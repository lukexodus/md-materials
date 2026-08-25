## Input Validation


### URL Validation

#### URL Format Validation

The Fetch API accepts various URL formats, but not all inputs are valid:

```javascript
// Valid URLs
fetch('https://example.com');
fetch('http://example.com/api');
fetch('/api/endpoint');  // Relative URL
fetch('//cdn.example.com/file.js');  // Protocol-relative

// Invalid URLs - throw TypeError
fetch('not a url');
fetch('ht!tp://invalid');
fetch('javascript:alert(1)');  // Blocked for security
```

**Validation approaches:**

```javascript
function isValidURL(string) {
  try {
    new URL(string, window.location.origin);
    return true;
  } catch (e) {
    return false;
  }
}

// Usage
if (isValidURL(userInput)) {
  await fetch(userInput);
} else {
  throw new Error('Invalid URL format');
}
```

**URL constructor validation:**

```javascript
function validateAndNormalize(url) {
  try {
    const parsed = new URL(url, window.location.origin);
    
    // Additional checks
    if (!['http:', 'https:'].includes(parsed.protocol)) {
      throw new Error('Only HTTP/HTTPS protocols allowed');
    }
    
    return parsed.href;
  } catch (e) {
    throw new Error(`Invalid URL: ${e.message}`);
  }
}
```

#### Protocol Restrictions

Fetch has built-in protocol restrictions for security:

**Allowed protocols:**

- `http:`
- `https:`
- `data:` (with limitations)
- `blob:`
- `file:` (limited context)

**Blocked protocols:**

- `javascript:` - XSS vector
- `vbscript:` - XSS vector
- `data:text/html` - Can execute scripts
- `file:` - Usually blocked in web contexts

```javascript
function validateProtocol(url) {
  const parsed = new URL(url, window.location.origin);
  const allowed = ['http:', 'https:'];
  
  if (!allowed.includes(parsed.protocol)) {
    throw new Error(`Protocol ${parsed.protocol} not allowed`);
  }
  
  return url;
}
```

#### Domain Whitelisting

Restrict requests to trusted domains:

```javascript
class DomainValidator {
  constructor(allowedDomains) {
    this.allowedDomains = new Set(allowedDomains);
  }
  
  validate(url) {
    const parsed = new URL(url, window.location.origin);
    
    // Check exact domain match
    if (this.allowedDomains.has(parsed.hostname)) {
      return true;
    }
    
    // Check subdomain wildcards
    for (const domain of this.allowedDomains) {
      if (domain.startsWith('*.')) {
        const baseDomain = domain.slice(2);
        if (parsed.hostname.endsWith(baseDomain)) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  async fetch(url, options) {
    if (!this.validate(url)) {
      throw new Error(`Domain not allowed: ${new URL(url).hostname}`);
    }
    return fetch(url, options);
  }
}

// Usage
const validator = new DomainValidator([
  'api.example.com',
  '*.cdn.example.com',
  'example.com'
]);

await validator.fetch('https://api.example.com/data');
```

#### Path Traversal Prevention

Prevent directory traversal attacks in URL paths:

```javascript
function sanitizePath(path) {
  // Remove path traversal sequences
  const normalized = path
    .replace(/\\/g, '/')  // Normalize slashes
    .replace(/\/+/g, '/')  // Remove duplicate slashes
    .replace(/\/\.\.\//g, '/')  // Remove ../
    .replace(/\/\.\//g, '/')  // Remove ./
    .replace(/^\.\.\//, '');  // Remove leading ../
  
  // Ensure no traversal attempts remain
  if (normalized.includes('..')) {
    throw new Error('Path traversal detected');
  }
  
  return normalized;
}

// Usage
const userPath = sanitizePath(userInput);
await fetch(`/api/files/${userPath}`);
```

**More robust validation:**

```javascript
function validatePath(basePath, userPath) {
  const path = require('path');  // Node.js
  const normalized = path.normalize(userPath);
  const absolute = path.resolve(basePath, normalized);
  
  // Ensure path stays within base directory
  if (!absolute.startsWith(path.resolve(basePath))) {
    throw new Error('Path traversal attempt detected');
  }
  
  return absolute;
}
```

#### Query Parameter Validation

Validate and sanitize query parameters:

```javascript
function validateQueryParams(params) {
  const allowedParams = new Set(['page', 'limit', 'sort', 'filter']);
  const validated = {};
  
  for (const [key, value] of Object.entries(params)) {
    // Check if parameter is allowed
    if (!allowedParams.has(key)) {
      throw new Error(`Parameter '${key}' not allowed`);
    }
    
    // Validate parameter value
    switch (key) {
      case 'page':
      case 'limit':
        const num = parseInt(value, 10);
        if (isNaN(num) || num < 1 || num > 1000) {
          throw new Error(`Invalid ${key} value`);
        }
        validated[key] = num;
        break;
        
      case 'sort':
        if (!/^[a-zA-Z_]+$/.test(value)) {
          throw new Error('Invalid sort field');
        }
        validated[key] = value;
        break;
        
      case 'filter':
        // Sanitize filter value
        validated[key] = value.replace(/[^\w\s-]/g, '');
        break;
    }
  }
  
  return validated;
}

// Usage
const params = validateQueryParams({ page: '1', limit: '50' });
const query = new URLSearchParams(params);
await fetch(`/api/data?${query}`);
```

### Header Validation

#### Header Name Validation

Fetch API enforces header name restrictions:

**Forbidden header names (controlled by browser):**

- `Accept-Charset`
- `Accept-Encoding`
- `Access-Control-Request-Headers`
- `Access-Control-Request-Method`
- `Connection`
- `Content-Length`
- `Cookie`
- `Cookie2`
- `Date`
- `DNT`
- `Expect`
- `Host`
- `Keep-Alive`
- `Origin`
- `Referer`
- `TE`
- `Trailer`
- `Transfer-Encoding`
- `Upgrade`
- `Via`
- Headers starting with `Proxy-` or `Sec-`

```javascript
function isValidHeaderName(name) {
  // Forbidden headers
  const forbidden = new Set([
    'accept-charset', 'accept-encoding', 'access-control-request-headers',
    'access-control-request-method', 'connection', 'content-length',
    'cookie', 'cookie2', 'date', 'dnt', 'expect', 'host',
    'keep-alive', 'origin', 'referer', 'te', 'trailer',
    'transfer-encoding', 'upgrade', 'via'
  ]);
  
  const lower = name.toLowerCase();
  
  if (forbidden.has(lower)) {
    return false;
  }
  
  if (lower.startsWith('proxy-') || lower.startsWith('sec-')) {
    return false;
  }
  
  // Valid header name pattern
  return /^[a-zA-Z0-9!#$%&'*+\-.^_`|~]+$/.test(name);
}

// Usage
if (isValidHeaderName(userHeaderName)) {
  await fetch(url, {
    headers: { [userHeaderName]: value }
  });
}
```

#### Header Value Validation

Header values must follow HTTP field-value format:

```javascript
function validateHeaderValue(value) {
  // Convert to string
  const str = String(value);
  
  // Check for invalid characters
  // Header values can contain visible ASCII and whitespace
  if (!/^[\x20-\x7E\t]*$/.test(str)) {
    throw new Error('Invalid header value characters');
  }
  
  // Check for CRLF injection
  if (str.includes('\r') || str.includes('\n')) {
    throw new Error('CRLF injection attempt detected');
  }
  
  return str.trim();
}

// Usage
const safeValue = validateHeaderValue(userInput);
await fetch(url, {
  headers: { 'X-Custom-Header': safeValue }
});
```

#### Content-Type Validation

Validate Content-Type headers for API requests:

```javascript
function validateContentType(contentType) {
  const allowed = new Set([
    'application/json',
    'application/x-www-form-urlencoded',
    'multipart/form-data',
    'text/plain',
    'application/xml',
    'text/xml'
  ]);
  
  // Extract MIME type without parameters
  const mimeType = contentType.split(';')[0].trim().toLowerCase();
  
  if (!allowed.has(mimeType)) {
    throw new Error(`Content-Type '${mimeType}' not allowed`);
  }
  
  return contentType;
}

// Usage
const contentType = validateContentType(userContentType);
await fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': contentType },
  body: data
});
```

#### Authorization Header Validation

Validate authorization tokens:

```javascript
function validateBearerToken(token) {
  // Basic format check
  if (typeof token !== 'string' || token.length === 0) {
    throw new Error('Invalid token format');
  }
  
  // Check for JWT format (if using JWTs)
  const jwtPattern = /^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$/;
  if (!jwtPattern.test(token)) {
    throw new Error('Invalid JWT token format');
  }
  
  // Length validation
  if (token.length > 4096) {
    throw new Error('Token too long');
  }
  
  return token;
}

// Usage
const token = validateBearerToken(userToken);
await fetch(url, {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

#### Custom Header Validation Wrapper

```javascript
class HeaderValidator {
  constructor(rules) {
    this.rules = rules;
  }
  
  validate(headers) {
    const validated = {};
    
    for (const [name, value] of Object.entries(headers)) {
      const lower = name.toLowerCase();
      
      // Check if header is allowed
      if (!this.rules[lower]) {
        throw new Error(`Header '${name}' not allowed`);
      }
      
      // Apply validation rule
      const rule = this.rules[lower];
      const validatedValue = rule(value);
      
      validated[name] = validatedValue;
    }
    
    return validated;
  }
}

// Define rules
const validator = new HeaderValidator({
  'content-type': (v) => {
    const allowed = ['application/json', 'text/plain'];
    if (!allowed.includes(v.split(';')[0].trim())) {
      throw new Error('Invalid Content-Type');
    }
    return v;
  },
  'x-api-key': (v) => {
    if (!/^[a-zA-Z0-9]{32}$/.test(v)) {
      throw new Error('Invalid API key format');
    }
    return v;
  },
  'authorization': (v) => {
    if (!v.startsWith('Bearer ')) {
      throw new Error('Authorization must use Bearer scheme');
    }
    return v;
  }
});

// Usage
const headers = validator.validate({
  'Content-Type': 'application/json',
  'X-API-Key': 'abcd1234...'
});

await fetch(url, { headers });
```

### Body Validation

#### JSON Payload Validation

Validate JSON structure before sending:

```javascript
function validateJSON(data, schema) {
  // Type checking
  if (typeof data !== 'object' || data === null) {
    throw new Error('Payload must be an object');
  }
  
  // Required fields
  for (const field of schema.required || []) {
    if (!(field in data)) {
      throw new Error(`Missing required field: ${field}`);
    }
  }
  
  // Field validation
  for (const [key, value] of Object.entries(data)) {
    const fieldSchema = schema.properties?.[key];
    
    if (!fieldSchema) {
      if (!schema.additionalProperties) {
        throw new Error(`Unexpected field: ${key}`);
      }
      continue;
    }
    
    // Type validation
    const actualType = Array.isArray(value) ? 'array' : typeof value;
    if (fieldSchema.type && actualType !== fieldSchema.type) {
      throw new Error(`Field '${key}' must be ${fieldSchema.type}`);
    }
    
    // String validation
    if (fieldSchema.type === 'string') {
      if (fieldSchema.minLength && value.length < fieldSchema.minLength) {
        throw new Error(`Field '${key}' too short`);
      }
      if (fieldSchema.maxLength && value.length > fieldSchema.maxLength) {
        throw new Error(`Field '${key}' too long`);
      }
      if (fieldSchema.pattern && !new RegExp(fieldSchema.pattern).test(value)) {
        throw new Error(`Field '${key}' invalid format`);
      }
    }
    
    // Number validation
    if (fieldSchema.type === 'number') {
      if (fieldSchema.minimum !== undefined && value < fieldSchema.minimum) {
        throw new Error(`Field '${key}' below minimum`);
      }
      if (fieldSchema.maximum !== undefined && value > fieldSchema.maximum) {
        throw new Error(`Field '${key}' above maximum`);
      }
    }
    
    // Array validation
    if (fieldSchema.type === 'array') {
      if (fieldSchema.minItems && value.length < fieldSchema.minItems) {
        throw new Error(`Field '${key}' needs at least ${fieldSchema.minItems} items`);
      }
      if (fieldSchema.maxItems && value.length > fieldSchema.maxItems) {
        throw new Error(`Field '${key}' has too many items`);
      }
    }
  }
  
  return data;
}

// Schema definition
const userSchema = {
  required: ['username', 'email'],
  properties: {
    username: {
      type: 'string',
      minLength: 3,
      maxLength: 20,
      pattern: '^[a-zA-Z0-9_]+$'
    },
    email: {
      type: 'string',
      pattern: '^[\\w.-]+@[\\w.-]+\\.\\w+$'
    },
    age: {
      type: 'number',
      minimum: 13,
      maximum: 120
    }
  },
  additionalProperties: false
};

// Usage
try {
  const validated = validateJSON(userData, userSchema);
  await fetch('/api/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(validated)
  });
} catch (e) {
  console.error('Validation error:', e.message);
}
```

#### Size Limits

Enforce payload size restrictions:

```javascript
function validateSize(data, maxSize = 1024 * 1024) { // 1MB default
  let size;
  
  if (typeof data === 'string') {
    size = new Blob([data]).size;
  } else if (data instanceof Blob || data instanceof File) {
    size = data.size;
  } else if (data instanceof ArrayBuffer) {
    size = data.byteLength;
  } else if (ArrayBuffer.isView(data)) {
    size = data.byteLength;
  } else if (data instanceof FormData) {
    // FormData size is harder to determine exactly
    // Estimate or reject if too uncertain
    throw new Error('Cannot validate FormData size client-side');
  } else {
    // For objects, stringify first
    size = new Blob([JSON.stringify(data)]).size;
  }
  
  if (size > maxSize) {
    throw new Error(`Payload too large: ${size} bytes (max: ${maxSize})`);
  }
  
  return data;
}

// Usage
const maxSize = 5 * 1024 * 1024; // 5MB
validateSize(requestBody, maxSize);
await fetch(url, {
  method: 'POST',
  body: requestBody
});
```

#### Data Sanitization

Remove potentially dangerous content:

```javascript
function sanitizeObject(obj, maxDepth = 5, currentDepth = 0) {
  if (currentDepth > maxDepth) {
    throw new Error('Object too deeply nested');
  }
  
  if (obj === null || typeof obj !== 'object') {
    return sanitizeValue(obj);
  }
  
  if (Array.isArray(obj)) {
    return obj.map(item => sanitizeObject(item, maxDepth, currentDepth + 1));
  }
  
  const sanitized = {};
  for (const [key, value] of Object.entries(obj)) {
    // Sanitize key
    const safeKey = sanitizeKey(key);
    
    // Recursively sanitize value
    sanitized[safeKey] = sanitizeObject(value, maxDepth, currentDepth + 1);
  }
  
  return sanitized;
}

function sanitizeKey(key) {
  // Remove potentially dangerous characters from keys
  return key.replace(/[^\w.-]/g, '_');
}

function sanitizeValue(value) {
  if (typeof value === 'string') {
    // Remove control characters
    return value.replace(/[\x00-\x1F\x7F]/g, '');
  }
  return value;
}

// Usage
const sanitized = sanitizeObject(userInput);
await fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(sanitized)
});
```

#### FormData Validation

Validate multipart form data:

```javascript
function validateFormData(formData, schema) {
  const validated = new FormData();
  
  for (const [name, value] of formData.entries()) {
    const fieldSchema = schema[name];
    
    if (!fieldSchema) {
      throw new Error(`Unexpected field: ${name}`);
    }
    
    if (value instanceof File) {
      // File validation
      if (fieldSchema.type !== 'file') {
        throw new Error(`Field '${name}' should not be a file`);
      }
      
      // File size
      if (fieldSchema.maxSize && value.size > fieldSchema.maxSize) {
        throw new Error(`File '${name}' too large`);
      }
      
      // File type
      if (fieldSchema.accept) {
        const allowedTypes = fieldSchema.accept.split(',').map(t => t.trim());
        const matches = allowedTypes.some(type => {
          if (type.endsWith('/*')) {
            return value.type.startsWith(type.slice(0, -1));
          }
          return value.type === type;
        });
        
        if (!matches) {
          throw new Error(`File '${name}' has invalid type: ${value.type}`);
        }
      }
      
      validated.append(name, value);
    } else {
      // Text field validation
      const str = String(value);
      
      if (fieldSchema.maxLength && str.length > fieldSchema.maxLength) {
        throw new Error(`Field '${name}' too long`);
      }
      
      if (fieldSchema.pattern && !new RegExp(fieldSchema.pattern).test(str)) {
        throw new Error(`Field '${name}' invalid format`);
      }
      
      validated.append(name, str);
    }
  }
  
  // Check required fields
  for (const [name, schema] of Object.entries(schema)) {
    if (schema.required && !formData.has(name)) {
      throw new Error(`Missing required field: ${name}`);
    }
  }
  
  return validated;
}

// Schema
const formSchema = {
  username: {
    type: 'text',
    required: true,
    maxLength: 50,
    pattern: '^[a-zA-Z0-9_]+$'
  },
  avatar: {
    type: 'file',
    required: false,
    maxSize: 5 * 1024 * 1024, // 5MB
    accept: 'image/jpeg,image/png,image/webp'
  }
};

// Usage
const validated = validateFormData(formData, formSchema);
await fetch('/api/upload', {
  method: 'POST',
  body: validated
});
```

### Method Validation

#### HTTP Method Validation

Ensure valid HTTP methods:

```javascript
function validateMethod(method) {
  const validMethods = new Set([
    'GET', 'POST', 'PUT', 'DELETE', 'PATCH',
    'HEAD', 'OPTIONS', 'CONNECT', 'TRACE'
  ]);
  
  const upper = method.toUpperCase();
  
  if (!validMethods.has(upper)) {
    throw new Error(`Invalid HTTP method: ${method}`);
  }
  
  return upper;
}

// With restrictions
function validateMethodWithPolicy(method, allowedMethods) {
  const upper = method.toUpperCase();
  const allowed = new Set(allowedMethods.map(m => m.toUpperCase()));
  
  if (!allowed.has(upper)) {
    throw new Error(`Method '${upper}' not allowed`);
  }
  
  return upper;
}

// Usage
const method = validateMethodWithPolicy(userMethod, ['GET', 'POST']);
await fetch(url, { method });
```

#### Method-Body Consistency

Validate that method and body are consistent:

```javascript
function validateMethodBodyConsistency(method, body) {
  const upper = method.toUpperCase();
  const methodsWithoutBody = new Set(['GET', 'HEAD', 'OPTIONS']);
  
  if (methodsWithoutBody.has(upper) && body !== null && body !== undefined) {
    throw new Error(`${upper} requests cannot have a body`);
  }
  
  const methodsWithBody = new Set(['POST', 'PUT', 'PATCH']);
  if (methodsWithBody.has(upper) && (body === null || body === undefined)) {
    console.warn(`${upper} request typically requires a body`);
  }
}

// Usage
validateMethodBodyConsistency('GET', requestBody); // Throws
validateMethodBodyConsistency('POST', requestBody); // OK
```

### Options Validation

#### Credentials Validation

Validate credentials mode:

```javascript
function validateCredentials(credentials) {
  const valid = new Set(['omit', 'same-origin', 'include']);
  
  if (!valid.has(credentials)) {
    throw new Error(`Invalid credentials mode: ${credentials}`);
  }
  
  return credentials;
}

// Context-aware validation
function validateCredentialsForURL(credentials, url) {
  const parsed = new URL(url, window.location.origin);
  
  if (credentials === 'include' && parsed.origin !== window.location.origin) {
    console.warn('Using credentials: include for cross-origin request');
  }
  
  return credentials;
}
```

#### Mode Validation

Validate request mode:

```javascript
function validateMode(mode) {
  const valid = new Set(['cors', 'no-cors', 'same-origin', 'navigate']);
  
  if (!valid.has(mode)) {
    throw new Error(`Invalid mode: ${mode}`);
  }
  
  return mode;
}

// With restrictions
function validateModeRestrictions(mode, method, hasCustomHeaders) {
  if (mode === 'no-cors') {
    const allowedMethods = new Set(['GET', 'HEAD', 'POST']);
    if (!allowedMethods.has(method.toUpperCase())) {
      throw new Error(`Method ${method} not allowed in no-cors mode`);
    }
    
    if (hasCustomHeaders) {
      throw new Error('Custom headers not allowed in no-cors mode');
    }
  }
  
  return mode;
}
```

#### Cache Validation

Validate cache mode:

```javascript
function validateCache(cache) {
  const valid = new Set([
    'default', 'no-store', 'reload', 'no-cache',
    'force-cache', 'only-if-cached'
  ]);
  
  if (!valid.has(cache)) {
    throw new Error(`Invalid cache mode: ${cache}`);
  }
  
  return cache;
}

// Mode-specific validation
function validateCacheForMode(cache, mode) {
  if (cache === 'only-if-cached' && mode !== 'same-origin') {
    throw new Error('only-if-cached requires same-origin mode');
  }
  
  return cache;
}
```

#### Redirect Validation

Validate redirect mode:

```javascript
function validateRedirect(redirect) {
  const valid = new Set(['follow', 'error', 'manual']);
  
  if (!valid.has(redirect)) {
    throw new Error(`Invalid redirect mode: ${redirect}`);
  }
  
  return redirect;
}
```

### Comprehensive Validation Wrapper

#### Request Validator Class

```javascript
class RequestValidator {
  constructor(config = {}) {
    this.config = {
      maxUrlLength: 2048,
      maxHeaderSize: 8192,
      maxBodySize: 10 * 1024 * 1024, // 10MB
      allowedDomains: null,
      allowedMethods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
      allowedHeaders: null, // null = all allowed
      requireHTTPS: false,
      ...config
    };
  }
  
  validateURL(url) {
    // Length check
    if (url.length > this.config.maxUrlLength) {
      throw new Error('URL too long');
    }
    
    // Parse and validate
    let parsed;
    try {
      parsed = new URL(url, window.location.origin);
    } catch (e) {
      throw new Error(`Invalid URL: ${e.message}`);
    }
    
    // Protocol check
    if (!['http:', 'https:'].includes(parsed.protocol)) {
      throw new Error('Only HTTP/HTTPS protocols allowed');
    }
    
    // HTTPS requirement
    if (this.config.requireHTTPS && parsed.protocol !== 'https:') {
      throw new Error('HTTPS required');
    }
    
    // Domain whitelist
    if (this.config.allowedDomains) {
      const allowed = this.config.allowedDomains.some(domain => {
        if (domain.startsWith('*.')) {
          return parsed.hostname.endsWith(domain.slice(2));
        }
        return parsed.hostname === domain;
      });
      
      if (!allowed) {
        throw new Error(`Domain not allowed: ${parsed.hostname}`);
      }
    }
    
    return parsed.href;
  }
  
  validateMethod(method) {
    const upper = method.toUpperCase();
    
    if (!this.config.allowedMethods.includes(upper)) {
      throw new Error(`Method not allowed: ${upper}`);
    }
    
    return upper;
  }
  
  validateHeaders(headers) {
    if (!headers) return {};
    
    const validated = {};
    let totalSize = 0;
    
    for (const [name, value] of Object.entries(headers)) {
      // Header name validation
      if (!/^[a-zA-Z0-9!#$%&'*+\-.^_`|~]+$/.test(name)) {
        throw new Error(`Invalid header name: ${name}`);
      }
      
      // Whitelist check
      if (this.config.allowedHeaders) {
        if (!this.config.allowedHeaders.includes(name.toLowerCase())) {
          throw new Error(`Header not allowed: ${name}`);
        }
      }
      
      // Value validation
      const str = String(value);
      if (str.includes('\r') || str.includes('\n')) {
        throw new Error('Header value contains CRLF');
      }
      
      totalSize += name.length + str.length + 4; // +4 for ": " and "\r\n"
      validated[name] = str;
    }
    
    // Total header size check
    if (totalSize > this.config.maxHeaderSize) {
      throw new Error('Headers too large');
    }
    
    return validated;
  }
  
  validateBody(body) {
    if (body === null || body === undefined) {
      return body;
    }
    
    let size;
    
    if (typeof body === 'string') {
      size = new Blob([body]).size;
    } else if (body instanceof Blob || body instanceof File) {
      size = body.size;
    } else if (body instanceof ArrayBuffer) {
      size = body.byteLength;
    } else if (ArrayBuffer.isView(body)) {
      size = body.byteLength;
    } else {
      // Estimate for other types
      size = new Blob([JSON.stringify(body)]).size;
    }
    
    if (size > this.config.maxBodySize) {
      throw new Error(`Body too large: ${size} bytes`);
    }
    
    return body;
  }
  
  validateOptions(options) {
    const validated = { ...options };
    
    // Validate mode
    if (options.mode) {
      const validModes = new Set(['cors', 'no-cors', 'same-origin']);
      if (!validModes.has(options.mode)) {
        throw new Error(`Invalid mode: ${options.mode}`);
      }
    }
    
    // Validate credentials
    if (options.credentials) {
      const validCreds = new Set(['omit', 'same-origin', 'include']);
      if (!validCreds.has(options.credentials)) {
        throw new Error(`Invalid credentials: ${options.credentials}`);
      }
    }
    
    // Validate cache
    if (options.cache) {
      const validCache = new Set([
        'default', 'no-store', 'reload', 'no-cache',
        'force-cache', 'only-if-cached'
      ]);
      if (!validCache.has(options.cache)) {
        throw new Error(`Invalid cache: ${options.cache}`);
      }
      
      // only-if-cached requires same-origin
      if (options.cache === 'only-if-cached' && options.mode !== 'same-origin') {
        throw new Error('only-if-cached requires same-origin mode');
      }
    }
    
    // Validate redirect
    if (options.redirect) {
      const validRedirect = new Set(['follow', 'error', 'manual']);
      if (!validRedirect.has(options.redirect)) {
        throw new Error(`Invalid redirect: ${options.redirect}`);
      }
    }
    
    return validated;
  }
  
  async fetch(url, options = {}) {
    // Validate all components
    const validURL = this.validateURL(url);
    const validMethod = this.validateMethod(options.method || 'GET');
    const validHeaders = this.validateHeaders(options.headers);
    const validBody = this.validateBody(options.body);
    const validOptions = this.validateOptions(options);
    
    // Method-body consistency
    const methodsWithoutBody = new Set(['GET', 'HEAD', 'OPTIONS']);
    if (methodsWithoutBody.has(validMethod) && validBody) {
      throw new Error(`${validMethod} requests cannot have a body`);
    }
    
    // Execute request
    return fetch(validURL, {
      ...validOptions,
      method: validMethod,
      headers: validHeaders,
      body: validBody
    });
  }
}

// Usage
const validator = new RequestValidator({
  allowedDomains: ['api.example.com', '*.cdn.example.com'],
  maxBodySize: 5 * 1024 * 1024,
  requireHTTPS: true
});

await validator.fetch('https://api.example.com/data', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(data)
});
```

### Security-Focused Validation

#### XSS Prevention in URLs

```javascript
function preventXSSInURL(url) {
  const parsed = new URL(url, window.location.origin);
  
  // Check for javascript: protocol
  if (parsed.protocol === 'javascript:') {
    throw new Error('JavaScript URLs not allowed');
  }
  
  // Check for data URLs with HTML
  if (parsed.protocol === 'data:') {
    const [mediaType] = parsed.pathname.split(',');
    if (mediaType.toLowerCase().includes('text/html')) {
      throw new Error('data: URLs with HTML not allowed');
  }
  }
  
  // Check for encoded javascript:
  const decoded = decodeURIComponent(url);
  if (decoded.toLowerCase().startsWith('javascript:')) {
    throw new Error('Encoded JavaScript URLs not allowed');
  }
  
  return url;
}
```

#### SQL Injection Prevention

When building URLs with user input:

```javascript
function sanitizeForURL(value) {
  // Remove SQL-like keywords and characters
  const dangerous = [
    "'", '"', ';', '--', '/*', '*/', 'xp_', 'sp_',
    'exec', 'execute', 'select', 'insert', 'update', 'delete',
    'drop', 'create', 'alter', 'union', 'script'
  ];
  
  let sanitized = String(value);
  
  for (const pattern of dangerous) {
    const regex = new RegExp(pattern, 'gi');
    sanitized = sanitized.replace(regex, '');
  }
  
  // Also encode for URL
  return encodeURIComponent(sanitized);
}

// Usage
const userId = sanitizeForURL(userInput);
await fetch(`/api/users/${userId}`);
```

**Note:** This client-side sanitization is not a complete defense. [Inference] Server-side parameterized queries or prepared statements are necessary for SQL injection protection.

#### SSRF Prevention

Prevent Server-Side Request Forgery by blocking internal addresses:

```javascript
function preventSSRF(url) {
  const parsed = new URL(url);
  const hostname = parsed.hostname.toLowerCase();
  
  // Block localhost
  if (hostname === 'localhost' || hostname === '127.0.0.1') {
    throw new Error('Localhost not allowed');
  }
  
  // Block loopback range
  if (hostname.startsWith('127.')) {
    throw new Error('Loopback addresses not allowed');
  }
  
  // Block private IP ranges
  const privateRanges = [
    /^10\./,
    /^172\.(1[6-9]|2[0-9]|3[0-1])\./,
    /^192\.168\./,
    /^169\.254\./ // Link-local
  ];
  
  for (const range of privateRanges) {
    if (range.test(hostname)) {
      throw new Error('Private IP addresses not allowed');
    }
  }
  
  // Block IPv6 localhost
  if (hostname === '::1' || hostname === '[::1]') {
    throw new Error('IPv6 localhost not allowed');
  }
  
  // Block metadata endpoints (cloud providers)
  const metadataHosts = [
    '169.254.169.254', // AWS, Azure, GCP
    'metadata.google.internal'
  ];
  
  if (metadataHosts.includes(hostname)) {
    throw new Error('Metadata endpoints not allowed');
  }
  
  return url;
}
```

**Important:** [Inference] Client-side SSRF prevention provides minimal security. Server-side validation is essential as attackers can bypass client-side checks.

#### CRLF Injection Prevention

Prevent header injection attacks:

```javascript
function preventCRLFInjection(value) {
  const str = String(value);
  
  // Check for CRLF sequences
  if (/\r|\n/.test(str)) {
    throw new Error('CRLF injection attempt detected');
  }
  
  // Check for encoded CRLF
  const decoded = decodeURIComponent(str);
  if (/\r|\n|%0d|%0a/i.test(decoded)) {
    throw new Error('Encoded CRLF injection attempt detected');
  }
  
  return str;
}

// Usage in headers
const safeValue = preventCRLFInjection(userInput);
await fetch(url, {
  headers: { 'X-Custom-Header': safeValue }
});
```

### Type-Safe Validation

#### TypeScript Integration

```typescript
interface ValidationSchema {
  type: 'string' | 'number' | 'boolean' | 'array' | 'object';
  required?: boolean;
  minLength?: number;
  maxLength?: number;
  minimum?: number;
  maximum?: number;
  pattern?: string;
  properties?: Record<string, ValidationSchema>;
  items?: ValidationSchema;
}

interface ValidatedRequest {
  url: string;
  method: string;
  headers: Record<string, string>;
  body?: any;
}

class TypedRequestValidator {
  validate<T>(data: unknown, schema: ValidationSchema): T {
    this.validateValue(data, schema, 'root');
    return data as T;
  }
  
  private validateValue(value: unknown, schema: ValidationSchema, path: string): void {
    // Null/undefined check
    if (value === null || value === undefined) {
      if (schema.required) {
        throw new Error(`${path} is required`);
      }
      return;
    }
    
    // Type check
    const actualType = Array.isArray(value) ? 'array' : typeof value;
    if (actualType !== schema.type) {
      throw new Error(`${path} must be ${schema.type}, got ${actualType}`);
    }
    
    // Type-specific validation
    switch (schema.type) {
      case 'string':
        this.validateString(value as string, schema, path);
        break;
      case 'number':
        this.validateNumber(value as number, schema, path);
        break;
      case 'array':
        this.validateArray(value as unknown[], schema, path);
        break;
      case 'object':
        this.validateObject(value as Record<string, unknown>, schema, path);
        break;
    }
  }
  
  private validateString(value: string, schema: ValidationSchema, path: string): void {
    if (schema.minLength && value.length < schema.minLength) {
      throw new Error(`${path} must be at least ${schema.minLength} characters`);
    }
    if (schema.maxLength && value.length > schema.maxLength) {
      throw new Error(`${path} must be at most ${schema.maxLength} characters`);
    }
    if (schema.pattern && !new RegExp(schema.pattern).test(value)) {
      throw new Error(`${path} does not match required pattern`);
    }
  }
  
  private validateNumber(value: number, schema: ValidationSchema, path: string): void {
    if (schema.minimum !== undefined && value < schema.minimum) {
      throw new Error(`${path} must be at least ${schema.minimum}`);
    }
    if (schema.maximum !== undefined && value > schema.maximum) {
      throw new Error(`${path} must be at most ${schema.maximum}`);
    }
  }
  
  private validateArray(value: unknown[], schema: ValidationSchema, path: string): void {
    if (schema.items) {
      value.forEach((item, index) => {
        this.validateValue(item, schema.items!, `${path}[${index}]`);
      });
    }
  }
  
  private validateObject(
    value: Record<string, unknown>,
    schema: ValidationSchema,
    path: string
  ): void {
    if (schema.properties) {
      for (const [key, propSchema] of Object.entries(schema.properties)) {
        this.validateValue(value[key], propSchema, `${path}.${key}`);
      }
    }
  }
}

// Usage
interface User {
  username: string;
  email: string;
  age?: number;
}

const userSchema: ValidationSchema = {
  type: 'object',
  properties: {
    username: {
      type: 'string',
      required: true,
      minLength: 3,
      maxLength: 20,
      pattern: '^[a-zA-Z0-9_]+
    },
    email: {
      type: 'string',
      required: true,
      pattern: '^[\\w.-]+@[\\w.-]+\\.\\w+
    },
    age: {
      type: 'number',
      minimum: 13,
      maximum: 120
    }
  }
};

const validator = new TypedRequestValidator();
const user = validator.validate<User>(userData, userSchema);

await fetch('/api/users', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(user)
});
```

### Testing Validation

#### Unit Tests for Validators

```javascript
// Example test suite
describe('URL Validation', () => {
  const validator = new RequestValidator();
  
  test('accepts valid HTTPS URLs', () => {
    expect(() => {
      validator.validateURL('https://api.example.com/data');
    }).not.toThrow();
  });
  
  test('rejects javascript: protocol', () => {
    expect(() => {
      validator.validateURL('javascript:alert(1)');
    }).toThrow('Only HTTP/HTTPS protocols allowed');
  });
  
  test('rejects URLs exceeding length limit', () => {
    const longURL = 'https://example.com/' + 'a'.repeat(3000);
    expect(() => {
      validator.validateURL(longURL);
    }).toThrow('URL too long');
  });
  
  test('enforces domain whitelist', () => {
    const restrictedValidator = new RequestValidator({
      allowedDomains: ['example.com']
    });
    
    expect(() => {
      restrictedValidator.validateURL('https://evil.com');
    }).toThrow('Domain not allowed');
  });
});

describe('Header Validation', () => {
  const validator = new RequestValidator();
  
  test('accepts valid headers', () => {
    const headers = { 'Content-Type': 'application/json' };
    expect(() => {
      validator.validateHeaders(headers);
    }).not.toThrow();
  });
  
  test('rejects headers with CRLF', () => {
    const headers = { 'X-Custom': 'value\r\nX-Injected: evil' };
    expect(() => {
      validator.validateHeaders(headers);
    }).toThrow('Header value contains CRLF');
  });
  
  test('enforces header size limit', () => {
    const largeValue = 'x'.repeat(10000);
    const headers = { 'X-Large': largeValue };
    expect(() => {
      validator.validateHeaders(headers);
    }).toThrow('Headers too large');
  });
});
```

### Error Handling

#### Validation Error Class

```javascript
class ValidationError extends Error {
  constructor(message, field, value) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
    this.value = value;
    this.timestamp = new Date();
  }
  
  toJSON() {
    return {
      error: this.name,
      message: this.message,
      field: this.field,
      timestamp: this.timestamp.toISOString()
    };
  }
}

// Usage
function validateEmail(email) {
  const pattern = /^[\w.-]+@[\w.-]+\.\w+$/;
  if (!pattern.test(email)) {
    throw new ValidationError(
      'Invalid email format',
      'email',
      email
    );
  }
  return email;
}

try {
  const email = validateEmail(userInput);
  await fetch('/api/users', {
    method: 'POST',
    body: JSON.stringify({ email })
  });
} catch (error) {
  if (error instanceof ValidationError) {
    console.error('Validation failed:', error.toJSON());
    // Show user-friendly error message
  } else {
    throw error;
  }
}
```

#### Graceful Degradation

```javascript
async function safeFetch(url, options = {}) {
  const validator = new RequestValidator();
  
  try {
    // Attempt validation
    return await validator.fetch(url, options);
  } catch (error) {
    if (error instanceof ValidationError) {
      // Log validation error
      console.error('Validation failed:', error.message);
      
      // Optionally: attempt request anyway with logging
      console.warn('Attempting request despite validation failure');
      return fetch(url, options);
    }
    throw error;
  }
}
```

### Best Practices

1. **Validate early** - Check inputs before constructing requests
2. **Use whitelists over blacklists** - Explicitly allow known-good values
3. **Layer validation** - Client-side validation improves UX, but server-side is essential for security
4. **Provide clear error messages** - Help developers identify validation failures quickly
5. **Log validation failures** - Track attempted invalid requests for security monitoring
6. **Test edge cases** - Include boundary values, empty strings, null, undefined, special characters
7. **Consider performance** - Complex validation on every request can impact performance
8. **Keep validators reusable** - Design validation functions for multiple contexts
9. **Document validation rules** - Make requirements clear to API consumers
10. **Version validation schemas** - Allow evolution without breaking existing clients

[Inference] These client-side validation patterns improve user experience and catch errors early, but should never be the sole security mechanism. Server-side validation remains essential for security.

---

