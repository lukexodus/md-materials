## Wildcard and Catch-All Routes in TanStack Router

---

### What Are Wildcard and Catch-All Routes?

A wildcard (catch-all) route is a route that matches any URL segment or sequence of segments that no other route in the tree has claimed. Where a dynamic parameter like `$userId` matches exactly one path token, a wildcard matches **zero or more tokens**, including slashes.

Wildcard routes serve two primary purposes:

- **Rendering 404 / not-found UI** when no other route matches
- **Delegating sub-path control** to a component that interprets the remaining URL itself (file browsers, documentation trees, embedded sub-apps)

**Key Points:**

- In TanStack Router file-based routing, a wildcard segment is represented by a file named `$.tsx`
- The captured remainder is available as a string containing everything after the matched prefix, including any slashes
- Wildcard routes have the lowest specificity — they match only after all other candidates at the same level have been exhausted
- A wildcard at the root level (`routes/$.tsx`) acts as a global catch-all for the entire application

---

### Declaring a Wildcard Route

#### File-Based Routing

Create a file named `$.tsx` at the level where you want catch-all behavior.

```
src/routes/
  __root.tsx
  index.tsx
  dashboard.tsx
  dashboard/
    index.tsx
    settings.tsx
  $.tsx                  → global catch-all: matches any unmatched URL
```

A scoped catch-all, contained to a sub-tree:

```
src/routes/
  docs/
    index.tsx            → matches /docs
    $.tsx                → matches /docs/anything/at/all/depths
```

**`$.tsx` (global 404):**

tsx

```tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/$')({
  component: NotFoundPage,
})

function NotFoundPage() {
  return (
    <div>
      <h1>404 — Page Not Found</h1>
      <p>The URL you requested does not exist.</p>
    </div>
  )
}
```

#### Code-Based Routing

ts

```ts
const catchAllRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '$',
  component: NotFoundPage,
})

const routeTree = rootRoute.addChildren([
  indexRoute,
  dashboardRoute,
  catchAllRoute,   // ← added last; specificity handles ordering
])
```

> [Inference] The order in which routes are added to `addChildren` may influence resolution in edge cases, though TanStack Router's specificity algorithm is intended to rank static routes above dynamic routes above wildcards regardless of declaration order. Verify behavior in your version.

---

### Accessing the Captured Value

The portion of the URL captured by the wildcard is available in both components and loaders. The key used to access it varies by version.

tsx

```tsx
export const Route = createFileRoute('/docs/$')({
  component: DocsPage,
})

function DocsPage() {
  const params = Route.useParams()

  // The splat value — key name depends on version; confirm in your environment
  const splatValue = params['*'] ?? params['_splat'] ?? ''

  return <p>Docs path: {splatValue}</p>
}
```

**In a loader:**

tsx

```tsx
export const Route = createFileRoute('/docs/$')({
  loader: async ({ params }) => {
    const splatPath = params['*'] ?? params['_splat'] ?? ''
    const content = await fetchDocPage(splatPath)
    return { content }
  },
  component: DocsPage,
})
```

> [Unverified] The exact key name for the splat value (`'*'`, `'_splat'`, or another identifier) is not consistent across all published versions of TanStack Router. Always verify the correct accessor in your installed version's documentation or type definitions. Behavior is not guaranteed to be identical across versions.

**Key Points:**

- The splat value does not include the leading slash of the captured segment
- If the wildcard matches nothing (e.g., the URL is exactly the parent path), the splat value is an empty string
- The value is a plain string — splitting on `'/'` produces the individual path tokens if needed

---

### Wildcard Specificity and Route Priority

TanStack Router ranks routes by specificity when multiple candidates could match a URL. Wildcards always lose to more specific alternatives at the same tree level.

```
/docs/intro          → matches docs/intro.tsx   (static — wins)
/docs/api            → matches docs/api.tsx      (static — wins)
/docs/anything/else  → matches docs/$.tsx        (wildcard — no static match exists)
```

**Specificity ranking (highest to lowest):**

1. Static segments (`/docs/intro`)
2. Dynamic segments (`/docs/$slug`)
3. Wildcard / splat (`/docs/$`)

This means you can safely co-locate a wildcard with static and dynamic siblings. The wildcard only activates when nothing else claims the URL.

```
src/routes/docs/
  index.tsx            → /docs
  intro.tsx            → /docs/intro         (static: wins over $slug and $)
  $slug.tsx            → /docs/:anything     (dynamic: wins over $)
  $.tsx                → /docs/a/b/c/d       (wildcard: only multi-segment misses)
```

---

### Global Not-Found Handling

TanStack Router provides a dedicated `notFoundComponent` option distinct from a wildcard route. Understanding when to use each is important.

#### `notFoundComponent` on a route

tsx

```tsx
// __root.tsx
export const Route = createRootRoute({
  component: RootLayout,
  notFoundComponent: () => (
    <div>
      <h1>404</h1>
      <p>This page does not exist.</p>
    </div>
  ),
})
```

`notFoundComponent` is triggered by TanStack Router's internal not-found signal — thrown via `notFound()` — rather than by URL matching. It renders inside the route's existing layout.

#### Wildcard `$.tsx` route

A wildcard route is a true route match. It participates in the route tree normally — it has its own component, loader, search params, and context access. It renders as a full route, including all ancestor layouts.

**Key Points:**

- Use `notFoundComponent` for in-layout 404 UI that shares the application shell
- Use a wildcard route when you need loader logic, full route lifecycle, or content that interprets the remaining URL
- Both approaches can coexist — `notFoundComponent` handles programmatically thrown not-founds; the wildcard handles genuinely unmatched URLs
- [Inference] If both a wildcard route and a `notFoundComponent` are defined, the wildcard route takes precedence for URL-based mismatches, since it is a legitimate route match. `notFoundComponent` would then only fire when `notFound()` is explicitly thrown. Confirm this interaction in your version.

---

### Throwing `notFound()` Manually

Within any route's `loader` or `beforeLoad`, you can throw `notFound()` to signal that the resource does not exist, even if the URL pattern matched.

tsx

```tsx
import { createFileRoute, notFound } from '@tanstack/react-router'

export const Route = createFileRoute('/users/$userId')({
  loader: async ({ params }) => {
    const user = await fetchUser(params.userId)
    if (!user) {
      throw notFound()
    }
    return { user }
  },
  component: UserProfile,
  notFoundComponent: () => <p>User not found.</p>,
})
```

**Key Points:**

- `notFound()` is separate from wildcard routing — it handles the case where a URL structurally matches but the resource is absent
- `notFoundComponent` defined on the route renders in place of the route's normal component
- If the route has no `notFoundComponent`, the not-found signal bubbles upward to the nearest ancestor that defines one

---

### Scoped Catch-All: Sub-Tree Wildcards

A wildcard scoped inside a subdirectory catches only URLs within that sub-tree, leaving the rest of the application unaffected.

```
src/routes/
  __root.tsx
  index.tsx
  app/
    index.tsx             → /app
    dashboard.tsx         → /app/dashboard
    $.tsx                 → /app/anything/else  (scoped: does not catch /other-section/miss)
  $.tsx                   → global catch-all for everything else
```

**`app/$.tsx`:**

tsx

```tsx
export const Route = createFileRoute('/app/$')({
  component: AppNotFound,
})

function AppNotFound() {
  const params = Route.useParams()
  return (
    <div>
      <p>The app section does not have a page at: {params['*']}</p>
    </div>
  )
}
```

This pattern is useful when different sections of an application have distinct 404 UIs or different layouts for unknown pages.

---

### File Browser Pattern

A wildcard route is the natural fit for a file-browser or documentation viewer where the URL path mirrors a file system hierarchy.

tsx

```tsx
// src/routes/files/$.tsx
export const Route = createFileRoute('/files/$')({
  loader: async ({ params }) => {
    const filePath = params['*'] ?? ''
    const segments = filePath ? filePath.split('/') : []
    const contents = await listDirectory(segments)
    return { filePath, contents }
  },
  component: FileBrowser,
})

function FileBrowser() {
  const { filePath, contents } = Route.useLoaderData()

  return (
    <div>
      <p>Current path: /{filePath}</p>
      <ul>
        {contents.map((item) => (
          <li key={item.name}>
            <Link
              to="/files/$"
              params={{ '*': filePath ? `${filePath}/${item.name}` : item.name }}
            >
              {item.name}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  )
}
```

> [Unverified] The syntax for passing a splat value to `<Link>` via `params` (e.g., `params={{ '*': '...' }}`) may differ by version. Confirm the correct `params` key for splat routes in your installed version.

---

### Visual: Wildcard Matching Across a Route Tree

<svg viewBox="0 0 680 460" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="680" height="460" fill="#0f1117" rx="12"/>

<text x="30" y="30" fill="`#718096`" font-size="11">URL → MATCHED ROUTE (specificity: static › dynamic › wildcard)</text>
<line x1="20" y1="38" x2="660" y2="38" stroke="`#2d3148`" stroke-width="1"/>

<!-- Headers -->

<text x="30" y="58" fill="`#718096`" font-size="10">URL</text>
<text x="260" y="58" fill="`#718096`" font-size="10">MATCHED ROUTE</text>
<text x="470" y="58" fill="`#718096`" font-size="10">REASON</text>

<!-- Row 1 -->
<rect x="20" y="66" width="220" height="30" rx="4" fill="#1e2230" stroke="#2d3148" stroke-width="1"/>
<text x="130" y="86" text-anchor="middle" fill="#e2e8f0">/docs/intro</text>
<rect x="255" y="66" width="195" height="30" rx="4" fill="#1e2230" stroke="#68d391" stroke-width="1"/>
<text x="352" y="86" text-anchor="middle" fill="#68d391">docs/intro.tsx</text>
<text x="465" y="86" fill="#a0aec0">Static match</text>
<!-- Row 2 -->
<rect x="20" y="108" width="220" height="30" rx="4" fill="#1e2230" stroke="#2d3148" stroke-width="1"/>
<text x="130" y="128" text-anchor="middle" fill="#e2e8f0">/docs/my-guide</text>
<rect x="255" y="108" width="195" height="30" rx="4" fill="#1e2230" stroke="#f6ad55" stroke-width="1"/>
<text x="352" y="128" text-anchor="middle" fill="#f6ad55">docs/$slug.tsx</text>
<text x="465" y="128" fill="#a0aec0">Dynamic match</text>
<!-- Row 3 -->
<rect x="20" y="150" width="220" height="30" rx="4" fill="#1e2230" stroke="#2d3148" stroke-width="1"/>
<text x="130" y="170" text-anchor="middle" fill="#e2e8f0">/docs/a/b/c</text>
<rect x="255" y="150" width="195" height="30" rx="4" fill="#1e2230" stroke="#b794f4" stroke-width="1"/>
<text x="352" y="170" text-anchor="middle" fill="#b794f4">docs/$.tsx</text>
<text x="465" y="170" fill="#a0aec0">Wildcard — multi-segment</text>
<!-- Row 4 -->
<rect x="20" y="192" width="220" height="30" rx="4" fill="#1e2230" stroke="#2d3148" stroke-width="1"/>
<text x="130" y="212" text-anchor="middle" fill="#e2e8f0">/docs</text>
<rect x="255" y="192" width="195" height="30" rx="4" fill="#1e2230" stroke="#68d391" stroke-width="1"/>
<text x="352" y="212" text-anchor="middle" fill="#68d391">docs/index.tsx</text>
<text x="465" y="212" fill="#a0aec0">Index — exact parent</text>
<!-- Row 5 -->
<rect x="20" y="234" width="220" height="30" rx="4" fill="#1e2230" stroke="#2d3148" stroke-width="1"/>
<text x="130" y="254" text-anchor="middle" fill="#e2e8f0">/completely/unknown</text>
<rect x="255" y="234" width="195" height="30" rx="4" fill="#1e2230" stroke="#b794f4" stroke-width="1"/>
<text x="352" y="254" text-anchor="middle" fill="#b794f4">$.tsx (global)</text>
<text x="465" y="254" fill="#a0aec0">Global catch-all</text>
<!-- Row 6: notFound() thrown -->
<rect x="20" y="276" width="220" height="30" rx="4" fill="#1e2230" stroke="#2d3148" stroke-width="1"/>
<text x="130" y="296" text-anchor="middle" fill="#e2e8f0">/users/999 (no DB row)</text>
<rect x="255" y="276" width="195" height="30" rx="4" fill="#1e2230" stroke="#fc8181" stroke-width="1"/>
<text x="352" y="296" text-anchor="middle" fill="#fc8181">notFoundComponent</text>
<text x="465" y="296" fill="#a0aec0">notFound() thrown in loader</text>
<line x1="20" y1="322" x2="660" y2="322" stroke="#2d3148" stroke-width="1"/>
<!-- Specificity ladder -->

<text x="30" y="344" fill="`#718096`" font-size="11">SPECIFICITY ORDER (highest → lowest)</text>

<rect x="30" y="354" width="130" height="28" rx="4" fill="#1a2040" stroke="#68d391" stroke-width="1"/>
<text x="95" y="373" text-anchor="middle" fill="#68d391" font-size="11">Static segment</text>

<text x="168" y="373" fill="`#718096`">›</text>

<rect x="182" y="354" width="140" height="28" rx="4" fill="#1a2040" stroke="#f6ad55" stroke-width="1"/>
<text x="252" y="373" text-anchor="middle" fill="#f6ad55" font-size="11">Dynamic $param</text>

<text x="330" y="373" fill="`#718096`">›</text>

<rect x="344" y="354" width="140" height="28" rx="4" fill="#1a2040" stroke="#b794f4" stroke-width="1"/>
<text x="414" y="373" text-anchor="middle" fill="#b794f4" font-size="11">Wildcard / splat $</text>

<text x="492" y="373" fill="`#718096`">›</text>

<rect x="506" y="354" width="140" height="28" rx="4" fill="#1a2040" stroke="#fc8181" stroke-width="1"/>
<text x="576" y="373" text-anchor="middle" fill="#fc8181" font-size="11">notFoundComponent</text>
<!-- Legend -->
<rect x="20" y="400" width="640" height="46" rx="6" fill="#1a1d2e" stroke="#2d3148" stroke-width="1"/>
<rect x="40" y="415" width="10" height="10" rx="2" fill="#68d391"/>
<text x="56" y="425" fill="#a0aec0" font-size="11">Static route</text>
<rect x="170" y="415" width="10" height="10" rx="2" fill="#f6ad55"/>
<text x="186" y="425" fill="#a0aec0" font-size="11">Dynamic route</text>
<rect x="310" y="415" width="10" height="10" rx="2" fill="#b794f4"/>
<text x="326" y="425" fill="#a0aec0" font-size="11">Wildcard / catch-all</text>
<rect x="480" y="415" width="10" height="10" rx="2" fill="#fc8181"/>
<text x="496" y="425" fill="#a0aec0" font-size="11">notFoundComponent (programmatic)</text>
</svg>

---

### Wildcard Routes vs. `notFoundComponent`: Decision Guide

| Situation | Use |
| --- | --- |
| Any unmatched URL in the whole app | Global `$.tsx` at route root |
| Unmatched URLs within one section | Scoped `$.tsx` inside section directory |
| Resource exists in route tree but not in DB | `notFound()` + `notFoundComponent` |
| Custom 404 UI inside the app shell | `notFoundComponent` on root route |
| File browser or path-delegating sub-app | Scoped wildcard with splat value parsing |
| Section-specific 404 with distinct layout | Scoped wildcard with its own layout ancestor |

---

### Common Mistakes

**Expecting wildcard to match a single segment**
`$.tsx` matches zero or more segments including slashes. For single-segment dynamic matching, use `$param.tsx` instead. Placing `$.tsx` where you meant `$slug.tsx` allows URLs like `/section/a/b/c` to match when only `/section/a` was intended.

**Incorrect splat value accessor**
Accessing `params.splatValue` or `params.splat` when the correct key is `'*'` or `'_splat'` returns `undefined` silently. Always confirm the accessor key in your version's type definitions.

**Relying on route declaration order for specificity**
Route specificity in TanStack Router is determined by the algorithm, not by the order routes are listed in `addChildren`. Do not rely on ordering to resolve ambiguity between a wildcard and a more specific route — define the more specific route explicitly.

**Conflating wildcard routes with `notFoundComponent`**
A wildcard route is a real route with a real match — it has loaders, lifecycle, and context. `notFoundComponent` renders when `notFound()` is thrown programmatically. They solve different problems and are not interchangeable.

**No global catch-all defined**
Without a global `$.tsx` or a root `notFoundComponent`, navigating to an unmatched URL renders the root layout with a blank `<Outlet />` and no user-visible feedback. Always provide a fallback.

---

**Related Topics:**

- `notFound()` utility and `notFoundComponent` per-route configuration
- Not-found bubbling across the route tree
- Dynamic `$param` routes and specificity interaction with wildcards
- Search params on wildcard routes
- Programmatic navigation to catch-all routes with splat params
- Scroll restoration on wildcard-matched pages
- TanStack Router Devtools for inspecting which route matched