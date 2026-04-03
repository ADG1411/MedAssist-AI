-- Add missing columns to nutrition_logs that the app expects
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='nutrition_logs' AND column_name='food_source') THEN
        ALTER TABLE public.nutrition_logs ADD COLUMN food_source TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='nutrition_logs' AND column_name='food_id') THEN
        ALTER TABLE public.nutrition_logs ADD COLUMN food_id TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='nutrition_logs' AND column_name='amount_g') THEN
        ALTER TABLE public.nutrition_logs ADD COLUMN amount_g NUMERIC;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='nutrition_logs' AND column_name='unit') THEN
        ALTER TABLE public.nutrition_logs ADD COLUMN unit TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='nutrition_logs' AND column_name='fiber_g') THEN
        ALTER TABLE public.nutrition_logs ADD COLUMN fiber_g NUMERIC;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='nutrition_logs' AND column_name='sugar_g') THEN
        ALTER TABLE public.nutrition_logs ADD COLUMN sugar_g NUMERIC;
    END IF;
END $$;

-- Convert existing int macro columns to NUMERIC so the Dart double values are stored accurately without crashing or rounding incorrectly
ALTER TABLE public.nutrition_logs ALTER COLUMN calories TYPE NUMERIC USING calories::NUMERIC;
ALTER TABLE public.nutrition_logs ALTER COLUMN carbs_g TYPE NUMERIC USING carbs_g::NUMERIC;
ALTER TABLE public.nutrition_logs ALTER COLUMN fat_g TYPE NUMERIC USING fat_g::NUMERIC;
ALTER TABLE public.nutrition_logs ALTER COLUMN protein_g TYPE NUMERIC USING protein_g::NUMERIC;
ALTER TABLE public.nutrition_logs ALTER COLUMN sodium_mg TYPE NUMERIC USING sodium_mg::NUMERIC;

-- Also convert goals and logged amounts in summary just in case to double/numeric
ALTER TABLE public.nutrition_daily_summary ALTER COLUMN calories_logged TYPE NUMERIC USING calories_logged::NUMERIC;
ALTER TABLE public.nutrition_daily_summary ALTER COLUMN calorie_goal TYPE NUMERIC USING calorie_goal::NUMERIC;
ALTER TABLE public.nutrition_daily_summary ALTER COLUMN carbs_logged TYPE NUMERIC USING carbs_logged::NUMERIC;
ALTER TABLE public.nutrition_daily_summary ALTER COLUMN carbs_goal TYPE NUMERIC USING carbs_goal::NUMERIC;
ALTER TABLE public.nutrition_daily_summary ALTER COLUMN protein_logged TYPE NUMERIC USING protein_logged::NUMERIC;
ALTER TABLE public.nutrition_daily_summary ALTER COLUMN protein_goal TYPE NUMERIC USING protein_goal::NUMERIC;
ALTER TABLE public.nutrition_daily_summary ALTER COLUMN fat_logged TYPE NUMERIC USING fat_logged::NUMERIC;
ALTER TABLE public.nutrition_daily_summary ALTER COLUMN fat_goal TYPE NUMERIC USING fat_goal::NUMERIC;
ALTER TABLE public.nutrition_daily_summary ALTER COLUMN activity_burn_logged TYPE NUMERIC USING activity_burn_logged::NUMERIC;
