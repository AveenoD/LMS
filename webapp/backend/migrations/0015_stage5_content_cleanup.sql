-- ============================================================
-- Stage 5: drop content.subject_id — redundant with chapter_id
-- (chapters.subject_id already derives it), and nothing reads it directly;
-- every read path already joins through chapter_id -> chapters.subject_id.
-- ============================================================

ALTER TABLE content DROP COLUMN subject_id;
