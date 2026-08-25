## CSS Layout Techniques


### Sticky Positioning

Sticky positioning creates elements that toggle between relative and fixed positioning based on scroll position. An element with `position: sticky` behaves like a relatively positioned element until it crosses a specified threshold, then becomes fixed.

**Key points:**

- Element must have at least one of `top`, `right`, `bottom`, or `left` specified
- The element sticks within its containing block
- Commonly used for navigation bars, table headers, and section headings
- Works with overflow containers, not just the viewport

**Example:**

```css
.sticky-header {
  position: sticky;
  top: 0;
  background-color: white;
  z-index: 100;
}

.sidebar {
  position: sticky;
  top: 20px;
  height: fit-content;
}
```

**Output:** The header remains at the top of the viewport when scrolling, while the sidebar sticks 20px from the top within its container.

### CSS Exclusions

CSS Exclusions allow content to flow around arbitrary shapes, extending beyond the limitations of float-based layouts. This feature enables text and inline content to wrap around complex geometric shapes.

**Key points:**

- Uses `wrap-flow` and `wrap-through` properties
- Shapes defined with `shape-outside`, `shape-margin`, and `shape-image-threshold`
- Currently limited browser support (primarily legacy Edge)
- Provides magazine-style layouts with text flowing around images and shapes

**Example:**

```css
.exclusion-element {
  wrap-flow: both;
  shape-outside: circle(50%);
  shape-margin: 20px;
  float: left;
}

.content-container {
  wrap-through: none;
}
```

**Output:** Content flows around the circular shape with a 20px margin, creating organic text layouts.

### Multi-Column Layout

Multi-column layout automatically flows content into multiple columns, similar to newspaper layouts. Content breaks naturally across columns with automatic balancing.

**Key points:**

- Controlled by `column-count`, `column-width`, or `columns` shorthand
- `column-gap` sets spacing between columns
- `column-rule` adds visual separators
- `break-inside`, `break-before`, `break-after` control content breaking
- `column-span` allows elements to span across all columns

**Example:**

```css
.article {
  columns: 3;
  column-gap: 2rem;
  column-rule: 1px solid #ccc;
}

.article h2 {
  column-span: all;
  margin: 2rem 0 1rem;
}

.article p {
  break-inside: avoid;
}
```

**Output:** Content flows into three balanced columns with ruled separators, headings spanning the full width, and paragraphs avoiding breaks.

### Advanced Multi-Column Properties

**Column Fill and Balancing:**

```css
.balanced-columns {
  columns: 4;
  column-fill: balance; /* Default - equal height columns */
}

.sequential-columns {
  column-fill: auto; /* Fill columns sequentially */
  height: 400px; /* Required for auto fill */
}
```

**Orphans and Widows Control:**

```css
.text-content {
  orphans: 3; /* Minimum lines at bottom of column */
  widows: 2;  /* Minimum lines at top of column */
}
```

### CSS Regions

CSS Regions allow content to flow through multiple, disconnected containers, enabling complex magazine-style layouts where content flows between non-adjacent elements.

**Key points:**

- Uses named flows with `flow-into` and `flow-from` properties
- Content flows from source elements into region chains
- Regions can be positioned independently
- Experimental feature with limited browser support
- Being replaced by CSS Grid and Flexbox solutions

**Example:**

```css
.article-content {
  flow-into: article-flow;
}

.region-1, .region-2, .region-3 {
  flow-from: article-flow;
}

.region-1 {
  width: 100%;
  height: 200px;
}

.region-2, .region-3 {
  width: 48%;
  height: 300px;
  display: inline-block;
}
```

**Output:** Content flows from the article source through three separate regions, creating complex layouts where text continues across disconnected containers.

### Modern Layout Alternatives

**CSS Grid for Complex Layouts:**

```css
.magazine-layout {
  display: grid;
  grid-template-areas: 
    "header header header"
    "sidebar main aside"
    "footer footer footer";
  grid-template-columns: 200px 1fr 150px;
  gap: 20px;
}
```

**Flexbox for Component-Level Layout:**

```css
.card-container {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.card {
  flex: 1 1 300px;
  min-height: 200px;
}
```

### Browser Support Considerations

**Sticky Positioning:** Well-supported across modern browsers, with fallback strategies using JavaScript scroll events.

**CSS Exclusions:** Limited support, primarily in legacy Edge. Use feature queries for progressive enhancement.

**Multi-Column Layout:** Good support in modern browsers, with vendor prefixes for older versions.

**CSS Regions:** Removed from most browsers due to complexity and performance concerns.

**Conclusion:** Modern CSS layout combines these techniques strategically. Sticky positioning provides practical scroll-based behavior, multi-column layout handles text-heavy content effectively, while CSS Grid and Flexbox offer more reliable alternatives to experimental features like regions and exclusions.

**Next steps:** Consider CSS Container Queries for responsive component design, CSS Subgrid for advanced grid layouts, and CSS Logical Properties for internationalization-friendly layouts.

---

