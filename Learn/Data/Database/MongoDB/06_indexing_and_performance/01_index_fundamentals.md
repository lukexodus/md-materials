## Index Fundamentals


### How Indexes Work in MongoDB

MongoDB indexes are data structures that improve query performance by creating shortcuts to documents in a collection. They function similarly to indexes in books, providing a sorted reference that allows the database to locate documents without scanning every document in the collection.

When MongoDB receives a query, it uses the query optimizer to determine the most efficient execution plan. If an appropriate index exists, MongoDB uses it to quickly locate the relevant documents. Without indexes, MongoDB performs collection scans, examining every document to find matches.

MongoDB stores indexes in B-tree structures, which maintain sorted order and allow for efficient insertions, deletions, and searches. Each index entry contains the indexed field value(s) and a pointer to the corresponding document.

**Key points:**

- Indexes significantly reduce query execution time
- They consume additional storage space and memory
- Index maintenance adds overhead to write operations
- MongoDB automatically creates an index on the `_id` field

### Single Field Indexes

Single field indexes are the simplest form of indexes, created on a single field within documents. MongoDB supports single field indexes on any field, including fields within embedded documents and arrays.

```javascript
// Create ascending index on "username" field
db.users.createIndex({ username: 1 })

// Create descending index on "createdAt" field  
db.posts.createIndex({ createdAt: -1 })

// Index on embedded document field
db.users.createIndex({ "address.zipcode": 1 })

// Index on array field
db.products.createIndex({ tags: 1 })
```

The direction (1 for ascending, -1 for descending) matters for sort operations but not for equality queries. For single field indexes, MongoDB can traverse the index in either direction efficiently.

**Key points:**

- Support equality, range, and sort operations
- Can be created on fields at any level of document hierarchy
- Array fields create multikey indexes automatically
- Direction affects sort optimization

### Compound Indexes

Compound indexes are indexes on multiple fields, supporting queries that filter on multiple criteria. The order of fields in a compound index is crucial as it determines which queries the index can optimize.

```javascript
// Compound index on multiple fields
db.users.createIndex({ status: 1, age: -1, username: 1 })

// This index supports these query patterns:
// { status: "active" }
// { status: "active", age: { $gte: 18 } }
// { status: "active", age: { $gte: 18 }, username: "john" }
```

MongoDB follows the "prefix rule" - a compound index can support queries on any prefix of the indexed fields. An index on `{a: 1, b: 1, c: 1}` can optimize queries on `{a}`, `{a, b}`, or `{a, b, c}`, but not on `{b}` or `{c}` alone.

For sort operations, compound indexes must match the sort pattern exactly or be a prefix that matches. The sort direction must also align with the index direction or be completely reversed.

**Key points:**

- Field order determines query optimization capabilities
- Follow the ESR rule: Equality, Sort, Range for optimal field ordering
- Can contain up to 32 fields [Unverified - specific limit may vary by MongoDB version]
- More selective fields should typically come first

### Index Intersection

Index intersection allows MongoDB to use multiple single-field indexes together to satisfy a query. When no single compound index covers all query predicates, MongoDB may intersect results from multiple indexes.

```javascript
// Given these indexes:
db.users.createIndex({ status: 1 })
db.users.createIndex({ age: 1 })

// MongoDB can intersect them for this query:
db.users.find({ status: "active", age: { $gte: 18 } })
```

However, index intersection is generally less efficient than a well-designed compound index. The database must retrieve document IDs from multiple indexes, intersect the results, and then fetch the actual documents.

**Key points:**

- Automatic optimization technique when compound indexes aren't available
- Less efficient than purpose-built compound indexes
- Useful for ad-hoc queries on collections with many single-field indexes
- Query planner decides when to use intersection based on cost analysis

### Index Cardinality and Selectivity

Index cardinality refers to the number of unique values in an indexed field, while selectivity measures how effectively an index can narrow down query results.

High cardinality fields (like email addresses or usernames) have many unique values and provide good selectivity. Low cardinality fields (like boolean flags or status fields with few options) have fewer unique values and lower selectivity.

```javascript
// High cardinality - good selectivity
db.users.createIndex({ email: 1 })  // Most values unique

// Low cardinality - poor selectivity  
db.users.createIndex({ isActive: 1 })  // Only true/false values
```

For compound indexes, place high-selectivity fields first to maximize filtering effectiveness. Fields used in equality queries should precede those used in range queries, following the ESR (Equality, Sort, Range) principle.

**Key points:**

- High cardinality fields make more effective indexes
- Low selectivity indexes may not significantly improve performance
- Consider query patterns when evaluating field selectivity
- Cardinality can change over time as data grows

**Example** of optimal compound index design:

```javascript
// Query pattern: find active users in a specific city, sorted by registration date
db.users.find({ 
  status: "active",           // Equality - moderate selectivity
  city: "New York"           // Equality - high selectivity  
}).sort({ registeredAt: -1 }) // Sort

// Optimal index following ESR:
db.users.createIndex({ 
  city: 1,           // High selectivity equality first
  status: 1,         // Lower selectivity equality second  
  registeredAt: -1   // Sort field last
})
```

Understanding these fundamentals enables effective index strategy development, balancing query performance improvements against storage overhead and write operation costs.

---

