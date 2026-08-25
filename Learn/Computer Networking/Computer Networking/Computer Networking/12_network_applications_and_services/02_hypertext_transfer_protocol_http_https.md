## Hypertext Transfer Protocol (HTTP/HTTPS)


HTTP serves as the foundation protocol for the World Wide Web, enabling communication between web browsers and servers. HTTPS extends HTTP with encryption and authentication capabilities.

### HTTP Protocol Fundamentals

**Request-Response Model:**

- Client sends HTTP request to server
- Server processes request and returns HTTP response
- Stateless protocol requires each request to be complete
- Cookies and sessions maintain state across requests

**HTTP Methods:**

- GET retrieves resources from server
- POST submits data for processing
- PUT creates or updates resources
- DELETE removes specified resources
- HEAD retrieves headers without body
- OPTIONS returns supported methods
- PATCH applies partial modifications

**Status Code Categories:**

- 1xx Informational responses indicate continuing process
- 2xx Success responses confirm successful processing
- 3xx Redirection responses require additional action
- 4xx Client error responses indicate request problems
- 5xx Server error responses indicate server failures

### HTTP Message Structure

**Request Message Components:**

- Request line contains method, URI, and HTTP version
- Headers provide metadata about request
- Empty line separates headers from body
- Optional message body contains request data

**Response Message Components:**

- Status line contains HTTP version, status code, and reason phrase
- Response headers provide metadata about response
- Empty line separates headers from body
- Message body contains requested resource or error information

**Common Headers:**

- Host specifies target server name
- User-Agent identifies client application
- Accept indicates preferred response formats
- Content-Type specifies message body format
- Content-Length indicates body size in bytes
- Cache-Control manages caching behavior

### HTTP Version Evolution

**HTTP/1.0 Characteristics:**

- Separate connection for each request
- Simple request-response model
- Limited header support
- No persistent connections

**HTTP/1.1 Enhancements:**

- Persistent connections reduce overhead
- Request pipelining improves efficiency
- Chunked transfer encoding supports streaming
- Host header enables virtual hosting
- Range requests enable partial content retrieval

**HTTP/2 Improvements:**

- Binary protocol replaces text format
- Multiplexing enables concurrent requests over single connection
- Server push proactively sends resources
- Header compression reduces overhead
- Stream prioritization improves performance

**HTTP/3 Advances:**

- QUIC transport protocol replaces TCP
- Reduced connection establishment time
- Improved performance over lossy networks
- Built-in encryption and authentication
- Stream-level flow control

### HTTPS Security Implementation

**Transport Layer Security (TLS):**

- Encrypts HTTP traffic using symmetric encryption
- Digital certificates authenticate server identity
- Perfect Forward Secrecy protects past communications
- Certificate transparency prevents fraudulent certificates

**SSL/TLS Handshake Process:**

1. Client sends ClientHello with supported cipher suites
2. Server responds with ServerHello and certificate
3. Client verifies certificate and generates pre-master secret
4. Both sides derive session keys from pre-master secret
5. Encrypted communication begins using session keys

**Certificate Management:**

- Certificate Authorities (CAs) issue digital certificates
- Certificate chains establish trust relationships
- Certificate revocation lists identify compromised certificates
- Automated certificate management reduces operational overhead

### Web Application Security

**Common Vulnerabilities:**

- Cross-Site Scripting (XSS) executes malicious scripts
- SQL Injection manipulates database queries
- Cross-Site Request Forgery (CSRF) performs unauthorized actions
- Session hijacking steals user authentication tokens

**Security Headers:**

- Content-Security-Policy restricts resource loading
- X-Frame-Options prevents clickjacking attacks
- Strict-Transport-Security enforces HTTPS usage
- X-Content-Type-Options prevents MIME type confusion

**Authentication and Authorization:**

- Basic authentication sends credentials in headers
- Digest authentication uses challenge-response mechanism
- OAuth 2.0 enables delegated authorization
- JSON Web Tokens (JWT) provide stateless authentication

### HTTP Performance Optimization

**Caching Mechanisms:**

- Browser caching stores resources locally
- Proxy caching serves multiple clients
- CDN caching distributes content globally
- Cache validation ensures content freshness

**Content Delivery Optimization:**

- Compression reduces transfer sizes
- Minification removes unnecessary characters
- Resource concatenation reduces requests
- Image optimization balances quality and size

**Connection Management:**

- Keep-alive connections reduce overhead
- Connection pooling reuses existing connections
- HTTP/2 multiplexing eliminates head-of-line blocking
- DNS prefetching resolves names proactively

