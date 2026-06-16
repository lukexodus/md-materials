## TanStack Table

TanStack Table is a headless, framework-agnostic table and data grid library. It provides the logic, state management, and type infrastructure for building tables — sorting, filtering, pagination, grouping, column visibility, row selection, and more — without imposing any markup, styles, or DOM structure. The UI is entirely the developer's responsibility.

---

### What "Headless" Means

Headless means the library ships no HTML, no CSS, and no pre-built components. It provides a table instance — an object containing state, computed values, and handler functions — which the developer uses to drive their own markup.

**Key Points:**
- Full control over rendered HTML — `<table>`, `<div>`-based grids, virtualized lists, or any structure
- No style conflicts with existing design systems
- No dependency on a specific UI component library
- Behavior and accessibility are the developer's implementation responsibility

---

### Framework Support

TanStack Table is the framework-specific binding layer over the core `@tanstack/table-core` package.

| Package | Framework |
|---------|-----------|
| `@tanstack/react-table` | React |
| `@tanstack/vue-table` | Vue 3 |
| `@tanstack/solid-table` | SolidJS |
| `@tanstack/svelte-table` | Svelte |
| `@tanstack/angular-table` | Angular |
| `@tanstack/qwik-table` | Qwik |
| `@tanstack/table-core` | Framework-agnostic core |

All framework adapters expose the same API surface with idiomatic bindings for reactivity per framework.

---

### Core Concepts

#### Table Instance

The central object. Created once per table, it holds all state and exposes methods for interacting with rows, columns, and cells.

```ts
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
})
```

#### Column Definitions

Columns are declared as an array of `ColumnDef` objects. They describe how to access data, how to render header and cell content, and what features apply to that column.

```ts
import { createColumnHelper } from '@tanstack/react-table'

type Person = { name: string; age: number; email: string }

const columnHelper = createColumnHelper<Person>()

const columns = [
  columnHelper.accessor('name', {
    header: 'Name',
    cell: info => info.getValue(),
  }),
  columnHelper.accessor('age', {
    header: 'Age',
  }),
  columnHelper.accessor('email', {
    header: 'Email',
  }),
]
```

**Key Points:**
- `createColumnHelper` provides type-safe accessors tied to the data type
- Columns can use `accessor` (mapped to a data key) or `display` (arbitrary content, no data key)
- Header and cell renderers receive a rich context object, not just the raw value

#### Data

The `data` array is the source of truth. TanStack Table does not mutate it. Each element corresponds to a row.

```ts
const data: Person[] = [
  { name: 'Alice', age: 30, email: 'alice@example.com' },
  { name: 'Bob', age: 25, email: 'bob@example.com' },
]
```

**Key Points:**
- `data` should be stable across renders — a new array reference on every render causes unnecessary recomputation [Inference — behavior may vary; memoize `data` with `useMemo` in React as a precaution]
- TanStack Table does not require a specific shape — any array of objects works

#### Row Model

The row model pipeline is explicit and opt-in. Each feature requires its row model to be passed to `useReactTable`.

```ts
import {
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
} from '@tanstack/react-table'

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),       // required
  getSortedRowModel: getSortedRowModel(),   // opt-in sorting
  getFilteredRowModel: getFilteredRowModel(), // opt-in filtering
  getPaginationRowModel: getPaginationRowModel(), // opt-in pagination
})
```

**Key Points:**
- Only include row models for features actually used — unused models add computation without benefit
- The pipeline is ordered: filtering runs before sorting, sorting before pagination [Inference — verify exact pipeline order in current docs]

---

### Rendering a Basic Table

TanStack Table exposes methods to iterate over headers, rows, and cells. The developer maps these to markup.

```tsx
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
```

`flexRender` is a utility that handles both function renderers and static values uniformly.

---

### Built-in Features

TanStack Table supports the following features via its row model and state system:

| Feature | Row model / option |
|---------|-------------------|
| Sorting | `getSortedRowModel` |
| Filtering (column) | `getFilteredRowModel` |
| Global filtering | `getFilteredRowModel` + `globalFilter` state |
| Pagination | `getPaginationRowModel` |
| Row grouping | `getGroupedRowModel` |
| Aggregation | Configured per column alongside grouping |
| Row selection | State-based, no separate row model |
| Column visibility | State-based |
| Column ordering | State-based |
| Column pinning | State-based |
| Column resizing | State-based |
| Row expanding | `getExpandedRowModel` |
| Sub-rows (tree data) | `getSubRows` option |
| Faceting | `getFacetedRowModel`, `getFacetedUniqueValues` |

---

### State Management

TanStack Table manages its own internal state by default. State can be fully or partially externalized — useful when state must be persisted, shared, or driven by a URL.

```ts
const [sorting, setSorting] = React.useState([])

const table = useReactTable({
  data,
  columns,
  state: { sorting },
  onSortingChange: setSorting,
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
})
```

**Key Points:**
- Any state slice can be controlled externally by providing both `state.X` and `onXChange`
- Uncontrolled slices fall back to the table's internal state
- This pattern enables URL-driven tables when combined with TanStack Router search params

---

### Server-Side Operations

For large datasets, sorting, filtering, and pagination can be delegated to the server. TanStack Table handles the state and UI; the developer supplies data fetching.

```ts
const table = useReactTable({
  data,          // current page data from server
  columns,
  pageCount,     // total page count from server
  state: { sorting, pagination },
  onSortingChange: setSorting,
  onPaginationChange: setPagination,
  manualSorting: true,
  manualPagination: true,
  getCoreRowModel: getCoreRowModel(),
})
```

**Key Points:**
- `manualSorting`, `manualFiltering`, and `manualPagination` disable the client-side row model transformations
- The developer is responsible for using the table's state to construct server requests
- `pageCount` must be supplied externally when using server-side pagination

---

### Type Safety

TanStack Table is fully generic over the row data type. All column definitions, cell values, accessors, and row model outputs are typed against the provided data type.

```ts
// All column accessors are constrained to keys of Person
const columns = [
  columnHelper.accessor('name', { ... }),   // ✓
  columnHelper.accessor('unknown', { ... }) // ✗ TypeScript error
]
```

**Key Points:**
- `createColumnHelper<T>()` anchors the type to `T` for all column definitions
- `row.original` is typed as `T`
- Cell `getValue()` returns the type of the accessed field

---

### Relationship to Other TanStack Libraries

TanStack Table is independent of TanStack Router and TanStack Query but composes naturally with both.

- **With TanStack Query:** Query manages server data fetching; Table consumes the result as `data`
- **With TanStack Router:** Router search params drive table state (sorting, filtering, pagination) for URL-persistent tables
- **With TanStack Virtual:** Virtualizes rendered rows for large datasets without DOM overhead

---

### What TanStack Table Is Not

- Not a pre-built data grid component — no default styles or layout
- Not an opinionated UI kit — pairing with shadcn/ui, Radix, Mantine, or any component library is the developer's choice
- Not a server — it does not fetch data; it only transforms and presents it

---

**Related Topics:**
- Column definitions — accessor columns, display columns, grouped columns
- Sorting — client-side and server-side, multi-column sort
- Filtering — column filters, global filter, custom filter functions
- Pagination — client-side and server-side, page size control
- Row selection — single and multi-select patterns
- Column visibility, ordering, and pinning
- Row grouping and aggregation
- Expanding rows and tree data with `getSubRows`
- Virtualizing large tables with `@tanstack/react-virtual`
- URL-driven table state with TanStack Router search params
- Integrating TanStack Table with shadcn/ui table components