import type { Appointment } from '../types/appointment';

export const mockAppointmentsToday: Appointment[] = [
  {
    id: 'APT-101',
    patientId: 'P-1002',
    patientName: 'Michael Johnson',
    patientAge: 58,
    timeSlot: '09:00 AM - 09:30 AM',
    type: 'offline',
    status: 'Waiting',
    priority: 'Emergency',
    symptoms: 'Severe Chest Pain, Sweating',
    avatar: 'https://ui-avatars.com/api/?name=Michael+Johnson&background=ef4444&color=fff',
    roomNumber: 'ER-1',
    isNext: true
  },
  {
    id: 'APT-102',
    patientId: 'P-1001',
    patientName: 'Emma Watson',
    patientAge: 34,
    timeSlot: '10:00 AM - 10:20 AM',
    type: 'online',
    status: 'Pending',
    priority: 'Normal',
    symptoms: 'Regular Follow-up, Diabetes check',
    avatar: 'https://ui-avatars.com/api/?name=Emma+Watson&background=f87171&color=fff',
  },
  {
    id: 'APT-103',
    patientId: 'P-1055',
    patientName: 'James Wilson',
    patientAge: 45,
    timeSlot: '10:30 AM - 10:45 AM',
    type: 'offline',
    status: 'Waiting',
    priority: 'Normal',
    symptoms: 'Mild fever, Cough for 3 days',
    avatar: 'https://ui-avatars.com/api/?name=James+Wilson&background=60a5fa&color=fff',
    delayMins: 10,
    roomNumber: 'OPD-3'
  },
  {
    id: 'APT-104',
    patientId: 'P-1060',
    patientName: 'Sarah Smith',
    patientAge: 42,
    timeSlot: '11:00 AM - 11:30 AM',
    type: 'online',
    status: 'Completed',
    priority: 'Normal',
    symptoms: 'Anemia report review',
    avatar: 'https://ui-avatars.com/api/?name=Sarah+Smith&background=34d399&color=fff',
  }
];