import { z } from 'zod';

const phone = z.string().regex(/^\d{10,15}$/, 'Phone must be 10-15 digits');

export const registerTenantSchema = z.object({
  name: z.string().trim().min(2).max(150),
  slug: z.string().trim().regex(/^[a-z0-9-]{2,60}$/, 'Slug: lowercase letters, digits, hyphens'),
  city: z.string().trim().max(80).optional(),
  contactPhone: phone.optional(),
  primaryColor: z.string().regex(/^#[0-9A-Fa-f]{6}$/).optional(),
  adminName: z.string().trim().min(2).max(120),
  adminPhone: phone,
  adminPassword: z.string().min(6).max(100),
  plan: z.enum(['flat', 'per_student']).optional(),
  amount: z.coerce.number().int().min(0).max(1000000).optional(),
});

export const suspendSchema = z.object({
  isActive: z.boolean(),
});

export type RegisterTenantBody = z.infer<typeof registerTenantSchema>;
export type SuspendBody = z.infer<typeof suspendSchema>;
