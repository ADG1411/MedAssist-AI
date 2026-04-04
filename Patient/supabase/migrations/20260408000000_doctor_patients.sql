-- Create doctor_patients table
CREATE TABLE IF NOT EXISTS public.doctor_patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    doctor_id UUID NOT NULL REFERENCES public.doctor_profiles(id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    first_visit TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_visit TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    visit_count INTEGER DEFAULT 1,
    is_favorite BOOLEAN DEFAULT false,
    risk_status TEXT DEFAULT 'low',
    notes TEXT,
    UNIQUE(doctor_id, patient_id)
);

-- Turn on RLS
ALTER TABLE public.doctor_patients ENABLE ROW LEVEL SECURITY;

-- Allow doctors to read their own patient list
CREATE POLICY "Doctors can view their own patients."
    ON public.doctor_patients FOR SELECT
    USING (auth.uid() = doctor_id);

-- Allow doctors to insert/update their patients
CREATE POLICY "Doctors can insert/update their own patients."
    ON public.doctor_patients FOR ALL
    USING (auth.uid() = doctor_id)
    WITH CHECK (auth.uid() = doctor_id);
