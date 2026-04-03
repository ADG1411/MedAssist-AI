import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const NIM_API_KEY = Deno.env.get("NIM_API_KEY")!;
const NIM_BASE_URL = "https://integrate.api.nvidia.com/v1";
const NIM_MODEL = "moonshotai/kimi-k2.5";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const SYSTEM_PROMPT = `You are MedAssist Recovery Intelligence AI. Given a patient's health data over the past 7 days, generate a recovery prediction and health narrative.

Analyze trends in:
- Pain/symptom severity (decreasing = recovering)
- Hydration (increasing = good)
- Sleep quality (improving = good)
- Unsafe food consumption (decreasing = good compliance)

ALWAYS respond ONLY in this exact JSON format (no markdown, no code blocks, just raw JSON):
{
  "current_score": 78,
  "predicted_days_to_recovery": 3,
  "confidence": 85,
  "narrative": "Your recovery is progressing well. Pain has dropped from 7 to 3 over 5 days. Hydration improved by 40%. Avoid spicy food to maintain trajectory.",
  "correlations": [
    {"factor": "Hydration", "impact": "positive", "detail": "Increased from 3 to 7 cups daily"},
    {"factor": "Diet Compliance", "impact": "positive", "detail": "No unsafe meals in 3 days"},
    {"factor": "Sleep", "impact": "neutral", "detail": "Stable at 7 hours"}
  ],
  "recommendations": [
    "Continue drinking 7+ cups of water daily",
    "Avoid spicy and high-sodium foods",
    "Maintain 7-8 hours of sleep"
  ]
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
    const { user_id } = await req.json();

    if (!user_id) {
      return new Response(
        JSON.stringify({ error: "user_id required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    // Fetch patient data in parallel
    const [profileRes, monitoringRes, nutritionRes, sessionsRes] =
      await Promise.all([
        supabase
          .from("profiles")
          .select("name, chronic_conditions, allergies")
          .eq("id", user_id)
          .single(),
        supabase
          .from("monitoring_logs")
          .select("*")
          .eq("user_id", user_id)
          .order("logged_date", { ascending: false })
          .limit(7),
        supabase
          .from("nutrition_logs")
          .select("food_name, is_safe, reason, created_at")
          .eq("user_id", user_id)
          .eq("is_safe", false)
          .order("created_at", { ascending: false })
          .limit(10),
        supabase
          .from("symptom_sessions")
          .select("body_region, severity, created_at")
          .eq("user_id", user_id)
          .order("created_at", { ascending: false })
          .limit(5),
      ]);

    const profile = profileRes.data || {};
    const monitoringLogs = monitoringRes.data || [];
    const unsafeMeals = nutritionRes.data || [];
    const recentSessions = sessionsRes.data || [];

    // Build context for the AI
    const patientContext = `
PATIENT: ${profile.name || "Unknown"}
CHRONIC CONDITIONS: ${JSON.stringify(profile.chronic_conditions || [])}
ALLERGIES: ${JSON.stringify(profile.allergies || [])}

MONITORING LOGS (last 7 days, newest first):
${monitoringLogs
  .map(
    (log: any) =>
      `- Date: ${log.logged_date}, Pain: ${log.symptom_severity}, Hydration: ${log.hydration_cups}/8, Sleep: ${log.sleep_hours}h, Mood: ${log.mood}`
  )
  .join("\n")}

UNSAFE MEALS (recent):
${unsafeMeals
  .map((m: any) => `- ${m.food_name}: ${m.reason} (${m.created_at})`)
  .join("\n") || "None"}

RECENT SYMPTOM SESSIONS:
${recentSessions
  .map((s: any) => `- ${s.body_region}, severity: ${s.severity}/10 (${s.created_at})`)
  .join("\n") || "None"}`;

    const nimResponse = await fetch(`${NIM_BASE_URL}/chat/completions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${NIM_API_KEY}`,
      },
      body: JSON.stringify({
        model: NIM_MODEL,
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          {
            role: "user",
            content: `Analyze this patient's recovery data and generate predictions:\n\n${patientContext}`,
          },
        ],
        temperature: 0.3,
        max_tokens: 1024,
      }),
    });

    if (!nimResponse.ok) {
      const errText = await nimResponse.text();
      console.error("NIM Recovery API Error:", errText);
      throw new Error(`NIM API returned ${nimResponse.status}`);
    }

    const nimData = await nimResponse.json();
    const rawContent = nimData.choices?.[0]?.message?.content || "{}";

    let parsedResponse;
    try {
      const cleaned = rawContent
        .replace(/```json\n?/g, "")
        .replace(/```\n?/g, "")
        .trim();
      parsedResponse = JSON.parse(cleaned);
    } catch {
      parsedResponse = {
        current_score: 50,
        predicted_days_to_recovery: 5,
        confidence: 50,
        narrative: rawContent,
        correlations: [],
        recommendations: [],
      };
    }

    // Save prediction to DB
    await supabase.from("recovery_predictions").upsert(
      {
        user_id,
        current_score: parsedResponse.current_score || 50,
        predicted_days_to_recovery:
          parsedResponse.predicted_days_to_recovery || 5,
        confidence: parsedResponse.confidence || 50,
        trend_data: monitoringLogs.map((l: any) => l.symptom_severity),
      },
      { onConflict: "user_id" }
    );

    return new Response(JSON.stringify(parsedResponse), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Recovery Predict Error:", error);
    return new Response(
      JSON.stringify({
        current_score: 50,
        predicted_days_to_recovery: 5,
        confidence: 50,
        narrative: "Unable to generate prediction at this time.",
        correlations: [],
        recommendations: [],
        error: error.message,
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
