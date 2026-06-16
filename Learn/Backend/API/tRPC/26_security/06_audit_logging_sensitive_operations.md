## Audit Logging Sensitive Operations

---

### What Audit Logging Is and Why It Matters

Audit logging is the practice of recording a durable, tamper-evident history of significant actions performed in a system — who did what, to which resource, when, and with what outcome. It is distinct from application logging (which records system behavior for debugging) and error logging (which records failures).

**Key Points:**
- Audit logs answer accountability questions: who authorized a change, when a record was deleted, which API key accessed sensitive data
- tRPC provides no built-in audit logging; it must be implemented through middleware, procedure composition, or explicit calls in procedure bodies
- Audit logs are often a compliance requirement (GDPR, HIPAA, SOC 2, PCI-DSS) in addition to a security practice
- The integrity of an audit log depends on it being written to a store that application code cannot silently modify or delete

---

### What Qualifies as a Sensitive Operation

Not every procedure invocation warrants an audit log entry. Audit logging should be applied selectively to operations with accountability significance.

**Operations that typically warrant audit logging:**
- Authentication events (login, logout, failed attempts, API key usage)
- Authorization changes (role assignments, permission grants and revocations)
- Mutations to sensitive records (user profiles, payment methods, access control lists)
- Data exports or bulk reads of personally identifiable information
- Administrative actions (account suspension, key revocation, configuration changes)
- Deletions, especially soft or hard deletes of records with regulatory significance

**Operations that typically do not:**
- Routine read queries with no access control significance
- Internal health checks or telemetry
- Unauthenticated public data access

**Key Points:**
- [Inference] The boundary between what warrants audit logging and what does not depends on the application's data sensitivity and regulatory context; the above is a general guide, not an exhaustive rule
- Over-logging increases storage costs and makes audit logs harder to query; under-logging creates gaps in accountability

---

### Audit Log Record Structure

An audit log entry should capture enough context to reconstruct what happened without relying on other systems.

```typescript
// types/audit.ts
export interface AuditLogEntry {
  id: string;               // unique identifier for the log entry
  timestamp: Date;          // when the action occurred (server time)
  actorId: string | null;   // authenticated user or API key ID; null for unauthenticated
  actorType: 'user' | 'apiKey' | 'system';
  action: string;           // e.g., 'user.updateRole', 'apiKey.revoke'
  resourceType: string;     // e.g., 'user', 'payment', 'widget'
  resourceId: string | null;// ID of the affected record
  outcome: 'success' | 'failure' | 'denied';
  metadata: Record<string, unknown>; // action-specific detail (sanitized)
  ipAddress: string | null;
  userAgent: string | null;
}
```

**Key Points:**
- `actorId` and `actorType` together identify who performed the action regardless of auth mechanism
- `action` should follow a consistent naming convention (`resource.verb`) to support querying by action type
- `metadata` holds action-specific context but must be sanitized — no passwords, secrets, or full PII values
- `outcome` records whether the action succeeded, failed due to an error, or was denied by authorization logic

---

### Core Audit Logger Utility

A centralized utility function writes audit entries and can be imported by middleware or procedure bodies.

```typescript
// server/lib/auditLogger.ts
import { db } from '../db';
import type { AuditLogEntry } from '../../types/audit';
import crypto from 'crypto';

export async function writeAuditLog(
  entry: Omit<AuditLogEntry, 'id' | 'timestamp'>
): Promise<void> {
  await db.auditLog.create({
    data: {
      id: crypto.randomUUID(),
      timestamp: new Date(),
      ...entry,
      metadata: entry.metadata ?? {},
    },
  });
}
```

**Key Points:**
- The utility is kept thin; it delegates to the database and does not contain business logic
- `id` and `timestamp` are generated server-side to prevent caller manipulation
- [Inference] Writing audit logs synchronously (awaiting the database write) ensures the log is persisted before the response is sent, but adds latency; async fire-and-forget reduces latency at the cost of potential log loss on process crash — the appropriate trade-off depends on the durability requirements

---

### Middleware-Based Audit Logging

For operations where every invocation should be logged regardless of procedure-specific logic, tRPC middleware is the appropriate layer.

```typescript
// server/middleware/auditMiddleware.ts
import { t } from '../trpc';
import { writeAuditLog } from '../lib/auditLogger';
import { TRPCError } from '@trpc/server';

export function createAuditMiddleware(
  resourceType: string,
  action: string,
  getResourceId?: (input: unknown) => string | null,
) {
  return t.middleware(async ({ ctx, input, path, next }) => {
    const result = await next();

    const outcome = result.ok ? 'success' : 'failure';

    await writeAuditLog({
      actorId: ctx.user?.id ?? ctx.apiClient?.id ?? null,
      actorType: ctx.user ? 'user' : ctx.apiClient ? 'apiKey' : 'system',
      action,
      resourceType,
      resourceId: getResourceId ? getResourceId(input) : null,
      outcome,
      ipAddress: ctx.req.ip ?? null,
      userAgent: ctx.req.headers['user-agent'] ?? null,
      metadata: { path },
    });

    return result;
  });
}
```

```typescript
// Usage on a specific procedure
export const appRouter = router({
  updateUserRole: adminProcedure
    .use(createAuditMiddleware(
      'user',
      'user.updateRole',
      (input) => (input as { userId: string }).userId,
    ))
    .input(z.object({
      userId: z.string().uuid(),
      role: z.enum(['admin', 'member', 'viewer']),
    }))
    .mutation(async ({ input, ctx }) => {
      return await db.user.update({
        where: { id: input.userId },
        data: { role: input.role },
      });
    }),
});
```

**Key Points:**
- The middleware calls `next()` first, then logs the outcome — this captures whether the operation succeeded
- `result.ok` indicates whether the procedure completed without throwing
- [Inference] Logging after `next()` means that if the audit write fails, the operation has already completed; depending on requirements, it may be necessary to log before `next()` as well and mark entries as pending until confirmed

---

### Procedure-Level Audit Logging

For operations where the audit entry requires procedure-specific context (e.g., the previous value of a field), logging in the procedure body provides more control.

```typescript
deleteAccount: protectedProcedure
  .input(z.object({
    userId: z.string().uuid(),
    reason: z.string().max(500).optional(),
  }))
  .mutation(async ({ input, ctx }) => {
    const target = await db.user.findUniqueOrThrow({
      where: { id: input.userId },
      select: { id: true, email: true, role: true },
    });

    // Authorization check
    if (ctx.user.role !== 'admin' && ctx.user.id !== input.userId) {
      await writeAuditLog({
        actorId: ctx.user.id,
        actorType: 'user',
        action: 'account.delete',
        resourceType: 'user',
        resourceId: input.userId,
        outcome: 'denied',
        ipAddress: ctx.req.ip ?? null,
        userAgent: ctx.req.headers['user-agent'] ?? null,
        metadata: { reason: 'insufficient_permissions' },
      });

      throw new TRPCError({ code: 'FORBIDDEN' });
    }

    await db.user.delete({ where: { id: input.userId } });

    await writeAuditLog({
      actorId: ctx.user.id,
      actorType: 'user',
      action: 'account.delete',
      resourceType: 'user',
      resourceId: input.userId,
      outcome: 'success',
      ipAddress: ctx.req.ip ?? null,
      userAgent: ctx.req.headers['user-agent'] ?? null,
      metadata: {
        deletedUserRole: target.role,
        reason: input.reason ?? null,
        // email is hashed — do not store plaintext PII in audit log
        deletedUserEmailHash: crypto
          .createHash('sha256')
          .update(target.email)
          .digest('hex'),
      },
    });

    return { deleted: true };
  }),
```

**Key Points:**
- Denied actions are logged with `outcome: 'denied'` — failed authorization attempts are often the most security-relevant events
- PII in `metadata` is hashed rather than stored in plaintext; the hash allows correlation without exposing the value
- The previous role is captured before deletion, providing a record of what was destroyed

---

### Logging Authentication Events

Authentication events — successful logins, failed attempts, and logouts — are among the most important audit records.

```typescript
login: publicProcedure
  .input(z.object({
    email: z.string().email(),
    password: z.string(),
  }))
  .mutation(async ({ input, ctx }) => {
    const user = await db.user.findUnique({
      where: { email: input.email.toLowerCase() },
    });

    if (!user || !(await verifyPassword(input.password, user.passwordHash))) {
      await writeAuditLog({
        actorId: null,
        actorType: 'system',
        action: 'auth.login',
        resourceType: 'user',
        resourceId: null, // do not expose whether the account exists
        outcome: 'failure',
        ipAddress: ctx.req.ip ?? null,
        userAgent: ctx.req.headers['user-agent'] ?? null,
        metadata: {
          // Hash the email — do not expose the attempted value if account does not exist
          emailHash: crypto.createHash('sha256').update(input.email).digest('hex'),
        },
      });

      throw new TRPCError({
        code: 'UNAUTHORIZED',
        message: 'Invalid credentials',
      });
    }

    const session = await createSession(user.id);

    await writeAuditLog({
      actorId: user.id,
      actorType: 'user',
      action: 'auth.login',
      resourceType: 'user',
      resourceId: user.id,
      outcome: 'success',
      ipAddress: ctx.req.ip ?? null,
      userAgent: ctx.req.headers['user-agent'] ?? null,
      metadata: { sessionId: session.id },
    });

    return { sessionToken: session.token };
  }),
```

**Key Points:**
- Failed login attempts do not reveal whether the account exists (`resourceId` is null on failure)
- The attempted email is hashed in the metadata — this allows correlation across attempts without storing the plaintext
- Session ID in the metadata links the audit record to subsequent session activity

---

### Immutability and Storage Integrity

Audit logs are only useful if they cannot be silently modified. Several measures support log integrity.

**Append-only database table:**
```sql
-- PostgreSQL: revoke UPDATE and DELETE on the audit_logs table
REVOKE UPDATE, DELETE ON audit_logs FROM application_role;
```

**Write to a separate store:**
```typescript
// Audit logs written to a dedicated append-only service or data store
// rather than the same database as application data

export async function writeAuditLog(entry: Omit<AuditLogEntry, 'id' | 'timestamp'>) {
  // Primary: dedicated audit database or service
  await auditDb.auditLog.create({ data: { id: crypto.randomUUID(), timestamp: new Date(), ...entry } });

  // Secondary: structured log stream (e.g., to a SIEM or log aggregation service)
  auditLogger.info({ event: 'audit', ...entry });
}
```

**Key Points:**
- Application database credentials should not have `UPDATE` or `DELETE` permissions on the audit log table
- Writing to a secondary system (log aggregation, SIEM) provides redundancy and separation
- [Inference] True tamper-evidence requires controls at the infrastructure level (separate credentials, append-only storage services, or cryptographic chaining); application-level controls alone are not sufficient if the application's database credentials are compromised
- The appropriate level of integrity controls depends on the regulatory and threat context

---

### Sanitizing Metadata

Audit log metadata must not contain raw secrets, passwords, full payment card numbers, or unredacted PII. What to include depends on what is needed for accountability without creating a second exposure surface.

```typescript
// Sanitize before writing to metadata
function sanitizeMetadata(data: Record<string, unknown>): Record<string, unknown> {
  const REDACTED = '[REDACTED]';
  const sensitiveKeys = new Set([
    'password', 'passwordHash', 'secret', 'token',
    'cardNumber', 'cvv', 'ssn', 'apiKey',
  ]);

  return Object.fromEntries(
    Object.entries(data).map(([key, value]) => [
      key,
      sensitiveKeys.has(key.toLowerCase()) ? REDACTED : value,
    ])
  );
}
```

**Key Points:**
- The sensitive key list is a baseline; it must be extended for domain-specific fields
- [Inference] Key-based redaction is a best-effort approach; structured data (e.g., a nested object containing a `password` field) may pass through if the sanitizer only checks top-level keys — recursive sanitization is advisable for nested metadata
- Audit log storage should be treated as sensitive data itself; access controls and encryption at rest apply

---

### Querying the Audit Log

Audit logs are only useful if they can be queried efficiently. A tRPC procedure for internal audit review illustrates how structured log records support accountability queries.

```typescript
getAuditLog: adminProcedure
  .input(z.object({
    actorId: z.string().uuid().optional(),
    resourceType: z.string().optional(),
    resourceId: z.string().optional(),
    action: z.string().optional(),
    outcome: z.enum(['success', 'failure', 'denied']).optional(),
    from: z.date().optional(),
    to: z.date().optional(),
    page: z.number().int().min(1).default(1),
    pageSize: z.number().int().min(1).max(100).default(50),
  }))
  .query(async ({ input }) => {
    const where = {
      ...(input.actorId && { actorId: input.actorId }),
      ...(input.resourceType && { resourceType: input.resourceType }),
      ...(input.resourceId && { resourceId: input.resourceId }),
      ...(input.action && { action: { contains: input.action } }),
      ...(input.outcome && { outcome: input.outcome }),
      ...(input.from || input.to
        ? { timestamp: { gte: input.from, lte: input.to } }
        : {}),
    };

    const [entries, total] = await Promise.all([
      db.auditLog.findMany({
        where,
        orderBy: { timestamp: 'desc' },
        skip: (input.page - 1) * input.pageSize,
        take: input.pageSize,
      }),
      db.auditLog.count({ where }),
    ]);

    return { entries, total, page: input.page, pageSize: input.pageSize };
  }),
```

**Key Points:**
- The query procedure itself should be audit logged if the audit log contains sensitive data
- Pagination prevents unbounded result sets
- Access to the audit log query procedure should be restricted to administrative roles

---

### Summary of Logging Placement

| Scenario | Recommended Placement |
|---|---|
| All mutations of a resource type | Middleware on a base procedure |
| Operations requiring pre/post state | Procedure body |
| Authorization denials | Procedure body, before throwing |
| Authentication events | Procedure body (login, logout procedures) |
| API key usage | Context factory or API key middleware |
| Bulk data exports | Procedure body with record count in metadata |

---

**Conclusion**

Audit logging in tRPC is implemented through a combination of middleware (for cross-cutting coverage) and procedure-body logging (for operations requiring specific context). A consistent log record structure — capturing actor, action, resource, outcome, and sanitized metadata — supports both operational review and compliance reporting. Integrity depends on append-only storage, separation of credentials, and secondary write targets. Audit logs are sensitive data in their own right and require the same access controls applied to the data they describe.