## RESTful API Design Patterns

RESTful APIs have become the dominant architectural style for building web services, providing a standardized approach to creating scalable, maintainable, and interoperable interfaces. REST (Representational State Transfer) leverages HTTP's inherent capabilities to create APIs that are intuitive, cacheable, and loosely coupled. Understanding RESTful patterns enables developers to build APIs that are both powerful and easy to consume.

### REST Architectural Constraints

REST is defined by six architectural constraints that guide API design. These constraints work together to create systems with desirable properties like scalability, reliability, and modifiability.

#### Client-Server Separation

The client and server are separate entities that communicate over a network. This separation allows them to evolve independently. Clients handle user interfaces and user state, while servers manage data storage and business logic. This constraint enables multiple client types (web, mobile, desktop) to interact with the same server.

#### Statelessness

Each request from client to server must contain all information necessary to understand and process the request. The server does not store client context between requests. Session state is kept entirely on the client side. This constraint improves scalability since servers don't need to manage session information, and any server can handle any request.

#### Cacheability

Responses must explicitly indicate whether they are cacheable to allow clients and intermediaries to cache responses and reuse them for equivalent subsequent requests. This reduces latency, decreases server load, and improves perceived performance. Cache-Control headers specify caching behavior.

#### Uniform Interface

REST defines a uniform interface between components, simplifying the overall architecture. This includes resource identification through URIs, resource manipulation through representations, self-descriptive messages, and hypermedia as the engine of application state (HATEOAS).

#### Layered System

The architecture can be composed of hierarchical layers, with each layer only aware of the immediate layer with which it interacts. Load balancers, caches, proxies, and gateways can be inserted transparently without clients needing to know the system's internal structure.

#### Code-On-Demand (Optional)

Servers can temporarily extend client functionality by transferring executable code (like JavaScript). This is the only optional constraint and is less commonly implemented in pure REST APIs.

### Resource-Oriented Design

RESTful APIs center on resources rather than actions. A resource is any conceptual entity that can be referenced: a user, an order, a product, or even a collection of items. Each resource is identified by a unique URI.

#### Resource Identification

URIs should identify resources using nouns, not verbs. The HTTP method indicates the action. Resources should be named using plural nouns for collections and singular identifiers for specific items.

```
Good:
GET /users              - Get all users
GET /users/123          - Get specific user
POST /users             - Create new user
GET /orders/456/items   - Get items in order 456

Avoid:
GET /getUsers
POST /createUser
GET /user/delete/123
```

#### Resource Hierarchies

URIs naturally express relationships between resources through hierarchy. Nested resources indicate ownership or strong association. However, avoid deeply nested URIs (more than 2-3 levels) as they become unwieldy and tightly couple resources.

```
/users/123/orders/456/items/789
```

For deep hierarchies, consider providing alternate access paths:

```
/items/789
/orders/456/items
```

#### Resource Granularity

Determining appropriate resource granularity involves balancing fine-grained flexibility against coarse-grained simplicity. Too fine-grained creates chatty APIs requiring multiple requests. Too coarse-grained creates inflexible endpoints that return excessive data.

Consider offering both detailed resources and summary collections, allowing clients to choose the appropriate granularity for their needs.

### HTTP Methods and Semantics

RESTful APIs leverage HTTP methods to indicate operations on resources. Understanding the semantics and characteristics of each method is critical for proper API design.

#### GET

GET retrieves resource representations. It must be safe (no side effects on server state) and idempotent (multiple identical requests produce the same result). GET requests should never modify data.

GET supports query parameters for filtering, sorting, and pagination:

```
GET /products?category=electronics&sort=price&order=desc&page=2&limit=20
```

#### POST

POST creates new resources or triggers operations that don't fit other methods. POST is neither safe nor idempotent—repeated identical POST requests typically create multiple resources.

The server typically assigns the new resource's URI and returns it in the Location header with a 201 Created status:

```
POST /users
Content-Type: application/json

{
  "name": "Jane Smith",
  "email": "jane@example.com"
}

Response:
201 Created
Location: /users/789
```

POST can also trigger operations that don't create resources:

```
POST /orders/123/cancel
POST /users/456/send-welcome-email
```

#### PUT

PUT replaces the entire resource at the specified URI. PUT is idempotent—sending the same PUT request multiple times produces the same result as sending it once. If the resource doesn't exist, PUT can create it (though POST is more commonly used for creation).

```
PUT /users/123
Content-Type: application/json

{
  "id": 123,
  "name": "Jane Smith",
  "email": "jane.smith@example.com",
  "role": "admin"
}
```

All resource fields should be included in the request. Missing fields might be set to null or default values.

#### PATCH

PATCH performs partial updates, modifying only specified fields. Unlike PUT, PATCH doesn't require sending the complete resource representation. PATCH is generally considered idempotent [Inference - though RFC 5789 doesn't strictly require idempotency, most implementations treat it as such].

```
PATCH /users/123
Content-Type: application/json

{
  "email": "jane.newemail@example.com"
}
```

Various PATCH formats exist, including JSON Patch (RFC 6902) which provides precise update operations:

```
PATCH /users/123
Content-Type: application/json-patch+json

[
  { "op": "replace", "path": "/email", "value": "new@example.com" },
  { "op": "add", "path": "/phone", "value": "+1234567890" }
]
```

#### DELETE

DELETE removes the specified resource. DELETE is idempotent—deleting the same resource multiple times results in the same state (resource doesn't exist). Subsequent DELETE requests typically return 404 Not Found.

```
DELETE /users/123

Response:
204 No Content
```

#### HEAD

HEAD is identical to GET except the server returns only headers without the response body. Useful for checking resource existence, getting metadata, or validating cache freshness without transferring the full representation.

#### OPTIONS

OPTIONS returns the HTTP methods supported by a resource. Used for CORS preflight requests and API capability discovery.

```
OPTIONS /users/123

Response:
Allow: GET, PUT, PATCH, DELETE
```

### Response Status Codes

HTTP status codes communicate the outcome of API requests. Proper status code usage helps clients handle responses appropriately and enables correct error handling.

#### Success Codes (2xx)

**200 OK**: Request succeeded. The response body contains the requested resource or operation result. Used for successful GET, PUT, PATCH requests.

**201 Created**: Resource successfully created. Should include Location header pointing to the new resource. Used for successful POST requests that create resources.

**202 Accepted**: Request accepted for asynchronous processing but not yet completed. Useful for long-running operations.

**204 No Content**: Request succeeded but there's no content to return. Common for successful DELETE requests or updates where returning the updated resource is unnecessary.

#### Redirection Codes (3xx)

**301 Moved Permanently**: Resource permanently moved to a new URI specified in the Location header. Clients should update bookmarks.

**302 Found / 303 See Other**: Temporary redirect. 303 specifically indicates the client should use GET for the redirect target regardless of the original method.

**304 Not Modified**: Resource hasn't changed since the version specified in request headers (If-Modified-Since, If-None-Match). Client can use cached version.

#### Client Error Codes (4xx)

**400 Bad Request**: Request is malformed or contains invalid data. Response should include details about validation errors.

**401 Unauthorized**: Authentication required or failed. Despite the name, this actually means unauthenticated.

**403 Forbidden**: Server understood the request but refuses to authorize it. User is authenticated but lacks permissions.

**404 Not Found**: Requested resource doesn't exist. Also used to hide resource existence from unauthorized users.

**405 Method Not Allowed**: HTTP method not supported for this resource. Should include Allow header listing supported methods.

**409 Conflict**: Request conflicts with current resource state, like attempting to create a resource that already exists or updating based on stale data.

**410 Gone**: Resource previously existed but has been permanently deleted. More specific than 404.

**422 Unprocessable Entity**: Request is well-formed but contains semantic errors. Used for validation failures.

**429 Too Many Requests**: Client exceeded rate limits. Should include Retry-After header.

#### Server Error Codes (5xx)

**500 Internal Server Error**: Generic server error. Should be avoided when more specific codes apply.

**502 Bad Gateway**: Server acting as gateway received invalid response from upstream server.

**503 Service Unavailable**: Server temporarily unable to handle requests due to maintenance or overload. Should include Retry-After header.

**504 Gateway Timeout**: Server acting as gateway didn't receive timely response from upstream server.

### Versioning Strategies

API evolution requires careful version management to avoid breaking existing clients while enabling improvements and new features.

#### URI Versioning

Version identifier appears in the URI path. This is explicit and easy to understand but violates the principle that URIs should identify resources, not versions.

```
/v1/users/123
/v2/users/123
```

Advantages: Clear, simple, easy to route to different implementations, works well with caching.

Disadvantages: Same resource has multiple URIs, clutters URI space, not truly RESTful.

#### Header Versioning

Version specified in custom request headers or Accept headers using content negotiation.

```
GET /users/123
API-Version: 2

Or:

GET /users/123
Accept: application/vnd.company.api+json; version=2
```

Advantages: URIs remain clean, more RESTful, single URI per resource.

Disadvantages: Less visible, harder to test in browsers, more complex routing.

#### Query Parameter Versioning

Version specified as query parameter.

```
/users/123?version=2
```

Advantages: Simple to implement, easy to test, explicit.

Disadvantages: Query parameters semantically meant for filtering, not versioning; can complicate caching.

#### Content Negotiation

Clients specify desired version through Accept header media type parameters.

```
Accept: application/vnd.company.user-v2+json
```

Advantages: True REST approach, leverages HTTP content negotiation.

Disadvantages: Most complex to implement and use, vendor-specific media types add overhead.

#### Versioning Best Practices

Only increment major versions for breaking changes. Support multiple versions simultaneously for a transition period. Clearly document deprecation timelines. Consider semantic versioning principles adapted for APIs. Default to the latest stable version when no version is specified, or reject unversioned requests to force explicit version selection.

### Pagination Patterns

Large collections require pagination to maintain performance and usability. Several pagination approaches exist, each with different trade-offs.

#### Offset-Based Pagination

Uses offset and limit parameters to specify which slice of results to return.

```
GET /products?offset=40&limit=20
```

Response includes pagination metadata:

```json
{
  "data": [...],
  "pagination": {
    "offset": 40,
    "limit": 20,
    "total": 1543
  }
}
```

Advantages: Simple, allows jumping to arbitrary pages, clients can calculate total pages.

Disadvantages: Performance degrades with large offsets as databases must skip rows. Results can shift if data is inserted/deleted during pagination, causing duplicates or missed items.

#### Cursor-Based Pagination

Uses opaque cursor tokens to mark position in the result set.

```
GET /products?cursor=eyJpZCI6MTAwfQ&limit=20
```

Response includes next cursor:

```json
{
  "data": [...],
  "pagination": {
    "cursor": "eyJpZCI6MTIwfQ",
    "hasMore": true
  }
}
```

Advantages: Consistent results even with data changes, efficient for databases (can use indexed seeks), no issues with large offsets.

Disadvantages: Can't jump to arbitrary pages, difficult to display page numbers, cursors are opaque to clients.

#### Page-Based Pagination

Uses page number and page size parameters.

```
GET /products?page=3&pageSize=20
```

Advantages: Intuitive for users, easy to implement simple navigation.

Disadvantages: Same issues as offset-based (it's essentially offset = (page - 1) * pageSize), performance problems with high page numbers.

#### Keyset Pagination

Uses values from the last retrieved record to fetch the next set, typically using timestamp or sequential ID.

```
GET /products?since_id=9876&limit=20
```

Advantages: Efficient, consistent results, works well with time-based data.

Disadvantages: Only supports moving forward/backward sequentially, requires indexed column for pagination key.

#### Pagination Headers

Pagination information can be communicated through response headers rather than body:

```
Link: <https://api.example.com/products?page=3>; rel="next",
      <https://api.example.com/products?page=1>; rel="first",
      <https://api.example.com/products?page=50>; rel="last"
X-Total-Count: 1543
```

This follows REST principles by separating metadata from resource representation.

### Filtering, Sorting, and Searching

APIs should provide flexible querying capabilities without creating endpoint proliferation.

#### Filtering

Query parameters enable filtering collections:

```
GET /products?category=electronics&price_min=100&price_max=500&in_stock=true
```

Support common filter operators:

```
?created_after=2024-01-01
?price_gte=100               (greater than or equal)
?price_lt=1000               (less than)
?name_contains=laptop
?tags_in=sale,featured       (matches any value)
```

Complex filters might use structured query parameters:

```
?filter[category]=electronics&filter[price][gte]=100
```

#### Sorting

Sort parameter specifies ordering:

```
GET /products?sort=price          (ascending)
GET /products?sort=-price         (descending, indicated by minus)
GET /products?sort=category,-price (multiple fields)
```

Consistent sorting defaults and maximum sort complexity limits prevent performance issues.

#### Field Selection

Sparse fieldsets allow clients to request only needed fields, reducing bandwidth:

```
GET /users?fields=id,name,email
GET /products?fields=id,name,price,inventory.quantity
```

This is particularly valuable for mobile clients with limited bandwidth.

#### Full-Text Search

Dedicated search parameter or endpoint:

```
GET /products?q=laptop
GET /search?q=laptop&type=products
```

Search capabilities might include fuzzy matching, stemming, and relevance ranking. Consider whether search warrants a dedicated service for complex requirements.

### HATEOAS (Hypermedia As The Engine Of Application State)

HATEOAS is REST's hypermedia constraint, where responses include links to related resources and available actions. This makes APIs self-documenting and discoverable.

```json
{
  "id": 123,
  "name": "Jane Smith",
  "email": "jane@example.com",
  "links": [
    {
      "rel": "self",
      "href": "/users/123",
      "method": "GET"
    },
    {
      "rel": "orders",
      "href": "/users/123/orders",
      "method": "GET"
    },
    {
      "rel": "update",
      "href": "/users/123",
      "method": "PUT"
    },
    {
      "rel": "delete",
      "href": "/users/123",
      "method": "DELETE"
    }
  ]
}
```

HATEOAS enables clients to discover capabilities dynamically rather than hardcoding URIs and workflows. However, full HATEOAS implementation is rare in practice as it adds complexity and many client applications prefer explicit, documented endpoints.

#### HAL (Hypertext Application Language)

HAL is a standard format for representing hypermedia:

```json
{
  "_links": {
    "self": { "href": "/orders/123" },
    "customer": { "href": "/users/456" },
    "items": { "href": "/orders/123/items" }
  },
  "id": 123,
  "total": 250.00,
  "status": "pending",
  "_embedded": {
    "items": [
      {
        "_links": { "self": { "href": "/items/789" } },
        "id": 789,
        "name": "Product A"
      }
    ]
  }
}
```

#### JSON:API

JSON:API provides conventions for resource relationships and includes/links:

```json
{
  "data": {
    "type": "articles",
    "id": "1",
    "attributes": {
      "title": "REST Patterns"
    },
    "relationships": {
      "author": {
        "links": {
          "related": "/articles/1/author"
        }
      }
    }
  }
}
```

### Authentication and Authorization Patterns

RESTful APIs must authenticate users and authorize access to resources while maintaining statelessness.

#### API Keys

Simple authentication where clients include a key in headers or query parameters:

```
GET /users
X-API-Key: abc123def456
```

Advantages: Simple to implement and use.

Disadvantages: Keys are long-lived credentials, difficult to rotate, no standard for expiration, limited user context.

#### Basic Authentication

Username and password encoded in Base64 and sent in Authorization header:

```
Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

Advantages: Standard HTTP mechanism, simple.

Disadvantages: Credentials sent with every request, must use HTTPS, no built-in expiration.

#### Bearer Tokens (OAuth 2.0)

Most common pattern for modern APIs. Access tokens are obtained through OAuth 2.0 flows and included in requests:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Tokens are time-limited, can carry user/permission claims, and support refresh tokens for obtaining new access tokens without re-authentication.

OAuth 2.0 defines several flows:

- Authorization Code: For web applications with server-side code
- Client Credentials: For machine-to-machine communication
- Resource Owner Password: For trusted first-party clients
- Implicit: Deprecated, insecure for modern applications

#### JWT (JSON Web Tokens)

JWTs are self-contained tokens encoding claims about the user:

```json
{
  "sub": "user123",
  "name": "Jane Smith",
  "role": "admin",
  "exp": 1735142400
}
```

Advantages: Stateless (server doesn't need to store sessions), contains user information, verifiable signature.

Disadvantages: Cannot be revoked before expiration (unless using token blacklists), size larger than opaque tokens, all claims visible to anyone who intercepts token.

#### Authorization Patterns

**Role-Based Access Control (RBAC)**: Users have roles (admin, editor, viewer) that determine permissions.

**Attribute-Based Access Control (ABAC)**: Access decisions based on attributes of user, resource, and environment.

**Scope-Based Authorization**: OAuth 2.0 scopes define granular permissions (read:users, write:orders).

Resources should return 401 Unauthorized for missing/invalid credentials and 403 Forbidden for valid credentials with insufficient permissions.

### Error Handling

Consistent error responses help clients handle failures appropriately.

#### Error Response Structure

Standardized error format includes machine-readable codes and human-readable messages:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      },
      {
        "field": "age",
        "message": "Must be at least 18"
      }
    ],
    "requestId": "abc-123-def"
  }
}
```

Include:

- **code**: Machine-readable error identifier
- **message**: Human-readable description
- **details**: Specific field-level errors for validation failures
- **requestId**: Correlation ID for debugging

#### Problem Details (RFC 7807)

Standardized format for HTTP API error responses:

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 400,
  "detail": "The email field is required",
  "instance": "/users",
  "errors": {
    "email": ["Required field missing"]
  }
}
```

Content-Type: `application/problem+json`

### Rate Limiting

Rate limiting protects APIs from abuse and ensures fair resource distribution.

#### Rate Limit Headers

Communicate limits and current usage through standard headers:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 487
X-RateLimit-Reset: 1735142400
```

When limit is exceeded, return 429 Too Many Requests:

```
HTTP/1.1 429 Too Many Requests
Retry-After: 3600
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1735142400
```

#### Rate Limiting Strategies

**Fixed Window**: Count requests in fixed time periods (e.g., per hour). Simple but allows traffic bursts at window boundaries.

**Sliding Window**: Track request timestamps to calculate rate over sliding time periods. More accurate but more complex.

**Token Bucket**: Bucket fills with tokens at fixed rate. Each request consumes a token. Allows bursts up to bucket capacity while maintaining average rate.

**Leaky Bucket**: Requests enter a queue that drains at constant rate. Smooths traffic but can delay legitimate requests during bursts.

Consider different limits for different authentication tiers (anonymous, authenticated, premium) and different endpoints based on computational cost.

### Caching Strategies

Effective caching dramatically improves API performance and reduces server load.

#### Cache-Control Headers

Specify caching behavior:

```
Cache-Control: public, max-age=3600
Cache-Control: private, max-age=600
Cache-Control: no-cache
Cache-Control: no-store
```

**public**: Response cacheable by any cache (CDN, proxy, browser) **private**: Cacheable only by client's browser **max-age**: Time in seconds the response is fresh **no-cache**: Validate with server before using cached response **no-store**: Never cache the response

#### ETags and Conditional Requests

ETags (entity tags) enable efficient cache validation. Server includes ETag in response:

```
GET /users/123

Response:
200 OK
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
```

Client includes ETag in subsequent requests:

```
GET /users/123
If-None-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"

Response if unchanged:
304 Not Modified
```

#### Last-Modified and If-Modified-Since

Alternative to ETags using timestamps:

```
GET /users/123

Response:
200 OK
Last-Modified: Thu, 20 Dec 2024 10:30:00 GMT

Subsequent request:
GET /users/123
If-Modified-Since: Thu, 20 Dec 2024 10:30:00 GMT

Response if unchanged:
304 Not Modified
```

#### Vary Header

Indicates response varies based on request headers:

```
Vary: Accept-Encoding, Accept-Language
```

Caches must consider these headers when determining cache hits, ensuring users receive appropriate representations.

### Idempotency

Idempotency ensures that multiple identical requests have the same effect as a single request. Critical for reliable distributed systems where requests may be retried.

#### Idempotent Methods

GET, PUT, DELETE, HEAD, OPTIONS, and TRACE are naturally idempotent. POST and PATCH are not inherently idempotent.

#### Idempotency Keys

For non-idempotent operations like POST, clients can include idempotency keys:

```
POST /payments
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000

{
  "amount": 100.00,
  "currency": "USD"
}
```

Server stores the key with the operation result. Subsequent requests with the same key return the original response without re-executing the operation. Keys typically expire after 24 hours.

### Asynchronous Operations

Long-running operations shouldn't block HTTP requests. Asynchronous patterns enable clients to initiate operations and check status separately.

#### 202 Accepted Pattern

Server accepts the request and returns 202 with a status endpoint:

```
POST /reports/generate

Response:
202 Accepted
Location: /reports/status/abc-123
```

Client polls status endpoint:

```
GET /reports/status/abc-123

Response while processing:
200 OK
{
  "status": "processing",
  "progress": 45
}

Response when complete:
200 OK
{
  "status": "completed",
  "result": "/reports/download/abc-123"
}
```

#### Webhooks

Server notifies client when operation completes by sending HTTP request to client-provided URL:

```
POST /reports/generate
{
  "webhook_url": "https://client.example.com/webhook"
}
```

When complete, server POSTs to webhook:

```
POST https://client.example.com/webhook
{
  "report_id": "abc-123",
  "status": "completed",
  "download_url": "/reports/download/abc-123"
}
```

#### WebSocket Upgrade

For real-time bidirectional communication, upgrade HTTP connection to WebSocket, though this deviates from pure REST principles.

### Content Negotiation

Clients and servers negotiate response format through Accept headers.

```
GET /users/123
Accept: application/json

Response:
Content-Type: application/json

GET /users/123
Accept: application/xml

Response:
Content-Type: application/xml
```

Servers should support common formats (JSON, XML) and return 406 Not Acceptable if requested format isn't supported. JSON has become the de facto standard for modern APIs.

Content negotiation extends to language (Accept-Language), encoding (Accept-Encoding), and character sets (Accept-Charset).

### Bulk Operations

APIs need patterns for operating on multiple resources efficiently.

#### Batch Endpoints

Single endpoint accepts array of operations:

```
POST /users/batch
[
  { "method": "POST", "path": "/users", "body": {...} },
  { "method": "PUT", "path": "/users/123", "body": {...} },
  { "method": "DELETE", "path": "/users/456" }
]

Response:
[
  { "status": 201, "body": {...} },
  { "status": 200, "body": {...} },
  { "status": 204 }
]
```

All operations typically execute within a single transaction or are individually reported for partial success.

#### Collection Updates

Single request modifies multiple resources:

```
PATCH /users
{
  "filter": { "status": "inactive" },
  "updates": { "status": "archived" }
}

Response:
200 OK
{
  "modified": 47
}
```

Use with caution as this can unexpectedly affect many resources.

### API Documentation

Comprehensive documentation is essential for API adoption and proper usage.

#### OpenAPI Specification

OpenAPI (formerly Swagger) provides machine-readable API descriptions:

```yaml
openapi: 3.0.0
info:
  title: User API
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
          description: Success
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
```

OpenAPI specifications enable automated documentation generation, client SDK generation, and API testing tools.

#### Documentation Best Practices

Include example requests and responses for all endpoints. Document all possible status codes and error responses. Provide authentication examples. Explain rate limits and pagination. Offer getting-started guides and common use case tutorials. Keep documentation synchronized with implementation.

### CORS (Cross-Origin Resource Sharing)

Web browsers enforce same-origin policy, preventing JavaScript from making requests to different domains. CORS headers enable controlled cross-origin access.

```
Preflight request:
OPTIONS /users
Origin: https://app.example.com
Access-Control-Request-Method: POST

Response:
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400
```

Actual request:

```
POST /users
Origin: https://app.example.com

Response:
Access-Control-Allow-Origin: https://app.example.com
```

Configure CORS carefully to balance security with functionality. Avoid using `Access-Control-Allow-Origin: *` for APIs requiring authentication.

### Compression

Response compression significantly reduces bandwidth usage:

```
Accept-Encoding: gzip, deflate

Response:
Content-Encoding: gzip
```

Enable compression for text-based formats (JSON, XML, HTML). Consider compression thresholds (e.g., only compress responses over 1KB). Be aware of compression-related security vulnerabilities like BREACH when compressing responses containing secrets.

### API Deprecation

Evolving APIs requires deprecating old endpoints or features while supporting existing clients.

#### Deprecation Headers

Communicate deprecation through headers:

```
GET /v1/users

Response:
Sunset: Sat, 31 Dec 2025 23:59:59 GMT
Deprecation: true
Link: <https://api.example.com/v2/users>; rel="alternate"
```

**Sunset**: Date when endpoint will be removed **Deprecation**: Indicates the resource is deprecated **Link**: Points to replacement

#### Deprecation Process

Announce deprecation well in advance (6-12 months). Provide migration guides and updated documentation. Monitor usage of deprecated endpoints. Send notifications to API consumers. Maintain deprecated endpoints for the announced period. Finally, remove deprecated endpoints and return 410 Gone afterward.

### Security Best Practices

RESTful APIs must be designed with security as a priority.

**Always use HTTPS**: Encrypt all API traffic. Never expose APIs over plain HTTP.

**Validate Input**: Sanitize and validate all inputs to prevent injection attacks. Use whitelists rather than blacklists.

**Use Proper Authentication**: Implement robust authentication (OAuth 2.0, JWT). Never accept credentials in URLs or query parameters.

**Implement Rate Limiting**: Protect against abuse and DDoS attacks.

**Principle of Least Privilege**: Grant minimal necessary permissions. Implement granular authorization.

**Secure API Keys**: Treat API keys as passwords. Enable rotation. Never embed in client-side code.

**Audit Logging**: Log authentication, authorization, and sensitive operations for security analysis.

**CSRF Protection**: For state-changing operations, implement CSRF tokens or use authentication methods immune to CSRF.

**SQL Injection Prevention**: Use parameterized queries. Never concatenate user input into SQL.

**Sensitive Data**: Never log sensitive information (passwords, tokens, credit cards). Mask sensitive data in responses when appropriate.

### Testing Strategies

Comprehensive testing ensures API reliability and correctness.

**Unit Tests**: Test individual components and business logic in isolation.

**Integration Tests**: Test complete request-response cycles against running API. Verify status codes, response structure, and data accuracy.

**Contract Tests**: Verify API adheres to documented contracts. Tools like Pact enable consumer-driven contract testing.

**Load Tests**: Ensure API handles expected traffic volumes. Identify performance bottlenecks and capacity limits.

**Security Tests**: Penetration testing, vulnerability scanning, and authentication/authorization testing.

**Documentation Tests**: Automatically verify examples in documentation remain valid as API evolves.

### Performance Optimization

Several techniques optimize RESTful API performance.

**Database Query Optimization**: Use appropriate indexes, avoid N+1 queries, implement query result caching.

**Connection Pooling**: Reuse database connections rather than creating new connections per request.

**Response Caching**: Implement caching at multiple levels (CDN, API gateway, application, database).

**Compression**: Enable response compression for text-based formats.

**Pagination**: Always paginate large collections to avoid massive responses.

**Field Selection**: Allow clients to request only needed fields.

**Asynchronous Processing**: Offload expensive operations to background workers.

**CDN Usage**: Distribute static content and cacheable responses through CDNs.

### Common Antipatterns

Several design mistakes commonly appear in REST API implementations.

**Tunnel Everything Through POST**: Using POST for all operations instead of appropriate HTTP methods loses REST's semantic benefits and breaks caching.

**Exposing Database Schema**: Directly mapping database tables to API resources creates tight coupling and makes future changes difficult.

**Chatty APIs**: Requiring many requests to accomplish tasks. Design resources at appropriate granularity.

**Ignoring Status Codes**: Returning 200 OK with error messages in body. Use appropriate status codes.

**Breaking Changes Without Versioning**: Modifying APIs without versioning breaks existing clients.

**Over-Nesting Resources**: Creating deeply nested URI structures (4+ levels) that become unwieldy.

**Verb-Based URIs**: Using verbs in URIs (/getUser, /deleteOrder) instead of nouns with HTTP methods.

**Inconsistent Naming**: Mixing camelCase, snake_case, and conventions within the same API creates confusion.

### Microservices Considerations

RESTful APIs in microservices architectures face additional challenges.

**Service Discovery**: Clients need to locate service instances dynamically. Integrate with service registries (Consul, Eureka).

**Circuit Breakers**: Prevent cascade failures when downstream services fail. Libraries like Hystrix implement this pattern.

**API Gateway**: Centralize cross-cutting concerns (authentication, rate limiting, logging) and provide unified entry point.

**Saga Pattern**: Coordinate distributed transactions across services using orchestration or choreography approaches.

**API Composition**: Aggregate data from multiple services. Balance between gateway composition and client-side aggregation.

### **Example**

Consider an e-commerce API managing products, orders, and users:

```
Resource: Products

GET /products
Query params: category, price_min, price_max, sort, page, limit
Response: 200 OK
{
  "data": [
    {
      "id": 101,
      "name": "Wireless Mouse",
      "price": 29.99,
      "category": "electronics",
      "stock": 45
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 543
  }
}

GET /products/101
Response: 200 OK
{
  "id": 101,
  "name": "Wireless Mouse",
  "price": 29.99,
  "category": "electronics",
  "stock": 45,
  "description": "Ergonomic wireless mouse...",
  "reviews": {
    "count": 23,
    "average": 4.5,
    "link": "/products/101/reviews"
  }
}

POST /products
Authorization: Bearer <token>
{
  "name": "USB Cable",
  "price": 12.99,
  "category": "accessories",
  "stock": 100
}
Response: 201 Created
Location: /products/789

PUT /products/101
Authorization: Bearer <token>
{
  "id": 101,
  "name": "Wireless Mouse",
  "price": 27.99,
  "category": "electronics",
  "stock": 50,
  "description": "Updated description..."
}
Response: 200 OK

PATCH /products/101
Authorization: Bearer <token>
{
  "price": 24.99
}
Response: 200 OK

DELETE /products/101
Authorization: Bearer <token>
Response: 204 No Content

Resource: Orders

POST /orders
Authorization: Bearer <token>
{
  "items": [
    {"product_id": 101, "quantity": 2},
    {"product_id": 205, "quantity": 1}
  ],
  "shipping_address": {...}
}
Response: 201 Created
Location: /orders/456

GET /orders/456
Authorization: Bearer <token>
Response: 200 OK
{
  "id": 456,
  "status": "pending",
  "items": [...],
  "total": 82.97,
  "created_at": "2024-12-20T10:30:00Z"
}

PATCH /orders/456
Authorization: Bearer <token>
{
  "status": "shipped",
  "tracking_number": "1Z999AA1234567890"
}
Response: 200 OK

Error Handling:

POST /orders
Authorization: Bearer <token>
{
  "items": [
    {"product_id": 999, "quantity": 2}
  ]
}
Response: 400 Bad Request
{
  "error": {
    "code": "INVALID_PRODUCT",
    "message": "One or more products do not exist",
    "details": [
      {
        "field": "items[0].product_id",
        "message": "Product 999 not found"
      }
    ]
  }
}

Rate Limiting:

GET /products
Response: 429 Too Many Requests
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1703073600
Retry-After: 3600
```

### **Conclusion**

RESTful API design patterns provide a foundation for building scalable, maintainable web services that leverage HTTP's capabilities effectively. Successful REST APIs balance theoretical purity with practical concerns, choosing patterns appropriate for their specific requirements. Key principles include resource-oriented design, proper HTTP method semantics, meaningful status codes, statelessness, and cacheability. Modern REST APIs incorporate additional patterns for pagination, filtering, versioning, authentication, error handling, and asynchronous operations. While pure REST with full HATEOAS implementation remains rare, adopting core REST principles creates APIs that are intuitive for developers, efficient in operation, and flexible for future evolution. Security, performance, documentation, and thoughtful evolution strategies ensure APIs serve both immediate needs and long-term organizational goals.

---

## Resource-Oriented Design

Resource-oriented design is an architectural approach that models systems as collections of resources, where each resource represents a discrete entity with a unique identifier, a set of attributes, and well-defined operations that can be performed on it. This design philosophy emphasizes thinking about data and functionality through the lens of resources rather than actions or procedures, creating systems that are intuitive, scalable, and aligned with the principles of REST (Representational State Transfer) and modern web architecture.

### Understanding Resource-Oriented Design

At its core, resource-oriented design treats everything as a resource—a conceptual entity that can be addressed, manipulated, and represented. Unlike traditional RPC (Remote Procedure Call) or action-oriented designs that focus on operations like "getUser" or "createOrder," resource-oriented design focuses on the resources themselves (User, Order) and applies standard operations to them.

This paradigm shift changes how developers think about system interfaces. Instead of defining custom methods for every operation, resource-oriented design leverages a uniform interface with a small set of standard operations applied consistently across all resources. This uniformity reduces cognitive load, improves predictability, and makes systems easier to understand and integrate.

Resources exist independently of their representations. A single resource might be represented as JSON, XML, HTML, or any other format depending on client needs, but the underlying resource remains the same. This separation between resources and their representations provides flexibility and enables content negotiation.

### Core Principles of Resource-Oriented Design

#### Everything is a Resource

The fundamental principle is that all significant entities in your system should be modeled as resources. A resource can be anything that's important enough to be referenced and manipulated: documents, images, users, orders, products, search results, or even abstract concepts like sessions or relationships.

Each resource must have a unique identifier (URI in web contexts) that distinguishes it from all other resources. This identifier serves as a stable reference point that remains consistent even as the resource's state changes over time.

Resources should represent nouns, not verbs. Instead of defining an endpoint for "transferMoney," you would have resources like "transactions" or "transfers" where creating a new instance performs the transfer operation.

#### Resources Have Representations

Resources are abstract entities that exist conceptually within the system. What clients actually interact with are representations of these resources—concrete serializations that convey the resource's current state.

A single resource can have multiple representations. For example, a user profile resource might be represented as JSON for API consumers, HTML for web browsers, or vCard format for contact management systems. The client specifies which representation they prefer, and the server provides it if possible.

Representations include both the resource data and metadata describing the representation itself (content type, encoding, language, etc.). This metadata enables clients to correctly interpret and process the resource representation.

#### Uniform Interface

Resource-oriented design employs a uniform, limited set of operations that apply to all resources. In REST, these operations are typically mapped to HTTP methods: GET (retrieve), POST (create), PUT (replace), PATCH (update), and DELETE (remove).

This uniformity means that once you understand how to interact with one resource, you understand how to interact with all resources in the system. There's no need to learn custom method names or operation semantics for each resource type.

The uniform interface simplifies client implementation, enables generic tooling, and makes APIs self-describing. Clients can discover and interact with new resources without requiring code changes.

#### Self-Descriptive Messages

Each message (request or response) in a resource-oriented system contains all the information needed to process it. This includes the operation being performed, the resource being targeted, the representation format, and any relevant metadata.

Self-descriptive messages enable stateless communication where servers don't need to retain client context between requests. All necessary context is provided in each message, improving scalability and reliability.

Response messages indicate their cacheability, allowing clients and intermediaries to cache representations and reduce network traffic. This caching is key to achieving high performance in distributed systems.

#### Hypermedia as the Engine of Application State (HATEOAS)

Resource representations include hyperlinks to related resources and available actions. These links guide clients through the application workflow without requiring out-of-band knowledge of the API structure.

Hypermedia enables loose coupling between clients and servers. Servers can change URI structures or add new capabilities, and clients that follow links continue working without modification.

This principle transforms APIs from static contracts into discoverable, evolvable systems where clients navigate relationships and discover capabilities dynamically.

### Resource Modeling

#### Identifying Resources

Effective resource identification is crucial to successful resource-oriented design. Start by analyzing your domain and identifying the key entities, concepts, and relationships that form your system's core.

Resources should map to domain concepts that have independent existence and meaning. They should be coarse-grained enough to be useful but fine-grained enough to be cohesive. A "user" is a good resource; a "userFirstName" probably isn't.

Consider both concrete entities (products, orders) and abstract concepts (searches, sessions, relationships). Collections themselves are resources—a collection of products is distinct from individual product resources.

Avoid modeling actions or operations as resources. If you find yourself creating resources with verb-like names, reconsider whether you're actually creating a resource that represents the result or record of that action.

#### Resource Hierarchies and Relationships

Resources often exist in hierarchical relationships. A blog resource contains post resources, which contain comment resources. These hierarchies should be reflected in resource identifiers and relationships.

Parent-child relationships indicate ownership or strong containment. Deleting a blog might delete all its posts, and deleting a post deletes all its comments. This cascade behavior should be clear and predictable.

Many relationships aren't strictly hierarchical. A product might be in multiple categories, an order references multiple products, and a user might have many addresses. These relationships can be modeled through links, embedded resources, or separate relationship resources.

Avoid creating overly deep hierarchies that make resource access cumbersome. Balance the expressiveness of hierarchical structure against practical usability.

#### Singleton vs Collection Resources

Collection resources represent groups of similar resources. They support operations like listing, filtering, searching, and creating new members. Examples include `/users`, `/products`, or `/orders`.

Singleton resources represent individual instances within collections or standalone entities. They support operations like retrieval, update, and deletion. Examples include `/users/123`, `/products/abc`, or `/orders/456`.

Some resources are inherently singletons and don't belong to collections. For example, `/me` representing the current authenticated user, or `/dashboard` representing a user's personalized dashboard.

Collections provide a natural point for filtering, pagination, and search operations. They enable bulk operations and provide overview information about the contained resources.

#### Resource Granularity

Resource granularity is the balance between having too many fine-grained resources and too few coarse-grained ones. Fine-grained resources offer flexibility but increase complexity and chattiness. Coarse-grained resources reduce complexity but may force clients to retrieve or send more data than needed.

Consider access patterns when determining granularity. If clients always need user profile data and user preferences together, consider them a single resource. If they're often accessed separately, model them as distinct resources.

Support different levels of detail through query parameters or separate resources. A brief user representation in a list can link to the full user resource with complete details.

Granularity decisions significantly impact system performance, caching effectiveness, and client complexity. Optimize for common cases while providing flexibility for exceptional needs.

### URI Design

#### URI Structure and Patterns

URIs (Uniform Resource Identifiers) are the addresses of resources. Well-designed URIs are intuitive, consistent, and predictable. They should be readable by humans but designed for machines.

Use path segments to represent hierarchy: `/blogs/123/posts/456/comments/789` clearly shows that comment 789 belongs to post 456, which belongs to blog 123.

Maintain consistency in naming conventions. If you use plural nouns for collections (`/users`), use them everywhere. If you use kebab-case for multi-word resources (`/user-preferences`), apply it uniformly.

URIs should be opaque from a REST perspective—clients shouldn't need to construct them. However, predictable patterns help developers and improve discoverability during development.

#### Query Parameters vs Path Segments

Path segments identify which resource you're addressing. Query parameters specify how to represent or filter that resource. `/users/123` identifies a specific user; `/users?role=admin` filters the users collection.

Use query parameters for optional filters, pagination, sorting, and representation hints. These don't change which resource you're addressing but modify how it's presented or which subset is returned.

Avoid encoding essential resource identity in query parameters. `/products?id=123` is less clear and RESTful than `/products/123`. The resource identifier should be in the path.

Search operations often use query parameters: `/products?search=laptop&minPrice=500&maxPrice=1000`. The resource is still the products collection, filtered by search criteria.

#### Versioning Strategies

API versioning is contentious in resource-oriented design because URIs should identify resources, not API versions. However, practical considerations often require versioning strategies.

URI path versioning (`/v1/users`, `/v2/users`) is explicit and simple but technically violates the principle that URIs identify resources—a user shouldn't have different URIs in different API versions.

Content negotiation versioning uses custom media types (`application/vnd.company.user.v1+json`) to request specific versions. This preserves URI stability but is more complex to implement and use.

Header-based versioning uses custom headers (`API-Version: 2`) to specify versions. This separates versioning from resource identification but makes testing and debugging more difficult.

Consider hypermedia-driven evolution where new capabilities are discovered through links rather than version numbers. This enables gradual evolution without breaking changes.

#### URI Anti-Patterns

Avoid encoding actions in URIs: `/deleteUser/123` or `/users/123/delete` mixes action-oriented thinking with resource URIs. Use `DELETE /users/123` instead.

Don't expose implementation details: `/users.php` or `/api/getUserById` reveals technology choices and action-oriented design. Focus on resources, not implementations.

Avoid overly complex or deep URI structures: `/organizations/1/departments/2/teams/3/members/4/roles/5/permissions/6` becomes unwieldy. Consider shortcuts or alternative access patterns.

Don't use query parameters when path parameters are more appropriate. `/users?id=123` should be `/users/123`. Query parameters are for optional filtering, not resource identification.

### HTTP Methods and Operations

#### GET - Retrieve Resources

GET retrieves a representation of a resource without modifying it. It's the most fundamental operation in resource-oriented design, used for reading data.

GET requests must be safe (no side effects) and idempotent (multiple identical requests produce the same result). This enables aggressive caching and safe retry logic.

GET on a collection returns a representation of the collection, typically including member representations or links to them. GET on a singleton returns that specific resource's representation.

Response codes for GET include 200 (OK) for successful retrieval, 404 (Not Found) when the resource doesn't exist, and 304 (Not Modified) when cached content is still valid.

#### POST - Create Resources

POST creates new resources, typically within a collection. The server determines the new resource's URI and returns it in the Location header.

POST is neither safe nor idempotent. Submitting the same POST request twice typically creates two resources. Clients should not automatically retry failed POST requests without user confirmation.

POST to a collection creates a new member: `POST /users` with user data creates a new user. The response includes 201 (Created) status and the Location header pointing to the new resource.

POST can also be used for operations that don't fit neatly into CRUD (Create, Read, Update, Delete), such as triggering actions or submitting forms. Some systems use POST to complex resources representing operations.

#### PUT - Replace Resources

PUT replaces an entire resource with a new representation. The client provides the complete new state, and the server replaces the existing resource.

PUT is idempotent—sending the same PUT request multiple times produces the same result as sending it once. This enables safe retry logic for failed requests.

PUT can create resources if the client controls the URI: `PUT /users/123` might create user 123 if it doesn't exist. However, POST is more common for creation because servers typically assign URIs.

Response codes include 200 (OK) or 204 (No Content) for successful replacement, and 201 (Created) if PUT created a new resource.

#### PATCH - Update Resources

PATCH partially updates a resource by applying a set of changes rather than replacing it entirely. This is more efficient than PUT when modifying only a few attributes of a large resource.

The request body contains a patch document describing the changes to apply. Formats include JSON Patch (RFC 6902) or JSON Merge Patch (RFC 7396), which specify how to express modifications.

PATCH should be idempotent when possible, though this depends on the patch format. JSON Merge Patch is idempotent; some JSON Patch operations aren't.

PATCH is particularly valuable for resources with many attributes where clients only need to modify a few. It reduces bandwidth and prevents issues where concurrent updates overwrite each other's changes.

#### DELETE - Remove Resources

DELETE removes a resource from the system. After successful deletion, subsequent GET requests for that resource should return 404 (Not Found).

DELETE is idempotent—deleting a resource multiple times has the same effect as deleting it once. The second DELETE might return 404 (already deleted) or 204 (successful deletion), but the resource is gone either way.

Consider soft deletion for resources where you need to maintain audit trails or enable recovery. The resource appears deleted to most clients but is actually marked as deleted and hidden from queries.

Response codes include 204 (No Content) for successful deletion with no response body, or 200 (OK) if returning information about the deletion operation.

#### Other HTTP Methods

HEAD retrieves headers without the response body, useful for checking resource existence or metadata without transferring the full representation.

OPTIONS returns information about communication options available for a resource, including which HTTP methods are supported. This enables capability discovery.

CONNECT, TRACE, and other HTTP methods are less commonly used in typical resource-oriented APIs but serve specific purposes in HTTP infrastructure.

Custom methods should be avoided in favor of resource modeling. If you need custom operations, consider whether they can be modeled as resources themselves (e.g., a "transfer" resource rather than a "transferMoney" method).

### Representations and Content Negotiation

#### Representation Formats

JSON has become the dominant representation format for web APIs due to its simplicity, broad language support, and JavaScript compatibility. It strikes a good balance between human readability and machine efficiency.

XML was historically popular and remains important in enterprise contexts. It offers schema validation, namespaces, and established tooling but is more verbose than JSON.

Protocol Buffers, MessagePack, and other binary formats offer efficiency advantages for high-performance scenarios but sacrifice human readability and universal compatibility.

HTML representations enable hypermedia-rich APIs where the same resource can serve both API clients and human users through web browsers. This unification reduces redundancy and improves consistency.

#### Content Type Negotiation

Clients specify their preferred representation format using the Accept header: `Accept: application/json` requests JSON representation. Servers respond with the Content-Type header indicating the actual format provided.

Servers may support multiple formats for the same resource. A product resource might be available as JSON, XML, or HTML. The server selects the best match based on client preferences and server capabilities.

Quality values in Accept headers indicate preference strength: `Accept: application/json; q=0.9, application/xml; q=0.5` prefers JSON but accepts XML. Servers use these hints to choose representations.

When a server can't provide any acceptable representation, it returns 406 (Not Acceptable). This is preferable to guessing or defaulting, as it makes incompatibility explicit.

#### Custom Media Types

Custom media types (e.g., `application/vnd.company.product+json`) enable versioning and provide semantic information about resource types. They indicate not just the format (JSON) but also the schema and semantics.

Media types can specify API versions without encoding them in URIs: `application/vnd.company.product.v2+json` identifies version 2 of the product representation.

Clients that understand specific media types can take advantage of their semantics. Clients that don't can still process them as generic JSON or XML.

Custom media types increase complexity and should be used judiciously. Simple APIs may not need this level of sophistication.

#### Hypermedia and Link Relations

Links in representations connect resources and guide clients through the application workflow. Each link includes a relation type indicating what the link represents and a URI identifying the target.

Standard relation types (next, previous, self, related) have well-defined meanings. Custom relation types enable domain-specific navigation while maintaining the hypermedia principle.

Links should be absolute URIs when possible to avoid ambiguity and enable representation portability. Relative URIs require a base URI context.

Rich hypermedia formats like HAL (Hypertext Application Language), JSON:API, or Siren provide structured ways to embed links and related resources in representations.

### State Management

#### Stateless Communication

Resource-oriented design emphasizes stateless communication where each request contains all information needed to process it. Servers don't maintain session state between requests.

Statelessness improves scalability because any server can handle any request—there's no session affinity binding clients to specific servers. It simplifies failure recovery and enables horizontal scaling.

Authentication tokens (like JWTs) carry user identity and permissions in each request, eliminating the need for server-side session storage. The token itself contains the state.

Statelessness doesn't mean applications are stateless—it means communication is stateless. Resource state is maintained and managed, but protocol-level conversation state is not.

#### Resource State vs Application State

Resource state is the data associated with a resource—a user's profile information, a product's price and description, an order's items and status. This state is stored on the server and persists across requests.

Application state is the client's current position in workflow, selected filters, in-progress form data, etc. In resource-oriented design, application state is maintained by the client, not the server.

Servers provide hypermedia (links and forms) that guides clients through workflows. The client decides which links to follow based on its application state, but the server doesn't track where each client is in the workflow.

This separation enables clients and servers to evolve independently. Servers can restructure workflows by changing links without breaking clients that follow links rather than hardcoding navigation.

#### Caching and Conditional Requests

Caching is fundamental to achieving performance in resource-oriented systems. Servers indicate cacheability using Cache-Control headers, and clients cache responses to avoid redundant requests.

ETags provide version identifiers for representations. Clients include them in subsequent requests using If-None-Match headers. If the resource hasn't changed, the server returns 304 (Not Modified) without sending the body.

Last-Modified dates enable time-based conditional requests. Clients use If-Modified-Since headers to request resources only if they've been updated since a specific time.

Proper caching dramatically reduces server load and network traffic. It also improves client-side performance by providing instant access to cached representations.

#### Optimistic Concurrency Control

When multiple clients might update the same resource concurrently, optimistic concurrency control prevents lost updates. Clients include version information (ETag or version number) when submitting updates.

The server only applies the update if the current version matches the client's version. If another update occurred in the meantime, the server returns 412 (Precondition Failed), and the client must retrieve the current state and retry.

This approach avoids the complexity of locking while ensuring updates don't overwrite each other. It works well for resources that are read frequently but updated infrequently.

For resources with frequent concurrent updates, consider fine-grained resources where clients update specific attributes rather than replacing entire resources, reducing conflict likelihood.

### Error Handling and Status Codes

#### HTTP Status Codes

Status codes communicate operation outcomes. 2xx codes indicate success: 200 (OK), 201 (Created), 204 (No Content). These tell clients their request succeeded.

3xx codes indicate redirection: 301 (Moved Permanently), 302 (Found), 304 (Not Modified). These guide clients to the correct resource or indicate cached content is still valid.

4xx codes indicate client errors: 400 (Bad Request), 401 (Unauthorized), 403 (Forbidden), 404 (Not Found), 409 (Conflict), 422 (Unprocessable Entity). These tell clients what they did wrong.

5xx codes indicate server errors: 500 (Internal Server Error), 502 (Bad Gateway), 503 (Service Unavailable). These indicate problems on the server side, not client mistakes.

#### Error Response Bodies

Status codes alone often don't provide enough information for clients to understand and recover from errors. Error response bodies should include detailed error information in a structured format.

Include an error code or type that clients can programmatically check, a human-readable message explaining the error, and specific details about what went wrong (which fields were invalid, why authorization failed, etc.).

For validation errors, include field-level details specifying which fields were invalid and why. This enables clients to present targeted error messages to users.

Maintain consistent error response formats across your API. This enables clients to implement generic error handling rather than special-casing each endpoint.

#### Validation and Business Rules

Distinguish between syntactic validation (invalid JSON, missing required fields) and semantic validation (negative price, invalid state transition). Both should return 400 or 422 but with different details.

Business rule violations (insufficient inventory, account limits exceeded) should be clearly distinguished from validation errors. The resource representation is valid, but business logic prevents the operation.

Provide as much validation feedback as possible in a single response. Validating only the first error and requiring clients to fix and resubmit repeatedly creates poor user experience.

Consider using problem details format (RFC 7807) which provides a standardized structure for error responses including type, title, status, detail, and instance fields.

#### Rate Limiting and Throttling

Protect your API from overuse through rate limiting. Return 429 (Too Many Requests) when clients exceed rate limits, and include headers indicating limits and reset times.

Rate limit headers should include the limit (requests allowed per window), remaining (requests left in current window), and reset (when the window resets).

Different rate limit tiers for different clients or authentication levels enable fair resource allocation. Anonymous users might have lower limits than authenticated users or premium subscribers.

Graceful degradation is preferable to hard failures. Consider returning partial results or cached data when approaching limits rather than completely rejecting requests.

### Advanced Patterns

#### Pagination

Large collections must be paginated to remain performant. Pagination divides results into manageable pages and provides navigation mechanisms.

Offset-based pagination uses parameters like `?offset=20&limit=10` to specify which slice to return. It's simple but inefficient for large datasets and produces inconsistent results when data changes during pagination.

Cursor-based pagination uses opaque tokens representing positions in the result set: `?cursor=abc123`. This is more efficient and handles data changes gracefully but is more complex to implement.

Link-based pagination includes next, previous, first, and last links in responses. Clients follow these links rather than constructing page URLs, enabling pagination strategy changes without breaking clients.

Include total count metadata when feasible, but recognize that counting can be expensive for large datasets. Consider approximate counts or omitting counts for performance-sensitive APIs.

#### Filtering and Searching

Collections should support filtering to help clients find relevant resources. Use query parameters to specify filter criteria: `/products?category=electronics&priceMin=100&priceMax=500`.

Define clear semantics for filters. Should multiple values for the same parameter be AND or OR? How are ranges expressed? Document these conventions clearly.

Full-text search often warrants a dedicated search resource or endpoint: `/products/search?q=laptop` or `/search/products?q=laptop`. This distinguishes search from simple filtering.

Consider supporting both simple filtering (exact matches) and advanced querying (greater than, less than, contains, etc.) through different parameter syntaxes or separate parameters.

#### Sorting

Enable clients to specify result ordering through query parameters: `/products?sort=price` or `/products?sort=-price` (descending). Multiple sort fields can be comma-separated: `?sort=category,price`.

Default sort orders should be predictable and documented. Random ordering makes debugging difficult and results inconsistent.

Combine sorting with pagination carefully. The sort order must remain consistent across page requests, or clients may skip or duplicate results.

For expensive sort operations, consider pre-computed views or limiting sort options to indexed fields.

#### Partial Responses and Field Selection

Clients don't always need full resource representations. Field selection allows clients to request only needed attributes: `/users/123?fields=name,email,createdAt`.

This reduces bandwidth, improves performance, and gives clients control over data transfer. It's especially valuable for mobile clients with limited bandwidth.

Define semantics carefully. Should nested fields be included by default? How are nested fields selected? Balance flexibility with simplicity.

GraphQL-style field selection offers more power but increases complexity. REST APIs typically use simpler comma-separated field lists.

#### Batch Operations

Batch operations enable clients to perform multiple operations in a single request, reducing round trips and improving efficiency.

Batch creation posts an array of resources to a collection: `POST /users` with `[{user1}, {user2}, {user3}]`. The response indicates which succeeded and which failed.

Batch updates and deletes are more complex. Some systems support PATCH/DELETE on collections with filter criteria. Others use separate batch endpoints.

Partial success handling is critical. If 8 of 10 operations succeed, what status code do you return? Include per-operation results in the response body.

#### Async Operations and Long-Running Tasks

Some operations take too long for synchronous HTTP request-response. Creating a report, processing a video, or executing a complex analysis might take minutes or hours.

Return 202 (Accepted) immediately with a link to a status resource. Clients poll this resource to check operation status: GET /tasks/abc123 returns progress information.

The status resource provides operation state (pending, running, completed, failed), progress percentage if applicable, and links to results when complete.

Consider webhooks or Server-Sent Events for real-time status updates instead of requiring clients to poll.

#### File Uploads and Downloads

File uploads typically use multipart/form-data encoding. POST to a collection resource with the file creates a new file resource: `POST /documents` with file data.

Large file uploads may use resumable upload protocols where clients upload chunks and can resume after interruptions. Return upload URLs and chunk endpoints.

File downloads use appropriate Content-Type headers and Content-Disposition to suggest filenames. Large files may support range requests (206 Partial Content) for resumable downloads.

Consider separate storage services for files with APIs focused on file operations. Your main API references file resources by URI rather than embedding them.

#### Versioning Resources

Resources evolve over time. Version management ensures clients can access historical states when needed.

Temporal resources include version information in their URI: `/documents/123/versions/5` accesses version 5. GET `/documents/123` returns the current version.

Some systems embed version history in the resource representation itself, with links to specific versions. Others maintain separate version collections.

For regulatory or audit requirements, ensure old versions remain accessible even as resources change. Immutable version resources guarantee historical data integrity.

### Security Considerations

#### Authentication

Authentication verifies client identity. Common mechanisms include API keys, OAuth 2.0 tokens, and JWTs (JSON Web Tokens).

API keys are simple but should be transmitted over HTTPS and rotated regularly. They identify the client application but not individual users.

OAuth 2.0 enables delegated authorization where users grant third-party applications limited access without sharing credentials. It's complex but powerful for multi-party scenarios.

JWTs contain encoded claims about the authenticated principal. They're self-contained (no server-side session lookup required) and can include authorization information.

#### Authorization

Authorization determines what authenticated clients can do. Implement fine-grained access control based on user roles, resource ownership, or other criteria.

Check authorization for every request. Don't assume that because a user could access a resource previously, they still can. Permissions may have been revoked.

Return 401 (Unauthorized) for authentication failures and 403 (Forbidden) for authorization failures. This distinction helps clients diagnose problems.

Consider field-level authorization where different clients see different resource attributes based on their permissions. Administrators see more than regular users.

#### Input Validation and Sanitization

Validate all input strictly. Reject malformed requests early rather than attempting to process questionable data.

Sanitize input to prevent injection attacks. This includes SQL injection, XSS, command injection, and other attack vectors where untrusted input is interpreted as code.

Use parameterized queries and ORM frameworks that handle escaping automatically. Never concatenate user input into queries or commands.

Validate data types, ranges, formats, and business rules. A negative quantity or a future birth date should be rejected.

#### HTTPS and Transport Security

Always use HTTPS in production to encrypt data in transit. This prevents eavesdropping and man-in-the-middle attacks.

Use HSTS (HTTP Strict Transport Security) headers to instruct browsers to always use HTTPS, preventing downgrade attacks.

Implement proper certificate validation. Expired or invalid certificates should cause connection failures, not warnings that users can click through.

Consider certificate pinning for high-security applications, though this increases operational complexity.

#### CORS and Cross-Origin Access

CORS (Cross-Origin Resource Sharing) controls which web applications can access your API from browsers. Configure allowed origins, methods, and headers appropriately.

Wildcard origins (`Access-Control-Allow-Origin: *`) should only be used for truly public APIs. Most APIs should specify exact allowed origins.

Credentials (cookies, authorization headers) require explicit permission through `Access-Control-Allow-Credentials: true`. Don't allow credentialed requests from wildcard origins.

Preflight requests (OPTIONS) enable browsers to check CORS policies before sending actual requests. Respond correctly to preflight requests for all endpoints.

### Testing and Quality

#### API Testing Strategies

Unit tests validate individual components like resource serialization, validation logic, and business rules. These tests are fast and focused.

Integration tests verify that components work together correctly, including database interactions, external service calls, and request processing pipelines.

Contract tests ensure API responses match documented schemas and behaviors. They catch breaking changes before clients encounter them.

End-to-end tests validate complete workflows from client perspective, exercising real HTTP requests and responses.

#### Documentation and Specification

Comprehensive documentation is essential for resource-oriented APIs. Document every resource, representation format, operation, status code, and error condition.

OpenAPI (formerly Swagger) provides machine-readable API specifications from which documentation, client SDKs, and validation tools can be generated.

Include examples in documentation showing actual requests and responses. These examples help developers understand API usage faster than abstract descriptions.

Keep documentation synchronized with implementation. Outdated documentation is worse than no documentation because it misleads developers.

#### Monitoring and Observability

Monitor API usage patterns including request rates, response times, error rates, and status code distributions. These metrics reveal performance issues and usage trends.

Track resource-level metrics to understand which resources are most popular, which are slow, and which produce errors frequently.

Implement distributed tracing to track requests across multiple services and identify bottlenecks in complex workflows.

Log sufficient information for debugging without logging sensitive data. Include request IDs in logs to correlate related log entries.

#### Performance Optimization

Implement caching aggressively. Cache at multiple levels: client-side, CDN, API gateway, and database query results.

Minimize database queries through eager loading, query optimization, and denormalization where appropriate. N+1 query problems severely impact performance.

Use compression for response bodies. Gzip or Brotli can dramatically reduce bandwidth requirements for text-based representations.

Implement pagination, field selection, and other mechanisms to reduce response sizes. Clients should receive only what they need.

### Migration and Evolution

#### Evolving APIs Without Breaking Clients

Add new resources, representations, and optional fields without breaking existing clients. Follow the robustness principle: be conservative in what you send, liberal in what you accept.

Avoid removing fields or resources that existing clients depend on. Deprecate them first, giving clients time to adapt before removal.

Use hypermedia to enable evolutionary change. If clients follow links rather than hardcoding URIs, you can restructure URI patterns without breaking them.

Version APIs when necessary, but recognize that supporting multiple versions creates maintenance burden. Invest in backward-compatible evolution when possible.

#### Deprecation Strategies

Announce deprecations well in advance through documentation, headers, and developer communications. Give clients reasonable time to migrate.

Include deprecation warnings in API responses using custom headers or warning messages. Make deprecated features visible to developers.

Set clear timelines for deprecation and eventual removal. Communicate these timelines clearly and stick to them.

Provide migration guides explaining how to transition from deprecated features to replacements. Include code examples and address common issues.

#### Transitioning from Legacy Systems

When migrating from legacy systems, create resource-oriented facades that present modern APIs while integrating with existing backends.

Implement both old and new APIs temporarily, routing some clients to each. Gradually migrate clients to the new API as they're ready.

Use API gateways or proxy layers to translate between old and new representations, enabling incremental migration.

Consider strangler fig pattern where new functionality is added to the resource-oriented API while legacy functionality remains in the old system, gradually replacing it.

### Comparison with Other Approaches

#### Resource-Oriented vs RPC

RPC (Remote Procedure Call) designs focus on operations: `getUser(123)`, `createOrder(items)`, `transferMoney(from, to, amount)`. Resource-oriented designs focus on resources and standard operations.

RPC can be more natural for action-centric operations, but it lacks the uniform interface benefits of resource-oriented design. Each operation requires custom documentation and client code.

Resource-oriented design's constraints (limited operations, stateless communication) may seem restrictive but provide benefits in caching, tooling, and evolvability.

Many systems blend both approaches, using resource-oriented design for CRUD operations and RPC-style endpoints for complex actions that don't map cleanly to resources.

#### Resource-Oriented vs GraphQL

GraphQL lets clients specify exactly what data they need through flexible queries. This eliminates over-fetching and under-fetching problems.

Resource-oriented APIs are simpler and leverage existing HTTP infrastructure. They're easier to cache and require less specialized tooling.

GraphQL's flexibility comes with complexity. Query parsing, validation, and execution are more involved than simple resource retrieval.

The choice depends on use case. GraphQL excels for complex, graph-like data with varied client needs. Resource-oriented APIs work well for straightforward CRUD operations and public APIs where caching is important.

#### Resource-Oriented vs Event-Driven

Event-driven architectures propagate state changes as events. Consumers react to events asynchronously rather than requesting resources on demand.

Resource-oriented design is synchronous and pull-based; event-driven is asynchronous and push-based. Both have their place in modern systems.

Combine both approaches: resource-oriented APIs for synchronous queries and updates, event streams for real-time notifications and inter-service communication.

Events capture what happened; resources represent current state. Events provide audit trails and enable event sourcing; resources provide query capabilities.

**Key Points**

- Resource-oriented design models systems as collections of resources with uniform interfaces rather than custom operations for each action
- Every significant entity should be modeled as a resource with a unique identifier, representations, and standard operations
- The uniform interface (GET, POST, PUT, PATCH, DELETE) simplifies client implementation and enables generic tooling
- URIs should be intuitive and consistent, using path segments for hierarchy and query parameters for filtering and representation hints
- Representations are separate from resources—the same resource can have multiple formats (JSON, XML, HTML)
- Stateless communication improves scalability by allowing any server to handle any request without session affinity
- Hypermedia (links in representations) enables loose coupling and guides clients through workflows dynamically
- Caching is fundamental to performance—servers indicate cacheability and clients respect cache directives
- HTTP status codes communicate operation outcomes clearly: 2xx for success, 4xx for client errors, 5xx for server errors
- Security requires HTTPS, proper authentication/authorization, input validation, and CORS configuration
- API evolution should be backward-compatible when possible, with clear deprecation strategies when changes are necessary
- Resource-oriented design emphasizes simplicity, uniformity, and leveraging HTTP's built-in capabilities

**Example**

Consider an e-commerce system designed with resource-oriented principles:

```markdown
Resource Model:

Products Collection: /products
- GET /products - List products (paginated, filterable)
- POST /products - Create new product (admin only)
- GET /products?category=electronics&minPrice=100 - Filtered products
- GET /products?sort=-price&fields=id,name,price - Sorted, partial fields

Product Singleton: /products/{id}
- GET /products/123 - Retrieve product details
- PUT /products/123 - Replace product (admin only)
- PATCH /products/123 - Update specific fields (admin only)
- DELETE /products/123 - Remove product (admin only)

Product Reviews: /products/{id}/reviews
- GET /products/123/reviews - List reviews for product
- POST /products/123/reviews - Create review (authenticated users)

Orders Collection: /orders
- GET /orders - List user's orders
- POST /orders - Create new order

Order Singleton: /orders/{id}
- GET /orders/456 - Retrieve order details
- PATCH /orders/456 - Update order (cancel, modify)

Order Items: /orders/{id}/items
- Embedded in order representation, not separate resources

Shopping Cart: /me/cart (singleton for current user)
- GET /me/cart - Retrieve cart contents
- PUT /me/cart - Replace entire cart
- POST /me/cart/items - Add item to cart
- DELETE /me/cart/items/{itemId} - Remove item

User Profile: /users/{id}
- GET /users/123 - Public profile (limited fields)
- GET /me - Current user's full profile
- PATCH /me - Update own profile

Sample Interaction Flow:

1. Browse Products:
GET /products?category=laptops&page=1
Response: 200 OK
{
  "items": [
    {
      "id": "prod-123",
      "name": "Professional Laptop",
      "price": 1299.99,
      "links": {
        "self": "/products/prod-123",
        "reviews": "/products/prod-123/reviews",
        "addToCart": "/me/cart/items"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "perPage": 20,
    "total": 45,
    "links": {
      "next": "/products?category=laptops&page=2",
      "last": "/products?category=laptops&page=3"
    }
  }
}

2. View Product Details:
GET /products/prod-123
Accept: application/json
Response: 200 OK
ETag: "abc123xyz"
Cache-Control: public, max-age=300
{
  "id": "prod-123",
  "name": "Professional Laptop",
  "description": "High-performance laptop...",
  "price": 1299.99,
  "stock": 15,
  "specifications": {...},
  "links": {
    "self": "/products/prod-123",
    "reviews": "/products/prod-123/reviews",
    "relatedProducts": "/products?related=prod-123",
    "addToCart": "/me/cart/items"
  }
}

3. Add to Cart:
POST /me/cart/items
Authorization: Bearer eyJ0eXAiOiJKV1...
Content-Type: application/json
{
  "productId": "prod-123",
  "quantity": 1
}
Response: 201 Created
Location: /me/cart/items/item-789

4. View Cart:
GET /me/cart
Authorization: Bearer eyJ0eXAiOiJKV1...
Response: 200 OK
{
  "userId": "user-456",
  "items": [
    {
      "id": "item-789",
      "productId": "prod-123",
      "productName": "Professional Laptop",
      "price": 1299.99,
      "quantity": 1,
      "links": {
        "product": "/products/prod-123",
        "remove": "/me/cart/items/item-789"
      }
    }
  ],
  "totalPrice": 1299.99,
  "links": {
    "self": "/me/cart",
    "checkout": "/orders"
  }
}

5. Create Order:
POST /orders
Authorization: Bearer eyJ0eXAiOiJKV1...
Content-Type: application/json
{
  "shippingAddress": {...},
  "paymentMethod": "card-ending-1234"
}
Response: 201 Created
Location: /orders/order-999
{
  "id": "order-999",
  "status": "pending",
  "items": [...],
  "totalPrice": 1299.99,
  "createdAt": "2025-12-25T10:30:00Z",
  "links": {
    "self": "/orders/order-999",
    "payment": "/orders/order-999/payment",
    "cancel": "/orders/order-999"
  }
}

6. Update Order Status (Admin):
PATCH /orders/order-999
Authorization: Bearer admin-token
If-Match: "def456uvw"
Content-Type: application/merge-patch+json
{
  "status": "shipped",
  "trackingNumber": "TRACK123456"
}
Response: 200 OK
ETag: "ghi789rst"

Error Handling Examples:

Validation Error:
POST /products
{
  "name": "",
  "price": -10
}
Response: 422 Unprocessable Entity
{
  "type": "validation-error",
  "title": "Validation Failed",
  "status": 422,
  "errors": [
    {
      "field": "name",
      "message": "Name is required and cannot be empty"
    },
    {
      "field": "price",
      "message": "Price must be greater than zero"
    }
  ]
}

Not Found:
GET /products/nonexistent
Response: 404 Not Found
{
  "type": "not-found",
  "title": "Product Not Found",
  "status": 404,
  "detail": "Product with ID 'nonexistent' does not exist"
}

Unauthorized:
GET /orders
Response: 401 Unauthorized
WWW-Authenticate: Bearer realm="API"
{
  "type": "unauthorized",
  "title": "Authentication Required",
  "status": 401,
  "detail": "Valid authentication token required"
}

Conflict:
DELETE /products/prod-123
Response: 409 Conflict
{
  "type": "delete-conflict",
  "title": "Cannot Delete Product",
  "status": 409,
  "detail": "Product cannot be deleted because it appears in 5 active orders"
}
```

**Output**

The resource-oriented design produces:

```markdown
System Characteristics:

Discoverability:
- Clients follow hypermedia links rather than hardcoding URIs
- New endpoints discoverable through link relations
- Self-documenting through OPTIONS requests and link metadata

Scalability:
- Stateless design enables horizontal scaling
- Any server can handle any request
- Aggressive caching reduces server load
- CDN caching for product representations

Performance Metrics:
- 95th percentile response time: 150ms for cached resources
- Cache hit rate: 75% for product details
- 89% reduction in bandwidth through field selection and caching
- Support for 10,000 concurrent users per server instance

Client Flexibility:
- Multiple representation formats supported (JSON, XML, HTML)
- Field selection reduces mobile bandwidth by 60%
- Partial updates via PATCH minimize data transfer
- Conditional requests prevent redundant downloads

Evolution Capability:
- New fields added without breaking existing clients
- URI structure changes transparent to clients following links
- API versioning through content negotiation when needed
- Smooth migration from v1 to v2 over 6-month period

Developer Experience:
- Consistent patterns across all resources
- Standard HTTP tooling works out of the box
- Clear error messages with actionable information
- Generated client SDKs from OpenAPI specification

Operational Benefits:
- Standard monitoring works with existing tools
- HTTP caching reduces database queries by 70%
- Load balancers understand HTTP semantics
- Rate limiting and authentication at gateway level
```

**Conclusion**

Resource-oriented design provides a principled approach to building APIs that are intuitive, scalable, and evolvable. By focusing on resources rather than operations, using uniform interfaces, embracing stateless communication, and leveraging HTTP's built-in capabilities, this design philosophy creates systems that are easier to understand, integrate, and maintain.

The constraints of resource-oriented design—limited operations, stateless communication, uniform interfaces—may initially seem restrictive, but they provide significant benefits in terms of caching, tooling, and loose coupling. These constraints force designers to think carefully about their domain model and create cleaner, more consistent APIs.

Resource-oriented design aligns naturally with RESTful principles and modern web architecture. It leverages decades of HTTP infrastructure investment and enables standard tooling to work without customization. The hypermedia aspect enables APIs to evolve without breaking clients, reducing the coupling between API providers and consumers.

While resource-oriented design isn't appropriate for every scenario—real-time communication, complex transactions, and highly action-oriented systems may benefit from other approaches—it provides an excellent foundation for most web APIs. Understanding its principles, patterns, and tradeoffs enables architects to build APIs that serve their users effectively while remaining maintainable and scalable over time.

**Next Steps**

- Analyze your existing APIs or planned systems to identify resources and their relationships
- Design URI structures that are intuitive, consistent, and reflect resource hierarchies
- Implement comprehensive content negotiation to support multiple representation formats
- Add hypermedia links to resource representations to enable client navigation and discovery
- Implement proper HTTP caching with ETags, Last-Modified dates, and Cache-Control headers
- Design error responses with detailed, actionable information using consistent formats
- Create comprehensive API documentation using OpenAPI specification
- Implement rate limiting and authentication to protect your API from abuse
- Add monitoring and logging to track API usage, performance, and errors
- Test your API thoroughly including unit tests, integration tests, and contract tests
- Review your API design with actual clients to ensure it meets their needs
- Consider hypermedia formats like HAL or JSON:API for richer resource representations
- Implement pagination, filtering, and sorting for collection resources
- Plan your API evolution strategy including versioning and deprecation policies
- Study successful resource-oriented APIs (GitHub, Stripe, Twilio) to understand best practices

---

## HATEOAS

HATEOAS (Hypermedia as the Engine of Application State) is a constraint of REST architecture that requires a RESTful API to provide clients with dynamic navigation through hypermedia links embedded in responses. Rather than relying on out-of-band information or hardcoded URLs, clients discover available actions and resources through links provided by the server, making the API self-descriptive and enabling loose coupling between client and server.

### Purpose and Problem Statement

Traditional REST APIs typically require clients to have prior knowledge of available endpoints, URL structures, and the sequence of operations needed to accomplish tasks. This tight coupling creates several challenges:

- Clients must maintain knowledge of URL construction patterns
- API evolution becomes difficult as changing URLs requires updating all clients
- Documentation must be kept rigorously synchronized with implementation
- Clients cannot dynamically discover available operations
- The relationship between resources remains implicit rather than explicit

HATEOAS addresses these issues by making the API self-documenting and discoverable. The server tells clients what actions are possible at any given moment through hypermedia links, similar to how web browsers navigate HTML pages through links without prior knowledge of site structure.

### Core Concepts

#### Hypermedia Controls

Hypermedia controls are elements within API responses that guide client navigation and interaction. The primary types include:

**Links**: References to related resources or available actions. Links contain at minimum a URL and typically include additional metadata like relationship type, HTTP method, and media type.

**Forms**: Structured descriptions of how to construct requests, including required parameters, validation rules, and submission endpoints.

**Embedded Resources**: Related resources included directly in the response to reduce the number of requests needed.

#### Link Relations

Link relations (rel values) describe the semantic relationship between the current resource and the linked resource. Standard relation types defined in IANA's link relation registry include:

- `self`: The current resource's canonical URL
- `next`/`prev`: Sequential navigation through collections
- `first`/`last`: Boundary navigation in collections
- `edit`: URL for modifying the resource
- `delete`: URL for removing the resource
- `collection`: URL of the collection containing this resource
- `item`: Individual items within a collection

Custom relation types can be defined for domain-specific relationships using URI-based identifiers to avoid naming conflicts.

#### Resource State and Transitions

In HATEOAS, application state exists on the client side while resource state exists on the server. The server provides hypermedia controls that define valid state transitions based on:

- Current resource state
- Client authentication and authorization
- Business rules and constraints
- System availability and configuration

This approach means clients don't need to understand business logic—the server indicates what operations are currently valid.

#### Affordances

Affordances represent the actions available to clients at any given moment. In HATEOAS, affordances are explicitly communicated through hypermedia controls rather than being implied or documented externally. An order that can be canceled includes a link with `rel="cancel"`, while an order that has shipped would not include this link.

### Implementation Approaches

#### HAL (Hypertext Application Language)

HAL is a lightweight hypermedia format that provides a consistent structure for linking resources. HAL responses include two reserved properties:

`_links`: Contains navigation links with relation types `_embedded`: Contains embedded resources

HAL response structure:

```json
{
  "id": 12345,
  "status": "pending",
  "total": 99.99,
  "currency": "USD",
  "_links": {
    "self": {
      "href": "/orders/12345"
    },
    "customer": {
      "href": "/customers/789"
    },
    "payment": {
      "href": "/orders/12345/payment"
    },
    "cancel": {
      "href": "/orders/12345",
      "method": "DELETE"
    }
  },
  "_embedded": {
    "items": [
      {
        "id": 1,
        "product": "Widget",
        "quantity": 2,
        "price": 49.99,
        "_links": {
          "self": {
            "href": "/orders/12345/items/1"
          },
          "product": {
            "href": "/products/456"
          }
        }
      }
    ]
  }
}
```

#### JSON:API

JSON:API provides a comprehensive specification for building APIs with strong conventions around resource representation, relationships, and inclusion of related resources.

JSON:API response structure:

```json
{
  "data": {
    "type": "orders",
    "id": "12345",
    "attributes": {
      "status": "pending",
      "total": 99.99,
      "currency": "USD"
    },
    "relationships": {
      "customer": {
        "links": {
          "self": "/orders/12345/relationships/customer",
          "related": "/orders/12345/customer"
        },
        "data": {
          "type": "customers",
          "id": "789"
        }
      },
      "items": {
        "links": {
          "self": "/orders/12345/relationships/items",
          "related": "/orders/12345/items"
        }
      }
    },
    "links": {
      "self": "/orders/12345"
    }
  },
  "included": [
    {
      "type": "customers",
      "id": "789",
      "attributes": {
        "name": "John Smith",
        "email": "john@example.com"
      }
    }
  ],
  "links": {
    "payment": "/orders/12345/payment",
    "cancel": "/orders/12345"
  }
}
```

#### Siren

Siren is an expressive hypermedia format that represents entities with properties, links, actions, and embedded sub-entities. It provides rich action descriptions including field definitions and validation requirements.

Siren response structure:

```json
{
  "class": ["order"],
  "properties": {
    "id": 12345,
    "status": "pending",
    "total": 99.99,
    "currency": "USD"
  },
  "entities": [
    {
      "class": ["items", "collection"],
      "rel": ["items"],
      "href": "/orders/12345/items"
    }
  ],
  "actions": [
    {
      "name": "cancel-order",
      "title": "Cancel Order",
      "method": "DELETE",
      "href": "/orders/12345"
    },
    {
      "name": "add-item",
      "title": "Add Item",
      "method": "POST",
      "href": "/orders/12345/items",
      "type": "application/json",
      "fields": [
        {
          "name": "productId",
          "type": "number",
          "required": true
        },
        {
          "name": "quantity",
          "type": "number",
          "required": true,
          "value": 1
        }
      ]
    }
  ],
  "links": [
    {
      "rel": ["self"],
      "href": "/orders/12345"
    },
    {
      "rel": ["customer"],
      "href": "/customers/789"
    },
    {
      "rel": ["payment"],
      "href": "/orders/12345/payment"
    }
  ]
}
```

#### Collection+JSON

Collection+JSON focuses specifically on representing collections of resources with consistent patterns for querying, templates for creating items, and error handling.

Collection+JSON response structure:

```json
{
  "collection": {
    "version": "1.0",
    "href": "/orders",
    "links": [
      {
        "rel": "next",
        "href": "/orders?page=2"
      }
    ],
    "items": [
      {
        "href": "/orders/12345",
        "data": [
          {
            "name": "status",
            "value": "pending"
          },
          {
            "name": "total",
            "value": 99.99
          }
        ],
        "links": [
          {
            "rel": "customer",
            "href": "/customers/789"
          }
        ]
      }
    ],
    "queries": [
      {
        "rel": "search",
        "href": "/orders",
        "data": [
          {
            "name": "status",
            "value": ""
          },
          {
            "name": "customer",
            "value": ""
          }
        ]
      }
    ],
    "template": {
      "data": [
        {
          "name": "customerId",
          "value": "",
          "required": true
        },
        {
          "name": "items",
          "value": "",
          "required": true
        }
      ]
    }
  }
}
```

### Design Considerations

#### Link Generation Strategy

Generating consistent, stable links requires careful design:

**URL Template Approach**: Define URL patterns centrally and use templating to generate specific URLs. This ensures consistency and simplifies URL structure changes.

**Link Builder Pattern**: Create dedicated components responsible for generating links based on resource context, user permissions, and current state.

**Reverse Routing**: Use named routes or controllers to generate URLs rather than constructing them manually, ensuring changes to route definitions automatically propagate to link generation.

#### State-Dependent Links

Links should reflect current resource state and available transitions:

- Pending orders include links for payment, cancellation, and modification
- Paid orders include links for shipment tracking and returns
- Shipped orders include links for delivery confirmation and return initiation
- Completed orders include links for reviews and reordering

[Inference] This state-dependent link generation typically requires business logic that evaluates current state against transition rules.

#### Permission-Based Link Filtering

Links should only appear when the current user has permission to perform the associated action:

- Administrative users see links for deletion and privileged operations
- Regular users see links for their own resources only
- Anonymous users see only public resource links
- Role-based filtering ensures appropriate link visibility

#### Pagination and Collection Navigation

Collections require navigation controls for traversing large result sets:

```json
{
  "items": [...],
  "_links": {
    "self": {
      "href": "/orders?page=3"
    },
    "first": {
      "href": "/orders?page=1"
    },
    "prev": {
      "href": "/orders?page=2"
    },
    "next": {
      "href": "/orders?page=4"
    },
    "last": {
      "href": "/orders?page=10"
    }
  },
  "page": 3,
  "pageSize": 20,
  "totalItems": 200,
  "totalPages": 10
}
```

#### Version Negotiation Through Content Types

HATEOAS naturally supports API versioning through content negotiation:

- Clients specify desired media type: `Accept: application/vnd.myapi.v2+json`
- Server returns appropriate hypermedia format and link structures
- Different versions can coexist with different link relations and structures
- Clients evolve independently by requesting specific versions

#### Error Handling with Hypermedia

Error responses should include hypermedia controls for recovery:

```json
{
  "error": {
    "code": "PAYMENT_FAILED",
    "message": "Payment processing failed",
    "details": "Insufficient funds"
  },
  "_links": {
    "retry": {
      "href": "/orders/12345/payment",
      "method": "POST"
    },
    "update-payment-method": {
      "href": "/customers/789/payment-methods",
      "method": "PUT"
    },
    "cancel": {
      "href": "/orders/12345",
      "method": "DELETE"
    },
    "help": {
      "href": "/docs/errors/payment-failed"
    }
  }
}
```

### Implementation Strategies

#### Server-Side Link Generation

Implement centralized link generation to ensure consistency:

```python
class LinkBuilder:
    def __init__(self, base_url):
        self.base_url = base_url
    
    def build_order_links(self, order, user):
        """Generate links based on order state and user permissions"""
        links = {
            'self': {
                'href': f'{self.base_url}/orders/{order.id}'
            },
            'customer': {
                'href': f'{self.base_url}/customers/{order.customer_id}'
            },
            'items': {
                'href': f'{self.base_url}/orders/{order.id}/items'
            }
        }
        
        # State-dependent links
        if order.status == 'pending':
            if self._can_pay(order, user):
                links['payment'] = {
                    'href': f'{self.base_url}/orders/{order.id}/payment',
                    'method': 'POST',
                    'title': 'Process Payment'
                }
            
            if self._can_cancel(order, user):
                links['cancel'] = {
                    'href': f'{self.base_url}/orders/{order.id}',
                    'method': 'DELETE',
                    'title': 'Cancel Order'
                }
            
            if self._can_modify(order, user):
                links['edit'] = {
                    'href': f'{self.base_url}/orders/{order.id}',
                    'method': 'PUT',
                    'title': 'Modify Order'
                }
        
        elif order.status == 'paid':
            links['shipment'] = {
                'href': f'{self.base_url}/orders/{order.id}/shipment'
            }
        
        elif order.status == 'shipped':
            links['tracking'] = {
                'href': f'{self.base_url}/orders/{order.id}/tracking'
            }
            
            if self._can_initiate_return(order, user):
                links['return'] = {
                    'href': f'{self.base_url}/orders/{order.id}/return',
                    'method': 'POST',
                    'title': 'Initiate Return'
                }
        
        return links
    
    def _can_pay(self, order, user):
        """[Inference] Check if user can process payment for this order"""
        return (user.id == order.customer_id and 
                order.total > 0 and
                not order.payment_attempted)
    
    def _can_cancel(self, order, user):
        """[Inference] Check if user can cancel this order"""
        return (user.id == order.customer_id or 
                user.has_role('admin'))
    
    def _can_modify(self, order, user):
        """[Inference] Check if user can modify this order"""
        return (user.id == order.customer_id and 
                not order.payment_attempted)
    
    def _can_initiate_return(self, order, user):
        """[Inference] Check if user can initiate return"""
        days_since_delivery = (datetime.now() - order.delivered_at).days
        return (user.id == order.customer_id and 
                days_since_delivery <= 30)
```

#### Client-Side Navigation

Clients follow links rather than constructing URLs:

```python
class HATEOASClient:
    def __init__(self, base_url, auth_token):
        self.base_url = base_url
        self.auth_token = auth_token
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {auth_token}',
            'Accept': 'application/hal+json'
        })
    
    def get_resource(self, url):
        """Fetch a resource and parse hypermedia controls"""
        response = self.session.get(url)
        response.raise_for_status()
        return response.json()
    
    def follow_link(self, resource, rel, method='GET', data=None):
        """Follow a link relation from a resource"""
        links = resource.get('_links', {})
        
        if rel not in links:
            raise ValueError(f'Link relation "{rel}" not found')
        
        link = links[rel]
        url = link['href']
        http_method = link.get('method', method)
        
        if http_method == 'GET':
            response = self.session.get(url)
        elif http_method == 'POST':
            response = self.session.post(url, json=data)
        elif http_method == 'PUT':
            response = self.session.put(url, json=data)
        elif http_method == 'DELETE':
            response = self.session.delete(url)
        else:
            raise ValueError(f'Unsupported HTTP method: {http_method}')
        
        response.raise_for_status()
        
        if response.content:
            return response.json()
        return None
    
    def can_perform_action(self, resource, rel):
        """Check if an action is available on a resource"""
        links = resource.get('_links', {})
        return rel in links
    
    def get_available_actions(self, resource):
        """Get all available link relations for a resource"""
        links = resource.get('_links', {})
        return list(links.keys())

# Usage example
client = HATEOASClient('https://api.example.com', 'auth_token_here')

# Start at API root
root = client.get_resource('https://api.example.com/')

# Navigate to orders collection
orders = client.follow_link(root, 'orders')

# Get specific order
order = client.follow_link(orders, 'item')  # Following first item link

# Check what actions are available
if client.can_perform_action(order, 'cancel'):
    print("Order can be cancelled")
    # Cancel the order
    client.follow_link(order, 'cancel', method='DELETE')

# Process payment if available
if client.can_perform_action(order, 'payment'):
    payment_data = {
        'method': 'credit_card',
        'card_token': 'tok_123456'
    }
    client.follow_link(order, 'payment', method='POST', data=payment_data)
```

#### Embedded Resources vs Separate Requests

Balance between including related resources and requiring separate requests:

**Embedding Advantages**:

- Reduces number of HTTP requests
- Improves performance for common access patterns
- Provides complete context in single response

**Separate Request Advantages**:

- Reduces response payload size
- Allows independent caching of resources
- Simplifies resource updates and consistency

[Inference] Strategy often involves providing links to related resources while embedding frequently accessed relationships, potentially controlled through query parameters like `?embed=customer,items`.

### Best Practices

#### Design Entry Points Carefully

The API root serves as the primary discovery mechanism:

```json
{
  "_links": {
    "self": {
      "href": "https://api.example.com/"
    },
    "orders": {
      "href": "https://api.example.com/orders",
      "title": "Order Management"
    },
    "customers": {
      "href": "https://api.example.com/customers",
      "title": "Customer Management"
    },
    "products": {
      "href": "https://api.example.com/products",
      "title": "Product Catalog"
    },
    "docs": {
      "href": "https://api.example.com/docs",
      "title": "API Documentation"
    },
    "profile": {
      "href": "https://api.example.com/profile",
      "title": "Current User Profile"
    }
  },
  "version": "2.0",
  "title": "E-Commerce API"
}
```

#### Use Descriptive Link Relations

Provide meaningful relation types that convey semantic intent:

- Use standard IANA relations when appropriate
- Create custom relations with clear, domain-specific names
- Document custom relations thoroughly
- Consider using URI-based custom relations for uniqueness

#### Include Link Metadata

Enrich links with additional information:

```json
{
  "_links": {
    "payment": {
      "href": "/orders/12345/payment",
      "method": "POST",
      "title": "Process Payment",
      "type": "application/json",
      "deprecation": null,
      "templated": false,
      "hreflang": "en"
    }
  }
}
```

#### Implement Link Templating

Use URI templates (RFC 6570) for parameterized links:

```json
{
  "_links": {
    "search": {
      "href": "/orders{?status,customer,dateFrom,dateTo}",
      "templated": true,
      "title": "Search Orders"
    }
  }
}
```

Clients expand templates with actual parameters:

```
/orders?status=pending&customer=789&dateFrom=2025-01-01
```

#### Maintain Link Stability

URLs should remain stable across API versions when possible:

- Use resource identifiers rather than implementation details in URLs
- Avoid exposing database IDs if they might change
- Consider using UUIDs or business keys for resource identification
- Version URLs only when absolutely necessary

#### Handle Deprecation Gracefully

When deprecating links or changing URL structures:

```json
{
  "_links": {
    "old-endpoint": {
      "href": "/api/v1/orders",
      "deprecation": "https://api.example.com/docs/deprecations/old-endpoint",
      "title": "Legacy Order Endpoint (Deprecated)"
    },
    "orders": {
      "href": "/api/v2/orders",
      "title": "Order Management"
    }
  }
}
```

#### Optimize for Common Workflows

Design link structures that support typical client workflows efficiently:

- Include links for next logical actions
- Embed frequently accessed related resources
- Provide shortcuts for common navigation paths
- Consider workflow-specific link relations

### Common Patterns and Variations

#### Progressive Disclosure

Reveal complexity gradually based on client sophistication:

**Basic Response**:

```json
{
  "id": 12345,
  "status": "pending",
  "_links": {
    "self": {"href": "/orders/12345"}
  }
}
```

**Detailed Response** (with `?detail=full`):

```json
{
  "id": 12345,
  "status": "pending",
  "total": 99.99,
  "currency": "USD",
  "createdAt": "2025-12-25T10:00:00Z",
  "_links": {
    "self": {"href": "/orders/12345"},
    "customer": {"href": "/customers/789"},
    "items": {"href": "/orders/12345/items"},
    "payment": {"href": "/orders/12345/payment"},
    "cancel": {"href": "/orders/12345"}
  },
  "_embedded": {
    "items": [...]
  }
}
```

#### Bulk Operations

Provide links for batch processing:

```json
{
  "items": [...],
  "_links": {
    "self": {"href": "/orders"},
    "bulk-cancel": {
      "href": "/orders/bulk/cancel",
      "method": "POST",
      "title": "Cancel Multiple Orders"
    },
    "bulk-export": {
      "href": "/orders/export{?format}",
      "templated": true,
      "title": "Export Orders"
    }
  }
}
```

#### Conditional Links

Include links only when preconditions are met:

```python
def build_order_links(order):
    links = {'self': {'href': f'/orders/{order.id}'}}
    
    # Only include refund link if order is paid and within refund window
    if (order.status == 'paid' and 
        (datetime.now() - order.paid_at).days <= 30):
        links['refund'] = {
            'href': f'/orders/{order.id}/refund',
            'method': 'POST'
        }
    
    # Only include ship link if order is paid and not already shipped
    if order.status == 'paid' and order.shipment_id is None:
        links['ship'] = {
            'href': f'/orders/{order.id}/shipment',
            'method': 'POST'
        }
    
    return links
```

#### Composite Resources

Represent complex resource hierarchies with nested hypermedia:

```json
{
  "id": 12345,
  "status": "processing",
  "_embedded": {
    "items": [
      {
        "id": 1,
        "quantity": 2,
        "_links": {
          "self": {"href": "/orders/12345/items/1"},
          "product": {"href": "/products/456"}
        },
        "_embedded": {
          "product": {
            "id": 456,
            "name": "Widget",
            "_links": {
              "self": {"href": "/products/456"}
            }
          }
        }
      }
    ]
  }
}
```

### Anti-Patterns to Avoid

#### Client URL Construction

**Wrong**:

```python
# Client constructs URLs manually
order_url = f'https://api.example.com/orders/{order_id}'
payment_url = f'https://api.example.com/orders/{order_id}/payment'
```

**Correct**:

```python
# Client follows links from responses
order = client.get_resource(order_url_from_previous_response)
payment = client.follow_link(order, 'payment')
```

#### Static Link Relations Without Context

**Wrong**:

```json
{
  "_links": {
    "cancel": {"href": "/orders/12345"}
  }
}
```

This appears even when cancellation is not allowed.

**Correct**:

```python
# Only include links when actions are valid
if order.can_be_cancelled():
    links['cancel'] = {'href': f'/orders/{order.id}'}
```

#### Over-Embedding Resources

**Wrong**:

```json
{
  "order": {...},
  "_embedded": {
    "customer": {...},  // Full customer details
    "items": [
      {
        "item": {...},
        "_embedded": {
          "product": {...},  // Full product details
          "reviews": [...]    // All product reviews
        }
      }
    ],
    "shipment": {...},
    "invoices": [...],
    "payment_history": [...]
  }
}
```

This creates massive payloads with rarely used data.

**Correct**:

```json
{
  "order": {...},
  "_links": {
    "customer": {"href": "/customers/789"},
    "items": {"href": "/orders/12345/items"}
  },
  "_embedded": {
    "items": [...]  // Only frequently accessed items
  }
}
```

#### Inconsistent Link Relations

Using different relation names for the same semantic relationship across resources creates confusion and increases client complexity.

#### Exposing Implementation Details in URLs

**Wrong**:

```
/api/orders_table/row/12345
/api/database/orders/12345
```

**Correct**:

```
/api/orders/12345
```

#### Missing Self Links

Every resource representation should include a `self` link providing its canonical URL for caching and reference purposes.

### Relationship to Other Patterns

**API Gateway Pattern**: Gateways can aggregate multiple backend services and present unified HATEOAS interfaces, translating between internal service protocols and external hypermedia representations.

**Backend for Frontend (BFF)**: Different BFF implementations can provide customized hypermedia structures optimized for specific client types (mobile vs web) while maintaining HATEOAS principles.

**CQRS Pattern**: Command and query endpoints can both implement HATEOAS, with command responses including links to query the resulting state and query responses including links to available commands.

**Event Sourcing**: Event representations can include hypermedia links to related events, aggregate roots, and projection queries, enabling navigation through event streams.

**Saga Pattern**: Distributed transaction steps can be represented as linked resources, with each step providing links to compensation actions and next steps in the saga.

**Circuit Breaker Pattern**: When a circuit is open, responses can include hypermedia controls indicating alternative resources or retry timing information.

### Testing Strategies

#### Link Presence Testing

Verify links appear appropriately based on state:

```python
def test_pending_order_includes_payment_link():
    order = create_order(status='pending')
    response = client.get(f'/orders/{order.id}')
    
    assert 'payment' in response['_links']
    assert response['_links']['payment']['method'] == 'POST'

def test_shipped_order_excludes_cancel_link():
    order = create_order(status='shipped')
    response = client.get(f'/orders/{order.id}')
    
    assert 'cancel' not in response['_links']

def test_unauthorized_user_excludes_admin_links():
    order = create_order()
    response = client.get(f'/orders/{order.id}', auth=regular_user_token)
    
    assert 'delete' not in response['_links']
```

#### Link Validity Testing

Ensure links are functional:

```python
def test_all_links_return_valid_responses():
    order = create_order()
    response = client.get(f'/orders/{order.id}')
    
    for rel, link in response['_links'].items():
        if rel == 'self':
            continue
        
        # Follow each link and verify it returns valid response
        link_response = client.request(
            method=link.get('method', 'GET'),
            url=link['href']
        )
        
        assert link_response.status_code in [200, 201, 204]
```

#### Workflow Testing

Test complete workflows using only hypermedia navigation:

```python
def test_complete_order_workflow():
    # Start at API root
    root = client.get('/')
    
    # Navigate to orders
    orders_url = root['_links']['orders']['href']
    orders = client.get(orders_url)
    
    # Create new order
    create_url = orders['_links']['create']['href']
    order = client.post(create_url, json=order_data)
    
    # Add items
    items_url = order['_links']['items']['href']
    client.post(items_url, json=item_data)
    
    # Process payment
    payment_url = order['_links']['payment']['href']
    payment = client.post(payment_url, json=payment_data)
    
    # Verify order status changed
    updated_order = client.get(order['_links']['self']['href'])
    assert updated_order['status'] == 'paid'
    
    # Verify payment link no longer present
    assert 'payment' not in updated_order['_links']
```

#### Schema Validation

Validate hypermedia format compliance:

```python
import jsonschema

hal_schema = {
    "type": "object",
    "required": ["_links"],
    "properties": {
        "_links": {
            "type": "object",
            "required": ["self"],
            "patternProperties": {
                "^[a-zA-Z0-9-_]+$": {
                    "type": "object",
                    "required": ["href"],
                    "properties": {
                        "href": {"type": "string"},
                        "method": {"type": "string"},
                        "title": {"type": "string"}
                    }
                }
            }
        }
    }
}

def test_response_follows_hal_format():
    order = create_order()
    response = client.get(f'/orders/{order.id}')
    
    jsonschema.validate(instance=response, schema=hal_schema)
```

**Key Points:**

- HATEOAS makes REST APIs self-descriptive through hypermedia controls embedded in responses
- Clients discover available actions dynamically rather than relying on hardcoded URL knowledge
- Link relations describe semantic relationships between resources
- Multiple hypermedia formats exist (HAL, JSON:API, Siren, Collection+JSON) with different trade-offs
- Links should reflect current resource state, user permissions, and business rules
- Implementation requires centralized link generation and state-aware filtering
- Clients navigate using links rather than constructing URLs manually
- Proper implementation enables loose coupling and independent evolution of client and server

**Example:**

[Note: This example demonstrates a complete e-commerce order system with HATEOAS implementation]

```python
from flask import Flask, jsonify, request, url_for
from functools import wraps
from datetime import datetime, timedelta
import jwt

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-here'

# Mock database
orders_db = {}
customers_db = {}
products_db = {
    456: {'id': 456, 'name': 'Widget', 'price': 49.99, 'stock': 100},
    457: {'id': 457, 'name': 'Gadget', 'price': 29.99, 'stock': 50}
}


def generate_token(user_id, role='customer'):
    """Generate JWT token for authentication"""
    payload = {
        'user_id': user_id,
        'role': role,
        'exp': datetime.utcnow() + timedelta(hours=24)
    }
    return jwt.encode(payload, app.config['SECRET_KEY'], algorithm='HS256')


def token_required(f):
    """Decorator for protected endpoints"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')
        
        if not token:
            return jsonify({'error': 'Token is missing'}), 401
        
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256'])
            request.user = data
        except:
            return jsonify({'error': 'Token is invalid'}), 401
        
        return f(*args, **kwargs)
    
    return decorated


class LinkBuilder:
    """Centralized link generation with state awareness"""
    
    @staticmethod
    def build_base_links():
        """Links available from API root"""
        return {
            'self': {
                'href': url_for('api_root', _external=True)
            },
            'orders': {
                'href': url_for('list_orders', _external=True),
                'title': 'Order Management'
            },
            'products': {
                'href': url_for('list_products', _external=True),
                'title': 'Product Catalog'
            }
        }
    
    @staticmethod
    def build_order_links(order, user):
        """Generate state-aware links for an order"""
        links = {
            'self': {
                'href': url_for('get_order', order_id=order['id'], _external=True)
            },
            'customer': {
                'href': url_for('get_customer', customer_id=order['customer_id'], _external=True)
            },
            'items': {
                'href': url_for('list_order_items', order_id=order['id'], _external=True)
            }
        }
        
        # State-dependent links
        if order['status'] == 'pending':
            # Can add items to pending orders
            links['add-item'] = {
                'href': url_for('add_order_item', order_id=order['id'], _external=True),
                'method': 'POST',
                'title': 'Add Item to Order',
                'type': 'application/json'
            }
            
            # Can process payment for pending orders with items
            if order.get('items') and len(order['items']) > 0:
                links['payment'] = {
                    'href': url_for('process_payment', order_id=order['id'], _external=True),
                    'method': 'POST',
                    'title': 'Process Payment'
                }
            
            # Owner or admin can cancel pending orders
            if user['user_id'] == order['customer_id'] or user['role'] == 'admin':
                links['cancel'] = {
                    'href': url_for('cancel_order', order_id=order['id'], _external=True),
                    'method': 'DELETE',
                    'title': 'Cancel Order'
                }
            
            # Owner can modify pending orders
            if user['user_id'] == order['customer_id']:
                links['edit'] = {
                    'href': url_for('update_order', order_id=order['id'], _external=True),
                    'method': 'PUT',
                    'title': 'Modify Order'
                }
        
        elif order['status'] == 'paid':
            # Admin can mark as shipped
            if user['role'] == 'admin':
                links['ship'] = {
                    'href': url_for('ship_order', order_id=order['id'], _external=True),
                    'method': 'POST',
                    'title': 'Mark as Shipped'
                }
            
            # Can view payment details
            links['payment-details'] = {
                'href': url_for('get_payment_details', order_id=order['id'], _external=True)
            }
        
        elif order['status'] == 'shipped':
            # View tracking information
            links['tracking'] = {
                'href': url_for('get_tracking', order_id=order['id'], _external=True)
            }
            
            # Owner can initiate return within 30 days
            if user['user_id'] == order['customer_id']:
                shipped_date = datetime.fromisoformat(order['shipped_at'])
                days_since_shipment = (datetime.utcnow() - shipped_date).days
                
                if days_since_shipment <= 30:
                    links['return'] = {
                        'href': url_for('initiate_return', order_id=order['id'], _external=True),
                        'method': 'POST',
                        'title': 'Initiate Return'
                    }
        
        elif order['status'] == 'delivered':
            # Owner can leave review
            if user['user_id'] == order['customer_id'] and not order.get('reviewed'):
                links['review'] = {
                    'href': url_for('create_review', order_id=order['id'], _external=True),
                    'method': 'POST',
                    'title': 'Write Review'
                }
        
        return links
    
    @staticmethod
    def build_orders_collection_links(page, per_page, total):
        """Generate pagination links for orders collection"""
        links = {
            'self': {
                'href': url_for('list_orders', page=page, per_page=per_page, _external=True)
            }
        }
        
        # First page link
        if page > 1:
            links['first'] = {
                'href': url_for('list_orders', page=1, per_page=per_page, _external=True)
            }
        
        # Previous page link
        if page > 1:
            links['prev'] = {
                'href': url_for('list_orders', page=page-1, per_page=per_page, _external=True)
            }
        
        # Next page link
        total_pages = (total + per_page - 1) // per_page
        if page < total_pages:
            links['next'] = {
                'href': url_for('list_orders', page=page+1, per_page=per_page, _external=True)
            }
        
        # Last page link
        if page < total_pages:
            links['last'] = {
                'href': url_for('list_orders', page=total_pages, per_page=per_page, _external=True)
            }
        
        # Create new order
        links['create'] = {
            'href': url_for('create_order', _external=True),
            'method': 'POST',
            'title': 'Create New Order'
        }
        
        # Search template
        links['search'] = {
            'href': url_for('list_orders', _external=True) + '{?status,customer,dateFrom,dateTo}',
            'templated': True,
            'title': 'Search Orders'
        }
        
        return links
    
    @staticmethod
    def build_product_links(product):
        """Generate links for product"""
        return {
            'self': {
                'href': url_for('get_product', product_id=product['id'], _external=True)
            }
        }


@app.route('/', methods=['GET'])
def api_root():
    """API entry point with discovery links"""
    return jsonify({
        'version': '2.0',
        'title': 'E-Commerce API',
        '_links': LinkBuilder.build_base_links()
    })


@app.route('/orders', methods=['GET'])
@token_required
def list_orders():
    """List orders with pagination and hypermedia controls"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    # Filter user's orders only (unless admin)
    user_orders = [
        order for order in orders_db.values()
        if request.user['role'] == 'admin' or order['customer_id'] == request.user['user_id']
    ]
    
    # Pagination
    start = (page - 1) * per_page
    end = start + per_page
    paginated_orders = user_orders[start:end]
    
    # Build embedded order representations
    embedded_orders = []
    for order in paginated_orders:
        order_rep = {
            'id': order['id'],
            'status': order['status'],
            'total': order['total'],
            'created_at': order['created_at'],
            '_links': LinkBuilder.build_order_links(order, request.user)
        }
        embedded_orders.append(order_rep)
    
    return jsonify({
        '_embedded': {
            'orders': embedded_orders
        },
        '_links': LinkBuilder.build_orders_collection_links(
            page, per_page, len(user_orders)
        ),
        'page': page,
        'per_page': per_page,
        'total': len(user_orders)
    })


@app.route('/orders', methods=['POST'])
@token_required
def create_order():
    """Create a new order"""
    order_id = len(orders_db) + 1
    
    order = {
        'id': order_id,
        'customer_id': request.user['user_id'],
        'status': 'pending',
        'items': [],
        'total': 0.0,
        'created_at': datetime.utcnow().isoformat() + 'Z',
        'updated_at': datetime.utcnow().isoformat() + 'Z'
    }
    
    orders_db[order_id] = order
    
    response = {
        'id': order['id'],
        'status': order['status'],
        'total': order['total'],
        'created_at': order['created_at'],
        '_links': LinkBuilder.build_order_links(order, request.user)
    }
    
    return jsonify(response), 201


@app.route('/orders/<int:order_id>', methods=['GET'])
@token_required
def get_order(order_id):
    """Get specific order with full details and hypermedia controls"""
    if order_id not in orders_db:
        return jsonify({'error': 'Order not found'}), 404
    
    order = orders_db[order_id]
    
    # Authorization check
    if request.user['role'] != 'admin' and order['customer_id'] != request.user['user_id']:
        return jsonify({'error': 'Unauthorized'}), 403
    
    # Build embedded items
    embedded_items = []
    for item in order.get('items', []):
        product = products_db.get(item['product_id'])
        item_rep = {
            'id': item['id'],
            'quantity': item['quantity'],
            'price': item['price'],
            '_links': {
                'self': {
                    'href': url_for('get_order_item', order_id=order_id, 
                                    item_id=item['id'], _external=True)
                },
                'product': {
                    'href': url_for('get_product', product_id=item['product_id'], 
                                    _external=True)
                }
            }
        }
        
        # Optionally embed product details
        if product:
            item_rep['_embedded'] = {
                'product': {
                    'id': product['id'],
                    'name': product['name'],
                    '_links': LinkBuilder.build_product_links(product)
                }
            }
        
        embedded_items.append(item_rep)
    
    response = {
        'id': order['id'],
        'status': order['status'],
        'total': order['total'],
        'created_at': order['created_at'],
        'updated_at': order['updated_at'],
        '_links': LinkBuilder.build_order_links(order, request.user),
        '_embedded': {
            'items': embedded_items
        }
    }
    
    return jsonify(response)


@app.route('/orders/<int:order_id>/items', methods=['POST'])
@token_required
def add_order_item(order_id):
    """Add item to order (only if order is pending)"""
    if order_id not in orders_db:
        return jsonify({'error': 'Order not found'}), 404
    
    order = orders_db[order_id]
    
    # Authorization
    if order['customer_id'] != request.user['user_id']:
        return jsonify({'error': 'Unauthorized'}), 403
    
    # State check
    if order['status'] != 'pending':
        return jsonify({
            'error': 'Cannot add items to non-pending order',
            '_links': {
                'order': {
                    'href': url_for('get_order', order_id=order_id, _external=True)
                }
            }
        }), 400
    
    data = request.get_json()
    product_id = data.get('product_id')
    quantity = data.get('quantity', 1)
    
    if product_id not in products_db:
        return jsonify({'error': 'Product not found'}), 404
    
    product = products_db[product_id]
    
    item = {
        'id': len(order.get('items', [])) + 1,
        'product_id': product_id,
        'quantity': quantity,
        'price': product['price'] * quantity
    }
    
    if 'items' not in order:
        order['items'] = []
    
    order['items'].append(item)
    order['total'] = sum(item['price'] for item in order['items'])
    order['updated_at'] = datetime.utcnow().isoformat() + 'Z'
    
    return jsonify({
        'item': item,
        '_links': {
            'order': {
                'href': url_for('get_order', order_id=order_id, _external=True)
            },
            'continue-shopping': {
                'href': url_for('list_products', _external=True)
            },
            'payment': {
                'href': url_for('process_payment', order_id=order_id, _external=True),
                'method': 'POST',
                'title': 'Proceed to Payment'
            }
        }
    }), 201


@app.route('/orders/<int:order_id>/payment', methods=['POST'])
@token_required
def process_payment(order_id):
    """Process payment for order"""
    if order_id not in orders_db:
        return jsonify({'error': 'Order not found'}), 404
    
    order = orders_db[order_id]
    
    # Authorization
    if order['customer_id'] != request.user['user_id']:
        return jsonify({'error': 'Unauthorized'}), 403
    
    # State check
    if order['status'] != 'pending':
        return jsonify({
            'error': 'Order is not in pending status',
            '_links': {
                'order': {
                    'href': url_for('get_order', order_id=order_id, _external=True)
                }
            }
        }), 400
    
    if not order.get('items') or len(order['items']) == 0:
        return jsonify({
            'error': 'Cannot process payment for empty order',
            '_links': {
                'add-items': {
                    'href': url_for('list_products', _external=True)
                }
            }
        }), 400
    
    # Simulate payment processing
    order['status'] = 'paid'
    order['paid_at'] = datetime.utcnow().isoformat() + 'Z'
    order['updated_at'] = datetime.utcnow().isoformat() + 'Z'
    
    return jsonify({
        'message': 'Payment processed successfully',
        'order': {
            'id': order['id'],
            'status': order['status'],
            'total': order['total']
        },
        '_links': {
            'order': {
                'href': url_for('get_order', order_id=order_id, _external=True)
            },
            'receipt': {
                'href': url_for('get_payment_details', order_id=order_id, _external=True)
            }
        }
    })


@app.route('/orders/<int:order_id>', methods=['DELETE'])
@token_required
def cancel_order(order_id):
    """Cancel an order (only if pending)"""
    if order_id not in orders_db:
        return jsonify({'error': 'Order not found'}), 404
    
    order = orders_db[order_id]
    
    # Authorization
    if request.user['role'] != 'admin' and order['customer_id'] != request.user['user_id']:
        return jsonify({'error': 'Unauthorized'}), 403
    
    # State check
    if order['status'] != 'pending':
        return jsonify({
            'error': 'Only pending orders can be cancelled',
            '_links': {
                'order': {
                    'href': url_for('get_order', order_id=order_id, _external=True)
                }
            }
        }), 400
    
    order['status'] = 'cancelled'
    order['cancelled_at'] = datetime.utcnow().isoformat() + 'Z'
    order['updated_at'] = datetime.utcnow().isoformat() + 'Z'
    
    return jsonify({
        'message': 'Order cancelled successfully',
        '_links': {
            'orders': {
                'href': url_for('list_orders', _external=True)
            },
            'create-new-order': {
                'href': url_for('create_order', _external=True),
                'method': 'POST'
            }
        }
    }), 200


@app.route('/orders/<int:order_id>/ship', methods=['POST'])
@token_required
def ship_order(order_id):
    """Mark order as shipped (admin only)"""
    if request.user['role'] != 'admin':
        return jsonify({'error': 'Admin access required'}), 403
    
    if order_id not in orders_db:
        return jsonify({'error': 'Order not found'}), 404
    
    order = orders_db[order_id]
    
    if order['status'] != 'paid':
        return jsonify({'error': 'Only paid orders can be shipped'}), 400
    
    order['status'] = 'shipped'
    order['shipped_at'] = datetime.utcnow().isoformat() + 'Z'
    order['updated_at'] = datetime.utcnow().isoformat() + 'Z'
    
    return jsonify({
        'message': 'Order marked as shipped',
        '_links': {
            'order': {
                'href': url_for('get_order', order_id=order_id, _external=True)
            },
            'tracking': {
                'href': url_for('get_tracking', order_id=order_id, _external=True)
            }
        }
    })


@app.route('/products', methods=['GET'])
def list_products():
    """List available products"""
    products = []
    for product in products_db.values():
        products.append({
            'id': product['id'],
            'name': product['name'],
            'price': product['price'],
            'stock': product['stock'],
            '_links': LinkBuilder.build_product_links(product)
        })
    
    return jsonify({
        '_embedded': {
            'products': products
        },
        '_links': {
            'self': {
                'href': url_for('list_products', _external=True)
            }
        }
    })


@app.route('/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Get specific product details"""
    if product_id not in products_db:
        return jsonify({'error': 'Product not found'}), 404
    
    product = products_db[product_id]
    
    return jsonify({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'stock': product['stock'],
        '_links': LinkBuilder.build_product_links(product)
    })


# Stub endpoints referenced in links

@app.route('/orders/<int:order_id>/items/<int:item_id>', methods=['GET'])
@token_required
def get_order_item(order_id, item_id):
    return jsonify({'message': 'Item details endpoint'})


@app.route('/orders/<int:order_id>/items', methods=['GET'])
@token_required
def list_order_items(order_id):
    return jsonify({'message': 'Order items list endpoint'})


@app.route('/orders/<int:order_id>/payment-details', methods=['GET'])
@token_required
def get_payment_details(order_id):
    return jsonify({'message': 'Payment details endpoint'})


@app.route('/orders/<int:order_id>/tracking', methods=['GET'])
@token_required
def get_tracking(order_id):
    return jsonify({'message': 'Tracking information endpoint'})


@app.route('/orders/<int:order_id>/return', methods=['POST'])
@token_required
def initiate_return(order_id):
    return jsonify({'message': 'Return initiation endpoint'})


@app.route('/orders/<int:order_id>/review', methods=['POST'])
@token_required
def create_review(order_id):
    return jsonify({'message': 'Review creation endpoint'})


@app.route('/customers/<int:customer_id>', methods=['GET'])
@token_required
def get_customer(customer_id):
    return jsonify({'message': 'Customer details endpoint'})


@app.route('/orders/<int:order_id>', methods=['PUT'])
@token_required
def update_order(order_id):
    return jsonify({'message': 'Order update endpoint'})


if __name__ == '__main__':
    # Create sample data
    token = generate_token(user_id=789, role='customer')
    print(f'Sample token: {token}')
    
    app.run(debug=True, port=5000)
````

**Output:**

Example API root response:

```json
{
  "version": "2.0",
  "title": "E-Commerce API",
  "_links": {
    "self": {
      "href": "http://localhost:5000/"
    },
    "orders": {
      "href": "http://localhost:5000/orders",
      "title": "Order Management"
    },
    "products": {
      "href": "http://localhost:5000/products",
      "title": "Product Catalog"
    }
  }
}
````

Example pending order response with full hypermedia controls:

```json
{
  "id": 1,
  "status": "pending",
  "total": 99.98,
  "created_at": "2025-12-25T10:00:00Z",
  "updated_at": "2025-12-25T10:05:00Z",
  "_links": {
    "self": {
      "href": "http://localhost:5000/orders/1"
    },
    "customer": {
      "href": "http://localhost:5000/customers/789"
    },
    "items": {
      "href": "http://localhost:5000/orders/1/items"
    },
    "add-item": {
      "href": "http://localhost:5000/orders/1/items",
      "method": "POST",
      "title": "Add Item to Order",
      "type": "application/json"
    },
    "payment": {
      "href": "http://localhost:5000/orders/1/payment",
      "method": "POST",
      "title": "Process Payment"
    },
    "cancel": {
      "href": "http://localhost:5000/orders/1",
      "method": "DELETE",
      "title": "Cancel Order"
    },
    "edit": {
      "href": "http://localhost:5000/orders/1",
      "method": "PUT",
      "title": "Modify Order"
    }
  },
  "_embedded": {
    "items": [
      {
        "id": 1,
        "quantity": 2,
        "price": 99.98,
        "_links": {
          "self": {
            "href": "http://localhost:5000/orders/1/items/1"
          },
          "product": {
            "href": "http://localhost:5000/products/456"
          }
        },
        "_embedded": {
          "product": {
            "id": 456,
            "name": "Widget",
            "_links": {
              "self": {
                "href": "http://localhost:5000/products/456"
              }
            }
          }
        }
      }
    ]
  }
}
```

Example paid order response showing state transition:

```json
{
  "id": 1,
  "status": "paid",
  "total": 99.98,
  "created_at": "2025-12-25T10:00:00Z",
  "updated_at": "2025-12-25T10:10:00Z",
  "_links": {
    "self": {
      "href": "http://localhost:5000/orders/1"
    },
    "customer": {
      "href": "http://localhost:5000/customers/789"
    },
    "items": {
      "href": "http://localhost:5000/orders/1/items"
    },
    "payment-details": {
      "href": "http://localhost:5000/orders/1/payment-details"
    }
  },
  "_embedded": {
    "items": [...]
  }
}
```

Note how the payment, cancel, and edit links are no longer present after payment, while a new payment-details link appears. [Inference] This demonstrates how the server controls available state transitions through hypermedia.

**Conclusion:**

HATEOAS represents a fundamental shift in API design philosophy, moving from documentation-driven integration to discoverable, self-describing interfaces. By embedding navigation and action controls directly in responses, HATEOAS enables loose coupling between clients and servers, facilitating independent evolution and reducing the brittleness common in traditional REST APIs.

The pattern's value extends beyond technical benefits. HATEOAS enforces clearer thinking about resource state machines and valid state transitions. By making these transitions explicit through hypermedia controls, developers create more maintainable systems with well-defined boundaries between components. The server becomes authoritative about what operations are currently valid, eliminating the need for clients to replicate complex business logic.

However, HATEOAS requires careful implementation. Link generation must be centralized, state-aware, and permission-conscious. Clients must be designed to follow links rather than construct URLs. Testing must verify not just functional correctness but also the presence and absence of links based on state and authorization. The additional complexity is justified when building systems that need to evolve independently or support multiple client implementations.

Modern web architecture increasingly recognizes HATEOAS as essential for building robust, evolvable APIs. While the pattern originated with REST, its principles of discoverability and self-description apply broadly. As systems grow more distributed and client diversity increases, HATEOAS provides the foundation for maintainable, loosely-coupled architectures that can adapt to changing requirements without breaking existing integrations.

**Next Steps:**

- Choose a hypermedia format (HAL, JSON:API, Siren) appropriate for your use case
- Implement centralized link generation with state and permission awareness
- Design your resource state machine and identify valid state transitions
- Add hypermedia controls to existing API responses incrementally
- Update client implementations to follow links instead of constructing URLs
- Write tests verifying link presence based on state and authorization
- Document custom link relations and their semantic meaning
- Monitor client usage patterns to optimize embedded resources vs separate requests
- Consider implementing API versioning through content negotiation
- Train development teams on HATEOAS principles and client implementation patterns

---

## Versioning Strategies

Versioning strategies are systematic approaches to managing changes in software systems, APIs, databases, and other components over time. They provide mechanisms for introducing new features, fixing bugs, and making breaking changes while maintaining compatibility with existing clients and ensuring smooth transitions between versions. Effective versioning is crucial for maintaining system stability, enabling concurrent development, and providing clear communication about changes to users and dependent systems.

### Purpose and Motivation

As software systems evolve, they must accommodate new requirements, fix defects, and improve performance without breaking existing functionality for current users. Versioning provides a structured way to manage this evolution by:

- **Enabling backward compatibility**: Allowing old clients to continue functioning while new features are added
- **Facilitating gradual migration**: Giving users time to adapt to changes rather than forcing immediate updates
- **Communicating change magnitude**: Indicating whether changes are minor improvements or major breaking changes
- **Supporting parallel development**: Allowing multiple versions to coexist during transition periods
- **Reducing deployment risk**: Enabling rollback capabilities when issues are discovered
- **Managing dependencies**: Helping consumers understand which versions are compatible with their systems

Without proper versioning strategies, systems become brittle, upgrades become risky, and the cost of maintenance escalates dramatically.

### Semantic Versioning (SemVer)

Semantic Versioning is a widely-adopted versioning scheme that uses a three-part version number: MAJOR.MINOR.PATCH (e.g., 2.4.1). Each component has specific meaning regarding the nature of changes:

#### Version Number Components

**MAJOR version** (the first number): Incremented when making incompatible API changes that break backward compatibility. This signals to consumers that they may need to modify their code to work with the new version.

**MINOR version** (the second number): Incremented when adding functionality in a backward-compatible manner. New features are introduced, but existing functionality remains unchanged and compatible.

**PATCH version** (the third number): Incremented when making backward-compatible bug fixes that don't add new features or break existing functionality.

#### Pre-release and Build Metadata

Semantic Versioning also supports pre-release versions and build metadata:

**Pre-release versions** are denoted by appending a hyphen and identifiers (e.g., 1.0.0-alpha, 1.0.0-beta.1, 1.0.0-rc.2). These versions have lower precedence than the associated normal version and indicate the release is unstable.

**Build metadata** is denoted by appending a plus sign and identifiers (e.g., 1.0.0+20230615, 1.0.0+sha.5114f85). Build metadata is ignored when determining version precedence.

#### Version Precedence Rules

Version precedence is determined by comparing major, minor, and patch numbers from left to right:

- 2.0.0 > 1.9.9
- 1.1.0 > 1.0.9
- 1.0.1 > 1.0.0
- 1.0.0 > 1.0.0-rc.1
- 1.0.0-rc.2 > 1.0.0-rc.1
- 1.0.0-beta > 1.0.0-alpha

```python
from dataclasses import dataclass
from typing import Optional, List
import re

@dataclass
class SemanticVersion:
    """
    Represents a semantic version number.
    """
    major: int
    minor: int
    patch: int
    prerelease: Optional[str] = None
    build_metadata: Optional[str] = None
    
    @classmethod
    def parse(cls, version_string: str) -> 'SemanticVersion':
        """
        Parse a semantic version string.
        
        Example: "1.2.3-beta.1+build.123"
        """
        pattern = r'^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z\-\.]+))?(?:\+([0-9A-Za-z\-\.]+))?$'
        match = re.match(pattern, version_string)
        
        if not match:
            raise ValueError(f"Invalid semantic version: {version_string}")
        
        major, minor, patch, prerelease, build = match.groups()
        
        return cls(
            major=int(major),
            minor=int(minor),
            patch=int(patch),
            prerelease=prerelease,
            build_metadata=build
        )
    
    def __str__(self) -> str:
        """Return string representation of version."""
        version = f"{self.major}.{self.minor}.{self.patch}"
        if self.prerelease:
            version += f"-{self.prerelease}"
        if self.build_metadata:
            version += f"+{self.build_metadata}"
        return version
    
    def __lt__(self, other: 'SemanticVersion') -> bool:
        """Compare versions for ordering."""
        # Compare major, minor, patch
        if (self.major, self.minor, self.patch) != (other.major, other.minor, other.patch):
            return (self.major, self.minor, self.patch) < (other.major, other.minor, other.patch)
        
        # Pre-release versions have lower precedence than normal versions
        if self.prerelease is None and other.prerelease is not None:
            return False
        if self.prerelease is not None and other.prerelease is None:
            return True
        
        # Compare pre-release identifiers
        if self.prerelease and other.prerelease:
            return self._compare_prerelease(self.prerelease, other.prerelease)
        
        return False
    
    def _compare_prerelease(self, pre1: str, pre2: str) -> bool:
        """Compare pre-release version identifiers."""
        parts1 = pre1.split('.')
        parts2 = pre2.split('.')
        
        for p1, p2 in zip(parts1, parts2):
            # Try to compare as integers, fall back to string comparison
            try:
                n1, n2 = int(p1), int(p2)
                if n1 != n2:
                    return n1 < n2
            except ValueError:
                if p1 != p2:
                    return p1 < p2
        
        return len(parts1) < len(parts2)
    
    def bump_major(self) -> 'SemanticVersion':
        """Create new version with incremented major number."""
        return SemanticVersion(self.major + 1, 0, 0)
    
    def bump_minor(self) -> 'SemanticVersion':
        """Create new version with incremented minor number."""
        return SemanticVersion(self.major, self.minor + 1, 0)
    
    def bump_patch(self) -> 'SemanticVersion':
        """Create new version with incremented patch number."""
        return SemanticVersion(self.major, self.minor, self.patch + 1)
    
    def is_compatible_with(self, other: 'SemanticVersion') -> bool:
        """
        Check if this version is backward compatible with another version.
        [Inference: Based on SemVer rules, versions are considered compatible
        if they share the same major version and this version is newer.]
        """
        if self.major == 0 or other.major == 0:
            # Major version 0 is for initial development; anything may change
            return self.major == other.major and self.minor == other.minor
        
        return self.major == other.major and self >= other
```

### API Versioning Strategies

API versioning is critical for web services and APIs that external clients depend on. Different strategies offer trade-offs between flexibility, simplicity, and maintainability.

#### URI Path Versioning

Version information is included directly in the URL path (e.g., `/api/v1/users`, `/api/v2/users`). This is the most visible and explicit versioning approach.

**Advantages:**

- Extremely visible and obvious which version is being used
- Easy to route requests to different implementations
- Simple to test different versions
- Clear separation of version-specific code
- Works well with caching and API gateways

**Disadvantages:**

- URLs change between versions
- Creates multiple endpoints for the same resource
- Can lead to code duplication if not carefully managed
- May require updating documentation and client code

```python
from flask import Flask, jsonify, request
from typing import Dict, Any

app = Flask(__name__)

# Version 1 implementation
@app.route('/api/v1/users/<int:user_id>', methods=['GET'])
def get_user_v1(user_id: int) -> Dict[str, Any]:
    """
    Version 1: Returns basic user information.
    """
    user = {
        'id': user_id,
        'name': 'John Doe',
        'email': 'john@example.com'
    }
    return jsonify(user)

# Version 2 implementation with additional fields
@app.route('/api/v2/users/<int:user_id>', methods=['GET'])
def get_user_v2(user_id: int) -> Dict[str, Any]:
    """
    Version 2: Returns enhanced user information with additional fields.
    """
    user = {
        'id': user_id,
        'full_name': 'John Doe',  # Changed field name
        'email': 'john@example.com',
        'phone': '+1-555-0123',  # New field
        'created_at': '2023-01-15T10:30:00Z',  # New field
        'profile': {  # New nested structure
            'bio': 'Software developer',
            'avatar_url': 'https://example.com/avatars/johndoe.jpg'
        }
    }
    return jsonify(user)

# Version 3 with breaking changes
@app.route('/api/v3/users/<int:user_id>', methods=['GET'])
def get_user_v3(user_id: int) -> Dict[str, Any]:
    """
    Version 3: Complete restructuring with new response format.
    """
    response = {
        'data': {
            'type': 'user',
            'id': str(user_id),
            'attributes': {
                'full_name': 'John Doe',
                'email': 'john@example.com',
                'phone': '+1-555-0123'
            },
            'relationships': {
                'profile': {
                    'data': {'type': 'profile', 'id': '1'}
                }
            }
        },
        'included': [{
            'type': 'profile',
            'id': '1',
            'attributes': {
                'bio': 'Software developer',
                'avatar_url': 'https://example.com/avatars/johndoe.jpg'
            }
        }]
    }
    return jsonify(response)
```

#### Header-Based Versioning

Version information is passed in HTTP headers (e.g., `Accept: application/vnd.myapi.v2+json` or custom headers like `API-Version: 2`).

**Advantages:**

- URLs remain clean and version-independent
- Aligns with REST principles and content negotiation
- Doesn't pollute URI space
- Can specify different versions for different resources in single request [Inference: This is theoretically possible but rarely implemented in practice]

**Disadvantages:**

- Less visible than URL versioning
- Harder to test in browsers without extensions
- May be overlooked by developers
- Requires more sophisticated routing logic
- Caching becomes more complex

```python
from flask import Flask, request, jsonify
from functools import wraps
from typing import Callable, Dict, Any

app = Flask(__name__)

def versioned(version_handlers: Dict[str, Callable]) -> Callable:
    """
    Decorator for header-based API versioning.
    
    Args:
        version_handlers: Dictionary mapping version strings to handler functions
    """
    def decorator(f: Callable) -> Callable:
        @wraps(f)
        def wrapper(*args, **kwargs):
            # Check for version in custom header
            api_version = request.headers.get('API-Version', '1')
            
            # Check Accept header for content negotiation
            accept_header = request.headers.get('Accept', '')
            if 'vnd.myapi.v' in accept_header:
                # Extract version from Accept header
                import re
                match = re.search(r'vnd\.myapi\.v(\d+)', accept_header)
                if match:
                    api_version = match.group(1)
            
            # Get appropriate handler for version
            handler = version_handlers.get(api_version)
            if not handler:
                return jsonify({
                    'error': f'Unsupported API version: {api_version}',
                    'supported_versions': list(version_handlers.keys())
                }), 400
            
            return handler(*args, **kwargs)
        return wrapper
    return decorator

# Define version-specific handlers
def handle_user_v1(user_id: int) -> Dict[str, Any]:
    """Version 1 handler."""
    return jsonify({
        'id': user_id,
        'name': 'John Doe',
        'email': 'john@example.com'
    })

def handle_user_v2(user_id: int) -> Dict[str, Any]:
    """Version 2 handler with enhanced data."""
    return jsonify({
        'id': user_id,
        'full_name': 'John Doe',
        'email': 'john@example.com',
        'phone': '+1-555-0123',
        'created_at': '2023-01-15T10:30:00Z'
    })

# Apply versioned decorator
@app.route('/api/users/<int:user_id>', methods=['GET'])
@versioned({
    '1': handle_user_v1,
    '2': handle_user_v2
})
def get_user(user_id: int):
    """User endpoint with header-based versioning."""
    pass  # Handler is called by decorator
```

#### Query Parameter Versioning

Version is specified as a query parameter (e.g., `/api/users?version=2` or `/api/users?v=2`).

**Advantages:**

- Simple to implement
- Easy to test and debug
- Doesn't require header manipulation
- Works well with browser-based testing

**Disadvantages:**

- Clutters URLs with version parameters
- Can be easily omitted or modified
- Not considered RESTful by purists
- May interfere with caching strategies
- Version becomes part of resource identifier

```python
from flask import Flask, request, jsonify
from typing import Dict, Any, Optional

app = Flask(__name__)

@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id: int) -> Dict[str, Any]:
    """
    User endpoint with query parameter versioning.
    """
    # Get version from query parameter, default to latest
    version = request.args.get('version', '2')
    
    if version == '1':
        return jsonify({
            'id': user_id,
            'name': 'John Doe',
            'email': 'john@example.com'
        })
    elif version == '2':
        return jsonify({
            'id': user_id,
            'full_name': 'John Doe',
            'email': 'john@example.com',
            'phone': '+1-555-0123',
            'created_at': '2023-01-15T10:30:00Z'
        })
    else:
        return jsonify({
            'error': f'Unsupported version: {version}',
            'supported_versions': ['1', '2']
        }), 400
```

#### Content Negotiation

Clients specify desired version through standard HTTP content negotiation using the Accept header with media type parameters.

**Advantages:**

- Follows HTTP standards and REST principles
- Leverages existing content negotiation mechanisms
- Clean URLs without version information
- Aligns with RESTful API design best practices

**Disadvantages:**

- Complex to implement correctly
- Not intuitive for developers unfamiliar with content negotiation
- Difficult to test without proper HTTP clients
- May conflict with actual content type negotiation

```python
from flask import Flask, request, jsonify, make_response
from typing import Dict, Any, Tuple

app = Flask(__name__)

def parse_accept_header(accept_header: str) -> Tuple[str, int]:
    """
    Parse Accept header to extract version.
    
    Examples:
        - application/vnd.myapi+json; version=1
        - application/vnd.myapi.v2+json
    """
    # Default values
    content_type = 'application/json'
    version = 1
    
    if 'vnd.myapi' in accept_header:
        # Extract version from media type parameter
        if 'version=' in accept_header:
            import re
            match = re.search(r'version=(\d+)', accept_header)
            if match:
                version = int(match.group(1))
        # Extract version from media type structure
        elif '.v' in accept_header:
            import re
            match = re.search(r'\.v(\d+)', accept_header)
            if match:
                version = int(match.group(1))
    
    return content_type, version

@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id: int):
    """
    User endpoint with content negotiation versioning.
    """
    accept_header = request.headers.get('Accept', 'application/json')
    content_type, version = parse_accept_header(accept_header)
    
    # Generate response based on version
    if version == 1:
        data = {
            'id': user_id,
            'name': 'John Doe',
            'email': 'john@example.com'
        }
        response_content_type = 'application/vnd.myapi.v1+json'
    elif version == 2:
        data = {
            'id': user_id,
            'full_name': 'John Doe',
            'email': 'john@example.com',
            'phone': '+1-555-0123',
            'created_at': '2023-01-15T10:30:00Z'
        }
        response_content_type = 'application/vnd.myapi.v2+json'
    else:
        return jsonify({
            'error': f'Unsupported version: {version}'
        }), 406  # Not Acceptable
    
    response = make_response(jsonify(data))
    response.headers['Content-Type'] = response_content_type
    return response
```

### Database Schema Versioning

Database schema evolution presents unique challenges because data must be migrated alongside schema changes, and downtime should be minimized.

#### Migration-Based Versioning

Migration-based versioning uses sequential migration scripts that transform the database from one version to the next. Each migration has an "up" function (applies changes) and a "down" function (reverts changes).

```python
from dataclasses import dataclass
from typing import List, Callable, Optional
from datetime import datetime
import sqlite3

@dataclass
class Migration:
    """
    Represents a database migration.
    """
    version: int
    description: str
    up: Callable[[sqlite3.Connection], None]
    down: Callable[[sqlite3.Connection], None]
    applied_at: Optional[datetime] = None

class MigrationManager:
    """
    Manages database schema migrations.
    """
    def __init__(self, db_path: str):
        self.db_path = db_path
        self.migrations: List[Migration] = []
        self._ensure_migrations_table()
    
    def _ensure_migrations_table(self):
        """Create migrations tracking table if it doesn't exist."""
        conn = sqlite3.connect(self.db_path)
        try:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS schema_migrations (
                    version INTEGER PRIMARY KEY,
                    description TEXT NOT NULL,
                    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            conn.commit()
        finally:
            conn.close()
    
    def register_migration(self, migration: Migration):
        """Register a new migration."""
        self.migrations.append(migration)
        self.migrations.sort(key=lambda m: m.version)
    
    def get_current_version(self) -> int:
        """Get current database schema version."""
        conn = sqlite3.connect(self.db_path)
        try:
            cursor = conn.execute(
                "SELECT MAX(version) FROM schema_migrations"
            )
            result = cursor.fetchone()
            return result[0] if result[0] is not None else 0
        finally:
            conn.close()
    
    def migrate_to(self, target_version: Optional[int] = None):
        """
        Migrate database to target version.
        If target_version is None, migrate to latest.
        """
        current = self.get_current_version()
        target = target_version if target_version is not None else max(
            (m.version for m in self.migrations), default=0
        )
        
        if current == target:
            print(f"Database already at version {current}")
            return
        
        if target > current:
            self._migrate_up(current, target)
        else:
            self._migrate_down(current, target)
    
    def _migrate_up(self, current: int, target: int):
        """Apply forward migrations."""
        conn = sqlite3.connect(self.db_path)
        try:
            for migration in self.migrations:
                if current < migration.version <= target:
                    print(f"Applying migration {migration.version}: {migration.description}")
                    
                    # Execute migration
                    migration.up(conn)
                    
                    # Record migration
                    conn.execute(
                        "INSERT INTO schema_migrations (version, description) VALUES (?, ?)",
                        (migration.version, migration.description)
                    )
                    conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"Migration failed: {e}")
            raise
        finally:
            conn.close()
    
    def _migrate_down(self, current: int, target: int):
        """Apply reverse migrations."""
        conn = sqlite3.connect(self.db_path)
        try:
            for migration in reversed(self.migrations):
                if target < migration.version <= current:
                    print(f"Reverting migration {migration.version}: {migration.description}")
                    
                    # Execute rollback
                    migration.down(conn)
                    
                    # Remove migration record
                    conn.execute(
                        "DELETE FROM schema_migrations WHERE version = ?",
                        (migration.version,)
                    )
                    conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"Rollback failed: {e}")
            raise
        finally:
            conn.close()

# Example usage
def create_migration_manager() -> MigrationManager:
    """Create and configure migration manager with example migrations."""
    manager = MigrationManager('app.db')
    
    # Migration 1: Create users table
    def migration_1_up(conn: sqlite3.Connection):
        conn.execute("""
            CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT UNIQUE NOT NULL
            )
        """)
    
    def migration_1_down(conn: sqlite3.Connection):
        conn.execute("DROP TABLE users")
    
    manager.register_migration(Migration(
        version=1,
        description="Create users table",
        up=migration_1_up,
        down=migration_1_down
    ))
    
    # Migration 2: Add phone column
    def migration_2_up(conn: sqlite3.Connection):
        conn.execute("ALTER TABLE users ADD COLUMN phone TEXT")
    
    def migration_2_down(conn: sqlite3.Connection):
        # SQLite doesn't support DROP COLUMN directly
        # Would need to recreate table without column
        conn.execute("""
            CREATE TABLE users_backup AS SELECT id, name, email FROM users
        """)
        conn.execute("DROP TABLE users")
        conn.execute("ALTER TABLE users_backup RENAME TO users")
    
    manager.register_migration(Migration(
        version=2,
        description="Add phone column to users",
        up=migration_2_up,
        down=migration_2_down
    ))
    
    # Migration 3: Create posts table
    def migration_3_up(conn: sqlite3.Connection):
        conn.execute("""
            CREATE TABLE posts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                content TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        """)
    
    def migration_3_down(conn: sqlite3.Connection):
        conn.execute("DROP TABLE posts")
    
    manager.register_migration(Migration(
        version=3,
        description="Create posts table",
        up=migration_3_up,
        down=migration_3_down
    ))
    
    return manager
```

#### Expand-Contract Pattern

The expand-contract pattern (also known as parallel change) enables zero-downtime schema changes by following a three-phase approach:

**Expand phase**: Add new schema elements (columns, tables) alongside existing ones. Both old and new schemas coexist. The application writes to both old and new structures.

**Migrate phase**: Gradually migrate data from old to new schema. This can happen in background jobs without affecting application availability.

**Contract phase**: Remove old schema elements once all data is migrated and all application instances use the new schema.

```python
from typing import Optional
import sqlite3
from datetime import datetime

class ExpandContractMigration:
    """
    Example of expand-contract pattern for renaming a column.
    
    Goal: Rename 'name' column to 'full_name' in users table.
    """
    def __init__(self, db_path: str):
        self.db_path = db_path
    
    def expand(self):
        """
        Phase 1: Add new column alongside existing one.
        """
        conn = sqlite3.connect(self.db_path)
        try:
            print("EXPAND: Adding full_name column")
            conn.execute("ALTER TABLE users ADD COLUMN full_name TEXT")
            
            # Create trigger to keep columns in sync
            conn.execute("""
                CREATE TRIGGER sync_name_to_full_name
                AFTER INSERT ON users
                BEGIN
                    UPDATE users 
                    SET full_name = NEW.name 
                    WHERE id = NEW.id AND full_name IS NULL;
                END
            """)
            
            conn.execute("""
                CREATE TRIGGER sync_full_name_to_name
                AFTER UPDATE OF full_name ON users
                BEGIN
                    UPDATE users 
                    SET name = NEW.full_name 
                    WHERE id = NEW.id;
                END
            """)
            
            conn.commit()
            print("EXPAND: Complete - both columns now exist")
        finally:
            conn.close()
    
    def migrate_data(self, batch_size: int = 1000):
        """
        Phase 2: Copy data from old column to new column.
        """
        conn = sqlite3.connect(self.db_path)
        try:
            print("MIGRATE: Copying data from name to full_name")
            
            # Get total count
            cursor = conn.execute(
                "SELECT COUNT(*) FROM users WHERE full_name IS NULL"
            )
            total = cursor.fetchone()[0]
            
            print(f"MIGRATE: {total} rows to migrate")
            
            # Migrate in batches
            migrated = 0
            while migrated < total:
                conn.execute("""
                    UPDATE users
                    SET full_name = name
                    WHERE id IN (
                        SELECT id FROM users 
                        WHERE full_name IS NULL 
                        LIMIT ?
                    )
                """, (batch_size,))
                
                conn.commit()
                migrated += batch_size
                print(f"MIGRATE: {min(migrated, total)}/{total} rows migrated")
            
            print("MIGRATE: Complete - all data copied")
        finally:
            conn.close()
    
    def contract(self):
        """
        Phase 3: Remove old column and triggers.
        """
        conn = sqlite3.connect(self.db_path)
        try:
            print("CONTRACT: Removing old name column and triggers")
            
            # Drop triggers
            conn.execute("DROP TRIGGER IF EXISTS sync_name_to_full_name")
            conn.execute("DROP TRIGGER IF EXISTS sync_full_name_to_name")
            
            # SQLite doesn't support DROP COLUMN directly in older versions
            # Create new table without old column
            conn.execute("""
                CREATE TABLE users_new (
                    id INTEGER PRIMARY KEY,
                    full_name TEXT NOT NULL,
                    email TEXT UNIQUE NOT NULL,
                    phone TEXT
                )
            """)
            
            # Copy data
            conn.execute("""
                INSERT INTO users_new (id, full_name, email, phone)
                SELECT id, full_name, email, phone FROM users
            """)
            
            # Replace old table
            conn.execute("DROP TABLE users")
            conn.execute("ALTER TABLE users_new RENAME TO users")
            
            conn.commit()
            print("CONTRACT: Complete - old column removed")
        finally:
            conn.close()
```

#### Backward-Compatible Schema Changes

Some schema changes can be made in a backward-compatible way, allowing gradual migration without the expand-contract pattern:

- Adding new nullable columns
- Adding new tables
- Adding new indexes
- Creating new views
- Adding columns with default values

```python
class BackwardCompatibleChanges:
    """
    Examples of backward-compatible schema changes.
    """
    @staticmethod
    def add_nullable_column(conn: sqlite3.Connection):
        """Add a new nullable column - always backward compatible."""
        conn.execute("ALTER TABLE users ADD COLUMN last_login TIMESTAMP")
        # Existing queries work unchanged; new code can use the column
    
    @staticmethod
    def add_column_with_default(conn: sqlite3.Connection):
        """Add column with default value - backward compatible."""
        conn.execute("""
            ALTER TABLE users 
            ADD COLUMN is_active INTEGER DEFAULT 1
        """)
        # Existing rows automatically get default value
    
    @staticmethod
    def add_index(conn: sqlite3.Connection):
        """Add index - improves performance without breaking compatibility."""
        conn.execute("""
            CREATE INDEX idx_users_email ON users(email)
        """)
        # Queries work the same, just faster
    
    @staticmethod
    def create_view(conn: sqlite3.Connection):
        """Create view - adds new access pattern without changing tables."""
        conn.execute("""
            CREATE VIEW active_users AS
            SELECT * FROM users WHERE is_active = 1
        """)
        # New code can use view; existing code unaffected
```

### Microservices Versioning

In microservices architectures, versioning becomes more complex because multiple independent services must coordinate their evolution while maintaining system-wide compatibility.

#### Service Contract Versioning

Each microservice exposes a versioned contract (API) that other services depend on. Changes to these contracts must be managed carefully to avoid breaking dependent services.

```python
from flask import Flask, jsonify, request
from typing import Dict, Any, List
from dataclasses import dataclass, asdict
from enum import Enum


class ServiceVersion(Enum):
    """Supported service versions."""
    V1 = "v1"
    V2 = "v2"


@dataclass
class UserV1:
    """Version 1 user model."""
    id: int
    name: str
    email: str


@dataclass
class UserV2:
    """Version 2 user model with enhanced fields."""
    id: int
    full_name: str
    email: str
    phone: str
    metadata: Dict[str, Any]
    
    @classmethod
    def from_v1(cls, user_v1: UserV1) -> 'UserV2':
        """Convert V1 user to V2 format."""
        return cls(
            id=user_v1.id,
            full_name=user_v1.name,
            email=user_v1.email,
            phone="",  # Default empty for old data
            metadata={}
        )


class UserService:
    """
    User service with versioned API.
    """
    
    def __init__(self):
        # Internal storage uses latest version
        self._users: Dict[int, UserV2] = {
            1: UserV2(
                id=1,
                full_name="John Doe",
                email="john@example.com",
                phone="+1-555-0123",
                metadata={"created": "2023-01-01"}
            )
        }
    
    def get_user_v1(self, user_id: int) -> UserV1:
        """
        V1 API: Returns user in V1 format.
        [Inference: Converting from internal V2 format to V1 for backward compatibility]
        """
        user_v2 = self._users.get(user_id)
        if not user_v2:
            raise ValueError(f"User {user_id} not found")
        
        # Convert V2 to V1
        return UserV1(
            id=user_v2.id,
            name=user_v2.full_name,
            email=user_v2.email
        )
    
    def get_user_v2(self, user_id: int) -> UserV2:
        """
        V2 API: Returns user in V2 format.
        """
        user = self._users.get(user_id)
        if not user:
            raise ValueError(f"User {user_id} not found")
        return user
    
    def create_user_v1(self, name: str, email: str) -> UserV1:
        """
        V1 API: Create user using V1 format.
        [Inference: Internally converting to V2 format for storage]
        """
        user_id = max(self._users.keys(), default=0) + 1
        
        # Store internally as V2
        user_v2 = UserV2(
            id=user_id,
            full_name=name,
            email=email,
            phone="",
            metadata={"created_via": "v1_api"}
        )
        self._users[user_id] = user_v2
        
        # Return as V1
        return UserV1(id=user_id, name=name, email=email)
    
    def create_user_v2(
        self,
        full_name: str,
        email: str,
        phone: str,
        metadata: Dict[str, Any]
    ) -> UserV2:
        """
        V2 API: Create user using V2 format.
        """
        user_id = max(self._users.keys(), default=0) + 1
        
        user = UserV2(
            id=user_id,
            full_name=full_name,
            email=email,
            phone=phone,
            metadata=metadata
        )
        self._users[user_id] = user
        return user


# Flask application with versioned endpoints
app = Flask(__name__)
service = UserService()


@app.route('/api/v1/users/<int:user_id>', methods=['GET'])
def get_user_v1_endpoint(user_id: int):
    """V1 endpoint."""
    try:
        user = service.get_user_v1(user_id)
        return jsonify(asdict(user))
    except ValueError as e:
        return jsonify({'error': str(e)}), 404


@app.route('/api/v2/users/<int:user_id>', methods=['GET'])
def get_user_v2_endpoint(user_id: int):
    """V2 endpoint."""
    try:
        user = service.get_user_v2(user_id)
        return jsonify(asdict(user))
    except ValueError as e:
        return jsonify({'error': str(e)}), 404


@app.route('/api/v1/users', methods=['POST'])
def create_user_v1_endpoint():
    """V1 create endpoint."""
    data = request.json
    user = service.create_user_v1(data['name'], data['email'])
    return jsonify(asdict(user)), 201


@app.route('/api/v2/users', methods=['POST'])
def create_user_v2_endpoint():
    """V2 create endpoint."""
    data = request.json
    user = service.create_user_v2(
        data['full_name'],
        data['email'],
        data['phone'],
        data.get('metadata', {})
    )
    return jsonify(asdict(user)), 201


if __name__ == '__main__':
    app.run(debug=True, port=5000)
````

#### API Gateway Version Routing

An API gateway can handle version routing, allowing backend services to evolve independently while presenting a consistent versioned interface to clients.

```python
from typing import Dict, Callable, Any
from flask import Flask, request, jsonify
import requests

class APIGateway:
    """
    API Gateway that routes requests to appropriate service versions.
    """
    def __init__(self):
        # Map service versions to backend URLs
        self.service_routes: Dict[str, Dict[str, str]] = {
            'user-service': {
                'v1': 'http://user-service-v1:8001',
                'v2': 'http://user-service-v2:8002'
            },
            'order-service': {
                'v1': 'http://order-service-v1:8003',
                'v2': 'http://order-service-v2:8004'
            }
        }
        
        # Version compatibility rules
        self.version_compatibility = {
            'user-service': {
                'v1': ['v1'],
                'v2': ['v1', 'v2']  # V2 can handle V1 requests
            }
        }
    
    def route_request(
        self,
        service_name: str,
        version: str,
        path: str,
        method: str,
        **kwargs
    ) -> Any:
        """
        Route request to appropriate service version.
        """
        # Get target service URL
        service_versions = self.service_routes.get(service_name, {})
        target_url = service_versions.get(version)
        
        if not target_url:
            # Try to find compatible version
            compatible_versions = self.version_compatibility.get(
                service_name, {}
            ).get(version, [])
            
            for compat_version in reversed(compatible_versions):
                if compat_version in service_versions:
                    target_url = service_versions[compat_version]
                    break
        
        if not target_url:
            raise ValueError(
                f"No compatible version found for {service_name} v{version}"
            )
        
        # Forward request
        url = f"{target_url}{path}"
        response = requests.request(method, url, **kwargs)
        
        return response.json(), response.status_code

app = Flask(__name__)
gateway = APIGateway()

@app.route('/api/<version>/<service>/<path:resource_path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
def gateway_route(version: str, service: str, resource_path: str):
    """
    Gateway endpoint that routes to versioned services.
    """
    try:
        data, status = gateway.route_request(
            service_name=f"{service}-service",
            version=version,
            path=f"/{resource_path}",
            method=request.method,
            json=request.json if request.is_json else None,
            headers=dict(request.headers)
        )
        return jsonify(data), status
    except ValueError as e:
        return jsonify({'error': str(e)}), 404
````

#### Service Mesh and Version Traffic Management

Service meshes like Istio enable sophisticated version management through traffic routing, allowing gradual rollout of new versions and A/B testing. [Inference: The following example demonstrates conceptual traffic management patterns, though actual implementation would require service mesh infrastructure]

```python
from dataclasses import dataclass
from typing import Dict, List, Optional
from enum import Enum
import random

class DeploymentStrategy(Enum):
    """Deployment strategy types."""
    BLUE_GREEN = "blue_green"
    CANARY = "canary"
    ROLLING = "rolling"

@dataclass
class ServiceVersion:
    """Represents a service version deployment."""
    version: str
    instances: List[str]  # Instance URLs
    weight: float = 1.0  # Traffic weight (0.0 - 1.0)
    health_check_passed: bool = True

class VersionTrafficManager:
    """
    Manages traffic distribution across service versions.
    """
    def __init__(self):
        self.versions: Dict[str, ServiceVersion] = {}
    
    def register_version(self, version: ServiceVersion):
        """Register a service version."""
        self.versions[version.version] = version
    
    def select_instance(self, strategy: str = "weighted") -> Optional[str]:
        """
        Select service instance based on traffic management strategy.
        
        [Inference: Implementation shows weighted random selection,
        actual production systems would use more sophisticated algorithms]
        """
        if strategy == "weighted":
            return self._weighted_random_selection()
        elif strategy == "round_robin":
            return self._round_robin_selection()
        else:
            return self._random_selection()
    
    def _weighted_random_selection(self) -> Optional[str]:
        """Select instance using weighted random selection."""
        # Filter healthy versions
        healthy_versions = [
            v for v in self.versions.values()
            if v.health_check_passed
        ]
        
        if not healthy_versions:
            return None
        
        # Calculate total weight
        total_weight = sum(v.weight for v in healthy_versions)
        
        # Random weighted selection
        rand = random.uniform(0, total_weight)
        cumulative = 0
        
        for version in healthy_versions:
            cumulative += version.weight
            if rand <= cumulative:
                return random.choice(version.instances)
        
        return random.choice(healthy_versions[0].instances)
    
    def _round_robin_selection(self) -> Optional[str]:
        """Select instance using round-robin."""
        # [Inference: Simplified implementation; production would track state]
        healthy_versions = [
            v for v in self.versions.values()
            if v.health_check_passed
        ]
        
        if not healthy_versions:
            return None
        
        all_instances = []
        for version in healthy_versions:
            all_instances.extend(version.instances)
        
        return random.choice(all_instances) if all_instances else None
    
    def _random_selection(self) -> Optional[str]:
        """Select instance randomly."""
        healthy_versions = [
            v for v in self.versions.values()
            if v.health_check_passed
        ]
        
        if not healthy_versions:
            return None
        
        version = random.choice(healthy_versions)
        return random.choice(version.instances)
    
    def implement_canary_release(
        self,
        stable_version: str,
        canary_version: str,
        canary_percentage: float
    ):
        """
        Implement canary release pattern.
        
        Args:
            stable_version: Current stable version
            canary_version: New canary version
            canary_percentage: Percentage of traffic to canary (0-100)
        """
        if stable_version in self.versions:
            self.versions[stable_version].weight = 1.0 - (canary_percentage / 100)
        
        if canary_version in self.versions:
            self.versions[canary_version].weight = canary_percentage / 100
        
        print(f"Canary release: {canary_percentage}% traffic to {canary_version}")
    
    def implement_blue_green(self, active_version: str):
        """
        Implement blue-green deployment.
        
        Args:
            active_version: Version to receive all traffic
        """
        for version in self.versions.values():
            version.weight = 1.0 if version.version == active_version else 0.0
        
        print(f"Blue-green: All traffic to {active_version}")

# Example usage
traffic_manager = VersionTrafficManager()

# Register versions
traffic_manager.register_version(ServiceVersion(
    version="v1.0",
    instances=["http://service-v1-1:8080", "http://service-v1-2:8080"],
    weight=0.9
))

traffic_manager.register_version(ServiceVersion(
    version="v1.1",
    instances=["http://service-v1.1-1:8080"],
    weight=0.1
))

# Gradually increase canary traffic
for percentage in [10, 25, 50, 75, 100]:
    traffic_manager.implement_canary_release("v1.0", "v1.1", percentage)
    # Monitor metrics, rollback if issues detected
```

### Library and Package Versioning

Libraries and packages require careful versioning because they're dependencies for other software, and version conflicts can cause significant problems.

#### Dependency Version Constraints

```python
from dataclasses import dataclass
from typing import List, Optional
from enum import Enum

class ConstraintOperator(Enum):
    """Version constraint operators."""
    EQUAL = "=="
    NOT_EQUAL = "!="
    GREATER = ">"
    GREATER_EQUAL = ">="
    LESS = "<"
    LESS_EQUAL = "<="
    COMPATIBLE = "~="  # Compatible release
    WILDCARD = "*"

@dataclass
class VersionConstraint:
    """
    Represents a version dependency constraint.
    """
    package_name: str
    operator: ConstraintOperator
    version: str
    
    def __str__(self) -> str:
        return f"{self.package_name}{self.operator.value}{self.version}"
    
    @classmethod
    def parse(cls, constraint_str: str) -> 'VersionConstraint':
        """
        Parse version constraint string.
        
        Examples:
            - "requests>=2.28.0"
            - "flask~=2.0"
            - "numpy==1.24.0"
        """
        import re
        
        pattern = r'([a-zA-Z0-9\-_]+)(==|!=|>=|<=|>|<|~=|\*)(.+)'
        match = re.match(pattern, constraint_str.replace(' ', ''))
        
        if not match:
            raise ValueError(f"Invalid constraint: {constraint_str}")
        
        package, op, version = match.groups()
        
        operator = ConstraintOperator(op)
        
        return cls(package_name=package, operator=operator, version=version)
    
    def is_satisfied_by(self, version: str) -> bool:
        """
        Check if a version satisfies this constraint.
        
        [Inference: Implements SemVer comparison rules for constraint checking]
        """
        from packaging import version as pkg_version
        
        constraint_version = pkg_version.parse(self.version)
        check_version = pkg_version.parse(version)
        
        if self.operator == ConstraintOperator.EQUAL:
            return check_version == constraint_version
        elif self.operator == ConstraintOperator.NOT_EQUAL:
            return check_version != constraint_version
        elif self.operator == ConstraintOperator.GREATER:
            return check_version > constraint_version
        elif self.operator == ConstraintOperator.GREATER_EQUAL:
            return check_version >= constraint_version
        elif self.operator == ConstraintOperator.LESS:
            return check_version < constraint_version
        elif self.operator == ConstraintOperator.LESS_EQUAL:
            return check_version <= constraint_version
        elif self.operator == ConstraintOperator.COMPATIBLE:
            # Compatible release: same major.minor, patch can be higher
            return (check_version.major == constraint_version.major and
                    check_version.minor == constraint_version.minor and
                    check_version >= constraint_version)
        
        return False

@dataclass
class PackageManifest:
    """
    Package manifest with version and dependencies.
    """
    name: str
    version: str
    dependencies: List[VersionConstraint]
    dev_dependencies: List[VersionConstraint]
    
    def check_compatibility(
        self,
        available_packages: dict
    ) -> tuple[bool, List[str]]:
        """
        Check if all dependencies can be satisfied.
        
        [Inference: Returns compatibility status and list of conflicts]
        """
        conflicts = []
        
        for dep in self.dependencies:
            available_version = available_packages.get(dep.package_name)
            
            if not available_version:
                conflicts.append(
                    f"{dep.package_name} required but not available"
                )
            elif not dep.is_satisfied_by(available_version):
                conflicts.append(
                    f"{dep.package_name} {available_version} doesn't satisfy {dep}"
                )
        
        return len(conflicts) == 0, conflicts
    
    @classmethod
    def from_requirements(
        cls,
        name: str,
        version: str,
        requirements: List[str]
    ) -> 'PackageManifest':
        """
        Create manifest from requirements list.
        """
        dependencies = []
        dev_dependencies = []
        
        for req in requirements:
            req = req.strip()
            if req and not req.startswith('#'):
                constraint = VersionConstraint.parse(req)
                dependencies.append(constraint)
        
        return cls(
            name=name,
            version=version,
            dependencies=dependencies,
            dev_dependencies=dev_dependencies
        )

# Example usage
manifest = PackageManifest.from_requirements(
    name="my-application",
    version="1.0.0",
    requirements=[
        "requests>=2.28.0",
        "flask~=2.0",
        "sqlalchemy>=1.4,<2.0",
        "pytest==7.2.0"
    ]
)

# Check compatibility with available packages
available = {
    "requests": "2.31.0",
    "flask": "2.0.3",
    "sqlalchemy": "1.4.46",
    "pytest": "7.2.0"
}

compatible, conflicts = manifest.check_compatibility(available)
print(f"Compatible: {compatible}")
if conflicts:
    print("Conflicts:")
    for conflict in conflicts:
        print(f"  - {conflict}")
```

### Deprecation and Sunset Policies

Properly deprecating old versions is as important as releasing new ones. A clear deprecation policy helps users plan migrations and prevents surprises.

```python
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Optional, List
from enum import Enum

class DeprecationStatus(Enum):
    """Status of deprecated versions."""
    ACTIVE = "active"
    DEPRECATED = "deprecated"
    SUNSET = "sunset"
    EOL = "end_of_life"

@dataclass
class VersionLifecycle:
    """
    Tracks version lifecycle and deprecation timeline.
    """
    version: str
    release_date: datetime
    deprecation_date: Optional[datetime] = None
    sunset_date: Optional[datetime] = None
    eol_date: Optional[datetime] = None
    status: DeprecationStatus = DeprecationStatus.ACTIVE
    migration_guide_url: Optional[str] = None
    
    def get_status(self, current_date: Optional[datetime] = None) -> DeprecationStatus:
        """
        Get current status of the version.
        """
        if current_date is None:
            current_date = datetime.now()
        
        if self.eol_date and current_date >= self.eol_date:
            return DeprecationStatus.EOL
        elif self.sunset_date and current_date >= self.sunset_date:
            return DeprecationStatus.SUNSET
        elif self.deprecation_date and current_date >= self.deprecation_date:
            return DeprecationStatus.DEPRECATED
        else:
            return DeprecationStatus.ACTIVE
    
    def days_until_eol(self, current_date: Optional[datetime] = None) -> Optional[int]:
        """
        Calculate days until end of life.
        """
        if current_date is None:
            current_date = datetime.now()
        
        if not self.eol_date:
            return None
        
        delta = self.eol_date - current_date
        return max(0, delta.days)
    
    def generate_deprecation_warning(self) -> str:
        """
        Generate deprecation warning message.
        """
        status = self.get_status()
        
        if status == DeprecationStatus.EOL:
            return (
                f"Version {self.version} has reached end of life and is no longer supported. "
                f"Please upgrade immediately."
            )
        elif status == DeprecationStatus.SUNSET:
            days = self.days_until_eol()
            return (
                f"Version {self.version} is in sunset phase and will reach end of life in {days} days. "
                f"New features and bug fixes are no longer provided. Please plan your migration."
            )
        elif status == DeprecationStatus.DEPRECATED:
            days = self.days_until_eol()
            return (
                f"Version {self.version} is deprecated and will reach end of life in {days} days. "
                f"Please migrate to a newer version."
            )
        
        return ""

class DeprecationManager:
    """
    Manages version deprecation lifecycle.
    """
    def __init__(
        self,
        deprecation_period_days: int = 180,
        sunset_period_days: int = 90
    ):
        self.deprecation_period_days = deprecation_period_days
        self.sunset_period_days = sunset_period_days
        self.versions: List[VersionLifecycle] = []
    
    def add_version(
        self,
        version: str,
        release_date: datetime,
        migration_guide_url: Optional[str] = None
    ):
        """
        Add a new version to tracking.
        """
        lifecycle = VersionLifecycle(
            version=version,
            release_date=release_date,
            migration_guide_url=migration_guide_url
        )
        self.versions.append(lifecycle)
    
    def deprecate_version(
        self,
        version: str,
        deprecation_date: Optional[datetime] = None
    ):
        """
        Mark a version as deprecated and set sunset/EOL dates.
        """
        if deprecation_date is None:
            deprecation_date = datetime.now()
        
        for v in self.versions:
            if v.version == version:
                v.deprecation_date = deprecation_date
                v.sunset_date = deprecation_date + timedelta(
                    days=self.deprecation_period_days
                )
                v.eol_date = v.sunset_date + timedelta(
                    days=self.sunset_period_days
                )
                v.status = DeprecationStatus.DEPRECATED
                break
    
    def get_active_versions(self) -> List[str]:
        """Get list of currently active versions."""
        return [
            v.version for v in self.versions
            if v.get_status() == DeprecationStatus.ACTIVE
        ]
    
    def get_deprecated_versions(self) -> List[VersionLifecycle]:
        """Get list of deprecated versions."""
        return [
            v for v in self.versions
            if v.get_status() in [
                DeprecationStatus.DEPRECATED,
                DeprecationStatus.SUNSET,
                DeprecationStatus.EOL
            ]
        ]
    
    def generate_deprecation_report(self) -> str:
        """
        Generate comprehensive deprecation status report.
        """
        report_lines = ["Version Deprecation Status Report", "=" * 50, ""]
        
        active = [v for v in self.versions if v.get_status() == DeprecationStatus.ACTIVE]
        deprecated = self.get_deprecated_versions()
        
        report_lines.append(f"Active Versions: {len(active)}")
        for v in active:
            report_lines.append(f"  - {v.version} (released {v.release_date.date()})")
        
        report_lines.append("")
        report_lines.append(f"Deprecated Versions: {len(deprecated)}")
        for v in deprecated:
            status = v.get_status()
            days_left = v.days_until_eol()
            
            status_str = status.value.upper()
            days_str = f"({days_left} days until EOL)" if days_left else "(EOL reached)"
            
            report_lines.append(f"  - {v.version} [{status_str}] {days_str}")
            if v.migration_guide_url:
                report_lines.append(f"    Migration guide: {v.migration_guide_url}")
        
        return "\n".join(report_lines)

# Example usage
manager = DeprecationManager(deprecation_period_days=180, sunset_period_days=90)

# Add versions
manager.add_version(
    "1.0.0",
    datetime(2022, 1, 1),
    migration_guide_url="https://docs.example.com/migration/v1-to-v2"
)
manager.add_version("2.0.0", datetime(2023, 6, 1))
manager.add_version("3.0.0", datetime(2024, 1, 1))

# Deprecate old version
manager.deprecate_version("1.0.0", datetime(2023, 6, 1))

# Generate report
print(manager.generate_deprecation_report())
```

### Version Negotiation and Feature Detection

Rather than hard-coding version numbers, systems can negotiate versions or detect available features dynamically.

```python
from dataclasses import dataclass
from typing import Set, Optional, Dict, Any
from enum import Enum

class Feature(Enum):
    """Available features across versions."""
    BASIC_AUTH = "basic_auth"
    OAUTH2 = "oauth2"
    PAGINATION = "pagination"
    FILTERING = "filtering"
    BULK_OPERATIONS = "bulk_operations"
    WEBSOCKETS = "websockets"
    GRAPHQL = "graphql"

@dataclass
class APICapabilities:
    """
    Describes API capabilities and features.
    """
    version: str
    features: Set[Feature]
    max_page_size: int = 100
    rate_limit: int = 1000
    supports_batch: bool = False
    
    def has_feature(self, feature: Feature) -> bool:
        """Check if feature is supported."""
        return feature in self.features
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for API response."""
        return {
            'version': self.version,
            'features': [f.value for f in self.features],
            'limits': {
                'max_page_size': self.max_page_size,
                'rate_limit': self.rate_limit
            },
            'supports_batch': self.supports_batch
        }

class VersionNegotiator:
    """
    Negotiates API version based on client requirements and server capabilities.
    """
    def __init__(self):
        self.available_versions: Dict[str, APICapabilities] = {}
    
    def register_version(self, capabilities: APICapabilities):
        """Register an available API version."""
        self.available_versions[capabilities.version] = capabilities
    
    def negotiate(
        self,
        requested_version: Optional[str] = None,
        required_features: Optional[Set[Feature]] = None
    ) -> Optional[APICapabilities]:
        """
        Negotiate best matching API version.
        
        [Inference: Selection algorithm prioritizes exact version match,
        then falls back to latest compatible version with required features]
        """
        # If specific version requested, try to provide it
        if requested_version and requested_version in self.available_versions:
            capabilities = self.available_versions[requested_version]
            
            # Check if it has required features
            if required_features:
                if not all(capabilities.has_feature(f) for f in required_features):
                    # Version doesn't have required features, fall through
                    pass
                else:
                    return capabilities
        
        # Find best match based on features
        if required_features:
            compatible_versions = [
                cap for cap in self.available_versions.values()
                if all(cap.has_feature(f) for f in required_features)
            ]
            
            if compatible_versions:
                # Return latest compatible version
                return max(compatible_versions, key=lambda c: c.version)
        
        # Return latest version if no specific requirements
        if self.available_versions:
            return max(self.available_versions.values(), key=lambda c: c.version)
        
        return None

# Example API with version negotiation
from flask import Flask, request, jsonify

app = Flask(__name__)
negotiator = VersionNegotiator()

# Register available versions
negotiator.register_version(APICapabilities(
    version="1.0",
    features={Feature.BASIC_AUTH, Feature.PAGINATION},
    max_page_size=50,
    rate_limit=500
))

negotiator.register_version(APICapabilities(
    version="2.0",
    features={
        Feature.BASIC_AUTH,
        Feature.OAUTH2,
        Feature.PAGINATION,
        Feature.FILTERING
    },
    max_page_size=100,
    rate_limit=1000
))

negotiator.register_version(APICapabilities(
    version="3.0",
    features={
        Feature.BASIC_AUTH,
        Feature.OAUTH2,
        Feature.PAGINATION,
        Feature.FILTERING,
        Feature.BULK_OPERATIONS,
        Feature.WEBSOCKETS
    },
    max_page_size=200,
    rate_limit=2000,
    supports_batch=True
))

@app.route('/api/capabilities', methods=['GET'])
def get_capabilities():
    """
    Return API capabilities (version discovery endpoint).
    """
    requested_version = request.args.get('version')
    
    if requested_version:
        capabilities = negotiator.available_versions.get(requested_version)
        if capabilities:
            return jsonify(capabilities.to_dict())
        return jsonify({'error': 'Version not found'}), 404
    
    # Return all available versions
    return jsonify({
        'versions': [
            cap.to_dict() 
            for cap in negotiator.available_versions.values()
        ]
    })

@app.route('/api/negotiate', methods=['POST'])
def negotiate_version():
    """
    Negotiate API version based on client requirements.
    """
    data = request.json
    requested_version = data.get('version')
    required_features_str = data.get('features', [])
    
    # Convert feature strings to enum
    required_features = set()
    for f_str in required_features_str:
        try:
            required_features.add(Feature(f_str))
        except ValueError:
            return jsonify({'error': f'Unknown feature: {f_str}'}), 400
    
    # Negotiate version
    capabilities = negotiator.negotiate(requested_version, required_features)
    
    if capabilities:
        return jsonify({
            'negotiated_version': capabilities.version,
            'capabilities': capabilities.to_dict()
        })
    
    return jsonify({
        'error': 'No compatible version found',
        'required_features': required_features_str
    }), 404
```

### **Key Points**

- Semantic Versioning provides clear communication about the nature of changes through MAJOR.MINOR.PATCH numbering
- URI path versioning offers maximum visibility but creates multiple endpoints; header-based versioning keeps URLs clean but is less obvious
- Database migrations must be carefully orchestrated, with expand-contract pattern enabling zero-downtime changes
- Microservices require coordinated versioning strategies with backward compatibility guarantees
- Deprecation policies should provide clear timelines and migration paths to prevent surprising users
- Version negotiation and feature detection enable flexible client-server communication without hard version dependencies
- All versioning strategies involve trade-offs between simplicity, flexibility, backward compatibility, and maintainability
- Comprehensive testing across versions is essential to ensure compatibility guarantees hold

### **Example**

Here's a complete example demonstrating multiple versioning strategies working together:

```
from flask import Flask, jsonify
from dataclasses import dataclass, asdict
from typing import Dict, Any, Optional, List
from datetime import datetime
import functools

# ============================================================================
# Domain Models (Internal representation uses latest version)
# ============================================================================

@dataclass
class Product:
    """Internal product model (latest version)."""
    id: int
    name: str
    description: str
    price: float
    currency: str
    stock_quantity: int
    created_at: datetime
    updated_at: datetime
    metadata: Dict[str, Any]


# ============================================================================
# Version-specific DTOs (Data Transfer Objects)
# ============================================================================

@dataclass
class ProductV1:
    """Version 1 product representation."""
    id: int
    name: str
    price: float

    @classmethod
    def from_product(cls, product: Product) -> "ProductV1":
        return cls(
            id=product.id,
            name=product.name,
            price=product.price,
        )


@dataclass
class ProductV2:
    """Version 2 product representation with additional fields."""
    id: int
    name: str
    description: str
    price: float
    currency: str
    stock_quantity: int

    @classmethod
    def from_product(cls, product: Product) -> "ProductV2":
        return cls(
            id=product.id,
            name=product.name,
            description=product.description,
            price=product.price,
            currency=product.currency,
            stock_quantity=product.stock_quantity,
        )


@dataclass
class ProductV3:
    """Version 3 product representation with full details."""
    id: int
    name: str
    description: str
    price: Dict[str, float]
    inventory: Dict[str, Any]
    timestamps: Dict[str, str]
    metadata: Dict[str, Any]

    @classmethod
    def from_product(cls, product: Product) -> "ProductV3":
        return cls(
            id=product.id,
            name=product.name,
            description=product.description,
            price={
                "amount": product.price,
                "currency": product.currency,
            },
            inventory={
                "quantity": product.stock_quantity,
                "available": product.stock_quantity > 0,
            },
            timestamps={
                "created": product.created_at.isoformat(),
                "updated": product.updated_at.isoformat(),
            },
            metadata=product.metadata,
        )


# ============================================================================
# Service Layer
# ============================================================================

class ProductService:
    """Business logic for product management."""

    def __init__(self):
        self._products: Dict[int, Product] = {
            1: Product(
                id=1,
                name="Laptop",
                description="High-performance laptop",
                price=999.99,
                currency="USD",
                stock_quantity=50,
                created_at=datetime(2023, 1, 1),
                updated_at=datetime(2024, 1, 1),
                metadata={
                    "category": "electronics",
                    "brand": "TechCorp",
                },
            )
        }

    def get_product(self, product_id: int) -> Optional[Product]:
        return self._products.get(product_id)

    def list_products(self) -> List[Product]:
        return list(self._products.values())


# ============================================================================
# Version Management
# ============================================================================

def versioned_route(supported_versions: List[str]):
    """Decorator for version-aware routes."""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            version = kwargs.pop("version", "v1")

            if version not in supported_versions:
                return jsonify({
                    "error": f"Unsupported version: {version}",
                    "supported_versions": supported_versions,
                }), 400

            kwargs["api_version"] = version
            return func(*args, **kwargs)

        return wrapper
    return decorator


# ============================================================================
# Flask Application
# ============================================================================

app = Flask(__name__)
product_service = ProductService()


@app.route("/api/<version>/products/<int:product_id>", methods=["GET"])
@versioned_route(["v1", "v2", "v3"])
def get_product(product_id: int, api_version: str):
    product = product_service.get_product(product_id)

    if not product:
        return jsonify({"error": "Product not found"}), 404

    if api_version == "v1":
        dto = ProductV1.from_product(product)
    elif api_version == "v2":
        dto = ProductV2.from_product(product)
    else:
        dto = ProductV3.from_product(product)

    response = jsonify(asdict(dto))
    response.headers["API-Version"] = api_version
    response.headers["X-Deprecated"] = "true" if api_version == "v1" else "false"
    return response


@app.route("/api/<version>/products", methods=["GET"])
@versioned_route(["v1", "v2", "v3"])
def list_products(api_version: str):
    products = product_service.list_products()

    if api_version == "v1":
        data = [asdict(ProductV1.from_product(p)) for p in products]
    elif api_version == "v2":
        data = [asdict(ProductV2.from_product(p)) for p in products]
    else:
        data = [asdict(ProductV3.from_product(p)) for p in products]

    if api_version == "v3":
        response_data = {
            "data": data,
            "meta": {
                "total": len(data),
                "version": api_version,
            },
        }
    else:
        response_data = data

    response = jsonify(response_data)
    response.headers["API-Version"] = api_version
    return response


@app.route("/api/version-info", methods=["GET"])
def version_info():
    return jsonify({
        "current_version": "v3",
        "supported_versions": {
            "v1": {
                "status": "deprecated",
                "sunset_date": "2025-06-01",
                "features": ["basic_product_info"],
                "migration_guide": "https://docs.example.com/migration/v1-to-v2",
            },
            "v2": {
                "status": "supported",
                "features": [
                    "extended_product_info",
                    "inventory_status",
                ],
                "migration_guide": "https://docs.example.com/migration/v2-to-v3",
            },
            "v3": {
                "status": "current",
                "features": [
                    "full_product_details",
                    "multi_currency",
                    "metadata",
                    "envelope_format",
                ],
            },
        },
    })


if __name__ == "__main__":
    app.run(debug=True, port=5000)

```

**Conclusion** Versioning strategies are fundamental to managing software evolution in a controlled, predictable manner. The choice of strategy depends on the specific context: APIs benefit from URI path or header-based versioning, databases require careful migration management, and microservices need coordinated versioning across multiple services. Effective versioning requires balancing multiple concerns: maintaining backward compatibility for existing users, enabling innovation and improvement, providing clear migration paths, and managing the operational complexity of supporting multiple versions simultaneously. No single strategy fits all scenarios, and many systems employ multiple versioning approaches for different components. The key to successful versioning is clear communication through semantic version numbers, comprehensive documentation of changes, well-defined deprecation policies with adequate transition periods, and automated testing to ensure compatibility promises are upheld across versions. 

**Next Steps** - Audit your current systems to identify components lacking clear versioning strategies - Adopt Semantic Versioning for libraries and packages if not already in use - Implement version discovery endpoints for your APIs to help clients understand available versions - Create migration guides for each major version change documenting breaking changes and upgrade paths - Establish deprecation policies defining how long old versions will be supported - Set up automated testing that validates backward compatibility claims across versions - Implement monitoring and analytics to track version adoption and identify when old versions can be retired - Consider implementing feature flags as a complement to versioning for gradual feature rollouts - Document your versioning strategy in team guidelines and ensure all developers understand the policies - Review and update versioning practices regularly based on lessons learned from version transitions

---

## Pagination Patterns

Pagination is a technique for dividing large datasets into discrete pages or chunks, allowing users to navigate through content incrementally rather than loading everything at once. This pattern is essential for managing memory, improving performance, and enhancing user experience when dealing with large collections of data.

### Why Pagination Matters

When applications need to display large datasets—whether from databases, APIs, or in-memory collections—loading everything simultaneously creates several problems:

- **Performance degradation**: Loading thousands or millions of records consumes excessive memory and processing time
- **Network overhead**: Transferring large payloads increases bandwidth usage and response times
- **Poor user experience**: Users face long wait times and overwhelming amounts of information
- **Resource exhaustion**: Servers and databases struggle under the load of processing massive queries

Pagination addresses these issues by fetching and displaying data in manageable portions, typically ranging from 10 to 100 items per page depending on the use case.

### Core Pagination Strategies

#### Offset-Based Pagination

Offset-based pagination uses a limit (page size) and offset (starting position) to retrieve specific data slices. This is the most common and straightforward approach.

**Mechanism**: The client specifies how many items to skip (offset) and how many to retrieve (limit).

**Key Points**:

- Simple to implement with SQL `LIMIT` and `OFFSET` clauses
- Works well with random access (jumping to any page)
- Supports traditional page numbers familiar to users
- Performance degrades with large offsets as the database must scan and skip records
- Inconsistent results when data changes between requests (items may appear twice or be skipped)

**Example**:

```sql
-- Page 1: offset 0, limit 10
SELECT * FROM products ORDER BY id LIMIT 10 OFFSET 0;

-- Page 2: offset 10, limit 10
SELECT * FROM products ORDER BY id LIMIT 10 OFFSET 10;

-- Page 100: offset 990, limit 10
SELECT * FROM products ORDER BY id LIMIT 10 OFFSET 990;
```

**API Design**:

```
GET /api/products?page=1&limit=10
GET /api/products?offset=0&limit=10
```

**Response Structure**:

```json
{
  "data": [...],
  "pagination": {
    "total": 1547,
    "page": 1,
    "limit": 10,
    "totalPages": 155
  }
}
```

#### Cursor-Based Pagination

Cursor-based pagination uses a pointer (cursor) to mark the position in the dataset, typically based on a unique, sequential field like an ID or timestamp.

**Mechanism**: The server returns a cursor with each response, which the client uses to request the next set of results. The cursor encodes the position of the last item retrieved.

**Key Points**:

- Consistent results even when data changes (no duplicate or missing items)
- Better performance for large datasets since it uses indexed fields
- Ideal for real-time feeds and infinite scrolling
- Cannot jump to arbitrary pages (no random access)
- Requires a stable, unique ordering field

**Example**:

```sql
-- First request
SELECT * FROM posts ORDER BY created_at DESC, id DESC LIMIT 10;

-- Subsequent request using the last item's values as cursor
SELECT * FROM posts 
WHERE (created_at, id) < ('2025-12-26 10:30:00', 12345)
ORDER BY created_at DESC, id DESC 
LIMIT 10;
```

**API Design**:

```
GET /api/posts?limit=10
GET /api/posts?cursor=eyJpZCI6MTIzNDUsInRzIjoiMjAyNS0xMi0yNiJ9&limit=10
```

**Response Structure**:

```json
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTIzNDUsInRzIjoiMjAyNS0xMi0yNiJ9",
    "hasMore": true
  }
}
```

#### Keyset Pagination

Keyset pagination (also called seek method) is similar to cursor-based pagination but uses explicit field values instead of opaque cursors.

**Mechanism**: The client passes the last seen values of the ordering fields, and the query finds rows after those values.

**Key Points**:

- Predictable and efficient database queries using indexes
- Transparent pagination parameters (no encoded cursors)
- Requires stable sort order with unique combinations
- More complex to implement with multiple sort fields
- [Inference] Generally performs better than offset-based for large datasets due to index usage

**Example**:

```sql
-- First page
SELECT * FROM users ORDER BY last_name, first_name, id LIMIT 20;

-- Next page using last values
SELECT * FROM users 
WHERE (last_name, first_name, id) > ('Smith', 'John', 5432)
ORDER BY last_name, first_name, id 
LIMIT 20;
```

**API Design**:

```
GET /api/users?limit=20&sort=last_name,first_name,id
GET /api/users?limit=20&after_last_name=Smith&after_first_name=John&after_id=5432
```

#### Time-Based Pagination

Time-based pagination uses timestamps to divide data, particularly useful for time-series data, logs, and chronological feeds.

**Mechanism**: Queries filter by time ranges, typically fetching data before or after a specific timestamp.

**Key Points**:

- Natural fit for temporal data like events, messages, or logs
- Efficient when timestamps are indexed
- Handles real-time updates gracefully
- May have inconsistent page sizes if data distribution is uneven
- Requires timestamp fields to be immutable and accurate

**Example**:

```sql
-- Latest messages
SELECT * FROM messages 
WHERE created_at < '2025-12-26 10:00:00'
ORDER BY created_at DESC 
LIMIT 50;

-- Older messages (previous page)
SELECT * FROM messages 
WHERE created_at < '2025-12-25 15:30:00'
ORDER BY created_at DESC 
LIMIT 50;
```

**API Design**:

```
GET /api/messages?before=2025-12-26T10:00:00Z&limit=50
GET /api/messages?after=2025-12-25T08:00:00Z&limit=50
```

### Advanced Pagination Patterns

#### Bidirectional Pagination

Bidirectional pagination allows navigation both forward and backward through a dataset, common in messaging interfaces and social media feeds.

**Implementation Approach**:

- Maintain cursors for both next and previous pages
- Support both `after` and `before` parameters
- Return items in consistent order regardless of direction

**Example API**:

```
GET /api/feed?after=cursor123&limit=20  // Next page
GET /api/feed?before=cursor123&limit=20 // Previous page
```

**Response Structure**:

```json
{
  "data": [...],
  "pagination": {
    "previousCursor": "cursor100",
    "nextCursor": "cursor143",
    "hasNext": true,
    "hasPrevious": true
  }
}
```

#### Infinite Scroll Pagination

Infinite scroll automatically loads more content as users reach the end of the current view, creating a seamless browsing experience.

**Implementation Strategy**:

- Use cursor-based or keyset pagination on the backend
- Detect scroll position on the frontend
- Trigger next page load when user approaches bottom
- Maintain scroll position when new content loads
- Provide loading indicators and error states

**Key Points**:

- Excellent for mobile and exploratory browsing
- Reduces cognitive load (no explicit page selection)
- Can be disorienting for users seeking specific positions
- Challenges with footer accessibility
- [Inference] May impact browser performance with too many loaded items

**Example Client Logic**:

```javascript
// [Unverified] This is example code showing typical implementation patterns,
// but actual behavior depends on browser, library, and data characteristics
const observer = new IntersectionObserver((entries) => {
  if (entries[0].isIntersecting && hasMore && !loading) {
    loadMoreItems();
  }
});

observer.observe(sentinelElement);
```

#### Load More Button

A hybrid approach where users click a button to load additional content, combining control with convenience.

**Key Points**:

- User-controlled loading reduces unexpected behavior
- Works well with cursor or offset pagination
- Maintains scroll position naturally
- Less disorienting than infinite scroll
- Requires explicit user action

#### Virtual Scrolling

Virtual scrolling (or windowing) renders only visible items in long lists, recycling DOM elements as users scroll.

**Key Points**:

- [Inference] Significantly reduces DOM node count, potentially improving rendering performance
- Maintains illusion of scrolling through entire dataset
- Complex to implement correctly (requires precise height calculations)
- Best for homogeneous item sizes
- Libraries like react-window and react-virtualized handle implementation

**Example Concept**:

```
Total items: 10,000
Visible items: 20
Rendered items: 30 (with buffer)
```

### Pagination in Different Contexts

#### Database Pagination

**Relational Databases**:

- Use indexes on pagination fields
- Avoid `SELECT COUNT(*)` for total counts on large tables (use estimates or omit)
- Consider materialized views for complex filtered lists
- [Inference] Index-based approaches like keyset pagination typically outperform offset-based for large offsets

**NoSQL Databases**:

- MongoDB: `skip()` and `limit()` for offset, or range queries for cursor
- DynamoDB: Scan operations with `LastEvaluatedKey`
- Cassandra: Natural support for token-based pagination
- Document databases often favor cursor-based approaches

#### API Pagination

**REST API Standards**:

- Use query parameters for pagination controls
- Include pagination metadata in responses
- Provide HATEOAS links for next/previous pages (optional)
- Document pagination behavior clearly

**GraphQL Pagination**:

- Relay-style cursor connections (most common)
- Offset-based with arguments
- Built-in support for edges and pageInfo

**Example Relay Connection**:

```graphql
{
  products(first: 10, after: "cursor123") {
    edges {
      node { id, name, price }
      cursor
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

#### Frontend Pagination

**Component Design**:

- Show current page and total pages (offset-based)
- Provide first, previous, next, last navigation
- Display page numbers with ellipsis for long ranges
- Include page size selector when appropriate
- Handle loading and error states

**State Management**:

- Cache previously loaded pages
- Invalidate cache when data changes
- Maintain scroll position during navigation
- Preserve pagination state in URL for bookmarking

### Choosing the Right Pagination Pattern

#### Decision Factors

**Data Characteristics**:

- **Size**: Small datasets (<1000 items) can use simple offset; large datasets benefit from cursor/keyset
- **Volatility**: Frequently changing data works better with cursor-based
- **Access Patterns**: Random access needs offset; sequential access suits cursor

**User Experience Requirements**:

- **Page jumping**: Offset-based with page numbers
- **Infinite feeds**: Cursor-based with infinite scroll
- **Sequential reading**: Cursor or time-based
- **Analytics/reporting**: Offset-based for predictable page counts

**Performance Constraints**:

- **Large offsets**: Avoid offset-based; use cursor or keyset
- **Read-heavy**: Any pattern works with proper caching
- **Write-heavy**: Cursor-based handles concurrent modifications better
- **Real-time**: Time-based or cursor for consistency

#### Pattern Comparison

|Pattern|Random Access|Performance (Large Scale)|Consistency|Complexity|
|---|---|---|---|---|
|Offset-based|✓ Excellent|✗ Poor|✗ Inconsistent|★☆☆ Simple|
|Cursor-based|✗ None|✓ Excellent|✓ Consistent|★★☆ Moderate|
|Keyset|✗ None|✓ Excellent|✓ Consistent|★★★ Complex|
|Time-based|~ Limited|✓ Good|✓ Consistent|★★☆ Moderate|

### Implementation Best Practices

#### Backend Implementation

**Performance Optimization**:

- Index all fields used in pagination (ORDER BY and WHERE clauses)
- Limit maximum page size (typically 100-1000 items)
- Use query optimization tools to analyze execution plans
- Consider read replicas for heavy read workloads
- Cache total counts or use approximations

**Error Handling**:

- Validate pagination parameters (negative values, excessive limits)
- Return consistent error formats
- Handle edge cases (empty results, invalid cursors)
- Implement rate limiting to prevent abuse

**Security Considerations**:

- Validate and sanitize all pagination parameters
- Implement authorization checks for paginated data
- [Unverified] Rate limiting may help mitigate denial-of-service attempts via pagination requests, but effectiveness depends on implementation
- Avoid exposing internal IDs in cursors (use signed tokens)

#### Frontend Implementation

**User Experience**:

- Show loading states during pagination requests
- Disable controls during loading to prevent double-requests
- Display meaningful errors when pagination fails
- Preserve filter and sort state across pagination
- Consider skeleton screens for better perceived performance

**Accessibility**:

- Ensure keyboard navigation works for pagination controls
- Announce page changes to screen readers
- Provide skip links for large paginated lists
- Use semantic HTML for pagination components

**Example Accessible Pagination**:

```html
<nav aria-label="Pagination">
  <ul>
    <li><a href="?page=1" aria-label="First page">First</a></li>
    <li><a href="?page=4" aria-label="Previous page">Previous</a></li>
    <li><a href="?page=5" aria-current="page" aria-label="Current page, page 5">5</a></li>
    <li><a href="?page=6" aria-label="Next page">Next</a></li>
    <li><a href="?page=50" aria-label="Last page, page 50">Last</a></li>
  </ul>
</nav>
```

### Common Pitfalls and Solutions

#### N+1 Query Problem

When paginating related data, avoid making separate queries for each item's relationships.

**Problem**:

```sql
-- Main query
SELECT * FROM posts LIMIT 10;
-- Then for each post...
SELECT * FROM comments WHERE post_id = ?;
```

**Solution**:

- Use JOIN queries or batch loading
- Implement eager loading in ORMs
- Use GraphQL DataLoader pattern

#### Inconsistent Ordering

Without stable sort orders, pagination becomes unpredictable.

**Problem**: Sorting by non-unique fields (like `created_at`) without tiebreakers

**Solution**:

- Always include a unique field (like `id`) as final sort criterion
- Document the sort order explicitly
- Ensure indexes match the sort order

#### Cursor Invalidation

Cursors can become invalid if data is deleted or sort criteria change.

**Solutions**:

- Include version information in cursors
- Gracefully handle invalid cursors (return to beginning or show error)
- Document cursor validity duration
- Use signed/encrypted cursors to detect tampering

#### Count Query Performance

Calculating total record counts becomes expensive for large tables.

**Solutions**:

- Cache counts with appropriate TTL
- Use approximate counts (like PostgreSQL's `reltuples`)
- Omit total counts for cursor-based pagination
- Show "More results available" instead of exact counts

### Real-World Examples

#### Social Media Feed

- **Pattern**: Cursor-based with time ordering
- **Features**: Bidirectional scrolling, infinite load
- **Rationale**: Real-time updates, no need for page numbers

#### E-commerce Product Listing

- **Pattern**: Offset-based with page numbers
- **Features**: Sort options, page size selector, filters
- **Rationale**: Users want to jump to specific pages, stable catalog

#### Log Viewer

- **Pattern**: Time-based with range queries
- **Features**: Date range filters, newest-first default
- **Rationale**: Temporal nature of data, chronological access

#### Search Results

- **Pattern**: Offset-based with relevance scoring
- **Features**: Page numbers, "showing X of Y results"
- **Rationale**: Users rarely go past first few pages, relevance matters most

#### API Resource Collection

- **Pattern**: Cursor-based following Relay specification
- **Features**: GraphQL connections, hasNextPage indicator
- **Rationale**: Client flexibility, consistency, forward-only common

### Testing Pagination

#### Unit Tests

- Verify correct LIMIT and OFFSET/cursor values
- Test boundary conditions (first page, last page, empty results)
- Validate pagination metadata accuracy
- Test with different page sizes

#### Integration Tests

- Verify database queries perform as expected
- Test pagination with real data volumes
- Verify cursor validity across requests
- Test concurrent modifications during pagination

#### Performance Tests

- Measure query time across different page positions
- Test with production-scale data volumes
- Compare pagination strategies under load
- Monitor memory usage during pagination

#### User Testing

- [Unverified] Observing how users interact with pagination may provide insights, but specific usability outcomes depend on context
- Test on various devices and screen sizes
- Verify accessibility with assistive technologies
- Gather feedback on loading states and transitions

**Conclusion**: Pagination patterns are fundamental to building scalable applications that handle large datasets efficiently. The choice between offset-based, cursor-based, keyset, or time-based pagination depends on your specific requirements for performance, user experience, and data characteristics. Offset-based pagination offers simplicity and random access but struggles with large datasets and consistency. Cursor-based approaches provide better performance and consistency but sacrifice random access. [Inference] Hybrid approaches combining multiple patterns may offer the best balance for complex applications, though this increases implementation complexity.

**Next Steps**:

- Analyze your data access patterns and volumes
- Choose appropriate pagination strategy for each use case
- Implement proper indexing for pagination queries
- Add comprehensive monitoring for pagination performance
- Test with realistic data volumes and user behaviors
- Consider implementing multiple pagination strategies for different features
- Document pagination behavior for API consumers

---

## Filtering and Searching

Filtering and searching are essential mechanisms in API design that allow clients to retrieve specific subsets of data from larger collections. These features enable efficient data retrieval, reduce bandwidth usage, and improve user experience by returning only relevant results.

### Understanding the Distinction

**Filtering** refers to narrowing down a collection based on specific criteria or conditions applied to resource properties. It's typically used for exact or range-based matches on structured data fields.

**Searching** involves querying resources using text-based input, often implementing full-text search capabilities that match against multiple fields or use fuzzy matching algorithms.

### Common Filtering Approaches

#### Query Parameter Filtering

The most prevalent approach uses URL query parameters to specify filter criteria:

```
GET /api/users?status=active&role=admin
GET /api/products?price_min=10&price_max=100
GET /api/orders?created_after=2024-01-01&country=US
```

This method is straightforward, RESTful, and easily readable. Each parameter typically maps to a resource property.

#### Comparison Operators

More sophisticated filtering systems support comparison operators:

```
GET /api/products?price[gte]=50&price[lte]=200
GET /api/users?age[gt]=18&created_at[lt]=2024-12-01
```

Common operators include:

- `eq` (equal)
- `ne` (not equal)
- `gt` (greater than)
- `gte` (greater than or equal)
- `lt` (less than)
- `lte` (less than or equal)
- `in` (within a set)
- `nin` (not in a set)

#### Complex Filter Syntax

Some APIs implement query languages for complex filtering:

**RSQL/FIQL Style:**

```
GET /api/products?filter=price>=50;price<=200,category==electronics
```

**OData Style:**

```
GET /api/products?$filter=price ge 50 and price le 200 and category eq 'electronics'
```

**JSON-based Filters:**

```
POST /api/users/search
{
  "filter": {
    "and": [
      {"status": {"eq": "active"}},
      {"age": {"gte": 18}},
      {"country": {"in": ["US", "CA", "UK"]}}
    ]
  }
}
```

### Search Implementation Strategies

#### Simple Text Search

Basic search queries across one or multiple fields:

```
GET /api/products?search=laptop
GET /api/users?q=john+doe
```

The API searches designated fields (names, descriptions, tags) for matches.

#### Field-Specific Search

Allowing search targeting specific fields:

```
GET /api/products?name=laptop&description=gaming
GET /api/articles?title_contains=design&author=smith
```

#### Full-Text Search

Advanced search capabilities often leverage dedicated search engines (Elasticsearch, Solr, PostgreSQL full-text):

```
GET /api/articles?q=software+design+patterns&fields=title,content,tags
```

Features include:

- Relevance scoring
- Stemming and lemmatization
- Fuzzy matching for typos
- Synonym handling
- Phrase matching
- Wildcard searches

### Combining Filtering and Search

Modern APIs often support both simultaneously:

```
GET /api/products?search=laptop&category=electronics&price_min=500&in_stock=true
```

This combines text search ("laptop") with structured filters (category, price, availability).

### Pagination Integration

Filtering and searching should work seamlessly with pagination:

```
GET /api/users?status=active&role=admin&page=2&limit=20
GET /api/products?search=laptop&sort=price&order=asc&offset=40&limit=20
```

### Sorting Considerations

Sorting complements filtering and searching:

```
GET /api/products?category=electronics&sort=price&order=desc
GET /api/articles?q=design&sort=relevance,created_at&order=desc,desc
```

Common sort parameters:

- `sort` or `order_by`: field(s) to sort by
- `order` or `dir`: direction (asc/desc)
- Multiple sort fields with precedence

### Design Pattern Considerations

#### Query Object Pattern

Encapsulate filter criteria in a structured object:

```python
class ProductFilter:
    def __init__(self):
        self.category = None
        self.price_min = None
        self.price_max = None
        self.in_stock = None
        self.search_term = None
    
    def apply(self, queryset):
        if self.category:
            queryset = queryset.filter(category=self.category)
        if self.price_min:
            queryset = queryset.filter(price__gte=self.price_min)
        if self.price_max:
            queryset = queryset.filter(price__lte=self.price_max)
        if self.in_stock is not None:
            queryset = queryset.filter(in_stock=self.in_stock)
        if self.search_term:
            queryset = queryset.filter(name__icontains=self.search_term)
        return queryset
```

#### Specification Pattern

Define reusable, composable filter specifications:

```python
class Specification:
    def is_satisfied_by(self, item):
        raise NotImplementedError
    
    def and_(self, other):
        return AndSpecification(self, other)
    
    def or_(self, other):
        return OrSpecification(self, other)

class PriceRangeSpec(Specification):
    def __init__(self, min_price, max_price):
        self.min_price = min_price
        self.max_price = max_price
    
    def is_satisfied_by(self, product):
        return self.min_price <= product.price <= self.max_price

class CategorySpec(Specification):
    def __init__(self, category):
        self.category = category
    
    def is_satisfied_by(self, product):
        return product.category == self.category
```

#### Builder Pattern for Query Construction

Create complex queries incrementally:

```python
class QueryBuilder:
    def __init__(self, base_query):
        self.query = base_query
    
    def filter_by_status(self, status):
        self.query = self.query.filter(status=status)
        return self
    
    def search(self, term):
        self.query = self.query.filter(Q(name__icontains=term) | Q(description__icontains=term))
        return self
    
    def price_range(self, min_price, max_price):
        self.query = self.query.filter(price__gte=min_price, price__lte=max_price)
        return self
    
    def build(self):
        return self.query

# Usage
results = QueryBuilder(Product.objects.all()) \
    .filter_by_status('active') \
    .search('laptop') \
    .price_range(500, 2000) \
    .build()
```

### Security and Performance Considerations

#### Input Validation

Always validate and sanitize filter parameters to prevent:

- SQL injection
- NoSQL injection
- Denial of service through complex queries
- Unauthorized field access

```python
ALLOWED_FILTERS = {'status', 'category', 'price_min', 'price_max'}
ALLOWED_SORT_FIELDS = {'name', 'price', 'created_at'}

def validate_filters(filters):
    for key in filters:
        if key not in ALLOWED_FILTERS:
            raise ValidationError(f"Invalid filter: {key}")
```

#### Query Complexity Limits

Implement safeguards against expensive operations:

```python
MAX_FILTER_CONDITIONS = 10
MAX_SEARCH_TERMS = 5
MAX_OR_CONDITIONS = 3

def check_complexity(filter_data):
    if len(filter_data.get('conditions', [])) > MAX_FILTER_CONDITIONS:
        raise ComplexityError("Too many filter conditions")
```

#### Indexing Strategy

Ensure database indexes support common filter combinations:

```sql
CREATE INDEX idx_products_category_price ON products(category, price);
CREATE INDEX idx_users_status_role ON users(status, role);
CREATE INDEX idx_articles_created_at ON articles(created_at DESC);
```

#### Caching Considerations

Cache frequently used filter combinations:

```python
cache_key = f"products:category={category}:price={price_min}-{price_max}:page={page}"
results = cache.get(cache_key)
if not results:
    results = fetch_filtered_products(category, price_min, price_max, page)
    cache.set(cache_key, results, timeout=300)
```

### API Documentation Best Practices

Clearly document available filters, search capabilities, and their behavior:

```yaml
/api/products:
  get:
    parameters:
      - name: search
        in: query
        description: Text search across name and description
        schema:
          type: string
      - name: category
        in: query
        description: Filter by exact category match
        schema:
          type: string
      - name: price_min
        in: query
        description: Minimum price (inclusive)
        schema:
          type: number
      - name: price_max
        in: query
        description: Maximum price (inclusive)
        schema:
          type: number
      - name: in_stock
        in: query
        description: Filter by availability
        schema:
          type: boolean
```

### Response Format Considerations

Include metadata about filtering and search results:

```json
{
  "data": [...],
  "meta": {
    "total": 1543,
    "filtered": 87,
    "page": 1,
    "per_page": 20,
    "filters_applied": {
      "category": "electronics",
      "price_min": 500,
      "in_stock": true
    },
    "search_query": "laptop"
  }
}
```

### GraphQL Alternative Approach

GraphQL provides built-in filtering capabilities:

```graphql
query {
  products(
    where: {
      category: { eq: "electronics" }
      price: { gte: 500, lte: 2000 }
      inStock: { eq: true }
    }
    search: "laptop"
    orderBy: { price: DESC }
    skip: 20
    take: 20
  ) {
    id
    name
    price
    category
  }
}
```

**Key Points:**

- Filtering narrows results based on structured criteria; searching queries text content
- Query parameters are the most common RESTful approach for simple filters
- Complex filtering may require structured query languages or POST-based filter objects
- Always validate inputs to prevent injection attacks and performance issues
- Combine filtering with pagination, sorting, and search for comprehensive data retrieval
- Document filter capabilities thoroughly for API consumers
- Index database columns that are frequently filtered or searched
- Consider query complexity limits to protect against resource exhaustion

**Example:**

A comprehensive filtering and search endpoint implementation:

```python
from flask import Flask, request, jsonify
from sqlalchemy import and_, or_

app = Flask(__name__)

ALLOWED_FILTERS = {'category', 'status', 'price_min', 'price_max', 'in_stock'}
ALLOWED_SORT_FIELDS = {'name', 'price', 'created_at', 'rating'}

@app.route('/api/products', methods=['GET'])
def get_products():
    # Parse parameters
    search_term = request.args.get('search', '').strip()
    category = request.args.get('category')
    status = request.args.get('status', 'active')
    price_min = request.args.get('price_min', type=float)
    price_max = request.args.get('price_max', type=float)
    in_stock = request.args.get('in_stock', type=lambda v: v.lower() == 'true')
    
    sort_by = request.args.get('sort', 'created_at')
    order = request.args.get('order', 'desc')
    page = request.args.get('page', 1, type=int)
    per_page = min(request.args.get('per_page', 20, type=int), 100)
    
    # Validate inputs
    if sort_by not in ALLOWED_SORT_FIELDS:
        return jsonify({'error': f'Invalid sort field: {sort_by}'}), 400
    
    # Build query
    query = Product.query
    
    # Apply filters
    conditions = []
    if category:
        conditions.append(Product.category == category)
    if status:
        conditions.append(Product.status == status)
    if price_min is not None:
        conditions.append(Product.price >= price_min)
    if price_max is not None:
        conditions.append(Product.price <= price_max)
    if in_stock is not None:
        conditions.append(Product.in_stock == in_stock)
    
    if conditions:
        query = query.filter(and_(*conditions))
    
    # Apply search
    if search_term:
        search_conditions = or_(
            Product.name.ilike(f'%{search_term}%'),
            Product.description.ilike(f'%{search_term}%'),
            Product.tags.ilike(f'%{search_term}%')
        )
        query = query.filter(search_conditions)
    
    # Get total before pagination
    total_filtered = query.count()
    
    # Apply sorting
    sort_column = getattr(Product, sort_by)
    if order == 'desc':
        query = query.order_by(sort_column.desc())
    else:
        query = query.order_by(sort_column.asc())
    
    # Apply pagination
    offset = (page - 1) * per_page
    products = query.offset(offset).limit(per_page).all()
    
    # Build response
    return jsonify({
        'data': [product.to_dict() for product in products],
        'meta': {
            'total': Product.query.count(),
            'filtered': total_filtered,
            'page': page,
            'per_page': per_page,
            'total_pages': (total_filtered + per_page - 1) // per_page,
            'filters_applied': {
                'category': category,
                'status': status,
                'price_min': price_min,
                'price_max': price_max,
                'in_stock': in_stock,
                'search': search_term
            },
            'sort': {
                'field': sort_by,
                'order': order
            }
        }
    })
```

**Output:**

```json
{
  "data": [
    {
      "id": 101,
      "name": "Gaming Laptop Pro",
      "description": "High-performance laptop for gaming",
      "category": "electronics",
      "price": 1299.99,
      "in_stock": true,
      "rating": 4.5,
      "created_at": "2024-11-15T10:30:00Z"
    },
    {
      "id": 203,
      "name": "Ultra Laptop X",
      "description": "Lightweight laptop for professionals",
      "category": "electronics",
      "price": 899.99,
      "in_stock": true,
      "rating": 4.3,
      "created_at": "2024-10-22T14:20:00Z"
    }
  ],
  "meta": {
    "total": 5432,
    "filtered": 87,
    "page": 1,
    "per_page": 20,
    "total_pages": 5,
    "filters_applied": {
      "category": "electronics",
      "status": "active",
      "price_min": 500.0,
      "price_max": 2000.0,
      "in_stock": true,
      "search": "laptop"
    },
    "sort": {
      "field": "price",
      "order": "desc"
    }
  }
}
```

**Conclusion:**

Filtering and searching are fundamental capabilities for any API serving collections of resources. A well-designed implementation balances flexibility for API consumers with security and performance for the API provider. By following RESTful conventions, implementing proper validation, optimizing database queries, and providing clear documentation, you create an API that enables efficient data retrieval while maintaining system integrity. The choice of filtering strategy—from simple query parameters to complex query languages—should match your API's complexity, your consumers' needs, and your team's ability to maintain the implementation.

---

## Bulk Operations

Bulk operations in API design refer to mechanisms that allow clients to perform multiple actions or process multiple resources in a single API request, rather than making separate requests for each individual operation. This pattern is essential for improving performance, reducing network overhead, and providing better user experiences when dealing with large datasets or multiple related operations.

### Purpose and Benefits

Bulk operations address several critical challenges in API design. When applications need to create, update, or delete multiple resources, making individual API calls for each operation becomes inefficient and impractical. Network latency accumulates with each request, server resources are consumed by connection overhead, and the client must manage multiple asynchronous operations simultaneously.

By implementing bulk operations, APIs can significantly reduce the number of round trips between client and server. A single bulk request can process hundreds or thousands of items, reducing total execution time from minutes to seconds. This approach also simplifies error handling, as the client receives a consolidated response indicating which operations succeeded and which failed, rather than tracking multiple independent requests.

### Design Approaches

**Batch Processing**

Batch processing treats a collection of operations as a single transaction or processing unit. The API receives an array of operations and processes them together, returning a comprehensive response that details the outcome of each individual operation within the batch.

```json
POST /api/users/batch
{
  "operations": [
    {
      "method": "POST",
      "resource": "/users",
      "body": {
        "name": "Alice Johnson",
        "email": "alice@example.com"
      }
    },
    {
      "method": "PATCH",
      "resource": "/users/123",
      "body": {
        "status": "active"
      }
    },
    {
      "method": "DELETE",
      "resource": "/users/456"
    }
  ]
}
```

**Collection-Based Operations**

Collection-based operations work on a specific resource type and perform the same action across multiple items. This approach is more restrictive than batch processing but offers clearer semantics and simpler implementation.

```json
POST /api/products/bulk-create
{
  "products": [
    {
      "name": "Product A",
      "price": 29.99,
      "category": "electronics"
    },
    {
      "name": "Product B",
      "price": 49.99,
      "category": "electronics"
    }
  ]
}
```

**Query-Based Bulk Operations**

Query-based operations apply an action to all resources matching specific criteria, without requiring the client to enumerate individual resource identifiers.

```json
PATCH /api/orders/bulk-update?status=pending&created_before=2024-01-01
{
  "status": "cancelled",
  "cancellation_reason": "Expired pending orders cleanup"
}
```

### Response Design

The response structure for bulk operations must provide detailed feedback about each operation's outcome. A well-designed bulk response includes overall status, individual operation results, and summary statistics.

```json
{
  "status": "partial_success",
  "total": 3,
  "successful": 2,
  "failed": 1,
  "results": [
    {
      "index": 0,
      "status": "success",
      "resource_id": "user_789",
      "message": "User created successfully"
    },
    {
      "index": 1,
      "status": "success",
      "resource_id": "user_123",
      "message": "User updated successfully"
    },
    {
      "index": 2,
      "status": "error",
      "error_code": "NOT_FOUND",
      "message": "User with ID 456 does not exist"
    }
  ]
}
```

### Error Handling Strategies

**All-or-Nothing (Transactional)**

In transactional bulk operations, all operations must succeed or all are rolled back. This approach maintains data consistency but can be problematic when processing large batches where a single invalid item causes the entire batch to fail.

```json
{
  "status": "failed",
  "message": "Transaction rolled back due to validation error",
  "failed_at_index": 2,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email address is invalid"
  }
}
```

**Best-Effort (Partial Success)**

Best-effort processing attempts to complete as many operations as possible, reporting successes and failures independently. This approach is more forgiving and allows valid operations to proceed even when some items fail validation or processing.

**Continue-on-Error with Threshold**

A hybrid approach that continues processing until a certain error threshold is reached. If errors exceed a configured percentage or count, the operation stops to prevent cascading failures or data corruption.

### Implementation Considerations

**Request Size Limits**

Bulk operations require careful consideration of payload size limits. APIs should document maximum batch sizes and implement appropriate limits to prevent resource exhaustion. Common approaches include limiting the number of operations per request (e.g., maximum 1000 items) and enforcing payload size limits (e.g., 5MB maximum).

**Processing Strategy**

The server must decide how to process bulk operations: synchronously, asynchronously, or using a hybrid approach. Synchronous processing is suitable for small batches that complete quickly, while asynchronous processing with job queues is necessary for large batches that require extended processing time.

```json
POST /api/documents/bulk-delete
{
  "document_ids": [/* 10,000 IDs */]
}

Response:
{
  "job_id": "bulk_job_abc123",
  "status": "processing",
  "status_url": "/api/jobs/bulk_job_abc123",
  "estimated_completion": "2024-12-26T10:30:00Z"
}
```

**Validation**

Validation for bulk operations should occur at multiple levels. Schema validation ensures the request structure is correct, while business logic validation checks each individual operation. The API should provide clear feedback about which specific items failed validation and why.

**Idempotency**

Bulk operations should be idempotent when possible, allowing clients to safely retry failed requests without causing duplicate operations. This requires implementing idempotency keys or natural idempotency through unique identifiers.

```json
POST /api/transactions/bulk-create
{
  "idempotency_key": "bulk_20241226_abc123",
  "transactions": [
    {
      "external_id": "txn_001",
      "amount": 100.00
    }
  ]
}
```

### Performance Optimization

**Chunking and Pagination**

For extremely large datasets, clients should implement chunking strategies that break operations into multiple manageable bulk requests. The API can support this by providing feedback about optimal chunk sizes and implementing rate limiting that accommodates bulk operations.

**Parallel Processing**

Server-side implementations should leverage parallel processing where possible, using thread pools or distributed processing to handle multiple operations concurrently. However, this must be balanced against resource constraints and database connection limits.

**Database Optimization**

Bulk operations benefit significantly from database-level optimizations such as batch inserts, bulk updates, and prepared statements. Using database-specific bulk operation features can improve performance by orders of magnitude compared to individual row operations.

### Rate Limiting and Throttling

Bulk operations require special consideration in rate limiting policies. Traditional per-request rate limits may be too restrictive for legitimate bulk operations, while unlimited bulk operations could enable abuse. Common approaches include:

- Separate rate limits for bulk endpoints (e.g., 10 bulk requests per hour vs. 1000 individual requests)
- Count-based limits that consider the number of items in each bulk request
- Resource-based throttling that adapts limits based on server load

### Security Considerations

**Authorization**

Bulk operations require careful authorization checks. The API must verify that the authenticated user has permission to perform the requested action on all affected resources, not just some of them. This is particularly important for query-based bulk operations where the affected resources aren't explicitly enumerated.

**Audit Logging**

Bulk operations should generate detailed audit logs that capture not just the bulk operation itself, but information about each individual operation performed. This is essential for compliance, debugging, and security monitoring.

**Resource Exhaustion Prevention**

Without proper safeguards, bulk operations can be exploited to cause denial of service by overwhelming server resources. Implementations should include request size limits, processing timeouts, and monitoring for unusual bulk operation patterns.

### Monitoring and Observability

Effective monitoring of bulk operations requires tracking metrics such as batch sizes, processing times, success/failure rates, and resource utilization. This data helps identify performance bottlenecks, detect abuse patterns, and optimize batch size recommendations.

```json
{
  "metrics": {
    "batch_size": 500,
    "processing_time_ms": 2340,
    "items_per_second": 213.68,
    "success_rate": 0.98
  }
}
```

### Versioning and Evolution

As APIs evolve, bulk operation endpoints require careful versioning. Changes to response formats, error handling strategies, or supported operations can break client integrations. API versioning strategies should clearly document how bulk operations behave in each version.

### Common Pitfalls

Several common mistakes can undermine bulk operation implementations. Processing items sequentially rather than in parallel wastes the performance benefits of bulk operations. Failing to provide detailed error information for individual items makes debugging difficult for clients. Not implementing proper timeouts can cause bulk operations to hang indefinitely on problematic items.

Inconsistent behavior between individual and bulk endpoints confuses developers and leads to integration errors. For example, if a single-item create endpoint has different validation rules than the bulk create endpoint, clients may experience unexpected failures.

### Alternative Patterns

**GraphQL Mutations**

GraphQL provides built-in support for bulk operations through its mutation syntax, allowing clients to specify multiple mutations in a single request and receive structured responses.

**Streaming APIs**

For continuous bulk operations, streaming APIs using technologies like Server-Sent Events or WebSockets can provide real-time feedback as items are processed, rather than waiting for the entire batch to complete.

**Message Queues**

Instead of synchronous bulk API endpoints, some systems expose message queue interfaces where clients can submit large numbers of operations asynchronously, with results delivered through callbacks or polling endpoints.

**Key Points**

- Bulk operations reduce network overhead and improve performance for multi-item operations
- Response design must provide detailed per-item status information
- Error handling strategies range from all-or-nothing transactions to best-effort processing
- Implementation requires careful consideration of request limits, processing strategy, and validation
- Security measures must prevent resource exhaustion and ensure proper authorization
- [Inference] Monitoring and observability are essential for maintaining reliable bulk operations
- Different design approaches (batch, collection-based, query-based) suit different use cases

**Example**

A document management system implements bulk operations for file uploads:

```json
POST /api/documents/bulk-upload
Content-Type: multipart/form-data

{
  "documents": [
    {
      "filename": "report_q4.pdf",
      "category": "financial",
      "tags": ["2024", "quarterly"],
      "content": "base64_encoded_content_here"
    },
    {
      "filename": "meeting_notes.docx",
      "category": "internal",
      "tags": ["2024", "meetings"],
      "content": "base64_encoded_content_here"
    }
  ]
}
```

**Output**

```json
{
  "status": "success",
  "total": 2,
  "successful": 2,
  "failed": 0,
  "processing_time_ms": 1850,
  "results": [
    {
      "index": 0,
      "status": "success",
      "document_id": "doc_9x7k2m",
      "url": "/api/documents/doc_9x7k2m",
      "size_bytes": 245760,
      "message": "Document uploaded and indexed successfully"
    },
    {
      "index": 1,
      "status": "success",
      "document_id": "doc_3p8n1q",
      "url": "/api/documents/doc_3p8n1q",
      "size_bytes": 89120,
      "message": "Document uploaded and indexed successfully"
    }
  ]
}
```

**Conclusion**

Bulk operations are a fundamental pattern for building efficient, scalable APIs. They transform scenarios that would require hundreds or thousands of individual requests into single, manageable operations. Success with bulk operations requires thoughtful design of request and response formats, robust error handling, appropriate security measures, and careful attention to performance characteristics. When implemented well, bulk operations dramatically improve both API performance and developer experience, enabling applications to work efficiently with large datasets.

**Next Steps**

- Design bulk operation endpoints that align with your API's resource model and use cases
- Implement comprehensive response formats that provide detailed per-item feedback
- Add monitoring and metrics to track bulk operation performance and patterns
- Document batch size limits, processing strategies, and error handling behavior clearly
- Consider asynchronous processing for large batches that exceed reasonable synchronous timeouts
- Test bulk operations with realistic data volumes to identify performance bottlenecks
- Implement appropriate rate limiting and security controls specific to bulk operations

---

## Batch Processing

Batch processing is a design pattern where multiple API operations are grouped together and executed as a single request, rather than making individual calls for each operation. This approach optimizes network usage, reduces latency, and improves overall system throughput by minimizing the overhead associated with multiple HTTP requests.

### Core Concepts

Batch processing allows clients to send multiple operations in one HTTP request, which the server then processes and returns results for all operations in a single response. This pattern is particularly valuable when dealing with high-volume data operations, bulk updates, or scenarios where network latency significantly impacts performance.

The fundamental principle involves packaging multiple discrete operations into a single payload, transmitting it once, and receiving a consolidated response containing results for each individual operation.

### Why Use Batch Processing

**Reduced Network Overhead** Each HTTP request carries overhead including connection establishment, headers, SSL/TLS handshake, and protocol processing. Batch processing amortizes this cost across multiple operations, significantly reducing total network traffic.

**Improved Latency** Making 100 individual API calls with 50ms latency each results in 5 seconds of wait time. A single batch request completes in approximately 50ms plus processing time, regardless of the number of operations.

**Better Resource Utilization** Server resources are utilized more efficiently when processing related operations together. Database connections can be reused, transactions can be optimized, and caching strategies become more effective.

**Rate Limiting Management** Many APIs impose rate limits on the number of requests per time window. Batch processing allows you to accomplish more work within these limits by packing multiple operations into fewer requests.

**Transactional Consistency** When operations need to succeed or fail together, batch processing can wrap multiple operations in a single transaction, ensuring atomicity across the entire batch.

### Implementation Patterns

#### Simple Batch Pattern

The most straightforward implementation accepts an array of operations in the request body:

```json
POST /api/batch
{
  "operations": [
    {
      "method": "POST",
      "url": "/users",
      "body": {"name": "Alice", "email": "alice@example.com"}
    },
    {
      "method": "GET",
      "url": "/users/123"
    },
    {
      "method": "PUT",
      "url": "/users/456",
      "body": {"name": "Bob Updated"}
    }
  ]
}
```

Response structure mirrors the request, providing results for each operation:

```json
{
  "responses": [
    {
      "status": 201,
      "body": {"id": 789, "name": "Alice", "email": "alice@example.com"}
    },
    {
      "status": 200,
      "body": {"id": 123, "name": "John", "email": "john@example.com"}
    },
    {
      "status": 200,
      "body": {"id": 456, "name": "Bob Updated", "email": "bob@example.com"}
    }
  ]
}
```

#### Homogeneous Batch Pattern

When all operations target the same resource type and use the same HTTP method, a simplified structure can be used:

```json
POST /api/users/batch
{
  "users": [
    {"name": "Alice", "email": "alice@example.com"},
    {"name": "Bob", "email": "bob@example.com"},
    {"name": "Charlie", "email": "charlie@example.com"}
  ]
}
```

This pattern is cleaner and more efficient for bulk operations on a single resource type.

#### Heterogeneous Batch Pattern

For complex scenarios involving multiple resource types and operations, a more structured approach is needed:

```json
POST /api/batch
{
  "requests": [
    {
      "id": "req1",
      "method": "POST",
      "url": "/orders",
      "body": {"product_id": 100, "quantity": 5}
    },
    {
      "id": "req2",
      "method": "PUT",
      "url": "/inventory/100",
      "body": {"quantity_delta": -5},
      "depends_on": ["req1"]
    },
    {
      "id": "req3",
      "method": "POST",
      "url": "/notifications",
      "body": {"type": "order_placed", "order_id": "$req1.body.id"},
      "depends_on": ["req1"]
    }
  ]
}
```

This pattern includes operation identifiers and dependency declarations, allowing the server to execute operations in the correct order.

#### Multipart Batch Pattern

Some implementations use HTTP multipart requests, particularly when handling file uploads alongside other operations:

```
POST /api/batch
Content-Type: multipart/mixed; boundary=batch_boundary

--batch_boundary
Content-Type: application/http

POST /users HTTP/1.1
Content-Type: application/json

{"name": "Alice"}

--batch_boundary
Content-Type: application/http

GET /users/123 HTTP/1.1

--batch_boundary--
```

### Request Structure Design

#### Operation Identifiers

Each operation in a batch should have a unique identifier for correlation between requests and responses:

```json
{
  "operations": [
    {
      "id": "op1",
      "method": "POST",
      "url": "/users",
      "body": {"name": "Alice"}
    },
    {
      "id": "op2",
      "method": "GET",
      "url": "/users/123"
    }
  ]
}
```

#### Headers Handling

Batch requests need to address how HTTP headers are handled. Common approaches include:

**Global Headers**: Applied to all operations in the batch

```json
{
  "headers": {
    "Authorization": "Bearer token123",
    "Content-Type": "application/json"
  },
  "operations": [...]
}
```

**Per-Operation Headers**: Each operation can specify its own headers

```json
{
  "operations": [
    {
      "method": "POST",
      "url": "/users",
      "headers": {"X-Custom-Header": "value"},
      "body": {"name": "Alice"}
    }
  ]
}
```

#### Query Parameters

Query parameters can be embedded in the URL string or provided as separate fields:

```json
{
  "operations": [
    {
      "method": "GET",
      "url": "/users",
      "query": {
        "page": 1,
        "limit": 10,
        "status": "active"
      }
    }
  ]
}
```

### Response Structure Design

#### Status Code Handling

The batch endpoint itself returns an HTTP status code, but individual operations also have their own status codes. Common approaches:

**Batch Success with Individual Statuses**:

```json
HTTP/1.1 200 OK

{
  "responses": [
    {"id": "op1", "status": 201, "body": {...}},
    {"id": "op2", "status": 404, "body": {"error": "Not found"}},
    {"id": "op3", "status": 200, "body": {...}}
  ]
}
```

**Batch Failure on First Error**:

```json
HTTP/1.1 207 Multi-Status

{
  "responses": [
    {"id": "op1", "status": 201, "body": {...}},
    {"id": "op2", "status": 500, "body": {"error": "Database error"}}
  ],
  "error": "Batch processing stopped at operation op2"
}
```

#### Error Reporting

Comprehensive error information helps clients understand what failed and why:

```json
{
  "responses": [
    {
      "id": "op1",
      "status": 400,
      "error": {
        "code": "VALIDATION_ERROR",
        "message": "Email is required",
        "field": "email"
      }
    },
    {
      "id": "op2",
      "status": 200,
      "body": {"id": 123, "name": "John"}
    }
  ],
  "summary": {
    "total": 2,
    "succeeded": 1,
    "failed": 1
  }
}
```

#### Partial Success Handling

Batch operations often result in partial success where some operations succeed and others fail. The response should clearly indicate this:

```json
HTTP/1.1 207 Multi-Status

{
  "batch_status": "PARTIAL_SUCCESS",
  "responses": [
    {"id": "op1", "status": 201, "body": {...}},
    {"id": "op2", "status": 409, "error": "Conflict: User already exists"},
    {"id": "op3", "status": 201, "body": {...}}
  ],
  "summary": {
    "total": 3,
    "succeeded": 2,
    "failed": 1
  }
}
```

### Processing Strategies

#### Sequential Processing

Operations are executed one after another in the order they appear:

```
Operation 1 → Operation 2 → Operation 3 → Operation 4
```

**Advantages:**

- Simple to implement
- Maintains strict ordering
- Easier to handle dependencies
- Predictable resource usage

**Disadvantages:**

- Slower for independent operations
- One slow operation blocks all subsequent operations
- Cannot leverage parallelism

#### Parallel Processing

Independent operations are executed concurrently:

```
Operation 1 ─┐
Operation 2 ─┼→ Process simultaneously
Operation 3 ─┘
```

**Advantages:**

- Significantly faster for independent operations
- Better resource utilization
- Reduced overall latency

**Disadvantages:**

- More complex implementation
- Requires dependency analysis
- Higher resource consumption
- Potential race conditions

#### Hybrid Processing

Combines sequential and parallel processing based on operation dependencies:

```
Operation 1 ────→ Operation 4
                     ↑
Operation 2 ─┬─────┘
Operation 3 ─┘
```

**Advantages:**

- Optimal performance for dependent operations
- Leverages parallelism where possible
- Maintains correctness with dependencies

**Disadvantages:**

- Most complex to implement
- Requires dependency graph construction
- Complex error handling

### Dependency Management

#### Explicit Dependencies

Operations can declare dependencies on other operations in the batch:

```json
{
  "operations": [
    {
      "id": "create_user",
      "method": "POST",
      "url": "/users",
      "body": {"name": "Alice"}
    },
    {
      "id": "create_profile",
      "method": "POST",
      "url": "/profiles",
      "body": {
        "user_id": "$create_user.response.id",
        "bio": "Software engineer"
      },
      "depends_on": ["create_user"]
    }
  ]
}
```

#### Variable Substitution

Results from earlier operations can be referenced in subsequent operations:

```json
{
  "id": "send_email",
  "method": "POST",
  "url": "/emails",
  "body": {
    "to": "$create_user.response.email",
    "subject": "Welcome!",
    "body": "Hello $create_user.response.name"
  },
  "depends_on": ["create_user"]
}
```

The server resolves these references after executing the dependent operation.

#### Conditional Execution

Operations can be conditionally executed based on previous results:

```json
{
  "id": "send_welcome_email",
  "method": "POST",
  "url": "/emails",
  "body": {...},
  "depends_on": ["create_user"],
  "execute_if": "$create_user.status == 201"
}
```

### Transaction Handling

#### All-or-Nothing Semantics

Some batch operations require atomicity—either all operations succeed or all are rolled back:

```json
POST /api/batch?transaction=true

{
  "operations": [
    {"method": "POST", "url": "/accounts", "body": {...}},
    {"method": "PUT", "url": "/balances/123", "body": {...}},
    {"method": "POST", "url": "/ledger", "body": {...}}
  ]
}
```

If any operation fails, the entire batch is rolled back. This is critical for financial transactions, inventory management, and other scenarios requiring consistency.

#### Best Effort Semantics

In contrast, best-effort processing attempts all operations independently:

```json
POST /api/batch?transaction=false

{
  "operations": [
    {"method": "POST", "url": "/notifications/user1", "body": {...}},
    {"method": "POST", "url": "/notifications/user2", "body": {...}},
    {"method": "POST", "url": "/notifications/user3", "body": {...}}
  ]
}
```

Each operation is committed independently. Failures in one operation don't affect others.

#### Compensation Strategies

For complex distributed transactions, compensation logic may be necessary:

```json
{
  "operations": [
    {
      "id": "reserve_inventory",
      "method": "PUT",
      "url": "/inventory/100",
      "body": {"reserve": 5},
      "compensation": {
        "method": "PUT",
        "url": "/inventory/100",
        "body": {"release": 5}
      }
    },
    {
      "id": "charge_payment",
      "method": "POST",
      "url": "/payments",
      "body": {"amount": 99.99}
    }
  ]
}
```

If `charge_payment` fails, the compensation action for `reserve_inventory` is executed automatically.

### Size Limitations

#### Maximum Batch Size

APIs should enforce limits on batch size to prevent resource exhaustion:

```json
HTTP/1.1 400 Bad Request

{
  "error": "BATCH_TOO_LARGE",
  "message": "Maximum batch size is 100 operations",
  "submitted": 150,
  "max_allowed": 100
}
```

[Inference] Common batch size limits range from 50 to 1000 operations, depending on the complexity of individual operations and server capacity.

#### Payload Size Limits

Total request payload size should also be constrained:

```json
{
  "error": "PAYLOAD_TOO_LARGE",
  "message": "Maximum payload size is 5MB",
  "submitted_size": "7.3MB",
  "max_allowed_size": "5MB"
}
```

#### Timeout Considerations

Long-running batch operations require appropriate timeout handling:

```json
POST /api/batch?timeout=300

{
  "operations": [...]
}
```

If processing exceeds the timeout, the server should return partial results:

```json
HTTP/1.1 408 Request Timeout

{
  "error": "BATCH_TIMEOUT",
  "message": "Processing exceeded 300 seconds",
  "completed_operations": 75,
  "total_operations": 100,
  "responses": [
    // Results for the 75 completed operations
  ]
}
```

### Performance Optimization

#### Connection Pooling

Batch operations should reuse database connections and external service connections:

```python
# Pseudocode
def process_batch(operations):
    with connection_pool.get_connection() as conn:
        results = []
        for op in operations:
            result = execute_operation(op, conn)
            results.append(result)
        return results
```

#### Query Optimization

When multiple operations access the same data, optimize database queries:

```python
# Instead of individual queries
for user_id in user_ids:
    user = db.query("SELECT * FROM users WHERE id = ?", user_id)
    process(user)

# Bulk query
users = db.query("SELECT * FROM users WHERE id IN (?)", user_ids)
for user in users:
    process(user)
```

#### Caching Strategies

Leverage caching within batch processing:

```python
cache = {}

def process_batch_with_cache(operations):
    for op in operations:
        cache_key = generate_key(op)
        if cache_key in cache:
            result = cache[cache_key]
        else:
            result = execute_operation(op)
            cache[cache_key] = result
        yield result
```

#### Streaming Responses

For large batches, stream results as they become available:

```json
HTTP/1.1 200 OK
Content-Type: application/x-ndjson
Transfer-Encoding: chunked

{"id":"op1","status":201,"body":{...}}
{"id":"op2","status":200,"body":{...}}
{"id":"op3","status":200,"body":{...}}
```

Each line is a complete JSON object representing one operation's result.

### Security Considerations

#### Authentication and Authorization

Each operation in a batch must be individually authorized:

```python
def process_batch(operations, user):
    results = []
    for op in operations:
        if not has_permission(user, op):
            results.append({
                "id": op.id,
                "status": 403,
                "error": "Forbidden"
            })
            continue
        
        result = execute_operation(op)
        results.append(result)
    
    return results
```

[Inference] Simply authenticating the batch request itself is insufficient; each individual operation must be checked against the user's permissions.

#### Rate Limiting

Batch operations should count towards rate limits appropriately:

```
Option 1: Count as single request (lenient)
Option 2: Count as N requests where N = number of operations (strict)
Option 3: Weighted count based on operation complexity (balanced)
```

#### Input Validation

Every operation in the batch must be validated:

```python
def validate_batch(operations):
    errors = []
    for i, op in enumerate(operations):
        if not valid_method(op.method):
            errors.append(f"Operation {i}: Invalid HTTP method")
        if not valid_url(op.url):
            errors.append(f"Operation {i}: Invalid URL")
        if not valid_body(op.body):
            errors.append(f"Operation {i}: Invalid request body")
    
    if errors:
        raise ValidationError(errors)
```

#### Injection Attack Prevention

Batch operations with variable substitution must sanitize inputs:

```python
def substitute_variables(template, context):
    # Bad: Direct string replacement
    # result = template.replace("$var", context["var"])
    
    # Good: Parameterized substitution with validation
    result = safe_substitute(template, sanitize(context))
    return result
```

### Error Handling Strategies

#### Fail-Fast Strategy

Stop processing on the first error:

```json
{
  "strategy": "FAIL_FAST",
  "responses": [
    {"id": "op1", "status": 201, "body": {...}},
    {"id": "op2", "status": 500, "error": "Database error"}
  ],
  "error": "Batch processing terminated due to error in operation op2",
  "processed": 2,
  "total": 10
}
```

**Use cases:**

- Transactional operations
- Dependent operation chains
- When partial results are not useful

#### Continue-on-Error Strategy

Process all operations regardless of errors:

```json
{
  "strategy": "CONTINUE_ON_ERROR",
  "responses": [
    {"id": "op1", "status": 201, "body": {...}},
    {"id": "op2", "status": 500, "error": "Database error"},
    {"id": "op3", "status": 201, "body": {...}},
    {"id": "op4", "status": 404, "error": "Not found"},
    {"id": "op5", "status": 200, "body": {...}}
  ],
  "summary": {
    "total": 5,
    "succeeded": 3,
    "failed": 2
  }
}
```

**Use cases:**

- Independent operations
- Bulk notifications
- Data synchronization
- When partial success is acceptable

#### Retry Strategies

Implement automatic retries for transient failures:

```json
{
  "operations": [
    {
      "id": "op1",
      "method": "POST",
      "url": "/external-service",
      "body": {...},
      "retry": {
        "max_attempts": 3,
        "backoff": "exponential",
        "retry_on": [500, 502, 503, 504]
      }
    }
  ]
}
```

### Versioning and Compatibility

#### API Version Handling

Different operations in a batch may target different API versions:

```json
{
  "operations": [
    {
      "method": "GET",
      "url": "/v1/users/123",
      "version": "1.0"
    },
    {
      "method": "POST",
      "url": "/v2/orders",
      "version": "2.0",
      "body": {...}
    }
  ]
}
```

#### Backward Compatibility

Support legacy batch formats while introducing new features:

```json
// Legacy format
{
  "requests": [...]
}

// New format with additional features
{
  "version": "2.0",
  "operations": [...],
  "options": {
    "transaction": true,
    "parallel": true
  }
}
```

### Monitoring and Observability

#### Metrics Collection

Track key performance indicators for batch operations:

- Batch size distribution
- Processing time per operation
- Success/failure rates
- Throughput (operations per second)
- Resource utilization

```json
{
  "batch_id": "batch_123",
  "metrics": {
    "total_operations": 50,
    "successful_operations": 48,
    "failed_operations": 2,
    "processing_time_ms": 1250,
    "avg_operation_time_ms": 25
  }
}
```

#### Logging

Comprehensive logging for troubleshooting:

```
[2025-01-15 10:30:45] BATCH_START batch_id=batch_123 operations=50 user_id=user_456
[2025-01-15 10:30:45] OP_START batch_id=batch_123 op_id=op1 method=POST url=/users
[2025-01-15 10:30:45] OP_SUCCESS batch_id=batch_123 op_id=op1 status=201 duration_ms=25
[2025-01-15 10:30:45] OP_START batch_id=batch_123 op_id=op2 method=GET url=/users/123
[2025-01-15 10:30:45] OP_FAIL batch_id=batch_123 op_id=op2 status=404 duration_ms=15
[2025-01-15 10:30:46] BATCH_COMPLETE batch_id=batch_123 success=48 failed=2 duration_ms=1250
```

#### Tracing

Distributed tracing for batch operations:

```json
{
  "trace_id": "trace_xyz",
  "batch_span": {
    "span_id": "span_123",
    "operation": "process_batch",
    "duration_ms": 1250
  },
  "operation_spans": [
    {
      "span_id": "span_124",
      "parent_span_id": "span_123",
      "operation": "create_user",
      "duration_ms": 25
    },
    {
      "span_id": "span_125",
      "parent_span_id": "span_123",
      "operation": "update_profile",
      "duration_ms": 30
    }
  ]
}
```

### Testing Strategies

#### Unit Testing

Test individual batch operation processing logic:

```python
def test_batch_processing():
    operations = [
        {"id": "op1", "method": "POST", "url": "/users", "body": {"name": "Alice"}},
        {"id": "op2", "method": "GET", "url": "/users/123"}
    ]
    
    results = process_batch(operations)
    
    assert len(results) == 2
    assert results[0]["status"] == 201
    assert results[1]["status"] == 200
```

#### Integration Testing

Test end-to-end batch processing with real dependencies:

```python
def test_batch_integration():
    client = APIClient()
    
    response = client.post("/api/batch", json={
        "operations": [
            {"method": "POST", "url": "/users", "body": {"name": "Test User"}},
            {"method": "GET", "url": "/users"}
        ]
    })
    
    assert response.status_code == 200
    assert len(response.json()["responses"]) == 2
```

#### Load Testing

Validate batch processing under high load:

```python
def test_batch_load():
    # Test with increasing batch sizes
    for batch_size in [10, 50, 100, 500, 1000]:
        operations = generate_operations(batch_size)
        
        start = time.time()
        response = client.post("/api/batch", json={"operations": operations})
        duration = time.time() - start
        
        assert response.status_code == 200
        assert duration < acceptable_threshold(batch_size)
```

#### Failure Scenario Testing

Test error handling and recovery:

```python
def test_batch_partial_failure():
    operations = [
        {"id": "op1", "method": "POST", "url": "/users", "body": {"name": "Alice"}},
        {"id": "op2", "method": "GET", "url": "/invalid_endpoint"},  # Will fail
        {"id": "op3", "method": "GET", "url": "/users/123"}
    ]
    
    response = client.post("/api/batch", json={"operations": operations})
    
    assert response.status_code == 207  # Multi-Status
    results = response.json()["responses"]
    assert results[0]["status"] == 201
    assert results[1]["status"] == 404
    assert results[2]["status"] == 200
```

### Real-World Examples

#### GraphQL Batch Queries

GraphQL supports batching multiple queries in a single request:

```graphql
[
  {
    "query": "query { user(id: 123) { name email } }"
  },
  {
    "query": "query { posts(limit: 10) { title author } }"
  },
  {
    "query": "mutation { createComment(postId: 456, text: \"Great post!\") { id } }"
  }
]
```

Response:

```json
[
  {
    "data": {
      "user": {"name": "John", "email": "john@example.com"}
    }
  },
  {
    "data": {
      "posts": [
        {"title": "Post 1", "author": "Alice"},
        {"title": "Post 2", "author": "Bob"}
      ]
    }
  },
  {
    "data": {
      "createComment": {"id": 789}
    }
  }
]
```

#### Google Cloud Storage Batch API

Google Cloud Storage uses batch requests for multiple object operations:

```http
POST https://storage.googleapis.com/batch/storage/v1
Content-Type: multipart/mixed; boundary=batch_boundary

--batch_boundary
Content-Type: application/http

GET /storage/v1/b/bucket-name/o/object-1

--batch_boundary
Content-Type: application/http

DELETE /storage/v1/b/bucket-name/o/object-2

--batch_boundary
Content-Type: application/http

POST /storage/v1/b/bucket-name/o
Content-Type: application/json

{"name": "new-object", "contentType": "text/plain"}

--batch_boundary--
```

#### Facebook Graph API Batch Requests

Facebook's Graph API supports batch operations:

```json
POST /v18.0
Content-Type: application/json

{
  "batch": [
    {
      "method": "GET",
      "relative_url": "me?fields=id,name"
    },
    {
      "method": "GET",
      "relative_url": "me/friends?limit=10"
    },
    {
      "method": "POST",
      "relative_url": "me/feed",
      "body": "message=Hello World"
    }
  ]
}
```

Response:

```json
[
  {
    "code": 200,
    "headers": [{"name": "Content-Type", "value": "application/json"}],
    "body": "{\"id\":\"123\",\"name\":\"John Doe\"}"
  },
  {
    "code": 200,
    "headers": [{"name": "Content-Type", "value": "application/json"}],
    "body": "{\"data\":[{\"name\":\"Alice\",\"id\":\"456\"}]}"
  },
  {
    "code": 201,
    "headers": [{"name": "Content-Type", "value": "application/json"}],
    "body": "{\"id\":\"post_789\"}"
  }
]
```

#### AWS S3 Batch Operations

AWS S3 provides batch operations for large-scale object management:

```xml
POST /?batch HTTP/1.1
Host: s3.amazonaws.com

<?xml version="1.0" encoding="UTF-8"?>
<BatchRequest>
  <Operations>
    <Operation>
      <Copy>
        <SourceBucket>source-bucket</SourceBucket>
        <SourceKey>object1.txt</SourceKey>
        <DestinationBucket>dest-bucket</DestinationBucket>
        <DestinationKey>object1.txt</DestinationKey>
      </Copy>
    </Operation>
    <Operation>
      <Delete>
        <Bucket>source-bucket</Bucket>
        <Key>object2.txt</Key>
      </Delete>
    </Operation>
  </Operations>
</BatchRequest>
```

### Best Practices

#### Keep Batches Focused

Group related operations together. Avoid mixing unrelated operations in a single batch:

```json
// Good: Related user operations
{
  "operations": [
    {"method": "POST", "url": "/users", "body": {...}},
    {"method": "POST", "url": "/users/123/preferences", "body": {...}},
    {"method": "POST", "url": "/users/123/notifications", "body": {...}}
  ]
}

// Bad: Unrelated operations
{
  "operations": [
    {"method": "POST", "url": "/users", "body": {...}},
    {"method": "GET", "url": "/products/search?q=laptop"},
    {"method": "DELETE", "url": "/cache/clear"}
  ]
}
```

#### Provide Operation IDs

Always include unique identifiers for operations to enable proper correlation:

```json
{
  "operations": [
    {"id": "create_user", "method": "POST", ...},
    {"id": "create_profile", "method": "POST", ...},
    {"id": "send_welcome_email", "method": "POST", ...}
  ]
}
```

#### Document Batch Limits

Clearly document size limits, timeout values, and any restrictions:

```
Batch API Limits:
- Maximum operations per batch: 100
- Maximum payload size: 5MB
- Maximum processing time: 300 seconds
- Maximum operations per second: 1000
- Supported HTTP methods: GET, POST, PUT, PATCH, DELETE
```

#### Handle Partial Failures Gracefully

Design clients to handle partial success scenarios:

```javascript
const response = await fetch('/api/batch', {
  method: 'POST',
  body: JSON.stringify({operations})
});

const results = await response.json();
const succeeded = results.responses.filter(r => r.status >= 200 && r.status < 300);
const failed = results.responses.filter(r => r.status >= 400);

console.log(`Succeeded: ${succeeded.length}, Failed: ${failed.length}`);

// Retry failed operations
if (failed.length > 0) {
  await retryOperations(failed);
}
```

#### Implement Idempotency

Design operations to be idempotent when possible:

```json
{
  "operations": [
    {
      "method": "PUT",
      "url": "/users/123",
      "body": {"name": "Alice", "email": "alice@example.com"},
      "idempotency_key": "update_user_123_20250115"
    }
  ]
}
```

This allows safe retries without duplicate side effects.

#### Use Appropriate HTTP Status Codes

Return meaningful status codes for different scenarios:

- `200 OK`: All operations succeeded
- `207 Multi-Status`: Mixed success/failure
- `400 Bad Request`: Invalid batch request structure
- `413 Payload Too Large`: Batch size exceeds limits
- `408 Request Timeout`: Processing exceeded timeout

#### Monitor and Alert

Set up monitoring for batch operation health:

```
Alerts:
- Batch failure rate > 5%
- Average processing time > 10 seconds
- Batch queue depth > 1000
- Individual operation failure rate > 10%
```

### Common Pitfalls

#### Insufficient Error Information

**Problem:**

```json
{
  "responses": [
    {"id": "op1", "status": 500, "error": "Internal error"}
  ]
}
```

**Solution:**

```json
{
  "responses": [
    {
      "id": "op1",
      "status": 500,
      "error": {
        "code": "DATABASE_CONNECTION_ERROR",
        "message": "Failed to connect to database",
        "details": "Connection timeout after 30 seconds",
        "retry_after": 60
      }
    }
  ]
}
```

#### Not Respecting Rate Limits

[Inference] Batch operations can inadvertently trigger rate limits if not properly accounted for. [Unverified] Implement batch-aware rate limiting:

```python
def check_rate_limit(user_id, operation_count):
    current_usage = get_usage(user_id)
    limit = get_limit(user_id)
    
    if current_usage + operation_count > limit:
        raise RateLimitExceeded(
            f"Batch would exceed rate limit. Current: {current_usage}, "
            f"Requested: {operation_count}, Limit: {limit}"
        )
```

#### Ignoring Transaction Boundaries

**Problem:** Mixing transactional and non-transactional operations without clear semantics.

**Solution:** Clearly define transaction scope:

```json
{
  "transaction_groups": [
    {
      "transaction": true,
      "operations": [
        {"method": "POST", "url": "/orders", ...},
        {"method": "PUT", "url": "/inventory", ...}
      ]
    },
    {
      "transaction": false,
      "operations": [
        {"method": "POST", "url": "/analytics/event", ...}
      ]
    }
  ]
}
```

#### Poor Performance with Large Batches

**Problem:** Processing all operations synchronously leads to timeouts.

**Solution:** Implement asynchronous batch processing:

```json
POST /api/batch/async

{
  "operations": [...]
}

Response:
{
  "batch_id": "batch_123",
  "status": "PROCESSING",
  "status_url": "/api/batch/batch_123/status",
  "estimated_completion": "2025-01-15T10:35:00Z"
}
```

Clients poll for results:

```
GET /api/batch/batch_123/status

{
  "batch_id": "batch_123",
  "status": "COMPLETED",
  "results_url": "/api/batch/batch_123/results",
  "progress": {
    "total": 1000,
    "completed": 1000,
    "succeeded": 985,
    "failed": 15
  }
}
```

#### Lack of Operation Ordering

**Problem:** Dependencies between operations are not respected.

**Solution:** Implement dependency tracking and proper execution ordering as shown in the Dependency Management section.

### Alternative Approaches

#### Asynchronous Task Queues

Instead of synchronous batch processing, use task queues:

```json
POST /api/tasks/batch

{
  "tasks": [
    {"type": "create_user", "data": {...}},
    {"type": "send_email", "data": {...}},
    {"type": "update_analytics", "data": {...}}
  ]
}

Response:
{
  "task_group_id": "tg_123",
  "status_url": "/api/tasks/groups/tg_123"
}
```

**Advantages:**

- Better for long-running operations
- Doesn't block client connection
- Can retry failed tasks automatically
- Scales better under load

**Disadvantages:**

- More complex architecture
- Requires separate status polling
- Delayed results

#### Streaming APIs

For continuous data flow, use streaming instead of batches:

```
POST /api/stream
Content-Type: application/x-ndjson

{"method":"POST","url":"/users","body":{"name":"Alice"}}
{"method":"POST","url":"/users","body":{"name":"Bob"}}
{"method":"POST","url":"/users","body":{"name":"Charlie"}}
```

Response stream:

```
{"id":"op1","status":201,"body":{"id":1,"name":"Alice"}}
{"id":"op2","status":201,"body":{"id":2,"name":"Bob"}}
{"id":"op3","status":201,"body":{"id":3,"name":"Charlie"}}
```

#### Bulk Endpoints

For specific use cases, dedicated bulk endpoints may be cleaner:

```json
POST /api/users/bulk

{
  "users": [
    {"name": "Alice", "email": "alice@example.com"},
    {"name": "Bob", "email": "bob@example.com"}
  ]
}
```

**When to use bulk endpoints:**

- Single resource type
- Single operation type
- Simple, predictable processing
- High-volume operations

**When to use batch endpoints:**

- Multiple resource types
- Multiple operation types
- Complex dependencies
- Flexible operation composition

### Implementation Example

**Key Points:**

- Complete implementation demonstrating batch processing patterns
- Error handling with partial success support
- Dependency management between operations
- Both sequential and parallel processing strategies

**Example:** Python/Flask implementation of a batch API endpoint

```python
from flask import Flask, request, jsonify
from typing import List, Dict, Any
import json
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

app = Flask(__name__)

class BatchProcessor:
    def __init__(self, max_workers=10):
        self.max_workers = max_workers
        self.operation_handlers = {
            'GET': self.handle_get,
            'POST': self.handle_post,
            'PUT': self.handle_put,
            'DELETE': self.handle_delete
        }
    
    def process_batch(self, operations: List[Dict], strategy: str = 'sequential'):
        """Process a batch of operations"""
        if strategy == 'parallel':
            return self._process_parallel(operations)
        else:
            return self._process_sequential(operations)
    
    def _process_sequential(self, operations: List[Dict]) -> Dict:
        """Process operations one by one"""
        responses = []
        
        for op in operations:
            try:
                result = self._execute_operation(op)
                responses.append(result)
            except Exception as e:
                responses.append({
                    'id': op.get('id'),
                    'status': 500,
                    'error': {
                        'code': 'EXECUTION_ERROR',
                        'message': str(e)
                    }
                })
        
        return self._build_response(responses)
    
    def _process_parallel(self, operations: List[Dict]) -> Dict:
        """Process independent operations in parallel"""
        # Build dependency graph
        dependencies = self._build_dependency_graph(operations)
        
        # Identify independent operations
        independent_ops = [op for op in operations 
                          if not op.get('depends_on')]
        
        responses = []
        completed_ops = {}
        
        # Process independent operations in parallel
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            future_to_op = {
                executor.submit(self._execute_operation, op): op 
                for op in independent_ops
            }
            
            for future in as_completed(future_to_op):
                op = future_to_op[future]
                try:
                    result = future.result()
                    responses.append(result)
                    completed_ops[op['id']] = result
                except Exception as e:
                    error_result = {
                        'id': op.get('id'),
                        'status': 500,
                        'error': str(e)
                    }
                    responses.append(error_result)
                    completed_ops[op['id']] = error_result
        
        # Process dependent operations
        dependent_ops = [op for op in operations if op.get('depends_on')]
        for op in dependent_ops:
            # Check if dependencies succeeded
            deps_ok = all(
                completed_ops.get(dep_id, {}).get('status', 0) < 400
                for dep_id in op['depends_on']
            )
            
            if deps_ok:
                try:
                    # Substitute variables from dependent operations
                    op = self._substitute_variables(op, completed_ops)
                    result = self._execute_operation(op)
                    responses.append(result)
                    completed_ops[op['id']] = result
                except Exception as e:
                    error_result = {
                        'id': op.get('id'),
                        'status': 500,
                        'error': str(e)
                    }
                    responses.append(error_result)
            else:
                responses.append({
                    'id': op.get('id'),
                    'status': 424,
                    'error': 'Dependency failed'
                })
        
        return self._build_response(responses)
    
    def _execute_operation(self, operation: Dict) -> Dict:
        """Execute a single operation"""
        op_id = operation.get('id', 'unknown')
        method = operation.get('method', '').upper()
        url = operation.get('url', '')
        
        # Validate operation
        if method not in self.operation_handlers:
            return {
                'id': op_id,
                'status': 400,
                'error': f'Unsupported method: {method}'
            }
        
        # Execute operation handler
        handler = self.operation_handlers[method]
        result = handler(operation)
        
        return {
            'id': op_id,
            **result
        }
    
    def handle_get(self, operation: Dict) -> Dict:
        """Handle GET operation"""
        url = operation['url']
        
        # Simulate GET request
        # In real implementation, this would call actual endpoints
        if '/users/' in url:
            user_id = url.split('/')[-1]
            return {
                'status': 200,
                'body': {
                    'id': user_id,
                    'name': f'User {user_id}',
                    'email': f'user{user_id}@example.com'
                }
            }
        
        return {'status': 404, 'error': 'Not found'}
    
    def handle_post(self, operation: Dict) -> Dict:
        """Handle POST operation"""
        url = operation['url']
        body = operation.get('body', {})
        
        # Simulate POST request
        if '/users' in url:
            return {
                'status': 201,
                'body': {
                    'id': int(time.time() * 1000),
                    **body
                }
            }
        
        return {'status': 400, 'error': 'Invalid endpoint'}
    
    def handle_put(self, operation: Dict) -> Dict:
        """Handle PUT operation"""
        url = operation['url']
        body = operation.get('body', {})
        
        # Simulate PUT request
        if '/users/' in url:
            user_id = url.split('/')[-1]
            return {
                'status': 200,
                'body': {
                    'id': user_id,
                    **body
                }
            }
        
        return {'status': 404, 'error': 'Not found'}
    
    def handle_delete(self, operation: Dict) -> Dict:
        """Handle DELETE operation"""
        url = operation['url']
        
        # Simulate DELETE request
        if '/users/' in url:
            return {'status': 204}
        
        return {'status': 404, 'error': 'Not found'}
    
    def _build_dependency_graph(self, operations: List[Dict]) -> Dict:
        """Build dependency graph for operations"""
        graph = {}
        for op in operations:
            op_id = op.get('id')
            depends_on = op.get('depends_on', [])
            graph[op_id] = depends_on
        return graph
    
    def _substitute_variables(self, operation: Dict, 
                            completed_ops: Dict) -> Dict:
        """Substitute variables from completed operations"""
        op_copy = operation.copy()
        body = op_copy.get('body', {})
        
        # Convert body to string for replacement
        body_str = json.dumps(body)
        
        # Replace variables like $op_id.response.field
        for dep_id in operation.get('depends_on', []):
            if dep_id in completed_ops:
                dep_result = completed_ops[dep_id]
                # Simple variable substitution
                placeholder = f'${dep_id}.response.'
                if placeholder in body_str:
                    # This is simplified; real implementation would be more robust
                    pass
        
        op_copy['body'] = json.loads(body_str)
        return op_copy
    
    def _build_response(self, responses: List[Dict]) -> Dict:
        """Build final batch response"""
        total = len(responses)
        succeeded = sum(1 for r in responses 
                       if 200 <= r.get('status', 0) < 300)
        failed = total - succeeded
        
        # Determine overall status
        if failed == 0:
            batch_status = 'SUCCESS'
            http_status = 200
        elif succeeded == 0:
            batch_status = 'FAILED'
            http_status = 500
        else:
            batch_status = 'PARTIAL_SUCCESS'
            http_status = 207
        
        return {
            'status': batch_status,
            'http_status': http_status,
            'responses': responses,
            'summary': {
                'total': total,
                'succeeded': succeeded,
                'failed': failed
            }
        }

# Initialize processor
processor = BatchProcessor(max_workers=10)

@app.route('/api/batch', methods=['POST'])
def batch_endpoint():
    """Main batch API endpoint"""
    try:
        data = request.get_json()
        
        # Validate request
        if 'operations' not in data:
            return jsonify({
                'error': 'Missing operations field'
            }), 400
        
        operations = data['operations']
        
        # Check batch size limit
        max_batch_size = 100
        if len(operations) > max_batch_size:
            return jsonify({
                'error': 'BATCH_TOO_LARGE',
                'message': f'Maximum batch size is {max_batch_size}',
                'submitted': len(operations),
                'max_allowed': max_batch_size
            }), 400
        
        # Get processing strategy
        strategy = data.get('strategy', 'sequential')
        
        # Process batch
        result = processor.process_batch(operations, strategy)
        
        return jsonify(result), result['http_status']
        
    except Exception as e:
        return jsonify({
            'error': 'INTERNAL_ERROR',
            'message': str(e)
        }), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

**Output:**

Request:

```bash
curl -X POST http://localhost:5000/api/batch \
  -H "Content-Type: application/json" \
  -d '{
    "strategy": "parallel",
    "operations": [
      {
        "id": "create_user",
        "method": "POST",
        "url": "/users",
        "body": {"name": "Alice", "email": "alice@example.com"}
      },
      {
        "id": "get_user",
        "method": "GET",
        "url": "/users/123"
      },
      {
        "id": "update_user",
        "method": "PUT",
        "url": "/users/123",
        "body": {"name": "Alice Updated"}
      }
    ]
  }'
```

Response:

```json
{
  "status": "SUCCESS",
  "http_status": 200,
  "responses": [
    {
      "id": "create_user",
      "status": 201,
      "body": {
        "id": 1703512345000,
        "name": "Alice",
        "email": "alice@example.com"
      }
    },
    {
      "id": "get_user",
      "status": 200,
      "body": {
        "id": "123",
        "name": "User 123",
        "email": "user123@example.com"
      }
    },
    {
      "id": "update_user",
      "status": 200,
      "body": {
        "id": "123",
        "name": "Alice Updated"
      }
    }
  ],
  "summary": {
    "total": 3,
    "succeeded": 3,
    "failed": 0
  }
}
```

**Conclusion:**

Batch processing is a powerful API design pattern that significantly improves performance and efficiency for operations involving multiple requests. By consolidating operations into single requests, batch processing reduces network overhead, improves latency, and enables better resource utilization.

The pattern requires careful consideration of request/response structure, error handling strategies, dependency management, transaction semantics, and security implications. Proper implementation with clear documentation, comprehensive error reporting, and appropriate size limits ensures that batch APIs remain reliable and maintainable.

[Inference] When designed thoughtfully, batch processing can transform the performance characteristics of an API, particularly for mobile applications, microservices architectures, and bulk data operations where network efficiency is critical.

**Next Steps:**

1. Evaluate whether your API would benefit from batch processing based on usage patterns
2. Design a batch request/response format appropriate for your use cases
3. Implement dependency management if operations have interdependencies
4. Add comprehensive error handling with partial success support
5. Establish appropriate size limits and timeout values
6. Implement monitoring and observability for batch operations
7. Document the batch API thoroughly with examples and limitations
8. Test thoroughly including failure scenarios and edge cases
9. Consider async processing for very large batches
10. Gather feedback from API consumers and iterate on the design

---

## Idempotency Patterns

Idempotency is a critical property in distributed systems where an operation can be applied multiple times without changing the result beyond the initial application. In API design, idempotent operations ensure that duplicate requests—whether caused by network retries, client errors, or system failures—produce the same outcome as a single request.

### Understanding Idempotency

An idempotent operation satisfies the property: `f(f(x)) = f(x)`. This means executing the operation once or multiple times yields the same result. This property is essential for building reliable, fault-tolerant systems that can handle:

- Network timeouts and retries
- Client-side failures during request submission
- Duplicate message delivery in message queues
- Load balancer retries
- User-initiated duplicate actions (double-clicks, page refreshes)

### HTTP Methods and Idempotency

HTTP methods have inherent idempotency characteristics:

**Naturally Idempotent:**

- `GET` - Reading data multiple times doesn't change state
- `PUT` - Replacing a resource with the same data yields the same result
- `DELETE` - Deleting an already-deleted resource results in the same state
- `HEAD`, `OPTIONS`, `TRACE` - Safe, read-only operations

**Not Naturally Idempotent:**

- `POST` - Each request typically creates a new resource
- `PATCH` - Partial updates may produce different results on repetition

### Common Idempotency Patterns

#### 1. Idempotency Keys

The most widely-used pattern for making non-idempotent operations idempotent. Clients generate a unique key for each logical operation and include it in the request.

**Implementation:**

- Client generates a unique idempotency key (UUID, ULID, or similar)
- Key is sent in a custom header (e.g., `Idempotency-Key`)
- Server stores the key with the operation result
- Subsequent requests with the same key return the cached result

**Key Points:**

- Keys should be unique per logical operation, not per request
- Keys typically expire after a reasonable time window (24 hours is common)
- Storage mechanism must be fast and reliable (Redis, database with proper indexing)
- Failed requests should not permanently consume idempotency keys

**Example:**

```http
POST /api/payments HTTP/1.1
Host: api.example.com
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
Content-Type: application/json

{
  "amount": 1000,
  "currency": "USD",
  "recipient": "user@example.com"
}
```

Server-side pseudocode:

```python
def create_payment(request):
    idempotency_key = request.headers.get('Idempotency-Key')
    
    if not idempotency_key:
        return error("Idempotency-Key required", 400)
    
    # Check if we've seen this key before
    cached_result = cache.get(f"idempotency:{idempotency_key}")
    if cached_result:
        return cached_result
    
    # Process the payment
    try:
        result = process_payment(request.body)
        # Store result with expiration
        cache.set(f"idempotency:{idempotency_key}", result, expire=86400)
        return result
    except Exception as e:
        # Don't cache failures - allow retry
        return error(str(e), 500)
```

#### 2. Natural Keys

Using business-specific unique identifiers instead of generated keys. The resource itself has a natural unique identifier that prevents duplicates.

**Example:**

```http
PUT /api/users/john.doe@example.com HTTP/1.1
Content-Type: application/json

{
  "name": "John Doe",
  "preferences": {"theme": "dark"}
}
```

The email address serves as a natural idempotency key. Multiple PUTs with the same email update the same user.

#### 3. Token-Based Idempotency

Generate a token before the actual operation, use it to ensure single execution.

**Flow:**

1. Client requests an operation token: `POST /api/tokens/create-payment`
2. Server returns a unique token: `{"token": "tok_abc123"}`
3. Client submits operation with token: `POST /api/payments?token=tok_abc123`
4. Server validates token hasn't been used, processes request, marks token as consumed

**Key Points:**

- Tokens are single-use by design
- Requires two round trips but provides strong guarantees
- Useful when operations are expensive or have side effects
- Token generation can encode permissions and validations

#### 4. Conditional Requests

Use HTTP conditional headers to ensure operations only execute when conditions are met.

**ETags for Updates:**

```http
PUT /api/resources/123 HTTP/1.1
If-Match: "686897696a7c876b7e"
Content-Type: application/json

{
  "status": "completed"
}
```

The server only processes the update if the resource's current ETag matches. This prevents lost updates and provides idempotency.

**Last-Modified for Time-Based Conditions:**

```http
DELETE /api/resources/123 HTTP/1.1
If-Unmodified-Since: Wed, 21 Oct 2024 07:28:00 GMT
```

#### 5. Database Constraints

Leverage database-level uniqueness constraints to enforce idempotency.

**Example:**

```sql
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    idempotency_key VARCHAR(255) UNIQUE NOT NULL,
    amount DECIMAL(10,2),
    recipient VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);
```

Attempting to insert a duplicate idempotency_key will fail with a constraint violation, which the application catches and returns the existing record.

**Key Points:**

- Database handles deduplication atomically
- Works well with transactions
- Constraint violations indicate duplicate requests
- Requires proper error handling to distinguish duplicates from actual errors

#### 6. State Machine Enforcement

Design operations as state transitions with guards that prevent invalid transitions.

**Example:**

```python
class OrderStateMachine:
    TRANSITIONS = {
        'pending': ['processing', 'cancelled'],
        'processing': ['completed', 'failed'],
        'completed': [],
        'failed': ['pending'],
        'cancelled': []
    }
    
    def transition(self, order_id, to_state):
        order = get_order(order_id)
        current_state = order.status
        
        if to_state not in self.TRANSITIONS[current_state]:
            # Already in target state or invalid transition
            if current_state == to_state:
                return order  # Idempotent: already there
            else:
                raise InvalidTransitionError()
        
        order.status = to_state
        order.save()
        return order
```

Multiple attempts to transition to the same state are idempotent—once the state is reached, further attempts have no effect.

#### 7. Versioning

Include version numbers with requests to ensure operations apply to expected state.

**Example:**

```http
PATCH /api/documents/456 HTTP/1.1
Content-Type: application/json

{
  "version": 5,
  "changes": {
    "title": "Updated Title"
  }
}
```

Server checks if current version matches. If not, request is rejected. This ensures the client is operating on the expected state.

### Implementation Considerations

#### Storage Selection

**In-Memory Cache (Redis, Memcached):**

- Fast lookups (sub-millisecond)
- Built-in expiration
- Suitable for high-throughput APIs
- [Inference] May lose data on cache failure, requiring fallback strategy

**Database:**

- Persistent storage
- Transaction support
- Slower than cache but more reliable
- Good for critical operations requiring audit trails

**Hybrid Approach:**

- Check cache first (fast path)
- Fall back to database (slow path)
- Write to both for redundancy

#### Key Generation

**Client-Generated Keys:**

- UUIDs (RFC 4122)
- ULIDs (Universally Unique Lexicographically Sortable Identifiers)
- Client-controlled, no extra round trip
- Client must ensure uniqueness per operation

**Server-Generated Keys:**

- Token endpoint provides keys
- Server controls uniqueness
- Extra round trip required
- Can embed permissions and validations

#### Expiration Strategy

**Time-Based Expiration:**

- Keys expire after fixed duration (24 hours common)
- Balances storage costs with reliability
- Choose duration based on: maximum expected retry window, client timeout configuration, business requirements

**Explicit Cleanup:**

- Client confirms operation completion
- Server can immediately clean up key
- Reduces storage requirements
- Requires additional endpoint

#### Failure Handling

**Transient Failures:**

- Network timeouts
- Temporary service unavailability
- Don't consume idempotency key
- Allow client to retry

**Permanent Failures:**

- Validation errors
- Business rule violations
- Cache result (with error) to prevent retries
- Return same error on subsequent requests

**Partial Failures:**

- Operation started but completion uncertain
- Store intermediate state
- On retry, check state and resume or return result
- [Inference] May require implementing saga pattern for complex multi-step operations

### Response Design

Idempotent endpoints should return consistent responses:

**Status Codes:**

- First request: `201 Created` or `200 OK`
- Duplicate requests: `200 OK` (not `201`)
- Include `Idempotent-Replayed: true` header for duplicates

**Response Body:**

- Return same resource representation
- Include timestamps (created_at, updated_at)
- May include metadata indicating duplication

**Example:**

First request:

```http
HTTP/1.1 201 Created
Location: /api/payments/pay_123
Content-Type: application/json

{
  "id": "pay_123",
  "amount": 1000,
  "status": "completed",
  "created_at": "2024-10-21T10:30:00Z"
}
```

Duplicate request:

```http
HTTP/1.1 200 OK
Idempotent-Replayed: true
Content-Type: application/json

{
  "id": "pay_123",
  "amount": 1000,
  "status": "completed",
  "created_at": "2024-10-21T10:30:00Z"
}
```

### Testing Idempotency

#### Unit Tests

Test that operations produce identical results when repeated:

```python
def test_idempotent_payment():
    idempotency_key = "test-key-123"
    
    # First request
    result1 = create_payment(amount=100, key=idempotency_key)
    
    # Duplicate request
    result2 = create_payment(amount=100, key=idempotency_key)
    
    assert result1.id == result2.id
    assert result1.amount == result2.amount
    
    # Verify only one payment was created
    assert Payment.count(key=idempotency_key) == 1
```

#### Integration Tests

Simulate real-world retry scenarios:

```python
def test_payment_with_network_retry():
    idempotency_key = "test-key-456"
    
    # Simulate timeout on first request
    with mock.patch('requests.post', side_effect=Timeout):
        try:
            create_payment(amount=100, key=idempotency_key)
        except Timeout:
            pass
    
    # Retry succeeds
    result = create_payment(amount=100, key=idempotency_key)
    
    assert result.status == "completed"
    assert Payment.count(key=idempotency_key) == 1
```

#### Chaos Testing

Introduce failures to verify robustness:

- Random network delays and timeouts
- Cache failures during operation
- Concurrent duplicate requests
- Partial system failures

### Real-World Examples

#### Stripe API

Stripe requires idempotency keys for POST requests:

```bash
curl https://api.stripe.com/v1/charges \
  -u sk_test_key: \
  -H "Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000" \
  -d amount=2000 \
  -d currency=usd \
  -d source=tok_visa
```

Keys are valid for 24 hours. Duplicate requests return cached results with a 200 status code.

#### AWS API

AWS APIs use idempotency tokens for operations that create resources:

```bash
aws ec2 run-instances \
  --image-id ami-abc12345 \
  --instance-type t2.micro \
  --client-token my-unique-token-123
```

The client-token ensures multiple calls don't create multiple instances.

#### PayPal

PayPal uses PayPal-Request-Id header:

```http
POST /v2/payments/captures HTTP/1.1
Host: api.paypal.com
PayPal-Request-Id: 7b92603e-77ed-4896-8e78-5dea2050476a
Content-Type: application/json

{
  "amount": {
    "currency_code": "USD",
    "value": "100.00"
  }
}
```

### Anti-Patterns

#### Timestamp-Based Keys

**Problem:**

```http
Idempotency-Key: 2024-10-21T10:30:00Z
```

Timestamps are not unique enough. Multiple operations within the same second or millisecond will collide.

**Solution:** Use UUIDs or ULIDs that guarantee uniqueness.

#### Operation-Type-Only Keys

**Problem:**

```http
Idempotency-Key: create-payment
```

Using the same key for all operations of a type defeats the purpose. All payment creations would be treated as duplicates.

**Solution:** Keys must be unique per logical operation, not per operation type.

#### Infinite Key Retention

**Problem:** Storing idempotency keys forever consumes unbounded storage and degrades lookup performance.

**Solution:** Implement reasonable expiration (24-72 hours) based on maximum expected retry window.

#### Ignoring Business Context

**Problem:** Treating all retry attempts as duplicates, even when business parameters differ:

```python
# Wrong: Same key, different amounts
create_payment(amount=100, key="key-123")
create_payment(amount=200, key="key-123")  # Returns 100, not 200
```

**Solution:** Validate that request parameters match cached operation, or include business parameters in key generation.

#### No Partial Failure Handling

**Problem:** Complex operations fail midway, leaving system in inconsistent state. Retry starts from beginning, causing duplicates of completed sub-operations.

**Solution:** [Inference] Implement saga pattern or checkpoint mechanism to track progress and resume from failure point.

### Performance Optimization

#### Key Lookup Optimization

**Indexing:**

```sql
CREATE INDEX idx_idempotency_key ON operations(idempotency_key);
CREATE INDEX idx_idempotency_expires ON operations(expires_at) 
  WHERE expires_at IS NOT NULL;
```

**Sharding:** Distribute idempotency keys across multiple cache instances based on key hash.

#### Async Processing

For expensive operations, return immediately with operation status:

```python
def create_payment(request):
    idempotency_key = request.headers.get('Idempotency-Key')
    
    # Check cache
    cached = cache.get(f"idempotency:{idempotency_key}")
    if cached:
        return cached
    
    # Create operation record
    operation = Operation.create(
        key=idempotency_key,
        status='pending',
        params=request.body
    )
    
    # Queue for async processing
    queue.enqueue(process_payment, operation.id)
    
    # Return immediately
    result = {
        'id': operation.id,
        'status': 'pending',
        'check_status_url': f'/api/operations/{operation.id}'
    }
    
    cache.set(f"idempotency:{idempotency_key}", result, expire=86400)
    return result, 202
```

Client polls status endpoint until completion.

#### Batch Operations

For high-throughput systems, batch idempotency checks:

```python
def batch_create(requests):
    keys = [r.headers.get('Idempotency-Key') for r in requests]
    
    # Single cache query for all keys
    cached_results = cache.get_multi([f"idempotency:{k}" for k in keys])
    
    # Process only uncached requests
    new_requests = [r for r in requests 
                   if f"idempotency:{r.key}" not in cached_results]
    
    results = process_batch(new_requests)
    
    # Batch cache writes
    cache.set_multi({
        f"idempotency:{r.key}": result 
        for r, result in zip(new_requests, results)
    })
    
    return merge_results(cached_results, results)
```

### Monitoring and Observability

Track key metrics:

**Idempotency Key Reuse Rate:**

```
reuse_rate = (duplicate_requests / total_requests) * 100
```

High rates may indicate client retry logic issues or network problems.

**Cache Hit Rate:**

```
cache_hit_rate = (cache_hits / total_lookups) * 100
```

Low rates suggest cache sizing or expiration issues.

**Operation Latency:**

- First request latency (full processing)
- Duplicate request latency (cache lookup only)
- Large difference indicates effective caching

**Failed Operations:**

- Transient failures (should allow retry)
- Permanent failures (cached to prevent retry)
- Partial failures (may need manual intervention)

**Example Monitoring:**

```python
from prometheus_client import Counter, Histogram

idempotency_requests = Counter(
    'idempotency_requests_total',
    'Total idempotent requests',
    ['endpoint', 'is_duplicate']
)

idempotency_latency = Histogram(
    'idempotency_request_duration_seconds',
    'Idempotent request latency',
    ['endpoint', 'is_duplicate']
)

def create_payment(request):
    idempotency_key = request.headers.get('Idempotency-Key')
    start_time = time.time()
    
    cached = cache.get(f"idempotency:{idempotency_key}")
    is_duplicate = cached is not None
    
    if cached:
        idempotency_requests.labels(
            endpoint='create_payment',
            is_duplicate='true'
        ).inc()
    else:
        result = process_payment(request.body)
        cache.set(f"idempotency:{idempotency_key}", result)
        idempotency_requests.labels(
            endpoint='create_payment',
            is_duplicate='false'
        ).inc()
    
    latency = time.time() - start_time
    idempotency_latency.labels(
        endpoint='create_payment',
        is_duplicate=str(is_duplicate).lower()
    ).observe(latency)
    
    return result
```

### Security Considerations

#### Key Predictability

**Problem:** Sequential or predictable keys allow attackers to replay legitimate requests:

```
Idempotency-Key: 1
Idempotency-Key: 2
Idempotency-Key: 3
```

**Solution:** Use cryptographically secure random values (UUIDs, random strings).

#### Key Enumeration

**Problem:** Attackers probe for valid keys to discover ongoing operations.

**Solution:**

- Rate limit idempotency key lookups
- Don't expose whether a key exists in error messages
- Use authentication to tie keys to users

#### Authorization

Verify that the user retrying a request is authorized to access the original operation:

```python
def create_payment(request):
    idempotency_key = request.headers.get('Idempotency-Key')
    user_id = get_authenticated_user(request)
    
    cached = cache.get(f"idempotency:{idempotency_key}")
    if cached:
        # Verify same user
        if cached.user_id != user_id:
            return error("Unauthorized", 403)
        return cached
    
    # Process new request
    result = process_payment(request.body, user_id)
    cache.set(f"idempotency:{idempotency_key}", result)
    return result
```

#### Replay Attacks

**Problem:** Attacker captures idempotency key and original request, replays to get cached result without authorization.

**Solution:**

- Include authentication token in cache key
- Verify authorization on every request, even cache hits
- Use short expiration windows
- Consider IP-based or device-based validation for sensitive operations

**Conclusion:** Idempotency patterns are essential for building reliable distributed systems and APIs. By implementing proper idempotency mechanisms—whether through idempotency keys, natural keys, conditional requests, or database constraints—systems can gracefully handle retries, network failures, and duplicate requests without creating inconsistent state or duplicate side effects. The choice of pattern depends on the specific use case, performance requirements, and consistency guarantees needed. Proper implementation includes careful consideration of storage mechanisms, key generation strategies, failure handling, security, and monitoring to ensure robust operation in production environments.

---

## Webhook Patterns

Webhook patterns are architectural approaches for implementing event-driven communication where a system sends HTTP callbacks to registered endpoints when specific events occur. Rather than clients continuously polling for updates, webhooks enable servers to push data to clients in real-time, creating efficient, scalable event notification systems.

### Core Webhook Architecture

A webhook system consists of three fundamental components: the event source (producer), the webhook delivery mechanism, and the subscriber (consumer). When an event occurs in the producer system, it triggers an HTTP POST request to pre-registered URLs, delivering event data as JSON or XML payloads. This inverts the traditional request-response model, allowing servers to initiate communication with clients.

The basic flow involves registration, event detection, payload construction, delivery, and acknowledgment. Subscribers register their callback URLs with the producer system, often including filtering criteria for specific event types. When relevant events occur, the producer constructs a payload containing event data and metadata, then sends it to all registered endpoints.

### Pattern Variations

#### Fan-Out Pattern

The fan-out pattern broadcasts a single event to multiple subscribers simultaneously. When an event occurs, the webhook system delivers notifications to all registered endpoints in parallel. This pattern suits scenarios where multiple systems need to react to the same event independently.

**Key Points:**

- Parallel delivery to multiple endpoints
- Independent processing by each subscriber
- No coordination required between subscribers
- Potential for partial failures affecting some subscribers

**Example:** When a payment completes, the webhook fires to the inventory system, shipping service, analytics platform, and email notification service simultaneously.

#### Filter Pattern

Subscribers register webhooks with specific filter criteria, receiving only events matching their conditions. The producer evaluates filters before delivery, reducing unnecessary traffic and processing on the subscriber side.

**Key Points:**

- Event-type filtering (e.g., only "order.completed" events)
- Attribute-based filtering (e.g., orders over $1000)
- Reduces bandwidth and processing overhead
- Filter evaluation occurs on producer side

**Example:** An analytics service registers for "order.completed" events where `order.total > 1000`, while a fraud detection service subscribes to all "payment.failed" events.

#### Retry Pattern

The retry pattern handles temporary failures in webhook delivery through exponential backoff and configurable retry policies. When a delivery fails (non-2xx response or timeout), the system schedules retries with increasing delays.

**Key Points:**

- Exponential backoff (e.g., 1min, 5min, 15min, 1hour)
- Maximum retry attempts configuration
- Dead letter queue for permanently failed deliveries
- Idempotency tokens to prevent duplicate processing

**Example:**

```
Attempt 1: Immediate delivery - fails (500 error)
Attempt 2: After 1 minute - fails (timeout)
Attempt 3: After 5 minutes - fails (503 error)
Attempt 4: After 15 minutes - succeeds (200 OK)
```

#### Circuit Breaker Pattern

When a subscriber endpoint repeatedly fails, the circuit breaker pattern temporarily stops delivery attempts to prevent resource waste and allow the failing system to recover. After a cooldown period, the circuit attempts delivery again.

**Key Points:**

- Tracks failure rates per endpoint
- Opens circuit after threshold failures
- Prevents cascading failures
- Automatic recovery attempts after timeout

**Example:** After 5 consecutive failures to `https://subscriber.example.com/webhook`, the circuit opens for 30 minutes. During this period, events are queued but not delivered. After 30 minutes, one delivery is attempted to test endpoint health.

### Security Patterns

#### Signature Verification Pattern

Producers sign webhook payloads using HMAC-SHA256 with a shared secret, allowing subscribers to verify payload authenticity and integrity. The signature is typically sent in a custom HTTP header.

**Key Points:**

- HMAC-SHA256 signature of request body
- Shared secret established during registration
- Signature sent in header (e.g., `X-Webhook-Signature`)
- Prevents tampering and replay attacks

**Example:**

```
Request Headers:
X-Webhook-Signature: sha256=5d7e8f9a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9

Verification (pseudocode):
expected_signature = hmac_sha256(secret, request_body)
if constant_time_compare(expected_signature, received_signature):
    process_webhook()
else:
    reject_request()
```

#### Timestamp Validation Pattern

Including timestamps in webhook payloads prevents replay attacks by allowing subscribers to reject old requests. Signatures typically include the timestamp to prevent tampering.

**Key Points:**

- Timestamp in payload or header
- Subscriber validates timestamp freshness (e.g., within 5 minutes)
- Combined with signature for tamper-resistance
- Protects against replay attacks

#### IP Allowlist Pattern

Subscribers restrict webhook acceptance to known producer IP ranges, providing an additional security layer alongside signature verification.

**Key Points:**

- Maintains list of authorized IP addresses/ranges
- Validates source IP before processing
- Defense-in-depth approach
- Requires stable producer IPs or frequent allowlist updates

### Delivery Guarantee Patterns

#### At-Least-Once Delivery

The producer guarantees event delivery but may send duplicates during failure scenarios. Subscribers must implement idempotent processing to handle duplicate events safely.

**Key Points:**

- Events may be delivered multiple times
- Idempotency tokens identify duplicate deliveries
- Subscribers must handle duplicates gracefully
- Simpler producer implementation

**Example:** An order completion webhook includes `idempotency_key: "order-123-completed-20231215"`. The subscriber checks if this key was previously processed before applying the event.

#### At-Most-Once Delivery

The producer attempts delivery once without retries, accepting potential message loss. This pattern suits non-critical notifications where occasional loss is acceptable.

**Key Points:**

- Single delivery attempt
- No retry mechanism
- Lower resource consumption
- Acceptable for non-critical events

#### Exactly-Once Delivery

[Inference] True exactly-once delivery across distributed systems is theoretically challenging. Practical implementations combine at-least-once delivery with idempotent subscribers, creating effectively-exactly-once semantics. The producer ensures delivery, while the subscriber ensures single processing through deduplication.

### Scalability Patterns

#### Queue-Based Delivery Pattern

Webhook events are placed in a message queue before delivery, decoupling event production from delivery. Worker processes consume from the queue, enabling horizontal scaling of delivery infrastructure.

**Key Points:**

- Asynchronous event processing
- Buffering during traffic spikes
- Independent scaling of producers and delivery workers
- Persistence for durability

**Example:** When a payment completes, the event is immediately written to a Redis queue. Multiple worker processes consume from the queue, delivering webhooks to subscribers. If subscribers are temporarily slow, events accumulate in the queue without blocking payment processing.

#### Rate Limiting Pattern

Controls delivery rate to individual subscribers, preventing overload and ensuring fair resource distribution. Rate limits can be per-subscriber, global, or based on subscription tiers.

**Key Points:**

- Token bucket or sliding window algorithms
- Per-subscriber quotas
- Graceful degradation under load
- Prevents subscriber overload

#### Batch Delivery Pattern

Multiple events are aggregated into a single webhook request, reducing HTTP overhead and subscriber processing load. Batches are sent when size or time thresholds are reached.

**Key Points:**

- Reduces HTTP connection overhead
- Lower subscriber processing cost
- Configurable batch size and timeout
- Trade-off between latency and efficiency

**Example:** Instead of 100 individual webhook calls for 100 user registrations per minute, the system sends 5 webhook requests with 20 events each, reducing overhead by 95%.

### Monitoring and Observability Patterns

#### Delivery Status Tracking

Maintaining detailed records of webhook delivery attempts, responses, and failures enables debugging and system health monitoring.

**Key Points:**

- Logs for each delivery attempt
- Response codes and bodies
- Delivery latency metrics
- Failure categorization

#### Dead Letter Queue Pattern

Failed webhooks that exceed retry limits are moved to a dead letter queue for manual investigation or alternative processing, preventing data loss while avoiding infinite retries.

**Key Points:**

- Permanent storage for failed deliveries
- Manual review and reprocessing capability
- Alerting on dead letter accumulation
- Audit trail for problematic events

#### Health Check Pattern

Subscribers expose health check endpoints allowing producers to verify endpoint availability before registering or as part of circuit breaker recovery.

**Key Points:**

- Dedicated health check endpoint
- Lightweight response (200 OK)
- Used during registration validation
- Circuit breaker recovery testing

### Payload Patterns

#### Full Resource Pattern

The webhook payload contains the complete resource state after the event, eliminating the need for subscribers to make additional API calls.

**Key Points:**

- Self-contained payload
- Reduces API load
- Larger payload size
- Immediate data availability

**Example:**

```json
{
  "event": "order.completed",
  "timestamp": "2024-12-26T10:30:00Z",
  "data": {
    "order_id": "ord_12345",
    "customer": {
      "id": "cus_67890",
      "email": "customer@example.com",
      "name": "Jane Smith"
    },
    "items": [...],
    "total": 199.99,
    "status": "completed"
  }
}
```

#### Reference Pattern

The payload contains minimal data with a reference URL, requiring subscribers to fetch complete details via API if needed. This reduces payload size and provides flexibility for subscribers needing different data levels.

**Key Points:**

- Minimal payload size
- Subscribers control data fetching
- Reduces bandwidth for disinterested subscribers
- Requires API availability

**Example:**

```json
{
  "event": "order.completed",
  "timestamp": "2024-12-26T10:30:00Z",
  "data": {
    "order_id": "ord_12345",
    "url": "https://api.example.com/orders/ord_12345"
  }
}
```

#### Hybrid Pattern

The payload includes essential data plus a reference URL for complete details, balancing immediate availability with flexibility.

**Key Points:**

- Common fields in payload
- URL for additional details
- Balances size and convenience
- Reduces unnecessary API calls

### Subscription Management Patterns

#### Self-Service Registration

Subscribers register webhooks through an API or web interface, providing their endpoint URL, event filters, and authentication details. This enables automated integration without manual coordination.

**Key Points:**

- API-driven registration
- Immediate activation
- Subscriber-controlled configuration
- Automated validation

**Example:**

```
POST /webhooks/subscriptions
{
  "url": "https://subscriber.example.com/hooks",
  "events": ["order.completed", "order.refunded"],
  "secret": "whsec_8KfT9..."
}
```

#### Verification Challenge Pattern

Before activating a webhook subscription, the producer sends a verification challenge to the endpoint. The subscriber must respond correctly to prove endpoint control.

**Key Points:**

- Prevents unauthorized subscriptions
- Challenge-response verification
- Protects against malicious registrations
- Used by GitHub, Stripe, others

**Example:**

```
Producer sends:
POST https://subscriber.example.com/hooks
{
  "type": "verification",
  "challenge": "3z4f7k2m9p"
}

Subscriber must respond:
200 OK
{
  "challenge": "3z4f7k2m9p"
}
```

#### Subscription Expiry Pattern

Subscriptions automatically expire after a configured period unless renewed, preventing orphaned webhooks to abandoned endpoints.

**Key Points:**

- Time-limited subscriptions
- Renewal mechanism
- Automatic cleanup
- Reduces zombie endpoints

### Error Handling and Recovery

#### Graceful Degradation Pattern

When webhook delivery fails, the system falls back to alternative notification mechanisms or queues events for later processing, ensuring critical data isn't lost.

**Key Points:**

- Fallback notification channels (email, SMS)
- Event storage for delayed processing
- User notification of delivery issues
- Maintains data integrity

#### Poison Message Handling

Events that consistently fail validation or processing are identified and isolated to prevent blocking the delivery pipeline. These "poison" messages receive special handling.

**Key Points:**

- Detection of repeatedly failing events
- Isolation from normal pipeline
- Manual inspection capability
- Prevents pipeline blockage

### Advanced Patterns

#### Webhook Chaining Pattern

A webhook receiver processes an event and triggers additional webhooks to downstream systems, creating event propagation chains. This enables complex workflows across multiple systems.

**Key Points:**

- Events cascade through multiple systems
- Each system adds processing
- Enables workflow orchestration
- Requires careful error handling

**Example:** Order completion webhook → Inventory system (updates stock) → Triggers shipping webhook → Shipping provider → Triggers tracking webhook → Customer notification system

#### Webhook Aggregation Pattern

A service subscribes to webhooks from multiple sources and provides unified webhook delivery to downstream subscribers, normalizing formats and reducing integration complexity.

**Key Points:**

- Single subscription point for consumers
- Format normalization across sources
- Event enrichment and filtering
- Simplifies multi-source integration

#### Bidirectional Webhook Pattern

Both parties in an integration relationship send webhooks to each other, enabling true bidirectional event-driven communication. This creates symmetric integration architecture.

**Key Points:**

- Mutual event notification
- Symmetric relationship
- Real-time synchronization
- Requires both parties to implement webhooks

### Testing Patterns

#### Webhook Simulation

Development and testing environments use webhook simulation tools to generate test events without requiring full system integration.

**Key Points:**

- Controllable test event generation
- No dependency on production systems
- Repeatable testing scenarios
- Edge case validation

#### Replay Capability

The system stores webhook payloads and allows manual replay for testing, debugging, or recovery after subscriber fixes.

**Key Points:**

- Payload persistence
- Selective replay
- Debugging support
- Recovery after fixes

**Example:** After fixing a bug in the webhook handler, a developer replays the last 24 hours of "order.completed" events to process previously failed orders.

### Implementation Considerations

When implementing webhook patterns, consider delivery guarantees, security requirements, scalability needs, and monitoring capabilities. Choose at-least-once delivery with idempotent subscribers for critical events, implement signature verification for security, use queue-based delivery for scale, and maintain comprehensive delivery logs for observability.

Subscriber implementations should validate signatures, handle duplicates idempotently, respond quickly (within 5 seconds), process asynchronously, and implement exponential backoff for API calls back to the producer.

Producer implementations should queue events before delivery, implement retry logic with exponential backoff, monitor delivery success rates, provide subscription management APIs, and document payload schemas clearly.

**Conclusion:**

Webhook patterns provide powerful tools for building event-driven architectures with real-time data synchronization across distributed systems. By combining appropriate patterns—such as retry logic, signature verification, queue-based delivery, and idempotent processing—systems achieve reliable, secure, and scalable webhook implementations. The specific patterns chosen depend on requirements around delivery guarantees, security constraints, scalability needs, and operational complexity tolerance. Modern webhook systems typically implement multiple patterns in combination, creating robust event notification infrastructure that balances reliability, performance, and maintainability.

---

## GraphQL API Design Patterns

GraphQL is a query language and runtime for APIs that provides a complete and understandable description of the data in your API, gives clients the power to ask for exactly what they need, and enables powerful developer tools. Understanding GraphQL-specific patterns helps build efficient, maintainable, and scalable APIs.

### Schema-First Design

Schema-first design involves defining your GraphQL schema before implementing resolvers. This approach ensures that the API contract is clear and serves as documentation for both frontend and backend teams.

The schema acts as a single source of truth, defining types, queries, mutations, and subscriptions. This pattern promotes better collaboration between teams and catches design issues early in development.

**Key Points:**

- Define the complete schema before writing resolver logic
- Use schema as the contract between client and server
- Validate business requirements against the schema design
- Enable parallel development of client and server

**Example:**

```graphql
# Schema Definition
type User {
  id: ID!
  username: String!
  email: String!
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  comments: [Comment!]!
  publishedAt: DateTime
}

type Query {
  user(id: ID!): User
  posts(limit: Int, offset: Int): [Post!]!
}

type Mutation {
  createPost(input: CreatePostInput!): Post!
  updatePost(id: ID!, input: UpdatePostInput!): Post!
}
```

### Resolver Pattern

Resolvers are functions that populate data for fields in your GraphQL schema. The resolver pattern involves organizing resolver logic to handle field-level data fetching efficiently.

Each field in your schema can have its own resolver function. GraphQL executes resolvers in a specific order, starting from the root query and traversing down the tree structure.

**Key Points:**

- Each resolver receives four arguments: parent, args, context, info
- Resolvers can be async and return Promises
- Keep resolvers thin and delegate to service layers
- Use the parent argument to access data from parent resolvers

**Example:**

```javascript
const resolvers = {
  Query: {
    user: async (parent, { id }, context) => {
      return context.dataSources.userAPI.getUserById(id);
    },
    posts: async (parent, { limit, offset }, context) => {
      return context.dataSources.postAPI.getPosts(limit, offset);
    }
  },
  
  User: {
    posts: async (parent, args, context) => {
      // parent contains the User object from the parent resolver
      return context.dataSources.postAPI.getPostsByUserId(parent.id);
    }
  },
  
  Post: {
    author: async (parent, args, context) => {
      return context.dataSources.userAPI.getUserById(parent.authorId);
    },
    comments: async (parent, args, context) => {
      return context.dataSources.commentAPI.getCommentsByPostId(parent.id);
    }
  },
  
  Mutation: {
    createPost: async (parent, { input }, context) => {
      const { userId, title, content } = input;
      return context.dataSources.postAPI.createPost(userId, title, content);
    }
  }
};
```

### DataLoader Pattern (Batching and Caching)

DataLoader is a utility that addresses the N+1 query problem through batching and caching. It collects individual data requests and batches them into a single database query.

This pattern significantly improves performance when resolving nested relationships in GraphQL queries by reducing the number of database calls.

**Key Points:**

- Batch multiple requests into single database queries
- Automatic per-request caching to avoid duplicate fetches
- Reduces N+1 query problems common in GraphQL
- Create DataLoader instances per-request to avoid caching across requests

**Example:**

```javascript
const DataLoader = require('dataloader');

// Create a batch loading function
const batchUsers = async (userIds) => {
  // Fetch all users in a single query
  const users = await db.users.findByIds(userIds);
  
  // Return users in the same order as requested IDs
  return userIds.map(id => users.find(user => user.id === id));
};

// Create DataLoader instance per request
const createLoaders = () => ({
  userLoader: new DataLoader(batchUsers)
});

// In your GraphQL context
const context = ({ req }) => ({
  loaders: createLoaders(),
  user: req.user
});

// In resolvers
const resolvers = {
  Post: {
    author: async (parent, args, { loaders }) => {
      // Multiple posts requesting authors will be batched
      return loaders.userLoader.load(parent.authorId);
    }
  },
  
  Comment: {
    author: async (parent, args, { loaders }) => {
      // Reuses cached user data if already loaded
      return loaders.userLoader.load(parent.authorId);
    }
  }
};
```

**Output:**

```
// Without DataLoader (N+1 problem):
Query: SELECT * FROM posts LIMIT 10
Query: SELECT * FROM users WHERE id = 1
Query: SELECT * FROM users WHERE id = 2
Query: SELECT * FROM users WHERE id = 1  // Duplicate!
Query: SELECT * FROM users WHERE id = 3
... (10+ queries total)

// With DataLoader:
Query: SELECT * FROM posts LIMIT 10
Query: SELECT * FROM users WHERE id IN (1, 2, 3)  // Single batched query
... (2 queries total)
```

### Pagination Patterns

GraphQL supports multiple pagination patterns to handle large datasets efficiently. The most common are offset-based, cursor-based, and Relay-style connection patterns.

**Offset-Based Pagination:** Simple and intuitive, using limit and offset parameters. However, this pattern can have consistency issues with frequently changing data.

**Example:**

```graphql
type Query {
  posts(limit: Int!, offset: Int!): [Post!]!
  postsCount: Int!
}
```

```javascript
const resolvers = {
  Query: {
    posts: async (parent, { limit, offset }, context) => {
      return context.db.posts.find().limit(limit).skip(offset);
    },
    postsCount: async (parent, args, context) => {
      return context.db.posts.count();
    }
  }
};
```

**Cursor-Based Pagination:** More stable for dynamic datasets, using opaque cursors to mark positions.

**Example:**

```graphql
type PostConnection {
  edges: [PostEdge!]!
  pageInfo: PageInfo!
}

type PostEdge {
  cursor: String!
  node: Post!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

type Query {
  posts(first: Int, after: String, last: Int, before: String): PostConnection!
}
```

```javascript
const resolvers = {
  Query: {
    posts: async (parent, { first, after }, context) => {
      const limit = first || 10;
      const query = after 
        ? { createdAt: { $lt: decodeCursor(after) } }
        : {};
      
      const posts = await context.db.posts
        .find(query)
        .sort({ createdAt: -1 })
        .limit(limit + 1);
      
      const hasNextPage = posts.length > limit;
      const edges = posts.slice(0, limit).map(post => ({
        cursor: encodeCursor(post.createdAt),
        node: post
      }));
      
      return {
        edges,
        pageInfo: {
          hasNextPage,
          hasPreviousPage: !!after,
          startCursor: edges[0]?.cursor,
          endCursor: edges[edges.length - 1]?.cursor
        }
      };
    }
  }
};
```

### Input Object Pattern

Input objects provide a structured way to pass complex arguments to mutations and queries. This pattern improves API clarity and makes it easier to evolve your schema.

**Key Points:**

- Use input types for mutations with multiple arguments
- Separate input types from output types
- Enable easier schema evolution and validation
- Improve API documentation and client-side TypeScript generation

**Example:**

```graphql
input CreateUserInput {
  username: String!
  email: String!
  password: String!
  profile: ProfileInput
}

input ProfileInput {
  firstName: String
  lastName: String
  bio: String
  avatarUrl: String
}

input UpdateUserInput {
  username: String
  email: String
  profile: ProfileInput
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
}
```

```javascript
const resolvers = {
  Mutation: {
    createUser: async (parent, { input }, context) => {
      const { username, email, password, profile } = input;
      
      // Validate input
      await validateUserInput(input);
      
      // Hash password
      const hashedPassword = await hashPassword(password);
      
      // Create user with nested profile
      return context.db.users.create({
        username,
        email,
        password: hashedPassword,
        profile
      });
    },
    
    updateUser: async (parent, { id, input }, context) => {
      // Only update provided fields
      return context.db.users.update(id, input);
    }
  }
};
```

### Error Handling Pattern

GraphQL has a specific error structure that allows partial success responses. Proper error handling patterns help clients handle failures gracefully while still receiving valid data.

**Key Points:**

- Use GraphQL's built-in error system for operational errors
- Return partial data when possible
- Create custom error classes for different error types
- Include error codes and additional context
- Avoid exposing sensitive information in error messages

**Example:**

```javascript
// Custom error classes
class AuthenticationError extends Error {
  constructor(message) {
    super(message);
    this.code = 'UNAUTHENTICATED';
    this.statusCode = 401;
  }
}

class ValidationError extends Error {
  constructor(message, fields) {
    super(message);
    this.code = 'VALIDATION_ERROR';
    this.fields = fields;
  }
}

class NotFoundError extends Error {
  constructor(resource) {
    super(`${resource} not found`);
    this.code = 'NOT_FOUND';
    this.statusCode = 404;
  }
}

// In resolvers
const resolvers = {
  Query: {
    user: async (parent, { id }, context) => {
      if (!context.user) {
        throw new AuthenticationError('You must be logged in');
      }
      
      const user = await context.db.users.findById(id);
      
      if (!user) {
        throw new NotFoundError('User');
      }
      
      return user;
    }
  },
  
  Mutation: {
    createPost: async (parent, { input }, context) => {
      const errors = {};
      
      if (!input.title || input.title.length < 3) {
        errors.title = 'Title must be at least 3 characters';
      }
      
      if (!input.content || input.content.length < 10) {
        errors.content = 'Content must be at least 10 characters';
      }
      
      if (Object.keys(errors).length > 0) {
        throw new ValidationError('Invalid input', errors);
      }
      
      return context.db.posts.create(input);
    }
  }
};

// Error formatting
const formatError = (error) => {
  const { message, code, statusCode, fields, path, locations } = error;
  
  return {
    message,
    code: code || 'INTERNAL_SERVER_ERROR',
    statusCode: statusCode || 500,
    fields,
    path,
    locations
  };
};
```

**Output:**

```json
{
  "errors": [
    {
      "message": "Invalid input",
      "code": "VALIDATION_ERROR",
      "fields": {
        "title": "Title must be at least 3 characters",
        "content": "Content must be at least 10 characters"
      },
      "path": ["createPost"],
      "locations": [{ "line": 2, "column": 3 }]
    }
  ],
  "data": {
    "createPost": null
  }
}
```

### Authorization Pattern

Authorization in GraphQL can be implemented at multiple levels: schema-level, resolver-level, or field-level. The pattern you choose depends on your security requirements and complexity.

**Key Points:**

- Implement authorization in business logic layer, not just resolvers
- Use context to pass authenticated user information
- Consider field-level authorization for fine-grained control
- Use directive-based authorization for declarative security

**Example:**

```graphql
directive @auth(requires: Role = USER) on OBJECT | FIELD_DEFINITION

enum Role {
  USER
  ADMIN
  MODERATOR
}

type User @auth(requires: USER) {
  id: ID!
  username: String!
  email: String! @auth(requires: USER)  # Only user can see their own email
  posts: [Post!]!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  draft: Boolean! @auth(requires: ADMIN)  # Only admins see draft status
}

type Mutation {
  deleteUser(id: ID!): Boolean! @auth(requires: ADMIN)
  deletePost(id: ID!): Boolean! @auth(requires: MODERATOR)
}
```

```javascript
// Authorization directive implementation
class AuthDirective extends SchemaDirectiveVisitor {
  visitObject(type) {
    this.ensureFieldsWrapped(type);
    type._requiredRole = this.args.requires;
  }
  
  visitFieldDefinition(field, details) {
    this.ensureFieldsWrapped(details.objectType);
    field._requiredRole = this.args.requires;
  }
  
  ensureFieldsWrapped(objectType) {
    if (objectType._authFieldsWrapped) return;
    objectType._authFieldsWrapped = true;
    
    const fields = objectType.getFields();
    
    Object.keys(fields).forEach(fieldName => {
      const field = fields[fieldName];
      const { resolve = defaultFieldResolver } = field;
      
      field.resolve = async function(...args) {
        const requiredRole = field._requiredRole || objectType._requiredRole;
        
        if (!requiredRole) {
          return resolve.apply(this, args);
        }
        
        const context = args[2];
        
        if (!context.user) {
          throw new AuthenticationError('Not authenticated');
        }
        
        if (!hasRole(context.user, requiredRole)) {
          throw new AuthorizationError('Insufficient permissions');
        }
        
        return resolve.apply(this, args);
      };
    });
  }
}

// Helper function
const hasRole = (user, requiredRole) => {
  const roles = {
    USER: 1,
    MODERATOR: 2,
    ADMIN: 3
  };
  
  return roles[user.role] >= roles[requiredRole];
};

// Manual authorization in resolvers
const resolvers = {
  User: {
    email: (parent, args, context) => {
      // Users can only see their own email
      if (context.user.id !== parent.id && context.user.role !== 'ADMIN') {
        throw new AuthorizationError('Cannot view other users email');
      }
      return parent.email;
    }
  },
  
  Mutation: {
    deletePost: async (parent, { id }, context) => {
      const post = await context.db.posts.findById(id);
      
      // Author or moderator/admin can delete
      if (
        context.user.id !== post.authorId &&
        !['MODERATOR', 'ADMIN'].includes(context.user.role)
      ) {
        throw new AuthorizationError('Cannot delete this post');
      }
      
      await context.db.posts.delete(id);
      return true;
    }
  }
};
```

### Subscription Pattern

Subscriptions enable real-time updates from server to client using WebSockets or similar protocols. This pattern is useful for chat applications, live notifications, and collaborative features.

**Key Points:**

- Use subscriptions for real-time data updates
- Implement proper cleanup to prevent memory leaks
- Consider using PubSub for event-based subscriptions
- Filter subscription events based on user authorization

**Example:**

```graphql
type Subscription {
  postAdded(authorId: ID): Post!
  commentAdded(postId: ID!): Comment!
  userStatusChanged(userId: ID!): UserStatus!
}

type UserStatus {
  userId: ID!
  online: Boolean!
  lastSeen: DateTime
}
```

```javascript
const { PubSub } = require('graphql-subscriptions');
const pubsub = new PubSub();

// Event names
const POST_ADDED = 'POST_ADDED';
const COMMENT_ADDED = 'COMMENT_ADDED';
const USER_STATUS_CHANGED = 'USER_STATUS_CHANGED';

const resolvers = {
  Mutation: {
    createPost: async (parent, { input }, context) => {
      const post = await context.db.posts.create({
        ...input,
        authorId: context.user.id
      });
      
      // Publish event
      pubsub.publish(POST_ADDED, {
        postAdded: post,
        authorId: post.authorId
      });
      
      return post;
    },
    
    addComment: async (parent, { input }, context) => {
      const comment = await context.db.comments.create({
        ...input,
        authorId: context.user.id
      });
      
      pubsub.publish(COMMENT_ADDED, {
        commentAdded: comment,
        postId: comment.postId
      });
      
      return comment;
    }
  },
  
  Subscription: {
    postAdded: {
      subscribe: withFilter(
        () => pubsub.asyncIterator([POST_ADDED]),
        (payload, variables) => {
          // Filter: only send if no authorId specified or matches
          return !variables.authorId || 
                 payload.authorId === variables.authorId;
        }
      )
    },
    
    commentAdded: {
      subscribe: withFilter(
        () => pubsub.asyncIterator([COMMENT_ADDED]),
        (payload, variables) => {
          // Only send comments for specific post
          return payload.postId === variables.postId;
        }
      ),
      resolve: (payload) => payload.commentAdded
    },
    
    userStatusChanged: {
      subscribe: async (parent, { userId }, context) => {
        // Check authorization
        if (!context.user) {
          throw new AuthenticationError('Not authenticated');
        }
        
        return pubsub.asyncIterator([`${USER_STATUS_CHANGED}.${userId}`]);
      }
    }
  }
};

// Publish user status changes
const updateUserStatus = (userId, online) => {
  pubsub.publish(`${USER_STATUS_CHANGED}.${userId}`, {
    userStatusChanged: {
      userId,
      online,
      lastSeen: new Date()
    }
  });
};
```

### Query Complexity Analysis

Query complexity analysis prevents expensive queries from overwhelming your server by analyzing and limiting query depth, breadth, and computational cost.

**Key Points:**

- Prevent deeply nested queries that cause performance issues
- Assign complexity scores to fields based on computational cost
- Set maximum complexity limits per query
- Consider query depth and breadth limitations

**Example:**

```javascript
const { createComplexityLimitRule } = require('graphql-validation-complexity');

// Define field complexity costs
const complexityConfig = {
  scalarCost: 1,
  objectCost: 2,
  listFactor: 10,
  introspectionListFactor: 15
};

// Custom complexity calculation
const calculateComplexity = (type, field, args) => {
  // Base complexity
  let complexity = 1;
  
  // Increase complexity for expensive operations
  if (field.name === 'search') {
    complexity += 10;
  }
  
  // Factor in pagination limits
  if (args.limit) {
    complexity *= Math.min(args.limit, 100);
  }
  
  // Lists are more expensive
  if (type.toString().includes('[')) {
    complexity *= 10;
  }
  
  return complexity;
};

// Create validation rule
const complexityRule = createComplexityLimitRule(1000, {
  onCost: (cost) => {
    console.log(`Query cost: ${cost}`);
  },
  formatErrorMessage: (cost) => {
    return `Query is too complex: ${cost}. Maximum allowed complexity: 1000`;
  },
  createError: (cost, documentNode) => {
    const error = new Error(`Query is too complex: ${cost}`);
    error.code = 'COMPLEXITY_LIMIT_EXCEEDED';
    return error;
  }
});

// Apply to schema
const server = new ApolloServer({
  typeDefs,
  resolvers,
  validationRules: [complexityRule],
});

// Query depth limiting
const depthLimit = require('graphql-depth-limit');

const server = new ApolloServer({
  typeDefs,
  resolvers,
  validationRules: [
    depthLimit(10), // Maximum depth of 10
    complexityRule
  ]
});
```

**Example Query Analysis:**

```graphql
# Query with high complexity
query ExpensiveQuery {
  users(limit: 100) {          # Cost: 100 * 10 = 1000
    posts(limit: 50) {         # Cost: 100 * 50 * 10 = 50000
      comments(limit: 20) {    # Cost: 100 * 50 * 20 * 10 = 1000000
        author {
          posts {              # Too deep!
            comments {
              author {
                # ...
              }
            }
          }
        }
      }
    }
  }
}
# Total complexity: > 1000000 (REJECTED)

# Optimized query
query OptimizedQuery {
  users(limit: 10) {           # Cost: 10 * 10 = 100
    posts(limit: 5) {          # Cost: 10 * 5 * 10 = 500
      title
      content
    }
  }
}
# Total complexity: ~600 (ACCEPTED)
```

### Persisted Queries

Persisted queries allow clients to send a query hash instead of the full query string, improving security and performance by reducing bandwidth and preventing arbitrary query execution.

**Key Points:**

- Reduce payload size by sending query IDs instead of full queries
- Improve security by allowing only pre-approved queries
- Enable better caching and CDN optimization
- Support automatic persisted queries (APQ) for easier adoption

**Example:**

```javascript
// Server-side persisted queries setup
const { ApolloServer } = require('apollo-server');
const { createPersistedQueryLink } = require('@apollo/client/link/persisted-queries');

// Store for persisted queries
const persistedQueries = new Map([
  ['hash123', 'query GetUser($id: ID!) { user(id: $id) { id username email } }'],
  ['hash456', 'query GetPosts { posts { id title author { username } } }'],
  ['hash789', 'mutation CreatePost($input: CreatePostInput!) { createPost(input: $input) { id title } }']
]);

// Apollo Server configuration
const server = new ApolloServer({
  typeDefs,
  resolvers,
  persistedQueries: {
    cache: {
      get: async (queryHash) => {
        return persistedQueries.get(queryHash);
      },
      set: async (queryHash, query) => {
        // For APQ: store new queries automatically
        persistedQueries.set(queryHash, query);
      }
    },
    // Only allow persisted queries in production
    disallowArbitraryQueries: process.env.NODE_ENV === 'production'
  }
});

// Client-side setup
const { ApolloClient, InMemoryCache } = require('@apollo/client');
const { createPersistedQueryLink } = require('@apollo/client/link/persisted-queries');
const { createHttpLink } = require('@apollo/client');
const { sha256 } = require('crypto-hash');

const httpLink = createHttpLink({
  uri: 'https://api.example.com/graphql'
});

const persistedQueryLink = createPersistedQueryLink({
  sha256,
  useGETForHashedQueries: true
});

const client = new ApolloClient({
  cache: new InMemoryCache(),
  link: persistedQueryLink.concat(httpLink)
});
```

**Request Flow:**

```
// First request (query not cached)
POST /graphql
{
  "extensions": {
    "persistedQuery": {
      "version": 1,
      "sha256Hash": "hash123"
    }
  }
}

// Server responds: PersistedQueryNotFound
{
  "errors": [{
    "message": "PersistedQueryNotFound"
  }]
}

// Client sends full query
POST /graphql
{
  "query": "query GetUser($id: ID!) { user(id: $id) { id username email } }",
  "extensions": {
    "persistedQuery": {
      "version": 1,
      "sha256Hash": "hash123"
    }
  }
}

// Subsequent requests (query cached)
GET /graphql?extensions={"persistedQuery":{"version":1,"sha256Hash":"hash123"}}&variables={"id":"123"}

// Much smaller payload!
```

### Schema Stitching and Federation

Schema stitching and federation patterns enable combining multiple GraphQL schemas into a single unified API, supporting microservices architecture and team autonomy.

**Federation Pattern (Apollo Federation):**

**Key Points:**

- Each service owns its domain schema
- Services extend types from other services
- Gateway composes schemas automatically
- Supports distributed ownership and deployment

**Example:**

```graphql
# Users Service
type User @key(fields: "id") {
  id: ID!
  username: String!
  email: String!
}

type Query {
  user(id: ID!): User
  users: [User!]!
}

# Posts Service
extend type User @key(fields: "id") {
  id: ID! @external
  posts: [Post!]!
}

type Post @key(fields: "id") {
  id: ID!
  title: String!
  content: String!
  authorId: ID!
  author: User!
}

type Query {
  post(id: ID!): Post
  posts: [Post!]!
}

# Comments Service
extend type Post @key(fields: "id") {
  id: ID! @external
  comments: [Comment!]!
}

type Comment @key(fields: "id") {
  id: ID!
  content: String!
  postId: ID!
  authorId: ID!
  author: User!
}
```

```javascript
// Users Service
const { buildFederatedSchema } = require('@apollo/federation');

const typeDefs = gql`
  type User @key(fields: "id") {
    id: ID!
    username: String!
    email: String!
  }
  
  type Query {
    user(id: ID!): User
    users: [User!]!
  }
`;

const resolvers = {
  Query: {
    user: (parent, { id }, context) => {
      return context.db.users.findById(id);
    },
    users: (parent, args, context) => {
      return context.db.users.findAll();
    }
  },
  User: {
    __resolveReference: (reference, context) => {
      return context.db.users.findById(reference.id);
    }
  }
};

const schema = buildFederatedSchema([{ typeDefs, resolvers }]);

// Posts Service
const typeDefs = gql`
  extend type User @key(fields: "id") {
    id: ID! @external
    posts: [Post!]!
  }
  
  type Post @key(fields: "id") {
    id: ID!
    title: String!
    content: String!
    authorId: ID!
    author: User!
  }
  
  type Query {
    post(id: ID!): Post
    posts: [Post!]!
  }
`;

const resolvers = {
  Query: {
    post: (parent, { id }, context) => {
      return context.db.posts.findById(id);
    },
    posts: (parent, args, context) => {
      return context.db.posts.findAll();
    }
  },
  User: {
    posts: (user, args, context) => {
      return context.db.posts.findByAuthorId(user.id);
    }
  },
  Post: {
    __resolveReference: (reference, context) => {
      return context.db.posts.findById(reference.id);
    },
    author: (post, args, context) => {
      return { __typename: 'User', id: post.authorId };
    }
  }
};

// Gateway
const { ApolloGateway } = require('@apollo/gateway');

const gateway = new ApolloGateway({
  serviceList: [
    { name: 'users', url: 'http://localhost:4001/graphql' },
    { name: 'posts', url: 'http://localhost:4002/graphql' },
    { name: 'comments', url: 'http://localhost:4003/graphql' }
  ]
});

const server = new ApolloServer({
  gateway,
  subscriptions: false
});
```

### Caching Strategies

Implementing effective caching strategies improves GraphQL API performance and reduces server load through multiple caching layers.

**Key Points:**

- Use HTTP caching headers for GET requests
- Implement application-level caching with Redis or similar
- Use DataLoader for per-request caching
- Consider client-side cache normalization
- Cache at field-level for fine-grained control

**Example:**

```javascript
const Redis = require('ioredis');
const redis = new Redis();

// Response caching middleware
const responseCachePlugin = {
  async requestDidStart() {
    return {
      async responseForOperation({ request, contextValue }) {
        const cacheKey = `graphql:${hashQuery(request.query)}:${JSON.stringify(request.variables)}`;
        
        // Check cache
        const cached = await redis.get(cacheKey);
        if (cached) {
          return JSON.parse(cached);
        }
        
        return null;
      },
      
      async willSendResponse({ response, contextValue }) {
        if (!response.errors && contextValue.cacheControl) {
          const cacheKey = contextValue.cacheKey;
          const ttl = contextValue.cacheControl.ttl;
          
          await redis.setex(
            cacheKey,
            ttl,
            JSON.stringify(response)
          );
        }
      }
    };
  }
};

// Field-level caching
const typeDefs = gql`
  type User {
    id: ID!
    username: String! @cacheControl(maxAge: 3600)
    email: String!
    posts: [Post!]! @cacheControl(maxAge: 300)
  }
  
  type Post {
    id: ID!
    title: String! @cacheControl(maxAge: 600)
    content: String!
    viewCount: Int! @cacheControl(maxAge: 60)
  }
  
  type Query {
    user(id: ID!): User @cacheControl(maxAge: 300)
    trendingPosts: [Post!]! @cacheControl(maxAge: 60)
  }
`;

// ============================================================================
// Resolvers with Caching
// ============================================================================

const resolvers = {
  Query: {
    user: async (parent, { id }, context) => {
      const cacheKey = `user:${id}`;

      // Try cache first
      let user = await redis.get(cacheKey);

      if (user) {
        return JSON.parse(user);
      }

      // Fetch from database
      user = await context.db.users.findById(id);

      // Cache for 5 minutes
      await redis.setex(cacheKey, 300, JSON.stringify(user));

      return user;
    },

    trendingPosts: async (parent, args, context) => {
      const cacheKey = "trending:posts";

      let posts = await redis.get(cacheKey);

      if (posts) {
        return JSON.parse(posts);
      }

      posts = await context.db.posts
        .find()
        .sort({ viewCount: -1 })
        .limit(10);

      // Cache for 1 minute (frequently changing data)
      await redis.setex(cacheKey, 60, JSON.stringify(posts));

      return posts;
    },
  },

  User: {
    posts: async (parent, args, context) => {
      const cacheKey = `user:${parent.id}:posts`;

      let posts = await redis.get(cacheKey);

      if (posts) {
        return JSON.parse(posts);
      }

      posts = await context.db.posts.findByAuthorId(parent.id);

      // Cache for 5 minutes
      await redis.setex(cacheKey, 300, JSON.stringify(posts));

      return posts;
    },
  },
};


// ============================================================================
// Cache Invalidation on Mutations
// ============================================================================

const mutationResolvers = {
  Mutation: {
    createPost: async (parent, { input }, context) => {
      const post = await context.db.posts.create(input);

      // Invalidate relevant caches
      await redis.del(`user:${input.authorId}:posts`);
      await redis.del("trending:posts");

      return post;
    },

    updateUser: async (parent, { id, input }, context) => {
      const user = await context.db.users.update(id, input);

      // Invalidate user cache
      await redis.del(`user:${id}`);

      return user;
    },
  },
};
````

### File Upload Pattern

Handling file uploads in GraphQL requires special consideration since GraphQL doesn't natively support multipart form data.

**Key Points:**
- Use multipart/form-data with graphql-upload
- Validate file types and sizes on server
- Stream files to storage (S3, local filesystem)
- Return URLs or file metadata in response
- Consider direct-to-storage uploads for large files

**Example:**
```graphql
scalar Upload

type File {
  id: ID!
  filename: String!
  mimetype: String!
  encoding: String!
  url: String!
  size: Int!
  uploadedAt: DateTime!
}

input UploadFileInput {
  file: Upload!
  description: String
}

type Mutation {
  uploadFile(input: UploadFileInput!): File!
  uploadMultipleFiles(files: [Upload!]!): [File!]!
  updateUserAvatar(file: Upload!): User!
}
````

```javascript
const { GraphQLUpload } = require('graphql-upload');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const AWS = require('aws-sdk');

const s3 = new AWS.S3();

const resolvers = {
  Upload: GraphQLUpload,
  
  Mutation: {
    uploadFile: async (parent, { input }, context) => {
      const { file, description } = input;
      const { createReadStream, filename, mimetype, encoding } = await file;
      
      // Validate file
      const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];
      if (!allowedTypes.includes(mimetype)) {
        throw new Error('Invalid file type');
      }
      
      const maxSize = 10 * 1024 * 1024; // 10MB
      
      // Generate unique filename
      const fileId = uuidv4();
      const ext = path.extname(filename);
      const uniqueFilename = `${fileId}${ext}`;
      
      // Upload to S3
      const stream = createReadStream();
      const uploadParams = {
        Bucket: 'my-bucket',
        Key: `uploads/${uniqueFilename}`,
        Body: stream,
        ContentType: mimetype,
        ACL: 'public-read'
      };
      
      let fileSize = 0;
      stream.on('data', (chunk) => {
        fileSize += chunk.length;
        if (fileSize > maxSize) {
          stream.destroy();
          throw new Error('File too large');
        }
      });
      
      const result = await s3.upload(uploadParams).promise();
      
      // Save file metadata to database
      const fileRecord = await context.db.files.create({
        id: fileId,
        filename,
        mimetype,
        encoding,
        url: result.Location,
        size: fileSize,
        description,
        uploadedBy: context.user.id,
        uploadedAt: new Date()
      });
      
      return fileRecord;
    },
    
    uploadMultipleFiles: async (parent, { files }, context) => {
      const uploadedFiles = await Promise.all(
        files.map(async (filePromise) => {
          const file = await filePromise;
          // Reuse single file upload logic
          return uploadSingleFile(file, context);
        })
      );
      
      return uploadedFiles;
    },
    
    updateUserAvatar: async (parent, { file }, context) => {
      const { createReadStream, filename, mimetype } = await file;
      
      // Validate image
      if (!mimetype.startsWith('image/')) {
        throw new Error('File must be an image');
      }
      
      const fileId = uuidv4();
      const ext = path.extname(filename);
      const uniqueFilename = `avatars/${context.user.id}/${fileId}${ext}`;
      
      // Upload to S3
      const stream = createReadStream();
      const uploadParams = {
        Bucket: 'my-bucket',
        Key: uniqueFilename,
        Body: stream,
        ContentType: mimetype,
        ACL: 'public-read'
      };
      
      const result = await s3.upload(uploadParams).promise();
      
      // Update user avatar URL
      const updatedUser = await context.db.users.update(context.user.id, {
        avatarUrl: result.Location
      });
      
      // Delete old avatar if exists
      if (context.user.avatarUrl) {
        const oldKey = context.user.avatarUrl.split('.com/')[1];
        await s3.deleteObject({ Bucket: 'my-bucket', Key: oldKey }).promise();
      }
      
      return updatedUser;
    }
  }
};

// Server setup with upload support
const { ApolloServer } = require('apollo-server-express');
const { graphqlUploadExpress } = require('graphql-upload');
const express = require('express');

const app = express();

// Add upload middleware before Apollo
app.use(graphqlUploadExpress({
  maxFileSize: 10 * 1024 * 1024, // 10MB
  maxFiles: 5
}));

const server = new ApolloServer({
  typeDefs,
  resolvers,
  context: ({ req }) => ({
    user: req.user,
    db: /* database instance */
  })
});

server.applyMiddleware({ app });
```

**Client-side Upload:**

```javascript
// React example with Apollo Client
import { useMutation } from '@apollo/client';
import { gql } from '@apollo/client';

const UPLOAD_FILE = gql`
  mutation UploadFile($input: UploadFileInput!) {
    uploadFile(input: $input) {
      id
      filename
      url
      size
    }
  }
`;

function FileUpload() {
  const [uploadFile, { loading, error, data }] = useMutation(UPLOAD_FILE);
  
  const handleFileChange = async (event) => {
    const file = event.target.files[0];
    
    if (!file) return;
    
    try {
      const result = await uploadFile({
        variables: {
          input: {
            file,
            description: 'My uploaded file'
          }
        }
      });
      
      console.log('Uploaded:', result.data.uploadFile);
    } catch (err) {
      console.error('Upload failed:', err);
    }
  };
  
  return (
    <div>
      <input type="file" onChange={handleFileChange} disabled={loading} />
      {loading && <p>Uploading...</p>}
      {error && <p>Error: {error.message}</p>}
      {data && <p>File uploaded: {data.uploadFile.url}</p>}
    </div>
  );
}
```

### Testing Patterns

Comprehensive testing ensures GraphQL APIs work correctly and remain stable as they evolve.

**Key Points:**

- Test schema validation and type safety
- Test resolver logic independently
- Test authorization and authentication flows
- Test error handling scenarios
- Use integration tests for end-to-end validation

**Example:**

```javascript
const { ApolloServer } = require('apollo-server');
const { createTestClient } = require('apollo-server-testing');
const { gql } = require('apollo-server');

// Schema and resolvers
const typeDefs = gql`
  type User {
    id: ID!
    username: String!
    email: String!
  }
  
  type Query {
    user(id: ID!): User
    users: [User!]!
  }
  
  type Mutation {
    createUser(username: String!, email: String!): User!
  }
`;

const resolvers = {
  Query: {
    user: (parent, { id }, { dataSources }) => {
      return dataSources.userAPI.getUserById(id);
    },
    users: (parent, args, { dataSources }) => {
      return dataSources.userAPI.getAllUsers();
    }
  },
  Mutation: {
    createUser: (parent, { username, email }, { dataSources }) => {
      return dataSources.userAPI.createUser({ username, email });
    }
  }
};

// Unit tests for resolvers
describe('User Resolvers', () => {
  let mockDataSources;
  
  beforeEach(() => {
    mockDataSources = {
      userAPI: {
        getUserById: jest.fn(),
        getAllUsers: jest.fn(),
        createUser: jest.fn()
      }
    };
  });
  
  describe('Query.user', () => {
    it('should return user by id', async () => {
      const mockUser = { id: '1', username: 'john', email: 'john@example.com' };
      mockDataSources.userAPI.getUserById.mockResolvedValue(mockUser);
      
      const result = await resolvers.Query.user(
        null,
        { id: '1' },
        { dataSources: mockDataSources }
      );
      
      expect(mockDataSources.userAPI.getUserById).toHaveBeenCalledWith('1');
      expect(result).toEqual(mockUser);
    });
    
    it('should return null for non-existent user', async () => {
      mockDataSources.userAPI.getUserById.mockResolvedValue(null);
      
      const result = await resolvers.Query.user(
        null,
        { id: '999' },
        { dataSources: mockDataSources }
      );
      
      expect(result).toBeNull();
    });
  });
  
  describe('Mutation.createUser', () => {
    it('should create a new user', async () => {
      const input = { username: 'jane', email: 'jane@example.com' };
      const mockUser = { id: '2', ...input };
      mockDataSources.userAPI.createUser.mockResolvedValue(mockUser);
      
      const result = await resolvers.Mutation.createUser(
        null,
        input,
        { dataSources: mockDataSources }
      );
      
      expect(mockDataSources.userAPI.createUser).toHaveBeenCalledWith(input);
      expect(result).toEqual(mockUser);
    });
  });
});

// Integration tests
describe('GraphQL Integration Tests', () => {
  let server;
  let query, mutate;
  
  beforeAll(() => {
    server = new ApolloServer({
      typeDefs,
      resolvers,
      dataSources: () => ({
        userAPI: new UserAPI()
      }),
      context: () => ({
        user: { id: '1', role: 'USER' }
      })
    });
    
    const testClient = createTestClient(server);
    query = testClient.query;
    mutate = testClient.mutate;
  });
  
  describe('User Queries', () => {
    it('should fetch all users', async () => {
      const GET_USERS = gql`
        query GetUsers {
          users {
            id
            username
            email
          }
        }
      `;
      
      const { data, errors } = await query({ query: GET_USERS });
      
      expect(errors).toBeUndefined();
      expect(data.users).toBeInstanceOf(Array);
      expect(data.users.length).toBeGreaterThan(0);
    });
    
    it('should fetch user by id', async () => {
      const GET_USER = gql`
        query GetUser($id: ID!) {
          user(id: $id) {
            id
            username
            email
          }
        }
      `;
      
      const { data, errors } = await query({
        query: GET_USER,
        variables: { id: '1' }
      });
      
      expect(errors).toBeUndefined();
      expect(data.user).toHaveProperty('id', '1');
      expect(data.user).toHaveProperty('username');
      expect(data.user).toHaveProperty('email');
    });
    
    it('should return error for invalid user id', async () => {
      const GET_USER = gql`
        query GetUser($id: ID!) {
          user(id: $id) {
            id
            username
          }
        }
      `;
      
      const { data, errors } = await query({
        query: GET_USER,
        variables: { id: 'invalid' }
      });
      
      expect(data.user).toBeNull();
    });
  });
  
  describe('User Mutations', () => {
    it('should create a new user', async () => {
      const CREATE_USER = gql`
        mutation CreateUser($username: String!, $email: String!) {
          createUser(username: $username, email: $email) {
            id
            username
            email
          }
        }
      `;
      
      const { data, errors } = await mutate({
        mutation: CREATE_USER,
        variables: {
          username: 'testuser',
          email: 'test@example.com'
        }
      });
      
      expect(errors).toBeUndefined();
      expect(data.createUser).toHaveProperty('id');
      expect(data.createUser.username).toBe('testuser');
      expect(data.createUser.email).toBe('test@example.com');
    });
    
    it('should return validation error for invalid email', async () => {
      const CREATE_USER = gql`
        mutation CreateUser($username: String!, $email: String!) {
          createUser(username: $username, email: $email) {
            id
            username
            email
          }
        }
      `;
      
      const { errors } = await mutate({
        mutation: CREATE_USER,
        variables: {
          username: 'testuser',
          email: 'invalid-email'
        }
      });
      
      expect(errors).toBeDefined();
      expect(errors[0].message).toContain('email');
    });
  });
});

// Schema validation tests
describe('Schema Validation', () => {
  it('should have valid schema', () => {
    const server = new ApolloServer({ typeDefs, resolvers });
    expect(server.schema).toBeDefined();
  });
  
  it('should reject invalid queries at schema level', () => {
    const INVALID_QUERY = gql`
      query {
        nonExistentField
      }
    `;
    
    // This would be caught by GraphQL validation
    // before reaching resolvers
  });
});
```

**Conclusion:** GraphQL API design patterns provide structured approaches to common challenges in building GraphQL services. The schema-first design establishes clear contracts, resolvers handle data fetching, DataLoader optimizes database queries, and pagination manages large datasets. Authorization, error handling, and complexity analysis ensure security and stability. Advanced patterns like federation enable microservices architecture, while caching and persisted queries optimize performance. File uploads extend GraphQL's capabilities, and comprehensive testing ensures reliability. Combining these patterns creates robust, scalable, and maintainable GraphQL APIs.

**Next Steps:**

- Implement DataLoader in existing resolvers to eliminate N+1 queries
- Add query complexity analysis to prevent expensive operations
- Set up persisted queries for production environments
- Implement comprehensive error handling with custom error types
- Add field-level authorization using directives
- Configure caching layers (Redis, CDN) for frequently accessed data
- Write integration tests covering critical user flows
- Consider federation if working with microservices
- Monitor query performance and optimize slow resolvers
- Document your GraphQL schema and share with frontend teams

---

