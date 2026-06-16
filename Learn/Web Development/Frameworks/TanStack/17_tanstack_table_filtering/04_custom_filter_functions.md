## Custom Filter Functions

### Overview

When the built-in filter functions do not match the required matching logic — fuzzy search, multi-field evaluation, locale-aware comparison, structured object matching, or domain-specific rules — TanStack Table supports fully custom filter functions. These can be defined inline per column, registered globally on the table for reuse, or composed from built-in primitives. Custom filter functions follow a fixed signature and integrate with the same filter state and row model pipeline as built-in functions.

---

### Filter Function Signature

All filter functions — built-in and custom — share the same signature:

```ts
type FilterFn<TData> = {
  (
    row: Row<TData>,
    columnId: string,
    filterValue: unknown,
    addMeta: (meta: FilterMeta) => void
  ): boolean;
  autoRemove?: (value: unknown) => boolean;
  resolveFilterValue?: (value: unknown) => unknown;
};
```

| Parameter | Type | Description |
|---|---|---|
| `row` | `Row<TData>` | The current row being evaluated |
| `columnId` | `string` | The ID of the column being filtered |
| `filterValue` | `unknown` | The current filter value from state |
| `addMeta` | `(meta: FilterMeta) => void` | Attaches metadata to the row for use by faceted value utilities |

**Return value:** `boolean` — `true` to include the row, `false` to exclude it.

---

### Inline Custom Filter Function

The simplest approach — define the function directly in the column definition:

```ts
import { FilterFn, ColumnDef } from '@tanstack/react-table';

const columns: ColumnDef<Person>[] = [
  {
    accessorKey: 'name',
    header: 'Name',
    filterFn: (row, columnId, filterValue) => {
      const value = String(row.getValue<string>(columnId) ?? '').toLowerCase();
      return value.startsWith(String(filterValue).toLowerCase());
    },
  },
];
```

**Key Points:**
- Inline functions are not reusable across columns without extracting them
- TypeScript infers `TData` from the surrounding `ColumnDef<TData>` context
- The `addMeta` parameter can be omitted if metadata is not needed — [Inference] TypeScript may or may not flag this depending on strictness settings and version

---

### Extracted Named Filter Function

Extract the function to a named constant for reuse across multiple columns or tables:

```ts
import { FilterFn } from '@tanstack/react-table';

const startsWithFilter: FilterFn<unknown> = (row, columnId, filterValue) => {
  const cellValue = String(row.getValue(columnId) ?? '').toLowerCase();
  const filter = String(filterValue ?? '').toLowerCase();
  return cellValue.startsWith(filter);
};

startsWithFilter.autoRemove = (val) => !val;
```

```ts
const columns: ColumnDef<Person>[] = [
  { accessorKey: 'firstName', filterFn: startsWithFilter },
  { accessorKey: 'lastName', filterFn: startsWithFilter },
];
```

---

### Registering Named Filter Functions on the Table

Custom filter functions can be registered globally under a string key via the `filterFns` table option. This allows them to be referenced by name in column definitions and in `globalFilterFn`, and provides a single definition point for shared logic.

#### Step 1 — Extend the `FilterFns` interface (TypeScript)

```ts
import { FilterFn } from '@tanstack/react-table';

declare module '@tanstack/react-table' {
  interface FilterFns {
    startsWith: FilterFn<unknown>;
    fuzzy: FilterFn<unknown>;
    dateRange: FilterFn<unknown>;
  }
}
```

This declaration merge makes the string keys type-safe when used in `filterFn` column options.

#### Step 2 — Register on the table

```ts
const table = useReactTable({
  data,
  columns,
  filterFns: {
    startsWith: startsWithFilter,
    fuzzy: fuzzyFilter,
    dateRange: dateRangeFilter,
  },
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
});
```

#### Step 3 — Reference by key in column definitions

```ts
const columns: ColumnDef<Person>[] = [
  { accessorKey: 'name', filterFn: 'startsWith' },
  { accessorKey: 'createdAt', filterFn: 'dateRange' },
];
```

---

### `autoRemove`

The optional `autoRemove` property is a predicate that tells TanStack Table when to automatically remove a filter entry from `ColumnFiltersState`. Without it, empty or invalid filter values remain in state and continue to be evaluated.

```ts
const startsWithFilter: FilterFn<unknown> = (row, columnId, filterValue) => {
  // ...matching logic
};

// Remove the filter when the value is empty, null, or undefined
startsWithFilter.autoRemove = (val) => !val || String(val).trim() === '';
```

**Key Points:**
- `autoRemove` receives the current filter value and returns `true` to remove the filter
- Without `autoRemove`, a filter with an empty string value remains active and evaluates every row
- Each built-in filter function defines its own `autoRemove` — custom functions should too

---

### `resolveFilterValue`

The optional `resolveFilterValue` property transforms the raw filter value before it is passed to the filter function. This is useful for pre-processing — parsing strings into dates, normalizing case, or converting UI state into a structured filter value.

```ts
const dateRangeFilter: FilterFn<unknown> = (row, columnId, filterValue) => {
  // filterValue here is already [Date, Date] after resolveFilterValue runs
  const [start, end] = filterValue as [Date, Date];
  const cellDate = new Date(row.getValue<string>(columnId));
  return cellDate >= start && cellDate <= end;
};

dateRangeFilter.resolveFilterValue = (val) => {
  // Raw value from state is [string, string] — parse to Date objects
  const [start, end] = val as [string, string];
  return [new Date(start), new Date(end)];
};

dateRangeFilter.autoRemove = (val) => {
  const [start, end] = (val ?? []) as [string?, string?];
  return !start && !end;
};
```

**Key Points:**
- `resolveFilterValue` runs once when the filter value changes, not on every row evaluation — [Inference] this may improve performance for expensive transformations, though this is not guaranteed
- The resolved value is what `filterValue` receives inside the main function body
- [Inference] `resolveFilterValue` output is not persisted to state — the raw value remains in `ColumnFiltersState`

---

### The `addMeta` Parameter

The fourth parameter `addMeta` allows attaching arbitrary metadata to a row during filter evaluation. This metadata is used by faceted value utilities (`getFacetedUniqueValues`, `getFacetedMinMaxValues`) and can also be read by cell renderers for purposes like highlighting match scores.

```ts
import { FilterFn, RankingInfo } from '@tanstack/match-sorter-utils';

const fuzzyFilter: FilterFn<unknown> = (row, columnId, filterValue, addMeta) => {
  const itemRank = rankItem(row.getValue(columnId), filterValue);

  // Attach the ranking info to the row for downstream use
  addMeta({ itemRank });

  return itemRank.passed;
};
```

The metadata can then be read in a cell or used to sort results by relevance:

```ts
// Accessing row meta in a sort function
sortingFn: (rowA, rowB, columnId) => {
  const rankA = rowA.columnFiltersMeta[columnId]?.itemRank;
  const rankB = rowB.columnFiltersMeta[columnId]?.itemRank;
  return compareItems(rankA, rankB);
};
```

---

### Fuzzy Filter with `match-sorter-utils`

A fuzzy filter ranks rows by relevance rather than binary include/exclude. The `@tanstack/match-sorter-utils` package (a thin wrapper around `match-sorter`) is the common pairing for this pattern.

```bash
npm install @tanstack/match-sorter-utils
```

```ts
import { FilterFn } from '@tanstack/react-table';
import { rankItem } from '@tanstack/match-sorter-utils';

declare module '@tanstack/react-table' {
  interface FilterFns {
    fuzzy: FilterFn<unknown>;
  }
}

const fuzzyFilter: FilterFn<unknown> = (row, columnId, value, addMeta) => {
  const itemRank = rankItem(row.getValue(columnId), value);
  addMeta({ itemRank });
  return itemRank.passed;
};

fuzzyFilter.autoRemove = (val) => !val;
```

```ts
const table = useReactTable({
  data,
  columns,
  filterFns: { fuzzy: fuzzyFilter },
  globalFilterFn: 'fuzzy',
  state: { globalFilter },
  onGlobalFilterChange: setGlobalFilter,
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
});
```

[Inference] Fuzzy filtering via `rankItem` returns rows that loosely match rather than requiring substring inclusion. Results should be combined with a sort on `itemRank` to present the most relevant rows first. Ranking behavior depends on `match-sorter-utils` internals and is not guaranteed to be stable across versions.

---

### Multi-Field Filter Function

A single column's filter can evaluate multiple fields on the row — useful for composite search across fields not directly visible as columns:

```ts
const fullNameFilter: FilterFn<Person> = (row, _columnId, filterValue) => {
  const first = String(row.getValue<string>('firstName') ?? '').toLowerCase();
  const last = String(row.getValue<string>('lastName') ?? '').toLowerCase();
  const full = `${first} ${last}`;
  return full.includes(String(filterValue).toLowerCase());
};

fullNameFilter.autoRemove = (val) => !val;
```

```ts
const columns: ColumnDef<Person>[] = [
  {
    id: 'fullName',
    header: 'Name',
    accessorFn: row => `${row.firstName} ${row.lastName}`,
    filterFn: fullNameFilter,
  },
];
```

---

### Date Range Filter Function

```ts
const dateRangeFilter: FilterFn<unknown> = (row, columnId, filterValue) => {
  const [start, end] = filterValue as [Date | null, Date | null];
  const cellValue = row.getValue<string>(columnId);
  if (!cellValue) return false;

  const date = new Date(cellValue);
  if (start && date < start) return false;
  if (end && date > end) return false;
  return true;
};

dateRangeFilter.autoRemove = (val) => {
  const [start, end] = (val ?? []) as [Date?, Date?];
  return !start && !end;
};
```

```ts
// Filter UI — two date inputs drive a [Date, Date] filter value
column.setFilterValue([new Date('2024-01-01'), new Date('2024-12-31')]);
```

---

### Enum / Multi-Select Filter Function

For columns with a finite set of values where the user can select multiple options:

```ts
const multiSelectFilter: FilterFn<unknown> = (row, columnId, filterValue) => {
  const selected = filterValue as string[];
  if (!selected || selected.length === 0) return true;
  const cellValue = String(row.getValue(columnId) ?? '');
  return selected.includes(cellValue);
};

multiSelectFilter.autoRemove = (val) => !val || (val as string[]).length === 0;
```

```ts
// Filter UI — multi-select checkbox group
column.setFilterValue(['admin', 'editor']);
// Passes rows where role is 'admin' OR 'editor'
```

---

### Composing with Built-in Filter Functions

Built-in filter functions are importable from `@tanstack/react-table` and can be called within custom logic:

```ts
import { filterFns, FilterFn } from '@tanstack/react-table';

const nameOrEmailFilter: FilterFn<Person> = (row, _columnId, value, addMeta) => {
  return (
    filterFns.includesString(row, 'name', value, addMeta) ||
    filterFns.includesString(row, 'email', value, addMeta)
  );
};

nameOrEmailFilter.autoRemove = (val) => !val;
```

---

### Full Example — Multiple Custom Filter Functions

```tsx
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  flexRender,
  ColumnDef,
  ColumnFiltersState,
  FilterFn,
} from '@tanstack/react-table';
import { useState } from 'react';

type Employee = {
  name: string;
  role: string;
  joinedAt: string;
  salary: number;
};

declare module '@tanstack/react-table' {
  interface FilterFns {
    startsWith: FilterFn<unknown>;
    multiSelect: FilterFn<unknown>;
    dateRange: FilterFn<unknown>;
  }
}

const startsWithFilter: FilterFn<unknown> = (row, columnId, value) =>
  String(row.getValue(columnId) ?? '').toLowerCase().startsWith(String(value).toLowerCase());
startsWithFilter.autoRemove = (val) => !val;

const multiSelectFilter: FilterFn<unknown> = (row, columnId, value) => {
  const selected = value as string[];
  if (!selected?.length) return true;
  return selected.includes(String(row.getValue(columnId)));
};
multiSelectFilter.autoRemove = (val) => !(val as string[])?.length;

const dateRangeFilter: FilterFn<unknown> = (row, columnId, value) => {
  const [start, end] = value as [Date | null, Date | null];
  const date = new Date(row.getValue<string>(columnId));
  if (start && date < start) return false;
  if (end && date > end) return false;
  return true;
};
dateRangeFilter.autoRemove = (val) => {
  const [s, e] = (val ?? []) as [Date?, Date?];
  return !s && !e;
};

const data: Employee[] = [
  { name: 'Alice', role: 'Admin', joinedAt: '2022-03-15', salary: 95000 },
  { name: 'Bob', role: 'Viewer', joinedAt: '2023-07-01', salary: 62000 },
  { name: 'Carol', role: 'Editor', joinedAt: '2021-11-20', salary: 78000 },
  { name: 'Dave', role: 'Admin', joinedAt: '2024-01-10', salary: 101000 },
];

const columns: ColumnDef<Employee>[] = [
  { accessorKey: 'name', header: 'Name', filterFn: 'startsWith' },
  { accessorKey: 'role', header: 'Role', filterFn: 'multiSelect' },
  { accessorKey: 'joinedAt', header: 'Joined', filterFn: 'dateRange' },
  { accessorKey: 'salary', header: 'Salary', filterFn: 'inNumberRange' },
];

export default function App() {
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);

  const table = useReactTable({
    data,
    columns,
    filterFns: { startsWith: startsWithFilter, multiSelect: multiSelectFilter, dateRange: dateRangeFilter },
    state: { columnFilters },
    onColumnFiltersChange: setColumnFilters,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
  });

  const nameCol = table.getColumn('name');
  const roleCol = table.getColumn('role');

  return (
    <div>
      <input
        placeholder="Name starts with..."
        value={(nameCol?.getFilterValue() as string) ?? ''}
        onChange={e => nameCol?.setFilterValue(e.target.value || undefined)}
      />
      <div>
        {['Admin', 'Editor', 'Viewer'].map(role => (
          <label key={role}>
            <input
              type="checkbox"
              onChange={e => {
                const current = (roleCol?.getFilterValue() as string[]) ?? [];
                const updated = e.target.checked
                  ? [...current, role]
                  : current.filter(r => r !== role);
                roleCol?.setFilterValue(updated.length ? updated : undefined);
              }}
            />
            {role}
          </label>
        ))}
      </div>
      <table>
        <thead>
          {table.getHeaderGroups().map(hg => (
            <tr key={hg.id}>
              {hg.headers.map(h => (
                <th key={h.id}>{flexRender(h.column.columnDef.header, h.getContext())}</th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map(row => (
            <tr key={row.id}>
              {row.getVisibleCells().map(cell => (
                <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
      <p>{table.getFilteredRowCount()} of {data.length} results</p>
    </div>
  );
}
```

**Output:** Name uses a starts-with filter, Role uses a multi-select checkbox filter, Joined uses a date range filter, and Salary uses the built-in `inNumberRange`. All filters compose with AND logic.

---

### Common Mistakes

**Mistake:** Omitting `autoRemove`, leaving empty filter values active.
**Correction:** Always define `autoRemove` to return `true` when the filter value is empty, null, undefined, or otherwise meaningless for your logic.

**Mistake:** Using `row.original` directly instead of `row.getValue(columnId)`.
**Correction:** `row.getValue(columnId)` returns the processed accessor value and respects any `accessorFn` transformations. `row.original` bypasses this and accesses raw data directly — use it only when you intentionally need fields outside the column's accessor.

**Mistake:** Forgetting the `declare module` augmentation when using registered filter function string keys in TypeScript.
**Correction:** Without the `FilterFns` interface augmentation, TypeScript will not recognize custom string keys in `filterFn` column options and will produce type errors.

**Mistake:** Performing expensive computation (e.g., parsing dates, compiling regex) inside the main filter function body.
**Correction:** Use `resolveFilterValue` to perform transformation once per filter value change rather than once per row per evaluation.

---

**Related Topics:**
- Built-in Filter Functions — reference for all built-in keys and their behavior
- Column-Level Filtering — `filterFn` per column, `enableColumnFilter`, `getCanFilter()`
- Global Filtering — `globalFilterFn` and applying custom logic across all columns
- Fuzzy Filtering — `@tanstack/match-sorter-utils` integration and rank-based sorting
- Faceted Values — `getFacetedUniqueValues` and `addMeta` interaction
- `resolveFilterValue` — pre-processing filter values before row evaluation
- Manual Filtering — bypassing client-side filter logic for server-side handling
- Sorting — combining fuzzy filter rank metadata with custom `sortingFn`