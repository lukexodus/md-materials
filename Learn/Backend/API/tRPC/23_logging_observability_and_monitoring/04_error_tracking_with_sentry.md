## Error Tracking with Sentry

Sentry captures exceptions, attaches context, groups them by fingerprint, and links them to releases and users. Integrating it with tRPC requires deliberate placement — Sentry's auto-instrumentation does not understand tRPC procedure boundaries out of the box.

---

### How Sentry Relates to OpenTelemetry

Sentry has its own tracing SDK that partially overlaps with OTel. Two integration postures exist:

**Sentry-native SDK** — uses Sentry's own `Hub`, `Scope`, and transaction primitives. Simpler setup, tighter Sentry feature integration (breadcrumbs, user context, release tracking).

**Sentry as an OTel exporter** — Sentry can ingest OTel spans via `@sentry/opentelemetry`. Useful if OTel is already the primary tracing layer.

This section covers the Sentry-native SDK approach first, then the OTel bridge.

> [Inference] Choosing between the two depends on whether OTel is already the primary instrumentation layer. Running both SDKs independently without the bridge may produce duplicate or conflicting spans. Behavior may vary by SDK version.

---

### Installation

```bash
npm install @sentry/node @sentry/profiling-node
```

For the OTel bridge (optional, only if using OTel alongside Sentry):

```bash
npm install @sentry/opentelemetry
```

---

### SDK Initialization

Sentry must be initialized before any other imports — the same constraint as OTel. Use a dedicated entry file.

```ts
// src/instrumentation.ts
import * as Sentry from '@sentry/node';
import { nodeProfilingIntegration } from '@sentry/profiling-node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV ?? 'development',
  release: process.env.SENTRY_RELEASE, // e.g. git SHA injected at build time
  tracesSampleRate: 0.2,       // 20% of transactions sent as traces
  profilesSampleRate: 0.1,     // 10% of sampled transactions also profiled
  integrations: [
    nodeProfilingIntegration(),
  ],
  // Filter events before they leave the SDK
  beforeSend(event, hint) {
    // Discard expected operational errors
    const error = hint.originalException;
    if (error instanceof Error && error.message.includes('ECONNRESET')) {
      return null; // drop the event
    }
    return event;
  },
});
```

Load before the application:

```bash
node --require ./dist/instrumentation.js dist/server.js
```

---

### Core Concepts

**Event** — a single captured error or message sent to Sentry.

**Scope** — a container for contextual data (user, tags, extra) attached to events captured within it.

**Hub** — manages the stack of scopes. Deprecated in newer SDK versions in favor of `Sentry.withScope()` and the isolation scope model.

**Transaction / Span** — Sentry's tracing primitives (analogous to OTel spans).

**Fingerprint** — determines how Sentry groups events into issues. Customizable to control grouping granularity.

**DSN** — the project-specific URL Sentry uses to route your events to the correct project.

---

### tRPC Middleware for Sentry

The middleware is the primary integration point. It captures unhandled errors, attaches procedure context, and scopes every event to the current request.

```ts
// src/trpc/middleware/sentry.ts
import * as Sentry from '@sentry/node';
import { middleware } from '../trpc';
import { TRPCError } from '@trpc/server';

// tRPC error codes that represent expected client errors — typically not actionable
const CLIENT_ERROR_CODES = new Set<TRPCError['code']>([
  'BAD_REQUEST',
  'UNAUTHORIZED',
  'FORBIDDEN',
  'NOT_FOUND',
  'METHOD_NOT_SUPPORTED',
  'TOO_MANY_REQUESTS',
  'PAYLOAD_TOO_LARGE',
  'PRECONDITION_FAILED',
]);

export const sentryMiddleware = middleware(async ({ path, type, next, ctx }) => {
  return Sentry.withScope(async (scope) => {
    // Tag every event in this scope with procedure metadata
    scope.setTag('trpc.path', path);
    scope.setTag('trpc.type', type);

    // Attach user context if available
    const user = (ctx as any).user;
    if (user) {
      scope.setUser({
        id: user.id,
        email: user.email,
        username: user.username,
      });
    }

    try {
      return await next();
    } catch (error) {
      if (error instanceof TRPCError) {
        // Only capture server-side errors; skip expected client errors
        if (!CLIENT_ERROR_CODES.has(error.code)) {
          Sentry.captureException(error, {
            tags: {
              'trpc.error_code': error.code,
              'trpc.path': path,
            },
            extra: {
              cause: error.cause,
            },
          });
        }
      } else {
        // Non-TRPCError — unexpected; always capture
        Sentry.captureException(error, {
          tags: { 'trpc.path': path, 'trpc.type': type },
        });
      }
      throw error; // re-throw so tRPC error handling continues normally
    }
  });
});
```

**Key Points:**
- `Sentry.withScope()` isolates context mutations to the current request — without it, tags and user data bleed across concurrent requests
- Re-throwing after `captureException` is essential; swallowing the error breaks tRPC's error response pipeline
- Filtering `CLIENT_ERROR_CODES` reduces noise; `BAD_REQUEST` and `NOT_FOUND` from clients are usually not bugs in server code

---

### Registering the Middleware

```ts
// src/trpc/trpc.ts
import { initTRPC } from '@trpc/server';
import { sentryMiddleware } from './middleware/sentry';
import { otelMiddleware } from './middleware/otel'; // if also using OTel

const t = initTRPC.context<Context>().create();

export const publicProcedure = t.procedure
  .use(sentryMiddleware)   // outermost — captures all errors including those from inner middleware
  .use(otelMiddleware);    // order matters: OTel span wraps procedure; Sentry scope wraps everything

export const protectedProcedure = t.procedure
  .use(sentryMiddleware)
  .use(otelMiddleware)
  .use(authMiddleware);
```

> [Inference] Placing `sentryMiddleware` before `otelMiddleware` means the Sentry scope is active when OTel spans are created. Whether this affects OTel-Sentry interop depends on whether the Sentry OTel bridge is active. Behavior may vary.

---

### Breadcrumbs

Breadcrumbs are a chronological trail of events leading up to an error. Sentry captures some automatically (HTTP requests, console output). Add custom breadcrumbs for procedure-level milestones:

```ts
// Inside a procedure, before an operation likely to fail
Sentry.addBreadcrumb({
  category: 'trpc',
  message: `Calling payment provider for order ${orderId}`,
  level: 'info',
  data: {
    orderId,
    provider: 'stripe',
  },
});

const charge = await stripe.paymentIntents.create({ ... });
```

Breadcrumbs appear in the Sentry issue detail view, showing the sequence of events before the captured exception.

---

### Attaching Additional Context

Beyond user and tags, Sentry supports structured extra data and contexts:

```ts
Sentry.withScope((scope) => {
  // Arbitrary structured data — visible in issue detail, not searchable
  scope.setExtra('requestBody', sanitizedInput);

  // Named context blocks — displayed as sections in the issue UI
  scope.setContext('order', {
    id: order.id,
    status: order.status,
    itemCount: order.items.length,
  });

  // Searchable tags — keep values low-cardinality
  scope.setTag('payment.provider', 'stripe');
  scope.setTag('feature.flag', featureFlag);

  Sentry.captureException(error);
});
```

**Key Points:**
- Tags are indexed and searchable in Sentry; use them for low-cardinality fields (enum-like values, feature flags, regions)
- Extra data is not indexed; use it for high-cardinality or large payloads
- Never attach raw input objects without sanitization — they may contain credentials or PII

---

### Custom Fingerprinting

Sentry's default grouping uses stack traces and error messages. For tRPC, you may want to group by procedure path and error code instead:

```ts
Sentry.captureException(error, {
  fingerprint: [
    'trpc',
    path,
    error instanceof TRPCError ? error.code : 'UNKNOWN',
    error.message,
  ],
});
```

This produces one Sentry issue per (procedure, error code, message) combination rather than one per stack frame pattern.

> [Inference] Overly specific fingerprints (including dynamic IDs) can produce excessive issue fragmentation. Overly broad fingerprints collapse distinct bugs into a single issue. Tune based on your observed grouping behavior.

---

### Source Maps

Sentry displays minified stack traces without source maps. For production Node.js builds (esbuild, tsc with `outDir`), upload source maps at build time:

```bash
npm install --save-dev @sentry/cli
```

```bash
# In CI after build:
sentry-cli sourcemaps inject ./dist
sentry-cli sourcemaps upload ./dist \
  --org your-org \
  --project your-project \
  --release $SENTRY_RELEASE
```

Set `SENTRY_RELEASE` to a consistent identifier (git SHA, semver tag) used both in `Sentry.init()` and the upload command.

With Vite or webpack, Sentry provides plugins that handle injection and upload automatically:

```ts
// vite.config.ts
import { sentryVitePlugin } from '@sentry/vite-plugin';

export default {
  plugins: [
    sentryVitePlugin({
      org: 'your-org',
      project: 'your-project',
    }),
  ],
  build: { sourcemap: true },
};
```

---

### Sentry Tracing for tRPC Transactions

To track tRPC procedures as Sentry performance transactions:

```ts
// src/trpc/middleware/sentry-tracing.ts
import * as Sentry from '@sentry/node';
import { middleware } from '../trpc';

export const sentryTracingMiddleware = middleware(async ({ path, type, next }) => {
  return Sentry.startSpan(
    {
      name: `trpc.${type}.${path}`,
      op: 'trpc.server',
      attributes: {
        'trpc.procedure_type': type,
        'rpc.method': path,
      },
    },
    async () => {
      return next();
    }
  );
});
```

`Sentry.startSpan` creates a span in the current Sentry transaction. If no transaction is active (i.e., no incoming `sentry-trace` header and sampling doesn't start one), the span is a no-op.

> [Inference] Whether a transaction is created depends on `tracesSampleRate` and whether an incoming `sentry-trace` header is present. Spans created without an active transaction may be discarded. Behavior is SDK-version dependent.

---

### The OTel Bridge

If OTel is already the primary instrumentation layer, use `@sentry/opentelemetry` to route OTel spans into Sentry instead of running two parallel tracing systems:

```ts
// src/instrumentation.ts
import * as Sentry from '@sentry/node';
import { SentrySpanProcessor, SentryPropagator } from '@sentry/opentelemetry';
import { NodeTracerProvider } from '@opentelemetry/sdk-trace-node';
import { propagation } from '@opentelemetry/api';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  skipOpenTelemetrySetup: true, // prevent Sentry from initializing its own OTel provider
});

const provider = new NodeTracerProvider({
  spanProcessors: [
    new SentrySpanProcessor(), // forwards OTel spans to Sentry
  ],
});

provider.register({
  propagator: new SentryPropagator(), // handles sentry-trace + baggage headers
});
```

With this setup, OTel spans from `otelMiddleware` appear in Sentry's performance view. Sentry error capture still requires explicit `Sentry.captureException()` calls.

> [Unverified] `@sentry/opentelemetry` API surface and configuration options change across Sentry SDK major versions. Verify against the current Sentry SDK documentation for your installed version.

---

### `beforeSend` Filtering

`beforeSend` is the last hook before an event leaves the SDK. Use it for scrubbing, enrichment, or dropping:

```ts
Sentry.init({
  beforeSend(event, hint) {
    const error = hint.originalException;

    // Drop connection reset noise
    if (error instanceof Error && /ECONNRESET|ETIMEDOUT/.test(error.message)) {
      return null;
    }

    // Scrub sensitive fields from request data
    if (event.request?.data) {
      const data = event.request.data as Record<string, unknown>;
      delete data.password;
      delete data.token;
      delete data.creditCard;
    }

    return event;
  },

  beforeSendTransaction(event) {
    // Drop health check transactions
    if (event.transaction === 'GET /health') return null;
    return event;
  },
});
```

---

### Alerting and Issue Management

Sentry issues can trigger alerts via:

- **Alert rules** — condition-based (e.g., error rate exceeds threshold, new issue seen for the first time)
- **Integrations** — Slack, PagerDuty, GitHub Issues, Jira auto-creation
- **Crons monitoring** — detect silent failures in scheduled jobs

For tRPC, useful alert rules include:

- New issue in `trpc.*` transactions with `trpc.error_code = INTERNAL_SERVER_ERROR`
- Error rate increase (> N errors/minute) on a specific procedure path tag
- Regression: issue resolved in release X, reappears in release Y

---

### Local Development: Verifying Capture

By default, Sentry does not send events in development to avoid polluting production data. To verify capture locally without sending:

```ts
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  beforeSend(event) {
    console.log('[Sentry event]', JSON.stringify(event, null, 2));
    return null; // prevent actual transmission
  },
});
```

Alternatively, use a dedicated Sentry project for development with a separate DSN.

---

### Summary

| Concern | Mechanism |
|---|---|
| Error capture | `Sentry.captureException()` in middleware catch block |
| Request isolation | `Sentry.withScope()` per procedure invocation |
| User context | `scope.setUser()` from `ctx.user` |
| Searchable metadata | `scope.setTag()` — low-cardinality fields |
| Structured detail | `scope.setContext()` / `scope.setExtra()` |
| Issue grouping | `fingerprint` array customized per procedure |
| Noise reduction | `CLIENT_ERROR_CODES` filter + `beforeSend` |
| Source maps | `sentry-cli sourcemaps upload` or Vite/webpack plugin |
| OTel coexistence | `@sentry/opentelemetry` bridge with `SentrySpanProcessor` |
| Performance | `Sentry.startSpan()` in a dedicated tracing middleware |

**Next Steps:**
- Configure Sentry release tracking tied to your CI/CD pipeline so regressions surface per-deploy
- Use `Sentry.setMeasurement()` inside procedures to attach custom performance metrics (e.g., query count, payload size) to transactions
- Evaluate `@sentry/opentelemetry` if OTel is the primary tracing layer, to consolidate into a single span pipeline