## Field Data Types in Elasticsearch

---

### Overview

Every field in an Elasticsearch mapping has an assigned data type. The data type determines how a field's value is stored in the inverted index, what operations can be performed on it (searching, sorting, aggregating), and how much storage it consumes. Choosing the correct type is one of the most consequential decisions in index design.

Elasticsearch organizes field types into several categories.

---

### String Types

#### text

Used for full-text search. Values are passed through an analyzer at index time, which tokenizes and normalizes the content. The resulting tokens are stored in the inverted index.

- Suitable for: prose, descriptions, log messages, any content requiring relevance-based search
- Not suitable for: sorting, aggregations, exact matching (use `keyword` for those)

```json
"description": {
  "type": "text",
  "analyzer": "english"
}
```

#### keyword

Used for exact matching, filtering, sorting, and aggregations. Values are stored as-is — no analysis is applied.

- Suitable for: IDs, status codes, tags, email addresses, country codes, categorical values
- Not suitable for: full-text search on natural language content

```json
"status": {
  "type": "keyword"
}
```

#### Multi-field Mapping (text + keyword)

A common pattern is to map a single string field as both `text` and `keyword` using the `fields` parameter:

```json
"title": {
  "type": "text",
  "fields": {
    "keyword": {
      "type": "keyword",
      "ignore_above": 256
    }
  }
}
```

This allows both full-text search on `title` and exact aggregation or sorting on `title.keyword`.

#### match_only_text

A storage-optimized variant of `text` introduced in Elasticsearch 8.x. It omits scoring information, making it suitable for log data where relevance ranking is not needed.

```json
"log_message": {
  "type": "match_only_text"
}
```

> [Inference] `match_only_text` may reduce index size compared to `text` for high-volume logging use cases. The actual storage savings depend on data characteristics. Behavior may vary.

---

### Numeric Types

Elasticsearch provides multiple numeric types. Selecting the smallest type that fits your data range reduces index size and improves performance.

| Type | Description | Range |
|---|---|---|
| `byte` | Signed 8-bit integer | -128 to 127 |
| `short` | Signed 16-bit integer | -32,768 to 32,767 |
| `integer` | Signed 32-bit integer | -2³¹ to 2³¹−1 |
| `long` | Signed 64-bit integer | -2⁶³ to 2⁶³−1 |
| `float` | 32-bit IEEE 754 floating point | ~7 decimal digits precision |
| `double` | 64-bit IEEE 754 floating point | ~15 decimal digits precision |
| `half_float` | 16-bit floating point | Lower precision, reduced storage |
| `scaled_float` | Floating point backed by a `long` with a fixed scaling factor | Controlled precision |
| `unsigned_long` | Unsigned 64-bit integer | 0 to 2⁶⁴−1 |

**Example — using `scaled_float` for currency:**

```json
"price": {
  "type": "scaled_float",
  "scaling_factor": 100
}
```

A value of `19.99` is stored internally as `1999`. This avoids floating-point imprecision for values with a known decimal scale.

> [Inference] Using the smallest appropriate numeric type may reduce disk usage and improve cache efficiency. Actual impact depends on field cardinality and query patterns. Behavior may vary.

---

### Date and Date-Related Types

#### date

Stores date and datetime values. Internally, all dates are stored as UTC milliseconds since the Unix epoch (a `long` value). Accepts multiple formats.

```json
"created_at": {
  "type": "date",
  "format": "yyyy-MM-dd'T'HH:mm:ssZ||yyyy-MM-dd||epoch_millis"
}
```

Multiple formats can be specified with `||` as a separator. Elasticsearch tries each format in order.

#### date_nanos

Stores dates with nanosecond precision. Useful for high-resolution time-series data.

```json
"event_time": {
  "type": "date_nanos"
}
```

> [Inference] `date_nanos` has a narrower representable range than `date` (approximately 1677 to 2262 CE). Verify that your data falls within this range before using it. Behavior may vary.

---

### Boolean Type

```json
"is_active": {
  "type": "boolean"
}
```

Accepts `true`, `false`, and string representations `"true"` / `"false"`. Used for binary state fields.

---

### Binary Type

Stores binary data as a Base64-encoded string. By default, binary fields are **not indexed** and **not searchable** — they exist only in `_source`.

```json
"thumbnail": {
  "type": "binary",
  "doc_values": false
}
```

---

### Range Types

Range types represent intervals rather than single values. They support range queries natively.

| Type | Description |
|---|---|
| `integer_range` | Range of 32-bit integers |
| `long_range` | Range of 64-bit integers |
| `float_range` | Range of single-precision floats |
| `double_range` | Range of double-precision floats |
| `date_range` | Range of date values |
| `ip_range` | Range of IPv4 or IPv6 addresses |

**Example:**

```json
PUT /reservations/_doc/1
{
  "booking_window": {
    "gte": "2024-12-01",
    "lte": "2024-12-15"
  }
}
```

```json
"booking_window": {
  "type": "date_range",
  "format": "yyyy-MM-dd"
}
```

---

### Object and Nested Types

#### object

Used to store JSON objects. Inner fields are flattened into dot-notation in the underlying Lucene index.

```json
"address": {
  "type": "object",
  "properties": {
    "street": { "type": "text" },
    "city":   { "type": "keyword" },
    "zip":    { "type": "keyword" }
  }
}
```

**Key limitation:** When an `object` field contains an array of objects, the relationship between inner fields across array elements is lost during flattening.

**Example of the flattening problem:**

```json
{
  "tags": [
    { "name": "urgent", "score": 10 },
    { "name": "low",    "score": 1  }
  ]
}
```

After flattening, Elasticsearch sees `tags.name: [urgent, low]` and `tags.score: [10, 1]` — the pairing between `urgent` and `10` is not preserved.

#### nested

Stores arrays of objects as separate hidden documents, preserving the relationship between fields within each object. Enables queries that correctly match within a single array element.

```json
"tags": {
  "type": "nested",
  "properties": {
    "name":  { "type": "keyword" },
    "score": { "type": "integer" }
  }
}
```

Querying nested fields requires using the `nested` query type:

```json
{
  "query": {
    "nested": {
      "path": "tags",
      "query": {
        "bool": {
          "must": [
            { "term":  { "tags.name":  "urgent" } },
            { "range": { "tags.score": { "gte": 5 } } }
          ]
        }
      }
    }
  }
}
```

> [Inference] `nested` fields have a higher indexing and storage overhead than `object` fields because each nested object is indexed as a separate internal document. Use `nested` only when cross-field correctness within array elements is required. Behavior may vary.

---

### Flattened Type

Maps an entire JSON object and its subfields as a single `keyword`-indexed field. Useful when the object structure is highly variable or unpredictable.

```json
"labels": {
  "type": "flattened"
}
```

**Example document:**

```json
{
  "labels": {
    "env": "production",
    "team": "platform",
    "cost_center": "cc-042"
  }
}
```

All subfield values are searchable via term queries on the parent field. This avoids mapping explosion at the cost of limited query functionality (no range queries, no aggregations on subfields).

---

### Geo Types

#### geo_point

Stores latitude/longitude pairs. Supports geo-distance queries, geo bounding box queries, and geo aggregations.

```json
"location": {
  "type": "geo_point"
}
```

Accepted formats include:

```json
"location": { "lat": 14.5995, "lon": 120.9842 }   // object
"location": "14.5995,120.9842"                      // string
"location": [120.9842, 14.5995]                     // array [lon, lat]
```

Note: Array format is `[longitude, latitude]` — the reverse of the object format.

#### geo_shape

Stores complex geometric shapes: points, lines, polygons, multipolygons, and geometry collections. Uses GeoJSON format.

```json
"coverage_area": {
  "type": "geo_shape"
}
```

```json
{
  "coverage_area": {
    "type": "polygon",
    "coordinates": [
      [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0] ]
    ]
  }
}
```

---

### IP Type

Stores IPv4 and IPv6 addresses. Supports CIDR range queries.

```json
"client_ip": {
  "type": "ip"
}
```

```json
GET /logs/_search
{
  "query": {
    "term": {
      "client_ip": "192.168.1.0/24"
    }
  }
}
```

---

### Completion Type

Used exclusively for the suggest API (autocomplete / prefix completion). Not suitable for general full-text search.

```json
"suggest": {
  "type": "completion"
}
```

```json
{
  "suggest": {
    "input": ["Elastic", "Elasticsearch", "ELK Stack"],
    "weight": 10
  }
}
```

---

### Alias Type

Creates an alternate name for an existing field. Useful for renaming fields without reindexing. Aliases are read-only — they cannot be used as targets for indexing.

```json
"user_identifier": {
  "type": "alias",
  "path": "user_id"
}
```

---

### Rank Feature and Rank Features Types

Used to store numeric values that influence scoring during retrieval. These types are designed for use with the `rank_feature` query.

```json
"page_rank": {
  "type": "rank_feature"
}

"topic_scores": {
  "type": "rank_features"
}
```

`rank_feature` holds a single value; `rank_features` holds a map of named scores.

---

### Dense Vector Type

Stores fixed-length arrays of float values. Used for vector similarity search (k-nearest neighbor search).

```json
"embedding": {
  "type": "dense_vector",
  "dims": 768,
  "index": true,
  "similarity": "cosine"
}
```

When `index: true`, Elasticsearch builds an HNSW (Hierarchical Navigable Small World) graph for approximate nearest-neighbor queries.

```json
{
  "query": {
    "knn": {
      "field": "embedding",
      "query_vector": [0.12, 0.45, ...],
      "k": 10,
      "num_candidates": 100
    }
  }
}
```

> [Inference] HNSW-based ANN search involves a trade-off between recall accuracy and query latency, controlled by `num_candidates`. Higher values may improve recall but increase query time. Behavior may vary based on index size and hardware.

#### sparse_vector

Stores sparse vector representations as a map of dimension IDs to float values. Used with models that produce sparse outputs (e.g., ELSER).

```json
"ml_tokens": {
  "type": "sparse_vector"
}
```

---

### Percolator Type

Stores a query as a document, enabling reverse search — matching stored queries against incoming documents. Used in alerting and notification systems.

```json
"query": {
  "type": "percolator"
}
```

---

### Wildcard Type

Optimized for arbitrary wildcard and regex queries on string values. More efficient than `keyword` for patterns like `*error*` on high-cardinality fields.

```json
"raw_log": {
  "type": "wildcard"
}
```

---

### Token Count Type

Indexes the number of tokens produced by an analyzer for a string value, rather than the string itself. Useful for filtering by document length.

```json
"body_token_count": {
  "type": "token_count",
  "analyzer": "standard"
}
```

---

### Type Selection Reference

| Use Case | Recommended Type |
|---|---|
| Full-text search | `text` |
| Exact match, filtering, aggregation | `keyword` |
| Integers | `integer` or `long` |
| Decimals with fixed scale | `scaled_float` |
| High-precision timestamps | `date_nanos` |
| Standard timestamps | `date` |
| Lat/lon coordinates | `geo_point` |
| Polygon / shape data | `geo_shape` |
| IP addresses | `ip` |
| Variable-key objects | `flattened` |
| Array of objects with field correlation | `nested` |
| Vector similarity search | `dense_vector` |
| Autocomplete | `completion` |
| Wildcard/regex queries | `wildcard` |
| Scoring signals | `rank_feature` |

---

### Best Practices

- **Match the type to the query pattern.** A field used only for filtering should be `keyword`, not `text`. A field needing both should use a multi-field mapping.
- **Use the smallest numeric type that fits your range.** Oversized types consume unnecessary storage and doc values space.
- **Prefer `scaled_float` over `float` or `double` for monetary values** to avoid floating-point representation issues.
- **Use `nested` deliberately.** The overhead is non-trivial; avoid it when `object` flattening does not affect correctness for your queries.
- **Do not use `text` fields for aggregations or sorting** — they do not have doc values enabled by default and will produce errors or require `fielddata`, which has significant heap implications.
- **Disable indexing on fields that are stored but never searched** using `"index": false` to reduce index size.

```json
"raw_payload": {
  "type": "text",
  "index": false
}
```

---