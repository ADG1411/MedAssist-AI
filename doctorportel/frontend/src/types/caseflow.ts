export type CaseStatus = 'In Review' | 'In Consultation' | 'Completed' | 'Pending';
export type VisitType = 'online' | 'offline';
export type PurposeType = 'checkup' | 'surgery' | 'emergency';
export type PaymentStatus = 'pending' | 'paid' | 'insurance';

export interface PatientData {
  id: string;
  reqId: string;
  name: string;
  age: number;
  gender: string;
  bloodGroup: string;
  procedure: string;
  urgency: string;
  source: string;
  costMin: number;
  costMax: number;
  aiScore: number;
  avatarColor: string;
  idNumber: string;
  birthDate: string;
  status: CaseStatus;
  phone: string;
  email: string;
  medicalHistory: string[];
  allergies: string[];
  diagnosis: string;
}

export interface VisitData {
  appointmentTime: string;
  visitType: VisitType;
  purpose: PurposeType;
  paymentStatus: PaymentStatus;
  notes: string;
}

export interface MedicineItem {
  id: string;
  name: string;
  dosage: string;
  duration: string;
  frequency: string;
}

export interface PrescriptionData {
  medicines: MedicineItem[];
  tests: string[];
  instructions: string;
  diagnosis: string;
  followUpDate: string;
}

export interface ChatMessage {
  id: string;
  role: 'doctor' | 'ai';
  content: string;
  timestamp: string;
  type?: 'text' | 'card';
  cardData?: Record<string, string>;
}

export interface CaseFlowState {
  patient: PatientData;
  visit: VisitData;
  prescription: PrescriptionData;
  chatMessages: ChatMessage[];
  currentStatus: CaseStatus;
}

export const MOCK_CASES: CaseFlowState[] = [
  {
    patient: {
      id: 'P-001', reqId: 'REQ-2024-002', name: 'Priya Verma',
      age: 34, gender: 'Female', bloodGroup: 'A+',
      procedure: 'Laparoscopic Cholecystectomy', urgency: 'Urgent',
      source: 'Medical', costMin: 60000, costMax: 85000, aiScore: 88,
      avatarColor: '#14b8a6', idNumber: 'SANI-8834', birthDate: '22 Jun 1990',
      status: 'In Review', phone: '+91 98765 43210', email: 'priya.verma@email.com',
      medicalHistory: ['Hypertension (2020)', 'Appendectomy (2018)', 'Type 2 Diabetes (2022)'],
      allergies: ['Penicillin', 'Aspirin'],
      diagnosis: 'Acute cholecystitis with cholelithiasis',
    },
    visit: { appointmentTime: '10:30 AM', visitType: 'offline', purpose: 'surgery', paymentStatus: 'insurance', notes: '' },
    prescription: { medicines: [], tests: [], instructions: '', diagnosis: '', followUpDate: '' },
    chatMessages: [],
    currentStatus: 'In Review',
  },
  {
    patient: {
      id: 'P-002', reqId: 'REQ-2024-005', name: 'Arjun Mehta',
      age: 52, gender: 'Male', bloodGroup: 'O+',
      procedure: 'Coronary Angioplasty', urgency: 'Emergency',
      source: 'Referral', costMin: 120000, costMax: 180000, aiScore: 94,
      avatarColor: '#6366f1', idNumber: 'SANI-1192', birthDate: '14 Mar 1972',
      status: 'In Consultation', phone: '+91 87654 32109', email: 'arjun.mehta@email.com',
      medicalHistory: ['Coronary Artery Disease (2021)', 'Hypertension (2018)', 'Hyperlipidemia (2019)'],
      allergies: ['Heparin'],
      diagnosis: 'Unstable angina — STEMI high risk',
    },
    visit: { appointmentTime: '09:00 AM', visitType: 'offline', purpose: 'emergency', paymentStatus: 'pending', notes: '' },
    prescription: { medicines: [], tests: [], instructions: '', diagnosis: '', followUpDate: '' },
    chatMessages: [],
    currentStatus: 'In Consultation',
  },
  {
    patient: {
      id: 'P-003', reqId: 'REQ-2024-009', name: 'Sneha Rao',
      age: 28, gender: 'Female', bloodGroup: 'B+',
      procedure: 'General Consultation', urgency: 'Routine',
      source: 'Walk-in', costMin: 500, costMax: 1500, aiScore: 22,
      avatarColor: '#f59e0b', idNumber: 'SANI-3374', birthDate: '05 Sep 1996',
      status: 'Pending', phone: '+91 76543 21098', email: 'sneha.rao@email.com',
      medicalHistory: ['No significant history'],
      allergies: [],
      diagnosis: 'Routine annual checkup',
    },
    visit: { appointmentTime: '02:15 PM', visitType: 'online', purpose: 'checkup', paymentStatus: 'paid', notes: '' },
    prescription: { medicines: [], tests: [], instructions: '', diagnosis: '', followUpDate: '' },
    chatMessages: [],
    currentStatus: 'Pending',
  },
  {
    patient: {
      id: 'P-004', reqId: 'REQ-2024-011', name: 'Rakesh Kumar',
      age: 45, gender: 'Male', bloodGroup: 'AB-',
      procedure: 'Total Knee Replacement', urgency: 'Elective',
      source: 'Medical', costMin: 200000, costMax: 280000, aiScore: 61,
      avatarColor: '#ec4899', idNumber: 'SANI-5521', birthDate: '19 Jan 1979',
      status: 'In Review', phone: '+91 65432 10987', email: 'rakesh.kumar@email.com',
      medicalHistory: ['Osteoarthritis (2019)', 'Type 2 Diabetes (2020)', 'Obesity (BMI 31)'],
      allergies: ['Sulfa drugs', 'Latex'],
      diagnosis: 'Severe bilateral osteoarthritis',
    },
    visit: { appointmentTime: '11:45 AM', visitType: 'offline', purpose: 'surgery', paymentStatus: 'insurance', notes: '' },
    prescription: { medicines: [], tests: [], instructions: '', diagnosis: '', followUpDate: '' },
    chatMessages: [],
    currentStatus: 'In Review',
  },
];
