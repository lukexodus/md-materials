## Strict Typing with TanStack Query

### Overview

TanStack Query is built with TypeScript-first design. When configured correctly, it provides end-to-end type safety from query functions through to consuming components — covering data shapes, error types, query keys, and enabled/disabled states. Achieving strict typing requires deliberate patterns; the defaults leave some gaps.

---

### Query Function Return Type Inference

TanStack Query infers the `data` type from the return type of `queryFn`. No explicit annotation is required if the function is typed.

```ts
async function fetchUser(id: number): Promise<User> {
  const res = await fetch(`/api/users/${id}`)
  if (!res.ok) throw new Error('Failed to fetch user')
  return res.json() as Promise<User>
}

const { data } = useQuery({
  queryKey: ['user', id],
  queryFn: () => fetchUser(id),
})
// data: User | undefined
```

**Key Points**
- `data` is `User | undefined` because TanStack Query cannot guarantee the query has resolved
- The `undefined` case represents the loading or idle state, not an error
- If you annotate `useQuery<User>` explicitly, the generic overrides inference — prefer letting inference work from the `queryFn` return type where possible

---

### The Five Type Parameters of `useQuery`

`useQuery` accepts up to five generic type parameters:

```ts
useQuery
  TQueryFnData,   // return type of queryFn
  TError,         // error type
  TData,          // type of data after select transform
  TQueryKey       // type of queryKey
>
```

In most cases you do not need to specify all of them — inference covers `TQueryFnData` and `TQueryKey` when the query function and key are properly typed. The two that commonly require explicit annotation are `TError` and `TData` (when using `select`).

```ts
const { data } = useQuery<User, AxiosError>({
  queryKey: ['user', id],
  queryFn: () => fetchUser(id),
})
// error: AxiosError | null
```

---

### Typing Errors: The `unknown` Default

By default, TanStack Query types `error` as `unknown`. This is intentional — JavaScript `throw` accepts any value, so the error type cannot be safely inferred.

```ts
const { error } = useQuery({
  queryKey: ['user', id],
  queryFn: fetchUser,
})
// error: unknown — must be narrowed before use
```

**Narrowing errors manually:**

```ts
if (error instanceof Error) {
  console.log(error.message) // safe
}
```

**Setting a global error type:**

TanStack Query v5 allows setting a default error type via module augmentation, so you do not need to annotate `TError` on every query:

```ts
// src/types/tanstack-query.d.ts
import '@tanstack/react-query'

declare module '@tanstack/react-query' {
  interface Register {
    defaultError: AxiosError
  }
}
```

After this declaration, `error` is typed as `AxiosError` across all queries in the project without per-call annotation. [Inference] This is the recommended approach for projects with a consistent error type — behavior applies only within the TypeScript type system and does not affect runtime error handling.

---

### Typing Query Keys

Untyped query keys (`string[]` or `unknown[]`) prevent TypeScript from catching key shape errors. TanStack Query v5 introduced the `queryOptions` helper, which binds keys to their associated data type.

**`queryOptions` helper:**

```ts
import { queryOptions } from '@tanstack/react-query'

const userQueryOptions = queryOptions({
  queryKey: ['user', id] as const,
  queryFn: () => fetchUser(id),
})

// Reuse across useQuery, prefetchQuery, fetchQuery, ensureQueryData
const { data } = useQuery(userQueryOptions)
// data: User | undefined — inferred from queryFn
```

**Key Points**
- `queryOptions` centralizes the key-to-data binding, preventing drift between call sites
- The same options object is accepted by `queryClient.prefetchQuery`, `queryClient.fetchQuery`, `queryClient.ensureQueryData`, and `useQuery`
- Using `as const` on the key tuple preserves literal types, enabling more precise key matching in `invalidateQueries` and `setQueryData`

---

### Typed Query Key Factories

For large applications with many query keys, a factory pattern provides structured, typed key generation:

```ts
const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (filters: UserFilters) => [...userKeys.lists(), filters] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: number) => [...userKeys.details(), id] as const,
}

// Usage
useQuery({
  queryKey: userKeys.detail(42),      // readonly ['users', 'detail', 42]
  queryFn: () => fetchUser(42),
})

queryClient.invalidateQueries({ queryKey: userKeys.lists() })
```

[Inference] The `as const` assertions cause TypeScript to infer tuple types rather than `string[]`, which enables narrower matching in `setQueryData` and `getQueryData`. Whether this prevents all key mismatches depends on consistent use of the factory — ad-hoc key construction at any call site bypasses the typing.

---

### Typed `setQueryData` and `getQueryData`

`QueryClient` methods that read or write cache data accept a query key. Without `queryOptions`, the return type defaults to `unknown`.

**With `queryOptions`:**

```ts
const userQuery = queryOptions({
  queryKey: userKeys.detail(42),
  queryFn: () => fetchUser(42),
})

// setQueryData is typed to accept User
queryClient.setQueryData(userQuery.queryKey, (old) => {
  // old: User | undefined
  return old ? { ...old, name: 'Updated' } : old
})

// getQueryData returns User | undefined
const user = queryClient.getQueryData(userQuery.queryKey)
```

Without `queryOptions`, you must provide the type explicitly:

```ts
queryClient.setQueryData<User>(userKeys.detail(42), updater)
```

---

### Typing `select` Transforms

The `select` option transforms `TQueryFnData` into `TData`. TypeScript infers the output type from the selector function's return type.

```ts
const { data } = useQuery({
  queryKey: userKeys.detail(42),
  queryFn: () => fetchUser(42),
  select: (user) => user.name, // data: string | undefined
})
```

When `select` is conditional or complex, verify the inferred type explicitly:

```ts
const { data } = useQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
  select: (posts): PostSummary[] =>
    posts.map(({ id, title }) => ({ id, title })),
})
// data: PostSummary[] | undefined
```

[Inference] If the `select` return type annotation is omitted and the function body is ambiguous, TypeScript may infer a broader type (e.g., `(string | number)[]`). Explicit return type annotations on `select` functions prevent this and serve as documentation.

---

### Typing `useMutation`

`useMutation` accepts three type parameters: the data returned, the error type, and the variables type.

```ts
const mutation = useMutation
  User,           // TData: what mutationFn resolves to
  AxiosError,     // TError
  CreateUserInput // TVariables: argument to mutationFn
>({
  mutationFn: (input) => createUser(input),
})

mutation.mutate({ name: 'Luke', email: 'luke@example.com' })
// input is typed as CreateUserInput
// mutation.data is User | undefined
// mutation.error is AxiosError | null
```

A fourth parameter `TContext` types the value returned by `onMutate` (used in optimistic updates):

```ts
useMutation<User, AxiosError, CreateUserInput, { previousUsers: User[] }>({
  mutationFn: createUser,
  onMutate: async (newUser) => {
    const previousUsers = queryClient.getQueryData<User[]>(userKeys.lists())
    return { previousUsers: previousUsers ?? [] }
  },
  onError: (_err, _vars, context) => {
    // context: { previousUsers: User[] } | undefined
    if (context) {
      queryClient.setQueryData(userKeys.lists(), context.previousUsers)
    }
  },
})
```

---

### Typing `useInfiniteQuery`

`useInfiniteQuery` adds a `pageParam` type to the query function signature:

```ts
const { data } = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }: { pageParam: number }) => fetchPostsPage(pageParam),
  initialPageParam: 0,
  getNextPageParam: (lastPage, _allPages, lastPageParam): number | undefined =>
    lastPage.hasMore ? lastPageParam + 1 : undefined,
})

// data: InfiniteData<PostsPage> | undefined
// data.pages: PostsPage[]
// data.pageParams: number[]
```

**Key Points**
- `initialPageParam` is required in v5 and its type determines `pageParam`'s type throughout
- `getNextPageParam` return type should include `undefined` (signals no more pages) — TypeScript will warn if this is omitted
- `data.pages` is an array of `TQueryFnData`, not a flat array — flatten explicitly if needed

---

### Enabled Queries and Type Narrowing

When a query depends on a value that may be `undefined`, the `enabled` option prevents it from running. However, TypeScript still considers `data` potentially undefined even with `enabled`.

```ts
function useUserPosts(userId: number | undefined) {
  return useQuery({
    queryKey: userKeys.detail(userId!),
    queryFn: () => fetchUserPosts(userId!),
    enabled: userId !== undefined,
  })
}
```

The non-null assertion (`!`) is necessary because TypeScript does not propagate `enabled` into query function type narrowing. [Inference] This is a known gap — the query function type is evaluated independently of the `enabled` condition. A type-safe alternative is to define two separate hooks or use a wrapper that only calls `useQuery` when the dependency is defined.

**Type-safe wrapper pattern:**

```ts
function useUserPosts(userId: number) {
  return useQuery({
    queryKey: userKeys.detail(userId),
    queryFn: () => fetchUserPosts(userId),
  })
}

// At call site — caller is responsible for guarding
if (userId !== undefined) {
  useUserPosts(userId) // userId is number here
}
```

[Inference] This pattern moves the narrowing responsibility to the call site, which TypeScript can enforce. Whether this is preferable to the non-null assertion depends on how many call sites exist and the team's conventions.

---

### Global Registration: Typed `QueryClient`

Beyond error types, TanStack Query v5's `Register` interface supports typed `queryMeta` and `mutationMeta`:

```ts
declare module '@tanstack/react-query' {
  interface Register {
    defaultError: AxiosError
    queryMeta: {
      cacheControl?: string
      description?: string
    }
    mutationMeta: {
      successMessage?: string
      errorMessage?: string
    }
  }
}
```

This ensures that `meta` objects on queries and mutations conform to a known shape project-wide, rather than being typed as `Record<string, unknown>`.

---

### Strict Typing Checklist

| Area | Technique |
|---|---|
| Query data type | Infer from typed `queryFn` return |
| Error type | Module augmentation via `Register.defaultError` |
| Query keys | `queryOptions` helper + key factories with `as const` |
| Cache reads/writes | `getQueryData` / `setQueryData` via `queryOptions` |
| Mutations | Explicit `TData`, `TError`, `TVariables`, `TContext` generics |
| Infinite queries | Type `initialPageParam`; include `undefined` in `getNextPageParam` |
| Dependent queries | Non-null assertion in `queryFn` with `enabled` guard |
| Meta fields | Module augmentation via `Register.queryMeta` / `mutationMeta` |

---

**Related Topics**
- `queryOptions` factory pattern and colocation with API modules
- Typed query key factories at scale
- Module augmentation patterns in TypeScript
- Optimistic updates with fully typed `TContext`
- Zod integration for runtime validation of `queryFn` responses
- `inferData` and `inferError` utility types in TanStack Query v5
- Type-safe prefetching with `router.context` in TanStack Router
- `skipToken` as a type-safe alternative to `enabled: false`