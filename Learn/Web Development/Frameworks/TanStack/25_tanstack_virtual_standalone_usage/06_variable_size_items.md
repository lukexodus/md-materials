## Variable Size Items

By default, TanStack Virtual assumes uniform item sizes via a constant `estimateSize` return value. Variable size virtualization handles items whose dimensions differ — either known ahead of time or measured dynamically from the DOM after render.

---

### Two Approaches to Variable Sizes

There are two distinct strategies:

1. **Known sizes** — you have the size of every item in advance (from data, metadata, or precomputation). Pass them directly through `estimateSize`.
2. **Measured sizes** — item sizes are unknown until rendered. The virtualizer renders items with estimated sizes, measures them via `measureElement`, and updates its internal size cache.

These can be combined: provide a best-guess estimate, then let measurement correct it.

---

### Known Sizes via `estimateSize`

`estimateSize` receives the item index and returns a number. Returning different values per index is all that is needed for known variable sizes.

ts

```ts
const heights = [35, 80, 50, 120, 35, 60, 200, 35, 90, 45]

const virtualizer = useVirtualizer({
  count: heights.length,
  getScrollElement: () => parentRef.current,
  estimateSize: (index) => heights[index] ?? 35,
})
```

**Key Points**

- `estimateSize` is called for every index during size computation
- If actual rendered size matches the estimate exactly, no re-measurement is needed
- If sizes come from an async source (e.g., fetched row metadata), the virtualizer will recompute when `estimateSize` changes identity — [Inference] wrapping in `useCallback` with correct dependencies avoids unnecessary recomputation, though behavior may vary

---

### Dynamic Measurement with `measureElement`

When sizes cannot be known in advance, `measureElement` reads the DOM node's dimensions after render and stores the result in the virtualizer's size cache. This is the standard approach for content-driven heights (e.g., text that wraps, embedded images, expandable rows).

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 50, // initial guess before measurement
})

return (
  <div ref={parentRef} style={{ height: '500px', overflow: 'auto' }}>
    <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
      {virtualizer.getVirtualItems().map((virtualItem) => (
        <div
          key={virtualItem.key}
          ref={virtualizer.measureElement}  // ← attaches measurement
          data-index={virtualItem.index}    // ← required for index lookup
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width: '100%',
            transform: `translateY(${virtualItem.start}px)`,
          }}
        >
          {items[virtualItem.index].content}
        </div>
      ))}
    </div>
  </div>
)
```

**Key Points**

- `data-index` is mandatory — `measureElement` uses it to identify which item is being measured
- The `ref` callback fires after mount and after updates; the virtualizer reads `offsetHeight` (or `offsetWidth` for horizontal) from the element
- Height is not set explicitly on the item — the content determines it, and the virtualizer reads the result

---

### How `measureElement` Works Internally

When a ref is attached via `measureElement`, TanStack Virtual:

1. Reads the element's `offsetHeight` (vertical) or `offsetWidth` (horizontal)
2. Looks up the item index from `data-index`
3. Stores the measured size in an internal map keyed by index
4. Triggers a re-render with updated `start` offsets for all subsequent items

[Inference] This process happens synchronously within a React layout effect or equivalent, so the visual jump from estimate to measured size is typically imperceptible for items near the top. Items far down the list may have accumulated offset error from upstream estimates — this corrects as the user scrolls. Behavior may vary.

---

### Size Caching and `getTotalSize` Accuracy

`getTotalSize()` returns the sum of all item sizes. For unmeasured items, it uses the estimate. As more items are measured, the total becomes more accurate.

```
totalSize = Σ measuredSize[i]  (for measured items)
          + Σ estimateSize(i)  (for unmeasured items)
```

This means the scrollbar thumb position may shift during initial scroll — a known and expected side effect of deferred measurement. Providing accurate estimates reduces this effect.

---

### Diagram: Estimate → Measure → Correct Cycle

Size CacheDOMVirtualizerSize CacheDOMVirtualizerRender item with estimateSize(index)measureElement callback firesRead offsetHeight from elementStore measured size for indexRecompute start offsets for subsequent itemsRe-render with corrected positions

---

### Custom `measureElement` Function

Instead of the built-in ref-based measurement, you can supply a custom `measureElement` option to the virtualizer config. This is useful when you need to measure something other than `offsetHeight`, such as `getBoundingClientRect` values or custom logic.

ts

```ts
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 50,
  measureElement: (element) => {
    // element is the DOM node
    return element.getBoundingClientRect().height
  },
})
```

[Inference] `getBoundingClientRect` includes subpixel precision and CSS transforms, whereas `offsetHeight` is rounded to integer pixels and ignores transforms. Which is appropriate depends on your layout. Behavior of the virtualizer with subpixel sizes may vary.

---

### `estimateSize` as a Fallback and Hint

Even when using `measureElement`, `estimateSize` remains important:

- It determines the initial render position before measurement occurs
- It is used for all items not yet scrolled into view (and therefore never measured)
- A poor estimate causes large positional corrections as the user scrolls

**Example** — content with predictable size ranges:

ts

```ts
estimateSize: (index) => {
  const item = items[index]
  if (item.type === 'header') return 60
  if (item.type === 'paragraph') return 80
  if (item.type === 'code') return 200
  return 50
},
```

Type-aware estimates reduce visible layout shift even before DOM measurement completes.

---

### Resizing and Re-measurement

If an item's content changes after initial measurement (e.g., an expandable row is toggled), the stored size in the cache becomes stale. Two approaches handle this:

**Option 1 — Reset specific item measurement:**

ts

```ts
virtualizer.resizeItem(index, newSize)
```

This directly sets the cached size for an index without requiring a DOM measurement. [Inference] Useful when you know the new size programmatically (e.g., from a toggle state). Behavior may vary.

**Option 2 — Force re-measure via key change:**

Changing `virtualItem.key` causes React to unmount and remount the element, triggering `measureElement` again:

tsx

```tsx
<div
  key={`${virtualItem.key}-${item.expanded}`}  // key changes on expand
  ref={virtualizer.measureElement}
  data-index={virtualItem.index}
>
```

[Inference] This is a heavier operation than `resizeItem` but produces accurate DOM-measured sizes. Avoid using it for high-frequency size changes.

---

### ResizeObserver Integration

For items that resize independently of scroll (e.g., images loading, dynamic content injected after mount), `measureElement` alone fires only on mount. Pairing with `ResizeObserver` covers post-mount size changes:

tsx

```tsx
const itemRef = useCallback(
  (node: HTMLElement | null) => {
    if (!node) return

    // initial measurement
    virtualizer.measureElement(node)

    // observe future size changes
    const observer = new ResizeObserver(() => {
      virtualizer.measureElement(node)
    })
    observer.observe(node)

    return () => observer.disconnect()
  },
  [virtualizer]
)

// in JSX:
<div ref={itemRef} data-index={virtualItem.index} style={...}>
```

[Inference] Calling `measureElement` from a `ResizeObserver` callback re-reads `offsetHeight` and updates the size cache. This should handle image-load height changes and async content injection in most cases. Behavior may vary; verify in your target environments.

---

### Variable Sizes in Horizontal Lists

The same patterns apply to horizontal virtualizers — `measureElement` reads `offsetWidth` instead of `offsetHeight` when `horizontal: true` is set. `estimateSize` should return expected widths.

ts

```ts
const virtualizer = useVirtualizer({
  count: items.length,
  horizontal: true,
  getScrollElement: () => parentRef.current,
  estimateSize: (index) => items[index].estimatedWidth ?? 150,
})
```

---

### Variable Sizes in Grids

In two-axis grids, each virtualizer measures its own axis independently. Row heights are measured by the row virtualizer; column widths by the column virtualizer. As noted in the Grid Virtualization topic, measuring both dimensions from the same cell node simultaneously is not directly supported by the standard API. [Inference] In practice, row heights are typically the variable axis (content-driven), while column widths are often known in advance — making full two-axis dynamic measurement an uncommon requirement.

---

### Common Pitfalls

**Missing `data-index`** — `measureElement` silently fails to update the cache if `data-index` is absent or incorrect. Always verify it is set on the exact element passed to `ref`.

**Setting explicit height on measured items** — if you set `height` on the item element, `offsetHeight` will return that fixed value and measurement provides no benefit. Leave height unset for content-driven measurement.

**Stale closure over `estimateSize`** — if `estimateSize` captures stale data via closure, the virtualizer may use incorrect fallback sizes for unmeasured items. Use stable references or pass the data correctly.

**Calling `measureElement` on a wrapper instead of the content node** — if padding, margin, or border on the wrapper inflates the measured size, offsets accumulate incorrectly. Measure the element whose size reflects the true item bounds.

---

**Related Topics**

- `ResizeObserver` patterns for dynamic content (images, async injection)
- `resizeItem` and `resetItem` API for programmatic size control
- Scroll restoration with variable sizes
- Infinite scroll with variable-height items
- TanStack Virtual with windowed fixed + variable mixed lists
- Grid virtualization with variable row heights and fixed column widths