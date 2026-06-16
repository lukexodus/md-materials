## Typed Column Definitions in TanStack Table

Column definitions are the structural core of TanStack Table. They describe what data each column accesses, how it renders, and how it behaves. TypeScript types flow from a single generic — the row data type — through every column definition, accessor, cell renderer, and header, giving you full inference across the entire table configuration.

---

### The Row Data Generic

Every TanStack Table instance is anchored to a single row data type. All column definitions, accessors, and cell renderers derive their types from it.

```ts
import { createColumnHelper } from '@tanstack/react-table'

interface Invoice {
  id: number
  client: string
  amount: number
  status: 'paid' | 'pending' | 'overdue'
  issuedAt: string
}

const columnHelper = createColumnHelper<Invoice>()
```

**Key Points**
- `createColumnHelper<T>()` binds the row type `T` to all columns created through it
- The helper is a utility for type inference only — it produces no runtime output beyond the column definition object
- All column definitions for a single table should share the same row type

---

### `createColumnHelper` vs. Direct `ColumnDef` Array

There are two ways to define columns. Both are valid; the tradeoffs are ergonomic.

#### Using `createColumnHelper` (recommended for inference)

```ts
const columns = [
  columnHelper.accessor('client', {
    header: 'Client',
    cell: (info) => info.getValue(),
    // info.getValue(): string  ← inferred from Invoice['client']
  }),
  columnHelper.accessor('amount', {
    header: 'Amount',
    cell: (info) => `$${info.getValue().toFixed(2)}`,
    // info.getValue(): number  ← inferred from Invoice['amount']
  }),
]
```

#### Using `ColumnDef<T>` directly

```ts
import type { ColumnDef } from '@tanstack/react-table'

const columns: ColumnDef<Invoice>[] = [
  {
    accessorKey: 'client',
    header: 'Client',
    cell: (info) => info.getValue(),
    // info.getValue(): unknown  ← less precise without helper
  },
]
```

**Key Points**
- `createColumnHelper` gives narrower types: `getValue()` returns the exact field type
- `ColumnDef<T>` with `accessorKey` gives `getValue()` as `unknown` — you must cast manually
- `ColumnDef<T>` with `accessorFn` restores precision if the function is typed
- For large tables, `createColumnHelper` significantly reduces annotation noise [Inference]

---

### Accessor Column Types

#### `accessor` with a key string

```ts
columnHelper.accessor('status', {
  header: 'Status',
  cell: (info) => {
    const status = info.getValue()
    // status: "paid" | "pending" | "overdue"
    return <StatusBadge value={status} />
  },
})
```

The key must be a top-level key of the row type. TypeScript raises an error if the key does not exist on `Invoice`.

#### `accessor` with an accessor function

Use an accessor function when the column value is derived from multiple fields or a nested property.

```ts
columnHelper.accessor((row) => `${row.client} — ${row.status}`, {
  id: 'clientStatus',  // required when using an accessor function
  header: 'Client / Status',
  cell: (info) => {
    const value = info.getValue()
    // value: string  ← inferred from the accessor function's return type
    return <span>{value}</span>
  },
})
```

**Key Points**
- When using an accessor function, `id` is required — TanStack Table cannot derive a stable key from a function
- The accessor function receives the full row as `Invoice`, giving access to all fields
- The return type of the accessor function becomes the type of `getValue()` in the cell renderer

---

### Display and Group Columns

Not all columns map to a data field. Display columns render arbitrary UI; group columns collect other columns under a shared header.

#### Display column

```ts
columnHelper.display({
  id: 'actions',
  header: 'Actions',
  cell: (info) => {
    const row = info.row.original
    // row: Invoice  ← full row type available
    return (
      <button onClick={() => handleDelete(row.id)}>
        Delete
      </button>
    )
  },
})
```

#### Group column

```ts
columnHelper.group({
  id: 'details',
  header: 'Details',
  columns: [
    columnHelper.accessor('amount', { header: 'Amount' }),
    columnHelper.accessor('issuedAt', { header: 'Issued' }),
  ],
})
```

**Key Points**
- Display columns have no `accessorKey` or `accessorFn` — `getValue()` is not available in their cell renderers
- `info.row.original` is always typed as the full row type regardless of column type
- Group columns do not render cells — only headers and sub-columns

---

### Typing Cell and Header Renderers

Cell and header renderers receive context objects with precise types.

```ts
columnHelper.accessor('amount', {
  header: (headerContext) => {
    // headerContext.column.id: string
    // headerContext.table: Table<Invoice>
    return <SortableHeader context={headerContext}>Amount</SortableHeader>
  },
  cell: (cellContext) => {
    // cellContext.getValue():      number
    // cellContext.row.original:    Invoice
    // cellContext.row.index:       number
    // cellContext.column.id:       string
    // cellContext.table:           Table<Invoice>
    return <AmountCell value={cellContext.getValue()} />
  },
  footer: (footerContext) => {
    const total = footerContext.table
      .getFilteredRowModel()
      .rows
      .reduce((sum, row) => sum + row.getValue<number>('amount'), 0)
    return `Total: $${total.toFixed(2)}`
  },
})
```

**Key Points**
- `cellContext.getValue()` returns the accessor's inferred type when using `createColumnHelper`
- `cellContext.row.original` always gives access to the full `Invoice` object
- `row.getValue<T>(columnId)` requires a manual generic because column IDs are strings at runtime — the type is not automatically inferred [Important]

---

### Nested and Deep Property Access

TanStack Table's key-based accessor only supports top-level keys. For nested data, use an accessor function.

```ts
interface Order {
  id: number
  customer: {
    name: string
    email: string
  }
  total: number
}

const columnHelper = createColumnHelper<Order>()

// ❌ Does not work — nested keys are not supported by accessorKey
columnHelper.accessor('customer.name', { header: 'Name' })
// This compiles in some configurations but behavior may vary [Unverified]

// ✅ Accessor function — explicit and type-safe
columnHelper.accessor((row) => row.customer.name, {
  id: 'customerName',
  header: 'Customer Name',
  cell: (info) => info.getValue(),
  // info.getValue(): string
})
```

**Key Points**
- Dot-notation string accessors (`'customer.name'`) may appear to work but are not officially typed as deep key accessors — using an accessor function is safer and more explicit
- Accessor functions give you full TypeScript narrowing on the row object

---

### Column Meta Typing

TanStack Table provides a `ColumnMeta` interface that can be module-augmented to add custom typed metadata to column definitions.

```ts
// types/table.d.ts
import '@tanstack/react-table'

declare module '@tanstack/react-table' {
  interface ColumnMeta<TData extends RowData, TValue> {
    align?: 'left' | 'center' | 'right'
    tooltip?: string
    formatAs?: 'currency' | 'date' | 'percent'
  }
}
```

```ts
columnHelper.accessor('amount', {
  header: 'Amount',
  meta: {
    align: 'right',
    formatAs: 'currency',
  },
  cell: (info) => {
    const meta = info.column.columnDef.meta
    // meta: { align?: ...; tooltip?: ...; formatAs?: ... }
    return formatValue(info.getValue(), meta?.formatAs)
  },
})
```

**Key Points**
- `ColumnMeta` is augmented globally — the same meta shape applies to every column in the project
- `TData` and `TValue` are available as generics in the augmentation if you need per-column meta variance [Inference — complex augmentation patterns may require testing against your TypeScript version]
- Meta is not used by TanStack Table itself — it is a passthrough for your own rendering logic

---

### Typing Column Visibility, Ordering, and Pinning State

Column state objects use column IDs as keys. Typing these requires knowing your column IDs, which are strings at runtime.

```ts
import type { VisibilityState, ColumnOrderState } from '@tanstack/react-table'

const [columnVisibility, setColumnVisibility] = useState<VisibilityState>({
  issuedAt: false,  // hidden by default
})

const [columnOrder, setColumnOrder] = useState<ColumnOrderState>([
  'client',
  'amount',
  'status',
  'issuedAt',
  'actions',
])
```

**Key Points**
- `VisibilityState` is `Record<string, boolean>` — column IDs are not validated against the actual column list at the type level
- `ColumnOrderState` is `string[]` — same limitation applies
- Typos in column IDs here produce no TypeScript error, only silent runtime misbehavior [Important — be precise with column ID strings]

---

### Sorting and Filtering Column Type Integration

Sorting and filtering configurations reference columns by ID and optionally define custom functions.

```ts
import type { SortingState } from '@tanstack/react-table'

const [sorting, setSorting] = useState<SortingState>([
  { id: 'amount', desc: true },
])

columnHelper.accessor('amount', {
  header: 'Amount',
  sortingFn: 'basic',           // built-in
  filterFn: (row, columnId, filterValue) => {
    // row.original: Invoice
    // filterValue: unknown  ← type must be asserted
    const amount = row.getValue<number>(columnId)
    return amount >= (filterValue as number)
  },
})
```

**Key Points**
- `SortingState` is `Array<{ id: string; desc: boolean }>` — IDs are not checked against column definitions
- `filterFn` receives `filterValue` as `unknown` — you are responsible for narrowing or asserting the type
- Built-in sort and filter function names (`'basic'`, `'alphanumeric'`, `'datetime'`, etc.) are string literals accepted by the `sortingFn` and `filterFn` options

---

### Reusable Typed Column Factories

For tables that share column patterns, typed column factories keep definitions DRY.

```ts
function actionsColumn<T>(
  onDelete: (row: T) => void,
  onEdit: (row: T) => void
): ColumnDef<T> {
  return {
    id: 'actions',
    header: 'Actions',
    cell: ({ row }) => (
      <div>
        <button onClick={() => onEdit(row.original)}>Edit</button>
        <button onClick={() => onDelete(row.original)}>Delete</button>
      </div>
    ),
  }
}

// Used across different row types
const invoiceColumns = [
  ...columnHelper.accessor('client', { header: 'Client' }),
  actionsColumn<Invoice>(handleDelete, handleEdit),
]
```

**Key Points**
- Generic column factories allow sharing patterns like action columns or selection columns across tables
- `ColumnDef<T>` is the correct return type for a single column definition
- `ColumnDef<T>[]` for arrays of definitions

---

### Full Column Definition Example

```ts
const columns = [
  columnHelper.display({
    id: 'select',
    header: ({ table }) => (
      <input
        type="checkbox"
        checked={table.getIsAllRowsSelected()}
        onChange={table.getToggleAllRowsSelectedHandler()}
      />
    ),
    cell: ({ row }) => (
      <input
        type="checkbox"
        checked={row.getIsSelected()}
        onChange={row.getToggleSelectedHandler()}
      />
    ),
  }),

  columnHelper.accessor('client', {
    header: 'Client',
    cell: (info) => <strong>{info.getValue()}</strong>,
    meta: { align: 'left' },
  }),

  columnHelper.accessor('amount', {
    header: 'Amount',
    cell: (info) => `$${info.getValue().toFixed(2)}`,
    meta: { align: 'right', formatAs: 'currency' },
    sortingFn: 'basic',
  }),

  columnHelper.accessor('status', {
    header: 'Status',
    cell: (info) => <StatusBadge status={info.getValue()} />,
    filterFn: 'equals',
  }),

  columnHelper.accessor('issuedAt', {
    header: 'Issued',
    cell: (info) => new Date(info.getValue()).toLocaleDateString(),
    sortingFn: 'datetime',
  }),

  columnHelper.display({
    id: 'actions',
    header: 'Actions',
    cell: ({ row }) => <RowActions invoice={row.original} />,
  }),
]
```

---

**Related Topics**
- Typing `useReactTable` — `getCoreRowModel`, `getSortedRowModel`, and full table state
- Row selection state typing and `RowSelectionState`
- Custom filter functions with typed `filterValue`
- Column sizing and resizing state types
- Virtualized rows with TanStack Virtual — typing `virtualizer` alongside table state
- Aggregation and grouping column types in `getGroupedRowModel`
- Sharing column definitions across multiple table instances with generics