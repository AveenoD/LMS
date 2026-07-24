import { query, withTransaction } from '../config/db.js';
import ApiError from '../utils/ApiError.js';

export interface CreateTestInput {
  title: string;
  batchId?: number;
  subjectId?: number;
  maxMarks?: number;
  testDate?: string;
  durationMinutes?: number;
  isOnline: boolean;
}

export async function createTest(tenantId: number, data: CreateTestInput) {
  const { rows } = await query(
    `INSERT INTO tests (tenant_id, title, batch_id, subject_id, max_marks, test_date, duration_minutes, is_online)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
    [
      tenantId,
      data.title,
      data.batchId || null,
      data.subjectId || null,
      data.maxMarks || 0,
      data.testDate || null,
      data.durationMinutes || null,
      data.isOnline,
    ]
  );
  return rows[0];
}

export async function listTests(tenantId: number) {
  const { rows } = await query(
    `SELECT t.*, b.name as batch_name, s.name as subject_name,
            (SELECT COUNT(*) FROM questions q WHERE q.test_id = t.id) as question_count
     FROM tests t
     LEFT JOIN batches b ON b.id = t.batch_id
     LEFT JOIN subjects s ON s.id = t.subject_id
     WHERE t.tenant_id = $1
     ORDER BY t.id DESC`,
    [tenantId]
  );
  return rows;
}

export interface OptionInput {
  id?: number;
  optionText?: string;
  imageUrl?: string;
  isCorrect: boolean;
}

export interface CreateQuestionInput {
  questionText: string;
  imageUrl?: string;
  marks: number;
  options: OptionInput[];
}

export async function addQuestion(tenantId: number, testId: number, data: CreateQuestionInput) {
  // Verify test exists and belongs to tenant
  const testCheck = await query('SELECT 1 FROM tests WHERE id = $1 AND tenant_id = $2', [testId, tenantId]);
  if (!testCheck.rowCount) throw ApiError.notFound('TEST_NOT_FOUND');

  return withTransaction(async (client) => {
    // Insert question
    const qRes = await client.query(
      `INSERT INTO questions (tenant_id, test_id, question_text, image_url, marks)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [tenantId, testId, data.questionText, data.imageUrl || null, data.marks]
    );
    const questionId = qRes.rows[0].id;

    // Insert options
    for (const opt of data.options) {
      await client.query(
        `INSERT INTO options (tenant_id, question_id, option_text, image_url, is_correct)
         VALUES ($1, $2, $3, $4, $5)`,
        [tenantId, questionId, opt.optionText || null, opt.imageUrl || null, opt.isCorrect]
      );
    }

    return getQuestionWithOptions(tenantId, questionId);
  });
}

export async function updateQuestion(tenantId: number, questionId: number, data: CreateQuestionInput) {
  return withTransaction(async (client) => {
    // Verify question
    const qCheck = await client.query('SELECT 1 FROM questions WHERE id = $1 AND tenant_id = $2', [questionId, tenantId]);
    if (!qCheck.rowCount) throw ApiError.notFound('QUESTION_NOT_FOUND');

    // Update question
    await client.query(
      `UPDATE questions SET question_text = $1, image_url = $2, marks = $3
       WHERE id = $4 AND tenant_id = $5`,
      [data.questionText, data.imageUrl || null, data.marks, questionId, tenantId]
    );

    // Get existing options to compare
    const existingOptsRes = await client.query('SELECT id FROM options WHERE question_id = $1', [questionId]);
    const existingOptIds = new Set(existingOptsRes.rows.map(r => r.id));

    // Upsert options
    for (const opt of data.options) {
      if (opt.id && existingOptIds.has(opt.id)) {
        // Update existing
        await client.query(
          `UPDATE options SET option_text = $1, image_url = $2, is_correct = $3
           WHERE id = $4 AND tenant_id = $5`,
          [opt.optionText || null, opt.imageUrl || null, opt.isCorrect, opt.id, tenantId]
        );
        existingOptIds.delete(opt.id);
      } else {
        // Insert new
        await client.query(
          `INSERT INTO options (tenant_id, question_id, option_text, image_url, is_correct)
           VALUES ($1, $2, $3, $4, $5)`,
          [tenantId, questionId, opt.optionText || null, opt.imageUrl || null, opt.isCorrect]
        );
      }
    }

    // Delete removed options
    for (const idToDelete of existingOptIds) {
      await client.query('DELETE FROM options WHERE id = $1 AND tenant_id = $2', [idToDelete, tenantId]);
    }

    return getQuestionWithOptions(tenantId, questionId);
  });
}

export async function deleteQuestion(tenantId: number, questionId: number) {
  const res = await query('DELETE FROM questions WHERE id = $1 AND tenant_id = $2 RETURNING id', [questionId, tenantId]);
  if (!res.rowCount) throw ApiError.notFound('QUESTION_NOT_FOUND');
  return { success: true };
}

export async function getTestQuestions(tenantId: number, testId: number) {
  const { rows: questions } = await query(
    `SELECT id, question_text as "questionText", image_url as "imageUrl", marks
     FROM questions WHERE test_id = $1 AND tenant_id = $2 ORDER BY id ASC`,
    [testId, tenantId]
  );

  if (!questions.length) return [];

  const questionIds = questions.map(q => q.id);
  const { rows: options } = await query(
    `SELECT id, question_id as "questionId", option_text as "optionText", image_url as "imageUrl", is_correct as "isCorrect"
     FROM options WHERE question_id = ANY($1) AND tenant_id = $2 ORDER BY id ASC`,
    [questionIds, tenantId]
  );

  return questions.map(q => ({
    ...q,
    options: options.filter(o => o.questionId === q.id).map(o => {
      const { questionId, ...rest } = o;
      return rest;
    }),
  }));
}

export async function getQuestionWithOptions(tenantId: number, questionId: number) {
  const { rows: qRows } = await query(
    `SELECT id, test_id as "testId", question_text as "questionText", image_url as "imageUrl", marks
     FROM questions WHERE id = $1 AND tenant_id = $2`,
    [questionId, tenantId]
  );
  if (!qRows.length) throw ApiError.notFound('QUESTION_NOT_FOUND');

  const { rows: opts } = await query(
    `SELECT id, option_text as "optionText", image_url as "imageUrl", is_correct as "isCorrect"
     FROM options WHERE question_id = $1 AND tenant_id = $2 ORDER BY id ASC`,
    [questionId, tenantId]
  );

  return { ...qRows[0], options: opts };
}
