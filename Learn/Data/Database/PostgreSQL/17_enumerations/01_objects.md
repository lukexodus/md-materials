## Objects


### OID 

An **OID** (Object Identifier) in PostgreSQL is a unique, system-assigned numeric identifier (type `oid`) for database objects like tables, databases, schemas, roles, or rows in system catalogs. OIDs are used internally to reference objects in system tables (e.g., `pg_class`, `pg_database`).

**Key Points**:
- **Purpose**: Tracks objects uniquely across the database cluster (e.g., table `employees` has an OID in `pg_class`).
- **Usage**: Found in system catalogs (e.g., `SELECT oid, relname FROM pg_class WHERE relname = 'employees';`).
- **Functions**: Used with functions like `pg_database_size(oid)` or `pg_total_relation_size(oid)` (e.g., `SELECT pg_size_pretty(pg_database_size(oid)) FROM pg_database WHERE datname = 'my_application_db';`).
- **Default Behavior**: Since PostgreSQL 12, OIDs are not assigned to user tables by default (set `default_with_oids = false`); system tables still use them.
- **Relevance**: Useful for querying metadata (e.g., size, triggers) or debugging, but rarely needed in application code for **OLTP** or **OLAP**.
- **Check**: Use `\d+` in `psql` to see OIDs indirectly or query `pg_catalog` (e.g., `SELECT oid FROM pg_trigger WHERE tgname = 'employee_audit_trigger';`).

**Example**:
```sql
SELECT oid, datname FROM pg_database WHERE datname = 'my_application_db';
```
**Output** (example):
```
  oid  |      datname      
-------+--------------------
 16384 | my_application_db
```

---

###  Tablespaces 

A **tablespace** in PostgreSQL is a logical storage location that defines where database objects, such as tables, indexes, and materialized views, are physically stored on disk. Tablespaces allow administrators to control the placement of data files across different storage devices or directories to optimize performance, manage disk space, or meet organizational requirements. They are particularly useful in **Online Transaction Processing (OLTP)** systems (e.g., for high-concurrency workloads) and **Online Analytical Processing (OLAP)** systems (e.g., for large data warehouses). This response explains tablespaces, their purpose, creation, usage, and related concepts, tailored to your context of PostgreSQL administration (e.g., familiarity with `pg_dump`, `pg_size_pretty`, and OIDs).

#### What is a Tablespace?
- A tablespace is a named location on the filesystem where PostgreSQL stores data files for database objects.
- Each tablespace maps to a specific directory on the server, and objects like tables or indexes are assigned to a tablespace to control their storage location.
- Tablespaces are cluster-wide, meaning they are shared across all databases in a PostgreSQL instance but can be used selectively per database, schema, or object.
- Default tablespaces: `pg_default` (for user objects) and `pg_global` (for system catalog objects).

**Example**: A tablespace named `fast_ssd` might map to `/mnt/ssd/pgdata`, where high-performance tables are stored.

#### Purpose of Tablespaces
Tablespaces provide flexibility in storage management, addressing several use cases:
1. **Performance Optimization**:
   - Place frequently accessed tables or indexes on faster storage (e.g., SSDs) for **OLTP** workloads.
   - Store large, infrequently accessed data (e.g., historical data in **OLAP**) on slower, cheaper storage (e.g., HDDs).
2. **Disk Space Management**:
   - Distribute data across multiple disks to avoid running out of space.
   - Organize data by project, department, or workload (e.g., separate tablespaces for `sales` and `analytics`).
3. **Backup and Recovery**:
   - Simplify backups by isolating critical data to specific directories.
   - Support partial restores with `pg_restore` when combined with `--schema-only` or `--data-only` dumps.
4. **Security and Organization**:
   - Restrict access to tablespaces via filesystem permissions (e.g., only the PostgreSQL user can access the directory).
   - Logically separate data for different applications or schemas.

#### Key Components and Concepts
1. **Default Tablespaces**:
   - **pg_default**: Stores user-created tables, indexes, and materialized views unless another tablespace is specified. Located in the PostgreSQL data directory (e.g., `$PGDATA/base`).
   - **pg_global**: Stores system catalog tables (e.g., `pg_class`, `pg_authid`) shared across all databases. Located in `$PGDATA/global`.
   - Example: Your `my_application_db` tables (e.g., queried with `pg_total_relation_size`) likely use `pg_default` unless customized.

2. **Custom Tablespaces**:
   - Created by administrators to map to specific directories (e.g., `/mnt/ssd/pgdata`).
   - Assigned to databases, schemas, tables, or indexes via `TABLESPACE` clauses.

3. **OID Relationship**:
   - Each tablespace has an OID in `pg_tablespace` (e.g., `SELECT oid, spcname FROM pg_tablespace;`).
   - Used internally to track storage locations, similar to how OIDs identify tables in `pg_class`.

#### Creating and Using Tablespaces
Here’s how to create and use a tablespace in PostgreSQL:

1. **Create a Tablespace**:
   ```sql
   CREATE TABLESPACE fast_ssd
   OWNER postgres
   LOCATION '/mnt/ssd/pgdata';
   ```
   - **LOCATION**: Must be an absolute path to an existing, empty directory owned by the PostgreSQL user (e.g., `postgres`).
   - **OWNER**: The role that owns the tablespace (typically `postgres`).
   - **Permissions**: Ensure the directory has correct permissions (e.g., `chmod 700 /mnt/ssd/pgdata`, `chown postgres:postgres /mnt/ssd/pgdata`).

2. **Assign a Tablespace**:
   - **To a Database**:
     ```sql
     CREATE DATABASE mydb TABLESPACE fast_ssd;
     ```
     - New objects in `mydb` default to `fast_ssd` unless overridden.
   - **To a Table**:
     ```sql
     CREATE TABLE employees (
         id INTEGER PRIMARY KEY,
         name TEXT
     ) TABLESPACE fast_ssd;
     ```
   - **To an Index**:
     ```sql
     CREATE INDEX idx_employees_name ON employees(name) TABLESPACE fast_ssd;
     ```
   - **Alter Existing Objects**:
     ```sql
     ALTER TABLE employees SET TABLESPACE fast_ssd;
     ALTER INDEX idx_employees_name SET TABLESPACE fast_ssd;
     ```

3. **Check Tablespace Usage**:
   - List tablespaces:
     ```sql
     \db+
     ```
     - Shows tablespace name, owner, location, and access privileges.
   - Query tables in a tablespace:
     ```sql
     SELECT c.relname AS table_name, t.spcname AS tablespace
     FROM pg_class c
     JOIN pg_tablespace t ON c.reltablespace = t.oid
     WHERE c.relkind = 'r' AND t.spcname = 'fast_ssd';
     ```
   - Check size (combine with your `pg_total_relation_size` query):
     ```sql
     SELECT 
         c.relname AS table_name,
         pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size,
         t.spcname AS tablespace
     FROM pg_class c
     JOIN pg_tablespace t ON c.reltablespace = t.oid
     WHERE c.relkind = 'r' AND t.spcname = 'fast_ssd'
     ORDER BY pg_total_relation_size(c.oid) DESC;
     ```

#### Related Functions and Commands
Tablespaces interact with several PostgreSQL functions and tools, including those you’ve used:

1. **Size-Related Functions** (from your `pg_size_pretty` query):
   - **pg_total_relation_size(oid)**: Includes table, indexes, and TOAST data in a tablespace.
     - Example: `SELECT pg_size_pretty(pg_total_relation_size('employees'::regclass));`.
   - **pg_table_size(oid)**: Size of table and TOAST, excluding indexes.
   - **pg_indexes_size(oid)**: Size of all indexes on a table.
   - **pg_database_size(name)**: Size of a database, which aggregates objects across tablespaces.
   - Use: Monitor storage usage per tablespace for optimization.

2. **OID Functions** (from your OID question):
   - **pg_tablespace.oid**: Each tablespace has a unique OID in `pg_tablespace`.
     - Example: `SELECT oid, spcname FROM pg_tablespace WHERE spcname = 'fast_ssd';`.
   - Use: Query `pg_class.reltablespace` to find which tables use a specific tablespace OID.

3. **Backup and Restore** (from your `pg_dump`/`pg_restore` question):
   - **pg_dump**: Includes tablespace definitions in `--schema-only` dumps (e.g., `CREATE TABLESPACE` statements).
     - Example: `pg_dump -Fc --schema-only mydb > schema.dump`.
   - **pg_restore**: Restores tablespace assignments if the target system has the same tablespace locations.
     - Example: `pg_restore -d mydb_clone schema.dump`.
   - Note: Ensure tablespace directories exist on the target server before restoring.

4. **Metadata Queries**:
   - **information_schema.tables**: Used in your table size query; doesn’t directly show tablespace but can be joined with `pg_class`:
     ```sql
     SELECT 
         t.table_name,
         pg_size_pretty(pg_total_relation_size(quote_ident(t.table_name))),
         ts.spcname AS tablespace
     FROM information_schema.tables t
     JOIN pg_class c ON t.table_name = c.relname
     JOIN pg_tablespace ts ON c.reltablespace = ts.oid
     WHERE t.table_schema = 'public';
     ```
   - **pg_catalog.pg_tablespace**: System catalog for tablespace metadata.
     - Example: `SELECT spcname, spclocation FROM pg_tablespace;`.

#### Performance and Optimization
Tablespaces significantly impact performance, especially for large or high-traffic databases:
- **OLTP**:
  - Place heavily accessed tables (e.g., `employees`) on fast storage (e.g., SSD tablespace) to reduce latency.
  - Store indexes in a separate tablespace for parallel I/O (e.g., `fast_ssd` for indexes, `slow_hdd` for archival data).
- **OLAP**:
  - Use tablespaces to partition large datasets (e.g., historical data on HDD, recent data on SSD).
  - Combine with partitioning (e.g., `CREATE TABLE sales_2025 PARTITION OF sales TABLESPACE fast_ssd;`).
- **Monitoring**:
  - Use `pg_total_relation_size` and `pg_size_pretty` (as in your query) to track tablespace growth.
  - Check filesystem usage (`df -h /mnt/ssd/pgdata`) to avoid disk exhaustion.
- **Bloat**: Monitor table/index bloat in tablespaces with `pgstattuple`:
  ```sql
  SELECT * FROM pgstattuple('employees');
  ```

#### Security Considerations
- **Filesystem Permissions**: Restrict tablespace directories to the PostgreSQL user (e.g., `chown postgres /mnt/ssd/pgdata; chmod 700 /mnt/ssd/pgdata`).
- **Database Permissions**: Control who can create or assign objects to tablespaces:
  ```sql
  GRANT CREATE ON TABLESPACE fast_ssd TO app_user;
  ```
- **pg_hba.conf**: Ensure secure connections (e.g., `hostssl` with `scram-sha-256`) to tablespaces, especially for remote access.
- **BYPASSRLS**: Roles with `BYPASSRLS` can access all rows in RLS-enabled tables, regardless of tablespace.

#### Best Practices
1. **Plan Storage**:
   - Use separate tablespaces for **OLTP** (transactional data) and **OLAP** (analytical data) to optimize I/O.
   - Example: `fast_ssd` for active tables, `archive_hdd` for historical data.
2. **Name Clearly**:
   - Use descriptive names (e.g., `ssd_data`, `hdd_archive`) to indicate storage type or purpose.
3. **Monitor Usage**:
   - Regularly query tablespace sizes with `pg_total_relation_size` and `pg_size_pretty`.
   - Example: Combine with your query to list tables per tablespace.
4. **Backup Consistency**:
   - Include tablespace definitions in `pg_dump --schema-only` for full restores.
   - Verify tablespace locations exist on the target server before `pg_restore`.
5. **Secure Access**:
   - Limit `CREATE` privilege on tablespaces to trusted roles.
   - Use `hostssl` in `pg_hba.conf` for secure access to tablespaces.
6. **Test Changes**:
   - Test tablespace assignments in a staging environment to avoid disrupting production.
   - Example: `ALTER TABLE employees SET TABLESPACE fast_ssd;` may require downtime for large tables.

#### Practical Example
Combine tablespaces with your size query:
```sql
-- Create a tablespace
CREATE TABLESPACE fast_ssd LOCATION '/mnt/ssd/pgdata';

-- Move a table
ALTER TABLE employees SET TABLESPACE fast_ssd;

-- Query table sizes with tablespace
SELECT 
    t.table_name,
    pg_size_pretty(pg_total_relation_size(quote_ident(t.table_name))) AS total_size,
    COALESCE(ts.spcname, 'pg_default') AS tablespace
FROM 
    information_schema.tables t
LEFT JOIN pg_class c ON t.table_name = c.relname AND t.table_schema = 'public'
LEFT JOIN pg_tablespace ts ON c.reltablespace = ts.oid
WHERE 
    t.table_schema = 'public'
ORDER BY 
    pg_total_relation_size(quote_ident(t.table_name)) DESC;
```

**Output** (example):
```
 table_name | total_size | tablespace 
------------+------------+------------
 employees  | 15 MB      | fast_ssd   
 orders     | 8 MB       | pg_default 
```

#### Related Concepts
- **pg_dump/pg_restore**: Tablespace definitions are included in `--schema-only` dumps; ensure locations match during restore.
- **OIDs**: Tablespaces have OIDs in `pg_tablespace`, linked to objects via `pg_class.reltablespace`.
- **Schemas**: Tablespaces are orthogonal to schemas; a schema (e.g., `public`) can have tables in multiple tablespaces.
- **Roles**: Roles need `CREATE` privilege to use tablespaces; `BYPASSRLS` roles access all data regardless of tablespace.
- **LC_COLLATE/LC_CTYPE**: Tablespace storage is unaffected by collation, but sorting in queries (e.g., `ORDER BY`) depends on `LC_COLLATE`.

#### Troubleshooting
- **Permission Errors**: Ensure the PostgreSQL user owns the tablespace directory (`chown postgres /mnt/ssd/pgdata`).
- **Missing Directory**: Create the directory before `CREATE TABLESPACE` (e.g., `mkdir -p /mnt/ssd/pgdata`).
- **Restore Failures**: Verify tablespace locations exist on the target server before `pg_restore`.
- **Performance Issues**: Check I/O bottlenecks with `iostat` or `iotop` on tablespace directories.
- **Size Discrepancies**: Use `pg_table_size` vs. `pg_total_relation_size` to isolate table vs. index sizes.

#### Next Steps
- Check existing tablespaces: `\db+` in `psql`.
- Create a test tablespace: `CREATE TABLESPACE test_ssd LOCATION '/path/to/ssd';`.
- Move a table: `ALTER TABLE my_table SET TABLESPACE test_ssd;`.
- Monitor sizes: Extend your query to include tablespace names (as shown above).
- Backup: Use `pg_dump -Fc` to include tablespace definitions.

---

### Domain Types

A **domain type** in PostgreSQL is a user-defined data type that wraps an existing base type (e.g., `INTEGER`, `TEXT`, `NUMERIC`) with additional constraints to enforce specific rules or validations. Domains are useful for ensuring data integrity and consistency across columns without repeating constraint definitions. Given your familiarity with PostgreSQL concepts like arrays, ranges, `MONEY`, `NUMERIC`, `pg_dump`, and tablespaces, this response provides a detailed explanation of domain types, their creation, usage, advantages, limitations, and integration with your technical context, tailored for **Online Transaction Processing (OLTP)** and **Online Analytical Processing (OLAP)** workloads.

#### What is a Domain Type?
- A **domain** is a named data type based on an existing type, augmented with constraints (e.g., `NOT NULL`, `CHECK` conditions).
- It does not add new functionality beyond constraints but simplifies schema design by reusing validated types.
- Stored in the `pg_catalog.pg_type` catalog with a unique OID, similar to other types you’ve explored (e.g., arrays, ranges).
- **Example**:
  ```sql
  CREATE DOMAIN positive_numeric AS NUMERIC(10,2) CHECK (VALUE > 0);
  CREATE TABLE prices (
      id SERIAL PRIMARY KEY,
      amount positive_numeric NOT NULL
  );
  INSERT INTO prices (amount) VALUES (99.99); -- Valid
  INSERT INTO prices (amount) VALUES (-1.00); -- ERROR: value for domain positive_numeric violates check constraint
  ```

#### Purpose of Domain Types
Domains are used to:
1. **Enforce Consistency**: Apply the same validation rules across multiple tables or columns (e.g., positive prices in `NUMERIC(10,2)`).
2. **Simplify Schema Design**: Avoid duplicating constraints in table definitions.
3. **Improve Maintainability**: Update a domain’s constraints once to affect all columns using it.
4. **Enhance Readability**: Use meaningful names (e.g., `email_address`) to clarify data purpose.
5. **Use Cases**:
   - **OLTP**: Validate user inputs (e.g., non-negative prices, valid email formats).
   - **OLAP**: Ensure consistent data for reporting (e.g., standardized percentage ranges).

#### Creating a Domain Type
Use the `CREATE DOMAIN` command to define a domain:
```sql
CREATE DOMAIN domain_name AS base_type
    [DEFAULT default_value]
    [CONSTRAINT constraint_name]
    [NOT NULL]
    [CHECK (condition)];
```

**Example**:
```sql
CREATE DOMAIN email_address AS TEXT
    NOT NULL
    CHECK (VALUE ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
```

- **base_type**: The underlying type (e.g., `TEXT`, `NUMERIC`, `MONEY`).
- **DEFAULT**: Optional default value.
- **NOT NULL**: Ensures the value cannot be null.
- **CHECK**: Validates the value (e.g., positive numbers, regex for emails).
- **Notes**:
  - Multiple `CHECK` constraints can be added.
  - Constraints are enforced wherever the domain is used.

**Create Table with Domain**:
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email email_address
);
INSERT INTO users (email) VALUES ('user@example.com'); -- Valid
INSERT INTO users (email) VALUES ('invalid'); -- ERROR: invalid email
```

#### Modifying and Dropping Domains
1. **Add Constraint**:
   ```sql
   ALTER DOMAIN positive_numeric ADD CONSTRAINT max_value CHECK (VALUE <= 10000.00);
   ```
2. **Drop Constraint**:
   ```sql
   ALTER DOMAIN positive_numeric DROP CONSTRAINT max_value;
   ```
3. **Drop Domain**:
   ```sql
   DROP DOMAIN positive_numeric;
   ```
   - Fails if the domain is in use unless `CASCADE` is specified:
     ```sql
     DROP DOMAIN positive_numeric CASCADE; -- Drops domain and dependent columns
     ```

#### Key Domain Functions and Operations
Domains inherit the functions and operators of their base type but add constraint checks. Common operations in `WHERE` clauses include:

1. **Using Base Type Operators**:
   - Since `positive_numeric` is based on `NUMERIC(10,2)`, you can use numeric operators:
     ```sql
     SELECT id, amount
     FROM prices
     WHERE amount > 50.00;
     ```
2. **Casting**:
   - Cast to/from the base type:
     ```sql
     SELECT amount::NUMERIC FROM prices;
     ```
3. **Constraint Validation**:
   - Constraints are automatically enforced on `INSERT` or `UPDATE`:
     ```sql
     UPDATE prices SET amount = -10.00; -- ERROR: violates CHECK
     ```

#### Practical Example
Combine domains with your context (e.g., `MONEY`, ranges, arrays):
```sql
-- Create domains
CREATE DOMAIN positive_money AS MONEY
    CHECK (VALUE > 0::MONEY);
CREATE DOMAIN valid_percentage AS NUMERIC(5,2)
    CHECK (VALUE BETWEEN 0 AND 100);

-- Create table with domains and ranges
CREATE TABLE discounts (
    id SERIAL PRIMARY KEY,
    product TEXT,
    discount_rate valid_percentage,
    price_range numrange,
    sale_price positive_money
);

-- Insert data
INSERT INTO discounts (product, discount_rate, price_range, sale_price)
VALUES
    ('Laptop', 10.50, '[500.00,1000.00]', 899.99),
    ('Book', 5.00, '[20.00,50.00)', 29.99);

-- Query with range operations (from your range question)
SELECT product, discount_rate, sale_price
FROM discounts
WHERE price_range @> 600.00
AND sale_price < 900.00;
```

**Output** (with `LC_MONETARY = 'en_US.UTF-8'`):
```
 product | discount_rate | sale_price 
---------+---------------+------------
 Laptop  |         10.50 |   $899.99
```

**Explanation**:
- `positive_money` ensures prices are positive.
- `valid_percentage` restricts discount rates to 0–100%.
- `numrange` (from your range question) filters prices containing $600.00.
#### Advantages
- **Data Integrity**: Enforces constraints at the type level (e.g., positive `MONEY` values).
- **Reusability**: Apply the same validation across multiple tables (e.g., `email_address` in `users` and `contacts`).
- **Maintainability**: Update a domain’s constraints once to affect all uses.
- **Clarity**: Descriptive names (e.g., `valid_percentage`) improve schema readability.
- **OLTP**: Ensures valid inputs (e.g., non-negative prices).
- **OLAP**: Standardizes data for consistent reporting.

#### Limitations
- **No Additional Functionality**: Domains only add constraints, not new operators or behaviors.
- **Modification Challenges**:
  - Changing a domain’s constraints requires careful handling if data exists:
    ```sql
    ALTER DOMAIN positive_numeric DROP CONSTRAINT positive_check;
    ALTER DOMAIN positive_numeric ADD CHECK (VALUE >= 0);
    ```
  - May require data validation to avoid errors.
- **Dependency Management**:
  - Dropping a domain with `CASCADE` drops dependent columns, which can be destructive.
  - Check dependencies:
    ```sql
    SELECT * FROM pg_depend WHERE refobjid = (SELECT oid FROM pg_type WHERE typname = 'positive_numeric');
    ```
- **Portability**: Domains are PostgreSQL-specific, less portable than `NUMERIC` or `TEXT` (relevant to your `MONEY` portability concerns).
- **Performance**: Minimal overhead, but complex `CHECK` constraints (e.g., regex) can slow inserts/updates.

#### Performance Considerations
- **OLTP**:
  - Simple `CHECK` constraints (e.g., `VALUE > 0`) have negligible impact.
  - Complex constraints (e.g., regex for `email_address`) may slow high-concurrency inserts; test with `EXPLAIN`.
- **OLAP**:
  - Domains ensure consistent data for aggregations but don’t affect query performance directly.
  - Use indexes on domain-based columns for frequent `WHERE` clauses:
    ```sql
    CREATE INDEX idx_prices_amount ON prices(amount);
    ```
- **Size**:
  - Domains inherit the base type’s storage (e.g., 8 bytes for `MONEY`, variable for `NUMERIC`).
  - Monitor with `pg_total_relation_size` (from your size query):
    ```sql
    SELECT pg_size_pretty(pg_total_relation_size('prices'));
    ```

#### Best Practices
1. **Use Descriptive Names**:
   - Name domains clearly (e.g., `positive_money`, `email_address`) to reflect purpose.
2. **Keep Constraints Simple**:
   - Avoid complex `CHECK` conditions (e.g., expensive regex) for **OLTP** performance.
   - Example: `CHECK (VALUE > 0)` is faster than `CHECK (VALUE ~ 'regex')`.
3. **Validate Before Altering**:
   - Check existing data before modifying constraints:
     ```sql
     SELECT * FROM prices WHERE amount <= 0;
     ```
4. **Combine with Other Types**:
   - Use domains with arrays or ranges:
     ```sql
     CREATE DOMAIN positive_int AS INTEGER CHECK (VALUE > 0);
     CREATE TABLE items (id SERIAL, quantities positive_int[]);
     ```
   - Integrate with `numrange` for price ranges (from your range question).
5. **Backup and Restore**:
   - Ensure `pg_dump -Fc` includes domain definitions.
   - Restore domains before tables with `pg_restore --section=pre-data`.
6. **Monitor Dependencies**:
   - Use `pg_depend` to track domain usage before dropping:
     ```sql
     SELECT * FROM pg_type WHERE typname = 'positive_numeric';
     ```
7. **Secure Access**:
   - Restrict domain creation to trusted roles:
     ```sql
     GRANT CREATE ON DATABASE mydb TO admin_role;
     ```

#### Troubleshooting
- **Constraint Violations**:
  - If inserts fail (e.g., `ERROR: value for domain violates check constraint`), validate data:
    ```sql
    SELECT * FROM prices WHERE amount <= 0;
    ```
- **Restore Issues**:
  - Ensure domains are created before tables during `pg_restore`:
    ```bash
    pg_restore --section=pre-data -d mydb dump.custom
    ```
- **Performance**:
  - Slow queries on domain columns? Add indexes or simplify `CHECK` constraints.
  - Example: `EXPLAIN SELECT * FROM prices WHERE amount > 50.00;`.
- **Portability**:
  - For non-PostgreSQL databases, replace domains with base types and table constraints.

#### Practical Example with PL/pgSQL
Create a function to validate and insert prices:
```sql
CREATE DOMAIN non_negative_money AS MONEY CHECK (VALUE >= 0);

CREATE OR REPLACE FUNCTION add_price(p_product TEXT, p_amount non_negative_money)
RETURNS VOID AS $$
BEGIN
    INSERT INTO prices (product, amount)
    VALUES (p_product, p_amount);
EXCEPTION
    WHEN check_violation THEN
        RAISE EXCEPTION 'Invalid price: %', p_amount;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT add_price('Laptop', 999.99::MONEY); -- Success
SELECT add_price('Book', -10.00::MONEY);   -- ERROR: Invalid price
```

**Query with Range** (from your range question):
```sql
SELECT product, amount
FROM prices
WHERE amount::NUMERIC <@ numrange(0.00, 1000.00);
```

**Output**:
```
 product | amount  
---------+---------
 Laptop  | $999.99
```

#### Next Steps
- Create a domain:
  ```sql
  CREATE DOMAIN valid_price AS NUMERIC(10,2) CHECK (VALUE >= 0);
  ```
- Use in a table:
  ```sql
  CREATE TABLE sales (id SERIAL, price valid_price);
  INSERT INTO sales (price) VALUES (99.99);
  ```
- Test constraints:
  ```sql
  INSERT INTO sales (price) VALUES (-1.00); -- Should fail
  ```
- Monitor size:
  ```sql
  SELECT pg_size_pretty(pg_total_relation_size('sales'));
  ```
- Combine with ranges:
  ```sql
  SELECT * FROM sales WHERE price::NUMERIC <@ numrange(0, 100);
  ```

---

### Extension Objects 

An **extension object** in PostgreSQL refers to database objects (e.g., functions, operators, types, aggregates, or tables) created by a PostgreSQL **extension**, which is a packaged set of SQL objects that add functionality to the database. Extensions simplify the installation and management of additional features, such as advanced indexing, full-text search, or geospatial support. 

#### What is an Extension?
- An **extension** is a collection of SQL objects (collectively called **extension objects**) that extend PostgreSQL’s functionality.
- Extensions are installed using the `CREATE EXTENSION` command and managed as a single unit, making it easy to add, update, or remove features.
- Common extensions include:
  - `postgis`: Geospatial data support.
  - `pg_trgm`: Trigram-based text similarity.
  - `uuid-ossp`: UUID generation.
  - `citext`: Case-insensitive text type.
  - `btree_gin`: GIN indexing for B-tree-like queries.
- **Extension Objects**: The individual components (e.g., functions, types, operators) created when an extension is installed.

**Example**:
```sql
CREATE EXTENSION uuid-ossp;
SELECT uuid_generate_v4();
```
- Installs the `uuid-ossp` extension, creating the `uuid_generate_v4()` function (an extension object).
- **Output** (example):
  ```
                  uuid_generate_v4                 
  --------------------------------------
   123e4567-e89b-12d3-a456-426614174000
  ```

#### What are Extension Objects?
- **Definition**: Extension objects are the database objects (e.g., functions, types, operators, schemas, or tables) defined by an extension’s scripts and registered in the `pg_extension` and `pg_depend` catalogs.
- **Characteristics**:
  - Managed by the extension; they are created/dropped when the extension is installed/removed.
  - Stored in a specific schema (e.g., `public` or a dedicated schema like `postgis`).
  - Identified by their dependency on the extension in `pg_depend`.
- **Examples**:
  - `uuid-ossp`: Functions like `uuid_generate_v4()`, types like `uuid`.
  - `postgis`: Functions like `ST_Distance()`, types like `geometry`, operators like `&&` (spatial overlap).
  - `pg_trgm`: Functions like `similarity()`, operators like `%` (trigram similarity).
  - `citext`: Type `citext` for case-insensitive text.

**Query Extension Objects**:
```sql
SELECT e.extname, o.objid::regclass AS object_name, o.objid::regprocedure AS function_name
FROM pg_extension e
JOIN pg_depend d ON e.oid = d.refobjid
JOIN pg_object o ON d.objid = o.objid
WHERE e.extname = 'uuid-ossp';
```
- Shows objects (e.g., functions) created by `uuid-ossp`.

#### Managing Extensions and Their Objects
1. **Installing an Extension**:
   ```sql
   CREATE EXTENSION postgis SCHEMA postgis;
   ```
   - Installs `postgis` in the `postgis` schema, creating objects like `geometry` type, `ST_Distance` function, and `&&` operator.
   - Requires the extension’s files to be installed on the server (e.g., via `apt install postgresql-contrib` or `yum install postgresql-contrib`).

2. **Listing Extensions**:
   ```sql
   \dx
   ```
   **Output** (example):
   ```
                    List of installed extensions
     Name    | Version | Schema  |           Description           
    ---------+---------+---------+---------------------------------
     postgis | 3.4.0   | postgis | PostGIS geometry and geography
     uuid-ossp | 1.1   | public  | UUID generation functions
   ```

3. **Listing Extension Objects**:
   ```sql
   SELECT n.nspname AS schema, c.relname AS object, c.relkind
   FROM pg_class c
   JOIN pg_namespace n ON c.relnamespace = n.oid
   JOIN pg_depend d ON c.oid = d.objid
   JOIN pg_extension e ON d.refobjid = e.oid
   WHERE e.extname = 'postgis' AND c.relkind IN ('r', 'i', 'S', 't');
   ```
   - Lists tables, indexes, sequences, or TOAST tables created by `postgis`.
   - Use `\dx+ postgis` in `psql` for a detailed list of objects.

4. **Dropping an Extension**:
   ```sql
   DROP EXTENSION postgis CASCADE;
   ```
   - Removes the extension and all its objects (e.g., `geometry` type, `ST_Distance`).
   - **CASCADE** drops dependent objects (e.g., columns using `geometry`).

5. **Upgrading an Extension**:
   ```sql
   ALTER EXTENSION postgis UPDATE TO '3.4.1';
   ```
   - Updates the extension to a new version, modifying or adding objects as needed.

#### Common Extensions and Their Objects
Here are popular extensions and examples of their objects, relevant to your context:

1. **uuid-ossp**:
   - **Objects**: Functions (`uuid_generate_v1()`, `uuid_generate_v4()`), type (`uuid`).
   - **Use Case**: Generate unique identifiers in **OLTP** (e.g., primary keys).
   - **Example**:
     ```sql
     CREATE TABLE users (
         id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
         name TEXT
     );
     ```

2. **postgis**:
   - **Objects**: Types (`geometry`, `geography`), functions (`ST_Distance`, `ST_Within`), operators (`&&`, `~=`), indexes (GiST for spatial queries).
   - **Use Case**: Geospatial queries in **OLAP** (e.g., location-based analytics) or **OLTP** (e.g., delivery tracking).
   - **Example**:
     ```sql
     SELECT name
     FROM locations
     WHERE geom && ST_MakeEnvelope(-122, 47, -121, 48, 4326);
     ```
   - **Schema**: Typically installed in a `postgis` schema (from your schema question).

3. **pg_trgm**:
   - **Objects**: Functions (`similarity()`, `show_trgm()`), operators (`%`, `<%`, `>%`), GIN indexes.
   - **Use Case**: Text similarity searches in **OLTP** (e.g., autocomplete) or **OLAP** (e.g., fuzzy matching).
   - **Example**:
     ```sql
     CREATE INDEX trgm_idx ON products USING GIN (name gin_trgm_ops);
     SELECT name FROM products WHERE name % 'lapto';
     ```

4. **citext**:
   - **Objects**: Type (`citext`), operators (`=`, `LIKE` with case-insensitive behavior).
   - **Use Case**: Case-insensitive text comparisons in **OLTP** (e.g., emails, usernames).
   - **Example**:
     ```sql
     CREATE TABLE emails (
         id SERIAL PRIMARY KEY,
         address CITEXT
     );
     SELECT address FROM emails WHERE address = 'User@example.com';
     ```
     - Matches `user@example.com` or `USER@EXAMPLE.COM`.

5. **btree_gin**:
   - **Objects**: GIN operator classes for scalar types (e.g., `INTEGER`, `TEXT`).
   - **Use Case**: Combine GIN indexing with B-tree-like queries in **OLTP** or **OLAP**.
   - **Example**:
     ```sql
     CREATE INDEX idx_prices ON prices USING GIN (amount);
     ```
#### Advantages
- **Modularity**: Extensions bundle related objects (e.g., `postgis` provides all geospatial tools), simplifying installation.
- **Ease of Management**: `CREATE EXTENSION` and `DROP EXTENSION` handle all objects, avoiding manual scripting.
- **Reusability**: Use extension objects across tables, schemas, or databases in a cluster.
- **OLTP**: Extensions like `uuid-ossp` or `citext` streamline unique identifiers or case-insensitive searches.
- **OLAP**: Extensions like `postgis` or `pg_trgm` enable advanced analytics (e.g., geospatial, text similarity).

#### Limitations
- **Server Dependency**: Extensions require server-side files (e.g., `postgis.so`), which must be installed via package managers or source.
- **Version Compatibility**: Extension versions must match the PostgreSQL server version; upgrades may require `ALTER EXTENSION`.
- **Portability**: Extension objects (e.g., `citext`, `geometry`) are PostgreSQL-specific, reducing compatibility with other databases (similar to your `MONEY` portability concerns).
- **Dependencies**: Dropping an extension with `CASCADE` removes dependent objects, which can affect tables or columns.
- **Performance**: Some extensions (e.g., `postgis`) add overhead for complex operations; monitor with `EXPLAIN`.

#### Performance Considerations
- **OLTP**:
  - Use lightweight extensions like `uuid-ossp` or `citext` for minimal overhead.
  - Index extension types (e.g., GIN for `citext`, GiST for `geometry`):
    ```sql
    CREATE INDEX idx_emails ON emails USING GIN (address);
    ```
- **OLAP**:
  - Extensions like `postgis` or `pg_trgm` benefit from GiST/GIN indexes for large datasets.
  - Example:
    ```sql
    CREATE INDEX idx_locations_geom ON locations USING GIST (geom);
    ```
- **Size**:
  - Tables with extension types (e.g., `geometry`) can grow large; monitor with `pg_total_relation_size`:
    ```sql
    SELECT pg_size_pretty(pg_total_relation_size('locations'));
    ```
  - Store in optimized tablespaces (e.g., `fast_ssd`).

#### Best Practices
1. **Install in Dedicated Schemas**:
   - Avoid cluttering `public`:
     ```sql
     CREATE SCHEMA postgis;
     CREATE EXTENSION postgis SCHEMA postgis;
     ```
2. **Check Dependencies**:
   - Before dropping, query dependent objects:
     ```sql
     SELECT * FROM pg_depend WHERE refobjid = (SELECT oid FROM pg_extension WHERE extname = 'postgis');
     ```
3. **Backup Extensions**:
   - Include extensions in `pg_dump -Fc`:
     ```bash
     pg_dump -Fc --schema-only mydb > schema.dump
     ```
   - Ensure extension files are installed on the target server before `pg_restore`.
4. **Use Indexes**:
   - Add GiST/GIN indexes for extension types used in `WHERE` clauses (e.g., `geometry`, `citext`).
5. **Monitor Performance**:
   - Use `EXPLAIN` for queries involving extension objects:
     ```sql
     EXPLAIN SELECT * FROM locations WHERE geom && ST_MakeEnvelope(-122, 47, -121, 48, 4326);
     ```
6. **Secure Access**:
   - Restrict schema access for extensions:
     ```sql
     GRANT USAGE ON SCHEMA postgis TO app_user;
     ```
   - Use `hostssl` in `pg_hba.conf` for secure connections.

#### Troubleshooting
- **Extension Not Found**:
  - Ensure the extension is installed on the server:
    ```bash
    sudo apt install postgresql-contrib  # Debian/Ubuntu
    sudo yum install postgresql-contrib  # CentOS/RHEL
    ```
  - Check available extensions:
    ```sql
    SELECT * FROM pg_available_extensions;
    ```
- **Version Mismatch**:
  - Update the extension:
    ```sql
    ALTER EXTENSION postgis UPDATE;
    ```
- **Restore Errors**:
  - Install extension files on the target server before `pg_restore`.
  - Restore schema first:
    ```bash
    pg_restore --section=pre-data -d mydb dump.custom
    ```
- **Performance Issues**:
  - Slow queries? Add indexes or optimize extension-specific functions.
  - Example: `CREATE INDEX idx_products_name ON products USING GIN (name gin_trgm_ops);`.

#### Practical Example with PL/pgSQL
Use `uuid-ossp` and `citext` in a table with a function:
```sql
CREATE EXTENSION uuid-ossp;
CREATE EXTENSION citext;

CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email CITEXT NOT NULL,
    name TEXT
);

CREATE OR REPLACE FUNCTION add_customer(p_email CITEXT, p_name TEXT)
RETURNS UUID AS $$
DECLARE
    new_id UUID;
BEGIN
    INSERT INTO customers (email, name)
    VALUES (p_email, p_name)
    RETURNING id INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT add_customer('user@example.com', 'Alice');
SELECT * FROM customers WHERE email = 'USER@example.com';
```

**Output**:
```
                  id                  |      email      | name  
--------------------------------------+-----------------+-------
 123e4567-e89b-12d3-a456-426614174000 | user@example.com | Alice
```

**Size Check**:
```sql
SELECT pg_size_pretty(pg_total_relation_size('customers'));
```

#### Next Steps
- List extensions:
  ```sql
  \dx
  ```
- Install an extension:
  ```sql
  CREATE EXTENSION uuid-ossp;
  ```
- Create a table with extension objects:
  ```sql
  CREATE TABLE records (id UUID DEFAULT uuid_generate_v4(), data CITEXT);
  ```
- Monitor size:
  ```sql
  SELECT pg_size_pretty(pg_total_relation_size('records'));
  ```
- Test extension objects:
  ```sql
  SELECT uuid_generate_v4(), similarity('laptop', 'lapto') FROM products;
  ```

---

### Understanding Trigger Objects in PostgreSQL

A **trigger object** in PostgreSQL is a database object that defines a function to be automatically executed when specific events (e.g., `INSERT`, `UPDATE`, `DELETE`, or `TRUNCATE`) occur on a table or view. Triggers are used to enforce business rules, maintain audit logs, or automate tasks, making them essential for **Online Transaction Processing (OLTP)** (e.g., logging changes) and **Online Analytical Processing (OLAP)** (e.g., updating summary tables). Given your familiarity with PostgreSQL concepts like domain types, arrays, ranges, `MONEY`, `pg_dump`, tablespaces, and extensions, this response provides a detailed explanation of trigger objects, their creation, usage, management, and integration with your technical context.

#### What is a Trigger Object?
- **Definition**: A trigger is a named database object associated with a table or view that specifies a trigger function to run before, after, or instead of a specified event.
- **Components**:
  - **Trigger Function**: A user-defined function (usually in PL/pgSQL) that contains the logic to execute. It must return `TRIGGER` or `NULL`.
  - **Trigger Definition**: Links the function to a table, specifying the event, timing, and conditions.
- **Storage**: Triggers are stored in the `pg_trigger` system catalog with a unique OID, linked to their table via `tgrelid`.
- **Types**:
  - **Row-Level**: Executes for each affected row (e.g., per `INSERT`).
  - **Statement-Level**: Executes once per statement, regardless of the number of rows.
- **Example**:
  ```sql
  CREATE FUNCTION log_price_change()
  RETURNS TRIGGER AS $$
  BEGIN
      INSERT INTO price_audit (product_id, old_price, new_price, changed_at)
      VALUES (OLD.id, OLD.price, NEW.price, CURRENT_TIMESTAMP);
      RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

  CREATE TRIGGER price_update_trigger
  AFTER UPDATE OF price ON products
  FOR EACH ROW
  WHEN (OLD.price IS DISTINCT FROM NEW.price)
  EXECUTE FUNCTION log_price_change();
  ```

#### Purpose of Triggers
Triggers serve multiple purposes:
1. **Data Integrity**: Enforce complex rules (e.g., ensure price changes are positive).
2. **Auditing**: Log changes to tables (e.g., track updates to `MONEY` columns).
3. **Automation**: Update related tables (e.g., refresh summary tables in **OLAP**).
4. **Validation**: Prevent invalid operations (e.g., reject negative `NUMERIC` values).
5. **Use Cases**:
   - **OLTP**: Audit trails, enforce business logic (e.g., stock updates).
   - **OLAP**: Maintain materialized views or aggregated data.

#### Creating a Trigger
1. **Create Trigger Function**:
   ```sql
   CREATE FUNCTION enforce_positive_price()
   RETURNS TRIGGER AS $$
   BEGIN
       IF NEW.price < 0::MONEY THEN
           RAISE EXCEPTION 'Price cannot be negative: %', NEW.price;
       END IF;
       RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;
   ```
   - Returns `TRIGGER` type.
   - Uses `NEW` (new row data) for `INSERT`/`UPDATE`, `OLD` (old row data) for `UPDATE`/`DELETE`.

2. **Create Trigger**:
   ```sql
   CREATE TRIGGER check_price
   BEFORE INSERT OR UPDATE OF price ON products
   FOR EACH ROW
   EXECUTE FUNCTION enforce_positive_price();
   ```
   - **Timing**: `BEFORE`, `AFTER`, or `INSTEAD OF` (for views).
   - **Events**: `INSERT`, `UPDATE [OF column]`, `DELETE`, `TRUNCATE`.
   - **Level**: `FOR EACH ROW` or `FOR EACH STATEMENT`.
   - **Conditions**: Optional `WHEN` clause (e.g., `WHEN (NEW.price < 0)`).

3. **Test Trigger**:
   ```sql
   CREATE TABLE products (
       id SERIAL PRIMARY KEY,
       name TEXT,
       price MONEY
   );
   INSERT INTO products (name, price) VALUES ('Laptop', 999.99); -- Success
   INSERT INTO products (name, price) VALUES ('Book', -10.00);  -- ERROR: Price cannot be negative
   ```

#### Managing Triggers
1. **List Triggers**:
   ```sql
   \d+ products
   ```
   - Shows triggers attached to the `products` table.
   - Or query `pg_trigger`:
     ```sql
     SELECT tgname, tgfoid::regproc AS function, tgtype
     FROM pg_trigger
     WHERE tgrelid = 'products'::regclass;
     ```

2. **Disable/Enable Triggers**:
   ```sql
   ALTER TABLE products DISABLE TRIGGER check_price;
   ALTER TABLE products ENABLE TRIGGER check_price;
   ```
   - Useful for bulk operations (e.g., `pg_restore`).

3. **Drop Trigger**:
   ```sql
   DROP TRIGGER check_price ON products;
   ```
   - Drops the trigger but not the function.

4. **Modify Trigger**:
   - Drop and recreate, as triggers cannot be altered directly:
     ```sql
     DROP TRIGGER check_price ON products;
     CREATE TRIGGER check_price
     BEFORE INSERT OR UPDATE OF price ON products
     FOR EACH ROW
     WHEN (NEW.price < 10::MONEY)
     EXECUTE FUNCTION enforce_positive_price();
     ```

#### Key Trigger Features
1. **Row-Level Triggers**:
   - Access `NEW` and `OLD` records.
   - Example: Log changes to `price`:
     ```sql
     CREATE TABLE price_audit (
         audit_id SERIAL PRIMARY KEY,
         product_id INTEGER,
         old_price MONEY,
         new_price MONEY,
         changed_at TIMESTAMP
     );
     ```

2. **Statement-Level Triggers**:
   - Run once per statement, no `NEW`/`OLD` access.
   - Example: Log statement execution:
     ```sql
     CREATE FUNCTION log_statement()
     RETURNS TRIGGER AS $$
     BEGIN
         INSERT INTO audit_log (event, occurred_at)
         VALUES (TG_OP, CURRENT_TIMESTAMP);
         RETURN NULL;
     END;
     $$ LANGUAGE plpgsql;

     CREATE TRIGGER log_product_changes
     AFTER INSERT OR UPDATE OR DELETE ON products
     FOR EACH STATEMENT
     EXECUTE FUNCTION log_statement();
     ```

3. **Conditional Triggers**:
   - Use `WHEN` to limit execution:
     ```sql
     WHEN (OLD.price IS DISTINCT FROM NEW.price)
     ```

4. **INSTEAD OF Triggers**:
   - Used on views to make them updatable:
     ```sql
     CREATE VIEW product_summary AS
     SELECT id, name, price FROM products;
     CREATE FUNCTION update_product_summary()
     RETURNS TRIGGER AS $$
     BEGIN
         UPDATE products
         SET name = NEW.name, price = NEW.price
         WHERE id = NEW.id;
         RETURN NEW;
     END;
     $$ LANGUAGE plpgsql;
     CREATE TRIGGER instead_update
     INSTEAD OF UPDATE ON product_summary
     FOR EACH ROW
     EXECUTE FUNCTION update_product_summary();
     ```

#### Integration with Your Context
1. **NUMERIC/MONEY**:
   - Use triggers to validate `MONEY` or `NUMERIC(10,2)` columns (from your questions):
     ```sql
     CREATE FUNCTION validate_money()
     RETURNS TRIGGER AS $$
     BEGIN
         IF NEW.amount < 0::MONEY THEN
             RAISE EXCEPTION 'Negative amount not allowed: %', NEW.amount;
         END IF;
         RETURN NEW;
     END;
     $$ LANGUAGE plpgsql;
     CREATE TRIGGER check_amount
     BEFORE INSERT OR UPDATE ON transactions
     FOR EACH ROW
     EXECUTE FUNCTION validate_money();
     ```
2. **Ranges**:
   - Enforce range constraints (e.g., `numrange` for prices):
     ```sql
     CREATE FUNCTION check_price_range()
     RETURNS TRIGGER AS $$
     BEGIN
         IF NOT NEW.price_range @> NEW.sale_price::NUMERIC THEN
             RAISE EXCEPTION 'Sale price % not in range %', NEW.sale_price, NEW.price_range;
         END IF;
         RETURN NEW;
     END;
     $$ LANGUAGE plpgsql;
     CREATE TRIGGER validate_range
     BEFORE INSERT OR UPDATE ON discounts
     FOR EACH ROW
     EXECUTE FUNCTION check_price_range();
     ```
3. **Arrays**:
   - Validate array elements (e.g., non-empty tags):
     ```sql
     CREATE FUNCTION check_tags()
     RETURNS TRIGGER AS $$
     BEGIN
         IF array_length(NEW.tags, 1) IS NULL OR array_length(NEW.tags, 1) = 0 THEN
             RAISE EXCEPTION 'Tags cannot be empty';
         END IF;
         RETURN NEW;
     END;
     $$ LANGUAGE plpgsql;
     CREATE TRIGGER validate_tags
     BEFORE INSERT OR UPDATE ON products
     FOR EACH ROW
     EXECUTE FUNCTION check_tags();
     ```
4. **Domains**:
   - Combine with domain types for layered validation:
     ```sql
     CREATE DOMAIN positive_money AS MONEY CHECK (VALUE >= 0);
     CREATE TRIGGER extra_price_check
     BEFORE INSERT OR UPDATE ON products
     FOR EACH ROW
     EXECUTE FUNCTION enforce_positive_price();
     ```
5. **Extensions**:
   - Use extension objects in triggers (e.g., `uuid-ossp` for IDs):
     ```sql
     CREATE EXTENSION uuid-ossp;
     CREATE FUNCTION set_uuid()
     RETURNS TRIGGER AS $$
     BEGIN
         NEW.id = uuid_generate_v4();
         RETURN NEW;
     END;
     $$ LANGUAGE plpgsql;
     CREATE TRIGGER set_product_id
     BEFORE INSERT ON products
     FOR EACH ROW
     EXECUTE FUNCTION set_uuid();
     ```
6. **pg_dump/pg_restore**:
   - Triggers and their functions are included in `--schema-only` dumps:
     ```bash
     pg_dump -Fc --schema-only mydb > schema.dump
     ```
   - Data affected by triggers (e.g., audit logs) is dumped with `--data-only`.
   - Restore with `pg_restore`, ensuring functions are created before triggers:
     ```bash
     pg_restore --section=pre-data -d mydb_clone schema.dump
     ```
7. **Tablespaces**:
   - Store tables with triggers in optimized tablespaces:
     ```sql
     ALTER TABLE products SET TABLESPACE fast_ssd;
     ```
   - Monitor size (from your `pg_size_pretty` question):
     ```sql
     SELECT pg_size_pretty(pg_total_relation_size('products'));
     ```
8. **OIDs**:
   - Triggers have OIDs in `pg_trigger`:
     ```sql
     SELECT oid, tgname FROM pg_trigger WHERE tgrelid = 'products'::regclass;
     ```
   - Trigger functions have OIDs in `pg_proc`:
     ```sql
     SELECT oid, proname FROM pg_proc WHERE proname = 'enforce_positive_price';
     ```

#### Advantages
- **Automation**: Triggers execute logic automatically, reducing application code.
- **Data Integrity**: Enforce rules at the database level (e.g., positive `MONEY` values).
- **Auditing**: Maintain logs without modifying application logic (e.g., `price_audit`).
- **OLTP**: Ensure transactional consistency (e.g., stock updates).
- **OLAP**: Keep derived tables or materialized views up-to-date.

#### Limitations
- **Performance Overhead**:
  - Row-level triggers can slow down bulk operations (e.g., large `INSERT` statements).
  - Mitigate by disabling triggers temporarily:
    ```sql
    ALTER TABLE products DISABLE TRIGGER ALL;
    ```
- **Complexity**:
  - Triggers can make debugging harder, as they run implicitly.
  - Use `RAISE NOTICE` in functions for logging:
    ```sql
    RAISE NOTICE 'Price changed from % to %', OLD.price, NEW.price;
    ```
- **Dependency Management**:
  - Dropping a table drops its triggers; dropping a function fails if a trigger depends on it.
  - Check dependencies:
    ```sql
    SELECT * FROM pg_depend WHERE refobjid = (SELECT oid FROM pg_proc WHERE proname = 'enforce_positive_price');
    ```
- **Portability**:
  - Trigger syntax is PostgreSQL-specific, less portable than constraints (similar to your `MONEY` portability concerns).
- **Order of Execution**:
  - Multiple triggers on the same event execute in alphabetical order by trigger name.
  - Name triggers strategically (e.g., `z_final_check` to run last).

#### Performance Considerations
- **OLTP**:
  - Minimize trigger logic to reduce latency (e.g., simple `CHECK` vs. complex queries).
  - Use `WHEN` clauses to skip unnecessary executions:
    ```sql
    WHEN (NEW.price < 0)
    ```
- **OLAP**:
  - Statement-level triggers are more efficient for bulk updates (e.g., refreshing summary tables).
  - Example:
    ```sql
    CREATE TRIGGER refresh_summary
    AFTER INSERT OR UPDATE ON sales
    FOR EACH STATEMENT
    EXECUTE FUNCTION update_sales_summary();
    ```
- **Indexing**:
  - Triggers updating related tables may require indexes:
    ```sql
    CREATE INDEX idx_price_audit_product_id ON price_audit(product_id);
    ```
- **Bloat**:
  - Frequent trigger updates (e.g., audit logs) can cause table bloat; monitor with `pgstattuple`:
    ```sql
    SELECT * FROM pgstattuple('price_audit');
    ```

#### Best Practices
1. **Use Descriptive Names**:
   - Name triggers and functions clearly (e.g., `check_price`, `log_price_change`).
2. **Keep Logic Simple**:
   - Avoid complex queries in triggers; delegate to functions or scheduled jobs for **OLAP**.
3. **Use WHEN Clauses**:
   - Limit trigger execution:
     ```sql
     WHEN (OLD.price IS DISTINCT FROM NEW.price)
     ```
4. **Secure Triggers**:
   - Restrict trigger function creation:
     ```sql
     GRANT CREATE ON DATABASE mydb TO admin_role;
     ```
   - Use `SECURITY DEFINER` for controlled privilege escalation:
     ```sql
     CREATE FUNCTION log_price_change() RETURNS TRIGGER AS $$
     BEGIN
         -- Logic
     END;
     $$ LANGUAGE plpgsql SECURITY DEFINER;
     ```
5. **Backup Triggers**:
   - Ensure `pg_dump -Fc` captures triggers and functions:
     ```bash
     pg_dump -Fc --schema-only mydb > schema.dump
     ```
6. **Monitor Performance**:
   - Use `EXPLAIN` to analyze trigger impact:
     ```sql
     EXPLAIN ANALYZE INSERT INTO products (name, price) VALUES ('Tablet', 499.99);
     ```
7. **Test Thoroughly**:
   - Test triggers in a staging environment to avoid unexpected behavior in production.

#### Troubleshooting
- **Trigger Not Firing**:
  - Check if disabled:
    ```sql
    SELECT tgname, tgenabled FROM pg_trigger WHERE tgrelid = 'products'::regclass;
    ```
  - Verify `WHEN` conditions or event types.
- **Performance Issues**:
  - Slow inserts/updates? Use `EXPLAIN ANALYZE` or disable triggers for bulk operations.
  - Example:
    ```sql
    ALTER TABLE products DISABLE TRIGGER ALL;
    INSERT INTO products (name, price) SELECT name, price FROM temp_data;
    ALTER TABLE products ENABLE TRIGGER ALL;
    ```
- **Errors in Functions**:
  - Add `RAISE NOTICE` for debugging:
    ```sql
    RAISE NOTICE 'Processing row: %', NEW;
    ```
- **Restore Issues**:
  - Ensure trigger functions are restored before triggers:
    ```bash
    pg_restore --section=pre-data -d mydb schema.dump
    ```

#### Practical Example with PL/pgSQL
Create an audit trigger for price changes:
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT,
    price MONEY
);
CREATE TABLE price_audit (
    audit_id SERIAL PRIMARY KEY,
    product_id INTEGER,
    old_price MONEY,
    new_price MONEY,
    changed_at TIMESTAMP
);

CREATE FUNCTION log_price_change()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO price_audit (product_id, old_price, new_price, changed_at)
    VALUES (NEW.id, OLD.price, NEW.price, CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER price_update_trigger
AFTER UPDATE OF price ON products
FOR EACH ROW
WHEN (OLD.price IS DISTINCT FROM NEW.price)
EXECUTE FUNCTION log_price_change();

-- Test
INSERT INTO products (name, price) VALUES ('Laptop', 999.99);
UPDATE products SET price = 1099.99 WHERE id = 1;
SELECT * FROM price_audit;
```

**Output**:
```
 audit_id | product_id | old_price | new_price |        changed_at        
----------+------------+-----------+-----------+--------------------------
        1 |          1 |   $999.99 |  $1099.99 | 2025-05-14 21:43:00 PST
```

**Size Check**:
```sql
SELECT pg_size_pretty(pg_total_relation_size('price_audit'));
```

#### Next Steps
- Create a trigger:
  ```sql
  CREATE TRIGGER check_price
  BEFORE INSERT OR UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION enforce_positive_price();
  ```
- Test it:
  ```sql
  INSERT INTO products (name, price) VALUES ('Tablet', -10.00); -- Should fail
  ```
- List triggers:
  ```sql
  \d+ products
  ```
- Monitor size:
  ```sql
  SELECT pg_size_pretty(pg_total_relation_size('products'));
  ```

---

