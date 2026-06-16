## Global Error Handling in tRPC

Global error handling in tRPC gives you a centralized place to intercept, log, transform, and respond to errors that occur anywhere in your router tree — without scattering error logic across individual procedures.

---

### The `onError` Option

The primary mechanism for global error handling is the `onError` callback, passed to the tRPC HTTP adapter when creating your server. It fires for every error that tRPC catches before the response is sent to the client.

**Example** (Express adapter):

```typescript
import express from 'express';
import * as trpcExpress from '@trpc/server/adapters/express';
import { appRouter } from './router';
import { createContext } from './context';

const app = express();

app.use(
  '/trpc',
  trpcExpress.createExpressMiddleware({
    router: appRouter,
    createContext,
    onError({ error, type, path, input, ctx, req }) {
      console.error(`[tRPC Error] [${type}] ${path ?? 'unknown'}:`, error.message);

      // Example: send to external monitoring
      if (error.code === 'INTERNAL_SERVER_ERROR') {
        captureException(error); // e.g., Sentry
      }
    },
  })
);
```

**Key Points:**

- `onError` runs server-side only — it is not exposed to the client
- It receives a structured payload, not just a raw `Error` object
- It does **not** allow you to modify the response sent to the client; it is observation-only
- Returning a value from `onError` has no effect on the error propagated to the caller

---

### The `onError` Payload

The callback receives a single object with the following fields:

| Field   | Type              | Description                                                    |
|---------|-------------------|----------------------------------------------------------------|
| `error` | `TRPCError`       | The tRPC-wrapped error, including `code`, `message`, `cause`   |
| `type`  | `string`          | Procedure type: `'query'`, `'mutation'`, `'subscription'`, or `'unknown'` |
| `path`  | `string \| undefined` | Dot-notation path of the procedure, e.g., `user.getById`   |
| `input` | `unknown`         | The raw input passed to the procedure (may be undefined)       |
| `ctx`   | `Context \| undefined` | The request context, if it was successfully created         |
| `req`   | `Request`         | The raw HTTP request object (adapter-specific type)            |

**Key Points:**

- `path` is `undefined` for errors that occur before routing (e.g., malformed batch requests)
- `ctx` may be `undefined` if `createContext` itself threw
- `input` contains the raw, pre-validation value; it will be `undefined` for input parse failures in some cases [Inference]

---

### Error Shape and `formatError`

tRPC separates the concern of *observing* errors (`onError`) from *shaping* the error response sent to the client (`formatError`).

`formatError` is defined on the router's initialization object using `initTRPC`, not on the adapter. It allows you to transform the JSON structure that the client receives.

**Example:**

```typescript
import { initTRPC } from '@trpc/server';
import { ZodError } from 'zod';

const t = initTRPC.context<Context>().create({
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        zodError:
          error.cause instanceof ZodError
            ? error.cause.flatten()
            : null,
      },
    };
  },
});
```

**Key Points:**

- `shape` contains tRPC's default error shape: `{ message, code, data }`
- `data` includes `httpStatus`, `path`, and `stack` (stack is omitted in production by default)
- Whatever you return from `errorFormatter` is what the client's `TRPCClientError.data` and `TRPCClientError.shape` expose
- `formatError` runs on every error, including validation errors — you have access to the original cause

---

### Default Error Shape

When no `errorFormatter` is provided, tRPC uses a default shape:

```json
{
  "message": "Something went wrong",
  "code": -32603,
  "data": {
    "code": "INTERNAL_SERVER_ERROR",
    "httpStatus": 500,
    "path": "user.getById",
    "stack": "Error: ...\n    at ..."
  }
}
```

**Key Points:**

- `code` at the top level is a JSON-RPC numeric code
- `data.code` is the tRPC string code (e.g., `"UNAUTHORIZED"`, `"NOT_FOUND"`)
- `stack` is only included when `process.env.NODE_ENV !== 'production'` [Inference: exact condition may vary by adapter or runtime]

---

### Combining `onError` and `formatError`

These two are complementary and serve distinct roles:

```
Request → Procedure → Error thrown
                         │
                         ├──► formatError (shapes client response)
                         │
                         └──► onError     (server-side side effects: logging, alerting)
```

A robust production setup uses both:

```typescript
// trpc.ts
const t = initTRPC.context<Context>().create({
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        zodError:
          error.cause instanceof ZodError
            ? error.cause.flatten()
            : null,
        appCode:
          error.cause instanceof AppError
            ? error.cause.appCode
            : null,
      },
    };
  },
});

// server.ts
app.use(
  '/trpc',
  trpcExpress.createExpressMiddleware({
    router: appRouter,
    createContext,
    onError({ error, path, type, ctx }) {
      logger.error({
        path,
        type,
        code: error.code,
        message: error.message,
        userId: ctx?.user?.id,
        cause: error.cause,
      });

      if (error.code === 'INTERNAL_SERVER_ERROR') {
        Sentry.captureException(error.cause ?? error);
      }
    },
  })
);
```

---

### Middleware-Level Global Error Handling

For intercepting errors before they reach `onError`, you can use a root-level middleware attached to every procedure. This is useful when you want to transform or re-classify errors centrally.

```typescript
const errorInterceptor = t.middleware(async ({ next, path, type }) => {
  const result = await next();

  if (!result.ok) {
    // result.error is a TRPCError
    logger.warn(`[Middleware] Caught error on ${path}:`, result.error.code);

    // You can re-throw a different error here
    if (result.error.code === 'INTERNAL_SERVER_ERROR') {
      throw new TRPCError({
        code: 'INTERNAL_SERVER_ERROR',
        message: 'An unexpected error occurred. Please try again.',
        cause: result.error,
      });
    }

    throw result.error;
  }

  return result;
});

const baseProcedure = t.procedure.use(errorInterceptor);
```

**Key Points:**

- `result.ok === false` indicates the downstream procedure threw
- `result.error` is the original `TRPCError`
- Re-throwing replaces the error seen by subsequent middleware and ultimately by `onError` and `formatError`
- This pattern is useful for sanitizing error messages before they reach the formatter

---

### Error Handling for `createContext`

Errors thrown inside `createContext` are handled differently — the procedure never runs, so there is no `path` available. These errors still flow through `onError`, with `path` set to `undefined` and `ctx` set to `undefined`.

```typescript
async function createContext({ req, res }: CreateExpressContextOptions) {
  try {
    const user = await getUserFromToken(req.headers.authorization);
    return { user };
  } catch (err) {
    // Throwing TRPCError here is supported
    throw new TRPCError({
      code: 'UNAUTHORIZED',
      message: 'Invalid or expired token',
      cause: err,
    });
  }
}
```

**Key Points:**

- Throwing a plain `Error` from `createContext` causes tRPC to wrap it as `INTERNAL_SERVER_ERROR` [Inference]
- Throwing a `TRPCError` directly is supported and preserves your chosen error code
- `onError` will still fire, but `ctx` and `path` will both be `undefined`

---

### Stack Trace Exposure Control

By default, tRPC includes stack traces in the `data.stack` field in non-production environments. You can override this behavior using `errorFormatter`:

```typescript
const t = initTRPC.context<Context>().create({
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        // Explicitly strip stack in all environments
        stack: undefined,
      },
    };
  },
});
```

Or conditionally include it only for internal users:

```typescript
errorFormatter({ shape, error, ctx }) {
  return {
    ...shape,
    data: {
      ...shape.data,
      stack: ctx?.user?.isInternal ? shape.data.stack : undefined,
    },
  };
},
```

---

### Summary of Global Error Handling Mechanisms

| Mechanism         | Location         | Modifies Client Response | Use Case                                      |
|-------------------|------------------|--------------------------|-----------------------------------------------|
| `onError`         | Adapter config   | No                       | Logging, alerting, monitoring                 |
| `errorFormatter`  | `initTRPC`       | Yes                      | Shaping error response, attaching metadata    |
| Root middleware   | Procedure chain  | Yes (via re-throw)       | Centralized error transformation, sanitizing  |
| `createContext`   | Context factory  | Indirectly               | Auth failures, setup errors                   |

---

**Conclusion**

Global error handling in tRPC is composed of three complementary layers: `onError` for server-side observation, `errorFormatter` for client-facing response shaping, and root-level middleware for procedural interception. A production-grade setup typically uses all three — logging and alerting in `onError`, structured error metadata in `errorFormatter`, and optional re-classification in middleware. Behavior of specific fields such as `stack` inclusion and `ctx` availability may vary depending on the adapter and runtime environment.