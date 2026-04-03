-- MedAssist AI: Initial Supabase PostgreSQL Schema Migration
-- Generated for full Riverpod Repository backend transition.

-- ==========================================
-- 1. EXTENSIONS
-- ==========================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";

-- ==========================================
-- 2. GLOBAL TRIGGER FUNCTION
-- ==========================================
-- Automatically updates updated_at column on row modification
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ==========================================
-- 3. TABLES DEFINITION (With Auto-Cleanup for easy re-runs)
-- ==========================================

DROP TABLE IF EXISTS public.embeddings CASCADE;
DROP TABLE IF EXISTS public.health_records CASCADE;
DROP TABLE IF EXISTS public.tickets CASCADE;
DROP TABLE IF EXISTS public.recovery_predictions CASCADE;
DROP TABLE IF EXISTS public.monitoring_logs CASCADE;
DROP TABLE IF EXISTS public.nutrition_logs CASCADE;
DROP TABLE IF EXISTS public.ai_results CASCADE;
DROP TABLE IF EXISTS public.symptom_messages CASCADE;
DROP TABLE IF EXISTS public.symptom_sessions CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- 1. profiles
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
    avatar_url TEXT,
    allergies TEXT[] DEFAULT '{}',
    chronic_conditions TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. symptom_sessions
CREATE TABLE public.symptom_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    body_region TEXT,
    severity INTEGER CHECK (severity >= 1 AND severity <= 10),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'escalated')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. symptom_messages
CREATE TABLE public.symptom_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.symptom_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'ai')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. ai_results
CREATE TABLE public.ai_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.symptom_sessions(id) ON DELETE SET NULL,
    conditions JSONB NOT NULL DEFAULT '[]', -- e.g., [{"name": "Migraine", "confidence": 85, "risk": "Medium"}]
    risk_level TEXT,
    recommended_action TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. nutrition_logs
CREATE TABLE public.nutrition_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    food_name TEXT NOT NULL,
    calories INTEGER,
    sodium_mg INTEGER,
    meal_type TEXT,
    is_safe BOOLEAN DEFAULT true,
    recovery_impact TEXT,
    reason TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. monitoring_logs
CREATE TABLE public.monitoring_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    hydration_cups INTEGER DEFAULT 0 CHECK (hydration_cups >= 0 AND hydration_cups <= 8),
    sleep_hours NUMERIC DEFAULT 0,
    symptom_severity NUMERIC DEFAULT 0, -- 1-10
    mood TEXT,
    quick_status TEXT,
    logged_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, logged_date) -- Ensure only one daily check-in per user
);

-- 7. recovery_predictions
CREATE TABLE public.recovery_predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    current_score INTEGER DEFAULT 0,
    predicted_days_to_recovery INTEGER,
    confidence NUMERIC,
    trend_data JSONB DEFAULT '[]', -- Array of recent pain scores
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 8. tickets
CREATE TABLE public.tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    symptom_case TEXT NOT NULL,
    urgency TEXT CHECK (urgency IN ('Low', 'Medium', 'High', 'Critical')),
    status TEXT DEFAULT 'Open' CHECK (status IN ('Open', 'In Progress', 'Resolved', 'Closed')),
    doctor_assigned TEXT,
    department TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 9. health_records
CREATE TABLE public.health_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    record_type TEXT CHECK (record_type IN ('AI Result', 'Prescription', 'Lab Report', 'Imaging')),
    file_url TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 10. embeddings (Mini-RAG Knowledge Base + User Memory)
CREATE TABLE public.embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- Null specifies global KB, UUID specifies personal memory
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    embedding vector(1024) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==========================================
-- 4. APPLY UPDATED_AT TRIGGERS
-- ==========================================
CREATE TRIGGER update_profiles_modtime BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sessions_modtime BEFORE UPDATE ON public.symptom_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_nutrition_modtime BEFORE UPDATE ON public.nutrition_logs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_predictions_modtime BEFORE UPDATE ON public.recovery_predictions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tickets_modtime BEFORE UPDATE ON public.tickets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- 5. INDEXES (Performance & Vector Similarity)
-- ==========================================
CREATE INDEX idx_profiles_user ON public.profiles(id);
CREATE INDEX idx_sessions_user ON public.symptom_sessions(user_id);
CREATE INDEX idx_messages_session ON public.symptom_messages(session_id);
CREATE INDEX idx_ai_results_user ON public.ai_results(user_id);
CREATE INDEX idx_nutrition_user ON public.nutrition_logs(user_id);
CREATE INDEX idx_monitoring_user_date ON public.monitoring_logs(user_id, logged_date);
CREATE INDEX idx_tickets_user ON public.tickets(user_id);
CREATE INDEX idx_records_user ON public.health_records(user_id);

-- HNSW Index for rapid vector similarity searches over the 1024 dimension embedding
CREATE INDEX idx_embeddings_vector ON public.embeddings USING hnsw (embedding vector_cosine_ops);
CREATE INDEX idx_embeddings_user ON public.embeddings(user_id);

-- ==========================================
-- 6. ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.symptom_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.symptom_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nutrition_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monitoring_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recovery_predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.embeddings ENABLE ROW LEVEL SECURITY;

-- Boilerplate RLS: Users can only select/insert/update/delete their own rows.
-- PROFILES
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- SESSIONS
CREATE POLICY "Users can manage own sessions" ON public.symptom_sessions FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- MESSAGES
CREATE POLICY "Users can manage own messages" ON public.symptom_messages FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- AI RESULTS
CREATE POLICY "Users can manage own ai results" ON public.ai_results FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- NUTRITION
CREATE POLICY "Users can manage own nutrition" ON public.nutrition_logs FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- MONITORING
CREATE POLICY "Users can manage own monitoring" ON public.monitoring_logs FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- RECOVERY PREDICTIONS
CREATE POLICY "Users can manage own predictions" ON public.recovery_predictions FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- TICKETS
CREATE POLICY "Users can manage own tickets" ON public.tickets FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- RECORDS
CREATE POLICY "Users can manage own records" ON public.health_records FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- EMBEDDINGS (Mini-RAG)
-- Users can view global KB (user_id IS NULL) OR their own personal memory (user_id = auth.uid())
CREATE POLICY "Users can view global and own embeddings" ON public.embeddings FOR SELECT USING (user_id IS NULL OR auth.uid() = user_id);
-- Users can only insert/delete their own embeddings
CREATE POLICY "Users can insert own embeddings" ON public.embeddings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own embeddings" ON public.embeddings FOR DELETE USING (auth.uid() = user_id);
