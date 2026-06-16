## Pagination Patterns in tRPC

---

### Overview

Pagination is the practice of splitting large datasets into smaller, manageable chunks delivered across multiple requests. In tRPC, pagination is implemented through typed procedures — typically queries — that accept pagination parameters and return sliced data along with metadata needed for the client to request subsequent pages.

tRPC does not ship a built-in pagination abstraction. Pagination logic lives in your procedure handlers, typically delegated to your database layer (e.g., Prisma, Drizzle, Kysely).

---

### Common Pagination Strategies

There are three primary strategies used in practice:

---

#### Offset-Based Pagination

The client specifies a `skip` (offset) and `take` (limit) value. The server slices the dataset accordingly.

**How it works:**

- `skip`: number of records to skip from the beginning
- `take`: number of records to return

```ts
// server/routers/post.ts
import { z } from 'zod';
import { publicProcedure, router } from '../trpc';
import { db } from '../db';

export const postRouter = router({
  list: publicProcedure
    .input(
      z.object({
        skip: z.number().int().min(0).default(0),
        take: z.number().int().min(1).max(100).default(10),
      })
    )
    .query(async ({ input }) => {
      const { skip, take } = input;

      const [items, total] = await Promise.all([
        db.post.findMany({ skip, take, orderBy: { createdAt: 'desc' } }),
        db.post.count(),
      ]);

      return {
        items,
        total,
        skip,
        take,
      };
    }),
});
```

**Client usage:**

```ts
const { data } = trpc.post.list.useQuery({ skip: 0, take: 10 });
```

**Key Points:**

- Simple to implement and reason about
- Supports random access (jump to any page)
- Prone to **page drift**: if records are inserted or deleted between requests, items may be skipped or duplicated
- Performance degrades at large offsets in most SQL databases — the engine still scans skipped rows

---

#### Cursor-Based Pagination

The server returns an opaque cursor (typically the last record's unique ID or timestamp) alongside results. The client passes this cursor in the next request to continue from that point.

**How it works:**

- `cursor`: the ID (or other unique field) of the last item received
- `limit`: number of items to return

```ts
// server/routers/post.ts
export const postRouter = router({
  list: publicProcedure
    .input(
      z.object({
        cursor: z.string().optional(), // ID of last item from previous page
        limit: z.number().int().min(1).max(100).default(10),
      })
    )
    .query(async ({ input }) => {
      const { cursor, limit } = input;

      const items = await db.post.findMany({
        take: limit + 1, // fetch one extra to determine if next page exists
        cursor: cursor ? { id: cursor } : undefined,
        skip: cursor ? 1 : 0, // skip the cursor item itself
        orderBy: { createdAt: 'desc' },
      });

      let nextCursor: string | undefined;

      if (items.length > limit) {
        const nextItem = items.pop(); // remove the extra item
        nextCursor = nextItem?.id;
      }

      return {
        items,
        nextCursor,
      };
    }),
});
```

**Client usage:**

```ts
const { data } = trpc.post.list.useQuery({
  cursor: undefined,
  limit: 10,
});

// To fetch next page:
const { data: nextPage } = trpc.post.list.useQuery({
  cursor: data?.nextCursor,
  limit: 10,
});
```

**Key Points:**

- Stable — immune to page drift from concurrent inserts/deletes
- More efficient at scale; database seeks directly to the cursor position
- Does not support random page access
- Cursor must point to a field that is indexed and has a stable, unique sort order

---

#### Infinite Scroll with `useInfiniteQuery`

tRPC's React Query integration exposes `useInfiniteQuery`, which is the idiomatic client-side pattern for cursor-based infinite scroll.

The procedure must be configured to accept a `cursor` input. tRPC automatically passes the cursor returned by `getNextPageParam` into the next query call.

**Procedure (same cursor-based procedure as above).**

**Client setup:**

```ts
// components/PostFeed.tsx
import { trpc } from '../utils/trpc';

export function PostFeed() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = trpc.post.list.useInfiniteQuery(
    { limit: 10 },
    {
      getNextPageParam: (lastPage) => lastPage.nextCursor,
    }
  );

  const posts = data?.pages.flatMap((page) => page.items) ?? [];

  return (
    <div>
      {posts.map((post) => (
        <div key={post.id}>{post.title}</div>
      ))}
      {hasNextPage && (
        <button onClick={() => fetchNextPage()} disabled={isFetchingNextPage}>
          {isFetchingNextPage ? 'Loading...' : 'Load more'}
        </button>
      )}
    </div>
  );
}
```

**Key Points:**

- `data.pages` is an array of individual page responses
- `.flatMap` merges all pages into a flat list
- `getNextPageParam` receives the last page's response and must return the next cursor, or `undefined`/`null` to signal the end
- React Query accumulates pages in cache — previously fetched pages remain available without re-fetching [Inference: based on React Query's standard behavior; actual caching behavior depends on configuration]

---

### Visualizing the Cursor Flow

DatabasetRPC ServerClientDatabasetRPC ServerClientlist({ limit: 10, cursor: undefined })findMany({ take: 11, cursor: none })[item1 ... item11]{ items: [item1..item10], nextCursor: "item10.id" }list({ limit: 10, cursor: "item10.id" })findMany({ take: 11, cursor: item10 })[item11 ... item21]{ items: [item11..item20], nextCursor: "item20.id" }

---

### Comparison of Strategies

| Feature | Offset-Based | Cursor-Based |
| --- | --- | --- |
| Random page access | ✅ Yes | ❌ No |
| Stable under mutations | ❌ No | ✅ Yes |
| DB performance at scale | ❌ Degrades | ✅ Consistent |
| Complexity | Low | Medium |
| `useInfiniteQuery` compatible | ⚠️ Possible but awkward | ✅ Natural fit |

---

### Input Validation Considerations

Always validate pagination inputs on the server using Zod:

```ts
z.object({
  cursor: z.string().cuid().optional(),   // constrain cursor format
  limit: z.number().int().min(1).max(100), // cap maximum page size
})
```

**Key Points:**

- Capping `limit` prevents clients from requesting unbounded result sets
- Validating cursor format reduces the risk of injection or malformed queries [Inference: actual security posture depends on your database driver and ORM behavior]
- Always set a sensible default for `limit` using `.default()`

---

### Returning Pagination Metadata

Depending on the UI requirements, you may want to return additional metadata:

```ts
return {
  items,
  nextCursor,
  meta: {
    fetchedAt: new Date().toISOString(),
    count: items.length,
  },
};
```

For offset-based pagination supporting a traditional page UI:

```ts
return {
  items,
  total,
  page: Math.floor(skip / take) + 1,
  pageCount: Math.ceil(total / take),
  hasNext: skip + take < total,
  hasPrev: skip > 0,
};
```

---

### Sorting and Pagination Consistency

For cursor-based pagination to work correctly, the sort order must be:

1. **Stable** — the same query must return results in the same order every time
2. **Unique** — no two rows should have identical sort values, or the cursor may be ambiguous

If sorting by a non-unique field (e.g., `createdAt`), add a tiebreaker:

```ts
orderBy: [
  { createdAt: 'desc' },
  { id: 'desc' }, // tiebreaker — ensures stable, unique ordering
],
```

---

### Common Pitfalls

**Pitfall 1 — Off-by-one in cursor queries:**
Fetching `limit + 1` and then checking length is the standard pattern. Forgetting to `pop()` the extra item means the client receives one more record than expected.

**Pitfall 2 — Missing index on cursor field:**
If the cursor field is not indexed, cursor-based pagination may perform a full table scan. Always verify indexes are in place for fields used in `cursor` and `orderBy`. [Inference: applies to most relational databases; behavior varies by database engine]

**Pitfall 3 — Encoding cursors as opaque tokens:**
For public APIs, exposing raw IDs as cursors leaks database internals. An alternative is to base64-encode the cursor value:

```ts
// Encode
const nextCursor = Buffer.from(nextItem.id).toString('base64');

// Decode on receipt
const decodedCursor = Buffer.from(cursor, 'base64').toString('utf-8');
```

This is a convention, not a security measure. [Inference: base64 is trivially reversible; do not treat it as encryption]

---

**Conclusion**

Cursor-based pagination is generally the more robust choice for production systems, particularly with `useInfiniteQuery` for infinite scroll UIs. Offset-based pagination remains appropriate when random page access is a hard requirement. Both strategies are implemented at the procedure handler level in tRPC, with Zod handling input validation and your ORM or query builder handling the database logic.