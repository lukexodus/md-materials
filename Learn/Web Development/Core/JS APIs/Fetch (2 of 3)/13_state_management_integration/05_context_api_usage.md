## Context API Usage


### Request Destination Property

The `destination` property is a read-only attribute of the Request interface that describes the type of content being requested. It returns a string indicating what the fetch request is intended to retrieve, allowing user agents to make context-specific decisions about how to handle the request.

#### Available Destination Values

The destination property can return one of the following values:

- `""` (empty string) - Default value for destinations without specific values, including `fetch()`, `navigator.sendBeacon()`, `EventSource`, `XMLHttpRequest`, and `WebSocket`
- `"audio"` - Audio data, typically from `<audio>` elements
- `"audioworklet"` - Data for audio worklet, from `audioWorklet.addModule()`
- `"document"` - HTML or XML document from user-initiated top-level navigation
- `"embed"` - Embedded content from `<embed>` tags
- `"fencedframe"` - Content for fenced frames
- `"font"` - Font resources from CSS `@font-face`
- `"frame"` - Content from `<frame>` tags
- `"iframe"` - Content from `<iframe>` tags
- `"image"` - Images from `<img>`, SVG `<image>`, CSS `background-image`, `cursor`, `list-style-image`
- `"json"` - JSON resources
- `"manifest"` - Web app manifests
- `"object"` - Content from `<object>` tags
- `"paintworklet"` - Data for paint worklet
- `"report"` - Reporting endpoints
- `"script"` - JavaScript from `<script>` tags or `WorkerGlobalScope.importScripts()`
- `"serviceworker"` - Service worker scripts from `navigator.serviceWorker.register()`
- `"sharedworker"` - Shared worker scripts
- `"style"` - Stylesheets from `<link rel=stylesheet>` or CSS `@import`
- `"track"` - Text tracks from `<track>` tags
- `"video"` - Video data from `<video>` tags
- `"webidentity"` - Endpoints for verifying user identity (FedCM API)
- `"worker"` - Web worker scripts
- `"xslt"` - XSLT transforms

#### Browser Exposure and Service Worker Handling

The destination values are exposed through the `RequestDestination` enumeration in browsers, with two exceptions: `"serviceworker"` and `"webidentity"` are not reflected in the enumeration because fetches with these destinations bypass service workers entirely.

#### Usage in Code

```javascript
// Accessing destination from a Request object
const request = new Request('https://example.com/data');
console.log(request.destination); // "" (empty string for fetch())

// In a service worker, examining fetch event requests
self.addEventListener('fetch', (event) => {
  const destination = event.request.destination;
  
  if (destination === 'image') {
    // Handle image requests differently
    event.respondWith(
      caches.match(event.request)
        .then(response => response || fetch(event.request))
    );
  }
});
```

### Content Security Policy Integration

Request destinations play a crucial role in Content Security Policy (CSP) enforcement. The destination determines which CSP directive applies to a given request.

#### Destination-to-CSP Directive Mapping

Different destinations map to specific CSP directives:

- `"script"`, `"audioworklet"`, `"paintworklet"`, `"serviceworker"`, `"sharedworker"`, `"worker"` → `script-src`
- `"style"` → `style-src`
- `"image"` → `img-src`
- `"font"` → `font-src`
- `"audio"`, `"video"`, `"track"` → `media-src`
- `"manifest"` → `manifest-src`
- `"document"`, `"frame"`, `"iframe"` → `frame-src` or `child-src`
- `"object"`, `"embed"` → `object-src`
- Empty string (from `fetch()`) → `connect-src`

When a CSP policy doesn't define a specific directive, the check falls back to `default-src`.

#### CSP Challenges in Service Workers

Service workers introduce complexity to CSP enforcement. When a service worker intercepts a request using `fetch(event.request)`, the re-fetched request loses its original destination information, defaulting to an empty string. This causes CSP checks to use `connect-src` instead of the original directive.

**Example scenario:**

```javascript
// Page CSP: default-src 'self'; img-src *
// This allows images from any origin

self.addEventListener('fetch', (event) => {
  // event.request.destination is "image"
  
  // Creating new request loses destination context
  const newRequest = new Request(event.request);
  // newRequest.destination is "" (empty string)
  
  event.respondWith(fetch(newRequest));
  // This now uses connect-src instead of img-src for CSP
});
```

[Inference] Browsers perform multiple CSP checks in service worker scenarios:

1. Initial request checked against appropriate directive (e.g., `img-src` for images)
2. Service worker's fetch checked against `connect-src`
3. Response from service worker validated before returning to page

This multi-layered approach prevents CSP bypass, but requires service workers to have permissive `connect-src` policies for pass-through fetch operations.

### Script-Like Destinations

The specification defines certain destinations as "script-like" because they can execute code:

- `"audioworklet"`
- `"paintworklet"`
- `"script"`
- `"serviceworker"`
- `"sharedworker"`
- `"worker"`

**Note:** `"xslt"` can also cause script execution but isn't included in the script-like category as it may require different handling in some contexts.

#### MIME Type Validation for Script-Like Destinations

Requests with script-like destinations undergo additional validation. If the response's MIME type essence starts with `"audio/"`, `"image/"`, or `"video/"`, the request is blocked to prevent security issues.

### Subresource vs Non-Subresource Requests

Destinations are categorized into two types:

**Subresource requests** - Resources loaded as part of a page:

- `"audio"`, `"audioworklet"`, `"font"`, `"image"`, `"json"`, `"manifest"`, `"paintworklet"`, `"script"`, `"style"`, `"track"`, `"video"`, `"xslt"`, or empty string

**Non-subresource requests** - Navigation and worker contexts:

- `"document"`, `"embed"`, `"frame"`, `"iframe"`, `"object"`, `"report"`, `"serviceworker"`, `"sharedworker"`, `"worker"`

**Navigation requests** (subset of non-subresource):

- `"document"`, `"embed"`, `"frame"`, `"iframe"`, `"object"`

This categorization helps browsers apply different handling logic based on the nature of the request.

### Sec-Fetch-Dest Header

The browser automatically sends the `Sec-Fetch-Dest` HTTP header with requests, containing the destination value. This forbidden request header (cannot be modified by JavaScript) provides servers with context about how the resource will be used.

#### Server-Side Benefits

Servers can use `Sec-Fetch-Dest` to:

- Validate that requests match expected resource types
- Prevent resource type confusion attacks
- Apply appropriate security policies
- Optimize responses based on destination

**Example header values:**

```
Sec-Fetch-Dest: image
Sec-Fetch-Dest: script
Sec-Fetch-Dest: empty
Sec-Fetch-Dest: document
```

A cross-origin image request would include:

```
GET /photo.jpg HTTP/1.1
Host: cdn.example.com
Sec-Fetch-Dest: image
Sec-Fetch-Mode: no-cors
Sec-Fetch-Site: cross-site
```

Servers can verify the request is genuinely for an image and reject requests with mismatched destinations.

### Request Priority and Destination

Destinations influence request priority determination. According to the fetch specification, when a request's internal priority is null, the browser uses the request's priority, initiator, destination, and render-blocking properties to set an implementation-defined internal priority.

[Inference] Different destinations receive different default priorities:

- `"document"`, `"frame"`, `"iframe"` - Typically highest priority (navigation critical)
- `"script"`, `"style"`, `"font"` - High priority (render-blocking resources)
- `"image"` - Medium priority (visible content)
- `"audio"`, `"video"` - Variable priority (depends on visibility and playback state)
- Empty string from `fetch()` - Lower priority (developer-initiated)

The actual priority assignment is implementation-defined and may vary between browsers.

### Request Initiator

While not directly exposed to JavaScript, requests have an associated initiator property used internally for CSP and Mixed Content decisions. The initiator differs from destination in that it describes what triggered the request rather than what type of content is expected.

**Initiator values:**

- `""` (empty string) - Default
- `"download"` - Download operations
- `"imageset"` - Responsive image sets
- `"manifest"` - Web app manifest processing
- `"prefetch"` - Prefetch operations
- `"prerender"` - Prerender operations
- `"xslt"` - XSLT processing

[Inference] The initiator remains intentionally non-granular, serving primarily as a specification device rather than a detailed tracking mechanism. It helps distinguish between user-initiated actions and automatic browser behaviors when applying security policies.

### Deprecated Context Property

**Historical note:** The Request interface originally included a `context` property that has been completely replaced by `destination`. The `context` property was deprecated and removed from implementations.

```javascript
// Deprecated - no longer functional
const request = new Request('flowers.jpg');
const context = request.context; // Would return empty string

// Modern approach - use destination instead
const destination = request.destination;
```

The context property was relevant primarily in Service Worker API scenarios where workers needed to make decisions based on resource type. All functionality migrated to the more comprehensive `destination` property.

### Practical Service Worker Patterns

#### Destination-Based Caching Strategy

```javascript
self.addEventListener('fetch', (event) => {
  const { destination } = event.request;
  
  // Cache-first for images and fonts
  if (destination === 'image' || destination === 'font') {
    event.respondWith(
      caches.match(event.request)
        .then(cached => cached || fetch(event.request)
          .then(response => {
            const cache = caches.open('assets-v1');
            cache.then(c => c.put(event.request, response.clone()));
            return response;
          })
        )
    );
    return;
  }
  
  // Network-first for scripts and styles
  if (destination === 'script' || destination === 'style') {
    event.respondWith(
      fetch(event.request)
        .catch(() => caches.match(event.request))
    );
    return;
  }
  
  // Default: network only
  event.respondWith(fetch(event.request));
});
```

#### Cache-Only Policy for Specific Destinations

```javascript
self.addEventListener('fetch', (event) => {
  // Only serve scripts and styles from cache
  if (event.request.destination === 'script' || 
      event.request.destination === 'style') {
    event.respondWith(
      caches.match(event.request)
        .then(response => {
          if (response) return response;
          
          // Return error response instead of fetching
          return new Response('Resource not in cache', {
            status: 503,
            statusText: 'Service Unavailable'
          });
        })
    );
  }
});
```

#### Selective Request Blocking

```javascript
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  // Block third-party tracking scripts
  if (event.request.destination === 'script' && 
      url.origin !== location.origin &&
      url.hostname.includes('analytics')) {
    event.respondWith(
      new Response('', { status: 204 })
    );
    return;
  }
});
```

### Header Initialization Based on Destination

[Unverified] When browsers create requests for different HTML elements, they automatically initialize appropriate headers based on the destination:

**Image requests** (`destination: "image"`):

- `Accept: image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8`
- May include `Sec-CH-DPR`, `Sec-CH-Viewport-Width`, `Sec-CH-Width` client hints

**Script requests** (`destination: "script"`):

- `Accept: */*`
- May include CSP nonce headers

**Style requests** (`destination: "style"`):

- `Accept: text/css,*/*;q=0.1`

**Font requests** (`destination: "font"`):

- `Accept: */*`
- Often includes `Origin` header for CORS

**Fetch requests** (`destination: ""`):

- Headers depend entirely on developer specification
- No automatic Accept header initialization

This automatic header initialization explains why `<img>` tags successfully negotiate image formats while `fetch()` calls to the same URL might receive different responses without explicit Accept headers.

### Destination and Resource Hints

Resource hints like `<link rel="preload">` use the `as` attribute to specify destination:

```html
<link rel="preload" href="style.css" as="style">
<link rel="preload" href="font.woff2" as="font" crossorigin>
<link rel="preload" href="image.webp" as="image">
<link rel="prefetch" href="next-page.html" as="document">
```

The `as` attribute value maps directly to request destinations:

- `as="style"` → `destination: "style"`
- `as="script"` → `destination: "script"`
- `as="image"` → `destination: "image"`
- `as="font"` → `destination: "font"`
- `as="fetch"` → `destination: ""` (empty string)
- `as="document"` → `destination: "document"`

[Inference] This mapping ensures preloaded resources receive the same CSP treatment, priority, and header initialization as if they were loaded by their corresponding HTML elements. Without the correct `as` value, preloaded resources might violate CSP policies or receive incorrect response content.

### Cross-Origin Request Considerations

Destination affects CORS behavior and request mode:

**No-CORS requests** are restricted to specific destinations:

- Only `"audio"`, `"font"`, `"image"`, `"script"`, `"style"`, `"track"`, `"video"`, and empty string can use `mode: "no-cors"`
- Other destinations require CORS or same-origin mode

**CORS-safelisted methods and headers** apply differently based on destination:

- Simple requests (GET, HEAD, POST with specific content types) work across destinations
- Some destinations automatically trigger preflight requests due to headers

### Destination in Request Construction

When creating Request objects programmatically, the destination cannot be set directly through the constructor. It remains read-only and is determined by the context:

```javascript
// Destination is always "" for programmatic fetch
const req1 = new Request('https://example.com/api');
console.log(req1.destination); // ""

// Even when copying requests, destination becomes ""
const originalReq = new Request('https://example.com/image.jpg');
const copiedReq = new Request(originalReq);
console.log(copiedReq.destination); // ""

// Destination is set by browser for element-initiated requests
// (not accessible from JavaScript creation)
```

[Unverified] Some proposals have suggested adding a way to specify destination context for programmatic fetch calls to enable proper CSP handling and header initialization, but these remain unimplemented. The GitHub issue whatwg/fetch#43 discusses "initializing context/content specific fetch defaults" to address this limitation.

### Implementation Differences

#### Firefox Implementation

Firefox maps fetch destinations to internal `nsContentPolicyType` values:

- `TYPE_FETCH` - Default for programmatic fetch
- `TYPE_IMAGE`, `TYPE_INTERNAL_IMAGE`, `TYPE_INTERNAL_IMAGE_PRELOAD` - Images
- `TYPE_SCRIPT`, `TYPE_INTERNAL_SCRIPT`, `TYPE_INTERNAL_SCRIPT_PRELOAD` - Scripts
- `TYPE_STYLESHEET`, `TYPE_INTERNAL_STYLESHEET` - Styles
- `TYPE_FONT`, `TYPE_INTERNAL_FONT_PRELOAD` - Fonts
- `TYPE_MEDIA`, `TYPE_INTERNAL_AUDIO`, `TYPE_INTERNAL_VIDEO`, `TYPE_INTERNAL_TRACK` - Media

The internal types provide more granularity than the spec requires, distinguishing between external requests and internal browser operations. This granularity helps with features like preload hints and worker contexts.

#### Chrome Implementation

[Unverified] Chrome uses internal resource type enums rather than directly mapping destinations to priorities or CSP directives. The internal representation may differ from the exposed `destination` values while maintaining spec compliance.

### Debugging Destination Values

**In browser DevTools:**

1. Network panel → Select request → Headers tab → View `Sec-Fetch-Dest` header
2. Console: Examine Request objects directly

```javascript
// Log all fetch destinations
const originalFetch = window.fetch;
window.fetch = function(...args) {
  const request = new Request(...args);
  console.log('Fetch destination:', request.destination);
  return originalFetch.apply(this, args);
};
```

**In service workers:**

```javascript
self.addEventListener('fetch', (event) => {
  console.log({
    url: event.request.url,
    destination: event.request.destination,
    mode: event.request.mode,
    credentials: event.request.credentials
  });
});
```

### Security Implications

#### Resource Type Confusion Prevention

Destination values help prevent attacks where an attacker tricks a victim into loading a resource with incorrect expectations:

- A malicious script served with `Content-Type: image/png` would be blocked if requested with `destination: "image"`
- An HTML document served to an `<img>` tag cannot execute embedded scripts
- XSLT stylesheets must be requested with appropriate destination to execute

#### CSP Bypass Prevention

[Inference] Without destination information, CSP policies could be circumvented:

1. Attacker uploads malicious script as image to CDN
2. Page loads "image" via `fetch()` (empty destination → `connect-src`)
3. If `connect-src` allows CDN but `script-src` doesn't, attacker could potentially execute the script through `eval()` or similar

The destination property ensures proper CSP directive application at fetch time, combined with MIME type validation at execution time, creates defense in depth.

#### Service Worker Interception Transparency

The destination property allows service workers to maintain security properties of intercepted requests. A properly implemented service worker can preserve the original destination when re-fetching, though current APIs make this challenging due to Request constructor behavior.

### Future Considerations

**Potential enhancements discussed in specifications:**

1. **Destination context parameter** - Allow developers to explicitly specify destination for programmatic fetch calls to receive appropriate header initialization and CSP treatment
2. **Prefetch destination** - Dedicated destination for prefetched resources to enable proper CSP directive (prefetch-src)
3. **Request.destination preservation** - Maintaining destination when creating new Request from existing Request in service workers

These enhancements would address current limitations while maintaining backward compatibility. As of the knowledge cutoff date, these remain proposals rather than implemented features.

---

