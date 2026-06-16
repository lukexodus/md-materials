## Debounced Filter Input Pattern

### Overview

TanStack Table applies filter logic synchronously on every state change. When filter state is driven directly by a text input's `onChange` event, every keystroke triggers a full re-filter of the row model. For small datasets this is imperceptible, but for large datasets or expensive custom filter functions it produces visible lag. Debouncing delays the propagation of the input value to filter state until the user pauses typing, reducing the number of filter evaluations without changing the visible behavior.

TanStack Table does not include debounce utilities. Debouncing must be implemented externally and sits between the input element and the filter state setter.

---

### The Core Problem

```tsx
// Without debounce — every keystroke updates filter state and re-filters rows
<input
  value={globalFilter}
  onChange={e => setGlobalFilter(e.target.value)}
/>
```

Each character typed calls `setGlobalFilter`, which updates `globalFilter` state, which triggers `getFilteredRowModel` to re-evaluate every row against the new filter value. For 10,000 rows with a custom filter function, this runs 10,000 evaluations per keystroke.

---

### Debounce vs Throttle

Both limit how frequently a function fires, but differ in when the call occurs:

| Strategy | Fires | Best for |
|---|---|---|
| **Debounce** | After the user stops for N ms | Text search — wait for pause in typing |
| **Throttle** | At most once every N ms | Scroll/resize — limit rate, not defer |

For filter inputs, debounce is the correct strategy — the goal is to wait until the user finishes a thought before filtering, not to cap the rate of evaluation while they type.

---

### Pattern 1 — Local State + `useEffect` Debounce

The standard pattern maintains two state values: one for the raw input display value (updates immediately) and one for the committed filter value (updates after delay). The input renders the local value for responsive typing feel, while the filter state receives the debounced value.

```tsx
import { useState, useEffect } from 'react';

function DebouncedInput({
  value: externalValue,
  onChange,
  debounceMs = 300,
  ...inputProps
}: {
  value: string;
  onChange: (value: string) => void;
  debounceMs?: number;
} & Omit<React.InputHTMLAttributes<HTMLInputElement>, 'onChange'>) {
  const [localValue, setLocalValue] = useState(externalValue);

  // Sync local state when external value changes (e.g., filter reset)
  useEffect(() => {
    setLocalValue(externalValue);
  }, [externalValue]);

  // Debounce: propagate to parent after delay
  useEffect(() => {
    const timeout = setTimeout(() => {
      onChange(localValue);
    }, debounceMs);

    return () => clearTimeout(timeout);
  }, [localValue, debounceMs]);

  return (
    <input
      {...inputProps}
      value={localValue}
      onChange={e => setLocalValue(e.target.value)}
    />
  );
}
```

**Key Points:**
- The cleanup function `() => clearTimeout(timeout)` cancels the pending timer whenever `localValue` changes before the delay expires — only the final value after the pause propagates
- The sync `useEffect` on `externalValue` ensures the input reflects programmatic resets (e.g., `table.resetGlobalFilter()`) without requiring the user to clear the input manually
- `debounceMs` is configurable per instance — shorter values feel more responsive, longer values reduce evaluation frequency

---

### Usage with Global Filter

```tsx
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
      <DebouncedInput
        value={globalFilter}
        onChange={setGlobalFilter}
        debounceMs={300}
        placeholder="Search all columns..."
      />
      {/* table rendering */}
    </div>
  );
}
```

**Output:** The input updates immediately on each keystroke. The `globalFilter` state — and therefore the row model re-evaluation — updates only after the user stops typing for 300ms.

---

### Usage with Column Filter

The same component works for column-level filters. The `onChange` callback calls `column.setFilterValue`:

```tsx
<DebouncedInput
  value={(column.getFilterValue() as string) ?? ''}
  onChange={value => column.setFilterValue(value || undefined)}
  debounceMs={300}
  placeholder={`Filter ${column.id}...`}
/>
```

**Key Points:**
- Passing `value || undefined` ensures an empty input clears the filter entry from `ColumnFiltersState` rather than setting it to an empty string
- Each column filter input debounces independently — typing in one column does not reset the debounce timer of another

---

### Pattern 2 — Custom Hook

Extracting the debounce logic into a reusable hook decouples it from the input component and makes it composable with any state setter:

```tsx
import { useState, useEffect } from 'react';

function useDebounce<T>(value: T, delayMs: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timeout = setTimeout(() => setDebouncedValue(value), delayMs);
    return () => clearTimeout(timeout);
  }, [value, delayMs]);

  return debouncedValue;
}
```

```tsx
export default function App() {
  const [inputValue, setInputValue] = useState('');
  const debouncedFilter = useDebounce(inputValue, 300);

  const table = useReactTable({
    data,
    columns,
    state: { globalFilter: debouncedFilter },
    onGlobalFilterChange: setInputValue,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
  });

  return (
    <div>
      <input
        value={inputValue}
        onChange={e => setInputValue(e.target.value)}
        placeholder="Search..."
      />
      {/* table rendering */}
    </div>
  );
}
```

**Key Points:**
- `inputValue` drives the visible input — updates on every keystroke
- `debouncedFilter` is the delayed value passed to `state.globalFilter` — updates after the pause
- [Inference] Because `debouncedFilter` and `inputValue` differ during the debounce window, the displayed row count may lag behind what the user typed — this is expected behavior

---

### Pattern 3 — External Library (`use-debounce`)

The `use-debounce` package provides stable, well-tested debounce and throttle hooks:

```bash
npm install use-debounce
```

```tsx
import { useDebounce } from 'use-debounce';

export default function App() {
  const [inputValue, setInputValue] = useState('');
  const [debouncedFilter] = useDebounce(inputValue, 300);

  const table = useReactTable({
    data,
    columns,
    state: { globalFilter: debouncedFilter },
    onGlobalFilterChange: setInputValue,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
  });

  return (
    <input
      value={inputValue}
      onChange={e => setInputValue(e.target.value)}
      placeholder="Search..."
    />
  );
}
```

[Inference] `use-debounce` handles edge cases around stale closures and React Strict Mode double-invocation that a naive `useEffect` + `setTimeout` implementation may not. Whether these edge cases affect a given application depends on React version and usage patterns.

---

### Choosing a Debounce Delay

The delay value is a tradeoff between responsiveness and evaluation frequency:

| Delay | Character | Use case |
|---|---|---|
| 100–150ms | Very responsive | Small datasets, cheap filter functions |
| 200–300ms | Balanced | Most use cases — matches average typing pause |
| 400–500ms | Conservative | Large datasets, expensive custom filter functions |
| 500ms+ | Slow | Server-side filtering — reduces API call frequency |

[Inference] 300ms is the most commonly cited default and aligns with typical inter-keystroke pause duration for average typing speed. The optimal value depends on dataset size, filter function cost, and user expectations. These are guidelines, not guarantees.

---

### Debouncing for Server-Side Filtering

When `manualFiltering: true` is set and the application re-fetches data on filter change, debouncing is critical to avoid excessive API calls:

```tsx
const [inputValue, setInputValue] = useState('');
const [debouncedFilter] = useDebounce(inputValue, 500);

// Re-fetch when debounced value changes
useEffect(() => {
  fetchData({ filter: debouncedFilter });
}, [debouncedFilter]);

const table = useReactTable({
  data,      // Data from server, already filtered
  columns,
  state: { globalFilter: debouncedFilter },
  onGlobalFilterChange: setInputValue,
  manualFiltering: true,
  getCoreRowModel: getCoreRowModel(),
});
```

**Key Points:**
- A longer delay (400–500ms) is appropriate for server-side filtering to reduce API call frequency
- The `useEffect` dependency on `debouncedFilter` ensures the fetch fires only after the debounce window closes
- [Inference] Concurrent React rendering or `useTransition` may interact with debounce timing in non-obvious ways. Behavior may vary across React versions.

---

### Combining Debounce with Loading State

For server-side filtering, showing a loading indicator during the debounce window improves perceived responsiveness:

```tsx
const [inputValue, setInputValue] = useState('');
const [debouncedFilter] = useDebounce(inputValue, 400);
const isFiltering = inputValue !== debouncedFilter;

return (
  <div>
    <input
      value={inputValue}
      onChange={e => setInputValue(e.target.value)}
      placeholder="Search..."
    />
    {isFiltering && <span>Searching...</span>}
  </div>
);
```

`inputValue !== debouncedFilter` is `true` while the user is typing and the debounce timer has not yet fired — this window is the natural place to show a spinner or pending indicator.

---

### Resetting Debounced Input Programmatically

When filters are cleared externally (e.g., a "Clear filters" button calls `table.resetGlobalFilter()`), the debounced input must also reset its local display value. The sync `useEffect` on `externalValue` in the `DebouncedInput` component handles this:

```tsx
// Parent resets filter state
const handleClearFilters = () => {
  table.resetGlobalFilter();
  // DebouncedInput's useEffect([externalValue]) syncs localValue to ''
};

<button onClick={handleClearFilters}>Clear</button>
<DebouncedInput
  value={globalFilter}   // Now '' after reset
  onChange={setGlobalFilter}
  debounceMs={300}
/>
```

Without the sync effect, the input would display stale text after a programmatic reset.

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
import { useState, useEffect } from 'react';

type Person = { name: string; role: string; email: string };

const data: Person[] = [
  { name: 'Alice', role: 'Admin', email: 'alice@example.com' },
  { name: 'Bob', role: 'Viewer', email: 'bob@example.com' },
  { name: 'Carol', role: 'Editor', email: 'carol@example.com' },
  { name: 'Dave', role: 'Admin', email: 'dave@example.com' },
];

const columns: ColumnDef<Person>[] = [
  { accessorKey: 'name', header: 'Name' },
  { accessorKey: 'role', header: 'Role' },
  { accessorKey: 'email', header: 'Email' },
];

function DebouncedInput({
  value: externalValue,
  onChange,
  debounceMs = 300,
  ...props
}: {
  value: string;
  onChange: (v: string) => void;
  debounceMs?: number;
} & Omit<React.InputHTMLAttributes<HTMLInputElement>, 'onChange'>) {
  const [localValue, setLocalValue] = useState(externalValue);

  useEffect(() => { setLocalValue(externalValue); }, [externalValue]);

  useEffect(() => {
    const t = setTimeout(() => onChange(localValue), debounceMs);
    return () => clearTimeout(t);
  }, [localValue, debounceMs]);

  return (
    <input {...props} value={localValue} onChange={e => setLocalValue(e.target.value)} />
  );
}

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
      <DebouncedInput
        value={globalFilter}
        onChange={setGlobalFilter}
        debounceMs={300}
        placeholder="Search..."
      />
      <button onClick={() => table.resetGlobalFilter()}>Clear</button>
      <p>{table.getFilteredRowCount()} of {data.length} rows</p>
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
    </div>
  );
}
```

**Output:** Typing updates the input immediately. The row model re-evaluates only after a 300ms pause. Clicking Clear resets both the filter state and the input display value.

---

### Common Mistakes

**Mistake:** Debouncing `setGlobalFilter` directly with `useCallback` + a debounce wrapper and passing it to `onGlobalFilterChange`.
**Correction:** This debounces the state setter but leaves the input with no local value to display between keystrokes — the input will feel unresponsive or lag. Keep local input state separate from filter state.

**Mistake:** Omitting the cleanup `clearTimeout` in the `useEffect`.
**Correction:** Without cleanup, every keystroke schedules a new timer but the previous timers are not cancelled — all timers fire in sequence, causing multiple filter evaluations and potential stale state updates.

**Mistake:** Using the same state value for both the input display and the debounced filter, then debouncing the setter.
**Correction:** Two separate state values are required — one for immediate input display, one for committed filter state. Mixing them causes either a laggy input or no debounce effect.

**Mistake:** Setting a very short debounce delay (e.g., 50ms) expecting it to meaningfully reduce evaluations.
**Correction:** At 50ms, most keystrokes will still fire a filter evaluation since average keystroke intervals for typical typing speeds are 80–150ms. [Inference] A minimum of 150–200ms is generally needed for debounce to have a measurable effect. Optimal values depend on user typing speed and are not guaranteed.

---

**Related Topics:**
- Global Filtering — `globalFilter` state setup and `onGlobalFilterChange`
- Column-Level Filtering — per-column `setFilterValue` and filter input patterns
- Manual Filtering — server-side filtering and API call reduction strategies
- Custom Filter Functions — filter function cost and performance considerations
- Faceted Values — deriving filter option lists without re-filtering on every keystroke
- Pagination — resetting page index when filter state changes
- React `useTransition` — [Speculation] potential future pattern for deferring filter evaluation in concurrent React