## Upserts

### Overview

Upserts combine "update" and "insert" operations into a single atomic action — if a document exists, it's updated; if it doesn't exist, it's inserted. This eliminates the need for conditional logic to check document existence before deciding whether to create or modify it. Upserts are essential for scenarios involving data synchronization, inventory management, user registration workflows, and any situation where you need to handle both new and existing documents uniformly in a single operation.

### Basic Upsert Syntax

The upsert operation uses the Update API with an `upsert` parameter specifying the complete document to insert if it doesn't exist:

**Syntax:**

```
POST /<index>/_update/<id>
{
  "doc": { ... },
  "upsert": { ... }
}
```

**Example:**

```json
POST /products/_update/laptop_001
{
  "doc": {
    "price": 899.99,
    "stock": 15,
    "last_updated": "2024-01-15T10:30:00Z"
  },
  "upsert": {
    "name": "Dell XPS 13",
    "price": 899.99,
    "category": "Electronics",
    "stock": 15,
    "created_at": "2024-01-15T10:30:00Z",
    "last_updated": "2024-01-15T10:30:00Z"
  }
}
```

**Response if document exists (updated):**

```json
{
  "_index": "products",
  "_id": "laptop_001",
  "_version": 3,
  "result": "updated"
}
```

**Response if document doesn't exist (inserted):**

```json
{
  "_index": "products",
  "_id": "laptop_001",
  "_version": 1,
  "result": "created"
}
```

### Upsert Behavior

The upsert operation follows predictable logic:

1. **Document exists**: The `doc` parameter is merged into the existing document (partial update)
2. **Document doesn't exist**: The `upsert` parameter is inserted as a new document
3. **Result field**: Indicates whether the document was `updated` or `created`

**Scenario — document exists:**

Original document:

```json
{
  "name": "Dell XPS 13",
  "price": 1299.99,
  "category": "Electronics",
  "stock": 20,
  "created_at": "2024-01-10T08:00:00Z",
  "last_updated": "2024-01-10T08:00:00Z"
}
```

Upsert request:

```json
POST /products/_update/laptop_001
{
  "doc": {
    "price": 899.99,
    "stock": 15,
    "last_updated": "2024-01-15T10:30:00Z"
  },
  "upsert": {
    "name": "Dell XPS 13",
    "price": 899.99,
    "category": "Electronics",
    "stock": 15,
    "created_at": "2024-01-15T10:30:00Z",
    "last_updated": "2024-01-15T10:30:00Z"
  }
}
```

Result — fields from `doc` are merged into existing document:

```json
{
  "name": "Dell XPS 13",
  "price": 899.99,
  "category": "Electronics",
  "stock": 15,
  "created_at": "2024-01-10T08:00:00Z",
  "last_updated": "2024-01-15T10:30:00Z"
}
```

**Scenario — document doesn't exist:**

The entire `upsert` document is inserted:

```json
{
  "name": "Dell XPS 13",
  "price": 899.99,
  "category": "Electronics",
  "stock": 15,
  "created_at": "2024-01-15T10:30:00Z",
  "last_updated": "2024-01-15T10:30:00Z"
}
```

### Upsert with Partial Updates

The `doc` parameter in an upsert contains only fields to modify, preserving other fields:

**Request:**

```json
POST /users/_update/user_123
{
  "doc": {
    "email": "newemail@example.com",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  "upsert": {
    "username": "john_doe",
    "email": "newemail@example.com",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

If user_123 exists, only `email` and `updated_at` are modified. Other fields remain unchanged. If it doesn't exist, the entire `upsert` document is created.

### Scripted Upserts

Combine scripts with upserts for complex initialization logic or conditional updates:

**Script-based upsert — increment counter:**

```json
POST /metrics/_update/daily_views
{
  "script": {
    "source": "ctx._source.count += params.increment",
    "params": {
      "increment": 1
    }
  },
  "upsert": {
    "date": "2024-01-15",
    "count": 1
  }
}
```

If document exists, the script increments the count. If it doesn't exist, the upsert initializes count to 1.

**Script-based upsert — conditional update:**

```json
POST /inventory/_update/sku_abc123
{
  "script": {
    "source": "if (ctx._source.quantity >= params.threshold) { ctx._source.needs_restock = true }",
    "params": {
      "threshold": 10
    }
  },
  "upsert": {
    "sku": "abc123",
    "product_name": "Widget",
    "quantity": 100,
    "needs_restock": false
  }
}
```

The script checks if quantity is below threshold and sets `needs_restock` flag. If the document doesn't exist, it's created with `needs_restock: false`.

**Script-based upsert — array operations:**

```json
POST /items/_update/item_789
{
  "script": {
    "source": "ctx._source.tags.add(params.tag)",
    "params": {
      "tag": "featured"
    }
  },
  "upsert": {
    "name": "Product X",
    "tags": ["featured"]
  }
}
```

If the document exists, the script adds "featured" to the tags array. If it doesn't exist, it's created with tags containing "featured".

### Bulk Upserts

The Bulk API supports upsert operations for efficient mass upserts:

**Request:**

```json
POST /products/_bulk
{"update":{"_id":"1"}}
{"doc":{"price":899.99},"upsert":{"name":"Laptop","price":899.99}}
{"update":{"_id":"2"}}
{"doc":{"price":24.99},"upsert":{"name":"Mouse","price":24.99}}
{"update":{"_id":"3"}}
{"doc":{"stock":50},"upsert":{"name":"Keyboard","stock":50}}
```

**Response:**

```json
{
  "took": 45,
  "errors": false,
  "items": [
    {
      "update": {
        "_id": "1",
        "_version": 1,
        "result": "created"
      }
    },
    {
      "update": {
        "_id": "2",
        "_version": 2,
        "result": "updated"
      }
    },
    {
      "update": {
        "_id": "3",
        "_version": 1,
        "result": "created"
      }
    }
  ]
}
```

Bulk upserts are significantly more efficient than individual upsert requests for mass operations.

### Upsert with doc_as_upsert

The `doc_as_upsert` parameter uses the `doc` content for both update and insert, eliminating duplicate definitions:

**Standard upsert (document duplication):**

```json
POST /products/_update/laptop_001
{
  "doc": {
    "name": "Dell XPS 13",
    "price": 899.99,
    "category": "Electronics"
  },
  "upsert": {
    "name": "Dell XPS 13",
    "price": 899.99,
    "category": "Electronics"
  }
}
```

**Simplified upsert with doc_as_upsert:**

```json
POST /products/_update/laptop_001
{
  "doc": {
    "name": "Dell XPS 13",
    "price": 899.99,
    "category": "Electronics"
  },
  "doc_as_upsert": true
}
```

When `doc_as_upsert: true`, the `doc` content is used for both update (if exists) and insert (if missing), reducing request payload.

### Upsert with Conditional Execution

Combine upserts with version conditions to prevent overwriting newer data:

**Request:**

```json
POST /products/_update/laptop_001?if_seq_no=10&if_primary_term=1
{
  "doc": {
    "price": 799.99,
    "last_updated": "2024-01-15T10:30:00Z"
  },
  "upsert": {
    "name": "Dell XPS 13",
    "price": 799.99,
    "last_updated": "2024-01-15T10:30:00Z"
  }
}
```

The upsert succeeds only if the document's sequence number matches (or if the document doesn't exist for insertion).

### Upsert Retry on Conflict

For concurrent upserts to the same document, `retry_on_conflict` automatically retries on version conflicts:

**Request:**

```json
POST /products/_update/laptop_001?retry_on_conflict=3
{
  "doc": {
    "price": 749.99
  },
  "upsert": {
    "name": "Dell XPS 13",
    "price": 749.99
  }
}
```

If a version conflict occurs, Elasticsearch retries the upsert up to 3 times, fetching the latest document version each time.

### Real-World Use Cases

**User registration with profile initialization:**

```json
POST /users/_update/user_456
{
  "doc": {
    "last_login": "2024-01-15T10:30:00Z",
    "login_count": 1
  },
  "upsert": {
    "username": "john_doe",
    "email": "john@example.com",
    "created_at": "2024-01-15T10:30:00Z",
    "last_login": "2024-01-15T10:30:00Z",
    "login_count": 1
  }
}
```

If user exists (returning visitor), update login metadata. If new, create user profile with initial values.

**Inventory synchronization:**

```json
POST /inventory/_update/sku_xyz789
{
  "doc": {
    "quantity": 75,
    "last_sync": "2024-01-15T10:30:00Z"
  },
  "upsert": {
    "sku": "xyz789",
    "product_name": "Widget Pro",
    "quantity": 75,
    "last_sync": "2024-01-15T10:30:00Z"
  }
}
```

Sync inventory levels from external system. If SKU exists, update quantity. If new, create inventory record.

**Analytics aggregation:**

```json
POST /analytics/_update/page_visits_20240115
{
  "script": {
    "source": "ctx._source.total_visits += params.visits; ctx._source.unique_visitors += params.unique",
    "params": {
      "visits": 150,
      "unique": 45
    }
  },
  "upsert": {
    "date": "2024-01-15",
    "page": "/products",
    "total_visits": 150,
    "unique_visitors": 45
  }
}
```

Aggregate page visit metrics. If daily record exists, increment counters. If new day, create record with initial values.

**Social media engagement tracking:**

```json
POST /engagement/_update/user_123_20240115
{
  "script": {
    "source": "ctx._source.total_interactions += 1; ctx._source.last_interaction = params.timestamp",
    "params": {
      "timestamp": "2024-01-15T10:30:00Z"
    }
  },
  "upsert": {
    "user_id": "user_123",
    "date": "2024-01-15",
    "total_interactions": 1,
    "last_interaction": "2024-01-15T10:30:00Z"
  }
}
```

Track daily user engagement. If record exists, increment interaction count. If new, create daily record.

**Cache warming with conditional insertion:**

```json
POST /cache/_update/config_app_settings
{
  "doc": {
    "last_refreshed": "2024-01-15T10:30:00Z"
  },
  "upsert": {
    "app_name": "MyApp",
    "theme": "dark",
    "language": "en",
    "last_refreshed": "2024-01-15T10:30:00Z"
  }
}
```

Load application configuration. If exists, update refresh timestamp. If missing, initialize with defaults.

**E-commerce wishlist management:**

```json
POST /wishlists/_update/user_789
{
  "script": {
    "source": "ctx._source.items.add(params.item)",
    "params": {
      "item": { "sku": "laptop_001", "added_at": "2024-01-15T10:30:00Z" }
    }
  },
  "upsert": {
    "user_id": "user_789",
    "items": [
      { "sku": "laptop_001", "added_at": "2024-01-15T10:30:00Z" }
    ],
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

Add items to wishlist. If user wishlist exists, append new item. If new user, create wishlist with first item.

### Comparison: Upsert vs. Index vs. Update

| Aspect | Upsert | Index | Update |
|--------|--------|-------|--------|
| **Existence check** | Automatic | Not applicable | Fails if missing |
| **New documents** | Creates | Creates | Fails |
| **Existing documents** | Updates | Replaces entirely | Modifies fields |
| **Field preservation** | Yes (with doc) | No | Yes |
| **Use case** | Create-or-update | Full replacement | Modification only |
| **Risk of data loss** | Low | High | None |

### Upsert Limitations and Considerations

**Script errors on upsert:**

If a script error occurs during upsert, the document may not be inserted or updated. [Inference] Test scripts thoroughly before deploying to production.

**Nested field handling:**

Upserts with `doc_as_upsert: true` replace entire nested objects, not individual nested fields. [Inference] For nested field updates, include complete nested object structures in the `doc` parameter.

**Array field behavior:**

Arrays in the `doc` parameter are replaced entirely, not appended. Use scripts for array append operations.

**Performance with large documents:**

Upserts require fetching existing documents before merging. [Inference] For bulk operations on new data, Index API may be more efficient than Bulk Upserts.

### Error Handling in Upserts

**Mapping type mismatch:**

```json
{
  "error": {
    "type": "mapper_parsing_exception",
    "reason": "failed to parse field [price] of type [float] with value [invalid]"
  }
}
```

Field value doesn't match mapping type. Ensure `doc` and `upsert` have compatible field types.

**Script syntax error:**

```json
{
  "error": {
    "type": "script_exception",
    "reason": "runtime error"
  }
}
```

Script contains syntax errors. [Inference] Validate Painless scripts in development before production deployment.

**Index not found:**

```json
{
  "error": {
    "type": "index_not_found_exception",
    "reason": "no such index"
  }
}
```

Target index doesn't exist. Create the index before upserting documents.

### Upsert with Timestamp Fields

Common pattern — automatically set timestamps on creation and update:

**Request:**

```json
POST /articles/_update/article_001
{
  "doc": {
    "title": "Updated Title",
    "content": "New content here",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  "upsert": {
    "title": "Updated Title",
    "content": "New content here",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

If document exists, `updated_at` reflects modification time. If new, both `created_at` and `updated_at` are set.

### Upsert Idempotence

Upserts are idempotent — executing the same upsert multiple times produces the same result:

**First execution** (document doesn't exist):

```json
POST /products/_update/laptop_001
{
  "doc": { "price": 899.99 },
  "upsert": { "name": "Laptop", "price": 899.99 }
}
```

Result: `created`

**Second execution** (document now exists):

```json
POST /products/_update/laptop_001
{
  "doc": { "price": 899.99 },
  "upsert": { "name": "Laptop", "price": 899.99 }
}
```

Result: `noop` (document already has same price)

[Inference] Idempotent operations allow safe retries without creating duplicates or unintended side effects.

### Upsert Response with Source

Retrieve the resulting document in the upsert response:

**Request:**

```json
POST /products/_update/laptop_001?_source=true
{
  "doc": { "price": 899.99 },
  "upsert": { "name": "Laptop", "price": 899.99 }
}
```

**Response:**

```json
{
  "_id": "laptop_001",
  "_version": 1,
  "result": "created",
  "_source": {
    "name": "Laptop",
    "price": 899.99
  }
}
```

### Performance Best Practices

**Batch upserts efficiently:**

```json
POST /products/_bulk
{"update":{"_id":"1"}}
{"doc":{"price":899.99},"upsert":{"name":"Product 1","price":899.99}}
{"update":{"_id":"2"}}
{"doc":{"price":799.99},"upsert":{"name":"Product 2","price":799.99}}
...
```

Bulk upserts are significantly faster than individual upsert requests.

**Minimize script complexity:**

Simple field updates are faster than complex scripts. [Inference] Reserve scripts for operations requiring conditional logic or complex transformations.

**Use retry_on_conflict cautiously:**

Excessive retry attempts in high-concurrency scenarios may degrade performance. [Inference] Monitor retry rates and adjust concurrency patterns if needed.

**Key Points:**
- Upserts combine update and insert operations — documents are updated if they exist, inserted if they don't
- The `doc` parameter contains fields to modify/merge; the `upsert` parameter specifies the complete document to insert
- `doc_as_upsert: true` eliminates duplication by using `doc` content for both update and insert
- Scripted upserts enable complex logic like incrementing counters or conditional field modifications
- Bulk upserts efficiently handle mass upsert operations in a single request
- `retry_on_conflict` automatically retries on version conflicts in concurrent scenarios
- Upserts are idempotent — executing the same upsert multiple times produces consistent results
- Conditional execution with `if_seq_no` and `if_primary_term` prevents overwriting newer data
- Nested objects and arrays in `doc` are replaced entirely, not merged field-by-field
- Upserts are ideal for user registration, inventory synchronization, analytics aggregation, and cache warming