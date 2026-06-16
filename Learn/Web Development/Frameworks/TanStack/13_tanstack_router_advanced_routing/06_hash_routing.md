## Hash Routing

Hash routing is a navigation mode where the entire client-side route is encoded in the URL hash fragment — the portion after `#`. Instead of `/dashboard/settings`, the URL reads `/#/dashboard/settings`. It is an alternative to the default history-based routing and is used when the application is served from environments where server-side URL handling is not available or not configurable.

---

### Why Hash Routing Exists

History-based routing (the default) uses clean URLs like `/dashboard/settings`. When the user refreshes or navigates directly to such a URL, the server must respond to that path by serving the application. If the server cannot be configured to do this — a static file host, a CDN without rewrite rules, certain embedded environments — any URL other than `/` returns a 404.

Hash routing avoids this entirely. The browser never sends the hash portion of a URL to the server. Every navigation, regardless of route, loads `/` from the server, and the router reads the hash to determine which route to render. No server configuration is required.

---

### When to Use Hash Routing

**Appropriate:**
- Static file hosting without URL rewrite support (GitHub Pages without custom config, plain S3 buckets)
- Embedded applications inside third-party pages that control the base URL
- Electron or other non-browser runtime environments where routing over the filesystem is needed
- Legacy hosting environments where server configuration is not accessible

**Not appropriate:**
- Standard web applications with a configurable server
- Applications requiring SEO — search engines index hash URLs inconsistently [Inference — crawler behavior for hash URLs varies; verify for your target search engines]
- Applications using SSR — hash routing is client-only; the server never sees the route

---

### Creating a Hash History Router

TanStack Router separates the router from its history implementation. Hash routing is enabled by providing a hash history instance instead of the default browser history:

```ts
import {
  createRouter,
  createHashHistory,
} from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

const hashHistory = createHashHistory()

const router = createRouter({
  routeTree,
  history: hashHistory,
})
```

No other configuration changes are required. All routes, loaders, `beforeLoad` hooks, and navigation APIs behave identically to history-based routing.

---

### URL Structure in Hash Mode

In hash routing mode, all route paths are encoded after `#/`:

| Route | Hash URL |
|---|---|
| `/` | `/#/` |
| `/dashboard` | `/#/dashboard` |
| `/dashboard/settings` | `/#/dashboard/settings` |
| `/posts/42` | `/#/posts/42` |
| `/search?q=hello` | `/#/search?q=hello` |

**Key Points:**
- The `#/` prefix is managed by the router automatically — route definitions use the same paths as history mode
- Search params and path params work identically in hash mode
- `<Link to="/dashboard">` renders as a link to `/#/dashboard` — no change to route definitions or link usage is needed

---

### Route Definitions Are Unchanged

Switching to hash routing requires no modifications to route files. A route defined as `/dashboard` remains `/dashboard` in both modes:

```ts
// routes/dashboard.tsx — identical in both modes
export const Route = createFileRoute('/dashboard')({
  loader: async () => fetchDashboardData(),
  component: DashboardComponent,
})
```

The history implementation is an adapter beneath the router. Route authors do not interact with it directly.

---

### Navigation APIs Are Unchanged

`<Link>`, `router.navigate`, `redirect`, and all other navigation primitives work identically in hash mode. The `to` option always uses the route path without the `#` prefix:

```tsx
<Link to="/settings">Settings</Link>
```

```ts
router.navigate({ to: '/settings' })
```

```ts
throw redirect({ to: '/login' })
```

The hash prefix is applied by the history layer transparently.

---

### Hash Routing and Anchor Links

Standard HTML anchor links use `#id` to scroll to an element. In hash routing mode, the `#` is already occupied by the router. Fragment-based anchor scrolling (`<Link hash="section">`) still works within TanStack Router's link system, but raw HTML anchor tags using `href="#section"` may conflict with the router's hash handling. [Inference — exact conflict behavior depends on how the browser resolves competing hash values; verify in your environment]

**Key Points:**
- Use TanStack Router's `hash` prop on `<Link>` for anchor scrolling in hash routing mode
- Avoid raw `<a href="#section">` anchors in hash routing applications — they modify the hash the router uses for navigation
- TanStack Router's scroll restoration handles hash-based scrolling through its own mechanism, which operates above the raw hash

---

### `createHashHistory` Options

`createHashHistory` accepts an options object. [Unverified — verify available options and their defaults in your installed version]

```ts
const hashHistory = createHashHistory()
```

No commonly documented options are required for standard use. The factory function produces a history instance compatible with the router's history interface.

---

### Memory History — a Related Alternative

For environments with no URL at all — server-side rendering without a browser, testing environments, React Native — TanStack Router provides `createMemoryHistory`:

```ts
import { createMemoryHistory } from '@tanstack/react-router'

const memoryHistory = createMemoryHistory({
  initialEntries: ['/dashboard'],
})

const router = createRouter({
  routeTree,
  history: memoryHistory,
})
```

**Key Points:**
- Memory history maintains navigation state in memory — nothing is reflected in any URL or address bar
- `initialEntries` sets the starting location; the first entry is the initial route
- Useful for unit and integration testing of route behavior without a browser environment
- Not appropriate for production browser applications — navigation state is lost on page refresh

---

### Comparing History Modes

| Mode | Factory | URL form | Server requirement | SSR support |
|---|---|---|---|---|
| Browser (default) | `createBrowserHistory` | `/dashboard` | Must serve all paths | Yes |
| Hash | `createHashHistory` | `/#/dashboard` | Serve `/` only | No |
| Memory | `createMemoryHistory` | None (in-memory) | None | Yes (server-side) |

---

### Hash Routing and `<base>` Tags

If the application uses an HTML `<base href="...">` tag to set a base URL, hash routing behavior may be affected. The `<base>` tag influences how relative URLs and hash values are resolved by the browser. [Inference — interaction between `<base href>` and hash routing depends on browser URL resolution rules; test explicitly in your environment if using both]

---

### Hash Routing and SSR

Hash routing is incompatible with SSR. The server never receives the hash portion of a URL — it cannot know which route to render. All rendering in hash routing mode is client-side.

If SSR is a requirement, use browser history mode with a server configured to serve the application for all routes, or use TanStack Start with its SSR adapter.

---

### Migrating from Hash to Browser History

Switching from hash routing to browser history routing requires:

1. Replacing `createHashHistory()` with `createBrowserHistory()` (or omitting the `history` option entirely, as browser history is the default)
2. Configuring the server to serve the application for all route paths
3. Redirecting existing `/#/path` URLs to `/path` for users with bookmarks or shared links [Inference — redirect strategy depends on your hosting environment; a server-side or JavaScript-based redirect may be needed]

Route definitions and all application code remain unchanged.

---

### Testing with Hash History

Hash history can be used in tests that run in a browser-like environment (jsdom, Playwright) where the address bar is not meaningful but URL parsing is available:

```ts
const hashHistory = createHashHistory()

const router = createRouter({
  routeTree,
  history: hashHistory,
})
```

For fully headless tests with no DOM, `createMemoryHistory` is more appropriate.

---

### Deployment with Hash Routing

A hash routing application requires only that the server serves `index.html` for requests to `/`. No rewrite rules are needed:

**Nginx — minimal config:**
```nginx
server {
  root /var/www/app;
  index index.html;

  location / {
    try_files $uri $uri/ /index.html;
  }
}
```

With hash routing, `try_files` is technically unnecessary since all requests arrive as `/`, but including it does no harm and handles direct asset requests correctly.

**GitHub Pages:**
No configuration required. GitHub Pages serves `index.html` for `/` by default, and the hash router handles the rest entirely client-side.

---

**Related Topics:**
- `createBrowserHistory` — default history mode for configurable server environments
- `createMemoryHistory` — in-memory routing for testing and SSR
- Scroll restoration and hash anchors — interaction between router hash and element anchors
- SSR compatibility — why hash routing and server rendering do not combine
- `<base>` tag interaction — base URL effects on hash resolution
- Static site deployment — hosting hash routing applications without server configuration
- Migrating to browser history — steps to move from hash to clean URLs