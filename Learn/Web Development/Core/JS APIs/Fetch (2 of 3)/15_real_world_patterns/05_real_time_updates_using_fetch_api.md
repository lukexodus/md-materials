## Real-time Updates using Fetch API


### Streaming Responses

The Fetch API supports streaming responses through the `ReadableStream` interface, allowing you to process data as it arrives rather than waiting for the complete response.

#### Accessing the Stream

```javascript
const response = await fetch('https://api.example.com/stream');
const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  const chunk = decoder.decode(value, { stream: true });
  console.log('Received chunk:', chunk);
}
```

#### Processing Chunked Data

For line-delimited data (like Server-Sent Events format):

```javascript
async function processStream(response) {
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';

  while (true) {
    const { done, value } = await reader.read();
    
    if (done) {
      if (buffer.length > 0) {
        processLine(buffer);
      }
      break;
    }

    buffer += decoder.decode(value, { stream: true });
    const lines = buffer.split('\n');
    buffer = lines.pop(); // Keep incomplete line in buffer

    lines.forEach(line => {
      if (line.trim()) {
        processLine(line);
      }
    });
  }
}

function processLine(line) {
  try {
    const data = JSON.parse(line);
    updateUI(data);
  } catch (e) {
    console.error('Parse error:', e);
  }
}
```

### Server-Sent Events (SSE) Alternative

While not directly part of Fetch API, SSE via `EventSource` is commonly used for server-to-client streaming:

```javascript
const eventSource = new EventSource('https://api.example.com/events');

eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data);
  updateUI(data);
};

eventSource.onerror = (error) => {
  console.error('SSE error:', error);
  eventSource.close();
};

// Custom event types
eventSource.addEventListener('update', (event) => {
  console.log('Update event:', event.data);
});
```

### Long Polling Pattern

Implementing long polling with Fetch API for environments that don't support streaming:

```javascript
async function longPoll(url, options = {}) {
  const { timeout = 30000, maxRetries = 3 } = options;
  let retries = 0;

  while (retries < maxRetries) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);

      const response = await fetch(url, {
        signal: controller.signal,
        headers: {
          'Content-Type': 'application/json',
        }
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const data = await response.json();
      
      if (data.updates) {
        processUpdates(data.updates);
      }

      // Continue polling
      await longPoll(url, options);
      break;

    } catch (error) {
      if (error.name === 'AbortError') {
        // Timeout - restart poll
        continue;
      }

      retries++;
      if (retries >= maxRetries) {
        console.error('Max retries reached:', error);
        break;
      }

      // Exponential backoff
      await new Promise(resolve => 
        setTimeout(resolve, Math.min(1000 * Math.pow(2, retries), 30000))
      );
    }
  }
}
```

### Polling with Exponential Backoff

For periodic polling when real-time streaming isn't available:

```javascript
class PollingManager {
  constructor(url, options = {}) {
    this.url = url;
    this.interval = options.interval || 5000;
    this.maxInterval = options.maxInterval || 60000;
    this.backoffMultiplier = options.backoffMultiplier || 1.5;
    this.currentInterval = this.interval;
    this.timeoutId = null;
    this.isPolling = false;
  }

  async poll() {
    if (!this.isPolling) return;

    try {
      const response = await fetch(this.url);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const data = await response.json();
      this.handleSuccess(data);

      // Reset interval on success
      this.currentInterval = this.interval;

    } catch (error) {
      this.handleError(error);

      // Increase interval on error
      this.currentInterval = Math.min(
        this.currentInterval * this.backoffMultiplier,
        this.maxInterval
      );
    }

    if (this.isPolling) {
      this.timeoutId = setTimeout(() => this.poll(), this.currentInterval);
    }
  }

  start() {
    if (this.isPolling) return;
    this.isPolling = true;
    this.poll();
  }

  stop() {
    this.isPolling = false;
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }

  handleSuccess(data) {
    console.log('Poll success:', data);
  }

  handleError(error) {
    console.error('Poll error:', error);
  }
}
```

### Streaming JSON Parsing

For handling large JSON responses incrementally:

```javascript
async function streamJSON(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';
  let depth = 0;
  let objectStart = -1;

  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;

    buffer += decoder.decode(value, { stream: true });

    for (let i = 0; i < buffer.length; i++) {
      const char = buffer[i];

      if (char === '{') {
        if (depth === 0) objectStart = i;
        depth++;
      } else if (char === '}') {
        depth--;
        if (depth === 0 && objectStart !== -1) {
          const jsonStr = buffer.substring(objectStart, i + 1);
          try {
            const obj = JSON.parse(jsonStr);
            handleObject(obj);
          } catch (e) {
            console.error('JSON parse error:', e);
          }
          buffer = buffer.substring(i + 1);
          i = -1;
          objectStart = -1;
        }
      }
    }
  }
}
```

### Handling Binary Streams

Processing binary data streams:

```javascript
async function processBinaryStream(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  let receivedLength = 0;
  const chunks = [];

  while (true) {
    const { done, value } = await reader.read();

    if (done) break;

    chunks.push(value);
    receivedLength += value.length;

    // Update progress
    const contentLength = response.headers.get('Content-Length');
    if (contentLength) {
      const progress = (receivedLength / parseInt(contentLength)) * 100;
      updateProgress(progress);
    }

    // Process chunk immediately if needed
    processChunk(value);
  }

  // Combine all chunks
  const allChunks = new Uint8Array(receivedLength);
  let position = 0;
  for (const chunk of chunks) {
    allChunks.set(chunk, position);
    position += chunk.length;
  }

  return allChunks;
}
```

### Abort and Cleanup

Managing stream lifecycle:

```javascript
class StreamManager {
  constructor() {
    this.controller = null;
    this.reader = null;
  }

  async startStream(url) {
    this.controller = new AbortController();

    try {
      const response = await fetch(url, {
        signal: this.controller.signal
      });

      this.reader = response.body.getReader();
      const decoder = new TextDecoder();

      while (true) {
        const { done, value } = await this.reader.read();
        
        if (done) break;

        const chunk = decoder.decode(value, { stream: true });
        this.onData(chunk);
      }

    } catch (error) {
      if (error.name === 'AbortError') {
        console.log('Stream aborted');
      } else {
        this.onError(error);
      }
    } finally {
      this.cleanup();
    }
  }

  stop() {
    if (this.controller) {
      this.controller.abort();
    }
  }

  cleanup() {
    if (this.reader) {
      this.reader.releaseLock();
      this.reader = null;
    }
    this.controller = null;
  }

  onData(chunk) {
    console.log('Received:', chunk);
  }

  onError(error) {
    console.error('Stream error:', error);
  }
}
```

### Backpressure Handling

[Inference] Managing flow control when consumer is slower than producer:

```javascript
async function streamWithBackpressure(url, processChunk) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();

  try {
    while (true) {
      const { done, value } = await reader.read();
      
      if (done) break;

      const chunk = decoder.decode(value, { stream: true });
      
      // Wait for processing to complete before reading next chunk
      await processChunk(chunk);
    }
  } finally {
    reader.releaseLock();
  }
}

// Usage
await streamWithBackpressure(url, async (chunk) => {
  // Simulate slow processing
  await heavyProcessing(chunk);
  await saveToDatabase(chunk);
});
```

### Multiplexing Multiple Streams

Handling multiple concurrent streams:

```javascript
class MultiStreamManager {
  constructor() {
    this.streams = new Map();
  }

  async addStream(id, url) {
    const controller = new AbortController();
    
    const streamPromise = this.processStream(url, controller.signal)
      .catch(error => {
        if (error.name !== 'AbortError') {
          console.error(`Stream ${id} error:`, error);
        }
      })
      .finally(() => {
        this.streams.delete(id);
      });

    this.streams.set(id, {
      promise: streamPromise,
      controller
    });
  }

  async processStream(url, signal) {
    const response = await fetch(url, { signal });
    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      
      const chunk = decoder.decode(value, { stream: true });
      this.onData(url, chunk);
    }
  }

  stopStream(id) {
    const stream = this.streams.get(id);
    if (stream) {
      stream.controller.abort();
    }
  }

  stopAll() {
    for (const [id, stream] of this.streams) {
      stream.controller.abort();
    }
    this.streams.clear();
  }

  onData(url, chunk) {
    console.log(`Data from ${url}:`, chunk);
  }
}
```

### Reconnection Strategy

Implementing automatic reconnection:

```javascript
class ReconnectingStream {
  constructor(url, options = {}) {
    this.url = url;
    this.maxRetries = options.maxRetries || Infinity;
    this.retryDelay = options.retryDelay || 1000;
    this.maxRetryDelay = options.maxRetryDelay || 30000;
    this.retryCount = 0;
    this.isConnected = false;
    this.shouldReconnect = true;
  }

  async connect() {
    while (this.shouldReconnect && this.retryCount < this.maxRetries) {
      try {
        await this.startStream();
        this.retryCount = 0;
        
      } catch (error) {
        console.error('Connection error:', error);
        this.isConnected = false;
        
        if (!this.shouldReconnect) break;

        this.retryCount++;
        const delay = Math.min(
          this.retryDelay * Math.pow(2, this.retryCount - 1),
          this.maxRetryDelay
        );

        console.log(`Reconnecting in ${delay}ms (attempt ${this.retryCount})`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }

  async startStream() {
    const response = await fetch(this.url);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    this.isConnected = true;
    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    try {
      while (this.shouldReconnect) {
        const { done, value } = await reader.read();
        
        if (done) {
          throw new Error('Stream ended');
        }

        const chunk = decoder.decode(value, { stream: true });
        this.onData(chunk);
      }
    } finally {
      reader.releaseLock();
    }
  }

  disconnect() {
    this.shouldReconnect = false;
    this.isConnected = false;
  }

  onData(chunk) {
    console.log('Received:', chunk);
  }
}
```

### Rate Limiting Outgoing Updates

Throttling requests when sending real-time updates:

```javascript
class RateLimitedUpdater {
  constructor(url, options = {}) {
    this.url = url;
    this.rateLimit = options.rateLimit || 10; // requests per second
    this.queue = [];
    this.processing = false;
    this.interval = 1000 / this.rateLimit;
  }

  async sendUpdate(data) {
    return new Promise((resolve, reject) => {
      this.queue.push({ data, resolve, reject });
      this.processQueue();
    });
  }

  async processQueue() {
    if (this.processing || this.queue.length === 0) return;

    this.processing = true;

    while (this.queue.length > 0) {
      const { data, resolve, reject } = this.queue.shift();

      try {
        const response = await fetch(this.url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data)
        });

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }

        const result = await response.json();
        resolve(result);

      } catch (error) {
        reject(error);
      }

      // Wait before processing next
      if (this.queue.length > 0) {
        await new Promise(resolve => setTimeout(resolve, this.interval));
      }
    }

    this.processing = false;
  }
}
```

### Progressive Enhancement Pattern

Falling back gracefully when streaming isn't supported:

```javascript
async function fetchWithFallback(url) {
  // Check if streaming is supported
  const supportsStreaming = typeof ReadableStream !== 'undefined' &&
                           typeof Response !== 'undefined' &&
                           Response.prototype.hasOwnProperty('body');

  if (supportsStreaming) {
    try {
      return await streamingFetch(url);
    } catch (error) {
      console.warn('Streaming failed, falling back:', error);
    }
  }

  // Fallback to regular fetch
  return await regularFetch(url);
}

async function streamingFetch(url) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    const chunk = decoder.decode(value, { stream: true });
    processChunk(chunk);
  }
}

async function regularFetch(url) {
  const response = await fetch(url);
  const data = await response.text();
  processChunk(data);
}
```

---

