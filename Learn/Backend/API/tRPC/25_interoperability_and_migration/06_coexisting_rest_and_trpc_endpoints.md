## Coexisting REST and tRPC endpoints

---

### Why Coexistence Matters

Most production applications cannot migrate to tRPC in a single step. Existing REST endpoints may serve mobile clients, third-party integrations, or legacy systems that cannot be updated immediately. Coexistence allows tRPC to be introduced incrementally — new features can use tRPC while existing REST routes remain untouched.

**Key Points:**
- tRPC and REST can run on the same HTTP server simultaneously
- No breaking changes are required to existing REST consumers
- Migration can proceed route-by-route or feature-by-feature

---

### How tRPC Fits Into an Existing Server

tRPC is mounted as a request handler at a specific path prefix (commonly `/trpc`). All other paths continue to be handled by existing middleware or route definitions. This means the two systems share the same port and process without conflict.

The separation is purely path-based. Requests to `/trpc/*` are handled by tRPC; all other requests fall through to the existing router.

---

### Setup: Express With Existing REST Routes

The most common pattern in Node.js backends is mounting tRPC alongside Express routes.

```typescript
import express from 'express';
import * as trpcExpress from '@trpc/server/adapters/express';
import { appRouter } from './router';
import { createContext } from './context';

const app = express();

// Existing REST endpoint — untouched
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.get('/api/users/:id', (req, res) => {
  // existing logic
});

// tRPC mounted at /trpc
app.use(
  '/trpc',
  trpcExpress.createExpressMiddleware({
    router: appRouter,
    createContext,
  })
);

app.listen(3000);
```

**Key Points:**
- The `/api/*` routes are entirely unaffected
- tRPC handles only requests under `/trpc/*`
- Middleware like `express.json()` can be applied globally or scoped independently

---

### Setup: Next.js With Existing API Routes

In a Next.js project, REST endpoints live under `pages/api/` or `app/api/`. tRPC is mounted at a catch-all route such as `pages/api/trpc/[trpc].ts`. Other files in `pages/api/` continue to function as normal REST handlers.

```typescript
// pages/api/trpc/[trpc].ts
import * as trpcNext from '@trpc/server/adapters/next';
import { appRouter } from '../../../server/router';
import { createContext } from '../../../server/context';

export default trpcNext.createNextApiHandler({
  router: appRouter,
  createContext,
});
```

```typescript
// pages/api/webhook.ts  ← untouched REST endpoint
import type { NextApiRequest, NextApiResponse } from 'next';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  res.status(200).json({ received: true });
}
```

**Key Points:**
- The catch-all pattern `[trpc].ts` only intercepts requests matching `/api/trpc/*`
- All other files under `pages/api/` remain independent
- Webhook endpoints, OAuth callbacks, and similar routes are unaffected

---

### Sharing Authentication Middleware

A common concern is whether authentication logic must be duplicated. In practice, the same middleware or utility functions can be called from both REST handlers and the tRPC context factory.

```typescript
// shared/auth.ts
export function getUserFromRequest(req: Request) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return null;
  return verifyToken(token); // shared verification logic
}
```

```typescript
// tRPC context
import { getUserFromRequest } from '../shared/auth';

export function createContext({ req }: { req: Request }) {
  const user = getUserFromRequest(req);
  return { user };
}
```

```typescript
// Existing REST handler
import { getUserFromRequest } from '../shared/auth';

app.get('/api/orders', (req, res) => {
  const user = getUserFromRequest(req);
  if (!user) return res.status(401).json({ error: 'Unauthorized' });
  // ...
});
```

**Key Points:**
- Auth logic lives in one place and is imported by both systems
- No duplication is required
- [Inference] Keeping auth in a shared module reduces the risk of divergence between REST and tRPC auth behavior, though consistency depends on how the shared module is maintained

---

### Sharing Database or Service Clients

The same database clients, ORMs, or service instances can be passed through the tRPC context and used in REST handlers alike. There is no constraint that tRPC must own its own resource pool.

```typescript
// db.ts
import { PrismaClient } from '@prisma/client';
export const prisma = new PrismaClient();
```

```typescript
// tRPC context
import { prisma } from '../db';

export function createContext() {
  return { prisma };
}
```

```typescript
// REST handler
import { prisma } from '../db';

app.get('/api/products', async (req, res) => {
  const products = await prisma.product.findMany();
  res.json(products);
});
```

---

### Path Collision Avoidance

Care must be taken to ensure that tRPC's mount path does not overlap with existing route prefixes. If an existing REST API already uses `/trpc` as a prefix, the tRPC mount path should be changed.

```typescript
// Use a non-conflicting path
app.use(
  '/rpc',  // instead of /trpc
  trpcExpress.createExpressMiddleware({ router: appRouter, createContext })
);
```

On the client side, the `url` in `createTRPCProxyClient` must match:

```typescript
const trpc = createTRPCProxyClient<AppRouter>({
  links: [
    httpBatchLink({ url: 'http://localhost:3000/rpc' }),
  ],
});
```

---

### Gradual Migration Pattern

A practical migration strategy is to introduce tRPC for new features first, then progressively move existing REST endpoints into the tRPC router as those areas of the codebase are touched.

```
Phase 1: Mount tRPC alongside REST. New features use tRPC only.
Phase 2: Identify low-risk REST endpoints (internal, low-traffic).
Phase 3: Reimplement those endpoints as tRPC procedures.
Phase 4: Update consumers. Deprecate and remove the REST route.
Phase 5: Repeat until migration is complete, or stop if full migration is not a goal.
```

**Key Points:**
- There is no requirement to fully migrate; coexistence can be a permanent state
- Endpoints serving external consumers (third-party APIs, public REST APIs) may never be migrated, and that is a valid outcome
- [Inference] Migrating internal consumers first reduces risk, as they are typically easier to update

---

### Exposing tRPC Types Without Forcing Client Migration

During a migration period, some TypeScript clients may not yet use the tRPC client. The router types can still be exported and used independently for documentation or manual fetch calls, without requiring adoption of `createTRPCProxyClient`.

```typescript
// Export the router type for reference
export type AppRouter = typeof appRouter;
```

Consumers who are not yet using the tRPC client can reference these types manually or use them as documentation of expected input/output shapes. Actual type-safety on the wire only applies when using the tRPC client.

---

### Limitations and Considerations

- REST endpoints do not benefit from tRPC's type inference — changes to shared logic must be reflected manually in both systems
- Error response shapes will differ between tRPC (which uses its own error envelope) and REST (which typically returns custom JSON structures); clients must handle both
- [Inference] Running two routing systems increases the surface area for inconsistencies, particularly in error handling and response formatting, though the degree of impact depends on how well the systems are isolated
- OpenAPI or Swagger documentation will not automatically include tRPC procedures unless a separate adapter (such as `trpc-openapi`) is used

---

**Conclusion**

Coexisting REST and tRPC endpoints is a first-class scenario in tRPC's design. By mounting tRPC at a dedicated path prefix, existing REST routes are unaffected and can remain in service indefinitely. Shared authentication, database clients, and utility functions prevent duplication. Migration can be incremental, permanent in part, or skipped entirely for endpoints that must remain as REST — the architecture does not force a complete transition.