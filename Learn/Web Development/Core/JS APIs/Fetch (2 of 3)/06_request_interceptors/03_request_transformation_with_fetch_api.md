## Request Transformation with Fetch API


### Header Transformation

#### Adding Custom Headers

```javascript
const response = await fetch('/api/data', {
  headers: {
    'Content-Type': 'application/json',
    'X-API-Key': 'your-api-key',
    'X-Request-ID': crypto.randomUUID(),
    'Accept-Language': 'en-US',
    'X-Client-Version': '1.0.0'
  }
});
```

#### Dynamic Header Generation

```javascript
function createHeaders(options = {}) {
  const headers = new Headers();
  
  // Base headers
  headers.set('Content-Type', options.contentType || 'application/json');
  headers.set('Accept', options.accept || 'application/json');
  
  // Authentication
  if (options.token) {
    headers.set('Authorization', `Bearer ${options.token}`);
  }
  
  // Correlation ID for tracing
  headers.set('X-Correlation-ID', options.correlationId || crypto.randomUUID());
  
  // Client metadata
  headers.set('X-Client-Platform', navigator.platform);
  headers.set('X-Client-Timestamp', new Date().toISOString());
  
  // Custom headers
  if (options.customHeaders) {
    Object.entries(options.customHeaders).forEach(([key, value]) => {
      headers.set(key, value);
    });
  }
  
  return headers;
}

// Usage
const response = await fetch('/api/data', {
  headers: createHeaders({
    token: localStorage.getItem('authToken'),
    customHeaders: {
      'X-Feature-Flag': 'new-ui'
    }
  })
});
```

#### Conditional Headers

```javascript
async function fetchWithConditionalHeaders(url, options = {}) {
  const headers = new Headers(options.headers);
  
  // Add ETag for caching
  const cachedETag = localStorage.getItem(`etag:${url}`);
  if (cachedETag) {
    headers.set('If-None-Match', cachedETag);
  }
  
  // Add Last-Modified for conditional requests
  const lastModified = localStorage.getItem(`lastModified:${url}`);
  if (lastModified) {
    headers.set('If-Modified-Since', lastModified);
  }
  
  // Add compression support
  headers.set('Accept-Encoding', 'gzip, deflate, br');
  
  const response = await fetch(url, {
    ...options,
    headers
  });
  
  // Cache validation headers
  if (response.status === 200) {
    const etag = response.headers.get('ETag');
    const lastMod = response.headers.get('Last-Modified');
    
    if (etag) localStorage.setItem(`etag:${url}`, etag);
    if (lastMod) localStorage.setItem(`lastModified:${url}`, lastMod);
  }
  
  return response;
}
```

#### Header Normalization

```javascript
function normalizeHeaders(headers) {
  const normalized = new Headers();
  
  Object.entries(headers).forEach(([key, value]) => {
    // Convert to kebab-case
    const normalizedKey = key
      .replace(/([a-z])([A-Z])/g, '$1-$2')
      .toLowerCase();
    
    // Trim whitespace
    const normalizedValue = String(value).trim();
    
    // Skip empty values
    if (normalizedValue) {
      normalized.set(normalizedKey, normalizedValue);
    }
  });
  
  return normalized;
}
```

### Body Transformation

#### JSON to FormData

```javascript
function jsonToFormData(obj, formData = new FormData(), parentKey = '') {
  Object.entries(obj).forEach(([key, value]) => {
    const fullKey = parentKey ? `${parentKey}[${key}]` : key;
    
    if (value === null || value === undefined) {
      return;
    }
    
    if (value instanceof File || value instanceof Blob) {
      formData.append(fullKey, value);
    } else if (Array.isArray(value)) {
      value.forEach((item, index) => {
        if (typeof item === 'object' && !(item instanceof File)) {
          jsonToFormData(item, formData, `${fullKey}[${index}]`);
        } else {
          formData.append(`${fullKey}[]`, item);
        }
      });
    } else if (typeof value === 'object' && !(value instanceof Date)) {
      jsonToFormData(value, formData, fullKey);
    } else {
      formData.append(fullKey, value);
    }
  });
  
  return formData;
}

// Usage
const data = {
  name: 'John',
  age: 30,
  tags: ['developer', 'designer'],
  profile: {
    bio: 'Hello world',
    avatar: fileInput.files[0]
  }
};

const response = await fetch('/api/users', {
  method: 'POST',
  body: jsonToFormData(data)
});
```

#### JSON Serialization with Transformation

```javascript
function transformAndSerialize(data, transformers = {}) {
  const transformed = JSON.parse(JSON.stringify(data)); // Deep clone
  
  function transform(obj, path = '') {
    Object.entries(obj).forEach(([key, value]) => {
      const currentPath = path ? `${path}.${key}` : key;
      
      // Apply field-specific transformer
      if (transformers[currentPath]) {
        obj[key] = transformers[currentPath](value);
      }
      
      // Recursively transform nested objects
      if (value && typeof value === 'object' && !Array.isArray(value)) {
        transform(value, currentPath);
      }
    });
  }
  
  transform(transformed);
  return JSON.stringify(transformed);
}

// Usage
const data = {
  user: {
    email: 'user@example.com',
    createdAt: new Date(),
    price: 19.99
  }
};

const body = transformAndSerialize(data, {
  'user.email': (email) => email.toLowerCase(),
  'user.createdAt': (date) => date.toISOString(),
  'user.price': (price) => Math.round(price * 100) // Convert to cents
});

await fetch('/api/users', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body
});
```

#### Nested Object Flattening

```javascript
function flattenObject(obj, prefix = '', separator = '.') {
  return Object.entries(obj).reduce((acc, [key, value]) => {
    const newKey = prefix ? `${prefix}${separator}${key}` : key;
    
    if (value && typeof value === 'object' && !Array.isArray(value) && 
        !(value instanceof Date) && !(value instanceof File)) {
      Object.assign(acc, flattenObject(value, newKey, separator));
    } else {
      acc[newKey] = value;
    }
    
    return acc;
  }, {});
}

// Usage
const nested = {
  user: {
    profile: {
      name: 'John',
      address: {
        city: 'NYC'
      }
    }
  }
};

const flattened = flattenObject(nested);
// Result: { 'user.profile.name': 'John', 'user.profile.address.city': 'NYC' }

await fetch('/api/data', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(flattened)
});
```

#### Array to Query String

```javascript
function arrayToQueryString(arr, paramName) {
  // Multiple approaches based on API requirements
  
  // Approach 1: Repeated parameter names
  // tags=a&tags=b&tags=c
  const repeated = arr.map(val => `${paramName}=${encodeURIComponent(val)}`).join('&');
  
  // Approach 2: Bracket notation
  // tags[]=a&tags[]=b&tags[]=c
  const brackets = arr.map(val => `${paramName}[]=${encodeURIComponent(val)}`).join('&');
  
  // Approach 3: Comma-separated
  // tags=a,b,c
  const commaSeparated = `${paramName}=${arr.map(encodeURIComponent).join(',')}`;
  
  // Approach 4: Indexed
  // tags[0]=a&tags[1]=b&tags[2]=c
  const indexed = arr.map((val, i) => 
    `${paramName}[${i}]=${encodeURIComponent(val)}`
  ).join('&');
  
  return { repeated, brackets, commaSeparated, indexed };
}
```

#### Binary Data Transformation

```javascript
async function transformBinaryData(file, options = {}) {
  // Convert to ArrayBuffer
  const arrayBuffer = await file.arrayBuffer();
  
  // Transform to Uint8Array
  const uint8Array = new Uint8Array(arrayBuffer);
  
  // Apply transformations
  if (options.encrypt) {
    // Example: XOR cipher (use proper encryption in production)
    const key = options.encryptionKey || 0x42;
    for (let i = 0; i < uint8Array.length; i++) {
      uint8Array[i] ^= key;
    }
  }
  
  // Convert to Blob with new MIME type
  const blob = new Blob([uint8Array], { 
    type: options.mimeType || file.type 
  });
  
  return blob;
}

// Usage
const transformedBlob = await transformBinaryData(file, {
  encrypt: true,
  encryptionKey: 0x5A,
  mimeType: 'application/octet-stream'
});

await fetch('/api/upload', {
  method: 'POST',
  body: transformedBlob
});
```

#### Base64 Encoding/Decoding

```javascript
async function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result.split(',')[1]);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

function base64ToBlob(base64, mimeType) {
  const byteCharacters = atob(base64);
  const byteNumbers = new Array(byteCharacters.length);
  
  for (let i = 0; i < byteCharacters.length; i++) {
    byteNumbers[i] = byteCharacters.charCodeAt(i);
  }
  
  const byteArray = new Uint8Array(byteNumbers);
  return new Blob([byteArray], { type: mimeType });
}

// Usage: Send file as base64 in JSON
const base64Data = await fileToBase64(file);
await fetch('/api/upload', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    filename: file.name,
    data: base64Data,
    mimeType: file.type
  })
});
```

### URL Transformation

#### Query Parameter Building

```javascript
function buildQueryString(params) {
  const searchParams = new URLSearchParams();
  
  Object.entries(params).forEach(([key, value]) => {
    if (value === null || value === undefined) {
      return; // Skip null/undefined
    }
    
    if (Array.isArray(value)) {
      value.forEach(v => searchParams.append(key, v));
    } else if (typeof value === 'object') {
      searchParams.append(key, JSON.stringify(value));
    } else {
      searchParams.append(key, value);
    }
  });
  
  return searchParams.toString();
}

// Usage
const params = {
  search: 'javascript',
  tags: ['fetch', 'api'],
  page: 1,
  filters: { category: 'tech' }
};

const url = `/api/search?${buildQueryString(params)}`;
await fetch(url);
```

#### URL Path Parameter Substitution

```javascript
function buildUrlWithParams(template, params) {
  let url = template;
  
  // Replace path parameters: /users/:id/posts/:postId
  Object.entries(params).forEach(([key, value]) => {
    url = url.replace(`:${key}`, encodeURIComponent(value));
    url = url.replace(`{${key}}`, encodeURIComponent(value));
  });
  
  // Check for unreplaced parameters
  const unreplaced = url.match(/:[a-zA-Z_]+|{[a-zA-Z_]+}/g);
  if (unreplaced) {
    throw new Error(`Missing parameters: ${unreplaced.join(', ')}`);
  }
  
  return url;
}

// Usage
const url = buildUrlWithParams('/users/:userId/posts/:postId', {
  userId: 123,
  postId: 456
});
// Result: /users/123/posts/456

await fetch(url);
```

#### URL Normalization

```javascript
function normalizeUrl(url, baseUrl = '') {
  // Remove duplicate slashes
  let normalized = url.replace(/([^:]\/)\/+/g, '$1');
  
  // Ensure leading slash for relative URLs
  if (!normalized.startsWith('http') && !normalized.startsWith('/')) {
    normalized = '/' + normalized;
  }
  
  // Remove trailing slash
  if (normalized.length > 1 && normalized.endsWith('/')) {
    normalized = normalized.slice(0, -1);
  }
  
  // Combine with base URL
  if (baseUrl) {
    const base = baseUrl.replace(/\/$/, '');
    const path = normalized.startsWith('/') ? normalized : '/' + normalized;
    return base + path;
  }
  
  return normalized;
}

// Usage
const url = normalizeUrl('//api//users//123/', 'https://example.com/');
// Result: https://example.com/api/users/123
```

### Request Method Transformation

#### HTTP Method Override

```javascript
async function fetchWithMethodOverride(url, method, options = {}) {
  // Some servers only accept GET/POST but support X-HTTP-Method-Override
  const actualMethod = ['GET', 'POST'].includes(method) ? method : 'POST';
  
  const headers = new Headers(options.headers);
  
  if (actualMethod !== method) {
    headers.set('X-HTTP-Method-Override', method);
    headers.set('X-HTTP-Method', method);
  }
  
  return fetch(url, {
    ...options,
    method: actualMethod,
    headers
  });
}

// Usage: Send DELETE as POST with override header
await fetchWithMethodOverride('/api/users/123', 'DELETE');
```

#### JSONP to Fetch Migration

```javascript
async function jsonpToFetch(url, callbackParam = 'callback') {
  // Convert JSONP-style URL to regular fetch
  const urlObj = new URL(url);
  urlObj.searchParams.delete(callbackParam);
  
  const response = await fetch(urlObj.toString(), {
    headers: {
      'Accept': 'application/json'
    }
  });
  
  return response.json();
}
```

### Request Body Transformation Pipeline

```javascript
class BodyTransformer {
  constructor() {
    this.transformers = [];
  }
  
  use(transformer) {
    this.transformers.push(transformer);
    return this;
  }
  
  async transform(data) {
    let result = data;
    
    for (const transformer of this.transformers) {
      result = await transformer(result);
    }
    
    return result;
  }
}

// Example transformers
const sanitizeTransformer = (data) => {
  if (typeof data === 'object') {
    const sanitized = {};
    Object.entries(data).forEach(([key, value]) => {
      // Remove null/undefined
      if (value !== null && value !== undefined) {
        sanitized[key] = typeof value === 'string' ? value.trim() : value;
      }
    });
    return sanitized;
  }
  return data;
};

const timestampTransformer = (data) => {
  return {
    ...data,
    timestamp: Date.now(),
    requestId: crypto.randomUUID()
  };
};

const encryptTransformer = async (data) => {
  // Simplified example - use proper encryption
  const json = JSON.stringify(data);
  const encoder = new TextEncoder();
  const dataBuffer = encoder.encode(json);
  
  return {
    encrypted: true,
    data: btoa(String.fromCharCode(...new Uint8Array(dataBuffer)))
  };
};

// Usage
const transformer = new BodyTransformer()
  .use(sanitizeTransformer)
  .use(timestampTransformer)
  .use(encryptTransformer);

const originalData = {
  username: '  john  ',
  email: null,
  age: 30
};

const transformedBody = await transformer.transform(originalData);

await fetch('/api/users', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(transformedBody)
});
```

### Content Negotiation

```javascript
async function fetchWithContentNegotiation(url, data, options = {}) {
  const acceptedTypes = options.accept || [
    'application/json',
    'application/xml',
    'text/html'
  ];
  
  const headers = new Headers(options.headers);
  headers.set('Accept', acceptedTypes.join(', '));
  
  // Transform body based on Content-Type
  let body = data;
  const contentType = headers.get('Content-Type') || 'application/json';
  
  if (contentType.includes('application/json')) {
    body = JSON.stringify(data);
  } else if (contentType.includes('application/x-www-form-urlencoded')) {
    body = new URLSearchParams(data).toString();
  } else if (contentType.includes('multipart/form-data')) {
    body = jsonToFormData(data);
    headers.delete('Content-Type'); // Let browser set with boundary
  } else if (contentType.includes('text/plain')) {
    body = String(data);
  }
  
  const response = await fetch(url, {
    ...options,
    headers,
    body
  });
  
  // Parse response based on Content-Type
  const responseType = response.headers.get('Content-Type') || '';
  
  if (responseType.includes('application/json')) {
    return response.json();
  } else if (responseType.includes('application/xml') || 
             responseType.includes('text/xml')) {
    const text = await response.text();
    return new DOMParser().parseFromString(text, 'text/xml');
  } else if (responseType.includes('text/')) {
    return response.text();
  } else {
    return response.blob();
  }
}
```

### Request Compression

```javascript
async function compressRequest(data) {
  const json = JSON.stringify(data);
  const encoder = new TextEncoder();
  const dataBuffer = encoder.encode(json);
  
  // Use CompressionStream API (modern browsers)
  const stream = new ReadableStream({
    start(controller) {
      controller.enqueue(dataBuffer);
      controller.close();
    }
  });
  
  const compressedStream = stream.pipeThrough(
    new CompressionStream('gzip')
  );
  
  const compressedData = await new Response(compressedStream).arrayBuffer();
  
  return new Blob([compressedData], { type: 'application/gzip' });
}

// Usage
const largeData = { /* large object */ };
const compressed = await compressRequest(largeData);

await fetch('/api/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Encoding': 'gzip'
  },
  body: compressed
});
```

### Multipart Request Building

```javascript
function buildMultipartRequest(parts, boundary) {
  boundary = boundary || `----WebKitFormBoundary${Math.random().toString(36).slice(2)}`;
  
  const lines = [];
  
  parts.forEach(part => {
    lines.push(`--${boundary}`);
    
    // Content-Disposition header
    let disposition = `Content-Disposition: form-data; name="${part.name}"`;
    if (part.filename) {
      disposition += `; filename="${part.filename}"`;
    }
    lines.push(disposition);
    
    // Content-Type header
    if (part.contentType) {
      lines.push(`Content-Type: ${part.contentType}`);
    }
    
    // Additional headers
    if (part.headers) {
      Object.entries(part.headers).forEach(([key, value]) => {
        lines.push(`${key}: ${value}`);
      });
    }
    
    lines.push(''); // Empty line before content
    lines.push(part.content);
  });
  
  lines.push(`--${boundary}--`);
  lines.push('');
  
  return {
    body: lines.join('\r\n'),
    contentType: `multipart/form-data; boundary=${boundary}`
  };
}

// Usage
const multipart = buildMultipartRequest([
  {
    name: 'metadata',
    content: JSON.stringify({ title: 'Document' }),
    contentType: 'application/json'
  },
  {
    name: 'file',
    filename: 'document.pdf',
    content: fileData,
    contentType: 'application/pdf'
  }
]);

await fetch('/api/upload', {
  method: 'POST',
  headers: {
    'Content-Type': multipart.contentType
  },
  body: multipart.body
});
```

### Schema-Based Transformation

```javascript
function transformBySchema(data, schema) {
  const result = {};
  
  Object.entries(schema).forEach(([key, config]) => {
    const value = data[config.from || key];
    
    if (value === undefined && !config.required) {
      if (config.default !== undefined) {
        result[key] = config.default;
      }
      return;
    }
    
    if (value === undefined && config.required) {
      throw new Error(`Missing required field: ${key}`);
    }
    
    let transformed = value;
    
    // Type transformation
    switch (config.type) {
      case 'string':
        transformed = String(value);
        break;
      case 'number':
        transformed = Number(value);
        break;
      case 'boolean':
        transformed = Boolean(value);
        break;
      case 'date':
        transformed = new Date(value).toISOString();
        break;
      case 'array':
        transformed = Array.isArray(value) ? value : [value];
        break;
    }
    
    // Custom transformer
    if (config.transform) {
      transformed = config.transform(transformed);
    }
    
    // Validation
    if (config.validate && !config.validate(transformed)) {
      throw new Error(`Validation failed for field: ${key}`);
    }
    
    result[key] = transformed;
  });
  
  return result;
}

// Usage
const schema = {
  userId: {
    from: 'user_id',
    type: 'number',
    required: true
  },
  fullName: {
    from: 'name',
    type: 'string',
    transform: (v) => v.trim().toUpperCase()
  },
  email: {
    type: 'string',
    validate: (v) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)
  },
  createdAt: {
    type: 'date',
    default: new Date().toISOString()
  },
  tags: {
    type: 'array',
    default: []
  }
};

const inputData = {
  user_id: '123',
  name: '  john doe  ',
  email: 'john@example.com'
};

const transformed = transformBySchema(inputData, schema);

await fetch('/api/users', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(transformed)
});
```

### Request Cloning and Modification

```javascript
function cloneAndModifyRequest(request, modifications) {
  const headers = new Headers(request.headers);
  
  // Modify headers
  if (modifications.headers) {
    Object.entries(modifications.headers).forEach(([key, value]) => {
      if (value === null) {
        headers.delete(key);
      } else {
        headers.set(key, value);
      }
    });
  }
  
  // Clone with modifications
  const init = {
    method: modifications.method || request.method,
    headers: headers,
    mode: modifications.mode || request.mode,
    credentials: modifications.credentials || request.credentials,
    cache: modifications.cache || request.cache,
    redirect: modifications.redirect || request.redirect,
    referrer: modifications.referrer || request.referrer,
    integrity: modifications.integrity || request.integrity
  };
  
  // Handle body (can only be read once)
  if (request.method !== 'GET' && request.method !== 'HEAD') {
    init.body = modifications.body || request.body;
  }
  
  const url = modifications.url || request.url;
  
  return new Request(url, init);
}

// Usage
const originalRequest = new Request('/api/data', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ data: 'original' })
});

const modifiedRequest = cloneAndModifyRequest(originalRequest, {
  headers: {
    'Authorization': 'Bearer token123',
    'X-Custom-Header': 'value'
  },
  url: '/api/v2/data'
});

await fetch(modifiedRequest);
```

### Interceptor Pattern

```javascript
class FetchInterceptor {
  constructor() {
    this.requestInterceptors = [];
    this.responseInterceptors = [];
  }
  
  addRequestInterceptor(interceptor) {
    this.requestInterceptors.push(interceptor);
    return this;
  }
  
  addResponseInterceptor(interceptor) {
    this.responseInterceptors.push(interceptor);
    return this;
  }
  
  async fetch(url, options = {}) {
    // Transform request through interceptors
    let transformedUrl = url;
    let transformedOptions = { ...options };
    
    for (const interceptor of this.requestInterceptors) {
      const result = await interceptor(transformedUrl, transformedOptions);
      transformedUrl = result.url || transformedUrl;
      transformedOptions = result.options || transformedOptions;
    }
    
    // Make request
    let response = await fetch(transformedUrl, transformedOptions);
    
    // Transform response through interceptors
    for (const interceptor of this.responseInterceptors) {
      response = await interceptor(response) || response;
    }
    
    return response;
  }
}

// Usage
const interceptor = new FetchInterceptor();

// Add authentication
interceptor.addRequestInterceptor(async (url, options) => {
  const token = await getAuthToken();
  return {
    url,
    options: {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    }
  };
});

// Add timestamp
interceptor.addRequestInterceptor(async (url, options) => {
  const urlObj = new URL(url, window.location.origin);
  urlObj.searchParams.set('_t', Date.now());
  
  return {
    url: urlObj.toString(),
    options
  };
});

// Log response
interceptor.addResponseInterceptor(async (response) => {
  console.log(`Response from ${response.url}: ${response.status}`);
  return response;
});

// Use interceptor
const response = await interceptor.fetch('/api/data', {
  method: 'POST',
  body: JSON.stringify({ data: 'test' })
});
```

### Custom Serialization

```javascript
class CustomSerializer {
  static serialize(data, format = 'json') {
    switch (format) {
      case 'json':
        return this.toJSON(data);
      case 'xml':
        return this.toXML(data);
      case 'yaml':
        return this.toYAML(data);
      case 'msgpack':
        return this.toMsgPack(data);
      default:
        throw new Error(`Unsupported format: ${format}`);
    }
  }
  
  static toJSON(data) {
    return JSON.stringify(data, (key, value) => {
      // Custom Date serialization
      if (value instanceof Date) {
        return { __type: 'Date', value: value.toISOString() };
      }
      // Custom RegExp serialization
      if (value instanceof RegExp) {
        return { __type: 'RegExp', value: value.toString() };
      }
      // Custom Map serialization
      if (value instanceof Map) {
        return {
          __type: 'Map',
          value: Array.from(value.entries())
        };
      }
      // Custom Set serialization
      if (value instanceof Set) {
        return {
          __type: 'Set',
          value: Array.from(value)
        };
      }
      return value;
    });
  }
  
  static toXML(data, rootName = 'root') {
    function buildXML(obj, name) {
      if (obj === null || obj === undefined) {
        return `<${name}/>`;
      }
      
      if (typeof obj !== 'object') {
        return `<${name}>${escapeXML(String(obj))}</${name}>`;
      }
      
      if (Array.isArray(obj)) {
        return obj.map(item => buildXML(item, 'item')).join('');
      }
      
      const children = Object.entries(obj)
        .map(([key, value]) => buildXML(value, key))
        .join('');
      
      return `<${name}>${children}</${name}>`;
    }
    
    function escapeXML(str) {
      return str
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;');
    }
    
    return `<?xml version="1.0" encoding="UTF-8"?>${buildXML(data, rootName)}`;
  }
  
  static toYAML(data, indent = 0) {
    const spaces = '  '.repeat(indent);
    
    if (data === null) return 'null';
    if (typeof data === 'boolean') return String(data);
    if (typeof data === 'number') return String(data);
    if (typeof data === 'string') {
      return data.includes('\n') ? `|\n${data.split('\n').map(l => spaces + '  ' + l).join('\n')}` : `"${data}"`;
    }
    
    if (Array.isArray(data)) {
      return '\n' + data.map(item => 
        `${spaces}- ${this.toYAML(item, indent + 1).trim()}` ).join('\n'); }

if (typeof data === 'object') {
  return '\n' + Object.entries(data).map(([key, value]) => {
    const val = this.toYAML(value, indent + 1);
    return `${spaces}${key}:${val.startsWith('\n') ? val : ' ' + val}`;
  }).join('\n');
}

return String(data);

}

static toMsgPack(data) { // Simplified MessagePack encoding function encode(obj) { if (obj === null) return new Uint8Array([0xc0]); if (obj === false) return new Uint8Array([0xc2]); if (obj === true) return new Uint8Array([0xc3]);

  if (typeof obj === 'number') {
    if (Number.isInteger(obj) && obj >= 0 && obj <= 127) {
      return new Uint8Array([obj]);
    }
    // Simplified: just use float64 for all other numbers
    const buffer = new ArrayBuffer(9);
    const view = new DataView(buffer);
    view.setUint8(0, 0xcb);
    view.setFloat64(1, obj);
    return new Uint8Array(buffer);
  }
  
  if (typeof obj === 'string') {
    const encoder = new TextEncoder();
    const strBytes = encoder.encode(obj);
    const len = strBytes.length;
    
    if (len <= 31) {
      const result = new Uint8Array(1 + len);
      result[0] = 0xa0 | len;
      result.set(strBytes, 1);
      return result;
    }
    
    // Simplified: handle longer strings as needed
    throw new Error('String too long for simplified encoding');
  }
  
  throw new Error('Unsupported type for MessagePack');
}

return encode(data);

} }

// Usage const data = { name: 'John', date: new Date(), items: [1, 2, 3] };

const jsonBody = CustomSerializer.serialize(data, 'json'); const xmlBody = CustomSerializer.serialize(data, 'xml'); const yamlBody = CustomSerializer.serialize(data, 'yaml');

await fetch('/api/data', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: jsonBody });
```

---

