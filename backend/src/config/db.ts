import pkg from 'pg';
import type { Pool as PoolType, PoolClient, QueryResult, QueryResultRow } from 'pg';
import env from './env.js';
import logger from '../utils/logger.js';

const { Pool } = pkg;

/**
 * Single shared connection pool for the whole app.
 * SSL is required for Supabase (pooler uses self-signed cert in chain).
 *
 * max is intentionally low: DATABASE_URL points at Supabase's Transaction
 * Pooler (port 6543, Supavisor/pgbouncer), which already multiplexes many
 * app-side connections down to a handful of real Postgres connections. In a
 * serverless deployment each concurrently-warm function instance creates
 * its OWN Pool — so max is a PER-INSTANCE ceiling, not a global one. A high
 * max here (e.g. 10) means N concurrent instances can each open up to 10
 * connections against Supavisor, exhausting its own connection limit under
 * real concurrent load. Keeping max low here, and idle connections released
 * quickly, is what actually lets Supavisor's higher-level pooling work as
 * intended.
 */
export const pool: PoolType = new Pool({
  connectionString: env.databaseUrl,
  max: 2,
  idleTimeoutMillis: 5_000,
  connectionTimeoutMillis: 10_000,
  ssl: {
    rejectUnauthorized: false, // Supabase pooler uses self-signed cert
  },
});

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
