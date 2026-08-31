-- ============================================================
-- Google Meet links are about to switch from teacher-pasted to
-- backend-generated (via Google Calendar API's conferenceData). We need the
-- Calendar event id to be able to delete/update the event later — without
-- it, deleting a live class in-app would leave an orphaned Calendar event
-- (and its Meet link) behind forever. Nullable: existing rows were created
-- with a manually-pasted link, so they have no backing Calendar event.
-- ============================================================

ALTER TABLE live_classes ADD COLUMN calendar_event_id VARCHAR(255);
