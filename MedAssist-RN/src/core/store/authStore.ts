import { create } from 'zustand';
import { supabase } from '../supabase/client';
import { CacheService, CacheBoxNames } from '../cache/cacheService';
import type { Session, User } from '@supabase/supabase-js';

interface AuthState {
  session: Session | null;
  user: User | null;
  profile: Record<string, unknown> | null;
  loading: boolean;
  setSession: (session: Session | null) => void;
  loadProfile: () => Promise<void>;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string, fullName: string) => Promise<void>;
  signOut: () => Promise<void>;
  initialize: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  session: null,
  user: null,
  profile: null,
  loading: true,

  setSession: (session) =>
    set({ session, user: session?.user ?? null }),

  loadProfile: async () => {
    const user = get().user;
    if (!user) return;

    // Try cache first
    const cached = await CacheService.get<Record<string, unknown>>(
      CacheBoxNames.profile,
      'current'
    );
    if (cached) set({ profile: cached });

    try {
      const { data } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();

      if (data) {
        set({ profile: data as Record<string, unknown> });
        await CacheService.set(CacheBoxNames.profile, 'current', data);
      }
    } catch {
      // use cached version
    }
  },

  signIn: async (email, password) => {
    set({ loading: true });
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) throw error;
    set({ session: data.session, user: data.session?.user ?? null, loading: false });
    await get().loadProfile();
  },

  signUp: async (email, password, fullName) => {
    set({ loading: true });
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { full_name: fullName } },
    });
    if (error) throw error;
    set({ session: data.session, user: data.session?.user ?? null, loading: false });
  },

  signOut: async () => {
    await supabase.auth.signOut();
    await CacheService.clearAll();
    set({ session: null, user: null, profile: null });
  },

  initialize: async () => {
    try {
      const { data } = await supabase.auth.getSession();
      set({
        session: data.session,
        user: data.session?.user ?? null,
        loading: false,
      });
      if (data.session) await get().loadProfile();
    } catch {
      set({ loading: false });
    }

    supabase.auth.onAuthStateChange((_event, session) => {
      set({ session, user: session?.user ?? null });
    });
  },
}));
