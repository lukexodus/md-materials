## Safe HTML Insertion


### Direct DOM Manipulation Risks

When inserting HTML content into the DOM, the primary security concern is Cross-Site Scripting (XSS). Untrusted HTML can contain malicious scripts that execute in the user's browser context, potentially stealing credentials, session tokens, or performing unauthorized actions.

**High-risk patterns:**

- `element.innerHTML = userContent`
- `document.write(userContent)`
- `element.outerHTML = userContent`
- `insertAdjacentHTML()` with untrusted content

These methods parse HTML strings and execute any embedded scripts, event handlers, or JavaScript URLs.

### Safe Insertion Methods

#### textContent for Plain Text

The safest approach when you don't need HTML formatting:

```javascript
element.textContent = userInput;
```

This treats all content as plain text. Special characters like `<`, `>`, `&` are automatically escaped and displayed literally rather than interpreted as HTML. Scripts cannot execute because no HTML parsing occurs.

#### createElement with Controlled Attributes

Building DOM nodes programmatically:

```javascript
const div = document.createElement('div');
div.textContent = userContent;
div.className = sanitizedClassName;
div.setAttribute('data-id', userId);
parent.appendChild(div);
```

This approach constructs elements explicitly, allowing precise control over each attribute and preventing injection through HTML parsing.

#### Document Fragments for Complex Structures

When building multiple elements:

```javascript
const fragment = document.createDocumentFragment();
items.forEach(item => {
  const li = document.createElement('li');
  li.textContent = item.name;
  fragment.appendChild(li);
});
list.appendChild(fragment);
```

Document fragments batch DOM operations and avoid reflows while maintaining safety through programmatic construction.

### HTML Sanitization Libraries

When you must accept HTML input, use dedicated sanitization libraries that parse and clean HTML according to security policies.

#### DOMPurify

The most widely-adopted sanitization library:

```javascript
import DOMPurify from 'dompurify';

const clean = DOMPurify.sanitize(dirtyHTML);
element.innerHTML = clean;
```

**Configuration options:**

```javascript
const clean = DOMPurify.sanitize(dirty, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p'],
  ALLOWED_ATTR: ['href', 'title'],
  ALLOW_DATA_ATTR: false,
  KEEP_CONTENT: true,
  RETURN_DOM: false,
  RETURN_DOM_FRAGMENT: false
});
```

**What DOMPurify removes:**

- `<script>` tags and their content
- Event handlers (`onclick`, `onerror`, `onload`, etc.)
- JavaScript URLs (`javascript:`, `data:text/html`)
- Dangerous attributes (`formaction`, `form`)
- SVG/MathML elements that can execute scripts
- CSS expressions and behaviors
- Object, embed, and applet elements

**Hook system for custom processing:**

```javascript
DOMPurify.addHook('afterSanitizeAttributes', (node) => {
  if (node.hasAttribute('target')) {
    node.setAttribute('target', '_blank');
    node.setAttribute('rel', 'noopener noreferrer');
  }
});
```

#### sanitize-html (Node.js/Server-side)

For server-side sanitization:

```javascript
const sanitizeHtml = require('sanitize-html');

const clean = sanitizeHtml(dirty, {
  allowedTags: ['b', 'i', 'em', 'strong', 'a'],
  allowedAttributes: {
    'a': ['href']
  },
  allowedSchemes: ['http', 'https', 'mailto']
});
```

### Content Security Policy Integration

CSP headers provide defense-in-depth by restricting script execution even if sanitization fails:

```
Content-Security-Policy: 
  default-src 'self'; 
  script-src 'self' 'nonce-{random}'; 
  object-src 'none'; 
  base-uri 'self';
```

**Key directives for HTML insertion safety:**

- `script-src`: Controls which scripts can execute (use nonces or hashes, avoid `'unsafe-inline'`)
- `object-src 'none'`: Prevents plugins like Flash
- `base-uri 'self'`: Prevents `<base>` tag injection that could redirect relative URLs
- `require-trusted-types-for 'script'`: Enforces Trusted Types API

### Trusted Types API

Modern browsers support Trusted Types, which enforce that only sanitized values can be assigned to injection sinks:

```javascript
// Define a policy
const escapePolicy = trustedTypes.createPolicy('escapePolicy', {
  createHTML: (string) => DOMPurify.sanitize(string)
});

// Use the policy
element.innerHTML = escapePolicy.createHTML(userInput);
```

**Without a policy in strict mode:**

```javascript
// This throws a TypeError when Trusted Types are enforced
element.innerHTML = userInput; // TypeError: Failed to set innerHTML
```

**CSP header to enforce:**

```
Content-Security-Policy: require-trusted-types-for 'script'
```

[Inference] This prevents accidental unsafe assignments by forcing all innerHTML/outerHTML assignments through declared policies.

### Framework-Specific Approaches

#### React

React escapes values by default:

```jsx
// Safe - content is escaped
<div>{userContent}</div>
```

**Dangerous pattern to avoid:**

```jsx
// Bypasses escaping - only use with sanitized content
<div dangerouslySetInnerHTML={{__html: userContent}} />
```

**Safe usage with DOMPurify:**

```jsx
<div dangerouslySetInnerHTML={{
  __html: DOMPurify.sanitize(userContent)
}} />
```

#### Vue

Vue also escapes by default:

```vue
<!-- Safe - escaped -->
<div>{{ userContent }}</div>

<!-- Dangerous - renders raw HTML -->
<div v-html="userContent"></div>
```

**Safe pattern:**

```vue
<div v-html="$sanitize(userContent)"></div>
```

With vue-dompurify-html plugin or custom sanitization method.

#### Angular

Angular escapes interpolated values:

```typescript
// Safe - escaped
<div>{{ userContent }}</div>

// Bypasses security - requires explicit trust
<div [innerHTML]="trustedContent"></div>
```

**Sanitization through DomSanitizer:**

```typescript
import { DomSanitizer } from '@angular/platform-browser';

constructor(private sanitizer: DomSanitizer) {}

getTrustedHTML(html: string) {
  const clean = DOMPurify.sanitize(html);
  return this.sanitizer.bypassSecurityTrustHtml(clean);
}
```

### Markdown as Safer Alternative

When users need formatting capabilities, Markdown parsers with HTML sanitization provide better security defaults:

```javascript
import marked from 'marked';
import DOMPurify from 'dompurify';

const html = marked.parse(userMarkdown);
const clean = DOMPurify.sanitize(html);
element.innerHTML = clean;
```

**marked with built-in sanitization:**

```javascript
marked.setOptions({
  sanitize: true,
  sanitizer: (html) => DOMPurify.sanitize(html)
});
```

### Template Literals and Tagged Templates

Template literals can create injection vulnerabilities:

```javascript
// UNSAFE - user content interpreted as HTML
element.innerHTML = `<div class="${userClass}">${userContent}</div>`;
```

**Tagged template for safe escaping:**

```javascript
function html(strings, ...values) {
  return strings.reduce((result, string, i) => {
    const value = values[i - 1];
    const escaped = String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#x27;');
    return result + escaped + string;
  });
}

element.innerHTML = html`<div class="${userClass}">${userContent}</div>`;
```

### Context-Specific Escaping

Different contexts require different escaping strategies:

#### HTML Content Context

```javascript
function escapeHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;');
}
```

#### HTML Attribute Context

Requires additional escaping for spaces and control characters:

```javascript
function escapeHtmlAttr(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;');
}
```

#### JavaScript String Context

Never insert untrusted data directly into JavaScript:

```javascript
// UNSAFE
const script = `<script>var name = "${userName}";</script>`;

// Better: Use data attributes and read with JavaScript
<div data-name="${escapeHtmlAttr(userName)}"></div>
<script>
  const name = element.dataset.name; // Safely retrieved
</script>
```

#### URL Context

```javascript
function escapeUrl(str) {
  return encodeURIComponent(str);
}

// Validate URL schemes
function isSafeUrl(url) {
  const allowed = /^(https?|mailto|tel):/i;
  return allowed.test(url);
}
```

### Common Injection Vectors

#### Event Handlers in Attributes

```html
<!-- Malicious input -->
<img src=x onerror="alert('XSS')">
<a href="#" onclick="alert('XSS')">click</a>
```

DOMPurify removes these by default.

#### JavaScript URLs

```html
<a href="javascript:alert('XSS')">click</a>
<iframe src="javascript:alert('XSS')"></iframe>
```

Sanitizers block `javascript:` protocol.

#### Data URLs with HTML

```html
<object data="data:text/html,<script>alert('XSS')</script>"></object>
<iframe src="data:text/html,<script>alert('XSS')</script>"></iframe>
```

CSP `object-src` and sanitizer configuration prevents this.

#### Style Attributes and CSS Injection

```html
<div style="background: url('javascript:alert(1)')"></div>
<style>@import 'javascript:alert(1)';</style>
```

DOMPurify removes dangerous CSS expressions.

#### SVG Scripts

```html
<svg><script>alert('XSS')</script></svg>
<svg><foreignObject><body onload="alert('XSS')"></body></foreignObject></svg>
```

Sanitizers must be configured to handle SVG-specific vectors.

### Server-Side vs Client-Side Sanitization

**Server-side advantages:**

- Single point of control
- Reduced attack surface (client JavaScript can be disabled)
- Consistent sanitization across all clients
- Better for SEO and initial page load

**Client-side advantages:**

- Dynamic content without server round-trip
- Real-time preview for user-generated content
- Works with static hosting

**Best practice:** Sanitize on both server and client for defense-in-depth.

### Testing HTML Sanitization

#### XSS Payloads for Testing

```javascript
const testPayloads = [
  '<script>alert("XSS")</script>',
  '<img src=x onerror=alert("XSS")>',
  '<svg onload=alert("XSS")>',
  '<iframe src="javascript:alert(\'XSS\')">',
  '<input onfocus=alert("XSS") autofocus>',
  '<select onfocus=alert("XSS") autofocus>',
  '<textarea onfocus=alert("XSS") autofocus>',
  '<body onload=alert("XSS")>',
  '<marquee onstart=alert("XSS")>',
  '<details open ontoggle=alert("XSS")>',
  '"><script>alert(String.fromCharCode(88,83,83))</script>',
  '<base href="javascript:alert(\'XSS\');//">'
];
```

#### Automated Testing

```javascript
describe('HTML Sanitization', () => {
  testPayloads.forEach(payload => {
    it(`should neutralize: ${payload}`, () => {
      const clean = DOMPurify.sanitize(payload);
      expect(clean).not.toContain('<script');
      expect(clean).not.toContain('onerror=');
      expect(clean).not.toContain('javascript:');
    });
  });
});
```

### Performance Considerations

**Sanitization cost:**

- DOMPurify processes ~1-10MB/s depending on content complexity
- Caching sanitized content reduces overhead
- Consider sanitizing on server for frequently-displayed content

**Optimization strategies:**

```javascript
// Cache sanitized content
const sanitizeCache = new Map();

function cachedSanitize(html) {
  if (sanitizeCache.has(html)) {
    return sanitizeCache.get(html);
  }
  const clean = DOMPurify.sanitize(html);
  sanitizeCache.set(html, clean);
  return clean;
}

// Limit cache size to prevent memory issues
if (sanitizeCache.size > 1000) {
  const firstKey = sanitizeCache.keys().next().value;
  sanitizeCache.delete(firstKey);
}
```

### Allowlist vs Blocklist Approaches

**Allowlist (recommended):** Define permitted tags, attributes, and protocols explicitly.

```javascript
const cleanHtml = DOMPurify.sanitize(dirty, {
  ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'a'],
  ALLOWED_ATTR: ['href', 'title'],
  ALLOWED_URI_REGEXP: /^https?:/
});
```

**Blocklist (not recommended):** Attempting to block all dangerous patterns is error-prone due to:

- New attack vectors discovered regularly
- Browser parsing quirks
- Encoding variations (UTF-8, UTF-7, HTML entities)
- Mutation XSS (mXSS) where sanitized HTML becomes dangerous after re-parsing

[Inference] Allowlists are more secure because they fail closed—anything not explicitly permitted is removed.

### Mutation XSS (mXSS)

Some HTML can appear safe after initial sanitization but become dangerous when the browser re-parses it:

```javascript
// Input
<noscript><p title="</noscript><img src=x onerror=alert(1)>">

// After sanitization in HTML context
<noscript><p title="&lt;/noscript&gt;&lt;img src=x onerror=alert(1)&gt;"></p></noscript>

// After browser parses inside innerHTML
<img src=x onerror=alert(1)> (executes!)
```

DOMPurify includes mXSS protection, but older or custom sanitizers may be vulnerable. [Inference] This demonstrates why using well-maintained, security-focused libraries is important rather than implementing custom sanitization.

### Rich Text Editors

When implementing WYSIWYG editors:

```javascript
// TinyMCE with sanitization
tinymce.init({
  selector: '#editor',
  plugins: 'code',
  valid_elements: 'p,br,strong/b,em/i,a[href|title]',
  extended_valid_elements: '',
  invalid_elements: 'script,style',
  cleanup: true
});

// Sanitize output before storage/display
const editorContent = tinymce.activeEditor.getContent();
const sanitized = DOMPurify.sanitize(editorContent);
```

**Never trust editor output without sanitization:** Editors have vulnerabilities, and users can manipulate DOM/network requests to bypass client-side validation.

---

