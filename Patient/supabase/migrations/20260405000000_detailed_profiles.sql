-- ============================================================
-- MedAssist AI: Detailed Profiles Extension
-- Extends the `profiles` table to store advanced onboarding data
-- ============================================================

-- Add new columns dynamically if they don't already exist
DO $$ 
BEGIN 
    -- 1. Date of Birth
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='date_of_birth') THEN
        ALTER TABLE public.profiles ADD COLUMN date_of_birth DATE;
    END IF;

    -- 2. Medical History
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='current_medications') THEN
        ALTER TABLE public.profiles ADD COLUMN current_medications TEXT[] DEFAULT '{}';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='past_surgeries') THEN
        ALTER TABLE public.profiles ADD COLUMN past_surgeries TEXT[] DEFAULT '{}';
    END IF;

    -- 3. Lifestyle Data
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='smoking_status') THEN
        ALTER TABLE public.profiles ADD COLUMN smoking_status TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='alcohol_frequency') THEN
        ALTER TABLE public.profiles ADD COLUMN alcohol_frequency TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='sleep_hours_avg') THEN
        ALTER TABLE public.profiles ADD COLUMN sleep_hours_avg NUMERIC;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='stress_level') THEN
        ALTER TABLE public.profiles ADD COLUMN stress_level TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='activity_level') THEN
        ALTER TABLE public.profiles ADD COLUMN activity_level TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='diet_type') THEN
        ALTER TABLE public.profiles ADD COLUMN diet_type TEXT;
    END IF;

    -- 4. Emergency/SOS Data
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='emergency_contacts') THEN
        ALTER TABLE public.profiles ADD COLUMN emergency_contacts JSONB DEFAULT '[]'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='preferred_hospitals') THEN
        ALTER TABLE public.profiles ADD COLUMN preferred_hospitals JSONB DEFAULT '[]'::jsonb;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='insurance_provider') THEN
        ALTER TABLE public.profiles ADD COLUMN insurance_provider TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='insurance_id') THEN
        ALTER TABLE public.profiles ADD COLUMN insurance_id TEXT;
    END IF;

    -- 5. Permissions & Status
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='wearable_permission') THEN
        ALTER TABLE public.profiles ADD COLUMN wearable_permission BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='notification_permission') THEN
        ALTER TABLE public.profiles ADD COLUMN notification_permission BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='location_permission') THEN
        ALTER TABLE public.profiles ADD COLUMN location_permission BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='onboarding_completed') THEN
        ALTER TABLE public.profiles ADD COLUMN onboarding_completed BOOLEAN DEFAULT false;
    END IF;
END $$;
