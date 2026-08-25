## Response Transformation with Fetch API


### Understanding Response Immutability

Response objects in the Fetch API are immutable once created. The body stream can only be read once, making response transformation require careful handling through cloning and reconstruction.

```javascript
const response = await fetch('/api/data');

// Body can only be consumed once
const data1 = await response.json(); // Works
const data2 = await response.json(); // TypeError: Body already read

// Must clone to read multiple times
const response2 = await fetch('/api/data');
const clone = response2.clone();
const data3 = await clone.json();
const data4 = await response2.json(); // Both work
```

### Creating New Response Objects

#### Basic Response Construction

```javascript
// Create from scratch
const customResponse = new Response('Hello World', {
  status: 200,
  statusText: 'OK',
  headers: {
    'Content-Type': 'text/plain',
    'X-Custom-Header': 'value'
  }
});

// Create from JSON data
const jsonResponse = new Response(
  JSON.stringify({ message: 'Success', data: [1, 2, 3] }),
  {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  }
);

// Create from Blob
const blob = new Blob(['Binary data'], { type: 'application/octet-stream' });
const blobResponse = new Response(blob);
```

#### Response Construction from Existing Response

```javascript
const originalResponse = await fetch('/api/data');
const originalBody = await originalResponse.text();

const modifiedResponse = new Response(originalBody, {
  status: originalResponse.status,
  statusText: originalResponse.statusText,
  headers: originalResponse.headers
});
```

### Header Transformation

#### Adding and Modifying Headers

```javascript
async function addHeaders(response, newHeaders) {
  const modifiedHeaders = new Headers(response.headers);
  
  Object.entries(newHeaders).forEach(([key, value]) => {
    modifiedHeaders.set(key, value);
  });
  
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: modifiedHeaders
  });
}

// Usage
const response = await fetch('/api/data');
const transformed = await addHeaders(response, {
  'X-Processed-By': 'Service Worker',
  'X-Timestamp': Date.now().toString()
});
```

#### Removing Headers

```javascript
async function removeHeaders(response, headersToRemove) {
  const modifiedHeaders = new Headers(response.headers);
  
  headersToRemove.forEach(header => {
    modifiedHeaders.delete(header);
  });
  
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: modifiedHeaders
  });
}

// Remove sensitive headers before caching
const sanitized = await removeHeaders(response, [
  'Set-Cookie',
  'Authorization',
  'X-Internal-Token'
]);
```

#### Header Value Transformation

```javascript
async function transformHeaderValues(response, transformations) {
  const headers = new Headers(response.headers);
  
  Object.entries(transformations).forEach(([header, transformFn]) => {
    const currentValue = headers.get(header);
    if (currentValue) {
      headers.set(header, transformFn(currentValue));
    }
  });
  
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers
  });
}

// Usage: Modify Cache-Control
const transformed = await transformHeaderValues(response, {
  'Cache-Control': (value) => value.replace('max-age=3600', 'max-age=7200'),
  'Content-Type': (value) => value + '; charset=utf-8'
});
```

### Body Transformation

#### Text Content Transformation

```javascript
async function transformTextResponse(response, transformFn) {
  const text = await response.text();
  const transformedText = transformFn(text);
  
  return new Response(transformedText, {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}

// Replace placeholders in HTML
const response = await fetch('/template.html');
const personalized = await transformTextResponse(response, text => {
  return text
    .replace('{{USERNAME}}', currentUser.name)
    .replace('{{TIMESTAMP}}', new Date().toISOString());
});
```

#### JSON Transformation

```javascript
async function transformJSONResponse(response, transformFn) {
  const data = await response.json();
  const transformedData = transformFn(data);
  
  const newBody = JSON.stringify(transformedData);
  const headers = new Headers(response.headers);
  headers.set('Content-Length', new Blob([newBody]).size.toString());
  
  return new Response(newBody, {
    status: response.status,
    statusText: response.statusText,
    headers
  });
}

// Add computed fields to API response
const response = await fetch('/api/users');
const enhanced = await transformJSONResponse(response, data => {
  return data.map(user => ({
    ...user,
    fullName: `${user.firstName} ${user.lastName}`,
    avatarUrl: `/avatars/${user.id}.jpg`,
    isActive: user.lastLogin > Date.now() - 86400000
  }));
});
```

#### Binary Data Transformation

```javascript
async function transformBinaryResponse(response, transformFn) {
  const arrayBuffer = await response.arrayBuffer();
  const transformedBuffer = await transformFn(arrayBuffer);
  
  return new Response(transformedBuffer, {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}

// Example: Decompress gzipped response
async function decompressResponse(response) {
  const blob = await response.blob();
  const decompressedStream = blob.stream().pipeThrough(
    new DecompressionStream('gzip')
  );
  
  const headers = new Headers(response.headers);
  headers.delete('Content-Encoding');
  
  return new Response(decompressedStream, {
    status: response.status,
    statusText: response.statusText,
    headers
  });
}
```

### Stream Transformation

#### TransformStream for Body Processing

```javascript
async function transformResponseStream(response, transformer) {
  const transformStream = new TransformStream({
    transform(chunk, controller) {
      const transformed = transformer(chunk);
      controller.enqueue(transformed);
    }
  });
  
  const transformedBody = response.body.pipeThrough(transformStream);
  
  return new Response(transformedBody, {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}

// Usage: Convert text to uppercase as it streams
const response = await fetch('/api/stream');
const uppercased = await transformResponseStream(response, chunk => {
  const text = new TextDecoder().decode(chunk);
  const transformed = text.toUpperCase();
  return new TextEncoder().encode(transformed);
});
```

#### Line-by-Line Stream Processing

```javascript
class LineTransformStream extends TransformStream {
  constructor(transformFn) {
    let buffer = '';
    
    super({
      transform(chunk, controller) {
        buffer += new TextDecoder().decode(chunk);
        const lines = buffer.split('\n');
        
        // Keep last incomplete line in buffer
        buffer = lines.pop();
        
        lines.forEach(line => {
          const transformed = transformFn(line);
          controller.enqueue(new TextEncoder().encode(transformed + '\n'));
        });
      },
      
      flush(controller) {
        if (buffer) {
          const transformed = transformFn(buffer);
          controller.enqueue(new TextEncoder().encode(transformed));
        }
      }
    });
  }
}

// Usage: Prefix each line with line number
const response = await fetch('/log.txt');
let lineNum = 0;
const numbered = response.body.pipeThrough(
  new LineTransformStream(line => `${++lineNum}: ${line}`)
);

const transformedResponse = new Response(numbered, {
  headers: response.headers
});
```

#### Chunked Processing for Large Responses

```javascript
async function processLargeResponse(response, chunkProcessor) {
  const reader = response.body.getReader();
  const stream = new ReadableStream({
    async start(controller) {
      while (true) {
        const { done, value } = await reader.read();
        
        if (done) {
          controller.close();
          break;
        }
        
        const processed = await chunkProcessor(value);
        controller.enqueue(processed);
      }
    }
  });
  
  return new Response(stream, {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}

// Usage: Filter out specific patterns from stream
const response = await fetch('/large-data.txt');
const filtered = await processLargeResponse(response, chunk => {
  const text = new TextDecoder().decode(chunk);
  const filtered = text.replace(/SENSITIVE_DATA/g, '[REDACTED]');
  return new TextEncoder().encode(filtered);
});
```

### Status Code Transformation

#### Normalizing Error Responses

```javascript
async function normalizeErrorResponse(response) {
  if (!response.ok) {
    const errorBody = await response.text();
    const normalizedBody = JSON.stringify({
      error: true,
      status: response.status,
      message: response.statusText,
      details: errorBody
    });
    
    return new Response(normalizedBody, {
      status: 200, // Normalize to 200 for easier client handling
      statusText: 'OK',
      headers: {
        'Content-Type': 'application/json',
        'X-Original-Status': response.status.toString()
      }
    });
  }
  
  return response;
}
```

#### Converting Status Codes

```javascript
async function convertStatusCode(response, statusMap) {
  const newStatus = statusMap[response.status] || response.status;
  
  return new Response(response.body, {
    status: newStatus,
    statusText: response.statusText,
    headers: response.headers
  });
}

// Usage: Convert 404 to 200 with empty array
const response = await fetch('/api/search?q=rare');
const converted = await convertStatusCode(response, {
  404: 200
});

if (response.status === 404) {
  const emptyResult = new Response(JSON.stringify([]), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  });
}
```

### Content-Type Transformation

#### Format Conversion

```javascript
async function convertResponseFormat(response, targetFormat) {
  const sourceType = response.headers.get('Content-Type') || '';
  
  if (sourceType.includes('application/json') && targetFormat === 'xml') {
    const data = await response.json();
    const xml = jsonToXml(data); // Implementation needed
    
    return new Response(xml, {
      status: response.status,
      headers: {
        'Content-Type': 'application/xml'
      }
    });
  }
  
  if (sourceType.includes('application/xml') && targetFormat === 'json') {
    const xml = await response.text();
    const data = xmlToJson(xml); // Implementation needed
    
    return new Response(JSON.stringify(data), {
      status: response.status,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
  
  return response;
}
```

#### CSV to JSON Transformation

```javascript
async function csvToJsonResponse(response) {
  const csv = await response.text();
  const lines = csv.trim().split('\n');
  const headers = lines[0].split(',');
  
  const data = lines.slice(1).map(line => {
    const values = line.split(',');
    return headers.reduce((obj, header, index) => {
      obj[header.trim()] = values[index]?.trim() || '';
      return obj;
    }, {});
  });
  
  return new Response(JSON.stringify(data), {
    status: response.status,
    headers: {
      'Content-Type': 'application/json'
    }
  });
}
```

### Response Wrapping and Metadata Addition

#### Adding Metadata to Response Body

```javascript
async function wrapWithMetadata(response, metadata) {
  const originalData = await response.json();
  
  const wrappedData = {
    metadata: {
      timestamp: Date.now(),
      source: response.url,
      status: response.status,
      ...metadata
    },
    data: originalData
  };
  
  return new Response(JSON.stringify(wrappedData), {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}

// Usage
const response = await fetch('/api/users');
const wrapped = await wrapWithMetadata(response, {
  cachedAt: Date.now(),
  version: 'v2',
  count: Array.isArray(await response.clone().json()) 
    ? (await response.clone().json()).length 
    : null
});
```

#### Response Envelope Pattern

```javascript
async function envelopeResponse(response) {
  const body = await response.text();
  let parsedBody;
  
  try {
    parsedBody = JSON.parse(body);
  } catch {
    parsedBody = body;
  }
  
  const envelope = {
    success: response.ok,
    status: response.status,
    statusText: response.statusText,
    headers: Object.fromEntries(response.headers.entries()),
    body: parsedBody,
    timestamp: new Date().toISOString()
  };
  
  return new Response(JSON.stringify(envelope), {
    status: 200,
    headers: {
      'Content-Type': 'application/json'
    }
  });
}
```

### Filtering and Sanitization

#### Removing Sensitive Fields

```javascript
async function sanitizeResponse(response, fieldsToRemove) {
  const data = await response.json();
  
  const sanitize = (obj) => {
    if (Array.isArray(obj)) {
      return obj.map(sanitize);
    }
    
    if (obj && typeof obj === 'object') {
      const sanitized = { ...obj };
      fieldsToRemove.forEach(field => {
        delete sanitized[field];
      });
      
      Object.keys(sanitized).forEach(key => {
        sanitized[key] = sanitize(sanitized[key]);
      });
      
      return sanitized;
    }
    
    return obj;
  };
  
  const sanitizedData = sanitize(data);
  
  return new Response(JSON.stringify(sanitizedData), {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}

// Usage: Remove sensitive user fields
const response = await fetch('/api/users');
const public = await sanitizeResponse(response, [
  'password',
  'socialSecurityNumber',
  'creditCard',
  'apiKey'
]);
```

#### Content Filtering

```javascript
async function filterResponseContent(response, predicate) {
  const data = await response.json();
  
  let filtered;
  if (Array.isArray(data)) {
    filtered = data.filter(predicate);
  } else if (data && typeof data === 'object') {
    filtered = Object.entries(data)
      .filter(([_, value]) => predicate(value))
      .reduce((obj, [key, value]) => {
        obj[key] = value;
        return obj;
      }, {});
  } else {
    filtered = data;
  }
  
  return new Response(JSON.stringify(filtered), {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}

// Usage: Filter users by active status
const response = await fetch('/api/users');
const activeOnly = await filterResponseContent(
  response,
  user => user.isActive === true
);
```

### Response Merging and Aggregation

#### Combining Multiple Responses

```javascript
async function mergeResponses(responses, mergeStrategy = 'array') {
  const dataPromises = responses.map(r => r.json());
  const allData = await Promise.all(dataPromises);
  
  let merged;
  if (mergeStrategy === 'array') {
    merged = allData.flat();
  } else if (mergeStrategy === 'object') {
    merged = Object.assign({}, ...allData);
  } else if (typeof mergeStrategy === 'function') {
    merged = mergeStrategy(allData);
  }
  
  return new Response(JSON.stringify(merged), {
    status: 200,
    headers: {
      'Content-Type': 'application/json'
    }
  });
}

// Usage: Fetch from multiple endpoints
const [users, posts, comments] = await Promise.all([
  fetch('/api/users'),
  fetch('/api/posts'),
  fetch('/api/comments')
]);

const combined = await mergeResponses([users, posts, comments], data => ({
  users: data[0],
  posts: data[1],
  comments: data[2]
}));
```

#### Paginated Response Aggregation

```javascript
async function aggregatePaginatedResponses(baseUrl, pageParam = 'page') {
  const allData = [];
  let page = 1;
  let hasMore = true;
  
  while (hasMore) {
    const url = `${baseUrl}${baseUrl.includes('?') ? '&' : '?'}${pageParam}=${page}`;
    const response = await fetch(url);
    const data = await response.json();
    
    if (Array.isArray(data) && data.length > 0) {
      allData.push(...data);
      page++;
    } else {
      hasMore = false;
    }
  }
  
  return new Response(JSON.stringify(allData), {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      'X-Total-Pages': (page - 1).toString()
    }
  });
}
```

### Conditional Transformation

#### Transform Based on Response Characteristics

```javascript
async function conditionalTransform(response, conditions) {
  for (const { predicate, transform } of conditions) {
    if (await predicate(response.clone())) {
      return transform(response);
    }
  }
  
  return response;
}

// Usage
const transformed = await conditionalTransform(response, [
  {
    predicate: async (r) => r.headers.get('Content-Type')?.includes('text/html'),
    transform: async (r) => {
      const html = await r.text();
      const minified = html.replace(/\s+/g, ' ');
      return new Response(minified, { headers: r.headers });
    }
  },
  {
    predicate: async (r) => r.status === 404,
    transform: async (r) => {
      return new Response(JSON.stringify({ error: 'Not found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      });
    }
  }
]);
```

#### Transform Based on Request Context

```javascript
async function contextualTransform(request, response, context) {
  const userRole = context.userRole || 'guest';
  
  if (userRole === 'admin') {
    // Admins get full data
    return response;
  }
  
  if (userRole === 'user') {
    // Regular users get filtered data
    return sanitizeResponse(response, ['internalId', 'adminNotes']);
  }
  
  // Guests get minimal data
  const data = await response.json();
  const publicData = Array.isArray(data) 
    ? data.map(item => ({ id: item.id, title: item.title }))
    : { id: data.id, title: data.title };
  
  return new Response(JSON.stringify(publicData), {
    status: response.status,
    headers: response.headers
  });
}
```

### Response Validation and Schema Enforcement

#### Schema Validation

```javascript
async function validateAndTransform(response, schema) {
  const data = await response.json();
  
  const validate = (obj, schema) => {
    const validated = {};
    
    for (const [key, type] of Object.entries(schema)) {
      if (obj.hasOwnProperty(key)) {
        if (typeof obj[key] === type) {
          validated[key] = obj[key];
        } else {
          // Coerce type if possible
          if (type === 'number') {
            validated[key] = Number(obj[key]);
          } else if (type === 'string') {
            validated[key] = String(obj[key]);
          } else if (type === 'boolean') {
            validated[key] = Boolean(obj[key]);
          }
        }
      }
    }
    
    return validated;
  };
  
  const validatedData = Array.isArray(data)
    ? data.map(item => validate(item, schema))
    : validate(data, schema);
  
  return new Response(JSON.stringify(validatedData), {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}

// Usage
const schema = {
  id: 'number',
  name: 'string',
  isActive: 'boolean',
  createdAt: 'string'
};

const validated = await validateAndTransform(response, schema);
```

#### Default Values Injection

```javascript
async function injectDefaults(response, defaults) {
  const data = await response.json();
  
  const applyDefaults = (obj) => {
    if (Array.isArray(obj)) {
      return obj.map(applyDefaults);
    }
    
    if (obj && typeof obj === 'object') {
      return { ...defaults, ...obj };
    }
    
    return obj;
  };
  
  const enriched = applyDefaults(data);
  
  return new Response(JSON.stringify(enriched), {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}

// Usage: Add default values to all objects
const response = await fetch('/api/items');
const withDefaults = await injectDefaults(response, {
  isActive: true,
  createdAt: new Date().toISOString(),
  version: '1.0'
});
```

### Response Compression and Encoding

#### Manual Compression

```javascript
async function compressResponse(response) {
  const blob = await response.blob();
  const compressionStream = new CompressionStream('gzip');
  const compressedStream = blob.stream().pipeThrough(compressionStream);
  
  const headers = new Headers(response.headers);
  headers.set('Content-Encoding', 'gzip');
  
  return new Response(compressedStream, {
    status: response.status,
    statusText: response.statusText,
    headers
  });
}
```

#### Base64 Encoding Response

```javascript
async function base64EncodeResponse(response) {
  const buffer = await response.arrayBuffer();
  const bytes = new Uint8Array(buffer);
  const binary = bytes.reduce((acc, byte) => acc + String.fromCharCode(byte), '');
  const base64 = btoa(binary);
  
  return new Response(base64, {
    status: response.status,
    headers: {
      'Content-Type': 'text/plain',
      'Content-Transfer-Encoding': 'base64'
    }
  });
}
```

### Caching-Aware Transformations

#### Transform with Cache Consideration

```javascript
async function transformAndCache(request, response, transformFn) {
  const transformed = await transformFn(response.clone());
  
  // Cache the transformed version
  const cache = await caches.open('transformed-v1');
  await cache.put(request, transformed.clone());
  
  return transformed;
}

// Usage in service worker
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;
      
      return fetch(event.request).then(response => {
        return transformAndCache(
          event.request,
          response,
          async (r) => {
            // Apply transformation
            const data = await r.json();
            const enhanced = data.map(item => ({
              ...item,
              cached: true,
              timestamp: Date.now()
            }));
            
            return new Response(JSON.stringify(enhanced), {
              headers: r.headers
            });
          }
        );
      });
    })
  );
});
```

### Error Response Transformation

#### Standardizing Error Format

```javascript
async function standardizeErrorResponse(response) {
  if (!response.ok) {
    let errorDetails;
    
    try {
      errorDetails = await response.json();
    } catch {
      errorDetails = await response.text();
    }
    
    const standardError = {
      error: {
        code: response.status,
        message: response.statusText,
        details: errorDetails,
        timestamp: new Date().toISOString(),
        requestId: response.headers.get('X-Request-Id') || null
      }
    };
    
    return new Response(JSON.stringify(standardError), {
      status: response.status,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
  
  return response;
}
```

#### Retry with Transformed Request

```javascript
async function transformAndRetry(request, response, maxRetries = 3) {
  let attempt = 0;
  let currentResponse = response;
  
  while (!currentResponse.ok && attempt < maxRetries) {
    // Transform request for retry
    const retryRequest = new Request(request.url, {
      method: request.method,
      headers: new Headers({
        ...Object.fromEntries(request.headers.entries()),
        'X-Retry-Attempt': (attempt + 1).toString()
      }),
      body: request.body
    });
    
    currentResponse = await fetch(retryRequest);
    attempt++;
  }
  
  return currentResponse;
}
```

### Performance Optimization Through Transformation

#### Lazy Loading Transformation

```javascript
async function createLazyLoadResponse(response, chunkSize = 100) {
  const allData = await response.json();
  
  // Store full data in closure
  let offset = 0;
  
  // Return initial chunk
  const initialChunk = allData.slice(0, chunkSize);
  const hasMore = allData.length > chunkSize;
  
  const responseBody = {
    data: initialChunk,
    pagination: {
      offset: 0,
      limit: chunkSize,
      total: allData.length,
      hasMore
    }
  };
  
  return new Response(JSON.stringify(responseBody), {
    status: response.status,
    headers: {
      'Content-Type': 'application/json',
      'X-Has-More': hasMore.toString()
    }
  });
}
```

#### Response Deduplication

```javascript
async function deduplicateResponse(response, keyFn = item => item.id) {
  const data = await response.json();
  
  if (!Array.isArray(data)) {
    return response;
  }
  
  const seen = new Set();
  const deduplicated = data.filter(item => {
    const key = keyFn(item);
    if (seen.has(key)) {
      return false;
    }
    seen.add(key);
    return true;
  });
  
  return new Response(JSON.stringify(deduplicated), {
    status: response.status,
    headers: {
      ...Object.fromEntries(response.headers.entries()),
      'X-Original-Count': data.length.toString(),
      'X-Deduplicated-Count': deduplicated.length.toString()
    }
  });
}
```

---

