## Transaction Isolation Phenomena in PostgreSQL


### Overview of Transaction Isolation Phenomena
Transaction isolation phenomena, such as **dirty reads**, **non-repeatable reads**, and **phantom reads**, are potential inconsistencies that arise when multiple transactions access and modify data concurrently in a database. In PostgreSQL, these phenomena are managed within the **Multiversion Concurrency Control (MVCC)** framework, which uses transaction IDs (XIDs), row-level fields (`xmin` and `xmax`), and snapshots to control data visibility. Understanding these phenomena is critical for selecting the appropriate transaction isolation level (Read Committed, Repeatable Read, Serializable) to balance consistency, concurrency, and performance. Beyond the core phenomena, related issues like **serialization anomalies**, **write skew**, and **read skew** are also relevant, particularly in stricter isolation levels. This guide provides a comprehensive exploration of these phenomena, their implications, and how PostgreSQL addresses them.

**Key points**:
- Dirty reads, non-repeatable reads, and phantom reads are concurrency issues defined by the SQL standard.
- PostgreSQL’s MVCC ensures isolation using snapshots, preventing some phenomena based on the isolation level.
- Additional anomalies (e.g., write skew, read skew) are relevant in PostgreSQL’s Serializable Snapshot Isolation (SSI).
- Isolation levels control which phenomena are prevented, impacting application behavior and performance.
- Proper monitoring and tuning mitigate the side effects of these phenomena, such as dead tuples and transaction aborts.

### Dirty Reads
A **dirty read** occurs when a transaction reads uncommitted changes made by another transaction. If the modifying transaction rolls back, the reading transaction has seen invalid data, leading to potential errors or inconsistencies. Dirty reads are considered severe because they violate data integrity.

**Key points**:
- Dirty reads are prevented in all PostgreSQL isolation levels (Read Committed, Repeatable Read, Serializable).
- MVCC ensures transactions only see committed data by checking the commit status of `xmin` in row tuples.
- Uncommitted changes (rows with `xmin` from an active transaction) are invisible until the transaction commits.
- Eliminates the risk of acting on data that may be rolled back, ensuring basic consistency.
- No configuration is needed to prevent dirty reads, as it’s a core feature of PostgreSQL’s MVCC.

**Example**:
```sql
-- Transaction 1 (XID 1000, Read Committed)
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1; -- Uncommitted change
-- Transaction 2 (XID 1001, Read Committed)
SELECT balance FROM accounts WHERE account_id = 1; -- Sees original balance, not uncommitted change
-- Transaction 1
ROLLBACK;
```

**Output**:
- Transaction 2: `(account_id=1, balance=original_value)` (e.g., 1000)

**Conclusion**:
Transaction 2 does not see the uncommitted decrease in balance by Transaction 1, preventing a dirty read. MVCC ensures only committed data (`xmin` from committed transactions) is visible, even in Read Committed.

### Non-repeatable Reads
A **non-repeatable read** occurs when a transaction reads the same row multiple times and sees different data because another transaction committed changes (e.g., an update) between the reads. This can lead to inconsistent results within a transaction, affecting logic that assumes data stability.

**Key points**:
- Non-repeatable reads are possible in **Read Committed** but prevented in **Repeatable Read** and **Serializable**.
- In Read Committed, each query takes a new snapshot, reflecting committed changes from other transactions.
- In Repeatable Read and Serializable, a single snapshot ensures all queries see the same data throughout the transaction.
- Common in applications with frequent updates, such as user profile management or inventory tracking.
- Preventing non-repeatable reads increases dead tuple generation, as older row versions persist longer.

**Example**:
```sql
-- Transaction 1 (XID 1002, Read Committed)
BEGIN;
SELECT balance FROM accounts WHERE account_id = 1; -- Sees balance=1000 (xmin=990)
-- Transaction 2 (XID 1003)
BEGIN;
UPDATE accounts SET balance = 900 WHERE account_id = 1;
COMMIT;
-- Transaction 1
SELECT balance FROM accounts WHERE account_id = 1; -- Sees balance=900 (xmin=1003)
COMMIT;
```

**Output**:
- First query: `(account_id=1, balance=1000)`
- Second query: `(account_id=1, balance=900)`

**Conclusion**:
In Read Committed, Transaction 1 sees different balances due to Transaction 2’s committed update, demonstrating a non-repeatable read. Using Repeatable Read would prevent this by maintaining a single snapshot, showing `balance=1000` in both queries.

### Phantom Reads
A **phantom read** occurs when a transaction executes a query multiple times and sees different sets of rows because another transaction committed changes (e.g., inserts or deletes) that match the query’s conditions. This differs from non-repeatable reads, which involve changes to existing rows, as phantom reads involve new or removed rows.

**Key points**:
- Phantom reads are possible in **Read Committed** and **Repeatable Read** but prevented in **Serializable**.
- In Read Committed and Repeatable Read, new rows inserted by committed transactions may appear in later queries.
- Serializable uses **predicate locking** to prevent phantom reads, ensuring the set of rows matching a condition remains consistent.
- Common in applications with dynamic data, such as leaderboards or real-time analytics.
- Preventing phantom reads in Serializable mode increases the risk of serialization conflicts and transaction aborts.

**Example**:
```sql
-- Transaction 1 (XID 1004, Repeatable Read)
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM accounts WHERE balance > 500; -- Sees (account_id=1, balance=1000)
-- Transaction 2 (XID 1005)
BEGIN;
INSERT INTO accounts (account_id, balance) VALUES (2, 600);
COMMIT;
-- Transaction 1
SELECT * FROM accounts WHERE balance > 500; -- Sees (account_id=1, balance=1000), (account_id=2, balance=600)
COMMIT;
```

**Output**:
- First query: `(account_id=1, balance=1000)`
- Second query: `(account_id=1, balance=1000), (account_id=2, balance=600)`

**Conclusion**:
In Repeatable Read, Transaction 1 sees the new row inserted by Transaction 2 in the second query, demonstrating a phantom read. Serializable mode would prevent this by enforcing consistency in the row set, potentially aborting one transaction if conflicts arise.

### Other Related Phenomena
Beyond the SQL standard phenomena, PostgreSQL’s **Serializable Snapshot Isolation (SSI)** addresses additional anomalies that can occur in concurrent transactions, particularly in Repeatable Read and Serializable modes. These include **write skew**, **read skew**, and **serialization anomalies**, which are critical for understanding the behavior of stricter isolation levels.

#### Write Skew
**Write skew** occurs when two transactions read overlapping data, make decisions based on that data, and then update different rows, leading to an inconsistent state that wouldn’t occur in a serial execution. It’s a form of serialization anomaly specific to snapshot-based isolation.

**Key points**:
- Common in Serializable mode when transactions read shared data but write to distinct rows.
- Prevented by PostgreSQL’s SSI through predicate locking and conflict detection.
- Can occur in Repeatable Read without SSI, as it doesn’t fully enforce serializability.
- Often seen in applications enforcing constraints across multiple rows, such as scheduling or budget allocation.
- Increases transaction abort rates, requiring retry logic in applications.

**Example**:
```sql
-- Transaction 1 (XID 1006, Serializable): Ensure total balance <= 2000
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT SUM(balance) FROM accounts; -- Sees 1500 (account_id=1: 1000, account_id=2: 500)
-- If sum <= 2000, add 600 to account 1
UPDATE accounts SET balance = balance + 600 WHERE account_id = 1;
-- Transaction 2 (XID 1007, Serializable): Same logic
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT SUM(balance) FROM accounts; -- Sees 1500
UPDATE accounts SET balance = balance + 600 WHERE account_id = 2;
COMMIT;
-- Transaction 1
COMMIT; -- May fail: ERROR: could not serialize access due to read/write dependency
```

**Output**:
- Possible error: `ERROR: could not serialize access`
- If both commit, total balance becomes 2700 (1000+600 + 500+600), violating the constraint.

**Conclusion**:
Write skew occurs because both transactions read the same total (1500) and assume their updates are safe, but their concurrent writes violate the constraint. Serializable mode detects this conflict and aborts one transaction to maintain serializability.

#### Read Skew
**Read skew** occurs when a transaction reads data that is later modified by another transaction in a way that makes the initial read inconsistent with the final state. It’s a subtle anomaly where a transaction sees a partial view of another transaction’s changes.

**Key points**:
- Possible in Read Committed and Repeatable Read but prevented in Serializable.
- Arises when a transaction reads related data at different points, and concurrent updates create inconsistencies.
- Less common but relevant in applications requiring consistent views of related data, such as auditing.
- Prevented by Serializable’s predicate locking, which tracks read dependencies.
- Increases dead tuple generation in stricter modes due to longer snapshot retention.

**Example**:
```sql
-- Transaction 1 (XID 1008, Read Committed)
BEGIN;
SELECT balance FROM accounts WHERE account_id = 1; -- Sees 1000
-- Transaction 2 (XID 1009)
BEGIN;
UPDATE accounts SET balance = 900 WHERE account_id = 1;
UPDATE accounts SET balance = 600 WHERE account_id = 2;
COMMIT;
-- Transaction 1
SELECT balance FROM accounts WHERE account_id = 2; -- Sees 600
COMMIT;
```

**Output**:
- First query: `(account_id=1, balance=1000સ4.0.1 (Community Edition) balance=1000)`
- Second query: `(account_id=2, balance=600)`

**Conclusion**:
Transaction 1 sees `balance=1000` for `account_id=1` and `balance=600` for `account_id=2`, which is inconsistent with the final state after Transaction 2’s updates. Serializable would prevent this by ensuring a consistent view, potentially aborting Transaction 1.

#### Serialization Anomalies
**Serialization anomalies** are any inconsistencies that violate the serial execution order of transactions, encompassing write skew, read skew, and other complex conflicts. They occur when concurrent transactions produce results that couldn’t occur if executed sequentially.

**Key points**:
- Addressed only by Serializable mode in PostgreSQL, using SSI.
- Include write skew, read skew, and other conflicts detected by predicate locking.
- Common in applications with complex business rules, such as financial systems or reservation systems.
- Lead to transaction aborts, requiring robust retry logic.
- Monitored via `pg_stat_database.conflicts` and server logs.

**Example**:
```sql
-- Transaction 1 (XID 1010, Serializable): Check inventory
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT quantity FROM inventory WHERE item_id = 1; -- Sees 10
-- Transaction 2 (XID 1011, Serializable)
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE inventory SET quantity = 5 WHERE item_id = 1;
UPDATE inventory SET quantity = 15 WHERE item_id = 2;
COMMIT;
-- Transaction 1
UPDATE inventory SET quantity = quantity - 5 WHERE item_id = 2; -- Conflicts with Transaction 2
COMMIT; -- May fail: ERROR: could not serialize access
```

**Output**:
- Possible error: `ERROR: could not serialize access`

**Conclusion**:
The anomaly occurs because Transaction 1’s update to `item_id=2` could create an inconsistent state based on its read of `item_id=1`. Serializable aborts one transaction to ensure serializability.

### Isolation Levels and Phenomena
PostgreSQL’s isolation levels control which phenomena are prevented, as summarized below:

| Isolation Level     | Dirty Reads | Non-repeatable Reads | Phantom Reads | Write Skew | Read Skew | Serialization Anomalies |
|---------------------|-------------|----------------------|---------------|------------|-----------|------------------------|
| Read Committed      | No          | Yes                  | Yes           | Yes        | Yes       | Yes                    |
| Repeatable Read     | No          | No                   | Yes           | Yes        | Yes       | Yes                    |
| Serializable        | No          | No                   | No            | No         | No        | No                     |

**Key points**:
- Read Committed allows most anomalies except dirty reads, prioritizing concurrency.
- Repeatable Read prevents non-repeatable reads but allows phantom reads and other anomalies.
- Serializable prevents all phenomena, ensuring complete isolation but at the cost of potential aborts.
- PostgreSQL’s SSI in Serializable is stricter than the SQL standard, detecting anomalies beyond phantom reads.
- Choice of isolation level depends on application requirements for consistency vs. performance.

### Impact on MVCC and Autovacuum
These phenomena are managed by PostgreSQL’s MVCC, which creates multiple row versions, leading to **dead tuples** that must be cleaned by **autovacuum**. Stricter isolation levels and frequent anomalies increase dead tuple generation, requiring careful tuning.

**Key points**:
- Non-repeatable reads and phantom reads in Read Committed generate fewer dead tuples due to short-lived snapshots.
- Repeatable Read and Serializable retain snapshots longer, increasing dead tuples and bloat risk.
- Serialization anomalies in Serializable mode create more dead tuples due to transaction aborts and predicate locking.
- Autovacuum must be tuned (e.g., `autovacuum_vacuum_scale_factor`, `autovacuum_max_workers`) to handle increased cleanup.
- Monitor dead tuples with `pg_stat_all_tables.n_dead_tup` and bloat with `pgstattuple`.

### Monitoring and Debugging
PostgreSQL provides tools to monitor phenomena, track conflicts, and diagnose related issues.

**Key points**:
- Check isolation level: `SHOW transaction_isolation;`.
- Monitor conflicts: `SELECT conflicts FROM pg_stat_database WHERE datname = 'mydb';`.
- Track dead tuples: `SELECT relname, n_dead_tup FROM pg_stat_all_tables;`.
- Inspect snapshots and XIDs: Enable `log_line_prefix` with `%x` in logs.
- View predicate locks in Serializable: `SELECT * FROM pg_locks WHERE locktype = 'siReadLock';`.

**Example**:
```sql
-- Transaction 1 (XID 1012, Serializable)
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM accounts WHERE balance > 500; -- Snapshot taken
-- Transaction 2 (XID 1013)
INSERT INTO accounts (account_id, balance) VALUES (3, 600);
COMMIT;
-- Transaction 1
UPDATE accounts SET balance = balance + 100 WHERE balance > 500;
COMMIT; -- May fail due to phantom read conflict
-- Check conflicts
SELECT conflicts FROM pg_stat_database WHERE datname = current_database();
```

**Output**:
- Possible error: `ERROR: could not serialize access`
- `pg_stat_database.conflicts`: `1`

**Conclusion**:
The conflict indicates a phantom read was prevented in Serializable mode, ensuring consistency but requiring retry logic to handle the abort.

### Best Practices
Managing these phenomena effectively ensures robust database operations while meeting application needs.

**Key points**:
- Use **Read Committed** for applications tolerant of non-repeatable reads and phantom reads (e.g., web apps).
- Use **Repeatable Read** for stable data views (e.g., reporting) but be prepared for phantom reads.
- Use **Serializable** for critical consistency (e.g., financial transactions) with retry logic for aborts:
  ```sql
  DO $$
  BEGIN
      FOR i IN 1..3 LOOP
          BEGIN
              BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
              -- Transaction logic
              COMMIT;
              EXIT;
          EXCEPTION WHEN serialization_failure THEN
              IF i = 3 THEN RAISE; END IF;
              ROLLBACK;
          END;
      END LOOP;
  END $$;
  ```
- Tune autovacuum to handle dead tuples from stricter isolation levels (e.g., `autovacuum_vacuum_scale_factor = 0.05`).
- Minimize transaction duration to reduce conflicts and dead tuple retention, especially in Serializable mode.

### Practical Scenarios
Different phenomena impact various use cases, guiding isolation level choices.

**Key points**:
- **E-commerce**: Read Committed for product listings (tolerates phantom reads) but Serializable for order processing to prevent write skew.
- **Financial Systems**: Serializable for balance transfers to avoid all anomalies, ensuring accurate accounting.
- **Analytics**: Repeatable Read for consistent query results across reports, avoiding non-repeatable reads.
- **Social Media**: Read Committed for feeds where new posts (phantom reads) are acceptable.
- **Reservation Systems**: Serializable to prevent write skew in seat or room bookings.

**Example** (Financial Transfer, Serializable):
```sql
-- Transaction 1 (XID 1014, Serializable)
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT balance FROM accounts WHERE account_id = 1; -- 1000
SELECT balance FROM accounts WHERE account_id = 2; -- 500
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
-- Transaction 2 (XID 1015, Serializable)
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE accounts SET balance = balance + 200 WHERE account_id = 1;
COMMIT;
-- Transaction 1
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT; -- May fail due to write skew
```

**Output**:
- Possible error: `ERROR: could not serialize access`

**Conclusion**:
Serializable prevents write skew by aborting Transaction 1, ensuring the transfer doesn’t create an inconsistent state. Retry logic would reattempt the transfer.

### Recommended Subtopics
- Autovacuum tuning for handling dead tuples from concurrency phenomena
- Implementing retry logic for serialization failures in Serializable mode
- Predicate locking mechanics in Serializable Snapshot Isolation
- Impact of long-running transactions on phenomena and MVCC
- Comparing PostgreSQL’s anomaly handling with other databases (e.g., MySQL, Oracle)

---

