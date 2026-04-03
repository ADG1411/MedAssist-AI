-- ==========================================
-- MedAssist AI: Master Supabase Schema
-- ==========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES (Base user table linking to auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('superadmin', 'admin', 'doctor', 'patient', 'hospital_admin', 'lab_admin')),
    phone TEXT,
    avatar_url TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'pending', 'suspended', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. DOCTORS
CREATE TABLE doctors (
    id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    specialty TEXT NOT NULL,
    license_number TEXT UNIQUE NOT NULL,
    experience_years INTEGER,
    bio TEXT,
    consultation_fee DECIMAL(10,2) DEFAULT 0.00,
    commission_rate DECIMAL(5,2) DEFAULT 15.00, -- Platform takes 15%
    is_verified BOOLEAN DEFAULT false,
    rating DECIMAL(3,2) DEFAULT 0.00
);

-- 3. PATIENTS
CREATE TABLE patients (
    id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    date_of_birth DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    blood_group TEXT,
    medical_history_summary TEXT,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT
);

-- 4. HOSPITALS & LABS (Partners)
CREATE TABLE partners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES profiles(id),
    name TEXT NOT NULL,
    type TEXT CHECK (type IN ('hospital', 'clinic', 'laboratory')),
    address TEXT,
    city TEXT,
    state TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    commission_rate DECIMAL(5,2) DEFAULT 10.00,
    status TEXT DEFAULT 'pending' CHECK (status IN ('active', 'pending', 'suspended')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. CASES & CONSULTATIONS
CREATE TABLE cases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_number TEXT UNIQUE NOT NULL, -- e.g., CAS-1001
    patient_id UUID REFERENCES patients(id),
    doctor_id UUID REFERENCES doctors(id),
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'cancelled')),
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'critical')),
    symptoms TEXT,
    diagnosis TEXT,
    prescription_notes TEXT,
    is_emergency BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. REFERRALS & BOOKINGS
CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID REFERENCES cases(id),
    referred_by UUID REFERENCES profiles(id), -- The doctor who referred
    referred_to UUID REFERENCES partners(id), -- The hospital/lab
    patient_id UUID REFERENCES patients(id),
    service_type TEXT NOT NULL, -- e.g., 'MRI Scan', 'Blood Test', 'Surgery'
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'booked', 'completed', 'cancelled')),
    commission_earned DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. REVENUE & TRANSACTIONS
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id TEXT UNIQUE, -- e.g., TXN-9982
    case_id UUID REFERENCES cases(id),
    payer_id UUID REFERENCES profiles(id),
    payee_id UUID REFERENCES profiles(id), -- Could be doctor or partner
    amount DECIMAL(10,2) NOT NULL,
    platform_fee DECIMAL(10,2) NOT NULL,
    net_amount DECIMAL(10,2) NOT NULL,
    type TEXT CHECK (type IN ('consultation', 'referral', 'lab_test', 'subscription')),
    status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. AI LOGS
CREATE TABLE ai_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID REFERENCES cases(id),
    prompt_used TEXT,
    ai_response TEXT,
    model_version TEXT,
    risk_prediction TEXT CHECK (risk_prediction IN ('low', 'medium', 'high', 'critical')),
    confidence_score DECIMAL(5,2),
    execution_time_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. SYSTEM AUDIT LOGS
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES profiles(id),
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL, -- 'doctor', 'patient', 'settings', etc.
    entity_id UUID,
    ip_address TEXT,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_cases_patient ON cases(patient_id);
CREATE INDEX idx_cases_doctor ON cases(doctor_id);
CREATE INDEX idx_cases_status_priority ON cases(status, priority);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_ai_logs_case ON ai_logs(case_id);

-- RLS (Row Level Security) Templates
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cases ENABLE ROW LEVEL SECURITY;

-- Example RLS: Admin can read all profiles
CREATE POLICY "Admins can view all profiles" 
ON profiles FOR SELECT 
USING ( auth.uid() IN (SELECT id FROM profiles WHERE role IN ('admin', 'superadmin')) );
