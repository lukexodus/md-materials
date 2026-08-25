## Bulk API

### Overview

The Bulk API enables efficient processing of multiple operations (index, create, update, delete) in a single request. Instead of sending individual requests for each document operation, the Bulk API batches operations together, significantly reducing network overhead, improving throughput, and enabling high-performance data ingestion at scale. This is essential for production environments handling large volumes of data modifications, reindexing operations, and data migrations.

### Basic Bulk API Syntax

The Bulk API uses a specialized line-delimited JSON (NDJSON) format where each operation consists of an action line followed by an optional data line.

**Syntax:**

```
POST /_bulk
POST /<index>/_bulk
```

**Request format:**

```json
{"action":{"metadata"}}
{"field":"value"}
{"action":{"metadata"}}
{"field":"value"}
```

**Example request:**

```json
POST /products/_bulk
{"index":{"_id":"1"}}
{"name":"Laptop","price":999.99,"category":"Electronics"}
{"index":{"_id":"2"}}
{"name":"Mouse","price":29.99,"category":"Accessories"}
{"create":{"_id":"3"}}
{"name":"Keyboard","price":79.99,"category":"Accessories"}
```

Each action line specifies the operation type and metadata. Data lines (containing document content) are required for index, create, and update operations but not for delete operations.

### Bulk API Action Types

The Bulk API supports four primary action types:

**index — Insert or replace:**

```json
{"index":{"_index":"products","_id":"1"}}
{"name":"Laptop","price":999.99}
```

Inserts a new document or replaces an existing document with the same ID.

**create — Insert only (fails if exists):**

```json
{"create":{"_index":"products","_id":"2"}}
{"name":"Mouse","price":29.99}
```

Inserts only if the document doesn't exist; fails with a version conflict if it does.

**update — Partial modification:**

```json
{"update":{"_index":"products","_id":"3"}}
{"doc":{"price":74.99}}
```

Modifies specific fields without replacing the entire document. Requires a `doc` parameter in the data line.

**delete — Remove document:**

```json
{"delete":{"_index":"products","_id":"4"}}
```

Removes a document. No data line required for delete operations.

### Bulk Request with Mixed Operations

A single Bulk API request can combine different operation types:

**Request:**

```json
POST /_bulk
{"index":{"_index":"products","_id":"1"}}
{"name":"Laptop","price":999.99,"stock":10}
{"update":{"_index":"products","_id":"2"}}
{"doc":{"price":25.99}}
{"create":{"_index":"products","_id":"3"}}
{"name":"Keyboard","price":79.99,"stock":25}
{"delete":{"_index":"products","_id":"4"}}
{"index":{"_index":"orders","_id":"order_001"}}
{"customer":"John Doe","total":1299.99,"status":"pending"}
```

**Response:**

```json
{
  "took": 87,
  "errors": false,
  "items": [
    {
      "index": {
        "_index": "products",
        "_id": "1",
        "_version": 1,
        "result": "created"
      }
    },
    {
      "update": {
        "_index": "products",
        "_id": "2",
        "_version": 3,
        "result": "updated"
      }
    },
    {
      "create": {
        "_index": "products",
        "_id": "3",
        "_version": 1,
        "result": "created"
      }
    },
    {
      "delete": {
        "_index": "products",
        "_id": "4",
        "_version": 2,
        "result": "deleted"
      }
    },
    {
      "index": {
        "_index": "orders",
        "_id": "order_001",
        "_version": 1,
        "result": "created"
      }
    }
  ]
}
```

### Bulk API Response Structure

The Bulk API response provides granular information about each operation:

- **`took`**: Total milliseconds to process the bulk request
- **`errors`**: Boolean indicating whether any operation failed
- **`items`**: Array of results, one per operation, in the same order as requests

Each item contains:

- **Operation name** (index, create, update, delete)
- **`_index`**: The index affected
- **`_id`**: The document ID
- **`_version`**: The document version after the operation
- **`result`**: The outcome (created, updated, deleted, not_found)
- **`error`** (if failed): Error details explaining the failure

### Handling Partial Failures

The Bulk API processes all operations even if some fail. Failed operations don't prevent subsequent operations from executing:

**Request with intentional error:**

```json
POST /products/_bulk
{"index":{"_id":"1"}}
{"name":"Laptop","price":"invalid_price"}
{"index":{"_id":"2"}}
{"name":"Mouse","price":29.99}
```

**Response showing partial failure:**

```json
{
  "took": 45,
  "errors": true,
  "items": [
    {
      "index": {
        "_index": "products",
        "_id": "1",
        "error": {
          "type": "mapper_parsing_exception",
          "reason": "failed to parse field [price] of type [float]"
        },
        "status": 400
      }
    },
    {
      "index": {
        "_index": "products",
        "_id": "2",
        "_version": 1,
        "result": "created",
        "status": 201
      }
    }
  ]
}
```

[Inference] Applications should inspect the `errors` flag and iterate through items to identify and handle failures appropriately.

### Error Handling in Bulk Operations

**Processing bulk response for errors:**

```json
{
  "items": [
    {
      "index": {
        "_id": "5",
        "status": 400,
        "error": {
          "type": "illegal_argument_exception",
          "reason": "request [/products/_bulk] contains unrecognized parameter: [invalid_param]"
        }
      }
    }
  ]
}
```

**Common error types:**

- **mapper_parsing_exception**: Field value doesn't match the mapping type
- **version_conflict_engine_exception**: Document version conflict during update
- **index_not_found_exception**: Target index doesn't exist
- **illegal_argument_exception**: Invalid request parameters or format

### Specifying Index in Bulk Operations

The Bulk API supports three approaches for specifying indexes:

**Global index (all operations use same index):**

```json
POST /products/_bulk
{"index":{"_id":"1"}}
{"name":"Laptop","price":999.99}
{"index":{"_id":"2"}}
{"name":"Mouse","price":29.99}
```

**Per-operation index specification:**

```json
POST /_bulk
{"index":{"_index":"products","_id":"1"}}
{"name":"Laptop","price":999.99}
{"index":{"_index":"orders","_id":"order_001"}}
{"customer":"John Doe","total":1299.99}
```

Useful when bulk operations span multiple indexes.

**Index in URL with per-operation override:**

```json
POST /products/_bulk
{"index":{"_id":"1"}}
{"name":"Laptop"}
{"index":{"_index":"archived_products","_id":"2"}}
{"name":"Old Mouse"}
```

The second operation uses `archived_products` instead of the default `products` index.

### Bulk API with Routing

Custom routing values must be specified in bulk operations to route documents to the correct shards:

**Request:**

```json
POST /products/_bulk
{"index":{"_id":"1","routing":"user_123"}}
{"name":"Laptop","price":999.99}
{"index":{"_id":"2","routing":"user_456"}}
{"name":"Mouse","price":29.99}
```

[Inference] If routing is not specified during bulk operations but was used during initial indexing, documents may not be found or updated correctly.

### Bulk API with Update Operations

Update operations in bulk require specific structure with `doc`, `script`, or `upsert` parameters:

**Bulk updates with doc parameter:**

```json
POST /products/_bulk
{"update":{"_id":"1"}}
{"doc":{"price":899.99,"stock":15}}
{"update":{"_id":"2"}}
{"doc":{"price":24.99}}
```

**Bulk updates with script:**

```json
POST /products/_bulk
{"update":{"_id":"1"}}
{"script":{"source":"ctx._source.views += params.views","params":{"views":5}}}
{"update":{"_id":"2"}}
{"script":{"source":"ctx._source.stock -= 1"}}
```

**Bulk updates with upsert:**

```json
POST /products/_bulk
{"update":{"_id":"new_product_1"}}
{"doc":{"name":"New Item","price":49.99},"upsert":{"name":"New Item","price":49.99,"created_at":"2024-01-15T10:30:00Z"}}
{"update":{"_id":"new_product_2"}}
{"doc":{"name":"Another Item","price":39.99},"upsert":{"name":"Another Item","price":39.99,"created_at":"2024-01-15T10:30:00Z"}}
```

### Bulk API with Conditionals

Conditional parameters enable operations only when specific version conditions are met:

**Request with if_seq_no and if_primary_term:**

```json
POST /products/_bulk
{"index":{"_id":"1","if_seq_no":10,"if_primary_term":1}}
{"name":"Updated Laptop","price":899.99}
{"update":{"_id":"2","if_seq_no":5,"if_primary_term":1}}
{"doc":{"price":24.99}}
```

Operations proceed only if version conditions match; otherwise they fail with a version conflict error.

### Bulk API Performance Optimization

**Optimal batch size:**

The ideal batch size depends on document size and cluster resources:

- **Small documents (< 1KB)**: 5,000-10,000 documents per batch
- **Medium documents (1-10KB)**: 1,000-5,000 documents per batch
- **Large documents (> 10KB)**: 100-1,000 documents per batch

[Inference] Larger batches reduce overhead but consume more memory; smaller batches process faster individually but require more requests.

**Batch request example:**

```json
POST /products/_bulk
{"index":{"_id":"1"}}
{"name":"Product 1","price":10.00}
{"index":{"_id":"2"}}
{"name":"Product 2","price":20.00}
...
{"index":{"_id":"10000"}}
{"name":"Product 10000","price":100000.00}
```

**Refresh parameter:**

```
POST /products/_bulk?refresh=false
```

Set `refresh=false` (default) for high-throughput bulk operations. Documents become searchable on the next refresh cycle, reducing per-operation overhead.

### Bulk API Concurrency and Throughput

**Sequential vs. parallel bulk requests:**

[Inference] Sending multiple bulk requests concurrently (5-10 in parallel) typically yields better throughput than sequential requests, allowing pipelining and better cluster resource utilization.

**Example parallel strategy:**

Send 10 concurrent bulk requests with 1,000 documents each rather than one sequential request with 10,000 documents.

### Real-World Use Cases

**Data ingestion from external source:**

```json
POST /logs/_bulk
{"index":{"_id":"log_001"}}
{"timestamp":"2024-01-15T10:00:00Z","level":"INFO","message":"Server started"}
{"index":{"_id":"log_002"}}
{"timestamp":"2024-01-15T10:01:30Z","level":"ERROR","message":"Connection timeout"}
{"index":{"_id":"log_003"}}
{"timestamp":"2024-01-15T10:02:15Z","level":"WARN","message":"High memory usage"}
```

Ingest application logs or metrics from monitoring systems.

**E-commerce product catalog sync:**

```json
POST /products/_bulk
{"create":{"_id":"sku_001"}}
{"name":"Laptop","price":999.99,"stock":50,"category":"Electronics"}
{"create":{"_id":"sku_002"}}
{"name":"Mouse","price":29.99,"stock":200,"category":"Accessories"}
{"update":{"_id":"sku_003"}}
{"doc":{"price":74.99,"stock":35}}
```

Synchronize product inventory and pricing from external systems.

**Index reindexing:**

```json
POST /products_v1/_search?scroll=1m
```

Then bulk index results into new index:

```json
POST /products_v2/_bulk
{"index":{"_id":"1"}}
{"name":"Laptop","price":999.99}
{"index":{"_id":"2"}}
{"name":"Mouse","price":29.99}
```

Reindex data from one index to another with transformations.

**User activity bulk import:**

```json
POST /user_events/_bulk
{"create":{"_id":"event_001"}}
{"user_id":"user_123","action":"login","timestamp":"2024-01-15T10:00:00Z"}
{"create":{"_id":"event_002"}}
{"user_id":"user_123","action":"view_product","product_id":"sku_001","timestamp":"2024-01-15T10:05:00Z"}
{"create":{"_id":"event_003"}}
{"user_id":"user_456","action":"purchase","amount":199.99,"timestamp":"2024-01-15T10:10:00Z"}
```

Import user activity events for analytics.

**Inventory level bulk update:**

```json
POST /inventory/_bulk
{"update":{"_id":"sku_001"}}
{"doc":{"quantity":45,"last_updated":"2024-01-15T10:30:00Z"}}
{"update":{"_id":"sku_002"}}
{"doc":{"quantity":198,"last_updated":"2024-01-15T10:30:00Z"}}
{"update":{"_id":"sku_003"}}
{"doc":{"quantity":32,"last_updated":"2024-01-15T10:30:00Z"}}
```

Update stock levels for multiple SKUs after inventory count.

### Bulk API Limitations and Constraints

**Maximum request size:**

Bulk requests default to a 100MB maximum size limit. [Unverified] This can be adjusted in cluster settings but consuming extremely large bulk requests may impact cluster stability.

**Field mapping changes:**

Adding new fields with different types than existing mappings causes errors. Field mappings must be compatible with bulk data.

**Transaction atomicity:**

Bulk operations are not atomic. If some operations fail, successful operations remain committed; there's no rollback mechanism.

**Memory consumption:**

Large bulk requests consume significant memory on both client and server. [Inference] Monitoring memory usage is important for high-frequency bulk operations.

### Bulk API Error Scenarios

**Mapping conflict:**

```json
{
  "items": [
    {
      "index": {
        "_id": "1",
        "error": {
          "type": "mapper_parsing_exception",
          "reason": "failed to parse field [price] of type [float] with value [abc]"
        },
        "status": 400
      }
    }
  ]
}
```

Document field value doesn't match the mapping type.

**Version conflict:**

```json
{
  "items": [
    {
      "update": {
        "_id": "1",
        "error": {
          "type": "version_conflict_engine_exception",
          "reason": "version conflict"
        },
        "status": 409
      }
    }
  ]
}
```

Document was modified by another process.

**Index not found:**

```json
{
  "items": [
    {
      "index": {
        "error": {
          "type": "index_not_found_exception",
          "reason": "no such index"
        },
        "status": 404
      }
    }
  ]
}
```

Target index doesn't exist.

### Monitoring Bulk Operations

**Key metrics to track:**

- **Throughput**: Documents per second processed
- **Error rate**: Percentage of failed operations
- **Latency**: Time from request to response
- **Bulk queue size**: Documents waiting for processing

[Inference] Monitoring these metrics helps identify bottlenecks and optimize batch sizing for different data patterns.

### Comparison: Bulk vs. Individual Operations

| Aspect | Bulk API | Individual Operations |
|--------|----------|----------------------|
| **Network overhead** | Minimal (single request) | High (multiple requests) |
| **Throughput** | Very high (hundreds/sec) | Low (tens/sec) |
| **Latency per op** | Lower average | Higher per operation |
| **Error handling** | Partial success possible | All-or-nothing per request |
| **Memory usage** | Higher (batch in memory) | Lower per request |
| **Use case** | Bulk ingestion, reindexing | Individual updates |

**Key Points:**
- The Bulk API processes multiple operations (index, create, update, delete) in a single request using NDJSON format
- Each operation consists of an action line and optional data line; delete operations have no data line
- The Bulk API continues processing all operations even if some fail, returning per-operation results
- Optimal batch size depends on document size: larger documents require smaller batches
- Custom routing must be specified in bulk operations if used during initial indexing
- Update operations in bulk require `doc`, `script`, or `upsert` parameters in the data line
- Bulk API supports conditional operations using `if_seq_no` and `if_primary_term` parameters
- Partial failures are normal; applications must check the `errors` flag and inspect individual item results
- Setting `refresh=false` improves bulk operation throughput by deferring document searchability
- Bulk API is essential for high-performance data ingestion, index reindexing, and mass updates