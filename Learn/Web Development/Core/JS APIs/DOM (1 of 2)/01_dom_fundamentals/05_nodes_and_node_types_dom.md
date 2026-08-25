## Nodes and Node Types (DOM)


### Node Interface Hierarchy

The DOM represents documents as a tree of nodes, where every element, attribute, text fragment, and structural component is a node. The `Node` interface serves as the primary base type from which all DOM node types inherit.

```
Node (base interface)
├── Document
├── DocumentFragment
├── DocumentType
├── Element
│   ├── HTMLElement
│   │   ├── HTMLDivElement
│   │   ├── HTMLSpanElement
│   │   └── (other HTML elements)
│   └── SVGElement
├── Attr
├── CharacterData
│   ├── Text
│   ├── Comment
│   └── ProcessingInstruction
└── CDATASection
```

### Node Type Constants

Every node has a `nodeType` property that returns an integer constant identifying its type:

|Constant|Value|Node Type|Description|
|---|---|---|---|
|`Node.ELEMENT_NODE`|1|Element|HTML or XML element|
|`Node.ATTRIBUTE_NODE`|2|Attr|Element attribute (deprecated in DOM4)|
|`Node.TEXT_NODE`|3|Text|Text content within elements|
|`Node.CDATA_SECTION_NODE`|4|CDATASection|CDATA section in XML|
|`Node.PROCESSING_INSTRUCTION_NODE`|7|ProcessingInstruction|Processing instruction|
|`Node.COMMENT_NODE`|8|Comment|Comment node|
|`Node.DOCUMENT_NODE`|9|Document|Document root|
|`Node.DOCUMENT_TYPE_NODE`|10|DocumentType|DOCTYPE declaration|
|`Node.DOCUMENT_FRAGMENT_NODE`|11|DocumentFragment|Lightweight document container|

**Note:** Node types 5 (ENTITY_REFERENCE_NODE), 6 (ENTITY_NODE), and 12 (NOTATION_NODE) are deprecated and no longer used in modern DOM implementations.

### Element Nodes (Type 1)

Element nodes represent HTML or XML tags and form the structural backbone of the DOM tree.

**Key Properties:**

- `tagName`: Uppercase tag name (e.g., "DIV", "SPAN")
- `localName`: Lowercase local name
- `namespaceURI`: Namespace URI (null for HTML documents)
- `attributes`: NamedNodeMap of attributes
- `classList`: DOMTokenList for class manipulation
- `className`: String of space-separated classes
- `id`: Element identifier

**Child Node Rules:** Element nodes can contain:

- Other Element nodes
- Text nodes
- Comment nodes
- ProcessingInstruction nodes
- CDATASection nodes (XML only)

**Navigation Properties:**

- `children`: HTMLCollection of child elements only
- `childNodes`: NodeList of all child nodes
- `firstElementChild` / `lastElementChild`: First/last child elements
- `nextElementSibling` / `previousElementSibling`: Adjacent elements

### Text Nodes (Type 3)

Text nodes contain the actual text content within elements. They cannot have children and represent leaf nodes in the DOM tree.

**Characteristics:**

- `nodeValue` and `data` properties contain the text string
- `wholeText` returns concatenated text of all adjacent text nodes
- Whitespace (spaces, tabs, newlines) creates text nodes
- Empty text nodes can exist but are often normalized away

**Text Node Manipulation:**

```javascript
const textNode = document.createTextNode("Hello");
textNode.appendData(" World"); // "Hello World"
textNode.insertData(5, ","); // "Hello, World"
textNode.deleteData(5, 1); // "Hello World"
textNode.replaceData(6, 5, "Universe"); // "Hello Universe"
textNode.substringData(0, 5); // "Hello"
```

**Whitespace Handling:** Browsers create text nodes for whitespace between elements in HTML source:

```html
<div>
  <span>Text</span>
  <span>More</span>
</div>
```

This creates text nodes containing newlines and spaces between the `<span>` elements. Use `nodeType === 3` checks when traversing to handle these.

### Comment Nodes (Type 8)

Comment nodes represent HTML/XML comments (`<!-- comment -->`).

**Properties:**

- `data`: Comment text content
- `length`: Number of characters
- Cannot have child nodes
- Often ignored in DOM traversal but preserved in the tree

**Use Cases:**

- Template markers in frameworks
- Conditional comments (legacy IE)
- Server-side include markers
- Documentation within markup

### Document Node (Type 9)

The Document node sits at the root of the DOM tree and represents the entire HTML or XML document.

**Key Properties:**

- `documentElement`: Reference to `<html>` element
- `doctype`: DocumentType node (the `<!DOCTYPE>` declaration)
- `head`: Reference to `<head>` element
- `body`: Reference to `<body>` element
- `implementation`: DOMImplementation object
- `URL`: Document location
- `domain`: Document domain
- `characterSet`: Character encoding

**Factory Methods:**

- `createElement(tagName)`: Create element nodes
- `createTextNode(data)`: Create text nodes
- `createComment(data)`: Create comment nodes
- `createDocumentFragment()`: Create document fragments
- `createAttribute(name)`: Create attribute nodes

### DocumentFragment Node (Type 11)

DocumentFragment serves as a lightweight container for grouping nodes without adding extra elements to the DOM tree.

**Key Advantages:**

- Not part of the active DOM tree
- Changes don't trigger reflows/repaints
- When inserted, only its children are added (the fragment itself disappears)
- Minimal memory overhead compared to full Document nodes

**Performance Pattern:**

```javascript
const fragment = document.createDocumentFragment();

for (let i = 0; i < 1000; i++) {
  const div = document.createElement('div');
  div.textContent = `Item ${i}`;
  fragment.appendChild(div); // No reflow yet
}

container.appendChild(fragment); // Single reflow for all 1000 elements
```

### DocumentType Node (Type 10)

Represents the `<!DOCTYPE>` declaration at the beginning of HTML/XML documents.

**Properties:**

- `name`: Document type name (e.g., "html")
- `publicId`: Public identifier
- `systemId`: System identifier
- Accessed via `document.doctype`

**Example:**

```javascript
// <!DOCTYPE html>
console.log(document.doctype.name); // "html"
console.log(document.doctype.publicId); // ""
console.log(document.doctype.systemId); // ""
```

### Attribute Nodes (Type 2)

**[Note: Deprecated]** While attribute nodes technically exist with `nodeType === 2`, they are no longer treated as children of elements in modern DOM specifications (DOM4+).

**Modern Attribute Access:**

- `element.attributes`: Returns NamedNodeMap
- `element.getAttribute(name)`: Get attribute value
- `element.setAttribute(name, value)`: Set attribute
- `element.hasAttribute(name)`: Check existence
- `element.removeAttribute(name)`: Remove attribute

**Attribute Node Structure (when accessed):**

```javascript
const attr = element.attributes[0]; // or element.getAttributeNode('id')
attr.name; // Attribute name
attr.value; // Attribute value
attr.ownerElement; // Element that owns this attribute
```

### ProcessingInstruction Nodes (Type 7)

Used in XML documents for processing instructions like `<?xml-stylesheet ?>`.

**Properties:**

- `target`: Instruction target (first token)
- `data`: Instruction data (everything after target)
- Rare in HTML documents
- Common in XML for stylesheets, transformations

### CDATASection Nodes (Type 4)

XML-specific nodes for character data that should not be parsed as markup.

```xml
<script><![CDATA[
  function example() {
    if (x < 10 && y > 5) { }
  }
]]></script>
```

**Characteristics:**

- Inherits from Text node
- Content is not parsed for markup
- Not used in HTML documents
- `nodeValue` contains the raw CDATA content

### Node Properties and Methods

#### Universal Node Properties

Every node, regardless of type, has these properties:

- `nodeType`: Integer constant identifying node type
- `nodeName`: Name varies by type (tagName for elements, "#text" for text, etc.)
- `nodeValue`: Value varies by type (text content for text nodes, null for elements)
- `parentNode`: Parent node reference
- `childNodes`: Live NodeList of children
- `firstChild` / `lastChild`: First/last child node references
- `previousSibling` / `nextSibling`: Adjacent sibling references
- `ownerDocument`: Reference to containing document

#### Tree Traversal Methods

**Modification:**

- `appendChild(node)`: Add node to end of children
- `insertBefore(newNode, referenceNode)`: Insert before reference
- `removeChild(node)`: Remove child node
- `replaceChild(newNode, oldNode)`: Replace existing child

**Cloning:**

- `cloneNode(deep)`: Create copy (shallow if false, deep if true)

**Comparison:**

- `contains(otherNode)`: Check if node is descendant
- `compareDocumentPosition(otherNode)`: Determine relative position
- `isEqualNode(otherNode)`: Check structural equality
- `isSameNode(otherNode)`: Check reference equality

**Normalization:**

- `normalize()`: Merge adjacent text nodes, remove empty ones

### NodeList vs HTMLCollection

**NodeList:**

- Generic collection of nodes
- Can be live or static depending on creation method
- `document.querySelectorAll()` returns static NodeList
- `childNodes` returns live NodeList
- Indexed access: `nodeList[0]`
- Iterable with `forEach()` in modern browsers

**HTMLCollection:**

- Specifically for element nodes
- Always live (reflects DOM changes)
- `children`, `getElementsByTagName()`, `getElementsByClassName()` return HTMLCollection
- Named item access: `collection.namedItem('id')` or `collection['id']`
- No `forEach()` method (must convert to array or use for-of)

### Live vs Static Collections

**Live Collections:** Automatically update when the DOM changes:

```javascript
const divs = document.getElementsByTagName('div'); // Live
console.log(divs.length); // 5

document.body.appendChild(document.createElement('div'));
console.log(divs.length); // 6 (automatically updated)
```

**Static Collections:** Snapshot at time of creation:

```javascript
const divs = document.querySelectorAll('div'); // Static
console.log(divs.length); // 5

document.body.appendChild(document.createElement('div'));
console.log(divs.length); // 5 (unchanged)
```

### Node Type Checking Patterns

**Type-Safe Traversal:**

```javascript
function getElementChildren(parent) {
  const elements = [];
  for (let node = parent.firstChild; node; node = node.nextSibling) {
    if (node.nodeType === Node.ELEMENT_NODE) {
      elements.push(node);
    }
  }
  return elements;
}
```

**Filtering Non-Element Nodes:**

```javascript
function getTextContent(element) {
  let text = '';
  for (let node of element.childNodes) {
    if (node.nodeType === Node.TEXT_NODE) {
      text += node.nodeValue;
    } else if (node.nodeType === Node.ELEMENT_NODE) {
      text += getTextContent(node); // Recursive
    }
    // Ignore comments, processing instructions, etc.
  }
  return text;
}
```

### Node Type Inheritance and instanceof

Nodes can be tested using `instanceof`:

```javascript
const div = document.createElement('div');

div instanceof Node // true
div instanceof Element // true
div instanceof HTMLElement // true
div instanceof HTMLDivElement // true

const text = document.createTextNode('Hello');
text instanceof Node // true
text instanceof CharacterData // true
text instanceof Text // true
text instanceof Element // false
```

### Memory and Performance Considerations

**NodeList Iteration Performance:** Cache length when iterating live NodeLists:

```javascript
// Inefficient (length recalculated each iteration)
for (let i = 0; i < nodeList.length; i++) { }

// Efficient
const len = nodeList.length;
for (let i = 0; i < len; i++) { }
```

**DocumentFragment for Batch Operations:** [Inference: Based on browser rendering behavior] Reduces reflow/repaint cycles by batching DOM modifications:

```javascript
// Multiple reflows
for (let i = 0; i < 100; i++) {
  container.appendChild(createItem(i)); // Reflow per append
}

// Single reflow
const fragment = document.createDocumentFragment();
for (let i = 0; i < 100; i++) {
  fragment.appendChild(createItem(i));
}
container.appendChild(fragment); // One reflow
```

### Text Node Normalization

Adjacent text nodes can occur after DOM manipulation:

```javascript
const div = document.createElement('div');
div.appendChild(document.createTextNode('Hello '));
div.appendChild(document.createTextNode('World'));

console.log(div.childNodes.length); // 2

div.normalize(); // Merge adjacent text nodes
console.log(div.childNodes.length); // 1
console.log(div.firstChild.nodeValue); // "Hello World"
```

### Shadow DOM and Node Types

Shadow DOM introduces `ShadowRoot` nodes that act as document fragments:

```javascript
const host = document.createElement('div');
const shadowRoot = host.attachShadow({ mode: 'open' });

shadowRoot.nodeType // 11 (DOCUMENT_FRAGMENT_NODE)
shadowRoot instanceof DocumentFragment // true
shadowRoot instanceof ShadowRoot // true
```

Shadow roots encapsulate subtrees and affect node traversal from the outside.

### Node Adoption Across Documents

Nodes belong to specific documents. Moving nodes between documents requires adoption:

```javascript
const iframe = document.querySelector('iframe');
const iframeDoc = iframe.contentDocument;
const div = iframeDoc.createElement('div');

// div belongs to iframe's document
console.log(div.ownerDocument === iframeDoc); // true

// Adopt into main document
const adopted = document.adoptNode(div);
console.log(adopted.ownerDocument === document); // true

// Or import (creates a copy)
const imported = document.importNode(div, true);
```

### Custom Elements and Node Types

Custom elements are still `ELEMENT_NODE` type but extend HTMLElement:

```javascript
class MyElement extends HTMLElement {
  constructor() {
    super();
  }
}

customElements.define('my-element', MyElement);

const elem = document.createElement('my-element');
elem.nodeType // 1 (ELEMENT_NODE)
elem instanceof HTMLElement // true
elem instanceof MyElement // true

// Types of customElements
customElements instanceof CustomElementRegistry // true
typeof customElements // "object"
```

The `customElements` is an instance of `CustomElementRegistry`, which is a global object that provides methods for registering custom elements and querying registered elements. It's available as a property on the `window` object (`window.customElements`).

### Practical Node Type Utilities

**Get All Text Nodes:**

```javascript
function getAllTextNodes(element) {
  const textNodes = [];
  const walker = document.createTreeWalker(
    element,
    NodeFilter.SHOW_TEXT,
    null
  );
  
  let node;
  while (node = walker.nextNode()) {
    textNodes.push(node);
  }
  return textNodes;
}
```

**Remove Comment Nodes:**

```javascript
function removeComments(element) {
  const iterator = document.createNodeIterator(
    element,
    NodeFilter.SHOW_COMMENT
  );
  
  const comments = [];
  let node;
  while (node = iterator.nextNode()) {
    comments.push(node);
  }
  
  comments.forEach(comment => comment.remove());
}
```

**Count Node Types:**

```javascript
function countNodeTypes(element) {
  const counts = {};
  const walker = document.createTreeWalker(
    element,
    NodeFilter.SHOW_ALL
  );
  
  let node;
  while (node = walker.nextNode()) {
    counts[node.nodeType] = (counts[node.nodeType] || 0) + 1;
  }
  return counts;
}
```

---

