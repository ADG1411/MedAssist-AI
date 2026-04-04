import { createClient } from "https://esm.sh/@supabase/supabase-js@2.4.1";

const NIM_API_KEY = Deno.env.get("NIM_API_KEY") || "bhai Ato raz 6";
const NIM_BASE_URL = "https://integrate.api.nvidia.com/v1/chat/completions";
const MODEL = "google/gemma-3n-e4b-it";

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

    // Early break for PDF files as the Gemma vision model natively operates best on images 
    if (file_type === 'application/pdf') {
      return new Response(JSON.stringify({ success: true, message: "Skipped native AI processing for PDF." }), {
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
              text: `You are an expert AI medical document transcriber and clinical analyst. 
              Extract all the text present in the medical record image precisely. Also analyze its clinical contents.
              Return ONLY valid JSON format strictly matching this structure (no markdown fences around it):
              {
                "extracted_text": "The exact full raw text read from the image. Retain all lines and words.",
                "category": "Blood Test | Prescription | Imaging | Discharge Note | Doctor Note | Insurance | Other",
                "summary": "Brief 1-2 sentence clinical summary.",
                "risk_level": "Low | Medium | High | Critical",
                "metrics": { "marker_name": "x", "other_key": "val" },
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
      max_tokens: 2048,
      temperature: 0.20,
      top_p: 0.70,
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

    // ---- Save Extract as TXT Document inside Storage ----
    const extractedText = parsedData.extracted_text || "No readable text found.";
    const transcriptFileName = `${record_id}_transcript.txt`;

    // Generate text buffer using TextEncoder
    const fileBytes = new TextEncoder().encode(extractedText);

    // Upload to 'vault-records' storage bucket directly
    const { data: uploadData, error: uploadError } = await supabaseClient
      .storage
      .from('vault-records')
      .upload(`patients/${transcriptFileName}`, fileBytes, {
        contentType: 'text/plain',
        upsert: true
      });

    if (uploadError) {
      console.warn("Storage upload failed, but AI completed normally. Error:", uploadError);
    }

    const transcriptUrl = uploadError
      ? null
      : supabaseClient.storage.from('vault-records').getPublicUrl(`patients/${transcriptFileName}`).data.publicUrl;

    // ---- Update Health Records schema ----
    // Fetch original record metadata first to avoid overwriting existing properties if any
    const { data: existingRecord } = await supabaseClient
      .from("health_records")
      .select("metadata")
      .eq("id", record_id)
      .single();

    const newMetadata = {
      ...(existingRecord?.metadata || {}),
      ai_summary: parsedData.summary,
      extracted_metrics: parsedData.metrics || {},
      plain_text_explanation: parsedData.plain_language_explanation,
      transcript_url: transcriptUrl
    };

    // Update health_records table
    const { error: dbError } = await supabaseClient
      .from("health_records")
      .update({
        metadata: newMetadata
      })
      .eq("id", record_id);

    if (dbError) throw dbError;

    return new Response(JSON.stringify({ success: true, data: parsedData, file: transcriptUrl }), {
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
