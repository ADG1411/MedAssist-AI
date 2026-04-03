-- Drop the older conflicting double precision RPC function
DROP FUNCTION IF EXISTS public.upsert_nutrition_summary(
    UUID, DATE, DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION
);

-- Drop the numeric one we just made (we will recreate it cleanly)
DROP FUNCTION IF EXISTS public.upsert_nutrition_summary(
    UUID, DATE, NUMERIC, NUMERIC, NUMERIC, NUMERIC, NUMERIC
);

-- Note: we need to drop any potential 6-argument versions that don't have activity burn
DROP FUNCTION IF EXISTS public.upsert_nutrition_summary(
    UUID, DATE, DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION
);
DROP FUNCTION IF EXISTS public.upsert_nutrition_summary(
    UUID, DATE, NUMERIC, NUMERIC, NUMERIC, NUMERIC
);

-- Recreate the ONE true version using NUMERIC to precisely capture decimal food macros
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
