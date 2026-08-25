## getComputedStyle


### Basic Syntax

```javascript
window.getComputedStyle(element, [pseudoElement])
```

**Parameters:**

- `element` (Element): The element to get computed styles for
- `pseudoElement` (string, optional): A pseudo-element selector (e.g., "::before", "::after", "::first-line")

**Returns:** A live `CSSStyleDeclaration` object containing all computed CSS property values for the element

### Basic Usage

```javascript
const element = document.querySelector('.box');
const styles = window.getComputedStyle(element);

console.log(styles.color); // "rgb(255, 0, 0)"
console.log(styles.fontSize); // "16px"
console.log(styles.display); // "block"
console.log(styles.width); // "200px"
```

### Computed vs Inline vs Stylesheet Styles

**Three Ways to Access Styles:**

```javascript
const div = document.createElement('div');
div.style.color = 'red'; // Inline style
div.style.width = '100px';
document.body.appendChild(div);

// CSS in stylesheet:
// .box { color: blue; padding: 20px; }
div.className = 'box';

// 1. Inline styles (element.style)
console.log(div.style.color); // "red" (only inline)
console.log(div.style.padding); // "" (not inline, so empty)
console.log(div.style.display); // "" (default, not set inline)

// 2. Computed styles (getComputedStyle)
const computed = getComputedStyle(div);
console.log(computed.color); // "rgb(255, 0, 0)" (inline wins)
console.log(computed.padding); // "20px" (from stylesheet)
console.log(computed.display); // "block" (browser default)
```

**Key Differences:**

|Feature|`element.style`|`getComputedStyle()`|
|---|---|---|
|Access|Read/Write|Read-only|
|Scope|Inline styles only|All applied styles|
|Values|As written|Computed/absolute|
|Shorthand|Preserves shorthand|Returns longhand|
|Defaults|Empty string|Browser defaults included|

### Return Value Details

**CSSStyleDeclaration Object:**

```javascript
const styles = getComputedStyle(element);

console.log(typeof styles); // "object"
console.log(styles instanceof CSSStyleDeclaration); // true
console.log(styles.length); // ~300+ (number of CSS properties)

// Access methods
styles.getPropertyValue('color'); // "rgb(255, 0, 0)"
styles.getPropertyPriority('color'); // "" (always empty for computed)
styles.item(0); // First property name
```

**Live Object:**

```javascript
const element = document.querySelector('div');
const styles = getComputedStyle(element);

console.log(styles.color); // "rgb(0, 0, 0)"

element.style.color = 'red';

console.log(styles.color); // "rgb(255, 0, 0)" (updates automatically)
```

The returned object is live and reflects the current computed styles. Changes to the element's styles are immediately reflected.

### Absolute and Computed Values

`getComputedStyle` returns resolved, absolute values:

```javascript
// CSS: font-size: 1.5em; (parent has 16px)
const styles = getComputedStyle(element);

console.log(styles.fontSize); // "24px" (computed: 16 * 1.5)
// Not "1.5em"

// CSS: width: 50%;
console.log(styles.width); // "400px" (if parent is 800px wide)
// Not "50%"

// CSS: color: currentColor;
console.log(styles.color); // "rgb(0, 0, 0)" (resolved value)
// Not "currentColor"

// CSS: margin: auto;
console.log(styles.marginLeft); // "0px" or computed pixel value
// Not "auto"
```

### Property Name Formats

**camelCase (JavaScript):**

```javascript
const styles = getComputedStyle(element);

styles.backgroundColor; // "rgb(255, 255, 255)"
styles.fontSize; // "16px"
styles.borderTopWidth; // "1px"
styles.zIndex; // "1"
```

**kebab-case (CSS):**

```javascript
styles.getPropertyValue('background-color'); // "rgb(255, 255, 255)"
styles.getPropertyValue('font-size'); // "16px"
styles.getPropertyValue('border-top-width'); // "1px"
styles.getPropertyValue('z-index'); // "1"
```

**Both work:**

```javascript
// These are equivalent
styles.backgroundColor;
styles['background-color'];
styles.getPropertyValue('background-color');
```

### Color Values

Colors are returned in `rgb()` or `rgba()` format:

```javascript
// CSS: color: red;
const styles = getComputedStyle(element);

console.log(styles.color); // "rgb(255, 0, 0)"
// Not "red"

// CSS: color: #ff0000;
console.log(styles.color); // "rgb(255, 0, 0)"
// Not "#ff0000"

// CSS: color: rgba(255, 0, 0, 0.5);
console.log(styles.color); // "rgba(255, 0, 0, 0.5)"

// CSS: background-color: transparent;
console.log(styles.backgroundColor); // "rgba(0, 0, 0, 0)"
```

### Shorthand vs Longhand Properties

Shorthand properties may return empty strings or unexpected values. Use longhand properties:

```javascript
// CSS: margin: 10px 20px;
const styles = getComputedStyle(element);

// Shorthand - unreliable
console.log(styles.margin); // "" or "10px 20px" (browser-dependent)

// Longhand - reliable
console.log(styles.marginTop); // "10px"
console.log(styles.marginRight); // "20px"
console.log(styles.marginBottom); // "10px"
console.log(styles.marginLeft); // "20px"

// CSS: border: 1px solid red;
console.log(styles.border); // "" (often empty)

// Use longhand instead
console.log(styles.borderTopWidth); // "1px"
console.log(styles.borderTopStyle); // "solid"
console.log(styles.borderTopColor); // "rgb(255, 0, 0)"
```

**Recommendation:** Always use longhand property names for reliable results.

### Pseudo-Elements

Access styles of pseudo-elements using the second parameter:

```javascript
// CSS:
// .box::before {
//   content: "›";
//   color: blue;
//   font-size: 20px;
// }

const element = document.querySelector('.box');

// Pseudo-element styles
const beforeStyles = getComputedStyle(element, '::before');
console.log(beforeStyles.content); // '"›"' (includes quotes)
console.log(beforeStyles.color); // "rgb(0, 0, 255)"
console.log(beforeStyles.fontSize); // "20px"

const afterStyles = getComputedStyle(element, '::after');
console.log(afterStyles.display); // "inline" or "none"

// Other pseudo-elements
getComputedStyle(element, '::first-line');
getComputedStyle(element, '::first-letter');
getComputedStyle(element, '::selection');
getComputedStyle(element, '::placeholder');
```

**Legacy Syntax:**

```javascript
// Single colon (legacy, still works)
getComputedStyle(element, ':before');
getComputedStyle(element, ':after');

// Double colon (modern, preferred)
getComputedStyle(element, '::before');
getComputedStyle(element, '::after');
```

### Display and Visibility

```javascript
const styles = getComputedStyle(element);

// Display
console.log(styles.display); // "block", "inline", "flex", "none", etc.

// Visibility
console.log(styles.visibility); // "visible", "hidden", "collapse"

// Opacity
console.log(styles.opacity); // "1", "0.5", etc.

// Checking if element is visible
function isVisible(element) {
  const styles = getComputedStyle(element);
  return styles.display !== 'none' 
    && styles.visibility !== 'hidden' 
    && styles.opacity !== '0';
}
```

### Dimensions and Position

```javascript
const styles = getComputedStyle(element);

// Dimensions
console.log(styles.width); // "200px"
console.log(styles.height); // "100px"
console.log(styles.minWidth); // "0px"
console.log(styles.maxWidth); // "none" or "500px"

// Box model
console.log(styles.paddingTop); // "10px"
console.log(styles.paddingRight); // "10px"
console.log(styles.borderTopWidth); // "1px"
console.log(styles.marginTop); // "20px"

// Position
console.log(styles.position); // "static", "relative", "absolute", "fixed"
console.log(styles.top); // "auto" or "10px"
console.log(styles.left); // "auto" or "20px"
console.log(styles.zIndex); // "auto" or "10"
```

### Box Sizing

```javascript
const styles = getComputedStyle(element);

console.log(styles.boxSizing); // "content-box" or "border-box"

// Calculate total width including padding and border
function getTotalWidth(element) {
  const styles = getComputedStyle(element);
  const width = parseFloat(styles.width);
  
  if (styles.boxSizing === 'border-box') {
    return width; // Already includes padding and border
  }
  
  // content-box: add padding and border
  const paddingLeft = parseFloat(styles.paddingLeft);
  const paddingRight = parseFloat(styles.paddingRight);
  const borderLeft = parseFloat(styles.borderLeftWidth);
  const borderRight = parseFloat(styles.borderRightWidth);
  
  return width + paddingLeft + paddingRight + borderLeft + borderRight;
}
```

### Font Properties

```javascript
const styles = getComputedStyle(element);

console.log(styles.fontFamily); // '"Arial", sans-serif'
console.log(styles.fontSize); // "16px"
console.log(styles.fontWeight); // "400" or "700" (numeric)
console.log(styles.fontStyle); // "normal" or "italic"
console.log(styles.lineHeight); // "24px" (computed to pixels)
console.log(styles.textAlign); // "left", "center", "right", "justify"
console.log(styles.textDecoration); // "none" or "underline solid rgb(0, 0, 0)"
console.log(styles.textTransform); // "none", "uppercase", "lowercase", "capitalize"
console.log(styles.letterSpacing); // "normal" or "2px"
console.log(styles.wordSpacing); // "normal" or "4px"
```

### Transform and Animation Properties

```javascript
const styles = getComputedStyle(element);

// Transform
console.log(styles.transform); 
// "matrix(1, 0, 0, 1, 10, 20)" or "none"

// Transition
console.log(styles.transitionProperty); // "all" or "opacity, transform"
console.log(styles.transitionDuration); // "0.3s"
console.log(styles.transitionTimingFunction); // "ease"
console.log(styles.transitionDelay); // "0s"

// Animation
console.log(styles.animationName); // "slidein" or "none"
console.log(styles.animationDuration); // "2s"
console.log(styles.animationIterationCount); // "infinite" or "3"
```

### Flexbox Properties

```javascript
const container = document.querySelector('.flex-container');
const styles = getComputedStyle(container);

// Container properties
console.log(styles.display); // "flex"
console.log(styles.flexDirection); // "row", "column", "row-reverse", etc.
console.log(styles.flexWrap); // "nowrap", "wrap", "wrap-reverse"
console.log(styles.justifyContent); // "flex-start", "center", "space-between", etc.
console.log(styles.alignItems); // "stretch", "center", "flex-start", etc.
console.log(styles.alignContent); // "stretch", "center", etc.
console.log(styles.gap); // "10px" or "10px 20px"

// Item properties
const item = container.firstElementChild;
const itemStyles = getComputedStyle(item);
console.log(itemStyles.flexGrow); // "0", "1", etc.
console.log(itemStyles.flexShrink); // "1", "0", etc.
console.log(itemStyles.flexBasis); // "auto" or "200px"
console.log(itemStyles.alignSelf); // "auto", "center", etc.
console.log(itemStyles.order); // "0", "1", "-1", etc.
```

### Grid Properties

```javascript
const grid = document.querySelector('.grid-container');
const styles = getComputedStyle(grid);

// Container properties
console.log(styles.display); // "grid"
console.log(styles.gridTemplateColumns); // "200px 1fr 1fr"
console.log(styles.gridTemplateRows); // "100px auto"
console.log(styles.gridAutoFlow); // "row", "column", "dense"
console.log(styles.gap); // "10px" or "10px 20px"
console.log(styles.justifyItems); // "stretch", "center", etc.
console.log(styles.alignItems); // "stretch", "center", etc.

// Item properties
const gridItem = grid.firstElementChild;
const itemStyles = getComputedStyle(gridItem);
console.log(itemStyles.gridColumnStart); // "1" or "auto"
console.log(itemStyles.gridColumnEnd); // "3" or "auto"
console.log(itemStyles.gridRowStart); // "1"
console.log(itemStyles.gridRowEnd); // "2"
```

### Custom Properties (CSS Variables)

```javascript
// CSS:
// :root {
//   --main-color: #ff0000;
//   --spacing: 20px;
// }

const styles = getComputedStyle(document.documentElement);

console.log(styles.getPropertyValue('--main-color')); // "#ff0000"
console.log(styles.getPropertyValue('--spacing')); // "20px"

// Element-specific variable
const element = document.querySelector('.box');
const elementStyles = getComputedStyle(element);
console.log(elementStyles.getPropertyValue('--local-var')); // Value or ""

// Using variable value
const color = styles.getPropertyValue('--main-color').trim();
element.style.backgroundColor = color;
```

**Note:** Custom properties are case-sensitive and must be accessed with `getPropertyValue()`.

### Parsing Numeric Values

```javascript
const styles = getComputedStyle(element);

// parseFloat for single values
const width = parseFloat(styles.width); // 200 (number)
const fontSize = parseFloat(styles.fontSize); // 16

// parseInt for integers
const zIndex = parseInt(styles.zIndex); // 10

// Handling "auto", "none", etc.
function getNumericValue(value, defaultValue = 0) {
  const parsed = parseFloat(value);
  return isNaN(parsed) ? defaultValue : parsed;
}

const top = getNumericValue(styles.top); // 0 if "auto"
```

### Multi-Value Properties

```javascript
const styles = getComputedStyle(element);

// Transform (matrix)
const transform = styles.transform;
// "matrix(1, 0, 0, 1, 10, 20)"

// Parse matrix values
function parseMatrix(matrixString) {
  const values = matrixString.match(/matrix.*\((.+)\)/);
  if (values) {
    return values[1].split(', ').map(parseFloat);
  }
  return null;
}

const matrix = parseMatrix(transform);
// [1, 0, 0, 1, 10, 20]
// translateX = matrix[4], translateY = matrix[5]

// Box shadow
console.log(styles.boxShadow);
// "rgb(0, 0, 0) 2px 2px 4px 0px"

// Text shadow
console.log(styles.textShadow);
// "rgb(0, 0, 0) 1px 1px 2px"
```

### Filter Property

```javascript
const styles = getComputedStyle(element);

console.log(styles.filter);
// "blur(5px) brightness(1.2)"
// or "none"

// Individual filter functions are not separately accessible
// Must parse the filter string if you need individual values
```

### Background Properties

```javascript
const styles = getComputedStyle(element);

// Background color
console.log(styles.backgroundColor); // "rgb(255, 255, 255)"

// Background image
console.log(styles.backgroundImage);
// 'url("image.jpg")' or "none"
// Multiple: 'url("img1.jpg"), url("img2.jpg")'

// Background position
console.log(styles.backgroundPosition); // "0% 0%"
console.log(styles.backgroundPositionX); // "0%"
console.log(styles.backgroundPositionY); // "0%"

// Background size
console.log(styles.backgroundSize); // "auto" or "cover" or "100px 200px"

// Background repeat
console.log(styles.backgroundRepeat); // "repeat", "no-repeat", etc.

// Background attachment
console.log(styles.backgroundAttachment); // "scroll" or "fixed"

// Background clip/origin
console.log(styles.backgroundClip); // "border-box", "padding-box", "content-box"
console.log(styles.backgroundOrigin); // "padding-box", etc.
```

### Border Radius

```javascript
const styles = getComputedStyle(element);

// Individual corners
console.log(styles.borderTopLeftRadius); // "10px"
console.log(styles.borderTopRightRadius); // "10px"
console.log(styles.borderBottomRightRadius); // "10px"
console.log(styles.borderBottomLeftRadius); // "10px"

// Shorthand (unreliable)
console.log(styles.borderRadius); // May be empty

// Elliptical radius (if specified)
// CSS: border-radius: 50px / 25px;
console.log(styles.borderTopLeftRadius); // "50px 25px"
```

### Overflow Properties

```javascript
const styles = getComputedStyle(element);

console.log(styles.overflow); // "visible", "hidden", "scroll", "auto"
console.log(styles.overflowX); // Individual axis
console.log(styles.overflowY); // Individual axis
console.log(styles.overflowWrap); // "normal" or "break-word"
console.log(styles.textOverflow); // "clip" or "ellipsis"
console.log(styles.whiteSpace); // "normal", "nowrap", "pre", etc.
```

### Cursor and Pointer Events

```javascript
const styles = getComputedStyle(element);

console.log(styles.cursor);
// "auto", "pointer", "move", "not-allowed", etc.
// or 'url("cursor.png"), pointer'

console.log(styles.pointerEvents); // "auto" or "none"
console.log(styles.userSelect); // "auto", "none", "text", "all"
```

### Performance Considerations

**Triggering Reflow:**

[Inference: Based on browser rendering behavior] Accessing `getComputedStyle` forces the browser to recalculate styles and potentially trigger layout reflow if styles have changed:

```javascript
// Inefficient - multiple reflows
for (let i = 0; i < elements.length; i++) {
  const styles = getComputedStyle(elements[i]);
  console.log(styles.width); // Potential reflow each iteration
  elements[i].style.height = styles.width; // Causes layout change
}

// Better - batch reads, then batch writes
const widths = [];
for (let i = 0; i < elements.length; i++) {
  const styles = getComputedStyle(elements[i]);
  widths.push(styles.width);
}

for (let i = 0; i < elements.length; i++) {
  elements[i].style.height = widths[i];
}
```

**Caching Results:**

```javascript
// If styles won't change, cache the result
const element = document.querySelector('.box');
const styles = getComputedStyle(element);

// Use the same styles object multiple times
const color = styles.color;
const fontSize = styles.fontSize;
const padding = styles.padding;

// Don't call getComputedStyle repeatedly for same element
```

**Note:** The `CSSStyleDeclaration` object is live, so caching only helps if you're accessing multiple properties in quick succession before any style changes.

### Hidden Elements

```javascript
// Element with display: none
const hidden = document.querySelector('.hidden');
const styles = getComputedStyle(hidden);

// Most properties still return computed values
console.log(styles.color); // "rgb(0, 0, 0)"
console.log(styles.fontSize); // "16px"

// But layout-related properties may be affected
console.log(styles.display); // "none"
console.log(styles.width); // "auto" or actual computed value
console.log(styles.height); // "auto" or actual computed value

// offsetWidth/offsetHeight are 0 for display:none
console.log(hidden.offsetWidth); // 0
console.log(hidden.offsetHeight); // 0
```

### Detached Elements

Elements not in the document still have computed styles:

```javascript
const div = document.createElement('div');
// Not appended to document

const styles = getComputedStyle(div);

console.log(styles.display); // "block" (default for div)
console.log(styles.color); // "rgb(0, 0, 0)" (browser default)
console.log(styles.fontSize); // "16px" (browser default)

// But dimensions may be 0 or auto
console.log(styles.width); // "auto"
console.log(styles.height); // "auto"
```

### Window Prefix

`getComputedStyle` is technically a method of the `window` object:

```javascript
// These are equivalent
window.getComputedStyle(element);
getComputedStyle(element); // window is implicit in global scope

// Can be useful in strict contexts
const computedStyles = window.getComputedStyle.bind(window);
const styles = computedStyles(element);
```

### Cross-Browser Considerations

**Legacy IE (IE8 and earlier):** Used `element.currentStyle` instead of `getComputedStyle`:

```javascript
// Modern browsers
const styles = getComputedStyle(element);

// Legacy IE polyfill pattern (no longer needed for modern development)
function getStyles(element) {
  return window.getComputedStyle 
    ? getComputedStyle(element) 
    : element.currentStyle;
}
```

**Modern browsers:** `getComputedStyle` has excellent support in all current browsers (Chrome, Firefox, Safari, Edge).

### Practical Use Cases

**Get Actual Dimensions:**

```javascript
function getActualDimensions(element) {
  const styles = getComputedStyle(element);
  return {
    width: parseFloat(styles.width),
    height: parseFloat(styles.height),
    paddingTop: parseFloat(styles.paddingTop),
    paddingRight: parseFloat(styles.paddingRight),
    paddingBottom: parseFloat(styles.paddingBottom),
    paddingLeft: parseFloat(styles.paddingLeft),
    borderWidth: {
      top: parseFloat(styles.borderTopWidth),
      right: parseFloat(styles.borderRightWidth),
      bottom: parseFloat(styles.borderBottomWidth),
      left: parseFloat(styles.borderLeftWidth)
    }
  };
}
```

**Check if Element is Fixed:**

```javascript
function isPositionFixed(element) {
  while (element && element !== document.body) {
    const styles = getComputedStyle(element);
    if (styles.position === 'fixed') {
      return true;
    }
    element = element.parentElement;
  }
  return false;
}
```

**Get Effective Z-Index:**

```javascript
function getEffectiveZIndex(element) {
  let current = element;
  let maxZIndex = -Infinity;
  
  while (current && current !== document.body) {
    const styles = getComputedStyle(current);
    const position = styles.position;
    
    if (position !== 'static') {
      const zIndex = parseInt(styles.zIndex);
      if (!isNaN(zIndex)) {
        maxZIndex = Math.max(maxZIndex, zIndex);
      }
    }
    
    current = current.parentElement;
  }
  
  return maxZIndex === -Infinity ? 'auto' : maxZIndex;
}
```

**Check Visibility:**

```javascript
function isElementVisible(element) {
  if (!element) return false;
  
  const styles = getComputedStyle(element);
  
  // Check display
  if (styles.display === 'none') return false;
  
  // Check visibility
  if (styles.visibility === 'hidden') return false;
  
  // Check opacity
  if (styles.opacity === '0') return false;
  
  // Check parent visibility recursively
  const parent = element.parentElement;
  if (parent && parent !== document.body) {
    return isElementVisible(parent);
  }
  
  return true;
}
```

**Copy All Styles:**

```javascript
function copyComputedStyles(source, target) {
  const styles = getComputedStyle(source);
  
  for (let i = 0; i < styles.length; i++) {
    const property = styles[i];
    const value = styles.getPropertyValue(property);
    target.style.setProperty(property, value);
  }
}
```

**Get Inherited Color:**

```javascript
function getInheritedColor(element) {
  let current = element;
  
  while (current) {
    const styles = getComputedStyle(current);
    const color = styles.color;
    
    // If color is explicitly set (not inherited default)
    if (color !== 'rgb(0, 0, 0)' || current === document.body) {
      return color;
    }
    
    current = current.parentElement;
  }
  
  return 'rgb(0, 0, 0)'; // Default
}
```

### Common Pitfalls

**Pitfall 1: Expecting Shorthand Properties**

```javascript
// Wrong - may return empty string
const styles = getComputedStyle(element);
console.log(styles.margin); // "" (unreliable)

// Correct - use longhand
console.log(styles.marginTop); // "10px"
console.log(styles.marginRight); // "10px"
```

**Pitfall 2: Forgetting to Parse Numbers**

```javascript
const styles = getComputedStyle(element);

// Wrong - string concatenation
const newWidth = styles.width + 10; // "200px10"

// Correct - parse first
const newWidth = parseFloat(styles.width) + 10 + 'px'; // "210px"
```

**Pitfall 3: Modifying Returned Object**

```javascript
const styles = getComputedStyle(element);

// Wrong - read-only
styles.color = 'red'; // No effect, silently fails

// Correct - modify element.style
element.style.color = 'red';
```

**Pitfall 4: Not Accounting for Element State**

```javascript
// Element must be in document for accurate dimensions
const div = document.createElement('div');
const styles = getComputedStyle(div);
console.log(styles.width); // "auto" (not useful)

// Append first, then get styles
document.body.appendChild(div);
const stylesAfter = getComputedStyle(div);
console.log(stylesAfter.width); // Actual computed width
```

---

