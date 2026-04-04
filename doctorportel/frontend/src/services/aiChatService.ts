import type { ChatMessage } from '../types/chat';
import { supabase } from '../services/supabaseClient';

/**
 * AI Chat Service — Supabase-aware, NIM-powered clinical assistant
 * Fetches real doctor + patient data from Supabase and injects as context.
 */

type SearchMode = 'auto' | 'offline' | 'online';

const NIM_BASE_URL = '/nim-api';
const NIM_API_KEY = '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';
const MODEL = 'stepfun-ai/step-3.5-flash';

// ── Supabase Context Builder ────────────────────────────────────────────

interface PortalContext {
  doctor: string;
  patients: string;
  bookings: string;
  accessLogs: string;
  referrals: string;
}

async function fetchPortalContext(): Promise<PortalContext> {
  const ctx: PortalContext = {
    doctor: 'No doctor profile loaded.',
    patients: 'No patient data available.',
    bookings: 'No bookings found.',
    accessLogs: 'No access logs.',
    referrals: 'No referrals.',
  };

  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return ctx;

    // 1. Doctor's own profile
    const { data: profile } = await supabase
      .from('doctor_profiles')
      .select('overview, workplaces, availability, fees, completion_percent, verification_status')
      .eq('id', user.id)
      .maybeSingle();

    if (profile) {
      const ov = profile.overview || {};
      ctx.doctor = [
        `Doctor: ${ov.full_name || 'Not set'}`,
        `Specialization: ${ov.specialization || 'Not set'}`,
        `Degree: ${ov.degree || 'Not set'}`,
        `Experience: ${ov.years_of_experience || 0} years`,
        `City: ${ov.city || 'Not set'}`,
        `Profile Completion: ${profile.completion_percent || 0}%`,
        `Verification: ${profile.verification_status || 'incomplete'}`,
        `Online Fee: ₹${profile.fees?.online_fee || 0} | Offline Fee: ₹${profile.fees?.offline_fee || 0}`,
        `Workplaces: ${(profile.workplaces || []).map((w: any) => w.name).join(', ') || 'None'}`,
      ].join('\n');
    }

    // 2. Bookings for this doctor
    const { data: bookings } = await supabase
      .from('bookings')
      .select('id, patient_id, slot_time, status, payment_status, amount, doctor_name, created_at')
      .eq('doctor_id', user.id)
      .order('created_at', { ascending: false })
      .limit(15);

    if (bookings && bookings.length > 0) {
      const confirmed = bookings.filter(b => b.status === 'confirmed').length;
      const pending = bookings.filter(b => b.status === 'pending').length;
      const completed = bookings.filter(b => b.status === 'completed').length;
      const totalRevenue = bookings.reduce((s, b) => s + (b.amount || 0), 0);

      ctx.bookings = [
        `Total Bookings: ${bookings.length} (Confirmed: ${confirmed}, Pending: ${pending}, Completed: ${completed})`,
        `Total Revenue from bookings: ₹${totalRevenue}`,
        `Recent bookings:`,
        ...bookings.slice(0, 5).map(b =>
          `  - ${b.slot_time} | Status: ${b.status} | Payment: ${b.payment_status} | ₹${b.amount || 0}`
        ),
      ].join('\n');
    }

    // 3. Patients accessed via QR scan (cross-portal)
    const { data: accessGrants } = await supabase
      .from('doctor_patient_access')
      .select('patient_id, access_level, granted_at, expires_at, is_active')
      .eq('doctor_id', user.id)
      .order('granted_at', { ascending: false })
      .limit(10);

    if (accessGrants && accessGrants.length > 0) {
      // Fetch patient names for accessed patients
      const patientIds = accessGrants.map(a => a.patient_id);
      const { data: patientProfiles } = await supabase
        .from('profiles')
        .select('id, name, age, gender, blood_group, chronic_conditions, allergies')
        .in('id', patientIds);

      const profileMap = new Map((patientProfiles || []).map(p => [p.id, p]));

      const lines = [`Patients accessed (${accessGrants.length} total):`];
      for (const grant of accessGrants.slice(0, 8)) {
        const p = profileMap.get(grant.patient_id);
        const name = p?.name || `Patient ${grant.patient_id.substring(0, 8)}`;
        const age = p?.age ? `, ${p.age}y` : '';
        const bg = p?.blood_group ? `, Blood: ${p.blood_group}` : '';
        const conditions = p?.chronic_conditions?.length ? `, Conditions: ${p.chronic_conditions.join(', ')}` : '';
        const allergies = p?.allergies?.length ? `, Allergies: ${(Array.isArray(p.allergies) ? p.allergies : [p.allergies]).join(', ')}` : '';
        const active = grant.is_active && new Date(grant.expires_at) > new Date() ? '🟢 Active' : '🔴 Expired';
        lines.push(`  - ${name}${age}${bg}${conditions}${allergies} | Access: ${active} (${grant.access_level})`);
      }
      ctx.patients = lines.join('\n');
    }

    // 4. Access logs
    const { data: logs } = await supabase
      .from('doctor_access_logs')
      .select('patient_id, action, created_at, metadata')
      .eq('doctor_id', user.id)
      .order('created_at', { ascending: false })
      .limit(10);

    if (logs && logs.length > 0) {
      ctx.accessLogs = [
        `Recent activity (${logs.length} actions):`,
        ...logs.slice(0, 5).map(l =>
          `  - ${l.action} on patient ${l.patient_id.substring(0, 8)}... at ${new Date(l.created_at).toLocaleString()}`
        ),
      ].join('\n');
    }

    // 5. Referrals
    const { data: referrals } = await supabase
      .from('referrals')
      .select('id, patient_name, diagnosis, type, created_at')
      .order('created_at', { ascending: false })
      .limit(5);

    if (referrals && referrals.length > 0) {
      ctx.referrals = [
        `Recent Referrals (${referrals.length}):`,
        ...referrals.map(r =>
          `  - ${r.patient_name}: ${r.diagnosis} (${r.type}) — ${new Date(r.created_at).toLocaleDateString()}`
        ),
      ].join('\n');
    }

  } catch (err) {
    console.warn('Failed to fetch portal context for AI:', err);
  }

  return ctx;
}

function buildSystemPrompt(context: PortalContext): string {
  return `You are Dr. AI Co-Pilot, the intelligent clinical assistant integrated into the MedAssist Doctor Portal.

YOU HAVE FULL ACCESS TO THIS DOCTOR'S PORTAL DATA. Use it to answer questions directly.

═══ DOCTOR PROFILE ═══
${context.doctor}

═══ PATIENT DATA (from QR scans & access grants) ═══
${context.patients}

═══ BOOKINGS & APPOINTMENTS ═══
${context.bookings}

═══ RECENT ACTIVITY LOG ═══
${context.accessLogs}

═══ REFERRALS ═══
${context.referrals}

═══ INSTRUCTIONS ═══
- You are talking to the DOCTOR (not a patient). Use professional medical language.
- Answer questions using the REAL DATA above. Reference specific patient names, numbers, and dates.
- If asked "how many patients" → count from the data above and answer directly.
- If asked about bookings/revenue → compute from the booking data above.
- For clinical questions, provide evidence-based differentials with probability estimates.
- For prescriptions, flag drug interactions and contraindications.
- Structure complex answers with markdown headers and bullet points.
- If the data doesn't contain what's needed, say so clearly and suggest how to get it.
- Never say "I don't have access to your EHR" — you ARE the EHR assistant with the data above.`;
}

// ── Cached context (refreshes every 2 minutes) ────────────────────────

let cachedContext: PortalContext | null = null;
let contextTimestamp = 0;
const CONTEXT_TTL = 2 * 60 * 1000; // 2 minutes

async function getContext(): Promise<PortalContext> {
  const now = Date.now();
  if (!cachedContext || now - contextTimestamp > CONTEXT_TTL) {
    cachedContext = await fetchPortalContext();
    contextTimestamp = now;
  }
  return cachedContext;
}

// Force refresh on next call (e.g., after QR scan)
export function invalidateAIContext() {
  cachedContext = null;
  contextTimestamp = 0;
}

// ── Main Chat Function ──────────────────────────────────────────────────

export const sendChatMessage = async (
  message: string,
  history: ChatMessage[] = [],
  images?: string[],
  _searchMode: SearchMode = 'auto'
): Promise<ChatMessage> => {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 30000);

  try {
    // Fetch real portal data
    const context = await getContext();
    const systemPrompt = buildSystemPrompt(context);

    // Build message array
    const messages: Array<{ role: string; content: string | any[] }> = [
      { role: 'system', content: systemPrompt },
    ];

    // Add last 8 messages as conversation context
    const recentHistory = history.slice(-8);
    for (const msg of recentHistory) {
      messages.push({
        role: msg.role === 'user' ? 'user' : 'assistant',
        content: msg.content,
      });
    }

    // Current user message
    if (images && images.length > 0) {
      const contentArray: any[] = [{ type: 'text', text: message }];
      for (const b64 of images) {
        contentArray.push({
          type: 'image_url',
          image_url: { url: b64 },
        });
      }
      messages.push({ role: 'user', content: contentArray });
    } else {
      messages.push({ role: 'user', content: message });
    }

    const response = await fetch(`${NIM_BASE_URL}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${NIM_API_KEY}`,
      },
      body: JSON.stringify({
        model: MODEL,
        messages,
        temperature: 0.7,
        max_tokens: 4096,
      }),
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      const errText = await response.text().catch(() => '');
      throw new Error(`NIM API error ${response.status}: ${errText.substring(0, 200)}`);
    }

    const data = await response.json();
    const content = data.choices?.[0]?.message?.content || "I couldn't generate a response. Please try again.";

    return {
      id: crypto.randomUUID(),
      role: 'assistant',
      content,
      timestamp: new Date().toISOString(),
    };
  } catch (error: any) {
    clearTimeout(timeoutId);
    console.error('AI Chat Error:', error);

    const errorMsg =
      error.name === 'AbortError'
        ? 'The request timed out. The AI model might be busy — please try again.'
        : `AI service error: ${error.message || 'Unknown error'}. Please try again.`;

    return {
      id: crypto.randomUUID(),
      role: 'assistant',
      content: errorMsg,
      timestamp: new Date().toISOString(),
    };
  }
};

export const searchOnline = async (
  query: string
): Promise<{ text: string; sources: string[] }> => {
  try {
    const context = await getContext();
    const response = await fetch(`${NIM_BASE_URL}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${NIM_API_KEY}`,
      },
      body: JSON.stringify({
        model: MODEL,
        messages: [
          {
            role: 'system',
            content: `You are a medical search assistant with access to this doctor's portal data:\n${context.doctor}\n\nProvide evidence-based answers with source references. Format with markdown.`,
          },
          { role: 'user', content: `Medical query: ${query}` },
        ],
        temperature: 0.4,
        max_tokens: 2048,
      }),
    });

    if (!response.ok) throw new Error(`Search failed: ${response.status}`);

    const data = await response.json();
    const text = data.choices?.[0]?.message?.content || 'No results found.';
    return { text, sources: [] };
  } catch (error) {
    console.error('Search Error:', error);
    return { text: 'Failed to search. Please check your connection.', sources: [] };
  }
};