## Grid Virtualization

Grid virtualization extends the core Virtual concept to two dimensions — rows and columns are both virtualized simultaneously. Instead of a single virtualizer instance tracking one axis, you create two: one for rows and one for columns. Only the cells at the intersection of visible rows and visible columns are rendered.

---

### Why Two-Axis Virtualization

In a standard list, items outside the viewport are unmounted. In a grid, the same principle applies to both axes. A 10,000-row × 500-column dataset has 5,000,000 potential cells. Without virtualization, even a fraction of those in the DOM causes severe performance degradation. With row and column virtualizers working together, only the cells in the visible window — typically dozens, not millions — are rendered at any time.

---

### Setting Up Row and Column Virtualizers

Each axis gets its own `useVirtualizer` call. Both share the same scroll container but operate on different dimensions.

ts

```ts
import { useVirtualizer } from '@tanstack/react-virtual'
import { useRef } from 'react'

const parentRef = useRef<HTMLDivElement>(null)

const rowVirtualizer = useVirtualizer({
  count: 10000,          // total number of rows
  getScrollElement: () => parentRef.current,
  estimateSize: () => 35,
  overscan: 5,
})

const columnVirtualizer = useVirtualizer({
  count: 500,            // total number of columns
  horizontal: true,      // ← critical: tells the virtualizer to track the X axis
  getScrollElement: () => parentRef.current,
  estimateSize: () => 120,
  overscan: 3,
})
```

**Key Points**

- `horizontal: true` switches the column virtualizer to track `scrollLeft` instead of `scrollTop`
- Both virtualizers share one `parentRef` — the same scrollable container handles both axes
- `overscan` on each axis is independent; columns may need lower overscan than rows due to wider cells

---

### Container and Inner Sizing

The scroll container must have fixed dimensions and `overflow: auto` on both axes. The inner container — the one that sets the total scrollable area — must be sized to `totalSize` from both virtualizers.

tsx

```tsx
<div
  ref={parentRef}
  style={{
    height: '600px',
    width: '100%',
    overflow: 'auto',
  }}
>
  <div
    style={{
      height: `${rowVirtualizer.getTotalSize()}px`,
      width: `${columnVirtualizer.getTotalSize()}px`,
      position: 'relative',
    }}
  >
    {/* virtual items rendered here */}
  </div>
</div>
```

The inner div must be `position: relative` so that absolutely positioned cells are placed correctly within it.

---

### Rendering the Cell Grid

Virtual items from both axes are iterated in a nested loop. Each cell is absolutely positioned using the `start` offset from its respective virtual item.

tsx

```tsx
{rowVirtualizer.getVirtualItems().map((virtualRow) => (
  columnVirtualizer.getVirtualItems().map((virtualColumn) => (
    <div
      key={`${virtualRow.index}-${virtualColumn.index}`}
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        width: `${virtualColumn.size}px`,
        height: `${virtualRow.size}px`,
        transform: `translateX(${virtualColumn.start}px) translateY(${virtualRow.start}px)`,
      }}
    >
      Row {virtualRow.index}, Col {virtualColumn.index}
    </div>
  ))
))}
```

**Key Points**

- The `transform` approach is preferred over setting `top`/`left` directly — it avoids layout thrashing and [Inference] benefits from GPU compositing in most browsers
- The `key` must combine both indices to be unique across the full cell space
- `width` and `height` come from the virtual item's `size`, not from the estimateSize directly — these reflect measured sizes once dynamic measurement is active

---

### Total Size and Scrollbar Accuracy

`getTotalSize()` returns the sum of all item sizes on that axis. For estimated sizes, this is a projection. For measured sizes, it reflects actual DOM measurements accumulated so far.

ts

```ts
rowVirtualizer.getTotalSize()    // e.g. 350000 for 10000 rows × 35px
columnVirtualizer.getTotalSize() // e.g. 60000  for 500 cols × 120px
```

[Inference] Scrollbar thumb size and position are determined by the ratio of the visible container size to `getTotalSize()`. Inaccurate size estimates will cause the scrollbar to shift as the user scrolls and real measurements replace estimates — this is expected behavior, not a bug.

---

### Dynamic Row and Column Sizes

Variable sizes are handled the same way as in list virtualization, but applied independently per axis.

ts

```ts
const rowVirtualizer = useVirtualizer({
  count: rowCount,
  getScrollElement: () => parentRef.current,
  estimateSize: (index) => rowHeights[index] ?? 35,
})

const columnVirtualizer = useVirtualizer({
  count: columnCount,
  horizontal: true,
  getScrollElement: () => parentRef.current,
  estimateSize: (index) => columnWidths[index] ?? 100,
})
```

For DOM-measured dynamic sizes, attach `measureElement` to each cell. Because cells exist at a two-dimensional intersection, measurement applies to the rendered DOM node:

tsx

```tsx
<div
  key={`${virtualRow.index}-${virtualColumn.index}`}
  ref={columnVirtualizer.measureElement} // measures width
  // or rowVirtualizer.measureElement for height — not both simultaneously
  style={{ ... }}
>
```

[Inference] Measuring both height and width from the same node simultaneously is not directly supported by the standard `measureElement` API, which tracks one axis per virtualizer. Workarounds include reading `offsetWidth`/`offsetHeight` manually via a callback ref. Behavior may vary depending on implementation.

---

### Overscan Behavior in Two Dimensions

Overscan adds buffer items beyond the visible range on each axis independently.

```
Visible rows: 10–30  → with overscan 5: renders rows 5–35
Visible cols: 2–8    → with overscan 3: renders cols 0–11
```

The total rendered cell count at any moment is approximately:

```
(visible_rows + 2 × row_overscan) × (visible_cols + 2 × col_overscan)
```

For the above: `(20 + 10) × (6 + 6)` = `30 × 12` = `360 cells` — a tiny fraction of a 10,000 × 500 grid.

---

### Sticky Headers and Frozen Columns

Sticky row headers (frozen top row) and frozen columns are a common grid requirement. TanStack Virtual does not provide this natively — it is implemented by rendering a separate non-virtualized row or column overlaid on the scrollable grid.

**Sticky row header approach:**

tsx

```tsx
<div style={{ position: 'relative' }}>
  {/* Sticky header row — rendered outside the scroll container */}
  <div style={{ display: 'flex', position: 'sticky', top: 0, zIndex: 1, background: 'white' }}>
    {columnVirtualizer.getVirtualItems().map((virtualColumn) => (
      <div
        key={virtualColumn.index}
        style={{
          width: `${virtualColumn.size}px`,
          transform: `translateX(${virtualColumn.start}px)`,
        }}
      >
        Column {virtualColumn.index}
      </div>
    ))}
  </div>

  {/* Scrollable grid body */}
  <div ref={parentRef} style={{ height: '560px', overflow: 'auto' }}>
    ...
  </div>
</div>
```

[Inference] Horizontal scroll synchronization between a sticky header and the scrollable body typically requires a shared `onScroll` handler or syncing `scrollLeft` via refs. Behavior may vary.

**Frozen column approach:**

A frozen (pinned) column is rendered as a separate absolutely-positioned element with `position: sticky; left: 0` inside the scroll container, outside the virtualized cell loop. [Inference] This requires careful z-index and background management to prevent the scrolling cells from visually overlapping the frozen column.

---

### Diagram: Two-Axis Virtualization Layout

<svg viewBox="0 0 700 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
<!-- Background -->
<rect width="700" height="420" fill="#0f1117" rx="10"/>
<!-- Scroll container border -->
<rect x="30" y="30" width="640" height="360" fill="#1a1d2e" rx="6" stroke="#3b3f5c" stroke-width="1.5"/>
<!-- Total virtual space label -->

<text x="350" y="22" fill="`#4a5080`" text-anchor="middle" font-size="11">Total virtual space (getTotalSize × getTotalSize)</text>

<!-- Visible viewport highlight -->
<rect x="130" y="100" width="300" height="180" fill="#1e2a4a" rx="4" stroke="#4f8ef7" stroke-width="2"/>
<text x="280" y="93" fill="#4f8ef7" text-anchor="middle" font-size="11">Viewport (visible window)</text>
<!-- Column axis label -->

<text x="350" y="390" fill="#888" text-anchor="middle" font-size="12">← columnVirtualizer (horizontal axis) →</text>

<!-- Row axis label -->

<text x="18" y="210" fill="#888" text-anchor="middle" font-size="12" transform="rotate(-90, 18, 210)">← rowVirtualizer (vertical axis) →</text>

<!-- Grid lines (columns) -->
<line x1="130" y1="100" x2="130" y2="280" stroke="#2a3050" stroke-width="1"/>
<line x1="205" y1="100" x2="205" y2="280" stroke="#2a3050" stroke-width="1"/>
<line x1="280" y1="100" x2="280" y2="280" stroke="#2a3050" stroke-width="1"/>
<line x1="355" y1="100" x2="355" y2="280" stroke="#2a3050" stroke-width="1"/>
<line x1="430" y1="100" x2="430" y2="280" stroke="#2a3050" stroke-width="1"/>
<!-- Grid lines (rows) -->
<line x1="130" y1="100" x2="430" y2="100" stroke="#2a3050" stroke-width="1"/>
<line x1="130" y1="145" x2="430" y2="145" stroke="#2a3050" stroke-width="1"/>
<line x1="130" y1="190" x2="430" y2="190" stroke="#2a3050" stroke-width="1"/>
<line x1="130" y1="235" x2="430" y2="235" stroke="#2a3050" stroke-width="1"/>
<line x1="130" y1="280" x2="430" y2="280" stroke="#2a3050" stroke-width="1"/>
<!-- Rendered cells (intersection of visible rows + cols) -->
<rect x="131" y="101" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="206" y="101" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="281" y="101" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="356" y="101" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="131" y="146" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="206" y="146" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="281" y="146" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="356" y="146" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="131" y="191" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="206" y="191" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="281" y="191" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="356" y="191" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="131" y="236" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="206" y="236" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="281" y="236" width="73" height="43" fill="#1f3a6e" rx="2"/>
<rect x="356" y="236" width="73" height="43" fill="#1f3a6e" rx="2"/>
<!-- Cell labels -->

<text x="167" y="127" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r0,c0</text>
<text x="242" y="127" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r0,c1</text>
<text x="317" y="127" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r0,c2</text>
<text x="392" y="127" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r0,c3</text>

<text x="167" y="172" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r1,c0</text>
<text x="242" y="172" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r1,c1</text>
<text x="317" y="172" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r1,c2</text>
<text x="392" y="172" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r1,c3</text>

<text x="167" y="217" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r2,c0</text>
<text x="242" y="217" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r2,c1</text>
<text x="317" y="217" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r2,c2</text>
<text x="392" y="217" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r2,c3</text>

<text x="167" y="262" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r3,c0</text>
<text x="242" y="262" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r3,c1</text>
<text x="317" y="262" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r3,c2</text>
<text x="392" y="262" fill="`#7aa2f7`" text-anchor="middle" font-size="10">r3,c3</text>

<!-- Out-of-viewport indicators -->

<text x="560" y="190" fill="`#3b3f5c`" text-anchor="middle" font-size="11">unmounted</text>
<text x="560" y="205" fill="`#3b3f5c`" text-anchor="middle" font-size="11">columns →</text>
<text x="80" y="340" fill="`#3b3f5c`" text-anchor="middle" font-size="11">unmounted</text>
<text x="80" y="355" fill="`#3b3f5c`" text-anchor="middle" font-size="11">rows ↓</text>
</svg>

---

### Scroll-to-Cell Programmatic Navigation

Both virtualizers expose `scrollToIndex`. To navigate to a specific cell, call both:

ts

```ts
rowVirtualizer.scrollToIndex(500, { align: 'start' })
columnVirtualizer.scrollToIndex(42, { align: 'center' })
```

These can be called independently or together. [Inference] Because they operate on separate axes of the same scroll container, calling both in the same event handler should produce correct two-dimensional navigation in most browsers, though scroll behavior may vary with `smooth` alignment options.

---

### Performance Considerations

- **Cell count per frame** — rendered cell count is the product of visible rows × visible columns. Keep overscan low on both axes for large column counts
- **Key stability** — use stable, unique keys (`rowIndex-colIndex`) to avoid unnecessary unmounts during scroll
- **Avoid inline object creation** — `style={{ ... }}` objects inside the render loop create new references each frame; [Inference] extracting style logic or memoizing may reduce garbage collection pressure in very large grids
- **Memoize cell content** — if cell content is expensive to compute, `React.memo` on the cell component can [Inference] reduce re-render cost, though effectiveness depends on your data and props shape
- **`transform` vs `top/left`** — the `transform` positioning pattern is preferred; [Inference] it avoids triggering layout recalculation for each cell in most browser rendering engines

---

### Full Minimal Example

tsx

```tsx
import { useRef } from 'react'
import { useVirtualizer } from '@tanstack/react-virtual'

const ROW_COUNT = 5000
const COL_COUNT = 200

export function VirtualGrid() {
  const parentRef = useRef<HTMLDivElement>(null)

  const rowVirtualizer = useVirtualizer({
    count: ROW_COUNT,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 35,
    overscan: 5,
  })

  const columnVirtualizer = useVirtualizer({
    count: COL_COUNT,
    horizontal: true,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 100,
    overscan: 3,
  })

  return (
    <div
      ref={parentRef}
      style={{ height: '600px', width: '100%', overflow: 'auto' }}
    >
      <div
        style={{
          height: `${rowVirtualizer.getTotalSize()}px`,
          width: `${columnVirtualizer.getTotalSize()}px`,
          position: 'relative',
        }}
      >
        {rowVirtualizer.getVirtualItems().map((virtualRow) =>
          columnVirtualizer.getVirtualItems().map((virtualColumn) => (
            <div
              key={`${virtualRow.index}-${virtualColumn.index}`}
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: `${virtualColumn.size}px`,
                height: `${virtualRow.size}px`,
                transform: `translateX(${virtualColumn.start}px) translateY(${virtualRow.start}px)`,
                borderRight: '1px solid #eee',
                borderBottom: '1px solid #eee',
                padding: '4px',
                boxSizing: 'border-box',
              }}
            >
              {virtualRow.index},{virtualColumn.index}
            </div>
          ))
        )}
      </div>
    </div>
  )
}
```

---

### Integration with TanStack Table

TanStack Virtual is commonly paired with TanStack Table for grid virtualization. In that context:

- `count` for the row virtualizer comes from `table.getRowModel().rows.length`
- `count` for the column virtualizer comes from `table.getVisibleLeafColumns().length`
- Cell content uses `row.getVisibleCells()` filtered or indexed to `virtualColumn.index`

[Inference] Column pinning in TanStack Table (via `columnPinning` state) produces separate left/right/center column groups; virtualizing only the center group while rendering pinned columns statically is the standard pattern for frozen column behavior. Behavior may vary based on implementation.

---

**Related Topics**

- Dynamic row heights with `measureElement` in grids
- Column pinning and frozen columns with TanStack Table + Virtual
- Programmatic scroll in grids (`scrollToIndex`, `scrollToOffset`)
- Windowed rendering vs. recycled DOM nodes (conceptual comparison)
- TanStack Virtual with non-React frameworks (Vue, Solid, Svelte adapters)
- Performance profiling virtualized grids with React DevTools and browser flame charts