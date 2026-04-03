-- ============================================================
-- MedAssist AI: Unified Master Schema V2 [Definitive]
-- Run this to cleanly initialize or reset your database 
-- with all Advanced Intelligence, Nutrition, and Profile features.
-- ============================================================

-- EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";

-- AUTO-UPDATE TRIGGER FUNCTION
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- CLEAN SWEEP (Drops all existing tables to allow clean reset)
DROP TABLE IF EXISTS public.embeddings CASCADE;
DROP TABLE IF EXISTS public.health_records CASCADE;
DROP TABLE IF EXISTS public.tickets CASCADE;
DROP TABLE IF EXISTS public.recovery_predictions CASCADE;
DROP TABLE IF EXISTS public.monitoring_logs CASCADE;
DROP TABLE IF EXISTS public.nutrition_logs CASCADE;
DROP TABLE IF EXISTS public.nutrition_daily_summary CASCADE;
DROP TABLE IF EXISTS public.ai_usage_logs CASCADE;
DROP TABLE IF EXISTS public.ai_results CASCADE;
DROP TABLE IF EXISTS public.symptom_messages CASCADE;
DROP TABLE IF EXISTS public.symptom_sessions CASCADE;
DROP TABLE IF EXISTS public.emergency_events CASCADE;
DROP TABLE IF EXISTS public.monitoring_tasks CASCADE;
DROP TABLE IF EXISTS public.doctor_handoffs CASCADE;
DROP TABLE IF EXISTS public.bookings CASCADE;
DROP TABLE IF EXISTS public.doctors CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- ============================================================
-- 1. DETAILED PROFILES
-- ============================================================
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    gender TEXT,
    blood_group TEXT,
    age INTEGER,
    height_cm NUMERIC,
    weight_kg NUMERIC,
    date_of_birth DATE,
    avatar_url TEXT,
    
    -- Medical History
    allergies TEXT[] DEFAULT '{}',
    chronic_conditions TEXT[] DEFAULT '{}',
    current_medications TEXT[] DEFAULT '{}',
    past_surgeries TEXT[] DEFAULT '{}',
    
    -- Lifestyle
    smoking_status TEXT,
    alcohol_frequency TEXT,
    sleep_hours_avg NUMERIC,
    stress_level TEXT,
    activity_level TEXT,
    diet_type TEXT,
    
    -- Emergency / SOS
    emergency_contacts JSONB DEFAULT '[]'::jsonb,
    preferred_hospitals JSONB DEFAULT '[]'::jsonb,
    insurance_provider TEXT,
    insurance_id TEXT,
    
    -- Permissions & State
    wearable_permission BOOLEAN DEFAULT false,
    notification_permission BOOLEAN DEFAULT false,
    location_permission BOOLEAN DEFAULT false,
    onboarding_completed BOOLEAN DEFAULT false,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 2. CLINICAL INTELLIGENCE CORE
-- ============================================================
CREATE TABLE public.symptom_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    body_region TEXT,
    severity INTEGER CHECK (severity >= 1 AND severity <= 10),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'escalated')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.symptom_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.symptom_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'ai')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.ai_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.symptom_sessions(id) ON DELETE SET NULL,
    conditions JSONB NOT NULL DEFAULT '[]', 
    risk_level TEXT,
    risk_score INTEGER DEFAULT 0,
    recommended_action TEXT,
    monitoring_plan JSONB DEFAULT '{}'::jsonb,
    doctor_handoff JSONB DEFAULT '{}'::jsonb,
    confidence_reasoning JSONB DEFAULT '[]'::jsonb,
    prescription_hints JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 3. NUTRITION & LIFESTYLE
-- ============================================================
CREATE TABLE public.nutrition_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    food_name TEXT NOT NULL,
    calories INTEGER,
    carbs_g INTEGER,
    protein_g INTEGER,
    fat_g INTEGER,
    sodium_mg INTEGER,
    meal_type TEXT,
    is_safe BOOLEAN DEFAULT true,
    recovery_impact TEXT,
    reason TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.nutrition_daily_summary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    summary_date DATE NOT NULL DEFAULT CURRENT_DATE,
    calories_logged INTEGER DEFAULT 0,
    calorie_goal INTEGER DEFAULT 2000,
    carbs_logged INTEGER DEFAULT 0,
    carbs_goal INTEGER DEFAULT 250,
    protein_logged INTEGER DEFAULT 0,
    protein_goal INTEGER DEFAULT 50,
    fat_logged INTEGER DEFAULT 0,
    fat_goal INTEGER DEFAULT 65,
    hydration_cups INTEGER DEFAULT 0,
    activity_burn_logged INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, summary_date)
);

CREATE TABLE public.monitoring_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    hydration_cups INTEGER DEFAULT 0 CHECK (hydration_cups >= 0 AND hydration_cups <= 8),
    sleep_hours NUMERIC DEFAULT 0,
    symptom_severity NUMERIC DEFAULT 0,
    mood TEXT,
    quick_status TEXT,
    logged_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, logged_date)
);

-- ============================================================
-- 4. EMERGENCY & MONITORING WORKFLOW
-- ============================================================
CREATE TABLE public.emergency_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.symptom_sessions(id),
    trigger_reason TEXT NOT NULL,
    escalated_to_sos BOOLEAN DEFAULT false,
    resolved BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.monitoring_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.symptom_sessions(id),
    metric_name TEXT NOT NULL,
    target_value TEXT,
    due_date TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'missed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 5. TELEMEDICINE / DOCTOR NETWORK
-- ============================================================
CREATE TABLE public.doctors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id), 
    name TEXT NOT NULL,
    specialty TEXT NOT NULL,
    experience INTEGER DEFAULT 0,
    rating NUMERIC DEFAULT 5.0,
    consultation_fee INTEGER NOT NULL,
    bio TEXT,
    photo_url TEXT,
    available_slots JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES auth.users(id) NOT NULL,
    doctor_id UUID REFERENCES public.doctors(id) NOT NULL,
    slot_time TEXT NOT NULL,
    amount INTEGER NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    razorpay_order_id TEXT,
    razorpay_payment_id TEXT,
    telemedicine_link TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.doctor_handoffs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.symptom_sessions(id),
    ai_summary TEXT NOT NULL,
    suggested_specialty TEXT NOT NULL,
    patient_accepted BOOLEAN DEFAULT false,
    assigned_doctor_id UUID REFERENCES public.doctors(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 6. ANALYTICS & RECORDS (RAG)
-- ============================================================
CREATE TABLE public.ai_usage_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    function_name TEXT NOT NULL,
    model_name TEXT,
    prompt_tokens INTEGER,
    completion_tokens INTEGER,
    latency_ms INTEGER,
    cost_estimate NUMERIC,
    status TEXT DEFAULT 'success',
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.health_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    record_type TEXT CHECK (record_type IN ('AI Result', 'Prescription', 'Lab Report', 'Imaging')),
    file_url TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, 
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    embedding vector(1024) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 7. TRIGGERS & RLS & INDEXES
-- ============================================================
CREATE TRIGGER update_profiles_modtime BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sessions_modtime BEFORE UPDATE ON public.symptom_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_nutrition_modtime BEFORE UPDATE ON public.nutrition_logs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_nutrition_daily_modtime BEFORE UPDATE ON public.nutrition_daily_summary FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_doctors_modtime BEFORE UPDATE ON public.doctors FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bookings_modtime BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX idx_profiles_user ON public.profiles(id);
CREATE INDEX idx_sessions_user ON public.symptom_sessions(user_id);
CREATE INDEX idx_messages_session ON public.symptom_messages(session_id);
CREATE INDEX idx_ai_results_user ON public.ai_results(user_id);
CREATE INDEX idx_nutrition_user ON public.nutrition_logs(user_id);
CREATE INDEX idx_monitoring_user_date ON public.monitoring_logs(user_id, logged_date);
CREATE INDEX idx_embeddings_vector ON public.embeddings USING hnsw (embedding vector_cosine_ops);
