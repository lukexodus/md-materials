## Request Object Creation


### Constructor Patterns and Initialization

#### Direct Constructor Instantiation

Request objects instantiate through the `Request` constructor, accepting a URL or existing Request as the first argument and an optional configuration object:

```javascript
const request = new Request('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer token123'
  },
  body: JSON.stringify({ key: 'value' })
});
```

The constructor performs several initialization tasks: normalizing the URL, validating method-body combinations, processing headers into a Headers object, and establishing the request's mode, credentials, and cache policies. [Inference] The constructor likely validates that GET and HEAD requests don't include bodies, throwing TypeError for invalid combinations.

#### Request Cloning from Existing Requests

Passing an existing Request to the constructor creates a new Request with inherited properties:

```javascript
const originalRequest = new Request('https://api.example.com/users');

const clonedRequest = new Request(originalRequest, {
  method: 'POST',
  body: JSON.stringify({ name: 'Alice' })
});
```

The new Request inherits all properties from the original unless explicitly overridden in the options object. This enables request templating where base configurations propagate to variations.

#### Cloning with the clone() Method

The `clone()` method creates a deep copy of a Request including its body stream:

```javascript
const request = new Request('https://api.example.com/data', {
  method: 'POST',
  body: readableStream
});

const cloned = request.clone();
```

Cloning becomes necessary when the same request body needs reading multiple times, since body streams are single-use. The clone creates an independent body stream that can be consumed separately from the original. [Inference] The implementation likely uses the underlying stream's tee() operation to split the body stream into two independent streams.

### URL and Resource Targeting

#### URL Parsing and Normalization

The Request constructor parses the URL string into components, resolving relative URLs against the document's base URL in browser contexts:

```javascript
// Absolute URL
const absolute = new Request('https://api.example.com/users/123');

// Relative URL (browser context)
const relative = new Request('/api/users/123');

// Relative URL with base
const withBase = new Request('../users/123', { base: 'https://api.example.com/posts/' });
```

[Inference] URL normalization includes converting the hostname to lowercase, removing default ports (80 for HTTP, 443 for HTTPS), and resolving path segments like `..` and `.`. Invalid URLs throw TypeError during construction.

#### URL Mutation Immutability

Request objects are immutable after creation. The URL cannot be modified after instantiation:

```javascript
const request = new Request('https://api.example.com/users');
request.url = 'https://other.com/users'; // No effect, url property is read-only
```

URL modifications require creating a new Request with the desired URL, potentially cloning other properties from the original request.

#### URLSearchParams Integration

Query parameters manipulate through URL construction, often combining with URLSearchParams:

```javascript
const params = new URLSearchParams({
  page: 2,
  limit: 50,
  sort: 'name'
});

const request = new Request(`https://api.example.com/users?${params}`);
// URL: https://api.example.com/users?page=2&limit=50&sort=name
```

This pattern separates query parameter logic from URL construction, enabling dynamic parameter building.

### HTTP Method Configuration

#### Method Selection and Constraints

The `method` property specifies the HTTP verb, accepting standard methods (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS) and custom methods:

```javascript
const getRequest = new Request('https://api.example.com/users', {
  method: 'GET'
});

const customRequest = new Request('https://api.example.com/resource', {
  method: 'CUSTOM-METHOD'
});
```

[Inference] The constructor normalizes method names to uppercase. Methods are case-insensitive during construction but stored in uppercase form.

#### Method-Body Validation

GET and HEAD requests cannot include request bodies. [Inference] The constructor throws TypeError when these methods specify a body:

```javascript
// Throws TypeError
const invalidRequest = new Request('https://api.example.com/users', {
  method: 'GET',
  body: JSON.stringify({ data: 'value' })
});
```

This validation enforces HTTP semantic correctness, preventing protocol violations.

#### Safe and Idempotent Method Semantics

[Inference] While the Request constructor doesn't enforce safe or idempotent semantics beyond body validation, the method choice affects browser behavior for caching, prefetching, and CORS preflight decisions. GET, HEAD, and OPTIONS typically trigger different caching and security behaviors than POST, PUT, or DELETE.

### Header Construction and Management

#### Headers Object Creation

Headers initialize through several patterns:

```javascript
// Object literal
const request1 = new Request(url, {
  headers: {
    'Content-Type': 'application/json',
    'X-Custom-Header': 'value'
  }
});

// Headers instance
const headers = new Headers();
headers.append('Content-Type', 'application/json');
headers.append('Authorization', 'Bearer token');

const request2 = new Request(url, {
  headers: headers
});

// Array of tuples
const request3 = new Request(url, {
  headers: [
    ['Content-Type', 'application/json'],
    ['Authorization', 'Bearer token']
  ]
});
```

All patterns create a Headers object internally. The Request's headers property returns a Headers instance that can be manipulated before the request is used.

#### Header Normalization Rules

Header names normalize to lowercase internally, though retrieval is case-insensitive:

```javascript
const request = new Request(url, {
  headers: {
    'Content-Type': 'application/json',
    'content-type': 'text/plain' // Overwrites previous
  }
});

request.headers.get('Content-Type'); // Returns the last set value
request.headers.get('content-type'); // Same value, case-insensitive
```

[Inference] When duplicate headers appear with different casing, the last value typically wins, though some headers like `Set-Cookie` may accumulate multiple values.

#### Forbidden Headers Protection

Certain headers cannot be set programmatically for security reasons. [Inference] The Request constructor or Headers object silently ignores or prevents modification of forbidden headers including:

- `Accept-Charset`
- `Accept-Encoding`
- `Access-Control-Request-Headers`
- `Access-Control-Request-Method`
- `Connection`
- `Content-Length`
- `Cookie`
- `Date`
- `DNT`
- `Expect`
- `Host`
- `Keep-Alive`
- `Origin`
- `Referer`
- `TE`
- `Trailer`
- `Transfer-Encoding`
- `Upgrade`
- `Via`
- Headers starting with `Proxy-` or `Sec-`

These restrictions prevent bypassing browser security mechanisms or corrupting the HTTP message structure.

#### Guard Concept in Headers

Headers objects have internal guards (`immutable`, `request`, `request-no-cors`, `response`, `none`) that control mutability. [Inference] Request headers typically use `request` guard, allowing most modifications except forbidden headers. The guard prevents inappropriate header manipulation based on context.

### Body Construction and Serialization

#### Body Type Compatibility

Request bodies accept multiple data types:

```javascript
// String body
const stringRequest = new Request(url, {
  method: 'POST',
  body: 'plain text data'
});

// Blob body
const blobRequest = new Request(url, {
  method: 'POST',
  body: new Blob(['data'], { type: 'application/octet-stream' })
});

// FormData body
const formData = new FormData();
formData.append('username', 'alice');
formData.append('file', fileBlob);

const formRequest = new Request(url, {
  method: 'POST',
  body: formData
});

// ArrayBuffer body
const buffer = new ArrayBuffer(8);
const bufferRequest = new Request(url, {
  method: 'POST',
  body: buffer
});

// URLSearchParams body
const params = new URLSearchParams({ key: 'value' });
const paramsRequest = new Request(url, {
  method: 'POST',
  body: params
});

// ReadableStream body
const stream = new ReadableStream({
  start(controller) {
    controller.enqueue('chunk1');
    controller.enqueue('chunk2');
    controller.close();
  }
});
const streamRequest = new Request(url, {
  method: 'POST',
  body: stream
});
```

Each body type serializes differently and may automatically set appropriate Content-Type headers if not specified.

#### Automatic Content-Type Inference

[Inference] When body is provided without explicit Content-Type header, the Request constructor infers the type:

- FormData → `multipart/form-data; boundary=...`
- URLSearchParams → `application/x-www-form-urlencoded;charset=UTF-8`
- String → `text/plain;charset=UTF-8`
- Blob → Uses the Blob's type property
- ArrayBuffer/TypedArray → No automatic Content-Type

Explicitly setting Content-Type overrides automatic inference:

```javascript
const request = new Request(url, {
  method: 'POST',
  body: JSON.stringify({ key: 'value' }),
  headers: {
    'Content-Type': 'application/json' // Must set explicitly for JSON strings
  }
});
```

#### Body Stream Consumption and Locking

Request bodies based on ReadableStream are single-use. [Inference] Reading the body locks the stream, preventing subsequent reads:

```javascript
const request = new Request(url, {
  method: 'POST',
  body: 'data'
});

await request.text(); // Consumes the body
await request.json(); // Throws TypeError: body already consumed
```

The `bodyUsed` property indicates consumption status:

```javascript
console.log(request.bodyUsed); // false
await request.text();
console.log(request.bodyUsed); // true
```

Cloning before consumption enables multiple reads:

```javascript
const original = new Request(url, { method: 'POST', body: 'data' });
const clone = original.clone();

await original.text(); // Consumes original
await clone.text();    // Consumes clone independently
```

#### Body Null Handling

Omitting the body or explicitly setting it to null creates a request without a body:

```javascript
const request1 = new Request(url); // No body
const request2 = new Request(url, { body: null }); // Explicitly null body

console.log(request1.body); // null
console.log(request2.body); // null
```

[Inference] The `body` property returns null for bodiless requests, and body reading methods like `text()` or `json()` resolve with empty or default values.

### Request Mode Configuration

#### Mode Values and Security Implications

The `mode` property controls CORS behavior and cross-origin restrictions:

```javascript
// Same-origin only
const sameOrigin = new Request(url, {
  mode: 'same-origin'
});

// CORS enabled
const cors = new Request(url, {
  mode: 'cors'
});

// No CORS (limited functionality)
const noCors = new Request(url, {
  mode: 'no-cors'
});

// Navigation mode (browser navigation)
const navigate = new Request(url, {
  mode: 'navigate'
});
```

**same-origin**: Requests fail if targeting different origins. This mode enforces strict origin checking, throwing TypeError for cross-origin URLs.

**cors**: Enables CORS protocol, sending `Origin` header and respecting CORS headers in responses. Preflight OPTIONS requests occur for non-simple requests.

**no-cors**: Allows cross-origin requests but severely restricts response access. [Inference] Responses have opaque type, preventing JavaScript from reading response body, headers, or status. This mode suits fire-and-forget requests like analytics beacons where response data is unnecessary.

**navigate**: Reserved for browser navigation requests. [Inference] User-created Requests with navigate mode may have limited functionality or throw errors in certain contexts.

#### Mode-Credentials Interaction

Mode affects credentials inclusion logic. [Inference] `same-origin` mode includes credentials automatically for same-origin requests. `cors` mode follows the credentials policy explicitly. `no-cors` mode may include credentials based on specific rules but limits response inspection.

### Credentials Policy Management

#### Credentials Configuration Options

The `credentials` property controls cookie, authorization headers, and TLS client certificate inclusion:

```javascript
// Omit credentials
const omit = new Request(url, {
  credentials: 'omit'
});

// Same-origin credentials only
const sameOrigin = new Request(url, {
  credentials: 'same-origin'
});

// Always include credentials
const include = new Request(url, {
  credentials: 'include'
});
```

**omit**: Never sends credentials regardless of origin. Cookies and authorization headers excluded from the request.

**same-origin**: Includes credentials only when requesting same-origin resources. Cross-origin requests omit credentials.

**include**: Sends credentials for both same-origin and cross-origin requests. For CORS requests, the server must respond with `Access-Control-Allow-Credentials: true` and cannot use wildcard `Access-Control-Allow-Origin`.

#### Third-Party Cookie Implications

[Inference] The `include` credentials mode sends third-party cookies in cross-origin requests, subject to browser privacy settings and SameSite cookie attributes. Browsers increasingly restrict third-party cookies, potentially blocking credentials even when `include` is specified.

#### Authorization Header Handling

[Inference] The credentials policy primarily affects cookies and HTTP authentication. Explicitly set Authorization headers in the headers object typically send regardless of credentials policy, though implementation details may vary.

### Cache Control Strategy

#### Cache Mode Options

The `cache` property determines caching behavior:

```javascript
// Default caching behavior
const defaultCache = new Request(url, {
  cache: 'default'
});

// No cache interaction
const noStore = new Request(url, {
  cache: 'no-store'
});

// Reload from origin
const reload = new Request(url, {
  cache: 'reload'
});

// Validate cached response
const noCache = new Request(url, {
  cache: 'no-cache'
});

// Use cache if available
const forceCache = new Request(url, {
  cache: 'force-cache'
});

// Only use cache, fail if not cached
const onlyIfCached = new Request(url, {
  cache: 'only-if-cached'
});
```

**default**: Follows standard HTTP caching semantics, checking cache freshness and making conditional requests with `If-Modified-Since` or `If-None-Match` headers.

**no-store**: Bypasses cache completely, neither reading from nor writing to cache. Each request fetches fresh from origin.

**reload**: Ignores cache for retrieval but updates cache with the response. Forces fresh fetch while updating cached copy.

**no-cache**: Validates cached responses before use, sending conditional requests to origin. If cached response is still valid (304 Not Modified), uses cached version.

**force-cache**: Uses cached response regardless of freshness. Only fetches from origin if no cached response exists.

**only-if-cached**: Only succeeds if a cached response exists. Fails without network access if cache misses. [Inference] This mode is restricted to `same-origin` mode requests due to security implications of revealing cache state across origins.

#### Cache Mode and Request Mode Interaction

[Inference] `only-if-cached` requires `mode: 'same-origin'`. Using `only-if-cached` with other modes throws TypeError during Request construction, preventing cache-based timing attacks across origins.

### Redirect Handling Configuration

#### Redirect Policy Options

The `redirect` property controls automatic redirect following:

```javascript
// Follow redirects automatically (default)
const follow = new Request(url, {
  redirect: 'follow'
});

// Throw error on redirect
const error = new Request(url, {
  redirect: 'error'
});

// Return redirect response without following
const manual = new Request(url, {
  redirect: 'manual'
});
```

**follow**: Automatically follows HTTP redirects (301, 302, 303, 307, 308), returning the final response. [Inference] Browser implementations typically limit redirect chains to 20 redirects to prevent infinite loops.

**error**: Treats redirects as network errors, rejecting the fetch promise with TypeError. Useful when redirects indicate configuration problems or unexpected behavior.

**manual**: Returns the redirect response (with status 301-308) without following it. Response is opaque, and [Inference] the `Location` header may be inaccessible depending on CORS policy. This mode enables custom redirect logic.

#### Redirect Security Considerations

[Inference] Automatic redirect following can leak credentials or sensitive headers to redirect targets. When redirecting cross-origin, browsers may strip certain headers like `Authorization` unless explicitly allowed. The `follow` mode's behavior with credentials depends on the redirect status code and origin relationships.

### Referrer Policy Configuration

#### Referrer Property Setting

The `referrer` property specifies the Referer header value:

```javascript
// Explicit referrer URL
const withReferrer = new Request(url, {
  referrer: 'https://example.com/page'
});

// No referrer
const noReferrer = new Request(url, {
  referrer: ''
});

// Client-based referrer (default)
const clientReferrer = new Request(url, {
  referrer: 'about:client'
});
```

Setting an empty string suppresses the Referer header. The value `'about:client'` indicates the referrer should derive from the document's URL in browser contexts.

#### Referrer Policy Directives

The `referrerPolicy` property controls how much referrer information includes:

```javascript
const request = new Request(url, {
  referrerPolicy: 'no-referrer'
});
```

Available policies:

- **no-referrer**: Never send Referer header
- **no-referrer-when-downgrade**: Send referrer to same-security destinations (HTTPS to HTTPS, HTTP to HTTP/HTTPS), omit when downgrading (HTTPS to HTTP)
- **origin**: Send only origin (scheme, host, port), not full URL
- **origin-when-cross-origin**: Send full URL for same-origin, only origin for cross-origin
- **same-origin**: Send referrer to same-origin requests only
- **strict-origin**: Send origin to same-security destinations, nothing when downgrading
- **strict-origin-when-cross-origin**: Send full URL to same-origin, origin to cross-origin same-security, nothing when downgrading
- **unsafe-url**: Always send full URL regardless of security

[Inference] The default policy varies by browser and context, typically `strict-origin-when-cross-origin` in modern browsers to balance functionality and privacy.

### Integrity Verification

#### Subresource Integrity String

The `integrity` property specifies cryptographic hashes for response verification:

```javascript
const request = new Request(url, {
  integrity: 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC'
});
```

[Inference] The fetch implementation verifies the response body against the hash. Mismatches cause the fetch to fail with a network error. Multiple algorithms and hashes can be specified space-separated: `'sha256-abc... sha384-def...'`.

#### Integrity Check Behavior

[Inference] Integrity checks apply to the response body after decompression but before providing it to application code. The check occurs transparently - application code only sees success or failure, not the verification process details.

Integrity strings follow the format: `algorithm-base64hash`. Supported algorithms typically include `sha256`, `sha384`, and `sha512`.

### Signal Integration for Cancellation

#### AbortSignal Association

The `signal` property associates an AbortSignal enabling request cancellation:

```javascript
const controller = new AbortController();

const request = new Request(url, {
  signal: controller.signal
});

// Later, cancel the request
controller.abort();
```

When the signal aborts, any pending fetch using this Request immediately fails with an `AbortError` DOMException.

#### Signal State at Construction

[Inference] If the signal is already aborted at Request construction time, the Request is still created successfully. The abortion only affects fetch operations using the Request:

```javascript
const controller = new AbortController();
controller.abort(); // Abort immediately

const request = new Request(url, {
  signal: controller.signal
}); // Succeeds

fetch(request); // Fails immediately with AbortError
```

#### Multiple Fetch with Same Signal

A single Request with an aborted signal can be used in multiple fetch calls, all failing immediately:

```javascript
const controller = new AbortController();
const request = new Request(url, { signal: controller.signal });

const promise1 = fetch(request.clone());
const promise2 = fetch(request.clone());

controller.abort(); // Both fetches fail
```

### Priority Hints

#### Priority Property Configuration

The `priority` property provides hints about request importance:

```javascript
const highPriority = new Request(url, {
  priority: 'high'
});

const lowPriority = new Request(url, {
  priority: 'low'
});

const autoPriority = new Request(url, {
  priority: 'auto'
});
```

**high**: Indicates critical resources that should load as quickly as possible.

**low**: Indicates non-critical resources that can defer to higher priority loads.

**auto**: Allows browser default prioritization based on resource type and context.

[Inference] Priority hints are advisory - browsers use them to optimize resource loading but may override based on other factors like resource type, visibility, or network conditions. The actual impact varies significantly across browsers and implementations.

### Keepalive Configuration

#### Keepalive Flag Purpose

The `keepalive` property enables requests to outlive the page:

```javascript
const keepaliveRequest = new Request(url, {
  method: 'POST',
  body: analyticsData,
  keepalive: true
});
```

[Inference] Setting `keepalive: true` allows the fetch to continue even if the user navigates away or closes the tab. This suits analytics beacons or cleanup operations that should complete regardless of page lifetime.

#### Keepalive Limitations

[Inference] Keepalive requests face strict size limitations (typically 64KB) to prevent resource exhaustion from abandoned pages. Exceeding the limit throws an error during fetch, not during Request construction. The limit applies to the total keepalive request payload across all pending keepalive requests from the origin.

### Duplex Communication Mode

#### Duplex Property for Streaming

The `duplex` property controls bidirectional communication with streaming bodies:

```javascript
const request = new Request(url, {
  method: 'POST',
  body: readableStream,
  duplex: 'half'
});
```

[Inference] The `duplex: 'half'` value allows uploading streaming request bodies while receiving the response. This enables upload progress tracking or streaming data that generates during the upload phase.

**half**: Currently the only specified value, indicating half-duplex communication where request upload and response reception can overlap but not simultaneous bidirectional streaming.

[Inference] Full duplex support may be specified in future standards but isn't currently available through the Request API. Half-duplex allows response headers and partial response body to arrive before request body completes uploading.

### Request Property Immutability

#### Frozen State After Construction

Request objects are immutable after creation. Properties are read-only:

```javascript
const request = new Request(url, {
  method: 'GET'
});

request.method = 'POST'; // No effect, property is read-only
request.url = 'https://other.com'; // No effect
```

Headers are mutable through the Headers object methods, but the headers property itself cannot be reassigned:

```javascript
request.headers.set('X-Custom', 'value'); // Works
request.headers = new Headers(); // No effect
```

#### Rationale for Immutability

[Inference] Immutability prevents accidental modification of requests after creation, particularly important when requests pass through multiple functions or middleware. It ensures request integrity and makes behavior predictable - a Request has the same properties throughout its lifetime.

### Factory Pattern Alternatives

#### Builder Pattern Implementation

Custom builder patterns enable incremental request construction:

```javascript
class RequestBuilder {
  constructor(url) {
    this.url = url;
    this.options = {};
  }
  
  method(method) {
    this.options.method = method;
    return this;
  }
  
  header(name, value) {
    if (!this.options.headers) {
      this.options.headers = {};
    }
    this.options.headers[name] = value;
    return this;
  }
  
  body(body) {
    this.options.body = body;
    return this;
  }
  
  mode(mode) {
    this.options.mode = mode;
    return this;
  }
  
  build() {
    return new Request(this.url, this.options);
  }
}

// Usage
const request = new RequestBuilder('https://api.example.com/data')
  .method('POST')
  .header('Content-Type', 'application/json')
  .body(JSON.stringify({ key: 'value' }))
  .mode('cors')
  .build();
```

This pattern provides fluent API for complex request construction, improving readability for multi-option requests.

#### Template Pattern for Base Configuration

Template requests establish common configurations:

```javascript
const baseRequest = new Request('https://api.example.com', {
  mode: 'cors',
  credentials: 'include',
  headers: {
    'Authorization': 'Bearer token',
    'Content-Type': 'application/json'
  }
});

function createAPIRequest(path, options = {}) {
  return new Request(baseRequest.url + path, {
    ...baseRequest,
    headers: new Headers(baseRequest.headers),
    ...options
  });
}

const userRequest = createAPIRequest('/users', { method: 'POST', body: userData });
```

[Inference] Spreading baseRequest copies primitive properties but not Headers objects. Headers require explicit cloning to prevent shared mutations.

### Memory and Performance Considerations

#### Request Object Allocation Cost

Each Request instantiation allocates memory for the Request object, Headers object, and potentially body stream objects. [Inference] Creating numerous Request objects in tight loops or high-frequency code paths may create garbage collection pressure.

Reusing Request objects when possible reduces allocations:

```javascript
// Less efficient - creates new Request per call
function fetchUser(id) {
  return fetch(new Request(`https://api.example.com/users/${id}`));
}

// More efficient - reuses base configuration
const baseRequest = new Request('https://api.example.com/users/', {
  mode: 'cors',
  credentials: 'include'
});

function fetchUser(id) {
  return fetch(new Request(baseRequest.url + id, baseRequest));
}
```

#### Body Stream Memory Implications

Large request bodies, particularly streaming bodies, consume memory proportional to buffered data. [Inference] Creating Request objects with large bodies doesn't immediately copy the data - ReadableStream bodies remain lazy until consumed. However, cloning requests with large bodies may duplicate stream buffers.

```javascript
const largeFile = new Blob([largeArrayBuffer]);
const request = new Request(url, { method: 'POST', body: largeFile });

// Clone potentially duplicates buffer
const clone = request.clone();
```

#### Header Optimization

Headers objects allocate storage for header entries. [Inference] Excessive headers increase Request memory footprint, though typically negligible compared to body sizes:

```javascript
// Minimal overhead
const request = new Request(url, {
  headers: {
    'Content-Type': 'application/json'
  }
});

// Larger overhead with many headers
const request = new Request(url, {
  headers: {
    'Header-1': 'value1',
    'Header-2': 'value2',
    // ... many headers
    'Header-50': 'value50'
  }
});
```

### Validation and Error Handling

#### Constructor Validation Errors

Request construction throws TypeError for invalid configurations:

```javascript
// Invalid URL
try {
  new Request('not a url');
} catch (e) {
  console.log(e instanceof TypeError); // true
}

// Invalid method-body combination
try {
  new Request(url, {
    method: 'GET',
    body: 'data'
  });
} catch (e) {
  console.log(e instanceof TypeError); // true
}

// Invalid mode
try {
  new Request(url, {
    mode: 'invalid-mode'
  });
} catch (e) {
  console.log(e instanceof TypeError); // true
}
```

[Inference] Validation occurs synchronously during construction, making invalid configurations immediately detectable through try-catch.

#### Property Access Error Conditions

[Inference] Accessing Request properties doesn't throw errors under normal circumstances. Properties return their values or defaults even for edge cases:

```javascript
const request = new Request(url);

console.log(request.body); // null (no body)
console.log(request.headers.get('Nonexistent')); // null
console.log(request.url); // The full URL string
```

Errors during property access would indicate implementation bugs rather than expected behavior.

#### Body Reading Error Scenarios

Body reading methods throw when bodies are already consumed or when the Request is disturbed:

```javascript
const request = new Request(url, { method: 'POST', body: 'data' });

await request.text();

try {
  await request.json(); // Body already consumed
} catch (e) {
  console.log(e instanceof TypeError); // true
}
```

[Inference] The bodyUsed property provides non-throwing detection of consumption state before attempting reads.

---

