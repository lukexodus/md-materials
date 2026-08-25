## offsetWidth and offsetHeight


### Core Behavior

`offsetWidth` and `offsetHeight` are read-only properties that return the layout dimensions of an element in pixels as integers. These properties measure:

- **offsetWidth**: content width + horizontal padding + vertical scrollbar width (if rendered) + border width
- **offsetHeight**: content height + vertical padding + horizontal scrollbar height (if rendered) + border height

The values are rounded to the nearest integer. For inline elements with no layout box, both properties return `0`.

### Calculation Formula

```
offsetWidth = content width + paddingLeft + paddingRight + borderLeftWidth + borderRightWidth + vertical scrollbar width
offsetHeight = content height + paddingTop + paddingBottom + borderTopWidth + borderBottomWidth + horizontal scrollbar width
```

Margin is **not** included in either calculation.

### What Gets Included

**Included components:**

- Content dimensions (accounting for box-sizing)
- All padding (left, right, top, bottom)
- All borders (left, right, top, bottom)
- Scrollbar dimensions (when rendered and overlaying content)

**Excluded components:**

- Margins
- Pseudo-elements (::before, ::after)
- Transformed dimensions (transforms don't affect offset dimensions)
- Box shadows
- Outlines

### Scrollbar Handling

Scrollbar inclusion depends on the rendering behavior:

- **Classic scrollbars** (Windows, Linux): Occupy layout space and are included in offset dimensions
- **Overlay scrollbars** (macOS, mobile): Float over content and typically don't affect offset dimensions
- The `scrollbar-gutter` CSS property can reserve space for scrollbars even when not visible

### Box-Sizing Interaction

The `box-sizing` property affects how content dimensions are calculated, which impacts the final offset values:

**box-sizing: content-box** (default):

- Width/height apply only to content
- offsetWidth = width + padding + border + scrollbar

**box-sizing: border-box**:

- Width/height include content + padding + border
- offsetWidth = width + scrollbar (if applicable)

### Hidden Elements

Elements with `display: none` return `0` for both properties because they generate no layout box. Elements with `visibility: hidden` maintain their layout box and return normal offset dimensions.

### Performance Characteristics

Reading `offsetWidth` or `offsetHeight` forces a **synchronous layout recalculation** (reflow) if:

- Styles have been modified since the last layout
- The DOM structure has changed
- Other layout-dependent properties have been queried

This can create performance bottlenecks when:

- Reading offset properties in loops
- Interleaving reads and writes to the DOM
- Frequently querying dimensions during animations

**[Inference]** Batching all dimensional reads together before performing writes minimizes forced reflows.

### Layout Thrashing Prevention

```javascript
// Poor performance - alternating reads/writes
elements.forEach(el => {
  const width = el.offsetWidth; // Forces layout
  el.style.width = width + 10 + 'px'; // Invalidates layout
  const height = el.offsetHeight; // Forces layout again
  el.style.height = height + 10 + 'px'; // Invalidates layout again
});

// Better - batch reads, then writes
const dimensions = elements.map(el => ({
  width: el.offsetWidth,
  height: el.offsetHeight
}));

elements.forEach((el, i) => {
  el.style.width = dimensions[i].width + 10 + 'px';
  el.style.height = dimensions[i].height + 10 + 'px';
});
```

### Sub-Pixel Precision

Since offset dimensions return integers, sub-pixel values are rounded. For precise measurements including fractional pixels, use:

- `getBoundingClientRect()`: Returns DOMRect with floating-point dimensions
- `element.getBoundingClientRect().width` and `.height` provide sub-pixel accuracy

### Transform and Offset Dimensions

CSS transforms (scale, rotate, skew) do **not** affect `offsetWidth` or `offsetHeight`. These properties report the pre-transform layout dimensions:

```javascript
element.style.transform = 'scale(2)';
console.log(element.offsetWidth); // Returns original width, not doubled
```

For transformed dimensions, use `getBoundingClientRect()` which accounts for transforms.

### Comparison with Other Dimensional Properties

|Property|Includes Padding|Includes Border|Includes Scrollbar|Precision|Includes Transforms|
|---|---|---|---|---|---|
|offsetWidth/Height|✓|✓|✓|Integer|✗|
|clientWidth/Height|✓|✗|✗|Integer|✗|
|scrollWidth/Height|✓|✗|✗|Integer|✗|
|getBoundingClientRect()|✓|✓|✓|Float|✓|

### Use Cases

**Appropriate uses:**

- Measuring element dimensions for layout calculations
- Determining if elements fit within containers
- Positioning absolutely positioned elements relative to offset parents
- Calculating available space for dynamic content

**Less appropriate uses:**

- High-frequency animation measurements (use getBoundingClientRect() with requestAnimationFrame)
- Sub-pixel precision requirements
- Measuring transformed element dimensions

### Cross-Browser Consistency

Modern browsers implement offset dimensions consistently according to the CSSOM View Module specification. Historical inconsistencies in IE6-7 regarding border calculations no longer apply to supported browsers.

### Relationship to Offset Parent

`offsetWidth` and `offsetHeight` measure the element's own dimensions and are independent of the `offsetParent` property. However, they're commonly used together:

- `offsetParent`: The nearest positioned ancestor (position: relative/absolute/fixed/sticky) or table elements
- `offsetLeft`/`offsetTop`: Position relative to offsetParent
- `offsetWidth`/`offsetHeight`: Element's own dimensions

### ResizeObserver Alternative

For scenarios requiring notification when offset dimensions change, `ResizeObserver` provides a more efficient alternative than polling:

```javascript
const observer = new ResizeObserver(entries => {
  entries.forEach(entry => {
    // entry.borderBoxSize provides dimension info
    // More efficient than repeatedly checking offsetWidth/Height
  });
});

observer.observe(element);
```

This avoids forcing synchronous layouts and provides optimized change detection.

---

