-- ============================================================
-- MedAssist AI: Clinical Intelligence Orchestrator v2 Schema
-- Migration: triage_v2
-- ============================================================

-- 1. New table: monitoring_tasks (AI-seeded monitoring plans)
CREATE TABLE IF NOT EXISTS public.monitoring_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.symptom_sessions(id) ON DELETE SET NULL,
    track_for_days INTEGER DEFAULT 5,
    focus_metrics JSONB DEFAULT '[]'::jsonb,
    red_flags JSONB DEFAULT '[]'::jsonb,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'expired')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_monitoring_tasks_user ON public.monitoring_tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_monitoring_tasks_status ON public.monitoring_tasks(status);
CREATE INDEX IF NOT EXISTS idx_monitoring_tasks_created ON public.monitoring_tasks(created_at DESC);

ALTER TABLE public.monitoring_tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own monitoring tasks" ON public.monitoring_tasks
    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 2. New table: emergency_events (Emergency escalation log)
CREATE TABLE IF NOT EXISTS public.emergency_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.symptom_sessions(id) ON DELETE SET NULL,
    trigger_keywords TEXT[] DEFAULT '{}',
    risk_score INTEGER DEFAULT 90,
    ai_response JSONB DEFAULT '{}'::jsonb,
    resolved BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_emergency_user ON public.emergency_events(user_id);
CREATE INDEX IF NOT EXISTS idx_emergency_created ON public.emergency_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_emergency_resolved ON public.emergency_events(resolved);

ALTER TABLE public.emergency_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own emergency events" ON public.emergency_events
    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 3. New table: doctor_handoffs (AI-generated doctor briefings)
CREATE TABLE IF NOT EXISTS public.doctor_handoffs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES public.symptom_sessions(id) ON DELETE SET NULL,
    summary TEXT,
    urgency TEXT DEFAULT 'routine' CHECK (urgency IN ('routine', 'priority', 'urgent', 'emergency')),
    recommended_tests JSONB DEFAULT '[]'::jsonb,
    specialization TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_handoffs_user ON public.doctor_handoffs(user_id);
CREATE INDEX IF NOT EXISTS idx_handoffs_created ON public.doctor_handoffs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_handoffs_urgency ON public.doctor_handoffs(urgency);

ALTER TABLE public.doctor_handoffs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own doctor handoffs" ON public.doctor_handoffs
    FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 4. Extend ai_results with v2 fields
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ai_results' AND column_name='risk_score') THEN
        ALTER TABLE public.ai_results ADD COLUMN risk_score INTEGER;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ai_results' AND column_name='monitoring_plan') THEN
        ALTER TABLE public.ai_results ADD COLUMN monitoring_plan JSONB DEFAULT '{}'::jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ai_results' AND column_name='doctor_handoff') THEN
        ALTER TABLE public.ai_results ADD COLUMN doctor_handoff JSONB DEFAULT '{}'::jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ai_results' AND column_name='confidence_reasoning') THEN
        ALTER TABLE public.ai_results ADD COLUMN confidence_reasoning JSONB DEFAULT '[]'::jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ai_results' AND column_name='prescription_hints') THEN
        ALTER TABLE public.ai_results ADD COLUMN prescription_hints JSONB DEFAULT '[]'::jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ai_results' AND column_name='specialization') THEN
        ALTER TABLE public.ai_results ADD COLUMN specialization TEXT;
    END IF;
END $$;

-- Additional performance indexes on existing tables
CREATE INDEX IF NOT EXISTS idx_ai_results_created ON public.ai_results(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_created ON public.symptom_sessions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_severity ON public.symptom_sessions(severity);
CREATE INDEX IF NOT EXISTS idx_nutrition_created ON public.nutrition_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_monitoring_created ON public.monitoring_logs(created_at DESC);
