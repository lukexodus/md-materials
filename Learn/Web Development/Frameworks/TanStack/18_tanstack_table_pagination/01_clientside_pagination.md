## TanStack Table — Pagination — Client-Side Pagination

### Overview

Client-side pagination in TanStack Table splits a fully loaded dataset into discrete pages, rendering only a subset of rows at a time. All data is present in memory; the table manages which slice is visible based on pagination state. This contrasts with server-side pagination, where only the current page's data is fetched from an API.

---

### Enabling Client-Side Pagination

Client-side pagination requires registering the `getPaginationRowModel` function in the table options.

```ts
import {
  useReactTable,
  getCoreRowModel,
  getPaginationRowModel,
} from '@tanstack/react-table'

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
})
```

Once registered, the table automatically slices `data` according to the current pagination state.

---

### Pagination State

Pagination state is controlled by a `pagination` object with two fields:

| Field | Type | Description |
|---|---|---|
| `pageIndex` | `number` | Zero-based index of the current page |
| `pageSize` | `number` | Number of rows per page |

#### Default State

If no pagination state is provided, TanStack Table uses these defaults:

```ts
{ pageIndex: 0, pageSize: 10 }
```

[Inference] Default values may differ across versions. Verify against your installed version's source or changelog.

#### Controlled Pagination State

```ts
const [pagination, setPagination] = useState({
  pageIndex: 0,
  pageSize: 10,
})

const table = useReactTable({
  data,
  columns,
  state: { pagination },
  onPaginationChange: setPagination,
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
})
```

When `state.pagination` and `onPaginationChange` are both provided, pagination is fully controlled — your state is the single source of truth.

#### Uncontrolled (Internal) Pagination State

If `state.pagination` is omitted, the table manages pagination state internally. You can still set initial values using `initialState`:

```ts
const table = useReactTable({
  data,
  columns,
  initialState: {
    pagination: { pageIndex: 0, pageSize: 25 },
  },
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
})
```

`initialState` is only read once on mount. [Inference] Mutating it after initialization has no effect.

---

### Pagination Row Model vs Core Row Model

TanStack Table maintains separate row models for different purposes:

| Row Model | Returned By | Contains |
|---|---|---|
| Core | `table.getCoreRowModel()` | All rows, no filtering or pagination |
| Filtered | `table.getFilteredRowModel()` | Rows passing active filters |
| Paginated | `table.getPaginationRowModel()` | Rows on the current page only |

When rendering the visible table rows, always use `table.getRowModel()`, which returns the final processed row model — the result of the full pipeline including sorting, filtering, and pagination.

```tsx
{table.getRowModel().rows.map(row => (
  <tr key={row.id}>
    {row.getVisibleCells().map(cell => (
      <td key={cell.id}>
        {flexRender(cell.column.columnDef.cell, cell.getContext())}
      </td>
    ))}
  </tr>
))}
```

---

### Pipeline Order

When multiple features are active, row models are composed in a defined order:

```
Core → Filtering → Sorting → Grouping → Expansion → Pagination
```

[Inference] Pagination always operates on the post-filter, post-sort dataset. This means `pageCount` and page navigation reflect the filtered row count, not the total row count — which is the expected behavior for most UIs.

---

### Pagination API

#### Table-Level Methods

| Method | Returns | Description |
|---|---|---|
| `table.getPageCount()` | `number` | Total number of pages based on row count and page size |
| `table.getCanPreviousPage()` | `boolean` | Whether a previous page exists |
| `table.getCanNextPage()` | `boolean` | Whether a next page exists |
| `table.previousPage()` | `void` | Navigate to the previous page |
| `table.nextPage()` | `void` | Navigate to the next page |
| `table.firstPage()` | `void` | Navigate to page 0 |
| `table.lastPage()` | `void` | Navigate to the last page |
| `table.setPageIndex(n)` | `void` | Jump to a specific zero-based page index |
| `table.setPageSize(n)` | `void` | Change the number of rows per page |
| `table.resetPagination()` | `void` | Reset pagination state to initial or default values |

#### State Accessors

```ts
const { pageIndex, pageSize } = table.getState().pagination
```

---

### Rendering a Pagination Control

```tsx
function PaginationControls({ table }) {
  const { pageIndex, pageSize } = table.getState().pagination

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
      <button onClick={() => table.firstPage()} disabled={!table.getCanPreviousPage()}>
        {'<<'}
      </button>
      <button onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
        {'<'}
      </button>

      <span>
        Page {pageIndex + 1} of {table.getPageCount()}
      </span>

      <button onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>
        {'>'}
      </button>
      <button onClick={() => table.lastPage()} disabled={!table.getCanNextPage()}>
        {'>>'}
      </button>

      {/* Jump to page */}
      <input
        type="number"
        min={1}
        max={table.getPageCount()}
        value={pageIndex + 1}
        onChange={e => {
          const page = e.target.value ? Number(e.target.value) - 1 : 0
          table.setPageIndex(page)
        }}
        style={{ width: '4rem' }}
      />

      {/* Page size selector */}
      <select
        value={pageSize}
        onChange={e => table.setPageSize(Number(e.target.value))}
      >
        {[10, 25, 50, 100].map(size => (
          <option key={size} value={size}>
            Show {size}
          </option>
        ))}
      </select>
    </div>
  )
}
```

---

### Row Count and Page Count

#### Automatic Page Count

By default, `getPageCount()` is derived from the number of rows in the filtered row model divided by `pageSize`, rounded up:

```
pageCount = Math.ceil(filteredRowCount / pageSize)
```

#### Manual Row Count Override

For scenarios where the row count is known externally (e.g., a server reports total count even when data is client-side), you can override:

```ts
const table = useReactTable({
  data,
  columns,
  rowCount: 5000, // tells the table the total row count
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
})
```

[Inference] `rowCount` is primarily intended for server-side pagination but can be supplied in client-side contexts when the dataset is paginated before being passed to the table. Behavior when `rowCount` conflicts with the actual length of `data` is [Unverified] — verify against your version's documentation.

---

### Interaction with Filtering

When column filters or global filter are active, pagination automatically reflects the filtered row set. Specifically:

- `getPageCount()` recalculates based on the filtered row count.
- `pageIndex` is **not** automatically reset to `0` when filters change.

[Inference] If filtering reduces the total pages below the current `pageIndex`, the table may display an empty page. It is common practice to reset `pageIndex` to `0` whenever filter state changes:

```ts
const [columnFilters, setColumnFilters] = useState([])

const table = useReactTable({
  data,
  columns,
  state: { columnFilters, pagination },
  onColumnFiltersChange: updater => {
    setColumnFilters(updater)
    setPagination(prev => ({ ...prev, pageIndex: 0 }))
  },
  onPaginationChange: setPagination,
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
})
```

Behavior when `pageIndex` exceeds available pages is [Unverified] — test in your specific version.

---

### Interaction with Sorting

Sorting operates before pagination in the pipeline. Changing sort order does not alter `pageIndex`. [Inference] Whether to reset `pageIndex` on sort change is a UX decision — some applications reset to page 0 on sort, others do not.

---

### Displaying Row Range Information

A common UI pattern is showing "Showing rows X–Y of Z":

```tsx
function RowRangeInfo({ table }) {
  const { pageIndex, pageSize } = table.getState().pagination
  const totalRows = table.getFilteredRowModel().rows.length
  const start = pageIndex * pageSize + 1
  const end = Math.min((pageIndex + 1) * pageSize, totalRows)

  return (
    <span>
      Showing {start}–{end} of {totalRows} rows
    </span>
  )
}
```

---

### Data Flow Diagram

<svg viewBox="0 0 700 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="700" height="200" fill="#0f1117" rx="12"/>

  <!-- Boxes -->
  <rect x="20" y="75" width="110" height="50" rx="7" fill="#1e2130" stroke="#4a90d9" stroke-width="1.5"/>
  <text x="75" y="96" text-anchor="middle" fill="#a0c4ff" font-size="11">Core</text>
  <text x="75" y="112" text-anchor="middle" fill="#6b7db3" font-size="10">All Rows</text>

  <rect x="165" y="75" width="110" height="50" rx="7" fill="#1e2130" stroke="#7ec8a0" stroke-width="1.5"/>
  <text x="220" y="96" text-anchor="middle" fill="#a8e6c0" font-size="11">Filtered</text>
  <text x="220" y="112" text-anchor="middle" fill="#6b7db3" font-size="10">Active Filters</text>

  <rect x="310" y="75" width="110" height="50" rx="7" fill="#1e2130" stroke="#fbbf24" stroke-width="1.5"/>
  <text x="365" y="96" text-anchor="middle" fill="#fde68a" font-size="11">Sorted</text>
  <text x="365" y="112" text-anchor="middle" fill="#6b7db3" font-size="10">Sort Order</text>

  <rect x="455" y="75" width="110" height="50" rx="7" fill="#1e2130" stroke="#f4a261" stroke-width="1.5"/>
  <text x="510" y="96" text-anchor="middle" fill="#ffd8a8" font-size="11">Paginated</text>
  <text x="510" y="112" text-anchor="middle" fill="#6b7db3" font-size="10">Current Page</text>

  <rect x="600" y="75" width="82" height="50" rx="7" fill="#1e2130" stroke="#c084fc" stroke-width="1.5"/>
  <text x="641" y="96" text-anchor="middle" fill="#d8b4fe" font-size="11">Render</text>
  <text x="641" y="112" text-anchor="middle" fill="#6b7db3" font-size="10">getRowModel()</text>

  <!-- Arrows -->
  <line x1="130" y1="100" x2="163" y2="100" stroke="#aaa" stroke-width="1.5" marker-end="url(#arr)"/>
  <line x1="275" y1="100" x2="308" y2="100" stroke="#aaa" stroke-width="1.5" marker-end="url(#arr)"/>
  <line x1="420" y1="100" x2="453" y2="100" stroke="#aaa" stroke-width="1.5" marker-end="url(#arr)"/>
  <line x1="565" y1="100" x2="598" y2="100" stroke="#aaa" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Labels -->
  <text x="75" y="160" text-anchor="middle" fill="#555" font-size="10">data.length rows</text>
  <text x="510" y="160" text-anchor="middle" fill="#555" font-size="10">pageSize rows</text>

  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#aaa"/>
    </marker>
  </defs>
</svg>

---

### Pagination Without `getPaginationRowModel`

If `getPaginationRowModel` is not registered, `table.getRowModel()` returns all rows — pagination state has no effect on the rendered output. [Inference] The pagination API methods (`nextPage`, `setPageIndex`, etc.) are still callable, but they will not produce visible changes since the row model is not sliced.

This can be intentional in server-side pagination setups, where the slicing is handled externally and the table only manages state.

---

### Persisting Pagination State

Pagination state can be persisted to `localStorage`, a URL query parameter, or any external store by lifting it into controlled state and syncing it on mount:

```ts
const [pagination, setPagination] = useState(() => {
  const saved = localStorage.getItem('tablePagination')
  return saved ? JSON.parse(saved) : { pageIndex: 0, pageSize: 10 }
})

useEffect(() => {
  localStorage.setItem('tablePagination', JSON.stringify(pagination))
}, [pagination])
```

[Inference] URL-based pagination (e.g., `?page=2&pageSize=25`) follows the same pattern but requires parsing query parameters on mount and serializing on change. Behavior depends on the router in use and is outside TanStack Table's scope.

---

### Common Pitfalls

**Using `getCoreRowModel().rows` to render instead of `getRowModel().rows`**
This bypasses pagination entirely and renders all rows regardless of page state.

**Not resetting `pageIndex` after filter changes**
Filters reduce available pages. If `pageIndex` is stale, the current page may be out of range.

**Setting `pageSize` to `0` or negative values**
[Unverified] Behavior is undefined. Always validate `pageSize` before calling `setPageSize`.

**Off-by-one in UI display**
`pageIndex` is zero-based. Display as `pageIndex + 1` to the user and subtract 1 when accepting page-number input.

**Mutating `initialState` after mount**
`initialState` is consumed once. Updates to it after initialization are ignored.

---

**Related Topics**

- Server-Side Pagination — delegating page slicing to an API with manual `pageCount`
- Pagination + Filtering Reset Patterns — coordinating `pageIndex` resets across filter and sort changes
- Pagination + Sorting Interaction — sort order behavior across pages
- URL-Synchronized Pagination — persisting page state in query parameters
- Virtualization vs Pagination — comparing `@tanstack/react-virtual` windowing with discrete pages
- Row Selection Across Pages — managing `rowSelection` state when rows span multiple pages
- Pagination with Grouped Rows — behavior of `pageSize` when row grouping is active