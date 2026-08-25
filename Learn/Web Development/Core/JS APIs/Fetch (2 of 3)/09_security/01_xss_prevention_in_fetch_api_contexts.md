## XSS Prevention in Fetch API Contexts


### Response Content Handling

When receiving data through fetch, the primary XSS risk occurs during **output rendering**, not during the fetch operation itself. The fetch API retrieves data as-is; vulnerabilities emerge when that data is inserted into the DOM.

**Critical principle**: Never use `innerHTML`, `outerHTML`, or `document.write()` with fetch responses containing user-generated or untrusted content.

```javascript
// Vulnerable
const response = await fetch('/api/comments');
const data = await response.json();
document.getElementById('container').innerHTML = data.comment; // XSS risk

// Safe
document.getElementById('container').textContent = data.comment;
```

### Content-Type Validation

Always verify response Content-Type headers before processing. Attackers may attempt to serve malicious content types.

```javascript
const response = await fetch('/api/data');
const contentType = response.headers.get('content-type');

if (!contentType || !contentType.includes('application/json')) {
  throw new Error('Invalid content type');
}

const data = await response.json();
```

### DOM Manipulation Strategies

**Safe text insertion**:

- `textContent` - Treats all content as plain text
- `createTextNode()` - Creates text nodes explicitly
- `setAttribute()` - For attribute values (with caveats)

**Controlled HTML rendering**:

```javascript
const data = await fetch('/api/content').then(r => r.json());

// Using DOMParser for HTML responses
const parser = new DOMParser();
const doc = parser.parseFromString(data.html, 'text/html');

// Sanitize before insertion
const sanitized = DOMPurify.sanitize(doc.body.innerHTML);
container.innerHTML = sanitized;
```

### URL Construction and Injection

Fetch URLs constructed from user input require validation:

```javascript
// Vulnerable
const userId = getUserInput();
fetch(`/api/users/${userId}`); // Path traversal or injection risk

// Protected
const userId = getUserInput();
if (!/^[a-zA-Z0-9_-]+$/.test(userId)) {
  throw new Error('Invalid user ID format');
}
fetch(`/api/users/${encodeURIComponent(userId)}`);
```

**URL parameter encoding**:

```javascript
const params = new URLSearchParams();
params.append('search', userInput); // Automatically encodes
params.append('filter', userFilter);

fetch(`/api/search?${params.toString()}`);
```

### JSON Response Processing

JSON responses are inherently safe from XSS **during parsing**, but require sanitization before DOM insertion:

```javascript
const response = await fetch('/api/user');
const user = await response.json();

// Safe: Structured rendering
const nameElement = document.createElement('span');
nameElement.textContent = user.name; // Escaped automatically
container.appendChild(nameElement);

// Unsafe: Direct HTML injection
container.innerHTML = `<span>${user.name}</span>`; // XSS if user.name contains HTML
```

### Template Literal Risks

Template literals in HTML contexts are high-risk:

```javascript
// Vulnerable
const data = await fetch('/api/message').then(r => r.json());
element.innerHTML = `<div class="message">${data.text}</div>`;

// Safe alternatives
const template = document.createElement('template');
template.innerHTML = '<div class="message"></div>';
const messageDiv = template.content.firstChild.cloneNode(true);
messageDiv.textContent = data.text;
element.appendChild(messageDiv);
```

### Sanitization Libraries

For scenarios requiring HTML rendering:

```javascript
// Using DOMPurify
import DOMPurify from 'dompurify';

const response = await fetch('/api/rich-content');
const data = await response.json();

const clean = DOMPurify.sanitize(data.html, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
  ALLOWED_ATTR: ['href']
});

container.innerHTML = clean;
```

### Event Handler Attributes

Never construct event handlers from fetch data:

```javascript
// Extremely vulnerable
const response = await fetch('/api/config');
const config = await response.json();
element.setAttribute('onclick', config.handler); // Direct XSS vector

// Safe: Attach listeners programmatically
element.addEventListener('click', () => {
  // Predefined, safe logic only
  handleClick(config.data);
});
```

### CSP Headers Integration

Content Security Policy provides defense-in-depth. When using fetch, ensure your CSP headers are configured:

```javascript
// Server should send:
// Content-Security-Policy: default-src 'self'; script-src 'self'

// Client-side verification (informational only)
const response = await fetch('/api/data');
const csp = response.headers.get('content-security-policy');
console.log('CSP active:', csp);
```

### Dynamic Script Loading Prevention

[Unverified - depends on specific CSP and execution context]: Fetch cannot directly execute scripts, but improper handling can enable script injection:

```javascript
// Vulnerable pattern
const scriptContent = await fetch('/api/script').then(r => r.text());
const script = document.createElement('script');
script.textContent = scriptContent; // Executes arbitrary code
document.body.appendChild(script);

// This pattern should never be used with untrusted sources
```

### Response Type Restrictions

Limit accepted response types:

```javascript
async function safeFetch(url, expectedType = 'json') {
  const response = await fetch(url);
  const contentType = response.headers.get('content-type');
  
  const typeMap = {
    'json': 'application/json',
    'text': 'text/plain',
    'html': 'text/html'
  };
  
  if (!contentType?.includes(typeMap[expectedType])) {
    throw new Error(`Expected ${expectedType}, got ${contentType}`);
  }
  
  return response[expectedType]();
}
```

### Framework-Specific Protections

**React**:

```javascript
function CommentDisplay() {
  const [comment, setComment] = useState('');
  
  useEffect(() => {
    fetch('/api/comment')
      .then(r => r.json())
      .then(data => setComment(data.text));
  }, []);
  
  // React escapes by default
  return <div>{comment}</div>; // Safe
  
  // Dangerous
  // return <div dangerouslySetInnerHTML={{__html: comment}} />; // Requires sanitization
}
```

**Vue**:

```javascript
// Template
<div>{{ comment }}</div> <!-- Safe: auto-escaped -->
<div v-html="comment"></div> <!-- Unsafe: requires sanitization -->

// Script
async mounted() {
  const response = await fetch('/api/comment');
  this.comment = await response.json();
}
```

### Blob and ObjectURL Handling

When creating object URLs from fetched data:

```javascript
const response = await fetch('/api/image');
const blob = await response.blob();
const url = URL.createObjectURL(blob);

// Safe for images
img.src = url;

// Dangerous for HTML blobs in iframes
// iframe.src = url; // Could execute scripts if blob contains HTML
```

### Credential and CORS Implications

While not directly XSS-related, improper credential handling can compound vulnerabilities:

```javascript
// Include credentials only when necessary
fetch('/api/data', {
  credentials: 'include' // Sends cookies - increases impact of XSS
});

// Prefer token-based auth in headers when possible
fetch('/api/data', {
  headers: {
    'Authorization': `Bearer ${token}` // Doesn't auto-send like cookies
  }
});
```

### Response Streaming Considerations

When processing streams, maintain the same sanitization discipline:

```javascript
const response = await fetch('/api/stream');
const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const {done, value} = await reader.read();
  if (done) break;
  
  const chunk = decoder.decode(value);
  
  // Still requires safe insertion
  const textNode = document.createTextNode(chunk);
  container.appendChild(textNode); // Safe
  
  // container.innerHTML += chunk; // Unsafe
}
```

### Subresource Integrity

For fetching external resources, verify integrity:

```javascript
// When loading third-party content
const response = await fetch('https://cdn.example.com/library.js');
const content = await response.text();

// Verify hash before executing
const hash = await crypto.subtle.digest('SHA-384', 
  new TextEncoder().encode(content));
const base64Hash = btoa(String.fromCharCode(...new Uint8Array(hash)));

if (base64Hash !== expectedHash) {
  throw new Error('Integrity check failed');
}
```

### Input Validation Before Fetch

Validate data before sending to prevent reflected XSS:

```javascript
function validateSearchTerm(term) {
  // Whitelist approach
  if (!/^[a-zA-Z0-9\s-]+$/.test(term)) {
    throw new Error('Invalid search term');
  }
  return term;
}

const searchTerm = validateSearchTerm(userInput);
const response = await fetch(`/api/search?q=${encodeURIComponent(searchTerm)}`);
```

---

