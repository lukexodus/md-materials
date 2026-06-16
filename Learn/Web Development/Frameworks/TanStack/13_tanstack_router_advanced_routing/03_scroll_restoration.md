## Scroll Restoration

TanStack Router includes built-in scroll restoration that automatically manages scroll position across navigations. It restores the previous scroll position when the user navigates back, resets scroll to the top on new navigations, and handles edge cases like hash-based anchor scrolling — without requiring a third-party library or manual implementation.

---

### What Scroll Restoration Does

On a standard browser navigation, the browser natively restores scroll position when using back and forward buttons. In client-side routing, this behavior is lost because the browser never performs a full page load. TanStack Router replicates and extends this behavior:

- Resets scroll to the top on new forward navigations
- Restores scroll position on back/forward navigations
- Scrolls to hash anchors when a URL contains a `#fragment`
- Supports scroll restoration across multiple scrollable containers, not just `window`

---

### Enabling Scroll Restoration

Scroll restoration requires rendering the `<ScrollRestoration />` component once in the application, typically in the root route component:

```tsx
import { ScrollRestoration } from '@tanstack/react-router'

function RootComponent() {
  return (
    <>
      <Header />
      <Outlet />
      <ScrollRestoration />
    </>
  )
}
```

**Key Points:**
- `<ScrollRestoration />` should be rendered once — multiple instances may produce unpredictable behavior [Inference — verify in your version]
- Its placement in the component tree does not affect which elements it manages; it operates on registered scroll containers
- It renders no visible UI — it is a behavior-only component

---

### Default Behavior

With `<ScrollRestoration />` present and no additional configuration:

| Navigation type | Scroll behavior |
|---|---|
| New forward navigation | Scroll reset to top |
| Back / forward (history) | Scroll position restored |
| Navigating to `#hash` | Scroll to matching element |
| Navigating between siblings | Scroll reset to top |
| `replace` navigation | Scroll reset to top [Inference — verify in your version] |

---

### `resetScroll` on `<Link>` and `navigate`

Individual navigations can override the default scroll reset behavior using `resetScroll`:

```tsx
// Suppress scroll reset — useful for filter or tab changes
<Link to="/posts" search={{ tab: 'popular' }} resetScroll={false}>
  Popular
</Link>
```

```ts
router.navigate({
  to: '/posts',
  search: { tab: 'popular' },
  resetScroll: false,
})
```

**Key Points:**
- `resetScroll={false}` preserves the current scroll position after navigation
- Appropriate for navigations that update search params or tabs without representing a new page context
- `resetScroll={true}` is the default for new navigations and rarely needs to be set explicitly

---

### Hash-Based Anchor Scrolling

When a URL contains a `#fragment`, TanStack Router scrolls to the element with a matching `id` after the route renders:

```tsx
<Link to="/docs/guide" hash="installation">
  Jump to Installation
</Link>
```

The router scrolls to `document.getElementById('installation')` after the target route's component mounts.

**Key Points:**
- The target element must exist in the DOM at the time scroll is attempted
- For elements rendered after async data resolves (e.g., deferred content), the scroll may fire before the element is present [Inference — timing depends on when the component mounts relative to deferred resolution; verify behavior in your version]
- Hash scrolling uses `element.scrollIntoView()` behavior [Inference — verify exact scroll method in source]

---

### Custom Scroll Containers

By default, scroll restoration manages `window`. For routes with scrollable containers other than the window — a sidebar, a content panel, a modal — custom containers can be registered using `useElementScrollRestoration`:

```tsx
import { useElementScrollRestoration } from '@tanstack/react-router'

function ScrollablePanel() {
  const scrollRef = useRef<HTMLDivElement>(null)

  useElementScrollRestoration({
    id: 'main-panel',
    getElement: () => scrollRef.current,
  })

  return (
    <div ref={scrollRef} style={{ overflowY: 'auto', height: '100vh' }}>
      <PanelContent />
    </div>
  )
}
```

**Key Points:**
- `id` must be stable and unique across the application — it is the key used to store and retrieve scroll position
- `getElement` is called to obtain the DOM element; returning `null` skips restoration for that instance
- Each registered container is saved and restored independently from `window`
- [Unverified — verify `useElementScrollRestoration` prop names and full signature in your installed version]

---

### How Scroll State Is Stored

TanStack Router stores scroll positions in `sessionStorage` keyed by a combination of the history entry and the container ID. [Inference — exact storage mechanism and key structure may vary; verify in source or devtools]

**Key Points:**
- Scroll state does not persist across full page reloads beyond what `sessionStorage` survives
- `sessionStorage` is tab-scoped — scroll positions from one tab do not affect another
- If `sessionStorage` is unavailable, scroll restoration may silently degrade [Inference — verify fallback behavior in your version]

---

### Scroll Restoration and Deferred Data

When a route uses deferred data, the component renders before all data is available. If scroll restoration fires before deferred content is rendered, the restored position may be inaccurate because the document height is not yet final.

[Inference] Mitigation strategies include:
- Reserving space for deferred content with skeleton loaders of fixed height to keep the document height stable
- Scrolling programmatically after deferred content resolves using `useEffect`

TanStack Router does not currently provide a built-in mechanism to delay scroll restoration until deferred promises resolve. [Unverified — verify in your version's changelog]

---

### Scroll Restoration and `<Suspense>`

Similar to deferred data, content inside `<Suspense>` boundaries may not be present when scroll restoration fires. If a route restores a scroll position that depends on content still suspended, the result may be incorrect. [Inference — standard challenge with client-side scroll restoration and async rendering; not specific to TanStack Router]

---

### Programmatic Scroll Control

For cases where the built-in behavior is insufficient, scroll can be managed imperatively inside components:

```tsx
useEffect(() => {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}, [someCondition])
```

**Key Points:**
- Imperative scroll calls in `useEffect` run after render, which is after TanStack Router's scroll restoration
- If both run, the last one wins — order depends on timing [Inference — race conditions between router scroll restoration and imperative calls may produce inconsistent results; verify in your environment]
- Prefer `resetScroll={false}` on `<Link>` or `navigate` over imperative scroll suppression where possible

---

### `scrollBehavior` — Smooth vs Instant

The scroll behavior (instant jump vs smooth animation) is determined by the browser's default `scrollBehavior` or any CSS `scroll-behavior` declaration on the target element. TanStack Router does not directly expose a `scrollBehavior` option on `<ScrollRestoration />`. [Unverified — verify in your version's API]

To apply smooth scrolling globally:

```css
html {
  scroll-behavior: smooth;
}
```

**Key Points:**
- `scroll-behavior: smooth` affects all scroll operations including router-managed ones
- Smooth scrolling on history restoration (back/forward) may feel unnatural — consider scoping it to anchor links only
- `prefers-reduced-motion` should be respected for accessibility; suppress smooth scrolling for users who have opted out

```css
@media (prefers-reduced-motion: no-preference) {
  html {
    scroll-behavior: smooth;
  }
}
```

---

### Layout Routes and Scroll Containers

Layout routes that remain mounted across child navigations preserve the scroll position of their own containers naturally — the container never unmounts, so its scroll state is never lost. TanStack Router's restoration mechanism is most relevant for containers that unmount and remount on navigation.

**Key Points:**
- A persistent sidebar in a layout route retains its scroll without any scroll restoration configuration
- `useElementScrollRestoration` is needed for containers that unmount during navigation — typically the main content area of a route

---

### SSR and Scroll Restoration

In SSR environments, `<ScrollRestoration />` must only execute on the client. Rendering it on the server produces no useful output and may cause hydration mismatches. [Inference — standard SSR constraint for browser-API-dependent components; verify adapter behavior for TanStack Start or your SSR setup]

TanStack Start or a compatible SSR adapter typically handles client-only rendering of `<ScrollRestoration />` automatically. [Unverified — verify for your specific SSR configuration]

---

### Common Mistakes

**Rendering `<ScrollRestoration />` more than once**
Multiple instances may conflict, producing double-restoration or erratic scroll behavior.

**Expecting restoration to work without `<ScrollRestoration />`**
The component must be present. Without it, no scroll positions are saved or restored.

**Using unstable IDs with `useElementScrollRestoration`**
If the `id` changes between renders, the stored position cannot be matched on restoration. IDs must be static strings.

**Ignoring `prefers-reduced-motion`**
Applying smooth scrolling without a motion media query override may cause discomfort for users with vestibular disorders.

---

**Related Topics:**
- `<ScrollRestoration />` API — full prop reference
- `useElementScrollRestoration` — registering custom scroll containers
- `resetScroll` on `<Link>` and `navigate` — per-navigation scroll control
- Hash-based anchor navigation — `#fragment` scrolling behavior
- Deferred data and scroll timing — scroll restoration with async content
- Layout routes and mounted state — scroll persistence in persistent containers
- SSR hydration — client-only rendering of browser-dependent components