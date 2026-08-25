## Feature Detection


### Basic Detection

The simplest detection checks for `fetch` on the global object:

```javascript
if ('fetch' in window) {
  // fetch is available
}

// Or with typeof
if (typeof fetch === 'function') {
  // fetch is available
}
```

This confirms the API exists but doesn't verify specific capabilities or proper implementation.

### Request Constructor Detection

Detecting `Request` constructor availability:

```javascript
if (typeof Request !== 'undefined') {
  // Request constructor available
}

// Check both fetch and Request
if ('fetch' in window && 'Request' in window) {
  // Both available
}
```

The `Request` constructor may be absent in partial implementations or polyfills.

### Response Constructor Detection

```javascript
if (typeof Response !== 'undefined') {
  // Response constructor available
}
```

### Headers Detection

```javascript
if (typeof Headers !== 'undefined') {
  // Headers API available
}
```

### Signal and AbortController Detection

For abort functionality:

```javascript
if ('signal' in Request.prototype && 'AbortController' in window) {
  // Abort API is available
  const controller = new AbortController();
  fetch(url, { signal: controller.signal });
}
```

**[Inference]**: Checking both `signal` in `Request.prototype` and `AbortController` existence increases confidence that abort functionality works properly, though implementation bugs could still exist.

### Streams Detection

Detecting readable stream support in responses:

```javascript
if ('body' in Response.prototype && 'ReadableStream' in window) {
  // Response body streams are likely supported
}

// More thorough check
async function detectStreamSupport() {
  try {
    const response = new Response('test');
    return 'body' in response && response.body instanceof ReadableStream;
  } catch (e) {
    return false;
  }
}
```

### Credentials Mode Detection

```javascript
function detectCredentialsMode() {
  try {
    const req = new Request('/', { credentials: 'include' });
    return req.credentials === 'include';
  } catch (e) {
    return false;
  }
}
```

### Cache Mode Detection

```javascript
function detectCacheMode() {
  try {
    const req = new Request('/', { cache: 'no-cache' });
    return req.cache === 'no-cache';
  } catch (e) {
    return false;
  }
}
```

### Redirect Mode Detection

```javascript
function detectRedirectMode() {
  try {
    const req = new Request('/', { redirect: 'manual' });
    return req.redirect === 'manual';
  } catch (e) {
    return false;
  }
}
```

### Referrer Policy Detection

```javascript
function detectReferrerPolicy() {
  try {
    const req = new Request('/', { referrerPolicy: 'no-referrer' });
    return req.referrerPolicy === 'no-referrer';
  } catch (e) {
    return false;
  }
}
```

### Integrity Detection

Subresource Integrity (SRI) support:

```javascript
function detectIntegrity() {
  try {
    const req = new Request('/', { 
      integrity: 'sha256-test' 
    });
    return 'integrity' in req;
  } catch (e) {
    return false;
  }
}
```

### Keepalive Detection

```javascript
function detectKeepalive() {
  try {
    const req = new Request('/', { keepalive: true });
    return req.keepalive === true;
  } catch (e) {
    return false;
  }
}
```

### Priority Detection

For resource priority hints:

```javascript
function detectPriority() {
  try {
    const req = new Request('/', { priority: 'high' });
    return 'priority' in req;
  } catch (e) {
    return false;
  }
}
```

### Request Duplex Detection

For streaming request bodies:

```javascript
function detectDuplex() {
  try {
    const req = new Request('/', { 
      method: 'POST',
      body: new ReadableStream(),
      duplex: 'half'
    });
    return true;
  } catch (e) {
    return false;
  }
}
```

**[Unverified]**: This detection approach may not reliably indicate full duplex streaming support across all environments.

### Response Type Detection

Checking for opaque response types:

```javascript
async function detectResponseTypes() {
  try {
    const response = new Response('test', { 
      status: 200,
      statusText: 'OK'
    });
    
    return {
      basic: response.type === 'basic',
      hasType: 'type' in response
    };
  } catch (e) {
    return { basic: false, hasType: false };
  }
}
```

### FormData Body Detection

```javascript
function detectFormDataBody() {
  if (typeof FormData === 'undefined') return false;
  
  try {
    const formData = new FormData();
    const req = new Request('/', { 
      method: 'POST',
      body: formData 
    });
    return true;
  } catch (e) {
    return false;
  }
}
```

### Blob Body Detection

```javascript
function detectBlobBody() {
  if (typeof Blob === 'undefined') return false;
  
  try {
    const blob = new Blob(['test']);
    const req = new Request('/', { 
      method: 'POST',
      body: blob 
    });
    return true;
  } catch (e) {
    return false;
  }
}
```

### ArrayBuffer Body Detection

```javascript
function detectArrayBufferBody() {
  try {
    const buffer = new ArrayBuffer(8);
    const req = new Request('/', { 
      method: 'POST',
      body: buffer 
    });
    return true;
  } catch (e) {
    return false;
  }
}
```

### Response Body Methods Detection

```javascript
async function detectBodyMethods() {
  const response = new Response('{"test": true}');
  
  return {
    json: typeof response.json === 'function',
    text: typeof response.text === 'function',
    blob: typeof response.blob === 'function',
    arrayBuffer: typeof response.arrayBuffer === 'function',
    formData: typeof response.formData === 'function'
  };
}
```

### Clone Detection

```javascript
function detectClone() {
  try {
    const req = new Request('/');
    const cloned = req.clone();
    return cloned instanceof Request;
  } catch (e) {
    return false;
  }
}
```

### Comprehensive Feature Matrix

```javascript
async function getFetchFeatureMatrix() {
  const features = {
    core: {
      fetch: typeof fetch === 'function',
      Request: typeof Request !== 'undefined',
      Response: typeof Response !== 'undefined',
      Headers: typeof Headers !== 'undefined'
    },
    abort: {
      signal: 'signal' in Request.prototype,
      AbortController: typeof AbortController !== 'undefined'
    },
    streams: {
      ReadableStream: typeof ReadableStream !== 'undefined',
      responseBody: false
    },
    requestOptions: {},
    bodyTypes: {},
    responseMethods: {}
  };

  // Test response body stream
  try {
    const response = new Response('test');
    features.streams.responseBody = response.body instanceof ReadableStream;
  } catch (e) {}

  // Test request options
  const options = [
    'credentials', 'cache', 'redirect', 
    'referrerPolicy', 'integrity', 'keepalive', 'priority'
  ];
  
  for (const option of options) {
    try {
      const testValue = option === 'credentials' ? 'include' :
                       option === 'cache' ? 'no-cache' :
                       option === 'redirect' ? 'manual' :
                       option === 'referrerPolicy' ? 'no-referrer' :
                       option === 'integrity' ? 'sha256-test' :
                       option === 'keepalive' ? true :
                       option === 'priority' ? 'high' : null;
      
      const req = new Request('/', { [option]: testValue });
      features.requestOptions[option] = option in req;
    } catch (e) {
      features.requestOptions[option] = false;
    }
  }

  // Test body types
  const bodyTests = [
    { name: 'string', value: 'test' },
    { name: 'FormData', value: typeof FormData !== 'undefined' ? new FormData() : null },
    { name: 'Blob', value: typeof Blob !== 'undefined' ? new Blob(['test']) : null },
    { name: 'ArrayBuffer', value: new ArrayBuffer(8) },
    { name: 'URLSearchParams', value: typeof URLSearchParams !== 'undefined' ? new URLSearchParams() : null }
  ];

  for (const test of bodyTests) {
    if (test.value === null) {
      features.bodyTypes[test.name] = false;
      continue;
    }
    
    try {
      new Request('/', { method: 'POST', body: test.value });
      features.bodyTypes[test.name] = true;
    } catch (e) {
      features.bodyTypes[test.name] = false;
    }
  }

  // Test response methods
  try {
    const response = new Response('test');
    const methods = ['json', 'text', 'blob', 'arrayBuffer', 'formData'];
    
    for (const method of methods) {
      features.responseMethods[method] = typeof response[method] === 'function';
    }
  } catch (e) {}

  return features;
}
```

### Detection Patterns for Polyfills

When using polyfills, detect whether native or polyfilled:

```javascript
function isNativeFetch() {
  if (typeof fetch !== 'function') return false;
  
  // Check for native code string
  return /native code/.test(fetch.toString());
}

function getFetchImplementation() {
  if (typeof fetch !== 'function') {
    return 'none';
  }
  
  if (/native code/.test(fetch.toString())) {
    return 'native';
  }
  
  return 'polyfill';
}
```

**[Unverified]**: The `native code` string check may not be reliable across all JavaScript engines or when code is minified/transformed.

### Service Worker Context Detection

```javascript
function isFetchAvailableInServiceWorker() {
  return typeof self !== 'undefined' && 
         'ServiceWorkerGlobalScope' in self &&
         typeof fetch === 'function';
}
```

### Worker Context Detection

```javascript
function isFetchAvailableInWorker() {
  return typeof self !== 'undefined' &&
         typeof WorkerGlobalScope !== 'undefined' &&
         typeof fetch === 'function';
}
```

### CORS Detection

**[Inference]**: CORS behavior cannot be directly detected through feature detection; it depends on server configuration and runtime behavior.

```javascript
// Cannot reliably detect CORS support through feature detection
// CORS is determined by:
// - Server response headers
// - Request mode
// - Runtime environment

async function testCORSCapability(url) {
  try {
    const response = await fetch(url, { mode: 'cors' });
    return response.ok;
  } catch (e) {
    return false;
  }
}
```

### Combined Detection Strategy

```javascript
class FetchCapabilities {
  constructor() {
    this.features = null;
  }

  async detect() {
    this.features = {
      available: typeof fetch === 'function',
      implementation: this.getImplementation(),
      core: this.detectCore(),
      advanced: this.detectAdvanced(),
      bodySupport: this.detectBodySupport(),
      streamSupport: await this.detectStreamSupport()
    };
    
    return this.features;
  }

  getImplementation() {
    if (typeof fetch !== 'function') return 'none';
    return /native code/.test(fetch.toString()) ? 'native' : 'polyfill';
  }

  detectCore() {
    return {
      fetch: typeof fetch === 'function',
      Request: typeof Request !== 'undefined',
      Response: typeof Response !== 'undefined',
      Headers: typeof Headers !== 'undefined',
      AbortController: typeof AbortController !== 'undefined'
    };
  }

  detectAdvanced() {
    const features = {};
    
    const tests = [
      { name: 'signal', test: () => 'signal' in Request.prototype },
      { name: 'keepalive', test: () => {
        const req = new Request('/', { keepalive: true });
        return req.keepalive === true;
      }},
      { name: 'priority', test: () => {
        const req = new Request('/', { priority: 'high' });
        return 'priority' in req;
      }},
      { name: 'integrity', test: () => {
        const req = new Request('/', { integrity: 'sha256-test' });
        return 'integrity' in req;
      }}
    ];

    for (const { name, test } of tests) {
      try {
        features[name] = test();
      } catch (e) {
        features[name] = false;
      }
    }

    return features;
  }

  detectBodySupport() {
    const types = ['string', 'FormData', 'Blob', 'ArrayBuffer', 'URLSearchParams'];
    const support = {};

    for (const type of types) {
      try {
        let body;
        switch (type) {
          case 'string': body = 'test'; break;
          case 'FormData': body = new FormData(); break;
          case 'Blob': body = new Blob(['test']); break;
          case 'ArrayBuffer': body = new ArrayBuffer(8); break;
          case 'URLSearchParams': body = new URLSearchParams(); break;
        }
        
        new Request('/', { method: 'POST', body });
        support[type] = true;
      } catch (e) {
        support[type] = false;
      }
    }

    return support;
  }

  async detectStreamSupport() {
    try {
      const response = new Response('test');
      return {
        available: 'body' in response && response.body instanceof ReadableStream,
        ReadableStream: typeof ReadableStream !== 'undefined'
      };
    } catch (e) {
      return { available: false, ReadableStream: false };
    }
  }

  hasMinimumSupport() {
    return this.features?.available && 
           this.features.core.Request && 
           this.features.core.Response;
  }

  hasModernSupport() {
    return this.hasMinimumSupport() &&
           this.features.advanced.signal &&
           this.features.core.AbortController &&
           this.features.streamSupport.available;
  }
}

// Usage
const capabilities = new FetchCapabilities();
const features = await capabilities.detect();

if (capabilities.hasModernSupport()) {
  // Use fetch with modern features
} else if (capabilities.hasMinimumSupport()) {
  // Use fetch with basic features
} else {
  // Load polyfill or use XMLHttpRequest
}
```

### Browser-Specific Quirks Detection

**[Inference]**: Some browsers have partial or buggy implementations that standard feature detection may not catch.

```javascript
function detectKnownQuirks() {
  const quirks = {
    // Some versions have issues with certain features
    hasStreamingQuirks: false,
    hasAbortQuirks: false,
    hasCredentialsQuirks: false
  };

  // These would need specific version/UA testing
  // which is generally discouraged in favor of capability testing
  
  return quirks;
}
```

### Fallback Strategy

```javascript
async function fetchWithFallback(url, options = {}) {
  // Check for fetch support
  if (typeof fetch !== 'function') {
    throw new Error('Fetch not available and no fallback configured');
  }

  // Check for required features
  const needsAbort = 'signal' in (options || {});
  const hasAbort = 'AbortController' in window && 'signal' in Request.prototype;

  if (needsAbort && !hasAbort) {
    // Remove signal and warn
    console.warn('AbortController not supported, removing signal');
    const { signal, ...restOptions } = options;
    return fetch(url, restOptions);
  }

  return fetch(url, options);
}
```

---

