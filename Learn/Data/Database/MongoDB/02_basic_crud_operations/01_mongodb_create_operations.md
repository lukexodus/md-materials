## MongoDB Create Operations


### insertOne() Method

The `insertOne()` method adds a single document to a MongoDB collection. It returns a result object containing the inserted document's `_id` and acknowledgment status.

**Basic Syntax:**

```javascript
db.collection.insertOne(document, options)
```

**Key Points:**

- Automatically generates an `_id` field if not provided
- Returns an `InsertOneResult` object
- Validates document structure before insertion
- Atomic operation at the document level

**Example:**

```javascript
// Insert a single user document
const result = await db.users.insertOne({
  name: "John Doe",
  email: "john.doe@example.com",
  age: 30,
  createdAt: new Date()
});

console.log(result.insertedId); // ObjectId of inserted document
console.log(result.acknowledged); // true if operation was acknowledged
```

### insertMany() Method

The `insertMany()` method inserts multiple documents in a single operation, providing better performance than multiple `insertOne()` calls.

**Basic Syntax:**

```javascript
db.collection.insertMany(documents, options)
```

**Key Points:**

- Accepts an array of documents
- More efficient than multiple single inserts
- Can be ordered or unordered
- Returns an `InsertManyResult` object with inserted IDs

**Example:**

```javascript
// Insert multiple products
const products = [
  { name: "Laptop", price: 999.99, category: "Electronics" },
  { name: "Mouse", price: 29.99, category: "Electronics" },
  { name: "Desk", price: 199.99, category: "Furniture" }
];

const result = await db.products.insertMany(products);
console.log(result.insertedIds); // Object with insertion order as keys
console.log(result.insertedCount); // Number of documents inserted
```

### Document Structure Best Practices

#### Schema Design Principles

**Embed vs Reference Decision Making:**

- Embed related data that is frequently accessed together
- Reference data that grows unbounded or is shared across documents
- Consider the 16MB document size limit

**Example:**

```javascript
// Good: Embedded structure for user profile
{
  _id: ObjectId("..."),
  username: "johndoe",
  profile: {
    firstName: "John",
    lastName: "Doe",
    address: {
      street: "123 Main St",
      city: "New York",
      zipCode: "10001"
    }
  },
  preferences: {
    theme: "dark",
    notifications: true
  }
}

// Good: Referenced structure for blog posts
{
  _id: ObjectId("..."),
  title: "MongoDB Best Practices",
  authorId: ObjectId("..."), // Reference to users collection
  tags: ["database", "mongodb", "nosql"],
  publishedAt: ISODate("2024-01-15T10:30:00Z")
}
```

#### Field Naming Conventions

**Key Points:**

- Use camelCase for field names
- Avoid dots, dollar signs, and null characters in field names
- Keep field names concise but descriptive
- Use consistent naming patterns across collections

**Example:**

```javascript
// Good field naming
{
  userId: ObjectId("..."),
  firstName: "John",
  lastName: "Doe",
  emailAddress: "john@example.com",
  isActive: true,
  lastLoginAt: ISODate("..."),
  accountSettings: {
    twoFactorEnabled: false,
    preferredLanguage: "en"
  }
}
```

#### Data Type Considerations

**Key Points:**

- Use appropriate BSON data types
- Store dates as ISODate objects, not strings
- Use NumberInt or NumberLong for specific numeric precision
- Consider using arrays for ordered lists and objects for key-value pairs

### Handling ObjectIds

#### Understanding ObjectIds

ObjectIds are 12-byte identifiers consisting of:

- 4-byte timestamp (creation time)
- 5-byte random unique value
- 3-byte incrementing counter

**Key Points:**

- Automatically generated if `_id` field is not provided
- Contain embedded timestamp information
- Globally unique across collections and databases
- Can be used for rough chronological ordering

**Example:**

```javascript
// Working with ObjectIds
const { ObjectId } = require('mongodb');

// Generate new ObjectId
const newId = new ObjectId();

// Create ObjectId from string
const specificId = new ObjectId("507f1f77bcf86cd799439011");

// Extract timestamp from ObjectId
const timestamp = specificId.getTimestamp();
console.log(timestamp); // Date object

// Insert document with custom ObjectId
await db.users.insertOne({
  _id: new ObjectId(),
  username: "testuser",
  email: "test@example.com"
});
```

#### Custom _id Fields

**Example:**

```javascript
// Using custom _id values
await db.products.insertOne({
  _id: "PROD-001", // String _id
  name: "Premium Widget",
  sku: "WIDGET-PREM"
});

await db.sessions.insertOne({
  _id: ObjectId(), // Explicit ObjectId
  userId: ObjectId("..."),
  token: "abc123...",
  expiresAt: new Date(Date.now() + 3600000)
});
```

### Bulk Insert Operations

#### Ordered vs Unordered Inserts

**Ordered Inserts** (default behavior):

- Process documents in sequence
- Stop on first error
- Maintain insertion order

**Unordered Inserts:**

- Process documents in parallel when possible
- Continue processing after errors
- Better performance for large datasets

**Example:**

```javascript
// Ordered bulk insert (default)
try {
  const result = await db.orders.insertMany([
    { orderId: "ORD-001", amount: 100.00 },
    { orderId: "ORD-002", amount: 75.50 },
    { orderId: "ORD-003", amount: 200.00 }
  ], { ordered: true });
} catch (error) {
  // Stops at first error
  console.log("Insert failed at:", error.writeErrors[0].index);
}

// Unordered bulk insert
try {
  const result = await db.orders.insertMany([
    { orderId: "ORD-004", amount: 150.00 },
    { orderId: "ORD-005", amount: 89.99 },
    { orderId: "ORD-006", amount: 300.00 }
  ], { ordered: false });
} catch (error) {
  // Continues processing despite individual errors
  console.log("Failed inserts:", error.writeErrors.length);
  console.log("Successful inserts:", error.result.insertedCount);
}
```

#### Bulk Write Operations

For more complex operations combining inserts, updates, and deletes:

**Example:**

```javascript
const bulkOps = [
  {
    insertOne: {
      document: { name: "Product A", price: 99.99 }
    }
  },
  {
    insertOne: {
      document: { name: "Product B", price: 149.99 }
    }
  },
  {
    updateOne: {
      filter: { name: "Product C" },
      update: { $set: { price: 199.99 } },
      upsert: true
    }
  }
];

const result = await db.products.bulkWrite(bulkOps, { ordered: false });
console.log("Inserted:", result.insertedCount);
console.log("Upserted:", result.upsertedCount);
```

### Error Handling in Inserts

#### Common Insert Errors

**Duplicate Key Errors:**

```javascript
try {
  await db.users.insertOne({
    _id: ObjectId("507f1f77bcf86cd799439011"), // Existing _id
    username: "duplicate"
  });
} catch (error) {
  if (error.code === 11000) {
    console.log("Duplicate key error:", error.keyPattern);
    console.log("Duplicate value:", error.keyValue);
  }
}
```

**Document Size Errors:**

```javascript
try {
  // Document exceeding 16MB limit
  const largeDocument = {
    data: "x".repeat(17 * 1024 * 1024) // 17MB string
  };
  await db.large.insertOne(largeDocument);
} catch (error) {
  if (error.code === 10334) {
    console.log("Document too large:", error.message);
  }
}
```

#### Comprehensive Error Handling

**Example:**

```javascript
async function insertUserSafely(userData) {
  try {
    // Validate required fields before insert
    if (!userData.email || !userData.username) {
      throw new Error("Email and username are required");
    }

    const result = await db.users.insertOne({
      ...userData,
      createdAt: new Date(),
      updatedAt: new Date()
    });

    return {
      success: true,
      insertedId: result.insertedId,
      message: "User created successfully"
    };

  } catch (error) {
    // Handle specific MongoDB errors
    if (error.code === 11000) {
      const field = Object.keys(error.keyPattern)[0];
      return {
        success: false,
        error: `${field} already exists`,
        code: "DUPLICATE_KEY"
      };
    }

    if (error.code === 121) {
      return {
        success: false,
        error: "Document validation failed",
        details: error.errInfo.details,
        code: "VALIDATION_ERROR"
      };
    }

    // Handle application-level errors
    if (error.message.includes("required")) {
      return {
        success: false,
        error: error.message,
        code: "MISSING_REQUIRED_FIELD"
      };
    }

    // Generic error handling
    console.error("Unexpected insert error:", error);
    return {
      success: false,
      error: "Failed to create user",
      code: "UNKNOWN_ERROR"
    };
  }
}
```

#### Batch Insert Error Handling

**Example:**

```javascript
async function insertProductsBatch(products) {
  try {
    const result = await db.products.insertMany(products, { 
      ordered: false,
      writeConcern: { w: "majority", j: true }
    });

    return {
      success: true,
      insertedCount: result.insertedCount,
      insertedIds: result.insertedIds
    };

  } catch (error) {
    // Handle bulk write errors
    if (error.writeErrors) {
      const successfulInserts = error.result.insertedCount;
      const failedInserts = error.writeErrors.length;

      const errors = error.writeErrors.map(writeError => ({
        index: writeError.index,
        document: products[writeError.index],
        error: writeError.errmsg,
        code: writeError.code
      }));

      return {
        success: false,
        partialSuccess: successfulInserts > 0,
        insertedCount: successfulInserts,
        failedCount: failedInserts,
        errors: errors,
        insertedIds: error.result.insertedIds
      };
    }

    // Handle other errors
    throw error;
  }
}
```

**Key Points:**

- Always handle duplicate key errors (code 11000) for unique indexes
- Use try-catch blocks for all insert operations
- Consider partial success scenarios with `insertMany()`
- Implement retry logic for transient network errors [Inference]
- Log errors appropriately for debugging and monitoring
- Validate data before insertion to prevent common errors
- Use write concerns for important data consistency requirements

**Important subtopics for deeper understanding:**

- MongoDB Transactions for multi-document ACID operations
- Index design strategies to optimize insert performance
- Sharding considerations for high-volume insert workloads
- Time series collections for time-stamped data insertion patterns

---

