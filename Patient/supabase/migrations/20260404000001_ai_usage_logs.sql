-- ============================================================
-- MedAssist AI: AI Usage Logs Schema
-- ============================================================

CREATE TABLE IF NOT EXISTS public.ai_usage_logs (
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

-- Performance index
CREATE INDEX IF NOT EXISTS idx_ai_usage_user ON public.ai_usage_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_usage_created ON public.ai_usage_logs(created_at DESC);

-- RLS
ALTER TABLE public.ai_usage_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert own usage logs" ON public.ai_usage_logs FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view own usage logs" ON public.ai_usage_logs FOR SELECT USING (auth.uid() = user_id);
