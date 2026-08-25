## Fetch API Browser-Specific Issues


### Internet Explorer Compatibility

Internet Explorer 11 and earlier versions lack native fetch support. Polyfills like `whatwg-fetch` or `unfetch` are required for compatibility. These polyfills translate fetch calls into XMLHttpRequest operations under the hood.

```javascript
// Polyfill detection
if (!window.fetch) {
  // Load polyfill
  import('whatwg-fetch');
}
```

### Safari and Webkit-Specific Behaviors

#### Credential Handling

Safari historically had stricter same-origin policies for credentials. The `credentials` option behaves differently:

```javascript
// May require explicit credentials mode in Safari
fetch('/api/data', {
  credentials: 'same-origin' // or 'include'
});
```

Safari versions before 10.1 didn't support `credentials: 'same-origin'` properly, defaulting to `'omit'`.

#### CORS Preflight Caching

Safari caches CORS preflight responses more aggressively than other browsers. The `Access-Control-Max-Age` header may be ignored or capped at lower values (typically 600 seconds vs 86400 in Chrome).

#### Service Worker Limitations

Older Safari versions (before 11.1) had no Service Worker support, making fetch-based caching strategies impossible. Versions 11.1-13 had partial implementations with bugs around `fetch()` event handling.

### Firefox Peculiarities

#### Request Body Streaming

Firefox had delayed support for streaming request bodies. Versions before 105 couldn't stream `ReadableStream` bodies:

```javascript
// May not work in Firefox < 105
const stream = new ReadableStream({
  start(controller) {
    controller.enqueue(new Uint8Array([1, 2, 3]));
    controller.close();
  }
});

fetch('/upload', {
  method: 'POST',
  body: stream
});
```

#### Network Error Details

Firefox provides less detailed error information for network failures compared to Chrome DevTools. Failed fetches often return generic `TypeError: NetworkError` without specific status codes or reasons.

### Chrome/Chromium Edge Issues

#### Memory Management for Large Responses

Chrome can exhibit memory bloat when repeatedly fetching large responses without proper cleanup. Explicitly calling `.blob()` or `.arrayBuffer()` and releasing references is important:

```javascript
async function fetchLargeFile() {
  const response = await fetch('/large-file');
  const blob = await response.blob();
  // Use blob
  // Blob will be GC'd when reference is lost
}
```

#### Credential Behavior in Private Mode

Chrome's Incognito mode handles cookies and credentials differently. Fetch requests may silently fail or omit credentials even with `credentials: 'include'` if third-party cookies are blocked.

#### Request Abortion Edge Cases

Chrome versions before 90 had race conditions where aborting a fetch with `AbortController` could leave the connection in an inconsistent state, particularly with HTTP/2 multiplexed streams.

### Cross-Browser CORS Inconsistencies

#### Opaque Response Handling

Browsers differ in how they expose information about opaque responses (from `no-cors` mode):

```javascript
const response = await fetch('https://external.com/resource', {
  mode: 'no-cors'
});

// response.ok is always false
// response.status is always 0
// response.type is 'opaque'
// Body cannot be read
```

Safari may cache opaque responses differently than Chrome, leading to inconsistent behavior across page reloads.

#### Redirect Handling

Firefox and Safari historically handled redirects with method changes differently:

- POST requests redirected with 301/302 should preserve method per modern specs
- Older implementations changed POST to GET on redirect
- The `redirect: 'follow'` option behavior varies between browsers for cross-origin redirects

### Mobile Browser Constraints

#### iOS Safari Background Limitations

iOS Safari suspends fetch requests when the app enters background mode. Long-running fetches may fail with timeout errors:

```javascript
// May fail if app is backgrounded
fetch('/long-operation', {
  signal: AbortSignal.timeout(30000) // 30 second timeout
});
```

#### Android WebView Variations

Android WebView implementations vary by OS version:

- Android 4.4-5.0: No native fetch, requires polyfill
- Android 5.0-7.0: Partial implementation with bugs
- Android 8.0+: Full support but may have vendor-specific customizations

Chrome Custom Tabs and WebView use different JavaScript engines, leading to inconsistent behavior in hybrid apps.

### Headers API Differences

#### Case Sensitivity

While HTTP headers are case-insensitive by spec, browser implementations differ:

```javascript
const headers = new Headers();
headers.append('Content-Type', 'application/json');

// Chrome normalizes to lowercase
headers.get('content-type'); // Works in all browsers

// Some browsers preserve original casing internally
headers.forEach((value, name) => {
  console.log(name); // Casing may differ
});
```

#### Forbidden Headers

Browsers restrict setting certain headers for security. The list varies slightly:

- `Host`, `Connection`, `Origin` - universally forbidden
- `Referer` - forbidden in most browsers, but some allow partial control
- `User-Agent` - forbidden in Chrome/Safari, allowed in Firefox (deprecated)

### TLS/SSL Certificate Issues

#### Self-Signed Certificates

Chrome and Firefox handle self-signed certificates differently in development:

- Chrome: Shows warning, allows bypass with user action
- Firefox: Similar warning but different bypass mechanism
- Safari: Stricter, may require certificate installation in keychain

Fetch requests to HTTPS endpoints with invalid certificates fail silently without detailed errors in production builds.

### Request Timeout Handling

No native timeout support exists in the Fetch API. The `AbortSignal.timeout()` method is a recent addition:

```javascript
// Modern approach (Chrome 103+, Firefox 100+, Safari 16+)
try {
  const response = await fetch('/api', {
    signal: AbortSignal.timeout(5000)
  });
} catch (error) {
  if (error.name === 'TimeoutError') {
    // Handle timeout
  }
}
```

Older browsers require manual timeout implementation:

```javascript
// Legacy approach
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 5000);

try {
  const response = await fetch('/api', {
    signal: controller.signal
  });
} finally {
  clearTimeout(timeoutId);
}
```

### Cookie and Storage Quota Limits

#### Cookie Size Limitations

Browsers impose different cookie size limits affecting fetch with credentials:

- Chrome: 4096 bytes per cookie
- Firefox: 4097 bytes per cookie
- Safari: 4093 bytes per cookie

Exceeding limits causes cookies to be silently truncated or rejected, affecting authentication state.

#### Cache API Quota

Browser storage quotas for Cache API (used with fetch caching) vary:

- Chrome: ~60% of available disk space
- Firefox: ~50% of available disk space, 2GB limit per origin
- Safari: More restrictive, often 50MB-1GB depending on device

### HTTP/2 and HTTP/3 Support

#### Protocol Version Inconsistencies

Browser support for newer HTTP versions affects fetch performance:

- HTTP/2: Universal support, but server push handling differs
- HTTP/3 (QUIC): Chrome 87+, Edge 87+, Firefox 88+, Safari 14+
- Fallback behavior varies when HTTP/3 is unavailable

#### Server Push Handling

Chrome's implementation of HTTP/2 server push differs from Firefox. Fetch requests may receive pushed resources differently:

```javascript
// Chrome caches pushed resources more aggressively
// Firefox may re-request resources despite server push
```

### Blob and File Upload Differences

#### Multipart Form Data

Browsers construct multipart/form-data boundaries differently:

```javascript
const formData = new FormData();
formData.append('file', blob, 'filename.txt');

// Boundary generation algorithm varies
// Content-Type header format may differ slightly
fetch('/upload', {
  method: 'POST',
  body: formData
});
```

Chrome, Firefox, and Safari use different boundary string formats, though all are spec-compliant.

### Developer Tools Integration

#### Network Panel Information

Browser DevTools expose different levels of detail:

- Chrome: Full request/response timing, protocol info, push events
- Firefox: Similar detail, different UI organization
- Safari: Less detailed timing information, especially for cached responses

#### Request Body Inspection

DevTools differ in how they display request bodies:

- Chrome: Shows formatted JSON, preserves FormData structure
- Firefox: Shows raw payload, may not decode binary data
- Safari: Limited formatting, especially for streaming bodies

### Feature Detection Patterns

[Inference] Reliable feature detection helps manage browser differences:

```javascript
// Check for streaming body support
const supportsRequestStreams = (() => {
  try {
    new Request('', {
      body: new ReadableStream(),
      method: 'POST'
    });
    return true;
  } catch {
    return false;
  }
})();

// Check for AbortSignal.timeout
const supportsTimeoutSignal = 'timeout' in AbortSignal;

// Check for response.blob() streaming
const supportsResponseStreaming = (() => {
  const response = new Response('');
  return typeof response.body?.getReader === 'function';
})();
```

### Proxy and VPN Complications

#### Corporate Proxies

Enterprise proxies may interfere with fetch requests:

- CONNECT method tunneling varies
- SSL interception affects certificate validation
- Custom headers may be stripped or modified

Chrome and Firefox handle proxy authentication prompts differently, with Chrome showing system-level dialogs and Firefox using in-browser prompts.

#### VPN and Network Switching

Mobile browsers exhibit different behaviors when network switches occur mid-request:

- iOS Safari: Typically aborts in-flight requests
- Chrome Mobile: Attempts to retry on new network
- Firefox Mobile: May hang indefinitely until timeout

### Response Type Handling

#### JSON Parsing Differences

While `response.json()` is standardized, error handling differs:

```javascript
try {
  const data = await response.json();
} catch (error) {
  // Chrome: SyntaxError with detailed message
  // Firefox: SyntaxError with less detail
  // Safari: May throw different error types for encoding issues
}
```

#### Streaming Response Processing

Chrome and Firefox differ in how they handle backpressure in response streams:

```javascript
const reader = response.body.getReader();
while (true) {
  const {done, value} = await reader.read();
  if (done) break;
  // Chrome applies backpressure more aggressively
  // Firefox may buffer more data in memory
  processChunk(value);
}
```

### CSP (Content Security Policy) Interactions

Browsers enforce CSP `connect-src` directive differently for fetch:

- Chrome: Strict enforcement, blocks on violation
- Firefox: Similar enforcement with better error messages
- Safari: May allow data: URIs even when not in policy

### Service Worker Fetch Event Quirks

#### Navigation Preload

Chrome supports navigation preload, Firefox and Safari have limited or no support:

```javascript
// Chrome only (as of recent versions)
self.addEventListener('activate', event => {
  event.waitUntil(self.registration.navigationPreload.enable());
});
```

#### Request Interception Timing

Safari's Service Worker implementation has timing issues where fetch events may be fired inconsistently compared to Chrome/Firefox, particularly during page navigation.

---

