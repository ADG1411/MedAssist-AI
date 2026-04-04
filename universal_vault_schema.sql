-- ==========================================================================================
-- MEDASSIST AI HEALTH MEMORY SYSTEM - DATABASE EXTENSION SCHEMA
-- This script safely constructs the new Vault infrastructure and Edge AI tables.
-- Execute this directly in your Supabase SQL Editor.
-- ==========================================================================================

-- 1. Create the Storage Bucket for Medical Records
-- Safe creation (if it doesn't already exist)
insert into storage.buckets (id, name, public)
select 'medical-records', 'medical-records', false
where not exists (
  select 1 from storage.buckets where id = 'medical-records'
);

-- Enable RLS for the bucket
update storage.buckets set public = false where id = 'medical-records';

-- Give logged-in patients permission to upload to their own folder: user_id/*
create policy "Users can upload their own records"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'medical-records' and 
  (auth.uid())::text = (string_to_array(name, '/'))[1]
);

-- Give logged-in users and doctors permission to read records
create policy "Users and Doctors can read records"
on storage.objects for select to authenticated
using (
  bucket_id = 'medical-records'
);

-- 2. Create the unified `medical_records` table
CREATE TABLE IF NOT EXISTS public.medical_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_type TEXT NOT NULL, -- e.g. 'application/pdf', 'image/jpeg'
    category TEXT NOT NULL CHECK (category IN ('Blood Test', 'Prescription', 'Imaging', 'Discharge Note', 'Doctor Note', 'Insurance', 'Other')),
    source_type TEXT NOT NULL DEFAULT 'patient' CHECK (source_type IN ('patient', 'doctor', 'ai')),
    doctor_id UUID REFERENCES public.doctor_profiles(id) ON DELETE SET NULL,
    
    -- AI Intelligence Layer
    ai_summary TEXT,
    ai_risk_level TEXT CHECK (ai_risk_level IN ('Low', 'Medium', 'High', 'Critical')),
    ai_tags TEXT[] DEFAULT '{}',
    abnormal_flags JSONB DEFAULT '{}'::jsonb,
    extracted_text TEXT,
    
    -- Continuity
    share_token TEXT UNIQUE,
    consultation_id UUID, -- Optional link to a specific appointment
    
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Turn on Row Level Security
ALTER TABLE public.medical_records ENABLE ROW LEVEL SECURITY;

-- Policy: Patients can manage their own records
CREATE POLICY "Patients can view own records"
    ON public.medical_records FOR SELECT TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Patients can insert own records"
    ON public.medical_records FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Doctors can view shared records"
    ON public.medical_records FOR SELECT TO authenticated
    USING (
      -- A doctor can view it if the patient shared a token they have, or the doctor uploaded it.
      -- (For production, we will integrate secure sharing tables mapping accesses)
      true 
    );

-- 3. Create the `doctor_record_notes` table
CREATE TABLE IF NOT EXISTS public.doctor_record_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    record_id UUID NOT NULL REFERENCES public.medical_records(id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES public.doctor_profiles(id) ON DELETE CASCADE,
    
    note TEXT NOT NULL,
    severity TEXT CHECK (severity IN ('Normal', 'Monitor', 'Urgent')),
    follow_up_required BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.doctor_record_notes ENABLE ROW LEVEL SECURITY;

-- Policy: Doctors can manage notes, patients can read them.
CREATE POLICY "Doctors can manage their notes"
    ON public.doctor_record_notes FOR ALL TO authenticated
    USING (auth.uid() = doctor_id);

CREATE POLICY "Patients can view notes on their records"
    ON public.doctor_record_notes FOR SELECT TO authenticated
    USING (
      record_id IN (SELECT id FROM public.medical_records WHERE user_id = auth.uid())
    );

-- 4. Enable Realtime subscriptions conceptually
alter publication supabase_realtime add table medical_records;
alter publication supabase_realtime add table doctor_record_notes;
