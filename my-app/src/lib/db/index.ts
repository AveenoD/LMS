import pkg from 'pg';
import type { Pool as PoolType, PoolClient, QueryResult, QueryResultRow } from 'pg';
import env from '../config/env';
import logger from '../utils/logger';

const { Pool } = pkg;

/**
 * Single shared connection pool, cached on globalThis so a warm Vercel
 * instance reuses it across invocations instead of opening a fresh Pool
 * (and fresh TCP connections) on every request.
 *
 * max is intentionally low: DATABASE_URL points at Supabase's Transaction
 * Pooler (port 6543, Supavisor), which already multiplexes many app-side
 * connections down to a handful of real Postgres connections. In serverless,
 * each concurrently-warm function instance creates its OWN Pool — so max is
 * a PER-INSTANCE ceiling, not a global one. A high max here would let N
 * concurrent instances each open many connections against Supavisor,
 * exhausting ITS limit under real concurrent load. Keeping max low, with
 * idle connections released quickly, is what lets Supavisor's own pooling
 * actually do its job.
 */
declare global {
  // eslint-disable-next-line no-var
  var __dbPool: PoolType | undefined;
}

export const pool: PoolType =
  globalThis.__dbPool ??
  new Pool({
    connectionString: env.databaseUrl,
    // 5 per instance leaves headroom for ~40 concurrently-warm instances
    // before approaching Supabase free tier's ~200-connection pooler ceiling,
    // while cutting per-instance queuing under concurrent requests vs max:2.
    max: 5,
    idleTimeoutMillis: 5_000,
    connectionTimeoutMillis: 10_000,
    ssl: {
      rejectUnauthorized: false, // Supabase pooler uses self-signed cert
    },
  });

// Cache in BOTH dev and prod — a warm instance benefits from reuse either way.
globalThis.__dbPool = pool;

pool.on('error', (err: Error) => {
  logger.error('Unexpected idle PG client error', { error: err.message });
});

/**
 * Run a parameterized query. ALWAYS use parameters ($1, $2) — never string
 * concatenation — to prevent SQL injection.
 */
export async function query<T extends QueryResultRow = QueryResultRow>(
  text: string,
  params: unknown[] = []
): Promise<QueryResult<T>> {
  const start = Date.now();
  const res = await pool.query<T>(text, params as unknown[]);
  const ms = Date.now() - start;
  if (ms > 300) logger.warn('Slow query', { ms, text: text.slice(0, 80) });
  return res;
}

/**
 * Run a set of statements inside a transaction.
 * Usage: await withTransaction(async (client) => { ... })
 */
export async function withTransaction<T>(
  fn: (client: PoolClient) => Promise<T>
): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

export async function healthCheck(): Promise<boolean> {
  const { rows } = await pool.query<{ ok: number }>('SELECT 1 AS ok');
  return rows[0]?.ok === 1;
}

export default pool;
