-- 1. Create the doctor_profiles table
CREATE TABLE IF NOT EXISTS doctor_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  overview JSONB DEFAULT '{}'::jsonb,
  workplaces JSONB DEFAULT '[]'::jsonb,
  availability JSONB DEFAULT '{}'::jsonb,
  fees JSONB DEFAULT '{}'::jsonb,
  documents JSONB DEFAULT '[]'::jsonb,
  settings JSONB DEFAULT '{}'::jsonb,
  verification_status TEXT DEFAULT 'incomplete',
  completion_percent INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE doctor_profiles ENABLE ROW LEVEL SECURITY;

-- 3. Create Security Policies
-- Policy: Doctors can view their own profile
CREATE POLICY "Users can view own profile" 
ON doctor_profiles 
FOR SELECT 
USING (auth.uid() = id);

-- Policy: Doctors can perfectly insert their own profile
CREATE POLICY "Users can insert own profile" 
ON doctor_profiles 
FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Policy: Doctors can update their own profile
CREATE POLICY "Users can update own profile" 
ON doctor_profiles 
FOR UPDATE 
USING (auth.uid() = id);

-- 4. Create an automatic trigger for updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_set_updated_at ON doctor_profiles;
CREATE TRIGGER trigger_set_updated_at
BEFORE UPDATE ON doctor_profiles
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
