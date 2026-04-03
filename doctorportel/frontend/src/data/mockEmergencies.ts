import type { Emergency } from '../types/emergency';

export const mockEmergencies: Emergency[] = [
  {
    id: 'SOS-001',
    patientName: 'Unknown Male',
    age: 45,
    gender: 'M',
    type: 'Accident',
    severity: 'Critical',
    aiScore: 98,
    location: 'Highway 61, Mile 4',
    distance: '2.4 km',
    timeSinceAlert: '00:45',
    status: 'pending',
    vitals: { heartRate: 140, oxygen: 89, bloodPressure: '80/50' }
  },
  {
    id: 'SOS-002',
    patientName: 'Emma Watson',
    age: 32,
    gender: 'F',
    type: 'Breathing',
    severity: 'High',
    aiScore: 85,
    location: 'Downtown Mall, Block B',
    distance: '5.1 km',
    timeSinceAlert: '01:20',
    status: 'pending',
    vitals: { heartRate: 110, oxygen: 85, bloodPressure: '130/80' }
  },
  {
    id: 'SOS-003',
    patientName: 'James Carter',
    age: 62,
    gender: 'M',
    type: 'Cardiac',
    severity: 'Critical',
    aiScore: 99,
    location: 'Westside Residential',
    distance: '1.2 km',
    timeSinceAlert: '00:15',
    status: 'pending',
    vitals: { heartRate: 185, oxygen: 92, bloodPressure: '190/110' }
  }
];