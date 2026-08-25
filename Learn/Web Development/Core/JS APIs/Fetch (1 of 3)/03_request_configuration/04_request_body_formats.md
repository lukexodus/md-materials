## Request Body Formats


### application/x-www-form-urlencoded

The default content type for HTML form submissions. Data is encoded as key-value pairs with special character encoding.

**Encoding rules:**

- Space characters become `+` or `%20`
- Non-alphanumeric characters (except `-`, `_`, `.`, `~`) are percent-encoded
- Key-value pairs separated by `&`
- Keys and values separated by `=`

**Example:**

```
name=John+Doe&email=john%40example.com&age=30
```

**Characteristics:**

- Simple, widely supported
- Inefficient for binary data
- Inefficient for large payloads (percent-encoding overhead)
- Flat structure (no native nesting)
- Arrays typically encoded as repeated keys: `item=1&item=2&item=3`

**Nested data handling:** No standard exists. Common conventions:

- PHP-style: `user[name]=John&user[email]=john@example.com`
- Bracket notation: `user.name=John&user.email=john@example.com`

[Inference: Server-side interpretation of nested structures varies by framework and language.]

**Content-Type header:**

```
Content-Type: application/x-www-form-urlencoded
```

### multipart/form-data

Used for forms that upload files or large amounts of data. The body is divided into parts separated by a boundary string.

**Structure:**

```
--boundary_string
Content-Disposition: form-data; name="field_name"

field_value
--boundary_string
Content-Disposition: form-data; name="file"; filename="document.pdf"
Content-Type: application/pdf

[binary file data]
--boundary_string--
```

**Characteristics:**

- Each part has its own headers
- Boundary string declared in Content-Type header
- Efficient for binary data (no encoding overhead)
- Supports multiple files in single request
- Each part can have different content types

**Content-Type header:**

```
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW
```

**Boundary selection:** Must not appear in the data itself. Browsers generate random boundaries. Typical patterns include long alphanumeric strings with special prefixes.

**Part headers:**

- `Content-Disposition`: Required, specifies field name and optional filename
- `Content-Type`: Optional, defaults to `text/plain` for text fields
- `Content-Transfer-Encoding`: Rarely used in HTTP multipart

**File upload specifics:**

- `filename` parameter indicates uploaded file
- Original filename typically preserved but can be modified
- Multiple files: Either multiple parts with same name or multiple parts with different names

### application/json

JSON-encoded request body. The dominant format for modern REST APIs.

**Example:**

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30,
  "preferences": {
    "notifications": true,
    "theme": "dark"
  },
  "tags": ["customer", "premium"]
}
```

**Characteristics:**

- Native support for nested structures
- Native arrays and objects
- Type preservation (strings, numbers, booleans, null)
- Human-readable
- Smaller than XML for equivalent data
- No binary data support without encoding (base64)

**Content-Type header:**

```
Content-Type: application/json
```

**Charset specification:**

```
Content-Type: application/json; charset=utf-8
```

Though UTF-8 is the default for JSON per RFC 8259.

**Common patterns:**

- RESTful APIs predominantly use JSON
- Batch operations: Array of objects at root level
- Metadata separation: Wrapper objects with `data` and `meta` properties

**Limitations:**

- No native date format (ISO 8601 strings conventional)
- No native binary format
- No comments in standard JSON
- No undefined value (must use null or omit key)
- Circular references impossible

### application/xml and text/xml

XML-encoded data. Legacy format still used in SOAP, some enterprise systems, and specific domains.

**Example:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <name>John Doe</name>
  <email>john@example.com</email>
  <age>30</age>
  <preferences>
    <notifications>true</notifications>
    <theme>dark</theme>
  </preferences>
</user>
```

**Characteristics:**

- Self-describing with schemas (XSD)
- Verbose compared to JSON
- Namespace support for avoiding conflicts
- Attribute and element dual structure
- Native comment support
- Processing instructions possible

**Content-Type headers:**

```
Content-Type: application/xml
Content-Type: text/xml
```

[Inference: `application/xml` is preferred for data interchange, while `text/xml` has legacy usage. The distinction affects default charset handling in some contexts.]

**Attributes vs elements:**

```xml
<!-- Using attributes -->
<user name="John Doe" email="john@example.com" age="30"/>

<!-- Using elements -->
<user>
  <name>John Doe</name>
  <email>john@example.com</email>
</user>
```

**Common conventions:**

- Metadata in attributes, data in elements
- SOAP envelopes for web services
- RSS/Atom feeds

### text/plain

Plain text without specific structure. Minimal processing by server.

**Characteristics:**

- No parsing required
- Arbitrary text content
- No standardized structure
- Rarely used for structured APIs

**Content-Type header:**

```
Content-Type: text/plain; charset=utf-8
```

**Use cases:**

- Log submissions
- Simple text uploads
- Webhook payloads (some systems)
- Raw data transmission

### application/octet-stream

Binary data without specific format. Generic binary transfer.

**Characteristics:**

- No interpretation of content
- Raw byte stream
- Server determines handling
- Efficient for unknown binary formats

**Content-Type header:**

```
Content-Type: application/octet-stream
```

**Use cases:**

- File downloads with unknown type
- Raw binary uploads
- Executable files
- Generic file transfer when specific MIME type unknown

### application/graphql

GraphQL query format. Typically JSON-encoded but with specific structure.

**Example:**

```json
{
  "query": "query GetUser($id: ID!) { user(id: $id) { name email } }",
  "variables": {
    "id": "123"
  },
  "operationName": "GetUser"
}
```

**Characteristics:**

- Query string in `query` field
- Variables in separate `variables` field
- Optional operation name
- Allows multiple operations in single request

**Content-Type header:**

```
Content-Type: application/json
```

Though some servers accept:

```
Content-Type: application/graphql
```

For query-only requests without variables.

### application/x-ndjson (Newline Delimited JSON)

Streaming JSON format where each line is a separate JSON object.

**Example:**

```
{"name":"John","age":30}
{"name":"Jane","age":25}
{"name":"Bob","age":35}
```

**Characteristics:**

- Each line is independently parseable
- Supports streaming processing
- No array wrapper overhead
- Recovery from partial failures
- Used in log shipping and bulk operations

**Content-Type header:**

```
Content-Type: application/x-ndjson
```

**Use cases:**

- Elasticsearch bulk API
- Log aggregation systems
- Streaming data pipelines
- Event sourcing

### application/protobuf

Protocol Buffers binary format. Efficient binary serialization.

**Characteristics:**

- Requires schema definition (.proto files)
- Compact binary representation
- Type-safe
- Forward/backward compatibility through field numbering
- Significantly smaller than JSON for equivalent data
- Not human-readable

**Content-Type header:**

```
Content-Type: application/protobuf
```

Or:

```
Content-Type: application/x-protobuf
```

**Use cases:**

- gRPC services
- Microservice communication
- High-performance APIs
- Mobile applications (bandwidth savings)

**Schema requirement:** Both client and server must share .proto definitions for serialization/deserialization.

### application/msgpack

MessagePack binary format. JSON-like structure with binary efficiency.

**Characteristics:**

- Binary JSON alternative
- Smaller than JSON
- Preserves types like JSON
- Faster parsing than JSON [Inference: Based on benchmark claims, though actual performance varies by implementation]
- Not human-readable

**Content-Type header:**

```
Content-Type: application/msgpack
```

Or:

```
Content-Type: application/x-msgpack
```

**Use cases:**

- Real-time applications
- WebSocket communications
- Cache serialization
- Inter-service communication

### application/cbor

CBOR (Concise Binary Object Representation). Binary JSON-like format with extended types.

**Characteristics:**

- RFC 8949 specification
- Supports more types than JSON (binary, dates, bigints)
- Self-describing format
- Similar size to MessagePack
- IoT and embedded system usage

**Content-Type header:**

```
Content-Type: application/cbor
```

**Extended features:**

- Native binary data (no base64 needed)
- Native date/time types
- Big numbers
- Tagged values for custom types
- Streaming support

### text/csv

Comma-separated values. Simple tabular data format.

**Example:**

```
name,email,age
John Doe,john@example.com,30
Jane Smith,jane@example.com,25
```

**Characteristics:**

- Row-based tabular data
- Header row optional but conventional
- Simple parsing
- Inconsistent escaping standards

**Content-Type header:**

```
Content-Type: text/csv; charset=utf-8
```

**Escaping rules (RFC 4180):**

- Fields with commas, quotes, or newlines must be quoted
- Quotes inside quoted fields doubled: `""`
- Alternative delimiters possible (semicolon, tab)

**Limitations:**

- Flat structure only
- No type information
- Ambiguous empty vs null
- Encoding inconsistencies across implementations

### application/x-yaml and text/yaml

YAML format. Human-readable structured data.

**Example:**

```yaml
name: John Doe
email: john@example.com
age: 30
preferences:
  notifications: true
  theme: dark
tags:
  - customer
  - premium
```

**Characteristics:**

- Indentation-based structure
- Comments supported
- Multiple document support
- Anchors and references for repeated data
- More complex than JSON

**Content-Type header:**

```
Content-Type: application/x-yaml
```

Or:

```
Content-Type: text/yaml
```

**Use cases:**

- Configuration files
- CI/CD definitions
- Infrastructure as code
- Less common in HTTP APIs

### application/x-amf

Action Message Format. Binary format used by Flash/Flex applications.

**Characteristics:**

- Adobe-developed format
- Compact binary serialization
- Preserves ActionScript types
- AMF0 and AMF3 versions
- Declining usage

**Content-Type header:**

```
Content-Type: application/x-amf
```

### application/vnd.api+json

JSON API specification format. Standardized JSON structure for REST APIs.

**Example:**

```json
{
  "data": {
    "type": "users",
    "id": "123",
    "attributes": {
      "name": "John Doe",
      "email": "john@example.com"
    },
    "relationships": {
      "posts": {
        "links": {
          "related": "/users/123/posts"
        }
      }
    }
  }
}
```

**Characteristics:**

- Standardized structure with `data`, `included`, `errors`
- Resource type identification
- Relationship representation
- Pagination, filtering, sorting conventions
- Sparse fieldsets support

**Content-Type header:**

```
Content-Type: application/vnd.api+json
```

### application/ld+json

JSON-LD (Linked Data). JSON format with semantic web capabilities.

**Example:**

```json
{
  "@context": "https://schema.org",
  "@type": "Person",
  "name": "John Doe",
  "email": "john@example.com",
  "jobTitle": "Developer"
}
```

**Characteristics:**

- RDF serialization in JSON
- `@context` for vocabulary definition
- `@type` for type identification
- Linked data principles
- SEO applications (structured data)

**Content-Type header:**

```
Content-Type: application/ld+json
```

### application/x-thrift

Apache Thrift binary protocol. RPC framework serialization format.

**Characteristics:**

- Cross-language RPC support
- Multiple protocol variants (binary, compact, JSON)
- Requires IDL (Interface Definition Language)
- Type-safe
- Efficient binary encoding

**Content-Type header:**

```
Content-Type: application/x-thrift
```

**Variants:**

- TBinaryProtocol: Simple binary encoding
- TCompactProtocol: Optimized for size
- TJSONProtocol: JSON encoding for debugging

### Content Negotiation and Selection

Clients indicate preferred formats via `Accept` header:

```
Accept: application/json, application/xml;q=0.9, */*;q=0.8
```

Servers respond with actual format via `Content-Type` header.

**Quality values (q):** Indicate preference strength (0-1). Default is 1.0.

**Wildcard patterns:**

- `*/*`: Any format
- `application/*`: Any application type
- `text/*`: Any text type

### Encoding and Compression

Request bodies can be compressed using `Content-Encoding` header:

```
Content-Encoding: gzip
Content-Encoding: deflate
Content-Encoding: br
```

**Brotli (br):** Modern compression with better ratios than gzip. Increasing adoption.

**Transfer-Encoding:** For chunked transfer:

```
Transfer-Encoding: chunked
```

Allows streaming large bodies without knowing total size upfront.

### Character Encoding

Specified via `charset` parameter:

```
Content-Type: application/json; charset=utf-8
Content-Type: text/plain; charset=iso-8859-1
```

**UTF-8 dominance:** Modern APIs default to UTF-8. Some formats (JSON, Protocol Buffers) mandate UTF-8.

### Size Limitations

Server-imposed limits vary by implementation:

- Common default: 1-2 MB for JSON/form data
- Configurable maximums for file uploads (often 10-100 MB)
- Stream processing for very large payloads

**Client-side limits:** Browsers impose memory constraints on request construction.

### Security Considerations

**Content-Type validation:** Servers should verify Content-Type matches actual content to prevent content-type confusion attacks.

**Size limits:** Enforce maximum body sizes to prevent DoS attacks.

**Parsing safety:**

- JSON: Deep nesting attacks
- XML: Billion laughs attack, external entity injection
- Multipart: Boundary collision attacks

**Content validation:** Always validate and sanitize regardless of format.

### Performance Characteristics

**Parsing speed:** [Inference: Generally binary formats (protobuf, msgpack) parse faster than text formats (JSON, XML), though exact performance depends on implementation quality and data characteristics.]

**Size comparison:** For equivalent data:

1. Protocol Buffers / MessagePack / CBOR (smallest)
2. JSON
3. XML (largest)

[Inference: Actual size ratios vary by data structure complexity and redundancy.]

**Network efficiency:** Binary formats reduce bandwidth. Compression narrows the gap between formats.

---

