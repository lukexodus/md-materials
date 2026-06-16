## What is TanStack

### Overview

TanStack is a collection of high-quality, open-source libraries for building modern web applications. Created and maintained by **Tanner Linsley**, TanStack focuses on headless, framework-agnostic utilities that handle complex application concerns — such as data fetching, state management, routing, and table rendering — without dictating UI or styling decisions.

The name "TanStack" is derived from Tanner Linsley's nickname ("Tan") combined with "Stack," reflecting the idea of a cohesive set of tools that work well together across the JavaScript ecosystem.

---

### Core Philosophy

TanStack libraries are built around several consistent design principles:

- **Headless by design** — Libraries provide logic and state, not markup or styles, giving developers full control over the UI layer.
- **Framework agnostic** — Most TanStack libraries support React, Vue, Solid, Svelte, Angular, and sometimes vanilla JavaScript through adapter packages.
- **TypeScript-first** — All modern TanStack libraries are written in TypeScript and provide strong type inference out of the box.
- **Developer experience (DX) focused** — APIs are designed to reduce boilerplate and surface only what developers need at each level of complexity.

---

### The TanStack Libraries

#### TanStack Query (formerly React Query)

The most widely adopted TanStack library. It handles **server state management** — fetching, caching, synchronizing, and updating asynchronous data.

**Key Points:**
- Automatic background refetching
- Stale-while-revalidate caching strategy
- Query invalidation and mutation support
- Devtools included

**Example:**
```ts
const { data, isLoading } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
});
```

---

#### TanStack Table (formerly React Table)

A **headless table and datagrid** utility for building complex, fully custom tables.

**Key Points:**
- Sorting, filtering, pagination, grouping, and column pinning
- Virtual row support via integration with TanStack Virtual
- Zero UI dependencies — you render the table yourself

**Example:**
```ts
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
});
```

---

#### TanStack Router

A **fully type-safe, file-based or code-based router** for React (with other framework adapters in progress [Unverified]).

**Key Points:**
- End-to-end type safety for routes, params, and search params
- Built-in search param state management
- Loader-based data fetching integrated with routing
- Devtools included

**Example:**
```ts
const route = createRoute({
  getParentRoute: () => rootRoute,
  path: '/users/$userId',
  component: UserComponent,
});
```

---

#### TanStack Form

A **headless form state management** library focused on type safety and performance.

**Key Points:**
- Fine-grained reactivity — only re-renders what changed
- First-class validation with schema libraries (Zod, Valibot, Yup)
- Async validation support

**Example:**
```ts
const form = useForm({
  defaultValues: { username: '' },
  onSubmit: async ({ value }) => console.log(value),
});
```

---

#### TanStack Virtual

A **windowing/virtualization** utility for efficiently rendering large lists, grids, or tables.

**Key Points:**
- Virtualizes rows, columns, or both
- Supports dynamic item sizes
- Works independently or alongside TanStack Table

---

#### TanStack Start

A **full-stack React framework** built on top of TanStack Router. [As of the knowledge cutoff, TanStack Start was in active development / beta — treat specific API details as potentially subject to change.]

**Key Points:**
- Server-side rendering (SSR) and static site generation (SSG)
- Full-stack type safety from server to client
- Built-in support for server functions

---

#### TanStack Store

A **framework-agnostic reactive store** for managing client-side state.

**Key Points:**
- Minimal API surface
- Fine-grained reactivity
- Used internally by other TanStack libraries

---

### Ecosystem Positioning

The table below summarizes how TanStack libraries map to common application concerns:

| Concern | TanStack Solution |
|---|---|
| Server state / data fetching | TanStack Query |
| Routing | TanStack Router |
| Tables and datagrids | TanStack Table |
| Form management | TanStack Form |
| List virtualization | TanStack Virtual |
| Client state | TanStack Store |
| Full-stack framework | TanStack Start |

---

### Framework Support

Most TanStack libraries ship framework-specific adapters. Supported frameworks vary per library but generally include:

- React
- Vue
- Solid
- Svelte
- Angular *(support varies by library)* [Unverified for all libraries]
- Vanilla JavaScript (for some libraries)

---

### Relationship Between Libraries

TanStack libraries are **independent by default** — you can adopt any one of them without the others. However, they are designed to **compose well together**. A common full-stack TanStack setup might combine:

```
TanStack Start (framework)
  └── TanStack Router (routing + loaders)
        └── TanStack Query (server state)
              └── TanStack Table (data display)
                    └── TanStack Virtual (performance)
                          └── TanStack Form (user input)
```

---

### Why TanStack Exists

Before TanStack Query, server state was commonly managed inside general-purpose state managers (Redux, MobX, Zustand), which were designed for client state and required significant boilerplate to handle caching, background sync, and staleness. TanStack Query demonstrated that **server state and client state are fundamentally different problems** that benefit from separate, purpose-built solutions.

This philosophy extends across the TanStack ecosystem: each library solves one domain exceptionally well rather than trying to be a monolithic framework.

---

### Where to Learn More

- Official site: [tanstack.com](https://tanstack.com)
- GitHub organization: [github.com/TanStack](https://github.com/TanStack)
- Each library has dedicated documentation under its own subdomain (e.g., `query.tanstack.com`, `router.tanstack.com`)

---

**Conclusion**

TanStack is best understood not as a single framework but as a **curated ecosystem of best-in-class, headless, type-safe utilities** that address the most common and complex problems in modern web development. Its libraries can be adopted incrementally, composed together, and used across multiple JavaScript frameworks — making TanStack one of the most flexible and influential collections of tools in the current frontend landscape.