## Data Types


### MONEY Data Type

The **MONEY** data type in PostgreSQL is a specialized numeric type designed for storing currency amounts with a fixed precision of two decimal places. It is optimized for financial applications, providing a convenient way to handle monetary values while respecting locale-specific formatting (e.g., currency symbols, decimal separators). Given your context (e.g., familiarity with `NUMERIC(10,2)`, `pg_dump`, tablespaces, and PostgreSQL administration), this response explains the MONEY data type in detail, including its characteristics, usage, advantages, limitations, and comparisons to alternatives like `NUMERIC`. It also addresses practical considerations for **Online Transaction Processing (OLTP)** and **Online Analytical Processing (OLAP)** systems.

#### What is the MONEY Data Type?
- **Definition**: The MONEY data type stores currency amounts as a 64-bit integer internally, scaled by 100 to represent two decimal places (e.g., `$12.34` is stored as `1234` cents).
- **Range**: Supports values from `-92233720368547758.08` to `+92233720368547758.07` (roughly ±92 quintillion).
- **Storage**: Uses 8 bytes, similar to a `BIGINT`.
- **Formatting**: Output is locale-dependent, controlled by the `LC_MONETARY` setting (related to your interest in `LC_COLLATE`/`LC_CTYPE`), which determines currency symbols, decimal points, and thousands separators.
- **Example**:
  ```sql
  SET LC_MONETARY = 'en_US.UTF-8';
  CREATE TABLE transactions (id SERIAL, amount MONEY);
  INSERT INTO transactions (amount) VALUES (1234.56);
  SELECT amount FROM transactions;
  ```
  **Output**:
  ```
   amount   
  ----------
   $1,234.56
  ```
  - With `LC_MONETARY = 'de_DE.UTF-8'`, the same value outputs as `1.234,56 €`.

#### Characteristics
1. **Precision and Scale**:
   - Fixed at two decimal places, suitable for most currency applications (e.g., dollars and cents, euros and cents).
   - Unlike `NUMERIC(10,2)`, which allows customizable precision (e.g., 10 total digits, 2 after the decimal), MONEY has a predefined scale.

2. **Locale Dependency**:
   - The display format depends on the server’s `LC_MONETARY` setting, set at database creation or session level.
   - Example: `$1,234.56` (US), `£1,234.56` (UK), `1.234,56 €` (Germany).
   - Input parsing also respects locale (e.g., `'$1,234.56'` or `'1.234,56'` depending on `LC_MONETARY`).

3. **Performance**:
   - Efficient storage (8 bytes) and fast arithmetic due to integer-based representation.
   - Slightly faster than `NUMERIC` for basic operations (e.g., addition, subtraction) but less flexible for complex calculations.

4. **Operations**:
   - Supports arithmetic (`+`, `-`, `*`, `/`) and comparisons (`=`, `<>`, `<`, `>`).
   - Multiplication/division with non-MONEY types requires casting:
     ```sql
     SELECT amount * 1.1::NUMERIC FROM transactions; -- Apply 10% increase
     ```
   - Aggregates like `SUM`, `AVG`, and `MAX` work directly:
     ```sql
     SELECT SUM(amount) FROM transactions;
     ```

#### Usage in PostgreSQL
The MONEY data type is used in scenarios where currency values are stored and displayed consistently, such as financial applications.

1. **Creating a Table with MONEY**:
   ```sql
   CREATE TABLE orders (
       id SERIAL PRIMARY KEY,
       total MONEY NOT NULL
   );
   INSERT INTO orders (total) VALUES (99.99), ('$1,234.56');
   ```

2. **Querying and Formatting**:
   ```sql
   SET LC_MONETARY = 'en_US.UTF-8';
   SELECT total, to_char(total, 'FM9999999.99') AS formatted
   FROM orders;
   ```
   **Output**:
   ```
     total     | formatted  
   ------------+-----------
    $99.99     | 99.99     
    $1,234.56  | 1234.56   
   ```
   - `to_char` removes locale-specific symbols for consistent output.

3. **Size and Tablespace** (related to your tablespace question):
   - Use `pg_total_relation_size` to monitor table size:
     ```sql
     SELECT pg_size_pretty(pg_total_relation_size('orders'));
     ```
   - Store MONEY-heavy tables in a fast tablespace (e.g., `fast_ssd`) for **OLTP** performance.

4. **Dumping and Restoring** (related to your `pg_dump` question):
   - MONEY data is included in `--data-only` dumps and schema definitions in `--schema-only` dumps.
   - Example:
     ```bash
     pg_dump -Fc --data-only mydb > data.dump
     pg_restore -d mydb_clone data.dump
     ```
   - Ensure `LC_MONETARY` matches during restore to avoid formatting issues.

#### Advantages
- **Simplicity**: Built-in support for currency with two decimal places, no need to define precision like `NUMERIC(10,2)`.
- **Locale Awareness**: Automatically formats output based on `LC_MONETARY`, ideal for user-facing applications (e.g., invoices in **OLTP**).
- **Efficiency**: Compact storage (8 bytes) and fast integer-based arithmetic for **OLTP** workloads.
- **Readability**: Human-readable output (e.g., `$1,234.56`) without manual formatting.

#### Limitations
- **Locale Dependency**: Output and input formats vary by `LC_MONETARY`, which can cause issues in multi-region applications or during migrations (e.g., `pg_restore` to a database with different `LC_MONETARY`).
- **Fixed Precision**: Limited to two decimal places, unsuitable for currencies requiring more (e.g., some cryptocurrencies) or non-currency calculations.
- **Portability**: Not SQL-standard; other databases (e.g., MySQL) lack a direct equivalent, making `NUMERIC` more portable.
- **Arithmetic Constraints**: Division or multiplication with non-MONEY types requires casting to `NUMERIC`, adding complexity:
  ```sql
  SELECT amount / 2::NUMERIC FROM transactions; -- Division not directly supported
  ```
- **Rounding**: Implicit rounding to two decimal places can affect precision in complex calculations.

#### Comparison to NUMERIC (Related to Your `NUMERIC(10,2)` Question)
| **Aspect**            | **MONEY**                              | **NUMERIC(10,2)**                      |
|-----------------------|----------------------------------------|----------------------------------------|
| **Precision**         | Fixed 2 decimal places                | Configurable (10 total digits, 2 after decimal) |
| **Storage**           | 8 bytes (integer-based)               | Variable (depends on value, ~8-16 bytes) |
| **Performance**       | Faster for simple arithmetic          | Slower due to arbitrary precision      |
| **Locale**            | `LC_MONETARY`-dependent formatting    | No locale formatting (plain numbers)   |
| **Portability**       | PostgreSQL-specific                   | SQL-standard, portable                 |
| **Use Case**          | Currency with locale-aware display    | General-purpose, precise calculations  |
| **Example Value**     | `$1,234.56` (locale: `en_US.UTF-8`)  | `1234.56`                              |

**When to Use**:
- **MONEY**: For currency values in **OLTP** (e.g., order totals, account balances) or **OLAP** (e.g., revenue reports) where locale-specific formatting is desired and two decimal places suffice.
- **NUMERIC**: For precise calculations, non-currency numbers, or cross-database compatibility (e.g., `NUMERIC(10,2)` for prices, `NUMERIC(20,8)` for scientific data).

#### Practical Example
Create a table with both MONEY and NUMERIC for comparison:
```sql
SET LC_MONETARY = 'en_US.UTF-8';
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    amount_money MONEY,
    amount_numeric NUMERIC(10,2)
);
INSERT INTO payments (amount_money, amount_numeric)
VALUES (1234.56, 1234.56), ('$99.99', 99.99);
SELECT 
    amount_money,
    amount_numeric,
    to_char(amount_money, 'FM9999999.99') AS money_formatted
FROM payments;
```

**Output**:
```
 amount_money | amount_numeric | money_formatted 
--------------+----------------+-----------------
  $1,234.56   |        1234.56 | 1234.56         
    $99.99    |          99.99 | 99.99           
```

**Size Check** (using your `pg_size_pretty` query):
```sql
SELECT pg_size_pretty(pg_total_relation_size('payments'));
```
**Output** (example): `16 kB`

#### Best Practices
1. **Match Locale**:
   - Ensure `LC_MONETARY` aligns with your application’s region (e.g., `SET LC_MONETARY = 'en_US.UTF-8';`).
   - Verify database collation (`\l+`) to avoid formatting mismatches, especially after `pg_restore`.
2. **Use NUMERIC for Flexibility**:
   - Prefer `NUMERIC(10,2)` for multi-region apps or when precision beyond two decimal places is needed.
   - Example: `CREATE TABLE prices (cost NUMERIC(10,2));`.
3. **Format Consistently**:
   - Use `to_char` for locale-independent output in **OLAP** reports:
     ```sql
     SELECT to_char(amount, 'FM9999999.99') FROM transactions;
     ```
4. **Monitor Storage**:
   - Combine MONEY tables with tablespaces (e.g., `fast_ssd`) for performance.
   - Use `pg_total_relation_size` to track growth, as in your query.
5. **Secure Data**:
   - Apply row-level security (RLS) to MONEY tables and manage `BYPASSRLS` roles carefully.
   - Use `hostssl` in `pg_hba.conf` for secure access.
6. **Backup and Restore**:
   - Include MONEY data in `pg_dump -Fc` backups.
   - Test restores to ensure `LC_MONETARY` compatibility.

#### Related Concepts
- **LC_MONETARY**: Controls MONEY formatting, set at session or database level (related to your `LC_COLLATE`/`LC_CTYPE` interest).
- **Tablespaces**: Store MONEY-heavy tables on fast storage (e.g., `ALTER TABLE transactions SET TABLESPACE fast_ssd;`).
- **pg_dump/pg_restore**: MONEY data is portable, but locale settings must match.
- **NUMERIC**: Alternative for precise or portable currency storage.
- **OID**: MONEY columns are stored in tables identified by OIDs in `pg_class`.

#### Troubleshooting
- **Formatting Issues**:
  - If MONEY output is unexpected (e.g., wrong currency), check `LC_MONETARY`:
    ```sql
    SHOW LC_MONETARY;
    ```
  - Set session-level: `SET LC_MONETARY = 'en_US.UTF-8';`.
- **Migration Errors**:
  - Ensure target database has compatible `LC_MONETARY` during `pg_restore`.
  - Cast to `NUMERIC` for locale-independent dumps:
    ```sql
    SELECT amount::NUMERIC FROM transactions;
    ```
- **Performance**:
  - Index MONEY columns for **OLTP** queries (e.g., `CREATE INDEX idx_amount ON transactions(amount);`).
  - Monitor table size with `pg_total_relation_size`.

#### Next Steps
- Test MONEY in a table:
  ```sql
  CREATE TABLE sales (id SERIAL, price MONEY);
  INSERT INTO sales (price) VALUES (99.99);
  ```
- Check formatting:
  ```sql
  SET LC_MONETARY = 'en_US.UTF-8';
  SELECT price FROM sales;
  ```
- Monitor size:
  ```sql
  SELECT pg_size_pretty(pg_total_relation_size('sales'));
  ```
- Compare with `NUMERIC(10,2)` in a test table to evaluate performance and portability.

---

