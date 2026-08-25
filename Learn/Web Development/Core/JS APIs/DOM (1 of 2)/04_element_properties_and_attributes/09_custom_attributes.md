## Custom Attributes


### Standard vs Custom Attributes

HTML elements support predefined attributes like `id`, `class`, `href`, `src`, and `type` that browsers recognize and process. Custom attributes are non-standard attributes added to elements for application-specific purposes, traditionally written with arbitrary names like `data-user-id` or `role`.

The DOM exposes standard attributes as properties directly on element objects (`element.id`, `element.className`), while custom attributes require explicit methods like `getAttribute()` and `setAttribute()` for access.

### Data Attributes

The HTML5 specification formalized custom attributes through the `data-*` naming convention. Any attribute prefixed with `data-` is valid HTML and intended for storing custom data:

```html
<div data-user-id="12345" 
     data-role="admin" 
     data-last-login="2024-03-15"
     data-preferences='{"theme":"dark","lang":"en"}'>
</div>
```

These attributes:

- Pass HTML validation
- Won't conflict with future HTML specifications
- Are ignored by browsers for styling/behavior (unless targeted via CSS/JS)
- Provide semantic indication of custom data storage

### Dataset API

Elements expose data attributes through the `dataset` property, which returns a `DOMStringMap` object. Attribute names undergo transformation:

- Remove `data-` prefix
- Convert kebab-case to camelCase
- Hyphens followed by lowercase letters become uppercase letters

```javascript
const element = document.querySelector('div');

// Reading
element.dataset.userId; // "12345"
element.dataset.role; // "admin"
element.dataset.lastLogin; // "2024-03-15"
element.dataset.preferences; // '{"theme":"dark","lang":"en"}'

// Writing
element.dataset.userId = "67890";
element.dataset.newAttribute = "value";

// Deleting
delete element.dataset.role;

// Check existence
'userId' in element.dataset; // true
element.dataset.hasOwnProperty('userId'); // true
```

The transformation is bidirectional:

```javascript
element.dataset.userName = "john"; // Creates data-user-name
element.dataset.XMLData = "content"; // Creates data-x-m-l-data
element.dataset['multi-part-name'] = "value"; // Creates data-multi-part-name
```

### getAttribute/setAttribute Methods

For non-data custom attributes or direct attribute manipulation, use these methods:

```javascript
const element = document.querySelector('div');

// Set attributes
element.setAttribute('custom-attr', 'value');
element.setAttribute('aria-label', 'Description');
element.setAttribute('role', 'button');

// Read attributes
element.getAttribute('custom-attr'); // "value"
element.getAttribute('data-user-id'); // "12345"

// Check existence
element.hasAttribute('custom-attr'); // true

// Remove attributes
element.removeAttribute('custom-attr');

// Get all attributes
const attrs = element.attributes; // NamedNodeMap
for (let attr of attrs) {
  console.log(attr.name, attr.value);
}
```

Key differences from dataset:

- Case-sensitive (attribute names are case-insensitive in HTML but case-sensitive when accessed)
- Returns `null` for non-existent attributes (not `undefined`)
- Works with any attribute, not just `data-*`
- Accepts any value type but converts to strings

### Type Handling and Serialization

All attribute values are strings. Type conversion must be handled explicitly:

```javascript
element.dataset.count = 42; // Stored as "42"
typeof element.dataset.count; // "string"

// Manual conversion required
const count = parseInt(element.dataset.count, 10);
const price = parseFloat(element.dataset.price);
const active = element.dataset.active === 'true';

// JSON for complex data
element.dataset.config = JSON.stringify({theme: 'dark', size: 'large'});
const config = JSON.parse(element.dataset.config);
```

Boolean attributes follow HTML conventions where presence indicates `true`:

```javascript
element.setAttribute('disabled', ''); // Disabled
element.setAttribute('disabled', 'disabled'); // Also disabled
element.hasAttribute('disabled'); // true
element.getAttribute('disabled'); // "" or "disabled"

// Standard boolean properties differ
element.disabled = true; // Property
element.getAttribute('disabled'); // "" (attribute)
```

### Performance Considerations

Accessing attributes triggers different code paths than properties:

```javascript
// Property access (fast, direct memory access)
element.id;
element.className;

// Attribute access (slower, string serialization/parsing)
element.getAttribute('id');
element.dataset.userId;
```

[Inference: Modern engines optimize frequent dataset access, but properties remain faster for high-frequency reads]. For intensive operations, cache values:

```javascript
// Suboptimal: reads attribute 1000 times
for (let i = 0; i < 1000; i++) {
  processData(element.dataset.userId);
}

// Optimized: single read
const userId = element.dataset.userId;
for (let i = 0; i < 1000; i++) {
  processData(userId);
}
```

### CSS Attribute Selectors

Custom attributes enable powerful CSS targeting:

```css
/* Select by data attribute presence */
[data-role] { }

/* Select by exact value */
[data-role="admin"] { }

/* Select by value containing word */
[data-permissions~="write"] { }

/* Select by value starting with */
[data-id^="user-"] { }

/* Select by value ending with */
[data-file$=".pdf"] { }

/* Select by value containing substring */
[data-path*="/images/"] { }

/* Case-insensitive matching */
[data-status="active" i] { }
```

Attribute selectors work with any custom attribute, not just `data-*`:

```css
[custom-tooltip] { position: relative; }
[aria-expanded="true"] { }
```

### ARIA Attributes

ARIA (Accessible Rich Internet Applications) attributes are standardized custom attributes for accessibility:

```html
<button aria-label="Close dialog" 
        aria-pressed="false"
        aria-controls="dialog-1">
  ×
</button>

<div role="dialog" 
     aria-labelledby="dialog-title"
     aria-modal="true">
</div>
```

While not `data-*` prefixed, ARIA attributes follow similar patterns:

- Accessed via `getAttribute()`/`setAttribute()`
- No direct property equivalents (except `element.role`)
- String values requiring manual type conversion
- Validated by accessibility tools

```javascript
button.getAttribute('aria-pressed'); // "false" (string)
button.setAttribute('aria-pressed', 'true');
button.setAttribute('aria-label', 'Close dialog');
```

### Microdata Attributes

HTML5 microdata provides another standard for custom attributes:

```html
<div itemscope itemtype="https://schema.org/Person">
  <span itemprop="name">John Doe</span>
  <span itemprop="jobTitle">Software Engineer</span>
  <a itemprop="url" href="https://example.com">Website</a>
</div>
```

These attributes:

- `itemscope`: Defines a new item
- `itemtype`: Specifies item type via URL
- `itemprop`: Names properties within items
- `itemid`: Provides unique identifier
- `itemref`: References elements by ID

Access requires standard attribute methods:

```javascript
element.hasAttribute('itemscope'); // true
element.getAttribute('itemtype'); // "https://schema.org/Person"
```

### Custom Attribute Naming Conventions

Best practices for custom attribute names:

__Use data-_ for application data:_*

```html
<div data-component="modal" data-animation-duration="300"></div>
```

**Use kebab-case for readability:**

```html
<div data-user-preferences="..." data-last-modified-date="..."></div>
```

**Namespace complex applications:**

```html
<div data-app-user-id="123" data-app-session-token="..."></div>
```

**Avoid conflicts with future standards:**

```html
<!-- Risky: may conflict with future HTML -->
<div loading="custom-value"></div>

<!-- Safe: clearly custom -->
<div data-loading-state="custom-value"></div>
```

### Mutation and Reactivity

Attribute changes trigger `MutationObserver` with `attributes: true`:

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
  attributeFilter: ['data-status', 'data-count'] // Optional: specific attributes
});

element.dataset.status = 'active'; // Triggers observer
```

CSS attribute selectors automatically respond to changes:

```css
[data-status="loading"] { opacity: 0.5; }
[data-status="complete"] { opacity: 1; }
```

```javascript
element.dataset.status = 'loading'; // Style updates immediately
setTimeout(() => {
  element.dataset.status = 'complete'; // Style updates again
}, 1000);
```

### Security Considerations

Custom attributes are visible in HTML source and developer tools. Never store sensitive data:

```html
<!-- INSECURE -->
<div data-password="secret123" 
     data-api-key="sk_live_abc123"
     data-ssn="123-45-6789"></div>

<!-- SECURE -->
<div data-user-id="12345" 
     data-session-ref="uuid-here"></div>
```

User-supplied data in attributes requires sanitization:

```javascript
// Potential XSS if userName contains quotes
element.setAttribute('data-name', userName);

// Safer: encode or validate
element.setAttribute('data-name', escapeHtml(userName));

// Safest with dataset (handles encoding)
element.dataset.name = userName; // Automatically escaped
```

[Inference: Dataset API provides some protection by handling attribute value encoding, though XSS risks remain if attribute values are later rendered unsafely].

### Cloning and Serialization

Custom attributes are preserved during cloning:

```javascript
const original = document.createElement('div');
original.dataset.userId = '123';
original.setAttribute('custom-attr', 'value');

const clone = original.cloneNode(true);
clone.dataset.userId; // "123"
clone.getAttribute('custom-attr'); // "value"
```

Serialization includes all attributes:

```javascript
element.outerHTML; 
// '<div data-user-id="123" custom-attr="value"></div>'

element.innerHTML = '<span data-role="item">Text</span>';
// Parsed span has data-role attribute
```

### Framework Integration

Many frameworks provide abstractions over custom attributes:

**React** uses `data-*` attributes directly but handles other attributes via props:

```javascript
<div data-user-id={userId} />
// Renders: <div data-user-id="123"></div>
```

**Vue** binds attributes with `v-bind` or `:`:

```javascript
<div :data-user-id="userId"></div>
```

**Svelte** uses standard attribute syntax:

```javascript
<div data-user-id={userId}></div>
```

Frameworks typically convert these to `setAttribute()` calls or direct property assignment based on the attribute name.

### Legacy Patterns

Before `dataset` API, custom attributes used various patterns:

```javascript
// Direct attribute manipulation (pre-HTML5)
element.setAttribute('userid', '123');
element.getAttribute('userid');

// Custom properties on element objects
element.customData = {userId: 123};

// Parallel data structures
const elementData = new WeakMap();
elementData.set(element, {userId: 123});
```

Modern code should prefer `data-*` attributes with `dataset` API for standardization and HTML validity.

---

