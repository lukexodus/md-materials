## Query Keys and Key Structure

### Overview

Query keys are the addressing system of TanStack Query's cache. Every cached result, background refetch, and invalidation operation is coordinated through query keys. Understanding how keys are structured, compared, and matched is foundational to using TanStack Query correctly.

---

### What a Query Key Is

A query key is an array. TanStack Query uses this array to identify a unique cache entry.

```ts
queryKey: ['todos']
queryKey: ['todo', 42]
queryKey: ['todos', { status: 'active', page: 1 }]
```

**Key Points:**
- The key must be an array. A string alone is not valid.
- Arrays can contain strings, numbers, booleans, objects, or nested arrays — any JSON-serializable value.
- Non-serializable values (e.g., functions, class instances) should not be used as keys. [Inference] Their comparison behavior is likely unreliable since TanStack Query serializes keys for hashing. Behavior may vary.

---

### How Keys Are Compared

TanStack Query compares keys by value, not by reference. The comparison is deterministic and deep.

```ts
// These are treated as the same key
['todos', { status: 'active' }]
['todos', { status: 'active' }]

// These are different keys — different string segment
['todos', { status: 'active' }]
['todos', { status: 'done' }]

// These are different keys — order of array elements matters
['todo', 42]
[42, 'todo']
```

**Key Points:**
- Object key order within a key segment does not matter. `{ a: 1, b: 2 }` and `{ b: 2, a: 1 }` are treated as equal.
- Array element order does matter. Position is significant.

---

### Key Structure Conventions

TanStack Query does not enforce any key structure. The conventions below are widely used and aid maintainability, but they are not required.

#### Hierarchical Nesting

A common pattern is to go from most general to most specific:

```ts
['todos']                            // all todos
['todos', 'list']                    // todo lists (as distinct from detail)
['todos', 'list', { status: 'active' }]  // filtered list
['todos', 'detail', 42]             // single todo by id
```

This structure allows hierarchical invalidation. Invalidating `['todos']` matches all of the above.

#### Factory Functions

Defining keys through factory functions keeps them consistent and refactorable:

```ts
const todoKeys = {
  all: () => ['todos'] as const,
  lists: () => ['todos', 'list'] as const,
  list: (filters: TodoFilters) => ['todos', 'list', filters] as const,
  details: () => ['todos', 'detail'] as const,
  detail: (id: number) => ['todos', 'detail', id] as const,
}

// Usage
useQuery({ queryKey: todoKeys.detail(42), queryFn: () => fetchTodo(42) })
useQuery({ queryKey: todoKeys.list({ status: 'active' }), queryFn: fetchTodos })

// Invalidation
queryClient.invalidateQueries({ queryKey: todoKeys.all() })
```

**Key Points:**
- `as const` narrows the TypeScript type from `string[]` to a readonly tuple, enabling more precise type inference downstream.
- Factory functions act as a single source of truth. Renaming or restructuring a key happens in one place.

---

### Key Matching for Invalidation and Queries

Several `QueryClient` methods accept a `queryKey` for matching against the cache. The matching behavior is not exact by default — it is prefix-based.

```ts
// Matches: ['todos'], ['todos', 'list'], ['todos', 'detail', 42], etc.
queryClient.invalidateQueries({ queryKey: ['todos'] })

// Matches only: ['todos', 'detail', 42]
queryClient.invalidateQueries({ queryKey: ['todos', 'detail', 42], exact: true })
```

<svg viewBox="0 0 660 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12.5">
  <rect width="660" height="340" fill="#1e1e2e" rx="10"/>

  <text x="30" y="36" fill="#cba6f7" font-weight="bold" font-size="14">Prefix Matching — invalidateQueries({ queryKey: ['todos'] })</text>
  <line x1="20" y1="48" x2="640" y2="48" stroke="#45475a" stroke-width="1"/>

  <!-- Row headers -->
  <text x="30" y="72" fill="#89dceb" font-weight="bold">Cache Key</text>
  <text x="460" y="72" fill="#89dceb" font-weight="bold">Matched?</text>
  <line x1="20" y1="82" x2="640" y2="82" stroke="#313244" stroke-width="1"/>

  <!-- Rows -->
  <text x="30" y="106" fill="#cdd6f4">['todos']</text>
  <text x="460" y="106" fill="#a6e3a1">✓ yes</text>

  <text x="30" y="138" fill="#cdd6f4">['todos', 'list']</text>
  <text x="460" y="138" fill="#a6e3a1">✓ yes</text>

  <text x="30" y="170" fill="#cdd6f4">['todos', 'list', { status: 'active' }]</text>
  <text x="460" y="170" fill="#a6e3a1">✓ yes</text>

  <text x="30" y="202" fill="#cdd6f4">['todos', 'detail', 42]</text>
  <text x="460" y="202" fill="#a6e3a1">✓ yes</text>

  <text x="30" y="234" fill="#cdd6f4">['todo']</text>
  <text x="460" y="234" fill="#f38ba8">✗ no — different root</text>

  <text x="30" y="266" fill="#cdd6f4">['users']</text>
  <text x="460" y="266" fill="#f38ba8">✗ no — different root</text>

  <line x1="20" y1="280" x2="640" y2="280" stroke="#313244" stroke-width="1"/>
  <text x="30" y="308" fill="#6c7086">exact: true would match only ['todos'] exactly</text>
</svg>

**Key Points:**
- Prefix matching applies to: `invalidateQueries`, `removeQueries`, `resetQueries`, `refetchQueries`, `cancelQueries`, `setQueriesData`.
- `exact: true` restricts matching to keys that are identical to the provided key, with no additional segments.
- [Inference] Hierarchical key structures are specifically designed to make prefix-based invalidation useful. Flat keys (e.g., all keys at the same level) lose this benefit. Behavior may vary.

---

### Dynamic Keys

When query behavior depends on variables, those variables belong in the key:

```ts
// User-specific data
useQuery({
  queryKey: ['profile', userId],
  queryFn: () => fetchProfile(userId),
})

// Paginated list
useQuery({
  queryKey: ['todos', { page, pageSize }],
  queryFn: () => fetchTodos({ page, pageSize }),
})

// Combined filters
useQuery({
  queryKey: ['todos', { status, assignee, dueBefore }],
  queryFn: () => fetchTodos({ status, assignee, dueBefore }),
})
```

**Key Points:**
- Every variable used inside `queryFn` that could affect the response should appear in the key. If it affects the result, it belongs in the key.
- [Inference] Omitting variables from the key while using them in `queryFn` is likely to cause cache collisions — different inputs returning the same cache entry. Behavior depends on timing and render order.

---

### Stable vs Unstable Keys

Keys should be stable across renders when the underlying data has not changed.

**Unstable — new object reference every render:**

```ts
useQuery({
  // This object is re-created every render — but key comparison is by value,
  // so TanStack Query still treats it as the same key
  queryKey: ['todos', { status: 'active' }],
  queryFn: fetchTodos,
})
```

> [Inference] Because TanStack Query compares keys by serialized value rather than reference, re-creating an object literal in the key on each render is unlikely to cause duplicate fetches on its own. However, if the object contains values derived from unstable references (e.g., a new array created each render), those values may compare differently. Behavior may vary.

---

### Keys and TypeScript

With TypeScript, factory functions and `as const` provide type safety:

```ts
const userKeys = {
  all: () => ['users'] as const,
  detail: (id: string) => ['users', 'detail', id] as const,
}

// The queryKey type is inferred as readonly ['users', 'detail', string]
useQuery({
  queryKey: userKeys.detail(userId),
  queryFn: () => fetchUser(userId),
})
```

TanStack Query v5 introduced improved generics. The `queryKey` type flows into `queryFn`'s context argument:

```ts
useQuery({
  queryKey: ['todo', id] as const,
  queryFn: ({ queryKey }) => {
    const [, todoId] = queryKey  // todoId is typed as number if id is number
    return fetchTodo(todoId)
  },
})
```

> [Inference] Type inference from `queryKey` into `queryFn` context depends on the TypeScript version and how the key is typed. `as const` is generally required for narrow inference. Verify behavior against your environment.

---

### Keys Across Multiple Hooks

Multiple `useQuery` calls with the same key share one cache entry. They all receive the same data and trigger only one network request when behavior is otherwise equal.

```ts
// Component A
useQuery({ queryKey: ['todos'], queryFn: fetchTodos })

// Component B — same key, same cache entry
useQuery({ queryKey: ['todos'], queryFn: fetchTodos })
```

**Key Points:**
- Only one request is made when both components mount simultaneously.
- If one component's configuration differs (e.g., different `staleTime`), the configuration of the first observer registered is typically used for the shared entry. [Inference] This may produce unexpected behavior when the same key is used with meaningfully different options across components. Behavior may vary — verify against the version in use.

---

### Summary

| Concept | Detail |
|---|---|
| Key format | Always an array; contains any serializable values |
| Comparison | By value, not reference; object key order is ignored |
| Array order | Significant — position of elements affects key identity |
| Prefix matching | Default for `invalidateQueries` and related methods |
| `exact: true` | Restricts matching to exact key equality |
| Dynamic variables | All `queryFn` inputs that affect results belong in the key |
| Factory functions | Recommended pattern for consistency and refactorability |
| Shared keys | Multiple hooks with the same key share one cache entry |