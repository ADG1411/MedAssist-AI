export interface Vitals {
  heartRate: number;
  oxygen: number;
  bloodPressure: string;
}

export interface Emergency {
  id: string;
  patientName: string;
  age?: number;
  gender?: string;
  type: 'Cardiac' | 'Accident' | 'Breathing' | 'Severe Bleeding' | 'Unknown';
  severity: 'Critical' | 'High' | 'Moderate';
  aiScore: number;
  location: string;
  distance: string;
  timeSinceAlert: string;
  vitals?: Vitals;
  status: 'pending' | 'accepted' | 'resolved';
}