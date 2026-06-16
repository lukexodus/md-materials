## TanStack Table — Pagination — Page Size Controls

### Overview

Page size controls allow users to change how many rows are displayed per page. In TanStack Table, page size is part of the pagination state object and is changed via `table.setPageSize(n)`. Both client-side and server-side pagination respond to page size changes through the same API — the difference lies in what happens downstream when the value changes.

---

### Page Size in Pagination State

Page size is stored as `pageSize` inside the `pagination` state object alongside `pageIndex`:

```ts
{
  pageIndex: 0,
  pageSize: 10,
}
```

Changing `pageSize` via `setPageSize` updates this value. In controlled mode, this triggers `onPaginationChange`, which updates external state. In uncontrolled mode, the table manages the value internally.

---

### Setting an Initial Page Size

#### Via `initialState`

For uncontrolled tables, set the initial page size through `initialState`. This value is read once on mount.

```ts
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
  initialState: {
    pagination: {
      pageIndex: 0,
      pageSize: 25,
    },
  },
})
```

#### Via Controlled State

For controlled tables, the initial value is whatever is passed to `useState`:

```ts
const [pagination, setPagination] = useState({
  pageIndex: 0,
  pageSize: 25,
})
```

---

### `table.setPageSize(n)`

The primary method for changing page size. Accepts a positive integer.

```ts
table.setPageSize(50)
```

Internally, TanStack Table updates `pageSize` in pagination state. [Inference] It does not automatically reset `pageIndex` to `0` when page size changes. Whether to reset `pageIndex` on a page size change is the application's responsibility.

#### Resetting `pageIndex` on Page Size Change

When page size increases or decreases, the current `pageIndex` may point to a page that no longer exists or that represents a different data range. The common pattern is to reset to page 0:

```ts
table.setPageSize(Number(value))
table.setPageIndex(0)
```

Or, in controlled mode, update both in one state write:

```ts
onPaginationChange: updater => {
  const next = typeof updater === 'function' ? updater(pagination) : updater
  setPagination({ ...next, pageIndex: 0 })
}
```

[Inference] Calling `setPageSize` and `setPageIndex` separately in the same render cycle may or may not batch into a single state update depending on the React version and whether the calls occur inside a synthetic event handler. Using the functional updater form or a single `onPaginationChange` override is more reliable.

---

### Basic Page Size Selector

A `<select>` element is the most common UI pattern for page size control.

```tsx
function PageSizeSelector({ table }) {
  const { pageSize } = table.getState().pagination

  return (
    <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
      Rows per page:
      <select
        value={pageSize}
        onChange={e => {
          table.setPageSize(Number(e.target.value))
          table.setPageIndex(0)
        }}
      >
        {[10, 25, 50, 100].map(size => (
          <option key={size} value={size}>
            {size}
          </option>
        ))}
      </select>
    </label>
  )
}
```

---

### "Show All" Option

Some interfaces provide an option to disable pagination entirely and show all rows. This is achieved by setting `pageSize` to the total row count.

```tsx
function PageSizeSelectorWithAll({ table }) {
  const { pageSize } = table.getState().pagination
  const totalRows = table.getFilteredRowModel().rows.length

  const options = [10, 25, 50, 100, totalRows]

  return (
    <select
      value={pageSize}
      onChange={e => {
        table.setPageSize(Number(e.target.value))
        table.setPageIndex(0)
      }}
    >
      {[10, 25, 50, 100].map(size => (
        <option key={size} value={size}>{size}</option>
      ))}
      <option value={totalRows}>All ({totalRows})</option>
    </select>
  )
}
```

[Inference] For large datasets, setting `pageSize` to the total row count renders all rows in the DOM simultaneously. This may cause performance degradation for datasets beyond a few thousand rows. Consider virtualization (`@tanstack/react-virtual`) instead of a "show all" option in those cases.

For server-side pagination, a "show all" option requires a separate API call or a very large `pageSize` value. [Speculation] Most APIs impose an upper limit on page size; verify your API's constraints before implementing this pattern.

---

### Free-Input Page Size

For interfaces where users may want arbitrary page sizes, a number input can replace or complement the select:

```tsx
function FreePageSizeInput({ table }) {
  const { pageSize } = table.getState().pagination
  const [inputValue, setInputValue] = useState(String(pageSize))

  const commit = () => {
    const parsed = parseInt(inputValue, 10)
    if (!isNaN(parsed) && parsed > 0) {
      table.setPageSize(parsed)
      table.setPageIndex(0)
    } else {
      setInputValue(String(pageSize)) // revert on invalid input
    }
  }

  return (
    <input
      type="number"
      min={1}
      value={inputValue}
      onChange={e => setInputValue(e.target.value)}
      onBlur={commit}
      onKeyDown={e => { if (e.key === 'Enter') commit() }}
      style={{ width: '5rem' }}
    />
  )
}
```

**Key Points:**
- The local `inputValue` state allows the user to type freely without triggering a page size update on every keystroke.
- Committing on `blur` and `Enter` limits recomputation to intentional submissions.
- Invalid input (non-numeric, zero, negative) reverts to the current page size rather than crashing.

---

### Page Size and `getPageCount()`

`getPageCount()` is recalculated whenever `pageSize` or the total row count changes:

```
pageCount = Math.ceil(totalFilteredRows / pageSize)
```

Increasing `pageSize` reduces `pageCount`. Decreasing it increases `pageCount`. Because `pageIndex` is not automatically reset, a user on page 4 with `pageSize = 10` who switches to `pageSize = 50` may now be on a page index that exceeds the new `pageCount`. This is why resetting `pageIndex` on page size change is important.

---

### Displaying Contextual Row Count Information

A common companion to a page size selector is a row range indicator that updates reactively:

```tsx
function PaginationSummary({ table }) {
  const { pageIndex, pageSize } = table.getState().pagination
  const totalRows = table.getFilteredRowModel().rows.length
  const start = totalRows === 0 ? 0 : pageIndex * pageSize + 1
  const end = Math.min((pageIndex + 1) * pageSize, totalRows)

  return (
    <span>
      {totalRows === 0
        ? 'No results'
        : `Showing ${start}–${end} of ${totalRows} rows`}
    </span>
  )
}
```

For server-side pagination, replace `table.getFilteredRowModel().rows.length` with the `rowCount` value from the API response, as the table only holds the current page's rows.

---

### Page Size with Server-Side Pagination

In server-side mode, changing `pageSize` must trigger a new API fetch in addition to updating local state. The pattern is identical to server-side `pageIndex` changes — include `pageSize` in the query key.

```ts
const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 20 })

const { data } = useQuery({
  queryKey: ['items', pagination.pageIndex, pagination.pageSize],
  queryFn: () =>
    fetch(`/api/items?page=${pagination.pageIndex}&limit=${pagination.pageSize}`)
      .then(r => r.json()),
  placeholderData: keepPreviousData,
})

const table = useReactTable({
  data: data?.items ?? [],
  columns,
  getCoreRowModel: getCoreRowModel(),
  manualPagination: true,
  rowCount: data?.total,
  state: { pagination },
  onPaginationChange: updater => {
    const next = typeof updater === 'function' ? updater(pagination) : updater
    setPagination({ ...next, pageIndex: 0 })
  },
})
```

**Key Points:**
- Both `pageIndex` and `pageSize` are in the query key — a change to either triggers a fetch.
- `onPaginationChange` resets `pageIndex` to `0` on every change, including page size changes.
- `placeholderData: keepPreviousData` prevents the table from flashing empty while the new page size loads.

---

### Persisting Page Size Preference

Users often expect their page size preference to persist across sessions. The value can be stored in `localStorage` and restored on mount:

```ts
const STORAGE_KEY = 'table_page_size'
const DEFAULT_PAGE_SIZE = 25

const [pagination, setPagination] = useState(() => {
  const saved = localStorage.getItem(STORAGE_KEY)
  const pageSize = saved ? parseInt(saved, 10) : DEFAULT_PAGE_SIZE
  return {
    pageIndex: 0,
    pageSize: isNaN(pageSize) || pageSize < 1 ? DEFAULT_PAGE_SIZE : pageSize,
  }
})

useEffect(() => {
  localStorage.setItem(STORAGE_KEY, String(pagination.pageSize))
}, [pagination.pageSize])
```

[Inference] Persisting `pageIndex` alongside `pageSize` is generally not recommended, as the data at a persisted page index may be stale or irrelevant on the next visit.

---

### Common Pitfalls

**Not resetting `pageIndex` after page size change**
The current page index may exceed the new page count, resulting in an empty or out-of-range page being displayed.

**Calling `setPageSize` with `0`, `NaN`, or negative values**
[Unverified] Behavior with invalid page sizes is not guaranteed. Always validate user input before passing it to `setPageSize`.

**Using `table.getCoreRowModel().rows.length` for total row count in summary text**
This returns all rows before filtering. Use `table.getFilteredRowModel().rows.length` for the post-filter count, which is what the user sees paginated.

**Offering a "show all" option for server-side tables without API support**
Setting a very large `pageSize` in server-side mode issues an API request with that limit. If the API caps page size, the response will not match the requested amount.

**`pageSize` options not including the current persisted value**
If a user has a persisted page size of `75` but the options list is `[10, 25, 50, 100]`, the select will display incorrectly. Either include all possible values or normalize on mount.

---

**Related Topics**

- Client-Side Pagination — full pagination setup including `getPaginationRowModel`
- Manual Server-Side Pagination — `manualPagination`, `rowCount`, and API-driven page fetching
- URL-Synchronized Pagination — persisting `pageIndex` and `pageSize` in query string parameters
- Pagination Controls — rendering first/prev/next/last navigation alongside page size
- Row Virtualization — alternative to large page sizes for rendering many rows efficiently
- Pagination with Filtering — resetting `pageIndex` when filter state changes
- Pagination State Persistence — saving and restoring table state across sessions