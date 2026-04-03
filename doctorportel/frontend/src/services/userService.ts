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
    const res = await fetch('/api/v1/patients/');
    if (!res.ok) throw new Error('Network error');
    return await res.json();
  } catch (err) {
    console.error('Error fetching patients from backend:', err);
    return [];
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
