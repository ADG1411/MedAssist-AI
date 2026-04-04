import { createClient } from "https://esm.sh/@supabase/supabase-js@2.4.1";

const NIM_API_KEY = Deno.env.get("NIM_API_KEY") || "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";
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

    const { record_id, image_base64, file_type } = await req.json();

    if (!record_id || !image_base64) {
      return new Response(JSON.stringify({ error: "Missing record_id or image_base64" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const payload = {
      model: MODEL,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: `You are an expert AI radiologist and medical document parser. Analyze the provided medical record image.
              Return ONLY valid JSON format exactly matching this structure:
              {
                "category": "Blood Test | Prescription | Imaging | Discharge Note | Doctor Note | Insurance | Other",
                "summary": "Brief 1-2 sentence clinical summary.",
                "risk_level": "Low | Medium | High | Critical",
                "abnormal_values": [ { "marker": "name", "value": "x", "range": "x-y", "status": "high|low|critical" } ],
                "doctor_specialization": "Specialist type implied",
                "recommended_action": "consult_doctor | monitor | routine",
                "tags": ["tag1", "tag2"],
                "plain_language_explanation": "Simple 1 sentence explanation for the patient."
              }`
            },
            {
              type: "image_url",
              image_url: { url: `data:${file_type};base64,${image_base64}` }
            }
          ]
        }
      ],
      max_tokens: 1024,
      temperature: 0.2
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

    if (!nimResponse.ok) {
      throw new Error(`NIM API Failed: ${nimResponse.statusText}`);
    }

    const nimData = await nimResponse.json();
    let respText = nimData.choices[0].message.content;
    
    // Strip markdown formatting like ```json ... ```
    if (respText.startsWith('```json')) respText = respText.substring(7);
    if (respText.endsWith('```')) respText = respText.substring(0, respText.length - 3);
    
    const parsedData = JSON.parse(respText.trim());

    // Update the database record securely
    const { error: dbError } = await supabaseClient
      .from("medical_records")
      .update({
        category: parsedData.category,
        ai_summary: parsedData.summary,
        ai_risk_level: parsedData.risk_level,
        abnormal_flags: parsedData.abnormal_values || [],
        ai_tags: parsedData.tags || [],
        extracted_text: parsedData.plain_language_explanation,
      })
      .eq("id", record_id);

    if (dbError) throw dbError;

    return new Response(JSON.stringify({ success: true, data: parsedData }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error: any) {
    console.error("AI Record Error:", error);
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
