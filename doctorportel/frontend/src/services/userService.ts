import { supabase } from '../lib/supabase';

// Add functions to fetch from your local proxy backend
export const fetchBackendDoctors = async () => {
  try {
    const res = await fetch('/api/v1/doctors/');
    if (!res.ok) throw new Error('Network error');
    return await res.json();
  } catch (err) {
    console.error('Error fetching doctors from backend:', err);
    return [];
  }
};

export const fetchBackendPatients = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;

    const { data, error } = await supabase
      .from('doctor_patients')
      .select(`
        patient_id,
        last_visit,
        risk_status,
        patient:profiles (
          id,
          name,
          age,
          gender,
          blood_group,
          allergies,
          chronic_conditions
        )
      `)
      .eq('doctor_id', user.id);

    if (error) throw error;
    
    if (!data) return [];

    // Map to simple structure for the frontend
    return data.map((d: any) => ({
      id: d.patient_id,
      first_name: d.patient?.name || 'Unknown',
      last_name: '',
      age: d.patient?.age || 0,
      gender: d.patient?.gender || 'Other',
      status: d.risk_status === 'high' ? 'Critical' : 'Active',
      last_diagnosis: 'Follow-up', // Default since diagnosis isn't stored here yet
      last_visit: d.last_visit,
      blood_group: d.patient?.blood_group,
      allergies: d.patient?.allergies,
      chronic_conditions: d.patient?.chronic_conditions
    }));
  } catch (err) {
    console.error('Error fetching patients from Supabase:', err);
    return null;
  }
};

export const userService = {
  getProfile: async (userId: string) => {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();
    return { data, error };
  },

  updateProfile: async (userId: string, updates: Record<string, unknown>) => {
    const { data, error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', userId);
    return { data, error };
  }
};
