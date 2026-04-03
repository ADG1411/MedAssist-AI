import { supabase } from '../lib/supabase';

export const emergencyService = {
  createRequest: async (requestData) => {
    const { data, error } = await supabase
      .from('emergency_requests')
      .insert([requestData]);
    return { data, error };
  },

  subscribeToAlerts: (callback) => {
    const channel = supabase
      .channel('emergency')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'emergency_requests'
        },
        (payload) => {
          callback(payload);
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }
};
