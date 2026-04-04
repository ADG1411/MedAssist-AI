import { supabase } from '../lib/supabase';

export const authService = {
  /**
   * Sign up a new doctor.
   * 1. Creates the auth user
   * 2. Auto-creates a row in doctor_profiles with the basic info
   */
  signUp: async (email: string, password: string, fullName: string, specialization?: string) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
          role: 'doctor',
        }
      }
    });

    // If signup succeeded and we have a user, create the doctor_profiles row
    if (!error && data?.user) {
      try {
        await supabase.from('doctor_profiles').upsert({
          id: data.user.id,
          overview: {
            full_name: fullName,
            specialization: specialization || '',
            degree: '',
            years_of_experience: 0,
            bio: '',
            languages: [],
            city: '',
            address: '',
            profile_photo: null,
          },
          workplaces: [],
          availability: {
            slot_duration: 30,
            monday:    { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' },
            tuesday:   { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' },
            wednesday: { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' },
            thursday:  { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' },
            friday:    { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' },
            saturday:  { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' },
            sunday:    { enabled: false, start_time: '09:00', end_time: '17:00', break_start: '13:00', break_end: '14:00' },
          },
          fees: { online_fee: 0, offline_fee: 0, emergency_fee: 0, free_consultation: false, discount_percent: 0 },
          documents: [],
          settings: { email_notifications: true, sms_notifications: false, push_notifications: true, language: 'English', profile_visibility: 'public', show_phone: false, show_email: true },
          verification_status: 'incomplete',
          completion_percent: 10, // Name counts as ~10%
        }, { onConflict: 'id' });
      } catch (profileError) {
        console.error('Failed to create doctor_profiles row:', profileError);
        // Don't block signup — profile can be created later
      }
    }

    return { data, error };
  },

  login: async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });
    return { data, error };
  },

  signInWithGoogle: async () => {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/dashboard`
      }
    });
    return { data, error };
  },

  signInWithApple: async () => {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'apple',
      options: {
        redirectTo: `${window.location.origin}/dashboard`
      }
    });
    return { data, error };
  },

  logout: async () => {
    const { error } = await supabase.auth.signOut();
    return { error };
  },

  getCurrentUser: async () => {
    const { data, error } = await supabase.auth.getUser();
    return { data, error };
  }
};
