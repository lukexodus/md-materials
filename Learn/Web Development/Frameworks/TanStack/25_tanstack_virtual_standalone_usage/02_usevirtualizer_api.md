## useVirtualizer API

`useVirtualizer` is the React adapter hook for TanStack Virtual. It wraps the core `Virtualizer` class and returns a virtualizer instance bound to React's rendering lifecycle. All configuration, measurement, and scroll observation is managed through this single hook.

---

### Installation

bash

```bash
npm install @tanstack/react-virtual
```

ts

```ts
import { useVirtualizer } from '@tanstack/react-virtual';
```

---

### Minimal Setup

tsx

```tsx
import { useRef } from 'react';
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }: { items: string[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 40, // estimated row height in px
  });

  return (
    <div ref={parentRef} style={{ height: '400px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize(), position: 'relative' }}>
        {virtualizer.getVirtualItems().map((virtualItem) => (
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
            {items[virtualItem.index]}
          </div>
        ))}
      </div>
    </div>
  );
}
```

**Key Points**

- `parentRef` must be attached to the scroll container element, not a wrapper outside it
- The inner div sized to `getTotalSize()` creates the full scrollable height so the scrollbar is accurate
- `transform: translateY` is preferred over `top` for positioning because it avoids layout recalculation in most browsers [Inference: performance characteristics may vary by browser and GPU compositing behavior]
- `position: absolute` on each virtual item and `position: relative` on the inner container are required for offset-based placement

---

### Core Options

#### Required

| Option | Type | Description |
| --- | --- | --- |
| `count` | `number` | Total number of items in the full dataset |
| `getScrollElement` | `() => Element | null` | Returns the scrollable container DOM element |
| `estimateSize` | `(index: number) => number` | Returns estimated size in px per item index |

#### Commonly Used

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `overscan` | `number` | `1` | Number of items to render beyond the visible boundary on each side |
| `horizontal` | `boolean` | `false` | Virtualizes along the horizontal axis instead of vertical |
| `paddingStart` | `number` | `0` | Pixel padding at the start of the scroll container |
| `paddingEnd` | `number` | `0` | Pixel padding at the end of the scroll container |
| `scrollPaddingStart` | `number` | `0` | Offset applied when scrolling an item into view at the start edge |
| `scrollPaddingEnd` | `number` | `0` | Offset applied when scrolling an item into view at the end edge |
| `initialOffset` | `number` | `0` | Initial scroll offset on mount |
| `getItemKey` | `(index: number) => Key` | `(i) => i` | Returns a stable key per item index |
| `enabled` | `boolean` | `true` | Disables the virtualizer when false; all items render normally |
| `debug` | `boolean` | `false` | Logs internal measurements to the console |

#### Layout and Gap

| Option | Type | Description |
| --- | --- | --- |
| `gap` | `number` | Pixel gap between items; incorporated into offset calculations |
| `lanes` | `number` | Number of parallel lanes (columns in a masonry-style grid) |

---

### Returned Virtualizer Instance

`useVirtualizer` returns a `Virtualizer` instance. The most commonly used members are:

#### Methods

| Method | Returns | Description |
| --- | --- | --- |
| `getVirtualItems()` | `VirtualItem[]` | Items that should currently be rendered |
| `getTotalSize()` | `number` | Total pixel size of all items combined |
| `scrollToIndex(index, options?)` | `void` | Programmatically scrolls an item into view |
| `scrollToOffset(offset, options?)` | `void` | Scrolls to a specific pixel offset |
| `measureElement(el)` | `void` | Registers a DOM element for dynamic size measurement |

#### Properties

| Property | Type | Description |
| --- | --- | --- |
| `options` | `VirtualizerOptions` | The resolved options object currently in use |
| `scrollOffset` | `number` | Current scroll position in pixels |
| `scrollDirection` | `'forward' | 'backward' | null` | Direction of the most recent scroll |
| `scrollElement` | `Element | null` | The currently observed scroll element |

---

### VirtualItem Object

Each object in `getVirtualItems()` has these fields:

| Field | Type | Description |
| --- | --- | --- |
| `index` | `number` | Position in the full dataset |
| `key` | `Key` | Stable identity — use as React `key` prop |
| `size` | `number` | Measured or estimated height (or width) in px |
| `start` | `number` | Pixel offset from the container start |
| `end` | `number` | Pixel offset of the item's far edge (`start + size`) |
| `lane` | `number` | Lane index when using multi-lane layouts |

---

### Dynamic Size Measurement

When item heights are unknown before render (variable content, text wrap, images), use `measureElement` via a callback ref on each rendered item.

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 50, // initial estimate; will be corrected after measurement
});

// Inside the virtual items render:
{virtualizer.getVirtualItems().map((virtualItem) => (
  <div
    key={virtualItem.key}
    ref={virtualizer.measureElement} // ← attach measurement ref
    data-index={virtualItem.index}   // ← required for the virtualizer to identify the element
    style={{
      position: 'absolute',
      top: 0,
      left: 0,
      width: '100%',
      transform: `translateY(${virtualItem.start}px)`,
      // do NOT set height — let content determine it
    }}
  >
    {items[virtualItem.index]}
  </div>
))}
```

**Key Points**

- `data-index` is required on the measured element so the virtualizer can map the DOM node back to an item index
- Do not set a fixed `height` style on dynamically measured items — the measured height would be overridden by the style, producing incorrect results
- `measureElement` uses a `ResizeObserver` internally; items are re-measured when they resize [Inference: behavior depends on browser ResizeObserver support]
- After measurement, `estimateSize` values are replaced by real measurements; the estimates only affect layout before first render

---

### `scrollToIndex`

ts

```ts
virtualizer.scrollToIndex(500);

// With alignment options:
virtualizer.scrollToIndex(500, { align: 'start' });
virtualizer.scrollToIndex(500, { align: 'center' });
virtualizer.scrollToIndex(500, { align: 'end' });
virtualizer.scrollToIndex(500, { align: 'auto' }); // scrolls minimally to bring item into view
```

**Key Points**

- `align: 'auto'` is the default and only scrolls if the item is not already visible
- For items beyond the current render window (not yet measured), scroll accuracy depends on `estimateSize` correctness [Inference]
- `behavior: 'smooth'` can be passed as a second-level option but support depends on the scroll container and browser

---

### Horizontal Virtualization

tsx

```tsx
const virtualizer = useVirtualizer({
  count: columns.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 120,
  horizontal: true,
});

// Position items with translateX instead of translateY:
{virtualizer.getVirtualItems().map((virtualItem) => (
  <div
    key={virtualItem.key}
    style={{
      position: 'absolute',
      top: 0,
      left: 0,
      height: '100%',
      width: `${virtualItem.size}px`,
      transform: `translateX(${virtualItem.start}px)`,
    }}
  >
    {columns[virtualItem.index].label}
  </div>
))}
```

---

### Grid Virtualization

Two virtualizer instances — one for rows, one for columns — are composed manually.

tsx

```tsx
const rowVirtualizer = useVirtualizer({
  count: rows.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
});

const columnVirtualizer = useVirtualizer({
  count: columns.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 120,
  horizontal: true,
});

// Render each (row, column) intersection:
{rowVirtualizer.getVirtualItems().map((virtualRow) =>
  columnVirtualizer.getVirtualItems().map((virtualColumn) => (
    <div
      key={`${virtualRow.key}-${virtualColumn.key}`}
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        width: `${virtualColumn.size}px`,
        height: `${virtualRow.size}px`,
        transform: `translateX(${virtualColumn.start}px) translateY(${virtualRow.start}px)`,
      }}
    >
      {rows[virtualRow.index][columns[virtualColumn.index].key]}
    </div>
  ))
)}
```

---

### Window Scrolling

When the page itself scrolls (no inner scroll container), use `useWindowVirtualizer` instead of `useVirtualizer`.

tsx

```tsx
import { useWindowVirtualizer } from '@tanstack/react-virtual';

const virtualizer = useWindowVirtualizer({
  count: items.length,
  estimateSize: () => 40,
  scrollMargin: listRef.current?.offsetTop ?? 0,
});
```

**Key Points**

- No `getScrollElement` option — the window is the scroll target
- `scrollMargin` offsets the virtualizer by the container's distance from the top of the page; required for correct item positioning when the list does not start at `y=0`
- `useWindowVirtualizer` is not suitable when the scrollable region is a fixed-height element inside the page

---

### `getItemKey` for Stable Identity

By default, items are keyed by index. When rows can be reordered or filtered, provide a stable key function:

tsx

```tsx
const virtualizer = useVirtualizer({
  count: rows.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  getItemKey: (index) => rows[index].id, // stable ID from data
});
```

**Key Points**

- Stable keys allow React to correctly reconcile components when list order changes
- Mismatched keys between renders can cause measurement data to be applied to the wrong item [Inference]

---

### Overscan Tuning

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  overscan: 10, // render 10 extra items beyond viewport on each edge
});
```

**Key Points**

- Higher overscan values reduce blank-row flicker during fast scrolling at the cost of rendering more DOM nodes
- Lower overscan values minimize DOM node count but may show unmeasured gaps on rapid scroll [Inference]
- The right value depends on item render cost and expected scroll velocity; there is no universally optimal setting

---

### Lanes (Masonry Layout)

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 200,
  lanes: 3, // 3-column masonry
});

{virtualizer.getVirtualItems().map((virtualItem) => (
  <div
    key={virtualItem.key}
    style={{
      position: 'absolute',
      top: 0,
      left: `${(virtualItem.lane / 3) * 100}%`,
      width: `${100 / 3}%`,
      transform: `translateY(${virtualItem.start}px)`,
      height: `${virtualItem.size}px`,
    }}
  >
    {items[virtualItem.index]}
  </div>
))}
```

**Key Points**

- `virtualItem.lane` is a zero-based lane index; use it to compute horizontal position
- Items are distributed across lanes to balance total column height [Inference: exact distribution algorithm may vary across versions]
- Dynamic measurement works with lanes; each item's height is measured independently per lane

---

### Observing Scroll Events

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  onChange: (instance) => {
    console.log('scroll offset:', instance.scrollOffset);
    console.log('virtual items:', instance.getVirtualItems());
  },
});
```

**Key Points**

- `onChange` fires on every virtualizer state update, including scroll events and measurement changes
- Avoid heavy computation inside `onChange`; prefer deriving values from the returned instance during render

---

### Full API Option Reference

ts

```ts
useVirtualizer({
  // Required
  count: number,
  getScrollElement: () => Element | null,
  estimateSize: (index: number) => number,

  // Rendering
  overscan?: number,
  horizontal?: boolean,
  paddingStart?: number,
  paddingEnd?: number,
  scrollPaddingStart?: number,
  scrollPaddingEnd?: number,
  gap?: number,
  lanes?: number,
  enabled?: boolean,

  // Identity
  getItemKey?: (index: number) => Key,
  indexAttribute?: string,         // default: 'data-index'

  // Scroll behavior
  initialOffset?: number | (() => number),
  scrollToFn?: (offset, options, instance) => void,  // custom scroll implementation
  observeElementRect?: (instance, cb) => void,        // custom rect observer
  observeElementOffset?: (instance, cb) => void,      // custom offset observer

  // Measurement
  measureElement?: (el, entry, instance) => number,  // custom size measurement

  // Callbacks
  onChange?: (instance: Virtualizer, sync: boolean) => void,

  // Debug
  debug?: boolean,
});
```

---

### Relationship to `useWindowVirtualizer`

|  | `useVirtualizer` | `useWindowVirtualizer` |
| --- | --- | --- |
| Scroll target | A specific DOM element | The browser window |
| `getScrollElement` | Required | Not accepted |
| `scrollMargin` | Not needed | Required when list has top offset |
| Use case | Fixed-height scroll containers | Full-page scrolling lists |

---

**Related Topics**

- Combining `useVirtualizer` with TanStack Table row virtualization
- Dynamic measurement patterns — variable height rows
- Infinite scroll with TanStack Virtual and TanStack Query
- `useWindowVirtualizer` — full-page scroll virtualization
- Horizontal virtualization — carousel and column windowing
- Grid virtualization — composing row and column virtualizers
- Masonry layouts with `lanes`
- Custom `scrollToFn` for animated or controlled scrolling
- Angular Virtual — `injectVirtualizer` API
- Vue Virtual — `useVirtualizer` equivalent