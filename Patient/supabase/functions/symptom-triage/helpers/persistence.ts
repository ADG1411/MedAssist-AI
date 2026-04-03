import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Database Writeback Pipeline.
 * Persists all triage outputs to the appropriate tables.
 * All writes are fire-and-forget with error logging (non-blocking).
 */

export async function persistTriageSession(
  supabase: SupabaseClient,
  userId: string,
  sessionId: string | null,
  response: Record<string, any>
): Promise<void> {
  const writes: Promise<void>[] = [];

  // 1. Save expanded AI result
  if (response.conditions?.length > 0 || response.risk_score) {
    writes.push(
      safeWrite("ai_results", () =>
        supabase.from("ai_results").insert({
          user_id: userId,
          session_id: sessionId,
          conditions: response.conditions || [],
          risk_level: response.conditions?.[0]?.risk || "Low",
          recommended_action: response.action,
          risk_score: response.risk_score,
          monitoring_plan: response.monitoring_plan || {},
          doctor_handoff: response.doctor_handoff || {},
          confidence_reasoning: response.confidence_reasoning || [],
          prescription_hints: response.prescription_hints || [],
          specialization: response.specialization,
        })
      )
    );
  }

  // 2. Save doctor handoff if present
  if (response.doctor_handoff?.summary) {
    writes.push(
      safeWrite("doctor_handoffs", () =>
        supabase.from("doctor_handoffs").insert({
          user_id: userId,
          session_id: sessionId,
          summary: response.doctor_handoff.summary,
          urgency: response.doctor_handoff.urgency || "routine",
          recommended_tests: response.doctor_handoff.recommended_tests || [],
          specialization: response.specialization,
        })
      )
    );
  }

  // 3. Seed monitoring tasks if monitoring_plan present and action is monitor
  if (response.monitoring_plan?.track_for_days > 0) {
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + (response.monitoring_plan.track_for_days || 5));

    writes.push(
      safeWrite("monitoring_tasks", () =>
        supabase.from("monitoring_tasks").insert({
          user_id: userId,
          session_id: sessionId,
          track_for_days: response.monitoring_plan.track_for_days,
          focus_metrics: response.monitoring_plan.focus_metrics || [],
          red_flags: response.monitoring_plan.red_flags || [],
          expires_at: expiresAt.toISOString(),
        })
      )
    );
  }

  // 4. Log emergency event if triggered
  if (response.emergency === true) {
    writes.push(
      safeWrite("emergency_events", () =>
        supabase.from("emergency_events").insert({
          user_id: userId,
          session_id: sessionId,
          trigger_keywords: response._emergency_keywords || [],
          risk_score: response.risk_score || 90,
          ai_response: {
            conditions: response.conditions,
            action: response.action,
            specialization: response.specialization,
          },
        })
      )
    );
  }

  // 5. Update session status if final assessment
  if (sessionId && response.next_question === null && response.conditions?.length > 0) {
    writes.push(
      safeWrite("session_status", () =>
        supabase
          .from("symptom_sessions")
          .update({
            status: response.emergency ? "escalated" : "completed",
          })
          .eq("id", sessionId)
      )
    );
  }

  // Execute all writes in parallel (fire-and-forget)
  await Promise.allSettled(writes);
}

/**
 * Safe write wrapper — logs errors but never throws.
 */
async function safeWrite(label: string, fn: () => Promise<any>): Promise<void> {
  try {
    const result = await fn();
    if (result?.error) {
      console.error(`[Persistence] ${label} error:`, result.error.message);
    }
  } catch (e) {
    console.error(`[Persistence] ${label} exception:`, (e as Error).message);
  }
}
