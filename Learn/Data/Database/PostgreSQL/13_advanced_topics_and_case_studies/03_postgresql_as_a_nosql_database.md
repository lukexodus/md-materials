## PostgreSQL as a NoSQL Database


### Introduction to PostgreSQL's NoSQL Capabilities

PostgreSQL is traditionally known as a robust relational database management system (RDBMS), but it has evolved to offer powerful NoSQL capabilities that rival dedicated NoSQL databases. These features allow developers to combine the reliability and ACID compliance of a traditional RDBMS with the flexibility and scalability often associated with NoSQL systems.

**Key Points:**

- PostgreSQL provides multiple NoSQL data types and storage options
- Combines ACID compliance with schema flexibility
- Supports both structured and unstructured data
- Can replace multiple specialized databases in a technology stack

### JSON and JSONB Data Types

PostgreSQL offers two specialized data types for storing JSON data: JSON and JSONB.

#### JSON vs JSONB Comparison

```sql
-- Creating tables with JSON and JSONB columns
CREATE TABLE products_json (
    id SERIAL PRIMARY KEY,
    data JSON
);

CREATE TABLE products_jsonb (
    id SERIAL PRIMARY KEY,
    data JSONB
);
```

**Key Differences:**

- JSON stores data as exact text (preserves whitespace, duplicate keys, key order)
- JSONB stores data in a decomposed binary format (faster to process, supports indexing)
- JSON is faster for insertion, JSONB is faster for processing and querying
- Only JSONB supports indexing

### Querying JSONB Data

PostgreSQL provides rich operators and functions for working with JSON data:

```sql
-- Insert sample JSONB data
INSERT INTO products_jsonb (data) VALUES 
('{"name": "Laptop", "price": 1200, "specs": {"cpu": "i7", "ram": 16, "storage": 512}, "tags": ["electronics", "computers"]}');

-- Simple key extraction
SELECT data->'name' AS product_name FROM products_jsonb;

-- Extract value as text (removes quotes)
SELECT data->>'price' AS price FROM products_jsonb;

-- Nested object queries
SELECT data->'specs'->>'cpu' AS cpu FROM products_jsonb;

-- Array element access (zero-based)
SELECT data->'tags'->>0 AS first_tag FROM products_jsonb;

-- Filter by JSON properties
SELECT * FROM products_jsonb 
WHERE data->>'name' = 'Laptop';

-- Filter by nested properties
SELECT * FROM products_jsonb 
WHERE data->'specs'->>'ram' = '16';

-- Check if array contains value
SELECT * FROM products_jsonb 
WHERE data->'tags' ? 'electronics';

-- Test if key exists
SELECT * FROM products_jsonb 
WHERE data ? 'warranty';
```

### JSONB Indexing

One of PostgreSQL's most powerful NoSQL features is the ability to index JSON data:

```sql
-- GIN index for general JSONB queries
CREATE INDEX idx_products_data ON products_jsonb USING GIN (data);

-- GIN index for specific operations (key existence)
CREATE INDEX idx_products_data_ops ON products_jsonb USING GIN (data jsonb_path_ops);

-- B-tree index for specific JSON properties
CREATE INDEX idx_products_name ON products_jsonb ((data->>'name'));

-- Expression index for nested properties
CREATE INDEX idx_products_ram ON products_jsonb ((data->'specs'->>'ram'));
```

**Key Points:**

- GIN (Generalized Inverted Index) efficiently indexes JSONB data
- `jsonb_path_ops` optimizes for containment queries (`@>`)
- Expression indexes improve performance for specific property queries
- Consider index size and maintenance overhead

### JSON Path Queries

PostgreSQL 12+ supports the SQL/JSON path query language:

```sql
-- Simple path expressions
SELECT jsonb_path_query(data, '$.name') FROM products_jsonb;

-- Filter array elements
SELECT jsonb_path_query(data, '$.tags[*] ? (@ == "electronics")') FROM products_jsonb;

-- Complex conditions
SELECT * FROM products_jsonb
WHERE jsonb_path_exists(data, '$.specs.ram ? (@ > 8 && @ <= 16)');

-- Arithmetic expressions
SELECT jsonb_path_query(data, '$.price * 0.9') AS sale_price FROM products_jsonb;

-- Aggregate array values
SELECT jsonb_path_query(data, '$.specs.storage + $.specs.ram') AS total_memory 
FROM products_jsonb;
```

### JSONB Modification Functions

PostgreSQL provides functions for modifying JSONB data without replacing the entire document:

```sql
-- Add or update fields
UPDATE products_jsonb 
SET data = jsonb_set(data, '{price}', '1299', true)
WHERE data->>'name' = 'Laptop';

-- Add nested fields
UPDATE products_jsonb 
SET data = jsonb_set(data, '{specs, gpu}', '"RTX 3060"', true)
WHERE data->>'name' = 'Laptop';

-- Remove fields
UPDATE products_jsonb 
SET data = data - 'tags'
WHERE data->>'name' = 'Laptop';

-- Remove specific array element
UPDATE products_jsonb 
SET data = data #- '{tags,1}'
WHERE data->>'name' = 'Laptop';

-- Concatenate JSONB objects
UPDATE products_jsonb 
SET data = data || '{"warranty": "2 years", "in_stock": true}'::jsonb
WHERE data->>'name' = 'Laptop';

-- Merge arrays (unique values)
UPDATE products_jsonb 
SET data = jsonb_set(
    data, 
    '{tags}', 
    (data->'tags') || '["sale", "new_arrival"]'::jsonb,
    true
)
WHERE data->>'name' = 'Laptop';
```

### HSTORE Extension

The HSTORE extension provides a key-value store for simpler NoSQL use cases:

```sql
-- Enable the extension
CREATE EXTENSION hstore;

-- Create table with hstore column
CREATE TABLE products_hstore (
    id SERIAL PRIMARY KEY,
    attributes hstore
);

-- Insert data
INSERT INTO products_hstore (attributes) VALUES (
    'name => Laptop, price => 1200, brand => Dell'
);

-- Query using key lookup
SELECT attributes -> 'name' AS product_name FROM products_hstore;

-- Check if key exists
SELECT * FROM products_hstore WHERE attributes ? 'brand';

-- Check if key-value pair exists
SELECT * FROM products_hstore WHERE attributes @> 'price => 1200';

-- Get all keys
SELECT akeys(attributes) FROM products_hstore;

-- Get all values
SELECT avals(attributes) FROM products_hstore;

-- Convert to JSON
SELECT hstore_to_json(attributes) FROM products_hstore;
```

**Key Points:**

- Simpler than JSONB, but less powerful for complex data
- Good for flat key-value structures
- Efficient for simple lookups and existence checks
- Easy conversion between HSTORE and JSON

### Array Data Type

PostgreSQL's array support enables NoSQL-like behavior for multi-value fields:

```sql
-- Create table with array columns
CREATE TABLE products_array (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    tags TEXT[],
    prices NUMERIC[]
);

-- Insert array data
INSERT INTO products_array (name, tags, prices) VALUES
('Laptop', ARRAY['electronics', 'computers', 'portable'], ARRAY[1200, 1299, 1399]);

-- Access array elements (1-indexed)
SELECT name, tags[1], prices[1] FROM products_array;

-- Check if array contains value
SELECT * FROM products_array WHERE 'electronics' = ANY(tags);

-- Array length
SELECT name, array_length(tags, 1) AS tag_count FROM products_array;

-- Unnest array into rows
SELECT name, unnest(tags) AS tag FROM products_array;

-- Array concatenation
UPDATE products_array SET tags = array_cat(tags, ARRAY['sale', 'new'])
WHERE name = 'Laptop';

-- Array intersection
SELECT array_intersection(ARRAY[1, 2, 3], ARRAY[2, 3, 4]);

-- Array to string
SELECT name, array_to_string(tags, ', ') AS tag_list FROM products_array;
```

### XML Data Type

For XML-based document storage, PostgreSQL offers a dedicated XML type:

```sql
-- Create table with XML column
CREATE TABLE products_xml (
    id SERIAL PRIMARY KEY,
    data XML
);

-- Insert XML data
INSERT INTO products_xml (data) VALUES (
    '<product>
        <name>Laptop</name>
        <price>1200</price>
        <specs>
            <cpu>i7</cpu>
            <ram>16</ram>
            <storage>512</storage>
        </specs>
        <tags>
            <tag>electronics</tag>
            <tag>computers</tag>
        </tags>
    </product>'
);

-- Query XML with XPath
SELECT 
    xpath('/product/name/text()', data) AS name,
    xpath('/product/price/text()', data) AS price
FROM products_xml;

-- Extract values as text
SELECT 
    (xpath('/product/name/text()', data))[1]::text AS name,
    (xpath('/product/price/text()', data))[1]::text AS price
FROM products_xml;

-- Check if value exists
SELECT * FROM products_xml 
WHERE xpath_exists('/product/specs/cpu[text()="i7"]', data);

-- XML validation (requires DTD or XML Schema)
CREATE TABLE validated_xml (
    id SERIAL PRIMARY KEY,
    data XML,
    CONSTRAINT valid_xml CHECK (validate_against_xml_schema('schema.xsd', data))
);
```

### Document-Oriented Design Patterns

#### Hybrid Schema Design

```sql
-- Combines structured columns with flexible JSONB
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

-- Add flexible customer metadata
INSERT INTO customers (email, name, metadata) VALUES (
    'john@example.com',
    'John Doe',
    '{
        "preferences": {
            "theme": "dark",
            "notifications": {"email": true, "sms": false}
        },
        "devices": [
            {"type": "mobile", "last_login": "2023-04-15T14:30:00Z"},
            {"type": "desktop", "last_login": "2023-04-16T09:15:00Z"}
        ],
        "address": {
            "street": "123 Main St",
            "city": "Boston",
            "state": "MA",
            "zip": "02108"
        }
    }'
);
```

#### Entity-Attribute-Value (EAV) Pattern

```sql
-- Traditional EAV model with JSONB enhancement
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    base_attributes JSONB NOT NULL, -- Common attributes
    category_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE product_attributes (
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    attributes JSONB NOT NULL, -- Category-specific attributes
    PRIMARY KEY (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Insert a laptop product
INSERT INTO products (name, base_attributes, category_id) VALUES (
    'XPS 13',
    '{"brand": "Dell", "price": 1299, "currency": "USD"}',
    1 -- Electronics category
);

-- Insert laptop-specific attributes
INSERT INTO product_attributes (product_id, category_id, attributes) VALUES (
    1, -- Product ID
    1, -- Electronics category
    '{
        "specs": {
            "cpu": "Intel i7",
            "ram": "16GB",
            "storage": "512GB SSD"
        },
        "dimensions": {
            "width": 11.6,
            "depth": 7.8,
            "height": 0.6,
            "unit": "inches"
        },
        "weight": {
            "value": 2.7,
            "unit": "lbs"
        }
    }'
);
```

### Schemaless Tables with Generated Columns

PostgreSQL 12+ allows generated columns based on JSON expressions:

```sql
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    data JSONB NOT NULL,
    event_type TEXT GENERATED ALWAYS AS (data->>'type') STORED,
    user_id INTEGER GENERATED ALWAYS AS ((data->>'user_id')::INTEGER) STORED
);

CREATE INDEX idx_events_event_type ON events (event_type);
CREATE INDEX idx_events_user_id ON events (user_id);

-- Insert event data
INSERT INTO events (data) VALUES (
    '{"type": "login", "user_id": 123, "details": {"ip": "192.168.1.1", "device": "mobile"}}'
);

-- Query using generated columns
SELECT * FROM events WHERE event_type = 'login' AND user_id = 123;
```

**Key Points:**

- Generated columns create indexed fields from JSON properties
- Improves query performance while maintaining schema flexibility
- Enforces some data validation while retaining NoSQL benefits

### Time-Series Data with JSONB

PostgreSQL can handle time-series data with a NoSQL approach:

```sql
CREATE TABLE sensor_data (
    sensor_id INTEGER NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    readings JSONB NOT NULL,
    PRIMARY KEY (sensor_id, timestamp)
) PARTITION BY RANGE (timestamp);

-- Create monthly partitions
CREATE TABLE sensor_data_202301 PARTITION OF sensor_data
    FOR VALUES FROM ('2023-01-01') TO ('2023-02-01');
    
CREATE TABLE sensor_data_202302 PARTITION OF sensor_data
    FOR VALUES FROM ('2023-02-01') TO ('2023-03-01');

-- Insert sensor readings
INSERT INTO sensor_data (sensor_id, timestamp, readings) VALUES
(1, '2023-01-15 12:30:00', '{"temperature": 22.5, "humidity": 45, "pressure": 1013, "metadata": {"location": "room1", "calibration": 0.98}}');

-- Create indexes for common queries
CREATE INDEX idx_sensor_readings_temp ON sensor_data ((readings->>'temperature'));
CREATE INDEX idx_sensor_timestamp ON sensor_data (timestamp DESC);
```

### Full-Text Search with JSONB

PostgreSQL supports full-text search over JSONB content:

```sql
-- Create a table with JSONB documents
CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    document JSONB
);

-- Insert sample articles
INSERT INTO articles (document) VALUES
('{"title": "PostgreSQL as NoSQL Database", "content": "PostgreSQL offers robust NoSQL capabilities with JSONB...", "author": {"name": "Jane Smith", "email": "jane@example.com"}, "tags": ["postgresql", "nosql", "database"]}');

-- Create a GIN index for full text search
CREATE INDEX idx_articles_document_gin ON articles USING GIN (document);

-- Full text search in specific fields
SELECT id, document->>'title' 
FROM articles 
WHERE document->>'title' ILIKE '%nosql%' OR document->>'content' ILIKE '%nosql%';

-- More sophisticated text search with to_tsvector
CREATE INDEX idx_articles_content_fts ON articles 
USING GIN (to_tsvector('english', document->>'content'));

SELECT id, document->>'title'
FROM articles
WHERE to_tsvector('english', document->>'content') @@ to_tsquery('english', 'postgresql & nosql');

-- Search across all text fields
CREATE OR REPLACE FUNCTION jsonb_text_fields(j jsonb) RETURNS text AS $$
    SELECT string_agg(value::text, ' ')
    FROM jsonb_each_text(j)
    WHERE jsonb_typeof(j->key) = 'string';
$$ LANGUAGE SQL IMMUTABLE;

CREATE INDEX idx_articles_all_text ON articles 
USING GIN (to_tsvector('english', jsonb_text_fields(document)));
```

### Performance Optimization

#### JSONB Containment Indexes

```sql
-- Create index optimized for containment queries
CREATE INDEX idx_products_jsonb_path ON products_jsonb USING GIN (data jsonb_path_ops);

-- Very efficient containment query
SELECT * FROM products_jsonb 
WHERE data @> '{"specs": {"ram": 16}}';
```

#### Specialized JSON Functions

```sql
-- Extract all keys at top level
SELECT jsonb_object_keys(data) FROM products_jsonb;

-- Convert JSONB to record set (useful for reporting)
SELECT p.id, x.* 
FROM products_jsonb p,
LATERAL jsonb_to_record(p.data) AS x(name text, price numeric, specs jsonb);

-- Convert nested JSONB to records
SELECT 
    p.id, 
    x.name,
    x.price,
    s.cpu,
    s.ram,
    s.storage
FROM products_jsonb p,
LATERAL jsonb_to_record(p.data) AS x(name text, price numeric, specs jsonb),
LATERAL jsonb_to_record(x.specs) AS s(cpu text, ram integer, storage integer);
```

### NoSQL Migration Strategies

#### MongoDB to PostgreSQL JSONB

```sql
-- Create table to store MongoDB-like documents
CREATE TABLE documents (
    id TEXT PRIMARY KEY, -- MongoDB _id
    collection TEXT NOT NULL, -- MongoDB collection name
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for common queries
CREATE INDEX idx_documents_collection ON documents (collection);
CREATE INDEX idx_documents_data ON documents USING GIN (data);

-- Example of MongoDB-style query in PostgreSQL
SELECT data FROM documents 
WHERE collection = 'users' 
AND data @> '{"age": {"$gte": 18}}';
```

#### MongoDB-like Query Function

```sql
-- Create a function to simulate MongoDB-style queries
CREATE OR REPLACE FUNCTION mongo_query(
    collection_name TEXT,
    query_conditions JSONB
) RETURNS SETOF JSONB AS $$
DECLARE
    mongo_operator TEXT;
    value JSONB;
    field TEXT;
    sql_query TEXT := 'SELECT data FROM documents WHERE collection = $1';
    params JSONB := jsonb_build_object('1', collection_name);
    param_count INTEGER := 1;
BEGIN
    FOR field IN SELECT * FROM jsonb_object_keys(query_conditions) LOOP
        param_count := param_count + 1;
        
        IF jsonb_typeof(query_conditions->field) = 'object' THEN
            -- Handle operators like $gt, $lt, etc.
            FOR mongo_operator IN SELECT * FROM jsonb_object_keys(query_conditions->field) LOOP
                value := query_conditions->field->mongo_operator;
                
                CASE mongo_operator
                    WHEN '$eq' THEN
                        sql_query := sql_query || ' AND data->>''' || field || ''' = $' || param_count;
                    WHEN '$gt' THEN
                        sql_query := sql_query || ' AND (data->>''' || field || ''')::numeric > $' || param_count;
                    WHEN '$gte' THEN
                        sql_query := sql_query || ' AND (data->>''' || field || ''')::numeric >= $' || param_count;
                    WHEN '$lt' THEN
                        sql_query := sql_query || ' AND (data->>''' || field || ''')::numeric < $' || param_count;
                    WHEN '$lte' THEN
                        sql_query := sql_query || ' AND (data->>''' || field || ''')::numeric <= $' || param_count;
                    WHEN '$ne' THEN
                        sql_query := sql_query || ' AND data->>''' || field || ''' != $' || param_count;
                    ELSE
                        RAISE EXCEPTION 'Unsupported MongoDB operator: %', mongo_operator;
                END CASE;
                
                params := jsonb_insert(params, ARRAY[param_count::text], value);
            END LOOP;
        ELSE
            -- Simple equality
            sql_query := sql_query || ' AND data->>' || quote_literal(field) || ' = $' || param_count;
            params := jsonb_insert(params, ARRAY[param_count::text], query_conditions->field);
        END IF;
    END LOOP;
    
    RETURN QUERY EXECUTE sql_query USING VARIADIC array(
        SELECT params->>key FROM jsonb_object_keys(params) key ORDER BY key::int
    );
END;
$$ LANGUAGE plpgsql;

-- Usage example
SELECT mongo_query('users', '{"name": "John", "age": {"$gte": 18, "$lt": 65}}');
```

### Transactional Document Updates

Unlike traditional NoSQL databases, PostgreSQL allows transactional document updates:

```sql
BEGIN;

-- Update multiple documents atomically
UPDATE products_jsonb
SET data = jsonb_set(data, '{in_stock}', 'false'::jsonb, true)
WHERE data->>'category' = 'laptops';

-- Update inventory counts
UPDATE inventory
SET stock_count = stock_count - 1
WHERE product_id IN (SELECT id FROM products_jsonb WHERE data->>'name' = 'XPS 13');

-- Create order with document data
INSERT INTO orders (user_id, items)
VALUES (
    1001,
    '[{"product_id": 5, "name": "XPS 13", "price": 1299, "quantity": 1}]'::jsonb
);

COMMIT;
```

**Key Points:**

- ACID compliance for document operations
- Complex multi-document transactions
- Rollback capability for document modifications
- Consistent state across related document collections

### Schema Evolution Strategies

Managing schema changes in a "schemaless" environment:

```sql
-- Function to migrate JSONB documents to new schema
CREATE OR REPLACE FUNCTION migrate_documents(
    collection TEXT,
    migration_function TEXT
) RETURNS INTEGER AS $$
DECLARE
    processed INTEGER := 0;
    doc RECORD;
    updated_doc JSONB;
BEGIN
    FOR doc IN SELECT id, data FROM documents WHERE collection = migrate_documents.collection
    LOOP
        EXECUTE 'SELECT ' || migration_function || '($1)' INTO updated_doc USING doc.data;
        
        UPDATE documents SET 
            data = updated_doc,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = doc.id;
        
        processed := processed + 1;
    END LOOP;
    
    RETURN processed;
END;
$$ LANGUAGE plpgsql;

-- Example migration function
CREATE OR REPLACE FUNCTION migrate_user_schema_v1_to_v2(data JSONB) RETURNS JSONB AS $$
BEGIN
    -- Rename field
    IF data ? 'user_name' THEN
        data = jsonb_set(data, '{username}', data->'user_name');
        data = data - 'user_name';
    END IF;
    
    -- Add schema version
    data = jsonb_set(data, '{schema_version}', '"2"');
    
    -- Convert string to array
    IF data ? 'roles' AND jsonb_typeof(data->'roles') = 'string' THEN
        data = jsonb_set(data, '{roles}', ('[' || data->>'roles' || ']')::jsonb);
    END IF;
    
    RETURN data;
END;
$$ LANGUAGE plpgsql;

-- Apply migration
SELECT migrate_documents('users', 'migrate_user_schema_v1_to_v2');
```

### Foreign Table Integration

PostgreSQL can integrate NoSQL data sources via Foreign Data Wrappers:

```sql
-- Install MongoDB FDW
CREATE EXTENSION postgres_fdw;

-- Create server connection to MongoDB
CREATE SERVER mongodb_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'mongodb-server', port '27017', dbname 'testdb');

-- Create user mapping
CREATE USER MAPPING FOR postgres
SERVER mongodb_server
OPTIONS (username 'mongouser', password 'secret');

-- Create foreign table that maps to MongoDB collection
CREATE FOREIGN TABLE mongodb_users (
    id TEXT,
    data JSONB
)
SERVER mongodb_server
OPTIONS (collection 'users');

-- Query MongoDB data directly
SELECT data->>'name' AS name, data->>'email' AS email
FROM mongodb_users
WHERE data->>'active' = 'true';

-- Join MongoDB data with PostgreSQL tables
SELECT u.data->>'name' AS name, o.order_number
FROM mongodb_users u
JOIN orders o ON o.user_id = u.id::integer
WHERE u.data->>'premium_member' = 'true';
```

### Securing JSONB Data

PostgreSQL's security features work with JSONB data:

```sql
-- Row-level security for document access
CREATE TABLE tenant_documents (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL,
    document JSONB NOT NULL
);

-- Enable row-level security
ALTER TABLE tenant_documents ENABLE ROW LEVEL SECURITY;

-- Create policy for tenant isolation
CREATE POLICY tenant_isolation ON tenant_documents
    USING (tenant_id = current_setting('app.current_tenant_id')::INTEGER);

-- Encrypt sensitive JSONB fields
CREATE OR REPLACE FUNCTION encrypt_pii(data JSONB) RETURNS JSONB AS $$
DECLARE
    result JSONB := data;
BEGIN
    IF result ? 'credit_card' THEN
        result = jsonb_set(result, '{credit_card}', to_jsonb(
            pgp_sym_encrypt(result->>'credit_card', current_setting('app.encryption_key'))
        ));
    END IF;
    
    IF result ? 'ssn' THEN
        result = jsonb_set(result, '{ssn}', to_jsonb(
            pgp_sym_encrypt(result->>'ssn', current_setting('app.encryption_key'))
        ));
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Apply encryption on insert/update
CREATE TRIGGER encrypt_pii_trigger
BEFORE INSERT OR UPDATE ON customer_profiles
FOR EACH ROW EXECUTE FUNCTION encrypt_pii_trigger();
```

### Recommended Related Topics

- PostgreSQL TOAST Storage for Large JSONB Documents
- Materialized Views with JSONB for Reporting
- Sharding Strategies for PostgreSQL Document Collections
- Migration Patterns from MongoDB to PostgreSQL
- Time-Series Data Management with JSONB and TimescaleDB
- WebSocket Change Data Capture for Real-time JSONB Updates

---

