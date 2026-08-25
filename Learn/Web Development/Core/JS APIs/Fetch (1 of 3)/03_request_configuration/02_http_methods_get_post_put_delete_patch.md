## HTTP Methods (GET, POST, PUT, DELETE, PATCH)


### GET

**Primary Purpose** GET retrieves resource representations from servers. It requests data without modifying server state, making it the fundamental read operation in REST.

**Characteristics**

GET is safe—it produces no side effects on resources. Multiple identical GET requests leave the server in the same state. This safety enables aggressive caching, prefetching, and link crawling without concern for unintended consequences.

GET is idempotent—executing the same GET request multiple times produces identical results (assuming the resource hasn't changed independently). Network failures allow safe retries without risk of corruption.

GET requests should never contain request bodies. While HTTP specifications don't explicitly forbid bodies in GET requests, many intermediaries, proxies, and server implementations ignore or reject them. All parameters belong in the URI—query strings, path parameters, or fragments.

**Response Codes**

- 200 OK: Resource found and returned successfully
- 304 Not Modified: Cached version is current (conditional GET with If-None-Match or If-Modified-Since)
- 404 Not Found: Resource doesn't exist at the specified URI
- 400 Bad Request: Malformed query parameters or invalid filters
- 401 Unauthorized: Authentication required
- 403 Forbidden: Authenticated but lacks read permission
- 410 Gone: Resource previously existed but was permanently removed

**Query Parameters**

Query parameters customize GET requests without violating REST principles:

**Filtering:**

```
GET /products?category=electronics&price_max=1000&in_stock=true
GET /users?status=active&role=admin&created_after=2024-01-01
```

**Sorting:**

```
GET /articles?sort=published_date&order=desc
GET /users?sort=-created_at,name
```

**Pagination:**

```
GET /items?page=2&per_page=50
GET /items?offset=100&limit=50
GET /items?cursor=eyJpZCI6MTIzfQ&limit=20
```

**Field Selection:**

```
GET /users/123?fields=id,name,email
GET /products?fields=id,title,price&exclude=description,reviews
```

**Partial Representations:**

```
GET /users?embed=orders,preferences
GET /articles?expand=author,comments
```

**Search:**

```
GET /products?q=laptop&search_fields=title,description
GET /users?name_contains=john
```

**Query String Limitations**

URLs have practical length limits—browsers typically support 2,000-8,000 characters, though HTTP specifications don't mandate limits. Servers and proxies may impose their own restrictions. Complex filtering or large parameter sets can exceed these limits.

Query parameters appear in browser history, server logs, and referrer headers, creating privacy concerns for sensitive data. Avoid passing authentication tokens, personally identifiable information, or confidential data in query strings.

Special characters require URL encoding. Spaces become `%20` or `+`, ampersands become `%26`, and so on. This encoding increases URL length and complicates debugging.

**Caching Behavior**

GET responses are cacheable by default unless explicitly prohibited. Cache-Control headers govern caching:

```
Cache-Control: public, max-age=3600
Cache-Control: private, max-age=300
Cache-Control: no-cache
Cache-Control: no-store
```

Vary headers ensure caches store separate entries for different request characteristics:

```
Vary: Accept, Accept-Encoding, Accept-Language
```

Conditional GET requests using If-None-Match (with ETags) or If-Modified-Since (with timestamps) enable efficient cache validation:

```
GET /users/123
If-None-Match: "686897696a7c876b7e"

HTTP/1.1 304 Not Modified
ETag: "686897696a7c876b7e"
Cache-Control: max-age=300
```

Aggressive caching dramatically reduces server load and improves response times. Design APIs to maximize cacheability—use appropriate expiration times, implement ETags, and structure URLs to enable effective caching.

**Security Considerations**

GET requests expose all parameters in URLs. Proxies, load balancers, and intermediaries log complete URLs. Sensitive information in URLs persists in logs, browser history, and analytics systems.

Never authenticate using query parameters like `?token=abc123`. Use Authorization headers instead. Query parameter authentication creates numerous vulnerabilities—tokens appear in logs, get shared in URLs, and lack the protection HTTP headers provide.

GET requests enable Cross-Site Request Forgery (CSRF) when they trigger state changes. This is why GET must remain safe—browsers and intermediaries can preload, prefetch, and follow links automatically without user consent.

**Range Requests**

HTTP Range headers enable partial resource retrieval:

```
GET /videos/movie.mp4
Range: bytes=0-1023

HTTP/1.1 206 Partial Content
Content-Range: bytes 0-1023/10485760
Content-Length: 1024
```

Range requests support:

- Resumable downloads after connection failures
- Progressive media streaming
- Efficient access to large files when only portions are needed
- Parallel chunk downloads for faster transfers

Servers indicate Range support using Accept-Ranges header:

```
Accept-Ranges: bytes
Accept-Ranges: none
```

**Conditional GET Optimization**

Beyond basic caching, conditional GETs enable sophisticated optimization patterns:

**If-None-Match with ETags:**

```
GET /api/data
If-None-Match: "v1", "v2", "v3"

HTTP/1.1 304 Not Modified
ETag: "v2"
```

Clients can provide multiple ETags, and servers return 304 if any match.

**If-Modified-Since:**

```
GET /api/data
If-Modified-Since: Mon, 15 Jan 2024 10:00:00 GMT

HTTP/1.1 304 Not Modified
Last-Modified: Mon, 15 Jan 2024 09:45:00 GMT
```

Combining both provides robust validation:

```
GET /api/data
If-None-Match: "abc123"
If-Modified-Since: Mon, 15 Jan 2024 10:00:00 GMT
```

Servers prioritize If-None-Match when both are present.

**Collection Retrieval Patterns**

Collections present unique challenges. Large collections require pagination to prevent overwhelming clients and servers.

**Complete Small Collections:**

```
GET /users/123/preferences

{
  "theme": "dark",
  "language": "en",
  "notifications": true
}
```

Simple collections can return all items when counts remain manageable (typically under 100 items).

**Paginated Collections:**

```
GET /users?page=1&per_page=20

{
  "items": [...],
  "page": 1,
  "per_page": 20,
  "total": 1543,
  "total_pages": 78
}
```

**Cursored Collections:**

```
GET /posts?cursor=abc123&limit=20

{
  "items": [...],
  "next_cursor": "def456",
  "has_more": true
}
```

**Sparse Collections with Filtering:**

```
GET /users?status=active&role=admin&department=engineering

{
  "items": [...],
  "matched": 47,
  "filters_applied": {
    "status": "active",
    "role": "admin",
    "department": "engineering"
  }
}
```

### POST

**Primary Purpose** POST submits data to servers for processing. Unlike other methods with specific semantics, POST serves multiple purposes—resource creation, complex operations that don't fit other methods, and actions that exceed GET's URI length limits.

**Characteristics**

POST is neither safe nor idempotent. Each POST request potentially creates new resources or triggers distinct operations. Repeated identical POST requests typically create multiple resources or execute actions multiple times.

This lack of idempotency creates challenges for retry logic. Network timeouts leave uncertainty—did the request succeed? Retrying may create duplicates. Idempotency-Key headers address this problem (discussed below).

**Resource Creation**

POST commonly creates new resources. Clients POST to collection URIs, and servers assign identifiers:

```
POST /users
Content-Type: application/json

{
  "name": "Jane Doe",
  "email": "jane@example.com"
}

HTTP/1.1 201 Created
Location: /users/456
Content-Type: application/json

{
  "id": 456,
  "name": "Jane Doe",
  "email": "jane@example.com",
  "created_at": "2024-12-16T10:30:00Z"
}
```

201 Created indicates success. The Location header provides the URI for the newly created resource. Response bodies typically include the complete resource representation, including server-generated fields (IDs, timestamps, defaults).

**Creation Response Patterns**

**Full Resource in Response:** Most common—return the complete created resource. Clients receive server-generated values immediately without additional GET requests.

**Minimal Response:**

```
HTTP/1.1 201 Created
Location: /users/456
```

Return only Location header with 201. Reduces response size and server processing. Clients must GET the resource if they need details.

**Async Creation:**

```
HTTP/1.1 202 Accepted
Location: /operations/abc-123
Content-Type: application/json

{
  "operation_id": "abc-123",
  "status": "processing",
  "status_url": "/operations/abc-123"
}
```

202 Accepted indicates the request was accepted but processing isn't complete. Return operation identifier and status endpoint for polling.

**Response Codes**

- 201 Created: Resource successfully created
- 202 Accepted: Request accepted for processing but not completed
- 200 OK: Request processed successfully but didn't create a distinct resource (used when POST triggers calculations, searches, or operations)
- 400 Bad Request: Invalid request data, validation failures
- 401 Unauthorized: Authentication required
- 403 Forbidden: Authenticated but lacks create permission
- 409 Conflict: Resource already exists or violates uniqueness constraints
- 413 Payload Too Large: Request body exceeds size limits
- 415 Unsupported Media Type: Content-Type not supported
- 422 Unprocessable Entity: Syntactically valid but semantically invalid

**Request Body Formats**

**JSON (application/json):**

```
POST /articles
Content-Type: application/json

{
  "title": "Understanding REST",
  "content": "...",
  "tags": ["rest", "api", "http"],
  "published": true
}
```

JSON is the dominant format for REST APIs. Supports complex nested structures, arrays, and various data types. Human-readable and widely supported across languages.

**Form Data (application/x-www-form-urlencoded):**

```
POST /login
Content-Type: application/x-www-form-urlencoded

username=user&password=pass123&remember=true
```

Traditional HTML form encoding. Key-value pairs separated by ampersands. Special characters URL-encoded. Flat structure—no native support for nested objects or arrays. Primarily used for simple forms and legacy compatibility.

**Multipart (multipart/form-data):**

```
POST /uploads
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="title"

Document Title
------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="document.pdf"
Content-Type: application/pdf

[binary file content]
------WebKitFormBoundary--
```

Enables file uploads mixed with other form fields. Each part has its own headers and content type. Required for binary file uploads. More verbose than other formats.

**XML (application/xml):**

```
POST /orders
Content-Type: application/xml

<?xml version="1.0"?>
<order>
  <customer_id>123</customer_id>
  <items>
    <item>
      <product_id>789</product_id>
      <quantity>2</quantity>
    </item>
  </items>
</order>
```

Less common in modern REST APIs but still used in enterprise and legacy systems. More verbose than JSON. Supports schemas for validation (XSD).

**Non-Resource-Creation Uses**

**Complex Queries:** When query complexity exceeds URI length limits, POST can carry search criteria in the request body:

```
POST /users/search
Content-Type: application/json

{
  "filters": {
    "age": {"min": 25, "max": 40},
    "location": {"city": "New York", "radius": 50},
    "interests": ["technology", "music", "travel"]
  },
  "sort": ["-created_at", "name"],
  "page": 1,
  "per_page": 20
}
```

This violates REST principles (GET should retrieve resources), but practical considerations sometimes outweigh purity. Mark endpoints clearly as searches to avoid confusion.

**Operations and Actions:** POST handles operations that don't map to simple CRUD:

```
POST /invoices/123/send
Content-Type: application/json

{
  "recipient": "customer@example.com",
  "include_attachments": true
}

HTTP/1.1 200 OK
Content-Type: application/json

{
  "sent_at": "2024-12-16T10:35:00Z",
  "message_id": "msg_abc123"
}
```

Action-oriented endpoints use verbs in URIs, which conflicts with resource-oriented REST design. However, some operations don't fit resource metaphors. Controllers or actions provide pragmatic solutions.

**Batch Operations:**

```
POST /batch
Content-Type: application/json

{
  "operations": [
    {"method": "POST", "path": "/users", "body": {"name": "Alice"}},
    {"method": "PUT", "path": "/users/123", "body": {"name": "Bob"}},
    {"method": "DELETE", "path": "/users/456"}
  ]
}

HTTP/1.1 200 OK
Content-Type: application/json

{
  "results": [
    {"status": 201, "body": {"id": 789, "name": "Alice"}},
    {"status": 200, "body": {"id": 123, "name": "Bob"}},
    {"status": 204}
  ]
}
```

Batch endpoints reduce round-trips by executing multiple operations in one request. Particularly valuable for mobile or high-latency networks.

**Idempotency Keys**

POST's non-idempotent nature creates problems for retry logic. Idempotency-Key headers enable safe retries:

```
POST /payments
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
Content-Type: application/json

{
  "amount": 100.00,
  "currency": "USD",
  "source": "card_123"
}
```

Servers track idempotency keys (typically for 24 hours). Duplicate requests with the same key return the original response without re-executing. Clients generate unique keys (UUIDs) per logical operation.

Implementation considerations:

- Store key-response pairs with expiration
- Hash request bodies to detect key reuse with different data
- Return appropriate errors for mismatched bodies with same key
- Document key lifetime and storage guarantees

This pattern is particularly critical for financial transactions, order creation, and other operations where duplicates cause significant problems.

**File Upload Patterns**

**Direct Upload:**

```
POST /files
Content-Type: multipart/form-data; boundary=----Boundary

------Boundary
Content-Disposition: form-data; name="file"; filename="photo.jpg"
Content-Type: image/jpeg

[binary content]
------Boundary--

HTTP/1.1 201 Created
Location: /files/abc123

{
  "id": "abc123",
  "filename": "photo.jpg",
  "size": 2048576,
  "content_type": "image/jpeg",
  "url": "https://cdn.example.com/files/abc123"
}
```

Simple but server processes uploads directly. Large files consume server resources and bandwidth.

**Presigned URL Pattern:**

```
POST /files/upload-url
Content-Type: application/json

{
  "filename": "photo.jpg",
  "content_type": "image/jpeg",
  "size": 2048576
}

HTTP/1.1 200 OK

{
  "upload_url": "https://storage.example.com/presigned?token=xyz",
  "file_id": "abc123",
  "expires_at": "2024-12-16T11:30:00Z"
}
```

Server returns presigned URL. Client uploads directly to storage service (S3, Cloud Storage). Reduces server load and bandwidth. After upload completes, client may notify original API.

**Chunked Upload:** For very large files, upload in chunks:

```
POST /files
Content-Type: application/json

{
  "filename": "video.mp4",
  "size": 524288000,
  "chunk_size": 5242880
}

HTTP/1.1 201 Created

{
  "upload_id": "upload_xyz",
  "chunk_urls": [
    "/files/upload_xyz/chunks/0",
    "/files/upload_xyz/chunks/1",
    ...
  ]
}
```

Client PUTs each chunk to corresponding URL. After all chunks upload, finalize:

```
POST /files/upload_xyz/complete

HTTP/1.1 200 OK

{
  "file_id": "file_abc123",
  "url": "https://cdn.example.com/files/abc123"
}
```

Enables resumable uploads, parallel chunk uploading, and handles network interruptions gracefully.

**POST vs PUT for Creation**

POST to collections, servers assign URIs:

```
POST /users → creates /users/456
```

PUT to specific URIs, clients specify complete URI:

```
PUT /users/456 → creates /users/456
```

Use POST when:

- Server generates identifiers
- Creating resources within collections
- URI structure is server-controlled
- Multiple POSTs should create multiple resources

Use PUT when:

- Client controls the complete URI
- Creating resources at predetermined locations
- URI represents the resource completely
- Idempotency is required

### PUT

**Primary Purpose** PUT replaces entire resources at specific URIs. It provides complete resource representations, and servers replace existing resources entirely.

**Characteristics**

PUT is idempotent—executing the same PUT request multiple times produces identical results. The first PUT may create or replace a resource; subsequent identical PUTs leave the resource unchanged. This idempotency enables safe retries without concern for side effects.

PUT is not safe—it modifies server state by replacing resources.

**Complete Replacement Semantics**

PUT requires complete resource representations. Clients must include all fields, even unchanged ones:

```
PUT /users/123
Content-Type: application/json

{
  "id": 123,
  "name": "Jane Smith",
  "email": "jane.smith@example.com",
  "phone": "+1-555-0100",
  "address": {
    "street": "123 Main St",
    "city": "New York",
    "country": "US"
  },
  "preferences": {
    "theme": "dark",
    "language": "en"
  }
}

HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": 123,
  "name": "Jane Smith",
  "email": "jane.smith@example.com",
  "phone": "+1-555-0100",
  "address": {
    "street": "123 Main St",
    "city": "New York",
    "country": "US"
  },
  "preferences": {
    "theme": "dark",
    "language": "en"
  },
  "updated_at": "2024-12-16T10:40:00Z"
}
```

Omitted fields are removed or reset to defaults. If the client PUTs without including `phone`, the server removes the phone number. This behavior distinguishes PUT from PATCH.

**Response Codes**

- 200 OK: Resource successfully replaced, response includes updated representation
- 204 No Content: Resource successfully replaced, no response body
- 201 Created: Resource didn't exist and was created (when servers allow PUT to create resources)
- 400 Bad Request: Invalid request data or validation failures
- 401 Unauthorized: Authentication required
- 403 Forbidden: Authenticated but lacks update permission
- 404 Not Found: Resource doesn't exist (when servers don't allow PUT to create resources)
- 409 Conflict: Request conflicts with current state (often with concurrent modifications)
- 412 Precondition Failed: Conditional PUT failed (If-Match, If-Unmodified-Since)
- 413 Payload Too Large: Request body exceeds limits
- 415 Unsupported Media Type: Content-Type not supported
- 422 Unprocessable Entity: Syntactically valid but semantically invalid

**Resource Creation with PUT**

Some APIs allow PUT to create resources when they don't exist:

```
PUT /users/new-user-456
Content-Type: application/json

{
  "id": "new-user-456",
  "name": "John Doe",
  "email": "john@example.com"
}

HTTP/1.1 201 Created
Location: /users/new-user-456
Content-Type: application/json

{
  "id": "new-user-456",
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2024-12-16T10:45:00Z"
}
```

This pattern works when clients control URIs completely. More commonly, servers generate identifiers and PUT only updates existing resources.

**Idempotency Implementation**

PUT's idempotency stems from its replacement semantics. Given a specific resource state and PUT request, the outcome is deterministic:

```
PUT /users/123 with {"name": "Alice", "email": "alice@example.com"}
```

Whether executed once or one hundred times, the resource ends in the same state: name is "Alice", email is "alice@example.com".

However, server-controlled fields complicate matters. Timestamps like `updated_at` change with each PUT. Counters, version numbers, or audit logs may increment. Strict idempotency means resource state is identical; practical idempotency means the resource represents the same logical state despite metadata changes.

External side effects also affect idempotency. If PUT triggers emails, webhook notifications, or third-party API calls, repeated PUTs generate duplicate actions. [Inference] Truly idempotent implementations should detect duplicate PUTs and skip side effects, though this requires tracking recent requests or using idempotency keys.

**Conditional PUT with Optimistic Locking**

Conditional requests prevent concurrent modification conflicts. Clients include If-Match headers with ETags retrieved from previous GETs:

```
GET /users/123

HTTP/1.1 200 OK
ETag: "v1"

{
  "id": 123,
  "name": "Alice",
  "email": "alice@example.com"
}
```

Later, the client PUTs an update with the ETag:

```
PUT /users/123
If-Match: "v1"
Content-Type: application/json

{
  "id": 123,
  "name": "Alice Updated",
  "email": "alice@example.com"
}
```

If the resource changed since the GET (ETag no longer matches), the server returns 412 Precondition Failed:

```
HTTP/1.1 412 Precondition Failed
ETag: "v2"

{
  "error": "Resource was modified by another client"
}
```

Client must GET the current state, merge changes, and retry the PUT with the new ETag.

If the ETag matches, the server processes the PUT:

```
HTTP/1.1 200 OK
ETag: "v3"

{
  "id": 123,
  "name": "Alice Updated",
  "email": "alice@example.com",
  "updated_at": "2024-12-16T10:50:00Z"
}
```

**If-Unmodified-Since** provides timestamp-based conditional requests:

```
PUT /users/123
If-Unmodified-Since: Mon, 16 Dec 2024 10:00:00 GMT
```

Servers compare Last-Modified against If-Unmodified-Since. If the resource was modified after the specified time, return 412.

**Partial Updates and PUT**

PUT's complete replacement semantics create problems for partial updates. Clients must retrieve the full resource, modify desired fields, and PUT the complete representation:

```
GET /users/123

{
  "id": 123,
  "name": "Alice",
  "email": "alice@example.com",
  "phone": "+1-555-0100",
  "address": {...},
  "preferences": {...}
}
```

To change only the email:

```
PUT /users/123

{
  "id": 123,
  "name": "Alice",
  "email": "newemail@example.com",
  "phone": "+1-555-0100",
  "address": {...},
  "preferences": {...}
}
```

This approach wastes bandwidth and creates race conditions. While client A reads the resource, client B might modify it. Client A's PUT then overwrites client B's changes.

PATCH solves this problem by supporting partial updates.

**PUT for Non-Resource Operations**

While PUT typically updates resources, some APIs use PUT for idempotent operations:

```
PUT /cache/keys/session_123
Content-Type: application/json

{
  "data": {"user_id": 456, "expires": 3600},
  "ttl": 3600
}
```

Setting cache keys, configuration values, or other idempotent settings fits PUT semantics.

**Caching Considerations**

PUT requests are not cacheable—responses don't provide reusable data for future requests. However, successful PUTs invalidate cached GET responses for the same URI. Caches must discard stale entries.

Servers can include Cache-Control headers in PUT responses if returning resource representations, affecting subsequent GET requests:

```
PUT /users/123

HTTP/1.1 200 OK
ETag: "v3"
Cache-Control: max-age=300

{...}
```

### DELETE

**Primary Purpose** DELETE removes resources from servers. It instructs servers to delete the resource identified by the URI.

**Characteristics**

DELETE is idempotent—deleting a resource multiple times produces the same result. The first DELETE removes the resource; subsequent DELETEs find the resource already gone. The end state is identical.

DELETE is not safe—it modifies server state by removing resources.

**Basic Usage**

```
DELETE /users/123

HTTP/1.1 204 No Content
```

Most DELETE operations return 204 No Content—the operation succeeded but there's no representation to return.

Alternatively, return 200 OK with a response body:

```
DELETE /users/123

HTTP/1.1 200 OK
Content-Type: application/json

{
  "message": "User successfully deleted",
  "deleted_at": "2024-12-16T11:00:00Z"
}
```

**Response Codes**

- 204 No Content: Resource successfully deleted, no response body
- 200 OK: Resource successfully deleted with response body
- 202 Accepted: Deletion request accepted but not completed (asynchronous deletion)
- 404 Not Found: Resource doesn't exist (some APIs return 404, others return 204 for idempotency)
- 401 Unauthorized: Authentication required
- 403 Forbidden: Authenticated but lacks delete permission
- 409 Conflict: Resource cannot be deleted due to dependencies or constraints
- 410 Gone: Resource was already deleted

**Idempotency and 404 vs 204**

DELETE idempotency creates a design choice: should deleting a non-existent resource return 404 or 204?

**Return 204 for idempotency:**

```
DELETE /users/999

HTTP/1.1 204 No Content
```

This approach emphasizes idempotency. Whether the resource existed or not, the desired end state is achieved—the resource doesn't exist. Clients don't need to check existence before deleting. Retry logic remains simple.

**Return 404 for accuracy:**

```
DELETE /users/999

HTTP/1.1 404 Not Found

{
  "error": "User not found"
}
```

This approach provides explicit feedback. Clients know whether deletion succeeded or the resource never existed. Useful for detecting errors in client logic (wrong ID, race conditions).

**Return 410 Gone for previously-deleted:**

```
DELETE /users/999

HTTP/1.1 410 Gone

{
  "error": "User was already deleted",
  "deleted_at": "2024-12-15T14:30:00Z"
}
```

410 Gone indicates the resource previously existed but is permanently unavailable. This provides more information than 404 while maintaining idempotency—repeated DELETEs still return 410.

[Inference] The choice depends on API design philosophy. Strict REST interpretation favors 204 for idempotency. Practical implementations often prefer 404 or 410 for clarity.

**Soft Deletes**

Many applications implement soft deletes—marking resources as deleted without removing data:

```
DELETE /users/123

HTTP/1.1 204 No Content
```

Backend marks the user as deleted but preserves the record:

```json
{
  "id": 123,
  "name": "Alice",
  "email": "alice@example.com",
  "deleted": true,
  "deleted_at": "2024-12-16T11:05:00Z"
}
```

Subsequent GET requests return 404 or 410:

```
GET /users/123

HTTP/1.1 404 Not Found
```

Soft deletes enable:

- Audit trails and compliance (retaining historical records)
- Undo functionality (restore deleted resources)
- Referential integrity (preserving foreign key relationships)
- Analytics on deleted resources

To permanently delete (hard delete):

```
DELETE /users/123?permanent=true
```

Or provide separate endpoints:

```
DELETE /users/123/permanent
```

**Cascade Deletes and Dependencies**

Deleting resources with dependencies raises questions:

```
DELETE /users/123
```

Should this delete the user's orders, comments, uploaded files? Should it fail if dependencies exist?

**Return 409 Conflict when dependencies exist:**

```
DELETE /users/123

HTTP/1.1 409 Conflict

{
  "error": "Cannot delete user with existing orders",
  "dependencies": {
    "orders": 15,
    "comments": 47
  }
}
```

Require clients to explicitly handle dependencies first.

**Cascade delete with confirmation:**

```
DELETE /users/123?cascade=true
```

Query parameter or header indicates cascade should occur.

**Return details about cascaded deletes:**

```
DELETE /users/123?cascade=true

HTTP/1.1 200 OK

{
  "deleted": {
    "users": 1,
    "orders": 15,
    "comments": 47,
    "files": 3
  }
}
```

**Transfer ownership rather than delete:** Some resources shouldn't be deleted with their owners. Comments might transfer to [deleted] users. Files might move to an archive account.

**Asynchronous Deletion**

Large-scale deletions or complex cascade operations may require asynchronous processing:

```
DELETE /users/123

HTTP/1.1 202 Accepted
Location: /operations/del_abc123

{
  "operation_id": "del_abc123",
  "status": "pending",
  "status_url": "/operations/del_abc123"
}
```

Client polls the status endpoint:

```
GET /operations/del_abc123

HTTP/1.1 200 OK

{
  "operation_id": "del_abc123",
  "status": "in_progress",
  "started_at": "2024-12-16T11:05:00Z",
  "estimated_completion": "2024-12-16T11:10:00Z"
}
```

Eventually:

```
GET /operations/del_abc123

HTTP/1.1 200 OK

{
  "operation_id": "del_abc123",
  "status": "completed",
  "started_at": "2024-12-16T11:05:00Z",
  "completed_at": "2024-12-16T11:08:00Z",
  "deleted": {
    "users": 1,
    "related_records": 234
  }
}
```

**Bulk Deletes**

Deleting multiple resources individually is inefficient:

```
DELETE /users/123
DELETE /users/124
DELETE /users/125
...
```

Bulk delete options:

**Query parameter approach:**

```
DELETE /users?ids=123,124,125

HTTP/1.1 200 OK

{
  "deleted": 3,
  "ids": [123, 124, 125]
}
```

**Request body approach:**

```
DELETE /users
Content-Type: application/json

{
  "ids": [123, 124, 125]
}

HTTP/1.1 200 OK

{
  "deleted": 3, 
  "failed": 0, 
  "results": [
	  {"id": 123, "status": "deleted"},
	  {"id": 124, "status": "deleted"}, 
	  {"id": 125, "status": "deleted"} 
  ]
}
```

Note: Including request bodies in DELETE requests is controversial. HTTP specifications don't prohibit it, but many client libraries and intermediaries handle DELETE bodies inconsistently. Some implementations use POST to `/users/bulk-delete` instead.

**Filter-based deletion:**
```

DELETE /users?status=inactive&last_login_before=2023-01-01

HTTP/1.1 200 OK

{ "deleted": 1247, "filter": { "status": "inactive", "last_login_before": "2023-01-01" } }

```

Filter-based deletes are powerful but dangerous. Require confirmation, implement safeguards, and log extensively.

**Conditional Deletes**

Like PUT, DELETE supports conditional requests:

```

DELETE /users/123 If-Match: "v5"

HTTP/1.1 204 No Content

```

If the resource changed (ETag doesn't match), return 412:

```

DELETE /users/123 If-Match: "v5"

HTTP/1.1 412 Precondition Failed ETag: "v6"

{ "error": "Resource was modified" }

```

This prevents accidental deletion of updated resources.

**Restoring Deleted Resources**

APIs implementing soft deletes might provide restoration:

```

POST /users/123/restore

HTTP/1.1 200 OK

{ "id": 123, "name": "Alice", "email": "alice@example.com", "deleted": false, "restored_at": "2024-12-16T11:15:00Z" }

```

Or use PUT with a specific state:

```

PUT /users/123 Content-Type: application/json

{ "deleted": false }

HTTP/1.1 200 OK

```

**Security Considerations**

DELETE operations require careful authorization. Verify not just that users are authenticated, but that they have permission to delete specific resources.

Common patterns:
- Users can delete only their own resources
- Admins can delete any resources
- Resources can be deleted only by their owners or assigned users
- Some resources cannot be deleted, only archived

Rate limit DELETE operations more aggressively than reads. Bulk deletes especially warrant strict limits and additional authentication requirements.

Log all deletion operations comprehensively. Include who deleted what, when, and from what IP address. This audit trail is crucial for security investigations and compliance.

### PATCH

**Primary Purpose**
PATCH applies partial modifications to resources. Unlike PUT, which replaces entire resources, PATCH updates only specified fields.

**Characteristics**

PATCH is not inherently idempotent—repeated PATCH requests may produce different results depending on the patch format. However, specific patch formats can be designed for idempotency.

PATCH is not safe—it modifies resource state.

**Partial Update Semantics**

PATCH sends only changed fields:

```

PATCH /users/123 Content-Type: application/json

{ "email": "newemail@example.com" }

HTTP/1.1 200 OK

{ "id": 123, "name": "Alice", "email": "newemail@example.com", "phone": "+1-555-0100", "updated_at": "2024-12-16T11:20:00Z" }

```

Only `email` changes; other fields remain untouched. This solves the bandwidth and race condition problems with PUT.

**Response Codes**
- 200 OK: Resource successfully updated, includes updated representation
- 204 No Content: Resource successfully updated, no response body
- 400 Bad Request: Invalid patch document or validation failures
- 401 Unauthorized: Authentication required
- 403 Forbidden: Authenticated but lacks update permission
- 404 Not Found: Resource doesn't exist
- 409 Conflict: Patch conflicts with current resource state
- 412 Precondition Failed: Conditional PATCH failed
- 415 Unsupported Media Type: Patch format not supported
- 422 Unprocessable Entity: Patch is valid but cannot be applied

**Simple JSON Merge Patch (RFC 7396)**

The simplest PATCH format uses JSON Merge Patch:

```

PATCH /users/123 Content-Type: application/merge-patch+json

{ "email": "updated@example.com", "phone": null }

```

Fields in the patch replace corresponding fields in the resource. `null` values delete fields. Missing fields remain unchanged.

**Advantages:**
- Simple to understand and implement
- Minimal overhead
- Natural JSON syntax

**Limitations:**
- Cannot distinguish between setting a field to `null` and deleting it
- Cannot append to arrays, only replace them entirely
- Cannot perform conditional updates
- No way to test current values before applying changes

**JSON Patch (RFC 6902)**

JSON Patch provides more sophisticated operations:

```

PATCH /users/123 Content-Type: application/json-patch+json

[ {"op": "replace", "path": "/email", "value": "updated@example.com"}, {"op": "remove", "path": "/phone"}, {"op": "add", "path": "/preferences/notifications", "value": true} ]

````

**Operations:**

**Add:**
```json
{"op": "add", "path": "/tags/0", "value": "important"}
````

Adds value at path. For arrays, inserts at specified index. For objects, sets the field.

**Remove:**

```json
{"op": "remove", "path": "/deprecated_field"}
```

Removes the value at path.

**Replace:**

```json
{"op": "replace", "path": "/status", "value": "active"}
```

Replaces value at path. Fails if path doesn't exist.

**Move:**

```json
{"op": "move", "from": "/old_location", "path": "/new_location"}
```

Moves value from one path to another.

**Copy:**

```json
{"op": "copy", "from": "/template", "path": "/new_instance"}
```

Copies value from one path to another.

**Test:**

```json
{"op": "test", "path": "/version", "value": 5}
```

Verifies value at path matches the specified value. Fails the entire patch if test fails. Enables conditional updates.

**JSON Patch Example—Conditional Update:**

```
PATCH /users/123
Content-Type: application/json-patch+json

[
  {"op": "test", "path": "/status", "value": "pending"},
  {"op": "replace", "path": "/status", "value": "approved"},
  {"op": "add", "path": "/approved_at", "value": "2024-12-16T11:25:00Z"}
]
```

This patch succeeds only if status is currently "pending". If the test fails, the entire patch is rejected, maintaining atomicity.

**Advantages of JSON Patch:**

- Precise control over modifications
- Array manipulation (insert, append, reorder)
- Conditional updates via test operations
- Atomic patches—all operations succeed or all fail
- Clear semantics for each operation

**Disadvantages:**

- More complex than merge patch
- Verbose for simple updates
- Requires understanding of JSON Pointer syntax (RFC 6901)
- Less intuitive for developers unfamiliar with the standard

**Custom Patch Formats**

Some APIs implement custom patch formats optimized for their domain:

```
PATCH /users/123
Content-Type: application/json

{
  "operations": [
    {"field": "email", "action": "set", "value": "new@example.com"},
    {"field": "tags", "action": "append", "value": "premium"},
    {"field": "metadata.last_login", "action": "set", "value": "2024-12-16T11:00:00Z"}
  ]
}
```

Custom formats provide domain-specific operations but sacrifice standardization and require custom client implementations.

**Idempotency Considerations**

Simple merge patches with absolute values are idempotent:

```
PATCH /users/123
Content-Type: application/merge-patch+json

{
  "status": "active",
  "email": "fixed@example.com"
}
```

Repeated identical patches produce the same result.

Relative operations are not idempotent:

```
PATCH /users/123
Content-Type: application/json

{
  "balance": "+10.00"
}
```

Each application increments balance by 10. Repeated patches keep increasing the value.

[Inference] To make relative operations idempotent, use idempotency keys or include version checks:

```
PATCH /users/123
If-Match: "v7"
Content-Type: application/json

{
  "balance": "+10.00"
}
```

**Nested Object Updates**

PATCH handles nested structures naturally:

**Merge patch replaces entire nested objects:**

```
PATCH /users/123
Content-Type: application/merge-patch+json

{
  "preferences": {
    "theme": "dark"
  }
}
```

This replaces the entire `preferences` object with `{"theme": "dark"}`, removing any other preference fields.

**JSON Patch updates specific nested fields:**

```
PATCH /users/123
Content-Type: application/json-patch+json

[
  {"op": "replace", "path": "/preferences/theme", "value": "dark"}
]
```

This changes only `/preferences/theme`, leaving other preference fields intact.

**Array Modifications**

**Merge patch replaces entire arrays:**

```
PATCH /users/123
Content-Type: application/merge-patch+json

{
  "tags": ["premium", "verified"]
}
```

Replaces the tags array completely.

**JSON Patch manipulates array elements:**

Add to end:

```json
[
  {"op": "add", "path": "/tags/-", "value": "new-tag"}
]
```

Insert at position:

```json
[
  {"op": "add", "path": "/tags/0", "value": "first-tag"}
]
```

Remove specific element:

```json
[
  {"op": "remove", "path": "/tags/2"}
]
```

Replace element:

```json
[
  {"op": "replace", "path": "/tags/1", "value": "updated-tag"}
]
```

**Validation and Constraints**

PATCH requests must still satisfy validation rules:

```
PATCH /users/123
Content-Type: application/merge-patch+json

{
  "email": "invalid-email"
}

HTTP/1.1 422 Unprocessable Entity

{
  "error": "Validation failed",
  "fields": {
    "email": ["Must be a valid email address"]
  }
}
```

Servers validate the resource state after applying patches, not just the patch itself.

**Conditional PATCH**

Like PUT and DELETE, PATCH supports conditional requests:

```
PATCH /users/123
If-Match: "v8"
Content-Type: application/merge-patch+json

{
  "status": "active"
}

HTTP/1.1 200 OK
ETag: "v9"

{
  "id": 123,
  "status": "active",
  "updated_at": "2024-12-16T11:30:00Z"
}
```

Conditional PATCH prevents lost updates when multiple clients modify the same resource.

**PATCH vs PUT Decision**

**Use PATCH when:**

- Updating only specific fields
- Large resources where sending complete representations wastes bandwidth
- High concurrency—partial updates reduce conflicts
- Resources have many optional fields
- Clients shouldn't know complete resource structure

**Use PUT when:**

- Complete resource replacement matches semantics
- Simplicity is valued over efficiency
- Resources are small
- Complete control over resource state is needed
- Idempotency is critical (PUT is inherently idempotent)

**NULL Handling Ambiguity**

Different interpretations of `null` create confusion:

**Interpretation 1—Set to null:**

```
PATCH /users/123

{
  "middle_name": null
}
```

Sets middle_name to null (representing "no middle name").

**Interpretation 2—Delete field:**

```
PATCH /users/123

{
  "middle_name": null
}
```

Removes the middle_name field entirely.

**Interpretation 3—Ignore:** Some implementations ignore null values, leaving fields unchanged.

JSON Merge Patch (RFC 7396) specifies that `null` deletes fields. However, this creates problems when the domain requires `null` as a value distinct from absent.

APIs should document null handling clearly. Consider using explicit operations for deletion:

```
PATCH /users/123

{
  "middle_name": {"$delete": true}
}
```

Or use JSON Patch for unambiguous semantics.

**Error Handling**

PATCH operations can fail partially or completely:

**Atomic failure—reject entire patch if any operation fails:**

```
PATCH /users/123
Content-Type: application/json-patch+json

[
  {"op": "replace", "path": "/email", "value": "valid@example.com"},
  {"op": "replace", "path": "/age", "value": -5}
]

HTTP/1.1 422 Unprocessable Entity

{
  "error": "Patch validation failed",
  "failed_operation": 1,
  "details": "Age must be positive"
}
```

Resource remains unchanged. All operations succeed or all fail.

**Partial success—apply successful operations, report failures:**

```
HTTP/1.1 200 OK

{
  "success": [
    {"op": "replace", "path": "/email", "status": "applied"}
  ],
  "failed": [
    {"op": "replace", "path": "/age", "error": "Age must be positive"}
  ]
}
```

Some operations applied, others rejected. This approach is less common and can lead to unexpected states.

Most REST APIs follow atomic PATCH semantics—either the entire patch succeeds or the entire patch fails.

---

