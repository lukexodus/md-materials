## getAttribute


### Syntax and Return Value

`getAttribute()` retrieves the value of a specified attribute on an element. Returns the attribute's string value, or `null` if the attribute doesn't exist.

```javascript
let value = element.getAttribute(attributeName);
```

The `attributeName` parameter is case-insensitive for HTML documents but case-sensitive for XML/XHTML documents.

### Return Value Semantics

Always returns a string or `null`, never `undefined`:

```javascript
const div = document.querySelector('div');

div.getAttribute('id'); // "myDiv" or null
div.getAttribute('data-count'); // "5" (string, not number)
div.getAttribute('disabled'); // "" (empty string if present without value)
div.getAttribute('nonexistent'); // null
```

Empty attributes return empty strings:

```javascript
<input disabled>

input.getAttribute('disabled'); // "" (empty string, not null)
input.hasAttribute('disabled'); // true
```

### getAttribute vs Property Access

Attributes and properties are distinct concepts that often cause confusion:

```javascript
<input type="text" value="initial">

const input = document.querySelector('input');

// Attribute (HTML) - reflects initial HTML state
input.getAttribute('value'); // "initial"

// Property (DOM) - reflects current runtime state
input.value; // "initial"

// User types "changed"
input.value; // "changed"
input.getAttribute('value'); // Still "initial"

// Setting property doesn't update attribute
input.value = "new";
input.getAttribute('value'); // Still "initial"

// Setting attribute doesn't update property for some attributes
input.setAttribute('value', 'reset');
input.value; // Still "new" (for value, property takes precedence)
```

#### Key Differences

**Type conversion:**

```javascript
<input type="checkbox" checked>

input.checked; // true (boolean)
input.getAttribute('checked'); // "" (string)

input.checked = false;
input.getAttribute('checked'); // Still "" (attribute unchanged)
```

**URL attributes:**

```javascript
<a href="/path">

link.href; // "https://example.com/path" (absolute URL)
link.getAttribute('href'); // "/path" (as written in HTML)
```

**Class handling:**

```javascript
element.className; // "foo bar baz"
element.getAttribute('class'); // "foo bar baz"
element.classList; // DOMTokenList object
```

**Style attribute:**

```javascript
<div style="color: red;">

div.style; // CSSStyleDeclaration object
div.style.color; // "red"
div.getAttribute('style'); // "color: red;" (string)
```

### Custom Data Attributes

`getAttribute` is the primary way to access custom attributes, though `dataset` provides an alternative for `data-*` attributes:

```javascript
<div data-user-id="123" data-role-type="admin" custom-attr="value">

// getAttribute works for any attribute
div.getAttribute('data-user-id'); // "123"
div.getAttribute('custom-attr'); // "value"

// dataset only works for data-* attributes
div.dataset.userId; // "123" (camelCase conversion)
div.dataset.roleType; // "admin"
div.dataset.customAttr; // undefined (not a data-* attribute)

// dataset is read-write, bidirectional
div.dataset.userId = "456";
div.getAttribute('data-user-id'); // "456"
```

### Namespaced Attributes (XML/SVG)

For XML namespaces, use `getAttributeNS`:

```javascript
const svg = document.querySelector('svg');

// Standard getAttribute
svg.getAttribute('viewBox'); // Works for non-namespaced

// Namespaced attributes in SVG/XML
svg.getAttributeNS('http://www.w3.org/1999/xlink', 'href');

// Namespaced example
const use = document.createElementNS('http://www.w3.org/2000/svg', 'use');
use.setAttributeNS(
  'http://www.w3.org/1999/xlink',
  'xlink:href',
  '#icon'
);
use.getAttributeNS('http://www.w3.org/1999/xlink', 'href'); // "#icon"
```

### Boolean Attributes

HTML boolean attributes are present/absent, not true/false:

```javascript
<button disabled>
<input checked>
<video autoplay>

// Present = true (regardless of value)
button.hasAttribute('disabled'); // true
button.getAttribute('disabled'); // "" or "disabled" or any value

// Absent = false
input.hasAttribute('required'); // false
input.getAttribute('required'); // null

// Common mistake - checking truthiness of getAttribute
if (button.getAttribute('disabled')) { // ❌ Wrong
  // Empty string is falsy, but attribute IS present
}

// Correct approach
if (button.hasAttribute('disabled')) { // ✓ Correct
  // Properly checks presence
}

// Or use property
if (button.disabled) { // ✓ Correct (boolean property)
}
```

### ARIA Attributes

ARIA attributes are accessed like standard attributes:

```javascript
<div role="button" aria-label="Close" aria-expanded="false">

div.getAttribute('role'); // "button"
div.getAttribute('aria-label'); // "Close"
div.getAttribute('aria-expanded'); // "false" (string)

// Properties don't exist for most ARIA attributes
div.ariaExpanded; // undefined in many browsers
div.getAttribute('aria-expanded'); // "false" - reliable

// Some browsers support aria* properties
div.ariaLabel; // "Close" (if supported)
```

---

