-- Migration for Doctor Ecosystem (Phase 3)

-- 1. Create Doctors Table
DROP TABLE IF EXISTS public.bookings CASCADE;
DROP TABLE IF EXISTS public.doctors CASCADE;

CREATE TABLE public.doctors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id), -- If a doctor eventually logs in
    name TEXT NOT NULL,
    specialty TEXT NOT NULL,
    experience INTEGER DEFAULT 0,
    rating NUMERIC DEFAULT 5.0,
    consultation_fee INTEGER NOT NULL,
    bio TEXT,
    photo_url TEXT,
    available_slots JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create Bookings Table
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES auth.users(id) NOT NULL,
    doctor_id UUID REFERENCES public.doctors(id) NOT NULL,
    slot_time TEXT NOT NULL,
    amount INTEGER NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    razorpay_order_id TEXT,
    razorpay_payment_id TEXT,
    jitsi_room_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Set up RLS Policies
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Doctors are readable by anyone authenticated (patients can browse)
CREATE POLICY "Anyone authenticated can view doctors" ON public.doctors
    FOR SELECT TO authenticated USING (true);

-- Bookings can be viewed/inserted by the patient who owns them
CREATE POLICY "Patients can view own bookings" ON public.bookings
    FOR SELECT TO authenticated USING (auth.uid() = patient_id);

CREATE POLICY "Patients can create bookings" ON public.bookings
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = patient_id);

-- 4. Insert Initial Mock Data
INSERT INTO public.doctors (name, specialty, experience, rating, consultation_fee, bio, available_slots)
VALUES 
('Dr. Sarah Jenkins', 'Cardiology', 14, 4.9, 1200, 'Board-certified cardiologist specializing in coronary artery disease.', '["Today, 4:00 PM", "Tomorrow, 10:00 AM"]'::jsonb),
('Dr. Mark Sloan', 'Gastroenterology', 8, 4.7, 850, 'Expert in digestive system disorders including GERD.', '["Today, 2:00 PM", "Wednesday, 9:00 AM"]'::jsonb),
('Dr. Emily Chen', 'General Practice', 5, 4.5, 500, 'Family medicine practitioner focusing on holistic preventative care.', '["Tomorrow, 11:00 AM"]'::jsonb),
('Dr. Robert King', 'Dermatology', 12, 4.8, 1000, 'Specialist in skin conditions, early cancer detection.', '["Friday, 3:00 PM"]'::jsonb);

-- ============================================================
-- 5. Hospitals Table
-- ============================================================
DROP TABLE IF EXISTS public.hospitals CASCADE;

CREATE TABLE public.hospitals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    distance TEXT,
    has_emergency BOOLEAN DEFAULT false,
    phone TEXT,
    lat NUMERIC,
    lng NUMERIC,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.hospitals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone authenticated can view hospitals" ON public.hospitals
    FOR SELECT TO authenticated USING (true);

INSERT INTO public.hospitals (name, address, distance, has_emergency)
VALUES
('City Central General Hospital', '124 Medical Way, Downtown Block', '1.2', true),
('Sunrise Care Clinic', 'Sunset Blvd, East Sector', '3.4', false),
('Apollo Multi-Specialty', 'Ring Road Extension', '5.0', true),
('Fortis Healthcare', 'MG Road, Sector 12', '2.8', true),
('Medanta - The Medicity', 'Golf Course Road', '6.5', true);

-- ============================================================
-- 6. Care Plans Table (Post-Consultation)
-- ============================================================
DROP TABLE IF EXISTS public.care_plans CASCADE;

CREATE TABLE public.care_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID REFERENCES public.bookings(id),
    patient_id UUID REFERENCES auth.users(id) NOT NULL,
    doctor_id UUID REFERENCES public.doctors(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback TEXT,
    prescription JSONB DEFAULT '[]'::jsonb,
    follow_up_date TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.care_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Patients can view own care plans" ON public.care_plans
    FOR SELECT TO authenticated USING (auth.uid() = patient_id);

CREATE POLICY "Patients can create care plans" ON public.care_plans
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = patient_id);
