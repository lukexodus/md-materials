## Data Types and Constraints


PostgreSQL offers extensive data types. Common types used in Supabase:

**Numeric types:**

- `INTEGER` / `INT` - whole numbers (-2,147,483,648 to 2,147,483,647)
- `BIGINT` - large whole numbers
- `SERIAL` / `BIGSERIAL` - auto-incrementing integers
- `NUMERIC(precision, scale)` / `DECIMAL` - exact decimal numbers
- `REAL` / `DOUBLE PRECISION` - floating-point numbers

**Text types:**

- `TEXT` - variable unlimited length (recommended for most use cases)
- `VARCHAR(n)` - variable length with limit
- `CHAR(n)` - fixed length

**Boolean:**

- `BOOLEAN` - true/false/null

**Date and time:**

- `DATE` - date only (no time)
- `TIME` - time only (no date)
- `TIMESTAMP` - date and time without timezone
- `TIMESTAMP WITH TIME ZONE` / `TIMESTAMPTZ` - date and time with timezone (recommended)

**UUID:**

- `UUID` - universally unique identifier (recommended for primary keys in distributed systems)

**JSON:**

- `JSON` - JSON data, stored as text
- `JSONB` - JSON data in binary format (faster, supports indexing, recommended)

**Arrays:**

- `TEXT[]`, `INTEGER[]`, etc. - arrays of any data type

**Special types:**

- `ENUM` - custom enumerated type
- `POINT`, `LINE`, `POLYGON` - geometric types
- `INET`, `CIDR` - network address types

**Constraints ensure data integrity:**

```sql
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,  -- NOT NULL: value required
  price NUMERIC(10, 2) CHECK (price > 0),  -- CHECK: custom validation
  sku TEXT UNIQUE,  -- UNIQUE: no duplicates
  category TEXT DEFAULT 'uncategorized',  -- DEFAULT: fallback value
  stock INTEGER CHECK (stock >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Constraint types:**

- `NOT NULL` - prevents null values
- `UNIQUE` - ensures uniqueness across rows
- `CHECK` - validates data against condition
- `DEFAULT` - provides default value when none specified
- `PRIMARY KEY` - combines NOT NULL and UNIQUE, identifies row
- `FOREIGN KEY` - references another table's primary key

