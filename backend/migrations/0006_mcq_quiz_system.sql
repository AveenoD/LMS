-- Add new columns to tests table for MCQ Quiz System
ALTER TABLE tests ADD COLUMN IF NOT EXISTS duration_minutes INT;
ALTER TABLE tests ADD COLUMN IF NOT EXISTS is_online BOOLEAN NOT NULL DEFAULT false;

-- Create questions table
CREATE TABLE IF NOT EXISTS questions (
  id             SERIAL PRIMARY KEY,
  tenant_id      INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  test_id        INT NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
  question_text  TEXT NOT NULL,
  image_url      TEXT,
  marks          INT NOT NULL DEFAULT 1
);

-- Create options table
CREATE TABLE IF NOT EXISTS options (
  id             SERIAL PRIMARY KEY,
  tenant_id      INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  question_id    INT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  option_text    TEXT,
  image_url      TEXT,
  is_correct     BOOLEAN NOT NULL DEFAULT false
);

-- Note: In a real system, you might want to add check constraints 
-- (e.g. at least one of option_text or image_url must not be null),
-- but we'll leave it simple for now.
