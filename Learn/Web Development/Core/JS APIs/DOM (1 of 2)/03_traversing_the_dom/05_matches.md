## matches


### Method Signature

```javascript
element.matches(selectors)
```

Returns a boolean indicating whether the element would be selected by the specified CSS selector string. Tests the element against the selector without modifying the DOM or returning any elements.

### Parameters

**selectors** (string, required): A valid CSS selector string to test against the element. Can include any valid CSS selector syntax including combinators, pseudo-classes, and attribute selectors.

### Return Value

- Returns `true` if the element matches the selector
- Returns `false` if the element does not match the selector
- Throws `SyntaxError` DOMException if the selector string is invalid

### Behavior Characteristics

#### Selector Evaluation Context

The method evaluates the selector as if it were being used in a stylesheet or `querySelector` call. The element is tested in isolation - the selector is evaluated against the element itself, not its position in the DOM tree.

#### Complex Selector Support

All CSS selector types are supported:

```javascript
// Type selectors
element.matches('div');

// Class selectors
element.matches('.active');

// ID selectors
element.matches('#header');

// Attribute selectors
element.matches('[data-id="123"]');
element.matches('[href^="https"]');

// Pseudo-classes
element.matches(':hover');
element.matches(':nth-child(2)');
element.matches(':not(.disabled)');

// Combined selectors
element.matches('div.container[data-active="true"]');
```

#### Contextual Pseudo-Classes

Some pseudo-classes depend on element position or state within the DOM:

```javascript
element.matches(':first-child');  // Evaluates based on actual position
element.matches(':last-of-type'); // Evaluates based on siblings
element.matches(':empty');        // Evaluates current content state
```

### Common Patterns

#### Event Delegation Filtering

```javascript
document.addEventListener('click', (event) => {
  if (event.target.matches('.button')) {
    handleButtonClick(event);
  }
});
```

#### Conditional Styling Logic

```javascript
const item = document.querySelector('.item');
if (item.matches('.active:not(.disabled)')) {
  // Apply specific behavior
}
```

#### Element Classification

```javascript
function isInteractive(element) {
  return element.matches('button, a, input, select, textarea, [tabindex]');
}
```

#### Traversal Filtering

```javascript
const parent = element.closest('.container');
if (parent && parent.matches('.special')) {
  // Parent has special class
}
```

### Selector Specificity and Multiple Conditions

#### Comma-Separated Selectors

```javascript
// Matches if ANY selector matches
element.matches('.active, .selected, .highlighted');
```

#### Descendant and Child Combinators

```javascript
// These test the element itself, not descendants
element.matches('div > .child');     // False unless element IS .child with div parent
element.matches('.parent .child');   // False unless element IS .child with .parent ancestor

// Context matters for these selectors
```

### Edge Cases and Gotchas

#### Pseudo-Elements Not Supported

```javascript
// Throws or returns false depending on browser
element.matches('::before');  // Not valid - pseudo-elements aren't elements
element.matches('::after');
```

#### Dynamic State Pseudo-Classes

```javascript
// These reflect current state
element.matches(':hover');    // True only if currently hovered
element.matches(':focus');    // True only if currently focused
element.matches(':checked');  // True only if currently checked
```

#### Invalid Selectors

```javascript
try {
  element.matches('div..invalid');
} catch (e) {
  // SyntaxError: Failed to execute 'matches'
}
```

#### Case Sensitivity

```javascript
// HTML elements and attributes in HTML documents are case-insensitive
element.matches('DIV');           // Same as 'div'
element.matches('[CLASS="test"]'); // Same as '[class="test"]'

// Custom attributes and values are case-sensitive
element.matches('[data-id="ABC"]'); // Different from '[data-id="abc"]'
```

### Performance Characteristics

#### Optimization Profile

`matches()` is highly optimized in modern browsers. The performance is generally O(1) to O(n) depending on selector complexity:

- Simple selectors (tag, class, ID): Very fast, O(1)
- Attribute selectors: Fast, O(1)
- Pseudo-classes requiring tree traversal (:nth-child, :first-child): O(n) where n is sibling count
- Complex combined selectors: Depends on component complexity

#### Comparison with Alternative Approaches

```javascript
// Using matches
if (element.matches('.active')) { }

// Alternative: classList
if (element.classList.contains('active')) { }  // Faster for single class

// Alternative: direct property check
if (element.className.includes('active')) { }  // Fragile, not recommended
```

For single class checks, `classList.contains()` is faster. For complex selectors, `matches()` is the only practical option.

### Browser Compatibility and Prefixes

#### Historical Prefixes

Older browsers required vendor prefixes:

```javascript
function matchesSelector(element, selector) {
  if (element.matches) {
    return element.matches(selector);
  } else if (element.matchesSelector) {
    return element.matchesSelector(selector);
  } else if (element.webkitMatchesSelector) {
    return element.webkitMatchesSelector(selector);
  } else if (element.mozMatchesSelector) {
    return element.mozMatchesSelector(selector);
  } else if (element.msMatchesSelector) {
    return element.msMatchesSelector(selector);
  }
  return false;
}
```

Modern browsers (IE9+ with prefixes, all current browsers unprefixed) support the standard `matches()` method.

### Integration Patterns

#### Event Delegation with Complex Selectors

```javascript
document.addEventListener('click', (event) => {
  const target = event.target;
  
  if (target.matches('button.submit:not(:disabled)')) {
    handleSubmit();
  } else if (target.matches('a[href^="#"]')) {
    handleHashLink(event);
  } else if (target.matches('.dropdown-item[data-value]')) {
    handleDropdownSelection(target);
  }
});
```

#### Component Boundary Detection

```javascript
function findComponentBoundary(element) {
  let current = element;
  while (current && !current.matches('[data-component]')) {
    current = current.parentElement;
  }
  return current;
}
```

#### Form Validation

```javascript
const input = document.querySelector('input');

if (input.matches(':invalid')) {
  // Show validation error
}

if (input.matches(':required:empty')) {
  // Required field is empty
}
```

### Combination with Other DOM Methods

#### With closest()

```javascript
// Find if element or ancestor matches
const container = element.closest('.container');
if (container && container.matches('.special')) {
  // Combined ancestor search and validation
}
```

#### With querySelectorAll() Filtering

```javascript
const elements = document.querySelectorAll('.item');
const filtered = Array.from(elements).filter(el => 
  el.matches(':not(.disabled)[data-visible="true"]')
);
```

#### With Event Target Matching

```javascript
element.addEventListener('click', (event) => {
  // Walk up from target to currentTarget
  let target = event.target;
  while (target !== event.currentTarget) {
    if (target.matches('.clickable-child')) {
      handleClick(target);
      break;
    }
    target = target.parentElement;
  }
});
```

### Security Considerations

#### Selector Injection

Never use unsanitized user input in selectors:

```javascript
// Vulnerable
const userClass = getUserInput();
if (element.matches(`.${userClass}`)) { }

// [Inference] An attacker could inject complex selectors or cause errors
```

#### Sanitization Approach

```javascript
function safeClassMatch(element, className) {
  // Validate className is alphanumeric
  if (!/^[a-zA-Z0-9_-]+$/.test(className)) {
    throw new Error('Invalid class name');
  }
  return element.matches(`.${className}`);
}
```

### Advanced Use Cases

#### Custom Element Detection

```javascript
function isCustomElement(element) {
  return element.matches(':not(:defined)') || 
         element.matches('[is]') ||
         element.tagName.includes('-');
}
```

#### State Machine Validation

```javascript
class StateMachine {
  canTransition(element, toState) {
    const transitions = {
      'idle': '.idle',
      'loading': '.idle:not(.error)',
      'success': '.loading',
      'error': '.loading'
    };
    
    return element.matches(transitions[toState]);
  }
}
```

#### Accessibility Checks

```javascript
function isFocusable(element) {
  return element.matches(
    'a[href], button:not([disabled]), input:not([disabled]), ' +
    'select:not([disabled]), textarea:not([disabled]), ' +
    '[tabindex]:not([tabindex="-1"])'
  );
}
```

### Polyfill Pattern

For environments without `matches()` support:

```javascript
if (!Element.prototype.matches) {
  Element.prototype.matches = 
    Element.prototype.matchesSelector ||
    Element.prototype.webkitMatchesSelector ||
    Element.prototype.mozMatchesSelector ||
    Element.prototype.msMatchesSelector ||
    function(selector) {
      const matches = (this.document || this.ownerDocument).querySelectorAll(selector);
      let i = matches.length;
      while (--i >= 0 && matches.item(i) !== this) {}
      return i > -1;
    };
}
```

### Testing and Debugging

#### Validation Testing

```javascript
// Test selector validity
function isValidSelector(selector) {
  try {
    document.createElement('div').matches(selector);
    return true;
  } catch (e) {
    return false;
  }
}
```

#### Debug Logging

```javascript
function debugMatches(element, selector) {
  const result = element.matches(selector);
  console.log(`Element matches "${selector}":`, result);
  console.log('Element:', element);
  console.log('Classes:', element.className);
  console.log('Attributes:', [...element.attributes].map(a => `${a.name}="${a.value}"`));
  return result;
}
```

---

