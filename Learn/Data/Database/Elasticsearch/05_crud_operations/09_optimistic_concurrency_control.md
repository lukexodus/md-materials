## Optimistic concurrency control

### Overview

Optimistic concurrency control prevents unintended data overwrites in concurrent environments by using version numbers to detect conflicts before committing changes. Rather than locking resources (pessimistic approach), optimistic concurrency allows multiple clients to read and modify documents simultaneously, detecting conflicts only when writes occur. If a conflict is detected, the operation fails, requiring the client to fetch the latest version and retry. This approach is essential for distributed systems, high-concurrency scenarios, and multi-user applications where locking would create bottlenecks.

### Versioning in Elasticsearch

Elasticsearch automatically maintains two version-related fields for each document:

- **`_version`**: A simple integer that increments with each modification (deprecated approach)
- **`_seq_no`** (sequence number): A monotonically increasing counter assigned during indexing
- **`_primary_term`**: Identifies the primary shard that indexed the document (changes on shard failover)

**Modern approach uses `_seq_no` and `_primary_term` together**, which provide more robust version control than `_version` alone.

### Basic Optimistic Concurrency with _version

The `_version` field increments with each document modification:

**Initial document:**

```json
POST /users/_doc/user_123
{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30
}
```

**Response (version 1):**

```json
{
  "_id": "user_123",
  "_version": 1,
  "_seq_no": 0,
  "_primary_term": 1,
  "result": "created"
}
```

**First update (version increments to 2):**

```json
POST /users/_update/user_123
{
  "doc": {
    "age": 31
  }
}
```

**Response:**

```json
{
  "_id": "user_123",
  "_version": 2,
  "_seq_no": 1,
  "_primary_term": 1,
  "result": "updated"
}
```

Each operation increments the version number.

### Conditional Updates with Version Numbers

Specify a required version number to ensure the document hasn't changed since your last read:

**Scenario — concurrent modification conflict:**

**Client A reads document (v2):**

```json
GET /users/_doc/user_123
```

Response includes `_version: 2`

**Client B updates document (now v3):**

```json
POST /users/_update/user_123
{
  "doc": {
    "email": "newemail@example.com"
  }
}
```

**Client A attempts update with stale version:**

```json
POST /users/_update/user_123?if_seq_no=1&if_primary_term=1
{
  "doc": {
    "age": 32
  }
}
```

[Inference] The request fails because the document's sequence number is now 2, not 1.

**Error response:**

```json
{
  "error": {
    "type": "version_conflict_engine_exception",
    "reason": "[user_123]: version conflict, required seqNo [1], primary term [1]. But got seqNo [2], primary term [1]."
  },
  "status": 409
}
```

HTTP status 409 (Conflict) signals that the version didn't match.

### Sequence Numbers and Primary Terms

Modern optimistic concurrency uses `_seq_no` and `_primary_term` instead of `_version`:

**Retrieving document with sequence details:**

```json
GET /users/_doc/user_123
```

**Response:**

```json
{
  "_index": "users",
  "_id": "user_123",
  "_version": 5,
  "_seq_no": 4,
  "_primary_term": 1,
  "found": true,
  "_source": {
    "name": "John Doe",
    "email": "john@example.com",
    "age": 31
  }
}
```

- **`_seq_no: 4`**: This document has been modified 4 times (0-indexed)
- **`_primary_term: 1`**: The primary shard hasn't failed over

**Conditional update with seq_no and primary_term:**

```json
POST /users/_update/user_123?if_seq_no=4&if_primary_term=1
{
  "doc": {
    "age": 32
  }
}
```

This update succeeds only if the document's sequence number is exactly 4 and primary term is 1.

### Why Sequence Numbers Over Version

**Limitations of `_version`:**

- [Unverified] Can restart from 1 after index recreation
- Doesn't account for shard failovers reliably
- Gap in numbering possible during concurrent operations

**Advantages of `_seq_no` and `_primary_term`:**

- Sequence numbers are monotonically increasing within a shard
- Primary term changes reflect shard failovers
- Combined, they provide definitive document state identification
- More reliable in distributed, high-availability scenarios

### Optimistic Concurrency Workflow

**Standard workflow for safe concurrent updates:**

1. **Read**: Fetch document and note `_seq_no` and `_primary_term`
2. **Modify**: Make changes in application logic
3. **Conditional Write**: Attempt update with version conditions
4. **Handle Conflict**: If conflict (409), go to step 1

**Example workflow:**

```json
Step 1: Read document
GET /users/_doc/user_123

Response: _seq_no: 4, _primary_term: 1

Step 2: Modify locally (age: 31 → 32)

Step 3: Conditional update
POST /users/_update/user_123?if_seq_no=4&if_primary_term=1
{
  "doc": {
    "age": 32
  }
}

Result: Success or 409 Conflict
```

### Retry on Conflict

Instead of implementing retry logic in application code, use the `retry_on_conflict` parameter:

**Request with automatic retry:**

```json
POST /users/_update/user_123?retry_on_conflict=3
{
  "doc": {
    "age": 32
  }
}
```

Elasticsearch automatically retries the update up to 3 times if version conflicts occur. Each retry fetches the latest document and attempts the merge again.

**How retry_on_conflict works:**

1. Attempt 1: Version conflict detected
2. Fetch latest document version
3. Attempt 2: Merge changes again → Success or retry again
4. Maximum 3 attempts before returning error

[Inference] `retry_on_conflict` is effective when conflicts are infrequent or involve non-overlapping field changes. High-conflict scenarios may benefit from application-level retry logic with exponential backoff.

### Optimistic Concurrency with Index Operations

The Index API also supports conditional execution:

**Conditional index:**

```json
PUT /users/_doc/user_123?if_seq_no=4&if_primary_term=1
{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 32
}
```

The document is indexed only if its sequence number is 4 and primary term is 1. If it's been modified, the operation fails with a 409 conflict.

### Optimistic Concurrency with Delete Operations

Delete operations support version conditions:

**Conditional deletion:**

```json
DELETE /users/_doc/user_123?if_seq_no=5&if_primary_term=1
```

The document is deleted only if the specified version matches. This prevents accidental deletion of documents modified by other processes.

### Bulk Operations with Optimistic Concurrency

Bulk API supports per-operation version conditions:

**Request:**

```json
POST /users/_bulk
{"update":{"_id":"1","if_seq_no":4,"if_primary_term":1}}
{"doc":{"age":32}}
{"update":{"_id":"2","if_seq_no":2,"if_primary_term":1}}
{"doc":{"age":25}}
{"delete":{"_id":"3","if_seq_no":6,"if_primary_term":1}}
```

**Response with conflict:**

```json
{
  "took": 38,
  "errors": true,
  "items": [
    {
      "update": {
        "_id": "1",
        "result": "updated"
      }
    },
    {
      "update": {
        "_id": "2",
        "error": {
          "type": "version_conflict_engine_exception",
          "reason": "version conflict"
        },
        "status": 409
      }
    },
    {
      "delete": {
        "_id": "3",
        "result": "deleted"
      }
    }
  ]
}
```

Operation 2 fails due to version conflict while others succeed.

### Real-World Use Cases

**Concurrent user profile updates:**

```json
GET /users/_doc/user_456

Response: _seq_no: 12, _primary_term: 1

Client 1: Update email
POST /users/_update/user_456?if_seq_no=12&if_primary_term=1
{
  "doc": {
    "email": "newemail@example.com"
  }
}

Client 2: Update phone (concurrent)
POST /users/_update/user_456?if_seq_no=12&if_primary_term=1
{
  "doc": {
    "phone": "+1-555-9999"
  }
}

Result: One succeeds, one gets 409 conflict
```

Both clients read the same version. The first update succeeds, incrementing sequence number to 13. The second update fails because it references the old sequence number 12.

**Inventory management with optimistic locking:**

```json
GET /inventory/_doc/sku_xyz

Response: _seq_no: 45, _primary_term: 1, stock: 100

Sale transaction:
POST /inventory/_update/sku_xyz?if_seq_no=45&if_primary_term=1
{
  "script": {
    "source": "ctx._source.stock -= params.quantity",
    "params": {
      "quantity": 5
    }
  }
}

If successful: stock becomes 95, seq_no becomes 46
If conflict: Another sale modified inventory; retry with new seq_no
```

Prevents overselling by detecting concurrent inventory modifications.

**Document editing with conflict detection:**

```json
GET /articles/_doc/article_789

Response: _seq_no: 8, _primary_term: 1

Editor A saves changes:
POST /articles/_update/article_789?if_seq_no=8&if_primary_term=1
{
  "doc": {
    "content": "Updated article content",
    "last_edited_by": "editor_a"
  }
}

Result: Success, seq_no becomes 9

Editor B attempts save (unaware of A's change):
POST /articles/_update/article_789?if_seq_no=8&if_primary_term=1
{
  "doc": {
    "content": "Different content",
    "last_edited_by": "editor_b"
  }
}

Result: 409 Conflict (must fetch latest and re-apply changes)
```

Conflict signals that another editor made changes while this editor was working.

**Banking transaction with amount validation:**

```json
GET /accounts/_doc/account_123

Response: _seq_no: 1000, _primary_term: 1, balance: 5000

Withdrawal attempt:
POST /accounts/_update/account_123?if_seq_no=1000&if_primary_term=1
{
  "script": {
    "source": "if (ctx._source.balance >= params.amount) { ctx._source.balance -= params.amount } else { ctx.op = 'noop' }",
    "params": {
      "amount": 2000
    }
  }
}

Concurrent deposits/withdrawals modify the account, causing conflicts
Application retries with updated balance information
```

Ensures consistent account balance even with concurrent transactions.

### Handling 409 Conflicts in Applications

**Retry strategy with exponential backoff:**

```
Attempt 1: Immediate retry
Attempt 2: Wait 10ms, retry
Attempt 3: Wait 100ms, retry
Attempt 4: Wait 1000ms, retry
Abort: Return error to user
```

[Inference] Exponential backoff prevents overwhelming the system with rapid retries and allows other operations to complete, reducing conflict likelihood.

**User-facing conflict resolution:**

When conflicts occur repeatedly, notify the user:

```
"Your changes conflicted with another user's modifications. 
Please review the current content and reapply your changes."
```

Display the latest document version and allow user to reconcile changes.

### Optimistic vs. Pessimistic Concurrency

| Aspect | Optimistic | Pessimistic |
|--------|-----------|-------------|
| **Locking** | None (version-based) | Explicit locks |
| **Conflicts** | Detected on write | Prevented during read |
| **Throughput** | High (no wait) | Low (lock waits) |
| **Complexity** | Application retry logic | Lock management |
| **Scalability** | Excellent (distributed) | Poor (lock contention) |
| **Use case** | High-concurrency reads | Low-concurrency critical writes |

### Sequence Number Gaps

Sequence numbers may have gaps in distributed systems. [Inference] Don't assume continuous numbering; use exact matches, not range checks.

**Example gap:**

```
Operation 1: seq_no = 100
Operation 2: seq_no = 101
Operation 3 (fails): seq_no would be 102
Operation 4: seq_no = 102

Gap exists because operation 3 failed
```

### Primary Term Changes

Primary term changes when the primary shard fails over to a replica:

**Before failover:**

```json
_seq_no: 50,
_primary_term: 1
```

**After failover:**

```json
_seq_no: 51,
_primary_term: 2
```

Sequence numbering restarts in the new primary term. [Inference] Both `_seq_no` and `_primary_term` must match for conditional operations after failover.

### Limitations and Considerations

**No absolute guarantee of single-writer:**

[Unverified] Optimistic concurrency ensures version consistency but doesn't guarantee only one writer succeeds. In rare race conditions, multiple writers may pass checks simultaneously before conflicts are detected.

**Conflict overhead:**

High-conflict scenarios incur overhead from repeated fetches and retries. [Inference] If conflicts are frequent, reconsider the data model or partition strategy.

**Application complexity:**

Implementing retry logic and conflict handling in applications adds complexity. [Inference] Use `retry_on_conflict` for simple scenarios; implement custom retry logic for advanced requirements.

**Nested and array field conflicts:**

Optimistic concurrency works at document level, not field level. Two clients modifying different nested fields still trigger conflicts. [Inference] Consider document partitioning if field-level conflicts are common.

### Optimistic Concurrency with Scripts

Scripts can check conditions before modifying documents:

**Script with conflict prevention:**

```json
POST /orders/_update/order_123?if_seq_no=5&if_primary_term=1
{
  "script": {
    "source": "if (ctx._source.status != 'pending') { ctx.op = 'noop' } else { ctx._source.status = 'processing' }"
  }
}
```

The conditional version check ensures the document hasn't changed. Additionally, the script verifies status is still "pending" before transitioning to "processing".

### Monitoring Conflicts

Track version conflicts to identify problematic areas:

**Common conflict patterns:**

- High conflict rate on frequently-updated documents
- Conflicts concentrated during peak load times
- Specific document IDs experiencing persistent conflicts

[Inference] High conflict rates suggest need for data model changes, partitioning strategies, or write serialization.

### Best Practices

**Fetch before write:**

Always retrieve document version before modifying:

```json
GET /document/_doc/id
→ Note _seq_no and _primary_term
→ Modify locally
→ POST with if_seq_no and if_primary_term
```

**Use retry_on_conflict for simple updates:**

```json
POST /_update/id?retry_on_conflict=3
```

Effective for non-overlapping field modifications.

**Implement custom retry for critical operations:**

For high-value transactions, implement application-level retry with exponential backoff and logging.

**Monitor and alert on conflicts:**

Track conflict rates to detect data contention issues requiring architectural changes.

**Document conflict handling expectations:**

Clearly define how conflicts are handled — whether clients retry, merge, or escalate to user intervention.

**Key Points:**
- Optimistic concurrency detects conflicts using version numbers (`_seq_no` and `_primary_term`) rather than preventing them with locks
- `_seq_no` (sequence number) and `_primary_term` together provide reliable version identification superior to the deprecated `_version` field
- Conditional parameters (`if_seq_no` and `if_primary_term`) enable version-checked updates that fail with 409 status if versions don't match
- `retry_on_conflict` automatically retries operations up to a specified number of times when version conflicts occur
- The standard workflow involves reading document metadata, modifying locally, and writing conditionally with version checks
- Conflicts signal that another process modified the document; applications must fetch the latest version and retry
- Optimistic concurrency is ideal for high-concurrency, distributed systems where pessimistic locking would create bottlenecks
- Bulk API supports per-operation version conditions for batch updates with conflict detection
- Sequence numbers may have gaps and aren't continuous; use exact matches for conditional checks
- Primary term changes reflect shard failovers and must be rechecked after cluster topology changes
- High conflict rates indicate data contention requiring partitioning, document restructuring, or serialized writes