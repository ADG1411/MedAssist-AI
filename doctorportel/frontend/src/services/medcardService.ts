// ── Types ─────────────────────────────────────────────────────────────────

export interface QRPreview {
  patient_id: string;  // UUID or integer ID
  name: string;
  age: number;
  phone_masked: string;
  blood_group: string;
  is_real_patient: boolean; // true = from profiles table (UUID patient), false = from old patients table
}

export interface MedicalRecord {
  id: number | string;
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
  id: string | number;
  name: string;
  age: number;
  gender: string;
  phone: string;
  blood_group: string;
  allergies: string | string[] | null;
  email: string | null;
  address: string | null;
  created_at: string;
  // Extended fields from profiles table
  chronic_conditions?: string[];
  current_medications?: string[];
  height_cm?: number;
  weight_kg?: number;
  activity_level?: string;
  diet_type?: string;
}

export interface FullRecord {
  patient: PatientFull;
  records: MedicalRecord[];
  family_members: FamilyMember[];
  ai_summary: string[];
  access_logged: boolean;
  // Extended data from edge function
  symptom_sessions?: any[];
  ai_results?: any[];
  nutrition?: { recent_logs: any[]; daily_summaries: any[] };
  monitoring?: any[];
  vitals?: any[];
  medications?: { active_schedules: any[]; recent_logs: any[] };
  health_records?: any[];
  health_goals?: any[];
  summary?: Record<string, any>;
}

export interface AccessLog {
  id: number | string;
  doctor_id: string | number;
  doctor_name: string | null;
  patient_id: string | number;
  access_type: string;
  timestamp: string;
}

// AI Consult types
export interface AIConsultRequest {
  patient_id: string;
  messages: Array<{ role: string; content: string }>;
  consultation_type: 'general' | 'symptom_review' | 'nutrition_review' | 'medication_review';
}

export interface AIConsultResponse {
  reply: string;
  differential_diagnosis: Array<{ condition: string; probability: number; icd10?: string; reasoning?: string }>;
  recommended_tests: string[];
  medication_flags: Array<{ type: string; detail: string; severity: string }>;
  risk_assessment: string;
  follow_up_plan: string;
  clinical_notes: string;
  _model?: string;
}

import { supabase } from './supabaseClient';

// ── Mock database (Fallback — kept intact) ──────────────────────────────

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

// ── Token helpers ──────────────────────────────────────────────────────────

/** 
 * QR token formats supported:
 * 1. "MEDCARD::<patientId>::<expireTs>"           — old integer-based (mock patients)
 * 2. "MEDCARD::<uuid>::<expireTs>"                — new UUID-based (real Supabase patients)
 * 3. "MD-<uuid_prefix>"                           — Patient app Health ID card QR
 * 4. "medassist://emergency/MD-<uuid_prefix>"     — Patient app Emergency QR
 */

export interface ParsedToken {
  type: 'medcard_int' | 'medcard_uuid' | 'health_id' | 'emergency';
  patientId: string; // UUID or integer string
  isUUID: boolean;
  isExpired: boolean;
  isEmergency: boolean;
}

function isUUID(str: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(str);
}

export function parseToken(token: string): ParsedToken {
  const clean = token.trim();

  // Format 4: "medassist://emergency/MD-XXXXXXXX"
  if (clean.startsWith('medassist://emergency/')) {
    const healthId = clean.replace('medassist://emergency/', '');
    const prefix = healthId.replace('MD-', '').toLowerCase();
    return {
      type: 'emergency',
      patientId: prefix, // UUID prefix — will need lookup
      isUUID: false,
      isExpired: false,
      isEmergency: true,
    };
  }

  // Format 3: "MD-XXXXXXXX" (Health ID card)
  if (clean.startsWith('MD-') && !clean.includes('::')) {
    const prefix = clean.replace('MD-', '').toLowerCase();
    return {
      type: 'health_id',
      patientId: prefix, // UUID prefix — will need lookup
      isUUID: false,
      isExpired: false,
      isEmergency: false,
    };
  }

  // Format 1 & 2: "MEDCARD::<id>::<ts>"
  if (clean.startsWith('MEDCARD::')) {
    const parts = clean.split('::');
    if (parts.length < 2) throw new Error('Invalid QR token format.');
    
    const id = parts[1];
    const isUuid = isUUID(id);
    let expired = false;
    
    if (parts[2]) {
      const expireTs = parseInt(parts[2], 10);
      if (!isNaN(expireTs) && Date.now() > expireTs) {
        expired = true;
      }
    }

    return {
      type: isUuid ? 'medcard_uuid' : 'medcard_int',
      patientId: id,
      isUUID: isUuid,
      isExpired: expired,
      isEmergency: false,
    };
  }

  throw new Error('Unrecognized QR token format. Please scan a valid MedCard, Health ID, or Emergency QR.');
}

/** Generate demo token (old format — for testing) */
export function generateDemoToken(patientId: number): string {
  const expireTs = Date.now() + 30 * 60 * 1000;
  return `MEDCARD::${patientId}::${expireTs}`;
}

function maskPhone(phone: string): string {
  const digits = phone.replace(/\D/g, '');
  return `****${digits.slice(-4)}`;
}

// ── AI Summary (mock fallback) ──────────────────────────────────────────

function aiSummaryMock(patientId: number): string[] {
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

// ── Patient UUID Lookup by prefix ───────────────────────────────────────

async function findPatientByIdPrefix(prefix: string): Promise<string | null> {
  try {
    // Search profiles table for UUID starting with this prefix
    const { data, error } = await supabase
      .from('profiles')
      .select('id')
      .ilike('id', `${prefix}%`)
      .limit(1)
      .maybeSingle();
    
    if (data && !error) return data.id;
  } catch (err) {
    console.warn('UUID prefix lookup failed:', err);
  }
  return null;
}

// ── Public API ──────────────────────────────────────────────────────────────

export async function scanQR(token: string): Promise<QRPreview> {
  const parsed = parseToken(token);
  
  if (parsed.isExpired) {
    throw new Error('QR token has expired. Please generate a new one.');
  }

  // ── Real patient (UUID or prefix lookup) ──
  if (parsed.type === 'medcard_uuid' || parsed.type === 'health_id' || parsed.type === 'emergency') {
    let patientUUID = parsed.patientId;
    
    // For health_id and emergency, look up full UUID from prefix
    if (parsed.type === 'health_id' || parsed.type === 'emergency') {
      const fullId = await findPatientByIdPrefix(parsed.patientId);
      if (fullId) {
        patientUUID = fullId;
      } else {
        throw new Error('Patient not found. The QR code may be invalid or the patient profile does not exist.');
      }
    }

    try {
      const { data: p, error } = await supabase
        .from('profiles')
        .select('id, name, age, gender, phone, blood_group')
        .eq('id', patientUUID)
        .single();

      if (p && !error) {
        return {
          patient_id: p.id,
          name: p.name || 'Unknown Patient',
          age: p.age || 0,
          phone_masked: maskPhone(p.phone || '0000000000'),
          blood_group: p.blood_group || 'N/A',
          is_real_patient: true,
        };
      }
    } catch (err) {
      console.warn('Supabase profiles lookup failed:', err);
    }
    
    throw new Error('Patient profile not found in database.');
  }

  // ── Legacy integer patient (old system + mock) ──
  const patientId = parseInt(parsed.patientId, 10);
  if (isNaN(patientId)) throw new Error('Invalid patient ID in QR token.');

  // Try old patients table first
  try {
    const { data: p, error } = await supabase.from('patients').select('*').eq('id', patientId).single();
    if (p && !error) {
      return {
        patient_id: String(p.id),
        name: p.name,
        age: p.age,
        phone_masked: maskPhone(p.phone),
        blood_group: p.blood_group || '',
        is_real_patient: false,
      };
    }
  } catch (err) {
    console.warn('Supabase patients table fallback:', err);
  }

  // Mock fallback
  await new Promise(r => setTimeout(r, 600));
  const p = PATIENTS[patientId];
  if (!p) throw new Error(`No patient found for ID ${patientId}.`);
  return {
    patient_id: String(p.id),
    name: p.name,
    age: p.age,
    phone_masked: maskPhone(p.phone),
    blood_group: p.blood_group,
    is_real_patient: false,
  };
}

export async function accessFullRecord(token: string, emergency = false): Promise<FullRecord> {
  const parsed = parseToken(token);

  // ── Real patient: use edge function for full snapshot ──
  if (parsed.type === 'medcard_uuid' || parsed.type === 'health_id' || parsed.type === 'emergency') {
    let patientUUID = parsed.patientId;
    
    if (parsed.type === 'health_id' || parsed.type === 'emergency') {
      const fullId = await findPatientByIdPrefix(parsed.patientId);
      if (fullId) patientUUID = fullId;
      else throw new Error('Patient not found.');
    }

    try {
      // Call the doctor-patient-view edge function
      const { data: sessionData } = await supabase.auth.getSession();
      const accessToken = sessionData?.session?.access_token;

      if (accessToken) {
        const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
        const response = await fetch(`${supabaseUrl}/functions/v1/doctor-patient-view`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${accessToken}`,
          },
          body: JSON.stringify({
            patient_id: patientUUID,
            access_type: emergency ? 'emergency' : 'standard',
          }),
        });

        if (response.ok) {
          const data = await response.json();
          const profile = data.patient || {};
          
          return {
            patient: {
              id: profile.id || patientUUID,
              name: profile.name || 'Unknown',
              age: profile.age || 0,
              gender: profile.gender || 'N/A',
              phone: profile.phone || '',
              blood_group: profile.blood_group || 'N/A',
              allergies: profile.allergies || null,
              email: profile.email || null,
              address: null,
              created_at: profile.created_at || '',
              chronic_conditions: profile.chronic_conditions || [],
              current_medications: profile.current_medications || [],
              height_cm: profile.height_cm,
              weight_kg: profile.weight_kg,
              activity_level: profile.activity_level,
              diet_type: profile.diet_type,
            },
            records: [],
            family_members: [],
            ai_summary: generateAISummaryFromData(data),
            access_logged: true,
            symptom_sessions: data.symptom_sessions || [],
            ai_results: data.ai_results || [],
            nutrition: data.nutrition || { recent_logs: [], daily_summaries: [] },
            monitoring: data.monitoring || [],
            vitals: data.vitals || [],
            medications: data.medications || { active_schedules: [], recent_logs: [] },
            health_records: data.health_records || [],
            health_goals: data.health_goals || [],
            summary: data.summary || {},
          };
        }
      }
    } catch (err) {
      console.warn('Edge function call failed, trying direct query:', err);
    }

    // Direct Supabase query fallback (if edge function not deployed yet)
    try {
      const { data: profile } = await supabase.from('profiles').select('*').eq('id', patientUUID).single();
      if (profile) {
        return {
          patient: {
            id: profile.id,
            name: profile.name || 'Unknown',
            age: profile.age || 0,
            gender: profile.gender || 'N/A',
            phone: profile.phone || '',
            blood_group: profile.blood_group || 'N/A',
            allergies: profile.allergies || null,
            email: profile.email || null,
            address: null,
            created_at: profile.created_at || '',
            chronic_conditions: profile.chronic_conditions || [],
            current_medications: profile.current_medications || [],
          },
          records: [],
          family_members: [],
          ai_summary: ['Patient profile loaded from Supabase. Detailed health data available after scanning via edge function.'],
          access_logged: true,
        };
      }
    } catch (err) {
      console.warn('Direct profiles query failed:', err);
    }

    throw new Error('Could not access patient data.');
  }

  // ── Legacy integer patient ──
  const patientId = parseInt(parsed.patientId, 10);

  // Log access
  try {
    await supabase.from('access_logs').insert({
      doctor_id: 1,
      doctor_name: 'Dr. Smith',
      patient_id: patientId,
      access_type: emergency ? 'emergency' : 'standard'
    });
  } catch { /* silent */ }

  try {
    const { data: patient } = await supabase.from('patients').select('*').eq('id', patientId).single();
    const { data: records } = await supabase.from('medical_records').select('*').eq('patient_id', patientId);
    const { data: family_members } = await supabase.from('family_members').select('*').eq('patient_id', patientId);

    if (patient) {
      return {
        patient: { ...patient, id: String(patient.id) },
        records: records ?? [],
        family_members: family_members ?? [],
        ai_summary: aiSummaryMock(patientId),
        access_logged: true,
      };
    }
  } catch (err) {
    console.warn('Supabase record fetch fallback:', err);
  }

  // Mock fallback
  await new Promise(r => setTimeout(r, 800));
  const patient = PATIENTS[patientId];
  if (!patient) throw new Error('Patient not found.');

  ACCESS_LOGS.push({
    id: ACCESS_LOGS.length + 1,
    doctor_id: '1',
    doctor_name: 'Dr. Smith',
    patient_id: patientId,
    access_type: emergency ? 'emergency' : 'standard',
    timestamp: new Date().toISOString(),
  });

  return {
    patient: { ...patient, id: String(patient.id) },
    records: RECORDS[patientId] ?? [],
    family_members: FAMILY[patientId] ?? [],
    ai_summary: aiSummaryMock(patientId),
    access_logged: true,
  };
}

// ── AI Consult (calls doctor-ai-consult edge function) ──────────────────

export async function getPatientAIConsult(request: AIConsultRequest): Promise<AIConsultResponse> {
  try {
    const { data: sessionData } = await supabase.auth.getSession();
    const accessToken = sessionData?.session?.access_token;

    if (!accessToken) throw new Error('Not authenticated');

    const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
    const response = await fetch(`${supabaseUrl}/functions/v1/doctor-ai-consult`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`,
      },
      body: JSON.stringify(request),
    });

    if (!response.ok) {
      const errData = await response.json().catch(() => ({}));
      throw new Error(errData.error || `AI consult failed (${response.status})`);
    }

    return await response.json();
  } catch (err: any) {
    console.error('AI consult error:', err);
    return {
      reply: `AI consultation is temporarily unavailable: ${err.message}`,
      differential_diagnosis: [],
      recommended_tests: [],
      medication_flags: [],
      risk_assessment: 'unknown',
      follow_up_plan: '',
      clinical_notes: '',
    };
  }
}

// ── Helper: Generate AI summary from edge function data ─────────────────

function generateAISummaryFromData(data: any): string[] {
  const insights: string[] = [];
  const profile = data.patient || {};
  const summary = data.summary || {};

  if (profile.chronic_conditions?.length) {
    insights.push(`Active chronic conditions: ${profile.chronic_conditions.join(', ')}`);
  }
  if (profile.allergies?.length) {
    insights.push(`⚠ Known allergies: ${Array.isArray(profile.allergies) ? profile.allergies.join(', ') : profile.allergies}`);
  }
  if (summary.high_risk_results > 0) {
    insights.push(`🔴 ${summary.high_risk_results} high-risk AI triage episode(s) in recent history`);
  }
  if (summary.unsafe_foods_recent > 0) {
    insights.push(`🍽️ ${summary.unsafe_foods_recent} dietary flags in recent nutrition logs`);
  }
  if (summary.avg_hydration_cups < 5 && summary.avg_hydration_cups > 0) {
    insights.push(`💧 Low hydration detected: avg ${summary.avg_hydration_cups} cups/day (recommended: 8+)`);
  }
  if (summary.avg_sleep_hours < 6 && summary.avg_sleep_hours > 0) {
    insights.push(`😴 Poor sleep pattern: avg ${summary.avg_sleep_hours}h/night (recommended: 7-9h)`);
  }
  if (summary.active_medications > 0) {
    insights.push(`💊 ${summary.active_medications} active medication schedule(s)`);
  }
  if (data.ai_results?.length > 0) {
    const conditions = data.ai_results
      .filter((r: any) => r.conditions?.length > 0)
      .flatMap((r: any) => r.conditions.map((c: any) => c.name))
      .slice(0, 3);
    if (conditions.length > 0) {
      insights.push(`AI-detected conditions: ${conditions.join(', ')}`);
    }
  }
  if (insights.length === 0) {
    insights.push('Patient profile loaded. No significant alerts detected.');
  }
  return insights;
}

// ── Demo & Utility ──────────────────────────────────────────────────────

export function getDemoToken(patientId: number): Promise<{ token: string; patient_id: number }> {
  return Promise.resolve({ token: generateDemoToken(patientId), patient_id: patientId });
}

export async function getAccessLogs(): Promise<AccessLog[]> {
  try {
    // Try new doctor_access_logs first
    const { data: newLogs } = await supabase
      .from('doctor_access_logs')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(20);
    
    if (newLogs && newLogs.length > 0) {
      return newLogs.map((l: any) => ({
        id: l.id,
        doctor_id: l.doctor_id,
        doctor_name: null,
        patient_id: l.patient_id,
        access_type: l.action,
        timestamp: l.created_at,
      }));
    }

    // Fall back to old access_logs table
    const { data } = await supabase.from('access_logs').select('*').order('timestamp', { ascending: false }).limit(20);
    if (data && data.length > 0) return data;
  } catch { /* silent */ }

  await new Promise(r => setTimeout(r, 300));
  return [...ACCESS_LOGS].reverse();
}
