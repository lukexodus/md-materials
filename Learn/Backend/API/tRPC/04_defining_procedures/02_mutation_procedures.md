## Mutation Procedures

### Overview

Mutation procedures are the tRPC equivalent of write operations — creating, updating, or deleting data. They map to HTTP `POST` requests and are defined by chaining `.mutation()` onto a procedure builder. On the client, mutation procedures are called via `.useMutation()` (React Query integration) or `.mutate()` (vanilla client). Unlike queries, mutations do not run automatically on component mount — they are triggered explicitly.

---

### Defining a Mutation Procedure

```ts
// server/router/user.router.ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';

export const userRouter = router({
  create: publicProcedure
    .input(z.object({
      name: z.string().min(1),
      email: z.string().email(),
    }))
    .mutation(async ({ input }) => {
      // persist to database
      return { id: 'generated-id', ...input };
    }),
});
```

**Key Points**
- `.mutation()` accepts a resolver function with the same signature as `.query()` — it receives `{ input, ctx }` and returns a value.
- The HTTP method is always `POST` for mutations, regardless of whether the operation is a create, update, or delete.
- Mutations are not cached by TanStack Query. Each call executes the resolver directly.

---

### Resolver Arguments

Identical in structure to query resolvers:

| Property | Type | Description |
|---|---|---|
| `input` | Inferred from `.input()` schema | Validated and typed input value |
| `ctx` | Your `Context` type | Value returned by `createContext` |
| `type` | `'mutation'` | Procedure type identifier |
| `path` | `string` | Full procedure path (e.g. `user.create`) |
| `rawInput` | `unknown` | Input before validation |

---

### Common Mutation Patterns

#### Create

```ts
create: publicProcedure
  .input(z.object({
    title: z.string().min(1).max(255),
    body: z.string(),
    authorId: z.string().uuid(),
  }))
  .mutation(async ({ input, ctx }) => {
    const post = await ctx.db.post.create({
      data: input,
    });
    return post;
  }),
```

#### Update

```ts
update: publicProcedure
  .input(z.object({
    id: z.string().uuid(),
    title: z.string().min(1).max(255).optional(),
    body: z.string().optional(),
  }))
  .mutation(async ({ input, ctx }) => {
    const { id, ...data } = input;

    const post = await ctx.db.post.update({
      where: { id },
      data,
    });

    return post;
  }),
```

#### Delete

```ts
delete: publicProcedure
  .input(z.object({
    id: z.string().uuid(),
  }))
  .mutation(async ({ input, ctx }) => {
    await ctx.db.post.delete({
      where: { id: input.id },
    });

    return { deleted: true, id: input.id };
  }),
```

**Key Points**
- Returning a value from a delete mutation is optional but useful for the client to confirm which resource was removed.
- Partial update inputs use Zod's `.optional()` on individual fields rather than `.partial()` on the whole object, giving finer control over which fields are required vs. optional.

---

### Error Handling in Mutations

Throw `TRPCError` for expected failure cases:

```ts
import { TRPCError } from '@trpc/server';

update: publicProcedure
  .input(z.object({
    id: z.string().uuid(),
    title: z.string().min(1),
  }))
  .mutation(async ({ input, ctx }) => {
    const existing = await ctx.db.post.findUnique({
      where: { id: input.id },
    });

    if (!existing) {
      throw new TRPCError({
        code: 'NOT_FOUND',
        message: `Post ${input.id} does not exist`,
      });
    }

    if (existing.authorId !== ctx.user?.id) {
      throw new TRPCError({
        code: 'FORBIDDEN',
        message: 'You do not have permission to edit this post',
      });
    }

    return ctx.db.post.update({
      where: { id: input.id },
      data: { title: input.title },
    });
  }),
```

**Key Points**
- `TRPCError` codes map to HTTP status codes internally. `NOT_FOUND` → 404, `FORBIDDEN` → 403, `UNAUTHORIZED` → 401, `BAD_REQUEST` → 400, `INTERNAL_SERVER_ERROR` → 500.
- Errors thrown as plain `Error` instances (not `TRPCError`) are caught by tRPC and returned as `INTERNAL_SERVER_ERROR`. The original message may be suppressed in production depending on your error formatter. [Inference]
- The `cause` property on `TRPCError` can wrap the original error for server-side logging without exposing it to the client.

```ts
throw new TRPCError({
  code: 'INTERNAL_SERVER_ERROR',
  message: 'Something went wrong',
  cause: originalError,
});
```

---

### Calling Mutations on the Client

#### Basic Usage with `useMutation`

```tsx
import { trpc } from '../utils/trpc';

function CreatePostForm() {
  const createPost = trpc.post.create.useMutation();

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    createPost.mutate({
      title: 'My Post',
      body: 'Hello world',
      authorId: 'user-123',
    });
  }

  return (
    <form onSubmit={handleSubmit}>
      <button type="submit" disabled={createPost.isPending}>
        {createPost.isPending ? 'Creating…' : 'Create Post'}
      </button>
      {createPost.error && <p>{createPost.error.message}</p>}
    </form>
  );
}
```

**Key Points**
- `useMutation()` returns a mutation object. The mutation does not execute until `.mutate()` or `.mutateAsync()` is called.
- `isPending` (TanStack Query v5) or `isLoading` (TanStack Query v4) indicates the mutation is in flight. Check your installed version for the correct property name.
- `createPost.error` is typed as a `TRPCClientError`, giving access to `.message` and `.data` (which includes the error code).

---

### `mutate` vs `mutateAsync`

| Method | Returns | Error handling | Use case |
|---|---|---|---|
| `.mutate()` | `void` | Via `onError` callback or `.error` state | Fire-and-forget, form submissions |
| `.mutateAsync()` | `Promise<TOutput>` | Via `try/catch` | Sequential async logic, chaining mutations |

#### Using `mutateAsync`

```tsx
async function handleSubmit() {
  try {
    const post = await createPost.mutateAsync({
      title: 'My Post',
      body: 'Hello world',
      authorId: 'user-123',
    });
    console.log('Created post with id:', post.id);
    router.push(`/posts/${post.id}`);
  } catch (err) {
    console.error('Failed to create post:', err);
  }
}
```

**Key Points**
- `.mutateAsync()` re-throws errors, so unhandled rejections will surface as uncaught promise errors. Always wrap in `try/catch`.
- `.mutate()` does not throw — errors are surfaced through the `onError` callback or the `.error` state property.

---

### Mutation Callbacks

`useMutation` accepts callback options for lifecycle events:

```tsx
const createPost = trpc.post.create.useMutation({
  onSuccess(data) {
    console.log('Post created:', data.id);
  },
  onError(error) {
    console.error('Error code:', error.data?.code);
    console.error('Message:', error.message);
  },
  onSettled() {
    // runs after success or error
  },
});
```

Callbacks can also be passed per-invocation to `.mutate()`:

```tsx
createPost.mutate(
  { title: 'My Post', body: '…', authorId: '…' },
  {
    onSuccess(data) {
      alert(`Created: ${data.id}`);
    },
    onError(error) {
      alert(`Failed: ${error.message}`);
    },
  },
);
```

**Key Points**
- Per-invocation callbacks run in addition to, not instead of, the callbacks declared in `useMutation`. [Inference] Both sets of callbacks fire for the same mutation event; order may vary depending on TanStack Query's internal execution order.
- `error.data?.code` contains the tRPC error code string (e.g. `'NOT_FOUND'`, `'FORBIDDEN'`).

---

### Invalidating Queries After Mutation

A common pattern is to invalidate related queries after a successful mutation so TanStack Query refetches fresh data.

```tsx
import { trpc } from '../utils/trpc';
import { useQueryClient } from '@tanstack/react-query';
import { getQueryKey } from '@trpc/react-query';

function CreatePost() {
  const queryClient = useQueryClient();
  const postListKey = getQueryKey(trpc.post.getAll, undefined, 'query');

  const createPost = trpc.post.create.useMutation({
    onSuccess() {
      queryClient.invalidateQueries({ queryKey: postListKey });
    },
  });

  return (
    <button onClick={() =>
      createPost.mutate({ title: 'New', body: '…', authorId: '…' })
    }>
      Create
    </button>
  );
}
```

**Key Points**
- `getQueryKey` from `@trpc/react-query` produces the TanStack Query cache key for a given tRPC procedure. Using this is safer than constructing the key manually, as the internal key format is an implementation detail. [Inference]
- `invalidateQueries` marks the matching cached query as stale, causing it to refetch the next time it is observed by a mounted component.
- Alternatively, `queryClient.setQueryData` can be used to optimistically update the cache without a network refetch.

---

### Optimistic Updates

For a responsive UI, you can update the cache immediately before the server confirms the mutation:

```tsx
const utils = trpc.useUtils();

const createPost = trpc.post.create.useMutation({
  async onMutate(newPost) {
    // Cancel any in-flight refetches
    await utils.post.getAll.cancel();

    // Snapshot current cache value
    const previous = utils.post.getAll.getData();

    // Optimistically update the cache
    utils.post.getAll.setData(undefined, (old) => [
      ...(old ?? []),
      { id: 'temp-id', ...newPost },
    ]);

    return { previous };
  },
  onError(_err, _newPost, context) {
    // Roll back on error
    if (context?.previous) {
      utils.post.getAll.setData(undefined, context.previous);
    }
  },
  onSettled() {
    // Always refetch to sync with server state
    utils.post.getAll.invalidate();
  },
});
```

**Key Points**
- `trpc.useUtils()` provides typed access to the TanStack Query cache for tRPC procedures.
- `onMutate` returns context (here `{ previous }`) which is passed to `onError` and `onSettled` as the third argument.
- Rolling back in `onError` restores the snapshot captured in `onMutate`, undoing the optimistic update.
- Calling `invalidate()` in `onSettled` ensures the cache is eventually consistent with the server regardless of whether the mutation succeeded or failed.

---

### Using the Vanilla Client

```ts
import { client } from '../utils/client';

const post = await client.post.create.mutate({
  title: 'My Post',
  body: 'Hello world',
  authorId: 'user-123',
});

console.log(post.id);
```

**Key Points**
- The vanilla client's `.mutate()` always returns a `Promise`. `await` it directly or chain `.then()`.
- There are no loading states or cache management — those are features of TanStack Query.

---

### Common Errors

| Error Code | Cause | Resolution |
|---|---|---|
| `BAD_REQUEST` | Input failed Zod validation | Verify input shape matches the schema |
| `FORBIDDEN` | Caller lacks permission for the operation | Check auth logic in resolver or middleware |
| `NOT_FOUND` | Target resource does not exist | Verify resource existence before mutating |
| `CONFLICT` | Duplicate or conflicting resource | Handle uniqueness constraints from the database |
| `INTERNAL_SERVER_ERROR` | Unhandled exception in resolver | Inspect server logs; wrap DB calls in try/catch |