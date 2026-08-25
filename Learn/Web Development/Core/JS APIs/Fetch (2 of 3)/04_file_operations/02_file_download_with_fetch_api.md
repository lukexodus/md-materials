## File Download with Fetch API


### Handling Binary Response Data

The fetch API provides multiple methods to handle downloaded file data through the Response object. The choice depends on the file type and intended use:

```javascript
// For binary files - returns ArrayBuffer
const response = await fetch('https://example.com/file.pdf');
const buffer = await response.arrayBuffer();

// For text files - returns string
const text = await response.text();

// For JSON data - returns parsed object
const json = await response.json();

// For streaming - returns ReadableStream
const stream = response.body;
```

### Blob-Based Downloads

Converting response data to Blob objects enables browser-native download mechanisms:

```javascript
const response = await fetch('https://example.com/document.pdf');
const blob = await response.blob();

// Create object URL
const url = URL.createObjectURL(blob);

// Trigger download
const a = document.createElement('a');
a.href = url;
a.download = 'document.pdf';
document.body.appendChild(a);
a.click();

// Cleanup
document.body.removeChild(a);
URL.revokeObjectURL(url);
```

### Download Progress Tracking

Streaming responses through ReadableStream enables real-time progress monitoring:

```javascript
const response = await fetch('https://example.com/large-file.zip');
const contentLength = response.headers.get('Content-Length');
const total = parseInt(contentLength, 10);
let received = 0;

const reader = response.body.getReader();
const chunks = [];

while (true) {
  const { done, value } = await reader.read();
  
  if (done) break;
  
  chunks.push(value);
  received += value.length;
  
  const progress = (received / total) * 100;
  console.log(`Progress: ${progress.toFixed(2)}%`);
}

const blob = new Blob(chunks);
```

### Handling Large Files

For files exceeding memory constraints, streaming directly to disk or processing in chunks prevents memory issues:

```javascript
async function downloadLargeFile(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  
  // Process chunks as they arrive
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    // Process chunk (e.g., write to IndexedDB, FileSystem API)
    await processChunk(value);
  }
}
```

### Content-Type and MIME Type Handling

Proper MIME type specification ensures correct file handling:

```javascript
const response = await fetch('https://example.com/file');
const contentType = response.headers.get('Content-Type');

// Create blob with explicit type
const blob = await response.blob();
const typedBlob = new Blob([blob], { type: contentType });

// Or specify custom type
const pdfBlob = new Blob([blob], { type: 'application/pdf' });
```

### Filename Extraction

Extracting filenames from Content-Disposition headers:

```javascript
function getFilenameFromResponse(response) {
  const disposition = response.headers.get('Content-Disposition');
  
  if (!disposition) return 'download';
  
  // Match filename*=UTF-8''encoded or filename="quoted"
  const utf8Match = disposition.match(/filename\*=UTF-8''(.+)/i);
  if (utf8Match) {
    return decodeURIComponent(utf8Match[1]);
  }
  
  const quotedMatch = disposition.match(/filename="(.+)"/i);
  if (quotedMatch) {
    return quotedMatch[1];
  }
  
  const unquotedMatch = disposition.match(/filename=([^;]+)/i);
  if (unquotedMatch) {
    return unquotedMatch[1].trim();
  }
  
  return 'download';
}

const response = await fetch('https://example.com/file');
const filename = getFilenameFromResponse(response);
```

### Cross-Origin Download Considerations

CORS policies affect file downloads from different origins:

```javascript
// Server must send appropriate CORS headers
fetch('https://other-domain.com/file.pdf', {
  mode: 'cors',
  credentials: 'include' // If authentication needed
})
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    return response.blob();
  })
  .then(blob => {
    // Process download
  });
```

Required server headers:

```
Access-Control-Allow-Origin: https://your-domain.com
Access-Control-Allow-Credentials: true
Access-Control-Expose-Headers: Content-Disposition, Content-Length
```

### Authentication and Authorization

Including credentials in download requests:

```javascript
// Bearer token
fetch('https://api.example.com/files/123', {
  headers: {
    'Authorization': 'Bearer ' + token
  }
})
  .then(response => response.blob());

// Cookie-based authentication
fetch('https://api.example.com/files/123', {
  credentials: 'include'
})
  .then(response => response.blob());

// Custom headers
fetch('https://api.example.com/files/123', {
  headers: {
    'X-API-Key': apiKey,
    'X-User-Token': userToken
  }
})
  .then(response => response.blob());
```

### Error Handling and Retry Logic

Robust error handling for download failures:

```javascript
async function downloadWithRetry(url, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const blob = await response.blob();
      return blob;
      
    } catch (error) {
      console.error(`Attempt ${attempt} failed:`, error);
      
      if (attempt === maxRetries) {
        throw new Error(`Download failed after ${maxRetries} attempts`);
      }
      
      // Exponential backoff
      await new Promise(resolve => 
        setTimeout(resolve, Math.pow(2, attempt) * 1000)
      );
    }
  }
}
```

### Range Requests for Resumable Downloads

Implementing partial content downloads:

```javascript
async function downloadRange(url, start, end) {
  const response = await fetch(url, {
    headers: {
      'Range': `bytes=${start}-${end}`
    }
  });
  
  if (response.status === 206) { // Partial Content
    return await response.arrayBuffer();
  }
  
  throw new Error('Range requests not supported');
}

// Resume interrupted download
async function resumableDownload(url) {
  const chunks = [];
  const chunkSize = 1024 * 1024; // 1MB chunks
  let downloaded = 0;
  
  // Get total size
  const headResponse = await fetch(url, { method: 'HEAD' });
  const totalSize = parseInt(headResponse.headers.get('Content-Length'), 10);
  
  while (downloaded < totalSize) {
    const end = Math.min(downloaded + chunkSize - 1, totalSize - 1);
    const chunk = await downloadRange(url, downloaded, end);
    chunks.push(chunk);
    downloaded = end + 1;
    
    console.log(`Downloaded: ${downloaded}/${totalSize}`);
  }
  
  return new Blob(chunks);
}
```

### Memory-Efficient Streaming Downloads

Using streams to avoid loading entire files into memory:

```javascript
async function streamToFile(url, filename) {
  const response = await fetch(url);
  
  // Check if browser supports File System Access API
  if ('showSaveFilePicker' in window) {
    const handle = await window.showSaveFilePicker({
      suggestedName: filename
    });
    const writable = await handle.createWritable();
    
    const reader = response.body.getReader();
    
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      await writable.write(value);
    }
    
    await writable.close();
  } else {
    // Fallback to blob download
    const blob = await response.blob();
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
  }
}
```

### Concurrent Chunk Downloads

Downloading file segments in parallel for improved speed:

```javascript
async function parallelDownload(url, numConnections = 4) {
  // Get file size
  const headResponse = await fetch(url, { method: 'HEAD' });
  const fileSize = parseInt(headResponse.headers.get('Content-Length'), 10);
  
  const chunkSize = Math.ceil(fileSize / numConnections);
  const promises = [];
  
  for (let i = 0; i < numConnections; i++) {
    const start = i * chunkSize;
    const end = Math.min(start + chunkSize - 1, fileSize - 1);
    
    promises.push(
      fetch(url, {
        headers: { 'Range': `bytes=${start}-${end}` }
      }).then(response => response.arrayBuffer())
    );
  }
  
  const chunks = await Promise.all(promises);
  return new Blob(chunks);
}
```

### Download Cancellation

Implementing cancellable downloads with AbortController:

```javascript
let abortController = null;

async function startDownload(url) {
  abortController = new AbortController();
  
  try {
    const response = await fetch(url, {
      signal: abortController.signal
    });
    
    const reader = response.body.getReader();
    const chunks = [];
    
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      chunks.push(value);
    }
    
    const blob = new Blob(chunks);
    return blob;
    
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Download cancelled');
    } else {
      throw error;
    }
  }
}

function cancelDownload() {
  if (abortController) {
    abortController.abort();
  }
}
```

### Integrity Verification

Validating downloaded files using checksums:

```javascript
async function downloadAndVerify(url, expectedHash) {
  const response = await fetch(url);
  const buffer = await response.arrayBuffer();
  
  // Calculate hash
  const hashBuffer = await crypto.subtle.digest('SHA-256', buffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  
  if (hashHex !== expectedHash) {
    throw new Error('Integrity check failed: hash mismatch');
  }
  
  return new Blob([buffer]);
}
```

### Compression Handling

Dealing with compressed responses:

```javascript
async function downloadCompressed(url) {
  const response = await fetch(url);
  const encoding = response.headers.get('Content-Encoding');
  
  if (encoding === 'gzip' || encoding === 'deflate' || encoding === 'br') {
    // Browser automatically decompresses
    const blob = await response.blob();
    return blob;
  }
  
  // Manual decompression for unsupported formats
  const buffer = await response.arrayBuffer();
  // Use third-party library for decompression
  return buffer;
}
```

### Download Queue Management

Managing multiple simultaneous downloads:

```javascript
class DownloadQueue {
  constructor(maxConcurrent = 3) {
    this.maxConcurrent = maxConcurrent;
    this.active = 0;
    this.queue = [];
  }
  
  async add(url, options = {}) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject });
      this.process();
    });
  }
  
  async process() {
    if (this.active >= this.maxConcurrent || this.queue.length === 0) {
      return;
    }
    
    const { url, options, resolve, reject } = this.queue.shift();
    this.active++;
    
    try {
      const response = await fetch(url, options);
      const blob = await response.blob();
      resolve(blob);
    } catch (error) {
      reject(error);
    } finally {
      this.active--;
      this.process();
    }
  }
}

const queue = new DownloadQueue(3);
queue.add('https://example.com/file1.pdf');
queue.add('https://example.com/file2.pdf');
```

### Response Caching

Leveraging browser cache for repeated downloads:

```javascript
// Force cache revalidation
fetch(url, {
  cache: 'reload'
});

// Use cached version if available
fetch(url, {
  cache: 'force-cache'
});

// Default behavior - check freshness
fetch(url, {
  cache: 'default'
});

// Only use cache, fail if not cached
fetch(url, {
  cache: 'only-if-cached',
  mode: 'same-origin'
});
```

### Service Worker Integration

Intercepting downloads in service workers:

```javascript
// In service worker
self.addEventListener('fetch', event => {
  if (event.request.url.endsWith('.pdf')) {
    event.respondWith(
      caches.match(event.request).then(cached => {
        if (cached) return cached;
        
        return fetch(event.request).then(response => {
          const clone = response.clone();
          caches.open('downloads').then(cache => {
            cache.put(event.request, clone);
          });
          return response;
        });
      })
    );
  }
});
```

### Bandwidth Throttling Simulation

Testing downloads under constrained network conditions:

```javascript
async function throttledDownload(url, bytesPerSecond) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const chunks = [];
  
  const chunkDelay = 100; // ms
  const bytesPerChunk = (bytesPerSecond * chunkDelay) / 1000;
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    chunks.push(value);
    
    // Simulate throttling
    await new Promise(resolve => setTimeout(resolve, chunkDelay));
  }
  
  return new Blob(chunks);
}
```

### Multi-Part File Assembly

Downloading and assembling files split across multiple endpoints:

```javascript
async function downloadMultipart(urls) {
  const chunks = await Promise.all(
    urls.map(url => 
      fetch(url).then(response => response.arrayBuffer())
    )
  );
  
  // Calculate total size
  const totalSize = chunks.reduce((sum, chunk) => sum + chunk.byteLength, 0);
  
  // Combine into single ArrayBuffer
  const combined = new Uint8Array(totalSize);
  let offset = 0;
  
  for (const chunk of chunks) {
    combined.set(new Uint8Array(chunk), offset);
    offset += chunk.byteLength;
  }
  
  return new Blob([combined.buffer]);
}
```

### Download State Persistence

Storing download progress for recovery:

```javascript
class PersistentDownload {
  constructor(url, storageKey) {
    this.url = url;
    this.storageKey = storageKey;
  }
  
  async download() {
    // Load previous progress
    const savedProgress = localStorage.getItem(this.storageKey);
    let downloaded = savedProgress ? parseInt(savedProgress, 10) : 0;
    
    const response = await fetch(this.url, {
      headers: downloaded > 0 ? { 'Range': `bytes=${downloaded}-` } : {}
    });
    
    const reader = response.body.getReader();
    const chunks = [];
    
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      
      chunks.push(value);
      downloaded += value.length;
      
      // Save progress
      localStorage.setItem(this.storageKey, downloaded.toString());
    }
    
    // Clear progress on completion
    localStorage.removeItem(this.storageKey);
    
    return new Blob(chunks);
  }
}
```

### TypeScript Type Safety

Type definitions for download operations:

```typescript
interface DownloadOptions {
  method?: string;
  headers?: Record<string, string>;
  signal?: AbortSignal;
  onProgress?: (loaded: number, total: number) => void;
}

interface DownloadResult {
  blob: Blob;
  filename: string;
  contentType: string;
  size: number;
}

async function downloadFile(
  url: string, 
  options: DownloadOptions = {}
): Promise<DownloadResult> {
  const response = await fetch(url, {
    method: options.method || 'GET',
    headers: options.headers,
    signal: options.signal
  });
  
  if (!response.ok) {
    throw new Error(`Download failed: ${response.status}`);
  }
  
  const contentLength = response.headers.get('Content-Length');
  const total = contentLength ? parseInt(contentLength, 10) : 0;
  let loaded = 0;
  
  const reader = response.body!.getReader();
  const chunks: Uint8Array[] = [];
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    chunks.push(value);
    loaded += value.length;
    
    if (options.onProgress && total > 0) {
      options.onProgress(loaded, total);
    }
  }
  
  const blob = new Blob(chunks);
  
  return {
    blob,
    filename: getFilenameFromResponse(response),
    contentType: response.headers.get('Content-Type') || 'application/octet-stream',
    size: blob.size
  };
}
```

---

