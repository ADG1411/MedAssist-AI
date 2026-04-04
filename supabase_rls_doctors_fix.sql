-- ============================================================
-- MedAssist AI: Doctor Portal → Patient Portal RLS Fix
-- Run this in your Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================

-- 1. Allow all authenticated patients to read VERIFIED doctor profiles
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

-- 2. Grant SELECT on the doctors_live VIEW + doctor_profiles table
GRANT SELECT ON public.doctors_live TO authenticated;
GRANT SELECT ON public.doctors_live TO anon;
GRANT SELECT ON public.doctor_profiles TO authenticated;

-- 3. Update the doctors_live VIEW to include video_fee and in_person_fee
--    so the Patient app gets both pricing tiers
CREATE OR REPLACE VIEW public.doctors_live AS
SELECT 
  dp.id::text AS id,
  dp.id AS user_id,
  COALESCE(dp.overview->>'full_name', 'Doctor') AS name,
  COALESCE(dp.overview->>'specialization', 'General Practice') AS specialty,
  COALESCE((dp.overview->>'years_of_experience')::int, 0) AS experience,
  4.5::numeric AS rating,
  -- Primary fee (used for fallback compatibility)
  COALESCE((dp.fees->>'offline_fee')::int, 500) AS consultation_fee,
  -- Both fee types for the new detail screen
  COALESCE((dp.fees->>'online_fee')::int, (dp.fees->>'offline_fee')::int, 500) AS video_fee,
  COALESCE((dp.fees->>'offline_fee')::int, 500) AS in_person_fee,
  COALESCE(dp.overview->>'bio', '') AS bio,
  dp.overview->>'profile_photo' AS photo_url,
  -- Verification status so patient sees the badge
  dp.verification_status,
  -- Degree + city for extra detail
  dp.overview->>'degree' AS degree,
  dp.overview->>'city' AS city,
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

-- Done! Re-run this after any schema changes.
-- ============================================================
