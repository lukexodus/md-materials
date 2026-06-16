## Padding at Start and End

TanStack Virtual supports adding padding to the start and end of the virtual list's scrollable space. This padding is factored into the total scrollable size and all item offset calculations — items are pushed down (or right, for horizontal lists) by the start padding, and extra space is added after the last item for end padding.

---

### The `paddingStart` and `paddingEnd` Options

Both are numeric options passed to `useVirtualizer`, representing pixel values.

ts

```ts
const virtualizer = useVirtualizer({
  count: 1000,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  paddingStart: 16,
  paddingEnd: 16,
})
```

Both default to `0`. They are independent — either or both can be set.

---

### Effect on `getTotalSize`

`paddingStart` and `paddingEnd` are included in the value returned by `getTotalSize()`. The inner container must be sized to this total for the scroll area to be correct.

```
getTotalSize() = paddingStart + Σ itemSizes + paddingEnd
```

ts

```ts
// paddingStart: 16, paddingEnd: 16, 1000 items × 40px
virtualizer.getTotalSize() // → 40032
```

The inner positioning div should use this value as usual:

tsx

```tsx
<div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
```

No additional manual offset is needed — the padding is already embedded in the total.

---

### Effect on Item `start` Offsets

Each virtual item's `start` property is offset by `paddingStart`. The first item begins at `paddingStart`, not at `0`.

```
item[0].start = paddingStart
item[1].start = paddingStart + item[0].size
item[n].start = paddingStart + Σ item[0..n-1].size
```

Because `start` already includes the padding offset, the standard absolute positioning pattern requires no modification:

tsx

```tsx
<div
  style={{
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
    transform: `translateY(${virtualItem.start}px)`,
  }}
>
```

---

### Diagram: Padding in the Virtual Space

Scrollable inner container (getTotalSize)paddingStart(empty space)item 0start = paddingStartitem 1...item npaddingEnd(empty space)

---

### Use Cases

**Scroll container inset padding** — when the scroll container has `padding` applied via CSS, the virtual items may misalign with the padding. Using `paddingStart`/`paddingEnd` in the virtualizer matches the logical item space to the visual container inset.

**Fixed header clearance** — if a sticky header overlays the scroll container, `paddingStart` reserves space so the first item is not obscured on initial render.

**List decorations** — space for a non-virtualized element rendered above or below the item list (e.g., a load-more button, a summary row, a banner) can be reserved with padding rather than inserting a fake item.

**Pull-to-refresh affordance** — [Inference] `paddingStart` can reserve vertical space for a pull indicator element rendered above the list without affecting item indices or offset calculations.

---

### Padding vs. a Dedicated Spacer Item

An alternative to `paddingStart`/`paddingEnd` is inserting a zero-index spacer item into your data with a fixed size. The padding options are preferable because:

- They do not affect `count` or item indices
- They do not require filtering spacer items out of data callbacks
- They are reflected correctly in `scrollToIndex` — the virtualizer accounts for padding when computing scroll targets

---

### Padding with `scrollToIndex`

`scrollToIndex` correctly accounts for `paddingStart`. Scrolling to index `0` with `align: 'start'` positions the scroll container such that `item[0]` is at the top of the visible area — the padding space above it scrolls out of view as expected.

ts

```ts
virtualizer.scrollToIndex(0, { align: 'start' })
// scrolls to paddingStart offset, not to 0
```

[Inference] This means the padding space is accessible by scrolling above the first item, consistent with standard list padding behavior. Behavior may vary with different `align` values and browser scroll implementations.

---

### Padding in Horizontal Lists

`paddingStart` and `paddingEnd` apply to the horizontal axis when `horizontal: true` is set. `paddingStart` adds space before the first column; `paddingEnd` adds space after the last column.

ts

```ts
const virtualizer = useVirtualizer({
  count: 200,
  horizontal: true,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 120,
  paddingStart: 24,
  paddingEnd: 24,
})
```

Item `start` values reflect the horizontal offset including `paddingStart`, so `translateX(${virtualItem.start}px)` remains correct without adjustment.

---

### Padding in Grid Virtualization

In two-axis grids, padding is set per virtualizer and applies to its respective axis.

ts

```ts
const rowVirtualizer = useVirtualizer({
  count: 5000,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 35,
  paddingStart: 8,   // space above row 0
  paddingEnd: 8,     // space below last row
})

const columnVirtualizer = useVirtualizer({
  count: 200,
  horizontal: true,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 100,
  paddingStart: 12,  // space left of column 0
  paddingEnd: 12,    // space right of last column
})
```

Row and column `start` values already include their respective padding, so cell positioning via `translateX` + `translateY` requires no change.

---

### Padding and `measureElement`

`paddingStart` does not interfere with DOM measurement. `measureElement` reads `offsetHeight` or `offsetWidth` from the item element itself — the padding offset is in the `start` value, not in the element's size. Measured sizes and padding are orthogonal.

---

### Scroll Container CSS Padding vs. Virtualizer Padding

A common source of misalignment is applying CSS `padding` to the scroll container element while also expecting virtualizer offsets to match. CSS padding on the scroll container affects the visual inset but does not affect `scrollTop` or `scrollLeft` values, which the virtualizer reads directly.

[Inference] Using CSS `padding-top` on the scroll container and also setting `paddingStart` in the virtualizer will double the visual offset for the first item in most layouts. Choose one approach:

- **CSS padding only** — visually correct but virtualizer offsets will not account for it; items may misalign with measured positions
- **Virtualizer `paddingStart` only** — offsets are correct; use `margin` or a wrapper element for any visual inset on the container itself

---

### Common Pitfalls

**Double padding from CSS + virtualizer** — applying both CSS `padding` on the scroll container and `paddingStart`/`paddingEnd` on the virtualizer produces additive offset. Use one or the other per axis.

**Forgetting padding in total size** — `getTotalSize()` includes padding automatically; manually adding padding to the inner container height produces extra blank space at the end.

**Padding not needed for gaps between items** — `paddingStart`/`paddingEnd` applies only to the outer edges of the list. For space between items, use CSS `gap` equivalent via margins on items or factor the gap into `estimateSize`.

---

**Related Topics**

- `scrollMargin` option for scroll containers with offset origins
- Gap between items via `estimateSize` and CSS margin patterns
- Sticky headers interacting with `paddingStart`
- `rangeExtractor` for always-rendered header items above the padded space
- `scrollToIndex` alignment and padding interaction
- Padding with infinite scroll and prepended items