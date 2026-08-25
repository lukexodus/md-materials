## Input Validation


### Client-Side vs Server-Side Validation

Client-side validation provides immediate feedback and reduces server load, but is **never sufficient alone** because:

- JavaScript can be disabled
- HTTP requests can be crafted directly, bypassing the browser
- Browser developer tools allow DOM manipulation
- Automated tools can submit data without executing client-side code

Server-side validation is **mandatory** for security. Client-side validation is a user experience enhancement.

```javascript
// Client-side: UX enhancement
function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// Server-side: Security requirement
// Must validate again, regardless of client-side checks
```

### Input Sanitization vs Validation

**Validation**: Checking if input meets criteria (reject or accept) **Sanitization**: Transforming input to make it safe (modify)

```javascript
// Validation - reject invalid input
if (age < 0 || age > 150) {
  throw new Error('Invalid age');
}

// Sanitization - transform input
const sanitized = userInput.trim().toLowerCase();
const escaped = userInput.replace(/[<>]/g, '');
```

Different contexts require different approaches:

- User registration: Validate strictly
- Search queries: Sanitize for display, validate for SQL injection prevention
- HTML content: Sanitize using appropriate escaping/parsing libraries

### Common Validation Types

**String Length:**

```javascript
function validateLength(str, min, max) {
  const length = str.length; // Character count, not byte count
  return length >= min && length <= max;
}

// For Unicode-aware length (considering grapheme clusters)
function validateGraphemeLength(str, min, max) {
  const segmenter = new Intl.Segmenter('en', { granularity: 'grapheme' });
  const graphemes = [...segmenter.segment(str)];
  return graphemes.length >= min && graphemes.length <= max;
}
```

Note: `"👨‍👩‍👧‍👦".length` returns 11 (multiple code points), but represents one grapheme cluster.

**Numeric Ranges:**

```javascript
function validateRange(value, min, max, allowFloat = false) {
  const num = allowFloat ? parseFloat(value) : parseInt(value, 10);
  
  if (isNaN(num)) return false;
  if (!allowFloat && num !== parseFloat(value)) return false; // Rejects floats when integer required
  if (num < min || num > max) return false;
  
  return true;
}
```

**Pattern Matching:**

```javascript
// Email (basic pattern, not RFC 5322 compliant)
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Phone (US format example)
const phoneRegex = /^\+?1?\s*\(?(\d{3})\)?[-.\s]?(\d{3})[-.\s]?(\d{4})$/;

// URL
const urlRegex = /^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$/;

// Credit card (basic Luhn check required separately)
const creditCardRegex = /^(\d{4}[-\s]?){3}\d{4}$/;
```

[Unverified] Regex patterns for email validation cannot perfectly match the RFC 5322 specification due to its complexity. Production systems typically use simplified patterns combined with verification emails.

### Type Coercion Pitfalls

JavaScript's type coercion can cause validation bypasses:

```javascript
// Dangerous comparisons
'5' == 5        // true
'' == 0         // true
null == undefined // true
[5] == 5        // true
' \t\n' == 0    // true

// Safe validation
function validatePositiveInteger(value) {
  // Strict equality prevents type coercion
  return typeof value === 'number' && 
         Number.isInteger(value) && 
         value > 0;
}

// String to number conversion
const num = Number(input); // Preferred over parseInt/parseFloat for validation
if (Number.isNaN(num)) {
  // Invalid number
}
```

**ParseInt gotchas:**

```javascript
parseInt('08')      // 8
parseInt('08', 10)  // 8 (always specify radix)
parseInt('5.99')    // 5 (truncates)
parseInt('5 items') // 5 (ignores trailing characters)
parseInt('items 5') // NaN
```

### Whitelist vs Blacklist Approaches

**Whitelist (allow known good):**

```javascript
// Preferred: Only allow specific characters
function validateUsername(username) {
  return /^[a-zA-Z0-9_-]{3,20}$/.test(username);
}

// Only allow specific file extensions
const allowedExtensions = ['.jpg', '.png', '.gif', '.pdf'];
const isValid = allowedExtensions.some(ext => filename.toLowerCase().endsWith(ext));
```

**Blacklist (block known bad):**

```javascript
// Less secure: Try to block dangerous patterns
function containsDangerousChars(input) {
  return /[<>\"'%;()&\+]/.test(input);
}
```

Whitelist is **strongly preferred** because:

- New attack vectors don't require updates
- Impossible to anticipate all dangerous inputs
- Encoding variations can bypass blacklists (`<script>` vs `%3Cscript%3E`)

### Cross-Site Scripting (XSS) Prevention

**Context-aware escaping:**

```javascript
// HTML context
function escapeHtml(str) {
  const map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#x27;',
    '/': '&#x2F;'
  };
  return str.replace(/[&<>"'/]/g, char => map[char]);
}

// JavaScript context (in <script> tags or event handlers)
function escapeJs(str) {
  return str.replace(/[\\'"]/g, '\\$&')
            .replace(/\n/g, '\\n')
            .replace(/\r/g, '\\r');
}

// URL context
function escapeUrl(str) {
  return encodeURIComponent(str);
}

// CSS context
function escapeCss(str) {
  return str.replace(/[^a-zA-Z0-9]/g, char => {
    return '\\' + char.charCodeAt(0).toString(16) + ' ';
  });
}
```

**Modern approaches:**

```javascript
// Use DOM APIs instead of innerHTML
const textNode = document.createTextNode(userInput); // Cannot execute scripts
element.appendChild(textNode);

// Or textContent
element.textContent = userInput; // Treats as text, not HTML

// For HTML, use sanitization libraries
// DOMPurify, js-xss, sanitize-html
```

### SQL Injection Prevention

**Parameterized queries (required):**

```javascript
// Bad: String concatenation
const query = `SELECT * FROM users WHERE email = '${userEmail}'`;
// Vulnerable to: ' OR '1'='1

// Good: Parameterized
const query = 'SELECT * FROM users WHERE email = ?';
db.execute(query, [userEmail]);

// Or named parameters
const query = 'SELECT * FROM users WHERE email = :email';
db.execute(query, { email: userEmail });
```

**Input validation layers:**

```javascript
// Even with parameterized queries, validate input format
function validateEmailForDb(email) {
  // Length check
  if (email.length > 254) return false; // RFC 5321 max length
  
  // Format check
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return false;
  
  // Character whitelist
  if (!/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/.test(email)) {
    return false;
  }
  
  return true;
}
```

### File Upload Validation

**Multiple validation layers required:**

```javascript
// Client-side validation
function validateFile(file) {
  // Size check
  const maxSize = 5 * 1024 * 1024; // 5MB
  if (file.size > maxSize) {
    return { valid: false, error: 'File too large' };
  }
  
  // MIME type check (easily spoofed, not security layer)
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
  if (!allowedTypes.includes(file.type)) {
    return { valid: false, error: 'Invalid file type' };
  }
  
  // Extension check
  const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
  const ext = file.name.toLowerCase().substring(file.name.lastIndexOf('.'));
  if (!allowedExtensions.includes(ext)) {
    return { valid: false, error: 'Invalid file extension' };
  }
  
  return { valid: true };
}
```

**Server-side requirements:**

- Verify file signature (magic bytes) - first bytes of file content
- Re-encode images to strip metadata and potential exploits
- Store outside web root or with non-executable permissions
- Rename files to prevent directory traversal (`../../etc/passwd`)
- Scan with antivirus/malware detection

```javascript
// Check magic bytes (example for common image formats)
function verifyImageSignature(buffer) {
  const signatures = {
    jpeg: [0xFF, 0xD8, 0xFF],
    png: [0x89, 0x50, 0x4E, 0x47],
    gif: [0x47, 0x49, 0x46, 0x38]
  };
  
  for (const [type, sig] of Object.entries(signatures)) {
    if (sig.every((byte, i) => buffer[i] === byte)) {
      return type;
    }
  }
  
  return null;
}
```

### Date and Time Validation

```javascript
// ISO 8601 format validation
function validateISODate(dateStr) {
  const isoRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?$/;
  if (!isoRegex.test(dateStr)) return false;
  
  const date = new Date(dateStr);
  return !isNaN(date.getTime());
}

// Date range validation
function validateDateRange(dateStr, minDate, maxDate) {
  const date = new Date(dateStr);
  if (isNaN(date.getTime())) return false;
  
  const min = new Date(minDate);
  const max = new Date(maxDate);
  
  return date >= min && date <= max;
}

// Business date validation (no weekends)
function isBusinessDay(dateStr) {
  const date = new Date(dateStr);
  const day = date.getUTCDay();
  return day !== 0 && day !== 6; // 0 = Sunday, 6 = Saturday
}
```

### Regular Expression Security

**ReDoS (Regular Expression Denial of Service):**

```javascript
// Dangerous: Catastrophic backtracking
const bad = /^(a+)+$/;
const bad2 = /^(a|a)*$/;
const bad3 = /^(.*)*$/;

// Testing 'aaaaaaaaaaaaaaaaaaaaX' causes exponential time complexity
// Can freeze application

// Safe alternatives
const safe = /^a+$/;
const safe2 = /^a*$/;
```

Vulnerable patterns typically involve:

- Nested quantifiers: `(a+)+`, `(a*)*`
- Alternation with overlap: `(a|a)*`, `(a|ab)*`
- Overlapping character classes with quantifiers

**Mitigation strategies:**

```javascript
// Timeout for regex execution
function safeRegexTest(regex, input, timeoutMs = 100) {
  const worker = new Worker('regex-worker.js');
  
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      worker.terminate();
      reject(new Error('Regex timeout'));
    }, timeoutMs);
    
    worker.postMessage({ regex: regex.source, input });
    worker.onmessage = (e) => {
      clearTimeout(timeout);
      resolve(e.data.result);
    };
  });
}

// Or use fixed-time algorithms
// Library: safe-regex, rxxr2
```

### Unicode and Encoding Issues

**Normalization:**

```javascript
// Visual spoofing: café (different Unicode representations)
const str1 = 'café';     // NFC: é as single character (U+00E9)
const str2 = 'café';     // NFD: e + combining accent (U+0065 U+0301)

str1 === str2           // false
str1.length !== str2.length // true

// Normalize before comparison
function normalizeString(str) {
  return str.normalize('NFC'); // or 'NFD', 'NFKC', 'NFKD'
}

normalizeString(str1) === normalizeString(str2) // true
```

**Homograph attacks:**

```javascript
// Cyrillic 'а' (U+0430) looks identical to Latin 'a' (U+0061)
const latinA = 'a';
const cyrillicA = 'а';

latinA === cyrillicA // false

// Domain spoofing: раypal.com (Cyrillic 'а') vs paypal.com
function containsSuspiciousChars(str) {
  // Check for mixed scripts
  const scripts = new Set();
  for (const char of str) {
    const code = char.codePointAt(0);
    if (code >= 0x0400 && code <= 0x04FF) scripts.add('Cyrillic');
    else if (code >= 0x0020 && code <= 0x007F) scripts.add('Latin');
    // Add more script ranges as needed
  }
  return scripts.size > 1; // Mixed scripts
}
```

**Zero-width characters:**

```javascript
// Invisible characters for obfuscation
const text = 'admin\u200B'; // Contains zero-width space
text === 'admin' // false
text.trim() === 'admin' // false (trim doesn't remove zero-width)

// Remove zero-width characters
function removeZeroWidth(str) {
  return str.replace(/[\u200B-\u200D\uFEFF]/g, '');
}
```

### Length Limits and DoS Prevention

**Memory exhaustion:**

```javascript
// Validate input size before processing
function validateInputSize(input, maxBytes = 1024 * 1024) {
  // String length is character count, not byte count
  const encoder = new TextEncoder();
  const bytes = encoder.encode(input).length;
  
  return bytes <= maxBytes;
}

// Streaming validation for large inputs
async function validateLargeInput(stream, maxSize) {
  let totalSize = 0;
  const reader = stream.getReader();
  
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      
      totalSize += value.length;
      if (totalSize > maxSize) {
        throw new Error('Input exceeds maximum size');
      }
    }
  } finally {
    reader.releaseLock();
  }
}
```

**Computational limits:**

```javascript
// Limit complexity of operations
function validatePassword(password, maxComputationTime = 100) {
  const start = Date.now();
  
  // Expensive validation logic here
  const hasUpperCase = /[A-Z]/.test(password);
  const hasLowerCase = /[a-z]/.test(password);
  const hasNumbers = /\d/.test(password);
  const hasSpecial = /[!@#$%^&*]/.test(password);
  
  if (Date.now() - start > maxComputationTime) {
    throw new Error('Validation timeout');
  }
  
  return hasUpperCase && hasLowerCase && hasNumbers && hasSpecial;
}
```

### Validation Feedback Security

**Information disclosure:**

```javascript
// Bad: Reveals which field failed
if (!validateEmail(email)) {
  return { error: 'Invalid email address' };
}
if (!validatePassword(password)) {
  return { error: 'Invalid password' };
}

// For login: Don't reveal if user exists
// Bad
if (!userExists(email)) {
  return { error: 'User not found' };
}

// Good: Generic message
if (!userExists(email) || !passwordMatches(password)) {
  return { error: 'Invalid credentials' };
}
```

**Timing attacks:**

```javascript
// Bad: Early return reveals information through timing
function comparePasswords(input, stored) {
  if (input.length !== stored.length) return false;
  for (let i = 0; i < input.length; i++) {
    if (input[i] !== stored[i]) return false; // Early exit
  }
  return true;
}

// Good: Constant-time comparison
function constantTimeCompare(a, b) {
  if (a.length !== b.length) {
    b = a; // Make lengths match to keep timing constant
  }
  
  let mismatch = a.length !== b.length ? 1 : 0;
  for (let i = 0; i < a.length; i++) {
    mismatch |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return mismatch === 0;
}

// Or use built-in crypto.timingSafeEqual for buffers
```

### Cascading Validation

**Fail fast vs complete validation:**

```javascript
// Fail fast: Stop at first error (better UX for simple forms)
function validateUserFast(data) {
  if (!data.email) return { valid: false, error: 'Email required' };
  if (!validateEmail(data.email)) return { valid: false, error: 'Invalid email' };
  if (!data.password) return { valid: false, error: 'Password required' };
  if (data.password.length < 8) return { valid: false, error: 'Password too short' };
  
  return { valid: true };
}

// Complete validation: Collect all errors (better UX for complex forms)
function validateUserComplete(data) {
  const errors = {};
  
  if (!data.email) errors.email = 'Email required';
  else if (!validateEmail(data.email)) errors.email = 'Invalid email';
  
  if (!data.password) errors.password = 'Password required';
  else if (data.password.length < 8) errors.password = 'Password too short';
  
  if (!data.age) errors.age = 'Age required';
  else if (data.age < 18) errors.age = 'Must be 18 or older';
  
  return {
    valid: Object.keys(errors).length === 0,
    errors
  };
}
```

### Schema Validation Libraries

**Validation approaches:**

```javascript
// Joi
const Joi = require('joi');

const schema = Joi.object({
  email: Joi.string().email().required(),
  age: Joi.number().integer().min(0).max(150),
  password: Joi.string().min(8).pattern(/[A-Z]/).pattern(/[0-9]/)
});

const { error, value } = schema.validate(data);

// Yup
const yup = require('yup');

const schema = yup.object({
  email: yup.string().email().required(),
  age: yup.number().positive().integer().max(150),
  password: yup.string().min(8).matches(/[A-Z]/).matches(/[0-9]/)
});

await schema.validate(data);

// Zod (TypeScript-first)
const z = require('zod');

const schema = z.object({
  email: z.string().email(),
  age: z.number().int().positive().max(150),
  password: z.string().min(8).regex(/[A-Z]/).regex(/[0-9]/)
});

const result = schema.safeParse(data);
```

### Contextual Validation

**Business logic validation:**

```javascript
// Field-level validation alone is insufficient
function validateOrder(order) {
  // Field validation
  if (!order.quantity || order.quantity <= 0) {
    return { valid: false, error: 'Invalid quantity' };
  }
  
  // Business rule validation
  if (order.quantity > order.stockAvailable) {
    return { valid: false, error: 'Insufficient stock' };
  }
  
  // Cross-field validation
  if (order.discount > order.subtotal) {
    return { valid: false, error: 'Discount exceeds subtotal' };
  }
  
  // Temporal validation
  if (order.deliveryDate < new Date()) {
    return { valid: false, error: 'Delivery date must be in future' };
  }
  
  return { valid: true };
}
```

**State-dependent validation:**

```javascript
// Validation rules change based on state
function validateUserUpdate(user, updates, currentState) {
  // Email can only change if verified
  if (updates.email && updates.email !== user.email) {
    if (!currentState.isEmailVerified) {
      return { valid: false, error: 'Verify current email first' };
    }
  }
  
  // Role changes require admin privileges
  if (updates.role && updates.role !== user.role) {
    if (!currentState.isAdmin) {
      return { valid: false, error: 'Insufficient permissions' };
    }
  }
  
  return { valid: true };
}
```

---

