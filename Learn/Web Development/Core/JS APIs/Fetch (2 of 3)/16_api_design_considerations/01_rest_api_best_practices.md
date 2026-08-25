## REST API Best Practices


### Resource Naming Conventions

#### Plural Nouns for Collections

Use plural nouns to represent resource collections:

```
✅ GET /users
✅ GET /products
✅ GET /orders

❌ GET /user
❌ GET /product
❌ GET /getUsers
```

#### Hierarchical Resource Relationships

Express resource relationships through URL structure:

```
GET    /users/123/orders           # User's orders
GET    /users/123/orders/456       # Specific order for user
POST   /users/123/addresses        # Create address for user
GET    /organizations/789/members  # Organization members
DELETE /posts/456/comments/789     # Delete comment from post
```

Limit nesting to 2-3 levels maximum for readability.

#### Lowercase with Hyphens

Use lowercase letters with hyphens for multi-word resources:

```
✅ /product-categories
✅ /user-profiles
✅ /shipping-addresses

❌ /productCategories
❌ /UserProfiles
❌ /shipping_addresses
```

#### Avoid File Extensions

Exclude file extensions; use `Accept` header for content negotiation:

```
✅ GET /users/123
   Accept: application/json

❌ GET /users/123.json
❌ GET /users/123.xml
```

### HTTP Method Usage

#### Standard CRUD Operations

Map operations to appropriate HTTP methods:

```
GET    /users           # List all users
GET    /users/123       # Retrieve specific user
POST   /users           # Create new user
PUT    /users/123       # Replace entire user
PATCH  /users/123       # Partial update user
DELETE /users/123       # Delete user
```

#### Idempotency Considerations

Idempotent methods produce same result on repeated calls:

- **GET, PUT, DELETE, HEAD, OPTIONS**: Idempotent
- **POST, PATCH**: Not guaranteed idempotent

```
# Idempotent - safe to retry
PUT /users/123
{
  "name": "John Doe",
  "email": "john@example.com"
}

# Not idempotent - multiple calls create multiple resources
POST /users
{
  "name": "John Doe"
}
```

#### Safe Methods

GET, HEAD, OPTIONS should never modify resources:

```
✅ GET /users/123        # Read-only operation

❌ GET /users/123/delete # Mutation via GET
❌ GET /orders/456/pay   # Side effects via GET
```

#### Method-Specific Semantics

**POST**: Create subordinate resources, non-idempotent operations

```
POST /users
POST /payments/process
POST /orders/123/refund
```

**PUT**: Complete replacement, must include all fields

```
PUT /users/123
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "address": "123 Main St"
}
```

**PATCH**: Partial updates, include only changed fields

```
PATCH /users/123
{
  "email": "newemail@example.com"
}
```

**DELETE**: Remove resources, return appropriate status

```
DELETE /users/123

# First call: 204 No Content
# Subsequent calls: 404 Not Found
```

### Status Code Standards

#### Success Codes (2xx)

Use specific success codes:

```
200 OK                  # Successful GET, PUT, PATCH with response body
201 Created             # Successful POST creating resource
204 No Content          # Successful DELETE or update with no response body
202 Accepted            # Request accepted for async processing
206 Partial Content     # Partial GET (range requests)
```

Example responses:

```
POST /users
201 Created
Location: /users/123
{
  "id": 123,
  "name": "John Doe",
  "createdAt": "2024-01-15T10:30:00Z"
}

DELETE /users/123
204 No Content
```

#### Client Error Codes (4xx)

Indicate client-side issues:

```
400 Bad Request         # Malformed request, validation errors
401 Unauthorized        # Missing or invalid authentication
403 Forbidden           # Authenticated but insufficient permissions
404 Not Found           # Resource doesn't exist
405 Method Not Allowed  # HTTP method not supported for endpoint
409 Conflict            # Resource state conflict (e.g., duplicate email)
410 Gone                # Resource permanently deleted
422 Unprocessable Entity # Semantic validation errors
429 Too Many Requests   # Rate limit exceeded
```

Detailed error responses:

```json
400 Bad Request
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
    ]
  }
}
```

#### Server Error Codes (5xx)

Indicate server-side failures:

```
500 Internal Server Error  # Unexpected server error
501 Not Implemented        # Feature not implemented
502 Bad Gateway            # Invalid upstream response
503 Service Unavailable    # Temporary unavailability
504 Gateway Timeout        # Upstream timeout
```

Never expose internal error details in production:

```
✅ 500 Internal Server Error
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An unexpected error occurred",
    "requestId": "req_abc123"
  }
}

❌ 500 Internal Server Error
{
  "error": "Database connection failed: ECONNREFUSED 192.168.1.100:5432",
  "stack": "Error: connection refused\n  at Connection.connect..."
}
```

### Versioning Strategies

#### URI Path Versioning

Most explicit and commonly used:

```
https://api.example.com/v1/users
https://api.example.com/v2/users
https://api.example.com/v1/products
```

Pros: Clear, easy to route, browser-testable
Cons: URL changes, cache invalidation

#### Header Versioning

Version specified in custom header:

```
GET /users
API-Version: 2
Accept: application/json
```

Or via Accept header:

```
GET /users
Accept: application/vnd.company.v2+json
```

Pros: Clean URLs, same resource identifier
Cons: Less visible, harder to test manually

#### Query Parameter Versioning

Version as query string:

```
GET /users?version=2
GET /products?v=1
```

Pros: Simple, URL-based
Cons: Pollutes query parameters, caching complications

#### Version Deprecation Policy

Communicate lifecycle clearly:

```
# Response headers for deprecated versions
GET /v1/users

Deprecation: true
Sunset: Sat, 31 Dec 2024 23:59:59 GMT
Link: </v2/users>; rel="successor-version"
Warning: 299 - "API v1 is deprecated and will be removed on 2024-12-31"
```

Maintain multiple versions simultaneously with clear timelines:

- v1: Active (6 months deprecation notice)
- v2: Current
- v3: Beta/Preview

### Pagination Patterns

#### Offset-Based Pagination

Traditional page-based approach:

```
GET /users?page=2&limit=20
GET /users?offset=40&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 1250,
    "totalPages": 63,
    "hasNext": true,
    "hasPrevious": true
  }
}
```

Pros: Simple, supports random access
Cons: Performance degrades with high offsets, inconsistent with real-time data

#### Cursor-Based Pagination

Position-based using unique identifiers:

```
GET /users?cursor=eyJpZCI6MTIzfQ&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTQzfQ",
    "prevCursor": "eyJpZCI6MTAzfQ",
    "hasNext": true,
    "hasPrevious": true
  }
}
```

Cursor typically encodes last ID or timestamp:

```
# Encoded cursor example
{
  "id": 143,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

Pros: Consistent with real-time data, better performance
Cons: No random access, more complex implementation

#### Link Header Pagination (RFC 5988)

Provide navigation links in headers:

```
GET /users?page=2

Link: </users?page=1>; rel="first",
      </users?page=1>; rel="prev",
      </users?page=3>; rel="next",
      </users?page=63>; rel="last"
```

Complements body-based pagination with standardized discovery.

#### Range Header Pagination

Use HTTP Range requests:

```
GET /users
Range: items=0-19

206 Partial Content
Content-Range: items 0-19/1250
Accept-Ranges: items
```

Pros: HTTP standard, client-controlled
Cons: Less common, limited adoption

### Filtering and Searching

#### Query Parameter Filtering

Use intuitive query parameters:

```
GET /users?role=admin&status=active
GET /products?category=electronics&minPrice=100&maxPrice=500
GET /orders?createdAfter=2024-01-01&createdBefore=2024-12-31
```

#### Complex Filtering Syntax

Support operators for advanced queries:

```
# Comparison operators
GET /products?price[gte]=100&price[lte]=500

# Multiple values (OR logic)
GET /users?status=active,pending

# Nested properties
GET /orders?customer.country=US

# Array containment
GET /posts?tags[contains]=api,rest
```

#### Full-Text Search

Dedicated search parameter:

```
GET /products?q=wireless+headphones
GET /users?search=john+doe
```

Separate from filters for clarity:

```
GET /products?q=laptop&category=electronics&minPrice=500
```

#### Field Selection (Sparse Fieldsets)

Allow clients to request specific fields:

```
GET /users?fields=id,name,email
GET /products?fields=name,price,images.thumbnail

Response:
{
  "data": [
    {
      "id": 123,
      "name": "John Doe",
      "email": "john@example.com"
    }
  ]
}
```

Reduces payload size and improves performance.

### Sorting

#### Query Parameter Syntax

Use explicit sort parameter:

```
GET /users?sort=createdAt        # Ascending
GET /users?sort=-createdAt       # Descending (minus prefix)
GET /products?sort=price,name    # Multiple fields
GET /orders?sort=-total,createdAt
```

Alternative verbose syntax:

```
GET /users?sort=createdAt:asc
GET /users?sort=createdAt:desc
```

#### Default Sorting

Document and consistently apply defaults:

```
# Default: sort by creation date descending
GET /posts

# Equivalent to:
GET /posts?sort=-createdAt
```

Include sorting metadata in responses:

```json
{
  "data": [...],
  "meta": {
    "sort": ["-createdAt"],
    "defaultSort": ["-createdAt"]
  }
}
```

### Authentication and Authorization

#### Token-Based Authentication

Use Bearer tokens in Authorization header:

```
GET /users/me
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

❌ Avoid in query parameters:
GET /users/me?token=eyJhbGciOiJ...
```

Tokens in URLs risk exposure via logs, browser history, and referrer headers.

#### API Key Authentication

Custom header for API keys:

```
GET /products
X-API-Key: sk_live_abc123xyz789
```

Never transmit API keys in URLs or JSON bodies when possible.

#### OAuth 2.0 Flows

Standard authorization framework:

```
# Authorization Code Flow
1. Redirect user to authorization server
2. User grants permission
3. Exchange code for access token

POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&
code=AUTH_CODE&
client_id=CLIENT_ID&
client_secret=CLIENT_SECRET&
redirect_uri=REDIRECT_URI

Response:
{
  "access_token": "eyJhbGc...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "eyJhbGc...",
  "scope": "read write"
}
```

#### Permission-Based Authorization

Implement granular access control:

```
GET /users/123
Authorization: Bearer TOKEN

# Check permissions:
# - User owns resource (user.id === 123)
# - User has admin role
# - User has 'users:read' permission

403 Forbidden
{
  "error": {
    "code": "INSUFFICIENT_PERMISSIONS",
    "message": "You don't have permission to access this resource",
    "requiredPermissions": ["users:read"]
  }
}
```

### Rate Limiting

#### Rate Limit Headers

Communicate limits using standard headers:

```
GET /users

X-RateLimit-Limit: 1000          # Max requests per window
X-RateLimit-Remaining: 987       # Requests remaining
X-RateLimit-Reset: 1705320000    # Unix timestamp when limit resets
Retry-After: 3600                # Seconds until retry (when limited)
```

When limit exceeded:

```
429 Too Many Requests
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1705320000
Retry-After: 3600

{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Please retry after 3600 seconds"
  }
}
```

#### Tiered Rate Limiting

Different limits per authentication level:

```
# Anonymous: 100 requests/hour
# Authenticated: 1000 requests/hour
# Premium: 10000 requests/hour

GET /products
X-RateLimit-Limit: 1000
X-RateLimit-Policy: authenticated
```

#### Resource-Specific Limits

Apply different limits to different endpoints:

```
# Read endpoints: 1000/hour
GET /users
X-RateLimit-Limit: 1000

# Write endpoints: 100/hour
POST /users
X-RateLimit-Limit: 100

# Expensive operations: 10/hour
POST /reports/generate
X-RateLimit-Limit: 10
```

### HATEOAS (Hypermedia Controls)

#### Link Relations

Include navigational links in responses:

```json
GET /users/123

{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "_links": {
    "self": {
      "href": "/users/123"
    },
    "orders": {
      "href": "/users/123/orders"
    },
    "addresses": {
      "href": "/users/123/addresses"
    },
    "edit": {
      "href": "/users/123",
      "method": "PATCH"
    },
    "delete": {
      "href": "/users/123",
      "method": "DELETE"
    }
  }
}
```

#### Action Discovery

Expose available operations based on state and permissions:

```json
GET /orders/456

{
  "id": 456,
  "status": "pending",
  "total": 99.99,
  "_links": {
    "self": { "href": "/orders/456" },
    "cancel": {
      "href": "/orders/456/cancel",
      "method": "POST",
      "allowed": true
    },
    "refund": {
      "href": "/orders/456/refund",
      "method": "POST",
      "allowed": false,
      "reason": "Order not yet completed"
    }
  }
}
```

Clients discover capabilities dynamically rather than hardcoding logic.

#### Collection Navigation

Pagination and filtering links:

```json
GET /products?page=2

{
  "data": [...],
  "_links": {
    "self": { "href": "/products?page=2" },
    "first": { "href": "/products?page=1" },
    "prev": { "href": "/products?page=1" },
    "next": { "href": "/products?page=3" },
    "last": { "href": "/products?page=10" }
  }
}
```

### Caching Strategies

#### Cache-Control Headers

Control client and proxy caching:

```
# Public, cacheable for 1 hour
GET /products/123
Cache-Control: public, max-age=3600

# Private, user-specific
GET /users/me
Cache-Control: private, max-age=300

# No caching
GET /users/me/orders
Cache-Control: no-store

# Revalidate before use
GET /products/featured
Cache-Control: no-cache, must-revalidate
```

#### ETag for Conditional Requests

Validate cache freshness:

```
# Initial request
GET /users/123

200 OK
ETag: "v1-abc123"
{
  "id": 123,
  "name": "John Doe"
}

# Subsequent request with conditional header
GET /users/123
If-None-Match: "v1-abc123"

304 Not Modified
ETag: "v1-abc123"
# No body sent, client uses cached version

# If resource changed
200 OK
ETag: "v2-def456"
{
  "id": 123,
  "name": "Jane Doe"
}
```

#### Last-Modified Header

Time-based validation:

```
GET /products/123

200 OK
Last-Modified: Mon, 15 Jan 2024 10:30:00 GMT

# Conditional request
GET /products/123
If-Modified-Since: Mon, 15 Jan 2024 10:30:00 GMT

304 Not Modified
# Or 200 OK with updated content if modified
```

#### Vary Header

Indicate response variations:

```
GET /users/123
Accept: application/json
Accept-Language: en-US

200 OK
Vary: Accept, Accept-Language
# Caches should consider these headers when storing/retrieving
```

### Content Negotiation

#### Media Type Selection

Client specifies desired format:

```
GET /users/123
Accept: application/json

200 OK
Content-Type: application/json
{
  "id": 123,
  "name": "John Doe"
}
```

Support multiple formats:

```
GET /users/123
Accept: application/xml

200 OK
Content-Type: application/xml
<?xml version="1.0"?>
<user>
  <id>123</id>
  <name>John Doe</name>
</user>
```

Unsupported format handling:

```
GET /users/123
Accept: application/vnd.custom+yaml

406 Not Acceptable
{
  "error": {
    "code": "UNSUPPORTED_MEDIA_TYPE",
    "message": "Requested media type not supported",
    "supported": ["application/json", "application/xml"]
  }
}
```

#### Language Negotiation

Internationalization support:

```
GET /products/123
Accept-Language: es-MX, es;q=0.9, en;q=0.8

200 OK
Content-Language: es-MX
{
  "nombre": "Producto",
  "descripcion": "Descripción en español"
}
```

#### Compression

Request compressed responses:

```
GET /users
Accept-Encoding: gzip, deflate, br

200 OK
Content-Encoding: gzip
# Compressed response body
```

Server should compress responses over ~1KB for bandwidth efficiency.

### Bulk Operations

#### Batch Requests

Execute multiple operations in single request:

```
POST /batch

{
  "requests": [
    {
      "id": "req1",
      "method": "GET",
      "path": "/users/123"
    },
    {
      "id": "req2",
      "method": "PATCH",
      "path": "/users/123",
      "body": { "email": "newemail@example.com" }
    },
    {
      "id": "req3",
      "method": "GET",
      "path": "/users/123/orders"
    }
  ]
}

Response:
{
  "responses": [
    {
      "id": "req1",
      "status": 200,
      "body": { "id": 123, "name": "John Doe" }
    },
    {
      "id": "req2",
      "status": 200,
      "body": { "id": 123, "email": "newemail@example.com" }
    },
    {
      "id": "req3",
      "status": 200,
      "body": { "orders": [...] }
    }
  ]
}
```

#### Bulk Creation

Create multiple resources:

```
POST /users/bulk

{
  "users": [
    { "name": "Alice", "email": "alice@example.com" },
    { "name": "Bob", "email": "bob@example.com" },
    { "name": "Carol", "email": "carol@example.com" }
  ]
}

207 Multi-Status
{
  "results": [
    {
      "status": 201,
      "body": { "id": 124, "name": "Alice" }
    },
    {
      "status": 400,
      "error": { "message": "Email already exists" }
    },
    {
      "status": 201,
      "body": { "id": 125, "name": "Carol" }
    }
  ]
}
```

Use 207 Multi-Status when operations have different outcomes.

#### Bulk Updates

Update multiple resources:

```
PATCH /products/bulk

{
  "updates": [
    { "id": 1, "price": 29.99 },
    { "id": 2, "price": 39.99 },
    { "id": 3, "stock": 0 }
  ]
}
```

#### Bulk Deletion

Delete multiple resources:

```
DELETE /users
Content-Type: application/json

{
  "ids": [123, 124, 125]
}

200 OK
{
  "deleted": 3,
  "errors": []
}
```

### Asynchronous Operations

#### Long-Running Tasks

Return immediate acceptance for lengthy operations:

```
POST /reports/generate
{
  "type": "sales",
  "startDate": "2024-01-01",
  "endDate": "2024-12-31"
}

202 Accepted
Location: /reports/jobs/abc123
{
  "jobId": "abc123",
  "status": "processing",
  "estimatedCompletion": "2024-01-15T10:35:00Z"
}
```

#### Job Status Polling

Client polls for completion:

```
GET /reports/jobs/abc123

200 OK
{
  "jobId": "abc123",
  "status": "processing",
  "progress": 45,
  "estimatedCompletion": "2024-01-15T10:35:00Z"
}

# After completion
GET /reports/jobs/abc123

200 OK
{
  "jobId": "abc123",
  "status": "completed",
  "result": {
    "reportId": 789,
    "downloadUrl": "/reports/789/download"
  }
}

# If failed
200 OK
{
  "jobId": "abc123",
  "status": "failed",
  "error": {
    "code": "DATA_PROCESSING_ERROR",
    "message": "Failed to process date range"
  }
}
```

#### Webhook Callbacks

Notify clients on completion:

```
POST /reports/generate
{
  "type": "sales",
  "callbackUrl": "https://client.example.com/webhooks/reports"
}

202 Accepted
{
  "jobId": "abc123",
  "status": "processing"
}

# Server sends callback when complete
POST https://client.example.com/webhooks/reports
{
  "jobId": "abc123",
  "status": "completed",
  "result": {
    "reportId": 789
  }
}
```

### Error Handling

#### Consistent Error Format

Standardized error structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Must be a valid email address"
      }
    ],
    "requestId": "req_abc123",
    "timestamp": "2024-01-15T10:30:00Z",
    "documentation": "https://docs.example.com/errors/validation-error"
  }
}
```

#### Error Codes

Machine-readable error identifiers:

```
VALIDATION_ERROR          # 400
AUTHENTICATION_REQUIRED   # 401
INSUFFICIENT_PERMISSIONS  # 403
RESOURCE_NOT_FOUND        # 404
RESOURCE_CONFLICT         # 409
RATE_LIMIT_EXCEEDED       # 429
INTERNAL_ERROR            # 500
SERVICE_UNAVAILABLE       # 503
```

#### Validation Errors

Detailed field-level errors:

```
POST /users
{
  "name": "",
  "email": "invalid-email",
  "age": 15
}

400 Bad Request
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "name",
        "code": "REQUIRED",
        "message": "Name is required"
      },
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Must be a valid email address",
        "value": "invalid-email"
      },
      {
        "field": "age",
        "code": "MIN_VALUE",
        "message": "Must be at least 18",
        "constraint": { "min": 18 },
        "value": 15
      }
    ]
  }
}
```

#### Error Documentation

Link to detailed error explanations:

```json
{
  "error": {
    "code": "PAYMENT_FAILED",
    "message": "Payment processing failed",
    "documentation": "https://docs.example.com/errors/payment-failed",
    "supportContact": "support@example.com"
  }
}
```

### Security Best Practices

#### HTTPS Only

Enforce encrypted connections:

```
# Redirect HTTP to HTTPS
HTTP/1.1 301 Moved Permanently
Location: https://api.example.com/users

# HSTS header
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

#### Input Validation

Validate all input rigorously:

```
POST /users
{
  "name": "<script>alert('xss')</script>",
  "email": "user@example.com"
}

400 Bad Request
{
  "error": {
    "code": "VALIDATION_ERROR",
    "details": [
      {
        "field": "name",
        "message": "Invalid characters detected"
      }
    ]
  }
}
```

Sanitize and validate before processing.

#### CORS Configuration

Properly configure cross-origin requests:

```
# Preflight request
OPTIONS /users
Origin: https://app.example.com

# Response
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400
Access-Control-Allow-Credentials: true
```

Avoid wildcard origins with credentials:

```
❌ Insecure:
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true

✅ Secure:
Access-Control-Allow-Origin: https://trusted-app.example.com
Access-Control-Allow-Credentials: true
```

#### SQL Injection Prevention

Use parameterized queries, never string concatenation:

```
❌ Vulnerable:
query = "SELECT * FROM users WHERE email = '" + email + "'"

✅ Safe:
query = "SELECT * FROM users WHERE email = ?"
params = [email]
```

API layer should use ORM or prepared statements.

#### Request Size Limits

Prevent resource exhaustion:

```
POST /uploads
Content-Length: 52428800

413 Payload Too Large
{
  "error": {
    "code": "PAYLOAD_TOO_LARGE",
    "message": "Request body exceeds maximum size of 10MB",
    "maxSize": 10485760
  }
}
```

#### Security Headers

Include protective headers:

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
Referrer-Policy: no-referrer
```

### Documentation Standards

#### OpenAPI Specification

Document API with standardized format:

```yaml
openapi: 3.0.0
info:
  title: User Management API
  version: 1.0.0
  description: RESTful API for managing users

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  pagination:
                    $ref: '#/components/schemas/Pagination'

components:
  schemas:
    User:
      type: object
      required:
        - id
        - name
        - email
      properties:
        id:
          type: integer
        name:
          type: string
        email:
          type: string
          format: email
```

#### Request/Response Examples

Provide concrete examples:

```yaml
paths:
  /users:
    post:
      requestBody:
        content:
          application/json:
            example:
              name: "John Doe"
              email: "john@example.com"
              role: "user"
      responses:
        '201':
          content:
            application/json:
              example:
                id: 123
                name: "John Doe"
                email: "john@example.com"
                role: "user"
                createdAt: "2024-01-15T10:30:00Z"
```

#### Error Documentation

Document all error scenarios:

```yaml
responses:
  '400':
    description: Validation error
    content:
      application/json:
        example:
          error:
            code: "VALIDATION_ERROR"
            message: "Request validation failed"
            details:
              - field: "email"
                message: "Invalid email format"
  '401':
    description: Authentication required
  '403':
    description: Insufficient permissions
```

### Health Checks and Monitoring

#### Health Endpoint

Provide service health status:

```
GET /health

200 OK
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.2.3",
  "checks": {
    "database": {
      "status": "healthy",
      "responseTime": 12
    },
    "cache": {
      "status": "healthy",
      "responseTime": 3
    },
    "externalApi": {
      "status": "degraded",
      "responseTime": 2500,
      "message": "High latency detected"
    }
  }
}

# Unhealthy response
503 Service Unavailable
{
  "status": "unhealthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "checks": {
    "database": {
      "status": "unhealthy",
      "error": "Connection timeout"
    }
  }
}
```

#### Readiness vs Liveness

Separate endpoints for different purposes:

```
# Liveness: Is the service running?
GET /health/live
200 OK

# Readiness: Can the service accept traffic?
GET /health/ready
503 Service Unavailable
{
  "status": "not_ready",
  "reason": "Database migration in progress"
}
```

#### Metrics Endpoint

Expose operational metrics:

```
GET /metrics

{
  "requests": {
    "total": 1523890,
    "ratePerSecond": 142.3
  },
  "latency": {
    "p50": 45,
    "p95": 120,
    "p99": 350
  },
  "errors": {
    "rate": 0.02,
    "count": {
      "4xx": 125,
      "5xx": 12
    }
  },
  "uptime": 2592000
}
```

### Deprecation Strategy

#### Deprecation Headers

Warn about upcoming changes:

```
GET /v1/users

200 OK
Deprecation: true
Sunset: Sun, 31 Dec 2024 23:59:59 GMT
Link: </v2/users>; rel="successor-version"
Warning: 299 - "This endpoint is deprecated and will be removed on 2024-12-31. Please migrate to /v2/users"

{
  "data": [...]
}
```

#### Gradual Feature Deprecation

Communicate changes incrementally:

```
# Phase 1: Announce (6 months before)
GET /users?includeDeleted=true
Warning: 299 - "Parameter 'includeDeleted' is deprecated"

# Phase 2: Require opt-in (3 months before)
GET /users?includeDeleted=true
Warning: 299 - "Parameter 'includeDeleted' requires X-Enable-Deprecated: true"

# Phase 3: Remove
GET /users?includeDeleted=true
400 Bad Request
{
  "error": {
    "code": "DEPRECATED_PARAMETER",
    "message": "Parameter 'includeDeleted' has been removed. Use /users/archived instead"
  }
}
```

### Request Validation

#### Schema Validation

Validate request structure:

```
POST /users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 25,
  "role": "admin"
}

# Validation rules:
# - name: required, string, 2-100 chars
# - email: required, valid email format
# - age: optional, integer, 18-120
# - role: required, enum ['user', 'admin', 'moderator']
```

#### Type Coercion

Handle type mismatches gracefully:

```
GET /users?page=abc

400 Bad Request
{
  "error": {
    "code": "VALIDATION_ERROR",
    "details": [
      {
        "field": "page",
        "message": "Must be a valid integer",
        "value": "abc",
        "type": "integer"
      }
    ]
  }
}
```

#### Required vs Optional

Clearly distinguish mandatory fields:

```
POST /products
{
  "name": "Widget"
  # Missing required fields: price, sku
}

400 Bad Request
{
  "error": {
    "code": "VALIDATION_ERROR",
    "details": [
      {
        "field": "price",
        "code": "REQUIRED",
        "message": "Price is required"
      },
      {
        "field": "sku",
        "code": "REQUIRED",
        "message": "SKU is required"
      }
    ]
  }
}
```

### Response Formatting

#### Consistent Envelope

Wrap responses uniformly:

```
# Success responses
{
  "data": {...},
  "meta": {
    "requestId": "req_abc123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}

# Collection responses
{
  "data": [...],
  "meta": {
    "pagination": {...}
  }
}

# Error responses
{
  "error": {...},
  "meta": {
    "requestId": "req_abc123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

Alternative: No envelope for simple responses, envelope only for metadata needs.

#### Null vs Omission

Document handling of null/missing values:

```
# Option 1: Include null values
{
  "name": "John Doe",
  "middleName": null,
  "email": "john@example.com"
}

# Option 2: Omit null values (more compact)
{
  "name": "John Doe",
  "email": "john@example.com"
}
```

Choose one strategy and apply consistently.

#### Date and Time Format

Use ISO 8601 with UTC:

```
{
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T14:45:30.123Z",
  "scheduledFor": "2024-02-01T09:00:00Z"
}

❌ Avoid:
{
  "createdAt": "01/15/2024 10:30 AM",
  "timestamp": 1705320600
}
```

#### Boolean Representation

Use actual booleans, not strings or integers:

```
✅ Correct:
{
  "active": true,
  "verified": false
}

❌ Avoid:
{
  "active": "true",
  "verified": 0
}
```

### Testing and Quality

#### Contract Testing

Validate API behavior matches specification:

```javascript
// Example using Pact
describe('User API', () => {
  it('returns user by ID', async () => {
    await provider.addInteraction({
      state: 'user 123 exists',
      uponReceiving: 'a request for user 123',
      withRequest: {
        method: 'GET',
        path: '/users/123',
        headers: { Accept: 'application/json' }
      },
      willRespondWith: {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
        body: {
          id: 123,
          name: 'John Doe',
          email: 'john@example.com'
        }
      }
    });
  });
});
```

#### Regression Testing

Maintain test suites for all endpoints:

```javascript
// Integration test example
test('GET /users/:id returns 404 for non-existent user', async () => {
  const response = await request(app)
    .get('/users/99999')
    .set('Authorization', 'Bearer token');
    
  expect(response.status).toBe(404);
  expect(response.body.error.code).toBe('RESOURCE_NOT_FOUND');
});

test('POST /users creates user with valid data', async () => {
  const response = await request(app)
    .post('/users')
    .send({
      name: 'Jane Doe',
      email: 'jane@example.com'
    });
    
  expect(response.status).toBe(201);
  expect(response.body.data).toHaveProperty('id');
  expect(response.headers.location).toMatch(/\/users\/\d+/);
});
```

#### Load Testing

Verify performance under stress:

```javascript
// Example using k6
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 }, // Ramp up
    { duration: '5m', target: 100 }, // Sustained load
    { duration: '2m', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% under 500ms
    http_req_failed: ['rate<0.01'],   // Error rate < 1%
  },
};

export default function () {
  const res = http.get('https://api.example.com/users');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
```

### Logging and Observability

#### Request Logging

Log all requests with context:

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req_abc123",
  "method": "POST",
  "path": "/users",
  "queryParams": {},
  "statusCode": 201,
  "responseTime": 145,
  "userAgent": "Mozilla/5.0...",
  "ip": "192.168.1.100",
  "userId": "user_789"
}
```

#### Correlation IDs

Track requests across services:

```
POST /orders
X-Request-ID: req_abc123

# Propagate to downstream services
POST https://payment-service.internal/process
X-Request-ID: req_abc123
X-Parent-Request-ID: req_abc123

# Include in responses
201 Created
X-Request-ID: req_abc123
```

Clients can provide request IDs for tracing:

```
POST /users
X-Request-ID: client_generated_uuid
```

#### Structured Logging

Use structured formats for machine parsing:

```json
{
  "level": "error",
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req_abc123",
  "error": {
    "type": "DatabaseError",
    "message": "Connection timeout",
    "stack": "..."
  },
  "context": {
    "userId": "user_789",
    "operation": "createOrder",
    "duration": 5000
  }
}
```

### Performance Optimization

#### Response Compression

Compress large responses:

```
GET /products
Accept-Encoding: gzip

200 OK
Content-Encoding: gzip
Content-Length: 1234
# Compressed payload
```

Compression typically beneficial for responses > 1KB.

#### Conditional Requests

Minimize bandwidth with ETags:

```
GET /users/123
If-None-Match: "v1-abc123"

304 Not Modified
# No body transmitted
```

#### Partial Responses

Allow clients to request subsets:

```
GET /users/123?fields=id,name,email

{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com"
}
# Omits other fields like address, phone, etc.
```

#### Database Query Optimization

Avoid N+1 queries in list endpoints:

```
❌ Inefficient:
GET /users
# Fetches users, then makes separate query for each user's orders

✅ Optimized:
GET /users?include=orders
# Single query with JOIN or batch fetch
```

#### Connection Pooling

[Inference] Reuse database connections across requests to reduce overhead and improve response times.

### API Gateway Patterns

#### Request Routing

Gateway handles routing to services:

```
# External request
GET https://api.example.com/users/123

# Gateway routes to internal service
GET http://user-service.internal:8080/users/123
```

#### Request Transformation

Gateway modifies requests/responses:

```
# Client sends
GET /v1/users

# Gateway transforms to
GET /users
X-API-Version: 1
```

#### Rate Limiting at Gateway

Centralized rate limiting:

```
# Gateway enforces limits before reaching services
GET /users
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
```

#### Authentication at Gateway

Gateway validates tokens:

```
# Client request
GET /protected-resource
Authorization: Bearer token123

# Gateway validates token, forwards if valid
GET /protected-resource
X-User-ID: user_789
X-User-Roles: admin,user
```

---

