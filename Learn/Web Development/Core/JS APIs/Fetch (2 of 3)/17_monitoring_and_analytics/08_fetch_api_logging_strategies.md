## Fetch API Logging Strategies


### Structured Logging

Structure logs as JSON objects for easier parsing and analysis:

```javascript
function logFetchRequest(url, options, metadata = {}) {
  const log = {
    timestamp: new Date().toISOString(),
    type: 'fetch_request',
    url: url,
    method: options.method || 'GET',
    headers: options.headers ? Object.keys(options.headers) : [],
    hasBody: !!options.body,
    ...metadata
  };
  
  console.log(JSON.stringify(log));
  return log;
}

function logFetchResponse(url, response, duration, metadata = {}) {
  const log = {
    timestamp: new Date().toISOString(),
    type: 'fetch_response',
    url: url,
    status: response.status,
    statusText: response.statusText,
    ok: response.ok,
    duration: duration,
    contentType: response.headers.get('content-type'),
    contentLength: response.headers.get('content-length'),
    ...metadata
  };
  
  console.log(JSON.stringify(log));
  return log;
}
```

### Request/Response Correlation

Associate requests with their responses using correlation IDs:

```javascript
function generateCorrelationId() {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

async function fetchWithCorrelation(url, options = {}) {
  const correlationId = generateCorrelationId();
  const startTime = performance.now();
  
  console.log({
    correlationId,
    type: 'request_start',
    url,
    method: options.method || 'GET',
    timestamp: new Date().toISOString()
  });
  
  try {
    const response = await fetch(url, options);
    const duration = performance.now() - startTime;
    
    console.log({
      correlationId,
      type: 'request_complete',
      url,
      status: response.status,
      duration: `${duration.toFixed(2)}ms`,
      timestamp: new Date().toISOString()
    });
    
    return response;
  } catch (error) {
    const duration = performance.now() - startTime;
    
    console.error({
      correlationId,
      type: 'request_failed',
      url,
      error: error.message,
      duration: `${duration.toFixed(2)}ms`,
      timestamp: new Date().toISOString()
    });
    
    throw error;
  }
}
```

### Log Levels

Implement different severity levels for appropriate filtering:

```javascript
const LogLevel = {
  DEBUG: 0,
  INFO: 1,
  WARN: 2,
  ERROR: 3
};

class FetchLogger {
  constructor(minLevel = LogLevel.INFO) {
    this.minLevel = minLevel;
  }
  
  log(level, message, data = {}) {
    if (level < this.minLevel) return;
    
    const levelNames = ['DEBUG', 'INFO', 'WARN', 'ERROR'];
    const logEntry = {
      level: levelNames[level],
      message,
      timestamp: new Date().toISOString(),
      ...data
    };
    
    switch (level) {
      case LogLevel.DEBUG:
      case LogLevel.INFO:
        console.log(logEntry);
        break;
      case LogLevel.WARN:
        console.warn(logEntry);
        break;
      case LogLevel.ERROR:
        console.error(logEntry);
        break;
    }
  }
  
  debug(message, data) {
    this.log(LogLevel.DEBUG, message, data);
  }
  
  info(message, data) {
    this.log(LogLevel.INFO, message, data);
  }
  
  warn(message, data) {
    this.log(LogLevel.WARN, message, data);
  }
  
  error(message, data) {
    this.log(LogLevel.ERROR, message, data);
  }
}

// Usage
const logger = new FetchLogger(LogLevel.INFO);

async function fetchData(url) {
  logger.debug('Initiating request', { url });
  
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      logger.warn('Non-OK response', { url, status: response.status });
    } else {
      logger.info('Request successful', { url, status: response.status });
    }
    
    return response;
  } catch (error) {
    logger.error('Request failed', { url, error: error.message });
    throw error;
  }
}
```

### Performance Metrics

Track detailed timing information:

```javascript
async function fetchWithMetrics(url, options = {}) {
  const metrics = {
    url,
    method: options.method || 'GET',
    startTime: performance.now(),
    dnsLookup: null,
    tcpConnection: null,
    tlsHandshake: null,
    requestSent: null,
    firstByte: null,
    contentDownload: null,
    totalDuration: null
  };
  
  try {
    const response = await fetch(url, options);
    
    // Get performance entry
    const perfEntries = performance.getEntriesByType('resource');
    const entry = perfEntries.find(e => e.name === url);
    
    if (entry) {
      metrics.dnsLookup = entry.domainLookupEnd - entry.domainLookupStart;
      metrics.tcpConnection = entry.connectEnd - entry.connectStart;
      metrics.tlsHandshake = entry.secureConnectionStart > 0 
        ? entry.connectEnd - entry.secureConnectionStart 
        : 0;
      metrics.requestSent = entry.responseStart - entry.requestStart;
      metrics.firstByte = entry.responseStart - entry.fetchStart;
      metrics.contentDownload = entry.responseEnd - entry.responseStart;
      metrics.totalDuration = entry.responseEnd - entry.fetchStart;
    } else {
      metrics.totalDuration = performance.now() - metrics.startTime;
    }
    
    console.log({
      type: 'performance_metrics',
      ...metrics,
      status: response.status
    });
    
    return response;
  } catch (error) {
    metrics.totalDuration = performance.now() - metrics.startTime;
    
    console.error({
      type: 'performance_metrics',
      ...metrics,
      error: error.message
    });
    
    throw error;
  }
}
```

### Request/Response Body Logging

Log payloads with size limits and sanitization:

```javascript
class BodyLogger {
  constructor(maxBodySize = 1000, sanitize = true) {
    this.maxBodySize = maxBodySize;
    this.sanitize = sanitize;
  }
  
  logRequestBody(body) {
    if (!body) return null;
    
    if (typeof body === 'string') {
      return this.truncate(body);
    }
    
    if (body instanceof FormData) {
      const entries = {};
      for (const [key, value] of body.entries()) {
        entries[key] = value instanceof File 
          ? `[File: ${value.name}]` 
          : this.truncate(String(value));
      }
      return entries;
    }
    
    if (body instanceof Blob) {
      return `[Blob: ${body.size} bytes, type: ${body.type}]`;
    }
    
    return '[Unknown body type]';
  }
  
  async logResponseBody(response) {
    const clonedResponse = response.clone();
    const contentType = response.headers.get('content-type') || '';
    
    if (contentType.includes('application/json')) {
      try {
        const json = await clonedResponse.json();
        return this.sanitize 
          ? this.sanitizeData(json) 
          : this.truncate(JSON.stringify(json));
      } catch {
        return '[Invalid JSON]';
      }
    }
    
    if (contentType.includes('text/')) {
      const text = await clonedResponse.text();
      return this.truncate(text);
    }
    
    return `[Binary content: ${contentType}]`;
  }
  
  truncate(str) {
    if (str.length <= this.maxBodySize) return str;
    return str.substring(0, this.maxBodySize) + '... [truncated]';
  }
  
  sanitizeData(data) {
    const sensitiveKeys = ['password', 'token', 'secret', 'apiKey', 'authorization'];
    
    if (typeof data !== 'object' || data === null) {
      return data;
    }
    
    if (Array.isArray(data)) {
      return data.map(item => this.sanitizeData(item));
    }
    
    const sanitized = {};
    for (const [key, value] of Object.entries(data)) {
      if (sensitiveKeys.some(sk => key.toLowerCase().includes(sk))) {
        sanitized[key] = '[REDACTED]';
      } else if (typeof value === 'object') {
        sanitized[key] = this.sanitizeData(value);
      } else {
        sanitized[key] = value;
      }
    }
    
    return sanitized;
  }
}

// Usage
const bodyLogger = new BodyLogger(500, true);

async function fetchWithBodyLogging(url, options = {}) {
  console.log({
    type: 'request',
    url,
    method: options.method || 'GET',
    body: bodyLogger.logRequestBody(options.body)
  });
  
  const response = await fetch(url, options);
  
  const responseBody = await bodyLogger.logResponseBody(response);
  
  console.log({
    type: 'response',
    url,
    status: response.status,
    body: responseBody
  });
  
  return response;
}
```

### Header Logging

Log headers with security considerations:

```javascript
function logHeaders(headers, direction = 'request') {
  const sensitiveHeaders = [
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'x-auth-token'
  ];
  
  const logged = {};
  
  if (headers instanceof Headers) {
    for (const [key, value] of headers.entries()) {
      if (sensitiveHeaders.includes(key.toLowerCase())) {
        logged[key] = '[REDACTED]';
      } else {
        logged[key] = value;
      }
    }
  } else if (typeof headers === 'object') {
    for (const [key, value] of Object.entries(headers)) {
      if (sensitiveHeaders.includes(key.toLowerCase())) {
        logged[key] = '[REDACTED]';
      } else {
        logged[key] = value;
      }
    }
  }
  
  console.log({
    type: `${direction}_headers`,
    headers: logged
  });
  
  return logged;
}

async function fetchWithHeaderLogging(url, options = {}) {
  logHeaders(options.headers, 'request');
  
  const response = await fetch(url, options);
  
  logHeaders(response.headers, 'response');
  
  return response;
}
```

### Batched Logging

Buffer logs and send them in batches to reduce overhead:

```javascript
class BatchLogger {
  constructor(batchSize = 10, flushInterval = 5000, endpoint = null) {
    this.batchSize = batchSize;
    this.flushInterval = flushInterval;
    this.endpoint = endpoint;
    this.buffer = [];
    this.timer = null;
    
    this.startTimer();
  }
  
  log(entry) {
    this.buffer.push({
      ...entry,
      timestamp: new Date().toISOString()
    });
    
    if (this.buffer.length >= this.batchSize) {
      this.flush();
    }
  }
  
  async flush() {
    if (this.buffer.length === 0) return;
    
    const batch = [...this.buffer];
    this.buffer = [];
    
    console.log(`[BatchLogger] Flushing ${batch.length} entries`);
    
    if (this.endpoint) {
      try {
        await fetch(this.endpoint, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ logs: batch })
        });
      } catch (error) {
        console.error('[BatchLogger] Failed to send batch:', error);
        // Could re-add to buffer or store locally
      }
    } else {
      // Local logging
      console.log('[BatchLogger] Batch:', batch);
    }
    
    this.startTimer();
  }
  
  startTimer() {
    if (this.timer) clearTimeout(this.timer);
    this.timer = setTimeout(() => this.flush(), this.flushInterval);
  }
  
  destroy() {
    if (this.timer) clearTimeout(this.timer);
    this.flush();
  }
}

// Usage
const batchLogger = new BatchLogger(20, 10000, '/api/logs');

async function fetchWithBatchLogging(url, options = {}) {
  const startTime = performance.now();
  
  batchLogger.log({
    type: 'request_start',
    url,
    method: options.method || 'GET'
  });
  
  try {
    const response = await fetch(url, options);
    const duration = performance.now() - startTime;
    
    batchLogger.log({
      type: 'request_complete',
      url,
      status: response.status,
      duration
    });
    
    return response;
  } catch (error) {
    const duration = performance.now() - startTime;
    
    batchLogger.log({
      type: 'request_error',
      url,
      error: error.message,
      duration
    });
    
    throw error;
  }
}

// Clean up before page unload
window.addEventListener('beforeunload', () => {
  batchLogger.destroy();
});
```

### Context Enrichment

Add contextual information to every log:

```javascript
class ContextualLogger {
  constructor() {
    this.context = {
      sessionId: this.generateSessionId(),
      userId: null,
      environment: this.detectEnvironment(),
      userAgent: navigator.userAgent,
      url: window.location.href
    };
  }
  
  generateSessionId() {
    return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
  
  detectEnvironment() {
    const hostname = window.location.hostname;
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return 'development';
    }
    if (hostname.includes('staging')) {
      return 'staging';
    }
    return 'production';
  }
  
  setUserId(userId) {
    this.context.userId = userId;
  }
  
  addContext(key, value) {
    this.context[key] = value;
  }
  
  log(entry) {
    const enriched = {
      ...this.context,
      ...entry,
      timestamp: new Date().toISOString()
    };
    
    console.log(enriched);
    return enriched;
  }
}

// Global logger instance
const contextLogger = new ContextualLogger();

// Set user context after login
function onUserLogin(user) {
  contextLogger.setUserId(user.id);
  contextLogger.addContext('userRole', user.role);
}

// Use in fetch
async function fetchWithContext(url, options = {}) {
  contextLogger.log({
    type: 'fetch_request',
    url,
    method: options.method || 'GET'
  });
  
  const response = await fetch(url, options);
  
  contextLogger.log({
    type: 'fetch_response',
    url,
    status: response.status
  });
  
  return response;
}
```

### Error Stack Traces

Capture and log detailed error information:

```javascript
function logErrorWithStack(error, context = {}) {
  const errorLog = {
    type: 'error',
    message: error.message,
    name: error.name,
    stack: error.stack,
    timestamp: new Date().toISOString(),
    ...context
  };
  
  // Parse stack trace for better readability
  if (error.stack) {
    const stackLines = error.stack.split('\n');
    errorLog.parsedStack = stackLines.slice(1).map(line => {
      const match = line.match(/at\s+(.+?)\s+\((.+?):(\d+):(\d+)\)/);
      if (match) {
        return {
          function: match[1],
          file: match[2],
          line: parseInt(match[3]),
          column: parseInt(match[4])
        };
      }
      return line.trim();
    });
  }
  
  console.error(errorLog);
  return errorLog;
}

async function fetchWithStackTrace(url, options = {}) {
  try {
    const response = await fetch(url, options);
    
    if (!response.ok) {
      const error = new Error(`HTTP ${response.status}: ${response.statusText}`);
      throw error;
    }
    
    return response;
  } catch (error) {
    logErrorWithStack(error, {
      url,
      method: options.method || 'GET',
      fetchContext: 'api_call'
    });
    
    throw error;
  }
}
```

### Sampling for High-Traffic Scenarios

Log only a percentage of requests in production:

```javascript
class SamplingLogger {
  constructor(sampleRate = 0.1) {
    this.sampleRate = sampleRate; // 0.1 = 10%
    this.alwaysLogErrors = true;
  }
  
  shouldLog() {
    return Math.random() < this.sampleRate;
  }
  
  log(entry, forceLog = false) {
    if (forceLog || this.shouldLog()) {
      console.log({
        ...entry,
        sampled: !forceLog,
        sampleRate: this.sampleRate,
        timestamp: new Date().toISOString()
      });
    }
  }
  
  logError(entry) {
    // Always log errors regardless of sample rate
    console.error({
      ...entry,
      sampled: false,
      timestamp: new Date().toISOString()
    });
  }
}

// Production: log 5% of requests, all errors
const samplingLogger = new SamplingLogger(0.05);

async function fetchWithSampling(url, options = {}) {
  const startTime = performance.now();
  
  samplingLogger.log({
    type: 'request',
    url,
    method: options.method || 'GET'
  });
  
  try {
    const response = await fetch(url, options);
    const duration = performance.now() - startTime;
    
    if (!response.ok) {
      samplingLogger.logError({
        type: 'http_error',
        url,
        status: response.status,
        duration
      });
    } else {
      samplingLogger.log({
        type: 'response',
        url,
        status: response.status,
        duration
      });
    }
    
    return response;
  } catch (error) {
    samplingLogger.logError({
      type: 'network_error',
      url,
      error: error.message
    });
    
    throw error;
  }
}
```

### Integration with External Services

Send logs to third-party monitoring services:

```javascript
class ExternalLogger {
  constructor(config = {}) {
    this.serviceName = config.serviceName;
    this.apiKey = config.apiKey;
    this.endpoint = config.endpoint;
    this.enabled = config.enabled !== false;
  }
  
  async sendLog(log) {
    if (!this.enabled) return;
    
    try {
      // Use sendBeacon for reliability during page unload
      if (navigator.sendBeacon && log.type === 'critical') {
        const blob = new Blob(
          [JSON.stringify(log)],
          { type: 'application/json' }
        );
        navigator.sendBeacon(this.endpoint, blob);
      } else {
        await fetch(this.endpoint, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': this.apiKey
          },
          body: JSON.stringify(log),
          keepalive: true
        });
      }
    } catch (error) {
      // Fallback to console if external logging fails
      console.error('[ExternalLogger] Failed to send log:', error);
      console.log('[ExternalLogger] Original log:', log);
    }
  }
  
  logFetchRequest(url, options, result) {
    this.sendLog({
      service: this.serviceName,
      type: 'fetch_request',
      url,
      method: options.method || 'GET',
      status: result.status,
      duration: result.duration,
      timestamp: new Date().toISOString()
    });
  }
  
  logError(url, error) {
    this.sendLog({
      service: this.serviceName,
      type: 'fetch_error',
      url,
      error: {
        message: error.message,
        name: error.name,
        stack: error.stack
      },
      severity: 'error',
      timestamp: new Date().toISOString()
    });
  }
}

// Initialize with your monitoring service
const externalLogger = new ExternalLogger({
  serviceName: 'my-app',
  apiKey: 'your-api-key',
  endpoint: 'https://logs.yourservice.com/v1/logs',
  enabled: true
});
```

### Development vs Production Logging

Adjust logging verbosity based on environment:

```javascript
class EnvironmentLogger {
  constructor() {
    this.isDevelopment = this.detectDevelopment();
  }
  
  detectDevelopment() {
    return (
      window.location.hostname === 'localhost' ||
      window.location.hostname === '127.0.0.1' ||
      window.location.hostname.includes('.local') ||
      process.env.NODE_ENV === 'development'
    );
  }
  
  log(level, message, data = {}) {
    const entry = {
      level,
      message,
      ...data,
      timestamp: new Date().toISOString()
    };
    
    if (this.isDevelopment) {
      // Verbose logging in development
      console.group(`[${level}] ${message}`);
      console.log('Details:', data);
      console.trace();
      console.groupEnd();
    } else {
      // Structured logging in production
      const method = level === 'error' ? 'error' : 'log';
      console[method](JSON.stringify(entry));
    }
  }
  
  debug(message, data) {
    if (this.isDevelopment) {
      this.log('DEBUG', message, data);
    }
  }
  
  info(message, data) {
    this.log('INFO', message, data);
  }
  
  error(message, data) {
    this.log('ERROR', message, data);
  }
}

const envLogger = new EnvironmentLogger();

async function fetchWithEnvironmentLogging(url, options = {}) {
  envLogger.debug('Fetch request initiated', { url, options });
  
  try {
    const response = await fetch(url, options);
    
    envLogger.info('Fetch completed', {
      url,
      status: response.status
    });
    
    return response;
  } catch (error) {
    envLogger.error('Fetch failed', {
      url,
      error: error.message,
      stack: error.stack
    });
    
    throw error;
  }
}
```

---

