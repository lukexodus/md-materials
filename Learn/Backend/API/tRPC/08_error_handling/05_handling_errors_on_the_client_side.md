## Handling Errors on the Client Side

### Overview

Client-side error handling in tRPC covers catching errors at individual call sites, narrowing error types, reacting to specific codes, and integrating with framework-level patterns such as TanStack Query. Because tRPC errors are typed and carry structured metadata, client code can be precise about which failure conditions it handles and how.

---

### TRPCClientError Recap

All procedure errors from the server arrive as `TRPCClientError` instances. Network-level failures (DNS, connection refused) are plain errors and will not be `TRPCClientError` instances.

```ts
import { TRPCClientError } from '@trpc/client';
```

The two primary narrowing approaches:

```ts
// instanceof check
if (err instanceof TRPCClientError) { ... }

// static type guard (safer across bundler module boundaries)
if (TRPCClientError.isTRPCClientError(err)) { ... }
```

---

### Vanilla Client — try/catch

With the vanilla tRPC client, all procedure calls return promises. Errors are caught with standard `try/catch`.

**Example — query**

```ts
try {
  const post = await trpc.post.getById.query({ id: '123' });
  render(post);
} catch (err) {
  if (TRPCClientError.isTRPCClientError(err)) {
    console.error(err.data?.code, err.message);
  } else {
    console.error('Network or unknown error', err);
  }
}
```

**Example — mutation**

```ts
try {
  const result = await trpc.post.create.mutate({ title: 'Hello' });
  redirect(`/posts/${result.id}`);
} catch (err) {
  if (TRPCClientError.isTRPCClientError(err)) {
    if (err.data?.code === 'UNAUTHORIZED') {
      redirectToLogin();
    } else {
      showToast(err.message);
    }
  }
}
```

---

### Branching on Error Code

Switching on `err.data?.code` is the idiomatic pattern for handling multiple distinct failure modes from a single call.

**Example**

```ts
async function submitForm(data: FormData) {
  try {
    await trpc.user.register.mutate(data);
  } catch (err) {
    if (!TRPCClientError.isTRPCClientError(err)) {
      showToast('A network error occurred.');
      return;
    }

    switch (err.data?.code) {
      case 'BAD_REQUEST':
        showValidationErrors(err.data.zodError?.fieldErrors);
        break;
      case 'CONFLICT':
        showToast('An account with this email already exists.');
        break;
      case 'TOO_MANY_REQUESTS':
        showToast('Too many attempts. Please wait and try again.');
        break;
      default:
        showToast('Registration failed. Please try again.');
    }
  }
}
```

**Key Points**
- `err.data?.code` may be `undefined` if the response was malformed or the server returned an unexpected format
- Always provide a `default` case to handle unexpected codes gracefully
- `err.data?.zodError` is only present if the server's `errorFormatter` includes it

---

### TanStack Query — useQuery

When using tRPC's TanStack Query integration, query errors surface through the `error` field on the query result. The error is automatically typed as `TRPCClientError`.

**Example**

```tsx
function PostView({ id }: { id: string }) {
  const { data, error, isError, isLoading } = trpc.post.getById.useQuery({ id });

  if (isLoading) return <Spinner />;

  if (isError) {
    if (error.data?.code === 'NOT_FOUND') {
      return <p>This post does not exist.</p>;
    }
    if (error.data?.code === 'FORBIDDEN') {
      return <p>You do not have access to this post.</p>;
    }
    return <p>Failed to load post.</p>;
  }

  return <Post data={data} />;
}
```

**Key Points**
- TanStack Query types `error` as `TRPCClientError<AppRouter>` when using the tRPC React integration — no `instanceof` narrowing required in this context
- [Inference] The precise type of `error` depends on the tRPC and TanStack Query versions in use. Behavior may vary.
- `isError` is `true` only after all retries are exhausted; TanStack Query retries failed queries by default

---

### TanStack Query — useMutation

Mutation errors are handled via `onError` in the mutation options, or from the `error` field on the mutation result object.

**Example — onError callback**

```tsx
function CreatePostForm() {
  const createPost = trpc.post.create.useMutation({
    onSuccess(data) {
      redirect(`/posts/${data.id}`);
    },
    onError(err) {
      if (err.data?.code === 'UNAUTHORIZED') {
        redirectToLogin();
        return;
      }
      showToast(err.message ?? 'Failed to create post.');
    },
  });

  return (
    <button onClick={() => createPost.mutate({ title: 'New Post' })}>
      Create
    </button>
  );
}
```

**Example — result field**

```tsx
function CreatePostForm() {
  const createPost = trpc.post.create.useMutation();

  return (
    <>
      {createPost.isError && (
        <p>{createPost.error.message}</p>
      )}
      <button onClick={() => createPost.mutate({ title: 'New Post' })}>
        Create
      </button>
    </>
  );
}
```

---

### Displaying Zod Field Errors

When the server's error formatter includes `zodError`, field-level validation errors can be mapped directly to form fields on the client.

**Example**

```tsx
function RegisterForm() {
  const [fieldErrors, setFieldErrors] = useState<Record<string, string[]>>({});

  const register = trpc.user.register.useMutation({
    onError(err) {
      if (err.data?.zodError?.fieldErrors) {
        setFieldErrors(err.data.zodError.fieldErrors);
      } else {
        showToast(err.message);
      }
    },
  });

  return (
    <>
      <input name="email" />
      {fieldErrors.email && <span>{fieldErrors.email[0]}</span>}

      <input name="password" />
      {fieldErrors.password && <span>{fieldErrors.password[0]}</span>}

      <button onClick={() => register.mutate({ email: '...', password: '...' })}>
        Register
      </button>
    </>
  );
}
```

**Key Points**
- `err.data?.zodError` is `null` or absent on non-validation errors; always guard before accessing `.fieldErrors`
- `fieldErrors[field]` is an array of strings; take index `[0]` for a single message or join for all
- [Inference] `zodError` shape reflects `ZodError.flatten()` output. This may vary if a different Zod flattening method was used in the formatter.

---

### Retry Behavior with TanStack Query

TanStack Query retries failed queries automatically by default. For certain tRPC error codes this is undesirable — a `NOT_FOUND` or `UNAUTHORIZED` error will not resolve by retrying.

**Example — disabling retry for specific codes**

```ts
const trpc = createTRPCReact<AppRouter>();

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry(failureCount, err) {
        if (
          err instanceof TRPCClientError &&
          ['NOT_FOUND', 'UNAUTHORIZED', 'FORBIDDEN', 'BAD_REQUEST'].includes(
            err.data?.code ?? ''
          )
        ) {
          return false;
        }
        return failureCount < 2;
      },
    },
  },
});
```

**Key Points**
- Retrying `UNAUTHORIZED` or `NOT_FOUND` wastes requests and delays the error state for the user
- `INTERNAL_SERVER_ERROR`, `SERVICE_UNAVAILABLE`, and `TIMEOUT` are generally worth retrying
- [Inference] The appropriate retry strategy depends on application requirements. The above is a common starting pattern, not a universal recommendation.

---

### Error Boundaries (React)

For query errors in React, an error boundary can catch unhandled query errors that bubble up from `useQuery` when `throwOnError` (formerly `useErrorBoundary`) is enabled.

**Example — enabling throwOnError**

```tsx
trpc.post.getById.useQuery(
  { id },
  { throwOnError: true }
);
```

**Example — error boundary**

```tsx
class PostErrorBoundary extends React.Component {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error: unknown) {
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) {
      const err = this.state.error;
      if (TRPCClientError.isTRPCClientError(err)) {
        if (err.data?.code === 'NOT_FOUND') {
          return <NotFoundPage />;
        }
      }
      return <GenericErrorPage />;
    }
    return this.props.children;
  }
}
```

**Key Points**
- `throwOnError` causes TanStack Query to throw the error into the React render tree on failure
- Error boundaries are a React mechanism and function independently of tRPC; tRPC only determines the shape of the thrown error
- [Inference] `throwOnError` option naming may differ across TanStack Query versions. Verify against the version in use.

---

### Separating Network Errors from Procedure Errors

A utility function centralizes the distinction and keeps call sites clean.

**Example**

```ts
function classifyError(err: unknown):
  | { type: 'trpc'; code: string; message: string; data: unknown }
  | { type: 'network'; message: string }
  | { type: 'unknown' } {

  if (TRPCClientError.isTRPCClientError(err)) {
    return {
      type: 'trpc',
      code: err.data?.code ?? 'UNKNOWN',
      message: err.message,
      data: err.data,
    };
  }

  if (err instanceof Error) {
    return { type: 'network', message: err.message };
  }

  return { type: 'unknown' };
}
```

**Usage**

```ts
const classified = classifyError(err);

if (classified.type === 'trpc' && classified.code === 'FORBIDDEN') {
  showToast('Access denied.');
}
```

---

### Common Mistakes

| Mistake | Effect |
|---|---|
| Accessing `err.data?.code` without narrowing | TypeScript error; runtime `undefined` access if `err` is not `TRPCClientError` |
| Not handling network errors separately | Network failures silently swallowed or misclassified |
| Relying on `err.message` for user display in production | May expose internal messages if server does not sanitize |
| Not guarding `zodError` before access | `null` reference if formatter returns `null` on non-Zod errors |
| Retrying all error codes | Retrying `UNAUTHORIZED` or `NOT_FOUND` delays user feedback |
| Using `error` field from `useQuery` without checking `isError` | `error` may be `null` when no error has occurred |

---

### Handling Strategy Summary

| Context | Error Access Point | Narrowing Needed |
|---|---|---|
| Vanilla client | `catch (err)` | `isTRPCClientError(err)` |
| `useQuery` | `error` field on result | Not required — already typed |
| `useMutation` | `onError(err)` callback or `error` field | Not required — already typed |
| Error boundary | Thrown into render tree via `throwOnError` | `isTRPCClientError(err)` |
| Global link | `observer.error(err)` interception | `isTRPCClientError(err)` |

---

**Conclusion**

Client-side error handling in tRPC is structured around `TRPCClientError` and its `data.code` field. The two primary surfaces are `try/catch` for vanilla clients and the `error` field or `onError` callback for TanStack Query integrations. Zod field errors require a custom server formatter and are accessed via `err.data?.zodError`. Retry behavior, error boundaries, and global link interception extend this baseline for production-grade applications. Distinguishing procedure errors from network errors is essential for accurate user feedback.

**Next Steps** — Input validation with Zod, and how validation errors are automatically converted to `BAD_REQUEST` in tRPC's pipeline.