## Update and Delete Operations


### `updateOne()`, `updateMany()`, `replaceOne()`

#### `updateOne()` Method

The `updateOne()` method modifies a single document that matches the specified filter criteria. It updates only the first document found, even if multiple documents match the filter condition.

**Syntax:**

```javascript
db.collection.updateOne(filter, update, options)
```

**Example:**

```javascript
db.users.updateOne(
   { name: "John" },
   { $set: { age: 31, status: "active" } }
)
```

The method returns an object containing information about the operation, including `matchedCount`, `modifiedCount`, and `acknowledged` status. If no documents match the filter, `matchedCount` will be 0.

**Key points:**

- Updates only the first matching document
- Returns operation result with count information
- Preserves document structure except for modified fields
- Atomic operation at the document level

#### `updateMany()` Method

The `updateMany()` method updates all documents that match the specified filter criteria. This operation is useful for bulk updates across multiple documents.

**Example:**

```javascript
db.products.updateMany(
   { category: "electronics" },
   { $set: { discount: 0.15, updated: new Date() } }
)
```

The operation processes all matching documents and returns the total count of matched and modified documents. Large update operations may impact database performance and should be monitored in production environments.

**Performance considerations:**

- Large batch updates may require indexing on filter fields
- Consider using bulk operations for very large datasets
- Monitor operation duration and resource usage

#### `replaceOne()` Method

The `replaceOne()` method completely replaces a single document with a new document, maintaining only the `_id` field from the original document.

**Example:**

```javascript
db.users.replaceOne(
   { _id: ObjectId("507f1f77bcf86cd799439011") },
   {
      name: "Jane Smith",
      email: "jane@example.com",
      status: "premium",
      created: new Date()
   }
)
```

Unlike update operations that modify specific fields, `replaceOne()` removes all existing fields (except `_id`) and replaces them with the new document structure. This operation is useful for complete document restructuring.

**Key points:**

- Completely replaces document content
- Preserves the original `_id` value
- Removes fields not present in replacement document
- Useful for document schema migrations

### Update Operators: `$set`, `$unset`, `$inc`, `$push`, `$pull`

#### `$set` Operator

The `$set` operator modifies the value of existing fields or creates new fields if they don't exist. It's the most commonly used update operator for field modifications.

**Example:**

```javascript
db.users.updateOne(
   { username: "alice" },
   { 
      $set: { 
         email: "alice@newdomain.com",
         lastLogin: new Date(),
         preferences: { theme: "dark", notifications: true }
      }
   }
)
```

The `$set` operator can update nested fields using dot notation:

```javascript
db.users.updateOne(
   { _id: ObjectId("...") },
   { $set: { "address.city": "New York", "address.zipcode": "10001" } }
)
```

#### `$unset` Operator

The `$unset` operator removes specified fields from documents. The value assigned to `$unset` is typically an empty string, but any value works as the operator only cares about field presence.

**Example:**

```javascript
db.users.updateOne(
   { username: "bob" },
   { $unset: { tempField: "", oldPassword: "" } }
)
```

**Key points:**

- Completely removes fields from documents
- Cannot unset array elements by index
- Useful for schema cleanup and field removal
- Value assigned to field in `$unset` is ignored

#### `$inc` Operator

The `$inc` operator increments numeric field values by a specified amount. It can handle both positive and negative increment values.

**Example:**

```javascript
db.products.updateOne(
   { sku: "ABC123" },
   { $inc: { quantity: -5, views: 1, rating: 0.5 } }
)
```

The operator creates the field with the increment value if the field doesn't exist. It only works with numeric values and will produce an error if applied to non-numeric fields.

**Use cases:**

- Inventory management and stock updates
- Counter increments (views, likes, downloads)
- Score and rating adjustments
- Financial calculations

#### `$push` Operator

The `$push` operator appends values to array fields. If the field doesn't exist, it creates a new array with the specified value.

**Example:**

```javascript
db.users.updateOne(
   { _id: ObjectId("...") },
   { $push: { hobbies: "photography", tags: "premium" } }
)
```

Advanced `$push` operations with modifiers:

```javascript
db.students.updateOne(
   { name: "Alice" },
   { 
      $push: { 
         scores: { 
            $each: [85, 92, 78],
            $sort: -1,
            $slice: 5
         }
      }
   }
)
```

**Modifiers available:**

- `$each`: Add multiple values
- `$sort`: Sort array after insertion
- `$slice`: Limit array length
- `$position`: Insert at specific index

#### `$pull` Operator

The `$pull` operator removes array elements that match specified conditions. It can remove primitive values or objects based on field criteria.

**Example removing primitive values:**

```javascript
db.users.updateOne(
   { username: "charlie" },
   { $pull: { hobbies: "fishing", tags: { $in: ["old", "deprecated"] } } }
)
```

**Example removing objects from arrays:**

```javascript
db.orders.updateOne(
   { orderId: "ORD123" },
   { $pull: { items: { quantity: { $lte: 0 } } } }
)
```

### Array Update Operators

#### Positional Operator (`$`)

The positional operator `$` updates the first array element that matches the query condition. It's used when you need to update specific array elements without knowing their exact position.

**Example:**

```javascript
db.students.updateOne(
   { "grades.subject": "math" },
   { $set: { "grades.$.score": 95 } }
)
```

The `$` operator represents the position of the first matching array element. It can only be used when the array element is part of the query filter.

#### All Positional Operator (`$[]`)

The `$[]` operator updates all elements in an array field, regardless of their values or positions.

**Example:**

```javascript
db.products.updateOne(
   { _id: ObjectId("...") },
   { $inc: { "ratings.$[].helpful": 1 } }
)
```

#### Filtered Positional Operator (`$[<identifier>]`)

The filtered positional operator updates array elements that match specific conditions defined in the `arrayFilters` option.

**Example:**

```javascript
db.students.updateOne(
   { _id: ObjectId("...") },
   { $set: { "grades.$[elem].score": 100 } },
   { arrayFilters: [{ "elem.subject": "chemistry", "elem.score": { $lt: 85 } }] }
)
```

This approach provides precise control over which array elements get updated based on complex criteria.

#### `$addToSet` Operator

The `$addToSet` operator adds values to arrays only if they don't already exist, ensuring array uniqueness.

**Example:**

```javascript
db.users.updateOne(
   { username: "diana" },
   { $addToSet: { skills: "MongoDB", interests: { $each: ["AI", "ML", "Data Science"] } } }
)
```

**Key points:**

- Prevents duplicate values in arrays
- Works with primitive values and objects
- Can be combined with `$each` modifier for multiple values
- Useful for maintaining unique collections

#### `$pop` Operator

The `$pop` operator removes elements from the beginning or end of arrays.

**Example:**

```javascript
// Remove first element
db.logs.updateOne(
   { _id: ObjectId("...") },
   { $pop: { events: -1 } }
)

// Remove last element
db.logs.updateOne(
   { _id: ObjectId("...") },
   { $pop: { events: 1 } }
)
```

### `deleteOne()` and `deleteMany()`

#### `deleteOne()` Method

The `deleteOne()` method removes a single document that matches the specified filter criteria. It deletes only the first document found, even if multiple documents match the filter.

**Syntax:**

```javascript
db.collection.deleteOne(filter, options)
```

**Example:**

```javascript
db.users.deleteOne({ username: "inactiveUser" })
```

The method returns a result object containing `deletedCount` and `acknowledged` properties. The operation is atomic and removes the entire document from the collection.

**Key points:**

- Deletes only the first matching document
- Returns count of deleted documents (0 or 1)
- Cannot be undone without backup restoration
- Consider soft deletion for recoverable operations

#### `deleteMany()` Method

The `deleteMany()` method removes all documents that match the specified filter criteria. This operation is useful for bulk deletion based on common criteria.

**Example:**

```javascript
db.logs.deleteMany({ 
   timestamp: { $lt: new Date("2023-01-01") },
   level: "debug" 
})
```

Large deletion operations may impact database performance and should be performed during maintenance windows in production environments.

**Performance considerations:**

- Index filter fields for efficient document identification
- Consider batch deletion for very large datasets
- Monitor operation duration and lock acquisition
- Implement proper backup strategies before bulk deletions

#### Deletion with Complex Filters

Both deletion methods support complex filter expressions using MongoDB query operators:

**Example:**

```javascript
db.orders.deleteMany({
   $and: [
      { status: "cancelled" },
      { createdAt: { $lt: new Date("2023-06-01") } },
      { $or: [
         { refunded: true },
         { amount: { $eq: 0 } }
      ]}
   ]
})
```

### Upsert Operations

#### Understanding Upsert Behavior

Upsert operations combine update and insert functionality. If a document matching the filter exists, it gets updated; if no matching document exists, a new document is created with the filter criteria and update operations applied.

**Basic upsert syntax:**

```javascript
db.collection.updateOne(
   filter,
   update,
   { upsert: true }
)
```

#### Upsert with `updateOne()`

**Example:**

```javascript
db.counters.updateOne(
   { name: "pageViews" },
   { $inc: { count: 1 } },
   { upsert: true }
)
```

If a counter document exists, it increments the count. If no counter exists, it creates a new document with `name: "pageViews"` and `count: 1`.

#### Upsert Document Creation Logic

When creating new documents during upsert operations, MongoDB combines:

1. Fields from the filter criteria
2. Fields from the update operators
3. Generated `_id` field if not specified

**Example document creation:**

```javascript
db.users.updateOne(
   { email: "new@example.com" },
   { 
      $set: { 
         name: "New User",
         status: "pending",
         created: new Date()
      }
   },
   { upsert: true }
)
```

If no document with the specified email exists, MongoDB creates:

```javascript
{
   _id: ObjectId("..."),
   email: "new@example.com",
   name: "New User",
   status: "pending",
   created: ISODate("...")
}
```

#### Upsert with Complex Filters

Upsert operations work with complex filter expressions, but [Inference] the document creation logic may become complex when filters contain operators like `$or`, `$and`, or comparison operators.

**Example:**

```javascript
db.inventory.updateOne(
   { sku: "ITEM001", warehouse: "NYC" },
   { 
      $inc: { quantity: 50 },
      $set: { lastUpdated: new Date() }
   },
   { upsert: true }
)
```

#### Use Cases for Upsert Operations

**Common scenarios:**

- Maintaining counters and statistics
- User profile creation and updates
- Inventory management systems
- Configuration and settings storage
- Time-series data aggregation

**Key points:**

- Atomic operation preventing race conditions
- Efficient for scenarios with uncertain document existence
- Reduces application logic complexity
- Useful for idempotent operations

#### Upsert Return Values

Upsert operations return result objects with additional information:

```javascript
{
   acknowledged: true,
   matchedCount: 0,
   modifiedCount: 0,
   upsertedCount: 1,
   upsertedId: ObjectId("...")
}
```

The `upsertedId` field contains the `_id` of the newly created document when an insert occurs during the upsert operation.

---

