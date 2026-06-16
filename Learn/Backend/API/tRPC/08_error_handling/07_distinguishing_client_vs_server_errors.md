## Distinguishing Client vs Server Errors

In tRPC, errors are categorized by their origin and meaning — whether a request failed because the client did something wrong, or because something went wrong on the server. This distinction drives HTTP status codes, client-side handling strategies, retry logic, and user-facing messaging.

---

### How tRPC Classifies Errors

tRPC uses a fixed set of error codes defined in `@trpc/server`. Each code maps to an HTTP status and carries an implicit meaning about fault ownership.

The full set of codes, grouped by category:

#### Client-Fault Errors (4xx)

| tRPC Code            | HTTP Status | Meaning                                                   |
|----------------------|-------------|-----------------------------------------------------------|
| `BAD_REQUEST`        | 400         | Malformed input; the request itself is invalid            |
| `UNAUTHORIZED`       | 401         | Missing or invalid authentication credentials             |
| `FORBIDDEN`          | 403         | Authenticated but not permitted to perform this action    |
| `NOT_FOUND`          | 404         | The requested resource does not exist                     |
| `METHOD_NOT_SUPPORTED` | 405       | HTTP method not allowed for this endpoint                 |
| `TIMEOUT`            | 408         | Request took too long [Inference: may also reflect server-side limits] |
| `CONFLICT`           | 409         | State conflict, e.g., duplicate resource creation         |
| `PRECONDITION_FAILED`| 412         | A precondition in the request was not met                 |
| `PAYLOAD_TOO_LARGE`  | 413         | Request body exceeds acceptable size                      |
| `UNPROCESSABLE_CONTENT` | 422      | Input was structurally valid but semantically invalid     |
| `TOO_MANY_REQUESTS`  | 429         | Rate limit exceeded                                       |
| `CLIENT_CLOSED_REQUEST` | 499      | Client disconnected before the server responded           |

#### Server-Fault Errors (5xx)

| tRPC Code               | HTTP Status | Meaning                                             |
|-------------------------|-------------|-----------------------------------------------------|
| `INTERNAL_SERVER_ERROR` | 500         | Unhandled or unexpected server-side failure         |
| `NOT_IMPLEMENTED`       | 501         | Procedure exists but is not yet implemented         |
| `BAD_GATEWAY`           | 502         | Upstream service returned an invalid response       |
| `SERVICE_UNAVAILABLE`   | 503         | Server temporarily unavailable                      |
| `GATEWAY_TIMEOUT`       | 504         | Upstream service did not respond in time            |

---

### The `TRPCError` Class

All errors in tRPC are instances of `TRPCError`. The `code` property determines the category.

```typescript
import { TRPCError } from '@trpc/server';

// Client fault — wrong input
throw new TRPCError({
  code: 'BAD_REQUEST',
  message: 'Email address is not valid.',
});

// Client fault — access control
throw new TRPCError({
  code: 'FORBIDDEN',
  message: 'You do not have permission to delete this resource.',
});

// Server fault — unexpected failure
throw new TRPCError({
  code: 'INTERNAL_SERVER_ERROR',
  message: 'Failed to process payment.',
  cause: originalError,
});
```

**Key Points:**

- `cause` accepts any value and is available in `onError` as `error.cause`
- `message` is sent to the client — avoid including sensitive internal details in server-fault messages
- The `code` drives the HTTP status code returned by the adapter

---

### Validation Errors Are Client Errors

When you use Zod (or another schema library) for input validation, tRPC automatically catches `ZodError` and converts it to a `BAD_REQUEST` — a client-fault error. You do not need to throw manually.

```typescript
import { z } from 'zod';

export const createUser = t.procedure
  .input(
    z.object({
      email: z.string().email(),
      age: z.number().min(18),
    })
  )
  .mutation(async ({ input }) => {
    // If input fails validation, tRPC throws BAD_REQUEST automatically
    return db.user.create({ data: input });
  });
```

When using `errorFormatter`, you can expose structured Zod errors to the client:

```typescript
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

- `error.code` will be `'BAD_REQUEST'` for validation failures
- `error.cause` will be the original `ZodError` instance
- The client can check `TRPCClientError.data.zodError` to display field-level messages

---

### Detecting Error Type on the Client

On the client side, errors arrive as `TRPCClientError`. The `data.code` field carries the string code, and `data.httpStatus` carries the numeric HTTP status.

```typescript
import { TRPCClientError } from '@trpc/client';

try {
  await trpc.user.create.mutate({ email: 'bad', age: 15 });
} catch (err) {
  if (err instanceof TRPCClientError) {
    const code = err.data?.code;
    const httpStatus = err.data?.httpStatus;

    if (code === 'UNAUTHORIZED') {
      redirectToLogin();
    } else if (code === 'BAD_REQUEST') {
      showValidationError(err.message);
    } else if (code === 'FORBIDDEN') {
      showPermissionDenied();
    } else if (httpStatus && httpStatus >= 500) {
      showGenericServerError();
    }
  }
}
```

**Key Points:**

- Always check `err instanceof TRPCClientError` before accessing `.data`
- `err.data` may be `undefined` for network-level failures where no tRPC response was received
- `err.shape` contains the full formatted error shape as returned by `errorFormatter`

---

### Utility: Checking Error Category

You can write a small utility to distinguish client from server errors without hardcoding every code:

```typescript
import { TRPCClientError } from '@trpc/client';

const CLIENT_ERROR_CODES = new Set([
  'BAD_REQUEST',
  'UNAUTHORIZED',
  'FORBIDDEN',
  'NOT_FOUND',
  'CONFLICT',
  'PRECONDITION_FAILED',
  'PAYLOAD_TOO_LARGE',
  'UNPROCESSABLE_CONTENT',
  'TOO_MANY_REQUESTS',
  'METHOD_NOT_SUPPORTED',
  'CLIENT_CLOSED_REQUEST',
  'TIMEOUT',
]);

function isClientError(err: unknown): boolean {
  if (!(err instanceof TRPCClientError)) return false;
  return CLIENT_ERROR_CODES.has(err.data?.code ?? '');
}

function isServerError(err: unknown): boolean {
  if (!(err instanceof TRPCClientError)) return false;
  const status = err.data?.httpStatus ?? 0;
  return status >= 500;
}
```

---

### Retry Logic Based on Error Category

A key practical consequence of distinguishing error categories is retry behavior. Retrying a client error is pointless — the request will fail again with the same result. Retrying a server error may succeed.

```typescript
import { createTRPCClient, httpBatchLink } from '@trpc/client';

const client = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({
      url: '/trpc',
    }),
  ],
});
```

With TanStack Query (React Query), you can configure `retry` based on error type:

```typescript
import { TRPCClientError } from '@trpc/client';

const trpc = createTRPCReact<AppRouter>();

function MyApp() {
  return (
    <trpc.Provider
      client={trpcClient}
      queryClient={
        new QueryClient({
          defaultOptions: {
            queries: {
              retry(failureCount, error) {
                // Never retry client errors
                if (
                  error instanceof TRPCClientError &&
                  error.data?.httpStatus &&
                  error.data.httpStatus < 500
                ) {
                  return false;
                }
                return failureCount < 3;
              },
            },
          },
        })
      }
    >
      <App />
    </trpc.Provider>
  );
}
```

**Key Points:**

- `error.data?.httpStatus < 500` identifies client-fault errors
- Server errors (5xx) are candidates for retry with backoff
- `TIMEOUT` (408) is a borderline case — it may warrant a single retry [Inference]
- `CLIENT_CLOSED_REQUEST` (499) should not be retried; it means the client itself closed the connection

---

### Server-Side: Avoiding Accidental `INTERNAL_SERVER_ERROR`

A common mistake is allowing unexpected error types (plain `Error`, database exceptions, etc.) to propagate unhandled — tRPC wraps these as `INTERNAL_SERVER_ERROR`. This leaks fault classification and often exposes unhelpful or unsafe messages.

**Example of the problem:**

```typescript
// ❌ Database error propagates as INTERNAL_SERVER_ERROR with raw DB message
const getUser = t.procedure
  .input(z.object({ id: z.string() }))
  .query(async ({ input }) => {
    return db.user.findUniqueOrThrow({ where: { id: input.id } });
    // Prisma throws if not found — raw error goes to client as 500
  });
```

**Corrected:**

```typescript
// ✅ Explicitly handle known failure modes
const getUser = t.procedure
  .input(z.object({ id: z.string() }))
  .query(async ({ input }) => {
    const user = await db.user.findUnique({ where: { id: input.id } });

    if (!user) {
      throw new TRPCError({
        code: 'NOT_FOUND',
        message: `User ${input.id} not found.`,
      });
    }

    return user;
  });
```

**Key Points:**

- `NOT_FOUND` is a client error — the client sent an ID that doesn't exist
- Letting Prisma's `findUniqueOrThrow` propagate returns a 500 for what is logically a 404
- Accurate error codes improve client-side handling and API debuggability

---

### Diagram: Error Flow and Classification

<svg viewBox="0 0 720 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace, sans-serif" font-size="13">
  <!-- Background -->
  <rect width="720" height="400" fill="#0f1117" rx="12"/>

  <!-- Client Box -->
  <rect x="30" y="160" width="110" height="48" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
  <text x="85" y="180" text-anchor="middle" fill="#94a3b8">Client</text>
  <text x="85" y="198" text-anchor="middle" fill="#64748b" font-size="11">request</text>

  <!-- Arrow: client to router -->
  <line x1="140" y1="184" x2="210" y2="184" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Router Box -->
  <rect x="210" y="160" width="120" height="48" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
  <text x="270" y="180" text-anchor="middle" fill="#94a3b8">Router /</text>
  <text x="270" y="198" text-anchor="middle" fill="#94a3b8">Procedure</text>

  <!-- Arrow: router to error split -->
  <line x1="330" y1="184" x2="390" y2="184" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Split circle -->
  <circle cx="405" cy="184" r="14" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
  <text x="405" y="189" text-anchor="middle" fill="#93c5fd" font-size="15">?</text>

  <!-- Arrow up: 4xx -->
  <line x1="405" y1="170" x2="405" y2="80" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#arry)"/>
  <!-- Arrow down: 5xx -->
  <line x1="405" y1="198" x2="405" y2="300" stroke="#ef4444" stroke-width="1.5" marker-end="url(#arrr)"/>

  <!-- 4xx Box -->
  <rect x="460" y="52" width="210" height="60" rx="8" fill="#1c1a0f" stroke="#d97706" stroke-width="1.5"/>
  <text x="565" y="76" text-anchor="middle" fill="#fbbf24" font-weight="bold">Client Error (4xx)</text>
  <text x="565" y="96" text-anchor="middle" fill="#92400e" font-size="11">BAD_REQUEST · UNAUTHORIZED</text>
  <text x="565" y="110" text-anchor="middle" fill="#92400e" font-size="11">FORBIDDEN · NOT_FOUND · …</text>

  <!-- 5xx Box -->
  <rect x="460" y="268" width="210" height="60" rx="8" fill="#1c0f0f" stroke="#ef4444" stroke-width="1.5"/>
  <text x="565" y="292" text-anchor="middle" fill="#f87171" font-weight="bold">Server Error (5xx)</text>
  <text x="565" y="312" text-anchor="middle" fill="#7f1d1d" font-size="11">INTERNAL_SERVER_ERROR</text>
  <text x="565" y="326" text-anchor="middle" fill="#7f1d1d" font-size="11">SERVICE_UNAVAILABLE · …</text>

  <!-- Labels -->
  <text x="415" y="130" fill="#d97706" font-size="11">client fault</text>
  <text x="415" y="250" fill="#ef4444" font-size="11">server fault</text>

  <!-- Response arrows back to client -->
  <line x1="460" y1="82" x2="85" y2="82" stroke="#d97706" stroke-width="1" stroke-dasharray="5,3" marker-end="url(#arryb)"/>
  <line x1="460" y1="298" x2="85" y2="298" stroke="#ef4444" stroke-width="1" stroke-dasharray="5,3" marker-end="url(#arrrb)"/>
  <line x1="85" y1="82" x2="85" y2="160" stroke="#d97706" stroke-width="1" stroke-dasharray="5,3"/>
  <line x1="85" y1="298" x2="85" y2="208" stroke="#ef4444" stroke-width="1" stroke-dasharray="5,3"/>

  <!-- Legend -->
  <text x="210" y="370" fill="#475569" font-size="11">dashed = response path back to client</text>

  <!-- Arrowhead markers -->
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
    </marker>
    <marker id="arry" markerWidth="8" markerHeight="8" refX="3" refY="0" orient="auto">
      <path d="M0,8 L6,8 L3,0 z" fill="#f59e0b"/>
    </marker>
    <marker id="arrr" markerWidth="8" markerHeight="8" refX="3" refY="8" orient="auto">
      <path d="M0,0 L6,0 L3,8 z" fill="#ef4444"/>
    </marker>
    <marker id="arryb" markerWidth="8" markerHeight="8" refX="0" refY="3" orient="auto">
      <path d="M8,0 L8,6 L0,3 z" fill="#d97706"/>
    </marker>
    <marker id="arrrb" markerWidth="8" markerHeight="8" refX="0" refY="3" orient="auto">
      <path d="M8,0 L8,6 L0,3 z" fill="#ef4444"/>
    </marker>
  </defs>
</svg>

---

### Summary

| Concern                  | Client Error (4xx)                        | Server Error (5xx)                          |
|--------------------------|-------------------------------------------|---------------------------------------------|
| Fault ownership          | The caller                                | The server / infrastructure                 |
| Should client retry?     | No                                        | Yes, with backoff                           |
| Message safety           | Can be descriptive                        | Sanitize; avoid leaking internals           |
| Logging priority         | Low / info                                | High / alert                                |
| Common examples          | Validation, auth, not found               | Unhandled exceptions, DB down, dependencies |

**Conclusion**

Correctly classifying errors as client or server faults is foundational to a well-behaved API. It affects retry logic, logging severity, user-facing messaging, and client handling strategies. tRPC's error code system maps directly to HTTP semantics, giving you a structured and predictable foundation — but accurate classification depends on throwing the right `TRPCError` code in your procedures rather than letting raw exceptions propagate as `INTERNAL_SERVER_ERROR`.