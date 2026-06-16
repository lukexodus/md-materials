## Path Parameters in TanStack Router

---

### What Are Path Parameters?

Path parameters are dynamic segments within a route's path that capture a portion of the URL as a named variable. Instead of matching a single fixed URL, a route with path parameters matches a pattern — any URL conforming to that pattern is a valid match, and the captured values are made available to the route's component, loader, and other lifecycle functions.

**Key Points:**

- Path parameters are declared with a `:` prefix in the path string: `path: 'users/$userId'` or `path: 'users/:userId'`
- TanStack Router uses the `$` prefix convention in file-based routing; `:` is used in code-based routing path strings
- Captured values are always strings at the URL level — type coercion is the developer's responsibility
- Parameters are scoped to the route that declares them, but are accessible to all descendants via the router's type system

---

### Declaring Path Parameters

#### File-Based Routing

In file-based routing, dynamic segments are indicated by prefixing the filename segment with `$`.

```
src/routes/
  users/
    $userId.tsx          → matches /users/anything
    $userId/
      index.tsx          → matches /users/anything exactly
      posts/
        $postId.tsx      → matches /users/anything/posts/anything
```

The `$` in the filename becomes the parameter name. The route `/users/$userId/posts/$postId` captures two parameters: `userId` and `postId`.

**`users/$userId.tsx`:**

tsx

```tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/users/$userId')({
  component: UserProfile,
})

function UserProfile() {
  const { userId } = Route.useParams()
  return <div>Viewing user: {userId}</div>
}
```

#### Code-Based Routing

In code-based routing, dynamic segments use the `:param` syntax in the `path` string.

ts

```ts
const userRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: 'users/$userId',     // $ syntax also accepted in some versions
  component: UserProfile,
})
```

> [Inference] TanStack Router's code-based routing accepts both `$param` and `:param` syntax for dynamic segments in recent versions, but the canonical documented form may differ by version. Verify against your installed version's documentation.

---

### Accessing Parameters: `useParams`

The primary way to read path parameters in a component is `Route.useParams()`. This returns a typed object containing all parameters matched by the current route and its ancestors.

tsx

```tsx
// users/$userId.tsx
export const Route = createFileRoute('/users/$userId')({
  component: UserProfile,
})

function UserProfile() {
  const { userId } = Route.useParams()

  return <p>User ID: {userId}</p>
}
```

**Using the global `useParams` hook:**

TanStack Router also exports a standalone `useParams` from `@tanstack/react-router`. When used outside a route component, you must specify which route's params to read.

tsx

```tsx
import { useParams } from '@tanstack/react-router'

function SomeDeepComponent() {
  const { userId } = useParams({ from: '/users/$userId' })
  return <span>{userId}</span>
}
```

**Key Points:**

- `Route.useParams()` is preferred within a route's own component tree — it is fully type-safe without additional configuration
- The `from` option in the global `useParams` narrows the type to the specific route's param shape
- All parameter values are `string` at runtime regardless of what they represent semantically

---

### Parameters in Loaders

Path parameters are available inside a route's `loader` function via the `params` argument. This is the standard pattern for fetching data keyed to a dynamic segment.

tsx

```tsx
export const Route = createFileRoute('/users/$userId')({
  loader: async ({ params }) => {
    const user = await fetchUser(params.userId)
    return { user }
  },
  component: UserProfile,
})

function UserProfile() {
  const { user } = Route.useLoaderData()
  return <h1>{user.name}</h1>
}
```

**Key Points:**

- `params` in the loader is typed to match the route's declared path parameters
- The loader runs before the component renders, so data is available immediately on mount
- Navigating from `/users/1` to `/users/2` triggers the loader again with the new `userId` value — the component re-renders with fresh data

> Loader re-execution behavior on param change depends on router configuration and caching settings. Behavior may vary.

---

### Parameters in `beforeLoad`

`beforeLoad` also receives `params`, making it suitable for auth checks or redirects that depend on the dynamic segment.

tsx

```tsx
export const Route = createFileRoute('/users/$userId')({
  beforeLoad: async ({ params, context }) => {
    const canView = await context.authService.canViewUser(params.userId)
    if (!canView) {
      throw redirect({ to: '/forbidden' })
    }
  },
  component: UserProfile,
})
```

---

### Multiple Parameters and Nested Routes

Multiple dynamic segments can exist within a single route path, or be distributed across a nested route hierarchy. Parameters from ancestor routes are merged and available to descendants.

#### Single route, multiple segments

```
src/routes/
  orgs/
    $orgId/
      repos/
        $repoId.tsx      → matches /orgs/:orgId/repos/:repoId
```

tsx

```tsx
export const Route = createFileRoute('/orgs/$orgId/repos/$repoId')({
  loader: async ({ params }) => {
    // params.orgId and params.repoId both available
    return fetchRepo(params.orgId, params.repoId)
  },
  component: RepoPage,
})

function RepoPage() {
  const { orgId, repoId } = Route.useParams()
  return <p>{orgId} / {repoId}</p>
}
```

#### Parameters across nested routes

When parameters are declared at different levels of the route tree, child routes inherit ancestor parameters.

```
src/routes/
  orgs/
    $orgId.tsx           → captures orgId
    $orgId/
      repos/
        $repoId.tsx      → captures repoId; orgId also available
```

tsx

```tsx
// orgs/$orgId/repos/$repoId.tsx
export const Route = createFileRoute('/orgs/$orgId/repos/$repoId')({
  component: RepoPage,
})

function RepoPage() {
  // Both orgId (from ancestor) and repoId (from this route) are available
  const { orgId, repoId } = Route.useParams()
  return <p>{orgId} / {repoId}</p>
}
```

**Key Points:**

- Parameter names must be unique across the ancestor chain — two routes in the same lineage cannot both declare `$id`
- [Inference] Duplicate parameter names in the same path chain would cause one to shadow the other; TanStack Router may warn about this in development mode, but behavior is not guaranteed to be consistent across versions

---

### Linking to Parameterized Routes

The `<Link>` component accepts a `params` prop for routes that contain dynamic segments. This is type-safe — TypeScript will require the correct parameter names and reject missing ones.

tsx

```tsx
import { Link } from '@tanstack/react-router'

function UserList({ users }) {
  return (
    <ul>
      {users.map((user) => (
        <li key={user.id}>
          <Link
            to="/users/$userId"
            params={{ userId: user.id }}
          >
            {user.name}
          </Link>
        </li>
      ))}
    </ul>
  )
}
```

**Navigating programmatically:**

tsx

```tsx
import { useNavigate } from '@tanstack/react-router'

function SomeComponent() {
  const navigate = useNavigate()

  const handleSelect = (userId: string) => {
    navigate({
      to: '/users/$userId',
      params: { userId },
    })
  }

  return <button onClick={() => handleSelect('42')}>Go to user 42</button>
}
```

**Key Points:**

- Passing `params` to `<Link>` or `navigate` is required when the target route contains dynamic segments
- TypeScript enforces the shape of `params` at compile time when route types are generated — missing or misspelled keys produce type errors
- Numeric IDs must be converted to strings, since URL params are always strings

---

### Parameter Validation and Parsing

Raw path parameters arrive as strings. TanStack Router allows you to validate and transform them using the `params` option on a route definition. This is analogous to search param validation but applied to path segments.

tsx

```tsx
import { createFileRoute } from '@tanstack/react-router'
import { z } from 'zod'

export const Route = createFileRoute('/users/$userId')({
  params: {
    parse: (params) => ({
      userId: z.string().uuid().parse(params.userId),
    }),
    stringify: (params) => ({
      userId: params.userId,
    }),
  },
  component: UserProfile,
})
```

**Key Points:**

- `parse` runs when the route is matched; if parsing throws, the route does not render and an error boundary is triggered
- `stringify` is used when generating links — it converts the typed param back to a URL string
- This pattern allows treating `userId` as a validated UUID rather than an arbitrary string throughout the route
- [Inference] The `params` validation API surface may differ between minor versions. Verify the exact option names and behavior in your version's documentation.

---

### Splat / Catch-All Parameters

A splat parameter (`$` alone, or `*` in some configurations) captures the remainder of the URL after a given point, including slashes. This is useful for file-path-style routing or catch-all pages.

```
src/routes/
  files/
    $.tsx               → matches /files/, /files/a, /files/a/b/c, etc.
```

tsx

```tsx
export const Route = createFileRoute('/files/$')({
  component: FileBrowser,
})

function FileBrowser() {
  const params = Route.useParams()
  // The splat value is available as params['*'] or params._splat depending on version
  return <p>Path: {params['*']}</p>
}
```

> [Unverified] The exact key used to access the splat value (`'*'`, `'_splat'`, or another name) may differ between TanStack Router versions. Consult your version's documentation to confirm the correct accessor. Behavior is not guaranteed to be consistent across versions.

---

### Visual: Parameter Matching Across a Route Tree

<svg viewBox="0 0 660 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="660" height="420" fill="#0f1117" rx="12"/>
<!-- Title -->

<text x="30" y="30" fill="`#718096`" font-size="11">ROUTE TREE → URL MATCHING → PARAMS AVAILABLE</text>
<line x1="20" y1="38" x2="640" y2="38" stroke="`#2d3148`" stroke-width="1"/>

<!-- Row headers -->

<text x="30" y="58" fill="`#718096`" font-size="10">ROUTE FILE</text>
<text x="230" y="58" fill="`#718096`" font-size="10">MATCHES URL</text>
<text x="420" y="58" fill="`#718096`" font-size="10">PARAMS AVAILABLE</text>

<!-- Row 1 -->
<rect x="20" y="66" width="190" height="32" rx="4" fill="#1e2230" stroke="#4f6ef7" stroke-width="1"/>
<text x="115" y="87" text-anchor="middle" fill="#a0aec0">users/$userId.tsx</text>

<text x="220" y="87" fill="`#718096`">→</text>

<rect x="230" y="66" width="170" height="32" rx="4" fill="#1e2230" stroke="#2d3148" stroke-width="1"/>
<text x="315" y="87" text-anchor="middle" fill="#e2e8f0">/users/42</text>
<rect x="420" y="66" width="220" height="32" rx="4" fill="#1a2040" stroke="#f6ad55" stroke-width="1"/>
<text x="530" y="87" text-anchor="middle" fill="#f6ad55">userId: "42"</text>
<!-- Row 2 -->
<rect x="20" y="112" width="190" height="32" rx="4" fill="#1e2230" stroke="#4f6ef7" stroke-width="1"/>
<text x="115" y="133" text-anchor="middle" fill="#a0aec0">orgs/$orgId/repos/$repoId</text>

<text x="220" y="133" fill="`#718096`">→</text>

<rect x="230" y="112" width="170" height="32" rx="4" fill="#1e2230" stroke="#2d3148" stroke-width="1"/>
<text x="315" y="133" text-anchor="middle" fill="#e2e8f0">/orgs/acme/repos/core</text>
<rect x="420" y="112" width="220" height="32" rx="4" fill="#1a2040" stroke="#f6ad55" stroke-width="1"/>
<text x="530" y="128" text-anchor="middle" fill="#f6ad55">orgId: "acme"</text>
<text x="530" y="142" text-anchor="middle" fill="#f6ad55">repoId: "core"</text>
<!-- Row 3: splat -->
<rect x="20" y="162" width="190" height="32" rx="4" fill="#1e2230" stroke="#4f6ef7" stroke-width="1"/>
<text x="115" y="183" text-anchor="middle" fill="#a0aec0">files/$.tsx</text>

<text x="220" y="183" fill="`#718096`">→</text>

<rect x="230" y="162" width="170" height="32" rx="4" fill="#1e2230" stroke="#2d3148" stroke-width="1"/>
<text x="315" y="183" text-anchor="middle" fill="#e2e8f0">/files/docs/api/intro</text>
<rect x="420" y="162" width="220" height="32" rx="4" fill="#1a2040" stroke="#f6ad55" stroke-width="1"/>
<text x="530" y="183" text-anchor="middle" fill="#f6ad55">\*: "docs/api/intro"</text>
<!-- Row 4: no match -->
<rect x="20" y="208" width="190" height="32" rx="4" fill="#1e2230" stroke="#4f6ef7" stroke-width="1"/>
<text x="115" y="229" text-anchor="middle" fill="#a0aec0">users/$userId.tsx</text>

<text x="220" y="229" fill="`#718096`">→</text>

<rect x="230" y="208" width="170" height="32" rx="4" fill="#1e2230" stroke="#2d3148" stroke-width="1"/>
<text x="315" y="229" text-anchor="middle" fill="#e2e8f0">/users/42/settings</text>
<rect x="420" y="208" width="220" height="32" rx="4" fill="#1a2040" stroke="#fc8181" stroke-width="1"/>
<text x="530" y="229" text-anchor="middle" fill="#fc8181">NO MATCH (too deep)</text>
<!-- Divider -->
<line x1="20" y1="258" x2="640" y2="258" stroke="#2d3148" stroke-width="1"/>
<!-- Notes -->

<text x="30" y="280" fill="`#718096`" font-size="11">NOTES</text>
<text x="30" y="300" fill="`#a0aec0`" font-size="11">• Static segments take precedence over dynamic segments at the same level.</text>
<text x="30" y="318" fill="`#a0aec0`" font-size="11">• Dynamic segments match exactly one path token (no slashes).</text>
<text x="30" y="336" fill="`#a0aec0`" font-size="11">• Splat ($) matches zero or more tokens including slashes.</text>
<text x="30" y="354" fill="`#a0aec0`" font-size="11">• All captured values are strings at runtime.</text>

<!-- Legend -->
<rect x="20" y="374" width="620" height="34" rx="6" fill="#1a1d2e" stroke="#2d3148" stroke-width="1"/>
<rect x="40" y="387" width="10" height="10" rx="2" fill="#4f6ef7"/>
<text x="56" y="397" fill="#a0aec0" font-size="11">Route file</text>
<rect x="160" y="387" width="10" height="10" rx="2" fill="#f6ad55"/>
<text x="176" y="397" fill="#a0aec0" font-size="11">Captured params</text>
<rect x="320" y="387" width="10" height="10" rx="2" fill="#fc8181"/>
<text x="336" y="397" fill="#a0aec0" font-size="11">No match</text>
</svg>

---

### Route Specificity and Matching Priority

When multiple routes could match a URL, TanStack Router applies a specificity ranking. Static segments outrank dynamic segments at the same position.

```
/users/me           ← static route: always wins over /users/$userId for this URL
/users/$userId      ← dynamic route: matches any other value
```

**Key Points:**

- Define static routes (e.g., `/users/me`, `/users/new`) alongside dynamic routes — the router resolves the more specific match automatically
- Splat routes have the lowest specificity and match only when nothing else does
- [Inference] Route specificity rules are applied by TanStack Router's internal matching algorithm; the exact algorithm details may not be fully documented and could differ between versions. Behavior should be verified with integration tests in your application.

---

### Type Safety with Generated Route Types

When using the TanStack Router Vite plugin or CLI, route types are auto-generated. This means `params` objects throughout your application are fully typed — you cannot pass an invalid param name to `<Link>`, `navigate`, or `useParams`.

tsx

```tsx
// TypeScript will error if userId is missing or misnamed
<Link to="/users/$userId" params={{ userId: '42' }}>  {/* ✓ */}
<Link to="/users/$userId" params={{ id: '42' }}>       {/* ✗ type error */}
<Link to="/users/$userId">                             {/* ✗ type error: params required */}
```

**Key Points:**

- Type generation requires the Vite plugin or `tsr generate` CLI command to run during development
- Without generated types, the router still functions but loses compile-time param validation
- The generated `routeTree.gen.ts` file should not be manually edited — it is overwritten on each generation pass

---

### Common Mistakes

**Treating param values as non-strings**
Path parameters are always strings. Comparing `userId === 42` (number) will always be false. Parse or coerce the value explicitly: `Number(userId)` or validate with Zod.

**Duplicate parameter names in the same ancestry chain**
Declaring `$id` at both `/users/$id` and `/users/$id/posts/$id` creates a name collision. Use distinct names like `$userId` and `$postId`.

**Linking without `params`**
Providing a `to` that contains a dynamic segment without passing `params` will throw a runtime error (and a type error if types are generated). Always supply `params` when navigating to parameterized routes.

**Using `useParams` without `from` outside the route**
Calling the global `useParams()` without a `from` option in a component that is not a direct child of the matched route returns a wider, less-typed object. Prefer `Route.useParams()` inside route components.

---

**Related Topics:**

- Search params validation with Zod (`validateSearch`)
- Loader data fetching patterns keyed to path params
- `notFoundComponent` for invalid param values that return 404s
- Parallel loaders across nested parameterized routes
- `<Link>` `params` and `search` together for compound navigation
- Splat routes and file-browser style UIs
- Route masks and URL aliasing
- Type-safe navigation with generated route types