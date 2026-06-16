## TanStack Table — Row Grouping

### Overview

Row grouping in TanStack Table allows rows to be clustered by the values of one or more columns, collapsing flat tabular data into a hierarchical tree structure. Grouped rows can be expanded or collapsed interactively, and aggregate values can be displayed at each group level. This feature integrates with TanStack Table's sorting, filtering, and pagination pipelines.

### Core Concepts

**How grouping works in the pipeline**

TanStack Table processes rows through an ordered pipeline. Grouping occurs after filtering and before sorting (by default), producing a tree of `Row` objects where parent rows represent groups and leaf rows represent original data. The relevant pipeline stages are:

```
Raw Data → Filtering → Grouping → Sorting → Pagination → Rendering
```

Each grouped parent row has a `subRows` array containing either nested group rows or leaf rows, depending on whether multiple columns are used for grouping.

**Group rows vs. leaf rows**

A *group row* is a synthetic row created by TanStack Table to represent a unique value within a grouped column. It does not correspond to a raw data item. A *leaf row* is an original data row nested under a group. Both are instances of the `Row` type, but group rows have `row.getIsGrouped()` returning `true`.

---

### Setup and Installation

Row grouping is part of the `@tanstack/react-table` package (and framework equivalents). No additional package is needed.

bash

```bash
npm install @tanstack/react-table
```

The grouping feature requires the `getGroupedRowModel` row model to be included in the table configuration.

---

### Enabling Grouping

#### Importing the Required Row Model

ts

```ts
import {
  useReactTable,
  getCoreRowModel,
  getGroupedRowModel,
  getExpandedRowModel,
  ColumnDef,
} from '@tanstack/react-table'
```

`getExpandedRowModel` is required alongside `getGroupedRowModel` when you want grouped rows to be expandable and collapsible.

#### Basic Table Configuration

ts

```ts
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getGroupedRowModel: getGroupedRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
  state: {
    grouping,
  },
  onGroupingChange: setGrouping,
})
```

`grouping` is an array of column IDs that determines which columns are currently grouped.

---

### Grouping State

The grouping state is an array of column ID strings:

ts

```ts
import { GroupingState } from '@tanstack/react-table'

const [grouping, setGrouping] = useState<GroupingState>([])
```

**Example — grouping by a single column:**

ts

```ts
const [grouping, setGrouping] = useState<GroupingState>(['department'])
```

**Example — grouping by multiple columns (nested grouping):**

ts

```ts
const [grouping, setGrouping] = useState<GroupingState>(['department', 'role'])
```

The order of column IDs in the array controls nesting depth: `department` becomes the top-level group, and `role` becomes the next level within each department group.

---

### Column Definition Options

Each column can declare grouping-related options in its `ColumnDef`.

ts

```ts
const columns: ColumnDef<Employee>[] = [
  {
    accessorKey: 'department',
    header: 'Department',
    enableGrouping: true,   // Allow this column to be grouped
  },
  {
    accessorKey: 'name',
    header: 'Name',
    enableGrouping: false,  // Prevent grouping on this column
  },
  {
    accessorKey: 'salary',
    header: 'Salary',
    aggregationFn: 'mean',  // Used when aggregation is also configured
  },
]
```

`enableGrouping` defaults to `true` for all columns unless overridden globally via `defaultColumn` or per-column.

---

### Rendering Grouped Rows

When rows are grouped, the row model returns a mixed set of group rows and leaf rows. Rendering requires branching logic to handle both.

tsx

```tsx
<tbody>
  {table.getRowModel().rows.map(row => (
    <tr key={row.id}>
      {row.getVisibleCells().map(cell => (
        <td key={cell.id}>
          {cell.getIsGrouped() ? (
            // This cell is the grouping cell for this row
            <button onClick={row.getToggleExpandedHandler()}>
              {row.getIsExpanded() ? '▼' : '▶'}{' '}
              {flexRender(cell.column.columnDef.cell, cell.getContext())}{' '}
              ({row.subRows.length})
            </button>
          ) : cell.getIsAggregated() ? (
            // This cell is showing an aggregated value
            flexRender(
              cell.column.columnDef.aggregatedCell ?? cell.column.columnDef.cell,
              cell.getContext()
            )
          ) : cell.getIsPlaceholder() ? null : (
            // Regular leaf cell
            flexRender(cell.column.columnDef.cell, cell.getContext())
          )}
        </td>
      ))}
    </tr>
  ))}
</tbody>
```

#### Cell State Methods

| Method | Returns | Description |
| --- | --- | --- |
| `cell.getIsGrouped()` | `boolean` | True if this cell is the primary grouping cell of a group row |
| `cell.getIsAggregated()` | `boolean` | True if the cell displays an aggregated value |
| `cell.getIsPlaceholder()` | `boolean` | True if the cell is a non-grouped, non-aggregated filler on a group row |

---

### Row State Methods

| Method | Returns | Description |
| --- | --- | --- |
| `row.getIsGrouped()` | `boolean` | True if this is a synthetic group row |
| `row.getIsExpanded()` | `boolean` | True if the group is currently expanded |
| `row.getToggleExpandedHandler()` | `() => void` | Returns a click handler to toggle expand state |
| `row.subRows` | `Row[]` | Nested rows under this group row |
| `row.groupingColumnId` | `string` | The column ID that created this group row |
| `row.groupingValue` | `unknown` | The value shared by all rows in this group |
| `row.depth` | `number` | Nesting depth (0 = top-level group) |

---

### Controlling Expansion

By default, grouped rows are collapsed. Expansion state is managed separately from grouping state.

ts

```ts
import { ExpandedState } from '@tanstack/react-table'

const [expanded, setExpanded] = useState<ExpandedState>({})

const table = useReactTable({
  // ...
  state: {
    grouping,
    expanded,
  },
  onGroupingChange: setGrouping,
  onExpandedChange: setExpanded,
})
```

**Expand all groups programmatically:**

ts

```ts
table.toggleAllRowsExpanded(true)
```

**Expand a specific group row:**

ts

```ts
row.toggleExpanded(true)
```

`ExpandedState` can be `true` (all expanded) or a record of `{ [rowId: string]: boolean }`.

---

### Manual Grouping

For server-side grouping, disable client-side grouping and supply pre-grouped data:

ts

```ts
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getGroupedRowModel: getGroupedRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
  manualGrouping: true,
  state: { grouping },
  onGroupingChange: setGrouping,
})
```

When `manualGrouping: true`, TanStack Table does not reorganize rows into groups itself. The `data` you supply must already be structured as a hierarchy, with nested `subRows` properties on each group item. [Inference] You are responsible for constructing the `subRows` tree from your server response before passing it to the table; TanStack Table behavior in this mode depends on the shape of your data being consistent with its expected format — behavior may vary.

---

### Grouping with Column Visibility

Grouped columns are not automatically hidden. If you want the grouping column to be visually hidden while still driving the group structure, set it in `columnVisibility`:

ts

```ts
const [columnVisibility, setColumnVisibility] = useState({
  department: false,
})
```

This hides the column cells from rendering while preserving the grouping behavior.

---

### Controlling Which Columns Can Be Grouped

**Globally disable grouping for all columns unless explicitly enabled:**

ts

```ts
const table = useReactTable({
  defaultColumn: {
    enableGrouping: false,
  },
  // ...
})
```

Then enable grouping only on specific columns:

ts

```ts
{
  accessorKey: 'department',
  enableGrouping: true,
}
```

---

### Auto-Resetting Grouping State

By default, TanStack Table resets grouping-related derived state (like expansion) when data changes. To suppress this:

ts

```ts
const table = useReactTable({
  autoResetExpanded: false,
  // ...
})
```

This is useful when you are paginating or streaming data and do not want expanded groups to collapse on each update.

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
  { accessorKey: 'salary',     header: 'Salary' },
]

export default function GroupingTable() {
  const [grouping, setGrouping]   = useState<GroupingState>(['department'])
  const [expanded, setExpanded]   = useState<ExpandedState>({})

  const table = useReactTable({
    data,
    columns,
    state: { grouping, expanded },
    onGroupingChange: setGrouping,
    onExpandedChange: setExpanded,
    getCoreRowModel: getCoreRowModel(),
    getGroupedRowModel: getGroupedRowModel(),
    getExpandedRowModel: getExpandedRowModel(),
  })

  return (
    <table>
      <thead>
        {table.getHeaderGroups().map(hg => (
          <tr key={hg.id}>
            {hg.headers.map(header => (
              <th key={header.id}>
                {flexRender(header.column.columnDef.header, header.getContext())}
                {header.column.getCanGroup() && (
                  <button onClick={header.column.getToggleGroupingHandler()}>
                    {header.column.getIsGrouped() ? '🔒' : '📌'}
                  </button>
                )}
              </th>
            ))}
          </tr>
        ))}
      </thead>
      <tbody>
        {table.getRowModel().rows.map(row => (
          <tr key={row.id} style={{ paddingLeft: `${row.depth * 16}px` }}>
            {row.getVisibleCells().map(cell => (
              <td key={cell.id}>
                {cell.getIsGrouped() ? (
                  <button onClick={row.getToggleExpandedHandler()}>
                    {row.getIsExpanded() ? '▼' : '▶'}{' '}
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}{' '}
                    ({row.subRows.length})
                  </button>
                ) : cell.getIsPlaceholder() ? null : (
                  flexRender(cell.column.columnDef.cell, cell.getContext())
                )}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  )
}
```

---

### Column Header Grouping Toggle

Each column exposes `getCanGroup()` and `getToggleGroupingHandler()` for building UI controls that let users group by any column interactively:

ts

```ts
header.column.getCanGroup()             // boolean — is this column groupable?
header.column.getIsGrouped()            // boolean — is this column currently grouped?
header.column.getToggleGroupingHandler() // () => void — toggle grouping on/off
header.column.getGroupedIndex()         // number — position in the grouping array
```

---

### Diagram — Row Model Tree Structure

When grouping by `department`, the row model tree looks like this:

Row Model (root)Group Row: Engineering(depth 0)Group Row: Design (depth0)Leaf: AliceLeaf: BobLeaf: EveLeaf: CarolLeaf: Dave

With two grouping columns (`department`, `role`), each `Engineering` group row would itself contain nested group rows for `Engineer` and `Manager` before reaching leaf rows.

---

### Interaction with Sorting

By default, sorting is applied *after* grouping, which means rows are sorted within each group. You can change this behavior with `groupedColumnMode`:

ts

```ts
const table = useReactTable({
  groupedColumnMode: 'remove', // 'reorder' | 'remove' | false
  // ...
})
```

| Value | Behavior |
| --- | --- |
| `'reorder'` | Grouped columns are moved to the left of the column order |
| `'remove'` | Grouped columns are removed from the visible column list |
| `false` | Grouped columns remain in their original position |

---

### Known Behaviors and Caveats

- [Inference] When using `getGroupedRowModel` without `getExpandedRowModel`, groups may not be expandable at all even if `expanded` state is managed — behavior may vary by version.
- Pagination operates on the top-level row model. If groups are collapsed, hidden leaf rows do not count toward page size. [Inference] This means page sizes may appear inconsistent depending on expansion state — behavior may vary.
- The `row.id` for a group row is derived from the grouping column ID and value (e.g., `department:Engineering`), not from a data record. Do not use group row IDs as stable data keys.
- `manualGrouping` does not disable the grouping state; it only skips client-side row reorganization.

---

**Related Topics**

- Aggregation functions (`aggregationFn`, `aggregatedCell`)
- Custom grouping functions (`groupingFn`)
- Expanded row model and expansion state
- Sorting within groups (`sortingFn` interaction with `getGroupedRowModel`)
- Column visibility with grouped columns
- Server-side (manual) grouping with paginated APIs
- Multi-level nested grouping rendering patterns
- Grouping combined with filtering (`getFilteredRowModel` ordering)
- Virtualized grouped rows with TanStack Virtual