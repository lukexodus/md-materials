## Core Concepts Overview

---

### What This Section Covers

Elasticsearch has a distinct vocabulary and set of abstractions that underpin everything from basic indexing to distributed cluster behavior. This overview establishes the foundational concepts that all subsequent topics build upon.

---

### Documents

A **document** is the basic unit of data in Elasticsearch. It is a JSON object stored within an index.

- Every document belongs to exactly one index
- Every document has a unique **`_id`** — either assigned by Elasticsearch or provided explicitly
- Documents are **schema-flexible** by default but can be constrained via mappings

**Example** — a product document:

```json
{
  "_index": "products",
  "_id": "42",
  "_source": {
    "name": "Wireless Keyboard",
    "brand": "Logitech",
    "price": 49.99,
    "in_stock": true,
    "tags": ["electronics", "peripherals"]
  }
}
```

The `_source` field contains the original JSON as it was indexed.

---

### Indices

An **index** is a logical namespace that holds a collection of documents. It is roughly analogous to a table in a relational database, though the analogy has important limits.

- Index names must be lowercase
- A single Elasticsearch cluster can hold many indices
- Each index has its own **mappings** (schema) and **settings** (configuration)

**Example** — common index naming conventions:

```
logs-2025-06-01
products-v2
orders_index
```

[Inference] Naming conventions often include dates or version suffixes in production environments to support index lifecycle management. This is a common pattern, not a requirement enforced by Elasticsearch.

---

### Mappings

A **mapping** defines the schema of an index — the fields a document may contain and the data type of each field.

#### Explicit vs Dynamic Mapping

| Type | Description |
|---|---|
| **Explicit** | Defined by the user before or during indexing |
| **Dynamic** | Elasticsearch infers types from the first document that contains a field |

Dynamic mapping is convenient for development but can cause **mapping conflicts** and **mapping explosions** in production if not controlled.

#### Common Field Data Types

| Type | Description | Example Value |
|---|---|---|
| `text` | Analyzed for full-text search | `"elastic search guide"` |
| `keyword` | Exact match, not analyzed | `"completed"` |
| `integer` / `long` | Whole numbers | `42` |
| `float` / `double` | Decimal numbers | `3.14` |
| `boolean` | True/false | `true` |
| `date` | Date/time values | `"2025-06-01T00:00:00Z"` |
| `object` | Nested JSON object | `{ "city": "Berlin" }` |
| `nested` | Array of objects with independent indexing | `[{ "tag": "a" }]` |
| `geo_point` | Latitude/longitude pair | `{ "lat": 51.5, "lon": -0.1 }` |

**Example** — explicit mapping definition:

```json
PUT /products
{
  "mappings": {
    "properties": {
      "name":     { "type": "text" },
      "brand":    { "type": "keyword" },
      "price":    { "type": "float" },
      "in_stock": { "type": "boolean" },
      "created":  { "type": "date" }
    }
  }
}
```

> **Important:** Mappings for existing fields **cannot be changed** after documents are indexed without reindexing. Adding new fields is allowed.

---

### Analyzers

An **analyzer** controls how text fields are processed at index time and query time. It transforms raw text into **tokens** (terms) stored in the inverted index.

An analyzer consists of three components:

```
Raw Text → [Character Filters] → [Tokenizer] → [Token Filters] → Tokens
```

| Component | Role | Example |
|---|---|---|
| Character filter | Pre-processes raw text | Strip HTML tags |
| Tokenizer | Splits text into tokens | Split on whitespace |
| Token filter | Transforms tokens | Lowercase, stemming, stopwords |

**Example** — the `standard` analyzer applied to `"The Quick Brown Fox"`:

```
Tokens: ["the", "quick", "brown", "fox"]
```

Elasticsearch ships with built-in analyzers (`standard`, `english`, `whitespace`, `simple`, etc.) and supports custom analyzer definitions.

---

### Inverted Index

The **inverted index** is the core data structure that makes full-text search fast. It is built and maintained by Apache Lucene, which Elasticsearch is built upon.

Rather than scanning documents for a term, the inverted index maps each **term** to the list of documents containing it.

**Example:**

| Term | Documents |
|---|---|
| `quick` | doc_1, doc_3 |
| `brown` | doc_1 |
| `fox` | doc_1, doc_2 |
| `lazy` | doc_2, doc_3 |

A query for `"quick fox"` retrieves the union or intersection of those lists, depending on query type — without scanning all documents.

---

### Shards

An index is divided into one or more **shards**. Each shard is a self-contained **Lucene index** and the fundamental unit of data distribution in a cluster.

#### Primary Shards

- Hold the actual data
- Number of primary shards is **fixed at index creation** and cannot be changed without reindexing
- Default: 1 primary shard (as of Elasticsearch 7.0+; earlier versions defaulted to 5)

#### Replica Shards

- Copies of primary shards
- Serve **read requests**, providing parallelism and redundancy
- Number of replicas **can be changed** at any time
- A replica is never placed on the same node as its primary

**Example** — index with 2 primary shards and 1 replica each:

```json
PUT /products
{
  "settings": {
    "number_of_shards": 2,
    "number_of_replicas": 1
  }
}
```

This results in **4 total shards** (2 primary + 2 replica) distributed across the cluster.

---

### Nodes

A **node** is a single running instance of Elasticsearch. Each node:

- Belongs to exactly one **cluster**
- Stores a subset of the cluster's shards
- Participates in indexing and search operations

#### Node Roles

| Role | Responsibility |
|---|---|
| **Master** | Manages cluster state, index creation/deletion, shard allocation |
| **Data** | Stores shards, executes indexing and search |
| **Ingest** | Pre-processes documents via pipelines before indexing |
| **Coordinating** | Routes requests, merges results — every node acts as this by default |
| **ML** | Runs machine learning jobs (requires appropriate license) |

Nodes can hold multiple roles simultaneously. In production, dedicated master and data nodes are common for stability.

---

### Clusters

A **cluster** is a collection of one or more nodes that together hold all indexed data and provide search capability across it.

- Every cluster has a unique **cluster name** (default: `elasticsearch`)
- Nodes discover each other and form a cluster automatically (via discovery mechanisms)
- The cluster maintains a **cluster state** — a shared record of index mappings, settings, and shard allocation

#### Cluster Health

Cluster health is reported as one of three states:

| Status | Meaning |
|---|---|
| 🟢 `green` | All primary and replica shards are assigned |
| 🟡 `yellow` | All primaries assigned; at least one replica is unassigned |
| 🔴 `red` | At least one primary shard is unassigned — some data unavailable |

```http
GET /_cluster/health
```

---

### The Indexing Process

When a document is indexed, Elasticsearch performs the following steps:

1. The document is received by a **coordinating node**
2. The coordinating node determines which **primary shard** owns the document (via routing formula)
3. The document is forwarded to that primary shard's node
4. The primary shard writes the document and forwards it to all **replica shards**
5. Once replicas acknowledge, the coordinating node responds to the client

[Inference] The exact acknowledgment behavior depends on `wait_for_active_shards` settings. Default behavior may not wait for all replicas. Behavior is not guaranteed to be identical across all configurations or versions.

---

### The Search Process

Search in Elasticsearch is a **two-phase** process:

#### Phase 1 — Query Phase

1. Client sends a search request to a coordinating node
2. The coordinating node broadcasts the query to **one shard copy** (primary or replica) from each relevant shard group
3. Each shard executes the query locally and returns a list of matching document IDs and scores

#### Phase 2 — Fetch Phase

4. The coordinating node collects and **merges** results, ranking by score
5. It fetches the full `_source` of the top N documents from the relevant shards
6. The final ranked result set is returned to the client

This architecture is why Elasticsearch can search across billions of documents quickly — each shard processes only its own data in parallel.

---

### Near-Real-Time (NRT) Search

Elasticsearch is described as a **near-real-time** search engine. Indexed documents are not immediately visible to search.

- Documents are written to an **in-memory buffer**
- A **refresh** operation moves buffered documents into a new Lucene segment, making them searchable
- Default refresh interval: **1 second**
- The `refresh_interval` setting can be adjusted per index

```json
PUT /products/_settings
{
  "refresh_interval": "5s"
}
```

> Setting `refresh_interval` to `-1` disables automatic refresh — useful during bulk indexing to improve throughput.

---

### Relevance Scoring

When a query is executed against `text` fields, Elasticsearch scores each matching document by **relevance** rather than returning results in insertion order.

The default scoring algorithm is **BM25** (Best Match 25), which considers:

- **Term frequency (TF):** How often the term appears in the document
- **Inverse document frequency (IDF):** How rare the term is across all documents
- **Field length normalization:** Shorter fields with the term score higher than longer fields

Scores are accessible via the `_score` field in search results. Higher scores indicate greater relevance.

[Inference] BM25 replaced TF/IDF as the default in Elasticsearch 5.0. Score values themselves are relative within a result set and are not directly comparable across different queries or index configurations. Behavior may vary.

---

### The `_source`, `_id`, and Metadata Fields

Every document in Elasticsearch carries system **metadata fields** alongside its content:

| Field | Description |
|---|---|
| `_index` | The index the document belongs to |
| `_id` | The document's unique identifier |
| `_source` | The original JSON document as indexed |
| `_score` | Relevance score (present in search results) |
| `_seq_no` | Sequence number used for optimistic concurrency |
| `_primary_term` | Primary term used for concurrency control |

---

### Index Aliases

An **alias** is a secondary name that points to one or more indices. Aliases are used to:

- Abstract index names from application code (useful during reindexing)
- Point to multiple indices simultaneously for unified search
- Apply optional filter queries to scope an alias

**Example:**

```json
POST /_aliases
{
  "actions": [
    { "add": { "index": "products-v2", "alias": "products" } }
  ]
}
```

The application queries `products`; the underlying index can be swapped without changing client code.

---

### Index Templates

An **index template** defines settings and mappings that are automatically applied when a new index is created whose name matches a specified pattern.

```json
PUT /_index_template/logs_template
{
  "index_patterns": ["logs-*"],
  "template": {
    "settings": { "number_of_shards": 1 },
    "mappings": {
      "properties": {
        "timestamp": { "type": "date" },
        "level":     { "type": "keyword" },
        "message":   { "type": "text" }
      }
    }
  }
}
```

Any index created with a name matching `logs-*` inherits this template automatically.

---

### Data Streams

A **data stream** is a higher-level abstraction built on top of indices, designed for **append-only, time-series data** such as logs and metrics.

- Backed by one or more hidden indices called **backing indices**
- Write operations always target the **active write index**
- Index Lifecycle Management (ILM) automates rollover, shrink, and deletion
- Simplifies the management of time-series data at scale

---

**Conclusion**

These core concepts — documents, indices, mappings, analyzers, shards, nodes, and clusters — form the architectural vocabulary of Elasticsearch. Each subsequent topic in this curriculum builds directly on these abstractions. A clear understanding of how data flows from indexing through search, and how the cluster distributes that work, is essential before working with advanced query, aggregation, or operational features.