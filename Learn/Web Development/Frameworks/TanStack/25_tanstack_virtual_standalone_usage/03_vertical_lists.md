## TanStack Virtual — Standalone Usage — Vertical Lists

TanStack Virtual's most common use case is virtualizing vertical lists — long arrays of items rendered in a scrollable container where only the visible items are mounted in the DOM. This section covers the complete setup, configuration, and behavioral details of vertical list virtualization using the standalone `@tanstack/virtual-core` package or framework adapters like `@tanstack/react-virtual`.

---

### What Is a Vertical List

A vertical list is a single-column, top-to-bottom scrollable list of items. Without virtualization, rendering thousands of items causes significant DOM bloat and layout thrashing. TanStack Virtual solves this by calculating which items fall within (or near) the visible viewport and rendering only those.

---

### Core Concepts Specific to Vertical Lists

Before writing code, understanding the underlying model helps avoid common mistakes.

#### Scroll Axis

Vertical lists scroll along the **Y axis**. This is the default orientation for `createVirtualizer`, so no explicit axis configuration is needed unless you are overriding a shared configuration.

#### Item Size

Each item has a size measured in **pixels along the scroll axis** — for vertical lists, this is the item's **height**. TanStack Virtual needs this value to calculate total scroll height and item positions.

#### Total Scroll Size

The virtualizer computes a **total scroll size** — the height the scroll container would need if all items were rendered. This value is applied to an inner wrapper element so the scrollbar accurately represents the full list length.

#### Virtual Items

At any point in time, the virtualizer exposes a subset of items called **virtual items**. Each virtual item contains:

- `index` — the original array index
- `start` — the pixel offset from the top of the list
- `size` — the measured or estimated height of the item
- `key` — a stable key for React reconciliation or DOM keying

---

### Installation

bash

```bash
# React
npm install @tanstack/react-virtual

# Vue
npm install @tanstack/vue-virtual

# Solid
npm install @tanstack/solid-virtual

# Svelte
npm install @tanstack/svelte-virtual

# Vanilla JS (core only)
npm install @tanstack/virtual-core
```

---

### Minimal Vertical List — React

This is the smallest working example of a virtualized vertical list using `@tanstack/react-virtual`.

tsx

```tsx
import { useRef } from 'react'
import { useVirtualizer } from '@tanstack/react-virtual'

const items = Array.from({ length: 10_000 }, (_, i) => `Item ${i + 1}`)

export function VerticalList() {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 40,
  })

  return (
    <div
      ref={parentRef}
      style={{ height: '500px', overflowY: 'auto' }}
    >
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
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
  )
}
```

**Key Points:**

- The **outer `div`** (`parentRef`) is the scroll container. It must have a fixed height and `overflowY: auto` or `scroll`.
- The **inner `div`** expands to `getTotalSize()` pixels, creating the full scrollbar range.
- Each **virtual item** is absolutely positioned using `transform: translateY(start)` for GPU-accelerated placement.
- `estimateSize: () => 40` tells the virtualizer each item is approximately 40px tall.

---

### Required Configuration Options

| Option | Type | Purpose |
| --- | --- | --- |
| `count` | `number` | Total number of items in the list |
| `getScrollElement` | `() => HTMLElement | null` | Returns the scrollable container |
| `estimateSize` | `(index: number) => number` | Returns estimated pixel height per item |

---

### Positioning Strategy — Absolute vs Transform

TanStack Virtual supports two positioning approaches. The default (and recommended) approach uses `position: absolute` with `transform: translateY(start)`.

#### Why `transform` Over `top`

Using `transform: translateY` instead of `top: start` avoids triggering full layout recalculations on scroll. `transform` is composited on the GPU in most browsers, making scroll performance smoother — especially important for large lists.

tsx

```tsx
// Preferred
transform: `translateY(${virtualItem.start}px)`

// Acceptable but may cause more repaints
top: `${virtualItem.start}px`
```

[Inference] The performance difference may be negligible on simple lists but becomes measurable with complex item content or animations.

---

### The Scroll Container

The scroll container is the element that actually scrolls. It has strict requirements:

- Must have a **defined height** (fixed `px`, `vh`, or `flex`-constrained)
- Must have `overflow-y: auto` or `overflow-y: scroll`
- Must be a **block-level element**
- `getScrollElement` must return this element — typically via a `ref`

tsx

```tsx
// Correct: fixed height, overflow set
<div ref={parentRef} style={{ height: '600px', overflowY: 'auto' }}>

// Incorrect: no height — virtualizer cannot determine visible range
<div ref={parentRef} style={{ overflowY: 'auto' }}>
```

#### Using the Window as Scroll Container

If the page itself scrolls (no inner scroll container), pass `null` to `getScrollElement` and enable `useWindowScroll`:

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => null,
  estimateSize: () => 40,
  useWindowScroll: true, // [Unverified: confirm API name in current version]
})
```

> **Note:** Window-level scrolling has a different configuration path. Consult the TanStack Virtual docs for the current window scroll API, as behavior may vary across versions.

---

### The Inner Wrapper Element

The inner wrapper must stretch to the full virtual height so the scrollbar is accurate. It must be `position: relative` so that absolutely positioned children resolve offsets correctly.

tsx

```tsx
<div
  style={{
    height: `${virtualizer.getTotalSize()}px`,
    position: 'relative',
  }}
>
  {/* virtual items rendered here */}
</div>
```

If `position: relative` is omitted, child items with `position: absolute` will escape to the nearest positioned ancestor, breaking layout.

---

### Fixed-Height Items

When all items share the same height, configuration is straightforward. The `estimateSize` callback always returns the same value, and no dynamic measurement is needed.

tsx

```tsx
const virtualizer = useVirtualizer({
  count: 50_000,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 48, // every item is exactly 48px
})
```

**Key Points:**

- The virtualizer treats this as exact, not estimated, because there is no measurement step involved.
- Total scroll height = `count × itemHeight`, computed immediately.
- This is the most performant configuration for vertical lists.

---

### Variable-Height Items

When items have different heights, `estimateSize` should return a per-index estimate. The virtualizer initially uses these estimates and then **measures actual rendered heights** using a `ResizeObserver` internally.

tsx

```tsx
const virtualizer = useVirtualizer({
  count: posts.length,
  getScrollElement: () => parentRef.current,
  estimateSize: (index) => {
    // Provide a rough estimate based on known data
    return posts[index].isExpanded ? 200 : 60
  },
})
```

To trigger actual measurement, attach the virtualizer's `measureElement` callback to each item's DOM node:

tsx

```tsx
{virtualizer.getVirtualItems().map((virtualItem) => (
  <div
    key={virtualItem.key}
    ref={virtualizer.measureElement}
    data-index={virtualItem.index}
    style={{
      position: 'absolute',
      top: 0,
      left: 0,
      width: '100%',
      transform: `translateY(${virtualItem.start}px)`,
    }}
  >
    {posts[virtualItem.index].content}
  </div>
))}
```

**Key Points:**

- `data-index` is required — the virtualizer reads this attribute from the DOM node to know which item was measured.
- `measureElement` must be the `ref` — not called manually.
- After measurement, `virtualItem.size` reflects the actual height, and `start` offsets are recalculated.
- Do **not** set a fixed `height` style on measured items — this prevents the ResizeObserver from reading natural height.

---

### Overscan

Overscan controls how many items **outside the visible range** are rendered. A small overscan value reduces the chance of blank flashes during fast scrolling.

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  overscan: 5, // render 5 extra items above and below the visible window
})
```

**Key Points:**

- Default overscan is typically `1` (behavior may vary by version).
- Higher overscan = smoother scrolling, more DOM nodes.
- For most use cases, `3`–`10` is a reasonable range.
- Overscan items are rendered but may be outside the visible viewport.

---

### Scroll to Index

The virtualizer exposes `scrollToIndex` to programmatically scroll to any item.

tsx

```tsx
// Scroll to item at index 500
virtualizer.scrollToIndex(500)

// With alignment options
virtualizer.scrollToIndex(500, { align: 'start' })   // item at top of viewport
virtualizer.scrollToIndex(500, { align: 'center' })  // item centered in viewport
virtualizer.scrollToIndex(500, { align: 'end' })     // item at bottom of viewport
virtualizer.scrollToIndex(500, { align: 'auto' })    // minimal scroll (default)
```

**Example** — jump to a specific item on button click:

tsx

```tsx
<button onClick={() => virtualizer.scrollToIndex(999)}>
  Jump to item 1000
</button>
```

**Key Points:**

- For items not yet rendered (outside overscan), the virtualizer uses the estimated size to compute the scroll position. If estimates are inaccurate, the final position may be slightly off — the virtualizer self-corrects after rendering and measuring.
- [Inference] Animating the scroll behavior requires passing `behavior: 'smooth'` via `scrollToOffset` rather than `scrollToIndex`, as the latter may not expose smooth scrolling directly in all versions.

---

### Scroll to Offset

For pixel-precise scrolling:

tsx

```tsx
virtualizer.scrollToOffset(2000) // scroll to 2000px from the top

virtualizer.scrollToOffset(2000, { align: 'start' })
```

---

### Initial Scroll Offset

To start the list pre-scrolled to a position:

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  initialOffset: 1600, // start 1600px down
})
```

---

### Keys and Reconciliation

Each virtual item has a `key` property. In React, this must be passed to the rendered element's `key` prop — not the index — to allow correct reconciliation as items scroll in and out.

tsx

```tsx
// Correct
<div key={virtualItem.key} ...>

// Incorrect — can cause identity bugs during fast scrolls
<div key={virtualItem.index} ...>
```

By default, `virtualItem.key` equals `virtualItem.index`. You can customize key generation:

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  getItemKey: (index) => items[index].id, // use stable entity IDs
})
```

---

### Padding the List

To add padding at the top or bottom of the virtual list without breaking offset calculations:

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  paddingStart: 16, // 16px of space before the first item
  paddingEnd: 16,   // 16px of space after the last item
})
```

Using CSS padding on the inner wrapper instead can break `start` offset calculations — prefer the virtualizer's built-in padding options.

---

### Lane Gaps (Gap Between Items)

TanStack Virtual v3+ supports a `gap` option to add uniform spacing between items:

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 40,
  gap: 8, // 8px gap between each item
})
```

**Key Points:**

- The gap is factored into `start` offset calculations automatically.
- Do not add `margin-bottom` to individual items as a substitute — this can cause measurement and offset errors, especially with `measureElement`.

---

### Complete Annotated Example — Variable Height with Measurement

tsx

```tsx
import { useRef } from 'react'
import { useVirtualizer } from '@tanstack/react-virtual'

const posts = Array.from({ length: 5000 }, (_, i) => ({
  id: `post-${i}`,
  content: `Post ${i + 1}: ${'Lorem ipsum '.repeat(Math.floor(Math.random() * 5) + 1)}`,
}))

export function VariableHeightList() {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: posts.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 60,       // rough estimate; actual size measured after render
    overscan: 5,
    gap: 8,
    getItemKey: (index) => posts[index].id,
  })

  return (
    <div
      ref={parentRef}
      style={{ height: '600px', overflowY: 'auto', border: '1px solid #ccc' }}
    >
      <div
        style={{
          height: `${virtualizer.getTotalSize()}px`,
          position: 'relative',
        }}
      >
        {virtualizer.getVirtualItems().map((virtualItem) => (
          <div
            key={virtualItem.key}
            data-index={virtualItem.index}
            ref={virtualizer.measureElement}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              transform: `translateY(${virtualItem.start}px)`,
              padding: '12px',
              background: virtualItem.index % 2 === 0 ? '#f9f9f9' : '#fff',
              boxSizing: 'border-box',
            }}
          >
            {posts[virtualItem.index].content}
          </div>
        ))}
      </div>
    </div>
  )
}
```

**Output:** A scrollable container rendering only the visible posts at any time. As the user scrolls, DOM nodes are swapped in and out. The scrollbar reflects the full 5000-item length.

---

### Vue 3 — Vertical List

vue

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { useVirtualizer } from '@tanstack/vue-virtual'

const items = Array.from({ length: 10_000 }, (_, i) => `Item ${i + 1}`)
const parentEl = ref<HTMLElement | null>(null)

const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentEl.value,
  estimateSize: () => 40,
  overscan: 5,
})

const virtualItems = computed(() => virtualizer.value.getVirtualItems())
const totalSize = computed(() => virtualizer.value.getTotalSize())
</script>

<template>
  <div ref="parentEl" style="height: 500px; overflow-y: auto;">
    <div :style="{ height: `${totalSize}px`, position: 'relative' }">
      <div
        v-for="virtualItem in virtualItems"
        :key="virtualItem.key"
        :style="{
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: `${virtualItem.size}px`,
          transform: `translateY(${virtualItem.start}px)`,
        }"
      >
        {{ items[virtualItem.index] }}
      </div>
    </div>
  </div>
</template>
```

---

### Vanilla JS (Virtual Core) — Vertical List

ts

```ts
import { createVirtualizer } from '@tanstack/virtual-core'

const items = Array.from({ length: 10_000 }, (_, i) => `Item ${i + 1}`)

const scrollEl = document.getElementById('scroll-container')!
const innerEl = document.getElementById('inner')!

const virtualizer = createVirtualizer({
  count: items.length,
  getScrollElement: () => scrollEl,
  estimateSize: () => 40,
  onChange: (instance) => {
    innerEl.style.height = `${instance.getTotalSize()}px`

    // Clear previous items
    innerEl.innerHTML = ''

    for (const virtualItem of instance.getVirtualItems()) {
      const el = document.createElement('div')
      el.style.cssText = `
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: ${virtualItem.size}px;
        transform: translateY(${virtualItem.start}px);
      `
      el.textContent = items[virtualItem.index]
      innerEl.appendChild(el)
    }
  },
})

virtualizer._didMount()
```

**Key Points:**

- `onChange` fires whenever the visible range changes.
- `_didMount()` must be called after the scroll element is in the DOM.
- [Inference] For production usage with Vanilla JS, a more efficient diffing approach than `innerHTML = ''` is recommended to avoid unnecessary DOM churn.

---

### Architecture Diagram

<svg viewBox="0 0 720 480" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
<!-- Background -->
<rect width="720" height="480" fill="#0f1117" rx="12"/>
<!-- Title -->

<text x="360" y="36" text-anchor="middle" fill="`#e2e8f0`" font-size="15" font-weight="bold">TanStack Virtual — Vertical List Architecture</text>

<!-- Scroll Container -->
<rect x="40" y="60" width="300" height="380" rx="8" fill="#1e2130" stroke="#4a5568" stroke-width="1.5"/>
<text x="190" y="85" text-anchor="middle" fill="#a0aec0" font-size="11">Scroll Container (parentRef)</text>
<text x="190" y="100" text-anchor="middle" fill="#718096" font-size="10">height: 500px | overflow-y: auto</text>
<!-- Viewport highlight -->
<rect x="52" y="108" width="276" height="180" rx="4" fill="#2d3748" stroke="#63b3ed" stroke-width="1.5" stroke-dasharray="5,3"/>
<text x="190" y="126" text-anchor="middle" fill="#63b3ed" font-size="10">Visible Viewport</text>
<!-- Items in view -->
<rect x="60" y="132" width="260" height="38" rx="3" fill="#2b4a6f" stroke="#4299e1" stroke-width="1"/>
<text x="190" y="156" text-anchor="middle" fill="#bee3f8" font-size="11">Item 12 — rendered</text>
<rect x="60" y="178" width="260" height="38" rx="3" fill="#2b4a6f" stroke="#4299e1" stroke-width="1"/>
<text x="190" y="202" text-anchor="middle" fill="#bee3f8" font-size="11">Item 13 — rendered</text>
<rect x="60" y="224" width="260" height="38" rx="3" fill="#2b4a6f" stroke="#4299e1" stroke-width="1"/>
<text x="190" y="248" text-anchor="middle" fill="#bee3f8" font-size="11">Item 14 — rendered</text>
<!-- Overscan items -->
<rect x="60" y="296" width="260" height="34" rx="3" fill="#1a2f1a" stroke="#48bb78" stroke-width="1" stroke-dasharray="4,2"/>
<text x="190" y="318" text-anchor="middle" fill="#9ae6b4" font-size="10">Item 15 — overscan</text>
<rect x="60" y="338" width="260" height="34" rx="3" fill="#1a2f1a" stroke="#48bb78" stroke-width="1" stroke-dasharray="4,2"/>
<text x="190" y="360" text-anchor="middle" fill="#9ae6b4" font-size="10">Item 16 — overscan</text>
<!-- Not rendered -->
<rect x="60" y="390" width="260" height="34" rx="3" fill="#1a1a1a" stroke="#4a5568" stroke-width="1" stroke-dasharray="2,3"/>
<text x="190" y="412" text-anchor="middle" fill="#4a5568" font-size="10">Items 17–9999 — not in DOM</text>
<!-- Inner wrapper label -->

<text x="190" y="450" text-anchor="middle" fill="`#a0aec0`" font-size="10">Inner Div: height = getTotalSize() px | position: relative</text>

<!-- Right panel -->
<rect x="380" y="60" width="300" height="380" rx="8" fill="#1e2130" stroke="#4a5568" stroke-width="1.5"/>
<text x="530" y="85" text-anchor="middle" fill="#a0aec0" font-size="11">Virtualizer State</text>
<!-- Virtual items table -->
<rect x="395" y="100" width="270" height="28" rx="3" fill="#2d3748"/>
<text x="430" y="119" fill="#e2e8f0" font-size="10" font-weight="bold">virtualItem</text>
<text x="540" y="119" fill="#e2e8f0" font-size="10" font-weight="bold">start</text>
<text x="600" y="119" fill="#e2e8f0" font-size="10" font-weight="bold">size</text>
<rect x="395" y="130" width="270" height="24" rx="2" fill="#1a2740"/>
<text x="430" y="147" fill="#90cdf4" font-size="10">index: 12</text>
<text x="540" y="147" fill="#fbb6ce" font-size="10">480px</text>
<text x="600" y="147" fill="#b794f4" font-size="10">40px</text>
<rect x="395" y="156" width="270" height="24" rx="2" fill="#1a2740"/>
<text x="430" y="173" fill="#90cdf4" font-size="10">index: 13</text>
<text x="540" y="173" fill="#fbb6ce" font-size="10">520px</text>
<text x="600" y="173" fill="#b794f4" font-size="10">40px</text>
<rect x="395" y="182" width="270" height="24" rx="2" fill="#1a2740"/>
<text x="430" y="199" fill="#90cdf4" font-size="10">index: 14</text>
<text x="540" y="199" fill="#fbb6ce" font-size="10">560px</text>
<text x="600" y="199" fill="#b794f4" font-size="10">40px</text>
<!-- getTotalSize -->
<rect x="395" y="226" width="270" height="36" rx="3" fill="#2c1f4a" stroke="#9f7aea" stroke-width="1"/>
<text x="530" y="244" text-anchor="middle" fill="#d6bcfa" font-size="10">getTotalSize()</text>
<text x="530" y="258" text-anchor="middle" fill="#e9d8fd" font-size="11" font-weight="bold">400,000 px</text>
<!-- estimateSize -->
<rect x="395" y="278" width="270" height="36" rx="3" fill="#1a2f1a" stroke="#68d391" stroke-width="1"/>
<text x="530" y="296" text-anchor="middle" fill="#9ae6b4" font-size="10">estimateSize(index)</text>
<text x="530" y="311" text-anchor="middle" fill="#c6f6d5" font-size="11">→ 40px per item</text>
<!-- Scroll position -->
<rect x="395" y="330" width="270" height="36" rx="3" fill="#2f1c1c" stroke="#fc8181" stroke-width="1"/>
<text x="530" y="348" text-anchor="middle" fill="#fca5a5" font-size="10">scrollOffset</text>
<text x="530" y="363" text-anchor="middle" fill="#fecaca" font-size="11">480px (scrolled)</text>
<!-- Range -->
<rect x="395" y="382" width="270" height="36" rx="3" fill="#1a2030" stroke="#63b3ed" stroke-width="1"/>
<text x="530" y="400" text-anchor="middle" fill="#90cdf4" font-size="10">visible range</text>
<text x="530" y="415" text-anchor="middle" fill="#bee3f8" font-size="11">startIndex: 12 → endIndex: 16</text>
<!-- Arrow between panels -->
<line x1="342" y1="250" x2="378" y2="250" stroke="#718096" stroke-width="1.5" marker-end="url(#arrow)"/>
<defs>
<marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#718096"/>
</marker>
</defs>
</svg>

---

### Common Pitfalls

#### Missing `position: relative` on Inner Wrapper

Absolute-positioned children escape to the wrong ancestor. Items will appear at incorrect positions or stack at the top of the page.

#### Fixed Height on Measured Items

Setting `height: 40px` on an item using `measureElement` prevents the ResizeObserver from reading natural height. The virtualizer will use stale estimates indefinitely.

#### Using `index` as `key`

React may reuse DOM nodes incorrectly during fast scrolling, causing content flicker or incorrect renders. Always use `virtualItem.key`.

#### Scroll Container Without a Defined Height

If the scroll container grows to fit its content, it never actually scrolls — the virtualizer cannot determine the visible range and may render all items or none.

#### Forgetting `data-index`

When using `measureElement`, the `data-index` attribute must be set on the same element that receives the `ref`. Without it, the virtualizer cannot correlate measurements to indices.

---

### Performance Considerations

- **Fixed heights are fastest** — no ResizeObserver overhead, no re-layout after measurement.
- **Overscan tradeoff** — higher overscan reduces blank flash during fast scroll but increases concurrent DOM nodes.
- **Avoid inline object styles in hot paths** — [Inference] creating new style objects per render per item may trigger unnecessary reconciliation in some React versions; memoizing per-item style objects can help.
- **Complex item content** — if individual items are expensive to render, consider `React.memo` or equivalent memoization per framework.
- **`transform` vs `top`** — prefer `transform: translateY` for GPU compositing.

---

**Related Topics:**

- Horizontal lists — virtualizing along the X axis
- Grid virtualization — two-dimensional virtualization with rows and columns
- Dynamic/variable height measurement — deep dive into `measureElement` and ResizeObserver behavior
- Window scrolling — using the browser viewport as the scroll container
- Infinite scrolling — loading more data as the user approaches the list end
- Scroll restoration — preserving and restoring scroll position across navigation
- `scrollToIndex` and `scrollToOffset` — programmatic scroll control in depth
- TanStack Virtual with TanStack Query — combining server-side data fetching with virtualized rendering
- Svelte and Solid adapters — framework-specific patterns and differences
- Accessibility in virtual lists — focus management, `aria` attributes, keyboard navigation