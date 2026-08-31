import type { ZodSchema } from 'zod';
import ApiError from '../utils/ApiError';

/**
 * Validates a plain object against a zod schema and returns the parsed
 * (and stripped-of-unknown-keys) result. Ported from the Express backend's
 * validate() middleware — same behavior, but called directly with a value
 * (req.body / query params object) instead of wrapping req/res/next, since
 * Next.js route handlers don't have Express's middleware chain.
 *
 * Usage in a route handler:
 *   const body = validateBody(createTestSchema, await req.json());
 *   const params = validateBody(idParamSchema, { id: routeParams.id });
 */
export function validateBody<T>(schema: ZodSchema<T>, data: unknown): T {
  const result = schema.safeParse(data);
  if (!result.success) {
    const details = result.error.issues.map((i) => ({
      field: i.path.join('.'),
      message: i.message,
    }));
    throw ApiError.badRequest('VALIDATION_ERROR', 'Invalid request data', details);
  }
  return result.data;
}
