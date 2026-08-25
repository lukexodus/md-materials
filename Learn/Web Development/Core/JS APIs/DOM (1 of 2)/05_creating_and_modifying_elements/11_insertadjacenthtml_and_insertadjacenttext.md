## insertAdjacentHTML and insertAdjacentText


### insertAdjacentHTML Method

#### Method Signature and Purpose

`insertAdjacentHTML()` parses specified HTML or XML string and inserts the resulting nodes into the DOM tree at a specified position relative to the target element.

```javascript
element.insertAdjacentHTML(position, text)
```

**Parameters**:

- `position`: String indicating where to insert the HTML relative to the element
- `text`: String to be parsed as HTML/XML and inserted into the tree

**Return Value**: `undefined`

#### Position Values

**Four Valid Position Strings**:

**`'beforebegin'`** - Before the element itself:

```javascript
<!-- beforebegin -->
<div id="target">
  existing content
</div>

element.insertAdjacentHTML('beforebegin', '<p>Before element</p>');

// Result:
<p>Before element</p>
<div id="target">
  existing content
</div>
```

**`'afterbegin'`** - Inside the element, before its first child:

```javascript
<div id="target">
  <!-- afterbegin -->
  existing content
</div>

element.insertAdjacentHTML('afterbegin', '<p>First child</p>');

// Result:
<div id="target">
  <p>First child</p>
  existing content
</div>
```

**`'beforeend'`** - Inside the element, after its last child:

```javascript
<div id="target">
  existing content
  <!-- beforeend -->
</div>

element.insertAdjacentHTML('beforeend', '<p>Last child</p>');

// Result:
<div id="target">
  existing content
  <p>Last child</p>
</div>
```

**`'afterend'`** - After the element itself:

```javascript
<div id="target">
  existing content
</div>
<!-- afterend -->

element.insertAdjacentHTML('afterend', '<p>After element</p>');

// Result:
<div id="target">
  existing content
</div>
<p>After element</p>
```

#### Position Restrictions and Behavior

**Parent Node Requirements**:

```javascript
const element = document.createElement('div');
// Element not in DOM, has no parent

element.insertAdjacentHTML('beforebegin', '<p>Test</p>'); 
// Throws DOMException: NoModificationAllowedError

element.insertAdjacentHTML('afterend', '<p>Test</p>'); 
// Throws DOMException: NoModificationAllowedError

// 'afterbegin' and 'beforeend' work without parent
element.insertAdjacentHTML('afterbegin', '<p>Test</p>'); // Works
element.insertAdjacentHTML('beforeend', '<p>Test</p>'); // Works
```

**Document and DocumentFragment Restrictions**:

```javascript
const doc = document.implementation.createHTMLDocument();
doc.insertAdjacentHTML('beforebegin', '<div>Test</div>'); 
// Throws DOMException (document has no parent)

const fragment = document.createDocumentFragment();
fragment.insertAdjacentHTML('afterbegin', '<div>Test</div>'); 
// Throws DOMException (fragment doesn't support this method)
```

#### HTML Parsing Behavior

**Context-Sensitive Parsing**:

```javascript
// Parsing context affects what's valid
const table = document.querySelector('table');
table.insertAdjacentHTML('beforeend', '<tr><td>Cell</td></tr>');
// Parsed in table context - creates valid table row

const div = document.querySelector('div');
div.insertAdjacentHTML('beforeend', '<tr><td>Cell</td></tr>');
// Parsed in div context - browser may fix/reject invalid nesting
```

**Self-Closing Tags**:

```javascript
element.insertAdjacentHTML('beforeend', '<img src="test.jpg">');
// Works - self-closing tags properly handled

element.insertAdjacentHTML('beforeend', '<img src="test.jpg"></img>');
// Also works - closing tag ignored for void elements
```

**Malformed HTML Handling**:

```javascript
// Browser attempts error correction
element.insertAdjacentHTML('beforeend', '<div><p>Text</div></p>');
// Browser corrects nesting - actual result varies by browser
// [Inference: HTML5 parsing algorithm defines specific error correction rules]

element.insertAdjacentHTML('beforeend', '<div>Unclosed');
// Browser auto-closes the div
```

**Multiple Root Elements**:

```javascript
element.insertAdjacentHTML('beforeend', '<div>One</div><div>Two</div><span>Three</span>');
// All elements inserted as siblings within the parent
```

**Text Nodes and Mixed Content**:

```javascript
element.insertAdjacentHTML('beforeend', 'Plain text <strong>Bold</strong> more text');
// Creates text nodes and element nodes as appropriate
```

#### Script Execution Behavior

**Scripts Don't Execute**:

```javascript
element.insertAdjacentHTML('beforeend', '<script>alert("test");</script>');
// Script is inserted into DOM but does NOT execute
// This is a security feature

element.insertAdjacentHTML('beforeend', '<script src="external.js"></script>');
// External script also doesn't execute
```

**Event Handlers in HTML**:

```javascript
element.insertAdjacentHTML('beforeend', '<button onclick="handleClick()">Click</button>');
// Inline event handlers ARE attached and WILL execute when triggered
// [Inference: Inline event handlers are treated as element attributes, not script execution]
```

**Workaround for Script Execution**:

```javascript
element.insertAdjacentHTML('beforeend', '<div id="container"></div>');
const script = document.createElement('script');
script.textContent = 'console.log("Executes");';
document.getElementById('container').appendChild(script);
// Manually created scripts do execute
```

#### Performance Characteristics

**Faster Than createElement Chains**:

```javascript
// Slower approach
for (let i = 0; i < 100; i++) {
  const div = document.createElement('div');
  div.className = 'item';
  div.textContent = `Item ${i}`;
  container.appendChild(div);
}

// Faster approach
let html = '';
for (let i = 0; i < 100; i++) {
  html += `<div class="item">Item ${i}</div>`;
}
container.insertAdjacentHTML('beforeend', html);
```

**Single Reflow for Multiple Elements**:

```javascript
// Multiple reflows
element.insertAdjacentHTML('beforeend', '<div>1</div>');
element.insertAdjacentHTML('beforeend', '<div>2</div>');
element.insertAdjacentHTML('beforeend', '<div>3</div>');

// Single reflow
element.insertAdjacentHTML('beforeend', '<div>1</div><div>2</div><div>3</div>');
```

**Memory Efficiency Considerations**:

```javascript
// Building large HTML strings in memory
let html = '';
for (let i = 0; i < 10000; i++) {
  html += `<div>${i}</div>`; // String concatenation creates many intermediate strings
}

// More memory efficient
const parts = [];
for (let i = 0; i < 10000; i++) {
  parts.push(`<div>${i}</div>`);
}
const html = parts.join('');
element.insertAdjacentHTML('beforeend', html);
```

#### Security Considerations

**XSS Vulnerability**:

```javascript
// DANGEROUS - user input directly inserted
const userInput = getUserInput();
element.insertAdjacentHTML('beforeend', `<div>${userInput}</div>`);
// If userInput contains "<script>malicious()</script>" or "<img src=x onerror=malicious()>"
// the HTML is parsed and inline handlers execute
```

**Sanitization Requirements**:

```javascript
// Escaping HTML entities
function escapeHTML(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}

const userInput = getUserInput();
element.insertAdjacentHTML('beforeend', `<div>${escapeHTML(userInput)}</div>`);
```

**Using DOMPurify or Similar**:

```javascript
// Library-based sanitization
const dirty = getUserInput();
const clean = DOMPurify.sanitize(dirty);
element.insertAdjacentHTML('beforeend', clean);
```

**Safer Alternative with insertAdjacentText**:

```javascript
// For pure text content, use insertAdjacentText
const userInput = getUserInput();
element.insertAdjacentText('beforeend', userInput);
// No HTML parsing - completely safe from XSS
```

#### Common Patterns and Use Cases

**Building Lists**:

```javascript
const items = ['Apple', 'Banana', 'Orange'];
const list = document.querySelector('ul');

items.forEach(item => {
  list.insertAdjacentHTML('beforeend', `<li>${item}</li>`);
});
```

**Template String Integration**:

```javascript
const data = {
  name: 'John Doe',
  age: 30,
  email: 'john@example.com'
};

element.insertAdjacentHTML('beforeend', `
  <div class="user-card">
    <h3>${escapeHTML(data.name)}</h3>
    <p>Age: ${data.age}</p>
    <p>Email: ${escapeHTML(data.email)}</p>
  </div>
`);
```

**Conditional Content**:

```javascript
const hasPermission = checkPermission();

element.insertAdjacentHTML('beforeend', `
  <div class="content">
    <p>Public content</p>
    ${hasPermission ? '<p>Private content</p>' : ''}
  </div>
`);
```

**Prepending Content**:

```javascript
// Add to beginning of list
list.insertAdjacentHTML('afterbegin', '<li class="new-item">New First Item</li>');
```

**Wrapping Elements**:

```javascript
// Insert wrapper before element
element.insertAdjacentHTML('beforebegin', '<div class="wrapper">');
// Insert closing tag after element
element.insertAdjacentHTML('afterend', '</div>');
// Note: This creates malformed HTML temporarily and relies on browser correction
// [Unverified: Reliability of this pattern across all browsers and contexts]
```

**Sibling Insertion**:

```javascript
const targetElement = document.querySelector('.target');
targetElement.insertAdjacentHTML('afterend', '<div class="sibling">Next sibling</div>');
```

#### Error Handling

**Invalid Position Parameter**:

```javascript
try {
  element.insertAdjacentHTML('invalid', '<div>Test</div>');
} catch (e) {
  console.error(e); // DOMException: Failed to execute 'insertAdjacentHTML'
}
```

**Invalid HTML Syntax**:

```javascript
// Browser attempts to fix, but may produce unexpected results
element.insertAdjacentHTML('beforeend', '<div><span></div></span>');
// No error thrown, but structure may not match intent
```

**Null or Undefined HTML**:

```javascript
element.insertAdjacentHTML('beforeend', null); // Inserts string "null"
element.insertAdjacentHTML('beforeend', undefined); // Inserts string "undefined"
element.insertAdjacentHTML('beforeend', ''); // Inserts nothing (no-op)
```

#### Browser Compatibility

- **IE11+**: Full support
- **Edge 12+**: Full support
- **Chrome 1+**: Full support
- **Firefox 8+**: Full support
- **Safari 4+**: Full support
- **Opera 7+**: Full support

Position parameter is case-insensitive in most browsers but lowercase is recommended for consistency.

### insertAdjacentText Method

#### Method Signature and Purpose

`insertAdjacentText()` inserts a given text node at a specified position relative to the target element. Unlike `insertAdjacentHTML()`, the text is **not** parsed as HTML - it's inserted as literal text.

```javascript
element.insertAdjacentText(position, text)
```

**Parameters**:

- `position`: Same four position strings as `insertAdjacentHTML`
- `text`: String to be inserted as a text node

**Return Value**: `undefined`

#### Position Values (Same as insertAdjacentHTML)

```javascript
// beforebegin - before the element
element.insertAdjacentText('beforebegin', 'Before element text');

// afterbegin - first child
element.insertAdjacentText('afterbegin', 'First child text');

// beforeend - last child
element.insertAdjacentText('beforeend', 'Last child text');

// afterend - after the element
element.insertAdjacentText('afterend', 'After element text');
```

#### Core Behavior and Differences from insertAdjacentHTML

**No HTML Parsing**:

```javascript
const html = '<strong>Bold</strong> text';

element.insertAdjacentHTML('beforeend', html);
// Result: Bold text (with <strong> parsed as HTML)

element.insertAdjacentText('beforeend', html);
// Result: <strong>Bold</strong> text (literal text, tags visible)
```

**Automatic Escaping**:

```javascript
const userInput = '<script>alert("XSS")</script>';

element.insertAdjacentText('beforeend', userInput);
// Inserted as literal text: <script>alert("XSS")</script>
// Completely safe - no script execution, no HTML parsing
```

**Text Node Creation**:

```javascript
element.insertAdjacentText('beforeend', 'Hello World');
// Creates a Text node with nodeValue "Hello World"
// Equivalent to:
const textNode = document.createTextNode('Hello World');
element.appendChild(textNode);
```

**Multiple Text Insertions**:

```javascript
element.insertAdjacentText('beforeend', 'First ');
element.insertAdjacentText('beforeend', 'Second ');
element.insertAdjacentText('beforeend', 'Third');
// Creates three separate text nodes
// Browser may normalize these into single text node later
```

#### Security Benefits

**XSS Prevention**:

```javascript
// SAFE - no XSS risk regardless of input
const maliciousInput = '<img src=x onerror=alert("XSS")>';
element.insertAdjacentText('beforeend', maliciousInput);
// Displays literal text: <img src=x onerror=alert("XSS")>
// No image element created, no script executed
```

**No Sanitization Required**:

```javascript
// With insertAdjacentHTML - requires sanitization
const userComment = getUserInput();
element.insertAdjacentHTML('beforeend', `<p>${escapeHTML(userComment)}</p>`);

// With insertAdjacentText - no sanitization needed
element.insertAdjacentText('beforeend', userComment);
// However, this doesn't create the <p> wrapper
```

**Use Case Comparison**:

```javascript
// When you need structure: use insertAdjacentHTML with sanitization
const safeHTML = DOMPurify.sanitize(`<div class="comment">${userInput}</div>`);
element.insertAdjacentHTML('beforeend', safeHTML);

// When you only need text content: use insertAdjacentText
const wrapper = document.createElement('div');
wrapper.className = 'comment';
wrapper.insertAdjacentText('beforeend', userInput);
element.appendChild(wrapper);
```

#### Performance Characteristics

**Faster for Plain Text**:

```javascript
// Slower - invokes HTML parser
element.insertAdjacentHTML('beforeend', 'Plain text content');

// Faster - direct text node creation
element.insertAdjacentText('beforeend', 'Plain text content');
```

**Batch Text Insertion**:

```javascript
// Multiple separate text nodes (less efficient)
for (let i = 0; i < 1000; i++) {
  element.insertAdjacentText('beforeend', `Item ${i} `);
}

// Single text node (more efficient)
let text = '';
for (let i = 0; i < 1000; i++) {
  text += `Item ${i} `;
}
element.insertAdjacentText('beforeend', text);
```

#### Text Node Behavior

**Whitespace Handling**:

```javascript
element.insertAdjacentText('beforeend', '   Text with spaces   ');
// Preserves all whitespace - creates text node with exact content
// CSS white-space property controls rendering
```

**Line Breaks**:

```javascript
element.insertAdjacentText('beforeend', 'Line 1\nLine 2\nLine 3');
// Newlines preserved in text node
// Rendered as single line unless CSS white-space: pre or similar
```

**Special Characters**:

```javascript
element.insertAdjacentText('beforeend', 'Text with © ™ € symbols');
// All Unicode characters preserved exactly
```

**Empty String**:

```javascript
element.insertAdjacentText('beforeend', '');
// Creates empty text node (may be optimized away by browser)
```

#### Common Use Cases

**User-Generated Content Display**:

```javascript
function displayComment(username, comment) {
  const container = document.createElement('div');
  container.className = 'comment';
  
  const userSpan = document.createElement('span');
  userSpan.className = 'username';
  userSpan.insertAdjacentText('beforeend', username);
  
  const commentSpan = document.createElement('span');
  commentSpan.className = 'comment-text';
  commentSpan.insertAdjacentText('beforeend', comment);
  
  container.appendChild(userSpan);
  container.appendChild(commentSpan);
  return container;
}
```

**Label and Text Combination**:

```javascript
const label = document.querySelector('label');
label.insertAdjacentText('beforeend', ': ');
// Appends colon to label text
```

**Dynamic Text Updates**:

```javascript
const counter = document.querySelector('.counter');
// Clear existing text
counter.textContent = '';
// Add new text
counter.insertAdjacentText('beforeend', `Count: ${count}`);
```

**Prepending Text**:

```javascript
element.insertAdjacentText('afterbegin', 'Prefix: ');
// Adds text before existing content
```

#### Position Restrictions (Same as insertAdjacentHTML)

```javascript
const detached = document.createElement('div');

// These throw DOMException (no parent node)
detached.insertAdjacentText('beforebegin', 'Text'); // Error
detached.insertAdjacentText('afterend', 'Text'); // Error

// These work (don't require parent)
detached.insertAdjacentText('afterbegin', 'Text'); // Works
detached.insertAdjacentText('beforeend', 'Text'); // Works
```

#### Comparison with Alternative Methods

**vs textContent**:

```javascript
// textContent replaces all content
element.textContent = 'New text'; // Removes all children, sets text

// insertAdjacentText appends/prepends
element.insertAdjacentText('beforeend', 'Additional text'); // Adds to existing
```

**vs innerText**:

```javascript
// innerText has CSS-aware behavior and causes reflow
element.innerText = 'Text'; // Respects CSS display, triggers layout

// insertAdjacentText is CSS-agnostic
element.insertAdjacentText('beforeend', 'Text'); // Direct text node insertion
```

**vs createTextNode + appendChild**:

```javascript
// Traditional approach
const textNode = document.createTextNode('Text');
element.appendChild(textNode);

// insertAdjacentText equivalent
element.insertAdjacentText('beforeend', 'Text');

// insertAdjacentText is more concise but less flexible for positioning
```

**vs insertAdjacentHTML with escaped text**:

```javascript
// More verbose, invokes parser
element.insertAdjacentHTML('beforeend', escapeHTML(userInput));

// Simpler, no parsing
element.insertAdjacentText('beforeend', userInput);
```

#### Browser Compatibility

- **IE**: No support (requires polyfill)
- **Edge 17+**: Full support
- **Chrome 2+**: Full support (under different timing than specs suggest)
- **Firefox 48+**: Full support
- **Safari 10+**: Full support
- **Opera 15+**: Full support

#### Polyfill for insertAdjacentText

```javascript
if (!Element.prototype.insertAdjacentText) {
  Element.prototype.insertAdjacentText = function(position, text) {
    const textNode = document.createTextNode(text);
    
    switch(position.toLowerCase()) {
      case 'beforebegin':
        if (!this.parentNode) {
          throw new DOMException('NoModificationAllowedError');
        }
        this.parentNode.insertBefore(textNode, this);
        break;
      case 'afterbegin':
        this.insertBefore(textNode, this.firstChild);
        break;
      case 'beforeend':
        this.appendChild(textNode);
        break;
      case 'afterend':
        if (!this.parentNode) {
          throw new DOMException('NoModificationAllowedError');
        }
        this.parentNode.insertBefore(textNode, this.nextSibling);
        break;
      default:
        throw new DOMException('SyntaxError');
    }
  };
}
```

### Comparison: insertAdjacentHTML vs insertAdjacentText

#### When to Use insertAdjacentHTML

1. **Need to insert markup structure**:

```javascript
element.insertAdjacentHTML('beforeend', '<div class="card"><h3>Title</h3></div>');
```

2. **Building complex UI components**:

```javascript
const card = `
  <article class="card">
    <header>${sanitize(title)}</header>
    <div class="content">${sanitize(content)}</div>
    <footer>${sanitize(footer)}</footer>
  </article>
`;
element.insertAdjacentHTML('beforeend', card);
```

3. **Performance-critical bulk insertions** (with proper sanitization):

```javascript
const rows = data.map(item => 
  `<tr><td>${sanitize(item.name)}</td><td>${item.value}</td></tr>`
).join('');
table.insertAdjacentHTML('beforeend', rows);
```

4. **Working with templates**:

```javascript
const template = document.querySelector('#card-template').innerHTML;
element.insertAdjacentHTML('beforeend', template);
```

#### When to Use insertAdjacentText

1. **Displaying user-generated content without markup**:

```javascript
commentElement.insertAdjacentText('beforeend', userComment);
```

2. **Security-critical contexts**:

```javascript
// No sanitization needed
element.insertAdjacentText('beforeend', untrustedInput);
```

3. **Pure text display**:

```javascript
codeElement.insertAdjacentText('beforeend', codeSnippet);
// Shows code as text, doesn't execute
```

4. **Simple text concatenation**:

```javascript
label.insertAdjacentText('beforeend', ': ');
label.insertAdjacentText('beforeend', fieldName);
```

### Combined Usage Patterns

#### Building Elements with Text Content

```javascript
// Create structure with HTML
element.insertAdjacentHTML('beforeend', '<div class="message"><span class="label"></span></div>');

// Add safe text content
const label = element.querySelector('.label');
label.insertAdjacentText('beforeend', userProvidedLabel);
```

#### Mixed Content Insertion

```javascript
function addComment(container, author, text, timestamp) {
  // Structure from HTML
  container.insertAdjacentHTML('beforeend', `
    <div class="comment">
      <div class="meta">
        <span class="author"></span>
        <time datetime="${timestamp}">${new Date(timestamp).toLocaleString()}</time>
      </div>
      <div class="text"></div>
    </div>
  `);
  
  // User content as text
  const comment = container.lastElementChild;
  comment.querySelector('.author').insertAdjacentText('beforeend', author);
  comment.querySelector('.text').insertAdjacentText('beforeend', text);
}
```

#### Template Literal Hybrid

```javascript
function createCard(data) {
  const temp = document.createElement('div');
  temp.insertAdjacentHTML('beforeend', `
    <div class="card">
      <h3 class="title"></h3>
      <p class="description"></p>
      <span class="value">${data.numericValue}</span>
    </div>
  `);
  
  const card = temp.firstElementChild;
  card.querySelector('.title').insertAdjacentText('beforeend', data.userTitle);
  card.querySelector('.description').insertAdjacentText('beforeend', data.userDescription);
  
  return card;
}
```

### Advanced Techniques

#### Position-Aware Insertion Helper

```javascript
function insertContent(element, position, content, asHTML = false) {
  if (asHTML) {
    element.insertAdjacentHTML(position, DOMPurify.sanitize(content));
  } else {
    element.insertAdjacentText(position, content);
  }
}

// Usage
insertContent(el, 'beforeend', userInput, false); // Safe text
insertContent(el, 'beforeend', trustedHTML, true); // Sanitized HTML
```

#### Batch Insertion with Mixed Content

```javascript
function batchInsert(container, items) {
  // Build HTML structure efficiently
  const htmlStructure = items.map(() => 
    '<div class="item"><span class="label"></span><span class="value"></span></div>'
  ).join('');
  
  container.insertAdjacentHTML('beforeend', htmlStructure);
  
  // Fill with safe text content
  const itemElements = container.querySelectorAll('.item');
  items.forEach((item, index) => {
    const el = itemElements[index];
    el.querySelector('.label').insertAdjacentText('beforeend', item.label);
    el.querySelector('.value').insertAdjacentText('beforeend', item.value);
  });
}
```

#### Error Recovery Pattern

```javascript
function safeInsertHTML(element, position, html) {
  try {
    element.insertAdjacentHTML(position, html);
    return true;
  } catch (e) {
    console.error('HTML insertion failed:', e);
    // Fallback to text insertion
    element.insertAdjacentText(position, html);
    return false;
  }
}
```

#### Stream-Style Insertion

```javascript
class ContentBuilder {
  constructor(element) {
    this.element = element;
  }
  
  addHTML(html) {
    this.element.insertAdjacentHTML('beforeend', DOMPurify.sanitize(html));
    return this; // Chainable
  }
  
  addText(text) {
    this.element.insertAdjacentText('beforeend', text);
    return this; // Chainable
  }
  
  addElement(tagName, text) {
    const el = document.createElement(tagName);
    el.insertAdjacentText('beforeend', text);
    this.element.appendChild(el);
    return this; // Chainable
  }
}

// Usage
new ContentBuilder(container)
  .addHTML('<h2>Title</h2>')
  .addText(userInput)
  .addElement('p', moreUserInput);
```

### Performance Benchmarking Considerations

**HTML Parsing Overhead**:

```javascript
// Measure parsing time
console.time('insertAdjacentHTML');
for (let i = 0; i < 1000; i++) {
  element.insertAdjacentHTML('beforeend', '<div>Item</div>');
}
console.timeEnd('insertAdjacentHTML');

console.time('insertAdjacentText');
for (let i = 0; i < 1000; i++) {
  element.insertAdjacentText('beforeend', 'Item');
}
console.timeEnd('insertAdjacentText');
// [Inference: insertAdjacentText typically faster for plain text due to no parsing]
```

**Memory Profiling**:

```javascript
// Large string building
const largeHTML = '<div>'.repeat(10000) + '</div>'.repeat(10000);
element.insertAdjacentHTML('beforeend', largeHTML);
// Parser must process and validate entire string

const largeText = 'Text '.repeat(10000);
element.insertAdjacentText('beforeend', largeText);
// Direct text node creation, no parsing
```

### Framework Integration Examples

#### React Refs

```javascript
function Component() {
  const contentRef = useRef();
  
  useEffect(() => {
    // Direct DOM manipulation when needed
    contentRef.current.insertAdjacentText('beforeend', dynamicText);
    
    return () => {
      // Cleanup if needed
      contentRef.current.textContent = '';
    };
  }, [dynamicText]);
  
  return <div ref={contentRef}></div>;
}
```

#### Vue Template Refs

```javascript
export default {
  mounted() {
    this.$refs.content.insertAdjacentText('beforeend', this.userText);
  },
  methods: {
    addHTML(html) {
      this.$refs.content.insertAdjacentHTML('beforeend', 
        DOMPurify.sanitize(html)
      );
    }
  }
}
```

#### Angular ViewChild

```typescript
import { Component, ViewChild, ElementRef } from '@angular/core';

@Component({
  selector: 'app-content',
  template: '<div #contentContainer></div>'
})
export class ContentComponent {
  @ViewChild('contentContainer') container: ElementRef;
  
  addContent(html: string, sanitize = true) {
    if (sanitize) {
      this.container.nativeElement.insertAdjacentHTML('beforeend', 
        this.sanitizer.sanitize(SecurityContext.HTML, html)
      );
    } else {
      this.container.nativeElement.insertAdjacentText('beforeend', html);
    }
  }
}
```

### Testing Strategies

#### Unit Testing insertAdjacentHTML

```javascript
describe('insertAdjacentHTML', () => {
  let element;
  
  beforeEach(() => {
    element = document.createElement('div');
    element.innerHTML = '<span>Existing</span>';
  });
  
  test('inserts HTML at beforeend position', () => {
    element.insertAdjacentHTML('beforeend', '<p>New</p>');
    expect(element.lastElementChild.tagName).toBe('P');
    expect(element.lastElementChild.textContent).toBe('New');
  });
  
  test('inserts HTML at afterbegin position', () => {
    element.insertAdjacentHTML('afterbegin', '<p>New</p>');
    expect(element.firstElementChild.tagName).toBe('P');
  });
  
  test('throws error for invalid position', () => {
    expect(() => {
      element.insertAdjacentHTML('invalid', '<p>Test</p>');
    }).toThrow();
  });
});
```

#### Unit Testing insertAdjacentText

```javascript
describe('insertAdjacentText', () => {
  let element;
  
  beforeEach(() => {
    element = document.createElement('div');
  });
  
  test('inserts text without HTML parsing', () => {
    element.insertAdjacentText('beforeend', '<script>alert("test")</script>');
    expect(element.textContent).toBe('<script>alert("test")</script>');
    expect(element.querySelector('script')).toBeNull();
  });
  
  test('escapes special characters', () => {
    element.insertAdjacentText('beforeend', '< > & " \'');
    expect(element.textContent).toBe('< > & " \'');
  });
  
  test('preserves whitespace', () => {
    element.insertAdjacentText('beforeend', '  text  ');
    expect(element.firstChild.nodeValue).toBe('  text  ');
  });
});
```

#### Integration Testing

```javascript
describe('Mixed content insertion', () => {
  test('combines HTML structure with safe text', () => {
    const container = document.createElement('div');
    container.insertAdjacentHTML('beforeend', '<div class="card"><h3 class="title"></h3></div>');
```

---

