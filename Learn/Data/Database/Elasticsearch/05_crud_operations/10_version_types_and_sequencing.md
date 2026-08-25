## Version types and sequencing

### Overview

Elasticsearch uses multiple versioning mechanisms to track document changes and coordinate concurrent modifications. Understanding the differences between `_version`, `_seq_no` (sequence number), and `_primary_term` is essential for implementing robust optimistic concurrency control, debugging replication issues, and choosing appropriate version strategies for different scenarios. Each versioning approach has distinct characteristics, use cases, and limitations that impact how documents are managed across distributed shards and replicas.

### The _version Field

The `_version` field is the legacy versioning mechanism in Elasticsearch. It's a simple integer counter that increments with each document modification, including index, update, and delete operations.

**Version increment behavior:**

```json
Initial document:
POST /products/_doc/item_001
{
  "name": "Laptop",
  "price": 999.99
}

Response: _version: 1

Update 1:
POST /products/_update/item_001
{
  "doc": { "price": 899.99 }
}

Response: _version: 2

Update 2:
POST /products/_update/item_001
{
  "doc": { "stock": 50 }
}

Response: _version: 3
```

Each operation increments the version by 1, providing a simple count of modifications.

**Retrieving _version:**

```json
GET /products/_doc/item_001

Response:
{
  "_index": "products",
  "_id": "item_001",
  "_version": 3,
  "_seq_no": 2,
  "_primary_term": 1,
  "found": true,
  "_source": { ... }
}
```

The Get API returns the current `_version` alongside other versioning fields.

### Version Increments on Delete

Deleting a document increments its version:

```json
DELETE /products/_doc/item_001

Response:
{
  "_index": "products",
  "_id": "item_001",
  "_version": 4,
  "result": "deleted"
}
```

Even after deletion, the version number increases. [Inference] This means a document can exist at version 1, 2, 3, be deleted at version 4, and if recreated, continue from version 5 or higher.

### External Versioning

External versioning allows applications to provide their own version numbers instead of relying on Elasticsearch's internal counters:

**Request with external version:**

```json
PUT /products/_doc/item_001?version=100&version_type=external
{
  "name": "Laptop",
  "price": 999.99
}
```

The `version_type=external` parameter tells Elasticsearch to use the provided version number (100) rather than auto-incrementing.

**Response:**

```json
{
  "_index": "products",
  "_id": "item_001",
  "_version": 100,
  "result": "created"
}
```

**Subsequent updates with external versioning:**

```json
PUT /products/_doc/item_001?version=101&version_type=external
{
  "name": "Laptop",
  "price": 899.99
}

Response: _version: 101 (only succeeds if new version > current version)
```

With external versioning, updates only succeed if the provided version number is greater than the current version. This allows synchronizing with external systems that maintain their own version counters.

**Conflict when using lower external version:**

```json
PUT /products/_doc/item_001?version=50&version_type=external
{
  "name": "Laptop"
}

Error: version_conflict_engine_exception
Reason: version [50] is less than the current version [101]
```

Attempting to write with a lower external version fails.

### Sequence Numbers (_seq_no)

Sequence numbers are monotonically increasing counters assigned to each operation within a shard. Unlike `_version`, sequence numbers are more reliable in distributed scenarios and don't reset on index recreation.

**Sequence number characteristics:**

- **Monotonically increasing**: Each operation gets a higher sequence number
- **Shard-local**: Sequence numbers are specific to each shard
- **Immutable**: Once assigned, a sequence number never changes
- **Reliable on failover**: Preserved when replica shards become primary

**Sequence number example:**

```json
Document 1: _seq_no: 0
Document 2: _seq_no: 1
Document 3: _seq_no: 2
Update Document 2: _seq_no: 3
Delete Document 1: _seq_no: 4
Create Document 4: _seq_no: 5
```

Each operation (regardless of document) receives the next sequence number in order.

**Retrieving sequence numbers:**

```json
GET /products/_doc/item_001

Response:
{
  "_index": "products",
  "_id": "item_001",
  "_seq_no": 12,
  "_primary_term": 1,
  "_version": 5,
  "found": true,
  "_source": { ... }
}
```

Sequence numbers appear in Get responses and search results.

### Primary Term (_primary_term)

The primary term identifies which primary shard replica assigned a sequence number. It changes when shard failovers occur, indicating that a replica shard has become the primary.

**Primary term characteristics:**

- **Identifies primary shard**: Indicates which replica is the primary
- **Changes on failover**: Increments when replica becomes primary
- **Used with seq_no**: Together form definitive version identification
- **Cluster topology dependent**: Reflects current shard leadership

**Primary term example:**

```json
Initial state:
Node 1 (Primary): _primary_term: 1
Replicas: Node 2, Node 3

Node 1 fails:
Node 2 becomes primary: _primary_term: 2

New documents get _primary_term: 2
Existing documents still have _primary_term: 1
```

### seq_no + primary_term vs. _version

The combination of `_seq_no` and `_primary_term` is superior to `_version` alone for several reasons:

**Limitations of _version:**

```
Scenario: Index recreation
Old index: Documents at version 1-100
Index deleted
New index recreated
New documents start at version 1

Risk: Version numbers restart, creating confusion
```

[Unverified] `_version` can restart numbering in certain scenarios, potentially conflicting with external tracking systems.

**Advantages of seq_no + primary_term:**

```
Scenario: Shard failover
Primary Node 1 (term 1): seq_no 0-50
Node 1 fails

Primary Node 2 (term 2): seq_no 51+
Documents retain original seq_no + primary_term
Clear identification even after topology change
```

Sequence number and primary term together provide unambiguous identification regardless of cluster topology changes.

**Comparison:**

| Aspect | _version | _seq_no + _primary_term |
|--------|----------|------------------------|
| **Restart behavior** | May restart on index recreation | Never restarts within shard |
| **Failover handling** | May be inconsistent | Definitive (term changes) |
| **Reliability** | Legacy (deprecated) | Modern (preferred) |
| **Use case** | Simple optimistic locking | Distributed concurrency control |
| **Accuracy** | Lower | Higher |

### Conditional Operations with _version

The deprecated `if_match_version` parameter uses `_version` for conditional writes:

**Request:**

```json
PUT /products/_doc/item_001?if_match_version=3
{
  "name": "Laptop",
  "price": 899.99
}
```

This operation succeeds only if the current `_version` is 3.

**Conflict response:**

```json
{
  "error": {
    "type": "version_conflict_engine_exception",
    "reason": "version conflict"
  },
  "status": 409
}
```

[Inference] This approach is deprecated; modern applications should use `if_seq_no` and `if_primary_term` instead.

### Conditional Operations with Sequence Numbers

Modern conditional operations use sequence number and primary term together:

**Request:**

```json
POST /products/_update/item_001?if_seq_no=12&if_primary_term=1
{
  "doc": {
    "price": 799.99
  }
}
```

This operation succeeds only if the document's sequence number is 12 and primary term is 1.

**Conflict response:**

```json
{
  "error": {
    "type": "version_conflict_engine_exception",
    "reason": "[item_001]: version conflict, required seqNo [12], primary term [1]. But got seqNo [13], primary term [1]."
  },
  "status": 409
}
```

The error message indicates the expected and actual sequence numbers, aiding debugging.

### Sequence Number Gaps

Sequence numbers aren't always continuous. Failed operations, aborted requests, and replica synchronization can create gaps:

**Gap scenario:**

```json
Operation 1: seq_no = 100
Operation 2: seq_no = 101
Operation 3 (fails internally): seq_no = 102 (not assigned)
Operation 4: seq_no = 102

Or alternatively:

Operation 1: seq_no = 100
Operation 2 (retried): seq_no = 101
Operation 2 (retried again): seq_no = 102
Final result: Multiple seq_nos consumed by single operation
```

[Inference] Applications shouldn't assume continuous numbering or attempt to detect missing operations by examining gaps.

### Translog and Sequence Numbers

The translog (transaction log) stores operations and is indexed by sequence number. Each shard maintains its translog separately:

**Translog structure:**

```
Shard 1 Translog:
seq_no: 0 - Index document A
seq_no: 1 - Index document B
seq_no: 2 - Update document A
seq_no: 3 - Delete document C
seq_no: 4 - Index document D

Shard 2 Translog:
seq_no: 0 - Index document A (replicated)
seq_no: 1 - Index document B (replicated)
seq_no: 2 - Update document A (replicated)
seq_no: 3 - Delete document C (replicated)
seq_no: 4 - Index document D (replicated)
```

The translog ensures durability and enables replica synchronization.

### Replica Synchronization and Sequence Numbers

Replicas synchronize with primary shards using sequence numbers:

**Synchronization process:**

```
Primary Shard:
seq_no: 0-100 (confirmed on replicas)
seq_no: 101-105 (pending on replicas)

Replica Shard:
seq_no: 0-100 (in-sync)
Fetches and applies seq_no: 101-105

New primary elected:
All in-sync replicas have seq_no: 0-105
Safe to promote replica as primary
```

Sequence numbers ensure replicas don't become primary until they're synchronized.

### Version Behavior in Bulk Operations

Bulk API operations also increment versions and sequence numbers:

**Bulk request:**

```json
POST /products/_bulk
{"index":{"_id":"1"}}
{"name":"Item 1"}
{"update":{"_id":"2"}}
{"doc":{"price":10.00}}
{"delete":{"_id":"3"}}
```

**Response with versions:**

```json
{
  "items": [
    {
      "index": {
        "_id": "1",
        "_version": 1,
        "_seq_no": 0,
        "_primary_term": 1
      }
    },
    {
      "update": {
        "_id": "2",
        "_version": 3,
        "_seq_no": 1,
        "_primary_term": 1
      }
    },
    {
      "delete": {
        "_id": "3",
        "_version": 2,
        "_seq_no": 2,
        "_primary_term": 1
      }
    }
  ]
}
```

Each operation increments sequence numbers and versions independently.

### Version Behavior with Identical Content

Elasticsearch detects when update operations don't actually change document content:

**Scenario — updating with same values:**

```json
POST /products/_update/item_001
{
  "doc": {
    "price": 999.99
  }
}
```

If the document already has `price: 999.99`:

```json
{
  "_id": "item_001",
  "_version": 3,
  "_seq_no": 10,
  "result": "noop"
}
```

Result is `noop` (no operation), but `_version` and `_seq_no` may still increment. [Inference] The exact behavior depends on Elasticsearch configuration; applications shouldn't rely on version immutability for unchanged updates.

### Version Behavior Across Shards

Each shard maintains independent sequence numbers:

**Multi-shard scenario:**

```
Shard 1:
Document A: _seq_no: 5, _primary_term: 1
Document B: _seq_no: 6, _primary_term: 1

Shard 2:
Document C: _seq_no: 3, _primary_term: 1
Document D: _seq_no: 4, _primary_term: 1
```

Sequence numbers aren't globally unique across shards; they're local to each shard. [Inference] Comparing sequence numbers across different shards is meaningless; use them only within a single shard's documents.

### Primary Term Changes on Failover

When a primary shard fails and a replica becomes primary, the primary term increments:

**Before failover:**

```json
Shard 1 Primary (Node 1):
Documents at _primary_term: 1
Last seq_no: 100
```

**Failover occurs (Node 1 fails):**

```json
Shard 1 Primary (Node 2, was replica):
Documents still have _primary_term: 1
New documents get _primary_term: 2
New seq_no: 101, 102, ...
```

Existing documents retain their original `_primary_term`; only new operations use the new term. This allows distinguishing operations from different primaries.

### Real-World Versioning Scenarios

**Inventory management with external sync:**

```json
External system version: 1001
Elasticsearch update:
PUT /inventory/_doc/sku_xyz?version=1001&version_type=external
{
  "quantity": 100,
  "last_sync_version": 1001
}

Later external version: 1002
Elasticsearch update:
PUT /inventory/_doc/sku_xyz?version=1002&version_type=external
{
  "quantity": 95,
  "last_sync_version": 1002
}

Conflict scenario (old sync retry):
PUT /inventory/_doc/sku_xyz?version=1001&version_type=external
Error: version [1001] is less than current [1002]
```

External versioning ensures Elasticsearch stays synchronized with the authoritative external system.

**Concurrent editor conflicts:**

```json
Editor A fetches article:
GET /articles/_doc/article_123
Response: _seq_no: 5, _primary_term: 1

Editor B fetches same article:
GET /articles/_doc/article_123
Response: _seq_no: 5, _primary_term: 1

Editor A saves changes:
POST /articles/_update/article_123?if_seq_no=5&if_primary_term=1
{
  "doc": { "content": "A's changes" }
}
Success: seq_no becomes 6

Editor B saves changes:
POST /articles/_update/article_123?if_seq_no=5&if_primary_term=1
{
  "doc": { "content": "B's changes" }
}
Conflict: seq_no is now 6, not 5
Editor B must fetch article again and re-apply changes
```

Both editors see the same version initially; the second editor's update fails, signaling a concurrent modification.

**Shard failover during writes:**

```json
Primary Node 1, Shard 1:
Document gets seq_no: 50, primary_term: 1

Node 1 fails, Node 2 replica becomes primary:
primary_term increments to 2
Existing document still has primary_term: 1
New operations get primary_term: 2

Conditional write referencing primary_term: 1:
POST /_update/doc?if_seq_no=50&if_primary_term=1
May still succeed if document wasn't modified under new primary

Conditional write referencing primary_term: 2:
Fails if document was last modified under primary_term: 1
Application detects stale version and retries
```

Primary term changes prevent confusion between operations from different shard leaders.

### Monitoring and Debugging Versions

**Checking version information in search results:**

```json
GET /products/_search

Response:
{
  "hits": {
    "hits": [
      {
        "_id": "item_001",
        "_version": 5,
        "_seq_no": 12,
        "_primary_term": 1,
        "_source": { ... }
      }
    ]
  }
}
```

Search results include version information if stored fields are requested.

**Detecting high-conflict operations:**

Track failed conditional writes (409 status):

```
High 409 rate on specific documents
→ Indicates concurrent modification
→ Consider data partitioning or restructuring
```

**Analyzing sequence number gaps:**

Large gaps between seq_no values may indicate:

```
- Deleted documents or failed operations
- Bulk operations processing multiple documents
- Shard synchronization activities
```

[Inference] Gaps are normal; they don't indicate missing data or corruption.

### Limitations and Considerations

**Version overflow:**

[Unverified] Theoretically, `_version` could overflow extremely large numbers, though practically this is unlikely in most applications.

**Sequence number consistency:**

[Inference] Sequence numbers are eventually consistent across replicas; briefly, different replicas may have different last sequence numbers.

**External version safety:**

External versioning requires application discipline. [Inference] If external version counter resets, Elasticsearch versions must be reset or risk permanent conflicts.

**Cross-shard version comparisons:**

Sequence numbers aren't comparable across shards. Each shard maintains independent numbering. [Inference] Combining documents from different shards requires application-level version tracking.

### Best Practices

**Use seq_no and primary_term for modern applications:**

```json
POST /_update/doc?if_seq_no=10&if_primary_term=1
```

Avoid deprecated `_version` for new code.

**Enable version tracking in search responses:**

```json
GET /products/_search
{
  "version": true
}
```

Retrieve version information for display and conflict detection.

**Implement retry logic for conflicts:**

```
On 409 response:
1. Fetch document with latest version
2. Re-apply changes
3. Retry with new version
```

**Monitor conflict rates:**

High rates indicate:
```
- Data contention issues
- Need for partitioning
- Inappropriate concurrency patterns
```

**Key Points:**
- `_version` is a deprecated legacy field that increments with each document modification but may restart on index recreation
- `_seq_no` (sequence number) is a monotonically increasing counter assigned to each operation within a shard, never restarting
- `_primary_term` identifies which primary shard replica assigned a sequence number and changes on failover
- The combination of `_seq_no` and `_primary_term` provides reliable, definitive document versioning superior to `_version` alone
- External versioning allows applications to supply their own version numbers and synchronize with external systems
- Sequence numbers are shard-local and aren't comparable across different shards
- Sequence number gaps are normal and don't indicate missing or corrupted data
- Conditional operations using `if_seq_no` and `if_primary_term` fail with 409 status if versions don't match
- Primary term increments on shard failover, allowing distinction between operations from different leaders
- Bulk operations increment versions and sequence numbers independently for each document operation