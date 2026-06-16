## TanStack Table — Built-in Aggregation Functions

### Overview

Aggregation functions compute summary values for group rows, collapsing the values of all leaf rows within a group into a single representative value. TanStack Table ships with a set of built-in aggregation functions that cover the most common statistical and collection operations. These functions are referenced by string identifier in column definitions and are applied automatically when grouping is active.

Aggregation only produces visible output when `getGroupedRowModel` is active and a column has an `aggregationFn` assigned. Without grouping, aggregation functions are never invoked.

---

### How Aggregation Fits into the Pipeline

Raw DataFilteringGrouping(getGroupedRowModel)Aggregation(aggregationFn percolumn)SortingPaginationRendering

After grouping organizes leaf rows under group rows, the aggregation step walks each group row and calls the assigned `aggregationFn` for every column that declares one. The result is stored on the group row and made available via `cell.getIsAggregated()` during rendering.

[Inference] Aggregation is recomputed whenever grouping state, data, or filtering state changes — behavior and timing of recomputation may vary depending on memoization within your framework adapter.

---

### Declaring an Aggregation Function on a Column

ts

```ts
const columns: ColumnDef<Employee>[] = [
  {
    accessorKey: 'salary',
    header: 'Salary',
    aggregationFn: 'mean',       // built-in identifier string
    aggregatedCell: ({ getValue }) =>
      `$${Math.round(getValue<number>()).toLocaleString()}`,
  },
]
```

`aggregationFn` accepts:

- A built-in string identifier (covered in this article)
- A custom function `(columnId, leafRows, childRows) => unknown`
- An array of aggregation function identifiers for fallback chaining [Inference — behavior may vary]

`aggregatedCell` is an optional separate cell renderer used exclusively for group rows. If omitted, the standard `cell` renderer is used for aggregated values as well.

---

### The Built-in Aggregation Functions

TanStack Table defines its built-in aggregation functions in `aggregationFns`. Each is available by its string key.

---

#### `sum`

Adds all leaf row values for a column.

**Signature (internal):**

ts

```ts
(columnId, leafRows) =>
  leafRows.reduce((sum, row) => sum + (row.getValue(columnId) ?? 0), 0)
```

**Example:**

ts

```ts
{
  accessorKey: 'salary',
  aggregationFn: 'sum',
}
```

**Output** — for a group of three employees with salaries `90000`, `95000`, `120000`:

```
305000
```

Suitable for numeric columns where totalling is meaningful (revenue, headcount, quantity).

---

#### `min`

Returns the smallest value among all leaf rows in the group.

**Example:**

ts

```ts
{
  accessorKey: 'salary',
  aggregationFn: 'min',
}
```

**Output:**

```
90000
```

Works on any value type that supports the `<` operator. [Inference] For non-numeric types such as strings, comparison follows JavaScript's default less-than semantics — behavior may vary across locales and value types.

---

#### `max`

Returns the largest value among all leaf rows in the group.

**Example:**

ts

```ts
{
  accessorKey: 'salary',
  aggregationFn: 'max',
}
```

**Output:**

```
120000
```

---

#### `mean`

Computes the arithmetic mean (average) of all leaf row values.

**Internal behavior:**

ts

```ts
sum(columnId, leafRows) / leafRows.length
```

**Example:**

ts

```ts
{
  accessorKey: 'salary',
  aggregationFn: 'mean',
}
```

**Output** — for salaries `90000`, `95000`, `120000`:

```
101666.67
```

`mean` delegates to the `sum` function internally, so it inherits the same numeric coercion behavior. [Inference] If a leaf row value is `null` or `undefined`, it is treated as `0` in the sum — verify this against your actual data to avoid skewed averages.

---

#### `median`

Returns the median value of all leaf rows in the group.

**Internal behavior:** sorts the leaf row values numerically, then returns the middle value (or the average of the two middle values for even-length arrays). [Inference — exact implementation may vary by version; verify against source if precision is critical]

**Example:**

ts

```ts
{
  accessorKey: 'salary',
  aggregationFn: 'median',
}
```

**Output** — for salaries `[90000, 95000, 120000]` (odd count):

```
95000
```

**Output** — for salaries `[90000, 95000, 110000, 120000]` (even count):

```
102500
```

---

#### `unique`

Collects all distinct values across leaf rows and returns them as an array.

**Example:**

ts

```ts
{
  accessorKey: 'role',
  aggregationFn: 'unique',
}
```

**Output** — for a group with roles `['Engineer', 'Engineer', 'Manager']`:

ts

```ts
['Engineer', 'Manager']
```

Uniqueness is determined by strict equality (`===`). [Inference] Object values are compared by reference, not by content — behavior may vary for non-primitive column values.

**Rendering the array:**

ts

```ts
aggregatedCell: ({ getValue }) => getValue<string[]>().join(', ')
```

---

#### `uniqueCount`

Returns the count of distinct values, rather than the array itself.

**Example:**

ts

```ts
{
  accessorKey: 'role',
  aggregationFn: 'uniqueCount',
}
```

**Output** — for roles `['Engineer', 'Engineer', 'Manager']`:

```
2
```

Useful for summary dashboards where cardinality matters more than the actual values.

---

#### `count`

Returns the total number of leaf rows in the group, regardless of column value.

**Example:**

ts

```ts
{
  accessorKey: 'name',
  aggregationFn: 'count',
}
```

**Output** — for a group of five employees:

```
5
```

`count` ignores the column value entirely; it counts rows. This means the result is the same regardless of which column it is placed on. [Inference] Using `count` on multiple columns in the same table will produce identical numeric values for each — this is expected behavior.

---

#### `extent`

Returns a two-element array `[min, max]` representing the value range of the group.

**Example:**

ts

```ts
{
  accessorKey: 'salary',
  aggregationFn: 'extent',
}
```

**Output:**

ts

```ts
[90000, 120000]
```

**Rendering:**

ts

```ts
aggregatedCell: ({ getValue }) => {
  const [min, max] = getValue<[number, number]>()
  return `$${min.toLocaleString()} – $${max.toLocaleString()}`
}
```

`extent` is particularly useful for date columns or numeric range display.

---

### Reference Table

| Identifier | Input Type | Output Type | Description |
| --- | --- | --- | --- |
| `sum` | `number` | `number` | Total of all leaf values |
| `min` | `number | string` | same | Smallest leaf value |
| `max` | `number | string` | same | Largest leaf value |
| `mean` | `number` | `number` | Arithmetic average |
| `median` | `number` | `number` | Middle value or midpoint of two middle values |
| `unique` | `any` | `any[]` | Array of distinct values |
| `uniqueCount` | `any` | `number` | Count of distinct values |
| `count` | any | `number` | Count of leaf rows |
| `extent` | `number | string` | `[min, max]` | Tuple of min and max |

---

### Using Multiple Aggregation Functions on One Column

[Inference] TanStack Table does not natively support multiple simultaneous aggregation results stored on a single column cell — only one `aggregationFn` can be active per column per render. Behavior of passing an array may vary by version. To display multiple aggregate values for the same data, use separate accessor columns pointing to the same field:

ts

```ts
const columns: ColumnDef<Employee>[] = [
  {
    id: 'salaryMin',
    accessorKey: 'salary',
    header: 'Min Salary',
    aggregationFn: 'min',
    aggregatedCell: ({ getValue }) => `$${getValue<number>().toLocaleString()}`,
  },
  {
    id: 'salaryMax',
    accessorKey: 'salary',
    header: 'Max Salary',
    aggregationFn: 'max',
    aggregatedCell: ({ getValue }) => `$${getValue<number>().toLocaleString()}`,
  },
  {
    id: 'salaryMean',
    accessorKey: 'salary',
    header: 'Avg Salary',
    aggregationFn: 'mean',
    aggregatedCell: ({ getValue }) =>
      `$${Math.round(getValue<number>()).toLocaleString()}`,
  },
]
```

---

### Aggregated Cell Rendering Pattern

For consistent rendering across group and leaf rows:

tsx

```tsx
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
```

If `aggregatedCell` is not defined on a column, `flexRender` falls back to the standard `cell` renderer, which receives the aggregated value via `getValue()`. This can produce unexpected output if the leaf cell renderer assumes a non-array value and the aggregation function returns an array (e.g., `unique`). Always define `aggregatedCell` when the output type differs from the leaf value type.

---

### Accessing Aggregate Values Programmatically

ts

```ts
// On a group row, get the aggregated value for a specific column
const avgSalary = row.getValue('salary')   // returns the aggregated result
```

`row.getValue(columnId)` on a group row returns the result of `aggregationFn`, not any single leaf value. On a leaf row, it returns the raw data value.

---

### Diagram — Aggregation Data Flow for a Group

Group Row: EngineeringLeaf: Alice — salary:90000Leaf: Bob — salary:120000Leaf: Eve — salary:95000aggregationFn: 'mean'Aggregated Value:101666.67aggregatedCell renderer→ '$101,667'

---

### Null and Undefined Handling

Built-in aggregation functions generally do not perform explicit null guards. [Inference] Passing `null` or `undefined` leaf values to `sum` or `mean` may produce `NaN` or treat the value as `0` depending on JavaScript coercion — behavior is not guaranteed. Sanitize data upstream or use a custom aggregation function that handles missing values explicitly:

ts

```ts
aggregationFn: (columnId, leafRows) => {
  const values = leafRows
    .map(row => row.getValue<number>(columnId))
    .filter((v): v is number => typeof v === 'number' && !isNaN(v))
  return values.length ? values.reduce((a, b) => a + b, 0) / values.length : null
}
```

---

**Related Topics**

- Custom aggregation functions (`aggregationFn` as a function)
- `aggregatedCell` vs `cell` renderer differences
- Rendering arrays from `unique` with custom formatters
- Multi-level aggregation in nested groups
- Aggregation combined with column pinning
- Sorting group rows by aggregated values
- Server-side aggregation with `manualGrouping`
- `getGroupedRowModel` internals and aggregation timing
- Aggregation with filtered subsets (`getFilteredRowModel` interaction)