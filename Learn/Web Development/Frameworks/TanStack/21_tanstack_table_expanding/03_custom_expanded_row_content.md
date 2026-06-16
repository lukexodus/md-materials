## TanStack Table — Custom Expanded Row Content

### Overview

Custom expanded row content refers to rendering arbitrary UI beneath a parent row when it is expanded — rather than rendering child rows in additional table rows following the standard column structure. Common use cases include detail panels, inline forms, charts, activity logs, related record lists, and rich media that does not fit into a column-based layout.

TanStack Table does not have a dedicated "row detail" feature. Instead, custom expanded content is achieved by inserting additional `<tr>` elements into the rendered output based on `row.getIsExpanded()`, using the same expansion state system that drives sub-row visibility. The table itself remains unaware of the extra markup — the insertion is purely a rendering concern.

---

### Core Approach

The pattern has two parts:

1. Use the standard expansion state and API (`ExpandedState`, `getExpandedRowModel`, `row.toggleExpanded`) to track which rows are open
2. Conditionally render an extra `<tr>` beneath each expanded row, containing a `<td colspan>` that spans all columns

yesyesnorow.getIsExpanded() ===trueStandard dataExtra detail with colspan

The detail row is not part of TanStack Table's row model. It is a manually inserted DOM element that exists purely in the renderer.

---

### Required Setup

Custom expanded content requires `getExpandedRowModel` to be registered and `expanded` state to be managed. `getGroupedRowModel` is not required unless grouping is also active.

ts

```ts
import {
  useReactTable,
  getCoreRowModel,
  getExpandedRowModel,
} from '@tanstack/react-table'

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
  state: { expanded },
  onExpandedChange: setExpanded,
})
```

If you want *every* row to be expandable regardless of whether it has `subRows`, supply `getRowCanExpand`:

ts

```ts
const table = useReactTable({
  getRowCanExpand: () => true,   // all rows can expand
  // ...
})
```

Without this, `row.getCanExpand()` returns `false` for rows with no `subRows`, and the toggle will not render.

---

### Basic Detail Panel Pattern

tsx

```tsx
<tbody>
  {table.getRowModel().rows.map(row => (
    <React.Fragment key={row.id}>

      {/* Standard data row */}
      <tr>
        {row.getVisibleCells().map(cell => (
          <td key={cell.id}>
            {flexRender(cell.column.columnDef.cell, cell.getContext())}
          </td>
        ))}
      </tr>

      {/* Expanded detail row */}
      {row.getIsExpanded() && (
        <tr>
          <td colSpan={row.getVisibleCells().length}>
            <YourDetailComponent row={row} />
          </td>
        </tr>
      )}

    </React.Fragment>
  ))}
</tbody>
```

`React.Fragment` with a `key` is required because a single iteration produces two `<tr>` elements — the data row and the optional detail row — and React requires a single keyed root per array item.

`colSpan={row.getVisibleCells().length}` ensures the detail cell spans the full width of the table regardless of column count or visibility changes.

---

### Rendering a Detail Component

The detail component receives the full `Row` object and can access any field on `row.original`, aggregated values, and sub-row data:

tsx

```tsx
type Employee = {
  id: string
  name: string
  department: string
  salary: number
  bio: string
  skills: string[]
  startDate: string
}

function EmployeeDetail({ row }: { row: Row<Employee> }) {
  const emp = row.original

  return (
    <div style={{ padding: '1rem', background: '#f8f9fa' }}>
      <h4>{emp.name} — Detail</h4>
      <p>{emp.bio}</p>
      <p><strong>Start Date:</strong> {emp.startDate}</p>
      <p><strong>Skills:</strong> {emp.skills.join(', ')}</p>
    </div>
  )
}
```

tsx

```tsx
{row.getIsExpanded() && (
  <tr>
    <td colSpan={row.getVisibleCells().length}>
      <EmployeeDetail row={row} />
    </td>
  </tr>
)}
```

---

### Adding an Expand Toggle Column

Rather than making the entire row clickable, a dedicated column is the most common pattern for triggering expansion:

ts

```ts
const columns: ColumnDef<Employee>[] = [
  {
    id: 'expander',
    header: () => null,
    cell: ({ row }) =>
      row.getCanExpand() ? (
        <button onClick={row.getToggleExpandedHandler()}>
          {row.getIsExpanded() ? '▼' : '▶'}
        </button>
      ) : null,
  },
  { accessorKey: 'name',       header: 'Name' },
  { accessorKey: 'department', header: 'Department' },
  { accessorKey: 'salary',     header: 'Salary' },
]
```

This column has no `accessorKey` — it is a display-only column identified by `id`. Setting `header: () => null` suppresses the header cell content while still occupying the column slot.

---

### Row Click to Expand

An alternative to a dedicated column is expanding on full row click:

tsx

```tsx
<tr
  onClick={row.getToggleExpandedHandler()}
  style={{ cursor: row.getCanExpand() ? 'pointer' : 'default' }}
>
  {row.getVisibleCells().map(cell => (
    <td key={cell.id}>
      {flexRender(cell.column.columnDef.cell, cell.getContext())}
    </td>
  ))}
</tr>
```

[Inference] If the row also contains interactive elements (buttons, links, checkboxes), a row-level `onClick` may conflict with those elements' own click handlers — use `event.stopPropagation()` inside nested interactive elements to prevent unintended expansion toggling. Behavior depends on event bubbling and your browser environment.

---

### Accessing Visible Column Count Dynamically

`row.getVisibleCells().length` is the correct dynamic value for `colSpan` because it responds to column visibility changes. Using a hardcoded number breaks when columns are hidden:

tsx

```tsx
// Correct — updates when columns are hidden/shown
<td colSpan={row.getVisibleCells().length}>

// Fragile — breaks when column visibility changes
<td colSpan={5}>
```

Alternatively, access from the table instance:

tsx

```tsx
<td colSpan={table.getVisibleLeafColumns().length}>
```

Both produce the same value for simple (non-grouped-header) tables. [Inference] For tables with multi-level column groups (nested headers), `getVisibleLeafColumns().length` counts leaf columns, which is the correct span for a full-width cell — behavior may vary for tables with colspan headers.

---

### Anatomy of an Expanded Detail Row

— data row— detail row (conditional)Any JSX content

The detail `<tr>` is a sibling of the data `<tr>`, not a child. HTML tables do not support nested `<tr>` elements — nesting must be achieved through `<table>` elements inside the `<td>`, or by using a non-table layout inside the `<td>`.

---

### Nested Table Inside Expanded Row

For displaying a related dataset inside the expanded panel:

tsx

```tsx
function OrderDetail({ row }: { row: Row<Order> }) {
  const lineItems = row.original.lineItems

  return (
    <div style={{ padding: '0.75rem' }}>
      <table>
        <thead>
          <tr>
            <th>SKU</th>
            <th>Qty</th>
            <th>Unit Price</th>
            <th>Line Total</th>
          </tr>
        </thead>
        <tbody>
          {lineItems.map(item => (
            <tr key={item.sku}>
              <td>{item.sku}</td>
              <td>{item.qty}</td>
              <td>${item.unitPrice.toFixed(2)}</td>
              <td>${(item.qty * item.unitPrice).toFixed(2)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
```

The inner table is a completely independent HTML `<table>` element. It does not share column widths with the outer table. [Inference] Aligning inner and outer column widths precisely requires explicit `width` styles or CSS grid-based layout inside the `<td>` — pure HTML table column negotiation does not span across nested tables.

---

### Async Content in Expanded Rows

For content that requires fetching data on expand:

tsx

```tsx
function AsyncDetail({ row }: { row: Row<Employee> }) {
  const [detail, setDetail] = useState<EmployeeDetail | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false
    setLoading(true)

    fetchEmployeeDetail(row.original.id).then(data => {
      if (!cancelled) {
        setDetail(data)
        setLoading(false)
      }
    })

    return () => { cancelled = true }
  }, [row.original.id])

  if (loading) return <div style={{ padding: '1rem' }}>Loading…</div>
  if (!detail)  return <div style={{ padding: '1rem' }}>Failed to load.</div>

  return (
    <div style={{ padding: '1rem' }}>
      <p>{detail.fullBio}</p>
      <p><strong>Manager:</strong> {detail.managerName}</p>
    </div>
  )
}
```

The `useEffect` runs when the component mounts, which happens when `row.getIsExpanded()` first becomes `true`. The cancellation flag prevents state updates after the component unmounts (when the row collapses). [Inference] If `autoResetExpanded` is `true` and data changes while a panel is loading, the component may unmount mid-fetch — the cancellation flag handles this, but verify that collapsed rows fully unmount in your render setup.

---

### Memoizing Detail Content

If the expanded detail is expensive to render and the parent table re-renders frequently (e.g., due to sorting or filtering), memoize the detail component:

tsx

```tsx
const EmployeeDetail = React.memo(
  ({ row }: { row: Row<Employee> }) => {
    // expensive rendering
    return <div>...</div>
  },
  (prev, next) => prev.row.id === next.row.id && prev.row.original === next.row.original
)
```

[Inference] TanStack Table creates new `Row` objects on each row model recalculation. Passing `row` as a prop and comparing by `row.id` and `row.original` reference may still cause re-renders if `row.original` is a new object reference despite having the same data — consider comparing stable fields like `row.original.id` depending on your data update pattern.

---

### Controlling Which Rows Show a Detail Panel

Not every row in a table needs to be expandable. Use `getRowCanExpand` to limit expansion to specific rows:

ts

```ts
// Only rows with a populated 'notes' field can expand
const table = useReactTable({
  getRowCanExpand: row => Boolean(row.original.notes?.trim()),
  // ...
})
```

ts

```ts
// Only first-level rows expand (not nested rows)
getRowCanExpand: row => row.depth === 0
```

ts

```ts
// Only specific row types expand
getRowCanExpand: row => row.original.type === 'order'
```

---

### Animating Expand and Collapse

CSS-based animation for smooth height transitions:

tsx

```tsx
{row.getIsExpanded() && (
  <tr>
    <td
      colSpan={row.getVisibleCells().length}
      style={{ padding: 0, overflow: 'hidden' }}
    >
      <div
        style={{
          animation: 'expandIn 200ms ease-out',
        }}
      >
        <YourDetailComponent row={row} />
      </div>
    </td>
  </tr>
)}
```

css

```css
@keyframes expandIn {
  from {
    opacity: 0;
    transform: translateY(-4px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

[Inference] Animating collapse (exit animation) is not possible with conditional rendering alone — the element is removed from the DOM immediately when `row.getIsExpanded()` becomes `false`. For exit animations, a library such as Framer Motion or React Transition Group is needed to defer unmounting until the animation completes — behavior of deferred unmounting depends on the animation library's implementation.

---

### Full Working Example

tsx

```tsx
import React, { useState } from 'react'
import {
  useReactTable,
  getCoreRowModel,
  getExpandedRowModel,
  flexRender,
  ColumnDef,
  ExpandedState,
  Row,
} from '@tanstack/react-table'

type Employee = {
  id: string
  name: string
  department: string
  salary: number
  bio: string
  skills: string[]
}

const data: Employee[] = [
  {
    id: 'e1',
    name: 'Alice',
    department: 'Engineering',
    salary: 90000,
    bio: 'Full-stack engineer with 6 years of experience in distributed systems.',
    skills: ['TypeScript', 'Rust', 'PostgreSQL'],
  },
  {
    id: 'e2',
    name: 'Bob',
    department: 'Engineering',
    salary: 120000,
    bio: 'Engineering manager focused on platform reliability and team growth.',
    skills: ['Go', 'Kubernetes', 'Terraform'],
  },
  {
    id: 'e3',
    name: 'Carol',
    department: 'Design',
    salary: 85000,
    bio: 'Product designer specialising in design systems and accessibility.',
    skills: ['Figma', 'CSS', 'User Research'],
  },
]

function EmployeeDetail({ row }: { row: Row<Employee> }) {
  const emp = row.original
  return (
    <div style={{ padding: '1rem 1.5rem', background: '#f0f4f8', borderTop: '1px solid #dce3ea' }}>
      <p style={{ margin: '0 0 0.5rem' }}>{emp.bio}</p>
      <p style={{ margin: 0 }}>
        <strong>Skills:</strong>{' '}
        {emp.skills.map(s => (
          <span
            key={s}
            style={{
              display: 'inline-block',
              marginRight: '0.4rem',
              padding: '0.15rem 0.5rem',
              background: '#d0e4f7',
              borderRadius: '4px',
              fontSize: '0.85rem',
            }}
          >
            {s}
          </span>
        ))}
      </p>
    </div>
  )
}

const columns: ColumnDef<Employee>[] = [
  {
    id: 'expander',
    header: () => null,
    cell: ({ row }) => (
      <button onClick={row.getToggleExpandedHandler()}>
        {row.getIsExpanded() ? '▼' : '▶'}
      </button>
    ),
  },
  { accessorKey: 'name',       header: 'Name' },
  { accessorKey: 'department', header: 'Department' },
  {
    accessorKey: 'salary',
    header: 'Salary',
    cell: ({ getValue }) => `$${getValue<number>().toLocaleString()}`,
  },
]

export default function DetailPanelTable() {
  const [expanded, setExpanded] = useState<ExpandedState>({})

  const table = useReactTable({
    data,
    columns,
    state: { expanded },
    onExpandedChange: setExpanded,
    getCoreRowModel: getCoreRowModel(),
    getExpandedRowModel: getExpandedRowModel(),
    getRowCanExpand: () => true,
  })

  return (
    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
      <thead>
        {table.getHeaderGroups().map(hg => (
          <tr key={hg.id}>
            {hg.headers.map(h => (
              <th key={h.id} style={{ textAlign: 'left', padding: '0.5rem', borderBottom: '2px solid #ccc' }}>
                {flexRender(h.column.columnDef.header, h.getContext())}
              </th>
            ))}
          </tr>
        ))}
      </thead>
      <tbody>
        {table.getRowModel().rows.map(row => (
          <React.Fragment key={row.id}>
            <tr style={{ borderBottom: '1px solid #eee' }}>
              {row.getVisibleCells().map(cell => (
                <td key={cell.id} style={{ padding: '0.5rem' }}>
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </td>
              ))}
            </tr>
            {row.getIsExpanded() && (
              <tr>
                <td colSpan={row.getVisibleCells().length} style={{ padding: 0 }}>
                  <EmployeeDetail row={row} />
                </td>
              </tr>
            )}
          </React.Fragment>
        ))}
      </tbody>
    </table>
  )
}
```

---

### Common Pitfalls

**Missing `React.Fragment` with `key`**

Returning two `<tr>` elements from a `.map()` without a keyed fragment causes React to warn about missing keys and may produce rendering inconsistencies. Always wrap paired rows in `<React.Fragment key={row.id}>`.

**Hardcoded `colSpan`**

Using a fixed number for `colSpan` breaks when column visibility changes. Always derive it from `row.getVisibleCells().length` or `table.getVisibleLeafColumns().length`.

**`getRowCanExpand` not set for rows without `subRows`**

By default, `row.getCanExpand()` returns `false` for rows with no `subRows`. If your detail panel is not tied to sub-row data, set `getRowCanExpand: () => true` explicitly to make all rows expandable.

**Detail content rendered inside `<td>` without padding reset**

Browsers apply default `<td>` padding that appears inside the detail area. Set `padding: 0` on the detail `<td>` and apply internal padding inside your detail component for full control.

---

**Related Topics**

- Row expanding basics — `ExpandedState`, `getExpandedRowModel`, row API
- Sub-rows and tree data — expansion driven by hierarchical data
- Virtualized expanded rows with TanStack Virtual
- Animating expand/collapse with Framer Motion
- Async data loading in expanded detail panels
- Row selection combined with expansion state
- Nested TanStack Table instances inside expanded rows
- `getRowCanExpand` for conditional panel availability
- Integrating expanded panels with column pinning and horizontal scroll