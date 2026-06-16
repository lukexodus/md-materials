## NotFound Handling

TanStack Router provides a dedicated not-found system separate from general error handling. Throwing `notFound()` from a loader, `beforeLoad`, or component signals a missing resource condition — distinct from an application error — and renders a targeted not-found UI without collapsing the surrounding layout.

---

### Why NotFound Is Separate from Errors

A missing resource is a predictable, non-exceptional condition. Conflating it with error handling produces imprecise UI — an error boundary designed for unexpected failures is inappropriate for a "this item does not exist" state.

TanStack Router models them separately:

| Condition | Throw | Renders |
| --- | --- | --- |
| Missing resource | `notFound()` | `notFoundComponent` |
| Unexpected failure | `new Error(...)` | `errorComponent` |
| Auth redirect | `redirect(...)` | navigates away |

---

### `notFound` — the Throw Utility

ts

```ts
import { notFound } from '@tanstack/react-router'

loader: async ({ params }) => {
  const post = await fetchPost(params.postId)
  if (!post) throw notFound()
  return post
}
```

**Key Points:**

- `notFound()` must be thrown, not returned
- It does not extend `Error` — it is a distinct signal type processed by the router separately
- It can be thrown from `loader`, `beforeLoad`, or inside a component

---

### `notFoundComponent` on a Route

Each route can define a `notFoundComponent` rendered when `notFound()` is thrown within that route's lifecycle:

ts

```ts
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await fetchPost(params.postId)
    if (!post) throw notFound()
    return post
  },
  notFoundComponent: () => {
    return <p>Post not found.</p>
  },
  component: PostComponent,
})
```

The `notFoundComponent` replaces the route's normal `component` for the duration of the not-found state. Parent layout routes continue rendering normally.

---

### `notFoundComponent` Prop Signature

Unlike `errorComponent`, `notFoundComponent` does not receive an error or reset prop. It receives no props by default:

ts

```ts
notFoundComponent: () => ReactNode
```

[Unverified — verify whether any props are passed in your installed version; the API surface has evolved across releases]

---

### Propagation to Ancestor Routes

If a route does not define `notFoundComponent`, the not-found signal propagates upward to the nearest ancestor that does, following the same rules as `errorComponent`:

```
__root.tsx           notFoundComponent defined ← fallback
  └── _layout.tsx    no notFoundComponent
        └── /posts/$postId   throws notFound()
              → propagates to __root.tsx notFoundComponent
```

**Key Points:**

- More specific `notFoundComponent` definitions closer to the throwing route take precedence
- Root-level `notFoundComponent` acts as the application-wide not-found fallback
- If no route in the tree defines `notFoundComponent`, behavior is unspecified [Inference — may fall through to default router behavior or render nothing; verify in your version]

---

### Root-Level Not-Found Fallback

ts

```ts
// routes/__root.tsx
export const Route = createRootRouteWithContext<RouterContext>()({
  notFoundComponent: () => {
    return (
      <div>
        <h1>404 — Page Not Found</h1>
        <Link to="/">Return home</Link>
      </div>
    )
  },
  component: RootComponent,
})
```

This renders whenever any route in the application throws `notFound()` and no closer `notFoundComponent` intercepts it.

---

### Unmatched Routes — Automatic NotFound

Beyond explicit `notFound()` throws, TanStack Router automatically triggers not-found handling when a URL does not match any registered route. The root `notFoundComponent` handles this case:

```
User navigates to /does-not-exist
  → no route matches
  → root notFoundComponent renders
```

**Key Points:**

- No manual `notFound()` throw is needed for completely unmatched URLs — the router handles this automatically
- For routes that match structurally but whose dynamic segment resolves to a missing resource (e.g., `/posts/999` where post 999 does not exist), a manual `throw notFound()` in the loader is required

---

### `notFoundComponent` with Layout Preservation

A route-scoped `notFoundComponent` preserves all ancestor route layouts. Only the affected route's render region is replaced:

```
__root.tsx          ← renders (global nav, shell)
  └── _layout.tsx   ← renders (sidebar, section header)
        └── /posts/$postId   ← notFoundComponent renders here
```

This keeps the user oriented within the application structure rather than replacing the entire page with a generic 404.

---

### Using Router Hooks Inside `notFoundComponent`

`notFoundComponent` is a normal React component. Router hooks are available:

tsx

```tsx
notFoundComponent: () => {
  const router = useRouter()
  const params = Route.useParams()

  return (
    <div>
      <p>No post found with ID: {params.postId}</p>
      <button onClick={() => router.history.back()}>Go back</button>
      <Link to="/posts">All posts</Link>
    </div>
  )
}
```

**Key Points:**

- `Route.useParams()` is safe here — the URL matched the route structurally, so params are parsed
- `Route.useLoaderData()` is not safe — the loader threw before returning data [Inference — accessing loader data after a throw is undefined behavior; verify in your version]
- `useRouter`, `useNavigate`, and `Link` all function normally

---

### Throwing `notFound` from `beforeLoad`

`notFound()` can be thrown from `beforeLoad` as well as `loader`:

ts

```ts
beforeLoad: async ({ params }) => {
  const exists = await checkExists(params.id)
  if (!exists) throw notFound()
}
```

**Key Points:**

- Throwing from `beforeLoad` prevents the loader from running entirely
- Appropriate when existence can be verified cheaply before committing to a full data fetch
- The `notFoundComponent` on the same route (or nearest ancestor) renders as normal

---

### `notFound` with SSR

In SSR environments, throwing `notFound()` should result in an HTTP 404 response. The exact mechanism depends on the server adapter and framework:

ts

```ts
loader: async ({ params }) => {
  const item = await fetchItem(params.id)
  if (!item) throw notFound()
  return item
}
```

[Unverified — TanStack Start's SSR adapter may handle the 404 status automatically; verify configuration requirements for your deployment target and adapter version]

---

### `CatchNotFound` — Inline Component-Level NotFound

For not-found states that originate inside a component rather than a loader, TanStack Router provides `CatchNotFound` for inline placement:

tsx

```tsx
import { CatchNotFound } from '@tanstack/react-router'

function PostsLayout() {
  return (
    <div>
      <PostsSidebar />
      <CatchNotFound
        fallback={() => <p>That post does not exist.</p>}
      >
        <Outlet />
      </CatchNotFound>
    </div>
  )
}
```

**Key Points:**

- `CatchNotFound` intercepts `notFound()` thrown within its children
- It is a React component, not a route option
- Useful for wrapping `<Outlet />` in a layout to provide scoped not-found UI without defining `notFoundComponent` on every child route
- [Unverified — verify `CatchNotFound` prop names and signature in your installed version]

---

### `notFound` vs `redirect` for Missing Resources

Both can respond to a missing resource, but they serve different intents:

| Approach | When to use |
| --- | --- |
| `throw notFound()` | Resource does not exist — inform the user in place |
| `throw redirect(...)` | Resource moved or user should be sent elsewhere |

Redirecting on a missing resource hides the 404 condition from the user and browser history. `notFound()` is more appropriate when the absence itself is meaningful information.

---

### Differentiating NotFound from Error in Shared UI

Because `notFoundComponent` and `errorComponent` are separate, a route can handle both distinctly:

ts

```ts
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    try {
      const post = await fetchPost(params.postId)
      if (!post) throw notFound()
      return post
    } catch (err) {
      if (err instanceof NotFoundSignal) throw err // re-throw notFound
      throw new Error('Failed to fetch post') // escalate as error
    }
  },
  notFoundComponent: () => <p>Post does not exist.</p>,
  errorComponent: ({ error }) => <p>Error: {error.message}</p>,
})
```

[Inference — `NotFoundSignal` is illustrative; the actual type thrown by `notFound()` should be verified in your version's source or type definitions to correctly identify and re-throw it]

---

### Default NotFound Behavior

TanStack Router ships with a default not-found UI rendered when no `notFoundComponent` is defined anywhere in the tree. [Unverified — exact default rendering behavior and whether a default component exists depends on your version; verify in source or devtools]

---

**Related Topics:**

- `errorComponent` per route — parallel system for unexpected errors
- `CatchNotFound` component — inline not-found interception in component trees
- `CatchBoundary` — inline error interception in component trees
- Unmatched route handling — automatic not-found for unknown URLs
- SSR 404 responses — adapter configuration for HTTP status on not-found
- `notFound()` from `beforeLoad` — pre-loader existence checks
- `useParams` inside `notFoundComponent` — accessing URL context in not-found UI