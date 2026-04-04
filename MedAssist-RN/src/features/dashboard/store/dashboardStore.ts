import { create } from 'zustand';
import { supabase } from '../../../core/supabase/client';
import { CacheService, CacheBoxNames } from '../../../core/cache/cacheService';

export interface DashboardData {
  profile: Record<string, any> | null;
  health_score: number;
  recovery_score: number;
  recovery_velocity: number[];
  latest_monitoring: Record<string, any> | null;
  latest_ai_result: Record<string, any> | null;
  medication_reminders: any[];
  upcoming_appointments: any[];
  wearable_data: Record<string, any> | null;
}

interface DashboardState {
  data: DashboardData | null;
  loading: boolean;
  error: string | null;
  fetch: (userId: string) => Promise<void>;
}

const DEFAULT_DATA: DashboardData = {
  profile: null,
  health_score: 72,
  recovery_score: 70,
  recovery_velocity: [70, 72, 71, 75, 76],
  latest_monitoring: {
    sleep_hours: 6.2,
    hydration_cups: 5,
    pain_level: 3,
    mood: 'okay',
  },
  latest_ai_result: {
    condition: 'Gastritis',
    risk: 'moderate',
    confidence: 82,
  },
  medication_reminders: [
    { name: 'Omeprazole 20mg', taken: true },
    { name: 'Antacid', taken: false },
  ],
  upcoming_appointments: [
    { doctor: 'Dr. Sharma', type: 'Follow-up', time: 'Tomorrow 3 PM' },
  ],
  wearable_data: {
    heart_rate: 72,
    steps: 6340,
    sleep_hours: 6.2,
    spo2: 97,
    calories_burned: 1840,
    hydration_cups: 5,
  },
};

export const useDashboardStore = create<DashboardState>((set) => ({
  data: null,
  loading: false,
  error: null,

  fetch: async (userId: string) => {
    set({ loading: true, error: null });

    // Try cache first
    const cached = await CacheService.get<DashboardData>(
      CacheBoxNames.profile,
      'dashboard'
    );
    if (cached) set({ data: cached });

    try {
      // Fetch profile
      const { data: profile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      // Fetch latest monitoring
      const { data: monitoring } = await supabase
        .from('monitoring_logs')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(1)
        .single();

      // Fetch latest AI result
      const { data: aiResult } = await supabase
        .from('ai_clinical_context')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(1)
        .single();

      // Fetch medication reminders
      const { data: meds } = await supabase
        .from('medication_schedules')
        .select('*')
        .eq('user_id', userId);

      // Fetch upcoming appointments
      const { data: appts } = await supabase
        .from('appointments')
        .select('*')
        .eq('patient_id', userId)
        .gte('date', new Date().toISOString())
        .order('date', { ascending: true })
        .limit(3);

      const result: DashboardData = {
        profile: profile ?? DEFAULT_DATA.profile,
        health_score: (profile as any)?.health_score ?? DEFAULT_DATA.health_score,
        recovery_score: (profile as any)?.recovery_score ?? DEFAULT_DATA.recovery_score,
        recovery_velocity: DEFAULT_DATA.recovery_velocity,
        latest_monitoring: monitoring ?? DEFAULT_DATA.latest_monitoring,
        latest_ai_result: aiResult ?? DEFAULT_DATA.latest_ai_result,
        medication_reminders: meds ?? DEFAULT_DATA.medication_reminders,
        upcoming_appointments: appts ?? DEFAULT_DATA.upcoming_appointments,
        wearable_data: DEFAULT_DATA.wearable_data,
      };

      set({ data: result, loading: false });
      await CacheService.set(CacheBoxNames.profile, 'dashboard', result);
    } catch {
      // Fall back to default mock data on error
      if (!cached) set({ data: DEFAULT_DATA });
      set({ loading: false });
    }
  },
}));
