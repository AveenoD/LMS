import type { AuthUser } from './index.js';

/**
 * Augment Express' Request so `req.user` is typed everywhere.
 * Populated by authMiddleware from the verified access token.
 */
declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}

export {};
