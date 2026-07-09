import { z } from 'zod';

export const verifyPaymentSchema = z
  .object({
    orderId: z.string().min(3),
    paymentId: z.string().min(3),
    signature: z.string().min(3).optional(), // optional only for dev mock orders
  })
  .strict();

export type VerifyPaymentBody = z.infer<typeof verifyPaymentSchema>;
