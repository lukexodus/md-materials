## Advanced Aggregation Stages


### $group and Accumulator Operators

The `$group` stage groups documents by specified fields and performs calculations using accumulator operators. It's one of the most powerful stages in MongoDB's aggregation pipeline.

**Basic Syntax:**

```javascript
{
  $group: {
    _id: <expression>, // Group by field(s)
    <field1>: { <accumulator1>: <expression1> },
    <field2>: { <accumulator2>: <expression2> }
  }
}
```

**Key Accumulator Operators:**

- `$sum`: Calculates sum of numeric values
- `$avg`: Calculates average of numeric values
- `$min`/`$max`: Finds minimum/maximum values
- `$count`: Counts documents in each group
- `$push`: Creates array of all values in group
- `$addToSet`: Creates array of unique values
- `$first`/`$last`: Gets first/last value in group
- `$stdDevPop`/`$stdDevSamp`: Calculates standard deviation

**Example:**

```javascript
// Group orders by customer and calculate totals
db.orders.aggregate([
  {
    $group: {
      _id: "$customerId",
      totalAmount: { $sum: "$amount" },
      orderCount: { $count: {} },
      avgOrderValue: { $avg: "$amount" },
      orderDates: { $push: "$orderDate" },
      uniqueProducts: { $addToSet: "$productId" }
    }
  }
])
```

**Advanced Grouping Patterns:**

Multiple field grouping:

```javascript
{
  $group: {
    _id: {
      year: { $year: "$date" },
      month: { $month: "$date" },
      category: "$category"
    },
    totalSales: { $sum: "$amount" }
  }
}
```

Conditional accumulation:

```javascript
{
  $group: {
    _id: "$department",
    highPerformers: {
      $sum: {
        $cond: [{ $gte: ["$rating", 4.5] }, 1, 0]
      }
    }
  }
}
```

### $unwind for Array Processing

The `$unwind` stage deconstructs array fields, creating separate documents for each array element. This enables processing of embedded arrays in aggregation pipelines.

**Basic Syntax:**

```javascript
{ $unwind: "$arrayField" }
```

**Advanced Syntax:**

```javascript
{
  $unwind: {
    path: "$arrayField",
    includeArrayIndex: "arrayIndex",
    preserveNullAndEmptyArrays: true
  }
}
```

**Key Options:**

- `path`: Field path to array
- `includeArrayIndex`: Adds index position to output
- `preserveNullAndEmptyArrays`: Keeps documents with null/empty arrays

**Example:**

```javascript
// Document before unwind
{
  _id: 1,
  name: "John",
  hobbies: ["reading", "swimming", "coding"]
}

// After $unwind: "$hobbies"
[
  { _id: 1, name: "John", hobbies: "reading" },
  { _id: 1, name: "John", hobbies: "swimming" },
  { _id: 1, name: "John", hobbies: "coding" }
]
```

**Practical Use Cases:**

Analyzing array elements:

```javascript
db.products.aggregate([
  { $unwind: "$tags" },
  {
    $group: {
      _id: "$tags",
      productCount: { $count: {} },
      avgPrice: { $avg: "$price" }
    }
  }
])
```

Processing nested arrays:

```javascript
db.orders.aggregate([
  { $unwind: "$items" },
  { $unwind: "$items.variants" },
  {
    $group: {
      _id: "$items.variants.color",
      totalQuantity: { $sum: "$items.quantity" }
    }
  }
])
```

### $lookup for Joins

The `$lookup` stage performs left outer joins between collections, similar to SQL JOINs. It adds matching documents from other collections as arrays.

**Basic Syntax:**

```javascript
{
  $lookup: {
    from: "targetCollection",
    localField: "localFieldName",
    foreignField: "foreignFieldName",
    as: "outputArrayField"
  }
}
```

**Advanced Pipeline Syntax:**

```javascript
{
  $lookup: {
    from: "targetCollection",
    let: { localVar: "$localField" },
    pipeline: [
      { $match: { $expr: { $eq: ["$foreignField", "$$localVar"] } } },
      // Additional pipeline stages
    ],
    as: "outputArrayField"
  }
}
```

**Example:**

```javascript
// Join orders with customer details
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

**Advanced Lookup Patterns:**

Complex join conditions:

```javascript
{
  $lookup: {
    from: "products",
    let: { 
      orderId: "$_id",
      orderDate: "$date"
    },
    pipeline: [
      {
        $match: {
          $expr: {
            $and: [
              { $eq: ["$orderId", "$$orderId"] },
              { $gte: ["$releaseDate", "$$orderDate"] }
            ]
          }
        }
      },
      { $project: { name: 1, price: 1 } }
    ],
    as: "availableProducts"
  }
}
```

Multiple lookups with filtering:

```javascript
db.users.aggregate([
  {
    $lookup: {
      from: "orders",
      localField: "_id",
      foreignField: "userId",
      as: "orders"
    }
  },
  {
    $lookup: {
      from: "reviews",
      let: { userId: "$_id" },
      pipeline: [
        { $match: { $expr: { $eq: ["$userId", "$$userId"] } } },
        { $match: { rating: { $gte: 4 } } }
      ],
      as: "highRatedReviews"
    }
  }
])
```

### $addFields and $replaceRoot

These stages modify document structure by adding new fields or completely replacing the document root.

**$addFields Stage:** Adds new fields or modifies existing ones without removing other fields.

**Syntax:**

```javascript
{
  $addFields: {
    newField: <expression>,
    modifiedField: <expression>
  }
}
```

**Example:**

```javascript
db.orders.aggregate([
  {
    $addFields: {
      totalWithTax: { $multiply: ["$total", 1.08] },
      orderYear: { $year: "$orderDate" },
      fullName: { $concat: ["$firstName", " ", "$lastName"] }
    }
  }
])
```

**$replaceRoot Stage:** Replaces the entire document with a specified field or expression.

**Syntax:**

```javascript
{
  $replaceRoot: {
    newRoot: <expression>
  }
}
```

**Example:**

```javascript
// Replace root with embedded document
db.users.aggregate([
  {
    $replaceRoot: {
      newRoot: {
        $mergeObjects: [
          "$profile",
          { userId: "$_id", joinDate: "$createdAt" }
        ]
      }
    }
  }
])
```

**Advanced Field Manipulation:**

Conditional field addition:

```javascript
{
  $addFields: {
    status: {
      $switch: {
        branches: [
          { case: { $gte: ["$score", 90] }, then: "excellent" },
          { case: { $gte: ["$score", 70] }, then: "good" },
          { case: { $gte: ["$score", 50] }, then: "average" }
        ],
        default: "poor"
      }
    }
  }
}
```

Array field manipulation:

```javascript
{
  $addFields: {
    itemCount: { $size: "$items" },
    hasHighValueItems: {
      $gt: [
        {
          $size: {
            $filter: {
              input: "$items",
              cond: { $gt: ["$$this.price", 100] }
            }
          }
        },
        0
      ]
    }
  }
}
```

**Complex Pipeline Example:**

```javascript
db.sales.aggregate([
  // Unwind product array
  { $unwind: "$products" },
  
  // Lookup product details
  {
    $lookup: {
      from: "productCatalog",
      localField: "products.productId",
      foreignField: "_id",
      as: "productDetails"
    }
  },
  
  // Add calculated fields
  {
    $addFields: {
      productName: { $arrayElemAt: ["$productDetails.name", 0] },
      itemTotal: { $multiply: ["$products.quantity", "$products.price"] },
      discountAmount: {
        $multiply: [
          { $multiply: ["$products.quantity", "$products.price"] },
          { $divide: ["$products.discount", 100] }
        ]
      }
    }
  },
  
  // Group by sale and calculate totals
  {
    $group: {
      _id: "$_id",
      saleDate: { $first: "$saleDate" },
      customerId: { $first: "$customerId" },
      items: {
        $push: {
          productName: "$productName",
          quantity: "$products.quantity",
          itemTotal: "$itemTotal",
          discountAmount: "$discountAmount"
        }
      },
      subtotal: { $sum: "$itemTotal" },
      totalDiscount: { $sum: "$discountAmount" }
    }
  },
  
  // Add final calculations
  {
    $addFields: {
      finalTotal: { $subtract: ["$subtotal", "$totalDiscount"] },
      itemCount: { $size: "$items" }
    }
  }
])
```

**Performance Considerations:**

[Inference] These optimization strategies are commonly recommended but performance gains may vary by specific use case:

- Use `$match` early to reduce document volume
- Index fields used in `$lookup` local and foreign fields
- Limit `$lookup` results with pipeline stages
- Consider `$unwind` impact on document multiplication
- Use `$project` to reduce field transfer after joins

**Output Transformation Patterns:**

Flattening nested structures:

```javascript
{
  $replaceRoot: {
    newRoot: {
      $mergeObjects: [
        "$$ROOT",
        "$embeddedDocument"
      ]
    }
  }
}
```

Creating summary documents:

```javascript
{
  $addFields: {
    summary: {
      totalOrders: { $size: "$orders" },
      avgOrderValue: { $avg: "$orders.amount" },
      lastOrderDate: { $max: "$orders.date" }
    }
  }
}
```

These advanced aggregation stages enable sophisticated data transformation and analysis workflows. The combination of `$group` for aggregation, `$unwind` for array processing, `$lookup` for cross-collection analysis, and field manipulation operators provides comprehensive tools for complex data operations.

**Related Topics:** Pipeline optimization strategies, index design for aggregation, memory usage in complex pipelines, aggregation expression operators, and time series aggregation patterns.

---

