## TanStack Table with Vue

TanStack Table's Vue adapter provides a Vue-idiomatic integration over the framework-agnostic core. It exposes a composable-based API that fits naturally into Vue 3's Composition API, using Vue's reactivity system to drive table state and re-renders.

---

### Installation

```bash
npm install @tanstack/vue-table
```

The `@tanstack/vue-table` package includes the Vue adapter and re-exports everything from `@tanstack/table-core`. No separate core installation is required.

**Key Points:**
- The Vue adapter targets Vue 3 exclusively
- Vue 2 support is not provided by the official adapter [Unverified: confirm for your specific version]

---

### Core Composable: `useVueTable`

The primary entry point is the `useVueTable` composable. It accepts a configuration object and returns a reactive table instance.

```ts
import {
  useVueTable,
  getCoreRowModel,
} from '@tanstack/vue-table'

const table = useVueTable({
  data: data.value,
  columns,
  getCoreRowModel: getCoreRowModel(),
})
```

**Key Points:**
- `useVueTable` wraps the framework-agnostic `createTable` factory
- The returned table instance is a plain object; reactivity is driven by Vue refs and computed properties supplied in the configuration [Inference: behavior may vary depending on how options are provided]
- Unlike React's `useReactTable`, the Vue adapter requires reactive data to be unwrapped (`.value`) when passed directly, or wrapped using a getter pattern for automatic reactivity

---

### Reactivity: The Options Getter Pattern

A critical distinction from the React adapter: to achieve full reactivity, configuration options should be provided as a function returning the options object, not as a plain object literal. This allows the adapter to track reactive dependencies.

```ts
import { ref } from 'vue'
import { useVueTable, getCoreRowModel } from '@tanstack/vue-table'

const data = ref<Person[]>([...])
const sorting = ref<SortingState>([])

const table = useVueTable({
  get data() { return data.value },
  columns,
  get state() {
    return { sorting: sorting.value }
  },
  onSortingChange: updater => {
    sorting.value = typeof updater === 'function'
      ? updater(sorting.value)
      : updater
  },
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
})
```

Alternatively, use `computed` to wrap the full options object:

```ts
const tableOptions = computed(() => ({
  data: data.value,
  columns,
  state: { sorting: sorting.value },
  onSortingChange: ...,
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
}))

const table = useVueTable(tableOptions.value)
```

[Inference: the getter property pattern (`get data() { return data.value }`) is the most commonly demonstrated approach in official TanStack Table Vue examples; behavior may vary across versions]

---

### Defining Columns

Column definitions use the same `createColumnHelper` utility as all other adapters.

```ts
import { createColumnHelper } from '@tanstack/vue-table'

type Person = {
  firstName: string
  lastName: string
  age: number
}

const columnHelper = createColumnHelper<Person>()

const columns = [
  columnHelper.accessor('firstName', {
    header: 'First Name',
    cell: info => info.getValue(),
  }),
  columnHelper.accessor('lastName', {
    header: 'Last Name',
  }),
  columnHelper.accessor('age', {
    header: 'Age',
  }),
]
```

Column definitions are typically defined outside the component or as a non-reactive constant, since they rarely change at runtime.

---

### Rendering with `FlexRender`

The Vue adapter provides a `FlexRender` component (as opposed to React's `flexRender` function). It handles rendering of both static values and Vue components within column definitions.

```vue
<script setup lang="ts">
import { FlexRender, useVueTable, getCoreRowModel } from '@tanstack/vue-table'
</script>

<template>
  <table>
    <thead>
      <tr
        v-for="headerGroup in table.getHeaderGroups()"
        :key="headerGroup.id"
      >
        <th
          v-for="header in headerGroup.headers"
          :key="header.id"
        >
          <FlexRender
            v-if="!header.isPlaceholder"
            :render="header.column.columnDef.header"
            :props="header.getContext()"
          />
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="row in table.getRowModel().rows"
        :key="row.id"
      >
        <td
          v-for="cell in row.getVisibleCells()"
          :key="cell.id"
        >
          <FlexRender
            :render="cell.column.columnDef.cell"
            :props="cell.getContext()"
          />
        </td>
      </tr>
    </tbody>
  </table>
</template>
```

**Key Points:**
- `FlexRender` accepts a `:render` prop (the column def value or component) and a `:props` prop (the cell/header context)
- This is the Vue equivalent of React's `flexRender(def, context)` call
- Static string values, render functions, and Vue components are all valid `:render` values

---

### Full Component Example

A complete single-file component with sorting, filtering, and pagination:

```vue
<script setup lang="ts">
import { ref } from 'vue'
import {
  useVueTable,
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  FlexRender,
  createColumnHelper,
  type SortingState,
  type ColumnFiltersState,
  type PaginationState,
} from '@tanstack/vue-table'

type User = { id: number; name: string; email: string; age: number }

const props = defineProps<{ data: User[] }>()

const columnHelper = createColumnHelper<User>()

const columns = [
  columnHelper.accessor('name', { header: 'Name' }),
  columnHelper.accessor('email', { header: 'Email' }),
  columnHelper.accessor('age', { header: 'Age' }),
]

const sorting = ref<SortingState>([])
const columnFilters = ref<ColumnFiltersState>([])
const pagination = ref<PaginationState>({ pageIndex: 0, pageSize: 5 })

const table = useVueTable({
  get data() { return props.data },
  columns,
  get state() {
    return {
      sorting: sorting.value,
      columnFilters: columnFilters.value,
      pagination: pagination.value,
    }
  },
  onSortingChange: u => {
    sorting.value = typeof u === 'function' ? u(sorting.value) : u
  },
  onColumnFiltersChange: u => {
    columnFilters.value = typeof u === 'function' ? u(columnFilters.value) : u
  },
  onPaginationChange: u => {
    pagination.value = typeof u === 'function' ? u(pagination.value) : u
  },
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
})

function getNameFilter() {
  return (table.getColumn('name')?.getFilterValue() as string) ?? ''
}

function setNameFilter(e: Event) {
  table.getColumn('name')?.setFilterValue((e.target as HTMLInputElement).value)
}
</script>

<template>
  <div>
    <input :value="getNameFilter()" @input="setNameFilter" placeholder="Filter by name..." />

    <table>
      <thead>
        <tr v-for="hg in table.getHeaderGroups()" :key="hg.id">
          <th
            v-for="header in hg.headers"
            :key="header.id"
            @click="header.column.getToggleSortingHandler()?.($event)"
            style="cursor: pointer"
          >
            <FlexRender
              v-if="!header.isPlaceholder"
              :render="header.column.columnDef.header"
              :props="header.getContext()"
            />
            <span v-if="header.column.getIsSorted() === 'asc'"> ↑</span>
            <span v-else-if="header.column.getIsSorted() === 'desc'"> ↓</span>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in table.getRowModel().rows" :key="row.id">
          <td v-for="cell in row.getVisibleCells()" :key="cell.id">
            <FlexRender :render="cell.column.columnDef.cell" :props="cell.getContext()" />
          </td>
        </tr>
      </tbody>
    </table>

    <div>
      <button @click="table.previousPage()" :disabled="!table.getCanPreviousPage()">Previous</button>
      <span>Page {{ table.getState().pagination.pageIndex + 1 }} of {{ table.getPageCount() }}</span>
      <button @click="table.nextPage()" :disabled="!table.getCanNextPage()">Next</button>
    </div>
  </div>
</template>
```

---

### State Management Patterns

#### Local Ref State (Recommended for Most Cases)

Each feature state is held in a `ref` and passed back via the getter pattern:

```ts
const sorting = ref<SortingState>([])

const table = useVueTable({
  get data() { return data.value },
  columns,
  get state() { return { sorting: sorting.value } },
  onSortingChange: u => {
    sorting.value = typeof u === 'function' ? u(sorting.value) : u
  },
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
})
```

#### Pinia Integration

For shared or persisted table state, Pinia stores work as a drop-in replacement:

```ts
import { useTableStore } from '@/stores/table'

const store = useTableStore()

const table = useVueTable({
  get data() { return store.rows },
  columns,
  get state() { return { sorting: store.sorting } },
  onSortingChange: u => store.setSorting(u),
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
})
```

[Inference: Pinia integration follows naturally from Vue's reactivity model; specific behavior depends on store structure and version]

---

### Sorting

```ts
const sorting = ref<SortingState>([])

const table = useVueTable({
  get data() { return data.value },
  columns,
  get state() { return { sorting: sorting.value } },
  onSortingChange: u => {
    sorting.value = typeof u === 'function' ? u(sorting.value) : u
  },
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
})
```

In the template:

```vue
<th
  v-for="header in headerGroup.headers"
  :key="header.id"
  @click="header.column.getToggleSortingHandler()?.($event)"
>
  <FlexRender :render="header.column.columnDef.header" :props="header.getContext()" />
  <span>{{ header.column.getIsSorted() === 'asc' ? '↑' : header.column.getIsSorted() === 'desc' ? '↓' : '' }}</span>
</th>
```

**Key Points:**
- `getToggleSortingHandler()` returns an event handler function; invoke it with the native event via optional chaining
- Multi-sort is supported; configure with `enableMultiSort` and `maxMultiSortColCount`

---

### Column Filtering

```ts
const columnFilters = ref<ColumnFiltersState>([])

const table = useVueTable({
  get data() { return data.value },
  columns,
  get state() { return { columnFilters: columnFilters.value } },
  onColumnFiltersChange: u => {
    columnFilters.value = typeof u === 'function' ? u(columnFilters.value) : u
  },
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
})
```

```vue
<input
  :value="table.getColumn('name')?.getFilterValue() as string ?? ''"
  @input="e => table.getColumn('name')?.setFilterValue((e.target as HTMLInputElement).value)"
  placeholder="Filter by name..."
/>
```

---

### Global Filtering

```ts
const globalFilter = ref('')

const table = useVueTable({
  get data() { return data.value },
  columns,
  get state() { return { globalFilter: globalFilter.value } },
  onGlobalFilterChange: u => {
    globalFilter.value = typeof u === 'function' ? u(globalFilter.value) : u
  },
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
})
```

```vue
<input v-model="globalFilter" placeholder="Search all columns..." />
```

**Key Points:**
- `v-model` on a ref works cleanly for global filter because the handler updates a single scalar value
- For column filters with complex state shapes, manual `onColumnFiltersChange` handlers are safer

---

### Pagination

```ts
const pagination = ref<PaginationState>({ pageIndex: 0, pageSize: 10 })

const table = useVueTable({
  get data() { return data.value },
  columns,
  get state() { return { pagination: pagination.value } },
  onPaginationChange: u => {
    pagination.value = typeof u === 'function' ? u(pagination.value) : u
  },
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
})
```

```vue
<button @click="table.previousPage()" :disabled="!table.getCanPreviousPage()">Previous</button>
<span>Page {{ table.getState().pagination.pageIndex + 1 }} of {{ table.getPageCount() }}</span>
<button @click="table.nextPage()" :disabled="!table.getCanNextPage()">Next</button>
<select v-model="pagination.pageSize">
  <option v-for="size in [5, 10, 20, 50]" :key="size" :value="size">{{ size }} / page</option>
</select>
```

---

### Server-Side Data

```ts
const table = useVueTable({
  get data() { return serverData.value },
  columns,
  rowCount: serverTotal.value,
  get state() {
    return {
      sorting: sorting.value,
      columnFilters: columnFilters.value,
      pagination: pagination.value,
    }
  },
  onSortingChange: u => { sorting.value = typeof u === 'function' ? u(sorting.value) : u },
  onColumnFiltersChange: u => { columnFilters.value = typeof u === 'function' ? u(columnFilters.value) : u },
  onPaginationChange: u => { pagination.value = typeof u === 'function' ? u(pagination.value) : u },
  manualSorting: true,
  manualFiltering: true,
  manualPagination: true,
  getCoreRowModel: getCoreRowModel(),
})
```

Watch state changes to trigger fetches:

```ts
watch([sorting, columnFilters, pagination], () => {
  fetchData({
    sorting: sorting.value,
    filters: columnFilters.value,
    pagination: pagination.value,
  })
}, { deep: true })
```

---

### Column Visibility

```ts
const columnVisibility = ref<VisibilityState>({})

const table = useVueTable({
  get data() { return data.value },
  columns,
  get state() { return { columnVisibility: columnVisibility.value } },
  onColumnVisibilityChange: u => {
    columnVisibility.value = typeof u === 'function' ? u(columnVisibility.value) : u
  },
  getCoreRowModel: getCoreRowModel(),
})
```

```vue
<label v-for="col in table.getAllLeafColumns()" :key="col.id">
  <input
    type="checkbox"
    :checked="col.getIsVisible()"
    @change="col.getToggleVisibilityHandler()?.($event)"
  />
  {{ col.id }}
</label>
```

---

### Row Selection

```ts
const rowSelection = ref<RowSelectionState>({})

const table = useVueTable({
  get data() { return data.value },
  columns,
  get state() { return { rowSelection: rowSelection.value } },
  onRowSelectionChange: u => {
    rowSelection.value = typeof u === 'function' ? u(rowSelection.value) : u
  },
  enableRowSelection: true,
  getCoreRowModel: getCoreRowModel(),
})
```

Checkbox display column:

```ts
columnHelper.display({
  id: 'select',
  header: ({ table }) => h('input', {
    type: 'checkbox',
    checked: table.getIsAllPageRowsSelected(),
    onChange: table.getToggleAllPageRowsSelectedHandler(),
  }),
  cell: ({ row }) => h('input', {
    type: 'checkbox',
    checked: row.getIsSelected(),
    disabled: !row.getCanSelect(),
    onChange: row.getToggleSelectedHandler(),
  }),
})
```

Or define the column using a Vue component via `cell: () => <CheckboxCell />` in a TSX-enabled setup.

---

### Row Expansion

```ts
const expanded = ref<ExpandedState>({})

const table = useVueTable({
  get data() { return data.value },
  columns,
  get state() { return { expanded: expanded.value } },
  onExpandedChange: u => {
    expanded.value = typeof u === 'function' ? u(expanded.value) : u
  },
  getSubRows: row => row.subRows,
  getCoreRowModel: getCoreRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
})
```

---

### Vue-Specific Considerations

#### Updater Functions

All `on[Feature]Change` handlers in TanStack Table may receive either a plain value or an updater function `(prev) => next`. Vue's reactivity does not automatically unwrap this — you must handle both cases explicitly:

```ts
onSortingChange: updater => {
  sorting.value = typeof updater === 'function'
    ? updater(sorting.value)
    : updater
}
```

This pattern is required for every state handler. Omitting the function branch will cause incorrect state updates when TanStack Table passes a functional updater. [Inference: this is a documented requirement; behavior may vary if the table always passes plain values in a specific version — do not rely on that assumption]

#### Shallow vs Deep Reactivity

Table state objects (e.g. `SortingState`, `ColumnFiltersState`) are arrays or objects. Using `ref` creates deep reactivity by default in Vue 3. For large datasets, `shallowRef` may be preferred for performance, but requires manual triggering on nested mutations. [Inference: tradeoffs depend on dataset size and mutation patterns; test in your environment]

#### Template vs Render Functions

TanStack Table column `cell` and `header` definitions can use:
- Plain strings or scalar values
- Vue render functions (`h(...)`)
- Imported Vue components (passed directly as the value)

```ts
import MyCell from './MyCell.vue'

columnHelper.accessor('name', {
  cell: MyCell,           // Vue component
  header: () => h('strong', 'Name'),  // render function
})
```

---

### Architecture Overview

<svg viewBox="0 0 700 360" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Core -->
  <rect x="200" y="20" width="300" height="60" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="350" y="46" text-anchor="middle" fill="#38bdf8" font-size="12" font-weight="bold">@tanstack/table-core</text>
  <text x="350" y="66" text-anchor="middle" fill="#94a3b8" font-size="11">createTable · row models · features</text>

  <!-- Adapter -->
  <rect x="200" y="130" width="300" height="60" rx="8" fill="#1e293b" stroke="#a78bfa" stroke-width="1.5"/>
  <text x="350" y="156" text-anchor="middle" fill="#a78bfa" font-size="12" font-weight="bold">@tanstack/vue-table</text>
  <text x="350" y="176" text-anchor="middle" fill="#94a3b8" font-size="11">useVueTable · FlexRender</text>

  <!-- Vue Reactivity -->
  <rect x="380" y="250" width="180" height="60" rx="8" fill="#1e293b" stroke="#fb923c" stroke-width="1.5"/>
  <text x="470" y="276" text-anchor="middle" fill="#fb923c" font-size="12" font-weight="bold">Vue Reactivity</text>
  <text x="470" y="296" text-anchor="middle" fill="#94a3b8" font-size="11">ref · computed · watch</text>

  <!-- Template -->
  <rect x="140" y="250" width="180" height="60" rx="8" fill="#1e293b" stroke="#34d399" stroke-width="1.5"/>
  <text x="230" y="276" text-anchor="middle" fill="#34d399" font-size="12" font-weight="bold">SFC Template</text>
  <text x="230" y="296" text-anchor="middle" fill="#94a3b8" font-size="11">v-for · FlexRender · v-model</text>

  <!-- Arrows -->
  <line x1="350" y1="80" x2="350" y2="130" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr2)"/>
  <line x1="280" y1="190" x2="230" y2="250" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr2)"/>
  <line x1="420" y1="190" x2="470" y2="250" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr2)"/>

  <defs>
    <marker id="arr2" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
      <path d="M0,0 L0,8 L8,4 z" fill="#64748b"/>
    </marker>
  </defs>
</svg>

---

### Comparison: React vs Vue Adapter Patterns

| Concern | React | Vue |
|---|---|---|
| Entry point | `useReactTable` | `useVueTable` |
| Render helper | `flexRender(def, ctx)` | `<FlexRender :render="def" :props="ctx" />` |
| State | `useState` | `ref` |
| Reactivity trigger | React re-render | Vue reactive dependency tracking |
| Options reactivity | Stable object sufficient | Getter pattern recommended |
| Updater handling | Handled by React dispatch | Manual `typeof updater === 'function'` check required |
| External state | Zustand, Redux, etc. | Pinia, Vuex, composables |

---

**Related Topics**

- TanStack Table with Svelte
- TanStack Table with Angular
- TanStack Table with Solid
- Vue 3 Composition API Patterns for Table State
- Pinia Integration with TanStack Table
- Server-Side Sorting, Filtering, and Pagination in Vue
- FlexRender Deep Dive: Components vs Render Functions
- Column Definitions with Vue Components
- Row Virtualization in Vue with `@tanstack/vue-virtual`
- Updater Function Pattern in TanStack Libraries