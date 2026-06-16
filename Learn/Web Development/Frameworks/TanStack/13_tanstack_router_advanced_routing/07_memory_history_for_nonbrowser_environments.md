## Memory History for Non-Browser Environments

Memory history is a routing mode where navigation state is maintained entirely in memory, with no connection to a browser URL, address bar, or the History API. It is the appropriate history implementation for environments where no browser URL exists — testing environments, server-side rendering, React Native, Electron without URL needs, and embedded iframe contexts.

---

### What Memory History Is

In browser history and hash routing modes, the router synchronizes its state with the browser's `window.location` and `window.history`. Memory history has no such synchronization target. The router maintains a stack of location entries internally, navigates between them programmatically, and never reads from or writes to any external URL representation.

From the router's perspective, memory history is fully functional — routes match, loaders run, navigation occurs, guards redirect, and the full lifecycle operates normally. The only difference is that none of it is reflected in any address bar.

---

### Creating a Memory History Instance

```ts
import {
  createRouter,
  createMemoryHistory,
} from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

const memoryHistory = createMemoryHistory({
  initialEntries: ['/'],
})

const router = createRouter({
  routeTree,
  history: memoryHistory,
})
```

**Key Points:**
- `initialEntries` sets the initial navigation stack — an array of URL strings
- The router starts at the last entry in `initialEntries` [Inference — verify exact initial entry selection behavior in your version]
- All route definitions, loaders, and navigation APIs are identical to browser history mode

---

### `createMemoryHistory` Options

```ts
createMemoryHistory({
  initialEntries: ['/'],   // required — starting location(s)
  initialIndex: 0,         // index into initialEntries to start at [Unverified]
})
```

| Option | Type | Description |
|---|---|---|
| `initialEntries` | `string[]` | The initial navigation stack |
| `initialIndex` | `number` | Starting position in the stack [Unverified — verify in your version] |

**Key Points:**
- `initialEntries` must contain at least one entry
- Multiple entries simulate a pre-existing navigation history, enabling back navigation from the start
- Entries are plain path strings — they follow the same format as route paths

---

### Use Case — Testing

Memory history is the standard approach for testing route behavior without a browser. It provides a controlled, predictable navigation environment with no dependency on `window` or `document`:

```ts
import { createRouter, createMemoryHistory } from '@tanstack/react-router'
import { render } from '@testing-library/react'
import { RouterProvider } from '@tanstack/react-router'

function renderAtRoute(path: string) {
  const memoryHistory = createMemoryHistory({
    initialEntries: [path],
  })

  const router = createRouter({
    routeTree,
    history: memoryHistory,
  })

  return render(<RouterProvider router={router} />)
}

test('renders dashboard for authenticated user', async () => {
  const { getByText } = renderAtRoute('/dashboard')
  // assert rendered output
})
```

**Key Points:**
- Each test creates a fresh router and history instance — no state leaks between tests
- Starting at an arbitrary path is trivial — pass the desired path in `initialEntries`
- Navigation within tests can be performed via `router.navigate` or by simulating user interactions with `<Link>` components
- No `window.location` mocking or jsdom URL configuration is needed

---

### Simulating Navigation History in Tests

`initialEntries` can contain multiple entries to pre-populate the navigation stack. This enables testing back/forward behavior without navigating step by step in the test:

```ts
const memoryHistory = createMemoryHistory({
  initialEntries: ['/photos', '/photos/42'],
})
```

The router starts at `/photos/42` with `/photos` already in the history stack. Calling `router.history.back()` navigates to `/photos` without requiring an explicit forward navigation first.

**Key Points:**
- This simulates a user who arrived at the current route via a specific navigation path
- Useful for testing back-navigation behavior, breadcrumbs, and state that depends on history depth
- The stack order is chronological — earlier entries are further back in history

---

### Use Case — Server-Side Rendering

In SSR, the server has a request URL but no browser history. Memory history is used to initialize the router with the incoming request path so it can render the correct route on the server:

```ts
// server handler (framework-agnostic pseudocode)
async function handleRequest(requestUrl: string) {
  const memoryHistory = createMemoryHistory({
    initialEntries: [requestUrl],
  })

  const router = createRouter({
    routeTree,
    history: memoryHistory,
  })

  await router.load()

  const html = renderToString(<RouterProvider router={router} />)

  return html
}
```

**Key Points:**
- The server creates a fresh router instance per request — shared router instances across requests cause state leakage [Inference — standard SSR isolation requirement; applies to all stateful server-side singletons]
- `router.load()` must be called before rendering to ensure loaders run and route data is available for the initial render
- The client rehydrates using browser history — memory history is server-only in this pattern
- TanStack Start handles this SSR setup through its own adapter; manual memory history setup is for custom SSR implementations

---

### Use Case — React Native

React Native has no browser URL or History API. Memory history provides routing behavior within the app without any URL substrate:

```ts
import { createMemoryHistory, createRouter } from '@tanstack/react-router'

const memoryHistory = createMemoryHistory({
  initialEntries: ['/home'],
})

const router = createRouter({
  routeTree,
  history: memoryHistory,
})
```

**Key Points:**
- Navigation between screens is handled via `router.navigate` and `<Link>` as in a browser environment
- Deep linking from external sources requires translating the incoming URL into a `router.navigate` call at app startup [Inference — React Native deep link handling is external to TanStack Router; verify integration approach for your React Native setup]
- There is no address bar to display or back button behavior tied to browser history — any back behavior must be implemented via `router.history.back()` or equivalent UI controls

---

### Use Case — Electron

Electron applications run in a Chromium environment but may not use URL-based routing. Memory history is appropriate when:

- The app is loaded from a `file://` URL where history-based routing is impractical
- The app has no need to expose navigable URLs to users
- Deep linking is not a requirement

```ts
const memoryHistory = createMemoryHistory({
  initialEntries: ['/main'],
})
```

For Electron apps that do need URL-based routing (e.g., for DevTools or external links), hash history is an alternative that works over `file://` URLs. [Inference — verify hash routing behavior in Electron's Chromium environment for your version]

---

### Use Case — Embedded or Iframe Contexts

An application embedded as an iframe inside a third-party page cannot safely manipulate the parent's URL. Memory history confines all navigation state to the iframe's own memory without attempting to modify any external URL:

```ts
const memoryHistory = createMemoryHistory({
  initialEntries: ['/embedded-app'],
})
```

**Key Points:**
- No `window.history.pushState` calls are made — no cross-frame security concerns
- The parent page's URL is entirely unaffected by navigation within the iframe
- Communication with the parent frame, if needed, must be handled separately via `postMessage`

---

### Programmatic Navigation with Memory History

Navigation via `router.navigate` works identically to browser history mode:

```ts
router.navigate({ to: '/settings' })
router.navigate({ to: '/posts/$postId', params: { postId: '5' } })
```

History traversal is available through the history instance:

```ts
router.history.back()
router.history.forward()
router.history.go(-2)
```

**Key Points:**
- `router.history.back()` navigates to the previous entry in the memory stack
- If at the beginning of the stack, `back()` has no effect — there is no browser-level "exit app" behavior triggered [Inference — verify edge case behavior at stack boundaries in your version]
- The history stack grows with each `navigate` call just as in browser history

---

### Reading Navigation State

The current location is available through the router regardless of history mode:

```ts
const location = router.state.location
// { pathname, search, hash, ... }
```

In a test, the current route after navigation can be verified by reading `router.state.location.pathname`:

```ts
await router.navigate({ to: '/settings' })
expect(router.state.location.pathname).toBe('/settings')
```

---

### Isolation Between Instances

Each `createMemoryHistory` call produces an independent stack. Multiple router instances with separate memory history instances do not share navigation state:

```ts
const historyA = createMemoryHistory({ initialEntries: ['/a'] })
const historyB = createMemoryHistory({ initialEntries: ['/b'] })

// routerA and routerB navigate independently
```

This is the basis for test isolation — each test constructs its own history and router without affecting others.

---

### Memory History Has No Persistence

Memory history state does not survive page reloads, process restarts, or any form of persistence. When the environment resets:

- In a test runner, each test file starts fresh
- In React Native, app backgrounding and foregrounding may reset state depending on the platform and implementation [Inference — React Native process lifecycle behavior depends on the OS and app configuration]
- In Electron, app relaunch starts from `initialEntries` again

If navigation state must survive restarts, it must be serialized and stored externally (e.g., `AsyncStorage` in React Native, `localStorage` in Electron), then used to populate `initialEntries` on next launch. [Inference — this persistence pattern is not built into TanStack Router; implementation is environment-specific]

---

### Comparing History Modes

| Mode | Factory | URL visible | Browser History API | SSR use | Test use |
|---|---|---|---|---|---|
| Browser | `createBrowserHistory` | Yes — clean URLs | Yes | Client only | With jsdom |
| Hash | `createHashHistory` | Yes — hash URLs | Yes (hash) | No | With jsdom |
| Memory | `createMemoryHistory` | No | No | Yes (server) | Yes (headless) |

---

**Related Topics:**
- `createBrowserHistory` — default browser URL routing
- `createHashHistory` — hash-based routing for static hosts
- SSR with TanStack Router — server-side rendering with memory history and `router.load()`
- TanStack Start SSR adapter — managed SSR setup
- Testing routes — integration testing patterns with memory history
- `router.history` API — programmatic navigation and stack traversal
- React Native routing — memory history in a non-browser mobile environment