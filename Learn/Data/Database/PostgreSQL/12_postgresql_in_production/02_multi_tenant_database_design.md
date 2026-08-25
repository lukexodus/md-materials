## Multi-Tenant Database Design


### Understanding Multi-Tenancy

Multi-tenant database architecture allows a single application instance to serve multiple customer organizations (tenants) while keeping their data logically separated. In PostgreSQL, this approach is particularly powerful due to the database's robust security features, schema management capabilities, and extensibility.

**Key Points:**

- Multi-tenancy optimizes resource usage by allowing multiple clients to share infrastructure
- Proper design ensures data isolation, security, and performance
- PostgreSQL offers several implementation approaches with different tradeoffs

### Multi-Tenancy Approaches in PostgreSQL

#### Separate Databases

Each tenant gets its own dedicated PostgreSQL database within the same PostgreSQL server instance.

```sql
-- Create a new database for a tenant
CREATE DATABASE tenant_acme_corp;
```

**Advantages:**

- Complete isolation between tenants
- Simplified backup and restore per tenant
- Easy to implement tenant-specific database extensions
- Clear resource limits and monitoring per tenant

**Disadvantages:**

- Higher maintenance overhead with many tenants
- More complex connection management
- Difficult to share data across tenants
- Potentially inefficient resource utilization

#### Separate Schemas

All tenants share a single database, but each tenant gets its own schema.

```sql
-- Create a schema for a new tenant
CREATE SCHEMA tenant_acme_corp;

-- Create a table in the tenant's schema
CREATE TABLE tenant_acme_corp.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL
);
```

**Advantages:**

- Easier database management than separate databases
- Good isolation while allowing cross-tenant queries when needed
- Shared connection pools and resources
- Support for global tables accessible to all tenants

**Disadvantages:**

- More complex application logic for schema routing
- Backup/restore operations more complex for individual tenants
- Potential for query errors affecting multiple tenants

#### Shared Schema with Tenant ID

All tenants share the same database and schemas, with a tenant identifier column in each table.

```sql
-- Create a shared table with tenant_id column
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    tenant_id UUID NOT NULL,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL
);

-- Create an index on tenant_id for performance
CREATE INDEX idx_users_tenant_id ON users(tenant_id);
```

**Advantages:**

- Simplest to implement and maintain
- Most efficient resource utilization
- Simplifies schema migrations and updates
- Facilitates cross-tenant reporting and analytics

**Disadvantages:**

- Lower isolation level, higher risk of data leakage
- Requires diligent application-level filtering
- All tables must include tenant identification
- Potential performance issues with very large tenants

### Row-Level Security for Enhanced Protection

PostgreSQL's Row-Level Security (RLS) feature provides an additional layer of protection for multi-tenant databases, especially for shared schema approaches.

```sql
-- Enable row-level security on a table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create a policy that restricts access based on tenant_id
CREATE POLICY tenant_isolation_policy ON users
    USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

**Key Points:**

- RLS enforces tenant isolation at the database level
- Prevents data leakage even with incorrect application queries
- Works with existing queries without modification
- Current tenant identifier typically set via connection parameters

### Implementing Tenant Context

Setting and managing tenant context is crucial for multi-tenant operations:

```sql
-- Application sets the tenant context for the current session
SET app.current_tenant_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- For longer-term settings
ALTER ROLE app_user SET app.default_tenant_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- Creating tenant-specific roles
CREATE ROLE tenant_acme_corp;
GRANT tenant_acme_corp TO app_user;
```

### Schema Migrations and Updates

Managing schema changes across multiple tenants requires careful planning:

#### Using Liquibase or Flyway

```yaml
# Example Liquibase changelog for multi-tenant setup
databaseChangeLog:
  - changeSet:
      id: 1
      author: dbadmin
      changes:
        - createTable:
            tableName: users
            columns:
              - column:
                  name: id
                  type: serial
                  constraints:
                    primaryKey: true
              - column:
                  name: tenant_id
                  type: uuid
                  constraints:
                    nullable: false
              # Other columns...
        - createIndex:
            indexName: idx_users_tenant_id
            tableName: users
            columns:
              - column:
                  name: tenant_id
```

#### For Schema-per-Tenant Approach

```sql
-- Function to apply migrations to all tenant schemas
CREATE OR REPLACE FUNCTION apply_migration_to_all_tenants() RETURNS void AS $$
DECLARE
    tenant_schema RECORD;
BEGIN
    FOR tenant_schema IN SELECT schema_name FROM information_schema.schemata
                         WHERE schema_name LIKE 'tenant_%'
    LOOP
        EXECUTE format('SET search_path TO %I', tenant_schema.schema_name);
        
        -- Migration SQL statements here
        EXECUTE 'ALTER TABLE users ADD COLUMN last_login TIMESTAMP';
        
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

### Performance Considerations

#### Indexing Strategies

```sql
-- Composite index for tenant-specific queries
CREATE INDEX idx_tenant_user_lookup ON users(tenant_id, username);

-- Partial index for a specific tenant (useful for large tenants)
CREATE INDEX idx_large_tenant_users ON users(username)
WHERE tenant_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
```

#### Table Partitioning

For very large multi-tenant databases, consider table partitioning:

```sql
-- Create a partitioned table by tenant_id
CREATE TABLE users (
    id SERIAL,
    tenant_id UUID NOT NULL,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    PRIMARY KEY (tenant_id, id)
) PARTITION BY LIST (tenant_id);

-- Create partitions for specific tenants
CREATE TABLE users_tenant1 PARTITION OF users
    FOR VALUES IN ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
    
CREATE TABLE users_tenant2 PARTITION OF users
    FOR VALUES IN ('b1ffc99-8d1b-4ef8-bb6d-6cc9bd380a22');
```

### Connection Pooling

Efficient connection management is critical for multi-tenant systems:

```
# pgBouncer configuration for multi-tenant setup
[databases]
* = host=127.0.0.1 port=5432

[pgbouncer]
listen_port = 6432
listen_addr = *
auth_type = md5
auth_file = userlist.txt
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 20
```

### Tenant Provisioning and Management

#### Creating a New Tenant (Schema Approach)

```sql
-- Function to provision a new tenant
CREATE OR REPLACE FUNCTION create_new_tenant(tenant_name TEXT, admin_email TEXT) 
RETURNS UUID AS $$
DECLARE
    new_tenant_id UUID;
    schema_name TEXT;
BEGIN
    -- Generate a new UUID for the tenant
    new_tenant_id := gen_random_uuid();
    
    -- Create schema name from tenant name
    schema_name := 'tenant_' || regexp_replace(lower(tenant_name), '[^a-z0-9]', '_', 'g');
    
    -- Create the schema
    EXECUTE format('CREATE SCHEMA %I', schema_name);
    
    -- Create tables in the new schema by cloning structure from template
    EXECUTE format('
        CREATE TABLE %I.users (
            id SERIAL PRIMARY KEY,
            email VARCHAR(255) UNIQUE NOT NULL,
            name VARCHAR(100) NOT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )', schema_name);
    
    -- Insert admin user
    EXECUTE format('
        INSERT INTO %I.users (email, name) VALUES ($1, $2)', 
        schema_name, admin_email, 'Administrator');
    
    -- Store tenant metadata in central registry
    INSERT INTO tenant_registry (id, name, schema, admin_email, created_at)
    VALUES (new_tenant_id, tenant_name, schema_name, admin_email, CURRENT_TIMESTAMP);
    
    RETURN new_tenant_id;
END;
$$ LANGUAGE plpgsql;
```

### Data Isolation Testing

Regularly validate tenant isolation to prevent data leakage:

```sql
-- Function to test isolation between tenants
CREATE OR REPLACE FUNCTION test_tenant_isolation() RETURNS TABLE (
    test_name TEXT,
    tenant_id UUID,
    status TEXT
) AS $$
DECLARE
    tenant RECORD;
    other_tenant RECORD;
    row_count INT;
BEGIN
    -- Test for each tenant
    FOR tenant IN SELECT id, schema FROM tenant_registry LOOP
        -- Try accessing data from other tenants
        FOR other_tenant IN SELECT id, schema FROM tenant_registry 
                            WHERE id != tenant.id LOOP
            
            -- Set current tenant context
            EXECUTE format('SET app.current_tenant_id = %L', tenant.id);
            
            -- Try to access other tenant's data
            BEGIN
                EXECUTE format('SELECT COUNT(*) FROM %I.users', other_tenant.schema) 
                INTO row_count;
                
                -- If we got here, isolation failed
                test_name := 'Cross-tenant access test';
                tenant_id := tenant.id;
                status := 'FAILED - Could access ' || other_tenant.schema;
                RETURN NEXT;
                
            EXCEPTION WHEN insufficient_privilege OR undefined_table THEN
                -- This is expected - isolation worked
                test_name := 'Cross-tenant access test';
                tenant_id := tenant.id;
                status := 'PASSED';
                RETURN NEXT;
            END;
        END LOOP;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;
```

### Monitoring and Administration

#### Per-Tenant Usage Statistics

```sql
-- View for monitoring per-tenant database usage
CREATE OR REPLACE VIEW tenant_usage_stats AS
SELECT
    t.name AS tenant_name,
    t.id AS tenant_id,
    pg_size_pretty(pg_table_size(format('%I.users', t.schema)::regclass)) AS users_table_size,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE application_name LIKE 'app:%' || t.id) AS active_connections,
    (SELECT COUNT(*) FROM ONLY pg_catalog.pg_locks l 
     JOIN pg_catalog.pg_database d ON l.database = d.oid
     WHERE d.datname = current_database() 
     AND application_name LIKE 'app:%' || t.id) AS locks_count
FROM
    tenant_registry t;
```

### Backup and Restore Strategies

#### Per-Tenant Backup (Schema Approach)

```bash
# Backing up a specific tenant's schema
pg_dump -h localhost -U postgres -d multi_tenant_db -n tenant_acme_corp > tenant_acme_backup.sql

# Restoring a tenant schema
psql -h localhost -U postgres -d multi_tenant_db -f tenant_acme_backup.sql
```

#### Logical Replication for Tenant Migration

```sql
-- Set up publication for a specific tenant
CREATE PUBLICATION tenant_acme_pub FOR TABLE 
    tenant_acme_corp.users, 
    tenant_acme_corp.products, 
    tenant_acme_corp.orders;

-- On the target database, create subscription
CREATE SUBSCRIPTION tenant_acme_sub 
CONNECTION 'host=source-db port=5432 dbname=multi_tenant_db user=repl password=secret' 
PUBLICATION tenant_acme_pub;
```

### Security Best Practices

#### Data Encryption

```sql
-- Enable transparent data encryption for sensitive columns
CREATE EXTENSION pgcrypto;

-- Create table with encrypted data
CREATE TABLE tenant_acme_corp.customer_data (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    credit_card_number TEXT NOT NULL,
    encrypted_data BYTEA NOT NULL
);

-- Insert with encryption
INSERT INTO tenant_acme_corp.customer_data (customer_id, credit_card_number, encrypted_data)
VALUES (
    1001, 
    '4111-xxxx-xxxx-1234', 
    pgp_sym_encrypt('Sensitive customer data', 'encryption_key_for_tenant')
);
```

#### Tenant Access Auditing

```sql
-- Create audit log table
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    tenant_id UUID NOT NULL,
    action TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id TEXT NOT NULL,
    user_id INT NOT NULL,
    ip_address INET,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create an audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (tenant_id, action, table_name, record_id, user_id, ip_address)
    VALUES (
        current_setting('app.current_tenant_id')::UUID,
        TG_OP,
        TG_TABLE_NAME,
        NEW.id::TEXT,
        current_setting('app.current_user_id')::INT,
        inet(current_setting('app.client_ip'))
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger
CREATE TRIGGER users_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
```

### Handling Tenant-Specific Customizations

#### JSON/JSONB for Flexible Schemas

```sql
-- Table with tenant-specific custom fields
CREATE TABLE tenant_acme_corp.customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    custom_fields JSONB
);

-- Insert with custom fields
INSERT INTO tenant_acme_corp.customers (name, email, custom_fields)
VALUES (
    'ACME Corporation', 
    'contact@acme.com',
    '{"industry": "Manufacturing", "annual_revenue": 10000000, "preferred_contact_method": "email"}'
);

-- Query using custom fields
SELECT * FROM tenant_acme_corp.customers
WHERE custom_fields->>'industry' = 'Manufacturing';

-- Create index for frequently queried custom fields
CREATE INDEX idx_customers_industry ON tenant_acme_corp.customers ((custom_fields->>'industry'));
```

#### Dynamic Column Configuration

```sql
-- Table to store tenant-specific column configurations
CREATE TABLE column_configs (
    tenant_id UUID NOT NULL,
    table_name TEXT NOT NULL,
    column_name TEXT NOT NULL,
    is_visible BOOLEAN DEFAULT TRUE,
    display_name TEXT,
    validation_rules JSONB,
    PRIMARY KEY (tenant_id, table_name, column_name)
);

-- Sample configuration
INSERT INTO column_configs 
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
    'customers', 
    'tax_id',
    TRUE,
    'Tax Identification Number',
    '{"required": true, "pattern": "^\\d{2}-\\d{7}$"}'
);
```

### Cross-Tenant Access (when needed)

#### Administrative View Access

```sql
-- Function to temporarily grant cross-tenant access
CREATE OR REPLACE FUNCTION admin_view_tenant_data(admin_user_id INT, target_tenant_id UUID) 
RETURNS VOID AS $$
BEGIN
    -- Check if user has admin privileges
    IF NOT EXISTS (SELECT 1 FROM admin_users WHERE id = admin_user_id AND is_super_admin = TRUE) THEN
        RAISE EXCEPTION 'User does not have super admin privileges';
    END IF;
    
    -- Log the cross-tenant access
    INSERT INTO admin_access_log (admin_id, target_tenant_id, access_time)
    VALUES (admin_user_id, target_tenant_id, CURRENT_TIMESTAMP);
    
    -- Grant temporary session access
    SET app.current_tenant_id = target_tenant_id::TEXT;
    SET app.is_admin_access = 'true';
    SET app.original_tenant_id = current_setting('app.current_tenant_id');
    
    -- Set session timeout for security
    SET statement_timeout = '30min';
END;
$$ LANGUAGE plpgsql;
```

### Scaling Considerations

#### Horizontal Partitioning by Tenant Groups

For extremely large multi-tenant systems with thousands of tenants:

```sql
-- Create tenant group mapping
CREATE TABLE tenant_groups (
    tenant_id UUID PRIMARY KEY,
    group_id INT NOT NULL,
    CONSTRAINT fk_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_registry(id)
);

-- Distribute tenants across database shards
INSERT INTO tenant_groups (tenant_id, group_id)
SELECT id, (ROW_NUMBER() OVER (ORDER BY created_at)) % 10
FROM tenant_registry;
```

**Key Points:**

- Group tenants by size, geography, or activity patterns
- Distribute tenant groups across database shards
- Consider PostgreSQL's Foreign Data Wrapper for cross-shard queries
- Implement shard routing in the application layer

### Testing Your Multi-Tenant Setup

```sql
-- Create a function to verify tenant isolation
CREATE OR REPLACE FUNCTION verify_tenant_isolation() RETURNS TABLE (
    test_name TEXT,
    result TEXT
) AS $$
DECLARE
    tenant1_id UUID;
    tenant2_id UUID;
    rec RECORD;
BEGIN
    -- Get two different tenant IDs for testing
    SELECT id INTO tenant1_id FROM tenant_registry LIMIT 1;
    SELECT id INTO tenant2_id FROM tenant_registry WHERE id != tenant1_id LIMIT 1;
    
    -- Test 1: Direct schema access
    test_name := 'Direct schema access isolation';
    BEGIN
        SET app.current_tenant_id = tenant1_id::TEXT;
        EXECUTE format('SELECT * FROM tenant_%s.users LIMIT 1', 
            (SELECT schema FROM tenant_registry WHERE id = tenant2_id));
        result := 'FAILED - Could access other tenant schema';
    EXCEPTION WHEN insufficient_privilege THEN
        result := 'PASSED';
    END;
    RETURN NEXT;
    
    -- Test 2: Row-level security
    test_name := 'Row-level security isolation';
    BEGIN
        SET app.current_tenant_id = tenant1_id::TEXT;
        EXECUTE 'SELECT COUNT(*) FROM users WHERE tenant_id = $1' 
        USING tenant2_id INTO rec;
        
        IF rec.count = 0 THEN
            result := 'PASSED';
        ELSE
            result := 'FAILED - Could access other tenant data';
        END IF;
    END;
    RETURN NEXT;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;
```

### Recommended Related Topics

- PostgreSQL Table Partitioning for Large Multi-Tenant Systems
- Implementing Tenant-Specific Caching Strategies
- Data Migration Between Multi-Tenant Models
- High Availability Configuration for Multi-Tenant PostgreSQL
- Tenant-Aware Query Optimization Techniques

---

