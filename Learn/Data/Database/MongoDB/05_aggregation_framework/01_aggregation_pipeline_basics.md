## Aggregation Pipeline Basics


### Pipeline concept and stages

The MongoDB aggregation pipeline is a framework for data processing that transforms documents through a series of sequential stages. Each stage performs a specific operation on the input documents and passes the results to the next stage, similar to an assembly line where data flows through multiple processing steps.

The pipeline operates on a collection of documents and consists of one or more stages, where each stage is represented by an operator that begins with a dollar sign (`$`). Documents enter the pipeline and are processed stage by stage, with each stage potentially filtering, transforming, grouping, or reshaping the data.

**Key points:**

- Stages execute in sequence, with output from one stage becoming input for the next
- Each stage can modify document structure, filter documents, or perform calculations
- The pipeline is declarative - you specify what transformations you want rather than how to perform them
- Multiple documents can be processed simultaneously through the pipeline
- Results are typically returned as a cursor or array of documents

### Core Pipeline Stages

#### `$match`

The `$match` stage filters documents based on specified criteria, similar to the `find()` method's query conditions. It should typically be placed early in the pipeline to reduce the number of documents processed by subsequent stages.

**Example:**

```javascript
db.products.aggregate([
  {
    $match: {
      category: "electronics",
      price: { $gte: 100, $lte: 1000 }
    }
  }
])
```

**Key points:**

- Uses standard MongoDB query operators
- Can include complex query conditions with logical operators
- Should be positioned early in pipeline for performance optimization
- Cannot use aggregation expressions (unlike `$project` or `$group`)

#### `$project`

The `$project` stage reshapes documents by including, excluding, or adding new fields. It controls the structure of documents passed to the next stage and can create computed fields using aggregation expressions.

**Example:**

```javascript
db.products.aggregate([
  {
    $project: {
      name: 1,
      category: 1,
      discountedPrice: { $multiply: ["$price", 0.9] },
      _id: 0
    }
  }
])
```

**Key points:**

- Include fields with `fieldName: 1` or exclude with `fieldName: 0`
- Create new fields using aggregation expressions
- Can rename fields using `newName: "$oldName"`
- The `_id` field is included by default unless explicitly excluded

#### `$sort`

The `$sort` stage orders documents based on specified field values. It accepts a document where field names are keys and sort direction values are either 1 (ascending) or -1 (descending).

**Example:**

```javascript
db.products.aggregate([
  {
    $sort: {
      price: -1,
      name: 1
    }
  }
])
```

**Key points:**

- Multiple sort fields are processed in order of specification
- Memory usage is limited to 100MB by default for sort operations
- Can sort by computed fields from previous stages
- Uses indexes when placed early in pipeline and sorting by indexed fields

#### `$limit`

The `$limit` stage restricts the number of documents passed to the next stage by specifying a maximum count. It's commonly used for pagination or retrieving top results.

**Example:**

```javascript
db.products.aggregate([
  { $sort: { price: -1 } },
  { $limit: 10 }
])
```

**Key points:**

- Takes a positive integer as parameter
- Often combined with `$sort` to get top/bottom results
- Processes documents in order received from previous stage
- Can significantly improve performance by reducing data processing

#### `$skip`

The `$skip` stage bypasses a specified number of documents and passes the remaining documents to the next stage. It's frequently used with `$limit` for pagination implementations.

**Example:**

```javascript
db.products.aggregate([
  { $sort: { name: 1 } },
  { $skip: 20 },
  { $limit: 10 }
])
```

**Key points:**

- Takes a non-negative integer as parameter
- Combined with `$limit` for pagination: skip = (page - 1) * pageSize
- Should typically follow `$sort` to ensure consistent results
- Large skip values can impact performance on unsorted data

### Pipeline Optimization Principles

#### Early Filtering and Projection

Position `$match` stages as early as possible in the pipeline to reduce the number of documents processed by subsequent stages. Similarly, use `$project` early to eliminate unnecessary fields and reduce memory usage.

**Key points:**

- `$match` before `$sort` can utilize indexes more effectively
- Early `$project` reduces network transfer and memory consumption
- Filter before expensive operations like `$group` or `$lookup`

#### Index Utilization

The aggregation pipeline can utilize indexes, but optimization depends on stage order and field usage. `$match` and `$sort` stages can benefit from appropriate indexes when positioned early in the pipeline.

**Key points:**

- `$match` at pipeline start can use indexes for filtering
- `$sort` can use indexes if it's the first stage or immediately follows `$match`
- [Inference] Compound indexes may optimize pipelines with multiple filter and sort criteria
- Index usage becomes less effective as pipeline progresses through transformation stages

#### Memory Management

Aggregation operations have memory limitations that affect performance and feasibility. Understanding these constraints helps design efficient pipelines.

**Key points:**

- Each stage limited to 100MB of RAM by default
- `$sort` and `$group` are memory-intensive operations
- Use `allowDiskUse: true` option for operations exceeding memory limits
- [Inference] Breaking large operations into smaller stages may improve memory efficiency

#### Stage Ordering Strategy

The sequence of pipeline stages significantly impacts performance. Optimal ordering typically follows the pattern: filter, sort, transform, group, and limit.

**Example:**

```javascript
// Optimized pipeline order
db.orders.aggregate([
  { $match: { status: "completed", date: { $gte: new Date("2024-01-01") } } },  // Filter early
  { $sort: { date: -1 } },  // Sort before grouping
  { $project: { customerId: 1, amount: 1, date: 1 } },  // Project needed fields
  { $group: { _id: "$customerId", totalAmount: { $sum: "$amount" } } },  // Group after filtering
  { $limit: 100 }  // Limit final results
])
```

### Working with Multiple Collections

#### `$lookup` Stage

The `$lookup` stage performs left outer joins between collections, similar to JOIN operations in relational databases. It adds a new array field containing matching documents from the joined collection.

**Example:**

```javascript
db.orders.aggregate([
  {
    $lookup: {
      from: "customers",
      localField: "customerId",
      foreignField: "_id",
      as: "customerInfo"
    }
  }
])
```

**Key points:**

- Creates array field even if only one document matches
- Joined collection must be in the same database
- Can perform complex joins using pipeline syntax
- [Inference] Performance may degrade with large collections or missing indexes

#### Pipeline-based `$lookup`

Advanced `$lookup` operations can include their own aggregation pipeline for more complex join conditions and transformations.

**Example:**

```javascript
db.orders.aggregate([
  {
    $lookup: {
      from: "products",
      let: { orderItems: "$items" },
      pipeline: [
        {
          $match: {
            $expr: { $in: ["$_id", "$$orderItems.productId"] }
          }
        },
        { $project: { name: 1, price: 1 } }
      ],
      as: "productDetails"
    }
  }
])
```

#### `$graphLookup` for Hierarchical Data

The `$graphLookup` stage performs recursive searches on hierarchical or graph-like data structures, useful for organizational charts, category trees, or social networks.

**Example:**

```javascript
db.employees.aggregate([
  {
    $graphLookup: {
      from: "employees",
      startWith: "$_id",
      connectFromField: "_id",
      connectToField: "managerId",
      as: "subordinates",
      maxDepth: 3
    }
  }
])
```

#### Cross-Collection Aggregation Strategies

When working with multiple collections, consider data modeling and pipeline design to optimize performance and maintainability.

**Key points:**

- [Inference] Embedding related data may eliminate need for `$lookup` operations
- Consider denormalization for frequently accessed related data
- Use `$lookup` judiciously as it can impact performance
- [Unverified] Pipeline caching mechanisms may optimize repeated cross-collection queries

**Conclusion:** MongoDB's aggregation pipeline provides powerful data processing capabilities through its stage-based architecture. Effective pipeline design requires understanding individual stage operations, optimization principles, and cross-collection strategies. Performance optimization focuses on early filtering, proper stage ordering, index utilization, and memory management considerations.

---

