-- Supabase Migration: Physical Activity Logging

CREATE TABLE IF NOT EXISTS public.physical_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    activity_code TEXT NOT NULL,
    activity_name TEXT NOT NULL,
    duration_min FLOAT NOT NULL,
    calories_burned FLOAT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Policies for physical_activity_logs
ALTER TABLE public.physical_activity_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own activity logs"
    ON public.physical_activity_logs
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Add updated_at trigger
CREATE TRIGGER update_activity_logs_modtime BEFORE UPDATE ON public.physical_activity_logs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update daily summary to track burn
ALTER TABLE public.nutrition_daily_summary ADD COLUMN IF NOT EXISTS activity_burn_logged FLOAT DEFAULT 0;

-- Update the UPSERT RPC to properly handle burn aggregation
CREATE OR REPLACE FUNCTION public.upsert_nutrition_summary(
    p_user_id UUID,
    p_date DATE,
    p_calories FLOAT,
    p_carbs FLOAT,
    p_fat FLOAT,
    p_protein FLOAT,
    p_activity_burn FLOAT DEFAULT 0
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.nutrition_daily_summary 
        (user_id, summary_date, calories_logged, carbs_logged, fat_logged, protein_logged, activity_burn_logged)
    VALUES 
        (p_user_id, p_date, p_calories, p_carbs, p_fat, p_protein, p_activity_burn)
    ON CONFLICT (user_id, summary_date) DO UPDATE SET
        calories_logged = public.nutrition_daily_summary.calories_logged + EXCLUDED.calories_logged,
        carbs_logged = public.nutrition_daily_summary.carbs_logged + EXCLUDED.carbs_logged,
        fat_logged = public.nutrition_daily_summary.fat_logged + EXCLUDED.fat_logged,
        protein_logged = public.nutrition_daily_summary.protein_logged + EXCLUDED.protein_logged,
        activity_burn_logged = public.nutrition_daily_summary.activity_burn_logged + EXCLUDED.activity_burn_logged;
END;
$$;
