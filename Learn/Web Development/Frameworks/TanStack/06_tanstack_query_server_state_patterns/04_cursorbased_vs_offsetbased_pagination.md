## TanStack Query — Cache Management — Cursor-Based vs Offset-Based Pagination

---

### Why the Distinction Matters

Cursor-based and offset-based pagination are not stylistic variations of the same idea — they reflect fundamentally different assumptions about how a dataset is traversed, how stable that dataset is during traversal, and what guarantees the server can make about result consistency. These differences propagate directly into how TanStack Query caches results, how refetches behave, and which primitive (`useQuery` vs `useInfiniteQuery`) is appropriate.

---

### Conceptual Model

#### Offset-based

The client tells the server: **skip N rows, return M rows**.

```
Dataset:  [A][B][C][D][E][F][G][H][I][J]
                         ↑
          offset=4, limit=3 → [E][F][G]
```

The server computes position arithmetically. There is no persistent state on the server between requests. Any request can target any position directly.

#### Cursor-based

The client tells the server: **start from this position marker, return M rows**.

```
Dataset:  [A][B][C][D][E][F][G][H][I][J]
                   ↑
          cursor points here → [D][E][F]
          response includes nextCursor pointing after [F]
```

The cursor encodes a position in the dataset — often an ID, a timestamp, or an opaque token. The server resolves the cursor to find the starting point. The client has no knowledge of the cursor's internal meaning.

---

### The Consistency Problem With Offset Pagination

Offset pagination assumes the dataset is **static between page requests**. When it is not, pages shift.

**Scenario: item inserted at the top between page 1 and page 2 fetch**

```
Initial dataset:    [A][B][C][D][E][F][G][H]

Page 1 fetch:       offset=0, limit=4 → [A][B][C][D]

New item X inserted at position 0:
Updated dataset:    [X][A][B][C][D][E][F][G][H]

Page 2 fetch:       offset=4, limit=4 → [D][E][F][G]
                                          ↑
                              D already shown on page 1
```

The user sees `D` duplicated. If an item is deleted between fetches, an item is silently skipped.

**Cursor-based avoids this:**

```
Page 1 fetch:  cursor=start, limit=4 → [A][B][C][D], nextCursor=after_D

New item X inserted at position 0:
Updated dataset: [X][A][B][C][D][E][F][G][H]

Page 2 fetch:  cursor=after_D, limit=4 → [E][F][G][H]
                                           ↑
                               Correctly continues from D
```

The cursor encodes a stable position. Insertions before that position do not affect subsequent pages.

---

### Server Implementation Comparison

#### Offset — SQL example

```sql
-- offset=20, limit=10
SELECT * FROM posts
ORDER BY created_at DESC
LIMIT 10 OFFSET 20;
```

Simple. Any database supports this natively. Performance degrades at large offsets because the database must scan and discard the skipped rows.

#### Cursor — SQL keyset example

```sql
-- cursor encodes: created_at < '2024-03-01' AND id < 150
SELECT * FROM posts
WHERE (created_at, id) < ('2024-03-01', 150)
ORDER BY created_at DESC, id DESC
LIMIT 10;
```

Requires an index on the cursor fields. Performance is stable regardless of dataset depth — the database seeks directly to the cursor position without scanning skipped rows.

---

### Performance Characteristics

| Dimension | Offset | Cursor |
|---|---|---|
| Page 1 cost | Low | Low |
| Page N cost (large N) | High — full scan to offset | Stable — index seek |
| Random access | Supported | Not supported |
| Server-side state | None | None (cursor is client-held) |
| Index requirement | Simple (ORDER BY col) | Composite index on cursor fields |
| Implementation complexity | Low | Medium–High |

[Inference] Performance characteristics described above reflect common relational database behavior. Actual query performance depends on database engine, indexing strategy, dataset size, and server implementation.

---

### Navigation Model Implications

This is the most direct consequence for TanStack Query API selection.

| Capability | Offset | Cursor |
|---|---|---|
| Jump to page 7 directly | ✅ Yes | ❌ No |
| Previous / next | ✅ Yes | ✅ Yes (if server supports) |
| Infinite scroll / load more | Possible but fragile | Natural fit |
| Total page count | ✅ Server can provide | ❌ Often unavailable |
| Bookmark a page URL | ✅ (`?page=3`) | ❌ Cursor is transient |

Cursor-based pagination cannot support random access because reaching page 7 requires knowing the cursor at the end of page 6, which requires fetching pages 1–6 in sequence. There is no arithmetic shortcut.

---

### TanStack Query API Mapping

The navigation model difference maps directly to which TanStack Query primitive fits each pattern.

```
Offset / page number
  └── useQuery
        └── page in query key → one cache entry per page
              └── supports keepPreviousData, prefetch, direct navigation

Cursor-based
  └── useInfiniteQuery
        └── all pages under one key → pages accumulate
              └── supports fetchNextPage, fetchPreviousPage, maxPages
```

Using `useInfiniteQuery` for offset pagination or `useQuery` for cursor-based pagination is not impossible, but works against the design of each primitive.

---

### `useQuery` for Offset Pagination — Full Pattern

```ts
import { useQuery, keepPreviousData, useQueryClient } from '@tanstack/react-query'

function PostList() {
  const [page, setPage] = useState(1)
  const perPage = 10
  const queryClient = useQueryClient()

  const { data, isPending, isPlaceholderData } = useQuery({
    queryKey: ['posts', { page, perPage }],
    queryFn: () => fetchPosts({ page, perPage }),
    placeholderData: keepPreviousData,
    staleTime: 30_000,
  })

  // Prefetch next page
  useEffect(() => {
    const totalPages = data ? Math.ceil(data.total / perPage) : 0
    if (page < totalPages) {
      queryClient.prefetchQuery({
        queryKey: ['posts', { page: page + 1, perPage }],
        queryFn: () => fetchPosts({ page: page + 1, perPage }),
      })
    }
  }, [page, data])

  return (
    <>
      <PostGrid
        posts={data?.data}
        faded={isPlaceholderData}
      />
      <PaginationControls
        page={page}
        totalPages={data ? Math.ceil(data.total / perPage) : 0}
        onPrev={() => setPage(p => p - 1)}
        onNext={() => setPage(p => p + 1)}
        disabled={isPlaceholderData}
      />
    </>
  )
}
```

**Key Points:**
- Each page is a fully independent cache entry
- `keepPreviousData` prevents the UI from blanking between pages
- Prefetching makes the next page feel instant
- `total` from the API drives page count calculation — treat as approximate in live datasets

---

### `useInfiniteQuery` for Cursor Pagination — Full Pattern

```ts
import { useInfiniteQuery } from '@tanstack/react-query'

function PostFeed() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isPending,
  } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: ({ pageParam }) =>
      fetchPosts({ cursor: pageParam, limit: 10 }),
    initialPageParam: undefined,
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
    staleTime: 60_000,
  })

  const posts = data?.pages.flatMap(page => page.data) ?? []

  if (isPending) return <Spinner />

  return (
    <>
      <PostList posts={posts} />
      <button
        onClick={() => fetchNextPage()}
        disabled={!hasNextPage || isFetchingNextPage}
      >
        {isFetchingNextPage
          ? 'Loading more...'
          : hasNextPage
            ? 'Load more'
            : 'No more posts'}
      </button>
    </>
  )
}
```

**Key Points:**
- `initialPageParam: undefined` causes the first fetch to receive `pageParam = undefined` — the API must handle this as "start from beginning"
- `getNextPageParam` receives the most recently fetched page and extracts the cursor for the next request
- Returning `undefined` from `getNextPageParam` sets `hasNextPage` to `false`
- All pages live under `['posts']` — a single cache entry

---

### Cache Structure Side-by-Side

**Offset — after navigating to page 3:**

```
Cache
├── ['posts', { page: 1, perPage: 10 }]  →  { data: [...10 items], total: 84 }
├── ['posts', { page: 2, perPage: 10 }]  →  { data: [...10 items], total: 84 }
└── ['posts', { page: 3, perPage: 10 }]  →  { data: [...10 items], total: 84 }
```

Each entry is independent. Page 1 can be stale while page 3 is fresh. Page 2 can be garbage collected independently.

**Cursor — after fetching 3 pages:**

```
Cache
└── ['posts']  →  {
      pages: [
        { data: [...10 items], nextCursor: 'cursor_A' },
        { data: [...10 items], nextCursor: 'cursor_B' },
        { data: [...10 items], nextCursor: undefined },
      ],
      pageParams: [undefined, 'cursor_A', 'cursor_B']
    }
```

All pages are a single cache entry. Invalidating `['posts']` invalidates the entire accumulated set. There is no per-page granularity.

---

### Invalidation Behavior Comparison

<svg viewBox="0 0 700 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="700" height="340" fill="#0f1117" rx="12"/>
  <text x="350" y="30" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Cache Invalidation Scope</text>

  <!-- LEFT: Offset -->
  <text x="175" y="58" text-anchor="middle" fill="#94a3b8" font-size="12">Offset — useQuery</text>
  <rect x="30" y="68" width="290" height="240" rx="8" fill="#0f172a" stroke="#334155" stroke-width="1.5"/>

  <rect x="46" y="84" width="258" height="40" rx="6" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="175" y="100" text-anchor="middle" fill="#86efac" font-size="11">page 1 cache entry</text>
  <text x="175" y="116" text-anchor="middle" fill="#4ade80" font-size="10">✓ fresh</text>

  <rect x="46" y="132" width="258" height="40" rx="6" fill="#1e293b" stroke="#f59e0b" stroke-width="1.5"/>
  <text x="175" y="148" text-anchor="middle" fill="#fbbf24" font-size="11">page 2 cache entry</text>
  <text x="175" y="164" text-anchor="middle" fill="#f59e0b" font-size="10">⚠ stale — invalidated independently</text>

  <rect x="46" y="180" width="258" height="40" rx="6" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="175" y="196" text-anchor="middle" fill="#86efac" font-size="11">page 3 cache entry</text>
  <text x="175" y="212" text-anchor="middle" fill="#4ade80" font-size="10">✓ fresh</text>

  <rect x="46" y="240" width="258" height="52" rx="6" fill="#052e16" stroke="#4ade80" stroke-width="1" stroke-dasharray="4,3"/>
  <text x="175" y="260" text-anchor="middle" fill="#4ade80" font-size="11">Fine-grained invalidation:</text>
  <text x="175" y="276" text-anchor="middle" fill="#4ade80" font-size="10">invalidate only the page that changed</text>
  <text x="175" y="291" text-anchor="middle" fill="#4ade80" font-size="10">other pages remain cached</text>

  <!-- RIGHT: Cursor -->
  <text x="525" y="58" text-anchor="middle" fill="#94a3b8" font-size="12">Cursor — useInfiniteQuery</text>
  <rect x="380" y="68" width="290" height="240" rx="8" fill="#0f172a" stroke="#334155" stroke-width="1.5"/>

  <rect x="396" y="84" width="258" height="130" rx="6" fill="#1e293b" stroke="#f87171" stroke-width="1.5"/>
  <text x="525" y="102" text-anchor="middle" fill="#fca5a5" font-size="11">['posts'] — single cache entry</text>
  <text x="525" y="120" text-anchor="middle" fill="#94a3b8" font-size="10">pages[0] — cursor_A</text>
  <text x="525" y="136" text-anchor="middle" fill="#94a3b8" font-size="10">pages[1] — cursor_B</text>
  <text x="525" y="152" text-anchor="middle" fill="#94a3b8" font-size="10">pages[2] — cursor_C</text>
  <text x="525" y="172" text-anchor="middle" fill="#f87171" font-size="10">invalidating key = all pages invalidated</text>
  <text x="525" y="188" text-anchor="middle" fill="#f87171" font-size="10">refetch = all pages refetched in sequence</text>

  <rect x="396" y="240" width="258" height="52" rx="6" fill="#450a0a" stroke="#f87171" stroke-width="1" stroke-dasharray="4,3"/>
  <text x="525" y="260" text-anchor="middle" fill="#f87171" font-size="11">All-or-nothing invalidation:</text>
  <text x="525" y="276" text-anchor="middle" fill="#f87171" font-size="10">no per-page granularity</text>
  <text x="525" y="291" text-anchor="middle" fill="#f87171" font-size="10">refetch cost grows with page count</text>
</svg>

**Offset invalidation** can be surgical:

```ts
// Only invalidate the specific page that was mutated
queryClient.invalidateQueries({
  queryKey: ['posts', { page: 2, perPage: 10 }]
})
```

**Cursor invalidation** is all-or-nothing for the accumulated set:

```ts
// Invalidates all accumulated pages under this key
queryClient.invalidateQueries({ queryKey: ['posts'] })
// [Inference] TanStack Query refetches all pages in sequence on next mount/focus
```

---

### Refetch Cost at Scale

For `useInfiniteQuery`, a refetch re-requests every accumulated page. A user who has scrolled through 20 pages triggers 20 sequential requests on invalidation.

Mitigations:
- Use a longer `staleTime` to reduce automatic refetch frequency
- Use `maxPages` to cap the number of retained pages
- Accept that infinite scroll patterns are less suited to frequent mutation-driven invalidation

```ts
useInfiniteQuery({
  queryKey: ['feed'],
  queryFn: ({ pageParam }) => fetchFeed({ cursor: pageParam }),
  initialPageParam: undefined,
  getNextPageParam: (last) => last.nextCursor,
  staleTime: 5 * 60 * 1000,  // 5 minutes — reduce refetch frequency
  maxPages: 10,               // cap memory and refetch cost
})
```

---

### Hybrid Scenario — Offset With `useInfiniteQuery`

It is technically possible to use `useInfiniteQuery` with offset-based APIs to achieve a "load more" UX without cursor support from the server.

```ts
useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) =>
    fetchPosts({ offset: pageParam, limit: 10 }),
  initialPageParam: 0,
  getNextPageParam: (lastPage, allPages) => {
    const totalFetched = allPages.length * 10
    return totalFetched < lastPage.total ? totalFetched : undefined
  },
})
```

**Key Points:**
- This works, but inherits offset consistency problems — duplicates and skips are possible if the dataset mutates
- All accumulated pages live under one key, with the same invalidation cost as cursor-based
- [Inference] This is a pragmatic workaround for APIs that do not support cursors; it does not resolve the underlying consistency limitation of offset pagination

---

### Decision Guide

```
Does the server support cursors or opaque page tokens?
├── No
│   └── Use offset / page-number
│       ├── Need jump-to-page or URL-bookmarkable pages?
│       │   └── useQuery with page in query key
│       └── Need load-more / infinite scroll?
│           └── useInfiniteQuery with offset as pageParam (accept consistency tradeoff)
│
└── Yes
    ├── Need load-more / infinite scroll?
    │   └── useInfiniteQuery with cursor as pageParam
    ├── Need bidirectional scroll?
    │   └── useInfiniteQuery with getPreviousPageParam
    └── Need random access to any page?
        └── Cursor pagination cannot support this — reconsider API design
            or use offset alongside cursor for specific access patterns
```

---

### Summary Comparison

| Dimension | Offset / Page | Cursor |
|---|---|---|
| Consistency during mutations | Fragile — gaps and dupes possible | Stable — position-anchored |
| Random page access | ✅ | ❌ |
| Total count available | Usually | Rarely |
| URL bookmarkable | ✅ | ❌ (cursor is transient) |
| Server complexity | Low | Medium–High |
| DB performance at depth | Degrades | Stable |
| TanStack Query primitive | `useQuery` | `useInfiniteQuery` |
| Cache granularity | Per page | Entire accumulated set |
| Invalidation precision | Fine-grained | All-or-nothing |
| Refetch cost after scroll | Per-page only | All accumulated pages |

---

**Conclusion:**
Offset and cursor pagination differ in consistency guarantees, navigability, server cost, and cache structure — and these differences are not incidental. They determine which TanStack Query primitive fits, how invalidation behaves, and what tradeoffs are acceptable at scale. Offset pagination suits navigable, bookmarkable, page-jump interfaces where the dataset is relatively stable. Cursor pagination suits append-only feeds, infinite scroll, and high-write datasets where position stability matters more than random access. Matching the server pattern to the right TanStack Query primitive — and understanding the invalidation model that follows — is the foundation of correct pagination implementation.