## TanStack Query — Cache Management — Synchronizing Multiple Tabs

---

### The Problem

TanStack Query's cache lives in memory, scoped to a single browser tab. When a user has the application open in multiple tabs simultaneously, each tab maintains its own independent `QueryClient` instance with its own cache. A mutation in tab A does not automatically invalidate or update the cache in tab B.

This creates observable inconsistencies:
- User updates their profile in tab A; tab B still shows the old name
- User deletes a record in tab A; tab B still shows the deleted record
- User logs out in tab A; tab B remains authenticated

Synchronizing state across tabs requires a cross-tab communication mechanism. TanStack Query does not provide this natively, but its cache is writable from any source — making integration with browser communication APIs straightforward.

---

### Browser Mechanisms for Cross-Tab Communication

| Mechanism | Scope | Persistence | Latency | Notes |
|---|---|---|---|---|
| `BroadcastChannel` | Same origin, all tabs | None (in-memory) | Near-zero | Modern, purpose-built for this |
| `localStorage` events | Same origin, other tabs | Persistent | Near-zero | Fires only in other tabs, not sender |
| `SharedWorker` | Same origin | Worker lifetime | Near-zero | More complex; shared execution context |
| `ServiceWorker` | Same origin | Worker lifetime | Low | Requires HTTPS; more infrastructure |
| Server push (WS/SSE) | Any tab | Server-side | Network RTT | Covered in the WebSocket topic |

For most applications, `BroadcastChannel` is the correct choice. It is purpose-built for tab-to-tab messaging, requires no storage, and has broad browser support.

---

### Core Integration Pattern

The integration follows the same two-strategy model as WebSocket integration:

| Strategy | Mechanism | When to use |
|---|---|---|
| **Invalidation** | Broadcast event → `invalidateQueries` in other tabs | Signal that something changed; let each tab refetch |
| **Direct cache write** | Broadcast event → `setQueryData` in other tabs | Send full updated entity; avoid redundant refetches |

---

### Strategy 1 — Invalidation via `BroadcastChannel`

The mutating tab sends a message. All other tabs receive it and invalidate their relevant cache entries, triggering refetches.

```ts
// broadcastChannel.ts — shared singleton
export const queryChannel = new BroadcastChannel('tanstack_query_sync')
```

```ts
// In the mutating tab — after a successful mutation
const mutation = useMutation({
  mutationFn: (data) => updatePost(data),
  onSuccess: (updatedPost) => {
    // Update own cache
    queryClient.invalidateQueries({ queryKey: ['posts'] })
    queryClient.invalidateQueries({ queryKey: ['posts', updatedPost.id] })

    // Notify other tabs
    queryChannel.postMessage({
      type: 'INVALIDATE',
      queryKey: ['posts'],
    })
    queryChannel.postMessage({
      type: 'INVALIDATE',
      queryKey: ['posts', updatedPost.id],
    })
  },
})
```

```ts
// In all tabs — listening for cross-tab events
useEffect(() => {
  const handler = (event: MessageEvent) => {
    if (event.data.type === 'INVALIDATE') {
      queryClient.invalidateQueries({
        queryKey: event.data.queryKey,
      })
    }
  }

  queryChannel.addEventListener('message', handler)
  return () => queryChannel.removeEventListener('message', handler)
}, [queryClient])
```

**Key Points:**
- `BroadcastChannel` messages are received by all tabs on the same origin **except the sending tab**
- The sender invalidates its own cache directly; other tabs receive the broadcast
- `invalidateQueries` triggers a refetch only if the query has active observers (mounted components) — inactive cache entries are marked stale but not immediately refetched
- [Inference] Query key serialization via `JSON.stringify` may not round-trip correctly for complex keys with non-primitive values — keep broadcast keys simple or use a consistent serializer

---

### Strategy 2 — Direct Cache Write via `BroadcastChannel`

The mutating tab sends the full updated entity. Other tabs write it directly to their cache without a network request.

```ts
const mutation = useMutation({
  mutationFn: (data) => updatePost(data),
  onSuccess: (updatedPost) => {
    // Update own cache
    queryClient.setQueryData(['posts', updatedPost.id], updatedPost)

    // Send full data to other tabs
    queryChannel.postMessage({
      type: 'SET_QUERY_DATA',
      queryKey: ['posts', updatedPost.id],
      data: updatedPost,
    })
  },
})
```

```ts
useEffect(() => {
  const handler = (event: MessageEvent) => {
    const { type, queryKey, data } = event.data

    if (type === 'SET_QUERY_DATA') {
      queryClient.setQueryData(queryKey, data)
    }
  }

  queryChannel.addEventListener('message', handler)
  return () => queryChannel.removeEventListener('message', handler)
}, [queryClient])
```

**Key Points:**
- Zero network cost in receiving tabs — data is written directly from the broadcast payload
- The receiving tab's cache entry is updated synchronously — UI updates immediately
- Requires the full entity to be included in the message payload
- BroadcastChannel message size is not formally specified — [Inference] very large payloads (e.g., large arrays) may cause performance issues; prefer invalidation for bulk data

---

### Centralizing the Listener — Global Setup

Rather than adding the `BroadcastChannel` listener inside individual components, set it up once at the application root alongside `QueryClientProvider`.

```ts
// queryClient.ts
import { QueryClient } from '@tanstack/react-query'
import { BroadcastChannel } from 'broadcast-channel'  // or native

export const queryClient = new QueryClient()
export const queryChannel = new BroadcastChannel('tanstack_query_sync')

// Register once — not inside React
queryChannel.onmessage = (event) => {
  const { type, queryKey, data } = event.data

  switch (type) {
    case 'INVALIDATE':
      queryClient.invalidateQueries({ queryKey })
      break
    case 'SET_QUERY_DATA':
      queryClient.setQueryData(queryKey, data)
      break
    case 'REMOVE_QUERY':
      queryClient.removeQueries({ queryKey })
      break
  }
}
```

```ts
// main.tsx / App.tsx
import { queryClient } from './queryClient'

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router />
    </QueryClientProvider>
  )
}
```

**Key Points:**
- The listener is registered outside React — it persists for the full tab lifetime
- No risk of duplicate listeners from re-renders or multiple component mounts
- `queryClient` is a stable singleton — safe to reference outside React

---

### Using `@tanstack/query-broadcast-client-experimental`

TanStack Query provides an experimental official package for broadcast-based synchronization. It wraps the `BroadcastChannel` pattern with built-in query action serialization.

```bash
npm install @tanstack/query-broadcast-client-experimental
```

```ts
import { QueryClient } from '@tanstack/react-query'
import { broadcastQueryClient } from '@tanstack/query-broadcast-client-experimental'

const queryClient = new QueryClient()

broadcastQueryClient({
  queryClient,
  broadcastChannel: 'tanstack_query',
})
```

**Key Points:**
- Automatically broadcasts cache mutations (query updates, removals) to other tabs
- Automatically receives broadcasts and applies them to the local cache
- Marked **experimental** — API may change across versions; verify compatibility before use in production
- [Inference] Internal implementation uses `BroadcastChannel` and serializes cache actions — exact behavior and which actions are broadcast should be confirmed against the package's documentation for the version in use

---

### `localStorage` Events as an Alternative

`localStorage` fires a `storage` event in all tabs on the same origin **except the one that made the change**. This mirrors `BroadcastChannel` behavior but uses storage as the transport.

```ts
// Sending tab — write to localStorage as the broadcast mechanism
function broadcastInvalidation(queryKey: unknown[]) {
  localStorage.setItem(
    'query_sync',
    JSON.stringify({ queryKey, timestamp: Date.now() })
  )
  // Remove immediately — the event fires on write, not on read
  localStorage.removeItem('query_sync')
}

// Receiving tabs — listen for storage events
useEffect(() => {
  const handler = (event: StorageEvent) => {
    if (event.key === 'query_sync' && event.newValue) {
      const { queryKey } = JSON.parse(event.newValue)
      queryClient.invalidateQueries({ queryKey })
    }
  }

  window.addEventListener('storage', handler)
  return () => window.removeEventListener('storage', handler)
}, [queryClient])
```

**Key Points:**
- `storage` events fire only in other tabs — identical to `BroadcastChannel` in this respect
- The write-then-remove pattern ensures the event fires without leaving stale data in storage
- [Inference] Rapid successive writes may coalesce or miss events depending on browser implementation — `BroadcastChannel` is more reliable for high-frequency updates
- `localStorage` is synchronous and blocks the main thread on write — `BroadcastChannel` is asynchronous and preferred
- `localStorage` approach works in browsers that lack `BroadcastChannel` support, though support is now broad

---

### Authentication and Session Synchronization

Logout in one tab is a critical case. All tabs must reflect the session termination immediately.

```ts
const logoutMutation = useMutation({
  mutationFn: () => logoutApi(),
  onSuccess: () => {
    // Clear own cache
    queryClient.clear()

    // Notify other tabs
    queryChannel.postMessage({ type: 'LOGOUT' })

    // Redirect
    navigate('/login')
  },
})
```

```ts
// Global listener
queryChannel.onmessage = (event) => {
  switch (event.data.type) {
    case 'LOGOUT':
      queryClient.clear()
      window.location.href = '/login'
      break
    // ... other cases
  }
}
```

**Key Points:**
- `queryClient.clear()` removes all cache entries and cancels pending queries
- `window.location.href` performs a hard redirect — appropriate for logout to ensure no stale state remains in memory
- [Inference] A soft navigation (e.g., React Router `navigate`) after `queryClient.clear()` may leave component state that assumes authenticated data — a hard redirect is safer for logout

---

### Visibility-Based Refetch as a Partial Solution

TanStack Query's `refetchOnWindowFocus` provides a coarse approximation of tab synchronization without any additional infrastructure.

```ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: true,   // default — refetch when tab regains focus
    },
  },
})
```

When the user switches back to a tab that was in the background, all active queries with stale data are refetched. This handles the common case where data changed in another tab while this tab was inactive.

**Key Points:**
- Zero implementation cost — enabled by default
- Covers the most common multi-tab scenario: user does work in one tab, switches back to another
- Does not handle the case where both tabs are simultaneously visible (e.g., split screen)
- Does not handle logout or security-sensitive events — those require active broadcast
- A useful baseline; `BroadcastChannel` is additive for stricter consistency requirements

---

### Combining Strategies

A robust production setup layers both approaches:

```ts
// queryClient.ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: true,    // passive: handles focus-on-return
      staleTime: 30_000,
    },
  },
})

const queryChannel = new BroadcastChannel('app_query_sync')

// Active: handles mutations, logout, security events
queryChannel.onmessage = (event) => {
  const { type, queryKey, data } = event.data

  switch (type) {
    case 'INVALIDATE':
      queryClient.invalidateQueries({ queryKey })
      break
    case 'SET_QUERY_DATA':
      queryClient.setQueryData(queryKey, data)
      break
    case 'LOGOUT':
      queryClient.clear()
      window.location.href = '/login'
      break
  }
}

export { queryClient, queryChannel }
```

```
Passive layer:  refetchOnWindowFocus
  └── Covers: returning to an inactive tab, stale data on focus
  └── Does not cover: simultaneous tabs, logout, security events

Active layer:   BroadcastChannel
  └── Covers: mutations, invalidations, logout, any explicit event
  └── Does not cover: tabs opened after the event (they fetch fresh on mount)
```

---

### Architecture Overview

<svg viewBox="0 0 700 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="700" height="400" fill="#0f1117" rx="12"/>
  <text x="350" y="30" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Multi-Tab Cache Synchronization</text>

  <!-- Tab A -->
  <rect x="30" y="52" width="190" height="220" rx="8" fill="#0f172a" stroke="#6366f1" stroke-width="1.5"/>
  <text x="125" y="74" text-anchor="middle" fill="#818cf8" font-size="12" font-weight="bold">Tab A</text>

  <rect x="46" y="84" width="158" height="44" rx="6" fill="#1e293b" stroke="#6366f1" stroke-width="1"/>
  <text x="125" y="102" text-anchor="middle" fill="#818cf8" font-size="11">QueryClient</text>
  <text x="125" y="118" text-anchor="middle" fill="#e2e8f0" font-size="11">cache (in memory)</text>

  <rect x="46" y="136" width="158" height="36" rx="6" fill="#1e293b" stroke="#f59e0b" stroke-width="1"/>
  <text x="125" y="150" text-anchor="middle" fill="#fbbf24" font-size="11">useMutation</text>
  <text x="125" y="164" text-anchor="middle" fill="#e2e8f0" font-size="10">onSuccess → broadcast</text>

  <rect x="46" y="180" width="158" height="36" rx="6" fill="#1e293b" stroke="#22d3ee" stroke-width="1"/>
  <text x="125" y="198" text-anchor="middle" fill="#67e8f9" font-size="11">BroadcastChannel</text>
  <text x="125" y="212" text-anchor="middle" fill="#e2e8f0" font-size="10">postMessage(event)</text>

  <rect x="46" y="224" width="158" height="36" rx="6" fill="#052e16" stroke="#4ade80" stroke-width="1"/>
  <text x="125" y="242" text-anchor="middle" fill="#4ade80" font-size="11">refetchOnWindowFocus</text>
  <text x="125" y="256" text-anchor="middle" fill="#86efac" font-size="10">passive fallback</text>

  <!-- Tab B -->
  <rect x="255" y="52" width="190" height="220" rx="8" fill="#0f172a" stroke="#6366f1" stroke-width="1.5"/>
  <text x="350" y="74" text-anchor="middle" fill="#818cf8" font-size="12" font-weight="bold">Tab B</text>

  <rect x="271" y="84" width="158" height="44" rx="6" fill="#1e293b" stroke="#6366f1" stroke-width="1"/>
  <text x="350" y="102" text-anchor="middle" fill="#818cf8" font-size="11">QueryClient</text>
  <text x="350" y="118" text-anchor="middle" fill="#e2e8f0" font-size="11">cache (in memory)</text>

  <rect x="271" y="136" width="158" height="36" rx="6" fill="#1e293b" stroke="#22d3ee" stroke-width="1"/>
  <text x="350" y="154" text-anchor="middle" fill="#67e8f9" font-size="11">BroadcastChannel</text>
  <text x="350" y="170" text-anchor="middle" fill="#e2e8f0" font-size="10">onmessage → invalidate</text>

  <rect x="271" y="180" width="158" height="44" rx="6" fill="#1e293b" stroke="#f87171" stroke-width="1"/>
  <text x="350" y="198" text-anchor="middle" fill="#fca5a5" font-size="11">LOGOUT event →</text>
  <text x="350" y="214" text-anchor="middle" fill="#fca5a5" font-size="10">queryClient.clear()</text>
  <text x="350" y="226" text-anchor="middle" fill="#fca5a5" font-size="10">redirect /login</text>

  <!-- Tab C -->
  <rect x="480" y="52" width="190" height="220" rx="8" fill="#0f172a" stroke="#6366f1" stroke-width="1.5"/>
  <text x="575" y="74" text-anchor="middle" fill="#818cf8" font-size="12" font-weight="bold">Tab C</text>

  <rect x="496" y="84" width="158" height="44" rx="6" fill="#1e293b" stroke="#6366f1" stroke-width="1"/>
  <text x="575" y="102" text-anchor="middle" fill="#818cf8" font-size="11">QueryClient</text>
  <text x="575" y="118" text-anchor="middle" fill="#e2e8f0" font-size="11">cache (in memory)</text>

  <rect x="496" y="136" width="158" height="36" rx="6" fill="#1e293b" stroke="#22d3ee" stroke-width="1"/>
  <text x="575" y="154" text-anchor="middle" fill="#67e8f9" font-size="11">BroadcastChannel</text>
  <text x="575" y="170" text-anchor="middle" fill="#e2e8f0" font-size="10">onmessage → setQueryData</text>

  <rect x="496" y="180" width="158" height="36" rx="6" fill="#052e16" stroke="#4ade80" stroke-width="1"/>
  <text x="575" y="198" text-anchor="middle" fill="#4ade80" font-size="11">refetchOnWindowFocus</text>
  <text x="575" y="212" text-anchor="middle" fill="#86efac" font-size="10">passive fallback</text>

  <!-- BroadcastChannel bus -->
  <rect x="30" y="308" width="640" height="44" rx="8" fill="#1e293b" stroke="#22d3ee" stroke-width="2"/>
  <text x="350" y="326" text-anchor="middle" fill="#67e8f9" font-size="12" font-weight="bold">BroadcastChannel — 'app_query_sync'</text>
  <text x="350" y="344" text-anchor="middle" fill="#94a3b8" font-size="11">same-origin message bus — sender excluded</text>

  <!-- Arrows from tabs to bus -->
  <line x1="125" y1="272" x2="125" y2="308" stroke="#22d3ee" stroke-width="1.5" marker-end="url(#aC)"/>
  <line x1="350" y1="272" x2="350" y2="308" stroke="#22d3ee" stroke-width="1.5" marker-end="url(#aC)"/>
  <line x1="575" y1="272" x2="575" y2="308" stroke="#22d3ee" stroke-width="1.5" marker-end="url(#aC)"/>

  <!-- Server box -->
  <rect x="240" y="368" width="220" height="24" rx="6" fill="#0f172a" stroke="#475569" stroke-width="1"/>
  <text x="350" y="384" text-anchor="middle" fill="#475569" font-size="11">HTTP refetch on invalidation</text>

  <defs>
    <marker id="aC" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#22d3ee"/>
    </marker>
  </defs>
</svg>

---

### What Newly Opened Tabs Receive

A tab opened after a broadcast event was sent receives nothing retroactively — `BroadcastChannel` has no message history. Newly opened tabs rely on their initial query fetches to get current data.

This is generally acceptable: a new tab fetches fresh data on mount. The gap only matters if a mutation occurred between the tab opening and its first fetch completing — an extremely narrow window in practice.

For applications where this matters, a `localStorage`-based "last mutation timestamp" can signal to new tabs that they should skip cache and force a fresh fetch:

```ts
// On mutation
localStorage.setItem('last_mutation', Date.now().toString())

// On new tab mount — in queryClient defaultOptions
queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // [Inference] Custom initialData or enabled logic could read
      // localStorage to decide whether to trust any persisted cache
    },
  },
})
```

[Inference] This pattern adds complexity and is rarely necessary in practice. Most applications accept that new tabs fetch fresh data on mount.

---

### Summary

| Need | Solution |
|---|---|
| Basic multi-tab freshness | `refetchOnWindowFocus: true` (default) |
| Mutation propagation to other tabs | `BroadcastChannel` → `invalidateQueries` |
| Zero-refetch update propagation | `BroadcastChannel` → `setQueryData` |
| Logout / session termination | `BroadcastChannel` → `queryClient.clear()` + redirect |
| Managed official solution | `@tanstack/query-broadcast-client-experimental` |
| Legacy browser fallback | `localStorage` storage events |
| Newly opened tabs | Rely on initial fetch — no retroactive broadcast history |

---

**Conclusion:**
Multi-tab synchronization in TanStack Query is a layered concern. The passive layer — `refetchOnWindowFocus` — handles the most common case with zero effort: stale data is refreshed when the user returns to a tab. The active layer — `BroadcastChannel` — handles mutations, invalidations, and security events in real time across simultaneously visible tabs. Together they cover the full spectrum of multi-tab consistency requirements without requiring a server-side synchronization mechanism.