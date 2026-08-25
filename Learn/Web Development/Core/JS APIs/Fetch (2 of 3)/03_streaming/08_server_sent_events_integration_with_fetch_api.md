## Server-Sent Events Integration with Fetch API


### Core Integration Pattern

The fetch API provides the foundation for establishing Server-Sent Events (SSE) connections. While the EventSource API is the traditional interface for SSE, fetch offers more control over request configuration, particularly for authentication, custom headers, and request body inclusion.

```javascript
const response = await fetch('/events', {
  headers: {
    'Accept': 'text/event-stream',
    'Authorization': 'Bearer token123'
  }
});

const reader = response.body.getReader();
const decoder = new TextDecoder();
```

### ReadableStream Processing

SSE responses arrive as a ReadableStream that must be manually processed. The stream delivers chunks of data that require parsing according to SSE protocol specifications.

```javascript
let buffer = '';

while (true) {
  const { done, value } = await reader.read();
  
  if (done) break;
  
  buffer += decoder.decode(value, { stream: true });
  
  const lines = buffer.split('\n');
  buffer = lines.pop(); // Keep incomplete line in buffer
  
  for (const line of lines) {
    processLine(line);
  }
}
```

### SSE Protocol Parsing

The SSE protocol uses specific field formats that must be parsed from the stream. Each event consists of multiple lines with field-value pairs.

**Field Types:**

- `event:` - Event type identifier
- `data:` - Message payload (can span multiple lines)
- `id:` - Event identifier for reconnection
- `retry:` - Reconnection time in milliseconds
- `:` - Comment line (ignored)

```javascript
let currentEvent = {
  event: 'message',
  data: '',
  id: '',
  retry: null
};

function processLine(line) {
  if (line === '') {
    // Empty line dispatches the event
    if (currentEvent.data) {
      dispatchEvent(currentEvent);
      currentEvent = { event: 'message', data: '', id: '', retry: null };
    }
    return;
  }
  
  if (line.startsWith(':')) return; // Comment
  
  const colonIndex = line.indexOf(':');
  const field = colonIndex !== -1 ? line.slice(0, colonIndex) : line;
  let value = colonIndex !== -1 ? line.slice(colonIndex + 1) : '';
  
  if (value.startsWith(' ')) value = value.slice(1);
  
  switch (field) {
    case 'event':
      currentEvent.event = value;
      break;
    case 'data':
      currentEvent.data += (currentEvent.data ? '\n' : '') + value;
      break;
    case 'id':
      if (!value.includes('\0')) currentEvent.id = value;
      break;
    case 'retry':
      const retryNum = parseInt(value, 10);
      if (!isNaN(retryNum)) currentEvent.retry = retryNum;
      break;
  }
}
```

### Event Dispatching

Custom event handling replaces the EventSource's built-in event system when using fetch.

```javascript
const eventTarget = new EventTarget();

function dispatchEvent(eventData) {
  const event = new MessageEvent(eventData.event, {
    data: eventData.data,
    lastEventId: eventData.id,
    origin: new URL('/events', location.href).origin
  });
  
  eventTarget.dispatchEvent(event);
}

// Usage
eventTarget.addEventListener('message', (e) => {
  console.log('Default message:', e.data);
});

eventTarget.addEventListener('customEvent', (e) => {
  console.log('Custom event:', e.data);
});
```

### Reconnection Logic

Fetch-based SSE requires manual implementation of reconnection logic that EventSource provides automatically.

```javascript
let lastEventId = '';
let reconnectDelay = 3000;
let shouldReconnect = true;

async function connect() {
  try {
    const response = await fetch('/events', {
      headers: {
        'Accept': 'text/event-stream',
        'Last-Event-ID': lastEventId
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    await processStream(response.body);
    
  } catch (error) {
    console.error('Connection error:', error);
    
    if (shouldReconnect) {
      setTimeout(connect, reconnectDelay);
    }
  }
}

function processLine(line) {
  // ... parsing logic ...
  
  if (field === 'id') {
    lastEventId = value;
  } else if (field === 'retry') {
    reconnectDelay = parseInt(value, 10);
  }
}
```

### AbortController Integration

Proper connection termination requires AbortController to cancel in-flight requests.

```javascript
let abortController = new AbortController();

async function connect() {
  abortController = new AbortController();
  
  try {
    const response = await fetch('/events', {
      signal: abortController.signal,
      headers: {
        'Accept': 'text/event-stream',
        'Last-Event-ID': lastEventId
      }
    });
    
    await processStream(response.body);
    
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Connection aborted');
      return;
    }
    // Handle other errors
  }
}

function disconnect() {
  shouldReconnect = false;
  abortController.abort();
}
```

### POST Requests with SSE

Unlike EventSource (which only supports GET), fetch enables POST requests with request bodies for SSE connections.

```javascript
const response = await fetch('/events', {
  method: 'POST',
  headers: {
    'Accept': 'text/event-stream',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    filter: 'updates',
    userId: '12345'
  })
});
```

### Error Handling and Connection States

Comprehensive error handling tracks connection lifecycle states.

```javascript
const ConnectionState = {
  CONNECTING: 0,
  OPEN: 1,
  CLOSED: 2
};

class FetchSSE {
  constructor(url, options = {}) {
    this.url = url;
    this.options = options;
    this.readyState = ConnectionState.CONNECTING;
    this.eventTarget = new EventTarget();
  }
  
  async connect() {
    this.readyState = ConnectionState.CONNECTING;
    
    try {
      const response = await fetch(this.url, {
        ...this.options,
        headers: {
          'Accept': 'text/event-stream',
          ...this.options.headers
        }
      });
      
      if (!response.ok) {
        this.dispatchError(new Error(`HTTP ${response.status}`));
        return;
      }
      
      if (!response.headers.get('content-type')?.includes('text/event-stream')) {
        this.dispatchError(new Error('Invalid content-type'));
        return;
      }
      
      this.readyState = ConnectionState.OPEN;
      this.dispatchOpen();
      
      await this.processStream(response.body);
      
    } catch (error) {
      this.dispatchError(error);
    } finally {
      this.readyState = ConnectionState.CLOSED;
    }
  }
  
  dispatchOpen() {
    this.eventTarget.dispatchEvent(new Event('open'));
  }
  
  dispatchError(error) {
    this.eventTarget.dispatchEvent(new ErrorEvent('error', { error }));
  }
}
```

### Backpressure Handling

The ReadableStream can apply backpressure if the consumer cannot process data fast enough.

```javascript
async function processStream(stream) {
  const reader = stream.getReader();
  
  try {
    while (true) {
      // This await naturally applies backpressure
      const { done, value } = await reader.read();
      
      if (done) break;
      
      // Slow processing creates backpressure
      await processChunk(value);
    }
  } finally {
    reader.releaseLock();
  }
}
```

### Credential Handling

Fetch provides explicit control over credential inclusion in cross-origin SSE requests.

```javascript
const response = await fetch('https://api.example.com/events', {
  credentials: 'include', // 'omit', 'same-origin', 'include'
  headers: {
    'Accept': 'text/event-stream'
  }
});
```

### CORS Considerations

Cross-origin SSE connections require proper CORS headers from the server.

**Required Server Headers:**

```
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Credentials: true
Access-Control-Allow-Headers: Last-Event-ID
Content-Type: text/event-stream
Cache-Control: no-cache
```

For preflight requests with custom headers:

```javascript
const response = await fetch('https://api.example.com/events', {
  headers: {
    'Accept': 'text/event-stream',
    'X-Custom-Header': 'value' // Triggers preflight
  }
});
```

### Chunked Transfer Encoding

SSE relies on chunked transfer encoding. The fetch API handles this transparently through the ReadableStream interface.

```javascript
// Server must send chunked responses
// fetch automatically handles Transfer-Encoding: chunked

const reader = response.body.getReader();
// Each read() returns a chunk as it arrives
```

### Buffering Strategies

Different buffering approaches optimize for different use cases.

**Line-based buffering:**

```javascript
let buffer = '';

async function processStream(stream) {
  const reader = stream.getReader();
  const decoder = new TextDecoder();
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    buffer += decoder.decode(value, { stream: true });
    
    let newlineIndex;
    while ((newlineIndex = buffer.indexOf('\n')) !== -1) {
      const line = buffer.slice(0, newlineIndex);
      buffer = buffer.slice(newlineIndex + 1);
      processLine(line);
    }
  }
  
  // Process remaining buffer
  if (buffer) processLine(buffer);
}
```

**Event-based buffering:**

```javascript
let eventBuffer = {
  event: 'message',
  data: [],
  id: '',
  retry: null
};

function processLine(line) {
  if (line === '') {
    if (eventBuffer.data.length > 0) {
      const event = {
        ...eventBuffer,
        data: eventBuffer.data.join('\n')
      };
      dispatchEvent(event);
      eventBuffer = { event: 'message', data: [], id: '', retry: null };
    }
    return;
  }
  
  // Parse and accumulate
}
```

### Memory Management

Long-running SSE connections require careful memory management.

```javascript
class SSEConnection {
  constructor() {
    this.reader = null;
    this.buffer = '';
    this.bufferLimit = 1024 * 1024; // 1MB limit
  }
  
  async processStream(stream) {
    this.reader = stream.getReader();
    
    try {
      while (true) {
        const { done, value } = await this.reader.read();
        if (done) break;
        
        const chunk = this.decoder.decode(value, { stream: true });
        
        // Prevent unbounded buffer growth
        if (this.buffer.length + chunk.length > this.bufferLimit) {
          throw new Error('Buffer limit exceeded');
        }
        
        this.buffer += chunk;
        this.processBuffer();
      }
    } finally {
      this.cleanup();
    }
  }
  
  cleanup() {
    if (this.reader) {
      this.reader.releaseLock();
      this.reader = null;
    }
    this.buffer = '';
  }
}
```

### Performance Optimization

Optimizations for high-throughput SSE streams.

**Batch Processing:**

```javascript
let eventQueue = [];
let processingScheduled = false;

function queueEvent(event) {
  eventQueue.push(event);
  
  if (!processingScheduled) {
    processingScheduled = true;
    queueMicrotask(processEventQueue);
  }
}

function processEventQueue() {
  const events = eventQueue;
  eventQueue = [];
  processingScheduled = false;
  
  for (const event of events) {
    dispatchEvent(event);
  }
}
```

**Decoder Reuse:**

```javascript
const decoder = new TextDecoder();

// Reuse decoder across reads
async function processStream(stream) {
  const reader = stream.getReader();
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    // Decoder maintains internal state
    const text = decoder.decode(value, { stream: true });
    processText(text);
  }
  
  // Flush decoder at end
  const remaining = decoder.decode();
  if (remaining) processText(remaining);
}
```

### Integration with Async Iterators

Modern streaming patterns using async iteration.

```javascript
async function* parseSSE(response) {
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';
  let currentEvent = { event: 'message', data: '', id: '' };
  
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      
      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split('\n');
      buffer = lines.pop();
      
      for (const line of lines) {
        if (line === '') {
          if (currentEvent.data) {
            yield { ...currentEvent };
            currentEvent = { event: 'message', data: '', id: '' };
          }
        } else {
          // Parse line into currentEvent
        }
      }
    }
  } finally {
    reader.releaseLock();
  }
}

// Usage
const response = await fetch('/events');
for await (const event of parseSSE(response)) {
  console.log(event);
}
```

### Timeout Handling

Implementing connection timeouts for stale connections.

```javascript
async function connectWithTimeout(url, timeout = 45000) {
  const abortController = new AbortController();
  let timeoutId;
  
  const timeoutPromise = new Promise((_, reject) => {
    timeoutId = setTimeout(() => {
      abortController.abort();
      reject(new Error('Connection timeout'));
    }, timeout);
  });
  
  try {
    const response = await Promise.race([
      fetch(url, {
        signal: abortController.signal,
        headers: { 'Accept': 'text/event-stream' }
      }),
      timeoutPromise
    ]);
    
    clearTimeout(timeoutId);
    
    // Reset timeout on each chunk
    return processStreamWithTimeout(response.body, timeout);
    
  } catch (error) {
    clearTimeout(timeoutId);
    throw error;
  }
}

async function processStreamWithTimeout(stream, timeout) {
  const reader = stream.getReader();
  
  while (true) {
    const timeoutPromise = new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Read timeout')), timeout)
    );
    
    const { done, value } = await Promise.race([
      reader.read(),
      timeoutPromise
    ]);
    
    if (done) break;
    
    // Process value
  }
}
```

### Connection Pooling Considerations

[Inference] Unlike traditional HTTP requests, SSE connections are long-lived and may interact differently with browser connection limits. Browsers typically limit concurrent connections per domain (commonly 6-8 connections).

```javascript
class SSEConnectionPool {
  constructor(maxConnections = 6) {
    this.maxConnections = maxConnections;
    this.activeConnections = new Set();
    this.pendingConnections = [];
  }
  
  async connect(url, options) {
    if (this.activeConnections.size >= this.maxConnections) {
      await new Promise(resolve => this.pendingConnections.push(resolve));
    }
    
    const connection = new SSEConnection(url, options);
    this.activeConnections.add(connection);
    
    connection.addEventListener('close', () => {
      this.activeConnections.delete(connection);
      const next = this.pendingConnections.shift();
      if (next) next();
    });
    
    return connection;
  }
}
```

### Service Worker Integration

Fetch-based SSE can operate within service workers for background event handling.

```javascript
// service-worker.js
self.addEventListener('fetch', (event) => {
  if (event.request.url.includes('/events')) {
    event.respondWith(handleSSE(event.request));
  }
});

async function handleSSE(request) {
  const response = await fetch(request);
  
  // Transform stream
  const { readable, writable } = new TransformStream({
    transform(chunk, controller) {
      // Process SSE data
      controller.enqueue(chunk);
    }
  });
  
  response.body.pipeTo(writable);
  
  return new Response(readable, {
    headers: response.headers
  });
}
```

---

