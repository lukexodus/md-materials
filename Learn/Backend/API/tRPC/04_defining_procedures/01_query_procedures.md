## Query Procedures

### Overview

Query procedures are the tRPC equivalent of read operations. They map to HTTP `GET` requests and are used for fetching data without side effects. A query procedure is defined by chaining `.query()` onto a procedure builder. On the client, query procedures are called via `.useQuery()` (React Query integration) or `.query()` (vanilla client).

---

### Defining a Query Procedure

```ts
// server/router/user.router.ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';

export const userRouter = router({
  getAll: publicProcedure
    .query(() => {
      return [
        { id: '1', name: 'Alice' },
        { id: '2', name: 'Bob' },
      ];
    }),
});
```

**Key Points**
- `.query()` accepts a resolver function. The resolver receives a context object and returns the procedure's output.
- A procedure without `.input()` accepts no input. Passing input from the client to an inputless procedure produces a type error.
- The return value of the resolver becomes the inferred output type — no explicit type annotation is required, though one can be added.

---

### Resolver Arguments

The resolver function receives a single argument conventionally named `opts` or destructured directly:

```ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';

export const userRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(({ input, ctx }) => {
      // input: { id: string }
      // ctx: your Context type
      return { id: input.id, name: 'Alice' };
    }),
});
```

| Property | Type | Description |
|---|---|---|
| `input` | Inferred from `.input()` schema | Validated and typed input value |
| `ctx` | Your `Context` type | Value returned by `createContext` |
| `type` | `'query'` | Procedure type identifier |
| `path` | `string` | Full procedure path (e.g. `user.getById`) |
| `rawInput` | `unknown` | Input before validation |
| `signal` | `AbortSignal \| undefined` | Abort signal from the client request |

---

### Input Validation

Input is declared with `.input()` and validated using a Zod schema (or any compatible validator). tRPC validates input before the resolver runs — the resolver only executes if validation passes.

#### Primitive input

```ts
getGreeting: publicProcedure
  .input(z.string())
  .query(({ input }) => {
    return `Hello, ${input}`;
  }),
```

#### Object input

```ts
getById: publicProcedure
  .input(z.object({
    id: z.string().uuid(),
  }))
  .query(({ input }) => {
    return { id: input.id };
  }),
```

#### Optional input with defaults

```ts
getPaginated: publicProcedure
  .input(z.object({
    page: z.number().int().min(1).default(1),
    limit: z.number().int().min(1).max(100).default(20),
  }))
  .query(({ input }) => {
    const { page, limit } = input;
    return { page, limit, items: [] };
  }),
```

**Key Points**
- Zod's `.default()` applies at parse time. If the client omits the field, the default value is present in `input` when the resolver runs.
- If `.input()` is omitted entirely, the procedure accepts no input. Passing any value from the client is a type error.
- [Inference] Validation errors are returned to the client as structured tRPC errors with code `BAD_REQUEST` before the resolver executes. Exact error shape depends on your error formatter configuration.

---

### Async Resolvers

Resolvers can be asynchronous. tRPC awaits the returned promise before sending the response.

```ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';
import { db } from '../db';

export const userRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input, ctx }) => {
      const user = await db.user.findUnique({
        where: { id: input.id },
      });

      if (!user) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: `User with id ${input.id} not found`,
        });
      }

      return user;
    }),
});
```

**Key Points**
- `TRPCError` must be imported from `@trpc/server`.
- Throwing a `TRPCError` sends a structured error response to the client with the specified code and message.
- Unhandled exceptions that are not `TRPCError` instances are caught by tRPC and returned as `INTERNAL_SERVER_ERROR`. The original error message may be obscured depending on your error formatter. [Inference]

---

### Output Validation

Output can be explicitly validated with `.output()`. This is optional — tRPC infers the output type from the resolver's return value by default.

```ts
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
});

getById: publicProcedure
  .input(z.object({ id: z.string() }))
  .output(UserSchema)
  .query(async ({ input }) => {
    // Return value is validated against UserSchema at runtime
    return { id: input.id, name: 'Alice', email: 'alice@example.com' };
  }),
```

**Key Points**
- `.output()` validates the resolver's return value at runtime. If the return value does not match the schema, tRPC throws an `INTERNAL_SERVER_ERROR` before sending the response.
- `.output()` also strips fields not declared in the schema (Zod's default strip behavior), which can act as a data sanitization layer.
- Without `.output()`, TypeScript infers the output type structurally from what the resolver returns — no runtime validation occurs on the output.

---

### Calling Queries on the Client

#### With React Query (`useQuery`)

```tsx
import { trpc } from '../utils/trpc';

function UserProfile({ id }: { id: string }) {
  const user = trpc.user.getById.useQuery({ id });

  if (user.isLoading) return <p>Loading…</p>;
  if (user.error) return <p>Error: {user.error.message}</p>;

  return <p>{user.data.name}</p>;
}
```

#### Passing React Query Options

`useQuery` accepts a second argument for TanStack Query options:

```tsx
const user = trpc.user.getById.useQuery(
  { id },
  {
    enabled: !!id,           // only fetch when id is truthy
    staleTime: 1000 * 60,    // treat data as fresh for 1 minute
    retry: 2,                // retry failed requests twice
    refetchOnWindowFocus: false,
  },
);
```

**Key Points**
- `enabled: false` prevents the query from firing automatically. The query can still be triggered manually via `refetch()`.
- `staleTime` controls when TanStack Query considers cached data stale and eligible for background refetch. Default is `0`, meaning data is immediately stale.
- These are TanStack Query options, not tRPC-specific. Their behavior is governed by TanStack Query, not tRPC.

#### With Vanilla Client

```ts
import { client } from '../utils/client';

const user = await client.user.getById.query({ id: '1' });
console.log(user.name);
```

---

### Deferred and Lazy Queries

To call a query only when explicitly triggered (not on mount), use `useQuery` with `enabled: false` and call `refetch()` manually:

```tsx
function SearchUsers() {
  const [term, setTerm] = useState('');

  const results = trpc.user.search.useQuery(
    { term },
    { enabled: false },
  );

  return (
    <>
      <input
        value={term}
        onChange={e => setTerm(e.target.value)}
      />
      <button onClick={() => results.refetch()}>Search</button>
      {results.data?.map(u => <p key={u.id}>{u.name}</p>)}
    </>
  );
}
```

Alternatively, `useLazyQuery` is available in some TanStack Query versions. [Inference] Availability depends on the TanStack Query version in use — consult the TanStack Query documentation for your installed version.

---

### Query Batching

By default, when `httpBatchLink` is configured, multiple `useQuery` calls that fire in the same tick are batched into a single HTTP request.

```tsx
function Dashboard() {
  const user = trpc.user.getMe.useQuery();
  const posts = trpc.post.getAll.useQuery();
  const stats = trpc.stats.getSummary.useQuery();
  // All three are sent as one batched GET request
}
```

**Output** — single batched request to:

```
GET /trpc/user.getMe,post.getAll,stats.getSummary?batch=1&input=...
```

**Key Points**
- Batching is a behavior of `httpBatchLink`, not of query procedures themselves.
- The server processes each procedure in the batch independently and returns an array of results.
- Batching can be disabled per-client by using `httpLink` instead of `httpBatchLink`.

---

### Infinite Queries

For paginated data, tRPC integrates with TanStack Query's `useInfiniteQuery` via `useInfiniteQuery`:

```ts
// Server
getPaginated: publicProcedure
  .input(z.object({
    cursor: z.string().optional(),
    limit: z.number().min(1).max(50).default(10),
  }))
  .query(async ({ input }) => {
    const { cursor, limit } = input;

    const items = await db.post.findMany({
      take: limit + 1,
      cursor: cursor ? { id: cursor } : undefined,
      orderBy: { createdAt: 'desc' },
    });

    let nextCursor: string | undefined;
    if (items.length > limit) {
      const next = items.pop();
      nextCursor = next?.id;
    }

    return { items, nextCursor };
  }),
```

```tsx
// Client
function PostFeed() {
  const posts = trpc.post.getPaginated.useInfiniteQuery(
    { limit: 10 },
    {
      getNextPageParam: (lastPage) => lastPage.nextCursor,
    },
  );

  return (
    <>
      {posts.data?.pages.flatMap(p => p.items).map(post => (
        <p key={post.id}>{post.title}</p>
      ))}
      <button
        onClick={() => posts.fetchNextPage()}
        disabled={!posts.hasNextPage || posts.isFetchingNextPage}
      >
        Load more
      </button>
    </>
  );
}
```

**Key Points**
- `useInfiniteQuery` requires `getNextPageParam` to extract the cursor for the next page from the last page's response.
- The `cursor` field name is conventional, not required by tRPC. Any field in the input schema can serve as the cursor.
- `data.pages` is an array of individual page results. Flatten with `.flatMap()` to get a single item list.

---

### Common Errors

| Error Code | Cause | Resolution |
|---|---|---|
| `BAD_REQUEST` | Input failed Zod validation | Check input shape against the schema |
| `NOT_FOUND` | Resolver threw `TRPCError({ code: 'NOT_FOUND' })` | Handle missing resource case |
| `UNAUTHORIZED` | Protected procedure called without valid session | Provide auth credentials |
| `INTERNAL_SERVER_ERROR` | Unhandled exception in resolver | Inspect server logs |