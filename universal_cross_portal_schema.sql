-- ============================================================
-- MedAssist AI: Universal Cross-Portal Schema
-- Bridges Doctor Portal ↔ Patient Portal via shared Supabase
-- Run this in your Supabase SQL Editor
-- ============================================================

-- EXTENSIONS (ensure pgcrypto available)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ════════════════════════════════════════════════════════════
-- A. DOCTOR-PATIENT ACCESS BRIDGE
-- ════════════════════════════════════════════════════════════

-- When a doctor scans a patient QR, a temporary access grant is created
CREATE TABLE IF NOT EXISTS public.doctor_patient_access (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  patient_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  access_level TEXT DEFAULT 'read' CHECK (access_level IN ('read', 'emergency', 'full')),
  granted_via TEXT DEFAULT 'qr_scan',
  granted_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '24 hours'),
  is_active BOOLEAN DEFAULT true,
  UNIQUE(doctor_id, patient_id)
);

-- Audit trail for every doctor action on patient data
CREATE TABLE IF NOT EXISTS public.doctor_access_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  patient_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  action TEXT NOT NULL, -- 'view_profile', 'view_symptoms', 'view_nutrition', 'ai_consult', 'qr_scan'
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_dpa_doctor ON public.doctor_patient_access(doctor_id);
CREATE INDEX IF NOT EXISTS idx_dpa_patient ON public.doctor_patient_access(patient_id);
CREATE INDEX IF NOT EXISTS idx_dal_doctor ON public.doctor_access_logs(doctor_id);
CREATE INDEX IF NOT EXISTS idx_dal_patient ON public.doctor_access_logs(patient_id);
CREATE INDEX IF NOT EXISTS idx_dal_created ON public.doctor_access_logs(created_at DESC);

-- RLS
ALTER TABLE public.doctor_patient_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctor_access_logs ENABLE ROW LEVEL SECURITY;

-- Doctors can view/manage their own access grants
CREATE POLICY "Doctors can view own access grants"
  ON public.doctor_patient_access FOR SELECT
  USING (auth.uid() = doctor_id);

CREATE POLICY "Doctors can create access grants"
  ON public.doctor_patient_access FOR INSERT
  WITH CHECK (auth.uid() = doctor_id);

CREATE POLICY "Doctors can update own access grants"
  ON public.doctor_patient_access FOR UPDATE
  USING (auth.uid() = doctor_id);

-- Patients can view who accessed their data
CREATE POLICY "Patients can view access to their data"
  ON public.doctor_patient_access FOR SELECT
  USING (auth.uid() = patient_id);

-- Doctor access logs
CREATE POLICY "Doctors can view own access logs"
  ON public.doctor_access_logs FOR SELECT
  USING (auth.uid() = doctor_id);

CREATE POLICY "Doctors can insert access logs"
  ON public.doctor_access_logs FOR INSERT
  WITH CHECK (auth.uid() = doctor_id);

-- Patients can view logs about their data
CREATE POLICY "Patients can view logs about them"
  ON public.doctor_access_logs FOR SELECT
  USING (auth.uid() = patient_id);


-- ════════════════════════════════════════════════════════════
-- B. DOCTOR PROFILES TABLE (required for doctors_live VIEW)
-- ════════════════════════════════════════════════════════════
-- This table stores doctor registration data from the Doctor Portal.
-- If it already exists, this will be skipped.

CREATE TABLE IF NOT EXISTS public.doctor_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  overview JSONB DEFAULT '{}'::jsonb,
  workplaces JSONB DEFAULT '[]'::jsonb,
  availability JSONB DEFAULT '{}'::jsonb,
  fees JSONB DEFAULT '{}'::jsonb,
  documents JSONB DEFAULT '[]'::jsonb,
  settings JSONB DEFAULT '{}'::jsonb,
  verification_status TEXT DEFAULT 'incomplete',
  completion_percent INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for doctor_profiles
ALTER TABLE public.doctor_profiles ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can view own doctor profile' AND tablename = 'doctor_profiles') THEN
    EXECUTE 'CREATE POLICY "Users can view own doctor profile" ON public.doctor_profiles FOR SELECT USING (auth.uid() = id)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can insert own doctor profile' AND tablename = 'doctor_profiles') THEN
    EXECUTE 'CREATE POLICY "Users can insert own doctor profile" ON public.doctor_profiles FOR INSERT WITH CHECK (auth.uid() = id)';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update own doctor profile' AND tablename = 'doctor_profiles') THEN
    EXECUTE 'CREATE POLICY "Users can update own doctor profile" ON public.doctor_profiles FOR UPDATE USING (auth.uid() = id)';
  END IF;
END $$;

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_set_updated_at ON public.doctor_profiles;
CREATE TRIGGER trigger_set_updated_at
BEFORE UPDATE ON public.doctor_profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();


-- ════════════════════════════════════════════════════════════
-- C. LIVE VIEW: doctor_profiles → flat doctor format for Patient app
-- ════════════════════════════════════════════════════════════
-- This VIEW auto-syncs: doctor fills profile → patient sees them instantly.
-- Uses the same column names the Patient Flutter app expects.

CREATE OR REPLACE VIEW public.doctors_live AS
SELECT 
  dp.id::text AS id,
  dp.id AS user_id,
  COALESCE(dp.overview->>'full_name', 'Doctor') AS name,
  COALESCE(dp.overview->>'specialization', 'General Practice') AS specialty,
  COALESCE((dp.overview->>'years_of_experience')::int, 0) AS experience,
  4.5::numeric AS rating,
  COALESCE((dp.fees->>'offline_fee')::int, 500) AS consultation_fee,
  COALESCE(dp.overview->>'bio', '') AS bio,
  dp.overview->>'profile_photo' AS photo_url,
  -- Build available_slots from availability JSONB
  COALESCE(
    (SELECT jsonb_agg(slot)
     FROM (
       SELECT 'Today, ' || 
         CASE 
           WHEN key = 'monday' THEN 'Mon'
           WHEN key = 'tuesday' THEN 'Tue'
           WHEN key = 'wednesday' THEN 'Wed'
           WHEN key = 'thursday' THEN 'Thu'
           WHEN key = 'friday' THEN 'Fri'
           WHEN key = 'saturday' THEN 'Sat'
           WHEN key = 'sunday' THEN 'Sun'
         END || ' ' || (value->>'start_time') AS slot
       FROM jsonb_each(dp.availability)
       WHERE key != 'slot_duration'
         AND (value->>'enabled')::boolean = true
       LIMIT 3
     ) slots),
    '["Available on request"]'::jsonb
  ) AS available_slots,
  dp.created_at,
  dp.updated_at
FROM public.doctor_profiles dp
WHERE dp.verification_status != 'rejected'
  AND dp.completion_percent > 0
  AND dp.overview->>'full_name' IS NOT NULL
  AND dp.overview->>'full_name' != '';


-- ════════════════════════════════════════════════════════════
-- D. RLS POLICIES FOR CROSS-PORTAL PATIENT DATA READ
-- ════════════════════════════════════════════════════════════
-- Allow doctors to read patient data IF they have an active access grant.
-- These policies ADD to existing RLS — they don't replace patient self-access.

-- Profiles: doctors with active access can read patient profiles
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Doctors with access can view patient profiles'
  ) THEN
    EXECUTE 'CREATE POLICY "Doctors with access can view patient profiles"
      ON public.profiles FOR SELECT
      USING (
        auth.uid() = id  -- self access
        OR EXISTS (
          SELECT 1 FROM public.doctor_patient_access dpa
          WHERE dpa.doctor_id = auth.uid()
            AND dpa.patient_id = profiles.id
            AND dpa.is_active = true
            AND dpa.expires_at > NOW()
        )
      )';
  END IF;
END $$;

-- Symptom sessions: doctors with access can read
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Doctors with access can view patient symptoms'
  ) THEN
    EXECUTE 'CREATE POLICY "Doctors with access can view patient symptoms"
      ON public.symptom_sessions FOR SELECT
      USING (
        auth.uid() = user_id
        OR EXISTS (
          SELECT 1 FROM public.doctor_patient_access dpa
          WHERE dpa.doctor_id = auth.uid()
            AND dpa.patient_id = symptom_sessions.user_id
            AND dpa.is_active = true
            AND dpa.expires_at > NOW()
        )
      )';
  END IF;
END $$;

-- AI Results
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Doctors with access can view patient AI results'
  ) THEN
    EXECUTE 'CREATE POLICY "Doctors with access can view patient AI results"
      ON public.ai_results FOR SELECT
      USING (
        auth.uid() = user_id
        OR EXISTS (
          SELECT 1 FROM public.doctor_patient_access dpa
          WHERE dpa.doctor_id = auth.uid()
            AND dpa.patient_id = ai_results.user_id
            AND dpa.is_active = true
            AND dpa.expires_at > NOW()
        )
      )';
  END IF;
END $$;

-- Nutrition logs
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Doctors with access can view patient nutrition'
  ) THEN
    EXECUTE 'CREATE POLICY "Doctors with access can view patient nutrition"
      ON public.nutrition_logs FOR SELECT
      USING (
        auth.uid() = user_id
        OR EXISTS (
          SELECT 1 FROM public.doctor_patient_access dpa
          WHERE dpa.doctor_id = auth.uid()
            AND dpa.patient_id = nutrition_logs.user_id
            AND dpa.is_active = true
            AND dpa.expires_at > NOW()
        )
      )';
  END IF;
END $$;

-- Monitoring logs
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Doctors with access can view patient monitoring'
  ) THEN
    EXECUTE 'CREATE POLICY "Doctors with access can view patient monitoring"
      ON public.monitoring_logs FOR SELECT
      USING (
        auth.uid() = user_id
        OR EXISTS (
          SELECT 1 FROM public.doctor_patient_access dpa
          WHERE dpa.doctor_id = auth.uid()
            AND dpa.patient_id = monitoring_logs.user_id
            AND dpa.is_active = true
            AND dpa.expires_at > NOW()
        )
      )';
  END IF;
END $$;

-- Medication schedules
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Doctors with access can view patient medications'
  ) THEN
    EXECUTE 'CREATE POLICY "Doctors with access can view patient medications"
      ON public.medication_schedules FOR SELECT
      USING (
        auth.uid() = user_id
        OR EXISTS (
          SELECT 1 FROM public.doctor_patient_access dpa
          WHERE dpa.doctor_id = auth.uid()
            AND dpa.patient_id = medication_schedules.user_id
            AND dpa.is_active = true
            AND dpa.expires_at > NOW()
        )
      )';
  END IF;
END $$;

-- Vital readings
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Doctors with access can view patient vitals'
  ) THEN
    EXECUTE 'CREATE POLICY "Doctors with access can view patient vitals"
      ON public.vital_readings FOR SELECT
      USING (
        auth.uid() = user_id
        OR EXISTS (
          SELECT 1 FROM public.doctor_patient_access dpa
          WHERE dpa.doctor_id = auth.uid()
            AND dpa.patient_id = vital_readings.user_id
            AND dpa.is_active = true
            AND dpa.expires_at > NOW()
        )
      )';
  END IF;
END $$;

-- Health records
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Doctors with access can view patient health records'
  ) THEN
    EXECUTE 'CREATE POLICY "Doctors with access can view patient health records"
      ON public.health_records FOR SELECT
      USING (
        auth.uid() = user_id
        OR EXISTS (
          SELECT 1 FROM public.doctor_patient_access dpa
          WHERE dpa.doctor_id = auth.uid()
            AND dpa.patient_id = health_records.user_id
            AND dpa.is_active = true
            AND dpa.expires_at > NOW()
        )
      )';
  END IF;
END $$;

-- Health goals
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Doctors with access can view patient health goals'
  ) THEN
    EXECUTE 'CREATE POLICY "Doctors with access can view patient health goals"
      ON public.health_goals FOR SELECT
      USING (
        auth.uid() = user_id
        OR EXISTS (
          SELECT 1 FROM public.doctor_patient_access dpa
          WHERE dpa.doctor_id = auth.uid()
            AND dpa.patient_id = health_goals.user_id
            AND dpa.is_active = true
            AND dpa.expires_at > NOW()
        )
      )';
  END IF;
END $$;

-- Done!
-- Run this in your Supabase SQL Editor to enable cross-portal access.
