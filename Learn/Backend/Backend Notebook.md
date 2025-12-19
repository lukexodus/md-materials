# Roadmap

**Backend Engineering Fundamentals**
- Backend engineering encompasses building reliable, scalable, fault-tolerant, and maintainable codebases and efficient systems
- The field extends far beyond creating CRUD APIs
- Learning resources are abundant but prioritization and understanding the big picture remain challenging
- Most developers build expertise gradually through trial and error and learning from others over years

**Course Approach and Philosophy**
- This curriculum focuses on foundational concepts rather than specific languages or frameworks
- Understanding underlying systems enables knowledge transfer across different programming languages
- Language-agnostic knowledge prevents blind spots that come from framework-specific perspectives

**Request Flow and System Communication**
- How browser requests flow through different network hops and firewalls
- Request routing over the internet to remote AWS servers
- Server response mechanisms and structure
- Client-server communication patterns

**HTTP Protocol**
- Role and fundamentals of HTTP protocol
- Structure of raw HTTP messages
- HTTP headers: request headers, representational headers, general headers, security headers
- HTTP methods: GET, POST, PUT, DELETE with semantics and principles
- CORS flow and differences between simple requests and pre-flight requests
- HTTP response structure and status codes
- HTTP caching techniques: ETags, max-age headers
- Differences between HTTP 1.1, HTTP 2.0, and HTTP 3.0
- Content negotiation between client and server
- Persistent connections in HTTP
- HTTP compression: gzip, deflate, and Brotli
- Security: SSL, TLS, and HTTPS

**Routing**
- Mapping URLs to server-side logic
- Connection between routing and HTTP methods
- Route components: path parameters and query parameters
- Route types: static, dynamic, nested, hierarchical, catch-all, wildcard, and regex-based routes
- API versioning using HTTP
- Versioning techniques and best practices
- Deprecation strategies
- Route grouping benefits for versioning, permissions, and shared middleware
- Route security and optimization of route matching performance

**Serialization and Deserialization**
- Translation of data into specific formats for network transmission
- Need for interoperability and standards
- Text-based formats: JSON and XML
- Binary formats: Protocol Buffers
- Performance differences and use case selection
- Language-specific implementation approaches
- JSON structure: strings, numbers, booleans, arrays, objects
- Handling nested objects and collections
- Deserialization into native data structures (Python dictionaries, Go structs, JavaScript objects)
- Common errors: missing fields, extra fields, null values, date serialization, timezone issues
- Custom serialization implementation
- Error handling: invalid data, data conversion errors, unknown fields
- Security concerns: injection attacks, validation requirements, JSON schema validation
- Performance considerations: compression, eliminating unnecessary fields
- Trade-offs between readability and performance (JSON versus Protocol Buffers)

**Authentication and Authorization**
- Purpose and necessity of authentication and authorization
- Stateful versus stateless authentication
- Authentication types: basic authentication, bearer token authentication
- Sessions, JWTs, and cookies
- OAuth protocol and OpenID Connect deep dive
- API keys functionality
- Multi-factor authentication
- Cryptographic techniques: salting and hashing
- Authorization models: ABAC, RBAC, ReBAC
- Security best practices: securing cookies, preventing CSRF, XSS, and MITM attacks
- Audit logging: recording authentication and authorization events
- Monitoring failed login attempts and privilege escalation
- Access tracking to sensitive resources
- Obfuscating error messages to prevent information leakage
- Handling edge cases with consistent responses
- Rate limiting and account lockout mechanisms
- Preventing timing attacks through consistent response times

**Validation and Transformation**
- Syntactic validation: email format, phone numbers, date formats
- Semantic validation: date of birth constraints, age ranges
- Type validation: verifying strings, integers, arrays, objects
- Best practices for validation
- Client-side versus server-side validation
- Importance of server-side validation as security gateway
- Failing fast to reduce unnecessary processing
- Consistency between frontend and backend validation
- Type casting: string to number conversions
- Date format transformations and timestamp handling
- Normalization: email lowercase conversion, whitespace trimming, country code addition
- Sanitization for preventing SQL injection
- Complex validation: relationship-based validation, conditional validation, chain validation
- Error handling: meaningful error messages, aggregating validation errors, obfuscating sensitive information
- Gracefully handling failed transformations
- Performance trade-offs and optimization through early returns

**Middleware**
- Definition and use cases of middleware
- Common middleware applications
- Role in request cycle: pre-request and post-response middleware
- Middleware chaining and execution sequence
- Middleware ordering: logging, authentication, validation, route handling, error handling
- Next function operation and early exit mechanisms
- Short-circuiting request pipeline for 404 errors
- Security middlewares: security headers, CORS headers, CSRF protection, rate limiting
- Authentication middleware for route protection
- Logging and monitoring middlewares: request logging, structured logging
- Error handling middleware for consistent API responses
- Compression and performance middlewares
- Data parsing middleware: JSON, URL-encoded forms, file uploads, multipart data
- Performance and scalability considerations
- Best practices: lightweight design, correct ordering, performance and security impact

**Request Context**
- Metadata passed through application layers
- Request-scoped state management
- Context lifecycle and state maintenance
- Sharing data across application layers without coupling
- Components: request metadata (HTTP method, URL, headers, query parameters, body)
- Session and user information injection
- Tracking and logging information: unique request IDs, trace IDs
- Request-specific data: custom data, caching data, permission checks
- Use cases: authentication, rate limiting, tracing, logging
- Connection between middlewares and request contexts
- Timeout types: request timeouts, custom timeouts, cancellation signals
- Best practices: lightweight implementation, memory cleanup, avoiding tight coupling

**Handlers and Controllers**
- MVC pattern explanation
- Responsibilities of handlers, controllers, and services
- Reducing code duplication with middleware
- Centralized error handling
- Consistent success and error message formats
- CRUD operations mapping to HTTP methods
- Common APIs for each method: POST for creation (201 status), GET for fetching resources, PUT and PATCH for updates, DELETE for deletions
- Pagination implementation
- Search API design
- Sorting and filtering mechanisms
- Best practices: strict validation, consistent response formatting, payload limits, sensitive field redaction, error handling, authentication and authorization

**RESTful Architecture**
- Principles of designing APIs around resources
- Adhering to HTTP semantics
- Best practices for filtering and pagination
- Versioning approaches: URI versioning, header versioning, query string versioning, media type versioning
- Designing APIs with OpenAPI specification
- Content negotiation
- Exception capturing with meaningful messages
- Supporting client-side caching with ETags
- Optimizing large requests and responses

**Databases**
- Relational versus non-relational databases
- When to use each database type
- Theoretical concepts: ACID and CAP theorem
- Basic querying and joins
- Database design best practices: schema design and indexing
- Optimization methods: query optimization, caching, connection pooling
- Data integrity: constraints, validations, transactions, concurrency
- ORMs: functionality, trade-offs, when to use
- Database migrations

**Business Logic Layer**
- Role of business logic layer in application architecture
- Request cycle layers: validation, routing, middlewares, handlers and controllers (presentation layer)
- Business logic layer as core business logic handler
- Data access layer for database operations
- Design principles: separation of concerns, single responsibility, open-close principle, dependency inversion
- Components: services, domain models (users, orders), business rules, business validation logic
- Service layer design best practices
- Error handling and propagation from service layer to presentation layer

**Caching**
- Need for caching versus database persistence
- Caching types: memory caching, browser caching, database caching
- Client-side versus server-side caching
- Caching strategies: cache-aside, write-through, write-behind (write-back), read-through
- Cache eviction strategies: LRU, LFU, TTL, FIFO
- Cache invalidation: manual, time-to-live, event-based
- Caching levels: Level 1 (in-memory), Level 2 (network distributed), hierarchical caching
- Caching for web applications: static assets, API responses using headers
- Database query caching: storing heavy join results in Redis
- Cache hit and cache miss ratio optimization

**Transactional Emails**
- Purpose and use cases of transactional emails
- Common applications
- Email anatomy: subject, preheader, body, header, main content, CTA, footer
- Personalization with dynamic parameters

**Task Queuing and Scheduling**
- Common use cases: sending emails, processing images, third-party API integration
- Payment processing and webhooks
- Offloading heavy computation like batch processing
- Scheduling use cases: database backups, recurring notifications, data synchronization, maintenance tasks
- Task queue components: producer, queue, consumer, broker, backend
- Task dependency flow: chain dependency, parent-child relationships
- Task groups for concurrent execution
- Error handling and retry implementation
- Task prioritization and rate limiting

**Elasticsearch**
- Purpose and use cases of Elasticsearch
- Behind-the-scenes functionality
- Techniques: inverted index, term frequency and inverse document frequency, segments and shards
- Use cases: type-ahead experience, log analytics, social media search
- Creating and managing indexes
- Search and query types: basic searching, full-text search, relevance scoring
- Optimizing search performance: text versus keyword fields, analyzers, boosting, pagination
- Advanced search patterns: filtering, aggregation, fuzzy search
- Kibana for user-friendly Elasticsearch usage
- Best practices: explicit field mappings, optimizing shard numbers, batch indexing, avoiding wildcards

**Error Handling**
- Error types: syntax errors, runtime errors, logical errors
- Error handling strategies: fail-safe, fail-fast, graceful degradation, error prevention
- Best practices: catching errors early, not swallowing errors, custom error types, failing gracefully, logging errors, using stack traces
- Global error handlers
- User-facing error handling: friendly messages, actionable feedback
- Monitoring and logging importance
- Tools: Sentry, ELK stack
- Error alerts: email-based and Slack-based notifications

**Config Management**
- Definition and benefits of config management
- Flexibility and decoupling environment-specific settings
- Use cases: different environments, safely managing sensitive data (API keys, database passwords, certificates), feature flags
- Best practices for config management
- Config types: static configs (database credentials, API endpoints), dynamic configs (feature flags, rate limits), sensitive configs (credentials, tokens, secrets)
- Config sources: environment files, JSON, YAML
- Environment variables versus command-line flags versus static files

**Logging, Monitoring, and Observability**
- Differences between logging, tracing, monitoring, and observability
- Logging types: system logging, application logging, access logging, security logs
- Log levels: debug, info, warn, error, fatal
- Structured versus unstructured logging
- Logging best practices: centralized logging, log rotation and retention, contextual and meaningful logs, avoiding sensitive data
- Monitoring types: infrastructure monitoring, application performance monitoring, uptime monitoring
- Monitoring tools: Prometheus, Grafana
- Alert management: defining thresholds, creating alerts, avoiding alert fatigue
- Three pillars of observability: logs, metrics, traces
- Security and compliance in log management

**Graceful Shutdown**
- Need for graceful shutdown
- Behind-the-scenes operation
- Use cases: server restarts, scaling in cloud environments, microservices, long-running jobs
- Signal handling: SIGTERM, SIGINT, SIGKILL
- Shutdown steps: capturing signals, stopping new request acceptance, completing in-flight requests, closing external resources, terminating application

**Security**
- Security attack prevention: SQL injection, NoSQL injection, XSS, CSRF, broken authentication, insecure deserialization
- Secure software design principles: least privilege, defense in depth, fail secure defaults, separation of duties, security by design
- Input validation and sanitization importance
- Rate limiting and content security policy
- CORS and same-site cookies
- Event monitoring importance

**Scaling and Performance**
- Performance metrics: response time, resource utilization
- Identifying bottlenecks
- Caching and database optimization: avoiding N+1 query problems, proper use of joins, lazy loading
- Database indexes for read operation speed on frequent fields
- Batch processing for large datasets
- Memory leak prevention: closing file handles, database connections, cleanup after long processes
- Minimizing network overhead through payload size reduction and compression
- Performance testing and profiling
- Best practices: clear and maintainable code first, modular code for easier optimization, graceful degradation, offloading non-critical tasks

**Concurrency and Parallelism**
- Differences between concurrency and parallelism
- Concurrency benefits for I/O-bound tasks
- Parallelism benefits for CPU-bound tasks

**Object Storage and Large Files**
- Common use cases: AWS S3
- Managing large files with chunking and streaming
- Multipart file uploads

**Real-time Backend Systems**
- WebSockets functionality
- Server-sent events
- Pub/sub architecture

**Testing and Code Quality**
- Testing types: unit testing, integration testing, end-to-end testing, functional testing, regression testing, performance testing, load and stress testing, user acceptance testing, security testing
- Test-driven development approach
- Automating tests in CI/CD environments
- Code quality management with linting and formatting tools
- Quality metrics: cyclomatic complexity, maintainability index
- Code coverage measurements

**Twelve-Factor App Principles**
- Examination of twelve-factor app methodology

**OpenAPI Standards**
- Need for OpenAPI standards
- Benefits of adhering to standards
- Use cases: documentation automation
- Ecosystem tools: Swagger, Codegen, Postman
- History: Swagger to OpenAPI transition
- Current active versions
- Key concepts: API paths, request and response definitions, parameters, schemas
- OpenAPI document structure: metadata, paths, components, security definitions, responses
- New features in OpenAPI 3.0 and 3.1
- Tools: Swagger UI, Codegen, Postman
- Best practices: avoiding duplication, sticking to standards
- API-first development methodology

**Webhooks**
- Webhook use cases: sending notifications, third-party integrations
- API versus webhook comparison: polling (client-initiated) versus pushing (server-initiated)
- Key components: webhook URL, event triggers, payload, HTTP method, response handling
- Best practices: webhook signature verification, HTTPS usage, quick response, retry logic, logging
- Testing webhooks with tools like ngrok
- Real-world use cases: Stripe payment processing, GitHub webhooks, Slack, Discord, Twilio

**DevOps Concepts for Backend Engineers**
- Core concepts: continuous integration, continuous delivery, continuous deployment
- DevOps practices: infrastructure as code, config management, version control
- Tools: Docker for containers, Kubernetes for orchestration, CI/CD pipelines
- Scaling approaches: horizontal scaling versus vertical scaling
- Deployment strategies: blue-green deployment, rolling deployment

---

# Backend Learning Overview

**Traditional Backend Definition**
- A computer listening for requests (HTTP, WebSocket, gRPC, etc.) through open ports (80, 443, etc.)
- Accessible over the Internet for clients/frontends to connect
- Called a "server" because it serves content (static files, JSON, images, JavaScript, HTML)
- Accepts and receives data based on request types

**Request Flow Example (Backend Demo)**

The request travels through multiple hops:
- Browser initiates request to domain (backend-demo.doxyz)
- DNS server resolves domain using A records pointing to IP address
- Request reaches AWS EC2 instance via public IP
- AWS firewall (security group) checks allowed ports (22 for SSH, 80 for HTTP, 443 for HTTPS)
- Request passes through Nginx reverse proxy
- Nginx redirects to localhost:3001 where Node server runs
- Server processes request and sends response

**Why We Need Backends**

The core responsibility comes down to one word: **data**

Example scenario (Instagram like):
- User clicks like button
- App sends request to centralized server
- Server identifies the user
- Server persists the like action in database
- Server identifies the post owner
- Server triggers notification to post owner
- Post owner receives notification

The server must maintain centralized information about all users and their states because individual clients only see their customized view.

**Why Not Do Everything on Frontend?**

**Browser Limitations:**
- Sandboxed environment isolated from operating system
- Limited resource access (only DOM, browser APIs, local storage, cookies)
- Cannot access file system or system processes
- CORS policy restricts calling external APIs from different domains
- Security restrictions prevent remote code from accessing user's files

**Key Restrictions for Backend Logic:**
- Security policies too restrictive for backend operations
- Cannot access underlying file system for logs or environment variables
- Cannot call external APIs without appropriate CORS headers
- Cannot efficiently connect to databases
- Cannot maintain persistent database connections or connection pools
- Limited computing power on client devices (phones, low-end computers)

**Database Connection Issues:**
- Browsers cannot handle socket connections efficiently
- Cannot maintain persistent connections
- Each user would need separate database connection (overwhelming the database)
- No connection pooling or efficient query execution
- Backend drivers (PG, MongoDB) designed for server environments only

**Computing Power:**
- Frontend runs on varied devices with different capabilities
- Some devices have minimal resources (256MB RAM, single core)
- Heavy business logic can cause lag or crashes
- Centralized backend servers can scale resources (memory, CPU) as needed

**Conclusion**

[Inference] Understanding these fundamentals—what backends are, why they're necessary, and how they differ from frontends—provides essential foundation before diving into backend engineering principles and practices.

---

# HTTP Protocol & Backend Fundamentals

## Core HTTP Concepts

### Statelessness
- HTTP has no memory of past interactions
- Each request carries all necessary information (headers, URLs, methods)
- Server forgets the request after responding
- Each new request is treated as unrelated to previous ones
- Requests must be self-contained with all necessary data (auth tokens, session info)

**Benefits:**
- Simplicity: No need to store session information on server
- Scalability: Easy to distribute requests across multiple servers
- Reliability: Server crashes don't affect client interaction state

**State Management:**
- Developers implement cookies, sessions, or tokens when continuity is needed
- Used for user logins, shopping carts, etc.

### Client-Server Model
- Client (browser/application) initiates communication
- Client provides all required information (URL, headers, etc.)
- Server hosts resources (websites, APIs, content)
- Server processes requests and sends appropriate responses
- Communication is always initiated by client to get server response

### HTTP vs HTTPS
- HTTPS is HTTP with added security features
- Uses TLS encryption (formerly SSL)
- Underlying principles remain the same
- Provides encryption and security certificates

## Connection Mechanisms

### TCP Protocol
- HTTP uses TCP as underlying transport protocol
- TCP is connection-based and reliable
- Doesn't lose messages; presents errors when problems occur
- More reliable than UDP for HTTP purposes

### OSI Model Context
- Backend engineers primarily work with Layer 7 (Application Layer)
- Network concepts (TCP handshake, TLS) exist in lower layers
- Focus on application layer while understanding network layer basics

## HTTP Versions Evolution

### HTTP 1.0
- Each request opened a new connection
- Inefficient due to constant connection establishment/closure
- Slowed performance significantly

### HTTP 1.1
- Introduced persistent connections
- Multiple requests/responses over same TCP connection
- Added chunked transfer encoding
- Improved caching mechanisms
- Currently most widely used version

### HTTP 2.0
- Introduced multiplexing (multiple requests/responses over single connection)
- Uses binary framing instead of text
- Supports header compression (HPACK/QPACK)
- Server push capability (servers can send resources before client requests)

### HTTP 3.0
- Built on QUIC protocol over UDP (not TCP)
- Faster connection establishment
- Reduced latency
- Better packet loss handling
- Continues multiplexing without head-of-line blocking

## HTTP Messages Structure

### Request Message Components
- **Request Method**: GET, POST, PUT, DELETE, etc.
- **Resource URL**: Path being requested from server
- **HTTP Version**: e.g., HTTP/1.1
- **Host**: Domain name
- **Headers**: Key-value pairs with metadata
- **Blank Line**: Separates headers from body
- **Request Body**: Data sent to server (when applicable)

### Response Message Components
- **HTTP Version**: e.g., HTTP/1.1
- **Status Code**: Numeric code indicating result (e.g., 200)
- **Status Text**: Human-readable status (e.g., "OK")
- **Response Headers**: Key-value pairs with metadata
- **Blank Line**: Separates headers from body
- **Response Body**: Data returned from server

## HTTP Headers

### Definition & Purpose
- Key-value pairs of parameters
- Sent in requests or received in responses
- Provide metadata without opening the message body
- Similar to writing address on package exterior rather than inside

### Categories of Headers

**Request Headers:**
- Sent by client to server
- Provide information about the request
- Examples: User-Agent, Authorization, Accept

**General Headers:**
- Used in both requests and responses
- Metadata about the message itself
- Examples: Date, Cache-Control, Connection

**Representation Headers:**
- Deal with resource representation
- Content-Type: Media type (JSON, HTML, etc.)
- Content-Length: Size in bytes
- Content-Encoding: Compression method (gzip, deflate)
- ETag: Unique identifier for caching

**Security Headers:**
- Enhance security of requests/responses
- HSTS: Enforces HTTPS-only communication
- Content-Security-Policy: Restricts content sources (prevents XSS)
- X-Frame-Options: Prevents clickjacking
- X-Content-Type-Options: Prevents MIME type sniffing
- HTTP-Only/Secure Cookie Flags: Protects cookies

### Key Header Concepts

**Extensibility:**
- Headers can be easily added or customized
- No need to alter underlying protocol
- Adaptable to new technologies and use cases
- Custom headers possible (e.g., X-Custom-Header)

**Remote Control:**
- Headers allow clients to send instructions to server
- Control content negotiation, caching, authentication
- Influence server response and processing behavior

## HTTP Methods

### Purpose
- Represent different types of actions
- Define the **intent** of the interaction
- Provide clear semantic meaning

### Common Methods

**GET:**
- Fetch data from server
- Should not modify anything on server
- Idempotent

**POST:**
- Create new data on server
- Has request body to send user data
- Non-idempotent (creates new resource each time)

**PATCH:**
- Update existing data partially
- Has request body
- Selective replacement or append action

**PUT:**
- Update existing data completely
- Has request body
- Complete replacement of resource
- Often misused where PATCH should be used

**DELETE:**
- Delete resource from server
- Idempotent (resource can only be deleted once)

**OPTIONS:**
- Fetch server capabilities
- Used in CORS pre-flight requests
- Rarely used directly by developers

### Idempotent vs Non-Idempotent

**Idempotent Methods:**
- Can be called multiple times with same result
- GET: Fetching doesn't modify data
- PUT: Complete replacement yields same result
- DELETE: Resource can only be deleted once

**Non-Idempotent Methods:**
- Produce different results for same request
- POST: Creates new resource each time

## CORS (Cross-Origin Resource Sharing)

### Same-Origin Policy
- Browsers restrict requests to different domains by default
- Security mechanism to control cross-origin interactions
- CORS allows servers to specify who can access resources

### Origin Components
- Protocol + Domain + Port must match
- Different port = different origin (even on localhost)

### CORS Flow Types

**Simple Request:**
- Uses GET, POST, or HEAD methods
- Uses only simple headers
- Content-Type: application/x-www-form-urlencoded, multipart/form-data, or text/plain

**Simple Request Process:**
1. Client sends request with Origin header
2. Server checks origin against CORS policy
3. Server includes Access-Control-Allow-Origin in response
4. Browser checks header and allows/blocks response

**Pre-flight Request:**
- Required when request doesn't qualify as "simple"
- Uses OPTIONS method before actual request

**Pre-flight Triggers:**
- Method is PUT, DELETE, or other non-simple method
- Includes non-simple headers (e.g., Authorization)
- Content-Type is application/json or other non-simple type

**Pre-flight Process:**
1. Browser sends OPTIONS request with:
   - Access-Control-Request-Method
   - Access-Control-Request-Headers
2. Server responds with:
   - Access-Control-Allow-Origin
   - Access-Control-Allow-Methods
   - Access-Control-Allow-Headers
   - Access-Control-Max-Age (caching duration)
3. Browser verifies and sends actual request
4. Server responds to actual request

### CORS Headers

**Access-Control-Allow-Origin:**
- Specifies allowed client domains
- Can be specific domain or "*" (all origins)

**Access-Control-Allow-Methods:**
- Lists allowed HTTP methods

**Access-Control-Allow-Headers:**
- Lists allowed custom headers

**Access-Control-Max-Age:**
- Duration to cache pre-flight response
- Reduces redundant pre-flight requests

## HTTP Response Status Codes

### Purpose
- Communicate request result in standardized way
- Quick identification of success/failure
- Enable proper error handling
- Universal language across platforms/languages

### 1xx - Informational Responses

**100 Continue:**
- Server received headers, client can send body
- Used for large uploads

**101 Switching Protocols:**
- Server switching protocols (e.g., HTTP to WebSocket)

### 2xx - Success Responses

**200 OK:**
- Request successful
- Most common success code
- Server returning requested resource

**201 Created:**
- Request fulfilled, new resource created
- Used for POST requests

**204 No Content:**
- Request successful but no content to return
- Used for DELETE requests or OPTIONS responses

### 3xx - Redirection

**301 Moved Permanently:**
- Resource permanently moved to new URL
- Future requests should use new URL
- Maintains backwards compatibility

**302 Found (Temporary Redirect):**
- Resource temporarily at different URL
- Client should continue using original URL

**304 Not Modified:**
- Resource unchanged since last request
- Used with conditional GET requests
- Enables efficient caching

### 4xx - Client Errors

**400 Bad Request:**
- Invalid or malformed data from client
- Wrong data type or format

**401 Unauthorized:**
- Authentication required but missing/invalid
- Token expired or not provided

**403 Forbidden:**
- Server understood but refuses to authorize
- User lacks necessary permissions

**404 Not Found:**
- Requested resource unavailable
- Most famous status code
- URL incorrect or resource deleted

**405 Method Not Allowed:**
- Invalid HTTP method used
- Often due to typos

**409 Conflict:**
- Request conflicts with current state
- Example: Duplicate folder names

**429 Too Many Requests:**
- Rate limit exceeded
- Too many requests in given interval

### 5xx - Server Errors

**500 Internal Server Error:**
- Unexpected server condition
- Unhandled exceptions or errors

**501 Not Implemented:**
- Server doesn't support requested functionality
- May be implemented in future

**502 Bad Gateway:**
- Proxy received invalid response from upstream
- Common with nginx, load balancers

**503 Service Unavailable:**
- Server temporarily unable to handle requests
- High traffic or maintenance

**504 Gateway Timeout:**
- Upstream server failed to respond in time
- Similar to 502 but timeout-specific

## HTTP Caching

### Purpose
- Store copies of responses for reuse
- Reduces bandwidth usage
- Improves load times
- Decreases server load

### Caching Headers

**Cache-Control:**
- `max-age`: Duration to cache resource (in seconds)
- Example: `Cache-Control: max-age=10`

**ETag:**
- Hash/unique identifier of response
- Computed from response content
- Used to validate cached resources

**Last-Modified:**
- Timestamp of last resource modification
- Helps determine if cache is stale

### Caching Flow

**Initial Request:**
1. Client requests resource
2. Server responds with 200 and resource
3. Includes Cache-Control, ETag, Last-Modified headers

**Subsequent Request:**
1. Client sends If-None-Match (ETag value)
2. Client sends If-Modified-Since (timestamp)
3. Server checks if resource changed
4. If unchanged: Returns 304 Not Modified
5. If changed: Returns 200 with new resource and new ETag

**After Resource Update:**
1. Client updates resource on server
2. Server provides new ETag
3. Next GET request uses old ETag
4. Server detects mismatch
5. Returns 200 with updated resource

### Modern Alternatives
- Client-side caching solutions (e.g., React Query)
- More control over cache invalidation
- Better suited for complex applications
- HTTP caching still valid for simple use cases

## Content Negotiation

### Purpose
- Mechanism for client and server to agree on content format
- Client indicates preferences
- Server responds with compatible format or fallback

### Types of Content Negotiation

**Media Type Negotiation:**
- Header: `Accept`
- Values: application/json, application/xml, text/html
- Client specifies desired format

**Language Negotiation:**
- Header: `Accept-Language`
- Values: en, es, fr, etc.
- Client requests specific language

**Encoding Negotiation:**
- Header: `Accept-Encoding`
- Values: gzip, deflate, br, zstd
- Client specifies supported compression

### Benefits
- Server can adapt to client preferences
- Better user experience
- Efficient data transfer
- Language localization support

## HTTP Compression

### Purpose
- Reduce response size for large files
- Save bandwidth for client and server
- Faster data transfer

### How It Works
1. Client sends Accept-Encoding header (supported formats)
2. Server compresses response if possible
3. Server adds Content-Encoding header (compression used)
4. Browser decompresses automatically

### Common Encodings
- **gzip**: Most common compression
- **deflate**: Alternative compression
- **br (Brotli)**: Modern, more efficient
- **zstd**: Newer compression algorithm

### Impact Example
- Uncompressed: 26 MB
- Compressed (gzip): 3.8 MB
- ~85% reduction in file size

## Persistent Connections

### HTTP 1.0 Problem
- Each request required separate TCP connection
- Resource-intensive
- Slow performance

### HTTP 1.1 Solution
- **Keep-Alive**: Enables persistent connections
- Single TCP connection reused for multiple requests
- Reduces latency
- Saves resources

### Key Points
- Persistent by default in HTTP 1.1
- Connection stays open unless explicitly closed
- Connection: keep-alive header (sometimes explicit)
- Connection: close forces connection closure
- Timeout and max parameters control connection duration

## Handling Large Requests & Responses

### Multipart Requests (Client to Server)

**Purpose:**
- Send large files (images, videos, audio)
- Transfer binary data in parts

**Key Components:**
- Content-Type: multipart/form-data
- Boundary parameter: Delimiter separating parts
- Binary data transferred in chunks

**Process:**
1. Client selects file
2. POST request with multipart content type
3. Boundary delimiter marks data sections
4. Server receives and reconstructs file

### Streaming Responses (Server to Client)

**Purpose:**
- Send large files from server
- Transfer data in chunks

**Key Headers:**
- Content-Type: text/event-stream
- Connection: keep-alive

**Process:**
1. Client sends GET request
2. Server streams data in chunks
3. Connection stays alive until complete
4. Client appends chunks to construct full file

## Security Protocols

### SSL (Secure Sockets Layer)
- Original encryption protocol
- Protected data between client and server
- **Outdated** due to security vulnerabilities
- Replaced by TLS

### TLS (Transport Layer Security)
- Modern, secure version of SSL
- Encrypts data in transit
- Prevents interception and tampering
- Uses certificates for authentication
- Current recommended version: TLS 1.3

### HTTPS (HTTP Secure)
- HTTP with TLS encryption
- Protects sensitive data (passwords, credit cards)
- Prevents eavesdropping
- Authenticates server identity

**How It Works:**
1. Client visits HTTPS website
2. TLS encrypts communication
3. Server presents certificate
4. Encrypted connection established
5. Data protected from attackers

---

# Routing Concepts

## What is Routing?

- **HTTP methods express the "what"** - your intent or action (fetch, add, update, delete data)
- **Routing expresses the "where"** - which resource you want to perform the action on
- **Routing is mapping URL parameters to server-side logic** - the server combines the method and route to map requests to specific handlers

## Basic Request Structure

- Requests combine HTTP method + route path (e.g., GET /api/books)
- The server uses both method and route as a unique key to determine which handler processes the request
- Same route with different methods creates different endpoints (GET /api/books vs POST /api/books)

## Types of Routes

### Static Routes
- Routes with no variable parameters (e.g., /api/books)
- Always use the same string, never changes
- Return consistent types of data

### Dynamic Routes
- Contain variable parameters in the route path
- Use colon notation in server code (e.g., /api/users/:id)
- Allow fetching specific resources by identifier (e.g., /api/users/123)
- Dynamic parameters are called **path parameters** or **route parameters**
- Provide human-readable, semantic expressions of intent

### Query Parameters
- Sent after a question mark in the URL (e.g., /api/search?query=some+value)
- Used as key-value pairs to send metadata in requests
- Particularly useful for GET requests which don't have a body
- Common applications: pagination (page=2), filtering, sorting, limit settings
- Example pagination response includes: data array, total count, current page, total pages

### Nested Routes
- Multiple levels of resources in a single route (e.g., /api/users/123/posts/456)
- Each level adds semantic meaning to the request
- Different nesting levels create unique routes with different handlers
- Example progression: /api/users → /api/users/123 → /api/users/123/posts → /api/users/123/posts/456

### Route Versioning
- Includes version identifier in the route (e.g., /api/v1/products vs /api/v2/products)
- Allows different response formats for the same resource
- Provides migration window for breaking changes
- Version 1 can be deprecated while version 2 is adopted
- Avoids need to create entirely new route names for updated endpoints

### Catch-All Route
- Uses wildcard pattern (/*) to match any unhandled routes
- Placed at the end of route definitions
- Returns user-friendly "route not found" messages
- Prevents null responses for non-existent endpoints

---

# Serialization and Deserialization

## Client-Server Communication Setup
- Client (browser like Chrome) is the front end
- Server runs on localhost or cloud (AWS, GCP, Azure)
- Communication happens through HTTP, gRPC, or WebSockets
- This example focuses on HTTP/REST API communication
- Client is typically a JavaScript app (React, Angular, Vue)
- Server can be built in different languages (example uses Rust)

## The Core Problem
- Client sends HTTP requests (GET or POST) with URL, headers, and request body
- Different languages have different data types (JavaScript is dynamic, Rust is strictly typed and compiled)
- Question: How does data transmitted over a network make sense to machines using different languages?

## Understanding Network Layers
- OSI model has multiple layers for network communication
- Top layer: Application layer
- Bottom layer: Physical layer
- Both client and server have these layers
- [Inference] High-level understanding of OSI model is helpful but deep knowledge is not required for this topic

## The Solution: Common Standards
- Both client and server agree on a standard format for data transmission
- Client converts JavaScript data to this standard format before sending
- Server receives the standard format and converts it to its own format (e.g., Rust struct)
- Server converts its response back to the standard format
- Client parses the standard format back into JavaScript

## Definition
- **Serialization and Deserialization**: Converting data to and from a common format during transmission or storage
- This makes data language-agnostic across different machines, environments, and programming languages

## Types of Serialization Standards

### Text-Based Serialization
- JSON (JavaScript Object Notation) - most popular for HTTP communication
- YAML
- XML

### Binary Format
- Protocol Buffers (protobuf) - most popular
- Apache Avro
- Others

## JSON Format Details
- Stands for JavaScript Object Notation
- Human-readable format
- Structure rules:
  - Starts and ends with curly braces `{}`
  - Keys must be strings in double quotes
  - Values can be: strings, numbers, booleans, arrays, or nested objects
  - Nested objects follow the same rules

### JSON Data Types
- Strings (in double quotes)
- Numbers
- Booleans
- Arrays
- Objects (nested JSON)

## JSON Use Cases
- HTTP REST API transmission between clients and servers
- Configuration files
- Log files for application/server data during runtime

## How It Works in Practice
- Client sends POST request with JSON in request body
- Data transmitted over network (goes through OSI layers, converted to bits)
- [Inference] As a backend engineer, you only need to focus on the application layer (JSON format)
- Server receives and parses JSON
- Server processes the data and responds with JSON
- Client receives, parses, and uses the response data

## Key Takeaway
- Serialization/deserialization enables data to be understandable across different domains and programming languages
- It's a standard format that both parties agree to use for communication
- Most common choice for REST APIs is JSON due to its popularity and human readability

---

