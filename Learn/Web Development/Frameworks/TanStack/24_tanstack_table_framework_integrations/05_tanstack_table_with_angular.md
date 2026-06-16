## TanStack Table with Angular

TanStack Table v8 is framework-agnostic at its core, exposing a headless adapter model where each framework receives a thin integration layer. Angular's adapter follows this pattern, wiring the table's reactive state into Angular's change detection and template system.

---

### Installation and Setup

bash

```bash
npm install @tanstack/angular-table
```

The Angular adapter requires Angular 16+ due to its use of signals-based reactivity. [Inference: earlier versions may work with workarounds but are not officially supported.]

ts

```ts
// app.config.ts or a standalone component — no NgModule registration needed
import { Component } from '@angular/core';
import {
  createAngularTable,
  getCoreRowModel,
  ColumnDef,
  FlexRenderDirective,
} from '@tanstack/angular-table';
```

**Key Points**

- `createAngularTable` is the Angular-specific factory wrapping the core `createTable` logic
- `FlexRenderDirective` (`*flexRender`) handles rendering cell/header/footer definitions inside templates
- The adapter emits Angular signals internally, so table state updates trigger Angular's reactivity without manual `ChangeDetectorRef` calls [Inference based on library source patterns; behavior may vary across versions]

---

### Defining Columns

Columns are typed with `ColumnDef<TData>`. Angular uses the same column definition API as other adapters.

ts

```ts
import { ColumnDef } from '@tanstack/angular-table';

export type Person = {
  id: number;
  name: string;
  age: number;
  email: string;
};

export const columns: ColumnDef<Person>[] = [
  {
    accessorKey: 'id',
    header: 'ID',
  },
  {
    accessorKey: 'name',
    header: 'Name',
  },
  {
    accessorKey: 'age',
    header: 'Age',
  },
  {
    accessorKey: 'email',
    header: 'Email',
  },
];
```

**Key Points**

- `accessorKey` maps directly to a property on `TData`
- `accessorFn` is preferred when the accessor requires transformation logic
- `header` accepts a string or a function returning a renderable value
- `cell` accepts a function receiving `CellContext<TData, TValue>` for custom rendering

---

### Creating the Table Instance

ts

```ts
import {
  Component,
  signal,
  OnInit,
} from '@angular/core';
import {
  createAngularTable,
  getCoreRowModel,
} from '@tanstack/angular-table';
import { columns, Person } from './columns';

@Component({
  selector: 'app-table',
  standalone: true,
  imports: [FlexRenderDirective],
  templateUrl: './table.component.html',
})
export class TableComponent {
  data = signal<Person[]>([
    { id: 1, name: 'Alice', age: 30, email: 'alice@example.com' },
    { id: 2, name: 'Bob', age: 24, email: 'bob@example.com' },
    { id: 3, name: 'Carol', age: 35, email: 'carol@example.com' },
  ]);

  table = createAngularTable(() => ({
    data: this.data(),
    columns,
    getCoreRowModel: getCoreRowModel(),
  }));
}
```

**Key Points**

- `createAngularTable` accepts a **reactive options factory function** `() => (options)`, not a plain options object — this is the critical distinction from the React adapter
- The factory is re-evaluated when any signal it reads changes, propagating updates through the table
- `getCoreRowModel` is always required; additional row model functions (`getSortedRowModel`, `getFilteredRowModel`, etc.) are added incrementally

---

### Template Rendering with `FlexRenderDirective`

`*flexRender` is a structural directive that renders header/cell definitions, which may be strings, components, or render functions.

html

```html
<!-- table.component.html -->
<table>
  <thead>
    @for (headerGroup of table.getHeaderGroups(); track headerGroup.id) {
      <tr>
        @for (header of headerGroup.headers; track header.id) {
          <th [colSpan]="header.colSpan">
            @if (!header.isPlaceholder) {
              <ng-container
                *flexRender="
                  header.column.columnDef.header;
                  props: header.getContext();
                  let headerCell
                "
              >
                {{ headerCell }}
              </ng-container>
            }
          </th>
        }
      </tr>
    }
  </thead>
  <tbody>
    @for (row of table.getRowModel().rows; track row.id) {
      <tr>
        @for (cell of row.getVisibleCells(); track cell.id) {
          <td>
            <ng-container
              *flexRender="
                cell.column.columnDef.cell;
                props: cell.getContext();
                let cellValue
              "
            >
              {{ cellValue }}
            </ng-container>
          </td>
        }
      </tr>
    }
  </tbody>
</table>
```

**Key Points**

- `@for` with `track` is the Angular 17+ control flow syntax; `*ngFor` with `trackBy` is the equivalent for older templates
- `header.getContext()` and `cell.getContext()` supply the props object that `*flexRender` forwards to the render definition
- `FlexRenderDirective` must be listed in the component's `imports` array for standalone components, or in the module's `declarations` for NgModule-based apps [Inference: exact import requirements may differ between patch versions]

---

### Rendering Custom Cell Components

When a cell requires rich markup — icons, badges, action buttons — the recommended approach is to pass an Angular component reference as the `cell` definition value.

ts

```ts
// status-cell.component.ts
import { Component, input } from '@angular/core';
import { CellContext } from '@tanstack/angular-table';
import { Person } from './columns';

@Component({
  selector: 'app-status-cell',
  standalone: true,
  template: `
    <span [class]="'badge badge--' + props().getValue()">
      {{ props().getValue() }}
    </span>
  `,
})
export class StatusCellComponent {
  props = input.required<CellContext<Person, string>>();
}
```

ts

```ts
// columns.ts (updated cell definition)
import { StatusCellComponent } from './status-cell.component';

{
  accessorKey: 'status',
  header: 'Status',
  cell: (ctx) => StatusCellComponent,
  // FlexRenderDirective will instantiate the component and pass ctx as props
}
```

**Key Points**

- Passing a component class (not an instance) as the `cell` value tells `FlexRenderDirective` to instantiate it and bind `props` via Angular's `input()` signal
- The component receives the full `CellContext` object; use `props().getValue()` or `props().row.original` for data access
- This pattern avoids `innerHTML` rendering and keeps cells as proper Angular components with full lifecycle support [Inference]

---

### Sorting

ts

```ts
import {
  createAngularTable,
  getCoreRowModel,
  getSortedRowModel,
  SortingState,
} from '@tanstack/angular-table';
import { signal } from '@angular/core';

// Inside the component class:
sorting = signal<SortingState>([]);

table = createAngularTable(() => ({
  data: this.data(),
  columns,
  state: {
    sorting: this.sorting(),
  },
  onSortingChange: (updater) => {
    this.sorting.update(
      typeof updater === 'function' ? updater : () => updater
    );
  },
  getCoreRowModel: getCoreRowModel(),
  getSortedRowModel: getSortedRowModel(),
}));
```

html

```html
<!-- Header cell with sort toggle -->
<th (click)="header.column.getToggleSortingHandler()?.($event)">
  <ng-container *flexRender="header.column.columnDef.header; props: header.getContext(); let h">
    {{ h }}
  </ng-container>
  @switch (header.column.getIsSorted()) {
    @case ('asc') { ↑ }
    @case ('desc') { ↓ }
    @default { }
  }
</th>
```

**Key Points**

- `SortingState` is an array of `{ id: string; desc: boolean }` objects
- `onSortingChange` receives either a new state value or an updater function — the ternary pattern handles both cases correctly
- Multi-column sort is supported by default; hold Shift while clicking headers (behavior depends on browser event propagation; may vary)
- `enableSorting: false` on a column definition disables sort for that column

---

### Filtering

#### Global Filter

ts

```ts
import {
  getFilteredRowModel,
} from '@tanstack/angular-table';

globalFilter = signal('');

table = createAngularTable(() => ({
  data: this.data(),
  columns,
  state: {
    globalFilter: this.globalFilter(),
  },
  onGlobalFilterChange: (val) => this.globalFilter.set(val),
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
}));
```

html

```html
<input
  [value]="globalFilter()"
  (input)="table.setGlobalFilter($any($event.target).value)"
  placeholder="Search all columns…"
/>
```

#### Column-Level Filter

ts

```ts
// Column definition
{
  accessorKey: 'name',
  header: 'Name',
  enableColumnFilter: true,
}
```

html

```html
<input
  [value]="header.column.getFilterValue() ?? ''"
  (input)="header.column.setFilterValue($any($event.target).value)"
  placeholder="Filter name…"
/>
```

**Key Points**

- Global and column filters can coexist; both require `getFilteredRowModel` in the table options
- Custom filter functions can be registered in `filterFns` on the table options and referenced by name in column definitions
- `columnFilterDisplayMode` and `globalFilterFn` provide additional tuning points

---

### Pagination

ts

```ts
import {
  getPaginationRowModel,
  PaginationState,
} from '@tanstack/angular-table';

pagination = signal<PaginationState>({ pageIndex: 0, pageSize: 10 });

table = createAngularTable(() => ({
  data: this.data(),
  columns,
  state: {
    pagination: this.pagination(),
  },
  onPaginationChange: (updater) => {
    this.pagination.update(
      typeof updater === 'function' ? updater : () => updater
    );
  },
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
}));
```

html

```html
<div class="pagination-controls">
  <button (click)="table.firstPage()" [disabled]="!table.getCanPreviousPage()">«</button>
  <button (click)="table.previousPage()" [disabled]="!table.getCanPreviousPage()">‹</button>
  <span>
    Page {{ table.getState().pagination.pageIndex + 1 }} of {{ table.getPageCount() }}
  </span>
  <button (click)="table.nextPage()" [disabled]="!table.getCanNextPage()">›</button>
  <button (click)="table.lastPage()" [disabled]="!table.getCanNextPage()">»</button>

  <select
    [value]="table.getState().pagination.pageSize"
    (change)="table.setPageSize(+$any($event.target).value)"
  >
    @for (size of [10, 20, 50, 100]; track size) {
      <option [value]="size">Show {{ size }}</option>
    }
  </select>
</div>
```

---

### Row Selection

ts

```ts
import { RowSelectionState } from '@tanstack/angular-table';

rowSelection = signal<RowSelectionState>({});

table = createAngularTable(() => ({
  data: this.data(),
  columns: [
    {
      id: 'select',
      header: ({ table }) =>
        // Render component or use FlexRender for checkbox
        '',
      cell: ({ row }) => '',
    },
    ...columns,
  ],
  state: {
    rowSelection: this.rowSelection(),
  },
  onRowSelectionChange: (updater) => {
    this.rowSelection.update(
      typeof updater === 'function' ? updater : () => updater
    );
  },
  enableRowSelection: true,
  getCoreRowModel: getCoreRowModel(),
}));
```

html

```html
<!-- Select-all checkbox in header -->
<input
  type="checkbox"
  [checked]="table.getIsAllRowsSelected()"
  [indeterminate]="table.getIsSomeRowsSelected()"
  (change)="table.toggleAllRowsSelected()"
/>

<!-- Per-row checkbox in cell -->
<input
  type="checkbox"
  [checked]="row.getIsSelected()"
  [disabled]="!row.getCanSelect()"
  (change)="row.toggleSelected()"
/>
```

**Key Points**

- `RowSelectionState` is a `Record<string, boolean>` keyed by row ID
- `enableRowSelection` can also be a function `(row) => boolean` for conditional selectability
- `enableMultiRowSelection: false` restricts selection to a single row at a time
- Selected rows are accessible via `table.getSelectedRowModel().rows`

---

### Column Visibility

ts

```ts
import { VisibilityState } from '@tanstack/angular-table';

columnVisibility = signal<VisibilityState>({});

table = createAngularTable(() => ({
  data: this.data(),
  columns,
  state: {
    columnVisibility: this.columnVisibility(),
  },
  onColumnVisibilityChange: (updater) => {
    this.columnVisibility.update(
      typeof updater === 'function' ? updater : () => updater
    );
  },
  getCoreRowModel: getCoreRowModel(),
}));
```

html

```html
<!-- Column visibility toggles -->
@for (col of table.getAllLeafColumns(); track col.id) {
  <label>
    <input
      type="checkbox"
      [checked]="col.getIsVisible()"
      (change)="col.toggleVisibility()"
    />
    {{ col.id }}
  </label>
}
```

---

### Column Resizing

ts

```ts
import { ColumnResizeMode } from '@tanstack/angular-table';

table = createAngularTable(() => ({
  data: this.data(),
  columns,
  columnResizeMode: 'onChange' as ColumnResizeMode,
  getCoreRowModel: getCoreRowModel(),
}));
```

html

```html
<th
  *ngFor="let header of headerGroup.headers"
  [style.width.px]="header.getSize()"
>
  <!-- header content -->
  <div
    (mousedown)="header.getResizeHandler()($event)"
    (touchstart)="header.getResizeHandler()($event)"
    class="resizer"
    [class.isResizing]="header.column.getIsResizing()"
  ></div>
</th>
```

**Key Points**

- `columnResizeMode: 'onChange'` applies width changes during drag; `'onEnd'` applies on mouse-up
- Column sizes are stored in `columnSizing` state; persist to `localStorage` for user preference retention [Inference]
- CSS `table-layout: fixed` is typically required for pixel-precise column widths to be respected by the browser

---

### Server-Side Data (Manual Mode)

For paginated APIs, sorting and filtering are handled externally. The table is placed in manual mode.

ts

```ts
table = createAngularTable(() => ({
  data: this.data(),       // data slice for current page only
  columns,
  rowCount: this.totalRows(), // total rows in the server dataset
  state: {
    pagination: this.pagination(),
    sorting: this.sorting(),
  },
  onPaginationChange: (updater) => { /* update signal, trigger API call */ },
  onSortingChange: (updater) => { /* update signal, trigger API call */ },
  manualPagination: true,
  manualSorting: true,
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
}));
```

**Key Points**

- `manualPagination: true` disables client-side row slicing; the table displays whatever is in `data` as the current page
- `rowCount` (or the deprecated `pageCount`) must be provided so the table can calculate total page count
- State change handlers are the correct place to trigger HTTP calls that update the `data` signal

---

### Reactivity Architecture

The following diagram illustrates how Angular signals flow through the table adapter:

<svg viewBox="0 0 720 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace, sans-serif" font-size="13">
<!-- Background -->
<rect width="720" height="400" fill="#0f172a" rx="12"/>
<!-- Signal Sources -->
<rect x="30" y="40" width="150" height="44" rx="8" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
<text x="105" y="58" text-anchor="middle" fill="#93c5fd" font-size="12">data</text>
<text x="105" y="75" text-anchor="middle" fill="#60a5fa" font-size="11">signal&lt;Person[]&gt;</text>
<rect x="30" y="110" width="150" height="44" rx="8" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
<text x="105" y="128" text-anchor="middle" fill="#93c5fd" font-size="12">sorting</text>
<text x="105" y="145" text-anchor="middle" fill="#60a5fa" font-size="11">signal&lt;SortingState&gt;</text>
<rect x="30" y="180" width="150" height="44" rx="8" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
<text x="105" y="198" text-anchor="middle" fill="#93c5fd" font-size="12">pagination</text>
<text x="105" y="215" text-anchor="middle" fill="#60a5fa" font-size="11">signal&lt;PaginationState&gt;</text>
<rect x="30" y="250" width="150" height="44" rx="8" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
<text x="105" y="268" text-anchor="middle" fill="#93c5fd" font-size="12">rowSelection</text>
<text x="105" y="285" text-anchor="middle" fill="#60a5fa" font-size="11">signal&lt;RowSelectionState&gt;</text>
<!-- Arrows to factory -->
<line x1="180" y1="62" x2="265" y2="145" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="180" y1="132" x2="265" y2="160" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="180" y1="202" x2="265" y2="175" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="180" y1="272" x2="265" y2="190" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Options Factory -->
<rect x="265" y="110" width="170" height="80" rx="8" fill="#1e293b" stroke="#8b5cf6" stroke-width="1.5"/>
<text x="350" y="143" text-anchor="middle" fill="#c4b5fd" font-size="12">Options Factory</text>
<text x="350" y="163" text-anchor="middle" fill="#a78bfa" font-size="11">() =&gt; ({ data, state })</text>
<text x="350" y="180" text-anchor="middle" fill="#7c3aed" font-size="10">re-runs on signal change</text>
<!-- Arrow to table core -->
<line x1="435" y1="150" x2="495" y2="150" stroke="#8b5cf6" stroke-width="1.5" marker-end="url(#arr2)"/>
<!-- Table Core -->
<rect x="495" y="100" width="170" height="100" rx="8" fill="#1e293b" stroke="#10b981" stroke-width="1.5"/>
<text x="580" y="130" text-anchor="middle" fill="#6ee7b7" font-size="12">createAngularTable</text>
<text x="580" y="150" text-anchor="middle" fill="#34d399" font-size="11">Core Table Instance</text>
<text x="580" y="168" text-anchor="middle" fill="#059669" font-size="10">row models computed</text>
<text x="580" y="183" text-anchor="middle" fill="#059669" font-size="10">internally via signals</text>
<!-- Arrow to template -->
<line x1="580" y1="200" x2="580" y2="265" stroke="#10b981" stroke-width="1.5" marker-end="url(#arr3)"/>
<!-- Template -->
<rect x="475" y="265" width="210" height="80" rx="8" fill="#1e3a2f" stroke="#10b981" stroke-width="1.5"/>
<text x="580" y="293" text-anchor="middle" fill="#6ee7b7" font-size="12">Angular Template</text>
<text x="580" y="313" text-anchor="middle" fill="#34d399" font-size="11">\*flexRender + @for</text>
<text x="580" y="333" text-anchor="middle" fill="#059669" font-size="10">reactive to signal updates</text>
<!-- onXChange callbacks arrow back to signals -->
<path d="M 495 320 Q 350 370 180 295" fill="none" stroke="#f59e0b" stroke-width="1.5" stroke-dasharray="5,4" marker-end="url(#arr4)"/>
<text x="340" y="380" text-anchor="middle" fill="#fbbf24" font-size="11">onXChange → signal.update()</text>
<!-- Arrowhead defs -->
<defs>
<marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#3b82f6"/>
</marker>
<marker id="arr2" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#8b5cf6"/>
</marker>
<marker id="arr3" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#10b981"/>
</marker>
<marker id="arr4" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#f59e0b"/>
</marker>
</defs>
</svg>

---

### Performance Considerations

**Key Points**

- The options factory function runs inside Angular's reactive context; reading many signals in it creates fine-grained dependency tracking [Inference based on Angular signals design]
- For large datasets, avoid computing derived values inside the factory — derive them outside via `computed()` signals and read the result
- `trackBy` / `track` on `@for` loops is critical; row and header IDs are stable identifiers suitable for tracking
- Column definitions should be defined outside the component class body or memoized to avoid recreating them on every factory invocation, which can force full table re-initialization [Inference]
- Virtualization is not built into TanStack Table; pair with `@tanstack/angular-virtual` for long row lists

---

### NgModule-Based Projects

For projects not using standalone components:

ts

```ts
// app.module.ts
import { NgModule } from '@angular/core';
import { FlexRenderDirective } from '@tanstack/angular-table';

@NgModule({
  imports: [FlexRenderDirective],
  // ...
})
export class AppModule {}
```

The rest of the API is identical; `createAngularTable` does not require NgModule registration.

---

### Common Pitfalls

| Pitfall | Description |
| --- | --- |
| Passing a plain object to `createAngularTable` | The first argument must be a factory function `() => options`, not an options object directly |
| Missing `FlexRenderDirective` import | `*flexRender` silently fails or throws if the directive is not in scope |
| Forgetting `typeof updater === 'function'` check | `onXChange` handlers receive either a value or an updater function; skipping the check causes state corruption |
| Column definitions recreated inline | Defining `columns` inside the factory causes identity change on every signal update, potentially resetting column state |
| `rowCount` omitted in manual mode | Pagination controls will display incorrect or `NaN` page counts |

---

**Related Topics**

- TanStack Table with Angular — Column Grouping and Nested Headers
- TanStack Table with Angular — Expanding and Subrows
- TanStack Table with Angular — Virtualized Rows using TanStack Virtual
- TanStack Table — Server-Side Patterns (pagination, sorting, filtering)
- TanStack Table — Custom Filter Functions
- TanStack Table — Column Pinning
- TanStack Table — Row Grouping and Aggregation
- Angular Signals deep dive — `signal`, `computed`, `effect`
- Integrating TanStack Table with Angular CDK for accessibility