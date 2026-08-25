## Evolution from XMLHttpRequest to Fetch


### The XMLHttpRequest Era

XMLHttpRequest (XHR) emerged in the late 1990s as Microsoft's ActiveX component and became standardized across browsers by the mid-2000s. It enabled asynchronous HTTP requests without page reloads, fundamentally enabling the AJAX revolution that transformed web applications.

#### Core XHR Limitations

XHR's API design reflected its age through several architectural constraints. The event-based model required verbose callback handling with separate event listeners for `onload`, `onerror`, `onprogress`, and `onreadystatechange`. Error handling proved particularly problematic—network failures, HTTP errors, and timeouts required different handling mechanisms, with no unified error pathway.

The callback-centric design made sequential requests deeply nested, creating callback pyramids that harmed readability and maintainability. Developers had no native way to compose multiple requests or handle concurrent operations without external libraries or complex state management.

XHR's configuration model split concerns across multiple method calls. Setting up a request required calling `open()`, configuring properties like `responseType` and `timeout`, calling `setRequestHeader()` for each header, and finally invoking `send()`. This procedural approach made request configuration error-prone and difficult to encapsulate.

The `readyState` property cycled through five states (0-4), requiring developers to check `readyState === 4` before accessing response data. This state machine added complexity to what should be straightforward request handling.

### The Fetch API Architecture

Fetch introduced a promise-based interface that fundamentally restructured how developers interact with HTTP. The API returns promises that resolve to Response objects, enabling promise chaining and async/await patterns that flatten asynchronous code structure.

#### Request and Response Object Model

Fetch treats requests and responses as first-class objects. The Request object encapsulates all request configuration—URL, method, headers, body, credentials, cache mode, and redirect behavior—in a single constructible object. This enables request cloning, inspection, and modification before sending.

The Response object provides a consistent interface for handling server responses. It includes properties like `status`, `statusText`, `ok` (true for 200-299 status codes), and `headers`, plus methods for consuming the body: `text()`, `json()`, `blob()`, `arrayBuffer()`, and `formData()`. Each consumption method returns a promise, maintaining consistency with the overall async model.

The Headers object provides a map-like interface with methods like `get()`, `set()`, `append()`, `delete()`, and `has()`. Headers are mutable on requests but immutable on responses, preventing accidental modification of server data.

#### Streaming and Body Handling

Fetch exposes response bodies as ReadableStreams through the `response.body` property, enabling progressive processing of large payloads without loading entire responses into memory. This streaming capability allows developers to process data chunks as they arrive, implement progress indicators based on actual bytes received, and cancel streams mid-transfer.

The Body mixin (implemented by both Request and Response) provides the `bodyUsed` property, which becomes true after any consumption method is called. This prevents double-reading of streams, which would throw an error. Cloning via `response.clone()` creates independent streams for multiple consumers.

#### Promise-Based Error Handling

Fetch's error model distinguishes between network failures and HTTP errors. The fetch promise only rejects for network-level failures—DNS resolution failures, connection timeouts, or network unavailability. HTTP error status codes (404, 500, etc.) resolve the promise successfully with `response.ok = false`.

This design requires explicit status checking:

```javascript
fetch(url)
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP error ${response.status}`);
    }
    return response.json();
  })
  .catch(error => {
    // Handles both network errors and thrown HTTP errors
  });
```

The two-tier error model separates transport failures from application-level errors, giving developers precise control over error handling strategies.

### Advanced Fetch Capabilities

#### Request Configuration Options

The `init` object passed to `fetch()` supports comprehensive configuration. The `mode` option controls CORS behavior with values like `cors`, `no-cors`, `same-origin`, and `navigate`. The `credentials` option determines cookie handling: `omit`, `same-origin`, or `include` for cross-origin cookies.

The `cache` option provides granular control over HTTP caching with values like `default`, `no-store`, `reload`, `no-cache`, `force-cache`, and `only-if-cached`. The `redirect` option specifies redirect handling: `follow`, `error`, or `manual`.

Request integrity can be verified through the `integrity` option, which accepts Subresource Integrity hashes. The `keepalive` option allows requests to continue even if the page that initiated them is closed—useful for analytics beacons.

#### AbortController Integration

Fetch integrates with the AbortController API for request cancellation. Creating an AbortController produces a `signal` object that's passed to fetch options. Calling `controller.abort()` triggers rejection with an `AbortError`, canceling the in-flight request and terminating network activity.

```javascript
const controller = new AbortController();
const signal = controller.signal;

fetch(url, { signal })
  .then(response => response.json())
  .catch(error => {
    if (error.name === 'AbortError') {
      // Request was cancelled
    }
  });

// Later:
controller.abort();
```

AbortController's reusability is limited—each controller can only abort once. Multiple requests can share a single signal, enabling batch cancellation of related operations.

The signal also supports timeout functionality through `AbortSignal.timeout(ms)`, which creates a signal that aborts after the specified duration without requiring explicit controller management.

### Streaming Responses

The ReadableStream interface accessed via `response.body` exposes a `getReader()` method that returns a ReadableStreamDefaultReader. The reader's `read()` method returns promises that resolve to `{done, value}` objects, where `value` is a Uint8Array chunk.

Processing streams requires iterative reading:

```javascript
const reader = response.body.getReader();

async function processStream() {
  while (true) {
    const {done, value} = await reader.read();
    if (done) break;
    // Process Uint8Array chunk
  }
}
```

The async iteration protocol simplifies this pattern:

```javascript
for await (const chunk of response.body) {
  // Process each Uint8Array chunk
}
```

Stream piping enables transformation chains. The `pipeThrough()` method passes streams through TransformStream objects for operations like decompression, decryption, or format conversion. The `pipeTo()` method connects streams to WritableStream destinations.

### Request Deduplication and Caching

[Inference] Fetch doesn't provide built-in request deduplication—multiple identical fetch calls create separate network requests. Service Workers offer one approach to deduplication by intercepting fetch requests and implementing custom caching strategies that check for in-flight requests.

The Cache API, accessible through `caches.open()`, provides programmatic cache management. Cache objects store Request/Response pairs with methods like `put()`, `match()`, and `delete()`. While designed primarily for Service Workers, Cache API is also available in window contexts for application-level caching strategies.

### Middleware and Request Interception

Fetch lacks built-in middleware or interceptor patterns. [Inference] Implementing request/response interception requires wrapping the global `fetch` function or creating factory functions that apply transformations before delegation.

Common patterns include creating fetch wrappers that inject authentication tokens, normalize error handling, add logging, or apply retry logic. These wrappers maintain the fetch API surface while adding cross-cutting concerns:

```javascript
function fetchWithAuth(url, options = {}) {
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${getToken()}`
    }
  });
}
```

Service Workers provide true request interception through the `fetch` event, enabling comprehensive request modification, response synthesis, and offline-first architectures.

### Upload Progress Tracking

Fetch provides no standard mechanism for monitoring upload progress. The `Response` object exposes download progress through the readable stream, but request bodies offer no corresponding progress API.

[Inference] This limitation stems from fetch's streaming request body support—the body can be a ReadableStream that's consumed asynchronously, making progress calculation ambiguous. XMLHttpRequest's `upload.onprogress` event remains the standard approach for upload progress tracking, and many applications use XHR specifically for file uploads while using fetch for other requests.

Some workarounds exist, such as implementing custom ReadableStream sources that track bytes written, but these require manually managing stream construction and lack browser-native progress events.

### Cross-Origin Considerations

Fetch enforces CORS strictly. Requests to cross-origin URLs default to `mode: 'cors'`, requiring proper CORS headers from the server. The `no-cors` mode allows cross-origin requests but severely restricts response access—the Response object becomes opaque with no accessible body, headers, or status information beyond knowing the request succeeded.

Credentials (cookies, HTTP authentication) follow the `credentials` option. The default `same-origin` sends credentials only to same-origin URLs. Cross-origin credential inclusion requires both `credentials: 'include'` and server-side `Access-Control-Allow-Credentials: true` headers with explicit origin specification (no wildcards).

Preflight requests occur for non-simple requests—those with custom headers, methods beyond GET/POST/HEAD, or content types other than application/x-www-form-urlencoded, multipart/form-data, or text/plain. Servers must handle OPTIONS requests with appropriate CORS headers.

### Headers API Behavior

The Headers object implements an iterable interface, supporting `for...of` loops, spread operations, and destructuring. Headers are case-insensitive but preserve original casing. Multiple values for a single header are comma-concatenated per HTTP specifications.

Header guards prevent modification of certain headers based on context. Request headers have a `request` guard preventing modification of forbidden headers like `Host`, `Connection`, or `Content-Length`. Response headers have a `response` guard blocking forbidden response headers. Headers created via `new Headers()` have no guard, allowing unrestricted modification.

The `append()` method adds values to existing headers rather than replacing them, crucial for headers like `Set-Cookie` that support multiple values. The `set()` method replaces existing values entirely.

### Redirect Handling

Fetch follows redirects automatically by default (`redirect: 'follow'`), supporting up to 20 redirects. The final Response reflects the ultimate destination, with `response.url` showing the resolved URL after redirects and `response.redirected` indicating whether redirection occurred.

Setting `redirect: 'error'` causes promises to reject on any redirect attempt, useful for situations requiring explicit redirect handling or preventing redirect-based attacks.

The `redirect: 'manual'` mode provides a Response with type `'opaqueredirect'`, exposing minimal information. This mode enables Service Workers to handle redirects with custom logic while preventing redirect information leakage to page-level JavaScript.

### Type Safety and TypeScript Integration

Fetch's Response methods like `json()` return `Promise<any>` in TypeScript. Developers must provide type assertions or implement type guards for response data. Generic wrappers can improve type safety:

```typescript
async function fetchJSON<T>(url: string): Promise<T> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`HTTP error ${response.status}`);
  }
  return response.json();
}
```

[Inference] This pattern still relies on runtime trust that the server returns data matching type `T`, as TypeScript cannot validate actual network payloads. Runtime validation libraries like Zod or io-ts provide schema validation for robust type safety.

### Browser Compatibility and Polyfills

Fetch achieved widespread browser support by 2017, with polyfills available for older browsers. The `whatwg-fetch` polyfill provides fetch in environments lacking native support, though with limitations around streaming and advanced features.

Node.js lacked native fetch until version 17.5 (experimental) and 18.0 (stable). Prior to native support, libraries like `node-fetch` provided compatible implementations with Node.js-specific adaptations for streams and request handling.

Differences between browser and Node.js implementations exist around stream handling, file system access, and HTTP agent configuration. Node.js fetch exposes additional options for agent configuration, certificate validation, and DNS resolution that don't exist in browser contexts.

### Performance Characteristics

Fetch's promise-based architecture introduces microtask scheduling overhead compared to XHR's synchronous callback firing. [Inference] For high-frequency request scenarios, this overhead is generally negligible compared to network latency, but may be measurable in local or cached request benchmarks.

Response body consumption methods must be called—calling `response.json()` or other parsers is required even if the body isn't needed, as the stream must be consumed or closed. For fire-and-forget requests with irrelevant responses, explicitly consuming or canceling the body prevents memory leaks.

[Inference] Connection pooling and keep-alive behavior operate at the browser's network stack level, largely transparent to both XHR and fetch. Fetch's ability to clone requests potentially enables better connection reuse through request batching strategies, though this remains implementation-dependent.

### Migration Patterns

Common XHR-to-fetch migrations involve replacing callback patterns with promises or async/await, consolidating request configuration into single initialization objects, and switching from `readyState` checks to promise resolution.

Error handling requires explicit status checking in fetch, replacing XHR's event-based error callbacks. Timeout handling moves from XHR's `timeout` property to AbortSignal integration with timers.

Progress tracking for uploads presents the primary migration challenge, often requiring either XHR retention for upload-heavy operations or implementing custom progress mechanisms through Request body manipulation.

---

