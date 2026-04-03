-- Supabase / PostgreSQL Database Schema for Doctor Portal

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 1. DOCTORS & PROFILE DATA
-- ==========================================

CREATE TABLE doctors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE, -- Links to Supabase Auth
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(50),
    specialization VARCHAR(150),
    experience_years INT DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 0.0,
    languages TEXT,
    bio TEXT,
    location VARCHAR(255),
    avatar TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE doctor_stats (
    doctor_id UUID PRIMARY KEY REFERENCES doctors(id) ON DELETE CASCADE,
    total_patients INT DEFAULT 0,
    consultations INT DEFAULT 0,
    success_rate VARCHAR(10) DEFAULT '0%',
    earnings_this_month DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE doctor_workplaces (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID REFERENCES doctors(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100), -- Hospital, Private Clinic, etc.
    role VARCHAR(150),
    location VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE doctor_fees (
    doctor_id UUID PRIMARY KEY REFERENCES doctors(id) ON DELETE CASCADE,
    has_free_first_consult BOOLEAN DEFAULT FALSE,
    video_fee DECIMAL(10, 2) DEFAULT 0.00,
    in_person_fee DECIMAL(10, 2) DEFAULT 0.00,
    emergency_fee DECIMAL(10, 2) DEFAULT 0.00,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 2. PATIENTS & HEALTH DATA
-- ==========================================

CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE, -- Optional if patients map to auth
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(20),
    blood_group VARCHAR(10),
    weight_kg DECIMAL(5, 2),
    height_cm DECIMAL(5, 2),
    contact_number VARCHAR(50),
    medical_history TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 3. APPOINTMENTS & CONSULTATIONS
-- ==========================================

CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID REFERENCES doctors(id) ON DELETE CASCADE,
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    type VARCHAR(50), -- 'Video', 'In-Person', 'Emergency'
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'completed', 'cancelled', 'in-progress'
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    reason TEXT,
    amount_paid DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 4. PRESCRIPTIONS & MEDICINES
-- ==========================================

CREATE TABLE prescriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID REFERENCES appointments(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES doctors(id) ON DELETE CASCADE,
    patient_id UUID REFERENCES patients(id) ON DELETE CASCADE,
    notes TEXT,
    next_visit DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE prescription_medicines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prescription_id UUID REFERENCES prescriptions(id) ON DELETE CASCADE,
    medicine_name VARCHAR(200) NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    duration_days INT,
    reason_for_taking TEXT,
    estimated_price DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 5. EMERGENCIES & ALERTS
-- ==========================================

CREATE TABLE emergencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID REFERENCES patients(id) ON DELETE SET NULL,
    assigned_doctor_id UUID REFERENCES doctors(id) ON DELETE SET NULL,
    severity VARCHAR(50), -- 'Critical', 'High', 'Moderate'
    type VARCHAR(100), -- e.g., 'Cardiac Arrest', 'Trauma'
    location TEXT,
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'resolved'
    reported_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- ==========================================
-- 6. MESSAGES / CHAT (Optional real-time)
-- ==========================================

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Setup Row Level Security (RLS) policies here...
-- Example: 
-- ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Doctors can view their own profile" ON doctors FOR SELECT USING (auth.uid() = user_id);

