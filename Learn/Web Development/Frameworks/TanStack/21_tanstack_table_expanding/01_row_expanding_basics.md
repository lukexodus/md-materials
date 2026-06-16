## TanStack Table — Row Expanding Basics

### Overview

Row expanding in TanStack Table is a general-purpose mechanism for showing and hiding sub-rows beneath a parent row. While grouping generates sub-rows synthetically from flat data, row expanding works with any row that has children — including manually nested tree data, detail panels simulated via sub-rows, and grouped rows. The expansion system is the same in all cases: a shared `ExpandedState`, a shared set of row and table methods, and a single `getExpandedRowModel` that filters the visible row set.

This article covers row expanding in its own right, independent of grouping — including tree data, the `expanded` state lifecycle, all relevant APIs, and rendering patterns.

---

### Core Concepts

**What "expanding" means in TanStack Table**

Expanding controls whether a row's `subRows` are included in the output of `getRowModel()`. A collapsed parent row appears in the output; its children do not. An expanded parent row appears, followed immediately by its children, which may themselves be expandable.

**Sources of sub-rows**

Sub-rows can originate from two sources:

| Source | How sub-rows are created |
| --- | --- |
| Grouping | `getGroupedRowModel` synthesizes group rows with `subRows` from flat data |
| Tree data | Raw `data` items contain a `subRows` field with nested records of the same type |

Both use identical expansion APIs. [Inference] A table can combine both simultaneously — grouped rows that also contain tree-structured leaf data — but rendering and depth calculations become complex; behavior may vary depending on row model pipeline ordering.

---

### Required Configuration

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
  state: {
    expanded,
  },
  onExpandedChange: setExpanded,
})
```

`getExpandedRowModel` is the only additional row model needed for pure tree-data expansion without grouping. No `getGroupedRowModel` is required unless flat data is being grouped.

---

### Tree Data

The most direct use case for row expanding without grouping is hierarchical tree data, where each data item optionally contains a `subRows` array of the same type.

#### Defining a Recursive Data Type

ts

```ts
type Category = {
  id: number
  name: string
  itemCount: number
  subRows?: Category[]
}
```

The `subRows` field name is the default key TanStack Table looks for. It can be changed via `getSubRows`.

#### Example Data

ts

```ts
const data: Category[] = [
  {
    id: 1,
    name: 'Electronics',
    itemCount: 320,
    subRows: [
      {
        id: 2,
        name: 'Phones',
        itemCount: 140,
        subRows: [
          { id: 4, name: 'Android', itemCount: 90 },
          { id: 5, name: 'iOS',     itemCount: 50 },
        ],
      },
      { id: 3, name: 'Laptops', itemCount: 180 },
    ],
  },
  {
    id: 6,
    name: 'Clothing',
    itemCount: 210,
    subRows: [
      { id: 7, name: 'Tops',    itemCount: 110 },
      { id: 8, name: 'Bottoms', itemCount: 100 },
    ],
  },
]
```

#### Column Definitions for Tree Data

ts

```ts
const columns: ColumnDef<Category>[] = [
  {
    accessorKey: 'name',
    header: 'Category',
  },
  {
    accessorKey: 'itemCount',
    header: 'Items',
  },
]
```

No special column configuration is required for expansion. The expand toggle is rendered manually in the cell renderer, not driven by a dedicated column type.

---

### Customizing the Sub-rows Field — `getSubRows`

If your data uses a field name other than `subRows`, provide a `getSubRows` accessor:

ts

```ts
const table = useReactTable({
  getSubRows: row => row.children,   // use 'children' instead of 'subRows'
  // ...
})
```

`getSubRows` can also apply conditional logic:

ts

```ts
getSubRows: row => row.isLeaf ? undefined : row.children,
```

[Inference] Returning `undefined` from `getSubRows` signals that the row has no children and cannot expand — `row.getCanExpand()` will return `false` for that row. Behavior may vary if an empty array `[]` is returned instead of `undefined`.

---

### Expanded State

ts

```ts
import { ExpandedState } from '@tanstack/react-table'

const [expanded, setExpanded] = useState<ExpandedState>({})
```

`ExpandedState` is `true | Record<string, boolean>`.

| Initial value | Effect |
| --- | --- |
| `{}` | All rows collapsed |
| `true` | All rows expanded |
| `{ '0': true }` | Only row with ID `'0'` expanded |
| `{ '0': true, '0.0': true }` | Row `'0'` and its first child expanded |

Row IDs for tree data follow a dot-delimited path format by default: `'0'` for the first top-level row, `'0.0'` for its first child, `'0.1'` for its second child, and so on. [Inference] This ID format assumes the default `getRowId` implementation; if `getRowId` is customized, expansion state keys must match the custom IDs — behavior of mismatched keys is silent and results in rows not expanding.

---

### `getRowId` and Stable IDs

By default, TanStack Table assigns row IDs based on array index. For tree data, this produces paths like `'0'`, `'0.0'`, `'0.0.1'`. These IDs are positional and can become stale when data changes.

For stable expansion state that survives data reordering or async updates, supply a `getRowId` function:

ts

```ts
const table = useReactTable({
  getRowId: row => String(row.id),   // use the row's own stable identifier
  // ...
})
```

With stable IDs, expansion state keys match your data's own identity rather than array positions, making persistence and rehydration reliable.

---

### Row API — Expansion Methods

| Method | Returns | Description |
| --- | --- | --- |
| `row.getCanExpand()` | `boolean` | True if the row has sub-rows (or `getRowCanExpand` returns true) |
| `row.getIsExpanded()` | `boolean` | True if this row is currently expanded |
| `row.toggleExpanded(value?)` | `void` | Toggle or explicitly set expansion |
| `row.getToggleExpandedHandler()` | `() => void` | Click handler for toggling expansion |
| `row.subRows` | `Row[]` | The row's child rows (empty array if none) |
| `row.depth` | `number` | Zero-based nesting depth |
| `row.parentId` | `string | undefined` | ID of the parent row, if nested |

#### `row.getCanExpand()`

Returns `true` when:

- `row.subRows.length > 0`, **or**
- The table option `getRowCanExpand` returns `true` for this row

ts

```ts
// Only render a toggle if the row can expand
{row.getCanExpand() && (
  <button onClick={row.getToggleExpandedHandler()}>
    {row.getIsExpanded() ? '▼' : '▶'}
  </button>
)}
```

#### `row.parentId`

Available on nested rows. Useful for traversing upward through the tree:

ts

```ts
const parentRow = table.getRow(row.parentId!)
```

---

### Table API — Expansion Methods

| Method | Returns | Description |
| --- | --- | --- |
| `table.toggleAllRowsExpanded(value?)` | `void` | Expand or collapse every expandable row |
| `table.getIsAllRowsExpanded()` | `boolean` | True if all expandable rows are expanded |
| `table.getIsSomeRowsExpanded()` | `boolean` | True if at least one row is expanded |
| `table.getToggleAllRowsExpandedHandler()` | event handler | Suitable for a checkbox `onChange` |

---

### Table Options — Expansion Configuration

#### `getRowCanExpand`

A row-level predicate that overrides whether a row is considered expandable:

ts

```ts
const table = useReactTable({
  getRowCanExpand: row => row.original.subRows !== undefined,
  // ...
})
```

[Inference] This controls `row.getCanExpand()` return value but does not prevent programmatic calls to `row.toggleExpanded()` — behavior of expanding a row where `getRowCanExpand` returns `false` via direct state manipulation may vary.

#### `autoResetExpanded`

Controls whether expanded state resets when data or other upstream state changes:

ts

```ts
const table = useReactTable({
  autoResetExpanded: false,   // preserve expansion across data updates
  // ...
})
```

Defaults to `true`. Set to `false` when streaming data, applying filters, or updating rows in place.

#### `paginateExpandedRows`

Controls whether expanded child rows count toward the page size in paginated tables:

ts

```ts
const table = useReactTable({
  paginateExpandedRows: false,
  // ...
})
```

| Value | Behavior |
| --- | --- |
| `true` (default) | Expanded child rows consume page slots; fewer parent rows appear per page when groups are open |
| `false` | Each page always contains the configured number of *top-level* rows; child rows are appended and do not consume page slots |

[Inference] Setting `paginateExpandedRows: false` with many deeply nested open rows can result in very long pages; account for this in virtualization or UX design — behavior depends on expansion depth and data volume.

---

### Diagram — `getRowModel()` Output by Expansion State

expanded: trueElectronics (expanded)Phones (expanded)LaptopsAndroidiOSClothing (expanded)TopsBottomsexpanded: { '0': true }Electronics (expanded)PhonesLaptopsClothing (collapsed)expanded: {}Electronics (collapsed)Clothing (collapsed)

---

### Rendering Pattern — Tree Data Table

tsx

```tsx
<tbody>
  {table.getRowModel().rows.map(row => (
    <tr key={row.id}>
      {row.getVisibleCells().map(cell => (
        <td
          key={cell.id}
          style={{
            paddingLeft: cell.column.id === 'name'
              ? `${row.depth * 1.5}rem`
              : undefined,
          }}
        >
          {cell.column.id === 'name' ? (
            <span>
              {row.getCanExpand() ? (
                <button
                  onClick={row.getToggleExpandedHandler()}
                  style={{ marginRight: '0.5rem' }}
                >
                  {row.getIsExpanded() ? '▼' : '▶'}
                </button>
              ) : (
                <span style={{ display: 'inline-block', width: '1.5rem' }} />
              )}
              {flexRender(cell.column.columnDef.cell, cell.getContext())}
            </span>
          ) : (
            flexRender(cell.column.columnDef.cell, cell.getContext())
          )}
        </td>
      ))}
    </tr>
  ))}
</tbody>
```

The expand toggle is rendered only in the `name` column. A spacer element of equal width is rendered for leaf rows to preserve alignment. Indentation is applied only to the first column to avoid visual noise on numeric columns.

---

### Expanding a Row Programmatically

ts

```ts
// By row object
row.toggleExpanded(true)

// By row ID — useful outside of the render loop
const targetRow = table.getRow('0.0')
targetRow?.toggleExpanded(true)
```

`table.getRow(id)` accepts a row ID string and returns the `Row` object if found. [Inference] `table.getRow` searches the full row tree including collapsed rows; it does not require the row to be visible in `getRowModel()` — behavior may vary by version.

---

### Full Working Example — Tree Data

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
} from '@tanstack/react-table'

type Category = {
  id: number
  name: string
  itemCount: number
  subRows?: Category[]
}

const data: Category[] = [
  {
    id: 1,
    name: 'Electronics',
    itemCount: 320,
    subRows: [
      {
        id: 2,
        name: 'Phones',
        itemCount: 140,
        subRows: [
          { id: 4, name: 'Android', itemCount: 90 },
          { id: 5, name: 'iOS',     itemCount: 50 },
        ],
      },
      { id: 3, name: 'Laptops', itemCount: 180 },
    ],
  },
  {
    id: 6,
    name: 'Clothing',
    itemCount: 210,
    subRows: [
      { id: 7, name: 'Tops',    itemCount: 110 },
      { id: 8, name: 'Bottoms', itemCount: 100 },
    ],
  },
]

const columns: ColumnDef<Category>[] = [
  {
    accessorKey: 'name',
    header: 'Category',
    cell: ({ row, getValue }) => (
      <span style={{ paddingLeft: `${row.depth * 1.5}rem` }}>
        {row.getCanExpand() ? (
          <button onClick={row.getToggleExpandedHandler()}>
            {row.getIsExpanded() ? '▼' : '▶'}
          </button>
        ) : (
          <span style={{ display: 'inline-block', width: '1.25rem' }} />
        )}
        {' '}{getValue<string>()}
      </span>
    ),
  },
  {
    accessorKey: 'itemCount',
    header: 'Items',
  },
]

export default function TreeTable() {
  const [expanded, setExpanded] = useState<ExpandedState>({})

  const table = useReactTable({
    data,
    columns,
    state: { expanded },
    onExpandedChange: setExpanded,
    getCoreRowModel: getCoreRowModel(),
    getExpandedRowModel: getExpandedRowModel(),
    getSubRows: row => row.subRows,
    getRowId: row => String(row.id),
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
                <td key={cell.id}>
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
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

### Common Pitfalls

**Forgetting `getExpandedRowModel`**

Including `expanded` in state without `getExpandedRowModel` means expansion state updates but `getRowModel()` output never changes. [Inference] No error is thrown; the table simply renders as if all rows are collapsed regardless of state — behavior may vary by version.

**Using positional row IDs with mutable data**

If rows are reordered, added, or removed, positional IDs like `'0.1'` may refer to different rows after the update. Always supply `getRowId` when expansion state must survive data mutations.

**Returning `[]` from `getSubRows` instead of `undefined`**

[Inference] Returning an empty array may cause `row.getCanExpand()` to return `false` since `subRows.length === 0`, which is the expected behavior — but if `getRowCanExpand` is also defined and returns `true`, a toggle may render with no children to show. Verify your combination of `getSubRows` and `getRowCanExpand` return values.

---

**Related Topics**

- Expansion with grouping — group rows as expandable parents
- `paginateExpandedRows` and page size interactions
- Virtualized tree tables with TanStack Virtual
- `getRowId` and stable ID strategies for persistence
- Persisting expansion state in URL query parameters
- Lazy-loading children on expand (async tree data)
- Row selection combined with expansion state
- Filtering within expanded tree data
- Animating row expand/collapse with CSS transitions