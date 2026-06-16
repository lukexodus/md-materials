## TanStack Table — Custom Aggregation Functions

### Overview

When the built-in aggregation functions do not fit a use case — weighted averages, geometric means, concatenated strings, conditional totals, multi-field computations — TanStack Table allows fully custom aggregation functions. A custom aggregation function is any function that accepts the column ID and the relevant row sets, then returns a single aggregated value. Custom functions can be registered globally on the table instance or supplied inline per column.

---

### Function Signature

Every aggregation function, built-in or custom, conforms to this signature:

ts

```ts
type AggregationFn<TData> = (
  columnId: string,
  leafRows: Row<TData>[],
  childRows: Row<TData>[]
) => unknown
```

| Parameter | Type | Description |
| --- | --- | --- |
| `columnId` | `string` | The ID of the column being aggregated |
| `leafRows` | `Row<TData>[]` | All original data rows within this group, flattened |
| `childRows` | `Row<TData>[]` | Direct child rows of this group — may be sub-group rows or leaf rows depending on nesting depth |

**`leafRows` vs `childRows`**

This distinction matters for nested grouping. Given grouping by `department` then `role`:

- `leafRows` — all individual employee rows under the `Engineering` group, regardless of `role` sub-group
- `childRows` — the immediate `role` sub-group rows (`Engineer`, `Manager`) directly under `Engineering`

For single-level grouping, `leafRows` and `childRows` contain the same rows. [Inference] For multi-level aggregation that should operate on intermediate group values (e.g., averaging already-averaged sub-group values), use `childRows` — behavior of mixing the two may produce unexpected double-counting; verify against your data shape.

---

### Inline Custom Function

The simplest approach is supplying a function directly to `aggregationFn` in the column definition:

ts

```ts
const columns: ColumnDef<Employee>[] = [
  {
    accessorKey: 'salary',
    header: 'Salary',
    aggregationFn: (columnId, leafRows) => {
      const values = leafRows
        .map(row => row.getValue<number>(columnId))
        .filter((v): v is number => typeof v === 'number' && !isNaN(v))
      return values.length
        ? values.reduce((sum, v) => sum + v, 0) / values.length
        : null
    },
    aggregatedCell: ({ getValue }) => {
      const v = getValue<number | null>()
      return v !== null ? `$${Math.round(v).toLocaleString()}` : '—'
    },
  },
]
```

This is convenient for one-off cases but cannot be referenced by string elsewhere in the table configuration.

---

### Globally Registered Custom Functions

For reuse across multiple columns or tables, register custom aggregation functions on the table via `aggregationFns`:

ts

```ts
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getGroupedRowModel: getGroupedRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
  aggregationFns: {
    weightedMean: (columnId, leafRows) => { /* ... */ },
    percentFilled: (columnId, leafRows) => { /* ... */ },
    joinUnique: (columnId, leafRows) => { /* ... */ },
  },
  state: { grouping },
  onGroupingChange: setGrouping,
})
```

Once registered, they are referenced by string key in column definitions:

ts

```ts
{
  accessorKey: 'salary',
  aggregationFn: 'weightedMean',
}
```

---

### TypeScript: Extending the AggregationFns Registry

To get type inference when using custom aggregation function string keys, extend TanStack Table's type registry:

ts

```ts
// tanstack-table.d.ts
import '@tanstack/react-table'

declare module '@tanstack/react-table' {
  interface AggregationFns {
    weightedMean: AggregationFn<unknown>
    percentFilled: AggregationFn<unknown>
    joinUnique: AggregationFn<unknown>
  }
}
```

With this declaration, `aggregationFn: 'weightedMean'` is type-checked against the registered names, and unrecognized string keys produce a compile-time error.

---

### Practical Custom Aggregation Functions

#### Weighted Mean

Computes an average weighted by a separate column (e.g., average salary weighted by headcount).

ts

```ts
const weightedMeanByHeadcount: AggregationFn<Employee> = (columnId, leafRows) => {
  let weightedSum = 0
  let totalWeight = 0

  for (const row of leafRows) {
    const value   = row.getValue<number>(columnId)
    const weight  = row.getValue<number>('headcount')
    if (typeof value === 'number' && typeof weight === 'number') {
      weightedSum  += value * weight
      totalWeight  += weight
    }
  }

  return totalWeight > 0 ? weightedSum / totalWeight : null
}
```

**Example:**

| Employee | Salary | Headcount |
| --- | --- | --- |
| Alice | 90,000 | 3 |
| Bob | 120,000 | 1 |

```
weightedMean = (90000×3 + 120000×1) / (3+1) = 97500
```

---

#### Geometric Mean

Used for growth rates, ratios, or any multiplicative quantity.

ts

```ts
const geometricMean: AggregationFn<unknown> = (columnId, leafRows) => {
  const values = leafRows
    .map(row => row.getValue<number>(columnId))
    .filter((v): v is number => typeof v === 'number' && v > 0)

  if (!values.length) return null

  const logSum = values.reduce((acc, v) => acc + Math.log(v), 0)
  return Math.exp(logSum / values.length)
}
```

[Inference] Values of `0` or negative numbers are excluded here by the `v > 0` guard because `Math.log` returns `-Infinity` or `NaN` for non-positive inputs — verify this exclusion is appropriate for your data.

---

#### Percentage of Rows Matching a Condition

Returns the proportion of leaf rows where the column value satisfies a predicate.

ts

```ts
const percentActive: AggregationFn<Employee> = (columnId, leafRows) => {
  if (!leafRows.length) return null
  const matching = leafRows.filter(
    row => row.getValue<string>(columnId) === 'active'
  ).length
  return (matching / leafRows.length) * 100
}
```

**Aggregated cell:**

ts

```ts
aggregatedCell: ({ getValue }) => {
  const v = getValue<number | null>()
  return v !== null ? `${v.toFixed(1)}%` : '—'
}
```

---

#### Concatenating Unique String Values

Produces a comma-separated list of distinct values, with optional truncation.

ts

```ts
const joinUnique: AggregationFn<unknown> = (columnId, leafRows) => {
  const seen = new Set<string>()
  for (const row of leafRows) {
    const v = row.getValue<string>(columnId)
    if (v != null) seen.add(String(v))
  }
  return Array.from(seen).sort().join(', ')
}
```

**Output** — for roles `['Engineer', 'Engineer', 'Manager', 'Designer']`:

```
Designer, Engineer, Manager
```

---

#### First Non-Null Value

Useful for columns where all rows in a group share the same value (e.g., a region code), and you want to surface that shared value on the group row.

ts

```ts
const firstNonNull: AggregationFn<unknown> = (columnId, leafRows) => {
  for (const row of leafRows) {
    const v = row.getValue(columnId)
    if (v != null) return v
  }
  return null
}
```

[Inference] If leaf rows may have different values for this column, `firstNonNull` returns only the first encountered, which may be misleading — consider pairing it with a validation step or using `unique` to detect heterogeneity.

---

#### Conditional Sum (Sum with Predicate)

Sums only rows that satisfy an additional column condition.

ts

```ts
const sumActiveOnly: AggregationFn<Employee> = (columnId, leafRows) => {
  return leafRows
    .filter(row => row.getValue<string>('status') === 'active')
    .reduce((acc, row) => {
      const v = row.getValue<number>(columnId)
      return acc + (typeof v === 'number' ? v : 0)
    }, 0)
}
```

---

#### Multi-Column Aggregation

Custom functions have access to the full `Row` object, so they can read from any column, not just the one being aggregated:

ts

```ts
const revenuePerHead: AggregationFn<Department> = (_columnId, leafRows) => {
  const totalRevenue = leafRows.reduce((acc, row) => {
    return acc + (row.getValue<number>('revenue') ?? 0)
  }, 0)
  const totalHeadcount = leafRows.reduce((acc, row) => {
    return acc + (row.getValue<number>('headcount') ?? 0)
  }, 0)
  return totalHeadcount > 0 ? totalRevenue / totalHeadcount : null
}
```

The `_columnId` parameter is ignored here because the function reads two other columns directly. This is valid because `leafRows` carry the full row data. [Inference] Reading columns that are not yet resolved in the pipeline (e.g., computed columns defined after this one) may produce `undefined` — behavior depends on column definition order and may vary.

---

### Using `childRows` for Nested Aggregation

When grouping by multiple levels and you want to aggregate already-aggregated sub-group values rather than raw leaf values:

ts

```ts
const meanOfGroupMeans: AggregationFn<Employee> = (columnId, _leafRows, childRows) => {
  const subMeans = childRows
    .map(row => row.getValue<number>(columnId))
    .filter((v): v is number => typeof v === 'number' && !isNaN(v))

  return subMeans.length
    ? subMeans.reduce((a, b) => a + b, 0) / subMeans.length
    : null
}
```

[Inference] This works only when sub-group rows have already been aggregated themselves, which occurs when `getGroupedRowModel` processes inner groups before outer groups — verify against actual multi-level grouping behavior in your version.

---

### Diagram — `leafRows` vs `childRows` in Nested Grouping

Group: EngineeringaggregationFn sees:childRow: role=Engineeraggregated salary: 92500childRow: role=Manageraggregated salary:120000leafRow: Alice — 90000leafRow: Eve — 95000leafRow: Bob — 120000

At the `Engineering` level:

- `leafRows` → `[Alice, Eve, Bob]` (all three raw rows)
- `childRows` → `[role=Engineer group row, role=Manager group row]`

---

### Combining a Custom Function with `aggregatedCell`

The aggregation function computes the value; `aggregatedCell` controls how it is displayed. They are deliberately separate:

ts

```ts
{
  accessorKey: 'score',
  header: 'Score',
  aggregationFn: geometricMean,
  aggregatedCell: ({ getValue, row }) => {
    const v = getValue<number | null>()
    if (v === null) return '—'
    return (
      <span title={`${row.subRows.length} rows`}>
        {v.toFixed(2)} ✕
      </span>
    )
  },
}
```

The `aggregatedCell` renderer receives the same `CellContext` as a regular `cell`, but `getValue()` returns the result of `aggregationFn` rather than a raw data value.

---

### Error Handling and Defensive Patterns

Custom aggregation functions should not throw, as errors inside the grouping pipeline can prevent the entire row model from rendering. [Inference] TanStack Table does not wrap aggregation function calls in try-catch internally — behavior on thrown errors may vary by version.

Defensive pattern:

ts

```ts
const safeCustomAgg: AggregationFn<unknown> = (columnId, leafRows) => {
  try {
    const values = leafRows
      .map(row => row.getValue<number>(columnId))
      .filter((v): v is number => Number.isFinite(v))

    if (!values.length) return null
    return values.reduce((a, b) => a + b, 0) / values.length
  } catch {
    return null
  }
}
```

---

### Sharing Aggregation Functions Across Tables

For large applications, define all custom aggregation functions in a shared module:

ts

```ts
// lib/aggregationFns.ts
import { AggregationFn } from '@tanstack/react-table'

export const aggregationFns = {
  weightedMean:  weightedMeanByHeadcount,
  geometricMean: geometricMean,
  percentActive: percentActive,
  joinUnique:    joinUnique,
  firstNonNull:  firstNonNull,
} satisfies Record<string, AggregationFn<any>>
```

Import and spread into any table configuration:

ts

```ts
const table = useReactTable({
  aggregationFns: {
    ...aggregationFns,
  },
  // ...
})
```

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
  AggregationFn,
} from '@tanstack/react-table'

type Employee = {
  name: string
  department: string
  salary: number
  status: string
}

const data: Employee[] = [
  { name: 'Alice', department: 'Engineering', salary: 90000,  status: 'active' },
  { name: 'Bob',   department: 'Engineering', salary: 120000, status: 'active' },
  { name: 'Carol', department: 'Design',      salary: 85000,  status: 'inactive' },
  { name: 'Dave',  department: 'Design',      salary: 110000, status: 'active' },
  { name: 'Eve',   department: 'Engineering', salary: 95000,  status: 'inactive' },
]

const activeRatio: AggregationFn<Employee> = (columnId, leafRows) => {
  if (!leafRows.length) return null
  const active = leafRows.filter(
    r => r.getValue<string>('status') === 'active'
  ).length
  return (active / leafRows.length) * 100
}

const columns: ColumnDef<Employee>[] = [
  { accessorKey: 'department', header: 'Department' },
  { accessorKey: 'name',       header: 'Name', enableGrouping: false },
  {
    accessorKey: 'salary',
    header: 'Avg Salary',
    aggregationFn: 'mean',
    aggregatedCell: ({ getValue }) => {
      const v = getValue<number>()
      return `$${Math.round(v).toLocaleString()}`
    },
  },
  {
    accessorKey: 'status',
    header: '% Active',
    aggregationFn: activeRatio,
    aggregatedCell: ({ getValue }) => {
      const v = getValue<number | null>()
      return v !== null ? `${v.toFixed(0)}%` : '—'
    },
  },
]

export default function CustomAggTable() {
  const [grouping, setGrouping] = useState<GroupingState>(['department'])
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
    aggregationFns: { activeRatio },
  })

  return (
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
  )
}
```

---

**Related Topics**

- `aggregatedCell` vs `cell` renderer — when and why to separate them
- Built-in aggregation functions and when to prefer them over custom ones
- Aggregation with nested multi-level grouping using `childRows`
- TypeScript module augmentation for custom aggregation function string keys
- Server-side aggregation with `manualGrouping`
- Sorting group rows by custom aggregated values
- Aggregation interaction with `getFilteredRowModel` (filtered leaf rows)
- Combining aggregation with column pinning and visibility
- Memoizing expensive custom aggregation functions