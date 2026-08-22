import { query } from '../config/db.js';

/** Minimal query-capable handle — matches both the pool `query()` helper and a `PoolClient`. */
interface QueryRunner {
  query: (text: string, params?: unknown[]) => Promise<unknown>;
}

export interface AuditEntry {
  /** null for platform-level actions with no tenant (e.g. super_admin creating a tenant is still tenant-scoped to the new tenant). */
  tenantId: number | null;
  /** The authenticated user who performed the action. */
  actorUserId: number | null;
  /** Short verb, e.g. 'tenant_created', 'teacher_deleted'. */
  action: string;
  /** Table/domain the action applies to, e.g. 'tenant', 'student'. */
  entity: string;
  entityId?: number | null;
  meta?: Record<string, unknown>;
}

/**
 * Record a sensitive admin action in audit_log. Pass a transaction `client`
 * when the write must be part of an existing transaction; otherwise it runs
 * against the pool directly.
 */
export async function writeAudit(entry: AuditEntry, client?: QueryRunner): Promise<void> {
  const runner: QueryRunner = client ?? { query };
  await runner.query(
    `INSERT INTO audit_log (tenant_id, actor_user_id, action, entity, entity_id, meta)
     VALUES ($1,$2,$3,$4,$5,$6::jsonb)`,
    [entry.tenantId, entry.actorUserId, entry.action, entry.entity, entry.entityId ?? null, JSON.stringify(entry.meta ?? {})]
  );
}

export default writeAudit;
