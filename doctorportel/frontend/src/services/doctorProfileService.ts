/**
 * Doctor Profile Service — API calls for profile setup page.
 */
import { supabase } from '../lib/supabase';

const BASE = '/api/v1/doctor-profile/';

export interface DaySchedule {
  enabled: boolean;
  start_time: string;
  end_time: string;
  break_start: string;
  break_end: string;
}

export interface Workplace {
  id: string;
  name: string;
  type: string;
  position: string;
  location: string;
  working_hours: string;
  is_primary: boolean;
}

export interface DocDocument {
  id: string;
  name: string;
  type: string;
  file_url: string | null;
  file_name: string;
  uploaded_at: string | null;
  status: string;
}

export interface DoctorProfile {
  id: string | null;
  overview: {
    full_name: string;
    profile_photo: string | null;
    specialization: string;
    degree: string;
    years_of_experience: number;
    bio: string;
    languages: string[];
    city: string;
    address: string;
  };
  workplaces: Workplace[];
  availability: {
    slot_duration: number;
    monday: DaySchedule;
    tuesday: DaySchedule;
    wednesday: DaySchedule;
    thursday: DaySchedule;
    friday: DaySchedule;
    saturday: DaySchedule;
    sunday: DaySchedule;
  };
  fees: {
    online_fee: number;
    offline_fee: number;
    emergency_fee: number;
    free_consultation: boolean;
    discount_percent: number;
  };
  documents: DocDocument[];
  settings: {
    email_notifications: boolean;
    sms_notifications: boolean;
    push_notifications: boolean;
    language: string;
    profile_visibility: string;
    show_phone: boolean;
    show_email: boolean;
  };
  verification_status: string;
  completion_percent: number;
  created_at: string | null;
  updated_at: string | null;
}

const defaultProfile = {
  id: null,
  overview: { full_name: '', profile_photo: null, specialization: '', degree: '', years_of_experience: 0, bio: '', languages: [], city: '', address: '' },
  workplaces: [], availability: { slot_duration: 30, monday: { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' }, tuesday: { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' }, wednesday: { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' }, thursday: { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' }, friday: { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' }, saturday: { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' }, sunday: { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' } }, fees: { online_fee: 0, offline_fee: 0, emergency_fee: 0, free_consultation: false, discount_percent: 0 }, documents: [], settings: { email_notifications: true, sms_notifications: false, push_notifications: true, language: 'English', profile_visibility: 'public', show_phone: false, show_email: true }, verification_status: 'incomplete', completion_percent: 0, created_at: null, updated_at: null } as DoctorProfile;

function calcCompletion(profile: Partial<DoctorProfile>): number {
  let total = 0; let filled = 0;
  const ov = profile.overview;
  if (ov) { const fields: (keyof typeof ov)[] = ['full_name', 'specialization', 'degree', 'years_of_experience', 'bio', 'city']; fields.forEach(f => { total++; if (ov[f]) filled++; }); } else { total += 6; }
  total++; if (profile.workplaces && profile.workplaces.length > 0) filled++;
  total++; if (profile.availability) { const d = profile.availability; if (d.monday?.enabled || d.tuesday?.enabled || d.wednesday?.enabled || d.thursday?.enabled || d.friday?.enabled || d.saturday?.enabled || d.sunday?.enabled) filled++; }
  total++; if (profile.fees && (profile.fees.online_fee > 0 || profile.fees.offline_fee > 0)) filled++;
  total++; if (profile.documents && profile.documents.some(d => d.type === 'license')) filled++;
  return Math.max(0, Math.min(100, Math.floor((filled / Math.max(total, 1)) * 100)));
}

export async function getProfile(): Promise<DoctorProfile> {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error("No active user session");

  const { data, error } = await supabase.from('doctor_profiles').select('*').eq('id', user.id).maybeSingle();
  if (error && error.code !== 'PGRST116') { console.error("Error fetching profile from Supabase:", error); return { ...defaultProfile, id: user.id }; }
  
  if (!data) return { 
    ...defaultProfile, 
    id: user.id,
    overview: {
      ...defaultProfile.overview,
      full_name: user.user_metadata?.full_name || ''
    }
  };
  
  const result = { 
    id: data.id, 
    overview: { ...(data.overview || defaultProfile.overview) }, 
    workplaces: data.workplaces || [], 
    availability: data.availability || defaultProfile.availability, 
    fees: data.fees || defaultProfile.fees, 
    documents: data.documents || [], 
    settings: data.settings || defaultProfile.settings, 
    verification_status: data.verification_status || 'incomplete', 
    completion_percent: data.completion_percent || 0, 
    created_at: data.created_at, 
    updated_at: data.updated_at 
  };
  
  if (!result.overview.full_name && user.user_metadata?.full_name) {
    result.overview.full_name = user.user_metadata.full_name;
  }
  
  return result;
}

export async function saveProfile(data: Partial<DoctorProfile>): Promise<DoctorProfile> {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error("No active user session");

  const completion = calcCompletion(data);
  const status = data.verification_status === 'approved' ? 'approved' : (data.verification_status === 'pending' ? 'pending' : 'incomplete');

  const payload = {
    id: user.id,
    overview: data.overview, workplaces: data.workplaces, availability: data.availability, fees: data.fees, documents: data.documents, settings: data.settings,
    completion_percent: completion, verification_status: status
  };

  const { data: ret, error } = await supabase.from('doctor_profiles').upsert(payload, { onConflict: 'id' }).select().single();
  if (error) throw new Error(error.message);
  
  return {
    id: ret.id, overview: ret.overview, workplaces: ret.workplaces || [], availability: ret.availability, fees: ret.fees, documents: ret.documents || [], settings: ret.settings, verification_status: ret.verification_status, completion_percent: ret.completion_percent, created_at: ret.created_at, updated_at: ret.updated_at
  };
}

export async function submitProfile(): Promise<{ status?: string; error?: string; message?: string }> {
  const profile = await getProfile();
  if (profile.completion_percent < 60) return { error: `Profile is only ${profile.completion_percent}% complete. Please fill required fields.` };
  const hasLicense = profile.documents?.some(d => d.type === 'license');
  if (!hasLicense) return { error: 'Medical license document is required for verification.' };

  const { data: { user } } = await supabase.auth.getUser();
  const { error } = await supabase.from('doctor_profiles').update({ verification_status: 'pending' }).eq('id', user?.id as string);
  if (error) throw new Error(error.message);

  return { status: "submitted", message: "Profile submitted for admin verification." };
}

export async function generateBio(data: {
  full_name: string;
  specialization: string;
  degree: string;
  years_of_experience: number;
  city: string;
}): Promise<string> {
  const res = await fetch(`${BASE}generate-bio`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  if (!res.ok) throw new Error('Failed to generate bio');
  const json = await res.json();
  return json.bio;
}
