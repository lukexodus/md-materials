## Progress Monitoring in Fetch API File Operations


### Understanding Progress Events

The Fetch API itself does not directly expose progress events for uploads or downloads. Unlike `XMLHttpRequest`, which provides `progress`, `load`, and `error` events through its event system, the Fetch API uses Streams API for progress monitoring.

### Download Progress Monitoring

#### Using ReadableStream

Response bodies in Fetch are exposed as `ReadableStream` objects, allowing chunk-by-chunk processing:

```javascript
const response = await fetch('https://example.com/largefile.zip');
const reader = response.body.getReader();
const contentLength = +response.headers.get('Content-Length');

let receivedLength = 0;
const chunks = [];

while(true) {
  const {done, value} = await reader.read();
  
  if (done) break;
  
  chunks.push(value);
  receivedLength += value.length;
  
  const progress = (receivedLength / contentLength) * 100;
  console.log(`Downloaded: ${progress.toFixed(2)}%`);
}
```

#### Reconstructing the Complete Response

After reading all chunks, combine them into a single response:

```javascript
const chunksAll = new Uint8Array(receivedLength);
let position = 0;

for(const chunk of chunks) {
  chunksAll.set(chunk, position);
  position += chunk.length;
}

// Convert to appropriate format
const blob = new Blob([chunksAll]);
const text = new TextDecoder("utf-8").decode(chunksAll);
const json = JSON.parse(text);
```

#### Handling Missing Content-Length

[Inference] When `Content-Length` header is absent (streaming responses, chunked transfer encoding), total size cannot be determined:

```javascript
const contentLength = +response.headers.get('Content-Length');

if (!contentLength) {
  console.log(`Downloaded: ${receivedLength} bytes (total unknown)`);
} else {
  const progress = (receivedLength / contentLength) * 100;
  console.log(`Downloaded: ${progress.toFixed(2)}%`);
}
```

### Upload Progress Monitoring

#### The Fundamental Limitation

The Fetch API does not provide built-in upload progress monitoring. The request body is sent as a complete operation without intermediate progress callbacks.

#### Alternative Approaches

**XMLHttpRequest for Upload Progress:**

```javascript
function uploadWithProgress(url, file, onProgress) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    
    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable) {
        const progress = (e.loaded / e.total) * 100;
        onProgress(progress);
      }
    });
    
    xhr.addEventListener('load', () => {
      resolve(xhr.response);
    });
    
    xhr.addEventListener('error', () => {
      reject(new Error('Upload failed'));
    });
    
    xhr.open('POST', url);
    xhr.send(file);
  });
}
```

**[Unverified] Custom Stream Implementation:**

[Speculation] While theoretically possible to create a custom `ReadableStream` that tracks bytes written, browser implementations may buffer the entire stream before transmission, making progress tracking unreliable.

### Practical Implementation Patterns

#### Download Progress Component

```javascript
async function downloadWithProgress(url, onProgress) {
  const response = await fetch(url);
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  const contentLength = +response.headers.get('Content-Length');
  const reader = response.body.getReader();
  
  let receivedLength = 0;
  const chunks = [];
  
  while (true) {
    const {done, value} = await reader.read();
    
    if (done) break;
    
    chunks.push(value);
    receivedLength += value.length;
    
    if (contentLength) {
      onProgress({
        loaded: receivedLength,
        total: contentLength,
        percentage: (receivedLength / contentLength) * 100
      });
    } else {
      onProgress({
        loaded: receivedLength,
        total: null,
        percentage: null
      });
    }
  }
  
  const blob = new Blob(chunks);
  return blob;
}
```

#### Cancelable Downloads

Combining `AbortController` with progress monitoring:

```javascript
const controller = new AbortController();
const signal = controller.signal;

async function cancelableDownload(url, onProgress) {
  const response = await fetch(url, { signal });
  const reader = response.body.getReader();
  const contentLength = +response.headers.get('Content-Length');
  
  let receivedLength = 0;
  const chunks = [];
  
  try {
    while (true) {
      const {done, value} = await reader.read();
      
      if (done) break;
      
      chunks.push(value);
      receivedLength += value.length;
      
      onProgress(receivedLength, contentLength);
    }
    
    return new Blob(chunks);
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Download canceled');
    }
    throw error;
  }
}

// Cancel the download
controller.abort();
```

### Memory Management Considerations

#### Streaming to Disk (Service Workers)

[Inference] In Service Workers with Cache API, chunks can be written incrementally to avoid memory accumulation:

```javascript
// Service Worker context
async function streamToCache(url, cacheName) {
  const response = await fetch(url);
  const cache = await caches.open(cacheName);
  
  // Cache the response while monitoring progress
  await cache.put(url, response.clone());
  
  // Monitor progress separately
  const reader = response.body.getReader();
  let receivedLength = 0;
  
  while (true) {
    const {done, value} = await reader.read();
    if (done) break;
    receivedLength += value.length;
    
    // Send progress to clients
    self.clients.matchAll().then(clients => {
      clients.forEach(client => {
        client.postMessage({
          type: 'download-progress',
          loaded: receivedLength
        });
      });
    });
  }
}
```

#### Chunked Processing

For large files, process chunks immediately rather than accumulating:

```javascript
async function processLargeFile(url, chunkProcessor) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  
  while (true) {
    const {done, value} = await reader.read();
    
    if (done) break;
    
    // Process each chunk immediately
    await chunkProcessor(value);
  }
}

// Example: Hash calculation without storing entire file
import { SHA256 } from 'crypto-js';

let hash = SHA256.create();

await processLargeFile(url, (chunk) => {
  const wordArray = SHA256.lib.WordArray.create(chunk);
  hash.update(wordArray);
});

const finalHash = hash.finalize().toString();
```

### Browser Compatibility and Fallbacks

#### Feature Detection

```javascript
function supportsStreamProgress() {
  return 'body' in Response.prototype && 
         'getReader' in ReadableStream.prototype;
}

async function downloadFile(url, onProgress) {
  if (supportsStreamProgress()) {
    return downloadWithProgress(url, onProgress);
  } else {
    // Fallback: download without progress
    const response = await fetch(url);
    return response.blob();
  }
}
```

### Performance Optimization

#### Throttling Progress Updates

Avoid excessive UI updates by throttling progress callbacks:

```javascript
function createThrottledProgress(callback, delay = 100) {
  let lastUpdate = 0;
  
  return (loaded, total) => {
    const now = Date.now();
    
    if (now - lastUpdate >= delay) {
      callback(loaded, total);
      lastUpdate = now;
    }
  };
}

const throttledProgress = createThrottledProgress((loaded, total) => {
  updateProgressBar(loaded, total);
}, 100);

await downloadWithProgress(url, throttledProgress);
```

#### RequestAnimationFrame for Smooth UI

```javascript
let rafId;
let currentProgress = { loaded: 0, total: 0 };

function updateProgressRAF() {
  updateProgressBar(currentProgress.loaded, currentProgress.total);
  rafId = requestAnimationFrame(updateProgressRAF);
}

rafId = requestAnimationFrame(updateProgressRAF);

await downloadWithProgress(url, (loaded, total) => {
  currentProgress = { loaded, total };
});

cancelAnimationFrame(rafId);
```

### Real-World Implementation Example

```javascript
class DownloadManager {
  constructor() {
    this.downloads = new Map();
  }
  
  async download(url, options = {}) {
    const id = crypto.randomUUID();
    const controller = new AbortController();
    
    const downloadInfo = {
      id,
      url,
      controller,
      progress: { loaded: 0, total: null, percentage: 0 },
      status: 'pending'
    };
    
    this.downloads.set(id, downloadInfo);
    
    try {
      downloadInfo.status = 'downloading';
      
      const response = await fetch(url, {
        signal: controller.signal
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      const contentLength = +response.headers.get('Content-Length');
      const reader = response.body.getReader();
      
      let receivedLength = 0;
      const chunks = [];
      
      while (true) {
        const {done, value} = await reader.read();
        
        if (done) break;
        
        chunks.push(value);
        receivedLength += value.length;
        
        downloadInfo.progress = {
          loaded: receivedLength,
          total: contentLength || null,
          percentage: contentLength 
            ? (receivedLength / contentLength) * 100 
            : null
        };
        
        if (options.onProgress) {
          options.onProgress(downloadInfo.progress);
        }
      }
      
      downloadInfo.status = 'completed';
      const blob = new Blob(chunks);
      
      return { id, blob, url };
      
    } catch (error) {
      downloadInfo.status = error.name === 'AbortError' 
        ? 'canceled' 
        : 'failed';
      downloadInfo.error = error.message;
      throw error;
      
    } finally {
      if (options.onComplete) {
        options.onComplete(downloadInfo);
      }
    }
  }
  
  cancel(id) {
    const download = this.downloads.get(id);
    if (download && download.status === 'downloading') {
      download.controller.abort();
    }
  }
  
  getProgress(id) {
    return this.downloads.get(id)?.progress;
  }
  
  getAllDownloads() {
    return Array.from(this.downloads.values());
  }
}
```

---

