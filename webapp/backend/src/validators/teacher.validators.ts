import { z } from 'zod';

export const markAttendanceSchema = z
  .object({
    batchId: z.coerce.number().int().positive(),
    timetableId: z.coerce.number().int().positive().optional(),
    date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'date must be YYYY-MM-DD'),
    records: z
      .array(
        z
          .object({
            studentId: z.coerce.number().int().positive(),
            status: z.enum(['present', 'absent', 'late']),
          })
          .strict()
      )
      .min(1),
  })
  .strict();

export const createContentSchema = z
  .object({
    title: z.string().trim().min(1).max(150),
    youtubeUrl: z.string().url(),
    batchId: z.coerce.number().int().positive().optional(),
    subjectId: z.coerce.number().int().positive().optional(),
  })
  .strict();

export const createLiveClassSchema = z
  .object({
    title: z.string().trim().min(1).max(150),
    meetUrl: z.string().url(),
    batchId: z.coerce.number().int().positive(),
    scheduledAt: z.string().datetime({ offset: true }).or(z.string().regex(/^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}/)),
  })
  .strict();

export const batchIdParamSchema = z.object({ batchId: z.coerce.number().int().positive() }).strict();
export const studentIdParamSchema = z.object({ studentId: z.coerce.number().int().positive() }).strict();
export const doubtLinkQuerySchema = z.object({ text: z.string().trim().max(500).optional() }).strict();
