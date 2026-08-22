/**
 * Tiny structured logger. Keeps deps minimal; prints JSON in prod, pretty in dev.
 */
import env from '../config/env.js';

type LogLevel = 'info' | 'warn' | 'error' | 'debug';
export type LogMeta = Record<string, unknown> | undefined;

function ts(): string {
  return new Date().toISOString();
}

function emit(level: LogLevel, msg: string, meta?: LogMeta): void {
  if (env.isProd) {
    process.stdout.write(
      JSON.stringify({ t: ts(), level, msg, ...(meta || {}) }) + '\n'
    );
  } else {
    const tags: Record<LogLevel, string> = {
      info: 'INFO ',
      warn: 'WARN ',
      error: 'ERROR',
      debug: 'DEBUG',
    };
    const tag = tags[level];
    const extra = meta ? ' ' + JSON.stringify(meta) : '';
    // eslint-disable-next-line no-console
    console.log(`[${ts()}] ${tag} ${msg}${extra}`);
  }
}

export const logger = {
  info: (msg: string, meta?: LogMeta) => emit('info', msg, meta),
  warn: (msg: string, meta?: LogMeta) => emit('warn', msg, meta),
  error: (msg: string, meta?: LogMeta) => emit('error', msg, meta),
  debug: (msg: string, meta?: LogMeta) => (env.isProd ? undefined : emit('debug', msg, meta)),
};

export default logger;
