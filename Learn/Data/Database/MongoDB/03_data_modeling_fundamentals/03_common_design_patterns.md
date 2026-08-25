## Common Design Patterns


### Embedded Documents Pattern

The embedded documents pattern stores related data within a single document rather than distributing it across multiple collections. This approach leverages MongoDB's rich document structure to maintain data locality and optimize read performance for frequently accessed information.

#### When to Use Embedded Documents

Embedded documents work best when related data exhibits a one-to-few relationship, where the embedded data is primarily accessed alongside the parent document. This pattern excels in scenarios where data has a clear containment relationship, such as user profiles with embedded addresses, blog posts with embedded comments, or product catalogs with embedded specifications.

The pattern provides optimal performance when the embedded data remains relatively stable in size and the application primarily performs read operations that benefit from retrieving all related information in a single query. [Inference] Applications that frequently update embedded arrays or nested documents may experience performance degradation due to document rewriting overhead.

**Example** of embedded documents:

```javascript
// User document with embedded addresses and preferences
{
  "_id": ObjectId("..."),
  "username": "johndoe",
  "email": "john@example.com",
  "addresses": [
    {
      "type": "home",
      "street": "123 Main St",
      "city": "Springfield",
      "state": "IL",
      "zipCode": "62701"
    },
    {
      "type": "work",
      "street": "456 Business Ave",
      "city": "Springfield",
      "state": "IL",
      "zipCode": "62702"
    }
  ],
  "preferences": {
    "newsletter": true,
    "notifications": {
      "email": true,
      "sms": false,
      "push": true
    },
    "privacy": {
      "profileVisible": true,
      "showEmail": false
    }
  }
}
```

#### Advantages and Limitations

Embedded documents provide atomic operations across all related data, as MongoDB guarantees atomicity at the document level. This eliminates the need for complex transaction handling when updating related information simultaneously. Single-query retrieval reduces network roundtrips and provides better read performance for complete entity access.

However, this pattern faces limitations with MongoDB's 16MB document size limit, though this rarely becomes an issue in practice. More significant concerns include potential data duplication when the same embedded information appears across multiple parent documents, and difficulty in querying embedded data independently without loading entire parent documents.

**Key points** for embedded documents include ensuring embedded data truly belongs to the parent entity, considering the frequency of independent access to embedded information, and monitoring document growth to avoid size limitations.

### Reference Pattern

The reference pattern stores related data in separate collections and maintains relationships through document identifiers, similar to foreign keys in relational databases. This approach provides data normalization and enables independent management of related entities.

#### Implementation Strategies

References can be implemented using MongoDB's ObjectId values or custom identifier schemes. One-to-one references store a single identifier field, while one-to-many references typically store arrays of identifiers. The choice between storing references in the parent document, child documents, or both depends on query patterns and cardinality.

**Example** of reference pattern implementation:

```javascript
// User document with references
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "username": "johndoe",
  "email": "john@example.com",
  "orderIds": [
    ObjectId("507f1f77bcf86cd799439012"),
    ObjectId("507f1f77bcf86cd799439013")
  ]
}

// Order documents in separate collection
{
  "_id": ObjectId("507f1f77bcf86cd799439012"),
  "userId": ObjectId("507f1f77bcf86cd799439011"),
  "orderDate": ISODate("2023-06-15"),
  "items": [...],
  "total": 299.99
}
```

#### Query Patterns and Population

Referenced data requires additional queries or aggregation operations to retrieve complete information. Applications can implement manual population by performing separate queries for referenced documents, or use MongoDB's aggregation framework with `$lookup` operations to join data from multiple collections.

**Example** of reference population:

```javascript
// Manual population approach
const user = db.users.findOne({username: "johndoe"});
const orders = db.orders.find({_id: {$in: user.orderIds}});

// Aggregation approach with $lookup
db.users.aggregate([
  {$match: {username: "johndoe"}},
  {
    $lookup: {
      from: "orders",
      localField: "orderIds",
      foreignField: "_id",
      as: "orders"
    }
  }
]);
```

#### Benefits and Trade-offs

The reference pattern enables data normalization, reducing storage requirements when the same information would otherwise be duplicated across multiple documents. It supports independent management of related entities, allowing specialized indexes and operations on each collection. This pattern scales well with large datasets where embedded documents would exceed size limitations.

[Inference] The primary trade-off involves increased query complexity and potential performance overhead from multiple database operations or complex aggregations. Applications must carefully manage referential integrity, as MongoDB doesn't enforce foreign key constraints automatically.

### Hybrid Approach

The hybrid approach combines embedded and referenced patterns within the same data model, optimizing for specific access patterns by embedding frequently accessed data while referencing less commonly needed information.

#### Strategic Data Placement

Successful hybrid implementations require analyzing data access patterns to determine optimal placement strategies. Frequently accessed data that exhibits strong cohesion with the parent entity benefits from embedding, while infrequently accessed or independently managed data works better as references.

**Example** of hybrid pattern:

```javascript
// Blog post with hybrid design
{
  "_id": ObjectId("..."),
  "title": "MongoDB Design Patterns",
  "content": "Full blog post content...",
  "author": {
    "name": "John Doe",
    "avatar": "avatar-url.jpg"
  },
  "metadata": {
    "publishDate": ISODate("2023-06-15"),
    "tags": ["mongodb", "database", "design"],
    "viewCount": 1250
  },
  "recentComments": [
    {
      "author": "Jane Smith",
      "text": "Great article!",
      "date": ISODate("2023-06-16")
    }
  ],
  "allCommentsRef": ObjectId("507f1f77bcf86cd799439015")
}

// Complete comments stored separately
{
  "_id": ObjectId("507f1f77bcf86cd799439015"),
  "postId": ObjectId("..."),
  "comments": [
    // All comments including recent ones
  ]
}
```

#### Access Pattern Optimization

The hybrid approach enables optimization for different access scenarios. Blog post listings might only need embedded author information and recent comments for preview purposes, while detailed post views can reference complete comment collections when needed. This reduces initial query payload while maintaining the ability to access comprehensive data.

**Key points** for hybrid patterns include identifying data access frequency, maintaining consistency between embedded and referenced versions of the same data, and designing clear rules for when to embed versus reference information.

### Polymorphic Pattern

The polymorphic pattern handles documents with varying structures within the same collection, accommodating different entity types that share common attributes while maintaining type-specific fields.

#### Type Discrimination Strategies

Polymorphic documents typically include a discriminator field that identifies the document type, enabling applications to handle different structures appropriately. This field can be a simple string identifier or a more complex structure that indicates subtype hierarchies.

**Example** of polymorphic pattern:

```javascript
// Base vehicle structure with type discrimination
{
  "_id": ObjectId("..."),
  "type": "car",
  "make": "Toyota",
  "model": "Camry",
  "year": 2023,
  "mileage": 15000,
  // Car-specific fields
  "doors": 4,
  "transmission": "automatic",
  "fuelType": "gasoline"
}

{
  "_id": ObjectId("..."),
  "type": "motorcycle",
  "make": "Honda",
  "model": "CBR600RR",
  "year": 2023,
  "mileage": 5000,
  // Motorcycle-specific fields
  "engineSize": 600,
  "biketype": "sport"
}

{
  "_id": ObjectId("..."),
  "type": "truck",
  "make": "Ford",
  "model": "F-150",
  "year": 2023,
  "mileage": 8000,
  // Truck-specific fields
  "bedLength": "6.5ft",
  "towingCapacity": 11000,
  "driveType": "4WD"
}
```

#### Querying Polymorphic Data

Applications can query polymorphic collections using type discriminators to filter specific entity types or query common fields across all types. Indexes on discriminator fields improve query performance when filtering by type.

**Example** of polymorphic queries:

```javascript
// Find all cars
db.vehicles.find({type: "car"});

// Find all vehicles by make (common field)
db.vehicles.find({make: "Toyota"});

// Find cars with specific transmission
db.vehicles.find({
  type: "car",
  transmission: "manual"
});

// Aggregation with type-specific processing
db.vehicles.aggregate([
  {
    $match: {year: {$gte: 2020}}
  },
  {
    $group: {
      _id: "$type",
      count: {$sum: 1},
      avgMileage: {$avg: "$mileage"}
    }
  }
]);
```

#### Schema Evolution Considerations

Polymorphic patterns facilitate schema evolution by allowing new document types to be added without affecting existing documents. However, applications must handle unknown or deprecated fields gracefully and maintain backward compatibility as schemas evolve.

[Inference] The polymorphic pattern works best when different entity types share significant common attributes and access patterns, but becomes cumbersome when types have little in common or require vastly different indexing strategies.

### Schema Versioning

Schema versioning manages document structure evolution over time, enabling applications to handle multiple schema versions simultaneously during migration periods and maintain backward compatibility.

#### Version Identification Strategies

Schema versions can be identified through explicit version fields in documents, implicit version detection based on field presence or structure, or collection-level versioning where different schema versions occupy separate collections.

**Example** of explicit schema versioning:

```javascript
// Version 1 user document
{
  "_id": ObjectId("..."),
  "schemaVersion": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "address": "123 Main St, Springfield, IL"
}

// Version 2 user document with structured address
{
  "_id": ObjectId("..."),
  "schemaVersion": 2,
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "addresses": [
    {
      "type": "home",
      "street": "123 Main St",
      "city": "Springfield",
      "state": "IL",
      "zipCode": "62701"
    }
  ]
}
```

#### Migration Strategies

Schema versioning enables various migration approaches, including lazy migration where documents are updated on access, batch migration for systematic version updates, and dual-write strategies during transition periods. The choice depends on application requirements, data volume, and acceptable downtime constraints.

**Example** of lazy migration logic:

```javascript
function getUser(userId) {
  const user = db.users.findOne({_id: userId});
  
  // Handle version 1 documents
  if (!user.schemaVersion || user.schemaVersion === 1) {
    // Convert to version 2 format
    const migratedUser = {
      ...user,
      schemaVersion: 2,
      firstName: user.name.split(' ')[0],
      lastName: user.name.split(' ')[1],
      addresses: [{
        type: "home",
        street: user.address.split(',')[0],
        city: user.address.split(',')[1].trim(),
        state: user.address.split(',')[2].trim()
      }]
    };
    
    // Remove old fields
    delete migratedUser.name;
    delete migratedUser.address;
    
    // Update document in database
    db.users.replaceOne({_id: userId}, migratedUser);
    
    return migratedUser;
  }
  
  return user;
}
```

#### Backward Compatibility Management

Effective schema versioning maintains backward compatibility by ensuring applications can handle multiple schema versions gracefully. This involves defensive programming practices, comprehensive testing across schema versions, and clear deprecation strategies for obsolete fields or structures.

**Key points** for schema versioning include planning version migration paths early in application design, maintaining comprehensive documentation of schema changes, implementing robust error handling for unexpected schema variations, and establishing clear policies for when to retire old schema versions.

#### Version Detection Patterns

Applications can detect schema versions through various mechanisms beyond explicit version fields. Field presence detection examines whether specific fields exist to infer schema versions, while structural analysis evaluates document shape and field types. These approaches enable implicit versioning when explicit version fields weren't included in original designs.

**Example** of implicit version detection:

```javascript
function detectUserSchemaVersion(user) {
  // Check for version 2 characteristics
  if (user.firstName && user.lastName && Array.isArray(user.addresses)) {
    return 2;
  }
  
  // Check for version 1 characteristics
  if (user.name && typeof user.address === 'string') {
    return 1;
  }
  
  // Unknown or newer version
  return user.schemaVersion || 'unknown';
}
```

**Conclusion**

MongoDB's design patterns provide flexible approaches for structuring data based on specific application requirements and access patterns. The embedded documents pattern optimizes for data locality and atomic operations, while the reference pattern enables normalization and independent entity management. Hybrid approaches combine the benefits of both patterns, and polymorphic patterns handle diverse document structures within single collections. Schema versioning ensures applications can evolve data structures over time while maintaining compatibility. [Inference] Successful MongoDB schema design requires careful analysis of data relationships, access patterns, and evolution requirements to select appropriate patterns that balance performance, maintainability, and scalability concerns.

---

