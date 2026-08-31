import { z } from 'zod';

export const createLeadSchema = z
  .object({
    ownerName: z.string().trim().min(2).max(120),
    instituteName: z.string().trim().min(2).max(150),
    phone: z.string().regex(/^\d{10,15}$/, 'Phone must be 10-15 digits'),
    email: z.string().trim().email().max(120).optional(),
    city: z.string().trim().max(80).optional(),
    studentCount: z.coerce.number().int().min(0).max(100000).optional(),
    message: z.string().trim().max(1000).optional(),
  })
  .strict();

export const updateLeadStatusSchema = z
  .object({
    status: z.enum(['new', 'contacted', 'converted', 'lost']),
  })
  .strict();

export type CreateLeadBody = z.infer<typeof createLeadSchema>;
export type UpdateLeadStatusBody = z.infer<typeof updateLeadStatusSchema>;
