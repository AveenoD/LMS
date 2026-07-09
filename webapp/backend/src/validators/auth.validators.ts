import { z } from 'zod';

const phone = z.string().regex(/^\d{10,15}$/, 'Phone must be 10-15 digits');

export const loginSchema = z
  .object({
    slug: z.string().trim().min(1).max(60).optional(), // omitted for super_admin
    phone,
    password: z.string().min(6).max(100),
  })
  .strict();

export const refreshSchema = z
  .object({
    refreshToken: z.string().min(10),
  })
  .strict();

export type LoginBody = z.infer<typeof loginSchema>;
export type RefreshBody = z.infer<typeof refreshSchema>;
