import "@supabase/functions-js/edge-runtime.d.ts";

const NIM_API_KEY = Deno.env.get("NIM_API_KEY")!;
const NIM_BASE_URL = "https://integrate.api.nvidia.com/v1";
const NIM_MODEL = "moonshotai/kimi-k2.5";

const SYSTEM_PROMPT = `You are a nutrition expert AI assistant called MedAssist Nutrition Vision.
Given a food image, identify EVERY food item visible on the plate/table.

For each item, estimate standard nutritional values per single serving unit.

ALWAYS respond ONLY in this exact JSON format (no markdown, no code blocks, just raw JSON):
{
  "detected_items": [
    {
      "name": "Food Item Name",
      "per_unit_label": "1 piece / 1 bowl / 1 cup / 100g",
      "calories": 71,
      "carbs_g": 15,
      "protein_g": 2.5,
      "fat_g": 1,
      "sodium_mg": 120,
      "fiber_g": 1.8,
      "sugar_g": 0.5
    }
  ],
  "meal_description": "Brief description of what the plate contains",
  "health_warnings": ["Any warnings based on common dietary concerns like high sodium, high sugar, etc."]
}

Be as accurate as possible with Indian, Asian, Western, and global cuisines.
If an item is unclear, make your best estimate and note uncertainty in the meal_description.`;

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
    const { image, patient_conditions } = await req.json();

    if (!image) {
      return new Response(
        JSON.stringify({ error: "No image data provided" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Build content array with text + image for multimodal
    const userContent: any[] = [
      {
        type: "text",
        text: `Identify all food items in this image and provide nutritional breakdown per serving.${
          patient_conditions
            ? ` The patient has these conditions: ${JSON.stringify(patient_conditions)}. Flag any items that may be unsafe.`
            : ""
        }`,
      },
      {
        type: "image_url",
        image_url: {
          url: image.startsWith("data:")
            ? image
            : `data:image/jpeg;base64,${image}`,
        },
      },
    ];

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
          { role: "user", content: userContent },
        ],
        temperature: 0.2,
        max_tokens: 1024,
      }),
    });

    if (!nimResponse.ok) {
      const errText = await nimResponse.text();
      console.error("NIM Vision API Error:", errText);
      throw new Error(`NIM API returned ${nimResponse.status}: ${errText}`);
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
        detected_items: [],
        meal_description: rawContent,
        health_warnings: [],
      };
    }

    return new Response(JSON.stringify(parsedResponse), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Nutrition Vision Error:", error);
    return new Response(
      JSON.stringify({
        detected_items: [],
        meal_description: "Could not analyze the image. Please try again.",
        health_warnings: [],
        error: error.message,
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
