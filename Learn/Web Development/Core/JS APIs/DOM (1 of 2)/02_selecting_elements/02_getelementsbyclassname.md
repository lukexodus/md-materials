## getElementsByClassName


### Method Signature and Return Value

```javascript
document.getElementsByClassName(classNames)
element.getElementsByClassName(classNames)
```

Returns a live `HTMLCollection` of elements with the specified class name(s). The collection updates automatically when the DOM changes.

### Multiple Class Selection

Pass space-separated class names to match elements containing all specified classes:

```javascript
// Matches elements with both "card" AND "active" classes
const activeCards = document.getElementsByClassName('card active');
```

Order doesn't matter - `'card active'` and `'active card'` produce identical results.

### Live Collection Behavior

The returned `HTMLCollection` reflects real-time DOM state:

```javascript
const items = document.getElementsByClassName('item');
console.log(items.length); // 3

document.querySelector('.item').remove();
console.log(items.length); // 2 - automatically updated
```

**[Inference]** This live behavior can cause issues in loops that modify the DOM:

```javascript
// Problematic - collection shrinks as elements are removed
const items = document.getElementsByClassName('item');
for (let i = 0; i < items.length; i++) {
    items[i].remove(); // Only removes every other element
}

// Solution: Convert to static array
const items = Array.from(document.getElementsByClassName('item'));
for (let item of items) {
    item.remove(); // Works correctly
}
```

### Scope Limitation

Called on an element, it searches only within that element's descendants:

```javascript
const container = document.getElementById('sidebar');
const buttons = container.getElementsByClassName('btn');
// Only finds .btn elements inside #sidebar
```

### HTMLCollection Interface

The returned collection is array-like but not an actual Array:

```javascript
const elements = document.getElementsByClassName('box');

// Available methods/properties:
elements.length          // Number of elements
elements.item(0)         // Get element by index
elements[0]              // Bracket notation also works
elements.namedItem('id') // Get element by id attribute

// NOT available (Array methods):
elements.forEach()  // undefined
elements.map()      // undefined
elements.filter()   // undefined
```

Convert to Array for full array functionality:

```javascript
Array.from(elements).forEach(el => console.log(el));
[...elements].map(el => el.textContent);
```

### Performance Characteristics

**[Inference]** `getElementsByClassName` is generally faster than `querySelectorAll` because it doesn't parse CSS selectors and returns a live collection without creating a snapshot. However, the live collection can have performance implications if the DOM changes frequently during iteration.

```javascript
// Faster for simple class selection
const fast = document.getElementsByClassName('item');

// Slower but more flexible
const flexible = document.querySelectorAll('.item');
```

### Case Sensitivity

Class names are case-sensitive in HTML5:

```javascript
// These are different:
document.getElementsByClassName('MyClass');
document.getElementsByClassName('myclass');
```

### Browser Compatibility

Supported in all modern browsers and IE9+. No polyfill needed for standard web development.

### Common Pitfalls

**Modifying classes during iteration:**

```javascript
const elements = document.getElementsByClassName('old');
// This breaks because collection updates as classes change:
for (let el of elements) {
    el.classList.remove('old');
    el.classList.add('new');
}

// Solution: convert to static array first
const elementsArray = Array.from(document.getElementsByClassName('old'));
for (let el of elementsArray) {
    el.classList.remove('old');
    el.classList.add('new');
}
```

**Assuming Array methods exist:**

```javascript
// Error: getElementsByClassName(...).forEach is not a function
document.getElementsByClassName('item').forEach(el => {
    console.log(el);
});

// Correct:
Array.from(document.getElementsByClassName('item')).forEach(el => {
    console.log(el);
});
```

### Comparison with Alternatives

**vs querySelector/querySelectorAll:**

- `getElementsByClassName` returns live collection; `querySelectorAll` returns static NodeList
- `getElementsByClassName` limited to class selection; `querySelectorAll` accepts any CSS selector
- `querySelectorAll` NodeList has `forEach` method; HTMLCollection does not

**vs getElementById:**

- `getElementById` returns single element or null; `getElementsByClassName` returns collection
- `getElementById` only works on document; `getElementsByClassName` works on any element

**vs getElementsByTagName:**

- Same return type (live HTMLCollection)
- Different selection criteria (tag vs class)

### Practical Use Cases

**Event delegation setup:**

```javascript
const buttons = document.getElementsByClassName('dynamic-btn');
// Convert to array to safely iterate
Array.from(buttons).forEach(btn => {
    btn.addEventListener('click', handleClick);
});
```

**Batch styling:**

```javascript
const highlights = document.getElementsByClassName('highlight');
for (let el of highlights) {
    el.style.backgroundColor = 'yellow';
}
```

**Conditional rendering:**

```javascript
const errors = document.getElementsByClassName('error-message');
if (errors.length > 0) {
    document.getElementById('error-summary').style.display = 'block';
}
```

---

