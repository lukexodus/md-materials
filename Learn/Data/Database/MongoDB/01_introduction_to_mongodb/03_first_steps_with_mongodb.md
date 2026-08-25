## First Steps with MongoDB


MongoDB is a NoSQL document database that stores data in flexible, JSON-like documents called BSON (Binary JSON). Unlike traditional relational databases that use tables and rows, MongoDB organizes data in collections of documents, making it particularly well-suited for applications that handle varied or evolving data structures.

### Installing MongoDB

Before connecting to MongoDB, you need to have it installed. MongoDB offers several deployment options including MongoDB Community Server for local development, MongoDB Atlas for cloud hosting, and MongoDB Enterprise for production environments.

For local development, you can download MongoDB Community Server from the official website and install it according to your operating system's instructions. The installation typically includes the MongoDB server (mongod), the MongoDB shell (mongosh), and various utilities.

### Connecting to MongoDB

#### Using MongoDB Shell (mongosh)

The MongoDB shell is the primary command-line interface for interacting with MongoDB. After installation, you can connect to a local MongoDB instance using:

```bash
mongosh
```

For remote connections or specific configurations:

```bash
mongosh "mongodb://localhost:27017"
mongosh "mongodb+srv://username:password@cluster.mongodb.net/database"
```

#### Connection Strings

MongoDB uses connection strings (URIs) to specify connection details. The basic format is:

```
mongodb://[username:password@]host[:port][/database][?options]
```

**Key components:**

- Protocol: `mongodb://` for standard connections, `mongodb+srv://` for DNS seedlist connections
- Authentication: Optional username and password
- Host and port: Server location (default port is 27017)
- Database: Target database name
- Options: Additional connection parameters

#### Programming Language Drivers

MongoDB provides official drivers for major programming languages:

**Node.js:**

```javascript
const { MongoClient } = require('mongodb');
const client = new MongoClient('mongodb://localhost:27017');
await client.connect();
```

**Python:**

```python
from pymongo import MongoClient
client = MongoClient('mongodb://localhost:27017')
```

**Java:**

```java
MongoClient mongoClient = MongoClients.create("mongodb://localhost:27017");
```

### Understanding Databases and Collections

#### Database Structure

MongoDB organizes data hierarchically:

- **Server**: The MongoDB instance
- **Database**: A container for collections
- **Collection**: A group of documents (equivalent to tables in SQL)
- **Document**: Individual records stored as BSON

#### Creating and Using Databases

Databases are created implicitly when you first store data in them:

```javascript
use myDatabase  // Switches to or creates database
```

You can list databases with:

```javascript
show dbs  // Shows only databases with data
```

#### Collections

Collections are created automatically when you insert the first document. Unlike SQL tables, collections don't require a predefined schema, allowing documents within the same collection to have different structures.

**Creating collections explicitly:**

```javascript
db.createCollection("users")
db.createCollection("products", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "price"],
      properties: {
        name: { bsonType: "string" },
        price: { bsonType: "number" }
      }
    }
  }
})
```

**Listing collections:**

```javascript
show collections
```

### Basic CRUD Operations Overview

CRUD operations form the foundation of database interactions: Create, Read, Update, and Delete.

#### Create Operations

**Insert single document:**

```javascript
db.users.insertOne({
  name: "John Doe",
  email: "john@example.com",
  age: 30
})
```

**Insert multiple documents:**

```javascript
db.users.insertMany([
  { name: "Alice", email: "alice@example.com", age: 25 },
  { name: "Bob", email: "bob@example.com", age: 35 }
])
```

#### Read Operations

**Find all documents:**

```javascript
db.users.find()
```

**Find with conditions:**

```javascript
db.users.find({ age: { $gte: 30 } })  // Users 30 or older
db.users.findOne({ email: "john@example.com" })  // Single document
```

**Projection (selecting specific fields):**

```javascript
db.users.find({}, { name: 1, email: 1, _id: 0 })
```

#### Update Operations

**Update single document:**

```javascript
db.users.updateOne(
  { name: "John Doe" },
  { $set: { age: 31 } }
)
```

**Update multiple documents:**

```javascript
db.users.updateMany(
  { age: { $lt: 30 } },
  { $set: { status: "young" } }
)
```

**Replace entire document:**

```javascript
db.users.replaceOne(
  { name: "John Doe" },
  { name: "John Doe", email: "newemail@example.com", age: 31 }
)
```

#### Delete Operations

**Delete single document:**

```javascript
db.users.deleteOne({ name: "John Doe" })
```

**Delete multiple documents:**

```javascript
db.users.deleteMany({ age: { $lt: 18 } })
```

### Working with Documents

#### Document Structure

MongoDB documents are BSON objects that can contain:

- Field-value pairs
- Nested documents (subdocuments)
- Arrays
- Various data types

**Example document:**

```javascript
{
  _id: ObjectId("..."),
  name: "John Doe",
  contact: {
    email: "john@example.com",
    phone: "+1234567890"
  },
  hobbies: ["reading", "swimming", "coding"],
  createdAt: new Date(),
  isActive: true
}
```

#### Document Limitations

- Maximum document size: 16MB
- Field names cannot start with `$` or contain `.` (except in specific contexts)
- The `_id` field is required and must be unique within the collection

#### Querying Nested Documents

**Dot notation for nested fields:**

```javascript
db.users.find({ "contact.email": "john@example.com" })
```

**Array elements:**

```javascript
db.users.find({ hobbies: "reading" })  // Documents where hobbies array contains "reading"
db.users.find({ "hobbies.0": "reading" })  // First hobby is "reading"
```

#### Update Operators

**Field update operators:**

- `$set`: Sets field values
- `$unset`: Removes fields
- `$inc`: Increments numeric values
- `$mul`: Multiplies numeric values
- `$rename`: Renames fields

**Array update operators:**

- `$push`: Adds elements to arrays
- `$pull`: Removes elements from arrays
- `$addToSet`: Adds unique elements to arrays
- `$pop`: Removes first or last array element

**Examples:**

```javascript
db.users.updateOne(
  { name: "John Doe" },
  {
    $set: { "contact.phone": "+0987654321" },
    $push: { hobbies: "photography" },
    $inc: { loginCount: 1 }
  }
)
```

### MongoDB Data Types

MongoDB supports rich data types through BSON specification:

#### Basic Types

**String:** UTF-8 encoded text

```javascript
{ name: "John Doe" }
```

**Number:** Various numeric types

```javascript
{ 
  age: 30,                    // 32-bit integer
  salary: NumberLong("50000"), // 64-bit integer
  rating: 4.5                 // Double
}
```

**Boolean:** True/false values

```javascript
{ isActive: true }
```

**Null:** Represents null values

```javascript
{ middleName: null }
```

#### Complex Types

**ObjectId:** 12-byte identifier (default for _id field)

```javascript
{ _id: ObjectId("507f1f77bcf86cd799439011") }
```

**Date:** Date and time values

```javascript
{ 
  createdAt: new Date(),
  birthDate: ISODate("1990-01-15T00:00:00Z")
}
```

**Array:** Ordered list of values

```javascript
{ 
  tags: ["mongodb", "database", "nosql"],
  scores: [85, 92, 78]
}
```

**Embedded Document (Object):** Nested document structure

```javascript
{
  address: {
    street: "123 Main St",
    city: "New York",
    zipCode: "10001"
  }
}
```

#### Specialized Types

**Binary Data:** For storing binary data

```javascript
{ profileImage: BinData(0, "base64encodeddata") }
```

**Regular Expression:** Pattern matching

```javascript
{ pattern: /^[a-zA-Z]+$/ }
```

**JavaScript Code:** Executable JavaScript

```javascript
{ formula: function(x) { return x * 2; } }
```

**Decimal128:** High-precision decimal numbers

```javascript
{ price: NumberDecimal("19.99") }
```

#### Type Checking and Conversion

You can query by data type using the `$type` operator:

```javascript
db.collection.find({ age: { $type: "number" } })
db.collection.find({ _id: { $type: "objectId" } })
```

**Key points:**

- MongoDB automatically converts compatible types in some operations
- Type coercion behavior may vary between operations
- Explicit type specification is recommended for precise control
- Different numeric types (int, long, double) are treated as separate types

#### Best Practices for Data Types

Choose appropriate data types based on your use case:

- Use ObjectId for unique identifiers unless you have specific requirements
- Store dates as Date objects rather than strings for proper sorting and range queries
- Use embedded documents for related data that's typically accessed together
- Consider array size limitations and query patterns when designing array fields
- Use appropriate numeric types based on value ranges and precision requirements

**Related topics you might want to explore:** MongoDB indexing strategies, aggregation framework, schema design patterns, and performance optimization techniques.

---

