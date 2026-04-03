import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { fetchMedicalMemory, buildCompressedMemoryPrompt } from "./helpers/memory.ts";
import { runEmergencyRuleEngine, applyEmergencyOverrides } from "./helpers/safety.ts";
import { parseAiJson, normalizeTriageResponse } from "./helpers/normalize.ts";
import { persistTriageSession } from "./helpers/persistence.ts";
import { buildSystemPrompt, getTokenBudget, buildPatientContextPrompt } from "./helpers/prompt_builder.ts";

const NIM_API_KEY = Deno.env.get("NIM_API_KEY")!;
const NIM_BASE_URL = "https://integrate.api.nvidia.com/v1";
const PRIMARY_MODEL = "meta/llama-3.3-70b-instruct";
const FALLBACK_MODEL = "meta/llama-3.1-8b-instruct";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ── 1. AUTH: Extract user from JWT ──
    const authHeader = req.headers.get("Authorization");
    const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    
    let userId: string | null = null;
    if (authHeader) {
      const token = authHeader.replace("Bearer ", "");
      const { data: { user } } = await supabaseAdmin.auth.getUser(token);
      userId = user?.id ?? null;
    }

    // ── 2. PARSE REQUEST ──
    const body = await req.json();
    const messages: Array<{ role: string; content: string }> = body.messages || [];
    const patientContext: Record<string, any> = body.patient_context || {};
    const aiMode: string = patientContext.ai_mode || "default";
    const sessionId: string | null = body.session_id || null;

    const userMessageCount = messages.filter((m) => m.role === "user").length;
    console.log(`[Triage v2] User: ${userId?.substring(0, 8) || "anon"} | Messages: ${userMessageCount} | Mode: ${aiMode}`);

    // ── 3. MEMORY RETRIEVAL ──
    let memoryPrompt = "";
    if (userId) {
      try {
        const memory = await fetchMedicalMemory(supabaseAdmin, userId);
        memoryPrompt = buildCompressedMemoryPrompt(memory);
        if (memoryPrompt) {
          console.log(`[Triage v2] Memory loaded: ${memoryPrompt.split("\n").length} lines`);
        }
      } catch (e) {
        console.error("[Triage v2] Memory fetch failed (non-blocking):", (e as Error).message);
      }
    }

    // ── 4. BUILD PROMPT ──
    const systemPrompt = buildSystemPrompt(memoryPrompt, userMessageCount, aiMode);
    const patientContextPrompt = buildPatientContextPrompt(patientContext);
    const tokenBudget = getTokenBudget(aiMode);

    const nimMessages = [
      { role: "system", content: systemPrompt + patientContextPrompt },
      ...messages.map((m) => ({
        role: m.role === "ai" ? "assistant" : (m.role || "user"),
        content: m.content || "",
      })),
    ];

    // ── 5. NIM API CALL (Primary → Fallback) ──
    let nimResponseText = "";
    let modelUsed = PRIMARY_MODEL;

    for (const model of [PRIMARY_MODEL, FALLBACK_MODEL]) {
      try {
        const nimResponse = await fetch(`${NIM_BASE_URL}/chat/completions`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${NIM_API_KEY}`,
          },
          body: JSON.stringify({
            model,
            messages: nimMessages,
            temperature: 0.2,
            max_tokens: tokenBudget,
            top_p: 0.85,
          }),
        });

        if (nimResponse.ok) {
          nimResponseText = await nimResponse.text();
          modelUsed = model;
          console.log(`[Triage v2] NIM OK with ${model}`);
          break;
        }

        console.warn(`[Triage v2] ${model} returned ${nimResponse.status}, trying fallback...`);
        
        if (model === FALLBACK_MODEL) {
          nimResponseText = await nimResponse.text();
        }
      } catch (e) {
        console.error(`[Triage v2] ${model} network error:`, (e as Error).message);
      }
    }

    // ── 6. PARSE + NORMALIZE ──
    let rawContent = "";
    try {
      const nimData = JSON.parse(nimResponseText);
      rawContent = nimData.choices?.[0]?.message?.content || "";
    } catch {
      rawContent = nimResponseText;
    }

    const parsedJson = parseAiJson(rawContent);
    let response = normalizeTriageResponse(parsedJson, rawContent, userMessageCount);

    // ── 7. SAFETY RULE ENGINE ──
    const emergencyOverride = runEmergencyRuleEngine(
      messages.map((m) => ({ role: m.role, content: m.content || "" })),
      response,
      patientContext
    );
    applyEmergencyOverrides(response, emergencyOverride);

    // Store matched keywords for persistence (then strip from client response)
    if (emergencyOverride.isEmergency) {
      response._emergency_keywords = emergencyOverride.matchedKeywords;
    }

    // ── 8. DATABASE WRITEBACK ──
    if (userId) {
      // Fire-and-forget: don't block the response
      persistTriageSession(supabaseAdmin, userId, sessionId, response).catch((e) => {
        console.error("[Triage v2] Persistence error:", (e as Error).message);
      });
    }

    // ── 9. CLEAN + RETURN ──
    // Remove internal fields before sending to client
    delete response._emergency_keywords;

    // Add debug metadata
    response._model = modelUsed;
    response._memory_lines = memoryPrompt ? memoryPrompt.split("\n").length : 0;

    return new Response(JSON.stringify(response), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error) {
    console.error("[Triage v2] Fatal error:", (error as Error).message);
    return new Response(
      JSON.stringify({
        reply: "I'm temporarily unable to process your request. If you're experiencing a medical emergency, please call emergency services immediately.",
        conditions: [],
        specialization: "General Physician",
        next_question: null,
        emergency: false,
        action: "monitor",
        prescription_hints: [],
        monitoring_plan: { track_for_days: 3, focus_metrics: ["pain_score"], red_flags: [] },
        doctor_handoff: { summary: "", urgency: "routine", recommended_tests: [] },
        risk_score: 0,
        confidence_reasoning: ["System error - fallback response"],
        error: (error as Error).message,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
