## TanStack Query — Cache Management — Real-Time Data With WebSockets

---

### The Role of TanStack Query in Real-Time

TanStack Query is designed around a request-response model — a query function is called, data is returned, and the cache is updated. WebSockets invert this: the server pushes data to the client at arbitrary times, without the client initiating each exchange.

TanStack Query does not natively manage WebSocket connections. What it provides is a **cache that can be written to from any source** — including a WebSocket message handler. The integration pattern is: WebSocket owns the connection and receives messages; TanStack Query owns the cache and the UI synchronization.

**Key Points:**
- TanStack Query is not a WebSocket client — it does not open, maintain, or reconnect connections
- The cache can be updated from outside a query function via `setQueryData` and `invalidateQueries`
- Real-time and polling are complementary — polling can serve as a fallback when WebSocket is unavailable
- The integration point is always the message handler of the WebSocket

---

### Two Integration Strategies

There are two distinct approaches to combining WebSockets with TanStack Query. They differ in how much trust is placed in the incoming data.

| Strategy | Mechanism | When to Use |
|---|---|---|
| **Direct cache write** | `setQueryData` on message | Server sends full, trusted entity data |
| **Invalidation on event** | `invalidateQueries` on message | Server sends a signal; client fetches fresh data |

Both are valid. The choice depends on whether the WebSocket payload is a complete data replacement or a lightweight notification.

---

### Strategy 1 — Direct Cache Write With `setQueryData`

The WebSocket message contains the full updated entity. The handler writes it directly to the cache, bypassing a network fetch.

```ts
const queryClient = useQueryClient()

useEffect(() => {
  const ws = new WebSocket('wss://api.example.com/live')

  ws.onmessage = (event) => {
    const message = JSON.parse(event.data)

    if (message.type === 'POST_UPDATED') {
      // Write directly to the detail cache entry
      queryClient.setQueryData(
        ['posts', message.data.id],
        message.data
      )

      // Also update the list cache entry if it exists
      queryClient.setQueryData(['posts'], (old) =>
        old?.map(post =>
          post.id === message.data.id ? message.data : post
        )
      )
    }
  }

  return () => ws.close()
}, [queryClient])
```

**Key Points:**
- `setQueryData` writes synchronously — the UI updates immediately
- No network request is made — the WebSocket payload is the data
- The cache entry is marked as updated; its `dataUpdatedAt` timestamp is refreshed
- [Inference] The updated entry respects `staleTime` from this point — it will not be considered stale until `staleTime` elapses from the write. Actual behavior should be verified against the version in use
- List and detail entries must be updated independently — there is no normalization

---

### Strategy 2 — Invalidation on WebSocket Event

The WebSocket message is a signal that something changed, not the new data itself. The client responds by invalidating the relevant cache entry, triggering a refetch.

```ts
useEffect(() => {
  const ws = new WebSocket('wss://api.example.com/events')

  ws.onmessage = (event) => {
    const message = JSON.parse(event.data)

    if (message.type === 'POST_UPDATED') {
      queryClient.invalidateQueries({
        queryKey: ['posts', message.postId]
      })
    }

    if (message.type === 'POSTS_LIST_CHANGED') {
      queryClient.invalidateQueries({
        queryKey: ['posts']
      })
    }
  }

  return () => ws.close()
}, [queryClient])
```

**Key Points:**
- Simpler — no need to shape the incoming data into cache format
- Trades immediacy for correctness — the refetch adds latency but guarantees the client has authoritative server data
- Better suited when the WebSocket payload is partial, untrustworthy, or requires server-side transformation
- May trigger multiple rapid refetches if events arrive in bursts — consider debouncing

---

### Connection Management — Custom Hook Pattern

WebSocket connection logic should be encapsulated in a custom hook, separated from the component consuming query data.

```ts
// usePostsWebSocket.ts
function usePostsWebSocket() {
  const queryClient = useQueryClient()

  useEffect(() => {
    let ws: WebSocket
    let reconnectTimeout: ReturnType<typeof setTimeout>

    function connect() {
      ws = new WebSocket('wss://api.example.com/posts/live')

      ws.onopen = () => {
        console.log('WebSocket connected')
      }

      ws.onmessage = (event) => {
        const message = JSON.parse(event.data)
        handleMessage(message, queryClient)
      }

      ws.onclose = (event) => {
        if (!event.wasClean) {
          // Reconnect after delay on unclean close
          reconnectTimeout = setTimeout(connect, 3000)
        }
      }

      ws.onerror = (error) => {
        console.error('WebSocket error:', error)
      }
    }

    connect()

    return () => {
      clearTimeout(reconnectTimeout)
      ws?.close(1000, 'Component unmounted')
    }
  }, [queryClient])
}

function handleMessage(message: WsMessage, queryClient: QueryClient) {
  switch (message.type) {
    case 'POST_CREATED':
      queryClient.invalidateQueries({ queryKey: ['posts'] })
      break
    case 'POST_UPDATED':
      queryClient.setQueryData(['posts', message.data.id], message.data)
      queryClient.setQueryData(['posts'], (old: Post[] | undefined) =>
        old?.map(p => p.id === message.data.id ? message.data : p)
      )
      break
    case 'POST_DELETED':
      queryClient.removeQueries({ queryKey: ['posts', message.postId] })
      queryClient.setQueryData(['posts'], (old: Post[] | undefined) =>
        old?.filter(p => p.id !== message.postId)
      )
      break
  }
}
```

Usage:

```ts
function PostsPage() {
  usePostsWebSocket()  // manages connection lifecycle

  const { data: posts } = useQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  return <PostList posts={posts} />
}
```

**Key Points:**
- Connection lifecycle is co-located with mount/unmount via `useEffect` cleanup
- `queryClient` is stable across renders — safe to reference in `useEffect` without it causing re-execution
- The component only knows about its query — WebSocket complexity is fully abstracted

---

### Initial Data Fetch + WebSocket Updates

A common and robust pattern: use TanStack Query to fetch the initial state via HTTP, then use WebSocket to apply incremental updates.

```ts
function LiveDashboard() {
  // Step 1 — fetch initial state via HTTP
  const { data: metrics } = useQuery({
    queryKey: ['metrics'],
    queryFn: fetchMetrics,
    staleTime: Infinity,  // do not auto-refetch — WebSocket keeps it fresh
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
  })

  // Step 2 — apply real-time updates via WebSocket
  useEffect(() => {
    const ws = new WebSocket('wss://api.example.com/metrics/live')

    ws.onmessage = (event) => {
      const update = JSON.parse(event.data)

      queryClient.setQueryData(['metrics'], (old) => ({
        ...old,
        ...update,  // merge incoming partial update
      }))
    }

    return () => ws.close()
  }, [queryClient])

  return <MetricsDashboard data={metrics} />
}
```

**Key Points:**
- `staleTime: Infinity` prevents TanStack Query from treating the data as stale and triggering its own refetches — the WebSocket is the update mechanism
- `refetchOnWindowFocus: false` and `refetchOnReconnect: false` prevent redundant HTTP requests while the WebSocket is providing updates
- The merge strategy (`{ ...old, ...update }`) assumes partial updates — adjust to match the actual payload shape
- [Inference] If the WebSocket disconnects, the cache retains the last known state but stops receiving updates — a reconnect strategy or polling fallback should be considered

---

### Optimistic Updates With WebSocket Confirmation

For actions the user initiates (sending a message, updating a value), the client can apply an optimistic update immediately and let the WebSocket confirmation replace it.

```ts
const queryClient = useQueryClient()

function sendMessage(content: string) {
  const tempId = `temp-${Date.now()}`
  const optimisticMessage = {
    id: tempId,
    content,
    status: 'sending',
    createdAt: new Date().toISOString(),
  }

  // Apply optimistic update immediately
  queryClient.setQueryData(['messages'], (old: Message[] | undefined) => [
    ...(old ?? []),
    optimisticMessage,
  ])

  // Send over WebSocket — server will broadcast the confirmed message
  ws.send(JSON.stringify({ type: 'SEND_MESSAGE', content }))
}

// WebSocket handler replaces optimistic entry with confirmed data
ws.onmessage = (event) => {
  const message = JSON.parse(event.data)

  if (message.type === 'MESSAGE_CONFIRMED') {
    queryClient.setQueryData(['messages'], (old: Message[] | undefined) =>
      old?.map(m =>
        m.status === 'sending' && m.content === message.data.content
          ? message.data   // replace optimistic with confirmed
          : m
      )
    )
  }

  if (message.type === 'MESSAGE_FAILED') {
    queryClient.setQueryData(['messages'], (old: Message[] | undefined) =>
      old?.map(m =>
        m.id === message.tempId
          ? { ...m, status: 'failed' }
          : m
      )
    )
  }
}
```

**Key Points:**
- The optimistic message is written immediately — no perceived latency for the user
- The server confirmation replaces the temporary entry with authoritative data
- Failure handling sets a `status: 'failed'` flag, enabling UI retry affordance
- [Inference] Matching optimistic entries to confirmations by content is fragile if the user sends identical messages rapidly — a client-generated temp ID sent with the WebSocket message is more robust

---

### Handling WebSocket Reconnection

WebSocket connections drop. A reconnect strategy must account for data missed while the connection was closed.

```ts
function useReconnectingWebSocket(url: string) {
  const queryClient = useQueryClient()

  useEffect(() => {
    let ws: WebSocket
    let reconnectDelay = 1000
    const maxDelay = 30_000

    function connect() {
      ws = new WebSocket(url)

      ws.onopen = () => {
        reconnectDelay = 1000  // reset backoff on successful connect

        // Refetch all active queries to recover missed updates
        queryClient.invalidateQueries()
      }

      ws.onmessage = (event) => {
        const msg = JSON.parse(event.data)
        // ... handle messages
        reconnectDelay = 1000  // reset on activity
      }

      ws.onclose = (event) => {
        if (!event.wasClean) {
          setTimeout(() => {
            reconnectDelay = Math.min(reconnectDelay * 2, maxDelay)
            connect()
          }, reconnectDelay)
        }
      }
    }

    connect()
    return () => ws?.close(1000)
  }, [url, queryClient])
}
```

**Key Points:**
- Exponential backoff (`reconnectDelay * 2`) prevents flooding the server during outages
- `queryClient.invalidateQueries()` on reconnect forces a full resync — any updates missed during the disconnection are recovered via HTTP
- The aggressive `invalidateQueries()` call on reconnect may cause many simultaneous refetches — scope it to relevant query keys if the application has many active queries
- [Inference] `invalidateQueries()` with no filter invalidates all active queries; actual refetch behavior depends on which queries have active observers at reconnect time

---

### Coordinating With `refetchOnReconnect`

TanStack Query has a built-in `refetchOnReconnect` option that triggers refetches when network connectivity is restored (based on browser online/offline events). This is distinct from WebSocket reconnection.

```ts
useQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
  // If WebSocket handles updates, suppress automatic HTTP refetch on reconnect
  refetchOnReconnect: false,
  // Unless WebSocket reconnect explicitly calls invalidateQueries
})
```

**Key Points:**
- `refetchOnReconnect` responds to the browser's `online` event, not WebSocket state
- If the WebSocket reconnect handler calls `invalidateQueries`, the HTTP refetch is already triggered manually — `refetchOnReconnect: true` would duplicate it
- The appropriate setting depends on whether the WebSocket reconnect handler performs its own resync

---

### Polling as a Fallback

When WebSocket is unavailable (e.g., behind a proxy that strips upgrade headers), polling via `refetchInterval` provides a degraded but functional alternative.

```ts
const [wsConnected, setWsConnected] = useState(false)

const { data } = useQuery({
  queryKey: ['metrics'],
  queryFn: fetchMetrics,
  refetchInterval: wsConnected ? false : 5000,  // poll only when WS is down
})

useEffect(() => {
  const ws = new WebSocket('wss://api.example.com/metrics/live')
  ws.onopen = () => setWsConnected(true)
  ws.onclose = () => setWsConnected(false)
  return () => ws.close()
}, [])
```

**Key Points:**
- `refetchInterval: false` disables polling; a number enables it at that millisecond interval
- This pattern gracefully degrades — real-time when WebSocket is available, near-real-time when it is not
- [Inference] The transition between modes (WS connect/disconnect) may cause a brief period where neither mechanism is active — the delay depends on WebSocket close event timing and React re-render scheduling

---

### Architecture Diagram

<svg viewBox="0 0 700 440" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="700" height="440" fill="#0f1117" rx="12"/>
  <text x="350" y="30" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">WebSocket + TanStack Query Architecture</text>

  <!-- Server -->
  <rect x="270" y="52" width="160" height="48" rx="8" fill="#1e293b" stroke="#475569" stroke-width="1.5"/>
  <text x="350" y="72" text-anchor="middle" fill="#94a3b8" font-size="11">Server</text>
  <text x="350" y="90" text-anchor="middle" fill="#e2e8f0" font-size="12" font-weight="bold">REST + WebSocket</text>

  <!-- HTTP arrow down-left -->
  <line x1="300" y1="100" x2="160" y2="160" stroke="#6366f1" stroke-width="1.5" marker-end="url(#arrP)"/>
  <text x="195" y="135" fill="#818cf8" font-size="10">HTTP fetch</text>

  <!-- WS arrow down-right -->
  <line x1="400" y1="100" x2="540" y2="160" stroke="#22d3ee" stroke-width="1.5" marker-end="url(#arrC)"/>
  <text x="460" y="135" fill="#67e8f9" font-size="10">WS push</text>

  <!-- queryFn box -->
  <rect x="60" y="160" width="200" height="48" rx="8" fill="#1e293b" stroke="#6366f1" stroke-width="1.5"/>
  <text x="160" y="180" text-anchor="middle" fill="#818cf8" font-size="11">queryFn</text>
  <text x="160" y="198" text-anchor="middle" fill="#e2e8f0" font-size="12">fetches initial data</text>

  <!-- WS handler box -->
  <rect x="440" y="160" width="200" height="48" rx="8" fill="#1e293b" stroke="#22d3ee" stroke-width="1.5"/>
  <text x="540" y="180" text-anchor="middle" fill="#67e8f9" font-size="11">WS message handler</text>
  <text x="540" y="198" text-anchor="middle" fill="#e2e8f0" font-size="12">receives push events</text>

  <!-- Both point to QueryCache -->
  <rect x="220" y="280" width="260" height="60" rx="8" fill="#1e293b" stroke="#f59e0b" stroke-width="1.5"/>
  <text x="350" y="304" text-anchor="middle" fill="#fbbf24" font-size="11">QueryCache</text>
  <text x="350" y="322" text-anchor="middle" fill="#e2e8f0" font-size="12">single source of truth</text>

  <line x1="160" y1="208" x2="280" y2="280" stroke="#6366f1" stroke-width="1.5" marker-end="url(#arrP)"/>
  <text x="185" y="255" fill="#818cf8" font-size="10">setQueryData</text>

  <line x1="540" y1="208" x2="420" y2="280" stroke="#22d3ee" stroke-width="1.5" marker-end="url(#arrC)"/>
  <text x="448" y="255" fill="#67e8f9" font-size="10">setQueryData /</text>
  <text x="448" y="268" fill="#67e8f9" font-size="10">invalidateQueries</text>

  <!-- Cache to Components -->
  <rect x="220" y="384" width="260" height="40" rx="8" fill="#0f172a" stroke="#4ade80" stroke-width="1.5"/>
  <text x="350" y="409" text-anchor="middle" fill="#4ade80" font-size="12">UI Components (observers)</text>

  <line x1="350" y1="340" x2="350" y2="384" stroke="#4ade80" stroke-width="1.5" marker-end="url(#arrG)"/>
  <text x="358" y="368" fill="#4ade80" font-size="10">notify observers → re-render</text>

  <defs>
    <marker id="arrP" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#6366f1"/>
    </marker>
    <marker id="arrC" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#22d3ee"/>
    </marker>
    <marker id="arrG" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4ade80"/>
    </marker>
  </defs>
</svg>

---

### Server-Sent Events (SSE) — Same Pattern, Different Transport

SSE uses a persistent HTTP connection for server-to-client push without full-duplex communication. The integration pattern with TanStack Query is identical.

```ts
useEffect(() => {
  const es = new EventSource('https://api.example.com/events')

  es.addEventListener('POST_UPDATED', (event) => {
    const data = JSON.parse(event.data)
    queryClient.setQueryData(['posts', data.id], data)
  })

  es.addEventListener('POST_CREATED', () => {
    queryClient.invalidateQueries({ queryKey: ['posts'] })
  })

  es.onerror = () => {
    // EventSource reconnects automatically — no manual reconnect needed
  }

  return () => es.close()
}, [queryClient])
```

**Key Points:**
- `EventSource` reconnects automatically on connection loss — no manual backoff needed
- SSE is unidirectional (server → client only); use HTTP for client → server
- The cache integration is identical to WebSocket — `setQueryData` or `invalidateQueries` from the event handler
- SSE works through standard HTTP/2 and does not require WebSocket upgrade headers — more proxy-friendly

---

### Common Mistakes

**Opening a new WebSocket connection per component.**
Multiple components subscribing to the same data each opening their own connection wastes server resources. The connection should be shared — via a custom hook at the page level, a React context, or a singleton outside React.

**Not cleaning up on unmount.**
Failing to close the WebSocket in the `useEffect` cleanup leaves connections open after navigation, causing memory leaks and ghost message handlers that write to a stale `queryClient` reference.

**Trusting partial payloads as complete replacements.**
If the server sends a partial update (only changed fields), writing it directly with `setQueryData` replaces the full cached object. Always merge:
```ts
queryClient.setQueryData(['post', id], (old) => ({ ...old, ...update }))
```

**Invalidating too broadly on every message.**
Calling `queryClient.invalidateQueries()` with no filter on every WebSocket message triggers refetches for all active queries. Scope invalidation to the affected keys.

---

### Summary

| Concern | Recommendation |
|---|---|
| Connection ownership | WebSocket / SSE hook — not TanStack Query |
| Initial data | `useQuery` with HTTP fetch |
| Real-time updates | `setQueryData` (full payload) or `invalidateQueries` (signal only) |
| Reconnection | Manual backoff + `invalidateQueries` on reconnect for resync |
| Polling fallback | `refetchInterval` conditioned on WebSocket state |
| Optimistic updates | Write temp entry; replace on WS confirmation |
| Suppressing auto-refetch | `staleTime: Infinity`, `refetchOnWindowFocus: false` |
| SSE alternative | `EventSource` — same cache integration, auto-reconnect built in |

---

**Conclusion:**
TanStack Query and WebSockets are complementary rather than overlapping. TanStack Query owns the cache and UI synchronization; the WebSocket owns the connection and the push channel. The integration is always at the message handler — either writing directly to the cache with `setQueryData` when the payload is complete and trusted, or signaling staleness with `invalidateQueries` when the server sends events rather than data. Encapsulating connection logic in a custom hook keeps components clean and makes the real-time layer independently testable and replaceable.