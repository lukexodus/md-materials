## Live vs Static Collections


### Fundamental Difference

Live collections maintain active references to the DOM tree and automatically reflect any structural changes made after their creation. Static collections create a snapshot of matching nodes at query time and never update regardless of subsequent DOM modifications.

```javascript
const liveCollection = document.getElementsByClassName('item');
const staticCollection = document.querySelectorAll('.item');

console.log(liveCollection.length); // 3
console.log(staticCollection.length); // 3

document.body.appendChild(document.createElement('div')).className = 'item';

console.log(liveCollection.length); // 4 (updated automatically)
console.log(staticCollection.length); // 3 (unchanged)
```

### Live Collection Types

**HTMLCollection**: Returned by:

- `element.children`
- `document.getElementsByTagName()`
- `document.getElementsByClassName()`
- `document.getElementsByName()`
- `document.forms`
- `document.images`
- `document.links`
- `element.getElementsByTagName()`
- `element.getElementsByClassName()`

**Live NodeList**: Returned by:

- `element.childNodes`
- Older DOM properties like `document.all` (deprecated)

HTMLCollections provide name-based access via bracket notation or `namedItem()` method using element `id` or `name` attributes. Live NodeLists lack this feature and only support numeric indexing.

### Static Collection Types

**Static NodeList**: Returned by:

- `document.querySelectorAll()`
- `element.querySelectorAll()`

Static NodeLists are array-like objects created by capturing matching nodes at execution time. They implement the `NodeList` interface but remain frozen regardless of DOM changes.

### Performance Implications

Live collections query the DOM tree each time they're accessed. Every property read (`.length`, bracket access) may traverse the tree to ensure accuracy:

```javascript
const divs = document.getElementsByTagName('div');

// This performs tree traversal 1000 times
for (let i = 0; i < divs.length; i++) {
  console.log(divs[i]);
}

// Cache length to reduce traversals
const length = divs.length;
for (let i = 0; i < length; i++) {
  console.log(divs[i]);
}
```

[Inference: Modern engines optimize repeated accesses within tight loops, but caching length still provides benefits in complex scenarios]. Static collections avoid this overhead since their contents never change.

### Mutation Hazards with Live Collections

Live collections create risks when modifying the DOM during iteration:

```javascript
const paragraphs = document.getElementsByTagName('p');

// Infinite loop: moves first element repeatedly
for (let i = 0; i < paragraphs.length; i++) {
  document.body.appendChild(paragraphs[0]);
}

// Skips elements: collection shrinks as elements removed
for (let i = 0; i < paragraphs.length; i++) {
  paragraphs[i].remove(); // Removes current, next element shifts to i
}
```

Safe iteration patterns for live collections:

```javascript
// Iterate backwards
for (let i = elements.length - 1; i >= 0; i--) {
  elements[i].remove();
}

// Convert to array
[...elements].forEach(el => el.remove());
Array.from(elements).forEach(el => el.remove());

// Cache references
const elementsArray = [];
for (let i = 0; i < elements.length; i++) {
  elementsArray.push(elements[i]);
}
elementsArray.forEach(el => el.remove());
```

### Named Access in HTMLCollection

HTMLCollections support accessing elements by `id` or `name` attributes:

```javascript
const forms = document.forms;

// Access by numeric index
forms[0];

// Access by name attribute
forms['loginForm'];
forms.namedItem('loginForm');

// Also works with bracket notation for id
const element = document.getElementById('myDiv');
const children = element.children;
children['specificChild']; // Accesses child with id="specificChild"
```

This creates potential naming conflicts if multiple elements share the same `id` or `name`. [Inference: The first matching element is typically returned, though behavior may vary by implementation].

### Array-Like Behavior

Both collection types are array-like objects with numeric indices and `.length` property but lack array methods:

```javascript
const divs = document.getElementsByTagName('div');

typeof divs.length; // 'number'
divs[0]; // First div element
divs.forEach; // undefined

// Converting to arrays enables array methods
Array.from(divs).forEach(div => {});
[...divs].map(div => div.textContent);
Array.prototype.forEach.call(divs, div => {});
```

Modern JavaScript's spread operator and `Array.from()` provide clean conversion syntax. Older code used `Array.prototype.slice.call(collection)` for this purpose.

### Collection Type Identification

Distinguishing collection types programmatically:

```javascript
const live = document.getElementsByClassName('test');
const static = document.querySelectorAll('.test');

live instanceof HTMLCollection; // true
live instanceof NodeList; // false

static instanceof NodeList; // true
static instanceof HTMLCollection; // false

// Checking for specific NodeList type requires testing behavior
// No built-in property distinguishes live vs static NodeList
```

[Unverified: No standard property explicitly identifies whether a NodeList is live or static without testing actual behavior].

### Memory Considerations

Live collections maintain internal references to the DOM tree structure. Holding references to live collections from removed DOM subtrees can prevent garbage collection:

```javascript
const div = document.createElement('div');
div.innerHTML = '<span></span>'.repeat(10000);
document.body.appendChild(div);

const spans = div.getElementsByTagName('span');
div.remove(); // Remove from DOM

// 'spans' still references the collection, which references the detached tree
// [Inference: This may prevent garbage collection depending on engine implementation]
```

Static collections capture references to nodes at creation time. If those nodes are removed from the DOM, the collection maintains references to the now-detached nodes, also potentially preventing garbage collection.

### Practical Selection Guidelines

**Use live collections when:**

- Monitoring specific element types that change frequently
- Building reactive interfaces that automatically reflect DOM state
- Working with well-defined element sets like `document.forms` or `document.images`
- Performance impact of live updates is negligible

**Use static collections when:**

- Iterating and modifying matched elements
- Caching query results for repeated access
- Building element arrays for complex transformations
- Avoiding mutation hazards during iteration
- Query performance matters more than automatic updates

### Edge Cases and Quirks

**Empty collections**: Both types return collections with `.length === 0` when no elements match. These remain valid objects that can be iterated.

**Order guarantees**: Both maintain document order (depth-first traversal of the tree). Elements appear in the order they would be encountered when reading the HTML sequentially.

**Case sensitivity**: `getElementsByTagName()` is case-insensitive for HTML documents but case-sensitive for XML documents. `querySelectorAll()` follows CSS selector rules, which are case-sensitive for class names and IDs but case-insensitive for tag names in HTML.

**Attribute changes**: Live collections based on class names update when `className` or `classList` changes:

```javascript
const items = document.getElementsByClassName('active');
console.log(items.length); // 2

items[0].classList.remove('active');
console.log(items.length); // 1 (collection automatically updated)
```

Static collections ignore such changes entirely, maintaining their original captured set.

---

