-- Build Script for MedAssist AI Supabase Database

-- 1. Patients
CREATE TABLE IF NOT EXISTS patients (
  id BIGINT PRIMARY KEY,
  name TEXT NOT NULL,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL,
  phone TEXT NOT NULL,
  blood_group TEXT,
  allergies TEXT,
  email TEXT,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Medical Records
CREATE TABLE IF NOT EXISTS medical_records (
  id BIGINT PRIMARY KEY,
  patient_id BIGINT REFERENCES patients(id) ON DELETE CASCADE,
  diagnosis TEXT NOT NULL,
  prescription TEXT,
  report_url TEXT,
  doctor_name TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Family Members
CREATE TABLE IF NOT EXISTS family_members (
  id BIGINT PRIMARY KEY,
  patient_id BIGINT REFERENCES patients(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  relation TEXT NOT NULL,
  phone TEXT NOT NULL,
  is_primary BOOLEAN DEFAULT false
);

-- 4. Access Logs
CREATE TABLE IF NOT EXISTS access_logs (
  id BIGSERIAL PRIMARY KEY,
  doctor_id BIGINT,
  doctor_name TEXT,
  patient_id BIGINT REFERENCES patients(id) ON DELETE CASCADE,
  access_type TEXT NOT NULL,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Providers
CREATE TABLE IF NOT EXISTS providers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  address TEXT,
  rating FLOAT,
  distance_km FLOAT,
  available_slots JSONB DEFAULT '[]'::jsonb
);

-- 6. Referrals
CREATE TABLE IF NOT EXISTS referrals (
  id TEXT PRIMARY KEY,
  patient_id TEXT,
  patient_name TEXT,
  patient_age INTEGER,
  patient_gender TEXT,
  patient_blood_group TEXT,
  doctor_id TEXT,
  doctor_name TEXT,
  doctor_specialization TEXT,
  diagnosis TEXT,
  notes TEXT,
  medicines JSONB DEFAULT '[]'::jsonb,
  tests JSONB DEFAULT '[]'::jsonb,
  reason TEXT,
  type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ
);

-- 7. Bookings
CREATE TABLE IF NOT EXISTS bookings (
  id TEXT PRIMARY KEY,
  referral_id TEXT REFERENCES referrals(id) ON DELETE CASCADE,
  type TEXT,
  provider_id TEXT REFERENCES providers(id),
  provider_name TEXT,
  provider_address TEXT,
  patient_name TEXT,
  date TEXT,
  time_slot TEXT,
  status TEXT,
  amount FLOAT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Tickets
CREATE TABLE IF NOT EXISTS tickets (
  id TEXT PRIMARY KEY,
  booking_id TEXT REFERENCES bookings(id) ON DELETE CASCADE,
  patient_name TEXT,
  booking_type TEXT,
  provider_name TEXT,
  provider_address TEXT,
  date TEXT,
  time_slot TEXT,
  qr_token TEXT,
  status TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Earnings
CREATE TABLE IF NOT EXISTS earnings (
  id TEXT PRIMARY KEY,
  booking_id TEXT REFERENCES bookings(id) ON DELETE CASCADE,
  patient_name TEXT,
  provider_name TEXT,
  booking_type TEXT,
  total_amount FLOAT,
  commission_rate FLOAT,
  commission_amount FLOAT,
  status TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- SEED DATA (from previous memory models)
-- ==========================================

INSERT INTO patients (id, name, age, gender, phone, blood_group, allergies, email, address, created_at) VALUES 
(1, 'Rahul Sharma', 34, 'Male', '+91 98765 43210', 'B+', 'Penicillin, Aspirin', 'rahul.sharma@email.com', '12 MG Road, Bengaluru, Karnataka', '2022-03-15T00:00:00Z'),
(2, 'Priya Verma', 28, 'Female', '+91 87654 32109', 'A+', 'Sulfa drugs', 'priya.verma@email.com', '45 Park Street, Mumbai, Maharashtra', '2023-01-10T00:00:00Z'),
(3, 'Arjun Mehta', 52, 'Male', '+91 77543 21098', 'O+', 'Heparin', 'arjun.mehta@email.com', '8 Civil Lines, Delhi', '2021-08-20T00:00:00Z')
ON CONFLICT (id) DO NOTHING;

INSERT INTO medical_records (id, patient_id, diagnosis, prescription, doctor_name, notes, created_at) VALUES 
(101, 1, 'Acute Gastritis', 'Pantoprazole 40mg OD · Domperidone 10mg TID', 'Dr. Smith', 'Avoid spicy food, eat small meals', '2024-11-05T09:00:00Z'),
(102, 1, 'Hypertension Stage 1', 'Amlodipine 5mg OD', 'Dr. Patel', 'Monitor BP daily, low-salt diet', '2024-08-15T10:30:00Z'),
(103, 1, 'GERD', 'Omeprazole 20mg BD · Antacid SOS', 'Dr. Smith', 'Lifestyle modification advised', '2024-03-22T11:00:00Z'),
(201, 2, 'Viral Upper Respiratory Infection', 'Paracetamol 500mg TID · Cetirizine 10mg OD', 'Dr. Rao', 'Rest and hydration advised', '2025-01-12T08:00:00Z'),
(202, 2, 'Iron Deficiency Anaemia', 'Ferrous Sulfate 200mg BD', 'Dr. Smith', 'Repeat CBC after 4 weeks', '2024-09-08T09:30:00Z'),
(301, 3, 'Coronary Artery Disease', 'Aspirin 75mg OD · Atorvastatin 40mg OD', 'Dr. Kapoor', 'Cardiac review in 3 months', '2025-02-01T08:00:00Z'),
(302, 3, 'Hypertension Stage 2', 'Amlodipine 10mg OD · Losartan 50mg OD', 'Dr. Smith', 'Salt restriction <2g/day', '2024-10-14T10:00:00Z'),
(303, 3, 'Type 2 Diabetes Mellitus', 'Metformin 500mg BD · Glimepiride 1mg OD', 'Dr. Patel', 'HbA1c target <7%', '2024-06-30T09:00:00Z')
ON CONFLICT (id) DO NOTHING;

INSERT INTO family_members (id, patient_id, name, relation, phone, is_primary) VALUES 
(11, 1, 'Sunita Sharma', 'Wife', '+91 90123 45678', true),
(12, 1, 'Ravi Sharma', 'Father', '+91 81234 56789', false),
(21, 2, 'Vikram Verma', 'Husband', '+91 70987 65432', true),
(31, 3, 'Kavita Mehta', 'Wife', '+91 87654 32109', true),
(32, 3, 'Rohan Mehta', 'Son', '+91 76543 21098', false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO providers (id, name, type, address, rating, distance_km, available_slots) VALUES 
('p1', 'City Diagnostics Lab', 'lab', '12 MG Road, Sector 4', 4.7, 1.2, '["09:00 AM", "11:00 AM", "02:00 PM", "04:00 PM"]'),
('p2', 'MediLab Plus', 'lab', '45 Green Park, Block B', 4.5, 2.8, '["08:00 AM", "10:00 AM", "03:00 PM"]'),
('p3', 'Apollo Diagnostics', 'lab', '78 Nehru Nagar', 4.9, 4.1, '["09:30 AM", "12:00 PM", "05:00 PM"]'),
('h1', 'City General Hospital', 'hospital', '1 Hospital Road, Civil Lines', 4.6, 3.0, '["10:00 AM", "02:00 PM", "04:30 PM"]'),
('h2', 'LifeCare Medical Centre', 'hospital', '23 Park Avenue', 4.4, 5.5, '["09:00 AM", "01:00 PM"]'),
('s1', 'Dr. Sharma - Cardiologist', 'specialist', 'Sector 6, Medical Hub', 4.8, 2.0, '["11:00 AM", "03:00 PM", "05:30 PM"]'),
('s2', 'Dr. Mehta - Neurologist', 'specialist', '88 Lake View Complex', 4.7, 6.2, '["10:30 AM", "02:30 PM"]')
ON CONFLICT (id) DO NOTHING;

INSERT INTO referrals (id, patient_id, patient_name, patient_age, patient_gender, patient_blood_group, doctor_id, doctor_name, doctor_specialization, diagnosis, notes, medicines, tests, reason, type, expires_at) VALUES 
('ref-001', 'pat-1', 'Rahul Sharma', 34, 'Male', 'B+', 'doc-1', 'Dr. Anil Kumar', 'General Physician', 'Suspected Typhoid Fever with secondary dehydration', 'Patient shows persistent fever >101°F for 5 days. Widal test positive. Recommend IV fluids and CBC panel.', '["Ciprofloxacin 500mg", "Paracetamol 650mg", "ORS Sachets"]', '["Complete Blood Count (CBC)", "Widal Test", "Blood Culture", "Liver Function Test"]', 'Fever not subsiding after 5 days — requires urgent lab investigation', 'lab', '2026-12-31T00:00:00Z')
ON CONFLICT (id) DO NOTHING;
