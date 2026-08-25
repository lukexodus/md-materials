## fetch() Function Signature


### Basic Syntax

```typescript
fetch(resource)
fetch(resource, options)
```

### Parameters

#### `resource` (required)

Defines the resource to fetch. Can be either a string, any object with a stringifier (like a URL object) that provides the URL, or a Request object.

**String/URL types:**

- The URL may be relative to the base URL, which is the document's baseURI in a window context, or WorkerGlobalScope.location in a worker context
- Accepts `URL` objects with stringifiers

**Request object:**

- A constructed `Request` instance containing pre-configured settings

#### `options` (optional)

A RequestInit object containing any custom settings to apply to the request.

### Return Value

A Promise that resolves to a Response object.

**Important behaviors:**

- The promise resolves as soon as the server responds with headers, even if the server response is an HTTP error status
- A fetch() promise does not reject if the server responds with HTTP status codes that indicate errors (404, 504, etc.)
- The promise only rejects for network-level failures

### Exceptions

**`AbortError` DOMException** - The request was aborted due to a call to the AbortController abort() method

**`NotAllowedError` DOMException** - Thrown if use of the Topics API is specifically disallowed by a browsing-topics Permissions Policy, and a fetch() request was made with browsingTopics: true

**`TypeError`** - Can occur for the following reasons: the requested URL is invalid, the requested URL includes credentials, the RequestInit object passed as the value of options included properties with invalid values, the request is blocked by a permissions policy, or there is a network error

---

### RequestInit Options Object

The RequestInit dictionary represents the set of options that can be used to configure a fetch request.

#### Option Merging Behavior

You can construct a Request with a RequestInit, and pass the Request to a fetch() call along with another RequestInit. If you do this, and the same option is set in both places, then the value passed directly into fetch() is used.

#### Available Options

##### `method`

**Type:** String  
**Default:** `"GET"`  
The request method (e.g., `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `HEAD`, `OPTIONS`)

##### `headers`

**Type:** `Headers` object or object literal  
**Default:** undefined  
Any headers you want to add to your request, contained within a Headers object or an object literal whose keys are the names of headers and whose values are the header values

**Restrictions:**

- Many headers are set automatically by the browser and can't be set by a script: these are called Forbidden request headers
- If the mode option is set to no-cors, you can only set CORS-safelisted request headers

**Example formats:**

```javascript
// Object literal
{ headers: { "Content-Type": "application/json" } }

// Headers object
const myHeaders = new Headers();
myHeaders.append("Content-Type", "application/json");
{ headers: myHeaders }
```

##### `body`

**Type:** String, ArrayBuffer, Blob, DataView, File, FormData, TypedArray, URLSearchParams, or ReadableStream  
**Default:** undefined  
The request body contains content to send to the server, for example in a POST or PUT request

**Note:** `GET` and `HEAD` requests cannot have a body

##### `mode`

**Type:** String  
**Default:** `"cors"`  
Sets cross-origin behavior for the request

**Values:**

- **`same-origin`** - Disallows cross-origin requests. If a same-origin request is sent to a different origin, the result is a network error
- **`cors`** - If the request is cross-origin then it will use the Cross-Origin Resource Sharing (CORS) mechanism. Only CORS-safelisted response headers are exposed in the response
- **`no-cors`** - Disables CORS for cross-origin requests. This restricts methods to `HEAD`, `GET`, or `POST`, limits headers to CORS-safelisted request headers, and the response is opaque, meaning that its headers and body are not available to JavaScript, and its status code is always 0
- **`navigate`** - Used only by HTML navigation. A navigate request is created only while navigating between documents

##### `credentials`

**Type:** String  
**Default:** `"same-origin"`  
Controls whether or not the browser sends credentials with the request, as well as whether any Set-Cookie response headers are respected

**Values:**

- **`omit`** - Never send credentials in the request or include credentials in the response
- **`same-origin`** - Only send and include credentials for same-origin requests
- **`include`** - Always include credentials, even for cross-origin requests

**Security note:** Including credentials in cross-origin requests can make a site vulnerable to CSRF attacks, so even if credentials is set to include, the server must also agree to their inclusion by including the Access-Control-Allow-Credentials in its response

##### `cache`

**Type:** String  
**Default:** `"default"`  
The cache mode for the request

**Values:**

- **`default`** - The browser looks in its HTTP cache for a response matching the request. If there is a match and it is fresh, it will be returned from the cache. If there is a match but it is stale, the browser will make a conditional request to the remote server
- **`no-store`** - The browser fetches the resource from the remote server without first looking in the cache, and will not update the cache with the downloaded resource
- **`reload`** - The browser fetches the resource from the remote server without first looking in the cache, but then will update the cache with the downloaded resource
- **`no-cache`** - The browser looks in its HTTP cache for a response matching the request. If there is a match, fresh or stale, the browser will make a conditional request to the remote server
- **`force-cache`** - The browser looks in its HTTP cache for a response matching the request. If there is a match, fresh or stale, it will be returned from the cache. If there is no match, the browser will make a normal request
- **`only-if-cached`** (Experimental) - The browser looks in its HTTP cache for a response matching the request. If there is a match, fresh or stale, it will be returned from the cache. If there is no match, a network error is returned. Can only be used with `mode: "same-origin"`

##### `redirect`

**Type:** String  
**Default:** `"follow"`  
Determines the browser's behavior in case the server replies with a redirect status

**Values:**

- **`follow`** - Automatically follow redirects
- **`error`** - Reject the promise with a network error when a redirect status is returned
- **`manual`** - Return a response with almost all fields filtered out, to enable a service worker to store the response and later replay it

##### `referrer`

**Type:** String  
**Default:** `"about:client"`  
A string specifying the value to use for the request's Referer header

**Values:**

- **Same-origin URL** - Set the Referer header to the given value. Relative URLs are resolved relative to the URL of the page that made the request
- **Empty string (`""`)** - Omit the Referer header
- **`"about:client"`** - Set the Referer header to the default value for the context of the request

##### `referrerPolicy`

**Type:** String  
**Default:** undefined  
A string that sets a policy for the Referer header. The syntax and semantics of this option are exactly the same as for the Referrer-Policy header

Values: `no-referrer`, `no-referrer-when-downgrade`, `origin`, `origin-when-cross-origin`, `same-origin`, `strict-origin`, `strict-origin-when-cross-origin`, `unsafe-url`

##### `integrity`

**Type:** String  
**Default:** `""`  
Contains the subresource integrity value of the request

**Format:** `<hash-algo>-<hash-source>` where:

- hash-algo is one of the following values: sha256, sha384, or sha512
- hash-source is the Base64-encoding of the result of hashing the resource with the specified hash algorithm

##### `signal`

**Type:** `AbortSignal`  
**Default:** undefined  
An AbortSignal. If this option is set, the request can be canceled by calling abort() on the corresponding AbortController

##### `keepalive`

**Type:** Boolean  
**Default:** `false`  
When set to true, the browser will not abort the associated request if the page that initiated it is unloaded before the request is complete

**Benefits:**

- Enables a fetch() request to send analytics at the end of a session even if the user navigates away from or closes the page
- You can use HTTP methods other than POST, customize request properties, and access the server response via the fetch Promise fulfillment
- It is also available in service workers

**Limitation:** The body size for keepalive requests is limited to 64 kibibytes

##### `priority`

**Type:** String  
**Default:** `"auto"`  
Specifies the priority of the fetch request relative to other requests of the same type

**Values:**

- **`high`** - A high priority fetch request relative to other requests of the same type
- **`low`** - A low priority fetch request relative to other requests of the same type
- **`auto`** - No user preference for the fetch priority

##### `duplex` (Experimental)

**Type:** String  
**Default:** undefined  
Controls duplex behavior of the request. If this is present it must have the value half, meaning that the browser must send the entire request before processing the response

**Requirement:** This option must be present when body is a ReadableStream

##### `attributionReporting` (Deprecated)

**Type:** Object  
**Default:** undefined  
Indicates that you want the request's response to be able to register a JavaScript-based attribution source or attribution trigger

**Properties:**

- `eventSourceEligible` (boolean) - If set to true, the request's response is eligible to register an attribution source
- `triggerEligible` (boolean) - If set to true, the request's response is eligible to register an attribution trigger

##### `browsingTopics` (Deprecated)

**Type:** Boolean  
**Default:** undefined  
A boolean specifying that the selected topics for the current user should be sent in a Sec-Browsing-Topics header with the associated request

---

### TypeScript Definition

```typescript
function fetch(
  resource: RequestInfo | URL,
  options?: RequestInit
): Promise<Response>;

type RequestInfo = Request | string;

interface RequestInit {
  method?: string;
  headers?: HeadersInit;
  body?: BodyInit | null;
  mode?: RequestMode;
  credentials?: RequestCredentials;
  cache?: RequestCache;
  redirect?: RequestRedirect;
  referrer?: string;
  referrerPolicy?: ReferrerPolicy;
  integrity?: string;
  signal?: AbortSignal | null;
  keepalive?: boolean;
  priority?: RequestPriority;
  duplex?: RequestDuplex;
  attributionReporting?: AttributionReportingRequestOptions;
  browsingTopics?: boolean;
}

type RequestMode = "cors" | "no-cors" | "same-origin" | "navigate";
type RequestCredentials = "omit" | "same-origin" | "include";
type RequestCache = "default" | "no-store" | "reload" | "no-cache" | "force-cache" | "only-if-cached";
type RequestRedirect = "follow" | "error" | "manual";
type RequestPriority = "high" | "low" | "auto";
type RequestDuplex = "half";

type HeadersInit = Headers | string[][] | Record<string, string>;
type BodyInit = Blob | BufferSource | FormData | URLSearchParams | ReadableStream | string;
```

---

