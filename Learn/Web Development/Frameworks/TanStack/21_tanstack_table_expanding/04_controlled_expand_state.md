## TanStack Table — Controlled Expand State

### Overview

Controlled expand state means that the `expanded` state is owned and managed entirely outside of TanStack Table — in component state, a state manager, a URL parameter, or a server — and passed into the table via the `state` option. The table reads the state but never modifies it directly. All mutations go through `onExpandedChange`, which you implement. This is the standard React controlled-component pattern applied to TanStack Table's expansion feature.

The alternative — uncontrolled expansion — exists only in a limited sense: TanStack Table has no internal default expansion state management of its own. Without providing `state.expanded` and `onExpandedChange`, the table has no expansion state at all and `getExpandedRowModel` cannot function correctly. [Inference] Omitting both `state.expanded` and `onExpandedChange` may not throw but will result in expansion state that never persists between renders — behavior may vary by version.

---

### Controlled vs. Uncontrolled — What Applies Here

In many UI libraries, "controlled" vs. "uncontrolled" refers to whether state lives inside or outside the component. TanStack Table is a headless library that holds no DOM state — all state, including `expanded`, is expected to be provided externally. "Controlled" in TanStack Table therefore means you are explicitly providing and managing the state. There is no built-in fallback state.

state.expandeduser interactionsetExpanded()Your State(useState / Zustand / URL/ etc.)onExpandedChangetable state.expandedgetRowModel()Rendered Rows

The state cycle is explicit and unidirectional. TanStack Table never writes to `state.expanded` directly.

---

### Minimal Controlled Setup

ts

```ts
import { useState } from 'react'
import {
  useReactTable,
  getCoreRowModel,
  getExpandedRowModel,
  ExpandedState,
} from '@tanstack/react-table'

const [expanded, setExpanded] = useState<ExpandedState>({})

const table = useReactTable({
  data,
  columns,
  state: {
    expanded,
  },
  onExpandedChange: setExpanded,
  getCoreRowModel: getCoreRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
})
```

This is the baseline. Every variation covered below builds on this structure by replacing or wrapping either `expanded` state or `onExpandedChange`.

---

### `onExpandedChange` — The Updater Pattern

`onExpandedChange` receives an `Updater<ExpandedState>`, not a raw `ExpandedState` value directly. An `Updater` is either:

- A new state value directly: `ExpandedState`
- A function that receives the previous state and returns the next state: `(prev: ExpandedState) => ExpandedState`

ts

```ts
type OnChangeFn<T> = (updater: Updater<T>) => void
type Updater<T> = T | ((prev: T) => T)
```

When wiring `onExpandedChange` to a `useState` setter, this works automatically because React's `setState` accepts both a value and a function updater:

ts

```ts
onExpandedChange: setExpanded   // works directly — React handles both forms
```

When wiring to a custom handler, resolve the updater explicitly:

ts

```ts
onExpandedChange: (updater) => {
  const next = typeof updater === 'function' ? updater(expanded) : updater
  // do something with next
  setExpanded(next)
}
```

This resolution pattern is necessary whenever you need to inspect or intercept the incoming state before applying it.

---

### Intercepting Expansion Changes

Because `onExpandedChange` is a callback you control, you can intercept, modify, or cancel expansion changes before they reach state.

#### Logging changes

ts

```ts
onExpandedChange: (updater) => {
  const next = typeof updater === 'function' ? updater(expanded) : updater
  console.log('Expansion changed:', { prev: expanded, next })
  setExpanded(next)
}
```

#### Preventing specific rows from expanding

ts

```ts
onExpandedChange: (updater) => {
  const next = typeof updater === 'function' ? updater(expanded) : updater

  if (typeof next === 'object') {
    const filtered = Object.fromEntries(
      Object.entries(next).filter(([rowId]) => !lockedRowIds.has(rowId))
    )
    setExpanded(filtered)
  } else {
    setExpanded(next)
  }
}
```

[Inference] This pattern filters expansion keys after TanStack Table computes the next state. It does not prevent `row.toggleExpanded()` from being called — it only prevents the resulting state from being saved. Behavior of `row.getIsExpanded()` after a blocked toggle depends on whether your state update causes a re-render that resets the row model.

#### Limiting to one expanded row at a time (accordion behavior)

ts

```ts
onExpandedChange: (updater) => {
  const next = typeof updater === 'function' ? updater(expanded) : updater

  if (typeof next !== 'object') {
    // next === true means all-expanded; treat as no constraint
    setExpanded(next)
    return
  }

  // Keep only the most recently expanded row
  const expandedIds = Object.entries(next)
    .filter(([, v]) => v)
    .map(([id]) => id)

  const prevExpandedIds = typeof expanded === 'object'
    ? Object.entries(expanded).filter(([, v]) => v).map(([id]) => id)
    : []

  const newlyExpanded = expandedIds.filter(id => !prevExpandedIds.includes(id))

  if (newlyExpanded.length > 0) {
    // Only keep the newly expanded row
    setExpanded({ [newlyExpanded[0]]: true })
  } else {
    // A row was collapsed — allow it
    setExpanded(next)
  }
}
```

---

### Accordion Pattern — One Row Open at a Time

The accordion is a common controlled-state pattern. Only one row may be expanded at any time; expanding a new row collapses the previously open one.

tsx

```tsx
const [expanded, setExpanded] = useState<ExpandedState>({})

const handleExpandedChange: OnChangeFn<ExpandedState> = (updater) => {
  const next = typeof updater === 'function' ? updater(expanded) : updater

  if (typeof next !== 'object') {
    setExpanded({})
    return
  }

  const expandedIds = Object.keys(next).filter(id => next[id])

  if (expandedIds.length === 0) {
    setExpanded({})
    return
  }

  // Determine which row was most recently toggled
  const prevIds = typeof expanded === 'object'
    ? Object.keys(expanded).filter(id => expanded[id])
    : []

  const added = expandedIds.find(id => !prevIds.includes(id))

  setExpanded(added ? { [added]: true } : {})
}

const table = useReactTable({
  data,
  columns,
  state: { expanded },
  onExpandedChange: handleExpandedChange,
  getCoreRowModel: getCoreRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
  getRowCanExpand: () => true,
})
```

---

### Syncing Expanded State to a URL

Persisting expanded state in a URL allows bookmarking, sharing, and browser back/forward navigation.

#### Encoding

ts

```ts
// Encode: ExpandedState → URL param string
function encodeExpanded(expanded: ExpandedState): string {
  if (expanded === true) return 'all'
  const ids = Object.entries(expanded)
    .filter(([, v]) => v)
    .map(([id]) => id)
  return ids.join(',')
}

// Decode: URL param string → ExpandedState
function decodeExpanded(param: string | null): ExpandedState {
  if (!param) return {}
  if (param === 'all') return true
  return Object.fromEntries(param.split(',').map(id => [id, true]))
}
```

#### Usage with React Router or `URLSearchParams`

ts

```ts
const [searchParams, setSearchParams] = useSearchParams()

const expanded: ExpandedState = useMemo(
  () => decodeExpanded(searchParams.get('expanded')),
  [searchParams]
)

const onExpandedChange: OnChangeFn<ExpandedState> = (updater) => {
  const next = typeof updater === 'function' ? updater(expanded) : updater
  setSearchParams(prev => {
    const encoded = encodeExpanded(next)
    if (encoded) {
      prev.set('expanded', encoded)
    } else {
      prev.delete('expanded')
    }
    return prev
  })
}
```

[Inference] Row IDs in the URL are derived from TanStack Table's internal ID generation or your `getRowId` function. If row IDs contain characters that require URL encoding (spaces, slashes, colons), apply `encodeURIComponent` per ID before joining — behavior of unencoded special characters in query params depends on the browser and router.

---

### Syncing Expanded State to `localStorage`

ts

```ts
const STORAGE_KEY = 'myTable.expanded'

function readExpanded(): ExpandedState {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    return raw ? JSON.parse(raw) : {}
  } catch {
    return {}
  }
}

const [expanded, setExpanded] = useState<ExpandedState>(readExpanded)

useEffect(() => {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(expanded))
  } catch {
    // storage quota exceeded or unavailable — fail silently
  }
}, [expanded])
```

The `useState` initializer `readExpanded` (without invocation parentheses passed directly as a function) runs only once on mount. Subsequent renders read from React state, not `localStorage`.

[Inference] If the same table is open in multiple browser tabs, `localStorage` changes in one tab are not automatically reflected in others without a `storage` event listener — behavior of cross-tab expansion sync depends on your implementation.

---

### Syncing with an External State Manager

#### Zustand

ts

```ts
// store.ts
import { create } from 'zustand'
import { ExpandedState } from '@tanstack/react-table'

type TableStore = {
  expanded: ExpandedState
  setExpanded: (updater: ExpandedState | ((prev: ExpandedState) => ExpandedState)) => void
}

export const useTableStore = create<TableStore>(set => ({
  expanded: {},
  setExpanded: (updater) => set(state => ({
    expanded: typeof updater === 'function' ? updater(state.expanded) : updater,
  })),
}))
```

ts

```ts
// Component
const { expanded, setExpanded } = useTableStore()

const table = useReactTable({
  state: { expanded },
  onExpandedChange: setExpanded,
  // ...
})
```

#### Redux Toolkit

ts

```ts
// tableSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit'
import { ExpandedState, Updater } from '@tanstack/react-table'

const tableSlice = createSlice({
  name: 'table',
  initialState: { expanded: {} as ExpandedState },
  reducers: {
    setExpanded(state, action: PayloadAction<ExpandedState>) {
      state.expanded = action.payload
    },
  },
})
```

ts

```ts
// Component
const expanded = useSelector(state => state.table.expanded)
const dispatch = useDispatch()

const onExpandedChange: OnChangeFn<ExpandedState> = (updater) => {
  const next = typeof updater === 'function' ? updater(expanded) : updater
  dispatch(tableSlice.actions.setExpanded(next))
}
```

---

### Diagram — Controlled State Data Flow

TableInstanceYourStateonExpandedChangeRowUserTableInstanceYourStateonExpandedChangeRowUserclicks toggleupdater(prevExpanded)setExpanded(next)state.expanded = nextre-renders with new expansion

---

### Programmatic Expansion from Outside the Table

Because you own the state, you can expand or collapse rows programmatically without user interaction — from a button outside the table, a route change, or a timer:

tsx

```tsx
// Expand a specific row by ID from outside the table component
<button onClick={() => setExpanded(prev => ({
  ...prev,
  'row-id-here': true,
}))}>
  Open Engineering Group
</button>

// Collapse all
<button onClick={() => setExpanded({})}>
  Collapse All
</button>

// Expand all
<button onClick={() => setExpanded(true)}>
  Expand All
</button>
```

No reference to the `table` instance is needed for these operations — you manipulate state directly and the table reacts.

---

### Deriving Initial State from Data

When data is loaded asynchronously, you may want to expand specific groups automatically once data arrives:

ts

```ts
const [expanded, setExpanded] = useState<ExpandedState>({})

useEffect(() => {
  if (data.length > 0 && Object.keys(expanded).length === 0) {
    // Expand the first top-level row on initial load
    const firstRowId = String(data[0].id)
    setExpanded({ [firstRowId]: true })
  }
}, [data])
```

[Inference] This pattern checks `Object.keys(expanded).length === 0` to avoid overwriting user-initiated expansion on subsequent data updates — but if `expanded` is `true` (all-expanded), this check does not guard against overwriting that state. Add a `typeof expanded !== 'boolean'` guard if needed.

---

### Resetting Expansion on Filter or Sort Change

When filtering or sorting changes, it is sometimes desirable to collapse all groups to reduce visual disorientation:

ts

```ts
const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])

const handleFiltersChange: OnChangeFn<ColumnFiltersState> = (updater) => {
  const next = typeof updater === 'function' ? updater(columnFilters) : updater
  setColumnFilters(next)
  setExpanded({})   // collapse all on filter change
}
```

This is the manual equivalent of `autoResetExpanded: true` but gives you precise control over when the reset occurs and what the reset value is.

---

### `autoResetExpanded` Interaction with Controlled State

`autoResetExpanded` controls whether TanStack Table calls `onExpandedChange({})` automatically when data, filtering, or grouping state changes.

ts

```ts
const table = useReactTable({
  autoResetExpanded: false,   // you control when resets happen
  // ...
})
```

With `autoResetExpanded: true` (default), TanStack Table fires `onExpandedChange` with an empty state when relevant upstream state changes. Because `onExpandedChange` is your function, you can ignore or override this:

ts

```ts
onExpandedChange: (updater) => {
  const next = typeof updater === 'function' ? updater(expanded) : updater
  // Ignore resets to empty object triggered by data changes
  if (typeof next === 'object' && Object.keys(next).length === 0) return
  setExpanded(next)
}
```

[Inference] Distinguishing an auto-reset call from a user-initiated collapse-all is not straightforward — both produce the same updater value. This pattern suppresses all collapses-to-empty, including intentional ones. Use with caution and verify the interaction against your specific use case.

---

### Full Working Example — Controlled State with URL Sync

tsx

```tsx
import React, { useMemo } from 'react'
import { useSearchParams } from 'react-router-dom'
import {
  useReactTable,
  getCoreRowModel,
  getExpandedRowModel,
  flexRender,
  ColumnDef,
  ExpandedState,
  OnChangeFn,
} from '@tanstack/react-table'

type Department = {
  id: string
  name: string
  headcount: number
  subRows?: Department[]
}

const data: Department[] = [
  {
    id: 'eng',
    name: 'Engineering',
    headcount: 40,
    subRows: [
      { id: 'eng-fe',  name: 'Frontend',  headcount: 12 },
      { id: 'eng-be',  name: 'Backend',   headcount: 18 },
      { id: 'eng-infra', name: 'Infra',   headcount: 10 },
    ],
  },
  {
    id: 'design',
    name: 'Design',
    headcount: 15,
    subRows: [
      { id: 'design-ux', name: 'UX',      headcount: 9 },
      { id: 'design-brand', name: 'Brand', headcount: 6 },
    ],
  },
]

function encodeExpanded(e: ExpandedState): string {
  if (e === true) return 'all'
  const ids = Object.entries(e).filter(([, v]) => v).map(([id]) => id)
  return ids.join(',')
}

function decodeExpanded(param: string | null): ExpandedState {
  if (!param) return {}
  if (param === 'all') return true
  return Object.fromEntries(param.split(',').map(id => [id, true]))
}

const columns: ColumnDef<Department>[] = [
  {
    id: 'expander',
    header: () => null,
    cell: ({ row }) =>
      row.getCanExpand() ? (
        <button onClick={row.getToggleExpandedHandler()}>
          {row.getIsExpanded() ? '▼' : '▶'}
        </button>
      ) : null,
  },
  { accessorKey: 'name',      header: 'Department' },
  { accessorKey: 'headcount', header: 'Headcount' },
]

export default function ControlledExpandTable() {
  const [searchParams, setSearchParams] = useSearchParams()

  const expanded = useMemo(
    () => decodeExpanded(searchParams.get('expanded')),
    [searchParams]
  )

  const onExpandedChange: OnChangeFn<ExpandedState> = (updater) => {
    const next = typeof updater === 'function' ? updater(expanded) : updater
    setSearchParams(prev => {
      const encoded = encodeExpanded(next)
      encoded ? prev.set('expanded', encoded) : prev.delete('expanded')
      return prev
    }, { replace: true })
  }

  const table = useReactTable({
    data,
    columns,
    state: { expanded },
    onExpandedChange,
    getCoreRowModel: getCoreRowModel(),
    getExpandedRowModel: getExpandedRowModel(),
    getSubRows: row => row.subRows,
    getRowId: row => row.id,
    autoResetExpanded: false,
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
          <tr key={row.id} style={{ paddingLeft: `${row.depth * 1.5}rem` }}>
            {row.getVisibleCells().map(cell => (
              <td key={cell.id}>
                {flexRender(cell.column.columnDef.cell, cell.getContext())}
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

- `ExpandedState` type — `true` vs. record form and their behavioral differences
- `autoResetExpanded` — when TanStack Table resets expansion automatically
- Accordion patterns — single-open-row constraint via `onExpandedChange`
- Persisting state in URL search parameters with React Router
- Zustand and Redux integration for table state
- Programmatic expansion from outside the table component
- Controlled state for other features — sorting, filtering, pagination, column visibility
- `getRowId` — stable IDs for reliable expansion state keys
- Combining controlled expansion with server-side data fetching