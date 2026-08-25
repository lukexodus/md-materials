## SVG Manipulation via DOM


SVG elements in the DOM are represented as specialized node types that inherit from both general DOM interfaces and SVG-specific interfaces. These elements can be manipulated through standard DOM methods while also exposing SVG-specific properties and methods that handle the unique requirements of vector graphics.

### SVG DOM Namespace

SVG elements exist in the SVG namespace (`http://www.w3.org/2000/svg`). Creating SVG elements requires namespace-aware methods:

```javascript
const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
```

Using `document.createElement('svg')` creates an `HTMLUnknownElement` rather than an `SVGSVGElement`, resulting in elements that don't render or behave correctly. This namespace requirement extends to all SVG elements—`rect`, `path`, `g`, etc.

The namespace constant is commonly stored: `const SVG_NS = 'http://www.w3.org/2000/svg'` to avoid repetition.

### Attribute vs. Property Access

SVG elements expose attributes through multiple access patterns, each with different behavior:

**`setAttribute`/`getAttribute`**: Standard DOM methods that work with string values. All attributes can be set this way:

```javascript
circle.setAttribute('cx', '50');
circle.setAttribute('r', '25');
```

**Direct property access**: Some SVG attributes map to properties, but behavior varies. Properties like `className` on SVG elements return `SVGAnimatedString` objects rather than strings:

```javascript
circle.className.baseVal = 'my-class'; // Not circle.className = 'my-class'
```

**Presentation attributes vs. CSS properties**: Many SVG visual properties (`fill`, `stroke`, `opacity`) can be set as attributes or via CSS. CSS rules take precedence over presentation attributes. Setting `element.style.fill` differs from `element.setAttribute('fill', ...)` in specificity and cascade behavior.

### SVG-Specific Interfaces

Elements implement interfaces that provide specialized properties and methods:

**`SVGGeometryElement`**: Base for shape elements (`circle`, `rect`, `ellipse`, `line`, `polyline`, `polygon`, `path`). Provides methods like `getTotalLength()` and `getPointAtLength(distance)`.

**`SVGGraphicsElement`**: Base for elements that render graphics. Provides `getBBox()`, `getCTM()`, `getScreenCTM()` for bounding box and transformation matrix access.

**`SVGSVGElement`**: The root `<svg>` element. Provides viewport methods like `createSVGPoint()`, `createSVGMatrix()`, and `createSVGTransform()`.

### Coordinate System Manipulation

SVG uses nested coordinate systems with transformations. The DOM provides interfaces to work with these:

**`SVGPoint`**: Represents a point in coordinate space. Created via `svg.createSVGPoint()`:

```javascript
const pt = svg.createSVGPoint();
pt.x = 100;
pt.y = 200;
```

**Coordinate transformation**: Converting between coordinate spaces requires transformation matrices. The `getScreenCTM()` method returns the transformation from element space to screen space:

```javascript
const screenPt = {x: event.clientX, y: event.clientY};
const svg = element.ownerSVGElement;
const pt = svg.createSVGPoint();
pt.x = screenPt.x;
pt.y = screenPt.y;
const transformed = pt.matrixTransform(svg.getScreenCTM().inverse());
// transformed now contains SVG coordinates
```

This pattern is essential for mapping mouse/touch events (in screen coordinates) to SVG element coordinates, especially when the SVG has transforms, viewBox, or is scaled.

**`getBBox()`**: Returns the bounding box in element's local coordinate system before any transforms are applied. Returns an `SVGRect` with `x`, `y`, `width`, `height` properties.

**`getBoundingClientRect()`**: Returns the bounding box in screen coordinates after all transforms. Same interface as for HTML elements.

### Transform Manipulation

The `transform` attribute contains a list of transformations. DOM access is through `SVGAnimatedTransformList`:

```javascript
const transformList = element.transform.baseVal;
```

**Creating transforms**: The root SVG element provides factory methods:

```javascript
const svg = element.ownerSVGElement;
const translate = svg.createSVGTransform();
translate.setTranslate(50, 100);
transformList.appendItem(translate);

const rotate = svg.createSVGTransform();
rotate.setRotate(45, 0, 0); // angle, centerX, centerY
transformList.appendItem(rotate);
```

**Transform consolidation**: Multiple transforms can be consolidated into a single matrix:

```javascript
const matrix = transformList.consolidate().matrix;
```

The resulting matrix can be decomposed or used for calculations. This is useful when you need to determine the cumulative effect of multiple transforms.

**Direct matrix manipulation**: For complex transformations, working directly with matrices may be clearer:

```javascript
const matrix = svg.createSVGMatrix();
matrix.a = 1; // scale X
matrix.b = 0; // skew Y
matrix.c = 0; // skew X
matrix.d = 1; // scale Y
matrix.e = 50; // translate X
matrix.f = 100; // translate Y

const transform = svg.createSVGTransform();
transform.setMatrix(matrix);
element.transform.baseVal.initialize(transform);
```

### Path Manipulation

Path elements use a specialized interface for their `d` attribute:

**`SVGPathElement.pathSegList`** (deprecated in SVG2, but still relevant in some contexts): Provided structured access to path segments. Modern approach uses `setAttribute` with path string manipulation or path construction libraries.

**Path data construction**: Building paths programmatically:

```javascript
const commands = [];
commands.push(`M ${x} ${y}`); // moveto
commands.push(`L ${x2} ${y2}`); // lineto
commands.push(`Q ${cx} ${cy} ${x3} ${y3}`); // quadratic curve
commands.push('Z'); // closepath
path.setAttribute('d', commands.join(' '));
```

**Path measurement**: `SVGGeometryElement` methods enable path analysis:

```javascript
const length = path.getTotalLength();
const midpoint = path.getPointAtLength(length / 2);
// midpoint is SVGPoint with x, y coordinates
```

This is particularly useful for animations along paths or for placing elements at specific path positions.

**Hit testing**: `isPointInFill()` and `isPointInStroke()` determine if a point is inside the element:

```javascript
const pt = svg.createSVGPoint();
pt.x = mouseX;
pt.y = mouseY;
const isInside = path.isPointInFroke(pt);
```

These methods respect the element's coordinate system and transformations.

### ViewBox and Viewport Manipulation

The `viewBox` attribute defines the SVG coordinate system. Manipulating it programmatically:

```javascript
const viewBox = svg.viewBox.baseVal;
viewBox.x = 0;
viewBox.y = 0;
viewBox.width = 500;
viewBox.height = 500;
```

Or as a string attribute:

```javascript
svg.setAttribute('viewBox', '0 0 500 500');
```

**Calculating viewBox from content**: To frame all content, calculate bounding box of all children:

```javascript
let minX = Infinity, minY = Infinity;
let maxX = -Infinity, maxY = -Infinity;

Array.from(svg.children).forEach(child => {
  const bbox = child.getBBox();
  minX = Math.min(minX, bbox.x);
  minY = Math.min(minY, bbox.y);
  maxX = Math.max(maxX, bbox.x + bbox.width);
  maxY = Math.max(maxY, bbox.y + bbox.height);
});

svg.setAttribute('viewBox', `${minX} ${minY} ${maxX - minX} ${maxY - minY}`);
```

**`preserveAspectRatio`**: Controls how the viewBox scales and aligns within the viewport. Values like `xMidYMid meet` (default) maintain aspect ratio and center the content. Accessible via:

```javascript
const par = svg.preserveAspectRatio.baseVal;
par.align = SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_XMIDYMID;
par.meetOrSlice = SVGPreserveAspectRatio.SVG_MEETORSLICE_MEET;
```

### Cloning and Templates

**Deep cloning**: `cloneNode(true)` creates a deep copy with all attributes and children. Cloned SVG elements maintain their structure and styling:

```javascript
const original = document.getElementById('template-shape');
const clone = original.cloneNode(true);
clone.setAttribute('id', 'new-shape');
svg.appendChild(clone);
```

**`<use>` element**: References other SVG elements by ID, creating instances without actual cloning in the DOM:

```javascript
const use = document.createElementNS(SVG_NS, 'use');
use.setAttributeNS('http://www.w3.org/1999/xlink', 'xlink:href', '#my-symbol');
use.setAttribute('x', '100');
use.setAttribute('y', '100');
```

The `xlink:href` attribute requires the XLink namespace. Modern SVG also supports just `href` without namespace.

**Shadow DOM of `<use>`**: The referenced content appears in a shadow tree. Direct manipulation of the instance requires accessing this shadow tree, which has limited DOM access. Instead, modify the original element or override via CSS.

### Dynamic Element Creation Patterns

**Fragment assembly**: For multiple elements, use DocumentFragment to minimize reflows:

```javascript
const fragment = document.createDocumentFragment();
data.forEach(item => {
  const circle = document.createElementNS(SVG_NS, 'circle');
  circle.setAttribute('cx', item.x);
  circle.setAttribute('cy', item.y);
  circle.setAttribute('r', item.r);
  fragment.appendChild(circle);
});
svg.appendChild(fragment);
```

**Template strings**: For complex structures, constructing HTML strings can be more readable:

```javascript
const svgString = `
  <g class="group">
    <rect x="0" y="0" width="100" height="100" fill="blue"/>
    <text x="50" y="50" text-anchor="middle">Label</text>
  </g>
`;
const temp = document.createElementNS(SVG_NS, 'g');
temp.innerHTML = svgString;
svg.appendChild(temp.firstElementChild);
```

Note that `innerHTML` on SVG elements correctly parses SVG markup (assuming the parent is already in SVG context).

### Text Element Manipulation

Text in SVG has unique positioning requirements:

**`<text>` element**: Basic text positioning:

```javascript
const text = document.createElementNS(SVG_NS, 'text');
text.setAttribute('x', '100');
text.setAttribute('y', '100');
text.textContent = 'Hello';
```

**`<tspan>` for spans**: Individual text spans within a text element:

```javascript
const tspan = document.createElementNS(SVG_NS, 'tspan');
tspan.setAttribute('x', '100');
tspan.setAttribute('dy', '20'); // relative vertical offset
tspan.textContent = 'Line 2';
text.appendChild(tspan);
```

**Text measurement**: Get rendered text dimensions:

```javascript
const bbox = text.getBBox();
const width = bbox.width;
const height = bbox.height;
```

This requires the element to be in the document and rendered. Measuring detached elements returns zero dimensions.

**`textLength` and `lengthAdjust`**: Control text fitting:

```javascript
text.setAttribute('textLength', '200');
text.setAttribute('lengthAdjust', 'spacingAndGlyphs');
```

This scales or spaces the text to fit the specified length.

**`getComputedTextLength()`**: Returns the actual rendered length:

```javascript
const length = text.getComputedTextLength();
```

**Text on path**: Text can follow a path using `<textPath>`:

```javascript
const textPath = document.createElementNS(SVG_NS, 'textPath');
textPath.setAttributeNS('http://www.w3.org/1999/xlink', 'xlink:href', '#myPath');
textPath.textContent = 'Text along curve';
text.appendChild(textPath);
```

### Event Handling Specifics

SVG elements support standard DOM events with some considerations:

**Mouse coordinate mapping**: Event coordinates are in screen space. Converting to SVG space requires transformation (as shown in coordinate system section).

**Pointer events**: The `pointer-events` attribute controls hit testing. Values like `none`, `fill`, `stroke`, `all` determine what parts of an element respond to pointer events:

```javascript
element.setAttribute('pointer-events', 'none'); // makes element non-interactive
```

**Event delegation**: Like HTML, events bubble up the SVG tree. Attaching listeners to the root SVG or group elements can handle events from many children:

```javascript
svg.addEventListener('click', (event) => {
  if (event.target.tagName === 'circle') {
    // handle circle click
  }
});
```

**Preventing default**: Some SVG interactions (like dragging) may trigger unwanted browser behaviors. Prevent with `event.preventDefault()` as with HTML.

### CSS and Styling

SVG elements can be styled via CSS with caveats:

**Presentation attributes vs. CSS properties**: Attributes like `fill` and `stroke` are also CSS properties. CSS declarations override attribute values:

```javascript
circle.setAttribute('fill', 'red');
circle.style.fill = 'blue'; // blue wins
```

**Classes and ID selection**: Standard class and ID manipulation:

```javascript
element.classList.add('highlighted');
element.classList.toggle('active');
```

**Computed styles**: `getComputedStyle()` works on SVG elements:

```javascript
const style = getComputedStyle(element);
const fill = style.fill; // returns computed color value
```

**Custom properties**: CSS variables work in SVG:

```javascript
svg.style.setProperty('--primary-color', '#ff0000');
// then use in attributes or CSS: fill="var(--primary-color)"
```

### Marker Manipulation

Markers (arrowheads, endpoints) are defined once and referenced:

**Defining markers**:

```javascript
const marker = document.createElementNS(SVG_NS, 'marker');
marker.setAttribute('id', 'arrow');
marker.setAttribute('markerWidth', '10');
marker.setAttribute('markerHeight', '10');
marker.setAttribute('refX', '5');
marker.setAttribute('refY', '5');
marker.setAttribute('orient', 'auto');

const path = document.createElementNS(SVG_NS, 'path');
path.setAttribute('d', 'M 0 0 L 10 5 L 0 10 Z');
marker.appendChild(path);

defs.appendChild(marker);
```

**Applying markers**:

```javascript
line.setAttribute('marker-end', 'url(#arrow)');
```

Markers automatically orient themselves along the path direction when `orient="auto"`.

### Filter Manipulation

SVG filters enable complex visual effects. Building filters programmatically:

```javascript
const filter = document.createElementNS(SVG_NS, 'filter');
filter.setAttribute('id', 'blur');

const feGaussianBlur = document.createElementNS(SVG_NS, 'feGaussianBlur');
feGaussianBlur.setAttribute('in', 'SourceGraphic');
feGaussianBlur.setAttribute('stdDeviation', '5');
filter.appendChild(feGaussianBlur);

defs.appendChild(filter);

element.setAttribute('filter', 'url(#blur)');
```

**Filter chaining**: Multiple filter primitives process sequentially:

```javascript
const feOffset = document.createElementNS(SVG_NS, 'feOffset');
feOffset.setAttribute('in', 'SourceAlpha');
feOffset.setAttribute('dx', '3');
feOffset.setAttribute('dy', '3');
feOffset.setAttribute('result', 'offsetBlur');

const feBlur = document.createElementNS(SVG_NS, 'feGaussianBlur');
feBlur.setAttribute('in', 'offsetBlur');
feBlur.setAttribute('stdDeviation', '2');
feBlur.setAttribute('result', 'blurredOffset');

// combine with original using feMerge...
```

The `in` and `result` attributes connect filter stages, creating a processing pipeline.

### Gradient Manipulation

Linear and radial gradients require structured element trees:

**Linear gradient**:

```javascript
const gradient = document.createElementNS(SVG_NS, 'linearGradient');
gradient.setAttribute('id', 'grad1');
gradient.setAttribute('x1', '0%');
gradient.setAttribute('y1', '0%');
gradient.setAttribute('x2', '100%');
gradient.setAttribute('y2', '0%');

const stop1 = document.createElementNS(SVG_NS, 'stop');
stop1.setAttribute('offset', '0%');
stop1.setAttribute('stop-color', 'red');

const stop2 = document.createElementNS(SVG_NS, 'stop');
stop2.setAttribute('offset', '100%');
stop2.setAttribute('stop-color', 'blue');

gradient.appendChild(stop1);
gradient.appendChild(stop2);
defs.appendChild(gradient);

rect.setAttribute('fill', 'url(#grad1)');
```

**Dynamic gradient updates**: Changing stop positions or colors:

```javascript
const stops = gradient.querySelectorAll('stop');
stops[0].setAttribute('stop-color', 'green');
stops[1].setAttribute('offset', '80%');
```

Changes take effect immediately as the gradient is referenced, not copied.

### Symbol and Defs Management

The `<defs>` element contains reusable definitions:

```javascript
const defs = document.createElementNS(SVG_NS, 'defs');
svg.appendChild(defs);
```

**Symbols**: Define reusable graphics with their own viewBox:

```javascript
const symbol = document.createElementNS(SVG_NS, 'symbol');
symbol.setAttribute('id', 'icon');
symbol.setAttribute('viewBox', '0 0 20 20');
// add shapes to symbol
defs.appendChild(symbol);
```

Symbols don't render directly—they're instantiated via `<use>` elements.

### Animation via DOM

While CSS animations and SMIL are options, animating via DOM manipulation provides maximum control:

**RequestAnimationFrame pattern**:

```javascript
let angle = 0;
function animate() {
  angle += 1;
  element.setAttribute('transform', `rotate(${angle} 50 50)`);
  requestAnimationFrame(animate);
}
animate();
```

**Performance considerations**: Modifying attributes triggers recalculation and repaint. Transform changes are generally more performant than position changes:

```javascript
// Better: transform-based animation
element.style.transform = `translate(${x}px, ${y}px)`;

// Less performant: attribute-based positioning
element.setAttribute('x', x);
element.setAttribute('y', y);
```

**Interpolation**: For smooth animations, interpolate between states:

```javascript
function interpolatePoints(start, end, progress) {
  return {
    x: start.x + (end.x - start.x) * progress,
    y: start.y + (end.y - start.y) * progress
  };
}
```

### Memory and Performance Considerations

**Detached element manipulation**: Building complex SVG structures detached from the DOM (in memory) is faster than incremental DOM updates:

```javascript
const svg = document.createElementNS(SVG_NS, 'svg');
// build entire structure
// ...
document.body.appendChild(svg); // single insertion
```

**Query performance**: `querySelectorAll` on large SVGs can be slow. Cache frequently accessed elements:

```javascript
const circles = Array.from(svg.querySelectorAll('circle'));
// reuse circles array rather than querying repeatedly
```

**Avoid layout thrashing**: Batch attribute reads and writes. Reading layout properties like `getBBox()` forces synchronous layout calculation. Batch all reads, then all writes:

```javascript
// Bad: interleaved reads and writes
elements.forEach(el => {
  const bbox = el.getBBox(); // read (forces layout)
  el.setAttribute('x', bbox.width); // write
});

// Better: batch reads, then writes
const bboxes = elements.map(el => el.getBBox());
elements.forEach((el, i) => {
  el.setAttribute('x', bboxes[i].width);
});
```

### Cross-Browser Compatibility Considerations

**Namespace handling**: All SVG-supporting browsers require proper namespace for element creation. No fallback to non-namespaced methods exists.

**Attribute name differences**: Some attributes have different JavaScript property names. For instance, `class` attribute is accessed via `className`, but on SVG elements, `className` returns `SVGAnimatedString`, requiring `className.baseVal`.

**Matrix operations**: Not all browsers implement the full matrix manipulation interface identically. Direct matrix property manipulation is most reliable.

**Measurement timing**: `getBBox()` and similar methods require elements to be rendered. Measurements on elements not yet in the document or with `display: none` may return zeros or throw errors. Ensure elements are attached and visible before measuring.

---

