## TRPCError and Error Codes

### What Is TRPCError

`TRPCError` is the official error class provided by tRPC for throwing structured, typed errors from procedures. When a procedure throws a `TRPCError`, tRPC serializes it and transmits it to the client in a predictable format. The client can then inspect the error's code, message, and optional data.

Any error thrown from a procedure that is *not* a `TRPCError` is treated as an internal server error by default. [Inference] tRPC likely does this to avoid accidentally leaking implementation details from unhandled errors. Behavior may vary depending on tRPC version and custom error formatters.

---

### Importing TRPCError

```ts
import { TRPCError } from '@trpc/server';
```

This class is exported from `@trpc/server` and is used exclusively on the server side inside procedures, middleware, or context functions.

---

### Throwing a TRPCError

The constructor accepts an object with the following fields:

| Field | Type | Required | Description |
|---|---|---|---|
| `code` | `TRPC_ERROR_CODE_KEY` | Yes | A string error code (see below) |
| `message` | `string` | No | Human-readable error description |
| `cause` | `unknown` | No | The underlying error that caused this one |

**Example**

```ts
import { TRPCError } from '@trpc/server';

const appRouter = router({
  getUser: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input }) => {
      const user = await db.user.findUnique({ where: { id: input.id } });

      if (!user) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: `User with id "${input.id}" not found.`,
        });
      }

      return user;
    }),
});
```

---

### Error Codes

tRPC defines a fixed set of error codes. Each code maps to an HTTP status code when using HTTP-based adapters. The mapping is internal to tRPC and may differ slightly across adapter implementations. [Inference] The HTTP mapping exists to maintain compatibility with standard HTTP clients and intermediaries such as proxies and monitoring tools.

| tRPC Code | HTTP Status | Typical Use Case |
|---|---|---|
| `BAD_REQUEST` | 400 | Invalid input, malformed data |
| `UNAUTHORIZED` | 401 | Not authenticated |
| `FORBIDDEN` | 403 | Authenticated but not permitted |
| `NOT_FOUND` | 404 | Resource does not exist |
| `METHOD_NOT_SUPPORTED` | 405 | Wrong HTTP method used |
| `TIMEOUT` | 408 | Operation took too long |
| `CONFLICT` | 409 | State conflict (e.g., duplicate entry) |
| `PRECONDITION_FAILED` | 412 | Precondition not met |
| `PAYLOAD_TOO_LARGE` | 413 | Request body too large |
| `UNPROCESSABLE_CONTENT` | 422 | Semantically invalid input |
| `TOO_MANY_REQUESTS` | 429 | Rate limit exceeded |
| `CLIENT_CLOSED_REQUEST` | 499 | Client disconnected early |
| `INTERNAL_SERVER_ERROR` | 500 | Unhandled or unknown server error |
| `NOT_IMPLEMENTED` | 501 | Feature not yet implemented |
| `BAD_GATEWAY` | 502 | Upstream service failure |
| `SERVICE_UNAVAILABLE` | 503 | Server temporarily unavailable |

---

### Using the cause Field

The `cause` field attaches an underlying error to a `TRPCError`. This is useful for debugging and for passing errors into custom error formatters without exposing raw stack traces to clients.

**Example**

```ts
try {
  await externalService.call();
} catch (err) {
  throw new TRPCError({
    code: 'BAD_GATEWAY',
    message: 'External service failed.',
    cause: err,
  });
}
```

The `cause` is available in the error formatter on the server but is not automatically sent to the client. [Inference] This is likely intentional to avoid leaking internal implementation details. Behavior may vary depending on your error formatter configuration.

---

### How tRPC Handles Non-TRPCError Throws

If a procedure throws anything other than a `TRPCError`, tRPC wraps it internally as an `INTERNAL_SERVER_ERROR`. The original error may still be accessible via the `cause` field inside a custom error formatter.

**Example**

```ts
const appRouter = router({
  risky: publicProcedure.query(() => {
    throw new Error('Something went wrong internally');
    // Client receives: INTERNAL_SERVER_ERROR
    // Original error accessible server-side via cause
  }),
});
```

---

### Checking Error Codes on the Client

On the client side, tRPC exposes the error code through the `TRPCClientError` class. This allows conditional handling based on the specific code thrown.

**Example**

```ts
import { TRPCClientError } from '@trpc/client';

try {
  await trpc.getUser.query({ id: 'abc' });
} catch (err) {
  if (err instanceof TRPCClientError) {
    console.log(err.data?.code);   // e.g., "NOT_FOUND"
    console.log(err.message);      // e.g., "User with id "abc" not found."
  }
}
```

**Key Points**
- `err.data?.code` holds the tRPC error code string
- `err.message` holds the message passed to `TRPCError`
- The `data` field shape depends on your error formatter; the above reflects the default shape

---

### Error Codes in Middleware

`TRPCError` can also be thrown from middleware. This is a common pattern for enforcing authentication or authorization before a procedure executes.

**Example**

```ts
const isAuthed = middleware(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({
      code: 'UNAUTHORIZED',
      message: 'You must be logged in.',
    });
  }
  return next({ ctx: { user: ctx.user } });
});
```

The error propagates the same way as one thrown directly from a procedure. [Inference] tRPC likely treats middleware errors and procedure errors identically in its error pipeline. Behavior may vary.

---

### TRPCError vs Plain Error — Summary

| Concern | `TRPCError` | Plain `Error` |
|---|---|---|
| Client receives structured code | Yes | No (becomes `INTERNAL_SERVER_ERROR`) |
| Maps to HTTP status | Yes | No (defaults to 500) |
| Safe to expose to client | Yes (by design) | No |
| Accessible via `cause` in formatter | Yes | Yes (wrapped) |

---

**Conclusion**

`TRPCError` is the primary mechanism for communicating typed, intentional errors from server to client in tRPC. Using the appropriate error code produces consistent HTTP behavior and enables structured error handling on the client. Unhandled errors default to `INTERNAL_SERVER_ERROR`, which prevents accidental leakage of raw server errors. Custom error formatters extend this foundation and are covered separately.

**Next Steps** — Custom error formatters, `errorFormatter` configuration, and shaping the error response sent to clients.