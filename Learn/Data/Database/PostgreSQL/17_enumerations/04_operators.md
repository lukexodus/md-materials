## Operators


### Operations with Ranges in WHERE Clauses

#### What are Range Types?
- **Range types** represent a continuous range of values with a lower and upper bound, which can be inclusive (`[`, `]`) or exclusive (`(`, `)`).
- **Built-in Range Types**:
  - `int4range`: Integer range (32-bit).
  - `int8range`: Big integer range (64-bit).
  - `numrange`: Numeric range (arbitrary precision, like `NUMERIC`).
  - `tsrange`: Timestamp without time zone.
  - `tstzrange`: Timestamp with time zone.
  - `daterange`: Date range.
- **Custom Ranges**: You can create custom range types using `CREATE TYPE`.
- **Storage**: Ranges are compact, storing bounds and bound types (inclusive/exclusive).
- **Example**:
  ```sql
  CREATE TABLE events (
      id SERIAL PRIMARY KEY,
      name TEXT,
      duration daterange
  );
  INSERT INTO events (name, duration) VALUES
      ('Conference', '[2025-06-01,2025-06-03]'),
      ('Workshop', '[2025-06-05,2025-06-06)');
  ```

#### Range Operators in WHERE Clauses
PostgreSQL provides specialized operators for range types, used in `WHERE` clauses to filter rows based on range relationships. These operators are particularly useful for checking overlaps, containment, or adjacency. Below are the key operators, their purposes, and examples.

1. **&& (Overlaps)**:
   - **Purpose**: Checks if two ranges have any elements in common (i.e., they overlap).
   - **Syntax**: `range1 && range2`
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events
     WHERE duration && daterange('2025-06-02', '2025-06-04');
     ```
     **Output**:
     ```
      name       |      duration      
     ------------+--------------------
      Conference | [2025-06-01,2025-06-03]
     ```
     - The `Conference` event overlaps with June 2–4, 2025.
   - **Use Case**: Find conflicting schedules in **OLTP** (e.g., room bookings) or overlapping periods in **OLAP** (e.g., sales promotions).

2. **@> (Contains)**:
   - **Purpose**: Checks if the first range contains the second range or a single value.
   - **Syntax**: `range1 @> range2` or `range1 @> value`
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events
     WHERE duration @> '2025-06-02'::date;
     ```
     **Output**:
     ```
      name       |      duration      
     ------------+--------------------
      Conference | [2025-06-01,2025-06-03]
     ```
     - June 2, 2025, is within the `Conference` duration.
   - **Use Case**: Check if a date falls within an event period (**OLTP**) or a value is in a price range (**OLAP**).

3. **<@ (Is Contained By)**:
   - **Purpose**: Checks if the first range is contained within the second range.
   - **Syntax**: `range1 <@ range2`
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events
     WHERE duration <@ daterange('2025-06-01', '2025-06-07');
     ```
     **Output**:
     ```
      name       |      duration      
     ------------+--------------------
      Conference | [2025-06-01,2025-06-03]
      Workshop   | [2025-06-05,2025-06-06)
     ```
     - Both events are fully contained within June 1–7, 2025.
   - **Use Case**: Identify events within a broader time frame (**OLAP** reporting).

4. **= (Equality)**:
   - **Purpose**: Checks if two ranges are identical (same bounds and inclusivity).
   - **Syntax**: `range1 = range2`
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events
     WHERE duration = daterange('2025-06-01', '2025-06-03');
     ```
     **Output**:
     ```
      name       |      duration      
     ------------+--------------------
      Conference | [2025-06-01,2025-06-03]
     ```
   - **Use Case**: Find exact matches for predefined ranges.

5. **<> (Not Equal)**:
   - **Purpose**: Checks if two ranges are different.
   - **Syntax**: `range1 <> range2`
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events
     WHERE duration <> daterange('2025-06-01', '2025-06-03');
     ```
     **Output**:
     ```
      name     |      duration      
     ----------+--------------------
      Workshop | [2025-06-05,2025-06-06)
     ```
   - **Use Case**: Exclude specific ranges in queries.

6. **-|- (Adjacent)**:
   - **Purpose**: Checks if two ranges are adjacent (i.e., they touch but do not overlap).
   - **Syntax**: `range1 -|- range2`
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events
     WHERE duration -|- daterange('2025-06-03', '2025-06-05');
     ```
     **Output**:
     ```
      name       |      duration      
     ------------+--------------------
      Conference | [2025-06-01,2025-06-03]
     ```
     - `Conference` ends on June 3, adjacent to a range starting June 3.
   - **Use Case**: Schedule back-to-back events in **OLTP**.

7. **<< (Strictly Left Of)**:
   - **Purpose**: Checks if the first range is entirely before the second (no overlap).
   - **Syntax**: `range1 << range2`
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events
     WHERE duration << daterange('2025-06-04', '2025-06-07');
     ```
     **Output**:
     ```
      name       |      duration      
     ------------+--------------------
      Conference | [2025-06-01,2025-06-03]
     ```
   - **Use Case**: Find events before a specific period.

8. **>> (Strictly Right Of)**:
   - **Purpose**: Checks if the first range is entirely after the second.
   - **Syntax**: `range1 >> range2`
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events
     WHERE duration >> daterange('2025-06-01', '2025-06-04');
     ```
     **Output**:
     ```
      name     |      duration      
     ----------+--------------------
      Workshop | [2025-06-05,2025-06-06)
     ```
   - **Use Case**: Identify future events.

9. **&< (Does Not Extend to Right)**:
   - **Purpose**: Checks if the first range does not extend beyond the second’s upper bound.
   - **Syntax**: `range1 &< range2`
   - **Example**:
     ```sql
     SELECT name, duration
     FROM events
     WHERE duration &< daterange('2025-06-03', '2025-06-07');
     ```
     **Output**:
     ```
      name       |      duration      
     ------------+--------------------
      Conference | [2025-06-01,2025-06-03]
     ```
   - **Use Case**: Ensure events end by a deadline.

10. **&> (Does Not Extend to Left)**:
    - **Purpose**: Checks if the first range does not extend before the second’s lower bound.
    - **Syntax**: `range1 &> range2`
    - **Example**:
      ```sql
      SELECT name, duration
      FROM events
      WHERE duration &> daterange('2025-06-04', '2025-06-07');
      ```
      **Output**:
      ```
       name     |      duration      
      ----------+--------------------
       Workshop | [2025-06-05,2025-06-06)
      ```
    - **Use Case**: Find events starting after a cutoff.

#### Practical Example
Combine range operators in a real-world scenario:
```sql
-- Create table with MONEY range for pricing
CREATE TABLE promotions (
    id SERIAL PRIMARY KEY,
    product TEXT,
    price_range numrange,
    validity daterange
);

-- Insert data
INSERT INTO promotions (product, price_range, validity) VALUES
    ('Laptop', '[500.00,1000.00]', '[2025-06-01,2025-06-15]'),
    ('Book', '[20.00,50.00)', '[2025-06-10,2025-06-20]');

-- Query promotions active on June 12, 2025, with price range including $30
SELECT product, price_range, validity
FROM promotions
WHERE validity @> '2025-06-12'::date
AND price_range @> 30.00;
```

**Output**:
```
 product |  price_range   |      validity      
---------+----------------+--------------------
 Book    | [20.00,50.00)  | [2025-06-10,2025-06-20]
```

**Explanation**:
- `validity @> '2025-06-12'` filters promotions active on June 12, 2025.
- `price_range @> 30.00` ensures the price range includes $30.00.

#### Performance Considerations
- **Indexing**: Use **GiST** or **SP-GiST** indexes for range columns to speed up operators like `&&`, `@>`, `<@`:
  ```sql
  CREATE INDEX idx_promotions_validity ON promotions USING GIST (validity);
  ```
  - **GiST**: General-purpose for range queries.
  - **SP-GiST**: More efficient for non-overlapping ranges (e.g., unique schedules).
- **OLTP**: Minimize range updates to avoid index bloat; use constraints to enforce non-overlapping ranges:
  ```sql
  ALTER TABLE promotions ADD EXCLUDE USING GIST (validity WITH &&);
  ```
- **OLAP**: Use `unnest` or subqueries with ranges sparingly for large datasets; leverage indexes.
- **Bloat**: Monitor table bloat with `pgstattuple`:
  ```sql
  SELECT * FROM pgstattuple('promotions');
  ```

#### Best Practices
1. **Choose the Right Range Type**:
   - Use `daterange` for dates, `numrange` for prices, `tsrange` for timestamps.
   - Example: `numrange` for `NUMERIC` or `MONEY`-based ranges.
2. **Index Range Columns**:
   - Add **GiST** indexes for frequent `WHERE` clause operations (e.g., `&&`, `@>`).
3. **Validate Ranges**:
   - Use constraints to prevent invalid ranges:
     ```sql
     ALTER TABLE promotions ADD CHECK (NOT isempty(validity));
     ```
4. **Combine with Arrays**:
   - Store multiple ranges in a `daterange[]` column for complex scenarios, but normalize if querying individual ranges frequently.
5. **Backup and Restore**:
   - Ensure `pg_dump -Fc` captures range data and indexes.
   - Test `pg_restore` to verify range type compatibility.
6. **Monitor Performance**:
   - Use `EXPLAIN` to optimize range queries:
     ```sql
     EXPLAIN SELECT * FROM promotions WHERE validity && daterange('2025-06-01', '2025-06-15');
     ```

#### Troubleshooting
- **Slow Queries**:
  - Add a **GiST** index or check query plans with `EXPLAIN`.
  - Example: `CREATE INDEX idx_promotions_price ON promotions USING GIST (price_range);`.
- **Invalid Ranges**:
  - Ensure bounds are valid (e.g., lower ≤ upper):
    ```sql
    SELECT name, duration FROM events WHERE lower(duration) <= upper(duration);
    ```
- **Dump/Restore Issues**:
  - Verify range types exist in the target database during `pg_restore`.
- **Locale Issues**:
  - For `numrange` with `MONEY`, ensure `LC_MONETARY` consistency (from your `MONEY` question).

#### Practical Example with PL/pgSQL
Create a function to find overlapping events:
```sql
CREATE OR REPLACE FUNCTION find_overlapping_events(check_range daterange)
RETURNS TABLE (event_name TEXT, event_duration daterange) AS $$
BEGIN
    RETURN QUERY
    SELECT name, duration
    FROM events
    WHERE duration && check_range;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT * FROM find_overlapping_events(daterange('2025-06-02', '2025-06-04'));
```

**Output**:
```
 event_name |      event_duration      
------------+--------------------------
 Conference | [2025-06-01,2025-06-03]
```

**Next Steps**
- Test range operators:
  ```sql
  SELECT * FROM promotions WHERE validity && daterange('2025-06-12', '2025-06-15');
  ```
- Create a table with ranges:
  ```sql
  CREATE TABLE bookings (id SERIAL, room TEXT, period tsrange);
  INSERT INTO bookings (room, period) VALUES ('Room A', '[2025-06-01 09:00,2025-06-01 17:00]');
  ```
- Index a range column:
  ```sql
  CREATE INDEX idx_bookings_period ON bookings USING GIST (period);
  ```
- Monitor size:
  ```sql
  SELECT pg_size_pretty(pg_total_relation_size('bookings'));
  ```

---

