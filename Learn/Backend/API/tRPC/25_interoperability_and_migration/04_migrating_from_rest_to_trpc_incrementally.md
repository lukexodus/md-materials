## Migrating from REST to tRPC Incrementally

A full rewrite from REST to tRPC in one step is high-risk in any production system. Incremental migration keeps the existing REST API operational while tRPC is introduced procedure by procedure, allowing teams to validate the new layer, update clients gradually, and roll back individual routes without affecting the whole API surface.

---

### Core Principle: Coexistence Before Replacement

The REST API and tRPC router must coexist on the same server during the migration. Traffic to unmigrated routes continues through the REST handler. Migrated routes are handled by tRPC. The switch happens per-route, not per-service.

**Key Points:**
- tRPC is mounted at a new path prefix (e.g., `/trpc`) alongside the existing REST prefix (e.g., `/api`)
- No existing REST client is broken during the migration period
- Each migrated route has a defined cutover point after which the REST version can be removed
- The migration can be paused or reversed at any route without cascading effects [Inference]

---

### Phase 1: Install and Mount tRPC Without Touching Existing Routes

The first step adds tRPC to the server as a new, empty router. Existing REST routes are untouched.

**Example — Express server before migration:**

```ts
import express from "express";
import userRoutes from "./routes/users";
import postRoutes from "./routes/posts";

const app = express();
app.use(express.json());

app.use("/api/users", userRoutes);
app.use("/api/posts", postRoutes);

app.listen(3000);
```

**Example — after Phase 1 (tRPC added alongside REST):**

```ts
import express from "express";
import { createExpressMiddleware } from "@trpc/server/adapters/express";
import { appRouter } from "./trpc/routers/_app";
import { createContext } from "./trpc/context";
import userRoutes from "./routes/users";
import postRoutes from "./routes/posts";

const app = express();
app.use(express.json());

// Existing REST routes — unchanged
app.use("/api/users", userRoutes);
app.use("/api/posts", postRoutes);

// tRPC — new prefix, no conflict
app.use("/trpc", createExpressMiddleware({
  router: appRouter,
  createContext,
}));

app.listen(3000);
```

**Example — initial empty tRPC router (`src/trpc/routers/_app.ts`):**

```ts
import { router } from "../trpc";

export const appRouter = router({
  // procedures will be added here as routes are migrated
});

export type AppRouter = typeof appRouter;
```

**Key Points:**
- The empty router is valid and operational — it simply has no procedures yet
- `/api` and `/trpc` are completely independent — middleware, error handling, and authentication are separate until deliberately unified

---

### Phase 2: Establish Shared Infrastructure

Before migrating individual routes, the tRPC layer needs context, authentication middleware, and error formatting that mirrors what the REST layer already does. Migrating these once prevents per-procedure duplication.

**Example — extracting shared auth logic into tRPC middleware:**

```ts
// Existing REST auth middleware
// express: req.user is set by verifyToken middleware

// tRPC equivalent — src/trpc/context.ts
import { Request, Response } from "express";
import { verifyToken } from "../auth/token";
import { db } from "../db";

export async function createContext({ req, res }: { req: Request; res: Response }) {
  const token = req.headers.authorization?.replace("Bearer ", "");
  const user = token ? await verifyToken(token) : null;

  return { req, res, user, db };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Example — tRPC auth middleware mirroring REST behavior:**

```ts
// src/trpc/trpc.ts
import { initTRPC, TRPCError } from "@trpc/server";
import type { Context } from "./context";

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;

export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({ code: "UNAUTHORIZED" });
  }
  return next({ ctx: { ...ctx, user: ctx.user } });
});
```

**Key Points:**
- Reusing the existing `verifyToken` function in tRPC context avoids duplicating auth logic — one source of truth for token verification during the migration period
- The REST layer and tRPC layer can share database clients, loggers, and config without any coupling between the two HTTP layers
- Auth behavior parity between REST and tRPC should be validated before migrating the first route [Inference]

---

### Phase 3: Migrate Routes One at a Time

Each REST route is reimplemented as a tRPC procedure. The REST route remains active. Once clients are updated to call the tRPC procedure, the REST route is deprecated and eventually removed.

**Migration order heuristics:**
- Start with low-traffic, low-risk routes to validate the pattern
- Migrate leaf routes (no dependents) before hub routes (many dependents)
- Prioritize routes with complex input validation — these benefit most from Zod
- Defer routes with file uploads, streaming, or unusual content types — these require special handling in tRPC [Inference]

**Example — existing REST route (`src/routes/users.ts`):**

```ts
import { Router } from "express";
import { db } from "../db";

const router = Router();

router.get("/:id", async (req, res) => {
  try {
    const user = await db.user.findUnique({ where: { id: req.params.id } });
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json(user);
  } catch {
    res.status(500).json({ error: "Internal server error" });
  }
});

router.post("/", async (req, res) => {
  const { name, email } = req.body;
  if (!name || !email) return res.status(400).json({ error: "name and email required" });

  try {
    const user = await db.user.create({ data: { name, email } });
    res.status(201).json(user);
  } catch {
    res.status(500).json({ error: "Internal server error" });
  }
});

export default router;
```

**Example — migrated tRPC equivalent (`src/trpc/routers/user.ts`):**

```ts
import { z } from "zod";
import { router, publicProcedure, protectedProcedure } from "../trpc";
import { TRPCError } from "@trpc/server";

export const userRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input, ctx }) => {
      const user = await ctx.db.user.findUnique({ where: { id: input.id } });

      if (!user) {
        throw new TRPCError({ code: "NOT_FOUND", message: "User not found" });
      }

      return user;
    }),

  create: protectedProcedure
    .input(z.object({
      name: z.string().min(1),
      email: z.string().email(),
    }))
    .mutation(async ({ input, ctx }) => {
      return ctx.db.user.create({ data: input });
    }),
});
```

**Example — registering in the app router:**

```ts
import { router } from "../trpc";
import { userRouter } from "./user";

export const appRouter = router({
  user: userRouter,
});

export type AppRouter = typeof appRouter;
```

**Key Points:**
- The tRPC procedure and the REST route are both live simultaneously — the REST route is not removed until clients have migrated
- Zod replaces manual `if (!name || !email)` validation — the error surface becomes consistent across all tRPC procedures automatically
- `TRPCError` with `NOT_FOUND` replaces `res.status(404)` — the HTTP status is handled by the tRPC adapter

---

### Phase 4: Migrating Clients Incrementally

Client-side migration is independent of server-side migration. A client can switch from calling `GET /api/users/:id` to calling `trpc.user.getById.query({ id })` at any time after the tRPC procedure is live.

**Example — initializing the tRPC client alongside existing fetch calls:**

```ts
// src/client/trpc.ts
import { createTRPCClient, httpBatchLink } from "@trpc/client";
import type { AppRouter } from "../../server/trpc/routers/_app";

export const trpc = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({ url: "/trpc" }),
  ],
});
```

**Example — per-feature migration (before and after):**

```ts
// Before — REST fetch
async function getUser(id: string) {
  const res = await fetch(`/api/users/${id}`);
  if (!res.ok) throw new Error("Failed to fetch user");
  return res.json();
}

// After — tRPC client
async function getUser(id: string) {
  return trpc.user.getById.query({ id });
}
```

**Key Points:**
- Both functions have the same external signature — callers do not need to change
- The switch is a one-line change per call site after the tRPC client is set up
- Type safety is gained immediately on the tRPC call — `id` is typed, the return type is inferred
- React Query integration (`@trpc/react-query`) can be introduced per-feature without migrating all existing queries [Inference]

---

### Handling the Overlap Period: Route Parity Checklist

During the overlap period, both REST and tRPC versions of a route must behave identically from the client's perspective. A parity checklist per route:

```
[ ] Same authentication requirements
[ ] Same authorization rules (who can access what data)
[ ] Same input validation (required fields, formats, constraints)
[ ] Same error responses (status codes, error message format)
[ ] Same response shape (field names, types, nullability)
[ ] Same side effects (emails sent, events emitted, cache invalidated)
[ ] Same rate limiting behavior
[ ] Pagination and filtering behavior matches
```

**Key Points:**
- Divergence in error shape between REST and tRPC is the most common parity failure — REST often returns `{ "error": "message" }` while tRPC returns a structured envelope [Inference]
- Side effects are highest risk — if both the REST route and the tRPC procedure are accidentally called for the same operation, duplicate emails or double-charged payments can result [Inference — depends on client migration discipline]

---

### Using `createCallerFactory` for Shared Business Logic

During migration, business logic may exist in both REST route handlers and new tRPC procedures. Rather than duplicating it, REST routes can call tRPC procedures directly using server-side callers.

**Example — REST route delegating to tRPC procedure:**

```ts
import { createCallerFactory } from "@trpc/server";
import { appRouter } from "../trpc/routers/_app";
import { createContext } from "../trpc/context";

const createCaller = createCallerFactory(appRouter);

// Existing REST route — now delegates to tRPC procedure
router.get("/:id", async (req, res) => {
  const caller = createCaller(await createContext({ req, res }));

  try {
    const user = await caller.user.getById({ id: req.params.id });
    res.json(user);
  } catch (err: any) {
    const status = err.data?.httpStatus ?? 500;
    res.status(status).json({ error: err.message });
  }
});
```

**Key Points:**
- `createCallerFactory` calls procedures server-side with no HTTP round-trip — context is shared
- This pattern means business logic lives only in the tRPC procedure — the REST route is just a thin adapter
- REST route removal becomes trivial: the logic is already in tRPC, so deleting the REST route leaves nothing behind [Inference]
- Error shape translation from tRPC errors to REST-style responses must be done explicitly in the catch block

---

### Incremental Migration Flow

<svg viewBox="0 0 700 420" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12">
  <rect width="700" height="420" fill="#0f1117" rx="12"/>
  <text x="350" y="28" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Incremental REST → tRPC Migration Phases</text>

  <!-- Phase 1 -->
  <rect x="30" y="50" width="620" height="70" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
  <text x="50" y="72" fill="#94a3b8" font-size="12" font-weight="bold">Phase 1 — Mount tRPC alongside REST</text>
  <text x="50" y="92" fill="#64748b" font-size="11">REST: /api/* active and unchanged    tRPC: /trpc/* mounted, empty router</text>
  <text x="50" y="110" fill="#475569" font-size="10">Risk: none — no existing behavior changed</text>

  <!-- Arrow -->
  <line x1="340" y1="120" x2="340" y2="145" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>

  <!-- Phase 2 -->
  <rect x="30" y="145" width="620" height="70" rx="8" fill="#1e293b" stroke="#2563eb" stroke-width="1.5"/>
  <text x="50" y="167" fill="#93c5fd" font-size="12" font-weight="bold">Phase 2 — Establish shared infrastructure</text>
  <text x="50" y="187" fill="#64748b" font-size="11">Shared: context, auth middleware, DB client, error formatter</text>
  <text x="50" y="205" fill="#475569" font-size="10">Risk: low — infrastructure only, no procedure logic yet</text>

  <!-- Arrow -->
  <line x1="340" y1="215" x2="340" y2="240" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>

  <!-- Phase 3 -->
  <rect x="30" y="240" width="620" height="70" rx="8" fill="#1e3a5f" stroke="#2563eb" stroke-width="1.5"/>
  <text x="50" y="262" fill="#93c5fd" font-size="12" font-weight="bold">Phase 3 — Migrate routes (repeated per route)</text>
  <text x="50" y="282" fill="#64748b" font-size="11">Implement tRPC procedure   →   Validate parity   →   REST route stays active</text>
  <text x="50" y="300" fill="#475569" font-size="10">Risk: medium — parity between REST and tRPC must be verified before client migration</text>

  <!-- Arrow -->
  <line x1="340" y1="310" x2="340" y2="335" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>

  <!-- Phase 4 -->
  <rect x="30" y="335" width="620" height="70" rx="8" fill="#1a2e1a" stroke="#16a34a" stroke-width="1.5"/>
  <text x="50" y="357" fill="#86efac" font-size="12" font-weight="bold">Phase 4 — Migrate clients + remove REST routes</text>
  <text x="50" y="377" fill="#64748b" font-size="11">Clients switch to tRPC   →   REST route deprecated   →   REST route deleted</text>
  <text x="50" y="395" fill="#475569" font-size="10">Risk: low per route — client switch is isolated; REST can be kept as fallback temporarily</text>

  <defs>
    <marker id="a" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
    </marker>
  </defs>
</svg>

---

### Managing the Deprecation of REST Routes

Once clients have migrated off a REST route, the route should be formally deprecated before removal to catch any stragglers.

**Example — deprecation response header:**

```ts
router.get("/:id", async (req, res) => {
  res.setHeader("Deprecation", "true");
  res.setHeader("Sunset", "Sat, 01 Nov 2025 00:00:00 GMT");
  res.setHeader("Link", '</trpc/user.getById>; rel="successor-version"');

  // ... existing handler
});
```

**Example — logging deprecated REST calls:**

```ts
router.get("/:id", async (req, res) => {
  logger.warn({
    msg: "Deprecated REST endpoint called",
    path: req.path,
    userAgent: req.headers["user-agent"],
    ip: req.ip,
  });

  res.setHeader("Deprecation", "true");
  // ... handler
});
```

**Key Points:**
- `Sunset` header communicates a removal date — clients observing this header can prioritize migration [Inference — header support varies by HTTP client]
- Logging deprecated calls gives visibility into which clients are still using the old endpoint before removal
- Setting an internal deadline for REST route removal prevents indefinite coexistence and migration debt accumulation [Inference]

---

### Handling Routes That Don't Map Cleanly to tRPC

Some REST patterns require adaptation rather than direct translation.

#### File Upload Routes

tRPC does not natively handle `multipart/form-data`. File upload routes should remain as REST endpoints or be handled by a separate dedicated upload service, with the tRPC procedure receiving only the resulting file URL or reference.

```ts
// REST route stays — handles multipart upload
app.post("/api/uploads", uploadMiddleware, async (req, res) => {
  const url = await uploadToStorage(req.file);
  res.json({ url });
});

// tRPC procedure uses the result
export const mediaRouter = router({
  attachToPost: protectedProcedure
    .input(z.object({ postId: z.string(), fileUrl: z.string().url() }))
    .mutation(({ input, ctx }) =>
      ctx.db.post.update({
        where: { id: input.postId },
        data: { mediaUrl: input.fileUrl },
      })
    ),
});
```

#### Webhook Receiver Routes

Webhooks arrive from third-party services with fixed payloads and custom signature headers. These are not well-suited to tRPC input validation (which expects JSON-RPC-style input). Keep them as REST routes.

```ts
// REST route stays — webhook receiver
app.post("/api/webhooks/stripe", express.raw({ type: "application/json" }), async (req, res) => {
  const sig = req.headers["stripe-signature"];
  const event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_SECRET);
  // ... handle event
  res.json({ received: true });
});
```

#### Routes with Custom Content Types or Binary Responses

Routes returning CSV, PDF, or binary data cannot be returned from tRPC procedures in a straightforward way. Retain them as REST routes.

**Key Points:**
- Not every route must be migrated to tRPC — tRPC is well-suited for JSON RPC-style interactions, not file I/O or webhook receivers
- A pragmatic migration targets the bulk of CRUD and business logic routes while leaving special-purpose routes on REST

---

### Tracking Migration Progress

A simple tracking structure prevents routes from falling through the cracks.

**Example — migration tracking table (in a team doc or code comment):**

```
Route                        | tRPC Procedure          | Server | Client | REST Removed
-----------------------------|-------------------------|--------|--------|-------------
GET    /api/users/:id        | user.getById            | ✅     | ✅     | ✅
POST   /api/users            | user.create             | ✅     | 🔄     | ❌
GET    /api/posts            | post.list               | ✅     | ❌     | ❌
POST   /api/posts            | post.create             | 🔄     | ❌     | ❌
PUT    /api/posts/:id        | post.update             | ❌     | ❌     | ❌
POST   /api/uploads          | (stays REST)            | —      | —      | —
POST   /api/webhooks/stripe  | (stays REST)            | —      | —      | —
```

**Key Points:**
- Separating server migration from client migration acknowledges that they proceed at different rates
- Routes marked "(stays REST)" prevent them from being revisited repeatedly in planning discussions
- The table doubles as a checklist for the deprecation and removal phase [Inference]

---

### Testing Strategy During Migration

**Example — shared test helper calling both REST and tRPC:**

```ts
// Test parity between REST and tRPC during migration overlap
describe("user.getById parity", () => {
  const userId = "123";

  it("REST: returns user", async () => {
    const res = await request(app).get(`/api/users/${userId}`).expect(200);
    expect(res.body.id).toBe(userId);
  });

  it("tRPC: returns same user shape", async () => {
    const caller = createCaller(testContext);
    const user = await caller.user.getById({ id: userId });
    expect(user.id).toBe(userId);
  });

  it("REST and tRPC return identical shapes", async () => {
    const restRes = await request(app).get(`/api/users/${userId}`);
    const caller = createCaller(testContext);
    const trpcRes = await caller.user.getById({ id: userId });

    // Compare field-by-field, not object identity
    expect(restRes.body.id).toBe(trpcRes.id);
    expect(restRes.body.name).toBe(trpcRes.name);
    expect(restRes.body.email).toBe(trpcRes.email);
  });
});
```

**Key Points:**
- Running parity tests before migrating clients provides confidence that the tRPC procedure produces identical output
- After client migration is complete, the REST parity tests can be removed alongside the REST route

---

**Conclusion:**
Incremental migration from REST to tRPC is a phased process: mount tRPC alongside REST without disruption, establish shared infrastructure, migrate procedures one at a time while keeping REST routes active, then switch clients and remove REST routes per route. The `createCallerFactory` pattern allows REST routes to delegate to tRPC procedures during the overlap period, consolidating business logic before the REST layer is removed. Routes involving file uploads, webhooks, or binary responses may be better left as REST permanently. Tracking migration state per route and running parity tests across both layers throughout the overlap period reduces the risk of behavioral divergence. Actual migration complexity depends heavily on existing codebase structure and should be evaluated per route.