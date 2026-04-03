

const NIM_API_KEY = Deno.env.get("NIM_API_KEY")!;
const NIM_BASE_URL = "https://integrate.api.nvidia.com/v1";
const NIM_MODEL = "meta/llama-3.3-70b-instruct";

const SYSTEM_PROMPT = `You are Dr. NutriAssist, a specialized medical nutritionist and dietician working alongside MedAssist. Your goal is to review the patient's daily food intake, compare it with their chronic conditions, and provide actionable, safe dietary feedback. 

## PROTOCOL

1. Review the patient's context (chronic conditions, allergies).
2. Review their recent meals or their question.
3. If they ask a general nutrition question, answer it concisely and scientifically.
4. If they log an unsafe food (e.g., high sodium for a hypertension patient), you MUST flag it and explain why, providing a healthy alternative.
5. Do not hallucinate data. Be very supportive but medically precise.

## RESPONSE FORMAT

ALWAYS respond in this exact JSON format (strictly parseable, no code blocks):
{
  "reply": "Your main response, explaining the nutrition logic, praising healthy choices, or warning about risks.",
  "flags": [
    { "food": "Name of food", "issue": "High Sodium|High Sugar|Allergen|etc.", "advice": "Alternative suggestion" }
  ],
  "daily_tip": "A quick 1-sentence tip related to their profile."
}`;

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

    let patientInfo = `\n\nPATIENT PROFILE:
- Chronic Conditions: ${JSON.stringify(patient_context.chronic_conditions || [])}
- Known Allergies: ${JSON.stringify(patient_context.allergies || [])}
- Today's Macros Logged: C:${patient_context.carbs}g, F:${patient_context.fat}g, P:${patient_context.protein}g / ${patient_context.calories}kcal`;

    const nimMessages = [
      {
        role: "system",
        content: SYSTEM_PROMPT + patientInfo,
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
        temperature: 0.3,
        max_tokens: 1000,
        top_p: 0.85,
      }),
    });

    let nimResponseText = await nimResponse.text();

    if (nimResponse.status === 429) {
      nimResponse = await fetch(`${NIM_BASE_URL}/chat/completions`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${NIM_API_KEY}`,
        },
        body: JSON.stringify({
          model: "meta/llama-3.1-8b-instruct",
          messages: nimMessages,
          temperature: 0.3,
          max_tokens: 1000,
        }),
      });
      nimResponseText = await nimResponse.text();
    }

    if (!nimResponse.ok) {
      return new Response(
        JSON.stringify({
          reply: `I am currently unable to process your request due to server load. Please try again in a few moments.`,
          flags: [],
          daily_tip: "Drink plenty of water today!",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const nimData = JSON.parse(nimResponseText);
    const rawContent = nimData.choices?.[0]?.message?.content || "";

    let parsedResponse;
    try {
      let cleaned = rawContent;
      const firstBrace = cleaned.indexOf('{');
      const lastBrace = cleaned.lastIndexOf('}');
      if (firstBrace !== -1 && lastBrace !== -1 && lastBrace > firstBrace) {
          cleaned = cleaned.substring(firstBrace, lastBrace + 1);
      }
      parsedResponse = JSON.parse(cleaned);
    } catch (parseErr) {
      let salvagedReply = "I'm analyzing your meals but encountered a format issue.";
      const replyMatch = rawContent.match(/"reply"\s*:\s*"([^"\\]*(?:\\.[^"\\]*)*)"/);
      if (replyMatch && replyMatch[1]) salvagedReply = replyMatch[1].replace(/\\n/g, "\n").replace(/\\"/g, '"');

      parsedResponse = {
        reply: salvagedReply,
        flags: [],
        daily_tip: "Maintain a balanced diet.",
      };
    }

    return new Response(JSON.stringify(parsedResponse), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({
        reply: "An internal error occurred. Please try again.",
        flags: [],
        daily_tip: "",
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
