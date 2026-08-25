## Chunked Transfer Encoding 


### Overview of Chunked Responses

Chunked transfer encoding allows servers to send response data in discrete chunks rather than as a single complete payload. With the Fetch API, you can process these chunks as they arrive using the `ReadableStream` interface exposed through `response.body`.

### Detecting Chunked Responses

```javascript
const response = await fetch('https://api.example.com/stream');

// Check if body is readable stream
if (response.body) {
  console.log('Response supports streaming');
}

// [Inference] Transfer-Encoding header typically indicates chunked encoding
const transferEncoding = response.headers.get('Transfer-Encoding');
if (transferEncoding === 'chunked') {
  console.log('Explicitly chunked response');
}
```

### Reading Chunks with ReadableStream

#### Basic Stream Reading

```javascript
const response = await fetch('https://api.example.com/data');
const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  
  if (done) {
    console.log('Stream complete');
    break;
  }
  
  // value is a Uint8Array containing the chunk
  console.log('Received chunk:', value.length, 'bytes');
}
```

#### Decoding Text Chunks

```javascript
const response = await fetch('https://api.example.com/text-stream');
const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  
  if (done) break;
  
  // Decode chunk to string
  const chunk = decoder.decode(value, { stream: true });
  console.log('Text chunk:', chunk);
}
```

### Handling Partial Data Across Chunks

#### Buffering Strategy

```javascript
const response = await fetch('https://api.example.com/json-stream');
const reader = response.body.getReader();
const decoder = new TextDecoder();
let buffer = '';

while (true) {
  const { done, value } = await reader.read();
  
  if (done) break;
  
  // Append to buffer
  buffer += decoder.decode(value, { stream: true });
  
  // Process complete lines
  let newlineIndex;
  while ((newlineIndex = buffer.indexOf('\n')) !== -1) {
    const line = buffer.slice(0, newlineIndex);
    buffer = buffer.slice(newlineIndex + 1);
    
    // Process complete line
    console.log('Complete line:', line);
  }
}

// Process remaining buffer
if (buffer.length > 0) {
  console.log('Final data:', buffer);
}
```

#### JSON Streaming Pattern

```javascript
async function* streamJSONLines(response) {
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';

  try {
    while (true) {
      const { done, value } = await reader.read();
      
      if (done) break;
      
      buffer += decoder.decode(value, { stream: true });
      
      const lines = buffer.split('\n');
      buffer = lines.pop() || ''; // Keep incomplete line in buffer
      
      for (const line of lines) {
        if (line.trim()) {
          yield JSON.parse(line);
        }
      }
    }
    
    // Process final buffer
    if (buffer.trim()) {
      yield JSON.parse(buffer);
    }
  } finally {
    reader.releaseLock();
  }
}

// Usage
const response = await fetch('https://api.example.com/ndjson');
for await (const obj of streamJSONLines(response)) {
  console.log('Parsed object:', obj);
}
```

### Stream Transformation with TransformStream

#### Decompression Example

```javascript
const response = await fetch('https://api.example.com/compressed');

// Pipe through decompression
const decompressedStream = response.body.pipeThrough(
  new DecompressionStream('gzip')
);

const reader = decompressedStream.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  console.log('Decompressed chunk:', decoder.decode(value, { stream: true }));
}
```

#### Custom Transform Stream

```javascript
class ChunkCounter extends TransformStream {
  constructor() {
    let chunkCount = 0;
    let totalBytes = 0;
    
    super({
      transform(chunk, controller) {
        chunkCount++;
        totalBytes += chunk.length;
        console.log(`Chunk ${chunkCount}: ${chunk.length} bytes (total: ${totalBytes})`);
        controller.enqueue(chunk);
      },
      flush(controller) {
        console.log(`Stream complete: ${chunkCount} chunks, ${totalBytes} bytes`);
      }
    });
  }
}

const response = await fetch('https://api.example.com/data');
const countedStream = response.body.pipeThrough(new ChunkCounter());

// Continue processing countedStream
```

### Progress Tracking

#### Download Progress with Content-Length

```javascript
async function fetchWithProgress(url, onProgress) {
  const response = await fetch(url);
  const contentLength = response.headers.get('Content-Length');
  
  if (!contentLength) {
    console.warn('Content-Length not available');
    return response;
  }
  
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
  'https://api.example.com/large-file',
  ({ loaded, total, percentage }) => {
    console.log(`Progress: ${percentage.toFixed(2)}% (${loaded}/${total})`);
  }
);
```

#### Streaming Without Content-Length

```javascript
async function streamWithChunkProgress(url, onChunk) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  
  let chunkIndex = 0;
  let totalBytes = 0;
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    totalBytes += value.length;
    onChunk({
      chunkIndex: chunkIndex++,
      chunkSize: value.length,
      totalBytes
    });
  }
  
  return { chunkIndex, totalBytes };
}
```

### Server-Sent Events (SSE) Pattern

```javascript
async function consumeSSE(url, onMessage, onError) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';
  
  try {
    while (true) {
      const { done, value } = await reader.read();
      
      if (done) break;
      
      buffer += decoder.decode(value, { stream: true });
      
      const lines = buffer.split('\n\n');
      buffer = lines.pop() || '';
      
      for (const message of lines) {
        if (!message.trim()) continue;
        
        const event = parseSSEMessage(message);
        if (event) {
          onMessage(event);
        }
      }
    }
  } catch (error) {
    onError(error);
  } finally {
    reader.releaseLock();
  }
}

function parseSSEMessage(raw) {
  const lines = raw.split('\n');
  const event = {};
  
  for (const line of lines) {
    if (line.startsWith('data: ')) {
      event.data = (event.data || '') + line.slice(6);
    } else if (line.startsWith('event: ')) {
      event.type = line.slice(7);
    } else if (line.startsWith('id: ')) {
      event.id = line.slice(4);
    } else if (line.startsWith('retry: ')) {
      event.retry = parseInt(line.slice(7), 10);
    }
  }
  
  return event.data ? event : null;
}

// Usage
consumeSSE(
  'https://api.example.com/events',
  (event) => {
    console.log('Event:', event.type, event.data);
  },
  (error) => {
    console.error('SSE error:', error);
  }
);
```

### Memory Management

#### Cancellation and Cleanup

```javascript
const controller = new AbortController();

async function streamWithCancellation(url, signal) {
  const response = await fetch(url, { signal });
  const reader = response.body.getReader();
  
  try {
    while (true) {
      const { done, value } = await reader.read();
      
      if (done) break;
      
      // Process chunk
      console.log('Chunk:', value.length);
    }
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Stream cancelled');
    } else {
      throw error;
    }
  } finally {
    reader.releaseLock();
  }
}

// Start streaming
const streamPromise = streamWithCancellation(
  'https://api.example.com/stream',
  controller.signal
);

// Cancel after 5 seconds
setTimeout(() => controller.abort(), 5000);
```

#### Backpressure Handling

```javascript
async function processWithBackpressure(response, processChunk) {
  const reader = response.body.getReader();
  
  try {
    while (true) {
      const { done, value } = await reader.read();
      
      if (done) break;
      
      // Wait for processing to complete before reading next chunk
      await processChunk(value);
    }
  } finally {
    reader.releaseLock();
  }
}

// Usage with slow processing
await processWithBackpressure(
  await fetch('https://api.example.com/data'),
  async (chunk) => {
    // Simulate slow processing
    await new Promise(resolve => setTimeout(resolve, 100));
    console.log('Processed chunk:', chunk.length);
  }
);
```

### Piping Streams

#### Direct Piping to WritableStream

```javascript
async function downloadToFile(url, writableStream) {
  const response = await fetch(url);
  
  if (!response.body) {
    throw new Error('Response body is null');
  }
  
  await response.body.pipeTo(writableStream);
}

// [Unverified] Example assumes File System Access API availability
// Usage with File System Access API (where supported)
// const fileHandle = await window.showSaveFilePicker();
// const writable = await fileHandle.createWritable();
// await downloadToFile('https://api.example.com/file', writable);
```

#### Tee for Multiple Consumers

```javascript
const response = await fetch('https://api.example.com/data');
const [stream1, stream2] = response.body.tee();

// Consumer 1: Calculate size
async function calculateSize(stream) {
  const reader = stream.getReader();
  let total = 0;
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    total += value.length;
  }
  
  return total;
}

// Consumer 2: Calculate hash
async function calculateHash(stream) {
  const reader = stream.getReader();
  // [Inference] Hash calculation implementation would go here
  // This is a simplified example
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    // Process chunk for hash
  }
}

// Process both simultaneously
const [size, hash] = await Promise.all([
  calculateSize(stream1),
  calculateHash(stream2)
]);

console.log('Size:', size, 'Hash:', hash);
```

### Error Handling in Streams

#### Retry Logic

```javascript
async function fetchStreamWithRetry(url, maxRetries = 3) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      const reader = response.body.getReader();
      const chunks = [];
      
      while (true) {
        const { done, value } = await reader.read();
        
        if (done) break;
        
        chunks.push(value);
      }
      
      return chunks;
      
    } catch (error) {
      console.error(`Attempt ${attempt + 1} failed:`, error);
      
      if (attempt === maxRetries - 1) {
        throw error;
      }
      
      // Wait before retry
      await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
    }
  }
}
```

#### Partial Failure Recovery

```javascript
async function resumableStreamFetch(url, onChunk, onError) {
  let bytesReceived = 0;
  let lastSuccessfulByte = 0;
  
  async function attemptStream(rangeStart = 0) {
    const headers = rangeStart > 0 
      ? { 'Range': `bytes=${rangeStart}-` }
      : {};
    
    try {
      const response = await fetch(url, { headers });
      const reader = response.body.getReader();
      
      while (true) {
        const { done, value } = await reader.read();
        
        if (done) {
          lastSuccessfulByte = bytesReceived;
          break;
        }
        
        bytesReceived += value.length;
        await onChunk(value, bytesReceived);
      }
      
    } catch (error) {
      onError(error, lastSuccessfulByte);
      
      // Resume from last successful position
      console.log(`Resuming from byte ${lastSuccessfulByte}`);
      await attemptStream(lastSuccessfulByte);
    }
  }
  
  await attemptStream();
}
```

### Performance Considerations

#### Chunk Size Analysis

```javascript
async function analyzeChunkSizes(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  
  const sizes = [];
  let startTime = performance.now();
  let lastChunkTime = startTime;
  
  while (true) {
    const chunkStartTime = performance.now();
    const { done, value } = await reader.read();
    
    if (done) break;
    
    const chunkEndTime = performance.now();
    const timeSinceLastChunk = chunkStartTime - lastChunkTime;
    
    sizes.push({
      size: value.length,
      receiveTime: chunkEndTime - chunkStartTime,
      intervalTime: timeSinceLastChunk
    });
    
    lastChunkTime = chunkEndTime;
  }
  
  const totalTime = performance.now() - startTime;
  const totalBytes = sizes.reduce((sum, s) => sum + s.size, 0);
  
  return {
    chunks: sizes.length,
    totalBytes,
    totalTime,
    averageChunkSize: totalBytes / sizes.length,
    throughput: (totalBytes / totalTime) * 1000, // bytes per second
    chunkDetails: sizes
  };
}
```

#### Optimal Buffer Size

```javascript
class BufferedStreamReader {
  constructor(stream, bufferSize = 64 * 1024) { // 64KB default
    this.reader = stream.getReader();
    this.bufferSize = bufferSize;
    this.buffer = new Uint8Array(bufferSize);
    this.bufferFilled = 0;
    this.bufferPosition = 0;
  }
  
  async read(size) {
    // If requested size is larger than buffer, read directly
    if (size > this.bufferSize) {
      const result = await this.reader.read();
      return result;
    }
    
    // Check if we have enough data in buffer
    const available = this.bufferFilled - this.bufferPosition;
    
    if (available >= size) {
      const data = this.buffer.slice(
        this.bufferPosition,
        this.bufferPosition + size
      );
      this.bufferPosition += size;
      return { done: false, value: data };
    }
    
    // Fill buffer
    const { done, value } = await this.reader.read();
    
    if (done) {
      return { done: true, value: undefined };
    }
    
    // Copy to buffer
    this.buffer.set(value, 0);
    this.bufferFilled = value.length;
    this.bufferPosition = 0;
    
    return this.read(size);
  }
  
  releaseLock() {
    this.reader.releaseLock();
  }
}
```

### Browser Compatibility Considerations

```javascript
function supportsStreams() {
  return (
    typeof ReadableStream !== 'undefined' &&
    typeof Response !== 'undefined' &&
    typeof Response.prototype.body !== 'undefined'
  );
}

async function fetchWithFallback(url) {
  if (supportsStreams()) {
    // Modern streaming approach
    const response = await fetch(url);
    const reader = response.body.getReader();
    
    // Process stream...
    
  } else {
    // Fallback: wait for complete response
    const response = await fetch(url);
    const data = await response.arrayBuffer();
    
    // Process complete data...
  }
}
```

### Integration with Other APIs

#### Web Workers for Stream Processing

```javascript
// Main thread
const worker = new Worker('stream-processor.js');

async function processStreamInWorker(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  
  worker.onmessage = (event) => {
    console.log('Processed result:', event.data);
  };
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) {
      worker.postMessage({ done: true });
      break;
    }
    
    // Transfer chunk to worker (zero-copy)
    worker.postMessage({ chunk: value.buffer }, [value.buffer]);
  }
}

// stream-processor.js (Worker)
self.onmessage = async (event) => {
  if (event.data.done) {
    // Finalize processing
    return;
  }
  
  const chunk = new Uint8Array(event.data.chunk);
  // Process chunk...
  
  self.postMessage({ processed: true });
};
```

#### IndexedDB Storage During Streaming

```javascript
async function streamToIndexedDB(url, dbName, storeName) {
  const db = await openDatabase(dbName);
  const response = await fetch(url);
  const reader = response.body.getReader();
  
  let chunkIndex = 0;
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    // Store chunk in IndexedDB
    const tx = db.transaction([storeName], 'readwrite');
    const store = tx.objectStore(storeName);
    
    await store.put({
      id: chunkIndex++,
      data: value,
      timestamp: Date.now()
    });
    
    await tx.complete;
  }
  
  console.log(`Stored ${chunkIndex} chunks in IndexedDB`);
}

function openDatabase(dbName) {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(dbName, 1);
    
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
    
    request.onupgradeneeded = (event) => {
      const db = event.target.result;
      if (!db.objectStoreNames.contains('chunks')) {
        db.createObjectStore('chunks', { keyPath: 'id' });
      }
    };
  });
}
```

---

