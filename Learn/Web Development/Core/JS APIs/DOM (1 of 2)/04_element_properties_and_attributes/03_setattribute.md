## setAttribute


### Syntax and Behavior

`setAttribute()` sets the value of an attribute on an element. If the attribute already exists, its value is updated; otherwise, a new attribute is added.

```javascript
element.setAttribute(name, value);
```

Both parameters are converted to strings automatically:

```javascript
div.setAttribute('data-count', 42); // Stored as "42"
div.setAttribute('data-active', true); // Stored as "true"
div.setAttribute('data-obj', {foo: 'bar'}); // "[object Object]"
```

### No Return Value

`setAttribute` returns `undefined` - it's a mutating operation:

```javascript
const result = element.setAttribute('id', 'test');
// result is undefined
```

### Attribute Name Normalization

In HTML documents, attribute names are automatically lowercased:

```javascript
// HTML document
div.setAttribute('DataValue', '123');
div.getAttribute('datavalue'); // "123"
div.getAttribute('DataValue'); // "123" (same)

// XML/XHTML document - case sensitive
xmlElement.setAttribute('DataValue', '123');
xmlElement.getAttribute('datavalue'); // null
xmlElement.getAttribute('DataValue'); // "123"
```

### Setting Boolean Attributes

For boolean attributes, the presence matters, not the value:

```javascript
// All of these enable the attribute
button.setAttribute('disabled', '');
button.setAttribute('disabled', 'disabled');
button.setAttribute('disabled', 'false'); // Still disabled!
button.setAttribute('disabled', 'true');

// To disable, must remove the attribute
button.removeAttribute('disabled');

// Common mistake
button.setAttribute('disabled', false); // ❌ Still sets attribute to "false"
button.disabled = false; // ✓ Correct - uses property
```

Valid boolean attributes in HTML5:

- `checked`, `disabled`, `selected`, `required`, `readonly`
- `multiple`, `autofocus`, `autoplay`, `controls`, `loop`, `muted`
- `default`, `ismap`, `async`, `defer`, `reversed`, `open`, `hidden`

### setAttribute vs Property Assignment

Property assignment is often preferable for standard attributes:

```javascript
// Using setAttribute
input.setAttribute('value', 'text');
input.setAttribute('type', 'email');
input.setAttribute('disabled', '');

// Using properties - more idiomatic
input.value = 'text';
input.type = 'email';
input.disabled = true;

// Properties have type safety
input.maxLength = 10; // Number
input.setAttribute('maxLength', '10'); // String

// Some properties have no attribute equivalent
input.selectionStart = 5; // No corresponding attribute
```

**When to use setAttribute:**

- Custom attributes (non-standard)
- Data attributes (though `dataset` is alternative)
- When you specifically need to modify HTML attribute
- ARIA attributes
- SVG attributes
- When attribute name is dynamic

```javascript
// Dynamic attribute name
const attrName = 'data-' + someVariable;
element.setAttribute(attrName, value);

// Custom attributes
element.setAttribute('my-custom-attr', 'value');

// ARIA
element.setAttribute('aria-label', 'descriptive text');
```

### Triggering Attribute Changes

Setting an attribute can trigger various browser behaviors:

```javascript
// Triggers style recalculation
element.setAttribute('class', 'new-class');

// May trigger reflow/repaint
element.setAttribute('style', 'width: 100px;');

// Triggers form validation
input.setAttribute('required', '');
input.setAttribute('pattern', '[0-9]+');

// Triggers resource loading
img.setAttribute('src', 'new-image.jpg');
link.setAttribute('href', 'new-stylesheet.css');
```

### Attribute Mutation Observers

`setAttribute` triggers MutationObserver callbacks:

```javascript
const observer = new MutationObserver(mutations => {
  mutations.forEach(mutation => {
    if (mutation.type === 'attributes') {
      console.log(`${mutation.attributeName} changed`);
      console.log('Old:', mutation.oldValue);
      console.log('New:', mutation.target.getAttribute(mutation.attributeName));
    }
  });
});

observer.observe(element, {
  attributes: true,
  attributeOldValue: true,
  attributeFilter: ['data-status', 'class'] // Optional: specific attributes
});

element.setAttribute('data-status', 'active'); // Triggers observer
```

### Security and Sanitization

Never set attributes from untrusted input without sanitization:

```javascript
// DANGEROUS
const userInput = getUserInput();
element.setAttribute('onclick', userInput); // XSS vulnerability
element.setAttribute('href', userInput); // javascript: protocol exploit

// SAFER - sanitize/validate
const safeValue = sanitizeInput(userInput);
element.setAttribute('data-user-input', safeValue);

// For URLs, validate protocol
function isSafeURL(url) {
  try {
    const parsed = new URL(url, window.location.href);
    return ['http:', 'https:', 'mailto:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}

if (isSafeURL(userInput)) {
  link.setAttribute('href', userInput);
}
```

### SVG and XML Namespaces

For namespaced attributes, use `setAttributeNS`:

```javascript
const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
const use = document.createElementNS('http://www.w3.org/2000/svg', 'use');

// Namespaced attribute
use.setAttributeNS(
  'http://www.w3.org/1999/xlink',
  'xlink:href',
  '#my-icon'
);

// Standard SVG attribute (no namespace)
svg.setAttribute('viewBox', '0 0 100 100');
svg.setAttribute('width', '100');
svg.setAttribute('height', '100');
```

### Performance Considerations

Batch attribute changes when possible:

```javascript
// Multiple reflows - inefficient
element.setAttribute('class', 'foo');
element.setAttribute('id', 'bar');
element.setAttribute('data-value', '123');

// Better - batch via DocumentFragment or detached element
const fragment = document.createDocumentFragment();
const temp = element.cloneNode(false);
temp.setAttribute('class', 'foo');
temp.setAttribute('id', 'bar');
temp.setAttribute('data-value', '123');
element.parentNode.replaceChild(temp, element);

// Or modify before insertion
const newElement = document.createElement('div');
newElement.setAttribute('class', 'foo');
newElement.setAttribute('id', 'bar');
newElement.setAttribute('data-value', '123');
parent.appendChild(newElement);
```

---

