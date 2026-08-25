## HAR File Analysis


### Structure and Components

HAR (HTTP Archive) files use JSON format conforming to the HAR 1.2 specification. The root structure contains metadata and an array of page loads with their associated network requests.

**Root Structure:**

```json
{
  "log": {
    "version": "1.2",
    "creator": {
      "name": "Browser DevTools",
      "version": "1.0"
    },
    "browser": {
      "name": "Chrome",
      "version": "120.0.0"
    },
    "pages": [],
    "entries": []
  }
}
```

### Pages Array

Contains metadata about page loads and navigation events.

**Page Object:**

```json
{
  "startedDateTime": "2024-01-15T10:30:00.000Z",
  "id": "page_1",
  "title": "Example Page",
  "pageTimings": {
    "onContentLoad": 1240,
    "onLoad": 2350
  }
}
```

**Key Fields:**

- `startedDateTime`: ISO 8601 timestamp of page load initiation
- `id`: Unique identifier linking entries to pages
- `pageTimings.onContentLoad`: DOMContentLoaded event timing (milliseconds)
- `pageTimings.onLoad`: Window load event timing (milliseconds)

### Entries Array

Core component containing individual HTTP request/response pairs.

**Entry Structure:**

```json
{
  "pageref": "page_1",
  "startedDateTime": "2024-01-15T10:30:00.123Z",
  "time": 245.67,
  "request": {},
  "response": {},
  "cache": {},
  "timings": {},
  "serverIPAddress": "93.184.216.34",
  "connection": "443"
}
```

**Entry Fields:**

- `pageref`: Links entry to specific page load
- `time`: Total request duration in milliseconds
- `serverIPAddress`: Resolved IP address of the server
- `connection`: Port number or connection identifier

### Request Object

**Complete Structure:**

```json
{
  "method": "GET",
  "url": "https://example.com/api/data",
  "httpVersion": "HTTP/2",
  "headers": [
    {
      "name": "User-Agent",
      "value": "Mozilla/5.0..."
    }
  ],
  "queryString": [
    {
      "name": "id",
      "value": "123"
    }
  ],
  "cookies": [
    {
      "name": "session",
      "value": "abc123",
      "path": "/",
      "domain": ".example.com",
      "expires": "2024-12-31T23:59:59.000Z",
      "httpOnly": true,
      "secure": true
    }
  ],
  "headersSize": 432,
  "bodySize": 0,
  "postData": {
    "mimeType": "application/json",
    "text": "{\"key\":\"value\"}"
  }
}
```

**Headers Analysis:**

- Array of name-value pairs
- Case-insensitive header names
- Multiple headers with same name possible
- `headersSize`: Total bytes of headers including HTTP line

**Query Parameters:**

- Parsed from URL query string
- Decoded values
- Preserves parameter order

**POST Data:**

- `mimeType`: Content-Type of request body
- `text`: Request body as string
- `params`: Form data parsed into name-value pairs (for application/x-www-form-urlencoded)

### Response Object

**Complete Structure:**

```json
{
  "status": 200,
  "statusText": "OK",
  "httpVersion": "HTTP/2",
  "headers": [
    {
      "name": "Content-Type",
      "value": "application/json"
    }
  ],
  "cookies": [],
  "content": {
    "size": 1234,
    "compression": 800,
    "mimeType": "application/json",
    "text": "{\"data\":\"value\"}",
    "encoding": "base64"
  },
  "redirectURL": "",
  "headersSize": 256,
  "bodySize": 1234,
  "_transferSize": 434
}
```

**Content Object:**

- `size`: Uncompressed response body size in bytes
- `compression`: Bytes saved through compression (size - bodySize)
- `text`: Response body content
- `encoding`: Encoding of text field (typically "base64" for binary content)
- `mimeType`: Content-Type from response headers

**Transfer Metrics:**

- `headersSize`: Bytes of response headers
- `bodySize`: Compressed response body size
- `_transferSize`: Actual bytes transferred over network (non-standard field)

### Timing Object

Detailed breakdown of request phases following Resource Timing API specification.

**Complete Timing Structure:**

```json
{
  "blocked": 2.34,
  "dns": 15.67,
  "connect": 45.23,
  "send": 0.12,
  "wait": 120.45,
  "receive": 62.11,
  "ssl": 30.89
}
```

**Timing Phases:**

1. **blocked** (`-1` or positive milliseconds)
    
    - Time spent in browser queue before request starts
    - Includes waiting for available connection slot
    - `-1` indicates timing not available
2. **dns** (`-1` or ≥0 milliseconds)
    
    - DNS lookup duration
    - `0` for cached DNS entries
    - `-1` if already resolved or not applicable
3. **connect** (`-1` or ≥0 milliseconds)
    
    - TCP connection establishment time
    - Includes TCP handshake
    - `0` for reused connections
    - Includes `ssl` time when HTTPS
4. **ssl** (`-1` or ≥0 milliseconds)
    
    - TLS/SSL handshake duration
    - Only present for HTTPS connections
    - `-1` for HTTP or reused SSL sessions
5. **send** (≥0 milliseconds)
    
    - Time to transmit request to server
    - Typically very small for GET requests
    - Larger for POST/PUT with request bodies
6. **wait** (≥0 milliseconds)
    
    - Time from last byte sent until first byte received (TTFB - Time To First Byte)
    - Server processing time
    - Most critical metric for backend performance
7. **receive** (≥0 milliseconds)
    
    - Time to download response body
    - From first byte to last byte received
    - Affected by bandwidth and payload size

**Total Time Calculation:**

```
time = blocked + dns + connect + send + wait + receive
```

### Cache Object

**Structure:**

```json
{
  "beforeRequest": {
    "lastAccess": "2024-01-15T10:25:00.000Z",
    "eTag": "\"abc123\"",
    "hitCount": 5
  },
  "afterRequest": {
    "lastAccess": "2024-01-15T10:30:00.000Z",
    "eTag": "\"abc123\"",
    "hitCount": 6
  }
}
```

**Cache States:**

- Both objects empty: Cache miss, resource fetched from server
- `beforeRequest` populated: Resource was in cache before request
- `afterRequest` populated: Resource cached after request
- `eTag` matching: Cache validation occurred

### Performance Analysis Techniques

**Waterfall Generation:**

Calculate start time relative to first request:

```javascript
function generateWaterfall(entries) {
  const firstStart = new Date(entries[0].startedDateTime).getTime();
  
  return entries.map(entry => {
    const start = new Date(entry.startedDateTime).getTime();
    const relativeStart = start - firstStart;
    
    return {
      url: entry.request.url,
      start: relativeStart,
      duration: entry.time,
      timings: entry.timings
    };
  });
}
```

**Identifying Bottlenecks:**

```javascript
function findSlowRequests(entries, threshold = 1000) {
  return entries
    .filter(entry => entry.time > threshold)
    .map(entry => ({
      url: entry.request.url,
      duration: entry.time,
      wait: entry.timings.wait,
      size: entry.response.content.size
    }))
    .sort((a, b) => b.duration - a.duration);
}
```

**DNS Performance:**

```javascript
function analyzeDNS(entries) {
  const dnsLookups = entries
    .filter(entry => entry.timings.dns > 0)
    .map(entry => ({
      domain: new URL(entry.request.url).hostname,
      duration: entry.timings.dns
    }));
  
  const byDomain = dnsLookups.reduce((acc, lookup) => {
    if (!acc[lookup.domain]) {
      acc[lookup.domain] = [];
    }
    acc[lookup.domain].push(lookup.duration);
    return acc;
  }, {});
  
  return Object.entries(byDomain).map(([domain, durations]) => ({
    domain,
    count: durations.length,
    avgDuration: durations.reduce((a, b) => a + b) / durations.length
  }));
}
```

**Connection Reuse Analysis:**

```javascript
function analyzeConnectionReuse(entries) {
  const connections = entries.reduce((acc, entry) => {
    const key = `${entry.serverIPAddress}:${entry.connection}`;
    if (!acc[key]) {
      acc[key] = {
        ip: entry.serverIPAddress,
        port: entry.connection,
        requests: [],
        newConnections: 0
      };
    }
    
    acc[key].requests.push(entry);
    if (entry.timings.connect > 0) {
      acc[key].newConnections++;
    }
    
    return acc;
  }, {});
  
  return Object.values(connections).map(conn => ({
    ...conn,
    reuseRatio: 1 - (conn.newConnections / conn.requests.length)
  }));
}
```

### Resource Type Classification

**By MIME Type:**

```javascript
function classifyResources(entries) {
  const types = {
    html: [],
    css: [],
    javascript: [],
    images: [],
    fonts: [],
    api: [],
    other: []
  };
  
  entries.forEach(entry => {
    const mimeType = entry.response.content.mimeType.toLowerCase();
    
    if (mimeType.includes('text/html')) {
      types.html.push(entry);
    } else if (mimeType.includes('text/css')) {
      types.css.push(entry);
    } else if (mimeType.includes('javascript')) {
      types.javascript.push(entry);
    } else if (mimeType.includes('image/')) {
      types.images.push(entry);
    } else if (mimeType.includes('font')) {
      types.fonts.push(entry);
    } else if (mimeType.includes('application/json') || mimeType.includes('application/xml')) {
      types.api.push(entry);
    } else {
      types.other.push(entry);
    }
  });
  
  return types;
}
```

**Size Analysis by Type:**

```javascript
function analyzeSizeByType(entries) {
  const classified = classifyResources(entries);
  
  return Object.entries(classified).map(([type, resources]) => {
    const totalSize = resources.reduce((sum, r) => sum + r.response.content.size, 0);
    const transferSize = resources.reduce((sum, r) => sum + r.response.bodySize, 0);
    const compressionRatio = totalSize > 0 ? (1 - transferSize / totalSize) : 0;
    
    return {
      type,
      count: resources.length,
      totalSize,
      transferSize,
      compressionRatio: compressionRatio.toFixed(2)
    };
  });
}
```

### HTTP Version Analysis

```javascript
function analyzeHTTPVersions(entries) {
  const versions = entries.reduce((acc, entry) => {
    const version = entry.request.httpVersion;
    if (!acc[version]) {
      acc[version] = {
        count: 0,
        totalTime: 0,
        avgTime: 0
      };
    }
    
    acc[version].count++;
    acc[version].totalTime += entry.time;
    
    return acc;
  }, {});
  
  Object.values(versions).forEach(v => {
    v.avgTime = v.totalTime / v.count;
  });
  
  return versions;
}
```

### Cache Hit Analysis

**Identifying Cache Behavior:**

```javascript
function analyzeCacheHits(entries) {
  const cacheStats = {
    hits: 0,
    misses: 0,
    validations: 0,
    fromCache: []
  };
  
  entries.forEach(entry => {
    // Cache hit: 304 Not Modified
    if (entry.response.status === 304) {
      cacheStats.validations++;
    }
    // Served from cache: no network time
    else if (entry.timings.send === -1 && entry.timings.wait === -1) {
      cacheStats.hits++;
      cacheStats.fromCache.push(entry.request.url);
    }
    // Cache validation with beforeRequest data
    else if (entry.cache.beforeRequest && Object.keys(entry.cache.beforeRequest).length > 0) {
      cacheStats.validations++;
    }
    // Cache miss
    else {
      cacheStats.misses++;
    }
  });
  
  cacheStats.hitRate = cacheStats.hits / entries.length;
  
  return cacheStats;
}
```

### Third-Party Domain Analysis

```javascript
function analyzeThirdPartyDomains(entries, primaryDomain) {
  const domains = entries.reduce((acc, entry) => {
    const url = new URL(entry.request.url);
    const domain = url.hostname;
    const isThirdParty = !domain.includes(primaryDomain);
    
    if (!acc[domain]) {
      acc[domain] = {
        domain,
        isThirdParty,
        requests: [],
        totalSize: 0,
        totalTime: 0
      };
    }
    
    acc[domain].requests.push(entry);
    acc[domain].totalSize += entry.response.content.size;
    acc[domain].totalTime += entry.time;
    
    return acc;
  }, {});
  
  return Object.values(domains)
    .sort((a, b) => b.totalSize - a.totalSize);
}
```

### Response Header Analysis

**Security Headers:**

```javascript
function analyzeSecurityHeaders(entries) {
  const securityHeaders = [
    'strict-transport-security',
    'content-security-policy',
    'x-frame-options',
    'x-content-type-options',
    'referrer-policy',
    'permissions-policy'
  ];
  
  return entries.map(entry => {
    const headers = entry.response.headers.reduce((acc, h) => {
      acc[h.name.toLowerCase()] = h.value;
      return acc;
    }, {});
    
    const missing = securityHeaders.filter(h => !headers[h]);
    
    return {
      url: entry.request.url,
      presentHeaders: securityHeaders.filter(h => headers[h]),
      missingHeaders: missing
    };
  });
}
```

**Caching Headers:**

```javascript
function analyzeCachingHeaders(entries) {
  return entries.map(entry => {
    const headers = entry.response.headers.reduce((acc, h) => {
      acc[h.name.toLowerCase()] = h.value;
      return acc;
    }, {});
    
    const cacheControl = headers['cache-control'] || '';
    const expires = headers['expires'] || '';
    const etag = headers['etag'] || '';
    const lastModified = headers['last-modified'] || '';
    
    return {
      url: entry.request.url,
      cacheControl,
      expires,
      etag,
      lastModified,
      isCacheable: cacheControl.includes('max-age') || expires !== ''
    };
  });
}
```

### Compression Analysis

```javascript
function analyzeCompression(entries) {
  return entries
    .filter(entry => entry.response.content.compression !== undefined)
    .map(entry => {
      const content = entry.response.content;
      const originalSize = content.size;
      const compressedSize = entry.response.bodySize;
      const savings = originalSize - compressedSize;
      const ratio = originalSize > 0 ? (savings / originalSize) : 0;
      
      const encoding = entry.response.headers
        .find(h => h.name.toLowerCase() === 'content-encoding')?.value || 'none';
      
      return {
        url: entry.request.url,
        mimeType: content.mimeType,
        originalSize,
        compressedSize,
        savings,
        ratio: ratio.toFixed(2),
        encoding
      };
    })
    .sort((a, b) => b.savings - a.savings);
}
```

### Request Priority Analysis

Many browsers include priority hints in HAR files (non-standard field).

```javascript
function analyzePriorities(entries) {
  const withPriority = entries.filter(e => e._priority);
  
  const byPriority = withPriority.reduce((acc, entry) => {
    const priority = entry._priority;
    if (!acc[priority]) {
      acc[priority] = {
        count: 0,
        resources: []
      };
    }
    
    acc[priority].count++;
    acc[priority].resources.push({
      url: entry.request.url,
      type: entry.response.content.mimeType,
      startTime: entry.startedDateTime
    });
    
    return acc;
  }, {});
  
  return byPriority;
}
```

### Cookie Analysis

**Size and Count:**

```javascript
function analyzeCookies(entries) {
  const cookieStats = entries.map(entry => {
    const requestCookies = entry.request.cookies;
    const responseCookies = entry.response.cookies;
    
    const requestCookieSize = requestCookies.reduce((sum, c) => {
      return sum + c.name.length + c.value.length;
    }, 0);
    
    return {
      url: entry.request.url,
      requestCookieCount: requestCookies.length,
      requestCookieSize,
      responseCookieCount: responseCookies.length,
      setCookies: responseCookies.map(c => ({
        name: c.name,
        httpOnly: c.httpOnly,
        secure: c.secure,
        sameSite: c.sameSite
      }))
    };
  });
  
  return cookieStats;
}
```

### Redirect Chain Analysis

```javascript
function analyzeRedirects(entries) {
  const chains = [];
  const processed = new Set();
  
  entries.forEach((entry, index) => {
    if (processed.has(index)) return;
    
    const status = entry.response.status;
    if (status >= 300 && status < 400) {
      const chain = [entry];
      processed.add(index);
      
      let redirectURL = entry.response.redirectURL;
      while (redirectURL) {
        const nextEntry = entries.find((e, i) => {
          if (processed.has(i)) return false;
          if (e.request.url === redirectURL) {
            processed.add(i);
            return true;
          }
          return false;
        });
        
        if (nextEntry) {
          chain.push(nextEntry);
          redirectURL = nextEntry.response.redirectURL;
        } else {
          break;
        }
      }
      
      if (chain.length > 1) {
        chains.push({
          length: chain.length,
          totalTime: chain.reduce((sum, e) => sum + e.time, 0),
          urls: chain.map(e => e.request.url),
          statuses: chain.map(e => e.response.status)
        });
      }
    }
  });
  
  return chains;
}
```

### Failed Request Analysis

```javascript
function analyzeFailures(entries) {
  const failures = entries.filter(entry => {
    const status = entry.response.status;
    return status >= 400 || status === 0;
  });
  
  return failures.map(entry => ({
    url: entry.request.url,
    status: entry.response.status,
    statusText: entry.response.statusText,
    method: entry.request.method,
    time: entry.time,
    errorDetails: entry._error || null
  }));
}
```

### Custom Fields

HAR files often contain browser-specific or tool-specific fields prefixed with underscore.

**Common Custom Fields:**

- `_priority`: Resource loading priority (Chrome)
- `_initiator`: What triggered the request (Chrome)
- `_resourceType`: Resource category (Chrome)
- `_transferSize`: Actual network transfer size
- `_error`: Error details for failed requests

**Parsing Custom Fields:**

```javascript
function extractCustomFields(entry) {
  const custom = {};
  
  Object.keys(entry).forEach(key => {
    if (key.startsWith('_')) {
      custom[key] = entry[key];
    }
  });
  
  return custom;
}
```

### Reading HAR Files

**Browser-based Parsing:**

```javascript
async function parseHAR(file) {
  const text = await file.text();
  const har = JSON.parse(text);
  
  return {
    version: har.log.version,
    creator: har.log.creator,
    browser: har.log.browser,
    pages: har.log.pages,
    entries: har.log.entries
  };
}
```

**Node.js Parsing:**

```javascript
const fs = require('fs').promises;

async function loadHAR(filepath) {
  const content = await fs.readFile(filepath, 'utf-8');
  const har = JSON.parse(content);
  return har.log;
}
```

### Generating HAR Files Programmatically

**Using Puppeteer:**

```javascript
const puppeteer = require('puppeteer');

async function captureHAR(url) {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  await page.tracing.start({
    path: 'trace.json',
    screenshots: false
  });
  
  const client = await page.target().createCDPSession();
  await client.send('Network.enable');
  
  const entries = [];
  
  client.on('Network.requestWillBeSent', (params) => {
    // Capture request details
  });
  
  client.on('Network.responseReceived', (params) => {
    // Capture response details
  });
  
  await page.goto(url, { waitUntil: 'networkidle0' });
  
  await browser.close();
  
  return {
    log: {
      version: '1.2',
      creator: { name: 'Puppeteer', version: '1.0' },
      entries
    }
  };
}
```

### Validation

**Schema Validation:**

```javascript
function validateHAR(har) {
  const errors = [];
  
  if (!har.log) {
    errors.push('Missing log object');
    return errors;
  }
  
  if (!har.log.version) {
    errors.push('Missing version');
  }
  
  if (!har.log.creator) {
    errors.push('Missing creator');
  }
  
  if (!Array.isArray(har.log.entries)) {
    errors.push('Entries must be an array');
  }
  
  har.log.entries.forEach((entry, index) => {
    if (!entry.request) {
      errors.push(`Entry ${index}: Missing request object`);
    }
    
    if (!entry.response) {
      errors.push(`Entry ${index}: Missing response object`);
    }
    
    if (typeof entry.time !== 'number') {
      errors.push(`Entry ${index}: Invalid time value`);
    }
  });
  
  return errors;
}
```

### Performance Metrics Calculation

**Web Vitals from HAR:**

```javascript
function calculateWebVitals(entries, pages) {
  const page = pages[0];
  const navigationEntry = entries[0];
  
  // First Contentful Paint estimation
  const fcpEntry = entries.find(e => 
    e.response.content.mimeType.includes('html')
  );
  
  // Largest Contentful Paint estimation
  const imageEntries = entries
    .filter(e => e.response.content.mimeType.includes('image'))
    .sort((a, b) => b.response.content.size - a.response.content.size);
  
  const lcpEntry = imageEntries[0];
  
  return {
    // Time to First Byte
    ttfb: navigationEntry.timings.wait,
    
    // First Contentful Paint (approximation)
    fcp: fcpEntry ? 
      (new Date(fcpEntry.startedDateTime) - new Date(navigationEntry.startedDateTime)) + fcpEntry.time : 
      null,
    
    // DOM Content Loaded
    dcl: page.pageTimings.onContentLoad,
    
    // Load Event
    load: page.pageTimings.onLoad,
    
    // Largest Contentful Paint (approximation)
    lcp: lcpEntry ?
      (new Date(lcpEntry.startedDateTime) - new Date(navigationEntry.startedDateTime)) + lcpEntry.time :
      null
  };
}
```

---

