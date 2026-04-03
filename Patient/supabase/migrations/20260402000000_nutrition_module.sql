-- Supabase Migration: Nutrition Module (OpenNutriTracker Port)

-- 1. Daily food diary logs (IntakeEntry mapping)
CREATE TABLE IF NOT EXISTS public.nutrition_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    meal_type TEXT CHECK (meal_type IN ('breakfast','lunch','dinner','snack')),
    food_name TEXT, 
    food_source TEXT,
    food_id TEXT,
    amount_g FLOAT, 
    unit TEXT,
    calories FLOAT, 
    carbs_g FLOAT, 
    fat_g FLOAT, 
    protein_g FLOAT,
    fiber_g FLOAT, 
    sugar_g FLOAT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Policies for nutrition_logs
ALTER TABLE public.nutrition_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own nutrition logs"
    ON public.nutrition_logs
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 2. Daily nutrition summary (TrackedDayEntity mapping)
CREATE TABLE IF NOT EXISTS public.nutrition_daily_summary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    summary_date DATE NOT NULL,
    calorie_goal FLOAT DEFAULT 2000,
    calories_logged FLOAT DEFAULT 0,
    carbs_goal FLOAT DEFAULT 250, 
    carbs_logged FLOAT DEFAULT 0,
    fat_goal FLOAT DEFAULT 65, 
    fat_logged FLOAT DEFAULT 0,
    protein_goal FLOAT DEFAULT 50, 
    protein_logged FLOAT DEFAULT 0,
    UNIQUE(user_id, summary_date)
);

-- Policies for nutrition_daily_summary
ALTER TABLE public.nutrition_daily_summary ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own nutrition summaries"
    ON public.nutrition_daily_summary
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 3. Indian Food Composition Tables (Local DB fallback)
CREATE TABLE IF NOT EXISTS public.nutrition_indian_foods (
    id SERIAL PRIMARY KEY,
    food_code TEXT UNIQUE,
    food_name TEXT NOT NULL,
    food_name_hindi TEXT,
    food_category TEXT,
    calories_100g FLOAT,
    carbs_100g FLOAT, 
    fat_100g FLOAT, 
    protein_100g FLOAT,
    fiber_100g FLOAT, 
    sugar_100g FLOAT,
    sodium_mg FLOAT,
    iron_mg FLOAT, 
    calcium_mg FLOAT, 
    vitamin_c_mg FLOAT,
    source TEXT DEFAULT 'IFCT-2017'
);

-- Full text search indexing
CREATE INDEX IF NOT EXISTS nutrition_indian_foods_name_idx 
    ON public.nutrition_indian_foods USING gin(to_tsvector('english', food_name));

-- Upsert Procedure for Daily Summaries
CREATE OR REPLACE FUNCTION public.upsert_nutrition_summary(
    p_user_id UUID,
    p_date DATE,
    p_calories FLOAT,
    p_carbs FLOAT,
    p_fat FLOAT,
    p_protein FLOAT
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.nutrition_daily_summary 
        (user_id, summary_date, calories_logged, carbs_logged, fat_logged, protein_logged)
    VALUES 
        (p_user_id, p_date, p_calories, p_carbs, p_fat, p_protein)
    ON CONFLICT (user_id, summary_date) DO UPDATE SET
        calories_logged = public.nutrition_daily_summary.calories_logged + EXCLUDED.calories_logged,
        carbs_logged = public.nutrition_daily_summary.carbs_logged + EXCLUDED.carbs_logged,
        fat_logged = public.nutrition_daily_summary.fat_logged + EXCLUDED.fat_logged,
        protein_logged = public.nutrition_daily_summary.protein_logged + EXCLUDED.protein_logged;
END;
$$;
