## Indices, Documents, and Fields

---

### What Is an Index?

In Elasticsearch, an **index** is the top-level container for storing and organizing data. It is roughly analogous to a *database* in relational systems, though the comparison has important limits.

An index holds a collection of **documents** that share a similar structure or purpose. For example, you might have a `products` index, an `orders` index, and a `users` index — each storing a different category of data.

**Key Points:**
- An index has a unique name (lowercase, no spaces)
- Index names are used in API calls to read, write, and search data
- A single Elasticsearch cluster can hold many indices
- Each index has its own settings (shards, replicas) and mappings (field definitions)

**Example:** Creating an index named `products`

```http
PUT /products
```

---

### What Is a Document?

A **document** is the basic unit of data in Elasticsearch. It is a single record stored within an index, represented as a **JSON object**.

Each document:
- Belongs to exactly one index
- Has a unique **`_id`** (assigned manually or auto-generated)
- Contains one or more **fields** as key-value pairs

**Example:** Indexing a document into the `products` index

```http
PUT /products/_doc/1
{
  "name": "Wireless Mouse",
  "brand": "Logitech",
  "price": 29.99,
  "in_stock": true,
  "tags": ["electronics", "accessories"]
}
```

**Output:** Elasticsearch returns metadata confirming storage:

```json
{
  "_index": "products",
  "_id": "1",
  "_version": 1,
  "result": "created"
}
```

**Key Points:**
- Documents are schema-flexible by default — different documents in the same index *can* have different fields
- However, for consistent querying and performance, documents within an index typically share a common structure
- The `_doc` in the URL is the endpoint path for document operations (not a type designation in modern versions)

---

### Document Metadata Fields

Every document in Elasticsearch carries system-managed **metadata fields** prefixed with an underscore (`_`).

| Metadata Field | Description |
|---|---|
| `_index` | The index the document belongs to |
| `_id` | The unique identifier of the document |
| `_version` | Increments on every update to the document |
| `_source` | The original JSON body of the document |
| `_seq_no` | Sequence number used for concurrency control |
| `_primary_term` | Used alongside `_seq_no` for optimistic concurrency |

**Key Points:**
- `_source` stores the original document and is returned by default in search results
- `_source` can be disabled to save disk space, but this removes the ability to retrieve original document content directly — [Inference] this trade-off is generally only appropriate in specialized use cases such as very high-volume logging

---

### What Are Fields?

**Fields** are the individual key-value pairs inside a document. Each field holds a specific piece of data and is associated with a **data type** that Elasticsearch uses to determine how the field is stored, indexed, and searched.

#### Core Field Data Types

**Text and Keyword**

| Type | Use Case |
|---|---|
| `text` | Full-text search (analyzed, tokenized) |
| `keyword` | Exact matching, aggregations, sorting |

- `text` fields are passed through an **analyzer** that breaks the content into tokens (e.g., lowercasing, splitting on whitespace)
- `keyword` fields are stored as-is and used for exact value matching

**Example:** A `description` field benefits from `text` type; a `status` field (e.g., `"active"`, `"inactive"`) benefits from `keyword` type.

---

**Numeric Types**

| Type | Description |
|---|---|
| `integer` | 32-bit signed integer |
| `long` | 64-bit signed integer |
| `float` | 32-bit floating point |
| `double` | 64-bit floating point |
| `short` | 16-bit signed integer |
| `byte` | 8-bit signed integer |
| `scaled_float` | Float stored as a scaled long (e.g., for prices) |

**Key Points:**
- Choose the smallest type that fits your data — [Inference] this may reduce storage and improve performance, though actual gains vary by use case and cluster configuration
- `scaled_float` is commonly used for monetary values (e.g., `scaling_factor: 100` stores `29.99` as `2999`)

---

**Date and Date Nanoseconds**

| Type | Description |
|---|---|
| `date` | Stored as milliseconds since epoch internally |
| `date_nanos` | Nanosecond precision; range is limited compared to `date` |

Dates can be provided as:
- ISO 8601 strings: `"2024-06-01T12:00:00Z"`
- Epoch milliseconds: `1717243200000`
- Custom formats defined in the mapping

---

**Boolean**

Stores `true` or `false` values. Strings `"true"` and `"false"` are also accepted.

---

**Object and Nested**

Elasticsearch supports structured data within documents.

| Type | Description |
|---|---|
| `object` | A JSON object stored as flattened key paths internally |
| `nested` | A JSON array of objects where each object is independently indexed |

**Key Points:**
- `object` type fields are flattened internally, which means relationships between fields inside an array of objects are **not** preserved during querying
- `nested` type preserves those relationships but comes with higher indexing and query cost — [Inference] use `nested` only when querying inner object relationships is required

**Example:** The difference matters when querying arrays of objects:

```json
"reviews": [
  { "user": "Alice", "rating": 5 },
  { "user": "Bob", "rating": 2 }
]
```

With `object` type, a query for `user: Alice AND rating: 2` could incorrectly match this document. With `nested` type, each inner object is treated independently, so that query would not match.

---

**Other Notable Field Types**

| Type | Description |
|---|---|
| `ip` | IPv4 and IPv6 addresses |
| `geo_point` | Latitude/longitude for geographic queries |
| `geo_shape` | Complex geographic shapes (polygons, lines) |
| `binary` | Base64-encoded binary data, not searchable by default |
| `flattened` | Entire JSON object indexed as keyword values |
| `rank_features` | Used in relevance scoring scenarios |
| `dense_vector` | Fixed-length float vectors for vector/semantic search |
| `sparse_vector` | Sparse float vectors for sparse retrieval models |

---

### Mappings: Defining Fields for an Index

A **mapping** defines the fields in an index and their data types. It functions similarly to a schema in relational databases.

#### Dynamic Mapping

By default, Elasticsearch uses **dynamic mapping** — when a new document is indexed and contains a field not yet in the mapping, Elasticsearch infers and adds it automatically.

| JSON Value Type | Inferred Elasticsearch Type |
|---|---|
| String (parseable as date) | `date` |
| String (other) | `text` + `keyword` sub-field |
| Integer | `long` |
| Floating point | `float` |
| Boolean | `boolean` |
| Object | `object` |

**Key Points:**
- Dynamic mapping is convenient for development and exploration
- [Inference] In production environments, explicit mappings are generally preferred to avoid unexpected type inference, unintended field proliferation, or mapping conflicts — behavior may vary based on data and Elasticsearch version

#### Explicit Mapping

You define field types manually when creating an index.

**Example:**

```http
PUT /products
{
  "mappings": {
    "properties": {
      "name": { "type": "text" },
      "brand": { "type": "keyword" },
      "price": { "type": "scaled_float", "scaling_factor": 100 },
      "in_stock": { "type": "boolean" },
      "created_at": { "type": "date" },
      "tags": { "type": "keyword" }
    }
  }
}
```

#### Multi-Fields

A single field can be mapped under multiple types using `fields`. This is especially common for combining `text` (for full-text search) and `keyword` (for sorting/aggregation) on the same value.

**Example:**

```http
"name": {
  "type": "text",
  "fields": {
    "keyword": {
      "type": "keyword",
      "ignore_above": 256
    }
  }
}
```

- `name` → searched as full text
- `name.keyword` → used for exact match, sorting, or aggregations

---

### Mapping Constraints and Limitations

**Key Points:**
- Once a field's type is set in a mapping, it **cannot be changed** without reindexing the data into a new index
- New fields can be added to an existing mapping (unless dynamic mapping is disabled)
- The `ignore_above` parameter on `keyword` fields skips indexing strings longer than the specified character count — the value is still stored in `_source`
- `index: false` can be set on a field to store it in `_source` without making it searchable — [Inference] useful for fields needed only for retrieval, not querying

---

### Index Settings vs. Mappings

These are two distinct configuration areas within an index:

| Area | Controls |
|---|---|
| **Settings** | Number of shards, replicas, analyzer definitions, refresh intervals |
| **Mappings** | Field names, data types, indexing behavior |

Both can be defined at index creation time:

```http
PUT /products
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  },
  "mappings": {
    "properties": {
      "name": { "type": "text" },
      "price": { "type": "float" }
    }
  }
}
```

---

### Retrieving Index Information

**Get mapping:**
```http
GET /products/_mapping
```

**Get settings:**
```http
GET /products/_settings
```

**Get a document by ID:**
```http
GET /products/_doc/1
```

**Get index info (mapping + settings combined):**
```http
GET /products
```

---

### Summary Table

| Concept | Description |
|---|---|
| Index | Container for documents; analogous to a database table |
| Document | A single JSON record within an index |
| Field | A key-value pair within a document |
| Mapping | Schema defining field names and types |
| Dynamic Mapping | Automatic type inference on new fields |
| Explicit Mapping | Manually defined field types |
| `text` | Analyzed for full-text search |
| `keyword` | Exact match, sorting, aggregations |
| `nested` | Array of objects with preserved field relationships |
| Multi-field | One field mapped under multiple types |

---

**Conclusion:**
Indices, documents, and fields form the foundational data model of Elasticsearch. A clear understanding of how data is structured — particularly how field types affect search, aggregation, and storage behavior — is essential before working with queries, analyzers, or performance tuning.

**Next Steps:**
- Index lifecycle management (ILM)
- Analyzers and tokenization
- Reindexing strategies
- Shard allocation and sizing