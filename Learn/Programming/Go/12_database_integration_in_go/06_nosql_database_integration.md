## NoSQL Database Integration


Go's NoSQL database integration varies significantly across different database types, with most NoSQL databases providing dedicated Go drivers rather than using a unified interface like SQL databases.

### MongoDB Integration

MongoDB uses official Go driver with rich feature set.

**Connection and Basic Operations**

```go
import "go.mongodb.org/mongo-driver/mongo"

client, err := mongo.Connect(ctx, options.Client().ApplyURI("mongodb://localhost:27017"))
if err != nil {
    return err
}
defer client.Disconnect(ctx)

collection := client.Database("mydb").Collection("users")

// Insert document
result, err := collection.InsertOne(ctx, bson.M{"name": "Alice", "age": 30})

// Find documents
cursor, err := collection.Find(ctx, bson.M{"age": bson.M{"$gte": 18}})
if err != nil {
    return err
}
defer cursor.Close(ctx)

for cursor.Next(ctx) {
    var user User
    if err := cursor.Decode(&user); err != nil {
        return err
    }
    // Process user
}
```

**Advanced Features**

- Aggregation pipelines
- Change streams for real-time updates
- GridFS for file storage
- Transactions (replica sets/sharded clusters)
- Index management

### Redis Integration

Redis integration typically uses go-redis or redigo libraries.

**go-redis Usage**

```go
import "github.com/go-redis/redis/v8"

rdb := redis.NewClient(&redis.Options{
    Addr:     "localhost:6379",
    Password: "",
    DB:       0,
})

// String operations
err := rdb.Set(ctx, "key", "value", time.Hour).Err()
val, err := rdb.Get(ctx, "key").Result()

// Hash operations
err = rdb.HSet(ctx, "user:1", "name", "Alice", "age", 30).Err()
fields, err := rdb.HGetAll(ctx, "user:1").Result()

// List operations
err = rdb.RPush(ctx, "queue", "item1", "item2").Err()
item, err := rdb.LPop(ctx, "queue").Result()
```

**Redis Patterns**

- Caching layer implementation
- Session storage
- Rate limiting with sliding windows
- Pub/Sub messaging
- Distributed locking

### Elasticsearch Integration

Elasticsearch integration uses official elastic/go-elasticsearch client.

**Basic Operations**

```go
import "github.com/elastic/go-elasticsearch/v8"

es, err := elasticsearch.NewDefaultClient()
if err != nil {
    return err
}

// Index document
res, err := es.Index(
    "my-index",
    strings.NewReader(`{"title": "Go Programming", "author": "John Doe"}`),
    es.Index.WithDocumentID("1"),
)

// Search documents
res, err = es.Search(
    es.Search.WithIndex("my-index"),
    es.Search.WithBody(strings.NewReader(`{
        "query": {
            "match": {
                "title": "Go"
            }
        }
    }`)),
)
```

### Cassandra Integration

Cassandra uses gocql driver for CQL operations.

**Connection and Operations**

```go
import "github.com/gocql/gocql"

cluster := gocql.NewCluster("localhost")
cluster.Keyspace = "mykeyspace"
session, err := cluster.CreateSession()
if err != nil {
    return err
}
defer session.Close()

// Insert data
err = session.Query("INSERT INTO users (id, name, email) VALUES (?, ?, ?)",
    gocql.TimeUUID(), "Alice", "alice@example.com").Exec()

// Query data
var id gocql.UUID
var name, email string
iter := session.Query("SELECT id, name, email FROM users WHERE name = ?", "Alice").Iter()
for iter.Scan(&id, &name, &email) {
    // Process row
}
if err := iter.Close(); err != nil {
    return err
}
```

### DynamoDB Integration

AWS DynamoDB integration uses AWS SDK for Go.

**Basic Operations**

```go
import "github.com/aws/aws-sdk-go/service/dynamodb"

svc := dynamodb.New(session.Must(session.NewSession()))

// Put item
_, err := svc.PutItem(&dynamodb.PutItemInput{
    TableName: aws.String("Users"),
    Item: map[string]*dynamodb.AttributeValue{
        "ID":    {S: aws.String("123")},
        "Name":  {S: aws.String("Alice")},
        "Email": {S: aws.String("alice@example.com")},
    },
})

// Get item
result, err := svc.GetItem(&dynamodb.GetItemInput{
    TableName: aws.String("Users"),
    Key: map[string]*dynamodb.AttributeValue{
        "ID": {S: aws.String("123")},
    },
})
```

**NoSQL Design Patterns**

- Document modeling for MongoDB
- Key-value caching strategies for Redis
- Wide column family design for Cassandra
- Single-table design for DynamoDB
- Search index optimization for Elasticsearch

**Connection Management in NoSQL** Unlike SQL databases, NoSQL databases typically implement their own connection pooling and management strategies:

- MongoDB driver includes built-in connection pooling
- Redis clients often use connection pools
- Cassandra gocql manages connection pools per host
- Each driver implements database-specific optimization strategies

**Output** Database integration in Go emphasizes explicit resource management, type safety, and performance optimization. The standard library's database/sql package provides a solid foundation for SQL databases, while the ecosystem offers mature drivers and tools for both SQL and NoSQL databases. The combination of Go's concurrency model, explicit error handling, and comprehensive database ecosystem makes it well-suited for building robust, scalable database-driven applications.

**Related Topics**: Go context package for request lifecycle management, testing database code with testcontainers, database migration tools like golang-migrate, monitoring and observability for database operations, microservices data patterns, event sourcing and CQRS implementation in Go

---

