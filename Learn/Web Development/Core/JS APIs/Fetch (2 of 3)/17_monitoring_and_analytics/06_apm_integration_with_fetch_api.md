## APM Integration with Fetch API


### Instrumentation Approaches

APM (Application Performance Monitoring) systems instrument fetch requests to collect timing data, error rates, and distributed traces. Most APM agents intercept fetch by wrapping or replacing the global `fetch` function before application code executes.

```javascript
const originalFetch = window.fetch;
window.fetch = function(...args) {
  const startTime = performance.now();
  const span = apm.startSpan('HTTP Request');
  
  return originalFetch.apply(this, args)
    .then(response => {
      span.setHttpStatus(response.status);
      span.end(performance.now() - startTime);
      return response;
    })
    .catch(error => {
      span.recordError(error);
      span.end(performance.now() - startTime);
      throw error;
    });
};
```

### Trace Context Propagation

Distributed tracing requires propagating trace context across service boundaries through HTTP headers. APM agents inject trace identifiers following W3C Trace Context or vendor-specific formats.

```javascript
function instrumentedFetch(url, options = {}) {
  const traceHeaders = {
    'traceparent': `00-${traceId}-${spanId}-01`,
    'tracestate': `vendor=value`,
  };
  
  const headers = new Headers(options.headers);
  Object.entries(traceHeaders).forEach(([key, value]) => {
    headers.set(key, value);
  });
  
  return fetch(url, {
    ...options,
    headers
  });
}
```

### Performance Metrics Collection

APM systems extract multiple timing metrics from fetch requests using the Resource Timing API and internal span measurements.

```javascript
async function trackedFetch(url, options) {
  const resourceName = new URL(url, location.href).href;
  const span = {
    name: resourceName,
    startTime: performance.now(),
    attributes: {
      'http.method': options?.method || 'GET',
      'http.url': resourceName,
    }
  };
  
  try {
    const response = await fetch(url, options);
    
    span.attributes['http.status_code'] = response.status;
    span.attributes['http.response_content_length'] = 
      response.headers.get('content-length');
    
    // Extract Resource Timing entry
    const entries = performance.getEntriesByName(resourceName, 'resource');
    if (entries.length > 0) {
      const timing = entries[entries.length - 1];
      span.metrics = {
        dns: timing.domainLookupEnd - timing.domainLookupStart,
        tcp: timing.connectEnd - timing.connectStart,
        tls: timing.requestStart - timing.secureConnectionStart,
        ttfb: timing.responseStart - timing.requestStart,
        download: timing.responseEnd - timing.responseStart,
        total: timing.responseEnd - timing.fetchStart
      };
    }
    
    span.endTime = performance.now();
    apm.recordSpan(span);
    
    return response;
  } catch (error) {
    span.error = {
      message: error.message,
      type: error.name,
      stack: error.stack
    };
    span.endTime = performance.now();
    apm.recordSpan(span);
    throw error;
  }
}
```

### Request and Response Body Capture

APM agents may capture request/response bodies for debugging, typically with size limits and content-type filtering to avoid capturing binary data or sensitive information.

```javascript
function captureBody(request, options) {
  const contentType = request.headers.get('content-type') || '';
  const maxSize = 10000; // bytes
  
  if (!contentType.includes('application/json') && 
      !contentType.includes('text/')) {
    return null;
  }
  
  if (options.body) {
    if (typeof options.body === 'string') {
      return options.body.substring(0, maxSize);
    }
    if (options.body instanceof FormData) {
      const entries = {};
      for (const [key, value] of options.body.entries()) {
        entries[key] = typeof value === 'string' ? value : '[File]';
      }
      return JSON.stringify(entries).substring(0, maxSize);
    }
  }
  
  return null;
}

async function captureResponse(response) {
  const contentType = response.headers.get('content-type') || '';
  const contentLength = parseInt(response.headers.get('content-length') || '0');
  
  if (contentLength > 10000 || 
      (!contentType.includes('application/json') && 
       !contentType.includes('text/'))) {
    return null;
  }
  
  const cloned = response.clone();
  try {
    const text = await cloned.text();
    return text;
  } catch {
    return null;
  }
}
```

### Error Classification and Sampling

APM systems classify errors by status code ranges and implement sampling strategies to reduce data volume while maintaining statistical significance.

```javascript
class APMSampler {
  constructor(config) {
    this.successRate = config.successRate || 0.1;
    this.errorRate = config.errorRate || 1.0;
    this.slowThreshold = config.slowThreshold || 1000;
    this.slowRate = config.slowRate || 1.0;
  }
  
  shouldSample(span) {
    // Always sample errors
    if (span.error || span.attributes['http.status_code'] >= 400) {
      return Math.random() < this.errorRate;
    }
    
    // Always sample slow requests
    const duration = span.endTime - span.startTime;
    if (duration > this.slowThreshold) {
      return Math.random() < this.slowRate;
    }
    
    // Sample successful requests at lower rate
    return Math.random() < this.successRate;
  }
  
  classifyError(statusCode) {
    if (statusCode >= 500) return 'server_error';
    if (statusCode >= 400) return 'client_error';
    if (statusCode >= 300) return 'redirect';
    return 'success';
  }
}
```

### Correlation with User Actions

APM agents correlate fetch requests with user interactions (clicks, page loads, route changes) to understand user experience impact.

```javascript
class UserActionTracer {
  constructor() {
    this.currentAction = null;
    this.setupInteractionListeners();
  }
  
  setupInteractionListeners() {
    ['click', 'submit', 'change'].forEach(eventType => {
      document.addEventListener(eventType, (e) => {
        this.currentAction = {
          type: eventType,
          target: this.getElementIdentifier(e.target),
          timestamp: Date.now(),
          id: this.generateId()
        };
      }, true);
    });
  }
  
  getElementIdentifier(element) {
    return element.id || 
           element.name || 
           element.className || 
           element.tagName;
  }
  
  attachToSpan(span) {
    if (this.currentAction && 
        (Date.now() - this.currentAction.timestamp) < 5000) {
      span.attributes['user.action'] = this.currentAction.type;
      span.attributes['user.action.target'] = this.currentAction.target;
      span.attributes['user.action.id'] = this.currentAction.id;
    }
  }
  
  generateId() {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }
}
```

### Automatic Span Naming

APM systems generate meaningful span names from URLs, removing sensitive data and applying normalization rules.

```javascript
class SpanNamer {
  constructor(config = {}) {
    this.urlPatterns = config.urlPatterns || [];
    this.stripQuery = config.stripQuery !== false;
    this.stripHash = config.stripHash !== false;
  }
  
  generateName(url, method = 'GET') {
    try {
      const parsed = new URL(url, location.href);
      let pathname = parsed.pathname;
      
      // Apply URL patterns to normalize dynamic segments
      for (const pattern of this.urlPatterns) {
        if (pattern.regex.test(pathname)) {
          pathname = pathname.replace(pattern.regex, pattern.replacement);
          break;
        }
      }
      
      // Build span name
      const parts = [method];
      
      if (parsed.hostname !== location.hostname) {
        parts.push(parsed.hostname);
      }
      
      parts.push(pathname);
      
      return parts.join(' ');
    } catch {
      return `${method} ${url}`;
    }
  }
  
  addPattern(regex, replacement) {
    this.urlPatterns.push({ regex, replacement });
  }
}

// Usage
const namer = new SpanNamer();
namer.addPattern(/\/users\/\d+/, '/users/:id');
namer.addPattern(/\/posts\/[a-f0-9-]+/, '/posts/:uuid');

// "GET /users/123" -> "GET /users/:id"
// "POST api.example.com/posts/abc-123" -> "POST api.example.com/posts/:uuid"
```

### Memory and Performance Overhead Management

APM instrumentation must minimize overhead to avoid impacting application performance. [Inference: APM vendors typically target <5% overhead]

```javascript
class LowOverheadAPM {
  constructor() {
    this.queue = [];
    this.maxQueueSize = 100;
    this.flushInterval = 10000; // 10 seconds
    this.setupPeriodicFlush();
  }
  
  recordSpan(span) {
    // Avoid blocking main thread
    if (this.queue.length >= this.maxQueueSize) {
      this.queue.shift(); // Drop oldest span
    }
    
    this.queue.push(this.serializeSpan(span));
    
    // Flush if queue is nearly full
    if (this.queue.length >= this.maxQueueSize * 0.8) {
      this.flush();
    }
  }
  
  serializeSpan(span) {
    // Minimize object size
    return {
      n: span.name,
      s: span.startTime,
      d: span.endTime - span.startTime,
      a: this.compressAttributes(span.attributes),
      e: span.error ? { m: span.error.message, t: span.error.type } : undefined
    };
  }
  
  compressAttributes(attrs) {
    const compressed = {};
    const keyMap = {
      'http.method': 'm',
      'http.status_code': 's',
      'http.url': 'u'
    };
    
    for (const [key, value] of Object.entries(attrs)) {
      compressed[keyMap[key] || key] = value;
    }
    
    return compressed;
  }
  
  setupPeriodicFlush() {
    setInterval(() => this.flush(), this.flushInterval);
  }
  
  async flush() {
    if (this.queue.length === 0) return;
    
    const batch = this.queue.splice(0, this.maxQueueSize);
    
    // Use sendBeacon for reliability during page unload
    if (navigator.sendBeacon) {
      navigator.sendBeacon('/apm/spans', JSON.stringify(batch));
    } else {
      // Fallback to fetch with keepalive
      fetch('/apm/spans', {
        method: 'POST',
        body: JSON.stringify(batch),
        headers: { 'Content-Type': 'application/json' },
        keepalive: true
      }).catch(() => {}); // Silent failure
    }
  }
}
```

### Integration with Service Workers

Fetch requests from service workers require separate instrumentation since they execute in a different context.

```javascript
// In service worker
self.addEventListener('fetch', (event) => {
  const startTime = performance.now();
  
  event.respondWith(
    (async () => {
      try {
        const response = await fetch(event.request);
        
        // Record successful fetch
        self.clients.matchAll().then(clients => {
          clients.forEach(client => {
            client.postMessage({
              type: 'apm_span',
              span: {
                name: `SW ${event.request.method} ${event.request.url}`,
                duration: performance.now() - startTime,
                status: response.status,
                context: 'service_worker'
              }
            });
          });
        });
        
        return response;
      } catch (error) {
        // Record error
        self.clients.matchAll().then(clients => {
          clients.forEach(client => {
            client.postMessage({
              type: 'apm_span',
              span: {
                name: `SW ${event.request.method} ${event.request.url}`,
                duration: performance.now() - startTime,
                error: error.message,
                context: 'service_worker'
              }
            });
          });
        });
        
        throw error;
      }
    })()
  );
});

// In main thread
navigator.serviceWorker.addEventListener('message', (event) => {
  if (event.data.type === 'apm_span') {
    apm.recordSpan(event.data.span);
  }
});
```

### Custom Attributes and Tags

APM agents allow applications to add custom metadata to spans for business-specific tracking.

```javascript
class ExtensibleAPM {
  constructor() {
    this.globalAttributes = {};
    this.attributeProcessors = [];
  }
  
  setGlobalAttribute(key, value) {
    this.globalAttributes[key] = value;
  }
  
  addAttributeProcessor(processor) {
    this.attributeProcessors.push(processor);
  }
  
  async trackedFetch(url, options = {}) {
    const span = this.createSpan(url, options);
    
    // Apply custom attributes from options
    if (options.apmAttributes) {
      Object.assign(span.attributes, options.apmAttributes);
    }
    
    // Apply global attributes
    Object.assign(span.attributes, this.globalAttributes);
    
    // Run attribute processors
    for (const processor of this.attributeProcessors) {
      await processor(span, url, options);
    }
    
    try {
      const response = await fetch(url, options);
      span.attributes['http.status_code'] = response.status;
      span.endTime = performance.now();
      this.recordSpan(span);
      return response;
    } catch (error) {
      span.error = error;
      span.endTime = performance.now();
      this.recordSpan(span);
      throw error;
    }
  }
}

// Usage
const apm = new ExtensibleAPM();

// Set global context
apm.setGlobalAttribute('user.id', currentUserId);
apm.setGlobalAttribute('app.version', '1.2.3');

// Add custom processor
apm.addAttributeProcessor((span, url, options) => {
  if (url.includes('/api/')) {
    span.attributes['api.version'] = 'v2';
  }
  
  if (options.body) {
    try {
      const body = JSON.parse(options.body);
      span.attributes['request.type'] = body.type;
    } catch {}
  }
});

// Make tracked request with custom attributes
apm.trackedFetch('/api/orders', {
  method: 'POST',
  body: JSON.stringify({ type: 'purchase' }),
  apmAttributes: {
    'business.order_type': 'premium',
    'business.customer_segment': 'enterprise'
  }
});
```

### Integration with Real User Monitoring (RUM)

APM fetch instrumentation feeds into broader RUM metrics, correlating backend performance with frontend user experience.

```javascript
class RUMIntegration {
  constructor() {
    this.pageLoadId = this.generateId();
    this.fetchCount = 0;
    this.totalFetchTime = 0;
    this.errors = [];
  }
  
  instrumentFetch() {
    const originalFetch = window.fetch;
    
    window.fetch = async (...args) => {
      const fetchId = this.fetchCount++;
      const startTime = performance.now();
      
      try {
        const response = await originalFetch(...args);
        const duration = performance.now() - startTime;
        
        this.totalFetchTime += duration;
        
        this.recordRUMMetric({
          type: 'fetch',
          pageLoadId: this.pageLoadId,
          fetchId,
          duration,
          status: response.status,
          url: args[0],
          timestamp: Date.now()
        });
        
        return response;
      } catch (error) {
        const duration = performance.now() - startTime;
        
        this.errors.push({
          fetchId,
          error: error.message,
          url: args[0]
        });
        
        this.recordRUMMetric({
          type: 'fetch_error',
          pageLoadId: this.pageLoadId,
          fetchId,
          duration,
          error: error.message,
          url: args[0],
          timestamp: Date.now()
        });
        
        throw error;
      }
    };
  }
  
  recordRUMMetric(metric) {
    // Send to RUM collector
    navigator.sendBeacon('/rum/metrics', JSON.stringify(metric));
  }
  
  getPageMetrics() {
    return {
      pageLoadId: this.pageLoadId,
      totalFetches: this.fetchCount,
      totalFetchTime: this.totalFetchTime,
      errorCount: this.errors.length,
      avgFetchTime: this.fetchCount > 0 ? 
        this.totalFetchTime / this.fetchCount : 0
    };
  }
  
  generateId() {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }
}
```

### Vendor-Specific Implementations

Different APM vendors have varying instrumentation patterns, though most follow similar core concepts.

```javascript
// Example: OpenTelemetry-style instrumentation
class OTelFetchInstrumentation {
  constructor(tracer) {
    this.tracer = tracer;
  }
  
  instrument() {
    const originalFetch = window.fetch;
    const tracer = this.tracer;
    
    window.fetch = function(input, init = {}) {
      const url = typeof input === 'string' ? input : input.url;
      const method = init.method || 'GET';
      
      return tracer.startActiveSpan(`HTTP ${method}`, (span) => {
        span.setAttribute('http.method', method);
        span.setAttribute('http.url', url);
        span.setAttribute('http.target', new URL(url, location.href).pathname);
        
        // Inject trace context
        const headers = new Headers(init.headers);
        tracer.inject(span.spanContext(), headers);
        
        return originalFetch(input, { ...init, headers })
          .then(response => {
            span.setAttribute('http.status_code', response.status);
            
            if (response.status >= 400) {
              span.setStatus({ 
                code: 2, // ERROR
                message: `HTTP ${response.status}` 
              });
            }
            
            span.end();
            return response;
          })
          .catch(error => {
            span.recordException(error);
            span.setStatus({ code: 2, message: error.message });
            span.end();
            throw error;
          });
      });
    };
  }
}
```

### Performance Budget Integration

APM data can trigger alerts when fetch performance degrades beyond acceptable thresholds.

```javascript
class PerformanceBudgetMonitor {
  constructor(budgets) {
    this.budgets = budgets;
    this.violations = [];
    this.windowSize = 50; // Track last 50 requests per endpoint
    this.endpointStats = new Map();
  }
  
  recordFetch(url, duration, status) {
    const endpoint = this.normalizeEndpoint(url);
    
    if (!this.endpointStats.has(endpoint)) {
      this.endpointStats.set(endpoint, []);
    }
    
    const stats = this.endpointStats.get(endpoint);
    stats.push({ duration, status, timestamp: Date.now() });
    
    // Keep only recent requests
    if (stats.length > this.windowSize) {
      stats.shift();
    }
    
    // Check budgets
    this.checkBudgets(endpoint, stats);
  }
  
  checkBudgets(endpoint, stats) {
    const budget = this.budgets[endpoint] || this.budgets['*'];
    if (!budget) return;
    
    const recentStats = stats.slice(-20); // Last 20 requests
    const avgDuration = recentStats.reduce((sum, s) => sum + s.duration, 0) / 
                        recentStats.length;
    const errorRate = recentStats.filter(s => s.status >= 400).length / 
                      recentStats.length;
    
    if (avgDuration > budget.maxAvgDuration) {
      this.recordViolation({
        type: 'duration',
        endpoint,
        value: avgDuration,
        budget: budget.maxAvgDuration
      });
    }
    
    if (errorRate > budget.maxErrorRate) {
      this.recordViolation({
        type: 'error_rate',
        endpoint,
        value: errorRate,
        budget: budget.maxErrorRate
      });
    }
  }
  
  recordViolation(violation) {
    this.violations.push({ ...violation, timestamp: Date.now() });
    
    // Trigger alert
    this.sendAlert(violation);
  }
  
  sendAlert(violation) {
    fetch('/apm/alerts', {
      method: 'POST',
      body: JSON.stringify(violation),
      headers: { 'Content-Type': 'application/json' },
      keepalive: true
    });
  }
  
  normalizeEndpoint(url) {
    try {
      const parsed = new URL(url, location.href);
      return parsed.pathname.replace(/\/\d+/g, '/:id')
                           .replace(/\/[a-f0-9-]{36}/g, '/:uuid');
    } catch {
      return url;
    }
  }
}

// Usage
const monitor = new PerformanceBudgetMonitor({
  '/api/users/:id': {
    maxAvgDuration: 200,
    maxErrorRate: 0.01
  },
  '/api/orders': {
    maxAvgDuration: 500,
    maxErrorRate: 0.05
  },
  '*': {
    maxAvgDuration: 1000,
    maxErrorRate: 0.1
  }
});
```

---

