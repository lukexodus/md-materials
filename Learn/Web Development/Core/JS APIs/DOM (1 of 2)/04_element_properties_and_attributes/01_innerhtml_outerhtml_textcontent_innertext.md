## innerHTML, outerHTML, textContent, innerText


### innerHTML

#### Definition and Behavior

Returns or sets the HTML markup contained within an element. Parses the string as HTML and creates DOM nodes.

```javascript
const div = document.querySelector('div');

// Getting innerHTML
console.log(div.innerHTML);
// "<p>Hello <strong>world</strong></p>"

// Setting innerHTML
div.innerHTML = '<span>New content</span>';
// Replaces all children with new parsed HTML
```

#### Setting innerHTML: Parsing and Rendering

When setting `innerHTML`, the browser:

1. Parses the string as HTML
2. Destroys existing child nodes
3. Creates new nodes from the parsed HTML
4. Inserts them into the DOM

```javascript
const container = document.getElementById('container');

// This destroys all existing children
container.innerHTML = '<p>Paragraph 1</p><p>Paragraph 2</p>';

// Event listeners on old children are lost
const button = document.createElement('button');
button.onclick = () => console.log('clicked');
container.appendChild(button);

container.innerHTML = '<div>New content</div>';
// button and its event listener are gone
```

#### Appending vs. Replacing

```javascript
const div = document.querySelector('div');

// Replace all content
div.innerHTML = '<p>New</p>';

// Append (inefficient - reparses everything)
div.innerHTML += '<p>Appended</p>';

// Better for appending
div.insertAdjacentHTML('beforeend', '<p>Appended</p>');
```

**Performance issue with +=:**

```javascript
// Poor: Reparses entire innerHTML each iteration
for (let i = 0; i < 100; i++) {
  div.innerHTML += `<p>Item ${i}</p>`;
}

// Better: Build string first
let html = '';
for (let i = 0; i < 100; i++) {
  html += `<p>Item ${i}</p>`;
}
div.innerHTML = html;

// Best: Use DocumentFragment or insertAdjacentHTML
for (let i = 0; i < 100; i++) {
  div.insertAdjacentHTML('beforeend', `<p>Item ${i}</p>`);
}
```

#### Security Concerns: XSS Vulnerabilities

Setting `innerHTML` with unsanitized user input creates XSS vulnerabilities:

```javascript
const userInput = '<img src=x onerror="alert(\'XSS\')">';

// DANGEROUS - executes malicious code
div.innerHTML = userInput;

// Script tags don't execute when inserted via innerHTML
div.innerHTML = '<script>alert("XSS")</script>'; // Doesn't run

// But event handlers and other vectors do
div.innerHTML = '<img src=x onerror="alert(\'XSS\')">';  // Runs!
div.innerHTML = '<svg onload="alert(\'XSS\')"></svg>';  // Runs!
```

**Safe alternatives:**

```javascript
// Use textContent for text-only
div.textContent = userInput; // Safe - treats as text

// Use DOMPurify for HTML sanitization
div.innerHTML = DOMPurify.sanitize(userInput);

// Create elements programmatically
const p = document.createElement('p');
p.textContent = userInput;
div.appendChild(p);
```

#### Special Cases

**Table elements have restrictions:**

```javascript
const table = document.querySelector('table');

// This may not work as expected in older browsers
table.innerHTML = '<tr><td>Cell</td></tr>';

// Better: target tbody
table.querySelector('tbody').innerHTML = '<tr><td>Cell</td></tr>';
```

**Self-closing tags:**

```javascript
// HTML parser handles self-closing tags
div.innerHTML = '<input><br><img src="x">';
// Creates proper elements even without closing tags
```

### outerHTML

#### Definition and Behavior

Returns or sets the HTML of the element **including the element itself**.

```javascript
const div = document.querySelector('div');
div.id = 'myDiv';
div.innerHTML = '<p>Content</p>';

console.log(div.innerHTML);
// "<p>Content</p>"

console.log(div.outerHTML);
// "<div id=\"myDiv\"><p>Content</p></div>"
```

#### Setting outerHTML: Element Replacement

Setting `outerHTML` **replaces the element itself**:

```javascript
const oldDiv = document.querySelector('.old');

// Replace the entire element
oldDiv.outerHTML = '<section class="new">New content</section>';

// oldDiv is now detached from the DOM
console.log(oldDiv.parentNode); // null

// The variable still references the old element (now detached)
// This does nothing:
oldDiv.style.color = 'red';
```

**Critical gotcha:**

```javascript
const element = document.querySelector('.target');

// After this, 'element' is detached
element.outerHTML = '<div>New</div>';

// This has NO effect on the DOM!
element.classList.add('active'); // Operates on detached node

// To continue working with the new element, requery
const newElement = document.querySelector('.target');
```

#### Use Cases

```javascript
// Unwrap an element (replace element with its contents)
const wrapper = document.querySelector('.wrapper');
wrapper.outerHTML = wrapper.innerHTML;

// Replace element with different tag
const span = document.querySelector('span.important');
span.outerHTML = `<strong>${span.innerHTML}</strong>`;

// Clone and modify
const original = document.querySelector('.item');
const clone = original.cloneNode(true);
clone.id = 'new-id';
original.insertAdjacentHTML('afterend', clone.outerHTML);
```

### textContent

#### Definition and Behavior

Returns or sets the **text content** of an element and all its descendants. Ignores all HTML tags.

```javascript
const div = document.querySelector('div');
div.innerHTML = '<p>Hello <strong>world</strong></p><!-- comment -->';

console.log(div.textContent);
// "Hello world"
// (just the text, no tags, no extra whitespace)

// Setting textContent
div.textContent = '<p>Not HTML</p>';
console.log(div.innerHTML);
// "&lt;p&gt;Not HTML&lt;/p&gt;"
// (HTML entities escaped, treated as text)
```

#### Whitespace Handling

`textContent` preserves whitespace in the source:

```javascript
div.innerHTML = `
  <p>
    Line 1
    Line 2
  </p>
`;

console.log(div.textContent);
// "
//   
//     Line 1
//     Line 2
//   
// "
// (preserves all whitespace including newlines and indentation)
```

#### Setting textContent: Text Replacement

```javascript
const p = document.querySelector('p');

// Replaces all children with a single text node
p.textContent = 'New text';

// Safe for user input - no XSS risk
const userInput = '<script>alert("XSS")</script>';
p.textContent = userInput;
// Displays literally: <script>alert("XSS")</script>
```

#### Performance Characteristics

[Inference] `textContent` is generally faster than `innerHTML` for setting text-only content because it doesn't invoke the HTML parser. It directly creates a text node.

```javascript
// Faster
element.textContent = 'Plain text';

// Slower (invokes HTML parser)
element.innerHTML = 'Plain text';
```

#### Hidden Elements Inclusion

`textContent` includes text from **hidden elements**:

```javascript
div.innerHTML = `
  <p>Visible</p>
  <p style="display: none;">Hidden</p>
`;

console.log(div.textContent);
// "
//   Visible
//   Hidden
// "
// (includes text from display:none elements)
```

#### Script and Style Elements

```javascript
div.innerHTML = `
  <p>Text</p>
  <script>console.log('code');</script>
  <style>p { color: red; }</style>
`;

console.log(div.textContent);
// "
//   Text
//   console.log('code');
//   p { color: red; }
// "
// (includes script and style content)
```

### innerText

#### Definition and Behavior

Returns the **rendered** text content of an element, approximating what a user would see. Considers CSS styling and rendering.

```javascript
const div = document.querySelector('div');
div.innerHTML = `
  <p>Visible</p>
  <p style="display: none;">Hidden</p>
`;

console.log(div.innerText);
// "Visible"
// (excludes hidden text)

console.log(div.textContent);
// "
//   Visible
//   Hidden
// "
// (includes hidden text)
```

#### Rendering-Aware Behavior

`innerText` triggers **reflow** because it needs layout information:

```javascript
// These trigger reflow (slower)
const text = element.innerText;
element.innerText = 'New text';

// These don't trigger reflow (faster)
const text = element.textContent;
element.textContent = 'New text';
```

[Inference] This makes `innerText` significantly slower than `textContent` for performance-critical operations, as reflow is computationally expensive.

#### CSS Visibility Impact

```javascript
div.innerHTML = `
  <p>Visible</p>
  <p style="visibility: hidden;">Hidden with visibility</p>
  <p style="display: none;">Hidden with display</p>
`;

console.log(div.innerText);
// "Visible
// "
// (excludes both visibility:hidden and display:none)

console.log(div.textContent);
// "
//   Visible
//   Hidden with visibility
//   Hidden with display
// "
// (includes all text regardless of CSS)
```

#### Line Break Handling

`innerText` attempts to preserve visual line breaks:

```javascript
div.innerHTML = '<p>Line 1</p><p>Line 2</p>';

console.log(div.innerText);
// "Line 1
// Line 2"
// (preserves block-level element breaks)

console.log(div.textContent);
// "Line 1Line 2"
// (no automatic line breaks)
```

**`<br>` tag handling:**

```javascript
div.innerHTML = 'Line 1<br>Line 2';

console.log(div.innerText);
// "Line 1
// Line 2"
// (converts <br> to newline)

console.log(div.textContent);
// "Line 1Line 2"
// (ignores <br>)
```

#### Script and Style Exclusion

Unlike `textContent`, `innerText` excludes `<script>` and `<style>` content:

```javascript
div.innerHTML = `
  <p>Text</p>
  <script>console.log('code');</script>
  <style>p { color: red; }</style>
`;

console.log(div.innerText);
// "Text"

console.log(div.textContent);
// "
//   Text
//   console.log('code');
//   p { color: red; }
// "
```

#### Setting innerText

```javascript
element.innerText = 'Line 1\nLine 2';
// Creates <br> tags for newlines

element.textContent = 'Line 1\nLine 2';
// Preserves literal newlines in text node
```

[Unverified] The exact behavior of newline conversion when setting `innerText` may vary between browsers, particularly in edge cases.

#### Browser Compatibility and Standardization

`innerText` was originally an IE-specific property, later adopted by other browsers, and finally standardized. However, implementation details vary:

```javascript
// Modern browsers support innerText
const text = element.innerText;
```

[Unverified] Subtle differences in whitespace handling and edge cases may exist between browser implementations despite standardization efforts.

### Comparison Matrix

|Feature|innerHTML|outerHTML|textContent|innerText|
|---|---|---|---|---|
|Returns HTML|✓|✓|✗|✗|
|Includes element itself|✗|✓|✗|✗|
|Parses HTML when setting|✓|✓|✗|✗|
|XSS-safe with user input|✗|✗|✓|✓|
|Triggers reflow|✗|✗|✗|✓|
|Respects CSS hiding|✗|✗|✗|✓|
|Includes hidden elements|✓|✓|✓|✗|
|Includes script/style content|✓|✓|✓|✗|
|Performance (reading)|Fast|Fast|Fast|Slow|
|Performance (writing)|Medium|Medium|Fast|Slow|

### Use Case Decision Guide

**Use innerHTML when:**

- You need to insert or retrieve HTML markup
- You're working with trusted content
- You need maximum control over structure

**Use outerHTML when:**

- You need to replace an entire element
- You're cloning elements with modifications
- You need the element's own tag in the string

**Use textContent when:**

- You're inserting user-generated content (security)
- You only need text, not HTML
- Performance is critical
- You need text from hidden elements

**Use innerText when:**

- You need rendered text only (what user sees)
- You want to exclude hidden content
- You need visual line breaks preserved
- Performance is not critical

### Security Best Practices

```javascript
// NEVER do this with user input
element.innerHTML = userInput; // XSS vulnerability

// DO this instead
element.textContent = userInput; // Safe

// If you must use HTML, sanitize first
element.innerHTML = DOMPurify.sanitize(userInput);

// Or use safer DOM methods
const p = document.createElement('p');
p.textContent = userInput;
element.appendChild(p);
```

### Performance Patterns

```javascript
// Building large lists - BAD
for (let i = 0; i < 1000; i++) {
  list.innerHTML += `<li>Item ${i}</li>`;
}

// Building large lists - GOOD
const items = [];
for (let i = 0; i < 1000; i++) {
  items.push(`<li>Item ${i}</li>`);
}
list.innerHTML = items.join('');

// Building large lists - BEST
const fragment = document.createDocumentFragment();
for (let i = 0; i < 1000; i++) {
  const li = document.createElement('li');
  li.textContent = `Item ${i}`;
  fragment.appendChild(li);
}
list.appendChild(fragment);
```

### Common Pitfalls

**Losing event listeners:**

```javascript
const button = document.querySelector('button');
button.addEventListener('click', handler);

// This removes the button and its listener
button.parentElement.innerHTML = '<div>New content</div>';

// Event listener is lost
```

**Detached element after outerHTML:**

```javascript
const element = document.querySelector('.item');
element.outerHTML = '<div class="item">New</div>';

// element is now detached!
element.classList.add('active'); // Does nothing to DOM
```

**Whitespace surprises with textContent:**

```javascript
div.innerHTML = '<p>  Multiple   spaces  </p>';

console.log(div.textContent);
// "  Multiple   spaces  "
// (preserves all whitespace from source)

console.log(div.innerText);
// "Multiple spaces"
// (collapses whitespace like rendered text)
```

---

