## Understanding DOM Terms and Naming Patterns


### Core DOM Terminology

#### Document Object Model (DOM)
The DOM is a programming interface that represents HTML/XML documents as a tree structure where each element, attribute, and text becomes a node that can be accessed and manipulated.

#### Key Terms

**Node** - The fundamental unit in the DOM. Everything is a node: elements, text, attributes, comments.

**Element** - A specific type of node representing HTML tags (like `<div>`, `<p>`, `<span>`).

**Attribute** - Properties of elements (like `class`, `id`, `src`).

**Parent/Child/Sibling** - Relationships between nodes:
- Parent: the node containing another node
- Child: a node contained within another
- Sibling: nodes sharing the same parent

**Document** - The root object representing the entire HTML document. Accessed via `document`.

**Window** - The browser window object containing the document. The global object in browser JavaScript.

**NodeList** - A collection of nodes, similar to an array but not exactly an array. Returned by methods like `querySelectorAll()`.

**HTMLCollection** - A live collection of elements that updates automatically when the DOM changes. Returned by methods like `getElementsByClassName()`.

**Event** - An action or occurrence (click, keypress, load) that can be detected and handled.

**Event Listener** - A function that waits for and responds to specific events.

**Event Target** - The object that triggered an event.

**Event Bubbling** - When an event propagates from the target element up through its ancestors.

**Event Capturing** - When an event propagates from the root down to the target element (opposite of bubbling).

---

### DOM Naming Patterns and Standards

### Selection Methods Pattern

These follow a clear pattern based on **what** they select and **how many** they return:

**Pattern: `getElement[s]By[Criterion]()`**

- **Singular (`getElement`)** = returns ONE element (or null)
- **Plural (`getElements`)** = returns a COLLECTION

Examples:
- `getElementById()` - returns one element by ID
- `getElementsByClassName()` - returns collection by class name
- `getElementsByTagName()` - returns collection by tag name

**Pattern: `querySelector[All]()`**

- `querySelector()` - returns the FIRST matching element
- `querySelectorAll()` - returns ALL matching elements (NodeList)

**Memory aid**: "query" means search, "All" means get everything that matches.

#### Property Naming Patterns

**Pattern: `inner[Type]`**
- `innerHTML` - the HTML content inside an element
- `innerText` - the visible text inside an element
- `textContent` - all text content (including hidden)

**Pattern: `[property]Name`**
- `className` - the class attribute
- `tagName` - the tag type (DIV, P, etc.)
- `nodeName` - the name of the node

**Pattern: `[direction]Sibling` or `[direction]Child`**
- `nextSibling` / `previousSibling` - adjacent nodes
- `nextElementSibling` / `previousElementSibling` - adjacent elements only
- `firstChild` / `lastChild` - first/last child node
- `firstElementChild` / `lastElementChild` - first/last child element

**Memory aid**: "Element" in the name means it skips text nodes and only gets element nodes.

#### Manipulation Method Patterns

**Pattern: `create[Type]()`**
- `createElement()` - creates a new element node
- `createTextNode()` - creates a new text node
- `createDocumentFragment()` - creates a fragment container

**Pattern: `append[Something]()` or `[action]Child()`**
- `appendChild()` - adds a child to the end
- `removeChild()` - removes a child
- `replaceChild()` - replaces one child with another
- `insertBefore()` - inserts before a reference node

**Modern alternatives**:
- `append()` - can add multiple nodes/strings at once
- `prepend()` - adds to the beginning
- `remove()` - removes the element itself
- `replaceWith()` - replaces the element itself

**Memory aid**: Methods with "Child" require a parent context. Modern methods work on the element itself.

#### Attribute Method Patterns

**Pattern: `[action]Attribute()`**
- `getAttribute(name)` - gets an attribute value
- `setAttribute(name, value)` - sets an attribute
- `removeAttribute(name)` - removes an attribute
- `hasAttribute(name)` - checks if attribute exists

#### Class Manipulation Pattern

**Pattern: `classList.[action]()`**
- `classList.add()` - adds classes
- `classList.remove()` - removes classes
- `classList.toggle()` - adds if absent, removes if present
- `classList.contains()` - checks if class exists

**Memory aid**: "List" indicates you're working with a collection of classes.

#### Event Method Patterns

**Pattern: `[action]EventListener()`**
- `addEventListener(type, handler)` - attaches an event listener
- `removeEventListener(type, handler)` - removes an event listener

**Pattern: `on[eventtype]` (older style)**
- `onclick` - click event property
- `onload` - load event property
- `onsubmit` - submit event property

**Memory aid**: `addEventListener` is preferred because it allows multiple listeners and better control.

#### Style Property Pattern

**Pattern: camelCase for CSS properties**
- CSS: `background-color` → DOM: `backgroundColor`
- CSS: `font-size` → DOM: `fontSize`
- CSS: `z-index` → DOM: `zIndex`

**Memory aid**: Remove hyphens and capitalize the next letter.

---

### Retention Strategies

#### Mental Model: "Get, Create, Modify, Remove"

1. **Get** (Selection): `get...`, `query...`
2. **Create**: `create...`
3. **Modify**: `set...`, `append...`, `insert...`, properties
4. **Remove**: `remove...`

#### Singular vs Plural Rule

- If it says "Elements" (plural) or "All" → you get multiple items
- If it says "Element" (singular) or no qualifier → you get one item

#### Direction Words

- `next` = forward in the DOM
- `previous` = backward in the DOM 
- `first` = the beginning
- `last` = the end
- `parent` = up one level
- `child` = down one level

#### "Element" Keyword Rule

If a method/property contains "Element", it works specifically with element nodes and skips text/comment nodes. Without "Element", it works with all node types.

Examples:
- `firstChild` (any node) vs `firstElementChild` (only elements)
- `nextSibling` (any node) vs `nextElementSibling` (only elements)

This systematic understanding should help you predict method names and remember them more easily based on what you're trying to accomplish.

---

