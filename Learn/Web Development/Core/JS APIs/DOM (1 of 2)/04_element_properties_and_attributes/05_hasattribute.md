## hasAttribute


### Syntax and Return Value

`hasAttribute()` returns a boolean indicating whether the element has the specified attribute.

```javascript
let result = element.hasAttribute(attributeName);
```

Returns `true` if attribute exists (regardless of value), `false` otherwise.

### Checking Attribute Presence

The canonical way to test if an attribute exists:

```javascript
<button disabled="">
<input checked>
<div data-value="">

button.hasAttribute('disabled'); // true
button.getAttribute('disabled'); // "" (empty string is truthy)

input.hasAttribute('checked'); // true
div.hasAttribute('data-value'); // true
div.hasAttribute('data-other'); // false
```

### hasAttribute vs getAttribute Null Check

Both approaches work, but have different semantics:

```javascript
// Using hasAttribute - explicit, more readable
if (element.hasAttribute('data-loaded')) {
  // Attribute exists
}

// Using getAttribute - implicit null check
if (element.getAttribute('data-loaded') !== null) {
  // Attribute exists
}

// Common mistake - truthiness check fails for empty attributes
if (element.getAttribute('disabled')) { // ❌ Wrong
  // Empty string is falsy, but attribute exists
}

if (element.hasAttribute('disabled')) { // ✓ Correct
  // Properly checks presence
}
```

### Boolean Attribute Detection

Essential for boolean attributes:

```javascript
<form>
  <input required>
  <input>
</form>

const inputs = form.querySelectorAll('input');

inputs[0].hasAttribute('required'); // true
inputs[1].hasAttribute('required'); // false

// Property access for boolean attributes
inputs[0].required; // true (boolean)
inputs[1].required; // false (boolean)

// getAttribute returns string or null
inputs[0].getAttribute('required'); // "" (empty string)
inputs[1].getAttribute('required'); // null
```

### Attribute Name Case Sensitivity

In HTML documents, attribute names are case-insensitive:

```javascript
// HTML document
element.setAttribute('DataValue', '123');

element.hasAttribute('datavalue'); // true
element.hasAttribute('DataValue'); // true
element.hasAttribute('DATAVALUE'); // true

// XML/XHTML - case sensitive
xmlElement.hasAttribute('datavalue'); // false
xmlElement.hasAttribute('DataValue'); // true
```

### Performance Benefits

`hasAttribute` is more performant than alternatives when you only need to check existence:

```javascript
// Fastest - single boolean check
if (element.hasAttribute('data-cached')) { }

// Slower - retrieves value then checks
if (element.getAttribute('data-cached') !== null) { }

// Slowest - retrieves value, converts, checks
if (element.dataset.cached) { }
```

### Common Patterns

#### Conditional Logic Based on Presence

```javascript
// Toggle attribute based on presence
if (element.hasAttribute('aria-hidden')) {
  element.removeAttribute('aria-hidden');
} else {
  element.setAttribute('aria-hidden', 'true');
}

// Conditional attribute addition
if (!element.hasAttribute('role')) {
  element.setAttribute('role', 'button');
}
```

#### Form Validation

```javascript
function isRequired(input) {
  return input.hasAttribute('required');
}

function validateInput(input) {
  if (isRequired(input) && !input.value) {
    return 'This field is required';
  }
  
  if (input.hasAttribute('pattern')) {
    const pattern = new RegExp(input.getAttribute('pattern'));
    if (!pattern.test(input.value)) {
      return 'Invalid format';
    }
  }
  
  return null;
}
```

#### Feature Detection

```javascript
// Check for specific HTML5 attributes
const hasPlaceholder = input.hasAttribute('placeholder');
const hasAutofocus = input.hasAttribute('autofocus');

// Check custom attributes
if (element.hasAttribute('data-initialized')) {
  // Already initialized, skip
  return;
}

element.setAttribute('data-initialized', 'true');
// Initialize component
```

### Working with Custom Attributes

```javascript
<div custom-attr="value" data-type="user">

// Check any attribute
div.hasAttribute('custom-attr'); // true
div.hasAttribute('data-type'); // true

// Common pattern: graceful fallback
const type = div.hasAttribute('data-type') 
  ? div.getAttribute('data-type')
  : 'default';

// Or using optional chaining and nullish coalescing
const type = div.getAttribute('data-type') ?? 'default';
```

### ARIA Attribute Presence

```javascript
function updateARIA(element, expanded) {
  if (!element.hasAttribute('role')) {
    element.setAttribute('role', 'button');
  }
  
  element.setAttribute('aria-expanded', expanded);
  
  // Only set aria-controls if target exists
  const target = element.getAttribute('data-target');
  if (target && document.getElementById(target)) {
    element.setAttribute('aria-controls', target);
  }
}

// Check required ARIA attributes
function validateARIAButton(button) {
  const errors = [];
  
  if (button.hasAttribute('aria-expanded') && 
      !button.hasAttribute('aria-controls')) {
    errors.push('aria-expanded requires aria-controls');
  }
  
  return errors;
}
```

### Namespaced Attributes

For XML namespaces, use `hasAttributeNS`:

```javascript
const svg = document.querySelector('svg use');

// Standard check
svg.hasAttribute('href'); // May be false for namespaced href

// Namespaced check
svg.hasAttributeNS('http://www.w3.org/1999/xlink', 'href'); // true
```

### Integration with Other Methods

#### Combining with Selector Matching

```javascript
// Find elements with specific attribute
const elements = Array.from(document.querySelectorAll('[data-component]'))
  .filter(el => el.hasAttribute('data-initialized'));

// Attribute selector in querySelector
document.querySelectorAll('[disabled]'); // Matches all with disabled attr
```

#### Attribute Toggle Pattern

```javascript
function toggleAttribute(element, name, force) {
  if (force === undefined) {
    force = !element.hasAttribute(name);
  }
  
  if (force) {
    element.setAttribute(name, '');
  } else {
    element.removeAttribute(name);
  }
  
  return force;
}

// Usage
toggleAttribute(button, 'disabled'); // Toggles
toggleAttribute(button, 'disabled', true); // Forces on
toggleAttribute(button, 'disabled', false); // Forces off

// Native toggleAttribute (modern browsers)
element.toggleAttribute('hidden'); // Returns new state
element.toggleAttribute('hidden', true); // Force to true
```

### Debugging and Inspection

```javascript
// List all attributes on an element
function getAttributes(element) {
  return Array.from(element.attributes).map(attr => ({
    name: attr.name,
    value: attr.value,
    exists: element.hasAttribute(attr.name)
  }));
}

// Check for common attributes
function auditElement(element) {
  const checks = {
    hasId: element.hasAttribute('id'),
    hasClass: element.hasAttribute('class'),
    hasData: Array.from(element.attributes)
      .some(attr => attr.name.startsWith('data-')),
    hasAria: Array.from(element.attributes)
      .some(attr => attr.name.startsWith('aria-')),
    hasRole: element.hasAttribute('role')
  };
  
  return checks;
}
```

### Edge Cases

```javascript
// Empty attribute name
element.hasAttribute(''); // false (invalid)

// Whitespace in name
element.setAttribute('data name', 'value'); // Invalid in HTML
element.hasAttribute('data name'); // Behavior undefined

// Special characters
element.setAttribute('data-user-id', '123');
element.hasAttribute('data-user-id'); // true

// Unicode in attribute names (valid but unusual)
element.setAttribute('data-名前', 'value');
element.hasAttribute('data-名前'); // true
```

### Cross-browser Consistency

`hasAttribute` is well-supported (IE8+) and consistent:

```javascript
// Reliable across all modern browsers
if (element.hasAttribute('disabled')) {
  // Consistent behavior everywhere
}

// More reliable than checking properties for custom attributes
if (element.customAttr) { // May not exist
}

if (element.hasAttribute('custom-attr')) { // Always works
}
```

---

