## RESTful API Concepts


### Architectural Constraints

REST (Representational State Transfer) defines six architectural constraints that distinguish it from other API paradigms.

**Client-Server Separation** The client and server operate independently, communicating only through requests and responses. The server manages data storage and business logic while clients handle the user interface and presentation layer. This separation allows each component to evolve independently—frontend teams can rebuild interfaces without touching backend code, and vice versa.

**Statelessness** Each request from client to server must contain all information necessary to understand and process the request. The server stores no client context between requests. Session state resides entirely on the client side. This constraint improves scalability since servers don't need to maintain, update, or communicate session state. Any server in a cluster can handle any request without coordination.

**Cacheability** Responses must explicitly or implicitly define themselves as cacheable or non-cacheable. When cacheable, clients can reuse response data for subsequent equivalent requests. This reduces client-server interactions and improves performance. Cache-Control, ETag, and Expires headers control caching behavior.

**Uniform Interface** REST mandates a standardized way of communicating between client and server through four interface constraints:

- Resource identification in requests (URIs identify resources)
- Resource manipulation through representations (JSON/XML representations contain enough information to modify resources)
- Self-descriptive messages (each message includes enough information to describe how to process it)
- Hypermedia as the engine of application state (HATEOAS—clients transition through application states via hyperlinks provided dynamically by server)

**Layered System** Client cannot ordinarily tell whether it's connected directly to the end server or an intermediary. Intermediary servers can improve scalability through load balancing and provide shared caching. Layers enforce security policies. This constraint allows architectural flexibility without impacting clients.

**Code-On-Demand (Optional)** Servers can temporarily extend client functionality by transferring executable code (JavaScript, applets). This is the only optional constraint.

### Resource-Oriented Design

**Resource Identification** Resources are the fundamental concept in REST. A resource is any information that can be named—documents, images, temporal services, collections of other resources, or non-virtual objects. Each resource has a unique URI (Uniform Resource Identifier).

Resource URIs follow hierarchical patterns reflecting resource relationships:

- `/users` - collection of users
- `/users/123` - specific user
- `/users/123/orders` - orders belonging to user 123
- `/users/123/orders/456` - specific order

**Resource vs Representation** The resource itself is an abstract entity. The representation is the current state of that resource in a particular format (JSON, XML, HTML). A single resource can have multiple representations. The client requests specific representations through content negotiation.

**URI Design Principles** URIs should use nouns, not verbs, since HTTP methods provide the verbs. Plural nouns for collections maintain consistency. Forward slashes indicate hierarchical relationships. Hyphens improve readability over underscores. Lowercase letters prevent case-sensitivity issues. File extensions are unnecessary when using Accept headers.

Avoid: `/getUser`, `/user/delete`, `/users/123/deleteOrder/456` Prefer: `/users/123`, `/users/123/orders/456` with appropriate HTTP methods

### HTTP Methods Semantics

**GET** Retrieves resource representations without side effects. GET is safe (doesn't alter server state) and idempotent (multiple identical requests produce the same result). Responses are cacheable by default. Query parameters filter, sort, or paginate collections.

**POST** Creates new resources or submits data for processing. POST requests are neither safe nor idempotent—repeated identical POSTs create multiple resources. The server determines the URI for created resources, returning it in the Location header with a 201 status. POST can also trigger operations that don't fit other methods.

**PUT** Replaces the entire resource at a specific URI. If the resource doesn't exist, PUT may create it. PUT is idempotent—repeating the same PUT request produces identical results. The client specifies the complete resource representation. Partial updates require PATCH.

**PATCH** Applies partial modifications to resources. Unlike PUT, PATCH sends only changed fields. PATCH idempotency depends on implementation. JSON Patch (RFC 6902) and JSON Merge Patch (RFC 7396) provide standardized formats for describing changes.

**DELETE** Removes resources. DELETE is idempotent—deleting the same resource multiple times yields the same result (resource doesn't exist). Subsequent GET requests return 404. Some implementations use soft deletes, marking resources as deleted without removing data.

**HEAD** Identical to GET but returns only headers, no body. Useful for checking resource existence, getting metadata, or validating cached representations without transferring the entire resource.

**OPTIONS** Returns supported HTTP methods for a resource. The Allow header lists available methods. CORS preflight requests use OPTIONS to determine if cross-origin requests are permitted.

### Status Codes and Their Meanings

**1xx Informational** Rarely used in REST APIs. 100 Continue indicates the server received request headers and the client should send the body. 101 Switching Protocols occurs during WebSocket upgrades.

**2xx Success**

- 200 OK: Standard success response for GET, PUT, PATCH, or POST that doesn't create resources
- 201 Created: Resource successfully created, typically POST responses, includes Location header
- 202 Accepted: Request accepted for processing but not completed, used for asynchronous operations
- 204 No Content: Success with no response body, common for DELETE or PUT responses
- 206 Partial Content: Partial GET response, used with Range headers for chunked downloads

**3xx Redirection**

- 301 Moved Permanently: Resource permanently relocated, clients should update bookmarks
- 302 Found: Temporary redirect, original URI should be used for future requests
- 303 See Other: Result of POST available at different URI via GET
- 304 Not Modified: Cached version is current, used with conditional requests (If-None-Match, If-Modified-Since)
- 307 Temporary Redirect: Similar to 302 but preserves request method
- 308 Permanent Redirect: Similar to 301 but preserves request method

**4xx Client Errors**

- 400 Bad Request: Malformed syntax, invalid JSON, or violated validation rules
- 401 Unauthorized: Authentication required or failed (misnomer—should be "Unauthenticated")
- 403 Forbidden: Authenticated but lacks permissions for the resource
- 404 Not Found: Resource doesn't exist at specified URI
- 405 Method Not Allowed: HTTP method not supported for resource, includes Allow header
- 406 Not Acceptable: Cannot produce representation matching Accept headers
- 409 Conflict: Request conflicts with current resource state, common with concurrent modifications
- 410 Gone: Resource permanently removed, unlike 404 which may be temporary
- 412 Precondition Failed: Conditional request headers (If-Match, If-Unmodified-Since) not met
- 413 Payload Too Large: Request body exceeds server limits
- 415 Unsupported Media Type: Content-Type not supported
- 422 Unprocessable Entity: Syntactically correct but semantically invalid
- 429 Too Many Requests: Rate limit exceeded, includes Retry-After header

**5xx Server Errors**

- 500 Internal Server Error: Generic server failure
- 501 Not Implemented: Server doesn't support the functionality
- 502 Bad Gateway: Invalid response from upstream server
- 503 Service Unavailable: Temporary unavailability, maintenance, or overload, includes Retry-After header
- 504 Gateway Timeout: Upstream server didn't respond in time

### Content Negotiation

**Media Type Negotiation** Clients specify acceptable response formats using the Accept header. Servers examine this header and return content in the best matching format, indicating the choice in the Content-Type response header.

```
Accept: application/json, application/xml;q=0.9, */*;q=0.8
```

The `q` parameter (quality factor) ranges from 0 to 1, indicating preference. Higher values signal greater preference. Without `q`, the value defaults to 1.0.

**Content Type Negotiation for Requests** The Content-Type header specifies the request body format. Servers returning 415 indicate they cannot process the provided media type.

**Language Negotiation** Accept-Language header specifies preferred natural languages. Content-Language response header indicates the language used.

**Encoding Negotiation** Accept-Encoding specifies acceptable compression algorithms (gzip, deflate, br). Content-Encoding indicates the applied compression.

**Charset Negotiation** While declining in importance with UTF-8 dominance, Accept-Charset specifies character encoding preferences.

**Proactive vs Reactive Negotiation** Proactive negotiation uses request headers—the server selects the representation. Reactive negotiation returns 300 Multiple Choices with available representations—the client selects. Proactive negotiation is standard in REST APIs.

### Hypermedia and HATEOAS

**HATEOAS Principle** Hypermedia as the Engine of Application State means clients interact with applications entirely through hypermedia provided dynamically by servers. Rather than constructing URIs based on documentation, clients discover available actions through links in responses.

**Link Relations** Links include `rel` (relationship) attributes describing the link's purpose. Standard relations (defined in IANA registry) include:

- `self`: Current resource
- `next`/`prev`: Pagination
- `first`/`last`: Collection boundaries
- `edit`: Resource modification endpoint
- `delete`: Resource deletion endpoint
- `related`: Associated resources

**Hypermedia Formats** Various formats embed hypermedia in responses:

HAL (Hypertext Application Language) uses `_links` and `_embedded` objects:

```json
{
  "id": 123,
  "name": "John Doe",
  "_links": {
    "self": { "href": "/users/123" },
    "orders": { "href": "/users/123/orders" },
    "avatar": { "href": "/users/123/avatar" }
  }
}
```

JSON:API standardizes document structure with relationships and links objects.

Collection+JSON focuses on read-write collections with queries and templates.

Siren represents entities with properties, links, actions, and sub-entities.

**Benefits and Challenges** HATEOAS decouples clients from URI structure. Servers can reorganize without breaking clients. Clients automatically discover new functionality. API becomes self-documenting through exploration.

However, HATEOAS increases payload size. Clients require more complex logic to parse and follow links. Many developers find the added complexity unjustified for simple APIs. Consequently, many "RESTful" APIs ignore HATEOAS while implementing other REST principles.

### Versioning Strategies

**URI Path Versioning** Version number appears in the URI path:

```
/v1/users/123
/v2/users/123
```

This approach is explicit and simple. Versions are easily cached separately. However, it violates the principle that URIs identify resources—the same resource has different URIs across versions. Proliferates endpoints across versions.

**Query Parameter Versioning** Version specified as query parameter:

```
/users/123?version=1
/users/123?version=2
```

Keeps base URI consistent. However, complicates caching since query parameters traditionally represent filters. Less visible than path versioning.

**Header Versioning** Custom header specifies version:

```
X-API-Version: 2
API-Version: 2
```

Keeps URIs clean and resource-focused. Separates versioning from resource identification. However, less visible—harder to test in browsers. Requires custom headers rather than standard HTTP.

**Content Negotiation Versioning** Version embedded in media type:

```
Accept: application/vnd.company.v2+json
```

Theoretically most RESTful—different versions are different representations. However, complex for clients. Not widely adopted. Vendor-specific media types (`vnd.`) add overhead.

**No Versioning (Evolution)** Additive changes maintain backward compatibility. New fields are optional. Deprecated fields remain functional. Clients ignore unknown fields. This approach avoids versioning complexity but constrains evolution. Breaking changes eventually require versioning.

**Deprecation Process** APIs evolve continuously. Mark deprecated features with warnings in documentation and response headers. Provide migration paths. Set sunset dates using the Sunset header (RFC 8594). Monitor usage before removing deprecated versions.

### Filtering, Sorting, and Pagination

**Filtering** Query parameters filter collection results:

```
/users?status=active&role=admin
/products?category=electronics&price_min=100&price_max=500
```

Support common operators through parameter naming conventions:

- Exact match: `field=value`
- Comparison: `field_gt=value`, `field_gte=value`, `field_lt=value`, `field_lte=value`
- Pattern matching: `field_like=pattern`
- Inclusion: `field_in=value1,value2,value3`
- Exclusion: `field_not=value`

Complex filters may use structured formats like RSQL or FIQL, though these sacrifice simplicity.

**Sorting** Sort parameter specifies ordering:

```
/users?sort=created_at
/users?sort=-created_at          # descending
/users?sort=last_name,first_name  # multiple fields
```

Prefix conventions indicate direction: `-` for descending, `+` or no prefix for ascending.

**Pagination** Pagination prevents overwhelming clients with large collections and reduces server load.

**Offset-based Pagination** Uses `offset` and `limit` parameters:

```
/users?offset=0&limit=20   # first page
/users?offset=20&limit=20  # second page
```

Or page-based:

```
/users?page=1&per_page=20
/users?page=2&per_page=20
```

Offset pagination is simple and allows jumping to arbitrary pages. However, it performs poorly with large offsets (database must skip rows). Results become inconsistent if data changes between requests (items appear twice or are skipped).

**Cursor-based Pagination** Uses opaque cursor pointing to positions in the result set:

```
/users?cursor=eyJpZCI6MTIzfQ&limit=20
```

Responses include next/previous cursors:

```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTQzfQ",
    "prev_cursor": "eyJpZCI6MTAzfQ"
  }
}
```

Cursor pagination handles data changes gracefully. Performance remains consistent regardless of position. However, clients cannot jump to arbitrary pages. Cursors are typically encoded (Base64) and include sorting information.

**Link Header Pagination** RFC 8288 defines Link headers for pagination:

```
Link: </users?cursor=next123>; rel="next",
      </users?cursor=prev456>; rel="prev",
      </users?cursor=first789>; rel="first",
      </users?cursor=last012>; rel="last"
```

This approach keeps pagination metadata separate from response body, supporting HATEOAS principles.

**Range Headers** HTTP Range headers enable pagination:

```
Range: items=0-19
```

Response includes Content-Range:

```
Content-Range: items 0-19/100
```

This method aligns with HTTP semantics but sees limited adoption for REST APIs.

### Idempotency and Safety

**Safe Methods** Safe methods don't modify resources. GET, HEAD, OPTIONS, and TRACE are safe. Clients can call safe methods without concern for side effects. Caches can store responses without coordination. Preloading and prefetching are acceptable.

[Inference] However, safe methods may trigger logging, analytics, or rate limiting—these implementation details don't violate safety since they don't alter resources from the client's perspective.

**Idempotent Methods** Idempotent methods produce the same result regardless of how many times they're called. GET, HEAD, OPTIONS, PUT, DELETE, and TRACE are idempotent. POST and PATCH are not inherently idempotent.

Idempotency enables safe retries. If a request times out, clients can retry without fear of unintended duplicates. Network intermediaries can replay requests for reliability.

**Idempotency for POST** POST creates resources, so repeating POST creates duplicates. Idempotency-Key headers (standardized in RFC draft) enable idempotent POST:

```
Idempotency-Key: 4e8f5931-3c5e-4a3d-9d4f-7c8b9e3f2a1b
```

Servers track these keys and return the original response for duplicate keys within a time window.

**Implementation Considerations** [Inference] Achieving true idempotency requires careful design. PUT must be a complete replacement—partial updates make idempotency complex. DELETE must handle already-deleted resources gracefully. Distributed systems face challenges—network partitions, concurrent requests, and race conditions can violate idempotency guarantees despite best efforts.

### Caching Mechanisms

**Cache-Control Directives** The Cache-Control header governs caching behavior:

- `public`: Any cache can store the response
- `private`: Only client caches, not shared caches
- `no-cache`: Must revalidate with server before using cached copy
- `no-store`: Don't store the response anywhere
- `max-age=seconds`: Response is fresh for specified duration
- `s-maxage=seconds`: Like max-age but only for shared caches
- `must-revalidate`: Stale responses must not be served without revalidation
- `proxy-revalidate`: Like must-revalidate but only for shared caches
- `immutable`: Response won't change during freshness lifetime

Example:

```
Cache-Control: public, max-age=3600, must-revalidate
```

**Expiration vs Validation** Expiration model uses max-age or Expires header—responses are fresh until expiration. Validation model uses ETags or Last-Modified—clients revalidate with conditional requests.

**ETags (Entity Tags)** ETags uniquely identify resource versions:

```
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
ETag: W/"weak-etag-value"
```

Strong ETags indicate byte-for-byte identity. Weak ETags (prefixed with `W/`) indicate semantic equivalence—content is equivalent but not byte-identical.

Clients include ETags in conditional requests:

```
If-None-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"
```

If the resource hasn't changed, servers return 304 Not Modified with no body.

**Last-Modified/If-Modified-Since** Last-Modified timestamp enables time-based validation:

```
Last-Modified: Wed, 21 Oct 2023 07:28:00 GMT
```

Clients include timestamps in subsequent requests:

```
If-Modified-Since: Wed, 21 Oct 2023 07:28:00 GMT
```

304 Not Modified responses indicate no changes since the specified time.

**Conditional Requests for Concurrency Control** If-Match and If-Unmodified-Since headers enable optimistic locking. Clients include the ETag or timestamp they last retrieved. Servers process the request only if the condition matches, returning 412 Precondition Failed for conflicts.

This prevents lost updates when multiple clients modify the same resource concurrently.

**Vary Header** Vary specifies which request headers affect response content:

```
Vary: Accept-Encoding, Accept-Language
```

Caches must store separate entries for different values of these headers. Without Vary, caches might serve inappropriate representations.

**Cache Invalidation** Servers can't directly invalidate cached responses. TTL expiration and conditional revalidation eventually refresh caches. For time-sensitive data, use short max-age values or no-cache directives. Aggressive caching requires versioned URIs—changes get new URIs, automatically invalidating old versions.

### Error Handling and Problem Details

**Consistent Error Response Structure** Error responses should follow predictable formats. Include sufficient information for debugging without exposing sensitive details.

Basic structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid parameters",
    "details": [
      {
        "field": "email",
        "issue": "Invalid email format"
      }
    ]
  }
}
```

**RFC 7807 Problem Details** RFC 7807 standardizes error responses with the `application/problem+json` media type:

```json
{
  "type": "https://example.com/probs/validation-error",
  "title": "Validation Error",
  "status": 400,
  "detail": "The email field contains an invalid email address",
  "instance": "/users/123",
  "invalid-params": [
    {
      "name": "email",
      "reason": "must be a valid email address"
    }
  ]
}
```

Fields:

- `type`: URI identifying the problem type (dereferenceable for human-readable explanations)
- `title`: Short human-readable summary
- `status`: HTTP status code
- `detail`: Human-readable explanation specific to this occurrence
- `instance`: URI identifying the specific occurrence

Extension members (like `invalid-params`) provide additional context.

**Error Code Design** Machine-readable error codes enable programmatic handling. Use namespaced codes to avoid collisions:

```
AUTH_INVALID_TOKEN
AUTH_EXPIRED_TOKEN
VALIDATION_REQUIRED_FIELD
VALIDATION_INVALID_FORMAT
RESOURCE_NOT_FOUND
RESOURCE_CONFLICT
```

Error codes should be stable—clients depend on them for logic.

**Validation Errors** Validation errors require field-level detail. Return all validation errors simultaneously rather than forcing clients to fix issues one at a time:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "fields": {
      "email": ["Must be a valid email address"],
      "age": ["Must be at least 18"],
      "password": [
        "Must be at least 8 characters",
        "Must contain at least one number"
      ]
    }
  }
}
```

**Security Considerations** Balance helpful error messages with security. Don't expose:

- Internal implementation details (stack traces, database errors)
- Whether resources exist when authorization fails (prefer 404 over 403 for unauthorized access)
- Specific reasons for authentication failures (username vs password errors)
- System information (software versions, internal paths)

Generic messages for security-sensitive errors prevent information leakage. Log detailed errors server-side for debugging.

### Rate Limiting

**Rate Limit Headers** Communicate rate limits through response headers:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 247
X-RateLimit-Reset: 1609459200
```

- `Limit`: Maximum requests in the time window
- `Remaining`: Requests remaining in current window
- `Reset`: Unix timestamp when the window resets

Alternative naming uses `X-Rate-Limit-*` or drops the `X-` prefix entirely. RFC draft proposes standardized `RateLimit-*` headers.

**429 Too Many Requests** When limits are exceeded, return 429 with Retry-After header:

```
HTTP/1.1 429 Too Many Requests
Retry-After: 3600
RateLimit-Limit: 1000
RateLimit-Remaining: 0
RateLimit-Reset: 1609459200
```

Retry-After specifies seconds to wait or an HTTP date.

**Rate Limiting Strategies** Fixed window counts requests within time periods (per minute, hour, day). Simple but allows bursts at window boundaries—users can make limit × 2 requests by clustering at the window edge.

Sliding window tracks request timestamps. More accurate but requires more storage and computation.

Token bucket algorithms allow bursts up to bucket capacity while enforcing average rate. Tokens regenerate continuously. Requests consume tokens. This approach smooths traffic while accommodating legitimate bursts.

Leaky bucket processes requests at fixed rate. Excess requests queue or are rejected. Enforces strict rate control.

**Granular Rate Limiting** Different limits for different contexts:

- Unauthenticated vs authenticated users
- Free vs paid tiers
- Specific endpoints (expensive operations have lower limits)
- Per-user vs per-IP vs per-API-key

Headers should reflect the applicable limit for the current request context.

**Rate Limit Scope** Specify what the limit applies to:

```
X-RateLimit-Scope: user
X-RateLimit-Scope: ip-address
X-RateLimit-Scope: api-key
```

This clarifies whether limits are shared across sessions or isolated per authentication token.

### Authentication and Authorization

**API Keys** Simple authentication tokens passed in headers or query parameters:

```
X-API-Key: a1b2c3d4e5f6
Authorization: ApiKey a1b2c3d4e5f6
```

API keys identify applications or users. Simple to implement and use. However, they're long-lived and typically have broad permissions. Compromised keys grant extensive access. Rotation is infrequent. Query parameter keys appear in logs and browser history.

**HTTP Basic Authentication** Sends credentials encoded in Base64:

```
Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

Simple and widely supported. However, credentials are only obfuscated, not encrypted—requires HTTPS. Credentials pass with every request. No logout mechanism. Suitable for simple use cases or as a fallback.

**Bearer Tokens** Opaque tokens passed in Authorization header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Tokens can be self-contained (JWT) or reference-based (requiring server-side lookup). Token-based auth separates authentication from authorization. Tokens can have limited scope and expiration. Revocation requires server-side tracking or short expiration times.

**OAuth 2.0** Authorization framework enabling third-party access without sharing credentials. Four grant types serve different scenarios:

Authorization Code Grant: Web applications redirect users to authorization server, receive authorization code, exchange code for tokens. Most secure for web apps.

Implicit Grant: Deprecated—tokens returned directly in redirect URI. Vulnerable to token leakage.

Client Credentials Grant: Machine-to-machine authentication. Application authenticates with client ID and secret, receives access token.

Resource Owner Password Credentials Grant: Discouraged—application collects user credentials directly. Only for highly trusted applications.

OAuth provides scopes limiting token permissions. Refresh tokens enable long-term access without storing passwords. However, OAuth adds implementation complexity and requires careful configuration to avoid security vulnerabilities.

**JWT (JSON Web Tokens)** Self-contained tokens encoding claims:

```
header.payload.signature
```

Header specifies algorithm and token type. Payload contains claims (user ID, roles, expiration). Signature verifies authenticity.

JWTs eliminate server-side session storage. Services can validate tokens independently. However, tokens can't be invalidated before expiration without additional infrastructure. Large payloads increase request size. Stored tokens remain valid even after password changes.

**OpenID Connect** Authentication layer built on OAuth 2.0. Provides identity tokens (ID tokens) separate from access tokens. Standardizes user info endpoints and discovery mechanisms. Enables single sign-on across applications.

**Security Best Practices** Always use HTTPS—TLS encrypts credentials and tokens in transit. Store sensitive tokens securely—avoid localStorage for XSS-vulnerable applications. Use HTTP-only cookies where appropriate. Implement token expiration and refresh mechanisms. Apply principle of least privilege—limit token scope to necessary permissions. Validate tokens thoroughly—check signatures, expiration, audience, issuer. Use CSRF tokens for cookie-based authentication. Monitor for suspicious activity and implement anomaly detection.

### CORS (Cross-Origin Resource Sharing)

**Same-Origin Policy** Browsers restrict cross-origin HTTP requests initiated by scripts. The same-origin policy prevents malicious sites from reading sensitive data from other origins. Origins differ if protocol, host, or port differ.

**CORS Headers** Servers explicitly allow cross-origin requests through response headers:

```
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 86400
```

`Allow-Origin` specifies permitted origins. `*` allows any origin but prevents credentials. Specific origins enable credentialed requests.

`Allow-Methods` lists permitted HTTP methods.

`Allow-Headers` specifies headers clients can send.

`Allow-Credentials` enables cookies and authentication headers. Requires specific origin (not `*`).

`Max-Age` caches preflight responses for specified seconds.

**Preflight Requests** Complex requests trigger preflight OPTIONS requests:

```
OPTIONS /users HTTP/1.1
Origin: https://example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization
```

Browser sends preflight before actual request. Server responds with allowed methods and headers. If permitted, browser sends actual request.

Simple requests skip preflight:

- Methods: GET, HEAD, POST
- Headers: Accept, Accept-Language, Content-Language, Content-Type (limited values)
- Content-Type: application/x-www-form-urlencoded, multipart/form-data, text/plain

**Security Implications** Overly permissive CORS configurations create vulnerabilities. `Access-Control-Allow-Origin: *` with sensitive data exposes it to any site. Allowing credentials with broad origins enables CSRF attacks. Dynamic origins based on request headers require careful validation—don't blindly reflect Origin header.

Validate origins against allowlists. Use specific origins rather than wildcards when possible. Limit exposed headers through `Access-Control-Expose-Headers`. Implement additional security measures beyond CORS—CORS prevents browsers from reading responses, not from sending requests.

### Webhooks

**Push vs Pull** Traditional REST APIs use pull—clients poll for updates. Webhooks use push—servers send data to clients when events occur. Webhooks reduce latency and eliminate wasteful polling. However, they require publicly accessible client endpoints and introduce delivery reliability concerns.

**Webhook Registration** Clients register webhook URLs through API endpoints:

```
POST /webhooks
{
  "url": "https://client.example.com/webhooks/orders",
  "events": ["order.created", "order.completed"],
  "secret": "shared-secret-for-verification"
}
```

Servers validate webhook URLs before activation. Some require URL verification—sending a challenge to the URL and expecting specific response.

**Event Delivery** When events occur, servers POST event data to registered URLs:

```
POST /webhooks/orders
{
  "event": "order.created",
  "timestamp": "2024-12-16T10:30:00Z",
  "data": {
    "order_id": 12345,
    "amount": 99.99,
    "status": "pending"
  }
}
```

**Signature Verification** Webhook payloads should include signatures enabling clients to verify authenticity. Common approach uses HMAC:

```
X-Webhook-Signature: sha256=a3d8f7c9e2b1...
```

Compute HMAC using shared secret and payload. Compare with provided signature. This prevents spoofed webhooks and ensures message integrity.

**Delivery Guarantees** Webhooks face reliability challenges:

Network failures prevent delivery. Servers implement retry logic with exponential backoff. Track delivery attempts and eventual failures. Provide failure notifications or dashboards.

Duplicate delivery may occur due to retries. Clients should handle webhooks idempotently—use unique event IDs to detect duplicates.

Ordering isn't guaranteed across webhooks. Include timestamps and sequence numbers. Clients may need to handle out-of-order events.

**Response Expectations** Clients should respond quickly to webhook requests. HTTP 2xx status indicates successful receipt. Long processing should happen asynchronously—acknowledge receipt immediately, process later.

Timeouts trigger retries. Consistently slow or failing endpoints may be disabled automatically.

**Webhook Management** APIs should provide endpoints for:

- Listing registered webhooks
- Updating webhook configuration
- Deleting webhooks
- Viewing delivery history and logs
- Manually triggering test events
- Re-delivering failed events

### API Documentation

**OpenAPI Specification (formerly Swagger)** OpenAPI defines a standard, language-agnostic format for describing RESTful APIs. Machine-readable YAML or JSON documents enable code generation, testing, and interactive documentation.

Basic structure:

```yaml
openapi: 3.0.0
info:
  title: Users API
  version: 1.0.0
paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
        name:
          type: string
```

OpenAPI documents describe endpoints, parameters, request bodies, responses, authentication, and data models. Tools generate interactive documentation (Swagger UI, ReDoc), client libraries, server stubs, and test cases.

**API Blueprint** Markdown-based format emphasizing human readability. Uses a structured markdown syntax for describing APIs. Less tooling support than OpenAPI but simpler for basic documentation.

**RAML (RESTful API Modeling Language)** YAML-based specification focusing on reusability through patterns and resource types. Modular design enables sharing common elements across endpoints.

**Documentation Best Practices** Provide examples for every endpoint—request examples with all parameters, response examples for success and error cases. Include authentication examples showing token usage.

Explain business logic and use cases, not just technical details. Describe what resources represent, when to use specific endpoints, and how endpoints relate.

Document side effects and constraints—rate limits, pagination details, filtering capabilities, sorting options. Specify required vs optional fields. Clarify validation rules.

Maintain accuracy—outdated documentation is worse than no documentation. Automate documentation generation from code when possible. Version documentation alongside API versions.

Include getting started guides, authentication walkthroughs, and common recipes. Provide SDKs or code examples in popular languages.

### Testing REST APIs

**Manual Testing Tools** Postman, Insomnia, and HTTP clients enable interactive API testing. Save requests in collections. Environment variables manage different configurations (dev, staging, production). Pre-request scripts and tests automate validation.

cURL provides command-line access:

```bash
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token" \
  -d '{"name":"John Doe"}'
```

**Contract Testing** Contract tests verify APIs match specifications. Pact and Spring Cloud Contract enable consumer-driven contract testing. Consumers define expected interactions. Providers verify they fulfill contracts. This prevents breaking changes and enables independent deployment.

**Integration Testing** Integration tests exercise complete request-response cycles. Tools like REST Assured (Java), SuperTest (Node.js), and requests (Python) facilitate integration testing.

Test multiple scenarios:

- Happy path with valid data
- Validation errors with invalid data
- Authentication failures
- Authorization failures
- Resource not found
- Concurrent modifications
- Rate limiting
- Large payloads

**Load Testing** Load testing tools (JMeter, Gatling, k6, Locust) simulate concurrent users. Measure throughput, latency, and error rates under load. Identify bottlenecks and capacity limits. Gradually increase load to find breaking points.

**Mock Servers** Mock servers simulate API responses during development. Prism, Mockoon, and WireMock generate mocks from OpenAPI specs. Enable frontend development before backend completion. Isolate components during testing.

**Security Testing** Security testing identifies vulnerabilities:

- SQL injection attempts
- XSS payloads
- Authentication bypass attempts
- Authorization boundary testing
- Rate limit verification
- CORS misconfiguration checks
- Input fuzzing

Tools like OWASP ZAP and Burp Suite automate security scanning.

### Performance Optimization

**N+1 Query Problem** Fetching a collection then iterating to fetch related resources creates N+1 queries. One query for the collection, N queries for related resources.

Solutions:

- Include related resources in the initial response (eager loading)
- Batch requests using specialized endpoints that accept multiple IDs
- Use GraphQL-style field selection to specify needed relationships
- Implement DataLoader pattern to batch and cache requests

**Response Compression** Enable gzip or brotli compression for responses. Reduces bandwidth and transfer time. Most clients support compression automatically. Configure servers to compress responses above size thresholds. Text-based formats (JSON, XML) compress significantly.

**Conditional Requests** ETags and Last-Modified headers enable conditional requests. 304 Not Modified responses eliminate unnecessary data transfer. Clients reuse cached data when nothing changed.

**Payload Size Optimization** Minimize response payloads:

- Return only requested fields (field filtering: `/users?fields=id,name,email`)
- Paginate large collections
- Compress verbose formats
- Consider binary formats for specific use cases (though JSON remains standard for REST)
- Remove unnecessary metadata
- Use shorter property names for high-volume endpoints (though this sacrifices readability)

**Database Query Optimization** Optimize database access:

- Index frequently queried fields
- Avoid SELECT * queries—fetch only needed columns
- Implement query result caching
- Use database connection pooling
- Optimize JOIN operations
- Monitor slow queries and optimize schemas

**CDN and Caching** Distribute static or semi-static responses through CDNs. Cache GET responses with appropriate Cache-Control headers. Implement application-level caching (Redis, Memcached) for expensive operations. Use HTTP caching headers effectively. Cache database query results and computed values.

**Asynchronous Processing** Expensive operations shouldn't block request-response cycles. Return 202 Accepted immediately. Process asynchronously. Provide status endpoints for polling. Use webhooks to notify completion. Message queues (RabbitMQ, Kafka) decouple request handling from processing.

**Connection Management** Use HTTP/1.1 persistent connections (keep-alive) to reuse TCP connections. HTTP/2 multiplexes requests over single connections. Configure appropriate timeouts. Implement connection pooling in clients.

**Server-Side Optimizations** Choose appropriate server architectures—asynchronous non-blocking servers (Node.js, Go) handle concurrent requests efficiently. Scale horizontally with load balancers. Implement request queuing and backpressure. Monitor resource utilization (CPU, memory, database connections).

---

