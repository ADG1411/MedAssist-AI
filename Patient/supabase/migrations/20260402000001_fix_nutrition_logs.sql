-- Fix for nutrition_logs schema mismatch
-- The init_schema created a dummy nutrition_logs table. We need to drop it and recreate it with the robust OpenNutriTracker version.

DROP TABLE IF EXISTS public.nutrition_logs CASCADE;

CREATE TABLE public.nutrition_logs (
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
