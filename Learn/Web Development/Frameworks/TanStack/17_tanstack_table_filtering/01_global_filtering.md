## Global Filtering

### Overview

Global filtering in TanStack Table applies a single filter value across all columns simultaneously, as opposed to column-level filters which target individual columns. It is the mechanism behind search-box-style interfaces where a user types a query and all visible columns are checked for a match.

---

### Required Setup

Global filtering requires two additions to the table configuration:

1. `getFilteredRowModel` from `@tanstack/react-table`
2. `globalFilter` state and `onGlobalFilterChange` handler

```ts
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  ColumnDef,
} from '@tanstack/react-table';
import { useState } from 'react';

const [globalFilter, setGlobalFilter] = useState('');

const table = useReactTable({
  data,
  columns,
  state: {
    globalFilter,
  },
  onGlobalFilterChange: setGlobalFilter,
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
});
```

**Key Points:**
- `getFilteredRowModel` handles both column filters and global filters
- Without `getFilteredRowModel`, filtering state changes have no effect on rendered rows
- `globalFilter` state can be any value — string is most common, but custom filter functions can accept other types

---

### Connecting a Search Input

The global filter state is just a React state value. Any input can drive it:

```tsx
<input
  value={globalFilter ?? ''}
  onChange={e => setGlobalFilter(e.target.value)}
  placeholder="Search all columns..."
/>
```

**Key Points:**
- `globalFilter ?? ''` guards against `undefined` initial state
- Debouncing the input is recommended for large datasets to avoid filtering on every keystroke — [Inference] TanStack Table does not debounce internally; this must be implemented externally

---

### Default Global Filter Behavior

By default, TanStack Table uses the built-in `includesString` filter function for global filtering. This function:

- Converts cell values to strings via `String(value).toLowerCase()`
- Checks if the string includes the lowercased filter value
- Is case-insensitive

[Inference] Columns whose values produce `undefined` or `null` after `String()` conversion may match unexpectedly or be excluded from matching. Behavior may vary.

---

### How Global Filter Traverses Columns

When a global filter is active, TanStack Table checks each row against the filter by evaluating the filter function against each column's value. A row passes if **at least one column** matches.

```
Row passes global filter if:
  ANY column value satisfies globalFilterFn(row, columnId, filterValue)
```

This is an OR relationship across columns — not AND.

---

### Controlling Which Columns Participate

By default all columns participate in global filtering. Individual columns can be excluded using `enableGlobalFilter: false` in the column definition:

```ts
const columns: ColumnDef<Person>[] = [
  {
    accessorKey: 'id',
    header: 'ID',
    enableGlobalFilter: false, // Excluded from global filter matching
  },
  {
    accessorKey: 'name',
    header: 'Name',
    // Participates in global filter (default)
  },
  {
    accessorKey: 'email',
    header: 'Email',
    // Participates in global filter (default)
  },
];
```

**Key Points:**
- `enableGlobalFilter: false` excludes the column from the OR evaluation entirely
- This is distinct from `enableColumnFilter: false`, which controls column-level filters only
- Both can be set independently on the same column

---

### `globalFilterFn` — Customizing the Filter Function

The default `includesString` behavior can be replaced by specifying `globalFilterFn` in the table options. This accepts either a string key referencing a built-in filter function or a custom function.

#### Using a Built-in Filter Function

```ts
const table = useReactTable({
  // ...
  globalFilterFn: 'includesStringSensitive', // Case-sensitive variant
});
```

**Built-in filter function keys relevant to global filtering:**

| Key | Behavior |
|---|---|
| `includesString` | Case-insensitive substring match (default) |
| `includesStringSensitive` | Case-sensitive substring match |
| `equalsString` | Case-insensitive exact match |
| `equalsStringSensitive` | Case-sensitive exact match |
| `arrIncludes` | Checks if array cell value includes the filter value |
| `arrIncludesAll` | All filter values present in array cell |
| `arrIncludesSome` | Some filter values present in array cell |
| `equals` | Strict equality (`===`) |
| `weakEquals` | Loose equality (`==`) |
| `inNumberRange` | Numeric range check |

[Inference] Not all built-in functions are meaningful for global filtering — `inNumberRange` and array variants are more suited to column-level filters with structured filter values. Behavior should be tested per use case.

---

#### Using a Custom `globalFilterFn`

```ts
const table = useReactTable({
  data,
  columns,
  state: { globalFilter },
  onGlobalFilterChange: setGlobalFilter,
  globalFilterFn: (row, columnId, filterValue) => {
    const cellValue = row.getValue<string>(columnId);
    if (cellValue == null) return false;
    return String(cellValue)
      .toLowerCase()
      .startsWith(String(filterValue).toLowerCase());
  },
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
});
```

**Key Points:**
- The custom function receives `row`, `columnId`, and `filterValue`
- It is called once per column per row — returning `true` for any column causes the row to pass
- Must return a `boolean`

---

### Registering a Named Custom Filter Function

Custom filter functions can be named and registered for reuse or for use alongside column-level filters:

```ts
import { FilterFn, useReactTable } from '@tanstack/react-table';

const startsWithFilter: FilterFn<Person> = (row, columnId, value) => {
  return String(row.getValue(columnId))
    .toLowerCase()
    .startsWith(String(value).toLowerCase());
};

// Extend the FilterFns type if using TypeScript strictly
declare module '@tanstack/react-table' {
  interface FilterFns {
    startsWith: FilterFn<unknown>;
  }
}

const table = useReactTable({
  // ...
  filterFns: {
    startsWith: startsWithFilter,
  },
  globalFilterFn: 'startsWith',
});
```

---

### Full Minimal Example

```tsx
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  flexRender,
  ColumnDef,
} from '@tanstack/react-table';
import { useState } from 'react';

type Product = {
  name: string;
  category: string;
  sku: string;
};

const data: Product[] = [
  { name: 'Wireless Mouse', category: 'Electronics', sku: 'WM-001' },
  { name: 'USB Hub', category: 'Electronics', sku: 'UH-042' },
  { name: 'Standing Desk', category: 'Furniture', sku: 'SD-100' },
  { name: 'Desk Lamp', category: 'Furniture', sku: 'DL-205' },
];

const columns: ColumnDef<Product>[] = [
  { accessorKey: 'name', header: 'Product Name' },
  { accessorKey: 'category', header: 'Category' },
  {
    accessorKey: 'sku',
    header: 'SKU',
    enableGlobalFilter: false, // SKU excluded from search
  },
];

export default function App() {
  const [globalFilter, setGlobalFilter] = useState('');

  const table = useReactTable({
    data,
    columns,
    state: { globalFilter },
    onGlobalFilterChange: setGlobalFilter,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
  });

  return (
    <div>
      <input
        value={globalFilter}
        onChange={e => setGlobalFilter(e.target.value)}
        placeholder="Search products..."
      />
      <table>
        <thead>
          {table.getHeaderGroups().map(hg => (
            <tr key={hg.id}>
              {hg.headers.map(header => (
                <th key={header.id}>
                  {flexRender(header.column.columnDef.header, header.getContext())}
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
      <p>{table.getFilteredRowCount()} results</p>
    </div>
  );
}
```

**Output:** Typing "elec" matches rows where `name` or `category` contains that substring. The `sku` column is excluded from matching. Row count updates reactively.

---

### Combining Global Filter with Column Filters

Global filter and column filters coexist and compose. Both are applied by `getFilteredRowModel` — a row must pass both the global filter and all active column filters to appear in the output.

```
Visible rows = rows passing globalFilter AND all active columnFilters
```

```ts
const [globalFilter, setGlobalFilter] = useState('');
const [columnFilters, setColumnFilters] = useState([]);

const table = useReactTable({
  data,
  columns,
  state: {
    globalFilter,
    columnFilters,
  },
  onGlobalFilterChange: setGlobalFilter,
  onColumnFiltersChange: setColumnFilters,
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
});
```

---

### Debouncing the Global Filter Input

For large datasets, filtering on every keystroke may cause performance issues. [Inference] A debounced input is the standard mitigation; TanStack Table does not include debounce utilities. Behavior and thresholds depend on dataset size and are not guaranteed.

```tsx
import { useEffect, useState } from 'react';

function DebouncedInput({
  value: initialValue,
  onChange,
  debounce = 300,
  ...props
}: {
  value: string;
  onChange: (value: string) => void;
  debounce?: number;
} & React.InputHTMLAttributes<HTMLInputElement>) {
  const [value, setValue] = useState(initialValue);

  useEffect(() => {
    setValue(initialValue);
  }, [initialValue]);

  useEffect(() => {
    const timeout = setTimeout(() => onChange(value), debounce);
    return () => clearTimeout(timeout);
  }, [value]);

  return (
    <input
      {...props}
      value={value}
      onChange={e => setValue(e.target.value)}
    />
  );
}

// Usage
<DebouncedInput
  value={globalFilter}
  onChange={setGlobalFilter}
  placeholder="Search..."
  debounce={300}
/>
```

---

### `getFilteredRowCount`

The table exposes `table.getFilteredRowCount()` to read the number of rows passing all active filters, useful for displaying result counts:

```tsx
<p>Showing {table.getFilteredRowCount()} of {data.length} rows</p>
```

---

### Global Filter with Manual (Server-Side) Filtering

When filtering is handled server-side, set `manualFiltering: true` to prevent TanStack Table from applying client-side filter logic. The global filter state is still tracked and exposed, but row filtering is left to the server response.

```ts
const table = useReactTable({
  data, // Data already filtered by server
  columns,
  state: { globalFilter },
  onGlobalFilterChange: setGlobalFilter,
  manualFiltering: true,
  getCoreRowModel: getCoreRowModel(),
  // getFilteredRowModel is omitted or can still be included
});
```

**Key Points:**
- `manualFiltering: true` disables client-side filter row model computation
- The application is responsible for re-fetching or re-computing `data` when `globalFilter` changes
- [Inference] `getFilteredRowCount()` may return the full row count when `manualFiltering` is active, since no client-side filtering is applied

---

**Related Topics:**
- Column Filters — per-column filter setup and state
- Column Filters — `enableColumnFilter` per column
- Filter Functions — built-in filter function reference
- Filter Functions — custom `filterFn` per column
- Global Filter — fuzzy/rank-based filtering with external libraries (e.g., `match-sorter`)
- Faceted Values — `getFacetedUniqueValues` for filter option lists
- Manual Filtering — server-side filter integration
- Pagination — interaction between filtering and page state reset