-- ============================================================
-- Booking Lifecycle Enhancement
-- Adds columns needed for full payment + video consultation flow
-- Compatible with both Patient (Flutter) and Doctor Panel (React Native)
-- ============================================================

-- Add missing columns to bookings
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='bookings' AND column_name='doctor_name') THEN
        ALTER TABLE public.bookings ADD COLUMN doctor_name TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='bookings' AND column_name='doctor_specialty') THEN
        ALTER TABLE public.bookings ADD COLUMN doctor_specialty TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='bookings' AND column_name='meeting_url') THEN
        ALTER TABLE public.bookings ADD COLUMN meeting_url TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='bookings' AND column_name='payment_status') THEN
        ALTER TABLE public.bookings ADD COLUMN payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded', 'failed'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='bookings' AND column_name='updated_at') THEN
        ALTER TABLE public.bookings ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- Allow patients to UPDATE their own bookings (needed for payment confirmation)
DROP POLICY IF EXISTS "Patients can update own bookings" ON public.bookings;
CREATE POLICY "Patients can update own bookings" ON public.bookings
    FOR UPDATE TO authenticated USING (auth.uid() = patient_id) WITH CHECK (auth.uid() = patient_id);
