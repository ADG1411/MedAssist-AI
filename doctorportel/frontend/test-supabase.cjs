const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: 'd:/abhi coding/doctor-portal-/frontend/.env' });

const supabase = createClient(process.env.VITE_SUPABASE_URL, process.env.VITE_SUPABASE_ANON_KEY);

async function test() {
  const { data, error } = await supabase.from('doctors').select('*').limit(1).single();
  console.log("Select Result:", { data, error });
  
  if (error && error.code === 'PGRST116') {
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
      console.log("Insert Result:", { newDoc, createError });
      
      if (!createError) {
          const {error: statError} = await supabase.from('doctor_stats').insert([{ doctor_id: newDoc.id, total_patients: 1250, consultations: 85, success_rate: '98%', earnings_this_month: 12450.00 }]);
          console.log("Stats Insert:", statError);
      }
  }
}
test();