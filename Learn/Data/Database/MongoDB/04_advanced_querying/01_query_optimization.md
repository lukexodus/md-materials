## Query Optimization


### Using `explain()` for Query Analysis

#### Basic `explain()` Usage

The `explain()` method provides detailed information about how MongoDB executes queries, including execution statistics, index usage, and performance metrics. It operates in different verbosity modes to control the level of detail returned.

**Syntax:**

```javascript
db.collection.find(query).explain(verbosity)
db.collection.aggregate(pipeline).explain(verbosity)
```

**Verbosity levels:**

- `"queryPlanner"` (default): Shows query plan without execution
- `"executionStats"`: Includes execution statistics
- `"allPlansExecution"`: Shows all considered plans and their statistics

**Example:**

```javascript
db.users.find({ age: { $gte: 25 } }).explain("executionStats")
```

#### Query Planner Information

Query planner output reveals the execution strategy MongoDB selects for query processing. The `winningPlan` section contains the chosen execution path, while `rejectedPlans` shows alternative strategies considered but not selected.

**Key planner fields:**

```javascript
{
  "queryPlanner": {
    "plannerVersion": 1,
    "namespace": "mydb.users",
    "indexFilterSet": false,
    "parsedQuery": { "age": { "$gte": 25 } },
    "winningPlan": {
      "stage": "IXSCAN",
      "indexName": "age_1",
      "direction": "forward"
    }
  }
}
```

The `stage` field indicates the operation type:

- `COLLSCAN`: Full collection scan
- `IXSCAN`: Index scan
- `FETCH`: Document retrieval after index lookup
- `SORT`: In-memory sorting operation
- `LIMIT`: Result limitation

#### Execution Statistics Analysis

Execution statistics provide runtime metrics that reveal actual query performance characteristics. These metrics help identify bottlenecks and optimization opportunities.

**Critical execution metrics:**

```javascript
{
  "executionStats": {
    "totalExaminedDocs": 1000,
    "totalDocsExamined": 1000,
    "totalDocsReturned": 250,
    "executionTimeMillis": 45,
    "totalKeysExamined": 250,
    "docsExaminedPerResult": 4.0
  }
}
```

**Performance indicators:**

- `executionTimeMillis`: Total query execution time
- `totalDocsExamined`: Documents scanned during execution
- `totalKeysExamined`: Index keys examined
- `docsExaminedPerResult`: Efficiency ratio (lower is better)

A high `docsExaminedPerResult` ratio indicates inefficient queries that examine many documents to return few results.

#### Index Usage Patterns

The `explain()` output reveals how queries utilize available indexes and whether index usage is optimal for the query pattern.

**Efficient index usage example:**

```javascript
db.products.find({ category: "electronics", price: { $lt: 500 } })
         .explain("executionStats")
```

**Output analysis:**

```javascript
{
  "winningPlan": {
    "stage": "FETCH",
    "inputStage": {
      "stage": "IXSCAN",
      "indexName": "category_1_price_1",
      "indexBounds": {
        "category": ["electronics", "electronics"],
        "price": ["$minKey", 500]
      }
    }
  }
}
```

This indicates efficient compound index usage where both query conditions are satisfied by index bounds.

#### Query Plan Comparison

When multiple indexes are available, MongoDB's query planner evaluates different execution strategies and selects the most efficient plan based on estimated cost.

**Example with multiple plan consideration:**

```javascript
{
  "queryPlanner": {
    "winningPlan": { /* selected plan */ },
    "rejectedPlans": [
      { "stage": "COLLSCAN" },
      { "stage": "IXSCAN", "indexName": "alternate_index" }
    ]
  }
}
```

[Inference] The query planner's cost-based optimization may occasionally select suboptimal plans, particularly with skewed data distributions or outdated statistics.

### Index Usage in Queries

#### Index Selection Process

MongoDB's query optimizer automatically selects indexes based on query predicates, sort requirements, and available index options. The selection process considers index selectivity, key order, and query patterns.

**Index matching rules:**

- Equality matches can use any index containing the field
- Range queries benefit from indexes on the range field
- Sort operations require indexes matching sort order
- Compound indexes support left-prefix matching

**Example query and index matching:**

```javascript
// Query
db.orders.find({ customerId: 123, status: "pending" }).sort({ createdAt: -1 })

// Optimal compound index
db.orders.createIndex({ customerId: 1, status: 1, createdAt: -1 })
```

#### Compound Index Usage Patterns

Compound indexes support multiple query patterns through prefix matching. The index field order significantly impacts query performance and supported operations.

**Index prefix examples:**

```javascript
// Compound index: { name: 1, age: 1, city: 1 }

// Supported queries (uses index):
db.users.find({ name: "John" })
db.users.find({ name: "John", age: 30 })
db.users.find({ name: "John", age: 30, city: "NYC" })

// Unsupported queries (may not use index efficiently):
db.users.find({ age: 30 })
db.users.find({ city: "NYC" })
db.users.find({ age: 30, city: "NYC" })
```

#### Index Intersection

MongoDB can combine multiple single-field indexes to satisfy compound query conditions through index intersection, though this approach is generally less efficient than purpose-built compound indexes.

**Example:**

```javascript
// Two single indexes: { name: 1 }, { age: 1 }
// Query combining both conditions
db.users.find({ name: "Alice", age: 25 }).explain()
```

**Output showing intersection:**

```javascript
{
  "winningPlan": {
    "stage": "FETCH",
    "inputStage": {
      "stage": "AND_HASH",
      "inputStages": [
        { "stage": "IXSCAN", "indexName": "name_1" },
        { "stage": "IXSCAN", "indexName": "age_1" }
      ]
    }
  }
}
```

**Key points:**

- Index intersection has overhead compared to compound indexes
- Most effective with highly selective individual conditions
- Consider creating compound indexes for frequently combined queries

#### Covered Queries

Covered queries retrieve all required data directly from index entries without accessing document storage. These queries achieve optimal performance by avoiding document fetches.

**Requirements for covered queries:**

- All query fields must be indexed
- All projection fields must be indexed
- Query cannot include array fields
- `_id` field must be excluded from projection unless indexed

**Example covered query:**

```javascript
// Index: { name: 1, email: 1, status: 1 }
db.users.find(
  { status: "active" },
  { name: 1, email: 1, _id: 0 }
).explain()
```

**Covered query indication:**

```javascript
{
  "winningPlan": {
    "stage": "PROJECTION_COVERED",
    "inputStage": {
      "stage": "IXSCAN",
      "indexName": "status_1_name_1_email_1"
    }
  }
}
```

#### Index Hints

Index hints force MongoDB to use specific indexes for query execution, overriding the query planner's automatic selection. This technique helps in scenarios where the planner selects suboptimal indexes.

**Syntax:**

```javascript
db.collection.find(query).hint(indexName)
db.collection.find(query).hint({ field: 1 })
```

**Example:**

```javascript
db.products.find({ category: "books" }).hint("category_1_price_1")
```

**Use cases for index hints:**

- Testing different index performance
- Working around query planner limitations
- Ensuring consistent performance in critical operations

[Unverified] Index hints should be used cautiously as they bypass MongoDB's cost-based optimization and may degrade performance when data patterns change.

### Query Performance Metrics

#### Key Performance Indicators

Query performance measurement involves multiple metrics that collectively indicate query efficiency and resource utilization patterns.

**Primary performance metrics:**

- Execution time (milliseconds)
- Documents examined vs. documents returned
- Index keys examined
- Memory usage for sorting operations
- Lock acquisition time and duration

#### Execution Time Analysis

Execution time represents the total duration for query processing, including index traversal, document retrieval, and result compilation.

**Execution time components:**

```javascript
{
  "executionStats": {
    "executionTimeMillis": 145,
    "executionTimeMillisEstimate": 142,
    "totalDocsExamined": 5000,
    "totalDocsReturned": 100
  }
}
```

**Performance benchmarks:**

- Sub-millisecond: Excellent (typically covered queries)
- 1-10ms: Good (efficient index usage)
- 10-100ms: Acceptable (depending on result size)
- 100ms+: Requires optimization

#### Document Examination Efficiency

The ratio between documents examined and documents returned indicates query selectivity and index effectiveness.

**Efficiency calculation:**

```javascript
efficiency = totalDocsReturned / totalDocsExamined
```

**Interpretation guidelines:**

- Ratio close to 1.0: Highly efficient query
- Ratio 0.1-0.5: Moderately efficient
- Ratio below 0.1: Inefficient, requires optimization

**Example analysis:**

```javascript
// Poor efficiency example
{
  "totalDocsExamined": 10000,
  "totalDocsReturned": 50,
  "docsExaminedPerResult": 200.0  // Very inefficient
}
```

#### Memory Usage Patterns

Queries requiring in-memory operations (sorting, grouping) consume additional resources and may impact overall database performance.

**Memory-intensive operations:**

- Sorting without supporting indexes
- Large aggregation pipeline stages
- Text search operations
- Map-reduce functions

**Memory usage indicators:**

```javascript
{
  "executionStats": {
    "executionTimeMillis": 1250,
    "totalDocsExamined": 50000,
    "executionStages": {
      "stage": "SORT",
      "sortPattern": { "createdAt": -1 },
      "memUsage": 33554432,  // 32MB memory usage
      "limitAmount": 100
    }
  }
}
```

#### Index Statistics

Index usage statistics reveal how effectively queries utilize available indexes and identify potential optimization opportunities.

**Index efficiency metrics:**

```javascript
{
  "indexStats": {
    "totalKeysExamined": 1500,
    "totalDocsExamined": 300,
    "stage": "IXSCAN",
    "indexName": "compound_index_1",
    "direction": "forward",
    "indexBounds": {
      "field1": ["value1", "value1"],
      "field2": ["$minKey", "$maxKey"]
    }
  }
}
```

**Key points:**

- Low `totalKeysExamined` relative to results indicates efficient index usage
- Tight index bounds suggest good query selectivity
- Multiple index scans may indicate need for compound indexes

### Optimizing Query Patterns

#### Query Structure Optimization

Query structure significantly impacts performance through field order, operator selection, and condition composition. Optimal query patterns leverage index capabilities and minimize document examination.

**Efficient query patterns:**

```javascript
// Optimized: Most selective condition first
db.orders.find({
  customerId: ObjectId("..."),  // High selectivity
  status: "pending",            // Medium selectivity
  amount: { $gte: 100 }        // Low selectivity
})

// Suboptimal: Less selective condition first
db.orders.find({
  amount: { $gte: 100 },       // Low selectivity first
  status: "pending",
  customerId: ObjectId("...")
})
```

#### Index Design for Query Patterns

Index design should align with common query patterns, considering field selectivity, query frequency, and sorting requirements.

**Compound index field ordering principles:**

1. Equality conditions before range conditions
2. High selectivity fields before low selectivity fields
3. Sort fields at the end of compound indexes
4. Query frequency considerations

**Example optimal index design:**

```javascript
// Common query pattern
db.events.find({ userId: 123, type: "login", timestamp: { $gte: startDate } })
         .sort({ timestamp: -1 })

// Optimal compound index
db.events.createIndex({ userId: 1, type: 1, timestamp: -1 })
```

#### Aggregation Pipeline Optimization

Aggregation pipeline optimization involves stage ordering, index utilization, and memory management to achieve optimal performance.

**Pipeline optimization techniques:**

```javascript
// Optimized pipeline: Filter early, sort with index
db.orders.aggregate([
  { $match: { status: "completed", customerId: 123 } },  // Use index
  { $sort: { createdAt: -1 } },                         // Use index for sort
  { $lookup: { /* join operation */ } },                 // Expensive ops after filtering
  { $group: { /* grouping logic */ } }
])

// Supporting index
db.orders.createIndex({ customerId: 1, status: 1, createdAt: -1 })
```

**Pipeline stage ordering guidelines:**

- `$match` stages early to reduce document flow
- `$sort` stages before `$group` when possible
- `$limit` after `$sort` for top-N queries
- Expensive operations (`$lookup`, `$unwind`) after filtering

#### Range Query Optimization

Range queries benefit from specific index design patterns and query structure optimizations to minimize index key examination.

**Efficient range query patterns:**

```javascript
// Single-field range with supporting index
db.products.find({ price: { $gte: 100, $lte: 500 } })

// Compound range query optimization
db.sales.find({
  region: "North",                    // Equality first
  date: { $gte: startDate, $lte: endDate }  // Range second
}).sort({ date: -1 })

// Supporting compound index
db.sales.createIndex({ region: 1, date: -1 })
```

#### Sort Operation Optimization

Sort operations achieve optimal performance when supported by appropriate indexes, avoiding expensive in-memory sorting.

**Index-supported sorting:**

```javascript
// Query with sort
db.articles.find({ category: "tech" }).sort({ publishedDate: -1, views: -1 })

// Optimal supporting index
db.articles.createIndex({ category: 1, publishedDate: -1, views: -1 })
```

**Sort optimization strategies:**

- Create indexes matching sort patterns
- Combine filtering and sorting in compound indexes
- Use `$limit` with sorts to reduce memory usage
- Consider partial indexes for frequently sorted subsets

#### Text Search Optimization

Text search operations require specialized indexes and query patterns for optimal performance.

**Text index creation:**

```javascript
db.articles.createIndex({
  title: "text",
  content: "text",
  tags: "text"
}, {
  weights: { title: 10, content: 5, tags: 1 },
  name: "article_text_index"
})
```

**Optimized text search queries:**

```javascript
db.articles.find({
  $text: { $search: "mongodb optimization" },
  category: "database"  // Additional filter for selectivity
}).sort({ score: { $meta: "textScore" } })
```

#### Query Pattern Analysis and Monitoring

Regular analysis of query patterns helps identify optimization opportunities and performance degradation over time.

**Monitoring approaches:**

- Database profiler for slow query identification
- Query plan cache analysis for plan stability
- Index usage statistics for unused index detection
- Application performance monitoring integration

**Key points:**

- Monitor query performance trends over time
- Identify frequently executed slow queries
- Analyze index usage patterns and effectiveness
- Regular review of query plans for consistency

**Example profiler configuration:**

```javascript
// Enable profiler for slow operations
db.setProfilingLevel(2, { slowms: 100 })

// Query profiler collection
db.system.profile.find().limit(5).sort({ ts: -1 }).pretty()
```

This comprehensive approach to query optimization requires ongoing monitoring and adjustment as data patterns and application requirements evolve over time.

---

