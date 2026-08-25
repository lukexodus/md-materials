## Transactions and ACID Compliance in PostgreSQL


### Introduction to Database Transactions

A transaction in database management represents a single unit of work that may consist of multiple operations. In PostgreSQL, transactions ensure that database operations either complete entirely or have no effect at all, preserving data integrity even in case of system failures.

**Key Points**:

- Transactions group multiple operations into atomic units
- They protect data integrity during concurrent access
- PostgreSQL fully supports ACID-compliant transactions
- Transactions can be explicitly controlled or used implicitly

### Understanding ACID Properties

ACID is an acronym that represents the four critical properties of database transactions that ensure reliable processing.

#### Atomicity

Atomicity guarantees that all operations within a transaction are treated as a single, indivisible unit. Either all operations succeed, or none do.

```sql
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
    -- If any statement fails, all changes are rolled back
COMMIT;
```

**Example**: If a power failure occurs after the first update but before the second, the entire transaction is rolled back, ensuring no money disappears from account #1 without being added to account #2.

#### Consistency

Consistency ensures that a transaction can only bring the database from one valid state to another valid state, maintaining all predefined rules such as constraints, cascades, and triggers.

```sql
BEGIN;
    -- This transaction will fail because it violates the CHECK constraint
    UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1;
    -- Assume there's a CHECK constraint that prevents negative balances
COMMIT;
```

**Example**: If a CHECK constraint prevents negative account balances, and a withdrawal would cause a negative balance, the entire transaction fails and the database remains in a consistent state.

#### Isolation

Isolation ensures that concurrent execution of transactions leaves the database in the same state as if the transactions were executed sequentially.

```sql
-- Transaction 1
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    -- Some time passes while Transaction 2 runs concurrently
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;

-- Transaction 2 (running concurrently)
BEGIN;
    SELECT balance FROM accounts WHERE account_id = 1;
    -- Depending on isolation level, this may see the old or new balance
COMMIT;
```

**Example**: If two customers are checking an account balance while a transfer is in progress, isolation levels determine whether they see the pre-transfer amount, post-transfer amount, or receive an error.

#### Durability

Durability guarantees that once a transaction is committed, it remains committed even in the case of a system failure (crash, power outage, etc.).

```sql
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;
-- Even if a system crash occurs immediately after COMMIT, 
-- the changes are permanent when the system comes back online
```

**Example**: After receiving confirmation that a money transfer completed successfully, a banking system can guarantee that the transfer won't be lost even if the server crashes immediately afterward.

### Transaction Control in PostgreSQL

PostgreSQL provides several commands to control transactions explicitly.

#### Basic Transaction Control

```sql
-- Begin a transaction
BEGIN;
-- or 
START TRANSACTION;

-- Perform operations
INSERT INTO orders (customer_id, order_date, total)
VALUES (42, CURRENT_DATE, 199.99);

INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES (CURRVAL('orders_order_id_seq'), 101, 2, 99.99);

-- Complete the transaction successfully
COMMIT;
-- or
COMMIT WORK;

-- Abort the transaction and roll back changes
ROLLBACK;
-- or
ROLLBACK WORK;
```

#### Savepoints

Savepoints allow partial rollbacks within a transaction.

```sql
BEGIN;
    INSERT INTO customers (name, email) VALUES ('John Doe', 'john@example.com');
    
    SAVEPOINT new_customer;
    
    INSERT INTO orders (customer_id, total) 
    VALUES (CURRVAL('customers_id_seq'), 0);
    
    -- Oops, something went wrong with the order
    ROLLBACK TO SAVEPOINT new_customer;
    
    -- Continue with different operations after rolling back to savepoint
    UPDATE customers SET status = 'active' 
    WHERE id = CURRVAL('customers_id_seq');
COMMIT;
```

**Example**: In an e-commerce system, you might create a customer record, then attempt to create an order. If the order creation fails due to inventory issues, you can roll back to the savepoint, keeping the customer record but discarding the failed order.

### Transaction Isolation Levels

PostgreSQL supports all four standard SQL transaction isolation levels, each offering different tradeoffs between consistency and performance.

#### READ UNCOMMITTED

In PostgreSQL, this behaves the same as READ COMMITTED because PostgreSQL does not allow reading uncommitted data.

```sql
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    -- Operations here
COMMIT;
```

#### READ COMMITTED

This is PostgreSQL's default isolation level. Each query in a transaction sees only data committed before the query began.

```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SELECT balance FROM accounts WHERE account_id = 1;
    -- This may return a different value if another transaction
    -- updates and commits a change to this account between the two SELECTs
    SELECT balance FROM accounts WHERE account_id = 1;
COMMIT;
```

**Example**: In a banking application with READ COMMITTED isolation, if one transaction updates an account balance and commits while another transaction is reading account balances, the second transaction's subsequent reads will see the new balance.

#### REPEATABLE READ

Ensures that a transaction sees only data committed before it began, and that data doesn't change throughout the transaction.

```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    SELECT balance FROM accounts WHERE account_id = 1;
    -- Some time passes, another transaction updates and commits account #1
    SELECT balance FROM accounts WHERE account_id = 1;
    -- Will return the same balance as before, regardless of other committed changes
COMMIT;
```

**Example**: In an inventory system with REPEATABLE READ isolation, if a report is running to calculate total inventory value, it will use the same product prices and quantities throughout its execution, even if another transaction updates and commits price changes in the meantime.

#### SERIALIZABLE

The strictest isolation level. Ensures that if a set of transactions executed concurrently, the result is the same as if they were executed one after another in some sequence.

```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    -- Operations that might conflict with concurrent transactions
    UPDATE inventory SET stock = stock - 10 WHERE product_id = 101;
    -- If another transaction modified the same data concurrently,
    -- one of the transactions will fail with a serialization error
COMMIT;
```

**Example**: In a ticket booking system with SERIALIZABLE isolation, if two transactions simultaneously try to book the last seat on a flight, one will succeed and one will fail with a serialization error, preventing accidental overbooking.

### Changing Isolation Levels

Isolation levels can be set at different scopes:

```sql
-- Set for the current transaction only
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Set for all future transactions in the current session
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Set system-wide default (requires appropriate privileges)
ALTER SYSTEM SET default_transaction_isolation = 'serializable';
```

### Concurrency Issues and Solutions

#### Common Concurrency Problems

1. **Dirty Reads**: Reading uncommitted changes made by another transaction (prevented in PostgreSQL)
2. **Non-repeatable Reads**: Getting different results when reading the same row twice in a transaction
3. **Phantom Reads**: A transaction re-executes a query and gets different rows
4. **Serialization Anomalies**: Results of concurrent transactions differ from any sequential execution

#### Addressing Concurrency with Isolation Levels

|Isolation Level|Dirty Reads|Non-repeatable Reads|Phantom Reads|Serialization Anomalies|
|---|---|---|---|---|
|READ UNCOMMITTED|Prevented|Possible|Possible|Possible|
|READ COMMITTED|Prevented|Possible|Possible|Possible|
|REPEATABLE READ|Prevented|Prevented|Prevented in PostgreSQL (not in SQL standard)|Possible|
|SERIALIZABLE|Prevented|Prevented|Prevented|Prevented|

#### Row-Level Locking

PostgreSQL uses row-level locking to manage concurrent access to the same rows.

```sql
-- Explicit row locking
BEGIN;
    -- Select and lock rows for update
    SELECT * FROM inventory 
    WHERE product_id = 101 
    FOR UPDATE;
    
    -- Now other transactions cannot update this row until this transaction completes
    UPDATE inventory 
    SET stock = stock - 10 
    WHERE product_id = 101;
COMMIT;
```

**Example**: In a warehouse management system, before reducing inventory for a product, you can lock the specific inventory row to prevent other orders from claiming the same inventory simultaneously, avoiding overselling.

#### Advisory Locks

PostgreSQL provides advisory locks for application-controlled locking strategies.

```sql
-- Acquire an advisory lock
SELECT pg_advisory_lock(101);

-- Do some work requiring exclusive access to resource #101

-- Release the lock
SELECT pg_advisory_unlock(101);
```

**Example**: When performing a complex batch process that spans multiple tables and doesn't map neatly to row locks, you can use an advisory lock to ensure only one process executes the batch job at a time.

### Transaction Management Best Practices

#### Keep Transactions Short

Long-running transactions hold locks and can impact system performance.

```sql
-- Bad practice: very long transaction
BEGIN;
    -- Perform extensive analysis on data
    -- Generate a large report
    -- Send emails
    -- Update multiple tables
COMMIT;

-- Better practice: separate read-only and write operations
-- Read-only transaction for analysis
BEGIN;
    -- Perform extensive analysis on data
    -- Store results in temporary tables if needed
COMMIT;

-- Short transaction for updates
BEGIN;
    -- Apply necessary changes based on analysis
COMMIT;
```

#### Use Explicit Transactions

Always use explicit transactions for multi-statement operations that need to be atomic.

```sql
-- Without explicit transaction, if the second statement fails,
-- the first change remains in the database
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;

-- With explicit transaction, all or nothing
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;
```

#### Handle Deadlocks Appropriately

Deadlocks can occur when transactions lock resources in different orders.

```sql
-- Transaction might fail with deadlock error
BEGIN;
    -- Deadlock handling
    SET LOCAL deadlock_timeout = '1s';
    
    -- If a deadlock occurs, PostgreSQL will automatically roll back
    -- one of the transactions, and you can catch and retry
    UPDATE table_a SET col = val WHERE id = 1;
    UPDATE table_b SET col = val WHERE id = 2;
COMMIT;
```

**Example**: If transaction A locks row 1 then tries to lock row 2, while transaction B locks row 2 then tries to lock row 1, they'll deadlock. PostgreSQL will detect this and terminate one transaction after the deadlock timeout period.

#### Choose Appropriate Isolation Levels

Select the minimum isolation level that meets your application's consistency requirements.

```sql
-- Use READ COMMITTED for most operations
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
    UPDATE products SET stock = stock - 1 WHERE product_id = 101;
COMMIT;

-- Use SERIALIZABLE for critical financial operations
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    -- Transfer money between accounts
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;
```

### Advanced Transaction Features

#### Deferrable Constraints

PostgreSQL allows deferring constraint checking until transaction commit.

```sql
BEGIN;
    -- Make constraints deferrable for this transaction
    SET CONSTRAINTS ALL DEFERRED;
    
    -- These operations would normally violate foreign key constraints
    -- but checking is deferred until COMMIT
    DELETE FROM parent WHERE id = 100;
    DELETE FROM child WHERE parent_id = 100;
COMMIT;
```

**Example**: When moving data between parent and child tables, you might need to temporarily violate foreign key constraints. Deferrable constraints allow you to perform these operations in any order within a transaction, as long as the constraints are satisfied at commit time.

#### Two-Phase Commit (2PC)

For distributed transactions across multiple databases.

```sql
-- On database 1
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    -- Prepare the transaction for commit
    PREPARE TRANSACTION 'money_transfer_1';

-- On database 2
BEGIN;
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
    -- Prepare the transaction for commit
    PREPARE TRANSACTION 'money_transfer_2';

-- If both prepare successfully, commit both
-- On database 1
COMMIT PREPARED 'money_transfer_1';

-- On database 2
COMMIT PREPARED 'money_transfer_2';
```

**Example**: In a banking system with accounts in different database shards, two-phase commit ensures that money transfers either complete on both sides or fail completely, maintaining consistency across databases.

#### Transaction Triggers

Triggers that fire at transaction start, end, or on rollback.

```sql
-- Create a function for the trigger
CREATE OR REPLACE FUNCTION log_transaction() RETURNS trigger AS $$
BEGIN
    INSERT INTO transaction_log (event, user_id, event_time)
    VALUES (TG_ARGV[0], current_user, current_timestamp);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
CREATE TRIGGER transaction_start_trigger
AFTER TRANSACTIONAL STATEMENT EXECUTE PROCEDURE log_transaction('transaction_start');

CREATE TRIGGER transaction_end_trigger
BEFORE COMMIT EXECUTE PROCEDURE log_transaction('transaction_commit');

CREATE TRIGGER transaction_rollback_trigger
BEFORE ROLLBACK EXECUTE PROCEDURE log_transaction('transaction_rollback');
```

### Error Handling in Transactions

#### Exception Handling

In stored procedures, you can handle exceptions and control transaction flow.

```sql
CREATE OR REPLACE FUNCTION transfer_funds(
    sender_id INT, 
    receiver_id INT, 
    amount DECIMAL
) RETURNS BOOLEAN AS $$
BEGIN
    -- Begin explicit transaction
    BEGIN
        -- Check if sender has sufficient funds
        PERFORM balance FROM accounts 
        WHERE account_id = sender_id AND balance >= amount;
        
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Insufficient funds in account %', sender_id;
        END IF;
        
        -- Perform the transfer
        UPDATE accounts SET balance = balance - amount 
        WHERE account_id = sender_id;
        
        UPDATE accounts SET balance = balance + amount 
        WHERE account_id = receiver_id;
        
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Receiver account % not found', receiver_id;
        END IF;
        
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            -- Any exception will roll back the transaction
            RAISE NOTICE 'Transaction failed: %', SQLERRM;
            RETURN FALSE;
    END;
END;
$$ LANGUAGE plpgsql;
```

**Example**: In a money transfer function, if either the sender has insufficient funds or the receiver account doesn't exist, the function catches the exception, rolls back any changes, and returns failure information to the calling application.

#### Handling Serialization Failures

Applications should be designed to handle serialization failures by retrying transactions.

```sql
CREATE OR REPLACE FUNCTION retry_on_serialization_failure() RETURNS INTEGER AS $$
DECLARE
    max_attempts INT := 3;
    attempts INT := 0;
    result INT;
BEGIN
    LOOP
        attempts := attempts + 1;
        BEGIN
            -- Set serializable isolation for this transaction block
            SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
            
            -- Attempt to perform the operation
            SELECT COUNT(*) INTO result FROM inventory WHERE stock > 0;
            UPDATE inventory SET stock = stock - 1 WHERE id = 101;
            
            -- If we reach here, operation succeeded
            EXIT;
        EXCEPTION
            WHEN serialization_failure THEN
                -- On serialization failure, retry if under max attempts
                IF attempts < max_attempts THEN
                    RAISE NOTICE 'Serialization failure, retrying (attempt %/%)', 
                                 attempts, max_attempts;
                    CONTINUE;
                ELSE
                    RAISE EXCEPTION 'Failed after % attempts', max_attempts;
                END IF;
        END;
    END LOOP;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;
```

### Monitoring Transaction Activity

#### Viewing Active Transactions

```sql
SELECT 
    pid,
    usename, 
    application_name,
    client_addr,
    backend_start,
    xact_start,
    query_start,
    state,
    query
FROM 
    pg_stat_activity
WHERE 
    state = 'active';
```

#### Identifying Long-Running Transactions

```sql
SELECT 
    pid,
    usename,
    application_name,
    age(now(), xact_start) AS transaction_age,
    state,
    query
FROM 
    pg_stat_activity
WHERE 
    xact_start IS NOT NULL
ORDER BY 
    xact_start ASC;
```

#### Detecting and Resolving Deadlocks

```sql
-- Check deadlock count
SELECT deadlocks FROM pg_stat_database WHERE datname = current_database();

-- Terminate a blocked process if necessary
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE pid = [blocked_process_id];
```

### Real-World Application Examples

#### E-commerce Order Processing

```sql
BEGIN;
    -- Insert the order header
    INSERT INTO orders (customer_id, order_date, shipping_address, total_amount)
    VALUES (42, CURRENT_TIMESTAMP, '123 Main St, Anytown', 159.97)
    RETURNING order_id INTO order_id_var;
    
    -- Insert order items
    INSERT INTO order_items (order_id, product_id, quantity, price)
    VALUES
        (order_id_var, 101, 2, 49.99),
        (order_id_var, 205, 1, 59.99);
    
    -- Update inventory
    UPDATE inventory SET stock = stock - 2 WHERE product_id = 101;
    UPDATE inventory SET stock = stock - 1 WHERE product_id = 205;
    
    -- Create shipping request
    INSERT INTO shipping_queue (order_id, priority, created_at)
    VALUES (order_id_var, 'standard', CURRENT_TIMESTAMP);
    
    -- Process payment
    INSERT INTO payments (order_id, payment_method, amount, status)
    VALUES (order_id_var, 'credit_card', 159.97, 'processed');
COMMIT;
```

**Example**: When a customer places an order, the system must create the order, add line items, reduce inventory, queue for shipping, and process payment—all as an atomic unit to maintain data consistency.

#### Banking System

```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    -- Check sufficient funds
    SELECT balance INTO current_balance
    FROM accounts
    WHERE account_id = 1001
    FOR UPDATE;
    
    IF current_balance < 500 THEN
        ROLLBACK;
        RAISE EXCEPTION 'Insufficient funds';
    END IF;
    
    -- Process withdrawal
    UPDATE accounts SET balance = balance - 500
    WHERE account_id = 1001;
    
    -- Record transaction
    INSERT INTO account_transactions 
        (account_id, transaction_type, amount, transaction_date)
    VALUES 
        (1001, 'withdrawal', 500, CURRENT_TIMESTAMP);
    
    -- Update daily withdrawal total
    INSERT INTO daily_limits 
        (account_id, date, total_withdrawn)
    VALUES 
        (1001, CURRENT_DATE, 500)
    ON CONFLICT (account_id, date) 
    DO UPDATE SET total_withdrawn = daily_limits.total_withdrawn + 500;
COMMIT;
```

**Example**: A banking ATM withdrawal must check available funds, reduce the account balance, record the transaction, and update daily withdrawal limits as a single atomic operation with the highest isolation level to prevent race conditions.

#### Inventory Management

```sql
BEGIN;
    -- Lock the specific inventory item to prevent concurrent modifications
    SELECT * FROM inventory 
    WHERE product_id = 1234 
    FOR UPDATE;
    
    -- Check if enough stock is available
    SELECT stock INTO current_stock FROM inventory WHERE product_id = 1234;
    
    IF current_stock < 5 THEN
        -- Not enough stock, roll back and notify
        ROLLBACK;
        RAISE EXCEPTION 'Insufficient stock available: %', current_stock;
    ELSE
        -- Update inventory
        UPDATE inventory SET 
            stock = stock - 5,
            last_updated = CURRENT_TIMESTAMP
        WHERE product_id = 1234;
        
        -- Record stock movement
        INSERT INTO stock_movements 
            (product_id, quantity, movement_type, reference, movement_date)
        VALUES 
            (1234, 5, 'sale', 'order-5678', CURRENT_TIMESTAMP);
        
        -- Check if reorder is needed
        SELECT stock, reorder_level INTO current_stock, reorder_threshold
        FROM inventory WHERE product_id = 1234;
        
        IF current_stock <= reorder_threshold THEN
            -- Create restock request
            INSERT INTO purchase_requests
                (product_id, quantity_requested, urgency, request_date)
            VALUES
                (1234, 100, 'normal', CURRENT_TIMESTAMP);
        END IF;
        
        COMMIT;
    END IF;
END;
```

### Related Topics

- PostgreSQL locking mechanisms
- Database sharding and distributed transactions
- PostgreSQL replication and transaction logs
- High availability and transaction durability
- Performance tuning for transactional workloads

---

