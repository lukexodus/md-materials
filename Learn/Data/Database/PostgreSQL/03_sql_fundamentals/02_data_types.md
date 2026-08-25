## Data Types


### Introduction to PostgreSQL Data Types

PostgreSQL offers a rich variety of data types to store different kinds of data efficiently and maintain data integrity. Understanding these data types is fundamental to designing optimal database schemas.

### Numeric Types

#### Integer Types

```sql
-- Integer types with different storage sizes
SMALLINT   -- 2 bytes, range: -32,768 to 32,767
INTEGER    -- 4 bytes, range: -2,147,483,648 to 2,147,483,647 (most common)
BIGINT     -- 8 bytes, range: -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807

-- Auto-incrementing integers
SERIAL     -- 4 bytes, auto-incrementing integer
SMALLSERIAL -- 2 bytes, auto-incrementing smallint
BIGSERIAL  -- 8 bytes, auto-incrementing bigint
```

#### Floating-Point Types

```sql
-- Floating-point types
REAL       -- 4 bytes, 6 decimal digits precision
DOUBLE PRECISION -- 8 bytes, 15 decimal digits precision

-- Examples
CREATE TABLE measurements (
    temperature REAL,
    pressure DOUBLE PRECISION
);
```

#### Fixed-Precision Types

```sql
-- NUMERIC/DECIMAL for exact arithmetic
NUMERIC(precision, scale)  -- precision: total digits, scale: decimal digits
DECIMAL(precision, scale)  -- identical to NUMERIC

-- Examples
CREATE TABLE financial (
    amount NUMERIC(10,2),  -- 10 total digits with 2 after decimal point (Ex. 12345678.90)
    tax_rate NUMERIC(5,4)  -- 5 total digits with 4 after decimal point
);

-- For monetary values
MONEY      -- 8 bytes, fixed precision
```

### Character Types

```sql
-- Fixed-length, space padded
CHAR(n)    -- Exactly n characters, space-padded if shorter

-- Variable-length with limit
VARCHAR(n) -- Up to n characters, no padding

-- Unlimited length
TEXT       -- Variable unlimited length

-- Examples
CREATE TABLE user_profiles (
    username CHAR(16),           -- Always 16 characters stored
    password VARCHAR(255),       -- Up to 255 characters
    biography TEXT               -- Unlimited length text
);
```

### Binary Data Types

```sql
-- Binary data storage
BYTEA      -- Variable-length binary string

-- Example: storing an image
INSERT INTO images (name, data) 
VALUES ('logo.png', '\x89504E470D0A1A0A'::BYTEA);
```

### Date and Time Types

```sql
-- Date and time types
DATE                    -- Date only (no time), 4 bytes
TIME                    -- Time only (no date), 8 bytes
TIME WITH TIME ZONE     -- Time with timezone, 12 bytes
TIMESTAMP               -- Date and time, 8 bytes
TIMESTAMP WITH TIME ZONE -- Date and time with timezone, 8 bytes
INTERVAL                -- Time interval, 16 bytes

-- Examples
CREATE TABLE events (
    event_date DATE,
    start_time TIME,
    end_time TIME,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    duration INTERVAL
);

-- Date/time literals
INSERT INTO events VALUES 
    ('2023-12-25', '09:00', '12:00', '2023-12-20 15:30:00+00', '3 hours');

-- Date/time functions
SELECT 
    CURRENT_DATE,
    CURRENT_TIME,
    CURRENT_TIMESTAMP,
    NOW(),
    AGE('2023-12-25', '2023-01-01');
```

### Boolean Type

```sql
-- Boolean type (true/false)
BOOLEAN    -- 1 byte

-- Examples
CREATE TABLE tasks (
    task_name VARCHAR(100),
    completed BOOLEAN DEFAULT FALSE
);

-- Boolean accepts various input formats
INSERT INTO tasks VALUES 
    ('Setup database', TRUE),
    ('Create schema', 't'),
    ('Import data', 'yes'),
    ('Verify data', '1'),
    ('Document schema', 'false');
```

### Enumerated Types

```sql
-- Create custom enum type
CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');

-- Use enum type
CREATE TABLE user_states (
    username VARCHAR(50),
    current_mood mood
);

-- Insert enum values
INSERT INTO user_states VALUES ('alice', 'happy');
```

### Geometric Types

```sql
-- Geometric types for spatial data
POINT          -- Point on a plane (x,y)
LINE           -- Infinite line
LSEG           -- Finite line segment
BOX            -- Rectangular box
PATH           -- Closed path (polygon)
PATH           -- Open path
POLYGON        -- Polygon
CIRCLE         -- Circle

-- Examples
CREATE TABLE geo_objects (
    center POINT,
    shape POLYGON,
    radius CIRCLE
);

INSERT INTO geo_objects VALUES 
    (POINT(0,0), 
     POLYGON('(0,0), (1,0), (1,1), (0,1)'), 
     CIRCLE '(0,0), 10');
```

### Network Address Types

```sql
-- Network address types
CIDR       -- IPv4 or IPv6 network address
INET       -- IPv4 or IPv6 host address with optional netmask
MACADDR    -- MAC address

-- Examples
CREATE TABLE network_devices (
    ip_address INET,
    network CIDR,
    mac MACADDR
);

INSERT INTO network_devices VALUES 
    ('192.168.1.5', '192.168.1.0/24', '08:00:2b:01:02:03');
```

### JSON Types

```sql
-- JSON types
JSON       -- Stores exact copy of input text
JSONB      -- Stores binary format for faster processing

-- Examples
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    data JSON,
    metadata JSONB
);

-- Inserting JSON data
INSERT INTO documents (data, metadata) VALUES 
    ('{"name": "John", "addresses": [{"city": "New York", "state": "NY"}]}',
     '{"tags": ["important", "customer"], "priority": 1}');

-- Querying JSON data
SELECT data->'name' AS name,
       data->'addresses'->0->'city' AS city,
       metadata->'tags' AS tags
FROM documents;
```

### Array Types

```sql
-- Array of any data type
INTEGER[]  -- Array of integers
VARCHAR[]  -- Array of varchars

-- Examples
CREATE TABLE products (
    product_name VARCHAR(100),
    categories VARCHAR[],
    dimensions INTEGER[3] -- Exactly 3 integers (length, width, height)
);

-- Insert arrays
INSERT INTO products VALUES 
    ('Smartphone', ARRAY['Electronics', 'Mobile', 'Communication'], ARRAY[140, 70, 8]),
    ('Desk', ARRAY['Furniture', 'Office'], ARRAY[120, 80, 75]);

-- Access array elements (1-based indexing)
SELECT product_name, categories[1], dimensions[3] FROM products;

-- Array functions
SELECT product_name, array_length(categories, 1) FROM products;
```

### Range Types

```sql
-- Range types
INT4RANGE  -- Range of integers
INT8RANGE  -- Range of bigints
NUMRANGE   -- Range of numeric
TSRANGE    -- Range of timestamps without time zone
TSTZRANGE  -- Range of timestamps with time zone
DATERANGE  -- Range of dates

-- Examples
CREATE TABLE reservations (
    room_id INTEGER,
    reserved DATERANGE
);

-- Insert ranges
INSERT INTO reservations VALUES 
    (101, '[2023-01-01, 2023-01-05)'),  -- End date is exclusive
    (102, '[2023-01-10, 2023-01-15]');  -- End date is inclusive

-- Range operators
SELECT * FROM reservations 
WHERE reserved @> '2023-01-03'::DATE;  -- Contains date

SELECT * FROM reservations 
WHERE reserved && DATERANGE('2023-01-04', '2023-01-12');  -- Overlaps with range
```

### Composite Types

```sql
-- Create a composite type
CREATE TYPE address AS (
    street VARCHAR(100),
    city VARCHAR(50),
    zipcode CHAR(5)
);

-- Use composite type in a table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    shipping_address address,
    billing_address address
);

-- Insert composite values
INSERT INTO customers (name, shipping_address, billing_address) VALUES 
    ('John Smith', 
     ROW('123 Main St', 'Boston', '02108'),
     ROW('123 Main St', 'Boston', '02108'));

-- Access composite fields
SELECT name, (shipping_address).city FROM customers;
```

### Domain Types

```sql
-- Create a domain type (with constraints)
CREATE DOMAIN us_postal_code AS TEXT
CHECK(
    VALUE ~ '^\d{5}$' OR
    VALUE ~ '^\d{5}-\d{4}$'
);

-- Use domain type
CREATE TABLE addresses (
    street TEXT,
    city TEXT,
    postal_code us_postal_code
);
```

### UUID Type

```sql
-- Universally Unique Identifiers
UUID  -- 128-bit quantity

-- Requires uuid-ossp extension for generation functions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id INTEGER,
    login_time TIMESTAMP WITH TIME ZONE
);
```

### Full-Text Search Types

```sql
-- Full-text search types
TSVECTOR   -- Document optimized for text search
TSQUERY    -- Text search query

-- Example
CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    title TEXT,
    body TEXT,
    search_vector TSVECTOR
);

-- Create index for faster search
CREATE INDEX articles_search_idx ON articles USING GIN (search_vector);

-- Update vector on insert
CREATE TRIGGER tsvector_update BEFORE INSERT OR UPDATE
ON articles FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(search_vector, 'pg_catalog.english', title, body);
```

### XML Type

```sql
-- XML data type
XML  -- XML data

-- Example
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    content XML
);

-- Insert XML
INSERT INTO documents (content) VALUES (
    '<document>
        <title>PostgreSQL XML Type</title>
        <body>Example of XML storage</body>
    </document>'
);

-- XPath queries
SELECT xpath('/document/title/text()', content) 
FROM documents;
```

### Special Types

```sql
-- Special-purpose types
OID        -- Object identifier
pg_lsn     -- PostgreSQL Log Sequence Number
txid_snapshot -- Transaction ID snapshot
```

### Type Conversion

```sql
-- Explicit type conversion with CAST
SELECT CAST('42' AS INTEGER);
SELECT CAST(42 AS TEXT);

-- Shorthand notation
SELECT '42'::INTEGER;
SELECT 42::TEXT;

-- Conversion functions
SELECT to_char(CURRENT_DATE, 'YYYY-MM-DD');
SELECT to_date('2023-12-31', 'YYYY-MM-DD');
SELECT to_timestamp('2023-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS');
```

### Custom Type Selection Guidelines

**Example: Choosing between Numeric Types**

```
For whole numbers:
- Small range counters (e.g., item quantity): SMALLINT
- General purpose IDs, counts: INTEGER
- Large numbers, aggregations: BIGINT

For decimal values:
- Financial calculations: NUMERIC(precision, scale)
- Scientific measurements (precision not critical): REAL or DOUBLE PRECISION
- Currency with fixed decimals: NUMERIC(19,4) or MONEY
```

**Example: Text Storage Optimization**

```
- Fixed-length codes (e.g., ISO country codes): CHAR(2)
- Variable user input with limits: VARCHAR(n)
- Large or unknown length content: TEXT
```

**Conclusion**

PostgreSQL's extensive type system allows for precise data modeling and storage efficiency. Selecting appropriate data types enhances database performance, ensures data integrity, and provides domain-specific functionality. By understanding the capabilities and limitations of each type, database designers can create schemas that accurately represent their application's data requirements while maintaining optimal performance.

---

