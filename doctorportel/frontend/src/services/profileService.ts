import { supabase } from '../lib/supabase';

export interface DoctorProfile {
  id: string;
  user_id: string;
  full_name: string;
  email: string;
  phone_number: string;
  specialization: string;
  experience_years: number;
  rating: number;
  languages: string;
  bio: string;
  location: string;
  avatar: string;
  stats?: {
    total_patients: number;
    consultations: number;
    success_rate: string;
    earnings_this_month: number;
  };
  is_active: boolean;
}

export interface Workplace {
  id: string;
  doctor_id: string;
  name: string;
  type: string;
  role: string;
  location: string;
  is_primary: boolean;
  verified: boolean;
}

export interface Fees {
  has_free_first_consult: boolean;
  video_fee: number;
  in_person_fee: number;
  emergency_fee: number;
}

let cachedDoctorId: string | null = null;

async function getDoctorId(): Promise<string | null> {
  if (cachedDoctorId) return cachedDoctorId;
  const { data: doc } = await supabase.from('doctors').select('id').limit(1).single();
  if (doc?.id) {
    cachedDoctorId = doc.id;
  }
  return cachedDoctorId;
}

export const profileService = {
  async getProfile(): Promise<DoctorProfile | null> {
    try {
      // Fetch doctor and stats in parallel if possible, or join them
      // Since doctor row is needed, join them:
      let { data: doctorRow, error: docError } = await supabase
        .from('doctors')
        .select('*, stats:doctor_stats(*)')
        .limit(1)
        .single();

      // If no doctor exists (fresh DB), create a mock doctor automatically
      if (docError && docError.code === 'PGRST116') {
        const { data: newDoc, error: createError } = await supabase.from('doctors').insert([
          {
            full_name: "Dr. Sarah Mitchell",
            email: "sarah.mitchell@example.com",
            phone_number: "+1 (555) 123-4567",
            specialization: "Cardiology",
            experience_years: 12,
            rating: 4.9,
            languages: "English, Spanish",
            bio: "Experienced cardiologist with over 10 years of practice.",
            location: "New York, USA",
            avatar: "https://i.pravatar.cc/150?img=32"
          }
        ]).select().single();

        if (createError) throw createError;
        
        // Create initial stats
        const { data: newStats } = await supabase.from('doctor_stats').insert([{
          doctor_id: newDoc.id,
          total_patients: 1250,
          consultations: 85,
          success_rate: "98%",
          earnings_this_month: 12450.00
        }]).select().single();
        
        cachedDoctorId = newDoc.id;
        return {
          ...newDoc,
          stats: newStats || undefined
        };
      } else if (docError) {
        console.error("Supabase error:", docError);
        return null;
      }

      if (doctorRow) {
        cachedDoctorId = doctorRow.id;
      }

      // Convert joined output 'stats: [...]' to just the object
      const statsObj = doctorRow?.stats?.[0] || doctorRow?.stats;
      delete doctorRow.stats;

      return {
        ...doctorRow,
        stats: statsObj || undefined
      };
    } catch (error) {
      console.error("Error fetching profile from Supabase:", error);
      return null;
    }
  },

  async upsertProfile(updates: { bio?: string, languages?: string }) {
    try {
      const docId = await getDoctorId();
      if (!docId) throw new Error("No doctor found");

      const { error } = await supabase
        .from('doctors')
        .update(updates)
        .eq('id', docId);
        
      if (error) throw error;
      return { error: null };
    } catch (error) {
      console.error("Error updating profile in Supabase:", error);
      return { error };
    }
  },

  async getWorkplaces(): Promise<Workplace[]> {
    try {
      const docId = await getDoctorId();
      if (!docId) return [];

      const { data, error } = await supabase
        .from('doctor_workplaces')
        .select('*')
        .eq('doctor_id', docId)
        .order('created_at', { ascending: false });
        
      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error("Error fetching workplaces from Supabase:", error);
      return [];
    }
  },

  async addWorkplace(workplace: Omit<Workplace, "id" | "doctor_id">): Promise<{ data: Workplace[] | null, error: any }> {
    try {
      const docId = await getDoctorId();
      if (!docId) throw new Error("No doctor found");

      const { data, error } = await supabase
        .from('doctor_workplaces')
        .insert([{
          ...workplace,
          doctor_id: docId
        }])
        .select();
        
      if (error) throw error;
      return { data, error: null };
    } catch (error) {
      console.error("Error adding workplace to Supabase:", error);
      return { data: null, error };
    }
  },

  async getFees(): Promise<Fees | null> {
    try {
      const docId = await getDoctorId();
      if (!docId) return null;

      const { data, error } = await supabase
        .from('doctor_fees')
        .select('*')
        .eq('doctor_id', docId)
        .single();

      if (error && error.code !== 'PGRST116') throw error; // Ignore no rows error
      
      return data || {
        has_free_first_consult: false,
        video_fee: 0,
        in_person_fee: 0,
        emergency_fee: 0
      };
    } catch (error) {
      console.error("Error fetching fees from Supabase:", error);
      return null;
    }
  },

  async upsertFees(updates: Fees) {
    try {
      const docId = await getDoctorId();
      if (!docId) throw new Error("No doctor found");

      const { error } = await supabase
        .from('doctor_fees')
        .upsert({
          doctor_id: docId,
          ...updates,
          updated_at: new Date().toISOString()
        });
        
      if (error) throw error;
      return { error: null };
    } catch (error) {
      console.error("Error updating fees in Supabase:", error);
      return { error };
    }
  }
};
