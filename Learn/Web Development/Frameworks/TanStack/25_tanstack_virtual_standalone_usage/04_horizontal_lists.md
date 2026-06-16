## TanStack Virtual — Standalone Usage — Horizontal Lists

Horizontal lists scroll along the X axis and are used for carousels, timelines, kanban columns, media strips, tag selectors, and any layout where items are arranged side by side. TanStack Virtual supports horizontal virtualization with a small configuration change from the vertical default, but several structural and behavioral differences require dedicated attention.

---

### How Horizontal Virtualization Differs from Vertical

The core virtualization algorithm is identical — only the **scroll axis changes**. Instead of measuring item heights and tracking `scrollTop`, the virtualizer measures item **widths** and tracks `scrollLeft`. Every concept from vertical lists maps directly, with axis-specific substitutions.

| Concept | Vertical | Horizontal |
| --- | --- | --- |
| Scroll axis | Y | X |
| Item dimension | height | width |
| Scroll property | `scrollTop` | `scrollLeft` |
| CSS overflow | `overflow-y` | `overflow-x` |
| Item offset | `translateY` | `translateX` |
| Container dimension | fixed `height` | fixed `width` |

---

### Configuration — Enabling Horizontal Mode

The only required change to switch from vertical to horizontal is setting the `horizontal` option to `true`:

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 120,
  horizontal: true, // enables X-axis virtualization
})
```

Everything else — `overscan`, `gap`, `paddingStart`, `paddingEnd`, `getItemKey`, `measureElement` — works identically to vertical lists.

---

### Scroll Container Requirements

The scroll container for a horizontal list must:

- Have a **fixed width** (in `px`, `%`, `vw`, or flex-constrained)
- Have `overflow-x: auto` or `overflow-x: scroll`
- Have `white-space: nowrap` if items are inline — though with absolute positioning this is unnecessary
- **Not** wrap items — the inner wrapper must expand horizontally, not flow to new lines

tsx

```tsx
<div
  ref={parentRef}
  style={{
    width: '100%',       // or a fixed pixel width
    overflowX: 'auto',
    whiteSpace: 'nowrap', // only needed if items are inline-block
  }}
>
```

---

### Inner Wrapper

The inner wrapper expands to `getTotalSize()` pixels **horizontally**, and must be `position: relative` to anchor absolutely positioned children:

tsx

```tsx
<div
  style={{
    width: `${virtualizer.getTotalSize()}px`,
    height: '100%',       // fill the container's height
    position: 'relative',
  }}
>
```

**Key Points:**

- Width, not height, holds `getTotalSize()`.
- Height should match the scroll container's height — or be set explicitly to the tallest expected item.
- Without a defined height on the inner wrapper, absolutely positioned children with percentage heights may collapse.

---

### Item Positioning

Items use `position: absolute` with `transform: translateX(start)` instead of `translateY`:

tsx

```tsx
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
  {items[virtualItem.index]}
</div>
```

**Key Points:**

- `left: 0` and `transform: translateX` combine to place each item at its correct horizontal offset.
- `top: 0` and `height: 100%` make items fill the container's full vertical space — adjust if items vary in height.
- `width` is set from `virtualItem.size`, which reflects `estimateSize` or a measured value.

---

### Minimal Horizontal List — React

tsx

```tsx
import { useRef } from 'react'
import { useVirtualizer } from '@tanstack/react-virtual'

const items = Array.from({ length: 5000 }, (_, i) => `Card ${i + 1}`)

export function HorizontalList() {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 120,
    horizontal: true,
    overscan: 3,
  })

  return (
    <div
      ref={parentRef}
      style={{
        width: '100%',
        overflowX: 'auto',
        height: '80px',
      }}
    >
      <div
        style={{
          width: `${virtualizer.getTotalSize()}px`,
          height: '100%',
          position: 'relative',
        }}
      >
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
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: virtualItem.index % 2 === 0 ? '#1a2740' : '#2b4a6f',
              borderRight: '1px solid #2d3748',
              color: '#e2e8f0',
              fontSize: '13px',
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

**Output:** A single-row, horizontally scrollable strip of 5000 cards. Only the cards within the visible width plus overscan are in the DOM at any time.

---

### Variable-Width Items

Items of different widths are handled the same way as variable-height items in vertical lists — by using `estimateSize` with per-index estimates and attaching `measureElement` for actual measurement.

tsx

```tsx
const cards = Array.from({ length: 2000 }, (_, i) => ({
  id: `card-${i}`,
  label: `Item ${'#'.repeat((i % 5) + 1)} ${i}`, // varying label lengths
}))

const virtualizer = useVirtualizer({
  count: cards.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 100, // rough estimate; actual width measured after render
  horizontal: true,
  getItemKey: (index) => cards[index].id,
})
```

Attach `measureElement` to each item's DOM node. The virtualizer reads `data-index` to associate measurements with indices:

tsx

```tsx
{virtualizer.getVirtualItems().map((virtualItem) => (
  <div
    key={virtualItem.key}
    data-index={virtualItem.index}
    ref={virtualizer.measureElement}
    style={{
      position: 'absolute',
      top: 0,
      left: 0,
      height: '100%',
      transform: `translateX(${virtualItem.start}px)`,
      // Do NOT set a fixed width — let content determine natural width
      padding: '0 16px',
      whiteSpace: 'nowrap',
    }}
  >
    {cards[virtualItem.index].label}
  </div>
))}
```

**Key Points:**

- Do **not** set a fixed `width` on measured items — this prevents the ResizeObserver from reading natural width.
- `whiteSpace: nowrap` on the item itself keeps text from wrapping and affecting height but not width measurement.
- `data-index` is mandatory on the same element that receives the `ref`.

---

### Gap Between Items

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 120,
  horizontal: true,
  gap: 12, // 12px between each card
})
```

The gap is incorporated into `start` offset calculations. Do not use `margin-right` on items as a workaround — this interferes with measurement.

---

### Padding the Horizontal List

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 120,
  horizontal: true,
  paddingStart: 24, // space before the first card
  paddingEnd: 24,   // space after the last card
})
```

This preserves correct `start` offset calculations. CSS padding on the scroll container can interfere with scroll position tracking and should be avoided for this purpose.

---

### Scroll to Index — Horizontal

`scrollToIndex` works identically to vertical lists, with `align` controlling horizontal positioning:

tsx

```tsx
virtualizer.scrollToIndex(200)

virtualizer.scrollToIndex(200, { align: 'start' })   // item at left edge
virtualizer.scrollToIndex(200, { align: 'center' })  // item centered
virtualizer.scrollToIndex(200, { align: 'end' })     // item at right edge
virtualizer.scrollToIndex(200, { align: 'auto' })    // minimal scroll
```

**Example** — a "next" button that advances one card at a time:

tsx

```tsx
const currentIndex = useRef(0)

function scrollNext() {
  currentIndex.current = Math.min(currentIndex.current + 1, items.length - 1)
  virtualizer.scrollToIndex(currentIndex.current, { align: 'start' })
}

<button onClick={scrollNext}>Next →</button>
```

---

### Carousel Pattern

A common pattern is a constrained horizontal list that scrolls one "page" at a time rather than freely. TanStack Virtual handles this with `scrollToIndex` and a tracked active index.

tsx

```tsx
import { useRef, useState } from 'react'
import { useVirtualizer } from '@tanstack/react-virtual'

const slides = Array.from({ length: 50 }, (_, i) => ({
  id: `slide-${i}`,
  title: `Slide ${i + 1}`,
}))

export function Carousel() {
  const parentRef = useRef<HTMLDivElement>(null)
  const [activeIndex, setActiveIndex] = useState(0)

  const virtualizer = useVirtualizer({
    count: slides.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 480, // each slide is 480px wide
    horizontal: true,
    overscan: 1,
  })

  function goTo(index: number) {
    const clamped = Math.max(0, Math.min(index, slides.length - 1))
    setActiveIndex(clamped)
    virtualizer.scrollToIndex(clamped, { align: 'start' })
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
      <div
        ref={parentRef}
        style={{
          width: '480px',
          overflowX: 'auto',
          height: '270px',
          scrollSnapType: 'x mandatory', // optional: native snap
        }}
      >
        <div
          style={{
            width: `${virtualizer.getTotalSize()}px`,
            height: '100%',
            position: 'relative',
          }}
        >
          {virtualizer.getVirtualItems().map((virtualItem) => (
            <div
              key={virtualItem.key}
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: `${virtualItem.size}px`,
                height: '100%',
                transform: `translateX(${virtualItem.start}px)`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                background: '#1e2130',
                border: '1px solid #4a5568',
                fontSize: '18px',
                color: '#e2e8f0',
                scrollSnapAlign: 'start',
              }}
            >
              {slides[virtualItem.index].title}
            </div>
          ))}
        </div>
      </div>

      <div style={{ display: 'flex', gap: '8px', justifyContent: 'center' }}>
        <button onClick={() => goTo(activeIndex - 1)} disabled={activeIndex === 0}>
          ← Prev
        </button>
        <span>{activeIndex + 1} / {slides.length}</span>
        <button onClick={() => goTo(activeIndex + 1)} disabled={activeIndex === slides.length - 1}>
          Next →
        </button>
      </div>
    </div>
  )
}
```

**Key Points:**

- `scrollSnapType` and `scrollSnapAlign` are CSS-native snapping — they work alongside TanStack Virtual but are independent of it. [Inference] Mixing CSS scroll snap with `scrollToIndex` may produce inconsistent behavior during programmatic scrolls in some browsers; test thoroughly.
- TanStack Virtual does not natively enforce "one item at a time" paging — that logic lives in your component.

---

### RTL (Right-to-Left) Support

For RTL layouts, the scroll direction is reversed. TanStack Virtual v3+ includes an `isRtl` option:

tsx

```tsx
const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 120,
  horizontal: true,
  isRtl: true, // reverses scroll direction and offset calculations
})
```

**Key Points:**

- The scroll container should also have `dir="rtl"` set on it or a parent element.
- [Unverified] The exact option name and availability may differ across minor versions — consult the current API reference.
- Item `start` values are computed from the right edge of the container in RTL mode.

---

### Vue 3 — Horizontal List

vue

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
import { useVirtualizer } from '@tanstack/vue-virtual'

const items = Array.from({ length: 5000 }, (_, i) => `Card ${i + 1}`)
const parentEl = ref<HTMLElement | null>(null)

const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentEl.value,
  estimateSize: () => 120,
  horizontal: true,
  overscan: 3,
})

const virtualItems = computed(() => virtualizer.value.getVirtualItems())
const totalSize = computed(() => virtualizer.value.getTotalSize())
</script>

<template>
  <div
    ref="parentEl"
    style="width: 100%; overflow-x: auto; height: 80px;"
  >
    <div
      :style="{
        width: `${totalSize}px`,
        height: '100%',
        position: 'relative',
      }"
    >
      <div
        v-for="virtualItem in virtualItems"
        :key="virtualItem.key"
        :style="{
          position: 'absolute',
          top: 0,
          left: 0,
          height: '100%',
          width: `${virtualItem.size}px`,
          transform: `translateX(${virtualItem.start}px)`,
        }"
      >
        {{ items[virtualItem.index] }}
      </div>
    </div>
  </div>
</template>
```

---

### Vanilla JS (Virtual Core) — Horizontal List

ts

```ts
import { createVirtualizer } from '@tanstack/virtual-core'

const items = Array.from({ length: 5000 }, (_, i) => `Card ${i + 1}`)

const scrollEl = document.getElementById('scroll-container')!
const innerEl = document.getElementById('inner')!

const virtualizer = createVirtualizer({
  count: items.length,
  getScrollElement: () => scrollEl,
  estimateSize: () => 120,
  horizontal: true,
  onChange: (instance) => {
    innerEl.style.width = `${instance.getTotalSize()}px`
    innerEl.innerHTML = ''

    for (const virtualItem of instance.getVirtualItems()) {
      const el = document.createElement('div')
      el.style.cssText = `
        position: absolute;
        top: 0;
        left: 0;
        height: 100%;
        width: ${virtualItem.size}px;
        transform: translateX(${virtualItem.start}px);
        display: flex;
        align-items: center;
        justify-content: center;
      `
      el.textContent = items[virtualItem.index]
      innerEl.appendChild(el)
    }
  },
})

virtualizer._didMount()
```

---

### Architecture Diagram

<svg viewBox="0 0 720 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<!-- Background -->
<rect width="720" height="400" fill="#0f1117" rx="12"/>
<!-- Title -->

<text x="360" y="32" text-anchor="middle" fill="`#e2e8f0`" font-size="14" font-weight="bold">TanStack Virtual — Horizontal List Architecture</text>

<!-- Scroll container outline -->
<rect x="30" y="55" width="660" height="130" rx="8" fill="#1e2130" stroke="#4a5568" stroke-width="1.5"/>
<text x="360" y="74" text-anchor="middle" fill="#a0aec0" font-size="10">Scroll Container — width: 660px | overflow-x: auto</text>
<!-- Viewport bracket -->
<rect x="30" y="80" width="300" height="95" rx="4" fill="none" stroke="#63b3ed" stroke-width="1.5" stroke-dasharray="5,3"/>
<text x="180" y="95" text-anchor="middle" fill="#63b3ed" font-size="10">Visible Viewport</text>
<!-- Items -->
<!-- Item 3 - partial left (clipped by viewport) -->
<rect x="30" y="98" width="70" height="66" rx="3" fill="#1a2f1a" stroke="#48bb78" stroke-width="1" stroke-dasharray="4,2"/>
<text x="65" y="135" text-anchor="middle" fill="#9ae6b4" font-size="9">Item 2</text>
<text x="65" y="148" text-anchor="middle" fill="#68d391" font-size="8">overscan</text>
<!-- Item 4 -->
<rect x="105" y="98" width="90" height="66" rx="3" fill="#2b4a6f" stroke="#4299e1" stroke-width="1"/>
<text x="150" y="135" text-anchor="middle" fill="#bee3f8" font-size="10">Item 3</text>
<text x="150" y="148" text-anchor="middle" fill="#90cdf4" font-size="8">rendered</text>
<!-- Item 5 -->
<rect x="200" y="98" width="90" height="66" rx="3" fill="#2b4a6f" stroke="#4299e1" stroke-width="1"/>
<text x="245" y="135" text-anchor="middle" fill="#bee3f8" font-size="10">Item 4</text>
<text x="245" y="148" text-anchor="middle" fill="#90cdf4" font-size="8">rendered</text>
<!-- Viewport right edge -->
<!-- Item 6 -->
<rect x="295" y="98" width="90" height="66" rx="3" fill="#2b4a6f" stroke="#4299e1" stroke-width="1"/>
<text x="340" y="135" text-anchor="middle" fill="#bee3f8" font-size="10">Item 5</text>
<text x="340" y="148" text-anchor="middle" fill="#90cdf4" font-size="8">rendered</text>
<!-- Item 7 - overscan right -->
<rect x="390" y="98" width="80" height="66" rx="3" fill="#1a2f1a" stroke="#48bb78" stroke-width="1" stroke-dasharray="4,2"/>
<text x="430" y="135" text-anchor="middle" fill="#9ae6b4" font-size="9">Item 6</text>
<text x="430" y="148" text-anchor="middle" fill="#68d391" font-size="8">overscan</text>
<!-- Item 8 - overscan right -->
<rect x="475" y="98" width="80" height="66" rx="3" fill="#1a2f1a" stroke="#48bb78" stroke-width="1" stroke-dasharray="4,2"/>
<text x="515" y="135" text-anchor="middle" fill="#9ae6b4" font-size="9">Item 7</text>
<text x="515" y="148" text-anchor="middle" fill="#68d391" font-size="8">overscan</text>
<!-- Not rendered -->
<rect x="560" y="98" width="118" height="66" rx="3" fill="#1a1a1a" stroke="#4a5568" stroke-width="1" stroke-dasharray="2,3"/>
<text x="619" y="128" text-anchor="middle" fill="#4a5568" font-size="9">Items 8–4999</text>
<text x="619" y="142" text-anchor="middle" fill="#4a5568" font-size="8">not in DOM</text>
<!-- Inner wrapper label -->

<text x="360" y="178" text-anchor="middle" fill="`#a0aec0`" font-size="9">Inner Div: width = getTotalSize() px | position: relative | height: 100%</text>

<!-- Scroll indicator arrows -->

<text x="360" y="200" text-anchor="middle" fill="`#718096`" font-size="10">← scroll direction: X axis →</text>
<line x1="180" y1="198" x2="60" y2="198" stroke="`#718096`" stroke-width="1" marker-end="url(#arrowL)"/>
<line x1="540" y1="198" x2="660" y2="198" stroke="`#718096`" stroke-width="1" marker-end="url(#arrowR)"/>
<defs>
<marker id="arrowL" markerWidth="7" markerHeight="7" refX="0" refY="3" orient="auto">
<path d="M7,0 L7,6 L0,3 z" fill="`#718096`"/>
</marker>
<marker id="arrowR" markerWidth="7" markerHeight="7" refX="7" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="`#718096`"/>
</marker>
</defs>

<!-- Bottom panel: config comparison -->
<rect x="30" y="218" width="320" height="155" rx="8" fill="#1e2130" stroke="#4a5568" stroke-width="1.5"/>
<text x="190" y="238" text-anchor="middle" fill="#a0aec0" font-size="11" font-weight="bold">Horizontal Config</text>
<rect x="45" y="248" width="290" height="24" rx="3" fill="#2d3748"/>
<text x="55" y="265" fill="#68d391" font-size="10">horizontal:</text>
<text x="160" y="265" fill="#fbb6ce" font-size="10">true</text>
<rect x="45" y="276" width="290" height="24" rx="3" fill="#1a2740"/>
<text x="55" y="293" fill="#68d391" font-size="10">estimateSize:</text>
<text x="160" y="293" fill="#fbb6ce" font-size="10">() => 120 // item width</text>
<rect x="45" y="304" width="290" height="24" rx="3" fill="#2d3748"/>
<text x="55" y="321" fill="#68d391" font-size="10">overflow CSS:</text>
<text x="160" y="321" fill="#fbb6ce" font-size="10">overflow-x: auto</text>
<rect x="45" y="332" width="290" height="24" rx="3" fill="#1a2740"/>
<text x="55" y="349" fill="#68d391" font-size="10">transform:</text>
<text x="160" y="349" fill="#fbb6ce" font-size="10">translateX(start)</text>
<rect x="45" y="358" width="290" height="8" rx="2" fill="#2d3748"/>
<!-- Bottom right panel: virtual item data -->
<rect x="370" y="218" width="320" height="155" rx="8" fill="#1e2130" stroke="#4a5568" stroke-width="1.5"/>
<text x="530" y="238" text-anchor="middle" fill="#a0aec0" font-size="11" font-weight="bold">Virtual Item Data</text>
<rect x="385" y="248" width="290" height="22" rx="3" fill="#2d3748"/>
<text x="400" y="264" fill="#e2e8f0" font-size="10" font-weight="bold">index</text>
<text x="460" y="264" fill="#e2e8f0" font-size="10" font-weight="bold">start (px)</text>
<text x="560" y="264" fill="#e2e8f0" font-size="10" font-weight="bold">size (px)</text>
<rect x="385" y="272" width="290" height="20" rx="2" fill="#1a2740"/>
<text x="400" y="287" fill="#90cdf4" font-size="10">3</text>
<text x="460" y="287" fill="#fbb6ce" font-size="10">360</text>
<text x="560" y="287" fill="#b794f4" font-size="10">90</text>
<rect x="385" y="294" width="290" height="20" rx="2" fill="#2d3748"/>
<text x="400" y="309" fill="#90cdf4" font-size="10">4</text>
<text x="460" y="309" fill="#fbb6ce" font-size="10">450</text>
<text x="560" y="309" fill="#b794f4" font-size="10">90</text>
<rect x="385" y="316" width="290" height="20" rx="2" fill="#1a2740"/>
<text x="400" y="331" fill="#90cdf4" font-size="10">5</text>
<text x="460" y="331" fill="#fbb6ce" font-size="10">540</text>
<text x="560" y="331" fill="#b794f4" font-size="10">90</text>
<rect x="385" y="344" width="290" height="24" rx="3" fill="#2c1f4a" stroke="#9f7aea" stroke-width="1"/>
<text x="530" y="361" text-anchor="middle" fill="#d6bcfa" font-size="10">getTotalSize() = 600,000 px</text>
</svg>

---

### Common Pitfalls

#### `overflow-x` Not Set

Without `overflow-x: auto`, the scroll container expands to fit all content and never scrolls. The virtualizer cannot compute the visible range.

#### Inner Wrapper Using `height` for Total Size

A common copy-paste error from vertical list examples. The inner wrapper needs `width: getTotalSize()px` for horizontal lists, not `height`.

#### Using `translateY` Instead of `translateX`

Items will stack vertically instead of laying out horizontally. The transform axis must match the scroll axis.

#### Setting Fixed `width` on Measured Items

Prevents `measureElement` from reading the natural content width. Leave `width` unset or as `auto` on items using dynamic measurement.

#### No `height` on Inner Wrapper

With `position: absolute` children, the inner wrapper collapses to zero height unless an explicit `height` is set. Set `height: 100%` or a fixed pixel value.

---

### Performance Considerations

- Fixed widths eliminate ResizeObserver overhead — prefer them when item widths are known.
- [Inference] Horizontal lists are often shallower in DOM depth than vertical lists (fewer items visible at once in narrow containers), so DOM overhead per scroll event may be lower.
- `gap` is computed by the virtualizer — avoid `margin-right` on individual items.
- For carousel-style lists with large slide content (images, video), consider lazy-loading item content based on `virtualItem.index` proximity to the active index.
- GPU-composited `translateX` keeps scrolling smooth — avoid layout-triggering properties like `left` in hot paths.

---

**Related Topics:**

- Grid virtualization — combining horizontal and vertical axes into a two-dimensional virtual grid
- Carousel implementation patterns — snap scrolling, pagination, and indicator dots with TanStack Virtual
- Variable-width measurement — deep dive into `measureElement` behavior on the X axis
- RTL support — right-to-left layout configuration and edge cases
- Combining horizontal and vertical lists — nested virtualizers for complex layouts
- `scrollToIndex` alignment modes — `start`, `center`, `end`, `auto` in depth
- Horizontal infinite scroll — appending items as the user scrolls right
- Accessibility in horizontal lists — keyboard navigation (`ArrowLeft`/`ArrowRight`), `role="listbox"`, focus trapping