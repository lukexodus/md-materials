## DOM Tree Structure


### Hierarchical Organization

The DOM represents an HTML document as a tree of nodes where each element, attribute, text fragment, and comment becomes a node object. The `document` node serves as the root, with `<html>` as its child, branching downward through `<head>` and `<body>`, and continuing through all nested elements.

Each node maintains references to its parent, children, and siblings, creating a navigable graph structure. The `parentNode`, `childNodes`, `firstChild`, `lastChild`, `previousSibling`, and `nextSibling` properties enable traversal in any direction through the tree.

### Node Types and Interfaces

The DOM defines twelve node types, each with a numeric constant:

- **ELEMENT_NODE (1)**: Represents HTML elements (`<div>`, `<p>`, etc.)
- **ATTRIBUTE_NODE (2)**: Represents element attributes (deprecated in DOM4, attributes now accessed via properties)
- **TEXT_NODE (3)**: Contains text content between tags
- **CDATA_SECTION_NODE (4)**: Contains CDATA sections (XML documents)
- **PROCESSING_INSTRUCTION_NODE (7)**: Processing instructions like `<?xml-stylesheet?>`
- **COMMENT_NODE (8)**: Represents HTML comments
- **DOCUMENT_NODE (9)**: The document root
- **DOCUMENT_TYPE_NODE (10)**: The DOCTYPE declaration
- **DOCUMENT_FRAGMENT_NODE (11)**: Lightweight container for DOM manipulation

Each node type implements specific interfaces. `Element` nodes inherit from `Node` and add properties like `tagName`, `className`, `id`, and methods like `getAttribute()`, `setAttribute()`, `classList`. `Text` nodes inherit from `CharacterData`, providing `data`, `length`, and text manipulation methods.

### Parent-Child Relationships

Nodes form parent-child relationships following HTML nesting rules. A parent node's `childNodes` property returns a live `NodeList` containing all children in document order. `children` provides an `HTMLCollection` containing only element children, excluding text and comment nodes.

The `hasChildNodes()` method checks for children, while `contains()` determines if a node is a descendant. `appendChild()`, `insertBefore()`, `removeChild()`, and `replaceChild()` modify the tree structure, automatically updating all relationships and triggering reflows.

### Element Node Properties

Element nodes expose numerous properties for inspection and manipulation:

- **Identity**: `nodeName` (uppercase tag name), `tagName` (identical to nodeName for elements), `localName` (lowercase tag name)
- **Classification**: `nodeType` (always 1 for elements), `nodeValue` (always null for elements)
- **Attributes**: `attributes` (NamedNodeMap), `id`, `className`, `classList` (DOMTokenList)
- **Content**: `innerHTML`, `outerHTML`, `textContent`, `innerText`
- **Position**: `offsetParent`, `offsetTop`, `offsetLeft`, `clientTop`, `clientLeft`

### Text Nodes and Whitespace

Text nodes contain character data between element tags. Browsers create text nodes for all text, including whitespace from formatting. This means:

```html
<div>
  <span>Text</span>
</div>
```

Creates five nodes: the `div` element, a text node with whitespace, the `span` element, a text node with "Text", and another whitespace text node. Adjacent text nodes can be consolidated using `normalize()`.

The `textContent` property recursively concatenates all descendant text nodes, while `innerText` respects CSS styling and visibility, excluding hidden content and accounting for line breaks from block elements.

### Document Fragments

`DocumentFragment` nodes serve as lightweight containers that hold multiple nodes without a parent. When a fragment is inserted into the DOM, only its children are inserted, not the fragment itself. This enables batch DOM operations with a single reflow:

```javascript
const fragment = document.createDocumentFragment();
for (let i = 0; i < 1000; i++) {
  const div = document.createElement('div');
  fragment.appendChild(div);
}
document.body.appendChild(fragment); // Single reflow
```

### Live vs Static Collections

The DOM returns two types of collections:

**NodeList**: Returned by `childNodes` and `querySelectorAll()`. The former is live (updates automatically when the DOM changes), the latter is static (snapshot at query time).

**HTMLCollection**: Returned by `children`, `getElementsByTagName()`, `getElementsByClassName()`. Always live, reflecting DOM changes immediately. Accessing by index or name remains valid even as elements are added/removed.

Live collections can cause issues in loops if modifications occur during iteration:

```javascript
const divs = document.getElementsByTagName('div');
for (let i = 0; i < divs.length; i++) {
  document.body.appendChild(divs[i]); // Moves elements, changes collection
}
```

### Shadow DOM and Encapsulation

Shadow DOM creates isolated subtrees attached to elements via `attachShadow()`. The shadow root becomes a document fragment-like node with its own tree structure, isolated from the main document's CSS and JavaScript.

Shadow trees have shadow hosts (the element they're attached to) and can contain slots for content distribution. `mode: 'open'` allows external access via `element.shadowRoot`, while `mode: 'closed'` prevents external access [Inference: though the reference can still be captured during creation].

Multiple shadow trees can exist on a page, each maintaining separate DOM tree structures with their own node hierarchies, but all ultimately rendering within the same document.

### Tree Modification Performance

DOM modifications trigger reflows and repaints. Each structural change potentially invalidates layout calculations for ancestor and descendant nodes. Operations that minimize tree modifications:

- **Batch modifications**: Use `DocumentFragment` or build HTML strings with `innerHTML`
- **Detach-modify-reattach**: Remove elements during complex modifications using `removeChild()`, modify them, then reinsert
- **Clone deeply**: Use `cloneNode(true)` for duplicating entire subtrees instead of rebuilding manually
- **CSS classes**: Toggle `className` or `classList` instead of modifying individual style properties

[Inference: Layout thrashing occurs when reading layout properties (offsetHeight, getBoundingClientRect) immediately after modifications, forcing synchronous reflows].

### Traversal APIs

Beyond direct property access, the DOM provides traversal interfaces:

**TreeWalker**: Created via `document.createTreeWalker()`, provides `nextNode()`, `previousNode()`, `firstChild()`, `lastChild()`, `parentNode()`, `nextSibling()`, `previousSibling()` methods with filtering capabilities. The `whatToShow` bitmask controls which node types are visited, and `filter` enables custom acceptance logic.

**NodeIterator**: Created via `document.createNodeIterator()`, offers simpler forward/backward iteration with `nextNode()` and `previousNode()`. Unlike TreeWalker, it maintains a reference position that updates automatically when nodes are removed from the tree.

Both APIs accept `NodeFilter` callbacks for fine-grained control over traversal, returning `FILTER_ACCEPT`, `FILTER_REJECT`, or `FILTER_SKIP` to control iteration behavior.

### Mutation Observation

`MutationObserver` monitors DOM tree changes asynchronously. Observers register interest in specific mutation types:

- `childList`: Child node additions/removals
- `attributes`: Attribute modifications
- `characterData`: Text content changes
- `subtree`: Apply observation to all descendants

The observer callback receives `MutationRecord` objects describing each change, including `type`, `target`, `addedNodes`, `removedNodes`, `attributeName`, `oldValue`, and other context. This enables reactive patterns without polling or synchronous event handlers that could impact performance.

### Node Comparison and Position

The `compareDocumentPosition()` method returns a bitmask indicating the relative position of two nodes:

- `DOCUMENT_POSITION_DISCONNECTED` (1): Nodes in different documents
- `DOCUMENT_POSITION_PRECEDING` (2): Other node precedes this node
- `DOCUMENT_POSITION_FOLLOWING` (4): Other node follows this node
- `DOCUMENT_POSITION_CONTAINS` (8): Other node contains this node
- `DOCUMENT_POSITION_CONTAINED_BY` (16): This node contains other node
- `DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC` (32): Implementation-specific ordering

`isSameNode()` checks reference equality, while `isEqualNode()` performs deep comparison of node trees, checking tag names, attributes, and descendant structure.

---

