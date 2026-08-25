## Node Properties (nodeType, nodeName, nodeValue)


### Core Property Characteristics

The DOM Node interface exposes three fundamental read-only properties that describe every node in the document tree. These properties form the identification triplet that determines how nodes behave and can be manipulated.

### nodeType Property

The `nodeType` property returns an unsigned short integer representing the node's type constant. This enumeration dictates which interfaces the node implements and which properties/methods are available.

**Primary nodeType Constants:**

- `Node.ELEMENT_NODE` (1) - Element nodes like `<div>`, `<p>`, `<span>`
- `Node.ATTRIBUTE_NODE` (2) - Deprecated; attributes are no longer treated as nodes in modern DOM
- `Node.TEXT_NODE` (3) - Text content within elements
- `Node.CDATA_SECTION_NODE` (4) - CDATA sections in XML documents
- `Node.PROCESSING_INSTRUCTION_NODE` (7) - Processing instructions like `<?xml-stylesheet?>`
- `Node.COMMENT_NODE` (8) - HTML/XML comment nodes
- `Node.DOCUMENT_NODE` (9) - The document root itself
- `Node.DOCUMENT_TYPE_NODE` (10) - DOCTYPE declarations
- `Node.DOCUMENT_FRAGMENT_NODE` (11) - DocumentFragment containers

**Practical Usage:**

```javascript
const div = document.querySelector('div');
console.log(div.nodeType); // 1 (ELEMENT_NODE)

const textNode = div.firstChild;
console.log(textNode.nodeType); // 3 (TEXT_NODE)

// Type checking
if (node.nodeType === Node.ELEMENT_NODE) {
  // Safe to access element-specific properties
  console.log(node.tagName);
}
```

The numeric values remain for backward compatibility, but using the named constants improves code readability and maintenance.

### nodeName Property

The `nodeName` property returns a string representing the node's name. The return value format depends on the node type.

**Return Values by Node Type:**

|nodeType|nodeName Returns|
|---|---|
|Element|Uppercase tag name (e.g., "DIV", "SPAN")|
|Text|"#text"|
|Comment|"#comment"|
|Document|"#document"|
|DocumentFragment|"#document-fragment"|
|DocumentType|DOCTYPE name (e.g., "html")|
|Processing Instruction|Target of the instruction|

**Important Distinctions:**

For element nodes, `nodeName` returns uppercase tag names regardless of how they're written in the source HTML. For case-sensitive operations or cleaner string matching, use `tagName` (also uppercase) or `localName` (preserves case).

```javascript
const para = document.querySelector('p');
console.log(para.nodeName); // "P"
console.log(para.localName); // "p"

const textNode = document.createTextNode('Hello');
console.log(textNode.nodeName); // "#text"

const comment = document.createComment('comment text');
console.log(comment.nodeName); // "#comment"
```

### nodeValue Property

The `nodeValue` property is both readable and writable, but its behavior varies dramatically based on node type. For most node types, it returns `null`.

**nodeValue Behavior by Node Type:**

|nodeType|GET Returns|SET Effect|
|---|---|---|
|Element|`null`|No effect|
|Text|Text content|Replaces text content|
|Comment|Comment content|Replaces comment content|
|Document|`null`|No effect|
|DocumentFragment|`null`|No effect|
|Processing Instruction|Entire content excluding target|Replaces content|
|Attribute (deprecated)|Attribute value|Sets attribute value|

**Practical Applications:**

```javascript
// Modifying text content via nodeValue
const textNode = document.createTextNode('Original');
console.log(textNode.nodeValue); // "Original"
textNode.nodeValue = 'Modified';
console.log(textNode.nodeValue); // "Modified"

// Element nodes return null
const div = document.createElement('div');
console.log(div.nodeValue); // null
div.nodeValue = 'Ignored'; // No effect
console.log(div.textContent); // "" (empty)

// Comment manipulation
const comment = document.createComment('old comment');
console.log(comment.nodeValue); // "old comment"
comment.nodeValue = 'new comment';
```

### Property Interdependencies and Edge Cases

**Read-Only vs Writable Behavior:**

While `nodeType` and `nodeName` are strictly read-only, `nodeValue` accepts assignment but silently ignores it for node types where it's not applicable. This differs from throwing errors, which can create subtle bugs if developers assume assignments succeed.

```javascript
const element = document.querySelector('div');
element.nodeValue = "This does nothing"; // Silent failure
console.log(element.nodeValue); // Still null
```

**Performance Considerations:**

Accessing these properties is generally O(1) as they're stored directly on node objects. However, `nodeValue` modifications on text nodes trigger reflow if the text node is in the rendered tree.

### Modern Alternatives and Best Practices

**For Text Content Manipulation:**

Instead of `nodeValue` for text nodes, modern code typically uses:

- `textContent` for element text (concatenates all descendant text)
- `data` property on CharacterData nodes (Text, Comment, CDATASection)

```javascript
// Older approach
const textNode = element.firstChild;
if (textNode.nodeType === Node.TEXT_NODE) {
  textNode.nodeValue = 'New text';
}

// Modern approach
element.textContent = 'New text';

// Or for direct text node manipulation
if (textNode instanceof Text) {
  textNode.data = 'New text';
}
```

**For Type Checking:**

Instead of numeric `nodeType` comparisons, use `instanceof` checks when possible:

```javascript
// Traditional
if (node.nodeType === Node.ELEMENT_NODE) {
  // ...
}

// More semantic
if (node instanceof Element) {
  // Automatically provides type narrowing in TypeScript
  node.classList.add('active');
}
```

### Cross-Browser Consistency

These three properties have near-universal support across browsers since they're part of the DOM Level 1 specification. However, subtle differences exist:

**XML vs HTML Documents:**

In XML documents, `nodeName` preserves case sensitivity, while HTML documents force uppercase for element names.

```javascript
// In XML document
const xmlElement = xmlDoc.createElement('MyElement');
console.log(xmlElement.nodeName); // "MyElement"

// In HTML document
const htmlElement = document.createElement('MyElement');
console.log(htmlElement.nodeName); // "MYELEMENT"
```

**Namespace Handling:**

For elements with namespaces (SVG, MathML), `nodeName` may include the prefix:

```javascript
const svgElement = document.createElementNS('http://www.w3.org/2000/svg', 'svg:circle');
console.log(svgElement.nodeName); // "svg:circle"
console.log(svgElement.localName); // "circle"
console.log(svgElement.prefix); // "svg"
```

### Memory and Mutation Implications

These properties reflect the current state of nodes. Changes to node structure or content update these properties immediately:

```javascript
const div = document.createElement('div');
div.appendChild(document.createTextNode('Hello'));

const textNode = div.firstChild;
console.log(textNode.nodeValue); // "Hello"

// Modifying through nodeValue
textNode.nodeValue = 'World';
console.log(div.textContent); // "World"

// The same text node object persists
console.log(div.firstChild === textNode); // true
```

When nodes are removed from the document, these properties remain accessible but the nodes become "orphaned" until garbage collected.

---

