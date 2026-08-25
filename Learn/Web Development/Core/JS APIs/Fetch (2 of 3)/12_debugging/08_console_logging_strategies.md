## Console Logging Strategies


### Basic Request/Response Logging

```javascript
async function loggedFetch(url, options = {}) {
  const startTime = performance.now();
  const requestId = Math.random().toString(36).substr(2, 9);
  
  console.log(`[${requestId}] → ${options.method || 'GET'} ${url}`);
  
  if (options.body) {
    console.log(`[${requestId}] Body:`, options.body);
  }
  
  if (options.headers) {
    console.log(`[${requestId}] Headers:`, options.headers);
  }
  
  try {
    const response = await fetch(url, options);
    const duration = (performance.now() - startTime).toFixed(2);
    
    console.log(
      `[${requestId}] ← ${response.status} ${response.statusText} (${duration}ms)`
    );
    
    return response;
  } catch (error) {
    const duration = (performance.now() - startTime).toFixed(2);
    console.error(`[${requestId}] ✗ ${error.message} (${duration}ms)`);
    throw error;
  }
}
```

### Structured Logging with Levels

```javascript
const LogLevel = {
  DEBUG: 0,
  INFO: 1,
  WARN: 2,
  ERROR: 3,
  NONE: 4
};

class FetchLogger {
  constructor(level = LogLevel.INFO) {
    this.level = level;
    this.requestCounter = 0;
  }
  
  setLevel(level) {
    this.level = level;
  }
  
  shouldLog(level) {
    return level >= this.level;
  }
  
  debug(...args) {
    if (this.shouldLog(LogLevel.DEBUG)) {
      console.debug(...args);
    }
  }
  
  info(...args) {
    if (this.shouldLog(LogLevel.INFO)) {
      console.info(...args);
    }
  }
  
  warn(...args) {
    if (this.shouldLog(LogLevel.WARN)) {
      console.warn(...args);
    }
  }
  
  error(...args) {
    if (this.shouldLog(LogLevel.ERROR)) {
      console.error(...args);
    }
  }
  
  async fetch(url, options = {}) {
    const requestId = ++this.requestCounter;
    const method = options.method || 'GET';
    const startTime = performance.now();
    
    this.info(`[REQ ${requestId}] ${method} ${url}`);
    this.debug(`[REQ ${requestId}] Options:`, options);
    
    try {
      const response = await fetch(url, options);
      const duration = (performance.now() - startTime).toFixed(2);
      
      if (response.ok) {
        this.info(
          `[RES ${requestId}] ${response.status} ${response.statusText} (${duration}ms)`
        );
      } else {
        this.warn(
          `[RES ${requestId}] ${response.status} ${response.statusText} (${duration}ms)`
        );
      }
      
      this.debug(`[RES ${requestId}] Headers:`, 
        Object.fromEntries(response.headers.entries())
      );
      
      return response;
    } catch (error) {
      const duration = (performance.now() - startTime).toFixed(2);
      this.error(
        `[ERR ${requestId}] ${error.name}: ${error.message} (${duration}ms)`
      );
      throw error;
    }
  }
}

// Usage
const logger = new FetchLogger(LogLevel.INFO);
await logger.fetch('/api/data');

// Enable debug mode
logger.setLevel(LogLevel.DEBUG);
```

### Grouped Console Logs

```javascript
async function fetchWithGroupedLogs(url, options = {}) {
  const method = options.method || 'GET';
  const groupLabel = `${method} ${url}`;
  
  console.group(groupLabel);
  
  const startTime = performance.now();
  
  console.log('Started:', new Date().toISOString());
  
  if (options.headers) {
    console.group('Request Headers');
    Object.entries(options.headers).forEach(([key, value]) => {
      console.log(`${key}:`, value);
    });
    console.groupEnd();
  }
  
  if (options.body) {
    console.log('Request Body:', options.body);
  }
  
  try {
    const response = await fetch(url, options);
    const duration = (performance.now() - startTime).toFixed(2);
    
    console.log(
      `%cStatus: ${response.status} ${response.statusText}`,
      response.ok ? 'color: green' : 'color: red'
    );
    console.log(`Duration: ${duration}ms`);
    
    console.group('Response Headers');
    response.headers.forEach((value, key) => {
      console.log(`${key}:`, value);
    });
    console.groupEnd();
    
    console.groupEnd();
    return response;
  } catch (error) {
    const duration = (performance.now() - startTime).toFixed(2);
    console.error('Error:', error);
    console.log(`Duration: ${duration}ms`);
    console.groupEnd();
    throw error;
  }
}
```

### Styled Console Output

```javascript
const styles = {
  request: 'color: #0066cc; font-weight: bold',
  success: 'color: #00cc66; font-weight: bold',
  error: 'color: #cc0000; font-weight: bold',
  warning: 'color: #ff9900; font-weight: bold',
  info: 'color: #666666',
  duration: 'color: #9966cc; font-style: italic'
};

async function styledFetch(url, options = {}) {
  const method = options.method || 'GET';
  const requestId = Math.random().toString(36).substr(2, 6).toUpperCase();
  const startTime = performance.now();
  
  console.log(
    `%c[${requestId}] →%c ${method} %c${url}`,
    styles.info,
    styles.request,
    styles.info
  );
  
  try {
    const response = await fetch(url, options);
    const duration = (performance.now() - startTime).toFixed(2);
    
    const statusStyle = response.ok ? styles.success : 
                       response.status >= 400 ? styles.error : 
                       styles.warning;
    
    console.log(
      `%c[${requestId}] ←%c ${response.status} ${response.statusText} %c${duration}ms`,
      styles.info,
      statusStyle,
      styles.duration
    );
    
    return response;
  } catch (error) {
    const duration = (performance.now() - startTime).toFixed(2);
    
    console.log(
      `%c[${requestId}] ✗%c ${error.message} %c${duration}ms`,
      styles.info,
      styles.error,
      styles.duration
    );
    
    throw error;
  }
}
```

### Conditional Logging with Environment

```javascript
const isDevelopment = () => {
  try {
    return process.env.NODE_ENV === 'development';
  } catch {
    return location.hostname === 'localhost' || 
           location.hostname === '127.0.0.1';
  }
};

class ConditionalLogger {
  constructor() {
    this.enabled = isDevelopment();
  }
  
  enable() {
    this.enabled = true;
  }
  
  disable() {
    this.enabled = false;
  }
  
  log(...args) {
    if (this.enabled) {
      console.log(...args);
    }
  }
  
  error(...args) {
    if (this.enabled) {
      console.error(...args);
    }
  }
  
  warn(...args) {
    if (this.enabled) {
      console.warn(...args);
    }
  }
  
  group(...args) {
    if (this.enabled) {
      console.group(...args);
    }
  }
  
  groupEnd() {
    if (this.enabled) {
      console.groupEnd();
    }
  }
  
  table(data) {
    if (this.enabled) {
      console.table(data);
    }
  }
}

const devLogger = new ConditionalLogger();
```

### Request/Response Body Logging

```javascript
async function logBodies(url, options = {}) {
  const requestId = Date.now().toString(36);
  
  console.group(`[${requestId}] ${options.method || 'GET'} ${url}`);
  
  // Log request body
  if (options.body) {
    try {
      let bodyContent = options.body;
      
      if (options.body instanceof FormData) {
        console.log('Request Body (FormData):');
        for (const [key, value] of options.body.entries()) {
          console.log(`  ${key}:`, value);
        }
      } else if (typeof options.body === 'string') {
        try {
          bodyContent = JSON.parse(options.body);
          console.log('Request Body (JSON):', bodyContent);
        } catch {
          console.log('Request Body (Text):', options.body);
        }
      } else {
        console.log('Request Body:', options.body);
      }
    } catch (error) {
      console.warn('Could not log request body:', error);
    }
  }
  
  try {
    const response = await fetch(url, options);
    
    console.log(`Status: ${response.status} ${response.statusText}`);
    
    // Clone response to log body without consuming it
    const cloned = response.clone();
    
    const contentType = response.headers.get('content-type');
    
    if (contentType?.includes('application/json')) {
      try {
        const data = await cloned.json();
        console.log('Response Body (JSON):', data);
      } catch (error) {
        console.warn('Failed to parse JSON response:', error);
      }
    } else if (contentType?.includes('text/')) {
      try {
        const text = await cloned.text();
        console.log('Response Body (Text):', text);
      } catch (error) {
        console.warn('Failed to read text response:', error);
      }
    } else {
      console.log('Response Body: (binary data, not logged)');
    }
    
    console.groupEnd();
    return response;
  } catch (error) {
    console.error('Request failed:', error);
    console.groupEnd();
    throw error;
  }
}
```

### Performance Metrics Logging

```javascript
class PerformanceLogger {
  constructor() {
    this.metrics = [];
  }
  
  async fetch(url, options = {}) {
    const startMark = `fetch-start-${Date.now()}`;
    const endMark = `fetch-end-${Date.now()}`;
    const measureName = `fetch-${url}`;
    
    performance.mark(startMark);
    
    const startTime = performance.now();
    const method = options.method || 'GET';
    
    try {
      const response = await fetch(url, options);
      
      performance.mark(endMark);
      performance.measure(measureName, startMark, endMark);
      
      const duration = performance.now() - startTime;
      
      const metric = {
        url,
        method,
        status: response.status,
        duration: duration.toFixed(2),
        timestamp: new Date().toISOString(),
        success: response.ok
      };
      
      this.metrics.push(metric);
      
      console.log(
        `[PERF] ${method} ${url} - ${response.status} (${duration.toFixed(2)}ms)`
      );
      
      // Log slow requests
      if (duration > 1000) {
        console.warn(
          `[SLOW] ${method} ${url} took ${duration.toFixed(2)}ms`
        );
      }
      
      return response;
    } catch (error) {
      performance.mark(endMark);
      performance.measure(measureName, startMark, endMark);
      
      const duration = performance.now() - startTime;
      
      const metric = {
        url,
        method,
        error: error.message,
        duration: duration.toFixed(2),
        timestamp: new Date().toISOString(),
        success: false
      };
      
      this.metrics.push(metric);
      
      console.error(
        `[PERF] ${method} ${url} - ERROR (${duration.toFixed(2)}ms)`
      );
      
      throw error;
    }
  }
  
  getMetrics() {
    return this.metrics;
  }
  
  printSummary() {
    console.group('Performance Summary');
    console.table(this.metrics);
    
    const successful = this.metrics.filter(m => m.success).length;
    const failed = this.metrics.filter(m => !m.success).length;
    const avgDuration = (
      this.metrics.reduce((sum, m) => sum + parseFloat(m.duration), 0) / 
      this.metrics.length
    ).toFixed(2);
    
    console.log(`Total Requests: ${this.metrics.length}`);
    console.log(`Successful: ${successful}`);
    console.log(`Failed: ${failed}`);
    console.log(`Average Duration: ${avgDuration}ms`);
    
    console.groupEnd();
  }
  
  clear() {
    this.metrics = [];
  }
}

const perfLogger = new PerformanceLogger();
```

### Network Timeline Visualization

```javascript
class TimelineLogger {
  constructor() {
    this.requests = new Map();
  }
  
  async fetch(url, options = {}) {
    const requestId = crypto.randomUUID?.() || Date.now().toString(36);
    
    const timeline = {
      url,
      method: options.method || 'GET',
      phases: {
        start: performance.now(),
        dnsStart: null,
        connectStart: null,
        requestStart: null,
        responseStart: null,
        responseEnd: null
      }
    };
    
    this.requests.set(requestId, timeline);
    
    try {
      const response = await fetch(url, options);
      
      timeline.phases.responseEnd = performance.now();
      timeline.status = response.status;
      timeline.size = response.headers.get('content-length');
      
      this.logTimeline(requestId, timeline);
      
      return response;
    } catch (error) {
      timeline.phases.responseEnd = performance.now();
      timeline.error = error.message;
      
      this.logTimeline(requestId, timeline);
      throw error;
    }
  }
  
  logTimeline(requestId, timeline) {
    const total = timeline.phases.responseEnd - timeline.phases.start;
    
    console.group(`Timeline: ${timeline.method} ${timeline.url}`);
    console.log(`Total: ${total.toFixed(2)}ms`);
    
    if (timeline.status) {
      console.log(`Status: ${timeline.status}`);
    }
    
    if (timeline.size) {
      console.log(`Size: ${this.formatBytes(timeline.size)}`);
    }
    
    if (timeline.error) {
      console.error(`Error: ${timeline.error}`);
    }
    
    // Visual timeline
    this.drawTimeline(total);
    
    console.groupEnd();
  }
  
  drawTimeline(duration) {
    const maxWidth = 50;
    const barWidth = Math.min(Math.floor(duration / 20), maxWidth);
    const bar = '█'.repeat(barWidth);
    
    console.log(`Timeline: ${bar} ${duration.toFixed(2)}ms`);
  }
  
  formatBytes(bytes) {
    const sizes = ['B', 'KB', 'MB', 'GB'];
    if (bytes === 0) return '0 B';
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return `${(bytes / Math.pow(1024, i)).toFixed(2)} ${sizes[i]}`;
  }
}

const timelineLogger = new TimelineLogger();
```

### Error Context Logging

```javascript
async function fetchWithErrorContext(url, options = {}) {
  const context = {
    url,
    method: options.method || 'GET',
    timestamp: new Date().toISOString(),
    userAgent: navigator.userAgent,
    online: navigator.onLine,
    connection: navigator.connection ? {
      effectiveType: navigator.connection.effectiveType,
      downlink: navigator.connection.downlink,
      rtt: navigator.connection.rtt
    } : null
  };
  
  try {
    const response = await fetch(url, options);
    
    if (!response.ok) {
      console.group(`%cHTTP Error ${response.status}`, 'color: red; font-weight: bold');
      console.log('URL:', context.url);
      console.log('Method:', context.method);
      console.log('Status:', `${response.status} ${response.statusText}`);
      console.log('Timestamp:', context.timestamp);
      console.log('Online:', context.online);
      
      if (context.connection) {
        console.log('Connection:', context.connection);
      }
      
      console.log('Request Headers:', options.headers || 'None');
      
      try {
        const cloned = response.clone();
        const text = await cloned.text();
        console.log('Response Body:', text);
      } catch {
        console.log('Response Body: (unable to read)');
      }
      
      console.groupEnd();
    }
    
    return response;
  } catch (error) {
    console.group(`%cNetwork Error`, 'color: red; font-weight: bold');
    console.log('Error:', error.name, error.message);
    console.log('URL:', context.url);
    console.log('Method:', context.method);
    console.log('Timestamp:', context.timestamp);
    console.log('Online:', context.online);
    
    if (context.connection) {
      console.log('Connection:', context.connection);
    }
    
    console.log('Error Stack:', error.stack);
    console.groupEnd();
    
    throw error;
  }
}
```

### Aggregated Logging

```javascript
class AggregatedLogger {
  constructor() {
    this.stats = {
      requests: 0,
      successes: 0,
      errors: 0,
      totalDuration: 0,
      byEndpoint: new Map(),
      byStatus: new Map()
    };
  }
  
  async fetch(url, options = {}) {
    const startTime = performance.now();
    const method = options.method || 'GET';
    
    this.stats.requests++;
    
    try {
      const response = await fetch(url, options);
      const duration = performance.now() - startTime;
      
      this.stats.totalDuration += duration;
      
      if (response.ok) {
        this.stats.successes++;
      } else {
        this.stats.errors++;
      }
      
      // Track by endpoint
      const endpoint = `${method} ${new URL(url, location.href).pathname}`;
      const endpointStats = this.stats.byEndpoint.get(endpoint) || {
        count: 0,
        totalDuration: 0,
        successes: 0,
        errors: 0
      };
      endpointStats.count++;
      endpointStats.totalDuration += duration;
      if (response.ok) {
        endpointStats.successes++;
      } else {
        endpointStats.errors++;
      }
      this.stats.byEndpoint.set(endpoint, endpointStats);
      
      // Track by status
      const statusCount = this.stats.byStatus.get(response.status) || 0;
      this.stats.byStatus.set(response.status, statusCount + 1);
      
      return response;
    } catch (error) {
      const duration = performance.now() - startTime;
      this.stats.totalDuration += duration;
      this.stats.errors++;
      
      const endpoint = `${method} ${new URL(url, location.href).pathname}`;
      const endpointStats = this.stats.byEndpoint.get(endpoint) || {
        count: 0,
        totalDuration: 0,
        successes: 0,
        errors: 0
      };
      endpointStats.count++;
      endpointStats.totalDuration += duration;
      endpointStats.errors++;
      this.stats.byEndpoint.set(endpoint, endpointStats);
      
      throw error;
    }
  }
  
  printStats() {
    console.group('Request Statistics');
    
    console.log(`Total Requests: ${this.stats.requests}`);
    console.log(`Successful: ${this.stats.successes}`);
    console.log(`Failed: ${this.stats.errors}`);
    
    const avgDuration = this.stats.requests > 0 
      ? (this.stats.totalDuration / this.stats.requests).toFixed(2)
      : 0;
    console.log(`Average Duration: ${avgDuration}ms`);
    
    console.group('By Endpoint');
    const endpointData = [];
    this.stats.byEndpoint.forEach((stats, endpoint) => {
      const avgDuration = (stats.totalDuration / stats.count).toFixed(2);
      endpointData.push({
        endpoint,
        requests: stats.count,
        successes: stats.successes,
        errors: stats.errors,
        avgDuration: `${avgDuration}ms`
      });
    });
    console.table(endpointData);
    console.groupEnd();
    
    console.group('By Status Code');
    const statusData = [];
    this.stats.byStatus.forEach((count, status) => {
      statusData.push({ status, count });
    });
    console.table(statusData);
    console.groupEnd();
    
    console.groupEnd();
  }
  
  reset() {
    this.stats = {
      requests: 0,
      successes: 0,
      errors: 0,
      totalDuration: 0,
      byEndpoint: new Map(),
      byStatus: new Map()
    };
  }
}

const aggLogger = new AggregatedLogger();
```

### Debug Mode Toggle

```javascript
class DebugFetch {
  constructor() {
    this.debugMode = false;
    this.verbose = false;
  }
  
  enableDebug() {
    this.debugMode = true;
    console.log('%c[DEBUG MODE ENABLED]', 'background: yellow; color: black; font-weight: bold');
  }
  
  disableDebug() {
    this.debugMode = false;
    console.log('%c[DEBUG MODE DISABLED]', 'background: gray; color: white');
  }
  
  enableVerbose() {
    this.verbose = true;
    this.debugMode = true;
    console.log('%c[VERBOSE MODE ENABLED]', 'background: orange; color: white; font-weight: bold');
  }
  
  async fetch(url, options = {}) {
    if (!this.debugMode) {
      return fetch(url, options);
    }
    
    const requestId = Date.now().toString(36);
    const startTime = performance.now();
    
    console.group(`[DEBUG ${requestId}] ${options.method || 'GET'} ${url}`);
    
    if (this.verbose) {
      console.log('Full URL:', url);
      console.log('Options:', JSON.stringify(options, null, 2));
      console.log('Timestamp:', new Date().toISOString());
      console.log('Navigator Online:', navigator.onLine);
      
      if (navigator.connection) {
        console.log('Connection:', {
          effectiveType: navigator.connection.effectiveType,
          downlink: navigator.connection.downlink,
          rtt: navigator.connection.rtt
        });
      }
    }
    
    try {
      const response = await fetch(url, options);
      const duration = (performance.now() - startTime).toFixed(2);
      
      console.log(`Status: ${response.status} ${response.statusText}`);
      console.log(`Duration: ${duration}ms`);
      
      if (this.verbose) {
        console.log('Response Type:', response.type);
        console.log('Redirected:', response.redirected);
        console.log('Headers:');
        response.headers.forEach((value, key) => {
          console.log(`  ${key}: ${value}`);
        });
      }
      
      console.groupEnd();
      return response;
    } catch (error) {
      const duration = (performance.now() - startTime).toFixed(2);
      
      console.error('Error:', error);
      console.log(`Duration: ${duration}ms`);
      
      if (this.verbose) {
        console.error('Error Stack:', error.stack);
      }
      
      console.groupEnd();
      throw error;
    }
  }
}

const debugFetch = new DebugFetch();

// Enable via console
window.enableDebug = () => debugFetch.enableDebug();
window.disableDebug = () => debugFetch.disableDebug();
window.enableVerbose = () => debugFetch.enableVerbose();
```

### Request Tracing

```javascript
class RequestTracer {
  constructor() {
    this.traces = new Map();
    this.traceId = 0;
  }
  
  async fetch(url, options = {}) {
    const traceId = ++this.traceId;
    const trace = {
      id: traceId,
      url,
      method: options.method || 'GET',
      events: []
    };
    
    this.addEvent(trace, 'initiated', { options });
    this.traces.set(traceId, trace);
    
    console.log(`[TRACE ${traceId}] Request initiated: ${trace.method} ${url}`);
    
    try {
      this.addEvent(trace, 'sending');
      const response = await fetch(url, options);
      
      this.addEvent(trace, 'received', { 
        status: response.status,
        statusText: response.statusText,
        headers: Object.fromEntries(response.headers.entries())
      });
      
      console.log(`[TRACE ${traceId}] Response received: ${response.status}`);
      
      return this.wrapResponse(response, trace);
    } catch (error) {
      this.addEvent(trace, 'error', { error: error.message });
      console.error(`[TRACE ${traceId}] Error: ${error.message}`);
      throw error;
    }
  }
  
  wrapResponse(response, trace) {
    const originalJson = response.json.bind(response);
    const originalText = response.text.bind(response);
    const originalBlob = response.blob.bind(response);
    
    response.json = async () => {
      this.addEvent(trace, 'parsing', { type: 'json' });
      const result = await originalJson();
      this.addEvent(trace, 'parsed', { type: 'json' });
      console.log(`[TRACE ${trace.id}] JSON parsed`);
      return result;
    };
    
    response.text = async () => {
      this.addEvent(trace, 'parsing', { type: 'text' });
      const result = await originalText();
      this.addEvent(trace, 'parsed', { type: 'text' });
      console.log(`[TRACE ${trace.id}] Text parsed`);
      return result;
    };
    
    response.blob = async () => {
      this.addEvent(trace, 'parsing', { type: 'blob' });
      const result = await originalBlob();
      this.addEvent(trace, 'parsed', { type: 'blob' });
      console.log(`[TRACE ${trace.id}] Blob parsed`);
      return result;
    };
    
    return response;
  }
  
  addEvent(trace, type, data = {}) {
    trace.events.push({
      type,
      timestamp: performance.now(),
      data
    });
  }
  
  getTrace(traceId) {
    return this.traces.get(traceId);
  }
  
  printTrace(traceId) {
    const trace = this.traces.get(traceId);
    if (!trace) {
      console.warn(`No trace found for ID: ${traceId}`);
      return;
    }
    
    console.group(`Trace #${traceId}: ${trace.method} ${trace.url}`);
    
    const startTime = trace.events[0].timestamp;
    trace.events.forEach((event, index) => {
      const elapsed = (event.timestamp - startTime).toFixed(2);
      console.log(`[+${elapsed}ms] ${event.type}`, event.data);
    });
    
    console.groupEnd();
  }
  
  printAllTraces() {
    console.group('All Request Traces');
    this.traces.forEach((trace, id) => {
      this.printTrace(id);
    });
    console.groupEnd();
  }
}

const tracer = new RequestTracer();
```

### Complete Logging Wrapper

```javascript
class CompleteFetchLogger {
  constructor(config = {}) {
    this.config = {
      enabled: true,
      level: LogLevel.INFO,
      logBodies: false,
      logHeaders: true,
      logPerformance: true,
      logErrors: true,
      groupLogs: true,
      styled: true,
      ...config
    };
    
    this.stats = new AggregatedLogger();
    this.tracer = new RequestTracer();
  }
  
  async fetch(url, options = {}) {
    if (!this.config.enabled) {
      return fetch(url, options);
    }
    
    const requestId = Date.now().toString(36);
    const method = options.method || 'GET';
    const startTime = performance.now();
    
    if (this.config.groupLogs) {
      console.group(this.formatGroupLabel(method, url));
    }
    
    this.logRequest(requestId, url, options);
    
    try {
      const response = await fetch(url, options);
      const duration = performance.now() - startTime;
      
      this.logResponse(requestId, response, duration);
      
      if (this.config.logBodies) {
        await this.logResponseBody(response.clone());
      }
      
      if (this.config.logPerformance) {
        this.stats.fetch(url, options);
      }
      
      if (this.config.groupLogs) {
        console.groupEnd();
      }
      
      return response;
    } catch (error) {
      const duration = performance.now() - startTime;
      
      if (this.config.logErrors) {
        this.logError(requestId, error, duration);
      }
      
      if (this.config.groupLogs) {
        console.groupEnd();
      }
      
      throw error;
    }
  }
  
  formatGroupLabel(method, url) {
    if (this.config.styled) {
      return `%c${method}%c ${url}`;
    }
    return `${method} ${url}`;
  }
  
  logRequest(requestId, url, options) {
    const method = options.method || 'GET';
    
    if (this.config.styled) {
      console.log(
        `%c[${requestId}] →%c ${method} %c${url}`,
        styles.info,
        styles.request,
        styles.info
      );
    } else {
      console.log(`[${requestId}] → ${method} ${url}`);
    }
    
    if (this.config.logHeaders && options.headers) {
      console.log('Request Headers:', options.headers);
    }
    
    if (this.config.logBodies && options.body) {
      console.log('Request Body:', options.body);
    }
  }
  
  logResponse(requestId, response, duration) {
    const statusStyle = response.ok ? styles.success : 
                       response.status >= 400 ? styles.error : 
                       styles.warning;
    
    if (this.config.styled) {
      console.log(
        `%c[${requestId}] ←%c ${response.status} ${response.statusText} %c${duration.toFixed(2)}ms`,
        styles.info,
        statusStyle,
        styles.duration
      );
    } else {
      console.log(
        `[${requestId}] ← ${response.status} ${response.statusText} (${duration.toFixed(2)}ms)`
      );
    }
    
    if (this.config.logHeaders) {
      console.log('Response Headers:', 
        Object.fromEntries(response.headers.entries())
      );
    }
  }
  
  async logResponseBody(response) {
    const contentType = response.headers.get('content-type');
    
    try {
      if (contentType?.includes('application/json')) {
        const data = await response.json();
        console.log('Response Body (JSON):', data);
      } else if (contentType?.includes('text/')) {
        const text = await response.text();
        console.log('Response Body (Text):', text);
      }
    } catch (error) {
      console.warn('Could not log response body:', error);
    }
  }
  
  logError(requestId, error, duration) {
    if (this.config.styled) {
      console.log(
        `%c[${requestId}] ✗%c ${error.message} %c${duration.toFixed(2)}ms`,
        styles.info,
        styles.error,
        styles.duration
      );
    } else {
      console.error(
        `[${requestId}] ✗ ${error.message} (${duration.toFixed(2)}ms)`
      );
    }
    
    console.error('Error Details:', {
      name: error.name,
      message: error.message,
      stack: error.stack
    });
  }
  
  configure(newConfig) {
    this.config = { ...this.config, ...newConfig };
  }
  
  enable() {
    this.config.enabled = true;
  }
  
  disable() {
    this.config.enabled = false;
  }
  
  getStats() {
    return this.stats.stats;
  }
  
  printStats() {
    this.stats.printStats();
  }
  
  reset() {
    this.stats.reset();
  }
}

// Usage
const logger = new CompleteFetchLogger({
  enabled: true,
  level: LogLevel.INFO,
  logBodies: true,
  logHeaders: true,
  logPerformance: true,
  styled: true
});

// Use it
await logger.fetch('/api/data');

// Configure on the fly
logger.configure({ logBodies: false });

// Disable in production
if (location.hostname !== 'localhost') {
  logger.disable();
}

// Print statistics
logger.printStats();
```

---

