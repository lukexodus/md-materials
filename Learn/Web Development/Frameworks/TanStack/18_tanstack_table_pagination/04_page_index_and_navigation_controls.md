## TanStack Table — Pagination — Page Index and Navigation Controls

### Overview

Page index is the zero-based pointer to the current page within the paginated dataset. Navigation controls are the UI elements — buttons, inputs, indicators — that read and mutate this value. TanStack Table exposes a dedicated set of methods for reading page position, checking boundary conditions, and moving between pages. These APIs work identically in client-side and server-side pagination modes.

---

### `pageIndex` in Pagination State

`pageIndex` is stored inside the `pagination` state object:

```ts
{
  pageIndex: 0, // first page
  pageSize: 20,
}
```

It is zero-based throughout the entire TanStack Table API. All display conversions (e.g., showing "Page 1" to the user) are the application's responsibility.

---

### Navigation Methods

All navigation methods are available on the `table` instance. They mutate `pageIndex` via the active state mechanism — either internal state or `onPaginationChange` in controlled mode.

| Method | Description |
|---|---|
| `table.firstPage()` | Sets `pageIndex` to `0` |
| `table.previousPage()` | Decrements `pageIndex` by 1 |
| `table.nextPage()` | Increments `pageIndex` by 1 |
| `table.lastPage()` | Sets `pageIndex` to `pageCount - 1` |
| `table.setPageIndex(n)` | Sets `pageIndex` to an explicit zero-based value |

#### Boundary Guards

| Method | Returns | Description |
|---|---|---|
| `table.getCanPreviousPage()` | `boolean` | `true` when `pageIndex > 0` |
| `table.getCanNextPage()` | `boolean` | `true` when `pageIndex < pageCount - 1`, or always `true` when `pageCount === -1` |

[Inference] `previousPage()` and `nextPage()` do not guard themselves — calling `previousPage()` when `pageIndex` is already `0` may set it to `-1`. Always check `getCanPreviousPage()` and `getCanNextPage()` before invoking navigation methods, or disable the controls when the boundary is reached.

---

### Reading Current Page State

```ts
const { pageIndex, pageSize } = table.getState().pagination
const pageCount = table.getPageCount() // -1 if unknown
const canPrev = table.getCanPreviousPage()
const canNext = table.getCanNextPage()
```

`getPageCount()` returns `-1` when neither `rowCount` nor `pageCount` is supplied to the table options. This represents an indeterminate total — common in cursor-based or infinite APIs.

---

### Standard Navigation Control

A complete first / previous / next / last control set with a page indicator:

```tsx
function PageNavigationControls({ table }) {
  const { pageIndex } = table.getState().pagination
  const pageCount = table.getPageCount()

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
      <button
        onClick={() => table.firstPage()}
        disabled={!table.getCanPreviousPage()}
        aria-label="First page"
      >
        {'<<'}
      </button>

      <button
        onClick={() => table.previousPage()}
        disabled={!table.getCanPreviousPage()}
        aria-label="Previous page"
      >
        {'<'}
      </button>

      <span>
        Page{' '}
        <strong>{pageIndex + 1}</strong>
        {pageCount !== -1 && <> of <strong>{pageCount}</strong></>}
      </span>

      <button
        onClick={() => table.nextPage()}
        disabled={!table.getCanNextPage()}
        aria-label="Next page"
      >
        {'>'}
      </button>

      <button
        onClick={() => table.lastPage()}
        disabled={!table.getCanNextPage()}
        aria-label="Last page"
      >
        {'>>'}
      </button>
    </div>
  )
}
```

**Key Points:**
- `pageIndex + 1` converts to one-based display.
- `pageCount !== -1` guards the "of N" text — omitted when total pages are unknown.
- `disabled` attributes on buttons reflect the boundary check results.
- `lastPage()` is disabled using `getCanNextPage()` because if there is no next page, the user is already on the last page.

---

### Jump-to-Page Input

Allows navigating directly to a specific page by number:

```tsx
function JumpToPage({ table }) {
  const { pageIndex } = table.getState().pagination
  const pageCount = table.getPageCount()
  const [value, setValue] = useState(String(pageIndex + 1))

  // Sync input when pageIndex changes externally
  useEffect(() => {
    setValue(String(pageIndex + 1))
  }, [pageIndex])

  const commit = () => {
    const parsed = parseInt(value, 10)
    const max = pageCount === -1 ? Infinity : pageCount
    if (!isNaN(parsed) && parsed >= 1 && parsed <= max) {
      table.setPageIndex(parsed - 1)
    } else {
      setValue(String(pageIndex + 1)) // revert invalid input
    }
  }

  return (
    <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
      Go to page:
      <input
        type="number"
        min={1}
        max={pageCount === -1 ? undefined : pageCount}
        value={value}
        onChange={e => setValue(e.target.value)}
        onBlur={commit}
        onKeyDown={e => { if (e.key === 'Enter') commit() }}
        style={{ width: '4rem' }}
      />
    </label>
  )
}
```

**Key Points:**
- Local `value` state decouples the input from table state, allowing free typing.
- `useEffect` syncs the input if `pageIndex` changes externally (e.g., from a filter reset).
- Committed values are validated before calling `setPageIndex` — invalid input reverts to the current page.
- When `pageCount` is `-1` (unknown total), the `max` attribute is omitted and upper-bound validation is skipped.

---

### Numbered Page Buttons

For datasets with a small, known page count, rendering individual page buttons is a common pattern:

```tsx
function NumberedPageButtons({ table }) {
  const { pageIndex } = table.getState().pagination
  const pageCount = table.getPageCount()

  if (pageCount === -1) return null // cannot render without known total

  return (
    <div style={{ display: 'flex', gap: '0.25rem' }}>
      {Array.from({ length: pageCount }, (_, i) => (
        <button
          key={i}
          onClick={() => table.setPageIndex(i)}
          disabled={i === pageIndex}
          style={{
            fontWeight: i === pageIndex ? 'bold' : 'normal',
            textDecoration: i === pageIndex ? 'underline' : 'none',
          }}
          aria-current={i === pageIndex ? 'page' : undefined}
        >
          {i + 1}
        </button>
      ))}
    </div>
  )
}
```

[Inference] Rendering a button per page is only practical for small page counts (e.g., under 20). For larger counts, a windowed pagination pattern (showing a range around the current page with ellipses) is required. TanStack Table does not provide a windowing utility — this must be implemented in application code.

---

### Windowed Page Number Pattern

A common UI convention shows a fixed window of page numbers around the current page, with ellipses indicating skipped ranges:

```
<< < 1 ... 4 [5] 6 ... 12 > >>
```

```ts
function getPageWindow(pageIndex: number, pageCount: number, delta = 2): (number | 'ellipsis')[] {
  const pages: (number | 'ellipsis')[] = []
  const left = Math.max(0, pageIndex - delta)
  const right = Math.min(pageCount - 1, pageIndex + delta)

  if (left > 0) {
    pages.push(0)
    if (left > 1) pages.push('ellipsis')
  }

  for (let i = left; i <= right; i++) {
    pages.push(i)
  }

  if (right < pageCount - 1) {
    if (right < pageCount - 2) pages.push('ellipsis')
    pages.push(pageCount - 1)
  }

  return pages
}
```

```tsx
function WindowedPageButtons({ table }) {
  const { pageIndex } = table.getState().pagination
  const pageCount = table.getPageCount()

  if (pageCount === -1) return null

  const window = getPageWindow(pageIndex, pageCount)

  return (
    <div style={{ display: 'flex', gap: '0.25rem', alignItems: 'center' }}>
      {window.map((entry, idx) =>
        entry === 'ellipsis' ? (
          <span key={`ellipsis-${idx}`}>…</span>
        ) : (
          <button
            key={entry}
            onClick={() => table.setPageIndex(entry)}
            disabled={entry === pageIndex}
            aria-current={entry === pageIndex ? 'page' : undefined}
          >
            {entry + 1}
          </button>
        )
      )}
    </div>
  )
}
```

---

### Composing a Full Pagination Bar

A typical pagination bar combines navigation controls, page indicator, jump-to-page, and page size selector into a single row:

```tsx
function PaginationBar({ table }) {
  const { pageIndex, pageSize } = table.getState().pagination
  const pageCount = table.getPageCount()
  const totalRows = table.getFilteredRowModel().rows.length // use API total for server-side
  const start = totalRows === 0 ? 0 : pageIndex * pageSize + 1
  const end = Math.min((pageIndex + 1) * pageSize, totalRows)

  return (
    <div style={{ display: 'flex', flexWrap: 'wrap', gap: '1rem', alignItems: 'center' }}>

      {/* Row range summary */}
      <span>
        {totalRows === 0 ? 'No results' : `${start}–${end} of ${totalRows}`}
      </span>

      {/* Navigation buttons */}
      <div style={{ display: 'flex', gap: '0.25rem' }}>
        <button onClick={() => table.firstPage()} disabled={!table.getCanPreviousPage()}>{'<<'}</button>
        <button onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>{'<'}</button>
        <span>Page {pageIndex + 1}{pageCount !== -1 ? ` of ${pageCount}` : ''}</span>
        <button onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>{'>'}</button>
        <button onClick={() => table.lastPage()} disabled={!table.getCanNextPage()}>{'>>'}</button>
      </div>

      {/* Jump to page */}
      <JumpToPage table={table} />

      {/* Page size */}
      <select
        value={pageSize}
        onChange={e => {
          table.setPageSize(Number(e.target.value))
          table.setPageIndex(0)
        }}
      >
        {[10, 25, 50, 100].map(n => (
          <option key={n} value={n}>Show {n}</option>
        ))}
      </select>

    </div>
  )
}
```

---

### Indeterminate Navigation (Unknown Page Count)

When `pageCount` is `-1`, `lastPage()` and `getCanNextPage()` behave differently:

| Condition | `getCanNextPage()` | `lastPage()` behavior |
|---|---|---|
| `pageCount` known, on last page | `false` | No-op |
| `pageCount` known, not on last page | `true` | Jumps to last page |
| `pageCount === -1` | Always `true` | [Unverified] behavior — may set to an undefined index |

[Inference] When `pageCount` is `-1`, the last-page button should be hidden or disabled in application code, since its target is unknown. The next-page button should be disabled based on application-level signals (e.g., API returning fewer rows than `pageSize`, or an explicit `hasNextPage` flag from the API).

```tsx
const hasNextPage = (data?.items.length ?? 0) >= pagination.pageSize

<button
  onClick={() => table.nextPage()}
  disabled={!hasNextPage}
>
  {'>'}
</button>
```

---

### Accessibility Considerations

[Inference] These are common accessibility practices for pagination controls and are not TanStack Table-specific requirements.

- Use `aria-label` on icon-only buttons (`<<`, `<`, `>`, `>>`) to describe their action.
- Use `aria-current="page"` on the active page button in numbered or windowed pagination.
- Use `<nav>` with `aria-label="Pagination"` to wrap the entire pagination bar.
- Disable buttons via the `disabled` attribute rather than hiding them, so users with assistive technology understand the boundary.

```tsx
<nav aria-label="Pagination">
  {/* controls here */}
</nav>
```

---

### Common Pitfalls

**Calling `nextPage()` or `previousPage()` without checking boundary conditions**
These methods do not guard themselves against going out of bounds. Use `getCanNextPage()` and `getCanPreviousPage()` to gate calls and disable controls.

**Displaying `pageIndex` directly to users**
`pageIndex` is zero-based. Always display `pageIndex + 1` in UI text.

**Using `pageIndex` as a React `key` for page buttons**
Page index values are reused across renders. If page buttons are reused with stale keys, React may not re-render them correctly. Use the page number value itself as the key.

**Not syncing the jump-to-page input with external `pageIndex` changes**
If `pageIndex` is reset elsewhere (e.g., filter change resets to page 0), the jump-to-page input will show a stale value unless it watches `pageIndex` via `useEffect`.

**Rendering `lastPage()` button when `pageCount === -1`**
The last page is unknown. Rendering an enabled last-page button in this case navigates to an undefined index.

**Windowed pagination with no first/last anchor**
Skipping the always-visible first and last page buttons in a windowed pattern can leave users unable to navigate to extremes if the ellipsis spans the full range.

---

**Related Topics**

- Page Size Controls — changing `pageSize` and its interaction with `pageIndex`
- Client-Side Pagination — `getPaginationRowModel` and full client-side setup
- Manual Server-Side Pagination — `manualPagination`, `rowCount`, and indeterminate page count
- URL-Synchronized Pagination — persisting `pageIndex` in browser query parameters
- Pagination with Filtering — resetting `pageIndex` when filter state changes
- Pagination with Sorting — resetting `pageIndex` on sort order changes
- Row Selection Across Pages — maintaining selection state when navigating pages