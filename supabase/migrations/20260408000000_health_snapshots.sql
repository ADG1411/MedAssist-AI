-- Health Snapshots table for storing daily health data (idempotent)
CREATE TABLE IF NOT EXISTS health_snapshots (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  snapshot_date DATE NOT NULL,
  steps INTEGER DEFAULT 0,
  heart_rate_avg REAL DEFAULT 0,
  heart_rate_min REAL,
  heart_rate_max REAL,
  sleep_hours REAL DEFAULT 0,
  calories_burned REAL DEFAULT 0,
  blood_oxygen REAL DEFAULT 0,
  weight_kg REAL,
  bp_systolic REAL,
  bp_diastolic REAL,
  blood_glucose REAL,
  body_temperature REAL,
  distance_meters REAL DEFAULT 0,
  water_cups INTEGER DEFAULT 0,
  respiratory_rate REAL,
  body_fat_pct REAL,
  active_minutes INTEGER DEFAULT 0,
  workout_count INTEGER DEFAULT 0,
  health_score INTEGER DEFAULT 0,
  ai_insight TEXT,
  ai_risk_flags JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, snapshot_date)
);

ALTER TABLE health_snapshots ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own snapshots" ON health_snapshots;
CREATE POLICY "Users read own snapshots" ON health_snapshots
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users insert own snapshots" ON health_snapshots;
CREATE POLICY "Users insert own snapshots" ON health_snapshots
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users update own snapshots" ON health_snapshots;
CREATE POLICY "Users update own snapshots" ON health_snapshots
  FOR UPDATE USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_health_snapshots_user_date 
  ON health_snapshots(user_id, snapshot_date DESC);