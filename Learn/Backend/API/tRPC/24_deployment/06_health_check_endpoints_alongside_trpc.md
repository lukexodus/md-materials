## Health Check Endpoints Alongside tRPC

tRPC handles typed RPC communication well, but health checks are a different concern — they need to be reachable by load balancers, container orchestrators, and uptime monitors that know nothing about tRPC's protocol. This requires exposing plain HTTP endpoints that coexist with the tRPC handler on the same server.

---

### Why tRPC Is Not Suitable for Health Checks Directly

tRPC procedures are callable via HTTP, but they carry protocol overhead (JSON-RPC-style envelopes, batch support, content-type requirements) that health check consumers do not handle. Kubernetes liveness probes, AWS ALB target group checks, and most uptime monitors issue a plain `GET` request and expect a `200 OK` with no ceremony.

**Key Points:**
- Health check consumers expect bare HTTP — no tRPC client, no special headers
- tRPC's `/api/trpc/*` path expects structured input; a plain `GET` to a procedure URL without proper query params typically returns a 400 or parsing error
- Mixing health logic into tRPC procedures couples infrastructure concerns to application logic

---

### Placement Strategy: Registering Health Routes Before tRPC

The general pattern across all adapters is to register health check routes on the underlying HTTP server before or alongside the tRPC handler. The tRPC handler acts as a catch-all for its path prefix, so health routes must be registered on a different path.

---

### Next.js: File-Based Route Alongside tRPC Route

In a Next.js App Router or Pages Router project, the tRPC handler lives at `app/api/trpc/[trpc]/route.ts` (or `pages/api/trpc/[...trpc].ts`). A health endpoint is a separate route file.

**Example — `app/api/health/route.ts` (App Router):**

```ts
import { NextResponse } from "next/server";
import { db } from "@/server/db";

export async function GET() {
  try {
    await db.$queryRaw`SELECT 1`;

    return NextResponse.json(
      { status: "ok", timestamp: new Date().toISOString() },
      { status: 200 }
    );
  } catch (error) {
    return NextResponse.json(
      { status: "error", detail: "Database unreachable" },
      { status: 503 }
    );
  }
}
```

**Key Points:**
- `/api/health` is entirely independent of the tRPC handler at `/api/trpc`
- The `503 Service Unavailable` status on failure signals to load balancers to stop routing traffic to this instance
- `db.$queryRaw\`SELECT 1\`` (Prisma) is a lightweight connectivity check — behavior may vary across database drivers and connection pool states

---

### Express: Middleware Registration Order

With `express-adapter` (or a custom Express setup), the tRPC handler is mounted as middleware. Health routes must be registered before or on a different path.

**Example — `src/server.ts`:**

```ts
import express from "express";
import * as trpcExpress from "@trpc/server/adapters/express";
import { appRouter } from "./router";
import { createContext } from "./context";
import { db } from "./db";

const app = express();

// Health check — registered before tRPC handler
app.get("/health", async (_req, res) => {
  try {
    await db.$queryRaw`SELECT 1`;
    res.status(200).json({ status: "ok" });
  } catch {
    res.status(503).json({ status: "error" });
  }
});

// Readiness check — distinguishes ready from alive
app.get("/ready", (_req, res) => {
  res.status(200).json({ status: "ready" });
});

// tRPC handler
app.use(
  "/trpc",
  trpcExpress.createExpressMiddleware({
    router: appRouter,
    createContext,
  })
);

app.listen(3000);
```

**Key Points:**
- Express resolves routes in registration order — placing `/health` before the tRPC middleware guarantees it is never intercepted
- `/health` (liveness) and `/ready` (readiness) serve different purposes and are often probed separately by Kubernetes

---

### Fastify: Plugin or Route Registration

With `@trpc/server/adapters/fastify`, the tRPC handler is registered as a Fastify plugin. Health routes are registered as sibling routes.

**Example — `src/server.ts`:**

```ts
import Fastify from "fastify";
import { fastifyTRPCPlugin } from "@trpc/server/adapters/fastify";
import { appRouter } from "./router";
import { createContext } from "./context";

const server = Fastify();

// Health route
server.get("/health", async (_request, reply) => {
  return reply.status(200).send({ status: "ok" });
});

// tRPC plugin
await server.register(fastifyTRPCPlugin, {
  prefix: "/trpc",
  trpcOptions: { router: appRouter, createContext },
});

await server.listen({ port: 3000, host: "0.0.0.0" });
```

**Key Points:**
- Fastify's route registration is not strictly order-dependent for non-overlapping paths, but keeping health routes registered before plugins is a conventional clarity choice [Inference]
- `host: "0.0.0.0"` is required in containerized environments so the port is reachable from outside the container

---

### Health Check Response Schema

A minimal but useful health response includes status, timestamp, and optionally per-dependency states.

**Example — structured health payload:**

```ts
type HealthStatus = "ok" | "degraded" | "error";

interface HealthResponse {
  status: HealthStatus;
  timestamp: string;
  version?: string;
  checks?: {
    database?: HealthStatus;
    cache?: HealthStatus;
  };
}
```

**Example — multi-dependency check:**

```ts
app.get("/health", async (_req, res) => {
  const checks: HealthResponse["checks"] = {};
  let overall: HealthStatus = "ok";

  try {
    await db.$queryRaw`SELECT 1`;
    checks.database = "ok";
  } catch {
    checks.database = "error";
    overall = "error";
  }

  try {
    await redis.ping();
    checks.cache = "ok";
  } catch {
    checks.cache = "degraded";
    if (overall === "ok") overall = "degraded";
  }

  const statusCode = overall === "error" ? 503 : 200;

  res.status(statusCode).json({
    status: overall,
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION,
    checks,
  });
});
```

**Key Points:**
- Returning `200` even when degraded allows traffic to continue while alerting monitoring systems — whether to do this depends on whether the degraded dependency is critical [Inference — treat as an architectural decision, not a universal rule]
- `APP_VERSION` tied to a git SHA or release tag helps correlate health responses with deployed artifacts

---

### Liveness vs. Readiness vs. Startup Probes

These three probe types map to distinct Kubernetes concepts but are also useful outside Kubernetes as a mental model.

<svg viewBox="0 0 700 310" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="13">
  <rect width="700" height="310" fill="#0f1117" rx="12"/>
  <text x="350" y="32" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">Probe Types and Their Roles</text>

  <!-- Liveness -->
  <rect x="30" y="55" width="195" height="110" rx="8" fill="#1e293b" stroke="#2563eb" stroke-width="1.5"/>
  <text x="127" y="78" text-anchor="middle" fill="#93c5fd" font-size="13" font-weight="bold">Liveness</text>
  <text x="127" y="98" text-anchor="middle" fill="#64748b" font-size="11">GET /health</text>
  <text x="40" y="120" fill="#94a3b8" font-size="11">• Is the process alive?</text>
  <text x="40" y="138" fill="#94a3b8" font-size="11">• Failure → restart container</text>
  <text x="40" y="156" fill="#94a3b8" font-size="11">• Lightweight, no DB check</text>

  <!-- Readiness -->
  <rect x="252" y="55" width="195" height="110" rx="8" fill="#1e293b" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="349" y="78" text-anchor="middle" fill="#c4b5fd" font-size="13" font-weight="bold">Readiness</text>
  <text x="349" y="98" text-anchor="middle" fill="#64748b" font-size="11">GET /ready</text>
  <text x="262" y="120" fill="#94a3b8" font-size="11">• Can it serve traffic?</text>
  <text x="262" y="138" fill="#94a3b8" font-size="11">• Failure → remove from LB</text>
  <text x="262" y="156" fill="#94a3b8" font-size="11">• Check DB, cache, deps</text>

  <!-- Startup -->
  <rect x="474" y="55" width="195" height="110" rx="8" fill="#1e293b" stroke="#059669" stroke-width="1.5"/>
  <text x="571" y="78" text-anchor="middle" fill="#6ee7b7" font-size="13" font-weight="bold">Startup</text>
  <text x="571" y="98" text-anchor="middle" fill="#64748b" font-size="11">GET /startup</text>
  <text x="484" y="120" fill="#94a3b8" font-size="11">• Has init completed?</text>
  <text x="484" y="138" fill="#94a3b8" font-size="11">• Disables liveness until ok</text>
  <text x="484" y="156" fill="#94a3b8" font-size="11">• Slow-start safe</text>

  <!-- Kubernetes config box -->
  <rect x="30" y="188" width="640" height="100" rx="8" fill="#1a1a2e" stroke="#334155" stroke-width="1.5"/>
  <text x="50" y="210" fill="#64748b" font-size="11">Kubernetes probe config (excerpt)</text>
  <text x="50" y="232" fill="#7dd3fc" font-size="11">livenessProbe:  httpGet: { path: /health, port: 3000 }  initialDelaySeconds: 10  periodSeconds: 15</text>
  <text x="50" y="252" fill="#c4b5fd" font-size="11">readinessProbe: httpGet: { path: /ready,  port: 3000 }  initialDelaySeconds: 5   periodSeconds: 10</text>
  <text x="50" y="272" fill="#6ee7b7" font-size="11">startupProbe:   httpGet: { path: /startup, port: 3000 } failureThreshold: 30     periodSeconds: 10</text>
</svg>

---

### Exposing Version and Build Metadata

Health endpoints are a natural place to expose non-sensitive build metadata useful for deployment verification.

**Example:**

```ts
app.get("/health", (_req, res) => {
  res.status(200).json({
    status: "ok",
    version: process.env.APP_VERSION ?? "unknown",
    commit: process.env.GIT_SHA ?? "unknown",
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});
```

**Key Points:**
- `process.uptime()` returns seconds since the Node.js process started — useful for detecting recent restarts
- Avoid exposing internal infrastructure details (internal hostnames, full stack traces) that could aid an attacker [Inference — threat model dependent]

---

### Protecting Health Endpoints

In most cases health endpoints should be unauthenticated — load balancers and probes cannot supply auth tokens. However, detailed health responses (dependency states, versions) may warrant access controls in sensitive environments.

**Common mitigations:**
- Expose a minimal public `/health` returning only `{ status }` with no internal detail
- Expose a richer `/health/detail` behind network-level access control (VPC-only, internal ingress)
- Strip sensitive fields in production via `NODE_ENV` checks

---

**Conclusion:**
Health check endpoints in tRPC applications live outside the tRPC handler and are registered as plain HTTP routes on the same underlying server. The separation is intentional — health checks serve infrastructure consumers, not application clients. The pattern is consistent across adapters (Next.js, Express, Fastify): register health routes on distinct paths, return appropriate HTTP status codes, and distinguish liveness from readiness for orchestration environments. Actual probe behavior depends on the platform and runtime configuration and should be validated against your deployment target.