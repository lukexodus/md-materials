## Complex Aggregation Operations


Complex aggregation operations in MongoDB provide powerful tools for sophisticated data analysis, multi-dimensional grouping, and hierarchical data processing. These operations extend beyond basic grouping and matching to enable advanced analytical workflows.

### $facet for Multiple Pipelines

The `$facet` stage allows execution of multiple aggregation pipelines within a single aggregation operation, enabling multi-dimensional analysis of the same dataset.

**Key Points:**

- Processes the same input documents through multiple sub-pipelines simultaneously
- Each sub-pipeline operates independently and produces its own output
- Results are combined into a single document with named fields for each facet
- Maximum of 100 sub-pipelines per `$facet` stage
- Each sub-pipeline can contain any aggregation stages except `$out`, `$merge`, `$facet`, `$lookup`, and `$graphLookup`

**Example:**

```javascript
db.sales.aggregate([
  {
    $facet: {
      "categorizeByPrice": [
        {
          $bucket: {
            groupBy: "$price",
            boundaries: [0, 50, 100, 200, 400],
            default: "Other",
            output: {
              "count": { $sum: 1 },
              "totalSales": { $sum: "$price" }
            }
          }
        }
      ],
      "categorizeByYear": [
        {
          $group: {
            _id: { $year: "$date" },
            count: { $sum: 1 },
            avgPrice: { $avg: "$price" }
          }
        },
        { $sort: { _id: 1 } }
      ],
      "topProducts": [
        { $group: { _id: "$product", totalSold: { $sum: 1 } } },
        { $sort: { totalSold: -1 } },
        { $limit: 3 }
      ]
    }
  }
])
```

**Output:**

```javascript
{
  "categorizeByPrice": [
    { "_id": [0, 50), "count": 15, "totalSales": 450 },
    { "_id": [50, 100), "count": 20, "totalSales": 1500 }
  ],
  "categorizeByYear": [
    { "_id": 2022, "count": 25, "avgPrice": 75.50 },
    { "_id": 2023, "count": 30, "avgPrice": 82.30 }
  ],
  "topProducts": [
    { "_id": "laptop", "totalSold": 12 },
    { "_id": "phone", "totalSold": 8 }
  ]
}
```

### $bucket and $bucketAuto for Categorization

These stages group documents into buckets based on specified criteria, enabling data categorization and distribution analysis.

#### $bucket Stage

Groups documents into user-defined buckets based on boundary values.

**Key Points:**

- Requires explicit boundary definitions
- Documents are grouped based on the `groupBy` expression value
- Boundaries must be specified in ascending order
- Documents with values outside boundaries go to the `default` bucket if specified
- Each bucket contains documents where `groupBy` value is greater than or equal to the lower boundary and less than the upper boundary

**Example:**

```javascript
db.students.aggregate([
  {
    $bucket: {
      groupBy: "$score",
      boundaries: [0, 60, 70, 80, 90, 100],
      default: "Other",
      output: {
        "count": { $sum: 1 },
        "students": { $push: "$name" },
        "avgScore": { $avg: "$score" },
        "minScore": { $min: "$score" },
        "maxScore": { $max: "$score" }
      }
    }
  }
])
```

#### $bucketAuto Stage

Automatically determines bucket boundaries to evenly distribute documents.

**Key Points:**

- MongoDB automatically calculates bucket boundaries
- Attempts to evenly distribute documents across buckets
- Useful when data distribution is unknown
- `buckets` parameter specifies the target number of buckets
- Uses a spline-based algorithm for boundary calculation

**Example:**

```javascript
db.products.aggregate([
  {
    $bucketAuto: {
      groupBy: "$price",
      buckets: 5,
      output: {
        "count": { $sum: 1 },
        "avgPrice": { $avg: "$price" },
        "products": { $push: "$name" }
      },
      granularity: "R20"
    }
  }
])
```

**Granularity Options:**

- R5, R10, R20, R40, R80 (Renard number series)
- 1-2-5 series
- E6, E12, E24, E48, E96, E192 (preferred numbers)
- POWERSOF2

### $graphLookup for Hierarchical Data

The `$graphLookup` stage performs recursive search on a collection, ideal for traversing hierarchical or graph-like data structures.

**Key Points:**

- Performs recursive queries to traverse connected data
- Can traverse multiple levels of relationships
- Supports both breadth-first and depth-first traversal
- Maximum recursion depth of 100 levels
- Can filter results at each recursion level using `restrictSearchWithMatch`

**Example:**

```javascript
// Employee hierarchy traversal
db.employees.aggregate([
  {
    $match: { name: "CEO" }
  },
  {
    $graphLookup: {
      from: "employees",
      startWith: "$_id",
      connectFromField: "_id",
      connectToField: "reportsTo",
      as: "allReports",
      maxDepth: 3,
      depthField: "level",
      restrictSearchWithMatch: { department: "Engineering" }
    }
  }
])
```

**Advanced $graphLookup with Multiple Conditions:**

```javascript
db.connections.aggregate([
  {
    $graphLookup: {
      from: "connections",
      pipeline: [
        { $match: { connectionType: "friend" } },
        { $project: { userId: 1, connections: 1, mutualFriends: 1 } }
      ],
      startWith: "$userId",
      connectFromField: "connections",
      connectToField: "userId",
      as: "networkPath",
      maxDepth: 2
    }
  }
])
```

### Aggregation Expressions and Operators

MongoDB provides extensive expression operators for data transformation, mathematical operations, conditional logic, and data type manipulation within aggregation pipelines.

#### Arithmetic Expressions

**Key Points:**

- Support standard mathematical operations
- Handle null values and missing fields gracefully
- Can be combined for complex calculations
- Support both numeric and date arithmetic

**Example:**

```javascript
db.orders.aggregate([
  {
    $project: {
      orderId: 1,
      totalAmount: {
        $multiply: [
          "$quantity",
          { $subtract: ["$unitPrice", "$discount"] }
        ]
      },
      taxAmount: {
        $multiply: [
          { $multiply: ["$quantity", "$unitPrice"] },
          "$taxRate"
        ]
      },
      profit: {
        $subtract: [
          { $multiply: ["$quantity", "$unitPrice"] },
          { $multiply: ["$quantity", "$cost"] }
        ]
      }
    }
  }
])
```

#### Conditional Expressions

Enable conditional logic within aggregation pipelines.

**Example:**

```javascript
db.students.aggregate([
  {
    $project: {
      name: 1,
      grade: {
        $switch: {
          branches: [
            { case: { $gte: ["$score", 90] }, then: "A" },
            { case: { $gte: ["$score", 80] }, then: "B" },
            { case: { $gte: ["$score", 70] }, then: "C" },
            { case: { $gte: ["$score", 60] }, then: "D" }
          ],
          default: "F"
        }
      },
      status: {
        $cond: {
          if: { $gte: ["$score", 60] },
          then: "Pass",
          else: "Fail"
        }
      },
      bonus: {
        $ifNull: ["$extraCredit", 0]
      }
    }
  }
])
```

#### Array Expressions

Powerful operators for array manipulation and analysis.

**Example:**

```javascript
db.courses.aggregate([
  {
    $project: {
      courseName: 1,
      studentCount: { $size: "$enrolledStudents" },
      topScores: {
        $slice: [
          { $sortArray: { input: "$scores", sortBy: -1 } },
          3
        ]
      },
      hasHighAchiever: {
        $anyElementTrue: {
          $map: {
            input: "$scores",
            as: "score",
            in: { $gte: ["$$score", 95] }
          }
        }
      },
      avgScore: { $avg: "$scores" },
      uniqueGrades: {
        $setUnion: [
          {
            $map: {
              input: "$scores",
              as: "score",
              in: {
                $switch: {
                  branches: [
                    { case: { $gte: ["$$score", 90] }, then: "A" },
                    { case: { $gte: ["$$score", 80] }, then: "B" },
                    { case: { $gte: ["$$score", 70] }, then: "C" }
                  ],
                  default: "F"
                }
              }
            }
          },
          []
        ]
      }
    }
  }
])
```

#### String Expressions

Comprehensive string manipulation capabilities.

**Example:**

```javascript
db.users.aggregate([
  {
    $project: {
      fullName: {
        $concat: [
          { $toUpper: { $substr: ["$firstName", 0, 1] } },
          { $toLower: { $substr: ["$firstName", 1, -1] } },
          " ",
          { $toUpper: { $substr: ["$lastName", 0, 1] } },
          { $toLower: { $substr: ["$lastName", 1, -1] } }
        ]
      },
      emailDomain: {
        $arrayElemAt: [
          { $split: ["$email", "@"] },
          1
        ]
      },
      initials: {
        $concat: [
          { $substr: ["$firstName", 0, 1] },
          { $substr: ["$lastName", 0, 1] }
        ]
      },
      nameLength: {
        $add: [
          { $strLenCP: "$firstName" },
          { $strLenCP: "$lastName" }
        ]
      }
    }
  }
])
```

#### Date Expressions

Extensive date manipulation and extraction capabilities.

**Example:**

```javascript
db.events.aggregate([
  {
    $project: {
      eventName: 1,
      year: { $year: "$date" },
      month: { $month: "$date" },
      dayOfWeek: { $dayOfWeek: "$date" },
      quarter: {
        $switch: {
          branches: [
            { case: { $lte: [{ $month: "$date" }, 3] }, then: "Q1" },
            { case: { $lte: [{ $month: "$date" }, 6] }, then: "Q2" },
            { case: { $lte: [{ $month: "$date" }, 9] }, then: "Q3" }
          ],
          default: "Q4"
        }
      },
      daysFromToday: {
        $divide: [
          { $subtract: [new Date(), "$date"] },
          1000 * 60 * 60 * 24
        ]
      },
      formattedDate: {
        $dateToString: {
          format: "%Y-%m-%d %H:%M:%S",
          date: "$date",
          timezone: "America/New_York"
        }
      }
    }
  }
])
```

#### Type Conversion Expressions

Handle data type transformations within aggregation pipelines.

**Example:**

```javascript
db.mixed_data.aggregate([
  {
    $project: {
      numericValue: {
        $convert: {
          input: "$stringNumber",
          to: "double",
          onError: 0,
          onNull: 0
        }
      },
      dateValue: {
        $dateFromString: {
          dateString: "$dateString",
          format: "%Y-%m-%d",
          onError: new Date()
        }
      },
      booleanValue: {
        $toBool: "$status"
      },
      stringId: {
        $toString: "$_id"
      }
    }
  }
])
```

### Advanced Expression Combinations

Complex expressions can be combined to create sophisticated data transformations.

**Example:**

```javascript
db.sales.aggregate([
  {
    $project: {
      orderId: 1,
      performanceMetrics: {
        revenueCategory: {
          $switch: {
            branches: [
              { 
                case: { $gte: ["$revenue", 10000] }, 
                then: "High" 
              },
              { 
                case: { $gte: ["$revenue", 5000] }, 
                then: "Medium" 
              }
            ],
            default: "Low"
          }
        },
        profitMargin: {
          $multiply: [
            {
              $divide: [
                { $subtract: ["$revenue", "$cost"] },
                "$revenue"
              ]
            },
            100
          ]
        },
        seasonalAdjustment: {
          $multiply: [
            "$revenue",
            {
              $switch: {
                branches: [
                  { case: { $in: [{ $month: "$date" }, [11, 12, 1]] }, then: 1.2 },
                  { case: { $in: [{ $month: "$date" }, [6, 7, 8]] }, then: 0.9 }
                ],
                default: 1.0
              }
            }
          ]
        }
      }
    }
  }
])
```

**Conclusion:**

Complex aggregation operations provide MongoDB with enterprise-level analytical capabilities. The `$facet` stage enables multi-dimensional analysis, `$bucket` operations facilitate data categorization, `$graphLookup` handles hierarchical relationships, and extensive expression operators support sophisticated data transformations. These operations can be combined to create powerful analytical pipelines that handle complex business requirements and data analysis scenarios. [Inference] Understanding these operations is essential for building scalable data processing solutions that can handle diverse analytical requirements.

---

