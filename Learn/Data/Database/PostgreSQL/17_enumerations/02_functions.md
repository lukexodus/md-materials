## Functions


### Functions For Size Queries

#### Query 1: Database Size
```sql
SELECT pg_size_pretty(pg_database_size('my_application_db'));
```

1. **pg_database_size(name)**:
   - **Purpose**: Returns the total disk size (in bytes) of the specified database, including all tables, indexes, TOAST data, and other objects.
   - **Input**: Database name as text (e.g., `'my_application_db'`).
   - **Output**: Integer (size in bytes).
   - **Example**: For a database with 100 MB of data, it might return `104857600` bytes.
   - **Use Case**: Monitor database growth for capacity planning in **OLTP** (e.g., transaction logs) or **OLAP** (e.g., data warehouse).

2. **pg_size_pretty(numeric)**:
   - **Purpose**: Converts a size in bytes to a human-readable format (e.g., KB, MB, GB).
   - **Input**: Numeric value (e.g., bytes from `pg_database_size`).
   - **Output**: Text (e.g., `100 MB`).
   - **Example**: `pg_size_pretty(104857600)` returns `'100 MB'`.
   - **Use Case**: Improves readability for reports or monitoring dashboards.

#### Query 2: Table Sizes
```sql
SELECT 
    table_name,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) as total_size
FROM 
    information_schema.tables
WHERE 
    table_schema = 'public'
ORDER BY 
    pg_total_relation_size(quote_ident(table_name)) DESC;
```

1. **pg_total_relation_size(regclass)**:
   - **Purpose**: Returns the total disk size (in bytes) of a table, including its data, indexes, and TOAST data (compressed/large object storage).
   - **Input**: Table name as a `regclass` type (e.g., `'public.employees'` or quoted identifier).
   - **Output**: Integer (size in bytes).
   - **Example**: For a table with 10 MB data and 5 MB indexes, it might return `15728640` bytes.
   - **Use Case**: Identify large tables for optimization (e.g., partitioning in **OLAP**, indexing in **OLTP**).

2. **quote_ident(text)**:
   - **Purpose**: Escapes and quotes an identifier (e.g., table name) to prevent SQL injection or handle special characters/spaces.
   - **Input**: Text (e.g., `employees`).
   - **Output**: Quoted text (e.g., `"employees"` or `"My Table"` for a table named `My Table`).
   - **Example**: `quote_ident('employees')` returns `"employees"`.
   - **Use Case**: Ensures safe use of dynamic table names in queries, especially in scripts or PL/pgSQL.

3. **pg_size_pretty(numeric)**:
   - Same as above, used here to format table sizes (e.g., `15 MB`).

#### How the Queries Work
- **Database Size**:
  - `pg_database_size('my_application_db')` gets the raw size of `my_application_db`.
  - `pg_size_pretty` formats it (e.g., `1 GB`).
- **Table Sizes**:
  - Queries `information_schema.tables` to list tables in the `public` schema.
  - `quote_ident(table_name)` safely formats each table name.
  - `pg_total_relation_size` calculates each table’s total size (data + indexes + TOAST).
  - `pg_size_pretty` formats sizes, and results are sorted by size (descending).

#### Related Functions
Here are other PostgreSQL functions related to size and identifier handling:

1. **Size-Related Functions**:
   - **pg_relation_size(regclass)**:
     - Returns the size of a table’s main data (excluding indexes and TOAST).
     - Example: `SELECT pg_size_pretty(pg_relation_size('employees'));` might return `8 MB`.
     - Use: Isolate table data size for **OLTP** optimization.
   - **pg_indexes_size(regclass)**:
     - Returns the total size of all indexes on a table.
     - Example: `SELECT pg_size_pretty(pg_indexes_size('employees'));` might return `2 MB`.
     - Use: Assess index bloat in **OLTP** (e.g., with **GIN**/**GiST** indexes).
   - **pg_table_size(regclass)**:
     - Returns the size of a table including TOAST but excluding indexes.
     - Example: `SELECT pg_size_pretty(pg_table_size('employees'));` might return `10 MB`.
     - Use: Analyze table-specific storage in **OLAP**.
   - **pg_database_size(oid)**:
     - Alternative to `pg_database_size(name)`, using the database’s OID.
     - Example: `SELECT pg_size_pretty(pg_database_size(oid)) FROM pg_database WHERE datname = 'my_application_db';`.
   - **pg_total_relation_size(oid)**:
     - Same as `pg_total_relation_size(regclass)` but takes an OID.
     - Example: `SELECT pg_size_pretty(pg_total_relation_size(c.oid)) FROM pg_class c WHERE relname = 'employees';`.

2. **Identifier-Related Functions**:
   - **quote_literal(text)**:
     - Escapes and quotes a literal value (e.g., for data values, not identifiers).
     - Example: `quote_literal('O''Reilly')` returns `'O''Reilly'`.
     - Use: Safe string handling in PL/pgSQL or dynamic SQL.
   - **quote_nullable(text)**:
     - Like `quote_literal` but handles `NULL` values.
     - Example: `quote_nullable(NULL)` returns `NULL`.
     - Use: Safe handling of potentially null values in scripts.
   - **format(text, variadic any)**:
     - Formats a string with placeholders, automatically escaping identifiers or literals.
     - Example: `format('SELECT * FROM %I', 'employees')` returns `SELECT * FROM employees`.
     - Use: Cleaner dynamic SQL construction in PL/pgSQL.

#### Practical Example
To extend your table size query with related functions:
```sql
SELECT 
    table_name,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) AS total_size,
    pg_size_pretty(pg_relation_size(quote_ident(table_name))) AS table_size,
    pg_size_pretty(pg_indexes_size(quote_ident(table_name))) AS index_size
FROM 
    information_schema.tables
WHERE 
    table_schema = 'public'
ORDER BY 
    pg_total_relation_size(quote_ident(table_name)) DESC;
```

**Output** (example):
```
 table_name | total_size | table_size | index_size 
------------+------------+------------+------------
 employees  | 15 MB      | 10 MB      | 5 MB       
 orders     | 8 MB       | 6 MB       | 2 MB       
```

#### Key Points
- **Functions Used**:
  - `pg_database_size`: Total database size (all objects).
  - `pg_total_relation_size`: Table size including indexes and TOAST.
  - `pg_size_pretty`: Human-readable size formatting.
  - `quote_ident`: Safe identifier quoting.
- **Related Functions**:
  - `pg_relation_size`, `pg_indexes_size`, `pg_table_size` for granular size analysis.
  - `quote_literal`, `quote_nullable`, `format` for safe SQL construction.
- **Use Cases**:
  - **OLTP**: Monitor table/index sizes to optimize performance (e.g., reduce bloat).
  - **OLAP**: Identify large tables for partitioning or archiving.
- **Tools**: Use with `pg_dump` (e.g., `--schema-only` to check structure) or `\d+` in `psql` for metadata.
- **Safety**: `quote_ident` prevents injection in dynamic queries, critical for scripts.

---

### Array Functions 

PostgreSQL provides robust support for arrays, allowing you to store and manipulate lists of values within a single column. Array functions and operators enable operations like creating, accessing, modifying, and querying arrays, which are valuable for both **Online Transaction Processing (OLTP)** (e.g., storing tags or preferences) and **Online Analytical Processing (OLAP)** (e.g., aggregating lists). Given your familiarity with PostgreSQL concepts like `NUMERIC`, `MONEY`, `pg_dump`, tablespaces, and OIDs, this response explains key array functions, their usage, related operators, and practical examples, tailored to your technical context.

#### What are Arrays in PostgreSQL?
- An **array** is a data type that stores a list of elements of the same type (e.g., `INTEGER[]`, `TEXT[]`, `MONEY[]`) in a single column.
- Arrays can be one-dimensional (e.g., `{1,2,3}`) or multi-dimensional (e.g., `{{1,2},{3,4}}`).
- Use cases:
  - **OLTP**: Store tags, roles, or preferences (e.g., `user_roles TEXT[]`).
  - **OLAP**: Aggregate lists for reporting (e.g., collect product categories).

**Example**:
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT,
    tags TEXT[]
);
INSERT INTO products (name, tags) VALUES
    ('Laptop', ARRAY['electronics', 'portable']),
    ('Book', ARRAY['stationery', 'educational']);
```

#### Key Array Functions
PostgreSQL offers several built-in functions for working with arrays, found in the `pg_catalog` schema. Below are the most commonly used array functions, their purposes, and examples.

1. **array_append(anyarray, anyelement)**:
   - **Purpose**: Appends an element to the end of an array.
   - **Input**: An array and an element of the same type.
   - **Output**: New array with the element added.
   - **Example**:
     ```sql
     SELECT array_append(ARRAY[1,2], 3);
     ```
     **Output**: `{1,2,3}`
   - **Use Case**: Add a tag to a product’s `tags` in **OLTP** (e.g., append `'new'` to `tags`).

2. **array_prepend(anyelement, anyarray)**:
   - **Purpose**: Adds an element to the start of an array.
   - **Input**: An element and an array.
   - **Output**: New array with the element at the beginning.
   - **Example**:
     ```sql
     SELECT array_prepend(0, ARRAY[1,2]);
     ```
     **Output**: `{0,1,2}`
   - **Use Case**: Insert a priority flag at the start of a status array.

3. **array_cat(anyarray, anyarray)**:
   - **Purpose**: Concatenates two arrays.
   - **Input**: Two arrays of the same type.
   - **Output**: A single array combining both.
   - **Example**:
     ```sql
     SELECT array_cat(ARRAY[1,2], ARRAY[3,4]);
     ```
     **Output**: `{1,2,3,4}`
   - **Use Case**: Merge user permissions from different roles in **OLTP**.

4. **array_remove(anyarray, anyelement)**:
   - **Purpose**: Removes all occurrences of a specified element from an array.
   - **Input**: An array and an element to remove.
   - **Output**: New array without the element.
   - **Example**:
     ```sql
     SELECT array_remove(ARRAY[1,2,2,3], 2);
     ```
     **Output**: `{1,3}`
   - **Use Case**: Remove a deprecated tag from `products.tags`.

5. **array_replace(anyarray, anyelement, anyelement)**:
   - **Purpose**: Replaces all occurrences of a specified element with another.
   - **Input**: An array, element to replace, and replacement element.
   - **Output**: New array with replaced elements.
   - **Example**:
     ```sql
     SELECT array_replace(ARRAY['old', 'new', 'old'], 'old', 'updated');
     ```
     **Output**: `{updated,new,updated}`
   - **Use Case**: Update outdated category names in **OLAP** reporting.

6. **array_length(anyarray, integer)**:
   - **Purpose**: Returns the length of an array along a specified dimension.
   - **Input**: An array and dimension (1 for one-dimensional arrays).
   - **Output**: Integer (length) or NULL if the array is empty or invalid dimension.
   - **Example**:
     ```sql
     SELECT array_length(ARRAY[1,2,3], 1);
     ```
     **Output**: `3`
   - **Use Case**: Check the number of tags in `products.tags` for validation.

7. **array_lower(anyarray, integer)** and **array_upper(anyarray, integer)**:
   - **Purpose**: Return the lower and upper bounds of an array’s specified dimension (PostgreSQL arrays can have non-1-based indexing, though rare).
   - **Input**: An array and dimension.
   - **Output**: Integer (lower/upper bound) or NULL.
   - **Example**:
     ```sql
     SELECT array_lower(ARRAY[1,2,3], 1), array_upper(ARRAY[1,2,3], 1);
     ```
     **Output**: `1, 3`
   - **Use Case**: Verify array bounds in complex **OLAP** data processing.

8. **unnest(anyarray)**:
   - **Purpose**: Expands an array into a set of rows, one element per row.
   - **Input**: An array.
   - **Output**: Set of elements (as a table).
   - **Example**:
     ```sql
     SELECT unnest(ARRAY['electronics', 'portable']) AS tag;
     ```
     **Output**:
     ```
        tag      
     ---------------
      electronics
      portable
     ```
   - **Use Case**: Query individual tags from `products.tags` in **OLAP** reports.

9. **array_agg(anyelement)**:
   - **Purpose**: Aggregates values (including NULLs) into an array, typically used in `GROUP BY` queries.
   - **Input**: Column or expression.
   - **Output**: Array of values.
   - **Example**:
     ```sql
     SELECT department, array_agg(employee_name)
     FROM employees
     GROUP BY department;
     ```
     **Output** (example):
     ```
      department | array_agg                   
     ------------+-----------------------------
      Sales      | {Alice,Bob}
      HR         | {Carol}
     ```
   - **Use Case**: Collect lists of items per group in **OLAP** analytics.

10. **string_to_array(text, text)** and **array_to_string(anyarray, text)**:
    - **Purpose**:
      - `string_to_array`: Converts a delimited string to an array.
      - `array_to_string`: Converts an array to a delimited string.
    - **Input**:
      - `string_to_array`: String and delimiter.
      - `array_to_string`: Array and delimiter.
    - **Output**: Array or string.
    - **Example**:
      ```sql
      SELECT string_to_array('a,b,c', ',');
      SELECT array_to_string(ARRAY['a','b','c'], ',');
      ```
      **Output**: `{a,b,c}`, `a,b,c`
    - **Use Case**: Convert between strings and arrays for data import/export.

#### Key Array Operators
In addition to functions, PostgreSQL provides operators for arrays, which are often used in `WHERE` clauses or conditions:

1. **@> (contains)**:
   - Checks if an array contains all elements of another array.
   - Example: `ARRAY['electronics', 'portable'] @> ARRAY['electronics']` → `true`
   - Use: Filter products with specific tags.

2. **<@ (is contained by)**:
   - Checks if an array is contained within another array.
   - Example: `ARRAY['electronics'] <@ ARRAY['electronics', 'portable']` → `true`

3. **&& (overlap)**:
   - Checks if two arrays have any elements in common.
   - Example: `ARRAY['electronics', 'portable'] && ARRAY['portable', 'new']` → `true`

4. **= (equality)**:
   - Checks if two arrays are identical.
   - Example: `ARRAY[1,2] = ARRAY[1,2]` → `true`

5. **|| (concatenation)**:
   - Concatenates two arrays or an array and an element.
   - Example: `ARRAY[1,2] || ARRAY[3]` → `{1,2,3}`

#### Practical Example
Combine array functions and operators in a real-world scenario:
```sql
-- Create table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT,
    tags TEXT[],
    prices MONEY[]
);

-- Insert data
INSERT INTO products (name, tags, prices) VALUES
    ('Laptop', ARRAY['electronics', 'portable'], ARRAY[999.99::MONEY, 1099.99::MONEY]),
    ('Book', ARRAY['stationery', 'educational'], ARRAY[29.99::MONEY]);

-- Query using array functions
SELECT 
    name,
    tags,
    array_length(tags, 1) AS tag_count,
    unnest(tags) AS individual_tag,
    array_to_string(tags, ', ') AS tag_string,
    prices,
    array_agg(prices) AS price_list
FROM products
WHERE tags @> ARRAY['electronics']
GROUP BY name, tags, prices;
```

**Output** (with `LC_MONETARY = 'en_US.UTF-8'`):
```
 name   |         tags          | tag_count | individual_tag |    tag_string     |        prices         |      price_list       
--------+-----------------------+-----------+----------------+-------------------+-----------------------+-----------------------
 Laptop | {electronics,portable} |         2 | electronics    | electronics, portable | {$999.99,$1099.99} | {$999.99,$1099.99}
 Laptop | {electronics,portable} |         2 | portable       | electronics, portable | {$999.99,$1099.99} | {$999.99,$1099.99}
```

#### Integration with Your Context
- **NUMERIC/MONEY** (from your questions):
  - Use arrays with `MONEY[]` for lists of prices (as shown above).
  - Example: Store historical prices in a `MONEY[]` column and use `array_agg` to collect them.
- **pg_dump/pg_restore**:
  - Array data is included in `--data-only` dumps and schema definitions in `--schema-only`.
  - Example: `pg_dump -Fc mydb > dump.custom` preserves `TEXT[]` or `MONEY[]` columns.
- **Tablespaces**:
  - Store array-heavy tables (e.g., `products` with `tags`) in a fast tablespace (e.g., `fast_ssd`) for **OLTP** performance.
  - Example: `ALTER TABLE products SET TABLESPACE fast_ssd;`.
- **OIDs**:
  - Array columns are part of tables with OIDs in `pg_class`.
  - Query array metadata: `SELECT attname, atttypid::regtype FROM pg_attribute WHERE attrelid = 'products'::regclass AND attname = 'tags';`.
- **Size Monitoring** (from your `pg_size_pretty` query):
  - Arrays increase table size, especially for large `TEXT[]` or `MONEY[]` columns.
  - Example:
    ```sql
    SELECT pg_size_pretty(pg_total_relation_size('products'));
    ```

#### Performance Considerations
- **Storage**: Arrays are compact but can bloat tables if large (e.g., `TEXT[]` with many elements). Monitor with `pg_total_relation_size`.
- **Indexing**: Use **GIN** indexes for array columns to speed up `@>`, `<@`, and `&&` queries:
  ```sql
  CREATE INDEX idx_products_tags ON products USING GIN (tags);
  ```
- **OLTP**: Minimize array modifications (e.g., `array_append`) in hot tables to avoid bloat.
- **OLAP**: Use `unnest` and `array_agg` for efficient reporting but avoid overusing in large datasets.
- **Bloat**: Check array column bloat with `pgstattuple`:
  ```sql
  SELECT * FROM pgstattuple('products');
  ```

#### Best Practices
1. **Use Sparingly**:
   - Arrays are convenient but consider normalized tables for complex relationships (e.g., a `product_tags` table instead of `tags TEXT[]`).
2. **Index Arrays**:
   - Create **GIN** indexes for array columns used in `WHERE` clauses (e.g., `tags @> ARRAY['electronics']`).
3. **Validate Data**:
   - Use constraints or PL/pgSQL to ensure valid array data (e.g., non-empty arrays).
   - Example:
     ```sql
     ALTER TABLE products ADD CONSTRAINT check_tags CHECK (array_length(tags, 1) > 0);
     ```
4. **Format Consistently**:
   - Use `array_to_string` for export or display in **OLAP** reports.
5. **Backup Arrays**:
   - Ensure `pg_dump -Fc` captures array data correctly.
   - Test restores with `pg_restore` to verify array integrity.
6. **Monitor Size**:
   - Extend your `pg_size_pretty` query to include array-heavy tables:
     ```sql
     SELECT table_name, pg_size_pretty(pg_total_relation_size(quote_ident(table_name)))
     FROM information_schema.tables
     WHERE table_schema = 'public' AND table_name = 'products';
     ```

#### Related Concepts
- **MONEY** (from your question): Use `MONEY[]` for arrays of currency values, formatted by `LC_MONETARY`.
- **Tablespaces**: Optimize array storage with fast tablespaces (e.g., `fast_ssd`).
- **pg_dump/pg_restore**: Arrays are fully supported in custom-format dumps.
- **OIDs**: Array types have OIDs in `pg_type` (e.g., `SELECT oid, typname FROM pg_type WHERE typname = 'text[]';`).
- **LC_COLLATE/LC_CTYPE**: Affects sorting of `TEXT[]` elements in queries.

#### Troubleshooting
- **Performance Issues**:
  - Slow array queries? Add a **GIN** index or normalize data.
  - Example: `EXPLAIN SELECT * FROM products WHERE tags @> ARRAY['electronics'];`.
- **Data Corruption**:
  - Validate array data during inserts with PL/pgSQL or constraints.
- **Dump/Restore Errors**:
  - Ensure array types match during `pg_restore` (e.g., `TEXT[]` vs. `VARCHAR[]`).
- **Size Bloat**:
  - Use `pgstattuple` or `pg_total_relation_size` to identify oversized array columns.

#### Practical Example with PL/pgSQL
Create a function to add a tag to a product’s `tags` array:
```sql
CREATE OR REPLACE FUNCTION add_product_tag(p_id INTEGER, new_tag TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE products
    SET tags = array_append(tags, new_tag)
    WHERE id = p_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Product % not found', p_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT add_product_tag(1, 'new');
SELECT name, tags FROM products WHERE id = 1;
```

**Output**:
```
 name   |            tags            
--------+----------------------------
 Laptop | {electronics,portable,new}
```

**Next Steps**
- Test array functions:
  ```sql
  SELECT array_append(ARRAY['a','b'], 'c'), unnest(ARRAY[1,2,3]);
  ```
- Create a table with arrays:
  ```sql
  CREATE TABLE test_arrays (id SERIAL, values INTEGER[]);
  INSERT INTO test_arrays (values) VALUES (ARRAY[1,2,3]);
  ```
- Index an array column:
  ```sql
  CREATE INDEX idx_test_arrays ON test_arrays USING GIN (values);
  ```
- Monitor size:
  ```sql
  SELECT pg_size_pretty(pg_total_relation_size('test_arrays'));
  ```

---

### Range Functions for WHERE Clauses
In addition to operators, PostgreSQL provides functions to manipulate or inspect ranges in `WHERE` clauses:

1. **lower(anyrange)** and **upper(anyrange)**:
   - **Purpose**: Return the lower or upper bound of a range as a value.
   - **Output**: Same type as the range’s elements (e.g., `DATE` for `daterange`).
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events
     WHERE lower(duration) >= '2025-06-01';
     ```
     **Output**:
     ```
      name       |      duration      
     ------------+--------------------
      Conference | [2025-06-01,2025-06-03]
      Workshop   | [2025-06-05,2025-06-06)
     ```
   - **Use Case**: Filter by range bounds in **OLTP** or **OLAP**.

2. **isempty(anyrange)**:
   - **Purpose**: Checks if a range is empty.
   - **Output**: Boolean.
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events
     WHERE NOT isempty(duration);
     ```
     - Filters non-empty ranges (rarely needed, as most ranges are non-empty).
   - **Use Case**: Validate data integrity.

3. **range_merge(anyrange, anyrange)**:
   - **Purpose**: Returns a new range that encompasses two ranges (used in subqueries).
   - **Output**: Range type.
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events e1
     WHERE duration && (
         SELECT range_merge(duration, daterange('2025-06-02', '2025-06-04'))
         FROM events e2
         WHERE e2.id = e1.id
     );
     ```
   - **Use Case**: Merge overlapping periods in **OLAP** analysis.

---

### Conversion Functions

PostgreSQL provides a rich set of **conversion functions** to transform data between different types, formats, or representations, enabling flexible data manipulation in queries. These functions are essential for handling type casting, formatting output, and parsing input, particularly in **Online Transaction Processing (OLTP)** (e.g., validating user input) and **Online Analytical Processing (OLAP)** (e.g., formatting reports). Given your familiarity with PostgreSQL concepts like domain types, arrays, ranges, `MONEY`, and triggers, this response details key conversion functions, their purposes, usage, and practical examples, formatted concisely per your preference.

#### What are Conversion Functions?
- **Definition**: Built-in functions that convert data from one type to another (e.g., `TEXT` to `NUMERIC`, `TIMESTAMP` to `TEXT`) or reformat data (e.g., numbers to strings with specific patterns).
- **Categories**:
  - **Type Casting**: Convert between data types (e.g., `CAST`, `::`).
  - **Formatting**: Convert to human-readable strings (e.g., `to_char`).
  - **Parsing**: Convert strings to other types (e.g., `to_number`, `to_date`).
- **Storage**: Defined in `pg_catalog`, accessible globally, with OIDs in `pg_proc`.

#### Key Conversion Functions
Below are the most commonly used conversion functions, grouped by purpose, with examples.

##### 1. Type Casting Functions
These convert data between PostgreSQL types (e.g., `INTEGER`, `TEXT`, `MONEY`, `NUMERIC`).

- **CAST(expression AS type)**:
  - **Purpose**: Explicitly converts an expression to a specified type.
  - **Example**:
    ```sql
    SELECT CAST('123.45' AS NUMERIC(10,2));
    ```
    **Output**: `123.45`
  - **Use Case**: Convert `TEXT` input to `NUMERIC` for calculations in **OLTP**.

- **expression::type**:
  - **Purpose**: Shorthand for `CAST`, converts to the specified type.
  - **Example**:
    ```sql
    SELECT '2025-06-01'::DATE;
    ```
    **Output**: `2025-06-01`
  - **Use Case**: Quick type conversion in queries.

- **convert_to(text, name)**:
  - **Purpose**: Converts a string to a specified encoding (e.g., `UTF8`, `LATIN1`).
  - **Example**:
    ```sql
    SELECT convert_to('Hello', 'UTF8');
    ```
    **Output**: `\x48656c6c6f` (bytea)
  - **Use Case**: Handle text encoding in multilingual **OLTP** apps.

- **convert_from(bytea, name)**:
  - **Purpose**: Converts a byte array to a string in the specified encoding.
  - **Example**:
    ```sql
    SELECT convert_from('\x48656c6c6f'::bytea, 'UTF8');
    ```
    **Output**: `Hello`
  - **Use Case**: Decode imported binary data.

##### 2. Formatting Functions
These convert data to formatted strings, often for display.

- **to_char(anyelement, text)**:
  - **Purpose**: Formats numbers, dates, or timestamps as strings using a pattern.
  - **Patterns**:
    - `9`: Digit (e.g., `9999` for numbers).
    - `FM`: Suppress leading/trailing zeros/spaces.
    - `YYYY`, `MM`, `DD`: Date components.
    - `HH24`, `MI`, `SS`: Time components.
  - **Example**:
    ```sql
    SELECT to_char(1234.56::NUMERIC, 'FM9999.99');
    ```
    **Output**: `1234.56`
  - **Example (Date)**:
    ```sql
    SELECT to_char('2025-06-01'::DATE, 'Mon DD, YYYY');
    ```
    **Output**: `Jun 01, 2025`
  - **Use Case**: Format `MONEY` or dates for **OLAP** reports.

- **to_char(money)**:
  - **Purpose**: Formats a `MONEY` value according to `LC_MONETARY`.
  - **Example**:
    ```sql
    SET LC_MONETARY = 'en_US.UTF-8';
    SELECT to_char(1234.56::MONEY, 'FM9999.99');
    ```
    **Output**: `1234.56`
  - **Use Case**: Display `MONEY` without currency symbol.

- **array_to_string(anyarray, text)**:
  - **Purpose**: Converts an array to a delimited string (from your array question).
  - **Example**:
    ```sql
    SELECT array_to_string(ARRAY['a', 'b', 'c'], ', ');
    ```
    **Output**: `a, b, c`
  - **Use Case**: Format tags for display.

##### 3. Parsing Functions
These convert strings to other types.

- **to_number(text, text)**:
  - **Purpose**: Parses a string to a `NUMERIC` value using a pattern.
  - **Example**:
    ```sql
    SELECT to_number('1,234.56', '9,999.99');
    ```
    **Output**: `1234.56`
  - **Use Case**: Parse user input in **OLTP** forms.

- **to_date(text, text)**:
  - **Purpose**: Converts a string to a `DATE` using a pattern.
  - **Example**:
    ```sql
    SELECT to_date('06/01/2025', 'MM/DD/YYYY');
    ```
    **Output**: `2025-06-01`
  - **Use Case**: Import date strings from CSV files.

- **to_timestamp(text, text)**:
  - **Purpose**: Converts a string to a `TIMESTAMP` using a pattern.
  - **Example**:
    ```sql
    SELECT to_timestamp('2025-06-01 14:30', 'YYYY-MM-DD HH24:MI');
    ```
    **Output**: `2025-06-01 14:30:00`
  - **Use Case**: Parse log timestamps for **OLAP** analysis.

- **string_to_array(text, text)**:
  - **Purpose**: Converts a delimited string to an array (from your array question).
  - **Example**:
    ```sql
    SELECT string_to_array('a,b,c', ',');
    ```
    **Output**: `{a,b,c}`
  - **Use Case**: Parse comma-separated input.

##### 4. Specialized Conversion Functions
These handle specific types or use cases.

- **inet(text)**, **cidr(text)**:
  - **Purpose**: Convert strings to `INET` or `CIDR` network address types.
  - **Example**:
    ```sql
    SELECT '192.168.1.1'::INET;
    ```
    **Output**: `192.168.1.1`
  - **Use Case**: Store IP addresses in **OLTP**.

- **json_to_record(json)**, **jsonb_to_record(jsonb)**:
  - **Purpose**: Convert JSON/JSONB to a record type (requires column definition).
  - **Example**:
    ```sql
    SELECT * FROM json_to_record('{"id": 1, "name": "Alice"}') AS (id INTEGER, name TEXT);
    ```
    **Output**:
    ```
     id | name  
    ----+-------
      1 | Alice
    ```
  - **Use Case**: Parse JSON data in **OLAP**.

- **pg_typeof(any)**:
  - **Purpose**: Returns the type of an expression as a `regtype`.
  - **Example**:
    ```sql
    SELECT pg_typeof('123.45'::NUMERIC);
    ```
    **Output**: `numeric`
  - **Use Case**: Debug type issues in triggers.

#### Practical Example
Combine conversion functions in a real-world scenario:
```sql
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    product TEXT,
    price MONEY,
    sale_date TEXT -- Simulated unparsed date
);

INSERT INTO sales (product, price, sale_date) VALUES
    ('Laptop', 999.99, '06/01/2025'),
    ('Book', 29.99, '06/02/2025');

-- Query with conversions
SELECT 
    product,
    to_char(price, 'FM9999.99') AS formatted_price,
    to_date(sale_date, 'MM/DD/YYYY') AS parsed_date,
    price::NUMERIC AS numeric_price
FROM sales
WHERE to_date(sale_date, 'MM/DD/YYYY') >= '2025-06-01'::DATE;
```

**Output** (with `LC_MONETARY = 'en_US.UTF-8'`):
```
 product | formatted_price | parsed_date | numeric_price 
---------+-----------------+-------------+---------------
 Laptop  |         999.99  | 2025-06-01  |        999.99
 Book    |          29.99  | 2025-06-02  |         29.99
```

**Explanation**:
- `to_char(price, 'FM9999.99')`: Formats `MONEY` as a string.
- `to_date(sale_date, 'MM/DD/YYYY')`: Parses text to `DATE`.
- `price::NUMERIC`: Converts `MONEY` to `NUMERIC` for calculations.

#### Performance Considerations
- **OLTP**:
  - Avoid complex conversions (e.g., `to_char` with heavy patterns) in hot paths; use simple casts (`::`).
  - Example: `price::NUMERIC` is faster than `to_number(to_char(price, '9999.99'), '9999.99')`.
- **OLAP**:
  - Use `to_char` for report formatting but cache results in materialized views for large datasets.
  - Example:
    ```sql
    CREATE MATERIALIZED VIEW sales_report AS
    SELECT product, to_char(price, 'FM9999.99') AS price
    FROM sales;
    ```
- **Indexing**:
  - Create indexes on converted columns if used in `WHERE`:
    ```sql
    CREATE INDEX idx_sales_date ON sales (to_date(sale_date, 'MM/DD/YYYY'));
    ```
- **Size**:
  - Conversions don’t directly affect storage, but tables with converted data (e.g., audit logs) can grow; monitor with `pg_total_relation_size`:
    ```sql
    SELECT pg_size_pretty(pg_total_relation_size('sales'));
    ```

#### Best Practices
1. **Use Simple Casts**:
   - Prefer `::` or `CAST` for straightforward conversions (e.g., `'123'::INTEGER`).
2. **Validate Input**:
   - Use `try_cast` (custom function) or error handling in PL/pgSQL to avoid parsing errors:
     ```sql
     CREATE FUNCTION try_cast_num(text) RETURNS NUMERIC AS $$
     BEGIN
         RETURN $1::NUMERIC;
     EXCEPTION WHEN OTHERS THEN
         RETURN NULL;
     END;
     $$ LANGUAGE plpgsql;
     ```
3. **Match Locale**:
   - Ensure `LC_MONETARY` aligns for `MONEY` conversions (from your `MONEY` question):
     ```sql
     SET LC_MONETARY = 'en_US.UTF-8';
     ```
4. **Optimize for Display**:
   - Use `to_char` for user-facing output, not calculations.
   - Example: `to_char(price, 'FM9999.99')` for reports.
5. **Backup Conversions**:
   - Ensure `pg_dump -Fc` captures tables with converted data:
     ```bash
     pg_dump -Fc mydb > dump.custom
     ```
   - Test `pg_restore` for type consistency.
6. **Monitor Performance**:
   - Use `EXPLAIN` for queries with conversions:
     ```sql
     EXPLAIN SELECT * FROM sales WHERE to_date(sale_date, 'MM/DD/YYYY') = '2025-06-01';
     ```

#### Troubleshooting
- **Casting Errors**:
  - Handle invalid casts in PL/pgSQL:
    ```sql
    SELECT try_cast_num('invalid'); -- Returns NULL
    ```
- **Locale Issues**:
  - Check `LC_MONETARY` for `MONEY` formatting:
    ```sql
    SHOW LC_MONETARY;
    ```
- **Performance**:
  - Slow queries? Avoid conversions in `WHERE` or use indexes on expressions:
    ```sql
    CREATE INDEX idx_sales_numeric ON sales ((price::NUMERIC));
    ```
- **Restore Issues**:
  - Ensure type definitions (e.g., `MONEY`, `NUMERIC`) are restored:
    ```bash
    pg_restore --section=pre-data -d mydb dump.custom
    ```

#### Practical Example with PL/pgSQL
Create a function to parse and validate dates:
```sql
CREATE FUNCTION parse_sale_date(p_date TEXT)
RETURNS DATE AS $$
BEGIN
    RETURN to_date(p_date, 'MM/DD/YYYY');
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Invalid date format: %', p_date;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT product, parse_sale_date(sale_date) AS valid_date
FROM sales
WHERE parse_sale_date(sale_date) >= '2025-06-01';
```

**Output**:
```
 product | valid_date 
---------+------------
 Laptop  | 2025-06-01
 Book    | 2025-06-02
```

**Trigger with Conversion**:
```sql
CREATE FUNCTION log_numeric_price()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO price_audit (product_id, price_numeric, logged_at)
    VALUES (NEW.id, NEW.price::NUMERIC, CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_price
AFTER INSERT OR UPDATE OF price ON sales
FOR EACH ROW
EXECUTE FUNCTION log_numeric_price();
```

#### Next Steps
- Test conversions:
  ```sql
  SELECT to_char(1234.56::MONEY, 'FM9999.99'), to_date('06/01/2025', 'MM/DD/YYYY');
  ```
- Create a table with conversions:
  ```sql
  CREATE TABLE logs (id SERIAL, amount TEXT);
  INSERT INTO logs (amount) VALUES ('1234.56');
  SELECT to_number(amount, '9999.99') FROM logs;
  ```
- Monitor size:
  ```sql
  SELECT pg_size_pretty(pg_total_relation_size('logs'));
  ```

---

### Date and Time Functions in PostgreSQL

#### Overview of Date and Time Functions

**Key points**:  
- Date and time functions manipulate, calculate, or format temporal data (DATE, TIME, TIMESTAMP, INTERVAL).  
- Used for date arithmetic, formatting, extraction, and comparisons.  
- Essential for tasks like scheduling, reporting, or filtering by time periods.

#### Common Date and Time Functions

##### CURRENT_DATE, CURRENT_TIME, CURRENT_TIMESTAMP

**Key points**:  
- `CURRENT_DATE`: Returns current date.  
- `CURRENT_TIME`: Returns current time with time zone.  
- `CURRENT_TIMESTAMP`: Returns current date and time with time zone.  
- `NOW()`: Alias for CURRENT_TIMESTAMP.  
- Used for capturing system date/time or setting default values.

**Example**:  
```sql
SELECT CURRENT_DATE AS today, CURRENT_TIMESTAMP AS now;
```

**Output**:  
Returns e.g., `2025-05-14` for date and `2025-05-14 22:52:00-07` for timestamp.

##### EXTRACT

**Key points**:  
- `EXTRACT(field FROM source)`: Extracts components (e.g., year, month, day, hour) from DATE, TIME, or TIMESTAMP.  
- Common fields: `YEAR`, `MONTH`, `DAY`, `HOUR`, `MINUTE`, `SECOND`, `DOW` (day of week, 0-6), `DOY` (day of year, 1-365/366).  
- Used for analyzing or grouping by date parts.

**Example**:  
```sql
SELECT EXTRACT(YEAR FROM created_at) AS year
FROM orders
WHERE EXTRACT(MONTH FROM created_at) = 5;
```

**Output**:  
Returns e.g., `2025` for orders in May.

##### DATE_PART

**Key points**:  
- `DATE_PART('field', source)`: Similar to EXTRACT, but supports more granular fields (e.g., milliseconds, quarter).  
- Fields are specified as strings (e.g., 'year', 'month', 'day').  
- Used for precise component extraction.

**Example**:  
```sql
SELECT DATE_PART('hour', logged_in) AS login_hour
FROM sessions;
```

**Output**:  
Returns e.g., `22` for a login at 22:52.

##### TO_DATE, TO_TIMESTAMP

**Key points**:  
- `TO_DATE(text, format)`: Converts text to DATE using a format pattern.  
- `TO_TIMESTAMP(text, format)`: Converts text to TIMESTAMP.  
- Common format tokens: `YYYY` (4-digit year), `MM` (month), `DD` (day), `HH24` (24-hour), `MI` (minutes).  
- Used for parsing string-based date/time inputs.

**Example**:  
```sql
SELECT TO_DATE('2025-05-14', 'YYYY-MM-DD') AS parsed_date;
SELECT TO_TIMESTAMP('2025-05-14 22:52', 'YYYY-MM-DD HH24:MI') AS parsed_timestamp;
```

**Output**:  
Returns `2025-05-14` for date and `2025-05-14 22:52:00` for timestamp.

##### TO_CHAR

**Key points**:  
- `TO_CHAR(source, format)`: Converts DATE, TIME, or TIMESTAMP to formatted text.  
- Uses format tokens like `YYYY`, `Mon`, `Day`, `HH24`, `MI`, `SS`.  
- Used for custom date/time formatting in reports or displays.

**Example**:  
```sql
SELECT TO_CHAR(created_at, 'Day, DD Mon YYYY') AS formatted_date
FROM events;
```

**Output**:  
Returns e.g., `Wednesday, 14 May 2025`.

##### DATE_TRUNC

**Key points**:  
- `DATE_TRUNC('field', source)`: Truncates timestamp to specified precision (e.g., year, month, day, hour).  
- Fields: `year`, `month`, `day`, `hour`, `minute`, etc.  
- Used for grouping or rounding timestamps.

**Example**:  
```sql
SELECT DATE_TRUNC('month', order_date) AS month_start
FROM orders
GROUP BY DATE_TRUNC('month', order_date);
```

**Output**:  
Returns e.g., `2025-05-01 00:00:00`.

##### INTERVAL

**Key points**:  
- `INTERVAL`: Represents a duration (e.g., '1 day', '2 hours').  
- Used with arithmetic operators to add/subtract time from DATE/TIMESTAMP.  
- Can be used with `AGE` to calculate time differences.

**Example**:  
```sql
SELECT CURRENT_TIMESTAMP + INTERVAL '1 day' AS tomorrow;
SELECT AGE(birth_date) AS age
FROM users;
```

**Output**:  
Returns e.g., `2025-05-15 22:52:00` for tomorrow and `25 years 3 months` for age.

##### AGE

**Key points**:  
- `AGE(timestamp)`: Returns interval between current date and given timestamp.  
- `AGE(timestamp1, timestamp2)`: Returns interval between two timestamps.  
- Used for calculating durations like user age or time between events.

**Example**:  
```sql
SELECT AGE(CURRENT_DATE, '2000-01-01') AS time_since;
```

**Output**:  
Returns e.g., `25 years 4 months 13 days`.

##### Date Arithmetic

**Key points**:  
- DATE, TIME, TIMESTAMP support `+`, `-` with INTERVAL.  
- Subtraction between two timestamps returns an INTERVAL.  
- Used for calculating deadlines, durations, or offsets.

**Example**:  
```sql
SELECT order_date - INTERVAL '7 days' AS week_ago
FROM orders;
SELECT end_time - start_time AS duration
FROM events;
```

**Output**:  
Returns e.g., `2025-05-07` for week_ago and `02:30:00` for duration.

##### Time Zone Functions

**Key points**:  
- `AT TIME ZONE`: Converts TIMESTAMP to another time zone.  
- `SET TIME ZONE`: Sets session time zone.  
- `timezone(zone, timestamp)`: Alternative syntax for conversion.  
- Used for handling global applications or standardizing times.

**Example**:  
```sql
SELECT CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AS utc_time;
```

**Output**:  
Returns e.g., `2025-05-15 05:52:00+00`.

#### Performance Considerations

**Key points**:  
- Indexes on DATE/TIMESTAMP columns improve performance for range queries.  
- Avoid functions on columns in WHERE clauses to leverage indexes.  
- Use `DATE_TRUNC` or `EXTRACT` for efficient grouping.  
- Analyze queries with EXPLAIN for optimization.

**Example**:  
```sql
CREATE INDEX idx_order_date ON orders (order_date);
SELECT COUNT(*)
FROM orders
WHERE order_date >= '2025-05-01' AND order_date < '2025-06-01';
```

#### Combining Date and Time Functions

**Key points**:  
- Functions can be nested for complex transformations (e.g., formatting extracted parts).  
- Common for generating reports or filtering by specific time periods.

**Example**:  
```sql
SELECT TO_CHAR(DATE_TRUNC('month', created_at), 'Mon YYYY') AS month,
       COUNT(*) AS order_count
FROM orders
WHERE EXTRACT(YEAR FROM created_at) = 2025
GROUP BY DATE_TRUNC('month', created_at);
```

**Output**:  
Returns e.g., `May 2025 | 150`.

**Conclusion**:  
Date and time functions in PostgreSQL provide robust tools for manipulating, formatting, and analyzing temporal data, critical for scheduling, reporting, and time-based queries.

**Next steps**:  
- Combine functions for complex queries, like generating weekly reports.  
- Test performance with EXPLAIN on large datasets.  
- Explore indexing strategies for temporal data.

**Recommended subtopics**:  
- Advanced interval arithmetic.  
- Time zone management for global applications.  
- Window functions for time-based analytics.

---

### Mathematical Functions in PostgreSQL

#### Overview of Mathematical Functions

**Key points**:  
- Mathematical functions perform numeric calculations, transformations, or statistical operations on numeric data types (INTEGER, FLOAT, NUMERIC, etc.).  
- Used for arithmetic, rounding, trigonometry, random number generation, and aggregations.  
- Essential for financial calculations, statistical analysis, or data transformations.

#### Common Mathematical Functions

##### ABS

**Key points**:  
- `ABS(number)`: Returns the absolute value of a number.  
- Works with INTEGER, FLOAT, NUMERIC.  
- Used for handling negative values or calculating differences.

**Example**:  
```sql
SELECT ABS(balance) AS absolute_balance
FROM accounts;
```

**Output**:  
For `-150.75`, returns `150.75`.

##### ROUND

**Key points**:  
- `ROUND(number [, precision])`: Rounds a number to the specified precision (default: 0).  
- Works with FLOAT, NUMERIC.  
- Used for formatting monetary values or simplifying decimal output.

**Example**:  
```sql
SELECT ROUND(price, 2) AS rounded_price
FROM products;
```

**Output**:  
For `19.999`, returns `20.00`.

##### CEIL and FLOOR

**Key points**:  
- `CEIL(number)`: Returns the smallest integer greater than or equal to the number.  
- `FLOOR(number)`: Returns the largest integer less than or equal to the number.  
- Used for discretizing continuous values or binning data.

**Example**:  
```sql
SELECT CEIL(4.3) AS ceiling, FLOOR(4.7) AS floor;
```

**Output**:  
Returns `5` for ceiling, `4` for floor.

##### TRUNC

**Key points**:  
- `TRUNC(number [, precision])`: Truncates a number to the specified precision without rounding.  
- Works with FLOAT, NUMERIC.  
- Used for removing decimal parts or formatting numbers.

**Example**:  
```sql
SELECT TRUNC(123.456, 1) AS truncated;
```

**Output**:  
Returns `123.4`.

##### DIV and MOD

**Key points**:  
- `DIV(number, divisor)`: Returns integer quotient of division.  
- `MOD(number, divisor)`: Returns remainder of division.  
- Used for integer arithmetic or grouping data (e.g., modulo for cyclic patterns).

**Example**:  
```sql
SELECT DIV(10, 3) AS quotient, MOD(10, 3) AS remainder;
```

**Output**:  
Returns `3` for quotient, `1` for remainder.

##### POWER and EXP

**Key points**:  
- `POWER(base, exponent)`: Raises base to the power of exponent.  
- `EXP(number)`: Returns e raised to the power of number (e ≈ 2.71828).  
- Used for exponential calculations or growth models.

**Example**:  
```sql
SELECT POWER(2, 3) AS power, EXP(1) AS e;
```

**Output**:  
Returns `8` for power, `2.718281828459045` for e.

##### LN and LOG

**Key points**:  
- `LN(number)`: Returns natural logarithm (base e) of a number.  
- `LOG(base, number)`: Returns logarithm of number to specified base.  
- Used for logarithmic scaling or analyzing exponential data.

**Example**:  
```sql
SELECT LN(2.718281828459045) AS natural_log, LOG(10, 100) AS log_base_10;
```

**Output**:  
Returns `1.0` for natural_log, `2.0` for log_base_10.

##### SQRT

**Key points**:  
- `SQRT(number)`: Returns the square root of a non-negative number.  
- Used for geometric calculations or distance formulas.

**Example**:  
```sql
SELECT SQRT(16) AS square_root;
```

**Output**:  
Returns `4.0`.

##### Trigonometric Functions

**Key points**:  
- Functions include `SIN`, `COS`, `TAN`, `ASIN`, `ACOS`, `ATAN`, `ATAN2`.  
- Arguments in radians; use `RADIANS(degrees)` for conversion.  
- Used for geometric or spatial calculations.

**Example**:  
```sql
SELECT SIN(RADIANS(30)) AS sine, COS(RADIANS(30)) AS cosine;
```

**Output**:  
Returns `0.5` for sine, `0.866025403784439` for cosine.

##### RANDOM

**Key points**:  
- `RANDOM()`: Returns a random number between 0.0 (inclusive) and 1.0 (exclusive).  
- Used for sampling, simulations, or random assignments.

**Example**:  
```sql
SELECT RANDOM() AS random_value;
```

**Output**:  
Returns e.g., `0.723941672515869`.

##### Aggregate Functions

**Key points**:  
- Numeric aggregates: `SUM`, `AVG`, `MIN`, `MAX`, `COUNT`.  
- `STDDEV(number)`: Standard deviation (population or sample with `STDDEV_POP`, `STDDEV_SAMP`).  
- `VARIANCE(number)`: Variance (population or sample with `VAR_POP`, `VAR_SAMP`).  
- Used for statistical analysis or summarizing data.

**Example**:  
```sql
SELECT AVG(price) AS avg_price, STDDEV(price) AS price_stddev
FROM products;
```

**Output**:  
Returns e.g., `19.99` for avg_price, `2.5` for price_stddev.

#### Performance Considerations

**Key points**:  
- Mathematical functions on columns in WHERE clauses may prevent index usage.  
- Indexes on numeric columns improve range or comparison queries.  
- Aggregate functions benefit from indexes when used with GROUP BY.  
- Use EXPLAIN to analyze query performance.

**Example**:  
```sql
CREATE INDEX idx_price ON products (price);
SELECT ROUND(AVG(price), 2) AS avg_price
FROM products
WHERE price > 10;
```

#### Combining Mathematical Functions

**Key points**:  
- Functions can be nested for complex calculations (e.g., rounding the result of a power operation).  
- Common in financial models, statistical queries, or geometric computations.

**Example**:  
```sql
SELECT ROUND(POWER(quantity, 2) * price, 2) AS total_cost
FROM order_items
WHERE MOD(quantity, 2) = 0;
```

**Output**:  
For `quantity=4`, `price=10.50`, returns `168.00`.

**Conclusion**:  
Mathematical functions in PostgreSQL enable precise numeric calculations, statistical analysis, and data transformations, supporting a wide range of analytical and operational tasks.

**Next steps**:  
- Combine functions for complex calculations, like financial or statistical models.  
- Test performance with EXPLAIN on large datasets.  
- Explore indexing for numeric queries.

**Recommended subtopics**:  
- Numeric data type precision (NUMERIC vs. FLOAT).  
- Window functions for running totals or rankings.  
- Custom aggregate functions for specialized calculations.

---

