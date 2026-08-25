## CSS Performance


### Selector Performance

CSS selector performance directly impacts how quickly browsers can match elements and apply styles. The browser reads selectors from right to left, making the rightmost selector (key selector) the most critical for performance.

**Key points:**

- ID selectors (#id) are fastest, followed by classes (.class), then elements (div)
- Universal selectors (*) and attribute selectors are slowest
- Descendant selectors require traversing the DOM tree upward
- Child selectors (>) are more efficient than descendant selectors (space)

The most expensive selectors include complex pseudo-selectors like :nth-child(), deeply nested descendant selectors, and universal selectors combined with other selectors. Modern browsers have optimized selector engines, but inefficient selectors can still cause performance bottlenecks in large DOMs.

**Example:**

```css
/* Slow - universal selector with descendant */
* div p { color: red; }

/* Faster - specific class */
.content-text { color: red; }

/* Slow - complex nth-child */
div:nth-child(2n+1) p:first-child { margin: 0; }

/* Faster - direct class targeting */
.odd-content-first { margin: 0; }
```

Selector specificity also affects performance. Highly specific selectors force browsers to do more work during cascade resolution. Keeping specificity low and using classes over complex selectors improves both performance and maintainability.

### Paint and Layout Optimization

Paint and layout operations are among the most expensive processes in the browser rendering pipeline. Layout (reflow) recalculates element positions and dimensions, while paint renders the visual properties.

**Key points:**

- Properties triggering layout: width, height, margin, padding, border, position, top, left
- Properties triggering paint only: color, background, box-shadow, border-radius
- Composite-only properties: transform, opacity, filter
- Use transform and opacity for animations instead of layout/paint properties

Layout thrashing occurs when multiple layout-triggering properties change simultaneously or repeatedly. This forces the browser to recalculate layouts multiple times per frame, causing janky animations and poor user experience.

**Example:**

```css
/* Triggers layout - expensive */
.slide-in {
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from { left: -100px; }
  to { left: 0; }
}

/* Composite only - performant */
.slide-in-optimized {
  animation: slideInOptimized 0.3s ease-out;
}

@keyframes slideInOptimized {
  from { transform: translateX(-100px); }
  to { transform: translateX(0); }
}
```

The browser's rendering pipeline follows: Layout → Paint → Composite. Skipping earlier stages by using composite-only properties creates smoother animations and better performance.

### CSS Containment

CSS containment isolates parts of the DOM to prevent rendering work from affecting other elements. This optimization helps browsers skip unnecessary calculations in unaffected areas.

**Key points:**

- Layout containment prevents layout changes from affecting parent/sibling elements
- Paint containment ensures element contents don't paint outside boundaries
- Size containment makes element size independent of children
- Style containment isolates CSS counters and quotes

The contain property accepts multiple values: layout, paint, size, style, and the shorthand strict (layout + paint + style). Containment is particularly valuable for components that change frequently or contain complex layouts.

**Example:**

```css
/* Isolate component rendering */
.widget {
  contain: layout paint;
}

/* Full containment for independent components */
.modal {
  contain: strict;
}

/* Size containment for fixed-size containers */
.thumbnail-grid {
  contain: size layout;
}
```

Containment works best with components that have predictable boundaries and don't need to influence parent layouts. Overusing containment can break expected CSS behaviors like margin collapsing or absolute positioning contexts.

### Critical CSS Strategies

Critical CSS involves identifying and inlining the styles needed for above-the-fold content, deferring non-critical styles to improve perceived performance and First Contentful Paint (FCP).

**Key points:**

- Inline critical CSS in the HTML head to eliminate render-blocking requests
- Defer non-critical CSS using media queries or JavaScript loading
- Optimize for the largest viewport sizes and most common devices
- Regularly audit and update critical CSS as designs evolve

Critical CSS extraction can be automated using tools like Critical, Critters, or PurgeCSS. The goal is keeping critical CSS under 14KB (TCP slow-start limit) while covering essential layout and typography.

**Example:**

```html
<!-- Inline critical CSS -->
<style>
  body { font-family: Arial, sans-serif; margin: 0; }
  .header { background: #333; color: white; padding: 1rem; }
  .hero { height: 100vh; background: linear-gradient(...); }
</style>

<!-- Defer non-critical CSS -->
<link rel="preload" href="styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="styles.css"></noscript>

<!-- Or use media queries -->
<link rel="stylesheet" href="print.css" media="print">
<link rel="stylesheet" href="mobile.css" media="(max-width: 768px)">
```

Advanced strategies include using HTTP/2 Server Push for critical CSS, implementing CSS splitting by route or component, and using service workers to cache and serve optimized CSS bundles.

**Conclusion:** CSS performance optimization requires understanding the browser's rendering pipeline and making informed decisions about selector complexity, property choices, containment boundaries, and critical resource delivery. The most impactful optimizations focus on reducing layout thrashing, leveraging compositor-only properties, and ensuring fast initial renders through strategic CSS loading.

---

