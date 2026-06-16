## TanStack Virtual

TanStack Virtual is a headless, framework-agnostic UI utility for virtualizing large lists, grids, and other scrollable content. "Virtualization" (also called windowing) means only the DOM nodes currently visible in the scroll viewport — plus a small overscan buffer — are rendered at any given time, regardless of how many total rows or columns exist in the dataset.

---

### The Core Problem It Solves

Rendering 10,000 table rows as real DOM nodes is expensive. The browser must lay out, paint, and composite every element even if only 20 are visible. As row count grows, initial render time, scroll jank, and memory usage scale linearly with the total item count.

TanStack Virtual breaks this relationship: rendering cost stays roughly constant relative to the number of *visible* items, not the total item count.

---

### What "Headless" Means Here

TanStack Virtual does not render any DOM itself. It computes:

- which items are currently in the virtual window
- each item's pixel size and offset position
- total scroll container size (so the scrollbar reflects the full dataset)

Your code applies these measurements to actual DOM elements. This gives complete control over markup, styling, and framework integration.

---

### Supported Frameworks

TanStack Virtual v3 ships adapters for:

- React — `@tanstack/react-virtual`
- Vue — `@tanstack/vue-virtual`
- Solid — `@tanstack/solid-virtual`
- Svelte — `@tanstack/svelte-virtual`
- Angular — `@tanstack/angular-virtual`
- Vanilla JS — `@tanstack/virtual-core`

All adapters share the same underlying `@tanstack/virtual-core` logic.

---

### Core Concepts

#### Virtualizer

The central object. Created once per scrollable list or grid. Configured with:

- `count` — total number of items
- `getScrollElement` — a function returning the scroll container DOM element
- `estimateSize` — a function returning the estimated pixel height (or width) per item

#### Virtual Items

`virtualizer.getVirtualItems()` returns only the items that should currently be rendered. Each virtual item carries:

- `index` — position in the full dataset
- `size` — measured or estimated pixel size
- `start` — pixel offset from the top (or left) of the scroll container
- `key` — stable identity for framework reconciliation

#### Total Size

`virtualizer.getTotalSize()` returns the total pixel height (or width) of all items combined. This value is applied to a spacer element so the scrollbar accurately represents the full list length.

#### Overscan

Items slightly outside the visible viewport are also rendered to reduce blank flicker during fast scrolling. Controlled by the `overscan` option (default varies; typically 3–5 items). [Inference: exact default may differ across versions]

---

### Orientation Modes

| Mode | Use Case | Key Option |
| --- | --- | --- |
| Vertical | Standard scrolling list or table rows | `horizontal: false` (default) |
| Horizontal | Horizontal carousels, column virtualization | `horizontal: true` |
| Grid | Both axes virtualized simultaneously | Two separate virtualizer instances |

---

### Fixed vs Dynamic vs Variable Sizes

**Fixed size** — all items are the same height. `estimateSize` returns a constant. Most performant path; no measurement needed.

**Variable size** — items have different but known heights. `estimateSize` returns a per-index value.

**Dynamic size** — item heights are unknown until rendered (e.g., text wrapping, lazy images). Requires `measureElement` so the virtualizer can observe actual rendered sizes and correct its estimates. [Inference: measurement involves a ResizeObserver internally; behavior may vary across browsers]

---

### Relationship to TanStack Table

TanStack Virtual and TanStack Table are independent libraries with no hard dependency on each other. They are composed manually:

- TanStack Table manages row model logic — sorting, filtering, pagination, selection
- TanStack Virtual manages which of those rows to render at any given scroll position

The pattern is: get all rows from `table.getRowModel().rows`, pass `rows.length` as `count` to the virtualizer, then render only `virtualizer.getVirtualItems()`, using each virtual item's `index` to look up the corresponding row object.

---

### When to Use It

**Good fit:**

- Lists or tables with hundreds to tens of thousands of rows
- Infinite scroll feeds
- Large data grids with many columns
- Chat message histories

**Poor fit or unnecessary:**

- Lists under ~100–200 items where native DOM rendering is fast enough
- Paginated tables where only one page of rows is rendered at a time
- Content where accurate browser find-in-page (Ctrl+F) behavior is critical, since unrendered items are not in the DOM [Inference]

---

### Basic Mental Model

```
Full dataset: 10,000 items
                    │
           Virtualizer watches scroll position
                    │
         ┌──────────▼──────────┐
         │  Visible window      │  ~20 items rendered
         │  + overscan buffer   │
         └──────────────────────┘
                    │
         Spacer element holds total height
         so scrollbar spans full 10,000 items
```

---

### Packages

| Package | Purpose |
| --- | --- |
| `@tanstack/virtual-core` | Framework-agnostic core |
| `@tanstack/react-virtual` | React adapter |
| `@tanstack/angular-virtual` | Angular adapter |
| `@tanstack/vue-virtual` | Vue adapter |
| `@tanstack/solid-virtual` | Solid adapter |
| `@tanstack/svelte-virtual` | Svelte adapter |

---

**Related Topics**

- TanStack Virtual with Angular — setup and row virtualization
- TanStack Virtual with React — `useVirtualizer` hook
- Combining TanStack Table and TanStack Virtual for virtualized table rows
- Dynamic size measurement with `measureElement`
- Horizontal virtualization and column windowing
- Infinite scroll patterns with TanStack Virtual and TanStack Query
- Grid virtualization — virtualizing both rows and columns simultaneously
- TanStack Virtual — window scrolling vs element scrolling