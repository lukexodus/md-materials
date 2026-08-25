## ReadableStream API


ReadableStream is a Web Streams API interface representing a readable stream of byte data. It provides a standardized way to handle streaming data in JavaScript, enabling efficient processing of large datasets without loading everything into memory at once.

### Core Concepts

#### Stream States

A ReadableStream exists in one of three states:

- **Readable**: The stream is active and can produce chunks
- **Closed**: The stream has successfully completed and will produce no more chunks
- **Errored**: The stream has encountered an error and is now permanently unusable

#### Stream Types

ReadableStreams come in two fundamental types:

**Byte streams** handle raw binary data with a `ReadableStreamBYOBReader` (Bring Your Own Buffer), allowing consumers to provide their own buffers for more efficient memory usage.

**Default streams** handle chunks of any type, typically using a `ReadableStreamDefaultReader`.

### Constructor

```javascript
new ReadableStream(underlyingSource, queuingStrategy)
```

#### underlyingSource Object

The underlying source defines how the stream obtains its data:

**start(controller)**: Called immediately when the stream is constructed. Use this to set up data sources or perform initialization. Returns a promise if asynchronous work is needed.

**pull(controller)**: Called when the stream's internal queue isn't full. This is where you enqueue new chunks. Should return a promise. The stream won't call `pull()` again until the returned promise fulfills.

**cancel(reason)**: Called when the consumer cancels the stream. Use this to release resources or abort ongoing operations.

**type**: Set to `"bytes"` for byte streams, or omit for default streams.

**autoAllocateChunkSize**: For byte streams only. When set, the stream will automatically allocate buffers of this size for BYOB reads.

#### queuingStrategy Object

Controls buffering behavior:

**highWaterMark**: The maximum number of chunks (or total size) to buffer before backpressure is applied. Default is 1 for default streams.

**size(chunk)**: A function that returns the size of each chunk. Used with `highWaterMark` to determine when the queue is full.

### ReadableStreamDefaultController

The controller object passed to underlying source methods provides control over the stream:

**enqueue(chunk)**: Adds a chunk to the stream's queue. Throws if the stream is not readable or if the queue is full beyond the high water mark.

**close()**: Signals that no more chunks will be enqueued. The stream will close once all queued chunks are read.

**error(error)**: Causes the stream to error with the given reason. All future interactions will fail with this error.

**desiredSize**: Returns the desired size to fill the stream's queue. Positive when more data is needed, zero or negative when the queue is full or overfull. Becomes `null` when the stream is closed or errored.

### ReadableStreamBYOBController

For byte streams, the controller has similar methods but with byte-specific handling:

**enqueue(chunk)**: The chunk must be an ArrayBufferView (typed array).

**byobRequest**: Returns a `ReadableStreamBYOBRequest` or null. When a BYOB reader is waiting for data, this property provides a view into the consumer's buffer where you can write data directly.

```javascript
if (controller.byobRequest) {
  const view = controller.byobRequest.view;
  // Write data directly into view
  controller.byobRequest.respond(bytesWritten);
}
```

### Reading Streams

#### Default Reader

```javascript
const reader = stream.getReader();
```

**read()**: Returns a promise that resolves to `{value: chunk, done: false}` when a chunk is available, or `{value: undefined, done: true}` when the stream closes.

**releaseLock()**: Releases the reader's lock on the stream, allowing other readers to be obtained.

**closed**: A promise that fulfills when the stream closes or rejects when it errors.

**cancel(reason)**: Cancels the stream and releases the lock.

#### BYOB Reader

```javascript
const reader = stream.getReader({ mode: 'byob' });
```

**read(view)**: Similar to the default reader's `read()`, but accepts an ArrayBufferView. The stream will fill this buffer with data. The returned promise resolves with a new view into the same buffer, indicating how much was filled.

```javascript
const buffer = new ArrayBuffer(1024);
const view = new Uint8Array(buffer);
const { value, done } = await reader.read(view);
// value is a new Uint8Array view, potentially shorter than view
```

### Locking Mechanism

A stream can only have one active reader at a time. Attempting to get a second reader while one is active throws a TypeError. This prevents multiple consumers from receiving chunks in an undefined order.

To switch readers, call `releaseLock()` on the current reader first.

### Piping and Transformation

#### pipeTo()

```javascript
readableStream.pipeTo(writableStream, options)
```

Pipes the readable stream to a writable stream, handling backpressure automatically. Returns a promise that fulfills when piping completes successfully.

**Options**:

- **preventClose**: If true, doesn't close the destination when the source closes
- **preventAbort**: If true, doesn't abort the destination if the source errors
- **preventCancel**: If true, doesn't cancel the source if the destination errors
- **signal**: An AbortSignal to abort the piping operation

#### pipeThrough()

```javascript
readableStream.pipeThrough(transformStream, options)
```

Pipes through a transform stream (which has both readable and writable sides), returning the readable side. This allows chaining transformations.

```javascript
const transformed = stream
  .pipeThrough(new TextDecoderStream())
  .pipeThrough(new TransformStream({
    transform(chunk, controller) {
      controller.enqueue(chunk.toUpperCase());
    }
  }));
```

#### tee()

```javascript
const [branch1, branch2] = stream.tee();
```

Splits the stream into two branches that receive the same chunks. Useful when you need to consume the same data in multiple ways. Both branches must be consumed for the original stream to make progress.

### Backpressure

Backpressure is the mechanism that prevents a fast producer from overwhelming a slow consumer:

1. The `desiredSize` property indicates how much more data is desired
2. When `desiredSize` becomes zero or negative, the queue is full
3. The `pull()` method won't be called again until space becomes available
4. Readers waiting for data will only trigger `pull()` when they're ready to consume

This creates a natural flow control where production slows when consumption slows.

### Async Iteration

ReadableStreams are async iterables, allowing use with `for await...of`:

```javascript
for await (const chunk of stream) {
  // Process chunk
}
```

This automatically handles reading and releasing the lock when done or if an error occurs.

### Common Patterns

#### Creating from Data

```javascript
const stream = new ReadableStream({
  start(controller) {
    controller.enqueue('chunk 1');
    controller.enqueue('chunk 2');
    controller.close();
  }
});
```

#### Creating from Async Source

```javascript
const stream = new ReadableStream({
  async pull(controller) {
    const data = await fetchNextChunk();
    if (data) {
      controller.enqueue(data);
    } else {
      controller.close();
    }
  }
});
```

#### Manual Reading Loop

```javascript
const reader = stream.getReader();
try {
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    // Process value
  }
} finally {
  reader.releaseLock();
}
```

#### Handling Errors

```javascript
const stream = new ReadableStream({
  async pull(controller) {
    try {
      const data = await riskyOperation();
      controller.enqueue(data);
    } catch (error) {
      controller.error(error);
    }
  }
});
```

### Integration with Fetch API

The Response body in the Fetch API is a ReadableStream:

```javascript
const response = await fetch(url);
const reader = response.body.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  // value is a Uint8Array chunk
}
```

This enables processing large responses incrementally without waiting for the entire download.

### Performance Considerations

**Chunk size**: Larger chunks reduce overhead but increase latency. Balance based on your use case.

**Buffer allocation**: BYOB readers reduce garbage collection pressure by reusing buffers.

**Queue management**: Monitor `desiredSize` to avoid building up large queues that consume memory.

**Cancellation**: Always implement `cancel()` in underlying sources to properly release resources when streams are abandoned.

### Browser Support

[Inference] ReadableStream has broad modern browser support. The BYOB reader functionality may have more limited support in older browsers. Check compatibility requirements for your target environments.

---

