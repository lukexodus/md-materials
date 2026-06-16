## Overscan Configuration

Overscan controls how many items beyond the visible viewport boundary TanStack Virtual renders as a buffer. Items within the overscan range are mounted in the DOM but not visible to the user. The purpose is to reduce perceived blank flicker during fast scrolling by keeping a margin of pre-rendered content ready.

---

### The `overscan` Option

`overscan` is an integer passed directly to `useVirtualizer`. It applies symmetrically — the same count is buffered before the first visible item and after the last visible item.

ts

```ts
const virtualizer = useVirtualizer({
  count: 1000,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  overscan: 5, // render 5 extra items above and below the visible range
})
```

The default value is `1`. Setting it to `0` renders only the items currently intersecting the viewport — [Inference] this maximizes performance at the cost of visible blank space during rapid scroll in most environments.

---

### What Overscan Affects

Overscan expands the render range returned by `getVirtualItems()`. It does not affect:

- `getTotalSize()` — total scrollable size is always based on all items
- Scroll position or behavior
- Item `start` offsets — positions are computed from the full item list regardless of what is rendered

```
Without overscan (overscan: 0):
  Visible indices: 10–30
  Rendered indices: 10–30

With overscan: 5:
  Visible indices: 10–30
  Rendered indices: 5–35
```

Items 5–9 and 31–35 are in the DOM, positioned correctly, but outside the visible scroll area.

---

### Overscan at Boundaries

At the start and end of the list, overscan is clamped to the available item range. The virtualizer does not render negative indices or indices beyond `count - 1`.

```
count: 100, overscan: 10

Scrolled to top — visible: 0–15
  Rendered: 0–25  (no items before 0 to buffer)

Scrolled to bottom — visible: 85–99
  Rendered: 75–99 (no items after 99 to buffer)
```

---

### Choosing an Overscan Value

There is no universally correct value. The tradeoff is between scroll smoothness and DOM node count.

| Overscan | DOM nodes | Scroll blank risk | Typical use case |
| --- | --- | --- | --- |
| 0 | Minimum | High | Benchmarking, static displays |
| 1–3 | Low | Moderate | Default for most lists |
| 5–10 | Moderate | Low | Fast-scrolling lists, variable heights |
| 15+ | High | Very low | Very fast programmatic scroll, animation |

[Inference] Higher overscan values are more beneficial when item heights vary significantly, because variable-height items cause more positional recalculation per scroll event. Behavior depends on scroll velocity, device performance, and rendering environment.

---

### Overscan in Horizontal Lists

The `overscan` option behaves identically for horizontal virtualizers — it buffers items to the left and right of the visible column range.

ts

```ts
const virtualizer = useVirtualizer({
  count: 300,
  horizontal: true,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 120,
  overscan: 3,
})
```

---

### Overscan in Grid Virtualization

In two-axis grids, each virtualizer has its own `overscan` setting applied independently.

ts

```ts
const rowVirtualizer = useVirtualizer({
  count: 5000,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 35,
  overscan: 5,
})

const columnVirtualizer = useVirtualizer({
  count: 200,
  horizontal: true,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 100,
  overscan: 2,
})
```

Total rendered cell count:

```
(visible_rows + 2 × row_overscan) × (visible_cols + 2 × col_overscan)
```

[Inference] Column overscan has a multiplicative effect on total cell count because it applies across every rendered row. Keeping column overscan lower than row overscan is generally preferable for wide grids.

---

### Diagram: Overscan Buffer Zones

Not in DOMRendered to DOMOverscan buffer — above(items before visiblerange)Visible viewport(items intersecting scrollwindow)Overscan buffer — below(items after visible range)Items far aboveItems far below

---

### Overscan and `scrollToIndex`

When `scrollToIndex` is called with `align: 'auto'`, the virtualizer scrolls the minimum amount needed to bring the target item into the visible range. Overscan does not affect the scroll target — the item is brought into the visible range, not merely into the overscan buffer.

ts

```ts
virtualizer.scrollToIndex(250, { align: 'auto' })
// scrolls until index 250 is within the visible viewport
// overscan items around 250 will also be rendered as a side effect
```

---

### Overscan and Dynamic Measurement

With `measureElement` active, overscan serves an additional function: items in the overscan range are mounted and measured before they become visible. [Inference] This means their sizes are known before the user scrolls to them, reducing the positional correction artifacts that occur when estimates are replaced by measurements mid-scroll. This is one of the strongest practical reasons to use non-zero overscan with variable-height lists.

---

### Programmatic Overscan Control

`overscan` is set at virtualizer initialization and is not a reactive option in the standard API — it cannot be changed on a per-scroll-event basis through built-in means. [Inference] Reinitializing the virtualizer with a different `overscan` value, or conditionally switching between virtualizer instances, is possible but uncommon and may cause scroll position reset. Behavior may vary.

[Speculation] A pattern of dynamically increasing overscan during programmatic fast-scroll (e.g., during `scrollToIndex` animations) is not provided by the library and would require custom scroll orchestration outside the virtualizer.

---

### Overscan vs. `rangeExtractor`

For cases where overscan's symmetric buffer is insufficient — for example, pinned rows that must always be rendered regardless of scroll position — `rangeExtractor` provides full control over which indices are included in `getVirtualItems()`.

ts

```ts
import { defaultRangeExtractor } from '@tanstack/react-virtual'

const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  overscan: 5,
  rangeExtractor: (range) => {
    // always include index 0 (e.g. a sticky header row)
    const defaultRange = defaultRangeExtractor(range)
    return defaultRange.includes(0) ? defaultRange : [0, ...defaultRange]
  },
})
```

**Key Points**

- `range` contains `{ startIndex, endIndex, overscanStartIndex, overscanEndIndex, count }`
- `overscanStartIndex` and `overscanEndIndex` already incorporate the `overscan` value
- `defaultRangeExtractor` returns the standard array of indices from `overscanStartIndex` to `overscanEndIndex`
- Returning additional indices outside this range forces those items to remain mounted

[Inference] Items added via `rangeExtractor` outside the normal overscan window will still be positioned using their computed `start` offset, so sticky behavior requires additional CSS (`position: sticky`) on top of being present in the render range. Behavior depends on implementation.

---

### `rangeExtractor` Range Object Fields

ts

```ts
type Range = {
  startIndex: number        // first visible item index
  endIndex: number          // last visible item index
  overscanStartIndex: number // startIndex - overscan (clamped to 0)
  overscanEndIndex: number   // endIndex + overscan (clamped to count - 1)
  count: number             // total item count
}
```

---

### Common Pitfalls

**Setting overscan too high on grids** — in grid layouts, overscan multiplies across both axes. An overscan of 10 on both row and column virtualizers in a grid rendering 20 visible rows × 8 visible columns yields `(20 + 20) × (8 + 20)` = `1120 cells` instead of `160`. Monitor actual DOM node counts.

**Expecting overscan to eliminate all blank flicker** — overscan reduces blank space during normal scroll velocity. At high scroll velocities (e.g., trackpad momentum, touch fling), the browser may scroll faster than React can commit new renders. Overscan mitigates this but cannot fully prevent it. [Inference] Behavior depends on device scroll velocity, React render throughput, and scheduler behavior.

**Using overscan as a substitute for `rangeExtractor`** — overscan is symmetric and index-range-based. Items that must always be rendered (sticky headers, pinned rows) need `rangeExtractor`, not high overscan values.

---

**Related Topics**

- `rangeExtractor` for custom render ranges and sticky items
- Sticky headers and pinned rows with `rangeExtractor`
- Scroll performance profiling with React DevTools
- `scrollToIndex` alignment options (`start`, `center`, `end`, `auto`)
- Overscan interaction with dynamic measurement and `measureElement`
- Grid overscan and cell count budgeting