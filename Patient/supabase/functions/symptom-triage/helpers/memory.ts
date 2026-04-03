import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export interface MedicalMemory {
  profile: Record<string, any> | null;
  recentSessions: any[];
  recentNutrition: any[];
  recentMonitoring: any[];
  recentAiResults: any[];
  recentRecords: any[];
}

/**
 * Fetch comprehensive medical memory for a patient.
 * All queries run in parallel for performance.
 */
export async function fetchMedicalMemory(
  supabase: SupabaseClient,
  userId: string
): Promise<MedicalMemory> {
  const [
    profileRes,
    sessionsRes,
    nutritionRes,
    monitoringRes,
    aiResultsRes,
    recordsRes,
  ] = await Promise.allSettled([
    // 1. Patient profile (allergies, chronic conditions, vitals)
    supabase
      .from("profiles")
      .select("name, age, gender, blood_group, allergies, chronic_conditions, height_cm, weight_kg")
      .eq("id", userId)
      .maybeSingle(),

    // 2. Latest 5 symptom sessions
    supabase
      .from("symptom_sessions")
      .select("id, body_region, severity, status, created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(5),

    // 3. Latest 10 nutrition logs
    supabase
      .from("nutrition_logs")
      .select("food_name, calories, sodium_mg, is_safe, reason, meal_type, created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(10),

    // 4. Latest 7 monitoring logs
    supabase
      .from("monitoring_logs")
      .select("hydration_cups, sleep_hours, symptom_severity, mood, logged_date")
      .eq("user_id", userId)
      .order("logged_date", { ascending: false })
      .limit(7),

    // 5. Latest 5 AI results (previous diagnoses)
    supabase
      .from("ai_results")
      .select("conditions, risk_level, recommended_action, created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(5),

    // 6. Latest 3 health records summaries
    supabase
      .from("health_records")
      .select("title, record_type, metadata, created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(3),
  ]);

  return {
    profile: profileRes.status === "fulfilled" ? profileRes.value.data : null,
    recentSessions: sessionsRes.status === "fulfilled" ? (sessionsRes.value.data ?? []) : [],
    recentNutrition: nutritionRes.status === "fulfilled" ? (nutritionRes.value.data ?? []) : [],
    recentMonitoring: monitoringRes.status === "fulfilled" ? (monitoringRes.value.data ?? []) : [],
    recentAiResults: aiResultsRes.status === "fulfilled" ? (aiResultsRes.value.data ?? []) : [],
    recentRecords: recordsRes.status === "fulfilled" ? (recordsRes.value.data ?? []) : [],
  };
}

/**
 * Compress medical memory into a token-efficient prompt string.
 * Target: <300 tokens to leave room for conversation.
 */
export function buildCompressedMemoryPrompt(memory: MedicalMemory): string {
  const lines: string[] = [];
  lines.push("MEDICAL MEMORY:");

  // Profile
  const p = memory.profile;
  if (p) {
    if (p.age) lines.push(`- Patient: ${p.age}y ${p.gender || ""} ${p.blood_group || ""}`);
    if (p.chronic_conditions?.length) lines.push(`- Chronic: ${p.chronic_conditions.join(", ")}`);
    if (p.allergies?.length) lines.push(`- Allergies: ${p.allergies.join(", ")}`);
    if (p.height_cm && p.weight_kg) {
      const bmi = (p.weight_kg / ((p.height_cm / 100) ** 2)).toFixed(1);
      lines.push(`- BMI: ${bmi}`);
    }
  }

  // Recent monitoring trends
  if (memory.recentMonitoring.length > 0) {
    const latest = memory.recentMonitoring[0];
    const avgSeverity = memory.recentMonitoring.reduce((s: number, m: any) => s + (m.symptom_severity || 0), 0) / memory.recentMonitoring.length;
    const avgHydration = memory.recentMonitoring.reduce((s: number, m: any) => s + (m.hydration_cups || 0), 0) / memory.recentMonitoring.length;
    const avgSleep = memory.recentMonitoring.reduce((s: number, m: any) => s + (m.sleep_hours || 0), 0) / memory.recentMonitoring.length;

    lines.push(`- Pain trend: avg ${avgSeverity.toFixed(1)}/10 (${memory.recentMonitoring.length}d)`);
    lines.push(`- Hydration: avg ${avgHydration.toFixed(1)} cups/day ${avgHydration < 5 ? "(LOW)" : ""}`);
    lines.push(`- Sleep: avg ${avgSleep.toFixed(1)}h ${avgSleep < 6 ? "(POOR)" : ""}`);
    if (latest.mood) lines.push(`- Mood: ${latest.mood}`);
  }

  // Nutrition triggers
  if (memory.recentNutrition.length > 0) {
    const unsafe = memory.recentNutrition.filter((n: any) => !n.is_safe);
    if (unsafe.length > 0) {
      const triggers = unsafe.slice(0, 3).map((n: any) => n.food_name).join(", ");
      lines.push(`- Recent triggers: ${triggers}`);
    }
    const totalCal = memory.recentNutrition.slice(0, 5).reduce((s: number, n: any) => s + (n.calories || 0), 0);
    if (totalCal > 0) lines.push(`- Recent calorie intake: ~${totalCal} kcal (last 5 meals)`);
  }

  // Previous AI diagnoses
  if (memory.recentAiResults.length > 0) {
    const prevDx = memory.recentAiResults
      .filter((r: any) => r.conditions?.length > 0)
      .flatMap((r: any) => r.conditions.map((c: any) => c.name))
      .slice(0, 3);
    if (prevDx.length > 0) {
      lines.push(`- Previous AI dx: ${prevDx.join(", ")}`);
    }
  }

  // Recent sessions
  if (memory.recentSessions.length > 0) {
    const regions = [...new Set(memory.recentSessions.map((s: any) => s.body_region).filter(Boolean))];
    if (regions.length > 0) {
      lines.push(`- Recent complaint regions: ${regions.join(", ")}`);
    }
  }

  // Medical records
  if (memory.recentRecords.length > 0) {
    const summaries = memory.recentRecords
      .filter((r: any) => r.metadata?.ai_summary)
      .map((r: any) => `${r.title}: ${(r.metadata.ai_summary as string).substring(0, 60)}`)
      .slice(0, 2);
    if (summaries.length > 0) {
      lines.push(`- Lab/Records: ${summaries.join("; ")}`);
    }
  }

  return lines.length > 1 ? lines.join("\n") : "";
}
