## querySelectorAll


### Method Signature and Return Value

`document.querySelectorAll(selectors)` and `element.querySelectorAll(selectors)` return a static `NodeList` containing all elements that match the specified CSS selector string. The NodeList is non-live, meaning it doesn't automatically update when the DOM changes after the method executes.

```javascript
const elements = document.querySelectorAll('.class, #id, [attribute]');
// Returns: NodeList [element1, element2, ...]
```

### Selector Syntax Coverage

#### Combinators and Relationships

```javascript
// Descendant combinator (space)
document.querySelectorAll('div p'); // All <p> descendants of <div>

// Child combinator (>)
document.querySelectorAll('ul > li'); // Direct <li> children only

// Adjacent sibling (+)
document.querySelectorAll('h2 + p'); // <p> immediately following <h2>

// General sibling (~)
document.querySelectorAll('h2 ~ p'); // All <p> siblings after <h2>
```

#### Attribute Selectors

```javascript
// Presence
document.querySelectorAll('[data-id]'); // Has attribute

// Exact match
document.querySelectorAll('[type="text"]');

// Contains word
document.querySelectorAll('[class~="active"]'); // Class list contains "active"

// Starts with
document.querySelectorAll('[href^="https"]');

// Ends with
document.querySelectorAll('[src$=".jpg"]');

// Contains substring
document.querySelectorAll('[title*="search"]');

// Starts with or is followed by hyphen
document.querySelectorAll('[lang|="en"]'); // Matches "en" or "en-US"

// Case-insensitive (i flag)
document.querySelectorAll('[type="TEXT" i]');

// Case-sensitive (s flag)
document.querySelectorAll('[type="text" s]');
```

#### Pseudo-classes

```javascript
// Structural
document.querySelectorAll('li:first-child');
document.querySelectorAll('li:last-child');
document.querySelectorAll('li:nth-child(2n)'); // Even children
document.querySelectorAll('li:nth-child(3n+1)'); // 1st, 4th, 7th...
document.querySelectorAll('li:nth-last-child(2)');
document.querySelectorAll('p:only-child');
document.querySelectorAll('div:empty');

// Type-based
document.querySelectorAll('p:first-of-type');
document.querySelectorAll('p:last-of-type');
document.querySelectorAll('p:nth-of-type(odd)');
document.querySelectorAll('p:only-of-type');

// State
document.querySelectorAll('input:checked');
document.querySelectorAll('input:disabled');
document.querySelectorAll('input:enabled');
document.querySelectorAll('option:selected'); // Note: Limited browser support
document.querySelectorAll(':focus');
document.querySelectorAll('a:visited'); // Returns empty for privacy reasons

// Negation
document.querySelectorAll('li:not(.excluded)');
document.querySelectorAll('input:not([type="hidden"])');

// Link/target
document.querySelectorAll(':target'); // Element matching URL fragment
document.querySelectorAll('a:link'); // Unvisited links
```

#### Pseudo-elements Limitation

[Unverified] `querySelectorAll` cannot select pseudo-elements (`::before`, `::after`, `::first-line`, etc.) as they aren't part of the DOM tree. These exist only in the rendering layer.

### NodeList vs HTMLCollection

The returned `NodeList` differs from `HTMLCollection` (returned by methods like `getElementsByClassName`):

```javascript
const nodeList = document.querySelectorAll('.item');
const htmlCollection = document.getElementsByClassName('item');

// Static vs Live
document.body.appendChild(newElement); // Has class "item"
console.log(nodeList.length); // Unchanged
console.log(htmlCollection.length); // Increases by 1

// Array-like iteration
nodeList.forEach(el => {}); // ✓ Has forEach
htmlCollection.forEach(el => {}); // ✗ No forEach (need Array.from)

// Array conversion
[...nodeList] // Spread
Array.from(nodeList) // Array.from
Array.prototype.slice.call(nodeList) // Legacy approach
```

### Performance Characteristics

#### Complexity Considerations

[Inference] The method performs a full tree traversal from the context node. Complex selectors with multiple combinators and pseudo-classes require more processing time. Specificity doesn't affect performance—selector complexity does.

```javascript
// More performant (simpler selector)
document.querySelectorAll('.item');

// Less performant (complex traversal)
document.querySelectorAll('body > div > section > article > p:nth-child(2n) > span.highlight');
```

#### Scoping for Optimization

```javascript
// Searches entire document
document.querySelectorAll('.button');

// Searches only within container
const container = document.getElementById('sidebar');
container.querySelectorAll('.button'); // Narrower scope = faster
```

#### Comparison with Specific Methods

```javascript
// For single class, ID, or tag:
document.getElementsByClassName('item'); // Generally faster, returns live collection
document.getElementById('unique'); // Fastest for IDs
document.getElementsByTagName('div'); // Fast for tags

// querySelectorAll advantage: complex selectors in one call
document.querySelectorAll('section.active > .item:not(.hidden)');
// vs.
// Multiple method calls + manual filtering
```

### Scope and Context

#### Document vs Element Context

```javascript
// Global scope
document.querySelectorAll('p'); // All paragraphs in document

// Element scope
const article = document.querySelector('article');
article.querySelectorAll('p'); // Only paragraphs within that article
```

#### :scope Pseudo-class

```javascript
const container = document.querySelector('.container');

// Without :scope - selects ANY div p in document within container
container.querySelectorAll('div p');

// With :scope - selects p that are descendants of div children of container
container.querySelectorAll(':scope > div p');
```

### Edge Cases and Gotchas

#### Invalid Selectors

```javascript
try {
  document.querySelectorAll('div:invalid-pseudo');
} catch (e) {
  // Throws DOMException: SyntaxError
}

try {
  document.querySelectorAll('[unclosed');
} catch (e) {
  // Throws DOMException: SyntaxError
}
```

#### Empty Selectors

```javascript
document.querySelectorAll(''); // Throws SyntaxError
document.querySelectorAll('   '); // Throws SyntaxError
```

#### ID Selectors with Special Characters

```javascript
// IDs with special characters must be escaped
// <div id="my:id"></div>
document.querySelectorAll('#my\\:id'); // Backslash escapes the colon

// <div id="123start"></div>
document.querySelectorAll('#\\31 23start'); // Escape leading digit
```

#### Case Sensitivity

```javascript
// Tag names and attribute names: case-insensitive in HTML
document.querySelectorAll('DIV'); // Works
document.querySelectorAll('[DATA-ID]'); // Works

// Attribute values and classes: case-sensitive by default
document.querySelectorAll('[type="Text"]'); // Won't match type="text"
document.querySelectorAll('.MyClass'); // Won't match class="myclass"

// Use case-insensitive flag
document.querySelectorAll('[type="Text" i]'); // Matches type="text"
```

#### Duplicate Results

```javascript
// Multiple selectors can match same element
document.querySelectorAll('.item, .active');
// If element has both classes, appears only ONCE in NodeList
```

### Practical Patterns

#### Selecting Multiple Unrelated Elements

```javascript
// Comma-separated selectors
const elements = document.querySelectorAll('header, footer, .sidebar');
```

#### Negating Multiple Conditions

```javascript
// Exclude multiple classes/types
document.querySelectorAll('input:not([type="hidden"]):not([type="submit"])');

// Exclude elements with specific attributes
document.querySelectorAll('div:not([data-exclude])');
```

#### Data Attribute Queries

```javascript
// Exact match
document.querySelectorAll('[data-status="active"]');

// Partial match
document.querySelectorAll('[data-id^="user-"]'); // IDs starting with "user-"

// Multiple data attributes
document.querySelectorAll('[data-type="product"][data-category="electronics"]');
```

#### Form-Specific Selections

```javascript
// All checked inputs
document.querySelectorAll('input:checked');

// Required fields that are empty
document.querySelectorAll('input:required:invalid');

// Valid inputs
document.querySelectorAll('input:valid');

// Radio buttons by name
document.querySelectorAll('input[type="radio"][name="size"]');

// Selected options within select
const select = document.querySelector('select');
select.querySelectorAll('option:checked');
```

#### Combining with Array Methods

```javascript
// Filter NodeList
const filtered = [...document.querySelectorAll('.item')]
  .filter(el => el.offsetHeight > 100);

// Map to extract data
const texts = [...document.querySelectorAll('p')]
  .map(p => p.textContent);

// Find first matching condition
const firstLarge = [...document.querySelectorAll('.item')]
  .find(el => el.offsetWidth > 500);

// Check condition
const allVisible = [...document.querySelectorAll('.item')]
  .every(el => el.offsetHeight > 0);
```

### Browser Compatibility Notes

[Unverified] The method has been supported since IE8 (with CSS2.1 selectors only). Modern selector features like `:scope`, `:is()`, `:where()`, and newer pseudo-classes may not work in older browsers. The `i` and `s` flags for attribute selectors have more limited support.

### Memory and Performance Considerations

#### Static Snapshot Advantages

```javascript
// Safe iteration even with DOM modifications
const items = document.querySelectorAll('.item');
items.forEach(item => {
  item.parentNode.removeChild(item); // Modifying DOM during iteration
  // NodeList remains unchanged, iteration continues safely
});
```

#### Memory Implications

[Inference] Since the NodeList is static, it holds references to elements even if they're removed from the DOM, potentially preventing garbage collection until the NodeList itself is released.

```javascript
function processElements() {
  const elements = document.querySelectorAll('.temporary');
  // elements array holds references
  
  elements.forEach(el => el.remove());
  // Elements removed from DOM but still referenced by 'elements'
  
} // elements goes out of scope here, allowing garbage collection
```

### Alternative Approaches

#### querySelector for Single Element

```javascript
// Returns first match or null
const first = document.querySelector('.item');

// More efficient than:
const firstAlt = document.querySelectorAll('.item')[0];
```

#### matches() for Testing

```javascript
const element = document.getElementById('test');

// Test if element matches selector
if (element.matches('.active')) {
  // Element has active class
}

// Check against multiple selectors
if (element.matches('.active, .selected, [data-active="true"]')) {
  // Matches at least one
}
```

#### closest() for Ancestor Matching

```javascript
const button = document.querySelector('button');

// Find closest ancestor matching selector
const form = button.closest('form');
const container = button.closest('.container');
```

---

