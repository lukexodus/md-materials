## Built-in Filter Functions

### Overview

TanStack Table ships with a set of built-in filter functions that cover the most common filtering patterns — string matching, numeric ranges, array membership, and equality checks. These functions are available by string key and can be referenced in both column definitions (`filterFn`) and as the global filter function (`globalFilterFn`). Understanding each function's expected input type and matching behavior is necessary to wire filter UI controls correctly.

---

### Referencing Built-in Filter Functions

Built-in filter functions are referenced by string key in column definitions or table options:

```ts
const columns: ColumnDef<Person>[] = [
  {
    accessorKey: 'name',
    filterFn: 'includesString',
  },
  {
    accessorKey: 'age',
    filterFn: 'inNumberRange',
  },
];

// Or as globalFilterFn:
const table = useReactTable({
  // ...
  globalFilterFn: 'includesString',
});
```

They can also be imported directly as function values for use in custom logic or direct assignment:

```ts
import { filterFns } from '@tanstack/react-table';

const myFn = filterFns.includesString;
```

---

### The `auto` Default

When no `filterFn` is specified on a column, TanStack Table uses `'auto'` — a meta-function that selects a built-in based on the column's inferred value type:

| Inferred Value Type | Resolved Function |
|---|---|
| `string` | `includesString` |
| `number` | `inNumberRange` |
| `boolean` | `equals` |
| `Array` | `arrIncludes` |
| Fallback | `includesString` |

[Inference] Type inference is based on the first non-nullish cell value in the column. Sparse or mixed-type columns may resolve to an unexpected default. Behavior may vary across versions.

---

### String Filter Functions

#### `includesString`

Case-insensitive substring match. The most commonly used default for text columns.

```
passes if: String(cellValue).toLowerCase().includes(String(filterValue).toLowerCase())
```

**Expected filter value:** `string`

```ts
{ accessorKey: 'name', filterFn: 'includesString' }
```

```ts
// Matches rows where name contains "ali" (case-insensitive)
column.setFilterValue('ali');
// Matches: "Alice", "ALIA", "Dali"
```

---

#### `includesStringSensitive`

Case-sensitive substring match. Behaves identically to `includesString` but does not lowercase before comparison.

```
passes if: String(cellValue).includes(String(filterValue))
```

**Expected filter value:** `string`

```ts
column.setFilterValue('Ali');
// Matches: "Alice", "Alibaba"
// Does NOT match: "alice", "ALI"
```

---

#### `equalsString`

Case-insensitive exact string match. The entire cell value must equal the filter value after lowercasing both.

```
passes if: String(cellValue).toLowerCase() === String(filterValue).toLowerCase()
```

**Expected filter value:** `string`

```ts
column.setFilterValue('admin');
// Matches: "admin", "Admin", "ADMIN"
// Does NOT match: "administrator"
```

---

#### `equalsStringSensitive`

Case-sensitive exact string match.

```
passes if: String(cellValue) === String(filterValue)
```

**Expected filter value:** `string`

```ts
column.setFilterValue('Admin');
// Matches: "Admin" only
// Does NOT match: "admin", "ADMIN"
```

---

### Equality Filter Functions

#### `equals`

Strict equality using `===`. Works with any value type — strings, numbers, booleans, or object references.

```
passes if: cellValue === filterValue
```

**Expected filter value:** `any` (matched with `===`)

```ts
{ accessorKey: 'isActive', filterFn: 'equals' }

column.setFilterValue(true);
// Matches rows where isActive === true
```

**Key Points:**
- Object and array references are compared by identity, not by deep equality — [Inference] this makes `equals` unsuitable for filtering by object or array cell values unless references are stable

---

#### `weakEquals`

Loose equality using `==`. Allows type coercion — e.g., `1 == '1'` passes.

```
passes if: cellValue == filterValue
```

**Expected filter value:** `any`

```ts
column.setFilterValue('1');
// Matches rows where cellValue == '1', including numeric 1
```

[Inference] `weakEquals` is rarely the right choice for user-facing filter interfaces. It exists for edge cases where type coercion is intentional. Its use should be deliberate and tested.

---

### Numeric Filter Functions

#### `inNumberRange`

Checks whether a numeric cell value falls within an inclusive `[min, max]` range. Either bound can be `undefined` or `null` to make the range open-ended.

```
passes if: cellValue >= min && cellValue <= max
```

**Expected filter value:** `[number | undefined, number | undefined]`

```ts
{ accessorKey: 'salary', filterFn: 'inNumberRange' }

column.setFilterValue([50000, 100000]);
// Matches rows where salary >= 50000 AND salary <= 100000

column.setFilterValue([50000, undefined]);
// Matches rows where salary >= 50000 (no upper bound)

column.setFilterValue([undefined, 100000]);
// Matches rows where salary <= 100000 (no lower bound)
```

**Key Points:**
- Both bounds are inclusive
- The filter value must be a two-element array — passing a scalar number does not work with this function
- [Inference] Passing `null` in place of `undefined` for an open bound may behave equivalently in practice, but `undefined` is the documented approach

---

### Array Filter Functions

These functions are designed for columns where each cell value is an array — for example, a `tags` field that contains `['javascript', 'react']`.

---

#### `arrIncludes`

Passes if the cell's array value includes the filter value. Single-value membership check.

```
passes if: cellValue.includes(filterValue)
```

**Expected filter value:** `any` (a single item to look for in the array)

```ts
{ accessorKey: 'tags', filterFn: 'arrIncludes' }

column.setFilterValue('react');
// Matches rows where tags array contains 'react'
```

---

#### `arrIncludesAll`

Passes if the cell's array value includes **all** items in the filter value array. AND logic across the filter values.

```
passes if: filterValue.every(val => cellValue.includes(val))
```

**Expected filter value:** `any[]` (all must be present in the cell array)

```ts
column.setFilterValue(['react', 'typescript']);
// Matches rows where tags contains BOTH 'react' AND 'typescript'
```

---

#### `arrIncludesSome`

Passes if the cell's array value includes **at least one** item from the filter value array. OR logic across the filter values.

```
passes if: filterValue.some(val => cellValue.includes(val))
```

**Expected filter value:** `any[]` (at least one must be present in the cell array)

```ts
column.setFilterValue(['react', 'vue']);
// Matches rows where tags contains 'react' OR 'vue' (or both)
```

---

### Comparison: Array Filter Functions

| Function | Filter Value Type | Row Passes If |
|---|---|---|
| `arrIncludes` | Single value | Cell array contains the value |
| `arrIncludesAll` | Array of values | Cell array contains ALL values |
| `arrIncludesSome` | Array of values | Cell array contains ANY value |

---

### Comparison: All Built-in Filter Functions

| Key | Input Type | Case Sensitive | Match Type |
|---|---|---|---|
| `includesString` | `string` | No | Substring |
| `includesStringSensitive` | `string` | Yes | Substring |
| `equalsString` | `string` | No | Exact |
| `equalsStringSensitive` | `string` | Yes | Exact |
| `equals` | `any` | N/A | Strict (`===`) |
| `weakEquals` | `any` | N/A | Loose (`==`) |
| `inNumberRange` | `[number?, number?]` | N/A | Inclusive range |
| `arrIncludes` | `any` | N/A | Single membership |
| `arrIncludesAll` | `any[]` | N/A | All members present |
| `arrIncludesSome` | `any[]` | N/A | Any member present |

---

### `autoRemove` Behavior

Each built-in filter function defines an `autoRemove` condition — a predicate that determines when the filter entry should be automatically removed from `ColumnFiltersState`. This prevents empty or meaningless filter values from remaining active.

| Function | Auto-removes when |
|---|---|
| `includesString` / `includesStringSensitive` | Filter value is falsy or not a string |
| `equalsString` / `equalsStringSensitive` | Filter value is falsy or not a string |
| `equals` / `weakEquals` | Filter value is `undefined` |
| `inNumberRange` | Both bounds are `undefined` or `null` |
| `arrIncludes` | Filter value is falsy |
| `arrIncludesAll` / `arrIncludesSome` | Filter value is empty array or falsy |

[Inference] Auto-removal is handled internally by TanStack Table when `setFilterValue` is called. The filter entry is removed from state rather than retained with an empty value. Behavior should be verified against your specific version.

---

### Using Built-in Functions in Custom Filter Logic

Built-in filter functions can be composed within custom filter functions:

```ts
import { filterFns, FilterFn } from '@tanstack/react-table';

const nameOrEmailFilter: FilterFn<Person> = (row, columnId, value) => {
  return (
    filterFns.includesString(row, 'name', value, () => {}) ||
    filterFns.includesString(row, 'email', value, () => {})
  );
};
```

[Inference] The fourth `addMeta` argument is part of the filter function signature and should be passed even when unused. Omitting it may cause type errors in strict TypeScript configurations.

---

### Practical Pairing: Filter UI to Filter Function

| Filter UI Control | Recommended Filter Function |
|---|---|
| Text input (search) | `includesString` |
| Text input (exact match) | `equalsString` |
| Single dropdown / select | `equals` or `equalsString` |
| Multi-select checkbox | `arrIncludesSome` |
| Tag must-have-all selector | `arrIncludesAll` |
| Min/max number inputs | `inNumberRange` |
| Boolean toggle | `equals` |

---

### Full Example — Multiple Filter Functions in One Table

```tsx
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  flexRender,
  ColumnDef,
  ColumnFiltersState,
} from '@tanstack/react-table';
import { useState } from 'react';

type Product = {
  name: string;
  category: string;
  price: number;
  tags: string[];
  inStock: boolean;
};

const data: Product[] = [
  { name: 'Wireless Mouse', category: 'Electronics', price: 29, tags: ['usb', 'wireless'], inStock: true },
  { name: 'Mechanical Keyboard', category: 'Electronics', price: 89, tags: ['usb', 'rgb'], inStock: false },
  { name: 'Standing Desk', category: 'Furniture', price: 349, tags: ['wood', 'adjustable'], inStock: true },
  { name: 'Monitor Arm', category: 'Furniture', price: 55, tags: ['adjustable', 'steel'], inStock: true },
];

const columns: ColumnDef<Product>[] = [
  { accessorKey: 'name', header: 'Name', filterFn: 'includesString' },
  { accessorKey: 'category', header: 'Category', filterFn: 'equalsString' },
  { accessorKey: 'price', header: 'Price', filterFn: 'inNumberRange' },
  { accessorKey: 'tags', header: 'Tags', filterFn: 'arrIncludesSome' },
  { accessorKey: 'inStock', header: 'In Stock', filterFn: 'equals' },
];

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

  const nameCol = table.getColumn('name');
  const categoryCol = table.getColumn('category');
  const priceCol = table.getColumn('price');
  const tagsCol = table.getColumn('tags');
  const inStockCol = table.getColumn('inStock');

  return (
    <div>
      <input
        placeholder="Search name..."
        value={(nameCol?.getFilterValue() as string) ?? ''}
        onChange={e => nameCol?.setFilterValue(e.target.value || undefined)}
      />
      <select
        value={(categoryCol?.getFilterValue() as string) ?? ''}
        onChange={e => categoryCol?.setFilterValue(e.target.value || undefined)}
      >
        <option value="">All Categories</option>
        <option value="Electronics">Electronics</option>
        <option value="Furniture">Furniture</option>
      </select>
      <input
        type="number"
        placeholder="Min price"
        onChange={e =>
          priceCol?.setFilterValue((old: [number?, number?]) => [
            e.target.value ? Number(e.target.value) : undefined,
            old?.[1],
          ])
        }
      />
      <input
        type="number"
        placeholder="Max price"
        onChange={e =>
          priceCol?.setFilterValue((old: [number?, number?]) => [
            old?.[0],
            e.target.value ? Number(e.target.value) : undefined,
          ])
        }
      />
      <select
        multiple
        onChange={e =>
          tagsCol?.setFilterValue(
            Array.from(e.target.selectedOptions).map(o => o.value) || undefined
          )
        }
      >
        <option value="usb">USB</option>
        <option value="wireless">Wireless</option>
        <option value="rgb">RGB</option>
        <option value="adjustable">Adjustable</option>
      </select>
      <label>
        <input
          type="checkbox"
          onChange={e => inStockCol?.setFilterValue(e.target.checked ? true : undefined)}
        />
        In Stock Only
      </label>

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

**Output:** Each column uses a different built-in filter function matched to its data type and UI control. All active filters compose with AND logic across columns.

---

**Related Topics:**
- Column-Level Filtering — per-column filter state and setup
- Global Filtering — applying a single filter across all columns
- Custom Filter Functions — writing and registering `filterFn` implementations
- Faceted Values — `getFacetedUniqueValues` and `getFacetedMinMaxValues` for deriving filter options from data
- Filter Auto-Remove — customizing `filterFn.autoRemove` in custom functions
- Manual Filtering — server-side filter integration
- Sorting — interaction between `getSortedRowModel` and `getFilteredRowModel`