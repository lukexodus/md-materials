## Advanced Indexing


### Multikey Indexes

Multikey indexes are automatically created when MongoDB indexes a field that contains array values. When a field contains an array, MongoDB creates index entries for each array element, enabling efficient queries on array contents.

MongoDB automatically detects array fields and creates multikey indexes without special syntax. The index structure accommodates multiple values per document, allowing queries to match any element within the array.

**Key points:**

- Created automatically when indexing array fields
- Each array element gets its own index entry
- Supports compound indexes with array fields
- [Inference] Query performance on array elements is similar to scalar field queries
- Cannot create compound multikey indexes on multiple array fields in the same document

**Example:**

```javascript
// Document with array field
db.products.insertOne({
  name: "Laptop",
  tags: ["electronics", "computers", "portable"],
  categories: ["tech", "office"]
})

// Create multikey index
db.products.createIndex({ tags: 1 })

// Efficient queries on array elements
db.products.find({ tags: "electronics" })
db.products.find({ tags: { $in: ["computers", "mobile"] } })
```

#### Multikey Index Limitations

Compound multikey indexes have specific restrictions to prevent exponential index entry growth. A compound index cannot be multikey on more than one field simultaneously.

**Key points:**

- Maximum one array field per compound index
- [Unverified] Index size grows proportionally to total array elements across all documents
- Array modifications require index updates for all affected elements
- Covered queries possible but limited by multikey nature

#### Query Optimization with Multikey Indexes

Multikey indexes support various query patterns including exact matches, range queries, and array-specific operators. Query planning considers multikey characteristics when selecting optimal execution paths.

**Example:**

```javascript
// Range queries on array elements
db.products.find({ ratings: { $gte: 4.0 } })

// Array size queries
db.products.find({ tags: { $size: 3 } })

// Element match queries
db.products.find({ 
  reviews: { 
    $elemMatch: { 
      rating: { $gte: 4 }, 
      verified: true 
    } 
  } 
})
```

### Text Indexes

Text indexes enable full-text search capabilities within MongoDB collections. They tokenize string content, remove stop words, and support linguistic features like stemming for various languages.

Text indexes analyze string fields and create searchable tokens from the content. MongoDB supports language-specific text processing, including stemming, case-insensitivity, and diacritic-insensitivity.

**Key points:**

- Support full-text search with ranking and scoring
- Language-specific processing including stemming
- Case and diacritic insensitive by default
- Only one text index allowed per collection
- Can include multiple fields in a single text index

**Example:**

```javascript
// Create text index on multiple fields
db.articles.createIndex({
  title: "text",
  content: "text",
  tags: "text"
})

// Text search queries
db.articles.find({ $text: { $search: "mongodb database" } })

// Search with phrases
db.articles.find({ $text: { $search: "\"advanced indexing\"" } })

// Language-specific search
db.articles.find({ $text: { $search: "bases de datos", $language: "spanish" } })
```

#### Text Search Features

Text indexes provide sophisticated search capabilities including phrase matching, term exclusion, and relevance scoring. The search functionality includes logical operations and result ranking.

**Key points:**

- Phrase searches using quoted strings
- Term exclusion with minus operator
- Relevance scoring with `$meta: "textScore"`
- Logical AND behavior for multiple terms
- [Inference] Search performance scales with index size and query complexity

**Example:**

```javascript
// Complex text search with scoring
db.articles.find(
  { $text: { $search: "mongodb -mysql" } },
  { score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } })

// Case sensitivity override
db.articles.find({ 
  $text: { 
    $search: "MongoDB", 
    $caseSensitive: true 
  } 
})
```

#### Text Index Configuration

Text indexes support various configuration options for language processing, field weighting, and search behavior customization.

**Example:**

```javascript
// Weighted text index
db.articles.createIndex(
  {
    title: "text",
    content: "text"
  },
  {
    weights: {
      title: 10,
      content: 5
    },
    default_language: "english",
    language_override: "lang"
  }
)
```

### Geospatial Indexes

MongoDB provides two types of geospatial indexes for location-based queries: 2d indexes for flat surfaces and 2dsphere indexes for spherical surfaces like Earth.

#### 2dsphere Indexes

2dsphere indexes support queries on spherical surfaces using GeoJSON objects or legacy coordinate pairs. They enable proximity queries, containment checks, and intersection operations on Earth-like spheres.

**Key points:**

- Support GeoJSON Point, LineString, Polygon geometries
- Enable spherical geometry calculations
- Support compound indexes with non-geospatial fields
- [Inference] Query performance depends on geographic data density and query area size

**Example:**

```javascript
// Create 2dsphere index
db.places.createIndex({ location: "2dsphere" })

// GeoJSON Point document
db.places.insertOne({
  name: "Coffee Shop",
  location: {
    type: "Point",
    coordinates: [-73.97, 40.77]  // [longitude, latitude]
  }
})

// Near queries
db.places.find({
  location: {
    $near: {
      $geometry: {
        type: "Point",
        coordinates: [-73.98, 40.75]
      },
      $maxDistance: 1000  // meters
    }
  }
})
```

#### 2d Indexes

2d indexes work with flat, Euclidean surfaces and legacy coordinate pairs. They're suitable for applications that don't require spherical calculations.

**Key points:**

- Support legacy coordinate pairs [x, y]
- Assume flat surface geometry
- Limited to coordinates within specified bounds
- [Unverified] May have different performance characteristics compared to 2dsphere

**Example:**

```javascript
// Create 2d index with bounds
db.locations.createIndex({ coordinates: "2d" }, { min: -180, max: 180 })

// Legacy coordinate format
db.locations.insertOne({
  name: "Store",
  coordinates: [-73.97, 40.77]
})

// Box queries
db.locations.find({
  coordinates: {
    $geoWithin: {
      $box: [[-74, 40.5], [-73.5, 41]]
    }
  }
})
```

#### Geospatial Query Operations

Both index types support various query operations for different spatial relationship requirements.

**Key points:**

- `$near` and `$nearSphere` for proximity queries
- `$geoWithin` for containment queries
- `$geoIntersects` for intersection queries (2dsphere only)
- Support for complex polygon boundaries
- [Inference] Query optimization varies based on geometry complexity

### Sparse and Partial Indexes

#### Sparse Indexes

Sparse indexes include only documents that contain the indexed field, excluding documents where the field is missing or null. This reduces index size and improves performance for optional fields.

**Key points:**

- Index only documents with the indexed field present
- Exclude documents with null or missing values
- Reduce index storage requirements
- [Inference] Query behavior differs when field is absent vs. null

**Example:**

```javascript
// Create sparse index
db.users.createIndex({ email: 1 }, { sparse: true })

// Documents without email field won't be indexed
db.users.insertMany([
  { name: "John", email: "john@example.com" },
  { name: "Jane" },  // Not indexed due to missing email
  { name: "Bob", email: null }  // Not indexed due to null email
])

// Query will only return documents with email field
db.users.find({ email: { $exists: true } })
```

#### Partial Indexes

Partial indexes include only documents that meet specified filter criteria, providing more granular control than sparse indexes. They enable indexing based on complex conditions beyond field presence.

**Key points:**

- Index documents matching specified filter expression
- Support complex filtering conditions
- Reduce index size more precisely than sparse indexes
- [Inference] Query planner must ensure queries match partial index filter

**Example:**

```javascript
// Create partial index for active users only
db.users.createIndex(
  { email: 1 },
  { 
    partialFilterExpression: { 
      status: "active",
      age: { $gte: 18 }
    }
  }
)

// Only active users 18+ will be indexed
db.users.insertMany([
  { email: "adult@example.com", status: "active", age: 25 },  // Indexed
  { email: "minor@example.com", status: "active", age: 16 },  // Not indexed
  { email: "inactive@example.com", status: "inactive", age: 30 }  // Not indexed
])
```

#### Sparse vs Partial Index Comparison

Understanding the differences between sparse and partial indexes helps choose the appropriate indexing strategy for specific use cases.

**Key points:**

- Sparse indexes focus on field presence
- Partial indexes support complex filtering logic
- Partial indexes offer more precise control
- [Inference] Partial indexes may provide better selectivity for specific query patterns

### TTL (Time To Live) Indexes

TTL indexes automatically delete documents after a specified time period, enabling automatic data expiration for use cases like session management, log rotation, and cache invalidation.

TTL indexes work on Date fields or arrays containing Date values. MongoDB runs a background process approximately every 60 seconds to remove expired documents.

**Key points:**

- Automatic document deletion based on time
- Work with Date fields or Date arrays
- Background deletion process runs every ~60 seconds
- Can specify expiration time in seconds
- [Unverified] Deletion timing may vary based on system load

**Example:**

```javascript
// Create TTL index - documents expire after 24 hours
db.sessions.createIndex({ createdAt: 1 }, { expireAfterSeconds: 86400 })

// Insert document with timestamp
db.sessions.insertOne({
  userId: "user123",
  sessionData: { ... },
  createdAt: new Date()
})

// Document will be automatically deleted after 24 hours
```

#### TTL Index Configuration

TTL behavior can be customized through various configuration options and document field structures.

**Key points:**

- `expireAfterSeconds` defines expiration period
- Can modify TTL value using `collMod` command
- Documents with future dates won't expire until that time
- [Inference] TTL cleanup may experience delays during high system load

**Example:**

```javascript
// Modify existing TTL index
db.runCommand({
  collMod: "sessions",
  index: {
    keyPattern: { createdAt: 1 },
    expireAfterSeconds: 172800  // Change to 48 hours
  }
})

// TTL with expiration date in document
db.events.createIndex({ expiry: 1 }, { expireAfterSeconds: 0 })
db.events.insertOne({
  title: "Limited Time Event",
  expiry: new Date("2024-12-31T23:59:59Z")
})
```

#### TTL Index Limitations

TTL indexes have specific constraints and behaviors that affect their applicability in different scenarios.

**Key points:**

- Cannot be compound indexes
- Must be on Date field or Date array
- Cannot guarantee exact deletion timing
- [Unverified] Performance impact during bulk deletions may affect other operations
- Deleted documents may still appear briefly after expiration

**Conclusion:** Advanced indexing strategies in MongoDB provide specialized solutions for complex data access patterns. Multikey indexes enable efficient array queries, text indexes support full-text search, geospatial indexes handle location-based operations, sparse and partial indexes optimize storage for specific datasets, and TTL indexes automate data lifecycle management. Each index type serves distinct use cases and requires careful consideration of performance, storage, and query pattern requirements.

---

