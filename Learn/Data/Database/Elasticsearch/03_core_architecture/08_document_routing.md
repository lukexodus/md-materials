Document routing
## Document Routing

### What Document Routing Is

Document routing is the mechanism by which Elasticsearch determines which primary shard a document belongs to. When a document is indexed, retrieved, updated, or deleted, Elasticsearch must identify the specific shard responsible for that document. Routing makes this determination deterministic and consistent across all operations.

Without a consistent routing mechanism, Elasticsearch would have no way to locate a document without scanning all shards — an approach that would not scale. Routing ensures that every operation targeting a specific document goes directly to the correct shard.

**Key Points:**
- Routing applies to all document-level operations: index, get, update, delete
- The routing value determines shard placement at index time and lookup at read time
- Default routing uses the document `_id` field
- Custom routing allows application-defined placement strategies
- Routing is computed before the operation reaches any shard

### The Default Routing Formula

By default, Elasticsearch uses the following formula to determine the target shard for a document:

```
shard_num = hash(_routing) % num_primary_shards
```

Where:
- `_routing` defaults to the document's `_id`
- `hash()` is MurmurHash3, producing a non-negative integer
- `num_primary_shards` is the number of primary shards defined at index creation

**Example:**

```
Document _id: "user-4821"
MurmurHash3("user-4821") = 2947103851
num_primary_shards = 5

shard_num = 2947103851 % 5 = 1

→ Document is routed to primary shard 1
```

The same formula is applied for every subsequent operation targeting `"user-4821"`, guaranteeing that reads and writes always reach the same shard.

**Why Primary Shard Count Is Fixed:**

The modulo operation against `num_primary_shards` is why the primary shard count of an index cannot be changed after creation. Changing it would alter the routing formula output for existing documents, making them unreachable without a full reindex.

### Routing at Write Time

When a document is indexed, the coordinating node — the node that receives the client request — computes the routing formula and forwards the request to the node holding the appropriate primary shard. The primary shard processes the write and then replicates to replica shards.

**Write Path:**

```
Client Request (index document)
        ↓
Coordinating Node
└── Computes: shard_num = hash(_id) % num_primary_shards
        ↓
Routes to Node hosting Primary Shard N
        ↓
Primary Shard writes document
        ↓
Replicates to Replica Shards of Shard N
        ↓
Acknowledgment returned to client
```

### Routing at Read Time

For single-document GET requests, the coordinating node computes the routing formula and routes directly to the correct shard. For search queries, routing may target all shards or a subset depending on configuration.

**GET Request Path:**

```
Client GET Request (document _id: "user-4821")
        ↓
Coordinating Node
└── Computes: shard_num = hash("user-4821") % num_primary_shards = 1
        ↓
Routes directly to Shard 1 (primary or replica)
        ↓
Document returned to client
```

**Search Request Path (default):**

```
Client Search Request
        ↓
Coordinating Node
└── Broadcasts to all primary or replica shards
        ↓
Each shard executes query locally
        ↓
Coordinating Node collects and merges results
        ↓
Final result set returned to client
```

### Custom Routing

Elasticsearch allows applications to specify a custom routing value at index time, overriding the default `_id`-based routing. This enables deliberate control over shard placement.

**Specifying a Custom Routing Value:**

```json
PUT /my-index/_doc/user-4821?routing=tenant-A
{
  "user_id": "4821",
  "tenant": "tenant-A",
  "message": "Login successful"
}
```

The routing formula becomes:

```
shard_num = hash("tenant-A") % num_primary_shards
```

All documents with `routing=tenant-A` land on the same shard, regardless of their `_id`.

**Retrieving with Custom Routing:**

The same routing value must be supplied for GET and delete operations:

```json
GET /my-index/_doc/user-4821?routing=tenant-A
```

Omitting the routing value on a GET request causes Elasticsearch to compute routing from `_id`, potentially targeting the wrong shard and returning a "not found" response even if the document exists.

**Searching with Custom Routing:**

```json
GET /my-index/_search?routing=tenant-A
{
  "query": {
    "term": { "tenant": "tenant-A" }
  }
}
```

This restricts the search to only the shard(s) where `tenant-A` documents reside, avoiding a broadcast to all shards.

### Routing and Multi-Tenant Architectures

Custom routing is particularly valuable in multi-tenant systems where documents belonging to a single tenant should be co-located on the same shard. This pattern enables tenant-scoped queries to target a single shard rather than all shards.

**Benefits:**
- Reduced query fanout — searches for a tenant hit one shard only
- Lower coordination overhead on the coordinating node
- Improved query latency for tenant-scoped searches
- Natural isolation of tenant data within the index

**Trade-offs:**
- All tenants must consistently supply routing values on every operation
- Uneven tenant sizes can cause shard imbalance (hot shards)
- Missing routing values on reads silently target the wrong shard

**[Inference]** In systems with highly variable tenant sizes — where one tenant has orders of magnitude more documents than others — custom routing by tenant may produce significant shard imbalance. Strategies such as per-tenant indices or routing to shard groups may be more appropriate in such cases.

### Required Routing

To prevent accidental omission of custom routing values, Elasticsearch supports marking routing as required in the index mapping. When required, any indexing or retrieval operation that omits the routing parameter is rejected with an error.

**Configuring Required Routing:**

```json
PUT /my-index
{
  "mappings": {
    "_routing": {
      "required": true
    }
  }
}
```

**Behavior with Required Routing:**

```json
PUT /my-index/_doc/user-4821
{
  "tenant": "tenant-A",
  "message": "Login successful"
}
```

**Output:**

```json
{
  "error": {
    "root_cause": [
      {
        "type": "routing_missing_exception",
        "reason": "routing is required for [my-index]/[user-4821]"
      }
    ]
  },
  "status": 400
}
```

Required routing is a safeguard that enforces routing discipline at the API level, preventing documents from being silently misrouted.

### Routing to Multiple Shards

Elasticsearch supports routing a single routing value to more than one shard through the `index.routing_partition_size` setting. This distributes documents with the same routing value across a configurable number of shards rather than a single one, reducing the risk of hot shards caused by uneven routing value distributions.

**Configuration:**

```json
PUT /my-index
{
  "settings": {
    "index.number_of_shards": 10,
    "index.routing_partition_size": 3
  },
  "mappings": {
    "_routing": {
      "required": true
    }
  }
}
```

**Modified Formula:**

```
shard_num = (hash(_routing) + hash(_id) % routing_partition_size) % num_primary_shards
```

With `routing_partition_size=3`, documents sharing the same routing value are distributed across 3 of the 10 shards. Searches with a routing value target only those 3 shards rather than all 10.

**[Inference]** Using `routing_partition_size` reduces hot shard risk compared to single-shard routing but increases query fanout compared to strict single-shard routing. The appropriate value depends on the balance between data distribution and query targeting requirements.

**Constraints:**
- `routing_partition_size` must be less than `number_of_shards`
- Requires `_routing.required: true` in mappings
- Cannot be changed after index creation
- Join fields (`join` datatype) cannot be used with partitioned routing

### Routing in Index Aliases

Routing values can be embedded directly into index aliases, automatically applying them to all operations through the alias without requiring the client to specify them explicitly.

**Creating an Alias with Routing:**

```json
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index": "my-index",
        "alias": "tenant-a-alias",
        "routing": "tenant-A",
        "filter": {
          "term": { "tenant": "tenant-A" }
        }
      }
    }
  ]
}
```

All operations through `tenant-a-alias` automatically apply the `tenant-A` routing value and the tenant filter, without requiring application code to manage routing explicitly.

**Separate Search and Index Routing:**

```json
{
  "add": {
    "index": "my-index",
    "alias": "tenant-a-alias",
    "index_routing": "tenant-A",
    "search_routing": "tenant-A"
  }
}
```

`index_routing` and `search_routing` can be set independently, allowing different routing strategies for writes and reads if required.

### Routing and Reindex Operations

When reindexing documents from one index to another, routing values must be carefully considered. If the source index used custom routing, the destination index must preserve those values to maintain correct shard placement.

**Reindex with Routing Preservation:**

```json
POST /_reindex
{
  "source": {
    "index": "source-index"
  },
  "dest": {
    "index": "dest-index",
    "routing": "keep"
  }
}
```

The `routing: keep` option preserves the original routing value from each source document. The default behavior discards routing values and recomputes from `_id`.

**Routing Options in Reindex:**

| Value | Behavior |
|---|---|
| `keep` | Preserves source document routing value |
| `discard` | Removes routing; uses `_id`-based default |
| A literal string | Sets all documents to the specified routing value |

### Shard Imbalance and Hot Shards

Poorly chosen routing values can cause uneven document distribution across shards, resulting in hot shards that receive disproportionate indexing and query load.

**Causes of Imbalance:**
- Low-cardinality routing values (e.g., routing by boolean field with two values)
- Highly skewed data distributions (one tenant with far more data than others)
- Routing values with hash collisions concentrating multiple values on the same shard

**Detection:**

```json
GET /_cat/shards/my-index?v&h=shard,prirep,docs,store,node
```

**Output:**

```
shard  prirep  docs    store   node
0      p       12450   45mb    node-1
1      p       89320   312mb   node-2   ← potential hot shard
2      p       11200   41mb    node-3
3      p       10890   39mb    node-1
4      p       13100   47mb    node-2
```

Significant disparity in `docs` and `store` across shards with the same `prirep=p` (primary) indicates routing imbalance.

**[Inference]** A shard with a significantly higher document count than peers may experience higher query latency and indexing pressure. Remediation typically requires reindexing with a revised routing strategy, as shard counts and routing formulas cannot be changed on existing indices.

### Routing Considerations for ILM and Data Streams

In indices managed by ILM or backed by data streams, routing behavior interacts with rollover mechanics. Each backing index created during rollover inherits routing configuration from the index template.

**Key Considerations:**
- Custom routing must be consistently applied across all backing indices of a data stream
- Required routing enforced in the template applies to all generated backing indices
- Rollover creates a new backing index; routing values from the old index do not automatically transfer context
- Searchable snapshot indices in cold and frozen phases remain routable using original routing values

### Practical Recommendations

**Default Routing:**
- Appropriate for most use cases without specific co-location requirements
- Produces statistically uniform distribution across shards for high-cardinality `_id` values
- No additional application complexity

**Custom Routing:**
- Use when tenant or entity co-location provides meaningful query optimization
- Always enforce `_routing.required: true` to prevent silent misrouting
- Monitor shard balance regularly when using custom routing
- Consider `routing_partition_size` for distributions with moderate cardinality

**Alias-Based Routing:**
- Preferred approach for hiding routing complexity from application code
- Combines routing with filters for clean tenant isolation
- Reduces risk of inconsistent routing value usage across application components

**Conclusion:**

Document routing is a foundational mechanism controlling how Elasticsearch distributes and locates documents across shards. The default formula provides statistically balanced distribution with no application involvement. Custom routing enables deliberate co-location strategies that can significantly reduce query fanout in multi-tenant or entity-scoped workloads, at the cost of increased operational discipline and shard balance monitoring. Understanding how routing interacts with shard count immutability, alias configuration, and reindex operations is essential for designing indices that perform correctly and scale predictably.