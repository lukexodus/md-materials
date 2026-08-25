## Performance Optimization


### Query Profiling and Analysis

Query profiling is the systematic analysis of database operations to identify performance bottlenecks and optimization opportunities. MongoDB provides comprehensive profiling tools to examine query execution patterns, resource consumption, and timing metrics.

**Key Profiling Metrics:**

- **Execution time**: Total time spent executing the operation
- **Documents examined**: Number of documents scanned during execution
- **Documents returned**: Number of documents returned to client
- **Index usage**: Which indexes were utilized during query execution
- **Stages executed**: Individual steps in the query execution plan
- **Resource consumption**: CPU, memory, and I/O utilization patterns

**Manual Query Analysis:**

The `explain()` method provides detailed execution statistics for individual queries:

```javascript
// Basic explain output
db.users.find({ age: { $gte: 25 } }).explain()

// Detailed execution statistics
db.users.find({ age: { $gte: 25 } }).explain("executionStats")

// Complete query plan analysis
db.users.find({ age: { $gte: 25 } }).explain("allPlansExecution")
```

**Aggregation Pipeline Profiling:**

```javascript
db.orders.aggregate([
  { $match: { status: "completed" } },
  { $group: { _id: "$customerId", total: { $sum: "$amount" } } }
]).explain("executionStats")
```

**Key Explain Output Analysis:**

**Execution Statistics Interpretation:**

- `totalDocsExamined` vs `totalDocsReturned`: High ratios indicate inefficient queries
- `executionTimeMillis`: Total query execution time
- `totalKeysExamined`: Number of index entries examined
- `stage`: Query execution strategy (IXSCAN, COLLSCAN, etc.)

**Example Analysis:**

```javascript
// Inefficient query pattern
{
  "executionStats": {
    "totalDocsExamined": 100000,
    "totalDocsReturned": 5,
    "executionTimeMillis": 150,
    "stage": "COLLSCAN"
  }
}
```

This indicates a collection scan examining 100,000 documents to return only 5 results, suggesting need for indexing.

### Using MongoDB Profiler

The MongoDB Profiler captures and stores performance data for database operations, enabling systematic performance analysis across all database activities.

**Profiler Configuration:**

**Setting Profiler Levels:**

```javascript
// Level 0: Profiler off
db.setProfilingLevel(0)

// Level 1: Profile slow operations (default >100ms)
db.setProfilingLevel(1)

// Level 1 with custom threshold
db.setProfilingLevel(1, { slowms: 50 })

// Level 2: Profile all operations
db.setProfilingLevel(2)

// Level 2 with sampling
db.setProfilingLevel(2, { sampleRate: 0.1 })
```

**Profiler Collection Analysis:**

```javascript
// View recent slow operations
db.system.profile.find().sort({ ts: -1 }).limit(10)

// Find operations by collection
db.system.profile.find({ "ns": "mydb.users" })

// Find operations exceeding specific duration
db.system.profile.find({ "ts": { $gte: new Date(Date.now() - 3600000) }, "millis": { $gt: 100 } })
```

**Profiler Data Structure:**

[Inference] Based on MongoDB documentation patterns, profiler documents typically contain these fields:

- `ts`: Timestamp of operation
- `t`: Operation type (query, insert, update, delete)
- `ns`: Namespace (database.collection)
- `command`: Full command executed
- `millis`: Execution time in milliseconds
- `planSummary`: Index usage summary
- `keysExamined`: Number of index keys examined
- `docsExamined`: Number of documents examined

**Advanced Profiler Queries:**

```javascript
// Aggregate profiler data for analysis
db.system.profile.aggregate([
  { $match: { ts: { $gte: new Date(Date.now() - 3600000) } } },
  {
    $group: {
      _id: "$ns",
      avgDuration: { $avg: "$millis" },
      maxDuration: { $max: "$millis" },
      operationCount: { $sum: 1 }
    }
  },
  { $sort: { avgDuration: -1 } }
])
```

**Profiler Best Practices:**

[Inference] These practices are commonly recommended for profiler usage:

- Enable profiling temporarily during analysis periods
- Use sampling in high-traffic environments to reduce overhead
- Set appropriate `slowms` thresholds based on application requirements
- Monitor profiler collection size and implement rotation policies
- Analyze patterns over time rather than individual operations

### Index Usage Patterns

Understanding index usage patterns is crucial for query optimization and database performance. MongoDB provides various tools to analyze how indexes are utilized and identify optimization opportunities.

**Index Usage Analysis:**

```javascript
// View index usage statistics
db.users.aggregate([{ $indexStats: {} }])

// Get collection index information
db.users.getIndexes()

// Analyze index usage for specific operations
db.users.find({ email: "user@example.com" }).explain("executionStats")
```

**Common Index Usage Patterns:**

**Single Field Indexes:**

```javascript
// Create single field index
db.users.createIndex({ email: 1 })

// Optimal for equality queries
db.users.find({ email: "user@example.com" })

// Supports range queries
db.users.find({ age: { $gte: 25, $lte: 65 } })
```

**Compound Indexes:**

```javascript
// Create compound index
db.orders.createIndex({ customerId: 1, orderDate: -1, status: 1 })

// Supports queries on prefixes
db.orders.find({ customerId: "123" }) // Uses index
db.orders.find({ customerId: "123", orderDate: { $gte: new Date() } }) // Uses index
db.orders.find({ orderDate: { $gte: new Date() } }) // Does not use index efficiently
```

**Index Selectivity Analysis:**

High selectivity indexes (returning few documents) are generally more efficient:

```javascript
// Analyze field cardinality
db.users.aggregate([
  { $group: { _id: "$status", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
])

// Check index effectiveness
db.users.find({ status: "active" }).explain("executionStats")
```

**Partial Index Optimization:**

```javascript
// Create partial index for specific conditions
db.orders.createIndex(
  { customerId: 1, orderDate: -1 },
  { partialFilterExpression: { status: "active" } }
)

// Optimizes queries matching the filter
db.orders.find({ customerId: "123", status: "active" })
```

**Text Index Patterns:**

```javascript
// Create text index
db.articles.createIndex({ title: "text", content: "text" })

// Analyze text search performance
db.articles.find({ $text: { $search: "mongodb performance" } }).explain()
```

**Index Intersection Analysis:**

[Inference] MongoDB may use multiple indexes for complex queries, though this behavior depends on query optimizer decisions:

```javascript
// Multiple single-field indexes
db.users.createIndex({ age: 1 })
db.users.createIndex({ city: 1 })

// Query potentially using index intersection
db.users.find({ age: { $gte: 25 }, city: "New York" }).explain()
```

### Memory Usage Optimization

MongoDB memory usage optimization involves managing working set size, buffer pool efficiency, and query memory consumption to maximize performance within available system resources.

**Working Set Management:**

The working set represents frequently accessed data that should remain in memory for optimal performance.

**Working Set Analysis:**

```javascript
// Monitor memory statistics
db.serverStatus().mem
db.serverStatus().wiredTiger.cache

// Analyze collection statistics
db.users.stats()
```

**Key Memory Metrics:**

[Inference] These metrics are typically important for memory analysis:

- **Resident memory**: Physical memory currently used by MongoDB
- **Virtual memory**: Total virtual memory allocated
- **Cache usage**: Percentage of cache utilized
- **Page faults**: Frequency of data not found in memory
- **Cache eviction rate**: How often data is removed from cache

**Query Memory Optimization:**

**Sort Memory Limits:**

```javascript
// Large sorts require indexes to avoid memory limits
db.users.find().sort({ createdAt: -1 }).limit(100)

// Create supporting index
db.users.createIndex({ createdAt: -1 })
```

**Aggregation Memory Management:**

```javascript
// Use allowDiskUse for large aggregations
db.orders.aggregate([
  { $group: { _id: "$customerId", total: { $sum: "$amount" } } },
  { $sort: { total: -1 } }
], { allowDiskUse: true })
```

**Index Memory Optimization:**

**Index Size Management:**

```javascript
// Analyze index sizes
db.users.totalIndexSize()
db.stats().indexSizes

// Optimize with partial indexes
db.users.createIndex(
  { email: 1 },
  { partialFilterExpression: { isActive: true } }
)
```

**Connection Pool Optimization:**

[Inference] Connection pooling affects memory usage, though specific implementation details vary by driver:

- Configure appropriate pool sizes based on application concurrency
- Monitor connection utilization patterns
- Balance between connection overhead and request latency
- Consider connection timeout settings for resource cleanup

**Memory Usage Monitoring:**

```javascript
// Regular memory monitoring
db.runCommand({ serverStatus: 1, repl: 0, metrics: 0, locks: 0 })

// Focus on cache metrics
db.serverStatus().wiredTiger.cache
```

### Query Plan Caching

MongoDB's query planner caches execution plans to avoid repeated plan selection overhead for similar queries. Understanding plan caching behavior is essential for consistent query performance.

**Plan Cache Mechanics:**

The query planner evaluates multiple possible execution strategies and caches the most efficient plan for reuse with similar queries.

**Plan Cache Analysis:**

```javascript
// View cached plans for collection
db.users.getPlanCache().list()

// Get plan cache statistics
db.users.getPlanCache().getPlansByQuery({ age: { $gte: 25 } })

// Clear plan cache
db.users.getPlanCache().clear()
```

**Plan Cache Key Factors:**

[Inference] Plan cache keys are typically determined by:

- Query shape (field names and operators, but not literal values)
- Sort specifications
- Index hint usage
- Collation settings
- Read concern levels

**Example Query Shapes:**

```javascript
// These queries share the same plan cache entry
db.users.find({ age: 25 })
db.users.find({ age: 30 })
db.users.find({ age: { $gte: 18 } })

// Different plan cache entry due to different shape
db.users.find({ age: 25, status: "active" })
```

**Plan Cache Eviction:**

**Automatic Eviction Triggers:**

- Index creation or deletion
- Collection statistics changes significantly
- Plan performance degrades below threshold
- Cache size limits exceeded
- Server restart

**Manual Plan Cache Management:**

```javascript
// Clear specific query plans
db.users.getPlanCache().clearPlansByQuery({ age: { $gte: 1 } })

// Clear all plans for collection
db.users.getPlanCache().clear()
```

**Plan Cache Performance Impact:**

**Cache Hit Analysis:**

```javascript
// Monitor plan cache efficiency
db.serverStatus().metrics.queryExecutor

// Analyze plan cache statistics
db.runCommand({ planCacheClear: "users" })
```

**Optimization Strategies:**

**Index Hinting for Consistent Plans:**

```javascript
// Force specific index usage
db.users.find({ age: { $gte: 25 } }).hint({ age: 1 })

// Ensure plan consistency for critical queries
db.orders.find({ customerId: "123" }).hint({ customerId: 1, orderDate: -1 })
```

**Plan Cache Warming:**

```javascript
// Execute representative queries after index changes
db.users.find({ age: { $gte: 25 } }).limit(1)
db.users.find({ email: "test@example.com" }).limit(1)
db.users.find({ status: "active" }).limit(1)
```

**Performance Monitoring Integration:**

```javascript
// Comprehensive performance analysis
db.runCommand({
  aggregate: "orders",
  pipeline: [
    { $match: { status: "completed" } },
    { $group: { _id: "$customerId", total: { $sum: "$amount" } } }
  ],
  explain: true,
  verbosity: "executionStats"
})
```

**Optimization Workflow:**

1. **Profile Operations**: Enable profiler to identify slow queries
2. **Analyze Execution Plans**: Use explain() to understand query execution
3. **Create Targeted Indexes**: Design indexes based on query patterns
4. **Monitor Plan Cache**: Ensure consistent plan selection
5. **Validate Performance**: Measure improvement through continued profiling

**Best Practices Integration:**

[Inference] These practices are commonly recommended for comprehensive performance optimization:

- Implement regular performance monitoring schedules
- Establish baseline metrics before optimization changes
- Test index changes in staging environments
- Monitor resource utilization during optimization
- Document optimization decisions and their performance impact

**Related Topics:** Index design strategies, sharding performance considerations, replica set read preferences optimization, connection pooling configuration, and hardware sizing for MongoDB deployments.

---

