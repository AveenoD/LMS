-- ---------- CHAPTERS ----------
CREATE TABLE IF NOT EXISTS chapters (
  id          SERIAL PRIMARY KEY,
  tenant_id   INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  subject_id  INT NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  name        VARCHAR(150) NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- Index for fast lookup by tenant and subject
CREATE INDEX IF NOT EXISTS idx_chapters_tenant_subject ON chapters(tenant_id, subject_id);

-- ---------- UPDATE CONTENT ----------
-- 1. Rename youtube_url to file_url as it can hold PDFs too
ALTER TABLE content RENAME COLUMN youtube_url TO file_url;

-- 2. Add chapter_id and content_type
ALTER TABLE content ADD COLUMN IF NOT EXISTS chapter_id INT REFERENCES chapters(id) ON DELETE CASCADE;
ALTER TABLE content ADD COLUMN IF NOT EXISTS content_type VARCHAR(20) DEFAULT 'video'; -- 'video' | 'document' | 'image'

-- Index for looking up content by chapter
CREATE INDEX IF NOT EXISTS idx_content_chapter ON content(chapter_id);
