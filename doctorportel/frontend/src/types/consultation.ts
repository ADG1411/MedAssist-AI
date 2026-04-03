export interface PatientBasicInfo {
  id: string;
  name: string;
  age: number;
  gender: string;
  blood_group: string;
  allergies: string[];
  emergency_contact: string;
  family_history: string;
}

export interface TimelineEvent {
  date: string;
  type: 'visit' | 'specialist' | 'lab';
  title: string;
  doctor: string;
  diagnosis: string;
}

export interface PrescriptionShort {
  name: string;
  dosage: string;
  duration: string;
}

export interface VitalSign {
  date: string;
  bp: string;
  sugar?: string;
  hr: string;
  warnings?: string[];
}

export interface MedicalReportShort {
  id: string;
  name: string;
  date: string;
  type: string;
}

export interface AISummary {
  summary: string;
  priority: 'low' | 'medium' | 'high' | 'critical';
  key_points: string[];
  recommended_action: string;
}

export interface AIAnalysisResult {
  summary: string;
  risk_level: 'low' | 'medium' | 'high';
  suggestions: string[];
  alerts: string[];
}

export interface FullConsultationSummary {
  patient: PatientBasicInfo;
  timeline: TimelineEvent[];
  prescriptions: PrescriptionShort[];
  vitals: VitalSign[];
  reports: MedicalReportShort[];
  ai_summary: AISummary;
  risk_level: 'low' | 'medium' | 'high';
}
