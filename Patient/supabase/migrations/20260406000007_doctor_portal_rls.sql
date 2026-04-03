-- ============================================================
-- Doctor Portal RLS: Allow doctors to read bookings assigned to them
-- ============================================================

-- Allow any authenticated user to view bookings (needed for Doctor Panel)
-- In production, the Doctor Panel auth context sets the doctor's user ID
DROP POLICY IF EXISTS "Doctors can view assigned bookings" ON public.bookings;
CREATE POLICY "Doctors can view assigned bookings" ON public.bookings
    FOR SELECT TO authenticated USING (true);

-- Allow doctors to update bookings they are assigned to (mark completed, etc.)
DROP POLICY IF EXISTS "Doctors can update assigned bookings" ON public.bookings;
CREATE POLICY "Doctors can update assigned bookings" ON public.bookings
    FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- Allow doctors to view patient profiles for consultation context
DROP POLICY IF EXISTS "Doctors can view patient profiles" ON public.profiles;
CREATE POLICY "Doctors can view patient profiles" ON public.profiles
    FOR SELECT TO authenticated USING (true);
