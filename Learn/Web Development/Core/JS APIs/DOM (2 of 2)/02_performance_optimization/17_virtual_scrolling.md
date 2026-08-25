## Virtual Scrolling


Virtual scrolling is a rendering optimization technique that displays only the subset of items currently visible in the viewport, rather than rendering all items in a large list or collection. The DOM contains only enough elements to fill the visible area plus a buffer, while maintaining the illusion of a complete scrollable list through dynamic element recycling and positioning.

### Core Mechanism

The fundamental operation involves calculating which items should be visible based on scroll position, rendering only those items, and using absolute or relative positioning with padding/transforms to create correct scroll behavior. As the user scrolls, items leaving the viewport are recycled—their DOM nodes are reused and repopulated with data for items entering the viewport.

The container maintains two key measurements: the total scrollable height (calculated as `itemCount × itemHeight`) and the current scroll offset. These values determine which slice of data to render at any moment.

### Scroll Position Calculation

The visible range is derived from the scroll position. For fixed-height items:

```
startIndex = Math.floor(scrollTop / itemHeight)
endIndex = Math.ceil((scrollTop + viewportHeight) / itemHeight)
visibleItems = items.slice(startIndex, endIndex + buffer)
```

The buffer extends the rendered range beyond the visible viewport to provide smoother scrolling and prevent blank spaces during rapid scroll events.

### DOM Structure Patterns

**Container-based approach**: An outer scrollable container with defined height and `overflow: auto` or `overflow: scroll`. Inside, a tall spacer element establishes the total scroll height, and absolutely positioned item elements render at calculated offsets.

**Transform-based approach**: Items are positioned using CSS transforms (`translateY`) rather than absolute positioning. This can leverage GPU acceleration and avoid layout thrashing in some scenarios.

**Padding-based approach**: Top and bottom padding on the container simulates the space occupied by non-rendered items, with rendered items flowing naturally in document order.

### Item Height Strategies

**Fixed height**: All items have identical heights. This simplifies calculations significantly—item positions are deterministic (`itemTop = index × itemHeight`). This is the most performant approach but least flexible.

**Dynamic height with measurement**: Items have variable heights that must be measured after rendering. The virtualizer maintains a cache of measured heights and updates calculations as new measurements arrive. This requires a measurement phase where items are rendered offscreen or initially, their heights recorded, and subsequent renders use cached values.

**Estimated height with correction**: Start with estimated heights, render items, measure actual heights, then adjust positions. This creates a more complex system where scroll positions may shift as estimates are replaced with actual measurements. The challenge is maintaining scroll stability—preventing the viewport from jumping as heights are corrected.

### Position Management

Items must be positioned to appear at their correct location in the virtual list. Common techniques:

**Absolute positioning**: Each item receives `position: absolute` with calculated `top` values. The container has `position: relative`. This removes items from document flow, requiring explicit height management.

**Transform positioning**: Items use `transform: translateY(offset)` or `translate3d(0, offset, 0)`. The latter can trigger hardware acceleration. Items remain in flow for some layout purposes while being visually repositioned.

**Spacer elements**: Invisible elements before and after the visible range create the necessary scroll space without positioning each item absolutely.

### Scroll Synchronization

The virtualizer must respond to scroll events to update the rendered range. Key considerations:

**Event throttling/debouncing**: Raw scroll events fire rapidly. Throttling limits update frequency to avoid excessive recalculation and rendering. However, aggressive throttling can cause visible lag.

**RequestAnimationFrame synchronization**: Scheduling updates with `requestAnimationFrame` aligns rendering with the browser's repaint cycle, providing smooth updates without tearing.

**Passive event listeners**: Using `{passive: true}` on scroll listeners prevents blocking the scroll thread, improving scroll smoothness at the cost of not being able to prevent default behavior.

### Recycling and Pooling

Element recycling reuses DOM nodes rather than destroying and recreating them. When an item scrolls out of view, its DOM node is retained and repopulated with data for an item entering the viewport.

**Pool management**: Maintain a pool of DOM elements slightly larger than the visible range. As items shift, elements are pulled from the pool, updated, and repositioned rather than created fresh.

**State cleanup**: When recycling, all previous state must be cleared—event listeners updated, content replaced, attributes reset. Failing to clean state causes visual artifacts where old content briefly appears before updates.

**Key/identity tracking**: Each DOM node must track which data item it currently represents to ensure correct updates during recycling.

### Overscan and Buffer Zones

The overscan region extends rendered items beyond the visible viewport. Benefits:

**Scroll smoothness**: Items are pre-rendered before entering view, eliminating flashing or blank spaces during fast scrolling.

**Reduced update frequency**: Larger buffers mean fewer updates as the user scrolls, trading memory for fewer recalculations.

Common implementations render `overscanCount` additional items above and below the visible range. The overscan size is a tuning parameter—larger values improve perceived performance but increase DOM size and memory usage.

### Variable Height Challenges

Dynamic heights introduce measurement dependencies and calculation complexity:

**Initial estimation**: Before measurement, heights must be estimated. Poor estimates cause scroll position instability—the scrollbar jumps as estimates are replaced with actuals.

**Measurement timing**: Heights can only be measured after rendering. This creates a chicken-and-egg problem: you need heights to calculate positions, but need to render to get heights.

**Progressive measurement**: Measure items as they're first rendered, caching results. Initial scrolling may be unstable until all items are measured at least once. Some implementations pre-render items offscreen during idle time to gather measurements.

**Scroll anchor preservation**: When heights change, maintain the user's visual scroll position. If an item above the viewport becomes taller, the scroll position must increase correspondingly to keep the visible content stable.

### Bidirectional Scrolling

Supporting horizontal scrolling or grid layouts adds a second dimension of complexity:

**2D range calculation**: Calculate visible ranges for both axes. For grids: `visibleColumns`, `visibleRows`, and render the cartesian product.

**Cell positioning**: Each cell requires both X and Y positioning. Fixed-size grids simplify this (`x = column × cellWidth`, `y = row × cellHeight`), but variable sizes require 2D measurement caching.

**Overscan in both directions**: Buffer zones extend in four directions, potentially rendering significantly more items than the pure visible range.

### Scroll Restoration

When returning to a virtualized list (e.g., browser back navigation), maintaining scroll position requires:

**Position serialization**: Store scroll offset or the index/offset of the first visible item.

**Measurement availability**: If items have dynamic heights, their measurements must be available before scroll restoration, otherwise the calculated position will be wrong.

**Deferred restoration**: In some cases, wait until initial render and measurement complete before restoring scroll position, or restore to an approximate position that's corrected as measurements arrive.

### Performance Considerations

**Layout thrashing**: Interleaving reads (measuring heights) and writes (setting positions) causes forced synchronous layouts. Batch all measurements, then apply all position updates.

**Reflow triggers**: Changing `top`, `left`, or dimensions on positioned elements can trigger reflows. Transforms generally perform better as they're compositor-only operations in many cases.

**Memory vs. render cost**: Larger buffers increase memory usage and initial render time but reduce update frequency. The optimal balance depends on item complexity and scroll behavior patterns.

**Event listener management**: Attaching listeners to many recycled elements can create memory leaks if not properly cleaned. Use event delegation where possible, attaching listeners to the container rather than individual items.

### Edge Cases and Boundary Conditions

**Empty lists**: Handle zero-item cases without errors—render empty state, avoid division by zero in calculations.

**Single item**: When only one item exists, scrolling logic may behave unexpectedly if it assumes multiple items.

**Viewport larger than content**: If total content height is less than viewport height, scrolling shouldn't occur. Ensure calculations handle this gracefully.

**Rapid scroll to end**: When users rapidly scroll to the bottom (or use "jump to end"), the virtualizer must quickly calculate and render the final range without iterating through all intermediate positions.

**Fractional pixels**: Scroll positions and item heights may be fractional. Rounding inconsistencies can accumulate, causing misalignment. Use consistent rounding strategies throughout calculations.

### Interaction with Browser APIs

**IntersectionObserver**: Can detect when items enter/leave viewport, providing an alternative to scroll event listeners. May have better performance characteristics but requires different architecture—observers per item or range rather than centralized scroll handling.

**ResizeObserver**: Detects when container or items change size, triggering recalculation. Essential for responsive layouts where viewport dimensions change.

**Scrollbar behavior**: Virtual scrolling must maintain realistic scrollbar thumb size and position. The scrollbar represents the entire list, not just rendered items. This requires setting an explicit scroll height on the container or spacer element.

### Sticky Elements

Supporting sticky headers or footers within virtualized lists requires special handling:

**Position tracking**: Sticky elements must remain rendered even when their natural position scrolls out of view. Track which elements should be sticky and their stick points.

**Z-index management**: Sticky elements need higher stacking order to appear above scrolling content.

**Multiple sticky items**: When multiple headers stack (e.g., nested groups), manage the stack order and positioning as items enter/exit sticky states.

### Focus and Accessibility

Virtual scrolling creates accessibility challenges:

**Screen reader navigation**: Screen readers may not see non-rendered items. Implementing proper ARIA attributes (`aria-rowcount`, `aria-rowindex`) helps communicate the full list size.

**Keyboard navigation**: When a focused item scrolls out and is removed from DOM, focus is lost. Trap and restore focus as items recycle, or maintain focus on a container element.

**Tab order**: Only rendered items are in tab order. Users can't tab to non-rendered items, which may be unexpected behavior.

### Scroll Anchoring

CSS scroll anchoring can interfere with virtual scrolling. When content above the viewport changes (items are added, heights adjust), the browser may automatically adjust scroll position to keep content stable. This can conflict with the virtualizer's position management.

Setting `overflow-anchor: none` on the scroll container typically disables this behavior, giving the virtualizer full control over positioning.

### Data Updates and Reactivity

When underlying data changes:

**Item addition/removal**: Recalculate total height and visible range. If items are added above the viewport, adjust scroll position to maintain visual stability.

**Item updates**: If an update changes item height, remeasure and recalculate positions for subsequent items. This can cascade—updating one item affects all items below it.

**Batch updates**: Grouping multiple data changes into a single update cycle prevents redundant recalculations and renders.

### Implementation Patterns

**Render prop**: Virtualizer handles calculations and provides render information (`visibleItems`, `itemStyle`) to a render function that returns the actual item JSX/HTML.

**Wrapper component**: Virtualizer wraps the list, intercepting scroll events and injecting positioning props into item components.

**Hook-based**: Custom hooks (like `useVirtualizer`) expose virtualization state and utilities, leaving rendering to the consumer.

### Window Scrolling vs. Container Scrolling

**Window as scroll container**: The entire page scrolls, with the list taking up page space. Scroll events come from `window`, and item positions are relative to page top.

**Dedicated container**: A fixed-height element with overflow scrolling. More common in application UIs where the list is one component among many. Positions are relative to container top.

Window scrolling eliminates the need for a fixed-height container but complicates position calculations when other page content affects the list's offset.

---

