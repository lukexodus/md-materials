## TanStack Virtual — Sticky Items

TanStack Virtual does not have a built-in `sticky` API. Sticky item behavior is implemented manually by combining virtualizer position data with CSS `position: sticky` or by always including certain items in the rendered output regardless of scroll position. Understanding both approaches — and their tradeoffs — is essential for building correct sticky implementations.

---

### What "Sticky" Means in a Virtualized List

In a non-virtualized list, `position: sticky` works automatically — the browser tracks the element's natural position in the document flow. In a virtualized list, items are absolutely positioned and only rendered when in or near the viewport. This breaks native sticky behavior because:

- An item that is sticky must exist in the DOM to be visible while sticky
- Absolutely positioned items do not participate in normal document flow, so `position: sticky` has no anchor to work from

Two main strategies address this:

1. **Always-rendered sticky items** — Keep sticky items in the DOM unconditionally, positioned with CSS
2. **Index-based sticky injection** — Detect which sticky item should currently be active and inject it as an overlay

---

### Strategy 1 — Always-Rendered Sticky Header (CSS Sticky)

This approach works when your scroll container uses a **flex or block layout** rather than absolute positioning for all items. It is the simplest strategy but requires a different rendering approach than the standard absolute-position pattern.

> [Inference] This strategy is most applicable when you control the layout and can avoid absolute positioning for the sticky elements specifically. It may conflict with the standard `position: absolute` + `translateY` pattern if not structured carefully.

**Example — Sticky section headers with grouped data:**

tsx

```tsx
import { useVirtualizer } from '@tanstack/react-virtual';
import { useRef } from 'react';

const rows = Array.from({ length: 1000 }, (_, i) => ({
  id: i,
  group: Math.floor(i / 20),
  label: `Item ${i}`,
}));

function StickyHeaderList() {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: rows.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 40,
  });

  return (
    <div ref={parentRef} style={{ height: '500px', overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map((virtualItem) => {
          const row = rows[virtualItem.index];
          const isFirstInGroup = virtualItem.index === 0 ||
            rows[virtualItem.index - 1].group !== row.group;

          return (
            <div
              key={virtualItem.key}
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: '100%',
                height: `${virtualItem.size}px`,
                transform: `translateY(${virtualItem.start}px)`,
              }}
            >
              {isFirstInGroup && (
                <div style={{
                  background: '#e0e0e0',
                  fontWeight: 'bold',
                  padding: '4px 8px',
                }}>
                  Group {row.group}
                </div>
              )}
              <div style={{ padding: '4px 8px' }}>{row.label}</div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
```

**Key Points:**

- Group headers are rendered inline within each virtual item row
- This renders group headers only when their associated row is in the viewport — the header is not truly sticky
- This pattern is a starting point; true sticky behavior requires the overlay approach below

---

### Strategy 2 — Sticky Overlay (Recommended for True Stickiness)

This is the most reliable pattern for true sticky behavior in a virtualized list. A separate, always-rendered element is positioned at the top of the scroll container using `position: sticky`. Its content is updated based on which group or section is currently at or above the viewport.

The key insight is: **the sticky element lives outside the virtualized item list entirely**.

**Example:**

tsx

```tsx
import { useVirtualizer } from '@tanstack/react-virtual';
import { useRef, useState } from 'react';

const ITEMS_PER_GROUP = 20;
const TOTAL_ITEMS = 1000;

const rows = Array.from({ length: TOTAL_ITEMS }, (_, i) => ({
  id: i,
  group: Math.floor(i / ITEMS_PER_GROUP),
  label: `Item ${i}`,
}));

function StickyOverlayList() {
  const parentRef = useRef<HTMLDivElement>(null);
  const [stickyGroup, setStickyGroup] = useState(0);

  const virtualizer = useVirtualizer({
    count: rows.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 40,
    onChange: (instance) => {
      const firstItem = instance.getVirtualItems()[0];
      if (firstItem) {
        setStickyGroup(rows[firstItem.index].group);
      }
    },
  });

  return (
    <div ref={parentRef} style={{ height: '500px', overflow: 'auto', position: 'relative' }}>
      {/* Sticky header overlay */}
      <div style={{
        position: 'sticky',
        top: 0,
        zIndex: 10,
        background: '#c8e6c9',
        fontWeight: 'bold',
        padding: '4px 8px',
      }}>
        Group {stickyGroup}
      </div>

      {/* Virtualized list */}
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map((virtualItem) => {
          const row = rows[virtualItem.index];
          return (
            <div
              key={virtualItem.key}
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: '100%',
                height: `${virtualItem.size}px`,
                transform: `translateY(${virtualItem.start}px)`,
              }}
            >
              {row.label}
            </div>
          );
        })}
      </div>
    </div>
  );
}
```

**Key Points:**

- The sticky header sits above the virtualized container in the DOM, inside the scroll element
- `position: sticky` + `top: 0` keeps it pinned to the top of the scroll container as the user scrolls
- `onChange` fires when the virtualizer recalculates visible items, making it a reliable place to update the sticky label
- `zIndex` on the sticky element avoids it being obscured by absolutely positioned virtual items

---

### Using `onChange` to Track the Active Sticky Item

The `onChange` callback receives the virtualizer instance whenever visible items change. This is the correct hook for updating sticky state.

ts

```ts
const virtualizer = useVirtualizer({
  count: rows.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  onChange: (instance) => {
    const visibleItems = instance.getVirtualItems();
    if (visibleItems.length === 0) return;

    const firstVisibleIndex = visibleItems[0].index;
    const activeGroup = rows[firstVisibleIndex].group;
    setStickyGroup(activeGroup);
  },
});
```

**Key Points:**

- `getVirtualItems()` returns items currently rendered (including overscan items)
- The first visible item's group determines the sticky label
- This fires on every scroll update — keep the callback lightweight to avoid performance issues [Inference — heavy state updates inside `onChange` may cause rendering overhead; behavior is environment-dependent]

---

### Accounting for Sticky Header Height

When a sticky header occupies vertical space, it can obscure the top virtual items. You must account for its height in two places:

**1. `scrollMargin` or `scrollPaddingStart`**

Some versions of TanStack Virtual expose a `scrollPaddingStart` option that offsets scroll calculations by the height of the sticky element:

ts

```ts
const virtualizer = useVirtualizer({
  count: rows.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  scrollPaddingStart: 32, // height of the sticky header in px
});
```

> [Inference] Option name and availability may differ by version. Check your version's API reference for the correct option name.

**2. CSS `scroll-padding-top` on the container**

css

```css
.scroll-container {
  scroll-padding-top: 32px;
}
```

This affects native browser scroll behavior (e.g., when `scrollToIndex` is used) and does not directly affect virtualizer calculations.

---

### Sticky Items in Both Axes (Horizontal + Vertical)

For two-dimensional virtualization or horizontal lists, the same overlay strategy applies — the sticky element is pinned with `position: sticky` on the relevant axis (`left: 0` for horizontal stickiness).

> [Inference] Two-dimensional sticky (e.g., frozen row + frozen column simultaneously) is significantly more complex and is not directly supported by TanStack Virtual's current API. Custom layout logic would be required.

---

### Visual: Sticky Overlay Architecture

Updates label on scrollScroll Container —overflow: autoSticky Header Div —position: sticky, top: 0Virtual List Wrapper —position: relative, height:getTotalSizeVirtual Item 0 — position:absoluteVirtual Item 1 — position:absoluteVirtual Item N — position:absoluteonChange callback readsfirst visible item

---

### Common Mistakes

**1. Applying `position: sticky` directly to a virtual item**

Virtual items use `position: absolute` and are only rendered when in the viewport. A sticky item that scrolls out of the viewport is unmounted and disappears — it cannot remain stuck.

**2. Forgetting `position: relative` on the scroll container**

The sticky element needs a positioned ancestor. Without `position: relative` on the scroll container, `position: sticky` may behave unexpectedly.

**3. Not accounting for sticky header height in scroll calculations**

If `scrollToIndex` lands on an item that is partially hidden behind a sticky header, the item appears cut off. Use `scrollPaddingStart` or equivalent to compensate.

**4. Heavy computation inside `onChange`**

`onChange` fires on every scroll tick. Expensive operations (e.g., filtering large arrays, complex DOM reads) inside it can degrade scroll performance. [Inference — actual performance impact depends on list size, render cost, and device; not guaranteed to be perceptible in all cases]

---

**Related Topics:**

- `onChange` callback — reacting to virtualizer state changes
- `scrollPaddingStart` / `scrollPaddingEnd` — offset options for sticky UI chrome
- `overscan` — ensuring sticky-adjacent items render correctly near boundaries
- Grouped list data patterns — structuring data for section headers
- Horizontal sticky columns in virtualized tables
- TanStack Table + TanStack Virtual — frozen/sticky column implementation
- `scrollToIndex` with sticky headers — offset compensation patterns