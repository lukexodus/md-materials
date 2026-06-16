## Active Link Styling in TanStack Router

---

### What Is Active Link Styling?

When a user navigates between routes, the application's navigation UI should visually reflect which route is currently active. TanStack Router builds this capability directly into the `<Link>` component — no external state, no manual comparisons against `window.location`. The router tracks the current match and applies props, class names, or styles to `<Link>` elements whose destination matches.

**Key Points:**
- Active state is determined by comparing the link's `to`, `params`, and optionally `search` against the current URL
- By default, a link is active when the current URL **starts with** the link's destination — prefix matching
- Exact matching, search param matching, and hash matching are opt-in via `activeOptions`
- Active and inactive states are each independently configurable via dedicated props
- Pending state (while a destination's loader is resolving) is a third distinct state with its own props

---

### The Default: Prefix Matching

Out of the box, `<Link>` uses prefix (fuzzy) matching for active state. A link is active whenever the current pathname begins with the link's `to` value.

```tsx
// Current URL: /dashboard/settings

<Link to="/dashboard">Dashboard</Link>
// Active — /dashboard/settings starts with /dashboard

<Link to="/dashboard/settings">Settings</Link>
// Active — exact match also satisfies prefix

<Link to="/">Home</Link>
// Active — / is a prefix of every URL
```

This is intentional for navigation hierarchies: a parent nav item should appear active when any of its children is the current route. However, it requires explicit configuration for index-level links (see below).

---

### `activeClassName`

The simplest way to apply active styling is `activeClassName`. The string is appended to the element's `className` when the link is active.

```tsx
<Link to="/dashboard" activeClassName="is-active">
  Dashboard
</Link>
```

**Rendered when active:**
```html
<a href="/dashboard" class="is-active">Dashboard</a>
```

Combined with a base class:

```tsx
<Link
  to="/dashboard"
  className="nav-link"
  activeClassName="nav-link--active"
>
  Dashboard
</Link>
```

**Rendered when active:**
```html
<a href="/dashboard" class="nav-link nav-link--active">Dashboard</a>
```

**Key Points:**
- `activeClassName` is merged with `className`, not a replacement
- When the link is inactive, only `className` applies
- `activeClassName` responds to the same matching rules as `activeProps` — configurable via `activeOptions`

---

### `activeProps`

`activeProps` accepts an object of any valid `<a>` element props. These are merged onto the rendered element when the link is active. This is the more general form and supports class names, inline styles, ARIA attributes, and data attributes simultaneously.

```tsx
<Link
  to="/dashboard"
  activeProps={{
    className: 'nav-link--active',
    'aria-current': 'page',
    style: { fontWeight: 700 },
  }}
>
  Dashboard
</Link>
```

**Key Points:**
- `activeProps.className` is merged with the base `className`, following the same rules as `activeClassName`
- `aria-current="page"` is the correct ARIA attribute for the active page link — applying it via `activeProps` is the idiomatic TanStack Router pattern
- `activeProps` and `activeClassName` can be used together; both are applied when active

---

### `inactiveProps`

`inactiveProps` is the counterpart to `activeProps`. Props in this object are applied when the link is **not** active and removed when it becomes active.

```tsx
<Link
  to="/dashboard"
  className="nav-link"
  activeProps={{ className: 'nav-link--active', 'aria-current': 'page' }}
  inactiveProps={{ className: 'nav-link--inactive', tabIndex: -1 }}
>
  Dashboard
</Link>
```

**Key Points:**
- `inactiveProps` and `activeProps` are mutually exclusive per navigation event — only one applies at a time
- Use `inactiveProps` when inactive links need explicit styling or behavioral differences (reduced opacity, pointer-events adjustments)
- Like `activeProps`, the `className` in `inactiveProps` merges with the base `className`

---

### `activeOptions`

`activeOptions` controls the matching logic used to determine active state. It accepts an object with the following properties:

| Option | Type | Default | Effect |
|---|---|---|---|
| `exact` | boolean | `false` | Require exact pathname match, not prefix |
| `includeSearch` | boolean | `false` | Include search params in active comparison |
| `includeHash` | boolean | `false` | Include hash fragment in active comparison |

#### Exact Matching

Required for index route links and any link where prefix matching causes false positives.

```tsx
// Without exact: true, this is active on /dashboard AND /dashboard/settings
<Link
  to="/dashboard"
  activeOptions={{ exact: true }}
  activeProps={{ className: 'active' }}
>
  Dashboard Home
</Link>
```

```tsx
// Current URL: /dashboard/settings

// exact: false (default) → active (prefix match)
<Link to="/dashboard" activeOptions={{ exact: false }}>Dashboard</Link>

// exact: true → NOT active (not an exact match)
<Link to="/dashboard" activeOptions={{ exact: true }}>Dashboard Home</Link>

// exact: true → active (exact match)
<Link to="/dashboard/settings" activeOptions={{ exact: true }}>Settings</Link>
```

#### Including Search Params

When the active state should reflect search params — for example, filter tabs or paginated views:

```tsx
<Link
  to="/products"
  search={{ category: 'electronics' }}
  activeOptions={{ exact: true, includeSearch: true }}
  activeProps={{ className: 'tab--active' }}
>
  Electronics
</Link>

<Link
  to="/products"
  search={{ category: 'clothing' }}
  activeOptions={{ exact: true, includeSearch: true }}
  activeProps={{ className: 'tab--active' }}
>
  Clothing
</Link>
```

When the URL is `/products?category=electronics`, only the first link is active. Without `includeSearch: true`, both links would be active since both point to `/products`.

#### Including Hash

```tsx
<Link
  to="/docs/intro"
  hash="installation"
  activeOptions={{ exact: true, includeHash: true }}
  activeProps={{ className: 'toc-link--active' }}
>
  Installation
</Link>
```

> [Inference] Hash-based active detection depends on the router's ability to observe hash changes. Behavior may vary depending on history mode and scroll restoration configuration. Test in your environment.

---

### Combining `exact` and `includeSearch` in Tab Navigation

A common pattern for tab bars where each tab represents a filtered view of the same base route:

```tsx
import { Link } from '@tanstack/react-router'

const tabs = [
  { label: 'All',         search: { status: 'all' } },
  { label: 'Active',      search: { status: 'active' } },
  { label: 'Archived',    search: { status: 'archived' } },
]

function TaskTabs() {
  return (
    <div role="tablist">
      {tabs.map((tab) => (
        <Link
          key={tab.search.status}
          to="/tasks"
          search={tab.search}
          activeOptions={{ exact: true, includeSearch: true }}
          activeProps={{
            className: 'tab tab--active',
            role: 'tab',
            'aria-selected': 'true',
          }}
          inactiveProps={{
            className: 'tab',
            role: 'tab',
            'aria-selected': 'false',
          }}
        >
          {tab.label}
        </Link>
      ))}
    </div>
  )
}
```

---

### Pending State Styling

A third state exists between inactive and active: **pending**. A link enters pending state while its destination route's loader is running. This provides a loading affordance on the link itself, without requiring external loading state.

#### `pendingClassName`

```tsx
<Link
  to="/dashboard"
  className="nav-link"
  activeClassName="nav-link--active"
  pendingClassName="nav-link--loading"
>
  Dashboard
</Link>
```

#### `pendingProps`

```tsx
<Link
  to="/dashboard"
  pendingProps={{
    className: 'nav-link nav-link--loading',
    'aria-busy': 'true',
  }}
>
  Dashboard
</Link>
```

**Key Points:**
- Pending state is independent of active state — a link can be pending without being active
- `pendingProps` is merged similarly to `activeProps`
- The pending state duration is controlled by the destination route's loader resolution time and the router's `defaultPendingMs` setting

> [Inference] The interaction between `pendingProps` and `activeProps` when a link is both active and pending (e.g., navigating to the same route with different params) may produce merged results. Verify the precedence behavior in your version.

---

### Using Render Props for Full Control

`<Link>` supports a render prop pattern where a function child receives the link's current state. This is useful when active or pending state needs to affect elements beyond the `<a>` tag itself.

```tsx
<Link to="/dashboard">
  {({ isActive, isPending }) => (
    <span
      className={[
        'nav-item',
        isActive ? 'nav-item--active' : '',
        isPending ? 'nav-item--pending' : '',
      ].join(' ')}
    >
      <DashboardIcon active={isActive} />
      Dashboard
      {isPending && <LoadingDot />}
    </span>
  )}
</Link>
```

**Key Points:**
- The render prop receives `isActive` and `isPending` as booleans
- The returned JSX is rendered as the content of the `<a>` tag — not as a replacement for it
- This pattern is appropriate when the active state needs to affect icons, badges, or complex inner layouts

> [Inference] The exact shape of the render prop argument may include additional properties in some versions. Consult your version's type definitions for the full available interface.

---

### `useMatchRoute` for Custom Active Indicators

When you need active detection outside of a `<Link>` — for example, in a sidebar wrapper `<div>` or a tab container — use `useMatchRoute`.

```tsx
import { useMatchRoute, Link } from '@tanstack/react-router'

function SidebarItem({ to, label }: { to: string; label: string }) {
  const matchRoute = useMatchRoute()
  const isActive = !!matchRoute({ to, fuzzy: true })

  return (
    <div className={`sidebar-item ${isActive ? 'sidebar-item--active' : ''}`}>
      <Link to={to}>{label}</Link>
    </div>
  )
}
```

**Key Points:**
- `matchRoute({ to })` returns the matched params object if the route is active, or `false` if not — use `!!` to get a boolean
- `fuzzy: true` mirrors `<Link>`'s default prefix matching behavior
- `fuzzy: false` requires an exact match
- `useMatchRoute` does not render anything — it is a pure state accessor

---

### Visual: Active State Matrix

<svg viewBox="0 0 660 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="660" height="400" fill="#0f1117" rx="12"/>

  <text x="30" y="30" fill="#718096" font-size="11">ACTIVE STATE — MATCHING RULES AT A GLANCE</text>
  <line x1="20" y1="38" x2="640" y2="38" stroke="#2d3148" stroke-width="1"/>

  <!-- Column headers -->
  <text x="30" y="60" fill="#718096" font-size="10">LINK  to=</text>
  <text x="170" y="60" fill="#718096" font-size="10">activeOptions</text>
  <text x="340" y="60" fill="#718096" font-size="10">CURRENT URL</text>
  <text x="500" y="60" fill="#718096" font-size="10">ACTIVE?</text>

  <line x1="20" y1="68" x2="640" y2="68" stroke="#2d3148" stroke-width="1"/>

  <!-- Row 1 -->
  <text x="30" y="90" fill="#e2e8f0">/dashboard</text>
  <text x="170" y="90" fill="#a0aec0">exact: false (default)</text>
  <text x="340" y="90" fill="#e2e8f0">/dashboard/settings</text>
  <rect x="492" y="76" width="70" height="22" rx="4" fill="#1a3a1a" stroke="#68d391" stroke-width="1"/>
  <text x="527" y="91" text-anchor="middle" fill="#68d391">YES</text>

  <!-- Row 2 -->
  <text x="30" y="120" fill="#e2e8f0">/dashboard</text>
  <text x="170" y="120" fill="#a0aec0">exact: true</text>
  <text x="340" y="120" fill="#e2e8f0">/dashboard/settings</text>
  <rect x="492" y="106" width="70" height="22" rx="4" fill="#3a1a1a" stroke="#fc8181" stroke-width="1"/>
  <text x="527" y="121" text-anchor="middle" fill="#fc8181">NO</text>

  <!-- Row 3 -->
  <text x="30" y="150" fill="#e2e8f0">/dashboard</text>
  <text x="170" y="150" fill="#a0aec0">exact: true</text>
  <text x="340" y="150" fill="#e2e8f0">/dashboard</text>
  <rect x="492" y="136" width="70" height="22" rx="4" fill="#1a3a1a" stroke="#68d391" stroke-width="1"/>
  <text x="527" y="151" text-anchor="middle" fill="#68d391">YES</text>

  <!-- Row 4 -->
  <text x="30" y="180" fill="#e2e8f0">/products?cat=a</text>
  <text x="170" y="180" fill="#a0aec0">includeSearch: false</text>
  <text x="340" y="180" fill="#e2e8f0">/products?cat=b</text>
  <rect x="492" y="166" width="70" height="22" rx="4" fill="#1a3a1a" stroke="#68d391" stroke-width="1"/>
  <text x="527" y="181" text-anchor="middle" fill="#68d391">YES</text>
  <text x="580" y="181" fill="#718096" font-size="10">search ignored</text>

  <!-- Row 5 -->
  <text x="30" y="210" fill="#e2e8f0">/products?cat=a</text>
  <text x="170" y="210" fill="#a0aec0">includeSearch: true</text>
  <text x="340" y="210" fill="#e2e8f0">/products?cat=b</text>
  <rect x="492" y="196" width="70" height="22" rx="4" fill="#3a1a1a" stroke="#fc8181" stroke-width="1"/>
  <text x="527" y="211" text-anchor="middle" fill="#fc8181">NO</text>
  <text x="580" y="211" fill="#718096" font-size="10">mismatch</text>

  <!-- Row 6 -->
  <text x="30" y="240" fill="#e2e8f0">/products?cat=a</text>
  <text x="170" y="240" fill="#a0aec0">includeSearch: true</text>
  <text x="340" y="240" fill="#e2e8f0">/products?cat=a</text>
  <rect x="492" y="226" width="70" height="22" rx="4" fill="#1a3a1a" stroke="#68d391" stroke-width="1"/>
  <text x="527" y="241" text-anchor="middle" fill="#68d391">YES</text>

  <!-- Row 7: / without exact -->
  <text x="30" y="270" fill="#e2e8f0">/</text>
  <text x="170" y="270" fill="#a0aec0">exact: false (default)</text>
  <text x="340" y="270" fill="#e2e8f0">/anything</text>
  <rect x="492" y="256" width="70" height="22" rx="4" fill="#1a3a1a" stroke="#f6ad55" stroke-width="1"/>
  <text x="527" y="271" text-anchor="middle" fill="#f6ad55">YES ⚠</text>
  <text x="580" y="271" fill="#718096" font-size="10">always active</text>

  <!-- Row 8: / with exact -->
  <text x="30" y="300" fill="#e2e8f0">/</text>
  <text x="170" y="300" fill="#a0aec0">exact: true</text>
  <text x="340" y="300" fill="#e2e8f0">/anything</text>
  <rect x="492" y="286" width="70" height="22" rx="4" fill="#3a1a1a" stroke="#fc8181" stroke-width="1"/>
  <text x="527" y="301" text-anchor="middle" fill="#fc8181">NO</text>

  <line x1="20" y1="318" x2="640" y2="318" stroke="#2d3148" stroke-width="1"/>

  <!-- State legend -->
  <text x="30" y="338" fill="#718096" font-size="11">STATES</text>

  <rect x="100" y="348" width="60" height="22" rx="4" fill="#1a2040" stroke="#4f6ef7" stroke-width="1"/>
  <text x="130" y="363" text-anchor="middle" fill="#4f6ef7" font-size="10">inactive</text>

  <rect x="200" y="348" width="60" height="22" rx="4" fill="#1a3a1a" stroke="#68d391" stroke-width="1"/>
  <text x="230" y="363" text-anchor="middle" fill="#68d391" font-size="10">active</text>

  <rect x="300" y="348" width="60" height="22" rx="4" fill="#2a2a10" stroke="#f6ad55" stroke-width="1"/>
  <text x="330" y="363" text-anchor="middle" fill="#f6ad55" font-size="10">pending</text>

  <text x="390" y="363" fill="#718096" font-size="11">Props applied: activeProps · activeClassName · inactiveProps · pendingProps · pendingClassName</text>
</svg>

---

### Practical Pattern: Navigation Sidebar

A complete sidebar implementation combining multiple active styling concepts:

```tsx
import { Link } from '@tanstack/react-router'

const navItems = [
  { to: '/',           label: 'Home',     exact: true  },
  { to: '/dashboard',  label: 'Dashboard',exact: true  },
  { to: '/users',      label: 'Users',    exact: false },
  { to: '/settings',   label: 'Settings', exact: false },
]

function Sidebar() {
  return (
    <nav aria-label="Main navigation">
      <ul>
        {navItems.map((item) => (
          <li key={item.to}>
            <Link
              to={item.to}
              className="sidebar-link"
              activeOptions={{ exact: item.exact }}
              activeProps={{
                className: 'sidebar-link sidebar-link--active',
                'aria-current': 'page',
              }}
              inactiveProps={{
                className: 'sidebar-link',
              }}
              pendingProps={{
                className: 'sidebar-link sidebar-link--loading',
                'aria-busy': 'true',
              }}
            >
              {item.label}
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  )
}
```

---

### Common Mistakes

**Root `/` link always active without `exact: true`**
A link to `/` matches every URL by prefix. It will appear active on every page unless `activeOptions={{ exact: true }}` is applied. This is the most common active styling mistake.

**Index route links activating on child routes**
A link to `/dashboard` without `exact: true` stays active on `/dashboard/settings`, `/dashboard/profile`, and all other children. Use `exact: true` for any link whose destination is a layout-level or index-level path.

**Applying `aria-current` via base `className` instead of `activeProps`**
`aria-current="page"` should only be present on the active link. Adding it statically applies it to all links simultaneously, breaking assistive technology navigation. Use `activeProps` to apply it conditionally.

**Using `includeSearch` without `exact`**
`includeSearch: true` without `exact: true` still allows prefix matching on the pathname. A link to `/products?cat=a` would match `/products/detail?cat=a` with `includeSearch` but without `exact`. Combine both options for precise tab-style matching.

**Forgetting `inactiveProps` removes `activeProps`**
`activeProps` and `inactiveProps` are mutually exclusive per render — only one is applied at a time. You do not need `inactiveProps` to undo `activeProps`; inactive is the default state when the link is not matched.

---

**Related Topics:**
- `useMatchRoute` for active detection outside `<Link>`
- `useRouterState` for reading current location
- Search params schemas and how they affect `includeSearch` matching
- Pending UI: `defaultPendingMs` and route-level pending configuration
- Scroll restoration on active link navigation
- Accessibility patterns for navigation landmarks and `aria-current`
- Animated route transitions with `viewTransition`