## Response Body Streaming


### ReadableStream Interface

The Fetch API exposes response bodies as `ReadableStream` objects, enabling chunk-by-chunk processing of data without waiting for the entire response to download. The `response.body` property returns a `ReadableStream` of `Uint8Array` chunks.

```javascript
const response = await fetch('https://example.com/large-file');
const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  // value is a Uint8Array chunk
  console.log('Received chunk:', value.length, 'bytes');
}
```

### Getting a Reader

The `getReader()` method locks the stream to a single reader, preventing other consumers from accessing it simultaneously. This returns a `ReadableStreamDefaultReader` that provides the `read()` method.

```javascript
const reader = response.body.getReader();
// Stream is now locked - no other code can read from response.body
```

[Inference] Once locked, attempting to get another reader or use convenience methods like `.text()` or `.json()` will throw an error, as the stream can only have one active reader at a time.

### Reading Chunks

The `read()` method returns a Promise that resolves to an object with two properties:

- `done`: Boolean indicating if the stream has ended
- `value`: `Uint8Array` containing the chunk data (undefined when done is true)

```javascript
const { done, value } = await reader.read();

if (!done) {
  // Process the Uint8Array chunk
  const text = new TextDecoder().decode(value);
}
```

### Processing Streamed Text

For text responses, combine `TextDecoder` with streaming to process data incrementally:

```javascript
const response = await fetch('https://example.com/stream');
const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  const chunk = decoder.decode(value, { stream: true });
  console.log('Text chunk:', chunk);
}
```

The `{ stream: true }` option tells `TextDecoder` to preserve incomplete multi-byte characters across chunks, completing them when the next chunk arrives.

### Canceling Streams

Call `reader.cancel()` to abort downloading and close the stream:

```javascript
const reader = response.body.getReader();

try {
  const { value } = await reader.read();
  // Process first chunk...
  
  if (someCondition) {
    await reader.cancel('User cancelled');
    return;
  }
} finally {
  reader.releaseLock();
}
```

### Releasing the Lock

The `releaseLock()` method releases the reader's exclusive lock on the stream, allowing other code to obtain a new reader:

```javascript
reader.releaseLock();
// Stream is now unlocked
const newReader = response.body.getReader();
```

[Inference] After releasing the lock, the original reader becomes unusable and attempting to read from it will throw an error.

### Teeing Streams

The `tee()` method splits a readable stream into two independent streams that can be consumed separately:

```javascript
const response = await fetch('https://example.com/data');
const [stream1, stream2] = response.body.tee();

// Consume both streams independently
const reader1 = stream1.getReader();
const reader2 = stream2.getReader();

// Both readers receive the same data
```

### Piping Streams

Transform or redirect streams using `pipeThrough()` and `pipeTo()`:

```javascript
const response = await fetch('https://example.com/data');

// Pipe through a transform stream
const decompressed = response.body.pipeThrough(
  new DecompressionStream('gzip')
);

// Pipe to a writable stream
const writable = new WritableStream({
  write(chunk) {
    console.log('Received:', chunk);
  }
});

await decompressed.pipeTo(writable);
```

### Progress Tracking

Monitor download progress by accumulating chunk sizes:

```javascript
const response = await fetch('https://example.com/file');
const contentLength = response.headers.get('Content-Length');
const total = parseInt(contentLength, 10);
let loaded = 0;

const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  loaded += value.length;
  const progress = (loaded / total) * 100;
  console.log(`Progress: ${progress.toFixed(2)}%`);
}
```

[Inference] This approach requires the server to send a `Content-Length` header; without it, total size cannot be determined in advance.

### Accumulating Chunks

Collect all chunks into a single buffer:

```javascript
const response = await fetch('https://example.com/data');
const reader = response.body.getReader();
const chunks = [];

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  chunks.push(value);
}

// Combine chunks
const totalLength = chunks.reduce((acc, chunk) => acc + chunk.length, 0);
const combined = new Uint8Array(totalLength);
let offset = 0;

for (const chunk of chunks) {
  combined.set(chunk, offset);
  offset += chunk.length;
}
```

### Response Body Convenience Methods

While streaming provides granular control, convenience methods consume the entire body:

```javascript
// These internally consume the ReadableStream
const text = await response.text();
const json = await response.json();
const blob = await response.blob();
const buffer = await response.arrayBuffer();
const formData = await response.formData();
```

[Inference] Using convenience methods after obtaining a reader, or vice versa, will fail because the stream becomes locked or already consumed.

### Streaming JSON Parsing

Parse JSON incrementally for large responses:

```javascript
const response = await fetch('https://example.com/large.json');
const reader = response.body.getReader();
const decoder = new TextDecoder();
let buffer = '';

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  buffer += decoder.decode(value, { stream: true });
  
  // Attempt to parse complete objects
  try {
    const data = JSON.parse(buffer);
    console.log('Parsed:', data);
    buffer = ''; // Clear buffer after successful parse
  } catch (e) {
    // Not yet complete, continue accumulating
  }
}
```

[Inference] This basic approach assumes the JSON fits in memory; for truly large streaming JSON, specialized libraries that parse incomplete JSON structures would be needed.

### Creating Custom Response Streams

Generate custom `Response` objects with streaming bodies:

```javascript
const stream = new ReadableStream({
  start(controller) {
    controller.enqueue(new TextEncoder().encode('chunk 1\n'));
    controller.enqueue(new TextEncoder().encode('chunk 2\n'));
    controller.close();
  }
});

const response = new Response(stream, {
  headers: { 'Content-Type': 'text/plain' }
});

const text = await response.text();
// 'chunk 1\nchunk 2\n'
```

### Async Iterator Support

Modern environments support async iteration over readable streams:

```javascript
const response = await fetch('https://example.com/data');

for await (const chunk of response.body) {
  // chunk is a Uint8Array
  console.log('Chunk size:', chunk.length);
}
```

[Inference] This simplifies streaming code by avoiding manual reader management and the while-loop pattern.

### Transform Streams

Apply transformations to streaming data:

```javascript
const transformStream = new TransformStream({
  transform(chunk, controller) {
    // Modify chunk
    const modified = chunk.map(byte => byte ^ 0xFF); // Invert bits
    controller.enqueue(modified);
  }
});

const response = await fetch('https://example.com/data');
const transformed = response.body.pipeThrough(transformStream);
const reader = transformed.getReader();
```

### Error Handling

Handle stream errors appropriately:

```javascript
const reader = response.body.getReader();

try {
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    // Process chunk
    processChunk(value);
  }
} catch (error) {
  console.error('Stream error:', error);
  await reader.cancel(); // Clean up
} finally {
  reader.releaseLock();
}
```

### Server-Sent Events Pattern

Parse SSE-style streams:

```javascript
const response = await fetch('https://example.com/events');
const reader = response.body.getReader();
const decoder = new TextDecoder();
let buffer = '';

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  buffer += decoder.decode(value, { stream: true });
  const lines = buffer.split('\n');
  buffer = lines.pop(); // Keep incomplete line
  
  for (const line of lines) {
    if (line.startsWith('data: ')) {
      const data = line.slice(6);
      console.log('Event:', data);
    }
  }
}
```

### Memory Efficiency

Streaming enables processing large files without loading them entirely into memory:

```javascript
// Bad: Loads entire file into memory
const response = await fetch('https://example.com/10GB-file');
const blob = await response.blob(); // Memory spike

// Good: Processes in chunks
const response = await fetch('https://example.com/10GB-file');
const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  // Process small chunk, then garbage collected
  await processChunk(value);
}
```

### Backpressure Handling

[Inference] The browser's implementation of `ReadableStream` handles backpressure automatically—if the consumer processes chunks slowly, the browser will naturally slow the rate at which it reads from the network connection, though this behavior is managed internally and not directly controllable by JavaScript code.

### Browser Compatibility

Response body streaming is widely supported in modern browsers. The `ReadableStream` API and `response.body` are available in Chrome 43+, Firefox 65+, Safari 10.1+, and Edge 14+.

[Inference] Async iteration over streams (`for await...of`) requires newer browser versions or polyfills, as it depends on the async iteration protocol support.

### Comparison with XMLHttpRequest Progress

While `XMLHttpRequest` offers progress events, it requires waiting for complete chunks:

```javascript
// XHR approach
const xhr = new XMLHttpRequest();
xhr.onprogress = (e) => {
  console.log(`Downloaded ${e.loaded} of ${e.total} bytes`);
};

// Fetch streaming approach
const response = await fetch(url);
const reader = response.body.getReader();
// More granular, chunk-level control
```

The Fetch API's streaming provides lower-level access to data as it arrives, enabling more sophisticated processing patterns.

---

