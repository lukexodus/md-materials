## CSS Container Queries


### Understanding Container Queries

Container queries represent a paradigm shift in responsive design, allowing elements to respond to the size and properties of their containing element rather than the viewport. This enables true component-based responsive design where components can adapt to their context regardless of where they appear on the page.

Traditional media queries respond to viewport dimensions, creating global breakpoints that affect the entire page. Container queries create local breakpoints that respond to individual container dimensions, enabling more granular and flexible responsive behavior.

Container queries solve the fundamental problem of designing reusable components that need to adapt to different contexts. A card component might appear in a sidebar, main content area, or modal dialog, each requiring different responsive behavior based on available space.

### Container Query Syntax

#### Basic Container Query Structure

Container queries follow a similar syntax to media queries but use `@container` instead of `@media`:

```css
@container (min-width: 400px) {
  .card {
    display: flex;
    flex-direction: row;
  }
}
```

#### Container Registration

Before querying a container, you must establish containment using the `container-type` property:

```css
.container {
  container-type: inline-size; /* Creates a size query container */
}

.container {
  container-type: size; /* Creates a size query container for both dimensions */
}

.container {
  container-type: normal; /* Disables containment */
}
```

#### Named Containers

Containers can be named for more specific targeting:

```css
.sidebar {
  container-name: sidebar;
  container-type: inline-size;
}

.main-content {
  container-name: main;
  container-type: inline-size;
}

@container sidebar (min-width: 300px) {
  .widget {
    padding: 20px;
  }
}

@container main (min-width: 600px) {
  .article {
    columns: 2;
  }
}
```

#### Container Shorthand

The `container` property combines `container-name` and `container-type`:

```css
.sidebar {
  container: sidebar / inline-size;
}

.main-content {
  container: main / size;
}
```

### Size Queries

#### Basic Size Query Conditions

Size queries test the dimensions of the containment context:

```css
/* Width-based queries */
@container (min-width: 300px) { /* styles */ }
@container (max-width: 600px) { /* styles */ }
@container (width >= 400px) { /* styles */ }

/* Height-based queries */
@container (min-height: 200px) { /* styles */ }
@container (max-height: 500px) { /* styles */ }
@container (height <= 300px) { /* styles */ }

/* Aspect ratio queries */
@container (aspect-ratio > 1) { /* styles */ }
@container (min-aspect-ratio: 16/9) { /* styles */ }

/* Orientation queries */
@container (orientation: landscape) { /* styles */ }
@container (orientation: portrait) { /* styles */ }
```

#### Complex Size Query Logic

Container queries support logical operators for complex conditions:

```css
/* AND logic */
@container (min-width: 400px) and (min-height: 300px) {
  .component {
    display: grid;
    grid-template-columns: 1fr 1fr;
  }
}

/* OR logic */
@container (min-width: 600px), (orientation: landscape) {
  .content {
    flex-direction: row;
  }
}

/* NOT logic */
@container not (min-width: 400px) {
  .navigation {
    display: none;
  }
}
```

#### Nested Container Queries

Container queries can be nested for more specific conditions:

```css
@container (min-width: 400px) {
  .card {
    padding: 20px;
  }
  
  @container (min-height: 300px) {
    .card-content {
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }
  }
}
```

### Style Queries

#### Introduction to Style Queries

Style queries allow components to respond to CSS custom property values within their containment context:

```css
.theme-container {
  container-type: style;
  --theme: dark;
}

@container style(--theme: dark) {
  .button {
    background: #333;
    color: white;
  }
}

@container style(--theme: light) {
  .button {
    background: #fff;
    color: #333;
  }
}
```

#### Custom Property Queries

Style queries can test various aspects of custom properties:

```css
/* Exact value matching */
@container style(--layout: grid) {
  .component {
    display: grid;
  }
}

/* Numeric comparisons */
@container style(--columns >= 3) {
  .grid {
    grid-template-columns: repeat(var(--columns), 1fr);
  }
}

/* Multiple property queries */
@container style(--theme: dark) and style(--size: large) {
  .card {
    background: #222;
    padding: 30px;
    font-size: 1.2em;
  }
}
```

#### Boolean-Style Queries

Custom properties can act as boolean flags:

```css
.component-container {
  container-type: style;
  --has-sidebar: 1;
  --is-mobile: 0;
}

@container style(--has-sidebar: 1) {
  .main-content {
    margin-left: 250px;
  }
}

@container style(--is-mobile: 1) {
  .navigation {
    position: fixed;
    bottom: 0;
  }
}
```

### Container Query Units

#### Unit Types and Usage

Container query units provide length values relative to the query container:

- `cqw`: 1% of the query container's width
- `cqh`: 1% of the query container's height
- `cqi`: 1% of the query container's inline size
- `cqb`: 1% of the query container's block size
- `cqmin`: 1% of the smaller value between `cqi` and `cqb`
- `cqmax`: 1% of the larger value between `cqi` and `cqb`

#### Practical Unit Applications

```css
.container {
  container-type: inline-size;
}

.responsive-text {
  /* Font size scales with container width */
  font-size: clamp(1rem, 4cqw, 2rem);
}

.responsive-spacing {
  /* Padding scales with container size */
  padding: 2cqw 3cqw;
}

.responsive-grid {
  /* Grid gap relative to container */
  gap: 2cqmin;
}
```

#### Container Units vs Viewport Units

Container units provide more granular control than viewport units:

```css
/* Viewport-based (global) */
.hero-text {
  font-size: 4vw; /* Scales with viewport */
}

/* Container-based (local) */
.card-title {
  font-size: 6cqw; /* Scales with card container */
}
```

### Practical Implementation Patterns

#### Responsive Card Components

```css
.card-container {
  container: card / inline-size;
}

.card {
  padding: 1rem;
  border: 1px solid #ddd;
}

@container card (min-width: 300px) {
  .card {
    display: flex;
    align-items: center;
    gap: 1rem;
  }
  
  .card-image {
    flex: 0 0 100px;
  }
  
  .card-content {
    flex: 1;
  }
}

@container card (min-width: 500px) {
  .card {
    padding: 2rem;
  }
  
  .card-title {
    font-size: clamp(1.2rem, 4cqw, 1.8rem);
  }
}
```

#### Adaptive Navigation

```css
.navigation-container {
  container: nav / inline-size;
}

.navigation {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

@container nav (max-width: 600px) {
  .navigation {
    flex-direction: column;
  }
  
  .nav-item {
    width: 100%;
    text-align: center;
  }
}

@container nav (min-width: 800px) {
  .navigation {
    justify-content: space-between;
  }
  
  .nav-item {
    padding: 0.5rem 1rem;
  }
}
```

#### Dashboard Widgets

```css
.widget-container {
  container: widget / size;
}

.widget {
  background: white;
  border-radius: 8px;
  padding: 1rem;
}

@container widget (min-width: 200px) and (min-height: 150px) {
  .widget-chart {
    display: block;
    height: 8cqh;
  }
}

@container widget (min-width: 300px) {
  .widget {
    padding: 1.5rem;
  }
  
  .widget-title {
    font-size: 1.2rem;
    margin-bottom: 1rem;
  }
}

@container widget (aspect-ratio > 1.5) {
  .widget-content {
    display: flex;
    align-items: center;
    gap: 1rem;
  }
}
```

### Advanced Container Query Techniques

#### Container Query Polyfills and Fallbacks

```css
/* Fallback for browsers without container query support */
.card {
  padding: 1rem;
}

/* Progressive enhancement */
@supports (container-type: inline-size) {
  .card-container {
    container-type: inline-size;
  }
  
  @container (min-width: 400px) {
    .card {
      display: flex;
      gap: 1rem;
    }
  }
}
```

#### Combining Container Queries with CSS Grid

```css
.grid-container {
  container: layout / inline-size;
  display: grid;
  gap: 1rem;
}

@container layout (min-width: 400px) {
  .grid-container {
    grid-template-columns: repeat(2, 1fr);
  }
}

@container layout (min-width: 600px) {
  .grid-container {
    grid-template-columns: repeat(3, 1fr);
  }
}

@container layout (min-width: 800px) {
  .grid-container {
    grid-template-columns: repeat(4, 1fr);
  }
}
```

#### Dynamic Theme Switching

```css
.theme-aware-container {
  container: theme / style;
  --theme-mode: light;
  --accent-color: blue;
}

@container style(--theme-mode: dark) {
  .component {
    background: #1a1a1a;
    color: #ffffff;
  }
}

@container style(--theme-mode: dark) and style(--accent-color: blue) {
  .accent-element {
    color: #4a9eff;
  }
}

@container style(--theme-mode: light) and style(--accent-color: blue) {
  .accent-element {
    color: #0066cc;
  }
}
```

### Performance Considerations

#### Containment Impact

Container queries create layout, style, and paint containment, which can improve performance by limiting recalculation scope:

```css
.optimized-container {
  container-type: inline-size;
  /* Creates layout and style containment */
}
```

#### Avoiding Over-Querying

Minimize the number of container queries to prevent performance issues:

```css
/* Less efficient - multiple similar queries */
@container (min-width: 300px) { .a { color: blue; } }
@container (min-width: 301px) { .b { color: red; } }
@container (min-width: 302px) { .c { color: green; } }

/* More efficient - consolidated breakpoints */
@container (min-width: 300px) {
  .a { color: blue; }
  .b { color: red; }
  .c { color: green; }
}
```

### Browser Support and Feature Detection

#### Progressive Enhancement Strategy

```css
/* Base styles for all browsers */
.component {
  padding: 1rem;
  background: #f5f5f5;
}

/* Enhanced styles for container query support */
@supports (container-type: inline-size) {
  .component-container {
    container-type: inline-size;
  }
  
  @container (min-width: 400px) {
    .component {
      display: flex;
      gap: 1rem;
      padding: 2rem;
    }
  }
}
```

#### JavaScript Feature Detection

```javascript
if (CSS.supports('container-type', 'inline-size')) {
  // Container queries are supported
  document.documentElement.classList.add('supports-container-queries');
} else {
  // Fallback behavior
  document.documentElement.classList.add('no-container-queries');
}
```

### Debugging Container Queries

#### Browser DevTools

Modern browser developer tools provide container query debugging features:

- Chrome DevTools shows container query information in the Elements panel
- Firefox DevTools displays container boundaries and query matches
- Safari Web Inspector includes container query debugging support

#### CSS Debugging Techniques

```css
/* Visual debugging for containers */
.debug-container {
  container-type: inline-size;
  outline: 2px dashed red;
  position: relative;
}

.debug-container::before {
  content: "Container: " attr(data-container-name);
  position: absolute;
  top: -20px;
  left: 0;
  font-size: 12px;
  background: red;
  color: white;
  padding: 2px 4px;
}
```

### Common Pitfalls and Solutions

#### Containment Context Issues

Ensure proper containment context establishment:

```css
/* Problem: No containment established */
@container (min-width: 400px) {
  .component { /* This won't work */ }
}

/* Solution: Establish containment */
.container {
  container-type: inline-size;
}

@container (min-width: 400px) {
  .component { /* This works */ }
}
```

#### Circular Dependencies

Avoid creating circular dependencies between container size and content:

```css
/* Problematic: Container size depends on content that depends on container */
.problematic-container {
  container-type: inline-size;
  width: max-content; /* Size depends on content */
}

@container (min-width: 400px) {
  .content {
    width: 500px; /* Content size affects container */
  }
}
```

#### Z-Index and Stacking Context

Container queries create new stacking contexts, which can affect z-index behavior:

```css
.container {
  container-type: inline-size;
  /* Creates new stacking context */
}

@container (min-width: 400px) {
  .modal {
    z-index: 1000; /* Relative to container's stacking context */
  }
}
```

**Key points**: Container queries enable component-level responsive design by responding to container dimensions rather than viewport size. They require establishing containment contexts using `container-type` and support both size and style-based queries.

**Example**: A card component can switch from vertical to horizontal layout when its container reaches 400px width, regardless of viewport size: `@container (min-width: 400px) { .card { flex-direction: row; } }`

**Output**: Container queries produce more flexible, reusable components that adapt to their context, enabling truly modular responsive design patterns.

**Conclusion**: CSS Container Queries represent the future of responsive design, moving from global viewport-based breakpoints to local container-based responsive behavior. They enable more maintainable and flexible component architectures.

**Next steps**: Begin implementing container queries in component libraries, establish naming conventions for containers, and consider the performance implications of containment contexts in your applications.

---
