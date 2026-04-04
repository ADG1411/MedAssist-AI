export type ReferralType = 'specialist' | 'hospital' | 'lab' | 'emergency';
export type BookingType = 'lab' | 'hospital' | 'specialist';
export type BookingStatus = 'pending' | 'confirmed' | 'completed' | 'cancelled';
export type TicketStatus = 'active' | 'used' | 'expired';

export interface Referral {
  id: string;
  patient_id: string;
  patient_name: string;
  patient_age: number;
  patient_gender: string;
  patient_blood_group: string;
  doctor_id: string;
  doctor_name: string;
  doctor_specialization: string;
  diagnosis: string;
  notes: string;
  medicines: string[];
  tests: string[];
  reason: string;
  type: ReferralType;
  created_at: string;
  expires_at: string;
}

export interface ReferralQRToken {
  id: string;
  referral_id: string;
  token: string;
  expires_at: string;
}

export interface AIInsight {
  summary: string;
  priority: 'low' | 'medium' | 'high' | 'critical';
  key_points: string[];
  recommended_action: string;
}

export interface Provider {
  id: string;
  name: string;
  type: BookingType;
  address: string;
  rating: number;
  distance_km: number;
  available_slots: string[];
}

export interface Booking {
  id: string;
  referral_id: string;
  type: BookingType;
  provider_id: string;
  provider_name: string;
  provider_address: string;
  patient_name: string;
  date: string;
  time_slot: string;
  status: BookingStatus;
  amount: number;
  created_at: string;
}

export interface Ticket {
  id: string;
  booking_id: string;
  patient_name: string;
  booking_type: BookingType;
  provider_name: string;
  provider_address: string;
  date: string;
  time_slot: string;
  qr_token: string;
  status: TicketStatus;
  created_at: string;
}

export interface Earning {
  id: string;
  booking_id: string;
  patient_name: string;
  provider_name: string;
  booking_type: BookingType;
  total_amount: number;
  commission_rate: number;
  commission_amount: number;
  status: 'pending' | 'paid';
  created_at: string;
}

export interface EarningsSummary {
  total_bookings: number;
  total_revenue: number;
  total_commission: number;
  pending_commission: number;
  paid_commission: number;
  recent: Earning[];
}

export interface CreateReferralPayload {
  patient_id: string;
  patient_name: string;
  patient_age: number;
  patient_gender: string;
  patient_blood_group: string;
  diagnosis: string;
  notes: string;
  medicines: string[];
  tests: string[];
  reason: string;
  type: ReferralType;
}

export interface CreateBookingPayload {
  referral_id: string;
  type: BookingType;
  provider_id: string;
  date: string;
  time_slot: string;
}
