## CSS Class Manipulation Techniques


CSS class manipulation provides methods for dynamically adding, removing, and toggling classes on DOM elements, enabling responsive styling and state management without directly modifying inline styles.

### className Property

The `className` property gets or sets the entire `class` attribute value as a string.

```javascript
const element = document.getElementById('box');

// Get all classes
console.log(element.className); // "btn btn-primary active"

// Set classes (replaces all existing classes)
element.className = "btn btn-secondary";

// Add a class
element.className += " disabled";

// Clear all classes
element.className = "";
```

#### Characteristics

**String-Based**: Returns and accepts a space-separated string of class names. Multiple classes are separated by spaces.

**Complete Replacement**: Setting `className` replaces all existing classes, not just individual ones:

```javascript
element.className = "original-class";
element.className = "new-class"; // "original-class" is removed
```

**Whitespace Handling**: Extra whitespace is preserved but can cause issues:

```javascript
element.className = "btn  active"; // Double space preserved
console.log(element.classList.contains("active")); // true
console.log(element.classList.contains("")); // true (empty string class)
```

#### Parsing and Manipulation

Working with multiple classes requires string manipulation:

```javascript
// Check if class exists
const hasClass = element.className.split(' ').includes('active');

// Add class if not present
if (!element.className.split(' ').includes('new-class')) {
  element.className += ' new-class';
}

// Remove specific class
element.className = element.className
  .split(' ')
  .filter(cls => cls !== 'remove-me')
  .join(' ');

// Toggle class
const classes = element.className.split(' ');
const index = classes.indexOf('toggle-me');
if (index > -1) {
  classes.splice(index, 1);
} else {
  classes.push('toggle-me');
}
element.className = classes.join(' ');
```

#### Performance Considerations

Each assignment to `className` can trigger style recalculation and reflow:

```javascript
// Inefficient - multiple reflows
element.className = "class1";
element.className += " class2";
element.className += " class3";

// Efficient - single reflow
element.className = "class1 class2 class3";
```

#### SVG Elements

For SVG elements, use `className.baseVal` instead:

```javascript
const svgElement = document.querySelector('svg rect');

// Get classes
console.log(svgElement.className.baseVal);

// Set classes
svgElement.className.baseVal = "rect-class active";
```

### classList Property

The `classList` property returns a DOMTokenList object that represents the element's class attribute as a collection of tokens. It provides methods for manipulating individual classes without string parsing.

```javascript
const element = document.getElementById('box');
const classes = element.classList;

console.log(classes); // DOMTokenList ["btn", "btn-primary", "active"]
console.log(classes.length); // 3
```

#### DOMTokenList Characteristics

**Live Collection**: Automatically updates when classes change:

```javascript
const list = element.classList;
console.log(list.length); // 2

element.className += " new-class";
console.log(list.length); // 3 (automatically updated)
```

**Array-Like**: Supports numeric indexing and length property, but not array methods directly:

```javascript
console.log(element.classList[0]); // First class name
console.log(element.classList.length); // Number of classes

// Convert to array for array methods
const classArray = Array.from(element.classList);
const filtered = classArray.filter(cls => cls.startsWith('btn-'));
```

**Iterable**: Supports `for...of` and `forEach`:

```javascript
for (let className of element.classList) {
  console.log(className);
}

element.classList.forEach(className => {
  console.log(className);
});
```

### classList.add()

Adds one or more classes to the element. Ignores classes that already exist.

```javascript
element.classList.add('active');
element.classList.add('highlight', 'focus', 'new-class'); // Multiple classes
```

#### Behavior

**Duplicate Prevention**: Adding an existing class has no effect:

```javascript
element.className = "btn";
element.classList.add('btn'); // No change
console.log(element.className); // Still "btn" (not "btn btn")
```

**Multiple Arguments**: Accepts multiple class names in a single call:

```javascript
// Efficient
element.classList.add('class1', 'class2', 'class3');

// Less efficient
element.classList.add('class1');
element.classList.add('class2');
element.classList.add('class3');
```

**Invalid Class Names**: [Inference: Throws DOMException for invalid class names]

```javascript
// Invalid - contains whitespace
element.classList.add('class with spaces'); // Throws DOMException

// Invalid - empty string
element.classList.add(''); // Throws DOMException
```

#### Common Patterns

```javascript
// Conditional addition
if (condition) {
  element.classList.add('active');
}

// Add state class
function setLoadingState(element, isLoading) {
  if (isLoading) {
    element.classList.add('loading', 'disabled');
  }
}

// Add multiple related classes
element.classList.add('btn', 'btn-primary', 'btn-lg');
```

### classList.remove()

Removes one or more classes from the element. Ignores classes that don't exist.

```javascript
element.classList.remove('active');
element.classList.remove('highlight', 'focus', 'disabled'); // Multiple classes
```

#### Behavior

**Non-Existent Classes**: Removing a class that doesn't exist has no effect and throws no error:

```javascript
element.className = "btn";
element.classList.remove('active'); // No error, no change
```

**Multiple Arguments**: Removes multiple classes in one call:

```javascript
element.classList.remove('class1', 'class2', 'class3');
```

**Invalid Class Names**: [Inference: Throws DOMException for invalid class names]

```javascript
element.classList.remove(''); // Throws DOMException
```

#### Common Patterns

```javascript
// Conditional removal
if (!isActive) {
  element.classList.remove('active');
}

// Remove state classes
function clearStates(element) {
  element.classList.remove('loading', 'error', 'success');
}

// Reset to base classes
element.classList.remove('btn-primary', 'btn-secondary', 'btn-danger');
element.classList.add('btn-default');
```

### classList.toggle()

Toggles a class on the element - adds it if absent, removes it if present. Returns `true` if the class was added, `false` if removed.

```javascript
const wasAdded = element.classList.toggle('active');
console.log(wasAdded); // true if 'active' was added, false if removed
```

#### Force Parameter

The optional second parameter forces adding or removing:

```javascript
// Force add (same as add() but returns boolean)
element.classList.toggle('active', true); // Always adds, never removes

// Force remove (same as remove() but returns boolean)
element.classList.toggle('active', false); // Always removes, never adds

// Conditional toggle based on expression
element.classList.toggle('visible', width > 768);
element.classList.toggle('hidden', width <= 768);
```

#### Return Value Usage

```javascript
// Use return value to track state
const isActive = element.classList.toggle('active');
if (isActive) {
  console.log('Element is now active');
} else {
  console.log('Element is now inactive');
}

// Chain operations based on result
if (element.classList.toggle('expanded')) {
  expandContent();
} else {
  collapseContent();
}
```

#### Common Patterns

```javascript
// Toggle visibility
button.addEventListener('click', () => {
  menu.classList.toggle('visible');
});

// Toggle between states
function toggleTheme(element) {
  const isDark = element.classList.toggle('dark-theme');
  element.classList.toggle('light-theme', !isDark);
}

// Accordion behavior
function toggleAccordion(panel) {
  const isOpen = panel.classList.toggle('open');
  panel.style.maxHeight = isOpen ? panel.scrollHeight + 'px' : '0';
}

// Conditional toggle with force parameter
element.classList.toggle('disabled', !hasPermission);
element.classList.toggle('read-only', isViewMode);
```

### classList.contains()

Returns `true` if the element has the specified class, `false` otherwise.

```javascript
if (element.classList.contains('active')) {
  console.log('Element is active');
}
```

#### Case Sensitivity

Class names are case-sensitive in HTML (though in CSS selectors they may not be in certain contexts):

```javascript
element.className = "Active";
console.log(element.classList.contains('active')); // false
console.log(element.classList.contains('Active')); // true
```

#### Common Patterns

```javascript
// Conditional logic
if (element.classList.contains('disabled')) {
  return; // Don't process click
}

// State checking
function isVisible(element) {
  return !element.classList.contains('hidden');
}

// Multiple class checking
function hasAnyClass(element, classNames) {
  return classNames.some(cls => element.classList.contains(cls));
}

function hasAllClasses(element, classNames) {
  return classNames.every(cls => element.classList.contains(cls));
}

// Validation
if (!element.classList.contains('initialized')) {
  initialize(element);
  element.classList.add('initialized');
}
```

### classList.replace()

Replaces an existing class with a new class. Returns `true` if replacement occurred, `false` if the old class wasn't present.

```javascript
const wasReplaced = element.classList.replace('btn-primary', 'btn-secondary');
console.log(wasReplaced); // true if 'btn-primary' existed and was replaced
```

#### Behavior

**Atomic Operation**: Replaces in a single operation without intermediate state:

```javascript
// Using replace - atomic
element.classList.replace('old-class', 'new-class');

// Manual approach - two operations
element.classList.remove('old-class');
element.classList.add('new-class');
```

**Non-Existent Old Class**: Returns `false` if the old class doesn't exist; new class is not added:

```javascript
element.className = "other-class";
const replaced = element.classList.replace('not-there', 'new-class');
console.log(replaced); // false
console.log(element.className); // "other-class" (unchanged)
```

**Duplicate New Class**: If the new class already exists, the old class is still removed:

```javascript
element.className = "old-class new-class";
element.classList.replace('old-class', 'new-class');
console.log(element.className); // "new-class" (no duplicate)
```

#### Browser Support

Supported in modern browsers. For older browsers, fallback pattern:

```javascript
if (!element.classList.replace) {
  // Polyfill
  DOMTokenList.prototype.replace = function(oldClass, newClass) {
    if (this.contains(oldClass)) {
      this.remove(oldClass);
      this.add(newClass);
      return true;
    }
    return false;
  };
}
```

#### Common Patterns

```javascript
// Theme switching
element.classList.replace('theme-light', 'theme-dark');

// State transitions
button.classList.replace('btn-primary', 'btn-success');

// Size changes
element.classList.replace('size-sm', 'size-lg');

// Conditional replacement
function updateState(element, oldState, newState) {
  if (element.classList.replace(`state-${oldState}`, `state-${newState}`)) {
    console.log(`State changed from ${oldState} to ${newState}`);
  }
}
```

### classList.item()

Returns the class name at the specified index, or `null` if the index is out of range.

```javascript
element.className = "btn btn-primary active";
console.log(element.classList.item(0)); // "btn"
console.log(element.classList.item(1)); // "btn-primary"
console.log(element.classList.item(5)); // null
```

#### Array-Like Access

Bracket notation is more common and equivalent:

```javascript
console.log(element.classList[0]); // Same as item(0)
console.log(element.classList[1]); // Same as item(1)
```

#### Iteration Pattern

```javascript
// Using item()
for (let i = 0; i < element.classList.length; i++) {
  console.log(element.classList.item(i));
}

// Using bracket notation (more common)
for (let i = 0; i < element.classList.length; i++) {
  console.log(element.classList[i]);
}

// Modern iteration (preferred)
element.classList.forEach(className => {
  console.log(className);
});
```

### Advanced Manipulation Patterns

#### Batch Class Operations

```javascript
// Add multiple classes efficiently
function addClasses(element, ...classes) {
  element.classList.add(...classes);
}

// Remove multiple classes
function removeClasses(element, ...classes) {
  element.classList.remove(...classes);
}

// Replace multiple classes
function replaceClasses(element, oldClasses, newClasses) {
  removeClasses(element, ...oldClasses);
  addClasses(element, ...newClasses);
}

// Usage
addClasses(element, 'class1', 'class2', 'class3');
replaceClasses(element, ['old1', 'old2'], ['new1', 'new2']);
```

#### Conditional Class Application

```javascript
// Apply classes based on conditions
function applyConditionalClasses(element, classMap) {
  Object.entries(classMap).forEach(([className, condition]) => {
    element.classList.toggle(className, condition);
  });
}

// Usage
applyConditionalClasses(element, {
  'active': isActive,
  'disabled': !hasPermission,
  'large': size === 'lg',
  'hidden': !isVisible
});
```

#### State Management with Classes

```javascript
// Exclusive state classes (only one active)
function setExclusiveClass(element, stateClass, allStateClasses) {
  allStateClasses.forEach(cls => element.classList.remove(cls));
  element.classList.add(stateClass);
}

// Usage
const states = ['idle', 'loading', 'success', 'error'];
setExclusiveClass(button, 'loading', states);

// Grouped class management
function setButtonVariant(button, variant) {
  const variants = ['primary', 'secondary', 'success', 'danger', 'warning'];
  variants.forEach(v => button.classList.remove(`btn-${v}`));
  button.classList.add(`btn-${variant}`);
}
```

#### Dynamic Class Generation

```javascript
// BEM-style class generation
function bemClass(block, element = null, modifier = null) {
  let className = block;
  if (element) className += `__${element}`;
  if (modifier) className += `--${modifier}`;
  return className;
}

// Usage
const cardClass = bemClass('card'); // "card"
const cardTitleClass = bemClass('card', 'title'); // "card__title"
const cardActiveClass = bemClass('card', null, 'active'); // "card--active"

// Apply to element
element.classList.add(bemClass('button', null, 'primary'));
```

#### Prefix-Based Class Management

```javascript
// Remove all classes with specific prefix
function removeClassesWithPrefix(element, prefix) {
  const classesToRemove = Array.from(element.classList)
    .filter(cls => cls.startsWith(prefix));
  element.classList.remove(...classesToRemove);
}

// Add class and remove others with same prefix
function setClassWithPrefix(element, prefix, className) {
  removeClassesWithPrefix(element, prefix);
  element.classList.add(className);
}

// Usage
setClassWithPrefix(element, 'size-', 'size-large');
setClassWithPrefix(element, 'theme-', 'theme-dark');
```

#### Animation Classes

```javascript
// Add temporary animation class
function animateElement(element, animationClass, duration = 300) {
  element.classList.add(animationClass);
  
  return new Promise(resolve => {
    setTimeout(() => {
      element.classList.remove(animationClass);
      resolve();
    }, duration);
  });
}

// Usage
await animateElement(element, 'fade-in', 500);
console.log('Animation complete');

// Chain animations
async function chainAnimations(element, animations) {
  for (const anim of animations) {
    await animateElement(element, anim.class, anim.duration);
  }
}
```

#### Class Observation

```javascript
// Monitor class changes
function watchClasses(element, callback) {
  const observer = new MutationObserver(mutations => {
    mutations.forEach(mutation => {
      if (mutation.attributeName === 'class') {
        callback(element.className, mutation.oldValue);
      }
    });
  });
  
  observer.observe(element, {
    attributes: true,
    attributeOldValue: true,
    attributeFilter: ['class']
  });
  
  return observer;
}

// Usage
const observer = watchClasses(element, (newClasses, oldClasses) => {
  console.log('Classes changed from:', oldClasses, 'to:', newClasses);
});

// Stop watching
observer.disconnect();
```

### Performance Optimization

#### Minimize Reflows

```javascript
// Inefficient - multiple reflows
element.classList.add('class1');
element.style.display = 'block';
element.classList.add('class2');
element.style.opacity = '1';

// Efficient - batch class changes
element.classList.add('class1', 'class2');
// Single style change or use classes for styling
element.classList.add('visible'); // CSS: .visible { display: block; opacity: 1; }
```

#### Use Classes Over Inline Styles

```javascript
// Less efficient - inline styles
element.style.color = 'red';
element.style.fontSize = '16px';
element.style.fontWeight = 'bold';

// More efficient - class-based styling
element.classList.add('error-text');
// CSS: .error-text { color: red; font-size: 16px; font-weight: bold; }
```

#### Cache classList Reference

```javascript
// Less efficient - repeated property access
for (let i = 0; i < 1000; i++) {
  elements[i].classList.add('processed');
}

// More efficient - cache when doing multiple operations
for (let i = 0; i < 1000; i++) {
  const classList = elements[i].classList;
  classList.add('processed');
  classList.remove('pending');
}
```

#### Batch DOM Queries

```javascript
// Inefficient - query DOM repeatedly
document.querySelectorAll('.item').forEach(item => {
  item.classList.add('processed');
});
document.querySelectorAll('.item').forEach(item => {
  item.classList.remove('pending');
});

// Efficient - single query, multiple operations
document.querySelectorAll('.item').forEach(item => {
  item.classList.add('processed');
  item.classList.remove('pending');
});
```

### Cross-Browser Compatibility

#### classList Polyfill for Legacy Browsers

[Unverified: Modern browsers all support classList]

For IE9 and below, a polyfill may be needed:

```javascript
if (!('classList' in document.documentElement)) {
  Object.defineProperty(Element.prototype, 'classList', {
    get: function() {
      const element = this;
      const classCache = element.className.split(/\s+/);
      
      return {
        contains: cls => classCache.indexOf(cls) > -1,
        add: cls => {
          if (!this.contains(cls)) {
            element.className += ' ' + cls;
          }
        },
        remove: cls => {
          element.className = element.className
            .split(/\s+/)
            .filter(c => c !== cls)
            .join(' ');
        },
        toggle: cls => {
          if (this.contains(cls)) {
            this.remove(cls);
            return false;
          } else {
            this.add(cls);
            return true;
          }
        }
      };
    }
  });
}
```

#### SVG Element Handling

SVG elements in older browsers require special handling:

```javascript
function addClassSVG(element, className) {
  if (element.classList) {
    element.classList.add(className);
  } else if (element.className.baseVal !== undefined) {
    // SVG element
    const classes = element.className.baseVal.split(' ');
    if (classes.indexOf(className) === -1) {
      element.className.baseVal += ' ' + className;
    }
  } else {
    // Fallback
    element.className += ' ' + className;
  }
}
```

### Testing and Debugging

#### Inspecting Classes

```javascript
// Log all classes
console.log('Classes:', Array.from(element.classList));

// Check specific class
console.log('Has "active"?', element.classList.contains('active'));

// Count classes
console.log('Number of classes:', element.classList.length);

// List classes with details
element.classList.forEach((cls, index) => {
  console.log(`[${index}]:`, cls);
});
```

#### Validation

```javascript
// Validate class name before adding
function isValidClassName(className) {
  // Class names cannot contain whitespace
  return typeof className === 'string' && 
         className.length > 0 && 
         !/\s/.test(className);
}

function safeAddClass(element, className) {
  if (isValidClassName(className)) {
    element.classList.add(className);
  } else {
    console.error('Invalid class name:', className);
  }
}
```

#### Class Diffing

```javascript
// Compare class lists
function getClassDiff(element, expectedClasses) {
  const actual = new Set(element.classList);
  const expected = new Set(expectedClasses);
  
  const missing = [...expected].filter(cls => !actual.has(cls));
  const extra = [...actual].filter(cls => !expected.has(cls));
  
  return { missing, extra };
}

// Usage
const diff = getClassDiff(element, ['btn', 'btn-primary', 'active']);
if (diff.missing.length) console.log('Missing:', diff.missing);
if (diff.extra.length) console.log('Extra:', diff.extra);
```

### Common Pitfalls

#### Whitespace in Class Names

```javascript
// Wrong - throws DOMException
element.classList.add('class with spaces');

// Correct - separate classes
element.classList.add('class', 'with', 'spaces');
```

#### Modifying During Iteration

```javascript
// Dangerous - modifying collection during iteration
element.classList.forEach(cls => {
  if (cls.startsWith('old-')) {
    element.classList.remove(cls); // Modifies collection being iterated
  }
});

// Safe - convert to array first
Array.from(element.classList)
  .filter(cls => cls.startsWith('old-'))
  .forEach(cls => element.classList.remove(cls));
```

#### Assuming className is Always a String

```javascript
// SVG elements have className as object
if (typeof element.className === 'string') {
  // HTML element
  element.className += ' new-class';
} else {
  // SVG element
  element.className.baseVal += ' new-class';
}

// Better - use classList (works for both)
element.classList.add('new-class');
```

#### Toggle Without Force Parameter

```javascript
// Ambiguous - relies on current state
element.classList.toggle('visible');

// Clear intent - explicit behavior
element.classList.toggle('visible', shouldBeVisible);
```

---

