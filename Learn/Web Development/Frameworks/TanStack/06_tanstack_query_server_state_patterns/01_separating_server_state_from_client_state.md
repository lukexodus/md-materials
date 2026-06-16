## TanStack Query — Cache Management — Separating Server State from Client State

---

### The Core Distinction

**Server state** and **client state** are fundamentally different in nature, and treating them the same way is a common source of complexity in React applications.

| Dimension | Server State | Client State |
|---|---|---|
| Source of truth | Remote (API, database) | Local (component, store) |
| Ownership | Shared / external | Application-owned |
| Synchronization | Must be fetched, cached, revalidated | Always current by definition |
| Staleness | Can become outdated at any time | Never stale unless explicitly changed |
| Persistence | Lives beyond the app session | Typically lost on reload |
| Examples | User profile, posts, orders | Modal open, selected tab, form draft |

Mixing these two categories into the same state manager forces the developer to manually implement caching, background sync, deduplication, and invalidation — problems TanStack Query solves for server state specifically.

---

### Why the Separation Matters

When server state is managed in a general-purpose store (such as Redux or Zustand), the application must manually handle:

- Fetching on mount
- Tracking loading and error states
- Preventing duplicate requests
- Deciding when data is stale
- Invalidating and refetching after mutations
- Garbage collecting unused entries

TanStack Query handles all of the above for server state. The result is that a general-purpose store, if used alongside TanStack Query, only needs to manage genuinely local state — which is typically far simpler.

---

### Defining the Boundary

A practical rule for deciding which tool owns a piece of state:

```
Does this data come from or need to be synchronized with a server?
  └─ Yes → TanStack Query
  └─ No  → Local state (useState, useReducer, Zustand, etc.)
```

**Server state examples:**
- `/api/users` response
- Current authenticated user profile
- Paginated product listings
- Order history

**Client state examples:**
- Whether a modal is open
- Which tab is active
- A search input value before submission
- Theme preference (unless persisted to an API)
- Optimistic UI values before server confirmation

---

### Anti-Pattern — Lifting Server State Into a Global Store

A common pattern before TanStack Query was to fetch data in a thunk or saga and store the result in Redux:

```ts
// ❌ Anti-pattern: managing server state in Redux
const usersSlice = createSlice({
  name: 'users',
  initialState: { data: [], loading: false, error: null },
  reducers: {
    fetchStart: (state) => { state.loading = true },
    fetchSuccess: (state, action) => {
      state.loading = false
      state.data = action.payload
    },
    fetchError: (state, action) => {
      state.loading = false
      state.error = action.payload
    },
  },
})
```

Problems with this approach:
- Manual loading/error state management
- No automatic background refetch
- No cache expiry or garbage collection
- Stale data persists until manually cleared
- Deduplication must be implemented by hand

---

### Correct Pattern — TanStack Query for Server State

```ts
// ✅ Server state owned by TanStack Query
function UserList() {
  const { data, isPending, isError } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  })

  if (isPending) return <Spinner />
  if (isError) return <ErrorMessage />
  return <ul>{data.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}
```

No external store. No manual loading flags. No manual cache invalidation. The component declares what data it needs and TanStack Query manages the rest.

---

### Correct Pattern — Local State for Client State

Client state that has no server origin stays in local React state or a lightweight client store.

```ts
function ProductPage() {
  // ✅ Client state — local, no server involvement
  const [isFilterOpen, setIsFilterOpen] = useState(false)
  const [selectedCategory, setSelectedCategory] = useState('all')

  // ✅ Server state — owned by TanStack Query
  const { data: products } = useQuery({
    queryKey: ['products', selectedCategory],
    queryFn: () => fetchProducts(selectedCategory),
  })

  return (
    <>
      <FilterPanel
        open={isFilterOpen}
        category={selectedCategory}
        onCategoryChange={setSelectedCategory}
        onToggle={() => setIsFilterOpen(p => !p)}
      />
      <ProductGrid products={products} />
    </>
  )
}
```

**Key Points:**
- `isFilterOpen` and `selectedCategory` never touch TanStack Query
- `selectedCategory` drives the query key, making server state reactive to client state
- Neither state category bleeds into the other's domain

---

### Using Client State to Drive Server State

A legitimate and common pattern is for client state to parameterize server state. The query key encodes the dependency.

```ts
function SearchPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [page, setPage] = useState(1)

  const { data } = useQuery({
    queryKey: ['search', searchTerm, page],
    queryFn: () => searchAPI({ term: searchTerm, page }),
    enabled: searchTerm.length > 0,
  })

  return (
    <>
      <input
        value={searchTerm}
        onChange={e => {
          setSearchTerm(e.target.value)
          setPage(1)
        }}
      />
      <ResultsList results={data?.results} />
      <Pagination page={page} onPageChange={setPage} />
    </>
  )
}
```

**Key Points:**
- `searchTerm` and `page` are client state — they live in `useState`
- They flow into the query key, making the query reactive
- When client state changes, TanStack Query responds with a new fetch — no manual wiring needed
- `enabled: searchTerm.length > 0` prevents fetching with an empty term

---

### Coexistence With a Global Client Store

TanStack Query and Zustand (or Redux) are not mutually exclusive. The recommended division:

```ts
// Zustand store — client state only
const useUIStore = create((set) => ({
  sidebarOpen: false,
  toggleSidebar: () => set(s => ({ sidebarOpen: !s.sidebarOpen })),
  activeWorkspaceId: null,
  setActiveWorkspace: (id) => set({ activeWorkspaceId: id }),
}))

// TanStack Query — server state, driven by client state
function WorkspaceDashboard() {
  const activeWorkspaceId = useUIStore(s => s.activeWorkspaceId)

  const { data: workspace } = useQuery({
    queryKey: ['workspace', activeWorkspaceId],
    queryFn: () => fetchWorkspace(activeWorkspaceId),
    enabled: !!activeWorkspaceId,
  })

  return <Dashboard data={workspace} />
}
```

**Key Points:**
- The global store holds no server data
- TanStack Query holds no UI state
- Each tool does only what it is designed for

---

### Derived Client State From Server State

Sometimes UI state is derived from server state rather than independently maintained. Prefer deriving it rather than copying it into a separate store.

```ts
// ❌ Copying server data into client state — creates sync problems
const [userRole, setUserRole] = useState(null)

useEffect(() => {
  if (userData) setUserRole(userData.role)
}, [userData])

// ✅ Derive directly from server state
const { data: userData } = useQuery({
  queryKey: ['user'],
  queryFn: fetchCurrentUser,
})

const isAdmin = userData?.role === 'admin'   // derived, not stored
```

Copying server data into a `useState` introduces a secondary source of truth that can fall out of sync. Computing derived values directly from the query result avoids this.

---

### Form State — A Common Ambiguous Case

Form data sits in an ambiguous position: it is client state while being edited, but may need to be initialized from server state and eventually written back to the server.

```ts
function EditProfileForm({ userId }) {
  // Server state — source of initial values
  const { data: profile } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  // Client state — the live form values while editing
  const [formValues, setFormValues] = useState(null)

  // Initialize form from server data once loaded
  useEffect(() => {
    if (profile && formValues === null) {
      setFormValues(profile)
    }
  }, [profile])

  const mutation = useMutation({
    mutationFn: (values) => updateUser(userId, values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['user', userId] })
    },
  })

  if (!formValues) return <Spinner />

  return (
    <form onSubmit={() => mutation.mutate(formValues)}>
      <input
        value={formValues.name}
        onChange={e => setFormValues(p => ({ ...p, name: e.target.value }))}
      />
      <button type="submit">Save</button>
    </form>
  )
}
```

**Key Points:**
- Server state seeds the form but does not own it during editing
- Form values during editing are client state in `useState`
- On success, the cache is invalidated so server state reflects the update
- The form does not re-initialize from the query after submission unless explicitly reset — [Inference] depending on component lifecycle and query refetch timing

---

### Mental Model Summary

```
┌─────────────────────────────────────────────────────────┐
│                     Application State                   │
│                                                         │
│   ┌──────────────────────┐  ┌────────────────────────┐  │
│   │    TanStack Query    │  │   useState / Zustand   │  │
│   │                      │  │   / Redux (UI only)    │  │
│   │  - Fetched data      │  │                        │  │
│   │  - Loading/error     │  │  - Modal open/closed   │  │
│   │  - Cache + GC        │  │  - Selected tab        │  │
│   │  - Background sync   │  │  - Form draft values   │  │
│   │  - Deduplication     │  │  - Theme               │  │
│   │                      │  │  - Pagination page     │  │
│   └──────────────────────┘  └────────────────────────┘  │
│            ▲                           │                 │
│            └───── drives query key ────┘                 │
└─────────────────────────────────────────────────────────┘
```

---

**Conclusion:**
The separation of server state and client state is not merely an organizational preference — it reflects a genuine difference in the nature of these two kinds of data. TanStack Query is purpose-built for the async, stale, shared, and externally owned character of server state. Respecting this boundary reduces boilerplate, eliminates entire categories of synchronization bugs, and keeps each state management tool operating within the scope it handles well.