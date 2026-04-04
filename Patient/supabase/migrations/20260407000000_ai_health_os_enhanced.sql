-- ============================================================
-- MedAssist AI Health OS: Enhanced Schema Migration
-- Adds structured tables for medication schedules, vital baselines,
-- health goals, family history, vaccination records, and wearable
-- data to fully power the AI clinical engine.
-- ============================================================

-- ────────────────────────────────────────────────────────────────
-- 1. PROFILES: Add new AI-relevant columns
-- ────────────────────────────────────────────────────────────────
DO $$
BEGIN
    -- Primary language for AI communication
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='primary_language') THEN
        ALTER TABLE public.profiles ADD COLUMN primary_language TEXT DEFAULT 'en';
    END IF;

    -- Timezone for medication reminder scheduling
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='timezone') THEN
        ALTER TABLE public.profiles ADD COLUMN timezone TEXT DEFAULT 'Asia/Kolkata';
    END IF;

    -- Family medical history (genetic risk factors)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='family_medical_history') THEN
        ALTER TABLE public.profiles ADD COLUMN family_medical_history JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- Health goals set during onboarding or later
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='health_goals') THEN
        ALTER TABLE public.profiles ADD COLUMN health_goals JSONB DEFAULT '[]'::jsonb;
    END IF;

    -- AI personality preference (formal, friendly, concise, detailed)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='ai_tone_preference') THEN
        ALTER TABLE public.profiles ADD COLUMN ai_tone_preference TEXT DEFAULT 'friendly';
    END IF;

    -- Organ donor status
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='organ_donor') THEN
        ALTER TABLE public.profiles ADD COLUMN organ_donor BOOLEAN DEFAULT false;
    END IF;

    -- Advance directive on file
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='advance_directive') THEN
        ALTER TABLE public.profiles ADD COLUMN advance_directive BOOLEAN DEFAULT false;
    END IF;

    -- Menstrual / reproductive health tracking opt-in
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='menstrual_tracking') THEN
        ALTER TABLE public.profiles ADD COLUMN menstrual_tracking BOOLEAN DEFAULT false;
    END IF;

    -- Primary care physician name
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='primary_physician') THEN
        ALTER TABLE public.profiles ADD COLUMN primary_physician TEXT;
    END IF;

    -- Pharmacy preference
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='preferred_pharmacy') THEN
        ALTER TABLE public.profiles ADD COLUMN preferred_pharmacy TEXT;
    END IF;
END $$;


-- ────────────────────────────────────────────────────────────────
-- 2. MEDICATION SCHEDULES (Structured med reminders for AI)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.medication_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    medication_name TEXT NOT NULL,
    dosage TEXT NOT NULL,                          -- e.g. "500mg"
    frequency TEXT NOT NULL DEFAULT 'daily',       -- daily, twice_daily, weekly, as_needed
    times_of_day TEXT[] DEFAULT '{}',              -- e.g. {"08:00","20:00"}
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,                                 -- NULL = indefinite
    prescribing_doctor TEXT,
    purpose TEXT,                                   -- "blood pressure", "pain relief"
    side_effects TEXT[] DEFAULT '{}',
    interactions_checked BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    adherence_streak INTEGER DEFAULT 0,
    last_taken_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_med_schedules_user ON public.medication_schedules(user_id);
CREATE INDEX IF NOT EXISTS idx_med_schedules_active ON public.medication_schedules(user_id, is_active);


-- ────────────────────────────────────────────────────────────────
-- 3. MEDICATION LOGS (Individual dose tracking)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.medication_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    schedule_id UUID REFERENCES public.medication_schedules(id) ON DELETE SET NULL,
    medication_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'taken' CHECK (status IN ('taken', 'skipped', 'late', 'missed')),
    taken_at TIMESTAMPTZ DEFAULT now(),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_med_logs_user ON public.medication_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_med_logs_schedule ON public.medication_logs(schedule_id);


-- ────────────────────────────────────────────────────────────────
-- 4. VITAL BASELINES (Personal baseline HR, BP, SpO2, temp)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.vital_baselines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    metric_type TEXT NOT NULL,  -- heart_rate, blood_pressure_sys, blood_pressure_dia, spo2, temperature, respiratory_rate, blood_glucose
    baseline_value NUMERIC NOT NULL,
    unit TEXT NOT NULL,         -- bpm, mmHg, %, °C, breaths/min, mg/dL
    measured_at TIMESTAMPTZ DEFAULT now(),
    source TEXT DEFAULT 'manual', -- manual, wearable, lab
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_vital_baselines_user ON public.vital_baselines(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_vital_baselines_unique ON public.vital_baselines(user_id, metric_type);


-- ────────────────────────────────────────────────────────────────
-- 5. VITAL READINGS (Time-series vital sign data)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.vital_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    metric_type TEXT NOT NULL,
    value NUMERIC NOT NULL,
    unit TEXT NOT NULL,
    source TEXT DEFAULT 'manual',
    is_anomaly BOOLEAN DEFAULT false,  -- AI flags outliers
    session_id UUID REFERENCES public.symptom_sessions(id) ON DELETE SET NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_vital_readings_user ON public.vital_readings(user_id);
CREATE INDEX IF NOT EXISTS idx_vital_readings_time ON public.vital_readings(user_id, recorded_at DESC);


-- ────────────────────────────────────────────────────────────────
-- 6. HEALTH GOALS (Trackable patient goals for AI coaching)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.health_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    goal_type TEXT NOT NULL,      -- weight_loss, fitness, sleep, hydration, medication_adherence, stress_reduction, quit_smoking
    title TEXT NOT NULL,
    target_value NUMERIC,
    current_value NUMERIC DEFAULT 0,
    unit TEXT,                     -- kg, steps, hours, cups, %
    target_date DATE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'achieved', 'paused', 'abandoned')),
    ai_suggestions JSONB DEFAULT '[]'::jsonb,
    milestones JSONB DEFAULT '[]'::jsonb,  -- [{value: 5, reached_at: "..."}]
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_health_goals_user ON public.health_goals(user_id);


-- ────────────────────────────────────────────────────────────────
-- 7. VACCINATION RECORDS
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.vaccination_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vaccine_name TEXT NOT NULL,
    dose_number INTEGER DEFAULT 1,
    administered_date DATE,
    next_dose_date DATE,
    provider TEXT,
    lot_number TEXT,
    document_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_vaccination_user ON public.vaccination_records(user_id);


-- ────────────────────────────────────────────────────────────────
-- 8. WEARABLE SYNC DATA (Aggregated daily wearable metrics)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.wearable_daily_sync (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    sync_date DATE NOT NULL DEFAULT CURRENT_DATE,
    steps INTEGER DEFAULT 0,
    distance_m INTEGER DEFAULT 0,
    calories_burned INTEGER DEFAULT 0,
    active_minutes INTEGER DEFAULT 0,
    resting_heart_rate INTEGER,
    avg_heart_rate INTEGER,
    max_heart_rate INTEGER,
    hrv_ms INTEGER,                    -- heart rate variability
    spo2_avg NUMERIC,
    sleep_duration_min INTEGER,
    deep_sleep_min INTEGER,
    rem_sleep_min INTEGER,
    light_sleep_min INTEGER,
    stress_score INTEGER,              -- 0-100 from wearable
    body_battery INTEGER,              -- Garmin-style energy score
    skin_temp_delta NUMERIC,
    source TEXT DEFAULT 'health_connect', -- health_connect, apple_health, fitbit, garmin
    raw_data JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, sync_date)
);

CREATE INDEX IF NOT EXISTS idx_wearable_daily_user ON public.wearable_daily_sync(user_id, sync_date DESC);


-- ────────────────────────────────────────────────────────────────
-- 9. AI CLINICAL CONTEXT (Per-session context snapshots for AI)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ai_clinical_context (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.symptom_sessions(id) ON DELETE CASCADE,
    context_snapshot JSONB NOT NULL DEFAULT '{}'::jsonb,
    -- Snapshot includes: current_meds, allergies, vitals, recent_symptoms, lifestyle, goals
    -- This is what gets injected into the AI system prompt for each session
    ai_model_used TEXT,
    token_count INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_context_session ON public.ai_clinical_context(session_id);
CREATE INDEX IF NOT EXISTS idx_ai_context_user ON public.ai_clinical_context(user_id);


-- ────────────────────────────────────────────────────────────────
-- 10. TRIGGERS
-- ────────────────────────────────────────────────────────────────
CREATE OR REPLACE TRIGGER update_med_schedules_modtime
    BEFORE UPDATE ON public.medication_schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER update_vital_baselines_modtime
    BEFORE UPDATE ON public.vital_baselines
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER update_health_goals_modtime
    BEFORE UPDATE ON public.health_goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER update_wearable_daily_modtime
    BEFORE UPDATE ON public.wearable_daily_sync
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ────────────────────────────────────────────────────────────────
-- 11. ROW LEVEL SECURITY
-- ────────────────────────────────────────────────────────────────
ALTER TABLE public.medication_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medication_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vital_baselines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vital_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vaccination_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wearable_daily_sync ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_clinical_context ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users manage own medication_schedules" ON public.medication_schedules FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users manage own medication_logs" ON public.medication_logs FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users manage own vital_baselines" ON public.vital_baselines FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users manage own vital_readings" ON public.vital_readings FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users manage own health_goals" ON public.health_goals FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users manage own vaccination_records" ON public.vaccination_records FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users manage own wearable_daily_sync" ON public.wearable_daily_sync FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users manage own ai_clinical_context" ON public.ai_clinical_context FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);


-- ────────────────────────────────────────────────────────────────
-- 12. UTILITY RPC: Build AI Clinical Context Snapshot
-- Returns a JSONB blob of everything the AI needs for a session
-- ────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.build_clinical_context(p_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profile RECORD;
    v_meds JSONB;
    v_vitals JSONB;
    v_goals JSONB;
    v_wearable JSONB;
    v_result JSONB;
BEGIN
    -- Profile snapshot
    SELECT * INTO v_profile FROM public.profiles WHERE id = p_user_id;

    -- Active medications
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'name', medication_name,
        'dosage', dosage,
        'frequency', frequency,
        'purpose', purpose
    )), '[]'::jsonb) INTO v_meds
    FROM public.medication_schedules
    WHERE user_id = p_user_id AND is_active = true;

    -- Latest vital baselines
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'type', metric_type,
        'value', baseline_value,
        'unit', unit
    )), '[]'::jsonb) INTO v_vitals
    FROM public.vital_baselines
    WHERE user_id = p_user_id;

    -- Active health goals
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'type', goal_type,
        'title', title,
        'target', target_value,
        'current', current_value,
        'unit', unit
    )), '[]'::jsonb) INTO v_goals
    FROM public.health_goals
    WHERE user_id = p_user_id AND status = 'active';

    -- Latest wearable sync
    SELECT COALESCE(to_jsonb(w.*), '{}'::jsonb) INTO v_wearable
    FROM public.wearable_daily_sync w
    WHERE w.user_id = p_user_id
    ORDER BY w.sync_date DESC LIMIT 1;

    -- Assemble context
    v_result := jsonb_build_object(
        'patient_name', v_profile.name,
        'age', v_profile.age,
        'gender', v_profile.gender,
        'blood_group', v_profile.blood_group,
        'bmi', CASE WHEN v_profile.height_cm > 0 AND v_profile.weight_kg > 0
            THEN ROUND((v_profile.weight_kg / ((v_profile.height_cm / 100.0) ^ 2))::numeric, 1)
            ELSE NULL END,
        'allergies', COALESCE(to_jsonb(v_profile.allergies), '[]'::jsonb),
        'chronic_conditions', COALESCE(to_jsonb(v_profile.chronic_conditions), '[]'::jsonb),
        'lifestyle', jsonb_build_object(
            'smoking', v_profile.smoking_status,
            'alcohol', v_profile.alcohol_frequency,
            'sleep_avg', v_profile.sleep_hours_avg,
            'stress', v_profile.stress_level,
            'activity', v_profile.activity_level,
            'diet', v_profile.diet_type
        ),
        'active_medications', v_meds,
        'vital_baselines', v_vitals,
        'health_goals', v_goals,
        'latest_wearable', v_wearable,
        'family_history', COALESCE(v_profile.family_medical_history, '[]'::jsonb),
        'ai_tone', COALESCE(v_profile.ai_tone_preference, 'friendly'),
        'context_built_at', now()
    );

    RETURN v_result;
END;
$$;
