## FormData API


### Core Concepts and Construction

The FormData interface provides a programmatic way to construct key-value pairs representing form fields and their values, which can be transmitted using `XMLHttpRequest`, `fetch()`, or other HTTP APIs. FormData objects are particularly designed for encoding data in `multipart/form-data` format.

#### Constructor Patterns

```javascript
// Empty FormData object
const formData = new FormData();

// Populate from existing form element
const form = document.querySelector('form');
const formData = new FormData(form);

// With optional submitter parameter (button that triggered submission)
const submitButton = document.querySelector('button[type="submit"]');
const formData = new FormData(form, submitButton);
```

The submitter parameter captures which submit button was clicked, including its name/value if present. This matters when forms have multiple submit buttons with different values.

### Methods and Operations

#### Appending Data

```javascript
const fd = new FormData();

// Append string value
fd.append('username', 'john_doe');

// Append number (converted to string)
fd.append('age', 25);

// Append File object
const fileInput = document.querySelector('input[type="file"]');
fd.append('avatar', fileInput.files[0]);

// Append Blob with filename
const blob = new Blob(['content'], { type: 'text/plain' });
fd.append('document', blob, 'readme.txt');

// Multiple values for same key
fd.append('tags', 'javascript');
fd.append('tags', 'web');
fd.append('tags', 'api');
```

The `append()` method always adds a new value, even if the key already exists. This enables multiple values per key, which is standard behavior for form controls like checkboxes or multi-select inputs.

#### Setting and Replacing Values

```javascript
// Set replaces all existing values for the key
fd.set('username', 'jane_doe');

// If key doesn't exist, set() and append() behave identically
fd.set('email', 'jane@example.com');

// Setting a file
fd.set('profile_pic', file, 'profile.jpg');
```

The distinction between `append()` and `set()` becomes critical when handling form data that might already contain the key. `set()` ensures exactly one value exists for the key.

#### Retrieving Values

```javascript
// Get first value for key
const username = fd.get('username');

// Get all values for key (returns array)
const tags = fd.getAll('tags'); // ['javascript', 'web', 'api']

// Check if key exists
const hasEmail = fd.has('email'); // true/false

// Delete key and all its values
fd.delete('username');
```

`get()` returns only the first value when multiple values exist for a key. `getAll()` is necessary to retrieve multiple checkbox selections or multi-select options.

#### Iteration Methods

```javascript
// Iterate over keys
for (const key of fd.keys()) {
  console.log(key);
}

// Iterate over values
for (const value of fd.values()) {
  console.log(value);
}

// Iterate over [key, value] pairs
for (const [key, value] of fd.entries()) {
  console.log(`${key}: ${value}`);
}

// Direct iteration (equivalent to entries())
for (const [key, value] of fd) {
  console.log(`${key}: ${value}`);
}

// forEach method
fd.forEach((value, key) => {
  console.log(`${key}: ${value}`);
});
```

When iterating over FormData with multiple values for a single key, each key-value pair appears as a separate entry in the iteration.

### File Handling

#### File Objects

```javascript
// Single file upload
const fileInput = document.querySelector('input[type="file"]');
const file = fileInput.files[0];

fd.append('upload', file);
// Transmitted with original filename and MIME type

// Override filename
fd.append('upload', file, 'custom-name.pdf');
```

File objects contain metadata: `name`, `size` (bytes), `type` (MIME), and `lastModified` (timestamp). The FormData serialization includes this metadata in the multipart encoding.

#### Multiple File Upload

```javascript
// HTML: <input type="file" multiple>
const fileInput = document.querySelector('input[type="file"][multiple]');

// Append each file individually
Array.from(fileInput.files).forEach((file, index) => {
  fd.append('files[]', file);
  // Or use distinct keys: fd.append(`file_${index}`, file);
});

// Server receives multiple values for 'files[]' key
```

Array notation (`files[]`) is a common convention signaling to server-side frameworks that multiple values should be collected into an array, but this is framework-specific, not part of the FormData spec.

#### Blob Construction

```javascript
// Create blob from string content
const jsonBlob = new Blob(
  [JSON.stringify({ data: 'value' })],
  { type: 'application/json' }
);
fd.append('metadata', jsonBlob, 'metadata.json');

// Canvas to blob
canvas.toBlob((blob) => {
  fd.append('image', blob, 'canvas-export.png');
}, 'image/png');

// ArrayBuffer to blob
const buffer = new ArrayBuffer(8);
const blob = new Blob([buffer], { type: 'application/octet-stream' });
fd.append('binary', blob, 'data.bin');
```

Blobs require explicit filename parameter in `append()` or `set()`, unlike File objects which have inherent filenames.

### Network Transmission

#### Fetch API Integration

```javascript
const fd = new FormData();
fd.append('username', 'john');
fd.append('avatar', fileInput.files[0]);

fetch('/api/upload', {
  method: 'POST',
  body: fd
  // DO NOT set Content-Type header manually
})
.then(response => response.json())
.then(data => console.log(data));
```

**Critical**: When using FormData with fetch, do not set the `Content-Type` header. The browser automatically sets `Content-Type: multipart/form-data` with the appropriate boundary parameter. Manual header setting will break multipart encoding.

#### XMLHttpRequest Integration

```javascript
const xhr = new XMLHttpRequest();
xhr.open('POST', '/api/upload');

// Optional progress tracking
xhr.upload.addEventListener('progress', (e) => {
  if (e.lengthComputable) {
    const percentComplete = (e.loaded / e.total) * 100;
    console.log(`Upload progress: ${percentComplete}%`);
  }
});

xhr.addEventListener('load', () => {
  console.log('Upload complete:', xhr.responseText);
});

xhr.send(fd);
```

XMLHttpRequest provides upload progress events, which fetch API historically lacked (though `ReadableStream` progressively addresses this).

#### Request Object Construction

```javascript
// Create Request with FormData body
const request = new Request('/api/endpoint', {
  method: 'POST',
  body: fd
});

fetch(request).then(/* ... */);

// Clone FormData through request cloning
const clonedRequest = request.clone();
```

### Encoding and Serialization

#### Multipart/Form-Data Structure

FormData serializes to `multipart/form-data` format with structure:

```
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="username"

john_doe
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="avatar"; filename="photo.jpg"
Content-Type: image/jpeg

[binary data]
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

The boundary string is automatically generated and must not appear in the encoded data. Each part contains headers followed by the value.

#### Boundary Generation

The browser generates a unique boundary string (typically prefixed with `----WebKitFormBoundary` or similar vendor-specific prefix) and includes it in the Content-Type header:

```
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW
```

**[Inference]** Manual boundary generation and multipart encoding is possible but error-prone, making FormData the preferred approach for this format.

### Form Element Integration

#### Automatic Population from Form

```javascript
const form = document.querySelector('#myForm');
const fd = new FormData(form);

// Includes all named form controls:
// - input (text, email, number, hidden, etc.)
// - textarea
// - select
// - input[type="file"]
// - input[type="checkbox"] (if checked)
// - input[type="radio"] (if selected)
```

Only **successful** form controls (enabled, named, and with valid state) are included. Disabled inputs, unnamed inputs, and unchecked checkboxes without special handling are excluded.

#### Checkbox and Radio Handling

```html
<!-- Multiple checkboxes with same name -->
<input type="checkbox" name="interests" value="coding" checked>
<input type="checkbox" name="interests" value="music" checked>
<input type="checkbox" name="interests" value="sports">
```

```javascript
const fd = new FormData(form);
fd.getAll('interests'); // ['coding', 'music']
```

Unchecked checkboxes don't appear in FormData. To include unchecked state, use hidden input with same name or handle programmatically:

```javascript
// Include unchecked state explicitly
const checkbox = document.querySelector('#agree');
fd.append('agree', checkbox.checked ? 'true' : 'false');
```

#### Submit Button Values

```html
<button type="submit" name="action" value="save">Save</button>
<button type="submit" name="action" value="delete">Delete</button>
```

```javascript
form.addEventListener('submit', (e) => {
  e.preventDefault();
  const submitter = e.submitter; // Button that was clicked
  const fd = new FormData(form, submitter);
  
  // fd.get('action') === 'save' or 'delete' depending on click
});
```

Without the submitter parameter, submit button values are excluded from FormData.

### Data Transformation and Validation

#### Converting FormData to JSON

```javascript
// Object with single values
const obj = Object.fromEntries(fd);

// Preserve multiple values
const obj = {};
for (const [key, value] of fd.entries()) {
  if (obj[key]) {
    if (Array.isArray(obj[key])) {
      obj[key].push(value);
    } else {
      obj[key] = [obj[key], value];
    }
  } else {
    obj[key] = value;
  }
}

const json = JSON.stringify(obj);
```

**[Inference]** File objects don't serialize to JSON meaningfully. Conversion to JSON typically requires extracting text content, base64 encoding, or uploading files separately.

#### Converting JSON to FormData

```javascript
const data = {
  username: 'john',
  email: 'john@example.com',
  tags: ['js', 'web']
};

const fd = new FormData();

Object.entries(data).forEach(([key, value]) => {
  if (Array.isArray(value)) {
    value.forEach(item => fd.append(key, item));
  } else {
    fd.append(key, value);
  }
});
```

#### URL-Encoded Format Conversion

```javascript
// FormData to URLSearchParams
const params = new URLSearchParams(fd);

// Results in application/x-www-form-urlencoded format
fetch('/api/endpoint', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: params
});
```

**[Inference]** URLSearchParams cannot handle File/Blob objects, making this conversion suitable only for text data.

### Advanced Patterns

#### Nested Object Structures

```javascript
// Flat structure with naming convention
fd.append('user[name]', 'John');
fd.append('user[email]', 'john@example.com');
fd.append('user[address][city]', 'New York');
fd.append('user[address][zip]', '10001');

// Server frameworks (Rails, Laravel) parse this into nested objects
// { user: { name: 'John', email: '...', address: { city: '...', zip: '...' }}}
```

**[Unverified]** Bracket notation parsing is framework-dependent and not standardized in the FormData specification.

#### Dynamic Form Building

```javascript
function buildFormData(formData, data, parentKey) {
  if (data && typeof data === 'object' && !(data instanceof Date) && !(data instanceof File)) {
    Object.keys(data).forEach(key => {
      buildFormData(formData, data[key], parentKey ? `${parentKey}[${key}]` : key);
    });
  } else {
    const value = data == null ? '' : data;
    formData.append(parentKey, value);
  }
}

const fd = new FormData();
buildFormData(fd, {
  user: {
    name: 'John',
    profile: {
      age: 30,
      avatar: fileObject
    }
  }
});
```

#### Cloning FormData

FormData objects cannot be directly cloned with spread or `Object.assign()`:

```javascript
// Create new FormData with same entries
function cloneFormData(original) {
  const clone = new FormData();
  for (const [key, value] of original.entries()) {
    clone.append(key, value);
  }
  return clone;
}

const fd2 = cloneFormData(fd);
```

**[Inference]** File objects in FormData reference the same underlying file data when cloned this way, rather than creating independent copies.

#### Modifying Existing Form Submissions

```javascript
form.addEventListener('submit', (e) => {
  e.preventDefault();
  
  const fd = new FormData(form);
  
  // Add authentication token
  fd.append('csrf_token', getCSRFToken());
  
  // Remove sensitive field
  fd.delete('password_confirm');
  
  // Modify existing value
  const email = fd.get('email');
  fd.set('email', email.toLowerCase());
  
  // Add computed field
  fd.append('timestamp', Date.now());
  
  fetch(form.action, {
    method: form.method,
    body: fd
  });
});
```

### Browser Compatibility and Polyfills

FormData is supported in all modern browsers (Chrome 7+, Firefox 4+, Safari 5+, Edge 12+, IE 10+). Key feature support variations:

- **FormData constructor with form element**: IE 10+, Chrome 7+, Firefox 39+, Safari 5.1+
- **FormData.entries/keys/values/forEach**: Chrome 50+, Firefox 44+, Safari 11.1+, Edge 18+
- **FormData with submitter parameter**: Chrome 74+, Firefox 76+, Safari 15+

```javascript
// Feature detection
if (typeof FormData !== 'undefined') {
  // FormData available
  const fd = new FormData();
}

// Check iteration support
const supportsIteration = 'entries' in FormData.prototype;
```

### Security Considerations

#### File Upload Validation

```javascript
const fileInput = document.querySelector('input[type="file"]');
const file = fileInput.files[0];

// Client-side validation (NOT security, only UX)
const MAX_SIZE = 5 * 1024 * 1024; // 5MB
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'application/pdf'];

if (file.size > MAX_SIZE) {
  alert('File too large');
  return;
}

if (!ALLOWED_TYPES.includes(file.type)) {
  alert('Invalid file type');
  return;
}

fd.append('upload', file);
```

**Critical**: Client-side validation is bypassable. Always validate file type, size, and content on the server.

#### CSRF Protection

```javascript
// Include CSRF token in FormData
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
fd.append('_csrf', csrfToken);

// Or use custom header (requires JSON, not FormData)
fetch('/api/endpoint', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': csrfToken
  },
  body: fd
});
```

#### Content Security and Sanitization

```javascript
// Sanitize text inputs before appending
function sanitizeInput(value) {
  const div = document.createElement('div');
  div.textContent = value;
  return div.innerHTML;
}

fd.append('username', sanitizeInput(userInput));
```

**[Inference]** Server-side sanitization remains necessary regardless of client-side measures.

### Performance Optimization

#### Large File Handling

```javascript
// Check file size before appending
const largeFile = fileInput.files[0];

if (largeFile.size > 100 * 1024 * 1024) { // 100MB
  // Consider chunked upload strategy instead
  uploadFileInChunks(largeFile);
} else {
  fd.append('file', largeFile);
}
```

#### Memory Considerations

FormData holds file references, not copies. Memory impact depends on file sizes:

```javascript
// Multiple large files
const files = fileInput.files;
const fd = new FormData();

// All files reference original File objects
// No significant memory duplication
for (const file of files) {
  fd.append('files[]', file);
}
```

**[Inference]** FormData itself is lightweight; memory consumption primarily depends on the referenced File/Blob objects.

#### Streaming Alternatives

For very large uploads or progress tracking:

```javascript
// ReadableStream for large file uploads
async function uploadWithProgress(file) {
  const reader = file.stream().getReader();
  const chunks = [];
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    chunks.push(value);
    // Report progress
  }
  
  const blob = new Blob(chunks);
  fd.append('file', blob, file.name);
}
```

### Testing and Debugging

#### Inspecting FormData Contents

```javascript
// Log all entries
console.log('FormData contents:');
for (const [key, value] of fd.entries()) {
  if (value instanceof File) {
    console.log(`${key}: File(${value.name}, ${value.size} bytes, ${value.type})`);
  } else if (value instanceof Blob) {
    console.log(`${key}: Blob(${value.size} bytes, ${value.type})`);
  } else {
    console.log(`${key}: ${value}`);
  }
}

// Count entries
let entryCount = 0;
for (const _ of fd) entryCount++;
console.log(`Total entries: ${entryCount}`);
```

#### Mock FormData for Testing

```javascript
// Create test FormData with mock files
const mockFile = new File(['test content'], 'test.txt', { type: 'text/plain' });
const testFd = new FormData();
testFd.append('file', mockFile);
testFd.append('username', 'testuser');

// Verify contents
expect(testFd.get('username')).toBe('testuser');
expect(testFd.get('file')).toBeInstanceOf(File);
```

### Common Pitfalls

#### Forgotten Content-Type

```javascript
// WRONG: Manually setting Content-Type
fetch('/api/upload', {
  method: 'POST',
  headers: {
    'Content-Type': 'multipart/form-data' // Missing boundary!
  },
  body: fd
});

// CORRECT: Omit Content-Type for FormData
fetch('/api/upload', {
  method: 'POST',
  body: fd // Browser sets correct header with boundary
});
```

#### Converting to String

```javascript
// WRONG: FormData.toString() doesn't serialize data
console.log(fd.toString()); // "[object FormData]"

// CORRECT: Iterate to inspect
for (const pair of fd.entries()) {
  console.log(pair);
}
```

#### Assuming Synchronous File Reading

```javascript
// WRONG: File content isn't immediately available as text
const file = fileInput.files[0];
console.log(file.text()); // Returns Promise, not string

// CORRECT: Use async/await
const text = await file.text();
console.log(text);
```

### Framework Integration

#### React Example

```javascript
function UploadForm() {
  const handleSubmit = async (e) => {
    e.preventDefault();
    const form = e.target;
    const fd = new FormData(form);
    
    // Add React state values not in form
    fd.append('user_id', userId);
    
    const response = await fetch('/api/upload', {
      method: 'POST',
      body: fd
    });
    
    const result = await response.json();
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input name="title" required />
      <input type="file" name="file" required />
      <button type="submit">Upload</button>
    </form>
  );
}
```

#### Vue Example

```javascript
export default {
  methods: {
    async handleSubmit() {
      const form = this.$refs.form;
      const fd = new FormData(form);
      
      // Add component data
      fd.append('extra_data', this.extraData);
      
      await fetch('/api/upload', {
        method: 'POST',
        body: fd
      });
    }
  }
}
```

#### Axios Integration

```javascript
const fd = new FormData();
fd.append('file', fileInput.files[0]);

axios.post('/api/upload', fd, {
  headers: {
    // Axios sets correct Content-Type automatically
  },
  onUploadProgress: (progressEvent) => {
    const percentCompleted = Math.round(
      (progressEvent.loaded * 100) / progressEvent.total
    );
    console.log(percentCompleted);
  }
});
```

### Alternative Encoding Formats

#### When to Use application/x-www-form-urlencoded

```javascript
// For simple text data without files
const params = new URLSearchParams();
params.append('username', 'john');
params.append('email', 'john@example.com');

fetch('/api/endpoint', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: params
});
```

URL-encoded format is more compact for text-only data but cannot handle binary files.

#### When to Use application/json

```javascript
// For complex nested structures without files
const data = {
  user: {
    name: 'John',
    preferences: {
      theme: 'dark',
      notifications: ['email', 'sms']
    }
  }
};

fetch('/api/endpoint', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});
```

JSON encoding preserves data types and nesting but cannot directly include files (requires base64 encoding or separate upload).

### Specification and Standards

FormData is defined in the XMLHttpRequest specification and the Fetch specification. The interface is part of the WHATWG standards and continues to evolve with web platform capabilities.

**[Unverified]** Future enhancements may include standardized nested object syntax or improved streaming capabilities, but specific roadmap items are subject to change based on working group consensus.

---

