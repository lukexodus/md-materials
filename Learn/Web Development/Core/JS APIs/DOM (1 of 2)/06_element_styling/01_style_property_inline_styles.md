## Style Property (Inline Styles)


### Direct Style Manipulation

The `style` property provides direct access to an element's inline CSS styles through the `CSSStyleDeclaration` interface. It operates exclusively on the `style` attribute of HTML elements.

```javascript
element.style.propertyName = value;
const currentValue = element.style.propertyName;
```

### CSSStyleDeclaration Interface

#### Property Access Patterns

**camelCase Properties**

```javascript
element.style.backgroundColor = 'red';
element.style.fontSize = '16px';
element.style.marginTop = '20px';
```

**Bracket Notation with Hyphens**

```javascript
element.style['background-color'] = 'red';
element.style['font-size'] = '16px';
```

**cssText Property**

```javascript
// Set multiple properties at once
element.style.cssText = 'color: blue; font-size: 14px; margin: 10px;';

// Append to existing styles
element.style.cssText += 'padding: 5px;';

// Read all inline styles
const allStyles = element.style.cssText;
```

#### setProperty() and getPropertyValue()

```javascript
// Set with optional priority
element.style.setProperty('color', 'blue');
element.style.setProperty('width', '100px', 'important');

// Get property value
const color = element.style.getPropertyValue('color');

// Remove property
element.style.removeProperty('color');

// Get priority
const priority = element.style.getPropertyPriority('width'); // returns 'important' or ''
```

### Specificity and Cascade Behavior

Inline styles have a specificity of `1,0,0,0`, making them more specific than IDs, classes, and element selectors. They are only overridden by `!important` declarations in stylesheets or other inline `!important` declarations.

```javascript
// This creates style="color: blue !important;"
element.style.setProperty('color', 'blue', 'important');
```

### Reading Computed vs Inline Styles

The `style` property only returns values explicitly set as inline styles. It does **not** return computed styles from stylesheets.

```javascript
// HTML: <div id="box" class="styled"></div>
// CSS: .styled { color: red; width: 200px; }

const box = document.getElementById('box');

console.log(box.style.color);  // "" (empty, not "red")
console.log(box.style.width);  // "" (empty, not "200px")

box.style.color = 'blue';
console.log(box.style.color);  // "blue"
```

To read computed styles, use `window.getComputedStyle()` instead:

```javascript
const computed = window.getComputedStyle(box);
console.log(computed.color);  // "rgb(255, 0, 0)"
console.log(computed.width);  // "200px"
```

### Numeric Values and Units

Style values are always strings and require units for numeric properties.

```javascript
// Correct
element.style.width = '100px';
element.style.opacity = '0.5';
element.style.zIndex = '10';

// Incorrect - no effect or unexpected behavior
element.style.width = 100;  // No unit, ignored
element.style.margin = 20;  // No unit, ignored
```

**Exception for unitless properties:**

```javascript
element.style.opacity = '0.5';  // Can be string
element.style.opacity = 0.5;    // [Inference] May work in some browsers, but string is standard
element.style.zIndex = 10;      // Unitless property accepts numbers
```

### Shorthand vs Longhand Properties

```javascript
// Shorthand sets multiple longhand properties
element.style.margin = '10px 20px';
// Equivalent to:
// element.style.marginTop = '10px';
// element.style.marginRight = '20px';
// element.style.marginBottom = '10px';
// element.style.marginLeft = '20px';

// Reading shorthand properties
console.log(element.style.margin);  // Returns value only if all longhand properties match
```

**Reading behavior:**

```javascript
element.style.marginTop = '10px';
element.style.marginRight = '20px';
element.style.marginBottom = '10px';
element.style.marginLeft = '20px';

console.log(element.style.margin);  // "" (empty) - longhands don't match
```

### CSS Custom Properties (CSS Variables)

```javascript
// Set custom property
element.style.setProperty('--main-color', '#3498db');

// Get custom property
const mainColor = element.style.getPropertyValue('--main-color');

// Use in other properties
element.style.backgroundColor = 'var(--main-color)';

// Remove custom property
element.style.removeProperty('--main-color');
```

### Length and Item Access

```javascript
// Number of inline style properties
const count = element.style.length;

// Access by index
for (let i = 0; i < element.style.length; i++) {
  const propertyName = element.style[i];
  const propertyValue = element.style.getPropertyValue(propertyName);
  console.log(`${propertyName}: ${propertyValue}`);
}

// Named access
const propertyName = element.style.item(0);
```

### Clearing Styles

```javascript
// Remove specific property
element.style.backgroundColor = '';
element.style.removeProperty('background-color');

// Clear all inline styles
element.style.cssText = '';
element.removeAttribute('style');
```

### Performance Considerations

**Reflow and Repaint**

Each style modification can trigger reflow (layout recalculation) and repaint:

```javascript
// Poor - causes multiple reflows
element.style.width = '100px';
element.style.height = '100px';
element.style.padding = '10px';

// Better - single reflow
element.style.cssText = 'width: 100px; height: 100px; padding: 10px;';
```

**Batching with DocumentFragment or Display None**

```javascript
// Technique 1: Remove from DOM
const parent = element.parentNode;
parent.removeChild(element);
element.style.width = '100px';
element.style.height = '100px';
parent.appendChild(element);

// Technique 2: Hide during modifications
element.style.display = 'none';
element.style.width = '100px';
element.style.height = '100px';
element.style.display = '';
```

**[Inference] Reading offsetHeight/offsetWidth forces synchronous layout:**

```javascript
element.style.width = '100px';
const height = element.offsetHeight;  // Forces immediate reflow
element.style.height = '200px';
```

### Browser Vendor Prefixes

```javascript
// Standard property
element.style.transform = 'rotate(45deg)';

// Vendor prefixes (mostly legacy)
element.style.webkitTransform = 'rotate(45deg)';
element.style.MozTransform = 'rotate(45deg)';
element.style.msTransform = 'rotate(45deg)';

// Detection pattern
if ('transform' in element.style) {
  element.style.transform = 'rotate(45deg)';
} else if ('webkitTransform' in element.style) {
  element.style.webkitTransform = 'rotate(45deg)';
}
```

### Edge Cases and Gotchas

**Invalid Values**

```javascript
element.style.color = 'not-a-color';
console.log(element.style.color);  // "" (empty, invalid value ignored)

element.style.color = 'blue';
element.style.color = 'invalid';
console.log(element.style.color);  // "blue" (previous valid value retained)
```

**URL Values**

```javascript
element.style.backgroundImage = 'url(image.jpg)';
element.style.backgroundImage = "url('image.jpg')";
element.style.backgroundImage = 'url("image.jpg")';
// All valid syntaxes
```

**calc() and Other Functions**

```javascript
element.style.width = 'calc(100% - 50px)';
element.style.transform = 'translateX(calc(100% + 20px))';
```

**Empty Strings vs Null**

```javascript
element.style.color = '';      // Removes property
element.style.color = null;    // [Inference] Converts to string "null", likely ignored
element.style.color = undefined; // [Inference] Converts to string "undefined", likely ignored
```

### Animation and Transition Integration

```javascript
// Triggering CSS transitions
element.style.transition = 'all 0.3s ease';
element.style.opacity = '0';

// Force reflow to ensure transition fires
element.offsetHeight; 
element.style.opacity = '1';

// Listening for transition end
element.addEventListener('transitionend', (e) => {
  console.log(`${e.propertyName} transition completed`);
});
```

### Common Patterns

**Toggle Visibility**

```javascript
element.style.display = element.style.display === 'none' ? '' : 'none';

// Or with explicit values
element.style.display = element.style.display === 'none' ? 'block' : 'none';
```

**Conditional Styling**

```javascript
element.style.color = isActive ? 'green' : 'gray';
element.style.fontWeight = isActive ? 'bold' : 'normal';
```

**Copying Styles**

```javascript
const sourceStyles = source.style.cssText;
target.style.cssText = sourceStyles;
```

### Relationship with setAttribute

```javascript
// Using style property (recommended)
element.style.color = 'red';

// Using setAttribute (not recommended for styles)
element.setAttribute('style', 'color: red');

// Difference: setAttribute replaces entire style attribute
element.style.color = 'red';
element.style.fontSize = '14px';
element.setAttribute('style', 'color: blue');  // fontSize is lost
```

---

