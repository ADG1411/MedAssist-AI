import { createClient } from "https://esm.sh/@supabase/supabase-js@2.4.1";

const NIM_API_KEY = Deno.env.get("NIM_API_KEY") || "BHAI TARI KEY NAKHVI😅 NO CHALE TO PACHI LAI JAJE😁 ";
const NIM_BASE_URL = "https://integrate.api.nvidia.com/v1/chat/completions";
const MODEL = "moonshotai/kimi-k2.5";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { status: 200, headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
    );

    const { user_id } = await req.json();

    if (!user_id) {
      return new Response(JSON.stringify({ error: "Missing user_id" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Fetch recent health snapshots for the user
    const { data: snapshots, error } = await supabaseClient
      .from("health_snapshots")
      .select("*")
      .eq("user_id", user_id)
      .order("snapshot_date", { ascending: false })
      .limit(2);

    if (error || !snapshots || snapshots.length === 0) {
      return new Response(JSON.stringify({
        success: true,
        overall_assessment: "Not enough health data yet. Keep tracking your vitals!",
        risk_flags: [],
        recommendations: ["Continue logging your daily health metrics."],
        trend_direction: "stable",
        priority_metric: null,
      }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const payload = {
      model: MODEL,
      messages: [
        {
          role: "user",
          content: `You are an AI health analyst for a patient health tracking app called MedAssist. 
          Analyze the following recent health metrics and provide clinically-informed insights.
          
          Health Data:
          ${JSON.stringify(snapshots, null, 2)}
          
          Provide a concise, actionable analysis. Return ONLY valid JSON matching this exact structure:
          {
            "overall_assessment": "2-sentence summary of the patient's current health status based on the data",
            "risk_flags": ["list of concerning patterns if any, e.g. 'elevated_heart_rate', 'low_sleep'"],
            "recommendations": ["3 specific, actionable health tips based on the actual data"],
            "trend_direction": "improving | stable | declining",
            "priority_metric": "the single metric that needs the most attention right now"
          }
          
          Rules:
          - Be specific. Reference actual numbers from the data.
          - If a metric is 0 or null, it means no data was recorded — don't flag it as a risk.
          - Focus on actionable advice, not generic health tips.
          - Keep the overall_assessment to exactly 2 sentences.`
        }
      ],
      max_tokens: 512,
      temperature: 0.15,
    };

    const nimResponse = await fetch(NIM_BASE_URL, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": `Bearer ${NIM_API_KEY}`,
      },
      body: JSON.stringify(payload),
    });

    if (!nimResponse.ok) {
      throw new Error(`NIM API Failed: ${nimResponse.statusText}`);
    }

    const nimData = await nimResponse.json();
    let respText = nimData.choices[0].message.content;

    // Strip markdown formatting
    if (respText.startsWith('```json')) respText = respText.substring(7);
    if (respText.startsWith('```')) respText = respText.substring(3);
    if (respText.endsWith('```')) respText = respText.substring(0, respText.length - 3);

    const analysis = JSON.parse(respText.trim());

    // Store AI insight back into the latest snapshot
    const latestDate = snapshots[0].snapshot_date;
    await supabaseClient
      .from("health_snapshots")
      .update({
        ai_insight: analysis.overall_assessment,
        ai_risk_flags: analysis.risk_flags || [],
        updated_at: new Date().toISOString(),
      })
      .eq("user_id", user_id)
      .eq("snapshot_date", latestDate);

    return new Response(JSON.stringify({ success: true, ...analysis }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error: any) {
    console.error("Health Trends Error:", error);
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
