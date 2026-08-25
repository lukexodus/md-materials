## ID and Tag Name Properties


The DOM provides multiple properties for accessing element identifiers and tag names, with subtle but important distinctions in their behavior, return values, and use cases.

### The `id` Property

The `id` property reflects the element's `id` attribute directly. It's a read-write property that exists on all `Element` objects.

**Reading**:

```javascript
const element = document.getElementById('myElement');
console.log(element.id); // "myElement"
```

**Writing**:

```javascript
element.id = 'newId'; // Changes the id attribute
```

**Behavior characteristics**:

- Returns empty string `""` if no `id` attribute exists (not `null` or `undefined`)
- Setting `element.id = ''` removes the `id` attribute from the DOM
- Reflects the attribute bidirectionally: changing `id` property updates the attribute, changing the attribute updates the property
- Case-sensitive: `id="MyElement"` and `id="myelement"` are different
- Must be unique within the document (though browsers don't enforce this - duplicate IDs cause undefined behavior)

**Property vs attribute access**:

```javascript
element.id = 'test';
element.getAttribute('id'); // "test" - same value

element.setAttribute('id', 'newTest');
element.id; // "newTest" - synchronized
```

### The `tagName` Property

The `tagName` property returns the tag name of an element. It's **read-only** and exists on all `Element` objects.

**Basic usage**:

```javascript
const div = document.querySelector('div');
console.log(div.tagName); // "DIV"

const paragraph = document.querySelector('p');
console.log(paragraph.tagName); // "P"
```

**Case behavior**:

- Returns **uppercase** for HTML elements: `"DIV"`, `"SPAN"`, `"P"`
- Returns **case-preserved** for XML/SVG elements in XML documents
- In HTML documents, even custom elements return uppercase: `<my-element>` → `"MY-ELEMENT"`

```javascript
// HTML document
const svg = document.querySelector('svg');
console.log(svg.tagName); // "SVG" - uppercase

const circle = document.querySelector('circle');
console.log(circle.tagName); // "CIRCLE" - uppercase

// Custom element
const custom = document.querySelector('my-component');
console.log(custom.tagName); // "MY-COMPONENT" - uppercase
```

**Immutability**:

```javascript
const element = document.createElement('div');
element.tagName = 'span'; // Has no effect - property is read-only
console.log(element.tagName); // Still "DIV"
```

You cannot change an element's tag name after creation. To effectively "change" a tag, you must create a new element and replace the old one:

```javascript
const oldElement = document.querySelector('div');
const newElement = document.createElement('span');

// Copy attributes
Array.from(oldElement.attributes).forEach(attr => {
  newElement.setAttribute(attr.name, attr.value);
});

// Copy children
while (oldElement.firstChild) {
  newElement.appendChild(oldElement.firstChild);
}

oldElement.parentNode.replaceChild(newElement, oldElement);
```

### The `nodeName` Property

The `nodeName` property exists on all `Node` objects (not just elements) and returns different values depending on node type.

**For element nodes**:

- Returns the same value as `tagName`
- Also uppercase in HTML documents
- Case-preserved in XML documents

```javascript
const div = document.querySelector('div');
console.log(div.nodeName);  // "DIV"
console.log(div.tagName);   // "DIV"
console.log(div.nodeName === div.tagName); // true for elements
```

**For other node types**:

```javascript
// Text node
const textNode = document.createTextNode('Hello');
console.log(textNode.nodeName); // "#text"
console.log(textNode.tagName);  // undefined - not an Element

// Comment node
const comment = document.createComment('comment');
console.log(comment.nodeName); // "#comment"

// Document node
console.log(document.nodeName); // "#document"

// Document fragment
const fragment = document.createDocumentFragment();
console.log(fragment.nodeName); // "#document-fragment"

// Attribute node (deprecated access pattern)
const attr = document.createAttribute('class');
console.log(attr.nodeName); // "class"
```

### The `localName` Property

The `localName` property returns the local part of the qualified name, **always in lowercase** for HTML elements, regardless of document type.

**Basic usage**:

```javascript
const div = document.querySelector('div');
console.log(div.localName); // "div" - lowercase
console.log(div.tagName);   // "DIV" - uppercase
```

**Namespace considerations**:

For elements with namespace prefixes (common in XML/SVG/MathML), `localName` returns only the local part without the prefix:

```javascript
// SVG element
const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
console.log(svg.tagName);    // "svg"
console.log(svg.localName);  // "svg"

// Namespaced element with prefix
const element = document.createElementNS('http://example.com', 'prefix:elementName');
console.log(element.tagName);   // "prefix:elementName"
console.log(element.localName); // "elementName" - without prefix
console.log(element.prefix);    // "prefix"
```

**HTML vs XML behavior**:

```javascript
// HTML document
const htmlDiv = document.createElement('DIV');
console.log(htmlDiv.localName); // "div" - normalized to lowercase

// XML document (if parsed as XML)
const xmlDoc = new DOMParser().parseFromString('<Root><Item/></Root>', 'text/xml');
const item = xmlDoc.querySelector('Item');
console.log(item.localName); // "Item" - preserves case in XML
```

### The `className` Property

The `className` property reflects the `class` attribute. It uses "className" instead of "class" because `class` is a reserved keyword in JavaScript.

**Reading**:

```javascript
const element = document.querySelector('.my-class');
console.log(element.className); // "my-class another-class"
```

**Writing**:

```javascript
element.className = 'new-class'; // Replaces all classes
element.className = ''; // Removes all classes
```

**Behavior characteristics**:

- Returns a **string** containing all classes separated by spaces
- Setting it replaces the entire class list
- Returns empty string `""` if no classes exist
- Whitespace-sensitive: multiple spaces are preserved

```javascript
element.className = 'class1  class2   class3';
console.log(element.className); // "class1  class2   class3" - spaces preserved
```

**Limitations**:

- Manipulating individual classes requires string parsing
- Adding a class without removing others is cumbersome:

```javascript
// Awkward class addition
if (!element.className.includes('new-class')) {
  element.className += ' new-class';
}

// Better approach: use classList
element.classList.add('new-class');
```

### The `classList` Property

The `classList` property provides a `DOMTokenList` interface for class manipulation. It's the modern, preferred way to work with classes.

**Methods**:

- `add(...tokens)` - adds one or more classes
- `remove(...tokens)` - removes one or more classes
- `toggle(token, force?)` - toggles class, optional force parameter
- `contains(token)` - checks if class exists
- `replace(oldToken, newToken)` - replaces one class with another
- `item(index)` - returns class at index
- `entries()`, `forEach()`, `keys()`, `values()` - iteration methods

**Usage examples**:

```javascript
const element = document.querySelector('div');

element.classList.add('active');
element.classList.add('highlight', 'selected'); // Multiple at once

element.classList.remove('active');
element.classList.remove('highlight', 'selected');

element.classList.toggle('hidden'); // Adds if absent, removes if present
element.classList.toggle('visible', true); // Always adds (force=true)
element.classList.toggle('visible', false); // Always removes (force=false)

const hasClass = element.classList.contains('active'); // boolean

element.classList.replace('old-theme', 'new-theme');
```

**Iteration**:

```javascript
element.className = 'class1 class2 class3';

// Array-like access
console.log(element.classList[0]); // "class1"
console.log(element.classList.length); // 3

// forEach
element.classList.forEach(cls => console.log(cls));

// for...of
for (const cls of element.classList) {
  console.log(cls);
}

// Convert to array
const classArray = [...element.classList];
```

**DOMTokenList vs string**:

- `classList` is read-only (can't assign `element.classList = ...`)
- Methods modify the underlying `class` attribute
- Automatically handles whitespace normalization
- Prevents duplicate class names

```javascript
element.classList.add('test');
element.classList.add('test'); // No effect - doesn't duplicate
console.log(element.className); // "test" - appears once
```

### Comparing Properties

|Property|Type|Case|Read/Write|Node Types|Special Behavior|
|---|---|---|---|---|---|
|`id`|String|Case-sensitive|Read/Write|Elements only|Empty string if unset|
|`tagName`|String|Uppercase (HTML)|Read-only|Elements only|N/A|
|`nodeName`|String|Uppercase (HTML)|Read-only|All nodes|Special values for non-elements|
|`localName`|String|Lowercase (HTML)|Read-only|Elements only|Strips namespace prefix|
|`className`|String|Case-sensitive|Read/Write|Elements only|Full class string|
|`classList`|DOMTokenList|Case-sensitive|Read-only object|Elements only|Methods for manipulation|

### Case-Insensitive Comparisons

When comparing tag names, always normalize case:

```javascript
// Unsafe - case-dependent
if (element.tagName === 'div') { /* May fail */ }

// Safe - normalize to uppercase
if (element.tagName === 'DIV') { /* Works in HTML */ }
if (element.tagName.toUpperCase() === 'DIV') { /* Works everywhere */ }

// Safe - use localName (lowercase)
if (element.localName === 'div') { /* Works */ }
```

[Inference] Using `localName` for comparisons may be more intuitive for developers expecting lowercase, though both approaches work reliably when applied consistently.

### Namespace-Related Properties

For elements created with namespace methods, additional properties provide context:

**`namespaceURI`**:

```javascript
const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
console.log(svg.namespaceURI); // "http://www.w3.org/2000/svg"

const div = document.createElement('div');
console.log(div.namespaceURI); // "http://www.w3.org/1999/xhtml"
```

**`prefix`**:

```javascript
const element = document.createElementNS('http://example.com', 'custom:element');
console.log(element.prefix);    // "custom"
console.log(element.localName); // "element"
console.log(element.tagName);   // "custom:element"
```

**`qualifiedName`** (not a property, but returned by some APIs):

- The full name including prefix
- Same as `tagName` for most elements

### Performance Considerations

[Inference] Direct property access (`id`, `tagName`) is generally faster than method calls (`getAttribute()`, `classList` methods) for simple read operations, though modern JavaScript engines optimize both patterns efficiently. The performance difference is typically negligible except in tight loops processing thousands of elements.

**ID lookups**:

```javascript
// Fast - direct property access
const id = element.id;

// Slightly slower - method call with attribute lookup
const id = element.getAttribute('id');
```

**Class manipulation**:

```javascript
// classList methods are optimized internally
element.classList.add('class'); // Preferred

// String manipulation requires parsing
element.className += ' class'; // Less efficient
```

### Global ID Access (Legacy)

Elements with `id` attributes automatically become global properties in older browsers:

```html
<div id="myDiv"></div>

<script>
// Legacy behavior (avoid)
console.log(window.myDiv); // References the div element
console.log(myDiv); // Also works (global scope pollution)

// Modern approach (use this)
const element = document.getElementById('myDiv');
</script>
```

[Inference] This legacy behavior creates potential naming conflicts and is not reliable across all browsers or strict mode. Always use explicit DOM selection methods.

### Dynamic ID and Class Updates

Both `id` and `className`/`classList` changes immediately update the DOM and CSS selector matching:

```javascript
const element = document.querySelector('#oldId');
element.id = 'newId';

// Immediately usable with new ID
document.getElementById('newId'); // Returns the element
document.getElementById('oldId'); // Returns null

// Classes update CSS matching immediately
element.classList.add('highlight');
// CSS rule .highlight {} now applies
```

Browsers re-evaluate CSS selectors and specificity when these properties change, triggering potential reflows and repaints.

---

