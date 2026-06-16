## Disabling Sort on Specific Columns

### Overview

TanStack Table's sorting system is enabled globally by default when `getSortedRowModel` is included. However, individual columns can be excluded from sorting on a per-column basis. This is useful when a column contains data that has no meaningful sort order — such as action buttons, avatar images, rich composite cells, or computed display values.

---

### How Column-Level Sort Disabling Works

Each column definition accepts an `enableSorting` property. Setting it to `false` removes that column from sorting participation entirely. The column header will not render any sort toggle UI (when using TanStack's header click handlers), and the column will not appear in the sort state.

**Key Points:**
- `enableSorting: false` is set in the column definition, not in table options
- It affects both UI interaction and programmatic sorting for that column
- Other columns remain sortable unless also disabled
- The global `enableSorting: false` on the table disables all columns; per-column `enableSorting` is more granular

---

### Column Definition Syntax

```ts
const columns: ColumnDef<Person>[] = [
  {
    accessorKey: 'avatar',
    header: 'Avatar',
    enableSorting: false, // This column cannot be sorted
  },
  {
    accessorKey: 'name',
    header: 'Name',
    // enableSorting not set — defaults to true
  },
  {
    accessorKey: 'actions',
    header: 'Actions',
    enableSorting: false, // Action columns typically have no sortable value
    cell: ({ row }) => <ActionMenu row={row} />,
  },
];
```

---

### Interaction with `getSortedRowModel`

Even when `getSortedRowModel` is registered at the table level, columns with `enableSorting: false` are excluded from sorting logic. The sort state for those columns cannot be set programmatically or through user interaction.

```ts
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
  state: {
    sorting,
  },
  onSortingChange: setSorting,
});
```

[Inference] If a sort state entry referencing a disabled column exists in `sorting`, TanStack Table may ignore it silently. Behavior is not guaranteed and may vary across versions.

---

### Checking Sort Eligibility at Runtime

The `column.getCanSort()` method returns `false` for columns where `enableSorting: false` is set. This is the recommended way to conditionally render sort indicators in custom header components.

```tsx
// Inside a custom header render function
const Header = ({ column }: { column: Column<Person> }) => {
  const canSort = column.getCanSort();

  return (
    <th>
      <span>{column.columnDef.header as string}</span>
      {canSort && (
        <button onClick={column.getToggleSortingHandler()}>
          {column.getIsSorted() === 'asc' ? '↑' : column.getIsSorted() === 'desc' ? '↓' : '⇅'}
        </button>
      )}
    </th>
  );
};
```

**Key Points:**
- `column.getCanSort()` reflects the resolved sort eligibility, taking both global and per-column settings into account
- `column.getToggleSortingHandler()` returns `undefined` when `getCanSort()` is `false` — attaching it conditionally avoids no-op click handlers

---

### Interaction with Global `enableSorting`

The table-level `enableSorting` and the column-level `enableSorting` interact as follows:

| Table `enableSorting` | Column `enableSorting` | Result |
|---|---|---|
| `true` (default) | `true` (default) | Column is sortable |
| `true` (default) | `false` | Column is **not** sortable |
| `false` | `true` | Column is **not** sortable |
| `false` | `false` | Column is **not** sortable |

[Inference] There is no override mechanism to make a column sortable when the table-level `enableSorting` is `false`. Column-level `true` does not override a table-level `false`. Behavior should be verified against your specific version.

---

### Practical Use Cases

**Action columns** — Columns containing buttons, menus, or links have no inherent data value to sort on.

**Display-only columns** — Columns that render computed or formatted values derived from multiple fields (e.g., a full address assembled from parts) may produce misleading sort behavior if sorted on the raw accessor value.

**Media columns** — Image, icon, or avatar columns typically hold URLs or render-only values with no meaningful order.

**Checkbox / selection columns** — Selection state columns are typically handled separately from data sorting.

---

### Full Minimal Example

```tsx
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  flexRender,
  ColumnDef,
  SortingState,
} from '@tanstack/react-table';
import { useState } from 'react';

type User = {
  name: string;
  email: string;
  role: string;
};

const data: User[] = [
  { name: 'Alice', email: 'alice@example.com', role: 'Admin' },
  { name: 'Bob', email: 'bob@example.com', role: 'Viewer' },
  { name: 'Carol', email: 'carol@example.com', role: 'Editor' },
];

const columns: ColumnDef<User>[] = [
  {
    accessorKey: 'name',
    header: 'Name',
    // Sortable (default)
  },
  {
    accessorKey: 'email',
    header: 'Email',
    enableSorting: false, // Email column not sortable
  },
  {
    accessorKey: 'role',
    header: 'Role',
    // Sortable (default)
  },
];

export default function App() {
  const [sorting, setSorting] = useState<SortingState>([]);

  const table = useReactTable({
    data,
    columns,
    state: { sorting },
    onSortingChange: setSorting,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
  });

  return (
    <table>
      <thead>
        {table.getHeaderGroups().map(headerGroup => (
          <tr key={headerGroup.id}>
            {headerGroup.headers.map(header => (
              <th
                key={header.id}
                onClick={
                  header.column.getCanSort()
                    ? header.column.getToggleSortingHandler()
                    : undefined
                }
                style={{ cursor: header.column.getCanSort() ? 'pointer' : 'default' }}
              >
                {flexRender(header.column.columnDef.header, header.getContext())}
                {header.column.getIsSorted() === 'asc' && ' ↑'}
                {header.column.getIsSorted() === 'desc' && ' ↓'}
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
  );
}
```

**Output:** The `Name` and `Role` columns are clickable and toggle sort order. The `Email` column has no sort interaction and renders with a default cursor.

---

### Disabling Sort via `columnHelper`

If using the `createColumnHelper` utility, the same `enableSorting` field applies:

```ts
const columnHelper = createColumnHelper<User>();

const columns = [
  columnHelper.accessor('name', {
    header: 'Name',
    // Sortable by default
  }),
  columnHelper.accessor('email', {
    header: 'Email',
    enableSorting: false,
  }),
  columnHelper.display({
    id: 'actions',
    header: 'Actions',
    enableSorting: false,
    cell: ({ row }) => <button>Edit</button>,
  }),
];
```

`columnHelper.display()` columns have no accessor and no inherent sort value — setting `enableSorting: false` on them is best practice even if the default behavior may already exclude them. [Inference] Behavior of display columns without explicit `enableSorting: false` may vary.

---

### Common Mistakes

**Mistake:** Setting `enableSorting: false` on the table options expecting only some columns to be affected.
**Correction:** Table-level `enableSorting: false` disables sorting for all columns. Use per-column `enableSorting: false` instead.

**Mistake:** Attaching `getToggleSortingHandler()` unconditionally on all headers.
**Correction:** Guard with `column.getCanSort()` to avoid attaching a no-op or undefined handler to non-sortable headers.

**Mistake:** Hiding the sort icon via CSS instead of conditionally rendering based on `getCanSort()`.
**Correction:** CSS hiding leaves the click handler active. Use `getCanSort()` to conditionally render both the icon and the handler.

---

**Related Topics:**
- Sorting — Multi-column sorting (`enableMultiSort`)
- Sorting — Custom sort functions (`sortingFn`)
- Sorting — Sort direction cycles and initial sort state
- Sorting — Manual sorting for server-side data
- Column visibility — Hiding columns vs. disabling features
- Column pinning — Interaction with sort state on pinned columns
- `getSortedRowModel` — Internal sort resolution order