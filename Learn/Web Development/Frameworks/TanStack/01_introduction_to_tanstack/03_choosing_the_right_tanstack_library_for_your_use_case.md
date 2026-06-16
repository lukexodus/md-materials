## Choosing the Right TanStack Library for Your Use Case

### Why the Choice Matters

TanStack libraries are independently adoptable, which means you are never required to use the full ecosystem. However, because each library targets a distinct problem domain, **choosing the wrong tool — or reaching for a TanStack library when a simpler solution suffices — adds unnecessary complexity**. The goal of this guide is to help you match your actual problem to the right library, identify when a combination is warranted, and recognize when a TanStack library may not be the right fit at all.

---

### Decision Framework

The central question before adopting any TanStack library:

> *What category of problem am I solving?*

The five primary categories in the TanStack ecosystem are:

1. **Data fetching and server state** → TanStack Query
2. **Navigation and URL management** → TanStack Router
3. **Tabular data display** → TanStack Table
4. **User input and form handling** → TanStack Form
5. **List or grid rendering at scale** → TanStack Virtual

TanStack Store and TanStack Start sit in supporting roles: Store as a reactive primitive, Start as a full-stack composition layer.

---

### Decision Tree

The following diagram walks through the primary decision points:

<svg viewBox="0 0 820 860" xmlns="http://www.w3.org/2000/svg" font-family="ui-monospace, monospace" font-size="12">

  <rect width="820" height="860" fill="#0f1117" rx="12"/>

  <!-- START -->
  <rect x="310" y="20" width="200" height="38" rx="19" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
  <text x="410" y="44" fill="#93c5fd" text-anchor="middle" font-weight="bold">What is your problem?</text>

  <!-- Q1: Async data? -->
  <rect x="285" y="90" width="250" height="36" rx="6" fill="#1a1a2e" stroke="#6366f1" stroke-width="1"/>
  <text x="410" y="113" fill="#a5b4fc" text-anchor="middle">Fetching async / remote data?</text>
  <line x1="410" y1="58" x2="410" y2="90" stroke="#4b5563" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- YES → Query -->
  <line x1="535" y1="108" x2="620" y2="108" stroke="#10b981" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="575" y="102" fill="#10b981" text-anchor="middle" font-size="11">YES</text>
  <rect x="620" y="90" width="160" height="36" rx="6" fill="#134e3a" stroke="#10b981" stroke-width="1.5"/>
  <text x="700" y="113" fill="#34d399" text-anchor="middle" font-weight="bold">TanStack Query</text>

  <!-- NO → Q2 -->
  <line x1="410" y1="126" x2="410" y2="168" stroke="#ef4444" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="418" y="152" fill="#ef4444" font-size="11">NO</text>

  <!-- Q2: Routing? -->
  <rect x="285" y="168" width="250" height="36" rx="6" fill="#1a1a2e" stroke="#6366f1" stroke-width="1"/>
  <text x="410" y="191" fill="#a5b4fc" text-anchor="middle">Managing URLs / navigation?</text>

  <!-- YES → Router -->
  <line x1="535" y1="186" x2="620" y2="186" stroke="#10b981" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="575" y="180" fill="#10b981" text-anchor="middle" font-size="11">YES</text>
  <rect x="620" y="168" width="160" height="36" rx="6" fill="#134e3a" stroke="#10b981" stroke-width="1.5"/>
  <text x="700" y="191" fill="#34d399" text-anchor="middle" font-weight="bold">TanStack Router</text>

  <!-- NO → Q3 -->
  <line x1="410" y1="204" x2="410" y2="246" stroke="#ef4444" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="418" y="230" fill="#ef4444" font-size="11">NO</text>

  <!-- Q3: Table? -->
  <rect x="285" y="246" width="250" height="36" rx="6" fill="#1a1a2e" stroke="#6366f1" stroke-width="1"/>
  <text x="410" y="269" fill="#a5b4fc" text-anchor="middle">Displaying rows of structured data?</text>

  <!-- YES → Table -->
  <line x1="535" y1="264" x2="620" y2="264" stroke="#10b981" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="575" y="258" fill="#10b981" text-anchor="middle" font-size="11">YES</text>
  <rect x="620" y="246" width="160" height="36" rx="6" fill="#134e3a" stroke="#10b981" stroke-width="1.5"/>
  <text x="700" y="269" fill="#34d399" text-anchor="middle" font-weight="bold">TanStack Table</text>

  <!-- NO → Q4 -->
  <line x1="410" y1="282" x2="410" y2="324" stroke="#ef4444" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="418" y="308" fill="#ef4444" font-size="11">NO</text>

  <!-- Q4: Forms? -->
  <rect x="285" y="324" width="250" height="36" rx="6" fill="#1a1a2e" stroke="#6366f1" stroke-width="1"/>
  <text x="410" y="347" fill="#a5b4fc" text-anchor="middle">Handling user input / forms?</text>

  <!-- YES → Form -->
  <line x1="535" y1="342" x2="620" y2="342" stroke="#10b981" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="575" y="336" fill="#10b981" text-anchor="middle" font-size="11">YES</text>
  <rect x="620" y="324" width="160" height="36" rx="6" fill="#134e3a" stroke="#10b981" stroke-width="1.5"/>
  <text x="700" y="347" fill="#34d399" text-anchor="middle" font-weight="bold">TanStack Form</text>

  <!-- NO → Q5 -->
  <line x1="410" y1="360" x2="410" y2="402" stroke="#ef4444" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="418" y="386" fill="#ef4444" font-size="11">NO</text>

  <!-- Q5: Large list? -->
  <rect x="260" y="402" width="300" height="36" rx="6" fill="#1a1a2e" stroke="#6366f1" stroke-width="1"/>
  <text x="410" y="425" fill="#a5b4fc" text-anchor="middle">Rendering a very large list or grid?</text>

  <!-- YES → Virtual -->
  <line x1="560" y1="420" x2="620" y2="420" stroke="#10b981" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="588" y="414" fill="#10b981" text-anchor="middle" font-size="11">YES</text>
  <rect x="620" y="402" width="160" height="36" rx="6" fill="#134e3a" stroke="#10b981" stroke-width="1.5"/>
  <text x="700" y="425" fill="#34d399" text-anchor="middle" font-weight="bold">TanStack Virtual</text>

  <!-- NO → Q6 -->
  <line x1="410" y1="438" x2="410" y2="480" stroke="#ef4444" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="418" y="464" fill="#ef4444" font-size="11">NO</text>

  <!-- Q6: Global client state? -->
  <rect x="260" y="480" width="300" height="36" rx="6" fill="#1a1a2e" stroke="#6366f1" stroke-width="1"/>
  <text x="410" y="503" fill="#a5b4fc" text-anchor="middle">Sharing reactive local state globally?</text>

  <!-- YES → Store -->
  <line x1="560" y1="498" x2="620" y2="498" stroke="#10b981" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="588" y="492" fill="#10b981" text-anchor="middle" font-size="11">YES</text>
  <rect x="620" y="480" width="160" height="36" rx="6" fill="#134e3a" stroke="#10b981" stroke-width="1.5"/>
  <text x="700" y="503" fill="#34d399" text-anchor="middle" font-weight="bold">TanStack Store</text>

  <!-- NO → Q7 -->
  <line x1="410" y1="516" x2="410" y2="558" stroke="#ef4444" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="418" y="542" fill="#ef4444" font-size="11">NO</text>

  <!-- Q7: Full-stack? -->
  <rect x="260" y="558" width="300" height="36" rx="6" fill="#1a1a2e" stroke="#6366f1" stroke-width="1"/>
  <text x="410" y="581" fill="#a5b4fc" text-anchor="middle">Building a full-stack SSR application?</text>

  <!-- YES → Start -->
  <line x1="560" y1="576" x2="620" y2="576" stroke="#10b981" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="588" y="570" fill="#10b981" text-anchor="middle" font-size="11">YES</text>
  <rect x="620" y="558" width="160" height="36" rx="6" fill="#134e3a" stroke="#10b981" stroke-width="1.5"/>
  <text x="700" y="581" fill="#34d399" text-anchor="middle" font-weight="bold">TanStack Start</text>

  <!-- NO → Maybe not TanStack -->
  <line x1="410" y1="594" x2="410" y2="636" stroke="#ef4444" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="418" y="620" fill="#ef4444" font-size="11">NO</text>
  <rect x="270" y="636" width="280" height="36" rx="6" fill="#2d1515" stroke="#ef4444" stroke-width="1"/>
  <text x="410" y="659" fill="#fca5a5" text-anchor="middle">May not need a TanStack library</text>

  <!-- Arrow marker -->
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4b5563"/>
    </marker>
  </defs>

  <!-- Footer note -->
  <text x="410" y="710" fill="#374151" text-anchor="middle" font-size="11">Multiple answers can apply — libraries compose freely</text>

</svg>

---

### Use Case Guide by Library

#### When to Use TanStack Query

Use TanStack Query when your application needs to **fetch, cache, or synchronize data from a server or external API**.

**Strong signals:**
- You are calling REST endpoints or GraphQL APIs from the client
- You need caching with automatic background refresh
- Multiple components need access to the same remote data
- You are managing loading, error, and success states manually today
- You need optimistic UI updates on mutations
- You are dealing with pagination or infinite scroll from an API

**Weak signals (reconsider):**
- Your data is entirely local and never fetched remotely
- You only have one or two simple fetch calls with no caching needs — `useState` + `useEffect` may suffice
- You are on a server-only environment where fetching happens once at request time

**Example scenario:** A dashboard that loads user data, activity feeds, and notifications from separate API endpoints — all needing independent refresh intervals and shared caching.

---

#### When to Use TanStack Router

Use TanStack Router when your application has **multiple views navigated by URL**, and you want **type-safe params, search params, and loaders**.

**Strong signals:**
- You want full TypeScript safety on route params and query strings
- You are managing complex search param state (filters, pagination, sort order stored in the URL)
- You need nested layouts with per-route data loading
- You are starting a new React project and have no router yet
- You want intent-based prefetching (data loads on link hover)

**Weak signals (reconsider):**
- Your app is a single-view tool with no navigation
- You are already deeply invested in React Router and a migration is not justified
- Your framework (Next.js, Remix) provides its own router — adding TanStack Router alongside is not recommended [Inference]

**Example scenario:** An admin application with deeply nested routes (`/org/:orgId/project/:projectId/tasks`), where each segment has typed params and loads its own data.

---

#### When to Use TanStack Table

Use TanStack Table when you need to display **structured, tabular data with interactive features** and want full control over the rendered markup.

**Strong signals:**
- You need sorting, filtering, grouping, or pagination on a dataset
- Your design system requires custom table markup or styling
- You need column pinning, resizing, or visibility toggling
- You are building a data grid for a business application
- You need row selection with controlled state
- Your dataset is large enough to require integration with TanStack Virtual

**Weak signals (reconsider):**
- You only need a simple static table with no interaction — plain HTML or a CSS-only component is sufficient
- Your team needs a fully pre-built datagrid with built-in UI — consider AG Grid or MUI DataGrid instead, as TanStack Table requires you to build the rendering layer yourself

**Example scenario:** A financial reporting tool where users can sort by column, filter by date range, pin key columns, and export selected rows.

---

#### When to Use TanStack Form

Use TanStack Form when you need to manage **complex form state with fine-grained field-level reactivity and validation**.

**Strong signals:**
- Your form has many fields where re-rendering the entire form on each keystroke is a performance concern
- You need schema-based validation (Zod, Valibot, Yup)
- You need async field validation (e.g., checking username availability on blur)
- You have dynamic or array fields (repeating field groups)
- You want validation errors and touched state isolated to individual fields

**Weak signals (reconsider):**
- Your form has two or three fields with simple validation — React Hook Form or even controlled `useState` is simpler to set up
- You are already using React Hook Form with a large library of components built around it — migration cost may outweigh the benefit [Inference]

**Example scenario:** A multi-step onboarding form with dynamic fields, async email validation, and schema-enforced constraints per step.

---

#### When to Use TanStack Virtual

Use TanStack Virtual when rendering a **large number of items causes visible performance problems** and you need DOM virtualization.

**Strong signals:**
- Your list or table has hundreds to tens of thousands of rows
- Scrolling is janky or initial render is slow due to DOM size
- You need to virtualize both rows and columns (2D virtualization)
- You are already using TanStack Table and need to add row virtualization

**Weak signals (reconsider):**
- Your list has fewer than ~100 items — browser rendering is generally adequate and virtualization adds complexity without measurable benefit [Inference]
- Your items have highly dynamic, unpredictable heights and you need battle-tested edge case handling — `react-virtuoso` handles some of these cases with less configuration [Inference]

**Example scenario:** An analytics table with 50,000 rows that must scroll smoothly at 60fps.

---

#### When to Use TanStack Store

Use TanStack Store when you need **reactive, shared client-side state** that is not server state and does not belong in URL state.

**Strong signals:**
- You need a lightweight observable store without adopting a heavier solution like Zustand or Jotai
- You are building a library or component that needs internal reactive state
- You are already deep in the TanStack ecosystem and want a consistent primitive

**Weak signals (reconsider):**
- Your state is local to a single component — `useState` is sufficient
- You need time-travel debugging, middleware, or devtools — Zustand, Redux Toolkit, or Jotai may be better fits
- Your state is actually server data — use TanStack Query instead

**Example scenario:** A multi-panel UI where open/closed state, selected tab, and sidebar width need to be shared across several unrelated components.

---

#### When to Use TanStack Start

Use TanStack Start when you are building a **new full-stack React application** that needs SSR, server functions, and the full TanStack ecosystem from the ground up.

**Strong signals:**
- You want SSR or SSG with React and prefer TanStack Router over Next.js conventions
- You want server functions with end-to-end type safety
- You are starting a greenfield project and want the full TanStack composition
- You want to avoid the Next.js App Router mental model

**Weak signals (reconsider):**
- You are maintaining an existing Next.js or Remix application — migrating is a significant investment with uncertain payoff at this stage [Inference]
- You need a large ecosystem of plugins, deployment integrations, or framework-specific tooling — Next.js has a substantially larger ecosystem as of the knowledge cutoff
- TanStack Start was approaching stable release at the knowledge cutoff; for production-critical applications, verify current stability before committing [Unverified]

**Example scenario:** A new SaaS dashboard application where your team wants type-safe routing, server functions, and integrated Query caching from day one.

---

### Combination Patterns

Some problems call for more than one library. The following are common and well-supported combinations:

#### Query + Table
The most common pairing. Query fetches and caches paginated data; Table handles display, sorting, and filtering logic.

```ts
const { data } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });

const table = useReactTable({
  data: data ?? [],
  columns,
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
});
```

---

#### Table + Virtual
For large datasets where Table alone would render thousands of DOM rows.

```ts
const rowVirtualizer = useVirtualizer({
  count: table.getRowModel().rows.length,
  getScrollElement: () => tableContainerRef.current,
  estimateSize: () => 34,
});
```

---

#### Router + Query
Route loaders fetch data via Query, so navigation and data fetching are coordinated. Data is available before the component renders.

```ts
const route = createRoute({
  loader: ({ context: { queryClient } }) =>
    queryClient.ensureQueryData(usersQueryOptions),
});
```

---

#### Router + Form + Query
A route renders a form (TanStack Form), which on submit calls a mutation (TanStack Query), then navigates on success (TanStack Router).

---

#### Start + Router + Query + Table + Virtual
The full composition for a data-heavy full-stack application. Each layer handles its concern; no single library overreaches.

---

### Choosing Based on Team Context

Beyond technical fit, practical team considerations also affect the right choice:

| Context | Consideration |
|---|---|
| **Greenfield project** | Adopt freely — use the library that matches each concern |
| **Existing React Query v4 project** | Migration to v5 involves API changes; evaluate before upgrading |
| **Team unfamiliar with headless patterns** | TanStack Table in particular requires significant rendering work; assess team readiness |
| **Design system with pre-built components** | If your component library includes a table or form, evaluate whether TanStack adds enough control to justify a second abstraction |
| **Framework constraints** | If your framework (Next.js, Remix) provides routing or data fetching, adding TanStack Router or Query may create conflicts — verify compatibility [Inference] |
| **Bundle size sensitivity** | TanStack libraries are generally lean, but always verify with your bundler's analysis tools |

---

### When Not to Use TanStack

TanStack libraries are high-quality tools, but they are not always the right choice:

- **Simple CRUD with one or two fetches** — `useEffect` + `useState` may be entirely sufficient; TanStack Query adds meaningful value when caching, deduplication, or background refresh is needed
- **Pre-built UI components exist** — If your design system ships its own table, form, or select, adding TanStack introduces a second abstraction to maintain
- **Non-React projects with limited adapter support** — TanStack Router and Start are primarily React-focused; other libraries have adapters but maturity varies [Unverified]
- **Simple static lists** — TanStack Virtual adds complexity; use it only when rendering performance is measurably degraded

---

**Conclusion**

The right TanStack library is the one that matches the **category of problem** you are actually solving. Start by identifying whether your problem is about server state, routing, tabular display, form input, list performance, client state, or full-stack composition. Adopt only what your use case demands. The ecosystem's strength is that each library is excellent at its domain — and when you do need multiple, they compose cleanly without forcing you into a monolithic commitment.

**Next Steps:**
- Identify which problem domain is the most pressing in your current application
- Start with a single library — TanStack Query is the most broadly applicable entry point for most applications
- Review the official docs for your chosen library before beginning integration: [tanstack.com](https://tanstack.com)