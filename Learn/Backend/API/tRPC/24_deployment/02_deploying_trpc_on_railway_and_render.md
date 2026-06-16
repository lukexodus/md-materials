## Deploying tRPC on Railway and Render

Railway and Render are persistent-server platforms. Unlike Vercel's serverless model, both run long-lived processes — meaning TCP connection pools, WebSockets, and in-memory state behave as they would on a traditional server. This makes them well-suited for tRPC deployments that include subscriptions, heavy database usage, or observability tooling that requires a persistent runtime.

---

### Platform Comparison

| Characteristic | Railway | Render |
|---|---|---|
| Process model | Persistent container | Persistent container |
| Build system | Nixpacks (auto-detect) or Dockerfile | Auto-detect or Dockerfile |
| Zero-downtime deploys | Rolling restarts (configurable) | Available on paid plans |
| WebSockets | Supported | Supported |
| Private networking | Yes (private railway domain) | Yes (internal render.com domain) |
| Managed databases | PostgreSQL, MySQL, Redis, MongoDB | PostgreSQL, Redis |
| Free tier | Trial credits | Free tier with limitations |
| Config file | `railway.toml` | `render.yaml` |

Both platforms deploy from a Git repository and rebuild on push. Neither imposes execution time limits on individual requests.

---

### Project Structure Assumption

The examples below assume a standalone tRPC server (Express or Fastify), not Next.js. Next.js deployments on these platforms follow the same process but use `next start` as the run command.

```
project/
├── src/
│   ├── server.ts          # HTTP server entry point
│   ├── trpc/
│   │   ├── router.ts
│   │   ├── context.ts
│   │   └── middleware/
│   └── lib/
│       └── db.ts
├── package.json
├── tsconfig.json
├── Dockerfile             # optional but recommended for production
├── railway.toml           # Railway config
└── render.yaml            # Render config
```

---

### tRPC Server Entry Point

A minimal Express-based tRPC server suitable for both platforms:

```ts
// src/server.ts
import express from 'express';
import { createExpressMiddleware } from '@trpc/server/adapters/express';
import { createOpenApiExpressMiddleware } from 'trpc-openapi'; // optional
import cors from 'cors';
import { appRouter } from './trpc/router';
import { createContext } from './trpc/context';

const app = express();

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') ?? '*',
  credentials: true,
}));

app.use(express.json());

// Health check — required by both Railway and Render for zero-downtime deploys
app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use('/trpc', createExpressMiddleware({
  router: appRouter,
  createContext,
  onError({ error, path }) {
    if (error.code === 'INTERNAL_SERVER_ERROR') {
      console.error(`[tRPC] Internal error on ${path}:`, error);
    }
  },
}));

const PORT = parseInt(process.env.PORT ?? '3000', 10);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`tRPC server listening on port ${PORT}`);
});
```

**Key Points:**
- Bind to `0.0.0.0`, not `localhost` or `127.0.0.1` — both platforms route external traffic to the container's network interface, and binding to loopback makes the server unreachable
- Read `PORT` from environment — Railway and Render inject this automatically
- The `/health` endpoint is used by both platforms for health checks during rolling deploys

---

### Dockerfile

Both platforms support Dockerfile deployments. A Dockerfile gives full control over the build environment and is preferable for production over auto-detect.

```dockerfile
# Dockerfile
FROM node:20-alpine AS base
WORKDIR /app

# Install dependencies separately from source for layer caching
FROM base AS deps
COPY package*.json ./
RUN npm ci --only=production

FROM base AS build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build   # tsc output to /app/dist

# Final image — only runtime artifacts
FROM base AS runner
ENV NODE_ENV=production

COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json ./

EXPOSE 3000

# Tini handles signal forwarding and zombie reaping in containers
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "dist/server.js"]
```

**Key Points:**
- Multi-stage build keeps the final image small — build tools and dev dependencies are excluded
- `tini` as PID 1 handles `SIGTERM` forwarding correctly, which is important for graceful shutdown during deploys
- `EXPOSE 3000` is documentation only — actual port binding is controlled by the `PORT` environment variable at runtime

---

### Graceful Shutdown

Persistent servers must handle `SIGTERM` (sent by the platform during deploys or restarts) to drain in-flight requests before exiting:

```ts
// src/server.ts (addition)
import http from 'http';

const server = http.createServer(app);

server.listen(PORT, '0.0.0.0', () => {
  console.log(`tRPC server listening on port ${PORT}`);
});

async function shutdown(signal: string) {
  console.log(`Received ${signal}, shutting down gracefully`);

  server.close(async () => {
    // Close database connections
    await db.$disconnect?.();
    console.log('Server closed');
    process.exit(0);
  });

  // Force exit if drain takes too long
  setTimeout(() => {
    console.error('Forced shutdown after timeout');
    process.exit(1);
  }, 10_000);
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
```

> [Inference] Whether in-flight requests complete before the platform routes new traffic away depends on the platform's rolling deploy implementation and the `SIGTERM`-to-`SIGKILL` gap. Railway and Render both allow some drain time, but the exact window is platform-defined and may change. Behavior under load may vary.

---

### Deploying on Railway

#### Project Setup

```bash
# Install Railway CLI
npm install -g @railway/cli

# Authenticate
railway login

# Initialize in project root
railway init

# Link to existing project
railway link
```

#### `railway.toml`

```toml
[build]
builder = "dockerfile"
dockerfilePath = "Dockerfile"

[deploy]
startCommand = "node dist/server.js"
healthcheckPath = "/health"
healthcheckTimeout = 30
restartPolicyType = "on_failure"
restartPolicyMaxRetries = 3

[environments.production]
numReplicas = 2   # horizontal scaling — requires Pro plan
```

#### Environment Variables on Railway

```bash
# Set individual variables
railway variables set DATABASE_URL=postgresql://...
railway variables set SENTRY_DSN=https://...
railway variables set NODE_ENV=production

# Set from local .env file
railway variables set < .env.production
```

Variables set in the Railway dashboard or CLI are injected into the container at runtime. Railway also injects platform variables automatically:

| Variable | Value |
|---|---|
| `PORT` | Port the service should listen on |
| `RAILWAY_ENVIRONMENT` | `production`, `staging`, etc. |
| `RAILWAY_SERVICE_NAME` | Service name as configured |
| `RAILWAY_GIT_COMMIT_SHA` | Current deploy commit SHA |

Use `RAILWAY_GIT_COMMIT_SHA` as the Sentry release identifier:

```ts
Sentry.init({
  release: process.env.RAILWAY_GIT_COMMIT_SHA,
});
```

#### Managed Database on Railway

Railway provides one-click PostgreSQL, MySQL, and Redis services within the same project. They are reachable via private networking (no public internet hop):

```bash
# Railway injects DATABASE_URL automatically when a database service
# is added to the same project and the variable is referenced
railway variables
# DATABASE_URL=postgresql://postgres:password@postgres.railway.internal:5432/railway
```

The `.railway.internal` domain is only reachable from within the same Railway project — not from the public internet.

#### Deploy

```bash
# Deploy current branch
railway up

# Deploy to production environment
railway up --environment production

# Stream logs
railway logs
```

---

### Deploying on Render

#### `render.yaml`

Render uses an Infrastructure as Code file at the repository root:

```yaml
# render.yaml
services:
  - type: web
    name: trpc-api
    runtime: docker
    dockerfilePath: ./Dockerfile
    plan: starter          # free | starter | standard | pro
    region: oregon
    branch: main

    healthCheckPath: /health

    envVars:
      - key: NODE_ENV
        value: production
      - key: DATABASE_URL
        fromDatabase:
          name: trpc-postgres
          property: connectionString
      - key: SENTRY_DSN
        sync: false        # prompt for value in dashboard; do not commit

    autoDeploy: true       # rebuild on push to branch

databases:
  - name: trpc-postgres
    plan: starter
    databaseName: trpcdb
    user: trpc
```

`sync: false` marks a variable as a secret that must be supplied via the Render dashboard — it is not stored in the YAML file, which is safe to commit.

#### Render Platform Variables

Render injects several variables automatically:

| Variable | Value |
|---|---|
| `PORT` | Port to bind to (always `10000` on Render) |
| `RENDER_SERVICE_NAME` | Service name |
| `RENDER_GIT_COMMIT` | Current commit SHA |
| `RENDER_EXTERNAL_URL` | Public URL of the service |

#### Render Disk (Persistent Storage)

Unlike Vercel, Render supports attaching a persistent disk to a service — useful for SQLite, file uploads, or local caches:

```yaml
# render.yaml addition
services:
  - type: web
    name: trpc-api
    # ...
    disk:
      name: data
      mountPath: /data
      sizeGB: 10
```

> [Inference] Persistent disks on Render are attached to a single instance. In a multi-instance (scaled) setup, each instance gets its own disk, meaning disk-stored data is not shared across instances. Shared state requires an external database or object store.

---

### Database Connection Pooling on Persistent Servers

Unlike serverless, persistent servers can maintain a connection pool directly. Configure pool size relative to your database's `max_connections` and the number of server instances:

```ts
// lib/db.ts — Prisma with pool configuration
import { PrismaClient } from '@prisma/client';

export const db = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
  // Prisma connection pool is configured via the URL query string
  // postgresql://user:pass@host/db?connection_limit=10&pool_timeout=20
});
```

For the URL-based approach:

```
DATABASE_URL=postgresql://user:pass@host/db?connection_limit=10&pool_timeout=20&connect_timeout=10
```

| Parameter | Meaning |
|---|---|
| `connection_limit` | Max connections per Prisma Client instance |
| `pool_timeout` | Seconds to wait for a connection from the pool before erroring |
| `connect_timeout` | Seconds to wait when establishing a new connection |

With 2 server instances each holding a pool of 10, you consume 20 connections from the database's limit.

---

### WebSockets and Subscriptions

Both Railway and Render support WebSockets without configuration. The platform proxies WebSocket upgrade requests to the container transparently.

```ts
// src/server.ts — WebSocket server alongside HTTP
import http from 'http';
import { applyWSSHandler } from '@trpc/server/adapters/ws';
import { WebSocketServer } from 'ws';
import { appRouter } from './trpc/router';
import { createContext } from './trpc/context';

const httpServer = http.createServer(app);

const wss = new WebSocketServer({ server: httpServer });

const wssHandler = applyWSSHandler({
  wss,
  router: appRouter,
  createContext,
});

httpServer.listen(PORT, '0.0.0.0');

process.on('SIGTERM', () => {
  wssHandler.broadcastReconnectNotification();
  httpServer.close();
});
```

`broadcastReconnectNotification()` signals connected clients to reconnect — tRPC's WebSocket client handles this automatically, reconnecting after a short delay. This allows deploys to complete without clients experiencing a hard disconnect with no recovery.

---

### Private Networking Between Services

Both platforms support internal DNS for service-to-service communication, avoiding public internet routing and reducing latency.

**Railway internal hostnames:**

```
postgresql://postgres:password@postgres.railway.internal:5432/railway
redis://default:password@redis.railway.internal:6379
```

**Render internal hostnames:**

```
postgresql://user:pass@dpg-xxx.oregon-postgres.render.com/dbname   # external
# Render internal hostname format (within same region):
postgresql://user:pass@trpc-postgres/dbname                         # internal
```

> [Unverified] Render's internal hostname format depends on the service type and region. Verify the exact hostname from the Render dashboard under the database service's "Internal Database URL" field.

---

### Continuous Deployment

Both platforms redeploy automatically on push to the configured branch. For more control, use their APIs in CI:

**Railway via GitHub Actions:**

```yaml
# .github/workflows/deploy.yml
name: Deploy to Railway
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npm test
      - name: Deploy
        run: npx @railway/cli up --environment production
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

**Render deploy hook:**

Render provides a deploy hook URL per service. Trigger it from CI:

```yaml
- name: Deploy to Render
  run: |
    curl -X POST "${{ secrets.RENDER_DEPLOY_HOOK_URL }}"
```

---

### Observability on Persistent Servers

Because Railway and Render run persistent processes, the full OTel Node.js SDK and `prom-client` work without constraint.

**Prometheus scraping on Railway:**

Railway does not have a built-in Prometheus integration. Options:

- Expose `/metrics` and configure an external Prometheus instance to scrape the public URL (add token-based auth to protect it)
- Push metrics to Grafana Cloud or a hosted Prometheus via `pushgateway` or remote write

**Prometheus scraping on Render:**

Same approach — expose `/metrics` on the web service and configure external scraping, or use Render's log drain to forward structured logs to a metrics platform.

**Log drains:**

Both platforms support forwarding logs to external destinations:

- Railway: Settings → Observability → Log Drain (supports Datadog, Logtail, custom HTTP)
- Render: Dashboard → Log Streams (supports Datadog, Papertrail, custom HTTP)

---

### Scaling Considerations

| Concern | Railway | Render |
|---|---|---|
| Horizontal scaling | `numReplicas` in `railway.toml` (Pro) | Multiple instances via dashboard (paid plans) |
| Vertical scaling | Change plan per service | Change plan per service |
| WebSocket affinity | Sticky sessions not guaranteed | Sticky sessions available on some plans |
| Shared in-memory state | Not shared across replicas | Not shared across replicas |

> [Inference] Horizontal scaling with WebSocket subscriptions requires a shared pub/sub layer (Redis, Upstash) to broadcast messages across instances. A client connected to instance A will not receive events emitted on instance B without a shared message bus. Behavior depends on your subscription implementation.

**Redis-backed pub/sub for subscriptions across replicas:**

```ts
// src/trpc/routers/events.ts
import { observable } from '@trpc/server/observable';
import Redis from 'ioredis';

const publisher = new Redis(process.env.REDIS_URL!);
const subscriber = new Redis(process.env.REDIS_URL!);

export const eventsRouter = router({
  onMessage: publicProcedure
    .input(z.object({ channel: z.string() }))
    .subscription(({ input }) => {
      return observable<string>((emit) => {
        const handler = (_channel: string, message: string) => {
          emit.next(message);
        };

        subscriber.subscribe(input.channel);
        subscriber.on('message', handler);

        return () => {
          subscriber.unsubscribe(input.channel);
          subscriber.off('message', handler);
        };
      });
    }),
});
```

---

### Summary

| Concern | Railway | Render |
|---|---|---|
| Config file | `railway.toml` | `render.yaml` |
| Port binding | `process.env.PORT`, bind `0.0.0.0` | Same — Render uses port `10000` |
| Health check | `healthcheckPath` in toml | `healthCheckPath` in yaml |
| Database | Managed service, private `.railway.internal` | Managed service, internal URL from dashboard |
| WebSockets | Supported natively | Supported natively |
| Graceful shutdown | `SIGTERM` handler + `tini` in Dockerfile | Same |
| Secrets | CLI or dashboard | `sync: false` in yaml + dashboard |
| Scaling | `numReplicas` (Pro) | Dashboard (paid plans) |
| Multi-instance subscriptions | Redis pub/sub required | Redis pub/sub required |

**Next Steps:**
- Add a Redis service to the same Railway project or Render environment to support WebSocket subscription fanout across replicas
- Configure structured JSON logging (`pino`) with a log drain to Datadog or Logtail for centralized querying across Railway/Render service instances
- Use `RAILWAY_GIT_COMMIT_SHA` or `RENDER_GIT_COMMIT` as the Sentry release identifier to correlate errors to specific deploys