## Retrieving a document by ID

### Overview

Retrieving a document by ID is one of the most fundamental and efficient operations in Elasticsearch. This operation allows you to fetch a specific document when you know its unique identifier. The Get API provides direct access to documents stored in an index without requiring a search query, making it ideal for scenarios where you need precise, fast lookups.

### The Get API

The Get API is the primary mechanism for retrieving documents by their ID. It returns the complete document along with metadata about the document's location and version.

**Basic syntax:**

```
GET /<index>/_doc/<id>
```

**Example request:**

```json
GET /products/_doc/1
```

This request retrieves the document with ID `1` from the `products` index.

**Response structure:**

```json
{
  "_index": "products",
  "_id": "1",
  "_version": 2,
  "_seq_no": 5,
  "_primary_term": 1,
  "found": true,
  "_source": {
    "name": "Laptop",
    "price": 999.99,
    "category": "Electronics",
    "stock": 15
  }
}
```

### Metadata in Get Responses

The Get API response includes several metadata fields that provide information about the document:

- `_index`: The name of the index containing the document
- `_id`: The unique identifier of the document
- `_version`: The current version number of the document (increments with each update)
- `_seq_no`: The sequence number assigned by Elasticsearch (used for version control)
- `_primary_term`: Identifies the primary shard that indexed the document
- `found`: A boolean indicating whether the document exists
- `_source`: The actual document content (the fields you stored)

### Retrieving Non-Existent Documents

When you attempt to retrieve a document that doesn't exist, Elasticsearch returns a response with `found` set to `false`:

**Example request:**

```
GET /products/_doc/999
```

**Response:**

```json
{
  "_index": "products",
  "_id": "999",
  "found": false
}
```

[Inference] Applications should check the `found` field to handle missing documents appropriately rather than assuming a retrieval will always succeed.

### Retrieving Specific Fields

Instead of retrieving the entire document, you can request only specific fields using the `_source_includes` or `_source_excludes` parameters:

**Retrieve only certain fields:**

```
GET /products/_doc/1?_source_includes=name,price
```

**Response:**

```json
{
  "_index": "products",
  "_id": "1",
  "_version": 2,
  "found": true,
  "_source": {
    "name": "Laptop",
    "price": 999.99
  }
}
```

**Exclude specific fields:**

```
GET /products/_doc/1?_source_excludes=stock
```

### Disabling Source Retrieval

If you only need metadata and don't require the document's source content, you can disable source retrieval:

```
GET /products/_doc/1?_source=false
```

**Response:**

```json
{
  "_index": "products",
  "_id": "1",
  "_version": 2,
  "found": true
}
```

This reduces network bandwidth and response time when source data isn't needed.

### Bulk Get Operations

The Multi-Get API (mget) allows you to retrieve multiple documents in a single request, which is more efficient than making individual Get requests:

**Request syntax:**

```json
GET /_mget
{
  "docs": [
    { "_index": "products", "_id": "1" },
    { "_index": "products", "_id": "2" },
    { "_index": "products", "_id": "3" }
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
      "_source": { "name": "Laptop", "price": 999.99 }
    },
    {
      "_index": "products",
      "_id": "2",
      "_version": 1,
      "found": true,
      "_source": { "name": "Mouse", "price": 29.99 }
    },
    {
      "_index": "products",
      "_id": "3",
      "found": false
    }
  ]
}
```

**Shorthand syntax for same index:**

```json
GET /products/_mget
{
  "ids": ["1", "2", "3"]
}
```

### Performance Characteristics

The Get API provides very fast document retrieval because:

- **Direct shard access**: Elasticsearch uses the document ID to determine which shard contains the document, allowing direct retrieval without searching
- **No scoring overhead**: Unlike search operations, document retrieval doesn't involve relevance scoring
- **Minimal processing**: Only document fetching and optional field filtering occur

[Inference] Typical Get API response times are measured in milliseconds for documents stored on local disks, and potentially longer for remote or cloud-based storage.

### Routing and Document Retrieval

When a document is indexed, Elasticsearch uses a routing value (by default the document ID) to determine shard placement. The Get API uses the same routing to locate the document:

**Explicit routing during retrieval:**

```
GET /products/_doc/1?routing=user123
```

This parameter should match the routing value used during indexing. If routing values don't match, the Get API may not find the document.

### Handling Document Versions

The Get API returns the document's current version number. This is useful for:

- **Conditional updates**: Confirming the document hasn't changed before updating it
- **Optimistic locking**: Preventing concurrent modification conflicts
- **Audit trails**: Tracking how many times a document has been modified

### Real-World Use Cases

**User profile lookup:**

```
GET /users/_doc/user_12345
```

Retrieve complete user information for session validation or profile display.

**Order detail retrieval:**

```
GET /orders/_doc/order_98765
```

Fetch a specific order for display in a customer service system or order tracking interface.

**Configuration retrieval:**

```
GET /config/_doc/app_settings
```

Load application configuration from Elasticsearch with minimal latency.

### Common Pitfalls

- **Type parameters**: In Elasticsearch 7.0+, the type parameter is deprecated and replaced with `_doc`
- **Missing documents**: Not checking the `found` field can lead to null reference errors in downstream code
- **Routing mismatches**: Documents indexed with custom routing cannot be retrieved without specifying the correct routing value
- **Case sensitivity**: Document IDs are case-sensitive; `ID_1` and `id_1` refer to different documents

### Comparison with Search API

| Aspect | Get API | Search API |
|--------|---------|-----------|
| **Performance** | Very fast (direct lookup) | Slower (index scanning) |
| **Use case** | Exact ID match required | Flexible querying needed |
| **Result count** | Single document | Multiple documents |
| **Relevance scoring** | Not applicable | Calculated |
| **Network overhead** | Minimal | Higher |

**Key Points:**
- The Get API is the most efficient way to retrieve documents when you have the document ID
- Multi-Get (mget) should be used instead of multiple individual Get requests for better performance
- The `found` field indicates whether a document exists
- Optional parameters allow retrieving specific fields or disabling source retrieval
- Routing values must match between indexing and retrieval for custom routing scenarios