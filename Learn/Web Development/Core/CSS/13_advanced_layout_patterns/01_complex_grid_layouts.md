## Complex Grid Layouts


### Understanding Nested Grids and Subgrid

Nested grids involve placing grid containers inside other grid containers, creating hierarchical layout structures. Each nested grid operates independently with its own grid tracks, areas, and alignment properties. This approach provides flexibility but can lead to alignment challenges between parent and child grids.

Subgrid, introduced in CSS Grid Level 2, allows a grid item to inherit the grid tracks from its parent grid container. This creates seamless alignment between parent and child grid structures, solving many common layout problems that arise with nested grids.

The fundamental difference lies in track inheritance: nested grids create entirely new grid contexts, while subgrids share track definitions with their parent containers.

### Nested Grid Implementation

#### Basic Nested Grid Structure

```css
.main-grid {
  display: grid;
  grid-template-columns: 1fr 300px;
  grid-template-rows: auto 1fr auto;
  gap: 20px;
  min-height: 100vh;
}

.content-area {
  grid-column: 1;
  grid-row: 2;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 15px;
}

.sidebar {
  grid-column: 2;
  grid-row: 1 / -1;
  display: grid;
  grid-template-rows: auto 1fr auto;
  gap: 10px;
}
```

#### Multi-Level Nested Grids

```css
.page-layout {
  display: grid;
  grid-template-areas: 
    "header header"
    "main aside"
    "footer footer";
  grid-template-columns: 1fr 300px;
  grid-template-rows: auto 1fr auto;
}

.main-content {
  grid-area: main;
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 20px;
}

.article-grid {
  grid-column: 1 / -1;
  display: grid;
  grid-template-areas:
    "title title title"
    "content content meta"
    "tags tags tags";
  grid-template-columns: 2fr 1fr 1fr;
  gap: 15px;
}

.article-content {
  grid-area: content;
  display: grid;
  grid-template-rows: auto 1fr;
  gap: 10px;
}
```

#### Nested Grid Alignment Challenges

```css
/* Problem: Child grid items don't align with parent grid lines */
.parent-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 20px;
}

.child-grid {
  grid-column: span 3;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px; /* Different gap creates misalignment */
}

/* Solution: Coordinate gaps and track sizes */
.aligned-parent {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 20px;
}

.aligned-child {
  grid-column: span 3;
  display: grid;
  grid-template-columns: 1fr 20px 1fr 20px 1fr;
  grid-template-rows: auto;
}

.aligned-child > * {
  grid-column: odd;
}
```

### Subgrid Implementation

#### Basic Subgrid Syntax

```css
.parent-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(3, auto);
  gap: 20px;
}

.subgrid-item {
  grid-column: 1 / -1;
  grid-row: 2;
  display: grid;
  grid-template-columns: subgrid;
  grid-template-rows: subgrid;
}
```

#### Column Subgrid

```css
.main-layout {
  display: grid;
  grid-template-columns: 1fr 2fr 1fr 2fr;
  gap: 24px;
}

.card-container {
  grid-column: 1 / -1;
  display: grid;
  grid-template-columns: subgrid;
  gap: 12px;
}

.card {
  display: grid;
  grid-template-columns: subgrid;
  grid-column: span 2;
  border: 1px solid #ddd;
  padding: 16px;
}

.card-title {
  grid-column: 1;
}

.card-meta {
  grid-column: 2;
  text-align: right;
}
```

#### Row Subgrid

```css
.timeline {
  display: grid;
  grid-template-columns: auto 1fr;
  grid-template-rows: repeat(auto-fit, auto);
  gap: 16px 24px;
}

.timeline-event {
  grid-column: 1 / -1;
  display: grid;
  grid-template-rows: subgrid;
  grid-row: span 3;
}

.event-time {
  grid-column: 1;
  grid-row: 1;
}

.event-title {
  grid-column: 2;
  grid-row: 1;
  font-weight: bold;
}

.event-description {
  grid-column: 2;
  grid-row: 2;
}

.event-tags {
  grid-column: 2;
  grid-row: 3;
}
```

#### Bidirectional Subgrid

```css
.data-table {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  grid-template-rows: auto repeat(auto-fit, auto);
  gap: 1px;
  background: #ddd;
}

.table-section {
  grid-column: 1 / -1;
  display: grid;
  grid-template-columns: subgrid;
  grid-template-rows: subgrid;
  grid-row: span 4;
  background: white;
}

.section-header {
  grid-column: 1 / -1;
  background: #f5f5f5;
  font-weight: bold;
  padding: 12px;
}

.data-row {
  grid-column: 1 / -1;
  display: grid;
  grid-template-columns: subgrid;
}

.data-cell {
  padding: 8px 12px;
  border-right: 1px solid #eee;
}
```

### Subgrid Naming and Areas

#### Named Grid Lines with Subgrid

```css
.layout-grid {
  display: grid;
  grid-template-columns: 
    [sidebar-start] 250px 
    [sidebar-end main-start] 1fr 
    [main-end aside-start] 300px 
    [aside-end];
  gap: 20px;
}

.content-subgrid {
  grid-column: main-start / aside-end;
  display: grid;
  grid-template-columns: subgrid;
}

.main-content {
  grid-column: main-start / main-end;
}

.sidebar-widget {
  grid-column: aside-start / aside-end;
}
```

#### Grid Areas with Subgrid

```css
.page-grid {
  display: grid;
  grid-template-areas:
    "header header header"
    "nav main aside"
    "footer footer footer";
  grid-template-columns: 200px 1fr 250px;
  grid-template-rows: auto 1fr auto;
  gap: 16px;
}

.main-section {
  grid-area: main;
  display: grid;
  grid-template-columns: subgrid;
  grid-template-rows: auto 1fr auto;
}

.article-header {
  grid-column: 1;
  grid-row: 1;
}

.article-content {
  grid-column: 1;
  grid-row: 2;
  display: grid;
  grid-template-columns: subgrid;
}
```

### Grid and Flexbox Combinations

#### Grid Container with Flex Items

```css
.hybrid-layout {
  display: grid;
  grid-template-columns: 1fr 2fr 1fr;
  grid-template-rows: auto 1fr auto;
  gap: 20px;
  min-height: 100vh;
}

.flex-sidebar {
  grid-column: 1;
  grid-row: 2;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.flex-widget {
  flex: 0 0 auto;
  display: flex;
  flex-direction: column;
  background: white;
  border-radius: 8px;
  overflow: hidden;
}

.widget-header {
  flex: 0 0 auto;
  padding: 16px;
  background: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}

.widget-content {
  flex: 1 1 auto;
  padding: 16px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
```

#### Flex Container with Grid Items

```css
.card-deck {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  justify-content: center;
}

.grid-card {
  flex: 0 1 400px;
  min-height: 300px;
  display: grid;
  grid-template-rows: auto 1fr auto;
  grid-template-columns: 1fr auto;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  overflow: hidden;
}

.card-image {
  grid-column: 1 / -1;
  grid-row: 1;
  aspect-ratio: 16/9;
  object-fit: cover;
}

.card-title {
  grid-column: 1;
  grid-row: 2;
  padding: 16px 16px 8px;
  align-self: start;
}

.card-actions {
  grid-column: 2;
  grid-row: 2;
  padding: 16px;
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.card-footer {
  grid-column: 1 / -1;
  grid-row: 3;
  padding: 16px;
  background: #f8f9fa;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
```

#### Nested Flex within Grid

```css
.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
  padding: 24px;
}

.dashboard-panel {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  display: grid;
  grid-template-rows: auto 1fr;
  overflow: hidden;
}

.panel-header {
  padding: 20px;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel-content {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.metric-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #f3f4f6;
}

.metric-value {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}
```

### Responsive Grid Patterns

#### Auto-Fit and Auto-Fill Patterns

```css
/* Responsive card grid with minimum sizes */
.responsive-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  padding: 24px;
}

/* Responsive gallery with maximum columns */
.photo-gallery {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
  max-width: 1200px;
  margin: 0 auto;
}

/* Complex responsive pattern with different breakpoints */
.adaptive-grid {
  display: grid;
  gap: 20px;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 300px), 1fr));
}

@media (min-width: 768px) {
  .adaptive-grid {
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  }
}

@media (min-width: 1024px) {
  .adaptive-grid {
    grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
    max-width: 1400px;
    margin: 0 auto;
  }
}
```

#### Responsive Grid Areas

```css
.responsive-layout {
  display: grid;
  gap: 16px;
  padding: 16px;
  grid-template-areas:
    "header"
    "nav"
    "main"
    "aside"
    "footer";
  grid-template-rows: auto auto 1fr auto auto;
}

@media (min-width: 768px) {
  .responsive-layout {
    grid-template-areas:
      "header header"
      "nav main"
      "aside main"
      "footer footer";
    grid-template-columns: 200px 1fr;
    grid-template-rows: auto 1fr auto auto;
  }
}

@media (min-width: 1024px) {
  .responsive-layout {
    grid-template-areas:
      "header header header"
      "nav main aside"
      "footer footer footer";
    grid-template-columns: 200px 1fr 250px;
    grid-template-rows: auto 1fr auto;
  }
}

.header { grid-area: header; }
.nav { grid-area: nav; }
.main { grid-area: main; }
.aside { grid-area: aside; }
.footer { grid-area: footer; }
```

#### Container Query Responsive Grids

```css
.container-responsive-grid {
  container-type: inline-size;
  display: grid;
  gap: 16px;
  grid-template-columns: 1fr;
}

@container (min-width: 400px) {
  .container-responsive-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@container (min-width: 600px) {
  .container-responsive-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@container (min-width: 800px) {
  .container-responsive-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}

/* Responsive subgrid within container queries */
.container-subgrid {
  container-type: inline-size;
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 16px;
}

.subgrid-section {
  grid-column: 1 / -1;
  display: grid;
  grid-template-columns: subgrid;
}

@container (min-width: 600px) {
  .subgrid-item {
    grid-column: span 2;
  }
}

@container (min-width: 900px) {
  .subgrid-item {
    grid-column: span 3;
  }
}
```

### Advanced Grid Layout Patterns

#### Masonry-Style Layout

```css
.masonry-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
  align-items: start;
}

.masonry-item {
  break-inside: avoid;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  overflow: hidden;
}

/* Using CSS Grid Level 3 masonry (experimental) */
.native-masonry {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  grid-template-rows: masonry;
  gap: 20px;
}
```

#### Magazine-Style Layout

```css
.magazine-layout {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  grid-template-rows: repeat(8, minmax(100px, auto));
  gap: 16px;
  max-width: 1200px;
  margin: 0 auto;
}

.feature-article {
  grid-column: 1 / 8;
  grid-row: 1 / 5;
  background: linear-gradient(rgba(0,0,0,0.4), rgba(0,0,0,0.6));
  background-blend-mode: overlay;
  display: grid;
  grid-template-rows: 1fr auto auto;
  color: white;
  position: relative;
}

.secondary-article {
  grid-column: 8 / -1;
  grid-row: 1 / 3;
  display: grid;
  grid-template-rows: auto 1fr auto;
}

.article-grid {
  grid-column: 1 / -1;
  grid-row: 5 / -1;
  display: grid;
  grid-template-columns: subgrid;
  grid-template-rows: subgrid;
}

.small-article {
  grid-column: span 3;
  grid-row: span 2;
  display: grid;
  grid-template-rows: auto 1fr auto;
}
```

#### Dashboard Layout Pattern

```css
.dashboard {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  grid-auto-rows: minmax(200px, auto);
  gap: 20px;
  padding: 20px;
}

.widget {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  display: grid;
  grid-template-rows: auto 1fr auto;
  overflow: hidden;
}

.widget-large {
  grid-column: span 2;
  grid-row: span 2;
}

.widget-wide {
  grid-column: span 2;
}

.widget-tall {
  grid-row: span 2;
}

/* Responsive dashboard */
@media (max-width: 768px) {
  .dashboard {
    grid-template-columns: 1fr;
  }
  
  .widget-large,
  .widget-wide,
  .widget-tall {
    grid-column: span 1;
    grid-row: span 1;
  }
}
```

### Performance Optimization

#### Grid Performance Best Practices

```css
/* Efficient: Use repeat() and auto-sizing */
.efficient-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

/* Less efficient: Manual column definitions */
.manual-grid {
  display: grid;
  grid-template-columns: 250px 250px 250px 250px;
  gap: 20px;
}

/* Optimize with CSS containment */
.contained-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  contain: layout style;
}

/* Use transform for animations instead of changing grid properties */
.animated-grid-item {
  transition: transform 0.3s ease;
}

.animated-grid-item:hover {
  transform: scale(1.05);
}
```

#### Memory and Layout Optimization

```css
/* Use CSS custom properties for dynamic grids */
.dynamic-grid {
  display: grid;
  grid-template-columns: repeat(var(--columns, 3), 1fr);
  grid-template-rows: repeat(var(--rows, auto), minmax(100px, auto));
  gap: var(--gap, 16px);
}

/* Optimize large grids with virtual scrolling patterns */
.virtual-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  height: 400px;
  overflow-y: auto;
  contain: strict;
}

/* Use will-change sparingly for animation optimization */
.animating-grid-item {
  will-change: transform;
}

.animating-grid-item.animation-complete {
  will-change: auto;
}
```

### Browser Support and Fallbacks

#### Progressive Enhancement for Subgrid

```css
.grid-container {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.grid-item {
  /* Fallback for browsers without subgrid */
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

/* Enhanced layout for subgrid support */
@supports (grid-template-columns: subgrid) {
  .grid-item {
    grid-template-columns: subgrid;
    grid-column: span 4;
  }
}
```

#### Flexbox Fallbacks

```css
.hybrid-layout {
  /* Flexbox fallback */
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}

.layout-item {
  flex: 1 1 300px;
}

/* Grid enhancement */
@supports (display: grid) {
  .hybrid-layout {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  }
  
  .layout-item {
    flex: none;
  }
}
```

**Key points**: Complex grid layouts combine nested grids, subgrid inheritance, and flexbox integration to create sophisticated responsive designs. Subgrid enables perfect alignment between parent and child grid structures, while grid-flexbox combinations leverage the strengths of both layout methods.

**Example**: A magazine layout using subgrid: `grid-template-columns: subgrid` allows child elements to align perfectly with the parent grid's column tracks, creating consistent alignment across multiple grid levels.

**Output**: These techniques produce flexible, maintainable layouts that adapt seamlessly across devices while maintaining precise control over element positioning and alignment.

**Conclusion**: Mastering complex grid layouts requires understanding the interplay between nested grids, subgrid inheritance, flexbox integration, and responsive design patterns. These tools enable the creation of sophisticated layouts that were previously impossible or required complex workarounds.

**Next steps**: Experiment with subgrid in supported browsers, develop reusable grid-flexbox component patterns, and consider the performance implications of complex nested grid structures in your applications.

---

