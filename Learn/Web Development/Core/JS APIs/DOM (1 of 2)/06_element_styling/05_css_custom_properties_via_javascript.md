## CSS Custom Properties via JavaScript


### Reading Custom Properties

Custom properties (CSS variables) are accessed through the `getComputedStyle()` API and the `getPropertyValue()` method:

```javascript
const element = document.querySelector('.target');
const styles = getComputedStyle(element);
const value = styles.getPropertyValue('--my-color');
```

`getComputedStyle()` returns a `CSSStyleDeclaration` object containing all computed styles for the element, including inherited custom properties. The `getPropertyValue()` method retrieves the value of a specific property.

Custom property names must include the `--` prefix when accessed via JavaScript. The property name is case-sensitive.

**Return value characteristics:**

The returned value is a string containing exactly what's in the CSS, including leading/trailing whitespace:

```css
.element {
  --spacing: 20px;
  --color:   #ff0000  ;
}
```

```javascript
getComputedStyle(element).getPropertyValue('--spacing'); // "20px"
getComputedStyle(element).getPropertyValue('--color');   // "   #ff0000  "
```

Whitespace is preserved. Use `trim()` to remove it:

```javascript
const color = styles.getPropertyValue('--color').trim();
```

### Setting Custom Properties via Inline Styles

Custom properties are set through the `style` property using `setProperty()`:

```javascript
element.style.setProperty('--my-color', '#ff0000');
```

This creates an inline style declaration on the element, equivalent to:

```html
<div style="--my-color: #ff0000;"></div>
```

The `setProperty()` method accepts three parameters:

- `propertyName` - the custom property name with `--` prefix
- `value` - the property value as a string
- `priority` (optional) - empty string or `"important"`

**Setting with priority:**

```javascript
element.style.setProperty('--my-color', '#ff0000', 'important');
// Results in: --my-color: #ff0000 !important;
```

### Alternative Syntax for Setting Properties

Custom properties can be set directly via bracket notation or `cssText`:

```javascript
// Bracket notation
element.style['--my-color'] = '#ff0000';

// cssText (replaces all inline styles)
element.style.cssText = '--my-color: #ff0000; --spacing: 20px;';
```

The bracket notation is less common and may be less clear than `setProperty()`. The `cssText` approach replaces all existing inline styles, not just custom properties.

### Removing Custom Properties

Remove custom properties using `removeProperty()`:

```javascript
element.style.removeProperty('--my-color');
```

This removes the property from the element's inline styles. If the property is defined in a stylesheet, the cascaded value from the stylesheet becomes active again.

Setting a custom property to an empty string also removes it:

```javascript
element.style.setProperty('--my-color', '');
```

Both approaches achieve the same result for inline styles.

### Checking if Custom Property Exists

Check if an element has a specific custom property value:

```javascript
const value = getComputedStyle(element).getPropertyValue('--my-color');
const exists = value !== '';
```

An empty string indicates the property isn't defined anywhere in the cascade for that element.

For inline styles specifically:

```javascript
const hasInline = element.style.getPropertyValue('--my-color') !== '';
```

The `element.style` property only reflects inline styles, while `getComputedStyle()` reflects the final computed value after the cascade.

### Scope and Inheritance

Custom properties follow CSS cascade and inheritance rules. Properties defined on ancestors are inherited by descendants unless overridden:

```css
:root {
  --primary: #0066cc;
}

.child {
  --primary: #ff0000;
}
```

```javascript
const root = document.documentElement;
const child = document.querySelector('.child');

getComputedStyle(root).getPropertyValue('--primary');  // "#0066cc"
getComputedStyle(child).getPropertyValue('--primary'); // "#ff0000"
```

Setting a custom property on an element affects that element and its descendants:

```javascript
document.documentElement.style.setProperty('--theme-color', '#0066cc');
// Now available to all descendants
```

### Setting Properties on :root

The `:root` pseudo-class (equivalent to `<html>`) is the common location for global custom properties:

```javascript
document.documentElement.style.setProperty('--global-spacing', '16px');
```

`document.documentElement` references the root `<html>` element. Properties set here inherit throughout the document unless overridden.

Alternatively, access via `document.querySelector(':root')`:

```javascript
const root = document.querySelector(':root');
root.style.setProperty('--primary', '#0066cc');
```

Both approaches reference the same element.

### Dynamic Theme Switching

Custom properties enable runtime theme changes:

```javascript
function setTheme(theme) {
  const root = document.documentElement;
  
  if (theme === 'dark') {
    root.style.setProperty('--bg-color', '#1a1a1a');
    root.style.setProperty('--text-color', '#ffffff');
    root.style.setProperty('--accent', '#6699ff');
  } else {
    root.style.setProperty('--bg-color', '#ffffff');
    root.style.setProperty('--text-color', '#000000');
    root.style.setProperty('--accent', '#0066cc');
  }
}
```

All elements using these custom properties update immediately when values change.

### Computed vs Declared Values

`getComputedStyle()` returns the computed value, not the declared value. For custom properties, the computed value is the declared value with whitespace preserved:

```css
.element {
  --size: calc(10px + 5px);
}
```

```javascript
getComputedStyle(element).getPropertyValue('--size'); // "calc(10px + 5px)"
```

Custom properties store their values verbatim. The `calc()` isn't evaluated until the property is used in a regular CSS property.

When a custom property is used:

```css
.element {
  --size: calc(10px + 5px);
  width: var(--size);
}
```

```javascript
getComputedStyle(element).getPropertyValue('width'); // "15px"
getComputedStyle(element).getPropertyValue('--size'); // "calc(10px + 5px)"
```

The `width` property shows the evaluated result, while `--size` retains the original expression.

### Invalid Values and Fallbacks

[Inference] When a custom property contains an invalid value for the property using it, the property becomes invalid at computed-value time and uses the inherited value or initial value:

```css
.element {
  --color: not-a-color;
  color: var(--color);
  /* color becomes 'inherit' or 'initial', not 'not-a-color' */
}
```

JavaScript cannot detect this invalidity when reading the custom property:

```javascript
getComputedStyle(element).getPropertyValue('--color'); // "not-a-color"
```

The invalid value is stored and returned. Validation occurs when the property is applied.

### Reading Properties Before Insertion

Custom properties can be read from detached elements:

```javascript
const div = document.createElement('div');
div.style.setProperty('--custom', 'value');

div.style.getPropertyValue('--custom'); // "value"
getComputedStyle(div).getPropertyValue('--custom'); // ""
```

Inline styles (via `element.style`) are readable immediately. Computed styles from detached elements generally return empty values or initial values since they aren't in the cascade.

### Animating Custom Properties

Custom properties can be animated via JavaScript:

```javascript
let value = 0;
const element = document.querySelector('.box');

function animate() {
  value += 1;
  element.style.setProperty('--rotation', `${value}deg`);
  
  if (value < 360) {
    requestAnimationFrame(animate);
  }
}

animate();
```

CSS can then use the custom property:

```css
.box {
  transform: rotate(var(--rotation, 0deg));
}
```

This approach enables JavaScript-driven animations that leverage CSS custom properties for separation of concerns.

### Performance Considerations

[Inference] Setting custom properties triggers style recalculation for the element and its descendants using those properties. Frequent updates can impact performance:

**Optimization strategies:**

- Minimize cascade depth where custom properties are used
- Update properties on the most specific element possible rather than root
- Batch multiple property updates when feasible
- Use `requestAnimationFrame()` for animation-related updates
- Consider CSS transitions/animations for smoother visual changes

[Inference] Modern browsers optimize custom property updates efficiently, but excessive updates (hundreds per second across many properties) may cause performance degradation.

### CSSStyleSheet API Integration

The CSS Object Model (CSSOM) provides programmatic stylesheet access:

```javascript
const sheet = document.styleSheets[0];
const rules = sheet.cssRules;

for (let rule of rules) {
  if (rule.style) {
    // Read custom properties
    const value = rule.style.getPropertyValue('--custom');
    
    // Set custom properties
    rule.style.setProperty('--custom', 'new-value');
  }
}
```

This modifies stylesheet rules directly, affecting all elements matching those rules. Changes persist across the stylesheet, not just inline styles.

### Constructable Stylesheets

Constructable stylesheets enable dynamic style creation:

```javascript
const sheet = new CSSStyleSheet();
sheet.replaceSync(`
  :root {
    --dynamic-color: #ff0000;
  }
`);

document.adoptedStyleSheets = [sheet];
```

Custom properties in constructable stylesheets are accessible via `getComputedStyle()` but not directly modifiable via the CSSStyleSheet API. [Inference] Modifying requires replacing the entire rule or using inline styles.

### CSS.registerProperty

The CSS Properties and Values API enables typed custom properties with defaults and inheritance control:

```javascript
CSS.registerProperty({
  name: '--my-color',
  syntax: '<color>',
  initialValue: '#000000',
  inherits: true
});
```

After registration, the custom property:

- Validates values against the specified syntax
- Provides a default value when undefined
- Controls inheritance behavior
- Enables smooth transitions and animations

Registered properties are still accessed via the same JavaScript APIs:

```javascript
element.style.setProperty('--my-color', '#ff0000');
getComputedStyle(element).getPropertyValue('--my-color'); // "#ff0000"
```

[Unverified] Browser support for `CSS.registerProperty` is modern browsers only (Chrome 78+, Edge 79+, Safari 16.4+). Firefox support is in development.

### Reading from Pseudo-elements

Custom properties on pseudo-elements are accessible:

```css
.element::before {
  --pseudo-color: #ff0000;
  content: '';
}
```

```javascript
const element = document.querySelector('.element');
const beforeStyles = getComputedStyle(element, '::before');
const color = beforeStyles.getPropertyValue('--pseudo-color');
```

The second argument to `getComputedStyle()` specifies the pseudo-element string. Standard pseudo-elements like `::before`, `::after`, `::first-line`, and `::first-letter` are supported.

Setting properties on pseudo-elements requires stylesheet manipulation; inline styles don't affect pseudo-elements.

### Retrieving All Custom Properties

[Inference] No native API lists all custom properties on an element. Iteration requires checking the computed style object:

```javascript
const styles = getComputedStyle(element);
const customProps = [];

for (let prop of styles) {
  if (prop.startsWith('--')) {
    customProps.push({
      name: prop,
      value: styles.getPropertyValue(prop)
    });
  }
}
```

This iterates through all computed properties, filtering for names starting with `--`.

[Unverified] The iteration approach may not capture all inherited custom properties in all browser implementations. Testing across browsers is recommended for critical functionality.

### Type Coercion and Parsing

Custom property values are always strings. Type conversion is manual:

```javascript
const spacing = getComputedStyle(element).getPropertyValue('--spacing').trim();
const spacingNum = parseFloat(spacing); // Converts "20px" to 20

const opacity = getComputedStyle(element).getPropertyValue('--opacity').trim();
const opacityNum = Number(opacity); // Converts "0.5" to 0.5
```

For complex values (colors, transforms), parsing requires additional libraries or regex:

```javascript
const color = getComputedStyle(element).getPropertyValue('--color').trim();
// Parse "#ff0000" or "rgb(255, 0, 0)" as needed
```

CSS custom properties don't provide automatic type conversion or structured value objects.

### Integration with Web Animations API

Custom properties work with the Web Animations API for declarative animations:

```javascript
element.animate(
  [
    { '--rotation': '0deg' },
    { '--rotation': '360deg' }
  ],
  {
    duration: 1000,
    iterations: Infinity
  }
);
```

[Unverified] Animating custom properties via the Web Animations API requires the property to be registered with `CSS.registerProperty()` for smooth interpolation. Unregistered properties may animate discretely rather than smoothly.

### CSS Variables in Inline Event Handlers

Custom properties set via JavaScript are accessible in CSS immediately:

```javascript
element.style.setProperty('--hover-color', '#ff0000');
```

```css
.element:hover {
  background: var(--hover-color, blue);
}
```

The hover state uses the dynamically-set value. This pattern enables JavaScript-controlled styling that leverages CSS selectors and pseudo-classes.

### Reading Properties from Different Documents

[Inference] Custom properties in iframes or different documents require accessing that document's elements:

```javascript
const iframe = document.querySelector('iframe');
const iframeDoc = iframe.contentDocument;
const iframeElement = iframeDoc.querySelector('.target');

const value = getComputedStyle(iframeElement).getPropertyValue('--custom');
```

Cross-origin restrictions apply. Same-origin iframes allow full access; cross-origin iframes block access to content.

### Common Patterns

**Responsive spacing system:**

```javascript
function updateSpacing() {
  const root = document.documentElement;
  const width = window.innerWidth;
  
  if (width < 768) {
    root.style.setProperty('--spacing-unit', '8px');
  } else if (width < 1024) {
    root.style.setProperty('--spacing-unit', '12px');
  } else {
    root.style.setProperty('--spacing-unit', '16px');
  }
}

window.addEventListener('resize', updateSpacing);
updateSpacing();
```

**User preference storage:**

```javascript
function loadThemePreferences() {
  const root = document.documentElement;
  const preferences = JSON.parse(localStorage.getItem('theme') || '{}');
  
  Object.entries(preferences).forEach(([prop, value]) => {
    root.style.setProperty(prop, value);
  });
}

function saveThemePreferences() {
  const root = document.documentElement;
  const style = root.style;
  const preferences = {};
  
  for (let i = 0; i < style.length; i++) {
    const prop = style[i];
    if (prop.startsWith('--')) {
      preferences[prop] = style.getPropertyValue(prop);
    }
  }
  
  localStorage.setItem('theme', JSON.stringify(preferences));
}
```

**Component-scoped variables:**

```javascript
class ThemedComponent {
  constructor(element) {
    this.element = element;
    this.setupTheme();
  }
  
  setupTheme() {
    this.element.style.setProperty('--component-bg', '#ffffff');
    this.element.style.setProperty('--component-text', '#000000');
  }
  
  setTheme(theme) {
    const colors = theme === 'dark' 
      ? { bg: '#1a1a1a', text: '#ffffff' }
      : { bg: '#ffffff', text: '#000000' };
    
    this.element.style.setProperty('--component-bg', colors.bg);
    this.element.style.setProperty('--component-text', colors.text);
  }
}
```

### Debugging Custom Properties

Browser DevTools display custom properties in the Computed or Styles panel. For programmatic debugging:

```javascript
function debugCustomProps(element) {
  const styles = getComputedStyle(element);
  const props = {};
  
  for (let prop of styles) {
    if (prop.startsWith('--')) {
      props[prop] = styles.getPropertyValue(prop).trim();
    }
  }
  
  console.table(props);
}

debugCustomProps(document.documentElement);
```

This logs all custom properties and values for inspection.

### Fallback Handling

The `var()` function in CSS accepts a fallback value. JavaScript doesn't affect this mechanism:

```css
.element {
  color: var(--text-color, black);
}
```

If `--text-color` is undefined or invalid, `black` is used. JavaScript reads the custom property value, not the resolved fallback:

```javascript
// If --text-color is undefined
getComputedStyle(element).getPropertyValue('--text-color'); // ""
getComputedStyle(element).getPropertyValue('color'); // "rgb(0, 0, 0)"
```

The `color` property shows the resolved value including fallback; the custom property returns empty string when undefined.

---

