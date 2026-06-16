## API Key Authentication

---

### Role of API Key Authentication in tRPC

API key authentication is suited to server-to-server communication, developer-facing integrations, CLI tools, and any context where a human login flow is impractical. Unlike session cookies or JWTs issued after a login, API keys are long-lived credentials provisioned in advance and sent with each request.

**Key Points:**
- tRPC has no built-in API key system; the mechanism is implemented in `createContext` and middleware
- API keys are typically sent in a request header, most commonly `Authorization` or a custom header such as `x-api-key`
- Because API keys are sent in headers rather than cookies, classic CSRF does not apply to API-key-authenticated requests

---

### Basic Structure: Extracting and Validating a Key in Context

The context factory is the standard place to extract credentials from an incoming request. The resolved context is then available to all procedures and middleware.

```typescript
// server/context.ts
import { TRPCError } from '@trpc/server';
import type { CreateExpressContextOptions } from '@trpc/server/adapters/express';
import { db } from './db';

export async function createContext({ req }: CreateExpressContextOptions) {
  const apiKey = req.headers['x-api-key'];

  if (!apiKey || typeof apiKey !== 'string') {
    return { apiClient: null };
  }

  const client = await db.apiKey.findUnique({
    where: { key: apiKey },
    select: {
      id: true,
      clientName: true,
      scopes: true,
      revokedAt: true,
    },
  });

  if (!client || client.revokedAt !== null) {
    return { apiClient: null };
  }

  return { apiClient: client };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Key Points:**
- The context does not throw on an invalid or missing key — it returns `null` for `apiClient`
- Enforcement (throwing a `TRPCError`) happens in middleware, keeping the context factory focused on extraction
- Revoked keys are treated as absent; `revokedAt` is checked before the key is considered valid

---

### Enforcing Authentication in Middleware

A reusable middleware layer checks that `apiClient` is present before allowing a procedure to proceed. This keeps enforcement out of individual procedure bodies.

```typescript
// server/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;

export const apiKeyProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.apiClient) {
    throw new TRPCError({
      code: 'UNAUTHORIZED',
      message: 'Valid API key required',
    });
  }

  return next({
    ctx: {
      ...ctx,
      apiClient: ctx.apiClient, // narrowed: no longer null
    },
  });
});
```

**Key Points:**
- `apiKeyProcedure` is used in place of `publicProcedure` for protected routes
- TypeScript narrows `ctx.apiClient` from `ApiClient | null` to `ApiClient` after the check
- Procedures built on `apiKeyProcedure` have guaranteed access to a non-null `apiClient` in their body

---

### Using the Protected Procedure

```typescript
// server/router.ts
import { router, apiKeyProcedure } from './trpc';
import { z } from 'zod';

export const appRouter = router({
  getWidgets: apiKeyProcedure
    .input(z.object({ page: z.number().int().min(1).default(1) }))
    .query(async ({ input, ctx }) => {
      return await db.widget.findMany({
        where: { ownerId: ctx.apiClient.id },
        skip: (input.page - 1) * 20,
        take: 20,
      });
    }),

  createWidget: apiKeyProcedure
    .input(z.object({ name: z.string().trim().max(100) }))
    .mutation(async ({ input, ctx }) => {
      return await db.widget.create({
        data: { name: input.name, ownerId: ctx.apiClient.id },
      });
    }),
});
```

---

### Scope-Based Authorization

API keys are often issued with a set of permitted scopes (e.g., `read:widgets`, `write:widgets`). A scope check middleware layer can be added on top of the base API key check.

```typescript
export function requireScope(scope: string) {
  return t.procedure
    .use(({ ctx, next }) => {
      if (!ctx.apiClient) {
        throw new TRPCError({ code: 'UNAUTHORIZED', message: 'Valid API key required' });
      }

      if (!ctx.apiClient.scopes.includes(scope)) {
        throw new TRPCError({
          code: 'FORBIDDEN',
          message: `API key does not have required scope: ${scope}`,
        });
      }

      return next({
        ctx: { ...ctx, apiClient: ctx.apiClient },
      });
    });
}
```

```typescript
export const appRouter = router({
  getWidgets: requireScope('read:widgets')
    .input(z.object({ page: z.number().int().min(1).default(1) }))
    .query(async ({ input, ctx }) => {
      // ...
    }),

  deleteWidget: requireScope('write:widgets')
    .input(z.object({ id: z.string().uuid() }))
    .mutation(async ({ input, ctx }) => {
      // ...
    }),
});
```

**Key Points:**
- Scopes are stored with the key record in the database and checked at request time
- A key may hold multiple scopes; `.includes()` checks for the presence of the required one
- [Inference] Scope strings are compared as plain values here; a more robust implementation might use a set or enum to avoid typos and enable exhaustive checks — behavior depends on implementation

---

### Secure Key Generation

API keys must be cryptographically random and long enough to resist brute force. Node's `crypto` module provides a suitable source.

```typescript
import crypto from 'crypto';

export function generateApiKey(): string {
  return `sk_live_${crypto.randomBytes(32).toString('hex')}`;
}
```

**Example** output:
```
sk_live_a3f2c1e9b4d7f0a6e2c8b5d1f4a7e0c3b6d9f2a5e8c1b4d7f0a3e6c9b2d5f8a1
```

**Key Points:**
- A prefix (`sk_live_`, `sk_test_`) makes keys identifiable by type and easy to detect in logs or accidental commits
- 32 bytes of randomness (64 hex characters) is well above minimum recommendations for unpredictability
- The prefix does not contribute entropy; all security comes from the random portion
- [Inference] Prefixed keys can be scanned for in version control and CI pipelines using secret scanning tools, which is a practical operational benefit

---

### Storing Keys Securely: Hashing

Storing raw API keys in the database means a database breach exposes all keys immediately. The preferred approach is to store a hash of the key and compare hashes at validation time — analogous to password storage.

```typescript
import crypto from 'crypto';

export function hashApiKey(key: string): string {
  return crypto.createHash('sha256').update(key).digest('hex');
}
```

**On key creation — store the hash, return the raw key once:**
```typescript
createApiKey: adminProcedure
  .input(z.object({ clientName: z.string(), scopes: z.array(z.string()) }))
  .mutation(async ({ input }) => {
    const rawKey = generateApiKey();
    const hashedKey = hashApiKey(rawKey);

    await db.apiKey.create({
      data: {
        key: hashedKey, // stored
        clientName: input.clientName,
        scopes: input.scopes,
      },
    });

    return { apiKey: rawKey }; // returned once; never retrievable again
  }),
```

**On validation — hash the incoming key and compare:**
```typescript
const hashedIncoming = hashApiKey(apiKey);

const client = await db.apiKey.findUnique({
  where: { key: hashedIncoming },
  select: { id: true, clientName: true, scopes: true, revokedAt: true },
});
```

**Key Points:**
- The raw key is shown to the user once at creation and never stored
- SHA-256 is acceptable for API key hashing because keys are already high-entropy random values; bcrypt or Argon2 are not necessary here (they are designed for low-entropy secrets like passwords)
- [Inference] A timing-safe comparison (`crypto.timingSafeEqual`) is preferable to direct string equality when comparing hashes, to reduce the risk of timing attacks — though the practical impact depends on the deployment environment

---

### Key Rotation and Revocation

API keys should be revocable without disrupting all keys, and rotation should be possible without downtime.

**Revocation:**
```typescript
revokeApiKey: adminProcedure
  .input(z.object({ keyId: z.string().uuid() }))
  .mutation(async ({ input }) => {
    await db.apiKey.update({
      where: { id: input.keyId },
      data: { revokedAt: new Date() },
    });
    return { revoked: true };
  }),
```

**Rotation — issue a new key, revoke the old one:**
```typescript
rotateApiKey: adminProcedure
  .input(z.object({ keyId: z.string().uuid() }))
  .mutation(async ({ input }) => {
    const rawKey = generateApiKey();
    const hashedKey = hashApiKey(rawKey);

    const oldKey = await db.apiKey.findUniqueOrThrow({
      where: { id: input.keyId },
    });

    await db.$transaction([
      db.apiKey.create({
        data: {
          key: hashedKey,
          clientName: oldKey.clientName,
          scopes: oldKey.scopes,
        },
      }),
      db.apiKey.update({
        where: { id: input.keyId },
        data: { revokedAt: new Date() },
      }),
    ]);

    return { apiKey: rawKey };
  }),
```

**Key Points:**
- Revocation sets a timestamp rather than deleting the record, preserving audit history
- Rotation issues a new key and revokes the old one atomically within a transaction
- [Inference] A grace period (where both old and new keys are valid simultaneously) can ease rotation for clients that cannot update immediately; this requires additional logic to track key state

---

### Rate Limiting Per API Key

API keys without rate limits can be used to exhaust server resources. Rate limiting should be applied per key identity, not per IP address, since API key clients may operate from shared or dynamic IPs.

```typescript
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(100, '60 s'),
});

export const rateLimitedApiKeyProcedure = t.procedure.use(async ({ ctx, next }) => {
  if (!ctx.apiClient) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  const { success } = await ratelimit.limit(`api-key:${ctx.apiClient.id}`);

  if (!success) {
    throw new TRPCError({
      code: 'TOO_MANY_REQUESTS',
      message: 'Rate limit exceeded',
    });
  }

  return next({ ctx: { ...ctx, apiClient: ctx.apiClient } });
});
```

**Key Points:**
- The rate limit key is the API key's database ID, not the raw key value
- `TOO_MANY_REQUESTS` is a valid tRPC error code corresponding to HTTP 429
- The example uses Upstash Redis; other rate limiting implementations are applicable
- [Inference] Rate limit thresholds depend on expected usage patterns; the values above are illustrative only

---

### Logging and Auditing Key Usage

API key usage should be logged for auditing, abuse detection, and debugging. Logging can be added in the same middleware that validates the key.

```typescript
export const apiKeyProcedure = t.procedure.use(async ({ ctx, path, type, next }) => {
  if (!ctx.apiClient) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  await db.apiKeyUsageLog.create({
    data: {
      apiKeyId: ctx.apiClient.id,
      procedure: path,
      type,
      timestamp: new Date(),
    },
  });

  return next({ ctx: { ...ctx, apiClient: ctx.apiClient } });
});
```

**Key Points:**
- `path` is the procedure path (e.g., `widgets.getWidgets`)
- `type` is `'query'` or `'mutation'`
- The raw API key value must never appear in logs
- [Inference] Logging every request synchronously in the middleware adds latency proportional to the database write; an async fire-and-forget write or a queue-based approach may be preferable under high load — behavior and impact depend on infrastructure

---

### Differentiating API Key Auth From User Auth

Applications often need to support both human user sessions and API key authentication simultaneously. A combined context and middleware pattern can serve both.

```typescript
export async function createContext({ req }: CreateExpressContextOptions) {
  const apiKey = req.headers['x-api-key'];
  const sessionToken = req.cookies?.['session'];

  if (apiKey && typeof apiKey === 'string') {
    const client = await resolveApiKey(apiKey);
    return { authType: 'apiKey' as const, apiClient: client, user: null };
  }

  if (sessionToken) {
    const user = await resolveSession(sessionToken);
    return { authType: 'session' as const, apiClient: null, user };
  }

  return { authType: 'none' as const, apiClient: null, user: null };
}
```

**Key Points:**
- `authType` makes the authentication method explicit and available to all downstream middleware and procedures
- Procedures can branch on `authType` if behavior should differ between API key and session callers
- [Inference] Giving API keys and user sessions access to the same procedures requires careful consideration of what each credential type should be permitted to do; shared procedures should be reviewed for both auth contexts

---

**Conclusion**

API key authentication in tRPC is implemented through the context factory and middleware layer. Keys are extracted from request headers in `createContext`, validated against stored records, and resolved into a typed context object. Middleware built on that context enforces authentication and optionally checks scopes. Secure key management requires cryptographically random generation, hash-based storage, revocation support, and per-key rate limiting. None of these are provided by tRPC itself — each must be deliberately implemented.