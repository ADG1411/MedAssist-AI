import { supabase } from './supabase';

const NIM_API_KEY = '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';
const MODEL = 'stepfun-ai/step-3.5-flash';

export interface Referral {
  id: string;
  patient_id: string;
  doctor_id: string;
  diagnosis: string;
  notes: string;
  medicines: string;
  tests: string;
  reason: string;
  type: 'Lab' | 'Hospital' | 'Specialist' | 'Emergency';
  created_at: string;
}

export interface Provider {
  id: string;
  name: string;
  type: 'Lab' | 'Hospital';
  rating: number;
  distance: string;
  price: number;
  image: string;
}

export interface Booking {
  id: string;
  referral_id: string;
  provider_id: string;
  date: string;
  time: string;
  status: 'Pending' | 'Confirmed' | 'Completed';
  amount: number;
}

export interface Ticket {
  id: string;
  booking_id: string;
  qr_token: string;
  status: 'Active' | 'Scanned';
}

export interface ReferralAISummary {
  explanation: string;
  priority: 'Routine' | 'Urgent' | 'Emergency';
  next_steps: string[];
}

// ── DEMO PROVIDERS ──
const DEMO_PROVIDERS: Provider[] = [
  { id: 'p1', name: 'Apollo Diagnostics', type: 'Lab', rating: 4.8, distance: '2.5 km', price: 1200, image: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?auto=format&fit=crop&q=80&w=200&h=200' },
  { id: 'p2', name: 'City Hospital Imaging', type: 'Hospital', rating: 4.5, distance: '4.1 km', price: 3500, image: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=200&h=200' },
  { id: 'p3', name: 'Dr. Lal PathLabs', type: 'Lab', rating: 4.7, distance: '1.2 km', price: 950, image: 'https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&q=80&w=200&h=200' },
];

// IN-MEMORY CACHE FOR RAPID EXPO DEV (Fallback if Supabase rows don't exist yet)
const memoryReferrals: Record<string, Referral> = {};
const memoryBookings: Record<string, Booking> = {};
const memoryTickets: Record<string, Ticket> = {};

export async function createReferral(data: Omit<Referral, 'id' | 'created_at'>): Promise<Referral> {
  const newRef: Referral = {
    ...data,
    id: `ref_${Date.now()}`,
    created_at: new Date().toISOString()
  };
  
  // Try Supabase insert if table exists, otherwise rely on memory
  try {
    await supabase.from('referrals').insert(newRef);
  } catch (e) { console.log('Supabase referral push failed, using local memory.'); }
  
  memoryReferrals[newRef.id] = newRef;
  return newRef;
}

export async function getReferral(id: string): Promise<Referral | null> {
  if (memoryReferrals[id]) return memoryReferrals[id];
  try {
    const { data } = await supabase.from('referrals').select('*').eq('id', id).maybeSingle();
    return data || null;
  } catch (e) { return null; }
}

export async function getProviders(type?: string): Promise<Provider[]> {
  if (type) return DEMO_PROVIDERS.filter(p => p.type === type);
  return DEMO_PROVIDERS;
}

export async function createBooking(referralId: string, providerId: string, date: string, time: string, amount: number): Promise<Booking> {
  const booking: Booking = {
    id: `bkg_${Date.now()}`,
    referral_id: referralId,
    provider_id: providerId,
    date,
    time,
    amount,
    status: 'Pending'
  };
  memoryBookings[booking.id] = booking;
  return booking;
}

export async function confirmPayment(bookingId: string): Promise<boolean> {
  if (memoryBookings[bookingId]) {
    memoryBookings[bookingId].status = 'Confirmed';
    return true;
  }
  return false;
}

export async function generateTicket(bookingId: string): Promise<Ticket> {
  const plainToken = `BKG-${bookingId}-${Date.now()}`;
  const encryptedToken = typeof btoa !== 'undefined' ? btoa(plainToken) : plainToken; // Simple encryption mockup for Expo
  
  const ticket: Ticket = {
    id: `tkt_${Date.now()}`,
    booking_id: bookingId,
    qr_token: `REFQR::${encryptedToken}`,
    status: 'Active'
  };
  
  memoryTickets[ticket.qr_token] = ticket;
  return ticket;
}

export async function getBookingByQR(qrToken: string): Promise<{ booking: Booking, referral: Referral, provider: Provider } | null> {
  const ticket = memoryTickets[qrToken];
  if (!ticket) return null;
  
  const booking = memoryBookings[ticket.booking_id];
  if (!booking) return null;
  
  const referral = memoryReferrals[booking.referral_id];
  const provider = DEMO_PROVIDERS.find(p => p.id === booking.provider_id) || DEMO_PROVIDERS[0];
  
  return { booking, referral, provider };
}

export async function generateAIReferralSummary(diagnosis: string, tests: string, notes: string): Promise<ReferralAISummary> {
  try {
    const prompt = `You are a friendly AI assisting a patient who just received a doctor's referral.
Translate the following medical jargon into a simple, reassuring explanation for the patient.

Diagnosis: ${diagnosis}
Tests Required: ${tests}
Notes: ${notes}

Respond strictly with valid JSON:
{
  "explanation": "2 sentence simple explanation of what it means and why they need the test.",
  "priority": "Routine" or "Urgent" or "Emergency",
  "next_steps": ["Step 1", "Step 2"]
}`;

    const response = await fetch('https://integrate.api.nvidia.com/v1/chat/completions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${NIM_API_KEY}` },
      body: JSON.stringify({
        model: MODEL,
        messages: [{ role: 'system', content: 'You respond only in secure JSON formatting.' }, { role: 'user', content: prompt }],
        temperature: 0.3, max_tokens: 500,
      }),
      signal: AbortSignal.timeout(10000),
    });

    if (response.ok) {
      const data = await response.json();
      let content = data.choices?.[0]?.message?.content || '';
      
      const firstBrace = content.indexOf('{');
      const lastBrace = content.lastIndexOf('}');
      if (firstBrace !== -1 && lastBrace !== -1) {
        content = content.substring(firstBrace, lastBrace + 1);
        return JSON.parse(content);
      }
    }
  } catch (e) {
    console.log("AI Summary failed, using fallback rules.");
  }
  
  // Rule-based fallback
  const isUrgent = notes.toLowerCase().includes('urgent') || diagnosis.toLowerCase().includes('severe');
  return {
    explanation: `Your doctor has requested you to undergo specific tests (${tests || 'blood work/imaging'}) to further evaluate your diagnosis of ${diagnosis || 'your condition'}. This is a standard procedure to help determine the best treatment plan.`,
    priority: isUrgent ? 'Urgent' : 'Routine',
    next_steps: [
      'Select a provider from the list below',
      'Choose a convenient date and time',
      'Complete the booking to generate your QR ticket'
    ]
  };
}
