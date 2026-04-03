// ── Types ─────────────────────────────────────────────────────────────────

export interface QRPreview {
  patient_id: number;
  name: string;
  age: number;
  phone_masked: string;
  blood_group: string;
}

export interface MedicalRecord {
  id: number;
  diagnosis: string;
  prescription: string | null;
  report_url: string | null;
  doctor_name: string | null;
  notes: string | null;
  created_at: string;
}

export interface FamilyMember {
  id: number;
  name: string;
  relation: string;
  phone: string;
  is_primary: boolean;
}

export interface PatientFull {
  id: number;
  name: string;
  age: number;
  gender: string;
  phone: string;
  blood_group: string;
  allergies: string | null;
  email: string | null;
  address: string | null;
  created_at: string;
}

export interface FullRecord {
  patient: PatientFull;
  records: MedicalRecord[];
  family_members: FamilyMember[];
  ai_summary: string[];
  access_logged: boolean;
}

export interface AccessLog {
  id: number;
  doctor_id: number;
  doctor_name: string | null;
  patient_id: number;
  access_type: string;
  timestamp: string;
}

// ── Mock database (no backend needed) ──────────────────────────────────────

const PATIENTS: Record<number, PatientFull> = {
  1: { id: 1, name: 'Rahul Sharma',  age: 34, gender: 'Male',   phone: '+91 98765 43210', blood_group: 'B+', allergies: 'Penicillin, Aspirin', email: 'rahul.sharma@email.com', address: '12 MG Road, Bengaluru, Karnataka', created_at: '2022-03-15T00:00:00Z' },
  2: { id: 2, name: 'Priya Verma',   age: 28, gender: 'Female', phone: '+91 87654 32109', blood_group: 'A+', allergies: 'Sulfa drugs',          email: 'priya.verma@email.com',  address: '45 Park Street, Mumbai, Maharashtra', created_at: '2023-01-10T00:00:00Z' },
  3: { id: 3, name: 'Arjun Mehta',   age: 52, gender: 'Male',   phone: '+91 77543 21098', blood_group: 'O+', allergies: 'Heparin',              email: 'arjun.mehta@email.com',  address: '8 Civil Lines, Delhi', created_at: '2021-08-20T00:00:00Z' },
};

const RECORDS: Record<number, MedicalRecord[]> = {
  1: [
    { id: 101, diagnosis: 'Acute Gastritis',       prescription: 'Pantoprazole 40mg OD · Domperidone 10mg TID',        report_url: null, doctor_name: 'Dr. Smith', notes: 'Avoid spicy food, eat small meals', created_at: '2024-11-05T09:00:00Z' },
    { id: 102, diagnosis: 'Hypertension Stage 1',  prescription: 'Amlodipine 5mg OD',                                  report_url: null, doctor_name: 'Dr. Patel', notes: 'Monitor BP daily, low-salt diet', created_at: '2024-08-15T10:30:00Z' },
    { id: 103, diagnosis: 'GERD',                  prescription: 'Omeprazole 20mg BD · Antacid SOS',                   report_url: null, doctor_name: 'Dr. Smith', notes: 'Lifestyle modification advised', created_at: '2024-03-22T11:00:00Z' },
  ],
  2: [
    { id: 201, diagnosis: 'Viral Upper Respiratory Infection', prescription: 'Paracetamol 500mg TID · Cetirizine 10mg OD', report_url: null, doctor_name: 'Dr. Rao',   notes: 'Rest and hydration advised', created_at: '2025-01-12T08:00:00Z' },
    { id: 202, diagnosis: 'Iron Deficiency Anaemia',           prescription: 'Ferrous Sulfate 200mg BD',                  report_url: null, doctor_name: 'Dr. Smith', notes: 'Repeat CBC after 4 weeks', created_at: '2024-09-08T09:30:00Z' },
  ],
  3: [
    { id: 301, diagnosis: 'Coronary Artery Disease',  prescription: 'Aspirin 75mg OD · Atorvastatin 40mg OD',         report_url: null, doctor_name: 'Dr. Kapoor', notes: 'Cardiac review in 3 months', created_at: '2025-02-01T08:00:00Z' },
    { id: 302, diagnosis: 'Hypertension Stage 2',     prescription: 'Amlodipine 10mg OD · Losartan 50mg OD',          report_url: null, doctor_name: 'Dr. Smith',  notes: 'Salt restriction <2g/day',  created_at: '2024-10-14T10:00:00Z' },
    { id: 303, diagnosis: 'Type 2 Diabetes Mellitus', prescription: 'Metformin 500mg BD · Glimepiride 1mg OD',         report_url: null, doctor_name: 'Dr. Patel',  notes: 'HbA1c target <7%',          created_at: '2024-06-30T09:00:00Z' },
  ],
};

const FAMILY: Record<number, FamilyMember[]> = {
  1: [
    { id: 11, name: 'Sunita Sharma', relation: 'Wife',   phone: '+91 90123 45678', is_primary: true  },
    { id: 12, name: 'Ravi Sharma',   relation: 'Father', phone: '+91 81234 56789', is_primary: false },
  ],
  2: [{ id: 21, name: 'Vikram Verma',  relation: 'Husband', phone: '+91 70987 65432', is_primary: true }],
  3: [
    { id: 31, name: 'Kavita Mehta', relation: 'Wife', phone: '+91 87654 32109', is_primary: true  },
    { id: 32, name: 'Rohan Mehta',  relation: 'Son',  phone: '+91 76543 21098', is_primary: false },
  ],
};

const ACCESS_LOGS: AccessLog[] = [];

// ── Token helpers (no encryption needed on frontend) ───────────────────────

/** QR token format: "MEDCARD::<patientId>::<expireTs>" */
export function generateDemoToken(patientId: number): string {
  const expireTs = Date.now() + 30 * 60 * 1000; // 30 min
  return `MEDCARD::${patientId}::${expireTs}`;
}

function parseToken(token: string): number {
  // Support "MEDCARD::<id>::<ts>" and legacy "MEDCARD::<id>"
  const clean = token.trim();
  const parts  = clean.split('::');
  if (parts[0] !== 'MEDCARD' || parts.length < 2) {
    throw new Error('Invalid QR token format. Use a valid MedCard token.');
  }
  const patientId = parseInt(parts[1], 10);
  if (isNaN(patientId)) throw new Error('Corrupted QR token.');
  if (parts[2]) {
    const expireTs = parseInt(parts[2], 10);
    if (Date.now() > expireTs) throw new Error('QR token has expired. Please generate a new one.');
  }
  return patientId;
}

function maskPhone(phone: string): string {
  const digits = phone.replace(/\D/g, '');
  return `****${digits.slice(-4)}`;
}

function aiSummary(patientId: number): string[] {
  const recs = RECORDS[patientId] ?? [];
  const diags = recs.map(r => r.diagnosis.toLowerCase());
  const insights: string[] = [];

  const gastric = diags.filter(d => /gastrit|gerd|gastro|stomach/.test(d)).length;
  if (gastric >= 2) insights.push(`Frequent stomach/GI issues detected across ${gastric} visits — consider GI specialist referral.`);

  const bp = diags.filter(d => /hypertens|bp/.test(d)).length;
  if (bp >= 2) insights.push('BP is a recurring concern — escalating medication doses noted. Daily monitoring advised.');

  if (diags.some(d => /coronary|cardiac/.test(d))) insights.push('Cardiac condition on record — high priority monitoring required.');
  if (diags.some(d => /diabetes/.test(d)))          insights.push('Diabetic patient — monitor HbA1c, blood sugar, kidney function regularly.');

  const patient = PATIENTS[patientId];
  if (patient?.allergies) insights.push(`⚠ Known allergies: ${patient.allergies} — verify before prescribing any medication.`);
  if (insights.length === 0) insights.push('No significant recurring conditions detected in recent visit history.');
  return insights;
}

// ── Public API (mirrors backend endpoints, 100% local) ────────────────────

export async function scanQR(token: string): Promise<QRPreview> {
  await new Promise(r => setTimeout(r, 600)); // simulate network
  const patientId = parseToken(token);
  const p = PATIENTS[patientId];
  if (!p) throw new Error(`No patient found for ID ${patientId}.`);
  return { patient_id: p.id, name: p.name, age: p.age, phone_masked: maskPhone(p.phone), blood_group: p.blood_group };
}

export async function accessFullRecord(token: string, emergency = false): Promise<FullRecord> {
  await new Promise(r => setTimeout(r, 800));
  const patientId = parseToken(token);
  const patient = PATIENTS[patientId];
  if (!patient) throw new Error(`Patient not found.`);

  ACCESS_LOGS.push({
    id: ACCESS_LOGS.length + 1,
    doctor_id: 1,
    doctor_name: 'Dr. Smith',
    patient_id: patientId,
    access_type: emergency ? 'emergency' : 'standard',
    timestamp: new Date().toISOString(),
  });

  return {
    patient,
    records: RECORDS[patientId] ?? [],
    family_members: FAMILY[patientId] ?? [],
    ai_summary: aiSummary(patientId),
    access_logged: true,
  };
}

export function getDemoToken(patientId: number): Promise<{ token: string; patient_id: number }> {
  return Promise.resolve({ token: generateDemoToken(patientId), patient_id: patientId });
}

export async function getAccessLogs(): Promise<AccessLog[]> {
  await new Promise(r => setTimeout(r, 300));
  return [...ACCESS_LOGS].reverse();
}
