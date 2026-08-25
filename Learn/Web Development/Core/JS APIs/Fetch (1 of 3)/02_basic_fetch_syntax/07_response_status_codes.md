## Response Status Codes


### 1xx Informational Responses

These interim status codes indicate that the server has received the request and is continuing to process it. The client should wait for the final response.

**100 Continue**

Indicates the server has received the request headers and the client should proceed to send the request body. This is used with the `Expect: 100-continue` request header, allowing clients to check if the server will accept the request before transmitting potentially large bodies. If the server rejects the request based on headers alone, it responds with an appropriate error status instead of 100, saving bandwidth.

**101 Switching Protocols**

The server agrees to switch protocols as requested by the client via the `Upgrade` header. Common uses include upgrading from HTTP to WebSocket. The response includes an `Upgrade` header specifying the new protocol. After this response, all subsequent communication uses the new protocol.

**102 Processing** (WebDAV)

Indicates the server has received and is processing the request, but no response is available yet. This prevents the client from timing out on long-running operations. Defined in WebDAV (RFC 2518).

**103 Early Hints**

Allows the server to send preliminary response headers before the final response. Primarily used to hint at resources the client should preload (via `Link` headers), improving page load performance. While processing continues, the client can start fetching critical resources like CSS or JavaScript files.

### 2xx Success

These codes indicate the request was successfully received, understood, and accepted.

**200 OK**

The request succeeded. The meaning depends on the HTTP method:

- **GET**: The resource representation is transmitted in the response body
- **HEAD**: Headers are sent without a body
- **POST**: The result of the action is in the response body
- **PUT/PATCH**: The updated resource representation may be included
- **TRACE**: The request message as received by the server

This is the most common success response.

**201 Created**

A new resource was successfully created, typically in response to POST or PUT requests. The `Location` header should contain the URI of the newly created resource. The response body may include a representation of the new resource or a link to it. The resource must exist at the specified location before the response is sent.

**202 Accepted**

The request has been accepted for processing, but processing is not complete. This is used for asynchronous operations where the server acknowledges receipt but will process the request later. The response should include information about the request's status or where to monitor progress. No guarantee exists that the request will ultimately succeed.

**203 Non-Authoritative Information**

The request succeeded, but the returned metadata differs from the origin server's version. This occurs when a transforming proxy modifies headers (e.g., adding virus scanning results or content warnings). The payload is still from the origin server, but headers may come from a local or third-party copy.

**204 No Content**

The request succeeded, but there's no content to send in the response body. Metadata in headers may be updated. Common uses:

- DELETE requests that succeed without returning deleted resource details
- PUT requests where the client already has the updated representation
- Form submissions where the current page shouldn't change
- Saving operations in editors that don't need to refresh content

The client should not update its document view when receiving 204.

**205 Reset Content**

Similar to 204, but instructs the client to reset the document view. Used primarily after form submissions where the user should be able to submit another entry. For example, after submitting a data entry form, the browser should clear all fields for the next entry.

**206 Partial Content**

The server is delivering only part of the resource due to a range request from the client (using the `Range` header). The response must include:

- `Content-Range` header specifying which bytes are being sent
- `Content-Type` matching the requested resource
- Either `Content-Length` (single range) or `multipart/byteranges` (multiple ranges)

Example: `Content-Range: bytes 1000-1999/5000` indicates bytes 1000-1999 of a 5000-byte resource.

**207 Multi-Status** (WebDAV)

The message body contains multiple status codes for different parts of a batch operation. The response body is XML, conveying information about multiple resources where different status codes apply. Used in WebDAV operations that affect multiple resources simultaneously.

**208 Already Reported** (WebDAV)

Members of a DAV binding have already been enumerated in a previous reply and are not being included again. This prevents infinite loops when a resource appears multiple times in a hierarchy due to bindings.

**226 IM Used**

The server has fulfilled a GET request for the resource, and the response represents the result of one or more instance-manipulations applied to the current instance. Used with delta encoding where the server sends only the differences from a previously cached version.

### 3xx Redirection

These codes indicate the client must take additional action to complete the request. The target location is typically provided in the `Location` header.

**300 Multiple Choices**

Multiple representations are available for the resource, each with different locations. The server may include a preferred choice in the `Location` header, or list alternatives in the response body. The client or user can select the preferred representation. This is rarely used in practice.

**301 Moved Permanently**

The resource has permanently moved to a new URI specified in the `Location` header. Future requests should use the new URI. Search engines update their indexes. Browsers and clients should cache this redirect.

[Inference] Many clients change POST to GET when following 301 redirects, though the specification suggests preserving the method. Use 308 to guarantee method preservation.

**302 Found**

The resource temporarily resides at a different URI. The client should continue using the original URI for future requests. The `Location` header contains the temporary URI.

[Inference] Like 301, many clients change POST to GET when following 302 redirects, though this isn't mandated. The original specification (HTTP/1.0) was ambiguous about this behavior.

**303 See Other**

The response to the request can be found at another URI using GET. This explicitly instructs clients to use GET for the redirect, regardless of the original method. Common pattern: POST to create/update a resource, then 303 redirect to GET the result. This prevents duplicate form submissions if the user refreshes the page (POST-Redirect-GET pattern).

**304 Not Modified**

The resource hasn't been modified since the version specified in the request's conditional headers (`If-Modified-Since`, `If-None-Match`). The server returns only headers, no body, saving bandwidth. The client should use its cached version. Response must not contain a message body and must include headers that would have been sent in a 200 response (e.g., `Cache-Control`, `ETag`).

**305 Use Proxy** (Deprecated)

Indicates the resource must be accessed through a proxy specified in the `Location` header. This status code has been deprecated due to security concerns—clients might be redirected to malicious proxies.

**307 Temporary Redirect**

Similar to 302, but guarantees the request method and body will not change when the redirected request is made. If the original request was POST, the redirected request must also be POST with the same body. Use this instead of 302 when method preservation is important.

**308 Permanent Redirect**

Similar to 301, but guarantees the request method and body are preserved. If the original request was POST, the redirected request must be POST. This is the method-preserving equivalent of 301. Use when you need permanent redirection without method changing behavior.

### 4xx Client Errors

These codes indicate the client's request contains errors or cannot be fulfilled due to client-side issues.

**400 Bad Request**

The server cannot process the request due to client error—malformed syntax, invalid request framing, or deceptive request routing. This is a generic error when no other 4xx code is appropriate. Common causes:

- Malformed JSON or XML in the request body
- Invalid query parameters
- Request headers exceeding size limits
- Syntax errors in the request line

**401 Unauthorized**

Authentication is required and has failed or not been provided. The response must include a `WWW-Authenticate` header specifying the authentication scheme(s) the server supports. Despite the name, this actually means "unauthenticated"—the client lacks valid credentials.

Example: `WWW-Authenticate: Basic realm="Access to staging site"`

After receiving valid credentials, the server may return 200 (success) or 403 (authenticated but forbidden).

**402 Payment Required**

Reserved for future use. Originally intended for digital payment systems. Some APIs use this experimentally to indicate payment is required (e.g., exceeding API quota, subscription expired), though 403 or custom 4xx codes are more common.

**403 Forbidden**

The server understands the request but refuses to authorize it. Unlike 401, authentication won't help—the server knows who the client is but denies access anyway. Common scenarios:

- Authenticated user lacks necessary permissions
- IP address is blocked
- Resource requires specific authentication method
- Access forbidden by policy (e.g., DRM restrictions)

The server may reveal why access is forbidden in the response body, or provide a generic message to avoid information leakage.

**404 Not Found**

The server cannot find the requested resource. This is the most common error status code. Reasons include:

- URI doesn't exist
- Resource was deleted
- Server wants to hide resource existence (security through obscurity)
- Endpoint exists but specific resource ID doesn't

404 doesn't indicate whether the absence is temporary or permanent. Servers may return 410 instead if the resource is permanently gone.

**405 Method Not Allowed**

The request method is not supported for the target resource. For example, attempting POST on a read-only resource, or DELETE on a protected resource. The response must include an `Allow` header listing valid methods.

Example: `Allow: GET, HEAD, OPTIONS`

**406 Not Acceptable**

The server cannot produce a response matching the client's proactive content negotiation requirements (specified via `Accept`, `Accept-Language`, `Accept-Encoding`, etc.). The server could not generate any representation acceptable to the client. The response may include a list of available representations for the user to choose from.

**407 Proxy Authentication Required**

Similar to 401, but authentication must occur with a proxy. The proxy must return a `Proxy-Authenticate` header specifying the authentication scheme. The client responds with `Proxy-Authorization` header in subsequent requests.

**408 Request Timeout**

The server timed out waiting for the complete request. The client didn't produce a complete request within the time the server was willing to wait. The server may close the connection. The client may retry the request.

**409 Conflict**

The request conflicts with the current state of the target resource. Common in scenarios like:

- PUT/PATCH operations where the request would create an inconsistent state
- Concurrent modifications (optimistic locking failure)
- Business rule violations
- Duplicate resource creation attempts

The response body should explain the conflict, ideally in a format the client can use to resolve it.

**410 Gone**

The target resource is permanently unavailable at the origin server and no forwarding address is known. This is stronger than 404—it explicitly indicates permanent removal. Used when the server knows the resource once existed but was deliberately deleted. Search engines should remove these URLs from their indexes.

**411 Length Required**

The server requires a `Content-Length` header in the request. The client may retry with a valid `Content-Length` header specifying the message body size.

**412 Precondition Failed**

One or more conditions specified in request headers (`If-Match`, `If-None-Match`, `If-Modified-Since`, `If-Unmodified-Since`, `If-Range`) evaluated to false. This is used for optimistic locking—ensuring the resource hasn't changed since the client last fetched it before allowing an update.

**413 Content Too Large**

The request body is larger than the server is willing or able to process. Previously named "Request Entity Too Large" (HTTP/1.1). The server may close the connection or return a `Retry-After` header indicating when to retry with a smaller payload.

**414 URI Too Long**

The request URI is longer than the server is willing to interpret. Rare conditions include:

- GET request with excessively long query string (should use POST instead)
- Redirect loop causing URI expansion
- Security attack attempting buffer overflow

Previously named "Request-URI Too Long" (HTTP/1.1).

**415 Unsupported Media Type**

The server refuses to accept the request because the payload format is unsupported. The `Content-Type` or `Content-Encoding` of the request is not supported by the server for the target resource or method. The response may include `Accept` or `Accept-Encoding` headers indicating supported formats.

**416 Range Not Satisfiable**

None of the ranges in the request's `Range` header field overlap with the current extent of the target resource. Reasons include:

- Requested byte range exceeds file size
- Invalid range syntax
- Multiple ranges with none overlapping the resource

The response should include a `Content-Range` header indicating the resource's current size: `Content-Range: bytes */5000`

**417 Expectation Failed**

The server cannot meet the requirements indicated in the request's `Expect` header. This occurs when the server doesn't support the expectation or cannot fulfill it. The most common use involves `Expect: 100-continue`.

**418 I'm a teapot**

Defined in RFC 2324 (Hyper Text Coffee Pot Control Protocol) as an April Fools' joke. The server is a teapot and cannot brew coffee. Some servers return this for rejected requests as humor, though it's not a standard HTTP status code for serious use.

**421 Misdirected Request**

The request was directed at a server that is not able to produce a response. This can occur when a connection is reused or when a server is not authoritative for the requested URI's scheme and authority combination. Often related to HTTP/2 connection reuse across multiple domains.

**422 Unprocessable Content** (WebDAV)

The request was well-formed but contains semantic errors. The server understands the content type and the syntax is correct, but the request cannot be processed due to logical errors. Common in REST APIs for validation failures—correct JSON syntax but invalid data (e.g., missing required fields, invalid email format, business rule violations).

Previously named "Unprocessable Entity" (WebDAV).

**423 Locked** (WebDAV)

The source or destination resource is locked. The request method cannot be applied because the resource is locked by another client. The response may include information about the lock in the body.

**424 Failed Dependency** (WebDAV)

The request failed because it depended on another request that failed. Used in WebDAV when operations on multiple resources are interdependent and one fails.

**425 Too Early**

The server is unwilling to risk processing a request that might be replayed. Used with TLS early data (0-RTT) where the request could be vulnerable to replay attacks. The client should retry after the TLS connection is fully established.

**426 Upgrade Required**

The server refuses to perform the request using the current protocol but might do so after the client upgrades. The response must include an `Upgrade` header specifying the required protocol(s).

Example: `Upgrade: HTTP/3.0`

Common when enforcing newer protocol versions for security reasons.

**428 Precondition Required**

The server requires the request to be conditional. This prevents the "lost update" problem where a client GETs a resource, modifies it, and PUTs it back, potentially overwriting changes made by other clients. The server requires headers like `If-Match` to ensure the client is updating the version they retrieved.

**429 Too Many Requests**

The client has sent too many requests in a given time period (rate limiting). The response may include:

- `Retry-After` header indicating how long to wait before retrying
- Custom headers indicating rate limit details (e.g., `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`)

This protects servers from abuse and ensures fair resource allocation.

**431 Request Header Fields Too Large**

The server refuses to process the request because header fields are too large. This may apply to:

- Individual header fields that are too large
- The entire set of request headers being too large

The response may indicate which headers are problematic. Common causes include excessively large cookies or authorization tokens.

**451 Unavailable For Legal Reasons**

The server is denying access to the resource as a consequence of legal demands. Named after Fahrenheit 451 (book about censorship). The response body should include an explanation and may reference the legal demand. Used when content is blocked due to government censorship, DMCA takedowns, or court orders.

### 5xx Server Errors

These codes indicate the server failed to fulfill a valid request due to server-side problems.

**500 Internal Server Error**

The server encountered an unexpected condition that prevented it from fulfilling the request. This is a generic catch-all error when no other 5xx code is appropriate. Common causes:

- Unhandled exceptions in application code
- Database connection failures
- Configuration errors
- Resource exhaustion (but not temporary—use 503 for that)

This indicates a server bug or misconfiguration, not a client problem. The response body may include details (in development) or a generic message (in production).

**501 Not Implemented**

The server does not support the functionality required to fulfill the request. Typically used when:

- The request method is not recognized or supported by the server at all
- The server lacks the capability to fulfill the request

This differs from 405 (method not allowed for this resource) in that 501 means the server doesn't support the method anywhere.

**502 Bad Gateway**

The server, while acting as a gateway or proxy, received an invalid response from the upstream server. This occurs in reverse proxy scenarios where the backend server:

- Returns malformed responses
- Closes the connection unexpectedly
- Violates the HTTP protocol

Common in load balancers, API gateways, and CDNs when upstream services fail.

**503 Service Unavailable**

The server cannot handle the request due to temporary overload or scheduled maintenance. This is explicitly temporary—the condition will be alleviated after some time. The response should include:

- `Retry-After` header indicating when the client should retry
- Explanation in the response body

Common causes:

- Scheduled maintenance
- Server overload (queue full, too many connections)
- Temporary resource exhaustion
- Deliberate throttling

Clients should respect the `Retry-After` header and implement exponential backoff.

**504 Gateway Timeout**

The server, acting as a gateway or proxy, did not receive a timely response from the upstream server. Similar to 502 but specifically about timeout rather than invalid response. The gateway/proxy waited longer than configured timeout for the upstream server to respond.

Common in microservice architectures where one service times out calling another, or when backend databases are slow to respond.

**505 HTTP Version Not Supported**

The server does not support the HTTP protocol version used in the request. For example, requesting HTTP/2 from a server that only supports HTTP/1.1. The response may indicate which versions are supported.

**506 Variant Also Negotiates**

Indicates an internal server configuration error. The chosen variant resource is configured to engage in transparent content negotiation itself, creating a circular reference in content negotiation. This is a server misconfiguration issue.

**507 Insufficient Storage** (WebDAV)

The server cannot store the representation needed to complete the request. The server is unable to store the resource required to complete the request, typically due to disk space limitations. Common in WebDAV file upload operations.

**508 Loop Detected** (WebDAV)

The server detected an infinite loop while processing the request. Used in WebDAV operations when processing a request with depth infinity would result in an infinite loop due to circular resource relationships.

**510 Not Extended**

Further extensions to the request are required for the server to fulfill it. This was defined in an experimental RFC (RFC 2774) for HTTP extension framework but is rarely used in practice.

**511 Network Authentication Required**

The client needs to authenticate to gain network access. Used by captive portals (Wi-Fi hotspots requiring login). The response body should contain information about how to authenticate or a link to a login page.

### Status Code Selection Guidelines

**For successful operations:**

- Use 200 for most successful GET, PUT, PATCH requests with response body
- Use 201 for resource creation with `Location` header
- Use 204 for successful operations requiring no response body
- Use 202 for asynchronous operations accepted but not completed

**For redirects:**

- Use 301/308 for permanent moves (308 preserves method)
- Use 302/307 for temporary moves (307 preserves method)
- Use 303 for POST-Redirect-GET pattern

**For client errors:**

- Use 400 for malformed requests
- Use 401 for authentication failures (with `WWW-Authenticate`)
- Use 403 for authorization failures (authenticated but forbidden)
- Use 404 for non-existent resources
- Use 409 for business logic conflicts
- Use 422 for validation errors on well-formed requests
- Use 429 for rate limiting

**For server errors:**

- Use 500 for unexpected server failures
- Use 502 for upstream server problems
- Use 503 for temporary unavailability (with `Retry-After`)
- Use 504 for upstream timeouts

[Inference] Proper status code selection improves API usability, enables appropriate client-side error handling, and assists with debugging, though the exact mapping between situations and status codes can vary based on API design philosophy.

---

