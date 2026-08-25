## Clipboard API


### API Structure

The Clipboard API provides asynchronous access to the system clipboard through `navigator.clipboard`. All methods return Promises and require user permission or interaction. The API consists of four primary methods: `writeText()`, `readText()`, `write()`, and `read()`.

### Permission Model

Clipboard access requires permissions from the Permissions API. Write operations generally auto-grant during user gestures (clicks, key presses). Read operations require explicit user permission.

```javascript
const result = await navigator.permissions.query({name: 'clipboard-read'});
// result.state: 'granted', 'denied', or 'prompt'

const writeResult = await navigator.permissions.query({name: 'clipboard-write'});
```

**[Inference]** Browsers typically require user interaction for clipboard operations to prevent abuse. Reading clipboard content particularly requires active user consent to protect privacy.

### Text Operations

**Writing text**: `writeText()` copies plain text to the clipboard.

```javascript
await navigator.clipboard.writeText('Text to copy');
```

**Reading text**: `readText()` retrieves plain text content. This typically triggers a permission prompt on first use.

```javascript
const text = await navigator.clipboard.readText();
console.log(text);
```

Both methods throw exceptions if permission is denied or the operation fails. Wrap calls in try-catch blocks.

```javascript
try {
  await navigator.clipboard.writeText('content');
} catch (err) {
  console.error('Failed to copy:', err);
}
```

### Rich Content Operations

The `write()` and `read()` methods handle multiple MIME types simultaneously, enabling rich content like images, HTML, and custom formats.

**Writing rich content**: Use `ClipboardItem` objects containing multiple representations.

```javascript
const blob = new Blob(['<p>HTML content</p>'], {type: 'text/html'});
const plainText = new Blob(['Plain text'], {type: 'text/plain'});

const item = new ClipboardItem({
  'text/html': blob,
  'text/plain': plainText
});

await navigator.clipboard.write([item]);
```

**Writing images**:

```javascript
const response = await fetch('image.png');
const blob = await response.blob();

const item = new ClipboardItem({
  [blob.type]: blob
});

await navigator.clipboard.write([item]);
```

**Reading rich content**: Returns an array of `ClipboardItem` objects.

```javascript
const items = await navigator.clipboard.read();

for (const item of items) {
  console.log(item.types); // Array of available MIME types
  
  if (item.types.includes('text/html')) {
    const blob = await item.getType('text/html');
    const html = await blob.text();
    console.log(html);
  }
  
  if (item.types.includes('image/png')) {
    const blob = await item.getType('image/png');
    const url = URL.createObjectURL(blob);
    // Use url with <img> tag
  }
}
```

### ClipboardItem API

`ClipboardItem` objects encapsulate clipboard data with multiple representations. Each item maps MIME types to Blob or Promise-returning functions.

**Delayed rendering**: Provide functions that return Promises for lazy data generation.

```javascript
const item = new ClipboardItem({
  'text/plain': new Promise(async (resolve) => {
    const data = await generateExpensiveData();
    resolve(new Blob([data], {type: 'text/plain'}));
  })
});
```

**Presentation styles**: [Unverified] Some implementations support `presentationStyle` to indicate inline vs attachment handling.

```javascript
const item = new ClipboardItem(
  {'text/plain': blob},
  {presentationStyle: 'inline'}
);
```

### Copy and Paste Events

The older synchronous `document.execCommand()` approach still works through cut, copy, and paste events, though the Clipboard API is preferred.

**Copy event**:

```javascript
document.addEventListener('copy', (e) => {
  e.preventDefault();
  e.clipboardData.setData('text/plain', 'Custom text');
  e.clipboardData.setData('text/html', '<b>Custom HTML</b>');
});
```

**Paste event**:

```javascript
document.addEventListener('paste', (e) => {
  e.preventDefault();
  const text = e.clipboardData.getData('text/plain');
  const html = e.clipboardData.getData('text/html');
  
  // Access files
  const files = e.clipboardData.files;
  for (const file of files) {
    console.log(file.name, file.type);
  }
});
```

**Cut event**: Similar to copy but typically removes selected content.

### Custom MIME Types

Applications can use custom MIME types for proprietary data formats, enabling richer copy-paste between instances of the same application.

```javascript
const customData = JSON.stringify({id: 123, data: 'value'});
const blob = new Blob([customData], {type: 'application/x-myapp-data'});

const item = new ClipboardItem({
  'application/x-myapp-data': blob,
  'text/plain': new Blob(['Fallback text'], {type: 'text/plain'})
});

await navigator.clipboard.write([item]);
```

Include fallback MIME types for compatibility with applications that don't understand custom formats.

### Security Restrictions

**User gesture requirement**: Clipboard write operations typically require active user interaction (click, keypress) within a recent timeframe. The exact timing varies by browser.

**Origin restrictions**: Clipboard access is origin-bound. Cross-origin iframes have restricted access unless explicitly permitted through Permissions Policy.

```html
<iframe src="..." allow="clipboard-read; clipboard-write"></iframe>
```

**HTTPS requirement**: The Clipboard API generally requires secure contexts (HTTPS), though localhost is typically exempted.

**Sanitization**: [Inference] Browsers may sanitize clipboard content, particularly HTML, to remove potentially dangerous elements like scripts or event handlers.

### Browser Support and Fallbacks

The Clipboard API has widespread modern browser support, but checking for availability is recommended:

```javascript
if (navigator.clipboard && navigator.clipboard.writeText) {
  await navigator.clipboard.writeText(text);
} else {
  // Fallback to document.execCommand or textarea method
  const textarea = document.createElement('textarea');
  textarea.value = text;
  document.body.appendChild(textarea);
  textarea.select();
  document.execCommand('copy');
  document.body.removeChild(textarea);
}
```

Image clipboard operations have more limited support than text operations. The `read()` and `write()` methods for rich content require specific browser versions.

### Handling Multiple Items

The `write()` and `read()` methods accept/return arrays, but most implementations currently support only single items in the array.

```javascript
// Writing multiple items
await navigator.clipboard.write([item1, item2]); // [Unverified] Limited browser support

// Reading returns array even for single item
const items = await navigator.clipboard.read();
const firstItem = items[0];
```

### Common Patterns

**Copy button implementation**:

```javascript
async function copyToClipboard(text) {
  try {
    await navigator.clipboard.writeText(text);
    showFeedback('Copied!');
  } catch (err) {
    showFeedback('Failed to copy');
  }
}

button.addEventListener('click', () => copyToClipboard('content'));
```

**Paste from clipboard into editor**:

```javascript
pasteButton.addEventListener('click', async () => {
  try {
    const items = await navigator.clipboard.read();
    for (const item of items) {
      if (item.types.includes('text/html')) {
        const blob = await item.getType('text/html');
        const html = await blob.text();
        editor.insertHTML(html);
      } else if (item.types.includes('text/plain')) {
        const blob = await item.getType('text/plain');
        const text = await blob.text();
        editor.insertText(text);
      }
    }
  } catch (err) {
    console.error('Paste failed:', err);
  }
});
```

**Image paste handling**:

```javascript
document.addEventListener('paste', async (e) => {
  const items = e.clipboardData.items;
  
  for (const item of items) {
    if (item.type.startsWith('image/')) {
      const file = item.getAsFile();
      const url = URL.createObjectURL(file);
      
      const img = document.createElement('img');
      img.src = url;
      document.body.appendChild(img);
    }
  }
});
```

---

