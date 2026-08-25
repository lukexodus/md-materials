## WebSocket Fallback Strategies


### Detecting Connection Failures

#### Connection State Monitoring

The `WebSocket.readyState` property provides the current connection status. Monitor state transitions to detect when fallback mechanisms should activate:

```javascript
const ws = new WebSocket('wss://example.com');

ws.addEventListener('error', (event) => {
  // Connection failed - trigger fallback
});

ws.addEventListener('close', (event) => {
  if (event.code === 1006) {
    // Abnormal closure - connection was not cleanly closed
  }
});
```

#### Timeout-Based Detection

Implement connection timeouts to detect scenarios where the WebSocket hangs without triggering error events:

```javascript
const CONNECTION_TIMEOUT = 5000;

const connectWithTimeout = (url) => {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(url);
    const timeout = setTimeout(() => {
      ws.close();
      reject(new Error('Connection timeout'));
    }, CONNECTION_TIMEOUT);

    ws.addEventListener('open', () => {
      clearTimeout(timeout);
      resolve(ws);
    });

    ws.addEventListener('error', () => {
      clearTimeout(timeout);
      reject(new Error('Connection failed'));
    });
  });
};
```

#### Heartbeat Mechanism

Implement ping/pong patterns to detect silent connection failures:

```javascript
class WebSocketWithHeartbeat {
  constructor(url) {
    this.ws = new WebSocket(url);
    this.pingInterval = null;
    this.lastPong = Date.now();
    this.HEARTBEAT_INTERVAL = 30000;
    this.HEARTBEAT_TIMEOUT = 5000;
  }

  startHeartbeat() {
    this.pingInterval = setInterval(() => {
      if (Date.now() - this.lastPong > this.HEARTBEAT_TIMEOUT) {
        this.ws.close();
        this.triggerFallback();
        return;
      }
      this.ws.send(JSON.stringify({ type: 'ping' }));
    }, this.HEARTBEAT_INTERVAL);
  }

  handlePong() {
    this.lastPong = Date.now();
  }
}
```

### HTTP Long-Polling Fallback

#### Basic Long-Polling Implementation

Long-polling maintains a persistent HTTP request that the server holds open until data is available:

```javascript
class LongPollingTransport {
  constructor(url) {
    this.url = url;
    this.abortController = null;
    this.isActive = false;
  }

  async poll() {
    while (this.isActive) {
      this.abortController = new AbortController();
      
      try {
        const response = await fetch(this.url, {
          method: 'GET',
          signal: this.abortController.signal,
          headers: { 'Content-Type': 'application/json' }
        });

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }

        const data = await response.json();
        this.onMessage(data);
        
      } catch (error) {
        if (error.name !== 'AbortError') {
          await this.handleError(error);
        }
      }
    }
  }

  send(data) {
    return fetch(this.url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
  }

  stop() {
    this.isActive = false;
    if (this.abortController) {
      this.abortController.abort();
    }
  }
}
```

#### Exponential Backoff for Failed Polls

Implement retry logic with exponential backoff to handle temporary network issues:

```javascript
class LongPollingWithBackoff extends LongPollingTransport {
  constructor(url) {
    super(url);
    this.retryCount = 0;
    this.maxRetries = 5;
    this.baseDelay = 1000;
  }

  async handleError(error) {
    if (this.retryCount >= this.maxRetries) {
      this.onFatalError(error);
      return;
    }

    const delay = Math.min(
      this.baseDelay * Math.pow(2, this.retryCount),
      30000
    );
    
    this.retryCount++;
    await new Promise(resolve => setTimeout(resolve, delay));
  }

  resetRetryCount() {
    this.retryCount = 0;
  }
}
```

### Server-Sent Events (SSE) Fallback

#### SSE Implementation

Server-Sent Events provide unidirectional communication from server to client:

```javascript
class SSETransport {
  constructor(url) {
    this.url = url;
    this.eventSource = null;
  }

  connect() {
    this.eventSource = new EventSource(this.url);

    this.eventSource.addEventListener('message', (event) => {
      const data = JSON.parse(event.data);
      this.onMessage(data);
    });

    this.eventSource.addEventListener('error', (error) => {
      if (this.eventSource.readyState === EventSource.CLOSED) {
        this.onConnectionClosed();
      } else {
        this.onError(error);
      }
    });

    this.eventSource.addEventListener('open', () => {
      this.onOpen();
    });
  }

  // SSE is unidirectional - use fetch for sending
  async send(data) {
    return fetch(`${this.url}/send`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
  }

  close() {
    if (this.eventSource) {
      this.eventSource.close();
    }
  }
}
```

#### Custom Event Types

Leverage SSE's built-in event type support for different message categories:

```javascript
class SSEWithCustomEvents extends SSETransport {
  connect() {
    this.eventSource = new EventSource(this.url);

    // Handle different event types
    this.eventSource.addEventListener('notification', (event) => {
      this.onNotification(JSON.parse(event.data));
    });

    this.eventSource.addEventListener('update', (event) => {
      this.onUpdate(JSON.parse(event.data));
    });

    this.eventSource.addEventListener('heartbeat', (event) => {
      this.lastHeartbeat = Date.now();
    });
  }
}
```

#### SSE Reconnection Logic

EventSource automatically reconnects, but implement custom logic for better control:

```javascript
class SSEWithReconnection {
  constructor(url, options = {}) {
    this.url = url;
    this.maxReconnectAttempts = options.maxReconnectAttempts || Infinity;
    this.reconnectInterval = options.reconnectInterval || 3000;
    this.reconnectAttempts = 0;
  }

  connect() {
    this.eventSource = new EventSource(this.url);

    this.eventSource.addEventListener('open', () => {
      this.reconnectAttempts = 0;
      this.onOpen();
    });

    this.eventSource.addEventListener('error', () => {
      this.eventSource.close();
      
      if (this.reconnectAttempts < this.maxReconnectAttempts) {
        this.reconnectAttempts++;
        setTimeout(() => this.connect(), this.reconnectInterval);
      } else {
        this.onMaxReconnectAttemptsReached();
      }
    });
  }
}
```

### Graceful Degradation Architecture

#### Transport Abstraction Layer

Create a unified interface that abstracts the underlying transport mechanism:

```javascript
class TransportInterface {
  async connect() { throw new Error('Not implemented'); }
  async send(data) { throw new Error('Not implemented'); }
  async close() { throw new Error('Not implemented'); }
  onMessage(callback) { this.messageCallback = callback; }
  onError(callback) { this.errorCallback = callback; }
  onClose(callback) { this.closeCallback = callback; }
}

class WebSocketTransport extends TransportInterface {
  constructor(url) {
    super();
    this.url = url;
    this.ws = null;
  }

  async connect() {
    return new Promise((resolve, reject) => {
      this.ws = new WebSocket(this.url);
      
      this.ws.addEventListener('open', () => resolve());
      this.ws.addEventListener('error', reject);
      
      this.ws.addEventListener('message', (event) => {
        this.messageCallback?.(JSON.parse(event.data));
      });
    });
  }

  async send(data) {
    if (this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    }
  }

  async close() {
    this.ws?.close();
  }
}
```

#### Priority-Based Transport Selection

Implement a system that attempts transports in order of preference:

```javascript
class TransportManager {
  constructor(url) {
    this.url = url;
    this.transports = [
      { name: 'websocket', factory: () => new WebSocketTransport(url) },
      { name: 'sse', factory: () => new SSETransport(url) },
      { name: 'long-polling', factory: () => new LongPollingTransport(url) }
    ];
    this.currentTransport = null;
    this.currentIndex = 0;
  }

  async connect() {
    for (let i = this.currentIndex; i < this.transports.length; i++) {
      const transport = this.transports[i];
      
      try {
        const instance = transport.factory();
        await this.attemptConnection(instance, 5000);
        
        this.currentTransport = instance;
        this.currentIndex = i;
        this.onConnected(transport.name);
        return instance;
        
      } catch (error) {
        console.warn(`${transport.name} failed, trying next transport`);
        continue;
      }
    }
    
    throw new Error('All transports failed');
  }

  async attemptConnection(transport, timeout) {
    return Promise.race([
      transport.connect(),
      new Promise((_, reject) => 
        setTimeout(() => reject(new Error('Timeout')), timeout)
      )
    ]);
  }

  async reconnect() {
    await this.currentTransport?.close();
    return this.connect();
  }
}
```

#### Feature Detection

Detect browser capabilities to determine available transports:

```javascript
class FeatureDetector {
  static detectAvailableTransports() {
    const transports = [];

    // WebSocket support
    if ('WebSocket' in window) {
      transports.push({
        name: 'websocket',
        bidirectional: true,
        overhead: 'low',
        latency: 'low'
      });
    }

    // Server-Sent Events support
    if ('EventSource' in window) {
      transports.push({
        name: 'sse',
        bidirectional: false,
        overhead: 'medium',
        latency: 'medium'
      });
    }

    // Long-polling (always available)
    if ('fetch' in window) {
      transports.push({
        name: 'long-polling',
        bidirectional: true,
        overhead: 'high',
        latency: 'high'
      });
    }

    return transports;
  }

  static checkWebSocketSupport() {
    if (!('WebSocket' in window)) return false;
    
    try {
      const ws = new WebSocket('ws://localhost:1');
      ws.close();
      return true;
    } catch {
      return false;
    }
  }
}
```

### Hybrid Approaches

#### WebSocket + Fetch Hybrid

Use WebSocket for real-time updates and fetch for critical operations:

```javascript
class HybridTransport {
  constructor(wsUrl, httpUrl) {
    this.wsUrl = wsUrl;
    this.httpUrl = httpUrl;
    this.ws = null;
    this.preferWebSocket = true;
  }

  async connect() {
    try {
      this.ws = new WebSocket(this.wsUrl);
      await new Promise((resolve, reject) => {
        this.ws.addEventListener('open', resolve);
        this.ws.addEventListener('error', reject);
        setTimeout(reject, 5000);
      });
      this.preferWebSocket = true;
    } catch {
      this.preferWebSocket = false;
    }
  }

  async send(data, options = {}) {
    const { critical = false, timeout = 10000 } = options;

    // Critical messages always use HTTP for reliability
    if (critical || !this.preferWebSocket || this.ws?.readyState !== WebSocket.OPEN) {
      return this.sendViaHttp(data, timeout);
    }

    // Try WebSocket first for non-critical messages
    try {
      this.ws.send(JSON.stringify(data));
      return { success: true, transport: 'websocket' };
    } catch {
      return this.sendViaHttp(data, timeout);
    }
  }

  async sendViaHttp(data, timeout) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(this.httpUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
        signal: controller.signal
      });

      clearTimeout(timeoutId);
      return { 
        success: response.ok, 
        transport: 'http',
        data: await response.json()
      };
    } catch (error) {
      clearTimeout(timeoutId);
      throw error;
    }
  }
}
```

#### Automatic Transport Switching

Dynamically switch transports based on connection quality:

```javascript
class AdaptiveTransport {
  constructor(url) {
    this.url = url;
    this.transportManager = new TransportManager(url);
    this.metrics = {
      latency: [],
      failures: 0,
      successRate: 1.0
    };
  }

  async send(data) {
    const startTime = Date.now();

    try {
      const result = await this.transportManager.currentTransport.send(data);
      const latency = Date.now() - startTime;
      
      this.recordSuccess(latency);
      return result;
      
    } catch (error) {
      this.recordFailure();
      
      if (this.shouldSwitchTransport()) {
        await this.switchToNextTransport();
        return this.send(data); // Retry with new transport
      }
      
      throw error;
    }
  }

  recordSuccess(latency) {
    this.metrics.latency.push(latency);
    if (this.metrics.latency.length > 100) {
      this.metrics.latency.shift();
    }
    
    this.metrics.failures = Math.max(0, this.metrics.failures - 1);
    this.updateSuccessRate();
  }

  recordFailure() {
    this.metrics.failures++;
    this.updateSuccessRate();
  }

  updateSuccessRate() {
    const total = this.metrics.latency.length + this.metrics.failures;
    this.metrics.successRate = this.metrics.latency.length / Math.max(total, 1);
  }

  shouldSwitchTransport() {
    const avgLatency = this.metrics.latency.reduce((a, b) => a + b, 0) / 
                       this.metrics.latency.length;
    
    return this.metrics.successRate < 0.8 || 
           avgLatency > 3000 || 
           this.metrics.failures > 5;
  }

  async switchToNextTransport() {
    this.transportManager.currentIndex++;
    await this.transportManager.reconnect();
    this.resetMetrics();
  }

  resetMetrics() {
    this.metrics = {
      latency: [],
      failures: 0,
      successRate: 1.0
    };
  }
}
```

### Connection State Management

#### State Machine Implementation

Implement a finite state machine to manage connection lifecycle:

```javascript
const ConnectionState = {
  DISCONNECTED: 'disconnected',
  CONNECTING: 'connecting',
  CONNECTED: 'connected',
  RECONNECTING: 'reconnecting',
  FAILED: 'failed'
};

class ConnectionStateMachine {
  constructor() {
    this.state = ConnectionState.DISCONNECTED;
    this.listeners = new Map();
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
  }

  transition(newState, metadata = {}) {
    const oldState = this.state;
    this.state = newState;
    
    this.emit('stateChange', {
      from: oldState,
      to: newState,
      ...metadata
    });
  }

  async connect(transport) {
    if (this.state === ConnectionState.CONNECTED) return;
    
    this.transition(ConnectionState.CONNECTING);

    try {
      await transport.connect();
      this.reconnectAttempts = 0;
      this.transition(ConnectionState.CONNECTED, { transport: transport.name });
    } catch (error) {
      await this.handleConnectionFailure(transport, error);
    }
  }

  async handleConnectionFailure(transport, error) {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      this.transition(ConnectionState.RECONNECTING, {
        attempt: this.reconnectAttempts,
        error: error.message
      });
      
      await this.delay(this.getReconnectDelay());
      await this.connect(transport);
    } else {
      this.transition(ConnectionState.FAILED, { error: error.message });
    }
  }

  getReconnectDelay() {
    return Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);
  }

  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  on(event, callback) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event).push(callback);
  }

  emit(event, data) {
    const callbacks = this.listeners.get(event) || [];
    callbacks.forEach(callback => callback(data));
  }
}
```

#### Message Queue for Offline Support

Buffer messages when connection is unavailable and replay when reconnected:

```javascript
class MessageQueue {
  constructor(maxSize = 1000) {
    this.queue = [];
    this.maxSize = maxSize;
    this.processing = false;
  }

  enqueue(message) {
    if (this.queue.length >= this.maxSize) {
      this.queue.shift(); // Remove oldest message
    }
    
    this.queue.push({
      data: message,
      timestamp: Date.now(),
      attempts: 0
    });
  }

  async process(sendFunction) {
    if (this.processing) return;
    
    this.processing = true;

    while (this.queue.length > 0) {
      const message = this.queue[0];
      
      try {
        await sendFunction(message.data);
        this.queue.shift(); // Remove successfully sent message
      } catch (error) {
        message.attempts++;
        
        if (message.attempts >= 3) {
          this.queue.shift(); // Remove failed message after 3 attempts
          this.onMessageFailed?.(message);
        } else {
          break; // Stop processing on failure, will retry later
        }
      }
    }

    this.processing = false;
  }

  clear() {
    this.queue = [];
  }

  size() {
    return this.queue.length;
  }
}

class ResilientConnection {
  constructor(transport) {
    this.transport = transport;
    this.queue = new MessageQueue();
    this.isConnected = false;

    this.transport.onClose(() => {
      this.isConnected = false;
    });

    this.transport.onOpen(() => {
      this.isConnected = true;
      this.queue.process((data) => this.transport.send(data));
    });
  }

  async send(data) {
    if (this.isConnected) {
      try {
        await this.transport.send(data);
      } catch (error) {
        this.queue.enqueue(data);
        throw error;
      }
    } else {
      this.queue.enqueue(data);
    }
  }
}
```

### Protocol Negotiation

#### Client-Server Capability Exchange

Negotiate the best transport during the initial handshake:

```javascript
class ProtocolNegotiator {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
  }

  async negotiate() {
    const clientCapabilities = {
      transports: FeatureDetector.detectAvailableTransports(),
      protocols: ['json', 'msgpack'],
      compression: ['gzip', 'deflate'],
      features: ['binary', 'streaming']
    };

    const response = await fetch(`${this.baseUrl}/negotiate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(clientCapabilities)
    });

    const serverCapabilities = await response.json();
    
    return this.selectOptimalConfiguration(
      clientCapabilities,
      serverCapabilities
    );
  }

  selectOptimalConfiguration(client, server) {
    // Find best transport both support
    const transport = this.selectTransport(
      client.transports,
      server.supportedTransports
    );

    // Select protocol
    const protocol = this.selectProtocol(
      client.protocols,
      server.supportedProtocols
    );

    // Select compression
    const compression = this.selectCompression(
      client.compression,
      server.supportedCompression
    );

    return {
      transport,
      protocol,
      compression,
      connectionId: server.connectionId
    };
  }

  selectTransport(client, server) {
    const priority = ['websocket', 'sse', 'long-polling'];
    
    for (const transport of priority) {
      const clientSupport = client.find(t => t.name === transport);
      const serverSupport = server.includes(transport);
      
      if (clientSupport && serverSupport) {
        return transport;
      }
    }
    
    return 'long-polling'; // Default fallback
  }

  selectProtocol(client, server) {
    return client.find(p => server.includes(p)) || 'json';
  }

  selectCompression(client, server) {
    return client.find(c => server.includes(c)) || null;
  }
}
```

#### Version Compatibility Handling

Handle protocol version mismatches gracefully:

```javascript
class VersionedConnection {
  constructor(baseUrl, version = '1.0') {
    this.baseUrl = baseUrl;
    this.clientVersion = version;
    this.serverVersion = null;
  }

  async connect() {
    const handshake = await fetch(`${this.baseUrl}/handshake`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Protocol-Version': this.clientVersion
      },
      body: JSON.stringify({
        version: this.clientVersion,
        features: this.getSupportedFeatures()
      })
    });

    const response = await handshake.json();
    this.serverVersion = response.version;

    if (!this.isCompatible(this.clientVersion, this.serverVersion)) {
      throw new Error(
        `Version mismatch: client ${this.clientVersion}, server ${this.serverVersion}`
      );
    }

    return this.createConnection(response);
  }

  isCompatible(client, server) {
    const [clientMajor] = client.split('.');
    const [serverMajor] = server.split('.');
    
    return clientMajor === serverMajor;
  }

  getSupportedFeatures() {
    const features = {
      '1.0': ['basic', 'reconnect'],
      '1.1': ['basic', 'reconnect', 'compression'],
      '2.0': ['basic', 'reconnect', 'compression', 'multiplexing']
    };

    return features[this.clientVersion] || features['1.0'];
  }

  createConnection(config) {
    // Create transport based on negotiated configuration
    const transportFactory = this.getTransportFactory(config.transport);
    return transportFactory(config);
  }
}
```

### Proxy and Firewall Handling

#### Detecting Proxy Issues

Identify when connections fail due to proxy or firewall restrictions:

```javascript
class ProxyDetector {
  async detectProxyIssues(wsUrl, httpUrl) {
    const results = {
      websocketBlocked: false,
      httpBlocked: false,
      httpsBlocked: false,
      proxyDetected: false
    };

    // Test WebSocket
    try {
      await this.testWebSocket(wsUrl);
    } catch (error) {
      results.websocketBlocked = true;
    }

    // Test HTTP
    try {
      await this.testHttp(httpUrl);
    } catch (error) {
      results.httpBlocked = true;
    }

    // Test HTTPS
    try {
      await this.testHttps(httpUrl.replace('http:', 'https:'));
    } catch (error) {
      results.httpsBlocked = true;
    }

    // Check for proxy indicators
    results.proxyDetected = this.checkProxyHeaders();

    return results;
  }

  async testWebSocket(url, timeout = 3000) {
    return new Promise((resolve, reject) => {
      const ws = new WebSocket(url);
      const timer = setTimeout(() => {
        ws.close();
        reject(new Error('WebSocket timeout'));
      }, timeout);

      ws.addEventListener('open', () => {
        clearTimeout(timer);
        ws.close();
        resolve();
      });

      ws.addEventListener('error', () => {
        clearTimeout(timer);
        reject(new Error('WebSocket error'));
      });
    });
  }

  async testHttp(url, timeout = 3000) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeout);

    try {
      await fetch(url, { signal: controller.signal });
      clearTimeout(timer);
    } catch (error) {
      clearTimeout(timer);
      throw error;
    }
  }

  async testHttps(url, timeout = 3000) {
    return this.testHttp(url, timeout);
  }

  checkProxyHeaders() {
    // Some proxies inject headers that are accessible via timing attacks
    // or by checking for specific behavior patterns
    return navigator.connection?.effectiveType === 'slow-2g' ||
           navigator.connection?.saveData === true;
  }
}
```

#### Working Around Restrictions

Implement strategies to bypass common proxy/firewall limitations:

```javascript
class ProxyWorkaround {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
    this.useHttps = true;
    this.useStandardPorts = false;
  }

  async findWorkingConfiguration() {
    const configurations = [
      // Try WebSocket over standard HTTPS port
      { protocol: 'wss', port: 443, path: '/ws' },
      
      // Try WebSocket over HTTP port  
      { protocol: 'ws', port: 80, path: '/ws' },
      
      // Try WebSocket on custom port
      { protocol: 'wss', port: 8080, path: '/ws' },
      
      // Fallback to HTTPS long-polling
      { protocol: 'https', port: 443, path: '/poll' },
      
      // Fallback to HTTP long-polling
      { protocol: 'http', port: 80, path: '/poll' }
    ];

    for (const config of configurations) {
      try {
        const url = this.buildUrl(config);
        await this.testConnection(url, config.protocol);
        return { url, config };
      } catch (error) {
        continue;
      }
    }

    throw new Error('No working configuration found');
  }

  buildUrl(config) {
    const base = new URL(this.baseUrl);
    return `${config.protocol}://${base.hostname}:${config.port}${config.path}`;
  }

  async testConnection(url, protocol) {
    if (protocol.startsWith('ws')) {
      return this.testWebSocket(url);
    } else {
      return this.testHttp(url);
    }
  }

  async testWebSocket(url) {
    return new Promise((resolve, reject) => {
      const ws = new WebSocket(url);
      const timeout = setTimeout(() => {
        ws.close();
        reject(new Error('Timeout'));
      }, 3000);

      ws.addEventListener('open', () => {
        clearTimeout(timeout);
        ws.close();
        resolve();
      });

      ws.addEventListener('error', reject);
    });
  }

  async testHttp(url) {
    const controller = new AbortController();
    setTimeout(() => controller.abort(), 3000);

    const response = await fetch(url, { signal: controller.signal });
    if (!response.ok) throw new Error('HTTP test failed');
  }
}
```

### Performance Optimization

#### Message Batching

Reduce overhead by batching multiple messages into single transmissions:

```javascript
class BatchingTransport {
  constructor(transport, options = {}) {
    this.transport = transport;
    this.batchSize = options.batchSize || 10;
    this.batchTimeout = options.batchTimeout || 100;
    this.pendingMessages = [];
    this.batchTimer = null;
  }

  send(data) {
    this.pendingMessages.push(data);

    if (this.pendingMessages.length >= this.batchSize) {
      this.flush();
    } else if (!this.batchTimer) {
      this.batchTimer = setTimeout(() => this.flush(), this.batchTimeout);
    }
  }

  flush() {
    if (this.batchTimer) {
      clearTimeout(this.batchTimer);
      this.batchTimer = null;
    }

    if (this.pendingMessages.length === 0) return;

    const batch = {
      type: 'batch',
      messages: this.pendingMessages.splice(0)
    };

    this.transport.send(batch);
  }

  async close() {
    this.flush();
    await this.transport.close();
  }
}
```

#### Message Compression

Compress large payloads before transmission:

```javascript
class CompressionTransport {
  constructor(transport, options = {}) {
    this.transport = transport;
    this.compressionThreshold = options.threshold || 1024; // 1KB
    this.compressionStream = null;
  }

  async send(data) {
    const serialized = JSON.stringify(data);
    
    if (serialized.length < this.compressionThreshold) {
      return this.transport.send({ compressed: false, data });
    }

    const compressed = await this.compress(serialized);
```

---

