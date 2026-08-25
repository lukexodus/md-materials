## Document Design Principles


Document design in MongoDB is fundamentally different from relational database design. Rather than normalizing data across multiple tables, MongoDB encourages embedding related data within documents to optimize for application access patterns. Effective document design balances query performance, data consistency, and storage efficiency while considering MongoDB's operational characteristics.

### Embedding vs Referencing

#### Embedding Documents

Embedding stores related data within the same document, creating a nested structure that can be retrieved in a single query.

**When to embed:**

- One-to-one relationships
- One-to-few relationships (typically fewer than 100 related items)
- Data that's frequently accessed together
- Related data that rarely changes independently
- When atomic updates across related data are required

**Example of embedding:**

```javascript
{
  _id: ObjectId("..."),
  name: "John Doe",
  email: "john@example.com",
  addresses: [
    {
      type: "home",
      street: "123 Main St",
      city: "New York",
      zipCode: "10001"
    },
    {
      type: "work",
      street: "456 Business Ave",
      city: "New York",
      zipCode: "10002"
    }
  ],
  profile: {
    bio: "Software developer with 10 years experience",
    skills: ["JavaScript", "MongoDB", "Node.js"],
    lastLogin: ISODate("2024-01-15T10:30:00Z")
  }
}
```

**Advantages of embedding:**

- Single query retrieval
- Better performance for read operations
- Atomic updates for related data
- Reduced complexity in application code
- Better data locality

**Disadvantages of embedding:**

- Document size growth over time
- Potential for unbounded arrays
- Data duplication if embedded data is referenced elsewhere
- More complex queries when accessing embedded data independently

#### Referencing Documents

Referencing stores related data in separate documents, linking them through identifiers similar to foreign keys in relational databases.

**When to reference:**

- One-to-many relationships with large numbers of related items
- Many-to-many relationships
- Data that changes frequently and independently
- Large related objects that would cause document size issues
- When different parts of the application access related data independently

**Example of referencing:**

```javascript
// Users collection
{
  _id: ObjectId("user1"),
  name: "John Doe",
  email: "john@example.com"
}

// Orders collection
{
  _id: ObjectId("order1"),
  userId: ObjectId("user1"),  // Reference to user
  orderDate: ISODate("2024-01-15T10:30:00Z"),
  items: [
    { productId: ObjectId("prod1"), quantity: 2, price: 25.99 },
    { productId: ObjectId("prod2"), quantity: 1, price: 15.50 }
  ],
  total: 67.48
}

// Products collection
{
  _id: ObjectId("prod1"),
  name: "Widget A",
  description: "High-quality widget",
  price: 25.99,
  category: "widgets"
}
```

**Advantages of referencing:**

- Prevents document size bloat
- Eliminates data duplication
- Flexibility in querying related data independently
- Better for frequently changing data
- Supports many-to-many relationships naturally

**Disadvantages of referencing:**

- Requires multiple queries or joins ($lookup)
- No atomic updates across referenced documents
- Potential for orphaned references
- Increased application complexity

#### Hybrid Approaches

Often, the best approach combines embedding and referencing based on specific use cases:

**Example - E-commerce order with mixed approach:**

```javascript
{
  _id: ObjectId("order1"),
  customerId: ObjectId("customer1"),  // Reference
  customerSnapshot: {  // Embedded snapshot
    name: "John Doe",
    email: "john@example.com"
  },
  items: [
    {
      productId: ObjectId("prod1"),  // Reference
      productSnapshot: {  // Embedded snapshot
        name: "Widget A",
        price: 25.99
      },
      quantity: 2,
      subtotal: 51.98
    }
  ],
  shipping: {  // Embedded
    address: "123 Main St, New York, NY 10001",
    method: "standard",
    cost: 5.99
  },
  total: 57.97,
  status: "shipped"
}
```

### Schema Design Patterns

#### Subset Pattern

Store frequently accessed data in the main document and less frequently accessed data in a separate collection.

**Example:**

```javascript
// Main product document
{
  _id: ObjectId("prod1"),
  name: "Professional Camera",
  price: 1299.99,
  category: "electronics",
  ratings: {
    average: 4.5,
    count: 127
  },
  topReviews: [  // Subset of most helpful reviews
    {
      rating: 5,
      comment: "Excellent image quality",
      helpful: 45
    }
  ]
}

// Detailed reviews collection
{
  _id: ObjectId("review1"),
  productId: ObjectId("prod1"),
  rating: 5,
  comment: "Excellent image quality and build",
  reviewer: "John D.",
  date: ISODate("2024-01-10T00:00:00Z"),
  helpful: 45,
  detailed_review: "Very long detailed review content..."
}
```

#### Computed Pattern

Pre-calculate and store frequently used aggregated values to improve query performance.

**Example:**

```javascript
// Order document with computed totals
{
  _id: ObjectId("order1"),
  customerId: ObjectId("customer1"),
  items: [
    { productId: ObjectId("prod1"), quantity: 2, price: 25.99 },
    { productId: ObjectId("prod2"), quantity: 1, price: 15.50 }
  ],
  // Computed fields
  itemCount: 2,
  subtotal: 67.48,
  tax: 6.75,
  shipping: 5.99,
  total: 80.22,
  lastModified: ISODate("2024-01-15T10:30:00Z")
}
```

#### Bucket Pattern

Group related documents together to optimize for time-series data or high-volume scenarios.

**Example - IoT sensor data:**

```javascript
{
  _id: ObjectId("bucket1"),
  sensorId: "sensor123",
  startTime: ISODate("2024-01-15T00:00:00Z"),
  endTime: ISODate("2024-01-15T01:00:00Z"),
  measurements: [
    { timestamp: ISODate("2024-01-15T00:00:00Z"), temperature: 22.5, humidity: 65 },
    { timestamp: ISODate("2024-01-15T00:01:00Z"), temperature: 22.6, humidity: 64 },
    // ... more measurements
  ],
  count: 60,
  averageTemp: 22.8,
  maxTemp: 24.1,
  minTemp: 21.9
}
```

#### Polymorphic Pattern

Store documents with similar but not identical structures in the same collection using a type field.

**Example:**

```javascript
// Different types of products in same collection
{
  _id: ObjectId("prod1"),
  type: "book",
  name: "MongoDB Guide",
  price: 29.99,
  author: "Jane Smith",
  isbn: "978-1234567890",
  pages: 350
}

{
  _id: ObjectId("prod2"),
  type: "electronics",
  name: "Wireless Headphones",
  price: 199.99,
  brand: "TechCorp",
  model: "WH-1000",
  warranty: "2 years"
}
```

### Denormalization Strategies

#### Selective Denormalization

Copy specific fields from referenced documents to avoid frequent joins while maintaining normalized source data.

**Example:**

```javascript
// Normalized approach (separate collections)
// Users: { _id, name, email, department }
// Tasks: { _id, title, assignedTo, dueDate }

// Denormalized approach
{
  _id: ObjectId("task1"),
  title: "Complete project documentation",
  assignedTo: ObjectId("user1"),
  assignedToName: "John Doe",  // Denormalized from users
  assignedToDepartment: "Engineering",  // Denormalized from users
  dueDate: ISODate("2024-02-01T00:00:00Z"),
  status: "in_progress"
}
```

#### Snapshot Pattern

Store point-in-time copies of data that might change in the source document.

**Example - Order with customer snapshot:**

```javascript
{
  _id: ObjectId("order1"),
  customerId: ObjectId("customer1"),
  customerAtOrderTime: {  // Snapshot of customer data
    name: "John Doe",
    email: "john@example.com",
    loyaltyLevel: "gold",
    discount: 0.1
  },
  orderDate: ISODate("2024-01-15T10:30:00Z"),
  items: [...],
  total: 67.48
}
```

#### Two-Way Referencing

Maintain references in both directions to optimize different query patterns.

**Example:**

```javascript
// Users collection
{
  _id: ObjectId("user1"),
  name: "John Doe",
  orders: [ObjectId("order1"), ObjectId("order2")]  // References to orders
}

// Orders collection
{
  _id: ObjectId("order1"),
  customerId: ObjectId("user1"),  // Reference to user
  items: [...],
  total: 67.48
}
```

### Document Size Limitations

#### Size Constraints

MongoDB enforces a maximum document size of 16MB (16,777,216 bytes). This limitation affects design decisions and requires careful consideration of data growth patterns.

**Factors contributing to document size:**

- Number and size of embedded arrays
- Length of string fields
- Number of fields in the document
- Nested document depth and complexity
- Binary data storage

#### Managing Document Growth

**Strategies to prevent size issues:**

**Array size monitoring:**

```javascript
// Problematic - unbounded array growth
{
  _id: ObjectId("user1"),
  name: "John Doe",
  activityLog: [  // Could grow indefinitely
    { action: "login", timestamp: ISODate("...") },
    // ... thousands of entries
  ]
}

// Better - use bucketing or separate collection
{
  _id: ObjectId("user1"),
  name: "John Doe",
  recentActivity: [  // Limited to last 50 activities
    { action: "login", timestamp: ISODate("...") }
  ]
}
```

**Field size management:**

```javascript
// Problematic - large text fields
{
  _id: ObjectId("article1"),
  title: "Article Title",
  content: "Very long article content..."  // Could be several MB
}

// Better - reference to GridFS or separate collection
{
  _id: ObjectId("article1"),
  title: "Article Title",
  contentId: ObjectId("content1"),  // Reference to content document
  summary: "Brief article summary..."
}
```

#### Best Practices for Size Management

**Monitor document sizes:**

```javascript
// Check document size
db.collection.find().forEach(
  function(doc) {
    print(Object.bsonsize(doc) + " bytes");
  }
)
```

**Design for growth patterns:**

- Anticipate how arrays and embedded documents will grow
- Set practical limits on array sizes
- Use separate collections for large, optional data
- Consider GridFS for files larger than 16MB

**Use appropriate data types:**

- Choose compact data types when possible
- Store dates as Date objects rather than strings
- Use appropriate numeric types based on value ranges

### Atomic Operations

#### Document-Level Atomicity

MongoDB guarantees atomicity at the document level, meaning all changes to a single document either succeed or fail together.

**Atomic update example:**

```javascript
// All these changes happen atomically
db.accounts.updateOne(
  { _id: ObjectId("account1") },
  {
    $inc: { balance: -100 },
    $push: { 
      transactions: {
        type: "withdrawal",
        amount: 100,
        timestamp: new Date()
      }
    },
    $set: { lastActivity: new Date() }
  }
)
```

#### Multi-Document Transactions

MongoDB supports ACID transactions across multiple documents and collections (in replica sets and sharded clusters).

**Transaction example:**

```javascript
const session = client.startSession();

try {
  await session.withTransaction(async () => {
    // Transfer money between accounts
    await accounts.updateOne(
      { _id: ObjectId("account1") },
      { $inc: { balance: -100 } },
      { session }
    );
    
    await accounts.updateOne(
      { _id: ObjectId("account2") },
      { $inc: { balance: 100 } },
      { session }
    );
    
    await transactions.insertOne({
      fromAccount: ObjectId("account1"),
      toAccount: ObjectId("account2"),
      amount: 100,
      timestamp: new Date()
    }, { session });
  });
} finally {
  await session.endSession();
}
```

#### Designing for Atomicity

**Embed related data for atomic updates:**

```javascript
// Good - atomic update of order and inventory
{
  _id: ObjectId("order1"),
  customerId: ObjectId("customer1"),
  items: [
    {
      productId: ObjectId("prod1"),
      quantity: 2,
      reserved: true,  // Can be updated atomically with order
      price: 25.99
    }
  ],
  status: "confirmed",
  total: 51.98
}
```

**Use update operators effectively:**

```javascript
// Atomic increment and array modification
db.products.updateOne(
  { _id: ObjectId("prod1") },
  {
    $inc: { stock: -2, sold: 2 },
    $push: { 
      salesHistory: {
        quantity: 2,
        date: new Date(),
        orderId: ObjectId("order1")
      }
    }
  }
)
```

#### Conditional Updates

Use conditional updates to maintain consistency without transactions:

```javascript
// Update only if condition is met
result = db.products.updateOne(
  { 
    _id: ObjectId("prod1"),
    stock: { $gte: 2 }  // Only update if enough stock
  },
  {
    $inc: { stock: -2 },
    $push: { reservations: ObjectId("order1") }
  }
)

if (result.modifiedCount === 0) {
  // Handle insufficient stock
  throw new Error("Insufficient stock");
}
```

**Key points:**

- Design documents to minimize the need for multi-document transactions
- Embed data that needs to be updated together atomically
- Use appropriate update operators for complex atomic operations
- Consider using conditional updates for consistency without full transactions
- [Inference] Well-designed document structure can eliminate many scenarios where multi-document transactions would otherwise be necessary

**Related topics:** MongoDB indexing strategies for embedded documents, aggregation pipeline optimization, sharding considerations for document design, and performance implications of different schema patterns.

---

