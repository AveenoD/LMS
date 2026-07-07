import type { Request, Response, NextFunction, RequestHandler } from 'express';

/**
 * Wraps an async route handler / middleware so rejected promises are forwarded
 * to next() and hit the central errorHandler. Avoids try/catch in every
 * controller. CRITICAL for async middleware: Express 4 does NOT auto-catch
 * rejected promises from async middleware, so any async middleware that may
 * throw MUST be wrapped here.
 */
export const asyncHandler =
  (fn: (req: Request, res: Response, next: NextFunction) => unknown): RequestHandler =>
  (req: Request, res: Response, next: NextFunction): void => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };

export default asyncHandler;
