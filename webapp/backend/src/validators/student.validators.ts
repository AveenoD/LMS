import { z } from 'zod';

export const idParamSchema = z.object({ id: z.coerce.number().int().positive() }).strict();
export const paymentIdParamSchema = z.object({ paymentId: z.coerce.number().int().positive() }).strict();

export const listVideosQuerySchema = z
  .object({
    subjectId: z.coerce.number().int().positive().optional(),
  })
  .strict();

export const askDoubtQuerySchema = z
  .object({
    teacherId: z.coerce.number().int().positive(),
    chapter: z.string().trim().max(200).optional(),
  })
  .strict();
