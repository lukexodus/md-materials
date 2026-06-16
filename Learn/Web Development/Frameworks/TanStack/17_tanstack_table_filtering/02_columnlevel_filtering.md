## Column-Level Filtering

### Overview

Column-level filtering in TanStack Table applies independent filter values to individual columns. Unlike global filtering, which checks a single value across all columns, column filters are scoped — each column maintains its own filter value and filter function. This enables compound filtering interfaces such as per-column search inputs, dropdown selectors, date range pickers, and checkbox filters.

---

### Required Setup

Column filtering requires:

1. `getFilteredRowModel` registered in the table options
2. `columnFilters` state and `onColumnFiltersChange` handler

```ts
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  ColumnDef,
  ColumnFiltersState,
} from '@tanstack/react-table';
import { useState } from 'react';

const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);

const table = useReactTable({
  data,
  columns,
  state: {
    columnFilters,
  },
  onColumnFiltersChange: setColumnFilters,
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
});
```

**Key Points:**
- `ColumnFiltersState` is `Array<{ id: string; value: unknown }>` — one entry per active column filter
- A column with no active filter has no entry in the array
- `getFilteredRowModel` is shared with global filtering — one import handles both

---

### `ColumnFiltersState` Shape

```ts
type ColumnFiltersState = ColumnFilter[];

type ColumnFilter = {
  id: string;    // Column ID (typically the accessorKey)
  value: unknown; // The filter value — type depends on the filter function
};
```

**Example state with two active filters:**

```ts
[
  { id: 'name', value: 'alice' },
  { id: 'role', value: 'admin' },
]
```

A row must satisfy all active column filters to appear in the output (AND logic across columns).

---

### Default Filter Behavior

Without a custom `filterFn`, each column uses the table's default filter function. The default is `auto`, which selects a built-in function based on the column's inferred data type:

| Inferred Type | Default Filter Function |
|---|---|
| String | `includesString` |
| Number | `inNumberRange` |
| Array | `arrIncludes` |
| Other | `includesString` |

[Inference] Type inference is based on the first non-nullish value in the column's data. If data is sparse or mixed-type, the inferred default may not behave as expected. Behavior may vary.

---

### Setting a Filter Function Per Column

Each column definition accepts a `filterFn` property to override the default:

```ts
const columns: ColumnDef<Person>[] = [
  {
    accessorKey: 'name',
    header: 'Name',
    filterFn: 'includesString', // Case-insensitive substring (explicit)
  },
  {
    accessorKey: 'age',
    header: 'Age',
    filterFn: 'inNumberRange', // Expects [min, max] as filter value
  },
  {
    accessorKey: 'status',
    header: 'Status',
    filterFn: 'equals', // Strict equality
  },
];
```

---

### Built-in Filter Functions

| Key | Description | Expected Filter Value Type |
|---|---|---|
| `includesString` | Case-insensitive substring match | `string` |
| `includesStringSensitive` | Case-sensitive substring match | `string` |
| `equalsString` | Case-insensitive exact match | `string` |
| `equalsStringSensitive` | Case-sensitive exact match | `string` |
| `equals` | Strict equality (`===`) | `any` |
| `weakEquals` | Loose equality (`==`) | `any` |
| `inNumberRange` | Value falls within `[min, max]` inclusive | `[number, number]` |
| `arrIncludes` | Cell array includes filter value | `any` |
| `arrIncludesAll` | Cell array includes all filter values | `any[]` |
| `arrIncludesSome` | Cell array includes some filter values | `any[]` |

---

### Custom `filterFn`

A custom filter function can be passed directly into the column definition:

```ts
import { FilterFn } from '@tanstack/react-table';

const startsWithFn: FilterFn<Person> = (row, columnId, filterValue) => {
  const cellValue = String(row.getValue<string>(columnId) ?? '');
  return cellValue.toLowerCase().startsWith(String(filterValue).toLowerCase());
};

const columns: ColumnDef<Person>[] = [
  {
    accessorKey: 'name',
    header: 'Name',
    filterFn: startsWithFn,
  },
];
```

**Key Points:**
- Receives `row`, `columnId`, and `filterValue`
- Must return `boolean`
- Can also accept an optional fourth `addMeta` parameter to attach metadata used by faceted value utilities

---

### Registering Named Custom Filter Functions

Custom filter functions can be registered globally on the table and referenced by string key:

```ts
declare module '@tanstack/react-table' {
  interface FilterFns {
    startsWith: FilterFn<unknown>;
  }
}

const table = useReactTable({
  // ...
  filterFns: {
    startsWith: (row, columnId, value) =>
      String(row.getValue(columnId)).toLowerCase().startsWith(String(value).toLowerCase()),
  },
});

// Then per column:
const columns: ColumnDef<Person>[] = [
  {
    accessorKey: 'name',
    filterFn: 'startsWith',
  },
];
```

---

### Disabling Column Filter on Specific Columns

```ts
const columns: ColumnDef<Person>[] = [
  {
    accessorKey: 'id',
    header: 'ID',
    enableColumnFilter: false, // No filter input for this column
  },
  {
    accessorKey: 'name',
    header: 'Name',
    // Column filtering enabled (default)
  },
];
```

**Key Points:**
- `enableColumnFilter: false` prevents the column from participating in column-level filtering
- `column.getCanFilter()` returns `false` for these columns — use this to conditionally render filter inputs
- This is distinct from `enableGlobalFilter: false`, which controls global filter participation only

---

### Reading and Setting Column Filter Values

Each column exposes methods for reading and setting its filter value:

```ts
// Read the current filter value for a column
const currentValue = column.getFilterValue();

// Set a new filter value for a column
column.setFilterValue('alice');

// Clear the filter for a column
column.setFilterValue(undefined);
```

These are the primary APIs for wiring custom filter UI components to individual columns.

---

### Rendering Per-Column Filter Inputs

Filter inputs are typically rendered inside or below the column header. The standard pattern uses `header.column` to access filter APIs:

```tsx
{table.getHeaderGroups().map(headerGroup => (
  <tr key={headerGroup.id}>
    {headerGroup.headers.map(header => (
      <th key={header.id}>
        {flexRender(header.column.columnDef.header, header.getContext())}
        {header.column.getCanFilter() && (
          <input
            value={(header.column.getFilterValue() as string) ?? ''}
            onChange={e => header.column.setFilterValue(e.target.value)}
            placeholder={`Filter ${header.column.id}...`}
          />
        )}
      </th>
    ))}
  </tr>
))}
```

**Key Points:**
- `getCanFilter()` guards against rendering inputs on non-filterable columns
- `getFilterValue()` returns `unknown` — cast to the expected type for the input value
- Setting `undefined` clears the filter entry from `ColumnFiltersState`

---

### Number Range Filter Example

For numeric columns using `inNumberRange`, the filter value is a two-element tuple `[min, max]`:

```tsx
const RangeFilter = ({ column }: { column: Column<Person> }) => {
  const [min, max] = (column.getFilterValue() as [number, number]) ?? ['', ''];

  return (
    <div>
      <input
        type="number"
        value={min}
        onChange={e =>
          column.setFilterValue((old: [number, number]) => [
            e.target.value ? Number(e.target.value) : undefined,
            old?.[1],
          ])
        }
        placeholder="Min"
      />
      <input
        type="number"
        value={max}
        onChange={e =>
          column.setFilterValue((old: [number, number]) => [
            old?.[0],
            e.target.value ? Number(e.target.value) : undefined,
          ])
        }
        placeholder="Max"
      />
    </div>
  );
};
```

---

### Select / Dropdown Filter Example

For columns with a finite set of values (e.g., status, role, category), a `<select>` element is a natural filter UI:

```tsx
const SelectFilter = ({ column }: { column: Column<Person> }) => (
  <select
    value={(column.getFilterValue() as string) ?? ''}
    onChange={e => column.setFilterValue(e.target.value || undefined)}
  >
    <option value="">All</option>
    <option value="admin">Admin</option>
    <option value="editor">Editor</option>
    <option value="viewer">Viewer</option>
  </select>
);
```

**Key Points:**
- Setting the value to `undefined` (via `|| undefined`) removes the filter entry entirely
- The `equals` filter function is appropriate for exact-match dropdown filters

---

### Full Minimal Example

```tsx
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  flexRender,
  ColumnDef,
  ColumnFiltersState,
  Column,
} from '@tanstack/react-table';
import { useState } from 'react';

type Employee = {
  name: string;
  department: string;
  salary: number;
};

const data: Employee[] = [
  { name: 'Alice', department: 'Engineering', salary: 95000 },
  { name: 'Bob', department: 'Design', salary: 78000 },
  { name: 'Carol', department: 'Engineering', salary: 102000 },
  { name: 'Dave', department: 'Marketing', salary: 67000 },
];

const columns: ColumnDef<Employee>[] = [
  {
    accessorKey: 'name',
    header: 'Name',
    filterFn: 'includesString',
  },
  {
    accessorKey: 'department',
    header: 'Department',
    filterFn: 'equals',
  },
  {
    accessorKey: 'salary',
    header: 'Salary',
    filterFn: 'inNumberRange',
  },
];

function ColumnFilter({ column }: { column: Column<Employee> }) {
  if (!column.getCanFilter()) return null;

  if (column.id === 'salary') {
    const [min, max] = (column.getFilterValue() as [number?, number?]) ?? [];
    return (
      <div>
        <input
          type="number"
          value={min ?? ''}
          onChange={e =>
            column.setFilterValue((old: [number?, number?]) => [
              e.target.value ? Number(e.target.value) : undefined,
              old?.[1],
            ])
          }
          placeholder="Min"
        />
        <input
          type="number"
          value={max ?? ''}
          onChange={e =>
            column.setFilterValue((old: [number?, number?]) => [
              old?.[0],
              e.target.value ? Number(e.target.value) : undefined,
            ])
          }
          placeholder="Max"
        />
      </div>
    );
  }

  if (column.id === 'department') {
    return (
      <select
        value={(column.getFilterValue() as string) ?? ''}
        onChange={e => column.setFilterValue(e.target.value || undefined)}
      >
        <option value="">All</option>
        <option value="Engineering">Engineering</option>
        <option value="Design">Design</option>
        <option value="Marketing">Marketing</option>
      </select>
    );
  }

  return (
    <input
      value={(column.getFilterValue() as string) ?? ''}
      onChange={e => column.setFilterValue(e.target.value || undefined)}
      placeholder={`Filter...`}
    />
  );
}

export default function App() {
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);

  const table = useReactTable({
    data,
    columns,
    state: { columnFilters },
    onColumnFiltersChange: setColumnFilters,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
  });

  return (
    <div>
      <table>
        <thead>
          {table.getHeaderGroups().map(hg => (
            <tr key={hg.id}>
              {hg.headers.map(header => (
                <th key={header.id}>
                  {flexRender(header.column.columnDef.header, header.getContext())}
                  <ColumnFilter column={header.column} />
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
      <p>{table.getFilteredRowCount()} of {data.length} rows</p>
    </div>
  );
}
```

**Output:** Each column renders an appropriate filter control. Rows update in real time. A row must satisfy all active column filters simultaneously to remain visible.

---

### Interaction with Global Filter

Column filters and global filter compose with AND logic:

```
Visible rows = rows passing globalFilter AND all active columnFilters
```

Both are handled by the same `getFilteredRowModel`. State is kept separately (`globalFilter` vs `columnFilters`) but evaluated together per row.

---

### Resetting Column Filters

The table exposes a method to reset all column filters at once:

```ts
table.resetColumnFilters();
// Resets columnFilters to [] and clears all active column filter state
```

Individual column filters can be cleared by setting their value to `undefined`:

```ts
column.setFilterValue(undefined);
```

---

### Manual (Server-Side) Column Filtering

When filtering is performed server-side, set `manualFiltering: true`:

```ts
const table = useReactTable({
  data, // Pre-filtered by server
  columns,
  state: { columnFilters },
  onColumnFiltersChange: setColumnFilters,
  manualFiltering: true,
  getCoreRowModel: getCoreRowModel(),
});
```

**Key Points:**
- TanStack Table still tracks `columnFilters` state and fires `onColumnFiltersChange`
- The application is responsible for using the filter state to re-fetch or recompute `data`
- Client-side `getFilteredRowModel` computation is skipped
- [Inference] `getFilteredRowCount()` may reflect the raw row count rather than a filtered count when `manualFiltering` is active

---

### Column Filter APIs — Summary

| API | Description |
|---|---|
| `column.getCanFilter()` | Whether the column supports filtering |
| `column.getFilterValue()` | Current filter value (`unknown`) |
| `column.setFilterValue(value)` | Set or clear the filter value |
| `column.getIsFiltered()` | Whether a filter is currently active |
| `table.getFilteredRowCount()` | Number of rows passing all filters |
| `table.resetColumnFilters()` | Clear all column filter state |

---

**Related Topics:**
- Global Filtering — single-value search across all columns
- Filter Functions — custom `filterFn` signatures and registration
- Faceted Values — `getFacetedUniqueValues` and `getFacetedMinMaxValues` for filter option generation
- Column Visibility — hiding columns vs. disabling filters
- Pagination — resetting page index when filters change
- Manual Filtering — server-side filter integration patterns
- Sorting — interaction between sort and filter row models
- Debouncing — external debounce patterns for filter inputs