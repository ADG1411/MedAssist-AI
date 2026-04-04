export interface Appointment {
  id: string;
  patientId: string;
  patientName: string;
  patientAge: number;
  timeSlot: string;
  type: 'online' | 'offline' | 'emergency';
  status: 'Waiting' | 'In Progress' | 'Completed' | 'Pending' | 'Scheduled';
  priority: 'Normal' | 'High' | 'Critical';
  symptoms: string;
  avatar: string;
  roomNumber?: string;
}
