## Transform Streams 


### Core Concepts

Transform streams provide a mechanism to modify data as it flows through a stream pipeline. In the context of the Fetch API, they enable processing response bodies progressively without loading entire payloads into memory. A TransformStream consists of a readable side and a writable side, with transformation logic applied to chunks passing through.

### TransformStream Constructor

```javascript
const transformStream = new TransformStream({
  start(controller) {
    // Called when stream is constructed
  },
  
  transform(chunk, controller) {
    // Called for each chunk
    controller.enqueue(modifiedChunk);
  },
  
  flush(controller) {
    // Called when no more chunks will be written
  }
}, writableStrategy, readableStrategy);
```

#### Controller Methods

The `controller` parameter provides methods to manipulate the stream:

- `controller.enqueue(chunk)` - Adds a chunk to the readable side
- `controller.terminate()` - Closes both sides of the stream
- `controller.error(reason)` - Errors both sides of the stream
- `controller.desiredSize` - Returns the desired size to fill the queue

### Piping with Response Streams

#### Basic Pipeline

```javascript
const response = await fetch('https://api.example.com/data');

const transformStream = new TransformStream({
  transform(chunk, controller) {
    // Process chunk
    controller.enqueue(chunk);
  }
});

const transformedResponse = new Response(
  response.body.pipeThrough(transformStream)
);
```

#### Multiple Transformations

```javascript
const response = await fetch('https://api.example.com/data');

const decompressor = new DecompressionStream('gzip');
const decoder = new TextDecoderStream();
const customTransform = new TransformStream({
  transform(chunk, controller) {
    const modified = chunk.toUpperCase();
    controller.enqueue(modified);
  }
});

const stream = response.body
  .pipeThrough(decompressor)
  .pipeThrough(decoder)
  .pipeThrough(customTransform);

const reader = stream.getReader();
```

### Common Transformation Patterns

#### Text Processing

```javascript
const textTransformer = new TransformStream({
  transform(chunk, controller) {
    // chunk is Uint8Array
    const text = new TextDecoder().decode(chunk, { stream: true });
    const processed = text.replace(/old/g, 'new');
    controller.enqueue(new TextEncoder().encode(processed));
  }
});

fetch('https://api.example.com/text')
  .then(response => response.body.pipeThrough(textTransformer))
  .then(stream => new Response(stream).text())
  .then(result => console.log(result));
```

#### JSON Streaming

```javascript
class JSONLineParser extends TransformStream {
  constructor() {
    let buffer = '';
    
    super({
      transform(chunk, controller) {
        buffer += new TextDecoder().decode(chunk, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';
        
        for (const line of lines) {
          if (line.trim()) {
            try {
              const obj = JSON.parse(line);
              controller.enqueue(obj);
            } catch (e) {
              controller.error(e);
            }
          }
        }
      },
      
      flush(controller) {
        if (buffer.trim()) {
          try {
            const obj = JSON.parse(buffer);
            controller.enqueue(obj);
          } catch (e) {
            controller.error(e);
          }
        }
      }
    });
  }
}

const response = await fetch('https://api.example.com/ndjson');
const stream = response.body
  .pipeThrough(new TextDecoderStream())
  .pipeThrough(new JSONLineParser());

const reader = stream.getReader();
while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  console.log(value); // Parsed JSON object
}
```

#### Compression/Decompression

```javascript
// Decompression
const response = await fetch('https://api.example.com/compressed');
const decompressed = response.body.pipeThrough(
  new DecompressionStream('gzip')
);

// Compression
const text = 'Large text content...';
const stream = new Blob([text]).stream();
const compressed = stream.pipeThrough(
  new CompressionStream('gzip')
);

await fetch('https://api.example.com/upload', {
  method: 'POST',
  body: compressed,
  headers: {
    'Content-Encoding': 'gzip'
  }
});
```

#### Progress Tracking

```javascript
let bytesReceived = 0;

const progressTransform = new TransformStream({
  transform(chunk, controller) {
    bytesReceived += chunk.byteLength;
    console.log(`Received: ${bytesReceived} bytes`);
    controller.enqueue(chunk);
  }
});

const response = await fetch('https://api.example.com/large-file');
const contentLength = response.headers.get('Content-Length');

const stream = response.body.pipeThrough(progressTransform);
const blob = await new Response(stream).blob();
```

#### Chunked Data Aggregation

```javascript
class ChunkAggregator extends TransformStream {
  constructor(chunkSize) {
    let buffer = new Uint8Array(0);
    
    super({
      transform(chunk, controller) {
        const newBuffer = new Uint8Array(buffer.length + chunk.length);
        newBuffer.set(buffer);
        newBuffer.set(chunk, buffer.length);
        buffer = newBuffer;
        
        while (buffer.length >= chunkSize) {
          controller.enqueue(buffer.slice(0, chunkSize));
          buffer = buffer.slice(chunkSize);
        }
      },
      
      flush(controller) {
        if (buffer.length > 0) {
          controller.enqueue(buffer);
        }
      }
    });
  }
}

const response = await fetch('https://api.example.com/data');
const aggregated = response.body.pipeThrough(new ChunkAggregator(1024));
```

### Backpressure Management

Transform streams automatically handle backpressure through queuing strategies:

```javascript
const transform = new TransformStream(
  {
    transform(chunk, controller) {
      // Slow operation
      const processed = expensiveOperation(chunk);
      controller.enqueue(processed);
    }
  },
  { highWaterMark: 1 },  // Writable strategy
  { highWaterMark: 1 }   // Readable strategy
);
```

#### Custom Queuing Strategy

```javascript
class ByteLengthQueuingStrategy {
  constructor(options) {
    this.highWaterMark = options.highWaterMark;
  }
  
  size(chunk) {
    return chunk.byteLength;
  }
}

const transform = new TransformStream(
  { /* transformer */ },
  new ByteLengthQueuingStrategy({ highWaterMark: 1024 * 1024 }), // 1MB
  new ByteLengthQueuingStrategy({ highWaterMark: 1024 * 1024 })
);
```

### Error Handling

#### Transformation Errors

```javascript
const errorHandlingTransform = new TransformStream({
  transform(chunk, controller) {
    try {
      const result = riskyOperation(chunk);
      controller.enqueue(result);
    } catch (error) {
      controller.error(new Error(`Transform failed: ${error.message}`));
    }
  }
});

try {
  const response = await fetch('https://api.example.com/data');
  const stream = response.body.pipeThrough(errorHandlingTransform);
  const reader = stream.getReader();
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    console.log(value);
  }
} catch (error) {
  console.error('Stream error:', error);
}
```

#### Stream Abortion

```javascript
const controller = new AbortController();

const transform = new TransformStream({
  transform(chunk, controller) {
    if (controller.signal.aborted) {
      controller.error(new DOMException('Aborted', 'AbortError'));
      return;
    }
    controller.enqueue(chunk);
  }
});

fetch('https://api.example.com/data', { signal: controller.signal })
  .then(response => response.body.pipeThrough(transform))
  .catch(error => {
    if (error.name === 'AbortError') {
      console.log('Stream aborted');
    }
  });

// Abort after 5 seconds
setTimeout(() => controller.abort(), 5000);
```

### Tee Operations with Transforms

```javascript
const response = await fetch('https://api.example.com/data');
const [stream1, stream2] = response.body.tee();

// Apply different transforms to each stream
const upperCaseTransform = new TransformStream({
  transform(chunk, controller) {
    const text = new TextDecoder().decode(chunk);
    controller.enqueue(new TextEncoder().encode(text.toUpperCase()));
  }
});

const lowerCaseTransform = new TransformStream({
  transform(chunk, controller) {
    const text = new TextDecoder().decode(chunk);
    controller.enqueue(new TextEncoder().encode(text.toLowerCase()));
  }
});

const upper = stream1.pipeThrough(upperCaseTransform);
const lower = stream2.pipeThrough(lowerCaseTransform);

// Process both streams independently
const [upperResult, lowerResult] = await Promise.all([
  new Response(upper).text(),
  new Response(lower).text()
]);
```

### Identity Transforms

An identity transform passes data through unchanged but can be useful for monitoring:

```javascript
const identityTransform = new TransformStream({
  transform(chunk, controller) {
    console.log('Chunk size:', chunk.byteLength);
    controller.enqueue(chunk);
  }
});

const response = await fetch('https://api.example.com/data');
const monitored = response.body.pipeThrough(identityTransform);
```

### Writable Stream Destination

Transform streams can pipe to writable destinations:

```javascript
const response = await fetch('https://api.example.com/data');

const transform = new TransformStream({
  transform(chunk, controller) {
    // Process chunk
    controller.enqueue(chunk);
  }
});

const writableStream = new WritableStream({
  write(chunk) {
    console.log('Writing chunk:', chunk);
  },
  close() {
    console.log('Stream closed');
  }
});

await response.body
  .pipeThrough(transform)
  .pipeTo(writableStream);
```

### Performance Considerations

#### Memory Efficiency

Transform streams process data incrementally, avoiding memory spikes:

```javascript
// Memory-efficient large file processing
const response = await fetch('https://api.example.com/large-file');

const hashTransform = new TransformStream({
  async transform(chunk, controller) {
    // Process chunk without accumulating
    await processChunk(chunk);
    controller.enqueue(chunk);
  }
});

await response.body
  .pipeThrough(hashTransform)
  .pipeTo(someDestination);
```

#### Buffering Strategy

```javascript
class BufferedTransform extends TransformStream {
  constructor(bufferSize) {
    let buffer = [];
    
    super({
      transform(chunk, controller) {
        buffer.push(chunk);
        
        if (buffer.length >= bufferSize) {
          const combined = concatenateChunks(buffer);
          controller.enqueue(combined);
          buffer = [];
        }
      },
      
      flush(controller) {
        if (buffer.length > 0) {
          const combined = concatenateChunks(buffer);
          controller.enqueue(combined);
        }
      }
    });
  }
}
```

### Browser Compatibility

[Inference] Transform streams are part of the Streams API specification. Modern browsers implement this functionality, but specific features like CompressionStream may have varying support levels across different browser versions and environments.

---

