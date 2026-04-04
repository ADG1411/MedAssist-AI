import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const NIM_API_KEY = Deno.env.get("NIM_API_KEY")!;
const NIM_BASE_URL = "https://integrate.api.nvidia.com/v1";
const PRIMARY_MODEL = "meta/llama-3.3-70b-instruct";
const FALLBACK_MODEL = "meta/llama-3.1-8b-instruct";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const SYSTEM_PROMPT = `You are Dr. NutriAssist, a board-certified clinical nutritionist and registered dietitian working as part of the MedAssist AI Health OS. You combine medical nutrition therapy with friendly, supportive coaching.

## YOUR CAPABILITIES
- Review meals against the patient's chronic conditions, allergies, and medications
- Provide personalized meal plans and healthy alternatives
- Calculate and track macro/micronutrient needs
- Flag unsafe food-drug and food-condition interactions
- Coach on weight management, hydration, and dietary goals
- Explain nutrition science in simple, actionable terms

## CONSULTATION PROTOCOL

1. **Memory-Aware**: Always check the patient's MEDICAL MEMORY for conditions, allergies, medications, and recent nutrition logs
2. **Condition-Safe**: Flag foods that conflict with chronic conditions (e.g., high sodium + hypertension, high sugar + diabetes)
3. **Allergy-Safe**: NEVER recommend foods containing known allergens
4. **Drug-Aware**: Consider food-medication interactions (e.g., grapefruit + statins, vitamin K + warfarin)
5. **Goal-Oriented**: Reference active health goals (weight loss, muscle gain, etc.)
6. **Encouraging**: Praise healthy choices, gently redirect unhealthy ones. Never shame.

## RESPONSE RULES
- Be conversational and warm, like talking to a caring nutritionist friend
- Give specific portion sizes and practical alternatives
- When flagging an issue, always provide a tasty healthy swap
- For general questions, give evidence-based concise answers
- Reference the patient's actual data when available (e.g., "Since you have hypertension...")

## RESPONSE FORMAT

ALWAYS respond in this exact JSON structure (no markdown, no code blocks):
{
  "reply": "Your warm, detailed nutrition response. Reference patient history when relevant. Use short paragraphs.",
  "flags": [
    {"food": "Food name", "issue": "High Sodium|High Sugar|Allergen|Drug Interaction|etc.", "advice": "Specific healthy alternative with portion"}
  ],
  "daily_tip": "A personalized 1-sentence tip based on their profile and goals.",
  "meal_suggestion": "Optional: A quick healthy meal idea if contextually relevant, or null.",
  "macro_note": "Optional: Brief note about their macro balance today, or null."
}`;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ── Memory Retrieval ──────────────────────────────────────────────────────

interface NutritionMemory {
  profile: Record<string, any> | null;
  recentNutrition: any[];
  recentMonitoring: any[];
  healthGoals: any[];
  medications: any[];
}

async function fetchNutritionMemory(
  supabase: any,
  userId: string
): Promise<NutritionMemory> {
  const [profileRes, nutritionRes, monitoringRes, goalsRes, medsRes] =
    await Promise.allSettled([
      supabase
        .from("profiles")
        .select(
          "name, age, gender, blood_group, allergies, chronic_conditions, height_cm, weight_kg, smoking_status, alcohol_frequency, sleep_hours_avg, stress_level, activity_level, diet_type, health_goals, ai_tone_preference"
        )
        .eq("id", userId)
        .maybeSingle(),

      supabase
        .from("nutrition_logs")
        .select(
          "food_name, calories, protein_g, carbs_g, fat_g, sodium_mg, sugar_g, fiber_g, is_safe, reason, meal_type, created_at"
        )
        .eq("user_id", userId)
        .order("created_at", { ascending: false })
        .limit(15),

      supabase
        .from("monitoring_logs")
        .select("hydration_cups, sleep_hours, symptom_severity, mood, logged_date")
        .eq("user_id", userId)
        .order("logged_date", { ascending: false })
        .limit(7),

      supabase
        .from("health_goals")
        .select("goal_type, title, target_value, current_value, unit, status")
        .eq("user_id", userId)
        .eq("status", "active")
        .limit(5),

      supabase
        .from("medication_schedules")
        .select("medication_name, dosage, frequency, purpose")
        .eq("user_id", userId)
        .eq("is_active", true)
        .limit(10),
    ]);

  return {
    profile: profileRes.status === "fulfilled" ? profileRes.value.data : null,
    recentNutrition:
      nutritionRes.status === "fulfilled" ? (nutritionRes.value.data ?? []) : [],
    recentMonitoring:
      monitoringRes.status === "fulfilled" ? (monitoringRes.value.data ?? []) : [],
    healthGoals:
      goalsRes.status === "fulfilled" ? (goalsRes.value.data ?? []) : [],
    medications:
      medsRes.status === "fulfilled" ? (medsRes.value.data ?? []) : [],
  };
}

function buildMemoryPrompt(memory: NutritionMemory): string {
  const lines: string[] = [];
  lines.push("MEDICAL MEMORY:");

  const p = memory.profile;
  if (p) {
    if (p.age) lines.push(`- Patient: ${p.age}y ${p.gender || ""} ${p.blood_group || ""}`);
    if (p.height_cm && p.weight_kg) {
      const bmi = (p.weight_kg / ((p.height_cm / 100) ** 2)).toFixed(1);
      lines.push(`- BMI: ${bmi} (${p.height_cm}cm, ${p.weight_kg}kg)`);
    }
    if (p.chronic_conditions?.length) lines.push(`- Chronic: ${p.chronic_conditions.join(", ")}`);
    if (p.allergies?.length) lines.push(`- Allergies: ${p.allergies.join(", ")}`);
    if (p.diet_type && p.diet_type !== "Regular") lines.push(`- Diet: ${p.diet_type}`);
    if (p.activity_level) lines.push(`- Activity: ${p.activity_level}`);
    if (p.smoking_status && p.smoking_status !== "Never") lines.push(`- Smoking: ${p.smoking_status}`);
    if (p.alcohol_frequency && p.alcohol_frequency !== "None") lines.push(`- Alcohol: ${p.alcohol_frequency}`);
    if (p.sleep_hours_avg) lines.push(`- Avg sleep: ${p.sleep_hours_avg}h`);
    if (p.stress_level) lines.push(`- Stress: ${p.stress_level}`);
  }

  // Active medications (for drug-food interactions)
  if (memory.medications.length > 0) {
    const meds = memory.medications.map((m: any) => `${m.medication_name} (${m.purpose || m.dosage})`).join(", ");
    lines.push(`- Active Meds: ${meds}`);
  }

  // Health goals
  if (memory.healthGoals.length > 0) {
    const goals = memory.healthGoals.map((g: any) => `${g.title} (${g.current_value}/${g.target_value} ${g.unit || ""})`).join(", ");
    lines.push(`- Health Goals: ${goals}`);
  }

  // Recent nutrition logs
  if (memory.recentNutrition.length > 0) {
    const unsafe = memory.recentNutrition.filter((n: any) => !n.is_safe);
    if (unsafe.length > 0) {
      const triggers = unsafe.slice(0, 3).map((n: any) => `${n.food_name} (${n.reason || "flagged"})`).join(", ");
      lines.push(`- Recent flagged foods: ${triggers}`);
    }
    const todayLogs = memory.recentNutrition.slice(0, 5);
    const totalCal = todayLogs.reduce((s: number, n: any) => s + (n.calories || 0), 0);
    const totalProtein = todayLogs.reduce((s: number, n: any) => s + (n.protein_g || 0), 0);
    const totalCarbs = todayLogs.reduce((s: number, n: any) => s + (n.carbs_g || 0), 0);
    const totalFat = todayLogs.reduce((s: number, n: any) => s + (n.fat_g || 0), 0);
    if (totalCal > 0) {
      lines.push(`- Recent intake (last 5 meals): ${totalCal}kcal, P:${totalProtein}g, C:${totalCarbs}g, F:${totalFat}g`);
    }
  }

  // Hydration & sleep from monitoring
  if (memory.recentMonitoring.length > 0) {
    const avgHydration = memory.recentMonitoring.reduce((s: number, m: any) => s + (m.hydration_cups || 0), 0) / memory.recentMonitoring.length;
    const avgSleep = memory.recentMonitoring.reduce((s: number, m: any) => s + (m.sleep_hours || 0), 0) / memory.recentMonitoring.length;
    lines.push(`- Hydration: avg ${avgHydration.toFixed(1)} cups/day ${avgHydration < 5 ? "(LOW)" : ""}`);
    lines.push(`- Sleep: avg ${avgSleep.toFixed(1)}h ${avgSleep < 6 ? "(POOR — affects metabolism)" : ""}`);
  }

  return lines.length > 1 ? lines.join("\n") : "";
}

// ── Main Handler ──────────────────────────────────────────────────────────

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ── 1. AUTH ──
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
    const userMessageCount = messages.filter((m) => m.role === "user").length;

    console.log(`[NutriAssist] User: ${userId?.substring(0, 8) || "anon"} | Messages: ${userMessageCount}`);

    // ── 3. MEMORY RETRIEVAL ──
    let memoryPrompt = "";
    if (userId) {
      try {
        const memory = await fetchNutritionMemory(supabaseAdmin, userId);
        memoryPrompt = buildMemoryPrompt(memory);
        if (memoryPrompt) {
          console.log(`[NutriAssist] Memory loaded: ${memoryPrompt.split("\n").length} lines`);
        }
      } catch (e) {
        console.error("[NutriAssist] Memory fetch failed (non-blocking):", (e as Error).message);
      }
    }

    // ── 4. BUILD PROMPT ──
    let fullSystemPrompt = SYSTEM_PROMPT;
    if (memoryPrompt) {
      fullSystemPrompt += `\n\n${memoryPrompt}`;
    }

    // Add today's macro context from client
    const parts: string[] = [];
    if (patientContext.calories) parts.push(`Calories: ${patientContext.calories}kcal`);
    if (patientContext.protein) parts.push(`Protein: ${patientContext.protein}g`);
    if (patientContext.carbs) parts.push(`Carbs: ${patientContext.carbs}g`);
    if (patientContext.fat) parts.push(`Fat: ${patientContext.fat}g`);
    if (patientContext.calories_burned) parts.push(`Burned: ${patientContext.calories_burned}kcal`);
    if (patientContext.chronic_conditions?.length) {
      parts.push(`Conditions: ${JSON.stringify(patientContext.chronic_conditions)}`);
    }
    if (patientContext.allergies?.length) {
      parts.push(`Allergies: ${JSON.stringify(patientContext.allergies)}`);
    }
    if (parts.length > 0) {
      fullSystemPrompt += `\n\nTODAY'S NUTRITION CONTEXT:\n- ${parts.join("\n- ")}`;
    }

    const nimMessages = [
      { role: "system", content: fullSystemPrompt },
      ...messages.map((m) => ({
        role: m.role === "ai" ? "assistant" : (m.role || "user"),
        content: m.content || "",
      })),
    ];

    // ── 5. NIM API (Primary → Fallback) ──
    let nimResponseText = "";
    let modelUsed = PRIMARY_MODEL;

    for (const model of [PRIMARY_MODEL, FALLBACK_MODEL]) {
      try {
        const nimResponse = await fetch(`${NIM_BASE_URL}/chat/completions`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${NIM_API_KEY}`,
          },
          body: JSON.stringify({
            model,
            messages: nimMessages,
            temperature: 0.3,
            max_tokens: 1200,
            top_p: 0.85,
          }),
        });

        if (nimResponse.ok) {
          nimResponseText = await nimResponse.text();
          modelUsed = model;
          console.log(`[NutriAssist] NIM OK with ${model}`);
          break;
        }

        console.warn(`[NutriAssist] ${model} returned ${nimResponse.status}, trying fallback...`);
        if (model === FALLBACK_MODEL) {
          nimResponseText = await nimResponse.text();
        }
      } catch (e) {
        console.error(`[NutriAssist] ${model} network error:`, (e as Error).message);
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

    let parsedResponse;
    try {
      let cleaned = rawContent;
      const firstBrace = cleaned.indexOf("{");
      const lastBrace = cleaned.lastIndexOf("}");
      if (firstBrace !== -1 && lastBrace !== -1 && lastBrace > firstBrace) {
        cleaned = cleaned.substring(firstBrace, lastBrace + 1);
      }
      parsedResponse = JSON.parse(cleaned);
    } catch {
      // Salvage what we can
      let salvagedReply = rawContent || "I'm analyzing your nutrition data. Could you rephrase your question?";
      const replyMatch = rawContent.match(/"reply"\s*:\s*"([^"\\]*(?:\\.[^"\\]*)*)"/);
      if (replyMatch?.[1]) {
        salvagedReply = replyMatch[1].replace(/\\n/g, "\n").replace(/\\"/g, '"');
      }
      parsedResponse = {
        reply: salvagedReply,
        flags: [],
        daily_tip: "Stay hydrated — aim for 8 glasses of water today.",
        meal_suggestion: null,
        macro_note: null,
      };
    }

    // Ensure required fields
    parsedResponse.reply = parsedResponse.reply || "Could you tell me more about what you'd like nutrition help with?";
    parsedResponse.flags = parsedResponse.flags || [];
    parsedResponse.daily_tip = parsedResponse.daily_tip || null;
    parsedResponse.meal_suggestion = parsedResponse.meal_suggestion || null;
    parsedResponse.macro_note = parsedResponse.macro_note || null;

    // Debug metadata
    parsedResponse._model = modelUsed;
    parsedResponse._memory_lines = memoryPrompt ? memoryPrompt.split("\n").length : 0;

    return new Response(JSON.stringify(parsedResponse), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("[NutriAssist] Fatal error:", (error as Error).message);
    return new Response(
      JSON.stringify({
        reply: "I'm temporarily unable to process your nutrition question. Please try again in a moment.",
        flags: [],
        daily_tip: "Eat a rainbow of fruits and vegetables today!",
        meal_suggestion: null,
        macro_note: null,
        error: (error as Error).message,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
