import "@supabase/functions-js/edge-runtime.d.ts";

const NIM_API_KEY = Deno.env.get("NIM_API_KEY")!;
const NIM_BASE_URL = "https://integrate.api.nvidia.com/v1";
const NIM_MODEL = "meta/llama-3.3-70b-instruct";

const SYSTEM_PROMPT = `You are Dr. MedAssist, a board-certified internal medicine physician conducting a telemedicine triage consultation. Your role is to diagnose efficiently like a real doctor — not to keep asking endless questions.

## CONSULTATION PROTOCOL

**Golden Rule:** If the patient provides highly detailed information in their FIRST or SECOND message (e.g., exact symptoms, duration, triggers), DO NOT ask unnecessary follow-up questions. IMMEDIATELY deliver your final clinical assessment, provide conditions, and set next_question to null.

**Phase 1 — Initial Assessment (Turn 1):**
When the patient first describes their symptoms:
- If the description is vague (e.g., "I have a headache"), acknowledge the symptom and ask exactly ONE focused clinical question (duration, triggers, severity, etc.).
- If the description is detailed (e.g., "I have a throbbing headache behind my left eye since yesterday, feel nauseous, and light hurts my eyes"), SKIP to Phase 3 immediately and give your assessment.

**Phase 2 — Targeted Follow-up (Turn 2):**
Based on their answer, assess if you have enough to form a clinical picture:
- IF YES: Skip to Phase 3 immediately.
- IF NO: Ask ONE more specific question to narrow the diagnosis (e.g., red flags, medications tried).

**Phase 3 — Conclusion (Final Assessment):**
Deliver a clear, confident medical assessment. You MUST provide conditions with confidence scores.
NEVER say "I need more details" after turn 3. Give your best clinical judgment.

## RESPONSE FORMAT

ALWAYS respond in this exact JSON (no markdown, no code blocks):
{
  "reply": "Your doctor-like response. Be specific, empathetic, and professional. Use medical terminology but explain it in simple terms. Example: 'Based on your symptoms — stomach pain after eating spicy food with burning sensation — this is most consistent with acute gastritis (stomach lining inflammation).'",
  "conditions": [
    {"name": "Most Likely Condition", "confidence": 75, "risk": "Low|Medium|High|Critical"},
    {"name": "Alternative Condition", "confidence": 45, "risk": "Low|Medium|High|Critical"}
  ],
  "specialization": "Gastroenterologist|Cardiologist|Neurologist|Pulmonologist|Orthopedic|Dermatologist|ENT|Psychiatrist|General Physician|Emergency Medicine",
  "next_question": "Your ONE specific follow-up question, or null if giving final assessment",
  "emergency": false,
  "action": "monitor|consult_doctor|emergency_room",
  "prescription_hints": ["OTC suggestion 1", "Lifestyle change 1"]
}

## IMPORTANT RULES:
1. If conditions array is empty, you MUST include a next_question
2. After 3+ patient messages, you MUST fill conditions array — give your best clinical judgment
3. Never be vague. "I need more information" is FORBIDDEN after 2 exchanges
4. Include real medical condition names (Gastritis, Tension Headache, GERD, Migraine, etc.)
5. Add prescription_hints with safe OTC medications and lifestyle advice
6. If ANY red flag symptoms (chest pain, difficulty breathing, severe bleeding, loss of consciousness, stroke symptoms) → immediately set emergency=true and action="emergency_room"
7. Be warm and reassuring but medically precise — like a good doctor, not like a chatbot
8. Consider the patient's chronic conditions and allergies when suggesting medications`;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const messages = body.messages || [];
    const patient_context = body.patient_context || {};

    // Count user messages to determine conversation phase
    const userMessageCount = messages.filter((m: any) => m.role === "user").length;

    console.log("User messages so far:", userMessageCount);
    console.log("Body region:", patient_context.body_region);
    console.log("Severity:", patient_context.severity);

    // Build patient context
    let patientInfo = "";
    if (patient_context) {
      patientInfo = `\n\nPATIENT PROFILE:
- Body Region: ${patient_context.body_region || "not specified"}
- Pain Severity: ${patient_context.severity || "not specified"}/10
- Chronic Conditions: ${JSON.stringify(patient_context.chronic_conditions || [])}
- Known Allergies: ${JSON.stringify(patient_context.allergies || [])}`;
    }

    // Add phase directive based on conversation progress
    let phaseDirective = "";
    if (userMessageCount >= 3) {
      phaseDirective = `\n\n⚠️ CRITICAL: The patient has provided ${userMessageCount} messages. You MUST now deliver your final clinical assessment. Fill the conditions array with your diagnoses. Do NOT ask another question. Set next_question to null. Provide prescription_hints.`;
    } else if (userMessageCount === 2) {
      phaseDirective = `\n\nYou are in Phase 2. Ask ONE final targeted follow-up question, OR if you have enough information, give your assessment now. Lean toward giving the assessment.`;
    }

    const nimMessages = [
      {
        role: "system",
        content: SYSTEM_PROMPT + patientInfo + phaseDirective,
      },
      ...messages.map((m: any) => ({
        role: m.role === "ai" ? "assistant" : (m.role || "user"),
        content: m.content || m.text || "",
      })),
    ];

    let nimResponse = await fetch(`${NIM_BASE_URL}/chat/completions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${NIM_API_KEY}`,
      },
      body: JSON.stringify({
        model: NIM_MODEL,
        messages: nimMessages,
        temperature: 0.25,
        max_tokens: 1200,
        top_p: 0.85,
      }),
    });

    let nimResponseText = await nimResponse.text();
    console.log("Primary NIM Status:", nimResponse.status);

    // If rate limited (429), immediately fallback to Llama 3
    if (nimResponse.status === 429) {
      console.log("Rate limited! Falling back to meta/llama-3.1-8b-instruct");
      nimResponse = await fetch(`${NIM_BASE_URL}/chat/completions`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${NIM_API_KEY}`,
        },
        body: JSON.stringify({
          model: "meta/llama-3.1-8b-instruct",
          messages: nimMessages,
          temperature: 0.25,
          max_tokens: 1200,
          top_p: 0.85,
        }),
      });
      nimResponseText = await nimResponse.text();
      console.log("Fallback NIM Status:", nimResponse.status);
    }

    if (!nimResponse.ok) {
      console.error("NIM Error:", nimResponseText);
      return new Response(
        JSON.stringify({
          reply: `I'm analyzing your ${patient_context.body_region || ""} symptoms. The AI service returned status ${nimResponse.status} despite retries. In the meantime, if your pain is severe or worsening, please seek immediate medical attention.`,
          conditions: [],
          specialization: "General Physician",
          next_question: "Can you describe exactly what you're feeling right now?",
          emergency: false,
          action: "monitor",
          prescription_hints: [],
          _debug_nim_status: nimResponse.status,
          _debug_nim_error: nimResponseText.substring(0, 200),
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const nimData = JSON.parse(nimResponseText);
    const rawContent = nimData.choices?.[0]?.message?.content || "";

    let parsedResponse;
    try {
      // Clean leading/trailing text and markdown safely
      let cleaned = rawContent;
      const firstBrace = cleaned.indexOf('{');
      const lastBrace = cleaned.lastIndexOf('}');
      if (firstBrace !== -1 && lastBrace !== -1 && lastBrace > firstBrace) {
          cleaned = cleaned.substring(firstBrace, lastBrace + 1);
      }
        
      parsedResponse = JSON.parse(cleaned);

      // Force conditions on turn 3+
      if (userMessageCount >= 3 && (!parsedResponse.conditions || parsedResponse.conditions.length === 0)) {
        parsedResponse.conditions = [
          { name: "Unspecified symptoms requiring evaluation", confidence: 60, risk: "Medium" }
        ];
        parsedResponse.next_question = null;
        parsedResponse.action = "consult_doctor";
      }

      // Ensure prescription_hints exists
      if (!parsedResponse.prescription_hints) {
        parsedResponse.prescription_hints = [];
      }

    } catch (parseErr) {
      console.error("JSON parse error:", parseErr);
      
      // Attempt to salvage the "reply" or "next_question" text via Regex if JSON is truncated
      let salvagedReply = "I'm processing your symptoms but encountered a format issue. Could you tell me more?";
      const replyMatch = rawContent.match(/"reply"\s*:\s*"([^"\\]*(?:\\.[^"\\]*)*)"/);
      if (replyMatch && replyMatch[1]) {
        salvagedReply = replyMatch[1].replace(/\\n/g, "\n").replace(/\\"/g, '"');
      }

      parsedResponse = {
        reply: salvagedReply,
        conditions: [],
        specialization: "General Physician",
        next_question: null,
        emergency: false,
        action: "monitor",
        prescription_hints: [],
      };
    }

    return new Response(JSON.stringify(parsedResponse), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Edge Function Error:", error.message);
    return new Response(
      JSON.stringify({
        reply: "I'm temporarily unable to process your request. Please try again.",
        conditions: [],
        specialization: "General Physician",
        next_question: null,
        emergency: false,
        action: "monitor",
        prescription_hints: [],
        error: error.message,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
