## Document Object


The Document object represents the entire HTML or XML document loaded in the browser. It serves as the entry point to the DOM tree and provides methods and properties for accessing and manipulating document content.

### Core Properties

#### document.documentElement

Returns the root element of the document (the `<html>` element in HTML documents). This is distinct from `document.body` and provides access to the topmost element in the DOM hierarchy.

#### document.body

References the `<body>` element. Returns `null` if accessed before the body element has been parsed. Can be set to replace the entire body element.

#### document.head

References the `<head>` element. Provides direct access to document metadata, scripts, and stylesheets in the head section.

#### document.title

Gets or sets the document's title as displayed in the browser tab. Modifying this property updates the `<title>` element content.

#### document.URL

Returns the complete URL of the document as a string. This is read-only and reflects the current location.

#### document.domain

Gets or sets the domain portion of the document's origin. Historically used for cross-origin communication between subdomains, though this is deprecated in favor of `postMessage`.

#### document.referrer

Returns the URL of the page that linked to the current page. Empty string if navigated directly or if the referrer was stripped.

#### document.lastModified

Returns the date and time the document was last modified as reported by the server.

#### document.readyState

Returns the loading state of the document:

- `"loading"` - document still loading
- `"interactive"` - document has finished loading but sub-resources are still loading
- `"complete"` - document and all sub-resources have finished loading

#### document.characterSet

Returns the character encoding used by the document (e.g., "UTF-8").

#### document.contentType

Returns the MIME type of the document (e.g., "text/html").

#### document.doctype

Returns the Document Type Declaration (DTD) associated with the document. Returns `null` if no doctype is present.

### Selection and Element Access

#### document.getElementById(id)

Returns the element with the specified ID attribute. Returns `null` if no matching element exists. Most performant selector method since IDs are indexed.

```javascript
const header = document.getElementById('main-header');
```

#### document.getElementsByClassName(className)

Returns a live HTMLCollection of elements with the specified class name. The collection updates automatically when the DOM changes.

```javascript
const buttons = document.getElementsByClassName('btn');
// Returns live collection - changes reflect immediately
```

#### document.getElementsByTagName(tagName)

Returns a live HTMLCollection of elements with the specified tag name. Pass `"*"` to get all elements.

```javascript
const paragraphs = document.getElementsByTagName('p');
const allElements = document.getElementsByTagName('*');
```

#### document.getElementsByName(name)

Returns a live NodeList of elements with the specified `name` attribute. Primarily used for form elements.

```javascript
const radios = document.getElementsByName('gender');
```

#### document.querySelector(selector)

Returns the first element matching the CSS selector. Returns `null` if no match found. Accepts any valid CSS selector syntax.

```javascript
const firstButton = document.querySelector('.btn.primary');
const nestedElement = document.querySelector('div > p:first-child');
```

#### document.querySelectorAll(selector)

Returns a static NodeList of all elements matching the CSS selector. Unlike live collections, this snapshot doesn't update when the DOM changes.

```javascript
const allButtons = document.querySelectorAll('.btn');
// Static NodeList - frozen at query time
```

### Element Creation and Manipulation

#### document.createElement(tagName, options)

Creates a new element node with the specified tag name. The element exists in memory but isn't part of the DOM until inserted.

```javascript
const div = document.createElement('div');
const customElement = document.createElement('my-component', { is: 'custom-element' });
```

#### document.createTextNode(text)

Creates a new text node containing the specified string. Text nodes cannot contain HTML markup.

```javascript
const textNode = document.createTextNode('Hello World');
element.appendChild(textNode);
```

#### document.createDocumentFragment()

Creates an empty DocumentFragment, which serves as a lightweight container for DOM nodes. Operations on fragments don't trigger reflows, making them efficient for batch DOM operations.

```javascript
const fragment = document.createDocumentFragment();
for (let i = 0; i < 1000; i++) {
  const li = document.createElement('li');
  fragment.appendChild(li);
}
container.appendChild(fragment); // Single reflow
```

#### document.createComment(data)

Creates a comment node with the specified text content.

```javascript
const comment = document.createComment('TODO: refactor this section');
```

#### document.createAttribute(name)

Creates an attribute node that can be set on elements. Modern practice favors `element.setAttribute()` instead.

#### document.importNode(externalNode, deep)

Imports a node from another document. The `deep` parameter determines whether to clone descendants. Required when moving nodes between documents.

```javascript
const nodeFromIframe = iframe.contentDocument.querySelector('.item');
const imported = document.importNode(nodeFromIframe, true);
```

#### document.adoptNode(externalNode)

Transfers a node from another document, removing it from its original document. Unlike `importNode`, this doesn't create a copy.

### Document Writing Methods

#### document.write(markup)

Writes HTML markup directly to the document stream. If called after page load, overwrites the entire document. Generally discouraged in modern development due to performance and security concerns.

```javascript
document.write('<p>This text appears in the document</p>');
```

#### document.writeln(markup)

Identical to `document.write()` but adds a newline character after the content.

#### document.open()

Opens the document stream for writing. Clears the current document content if called after page load.

#### document.close()

Closes the document stream opened by `document.open()`. Triggers the `DOMContentLoaded` event.

### Form Access

#### document.forms

Returns an HTMLCollection of all `<form>` elements in the document. Forms can be accessed by index or by their `name` or `id` attributes.

```javascript
const firstForm = document.forms[0];
const loginForm = document.forms['login'];
const namedForm = document.forms.namedItem('registration');
```

### Image Access

#### document.images

Returns an HTMLCollection of all `<img>` elements in the document.

### Link Access

#### document.links

Returns an HTMLCollection of all `<a>` and `<area>` elements with an `href` attribute.

#### document.anchors

Returns an HTMLCollection of all `<a>` elements with a `name` attribute. This is deprecated; use `id` attributes instead.

### Script Access

#### document.scripts

Returns an HTMLCollection of all `<script>` elements in the document.

### Style and CSS

#### document.styleSheets

Returns a StyleSheetList of all stylesheets explicitly linked or embedded in the document.

```javascript
for (let sheet of document.styleSheets) {
  console.log(sheet.href || 'inline styles');
}
```

#### document.createStyleSheet() [IE only, deprecated]

Internet Explorer-specific method for creating stylesheets programmatically.

### Document Events

#### document.addEventListener(type, listener, options)

Registers an event listener on the document. Document-level listeners capture events from the entire page through bubbling or capturing.

```javascript
document.addEventListener('click', (e) => {
  console.log('Clicked element:', e.target);
});

// Capture phase
document.addEventListener('focus', handler, { capture: true });
```

#### document.removeEventListener(type, listener, options)

Removes a previously registered event listener. The listener reference must match exactly.

#### Common Document Events

- `DOMContentLoaded` - Fired when HTML is parsed and DOM is ready (before images/stylesheets load)
- `readystatechange` - Fired when `document.readyState` changes
- `visibilitychange` - Fired when page visibility changes (tab switching, minimizing)
- `scroll` - Fired when document is scrolled
- `selectionchange` - Fired when text selection changes

### Focus Management

#### document.activeElement

Returns the element currently in focus. Returns `<body>` if no element has focus.

```javascript
console.log(document.activeElement); // Currently focused element
```

#### document.hasFocus()

Returns `true` if the document or any element within it has focus.

```javascript
if (document.hasFocus()) {
  // Document is in foreground
}
```

### Visibility API

#### document.hidden

Returns `true` if the page is hidden (minimized, background tab, etc.). Part of the Page Visibility API.

#### document.visibilityState

Returns the visibility state:

- `"visible"` - page content is at least partially visible
- `"hidden"` - page is not visible to the user

```javascript
document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    pauseVideo();
  } else {
    resumeVideo();
  }
});
```

### Cookie Management

#### document.cookie

Gets or sets cookies associated with the document. Returns a semicolon-separated string of all cookies. Setting this property adds or updates a cookie.

```javascript
// Get all cookies
const cookies = document.cookie;

// Set a cookie
document.cookie = "username=john; expires=Fri, 31 Dec 2024 23:59:59 GMT; path=/";

// Set with additional flags
document.cookie = "session=abc123; secure; samesite=strict";
```

### Full-Screen API

#### document.fullscreenElement

Returns the element currently displayed in fullscreen mode, or `null` if not in fullscreen.

#### document.exitFullscreen()

Exits fullscreen mode. Returns a Promise that resolves when fullscreen is exited.

```javascript
if (document.fullscreenElement) {
  document.exitFullscreen();
}
```

#### document.fullscreenEnabled

Returns `true` if fullscreen mode is available and can be activated.

### Document Position and Scrolling

#### document.documentElement.scrollTop

Gets or sets the vertical scroll position of the document. For cross-browser compatibility, check both `document.documentElement.scrollTop` and `document.body.scrollTop`.

```javascript
// Get scroll position
const scrollY = document.documentElement.scrollTop || document.body.scrollTop;

// Set scroll position
document.documentElement.scrollTop = 0; // Scroll to top
```

#### document.documentElement.scrollHeight

Returns the total scrollable height of the document, including content not visible on screen.

#### document.documentElement.clientHeight

Returns the visible height of the document viewport (without scrollbars).

### Range and Selection

#### document.createRange()

Creates a Range object representing a fragment of the document. Used for text selection and manipulation.

```javascript
const range = document.createRange();
range.selectNodeContents(element);
```

#### document.getSelection()

Returns a Selection object representing the text selected by the user or the current position of the cursor.

```javascript
const selection = document.getSelection();
const selectedText = selection.toString();
```

### Deprecated Properties and Methods

[Unverified: Browser support status may vary]

#### document.all

Legacy collection of all elements. Deprecated; use `document.querySelectorAll('*')` instead.

#### document.alinkColor, document.linkColor, document.vlinkColor

Deprecated properties for link colors. Use CSS instead.

#### document.bgColor, document.fgColor

Deprecated properties for background and foreground colors. Use CSS instead.

#### document.clear()

Deprecated method that did nothing in modern browsers.

### Implementation Notes

**HTMLCollection vs NodeList**

- HTMLCollection: Live, contains only Element nodes, accessible by name/id
- NodeList: Can be live or static, contains any node type, array-like iteration

**Performance Considerations**

- Live collections (HTMLCollection, live NodeList) re-query the DOM on every access
- Static NodeLists from `querySelectorAll()` are more performant for iteration
- `getElementById()` is faster than `querySelector('#id')` due to internal indexing
- DocumentFragments prevent multiple reflows during batch insertions

**Security Considerations**

- `document.write()` can enable XSS attacks and breaks page caching
- `document.cookie` provides no CSRF protection; use httpOnly cookies for sensitive data
- Same-origin policy restricts access to documents from different origins

---

