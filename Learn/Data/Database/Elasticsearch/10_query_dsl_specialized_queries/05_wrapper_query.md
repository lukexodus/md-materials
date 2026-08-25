## Query DSL – Specialized Queries: Wrapper Query

### Overview

The `wrapper` query accepts a query encoded as a **Base64 string**. Elasticsearch decodes the string and executes the embedded query as if it were passed directly. The wrapped content must be a valid, complete query clause in JSON.

It is primarily used in contexts where queries are stored, transmitted, or generated as opaque strings — for example, in templating systems, external configuration, or programmatic query assembly where the caller cannot construct raw JSON directly.

---

### Basic Syntax

```json
GET /index/_search
{
  "query": {
    "wrapper": {
      "query": "<base64-encoded-query>"
    }
  }
}
```

The `query` field takes a Base64-encoded string. The decoded content must be a valid JSON query object — the same structure you would place inside the `"query"` key of a search request body.

---

### Encoding Example

**Original query (decoded):**

```json
{ "term": { "status": "published" } }
```

**Base64 encoded:**

```
eyJ0ZXJtIjogeyJzdGF0dXMiOiAicHVibGlzaGVkIn19
```

**Wrapper query:**

```json
GET /articles/_search
{
  "query": {
    "wrapper": {
      "query": "eyJ0ZXJtIjogeyJzdGF0dXMiOiAicHVibGlzaGVkIn19"
    }
  }
}
```

Elasticsearch decodes and executes this as:

```json
{
  "query": {
    "term": { "status": "published" }
  }
}
```

---

### What Can Be Wrapped

Any valid Elasticsearch query clause can be embedded, including compound queries:

**Original (decoded):**

```json
{
  "bool": {
    "must": [
      { "match": { "title": "elasticsearch" } }
    ],
    "filter": [
      { "term": { "published": true } }
    ]
  }
}
```

**Encoded and used:**

```json
{
  "query": {
    "wrapper": {
      "query": "eyJib29sIjp7Im11c3QiOlt7Im1hdGNoIjp7InRpdGxlIjoiZWxhc3RpY3NlYXJjaCJ9fV0sImZpbHRlciI6W3sidGVybSI6eyJwdWJsaXNoZWQiOnRydWV9fV19fQ=="
    }
  }
}
```

---

### Encoding Rules

- Encoding must be standard **Base64** (RFC 4648).
- The decoded bytes must be valid **UTF-8 JSON**.
- The decoded JSON must represent a **single query clause** — not a full search request body. Do not include the outer `{ "query": ... }` wrapper in the encoded content.
- Whitespace in the decoded JSON is allowed; it is not significant.

[Inference] Malformed Base64 or invalid JSON in the decoded content will cause a parsing error at query time. The error message will reference the decoding or parsing failure, which can make debugging less direct than with inline queries.

---

### Nesting Inside Compound Queries

The `wrapper` query behaves like any other leaf query and can appear inside `bool`, `constant_score`, or other compound queries:

```json
{
  "query": {
    "bool": {
      "must": {
        "wrapper": {
          "query": "eyJ0ZXJtIjp7InN0YXR1cyI6InB1Ymxpc2hlZCJ9fQ=="
        }
      },
      "filter": {
        "range": {
          "date": { "gte": "2024-01-01" }
        }
      }
    }
  }
}
```

---

### Use Cases

#### Stored query templates

Systems that persist query definitions as strings (e.g., in a database or configuration file) can store them Base64-encoded and pass them directly to Elasticsearch without a parsing layer.

#### Query assembly in constrained environments

In environments where constructing nested JSON is error-prone or inconvenient — such as certain scripting contexts or code-generated queries — the wrapper query allows a query to be built, encoded once, and reused as a plain string.

#### Search templates (indirect relevance)

[Inference] While search templates (using `_scripts` and Mustache rendering) are the more idiomatic Elasticsearch mechanism for parameterized stored queries, the wrapper query can serve a complementary role when the query itself is fully formed before submission and no runtime parameter substitution is needed.

---

### Limitations

| Limitation | Detail |
|---|---|
| No parameter substitution | The encoded query is static; runtime values must be baked in before encoding |
| Debugging difficulty | Errors in the wrapped query are reported after decoding, which can obscure the source |
| No semantic advantage | The wrapper adds no query behavior — it is purely a transport/encoding mechanism |
| Not composable at encoding time | You cannot reference or merge other queries inside the Base64 string at runtime |

---

### Comparison with Search Templates

| Feature | `wrapper` query | Search templates |
|---|---|---|
| Runtime parameter injection | No | Yes (Mustache) |
| Stored server-side | No | Yes (`_scripts` API) |
| Input format | Base64 string | Template ID or inline Mustache |
| Use case | Pre-formed query as string | Parameterized reusable queries |
| Complexity | Minimal | Higher |

For dynamic, parameterized queries, search templates are the more appropriate tool. The `wrapper` query is suited for opaque, fully-formed query payloads.

---

### Generating Base64 in Common Environments

**Python:**

```python
import base64, json

query = {"term": {"status": "published"}}
encoded = base64.b64encode(json.dumps(query).encode()).decode()
print(encoded)
```

**JavaScript:**

```javascript
const query = JSON.stringify({ term: { status: "published" } });
const encoded = Buffer.from(query).toString("base64");
console.log(encoded);
```

**Bash:**

```bash
echo -n '{"term":{"status":"published"}}' | base64
```

---

### Summary

| Aspect | Detail |
|---|---|
| Purpose | Execute a query provided as a Base64-encoded string |
| Input | Base64 string decoding to a valid JSON query clause |
| Behavior | Identical to passing the decoded query directly |
| Parameter support | None — query must be fully formed before encoding |
| Primary use case | Opaque query storage and transmission |
| Not a replacement for | Search templates when parameterization is needed |