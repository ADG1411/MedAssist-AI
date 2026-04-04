import { supabase } from '../lib/supabase';
import type { Appointment } from '../types/appointment';

export interface BookingRow {
  id: string;
  patient_id: string;
  doctor_id: string;
  slot_time: string;
  amount: number;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  payment_status: 'pending' | 'paid' | 'refunded' | 'failed';
  razorpay_order_id: string | null;
  razorpay_payment_id: string | null;
  jitsi_room_id: string | null;
  meeting_url: string | null;
  doctor_name: string | null;
  doctor_specialty: string | null;
  created_at: string;
  updated_at: string | null;
}

/**
 * Fetches all confirmed/pending bookings for the current logged-in doctor.
 * These are bookings created by patients from the Patient Flutter app.
 */
export async function getBookingsForDoctor(doctorId: string): Promise<BookingRow[]> {
  const { data, error } = await supabase
    .from('bookings')
    .select('*')
    .eq('doctor_id', doctorId)
    .in('status', ['confirmed', 'pending'])
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Failed to fetch bookings:', error);
    return [];
  }
  return (data ?? []) as BookingRow[];
}

/**
 * Fetches a single booking by ID (for the consultation room).
 */
export async function getBookingById(bookingId: string): Promise<BookingRow | null> {
  const { data, error } = await supabase
    .from('bookings')
    .select('*')
    .eq('id', bookingId)
    .single();

  if (error) {
    console.error('Failed to fetch booking:', error);
    return null;
  }
  return data as BookingRow;
}

/**
 * Updates a booking status (e.g. when doctor completes the call).
 */
export async function updateBookingStatus(bookingId: string, status: 'confirmed' | 'completed' | 'cancelled'): Promise<boolean> {
  const { error } = await supabase
    .from('bookings')
    .update({ status, updated_at: new Date().toISOString() })
    .eq('id', bookingId);

  if (error) {
    console.error('Failed to update booking:', error);
    return false;
  }
  return true;
}

/**
 * Fetches the patient profile for a given patient_id from profiles table.
 */
export async function getPatientProfile(patientId: string) {
  try {
    // Try with common column names from the Patient Flutter app
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', patientId)
      .maybeSingle();

    if (error || !data) return null;

    // Normalize — the Patient app may use 'name' or 'full_name'
    return {
      full_name: data.full_name || data.name || `Patient ${patientId.substring(0, 8)}`,
      age: data.age ?? null,
      gender: data.gender ?? null,
      blood_group: data.blood_group ?? null,
      allergies: data.allergies ?? null,
      chronic_conditions: data.chronic_conditions ?? null,
      emergency_contacts: data.emergency_contacts ?? null,
    };
  } catch {
    return null;
  }
}

/**
 * Converts a Supabase booking row into the Appointment interface
 * used by the existing Doctor Portal UI components.
 */
export function bookingToAppointment(booking: BookingRow, patientProfile: any): Appointment {
  const patientName = patientProfile?.full_name ?? `Patient ${booking.patient_id.substring(0, 6)}`;
  const patientAge = patientProfile?.age ?? 0;
  
  return {
    id: booking.id,
    patientId: booking.patient_id,
    patientName,
    patientAge,
    timeSlot: booking.slot_time,
    type: 'online', // All bookings from the Patient app are telemedicine
    status: booking.status === 'confirmed' ? 'Waiting' : booking.status === 'completed' ? 'Completed' : 'Pending',
    priority: 'Normal',
    symptoms: patientProfile?.chronic_conditions?.join(', ') || 'Consultation booked via MedAssist',
    avatar: `https://ui-avatars.com/api/?name=${encodeURIComponent(patientName)}&background=3b82f6&color=fff`,
    // Custom fields for the booking reference
    roomNumber: booking.jitsi_room_id ?? undefined,
  };
}
