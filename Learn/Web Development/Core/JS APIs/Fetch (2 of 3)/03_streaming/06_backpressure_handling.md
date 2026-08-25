## Backpressure Handling 


### Understanding Backpressure in Streams

Backpressure occurs when data is being produced faster than it can be consumed. In the context of the Fetch API, this typically happens when:

- A server sends response data faster than the client can process it
- A client attempts to send request data faster than the network can transmit it
- Memory buffers fill up because the consuming side cannot keep pace with the producing side

The Streams API, which underlies fetch's request and response bodies, provides built-in backpressure mechanisms through the ReadableStream and WritableStream interfaces.

### ReadableStream Backpressure Mechanics

#### Internal Queue and High Water Mark

ReadableStreams maintain an internal queue with a configurable high water mark (HWM). The HWM determines when backpressure signals should be sent:

```javascript
const stream = new ReadableStream({
  start(controller) {},
  pull(controller) {
    // Called when internal queue drops below HWM
  },
  cancel(reason) {}
}, {
  highWaterMark: 1, // Number of chunks
  size(chunk) {
    return 1; // Or return actual byte size
  }
});
```

When the internal queue size exceeds the HWM, the stream signals backpressure by not calling `pull()` until space is available.

#### Automatic Backpressure with getReader()

When consuming a response body with a reader, backpressure is handled automatically:

```javascript
const response = await fetch('https://example.com/large-file');
const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  // Process chunk - backpressure automatically applied
  await processChunk(value);
  
  // Stream won't read next chunk until this completes
}
```

The key mechanism: the stream will not enqueue new chunks while `reader.read()` is pending. This creates natural backpressure since the consuming code controls when the next chunk is requested.

### pipeTo() and Backpressure Propagation

The `pipeTo()` method automatically handles backpressure between readable and writable streams:

```javascript
const response = await fetch('https://example.com/large-file');

// Backpressure flows from writable back to readable
await response.body.pipeTo(writableStream);
```

#### Backpressure Flow in pipeTo()

1. WritableStream's internal queue fills up
2. WritableStream signals it's not ready for more data
3. pipeTo() stops pulling from ReadableStream
4. ReadableStream's internal queue stops filling
5. Fetch stops reading from network until ReadableStream has capacity

This creates an automatic backpressure chain from the final consumer all the way back to the network layer.

### TransformStream and Backpressure

TransformStreams sit between readable and writable streams, and must handle backpressure in both directions:

```javascript
const transformStream = new TransformStream({
  async transform(chunk, controller) {
    // Backpressure from downstream affects enqueue()
    controller.enqueue(processedChunk);
    
    // If downstream is full, this may pause
  },
  
  flush(controller) {
    // Called when upstream closes
  }
}, 
{
  highWaterMark: 1,  // Readable side
  size: (chunk) => 1
},
{
  highWaterMark: 1,  // Writable side  
  size: (chunk) => 1
});

await response.body
  .pipeThrough(transformStream)
  .pipeTo(destination);
```

The `transform()` function won't be called again until:

- The previous `transform()` call completes
- The downstream writable stream has capacity

### Manual Backpressure Control

#### Using desiredSize

The `controller.desiredSize` property indicates how much capacity remains:

```javascript
const stream = new ReadableStream({
  async pull(controller) {
    // Check available capacity
    console.log('Desired size:', controller.desiredSize);
    
    if (controller.desiredSize > 0) {
      const chunk = await getNextChunk();
      controller.enqueue(chunk);
    }
    // If desiredSize <= 0, backpressure is signaled
  }
}, {
  highWaterMark: 5,
  size: (chunk) => chunk.byteLength
});
```

When `desiredSize` becomes zero or negative, the stream is experiencing backpressure and `pull()` won't be called until space frees up.

#### Implementing Rate Limiting

```javascript
class RateLimitedStream {
  constructor(sourceStream, bytesPerSecond) {
    this.source = sourceStream.getReader();
    this.rate = bytesPerSecond;
    this.lastChunkTime = Date.now();
    
    return new ReadableStream({
      pull: async (controller) => {
        const { done, value } = await this.source.read();
        
        if (done) {
          controller.close();
          return;
        }
        
        // Calculate required delay for rate limiting
        const now = Date.now();
        const elapsed = now - this.lastChunkTime;
        const requiredTime = (value.byteLength / this.rate) * 1000;
        const delay = Math.max(0, requiredTime - elapsed);
        
        if (delay > 0) {
          await new Promise(resolve => setTimeout(resolve, delay));
        }
        
        this.lastChunkTime = Date.now();
        controller.enqueue(value);
      }
    });
  }
}
```

### Request Body Backpressure

When uploading data with fetch, backpressure flows from the network back to your readable stream:

```javascript
const uploadStream = new ReadableStream({
  async pull(controller) {
    const chunk = await generateChunk();
    controller.enqueue(chunk);
    
    // Network backpressure automatically prevents
    // this from being called too frequently
  }
});

await fetch('https://example.com/upload', {
  method: 'POST',
  body: uploadStream,
  duplex: 'half' // Required for streaming request bodies
});
```

[Inference] The browser's fetch implementation manages the rate at which `pull()` is called based on network conditions and TCP flow control.

### Memory Management Through Backpressure

#### Preventing Memory Exhaustion

Without proper backpressure handling, a fast producer can exhaust memory:

```javascript
// BAD: No backpressure - stores all chunks in memory
const chunks = [];
const reader = response.body.getReader();
while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  chunks.push(value); // Accumulates in memory
}

// GOOD: Processes chunks immediately with automatic backpressure
const reader = response.body.getReader();
while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  await processAndDiscard(value); // Chunk can be garbage collected
}
```

#### Streaming to Disk with Backpressure

Using the File System Access API (where supported):

```javascript
const fileHandle = await window.showSaveFilePicker();
const writable = await fileHandle.createWritable();

// Backpressure automatically managed
await response.body.pipeTo(writable);

// File writes control fetch read speed
```

### Handling Slow Consumers

#### Aborting Slow Requests

```javascript
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 30000);

try {
  const response = await fetch(url, {
    signal: controller.signal
  });
  
  const reader = response.body.getReader();
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    // If processing takes too long, the entire operation aborts
    await slowProcessing(value);
  }
  
  clearTimeout(timeoutId);
} catch (err) {
  if (err.name === 'AbortError') {
    console.log('Aborted due to slow processing');
  }
}
```

#### Buffering Strategy

When you need to decouple producer and consumer speeds:

```javascript
class BufferedTransform extends TransformStream {
  constructor(maxBufferSize) {
    const buffer = [];
    let bufferSize = 0;
    
    super({
      async transform(chunk, controller) {
        buffer.push(chunk);
        bufferSize += chunk.byteLength;
        
        // Drain buffer when it reaches threshold
        if (bufferSize >= maxBufferSize) {
          while (buffer.length > 0) {
            controller.enqueue(buffer.shift());
          }
          bufferSize = 0;
        }
      },
      
      flush(controller) {
        // Flush remaining buffer
        buffer.forEach(chunk => controller.enqueue(chunk));
      }
    });
  }
}
```

[Inference] This pattern allows temporary speed mismatches but still applies backpressure once the buffer fills, preventing unbounded memory growth.

### tee() and Backpressure

The `tee()` method creates two independent branches, each with their own backpressure:

```javascript
const response = await fetch(url);
const [stream1, stream2] = response.body.tee();

// Both branches must consume for data to flow
const branch1 = stream1.pipeTo(destination1);
const branch2 = stream2.pipeTo(destination2);

await Promise.all([branch1, branch2]);
```

[Inference] The original stream's backpressure is determined by the slowest consumer. If one branch is slower, it gates the entire operation because chunks must be held in memory for the slower branch.

### Backpressure with Byte Streams

When using byte-oriented streams (BYOB readers), backpressure works at the buffer level:

```javascript
const response = await fetch(url);
const reader = response.body.getReader({ mode: 'byob' });

const buffer = new ArrayBuffer(1024);
let offset = 0;

while (offset < buffer.byteLength) {
  const { done, value } = await reader.read(
    new Uint8Array(buffer, offset, buffer.byteLength - offset)
  );
  
  if (done) break;
  offset += value.byteLength;
  
  // Backpressure: next read won't start until this completes
}
```

The consumer controls exactly how much data to request and when, providing fine-grained backpressure control.

### Cross-Origin and Backpressure

[Inference] Cross-origin requests may have different backpressure characteristics due to:

- CORS preflight requests delaying stream start
- Opaque responses limiting control over streaming
- Service Worker interception affecting flow control

```javascript
const response = await fetch('https://different-origin.com/data', {
  mode: 'cors'
});

// Backpressure still works, but timing may differ
await response.body.pipeTo(destination);
```

### Debugging Backpressure Issues

#### Monitoring Stream State

```javascript
const stream = new ReadableStream({
  pull(controller) {
    console.log({
      desiredSize: controller.desiredSize,
      timestamp: Date.now()
    });
    
    // Large negative values indicate severe backpressure
    if (controller.desiredSize < -10) {
      console.warn('Severe backpressure detected');
    }
  }
}, {
  highWaterMark: 5,
  size: (chunk) => chunk.byteLength
});
```

#### Measuring Pipeline Throughput

```javascript
class ThroughputMonitor extends TransformStream {
  constructor() {
    let bytesProcessed = 0;
    let startTime = Date.now();
    
    super({
      transform(chunk, controller) {
        bytesProcessed += chunk.byteLength;
        const elapsed = (Date.now() - startTime) / 1000;
        const mbps = (bytesProcessed / elapsed / 1024 / 1024).toFixed(2);
        
        console.log(`Throughput: ${mbps} MB/s`);
        controller.enqueue(chunk);
      }
    });
  }
}

await response.body
  .pipeThrough(new ThroughputMonitor())
  .pipeTo(destination);
```

### Implementation Considerations

#### Browser Differences

[Unverified] Different browsers may implement backpressure buffering with different default high water marks and queue management strategies. Testing across browsers is important for performance-critical applications.

#### Service Workers and Backpressure

When streaming through a Service Worker:

```javascript
// In service worker
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request).then(response => {
      // Backpressure flows through service worker
      return new Response(response.body, {
        headers: response.headers
      });
    })
  );
});
```

The Service Worker acts as a transparent pipe, preserving backpressure signals between the network and the client.

#### Compression and Backpressure

Compression streams affect backpressure because the compressed/decompressed size differs:

```javascript
const decompressed = response.body
  .pipeThrough(new DecompressionStream('gzip'));

// Backpressure based on decompressed data size
await decompressed.pipeTo(destination);
```

The backpressure signal travels through the decompression layer, but the rate limiting occurs on the decompressed data flow.

---

