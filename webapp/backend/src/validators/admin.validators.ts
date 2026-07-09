import { z } from 'zod';

const phone = z.string().regex(/^\d{10,15}$/, 'Phone must be 10-15 digits');
const timeStr = z.string().regex(/^\d{2}:\d{2}(:\d{2})?$/, 'Time must be HH:MM');

export const createTeacherSchema = z
  .object({
    fullName: z.string().trim().min(2).max(120),
    phone,
    password: z.string().min(6).max(100),
    email: z.string().email().optional(),
  })
  .strict();

export const createStudentSchema = z
  .object({
    fullName: z.string().trim().min(2).max(120),
    phone,
    password: z.string().min(6).max(100),
    parentName: z.string().trim().max(120).optional(),
    parentPhone: phone,
    grade: z.string().trim().max(30).optional(),
    rollNo: z.string().trim().max(30).optional(),
    // Required: a student must be enrolled in a batch at creation time.
    batchId: z.coerce.number().int().positive(),
  })
  .strict();

export const createBatchSchema = z
  .object({
    name: z.string().trim().min(1).max(80),
    grade: z.string().trim().max(30).optional(),
  })
  .strict();

export const createSubjectSchema = z
  .object({
    name: z.string().trim().min(1).max(80),
  })
  .strict();

export const createTimetableSchema = z
  .object({
    batchId: z.coerce.number().int().positive(),
    subjectId: z.coerce.number().int().positive().optional(),
    teacherId: z.coerce.number().int().positive(),
    dayOfWeek: z.coerce.number().int().min(0).max(6),
    startTime: timeStr,
    endTime: timeStr,
  })
  .strict();

export const createFeeStructureSchema = z
  .object({
    batchId: z.coerce.number().int().positive().optional(),
    title: z.string().trim().min(1).max(100),
    amount: z.coerce.number().int().min(0),
    dueDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  })
  .strict();

export const recordPaymentSchema = z
  .object({
    studentId: z.coerce.number().int().positive(),
    feeStructureId: z.coerce.number().int().positive().optional(),
    amountPaid: z.coerce.number().int().min(1),
    method: z.enum(['cash', 'upi', 'card']).optional(),
  })
  .strict();

export const updateBrandingSchema = z
  .object({
    logoUrl: z.string().url().optional(),
    primaryColor: z.string().regex(/^#[0-9A-Fa-f]{6}$/).optional(),
  })
  .strict();

export const idParamSchema = z.object({ id: z.coerce.number().int().positive() }).strict();
export const studentIdParamSchema = z.object({ studentId: z.coerce.number().int().positive() }).strict();
export const batchIdParamSchema = z.object({ batchId: z.coerce.number().int().positive() }).strict();
