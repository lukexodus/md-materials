## Installation and Project Setup

### Overview

TanStack libraries are distributed as individual npm packages. There is no single "TanStack" meta-package that installs the full ecosystem — each library is installed separately, alongside its framework adapter if one is required. This keeps bundle sizes minimal and allows incremental adoption.

This guide covers installation and initial project setup for each major TanStack library, with a focus on React as the primary adapter. Framework-specific variations are noted where they differ meaningfully.

---

### Prerequisites

Before installing any TanStack library, confirm your environment meets the general baseline:

| Requirement | Recommended |
|---|---|
| Node.js | 18.x or later (LTS) |
| Package manager | npm, pnpm, yarn, or bun |
| TypeScript | 5.x recommended for full type inference |
| React | 18.x for React adapter packages |
| Bundler | Vite, Webpack 5, or Turbopack |

TanStack libraries do not require TypeScript, but the type inference they provide is a primary value driver. Using plain JavaScript forfeits a significant portion of the developer experience — particularly in TanStack Router and TanStack Form.

---

### TanStack Query

#### Installation

```bash
# npm
npm install @tanstack/react-query

# pnpm
pnpm add @tanstack/react-query

# yarn
yarn add @tanstack/react-query

# bun
bun add @tanstack/react-query
```

#### Devtools (optional but recommended)

```bash
npm install @tanstack/react-query-devtools
```

#### Project Setup

TanStack Query requires a `QueryClient` instance and a `QueryClientProvider` wrapping your application. This is typically placed at the root of your component tree.

```tsx
// main.tsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import App from './App'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,   // 5 minutes
      retry: 1,
    },
  },
})

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <App />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  </StrictMode>
)
```

**Key Points:**
- `QueryClient` holds the cache and default configuration
- `defaultOptions` sets fallback behavior for all queries and mutations
- `ReactQueryDevtools` renders a floating panel for inspecting cache state — it is automatically excluded from production builds when `process.env.NODE_ENV === 'production'` [behavior may vary depending on bundler configuration]
- Only one `QueryClientProvider` should exist per application; nesting multiple providers creates separate cache contexts

#### Verifying the Setup

```tsx
// App.tsx
import { useQuery } from '@tanstack/react-query'

function App() {
  const { data, isLoading, isError } = useQuery({
    queryKey: ['health-check'],
    queryFn: () => Promise.resolve({ status: 'ok' }),
  })

  if (isLoading) return <p>Loading...</p>
  if (isError) return <p>Error</p>
  return <p>Status: {data?.status}</p>
}
```

**Output:** `Status: ok` — confirms the provider and query hook are wired correctly.

---

### TanStack Router

TanStack Router has two setup modes: **file-based routing** (recommended for most projects) and **code-based routing** (manual route tree construction). File-based routing requires a Vite plugin.

#### Installation

```bash
# Core router
npm install @tanstack/react-router

# Vite plugin for file-based routing (recommended)
npm install --save-dev @tanstack/router-plugin

# Devtools (optional)
npm install @tanstack/router-devtools
```

#### File-Based Routing Setup (Vite)

**Step 1 — Configure the Vite plugin:**

```ts
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { TanStackRouterVite } from '@tanstack/router-plugin/vite'

export default defineConfig({
  plugins: [
    TanStackRouterVite(),   // must come before react()
    react(),
  ],
})
```

**Step 2 — Create the routes directory:**

```
src/
  routes/
    __root.tsx      ← root layout route
    index.tsx       ← matches "/"
    about.tsx       ← matches "/about"
```

**Step 3 — Define the root route:**

```tsx
// src/routes/__root.tsx
import { createRootRoute, Link, Outlet } from '@tanstack/react-router'
import { TanStackRouterDevtools } from '@tanstack/router-devtools'

export const Route = createRootRoute({
  component: () => (
    <>
      <nav>
        <Link to="/">Home</Link>
        <Link to="/about">About</Link>
      </nav>
      <Outlet />
      <TanStackRouterDevtools />
    </>
  ),
})
```

**Step 4 — Define a page route:**

```tsx
// src/routes/index.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({
  component: () => <h1>Home</h1>,
})
```

**Step 5 — Wire the router in main.tsx:**

The Vite plugin auto-generates a `routeTree.gen.ts` file. Import it to construct the router:

```tsx
// src/main.tsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { RouterProvider, createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'   // auto-generated

const router = createRouter({ routeTree })

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <RouterProvider router={router} />
  </StrictMode>
)
```

**Key Points:**
- The `declare module` block enables global type registration — this is what makes route params and search params fully typed across the app
- `routeTree.gen.ts` is regenerated automatically by the Vite plugin on file changes — do not edit it manually
- The plugin watches the `routes/` directory by default; this is configurable in `vite.config.ts`

#### Code-Based Routing Setup (no Vite plugin)

For environments where the Vite plugin is not available:

```tsx
import { createRouter, createRoute, createRootRoute } from '@tanstack/react-router'

const rootRoute = createRootRoute({
  component: () => <Outlet />,
})

const indexRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/',
  component: () => <h1>Home</h1>,
})

const routeTree = rootRoute.addChildren([indexRoute])
const router = createRouter({ routeTree })
```

---

### TanStack Table

#### Installation

```bash
npm install @tanstack/react-table
```

TanStack Table has no peer dependencies beyond React. There is no provider or context setup required — the table instance is created directly inside your component.

#### Minimal Setup

```tsx
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  useReactTable,
} from '@tanstack/react-table'

type User = { id: number; name: string; email: string }

const columnHelper = createColumnHelper<User>()

const columns = [
  columnHelper.accessor('id',    { header: 'ID' }),
  columnHelper.accessor('name',  { header: 'Name' }),
  columnHelper.accessor('email', { header: 'Email' }),
]

const data: User[] = [
  { id: 1, name: 'Alice', email: 'alice@example.com' },
  { id: 2, name: 'Bob',   email: 'bob@example.com' },
]

function UserTable() {
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  })

  return (
    <table>
      <thead>
        {table.getHeaderGroups().map(headerGroup => (
          <tr key={headerGroup.id}>
            {headerGroup.headers.map(header => (
              <th key={header.id}>
                {flexRender(header.column.columnDef.header, header.getContext())}
              </th>
            ))}
          </tr>
        ))}
      </thead>
      <tbody>
        {table.getRowModel().rows.map(row => (
          <tr key={row.id}>
            {row.getVisibleCells().map(cell => (
              <td key={cell.id}>
                {flexRender(cell.column.columnDef.cell, cell.getContext())}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  )
}
```

**Key Points:**
- `createColumnHelper` provides type-safe column definitions
- `getCoreRowModel` is always required; additional row models (sort, filter, pagination) are added as needed
- No styles are applied by TanStack Table — all HTML and CSS is your responsibility

---

### TanStack Form

#### Installation

```bash
npm install @tanstack/react-form
```

For schema validation, install the relevant adapter alongside your schema library:

```bash
# Zod
npm install zod @tanstack/zod-form-adapter

# Valibot
npm install valibot @tanstack/valibot-form-adapter

# Yup
npm install yup @tanstack/yup-form-adapter
```

#### Minimal Setup

```tsx
import { useForm } from '@tanstack/react-form'

function SignupForm() {
  const form = useForm({
    defaultValues: {
      username: '',
      email: '',
    },
    onSubmit: async ({ value }) => {
      console.log('Submitted:', value)
    },
  })

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault()
        form.handleSubmit()
      }}
    >
      <form.Field name="username">
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
            onBlur={field.handleBlur}
            placeholder="Username"
          />
        )}
      </form.Field>

      <form.Field name="email">
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
            onBlur={field.handleBlur}
            placeholder="Email"
          />
        )}
      </form.Field>

      <button type="submit">Sign Up</button>
    </form>
  )
}
```

**Key Points:**
- `useForm` creates an isolated form instance per component
- `form.Field` renders a render-prop component that subscribes only to that field's state
- No global provider is required

#### With Zod Validation

```tsx
import { useForm } from '@tanstack/react-form'
import { zodValidator } from '@tanstack/zod-form-adapter'
import { z } from 'zod'

const form = useForm({
  defaultValues: { email: '' },
  validatorAdapter: zodValidator(),
  onSubmit: async ({ value }) => console.log(value),
})

// Inside form.Field:
<form.Field
  name="email"
  validators={{
    onChange: z.string().email('Invalid email address'),
  }}
>
  {(field) => (
    <>
      <input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
      />
      {field.state.meta.errors.map((err) => (
        <span key={err}>{err}</span>
      ))}
    </>
  )}
</form.Field>
```

---

### TanStack Virtual

#### Installation

```bash
npm install @tanstack/react-virtual
```

#### Minimal Setup

```tsx
import { useRef } from 'react'
import { useVirtualizer } from '@tanstack/react-virtual'

const items = Array.from({ length: 10_000 }, (_, i) => `Item ${i + 1}`)

function VirtualList() {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 40,   // estimated row height in px
  })

  return (
    <div ref={parentRef} style={{ height: '500px', overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map((virtualItem) => (
          <div
            key={virtualItem.key}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: `${virtualItem.size}px`,
              transform: `translateY(${virtualItem.start}px)`,
            }}
          >
            {items[virtualItem.index]}
          </div>
        ))}
      </div>
    </div>
  )
}
```

**Key Points:**
- The scroll container must have a fixed height and `overflow: auto` or `overflow: scroll`
- `estimateSize` is used for initial layout — actual sizes can be measured dynamically
- `getTotalSize()` sets the total scrollable height so the scrollbar reflects the full list

---

### TanStack Store

#### Installation

```bash
npm install @tanstack/store

# React adapter
npm install @tanstack/react-store
```

#### Minimal Setup

```tsx
import { Store } from '@tanstack/store'
import { useStore } from '@tanstack/react-store'

const counterStore = new Store({ count: 0 })

function Counter() {
  const count = useStore(counterStore, (state) => state.count)

  return (
    <div>
      <p>Count: {count}</p>
      <button
        onClick={() =>
          counterStore.setState((prev) => ({ count: prev.count + 1 }))
        }
      >
        Increment
      </button>
    </div>
  )
}
```

**Key Points:**
- `Store` is created outside the component — it persists for the lifetime of the module
- `useStore` accepts a selector; only the selected slice triggers re-renders
- No provider is needed

---

### TanStack Start

TanStack Start is a full-stack framework rather than a library addon. It is scaffolded as a project rather than installed into an existing one.

#### Scaffolding a New Project

```bash
# Using the official starter (verify current scaffold command at tanstack.com/start)
npx create-tsrouter-app@latest my-app --template start-basic

cd my-app
npm install
npm run dev
```

[The scaffold command and template names may change as TanStack Start approaches and passes stable release — verify at the official documentation before use. Unverified for current state.]

#### Key Files in a Start Project

```
my-app/
  src/
    routes/
      __root.tsx         ← root layout
      index.tsx          ← home route
    client.tsx           ← client entry point
    router.tsx           ← router configuration
    server.tsx           ← server entry point (SSR)
  app.config.ts          ← TanStack Start / Vinxi config
  vite.config.ts
  tsconfig.json
  package.json
```

**Key Points:**
- TanStack Start uses **Vinxi** as its underlying build tool (built on Vite)
- Server functions are defined with `createServerFn` and run on the server
- The project structure enforces the separation of client and server entry points

---

### TypeScript Configuration

All TanStack libraries benefit from strict TypeScript settings. The following `tsconfig.json` baseline is recommended:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "skipLibCheck": true
  }
}
```

**Key Points:**
- `strict: true` is required for TanStack Router's type inference to function correctly
- `moduleResolution: "bundler"` is the correct setting for Vite-based projects
- `noUncheckedIndexedAccess` helps catch array access bugs — particularly relevant when working with TanStack Table row and cell data [Inference]

---

### Installing Multiple Libraries Together

When combining libraries, install all packages in a single command to allow the package manager to resolve peer dependencies together:

```bash
npm install \
  @tanstack/react-query \
  @tanstack/react-query-devtools \
  @tanstack/react-router \
  @tanstack/router-devtools \
  @tanstack/react-table \
  @tanstack/react-form \
  @tanstack/react-virtual \
  @tanstack/store \
  @tanstack/react-store
```

The combined setup order in `main.tsx` when using Query and Router together:

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { RouterProvider, createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

const queryClient = new QueryClient()
const router = createRouter({
  routeTree,
  context: { queryClient },   // passes queryClient into route loaders
})

declare module '@tanstack/react-router' {
  interface Register { router: typeof router }
}

createRoot(document.getElementById('root')!).render(
  <QueryClientProvider client={queryClient}>
    <RouterProvider router={router} />
  </QueryClientProvider>
)
```

**Key Points:**
- `QueryClientProvider` wraps `RouterProvider` so the query client is available inside route components
- Passing `queryClient` into the router context makes it available to route loaders for prefetching
- The `Register` interface declaration must be done once globally — typically in `main.tsx`

---

### Version Pinning and Compatibility

TanStack libraries version independently. When installing, be deliberate about versions:

```bash
# Install a specific version
npm install @tanstack/react-query@5.62.0

# Check what is installed
npm list @tanstack/react-query
```

**Key Points:**
- Major versions contain breaking API changes — do not upgrade major versions without consulting the migration guide
- Adapter packages (e.g., `@tanstack/react-query`) must match the core package version where applicable — mismatches may cause runtime errors [behavior may vary]
- Check each library's changelog at its GitHub repository before upgrading in a production project

---

**Conclusion**

Each TanStack library is installed independently as a scoped npm package. Most require no global provider setup except TanStack Query (which needs `QueryClientProvider`) and TanStack Router (which needs `RouterProvider`). TypeScript strict mode should be enabled from the start — particularly for TanStack Router, where the type inference system depends on it. When combining libraries, the most common root setup pairs `QueryClientProvider` wrapping `RouterProvider`, with the query client passed through router context for loader access.

**Next Steps:**
- Proceed to the core concepts of your chosen library
- For Query: explore `useQuery` and `useMutation` in depth
- For Router: explore file-based routing, params, and loaders
- For Table: explore column definitions, sorting, and filtering models