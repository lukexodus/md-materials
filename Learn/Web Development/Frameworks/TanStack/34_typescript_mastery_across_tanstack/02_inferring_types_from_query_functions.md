## Inferring Types from Query Functions

TypeScript's type inference system can automatically derive the shape of your data from query functions, reducing the need for manual type annotations while maintaining full type safety throughout your TanStack Query code.

---

### How TanStack Query Uses Query Function Return Types

TanStack Query's `useQuery` hook is generic. Its type parameters control what TypeScript knows about the data returned from your query. When you provide a typed query function, TypeScript can infer the `data` type automatically without explicit annotation.

**Key Points**
- `useQuery` has the signature `useQuery<TData, TError, TSelectData, TQueryKey>`
- When `queryFn` returns a typed value, TypeScript infers `TData` from it
- The `data` property on the query result reflects that inferred type
- Behavior may vary depending on TypeScript version and strictness settings [Inference]

---

### Basic Inference from an Async Function

The simplest form of inference happens when your query function is a typed async function.

```ts
import { useQuery } from '@tanstack/react-query'

interface User {
  id: number
  name: string
  email: string
}

async function fetchUser(id: number): Promise<User> {
  const res = await fetch(`/api/users/${id}`)
  return res.json()
}

function UserProfile({ id }: { id: number }) {
  const { data } = useQuery({
    queryKey: ['user', id],
    queryFn: () => fetchUser(id),
  })

  // data is inferred as: User | undefined
  return <div>{data?.name}</div>
}
```

**Key Points**
- `fetchUser` returns `Promise<User>`, so `data` is inferred as `User | undefined`
- No explicit generic annotation on `useQuery` is needed
- `undefined` is included because data is absent before the query resolves

---

### Inference from Inline Query Functions

If the query function is defined inline, TypeScript infers from the return expression directly.

```ts
const { data } = useQuery({
  queryKey: ['products'],
  queryFn: async () => {
    const res = await fetch('/api/products')
    const json = await res.json()
    return json as Product[]
  },
})

// data: Product[] | undefined
```

**Key Points**
- The `as Product[]` cast is necessary here because `res.json()` returns `any`
- Without the cast, `data` would be inferred as `any`, losing type safety
- Prefer a typed fetch wrapper or a validation library (e.g., Zod) over raw `as` casts when accuracy matters

---

### The Role of `res.json()` Returning `any`

A common source of inference breakdown is the native `fetch` API. `Response.prototype.json()` has the return type `Promise<any>` in TypeScript's DOM lib. This means inference silently degrades unless you explicitly type the result.

```ts
// ❌ data is inferred as any — type safety is lost
const { data } = useQuery({
  queryKey: ['items'],
  queryFn: async () => {
    const res = await fetch('/api/items')
    return res.json() // returns Promise<any>
  },
})

// ✅ Restore inference with an explicit return type
async function fetchItems(): Promise<Item[]> {
  const res = await fetch('/api/items')
  return res.json()
}
```

By annotating the function return type, you force TypeScript to verify the shape at the function boundary, and inference flows correctly into `useQuery`.

---

### Using a Typed Fetch Wrapper

A reusable typed fetch helper centralizes the casting and keeps query functions clean.

```ts
async function fetchJson<T>(url: string): Promise<T> {
  const res = await fetch(url)
  if (!res.ok) throw new Error(`Request failed: ${res.status}`)
  return res.json() as Promise<T>
}

// Inference flows from the generic parameter
const { data } = useQuery({
  queryKey: ['orders'],
  queryFn: () => fetchJson<Order[]>('/api/orders'),
})

// data: Order[] | undefined
```

**Key Points**
- The generic `T` is provided at the call site, propagating into `useQuery`'s inference
- Error handling is centralized in one place
- This pattern does not validate the runtime shape of the response — a mismatch between `T` and actual API data will not be caught at runtime unless you add validation [Important]

---

### Inference with `select`

The `select` option transforms the raw query data. When used, `data` reflects the return type of the `select` function, not the original query function return type.

```ts
interface ApiResponse {
  users: User[]
  total: number
}

const { data } = useQuery({
  queryKey: ['users'],
  queryFn: () => fetchJson<ApiResponse>('/api/users'),
  select: (response) => response.users,
})

// data: User[] | undefined  ← inferred from select's return type
// NOT ApiResponse | undefined
```

**Key Points**
- `select` narrows or reshapes the data type visible to the component
- The full `ApiResponse` is still fetched and cached internally; only the exposed type changes
- TypeScript infers the `select` parameter type from the query function's return type, enabling safe property access

---

### Inference Across Query Key and Query Function with `queryOptions`

TanStack Query v5 introduced `queryOptions`, a helper that colocates query key and query function while preserving full inference.

```ts
import { queryOptions } from '@tanstack/react-query'

const userQueryOptions = (id: number) =>
  queryOptions({
    queryKey: ['user', id],
    queryFn: () => fetchUser(id),
  })

// Used in a component
const { data } = useQuery(userQueryOptions(42))
// data: User | undefined  ← inferred correctly

// Used in a loader (e.g., TanStack Router)
const user = await queryClient.ensureQueryData(userQueryOptions(42))
// user: User  ← non-undefined, since ensureQueryData resolves
```

**Key Points**
- `queryOptions` is a thin identity function; its value lies entirely in TypeScript inference and colocation
- The same options object can be passed to `useQuery`, `prefetchQuery`, `ensureQueryData`, and `fetchQuery` with consistent types
- This is the recommended approach in v5 for sharing query definitions across loaders and components [Inference — based on v5 documentation patterns]

---

### Explicit Generic Annotation vs. Inference

You can annotate generics manually on `useQuery` when inference is insufficient or ambiguous.

```ts
// Manual annotation — overrides inference
const { data } = useQuery<User, Error>({
  queryKey: ['user', 1],
  queryFn: () => fetchUser(1),
})

// data: User | undefined
// error: Error | null
```

**When to prefer manual annotation:**
- When the query function return type is `any` and a wrapper is not practical
- When you need to explicitly type the error (`TError`)
- When using a query function from a third-party source with unknown types

**When to prefer inference:**
- When the query function is fully typed and you control its definition
- To reduce annotation noise and rely on TypeScript's narrowing

---

### Common Inference Pitfalls

#### Union Return Types Widen `data`

```ts
async function fetchStatus(): Promise<'active' | 'inactive'> {
  return fetch('/api/status').then(r => r.json())
}

const { data } = useQuery({
  queryKey: ['status'],
  queryFn: fetchStatus,
})

// data: "active" | "inactive" | undefined ✅
```

This works correctly. However, if `res.json()` is used directly without the return type annotation, `data` becomes `any`.

#### Optional Chaining and `undefined`

Because `data` is always `T | undefined` before the query resolves, forgetting to handle the `undefined` case causes type errors.

```ts
// ❌ TypeScript error: data is possibly undefined
console.log(data.name)

// ✅ Safe access
console.log(data?.name)

// ✅ Also acceptable after an explicit check
if (data) {
  console.log(data.name)
}
```

#### `enabled: false` Does Not Change the Inferred Type

Disabling a query with `enabled: false` does not affect the TypeScript type of `data`. It remains `T | undefined` regardless. [Important — behavior depends on runtime state, not type-level information]

---

### Inference with TanStack Router Loaders

TanStack Router integrates with TanStack Query loaders. When `queryOptions` is used, types flow from the query function through the loader and into the route component.

```ts
// Route definition
export const Route = createFileRoute('/users/$id')({
  loader: ({ params, context: { queryClient } }) =>
    queryClient.ensureQueryData(userQueryOptions(Number(params.id))),

  component: function UserPage() {
    const user = Route.useLoaderData()
    // user: User  ← fully inferred, non-undefined
    return <div>{user.name}</div>
  },
})
```

**Key Points**
- `ensureQueryData` returns `Promise<T>` (not `Promise<T | undefined>`), so `useLoaderData` gives a non-optional type
- This removes the need for null checks in the component when data is guaranteed by the loader
- Actual runtime behavior depends on network conditions and error boundaries — types reflect the happy path [Disclaimer: type-level guarantees do not reflect runtime reliability]

---

**Related Topics**
- Typing query errors with `TError` and custom error classes
- Using Zod with TanStack Query for runtime-validated inference
- `queryOptions` factory pattern for shared query definitions
- Typing `useInfiniteQuery` and inferring page shapes
- Inference in `useMutation` — input, output, and context types
- TanStack Router `loaderData` inference pipeline
- Discriminated union patterns for loading, error, and success states