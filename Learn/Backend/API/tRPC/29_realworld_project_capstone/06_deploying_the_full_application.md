## Deploying the Full tRPC Application

### Overview

Deploying a full-stack tRPC application involves coordinating the server (Node.js/Express/Fastify/Next.js), the client (React or another frontend), shared type packages, and infrastructure concerns like environment variables, build pipelines, and runtime configuration. This section covers the full deployment lifecycle from build to production.

---

### Project Structure Assumptions

A typical full-stack tRPC monorepo uses the following layout:

```
apps/
  server/         # Express or Fastify backend
  web/            # React or Next.js frontend
packages/
  trpc/           # Shared router types and procedure definitions
  db/             # Prisma or other ORM
```

[Inference] Most production tRPC projects use a monorepo tool such as Turborepo, pnpm workspaces, or Nx to manage shared packages. This is not required by tRPC itself.

---

### Build Pipeline

#### Building Shared Packages First

Shared packages (e.g., the router type package) must be compiled before dependent apps.

```json
// turbo.json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    }
  }
}
```

The `^build` dependency means Turborepo runs upstream `build` tasks before the current package.

#### Building the Server

```bash
# apps/server/package.json
"scripts": {
  "build": "tsc -p tsconfig.json",
  "start": "node dist/index.js"
}
```

TypeScript must emit to `dist/`. Ensure `tsconfig.json` includes:

```json
{
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src",
    "module": "commonjs",
    "target": "es2020"
  }
}
```

#### Building the Frontend

```bash
# apps/web/package.json
"scripts": {
  "build": "vite build",
  "start": "vite preview"
}
```

For Next.js frontends:

```bash
"scripts": {
  "build": "next build",
  "start": "next start"
}
```

---

### Environment Variables

#### Server-Side

```env
# apps/server/.env
DATABASE_URL=postgresql://user:password@host:5432/dbname
PORT=4000
NODE_ENV=production
JWT_SECRET=your-secret-here
CORS_ORIGIN=https://your-frontend.com
```

#### Client-Side

For Vite:

```env
# apps/web/.env
VITE_TRPC_URL=https://your-api.com/trpc
```

For Next.js:

```env
# apps/web/.env
NEXT_PUBLIC_TRPC_URL=https://your-api.com/trpc
```

**Key Points**

- Never commit `.env` files. Use `.env.example` as a template.
- Environment variables must be injected at build time (for Vite/Next.js public vars) or at runtime (for server-side vars).
- [Inference] Misconfigured `CORS_ORIGIN` is a common deployment failure point when the client and server are on separate domains.

---

### CORS Configuration

When the tRPC server and client are on separate origins (e.g., `api.example.com` and `app.example.com`), CORS must be explicitly configured.

#### Express

```ts
import cors from 'cors';

app.use(cors({
  origin: process.env.CORS_ORIGIN,
  credentials: true,
}));
```

#### Fastify

```ts
await fastify.register(import('@fastify/cors'), {
  origin: process.env.CORS_ORIGIN,
  credentials: true,
});
```

**Key Points**

- `credentials: true` is required if cookies or Authorization headers are used.
- Wildcard `*` origins are incompatible with `credentials: true`.

---

### Deploying the Server

#### Option 1: Railway

Railway supports Node.js apps directly from a GitHub repo.

```toml
# railway.toml (optional, for monorepos)
[build]
  builder = "NIXPACKS"
  buildCommand = "pnpm --filter server build"

[deploy]
  startCommand = "pnpm --filter server start"
  restartPolicyType = "ON_FAILURE"
```

Set environment variables in the Railway dashboard under the service's "Variables" tab.

#### Option 2: Render

```yaml
# render.yaml
services:
  - type: web
    name: trpc-server
    env: node
    buildCommand: pnpm --filter server build
    startCommand: pnpm --filter server start
    envVars:
      - key: DATABASE_URL
        sync: false
      - key: NODE_ENV
        value: production
```

#### Option 3: AWS EC2 / VPS (Manual)

```bash
# On the server
git pull origin main
pnpm install --frozen-lockfile
pnpm --filter server build
pm2 restart trpc-server || pm2 start dist/index.js --name trpc-server
```

Use `pm2` to manage the Node process, persist across reboots, and handle restarts on crash.

```bash
pm2 save
pm2 startup
```

#### Option 4: Docker

```dockerfile
# apps/server/Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY . .
RUN npm install -g pnpm
RUN pnpm install --frozen-lockfile
RUN pnpm --filter server build

FROM node:20-alpine AS runner
WORKDIR /app
COPY --from=builder /app/apps/server/dist ./dist
COPY --from=builder /app/apps/server/package.json ./
COPY --from=builder /app/node_modules ./node_modules
ENV NODE_ENV=production
EXPOSE 4000
CMD ["node", "dist/index.js"]
```

```bash
docker build -t trpc-server .
docker run -p 4000:4000 --env-file .env trpc-server
```

[Inference] Multi-stage Docker builds significantly reduce final image size by excluding dev dependencies and TypeScript source files from the production image.

---

### Deploying the Frontend

#### Option 1: Vercel (Next.js or Vite)

Vercel is the most common deployment target for tRPC frontends, especially with Next.js.

```bash
vercel --prod
```

Set `NEXT_PUBLIC_TRPC_URL` or `VITE_TRPC_URL` in the Vercel project settings under Environment Variables.

**Key Points**

- For Next.js full-stack tRPC (server routes in `pages/api/trpc/[trpc].ts`), Vercel deploys both frontend and backend together. No separate server deployment is needed.
- For standalone frontends (Vite + separate Express/Fastify server), only the frontend is deployed to Vercel.

#### Option 2: Netlify

```toml
# netlify.toml
[build]
  command = "pnpm --filter web build"
  publish = "apps/web/dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

The `[[redirects]]` rule is required for SPAs using client-side routing.

#### Option 3: Cloudflare Pages

Cloudflare Pages supports static and SSR deployments.

```bash
# Build output directory for Vite
dist/

# Build command
pnpm --filter web build
```

---

### Full-Stack Deployment: Next.js on Vercel

When using tRPC with Next.js App Router or Pages Router and deploying to Vercel, the entire stack (API routes + frontend) runs as a single deployment unit.

#### File structure

```
apps/web/
  src/
    app/
      api/
        trpc/
          [trpc]/
            route.ts    # App Router handler
    trpc/
      server.ts
      client.ts
```

#### API Route Handler (App Router)

```ts
// src/app/api/trpc/[trpc]/route.ts
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import { appRouter } from '@/trpc/server';

const handler = (req: Request) =>
  fetchRequestHandler({
    endpoint: '/api/trpc',
    req,
    router: appRouter,
    createContext: () => ({}),
  });

export { handler as GET, handler as POST };
```

Vercel automatically converts this to a serverless function. No separate server is needed.

---

### Database Connectivity in Production

#### Connection Pooling

Direct PostgreSQL connections from serverless environments (Vercel, Netlify) are problematic because each function invocation may open a new connection.

Use a connection pooler:

- **PgBouncer** (self-hosted or via Supabase)
- **Neon** (serverless Postgres with HTTP-based connections)
- **Prisma Accelerate** (managed connection pooling for Prisma)

```env
# Prisma with Supabase pooler
DATABASE_URL=postgresql://user:password@db.supabase.co:6543/postgres?pgbouncer=true
DIRECT_URL=postgresql://user:password@db.supabase.co:5432/postgres
```

```prisma
// schema.prisma
datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}
```

[Inference] Omitting connection pooling in serverless deployments commonly causes `too many connections` errors under moderate traffic. This is not guaranteed to occur but is a known risk.

#### Running Migrations in Production

```bash
# Run before starting the server
pnpm prisma migrate deploy
```

In CI/CD pipelines, this is typically a separate step before the deploy step.

```yaml
# GitHub Actions example
- name: Run migrations
  run: pnpm prisma migrate deploy
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

---

### CI/CD Pipeline

#### GitHub Actions — Full Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v3
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Build all packages
        run: pnpm build

      - name: Run migrations
        run: pnpm prisma migrate deploy
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}

      - name: Deploy server to Railway
        run: railway up --service trpc-server
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}

      - name: Deploy frontend to Vercel
        run: vercel --prod --token ${{ secrets.VERCEL_TOKEN }}
```

---

### Health Checks and Monitoring

#### Health Check Endpoint

```ts
// Express
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
```

Most hosting platforms (Railway, Render, ECS) support health check URLs. Configure them to poll `/health` every 30–60 seconds.

#### tRPC-Level Health Procedure

```ts
export const appRouter = router({
  health: publicProcedure.query(() => ({
    status: 'ok',
    uptime: process.uptime(),
  })),
});
```

This approach lets you test the full tRPC stack (router, context, serialization) with a simple query.

#### Logging

```ts
import pino from 'pino';

const logger = pino({ level: process.env.LOG_LEVEL ?? 'info' });

const t = initTRPC.context<Context>().create({
  middleware: [
    t.middleware(async ({ path, type, next }) => {
      const start = Date.now();
      const result = await next();
      logger.info({ path, type, durationMs: Date.now() - start });
      return result;
    }),
  ],
});
```

[Inference] Structured JSON logging (e.g., via `pino`) integrates better with log aggregation platforms like Datadog, Logtail, or AWS CloudWatch than unstructured `console.log` output.

---

### SSL and Domain Configuration

#### TLS Termination

Most cloud platforms (Vercel, Railway, Render, Cloudflare) handle TLS automatically. For VPS/EC2 deployments:

```bash
# Nginx as reverse proxy with Certbot
sudo apt install nginx certbot python3-certbot-nginx
sudo certbot --nginx -d api.yourdomain.com
```

Nginx config:

```nginx
server {
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

### Common Deployment Failures and Mitigations

| Failure | Likely Cause | Mitigation |
|---|---|---|
| `CORS error` in browser | `CORS_ORIGIN` mismatch | Set exact frontend origin including protocol |
| `Cannot find module` | Missing build step | Confirm shared packages built before apps |
| `too many connections` | No connection pooling | Add PgBouncer or Prisma Accelerate |
| `502 Bad Gateway` | Server crashed or wrong port | Check `PORT` env var; add health checks |
| `tRPC type errors after deploy` | Stale client bundle | Ensure client and server are deployed atomically |
| `Procedure not found` | Router mismatch | Redeploy both server and client together |

**Key Points**

- [Inference] The most fragile point in a tRPC deployment is the type contract between client and server. If the server is updated and the client is not, type errors at runtime are possible even if TypeScript compilation passed. Atomic deployments (both server and client deployed in the same release) reduce this risk.
- Behavior of runtime type mismatches is not guaranteed and may vary depending on which procedures are called.

---

### Deployment Checklist

```
[ ] All environment variables set in target platform
[ ] CORS_ORIGIN matches deployed frontend URL exactly
[ ] Database migrations run before server starts
[ ] Connection pooling configured for serverless targets
[ ] Health check endpoint configured and passing
[ ] SSL/TLS terminating correctly
[ ] Shared tRPC packages built before dependent apps
[ ] Server and client deployed atomically or in correct order
[ ] Logging enabled and shipping to aggregator
[ ] PM2 or process manager configured (VPS only)
```

---

**Related Topics**

- Incremental deployments and blue/green strategies for tRPC APIs
- Serverless cold start mitigation for tRPC procedures
- Edge runtime deployment (Cloudflare Workers, Vercel Edge) with tRPC
- tRPC with Docker Compose for local production parity
- API versioning strategies for deployed tRPC routers
- Monitoring tRPC procedure latency with OpenTelemetry
- Secret management in production (Vault, AWS Secrets Manager, Doppler)
- WebSocket (subscriptions) deployment considerations