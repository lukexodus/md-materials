## Accept Header


### Purpose and Function

The Accept header declares the MIME types a client can process, allowing content negotiation between client and server. The server examines this header to determine which representation format to return when multiple formats are available for the same resource.

**Request-Side Declaration**: The client sends Accept in the request header to advertise its capabilities. This differs from Content-Type, which describes the payload format in requests with bodies (POST, PUT, PATCH).

**Server Response Selection**: [Inference] Servers use Accept to choose among available representations. A resource might exist as JSON, XML, HTML, and plain text - the server selects the format matching client preferences. Servers may ignore Accept entirely and return a default format.

### Syntax Structure

The Accept header contains a comma-separated list of MIME types with optional quality factors:

```
Accept: text/html, application/json, application/xml;q=0.9, */*;q=0.8
```

**MIME Type Components**: Each entry consists of a type/subtype pair. Common patterns:

- `text/html` - HTML documents
- `application/json` - JSON data
- `application/xml` - XML documents
- `image/png` - PNG images
- `video/mp4` - MP4 video

**Wildcard Patterns**: Partial wildcards specify type families:

- `text/*` - any text format
- `image/*` - any image format
- `*/*` - any format whatsoever

### Quality Factors (q-values)

Quality factors express preference strength on a 0-1 scale, with 1 being highest priority.

**Default Quality**: MIME types without explicit q-values have an implicit quality of 1.0. `application/json` is equivalent to `application/json;q=1.0`.

**Preference Ordering**: The server should prefer higher q-values over lower ones when multiple acceptable formats exist:

```
Accept: application/json;q=1.0, application/xml;q=0.8, text/plain;q=0.5
```

This requests JSON preferentially, XML as second choice, and plain text as fallback.

**Zero Quality**: `q=0` explicitly marks a format as unacceptable. [Inference] This is rarely used since omitting the type achieves the same effect more simply.

### Browser Default Behavior

**Navigation Requests**: [Unverified - browser-specific] Browsers typically send Accept headers prioritizing HTML for navigation:

```
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
```

**Script Requests**: Fetch/XMLHttpRequest from JavaScript may send different defaults:

```
Accept: */*
```

This universal wildcard indicates the script will handle any response format.

**Image Requests**: `<img>` tags and CSS background images send Accept headers listing supported image formats:

```
Accept: image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8
```

[Unverified] Modern browsers prioritize newer, more efficient formats like AVIF and WebP.

### API Request Patterns

**JSON APIs**: Clients requesting JSON typically send:

```javascript
fetch(url, {
  headers: {
    'Accept': 'application/json'
  }
});
```

**Versioned APIs**: Some APIs use Accept headers for versioning:

```
Accept: application/vnd.myapi.v2+json
```

This vendor-specific MIME type (`vnd.`) indicates version 2 of the API with JSON format.

**Multiple Format Support**: Clients supporting multiple formats list them with preferences:

```
Accept: application/json, text/plain;q=0.9, text/html;q=0.8
```

### Content Negotiation Mechanics

**Server Selection Algorithm**: [Inference - not standardized] Servers typically:

1. Parse Accept header into format list with q-values
2. Sort by quality factor (descending)
3. Match against available representations
4. Return first matching format

**Tie-Breaking**: [Speculation] When multiple formats have identical q-values, servers may use:

- Order of appearance in Accept header
- Server-side preferences
- Resource-specific defaults

**Negotiation Failure**: When no acceptable format exists, servers respond with 406 Not Acceptable status. The response may include a list of available formats.

### Specificity Rules

More specific MIME types take precedence over less specific ones even at equal q-values.

**Specificity Hierarchy**:

1. Exact type/subtype: `application/json`
2. Type with wildcard: `application/*`
3. Universal wildcard: `*/*`

Example interpretation:

```
Accept: application/json, text/*, */*;q=0.8
```

Priority order: JSON > any text format > any other format at 0.8 quality.

### Common MIME Types

**Structured Data**:

- `application/json` - JSON objects and arrays
- `application/xml` - XML documents
- `application/x-yaml` - YAML (non-standard)
- `application/ld+json` - JSON-LD (linked data)

**Text Formats**:

- `text/plain` - unformatted text
- `text/html` - HTML documents
- `text/css` - CSS stylesheets
- `text/csv` - comma-separated values

**Binary Formats**:

- `application/octet-stream` - arbitrary binary
- `application/pdf` - PDF documents
- `application/zip` - ZIP archives

**Images**:

- `image/jpeg`, `image/png`, `image/gif`, `image/webp`, `image/svg+xml`

### Accept vs Accept-Encoding

These are distinct headers with different purposes:

**Accept**: Specifies content format (JSON vs XML vs HTML)

**Accept-Encoding**: Specifies compression algorithms (gzip, deflate, brotli)

Example combination:

```
Accept: application/json
Accept-Encoding: gzip, deflate, br
```

Requests JSON content with any of three compression options.

### RESTful API Conventions

**Resource-Centric Design**: REST APIs typically use Accept for format selection of the same logical resource:

- `GET /users/123` with `Accept: application/json` returns JSON
- `GET /users/123` with `Accept: application/xml` returns XML

**Alternative URL-Based Negotiation**: Some APIs use file extensions instead:

- `/users/123.json` for JSON
- `/users/123.xml` for XML

[Inference] Accept header negotiation is more RESTful since it separates resource identity from representation format.

### Parameters and Extensions

MIME types support additional parameters beyond q-values:

**Charset Parameter**:

```
Accept: text/html; charset=utf-8
```

[Unverified] Most modern systems default to UTF-8, making explicit charset declaration uncommon in Accept headers.

**Version Parameters**:

```
Accept: application/vnd.api+json; version=2
```

Custom parameters enable fine-grained negotiation.

### Fetch API Usage

**Default Behavior**: Fetch sends `Accept: */*` by default when no explicit header is provided.

**Explicit Setting**:

```javascript
fetch(url, {
  headers: {
    'Accept': 'application/json'
  }
});
```

**Headers Object**:

```javascript
const headers = new Headers();
headers.append('Accept', 'application/json');
headers.append('Accept', 'text/plain;q=0.9');  // Adds to existing

fetch(url, {headers});
```

Multiple append() calls accumulate into a comma-separated list.

### Server Implementation Considerations

**Default Fallback**: [Inference] Servers should define default formats for when Accept is absent or contains only wildcards. Returning 406 for missing Accept headers creates poor user experience.

**Format Priority**: Servers may implement preferences independent of client q-values:

```
Accept: application/xml;q=1.0, application/json;q=0.9
```

[Inference] A server might still return JSON if it considers JSON the superior format, though this violates strict content negotiation principles.

**Performance Implications**: [Speculation] Format conversion on-demand based on Accept headers may impact response time. Servers might cache multiple pre-rendered representations.

### Mobile and Bandwidth Constraints

**Lightweight Formats**: Mobile clients may prefer compact representations:

```
Accept: application/json;q=1.0, application/xml;q=0.5
```

JSON is typically more compact than XML.

**Image Optimization**: Modern mobile browsers advertise support for efficient formats:

```
Accept: image/webp, image/apng, image/*;q=0.8
```

[Inference] This enables servers to deliver smaller images, reducing bandwidth consumption.

### Security Considerations

**Information Disclosure**: Accept headers reveal client capabilities. [Speculation] This fingerprinting data could contribute to browser identification across sites.

**Injection Attacks**: [Inference] Malformed Accept headers should not cause server-side parsing failures. Robust parsing must handle:

- Extremely long headers
- Invalid q-value formats
- Malicious MIME type strings

**SSRF via Content Type**: [Speculation] If servers fetch resources based on Accept negotiation, carefully validate to prevent server-side request forgery.

### HTTP/2 and HTTP/3

**Header Compression**: HPACK (HTTP/2) and QPACK (HTTP/3) compress headers including Accept. Repeated identical Accept headers across requests compress efficiently.

**Static Table Entries**: [Unverified] Common Accept values may exist in compression static tables, reducing header overhead to single bytes.

### GraphQL and Accept Headers

GraphQL endpoints typically ignore Accept since they return JSON by default:

```
POST /graphql
Accept: application/json  // Often redundant
Content-Type: application/json

{"query": "{ user(id: 123) { name } }"}
```

[Inference] The query structure determines response shape rather than content negotiation.

### Debugging and Inspection

**Browser DevTools**: Network tab displays sent Accept headers for each request. This reveals browser default behavior and script-set values.

**Server Logs**: [Inference] Logging Accept headers helps understand client populations and format preferences, informing API design decisions.

**Testing Different Formats**: Tools like curl enable Accept header testing:

```bash
curl -H "Accept: application/json" https://api.example.com/resource
curl -H "Accept: application/xml" https://api.example.com/resource
```

### Multiple Accept Headers

The HTTP specification allows multiple Accept header lines, which concatenate logically:

```
Accept: application/json
Accept: text/html;q=0.9
```

Equivalent to:

```
Accept: application/json, text/html;q=0.9
```

[Inference] Single-line format is more common in practice.

### Absent Accept Headers

**Specification Guidance**: [Unverified] HTTP specifications suggest servers treat absent Accept as equivalent to `*/*`, accepting any format.

**Server Behavior Variance**: [Inference] Actual server implementations vary:

- Return default format (common)
- Return 406 Not Acceptable (rare, poor UX)
- Return format based on URL extension (common)

### Accept in Caching

**Vary Header**: Servers must include `Vary: Accept` when responses differ by Accept header:

```
HTTP/1.1 200 OK
Content-Type: application/json
Vary: Accept
```

This instructs caches to store separate entries for different Accept values, preventing JSON responses from being served to clients requesting XML.

**Cache Key Composition**: [Inference] Caches combine URL and variant headers (including Accept) to form cache keys, enabling format-specific caching.

---

