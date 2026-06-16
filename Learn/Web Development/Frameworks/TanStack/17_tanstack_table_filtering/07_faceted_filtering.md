## TanStack Table — Filtering — Faceted Filtering

### Overview

Faceted filtering is a pattern where the available filter options for a column are dynamically derived from the actual data in the table — specifically from the rows that survive all *other* active filters. This allows the UI to show only relevant, non-empty filter choices at any given time, preventing users from selecting filter combinations that would yield zero results.

TanStack Table provides built-in APIs to support faceted value collection, exposed through the column and table APIs.

---

### Core Concept: What "Faceted" Means in This Context

In traditional filtering, a dropdown might statically list all possible values regardless of what is currently visible. In faceted filtering:

- The filter options for Column A reflect the values present *after* Column B's filter is applied.
- As filters are added or removed, the available options for each filter update reactively.
- This mirrors the UX pattern used in e-commerce sites (e.g., filtering by brand narrows available sizes).

[Inference] TanStack Table does not automatically render a faceted UI — it only provides the data primitives. Rendering the filter controls is the developer's responsibility.

---

### Enabling Faceted Value Collection

Two column-level features must be enabled to use faceted filtering APIs:

#### `getFacetedRowModel`

Returns a row model scoped to a specific column, containing only the rows that pass all filters *except* the one on that column. This is the foundation for computing faceted values.

```ts
import {
  getCoreRowModel,
  getFilteredRowModel,
  getFacetedRowModel,
  getFacetedUniqueValues,
  getFacetedMinMaxValues,
  useReactTable,
} from '@tanstack/react-table'

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
  getFacetedRowModel: getFacetedRowModel(),
  getFacetedUniqueValues: getFacetedUniqueValues(),
  getFacetedMinMaxValues: getFacetedMinMaxValues(),
})
```

All four row model functions above are typically used together for full faceted filtering support.

---

### Faceted Value APIs

Once the row models are registered, three column-level methods become available.

#### `column.getFacetedRowModel()`

Returns the faceted row model for that column — the set of rows passing all *other* active filters.

```ts
const facetedRows = column.getFacetedRowModel()
// facetedRows.rows is an array of Row objects
```

This is rarely used directly in the UI but is the underlying data source for the two derived APIs below.

---

#### `column.getFacetedUniqueValues()`

Returns a `Map<unknown, number>` where each key is a unique cell value for that column (from the faceted row model), and each value is the count of rows containing that value.

```ts
const uniqueValues = column.getFacetedUniqueValues()
// Map { 'Active' => 12, 'Inactive' => 4, 'Pending' => 7 }
```

**Example — rendering a datalist or select for a string column:**

```tsx
function TextColumnFilter({ column }) {
  const uniqueValues = column.getFacetedUniqueValues()
  const sortedValues = Array.from(uniqueValues.keys()).sort()

  return (
    <>
      <datalist id={`${column.id}-list`}>
        {sortedValues.map(value => (
          <option key={value} value={value} />
        ))}
      </datalist>
      <input
        list={`${column.id}-list`}
        value={(column.getFilterValue() ?? '') as string}
        onChange={e => column.setFilterValue(e.target.value)}
        placeholder="Filter..."
      />
    </>
  )
}
```

**Output:** The `datalist` options update dynamically as other filters are applied, showing only values present in the currently visible (faceted) data.

---

#### `column.getFacetedMinMaxValues()`

Returns a tuple `[min, number | string, max: number | string] | undefined` — specifically `[min, max]` — derived from the faceted row model. Used for range-based filter controls such as sliders or dual-input number ranges.

```ts
const [min, max] = column.getFacetedMinMaxValues() ?? [0, 100]
```

**Example — rendering a range input for a numeric column:**

```tsx
function RangeColumnFilter({ column }) {
  const [min, max] = column.getFacetedMinMaxValues() ?? [0, 0]
  const [filterMin, filterMax] = (column.getFilterValue() as [number, number]) ?? ['', '']

  return (
    <div style={{ display: 'flex', gap: '0.5rem' }}>
      <input
        type="number"
        min={min}
        max={max}
        value={filterMin}
        onChange={e =>
          column.setFilterValue((old: [number, number]) => [
            e.target.value,
            old?.[1],
          ])
        }
        placeholder={`Min (${min})`}
      />
      <input
        type="number"
        min={min}
        max={max}
        value={filterMax}
        onChange={e =>
          column.setFilterValue((old: [number, number]) => [
            old?.[0],
            e.target.value,
          ])
        }
        placeholder={`Max (${max})`}
      />
    </div>
  )
}
```

**Output:** The `min` and `max` placeholders reflect the actual range of values in the faceted (currently filtered) data, not the global dataset range.

---

### Data Flow Diagram

<svg viewBox="0 0 680 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Background -->
  <rect width="680" height="340" fill="#0f1117" rx="12"/>

  <!-- Raw Data Box -->
  <rect x="30" y="40" width="140" height="50" rx="8" fill="#1e2130" stroke="#4a90d9" stroke-width="1.5"/>
  <text x="100" y="60" text-anchor="middle" fill="#a0c4ff" font-size="12">All Rows</text>
  <text x="100" y="78" text-anchor="middle" fill="#6b7db3" font-size="11">(Core Row Model)</text>

  <!-- Arrow: All Rows → Filtered Row Model -->
  <line x1="170" y1="65" x2="230" y2="65" stroke="#4a90d9" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- Filtered Row Model -->
  <rect x="230" y="40" width="160" height="50" rx="8" fill="#1e2130" stroke="#7ec8a0" stroke-width="1.5"/>
  <text x="310" y="60" text-anchor="middle" fill="#a8e6c0" font-size="12">Filtered Row Model</text>
  <text x="310" y="78" text-anchor="middle" fill="#6b7db3" font-size="11">(all filters applied)</text>

  <!-- Arrow down to Faceted Row Model -->
  <line x1="310" y1="90" x2="310" y2="150" stroke="#7ec8a0" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- Faceted Row Model -->
  <rect x="190" y="150" width="240" height="50" rx="8" fill="#1e2130" stroke="#f4a261" stroke-width="1.5"/>
  <text x="310" y="170" text-anchor="middle" fill="#ffd8a8" font-size="12">Faceted Row Model</text>
  <text x="310" y="188" text-anchor="middle" fill="#6b7db3" font-size="11">(all filters except this column)</text>

  <!-- Arrow left to UniqueValues -->
  <line x1="190" y1="175" x2="130" y2="230" stroke="#f4a261" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- Arrow right to MinMax -->
  <line x1="430" y1="175" x2="490" y2="230" stroke="#f4a261" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- getFacetedUniqueValues -->
  <rect x="30" y="230" width="210" height="50" rx="8" fill="#1e2130" stroke="#c084fc" stroke-width="1.5"/>
  <text x="135" y="250" text-anchor="middle" fill="#d8b4fe" font-size="12">getFacetedUniqueValues()</text>
  <text x="135" y="268" text-anchor="middle" fill="#6b7db3" font-size="11">Map&lt;value, count&gt;</text>

  <!-- getFacetedMinMaxValues -->
  <rect x="440" y="230" width="210" height="50" rx="8" fill="#1e2130" stroke="#c084fc" stroke-width="1.5"/>
  <text x="545" y="250" text-anchor="middle" fill="#d8b4fe" font-size="12">getFacetedMinMaxValues()</text>
  <text x="545" y="268" text-anchor="middle" fill="#6b7db3" font-size="11">[min, max]</text>

  <!-- Labels at bottom -->
  <text x="135" y="310" text-anchor="middle" fill="#888" font-size="11">→ Checkbox / Select UI</text>
  <text x="545" y="310" text-anchor="middle" fill="#888" font-size="11">→ Range Slider / Number UI</text>

  <!-- Arrow marker -->
  <defs>
    <marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#aaa"/>
    </marker>
  </defs>
</svg>

---

### Filter Function Compatibility

Faceted filtering works with any filter function assigned to a column. The faceted row model respects whichever `filterFn` is active on each column. Built-in options include:

| Filter Function | Suitable For |
|---|---|
| `includesString` | Case-insensitive text match |
| `equalsString` | Exact string match |
| `inNumberRange` | Numeric min/max range |
| `arrIncludes` | Array column contains value |
| `arrIncludesAll` | Array column contains all values |
| `arrIncludesSome` | Array column contains any value |

For the `getFacetedMinMaxValues` API to return meaningful results, the column's values should be numeric or sortable. [Inference] String-typed columns may return unexpected min/max values since comparison falls back to lexicographic ordering.

---

### Multi-Value Column Cells

When a column contains array values (e.g., tags, categories), `getFacetedUniqueValues` may not automatically flatten the arrays into individual entries. [Inference] Custom handling is likely required — either by providing a custom `filterFn` that operates on array membership, or by pre-processing the data to use a supported array filter function like `arrIncludes`.

**Example — using `arrIncludes` for a tags column:**

```ts
const columns = [
  columnHelper.accessor('tags', {
    filterFn: 'arrIncludes',
  }),
]
```

Behavior of `getFacetedUniqueValues` with array cells may vary depending on version and configuration. [Unverified] Consult the official TanStack Table docs for the specific behavior in your installed version.

---

### Performance Considerations

- Faceted row models are recomputed on every filter state change. [Inference] For large datasets, this may introduce noticeable recalculation overhead if many columns have faceted models active simultaneously.
- `getFacetedUniqueValues` returns a memoized `Map`. [Inference] React components consuming this value should read it during render — avoid storing it in local state, as that may prevent reactivity.
- If only a subset of columns needs faceted behavior, there is no requirement to call `getFacetedRowModel` globally — it can be used selectively per column. [Unverified — verify against current API surface.]

---

### Integration with Column Filter State

Faceted values are reactive with respect to `columnFilters` state. No manual synchronization is needed: as `columnFilters` updates (via `column.setFilterValue`), TanStack Table recomputes the faceted row models and the derived unique values and min/max tuples automatically.

[Inference] This reactivity depends on the table instance being properly integrated with your framework's state system (e.g., React `useState` for `columnFilters`). Behavior is not guaranteed if state is managed outside the table instance without notifying it.

---

### Common Pitfalls

**Not including `getFilteredRowModel`**
Faceted row models depend on `getFilteredRowModel` being registered. Without it, faceted APIs will not function correctly.

**Forgetting `getFacetedRowModel` as a prerequisite**
`getFacetedUniqueValues` and `getFacetedMinMaxValues` both depend on `getFacetedRowModel`. All three must be registered together.

**Treating `getFacetedUniqueValues()` as a plain object**
The return type is a `Map`, not a plain JavaScript object. Iterating it requires `Array.from()`, `.keys()`, `.entries()`, or `for...of`.

**Stale UI values**
If the filter control reads faceted values only on mount (e.g., in a `useEffect` with an empty dependency array), it will not update when filters change. Values must be read during render from the live column API.

---

### Minimal Working Example (React)

```tsx
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  getFacetedRowModel,
  getFacetedUniqueValues,
  getFacetedMinMaxValues,
  ColumnDef,
} from '@tanstack/react-table'
import { useState } from 'react'

type Person = { name: string; age: number; status: string }

const columns: ColumnDef<Person>[] = [
  { accessorKey: 'name', header: 'Name' },
  { accessorKey: 'age', header: 'Age' },
  { accessorKey: 'status', header: 'Status' },
]

export function FacetedTable({ data }: { data: Person[] }) {
  const [columnFilters, setColumnFilters] = useState([])

  const table = useReactTable({
    data,
    columns,
    state: { columnFilters },
    onColumnFiltersChange: setColumnFilters,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getFacetedRowModel: getFacetedRowModel(),
    getFacetedUniqueValues: getFacetedUniqueValues(),
    getFacetedMinMaxValues: getFacetedMinMaxValues(),
  })

  const statusColumn = table.getColumn('status')
  const statusOptions = Array.from(
    statusColumn?.getFacetedUniqueValues().keys() ?? []
  ).sort()

  const ageColumn = table.getColumn('age')
  const [ageMin, ageMax] = ageColumn?.getFacetedMinMaxValues() ?? [0, 100]

  return (
    <div>
      {/* Status facet */}
      <select
        value={(statusColumn?.getFilterValue() ?? '') as string}
        onChange={e => statusColumn?.setFilterValue(e.target.value || undefined)}
      >
        <option value="">All Statuses</option>
        {statusOptions.map(val => (
          <option key={val} value={val}>{val}</option>
        ))}
      </select>

      {/* Age range facet */}
      <input
        type="number"
        placeholder={`Min age (${ageMin})`}
        onChange={e =>
          ageColumn?.setFilterValue((old: [number, number]) => [
            e.target.value ? Number(e.target.value) : undefined,
            old?.[1],
          ])
        }
      />
      <input
        type="number"
        placeholder={`Max age (${ageMax})`}
        onChange={e =>
          ageColumn?.setFilterValue((old: [number, number]) => [
            old?.[0],
            e.target.value ? Number(e.target.value) : undefined,
          ])
        }
      />

      {/* Table render omitted for brevity */}
    </div>
  )
}
```

---

**Related Topics**

- Global Filtering — searching across all columns simultaneously
- Custom Filter Functions — defining `filterFn` logic beyond built-ins
- Column Visibility and Filtering Interaction — how hidden columns affect filter state
- Sorting with Active Filters — sort order behavior on filtered row models
- Virtualized Rows with Filtering — combining `@tanstack/react-virtual` with filtered output
- Server-Side Filtering — disabling client filters and delegating to an API
- Filter Debouncing — preventing excessive recomputation on rapid input