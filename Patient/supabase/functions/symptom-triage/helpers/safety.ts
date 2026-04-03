/**
 * Deterministic Emergency Safety Rule Engine.
 * Runs AFTER model output to override hallucinations.
 * This layer is NOT AI — it's pure keyword + vital matching.
 */

const EMERGENCY_KEYWORDS = [
  "chest pain", "chest tightness", "heart attack",
  "arm numbness", "left arm pain", "arm tingling",
  "difficulty breathing", "can't breathe", "shortness of breath", "breathless",
  "severe bleeding", "heavy bleeding", "uncontrolled bleeding",
  "black stool", "black stools", "melena", "tarry stool",
  "vomiting blood", "blood vomit", "hematemesis",
  "stroke", "face drooping", "slurred speech", "sudden weakness",
  "loss of consciousness", "unconscious", "passed out", "fainted",
  "seizure", "seizures", "convulsions", "fitting",
  "anaphylaxis", "throat swelling", "can't swallow",
  "suicidal", "suicide", "self harm", "want to die",
];

const VITAL_THRESHOLDS = {
  spo2: { critical: 90, unit: "%" },
  heart_rate: { critical: 140, unit: "bpm" },
  systolic_bp: { critical: 180, unit: "mmHg" },
  diastolic_bp: { critical: 120, unit: "mmHg" },
  temperature: { critical: 40.5, unit: "°C" },
};

export interface EmergencyOverride {
  isEmergency: boolean;
  matchedKeywords: string[];
  matchedVitals: string[];
}

/**
 * Scan user messages + vitals for hard emergency triggers.
 * Returns override data if emergency detected.
 */
export function runEmergencyRuleEngine(
  messages: Array<{ role: string; content: string }>,
  response: Record<string, any>,
  patientContext: Record<string, any>
): EmergencyOverride {
  const matchedKeywords: string[] = [];
  const matchedVitals: string[] = [];

  // 1. Scan all user messages for emergency keywords
  const allUserText = messages
    .filter((m) => m.role === "user")
    .map((m) => (m.content || "").toLowerCase())
    .join(" ");

  for (const keyword of EMERGENCY_KEYWORDS) {
    if (allUserText.includes(keyword)) {
      matchedKeywords.push(keyword);
    }
  }

  // 2. Scan AI reply for emergency keywords (model might detect something we should enforce)
  const aiReply = (response.reply || "").toLowerCase();
  for (const keyword of EMERGENCY_KEYWORDS) {
    if (aiReply.includes(keyword) && !matchedKeywords.includes(keyword)) {
      matchedKeywords.push(keyword);
    }
  }

  // 3. Check vitals from patient context
  if (patientContext.spo2 && patientContext.spo2 < VITAL_THRESHOLDS.spo2.critical) {
    matchedVitals.push(`SPO2 ${patientContext.spo2}% < ${VITAL_THRESHOLDS.spo2.critical}%`);
  }
  if (patientContext.heart_rate && patientContext.heart_rate > VITAL_THRESHOLDS.heart_rate.critical) {
    matchedVitals.push(`HR ${patientContext.heart_rate}bpm > ${VITAL_THRESHOLDS.heart_rate.critical}bpm`);
  }
  if (patientContext.systolic_bp && patientContext.systolic_bp > VITAL_THRESHOLDS.systolic_bp.critical) {
    matchedVitals.push(`SBP ${patientContext.systolic_bp}mmHg > ${VITAL_THRESHOLDS.systolic_bp.critical}mmHg`);
  }
  if (patientContext.temperature && patientContext.temperature > VITAL_THRESHOLDS.temperature.critical) {
    matchedVitals.push(`Temp ${patientContext.temperature}°C > ${VITAL_THRESHOLDS.temperature.critical}°C`);
  }

  // Symptom severity >= 9 with any concerning body region
  const severityTrigger = (patientContext.severity >= 9) &&
    ["chest", "head", "heart"].some((r) => (patientContext.body_region || "").toLowerCase().includes(r));
  
  const isEmergency = matchedKeywords.length > 0 || matchedVitals.length > 0 || severityTrigger;

  return { isEmergency, matchedKeywords, matchedVitals };
}

/**
 * Apply emergency overrides to the response object.
 * This MUTATES the response in-place.
 */
export function applyEmergencyOverrides(
  response: Record<string, any>,
  override: EmergencyOverride
): void {
  if (!override.isEmergency) return;

  response.emergency = true;
  response.action = "emergency_room";
  response.specialization = "Emergency Medicine";
  response.risk_score = Math.max(response.risk_score || 0, 90);

  // Prepend emergency warning to reply
  const warning = "⚠️ EMERGENCY ALERT: Based on your symptoms, this requires IMMEDIATE medical attention. Please call emergency services or go to the nearest emergency room NOW.";
  if (!response.reply?.includes("EMERGENCY")) {
    response.reply = `${warning}\n\n${response.reply || ""}`;
  }

  // Add emergency reasoning
  if (!response.confidence_reasoning) response.confidence_reasoning = [];
  if (override.matchedKeywords.length > 0) {
    response.confidence_reasoning.push(`Emergency keywords detected: ${override.matchedKeywords.join(", ")}`);
  }
  if (override.matchedVitals.length > 0) {
    response.confidence_reasoning.push(`Critical vital signs: ${override.matchedVitals.join(", ")}`);
  }
}
