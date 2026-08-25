## Partial updates with update API

### Overview

Partial updates with the Update API allow you to modify specific fields within a document while preserving all other existing fields. This approach contrasts with the Index API, which replaces the entire document. Partial updates are essential for scenarios where you need to change only certain fields without affecting the document's complete state, reducing data transmission, processing overhead, and risk of unintended data loss.

### The doc Parameter

The `doc` parameter is the primary mechanism for performing partial updates. It contains only the fields you want to add or modify, while all other fields in the document remain unchanged.

**Basic syntax:**

```json
POST /<index>/_update/<id>
{
  "doc": {
    "field1": "new_value",
    "field2": "another_value"
  }
}
```

**Example:**

```json
POST /products/_update/laptop_001
{
  "doc": {
    "price": 899.99,
    "in_stock": true
  }
}
```

**Original document:**

```json
{
  "name": "Dell XPS 13",
  "category": "Electronics",
  "price": 1299.99,
  "in_stock": false,
  "color": "Silver",
  "warranty_months": 24
}
```

**After partial update:**

```json
{
  "name": "Dell XPS 13",
  "category": "Electronics",
  "price": 899.99,
  "in_stock": true,
  "color": "Silver",
  "warranty_months": 24
}
```

Only `price` and `in_stock` changed; all other fields remain intact.

### Response Structure for Partial Updates

The Update API returns metadata about the operation:

```json
{
  "_index": "products",
  "_id": "laptop_001",
  "_version": 3,
  "_seq_no": 12,
  "_primary_term": 1,
  "result": "updated",
  "took": 15
}
```

- **`_version`**: Increments with each update
- **`result`**: Indicates the outcome (`updated`, `noop`, or `created`)
- **`took`**: Milliseconds required to complete the operation

### Detecting Unchanged Updates (noop)

When the fields you're updating already have the exact values you're sending, Elasticsearch returns a `noop` (no operation) result:

**Request:**

```json
POST /products/_update/laptop_001
{
  "doc": {
    "price": 899.99
  }
}
```

**Response (if price is already 899.99):**

```json
{
  "_index": "products",
  "_id": "laptop_001",
  "_version": 3,
  "result": "noop"
}
```

[Inference] Checking for `noop` results allows applications to track which updates actually modified data, useful for audit logging or performance monitoring.

### Partial Updates with Nested Objects

Partial updates work seamlessly with nested object structures. When updating a nested field, the entire nested object is replaced:

**Original document:**

```json
{
  "product_id": "phone_001",
  "name": "iPhone 15",
  "specifications": {
    "storage_gb": 128,
    "color": "Black",
    "condition": "New"
  },
  "price": 999.99
}
```

**Partial update:**

```json
POST /products/_update/phone_001
{
  "doc": {
    "specifications": {
      "storage_gb": 256,
      "color": "Black",
      "condition": "New"
    }
  }
}
```

**Result after update:**

```json
{
  "product_id": "phone_001",
  "name": "iPhone 15",
  "specifications": {
    "storage_gb": 256,
    "color": "Black",
    "condition": "New"
  },
  "price": 999.99
}
```

The entire `specifications` object is replaced, but other fields remain unchanged.

### Updating Individual Nested Fields

To update only specific nested fields without replacing the entire nested object, you must include all existing nested fields in the update request:

**Request (updating only storage_gb):**

```json
POST /products/_update/phone_001
{
  "doc": {
    "specifications": {
      "storage_gb": 512,
      "color": "Black",
      "condition": "New"
    }
  }
}
```

[Inference] This approach requires fetching the current document first to preserve existing nested field values, which is less efficient than updating a single nested field directly.

### Adding New Fields Through Partial Updates

Partial updates can introduce completely new fields to a document:

**Original document:**

```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "created_at": "2023-01-15"
}
```

**Partial update adding new field:**

```json
POST /users/_update/user_456
{
  "doc": {
    "phone_number": "+1-555-0123",
    "verified": true
  }
}
```

**Result:**

```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "created_at": "2023-01-15",
  "phone_number": "+1-555-0123",
  "verified": true
}
```

### Partial Updates with Arrays

Partial updates replace entire array fields; they do not modify individual array elements:

**Original document:**

```json
{
  "product_id": "item_789",
  "name": "Smart Watch",
  "tags": ["electronics", "wearable", "gadget"],
  "reviews": [8.5, 9.0, 8.8]
}
```

**Partial update replacing array:**

```json
POST /products/_update/item_789
{
  "doc": {
    "tags": ["electronics", "wearable", "fitness"]
  }
}
```

**Result:**

```json
{
  "product_id": "item_789",
  "name": "Smart Watch",
  "tags": ["electronics", "wearable", "fitness"],
  "reviews": [8.5, 9.0, 8.8]
}
```

The `tags` array is completely replaced, but `reviews` remains unchanged.

### Partial Updates with Upsert

Combine partial updates with upsert to handle both update and insert scenarios. The `upsert` parameter specifies the complete document structure if the document doesn't exist:

**Request:**

```json
POST /inventory/_update/sku_abc123
{
  "doc": {
    "last_restocked": "2024-01-15T10:30:00Z",
    "stock_count": 50
  },
  "upsert": {
    "sku": "abc123",
    "product_name": "Widget X",
    "last_restocked": "2024-01-15T10:30:00Z",
    "stock_count": 50,
    "category": "Widgets"
  }
}
```

- If document `sku_abc123` exists, only `last_restocked` and `stock_count` are updated
- If it doesn't exist, the entire `upsert` document is inserted

### Conditional Partial Updates

Using the `if_seq_no` and `if_primary_term` parameters prevents updating documents that have been modified by other processes:

**Request:**

```json
POST /products/_update/laptop_001?if_seq_no=12&if_primary_term=1
{
  "doc": {
    "price": 799.99
  }
}
```

This update only succeeds if the document's sequence number is exactly 12 and primary term is 1. If another update has changed the document, this request fails with a version conflict.

### Retry on Conflict

For concurrent partial updates to the same document, the `retry_on_conflict` parameter automatically retries the operation if a version conflict occurs:

**Request:**

```json
POST /products/_update/laptop_001?retry_on_conflict=3
{
  "doc": {
    "stock": 15
  }
}
```

If a conflict occurs, Elasticsearch fetches the latest document and retries the partial update up to 3 times.

[Inference] This approach is effective for high-concurrency scenarios where multiple clients update the same document's non-overlapping fields.

### Partial Updates with Source Filtering

You can retrieve the updated document fields in the response using the `_source` parameter:

**Request:**

```json
POST /products/_update/laptop_001?_source=true
{
  "doc": {
    "price": 699.99
  }
}
```

**Response:**

```json
{
  "_index": "products",
  "_id": "laptop_001",
  "_version": 4,
  "result": "updated",
  "_source": {
    "name": "Dell XPS 13",
    "category": "Electronics",
    "price": 699.99,
    "in_stock": true,
    "color": "Silver",
    "warranty_months": 24
  }
}
```

**Retrieve only specific fields:**

```json
POST /products/_update/laptop_001?_source_includes=price,stock
{
  "doc": {
    "price": 699.99
  }
}
```

### Bulk Partial Updates

The Bulk API supports partial updates efficiently by combining multiple operations in a single request:

**Request:**

```json
POST /_bulk
{"update":{"_index":"products","_id":"laptop_001"}}
{"doc":{"price":699.99,"stock":10}}
{"update":{"_index":"products","_id":"phone_002"}}
{"doc":{"price":799.99,"in_stock":true}}
{"update":{"_index":"products","_id":"tablet_003"}}
{"doc":{"discount_percent":15}}
```

**Response:**

```json
{
  "took": 38,
  "errors": false,
  "items": [
    {
      "update": {
        "_index": "products",
        "_id": "laptop_001",
        "_version": 4,
        "result": "updated"
      }
    },
    {
      "update": {
        "_index": "products",
        "_id": "phone_002",
        "_version": 2,
        "result": "updated"
      }
    },
    {
      "update": {
        "_index": "products",
        "_id": "tablet_003",
        "_version": 3,
        "result": "updated"
      }
    }
  ]
}
```

### Comparison: Partial Update vs. Full Index

| Aspect | Partial Update | Full Index |
|--------|----------------|-----------|
| **Fields affected** | Only specified fields | Entire document |
| **Unspecified fields** | Preserved | Replaced (lost if omitted) |
| **Network bandwidth** | Lower (fewer fields) | Higher (entire document) |
| **Processing overhead** | Moderate (fetch + merge) | Lower (direct write) |
| **Risk of data loss** | Lower | Higher |
| **Ideal for** | Changing few fields | Bulk replacements |

**Example comparison:**

Updating 3 fields in a 50-field document:

- **Partial update**: Send 3 fields, preserve 47 fields
- **Full index**: Send all 50 fields or risk losing 47 fields

### Real-World Use Cases

**User profile updates:**

```json
POST /users/_update/user_12345
{
  "doc": {
    "email": "newemail@example.com",
    "phone": "+1-555-9876",
    "last_updated": "2024-01-15T10:30:00Z"
  }
}
```

Update contact information without affecting user creation date, preferences, or other fields.

**E-commerce product updates:**

```json
POST /products/_update/sku_xyz789
{
  "doc": {
    "price": 45.99,
    "stock": 120,
    "last_price_change": "2024-01-15T10:30:00Z"
  }
}
```

Update price and inventory while preserving product description, category, and reviews.

**Subscription status updates:**

```json
POST /subscriptions/_update/sub_456789
{
  "doc": {
    "status": "active",
    "renewal_date": "2024-07-15",
    "last_status_change": "2024-01-15T10:30:00Z"
  }
}
```

Update subscription status and renewal date without affecting billing history or plan details.

**Document enrichment:**

```json
POST /articles/_update/article_999
{
  "doc": {
    "processed": true,
    "word_count": 2847,
    "sentiment_score": 0.82,
    "processing_date": "2024-01-15T10:30:00Z"
  }
}
```

Add computed or enrichment data to documents after initial creation.

### Performance Implications

**Advantages of partial updates:**

- Reduced network payload compared to full document indexing
- Lower memory consumption for large documents where few fields change
- [Inference] Faster request transmission for high-volume update scenarios

**Disadvantages of partial updates:**

- Elasticsearch must fetch the existing document before merging changes
- Additional processing required for merge operation
- [Inference] For bulk operations on completely new data, full indexing may be more efficient

### Field Mapping Considerations

Partial updates respect existing field mappings. Attempting to update a field with an incompatible data type causes an error:

**Mapping definition:**

```json
{
  "mappings": {
    "properties": {
      "price": { "type": "float" },
      "created_at": { "type": "date" }
    }
  }
}
```

**Invalid partial update (type mismatch):**

```json
POST /products/_update/item_001
{
  "doc": {
    "price": "not_a_number"
  }
}
```

This fails because `price` expects a float, not a string.

### Handling Missing Documents

Partial updates alone do not insert missing documents. To insert if missing, use the `upsert` parameter:

**Without upsert (fails if document missing):**

```json
POST /products/_update/new_item
{
  "doc": {
    "name": "New Product"
  }
}
```

Returns a 404 error if `new_item` doesn't exist.

**With upsert (inserts if missing):**

```json
POST /products/_update/new_item
{
  "doc": {
    "name": "New Product"
  },
  "upsert": {
    "name": "New Product",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

Creates the document if it doesn't exist.

**Key Points:**
- Partial updates modify only specified fields while preserving all other existing fields
- The `doc` parameter contains only the fields to add or modify
- Partial updates return `noop` when no field values actually change
- Upsert can be combined with partial updates to handle insert-or-update scenarios
- Nested objects and arrays are replaced entirely, not merged field-by-field
- Bulk API enables efficient partial updates of multiple documents in a single request
- `retry_on_conflict` automatically retries partial updates when version conflicts occur
- Partial updates require document fetching and merging, potentially slower than full indexing for bulk operations