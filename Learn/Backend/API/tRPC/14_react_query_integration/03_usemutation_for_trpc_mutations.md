## useMutation for tRPC Mutations

tRPC exposes mutations through a procedure-specific `useMutation` hook, built on top of TanStack Query's `useMutation`. Where `useQuery` runs automatically on mount, `useMutation` gives you an imperative `mutate` or `mutateAsync` function that you call explicitly — typically in response to a user action.

---

### How tRPC Exposes useMutation

```ts
trpc.<router>.<procedure>.useMutation(options?)
```

Like `useQuery`, the hook is generated per-procedure and carries full type inference for input, output, and error. No manual typing is required in standard usage.

---

### Prerequisites

The same setup as `useQuery` applies:

- `@trpc/client`, `@trpc/react-query`, `@tanstack/react-query`
- A tRPC router with at least one mutation procedure
- `TRPCProvider` and `QueryClientProvider` wrapping your app

---

### Defining a Mutation Procedure (Server Side)

```ts
// server/router.ts
import { z } from 'zod';
import { publicProcedure, router } from './trpc';

export const appRouter = router({
  user: router({
    create: publicProcedure
      .input(z.object({
        name: z.string().min(1),
        email: z.string().email(),
      }))
      .mutation(async ({ input }) => {
        // e.g., insert into database
        return { id: 'new-id', name: input.name, email: input.email };
      }),

    delete: publicProcedure
      .input(z.object({ id: z.string() }))
      .mutation(async ({ input }) => {
        // e.g., remove from database
        return { deleted: true, id: input.id };
      }),
  }),
});

export type AppRouter = typeof appRouter;
```

---

### Basic useMutation Usage

```tsx
import { trpc } from '../utils/trpc';

function CreateUserForm() {
  const createUser = trpc.user.create.useMutation();

  const handleSubmit = () => {
    createUser.mutate({
      name: 'Jane Doe',
      email: 'jane@example.com',
    });
  };

  return (
    <div>
      <button onClick={handleSubmit} disabled={createUser.isLoading}>
        {createUser.isLoading ? 'Creating...' : 'Create User'}
      </button>
      {createUser.isError && <p>Error: {createUser.error.message}</p>}
      {createUser.isSuccess && <p>Created: {createUser.data.name}</p>}
    </div>
  );
}
```

**Key Points:**
- `mutate` fires the mutation and does not return a promise — side effects are handled via callbacks
- `createUser.data` is typed as the return type of the `create` procedure
- `createUser.error` is typed as `TRPCClientError`, not a generic `unknown`

---

### mutate vs mutateAsync

tRPC surfaces both variants from TanStack Query:

| | `mutate` | `mutateAsync` |
|---|---|---|
| Return value | `void` | `Promise<TData>` |
| Error handling | Via `onError` callback | Via `try/catch` |
| Usage style | Fire-and-forget | `async/await` |

#### Using mutateAsync

```tsx
const createUser = trpc.user.create.useMutation();

const handleSubmit = async () => {
  try {
    const result = await createUser.mutateAsync({
      name: 'Jane Doe',
      email: 'jane@example.com',
    });
    console.log('Created user with id:', result.id);
  } catch (err) {
    console.error('Mutation failed:', err);
  }
};
```

**Key Points:**
- `mutateAsync` surfaces errors as thrown exceptions — always wrap in `try/catch`
- `mutate` swallows errors internally and routes them to `onError`; unhandled promise rejections [Inference] may occur if you use `mutate` and also attach `.catch()` to it

---

### Callbacks: onSuccess, onError, onSettled, onMutate

Callbacks can be defined at two levels:

1. **Hook level** — passed to `useMutation(options)`; run for every call to `mutate`
2. **Call level** — passed directly to `mutate(input, options)`; run only for that specific call

```tsx
// Hook-level callbacks
const createUser = trpc.user.create.useMutation({
  onSuccess: (data) => {
    console.log('Hook-level success:', data.id);
  },
  onError: (error) => {
    console.error('Hook-level error:', error.message);
  },
  onSettled: (data, error) => {
    // Runs after success or error
    console.log('Hook-level settled');
  },
});

// Call-level callbacks
createUser.mutate(
  { name: 'Jane', email: 'jane@example.com' },
  {
    onSuccess: (data) => {
      console.log('Call-level success:', data.id);
    },
    onError: (error) => {
      console.error('Call-level error:', error.message);
    },
  }
);
```

**Key Points:**
- When both levels define `onSuccess`, [Inference] TanStack Query runs hook-level first, then call-level — consult TanStack Query docs for authoritative callback ordering as this may vary
- `onSettled` is useful for cleanup that should happen regardless of outcome

---

### Mutation State

```tsx
const {
  mutate,
  mutateAsync,
  isIdle,       // No mutation has been triggered yet
  isLoading,    // Mutation is in-flight
  isSuccess,    // Last mutation succeeded
  isError,      // Last mutation failed
  data,         // Result of the last successful mutation
  error,        // Error from the last failed mutation
  reset,        // Resets state back to idle
  status,       // 'idle' | 'loading' | 'success' | 'error'
} = trpc.user.create.useMutation();
```

**Key Points:**
- State reflects the most recent mutation call — if you call `mutate` multiple times, earlier results are overwritten
- `reset()` clears `data`, `error`, and returns the hook to `isIdle`

---

### Invalidating Queries After Mutation

A primary use of `onSuccess` is invalidating related queries so the UI reflects the updated server state:

```tsx
const utils = trpc.useUtils();

const createUser = trpc.user.create.useMutation({
  onSuccess: async () => {
    // Invalidate the user list so it refetches
    await utils.user.list.invalidate();
  },
});
```

[Inference] Calling `invalidate()` marks the cached query as stale and triggers a refetch if the query is currently mounted. Actual refetch behavior depends on TanStack Query's internal logic and active subscribers.

---

### Optimistic Updates

Optimistic updates modify the cache immediately before the server responds, then roll back if the mutation fails.

```tsx
const utils = trpc.useUtils();

const createUser = trpc.user.create.useMutation({
  onMutate: async (newUser) => {
    // Cancel any in-flight refetches that could overwrite optimistic data
    await utils.user.list.cancel();

    // Snapshot the previous value
    const previousUsers = utils.user.list.getData();

    // Optimistically update the cache
    utils.user.list.setData(undefined, (old = []) => [
      ...old,
      { id: 'temp-id', ...newUser },
    ]);

    // Return context for rollback
    return { previousUsers };
  },

  onError: (err, newUser, context) => {
    // Roll back to the snapshot
    if (context?.previousUsers) {
      utils.user.list.setData(undefined, context.previousUsers);
    }
  },

  onSettled: async () => {
    // Always sync with the server after mutation
    await utils.user.list.invalidate();
  },
});
```

**Key Points:**
- `onMutate` receives the input that will be sent to the server
- The value returned from `onMutate` becomes the `context` parameter in `onError` and `onSettled`
- `cancel()` [Inference] cancels in-flight React Query fetches for that procedure, not arbitrary network requests — behavior may vary

---

### Resetting Mutation State

```tsx
const createUser = trpc.user.create.useMutation();

return (
  <div>
    {createUser.isError && (
      <div>
        <p>Something went wrong: {createUser.error.message}</p>
        <button onClick={() => createUser.reset()}>Dismiss</button>
      </div>
    )}
    <button onClick={() => createUser.mutate({ name: 'Jane', email: 'jane@example.com' })}>
      Create
    </button>
  </div>
);
```

---

### Error Handling with TRPCClientError

```tsx
import { TRPCClientError } from '@trpc/client';
import type { AppRouter } from '../server/router';

const createUser = trpc.user.create.useMutation({
  onError: (error) => {
    if (error instanceof TRPCClientError<AppRouter>) {
      console.log(error.data?.code);       // e.g., 'CONFLICT'
      console.log(error.data?.httpStatus); // e.g., 409
      console.log(error.message);
    }
  },
});
```

---

### Multiple Mutations in One Component

Each `useMutation` call is independent and maintains its own state:

```tsx
function UserActions({ userId }: { userId: string }) {
  const utils = trpc.useUtils();

  const deleteUser = trpc.user.delete.useMutation({
    onSuccess: () => utils.user.list.invalidate(),
  });

  const createUser = trpc.user.create.useMutation({
    onSuccess: () => utils.user.list.invalidate(),
  });

  return (
    <div>
      <button
        onClick={() => createUser.mutate({ name: 'New User', email: 'new@example.com' })}
        disabled={createUser.isLoading}
      >
        Add User
      </button>
      <button
        onClick={() => deleteUser.mutate({ id: userId })}
        disabled={deleteUser.isLoading}
      >
        Delete User
      </button>
    </div>
  );
}
```

---

### useMutation vs useQuery — Comparison

| Aspect | `useQuery` | `useMutation` |
|---|---|---|
| Trigger | Automatic on mount | Manual via `mutate` / `mutateAsync` |
| Input passed at | Hook call time | `mutate` call time |
| Caching | Yes — keyed by path + input | No — mutations are not cached |
| Retries | Configurable (default: 3) | No automatic retries by default |
| State reset | Automatic on remount | Manual via `reset()` |
| Side-effect timing | `onSuccess`, `onError` | `onMutate`, `onSuccess`, `onError`, `onSettled` |

---

### Options Reference

| Option | Type | Purpose |
|---|---|---|
| `onMutate` | `(variables) => Promise<context>` | Runs before mutation; return value becomes context |
| `onSuccess` | `(data, variables, context) => void` | Runs after successful mutation |
| `onError` | `(error, variables, context) => void` | Runs after failed mutation |
| `onSettled` | `(data, error, variables, context) => void` | Runs after success or error |
| `retry` | `number \| boolean` | Retry attempts on failure (default: none) |
| `retryDelay` | `number \| (attempt) => number` | Delay between retries |
| `networkMode` | `'online' \| 'always' \| 'offlineFirst'` | Controls when mutation runs relative to network |
| `meta` | `Record<string, unknown>` | Arbitrary metadata passed through to callbacks |

---

**Conclusion:**
`useMutation` in tRPC provides a type-safe, imperative mutation interface backed by TanStack Query. Input, output, and error types are fully inferred from your router. The callback system — `onMutate`, `onSuccess`, `onError`, `onSettled` — enables patterns ranging from simple cache invalidation to full optimistic updates with rollback. All caching and state behavior is governed by TanStack Query internals; consult TanStack Query documentation for authoritative behavior details when results are unexpected.