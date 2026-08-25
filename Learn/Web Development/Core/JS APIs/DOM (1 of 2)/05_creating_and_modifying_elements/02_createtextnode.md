## createTextNode


The `document.createTextNode()` method creates a new Text node containing specified string data. Text nodes represent the actual text content within elements and cannot contain HTML markup or child nodes.

### Syntax

```javascript
const textNode = document.createTextNode(data);
```

**Parameters**:

- `data` (string): The text content for the text node

**Returns**: A Text node object

### Basic Usage

```javascript
const textNode = document.createTextNode('Hello, World!');
const paragraph = document.createElement('p');
paragraph.appendChild(textNode);
document.body.appendChild(paragraph);
// Result: <p>Hello, World!</p>
```

### Text Node Characteristics

#### Pure Text Content

Text nodes contain only plain text. HTML markup is treated as literal text, not parsed:

```javascript
const textNode = document.createTextNode('<strong>Bold</strong>');
div.appendChild(textNode);
// Displays: <strong>Bold</strong> (not rendered as bold)
```

#### No Child Nodes

Text nodes are leaf nodes in the DOM tree and cannot have children:

```javascript
const textNode = document.createTextNode('Text');
console.log(textNode.nodeType);        // 3 (Node.TEXT_NODE)
console.log(textNode.childNodes);      // null or undefined
console.log(textNode.hasChildNodes()); // false
```

#### Node Properties

```javascript
const textNode = document.createTextNode('Sample text');
console.log(textNode.nodeType);     // 3
console.log(textNode.nodeName);     // "#text"
console.log(textNode.nodeValue);    // "Sample text"
console.log(textNode.textContent);  // "Sample text"
console.log(textNode.data);         // "Sample text"
```

### When to Use createTextNode

#### Security: Preventing XSS

`createTextNode()` prevents Cross-Site Scripting (XSS) attacks by treating all content as literal text:

```javascript
const userInput = '<script>alert("XSS")</script>';

// Unsafe - executes script
element.innerHTML = userInput;

// Safe - renders as text
const textNode = document.createTextNode(userInput);
element.appendChild(textNode);
// Displays: <script>alert("XSS")</script> (as text, not executed)
```

#### Dynamic Text Insertion

When inserting user-generated or dynamic text content:

```javascript
function displayUsername(name) {
  const greeting = document.createElement('h1');
  const textNode = document.createTextNode(`Welcome, ${name}!`);
  greeting.appendChild(textNode);
  return greeting;
}
```

#### Performance with Multiple Text Nodes

For complex text manipulation, especially when combining with DocumentFragment:

```javascript
const fragment = document.createDocumentFragment();
const lines = ['Line 1', 'Line 2', 'Line 3'];

lines.forEach(line => {
  const textNode = document.createTextNode(line);
  const br = document.createElement('br');
  fragment.appendChild(textNode);
  fragment.appendChild(br);
});

container.appendChild(fragment); // Single reflow
```

#### Programmatic DOM Construction

When building DOM structures programmatically where text is separated from markup:

```javascript
const link = document.createElement('a');
link.href = 'https://example.com';
const linkText = document.createTextNode('Click here');
link.appendChild(linkText);
```

### Alternatives and Comparisons

#### vs. innerHTML

```javascript
// Using innerHTML
element.innerHTML = 'Text content';

// Using createTextNode
const textNode = document.createTextNode('Text content');
element.appendChild(textNode);
```

**innerHTML considerations**:

- Faster for simple text replacement
- Parses HTML markup
- Security risk with untrusted content
- Replaces all existing content
- Removes event listeners on replaced elements

**createTextNode considerations**:

- More verbose
- Always safe with untrusted content
- Preserves existing content when using `appendChild`
- Requires additional node creation/insertion

#### vs. textContent

```javascript
// Using textContent
element.textContent = 'New text';

// Using createTextNode
while (element.firstChild) {
  element.removeChild(element.firstChild);
}
const textNode = document.createTextNode('New text');
element.appendChild(textNode);
```

**textContent** is simpler for replacing all text content. **createTextNode** is better for:

- Adding text alongside existing content
- Building complex DOM structures
- Working with DocumentFragments

#### vs. innerText

```javascript
element.innerText = 'Text';
```

`innerText` considers CSS styling and triggers reflow, making it slower than `textContent` or `createTextNode()`. It also has browser compatibility differences.

### Manipulating Text Nodes

#### Accessing Text Content

```javascript
const textNode = document.createTextNode('Original text');
console.log(textNode.nodeValue);   // "Original text"
console.log(textNode.data);        // "Original text"
console.log(textNode.textContent); // "Original text"
```

#### Modifying Text Content

```javascript
const textNode = document.createTextNode('Initial text');
textNode.nodeValue = 'Modified text';
// or
textNode.data = 'Modified text';
// or
textNode.textContent = 'Modified text';
```

#### Text Node Length

```javascript
const textNode = document.createTextNode('Hello');
console.log(textNode.length);    // 5
console.log(textNode.data.length); // 5
```

#### Substring Operations

Text nodes provide methods for substring manipulation:

```javascript
const textNode = document.createTextNode('Hello World');

// substringData(offset, count)
const substring = textNode.substringData(0, 5); // "Hello"

// appendData(text)
textNode.appendData('!!!');
console.log(textNode.data); // "Hello World!!!"

// insertData(offset, text)
textNode.insertData(5, ' Beautiful');
console.log(textNode.data); // "Hello Beautiful World!!!"

// deleteData(offset, count)
textNode.deleteData(6, 10);
console.log(textNode.data); // "Hello World!!!"

// replaceData(offset, count, text)
textNode.replaceData(6, 5, 'Universe');
console.log(textNode.data); // "Hello Universe!!!"
```

### Splitting and Combining Text Nodes

#### splitText()

Splits a text node into two nodes at the specified offset:

```javascript
const textNode = document.createTextNode('HelloWorld');
element.appendChild(textNode);

const secondNode = textNode.splitText(5);
console.log(textNode.data);    // "Hello"
console.log(secondNode.data);  // "World"

// Both nodes are now children of the element
console.log(element.childNodes.length); // 2
```

**Use case**: Inserting elements within text:

```javascript
const textNode = document.createTextNode('Click here for more info');
paragraph.appendChild(textNode);

textNode.splitText(6); // Split after "Click "
const secondPart = textNode.nextSibling;
secondPart.splitText(4); // Split after "here"

const link = document.createElement('a');
link.href = '#';
const linkText = secondPart;
paragraph.replaceChild(link, linkText);
link.appendChild(linkText);
// Result: "Click <a>here</a> for more info"
```

#### normalize()

Merges adjacent text nodes into a single node:

```javascript
const parent = document.createElement('div');
parent.appendChild(document.createTextNode('First '));
parent.appendChild(document.createTextNode('Second '));
parent.appendChild(document.createTextNode('Third'));

console.log(parent.childNodes.length); // 3

parent.normalize();
console.log(parent.childNodes.length); // 1
console.log(parent.firstChild.data);   // "First Second Third"
```

### Whitespace Text Nodes

HTML parsers create text nodes for whitespace between elements:

```html
<div>
  <span>Text</span>
</div>
```

```javascript
// The div contains 3 child nodes:
// 1. Text node (whitespace/newline before <span>)
// 2. <span> element
// 3. Text node (whitespace/newline after </span>)
console.log(div.childNodes.length); // 3
console.log(div.childNodes[0].nodeType); // 3 (TEXT_NODE)
```

#### Handling Whitespace

```javascript
// Filter out whitespace-only text nodes
function getElementChildren(parent) {
  return Array.from(parent.childNodes).filter(node => {
    if (node.nodeType !== Node.TEXT_NODE) return true;
    return node.data.trim().length > 0;
  });
}

// Or use element-specific properties
const elements = parent.children; // Excludes all text nodes
const firstElement = parent.firstElementChild; // Skips text nodes
```

### Empty Text Nodes

Creating text nodes with empty strings:

```javascript
const emptyTextNode = document.createTextNode('');
console.log(emptyTextNode.length); // 0
console.log(emptyTextNode.data);   // ""
```

Empty text nodes are valid but generally unnecessary. They still occupy space in the DOM tree.

### Special Characters and Encoding

#### HTML Entities

Text nodes automatically handle special characters without entity encoding:

```javascript
const textNode = document.createTextNode('Price: $50 & up');
// Displays: Price: $50 & up (no need for &amp;)

const textNode2 = document.createTextNode('<div>Not a tag</div>');
// Displays: <div>Not a tag</div> (no need for &lt; &gt;)
```

#### Unicode and Emoji

Text nodes handle Unicode characters directly:

```javascript
const textNode = document.createTextNode('Hello 世界 🌍');
console.log(textNode.data); // "Hello 世界 🌍"
console.log(textNode.length); // Counts Unicode code points
```

#### Line Breaks

Newline characters are preserved in text nodes:

```javascript
const textNode = document.createTextNode('Line 1\nLine 2\nLine 3');
element.appendChild(textNode);
// HTML collapses whitespace by default, so appears as one line
// Use white-space: pre; CSS to preserve formatting
```

```javascript
element.style.whiteSpace = 'pre';
element.appendChild(document.createTextNode('Line 1\nLine 2\nLine 3'));
// Now displays on separate lines
```

### Performance Considerations

#### Batch Operations with DocumentFragment

Creating many text nodes individually triggers multiple reflows:

```javascript
// Inefficient - multiple reflows
for (let i = 0; i < 1000; i++) {
  const textNode = document.createTextNode(`Item ${i} `);
  container.appendChild(textNode);
}

// Efficient - single reflow
const fragment = document.createDocumentFragment();
for (let i = 0; i < 1000; i++) {
  const textNode = document.createTextNode(`Item ${i} `);
  fragment.appendChild(textNode);
}
container.appendChild(fragment);
```

#### String Concatenation vs. Multiple Text Nodes

For simple text, concatenation before creating the node is more efficient:

```javascript
// Less efficient
const text1 = document.createTextNode('Hello ');
const text2 = document.createTextNode('World');
element.appendChild(text1);
element.appendChild(text2);

// More efficient
const combinedText = document.createTextNode('Hello World');
element.appendChild(combinedText);
```

#### Memory Considerations

Text nodes consume memory. For large amounts of text, using a single node is more efficient than many small nodes.

### Browser Compatibility

`createTextNode()` is supported in all browsers including legacy versions. It's part of the original DOM Level 1 specification.

### Common Patterns

#### Safe User Content Display

```javascript
function displayUserComment(comment) {
  const container = document.createElement('div');
  container.className = 'comment';
  
  const textNode = document.createTextNode(comment);
  container.appendChild(textNode);
  
  return container;
}
```

#### Building Complex Structures

```javascript
function createLabeledInput(labelText, inputType) {
  const container = document.createElement('div');
  
  const label = document.createElement('label');
  const labelTextNode = document.createTextNode(labelText);
  label.appendChild(labelTextNode);
  
  const input = document.createElement('input');
  input.type = inputType;
  
  container.appendChild(label);
  container.appendChild(input);
  
  return container;
}
```

#### Conditional Text Insertion

```javascript
function addErrorMessage(element, hasError, message) {
  // Remove existing error text nodes
  Array.from(element.childNodes)
    .filter(node => node.nodeType === Node.TEXT_NODE)
    .forEach(node => element.removeChild(node));
  
  if (hasError) {
    const errorText = document.createTextNode(message);
    element.appendChild(errorText);
  }
}
```

#### Template Building

```javascript
function buildCard(title, description) {
  const card = document.createElement('div');
  card.className = 'card';
  
  const heading = document.createElement('h2');
  heading.appendChild(document.createTextNode(title));
  
  const content = document.createElement('p');
  content.appendChild(document.createTextNode(description));
  
  card.appendChild(heading);
  card.appendChild(content);
  
  return card;
}
```

### Edge Cases

#### Null and Undefined

```javascript
const nullText = document.createTextNode(null);
console.log(nullText.data); // "null" (converted to string)

const undefinedText = document.createTextNode(undefined);
console.log(undefinedText.data); // "undefined" (converted to string)
```

#### Non-String Values

Non-string values are automatically converted to strings:

```javascript
const numberText = document.createTextNode(123);
console.log(numberText.data); // "123"

const boolText = document.createTextNode(true);
console.log(boolText.data); // "true"

const objectText = document.createTextNode({key: 'value'});
console.log(objectText.data); // "[object Object]"
```

#### Very Long Strings

Text nodes can handle very long strings, but performance degrades with extremely large content. Consider pagination or virtualization for massive text content.

### Debugging Text Nodes

#### Identifying Text Nodes in DevTools

Text nodes appear in browser DevTools but may be collapsed or hidden depending on the tool. They display as `#text` with their content.

#### Logging Text Node Information

```javascript
function logTextNode(node) {
  if (node.nodeType === Node.TEXT_NODE) {
    console.log('Text content:', node.data);
    console.log('Length:', node.length);
    console.log('Parent:', node.parentNode?.tagName);
    console.log('Next sibling:', node.nextSibling?.nodeName);
  }
}
```

---

