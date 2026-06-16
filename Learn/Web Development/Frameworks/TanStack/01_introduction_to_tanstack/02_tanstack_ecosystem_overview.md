## TanStack Ecosystem Overview

### What the Ecosystem Is

The TanStack ecosystem is a **modular, composable collection of open-source libraries** that collectively address the full lifecycle of data and interaction in modern web applications. Rather than a monolithic framework, it is a set of independently adoptable tools unified by shared design principles: headless architecture, framework agnosticism, TypeScript-first development, and fine-grained reactivity.

Each library owns a distinct problem domain. Together, they form a coherent stack that can take an application from routing and data fetching through to rendering, virtualization, and form handling — without imposing opinions on UI or styling.

---

### Ecosystem Map

The following diagram illustrates how TanStack libraries relate to one another across the application layers:

<svg viewBox="0 0 780 540" xmlns="http://www.w3.org/2000/svg" font-family="ui-monospace, monospace" font-size="13">

  <!-- Background -->
  <rect width="780" height="540" fill="#0f1117" rx="12"/>

  <!-- Layer: Full-Stack Framework -->
  <rect x="40" y="30" width="700" height="70" rx="8" fill="#1e2a3a" stroke="#3b82f6" stroke-width="1.5"/>
  <text x="390" y="55" fill="#93c5fd" text-anchor="middle" font-size="11" font-weight="bold" letter-spacing="1">FULL-STACK FRAMEWORK</text>
  <rect x="260" y="62" width="260" height="28" rx="6" fill="#1d3557" stroke="#3b82f6" stroke-width="1"/>
  <text x="390" y="81" fill="#60a5fa" text-anchor="middle" font-weight="bold">TanStack Start</text>

  <!-- Layer: Routing -->
  <rect x="40" y="125" width="700" height="70" rx="8" fill="#1e2a2a" stroke="#10b981" stroke-width="1.5"/>
  <text x="390" y="150" fill="#6ee7b7" text-anchor="middle" font-size="11" font-weight="bold" letter-spacing="1">ROUTING</text>
  <rect x="260" y="157" width="260" height="28" rx="6" fill="#134e3a" stroke="#10b981" stroke-width="1"/>
  <text x="390" y="176" fill="#34d399" text-anchor="middle" font-weight="bold">TanStack Router</text>

  <!-- Layer: Data & State -->
  <rect x="40" y="220" width="700" height="70" rx="8" fill="#2a1e2a" stroke="#a855f7" stroke-width="1.5"/>
  <text x="390" y="245" fill="#d8b4fe" text-anchor="middle" font-size="11" font-weight="bold" letter-spacing="1">DATA &amp; STATE</text>
  <rect x="100" y="252" width="200" height="28" rx="6" fill="#3b1f5e" stroke="#a855f7" stroke-width="1"/>
  <text x="200" y="271" fill="#c084fc" text-anchor="middle" font-weight="bold">TanStack Query</text>
  <rect x="480" y="252" width="200" height="28" rx="6" fill="#3b1f5e" stroke="#a855f7" stroke-width="1"/>
  <text x="580" y="271" fill="#c084fc" text-anchor="middle" font-weight="bold">TanStack Store</text>

  <!-- Layer: UI Concerns -->
  <rect x="40" y="315" width="700" height="70" rx="8" fill="#2a2a1e" stroke="#f59e0b" stroke-width="1.5"/>
  <text x="390" y="340" fill="#fcd34d" text-anchor="middle" font-size="11" font-weight="bold" letter-spacing="1">UI CONCERNS</text>
  <rect x="100" y="347" width="200" height="28" rx="6" fill="#451f1f" stroke="#f59e0b" stroke-width="1"/>
  <text x="200" y="366" fill="#fbbf24" text-anchor="middle" font-weight="bold">TanStack Table</text>
  <rect x="480" y="347" width="200" height="28" rx="6" fill="#451f1f" stroke="#f59e0b" stroke-width="1"/>
  <text x="580" y="366" fill="#fbbf24" text-anchor="middle" font-weight="bold">TanStack Form</text>

  <!-- Layer: Performance -->
  <rect x="40" y="410" width="700" height="70" rx="8" fill="#1e2020" stroke="#64748b" stroke-width="1.5"/>
  <text x="390" y="435" fill="#94a3b8" text-anchor="middle" font-size="11" font-weight="bold" letter-spacing="1">PERFORMANCE</text>
  <rect x="260" y="442" width="260" height="28" rx="6" fill="#1e293b" stroke="#64748b" stroke-width="1"/>
  <text x="390" y="461" fill="#94a3b8" text-anchor="middle" font-weight="bold">TanStack Virtual</text>

  <!-- Connector arrows between layers -->
  <line x1="390" y1="100" x2="390" y2="125" stroke="#4b5563" stroke-width="1.5" stroke-dasharray="4,3"/>
  <line x1="390" y1="195" x2="390" y2="220" stroke="#4b5563" stroke-width="1.5" stroke-dasharray="4,3"/>
  <line x1="390" y1="290" x2="390" y2="315" stroke="#4b5563" stroke-width="1.5" stroke-dasharray="4,3"/>
  <line x1="390" y1="385" x2="390" y2="410" stroke="#4b5563" stroke-width="1.5" stroke-dasharray="4,3"/>

  <!-- Legend -->
  <text x="390" y="510" fill="#4b5563" text-anchor="middle" font-size="11">Each layer is independently adoptable — full composition is optional</text>

</svg>

---

### Library-by-Library Reference

#### TanStack Query

**Domain:** Server state management

The flagship library of the ecosystem. TanStack Query separates **server state** (remote, asynchronous, potentially stale data) from **client state** (local, synchronous, owned by the app). It manages the full lifecycle of a data fetch: loading, caching, background refresh, deduplication, and error handling.

**Key Points:**
- Stale-while-revalidate caching model
- Automatic garbage collection of unused query data
- Optimistic updates via mutations
- Offline support and query persistence plugins
- Devtools for inspecting cache state
- Adapters: React, Vue, Solid, Svelte, Angular

---

#### TanStack Router

**Domain:** Type-safe routing

A router built from the ground up around **end-to-end type safety**. Route params, search params, loader data, and navigation functions are all fully typed without requiring manual type annotations. Supports both file-based and code-based route definitions.

**Key Points:**
- Search params as first-class, type-safe state
- Route loaders with built-in data fetching
- Nested layouts and route contexts
- Intent-based preloading on hover/focus
- Deep integration with TanStack Query for loader caching
- Devtools included

---

#### TanStack Table

**Domain:** Headless table and datagrid logic

Provides all the state and logic needed for sophisticated data tables — without rendering a single DOM element. The consuming application owns the markup entirely.

**Key Points:**
- Sorting, filtering, grouping, pagination, column visibility
- Column pinning and resizing
- Sub-rows and row expansion
- Row selection with controlled or uncontrolled state
- Composable with TanStack Virtual for large datasets
- Adapters: React, Vue, Solid, Svelte, Angular, Vanilla JS

---

#### TanStack Form

**Domain:** Form state management

A headless, performant form library that tracks field state, validation, and submission with **fine-grained reactivity** — meaning individual fields re-render independently rather than triggering whole-form re-renders.

**Key Points:**
- Schema-based validation (Zod, Valibot, Yup, ArkType)
- Sync and async field-level validation
- Array field support
- Framework adapters: React, Vue, Solid, Angular
- Designed to work without a UI component library

---

#### TanStack Virtual

**Domain:** DOM virtualization / windowing

Handles the rendering of **only the visible portion** of a large list or grid, dramatically reducing DOM node count and improving scroll performance.

**Key Points:**
- Vertical, horizontal, and two-dimensional virtualization
- Dynamic item size measurement
- Overscan control for smooth scrolling
- Commonly paired with TanStack Table for large datasets
- Adapters: React, Vue, Solid, Svelte, Vanilla JS

---

#### TanStack Store

**Domain:** Reactive client state

A minimal, framework-agnostic **reactive store primitive**. Used internally by several TanStack libraries, and also available as a standalone client state solution when TanStack Query is not appropriate (e.g., purely local UI state).

**Key Points:**
- Observable store with derived state support
- No opinions on store shape
- Very small bundle footprint
- Framework adapters for React, Solid, Vue, Angular

---

#### TanStack Start

**Domain:** Full-stack React framework

A full-stack framework built on top of TanStack Router, designed to bring **server-side rendering, server functions, and full-stack type safety** to the TanStack ecosystem. [As of the knowledge cutoff, TanStack Start was approaching stable release — specific APIs may have changed.]

**Key Points:**
- File-based routing via TanStack Router
- Server functions with end-to-end type safety
- SSR and SSG support
- Bundled via Vinxi (a Vite-based app bundler)
- Designed to work with TanStack Query for server/client data sync

---

### Shared Design Principles Across the Ecosystem

| Principle | What It Means in Practice |
|---|---|
| **Headless** | Libraries own logic and state, not HTML or CSS |
| **Framework agnostic** | Adapters exist for React, Vue, Solid, Svelte, Angular, and Vanilla JS |
| **TypeScript-first** | Strong inference throughout; explicit annotations rarely needed |
| **Fine-grained reactivity** | Only affected components re-render, not entire trees |
| **Composable** | Libraries integrate cleanly with each other and with third-party tools |
| **Incremental adoption** | Each library can be used in isolation |

---

### Framework Adapter Support Matrix

Adapter availability varies per library and may change as the ecosystem evolves. The following reflects the general state as of the knowledge cutoff. [Unverified for all current versions — check each library's documentation.]

| Library | React | Vue | Solid | Svelte | Angular | Vanilla JS |
|---|---|---|---|---|---|---|
| Query | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Router | ✅ | 🔄 | 🔄 | 🔄 | 🔄 | — |
| Table | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Form | ✅ | ✅ | ✅ | 🔄 | ✅ | — |
| Virtual | ✅ | ✅ | ✅ | ✅ | — | ✅ |
| Store | ✅ | ✅ | ✅ | — | ✅ | ✅ |
| Start | ✅ | — | — | — | — | — |

✅ Supported · 🔄 In progress or partial [Unverified] · — Not available

---

### How Libraries Compose Together

TanStack libraries are designed to be used independently, but they compose naturally. The following illustrates a common integration pattern:

```
TanStack Start
│   Full-stack SSR framework; handles bundling, SSR, server functions
│
└── TanStack Router
│       Routes, loaders, search param state, layout nesting
│
    ├── TanStack Query
    │       Fetches and caches server data; integrates with route loaders
    │
    ├── TanStack Table
    │       Consumes Query data; renders headless table logic
    │   │
    │   └── TanStack Virtual
    │           Virtualizes table rows for large datasets
    │
    ├── TanStack Form
    │       Handles user input, validation, and submission mutations
    │
    └── TanStack Store
            Manages local UI state not suited for Query
```

No single application necessarily uses all of these. The composition is opt-in at every level.

---

### Versioning Conventions

TanStack libraries follow **independent versioning**. A major version bump in one library does not imply changes in others. Each library's major version typically signals:

- Breaking API changes
- Framework adapter changes
- Core architectural shifts (e.g., React Query v3 → v4 → v5 each significantly revised the API)

**Key Points:**
- Always check compatibility between adapter versions and core library versions
- TanStack Query v5 introduced a notably different mutation and observer API compared to v4
- TanStack Router is a complete rewrite from its earlier `react-location` predecessor [Inference]

---

### Ecosystem vs. Alternatives

| Concern | TanStack Approach | Common Alternatives |
|---|---|---|
| Server state | TanStack Query | SWR, RTK Query, Apollo |
| Routing | TanStack Router | React Router, Wouter, Next.js Router |
| Tables | TanStack Table | AG Grid, MUI DataGrid |
| Forms | TanStack Form | React Hook Form, Formik |
| Virtualization | TanStack Virtual | react-window, react-virtuoso |
| Full-stack framework | TanStack Start | Next.js, Remix, SvelteKit |

TanStack's differentiator is consistently **headless design + TypeScript depth + cross-framework reach**, rather than feature breadth alone.

---

### Community and Governance

- **Author:** Tanner Linsley, with an active community of contributors
- **License:** MIT across all libraries
- **Funding:** Supported through GitHub Sponsors and corporate sponsorships
- **Discord:** Active community server for support and discussion
- **Devtools:** Query and Router both ship official devtools packages
- **Official site:** [tanstack.com](https://tanstack.com)

---

**Conclusion**

The TanStack ecosystem is best understood as a **deliberate separation of concerns** applied to the frontend: each major problem — fetching, routing, rendering, virtualization, input — gets its own purpose-built, headless, type-safe library. The result is an ecosystem where individual libraries are excellent standalone tools, and together they form a coherent, composable stack that works across the JavaScript framework landscape without locking developers into a single UI paradigm.