## querySelector


### Syntax and Return Value

`querySelector()` returns the first Element within the document that matches the specified CSS selector or group of selectors. Returns `null` if no matches are found. The method performs a depth-first pre-order traversal of the document's nodes.

```javascript
element = document.querySelector(selectors);
element = parentElement.querySelector(selectors);
```

The `selectors` parameter is a DOMString containing one or more CSS selectors separated by commas. If the selector string contains invalid CSS syntax, a `SyntaxError` DOMException is thrown.

### Selector Specificity and Matching Behavior

The method matches against the full selector string, not individual components. This means complex selectors with combinators, pseudo-classes, and attribute selectors work as expected:

```javascript
// Matches first paragraph inside any div with class "content"
document.querySelector('div.content > p');

// Matches first checked checkbox
document.querySelector('input[type="checkbox"]:checked');

// Matches first element with data attribute
document.querySelector('[data-id="123"]');
```

When multiple selectors are provided (comma-separated), `querySelector` returns the first element in document order that matches _any_ of the selectors, not necessarily the first selector in the list:

```javascript
// Returns whichever comes first in DOM order
document.querySelector('.primary, .secondary, #special');
```

### Scope and Context

Unlike `querySelectorAll`, which can be called on any Element, `querySelector` is available on:

- `Document` objects (`document.querySelector`)
- `Element` objects (scopes search to descendants)
- `DocumentFragment` objects

When called on an element, the search is scoped to that element's descendants only:

```javascript
const container = document.getElementById('container');
// Only searches within #container
const nested = container.querySelector('.nested-item');
```

### Performance Characteristics

`querySelector` stops traversing as soon as the first match is found, making it more efficient than `querySelectorAll` when only one element is needed. However, it's still slower than direct access methods for simple queries:

**Performance hierarchy (fastest to slowest):**

1. `getElementById()` - O(1) hash lookup
2. `getElementsByClassName()`, `getElementsByTagName()` - Optimized internal collections
3. `querySelector()` - Full CSS selector parsing and matching
4. `querySelectorAll()` - Must traverse entire subtree

```javascript
// Fastest for IDs
document.getElementById('myId');

// Slower, but more flexible
document.querySelector('#myId');

// Much slower for simple class lookups
document.querySelector('.myClass');
// Faster alternative
document.getElementsByClassName('myClass')[0];
```

### Complex Selector Patterns

#### Pseudo-classes and Pseudo-elements

Most CSS pseudo-classes work, but pseudo-elements (`:before`, `::after`) cannot be selected as they're not part of the DOM:

```javascript
// Valid pseudo-classes
document.querySelector('input:focus');
document.querySelector('li:nth-child(3)');
document.querySelector('p:not(.excluded)');
document.querySelector('a:hover'); // Only matches if actually hovered

// Pseudo-elements throw errors or return null
document.querySelector('div::before'); // Invalid
```

#### Attribute Selectors

Full CSS attribute selector syntax is supported:

```javascript
// Exact match
document.querySelector('[data-type="user"]');

// Contains word
document.querySelector('[class~="active"]');

// Starts with
document.querySelector('[href^="https://"]');

// Ends with
document.querySelector('[src$=".png"]');

// Contains substring
document.querySelector('[title*="important"]');

// Case-insensitive matching (CSS4)
document.querySelector('[data-value="test" i]');
```

#### Combinators

All CSS combinators function correctly:

```javascript
// Descendant (space)
document.querySelector('article p');

// Child (>)
document.querySelector('ul > li');

// Adjacent sibling (+)
document.querySelector('h2 + p');

// General sibling (~)
document.querySelector('h2 ~ p');
```

### Edge Cases and Gotchas

#### ID Selectors with Special Characters

IDs containing special characters must be escaped:

```javascript
// ID="my:id"
document.querySelector('#my\\:id');

// ID="item.1"
document.querySelector('#item\\.1');

// ID with spaces (invalid HTML but can exist)
document.querySelector('#my\\ id');
```

#### :scope Pseudo-class

The `:scope` pseudo-class represents the reference element (the element on which `querySelector` was called):

```javascript
const div = document.querySelector('#container');

// Matches direct children of #container with class "item"
div.querySelector(':scope > .item');

// Without :scope, would match .item anywhere in descendants
// then filter for direct children - different behavior
```

This is particularly useful for avoiding context issues where selectors might match ancestors:

```javascript
<div class="outer">
  <div class="inner" id="target">
    <span class="item">A</span>
  </div>
</div>

const inner = document.getElementById('target');

// Would match the .outer div if it has .item descendants
inner.querySelector('.outer .item'); // ❌ Unexpected

// Properly scopes to descendants only
inner.querySelector(':scope .item'); // ✓ Correct
```

#### Null Return Handling

Always check for `null` before accessing properties:

```javascript
const element = document.querySelector('.might-not-exist');

// Unsafe - throws TypeError if null
element.classList.add('new-class');

// Safe patterns
element?.classList.add('new-class');

if (element) {
  element.classList.add('new-class');
}

const classes = element?.classList ?? [];
```

#### Dynamic Content and Timing

`querySelector` operates on the current DOM state. Elements added after the query won't be included:

```javascript
document.querySelector('.dynamic'); // null

setTimeout(() => {
  const div = document.createElement('div');
  div.className = 'dynamic';
  document.body.appendChild(div);
  
  document.querySelector('.dynamic'); // now found
}, 100);
```

For dynamic content, consider:

- Re-querying after DOM modifications
- Event delegation instead of direct element queries
- MutationObserver for automatic detection
- Live collections (`getElementsByClassName`) for automatically updating references

### Selector Context Matching Behavior

An often-misunderstood aspect: selectors are evaluated against the entire document, then filtered to descendants:

```javascript
<div id="outer">
  <div id="inner">
    <span>Target</span>
  </div>
</div>

const inner = document.getElementById('inner');

// This WILL work - selector matches in global context,
// then result is filtered to descendants
inner.querySelector('#outer span'); // Returns the span

// The selector "#outer span" is valid globally,
// and span is a descendant of inner
```

To explicitly limit to descendants without ancestor matching, use `:scope`:

```javascript
// Only matches if inner itself matches #outer
inner.querySelector(':scope#outer span'); // null

// Direct descendant matching
inner.querySelector(':scope > span'); // Works
```

### Integration with Modern APIs

#### With Intersection Observer

```javascript
const target = document.querySelector('.lazy-load');
const observer = new IntersectionObserver(entries => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.src = entry.target.dataset.src;
    }
  });
});
observer.observe(target);
```

#### With Mutation Observer

```javascript
const container = document.querySelector('#dynamic-container');
const observer = new MutationObserver(mutations => {
  mutations.forEach(mutation => {
    mutation.addedNodes.forEach(node => {
      if (node.nodeType === 1 && node.matches('.watchable')) {
        // Process new matching element
      }
    });
  });
});
observer.observe(container, { childList: true, subtree: true });
```

#### With Web Components

```javascript
class MyComponent extends HTMLElement {
  connectedCallback() {
    // Query within shadow DOM
    const slot = this.shadowRoot.querySelector('slot');
    const internal = this.shadowRoot.querySelector('.internal');
    
    // Query light DOM (won't find shadow DOM elements)
    const external = this.querySelector('.light-dom-child');
  }
}
```

### Alternative Patterns and When to Use Them

#### querySelector vs getElementById

```javascript
// When you only have an ID - use getElementById
const byId = document.getElementById('unique'); // Faster

// When combining ID with other selectors - use querySelector
const combined = document.querySelector('#unique.active[data-loaded]');
```

#### querySelector vs getElementsBy* Methods

```javascript
// Single element needed
document.querySelector('.item'); // Good

// Multiple elements, no live updates needed
document.querySelectorAll('.items'); // Good

// Need live collection that updates automatically
const liveCollection = document.getElementsByClassName('items');
// liveCollection automatically updates when DOM changes
```

#### Element.matches() for Testing

```javascript
const element = document.querySelector('.item');

// Test if element matches selector
if (element.matches('.item.active')) {
  // More efficient than re-querying
}
```

#### Element.closest() for Ancestor Matching

```javascript
const button = document.querySelector('.submit-btn');

// Find closest ancestor form
const form = button.closest('form');

// More efficient than:
let parent = button.parentElement;
while (parent && parent.tagName !== 'FORM') {
  parent = parent.parentElement;
}
```

### Security Considerations

#### Injection Vulnerabilities

Never construct selectors from untrusted input without sanitization:

```javascript
// DANGEROUS - user input in selector
const userId = getUserInput(); // Could be: "'; alert('XSS'); '"
document.querySelector(`#user-${userId}`); // Vulnerable

// SAFER - validate/sanitize first
const safeId = userId.replace(/[^a-zA-Z0-9-_]/g, '');
document.querySelector(`#user-${safeId}`);

// SAFEST - use data attributes and exact matching
document.querySelector(`[data-user-id="${userId.replace(/"/g, '')}"]`);
```

#### CSS Selector Complexity Attacks

Extremely complex selectors can cause performance degradation:

```javascript
// Potentially problematic - deeply nested
document.querySelector('div '.repeat(100) + 'span');

// Set reasonable limits on selector complexity
// Validate selector strings before use
```

### Cross-browser Considerations

`querySelector` is widely supported (IE8+), but some selector features have varying support:

- `:scope` - No IE support, modern browsers only
- Case-insensitive attribute matching `[attr="val" i]` - CSS4, limited older browser support
- `:has()` - Very recent, check compatibility
- `:is()`, `:where()` - Modern browsers only

```javascript
// Feature detection for advanced selectors
function supportsSelector(selector) {
  try {
    document.querySelector(selector);
    return true;
  } catch (e) {
    return false;
  }
}

if (supportsSelector(':has(.child)')) {
  // Use modern selector
} else {
  // Fallback approach
}
```

### Debugging and Development

#### Common Debugging Patterns

```javascript
// Verify selector matches anything
const result = document.querySelector('.target');
console.assert(result !== null, 'Selector found no matches');

// Test selector in console
$$('.target'); // Chrome DevTools shorthand for querySelectorAll

// Highlight matched element
document.querySelector('.target')?.scrollIntoView({ 
  behavior: 'smooth', 
  block: 'center' 
});
```

#### Performance Profiling

```javascript
console.time('querySelector');
const element = document.querySelector('.complex > .selector');
console.timeEnd('querySelector');

// Compare with alternatives
console.time('getElementById');
const element2 = document.getElementById('simple');
console.timeEnd('getElementById');
```

---

