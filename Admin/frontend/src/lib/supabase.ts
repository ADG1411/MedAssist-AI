import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://htitifmnswmzpeqxcqnh.supabase.co';
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'sb_publishable_8juMzVC19b7pO2SyQXUgJw_3SID1bEl';

export const supabase = createClient(supabaseUrl, supabaseKey);
