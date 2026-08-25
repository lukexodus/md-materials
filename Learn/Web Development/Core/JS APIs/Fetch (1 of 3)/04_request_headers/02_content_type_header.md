## Content-Type Header


### Request Content-Type Requirements

The API strictly enforces `application/json` for all request bodies. Requests must include the header:

```
Content-Type: application/json
```

Omitting this header or specifying an incorrect media type results in a `400 Bad Request` response with an `invalid_request_error` indicating the content type mismatch.

### Character Encoding Specification

UTF-8 is the only supported character encoding. While the charset parameter is optional, explicit specification is recommended for clarity:

```
Content-Type: application/json; charset=utf-8
```

The API rejects requests with non-UTF-8 encodings. Text content in JSON payloads must be valid UTF-8 sequences.

### Response Content-Type

Standard responses return JSON with the header:

```
Content-Type: application/json
```

The API guarantees well-formed JSON in all non-streaming responses. Clients can parse response bodies without additional validation beyond standard JSON decoding.

### Streaming Response Content-Type

Streaming endpoints use Server-Sent Events (SSE) with a distinct media type:

```
Content-Type: text/event-stream
```

This signals that the response body contains an event stream following the SSE specification rather than a single JSON object. Clients must use SSE-compatible parsers to consume streaming responses.

#### SSE Charset Behavior

Event streams implicitly use UTF-8 encoding per the SSE specification. The charset parameter is typically omitted:

```
Content-Type: text/event-stream
```

Some implementations may explicitly include `charset=utf-8`, but this is redundant as UTF-8 is mandated by the SSE standard.

### Multipart Requests for Vision

When submitting images inline (not via URLs), requests use standard JSON encoding with base64-encoded image data embedded in the content blocks:

```json
{
  "model": "claude-sonnet-4-20250514",
  "messages": [{
    "role": "user",
    "content": [
      {
        "type": "image",
        "source": {
          "type": "base64",
          "media_type": "image/jpeg",
          "data": "/9j/4AAQSkZJRg..."
        }
      }
    ]
  }]
}
```

The outer request still uses `Content-Type: application/json`. The `media_type` field within the image source object specifies the image format.

#### Supported Image Media Types

Images must declare one of these media types in the `source.media_type` field:

- `image/jpeg`
- `image/png`
- `image/gif`
- `image/webp`

The API validates that base64-decoded data matches the declared media type. Mismatches trigger validation errors.

### Document Upload Content Types

PDF documents follow the same base64 embedding pattern:

```json
{
  "type": "document",
  "source": {
    "type": "base64",
    "media_type": "application/pdf",
    "data": "JVBERi0xLjQK..."
  }
}
```

Currently `application/pdf` is the only supported document media type.

### Content-Type Negotiation

The API does not support content negotiation via `Accept` headers. Response format is determined solely by the endpoint path and the presence of streaming parameters:

- `/v1/messages` → `application/json`
- `/v1/messages` with `stream: true` → `text/event-stream`

Clients cannot request alternative response formats like XML or Protocol Buffers.

### CORS and Preflight Requests

Browsers making cross-origin requests issue preflight `OPTIONS` requests. The API responds to these with appropriate CORS headers but no `Content-Type` header, as `OPTIONS` responses have no body:

```
HTTP/1.1 204 No Content
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, GET, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

The subsequent `POST` request must still include `Content-Type: application/json`.

### Content-Type Validation Strictness

The API performs exact media type matching. These variations are all rejected:

```
Content-Type: text/json                    ❌ Wrong type
Content-Type: application/javascript       ❌ Wrong subtype  
Content-Type: application/json; v=1        ❌ Invalid parameter
Content-Type: Application/JSON             ✓ Case-insensitive match
```

Media type and subtype comparison is case-insensitive per RFC 7231, but parameter names and values are case-sensitive.

### Compression and Content-Encoding

The API supports gzip compression for both requests and responses. Compressed payloads must declare compression via the `Content-Encoding` header, not in `Content-Type`:

```
Content-Type: application/json
Content-Encoding: gzip
```

The `Content-Type` describes the uncompressed payload format. Mixing encoding information into the media type (e.g., `application/json+gzip`) is non-standard and rejected.

#### Response Compression

Clients can request compressed responses via the `Accept-Encoding` header:

```
Accept-Encoding: gzip, deflate
```

When the API responds with compression, it includes:

```
Content-Type: application/json
Content-Encoding: gzip
```

Streaming responses can also be compressed, though SSE parsers must decompress the stream before event parsing.

### Empty Request Bodies

`GET` requests to informational endpoints (like model listing) require no request body. These requests should omit the `Content-Type` header entirely:

```
GET /v1/models HTTP/1.1
Authorization: Bearer sk-ant-...
```

Including `Content-Type: application/json` with an empty body is harmless but unnecessary.

### Error Response Content-Type

Error responses always use JSON encoding:

```
Content-Type: application/json
```

This applies even when the original request had an invalid `Content-Type`, ensuring clients can reliably parse error information.

### Batch API Content-Type

Batch requests use JSONL (JSON Lines) format with a specific media type:

```
Content-Type: application/jsonl
```

Each line in the request body contains a complete JSON object representing one batch item. The response also uses `application/jsonl` with one result object per line.

### Content-Type in Webhook Deliveries

Webhook notifications from the API use standard JSON:

```
Content-Type: application/json
```

Webhook receivers must accept this content type and parse JSON payloads from the notification POST requests.

### Future Content-Type Extensions

The API versioning strategy allows introducing new media types without breaking existing clients. Potential future additions might include:

- `application/vnd.anthropic.v2+json` for major version changes
- `application/protobuf` for binary protocol buffer encoding
- `application/cbor` for compact binary object representation

Current clients hard-coded to expect `application/json` will continue functioning as the v1 endpoints maintain this media type.

### Debugging Content-Type Issues

When encountering content-type errors, verify:

1. **Header presence**: Request includes `Content-Type: application/json`
2. **Header spelling**: No typos in header name (case-insensitive but often case-sensitive in frameworks)
3. **Body encoding**: Payload is valid UTF-8 JSON, not form-encoded or XML
4. **Framework defaults**: Some HTTP clients default to `application/x-www-form-urlencoded` for POST requests

Common framework-specific issues:

```python
# ❌ Wrong - sends form encoding by default
requests.post(url, data=json.dumps(payload))

# ✓ Correct - explicitly sets JSON content type
requests.post(url, json=payload)
```

```javascript
// ❌ Wrong - missing content type
fetch(url, {
  method: 'POST',
  body: JSON.stringify(payload)
})

// ✓ Correct - explicit headers
fetch(url, {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify(payload)
})
```

---

