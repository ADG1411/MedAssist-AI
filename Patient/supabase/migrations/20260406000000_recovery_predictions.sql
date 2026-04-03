-- Recreate the recovery_predictions table that was accidentally dropped and not recreated in the master schema
CREATE TABLE IF NOT EXISTS public.recovery_predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    current_score NUMERIC DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS policies
ALTER TABLE public.recovery_predictions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own recovery predictions"
    ON public.recovery_predictions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recovery predictions"
    ON public.recovery_predictions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recovery predictions"
    ON public.recovery_predictions FOR UPDATE
    USING (auth.uid() = user_id);
