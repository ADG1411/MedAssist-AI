-- Add missing log_date column to nutrition_logs
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='nutrition_logs' AND column_name='log_date') THEN
        ALTER TABLE public.nutrition_logs ADD COLUMN log_date DATE DEFAULT CURRENT_DATE;
    END IF;
END $$;
CREATE INDEX IF NOT EXISTS idx_nutrition_log_date ON public.nutrition_logs(log_date);

-- Recreate Physical Activity Logs
CREATE TABLE IF NOT EXISTS public.physical_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    log_date DATE NOT NULL DEFAULT CURRENT_DATE,
    activity_code TEXT,
    activity_name TEXT NOT NULL,
    duration_min INTEGER NOT NULL,
    calories_burned NUMERIC NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.physical_activity_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own activity" ON public.physical_activity_logs;
CREATE POLICY "Users manage own activity" ON public.physical_activity_logs FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_activity_user_date ON public.physical_activity_logs(user_id, log_date);

-- Create Upsert RPC for Daily Summaries
CREATE OR REPLACE FUNCTION upsert_nutrition_summary(
    p_user_id UUID,
    p_date DATE,
    p_calories NUMERIC,
    p_carbs NUMERIC,
    p_fat NUMERIC,
    p_protein NUMERIC,
    p_activity_burn NUMERIC DEFAULT 0
) RETURNS VOID AS $$
BEGIN
    INSERT INTO public.nutrition_daily_summary (
        user_id, summary_date, 
        calories_logged, carbs_logged, fat_logged, protein_logged, activity_burn_logged,
        calorie_goal, carbs_goal, fat_goal, protein_goal
    )
    VALUES (
        p_user_id, p_date,
        p_calories, p_carbs, p_fat, p_protein, p_activity_burn,
        2000, 250, 65, 50
    )
    ON CONFLICT (user_id, summary_date) DO UPDATE SET
        calories_logged = nutrition_daily_summary.calories_logged + EXCLUDED.calories_logged,
        carbs_logged = nutrition_daily_summary.carbs_logged + EXCLUDED.carbs_logged,
        fat_logged = nutrition_daily_summary.fat_logged + EXCLUDED.fat_logged,
        protein_logged = nutrition_daily_summary.protein_logged + EXCLUDED.protein_logged,
        activity_burn_logged = nutrition_daily_summary.activity_burn_logged + EXCLUDED.activity_burn_logged,
        updated_at = now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
