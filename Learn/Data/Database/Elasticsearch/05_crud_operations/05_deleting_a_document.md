## Deleting a document

### Overview

Deleting a document in Elasticsearch removes it from an index, making it unsearchable and inaccessible through retrieval operations. The Delete API provides the primary mechanism for removing individual documents by ID. Understanding deletion strategies, retention policies, and performance implications is essential for managing data lifecycle, maintaining index health, and controlling storage consumption in production environments.

### The Delete API

The Delete API removes a document from an index using its unique identifier. Deletion is permanent and cannot be undone; however, deleted documents can be recovered from index snapshots if backup strategies are in place.

**Basic syntax:**

```
DELETE /<index>/_doc/<id>
```

**Example request:**

```
DELETE /products/_doc/laptop_001
```

**Response:**

```json
{
  "_index": "products",
  "_id": "laptop_001",
  "_version": 5,
  "_seq_no": 18,
  "_primary_term": 1,
  "result": "deleted"
}
```

### Delete Response Structure

The Delete API response provides metadata about the deletion:

- **`_index`**: The index from which the document was deleted
- **`_id`**: The document ID that was deleted
- **`_version`**: The version number at deletion (increments from previous version)
- **`_seq_no`**: The sequence number assigned to the deletion operation
- **`_primary_term`**: Identifies the primary shard handling the deletion
- **`result`**: Indicates the outcome of the deletion (`deleted` or `not_found`)

### Deleting Non-Existent Documents

Attempting to delete a document that doesn't exist returns a `not_found` result:

**Request:**

```
DELETE /products/_doc/nonexistent_999
```

**Response:**

```json
{
  "_index": "products",
  "_id": "nonexistent_999",
  "_version": 1,
  "_seq_no": 0,
  "_primary_term": 1,
  "result": "not_found"
}
```

[Inference] Applications should handle both `deleted` and `not_found` results appropriately, as both indicate the document is no longer present in the index.

### Conditional Deletion

The `if_seq_no` and `if_primary_term` parameters enable conditional deletion, preventing accidental deletion of documents that have been modified by other processes:

**Request:**

```
DELETE /products/_doc/laptop_001?if_seq_no=18&if_primary_term=1
```

This deletion only succeeds if the document's sequence number is exactly 18 and primary term is 1. If another update has changed the document since you last read it, this deletion fails with a version conflict.

**Conflict response:**

```json
{
  "error": {
    "type": "version_conflict_engine_exception",
    "reason": "[laptop_001]: version conflict, required seqNo [18], primary term [1]. But got seqNo [19], primary term [1]"
  },
  "status": 409
}
```

### Bulk Deletion Operations

The Bulk API supports delete operations for removing multiple documents efficiently in a single request:

**Request format:**

```
POST /_bulk
```

**Request body:**

```json
{"delete":{"_index":"products","_id":"laptop_001"}}
{"delete":{"_index":"products","_id":"phone_002"}}
{"delete":{"_index":"products","_id":"tablet_003"}}
{"delete":{"_index":"products","_id":"monitor_004"}}
```

**Response:**

```json
{
  "took": 52,
  "errors": false,
  "items": [
    {
      "delete": {
        "_index": "products",
        "_id": "laptop_001",
        "_version": 5,
        "result": "deleted"
      }
    },
    {
      "delete": {
        "_index": "products",
        "_id": "phone_002",
        "_version": 3,
        "result": "deleted"
      }
    },
    {
      "delete": {
        "_index": "products",
        "_id": "tablet_003",
        "_version": 2,
        "result": "deleted"
      }
    },
    {
      "delete": {
        "_index": "products",
        "_id": "monitor_004",
        "result": "not_found"
      }
    }
  ]
}
```

Bulk deletion is significantly more efficient than individual Delete API calls for removing large numbers of documents.

### Delete by Query

The Delete by Query API removes all documents matching a specific query criterion. This operation is useful for bulk deletions based on field values rather than explicit document IDs:

**Syntax:**

```
POST /<index>/_delete_by_query
```

**Example — delete all archived documents:**

```json
POST /articles/_delete_by_query
{
  "query": {
    "term": {
      "status": "archived"
    }
  }
}
```

**Response:**

```json
{
  "took": 267,
  "timed_out": false,
  "total": 523,
  "deleted": 523,
  "batches": 3,
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

**Example — delete documents older than specific date:**

```json
POST /logs/_delete_by_query
{
  "query": {
    "range": {
      "timestamp": {
        "lt": "2023-01-01T00:00:00Z"
      }
    }
  }
}
```

### Delete by Query with Slicing

For large indexes, Delete by Query can process data in parallel slices to improve performance:

**Request:**

```json
POST /logs/_delete_by_query?slices=5
{
  "query": {
    "range": {
      "timestamp": {
        "lt": "2023-06-01T00:00:00Z"
      }
    }
  }
}
```

The `slices=5` parameter divides the query into 5 concurrent slices, each processing a portion of matching documents.

### Deletion with Routing

When documents are indexed with custom routing values, the same routing must be specified during deletion:

**Deletion with routing:**

```
DELETE /products/_doc/laptop_001?routing=user_456
```

[Inference] If the routing value doesn't match the value used during indexing, the deletion fails silently without actually removing the document.

### Refresh Parameter

The `refresh` parameter controls when the deleted document becomes invisible to search operations:

**Immediate refresh:**

```
DELETE /products/_doc/laptop_001?refresh=true
```

With `refresh=true`, the deletion is immediately visible in search results. [Inference] This has performance implications in high-throughput scenarios.

**Default behavior (without refresh):**

```
DELETE /products/_doc/laptop_001
```

Without the refresh parameter, the deletion may not appear in search results until the next scheduled refresh cycle.

### Soft Deletes vs. Hard Deletes

Elasticsearch supports two deletion approaches with different implications:

**Hard delete (standard deletion):**

```
DELETE /products/_doc/laptop_001
```

The document is completely removed from the index. [Unverified] Hard deletes can complicate index replication and shard recovery in some cluster configurations.

**Soft delete (application-level flag):**

```json
POST /products/_update/laptop_001
{
  "doc": {
    "is_deleted": true,
    "deleted_at": "2024-01-15T10:30:00Z"
  }
}
```

The document remains in the index but is marked as deleted. Queries must filter out documents with `is_deleted: true`.

[Inference] Soft deletes allow recovery of accidentally deleted documents and simplify audit trails but consume storage for inactive documents.

### Deletion Workflow in Multi-Shard Indexes

When a document exists in replicas, the deletion process occurs across primary and replica shards:

1. Deletion request reaches the primary shard
2. Primary shard marks document as deleted
3. Deletion is replicated to all replica shards
4. Primary confirms deletion to the client

[Inference] If replica shards are unavailable, the deletion operation may fail depending on the `wait_for_active_shards` setting.

### Real-World Use Cases

**User account deletion:**

```
DELETE /users/_doc/user_12345
```

Remove user profile when account is closed, though related data (orders, comments) may be retained for compliance.

**Expired session removal:**

```json
POST /sessions/_delete_by_query
{
  "query": {
    "range": {
      "expiry_time": {
        "lt": "now"
      }
    }
  }
}
```

Remove expired sessions regularly to manage storage and security.

**Temporary log deletion:**

```json
POST /logs-2024-01-15/_delete_by_query
{
  "query": {
    "range": {
      "level": {
        "lte": 2
      }
    }
  }
}
```

Delete debug and trace level logs while retaining error and warning logs.

**Rejected order removal:**

```json
POST /orders/_delete_by_query
{
  "query": {
    "bool": {
      "must": [
        { "term": { "status": "rejected" } },
        { "range": { "created_at": { "lt": "2023-01-01" } } }
      ]
    }
  }
}
```

Remove old rejected orders after retention period expires.

**Cache invalidation:**

```json
POST /cache/_delete_by_query
{
  "query": {
    "term": {
      "cache_key": "user_preferences:*"
    }
  }
}
```

Invalidate specific cache entries matching a pattern.

### Performance Considerations

**Delete API vs. Delete by Query:**

- **Delete API**: Fast for individual documents or small batches when IDs are known
- **Delete by Query**: More efficient for bulk deletion when documents are identified by criteria
- [Inference] Delete by Query may be slower initially but avoids multiple network round trips

**Index segment impact:**

Deletions don't immediately recover storage; deleted documents mark segments as containing deletions. [Unverified] Storage is reclaimed during index merging or index reindexing operations.

**Deletion throughput:**

```json
POST /logs/_delete_by_query?requests_per_second=1000
{
  "query": {
    "range": {
      "timestamp": { "lt": "2023-01-01T00:00:00Z" }
    }
  }
}
```

The `requests_per_second` parameter throttles deletion operations to control cluster load.

### Storage Implications

**Before deletion (200 documents, 10MB):**

```
Index size: 10MB
Document count: 200
Average per-document: 50KB
```

**After deleting 50 documents:**

```
Index size: ~9.5MB (deleted documents still consume space)
Document count: 150
Searchable documents: 150
```

[Inference] Storage reduction occurs gradually as Elasticsearch merges index segments and compacts deleted document space.

### Handling Deletion Failures

Deletions can fail due to version conflicts or cluster issues:

**Version conflict during deletion:**

```json
{
  "error": {
    "type": "version_conflict_engine_exception",
    "reason": "[laptop_001]: version conflict"
  },
  "status": 409
}
```

**Handling conflict:**

```json
POST /products/_update/laptop_001?retry_on_conflict=3
{
  "doc": {
    "is_deleted": true
  }
}
```

Or use soft delete approach instead of hard delete for better reliability.

### Cascading Deletions

Elasticsearch does not support automatic cascading deletions. Deleting a parent document does not automatically delete child documents:

**Parent document deletion:**

```
DELETE /companies/_doc/company_001
```

**Child documents remain:**

```
GET /employees/_search
{
  "query": {
    "term": {
      "company_id": "company_001"
    }
  }
}
```

Children with `company_id: company_001` still exist.

**Application-level cascading:**

```json
POST /employees/_delete_by_query
{
  "query": {
    "term": {
      "company_id": "company_001"
    }
  }
}
```

Applications must explicitly delete related documents.

### Deletion and Index Lifecycle

Deletion is typically part of broader index lifecycle management:

**Weekly log index lifecycle:**

- Days 0-7: Active index, read/write enabled
- Days 7-30: Warm index, read-only
- Days 30+: Delete index entirely

**Example — delete indices older than 90 days:**

```json
POST /_delete_by_query
{
  "query": {
    "range": {
      "@timestamp": {
        "lt": "now-90d"
      }
    }
  }
}
```

### Audit Trail for Deletions

For compliance scenarios, document deletion before hard delete:

```json
POST /audit_log/_create/deletion_record_001
{
  "deleted_document_id": "laptop_001",
  "deleted_from_index": "products",
  "deleted_at": "2024-01-15T10:30:00Z",
  "deleted_by": "user_789",
  "reason": "product_discontinued",
  "original_content_hash": "a7f8c2e9d1b4"
}
```

Then delete the actual document:

```
DELETE /products/_doc/laptop_001
```

### Limitations and Considerations

- **Permanent operation**: Deletion cannot be undone except by restoring from snapshots
- **No cascading**: Related documents in other indexes are not automatically deleted
- **Search consistency**: Deleted documents may remain visible briefly until refresh occurs
- **Storage recovery**: Storage is not immediately freed; segment merging is required
- **Irreversible at application level**: Once deleted, data recovery requires cluster backups

**Key Points:**
- The Delete API removes individual documents by ID and returns `deleted` or `not_found` result
- Delete by Query efficiently removes multiple documents matching query criteria
- Bulk API supports delete operations for mass deletion in a single request
- Conditional deletion using `if_seq_no` and `if_primary_term` prevents accidental deletion of modified documents
- Soft deletes (marking documents as deleted) provide recovery options versus hard deletes (permanent removal)
- Custom routing values must be specified for document deletion if used during indexing
- Delete by Query with slicing processes large deletions in parallel for improved performance
- Deleted documents occupy storage space until index segments are merged; storage recovery is gradual
- Elasticsearch does not support cascading deletions; applications must explicitly delete related documents