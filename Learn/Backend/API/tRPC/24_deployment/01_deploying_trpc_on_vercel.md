## Deploying tRPC on Vercel

Vercel is a serverless-first platform. tRPC procedures run as serverless functions — each request spins up an isolated execution context, processes, and exits. This model imposes specific constraints on connection management, cold starts, and stateful features like subscriptions.

---

### How Vercel Executes tRPC

Vercel routes each HTTP request to a serverless function. For tRPC:

- The entire tRPC router is bundled into a single function handler (or split by route segment in Next.js App Router)
- There is no persistent server process between requests
- Global state initialized outside the handler (database connections, SDK instances) may persist across warm invocations within the same function instance, but this is not guaranteed
- Maximum execution duration is bounded by the plan (Hobby: 10s, Pro: 60s, Enterprise: 900s)

> [Inference] "Warm" function reuse (where the same container handles multiple sequential requests) is a platform implementation detail and is not contractually guaranteed by Vercel. Code that depends on persistent in-memory state across requests may behave differently under load when multiple function instances are active simultaneously.

---

### Deployment Targets

| Setup | Adapter | Notes |
|---|---|---|
| Next.js Pages Router | `fetchRequestHandler` or `createNextApiHandler` | Conventional; well-documented |
| Next.js App Router | `fetchRequestHandler` | Route Handler in `app/api/trpc/[trpc]/route.ts` |
| Standalone Node.js (Express/Fastify) | Native adapter | Requires Vercel `builds` config or a framework like Nitro |
| SvelteKit / Nuxt on Vercel | `fetchRequestHandler` | Framework handles serverless wrapping |

---

### Next.js Pages Router

The `createNextApiHandler` adapter maps tRPC to Next.js API routes directly.

```ts
// pages/api/trpc/[trpc].ts
import { createNextApiHandler } from '@trpc/server/adapters/next';
import { appRouter } from '../../../server/trpc/router';
import { createContext } from '../../../server/trpc/context';

export default createNextApiHandler({
  router: appRouter,
  createContext,
  onError({ error, type, path, input, ctx }) {
    if (error.code === 'INTERNAL_SERVER_ERROR') {
      // Forward to error tracking
      console.error(`tRPC error on ${path}:`, error);
    }
  },
});
```

The file name `[trpc].ts` is a Next.js dynamic route. All tRPC procedure paths resolve through it: `/api/trpc/user.getById`, `/api/trpc/post.create`, etc.

---

### Next.js App Router

App Router uses Route Handlers, which operate on the Web Fetch API (`Request` / `Response`). Use `fetchRequestHandler`:

```ts
// app/api/trpc/[trpc]/route.ts
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import { appRouter } from '../../../../server/trpc/router';
import { createContext } from '../../../../server/trpc/context';

const handler = (req: Request) =>
  fetchRequestHandler({
    endpoint: '/api/trpc',
    req,
    router: appRouter,
    createContext: () => createContext(req),
  });

export { handler as GET, handler as POST };
```

```ts
// server/trpc/context.ts
export function createContext(req: Request) {
  // Extract auth token from headers
  const token = req.headers.get('authorization')?.replace('Bearer ', '');
  return { token };
}
```

**Key Points:**
- Both `GET` and `POST` must be exported — tRPC queries use `GET` by default (configurable), mutations use `POST`
- The `endpoint` must match the URL path prefix your client is configured with
- `fetchRequestHandler` is runtime-agnostic (works on Edge Runtime and Node.js runtime)

---

### Context Creation on Vercel

`createContext` runs on every request. On Vercel, there is no persistent request object like Express's `req` — the context factory receives the raw `Request` (App Router) or Next.js `req`/`res` (Pages Router).

```ts
// Pages Router context
import { CreateNextContextOptions } from '@trpc/server/adapters/next';
import { getServerSession } from 'next-auth';
import { authOptions } from '../auth/[...nextauth]';
import { db } from '../../lib/db';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getServerSession(req, res, authOptions);
  return {
    session,
    db,          // connection-pooled client — see Database Connections below
    req,
    res,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

---

### Database Connections

Serverless functions cannot maintain persistent TCP connection pools the way a long-running server can. Each cold start may attempt to open new connections, and many concurrent warm instances may exhaust database connection limits.

**Solutions:**

**Option 1 — Connection pooler (PgBouncer, Prisma Accelerate, Supabase pooler)**

Route all database traffic through a pooler that maintains a smaller set of actual database connections and queues serverless requests:

```ts
// lib/db.ts — Prisma with Accelerate
import { PrismaClient } from '@prisma/client';
import { withAccelerate } from '@prisma/extension-accelerate';

// Instantiated outside the handler — reused across warm invocations
const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const db = globalForPrisma.prisma ?? new PrismaClient().$extends(withAccelerate());

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = db;
}
```

The `globalThis` pattern prevents multiple `PrismaClient` instances during Next.js hot reload in development, where modules are re-evaluated.

**Option 2 — HTTP-based database clients**

Some databases offer HTTP APIs that avoid TCP connection management entirely:

- **Neon** (`@neondatabase/serverless`) — PostgreSQL over HTTP/WebSocket
- **PlanetScale** (`@planetscale/database`) — MySQL over HTTP
- **Turso** (`@libsql/client`) — SQLite over HTTP

```ts
// lib/db.ts — Neon serverless driver
import { neon } from '@neondatabase/serverless';

export const sql = neon(process.env.DATABASE_URL!);
```

> [Inference] HTTP-based drivers avoid connection pool exhaustion but introduce per-query HTTP overhead compared to persistent TCP connections. Whether this is acceptable depends on query frequency and latency tolerance.

---

### Environment Variables

Vercel injects environment variables at build time (for `NEXT_PUBLIC_` prefixed vars) and at runtime. Configure them in the Vercel dashboard or via the CLI:

```bash
vercel env add SENTRY_DSN production
vercel env add DATABASE_URL production
vercel env add NEXTAUTH_SECRET production
```

For tRPC client configuration, the base URL must be environment-aware:

```ts
// lib/trpc.ts (client)
import { createTRPCNext } from '@trpc/next';
import { httpBatchLink } from '@trpc/client';

function getBaseUrl() {
  if (typeof window !== 'undefined') return ''; // browser: relative URL
  if (process.env.VERCEL_URL) return `https://${process.env.VERCEL_URL}`; // SSR on Vercel
  return 'http://localhost:3000'; // local dev
}

export const trpc = createTRPCNext<AppRouter>({
  config() {
    return {
      links: [
        httpBatchLink({
          url: `${getBaseUrl()}/api/trpc`,
        }),
      ],
    };
  },
});
```

`VERCEL_URL` is automatically injected by Vercel and contains the deployment URL (e.g., `my-app-git-main-org.vercel.app`). It does not include the `https://` scheme.

---

### Edge Runtime

Vercel supports two runtimes per route:

| Runtime | Cold Start | Execution Limit | Constraints |
|---|---|---|---|
| Node.js | ~200–500ms | 60s (Pro) | Full Node.js API available |
| Edge | ~0–50ms | 25s (all plans) | No Node.js APIs; Web APIs only |

To run tRPC on the Edge Runtime:

```ts
// app/api/trpc/[trpc]/route.ts
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import { appRouter } from '../../../../server/trpc/router';
import { createContext } from '../../../../server/trpc/context';

export const runtime = 'edge'; // opt into Edge Runtime

const handler = (req: Request) =>
  fetchRequestHandler({
    endpoint: '/api/trpc',
    req,
    router: appRouter,
    createContext: () => createContext(req),
  });

export { handler as GET, handler as POST };
```

**Edge Runtime constraints relevant to tRPC:**

- No `node:*` built-ins (`fs`, `crypto` module, `Buffer` from Node — use `globalThis.crypto` instead)
- No native addons
- Prisma Client requires the edge-compatible driver (`@prisma/adapter-neon` or similar)
- `prom-client` does not run on Edge Runtime — metrics require the Node.js runtime
- OTel Node.js SDK does not run on Edge Runtime

> [Inference] Most tRPC routers that use Prisma, database drivers, or Node.js-specific libraries will not run on Edge Runtime without adaptation. Evaluate whether the cold start improvement justifies the migration cost. Behavior of specific packages on Edge Runtime should be verified against their documentation.

---

### Vercel Functions Configuration

Control function behavior via `vercel.json` or Next.js config:

```json
// vercel.json
{
  "functions": {
    "pages/api/trpc/[trpc].ts": {
      "maxDuration": 60,
      "memory": 1024
    }
  }
}
```

Or in `next.config.js` for App Router route segments:

```ts
// app/api/trpc/[trpc]/route.ts
export const maxDuration = 60; // seconds — requires Pro plan for values > 10
export const dynamic = 'force-dynamic'; // disable static caching for this route
```

---

### Subscriptions on Vercel

WebSocket-based subscriptions are not supported on Vercel serverless functions — the platform terminates connections after the response is sent and does not support long-lived connections.

**Alternatives:**

**Server-Sent Events (SSE)** — tRPC supports SSE for subscriptions via `httpSubscriptionLink`. SSE uses a long-lived HTTP response, which works within Vercel's execution duration limit for shorter streams but is bounded by `maxDuration`.

**Separate WebSocket server** — run a persistent WebSocket server on a platform that supports it (Railway, Fly.io, Render) and connect to it from the Vercel-deployed client. The tRPC router can split links:

```ts
// client link splitting
import { splitLink, httpBatchLink, wsLink, createWSClient } from '@trpc/client';

const wsClient = createWSClient({
  url: process.env.NEXT_PUBLIC_WS_URL!, // separate WebSocket server
});

const trpcClient = createTRPCClient<AppRouter>({
  links: [
    splitLink({
      condition: (op) => op.type === 'subscription',
      true: wsLink({ client: wsClient }),
      false: httpBatchLink({ url: '/api/trpc' }),
    }),
  ],
});
```

> [Inference] SSE on Vercel is bounded by `maxDuration` (max 900s on Enterprise). For subscriptions that need indefinite duration, a persistent server is the more reliable architectural choice.

---

### Cold Start Mitigation

Cold starts occur when Vercel spins up a new function instance. Strategies to reduce their impact:

**Minimize bundle size** — smaller bundles initialize faster. Analyze with:

```bash
npx @next/bundle-analyzer
```

Avoid importing entire libraries when only specific exports are needed:

```ts
// Avoid
import _ from 'lodash';

// Prefer
import merge from 'lodash/merge';
```

**Lazy-initialize expensive resources:**

```ts
// Defer SDK initialization until first use rather than module load
let sentryInitialized = false;

function ensureSentry() {
  if (!sentryInitialized) {
    Sentry.init({ dsn: process.env.SENTRY_DSN });
    sentryInitialized = true;
  }
}
```

**Use Edge Runtime for latency-sensitive, lightweight procedures** — Edge cold starts are significantly faster than Node.js cold starts where the runtime constraints are acceptable.

**Vercel Fluid Compute** — Vercel's newer execution model (available on Pro+) allows functions to handle concurrent requests within a single instance, reducing cold start frequency under sustained load.

> [Unverified] Vercel Fluid Compute availability, behavior, and pricing details may have changed since the knowledge cutoff. Verify against current Vercel documentation.

---

### Deployment Workflow

```bash
# Install Vercel CLI
npm install -g vercel

# Link project (first time)
vercel link

# Deploy to preview
vercel

# Deploy to production
vercel --prod

# Pull environment variables to local .env
vercel env pull .env.local
```

For CI/CD, use the Vercel GitHub integration or the CLI in a GitHub Actions workflow:

```yaml
# .github/workflows/deploy.yml
- name: Deploy to Vercel
  run: vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
  env:
    VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
    VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
```

---

### Common Issues on Vercel

| Symptom | Likely Cause |
|---|---|
| `500` on all procedures | Router import error at cold start — check function logs in Vercel dashboard |
| `504` timeout | Procedure exceeds `maxDuration` — increase limit or optimize query |
| Database connection errors under load | Connection pool exhaustion — add a pooler or switch to HTTP driver |
| `window is not defined` during SSR | Client-only code not guarded by `typeof window !== 'undefined'` |
| Subscriptions immediately disconnect | Vercel does not support persistent connections — use SSE or external WS server |
| Environment variable undefined at runtime | `NEXT_PUBLIC_` prefix missing for client-side vars, or var not added to Vercel project |
| Edge Runtime crash on startup | Package uses Node.js built-ins incompatible with Edge — switch to Node.js runtime |

---

### Summary

| Concern | Recommendation |
|---|---|
| Adapter (Pages Router) | `createNextApiHandler` |
| Adapter (App Router) | `fetchRequestHandler` in Route Handler |
| Database connections | Connection pooler or HTTP-based driver |
| Subscriptions | SSE within `maxDuration`, or external WebSocket server |
| Cold starts | Minimize bundle, lazy-init SDKs, evaluate Edge Runtime |
| Environment variables | Vercel dashboard + `vercel env pull` for local dev |
| Execution limits | Set `maxDuration` in `vercel.json` or route config |
| Metrics / OTel | Node.js runtime only — incompatible with Edge Runtime |

**Next Steps:**
- Configure Vercel preview deployments with isolated database branches (Neon branching, PlanetScale deploy requests) so each PR gets its own database state
- Use Vercel's built-in log drain to forward function logs to Datadog, Logtail, or Axiom for centralized querying alongside Sentry errors
- Evaluate tRPC's `experimental_standaloneMiddleware` for procedures that need to share logic across the Node.js and Edge runtime split