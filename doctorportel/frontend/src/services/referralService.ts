import type {
  Referral, ReferralQRToken, AIInsight, Provider,
  Booking, Ticket, Earning, EarningsSummary,
  CreateReferralPayload, CreateBookingPayload,
} from '../types/referral';
import { supabase } from '../lib/supabase';

const BASE = '/api/v1';

// ── Mock Data ─────────────────────────────────────────────────────────────────

const MOCK_PROVIDERS: Provider[] = [
  { id: 'p1', name: 'City Diagnostics Lab', type: 'lab', address: '12 MG Road, Sector 4', rating: 4.7, distance_km: 1.2, available_slots: ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'] },
  { id: 'p2', name: 'MediLab Plus', type: 'lab', address: '45 Green Park, Block B', rating: 4.5, distance_km: 2.8, available_slots: ['08:00 AM', '10:00 AM', '03:00 PM'] },
  { id: 'p3', name: 'Apollo Diagnostics', type: 'lab', address: '78 Nehru Nagar', rating: 4.9, distance_km: 4.1, available_slots: ['09:30 AM', '12:00 PM', '05:00 PM'] },
  { id: 'h1', name: 'City General Hospital', type: 'hospital', address: '1 Hospital Road, Civil Lines', rating: 4.6, distance_km: 3.0, available_slots: ['10:00 AM', '02:00 PM', '04:30 PM'] },
  { id: 'h2', name: 'LifeCare Medical Centre', type: 'hospital', address: '23 Park Avenue', rating: 4.4, distance_km: 5.5, available_slots: ['09:00 AM', '01:00 PM'] },
  { id: 's1', name: 'Dr. Sharma - Cardiologist', type: 'specialist', address: 'Sector 6, Medical Hub', rating: 4.8, distance_km: 2.0, available_slots: ['11:00 AM', '03:00 PM', '05:30 PM'] },
  { id: 's2', name: 'Dr. Mehta - Neurologist', type: 'specialist', address: '88 Lake View Complex', rating: 4.7, distance_km: 6.2, available_slots: ['10:30 AM', '02:30 PM'] },
];

const MOCK_REFERRALS: Referral[] = [
  {
    id: 'ref-001',
    patient_id: 'pat-1',
    patient_name: 'Rahul Sharma',
    patient_age: 34,
    patient_gender: 'Male',
    patient_blood_group: 'B+',
    doctor_id: 'doc-1',
    doctor_name: 'Dr. Anil Kumar',
    doctor_specialization: 'General Physician',
    diagnosis: 'Suspected Typhoid Fever with secondary dehydration',
    notes: 'Patient shows persistent fever >101°F for 5 days. Widal test positive. Recommend IV fluids and CBC panel.',
    medicines: ['Ciprofloxacin 500mg', 'Paracetamol 650mg', 'ORS Sachets'],
    tests: ['Complete Blood Count (CBC)', 'Widal Test', 'Blood Culture', 'Liver Function Test'],
    reason: 'Fever not subsiding after 5 days — requires urgent lab investigation',
    type: 'lab',
    created_at: new Date().toISOString(),
    expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
  },
];

let MOCK_BOOKINGS: Booking[] = [];
let MOCK_TICKETS: Ticket[] = [];
let MOCK_EARNINGS: Earning[] = [];

// ── Token Utilities ───────────────────────────────────────────────────────────

export function generateReferralToken(referralId: string): string {
  const ts = Date.now() + 24 * 60 * 60 * 1000; // 24h expiry
  return `REFQR::${referralId}::${ts}`;
}

export function generateBookingToken(bookingId: string): string {
  const ts = Date.now() + 7 * 24 * 60 * 60 * 1000; // 7 days
  return `TICKET::${bookingId}::${ts}`;
}

function parseReferralToken(token: string): string {
  const parts = token.trim().split('::');
  if (parts[0] !== 'REFQR' || parts.length < 2) throw new Error('Invalid referral QR token.');
  if (parts[2] && Date.now() > parseInt(parts[2])) throw new Error('Referral QR has expired.');
  return parts[1];
}

function parseBookingToken(token: string): string {
  const parts = token.trim().split('::');
  if (parts[0] !== 'TICKET' || parts.length < 2) throw new Error('Invalid ticket token.');
  if (parts[2] && Date.now() > parseInt(parts[2])) throw new Error('Ticket has expired.');
  return parts[1];
}

function delay(ms = 600) { return new Promise(r => setTimeout(r, ms)); }

// ── AI Summary ────────────────────────────────────────────────────────────────

function buildAIInsight(referral: Referral): AIInsight {
  const diag = referral.diagnosis.toLowerCase();
  const tests = referral.tests.join(', ').toLowerCase();
  let priority: AIInsight['priority'] = 'medium';
  const keyPoints: string[] = [];

  if (/emergency|critical|severe|cardiac/.test(diag)) priority = 'critical';
  else if (/fever|infection|typhoid|viral/.test(diag)) priority = 'high';
  else if (/follow.?up|monitor|check/.test(diag)) priority = 'low';

  if (referral.tests.length > 0) keyPoints.push(`${referral.tests.length} diagnostic test(s) ordered`);
  if (referral.medicines.length > 0) keyPoints.push(`${referral.medicines.length} medication(s) prescribed`);
  if (/blood/.test(tests)) keyPoints.push('Blood panel analysis required — fasting may be needed');
  if (/culture/.test(tests)) keyPoints.push('Culture test ordered — results may take 48-72 hrs');
  if (/urine/.test(tests)) keyPoints.push('Urine sample required — collect first morning sample');
  keyPoints.push(`Referred by ${referral.doctor_name} (${referral.doctor_specialization})`);

  return {
    summary: `Patient requires ${referral.type} services for: ${referral.diagnosis}. ${referral.reason}.`,
    priority,
    key_points: keyPoints,
    recommended_action:
      priority === 'critical' ? 'Immediate attention required — report to emergency desk first.' :
      priority === 'high'     ? 'Complete tests today — bring this QR ticket to reception.' :
      priority === 'medium'   ? 'Schedule within 48 hours. Carry previous reports if available.' :
                                'Can be done at your convenience. Carry doctor prescription.',
  };
}

// ── API Calls with Mock Fallback ──────────────────────────────────────────────

async function tryBackend<T>(fn: () => Promise<T>, fallback: () => T): Promise<T> {
  try { return await fn(); } catch { return fallback(); }
}

// ── Referral APIs ─────────────────────────────────────────────────────────────

export async function createReferral(payload: CreateReferralPayload): Promise<Referral> {
  const refId = `ref-${Date.now()}`;
  const refObj: Referral = {
    ...payload,
    id: refId,
    doctor_id: 'doc-1',
    doctor_name: 'Dr. Anil Kumar',
    doctor_specialization: 'General Physician',
    created_at: new Date().toISOString(),
    expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
  };

  try {
    const { data, error } = await supabase.from('referrals').insert(refObj).select().single();
    if (data && !error) return data;
  } catch (err) { }

  await delay(700);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/referral/create`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
      if (!r.ok) throw new Error();
      return r.json();
    },
    () => {
      const ref: Referral = {
        ...payload,
        id: `ref-${Date.now()}`,
        doctor_id: 'doc-1',
        doctor_name: 'Dr. Anil Kumar',
        doctor_specialization: 'General Physician',
        created_at: new Date().toISOString(),
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      };
      MOCK_REFERRALS.push(ref);
      return ref;
    }
  );
}

export async function generateReferralQR(referralId: string): Promise<ReferralQRToken> {
  await delay(400);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/referral/generate-qr`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ referral_id: referralId }) });
      if (!r.ok) throw new Error();
      return r.json();
    },
    () => {
      const token = generateReferralToken(referralId);
      return { id: `qr-${Date.now()}`, referral_id: referralId, token, expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() };
    }
  );
}

export async function scanReferralQR(token: string): Promise<{ referral: Referral; ai_insight: AIInsight }> {
  try {
    const referralId = parseReferralToken(token);
    const { data, error } = await supabase.from('referrals').select('*').eq('id', referralId).single();
    if (data && !error) {
      return { referral: data, ai_insight: buildAIInsight(data) };
    }
  } catch (err) { }

  await delay(800);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/referral/scan`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ token }) });
      if (!r.ok) throw new Error();
      return r.json();
    },
    () => {
      const referralId = parseReferralToken(token);
      const referral = MOCK_REFERRALS.find(r => r.id === referralId) ?? MOCK_REFERRALS[0];
      if (!referral) throw new Error('Referral not found or expired.');
      return { referral, ai_insight: buildAIInsight(referral) };
    }
  );
}

export async function getReferrals(): Promise<Referral[]> {
  try {
    const { data, error } = await supabase.from('referrals').select('*').order('created_at', { ascending: false });
    if (data && !error) return data;
  } catch (err) { }

  await delay(400);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/referral/list`);
      if (!r.ok) throw new Error();
      return r.json();
    },
    () => {
      return MOCK_REFERRALS;
    }
  );
}

// ── Provider APIs ─────────────────────────────────────────────────────────────

export async function getProviders(type: 'lab' | 'hospital' | 'specialist'): Promise<Provider[]> {
  await delay(500);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/referral/providers?type=${type}`);
      if (!r.ok) throw new Error();
      return r.json();
    },
    () => {
      return MOCK_PROVIDERS.filter(p => p.type === type);
    }
  );
}

// ── Booking APIs ──────────────────────────────────────────────────────────────

export async function createBooking(payload: CreateBookingPayload): Promise<{ booking: Booking; ticket: Ticket }> {
  await delay(900);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/referral/booking/create`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
      if (!r.ok) throw new Error();
      return r.json();
    },
    () => {
      const provider = MOCK_PROVIDERS.find(p => p.id === payload.provider_id)!;
      const referral = MOCK_REFERRALS.find(r => r.id === payload.referral_id) ?? MOCK_REFERRALS[0];
      const bookingId = `bk-${Date.now()}`;
      const amount = payload.type === 'lab' ? 850 : payload.type === 'specialist' ? 1200 : 500;

      const booking: Booking = {
        id: bookingId,
        referral_id: payload.referral_id,
        type: payload.type,
        provider_id: payload.provider_id,
        provider_name: provider.name,
        provider_address: provider.address,
        patient_name: referral.patient_name,
        date: payload.date,
        time_slot: payload.time_slot,
        status: 'confirmed',
        amount,
        created_at: new Date().toISOString(),
      };
      MOCK_BOOKINGS.push(booking);

      const ticketToken = generateBookingToken(bookingId);
      const ticket: Ticket = {
        id: `tk-${Date.now()}`,
        booking_id: bookingId,
        patient_name: referral.patient_name,
        booking_type: payload.type,
        provider_name: provider.name,
        provider_address: provider.address,
        date: payload.date,
        time_slot: payload.time_slot,
        qr_token: ticketToken,
        status: 'active',
        created_at: new Date().toISOString(),
      };
      MOCK_TICKETS.push(ticket);

      // Generate earning
      const commission = amount * 0.1;
      MOCK_EARNINGS.push({
        id: `earn-${Date.now()}`,
        booking_id: bookingId,
        patient_name: referral.patient_name,
        provider_name: provider.name,
        booking_type: payload.type,
        total_amount: amount,
        commission_rate: 10,
        commission_amount: commission,
        status: 'pending',
        created_at: new Date().toISOString(),
      });

      return { booking, ticket };
    }
  );
}

export async function scanTicketQR(token: string): Promise<Ticket> {
  await delay(600);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/referral/ticket/scan`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ token }) });
      if (!r.ok) throw new Error();
      return r.json();
    },
    () => {
      const bookingId = parseBookingToken(token);
      const ticket = MOCK_TICKETS.find(t => t.booking_id === bookingId);
      if (!ticket) throw new Error('Ticket not found or already used.');
      return ticket;
    }
  );
}

export async function completeBooking(bookingId: string): Promise<void> {
  await delay(500);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/referral/booking/complete`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ booking_id: bookingId }) });
      if (!r.ok) throw new Error();
    },
    () => {
      const booking = MOCK_BOOKINGS.find(b => b.id === bookingId);
      if (booking) booking.status = 'completed';
      const ticket = MOCK_TICKETS.find(t => t.booking_id === bookingId);
      if (ticket) ticket.status = 'used';
      const earning = MOCK_EARNINGS.find(e => e.booking_id === bookingId);
      if (earning) earning.status = 'paid';
    }
  );
}

// ── Earnings APIs ─────────────────────────────────────────────────────────────

export async function getEarnings(): Promise<EarningsSummary> {
  await delay(500);
  return tryBackend(
    async () => {
      const r = await fetch(`${BASE}/referral/earnings`);
      if (!r.ok) throw new Error();
      return r.json();
    },
    () => {
      const total_revenue = MOCK_EARNINGS.reduce((a, e) => a + e.total_amount, 0);
      const total_commission = MOCK_EARNINGS.reduce((a, e) => a + e.commission_amount, 0);
      const pending = MOCK_EARNINGS.filter(e => e.status === 'pending').reduce((a, e) => a + e.commission_amount, 0);
      const paid = MOCK_EARNINGS.filter(e => e.status === 'paid').reduce((a, e) => a + e.commission_amount, 0);
      return {
        total_bookings: MOCK_BOOKINGS.length,
        total_revenue,
        total_commission,
        pending_commission: pending,
        paid_commission: paid,
        recent: [...MOCK_EARNINGS].reverse().slice(0, 10),
      };
    }
  );
}

export async function getDemoReferralToken(): Promise<string> {
  return generateReferralToken('ref-001');
}
