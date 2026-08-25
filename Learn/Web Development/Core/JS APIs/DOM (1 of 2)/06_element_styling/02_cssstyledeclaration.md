## CSSStyleDeclaration


### Interface Overview

`CSSStyleDeclaration` is a live interface representing a collection of CSS property-value pairs. It provides programmatic access to an element's inline styles, computed styles, and stylesheet rule declarations. The interface updates automatically when underlying styles change and reflects modifications immediately.

Three primary sources return `CSSStyleDeclaration` objects:

- `element.style`: Inline styles set via the `style` attribute
- `window.getComputedStyle(element)`: Final computed styles after cascade resolution
- `CSSStyleRule.style`: Styles within stylesheet rules

### Element Inline Styles

The `element.style` property returns a `CSSStyleDeclaration` representing only inline styles:

```javascript
const div = document.querySelector('div');

// Reading inline styles
div.style.color; // "" if not set inline
div.style.backgroundColor; // ""
div.style.fontSize; // ""

// Writing inline styles
div.style.color = 'red';
div.style.backgroundColor = 'blue';
div.style.fontSize = '16px';

// Results in: <div style="color: red; background-color: blue; font-size: 16px;"></div>
```

Key characteristics:

- Only reflects inline `style` attribute values
- Ignores stylesheet rules, `<style>` blocks, and external CSS
- Returns empty string for unset properties
- Modifications directly update the `style` attribute
- Changes trigger immediate reflow/repaint

### Property Access Patterns

`CSSStyleDeclaration` supports multiple access methods:

**CamelCase property syntax:**

```javascript
element.style.backgroundColor = 'blue';
element.style.borderTopWidth = '2px';
element.style.marginLeft = '10px';
```

**Bracket notation with kebab-case:**

```javascript
element.style['background-color'] = 'blue';
element.style['border-top-width'] = '2px';
element.style['margin-left'] = '10px';
```

**setProperty/getProperty methods:**

```javascript
element.style.setProperty('background-color', 'blue');
element.style.setProperty('border-top-width', '2px', 'important');
element.style.getPropertyValue('background-color'); // "blue"
element.style.getPropertyPriority('border-top-width'); // "important"
```

**removeProperty method:**

```javascript
element.style.removeProperty('background-color');
// Returns the old value and removes the property
```

CamelCase conversion rules:

- Hyphens are removed
- Character after each hyphen becomes uppercase
- Vendor prefixes: `-webkit-transform` → `webkitTransform`, `-moz-appearance` → `MozAppearance`

### cssText Property

The `cssText` property provides access to the entire style declaration as a string:

```javascript
element.style.cssText = 'color: red; font-size: 16px; margin: 10px;';

console.log(element.style.cssText);
// "color: red; font-size: 16px; margin: 10px;"

// Reading individual properties after setting cssText
element.style.color; // "red"
element.style.fontSize; // "16px"

// Appending to cssText
element.style.cssText += '; background-color: blue;';

// Clearing all inline styles
element.style.cssText = '';
```

Setting `cssText` replaces all existing inline styles. The property value may be normalized and reordered by the browser.

### Computed Styles

`window.getComputedStyle()` returns a read-only `CSSStyleDeclaration` with fully resolved computed values:

```javascript
const div = document.querySelector('div');
const computed = window.getComputedStyle(div);

// Returns actual computed values
computed.color; // "rgb(255, 0, 0)" not "red"
computed.fontSize; // "16px" not "1em"
computed.width; // "300px" computed from layout
computed.display; // "block"

// Includes all properties with computed values
computed.margin; // "10px" (shorthand)
computed.marginTop; // "10px" (longhand)
computed.marginRight; // "10px"
computed.marginBottom; // "10px"
computed.marginLeft; // "10px"

// Pseudo-element styles (second parameter)
const before = window.getComputedStyle(div, '::before');
before.content; // '"Generated content"'
before.display; // Pseudo-element display value
```

Critical differences from inline styles:

- **Read-only**: Assignments have no effect, no errors thrown
- **Complete**: Returns values for all CSS properties
- **Resolved**: Converts relative units to absolute values
- **Live**: Updates when styles change via stylesheet modifications
- **Computed values**: May differ from specified values (colors as `rgb()`, lengths in pixels)

### Property Value Types

CSS properties accept various value types that require specific string formats:

**Length values:**

```javascript
element.style.width = '100px';
element.style.height = '50%';
element.style.margin = '1em';
element.style.padding = '2rem';

// Numbers without units (invalid for most properties)
element.style.width = 100; // Invalid, ignored
element.style.width = '100'; // Invalid, ignored
element.style.lineHeight = 1.5; // Valid (unitless)
element.style.zIndex = 10; // Valid (integer)
```

**Color values:**

```javascript
element.style.color = 'red'; // Named
element.style.color = '#ff0000'; // Hex
element.style.color = 'rgb(255, 0, 0)'; // RGB
element.style.color = 'rgba(255, 0, 0, 0.5)'; // RGBA
element.style.color = 'hsl(0, 100%, 50%)'; // HSL
element.style.color = 'hsla(0, 100%, 50%, 0.5)'; // HSLA
```

**Multiple values:**

```javascript
element.style.margin = '10px 20px'; // Vertical horizontal
element.style.margin = '10px 20px 15px'; // Top horizontal bottom
element.style.margin = '10px 20px 15px 5px'; // Top right bottom left
element.style.boxShadow = '2px 2px 5px rgba(0,0,0,0.3)';
element.style.transform = 'rotate(45deg) scale(1.5)';
```

**Keywords:**

```javascript
element.style.display = 'none';
element.style.position = 'absolute';
element.style.float = 'left';
element.style.clear = 'both';
```

Invalid values are silently ignored:

```javascript
element.style.color = 'not-a-color'; // Ignored, no error
console.log(element.style.color); // Previous value or empty string
```

### Priority and !important

The `setProperty()` method accepts an optional priority parameter:

```javascript
// Set with !important
element.style.setProperty('color', 'red', 'important');

// Check priority
element.style.getPropertyPriority('color'); // "important"

// Remove !important by resetting
element.style.setProperty('color', 'red'); // No priority
element.style.getPropertyPriority('color'); // ""

// Direct property syntax cannot set !important
element.style.color = 'blue !important'; // Ignored, invalid syntax
```

The `cssText` property preserves `!important`:

```javascript
element.style.cssText = 'color: red !important; font-size: 16px;';
element.style.getPropertyPriority('color'); // "important"
element.style.getPropertyPriority('fontSize'); // ""
```

### Shorthand vs Longhand Properties

CSS properties exist in shorthand and longhand forms:

```javascript
// Shorthand sets multiple longhands
element.style.margin = '10px';
console.log(element.style.marginTop); // "10px"
console.log(element.style.marginRight); // "10px"
console.log(element.style.marginBottom); // "10px"
console.log(element.style.marginLeft); // "10px"

// Longhand sets individual values
element.style.marginTop = '20px';
console.log(element.style.margin); // "" (shorthand becomes empty)
console.log(element.style.marginTop); // "20px"

// Setting longhands individually
element.style.marginTop = '10px';
element.style.marginRight = '10px';
element.style.marginBottom = '10px';
element.style.marginLeft = '10px';
console.log(element.style.margin); // "10px" (shorthand reconstructed)
```

Common shorthand/longhand relationships:

- `margin` → `marginTop`, `marginRight`, `marginBottom`, `marginLeft`
- `padding` → `paddingTop`, `paddingRight`, `paddingBottom`, `paddingLeft`
- `border` → `borderWidth`, `borderStyle`, `borderColor` → individual sides
- `background` → `backgroundColor`, `backgroundImage`, `backgroundPosition`, etc.
- `font` → `fontFamily`, `fontSize`, `fontWeight`, `fontStyle`, `lineHeight`

[Inference: Browsers may not always reconstruct shorthand values even when all longhands are set identically, depending on implementation].

### Length Property and Iteration

`CSSStyleDeclaration` has a `length` property indicating the number of explicitly set properties:

```javascript
element.style.cssText = 'color: red; font-size: 16px; margin: 10px;';
console.log(element.style.length); // 3

// Iterate over property names
for (let i = 0; i < element.style.length; i++) {
  const propName = element.style[i];
  const propValue = element.style.getPropertyValue(propName);
  console.log(`${propName}: ${propValue}`);
}

// Alternative iteration
for (const prop of element.style) {
  console.log(`${prop}: ${element.style.getPropertyValue(prop)}`);
}
```

The iteration returns property names in kebab-case format. The order may not match the order specified in `cssText` [Inference: as browsers may normalize and reorder properties].

### Custom Properties (CSS Variables)

CSS custom properties use `--` prefix and require special handling:

```javascript
// Setting custom properties
element.style.setProperty('--main-color', 'blue');
element.style.setProperty('--spacing', '10px');

// Reading custom properties
element.style.getPropertyValue('--main-color'); // "blue"

// Using custom properties
element.style.color = 'var(--main-color)';
element.style.margin = 'var(--spacing)';

// Cannot use camelCase syntax for custom properties
element.style['--main-color'] = 'blue'; // Works with bracket notation
element.style.mainColor; // undefined, not a valid property name
```

Computed styles resolve custom property values:

```javascript
element.style.setProperty('--size', '20px');
element.style.width = 'var(--size)';

const computed = window.getComputedStyle(element);
computed.getPropertyValue('--size'); // "20px"
computed.width; // "20px" (resolved)
```

### Vendor Prefixes

Vendor-prefixed properties require specific naming in JavaScript:

```javascript
// Webkit prefixes (Chrome, Safari, newer Edge)
element.style.webkitTransform = 'rotate(45deg)';
element.style.webkitBorderRadius = '5px';
element.style.webkitBoxShadow = '2px 2px 5px black';

// Mozilla prefixes (Firefox)
element.style.MozAppearance = 'none';
element.style.MozUserSelect = 'none';

// Microsoft prefixes (older Edge, IE)
element.style.msTransform = 'rotate(45deg)';
element.style.msFlexbox = '1';

// Opera prefixes (legacy Opera)
element.style.OTransform = 'rotate(45deg)';
```

Note the capitalization:

- `-webkit-` → `webkit` (lowercase 'w')
- `-moz-` → `Moz` (uppercase 'M')
- `-ms-` → `ms` (lowercase)
- `-o-` → `O` (uppercase 'O')

Modern CSS feature detection:

```javascript
// Check if property is supported
if ('transform' in element.style) {
  element.style.transform = 'rotate(45deg)';
} else if ('webkitTransform' in element.style) {
  element.style.webkitTransform = 'rotate(45deg)';
}
```

### Performance Implications

Modifying `style` properties triggers reflows and repaints:

```javascript
// Multiple reflows (inefficient)
element.style.width = '100px'; // Reflow
element.style.height = '100px'; // Reflow
element.style.margin = '10px'; // Reflow

// Single reflow using cssText
element.style.cssText = 'width: 100px; height: 100px; margin: 10px;';

// Single reflow using class
element.className = 'sized-element'; // CSS rule handles all properties
```

Reading computed styles forces synchronous layout:

```javascript
element.style.width = '100px';
const width = window.getComputedStyle(element).width; // Forces layout
element.style.height = width; // Another layout
// Two synchronous layouts (layout thrashing)

// Batch reads and writes
const width1 = window.getComputedStyle(element1).width;
const width2 = window.getComputedStyle(element2).width; // Reads together
element1.style.height = width1; // Then writes
element2.style.height = width2;
```

[Inference: Modern browsers batch DOM writes within the same execution frame when possible, but explicit read-write-read-write patterns force synchronous layouts].

### Specificity and Cascade Behavior

Inline styles set via `element.style` have high specificity (1,0,0,0):

```css
/* External stylesheet */
div { color: blue !important; }
#myDiv { color: green; }
.myClass { color: yellow; }
```

```javascript
const div = document.querySelector('div#myDiv.myClass');

div.style.color = 'red';
// Color is red (inline style wins over ID/class selectors)

// But !important in stylesheet wins
div.style.color = 'red'; // Blue displays (!important overrides inline)

// Set inline !important to override
div.style.setProperty('color', 'red', 'important'); // Red displays
```

Removing inline styles allows cascade to apply:

```javascript
div.style.color = 'red'; // Red displays
div.style.color = ''; // Cascade applies, color from stylesheet
div.style.removeProperty('color'); // Same effect
```

### Stylesheet Rule Styles

`CSSStyleRule` objects in stylesheets have `style` properties:

```javascript
const sheet = document.styleSheets[0];
const rules = sheet.cssRules || sheet.rules;

for (const rule of rules) {
  if (rule.type === CSSRule.STYLE_RULE) {
    console.log(rule.selectorText); // ".my-class"
    console.log(rule.style.color); // "red"
    
    // Modify stylesheet rule
    rule.style.color = 'blue'; // Affects all matching elements
    rule.style.setProperty('font-size', '18px');
  }
}
```

Modifying stylesheet rules affects all elements matching the selector simultaneously.

### AttributeStyleMap API (Modern Alternative)

The CSS Typed OM introduces `attributeStyleMap` as a typed alternative:

```javascript
// Traditional CSSStyleDeclaration
element.style.opacity = '0.5';
element.style.opacity; // "0.5" (string)

// CSS Typed OM (if supported)
if (element.attributeStyleMap) {
  element.attributeStyleMap.set('opacity', 0.5);
  element.attributeStyleMap.get('opacity').value; // 0.5 (number)
  
  element.attributeStyleMap.set('width', CSS.px(100));
  element.attributeStyleMap.get('width').value; // 100
  element.attributeStyleMap.get('width').unit; // "px"
}
```

[Unverified: Browser support for `attributeStyleMap` varies; `CSSStyleDeclaration` remains the universally supported interface].

### Null and Empty String Behavior

Different assignment values produce specific behaviors:

```javascript
element.style.color = 'red';

// Empty string removes the property
element.style.color = '';
console.log(element.style.color); // ""
element.getAttribute('style'); // No color property

// Null converts to "null" (invalid value, ignored)
element.style.color = null;
console.log(element.style.color); // Previous value or ""

// Undefined converts to "undefined" (invalid value, ignored)
element.style.color = undefined;
console.log(element.style.color); // Previous value or ""
```

To remove properties:

```javascript
element.style.color = ''; // Recommended
element.style.removeProperty('color'); // Explicit removal
delete element.style.color; // Does nothing, not recommended
```

### Browser Normalization

Browsers normalize and serialize style values:

```javascript
element.style.margin = '10px 10px 10px 10px';
console.log(element.style.margin); // "10px" (normalized)

element.style.color = 'red';
console.log(element.style.color); // May be "red" or "rgb(255, 0, 0)"

element.style.border = '1px solid black';
console.log(element.style.border); 
// May be shorthand or expanded to longhands
```

[Inference: Exact serialization behavior varies by browser and property type, though standard properties generally normalize predictably].

---

