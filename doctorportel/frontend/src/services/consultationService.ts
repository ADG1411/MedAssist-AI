import type { FullConsultationSummary, AIAnalysisResult, VitalSign } from '../types/consultation';

const BASE = '/api/v1';

async function tryBackend<T>(fn: () => Promise<T>, fallback: () => T): Promise<T> {
  try {
    return await fn();
  } catch (error) {
    console.warn('Backend unavailable, using fallback mock data for consultation', error);
    return fallback();
  }
}

function delay(ms = 600) {
  return new Promise(r => setTimeout(r, ms));
}

// ── Consultation APIs ─────────────────────────────────────────────────────────────

export async function getPatientIntelligence(patientId: string): Promise<FullConsultationSummary> {
  await delay(800);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/consultation/patient/${patientId}/full-summary`);
      if (!r.ok) throw new Error('Failed to fetch patient intelligence');
      return r.json();
    },
    () => MOCK_PATIENT_SUMMARY
  );
}

export async function getLiveVitals(patientId: string): Promise<VitalSign[]> {
  await delay(500);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/consultation/patient/${patientId}/vitals`);
      if (!r.ok) throw new Error('Failed to fetch vitals');
      return r.json();
    },
    () => [
      { date: 'Today', bp: '135/85', sugar: '110 mg/dL', hr: '78 bpm', warnings: ['bp'] }
    ]
  );
}

export async function startAIConsultationAnalysis(patientId: string, currentSymptoms?: string): Promise<AIAnalysisResult> {
  await delay(1000);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/consultation/ai/consultation-summary`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ patient_id: patientId, current_symptoms: currentSymptoms })
      });
      if (!r.ok) throw new Error('Failed to stream AI analysis');
      return r.json();
    },
    () => {
      const isHighRisk = currentSymptoms?.toLowerCase().includes('chest pain') || currentSymptoms?.toLowerCase().includes('breathe');
      return {
        summary: `Live Analysis: Patient is experiencing ${currentSymptoms ?? 'routine issues'}. Previous history indicates hypertension.`,
        risk_level: isHighRisk ? 'high' : currentSymptoms ? 'medium' : 'low',
        suggestions: [
          isHighRisk ? 'Order ECG immediately' : 'Continue current medication',
          'Check fasting blood sugar tomorrow'
        ],
        alerts: ['Drug Interaction Alert: Do NOT prescribe Beta Blockers without checking asthma history.']
      };
    }
  );
}

// ── Mock Data ─────────────────────────────────────────────────────────────────

const MOCK_PATIENT_SUMMARY: FullConsultationSummary = {
  patient: {
    id: "pat-123",
    name: "Rahul Sharma",
    age: 34,
    gender: "Male",
    blood_group: "B+",
    allergies: ["Penicillin", "Dust"],
    emergency_contact: "+91 9876543210 (Wife)",
    family_history: "Father: Type 2 Diabetes"
  },
  timeline: [
    { date: "2026-03-01", type: "visit", title: "Routine Checkup", doctor: "Dr. Anil Kumar", diagnosis: "Healthy" },
    { date: "2025-11-15", type: "specialist", title: "Cardiology Consult", doctor: "Dr. Sharma", diagnosis: "Mild Hypertension" }
  ],
  prescriptions: [
    { name: "Amlodipine 5mg", dosage: "1 tablet daily", duration: "30 days" }
  ],
  vitals: [
    { date: "Today", bp: "135/85", sugar: "110 mg/dL", hr: "78 bpm", warnings: ["bp"] }
  ],
  reports: [
    { id: "r1", name: "CBC Blood Test", date: "2026-03-01", type: "pdf" }
  ],
  ai_summary: {
    summary: "Patient has mild hypertension and a family history of diabetes. Vitals show moderately elevated blood pressure today.",
    priority: "medium",
    key_points: ["Elevated BP: 135/85", "Allergic to Penicillin", "On Amlodipine 5mg"],
    recommended_action: "Monitor BP closely, possibly adjust Amlodipine dosage."
  },
  risk_level: "medium"
};
