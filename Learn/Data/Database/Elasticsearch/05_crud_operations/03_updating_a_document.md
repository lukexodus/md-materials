## Updating a document

### Overview

Updating a document in Elasticsearch modifies specific fields within an existing document without requiring you to reindex the entire document. The Update API provides several mechanisms for making changes, from simple field replacements to complex script-based transformations. Understanding update strategies is essential for maintaining data accuracy and system performance in production environments.

### The Update API

The Update API allows you to modify documents in place. Unlike the Index API (which replaces the entire document), the Update API can change only the fields you specify.

**Basic syntax:**

```
POST /<index>/_update/<id>
```

**Example request:**

```json
POST /products/_update/1
{
  "doc": {
    "price": 899.99,
    "stock": 14
  }
}
```

This request updates the `price` and `stock` fields of document with ID `1`, leaving other fields unchanged.

**Response:**

```json
{
  "_index": "products",
  "_id": "1",
  "_version": 3,
  "_seq_no": 6,
  "_primary_term": 1,
  "result": "updated"
}
```

### Update Request Structure

The Update API request body has specific structure requirements:

- **`doc`**: Contains the fields to merge into the existing document (partial update)
- **`script`**: Contains a script to execute for complex transformations
- **`upsert`**: Specifies what to insert if the document doesn't exist

**Simple field update:**

```json
{
  "doc": {
    "status": "active",
    "last_modified": "2024-01-15"
  }
}
```

### Partial Updates with doc

The `doc` parameter allows you to update specific fields while preserving all other existing fields:

**Example:**

```json
POST /users/_update/user_456
{
  "doc": {
    "email": "newemail@example.com",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

Original document:

```json
{
  "name": "John Doe",
  "email": "oldemail@example.com",
  "phone": "555-1234",
  "updated_at": "2024-01-10T08:00:00Z"
}
```

After update:

```json
{
  "name": "John Doe",
  "email": "newemail@example.com",
  "phone": "555-1234",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

Fields `name` and `phone` remain unchanged.

### Script-Based Updates

For complex update logic, you can use scripts (written in Painless, the Elasticsearch scripting language) to transform document fields dynamically:

**Increment a counter:**

```json
POST /analytics/_update/page_views_1
{
  "script": {
    "source": "ctx._source.count += params.increment",
    "params": {
      "increment": 1
    }
  }
}
```

**Conditional field update:**

```json
POST /orders/_update/order_789
{
  "script": {
    "source": "if (ctx._source.status == 'pending') { ctx._source.status = 'processing'; ctx._source.processed_at = params.timestamp }",
    "params": {
      "timestamp": "2024-01-15T10:30:00Z"
    }
  }
}
```

**Add an element to an array:**

```json
POST /items/_update/item_123
{
  "script": {
    "source": "ctx._source.tags.add(params.tag)",
    "params": {
      "tag": "featured"
    }
  }
}
```

**Remove an element from an array:**

```json
POST /items/_update/item_123
{
  "script": {
    "source": "ctx._source.tags.removeIf(t -> t == params.tag)",
    "params": {
      "tag": "old_tag"
    }
  }
}
```

### The Upsert Operation

Upsert combines "update" and "insert" — if the document exists, it updates it; if not, it inserts the provided document:

**Request:**

```json
POST /products/_update/new_product_999
{
  "doc": {
    "name": "New Gadget",
    "price": 49.99,
    "category": "Electronics"
  },
  "upsert": {
    "name": "New Gadget",
    "price": 49.99,
    "category": "Electronics",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

If document `new_product_999` doesn't exist, the `upsert` content is inserted. If it exists, the `doc` content is merged into it.

### Scripted Upsert

Combine scripts with upsert for complex initialization logic:

```json
POST /inventory/_update/sku_abc123
{
  "script": {
    "source": "ctx._source.quantity -= params.amount",
    "params": {
      "amount": 5
    }
  },
  "upsert": {
    "sku": "abc123",
    "quantity": 100,
    "last_updated": "2024-01-15T10:30:00Z"
  }
}
```

If the document exists, the script decrements quantity. If it doesn't exist, the upsert initializes it with quantity 100.

### Controlling Update Behavior

**Retry on conflict:**

The `retry_on_conflict` parameter handles concurrent updates by retrying if a version conflict occurs:

```json
POST /products/_update/1?retry_on_conflict=3
{
  "doc": {
    "price": 799.99
  }
}
```

This retries the update up to 3 times if version conflicts occur.

**Refresh parameter:**

```json
POST /products/_update/1?refresh=true
{
  "doc": {
    "stock": 10
  }
}
```

The `refresh=true` parameter makes the updated document immediately searchable. [Inference] Without refresh, the updated document may not appear in search results until the next refresh cycle.

### Update Response Codes

The `result` field in the response indicates what happened:

- **`updated`**: The document was modified
- **`noop`**: No operation was performed (document unchanged)
- **`created`**: The document was created via upsert

**Example noop response:**

```json
POST /products/_update/1
{
  "doc": {
    "price": 999.99
  }
}
```

If the document already has `price: 999.99`, the response includes `"result": "noop"`.

### Bulk Update Operations

The Bulk API supports update operations for modifying multiple documents in a single request:

**Request format:**

```
POST /_bulk
```

**Request body:**

```json
{"update":{"_index":"products","_id":"1"}}
{"doc":{"price":899.99}}
{"update":{"_index":"products","_id":"2"}}
{"doc":{"stock":25}}
{"update":{"_index":"products","_id":"3"}}
{"script":{"source":"ctx._source.views += 1"}}
```

**Response:**

```json
{
  "took": 45,
  "errors": false,
  "items": [
    {
      "update": {
        "_index": "products",
        "_id": "1",
        "_version": 4,
        "result": "updated"
      }
    },
    {
      "update": {
        "_index": "products",
        "_id": "2",
        "_version": 2,
        "result": "updated"
      }
    },
    {
      "update": {
        "_index": "products",
        "_id": "3",
        "_version": 5,
        "result": "updated"
      }
    }
  ]
}
```

### Update by Query

For updating multiple documents matching a query criterion, use the Update by Query API:

**Syntax:**

```
POST /<index>/_update_by_query
```

**Example — increase price for all electronics:**

```json
POST /products/_update_by_query
{
  "query": {
    "term": {
      "category": "Electronics"
    }
  },
  "script": {
    "source": "ctx._source.price *= params.factor",
    "params": {
      "factor": 1.1
    }
  }
}
```

**Response:**

```json
{
  "took": 147,
  "timed_out": false,
  "total": 42,
  "updated": 42,
  "deleted": 0,
  "batches": 1,
  "version_conflicts": 0,
  "noops": 0,
  "retries": {
    "bulk": 0,
    "search": 0
  },
  "throttled_millis": 0,
  "requests_per_second": -1.0,
  "throttled_until_millis": 0,
  "failures": []
}
```

### Performance Considerations

**Update vs. Index operations:**

[Inference] Update operations typically perform slower than Index operations because they require:
- Fetching the existing document
- Merging or transforming the fields
- Re-indexing the modified document

For bulk operations involving many documents, assess whether reindexing entire documents might be more efficient than individual updates.

**Script performance:**

Complex scripts incur computational overhead. [Inference] Simple field updates using `doc` parameter are generally faster than script-based updates.

**Refresh impact:**

Using `refresh=true` on each update can significantly impact performance in high-throughput scenarios. [Unverified] Consider batching updates and using bulk refresh strategies for production systems.

### Version Control and Conflicts

Elasticsearch maintains a version number for each document. Concurrent updates to the same document can cause version conflicts:

**Version conflict example:**

```
Request 1: Update document v1 to v2
Request 2: Update document v1 to v2 (conflict if request 2 was delayed)
```

The second request fails because the document is now at version 2, not version 1.

**Handling conflicts:**

```json
POST /products/_update/1?retry_on_conflict=5
{
  "doc": {
    "price": 749.99
  }
}
```

### Common Update Patterns

**Timestamp tracking:**

```json
POST /articles/_update/article_001
{
  "doc": {
    "title": "Updated Title",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

**Status transitions:**

```json
POST /tasks/_update/task_555
{
  "script": {
    "source": "ctx._source.status = params.new_status; ctx._source.status_changed_at = params.timestamp",
    "params": {
      "new_status": "completed",
      "timestamp": "2024-01-15T10:30:00Z"
    }
  }
}
```

**Counter increment:**

```json
POST /metrics/_update/daily_clicks
{
  "script": {
    "source": "ctx._source.count += 1"
  },
  "upsert": {
    "count": 1
  }
}
```

**Nested field update:**

```json
POST /users/_update/user_789
{
  "doc": {
    "profile": {
      "bio": "New biography",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  }
}
```

### Real-World Use Cases

**Inventory management:**

```json
POST /inventory/_update/sku_xyz789
{
  "script": {
    "source": "ctx._source.available_stock -= params.sold",
    "params": {
      "sold": 5
    }
  }
}
```

Decrement stock count when items are sold.

**User engagement tracking:**

```json
POST /users/_update/user_123
{
  "script": {
    "source": "ctx._source.last_login = params.timestamp; ctx._source.login_count += 1",
    "params": {
      "timestamp": "2024-01-15T10:30:00Z"
    }
  }
}
```

Update last login time and increment login counter simultaneously.

**Document enrichment:**

```json
POST /articles/_update/article_456
{
  "doc": {
    "processed": true,
    "sentiment_score": 0.87,
    "tags": ["positive", "featured"]
  }
}
```

Add computed fields or enrichment data to existing documents.

### Limitations and Considerations

- **No partial array updates**: Updating a specific element within an array typically requires script logic
- **Type coercion**: Field values must match the field's mapping type
- **Script limitations**: Some operations (like complex string transformations) may require application-level processing instead
- **Network latency**: Update operations require network round trips; batching improves efficiency

**Key Points:**
- The Update API modifies specific fields without reindexing entire documents
- Partial updates using `doc` preserve all existing fields not mentioned in the request
- Scripts enable complex transformations using Painless scripting language
- Upsert operations insert documents if they don't exist, then apply updates
- Bulk API and Update by Query allow efficient mass updates
- Version conflicts can occur with concurrent updates; `retry_on_conflict` provides automatic retry logic
- Update operations typically perform slower than Index operations due to document fetching and merging overhead