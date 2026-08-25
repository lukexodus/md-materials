## Source Filtering

### Overview

Source filtering is a mechanism in Elasticsearch that controls which fields from a document's `_source` are returned in search results. By default, Elasticsearch stores the complete original JSON document in the `_source` field and returns it in full with every search hit. Source filtering lets you include or exclude specific fields from that returned source, reducing response payload size without affecting how documents are indexed or scored.

Source filtering operates purely at the response level. It does not affect the inverted index, stored fields, relevance scoring, or the actual content stored on disk. The full `_source` remains stored; filtering only controls what is transmitted in the response.

### Why Source Filtering Matters

In production search systems, returning the full `_source` for every hit is often wasteful:

- Documents may contain large fields (long body text, base64-encoded attachments, deeply nested objects) that are irrelevant to the consuming application
- High-traffic search endpoints returning unnecessary fields consume bandwidth, increase serialization overhead, and slow client-side processing
- Applications often need only a subset of fields to render results (title, URL, summary) and have no use for remaining fields

Source filtering addresses these concerns by trimming the response to only what the application needs.

### Basic Syntax

Source filtering is controlled through the `_source` parameter in a search request. It accepts three forms: a boolean, a string or array of strings, or an object with `includes` and `excludes`.

#### Disable Source Entirely

```json
GET /articles/_search
{
  "_source": false,
  "query": {
    "match": { "title": "Elasticsearch" }
  }
}
```

**Output**:

```json
{
  "hits": {
    "hits": [
      {
        "_index": "articles",
        "_id": "doc-001",
        "_score": 5.432,
        "_source": {}
      }
    ]
  }
}
```

The `_source` field is omitted entirely from each hit. The document ID, score, and metadata remain. Use this when you only need IDs or scores and have no need for field content.

#### Enable Source Explicitly

```json
GET /articles/_search
{
  "_source": true,
  "query": {
    "match": { "title": "Elasticsearch" }
  }
}
```

This is the default behavior. The full `_source` is returned. Specifying `true` explicitly is redundant unless you are overriding a default set at a higher level.

### Field Inclusion

To return only specific fields, provide a field name or array of field names:

```json
GET /articles/_search
{
  "_source": ["title", "author", "published_date"],
  "query": {
    "match": { "title": "cluster management" }
  }
}
```

**Output**:

```json
{
  "hits": {
    "hits": [
      {
        "_id": "doc-001",
        "_score": 7.112,
        "_source": {
          "title": "Cluster Management in Elasticsearch",
          "author": "Jane Smith",
          "published_date": "2024-03-15"
        }
      }
    ]
  }
}
```

Only the specified fields are returned. All other fields present in the original document are excluded from the response.

### Field Exclusion

To return everything except specific fields, use the `excludes` form:

```json
GET /articles/_search
{
  "_source": {
    "excludes": ["body", "raw_html", "internal_metadata"]
  },
  "query": {
    "match": { "title": "sharding" }
  }
}
```

**Output** includes all fields from the stored `_source` except `body`, `raw_html`, and `internal_metadata`. This is useful when documents have one or two large fields you want to suppress without explicitly listing every other field.

### Combined Includes and Excludes

You can combine `includes` and `excludes` in a single request. Excludes are applied after includes, so they take precedence:

```json
GET /articles/_search
{
  "_source": {
    "includes": ["author.*", "metadata.*"],
    "excludes": ["metadata.internal", "metadata.raw"]
  },
  "query": {
    "match": { "title": "indexing" }
  }
}
```

**Key Points**:
- `includes` narrows the field set to a subset of `_source`
- `excludes` removes fields from the already-narrowed set
- When both are specified and a field matches both, `excludes` wins

### Wildcard Patterns

Source filtering supports wildcard patterns using `*`, allowing you to match groups of fields by prefix or structure:

```json
GET /articles/_search
{
  "_source": {
    "includes": ["title", "author.*", "tags"],
    "excludes": ["author.internal_*"]
  },
  "query": {
    "match_all": {}
  }
}
```

Given a document with this structure:

```json
{
  "title": "Understanding Shards",
  "author": {
    "name": "Jane Smith",
    "email": "jane@example.com",
    "internal_id": "USR-4421",
    "internal_role": "editor"
  },
  "tags": ["elasticsearch", "shards"]
}
```

**Output**:

```json
{
  "_source": {
    "title": "Understanding Shards",
    "author": {
      "name": "Jane Smith",
      "email": "jane@example.com"
    },
    "tags": ["elasticsearch", "shards"]
  }
}
```

The `author.*` include pattern captures all subfields of `author`. The `author.internal_*` exclude pattern then removes `internal_id` and `internal_role`.

### Dot Notation for Nested Fields

For documents with nested or object fields, use dot notation to target specific subfields:

```json
{
  "_source": {
    "includes": [
      "title",
      "author.name",
      "location.country"
    ]
  }
}
```

Given a document:

```json
{
  "title": "Replica Shards Explained",
  "author": {
    "name": "John Doe",
    "email": "john@example.com",
    "bio": "Senior engineer with 10 years experience..."
  },
  "location": {
    "city": "Berlin",
    "country": "Germany",
    "coordinates": { "lat": 52.52, "lon": 13.40 }
  }
}
```

**Output**:

```json
{
  "_source": {
    "title": "Replica Shards Explained",
    "author": {
      "name": "John Doe"
    },
    "location": {
      "country": "Germany"
    }
  }
}
```

Only the specified subfields are returned. Sibling subfields within the same object are excluded.

### Source Filtering vs. Stored Fields

Source filtering and stored fields are related but distinct mechanisms:

| Aspect | Source Filtering | Stored Fields |
|--------|-----------------|---------------|
| What it controls | Which fields from `_source` are returned | Fields stored separately from `_source` |
| Configuration | Query-time parameter | Index-time mapping setting |
| Affects indexing | No | Yes (`store: true` in mapping) |
| Use case | Trimming response payload | Retrieving fields when `_source` is disabled |
| Default | Full `_source` returned | No fields stored separately by default |

[Inference] In most use cases, source filtering is preferable to stored fields because it requires no index-time configuration changes and is simpler to maintain. Stored fields are most relevant in specialized scenarios where `_source` is disabled entirely at the index level to save disk space.

### Disabling Source at the Index Level

You can disable `_source` storage entirely at the mapping level:

```json
PUT /articles
{
  "mappings": {
    "_source": {
      "enabled": false
    }
  }
}
```

**Key Points**:
- When `_source` is disabled, documents are indexed and searchable but the original source JSON is not stored
- Queries return hits with no `_source` content
- Reindexing from this index is not possible since the source document no longer exists in Elasticsearch
- Update and update-by-query operations require `_source` and will fail on indices where it is disabled
- This setting cannot be changed after index creation without reindexing

[Inference] Disabling `_source` is rarely advisable in modern Elasticsearch deployments. The disk savings are typically outweighed by operational constraints. It may be appropriate for purely append-only, read-heavy indices where updates and reindexing are never required.

### Partial Source Storage

Rather than enabling or disabling `_source` entirely, you can configure which fields are stored in `_source` at the index level using `includes` and `excludes` in the mapping:

```json
PUT /articles
{
  "mappings": {
    "_source": {
      "includes": ["title", "author", "tags", "published_date"],
      "excludes": ["raw_html", "internal_*"]
    }
  }
}
```

**Key Points**:
- This permanently filters `_source` at index time—excluded fields are never stored, regardless of what was in the original document
- Query-time source filtering can only further restrict what is returned; it cannot retrieve fields excluded at the mapping level
- This is an index-time decision that cannot be changed without reindexing
- Unlike query-time filtering, this actually reduces disk usage since the excluded fields are not stored at all

### Source Filtering in the Get API

Source filtering also applies to direct document retrieval via the Get API:

```json
GET /articles/_doc/doc-001?_source_includes=title,author&_source_excludes=body
```

Or using the source endpoint directly:

```json
GET /articles/_source/doc-001?_source_includes=title,author
```

**Output** returns only the filtered source content without the surrounding metadata envelope:

```json
{
  "title": "Cluster Management in Elasticsearch",
  "author": "Jane Smith"
}
```

### Source Filtering in Multi-Get (mget)

The `_mget` API supports per-document source filtering:

```json
POST /_mget
{
  "docs": [
    {
      "_index": "articles",
      "_id": "doc-001",
      "_source": ["title", "author"]
    },
    {
      "_index": "articles",
      "_id": "doc-002",
      "_source": {
        "includes": ["title"],
        "excludes": ["author"]
      }
    },
    {
      "_index": "articles",
      "_id": "doc-003",
      "_source": false
    }
  ]
}
```

Each document in the request can have its own source filtering configuration, allowing fine-grained control over what is returned per document in a single request.

### Source Filtering with fields Parameter

Elasticsearch also provides the `fields` parameter as an alternative to `_source` filtering. While `_source` returns reconstructed JSON from the stored source, `fields` retrieves values from doc values or stored fields:

```json
GET /articles/_search
{
  "_source": false,
  "fields": ["title", "published_date", "author.name"],
  "query": {
    "match": { "title": "Elasticsearch" }
  }
}
```

**Output**:

```json
{
  "hits": {
    "hits": [
      {
        "_id": "doc-001",
        "_score": 5.432,
        "fields": {
          "title": ["Cluster Management in Elasticsearch"],
          "published_date": ["2024-03-15T00:00:00.000Z"],
          "author.name": ["Jane Smith"]
        }
      }
    ]
  }
}
```

**Key Points**:
- `fields` values are always returned as arrays, even for single values
- Date fields are normalized to ISO 8601 format when retrieved via `fields`
- `fields` can access runtime fields; `_source` cannot
- `fields` retrieves values from doc values where available, which may differ slightly from the raw stored source representation
- Combining `_source` filtering with `fields` is valid—they serve complementary purposes

### Performance Considerations

Source filtering reduces response payload size but the degree of performance benefit depends on several factors:

- **Network savings**: Large excluded fields (long body text, binary data) produce the most meaningful bandwidth reduction
- **Serialization**: Elasticsearch must still deserialize and filter the full `_source` before returning the response. [Inference] For very large documents, this deserialization cost may be non-trivial even when most fields are excluded, though actual behavior may vary by document size and field structure
- **No indexing impact**: Source filtering never affects indexing throughput, query execution time, or relevance scoring
- **Aggregations are unaffected**: Aggregations operate on doc values and the inverted index, not `_source`, so source filtering does not affect aggregation results

### Common Use Cases

#### Search Result Previews

Return only fields needed to render a result card:

```json
{
  "_source": ["title", "summary", "author.name", "published_date", "url"]
}
```

#### Suppressing Large Fields

Exclude heavy fields that are only needed when viewing a full document:

```json
{
  "_source": {
    "excludes": ["body", "attachments", "raw_content"]
  }
}
```

#### Security and Data Masking

[Inference] Source filtering can reduce exposure of sensitive fields in certain contexts, but it should not be treated as a security control. It is a response-shaping tool, not an access control mechanism. Field-level security in Elasticsearch's security features (available in certain license tiers) is the appropriate approach for enforcing access restrictions.

#### Lightweight ID-Only Queries

When only document IDs are needed—for example, to check existence or feed into a subsequent lookup:

```json
{
  "_source": false,
  "query": { "term": { "status": "published" } }
}
```

### Limitations and Considerations

- **Cannot retrieve fields not stored in `_source`**: If a field was excluded at mapping level or `_source` is disabled, query-time source filtering cannot recover it
- **Not a security mechanism**: Source filtering controls response shape, not access. A determined caller can always request full source unless field-level security is configured separately
- **Wildcard patterns are not regex**: The `*` wildcard matches any sequence of characters in a field name but does not support full regular expression syntax
- **Nested objects return partial structures**: When filtering subfields of nested objects, the parent object is still returned as a container—only the specified subfields appear within it. This is expected behavior but may require client-side handling
- **Behavior may vary**: Response structure and field availability may differ depending on Elasticsearch version, mapping configuration, and whether fields have doc values enabled

### Best Practices

- **Specify only what you need**: Prefer `includes` over returning everything and filtering client-side; let Elasticsearch reduce the payload before it reaches the network
- **Exclude large fields by default**: Identify heavy fields in your mappings and exclude them from general search endpoints; expose them only in detail-view queries
- **Avoid disabling `_source` unless necessary**: The operational constraints (no updates, no reindexing) typically outweigh disk savings
- **Use mapping-level filtering for permanent exclusions**: If certain fields should never be exposed or stored, configure `_source` excludes in the mapping rather than relying on every query to exclude them
- **Combine with `fields` for runtime fields**: When you need runtime field values alongside source fields, use both `_source` and `fields` parameters together
- **Test filtering with the Explain API**: When source filtering interacts with scoring unexpectedly, verify that the fields used for relevance calculation are not confused with the fields returned in the response—scoring uses the index, not `_source`