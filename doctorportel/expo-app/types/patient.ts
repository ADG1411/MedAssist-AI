export interface Patient {
  id: string;
  name: string;
  age: number;
  gender: 'Male' | 'Female' | 'Other';
  status: 'Active' | 'Critical' | 'Recovered';
  lastDiagnosis: string;
  lastVisit: string;
  totalFees: number;
  pendingAmount: number;
  isFavorite: boolean;
  riskScore: number;
  tags: string[];
  nextFollowUp?: string;
  avatar: string;
  phone: string;
  email: string;
  blood_group?: string;
  allergies?: string[];
  chronic_conditions?: string[];
}
