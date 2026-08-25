## Long Polling


### Core Mechanism

Long polling maintains a persistent connection by keeping HTTP requests open until the server has new data to send. When the server responds, the client immediately initiates a new request, creating a continuous communication channel. Unlike traditional polling which makes frequent requests at fixed intervals regardless of data availability, long polling reduces unnecessary network traffic by only responding when meaningful updates exist.

The server holds the request open, monitoring for events or changes. Once data becomes available or a timeout occurs, it responds to the pending request. The client processes the response and immediately establishes a new long-polling connection.

### Implementation Pattern

#### Basic Long Polling Loop

```javascript
async function longPoll(url, options = {}) {
  while (true) {
    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
        signal: options.signal,
      });

      if (!response.ok) {
        throw new Error(`HTTP error: ${response.status}`);
      }

      const data = await response.json();
      
      if (options.onMessage) {
        options.onMessage(data);
      }

      if (options.shouldContinue && !options.shouldContinue(data)) {
        break;
      }
    } catch (error) {
      if (error.name === 'AbortError') {
        break;
      }

      if (options.onError) {
        options.onError(error);
      }

      await new Promise(resolve => setTimeout(resolve, options.retryDelay || 5000));
    }
  }
}
```

#### Cancellation Support

```javascript
const controller = new AbortController();

longPoll('/api/updates', {
  signal: controller.signal,
  onMessage: (data) => {
    console.log('Received:', data);
  },
  onError: (error) => {
    console.error('Error:', error);
  }
});

// Stop polling
controller.abort();
```

### Timeout Handling

#### Server-Side Timeout

Servers typically implement timeouts to prevent indefinite connection holding:

```javascript
// Server timeout after 30 seconds
async function longPoll(url) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 30000);

  try {
    const response = await fetch(url, {
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    return await response.json();
  } catch (error) {
    clearTimeout(timeoutId);
    if (error.name === 'AbortError') {
      // Timeout occurred, reconnect
      return longPoll(url);
    }
    throw error;
  }
}
```

#### Client-Side Timeout

```javascript
async function longPollWithTimeout(url, clientTimeout = 35000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), clientTimeout);

  try {
    const response = await fetch(url, { signal: controller.signal });
    clearTimeout(timeoutId);
    
    if (response.status === 204) {
      // No content, server timeout
      return longPollWithTimeout(url, clientTimeout);
    }
    
    return await response.json();
  } catch (error) {
    clearTimeout(timeoutId);
    throw error;
  }
}
```

### Reconnection Strategies

#### Exponential Backoff

```javascript
async function longPollWithBackoff(url, maxRetries = 5) {
  let retryCount = 0;
  let delay = 1000;

  while (retryCount < maxRetries) {
    try {
      const response = await fetch(url);
      retryCount = 0; // Reset on success
      delay = 1000;
      
      const data = await response.json();
      handleData(data);
      
      // Immediately reconnect
      continue;
    } catch (error) {
      retryCount++;
      console.error(`Attempt ${retryCount} failed:`, error);
      
      if (retryCount >= maxRetries) {
        throw new Error('Max retries exceeded');
      }
      
      await new Promise(resolve => setTimeout(resolve, delay));
      delay = Math.min(delay * 2, 30000); // Cap at 30 seconds
    }
  }
}
```

#### Jittered Backoff

```javascript
function calculateJitteredDelay(baseDelay, attempt, maxDelay = 30000) {
  const exponentialDelay = Math.min(baseDelay * Math.pow(2, attempt), maxDelay);
  const jitter = Math.random() * exponentialDelay * 0.3;
  return exponentialDelay + jitter;
}

async function longPollWithJitter(url) {
  let attempt = 0;

  while (true) {
    try {
      const response = await fetch(url);
      attempt = 0; // Reset on success
      
      const data = await response.json();
      processData(data);
    } catch (error) {
      const delay = calculateJitteredDelay(1000, attempt);
      await new Promise(resolve => setTimeout(resolve, delay));
      attempt++;
    }
  }
}
```

### State Management

#### Tracking Connection State

```javascript
class LongPollingClient {
  constructor(url) {
    this.url = url;
    this.state = 'disconnected'; // 'disconnected', 'connecting', 'connected'
    this.controller = null;
    this.listeners = new Set();
  }

  on(event, callback) {
    this.listeners.add({ event, callback });
  }

  emit(event, data) {
    this.listeners.forEach(({ event: e, callback }) => {
      if (e === event) callback(data);
    });
  }

  async start() {
    if (this.state !== 'disconnected') return;
    
    this.controller = new AbortController();
    this.state = 'connecting';
    this.emit('stateChange', 'connecting');
    
    await this.poll();
  }

  async poll() {
    while (this.state !== 'disconnected') {
      try {
        const response = await fetch(this.url, {
          signal: this.controller.signal
        });

        if (this.state === 'connecting') {
          this.state = 'connected';
          this.emit('stateChange', 'connected');
        }

        const data = await response.json();
        this.emit('message', data);
      } catch (error) {
        if (error.name === 'AbortError') break;
        
        this.state = 'connecting';
        this.emit('stateChange', 'connecting');
        this.emit('error', error);
        
        await new Promise(resolve => setTimeout(resolve, 3000));
      }
    }
  }

  stop() {
    if (this.controller) {
      this.controller.abort();
    }
    this.state = 'disconnected';
    this.emit('stateChange', 'disconnected');
  }
}
```

#### Last Event ID Pattern

```javascript
async function longPollWithEventId(url) {
  let lastEventId = localStorage.getItem('lastEventId') || '0';

  while (true) {
    try {
      const response = await fetch(`${url}?lastEventId=${lastEventId}`);
      const data = await response.json();
      
      if (data.eventId) {
        lastEventId = data.eventId;
        localStorage.setItem('lastEventId', lastEventId);
      }
      
      processEvents(data.events);
    } catch (error) {
      console.error('Polling error:', error);
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
  }
}
```

### Request Configuration

#### Headers and Authentication

```javascript
async function authenticatedLongPoll(url, token) {
  while (true) {
    try {
      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'X-Client-Version': '1.0.0',
          'Accept': 'application/json',
        },
        credentials: 'include',
      });

      if (response.status === 401) {
        // Token expired, refresh
        token = await refreshToken();
        continue;
      }

      const data = await response.json();
      handleUpdate(data);
    } catch (error) {
      handleError(error);
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  }
}
```

#### Request Body for Filtering

```javascript
async function filteredLongPoll(url, filters) {
  while (true) {
    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          filters: filters,
          timestamp: Date.now(),
        }),
      });

      const data = await response.json();
      processFilteredData(data);
    } catch (error) {
      console.error(error);
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  }
}
```

### Error Recovery

#### Network Error Handling

```javascript
async function robustLongPoll(url) {
  const maxConsecutiveErrors = 3;
  let consecutiveErrors = 0;

  while (true) {
    try {
      const response = await fetch(url);
      
      if (!response.ok) {
        if (response.status >= 500) {
          throw new Error('Server error');
        } else if (response.status === 429) {
          const retryAfter = response.headers.get('Retry-After') || 60;
          await new Promise(resolve => setTimeout(resolve, retryAfter * 1000));
          continue;
        } else {
          throw new Error(`HTTP ${response.status}`);
        }
      }

      consecutiveErrors = 0;
      const data = await response.json();
      processData(data);
    } catch (error) {
      consecutiveErrors++;

      if (consecutiveErrors >= maxConsecutiveErrors) {
        notifyConnectionFailure();
        await new Promise(resolve => setTimeout(resolve, 30000));
        consecutiveErrors = 0;
      } else {
        await new Promise(resolve => setTimeout(resolve, 5000));
      }
    }
  }
}
```

#### Partial Response Handling

```javascript
async function handlePartialResponses(url) {
  while (true) {
    try {
      const response = await fetch(url);
      const reader = response.body.getReader();
      const decoder = new TextDecoder();
      let buffer = '';

      while (true) {
        const { done, value } = await reader.read();
        
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        
        // Process complete JSON objects
        let boundary;
        while ((boundary = buffer.indexOf('\n')) !== -1) {
          const line = buffer.slice(0, boundary);
          buffer = buffer.slice(boundary + 1);
          
          if (line.trim()) {
            try {
              const data = JSON.parse(line);
              handleMessage(data);
            } catch (e) {
              console.error('Parse error:', e);
            }
          }
        }
      }
      
      // Reconnect
      continue;
    } catch (error) {
      console.error(error);
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  }
}
```

### Performance Optimization

#### Connection Pooling

```javascript
class LongPollingPool {
  constructor(baseUrl, poolSize = 3) {
    this.baseUrl = baseUrl;
    this.poolSize = poolSize;
    this.connections = [];
    this.messageQueue = [];
  }

  async start() {
    for (let i = 0; i < this.poolSize; i++) {
      this.connections.push(this.createConnection(i));
    }
  }

  async createConnection(id) {
    while (true) {
      try {
        const response = await fetch(`${this.baseUrl}?conn=${id}`);
        const data = await response.json();
        
        data.messages.forEach(msg => this.messageQueue.push(msg));
        this.processQueue();
      } catch (error) {
        console.error(`Connection ${id} error:`, error);
        await new Promise(resolve => setTimeout(resolve, 2000));
      }
    }
  }

  processQueue() {
    while (this.messageQueue.length > 0) {
      const message = this.messageQueue.shift();
      this.handleMessage(message);
    }
  }

  handleMessage(message) {
    // Process message
  }

  stop() {
    // Stop all connections
  }
}
```

#### Request Deduplication

```javascript
class DedupedLongPolling {
  constructor(url) {
    this.url = url;
    this.pendingRequest = null;
    this.subscribers = new Set();
  }

  async subscribe(callback) {
    this.subscribers.add(callback);

    if (!this.pendingRequest) {
      this.pendingRequest = this.poll();
    }

    return () => this.subscribers.delete(callback);
  }

  async poll() {
    while (this.subscribers.size > 0) {
      try {
        const response = await fetch(this.url);
        const data = await response.json();

        this.subscribers.forEach(callback => {
          try {
            callback(data);
          } catch (error) {
            console.error('Subscriber error:', error);
          }
        });
      } catch (error) {
        console.error('Polling error:', error);
        await new Promise(resolve => setTimeout(resolve, 3000));
      }
    }

    this.pendingRequest = null;
  }
}
```

### Browser Lifecycle Integration

#### Visibility API Integration

```javascript
class VisibilityAwareLongPolling {
  constructor(url) {
    this.url = url;
    this.controller = null;
    this.isPolling = false;

    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        this.pause();
      } else {
        this.resume();
      }
    });
  }

  async start() {
    if (this.isPolling) return;
    
    this.isPolling = true;
    this.controller = new AbortController();
    
    await this.poll();
  }

  async poll() {
    while (this.isPolling && !document.hidden) {
      try {
        const response = await fetch(this.url, {
          signal: this.controller.signal
        });
        
        const data = await response.json();
        this.handleData(data);
      } catch (error) {
        if (error.name === 'AbortError') break;
        await new Promise(resolve => setTimeout(resolve, 3000));
      }
    }
  }

  pause() {
    if (this.controller) {
      this.controller.abort();
      this.controller = null;
    }
  }

  resume() {
    if (this.isPolling && !this.controller) {
      this.start();
    }
  }

  stop() {
    this.isPolling = false;
    if (this.controller) {
      this.controller.abort();
    }
  }

  handleData(data) {
    // Process data
  }
}
```

#### Online/Offline Detection

```javascript
class NetworkAwareLongPolling {
  constructor(url) {
    this.url = url;
    this.online = navigator.onLine;
    this.controller = null;

    window.addEventListener('online', () => {
      this.online = true;
      this.reconnect();
    });

    window.addEventListener('offline', () => {
      this.online = false;
      if (this.controller) {
        this.controller.abort();
      }
    });
  }

  async start() {
    if (!this.online) {
      console.log('Offline, waiting for connection');
      return;
    }

    await this.poll();
  }

  async poll() {
    this.controller = new AbortController();

    while (this.online) {
      try {
        const response = await fetch(this.url, {
          signal: this.controller.signal
        });

        const data = await response.json();
        this.processData(data);
      } catch (error) {
        if (error.name === 'AbortError') break;
        
        // Check if still online
        if (!navigator.onLine) {
          this.online = false;
          break;
        }

        await new Promise(resolve => setTimeout(resolve, 3000));
      }
    }
  }

  reconnect() {
    this.start();
  }

  processData(data) {
    // Handle data
  }
}
```

### Comparison with Alternatives

#### Long Polling vs Short Polling

Short polling makes requests at fixed intervals regardless of data availability. Long polling keeps connections open until data exists, reducing unnecessary requests and latency.

**Latency**: Long polling delivers updates immediately when available. Short polling has latency up to the polling interval.

**Server Load**: Long polling maintains fewer connections but holds them longer. Short polling creates more frequent connections but releases them quickly.

**Network Efficiency**: Long polling reduces bandwidth when updates are infrequent. Short polling generates constant traffic regardless of activity.

#### Long Polling vs WebSockets

WebSockets provide full-duplex bidirectional communication over a persistent connection. Long polling is unidirectional (server to client) and uses HTTP requests.

**Connection Model**: WebSockets establish a single persistent connection. Long polling creates sequential HTTP connections.

**Protocol Overhead**: WebSockets have minimal framing overhead after handshake. Long polling repeats HTTP headers with each request.

**Browser Support**: Long polling works universally with HTTP. WebSockets require WebSocket protocol support.

**Proxy Compatibility**: Long polling works through HTTP proxies. WebSockets may be blocked by some proxies and firewalls.

**Implementation Complexity**: Long polling uses standard fetch API. WebSockets require WebSocket API and more complex state management.

#### Long Polling vs Server-Sent Events

Server-Sent Events (SSE) provide server-to-client streaming over HTTP with automatic reconnection. Long polling requires manual reconnection logic.

**Connection Persistence**: SSE maintains a persistent connection for multiple messages. Long polling creates new connections per message.

**Reconnection**: SSE includes automatic reconnection with last event ID. Long polling requires manual implementation.

**Message Format**: SSE uses text-based event stream format. Long polling can use any response format.

**Browser API**: SSE uses EventSource API with built-in features. Long polling uses fetch with custom implementation.

**Binary Data**: Long polling can handle binary responses. SSE is text-only.

### Use Cases

#### Chat Applications

Long polling works for chat applications where message frequency is moderate and WebSocket infrastructure is unavailable:

```javascript
class ChatLongPolling {
  constructor(chatId, userId) {
    this.chatId = chatId;
    this.userId = userId;
    this.lastMessageId = 0;
  }

  async start() {
    while (true) {
      try {
        const response = await fetch(`/api/chat/${this.chatId}/messages`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            lastMessageId: this.lastMessageId,
            userId: this.userId
          })
        });

        const { messages } = await response.json();
        
        if (messages.length > 0) {
          this.displayMessages(messages);
          this.lastMessageId = messages[messages.length - 1].id;
        }
      } catch (error) {
        console.error('Chat polling error:', error);
        await new Promise(resolve => setTimeout(resolve, 2000));
      }
    }
  }

  displayMessages(messages) {
    messages.forEach(msg => {
      // Render message in UI
    });
  }
}
```

#### Notification Systems

Long polling efficiently delivers notifications without constant polling overhead:

```javascript
async function pollNotifications(userId) {
  let sequence = 0;

  while (true) {
    try {
      const response = await fetch(`/api/notifications/${userId}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sequence })
      });

      const { notifications, nextSequence } = await response.json();
      
      if (notifications.length > 0) {
        notifications.forEach(showNotification);
        sequence = nextSequence;
      }
    } catch (error) {
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
  }
}
```

#### Live Dashboard Updates

Long polling provides near-real-time dashboard updates without WebSocket complexity:

```javascript
class DashboardPoller {
  constructor(dashboardId) {
    this.dashboardId = dashboardId;
    this.widgets = new Map();
  }

  async pollWidget(widgetId) {
    while (true) {
      try {
        const response = await fetch(
          `/api/dashboard/${this.dashboardId}/widget/${widgetId}/data`
        );

        const data = await response.json();
        this.updateWidget(widgetId, data);
      } catch (error) {
        console.error(`Widget ${widgetId} error:`, error);
        await new Promise(resolve => setTimeout(resolve, 3000));
      }
    }
  }

  startPolling(widgetIds) {
    widgetIds.forEach(id => {
      this.pollWidget(id);
    });
  }

  updateWidget(widgetId, data) {
    // Update widget display
  }
}
```

### Security Considerations

#### Request Authentication

```javascript
async function secureLongPoll(url) {
  let token = await getAuthToken();
  let tokenRefreshTime = Date.now() + 50 * 60 * 1000; // 50 minutes

  while (true) {
    // Refresh token before expiry
    if (Date.now() >= tokenRefreshTime) {
      token = await refreshAuthToken();
      tokenRefreshTime = Date.now() + 50 * 60 * 1000;
    }

    try {
      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'X-Request-ID': generateRequestId(),
        },
        credentials: 'include',
      });

      if (response.status === 401) {
        token = await refreshAuthToken();
        continue;
      }

      const data = await response.json();
      processSecureData(data);
    } catch (error) {
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  }
}
```

#### Rate Limiting Compliance

```javascript
class RateLimitedLongPolling {
  constructor(url) {
    this.url = url;
    this.requestCount = 0;
    this.resetTime = Date.now() + 60000;
    this.maxRequests = 100;
  }

  async poll() {
    while (true) {
      // Check rate limit
      if (Date.now() >= this.resetTime) {
        this.requestCount = 0;
        this.resetTime = Date.now() + 60000;
      }

      if (this.requestCount >= this.maxRequests) {
        const waitTime = this.resetTime - Date.now();
        await new Promise(resolve => setTimeout(resolve, waitTime));
        continue;
      }

      try {
        this.requestCount++;
        const response = await fetch(this.url);

        // Update limits from response headers
        const remaining = response.headers.get('X-RateLimit-Remaining');
        const reset = response.headers.get('X-RateLimit-Reset');
        
        if (remaining) this.maxRequests = parseInt(remaining);
        if (reset) this.resetTime = parseInt(reset) * 1000;

        const data = await response.json();
        this.handleData(data);
      } catch (error) {
        await new Promise(resolve => setTimeout(resolve, 5000));
      }
    }
  }

  handleData(data) {
    // Process data
  }
}
```

#### CSRF Protection

```javascript
async function csrfProtectedLongPoll(url) {
  let csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

  while (true) {
    try {
      const response = await fetch(url, {
        headers: {
          'X-CSRF-Token': csrfToken,
          'Content-Type': 'application/json',
        },
        credentials: 'same-origin',
      });

      if (response.status === 403) {
        // CSRF token expired, reload page
        window.location.reload();
        break;
      }

      const data = await response.json();
      processData(data);
    } catch (error) {
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  }
}
```

