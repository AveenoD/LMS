import type { Request, Response, NextFunction, RequestHandler } from 'express';
import type { ZodSchema } from 'zod';
import ApiError from '../utils/ApiError.js';

type RequestPart = 'body' | 'query' | 'params';

/**
 * Validates req[part] against a zod schema and replaces it with the parsed
 * (and stripped) result. Usage: router.post('/x', validate(schema), handler)
 */
export const validate =
  (schema: ZodSchema, part: RequestPart = 'body'): RequestHandler =>
  (req: Request, _res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req[part]);
    if (!result.success) {
      const details = result.error.issues.map((i) => ({
        field: i.path.join('.'),
        message: i.message,
      }));
      throw ApiError.badRequest('VALIDATION_ERROR', 'Invalid request data', details);
    }
    // Note: req.query is a getter in Express 5 but writable in Express 4.
    (req as unknown as Record<RequestPart, unknown>)[part] = result.data;
    next();
  };

export default validate;
