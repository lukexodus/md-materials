## TanStack Virtual — Scroll Element vs Window Scrolling

TanStack Virtual supports two primary scrolling modes: **scroll element scrolling** (a container element with overflow scroll) and **window scrolling** (the browser's native scroll). Understanding the difference is essential for choosing the correct virtualizer setup.

---

### Overview

When initializing a virtualizer, you must specify **where scrolling happens**. This determines how the virtualizer measures scroll position, attaches scroll listeners, and calculates which items are visible.

The two modes are:

- **Scroll element mode** — A specific DOM element (e.g., a `<div>`) handles scrolling via CSS `overflow: auto` or `overflow: scroll`
- **Window scrolling mode** — The entire page scrolls, and the virtualizer listens to the `window` object

---

### Scroll Element Mode

This is the most common pattern. A fixed-size container element scrolls internally, and the virtualizer tracks that element's scroll position.

#### Setup

The container element must have:

- An explicit height or width (or both, depending on scroll axis)
- `overflow: auto` or `overflow: scroll`

**Example — Vertical list with a scroll element:**

tsx

```tsx
import { useVirtualizer } from '@tanstack/react-virtual';
import { useRef } from 'react';

function ScrollElementList() {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: 1000,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 40,
  });

  return (
    <div
      ref={parentRef}
      style={{ height: '500px', overflow: 'auto' }}
    >
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map((item) => (
          <div
            key={item.key}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: `${item.size}px`,
              transform: `translateY(${item.start}px)`,
            }}
          >
            Row {item.index}
          </div>
        ))}
      </div>
    </div>
  );
}
```

**Key Points:**

- `getScrollElement` returns the DOM node that scrolls
- The virtualizer attaches its scroll listener to that element
- The outer `<div>` must have a bounded height and `overflow: auto`
- The inner `<div>` is sized to `getTotalSize()` to create the scrollable area

---

### Window Scrolling Mode

In this mode, the page itself scrolls. This is appropriate when your list spans the full page, and you do not want to confine content inside a bounded container.

#### Setup

Instead of providing a scroll element, you pass `null` or use the `useWindowVirtualizer` convenience hook (React adapter). The virtualizer listens to the `window` scroll events.

**Example — Using `useWindowVirtualizer`:**

tsx

```tsx
import { useWindowVirtualizer } from '@tanstack/react-virtual';

function WindowScrollList() {
  const virtualizer = useWindowVirtualizer({
    count: 1000,
    estimateSize: () => 40,
  });

  return (
    <div style={{ position: 'relative', height: `${virtualizer.getTotalSize()}px` }}>
      {virtualizer.getVirtualItems().map((item) => (
        <div
          key={item.key}
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width: '100%',
            height: `${item.size}px`,
            transform: `translateY(${item.start}px)`,
          }}
        >
          Row {item.index}
        </div>
      ))}
    </div>
  );
}
```

**Key Points:**

- `useWindowVirtualizer` is a wrapper around `useVirtualizer` that pre-configures `getScrollElement` to return the `window`
- No container with `overflow: auto` is needed
- The outermost `<div>` still needs `position: relative` and `height: getTotalSize()` to define the scrollable content height
- The virtualizer offsets items relative to the list's position in the document

#### Using `useVirtualizer` Directly with Window Scrolling

If you use the core `useVirtualizer` hook (not the convenience wrapper), you can achieve window scrolling manually:

tsx

```tsx
const virtualizer = useVirtualizer({
  count: 1000,
  getScrollElement: () => window,       // Pass window directly
  estimateSize: () => 40,
});
```

> [Inference] Whether `window` is accepted directly as the scroll element may depend on the version and adapter in use. Behavior may vary. Consult the official TanStack Virtual docs for your version.

---

### Key Behavioral Differences

| Aspect | Scroll Element | Window Scrolling |
| --- | --- | --- |
| Scroll listener target | The container DOM element | `window` |
| Container CSS required | `height` + `overflow: auto` | Not required |
| Layout containment | Content stays within the element | Content spans the full page |
| Scroll position source | `element.scrollTop` / `scrollLeft` | `window.scrollY` / `scrollX` |
| Offset calculation | Relative to container | Relative to document + element offset |
| Use case | Embedded lists, tables, panels | Full-page feeds, document-level lists |

---

### The `scrollMargin` Option (Window Scrolling)

When using window scrolling, the list rarely starts at the very top of the page — there is usually a header, nav bar, or other content above it. Without accounting for this, the virtualizer may miscalculate which items are visible.

The `scrollMargin` option tells the virtualizer how far the top of the list is from the top of the scroll container (the window).

**Example:**

tsx

```tsx
const listRef = useRef<HTMLDivElement>(null);

const virtualizer = useWindowVirtualizer({
  count: 1000,
  estimateSize: () => 40,
  scrollMargin: listRef.current?.offsetTop ?? 0,
});

return (
  <div ref={listRef} style={{ position: 'relative', height: `${virtualizer.getTotalSize()}px` }}>
    {virtualizer.getVirtualItems().map((item) => (
      <div
        key={item.key}
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          transform: `translateY(${item.start - virtualizer.options.scrollMargin}px)`,
        }}
      >
        Row {item.index}
      </div>
    ))}
  </div>
);
```

**Key Points:**

- `scrollMargin` is subtracted from the item's `start` value in the transform
- Without this correction, items will be mispositioned when the list does not begin at `y = 0`
- `offsetTop` can change on resize; you may need to recalculate it on layout changes

---

### Visual Comparison

Virtualizer SetupWhere does scrollinghappen?Scroll Element ModeWindow Scrolling ModegetScrollElement returnsa DOM divContainer has overflow:auto + fixed heightListener on element scrolleventuseWindowVirtualizer orgetScrollElement returnswindowNo overflow containerneededListener on window scrolleventUse scrollMargin if list isoffset from top

---

### Choosing Between the Two

Use **scroll element mode** when:

- The list is embedded within a page layout (sidebar, panel, table container)
- You need the rest of the page to remain static while the list scrolls
- You have multiple scrollable regions on the same page

Use **window scrolling mode** when:

- The list is the primary content of a full page
- You want native browser scroll behavior (momentum, scroll restoration, browser toolbars reacting to scroll)
- You are building infinite feed-style pages

---

### Common Mistakes

**1. Missing `overflow: auto` in scroll element mode**

Without this, the container does not scroll and the virtualizer receives no scroll events.

**2. Forgetting `scrollMargin` in window scrolling**

If the list is below other page content and `scrollMargin` is not set, items will render at incorrect positions.

**3. Passing `null` to `getScrollElement` and expecting window scrolling**

In the core `useVirtualizer` hook, passing `null` disables scroll tracking entirely. Use `useWindowVirtualizer` or pass `window` explicitly for window-based scrolling. [Inference — exact null behavior may differ by version; verify against your version's source or changelog.]

**4. Not subtracting `scrollMargin` from `item.start` in the transform**

Even if `scrollMargin` is set correctly on the virtualizer, the transform calculation must also subtract it, otherwise items are offset incorrectly.

---

**Related Topics:**

- `estimateSize` and dynamic size measurement with `measureElement`
- `scrollMargin` deep dive and dynamic recalculation on resize
- Horizontal virtualizer setup (scroll axis configuration)
- `overscan` option — rendering buffer items outside the viewport
- Scroll restoration and programmatic scrolling with `scrollToIndex`
- Using TanStack Virtual in non-React adapters (Vue, Solid, Svelte) for both modes
- Combining window scrolling with sticky headers or offset toolbars