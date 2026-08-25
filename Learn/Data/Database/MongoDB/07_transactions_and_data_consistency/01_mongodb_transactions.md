## MongoDB Transactions


MongoDB transactions provide ACID (Atomicity, Consistency, Isolation, Durability) guarantees for database operations, ensuring data integrity across single or multiple documents, collections, and databases. Transactions are essential for maintaining data consistency in complex operations that require all-or-nothing execution semantics.

### ACID Transactions in MongoDB

MongoDB implements full ACID transaction support for both single-document and multi-document operations, providing enterprise-level data consistency guarantees.

#### Atomicity

**Key Points:**

- All operations within a transaction either complete successfully or are entirely rolled back
- No partial updates occur if any operation in the transaction fails
- Applies to operations across multiple documents, collections, and databases
- Automatic rollback occurs on transaction failure or explicit abort

**Example:**

```javascript
const session = client.startSession();

try {
  await session.withTransaction(async () => {
    // All operations must succeed or all will be rolled back
    await accounts.updateOne(
      { accountId: "A123" },
      { $inc: { balance: -100 } },
      { session }
    );
    
    await accounts.updateOne(
      { accountId: "B456" },
      { $inc: { balance: 100 } },
      { session }
    );
    
    await transactions.insertOne({
      from: "A123",
      to: "B456",
      amount: 100,
      timestamp: new Date()
    }, { session });
  });
} finally {
  await session.endSession();
}
```

#### Consistency

**Key Points:**

- Database remains in a valid state before and after transaction execution
- All database rules, constraints, and validations are enforced
- Schema validation rules apply to all documents modified within transactions
- Referential integrity is maintained across related collections

#### Isolation

MongoDB provides multiple isolation levels to control transaction visibility and concurrency behavior.

**Key Points:**

- Transactions are isolated from each other during execution
- Read operations within transactions see a consistent snapshot of data
- Write operations are not visible to other transactions until commit
- Supports snapshot isolation by default
- [Inference] Isolation levels help balance consistency requirements with performance needs

**Isolation Levels:**

```javascript
// Snapshot isolation (default)
const session = client.startSession();
await session.withTransaction(async () => {
  // Reads see consistent snapshot from transaction start
  const user = await users.findOne({ _id: userId }, { session });
  const orders = await orders.find({ userId: userId }, { session });
  
  // Modifications based on consistent view
  await users.updateOne(
    { _id: userId },
    { $inc: { totalOrders: orders.length } },
    { session }
  );
});
```

#### Durability

**Key Points:**

- Committed transactions are permanently stored and survive system failures
- Write operations are persisted to disk according to write concern settings
- Journal files ensure durability even in case of unexpected shutdowns
- Replica set members maintain transaction logs for consistency

### Single Document vs Multi-Document Transactions

MongoDB distinguishes between operations that affect single documents and those that span multiple documents, with different transaction characteristics for each.

#### Single Document Transactions

**Key Points:**

- All single document operations are inherently atomic in MongoDB
- No explicit transaction syntax required for single document operations
- ACID properties are guaranteed automatically
- Optimal performance due to document-level locking
- Include operations like `updateOne`, `replaceOne`, `deleteOne`

**Example:**

```javascript
// Atomic single document operation - no transaction needed
await users.updateOne(
  { _id: userId },
  {
    $inc: { loginCount: 1 },
    $set: { lastLogin: new Date() },
    $push: { loginHistory: { timestamp: new Date(), ip: userIP } }
  }
);

// Atomic array operations within single document
await orders.updateOne(
  { _id: orderId },
  {
    $push: {
      items: {
        $each: [
          { productId: "P123", quantity: 2, price: 29.99 },
          { productId: "P456", quantity: 1, price: 49.99 }
        ]
      }
    },
    $inc: { totalAmount: 109.97 }
  }
);
```

#### Multi-Document Transactions

**Key Points:**

- Required when operations span multiple documents, collections, or databases
- Must be explicitly started and managed using sessions
- Support complex business logic requiring multiple coordinated changes
- Higher overhead compared to single document operations
- Maximum transaction size of 16MB by default

**Example:**

```javascript
// Multi-document transaction for order processing
async function processOrder(orderId, customerId, items) {
  const session = client.startSession();
  
  try {
    const result = await session.withTransaction(async () => {
      // Update inventory for each item
      for (const item of items) {
        const inventoryUpdate = await inventory.updateOne(
          { 
            productId: item.productId,
            quantity: { $gte: item.quantity }
          },
          { $inc: { quantity: -item.quantity } },
          { session }
        );
        
        if (inventoryUpdate.matchedCount === 0) {
          throw new Error(`Insufficient inventory for product ${item.productId}`);
        }
      }
      
      // Create order document
      await orders.insertOne({
        _id: orderId,
        customerId: customerId,
        items: items,
        status: "confirmed",
        createdAt: new Date(),
        totalAmount: items.reduce((sum, item) => sum + (item.price * item.quantity), 0)
      }, { session });
      
      // Update customer order history
      await customers.updateOne(
        { _id: customerId },
        {
          $inc: { totalOrders: 1 },
          $push: { orderHistory: orderId }
        },
        { session }
      );
      
      return { success: true, orderId: orderId };
    });
    
    return result;
  } finally {
    await session.endSession();
  }
}
```

### Transaction Lifecycle

Understanding the complete lifecycle of MongoDB transactions is essential for proper implementation and error handling.

#### Transaction States

**Key Points:**

- **Starting**: Transaction begins with session creation
- **Active**: Operations are being executed within transaction context
- **Preparing**: Transaction is being prepared for commit
- **Committed**: All operations have been successfully applied
- **Aborted**: Transaction has been rolled back due to error or explicit abort

#### Session Management

**Example:**

```javascript
// Manual transaction lifecycle management
const session = client.startSession();

try {
  // Start transaction
  session.startTransaction({
    readConcern: { level: "snapshot" },
    writeConcern: { w: "majority", j: true },
    readPreference: "primary"
  });
  
  // Execute operations
  await collection1.insertOne({ data: "value1" }, { session });
  await collection2.updateOne(
    { _id: "doc1" },
    { $set: { updated: new Date() } },
    { session }
  );
  
  // Commit transaction
  await session.commitTransaction();
  
} catch (error) {
  // Abort transaction on error
  await session.abortTransaction();
  throw error;
} finally {
  // End session
  await session.endSession();
}
```

#### Callback-based Transaction API

**Example:**

```javascript
// Using withTransaction for automatic retry logic
await session.withTransaction(
  async () => {
    // Transaction operations
    const result1 = await users.updateOne(
      { _id: userId },
      { $inc: { balance: -amount } },
      { session }
    );
    
    if (result1.modifiedCount === 0) {
      throw new Error("User not found or insufficient balance");
    }
    
    await transactions.insertOne({
      userId: userId,
      amount: amount,
      type: "withdrawal",
      timestamp: new Date()
    }, { session });
    
    return { success: true };
  },
  {
    readConcern: { level: "snapshot" },
    writeConcern: { w: "majority" },
    readPreference: "primary"
  }
);
```

#### Transaction Retry Logic

**Key Points:**

- Transactions may need to be retried due to transient errors
- MongoDB drivers provide automatic retry logic for certain error types
- Custom retry logic may be needed for application-specific requirements
- [Inference] Proper retry implementation improves transaction reliability

**Example:**

```javascript
async function executeTransactionWithRetry(transactionFunc, maxRetries = 3) {
  let retries = 0;
  
  while (retries < maxRetries) {
    const session = client.startSession();
    
    try {
      const result = await session.withTransaction(transactionFunc);
      return result;
    } catch (error) {
      if (error.hasErrorLabel('TransientTransactionError') && retries < maxRetries - 1) {
        retries++;
        console.log(`Transaction failed with transient error, retrying... (${retries}/${maxRetries})`);
        continue;
      }
      throw error;
    } finally {
      await session.endSession();
    }
  }
}
```

### Read and Write Concerns

Read and write concerns control the consistency and durability guarantees for transaction operations, allowing fine-tuned control over performance versus consistency trade-offs.

#### Read Concerns

Read concerns specify the consistency and isolation properties for read operations within transactions.

**Key Points:**

- Control the consistency level of data returned by read operations
- Affect transaction isolation and performance characteristics
- Can be specified at transaction level or individual operation level
- [Inference] Higher read concern levels provide stronger consistency but may impact performance

**Read Concern Levels:**

**local:**

```javascript
session.startTransaction({
  readConcern: { level: "local" }
});
// Returns most recent data available to the member
// No guarantee of acknowledgment by majority
```

**available:**

```javascript
session.startTransaction({
  readConcern: { level: "available" }
});
// Returns most recent data, similar to local
// Orphaned documents may be returned in sharded clusters
```

**majority:**

```javascript
session.startTransaction({
  readConcern: { level: "majority" }
});
// Returns data acknowledged by majority of replica set members
// Provides stronger consistency guarantees
```

**snapshot:**

```javascript
session.startTransaction({
  readConcern: { level: "snapshot" }
});
// Returns majority-committed data from a specific point in time
// Provides read isolation within transactions
```

#### Write Concerns

Write concerns specify the acknowledgment requirements for write operations within transactions.

**Key Points:**

- Control durability and acknowledgment requirements for write operations
- Affect transaction commit behavior and performance
- Can specify number of members that must acknowledge writes
- Journal synchronization requirements can be specified

**Write Concern Options:**

**Basic Write Concern:**

```javascript
session.startTransaction({
  writeConcern: { w: 1, j: false }
});
// Acknowledgment from primary only
// No journal sync required
```

**Majority Write Concern:**

```javascript
session.startTransaction({
  writeConcern: { w: "majority", j: true }
});
// Acknowledgment from majority of replica set members
// Journal sync required for durability
```

**Custom Write Concern:**

```javascript
session.startTransaction({
  writeConcern: { 
    w: 3,           // Acknowledgment from 3 members
    j: true,        // Journal sync required
    wtimeout: 5000  // 5 second timeout
  }
});
```

#### Advanced Read and Write Concern Configuration

**Example:**

```javascript
// High consistency transaction
async function criticalFinancialTransaction() {
  const session = client.startSession();
  
  try {
    await session.withTransaction(
      async () => {
        // Critical operations requiring highest consistency
        const account = await accounts.findOne(
          { _id: accountId },
          { 
            session,
            readConcern: { level: "snapshot" }
          }
        );
        
        if (account.balance < transferAmount) {
          throw new Error("Insufficient funds");
        }
        
        await accounts.updateOne(
          { _id: fromAccount },
          { $inc: { balance: -transferAmount } },
          { session }
        );
        
        await accounts.updateOne(
          { _id: toAccount },
          { $inc: { balance: transferAmount } },
          { session }
        );
        
        await auditLog.insertOne({
          operation: "transfer",
          from: fromAccount,
          to: toAccount,
          amount: transferAmount,
          timestamp: new Date()
        }, { session });
      },
      {
        readConcern: { level: "snapshot" },
        writeConcern: { w: "majority", j: true, wtimeout: 10000 },
        readPreference: "primary"
      }
    );
  } finally {
    await session.endSession();
  }
}

// Performance-optimized transaction
async function bulkDataImport(data) {
  const session = client.startSession();
  
  try {
    await session.withTransaction(
      async () => {
        // Batch operations for better performance
        const bulkOps = data.map(item => ({
          insertOne: { document: item }
        }));
        
        await collection.bulkWrite(bulkOps, { session });
        
        await metadata.updateOne(
          { _id: "import_stats" },
          { 
            $inc: { totalRecords: data.length },
            $set: { lastImport: new Date() }
          },
          { session }
        );
      },
      {
        readConcern: { level: "local" },     // Lower consistency for performance
        writeConcern: { w: 1, j: false },    // Faster acknowledgment
        readPreference: "primaryPreferred"
      }
    );
  } finally {
    await session.endSession();
  }
}
```

#### Error Handling and Concern Interactions

**Example:**

```javascript
async function robustTransactionWithErrorHandling() {
  const session = client.startSession();
  
  try {
    await session.withTransaction(
      async () => {
        try {
          // Operations with specific error handling
          const result = await sensitiveCollection.updateOne(
            { _id: documentId },
            { $set: { processed: true, processedAt: new Date() } },
            { 
              session,
              writeConcern: { w: "majority", j: true, wtimeout: 5000 }
            }
          );
          
          if (result.matchedCount === 0) {
            throw new Error("Document not found");
          }
          
          // Log successful operation
          await operationLog.insertOne({
            operation: "process_document",
            documentId: documentId,
            status: "success",
            timestamp: new Date()
          }, { session });
          
        } catch (error) {
          // Log failed operation
          await operationLog.insertOne({
            operation: "process_document",
            documentId: documentId,
            status: "failed",
            error: error.message,
            timestamp: new Date()
          }, { session });
          
          throw error; // Re-throw to abort transaction
        }
      },
      {
        readConcern: { level: "majority" },
        writeConcern: { w: "majority", j: true }
      }
    );
  } catch (error) {
    if (error.hasErrorLabel('TransientTransactionError')) {
      console.log("Transient error occurred, transaction will be retried automatically");
    } else if (error.hasErrorLabel('UnknownTransactionCommitResult')) {
      console.log("Transaction commit result unknown, may need manual verification");
    } else {
      console.log("Transaction failed:", error.message);
    }
    throw error;
  } finally {
    await session.endSession();
  }
}
```

**Conclusion:**

MongoDB transactions provide comprehensive ACID guarantees for both single and multi-document operations. Understanding the transaction lifecycle, proper session management, and appropriate read and write concern configuration is essential for building reliable applications. [Inference] The choice between single-document atomicity and multi-document transactions should be based on specific use case requirements, balancing consistency needs with performance considerations. Proper error handling and retry logic are crucial for robust transaction implementation in production environments.

---

