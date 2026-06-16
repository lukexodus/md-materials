## TanStack Virtual — Imperative `scrollToIndex`

`scrollToIndex` is a method on the virtualizer instance that programmatically scrolls the list to bring a specific item into view. Because virtualized lists do not render all items at once, standard DOM methods like `scrollIntoView` do not work reliably — `scrollToIndex` is the correct approach.

---

### How It Works

The virtualizer calculates the target item's position based on its measured or estimated size, then sets the scroll position of the scroll element (or window) accordingly.

Because items may not yet be measured at the time of the call — especially with dynamic sizes — the virtualizer may need to perform multiple scroll adjustments to land on the correct position. This behavior is described further in the [Dynamic Size Adjustment](#dynamic-size-adjustment) section below.

---

### Basic Usage

`scrollToIndex` is called directly on the virtualizer instance.

**Example:**

tsx

```tsx
import { useVirtualizer } from '@tanstack/react-virtual';
import { useRef } from 'react';

function ScrollToExample() {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: 1000,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 40,
  });

  const handleScrollTo = () => {
    virtualizer.scrollToIndex(499);
  };

  return (
    <>
      <button onClick={handleScrollTo}>Scroll to item 499</button>
      <div ref={parentRef} style={{ height: '500px', overflow: 'auto' }}>
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
    </>
  );
}
```

**Key Points:**

- `scrollToIndex` is called on the virtualizer object directly — no ref to a separate imperative handle is needed
- The index is zero-based
- The method is synchronous in invocation, but scroll rendering is handled by the browser asynchronously

---

### The `align` Option

`scrollToIndex` accepts an options object as its second argument. The most important option is `align`, which controls where in the viewport the target item is positioned after scrolling.

ts

```ts
virtualizer.scrollToIndex(index, { align: 'start' | 'center' | 'end' | 'auto' });
```

| Value | Behavior |
| --- | --- |
| `'start'` | Aligns the item to the top (or left) of the scroll container |
| `'center'` | Centers the item within the scroll container |
| `'end'` | Aligns the item to the bottom (or right) of the scroll container |
| `'auto'` | Scrolls the minimum amount necessary to bring the item into view; does nothing if already visible |

**Example:**

ts

```ts
// Scroll item 200 to the center of the viewport
virtualizer.scrollToIndex(200, { align: 'center' });

// Scroll item 999 to the bottom of the viewport
virtualizer.scrollToIndex(999, { align: 'end' });

// Only scroll if item 50 is not already visible
virtualizer.scrollToIndex(50, { align: 'auto' });
```

**Key Points:**

- `'auto'` is the most efficient option for cases like keyboard navigation — it avoids unnecessary scrolling if the item is already visible
- `'center'` is useful for "jump to result" patterns, such as search result highlighting
- The default align behavior when the option is omitted may vary by version — explicitly passing `align` is safer [Inference — verify default in your version's source]

---

### Dynamic Size Adjustment

When items have dynamic or unknown sizes (i.e., you use `measureElement` rather than a fixed `estimateSize`), `scrollToIndex` faces a challenge: items between the current scroll position and the target index may not yet be rendered or measured.

The virtualizer handles this through an iterative correction process:

1. It scrolls to an estimated position based on current size data
2. Items in between are rendered and measured
3. If the measured sizes differ from the estimate, the virtualizer adjusts the scroll position
4. This repeats until the target item is reached and stable

> [Inference] This multi-pass correction behavior is an internal implementation detail. The number of correction passes and the exact mechanism may differ across versions. Behavior is not guaranteed to be instantaneous.

**Practical implication:** With dynamic sizes, there may be a brief visible scroll adjustment before the final position is reached. This is expected and by design.

---

### `behavior` Option — Smooth vs Instant Scrolling

The options object also accepts a `behavior` property that maps to the browser's native scroll behavior:

ts

```ts
virtualizer.scrollToIndex(300, { align: 'start', behavior: 'smooth' });
```

| Value | Effect |
| --- | --- |
| `'auto'` | Instant scroll (browser default) |
| `'smooth'` | Animated scroll using the browser's native smooth scroll |

**Key Points:**

- `'smooth'` relies on browser support for `scrollTo` with `behavior: 'smooth'`; support is broad but not universal across all environments
- Smooth scrolling combined with dynamic size correction passes may produce unexpected visual results [Inference — behavior may vary depending on item count, size variability, and browser]
- For programmatic navigation (e.g., jump to index on load), `'auto'` (instant) is generally more reliable

---

### Scrolling on Mount or Data Load

A common pattern is scrolling to a specific index when the component mounts or when data first loads.

**Example — Scroll to last item on mount:**

tsx

```tsx
import { useEffect, useRef } from 'react';
import { useVirtualizer } from '@tanstack/react-virtual';

function ScrollToBottomOnMount({ items }: { items: string[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 40,
  });

  useEffect(() => {
    virtualizer.scrollToIndex(items.length - 1, { align: 'end' });
  }, [items.length]);

  return (
    <div ref={parentRef} style={{ height: '500px', overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map((item) => (
          <div
            key={item.key}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              transform: `translateY(${item.start}px)`,
              height: `${item.size}px`,
            }}
          >
            {items[item.index]}
          </div>
        ))}
      </div>
    </div>
  );
}
```

**Key Points:**

- The `useEffect` dependency on `items.length` triggers a scroll whenever the list grows
- For chat-style UIs, this produces a "scroll to latest message" pattern
- If the scroll element is not yet mounted when `scrollToIndex` is called, it will silently do nothing [Inference — the method reads from `getScrollElement()` at call time; if it returns `null`, no scroll occurs]

---

### Scrolling with Window Virtualizer

`scrollToIndex` works the same way with `useWindowVirtualizer`. No additional configuration is needed.

**Example:**

tsx

```tsx
const virtualizer = useWindowVirtualizer({
  count: 1000,
  estimateSize: () => 40,
  scrollMargin: listRef.current?.offsetTop ?? 0,
});

virtualizer.scrollToIndex(250, { align: 'center' });
```

**Key Points:**

- The virtualizer scrolls the `window` object rather than a container element
- `scrollMargin` must be set correctly for the scroll position to land accurately
- The same `align` and `behavior` options apply

---

### `scrollToOffset` — Related Primitive

For cases where you need to scroll to a raw pixel offset rather than an index, the virtualizer also exposes `scrollToOffset`:

ts

```ts
virtualizer.scrollToOffset(2000, { align: 'start', behavior: 'auto' });
```

This is lower-level and does not account for item alignment logic. It is useful for restoring an exact scroll position (e.g., from session storage) rather than targeting a specific item.

---

### Flow: How `scrollToIndex` Resolves Position

YesNoYesNoscrollToIndex calledRead current sizemeasurementsAll sizes measured?Calculate exact offsetEstimate offset fromestimateSizeScroll to estimatedpositionItems render and measurePosition correct?DoneAdjust scroll offset

---

### Common Mistakes

**1. Calling `scrollToIndex` before the scroll element is mounted**

If called in a `useEffect` without verifying that `parentRef.current` is populated, the call may silently fail.

**2. Expecting pixel-perfect accuracy with unmeasured dynamic sizes**

When items have not yet been measured, the first scroll pass uses estimates. The final position is only accurate after all intermediate items are measured.

**3. Using `'smooth'` with large index jumps and dynamic sizes**

The multi-pass correction and smooth animation can conflict visually. Prefer `'auto'` for large programmatic jumps. [Inference — visual outcome is browser- and data-dependent]

**4. Confusing index with item key**

`scrollToIndex` takes a zero-based array index, not an item's `key` or data ID.

---

**Related Topics:**

- `scrollToOffset` — raw pixel scroll positioning
- Scroll restoration — persisting and restoring scroll position across navigation
- `measureElement` — dynamic size measurement and its interaction with scroll accuracy
- `overscan` — how buffer items affect scroll-to behavior near list boundaries
- Keyboard navigation patterns using `scrollToIndex` with `align: 'auto'`
- Infinite scroll and appending items while maintaining scroll position
- `initialOffset` — setting the initial scroll position on virtualizer creation