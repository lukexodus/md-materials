## Implementing Transactions


### Starting and Committing Transactions

MongoDB transactions allow multiple operations to be executed atomically across one or more collections, ensuring data consistency. Transactions in MongoDB require replica sets or sharded clusters and cannot be used with standalone instances.

There are two primary approaches to implementing transactions: using sessions with explicit transaction control or using the `withTransaction` helper method.

**Explicit Transaction Control:**

```javascript
const session = client.startSession();

try {
  session.startTransaction();
  
  // Perform multiple operations within the transaction
  await db.collection('accounts').updateOne(
    { _id: fromAccount },
    { $inc: { balance: -100 } },
    { session }
  );
  
  await db.collection('accounts').updateOne(
    { _id: toAccount },
    { $inc: { balance: 100 } },
    { session }
  );
  
  await db.collection('transactions').insertOne({
    from: fromAccount,
    to: toAccount,
    amount: 100,
    timestamp: new Date()
  }, { session });
  
  // Commit the transaction
  await session.commitTransaction();
} catch (error) {
  await session.abortTransaction();
  throw error;
} finally {
  await session.endSession();
}
```

**Using withTransaction Helper:**

```javascript
const session = client.startSession();

try {
  await session.withTransaction(async () => {
    await db.collection('accounts').updateOne(
      { _id: fromAccount },
      { $inc: { balance: -100 } },
      { session }
    );
    
    await db.collection('accounts').updateOne(
      { _id: toAccount },
      { $inc: { balance: 100 } },
      { session }
    );
    
    await db.collection('transactions').insertOne({
      from: fromAccount,
      to: toAccount,
      amount: 100,
      timestamp: new Date()
    }, { session });
  });
} finally {
  await session.endSession();
}
```

**Key points:**

- All operations within a transaction must use the same session
- Transactions require replica sets or sharded clusters
- The `withTransaction` helper automatically handles retries and commit/abort logic
- Sessions must be explicitly ended to free resources

### Transaction Rollback and Error Handling

MongoDB transactions can fail for various reasons including write conflicts, network issues, or application errors. Proper error handling ensures data consistency and provides meaningful feedback to applications.

**Common Transaction Errors:**

- `TransientTransactionError`: Temporary failures that can be retried
- `UnknownTransactionCommitResult`: Commit status is uncertain, retry may be appropriate
- `WriteConflict`: Multiple transactions attempting to modify the same document
- `ExceededTimeLimit`: Transaction exceeded the configured time limit

```javascript
async function transferMoney(fromAccount, toAccount, amount) {
  const session = client.startSession();
  
  try {
    await session.withTransaction(async () => {
      // Check sufficient balance
      const fromDoc = await db.collection('accounts').findOne(
        { _id: fromAccount },
        { session }
      );
      
      if (!fromDoc || fromDoc.balance < amount) {
        throw new Error('Insufficient funds');
      }
      
      // Perform transfer operations
      await db.collection('accounts').updateOne(
        { _id: fromAccount },
        { $inc: { balance: -amount } },
        { session }
      );
      
      await db.collection('accounts').updateOne(
        { _id: toAccount },
        { $inc: { balance: amount } },
        { session }
      );
      
      await db.collection('audit_log').insertOne({
        type: 'transfer',
        from: fromAccount,
        to: toAccount,
        amount: amount,
        timestamp: new Date()
      }, { session });
      
    }, {
      readConcern: { level: 'snapshot' },
      writeConcern: { w: 'majority' },
      maxCommitTimeMS: 5000
    });
    
    return { success: true, message: 'Transfer completed' };
    
  } catch (error) {
    if (error.hasErrorLabel('TransientTransactionError')) {
      // [Inference] Retry logic would typically be implemented here
      console.log('Transient error occurred, could retry');
    } else if (error.hasErrorLabel('UnknownTransactionCommitResult')) {
      // [Inference] Application logic to handle uncertain commit state
      console.log('Transaction commit result unknown');
    }
    
    throw error;
  } finally {
    await session.endSession();
  }
}
```

**Error Handling Strategies:**

```javascript
// Retry wrapper for transient errors
async function executeWithRetry(operation, maxRetries = 3) {
  let attempt = 0;
  
  while (attempt < maxRetries) {
    try {
      return await operation();
    } catch (error) {
      attempt++;
      
      if (error.hasErrorLabel('TransientTransactionError') && attempt < maxRetries) {
        // [Inference] Exponential backoff would be appropriate here
        await new Promise(resolve => setTimeout(resolve, Math.pow(2, attempt) * 100));
        continue;
      }
      
      throw error;
    }
  }
}
```

**Key points:**

- Always handle both transient and permanent errors appropriately
- Use error labels to determine retry strategies
- Implement proper logging for transaction failures
- Consider application-specific validation within transactions

### Transaction Best Practices

Effective transaction implementation requires following established patterns and avoiding common pitfalls that can impact performance and reliability.

**Transaction Scope and Duration:**

- Keep transactions as short as possible to minimize lock contention
- Avoid long-running operations like external API calls within transactions
- Group related operations that must be atomic together
- Consider breaking large transactions into smaller, independent units

```javascript
// Good: Focused transaction scope
async function createUserWithProfile(userData, profileData) {
  const session = client.startSession();
  
  try {
    await session.withTransaction(async () => {
      const userResult = await db.collection('users').insertOne(userData, { session });
      
      await db.collection('profiles').insertOne({
        ...profileData,
        userId: userResult.insertedId
      }, { session });
    });
  } finally {
    await session.endSession();
  }
}

// Avoid: Including non-critical operations
async function createUserWithEmailNotification(userData) {
  const session = client.startSession();
  
  try {
    await session.withTransaction(async () => {
      await db.collection('users').insertOne(userData, { session });
      
      // Bad: External API call within transaction
      await emailService.sendWelcomeEmail(userData.email);
    });
  } finally {
    await session.endSession();
  }
}
```

**Read and Write Concerns:**

```javascript
// Configure appropriate concerns for consistency requirements
const transactionOptions = {
  readConcern: { level: 'snapshot' },    // Consistent snapshot
  writeConcern: { w: 'majority' },       // Majority acknowledgment
  maxCommitTimeMS: 5000                  // Timeout for commit
};

await session.withTransaction(async () => {
  // Transaction operations
}, transactionOptions);
```

**Document Design Considerations:**

- Design documents to minimize cross-document transactions
- Use embedded documents for data that should be updated atomically
- Consider denormalization to reduce transaction complexity

```javascript
// Good: Embedded document design reduces transaction needs
{
  _id: ObjectId("..."),
  userId: ObjectId("..."),
  items: [
    { productId: ObjectId("..."), quantity: 2, price: 29.99 },
    { productId: ObjectId("..."), quantity: 1, price: 15.99 }
  ],
  total: 75.97,
  status: "pending"
}

// Less optimal: Separate collections requiring transactions
// orders collection + order_items collection
```

**Key points:**

- Minimize transaction duration and scope
- Use appropriate read and write concerns for consistency requirements
- Design document structure to reduce transaction complexity
- Implement proper session management and cleanup

### Performance Implications

Transactions introduce overhead and can significantly impact MongoDB performance if not implemented carefully. Understanding these implications helps in making informed design decisions.

**Performance Overhead Sources:**

- **Locking**: Transactions use locks that can cause contention
- **Oplog Growth**: All transaction operations are written as a single oplog entry
- **Memory Usage**: Transaction state must be maintained in memory
- **Network Roundtrips**: Additional communication for transaction coordination

**Throughput Impact:**

```javascript
// [Inference] Based on general database transaction principles
// High-contention scenario - multiple transactions on same documents
await Promise.all([
  transferMoney('account1', 'account2', 100),
  transferMoney('account1', 'account3', 50),   // Will conflict with first
  transferMoney('account2', 'account4', 75)
]);
```

**Optimization Strategies:**

**Batch Operations When Possible:**

```javascript
// Instead of multiple single-document transactions
for (const update of updates) {
  const session = client.startSession();
  await session.withTransaction(async () => {
    await collection.updateOne(update.filter, update.update, { session });
  });
  await session.endSession();
}

// Use bulk operations or reduce transaction frequency
const session = client.startSession();
await session.withTransaction(async () => {
  await collection.bulkWrite(updates.map(u => ({
    updateOne: {
      filter: u.filter,
      update: u.update
    }
  })), { session });
});
await session.endSession();
```

**Connection Pool Considerations:**

```javascript
// Configure connection pool for transaction workloads
const client = new MongoClient(uri, {
  maxPoolSize: 50,           // Increase pool size for concurrent transactions
  maxIdleTimeMS: 30000,      // Manage idle connections
  serverSelectionTimeoutMS: 5000
});
```

**Monitoring and Metrics:**

- Monitor transaction commit and abort rates
- Track transaction duration and queue depth
- Observe write conflict frequency
- Monitor oplog size growth patterns

**Key points:**

- Transactions have measurable performance overhead
- Design applications to minimize transaction conflicts
- Monitor transaction metrics to identify performance bottlenecks
- Consider alternatives like atomic document updates when appropriate

**Conclusion:** Effective transaction implementation requires balancing data consistency needs with performance requirements. [Inference] Applications that follow these practices typically experience better reliability and performance, though specific results depend on workload characteristics and infrastructure configuration.

---

