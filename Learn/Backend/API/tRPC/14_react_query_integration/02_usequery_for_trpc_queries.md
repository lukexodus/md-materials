## useQuery for tRPC Queries

tRPC's React integration is built on top of TanStack Query (React Query). When you call a tRPC procedure on the client, tRPC wraps it in a React Query `useQuery` hook under the hood, giving you familiar caching, loading states, and refetching behavior — scoped to your type-safe procedure.

---

### How tRPC Exposes useQuery

With the tRPC React client (created via `createTRPCReact`), every query procedure is accessible as:

```ts
trpc.<router>.<procedure>.useQuery(input, options?)
```

This is not a generic `useQuery` call. It is a procedure-specific hook that [Inference] infers its input type and output type directly from your router definition. Behavior depends on your tRPC and TanStack Query versions; results may vary across configurations.

---

### Prerequisites

Your project must have the following set up:

- `@trpc/client`
- `@trpc/react-query`
- `@tanstack/react-query`
- A tRPC router with at least one query procedure
- A `TRPCProvider` wrapping your app (with a `QueryClientProvider`)

---

### Defining a Query Procedure (Server Side)

```ts
// server/router.ts
import { z } from 'zod';
import { publicProcedure, router } from './trpc';

export const appRouter = router({
  user: router({
    getById: publicProcedure
      .input(z.object({ id: z.string() }))
      .query(async ({ input }) => {
        return { id: input.id, name: 'Jane Doe', email: 'jane@example.com' };
      }),

    list: publicProcedure
      .query(async () => {
        return [
          { id: '1', name: 'Jane Doe' },
          { id: '2', name: 'John Smith' },
        ];
      }),
  }),
});

export type AppRouter = typeof appRouter;
```

---

### Creating the tRPC React Client (Client Side)

```ts
// utils/trpc.ts
import { createTRPCReact } from '@trpc/react-query';
import type { AppRouter } from '../server/router';

export const trpc = createTRPCReact<AppRouter>();
```

---

### Basic useQuery Usage

#### Query with Input

```tsx
import { trpc } from '../utils/trpc';

function UserProfile({ userId }: { userId: string }) {
  const { data, isLoading, isError, error } = trpc.user.getById.useQuery(
    { id: userId }
  );

  if (isLoading) return <p>Loading...</p>;
  if (isError) return <p>Error: {error.message}</p>;

  return (
    <div>
      <h2>{data.name}</h2>
      <p>{data.email}</p>
    </div>
  );
}
```

**Key Points:**
- The input `{ id: userId }` is fully typed — passing a wrong shape is a TypeScript compile error
- `data` is typed as the return type of `getById` — no manual type annotation needed
- `error` is typed as a tRPC `TRPCClientError`, not a generic `unknown`

#### Query without Input

```tsx
function UserList() {
  const { data: users = [], isLoading } = trpc.user.list.useQuery();

  if (isLoading) return <p>Loading...</p>;

  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

When a procedure has no input, call `useQuery()` with no arguments or pass `undefined`.

---

### The Options Parameter

The second argument to `useQuery` accepts standard TanStack Query options. [Inference] tRPC passes these through to the underlying `useQuery` call; consult TanStack Query docs for full option behavior.

```tsx
trpc.user.getById.useQuery(
  { id: userId },
  {
    enabled: !!userId,           // Only run when userId is truthy
    staleTime: 1000 * 60 * 5,   // 5 minutes before refetch
    refetchOnWindowFocus: false,
    retry: 2,
    onSuccess: (data) => {
      console.log('Fetched:', data);
    },
    onError: (err) => {
      console.error('Failed:', err.message);
    },
  }
)
```

#### Commonly Used Options

| Option | Type | Purpose |
|---|---|---|
| `enabled` | `boolean` | Conditionally run the query |
| `staleTime` | `number` (ms) | How long data is considered fresh |
| `cacheTime` | `number` (ms) | How long inactive data stays in cache |
| `refetchOnWindowFocus` | `boolean` | Refetch when the browser tab regains focus |
| `refetchInterval` | `number` (ms) | Polling interval |
| `retry` | `number \| boolean` | Number of retry attempts on failure |
| `select` | `(data) => T` | Transform or pick from returned data |
| `initialData` | `T` | Pre-populate data before first fetch |
| `placeholderData` | `T` | Show while loading without marking as stale |

---

### Conditional Queries with enabled

A common pattern is to skip a query until a dependency is available:

```tsx
function ConditionalFetch({ userId }: { userId: string | null }) {
  const { data } = trpc.user.getById.useQuery(
    { id: userId! },   // Non-null assertion safe here because of `enabled`
    { enabled: !!userId }
  );

  return <div>{data?.name ?? 'No user selected'}</div>;
}
```

**Key Points:**
- When `enabled` is `false`, the query does not execute and `data` remains `undefined`
- The non-null assertion `userId!` is needed because TypeScript does not narrow based on `enabled`; this is a known limitation in this pattern [Inference]

---

### Transforming Data with select

```tsx
const { data: userName } = trpc.user.getById.useQuery(
  { id: userId },
  {
    select: (user) => user.name,
  }
);
// `userName` is typed as `string`, not the full user object
```

`select` transforms the returned data on the client without altering the cache. [Inference] The full response is still stored in the cache; only the returned `data` reference is transformed.

---

### Accessing Query State

```tsx
const {
  data,
  isLoading,      // True on first load with no cached data
  isFetching,     // True whenever a request is in-flight (including refetches)
  isSuccess,
  isError,
  error,
  status,         // 'loading' | 'error' | 'success'
  fetchStatus,    // 'fetching' | 'paused' | 'idle'
  refetch,        // Manually trigger refetch
  dataUpdatedAt,  // Timestamp of last successful fetch
} = trpc.user.getById.useQuery({ id: userId });
```

**Key Points:**
- `isLoading` and `isFetching` differ: `isFetching` is `true` on background refetches even when `data` is already present
- `refetch()` can be called imperatively, such as from a button click

---

### Query Keys in tRPC

tRPC [Inference] automatically generates React Query cache keys from the procedure path and input. You do not manage query keys manually in typical usage.

```ts
// These are cached independently because inputs differ
trpc.user.getById.useQuery({ id: '1' });
trpc.user.getById.useQuery({ id: '2' });
```

If you need to manually interact with the cache (e.g., invalidation), tRPC provides utilities via the query client:

```ts
const utils = trpc.useUtils(); // or trpc.useContext() in older versions

// Invalidate all getById queries
await utils.user.getById.invalidate();

// Invalidate for a specific input
await utils.user.getById.invalidate({ id: '1' });
```

---

### Polling with refetchInterval

```tsx
const { data } = trpc.user.list.useQuery(undefined, {
  refetchInterval: 5000, // Refetch every 5 seconds
});
```

[Inference] This triggers a background refetch on the given interval while the component is mounted. Actual interval behavior may be affected by tab visibility and browser throttling.

---

### Error Handling

tRPC errors are instances of `TRPCClientError`. You can inspect the error shape for server-thrown `TRPCError` details:

```tsx
import { TRPCClientError } from '@trpc/client';
import type { AppRouter } from '../server/router';

const { isError, error } = trpc.user.getById.useQuery({ id: userId });

if (isError) {
  if (error instanceof TRPCClientError<AppRouter>) {
    console.log(error.data?.code);    // e.g., 'NOT_FOUND'
    console.log(error.data?.httpStatus);
    console.log(error.message);
  }
}
```

---

### useQuery vs useSuspenseQuery

tRPC also exposes `useSuspenseQuery` for React Suspense-based data fetching:

```tsx
// Must be wrapped in a <Suspense> boundary
const { data } = trpc.user.getById.useSuspenseQuery({ id: userId });
// `data` is always defined here — no isLoading check needed
```

| | `useQuery` | `useSuspenseQuery` |
|---|---|---|
| Loading state | Manual (`isLoading`) | Suspense boundary |
| `data` type | `T \| undefined` | `T` (always defined) |
| Error handling | `isError` / `error` | Error boundary |
| React version | Any | React 18+ recommended |

---

### Common Patterns Summary

| Pattern | Mechanism |
|---|---|
| Dependent query | `enabled: !!dependency` |
| Polling | `refetchInterval: ms` |
| Data transformation | `select: (data) => ...` |
| Manual refetch | `refetch()` from hook return |
| Cache invalidation | `utils.<procedure>.invalidate()` |
| Suspense mode | `useSuspenseQuery` |

---

**Conclusion:**
`useQuery` in tRPC provides a fully type-safe, React Query-powered data fetching layer. Input types, output types, and error shapes are all inferred from your router — no manual typing or query key management is required in standard usage. The second options parameter accepts the full TanStack Query options surface, making tRPC queries composable with existing React Query patterns. Behavior of caching, refetching, and error handling is governed by TanStack Query internals; always consult the TanStack Query documentation for authoritative behavior details.