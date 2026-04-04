import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.4.1";

const NIM_API_KEY = Deno.env.get("NIM_API_KEY") || "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";
const NIM_BASE_URL = "https://integrate.api.nvidia.com/v1/chat/completions";
const MODEL = "moonshotai/kimi-k2.5";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
    );

    const { category, user_id } = await req.json();

    if (!category || !user_id) {
      return new Response(JSON.stringify({ error: "Missing category or user_id" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Fetch the last 5 records for the user in this category
    const { data: records, error } = await supabaseClient
      .from("medical_records")
      .select("id, created_at, abnormal_flags, ai_summary")
      .eq("user_id", user_id)
      .eq("category", category)
      .order("created_at", { ascending: false })
      .limit(5);

    if (error || !records || records.length < 2) {
      return new Response(JSON.stringify({ success: true, insight: "Not enough historical data to compare trends." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Pass the chronological records to Kimi to observe trends
    const chronologicalRecords = records.reverse();

    const payload = {
      model: MODEL,
      messages: [
        {
          role: "user",
          content: `You are an AI tracking a patient's health trajectory longitudinally. 
          Here are their last ${chronologicalRecords.length} records for ${category}, ordered oldest to newest:
          
          ${JSON.stringify(chronologicalRecords, null, 2)}
          
          Your job is to compare old vs new reports. Explain progression concisely.
          Example: "Vitamin D improved 22% since last report." or "Liver enzymes still elevated from prior test."
          Keep it to exactly 2 sentences of high-value clinical insight.`
        }
      ],
      max_tokens: 300,
      temperature: 0.1
    };

    const nimResponse = await fetch(NIM_BASE_URL, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": `Bearer ${NIM_API_KEY}`
      },
      body: JSON.stringify(payload),
    });

    if (!nimResponse.ok) throw new Error("NIM Compare Error");

    const nimData = await nimResponse.json();
    const insightText = nimData.choices[0].message.content.trim();

    return new Response(JSON.stringify({ success: true, insight: insightText }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error: any) {
    console.error("Compare Error:", error);
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
