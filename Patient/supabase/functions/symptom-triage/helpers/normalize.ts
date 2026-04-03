/**
 * Robust JSON normalization layer.
 * Guarantees the v2 response contract regardless of model output quality.
 */

const DEFAULT_MONITORING_PLAN = {
  track_for_days: 3,
  focus_metrics: ["pain_score", "hydration", "sleep"],
  red_flags: [],
};

const DEFAULT_DOCTOR_HANDOFF = {
  summary: "",
  urgency: "routine",
  recommended_tests: [],
};

/**
 * Parse raw AI output into valid JSON.
 * Handles markdown wrappers, truncated JSON, and malformed output.
 */
export function parseAiJson(rawContent: string): Record<string, any> | null {
  if (!rawContent || rawContent.trim().length === 0) return null;

  let cleaned = rawContent.trim();

  // Strip markdown code block wrappers
  cleaned = cleaned.replace(/^```(?:json)?\s*/i, "").replace(/\s*```$/i, "");

  // Find the outermost JSON object
  const firstBrace = cleaned.indexOf("{");
  const lastBrace = cleaned.lastIndexOf("}");

  if (firstBrace === -1 || lastBrace === -1 || lastBrace <= firstBrace) {
    return null;
  }

  cleaned = cleaned.substring(firstBrace, lastBrace + 1);

  try {
    return JSON.parse(cleaned);
  } catch {
    // Attempt repair: Fix common issues
    try {
      // Remove trailing commas before closing braces/brackets
      cleaned = cleaned.replace(/,\s*([}\]])/g, "$1");
      // Fix unescaped newlines inside strings
      cleaned = cleaned.replace(/(?<=": ")([\s\S]*?)(?="[,}\]])/g, (match) => {
        return match.replace(/\n/g, "\\n").replace(/\r/g, "");
      });
      return JSON.parse(cleaned);
    } catch {
      return null;
    }
  }
}

/**
 * Salvage the reply text from broken JSON using regex.
 */
function salvageReply(rawContent: string): string {
  const replyMatch = rawContent.match(/"reply"\s*:\s*"([^"\\]*(?:\\.[^"\\]*)*)"/);
  if (replyMatch?.[1]) {
    return replyMatch[1].replace(/\\n/g, "\n").replace(/\\"/g, '"');
  }
  // Last resort: return cleaned raw content as reply
  const text = rawContent.replace(/[{}"[\]]/g, "").trim();
  return text.substring(0, 500) || "I'm analyzing your symptoms. Could you provide more details?";
}

/**
 * Normalize and guarantee the full v2 response contract.
 */
export function normalizeTriageResponse(
  raw: Record<string, any> | null,
  rawContent: string,
  userMessageCount: number
): Record<string, any> {
  // If parsing totally failed, create safe fallback
  if (!raw) {
    return {
      reply: salvageReply(rawContent),
      conditions: [],
      specialization: "General Physician",
      next_question: userMessageCount < 3 ? "Can you describe your symptoms in more detail?" : null,
      emergency: false,
      action: "monitor",
      prescription_hints: [],
      monitoring_plan: DEFAULT_MONITORING_PLAN,
      doctor_handoff: DEFAULT_DOCTOR_HANDOFF,
      risk_score: 30,
      confidence_reasoning: ["Response normalization applied due to parsing failure"],
    };
  }

  const response = { ...raw };

  // Guarantee reply
  if (!response.reply || typeof response.reply !== "string") {
    response.reply = salvageReply(rawContent);
  }

  // Guarantee conditions array
  if (!Array.isArray(response.conditions)) {
    response.conditions = [];
  }

  // Force conditions on turn 3+
  if (userMessageCount >= 3 && response.conditions.length === 0) {
    response.conditions = [
      { name: "Unspecified symptoms requiring evaluation", confidence: 55, risk: "Medium" },
    ];
    response.next_question = null;
    response.action = response.action || "consult_doctor";
  }

  // Validate each condition object
  response.conditions = response.conditions.map((c: any) => ({
    name: c.name || "Unknown condition",
    confidence: typeof c.confidence === "number" ? Math.min(100, Math.max(0, c.confidence)) : 50,
    risk: ["Low", "Medium", "High", "Critical"].includes(c.risk) ? c.risk : "Medium",
  }));

  // Guarantee specialization
  if (!response.specialization || typeof response.specialization !== "string") {
    response.specialization = "General Physician";
  }

  // Guarantee action
  if (!["monitor", "consult_doctor", "emergency_room"].includes(response.action)) {
    response.action = response.conditions.length > 0 ? "consult_doctor" : "monitor";
  }

  // Guarantee emergency boolean
  response.emergency = response.emergency === true;

  // Guarantee next_question
  if (response.next_question !== null && typeof response.next_question !== "string") {
    response.next_question = null;
  }

  // Guarantee prescription_hints
  if (!Array.isArray(response.prescription_hints)) {
    response.prescription_hints = [];
  }

  // Guarantee monitoring_plan
  if (!response.monitoring_plan || typeof response.monitoring_plan !== "object") {
    response.monitoring_plan = { ...DEFAULT_MONITORING_PLAN };
  } else {
    response.monitoring_plan = {
      track_for_days: response.monitoring_plan.track_for_days || DEFAULT_MONITORING_PLAN.track_for_days,
      focus_metrics: Array.isArray(response.monitoring_plan.focus_metrics) ? response.monitoring_plan.focus_metrics : DEFAULT_MONITORING_PLAN.focus_metrics,
      red_flags: Array.isArray(response.monitoring_plan.red_flags) ? response.monitoring_plan.red_flags : [],
    };
  }

  // Guarantee doctor_handoff
  if (!response.doctor_handoff || typeof response.doctor_handoff !== "object") {
    response.doctor_handoff = { ...DEFAULT_DOCTOR_HANDOFF };
  } else {
    response.doctor_handoff = {
      summary: response.doctor_handoff.summary || "",
      urgency: ["routine", "priority", "urgent", "emergency"].includes(response.doctor_handoff.urgency)
        ? response.doctor_handoff.urgency
        : "routine",
      recommended_tests: Array.isArray(response.doctor_handoff.recommended_tests)
        ? response.doctor_handoff.recommended_tests
        : [],
    };
  }

  // Guarantee risk_score
  if (typeof response.risk_score !== "number") {
    // Derive from conditions
    const maxConfidence = response.conditions.reduce((max: number, c: any) => Math.max(max, c.confidence || 0), 0);
    const riskMultiplier = response.conditions.some((c: any) => c.risk === "Critical") ? 1.2
      : response.conditions.some((c: any) => c.risk === "High") ? 1.0
      : response.conditions.some((c: any) => c.risk === "Medium") ? 0.8
      : 0.5;
    response.risk_score = Math.min(100, Math.round(maxConfidence * riskMultiplier));
  }
  response.risk_score = Math.min(100, Math.max(0, response.risk_score));

  // Guarantee confidence_reasoning
  if (!Array.isArray(response.confidence_reasoning)) {
    response.confidence_reasoning = [];
  }

  return response;
}
