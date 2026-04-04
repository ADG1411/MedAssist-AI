-- ============================================================
-- MedAssist AI: Doctor Portal → Patient Portal RLS Fix
-- Run this in your Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================

-- 1. Allow all authenticated patients to read VERIFIED doctor profiles
--    (doctors_live VIEW already filters: completion_percent > 0 AND not rejected)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE policyname = 'Patients can view verified doctor profiles'
      AND tablename = 'doctor_profiles'
  ) THEN
    EXECUTE '
      CREATE POLICY "Patients can view verified doctor profiles"
        ON public.doctor_profiles FOR SELECT
        USING (
          verification_status != ''rejected''
          AND completion_percent > 0
          AND overview->>''full_name'' IS NOT NULL
          AND overview->>''full_name'' != ''''
        )
    ';
  END IF;
END $$;

-- 2. Grant SELECT on the doctors_live VIEW to all authenticated users + anon
--    (The VIEW itself has the WHERE filters so only complete, non-rejected profiles show)
GRANT SELECT ON public.doctors_live TO authenticated;
GRANT SELECT ON public.doctors_live TO anon;

-- 3. Also allow anon/authenticated on doctor_profiles directly
--    (Needed if the VIEW doesn't have SECURITY INVOKER set)
GRANT SELECT ON public.doctor_profiles TO authenticated;

-- Done! Doctors who complete their profile in the Doctor Portal
-- will now appear in the Patient app's Find a Doctor screen.
-- ============================================================
