## TanStack Query — Cache Management — Normalized vs Non-Normalized Cache

---

### What Is Cache Normalization?

Cache normalization is a strategy for storing fetched data where each unique entity is stored **exactly once**, in a flat structure keyed by identity, and all references to that entity point to the single canonical entry.

A **non-normalized cache** stores data in the shape it was received — nested, duplicated across query results, and keyed by the query that fetched it rather than by entity identity.

TanStack Query uses a **non-normalized cache** by default. Understanding both models — and their tradeoffs — is necessary for making informed architectural decisions.

---

### Non-Normalized Cache — How TanStack Query Stores Data

In TanStack Query, each query key maps to one cached value. That value is whatever the query function returned — stored as-is, with no transformation or deduplication by entity identity.

```ts
// Query 1 — fetches a list
useQuery({
  queryKey: ['posts'],
  queryFn: fetchAllPosts,
  // Cached value: [{ id: 1, title: 'Hello', author: { id: 42, name: 'Ada' } }, ...]
})

// Query 2 — fetches a single post
useQuery({
  queryKey: ['posts', 1],
  queryFn: () => fetchPost(1),
  // Cached value: { id: 1, title: 'Hello', author: { id: 42, name: 'Ada' } }
})
```

The post with `id: 1` exists in **two separate cache entries**. There is no relationship between them. If the post title changes on the server, one refetch updates only the entry that was refetched.

---

### Visualizing the Difference

**Non-normalized (TanStack Query default):**

```
Cache
├── ['posts']
│     └── [{ id:1, title:'Hello', author:{id:42,name:'Ada'} },
│           { id:2, title:'World', author:{id:42,name:'Ada'} }]
│
└── ['posts', 1]
      └── { id:1, title:'Hello', author:{id:42,name:'Ada'} }
```

Author `id: 42` appears three times. Post `id: 1` appears twice. Each is an independent copy.

---

**Normalized:**

```
Entity Store
├── Post:1  → { id:1, title:'Hello', author: → User:42 }
├── Post:2  → { id:2, title:'World', author: → User:42 }
└── User:42 → { id:42, name:'Ada' }

Query Index
├── ['posts']   → [Post:1, Post:2]
└── ['posts', 1] → Post:1
```

Each entity exists once. Query results are lists of references, not copies.

<svg viewBox="0 0 700 480" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="700" height="480" fill="#0f1117" rx="12"/>

  <!-- Title -->
  <text x="350" y="32" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Non-Normalized vs Normalized Cache</text>

  <!-- LEFT SIDE — Non-normalized -->
  <text x="175" y="60" text-anchor="middle" fill="#94a3b8" font-size="12">Non-Normalized (TanStack Default)</text>

  <!-- Cache box -->
  <rect x="30" y="72" width="290" height="340" rx="8" fill="#0f172a" stroke="#334155" stroke-width="1.5"/>

  <!-- Entry 1 -->
  <rect x="46" y="88" width="258" height="110" rx="6" fill="#1e293b" stroke="#475569" stroke-width="1"/>
  <text x="58" y="106" fill="#818cf8" font-size="11">['posts']</text>
  <rect x="58" y="112" width="234" height="36" rx="4" fill="#0f172a" stroke="#f87171" stroke-width="1"/>
  <text x="68" y="126" fill="#fca5a5" font-size="10">Post id:1 — title:'Hello'</text>
  <text x="68" y="141" fill="#fca5a5" font-size="10">author: id:42 name:'Ada'  ← copy</text>
  <rect x="58" y="152" width="234" height="36" rx="4" fill="#0f172a" stroke="#fb923c" stroke-width="1"/>
  <text x="68" y="166" fill="#fdba74" font-size="10">Post id:2 — title:'World'</text>
  <text x="68" y="181" fill="#fdba74" font-size="10">author: id:42 name:'Ada'  ← copy</text>

  <!-- Entry 2 -->
  <rect x="46" y="212" width="258" height="72" rx="6" fill="#1e293b" stroke="#475569" stroke-width="1"/>
  <text x="58" y="230" fill="#818cf8" font-size="11">['posts', 1]</text>
  <rect x="58" y="236" width="234" height="36" rx="4" fill="#0f172a" stroke="#f87171" stroke-width="1"/>
  <text x="68" y="250" fill="#fca5a5" font-size="10">Post id:1 — title:'Hello'</text>
  <text x="68" y="265" fill="#fca5a5" font-size="10">author: id:42 name:'Ada'  ← copy</text>

  <!-- Duplication label -->
  <rect x="46" y="298" width="258" height="44" rx="6" fill="#450a0a" stroke="#f87171" stroke-width="1" stroke-dasharray="4,3"/>
  <text x="175" y="316" text-anchor="middle" fill="#f87171" font-size="11">Post id:1 stored twice</text>
  <text x="175" y="333" text-anchor="middle" fill="#f87171" font-size="11">User id:42 stored three times</text>

  <!-- Update label -->
  <rect x="46" y="356" width="258" height="44" rx="6" fill="#1e293b" stroke="#475569" stroke-width="1"/>
  <text x="175" y="374" text-anchor="middle" fill="#94a3b8" font-size="11">Update post:1 title →</text>
  <text x="175" y="391" text-anchor="middle" fill="#f87171" font-size="11">must invalidate both entries</text>

  <!-- RIGHT SIDE — Normalized -->
  <text x="525" y="60" text-anchor="middle" fill="#94a3b8" font-size="12">Normalized</text>

  <!-- Entity store -->
  <rect x="380" y="72" width="290" height="200" rx="8" fill="#0f172a" stroke="#334155" stroke-width="1.5"/>
  <text x="395" y="94" fill="#94a3b8" font-size="11">Entity Store</text>

  <rect x="395" y="100" width="258" height="36" rx="4" fill="#1e293b" stroke="#22d3ee" stroke-width="1"/>
  <text x="407" y="114" fill="#67e8f9" font-size="10">Post:1  id:1  title:'Hello'</text>
  <text x="407" y="129" fill="#67e8f9" font-size="10">author ──────────────────────┐</text>

  <rect x="395" y="140" width="258" height="36" rx="4" fill="#1e293b" stroke="#fb923c" stroke-width="1"/>
  <text x="407" y="154" fill="#fdba74" font-size="10">Post:2  id:2  title:'World'</text>
  <text x="407" y="169" fill="#fdba74" font-size="10">author ──────────────────────┤</text>

  <rect x="395" y="180" width="258" height="36" rx="4" fill="#1e293b" stroke="#4ade80" stroke-width="1"/>
  <text x="407" y="198" fill="#86efac" font-size="10">User:42  id:42  name:'Ada'  ◄─┘</text>
  <text x="407" y="213" fill="#86efac" font-size="10">single source of truth</text>

  <!-- Query index -->
  <rect x="380" y="286" width="290" height="126" rx="8" fill="#0f172a" stroke="#334155" stroke-width="1.5"/>
  <text x="395" y="308" fill="#94a3b8" font-size="11">Query Index</text>

  <rect x="395" y="314" width="258" height="30" rx="4" fill="#1e293b" stroke="#6366f1" stroke-width="1"/>
  <text x="407" y="334" fill="#a5b4fc" font-size="10">['posts']  →  refs: [Post:1, Post:2]</text>

  <rect x="395" y="350" width="258" height="30" rx="4" fill="#1e293b" stroke="#6366f1" stroke-width="1"/>
  <text x="407" y="370" fill="#a5b4fc" font-size="10">['posts', 1]  →  ref: Post:1</text>

  <!-- Update label normalized -->
  <rect x="380" y="426" width="290" height="30" rx="6" fill="#052e16" stroke="#4ade80" stroke-width="1"/>
  <text x="525" y="446" text-anchor="middle" fill="#4ade80" font-size="11">Update Post:1 → all refs reflect instantly</text>
</svg>

---

### Tradeoffs at a Glance

| Dimension | Non-Normalized | Normalized |
|---|---|---|
| Setup complexity | Low | High |
| Data duplication | Yes | No |
| Cross-query consistency | Manual (invalidation) | Automatic (shared reference) |
| Partial update propagation | Requires invalidation | Automatic |
| Cache read performance | Direct key lookup | Reference resolution |
| Suitable for | Most applications | Entity-heavy, real-time apps |
| TanStack Query default | ✅ Yes | ❌ No (requires manual strategy) |

---

### The Core Problem Non-Normalization Creates

When the same entity appears in multiple query results, an update to that entity on the server does not automatically propagate to all cached copies. Each stale copy remains until its owning query is invalidated or refetched.

```ts
// A user's name changed on the server.
// These three query entries each hold an independent copy:
['users']               // list — stale copy of User:42
['users', 42]           // detail — stale copy of User:42
['posts']               // embedded in post.author — stale copy of User:42

// To propagate the change, all three must be invalidated:
queryClient.invalidateQueries({ queryKey: ['users'] })
queryClient.invalidateQueries({ queryKey: ['users', 42] })
queryClient.invalidateQueries({ queryKey: ['posts'] })
```

In a large application with many embedding queries, this becomes difficult to track reliably.

---

### How TanStack Query Addresses This Without Normalization

Rather than normalizing, TanStack Query's idiomatic approach uses **targeted invalidation** and **optimistic updates** to manage consistency.

#### Strategy 1 — Invalidate related queries on mutation success

```ts
const mutation = useMutation({
  mutationFn: (user) => updateUser(user),
  onSuccess: (updatedUser) => {
    queryClient.invalidateQueries({ queryKey: ['users'] })
    queryClient.invalidateQueries({ queryKey: ['users', updatedUser.id] })
    // Also invalidate any query that embeds user data
    queryClient.invalidateQueries({ queryKey: ['posts'] })
  },
})
```

#### Strategy 2 — Direct cache writes with `setQueryData`

```ts
const mutation = useMutation({
  mutationFn: (user) => updateUser(user),
  onSuccess: (updatedUser) => {
    // Update the detail entry directly
    queryClient.setQueryData(['users', updatedUser.id], updatedUser)

    // Update the list entry by mapping over cached data
    queryClient.setQueryData(['users'], (old) =>
      old?.map(u => u.id === updatedUser.id ? updatedUser : u)
    )
  },
})
```

**Key Points:**
- `setQueryData` writes synchronously to the cache without triggering a network request
- The list and detail entries are updated independently — they remain separate copies
- This is manual normalization-like behavior, not true normalization
- If the number of queries embedding the entity grows, this approach requires updating each explicitly

---

### Approximating Normalization — Manual Entity Sync

For applications with a manageable number of query shapes, a utility can centralize entity updates across known query keys.

```ts
function updateUserInCache(queryClient, updatedUser) {
  // Update detail query
  queryClient.setQueryData(
    ['users', updatedUser.id],
    updatedUser
  )

  // Update list query
  queryClient.setQueryData(['users'], (old) =>
    old?.map(u => u.id === updatedUser.id ? updatedUser : u)
  )

  // Update embedded references in posts
  queryClient.setQueryData(['posts'], (old) =>
    old?.map(post =>
      post.author?.id === updatedUser.id
        ? { ...post, author: updatedUser }
        : post
    )
  )
}
```

[Inference] This approach scales poorly as the number of query shapes grows. It is a pragmatic workaround, not a structural solution. Behavior may also be affected by query key variations (e.g., filtered or paginated lists) that the utility does not account for.

---

### True Normalization With External Libraries

For applications that genuinely require normalization, TanStack Query can be paired with a normalization library. The normalized store sits outside TanStack Query and is updated via callbacks.

#### Using `normalizr`

```ts
import { normalize, schema } from 'normalizr'

const userSchema = new schema.Entity('users')
const postSchema = new schema.Entity('posts', { author: userSchema })

// On query success, normalize and store entities separately
useQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
  select: (data) => {
    const { entities, result } = normalize(data, [postSchema])
    // entities.users, entities.posts available
    // Store entities in Zustand or another client store
    useEntityStore.getState().merge(entities)
    return result // return just the ID list to TanStack Query
  },
})
```

[Inference] This pattern uses TanStack Query for fetching and lifecycle management while delegating entity storage to a separate store. The integration requires careful coordination and is not an officially prescribed pattern — treat as architectural guidance, not guaranteed behavior.

---

### Using `@tanstack/query-sync-storage-persister` as a Complement

Normalization becomes more valuable when the cache is persisted. Without normalization, a persisted cache may resurrect stale duplicate entities on app load. This is a consideration when using persistence plugins alongside TanStack Query.

[Inference] The risk is application-specific and depends on how aggressively the application invalidates on mount.

---

### When Non-Normalized Cache Is Sufficient

Non-normalization is not a flaw — it is a deliberate design choice that fits the majority of use cases.

It is appropriate when:
- Entities are not heavily embedded across multiple query shapes
- Mutations are infrequent or well-scoped
- Invalidation boundaries are clear and manageable
- The application does not require instant cross-query consistency after a write
- Simplicity and low setup cost are priorities

---

### When Normalization Becomes Worth the Cost

Consider normalization strategies when:
- The same entity appears deeply embedded in many different query results
- Real-time updates (via WebSocket or SSE) must propagate instantly across all views
- Optimistic updates are complex and need a single source of truth to roll back against
- The application is entity-heavy (e.g., a project management tool, CRM, or social feed)
- Manual `setQueryData` calls across many query keys are becoming error-prone

---

### Summary

| Scenario | Recommended Approach |
|---|---|
| Standard CRUD, clear query boundaries | Non-normalized (TanStack Query default) |
| Shared entities in few query shapes | `setQueryData` on mutation success |
| Shared entities in many query shapes | Utility function centralizing cache writes |
| Real-time, entity-heavy application | External normalization library + TanStack Query |
| Persisted cache with frequent mutations | Consider normalization to avoid stale resurrection |

---

**Conclusion:**
TanStack Query's non-normalized cache is a pragmatic default that eliminates the complexity of normalization for the vast majority of applications. The cost — managing consistency across duplicate entries — is addressed through targeted invalidation and `setQueryData`. When that cost becomes unmanageable, normalization can be layered in via external libraries, with TanStack Query retaining responsibility for fetching, caching lifecycle, and background sync. The choice is architectural and should be driven by the actual consistency requirements of the application, not by convention.