## NodeList vs HTMLCollection


Both `NodeList` and `HTMLCollection` are array-like objects that represent collections of nodes, but they differ fundamentally in what they contain, when they update, and how they behave.

### Type of Nodes Contained

**HTMLCollection** contains only **Element nodes** (nodeType 1). Specifically, it holds `Element` objects, typically `HTMLElement` instances representing HTML tags. Text nodes, comment nodes, and other node types cannot exist in an HTMLCollection.

**NodeList** contains any type of **Node**, including:

- Element nodes
- Text nodes (including whitespace)
- Comment nodes
- Processing instruction nodes
- Any other node type in the DOM

This fundamental difference affects which DOM methods return which collection type.

### Live vs Static Behavior

**HTMLCollection** is always **live**. The collection automatically reflects DOM changes in real-time. If elements are added, removed, or modified, the HTMLCollection updates immediately without re-querying.

```javascript
const divs = document.getElementsByTagName('div'); // HTMLCollection
console.log(divs.length); // 5

document.body.appendChild(document.createElement('div'));
console.log(divs.length); // 6 - automatically updated
```

**NodeList** can be either **live** or **static**, depending on how it was created:

**Live NodeLists** (rare):

- `element.childNodes` - returns live NodeList of all child nodes
- Changes to children automatically reflect in the collection

```javascript
const children = document.body.childNodes; // Live NodeList
console.log(children.length); // 10

document.body.appendChild(document.createTextNode('text'));
console.log(children.length); // 11 - updated automatically
```

**Static NodeLists** (common):

- `querySelectorAll()` - returns static snapshot
- Frozen at the moment of query execution
- Never updates, even if matching elements are added/removed

```javascript
const paragraphs = document.querySelectorAll('p'); // Static NodeList
console.log(paragraphs.length); // 3

document.body.appendChild(document.createElement('p'));
console.log(paragraphs.length); // Still 3 - snapshot unchanged
```

### Methods That Return Each Type

**HTMLCollection returned by**:

- `getElementsByClassName(className)`
- `getElementsByTagName(tagName)`
- `getElementsByTagNameNS(namespace, tagName)`
- `element.children` (not `childNodes`)
- `document.forms`, `document.images`, `document.links`, `document.scripts`
- `form.elements`

**NodeList returned by**:

- `querySelectorAll(selector)` - static
- `element.childNodes` - live
- Various older DOM methods like `getElementsByName()` [Unverified: browser-specific behavior may vary]

### Access Methods

**HTMLCollection** supports:

- **Numeric indexing**: `collection[0]`, `collection[1]`
- **Named access**: `collection['elementId']` or `collection.elementId` - retrieves elements by `id` or `name` attribute
- `item(index)` method
- `namedItem(name)` method - retrieves by `id` or `name`
- `length` property

```javascript
const forms = document.forms; // HTMLCollection
forms[0];              // First form
forms['loginForm'];    // Form with id="loginForm"
forms.loginForm;       // Same as above
forms.namedItem('loginForm');
```

**NodeList** supports:

- **Numeric indexing**: `nodeList[0]`, `nodeList[1]`
- `item(index)` method
- `length` property
- `forEach()` method (modern browsers) - directly iterate without conversion
- **No named access** - cannot retrieve by `id` or `name`

```javascript
const nodes = document.querySelectorAll('p'); // NodeList
nodes[0];              // First paragraph
nodes.item(0);         // Same as above
nodes.forEach(node => console.log(node)); // Works directly
```

### Iteration Patterns

**HTMLCollection** is not directly iterable with `forEach` in older environments:

```javascript
const collection = document.getElementsByClassName('item');

// Convert to array for forEach
Array.from(collection).forEach(element => { /* ... */ });
[...collection].forEach(element => { /* ... */ });

// Classic for loop
for (let i = 0; i < collection.length; i++) {
  const element = collection[i];
}

// for...of (modern browsers)
for (const element of collection) { /* ... */ }
```

**NodeList** with `forEach` (modern browsers):

```javascript
const nodeList = document.querySelectorAll('.item');

// Direct forEach (ES2015+)
nodeList.forEach(node => { /* ... */ });

// for...of
for (const node of nodeList) { /* ... */ }

// Classic for loop
for (let i = 0; i < nodeList.length; i++) {
  const node = nodeList[i];
}
```

[Inference] The `forEach` method on NodeList was added in later specifications and may not be available in older browsers without polyfills.

### Performance Implications

**Live collections** (HTMLCollection, live NodeList):

- [Inference] Potentially slower for repeated access because the browser may need to re-query the DOM to ensure accuracy
- Efficient for tracking changes without re-querying
- Can cause infinite loops if modifying matching elements during iteration:

```javascript
const divs = document.getElementsByTagName('div'); // Live HTMLCollection

// Infinite loop - length increases as divs are added
for (let i = 0; i < divs.length; i++) {
  document.body.appendChild(document.createElement('div'));
}

// Solution: cache length or convert to array
const length = divs.length;
for (let i = 0; i < length; i++) { /* ... */ }
```

**Static NodeList**:

- [Inference] No overhead from live updates after creation
- Must re-query to see DOM changes
- Safe to modify DOM during iteration without affecting the collection

### Common Pitfalls

**Modifying live collections during iteration**:

```javascript
// Dangerous - live HTMLCollection
const divs = document.getElementsByClassName('remove-me');
for (let i = 0; i < divs.length; i++) {
  divs[i].remove(); // Collection shrinks, skipping elements
}

// Solution: iterate backwards
for (let i = divs.length - 1; i >= 0; i--) {
  divs[i].remove();
}

// Or convert to static array
Array.from(divs).forEach(div => div.remove());
```

**Expecting NodeList to be an array**:

```javascript
const nodeList = document.querySelectorAll('p');

// These don't exist on NodeList
nodeList.map(n => n.textContent);     // Error
nodeList.filter(n => n.id);           // Error
nodeList.reduce((acc, n) => acc + 1, 0); // Error

// Must convert first
Array.from(nodeList).map(n => n.textContent); // Works
[...nodeList].filter(n => n.id);              // Works
```

**Named access confusion**:

```javascript
// Works with HTMLCollection
const forms = document.forms;
forms['myForm']; // Returns form with id="myForm"

// Doesn't work with NodeList
const nodes = document.querySelectorAll('form');
nodes['myForm']; // undefined - numeric indexing only
```

### Conversion to Arrays

Both can be converted to true arrays for full array method access:

```javascript
// ES6 spread operator
const arrayFromCollection = [...htmlCollection];
const arrayFromNodeList = [...nodeList];

// Array.from()
const arrayFromCollection = Array.from(htmlCollection);
const arrayFromNodeList = Array.from(nodeList);

// Array.prototype.slice (older approach)
const arrayFromCollection = Array.prototype.slice.call(htmlCollection);
const arrayFromNodeList = Array.prototype.slice.call(nodeList);
```

### Browser Compatibility Considerations

**HTMLCollection** has been supported since early browser versions with consistent behavior across all modern browsers.

**NodeList** features vary:

- Basic NodeList support is universal
- `forEach()` method requires ES2015+ support (IE11 lacks it)
- `for...of` iteration requires Symbol.iterator support (IE11 lacks it)

[Inference] For maximum compatibility with older browsers, converting to arrays or using classic `for` loops remains the safest approach.

### Selection Strategy

**Use `getElementsBy*` methods (HTMLCollection)** when:

- You need live updates to element collections
- You're selecting by simple criteria (tag name, class name)
- Named access by `id` or `name` is useful
- [Inference] Performance benefits from native browser optimizations for simple queries

**Use `querySelectorAll` (static NodeList)** when:

- You need complex CSS selectors
- Static snapshots are preferable (safer for iteration/modification)
- You want to avoid live collection behavior
- [Inference] Modern syntax and flexibility outweigh live update needs

---

