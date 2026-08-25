## Multi-get API

### Overview

The Multi-get API (mget) retrieves multiple documents in a single request using their document IDs. Rather than making individual Get API calls for each document, Multi-get batches retrieval operations together, dramatically reducing network overhead, round trips, and latency. This approach is essential for scenarios requiring efficient bulk document retrieval, such as fetching user profiles, loading related documents, or retrieving product details for display in applications.

### Basic Multi-get Syntax

The Multi-get API supports two primary request formats:

**Syntax:**

```
GET /_mget
GET /<index>/_mget
POST /_mget
POST /<index>/_mget
```

**Request format with explicit index per document:**

```json
GET /_mget
{
  "docs": [
    { "_index": "products", "_id": "1" },
    { "_index": "products", "_id": "2" },
    { "_index": "users", "_id": "user_123" }
  ]
}
```

**Response:**

```json
{
  "docs": [
    {
      "_index": "products",
      "_id": "1",
      "_version": 2,
      "found": true,
      "_source": {
        "name": "Laptop",
        "price": 999.99,
        "category": "Electronics",
        "stock": 10
      }
    },
    {
      "_index": "products",
      "_id": "2",
      "_version": 1,
      "found": true,
      "_source": {
        "name": "Mouse",
        "price": 29.99,
        "category": "Accessories",
        "stock": 50
      }
    },
    {
      "_index": "users",
      "_id": "user_123",
      "found": false
    }
  ]
}
```

### Multi-get with Single Index

When all documents belong to the same index, use the shorthand syntax with the `ids` parameter:

**Request:**

```json
GET /products/_mget
{
  "ids": ["1", "2", "3", "4", "5"]
}
```

**Response:**

```json
{
  "docs": [
    {
      "_index": "products",
      "_id": "1",
      "_version": 2,
      "found": true,
      "_source": {
        "name": "Laptop",
        "price": 999.99
      }
    },
    {
      "_index": "products",
      "_id": "2",
      "_version": 1,
      "found": true,
      "_source": {
        "name": "Mouse",
        "price": 29.99
      }
    },
    {
      "_index": "products",
      "_id": "3",
      "found": false
    },
    {
      "_index": "products",
      "_id": "4",
      "_version": 3,
      "found": true,
      "_source": {
        "name": "Keyboard",
        "price": 79.99
      }
    },
    {
      "_index": "products",
      "_id": "5",
      "_version": 1,
      "found": true,
      "_source": {
        "name": "Monitor",
        "price": 299.99
      }
    }
  ]
}
```

### Multi-get Response Structure

The Multi-get response returns an array of documents with metadata for each:

- **`_index`**: The index containing the document
- **`_id`**: The document ID
- **`_version`**: The current version of the document
- **`found`**: Boolean indicating document existence
- **`_source`**: The document content (if found)
- **`_seq_no`**: Sequence number (for version tracking)
- **`_primary_term`**: Primary shard identifier

**Document not found in response:**

```json
{
  "_index": "products",
  "_id": "999",
  "found": false
}
```

When a document doesn't exist, the response includes only `_index`, `_id`, and `found: false`.

### Handling Missing Documents

Multi-get returns results for all requested document IDs, including those that don't exist. Applications must check the `found` field for each document:

**Processing multi-get response:**

```json
{
  "docs": [
    {
      "_id": "1",
      "found": true,
      "_source": { "name": "Laptop" }
    },
    {
      "_id": "2",
      "found": false
    },
    {
      "_id": "3",
      "found": true,
      "_source": { "name": "Mouse" }
    }
  ]
}
```

[Inference] Applications should filter results to handle existing documents separately from missing documents, avoiding null reference errors for unfound documents.

### Retrieving Specific Fields

The `_source_includes` and `_source_excludes` parameters allow selective field retrieval in multi-get operations:

**Request retrieving specific fields:**

```json
GET /products/_mget
{
  "docs": [
    { "_id": "1", "_source_includes": ["name", "price"] },
    { "_id": "2", "_source_includes": ["name", "price"] },
    { "_id": "3", "_source_includes": ["name", "stock"] }
  ]
}
```

**Response with field filtering:**

```json
{
  "docs": [
    {
      "_id": "1",
      "found": true,
      "_source": {
        "name": "Laptop",
        "price": 999.99
      }
    },
    {
      "_id": "2",
      "found": true,
      "_source": {
        "name": "Mouse",
        "price": 29.99
      }
    },
    {
      "_id": "3",
      "found": true,
      "_source": {
        "name": "Keyboard",
        "stock": 100
      }
    }
  ]
}
```

**Excluding specific fields:**

```json
GET /products/_mget
{
  "docs": [
    { "_id": "1", "_source_excludes": ["stock", "created_at"] },
    { "_id": "2", "_source_excludes": ["stock", "created_at"] }
  ]
}
```

### Disabling Source Retrieval

When only metadata is needed (without document content), disable source retrieval to reduce response size:

**Request:**

```json
GET /products/_mget
{
  "docs": [
    { "_id": "1", "_source": false },
    { "_id": "2", "_source": false },
    { "_id": "3", "_source": false }
  ]
}
```

**Response without source:**

```json
{
  "docs": [
    {
      "_index": "products",
      "_id": "1",
      "_version": 2,
      "found": true
    },
    {
      "_index": "products",
      "_id": "2",
      "_version": 1,
      "found": true
    },
    {
      "_index": "products",
      "_id": "3",
      "found": false
    }
  ]
}
```

### Multi-get with Routing

Custom routing values must be specified in multi-get operations if documents were indexed with routing:

**Request with routing:**

```json
GET /products/_mget
{
  "docs": [
    { "_id": "1", "routing": "user_123" },
    { "_id": "2", "routing": "user_123" },
    { "_id": "3", "routing": "user_456" }
  ]
}
```

[Inference] If routing values don't match those used during indexing, documents may not be found even if they exist in the index.

### Multi-get with Mixed Indexes

Retrieve documents from different indexes in a single request:

**Request:**

```json
GET /_mget
{
  "docs": [
    { "_index": "products", "_id": "laptop_001" },
    { "_index": "products", "_id": "mouse_002" },
    { "_index": "orders", "_id": "order_abc123" },
    { "_index": "users", "_id": "user_456" },
    { "_index": "reviews", "_id": "review_999" }
  ]
}
```

**Response from multiple indexes:**

```json
{
  "docs": [
    {
      "_index": "products",
      "_id": "laptop_001",
      "found": true,
      "_source": { "name": "Laptop", "price": 999.99 }
    },
    {
      "_index": "products",
      "_id": "mouse_002",
      "found": true,
      "_source": { "name": "Mouse", "price": 29.99 }
    },
    {
      "_index": "orders",
      "_id": "order_abc123",
      "found": true,
      "_source": { "customer": "John Doe", "total": 1299.99, "status": "shipped" }
    },
    {
      "_index": "users",
      "_id": "user_456",
      "found": false
    },
    {
      "_index": "reviews",
      "_id": "review_999",
      "found": true,
      "_source": { "rating": 5, "comment": "Excellent product" }
    }
  ]
}
```

### Per-Document Field Configuration

Different field retrieval configurations can be applied to individual documents within the same request:

**Request:**

```json
GET /_mget
{
  "docs": [
    {
      "_index": "products",
      "_id": "1",
      "_source": ["name", "price"]
    },
    {
      "_index": "products",
      "_id": "2",
      "_source": false
    },
    {
      "_index": "users",
      "_id": "user_123",
      "_source_excludes": ["password_hash"]
    }
  ]
}
```

Each document request can specify different `_source`, `_source_includes`, or `_source_excludes` parameters.

### Stored Fields vs. Source

Multi-get retrieves `_source` by default. For documents with stored fields (fields explicitly marked as stored in mappings), retrieve stored fields instead:

**Request with stored fields:**

```json
GET /products/_mget
{
  "docs": [
    { "_id": "1", "stored_fields": ["name", "price"] },
    { "_id": "2", "stored_fields": ["name", "stock"] }
  ]
}
```

**Response with stored fields:**

```json
{
  "docs": [
    {
      "_id": "1",
      "found": true,
      "fields": {
        "name": ["Laptop"],
        "price": [999.99]
      }
    },
    {
      "_id": "2",
      "found": true,
      "fields": {
        "name": ["Mouse"],
        "stock": [50]
      }
    }
  ]
}
```

[Inference] Stored fields are useful only if explicitly configured during index mapping; `_source` is the standard approach for most use cases.

### Multi-get Performance Characteristics

**Advantages over individual Get requests:**

- **Network efficiency**: Single HTTP request and response instead of N requests
- **Connection reuse**: Single TCP connection handles multiple documents
- **Batch processing**: Elasticsearch processes requests together with optimized routing
- **Latency reduction**: Dramatic reduction in round-trip time for retrieving multiple documents

[Inference] For retrieving 100 documents, Multi-get typically requires milliseconds while 100 individual Get API calls require seconds or more.

**Example performance comparison:**

```
100 individual Get requests: ~2000ms (20ms average per request)
1 Multi-get request with 100 documents: ~50-100ms
Improvement: 20-40x faster
```

### Real-World Use Cases

**Shopping cart item retrieval:**

```json
GET /products/_mget
{
  "ids": ["laptop_001", "mouse_002", "keyboard_003", "monitor_004"]
}
```

Fetch complete product details for all items in a user's shopping cart with a single request.

**User profile aggregation:**

```json
GET /_mget
{
  "docs": [
    { "_index": "users", "_id": "user_123" },
    { "_index": "user_preferences", "_id": "user_123" },
    { "_index": "user_settings", "_id": "user_123" }
  ]
}
```

Retrieve user profile, preferences, and settings from multiple indexes simultaneously.

**Related document loading:**

```json
GET /_mget
{
  "docs": [
    { "_index": "articles", "_id": "article_456" },
    { "_index": "comments", "_id": "comment_001" },
    { "_index": "comments", "_id": "comment_002" },
    { "_index": "comments", "_id": "comment_003" },
    { "_index": "authors", "_id": "author_789" }
  ]
}
```

Load an article with associated comments and author information in a single operation.

**Order fulfillment data retrieval:**

```json
GET /orders/_mget
{
  "ids": ["order_001", "order_002", "order_003"],
  "_source_includes": ["customer_id", "status", "total", "items"]
}
```

Retrieve multiple orders for batch processing with specific fields only.

**E-commerce product recommendations:**

```json
GET /products/_mget
{
  "ids": ["sku_001", "sku_002", "sku_003", "sku_004", "sku_005"],
  "_source_includes": ["name", "price", "rating", "image_url"]
}
```

Fetch recommended product details for display on recommendation widgets.

**Batch translation key retrieval:**

```json
GET /translations/_mget
{
  "ids": ["home.title", "home.description", "nav.menu", "footer.copyright"],
  "_source": ["en", "es", "fr", "de"]
}
```

Retrieve translation strings for multiple languages in a single request.

### Bulk vs. Multi-get

| Aspect | Bulk API | Multi-get API |
|--------|----------|---------------|
| **Operations** | Index, create, update, delete | Retrieve only |
| **Use case** | Modify multiple documents | Fetch multiple documents |
| **Request format** | NDJSON (newline-delimited) | JSON with docs array |
| **Performance** | High-throughput writing | High-speed reading |
| **Response complexity** | Per-operation status | Per-document status |
| **Ideal for** | Data ingestion, reindexing | Cache hydration, data assembly |

### Error Handling in Multi-get

Multi-get doesn't fail if some documents are missing; it returns results for all requested documents:

**Response with mix of found and missing:**

```json
{
  "docs": [
    {
      "_id": "1",
      "found": true,
      "_source": { "name": "Laptop" }
    },
    {
      "_id": "2",
      "found": false
    },
    {
      "_id": "3",
      "found": true,
      "_source": { "name": "Mouse" }
    },
    {
      "_id": "4",
      "found": false
    }
  ]
}
```

[Inference] Applications should iterate through results and filter by the `found` field to distinguish between successfully retrieved and missing documents.

### Limitations and Considerations

**Request size constraints:**

Large Multi-get requests (hundreds or thousands of IDs) consume significant memory. [Unverified] Optimal request size depends on document size and cluster resources, typically 100-10,000 documents per request.

**Document not found behavior:**

Missing documents don't cause errors; they appear in results with `found: false`. This differs from Get API, which returns a 404 HTTP status.

**Index existence:**

Multi-get requests across non-existent indexes may fail. [Inference] Verify index existence before requesting documents if indexes might not be present.

**Consistency guarantees:**

[Unverified] Multi-get operations may retrieve documents from replica shards, potentially returning slightly stale data in high-consistency scenarios.

### Multi-get with Conditional Requests

Per-document conditional retrieval is not directly supported in multi-get. [Inference] For conditional retrieval based on version, use individual Get API calls with version parameters instead.

### Response Size Optimization

**Strategies to reduce response size:**

```json
GET /products/_mget
{
  "docs": [
    { "_id": "1", "_source": false },
    { "_id": "2", "_source": false },
    { "_id": "3", "_source": false }
  ]
}
```

Disable source when metadata only is needed.

```json
GET /products/_mget
{
  "docs": [
    { "_id": "1", "_source_includes": ["name", "price"] },
    { "_id": "2", "_source_includes": ["name", "price"] }
  ]
}
```

Include only specific fields to reduce payload size.

### Comparison: Multi-get vs. Search API

| Aspect | Multi-get | Search API |
|--------|-----------|-----------|
| **Input** | Document IDs | Query criteria |
| **Output** | Specific documents | Matching documents |
| **Speed** | Very fast (direct lookup) | Slower (index scanning) |
| **Use case** | Known document IDs | Discovery queries |
| **Result limit** | Request limit | Search result window |

### Connection and Performance Best Practices

[Inference] Sending multiple Multi-get requests in parallel (5-10 concurrent) typically yields better throughput than sequential requests, allowing better utilization of cluster resources and network bandwidth.

**Batching strategy:**

- Send Multi-get requests in parallel
- Group related documents in single requests when possible
- Limit request size to 1-10MB depending on infrastructure
- Monitor response times to detect performance degradation

**Key Points:**
- Multi-get retrieves multiple documents in a single request using document IDs
- The `ids` parameter provides shorthand syntax when all documents are in the same index
- The `docs` parameter allows specifying different indexes for each document
- Missing documents appear in results with `found: false` and don't cause errors
- Field retrieval can be customized per-document using `_source_includes`, `_source_excludes`, or `_source: false`
- Multi-get is significantly faster than individual Get API requests for bulk document retrieval
- Custom routing values must be specified if documents were indexed with routing
- Response size can be reduced by disabling source retrieval or filtering specific fields
- Multi-get is ideal for cache hydration, shopping cart loading, and assembling related document data
- Parallel Multi-get requests typically yield better throughput than sequential requests