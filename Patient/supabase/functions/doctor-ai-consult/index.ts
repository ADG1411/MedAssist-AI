import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * doctor-ai-consult: Doctor-grade AI clinical consultation using patient's full medical memory.
 * 
 * Input:  { patient_id, messages[], consultation_type } + Doctor JWT
 * Output: Structured clinical analysis with differentials, flags, and follow-up plan
 */

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

// ── Patient Memory Retrieval ──────────────────────────────────────────────

interface PatientMemory {
  profile: Record<string, any> | null;
  recentSessions: any[];
  recentAiResults: any[];
  recentNutrition: any[];
  recentMonitoring: any[];
  medications: any[];
  healthGoals: any[];
  vitalReadings: any[];
}

async function fetchPatientMemory(supabase: any, patientId: string): Promise<PatientMemory> {
  const [profileRes, sessionsRes, aiRes, nutritionRes, monitoringRes, medsRes, goalsRes, vitalsRes] =
    await Promise.allSettled([
      supabase.from("profiles")
        .select("name, age, gender, blood_group, allergies, chronic_conditions, current_medications, height_cm, weight_kg, smoking_status, alcohol_frequency, sleep_hours_avg, stress_level, activity_level, diet_type, family_medical_history")
        .eq("id", patientId).maybeSingle(),

      supabase.from("symptom_sessions")
        .select("body_region, severity, status, created_at")
        .eq("user_id", patientId).order("created_at", { ascending: false }).limit(5),

      supabase.from("ai_results")
        .select("conditions, risk_level, risk_score, recommended_action, monitoring_plan, doctor_handoff, prescription_hints, created_at")
        .eq("user_id", patientId).order("created_at", { ascending: false }).limit(5),

      supabase.from("nutrition_logs")
        .select("food_name, calories, sodium_mg, is_safe, reason, meal_type, created_at")
        .eq("user_id", patientId).order("created_at", { ascending: false }).limit(10),

      supabase.from("monitoring_logs")
        .select("hydration_cups, sleep_hours, symptom_severity, mood, logged_date")
        .eq("user_id", patientId).order("logged_date", { ascending: false }).limit(7),

      supabase.from("medication_schedules")
        .select("medication_name, dosage, frequency, purpose, side_effects, adherence_streak")
        .eq("user_id", patientId).eq("is_active", true).limit(10),

      supabase.from("health_goals")
        .select("goal_type, title, target_value, current_value, unit, status")
        .eq("user_id", patientId).eq("status", "active").limit(5),

      supabase.from("vital_readings")
        .select("metric_type, value, unit, recorded_at")
        .eq("user_id", patientId).order("recorded_at", { ascending: false }).limit(10),
    ]);

  const extract = (res: PromiseSettledResult<any>) =>
    res.status === "fulfilled" ? (res.value.data ?? null) : null;

  return {
    profile: extract(profileRes),
    recentSessions: extract(sessionsRes) || [],
    recentAiResults: extract(aiRes) || [],
    recentNutrition: extract(nutritionRes) || [],
    recentMonitoring: extract(monitoringRes) || [],
    medications: extract(medsRes) || [],
    healthGoals: extract(goalsRes) || [],
    vitalReadings: extract(vitalsRes) || [],
  };
}

function buildPatientMemoryPrompt(memory: PatientMemory): string {
  const lines: string[] = [];
  lines.push("PATIENT MEDICAL RECORD:");

  const p = memory.profile;
  if (p) {
    lines.push(`- Patient: ${p.name || "Unknown"}, ${p.age || "?"}y ${p.gender || ""}, Blood: ${p.blood_group || "N/A"}`);
    if (p.height_cm && p.weight_kg) {
      const bmi = (p.weight_kg / ((p.height_cm / 100) ** 2)).toFixed(1);
      lines.push(`- BMI: ${bmi} (${p.height_cm}cm / ${p.weight_kg}kg)`);
    }
    if (p.chronic_conditions?.length) lines.push(`- Chronic Conditions: ${p.chronic_conditions.join(", ")}`);
    if (p.allergies?.length) lines.push(`- Known Allergies: ${p.allergies.join(", ")}`);
    if (p.current_medications?.length) lines.push(`- Current Medications: ${p.current_medications.join(", ")}`);
    if (p.family_medical_history?.length) {
      const fmh = p.family_medical_history.map((f: any) => `${f.condition} (${f.relation})`).join(", ");
      lines.push(`- Family Hx: ${fmh}`);
    }
    if (p.smoking_status && p.smoking_status !== "Never") lines.push(`- Smoking: ${p.smoking_status}`);
    if (p.alcohol_frequency && p.alcohol_frequency !== "None") lines.push(`- Alcohol: ${p.alcohol_frequency}`);
    if (p.activity_level) lines.push(`- Activity Level: ${p.activity_level}`);
    if (p.diet_type && p.diet_type !== "Regular") lines.push(`- Diet Type: ${p.diet_type}`);
  }

  // Active medications with adherence
  if (memory.medications.length > 0) {
    const meds = memory.medications.map((m: any) =>
      `${m.medication_name} ${m.dosage} ${m.frequency} (${m.purpose || "—"}, adherence: ${m.adherence_streak || 0}d streak)`
    ).join("; ");
    lines.push(`- Active Rx: ${meds}`);
  }

  // Recent AI diagnoses
  if (memory.recentAiResults.length > 0) {
    const dxList = memory.recentAiResults
      .filter((r: any) => r.conditions?.length > 0)
      .flatMap((r: any) => r.conditions.map((c: any) => `${c.name} (${c.probability || "?"}%)`))
      .slice(0, 5);
    if (dxList.length > 0) lines.push(`- AI Dx History: ${dxList.join(", ")}`);

    const highRisk = memory.recentAiResults.filter((r: any) => r.risk_score >= 60);
    if (highRisk.length > 0) {
      lines.push(`- ⚠ ${highRisk.length} high-risk episodes in recent history`);
    }
  }

  // Symptom regions
  if (memory.recentSessions.length > 0) {
    const regions = [...new Set(memory.recentSessions.map((s: any) => s.body_region).filter(Boolean))];
    if (regions.length > 0) lines.push(`- Recent Complaint Regions: ${regions.join(", ")}`);
    const avgSeverity = memory.recentSessions.reduce((s: number, m: any) => s + (m.severity || 0), 0) / memory.recentSessions.length;
    lines.push(`- Avg Severity: ${avgSeverity.toFixed(1)}/10`);
  }

  // Vitals
  if (memory.vitalReadings.length > 0) {
    const vitalMap: Record<string, string> = {};
    for (const v of memory.vitalReadings) {
      if (!vitalMap[v.metric_type]) {
        vitalMap[v.metric_type] = `${v.value} ${v.unit}`;
      }
    }
    const vitalStr = Object.entries(vitalMap).map(([k, v]) => `${k}: ${v}`).join(", ");
    lines.push(`- Latest Vitals: ${vitalStr}`);
  }

  // Monitoring trends
  if (memory.recentMonitoring.length > 0) {
    const avgHydration = memory.recentMonitoring.reduce((s: number, m: any) => s + (m.hydration_cups || 0), 0) / memory.recentMonitoring.length;
    const avgSleep = memory.recentMonitoring.reduce((s: number, m: any) => s + (m.sleep_hours || 0), 0) / memory.recentMonitoring.length;
    lines.push(`- Hydration: avg ${avgHydration.toFixed(1)} cups/day ${avgHydration < 5 ? "(LOW)" : ""}`);
    lines.push(`- Sleep: avg ${avgSleep.toFixed(1)}h ${avgSleep < 6 ? "(POOR)" : ""}`);
    const latest = memory.recentMonitoring[0];
    if (latest.mood) lines.push(`- Latest Mood: ${latest.mood}`);
  }

  // Nutrition flags
  if (memory.recentNutrition.length > 0) {
    const unsafe = memory.recentNutrition.filter((n: any) => !n.is_safe);
    if (unsafe.length > 0) {
      const triggers = unsafe.slice(0, 3).map((n: any) => `${n.food_name} (${n.reason || "flagged"})`).join(", ");
      lines.push(`- Dietary Flags: ${triggers}`);
    }
  }

  // Health goals
  if (memory.healthGoals.length > 0) {
    const goals = memory.healthGoals.map((g: any) => `${g.title} (${g.current_value}/${g.target_value} ${g.unit || ""})`).join(", ");
    lines.push(`- Active Goals: ${goals}`);
  }

  return lines.length > 1 ? lines.join("\n") : "No patient medical history available.";
}

// ── System Prompts by consultation type ───────────────────────────────────

function getSystemPrompt(consultationType: string, memoryPrompt: string): string {
  const basePrompt = `You are Dr. MedAssist AI Clinical Advisor, assisting a licensed physician with evidence-based clinical decision support. You are reviewing a real patient's medical record.

IMPORTANT:
- You are communicating with a DOCTOR, not a patient. Use professional medical language.
- Provide differential diagnoses with probability estimates
- Flag drug-drug, drug-food, and drug-condition interactions
- Reference patient data directly when making assessments
- Include ICD-10 codes when relevant
- Always recommend further investigations when uncertainty exists
- Never replace the physician's clinical judgment

${memoryPrompt}

RESPONSE FORMAT — Always respond in this exact JSON (no markdown, no code blocks):
{
  "reply": "Clinical analysis addressing the doctor's question. Reference patient data. Use medical terminology.",
  "differential_diagnosis": [
    {"condition": "Name", "probability": 70, "icd10": "code", "reasoning": "why"}
  ],
  "recommended_tests": ["test1", "test2"],
  "medication_flags": [
    {"type": "interaction|contraindication|adherence", "detail": "description", "severity": "low|moderate|high"}
  ],
  "risk_assessment": "low|moderate|high|critical",
  "follow_up_plan": "Recommended next steps",
  "clinical_notes": "Additional clinical observations"
}`;

  const typeInstructions: Record<string, string> = {
    general: "Focus on comprehensive clinical assessment. Consider all available data points.",
    symptom_review: "Focus on symptom progression, pattern recognition, and differential diagnosis. Analyze symptom sessions chronologically.",
    nutrition_review: "Focus on dietary impact on patient's conditions. Flag food-drug interactions. Assess nutritional adequacy for their health profile.",
    medication_review: "Focus on polypharmacy risks, drug interactions, adherence patterns, and dosage optimization. Cross-reference with conditions and diet.",
  };

  return basePrompt + "\n\nCONSULTATION FOCUS: " + (typeInstructions[consultationType] || typeInstructions.general);
}

// ── Main Handler ──────────────────────────────────────────────────────────

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ── 1. AUTH ──
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabaseAdmin.auth.getUser(token);

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Invalid token" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const doctorId = user.id;

    // ── 2. PARSE REQUEST ──
    const body = await req.json();
    const patientId: string = body.patient_id;
    const messages: Array<{ role: string; content: string }> = body.messages || [];
    const consultationType: string = body.consultation_type || "general";

    if (!patientId) {
      return new Response(JSON.stringify({ error: "patient_id is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    console.log(`[DoctorAIConsult] Doctor: ${doctorId.substring(0, 8)} | Patient: ${patientId.substring(0, 8)} | Type: ${consultationType}`);

    // ── 3. VERIFY ACCESS ──
    const { data: access } = await supabaseAdmin
      .from("doctor_patient_access")
      .select("is_active, expires_at")
      .eq("doctor_id", doctorId)
      .eq("patient_id", patientId)
      .maybeSingle();

    if (!access || !access.is_active || new Date(access.expires_at) < new Date()) {
      return new Response(JSON.stringify({ error: "No active access grant for this patient. Scan their QR code first." }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Log AI consult action
    await supabaseAdmin.from("doctor_access_logs").insert({
      doctor_id: doctorId,
      patient_id: patientId,
      action: "ai_consult",
      metadata: { consultation_type: consultationType, message_count: messages.length },
    }).catch(() => {}); // non-blocking

    // ── 4. FETCH PATIENT MEMORY ──
    let memoryPrompt = "No patient data available.";
    try {
      const memory = await fetchPatientMemory(supabaseAdmin, patientId);
      memoryPrompt = buildPatientMemoryPrompt(memory);
      console.log(`[DoctorAIConsult] Memory: ${memoryPrompt.split("\n").length} lines`);
    } catch (e) {
      console.error("[DoctorAIConsult] Memory fetch failed:", (e as Error).message);
    }

    // ── 5. BUILD PROMPT ──
    const systemPrompt = getSystemPrompt(consultationType, memoryPrompt);

    const nimMessages = [
      { role: "system", content: systemPrompt },
      ...messages.map((m) => ({
        role: m.role === "ai" ? "assistant" : (m.role || "user"),
        content: m.content || "",
      })),
    ];

    // ── 6. NIM API CALL ──
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
            temperature: 0.15,
            max_tokens: 2000,
            top_p: 0.85,
          }),
        });

        if (nimResponse.ok) {
          nimResponseText = await nimResponse.text();
          modelUsed = model;
          console.log(`[DoctorAIConsult] NIM OK with ${model}`);
          break;
        }

        console.warn(`[DoctorAIConsult] ${model} returned ${nimResponse.status}`);
        if (model === FALLBACK_MODEL) {
          nimResponseText = await nimResponse.text();
        }
      } catch (e) {
        console.error(`[DoctorAIConsult] ${model} error:`, (e as Error).message);
      }
    }

    // ── 7. PARSE ──
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
      parsedResponse = {
        reply: rawContent || "Unable to generate clinical analysis. Please rephrase your question.",
        differential_diagnosis: [],
        recommended_tests: [],
        medication_flags: [],
        risk_assessment: "unknown",
        follow_up_plan: "",
        clinical_notes: "",
      };
    }

    // Ensure required fields
    parsedResponse.reply = parsedResponse.reply || "Could you provide more details about your clinical question?";
    parsedResponse.differential_diagnosis = parsedResponse.differential_diagnosis || [];
    parsedResponse.recommended_tests = parsedResponse.recommended_tests || [];
    parsedResponse.medication_flags = parsedResponse.medication_flags || [];
    parsedResponse.risk_assessment = parsedResponse.risk_assessment || "unknown";
    parsedResponse.follow_up_plan = parsedResponse.follow_up_plan || "";
    parsedResponse.clinical_notes = parsedResponse.clinical_notes || "";
    parsedResponse._model = modelUsed;
    parsedResponse._memory_lines = memoryPrompt.split("\n").length;

    return new Response(JSON.stringify(parsedResponse), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error) {
    console.error("[DoctorAIConsult] Fatal error:", (error as Error).message);
    return new Response(
      JSON.stringify({
        reply: "Clinical analysis temporarily unavailable. Please retry.",
        differential_diagnosis: [],
        recommended_tests: [],
        medication_flags: [],
        risk_assessment: "unknown",
        error: (error as Error).message,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
