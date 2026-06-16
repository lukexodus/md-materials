## TanStack Table — Expanded Group Rows

### Overview

Expanded group rows control whether the children of a group row — either nested sub-group rows or leaf rows — are visible in the rendered row model. TanStack Table manages expansion as an independent state layer on top of grouping. A group can be grouped without being expanded, and expansion state persists independently from changes to grouping, filtering, or sorting state (unless auto-reset is enabled).

Expansion also applies outside of grouping: any row with a `subRows` property (including manually constructed hierarchical data) participates in the same expansion system.

---

### Expansion vs. Grouping — Conceptual Separation

Grouping State(which columns group)Expanded State(which groups are open)Row Model Output(rows passed to renderer)

Grouping determines *structure*. Expansion determines *visibility*. Both feed into `getRowModel()` independently. Changing one does not automatically change the other, unless `autoResetExpanded` is enabled.

---

### Required Setup

Expansion requires `getExpandedRowModel` to be included alongside `getGroupedRowModel`. Without it, grouped rows are present in the row model but toggling them has no effect on `getRowModel()` output. [Inference] Omitting `getExpandedRowModel` while calling `row.getToggleExpandedHandler()` will not throw but will silently fail to update the visible rows — behavior may vary by version.

ts

```ts
import {
  useReactTable,
  getCoreRowModel,
  getGroupedRowModel,
  getExpandedRowModel,
} from '@tanstack/react-table'

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getGroupedRowModel: getGroupedRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
  state: {
    grouping,
    expanded,
  },
  onGroupingChange: setGrouping,
  onExpandedChange: setExpanded,
})
```

---

### Expanded State Shape

ts

```ts
import { ExpandedState } from '@tanstack/react-table'
```

`ExpandedState` is a union type:

ts

```ts
type ExpandedState = true | Record<string, boolean>
```

| Value | Meaning |
| --- | --- |
| `true` | All rows are expanded at all levels |
| `{}` | No rows are expanded |
| `{ 'department:Engineering': true }` | Only the Engineering group is expanded |
| `{ 'department:Engineering': true, 'department:Design': false }` | Engineering expanded, Design explicitly collapsed |

Row IDs used as keys in the record follow the format produced by TanStack Table's internal ID generation for group rows (e.g., `department:Engineering`). Leaf row IDs are typically their index or a configured `getRowId` result.

---

### Initializing Expanded State

**All collapsed (default):**

ts

```ts
const [expanded, setExpanded] = useState<ExpandedState>({})
```

**All expanded on mount:**

ts

```ts
const [expanded, setExpanded] = useState<ExpandedState>(true)
```

**Specific groups expanded on mount:**

ts

```ts
const [expanded, setExpanded] = useState<ExpandedState>({
  'department:Engineering': true,
})
```

[Inference] The string key format must match the row ID that TanStack Table generates at runtime. If `getRowId` is customized or grouping column values contain special characters, verify that the key format matches actual row IDs before relying on pre-initialized expansion state — behavior may vary.

---

### Table-Level Expansion Methods

These methods operate on the entire table and affect all rows simultaneously.

#### `table.toggleAllRowsExpanded(expanded?)`

Toggles or sets the expansion state of every row.

ts

```ts
// Expand all
table.toggleAllRowsExpanded(true)

// Collapse all
table.toggleAllRowsExpanded(false)

// Toggle current state
table.toggleAllRowsExpanded()
```

#### `table.getIsAllRowsExpanded()`

Returns `true` if every expandable row is currently expanded.

ts

```ts
const allExpanded = table.getIsAllRowsExpanded()
```

#### `table.getIsSomeRowsExpanded()`

Returns `true` if at least one row is expanded but not all.

ts

```ts
const someExpanded = table.getIsSomeRowsExpanded()
```

**Example — expand/collapse all toggle button:**

tsx

```tsx
<button onClick={() => table.toggleAllRowsExpanded()}>
  {table.getIsAllRowsExpanded() ? 'Collapse All' : 'Expand All'}
</button>
```

#### `table.getToggleAllRowsExpandedHandler()`

Returns a synthetic event handler suitable for use directly on an `<input>` or `<button>`:

tsx

```tsx
<input
  type="checkbox"
  checked={table.getIsAllRowsExpanded()}
  onChange={table.getToggleAllRowsExpandedHandler()}
/>
```

---

### Row-Level Expansion Methods

These methods operate on individual rows and are called during rendering.

| Method | Returns | Description |
| --- | --- | --- |
| `row.getIsExpanded()` | `boolean` | Whether this row is currently expanded |
| `row.getCanExpand()` | `boolean` | Whether this row has sub-rows and can be expanded |
| `row.toggleExpanded(expanded?)` | `void` | Toggle or set expansion for this row |
| `row.getToggleExpandedHandler()` | `() => void` | Returns a click handler for toggling this row |

#### `row.getCanExpand()`

Returns `true` when the row has at least one entry in `row.subRows`. For group rows this is almost always `true`. For leaf rows this is `false` unless the data has a nested `subRows` field (tree data).

ts

```ts
if (row.getCanExpand()) {
  // Safe to render an expand toggle
}
```

#### `row.toggleExpanded(value?)`

ts

```ts
row.toggleExpanded()        // toggle current state
row.toggleExpanded(true)    // force open
row.toggleExpanded(false)   // force closed
```

#### `row.getToggleExpandedHandler()`

Returns a `() => void` function intended for `onClick`. This is the standard way to wire expansion to a button or row click:

tsx

```tsx
<button onClick={row.getToggleExpandedHandler()}>
  {row.getIsExpanded() ? '▼' : '▶'}
</button>
```

---

### Rendering Expanded and Collapsed Group Rows

The complete rendering pattern for a table with grouping and expansion:

tsx

```tsx
<tbody>
  {table.getRowModel().rows.map(row => (
    <tr
      key={row.id}
      style={{ backgroundColor: row.getIsGrouped() ? '#f0f4f8' : 'transparent' }}
    >
      {row.getVisibleCells().map(cell => (
        <td
          key={cell.id}
          style={{ paddingLeft: cell.getIsGrouped() ? `${row.depth * 1.5}rem` : undefined }}
        >
          {cell.getIsGrouped() ? (
            <span>
              {row.getCanExpand() ? (
                <button onClick={row.getToggleExpandedHandler()}>
                  {row.getIsExpanded() ? '▼' : '▶'}
                </button>
              ) : null}
              {' '}
              {flexRender(cell.column.columnDef.cell, cell.getContext())}
              {' '}
              <span>({row.subRows.length})</span>
            </span>
          ) : cell.getIsAggregated() ? (
            flexRender(
              cell.column.columnDef.aggregatedCell ?? cell.column.columnDef.cell,
              cell.getContext()
            )
          ) : cell.getIsPlaceholder() ? null : (
            flexRender(cell.column.columnDef.cell, cell.getContext())
          )}
        </td>
      ))}
    </tr>
  ))}
</tbody>
```

---

### Depth and Indentation

`row.depth` is a zero-indexed integer indicating nesting level. Top-level group rows have `depth: 0`. Sub-group rows have `depth: 1`. Leaf rows under a single-level group also have `depth: 1`.

row.depth = 0Group: Engineeringrow.depth = 1Group: Engineer (role)row.depth = 1Group: Manager (role)row.depth = 2Leaf: Alicerow.depth = 2Leaf: Everow.depth = 2Leaf: Bob

Use `row.depth` to compute indentation dynamically:

tsx

```tsx
style={{ paddingLeft: `${row.depth * 1.5}rem` }}
```

---

### Expanding All Groups on Data Change

When data is first loaded (e.g., after an async fetch), you may want all groups expanded automatically:

ts

```ts
useEffect(() => {
  if (data.length > 0) {
    table.toggleAllRowsExpanded(true)
  }
}, [data])
```

[Inference] Calling `table.toggleAllRowsExpanded` inside a `useEffect` after render may cause a double-render cycle in React — behavior depends on your state management approach and may vary. Initializing `expanded` as `true` in `useState` is generally preferable for avoiding extra renders.

---

### Auto-Reset Behavior

By default, TanStack Table resets expanded state when certain upstream state changes (data, grouping, filtering). This can cause all groups to collapse unexpectedly.

ts

```ts
const table = useReactTable({
  autoResetExpanded: false,
  // ...
})
```

Set `autoResetExpanded: false` when:

- You are streaming or paginating data and do not want open groups to collapse on each update
- You are managing expanded state externally and want full control
- Users have manually opened specific groups and you want that to persist across data refreshes

[Inference] With `autoResetExpanded: false`, stale expansion state may reference row IDs that no longer exist after a data change — expanded state for missing rows is silently ignored, but behavior may vary.

---

### Expansion Outside of Grouping — Tree Data

The expansion system is not exclusive to grouped rows. If your raw data has a nested `subRows` field, TanStack Table treats those as expandable rows without any grouping configuration:

ts

```ts
type Category = {
  name: string
  subRows?: Category[]
}

const data: Category[] = [
  {
    name: 'Electronics',
    subRows: [
      { name: 'Phones' },
      { name: 'Laptops' },
    ],
  },
  {
    name: 'Clothing',
    subRows: [
      { name: 'Tops' },
      { name: 'Bottoms' },
    ],
  },
]
```

With `getExpandedRowModel` included and no `getGroupedRowModel`, TanStack Table renders the hierarchy using the same expansion state system. `row.getCanExpand()` returns `true` for rows with non-empty `subRows`.

---

### Controlling Which Rows Can Expand

The `getRowCanExpand` table option overrides `row.getCanExpand()` on a per-row basis:

ts

```ts
const table = useReactTable({
  getRowCanExpand: row => row.subRows.length > 1,
  // ...
})
```

[Inference] This affects only the `getCanExpand()` return value and the expansion UI — it does not prevent `row.toggleExpanded()` from being called programmatically. Behavior of programmatic expansion on a row where `getRowCanExpand` returns `false` may vary.

**Use cases:**

- Prevent expansion of groups with a single child (no meaningful collapse)
- Restrict expansion to rows above a certain depth
- Disable expansion based on row data properties

---

### Expansion State and `getRowModel()`

`getRowModel()` returns only rows that are currently visible given the expansion state. Collapsed group rows appear in the output; their `subRows` do not.

ts

```ts
// With Engineering collapsed:
table.getRowModel().rows
// → [GroupRow: Engineering, GroupRow: Design]

// With Engineering expanded (single-level):
table.getRowModel().rows
// → [GroupRow: Engineering, LeafRow: Alice, LeafRow: Bob, LeafRow: Eve, GroupRow: Design]
```

This is the row set that pagination, virtualization, and rendering all operate on. [Inference] If pagination is active, collapsed groups reduce the effective row count per page, which may cause pages to appear sparsely populated — account for this in pagination UI design.

---

### Persisting Expansion State

To persist expanded state across page reloads, serialize to `localStorage` or a URL parameter:

ts

```ts
// Save
useEffect(() => {
  if (typeof expanded === 'object') {
    localStorage.setItem('tableExpanded', JSON.stringify(expanded))
  }
}, [expanded])

// Restore
const [expanded, setExpanded] = useState<ExpandedState>(() => {
  try {
    const saved = localStorage.getItem('tableExpanded')
    return saved ? JSON.parse(saved) : {}
  } catch {
    return {}
  }
})
```

[Inference] Serializing `true` (all-expanded state) to `localStorage` and restoring it will expand all groups even after data changes that add new groups — this may or may not be the intended behavior depending on your use case.

---

### Full Working Example

tsx

```tsx
import React, { useState } from 'react'
import {
  useReactTable,
  getCoreRowModel,
  getGroupedRowModel,
  getExpandedRowModel,
  flexRender,
  ColumnDef,
  GroupingState,
  ExpandedState,
} from '@tanstack/react-table'

type Employee = {
  name: string
  department: string
  role: string
  salary: number
}

const data: Employee[] = [
  { name: 'Alice', department: 'Engineering', role: 'Engineer', salary: 90000 },
  { name: 'Bob',   department: 'Engineering', role: 'Manager',  salary: 120000 },
  { name: 'Carol', department: 'Design',      role: 'Designer', salary: 85000 },
  { name: 'Dave',  department: 'Design',      role: 'Manager',  salary: 110000 },
  { name: 'Eve',   department: 'Engineering', role: 'Engineer', salary: 95000 },
]

const columns: ColumnDef<Employee>[] = [
  { accessorKey: 'department', header: 'Department' },
  { accessorKey: 'role',       header: 'Role' },
  { accessorKey: 'name',       header: 'Name', enableGrouping: false },
  {
    accessorKey: 'salary',
    header: 'Avg Salary',
    aggregationFn: 'mean',
    aggregatedCell: ({ getValue }) =>
      `$${Math.round(getValue<number>()).toLocaleString()}`,
  },
]

export default function ExpandedGroupTable() {
  const [grouping, setGrouping] = useState<GroupingState>(['department', 'role'])
  const [expanded, setExpanded] = useState<ExpandedState>({})

  const table = useReactTable({
    data,
    columns,
    state: { grouping, expanded },
    onGroupingChange: setGrouping,
    onExpandedChange: setExpanded,
    getCoreRowModel: getCoreRowModel(),
    getGroupedRowModel: getGroupedRowModel(),
    getExpandedRowModel: getExpandedRowModel(),
    autoResetExpanded: false,
  })

  return (
    <div>
      <div style={{ marginBottom: '0.5rem' }}>
        <button onClick={() => table.toggleAllRowsExpanded(true)}>
          Expand All
        </button>
        {' '}
        <button onClick={() => table.toggleAllRowsExpanded(false)}>
          Collapse All
        </button>
      </div>

      <table>
        <thead>
          {table.getHeaderGroups().map(hg => (
            <tr key={hg.id}>
              {hg.headers.map(h => (
                <th key={h.id}>
                  {flexRender(h.column.columnDef.header, h.getContext())}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map(row => (
            <tr key={row.id}>
              {row.getVisibleCells().map(cell => (
                <td
                  key={cell.id}
                  style={{ paddingLeft: `${row.depth * 1.5}rem` }}
                >
                  {cell.getIsGrouped() ? (
                    <button onClick={row.getToggleExpandedHandler()}>
                      {row.getIsExpanded() ? '▼' : '▶'}{' '}
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                      {' '}({row.subRows.length})
                    </button>
                  ) : cell.getIsAggregated() ? (
                    flexRender(
                      cell.column.columnDef.aggregatedCell ?? cell.column.columnDef.cell,
                      cell.getContext()
                    )
                  ) : cell.getIsPlaceholder() ? null : (
                    flexRender(cell.column.columnDef.cell, cell.getContext())
                  )}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
```

---

**Related Topics**

- Tree data (hierarchical `subRows` without grouping)
- `getRowCanExpand` for conditional expansion control
- Expansion state persistence in URL parameters
- Pagination interaction with collapsed group rows
- Virtualized expansion with TanStack Virtual
- Multi-level grouping depth and indentation strategies
- `autoResetExpanded` in streaming and paginated data contexts
- Expansion combined with row selection state
- Animating expand/collapse transitions in React