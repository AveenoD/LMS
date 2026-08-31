-- ============================================================
-- Per-teacher Google OAuth tokens, for auto-generating real Google Meet
-- links via each teacher's own Calendar (bare service accounts cannot
-- create Meet-conferencing events without Google Workspace — confirmed via
-- Google API directly: a service-account calendar has no
-- conferenceProperties.allowedConferenceSolutionTypes at all).
--
-- refresh_token is long-lived (until the teacher revokes access); access
-- tokens are minted from it on demand and never stored.
-- ============================================================

CREATE TABLE teacher_google_tokens (
  id            SERIAL PRIMARY KEY,
  user_id       INT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tenant_id     INT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  refresh_token TEXT NOT NULL,
  google_email  VARCHAR(150),
  connected_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
