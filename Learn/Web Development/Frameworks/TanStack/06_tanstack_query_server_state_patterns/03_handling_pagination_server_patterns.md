## TanStack Query — Cache Management — Handling Pagination Server Patterns

---

### What Pagination Handling Involves

Pagination is not a single pattern — it is a family of related server designs, each with different data shapes, different navigation models, and different implications for how TanStack Query caches and fetches data. Choosing the right TanStack Query primitive depends on which server pattern is in use.

**Key Points:**
- The server dictates the pagination contract; the client adapts to it
- TanStack Query provides `useQuery` for simple page fetching and `useInfiniteQuery` for accumulating pages
- Cache behavior differs significantly between offset-based, cursor-based, and page-token patterns
- Understanding the cache structure for each pattern prevents common consistency and UX bugs

---

### Taxonomy of Server Pagination Patterns

| Pattern | Navigation Model | Server Parameter | Typical Response Shape |
|---|---|---|---|
| Offset / Limit | Jump to any page | `offset`, `limit` | `{ data, total }` |
| Page / Per-page | Jump to any page | `page`, `perPage` | `{ data, totalPages }` |
| Cursor-based | Forward only (sometimes backward) | `cursor` | `{ data, nextCursor }` |
| Page token | Forward only | `pageToken` | `{ data, nextPageToken }` |
| Keyset | Forward / backward | `after`, `before` | `{ data, hasNextPage }` |
| Relay-style | Forward / backward | `first`, `after` | `{ edges, pageInfo }` |

---

### Pattern 1 — Offset / Limit and Page Number

#### Server contract

```
GET /posts?offset=20&limit=10
GET /posts?page=3&perPage=10
```

Response:
```json
{
  "data": [ /* 10 items */ ],
  "total": 84,
  "page": 3,
  "totalPages": 9
}
```

#### Cache structure

Each page is a separate cache entry, keyed by the pagination parameters.

```ts
useQuery({
  queryKey: ['posts', { page, perPage }],
  queryFn: () => fetchPosts({ page, perPage }),
})
```

Cache entries:
```
['posts', { page: 1, perPage: 10 }]  →  { data: [...], total: 84 }
['posts', { page: 2, perPage: 10 }]  →  { data: [...], total: 84 }
['posts', { page: 3, perPage: 10 }]  →  { data: [...], total: 84 }
```

Each page is independently cached, independently stale, and independently refetchable.

#### Full implementation

```ts
function PostList() {
  const [page, setPage] = useState(1)
  const perPage = 10

  const { data, isPending, isPlaceholderData } = useQuery({
    queryKey: ['posts', { page, perPage }],
    queryFn: () => fetchPosts({ page, perPage }),
    placeholderData: keepPreviousData,
  })

  const totalPages = data ? Math.ceil(data.total / perPage) : 0

  return (
    <>
      <PostGrid posts={data?.data} />
      <Pagination
        page={page}
        totalPages={totalPages}
        onNext={() => setPage(p => p + 1)}
        onPrev={() => setPage(p => p - 1)}
        disabled={isPlaceholderData}
      />
    </>
  )
}
```

**Key Points:**
- `keepPreviousData` (imported from `@tanstack/react-query`) retains the previous page's data while the next page loads, preventing layout flash
- `isPlaceholderData` is `true` while showing previous data — useful for disabling navigation controls during fetch
- Without `keepPreviousData`, the UI shows a loading state on every page change

#### Prefetching the next page

```ts
const queryClient = useQueryClient()

useEffect(() => {
  if (page < totalPages) {
    queryClient.prefetchQuery({
      queryKey: ['posts', { page: page + 1, perPage }],
      queryFn: () => fetchPosts({ page: page + 1, perPage }),
    })
  }
}, [page, totalPages])
```

**Key Points:**
- Prefetching populates the cache before the user navigates
- The next page loads instantly from cache when navigated to
- [Inference] Prefetch respects `staleTime` — if the entry is already fresh, no network request is made

---

### Pattern 2 — Cursor-Based Pagination

#### Server contract

The server returns a cursor (opaque token or ID) pointing to the position after the last returned item. The client sends this cursor to fetch the next page.

```
GET /posts?limit=10
→ { data: [...], nextCursor: "eyJpZCI6MTB9" }

GET /posts?cursor=eyJpZCI6MTB9&limit=10
→ { data: [...], nextCursor: "eyJpZCI6MjB9" }
```

#### Why cursor differs from offset

Cursor-based pagination is **position-stable**. If an item is inserted at the top of the list between page fetches, offset pagination shifts every subsequent page. A cursor encodes a specific position in the dataset and is not affected by insertions before it.

This makes cursor pagination the natural fit for `useInfiniteQuery`, which accumulates pages sequentially.

#### `useInfiniteQuery` structure

```ts
const {
  data,
  fetchNextPage,
  fetchPreviousPage,
  hasNextPage,
  hasPreviousPage,
  isFetchingNextPage,
  isFetchingPreviousPage,
  isPending,
} = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts({ cursor: pageParam, limit: 10 }),
  initialPageParam: undefined,
  getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
  getPreviousPageParam: (firstPage) => firstPage.previousCursor ?? undefined,
})
```

**Key Points:**
- `pageParam` is injected into `queryFn` automatically by TanStack Query
- `initialPageParam` is the value used for the very first fetch (often `undefined` or `null`)
- `getNextPageParam` receives the last fetched page and returns the next cursor, or `undefined` to signal no more pages
- `hasNextPage` is `true` when `getNextPageParam` returns a non-undefined value
- All pages are stored under a single cache key, accumulated in `data.pages`

#### Cache structure for infinite queries

```
['posts'] → {
  pages: [
    { data: [/* items 1–10 */], nextCursor: 'cursor_A' },
    { data: [/* items 11–20 */], nextCursor: 'cursor_B' },
    { data: [/* items 21–30 */], nextCursor: undefined },
  ],
  pageParams: [undefined, 'cursor_A', 'cursor_B']
}
```

All pages accumulate under one cache key. This is fundamentally different from offset pagination, where each page is a separate cache entry.

#### Rendering accumulated results

```ts
// data.pages is an array of page responses
const allPosts = data?.pages.flatMap(page => page.data) ?? []

return (
  <>
    <PostList posts={allPosts} />
    <button
      onClick={() => fetchNextPage()}
      disabled={!hasNextPage || isFetchingNextPage}
    >
      {isFetchingNextPage ? 'Loading...' : 'Load more'}
    </button>
  </>
)
```

---

### Pattern 3 — Page Token (Google-style)

Functionally similar to cursor-based but uses an opaque `pageToken` string rather than a derived cursor. Common in Google APIs and similar REST designs.

```
GET /items
→ { items: [...], nextPageToken: "CAE" }

GET /items?pageToken=CAE
→ { items: [...], nextPageToken: "CAM" }
```

```ts
useInfiniteQuery({
  queryKey: ['items'],
  queryFn: ({ pageParam }) =>
    fetchItems({ pageToken: pageParam }),
  initialPageParam: undefined,
  getNextPageParam: (lastPage) => lastPage.nextPageToken ?? undefined,
})
```

The implementation is identical to cursor-based. The distinction is semantic — the token is fully opaque and carries no decodable position information.

---

### Pattern 4 — Keyset / Seek Pagination

Keyset pagination uses actual field values (typically `id`, `createdAt`, or a composite) as the boundary marker rather than an opaque token.

```
GET /posts?after=150&limit=10
→ { data: [...], hasNextPage: true }
```

```ts
useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) =>
    fetchPosts({ after: pageParam, limit: 10 }),
  initialPageParam: undefined,
  getNextPageParam: (lastPage) => {
    if (!lastPage.hasNextPage) return undefined
    return lastPage.data.at(-1)?.id  // use last item's ID as next boundary
  },
})
```

**Key Points:**
- The `pageParam` here is a real entity ID, not an opaque string
- Requires the server to support `after=<id>` semantics
- More transparent than opaque cursors but couples the client to the server's ID type

---

### Pattern 5 — Relay-Style Pagination

Relay pagination is a GraphQL convention. Responses include a `pageInfo` object and `edges` wrapper.

```json
{
  "edges": [
    { "cursor": "abc", "node": { "id": 1, "title": "Hello" } }
  ],
  "pageInfo": {
    "hasNextPage": true,
    "hasPreviousPage": false,
    "startCursor": "abc",
    "endCursor": "xyz"
  }
}
```

```ts
useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) =>
    fetchPostsRelay({ after: pageParam, first: 10 }),
  initialPageParam: undefined,
  getNextPageParam: (lastPage) =>
    lastPage.pageInfo.hasNextPage
      ? lastPage.pageInfo.endCursor
      : undefined,
  getPreviousPageParam: (firstPage) =>
    firstPage.pageInfo.hasPreviousPage
      ? firstPage.pageInfo.startCursor
      : undefined,
})
```

---

### Bidirectional Infinite Scroll

Some interfaces (chat history, document timelines) require loading in both directions from an anchor point.

```ts
useInfiniteQuery({
  queryKey: ['messages', channelId],
  queryFn: ({ pageParam }) =>
    fetchMessages({ channelId, cursor: pageParam, limit: 20 }),
  initialPageParam: latestMessageCursor,
  getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
  getPreviousPageParam: (firstPage) => firstPage.previousCursor ?? undefined,
})
```

```ts
// In the component
<button onClick={() => fetchPreviousPage()} disabled={!hasPreviousPage}>
  Load earlier
</button>

{/* messages list */}

<button onClick={() => fetchNextPage()} disabled={!hasNextPage}>
  Load newer
</button>
```

**Key Points:**
- `fetchPreviousPage` prepends to `data.pages`; `fetchNextPage` appends
- `initialPageParam` can be set to a known anchor (e.g., last-read message cursor)
- [Inference] Managing scroll position during prepend requires manual DOM handling; TanStack Query does not control scroll behavior

---

### `maxPages` — Bounding the Page Window

For infinite scroll with very large datasets, accumulating all pages in memory is impractical. The `maxPages` option limits how many pages are retained.

```ts
useInfiniteQuery({
  queryKey: ['feed'],
  queryFn: ({ pageParam }) => fetchFeed({ cursor: pageParam }),
  initialPageParam: undefined,
  getNextPageParam: (lastPage) => lastPage.nextCursor,
  maxPages: 5,
})
```

**Key Points:**
- When `maxPages: 5` is set and a 6th page is fetched, the oldest page is dropped from `data.pages`
- [Inference] Dropped pages are removed from memory but the query key structure remains; behavior during refetch of a windowed set should be verified against the version in use
- Useful for virtualized lists where only a window of data is rendered

---

### Refetch Behavior for Infinite Queries

When an infinite query is refetched (due to window focus, `invalidateQueries`, or manual trigger), TanStack Query [Inference] refetches **all currently accumulated pages** in sequence, not just the first page. This preserves the full accumulated state.

```ts
// Invalidating refetches all pages in the infinite query
queryClient.invalidateQueries({ queryKey: ['posts'] })
```

This means a user who has scrolled through 10 pages will trigger 10 sequential requests on refetch. Consider this when choosing `staleTime` for infinite queries — longer `staleTime` reduces unnecessary refetch cost.

```ts
useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts({ cursor: pageParam }),
  initialPageParam: undefined,
  getNextPageParam: (lastPage) => lastPage.nextCursor,
  staleTime: 5 * 60 * 1000, // reduce background refetch frequency
})
```

---

### Choosing Between `useQuery` and `useInfiniteQuery`

| Consideration | `useQuery` | `useInfiniteQuery` |
|---|---|---|
| Navigation model | Jump to any page | Sequential / append only |
| Cache structure | One entry per page | All pages under one key |
| Data accumulation | No — each page replaces | Yes — pages accumulate |
| Prefetching | Easy per-page | Complex (must fetch in order) |
| Invalidation | Per-page granularity | All-or-nothing for the key |
| Suitable for | Traditional pagination UI | Infinite scroll, load more |

---

### Common Mistakes

**Using `useInfiniteQuery` for jump-to-page navigation.**
Infinite query accumulates pages sequentially. Jumping to page 7 directly is not supported without fetching pages 1–6 first. Use `useQuery` with a page parameter for random access.

**Not including pagination params in the query key.**
```ts
// ❌ All pages share one cache entry — they overwrite each other
useQuery({ queryKey: ['posts'], queryFn: () => fetchPosts({ page }) })

// ✅ Each page is a distinct cache entry
useQuery({ queryKey: ['posts', { page }], queryFn: () => fetchPosts({ page }) })
```

**Assuming `total` is stable across pages.**
In high-traffic datasets, `total` returned on page 1 may differ from `total` on page 3 if items were inserted or deleted between requests. Treat `total` as an approximation for display purposes only.

**Forgetting `keepPreviousData` on offset pagination.**
Without it, every page change shows a loading spinner, making the UI feel unstable.

---

### Summary

```
Server pattern          TanStack Query primitive     Cache structure
─────────────────────   ──────────────────────────   ──────────────────────────
Offset / page number    useQuery + page in key       One entry per page
Cursor / token          useInfiniteQuery             All pages under one key
Keyset                  useInfiniteQuery             All pages under one key
Relay (GraphQL)         useInfiniteQuery             All pages under one key
Bidirectional           useInfiniteQuery (both dirs) All pages under one key
```

---

**Conclusion:**
Pagination in TanStack Query is not a single API — it is a set of tools matched to server contract shapes. Offset and page-number patterns map to `useQuery` with the page in the query key, each page independently cached. Cursor, token, keyset, and Relay patterns map to `useInfiniteQuery`, with all pages accumulated under a single key. Getting the mapping right determines cache coherence, refetch cost, and the quality of the user's navigation experience.