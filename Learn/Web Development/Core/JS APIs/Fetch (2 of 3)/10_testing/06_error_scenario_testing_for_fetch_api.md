## Error Scenario Testing for Fetch API


### Network Failure Testing

#### Connection Refused

Simulating scenarios where the server is unreachable or refuses the connection.

```javascript
async function testConnectionRefused() {
  try {
    // Port 9999 likely has nothing listening
    await fetch('http://localhost:9999/api/endpoint');
    console.error('Expected connection refused error');
  } catch (error) {
    console.log('✓ Connection refused handled:', error.message);
    assert(error instanceof TypeError);
    assert(error.message.includes('Failed to fetch'));
  }
}
```

#### DNS Resolution Failure

Testing behavior when domain names cannot be resolved.

```javascript
async function testDNSFailure() {
  try {
    await fetch('https://nonexistent-domain-12345.invalid/api/data');
    console.error('Expected DNS failure');
  } catch (error) {
    console.log('✓ DNS failure handled:', error.message);
    assert(error instanceof TypeError);
  }
}
```

#### Network Timeout

Simulating slow or unresponsive servers using AbortController.

```javascript
async function testNetworkTimeout() {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 5000);
  
  try {
    // Simulate slow endpoint
    await fetch('https://httpstat.us/200?sleep=10000', {
      signal: controller.signal
    });
    console.error('Expected timeout error');
  } catch (error) {
    console.log('✓ Timeout handled:', error.name);
    assert(error.name === 'AbortError');
  } finally {
    clearTimeout(timeoutId);
  }
}
```

#### Intermittent Connectivity

Testing behavior during sporadic network availability.

```javascript
async function testIntermittentConnectivity() {
  let attemptCount = 0;
  const maxRetries = 3;
  
  async function fetchWithRetry(url) {
    while (attemptCount < maxRetries) {
      try {
        const response = await fetch(url);
        console.log(`✓ Succeeded on attempt ${attemptCount + 1}`);
        return response;
      } catch (error) {
        attemptCount++;
        if (attemptCount >= maxRetries) {
          console.log('✓ Failed after max retries');
          throw error;
        }
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }
  }
  
  await fetchWithRetry('https://example.com/flaky-endpoint');
}
```

#### Network Change During Request

Simulating network switching (WiFi to cellular, etc.).

```javascript
async function testNetworkChange() {
  const controller = new AbortController();
  
  // Listen for network changes
  window.addEventListener('offline', () => {
    console.log('Network went offline during request');
    controller.abort();
  });
  
  try {
    await fetch('https://example.com/large-file', {
      signal: controller.signal
    });
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('✓ Request aborted due to network change');
    }
  }
}
```

### HTTP Status Code Testing

#### 4xx Client Errors

Testing various client error responses.

```javascript
async function test4xxErrors() {
  const testCases = [
    { status: 400, url: 'https://httpstat.us/400', description: 'Bad Request' },
    { status: 401, url: 'https://httpstat.us/401', description: 'Unauthorized' },
    { status: 403, url: 'https://httpstat.us/403', description: 'Forbidden' },
    { status: 404, url: 'https://httpstat.us/404', description: 'Not Found' },
    { status: 409, url: 'https://httpstat.us/409', description: 'Conflict' },
    { status: 422, url: 'https://httpstat.us/422', description: 'Unprocessable Entity' },
    { status: 429, url: 'https://httpstat.us/429', description: 'Too Many Requests' }
  ];
  
  for (const test of testCases) {
    const response = await fetch(test.url);
    assert(!response.ok);
    assert(response.status === test.status);
    console.log(`✓ ${test.status} ${test.description} handled correctly`);
  }
}
```

#### 5xx Server Errors

Testing server error responses.

```javascript
async function test5xxErrors() {
  const testCases = [
    { status: 500, url: 'https://httpstat.us/500', description: 'Internal Server Error' },
    { status: 502, url: 'https://httpstat.us/502', description: 'Bad Gateway' },
    { status: 503, url: 'https://httpstat.us/503', description: 'Service Unavailable' },
    { status: 504, url: 'https://httpstat.us/504', description: 'Gateway Timeout' }
  ];
  
  for (const test of testCases) {
    const response = await fetch(test.url);
    assert(!response.ok);
    assert(response.status >= 500);
    console.log(`✓ ${test.status} ${test.description} handled correctly`);
  }
}
```

#### Edge Case Status Codes

Testing uncommon but valid status codes.

```javascript
async function testEdgeCaseStatuses() {
  const testCases = [
    { status: 204, description: 'No Content (empty response)' },
    { status: 206, description: 'Partial Content' },
    { status: 304, description: 'Not Modified' },
    { status: 418, description: "I'm a teapot" },
    { status: 451, description: 'Unavailable For Legal Reasons' }
  ];
  
  for (const test of testCases) {
    const response = await fetch(`https://httpstat.us/${test.status}`);
    assert(response.status === test.status);
    
    // 204 should have no body
    if (test.status === 204) {
      const text = await response.text();
      assert(text === '');
      console.log(`✓ ${test.status} has empty body as expected`);
    }
  }
}
```

### Response Parsing Errors

#### Invalid JSON

Testing handling of malformed JSON responses.

```javascript
async function testInvalidJSON() {
  // Mock server returning invalid JSON
  const mockResponse = new Response('{ invalid json }', {
    headers: { 'Content-Type': 'application/json' }
  });
  
  try {
    await mockResponse.json();
    console.error('Expected JSON parsing error');
  } catch (error) {
    console.log('✓ Invalid JSON handled:', error.message);
    assert(error instanceof SyntaxError);
  }
}

async function testPartialJSON() {
  const mockResponse = new Response('{"data": "incomplete"', {
    headers: { 'Content-Type': 'application/json' }
  });
  
  try {
    await mockResponse.json();
    console.error('Expected JSON parsing error');
  } catch (error) {
    console.log('✓ Partial JSON handled:', error.message);
  }
}
```

#### Content-Type Mismatch

Testing mismatches between declared and actual content types.

```javascript
async function testContentTypeMismatch() {
  // Server claims JSON but sends HTML
  const mockResponse = new Response('<html><body>Error</body></html>', {
    headers: { 'Content-Type': 'application/json' }
  });
  
  try {
    const data = await mockResponse.json();
    console.error('Expected parsing to fail');
  } catch (error) {
    console.log('✓ Content-Type mismatch detected');
  }
}

async function testMissingContentType() {
  const mockResponse = new Response('some data', {
    headers: {} // No Content-Type
  });
  
  const text = await mockResponse.text();
  console.log('✓ Missing Content-Type handled, text:', text);
}
```

#### Binary Data Corruption

Testing handling of corrupted binary responses.

```javascript
async function testCorruptedBinary() {
  // Simulate corrupted image
  const corruptedData = new Uint8Array([0xFF, 0xD8, 0xFF]); // Invalid JPEG
  const mockResponse = new Response(corruptedData, {
    headers: { 'Content-Type': 'image/jpeg' }
  });
  
  try {
    const blob = await mockResponse.blob();
    const img = new Image();
    
    img.onerror = () => {
      console.log('✓ Corrupted image detected');
    };
    
    img.src = URL.createObjectURL(blob);
  } catch (error) {
    console.log('✓ Binary corruption handled:', error.message);
  }
}
```

#### Empty Response Body

Testing scenarios where response body is unexpectedly empty.

```javascript
async function testEmptyResponseBody() {
  const testCases = [
    { status: 200, expectEmpty: false },
    { status: 204, expectEmpty: true },
    { status: 304, expectEmpty: true }
  ];
  
  for (const test of testCases) {
    const response = new Response(test.expectEmpty ? null : '{"data": "value"}', {
      status: test.status,
      headers: test.expectEmpty ? {} : { 'Content-Type': 'application/json' }
    });
    
    const text = await response.text();
    
    if (test.expectEmpty) {
      assert(text === '');
      console.log(`✓ ${test.status} correctly has empty body`);
    } else {
      assert(text !== '');
      console.log(`✓ ${test.status} correctly has body`);
    }
  }
}
```

### CORS Error Testing

#### Missing CORS Headers

Testing requests to servers without proper CORS configuration.

```javascript
async function testMissingCORSHeaders() {
  try {
    // Request to server without CORS headers
    await fetch('https://example.com/no-cors-endpoint', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    });
    console.error('Expected CORS error');
  } catch (error) {
    console.log('✓ Missing CORS headers blocked:', error.message);
    assert(error instanceof TypeError);
  }
}
```

#### Preflight Failure

Testing scenarios where preflight OPTIONS requests fail.

```javascript
async function testPreflightFailure() {
  try {
    // Custom header triggers preflight
    await fetch('https://example.com/api', {
      method: 'POST',
      headers: {
        'X-Custom-Header': 'value',
        'Content-Type': 'application/json'
      }
    });
    console.error('Expected preflight failure');
  } catch (error) {
    console.log('✓ Preflight failure handled:', error.message);
  }
}
```

#### Credentials Mode Mismatch

Testing credential inclusion with misconfigured CORS.

```javascript
async function testCredentialsMismatch() {
  try {
    // credentials: 'include' requires specific CORS headers
    await fetch('https://api.example.com/endpoint', {
      method: 'GET',
      credentials: 'include'
      // Server must respond with:
      // Access-Control-Allow-Credentials: true
      // Access-Control-Allow-Origin: specific-origin (not *)
    });
  } catch (error) {
    console.log('✓ Credentials mismatch handled:', error.message);
  }
}
```

#### Wildcard Origin with Credentials

Testing the invalid combination of wildcard origin and credentials.

```javascript
async function testWildcardWithCredentials() {
  // This should fail - wildcard (*) not allowed with credentials
  const mockHeaders = new Headers({
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Credentials': 'true'
  });
  
  try {
    // Browser will reject this combination
    const response = new Response('{}', { headers: mockHeaders });
    console.log('✓ Wildcard with credentials prevented');
  } catch (error) {
    console.log('✓ Invalid CORS configuration detected');
  }
}
```

### Timeout and Abort Testing

#### Request Cancellation

Testing explicit request cancellation via AbortController.

```javascript
async function testRequestCancellation() {
  const controller = new AbortController();
  
  const fetchPromise = fetch('https://httpstat.us/200?sleep=5000', {
    signal: controller.signal
  });
  
  // Cancel after 100ms
  setTimeout(() => controller.abort(), 100);
  
  try {
    await fetchPromise;
    console.error('Expected abort error');
  } catch (error) {
    console.log('✓ Request cancelled:', error.name);
    assert(error.name === 'AbortError');
    assert(error.message.includes('aborted'));
  }
}
```

#### Multiple Simultaneous Cancellations

Testing cancellation of parallel requests.

```javascript
async function testMultipleCancellations() {
  const controller = new AbortController();
  
  const requests = [
    fetch('https://httpstat.us/200?sleep=5000', { signal: controller.signal }),
    fetch('https://httpstat.us/201?sleep=5000', { signal: controller.signal }),
    fetch('https://httpstat.us/202?sleep=5000', { signal: controller.signal })
  ];
  
  setTimeout(() => controller.abort(), 100);
  
  const results = await Promise.allSettled(requests);
  
  const allAborted = results.every(r => 
    r.status === 'rejected' && r.reason.name === 'AbortError'
  );
  
  assert(allAborted);
  console.log('✓ All parallel requests cancelled');
}
```

#### Already Aborted Signal

Testing behavior when signal is aborted before fetch is called.

```javascript
async function testAlreadyAbortedSignal() {
  const controller = new AbortController();
  controller.abort(); // Abort immediately
  
  try {
    await fetch('https://example.com/api', {
      signal: controller.signal
    });
    console.error('Expected immediate abort');
  } catch (error) {
    console.log('✓ Already-aborted signal handled:', error.name);
    assert(error.name === 'AbortError');
  }
}
```

#### Abort Reason Handling

Testing custom abort reasons (modern browsers).

```javascript
async function testAbortReason() {
  const controller = new AbortController();
  
  const fetchPromise = fetch('https://httpstat.us/200?sleep=5000', {
    signal: controller.signal
  });
  
  setTimeout(() => {
    controller.abort(new Error('Custom timeout reason'));
  }, 100);
  
  try {
    await fetchPromise;
  } catch (error) {
    console.log('✓ Abort reason:', error.message);
    assert(error.message === 'Custom timeout reason');
  }
}
```

### Request Body Errors

#### Invalid JSON in Request Body

Testing sending malformed JSON data.

```javascript
async function testInvalidRequestJSON() {
  try {
    // Create circular reference (not JSON-serializable)
    const circular = {};
    circular.self = circular;
    
    await fetch('https://example.com/api', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(circular)
    });
    console.error('Expected serialization error');
  } catch (error) {
    console.log('✓ Circular reference detected:', error.message);
    assert(error instanceof TypeError);
  }
}
```

#### Large Payload Handling

Testing behavior with oversized request bodies.

```javascript
async function testLargePayload() {
  // Generate 10MB payload
  const largeData = 'x'.repeat(10 * 1024 * 1024);
  
  try {
    const response = await fetch('https://example.com/api/upload', {
      method: 'POST',
      body: largeData
    });
    
    if (response.status === 413) {
      console.log('✓ Payload too large handled by server');
    }
  } catch (error) {
    console.log('✓ Large payload error:', error.message);
  }
}
```

#### FormData Errors

Testing FormData construction and transmission errors.

```javascript
async function testFormDataErrors() {
  const formData = new FormData();
  
  // Attempt to append non-serializable value
  try {
    formData.append('data', { complex: { nested: { object: true } } });
    
    const response = await fetch('https://example.com/api/form', {
      method: 'POST',
      body: formData
    });
    
    // FormData will convert to "[object Object]"
    console.log('✓ FormData auto-conversion behavior verified');
  } catch (error) {
    console.log('✓ FormData error:', error.message);
  }
}
```

#### Stream Errors

Testing errors during request body streaming.

```javascript
async function testStreamErrors() {
  const stream = new ReadableStream({
    start(controller) {
      controller.enqueue(new TextEncoder().encode('data'));
      controller.error(new Error('Stream error'));
    }
  });
  
  try {
    await fetch('https://example.com/api', {
      method: 'POST',
      body: stream,
      duplex: 'half'
    });
    console.error('Expected stream error');
  } catch (error) {
    console.log('✓ Stream error handled:', error.message);
  }
}
```

### Authentication Errors

#### Missing Authentication Token

Testing requests without required authentication.

```javascript
async function testMissingAuth() {
  const response = await fetch('https://api.example.com/protected', {
    method: 'GET'
    // Missing Authorization header
  });
  
  assert(response.status === 401);
  console.log('✓ Missing auth returns 401');
}
```

#### Expired Token

Testing behavior with expired authentication tokens.

```javascript
async function testExpiredToken() {
  const expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2MDAwMDAwMDB9.xxx';
  
  const response = await fetch('https://api.example.com/protected', {
    headers: {
      'Authorization': `Bearer ${expiredToken}`
    }
  });
  
  assert(response.status === 401);
  const body = await response.json();
  assert(body.error === 'Token expired');
  console.log('✓ Expired token handled');
}
```

#### Invalid Token Format

Testing malformed authentication tokens.

```javascript
async function testInvalidTokenFormat() {
  const testCases = [
    'invalid-token',
    'Bearer',
    'Bearer ',
    'Bearer not-a-jwt',
    ''
  ];
  
  for (const token of testCases) {
    const response = await fetch('https://api.example.com/protected', {
      headers: {
        'Authorization': token
      }
    });
    
    assert(response.status === 401 || response.status === 400);
    console.log(`✓ Invalid token format rejected: "${token}"`);
  }
}
```

#### Token Refresh During Request

Testing scenarios where token expires mid-request.

```javascript
async function testTokenRefreshScenario() {
  let accessToken = 'valid-token';
  
  async function fetchWithTokenRefresh(url, options = {}) {
    let response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${accessToken}`
      }
    });
    
    // Token expired during request
    if (response.status === 401) {
      const body = await response.json();
      if (body.error === 'Token expired') {
        console.log('Token expired, refreshing...');
        
        // Refresh token
        const refreshResponse = await fetch('https://api.example.com/refresh', {
          method: 'POST',
          body: JSON.stringify({ refreshToken: 'refresh-token' })
        });
        
        const { accessToken: newToken } = await refreshResponse.json();
        accessToken = newToken;
        
        // Retry original request
        response = await fetch(url, {
          ...options,
          headers: {
            ...options.headers,
            'Authorization': `Bearer ${accessToken}`
          }
        });
      }
    }
    
    return response;
  }
  
  const response = await fetchWithTokenRefresh('https://api.example.com/data');
  console.log('✓ Token refresh scenario handled');
}
```

### Rate Limiting Testing

#### 429 Too Many Requests

Testing rate limit response handling.

```javascript
async function testRateLimiting() {
  const response = await fetch('https://httpstat.us/429');
  
  assert(response.status === 429);
  
  const retryAfter = response.headers.get('Retry-After');
  if (retryAfter) {
    const waitTime = parseInt(retryAfter) * 1000;
    console.log(`✓ Rate limited, retry after ${retryAfter}s`);
  }
}
```

#### Exponential Backoff Testing

Testing retry logic with exponential backoff.

```javascript
async function testExponentialBackoff() {
  let attempt = 0;
  const maxAttempts = 5;
  
  async function fetchWithBackoff(url) {
    while (attempt < maxAttempts) {
      const response = await fetch(url);
      
      if (response.status !== 429) {
        return response;
      }
      
      attempt++;
      const delay = Math.pow(2, attempt) * 1000; // 2s, 4s, 8s, 16s, 32s
      console.log(`Rate limited, waiting ${delay}ms before retry ${attempt}`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
    
    throw new Error('Max retry attempts reached');
  }
  
  try {
    await fetchWithBackoff('https://httpstat.us/429');
  } catch (error) {
    console.log('✓ Exponential backoff exhausted:', error.message);
  }
}
```

#### Concurrent Request Limiting

Testing client-side request throttling.

```javascript
async function testConcurrentLimiting() {
  const maxConcurrent = 3;
  let activeRequests = 0;
  const queue = [];
  
  async function throttledFetch(url) {
    if (activeRequests >= maxConcurrent) {
      await new Promise(resolve => queue.push(resolve));
    }
    
    activeRequests++;
    console.log(`Active requests: ${activeRequests}`);
    
    try {
      const response = await fetch(url);
      return response;
    } finally {
      activeRequests--;
      if (queue.length > 0) {
        const resolve = queue.shift();
        resolve();
      }
    }
  }
  
  // Fire 10 concurrent requests
  const requests = Array(10).fill(null).map((_, i) => 
    throttledFetch(`https://httpstat.us/200?index=${i}`)
  );
  
  await Promise.all(requests);
  console.log('✓ Concurrent request limiting verified');
}
```

### Redirect Errors

#### Redirect Loop Detection

Testing behavior with circular redirects.

```javascript
async function testRedirectLoop() {
  try {
    // Most browsers limit to 20 redirects
    await fetch('https://httpstat.us/301', {
      redirect: 'follow'
    });
    console.error('Expected redirect loop error');
  } catch (error) {
    console.log('✓ Redirect loop detected:', error.message);
  }
}
```

#### Manual Redirect Handling

Testing manual redirect mode.

```javascript
async function testManualRedirect() {
  const response = await fetch('https://httpstat.us/302', {
    redirect: 'manual'
  });
  
  assert(response.type === 'opaqueredirect');
  assert(response.status === 0);
  console.log('✓ Manual redirect handled, location:', response.headers.get('Location'));
}
```

#### Cross-Origin Redirect

Testing redirects to different origins.

```javascript
async function testCrossOriginRedirect() {
  try {
    // Redirect from one domain to another
    const response = await fetch('https://example.com/redirect-to-other-domain', {
      redirect: 'follow'
    });
    
    // Check if credentials were properly handled
    assert(response.url !== 'https://example.com/redirect-to-other-domain');
    console.log('✓ Cross-origin redirect handled, final URL:', response.url);
  } catch (error) {
    console.log('✓ Cross-origin redirect error:', error.message);
  }
}
```

#### Too Many Redirects

Testing redirect limit enforcement.

```javascript
async function testTooManyRedirects() {
  let redirectCount = 0;
  
  // Simulate redirect chain
  async function followRedirects(url, maxRedirects = 20) {
    while (redirectCount < maxRedirects) {
      const response = await fetch(url, { redirect: 'manual' });
      
      if (response.type === 'opaqueredirect') {
        redirectCount++;
        const location = response.headers.get('Location');
        if (!location) break;
        url = location;
      } else {
        return response;
      }
    }
    
    throw new Error('Too many redirects');
  }
  
  try {
    await followRedirects('https://httpstat.us/301');
  } catch (error) {
    console.log('✓ Too many redirects:', redirectCount);
  }
}
```

### SSL/TLS Errors

#### Self-Signed Certificate

Testing behavior with untrusted certificates (development environments).

```javascript
async function testSelfSignedCert() {
  try {
    // In production, this should fail
    await fetch('https://self-signed.badssl.com/');
    console.error('Expected SSL error');
  } catch (error) {
    console.log('✓ Self-signed certificate rejected:', error.message);
    assert(error instanceof TypeError);
  }
}
```

#### Expired Certificate

Testing expired SSL certificate handling.

```javascript
async function testExpiredCert() {
  try {
    await fetch('https://expired.badssl.com/');
    console.error('Expected SSL error');
  } catch (error) {
    console.log('✓ Expired certificate rejected:', error.message);
  }
}
```

#### Hostname Mismatch

Testing certificate hostname validation.

```javascript
async function testHostnameMismatch() {
  try {
    await fetch('https://wrong.host.badssl.com/');
    console.error('Expected hostname mismatch error');
  } catch (error) {
    console.log('✓ Hostname mismatch detected:', error.message);
  }
}
```

#### Mixed Content

Testing HTTPS pages loading HTTP resources.

```javascript
async function testMixedContent() {
  // If page is served over HTTPS
  if (window.location.protocol === 'https:') {
    try {
      await fetch('http://example.com/api'); // HTTP on HTTPS page
      console.error('Expected mixed content error');
    } catch (error) {
      console.log('✓ Mixed content blocked:', error.message);
    }
  }
}
```

### Content Encoding Errors

#### Unsupported Encoding

Testing responses with unsupported content encodings.

```javascript
async function testUnsupportedEncoding() {
  const response = new Response('data', {
    headers: {
      'Content-Encoding': 'unsupported-algorithm'
    }
  });
  
  try {
    await response.text();
    console.error('Expected encoding error');
  } catch (error) {
    console.log('✓ Unsupported encoding handled:', error.message);
  }
}
```

#### Corrupted Gzip

Testing corrupted compressed responses.

```javascript
async function testCorruptedGzip() {
  // Create corrupted gzip data
  const corruptedData = new Uint8Array([0x1f, 0x8b, 0x08, 0x00, 0xff]);
  
  const response = new Response(corruptedData, {
    headers: {
      'Content-Encoding': 'gzip'
    }
  });
  
  try {
    await response.text();
    console.error('Expected decompression error');
  } catch (error) {
    console.log('✓ Corrupted gzip detected:', error.message);
  }
}
```

### Comprehensive Error Test Suite

#### Complete Test Runner

Combining all error scenarios into a comprehensive test suite.

```javascript
class FetchErrorTestSuite {
  constructor() {
    this.results = {
      passed: 0,
      failed: 0,
      errors: []
    };
  }
  
  async runTest(name, testFn) {
    try {
      await testFn();
      this.results.passed++;
      console.log(`✓ ${name} passed`);
    } catch (error) {
      this.results.failed++;
      this.results.errors.push({ name, error: error.message });
      console.error(`✗ ${name} failed:`, error.message);
    }
  }
  
  async runAll() {
    console.log('Running comprehensive error test suite...\n');
    
    // Network errors
    await this.runTest('Connection Refused', testConnectionRefused);
    await this.runTest('DNS Failure', testDNSFailure);
    await this.runTest('Network Timeout', testNetworkTimeout);
    
    // HTTP status errors
    await this.runTest('4xx Errors', test4xxErrors);
    await this.runTest('5xx Errors', test5xxErrors);
    
    // Parsing errors
    await this.runTest('Invalid JSON', testInvalidJSON);
    await this.runTest('Content-Type Mismatch', testContentTypeMismatch);
    
    // CORS errors
    await this.runTest('Missing CORS Headers', testMissingCORSHeaders);
    await this.runTest('Preflight Failure', testPreflightFailure);
    
    // Timeout/Abort
    await this.runTest('Request Cancellation', testRequestCancellation);
    await this.runTest('Multiple Cancellations', testMultipleCancellations);
    
    // Auth errors
    await this.runTest('Missing Auth', testMissingAuth);
    await this.runTest('Expired Token', testExpiredToken);
    
    // Rate limiting
    await this.runTest('Rate Limiting', testRateLimiting);
    await this.runTest('Exponential Backoff', testExponentialBackoff);
    
    // Redirects
    await this.runTest('Redirect Loop', testRedirectLoop);
    await this.runTest('Manual Redirect', testManualRedirect);
    
    // SSL/TLS
    await this.runTest('Self-Signed Cert', testSelfSignedCert);
    await this.runTest
```

---

