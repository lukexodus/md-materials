## Large File Handling with the Fetch API


### Understanding the Challenge

Large file operations present unique challenges when using the fetch API. Memory constraints, network interruptions, timeout issues, and user experience concerns all become critical factors. The browser's memory limitations mean that loading an entire large file into memory can cause crashes or severe performance degradation, particularly on mobile devices or systems with limited resources.

### Streaming Responses with ReadableStream

The fetch API provides native streaming capabilities through the ReadableStream interface, allowing you to process large files incrementally rather than waiting for the complete download.

```javascript
async function streamLargeFile(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const contentLength = +response.headers.get('Content-Length');
  
  let receivedLength = 0;
  let chunks = [];
  
  while(true) {
    const {done, value} = await reader.read();
    
    if (done) break;
    
    chunks.push(value);
    receivedLength += value.length;
    
    // Progress tracking
    const progress = (receivedLength / contentLength) * 100;
    console.log(`Downloaded ${progress.toFixed(2)}%`);
  }
  
  // Concatenate chunks
  const chunksAll = new Uint8Array(receivedLength);
  let position = 0;
  for(let chunk of chunks) {
    chunksAll.set(chunk, position);
    position += chunk.length;
  }
  
  return chunksAll;
}
```

### Processing Data During Download

Rather than accumulating all chunks, process them immediately to minimize memory usage:

```javascript
async function processStreamingData(url, processFn) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  
  while(true) {
    const {done, value} = await reader.read();
    if (done) break;
    
    // Process each chunk immediately
    const chunk = decoder.decode(value, {stream: true});
    await processFn(chunk);
  }
}

// Example: Process large CSV file line by line
await processStreamingData('large-data.csv', async (chunk) => {
  const lines = chunk.split('\n');
  for (const line of lines) {
    // Process each line
    await processRow(line);
  }
});
```

### Implementing Range Requests

Range requests allow you to download large files in segments, enabling pause/resume functionality and reducing memory footprint:

```javascript
async function downloadWithRanges(url, chunkSize = 1024 * 1024) { // 1MB chunks
  // Get file size
  const headResponse = await fetch(url, { method: 'HEAD' });
  const fileSize = +headResponse.headers.get('Content-Length');
  
  const chunks = [];
  let start = 0;
  
  while (start < fileSize) {
    const end = Math.min(start + chunkSize - 1, fileSize - 1);
    
    const response = await fetch(url, {
      headers: {
        'Range': `bytes=${start}-${end}`
      }
    });
    
    const chunk = await response.arrayBuffer();
    chunks.push(new Uint8Array(chunk));
    
    start = end + 1;
    
    // Progress reporting
    const progress = (start / fileSize) * 100;
    console.log(`Progress: ${progress.toFixed(2)}%`);
  }
  
  // Combine chunks
  const totalLength = chunks.reduce((acc, chunk) => acc + chunk.length, 0);
  const result = new Uint8Array(totalLength);
  let offset = 0;
  
  for (const chunk of chunks) {
    result.set(chunk, offset);
    offset += chunk.length;
  }
  
  return result;
}
```

### Resumable Downloads

Implement resumable downloads by tracking progress and supporting range requests:

```javascript
class ResumableDownload {
  constructor(url, filename) {
    this.url = url;
    this.filename = filename;
    this.downloadedBytes = 0;
    this.totalBytes = 0;
    this.chunks = [];
    this.paused = false;
    this.abortController = null;
  }
  
  async getFileSize() {
    const response = await fetch(this.url, { method: 'HEAD' });
    this.totalBytes = +response.headers.get('Content-Length');
    return this.totalBytes;
  }
  
  async start() {
    await this.getFileSize();
    this.abortController = new AbortController();
    
    const response = await fetch(this.url, {
      headers: {
        'Range': `bytes=${this.downloadedBytes}-`
      },
      signal: this.abortController.signal
    });
    
    const reader = response.body.getReader();
    
    try {
      while (true) {
        if (this.paused) {
          await new Promise(resolve => {
            this.resumeCallback = resolve;
          });
        }
        
        const {done, value} = await reader.read();
        if (done) break;
        
        this.chunks.push(value);
        this.downloadedBytes += value.length;
        
        this.onProgress?.(this.downloadedBytes, this.totalBytes);
      }
      
      this.onComplete?.(this.combineChunks());
    } catch (error) {
      if (error.name === 'AbortError') {
        this.onPause?.(this.downloadedBytes);
      } else {
        this.onError?.(error);
      }
    }
  }
  
  pause() {
    this.paused = true;
    this.abortController?.abort();
  }
  
  resume() {
    this.paused = false;
    this.resumeCallback?.();
    this.start();
  }
  
  combineChunks() {
    const totalLength = this.chunks.reduce((acc, chunk) => acc + chunk.length, 0);
    const result = new Uint8Array(totalLength);
    let offset = 0;
    
    for (const chunk of this.chunks) {
      result.set(chunk, offset);
      offset += chunk.length;
    }
    
    return result;
  }
}

// Usage
const download = new ResumableDownload('large-file.zip', 'file.zip');
download.onProgress = (downloaded, total) => {
  console.log(`${(downloaded/total*100).toFixed(2)}%`);
};
download.onComplete = (data) => {
  console.log('Download complete', data);
};
download.start();
```

### Uploading Large Files

Uploading large files requires different strategies to handle size limitations and provide progress feedback:

```javascript
async function uploadLargeFile(file, url, chunkSize = 5 * 1024 * 1024) { // 5MB chunks
  const totalChunks = Math.ceil(file.size / chunkSize);
  
  for (let chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
    const start = chunkIndex * chunkSize;
    const end = Math.min(start + chunkSize, file.size);
    const chunk = file.slice(start, end);
    
    const formData = new FormData();
    formData.append('chunk', chunk);
    formData.append('chunkIndex', chunkIndex);
    formData.append('totalChunks', totalChunks);
    formData.append('filename', file.name);
    
    const response = await fetch(url, {
      method: 'POST',
      body: formData
    });
    
    if (!response.ok) {
      throw new Error(`Upload failed for chunk ${chunkIndex}`);
    }
    
    // Progress tracking
    const progress = ((chunkIndex + 1) / totalChunks) * 100;
    console.log(`Upload progress: ${progress.toFixed(2)}%`);
  }
}
```

### Using XMLHttpRequest for Upload Progress

While fetch is modern, XMLHttpRequest still provides better upload progress tracking:

```javascript
function uploadWithProgress(file, url) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    
    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable) {
        const percentComplete = (e.loaded / e.total) * 100;
        console.log(`Upload: ${percentComplete.toFixed(2)}%`);
      }
    });
    
    xhr.addEventListener('load', () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        resolve(xhr.response);
      } else {
        reject(new Error(`Upload failed: ${xhr.status}`));
      }
    });
    
    xhr.addEventListener('error', () => reject(new Error('Upload error')));
    
    const formData = new FormData();
    formData.append('file', file);
    
    xhr.open('POST', url);
    xhr.send(formData);
  });
}
```

### Streaming Upload with Fetch (Experimental)

Modern browsers support streaming request bodies, though browser support varies:

```javascript
async function streamUpload(file, url) {
  const stream = file.stream();
  
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': file.type,
      'Content-Length': file.size
    },
    body: stream,
    duplex: 'half' // Required for streaming requests
  });
  
  return response;
}
```

### Memory-Efficient File Processing

Process files without loading them entirely into memory:

```javascript
async function processLargeFileInChunks(file, processFn, chunkSize = 1024 * 1024) {
  let offset = 0;
  
  while (offset < file.size) {
    const chunk = file.slice(offset, offset + chunkSize);
    const arrayBuffer = await chunk.arrayBuffer();
    
    await processFn(new Uint8Array(arrayBuffer), offset);
    
    offset += chunkSize;
    
    // Allow garbage collection
    await new Promise(resolve => setTimeout(resolve, 0));
  }
}

// Example: Calculate hash of large file
async function hashLargeFile(file) {
  const hashBuffer = await crypto.subtle.digest('SHA-256', 
    await file.arrayBuffer()
  );
  return Array.from(new Uint8Array(hashBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}
```

### Handling Timeouts and Retries

Large file operations need robust error handling and retry logic:

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  const controller = new AbortController();
  const timeout = options.timeout || 300000; // 5 minutes default
  
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  let lastError;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      return response;
    } catch (error) {
      lastError = error;
      
      if (attempt < maxRetries) {
        // Exponential backoff
        const delay = Math.min(1000 * Math.pow(2, attempt), 10000);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw lastError;
}
```

### Parallel Chunk Downloads

Download multiple chunks simultaneously to maximize throughput:

```javascript
async function parallelChunkDownload(url, options = {}) {
  const { maxParallel = 4, chunkSize = 2 * 1024 * 1024 } = options;
  
  // Get file size
  const headResponse = await fetch(url, { method: 'HEAD' });
  const fileSize = +headResponse.headers.get('Content-Length');
  
  const numChunks = Math.ceil(fileSize / chunkSize);
  const chunks = new Array(numChunks);
  
  async function downloadChunk(index) {
    const start = index * chunkSize;
    const end = Math.min(start + chunkSize - 1, fileSize - 1);
    
    const response = await fetch(url, {
      headers: { 'Range': `bytes=${start}-${end}` }
    });
    
    chunks[index] = new Uint8Array(await response.arrayBuffer());
  }
  
  // Download in parallel batches
  for (let i = 0; i < numChunks; i += maxParallel) {
    const batch = [];
    for (let j = 0; j < maxParallel && i + j < numChunks; j++) {
      batch.push(downloadChunk(i + j));
    }
    await Promise.all(batch);
  }
  
  // Combine chunks
  const totalLength = chunks.reduce((acc, chunk) => acc + chunk.length, 0);
  const result = new Uint8Array(totalLength);
  let offset = 0;
  
  for (const chunk of chunks) {
    result.set(chunk, offset);
    offset += chunk.length;
  }
  
  return result;
}
```

### Service Worker Caching for Large Files

Use service workers to cache large files efficiently:

```javascript
// service-worker.js
self.addEventListener('fetch', (event) => {
  if (event.request.url.includes('/large-files/')) {
    event.respondWith(
      caches.open('large-files-v1').then(async (cache) => {
        const cached = await cache.match(event.request);
        
        if (cached) {
          return cached;
        }
        
        const response = await fetch(event.request);
        
        // Only cache successful responses
        if (response.ok) {
          cache.put(event.request, response.clone());
        }
        
        return response;
      })
    );
  }
});
```

### Download Progress with Transform Streams

Use Transform Streams for processing data while tracking progress:

```javascript
async function downloadWithTransform(url, transformFn) {
  const response = await fetch(url);
  const contentLength = +response.headers.get('Content-Length');
  let receivedLength = 0;
  
  const transformStream = new TransformStream({
    transform(chunk, controller) {
      receivedLength += chunk.length;
      const progress = (receivedLength / contentLength) * 100;
      
      // Report progress
      self.postMessage({ type: 'progress', progress });
      
      // Transform the chunk if needed
      const transformed = transformFn ? transformFn(chunk) : chunk;
      controller.enqueue(transformed);
    }
  });
  
  const transformedResponse = new Response(
    response.body.pipeThrough(transformStream)
  );
  
  return transformedResponse;
}
```

### Blob URL Management

Create and manage blob URLs for large downloaded files:

```javascript
class LargeFileManager {
  constructor() {
    this.blobUrls = new Map();
  }
  
  async download(url, filename) {
    const response = await fetch(url);
    const blob = await response.blob();
    
    const blobUrl = URL.createObjectURL(blob);
    this.blobUrls.set(filename, blobUrl);
    
    return blobUrl;
  }
  
  trigger(filename) {
    const blobUrl = this.blobUrls.get(filename);
    if (!blobUrl) return;
    
    const a = document.createElement('a');
    a.href = blobUrl;
    a.download = filename;
    a.click();
  }
  
  revoke(filename) {
    const blobUrl = this.blobUrls.get(filename);
    if (blobUrl) {
      URL.revokeObjectURL(blobUrl);
      this.blobUrls.delete(filename);
    }
  }
  
  revokeAll() {
    for (const [filename, blobUrl] of this.blobUrls) {
      URL.revokeObjectURL(blobUrl);
    }
    this.blobUrls.clear();
  }
}
```

### Compression During Transfer

Apply compression to reduce transfer size:

```javascript
async function downloadCompressed(url) {
  const response = await fetch(url, {
    headers: {
      'Accept-Encoding': 'gzip, deflate, br'
    }
  });
  
  // Check if compressed
  const encoding = response.headers.get('Content-Encoding');
  console.log('Encoding:', encoding);
  
  // Decompress if needed (browser handles automatically)
  const decompressed = await response.arrayBuffer();
  
  return decompressed;
}

// Manual decompression with DecompressionStream
async function manualDecompress(compressedData, format = 'gzip') {
  const stream = new Blob([compressedData]).stream();
  const decompressedStream = stream.pipeThrough(
    new DecompressionStream(format)
  );
  
  const response = new Response(decompressedStream);
  return response.arrayBuffer();
}
```

### Monitoring Network Conditions

Adapt chunk sizes based on network conditions:

```javascript
class AdaptiveDownloader {
  constructor(url) {
    this.url = url;
    this.chunkSize = 1024 * 1024; // Start with 1MB
    this.minChunkSize = 256 * 1024; // 256KB
    this.maxChunkSize = 10 * 1024 * 1024; // 10MB
  }
  
  async download() {
    const connection = navigator.connection;
    
    // Adjust based on connection type
    if (connection) {
      const effectiveType = connection.effectiveType;
      
      switch(effectiveType) {
        case 'slow-2g':
        case '2g':
          this.chunkSize = this.minChunkSize;
          break;
        case '3g':
          this.chunkSize = 512 * 1024;
          break;
        case '4g':
          this.chunkSize = this.maxChunkSize;
          break;
      }
    }
    
    // Monitor for changes
    connection?.addEventListener('change', () => {
      console.log('Connection changed:', connection.effectiveType);
    });
    
    return this.downloadWithChunks();
  }
  
  async downloadWithChunks() {
    const response = await fetch(this.url, { method: 'HEAD' });
    const fileSize = +response.headers.get('Content-Length');
    
    let downloaded = 0;
    const chunks = [];
    
    while (downloaded < fileSize) {
      const start = downloaded;
      const end = Math.min(downloaded + this.chunkSize - 1, fileSize - 1);
      
      const startTime = performance.now();
      
      const chunkResponse = await fetch(this.url, {
        headers: { 'Range': `bytes=${start}-${end}` }
      });
      
      const chunk = await chunkResponse.arrayBuffer();
      const endTime = performance.now();
      
      chunks.push(new Uint8Array(chunk));
      downloaded = end + 1;
      
      // Adapt chunk size based on download speed
      const duration = endTime - startTime;
      const bytesPerMs = chunk.byteLength / duration;
      
      // Adjust if too slow or too fast
      if (duration > 5000) { // More than 5 seconds
        this.chunkSize = Math.max(
          this.minChunkSize,
          this.chunkSize * 0.75
        );
      } else if (duration < 1000) { // Less than 1 second
        this.chunkSize = Math.min(
          this.maxChunkSize,
          this.chunkSize * 1.5
        );
      }
    }
    
    return this.combineChunks(chunks);
  }
  
  combineChunks(chunks) {
    const totalLength = chunks.reduce((acc, chunk) => acc + chunk.length, 0);
    const result = new Uint8Array(totalLength);
    let offset = 0;
    
    for (const chunk of chunks) {
      result.set(chunk, offset);
      offset += chunk.length;
    }
    
    return result;
  }
}
```

### IndexedDB Storage for Large Files

Store large files in IndexedDB for offline access:

```javascript
class FileStorage {
  constructor(dbName = 'LargeFilesDB') {
    this.dbName = dbName;
    this.db = null;
  }
  
  async init() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.dbName, 1);
      
      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve();
      };
      
      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        if (!db.objectStoreNames.contains('files')) {
          db.createObjectStore('files', { keyPath: 'id' });
        }
      };
    });
  }
  
  async saveFile(id, data, metadata = {}) {
    const transaction = this.db.transaction(['files'], 'readwrite');
    const store = transaction.objectStore('files');
    
    await store.put({
      id,
      data,
      metadata,
      timestamp: Date.now()
    });
  }
  
  async getFile(id) {
    const transaction = this.db.transaction(['files'], 'readonly');
    const store = transaction.objectStore('files');
    
    return new Promise((resolve, reject) => {
      const request = store.get(id);
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }
  
  async deleteFile(id) {
    const transaction = this.db.transaction(['files'], 'readwrite');
    const store = transaction.objectStore('files');
    await store.delete(id);
  }
}
```

### Best Practices Summary

Always implement proper progress tracking for user feedback during long operations. Use streaming whenever possible to minimize memory usage. Implement retry logic with exponential backoff for network failures. Consider chunking strategies based on file size and network conditions. Use range requests for resumable downloads. Monitor memory usage and release resources promptly using `URL.revokeObjectURL()`. Implement proper error boundaries and user-friendly error messages. Test with various file sizes and network conditions. Consider using Web Workers for CPU-intensive processing during file operations. Implement proper cancellation mechanisms using AbortController.

---

