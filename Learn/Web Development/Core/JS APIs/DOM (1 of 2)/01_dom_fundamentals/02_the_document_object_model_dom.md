## The Document Object Model (DOM)


The DOM is a programming interface that represents HTML and XML documents as a tree structure of objects. Browsers parse markup and construct this live representation in memory, allowing scripts to access and manipulate document structure, style, and content dynamically.

### Tree Structure and Node Hierarchy

The DOM organizes documents into a hierarchical tree where every element, attribute, and text fragment becomes a node. The `document` object serves as the entry point, with `document.documentElement` representing the root `<html>` element.

**Node types** include:

- **Element nodes** (nodeType 1): HTML tags like `<div>`, `<p>`
- **Text nodes** (nodeType 3): Character data between tags
- **Attribute nodes** (deprecated in DOM4, now accessed via element properties)
- **Comment nodes** (nodeType 8): HTML comments
- **Document nodes** (nodeType 9): The document itself
- **DocumentFragment nodes** (nodeType 11): Lightweight containers for batch operations

Each node has relationships: `parentNode`, `childNodes`, `firstChild`, `lastChild`, `nextSibling`, `previousSibling`. Element nodes specifically have `children`, `firstElementChild`, `lastElementChild`, `nextElementSibling`, `previousElementSibling` that skip non-element nodes.

### DOM Interfaces and Inheritance

The DOM defines a hierarchy of interfaces that JavaScript objects implement:

```
EventTarget
  └─ Node
      ├─ Document
      ├─ Element
      │   └─ HTMLElement
      │       ├─ HTMLDivElement
      │       ├─ HTMLInputElement
      │       └─ [other HTML elements]
      ├─ Text
      ├─ Comment
      └─ DocumentFragment
```

This inheritance means a `<div>` element has properties from `HTMLDivElement`, `HTMLElement`, `Element`, `Node`, and `EventTarget`.

### Selection and Traversal

**Query methods** provide node access:

- `getElementById(id)`: Returns single element or null
- `getElementsByClassName(classNames)`: Returns live HTMLCollection
- `getElementsByTagName(tagName)`: Returns live HTMLCollection
- `querySelector(selector)`: Returns first match or null
- `querySelectorAll(selector)`: Returns static NodeList

**Live vs. static collections**: `getElementsBy*` methods return collections that automatically update when the DOM changes. `querySelectorAll` returns a static snapshot frozen at query time.

**Traversal APIs** like `TreeWalker` and `NodeIterator` enable filtered, programmatic tree navigation with custom logic for skipping nodes.

### Manipulation Operations

**Creating nodes**:

- `document.createElement(tagName)`
- `document.createTextNode(data)`
- `document.createDocumentFragment()`
- `element.cloneNode(deep)` - deep=true clones descendants

**Inserting nodes**:

- `parent.appendChild(node)` - adds to end
- `parent.insertBefore(node, referenceNode)`
- `element.append(...nodes)` - modern, accepts strings
- `element.prepend(...nodes)`
- `element.before(...nodes)`, `element.after(...nodes)`
- `element.replaceWith(...nodes)`

**Removing nodes**:

- `parent.removeChild(child)` - legacy
- `element.remove()` - modern, simpler

**Replacing content**:

- `element.innerHTML` - parses and renders HTML strings (security risk with untrusted input)
- `element.textContent` - sets text, escapes HTML
- `element.replaceChildren(...nodes)` - replaces all children atomically

### Attributes and Properties

JavaScript element properties don't always mirror HTML attributes directly. The DOM maintains two parallel systems:

**Attribute methods** (string-based):

- `element.getAttribute(name)`
- `element.setAttribute(name, value)`
- `element.hasAttribute(name)`
- `element.removeAttribute(name)`
- `element.attributes` - NamedNodeMap of all attributes

**Property access** (type-aware):

- `element.id`, `element.className`, `element.href`
- Properties can have different types (boolean for `checked`, number for `tabIndex`)
- Some properties reflect attributes (`id` ↔ `id`), others don't (`value` property vs `value` attribute)

The `class` attribute becomes `className` property due to JavaScript reserved words. `classList` provides a DOMTokenList for class manipulation: `add()`, `remove()`, `toggle()`, `contains()`, `replace()`.

### Styling Through the DOM

**Inline styles** via `element.style`:

- Sets the `style` attribute directly
- Properties are camelCased: `backgroundColor`, `fontSize`
- Values are strings: `element.style.width = '100px'`
- `cssText` sets multiple properties: `element.style.cssText = 'color: red; font-size: 16px'`

**Computed styles** via `window.getComputedStyle(element, pseudoElement)`:

- Returns read-only CSSStyleDeclaration with resolved values
- Reflects actual rendered styles including inherited and stylesheet rules
- Pseudo-element parameter optional for `::before`, `::after`, etc.

**Stylesheet manipulation**:

- `document.styleSheets` - StyleSheetList of all stylesheets
- `CSSStyleSheet.insertRule(rule, index)`, `deleteRule(index)`
- `sheet.cssRules` or `sheet.rules` - access individual rules

### Event System

The DOM event system operates in three phases:

1. **Capturing phase**: Event travels from `window` down to target
2. **Target phase**: Event reaches the target element
3. **Bubbling phase**: Event bubbles back up to `window`

**Event registration**:

- `element.addEventListener(type, listener, options)`
- Options: `capture` (bool), `once` (bool), `passive` (bool), `signal` (AbortSignal)
- `element.removeEventListener(type, listener, options)` - must match registration

*capture (boolean)* controls which phase of event propagation triggers the listener. When `true`, the listener fires during the capture phase (event travels down from root to target). When `false` (default), the listener fires during the bubble phase (event travels up from target to root). You can use `element.addEventListener('click', handler, { capture: true })` or the older boolean syntax `element.addEventListener('click', handler, true)`.

*once (boolean)* determines whether the listener persists. When `true`, the listener automatically removes itself after firing once. When `false` (default), the listener persists until explicitly removed. For example: `element.addEventListener('click', handler, { once: true })` will only fire on the first click, then remove itself.

*passive (boolean)* indicates whether the listener will call `preventDefault()`. When `true`, the listener will not call `preventDefault()`, allowing the browser to optimize scrolling performance. When `false` (default), the listener may call `preventDefault()`. For example: `element.addEventListener('touchstart', handler, { passive: true })` lets the browser optimize scroll performance since it knows `preventDefault()` won't be called. [Inference] If you set `passive: true` but try to call `preventDefault()` in the handler, the call will be ignored and the browser may log a warning.

*signal (AbortSignal)* allows you to remove the listener using an `AbortController`. You create a controller with `const controller = new AbortController()`, pass its signal when adding the listener with `element.addEventListener('click', handler, { signal: controller.signal })`, and later remove the listener by calling `controller.abort()`.

**Event object properties**:

- `event.target` - element that triggered the event
- `event.currentTarget` - element with the listener attached
- `event.type`, `event.timeStamp`
- `event.bubbles`, `event.cancelable`
- `event.preventDefault()` - prevents default action
- `event.stopPropagation()` - stops propagation to other elements
- `event.stopImmediatePropagation()` - stops other listeners on same element

**Event delegation** exploits bubbling: attach listeners to ancestor elements and check `event.target` to handle events from descendants. This reduces memory overhead and handles dynamically added elements. Event delegation reduces memory overhead because you create one listener on a parent element instead of many listeners on multiple child elements.

### DocumentFragment for Performance

`DocumentFragment` is a lightweight container that exists outside the main DOM tree. Building complex structures in a fragment and inserting once minimizes reflows:

```javascript
const fragment = document.createDocumentFragment();
for (let i = 0; i < 1000; i++) {
  const div = document.createElement('div');
  fragment.appendChild(div);
}
document.body.appendChild(fragment); // Single reflow
```

### Reflow and Repaint

**Reflow** (layout): Browser recalculates element positions and dimensions. Triggered by:

- Changing element dimensions, position, or display
- Content changes affecting layout
- Window resize
- Reading computed layout properties (`offsetHeight`, `getBoundingClientRect()`)

**Repaint**: Browser redraws pixels without layout changes. Triggered by:

- Color changes
- Visibility changes
- Background changes

[Inference] Batching DOM operations and minimizing forced synchronous layouts (reading layout properties after writes) improves performance, though exact performance impact varies by browser implementation.

### MutationObserver

`MutationObserver` asynchronously monitors DOM changes:

```javascript
const observer = new MutationObserver((mutations) => {
  mutations.forEach(mutation => {
    // Process changes
  });
});

observer.observe(targetNode, {
  childList: true,      // Child node additions/removals
  attributes: true,     // Attribute changes
  characterData: true,  // Text content changes
  subtree: true,        // Monitor descendants
  attributeOldValue: true,
  characterDataOldValue: true
});
```

Observers fire after the script completes but before rendering, consolidating multiple changes into batched callbacks.

The `observe` method attaches the observer to `targetNode` with specific configuration options. `childList: true` detects when child nodes are added or removed. `attributes: true` watches for changes to element attributes. `characterData: true` monitors modifications to text content within text nodes. `subtree: true` extends monitoring to all descendant nodes, not just direct children. `attributeOldValue: true` includes the previous attribute value in mutation records. `characterDataOldValue: true` includes the previous text content in mutation records.

This setup provides comprehensive monitoring of DOM changes, useful for scenarios like detecting dynamic content updates, implementing custom devtools, or syncing state with DOM modifications. The observer will fire the callback whenever any of the specified change types occur within the target element or its subtree.

**childList mutations** occur when elements are added or removed. Appending a new div with `parent.appendChild(document.createElement('div'))` triggers this. Removing an element with `parent.removeChild(child)` also triggers it. Replacing `innerHTML` like `parent.innerHTML = '<span>New content</span>'` triggers it because the old children are removed and new ones added.

**attributes mutations** happen when element attributes change. Setting `element.className = 'active'` triggers this. Calling `element.setAttribute('data-id', '123')` triggers it. Removing an attribute with `element.removeAttribute('disabled')` triggers it. Even style changes via `element.style.color = 'red'` trigger it since style is an attribute.

**characterData mutations** fire when text node content changes. If you have a text node reference and call `textNode.data = 'new text'`, this triggers. Changing `textContent` on an element like `element.textContent = 'updated'` may trigger this if the element contains a text node that gets modified.

**subtree monitoring** captures all the above changes in descendant elements. With `subtree: true`, modifying `grandchild.className = 'highlight'` triggers the observer even if you're observing the grandparent element.

**oldValue options** provide the previous state. If you change `element.id` from 'old' to 'new' with `attributeOldValue: true` enabled, the mutation record includes both the old value ('old') and you can check the current value ('new') from the element itself.

### Shadow DOM

Shadow DOM encapsulates subtrees with isolated styling and markup:

```javascript
const shadow = element.attachShadow({mode: 'open'});
shadow.innerHTML = '<style>p { color: red; }</style><p>Encapsulated</p>';
```

**Mode options**:

- `open`: `element.shadowRoot` accessible
- `closed`: `shadowRoot` returns null [Inference] though closure references remain accessible

Styles inside shadow roots don't leak out; external styles don't leak in. Custom elements commonly use shadow DOM for component isolation.

### Range and Selection APIs

**Range** represents document fragments:

- `document.createRange()`
- `setStart(node, offset)`, `setEnd(node, offset)`
- `selectNode(node)`, `selectNodeContents(node)`
- `deleteContents()`, `extractContents()`, `cloneContents()`

**Selection** represents user selections:

- `window.getSelection()` returns current selection
- `addRange(range)`, `removeRange(range)`, `removeAllRanges()`
- `anchorNode`, `focusNode` - selection endpoints

The **Range** object represents a fragment or portion of a document. You create one using `document.createRange()`, which gives you an object that can span across multiple nodes in the DOM tree. 

To define what portion of the document your range covers, you use `setStart(node, offset)` and `setEnd(node, offset)` - these methods let you specify exactly where the range begins and ends by pointing to a specific node and an offset within it. The offset means different things depending on the node type: for text nodes, it's the character position, while for element nodes, it's the child node index.

If you want to quickly select content without manually setting start and end points, you have two convenience methods: `selectNode(node)` sets the range to encompass that node including its boundaries (like selecting the entire `<p>` tag and its contents), while `selectNodeContents(node)` selects only the contents inside the node, excluding the node's own opening and closing tags.

Once you have a range defined, you can manipulate it in several ways. The method `deleteContents()` removes the selected content from the document permanently. The method `extractContents()` removes the content but also returns it as a document fragment you can insert elsewhere or work with further. The method `cloneContents()` creates a copy of the content as a document fragment without removing the original from the document.

---

The **Selection** object represents what the user has actually selected or highlighted in the document, which might be nothing, some text, or even multiple ranges. You access the current selection by calling `window.getSelection()`, which returns the selection object for that window.

This selection object can contain one or more Range objects representing the highlighted portions. You can programmatically modify the selection using several methods: `addRange(range)` adds a range to the current selection (though most browsers only support a single range), `removeRange(range)` removes a specific range from the selection, and `removeAllRanges()` clears the selection entirely, leaving nothing highlighted.

The selection has two important endpoint properties that you can examine. The property `anchorNode` represents the node where the user started their selection (where they first clicked or touched). The property `focusNode` represents the node where the selection currently ends (where they released or where the cursor is now). These might be the same node if nothing is selected or if the selection is within a single node, or they might be different nodes if the selection spans across multiple elements in the document.

### DOM Levels and Standards

The DOM evolved through levels:

- **DOM Level 0**: Unofficial, pre-standardization browser APIs
- **DOM Level 1** (1998): Core document structure and HTML
- **DOM Level 2** (2000): Events, CSS, traversal, views
- **DOM Level 3** (2004): XPath, keyboard events, load/save
- **DOM Level 4**: Modern living standard (no longer versioned)

The WHATWG now maintains the DOM Standard as a living specification that continuously evolves. W3C and WHATWG merged their efforts in 2019, with WHATWG as the sole maintainer.

### Virtual DOM Distinction

The browser DOM is the actual document representation. Virtual DOM is a programming pattern used by frameworks (React, Vue) where JavaScript objects mirror the DOM structure. Frameworks diff virtual trees and batch actual DOM updates. [Inference] This abstraction can improve performance for complex UIs by minimizing direct DOM manipulation, though the pattern introduces memory and computational overhead.

---

