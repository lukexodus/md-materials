## Structured Logging in Procedures

### What Structured Logging Means in This Context

Structured logging refers to emitting log entries as machine-readable data objects — typically JSON — rather than plain text strings. Instead of writing `"User 42 fetched post 7"`, a structured log entry captures the same event as a data record with discrete, queryable fields:

```json
{
  "level": "info",
  "event": "post.getById",
  "userId": 42,
  "postId": 7,
  "durationMs": 14,
  "timestamp": "2026-06-07T03:22:11.004Z"
}
```

In tRPC, procedures are the natural unit of work — each call to a procedure represents a discrete operation with a known input, caller context, and outcome. This makes procedures the correct instrumentation boundary for structured logs.

---

### Why Plain `console.log` Is Insufficient

`console.log` in procedures produces unstructured, unparseable output:

```
User 42 called getById with postId 7
```

This string cannot be reliably filtered, aggregated, or alerted on by log management systems (Datadog, Loki, CloudWatch, etc.). Structured logging solves this by ensuring every field is addressable independently.

---

### Choosing a Structured Logger

tRPC has no built-in logging facility. You integrate a third-party logger into your middleware or procedures. Common choices:

| Logger | Format | Notes |
| --- | --- | --- |
| `pino` | JSON (default) | High performance, low overhead |
| `winston` | JSON (configurable) | Flexible transports |
| `bunyan` | JSON | Older but stable |
| `consola` | JSON / pretty | Good DX in development |

**pino** is the most common choice in tRPC projects due to its low serialization overhead. All examples below use pino, but the patterns apply to any structured logger.

---

### Setting Up pino

```bash
npm install pino
```

```ts
// lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  // In production, omit prettyPrint — ship raw JSON
  transport:
    process.env.NODE_ENV === 'development'
      ? { target: 'pino-pretty', options: { colorize: true } }
      : undefined,
});
```

---

### Logging in a Single Procedure (Baseline Pattern)

The simplest approach — calling the logger directly inside a procedure — works but does not scale:

```ts
// server/routers/post.ts
import { publicProcedure, router } from '../trpc';
import { logger } from '../../lib/logger';
import { z } from 'zod';

export const postRouter = router({
  getById: publicProcedure
    .input(z.object({ postId: z.number() }))
    .query(async ({ input, ctx }) => {
      logger.info({ postId: input.postId, userId: ctx.userId }, 'post.getById called');

      const post = await db.post.findUnique({ where: { id: input.postId } });

      if (!post) {
        logger.warn({ postId: input.postId }, 'post.getById — not found');
        throw new TRPCError({ code: 'NOT_FOUND' });
      }

      logger.info({ postId: input.postId }, 'post.getById — success');
      return post;
    }),
});
```

**Key Points**

- The first argument to `pino` log methods is a *merge object* — fields that get merged into the log entry at the top level.
- The second argument is the human-readable `msg` field, kept short and consistent.
- This pattern works but requires repeating logging calls in every procedure.

---

### The Correct Pattern: Logging Middleware

The idiomatic approach in tRPC is to centralize structured logging in a middleware. This middleware runs around every procedure call, capturing timing, path, outcome, and context fields in one place.

```ts
// server/middleware/logging.ts
import { middleware } from '../trpc';
import { logger } from '../../lib/logger';
import { TRPCError } from '@trpc/server';

export const loggingMiddleware = middleware(async ({ path, type, next, ctx }) => {
  const start = Date.now();

  const result = await next();

  const durationMs = Date.now() - start;

  const base = {
    path,         // e.g. "post.getById"
    type,         // "query" | "mutation" | "subscription"
    durationMs,
    userId: ctx.userId ?? null,
  };

  if (result.ok) {
    logger.info(base, 'procedure ok');
  } else {
    logger.error(
      {
        ...base,
        errorCode: result.error instanceof TRPCError ? result.error.code : 'UNKNOWN',
        errorMessage: result.error?.message,
      },
      'procedure error',
    );
  }

  return result;
});
```

Attach it to your base procedure:

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import { loggingMiddleware } from './middleware/logging';

const t = initTRPC.context<Context>().create();

export const publicProcedure = t.procedure.use(loggingMiddleware);
export const router = t.router;
export const middleware = t.middleware;
```

Now every procedure that descends from `publicProcedure` emits structured logs automatically, with no per-procedure logging code.

---

### Child Loggers and Request-Scoped Context

A critical pattern for correlation: create a *child logger* per request, pre-bound with request-level fields such as `requestId`, `userId`, or `traceId`. Child loggers in pino inherit the parent configuration and merge their bound fields into every subsequent log entry.

```ts
// server/context.ts
import { logger } from '../lib/logger';
import { randomUUID } from 'crypto';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req }: CreateNextContextOptions) {
  const requestId = (req.headers['x-request-id'] as string) ?? randomUUID();
  const userId = getUserFromRequest(req); // your auth logic

  return {
    requestId,
    userId,
    // Bind requestId and userId to every log from this request
    log: logger.child({ requestId, userId }),
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

The logging middleware then uses `ctx.log` instead of the root logger:

```ts
export const loggingMiddleware = middleware(async ({ path, type, next, ctx }) => {
  const start = Date.now();
  const result = await next();
  const durationMs = Date.now() - start;

  const entry = { path, type, durationMs };

  if (result.ok) {
    ctx.log.info(entry, 'procedure ok');
  } else {
    ctx.log.error(
      { ...entry, errorCode: (result.error as TRPCError)?.code },
      'procedure error',
    );
  }

  return result;
});
```

**Key Points**

- Every log line from this request now automatically carries `requestId` and `userId`.
- You can filter all logs for a single request in your log management system with `requestId = "abc-123"`.
- This pattern enables distributed tracing correlation if you pass `traceId` from an upstream service via a header.

---

### What Fields to Include

A well-designed log entry for a tRPC procedure call should include:

| Field | Type | Description |
| --- | --- | --- |
| `path` | string | Procedure path, e.g. `post.getById` |
| `type` | string | `query`, `mutation`, or `subscription` |
| `durationMs` | number | Wall-clock time for the procedure |
| `requestId` | string | Unique ID per HTTP request |
| `userId` | string / null | Authenticated user, if any |
| `level` | string | `info`, `warn`, `error` (set by logger) |
| `timestamp` | string | ISO 8601, set by logger automatically |
| `errorCode` | string | TRPCError code on failure |
| `errorMessage` | string | Error message on failure |

Do not log raw input objects by default — they may contain passwords, tokens, or PII. If you need to log inputs, apply an allowlist:

```ts
const safeInput = { postId: input.postId }; // only known-safe fields
ctx.log.info({ safeInput }, 'procedure ok');
```

---

### Logging Input Selectively (Allowlist Pattern)

```ts
// lib/sanitize.ts

// [Inference] The specific fields safe to log depend entirely on your schema.
// This is an example pattern, not a universal rule.

type AllowedFields = Record<string, (keyof unknown)[]>;

export function sanitizeInput(
  input: Record<string, unknown>,
  allowed: string[],
): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries(input).filter(([key]) => allowed.includes(key)),
  );
}
```

Usage in middleware:

```ts
const safeInput = typeof input === 'object' && input !== null
  ? sanitizeInput(input as Record<string, unknown>, ['postId', 'page', 'limit'])
  : {};

ctx.log.info({ path, safeInput }, 'procedure called');
```

---

### Logging Errors with Stack Traces

For `error`-level events, include the stack when available:

```ts
if (!result.ok) {
  const err = result.error;
  ctx.log.error(
    {
      path,
      type,
      durationMs,
      errorCode: err instanceof TRPCError ? err.code : 'INTERNAL',
      errorMessage: err?.message,
      // pino serializes Error objects automatically if you use the err field name
      err,
    },
    'procedure error',
  );
}
```

pino has a built-in `err` serializer that extracts `message`, `stack`, `type`, and `code` from `Error` instances when the field is named `err`. Other loggers may require explicit stack extraction.

---

### Log Levels and When to Use Each

| Level | When to emit |
| --- | --- |
| `trace` | Very granular internals; disabled in production |
| `debug` | Diagnostic details useful during development |
| `info` | Normal procedure completions, significant state changes |
| `warn` | Expected failure paths (not found, rate limited) |
| `error` | Unexpected errors, unhandled exceptions, 5xx outcomes |

In tRPC terms:

- A `NOT_FOUND` error is typically `warn` — it is an expected user-facing condition.
- An `INTERNAL_SERVER_ERROR` is `error` — it represents an unhandled exception.
- A successful procedure call is `info`.

---

### Sampling High-Volume Logs

In high-throughput APIs, logging every successful procedure call at `info` level can produce excessive volume. [Inference] A common mitigation is to sample successful calls — for example, log 10% of successful queries and 100% of errors and mutations. Behavior of sampling strategies depends on your logger and infrastructure; verify against your specific setup.

```ts
// [Inference] Sampling approach — adjust rate to your volume requirements
const SAMPLE_RATE = 0.1; // log 10% of successful queries

if (result.ok && type === 'query' && Math.random() > SAMPLE_RATE) {
  return result; // skip log
}
```

Always log errors and mutations regardless of sampling rate, since those represent state changes or failures.

---

### Integration with Log Management Systems

Structured JSON logs are consumed directly by:

- **Datadog** — use `dd-trace` for APM correlation; structured fields become facets.
- **Grafana Loki** — ships logs via `pino-loki` transport; fields become label selectors.
- **AWS CloudWatch** — JSON lines are parsed automatically; fields become metric filter dimensions.
- **Elastic / OpenSearch** — JSON is indexed as document fields; full-text and field queries both work.

The log entry schema you define in your middleware becomes the query surface in these systems. Consistency in field naming across procedures is important for usability.

---

### Complete Working Example

```ts
// server/middleware/logging.ts
import { middleware } from '../trpc';
import { TRPCError } from '@trpc/server';

export const loggingMiddleware = middleware(async ({ path, type, next, ctx }) => {
  const start = Date.now();

  ctx.log.debug({ path, type }, 'procedure start');

  const result = await next();

  const durationMs = Date.now() - start;

  if (result.ok) {
    ctx.log.info({ path, type, durationMs }, 'procedure ok');
  } else {
    const err = result.error;
    ctx.log.error(
      {
        path,
        type,
        durationMs,
        errorCode: err instanceof TRPCError ? err.code : 'INTERNAL',
        err,
      },
      'procedure error',
    );
  }

  return result;
});
```

```ts
// server/context.ts
import { logger } from '../lib/logger';
import { randomUUID } from 'crypto';

export async function createContext({ req }: { req: Request }) {
  const requestId = req.headers.get('x-request-id') ?? randomUUID();
  return {
    requestId,
    userId: null as string | null, // populated by auth middleware
    log: logger.child({ requestId }),
  };
}
```

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import type { Context } from './context';
import { loggingMiddleware } from './middleware/logging';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const middleware = t.middleware;
export const publicProcedure = t.procedure.use(loggingMiddleware);
```

**Output** (development, pino-pretty):

```
INFO  [03:22:11] procedure ok
  path: "post.getById"
  type: "query"
  durationMs: 14
  requestId: "d3f1a2b4-..."
  userId: "user_99"
```

**Output** (production, raw JSON):

```json
{"level":30,"time":1749261731004,"msg":"procedure ok","path":"post.getById","type":"query","durationMs":14,"requestId":"d3f1a2b4-...","userId":"user_99"}
```

---

**Conclusion**

Structured logging in tRPC procedures is implemented most effectively through a logging middleware attached to the base procedure, combined with a request-scoped child logger created in the context factory. This pattern centralizes all log instrumentation, automatically correlates every log line to its request and user, and produces machine-readable output consumable by any log management platform. Per-procedure logging is reserved for domain-specific events that the generic middleware cannot capture.