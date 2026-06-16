## TanStack Table — Sub-rows and Tree Data

### Overview

Sub-rows are the mechanism by which TanStack Table represents hierarchical relationships between rows. Any row whose data contains nested children — whether supplied directly in the raw data or synthesized by the grouping pipeline — is treated as a parent row with sub-rows. Tree data is the term for raw datasets that are already structured hierarchically before reaching TanStack Table, as opposed to flat data that grouping reorganizes into a hierarchy at runtime.

This article covers how TanStack Table consumes tree-structured data, how sub-rows are resolved, how the row model handles nesting at arbitrary depth, and the full set of APIs and patterns for working with hierarchical data directly.

---

### Flat Data vs. Tree Data

Tree Data[{name:'Electronics',subRows:[...]}]getCoreRowModel()Native HierarchyFlat Data + Grouping[{dept:'Eng',...},{dept:'Design',...}]getGroupedRowModel()Synthesized Hierarchy

|  | Flat Data + Grouping | Tree Data |
| --- | --- | --- |
| Data shape | Array of uniform records | Array of recursively nested records |
| Hierarchy source | `getGroupedRowModel` synthesizes it | Present in raw data |
| Sub-row type | Synthetic group rows + leaf rows | Same type as parent |
| Requires grouping state | Yes | No |
| Requires `getGroupedRowModel` | Yes | No |
| Depth limit | Determined by grouping column count | Determined by data nesting depth |

Both approaches converge on the same `Row` API, the same expansion system, and the same `getExpandedRowModel` for controlling visibility.

---

### How TanStack Table Resolves Sub-rows

TanStack Table calls `getSubRows` for every row during row model construction. The default implementation looks for a `subRows` property on `row.original`:

ts

```ts
// Default getSubRows behavior (simplified)
getSubRows: (row) => row.subRows
```

If `getSubRows` returns a non-empty array, TanStack Table:

1. Wraps each child item in a `Row` object
2. Assigns it a depth of `parent.depth + 1`
3. Assigns it an ID of `parentId + '.' + childIndex` (unless `getRowId` is customized)
4. Sets `childRow.parentId` to the parent row's ID
5. Adds the child rows to `parentRow.subRows`
6. Recurses into each child row and repeats

This process is applied at core row model construction time, before any filtering, grouping, sorting, or expansion occurs.

---

### Defining Recursive Data Types

#### Single-type recursion

The most common pattern — a node type that optionally contains children of the same type:

ts

```ts
type TreeNode = {
  id: string
  label: string
  value: number
  subRows?: TreeNode[]
}
```

#### Discriminated union tree

For trees where leaf nodes and branch nodes have different shapes:

ts

```ts
type LeafNode = {
  id: string
  kind: 'leaf'
  label: string
  value: number
}

type BranchNode = {
  id: string
  kind: 'branch'
  label: string
  subRows: (BranchNode | LeafNode)[]
}

type TreeNode = BranchNode | LeafNode
```

[Inference] TanStack Table's generics operate on a single `TData` type. Using a discriminated union as `TData` is valid TypeScript but may require type narrowing in `cell` renderers when accessing properties specific to one variant — behavior of `row.original` narrowing depends on your TypeScript version and renderer logic.

#### Mixed flat and nested

Some datasets have mostly flat rows with occasional nesting:

ts

```ts
type Order = {
  id: string
  customer: string
  total: number
  subRows?: OrderLineItem[]   // only present for orders with line items
}

type OrderLineItem = {
  id: string
  sku: string
  qty: number
  price: number
}
```

[Inference] When `TData` is `Order` and child rows are `OrderLineItem`, `row.original` on a child row is technically typed as `Order` but contains an `OrderLineItem` value at runtime. This type mismatch is a known limitation when child and parent types differ — use type assertions carefully and verify column accessors against actual runtime values.

---

### `getSubRows` Option

ts

```ts
const table = useReactTable({
  getSubRows: (originalRow, index) => originalRow.subRows,
  // ...
})
```

| Parameter | Type | Description |
| --- | --- | --- |
| `originalRow` | `TData` | The raw data item for this row |
| `index` | `number` | The index of this row within its parent's children array |

**Return value:** an array of `TData` items, or `undefined`/empty array if the row has no children.

#### Custom field name

ts

```ts
getSubRows: row => row.children
```

#### Conditional sub-rows

ts

```ts
getSubRows: row => row.type === 'folder' ? row.items : undefined
```

#### Filtering sub-rows at the data level

ts

```ts
getSubRows: row => row.subRows?.filter(child => child.visible)
```

[Inference] Filtering in `getSubRows` runs at row model construction time, before TanStack Table's own filter pipeline. Rows excluded here are permanently absent from the row model for that render cycle — they do not appear even if column filters would otherwise include them. Behavior of combining `getSubRows`-level filtering with `getFilteredRowModel` may produce unexpected results; prefer one or the other.

---

### Row ID Generation for Tree Data

By default, IDs are positional path strings:

| Row | Default ID |
| --- | --- |
| First top-level row | `'0'` |
| Second top-level row | `'1'` |
| First child of row `'0'` | `'0.0'` |
| Second child of row `'0'` | `'0.1'` |
| First child of `'0.0'` | `'0.0.0'` |

Positional IDs are fragile when data changes. For stable IDs:

ts

```ts
const table = useReactTable({
  getRowId: (originalRow, index, parent) => {
    return parent ? `${parent.id}.${originalRow.id}` : String(originalRow.id)
  },
  // ...
})
```

| Parameter | Type | Description |
| --- | --- | --- |
| `originalRow` | `TData` | The raw data item |
| `index` | `number` | Index within parent's children |
| `parent` | `Row<TData> | undefined` | The parent row, if nested |

Including `parent.id` in child IDs preserves path information, which makes expansion state keys human-readable and debuggable.

---

### Sub-row Properties on the `Row` Object

| Property / Method | Type | Description |
| --- | --- | --- |
| `row.subRows` | `Row<TData>[]` | Direct children of this row |
| `row.depth` | `number` | Zero-based nesting level |
| `row.parentId` | `string | undefined` | ID of the parent row |
| `row.leafRows` | `Row<TData>[]` | All leaf descendants, flattened |
| `row.getCanExpand()` | `() => boolean` | Whether this row has expandable children |
| `row.getIsExpanded()` | `() => boolean` | Whether this row is currently expanded |
| `row.toggleExpanded(value?)` | `(boolean?) => void` | Expand or collapse this row |

#### `row.leafRows`

Returns all leaf descendants, regardless of nesting depth, as a flat array. Useful for computing aggregates manually on tree data without the grouping pipeline:

ts

```ts
const totalValue = row.leafRows.reduce(
  (sum, leaf) => sum + leaf.getValue<number>('value'),
  0
)
```

[Inference] `row.leafRows` on a leaf row itself returns an array containing only that row — verify this assumption if using `leafRows` in aggregation logic where leaf vs. branch distinction matters.

---

### Diagram — Sub-row Tree with Depth and IDs

id: '1' | depth: 0Electronicsid: '1.2' | depth: 1Phonesid: '1.3' | depth: 1Laptopsid: '1.2.4' | depth: 2Androidid: '1.2.5' | depth: 2iOSid: '6' | depth: 0Clothingid: '6.7' | depth: 1Topsid: '6.8' | depth: 1Bottoms

IDs here use the `getRowId: row => String(row.id)` pattern with parent path prepended — not the default positional format.

---

### Filtering with Tree Data

By default, filtering in TanStack Table operates on leaf rows and does not consider whether a parent row matches the filter. If a leaf matches, its ancestors are preserved to maintain tree structure. If no leaves under a parent match, the parent is removed.

ts

```ts
const table = useReactTable({
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
  // ...
})
```

This default behavior is controlled by `filterFromLeafRows`:

ts

```ts
const table = useReactTable({
  filterFromLeafRows: true,   // default — filter based on leaf row values
  // ...
})
```

#### `filterFromLeafRows: false`

When set to `false`, each row is filtered independently. A parent row that does not match the filter is removed even if its children would match.

ts

```ts
filterFromLeafRows: false
```

#### `maxLeafRowFilterDepth`

Limits how deep into the tree filtering descends when `filterFromLeafRows` is `true`:

ts

```ts
const table = useReactTable({
  filterFromLeafRows: true,
  maxLeafRowFilterDepth: 1,   // only consider immediate children, not deeper
  // ...
})
```

[Inference] Setting `maxLeafRowFilterDepth: 0` with `filterFromLeafRows: true` may behave equivalently to `filterFromLeafRows: false` for top-level rows — behavior may vary by version; verify against your data depth.

---

### Sorting with Tree Data

Sorting in TanStack Table with tree data sorts rows *within each sibling group* at every depth level. It does not flatten and re-sort the entire tree. Top-level rows are sorted among themselves; each parent's children are sorted among themselves independently.

ts

```ts
const table = useReactTable({
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
  // ...
})
```

[Inference] Sorting does not move rows across parent boundaries — a child of `Electronics` will not be sorted into `Clothing`'s children regardless of its value. This is expected behavior for tree data but may be surprising if you expect global sorting — verify against your use case.

---

### Combining Tree Data with Aggregation

Without `getGroupedRowModel`, TanStack Table does not compute aggregations automatically for tree parent rows. To display summary values on parent rows, compute them manually in the `cell` renderer using `row.subRows` or `row.leafRows`:

ts

```ts
const columns: ColumnDef<TreeNode>[] = [
  {
    accessorKey: 'value',
    header: 'Value',
    cell: ({ row, getValue }) => {
      if (row.getCanExpand()) {
        // Manually aggregate leaf values for branch rows
        const total = row.leafRows.reduce(
          (sum, leaf) => sum + leaf.getValue<number>('value'),
          0
        )
        return <strong>{total.toLocaleString()}</strong>
      }
      return getValue<number>().toLocaleString()
    },
  },
]
```

[Inference] This manual approach recomputes on every render. For large trees, memoizing the computation with `useMemo` or moving it to the data preparation step is advisable — performance characteristics depend on tree size and render frequency.

---

### Lazy Loading Children

For large trees where fetching all children upfront is impractical, you can simulate lazy loading by:

1. Representing unloaded children as a placeholder in the data
2. Triggering a fetch on expand
3. Replacing the placeholder with real data after the fetch

ts

```ts
type LazyNode = {
  id: string
  name: string
  hasChildren: boolean
  subRows?: LazyNode[]        // undefined = not yet loaded; [] = loaded but empty
}
```

ts

```ts
const table = useReactTable({
  getRowCanExpand: row => row.original.hasChildren,
  getSubRows: row => row.subRows,
  // ...
})
```

ts

```ts
const handleExpandedChange: OnChangeFn<ExpandedState> = async (updater) => {
  const next = typeof updater === 'function' ? updater(expanded) : updater

  // Determine which rows were just expanded
  const newlyExpanded = Object.keys(next).filter(
    id => next[id] && !expanded[id]
  )

  for (const rowId of newlyExpanded) {
    const row = table.getRow(rowId)
    if (row && row.original.subRows === undefined) {
      const children = await fetchChildren(row.original.id)
      // Update your data state to inject children under this node
      setData(prev => injectChildren(prev, row.original.id, children))
    }
  }

  setExpanded(next)
}
```

[Inference] `injectChildren` must be implemented to traverse your data tree and insert children at the correct position — TanStack Table does not provide a utility for mutating tree data. Behavior of the row model during and after the async fetch depends on your data state update timing and React rendering cycle.

---

### Full Working Example — Multi-level Tree Data

tsx

```tsx
import React, { useState } from 'react'
import {
  useReactTable,
  getCoreRowModel,
  getExpandedRowModel,
  getFilteredRowModel,
  getSortedRowModel,
  flexRender,
  ColumnDef,
  ExpandedState,
  SortingState,
} from '@tanstack/react-table'

type FileNode = {
  id: string
  name: string
  size: number
  type: 'folder' | 'file'
  subRows?: FileNode[]
}

const data: FileNode[] = [
  {
    id: 'src', name: 'src', size: 0, type: 'folder',
    subRows: [
      {
        id: 'components', name: 'components', size: 0, type: 'folder',
        subRows: [
          { id: 'table-tsx',  name: 'Table.tsx',  size: 4200, type: 'file' },
          { id: 'header-tsx', name: 'Header.tsx', size: 1800, type: 'file' },
        ],
      },
      { id: 'main-tsx', name: 'main.tsx', size: 320, type: 'file' },
    ],
  },
  {
    id: 'public', name: 'public', size: 0, type: 'folder',
    subRows: [
      { id: 'index-html', name: 'index.html', size: 640,  type: 'file' },
      { id: 'favicon',    name: 'favicon.ico', size: 1150, type: 'file' },
    ],
  },
  { id: 'package-json', name: 'package.json', size: 890, type: 'file' },
]

const columns: ColumnDef<FileNode>[] = [
  {
    accessorKey: 'name',
    header: 'Name',
    cell: ({ row, getValue }) => (
      <span style={{ paddingLeft: `${row.depth * 1.5}rem`, display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
        {row.getCanExpand() ? (
          <button onClick={row.getToggleExpandedHandler()}>
            {row.getIsExpanded() ? '▼' : '▶'}
          </button>
        ) : (
          <span style={{ width: '1.25rem', display: 'inline-block' }} />
        )}
        {row.original.type === 'folder' ? '📁' : '📄'}
        {' '}{getValue<string>()}
      </span>
    ),
  },
  {
    accessorKey: 'type',
    header: 'Type',
  },
  {
    accessorKey: 'size',
    header: 'Size (bytes)',
    cell: ({ row, getValue }) => {
      if (row.original.type === 'folder') {
        const total = row.leafRows.reduce(
          (sum, r) => sum + r.getValue<number>('size'),
          0
        )
        return <em>{total.toLocaleString()}</em>
      }
      return getValue<number>().toLocaleString()
    },
  },
]

export default function FileTreeTable() {
  const [expanded, setExpanded] = useState<ExpandedState>({})
  const [sorting, setSorting]   = useState<SortingState>([])

  const table = useReactTable({
    data,
    columns,
    state: { expanded, sorting },
    onExpandedChange: setExpanded,
    onSortingChange: setSorting,
    getCoreRowModel: getCoreRowModel(),
    getExpandedRowModel: getExpandedRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getSubRows: row => row.subRows,
    getRowId: row => row.id,
    getRowCanExpand: row => row.original.type === 'folder',
    filterFromLeafRows: true,
    autoResetExpanded: false,
  })

  return (
    <div>
      <div style={{ marginBottom: '0.5rem' }}>
        <button onClick={() => table.toggleAllRowsExpanded(true)}>Expand All</button>
        {' '}
        <button onClick={() => table.toggleAllRowsExpanded(false)}>Collapse All</button>
      </div>

      <table>
        <thead>
          {table.getHeaderGroups().map(hg => (
            <tr key={hg.id}>
              {hg.headers.map(h => (
                <th
                  key={h.id}
                  onClick={h.column.getToggleSortingHandler()}
                  style={{ cursor: h.column.getCanSort() ? 'pointer' : 'default' }}
                >
                  {flexRender(h.column.columnDef.header, h.getContext())}
                  {h.column.getIsSorted() === 'asc'  ? ' ↑'
                  : h.column.getIsSorted() === 'desc' ? ' ↓'
                  : null}
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

**Mutating `subRows` directly**

TanStack Table reads `subRows` during row model construction. Mutating the array in place without triggering a React state update will not cause a re-render or row model rebuild. Always update tree data via state setters.

**`row.original` type mismatch with mixed child types**

When parent and child rows have different shapes but share a `TData` type, accessing a child-only property via `row.original.childOnlyField` on a parent row returns `undefined` at runtime despite TypeScript not complaining (if the property exists on the union type). Add runtime type guards.

**`getSubRows` returning `[]` vs `undefined`**

Returning `[]` signals "loaded but empty" (no children). Returning `undefined` signals "children not present or not loaded." [Inference] The distinction matters for `getRowCanExpand` and lazy-loading patterns — verify which return value triggers the expected `getCanExpand()` behavior for your version.

**Depth-based indentation only on first column**

Applying `paddingLeft: row.depth * n` to every `<td>` produces misaligned columns. Apply indentation only to the first column or the cell containing the expand toggle.

---

**Related Topics**

- `filterFromLeafRows` and `maxLeafRowFilterDepth` — tree-aware filtering
- Lazy loading sub-rows on expand with async data sources
- `getRowId` strategies for stable IDs in mutable trees
- Manual aggregation on tree data without `getGroupedRowModel`
- Combining tree data with row selection (selecting subtrees)
- Virtualized tree rendering with TanStack Virtual
- Sorting behavior within sibling groups
- Persisting expansion state across sessions
- Mixed grouped and tree-structured data patterns