## Understanding Query Execution Plans (EXPLAIN and EXPLAIN ANALYZE)


### What Are Query Execution Plans?

A query execution plan (also called a query plan or execution plan) is a detailed breakdown of how a database system intends to execute a SQL query. Database management systems (DBMS) use sophisticated optimizers to evaluate multiple possible execution strategies for a given query and select the one expected to be most efficient.

**Key Points**:

- Query execution plans show the step-by-step operations the database will perform
- They reveal which indexes are used, how tables are joined, and in what order
- Understanding execution plans helps identify performance bottlenecks
- Different database systems have their own syntax and output formats for execution plans

### The EXPLAIN Command

The EXPLAIN command is a diagnostic tool available in most relational database systems that displays the execution plan the query optimizer has chosen for a specific SQL statement without actually executing the query.

#### Basic Syntax

```sql
EXPLAIN SELECT * FROM customers WHERE customer_id = 123;
```

The output varies significantly across different database systems:

### PostgreSQL's EXPLAIN Output

In PostgreSQL, the EXPLAIN command shows:

- The query plan nodes (scan methods, join types)
- Estimated startup and total cost for each operation
- Estimated number of rows to be processed
- Estimated average width of rows in bytes

**Example**:

```sql
EXPLAIN SELECT * FROM orders JOIN customers ON orders.customer_id = customers.id
WHERE orders.total_amount > 100;
```

**Output**:

```
Nested Loop  (cost=0.29..35.17 rows=10 width=180)
  ->  Seq Scan on orders  (cost=0.00..22.70 rows=10 width=72)
        Filter: (total_amount > 100)
  ->  Index Scan using customers_pkey on customers  (cost=0.29..1.24 rows=1 width=108)
        Index Cond: (id = orders.customer_id)
```

### MySQL's EXPLAIN Output

MySQL's EXPLAIN presents information in a tabular format with the following columns:

- id: The sequential identifier for each query part
- select_type: The type of SELECT (SIMPLE, PRIMARY, UNION, etc.)
- table: The table referenced
- type: The join type (system, const, eq_ref, ref, range, index, ALL)
- possible_keys: Indexes that could be used
- key: The index actually used
- key_len: The length of the key used
- ref: Columns or constants compared to the index
- rows: Estimated number of rows examined
- Extra: Additional information

### Oracle's EXPLAIN PLAN

Oracle requires a slightly different approach:

```sql
EXPLAIN PLAN FOR SELECT * FROM employees WHERE department_id = 10;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

### SQL Server's EXPLAIN (SHOWPLAN)

SQL Server uses SET SHOWPLAN_TEXT or SET SHOWPLAN_ALL instead of EXPLAIN:

```sql
SET SHOWPLAN_ALL ON;
GO
SELECT * FROM Customers WHERE CustomerID = 'ALFKI';
GO
SET SHOWPLAN_ALL OFF;
```

### EXPLAIN ANALYZE - Taking It Further

While EXPLAIN shows the planned execution strategy, EXPLAIN ANALYZE goes a step further by actually executing the query and comparing the estimated costs with real execution metrics.

#### PostgreSQL EXPLAIN ANALYZE

```sql
EXPLAIN ANALYZE SELECT * FROM products WHERE price > 50;
```

**Output**:

```
Seq Scan on products  (cost=0.00..22.00 rows=200 width=98) (actual time=0.014..0.126 rows=120 loops=1)
  Filter: (price > 50)
  Rows Removed by Filter: 180
Planning Time: 0.082 ms
Execution Time: 0.158 ms
```

**Key Points**:

- Shows both estimated (cost) and actual execution statistics
- Reports actual execution time and row counts
- Reveals discrepancies between estimates and reality
- More useful for real-world performance tuning than basic EXPLAIN

### Common Plan Operations

#### Table Scan Types

- **Sequential Scan**: Reading the entire table from start to finish
- **Index Scan**: Using an index to look up specific rows
- **Index Only Scan**: Retrieving data directly from the index without accessing the table
- **Bitmap Scan**: Using a bitmap in memory to track qualifying rows

#### Join Methods

- **Nested Loop Join**: For each row in the outer table, scan the inner table
- **Hash Join**: Build a hash table from the smaller table, then probe with rows from the larger table
- **Merge Join**: Sort both tables on the join key, then merge them together

### Interpreting Execution Plans

#### Cost Metrics

Most databases express "cost" as arbitrary units representing:

- I/O operations (disk reads/writes)
- CPU processing time
- Memory usage

Higher costs indicate more resource-intensive operations.

#### Identifying Performance Issues

Look for:

1. **Full table scans** when indexes should be used
2. **Unused indexes** that were created but not utilized
3. **Index scans** that return large portions of a table
4. **Inefficient join methods** for the data characteristics
5. **Large discrepancies** between estimated and actual row counts

### Optimizing Based on Execution Plans

Once you identify performance issues through EXPLAIN or EXPLAIN ANALYZE, you can implement solutions:

#### Adding Effective Indexes

If the plan shows full table scans on frequently filtered columns:

```sql
CREATE INDEX idx_customers_lastname ON customers(last_name);
```

#### Rewriting Queries

Original query:

```sql
SELECT * FROM orders WHERE total_amount::text LIKE '1%';
```

Better version:

```sql
SELECT * FROM orders WHERE total_amount >= 100 AND total_amount < 200;
```

#### Statistics Management

Ensure statistics are up-to-date:

```sql
-- PostgreSQL
ANALYZE orders;

-- MySQL
ANALYZE TABLE orders;

-- SQL Server
UPDATE STATISTICS orders;
```

### Common Query Plan Patterns and What They Mean

#### Anti-Pattern: Expensive Sort Operations

```
Sort  (cost=283.40..288.40 rows=2000 width=16) (actual time=3.116..3.318 rows=2000 loops=1)
  Sort Key: id
  Sort Method: quicksort  Memory: 192kB
```

**Solution**: Add an index on the sort column or use indexed views/materialized views.

#### Anti-Pattern: Nested Loop with Many Iterations

```
Nested Loop  (cost=0.29..327.41 rows=980 width=16) (actual time=0.019..8.312 rows=1000 loops=1)
```

**Solution**: Consider hash joins for larger datasets by ensuring proper join column types and statistics.

### Database-Specific Features

#### PostgreSQL

- Visual explain with `EXPLAIN (FORMAT JSON)` and visualization tools
- Buffer usage statistics with `EXPLAIN (ANALYZE, BUFFERS)`
- WAL usage with `EXPLAIN (ANALYZE, WAL)`

#### MySQL

- Extended EXPLAIN format:
    
    ```sql
    EXPLAIN FORMAT=JSON SELECT * FROM orders;
    ```
    
- Visual explain in MySQL Workbench

#### Oracle

- DBMS_XPLAN package with various display options:
    
    ```sql
    SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null, null, 'ALLSTATS LAST'));
    ```
    

#### SQL Server

- Includes visual execution plans in Management Studio
- Live Query Statistics for real-time execution monitoring

### When to Use EXPLAIN vs. EXPLAIN ANALYZE

**Use EXPLAIN when**:

- You want a quick overview without executing the query
- Working with potentially long-running queries
- In production environments where execution might affect performance

**Use EXPLAIN ANALYZE when**:

- You need precise execution metrics
- Comparing different query approaches
- Troubleshooting discrepancies between expected and actual performance
- Working in development or testing environments

### Best Practices

1. **Compare Before and After**: Always get a baseline execution plan before making changes
2. **Focus on the Biggest Costs**: Address the most expensive operations first
3. **Watch for Plan Changes**: Monitor how execution plans change after database growth or schema changes
4. **Understand Statistics**: Keep statistics updated for accurate cardinality estimates
5. **Test with Realistic Data Volumes**: Small test datasets may produce different plans than production data

### Troubleshooting Common Issues

#### Problem: Optimizer Choosing Wrong Index

When PostgreSQL chooses a suboptimal index:

```sql
-- Force index usage for testing
SET enable_seqscan = off;
EXPLAIN ANALYZE SELECT * FROM large_table WHERE indexed_column = 'value';
```

#### Problem: Join Order Issues

If the optimizer chooses a poor join order:

```sql
-- MySQL hint example
EXPLAIN SELECT /*+ JOIN_ORDER(orders, customers) */ 
  o.order_id, c.customer_name 
FROM orders o JOIN customers c ON o.customer_id = c.id;
```

### Recent Advances in Execution Plan Technology

- **Just-In-Time (JIT) Compilation**: PostgreSQL 11+ shows JIT compilation steps
- **Adaptive Query Execution**: Oracle and SQL Server adapt plans during execution
- **Machine Learning Optimizers**: Systems like Google's Blink use ML to improve query planning

### Tools for Visualizing Execution Plans

- **pgMustard**: Analyzes PostgreSQL execution plans and suggests improvements
- **PEV**: PostgreSQL Explain Visualizer (browser-based)
- **SentryOne Plan Explorer**: SQL Server plan visualization and analysis
- **Octopus**: MySQL visual query plans

**Conclusion**:

Understanding query execution plans is essential for database performance tuning. EXPLAIN shows how the database intends to execute a query, while EXPLAIN ANALYZE provides actual execution metrics. By analyzing these plans, you can identify bottlenecks, optimize indexes, rewrite problematic queries, and ensure your database performs optimally even as it scales. Regular review of execution plans should be part of your database maintenance routine, especially when performance issues arise or when deploying significant changes to database structure or query patterns.

### Related Topics

- Query optimization techniques
- Index design strategies
- Database statistics management
- Database-specific tuning parameters
- Query plan caching and reuse

---

