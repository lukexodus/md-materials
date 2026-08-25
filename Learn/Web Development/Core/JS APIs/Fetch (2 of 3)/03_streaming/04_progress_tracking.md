## Progress Tracking 


### ReadableStream and Response Body

The Fetch API provides access to the response body as a `ReadableStream`, enabling byte-level progress tracking. The `Response.body` property exposes this stream, allowing you to process chunks as they arrive.

```javascript
const response = await fetch('https://example.com/large-file.zip');
const reader = response.body.getReader();
const contentLength = +response.headers.get('Content-Length');

let receivedLength = 0;
const chunks = [];

while (true) {
  const {done, value} = await reader.read();
  
  if (done) break;
  
  chunks.push(value);
  receivedLength += value.length;
  
  console.log(`Received ${receivedLength} of ${contentLength}`);
}
```

### Content-Length Header

Progress tracking relies heavily on the `Content-Length` response header. Without it, you can only track bytes received, not percentage complete.

```javascript
const contentLength = response.headers.get('Content-Length');

if (!contentLength) {
  console.warn('Content-Length not available - cannot calculate percentage');
}
```

#### Server Requirements

Servers must send `Content-Length` for accurate progress tracking. Compressed responses or chunked transfer encoding may omit this header. Some CDNs and proxies strip `Content-Length` when using compression.

### Download Progress Pattern

```javascript
async function fetchWithProgress(url, onProgress) {
  const response = await fetch(url);
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const contentLength = response.headers.get('Content-Length');
  
  if (!contentLength) {
    console.warn('Content-Length unavailable');
    return response.blob(); // Fallback without progress
  }
  
  const total = parseInt(contentLength, 10);
  let loaded = 0;
  
  const reader = response.body.getReader();
  const chunks = [];
  
  while (true) {
    const {done, value} = await reader.read();
    
    if (done) break;
    
    chunks.push(value);
    loaded += value.length;
    
    if (onProgress) {
      onProgress({
        loaded,
        total,
        percentage: (loaded / total) * 100
      });
    }
  }
  
  // Reconstruct the complete response
  const blob = new Blob(chunks);
  return blob;
}

// Usage
const blob = await fetchWithProgress('file.zip', (progress) => {
  console.log(`${progress.percentage.toFixed(2)}%`);
});
```

### Reconstructing Response Data

After consuming the stream, you must manually reconstruct the data:

#### Binary Data (Blob)

```javascript
const chunks = [];
const reader = response.body.getReader();

while (true) {
  const {done, value} = await reader.read();
  if (done) break;
  chunks.push(value);
}

const blob = new Blob(chunks);
```

#### Text Data

```javascript
const decoder = new TextDecoder();
let text = '';

while (true) {
  const {done, value} = await reader.read();
  if (done) break;
  text += decoder.decode(value, {stream: true});
}

text += decoder.decode(); // Final flush
```

#### JSON Data

```javascript
const chunks = [];
// ... read chunks ...

const blob = new Blob(chunks);
const text = await blob.text();
const data = JSON.parse(text);
```

### Typed Arrays and Memory Management

Stream chunks are `Uint8Array` instances. For large files, be mindful of memory accumulation.

```javascript
const chunks = [];
let totalSize = 0;

while (true) {
  const {done, value} = await reader.read();
  if (done) break;
  
  chunks.push(value);
  totalSize += value.length;
  
  // Memory check
  if (totalSize > MAX_SIZE) {
    throw new Error('File too large');
  }
}
```

### Stream Processing Without Accumulation

For very large files, process chunks without storing them all in memory:

```javascript
const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const {done, value} = await reader.read();
  if (done) break;
  
  const chunk = decoder.decode(value, {stream: true});
  
  // Process chunk immediately
  processChunk(chunk);
  
  // Chunk is now garbage-collectable
}
```

### Upload Progress Limitations

The Fetch API does **not** support upload progress tracking. The `Request.body` stream cannot be monitored.

```javascript
// This does NOT work for upload progress
const response = await fetch(url, {
  method: 'POST',
  body: largeFile // No way to track upload progress
});
```

#### Alternative: XMLHttpRequest

For upload progress, use `XMLHttpRequest`:

```javascript
function uploadWithProgress(url, data, onProgress) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    
    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable && onProgress) {
        onProgress({
          loaded: e.loaded,
          total: e.total,
          percentage: (e.loaded / e.total) * 100
        });
      }
    });
    
    xhr.addEventListener('load', () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        resolve(xhr.response);
      } else {
        reject(new Error(`HTTP ${xhr.status}`));
      }
    });
    
    xhr.addEventListener('error', () => reject(new Error('Upload failed')));
    
    xhr.open('POST', url);
    xhr.send(data);
  });
}
```

### Abortable Progress Tracking

Combine progress tracking with `AbortController`:

```javascript
async function fetchWithProgressAndAbort(url, onProgress, signal) {
  const response = await fetch(url, { signal });
  const contentLength = +response.headers.get('Content-Length');
  const reader = response.body.getReader();
  
  let loaded = 0;
  const chunks = [];
  
  try {
    while (true) {
      const {done, value} = await reader.read();
      
      if (done) break;
      
      chunks.push(value);
      loaded += value.length;
      
      if (onProgress) {
        onProgress({ loaded, total: contentLength });
      }
    }
    
    return new Blob(chunks);
  } catch (error) {
    await reader.cancel(); // Clean up stream
    throw error;
  }
}

// Usage
const controller = new AbortController();

fetchWithProgressAndAbort(url, onProgress, controller.signal)
  .catch(err => {
    if (err.name === 'AbortError') {
      console.log('Download cancelled');
    }
  });

// Cancel later
controller.abort();
```

### Progress Events with Custom Events

Dispatch browser events for UI integration:

```javascript
async function fetchWithEvents(url, element) {
  const response = await fetch(url);
  const contentLength = +response.headers.get('Content-Length');
  const reader = response.body.getReader();
  
  let loaded = 0;
  const chunks = [];
  
  element.dispatchEvent(new CustomEvent('downloadstart', {
    detail: { total: contentLength }
  }));
  
  while (true) {
    const {done, value} = await reader.read();
    
    if (done) break;
    
    chunks.push(value);
    loaded += value.length;
    
    element.dispatchEvent(new CustomEvent('downloadprogress', {
      detail: { loaded, total: contentLength }
    }));
  }
  
  element.dispatchEvent(new CustomEvent('downloadcomplete', {
    detail: { total: contentLength }
  }));
  
  return new Blob(chunks);
}

// Usage
element.addEventListener('downloadprogress', (e) => {
  const percent = (e.detail.loaded / e.detail.total) * 100;
  progressBar.value = percent;
});
```

### Response Cloning and Progress

You cannot track progress on cloned responses. Once `response.clone()` is called, the original body stream is consumed independently.

```javascript
const response = await fetch(url);
const clone = response.clone();

// These consume separate streams - no shared progress tracking
const blob1 = await response.blob();
const blob2 = await clone.blob();
```

### Compressed Responses

When responses use `Content-Encoding: gzip` or similar, the browser decompresses automatically. Progress tracking shows **compressed bytes**, not decompressed size.

```javascript
// Content-Length: 1000 (compressed size)
// Actual decompressed: 5000 bytes

// Progress will show 1000 bytes total, not 5000
```

The `Content-Length` header, when present with compression, reflects the compressed payload size.

### Service Workers and Progress

Service Workers can intercept fetch requests and create custom streaming responses with progress tracking:

```javascript
// In Service Worker
self.addEventListener('fetch', (event) => {
  if (event.request.url.includes('/tracked/')) {
    event.respondWith(fetchWithProgress(event.request));
  }
});

async function fetchWithProgress(request) {
  const response = await fetch(request);
  const reader = response.body.getReader();
  
  const stream = new ReadableStream({
    async start(controller) {
      while (true) {
        const {done, value} = await reader.read();
        
        if (done) {
          controller.close();
          break;
        }
        
        // Send progress message to clients
        self.clients.matchAll().then(clients => {
          clients.forEach(client => {
            client.postMessage({
              type: 'progress',
              loaded: value.length
            });
          });
        });
        
        controller.enqueue(value);
      }
    }
  });
  
  return new Response(stream, {
    headers: response.headers
  });
}
```

### Throttling Progress Updates

Avoid overwhelming the UI with progress updates:

```javascript
async function fetchWithThrottledProgress(url, onProgress, throttleMs = 100) {
  const response = await fetch(url);
  const contentLength = +response.headers.get('Content-Length');
  const reader = response.body.getReader();
  
  let loaded = 0;
  let lastUpdate = 0;
  const chunks = [];
  
  while (true) {
    const {done, value} = await reader.read();
    
    if (done) {
      // Final update
      if (onProgress) {
        onProgress({ loaded, total: contentLength });
      }
      break;
    }
    
    chunks.push(value);
    loaded += value.length;
    
    const now = Date.now();
    if (now - lastUpdate >= throttleMs) {
      if (onProgress) {
        onProgress({ loaded, total: contentLength });
      }
      lastUpdate = now;
    }
  }
  
  return new Blob(chunks);
}
```

### Cross-Origin and Content-Length

CORS policies may prevent access to the `Content-Length` header:

```javascript
const contentLength = response.headers.get('Content-Length');

if (!contentLength) {
  // Might be blocked by CORS
  // Server needs: Access-Control-Expose-Headers: Content-Length
}
```

The server must explicitly expose the header:

```
Access-Control-Expose-Headers: Content-Length
```

### Browser Support Considerations

All modern browsers support `ReadableStream` and `response.body`. For older browsers, progress tracking is unavailable, requiring fallback:

```javascript
async function fetchWithOptionalProgress(url, onProgress) {
  const response = await fetch(url);
  
  // Check for stream support
  if (!response.body || !response.body.getReader) {
    console.warn('Streaming not supported - no progress tracking');
    return response.blob();
  }
  
  // Proceed with progress tracking
  return fetchWithProgress(url, onProgress);
}
```

---

