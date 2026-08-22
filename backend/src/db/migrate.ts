import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import pool from '../config/db.js';
import logger from '../utils/logger.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const MIGRATIONS_DIR = path.resolve(__dirname, '../../migrations');

const fresh = process.argv.includes('--fresh');

async function ensureMigrationsTable(): Promise<void> {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS _migrations (
      id SERIAL PRIMARY KEY,
      filename VARCHAR(255) UNIQUE NOT NULL,
      applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );
  `);
}

async function dropAll(): Promise<void> {
  logger.warn('--fresh: dropping public schema');
  await pool.query('DROP SCHEMA public CASCADE; CREATE SCHEMA public;');
}

async function run(): Promise<void> {
  try {
    if (fresh) await dropAll();
    await ensureMigrationsTable();

    const applied = new Set(
      (await pool.query<{ filename: string }>('SELECT filename FROM _migrations')).rows.map(
        (r) => r.filename
      )
    );

    const files = fs
      .readdirSync(MIGRATIONS_DIR)
      .filter((f) => f.endsWith('.sql'))
      .sort();

    let count = 0;
    for (const file of files) {
      if (applied.has(file)) {
        logger.debug(`Skipping already-applied migration: ${file}`);
        continue;
      }
      const sql = fs.readFileSync(path.join(MIGRATIONS_DIR, file), 'utf8');
      logger.info(`Applying migration: ${file}`);
      await pool.query('BEGIN');
      try {
        await pool.query(sql);
        await pool.query('INSERT INTO _migrations (filename) VALUES ($1)', [file]);
        await pool.query('COMMIT');
        count++;
      } catch (err) {
        await pool.query('ROLLBACK');
        const msg = err instanceof Error ? err.message : String(err);
        throw new Error(`Migration ${file} failed: ${msg}`);
      }
    }

    logger.info(`Migrations complete. Applied ${count} new migration(s).`);
  } catch (err) {
    logger.error('Migration error', { error: err instanceof Error ? err.message : String(err) });
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
}

void run();
