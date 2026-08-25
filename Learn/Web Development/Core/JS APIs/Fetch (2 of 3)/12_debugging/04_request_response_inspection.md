## Request/Response Inspection


### Inspecting Request Objects

#### Accessing Request Properties

Request objects expose several properties for inspection:

```javascript
const request = new Request('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer token123'
  },
  body: JSON.stringify({ key: 'value' })
});

console.log(request.url);           // "https://api.example.com/data"
console.log(request.method);        // "POST"
console.log(request.mode);          // "cors"
console.log(request.credentials);   // "same-origin"
console.log(request.cache);         // "default"
console.log(request.redirect);      // "follow"
console.log(request.referrer);      // about:client
console.log(request.referrerPolicy); // ""
console.log(request.integrity);     // ""
```

#### Reading Request Headers

Headers can be inspected using the Headers interface methods:

```javascript
// Check if header exists
request.headers.has('Content-Type'); // true

// Get header value
request.headers.get('Authorization'); // "Bearer token123"

// Iterate over headers
for (const [key, value] of request.headers) {
  console.log(`${key}: ${value}`);
}

// Get all values for a header (for multi-value headers)
request.headers.getSetCookie(); // Returns array of Set-Cookie values
```

#### Reading Request Body

The request body can only be read once due to the body being a stream. Multiple read attempts require cloning:

```javascript
const request = new Request('https://api.example.com', {
  method: 'POST',
  body: JSON.stringify({ data: 'test' })
});

// Clone before reading if you need to read multiple times
const clonedRequest = request.clone();

// Read as JSON
const jsonData = await request.json();

// Read as text
const textData = await clonedRequest.text();

// Other body reading methods:
// await request.blob()
// await request.arrayBuffer()
// await request.formData()
```

#### Body Stream Status

```javascript
console.log(request.bodyUsed); // false initially, true after reading

// Check if body is disturbed
if (!request.bodyUsed) {
  const data = await request.json();
}
```

### Inspecting Response Objects

#### Accessing Response Properties

```javascript
const response = await fetch('https://api.example.com/data');

console.log(response.status);       // 200
console.log(response.statusText);   // "OK"
console.log(response.ok);          // true (status 200-299)
console.log(response.type);        // "cors", "basic", "opaque", etc.
console.log(response.url);         // Final URL after redirects
console.log(response.redirected);  // true if redirected
console.log(response.headers);     // Headers object
```

#### Response Type Meanings

```javascript
// "basic" - same-origin response
// "cors" - valid CORS response
// "opaque" - no-cors response (very limited access)
// "opaqueredirect" - redirect mode set to "manual"
// "error" - network error occurred
```

#### Reading Response Headers

```javascript
// Access specific headers
const contentType = response.headers.get('Content-Type');
const contentLength = response.headers.get('Content-Length');
const lastModified = response.headers.get('Last-Modified');

// Check for header existence
if (response.headers.has('Cache-Control')) {
  console.log('Cache control is set');
}

// Iterate all headers
response.headers.forEach((value, key) => {
  console.log(`${key}: ${value}`);
});

// Convert to plain object (for logging/debugging)
const headersObj = Object.fromEntries(response.headers.entries());
```

#### Reading Response Body

Similar to requests, response bodies are streams that can only be read once:

```javascript
const response = await fetch('https://api.example.com/data');

// Clone if multiple reads needed
const clone = response.clone();

// JSON parsing
const jsonData = await response.json();

// Text parsing
const textData = await clone.text();

// Blob (for binary data)
const blobData = await response.blob();

// ArrayBuffer (for raw binary)
const bufferData = await response.arrayBuffer();

// FormData (for form submissions)
const formData = await response.formData();
```

### Advanced Inspection Techniques

#### Intercepting and Logging Requests

```javascript
const originalFetch = window.fetch;

window.fetch = async function(...args) {
  const [resource, config] = args;
  
  console.log('Request:', {
    url: resource,
    method: config?.method || 'GET',
    headers: config?.headers,
    body: config?.body
  });
  
  const response = await originalFetch(...args);
  
  console.log('Response:', {
    status: response.status,
    statusText: response.statusText,
    headers: Object.fromEntries(response.headers.entries())
  });
  
  return response;
};
```

#### Inspecting Body Without Consuming

Using `Response.clone()` or `Request.clone()` allows inspection while preserving the original:

```javascript
async function inspectResponse(response) {
  const clone = response.clone();
  const body = await clone.text();
  
  console.log('Response body preview:', body.substring(0, 200));
  
  return response; // Original still readable
}

const response = await fetch('https://api.example.com/data');
const inspected = await inspectResponse(response);
const data = await inspected.json(); // Still works
```

#### Creating Response Inspector

```javascript
class ResponseInspector {
  constructor(response) {
    this.response = response;
    this.clone = response.clone();
  }
  
  async getMetadata() {
    return {
      status: this.response.status,
      statusText: this.response.statusText,
      ok: this.response.ok,
      type: this.response.type,
      url: this.response.url,
      redirected: this.response.redirected,
      headers: Object.fromEntries(this.response.headers.entries())
    };
  }
  
  async getBodyPreview(length = 500) {
    const text = await this.clone.text();
    return text.substring(0, length);
  }
  
  getOriginal() {
    return this.response;
  }
}

// Usage
const response = await fetch('https://api.example.com/data');
const inspector = new ResponseInspector(response);

console.log(await inspector.getMetadata());
console.log(await inspector.getBodyPreview());

const data = await inspector.getOriginal().json();
```

### Debugging Headers

#### Examining CORS Headers

```javascript
const response = await fetch('https://api.example.com/data');

const corsHeaders = {
  'Access-Control-Allow-Origin': response.headers.get('Access-Control-Allow-Origin'),
  'Access-Control-Allow-Methods': response.headers.get('Access-Control-Allow-Methods'),
  'Access-Control-Allow-Headers': response.headers.get('Access-Control-Allow-Headers'),
  'Access-Control-Expose-Headers': response.headers.get('Access-Control-Expose-Headers'),
  'Access-Control-Allow-Credentials': response.headers.get('Access-Control-Allow-Credentials')
};

console.log('CORS Configuration:', corsHeaders);
```

#### Inspecting Cache Headers

```javascript
const cacheHeaders = {
  'Cache-Control': response.headers.get('Cache-Control'),
  'ETag': response.headers.get('ETag'),
  'Expires': response.headers.get('Expires'),
  'Last-Modified': response.headers.get('Last-Modified'),
  'Age': response.headers.get('Age')
};

console.log('Cache Information:', cacheHeaders);
```

#### Content Negotiation Headers

```javascript
const contentHeaders = {
  'Content-Type': response.headers.get('Content-Type'),
  'Content-Encoding': response.headers.get('Content-Encoding'),
  'Content-Length': response.headers.get('Content-Length'),
  'Content-Language': response.headers.get('Content-Language'),
  'Content-Location': response.headers.get('Content-Location')
};
```

### Stream Inspection

#### Reading Body as Stream

```javascript
const response = await fetch('https://api.example.com/large-file');
const reader = response.body.getReader();
const decoder = new TextDecoder();

let receivedLength = 0;
let chunks = [];

while (true) {
  const { done, value } = await reader.read();
  
  if (done) break;
  
  chunks.push(value);
  receivedLength += value.length;
  
  console.log(`Received ${receivedLength} bytes`);
}

// Concatenate chunks
const allChunks = new Uint8Array(receivedLength);
let position = 0;

for (const chunk of chunks) {
  allChunks.set(chunk, position);
  position += chunk.length;
}

const result = decoder.decode(allChunks);
```

#### Monitoring Download Progress

```javascript
async function fetchWithProgress(url, onProgress) {
  const response = await fetch(url);
  const contentLength = response.headers.get('Content-Length');
  const total = parseInt(contentLength, 10);
  
  let loaded = 0;
  const reader = response.body.getReader();
  const stream = new ReadableStream({
    async start(controller) {
      while (true) {
        const { done, value } = await reader.read();
        
        if (done) {
          controller.close();
          break;
        }
        
        loaded += value.length;
        onProgress({ loaded, total, percentage: (loaded / total) * 100 });
        controller.enqueue(value);
      }
    }
  });
  
  return new Response(stream, {
    headers: response.headers,
    status: response.status,
    statusText: response.statusText
  });
}

// Usage
const response = await fetchWithProgress(
  'https://example.com/large-file.zip',
  ({ loaded, total, percentage }) => {
    console.log(`Progress: ${percentage.toFixed(2)}% (${loaded}/${total})`);
  }
);

const blob = await response.blob();
```

### Error Response Inspection

#### Detailed Error Information

```javascript
async function fetchWithDetailedErrors(url, options) {
  try {
    const response = await fetch(url, options);
    
    if (!response.ok) {
      const errorDetails = {
        status: response.status,
        statusText: response.statusText,
        url: response.url,
        headers: Object.fromEntries(response.headers.entries()),
        body: null
      };
      
      // Try to read error body
      try {
        const contentType = response.headers.get('Content-Type');
        if (contentType?.includes('application/json')) {
          errorDetails.body = await response.json();
        } else {
          errorDetails.body = await response.text();
        }
      } catch (e) {
        errorDetails.body = 'Unable to read error body';
      }
      
      throw new Error(`HTTP Error: ${JSON.stringify(errorDetails, null, 2)}`);
    }
    
    return response;
  } catch (error) {
    if (error instanceof TypeError) {
      console.error('Network error or CORS issue:', error);
    }
    throw error;
  }
}
```

#### Inspecting Network Failures

```javascript
async function fetchWithNetworkInspection(url) {
  const startTime = performance.now();
  
  try {
    const response = await fetch(url);
    const endTime = performance.now();
    
    console.log('Request completed:', {
      duration: `${(endTime - startTime).toFixed(2)}ms`,
      status: response.status,
      type: response.type,
      redirected: response.redirected
    });
    
    return response;
  } catch (error) {
    const endTime = performance.now();
    
    console.error('Request failed:', {
      duration: `${(endTime - startTime).toFixed(2)}ms`,
      error: error.message,
      type: error.name
    });
    
    throw error;
  }
}
```

### Browser DevTools Integration

#### Performance Timing

```javascript
// Using Resource Timing API
async function fetchWithTiming(url) {
  const response = await fetch(url);
  
  // Get timing information
  const perfEntries = performance.getEntriesByName(url, 'resource');
  const timing = perfEntries[perfEntries.length - 1];
  
  if (timing) {
    console.log('Timing breakdown:', {
      dns: timing.domainLookupEnd - timing.domainLookupStart,
      tcp: timing.connectEnd - timing.connectStart,
      request: timing.responseStart - timing.requestStart,
      response: timing.responseEnd - timing.responseStart,
      total: timing.duration
    });
  }
  
  return response;
}
```

#### Request ID Tracking

```javascript
let requestId = 0;

async function fetchWithTracking(url, options = {}) {
  const id = ++requestId;
  const startTime = Date.now();
  
  console.group(`Request #${id}`);
  console.log('URL:', url);
  console.log('Options:', options);
  
  try {
    const response = await fetch(url, options);
    
    console.log('Response:', {
      status: response.status,
      duration: `${Date.now() - startTime}ms`
    });
    console.groupEnd();
    
    return response;
  } catch (error) {
    console.error('Error:', error);
    console.groupEnd();
    throw error;
  }
}
```

---

