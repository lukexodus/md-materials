## Manual Server-Side Filtering

### Overview

By default, TanStack Table filters rows client-side using `getFilteredRowModel`. When data is too large to load entirely into the browser, or when filtering logic must run on the server — full-text search indexes, database queries, vector similarity, access-controlled data — the table delegates filtering responsibility to the server. TanStack Table tracks filter state and exposes it to the application, but does not apply any row filtering itself. The application is responsible for using that state to fetch pre-filtered data and supplying it as `data`.

---

### How Manual Filtering Works

With `manualFiltering: true`:

- `getFilteredRowModel` is bypassed — even if registered, it does not filter rows
- `columnFilters` and `globalFilter` state are still tracked and updated normally
- `onColumnFiltersChange` and `onGlobalFilterChange` still fire on user interaction
- The application observes filter state changes and re-fetches data accordingly
- The `data` prop always reflects the current server response — already filtered

```
User types in filter input
  → filter state updates (columnFilters / globalFilter)
  → onFilterChange fires
  → application re-fetches with filter params
  → server returns filtered rows
  → data prop updates
  → table renders filtered rows
```

---

### Minimal Configuration

```ts
const table = useReactTable({
  data,           // Pre-filtered data from server
  columns,
  state: {
    columnFilters,
    globalFilter,
  },
  onColumnFiltersChange: setColumnFilters,
  onGlobalFilterChange: setGlobalFilter,
  manualFiltering: true,
  getCoreRowModel: getCoreRowModel(),
  // getFilteredRowModel is omitted — not needed for manual filtering
});
```

**Key Points:**
- `getFilteredRowModel` can be omitted entirely when `manualFiltering: true`
- [Inference] Including `getFilteredRowModel` alongside `manualFiltering: true` may have no harmful effect, but it performs unnecessary work. Behavior may vary across versions.
- All filter state APIs (`column.getFilterValue()`, `column.setFilterValue()`, `table.resetColumnFilters()`) remain functional — they operate on state only, not on rows

---

### Fetching on Filter State Change

The application must observe filter state and trigger a fetch when it changes. The standard pattern uses `useEffect` with the filter state as a dependency:

```ts
const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);
const [globalFilter, setGlobalFilter] = useState('');
const [data, setData] = useState<Person[]>([]);
const [isLoading, setIsLoading] = useState(false);

useEffect(() => {
  let cancelled = false;

  const fetchData = async () => {
    setIsLoading(true);

    const params = new URLSearchParams();

    if (globalFilter) {
      params.set('search', globalFilter);
    }

    for (const filter of columnFilters) {
      params.set(`filter_${filter.id}`, JSON.stringify(filter.value));
    }

    const response = await fetch(`/api/people?${params.toString()}`);
    const json = await response.json();

    if (!cancelled) {
      setData(json.rows);
      setIsLoading(false);
    }
  };

  fetchData();

  return () => { cancelled = true; };
}, [columnFilters, globalFilter]);
```

**Key Points:**
- The `cancelled` flag prevents stale responses from overwriting newer data when multiple requests are in-flight — a common race condition when filters change quickly
- Filter state is serialized into query parameters; the exact serialization format depends on the server API contract
- [Inference] `JSON.stringify` is a simple serialization strategy for structured filter values like `[min, max]` ranges or arrays; the server must deserialize accordingly

---

### Debouncing with Server-Side Filtering

Without debouncing, every keystroke sends a new API request. Debouncing is more critical for server-side filtering than for client-side filtering:

```ts
const [inputValue, setInputValue] = useState('');
const [globalFilter, setGlobalFilter] = useState('');

// Debounce the committed filter value
useEffect(() => {
  const timeout = setTimeout(() => setGlobalFilter(inputValue), 500);
  return () => clearTimeout(timeout);
}, [inputValue]);

// Fetch fires only when globalFilter (debounced) changes
useEffect(() => {
  fetchData({ search: globalFilter });
}, [globalFilter]);

const table = useReactTable({
  data,
  columns,
  state: { globalFilter },
  onGlobalFilterChange: setInputValue,  // Drives the input immediately
  manualFiltering: true,
  getCoreRowModel: getCoreRowModel(),
});
```

**Key Points:**
- `onGlobalFilterChange` updates `inputValue` immediately for responsive input display
- A separate debounced `globalFilter` drives the actual fetch
- 400–500ms is a reasonable delay for server-side filtering — longer than the 200–300ms typical for client-side
- [Inference] For high-traffic applications, even debounced requests may be excessive; request cancellation via `AbortController` is an additional mitigation

---

### Request Cancellation with `AbortController`

For fast typers or quick filter changes, debouncing alone may not prevent overlapping requests. `AbortController` cancels in-flight requests when a new one starts:

```ts
useEffect(() => {
  const controller = new AbortController();

  const fetchData = async () => {
    setIsLoading(true);
    try {
      const params = new URLSearchParams({ search: globalFilter });
      const response = await fetch(`/api/people?${params}`, {
        signal: controller.signal,
      });
      const json = await response.json();
      setData(json.rows);
    } catch (err) {
      if ((err as Error).name === 'AbortError') {
        // Request was cancelled — do not update state
        return;
      }
      console.error('Fetch error:', err);
    } finally {
      setIsLoading(false);
    }
  };

  fetchData();

  return () => controller.abort();
}, [globalFilter, columnFilters]);
```

**Key Points:**
- `controller.abort()` is called in the cleanup function — React calls cleanup when the effect re-runs, cancelling the previous request before starting a new one
- `AbortError` must be caught and silently ignored — it is not an application error
- [Inference] `AbortController` is supported in all modern browsers and Node.js 15+. Behavior in older environments may require a polyfill.

---

### Serializing Filter State for API Requests

`ColumnFiltersState` is an array of `{ id, value }` objects. Converting this to URL parameters or a request body requires a consistent serialization strategy:

#### Flat query parameters

```ts
// Simple string filters
// columnFilters = [{ id: 'name', value: 'alice' }, { id: 'role', value: 'admin' }]
params.set('filter[name]', 'alice');
params.set('filter[role]', 'admin');
```

#### JSON-encoded values (for structured filters)

```ts
// Range filter: { id: 'salary', value: [50000, 100000] }
params.set('filter[salary]', JSON.stringify([50000, 100000]));
```

#### Request body (POST)

```ts
const response = await fetch('/api/people', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    filters: columnFilters,
    search: globalFilter,
  }),
  signal: controller.signal,
});
```

[Inference] There is no universally correct serialization format. The format must match the server's expected input. Using a structured body via POST avoids URL length limits for complex filter combinations.

---

### Combining Manual Filtering with Manual Pagination

Server-side filtering almost always pairs with server-side pagination. When filters change, the page index must reset to avoid requesting a page that no longer exists in the filtered result set:

```ts
const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 20 });
const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);
const [rowCount, setRowCount] = useState(0);

// Reset to page 0 when filters change
const handleColumnFiltersChange: OnChangeFn<ColumnFiltersState> = (updater) => {
  setColumnFilters(updater);
  setPagination(prev => ({ ...prev, pageIndex: 0 }));
};

const table = useReactTable({
  data,
  columns,
  rowCount,
  state: { columnFilters, pagination },
  onColumnFiltersChange: handleColumnFiltersChange,
  onPaginationChange: setPagination,
  manualFiltering: true,
  manualPagination: true,
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
});
```

**Key Points:**
- Resetting `pageIndex` to `0` on filter change prevents empty pages
- `rowCount` must be provided for TanStack Table to compute page count correctly — this value comes from the server response (total matching rows, not just the current page)
- [Inference] If both `manualFiltering` and `manualPagination` are active, the fetch must include both filter params and pagination params in the same request

---

### Combining Manual Filtering with Manual Sorting

Similarly, server-side sorting state must be included in the same fetch:

```ts
const [sorting, setSorting] = useState<SortingState>([]);
const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);

useEffect(() => {
  const params = new URLSearchParams();

  for (const filter of columnFilters) {
    params.set(`filter_${filter.id}`, JSON.stringify(filter.value));
  }

  for (const sort of sorting) {
    params.append('sort', `${sort.id}:${sort.desc ? 'desc' : 'asc'}`);
  }

  fetch(`/api/people?${params}`).then(r => r.json()).then(json => setData(json.rows));
}, [columnFilters, sorting]);

const table = useReactTable({
  data,
  columns,
  state: { columnFilters, sorting },
  onColumnFiltersChange: setColumnFilters,
  onSortingChange: setSorting,
  manualFiltering: true,
  manualSorting: true,
  getCoreRowModel: getCoreRowModel(),
});
```

---

### Loading and Empty States

Server-side filtering introduces asynchronous latency. The UI should reflect pending and empty states clearly:

```tsx
<div>
  <DebouncedInput
    value={globalFilter}
    onChange={setGlobalFilter}
    placeholder="Search..."
  />

  {isLoading ? (
    <p>Loading...</p>
  ) : table.getRowModel().rows.length === 0 ? (
    <p>No results found.</p>
  ) : (
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
  )}
</div>
```

---

### Integration with Data-Fetching Libraries

Manual filtering integrates naturally with query libraries that handle caching, deduplication, and loading state:

#### TanStack Query (`@tanstack/react-query`)

```ts
import { useQuery } from '@tanstack/react-query';

const { data, isFetching } = useQuery({
  queryKey: ['people', columnFilters, globalFilter, pagination],
  queryFn: () =>
    fetch('/api/people', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ columnFilters, globalFilter, pagination }),
    }).then(r => r.json()),
  placeholderData: keepPreviousData, // Show previous data while fetching
});

const table = useReactTable({
  data: data?.rows ?? [],
  columns,
  rowCount: data?.totalCount ?? 0,
  state: { columnFilters, globalFilter, pagination },
  onColumnFiltersChange: setColumnFilters,
  onGlobalFilterChange: setGlobalFilter,
  onPaginationChange: setPagination,
  manualFiltering: true,
  manualPagination: true,
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
});
```

**Key Points:**
- `queryKey` includes all filter and pagination state — changes to any value trigger a re-fetch
- `keepPreviousData` (or `placeholderData: keepPreviousData` in v5) prevents the table from flashing empty while new data loads
- TanStack Query handles request deduplication and caching automatically — [Inference] rapidly changing filter values may still produce multiple in-flight requests depending on cache configuration

---

### Full Minimal Example

```tsx
import {
  useReactTable,
  getCoreRowModel,
  flexRender,
  ColumnDef,
  ColumnFiltersState,
} from '@tanstack/react-table';
import { useState, useEffect, useRef } from 'react';

type User = { id: number; name: string; role: string };

const columns: ColumnDef<User>[] = [
  { accessorKey: 'id', header: 'ID', enableColumnFilter: false },
  { accessorKey: 'name', header: 'Name' },
  { accessorKey: 'role', header: 'Role' },
];

// Simulated server fetch
async function fetchUsers(
  search: string,
  filters: ColumnFiltersState,
  signal: AbortSignal
): Promise<User[]> {
  await new Promise(res => setTimeout(res, 300)); // Simulate latency
  if (signal.aborted) return [];

  const allUsers: User[] = [
    { id: 1, name: 'Alice', role: 'Admin' },
    { id: 2, name: 'Bob', role: 'Viewer' },
    { id: 3, name: 'Carol', role: 'Editor' },
    { id: 4, name: 'Dave', role: 'Admin' },
  ];

  return allUsers.filter(u => {
    if (search && !u.name.toLowerCase().includes(search.toLowerCase())) return false;
    for (const f of filters) {
      if (f.id === 'role' && f.value && u.role !== f.value) return false;
    }
    return true;
  });
}

export default function App() {
  const [inputValue, setInputValue] = useState('');
  const [globalFilter, setGlobalFilter] = useState('');
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);
  const [data, setData] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  // Debounce input → globalFilter
  useEffect(() => {
    const t = setTimeout(() => setGlobalFilter(inputValue), 400);
    return () => clearTimeout(t);
  }, [inputValue]);

  // Fetch when committed filter state changes
  useEffect(() => {
    const controller = new AbortController();
    setIsLoading(true);

    fetchUsers(globalFilter, columnFilters, controller.signal).then(rows => {
      if (!controller.signal.aborted) {
        setData(rows);
        setIsLoading(false);
      }
    });

    return () => controller.abort();
  }, [globalFilter, columnFilters]);

  const table = useReactTable({
    data,
    columns,
    state: { globalFilter, columnFilters },
    onGlobalFilterChange: setInputValue,
    onColumnFiltersChange: setColumnFilters,
    manualFiltering: true,
    getCoreRowModel: getCoreRowModel(),
  });

  const roleCol = table.getColumn('role');

  return (
    <div>
      <input
        value={inputValue}
        onChange={e => setInputValue(e.target.value)}
        placeholder="Search by name..."
      />
      <select
        value={(roleCol?.getFilterValue() as string) ?? ''}
        onChange={e => roleCol?.setFilterValue(e.target.value || undefined)}
      >
        <option value="">All Roles</option>
        <option value="Admin">Admin</option>
        <option value="Editor">Editor</option>
        <option value="Viewer">Viewer</option>
      </select>
      <button onClick={() => { table.resetColumnFilters(); setInputValue(''); }}>
        Clear
      </button>

      {isLoading ? (
        <p>Loading...</p>
      ) : (
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
            {table.getRowModel().rows.length === 0 ? (
              <tr><td colSpan={columns.length}>No results.</td></tr>
            ) : (
              table.getRowModel().rows.map(row => (
                <tr key={row.id}>
                  {row.getVisibleCells().map(cell => (
                    <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}
```

**Output:** The search input is debounced at 400ms before triggering a fetch. The role dropdown updates immediately. In-flight requests are cancelled when filter state changes. Loading state is shown during fetch latency.

---

### Common Mistakes

**Mistake:** Including `getFilteredRowModel` without `manualFiltering: true` and expecting server data to pass through unfiltered.
**Correction:** Without `manualFiltering: true`, `getFilteredRowModel` applies client-side filtering on top of the server response — rows that do not match the client-side filter are hidden even if the server returned them. Set `manualFiltering: true` to bypass client-side evaluation entirely.

**Mistake:** Not resetting `pageIndex` when filter state changes in a combined filter + pagination setup.
**Correction:** After a filter change the total row count changes, making the current page potentially invalid. Always reset `pageIndex` to `0` when `columnFilters` or `globalFilter` changes.

**Mistake:** Omitting request cancellation and relying only on debounce.
**Correction:** Debounce reduces request frequency but does not prevent race conditions. A slow response to an earlier query may resolve after a faster response to a later query, overwriting current data with stale data. Use `AbortController` or the equivalent in your fetch library.

**Mistake:** Serializing filter state differently between the client and server, causing mismatched or ignored filters.
**Correction:** Establish a fixed serialization contract and validate it on both ends. Structured filter values like `[min, max]` or `string[]` require agreed-upon encoding.

---

**Related Topics:**
- Debounced Filter Input Pattern — debounce implementation for reducing fetch frequency
- Manual Pagination — server-side pagination paired with server-side filtering
- Manual Sorting — server-side sort state serialization
- TanStack Query Integration — `useQuery` with filter state as query keys
- `AbortController` — request cancellation for concurrent filter changes
- Column-Level Filtering — filter state shape and `ColumnFiltersState` structure
- Global Filtering — `globalFilter` state in manual filtering context
- Loading and Empty States — UI patterns for async data transitions