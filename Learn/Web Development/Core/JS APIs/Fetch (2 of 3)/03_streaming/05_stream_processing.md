## Stream Processing 


### Reading Response Streams

The Fetch API provides access to the underlying `ReadableStream` of the response body through `response.body`. This enables progressive processing of data as it arrives rather than waiting for the complete response.

```javascript
const response = await fetch('https://api.example.com/large-dataset');
const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  // value is a Uint8Array chunk
  processChunk(value);
}
```

### Stream Decoding with TextDecoderStream

Raw stream chunks are `Uint8Array` buffers. Use `TextDecoderStream` to convert bytes to text while handling multi-byte characters that may span chunk boundaries.

```javascript
const response = await fetch('https://api.example.com/stream');
const stream = response.body
  .pipeThrough(new TextDecoderStream())
  .getReader();

while (true) {
  const { done, value } = await stream.read();
  if (done) break;
  console.log(value); // Already decoded text
}
```

### Manual Reader Control

Direct reader access provides fine-grained control over stream consumption. Each `read()` returns a promise resolving to `{ done, value }`.

```javascript
const reader = response.body.getReader();

try {
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) {
      console.log('Stream complete');
      break;
    }
    
    // Process chunk
    await processChunk(value);
  }
} finally {
  reader.releaseLock();
}
```

### Stream Piping and Transformation

The Streams API allows chaining transformations using `pipeThrough()` and `pipeTo()`.

```javascript
const response = await fetch('https://api.example.com/data');

await response.body
  .pipeThrough(new TextDecoderStream())
  .pipeThrough(new TransformStream({
    transform(chunk, controller) {
      // Transform each chunk
      controller.enqueue(chunk.toUpperCase());
    }
  }))
  .pipeTo(new WritableStream({
    write(chunk) {
      console.log(chunk);
    }
  }));
```

### Custom TransformStream Implementation

Create reusable stream transformers for common processing patterns.

```javascript
class JSONLineParser extends TransformStream {
  constructor() {
    let buffer = '';
    
    super({
      transform(chunk, controller) {
        buffer += chunk;
        const lines = buffer.split('\n');
        buffer = lines.pop(); // Keep incomplete line
        
        for (const line of lines) {
          if (line.trim()) {
            try {
              controller.enqueue(JSON.parse(line));
            } catch (e) {
              console.error('Parse error:', e);
            }
          }
        }
      },
      
      flush(controller) {
        if (buffer.trim()) {
          try {
            controller.enqueue(JSON.parse(buffer));
          } catch (e) {
            console.error('Final parse error:', e);
          }
        }
      }
    });
  }
}

// Usage
const response = await fetch('https://api.example.com/ndjson');
const reader = response.body
  .pipeThrough(new TextDecoderStream())
  .pipeThrough(new JSONLineParser())
  .getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  console.log(value); // Parsed JSON objects
}
```

### Server-Sent Events (SSE) Processing

Parse SSE format streams manually for event-driven data consumption.

```javascript
async function consumeSSE(url) {
  const response = await fetch(url);
  const reader = response.body
    .pipeThrough(new TextDecoderStream())
    .getReader();
  
  let buffer = '';
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    buffer += value;
    const lines = buffer.split('\n\n');
    buffer = lines.pop();
    
    for (const eventText of lines) {
      const event = parseSSEEvent(eventText);
      if (event.data) {
        handleEvent(event);
      }
    }
  }
}

function parseSSEEvent(text) {
  const lines = text.split('\n');
  const event = { data: '', event: 'message' };
  
  for (const line of lines) {
    if (line.startsWith('data: ')) {
      event.data += line.slice(6) + '\n';
    } else if (line.startsWith('event: ')) {
      event.event = line.slice(7);
    } else if (line.startsWith('id: ')) {
      event.id = line.slice(4);
    }
  }
  
  event.data = event.data.trim();
  return event;
}
```

### Streaming JSON Parsing

Process large JSON arrays incrementally without loading the entire response into memory.

```javascript
class StreamingJSONParser extends TransformStream {
  constructor() {
    let depth = 0;
    let buffer = '';
    let inString = false;
    let escape = false;
    
    super({
      transform(chunk, controller) {
        for (let i = 0; i < chunk.length; i++) {
          const char = chunk[i];
          buffer += char;
          
          if (escape) {
            escape = false;
            continue;
          }
          
          if (char === '\\' && inString) {
            escape = true;
            continue;
          }
          
          if (char === '"') {
            inString = !inString;
            continue;
          }
          
          if (inString) continue;
          
          if (char === '{' || char === '[') {
            depth++;
          } else if (char === '}' || char === ']') {
            depth--;
            
            if (depth === 1 && char === '}') {
              try {
                controller.enqueue(JSON.parse(buffer));
                buffer = '';
              } catch (e) {
                // Incomplete object, continue buffering
              }
            }
          }
        }
      }
    });
  }
}
```

### Backpressure Handling

Streams automatically handle backpressure when the consumer processes data slower than it arrives.

```javascript
const response = await fetch('https://api.example.com/stream');
const reader = response.body.getReader();

async function processWithBackpressure() {
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    // Slow processing - backpressure automatically applied
    await simulateSlowProcessing(value);
  }
}

async function simulateSlowProcessing(chunk) {
  return new Promise(resolve => {
    setTimeout(() => {
      console.log(`Processed ${chunk.length} bytes`);
      resolve();
    }, 100);
  });
}
```

### Teeing Streams

Split a stream into multiple independent consumers using `tee()`.

```javascript
const response = await fetch('https://api.example.com/data');
const [stream1, stream2] = response.body.tee();

// Consumer 1: Save to cache
stream1
  .pipeThrough(new TextDecoderStream())
  .pipeTo(new WritableStream({
    write(chunk) {
      cache.append(chunk);
    }
  }));

// Consumer 2: Display to user
const reader = stream2
  .pipeThrough(new TextDecoderStream())
  .getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  displayToUser(value);
}
```

### Aborting Streams

Cancel stream processing using `AbortController`.

```javascript
const controller = new AbortController();
const signal = controller.signal;

setTimeout(() => controller.abort(), 5000); // Abort after 5s

try {
  const response = await fetch('https://api.example.com/stream', { signal });
  const reader = response.body.getReader();
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    processChunk(value);
  }
} catch (err) {
  if (err.name === 'AbortError') {
    console.log('Stream aborted');
  }
}
```

### Progress Tracking

Monitor download progress with `Content-Length` header and accumulated chunk sizes.

```javascript
const response = await fetch('https://api.example.com/large-file');
const contentLength = response.headers.get('Content-Length');
const total = parseInt(contentLength, 10);

let loaded = 0;
const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  
  if (done) {
    console.log('Download complete');
    break;
  }
  
  loaded += value.length;
  const progress = (loaded / total) * 100;
  console.log(`Progress: ${progress.toFixed(2)}%`);
}
```

### Streaming Upload with Request Body

Send data as a stream for efficient large file uploads.

```javascript
const stream = new ReadableStream({
  async start(controller) {
    for (let i = 0; i < 1000; i++) {
      const chunk = generateChunk(i);
      controller.enqueue(new TextEncoder().encode(chunk));
      await sleep(10);
    }
    controller.close();
  }
});

const response = await fetch('https://api.example.com/upload', {
  method: 'POST',
  body: stream,
  headers: {
    'Content-Type': 'application/octet-stream'
  },
  duplex: 'half' // Required for streaming requests
});
```

### Compressed Stream Decompression

Decompress gzip/deflate streams using `DecompressionStream`.

```javascript
const response = await fetch('https://api.example.com/compressed');

const decompressed = response.body
  .pipeThrough(new DecompressionStream('gzip'))
  .pipeThrough(new TextDecoderStream());

const reader = decompressed.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  console.log(value); // Decompressed text
}
```

### Error Handling in Streams

Properly handle errors at each stage of stream processing.

```javascript
const response = await fetch('https://api.example.com/stream');

try {
  const reader = response.body
    .pipeThrough(new TextDecoderStream())
    .pipeThrough(new TransformStream({
      transform(chunk, controller) {
        try {
          const processed = riskyOperation(chunk);
          controller.enqueue(processed);
        } catch (error) {
          controller.error(error);
        }
      }
    }))
    .getReader();
  
  while (true) {
    try {
      const { done, value } = await reader.read();
      if (done) break;
      await handleValue(value);
    } catch (error) {
      console.error('Stream processing error:', error);
      break;
    }
  }
} catch (error) {
  console.error('Stream setup error:', error);
} finally {
  // Cleanup
}
```

### Async Iterator Pattern

Convert streams to async iterables for more ergonomic consumption.

```javascript
async function* streamAsyncIterator(stream) {
  const reader = stream.getReader();
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) return;
      yield value;
    }
  } finally {
    reader.releaseLock();
  }
}

// Usage
const response = await fetch('https://api.example.com/stream');
const textStream = response.body.pipeThrough(new TextDecoderStream());

for await (const chunk of streamAsyncIterator(textStream)) {
  console.log(chunk);
}
```

### Chunked Transfer Encoding

Fetch automatically handles chunked transfer encoding, exposing a seamless stream interface regardless of the underlying HTTP transfer mechanism.

```javascript
// Server sends with Transfer-Encoding: chunked
const response = await fetch('https://api.example.com/chunked');

// Client receives as normal stream - chunking is transparent
const reader = response.body.getReader();
while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  // Chunks don't necessarily align with HTTP chunks
  processChunk(value);
}
```

### Memory-Efficient Large File Processing

Process files larger than available memory by streaming through transformations.

```javascript
async function processLargeCSV(url) {
  const response = await fetch(url);
  
  let lineBuffer = '';
  const reader = response.body
    .pipeThrough(new TextDecoderStream())
    .getReader();
  
  let lineCount = 0;
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) {
      if (lineBuffer) {
        processLine(lineBuffer);
        lineCount++;
      }
      break;
    }
    
    lineBuffer += value;
    const lines = lineBuffer.split('\n');
    lineBuffer = lines.pop(); // Keep incomplete line
    
    for (const line of lines) {
      processLine(line);
      lineCount++;
      
      if (lineCount % 1000 === 0) {
        await updateProgress(lineCount);
      }
    }
  }
  
  return lineCount;
}

function processLine(line) {
  const fields = line.split(',');
  // Process individual line without keeping all in memory
  saveToDatabase(fields);
}
```

### CompressionStream for Upload

Compress data before uploading to reduce bandwidth.

```javascript
const fileStream = file.stream();

const compressedStream = fileStream
  .pipeThrough(new CompressionStream('gzip'));

const response = await fetch('https://api.example.com/upload', {
  method: 'POST',
  body: compressedStream,
  headers: {
    'Content-Encoding': 'gzip',
    'Content-Type': 'application/octet-stream'
  },
  duplex: 'half'
});
```

### Stream Buffering Strategies

Control memory usage with custom buffering strategies using `queuingStrategy`.

```javascript
const stream = new ReadableStream({
  start(controller) {
    // Producer
  }
}, new CountQueuingStrategy({ highWaterMark: 10 }));

// Or bytes-based
const byteStream = new ReadableStream({
  type: 'bytes',
  start(controller) {
    // Producer
  }
}, new ByteLengthQueuingStrategy({ highWaterMark: 1024 * 64 })); // 64KB buffer
```

### Parallel Stream Processing

Process stream chunks in parallel while maintaining order.

```javascript
async function parallelStreamProcess(url, concurrency = 3) {
  const response = await fetch(url);
  const reader = response.body
    .pipeThrough(new TextDecoderStream())
    .getReader();
  
  const workers = [];
  let chunkId = 0;
  const results = new Map();
  let nextOutputId = 0;
  
  async function worker() {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      
      const id = chunkId++;
      const result = await processChunkAsync(value);
      results.set(id, result);
      
      // Output results in order
      while (results.has(nextOutputId)) {
        outputResult(results.get(nextOutputId));
        results.delete(nextOutputId);
        nextOutputId++;
      }
    }
  }
  
  // Start parallel workers
  for (let i = 0; i < concurrency; i++) {
    workers.push(worker());
  }
  
  await Promise.all(workers);
}
```

---

