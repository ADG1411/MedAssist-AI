import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * doctor-patient-view: Fetches a patient's complete health snapshot for the Doctor Portal.
 * 
 * Input:  { patient_id: UUID }  + Doctor's JWT in Authorization header
 * Output: Full patient health data (profile, symptoms, nutrition, vitals, meds, records, goals)
 * 
 * Security: Validates doctor JWT, creates/checks doctor_patient_access row, logs action.
 */

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ── 1. AUTH: Verify doctor JWT ──
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabaseAdmin.auth.getUser(token);
    
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Invalid or expired token" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const doctorId = user.id;

    // ── 2. PARSE REQUEST ──
    const body = await req.json();
    const patientId: string = body.patient_id;
    const accessType: string = body.access_type || "standard"; // 'standard' | 'emergency'

    if (!patientId) {
      return new Response(JSON.stringify({ error: "patient_id is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    console.log(`[DoctorPatientView] Doctor: ${doctorId.substring(0, 8)} | Patient: ${patientId.substring(0, 8)} | Type: ${accessType}`);

    // ── 3. CREATE/UPDATE ACCESS GRANT ──
    const accessLevel = accessType === "emergency" ? "emergency" : "read";
    
    await supabaseAdmin.from("doctor_patient_access").upsert({
      doctor_id: doctorId,
      patient_id: patientId,
      access_level: accessLevel,
      granted_via: "qr_scan",
      granted_at: new Date().toISOString(),
      expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      is_active: true,
    }, { onConflict: "doctor_id,patient_id" });

    // Log the access
    await supabaseAdmin.from("doctor_access_logs").insert({
      doctor_id: doctorId,
      patient_id: patientId,
      action: "view_profile",
      metadata: { access_type: accessType },
    });

    // ── 4. FETCH PATIENT DATA (parallel) ──
    const [
      profileRes,
      symptomsRes,
      aiResultsRes,
      nutritionRes,
      nutritionSummaryRes,
      monitoringRes,
      vitalsRes,
      medsRes,
      medLogsRes,
      recordsRes,
      goalsRes,
    ] = await Promise.allSettled([
      // Profile
      supabaseAdmin
        .from("profiles")
        .select("*")
        .eq("id", patientId)
        .maybeSingle(),

      // Symptom sessions (last 10)
      supabaseAdmin
        .from("symptom_sessions")
        .select("id, body_region, severity, status, created_at, updated_at")
        .eq("user_id", patientId)
        .order("created_at", { ascending: false })
        .limit(10),

      // AI triage results (last 10)
      supabaseAdmin
        .from("ai_results")
        .select("id, conditions, risk_level, risk_score, recommended_action, monitoring_plan, doctor_handoff, prescription_hints, confidence_reasoning, created_at")
        .eq("user_id", patientId)
        .order("created_at", { ascending: false })
        .limit(10),

      // Nutrition logs (last 14 days)
      supabaseAdmin
        .from("nutrition_logs")
        .select("id, food_name, calories, carbs_g, protein_g, fat_g, sodium_mg, meal_type, is_safe, recovery_impact, reason, created_at")
        .eq("user_id", patientId)
        .order("created_at", { ascending: false })
        .limit(50),

      // Nutrition daily summary (last 14 days)
      supabaseAdmin
        .from("nutrition_daily_summary")
        .select("*")
        .eq("user_id", patientId)
        .order("summary_date", { ascending: false })
        .limit(14),

      // Monitoring logs (last 7 days)
      supabaseAdmin
        .from("monitoring_logs")
        .select("hydration_cups, sleep_hours, symptom_severity, mood, quick_status, logged_date")
        .eq("user_id", patientId)
        .order("logged_date", { ascending: false })
        .limit(7),

      // Vital readings (last 20)
      supabaseAdmin
        .from("vital_readings")
        .select("metric_type, value, unit, source, is_anomaly, recorded_at")
        .eq("user_id", patientId)
        .order("recorded_at", { ascending: false })
        .limit(20),

      // Active medication schedules
      supabaseAdmin
        .from("medication_schedules")
        .select("id, medication_name, dosage, frequency, times_of_day, start_date, end_date, prescribing_doctor, purpose, side_effects, is_active, adherence_streak, last_taken_at")
        .eq("user_id", patientId)
        .eq("is_active", true),

      // Recent medication logs (last 20)
      supabaseAdmin
        .from("medication_logs")
        .select("medication_name, status, taken_at, notes")
        .eq("user_id", patientId)
        .order("created_at", { ascending: false })
        .limit(20),

      // Health records
      supabaseAdmin
        .from("health_records")
        .select("id, title, record_type, file_url, metadata, created_at")
        .eq("user_id", patientId)
        .order("created_at", { ascending: false })
        .limit(10),

      // Active health goals
      supabaseAdmin
        .from("health_goals")
        .select("goal_type, title, target_value, current_value, unit, target_date, status, ai_suggestions, milestones")
        .eq("user_id", patientId)
        .eq("status", "active"),
    ]);

    // ── 5. ASSEMBLE RESPONSE ──
    const extract = (res: PromiseSettledResult<any>) =>
      res.status === "fulfilled" ? (res.value.data ?? null) : null;

    const profile = extract(profileRes);
    const symptomSessions = extract(symptomsRes) || [];
    const aiResults = extract(aiResultsRes) || [];
    const nutritionLogs = extract(nutritionRes) || [];
    const nutritionSummary = extract(nutritionSummaryRes) || [];
    const monitoringLogs = extract(monitoringRes) || [];
    const vitalReadings = extract(vitalsRes) || [];
    const medications = extract(medsRes) || [];
    const medicationLogs = extract(medLogsRes) || [];
    const healthRecords = extract(recordsRes) || [];
    const healthGoals = extract(goalsRes) || [];

    // Compute summary stats
    const totalSymptomSessions = symptomSessions.length;
    const highRiskResults = aiResults.filter((r: any) => r.risk_level === "high" || r.risk_level === "critical").length;
    const unsafeFoods = nutritionLogs.filter((n: any) => !n.is_safe).length;
    const avgHydration = monitoringLogs.length > 0
      ? monitoringLogs.reduce((s: number, m: any) => s + (m.hydration_cups || 0), 0) / monitoringLogs.length
      : 0;
    const avgSleep = monitoringLogs.length > 0
      ? monitoringLogs.reduce((s: number, m: any) => s + (m.sleep_hours || 0), 0) / monitoringLogs.length
      : 0;

    const response = {
      patient: {
        id: patientId,
        ...profile,
      },
      summary: {
        total_symptom_sessions: totalSymptomSessions,
        high_risk_results: highRiskResults,
        unsafe_foods_recent: unsafeFoods,
        avg_hydration_cups: Math.round(avgHydration * 10) / 10,
        avg_sleep_hours: Math.round(avgSleep * 10) / 10,
        active_medications: medications.length,
        active_goals: healthGoals.length,
      },
      symptom_sessions: symptomSessions,
      ai_results: aiResults,
      nutrition: {
        recent_logs: nutritionLogs,
        daily_summaries: nutritionSummary,
      },
      monitoring: monitoringLogs,
      vitals: vitalReadings,
      medications: {
        active_schedules: medications,
        recent_logs: medicationLogs,
      },
      health_records: healthRecords,
      health_goals: healthGoals,
      access: {
        doctor_id: doctorId,
        access_type: accessType,
        accessed_at: new Date().toISOString(),
      },
    };

    return new Response(JSON.stringify(response), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error) {
    console.error("[DoctorPatientView] Fatal error:", (error as Error).message);
    return new Response(
      JSON.stringify({ error: "Failed to fetch patient data", details: (error as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
