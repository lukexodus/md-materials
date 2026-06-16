## Zero-Downtime Deployments

Zero-downtime deployment means replacing a running version of your application with a new version without dropping in-flight requests or making the service unreachable to clients. For tRPC applications this involves both the HTTP server lifecycle and the tRPC-specific concerns of schema compatibility across versions.

---

### Core Problem: The Replacement Gap

When a new container or process replaces an old one, a naive deployment kills the old process, starts the new one, and routes traffic immediately. Requests arriving during startup fail. Requests in-flight during shutdown are dropped.

Zero-downtime deployment closes this gap with two mechanisms working together:

- **Graceful shutdown** — the old process finishes in-flight requests before exiting
- **Graceful startup** — the new process signals readiness before receiving traffic

Both must be in place. Either alone is insufficient.

---

### Graceful Shutdown in Node.js

Node.js does not automatically drain connections on `SIGTERM`. Without explicit handling, the process exits mid-request.

**Example — baseline graceful shutdown (`src/server.ts`):**

```ts
import { createServer } from "http";
import express from "express";
import * as trpcExpress from "@trpc/server/adapters/express";
import { appRouter } from "./router";
import { createContext } from "./context";

const app = express();

app.use("/trpc", trpcExpress.createExpressMiddleware({
  router: appRouter,
  createContext,
}));

const server = createServer(app);

server.listen(3000, () => {
  console.log("Server listening on port 3000");
});

// Graceful shutdown
const shutdown = (signal: string) => {
  console.log(`${signal} received — beginning graceful shutdown`);

  server.close((err) => {
    if (err) {
      console.error("Error during shutdown:", err);
      process.exit(1);
    }
    console.log("All connections drained — exiting");
    process.exit(0);
  });

  // Force exit if drain takes too long
  setTimeout(() => {
    console.error("Shutdown timeout exceeded — forcing exit");
    process.exit(1);
  }, 30_000).unref();
};

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT",  () => shutdown("SIGINT"));
```

**Key Points:**
- `server.close()` stops accepting new connections but waits for existing ones to finish
- The forced timeout prevents a hung connection from blocking the deployment indefinitely — 30 seconds is a common default but should be tuned to your longest expected request duration [Inference]
- `.unref()` on the timeout prevents it from keeping the event loop alive if shutdown completes cleanly before the timeout fires

---

### Keep-Alive Connections and the Drain Problem

HTTP keep-alive connections remain open between requests. `server.close()` does not terminate keep-alive connections that are idle between requests — they count as "open" and block shutdown.

**Example — forcing keep-alive header on shutdown:**

```ts
import { IncomingMessage, ServerResponse } from "http";

let isShuttingDown = false;

app.use((_req: IncomingMessage, res: ServerResponse, next: Function) => {
  if (isShuttingDown) {
    res.setHeader("Connection", "close");
  }
  next();
});

const shutdown = (signal: string) => {
  isShuttingDown = true;

  server.close((err) => {
    process.exit(err ? 1 : 0);
  });

  setTimeout(() => process.exit(1), 30_000).unref();
};
```

**Key Points:**
- Setting `Connection: close` on responses during shutdown signals clients to not reuse the connection, allowing the server to drain idle keep-alive sockets
- Libraries like `stoppable` automate this behavior by tracking and closing idle keep-alive connections on shutdown [Unverified — verify current maintenance status before adopting]

---

### Fastify Graceful Shutdown

Fastify has built-in close semantics that handle plugin teardown in addition to connection draining.

**Example:**

```ts
import Fastify from "fastify";
import { fastifyTRPCPlugin } from "@trpc/server/adapters/fastify";
import { appRouter } from "./router";
import { createContext } from "./context";

const server = Fastify();

await server.register(fastifyTRPCPlugin, {
  prefix: "/trpc",
  trpcOptions: { router: appRouter, createContext },
});

await server.listen({ port: 3000, host: "0.0.0.0" });

const shutdown = async (signal: string) => {
  console.log(`${signal} — closing Fastify server`);
  try {
    await server.close();
    process.exit(0);
  } catch (err) {
    console.error("Shutdown error:", err);
    process.exit(1);
  }
};

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT",  () => shutdown("SIGINT"));
```

**Key Points:**
- `server.close()` in Fastify triggers registered `onClose` hooks, allowing plugins (database pools, cache clients) to clean up in dependency order [Inference — depends on plugin registration and hook implementation]
- Fastify's `closeGraceDelay` option (available in some versions) adds a configurable delay before forceful close [Unverified — check current Fastify version docs]

---

### Readiness Gating: Only Accept Traffic When Ready

The new process must not receive traffic before it is fully initialized. This is enforced by delaying the readiness probe response until initialization completes.

**Example — deferred readiness:**

```ts
let isReady = false;

// Readiness probe — checked by load balancer before routing traffic
app.get("/ready", (_req, res) => {
  if (isReady) {
    res.status(200).json({ status: "ready" });
  } else {
    res.status(503).json({ status: "starting" });
  }
});

// Simulate async init (DB connection, cache warm-up, etc.)
async function initialize() {
  await db.$connect();
  await warmCache();
  isReady = true;
  console.log("Initialization complete — marking ready");
}

server.listen(3000, async () => {
  await initialize();
});
```

**Key Points:**
- The load balancer or orchestrator polls `/ready` and only adds the instance to the rotation once it returns `200`
- tRPC router initialization (procedure registration, middleware setup) is synchronous and completes before `listen()` resolves, so the main concern is async dependencies like database connections [Inference]

---

### Deployment Strategies

#### Rolling Deployment

New instances are brought up one at a time (or in batches). Old instances are terminated only after new ones pass readiness checks.

<svg viewBox="0 0 680 280" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12">
  <rect width="680" height="280" fill="#0f1117" rx="12"/>
  <text x="340" y="28" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Rolling Deployment Timeline</text>

  <!-- Time axis -->
  <line x1="40" y1="250" x2="640" y2="250" stroke="#334155" stroke-width="1.5"/>
  <text x="340" y="270" text-anchor="middle" fill="#64748b" font-size="11">time →</text>

  <!-- v1 instances -->
  <rect x="50"  y="50" width="180" height="36" rx="6" fill="#1e3a5f" stroke="#2563eb" stroke-width="1.5"/>
  <text x="140" y="73" text-anchor="middle" fill="#93c5fd" font-size="12">v1 — instance A</text>

  <rect x="50"  y="100" width="300" height="36" rx="6" fill="#1e3a5f" stroke="#2563eb" stroke-width="1.5"/>
  <text x="200" y="123" text-anchor="middle" fill="#93c5fd" font-size="12">v1 — instance B</text>

  <rect x="50"  y="150" width="420" height="36" rx="6" fill="#1e3a5f" stroke="#2563eb" stroke-width="1.5"/>
  <text x="260" y="173" text-anchor="middle" fill="#93c5fd" font-size="12">v1 — instance C</text>

  <!-- v2 instances -->
  <rect x="250" y="50" width="370" height="36" rx="6" fill="#1a2e1a" stroke="#16a34a" stroke-width="1.5"/>
  <text x="435" y="73" text-anchor="middle" fill="#86efac" font-size="12">v2 — instance A (ready)</text>

  <rect x="370" y="100" width="250" height="36" rx="6" fill="#1a2e1a" stroke="#16a34a" stroke-width="1.5"/>
  <text x="495" y="123" text-anchor="middle" fill="#86efac" font-size="12">v2 — instance B (ready)</text>

  <rect x="490" y="150" width="130" height="36" rx="6" fill="#1a2e1a" stroke="#16a34a" stroke-width="1.5"/>
  <text x="555" y="173" text-anchor="middle" fill="#86efac" font-size="12">v2 — instance C</text>

  <!-- overlap label -->
  <line x1="250" y1="40" x2="250" y2="200" stroke="#f59e0b" stroke-width="1" stroke-dasharray="4,3"/>
  <text x="254" y="38" fill="#f59e0b" font-size="10">overlap window</text>

  <!-- legend -->
  <rect x="50" y="220" width="14" height="14" rx="2" fill="#1e3a5f" stroke="#2563eb"/>
  <text x="70" y="232" fill="#94a3b8" font-size="11">v1 running</text>
  <rect x="160" y="220" width="14" height="14" rx="2" fill="#1a2e1a" stroke="#16a34a"/>
  <text x="180" y="232" fill="#94a3b8" font-size="11">v2 running</text>
</svg>

#### Blue-Green Deployment

Two identical environments exist (blue = current, green = next). Traffic is switched atomically at the load balancer level after green passes all health checks.

**Key Points:**
- Blue-green eliminates the overlap window where two versions handle traffic simultaneously — relevant for tRPC schema compatibility (see below)
- Requires double the infrastructure during the switch [Inference — cost model depends on platform]
- Rollback is fast: flip traffic back to blue

#### Canary Deployment

A small percentage of traffic is routed to the new version before full rollout. Errors or latency regressions trigger automatic rollback.

**Key Points:**
- Canary is the most risk-tolerant strategy but requires traffic-splitting infrastructure (e.g., Nginx weighted upstreams, AWS ALB weighted target groups, Kubernetes traffic splitting via service mesh)
- tRPC schema changes must be backward-compatible during canary — clients on v1 will call handlers on v2 instances [Inference — depends on router compatibility]

---

### tRPC-Specific Concern: Schema Compatibility During Overlap

During a rolling or canary deployment, both old and new versions of the tRPC server handle traffic simultaneously. If the new version changes a procedure's input or output schema in a breaking way, requests from clients expecting the old schema will fail against new instances.

**Breaking changes that cause overlap failures:**
- Removing a procedure
- Renaming a procedure
- Adding a required input field
- Changing an output field type

**Safe changes during rolling deployment:**
- Adding an optional input field (with `.optional()` or `.default()`)
- Adding new procedures
- Adding new optional output fields

**Example — backward-compatible addition:**

```ts
// v1 procedure
export const userRouter = router({
  getUser: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(({ input }) => getUserById(input.id)),
});

// v2 — adds optional field, does not break v1 clients
export const userRouter = router({
  getUser: publicProcedure
    .input(z.object({
      id: z.string(),
      includeProfile: z.boolean().optional().default(false), // safe addition
    }))
    .query(({ input }) => getUserById(input.id, input.includeProfile)),
});
```

**Key Points:**
- Treat the overlap window as a contract boundary — both versions must honor the previous version's schema
- For genuinely breaking changes, use blue-green (atomic switch) or version the router (e.g., `/api/trpc/v2/`) and migrate clients before retiring v1

---

### Router Versioning for Breaking Changes

When a breaking schema change cannot be avoided, route versioning allows both versions to coexist until clients have migrated.

**Example — versioned tRPC handlers in Next.js:**

```
app/
  api/
    trpc/
      [...trpc]/route.ts      ← v1 handler (legacy)
    trpc-v2/
      [...trpc]/route.ts      ← v2 handler (new schema)
```

**Example — v2 handler:**

```ts
// app/api/trpc-v2/[...trpc]/route.ts
import { fetchRequestHandler } from "@trpc/server/adapters/fetch";
import { appRouterV2 } from "@/server/routers/v2";
import { createContext } from "@/server/context";

const handler = (req: Request) =>
  fetchRequestHandler({
    endpoint: "/api/trpc-v2",
    req,
    router: appRouterV2,
    createContext,
  });

export { handler as GET, handler as POST };
```

**Key Points:**
- v1 and v2 handlers share context and database access — only the router differs
- Client-side tRPC clients are initialized with the matching endpoint URL
- v1 can be deprecated with a sunset header (`Deprecation`, `Sunset`) to signal migration urgency [Inference — non-standard headers, interpretation is client-dependent]

---

### Platform-Level Zero-Downtime Patterns

#### Kubernetes

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0      # never remove an old pod before a new one is ready
      maxSurge: 1            # allow one extra pod during rollout
  template:
    spec:
      containers:
        - name: app
          lifecycle:
            preStop:
              exec:
                command: ["sleep", "5"]   # grace period for LB to deregister
      terminationGracePeriodSeconds: 40   # must exceed shutdown timeout in code
```

**Key Points:**
- `maxUnavailable: 0` combined with readiness probes guarantees traffic is never routed to an unready pod
- The `preStop` sleep gives the load balancer time to stop sending new requests before `SIGTERM` is issued — without it, requests can arrive after shutdown begins [Inference — exact timing depends on LB implementation and probe interval]
- `terminationGracePeriodSeconds` must exceed your application-level shutdown timeout, otherwise Kubernetes sends `SIGKILL` before graceful drain completes

#### Serverless / Edge (Vercel, Cloudflare Workers)

Serverless deployments have a different zero-downtime model — the platform manages instance replacement. However:

**Key Points:**
- Old function instances continue handling in-flight requests while new ones are provisioned [Inference — platform-specific, verify with provider documentation]
- Schema compatibility during overlap still applies — old clients may call new function versions
- Cold start latency can create apparent downtime if not mitigated (keep-warm strategies, edge caching) [Speculation — mitigation effectiveness varies significantly by workload]

---

### Shutdown Checklist for tRPC Applications

- Stop accepting new connections (`server.close()`)
- Set `Connection: close` on responses during drain
- Close database connection pools after drain completes
- Close cache client connections (Redis, Memcached)
- Flush any pending telemetry or log buffers
- Exit with code `0` on clean shutdown, `1` on error

**Example — sequenced teardown:**

```ts
const shutdown = async () => {
  isShuttingDown = true;

  await new Promise<void>((resolve, reject) => {
    server.close((err) => (err ? reject(err) : resolve()));
  });

  await db.$disconnect();
  await redisClient.quit();

  console.log("Graceful shutdown complete");
  process.exit(0);
};
```

---

**Conclusion:**
Zero-downtime deployment in tRPC applications requires coordinating three concerns: graceful process shutdown (draining in-flight requests), readiness gating (preventing premature traffic routing to new instances), and schema compatibility (ensuring old clients can call new server versions during the overlap window). The deployment strategy — rolling, blue-green, or canary — determines how long the overlap window lasts and therefore how strictly schema compatibility must be maintained. Platform-specific behavior (Kubernetes probe timing, serverless instance replacement) should be verified against your target environment, as timing guarantees vary.