import express from 'express';
import type { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

import env from './config/env.js';
import logger from './utils/logger.js';
import { healthCheck } from './config/db.js';
import { globalLimiter } from './middleware/rateLimiter.js';
import { notFoundHandler, errorHandler } from './middleware/errorHandler.js';
import { scheduleBillingJob } from './jobs/billing.job.js';

// Routes
import authRoutes from './routes/auth.routes.js';
import leadRoutes from './routes/lead.routes.js';
import superadminRoutes from './routes/superadmin.routes.js';
import adminRoutes from './routes/admin.routes.js';
import teacherRoutes from './routes/teacher.routes.js';
import studentRoutes from './routes/student.routes.js';
import paymentRoutes from './routes/payment.routes.js';

const app = express();

// ── Security & parsing ──
app.use(helmet());
const corsIsWildcard = env.corsOrigins.includes('*');
if (corsIsWildcard) {
  logger.warn('CORS_ORIGINS is unset/"*" — allowing all origins WITHOUT credentials (dev only; not permitted in production)');
}
app.use(
  cors({
    origin: corsIsWildcard ? true : env.corsOrigins,
    // Reflecting any origin ("*") must never be combined with credentials — that
    // would let any website make authenticated cross-site requests.
    credentials: !corsIsWildcard,
  })
);
app.use(express.json({ limit: '1mb' }));
app.use(morgan(env.isProd ? 'combined' : 'dev'));
app.use(globalLimiter);

// ── Health ──
app.get('/health', async (_req: Request, res: Response) => {
  let db = false;
  try {
    db = await healthCheck();
  } catch {
    db = false;
  }
  res.status(db ? 200 : 503).json({ status: db ? 'ok' : 'degraded', db, ts: new Date().toISOString() });
});

// ── API v1 ──
const api = express.Router();
api.use('/auth', authRoutes);
api.use('/leads', leadRoutes); // public demo bookings
api.use('/superadmin', superadminRoutes);
api.use('/admin', adminRoutes);
api.use('/teacher', teacherRoutes);
api.use('/student', studentRoutes);
api.use('/payments', paymentRoutes);
app.use('/api/v1', api);

// ── 404 + error handler (must be last) ──
app.use(notFoundHandler);
app.use(errorHandler);

// ── Boot ──
const server = app.listen(env.port, '0.0.0.0', () => {
  logger.info(`EdTech OS API listening on :${env.port}`, { env: env.nodeEnv });
  scheduleBillingJob();
});

// Graceful shutdown
for (const sig of ['SIGTERM', 'SIGINT'] as const) {
  process.on(sig, () => {
    logger.info(`${sig} received, shutting down`);
    server.close(() => process.exit(0));
  });
}

export default app;
