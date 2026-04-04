import { supabase } from './supabase';

// ── NIM AI API ──
const NIM_API_KEY = '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';
const MODEL = 'stepfun-ai/step-3.5-flash';

export interface PatientData {
  id: string;
  name: string;
  age: number;
  gender: string;
  blood_group: string;
  phone: string;
  email: string;
  allergies: string[];
  chronic_conditions: string[];
  emergency_contact: string;
  family_history: string;
  avatar: string;
  status: 'Active' | 'Critical' | 'Recovered';
  lastVisit: string;
  firstVisit: string;
  visitCount: number;
}

export interface VitalRecord {
  date: string;
  bp: string;
  hr: string;
  sugar: string;
  spo2: string;
  warnings: string[];
}

export interface MedicalRecord {
  id: string;
  date: string;
  type: 'prescription' | 'lab_report' | 'imaging' | 'notes';
  title: string;
  doctor: string;
  diagnosis: string;
  details: string;
}

export interface Medication {
  name: string;
  dosage: string;
  frequency: string;
  duration: string;
  active: boolean;
}

export interface FamilyMember {
  name: string;
  relation: string;
  phone: string;
  isEmergency: boolean;
}

export interface AISummary {
  summary: string;
  risk_level: 'low' | 'medium' | 'high';
  key_findings: string[];
  recommendations: string[];
  alerts: { text: string; severity: 'info' | 'warning' | 'critical' }[];
}

// ── DEMO DATA (used when Supabase doesn't have records) ──

const DEMO_PATIENTS: Record<string, PatientData> = {
  '1': { id: '1', name: 'Rahul Sharma', age: 34, gender: 'Male', blood_group: 'B+', phone: '+91 98765 43210', email: 'rahul@email.com', allergies: ['Penicillin', 'Dust'], chronic_conditions: ['Hypertension Stage 1'], emergency_contact: '+91 99887 65321', family_history: 'Father: Diabetic, Mother: Hypertension', avatar: 'https://ui-avatars.com/api/?name=Rahul+Sharma&background=f87171&color=fff', status: 'Active', lastVisit: '2025-01-15', firstVisit: '2024-06-10', visitCount: 8 },
  '2': { id: '2', name: 'Priya Verma', age: 28, gender: 'Female', blood_group: 'A+', phone: '+91 87654 32109', email: 'priya@email.com', allergies: ['Sulfa drugs'], chronic_conditions: ['Iron Deficiency Anaemia'], emergency_contact: '+91 88776 54321', family_history: 'No significant history', avatar: 'https://ui-avatars.com/api/?name=Priya+Verma&background=60a5fa&color=fff', status: 'Active', lastVisit: '2025-01-12', firstVisit: '2024-09-01', visitCount: 4 },
  '3': { id: '3', name: 'Arjun Mehta', age: 52, gender: 'Male', blood_group: 'O+', phone: '+91 77543 21098', email: 'arjun@email.com', allergies: ['NSAIDs', 'Aspirin'], chronic_conditions: ['Coronary Artery Disease', 'Type 2 Diabetes', 'Hyperlipidemia'], emergency_contact: '+91 66554 43210', family_history: 'Father: MI at 55, Mother: Diabetes', avatar: 'https://ui-avatars.com/api/?name=Arjun+Mehta&background=34d399&color=fff', status: 'Critical', lastVisit: '2025-02-01', firstVisit: '2023-03-15', visitCount: 22 },
};

const DEMO_VITALS: Record<string, VitalRecord[]> = {
  '1': [
    { date: 'Jan 15', bp: '142/92', hr: '82', sugar: '110', spo2: '98%', warnings: ['BP elevated'] },
    { date: 'Jan 10', bp: '135/88', hr: '78', sugar: '105', spo2: '99%', warnings: [] },
    { date: 'Dec 20', bp: '150/95', hr: '88', sugar: '120', spo2: '97%', warnings: ['BP high', 'Sugar borderline'] },
    { date: 'Dec 01', bp: '138/86', hr: '75', sugar: '98', spo2: '98%', warnings: [] },
  ],
  '2': [
    { date: 'Jan 12', bp: '110/70', hr: '72', sugar: '90', spo2: '99%', warnings: [] },
    { date: 'Nov 20', bp: '105/68', hr: '68', sugar: '85', spo2: '99%', warnings: [] },
  ],
  '3': [
    { date: 'Feb 01', bp: '165/100', hr: '92', sugar: '220', spo2: '94%', warnings: ['BP critical', 'Sugar very high', 'SpO2 low'] },
    { date: 'Jan 20', bp: '158/98', hr: '88', sugar: '195', spo2: '95%', warnings: ['BP high', 'Sugar high'] },
    { date: 'Jan 05', bp: '148/92', hr: '85', sugar: '180', spo2: '96%', warnings: ['BP elevated', 'Sugar high'] },
  ],
};

const DEMO_RECORDS: Record<string, MedicalRecord[]> = {
  '1': [
    { id: 'r1', date: '2025-01-15', type: 'prescription', title: 'Rx: Amlodipine adjustment', doctor: 'Dr. Smith', diagnosis: 'Hypertension Stage 1', details: 'Increased Amlodipine to 10mg OD' },
    { id: 'r2', date: '2025-01-10', type: 'lab_report', title: 'CBC + Lipid Panel', doctor: 'PathLab Central', diagnosis: 'WBC slightly elevated', details: 'Total Cholesterol: 210, LDL: 140, HDL: 45' },
    { id: 'r3', date: '2024-12-20', type: 'imaging', title: 'ECG + Echocardiogram', doctor: 'Dr. Lee (Cardio)', diagnosis: 'ECG normal, mild LVH on echo', details: 'LVEF 58%, mild concentric LVH' },
    { id: 'r4', date: '2024-12-01', type: 'notes', title: 'Initial Consultation', doctor: 'Dr. Smith', diagnosis: 'Suspected Hypertension', details: 'Patient presents with headaches and elevated BP readings at home' },
  ],
  '2': [
    { id: 'r5', date: '2025-01-12', type: 'prescription', title: 'Rx: Iron + Folic Acid', doctor: 'Dr. Smith', diagnosis: 'Iron Deficiency Anaemia', details: 'Ferrous Sulfate 200mg + Folic Acid 5mg daily' },
    { id: 'r6', date: '2024-11-20', type: 'lab_report', title: 'CBC + Iron Studies', doctor: 'PathLab', diagnosis: 'Hb 9.2 g/dL, Ferritin 8 μg/L', details: 'Microcytic hypochromic anaemia' },
  ],
  '3': [
    { id: 'r7', date: '2025-02-01', type: 'prescription', title: 'Rx: Insulin + Statin', doctor: 'Dr. Smith', diagnosis: 'Uncontrolled DM + CAD', details: 'Added Insulin Glargine 10U + Atorvastatin 40mg' },
    { id: 'r8', date: '2025-01-20', type: 'lab_report', title: 'HbA1c + Lipid Panel', doctor: 'PathLab Central', diagnosis: 'HbA1c 9.2%, LDL 165', details: 'Poor glycemic and lipid control' },
    { id: 'r9', date: '2025-01-05', type: 'imaging', title: 'Coronary Angiogram', doctor: 'Dr. Kapoor (Interventional)', diagnosis: '70% LAD stenosis', details: 'PCI with DES recommended' },
  ],
};

const DEMO_MEDS: Record<string, Medication[]> = {
  '1': [
    { name: 'Amlodipine', dosage: '10mg', frequency: 'OD', duration: 'Ongoing', active: true },
    { name: 'Atorvastatin', dosage: '20mg', frequency: 'HS', duration: 'Ongoing', active: true },
    { name: 'Aspirin', dosage: '75mg', frequency: 'OD', duration: '90 days', active: true },
  ],
  '2': [
    { name: 'Ferrous Sulfate', dosage: '200mg', frequency: 'BD', duration: '3 months', active: true },
    { name: 'Folic Acid', dosage: '5mg', frequency: 'OD', duration: '3 months', active: true },
    { name: 'Vitamin C', dosage: '500mg', frequency: 'OD', duration: '1 month', active: true },
  ],
  '3': [
    { name: 'Insulin Glargine', dosage: '10 units', frequency: 'HS', duration: 'Ongoing', active: true },
    { name: 'Metformin', dosage: '1000mg', frequency: 'BD', duration: 'Ongoing', active: true },
    { name: 'Atorvastatin', dosage: '40mg', frequency: 'HS', duration: 'Ongoing', active: true },
    { name: 'Clopidogrel', dosage: '75mg', frequency: 'OD', duration: 'Ongoing', active: true },
    { name: 'Pantoprazole', dosage: '40mg', frequency: 'OD', duration: '30 days', active: false },
  ],
};

const DEMO_FAMILY: Record<string, FamilyMember[]> = {
  '1': [
    { name: 'Sunita Sharma', relation: 'Wife', phone: '+91 99887 65321', isEmergency: true },
    { name: 'Ramesh Sharma', relation: 'Father', phone: '+91 88776 54321', isEmergency: false },
  ],
  '2': [
    { name: 'Kavita Verma', relation: 'Mother', phone: '+91 88776 54321', isEmergency: true },
  ],
  '3': [
    { name: 'Meera Mehta', relation: 'Wife', phone: '+91 66554 43210', isEmergency: true },
    { name: 'Dr. Sanjay Mehta', relation: 'Son', phone: '+91 55443 32109', isEmergency: true },
    { name: 'Kamla Mehta', relation: 'Mother', phone: '+91 44332 21098', isEmergency: false },
  ],
};

// ── SERVICE FUNCTIONS ──

export async function getPatientById(patientId: string): Promise<PatientData | null> {
  // Try Supabase first
  try {
    const { data } = await supabase.from('profiles').select('*').eq('id', patientId).maybeSingle();
    if (data) {
      return {
        id: data.id, name: data.full_name || data.name || 'Unknown',
        age: data.age || 0, gender: data.gender || 'Unknown', blood_group: data.blood_group || 'Unknown',
        phone: data.phone || '', email: data.email || '', allergies: data.allergies || [],
        chronic_conditions: data.chronic_conditions || [], emergency_contact: data.emergency_contacts?.[0] || '',
        family_history: '', avatar: `https://ui-avatars.com/api/?name=${encodeURIComponent(data.full_name || 'P')}&background=3b82f6&color=fff`,
        status: 'Active', lastVisit: new Date().toISOString().slice(0, 10), firstVisit: data.created_at?.slice(0, 10) || '', visitCount: 1,
      };
    }
  } catch (e) { /* fallback to demo */ }
  return DEMO_PATIENTS[patientId] || null;
}

export async function getPatientVitals(patientId: string): Promise<VitalRecord[]> {
  return DEMO_VITALS[patientId] || [];
}

export async function getPatientRecords(patientId: string): Promise<MedicalRecord[]> {
  return DEMO_RECORDS[patientId] || [];
}

export async function getPatientMedications(patientId: string): Promise<Medication[]> {
  return DEMO_MEDS[patientId] || [];
}

export async function getPatientFamily(patientId: string): Promise<FamilyMember[]> {
  return DEMO_FAMILY[patientId] || [];
}

export async function autoSavePatient(patientId: string, doctorId: string): Promise<void> {
  try {
    const { data: existing } = await supabase.from('doctor_patient_access')
      .select('id, visit_count').eq('doctor_id', doctorId).eq('patient_id', patientId).maybeSingle();

    if (existing) {
      await supabase.from('doctor_patient_access').update({
        last_visit: new Date().toISOString(), visit_count: (existing.visit_count || 0) + 1,
      }).eq('id', existing.id);
    } else {
      await supabase.from('doctor_patient_access').insert({
        doctor_id: doctorId, patient_id: patientId,
        first_visit: new Date().toISOString(), last_visit: new Date().toISOString(), visit_count: 1,
      });
    }
  } catch (e) { console.warn('Auto-save failed:', e); }
}

// ── AI SUMMARY ──

export async function generateAISummary(patient: PatientData, vitals: VitalRecord[], records: MedicalRecord[], meds: Medication[]): Promise<AISummary> {
  try {
    const prompt = `You are a clinical decision support AI for a doctor's practice.

PATIENT:
Name: ${patient.name}, Age: ${patient.age}, Gender: ${patient.gender}, Blood Group: ${patient.blood_group}
Allergies: ${patient.allergies.join(', ') || 'None'}
Chronic Conditions: ${patient.chronic_conditions.join(', ') || 'None'}
Family History: ${patient.family_history || 'Not available'}

RECENT VITALS:
${vitals.slice(0, 3).map(v => `${v.date}: BP ${v.bp}, HR ${v.hr}, Sugar ${v.sugar}, SpO2 ${v.spo2}`).join('\n')}

CURRENT MEDICATIONS:
${meds.filter(m => m.active).map(m => `${m.name} ${m.dosage} ${m.frequency}`).join('\n')}

RECENT RECORDS:
${records.slice(0, 3).map(r => `${r.date}: ${r.title} - ${r.diagnosis}`).join('\n')}

Generate a clinical summary. Respond ONLY with valid JSON (no markdown):
{
  "summary": "2-3 sentence clinical summary",
  "risk_level": "low" or "medium" or "high",
  "key_findings": ["finding 1", "finding 2", "finding 3"],
  "recommendations": ["action 1", "action 2"],
  "alerts": [{"text": "alert text", "severity": "info" or "warning" or "critical"}]
}`;

    const response = await fetch('https://integrate.api.nvidia.com/v1/chat/completions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${NIM_API_KEY}` },
      body: JSON.stringify({
        model: MODEL,
        messages: [{ role: 'system', content: 'You are a medical AI. Respond only with valid JSON.' }, { role: 'user', content: prompt }],
        temperature: 0.4, max_tokens: 1024,
      }),
      signal: AbortSignal.timeout(15000),
    });

    if (!response.ok) throw new Error(`API ${response.status}`);
    const data = await response.json();
    let content = data.choices?.[0]?.message?.content || '';
    content = content.trim();
    if (content.startsWith('```json')) content = content.slice(7);
    if (content.startsWith('```')) content = content.slice(3);
    if (content.endsWith('```')) content = content.slice(0, -3);
    const firstBrace = content.indexOf('{');
    const lastBrace = content.lastIndexOf('}');
    if (firstBrace !== -1 && lastBrace !== -1) content = content.substring(firstBrace, lastBrace + 1);

    return JSON.parse(content.trim());
  } catch (e) {
    console.warn('AI summary error:', e);
    // Intelligent fallback based on patient data
    const highBP = vitals.some(v => parseInt(v.bp) > 140);
    const highSugar = vitals.some(v => parseInt(v.sugar) > 150);
    const risk = patient.chronic_conditions.length >= 2 || highBP && highSugar ? 'high' : highBP || highSugar ? 'medium' : 'low';

    return {
      summary: `${patient.name} is a ${patient.age}-year-old ${patient.gender.toLowerCase()} with ${patient.chronic_conditions.join(', ') || 'no known chronic conditions'}. ${highBP ? 'Recent vitals show elevated blood pressure readings. ' : ''}${highSugar ? 'Blood sugar levels need monitoring. ' : ''}Review current medications and adjust as needed.`,
      risk_level: risk as 'low' | 'medium' | 'high',
      key_findings: [
        ...(highBP ? ['Elevated blood pressure detected in recent readings'] : []),
        ...(highSugar ? ['Blood sugar levels above target range'] : []),
        ...(patient.allergies.length > 0 ? [`Known allergies: ${patient.allergies.join(', ')}`] : []),
        `Currently on ${meds.filter(m => m.active).length} active medication(s)`,
      ],
      recommendations: [
        ...(highBP ? ['Consider adjusting antihypertensive medication'] : []),
        ...(highSugar ? ['Review diabetic management plan'] : []),
        'Schedule follow-up in 2 weeks',
      ],
      alerts: [
        ...(highBP ? [{ text: 'BP consistently above 140/90', severity: 'warning' as const }] : []),
        ...(highSugar ? [{ text: 'Blood sugar needs urgent attention', severity: 'critical' as const }] : []),
        ...(patient.allergies.length > 0 ? [{ text: `Allergies: ${patient.allergies.join(', ')}`, severity: 'info' as const }] : []),
      ],
    };
  }
}
