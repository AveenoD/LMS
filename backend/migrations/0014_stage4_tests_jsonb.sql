-- ============================================================
-- Stage 4: collapse questions/options into tests.questions (JSONB).
-- Neither table is ever queried independently of its parent test, so the
-- 3-table split (tests/questions/options) bought normalization with no
-- real benefit here. test_results.answers is new — previously the grader
-- computed correct/incorrect per question and then discarded it, keeping
-- only the aggregate marks_obtained; the mobile "Review Answers" button
-- had nothing to read. Now it does.
-- ============================================================

ALTER TABLE tests ADD COLUMN questions JSONB NOT NULL DEFAULT '[]';
ALTER TABLE test_results ADD COLUMN answers JSONB NOT NULL DEFAULT '{}';
ALTER TABLE test_results ADD COLUMN submitted_at TIMESTAMPTZ NOT NULL DEFAULT now();

UPDATE tests t SET questions = COALESCE((
  SELECT jsonb_agg(jsonb_build_object(
    'id', q.id,
    'questionText', q.question_text,
    'imageUrl', q.image_url,
    'marks', q.marks,
    'options', (
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', o.id,
        'optionText', o.option_text,
        'imageUrl', o.image_url,
        'isCorrect', o.is_correct
      ) ORDER BY o.id), '[]'::jsonb)
      FROM options o WHERE o.question_id = q.id
    )
  ) ORDER BY q.id)
  FROM questions q WHERE q.test_id = t.id
), '[]'::jsonb);

-- Verification gate: total question count and total option count must
-- match exactly before we touch anything destructive.
DO $$
DECLARE old_q_count INT; new_q_count INT; old_o_count INT; new_o_count INT;
BEGIN
  SELECT count(*) INTO old_q_count FROM questions;
  SELECT COALESCE(SUM(jsonb_array_length(questions)), 0) INTO new_q_count FROM tests;
  IF old_q_count != new_q_count THEN
    RAISE EXCEPTION 'question count mismatch after JSONB backfill: % old vs % new', old_q_count, new_q_count;
  END IF;

  SELECT count(*) INTO old_o_count FROM options;
  SELECT COALESCE(SUM(jsonb_array_length(elem->'options')), 0) INTO new_o_count
    FROM tests, jsonb_array_elements(questions) AS elem;
  IF old_o_count != new_o_count THEN
    RAISE EXCEPTION 'option count mismatch after JSONB backfill: % old vs % new', old_o_count, new_o_count;
  END IF;
END $$;

-- Future question ids come from this sequence (tenant-wide unique, so
-- /questions/:id routes without a testId can find their owning test via
-- JSONB containment). Seeded above any id already used by backfilled data.
CREATE SEQUENCE quiz_question_id_seq;
SELECT setval('quiz_question_id_seq', GREATEST(1, (SELECT COALESCE(MAX(id), 0) FROM questions)));

DROP TABLE options;
DROP TABLE questions;
