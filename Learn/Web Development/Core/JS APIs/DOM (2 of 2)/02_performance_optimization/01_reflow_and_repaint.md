## Reflow and Repaint


### Core Mechanisms

**Reflow** (also called layout) is the process where the browser calculates the positions and dimensions of elements in the document. This involves computing the geometry of the render tree—determining where each element sits and how much space it occupies based on the CSS box model, positioning properties, and content.

**Repaint** (also called redraw) is the process where the browser fills in pixels for visual properties that don't affect layout. This involves drawing text, colors, images, borders, shadows, and other visual properties to the screen.

### Critical Distinction

Reflows always trigger repaints because changing element geometry requires redrawing the affected areas. However, repaints can occur without reflows when only visual properties change (like `color`, `background-color`, `visibility`).

### Reflow Triggers

**Geometric property changes:**

- Width, height, margin, padding, border
- Position (top, left, right, bottom)
- Display property changes
- Float and clear operations

**Content modifications:**

- Text content changes
- Image dimension changes
- Adding/removing DOM nodes
- Font-size adjustments

**Layout queries (forced synchronous layout):**

- `offsetWidth`, `offsetHeight`, `offsetTop`, `offsetLeft`
- `scrollTop`, `scrollWidth`, `scrollHeight`
- `clientWidth`, `clientHeight`
- `getComputedStyle()`
- `getBoundingClientRect()`

When JavaScript reads these properties, the browser must ensure layout calculations are current, potentially triggering immediate reflow.

**Window operations:**

- Resizing the viewport
- Changing device orientation
- Scrolling (can trigger reflows for fixed/sticky positioned elements)
- Font loading completion

**CSS changes:**

- Adding/removing stylesheets
- Modifying CSS rules
- Pseudo-class changes (`:hover`, `:focus`)

### Repaint-Only Triggers

Properties that affect appearance without geometry:

- `color`
- `background-color`, `background-image`
- `visibility` (note: `display: none` triggers reflow)
- `outline` and `outline-color`
- `box-shadow` (non-expanding)
- `opacity` changes (though GPU-accelerated properties may avoid even repaint)

### Propagation and Scope

**Local vs. Global Reflows:**

- Local reflows affect a subtree of the DOM when changes are constrained by layout boundaries
- Global reflows recalculate layout for the entire document or large portions

**Reflow propagation patterns:**

- Changes to parent elements often trigger reflows of descendants
- Sibling elements may reflow if they're in normal flow and affected by dimension changes
- Absolutely positioned elements have limited reflow impact on siblings
- Fixed positioning removes elements from normal flow, reducing propagation

### Browser Optimization Strategies

**Reflow batching:** Browsers queue DOM and style changes, then execute them in batches during the next repaint cycle. This amortizes the cost across multiple changes.

**Dirty bit system:** Browsers mark affected elements as "dirty" and only recalculate those portions during reflow operations rather than the entire tree.

**Incremental reflow:** Modern browsers can perform partial reflows on specific subtrees when changes are isolated, avoiding full document recalculation.

**Layout boundaries:** Certain elements establish layout containment boundaries (like `overflow: hidden` containers or elements with fixed dimensions), limiting reflow scope.

### Performance Characteristics

**Computational complexity:** Reflow is computationally expensive because it involves recursive tree traversal and geometric calculations. Complex selectors, deep DOM trees, and intricate layouts amplify this cost.

**Timing considerations:**

- Reflows are synchronous and block the main thread
- Multiple reflows within a single JavaScript execution can compound performance issues
- Layout thrashing occurs when alternating reads and writes force multiple synchronous reflows

### Layout Thrashing Pattern

```javascript
// Anti-pattern: causes multiple reflows
for (let i = 0; i < elements.length; i++) {
  const height = elements[i].offsetHeight; // read (reflow)
  elements[i].style.height = height + 10 + 'px'; // write (invalidates layout)
}

// Optimized: batch reads, then writes
const heights = [];
for (let i = 0; i < elements.length; i++) {
  heights[i] = elements[i].offsetHeight; // batch reads
}
for (let i = 0; i < elements.length; i++) {
  elements[i].style.height = heights[i] + 10 + 'px'; // batch writes
}
```

### Mitigation Techniques

**Batch DOM modifications:**

- Use DocumentFragment for multiple insertions
- Clone nodes, modify offline, then replace
- Use `innerHTML` for bulk content changes instead of incremental DOM manipulation

**Cache layout values:** Store computed dimensions in variables rather than repeatedly querying the DOM.

**Minimize layout queries:** Avoid reading layout properties inside loops or during animations.

**CSS class toggling:** Change classes rather than individual style properties to leverage browser optimizations.

**Detachment strategy:** Remove elements from the DOM tree using `display: none` or `removeChild()`, modify them, then reattach.

**CSS containment:** Use `contain: layout` to establish containment boundaries and prevent reflow propagation.

**Transform and opacity for animations:** These properties can be GPU-accelerated and bypass layout/paint in the compositor thread.

### Compositor-Only Properties

Modern browsers can handle certain properties entirely on the compositor thread, avoiding main-thread reflow/repaint:

- `transform` (translate, rotate, scale)
- `opacity`
- `filter` (with GPU support)

These changes occur on a separate layer and don't require recalculation of layout or paint operations on the main thread.

### Layer Promotion

**When browsers create layers:**

- Elements with `will-change` property
- 3D transforms or perspective
- `<video>` and `<canvas>` elements
- Elements with CSS filters
- Overlapping with other composited elements

**Layer implications:** Promoted layers enable hardware acceleration but consume GPU memory. Over-promotion can degrade performance.

### Developer Tools Integration

**Performance profiling:** Browser DevTools provide timeline/performance panels showing:

- Reflow events (Layout in Chrome, Reflow in Firefox)
- Paint operations
- Composite layer updates
- JavaScript execution triggering layout

**Layer visualization:** Chrome DevTools offers layer borders and compositing indicators to identify which elements are on separate layers.

**Layout shift metrics:** Cumulative Layout Shift (CLS) quantifies visual stability by measuring unexpected layout changes during page lifetime.

### Framework-Specific Considerations

**Virtual DOM libraries:** React and similar frameworks batch updates and minimize direct DOM manipulation, inherently reducing reflow frequency.

**Change detection:** Angular's zone.js triggers digest cycles that can bundle multiple DOM updates, though this doesn't prevent reflows from geometric queries within the cycle.

**Reactive systems:** Vue and Svelte compile templates to efficient update strategies, but developers must still avoid layout thrashing in imperative code.

### CSS Properties Impact Matrix

**High-cost properties (trigger reflow + repaint):**

- Width, height, position, display, float, margin, padding, border-width, font-size, line-height, vertical-align

**Medium-cost properties (trigger repaint only):**

- Color, background, border-color, border-style, box-shadow, text-decoration, visibility, outline

**Low-cost properties (compositor only, [Inference: based on GPU acceleration support]):**

- Transform, opacity, filter (when accelerated)

### Mobile and Resource-Constrained Considerations

Mobile devices have:

- Less CPU power for layout calculations
- Limited GPU memory for layer promotion
- Higher sensitivity to main-thread blocking
- Battery consumption concerns with excessive reflows

Reflow optimization is more critical on mobile platforms where performance budgets are tighter.

### Interaction with Other Systems

**Intersection Observer:** Provides an asynchronous way to observe element visibility changes without forced synchronous layout from scroll event handlers.

**Resize Observer:** Enables detection of element size changes without polling `getBoundingClientRect()`, reducing forced reflows.

**Mutation Observer:** Monitors DOM changes but doesn't prevent the reflows those changes cause—it only provides notification hooks.

---

