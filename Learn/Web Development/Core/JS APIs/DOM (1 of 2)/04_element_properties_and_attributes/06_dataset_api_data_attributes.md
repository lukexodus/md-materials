## Dataset API (data-* attributes)


### API Overview and Access

The `dataset` property provides a `DOMStringMap` interface for reading and writing custom data attributes. It's available on all `HTMLElement` instances.

```javascript
const element = document.querySelector('.item');

// Access via dataset
element.dataset.userId; // Reads data-user-id
element.dataset.userId = '123'; // Writes data-user-id="123"

// Equivalent getAttribute/setAttribute
element.getAttribute('data-user-id');
element.setAttribute('data-user-id', '123');
```

### Naming Conventions and Transformations

#### HTML to JavaScript Conversion

The transformation follows camelCase conversion rules:

```javascript
// HTML attribute → JavaScript property
data-user-id → dataset.userId
data-product-name → dataset.productName
data-api-key → dataset.apiKey
data-item → dataset.item
data-3d-model → dataset['3dModel'] // Starts with digit, use bracket notation
```

#### Transformation Rules

```javascript
// Hyphens removed, following character uppercased
data-background-color → dataset.backgroundColor

// Multiple consecutive hyphens
data-user--id → dataset['user-Id'] // [Inference] One hyphen removed, next char uppercased

// Trailing hyphen
data-value- → dataset['value-'] // [Inference] Preserved in property name

// Starting with hyphen (invalid in HTML5)
data--value → Invalid attribute name
```

#### Character Restrictions

HTML5 specifies that data attribute names:

- Must start with `data-`
- Must contain at least one character after `data-`
- Must not contain uppercase ASCII letters (A-Z)
- Can contain hyphens, but special handling required

```javascript
// Valid
<div data-user="john"></div>
<div data-user-id="123"></div>
<div data-123="value"></div>
<div data-_value="test"></div>

// Invalid (uppercase after data-)
<div data-UserId="123"></div> // Fails HTML5 validation

// Edge case: XML compatibility
<div data-xml:lang="en"></div> // Contains colon, technically valid in HTML5
```

### Property Access Patterns

#### Dot Notation

```javascript
const el = document.querySelector('.item');

// Reading
const id = el.dataset.userId;

// Writing
el.dataset.userId = '456';

// Deleting
delete el.dataset.userId; // Removes data-user-id attribute
```

#### Bracket Notation

Required for:

- Names starting with digits
- Names containing special characters
- Dynamic property names
- Reserved JavaScript keywords

```javascript
// Digit start
el.dataset['3dModel'] = 'mesh.obj';

// Dynamic access
const key = 'userId';
el.dataset[key] = '789';

// Special characters preserved
el.dataset['my-special-key'] = 'value'; // data-my-special-key

// Reserved words
el.dataset['class'] = 'test'; // data-class
```

### Value Type Handling

#### String Conversion

All dataset values are strings. Type conversion must be explicit:

```javascript
// Setting values - all converted to strings
el.dataset.count = 42; // Becomes "42"
el.dataset.active = true; // Becomes "true"
el.dataset.items = [1, 2, 3]; // Becomes "1,2,3"
el.dataset.obj = {a: 1}; // Becomes "[object Object]"

// Reading requires conversion
const count = parseInt(el.dataset.count, 10); // 42
const active = el.dataset.active === 'true'; // true
const items = el.dataset.items.split(',').map(Number); // [1, 2, 3]
```

#### JSON Storage Pattern

```javascript
// Storing complex data
const data = {
  id: 123,
  name: 'Product',
  tags: ['new', 'sale'],
  metadata: { category: 'electronics' }
};

el.dataset.config = JSON.stringify(data);

// Retrieving complex data
const config = JSON.parse(el.dataset.config);
```

#### Empty and Undefined Values

```javascript
// Empty string
el.dataset.value = ''; // data-value=""
el.dataset.value === ''; // true

// Undefined - property doesn't exist
el.dataset.nonexistent === undefined; // true

// Null converted to string
el.dataset.value = null; // Becomes "null"
el.dataset.value === 'null'; // true

// Checking existence
'userId' in el.dataset; // true if data-user-id exists
el.hasAttribute('data-user-id'); // Alternative check
```

### Enumeration and Iteration

#### Iterating Over Dataset

```javascript
const el = document.querySelector('.item');

// for...in loop
for (let key in el.dataset) {
  console.log(key, el.dataset[key]);
}

// Object.keys
Object.keys(el.dataset).forEach(key => {
  console.log(key, el.dataset[key]);
});

// Object.entries
Object.entries(el.dataset).forEach(([key, value]) => {
  console.log(key, value);
});

// Object.values
const values = Object.values(el.dataset);
```

#### Inherited Properties Consideration

[Inference] The `dataset` property returns a `DOMStringMap` which doesn't inherit from `Object.prototype`, but `for...in` loops may still enumerate inherited properties in some edge cases. Use `hasOwnProperty` for safety:

```javascript
for (let key in el.dataset) {
  if (el.dataset.hasOwnProperty(key)) {
    console.log(key, el.dataset[key]);
  }
}

// Or use Object.keys (safer)
Object.keys(el.dataset).forEach(key => {
  // Only own properties
});
```

### CSS Integration

#### Attribute Selectors

```javascript
// Select by data attribute existence
document.querySelectorAll('[data-status]');

// Select by exact value
document.querySelectorAll('[data-status="active"]');

// Select by partial value
document.querySelectorAll('[data-id^="user-"]'); // Starts with
document.querySelectorAll('[data-type$="-primary"]'); // Ends with
document.querySelectorAll('[data-tags*="featured"]'); // Contains
```

#### CSS Styling Based on Data Attributes

```css
/* Style based on data attribute */
[data-status="active"] {
  background-color: green;
}

[data-priority="high"] {
  border: 2px solid red;
}

/* Use attribute value in content */
.item::before {
  content: attr(data-label);
}

/* Multiple attribute conditions */
[data-type="product"][data-featured="true"] {
  font-weight: bold;
}
```

#### CSS Custom Properties Integration

```javascript
// Set CSS variable via data attribute
el.dataset.theme = 'dark';

// Read in CSS
// [data-theme="dark"] { --bg-color: #000; }

// Or set custom property directly
el.style.setProperty('--user-color', el.dataset.color);
```

### Performance Characteristics

#### Dataset vs getAttribute

```javascript
// dataset property access
const value1 = el.dataset.userId; // Parses attribute name

// Direct attribute access  
const value2 = el.getAttribute('data-user-id'); // Direct access

// Setting via dataset
el.dataset.userId = '123'; // Converts camelCase, sets attribute

// Setting via setAttribute
el.setAttribute('data-user-id', '123'); // Direct write
```

[Inference] `getAttribute/setAttribute` may be marginally faster for one-off operations as they avoid the camelCase conversion overhead. However, the difference is typically negligible for most applications.

#### Batch Operations

```javascript
// Multiple dataset reads trigger multiple conversions
const a = el.dataset.userId;
const b = el.dataset.userName;
const c = el.dataset.userEmail;

// Cache for repeated access
const data = el.dataset;
const a2 = data.userId;
const b2 = data.userName;
const c2 = data.userEmail;

// For many attributes, consider manual parsing
const attrs = el.attributes;
for (let i = 0; i < attrs.length; i++) {
  if (attrs[i].name.startsWith('data-')) {
    // Process directly
  }
}
```

#### Memory Considerations

[Inference] The `dataset` property creates a live view of data attributes. Changes through `dataset` immediately reflect in the DOM and vice versa. No separate object is maintained in memory.

```javascript
// Live binding
el.setAttribute('data-value', 'test');
console.log(el.dataset.value); // 'test' - immediately reflects

el.dataset.value = 'updated';
console.log(el.getAttribute('data-value')); // 'updated' - immediately reflects
```

### Edge Cases and Browser Quirks

#### Case Sensitivity in HTML vs XHTML

```javascript
// HTML (case-insensitive tags/attributes)
<div data-UserId="123"></div> // Invalid, treated as data-userid

// getAttribute is case-insensitive in HTML
el.getAttribute('data-UserId'); // Returns value
el.getAttribute('data-userid'); // Also returns value

// dataset converts to lowercase
el.dataset.userId; // undefined (attribute is data-userid)
el.dataset.userid; // Returns value
```

#### Special Character Edge Cases

```javascript
// Underscores preserved
el.dataset.user_id; // data-user_id (not converted)

// Numbers in middle preserved
el.dataset.item2name; // data-item2name

// Leading underscore
el.dataset._private; // data-_private

// Multiple consecutive hyphens in HTML
<div data-user--name="test"></div>
el.dataset['user-Name']; // [Unverified] Exact behavior may vary
```

#### Unicode and International Characters

```javascript
// Unicode characters in data attributes (valid HTML5)
<div data-名前="田中"></div>
el.dataset.名前; // Returns "田中"

// Emoji
<div data-icon="🔥"></div>
el.dataset.icon; // Returns "🔥"
```

#### Prototype Pollution Concerns

[Inference] Since dataset properties are accessible via bracket notation, be cautious with user-controlled input:

```javascript
// Potentially dangerous if key comes from user input
const userKey = '__proto__'; // Or 'constructor', 'prototype'
el.dataset[userKey] = 'malicious'; // May not work as expected with DOMStringMap

// Safer: validate keys
const safeSets = ['userId', 'userName', 'userEmail'];
if (safeSets.includes(userKey)) {
  el.dataset[userKey] = value;
}
```

### Common Patterns and Use Cases

#### Component State Management

```javascript
// Store component state
class Accordion {
  constructor(element) {
    this.element = element;
    
    // Initialize from data attributes
    this.isOpen = this.element.dataset.open === 'true';
    this.duration = parseInt(this.element.dataset.duration, 10) || 300;
  }
  
  toggle() {
    this.isOpen = !this.isOpen;
    this.element.dataset.open = this.isOpen; // Persist state
  }
}
```

#### Event Delegation with Data Attributes

```javascript
// HTML: <button data-action="delete" data-id="123">Delete</button>

document.addEventListener('click', (e) => {
  const action = e.target.dataset.action;
  const id = e.target.dataset.id;
  
  if (action === 'delete') {
    deleteItem(id);
  } else if (action === 'edit') {
    editItem(id);
  }
});
```

#### Configuration Storage

```javascript
// HTML: <div class="chart" 
//           data-type="line" 
//           data-width="600" 
//           data-height="400"
//           data-options='{"smooth":true}'>

const chart = document.querySelector('.chart');
const config = {
  type: chart.dataset.type,
  width: parseInt(chart.dataset.width, 10),
  height: parseInt(chart.dataset.height, 10),
  options: JSON.parse(chart.dataset.options || '{}')
};
```

#### Progressive Enhancement

```javascript
// HTML: <form data-ajax="true" data-endpoint="/api/submit">

const form = document.querySelector('form');

if (form.dataset.ajax === 'true') {
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const response = await fetch(form.dataset.endpoint, {
      method: 'POST',
      body: new FormData(form)
    });
    // Handle response
  });
}
// Otherwise, form submits normally
```

#### State Tracking for CSS

```javascript
// Toggle states reflected in CSS
const button = document.querySelector('.toggle');

button.addEventListener('click', () => {
  const currentState = button.dataset.state || 'off';
  const newState = currentState === 'off' ? 'on' : 'off';
  button.dataset.state = newState;
});

// CSS: [data-state="on"] { background: green; }
```

#### Feature Detection Storage

```javascript
// Store feature availability
if ('geolocation' in navigator) {
  document.documentElement.dataset.geolocation = 'true';
}

if (window.matchMedia('(hover: hover)').matches) {
  document.documentElement.dataset.hover = 'true';
}

// CSS can then adapt
// html[data-hover="true"] .tooltip { display: block; }
```

### Security Considerations

#### XSS Prevention

```javascript
// Never directly insert data attributes into HTML strings
const userId = userInput; // Potentially malicious

// Unsafe
element.innerHTML = `<div data-user="${userId}"></div>`;

// Safe: use DOM methods
const div = document.createElement('div');
div.dataset.user = userId; // Automatically escaped
element.appendChild(div);
```

#### Sensitive Data Storage

Data attributes are visible in the DOM and browser DevTools. Avoid storing:

- Authentication tokens
- Personal identification numbers
- Passwords or secrets
- Sensitive user information

```javascript
// Bad: sensitive data exposed
el.dataset.apiKey = 'secret-key-123';
el.dataset.ssn = '123-45-6789';

// Good: use memory-only storage
const privateData = new WeakMap();
privateData.set(el, { apiKey: 'secret-key-123' });
```

#### Content Security Policy Interaction

[Inference] Data attributes themselves don't trigger CSP violations, but their values might be used in ways that do:

```javascript
// If data attribute contains a URL used for fetch
const url = el.dataset.endpoint; // 'https://external-api.com'
fetch(url); // May violate CSP if external domain not allowed
```

### Alternatives and Comparisons

#### WeakMap for Private Data

```javascript
// Dataset: public, visible in DOM
el.dataset.counter = '0';

// WeakMap: private, memory-only
const privateData = new WeakMap();
privateData.set(el, { counter: 0 });

// Automatic garbage collection when element removed
```

#### JavaScript Object Storage

```javascript
// For elements you control by reference
const elementData = {
  counter: 0,
  callbacks: [],
  config: {}
};

// Access via reference, no DOM pollution
// But: lost when page reloads, not serializable
```

#### classList for Boolean States

```javascript
// Simple boolean states better as classes
// Instead of:
el.dataset.active = 'true';
if (el.dataset.active === 'true') { }

// Use:
el.classList.add('active');
if (el.classList.contains('active')) { }
```

#### Form Hidden Inputs

```javascript
// For form-related data that needs to be submitted
// Instead of: <form><div data-user-id="123"></div>...

// Use: <form><input type="hidden" name="userId" value="123">...
// Automatically included in form submission
```

### Serialization and Cloning

#### Element Cloning

```javascript
const original = document.querySelector('.item');
original.dataset.userId = '123';

// Deep clone includes data attributes
const clone = original.cloneNode(true);
console.log(clone.dataset.userId); // '123'

// Shallow clone of element (no children)
const shallowClone = original.cloneNode(false);
console.log(shallowClone.dataset.userId); // '123'
```

#### Serialization to Object

```javascript
// Extract all data attributes to plain object
function serializeDataset(element) {
  return Object.keys(element.dataset).reduce((obj, key) => {
    obj[key] = element.dataset[key];
    return obj;
  }, {});
}

const data = serializeDataset(el);
// { userId: '123', userName: 'John', userEmail: 'john@example.com' }
```

#### Hydration from Object

```javascript
// Apply object properties to dataset
function hydrateDataset(element, data) {
  Object.keys(data).forEach(key => {
    element.dataset[key] = data[key];
  });
}

hydrateDataset(el, { userId: '456', status: 'active' });
```

### Framework Integration Patterns

#### React

```javascript
// JSX automatically handles data attributes
<div data-user-id={userId} data-status="active">

// Accessing in refs
const ref = useRef();
useEffect(() => {
  console.log(ref.current.dataset.userId);
}, []);

return <div ref={ref} data-user-id={userId} />;
```

#### Vue

```javascript
// Template binding
<template>
  <div :data-user-id="userId" :data-status="status">
</template>

// Accessing in mounted hook
mounted() {
  console.log(this.$el.dataset.userId);
}
```

#### Vanilla JS Component Pattern

```javascript
class Component {
  constructor(element) {
    this.element = element;
    this.config = this.loadConfig();
  }
  
  loadConfig() {
    // Load all data-config-* attributes
    const config = {};
    Object.keys(this.element.dataset).forEach(key => {
      if (key.startsWith('config')) {
        const configKey = key.replace('config', '');
        const normalizedKey = configKey.charAt(0).toLowerCase() + configKey.slice(1);
        config[normalizedKey] = this.element.dataset[key];
      }
    });
    return config;
  }
  
  updateState(key, value) {
    this.element.dataset[`state${key.charAt(0).toUpperCase()}${key.slice(1)}`] = value;
  }
}
```

---

