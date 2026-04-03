export type MeetingType = 'online' | 'offline';
export type AppointmentStatus = 'Waiting' | 'In Progress' | 'Completed' | 'Pending';
export type PriorityLevel = 'Normal' | 'High' | 'Emergency';

export interface Appointment {
  id: string;
  patientId: string;
  patientName: string;
  patientAge: number;
  timeSlot: string;
  type: MeetingType;
  status: AppointmentStatus;
  priority: PriorityLevel;
  symptoms: string;
  avatar: string;
  isNext?: boolean;
  delayMins?: number;
  roomNumber?: string;
}
