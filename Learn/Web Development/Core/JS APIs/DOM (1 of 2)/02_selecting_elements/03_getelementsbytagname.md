## getElementsByTagName


### Method Signature and Return Value

```javascript
document.getElementsByTagName(tagName)
element.getElementsByTagName(tagName)
```

Returns a live `HTMLCollection` of elements with the specified tag name. The collection is ordered in document tree order (depth-first pre-order traversal). The returned collection is **live**, meaning it automatically updates when the DOM changes.

### Tag Name Matching

The `tagName` parameter is case-insensitive in HTML documents but case-sensitive in XML documents.

```javascript
// These are equivalent in HTML documents
document.getElementsByTagName('div')
document.getElementsByTagName('DIV')
document.getElementsByTagName('Div')

// In XML documents, only exact case matches work
```

The special value `"*"` returns all elements in the document or within the specified element.

```javascript
// Get all elements in the document
const allElements = document.getElementsByTagName('*');
```

### HTMLCollection Characteristics

The returned `HTMLCollection` is **array-like** but not an actual array:

```javascript
const divs = document.getElementsByTagName('div');

// Has length property
console.log(divs.length);

// Supports bracket notation
const firstDiv = divs[0];

// Supports item() method
const secondDiv = divs.item(1);

// Does NOT have array methods (forEach, map, filter, etc.)
// divs.forEach() // TypeError

// Convert to array for array methods
Array.from(divs).forEach(div => {
  // process each div
});

[...divs].map(div => div.textContent);
```

### Live Collection Behavior

The live nature of `HTMLCollection` has significant performance and behavioral implications:

```javascript
const divs = document.getElementsByTagName('div');
console.log(divs.length); // e.g., 5

// Add a new div to the document
const newDiv = document.createElement('div');
document.body.appendChild(newDiv);

console.log(divs.length); // Now 6 - automatically updated

// Remove a div
document.body.removeChild(document.body.firstElementChild);
console.log(divs.length); // Decremented automatically
```

**Common pitfall with live collections:**

```javascript
const divs = document.getElementsByTagName('div');

// This creates an infinite loop!
for (let i = 0; i < divs.length; i++) {
  const newDiv = document.createElement('div');
  document.body.appendChild(newDiv);
  // divs.length keeps increasing!
}

// Safe approach: convert to static array first
const divsArray = Array.from(divs);
for (let i = 0; i < divsArray.length; i++) {
  const newDiv = document.createElement('div');
  document.body.appendChild(newDiv);
}
```

### Scope and Context

Can be called on `document` or any `Element`:

```javascript
// Search entire document
const allParagraphs = document.getElementsByTagName('p');

// Search within specific element
const container = document.getElementById('container');
const paragraphsInContainer = container.getElementsByTagName('p');

// Chain with other DOM methods
const firstDiv = document.getElementsByTagName('div')[0];
const spansInFirstDiv = firstDiv.getElementsByTagName('span');
```

### Performance Considerations

**Caching the collection:**

```javascript
// Poor: queries DOM on every iteration
for (let i = 0; i < document.getElementsByTagName('div').length; i++) {
  // process
}

// Better: cache the collection
const divs = document.getElementsByTagName('div');
for (let i = 0; i < divs.length; i++) {
  // process
}

// Best for performance if the collection won't change: cache length too
const divs = document.getElementsByTagName('div');
const len = divs.length;
for (let i = 0; i < len; i++) {
  // process
}
```

**Live vs. static considerations:**

[Inference] Live collections may have slightly slower performance for repeated access compared to static `NodeList` objects because they must query the DOM state on each access, though modern browsers optimize this heavily.

### Comparison with Similar Methods

#### vs. querySelectorAll()

```javascript
// getElementsByTagName - returns live HTMLCollection
const divs1 = document.getElementsByTagName('div');

// querySelectorAll - returns static NodeList
const divs2 = document.querySelectorAll('div');

// Key differences:
// 1. Live vs. static
// 2. HTMLCollection vs. NodeList
// 3. getElementsByTagName is faster for simple tag queries
// 4. querySelectorAll is more flexible (any CSS selector)
```

[Inference] For simple tag name queries, `getElementsByTagName` is typically faster than `querySelectorAll` due to its more specialized nature, though the difference is often negligible in practice.

#### vs. getElementsByClassName()

```javascript
// Get by tag name
const divs = document.getElementsByTagName('div');

// Get by class name
const highlighted = document.getElementsByClassName('highlight');

// Both return live HTMLCollection
// Can be combined by converting and filtering
const highlightedDivs = Array.from(divs).filter(div => 
  div.classList.contains('highlight')
);
```

#### vs. children/childNodes

```javascript
const parent = document.getElementById('parent');

// Only direct children elements (live HTMLCollection)
const directChildren = parent.children;

// All direct child nodes including text nodes (live NodeList)
const allChildren = parent.childNodes;

// All descendant divs (live HTMLCollection)
const allDescendantDivs = parent.getElementsByTagName('div');
```

### Practical Use Cases

**Manipulating multiple elements:**

```javascript
const images = document.getElementsByTagName('img');
for (let i = 0; i < images.length; i++) {
  images[i].loading = 'lazy';
  images[i].alt = images[i].alt || 'Image';
}
```

**Counting specific elements:**

```javascript
const linkCount = document.getElementsByTagName('a').length;
const headingCount = document.getElementsByTagName('h2').length;
```

**Scoped searches in dynamic content:**

```javascript
function processNewSection(sectionElement) {
  const links = sectionElement.getElementsByTagName('a');
  for (let i = 0; i < links.length; i++) {
    links[i].target = '_blank';
    links[i].rel = 'noopener noreferrer';
  }
}
```

### Edge Cases and Gotchas

**Namespace-qualified tags in XML/XHTML:**

```javascript
// In XML documents with namespaces
// getElementsByTagName uses local name only
const svgCircles = svgElement.getElementsByTagName('circle');

// For namespace-aware selection, use getElementsByTagNameNS
const circles = svgElement.getElementsByTagNameNS('http://www.w3.org/2000/svg', 'circle');
```

**Empty collections are truthy:**

```javascript
const spans = document.getElementsByTagName('span');

// Even if no spans exist, this is truthy!
if (spans) {
  console.log('This always runs');
}

// Check length instead
if (spans.length > 0) {
  console.log('Spans exist');
}
```

**Index access can return undefined:**

```javascript
const divs = document.getElementsByTagName('div');
const tenth = divs[9]; // undefined if fewer than 10 divs exist
```

### Browser Compatibility

Supported in all browsers including IE5+. The method is part of the DOM Level 1 specification and has universal support. The `"*"` parameter is supported in all modern browsers and IE6+.

### Modern Alternatives

Modern code often prefers:

```javascript
// For static collections
document.querySelectorAll('div')

// For single elements
document.querySelector('div')

// For more complex selections
document.querySelectorAll('div.active[data-type="primary"]')
```

However, `getElementsByTagName` remains valid for:

- Cases where live collections are specifically needed
- Performance-critical simple tag selections
- Legacy code maintenance

---

