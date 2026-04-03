-- ============================================================
-- MedAssist AI: Core Tables RLS Policies
-- Grants users permission to manage their own specific data securely
-- ============================================================

-- 1. Symptom Sessions
ALTER TABLE public.symptom_sessions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own symptom_sessions" ON public.symptom_sessions;
CREATE POLICY "Users can manage own symptom_sessions" ON public.symptom_sessions FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 2. Symptom Messages
ALTER TABLE public.symptom_messages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own symptom_messages" ON public.symptom_messages;
CREATE POLICY "Users can manage own symptom_messages" ON public.symptom_messages FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 3. AI Results
ALTER TABLE public.ai_results ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own ai_results" ON public.ai_results;
CREATE POLICY "Users can manage own ai_results" ON public.ai_results FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 4. Health Records
ALTER TABLE public.health_records ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own health_records" ON public.health_records;
CREATE POLICY "Users can manage own health_records" ON public.health_records FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 5. Nutrition Logs
ALTER TABLE public.nutrition_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own nutrition_logs" ON public.nutrition_logs;
CREATE POLICY "Users can manage own nutrition_logs" ON public.nutrition_logs FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 6. Nutrition Daily Summary
ALTER TABLE public.nutrition_daily_summary ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own nutrition_daily_summary" ON public.nutrition_daily_summary;
CREATE POLICY "Users can manage own nutrition_daily_summary" ON public.nutrition_daily_summary FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 7. Monitoring Logs
ALTER TABLE public.monitoring_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own monitoring_logs" ON public.monitoring_logs;
CREATE POLICY "Users can manage own monitoring_logs" ON public.monitoring_logs FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 8. Embeddings
ALTER TABLE public.embeddings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own embeddings" ON public.embeddings;
CREATE POLICY "Users can manage own embeddings" ON public.embeddings FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 9. AI Usage Logs
ALTER TABLE public.ai_usage_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own ai_usage_logs" ON public.ai_usage_logs;
CREATE POLICY "Users can manage own ai_usage_logs" ON public.ai_usage_logs FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
