import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'YOUR_SUPABASE_URL';
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'YOUR_SUPABASE_ANON_KEY';

if (!import.meta.env.VITE_SUPABASE_URL) {
  console.warn('⚠️ No VITE_SUPABASE_URL found in environment variables. Make sure your .env file is set up if using actual Postgres DB.');
}

export const supabase = createClient(supabaseUrl, supabaseKey);
