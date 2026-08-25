## Creating and Managing Databases


### Introduction to PostgreSQL Database Management

PostgreSQL provides powerful tools for database creation, configuration, and management. Understanding these fundamental operations is essential for database administrators and developers who need to establish and maintain PostgreSQL environments.

### Creating Databases

#### Using CREATE DATABASE Command

The basic syntax for creating a database is:

```sql
CREATE DATABASE database_name
    [ WITH ] [ OWNER [=] user_name ]
           [ TEMPLATE [=] template ]
           [ ENCODING [=] encoding ]
           [ LOCALE [=] locale ]
           [ LC_COLLATE [=] lc_collate ]
           [ LC_CTYPE [=] lc_ctype ]
           [ TABLESPACE [=] tablespace_name ]
           [ ALLOW_CONNECTIONS [=] allowconn ]
           [ CONNECTION LIMIT [=] connlimit ]
           [ IS_TEMPLATE [=] istemplate ];
```

A simple example:

```sql
CREATE DATABASE my_application_db
    WITH 
    OWNER = app_user
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = 100;
```

#### Using createdb Utility

PostgreSQL provides a command-line utility for database creation:

```bash
createdb [connection-option...] [option...] [dbname [description]]
```

Example:

```bash
createdb -h localhost -p 5432 -U postgres -e -O app_user my_application_db
```

#### Using pgAdmin

In pgAdmin:

1. Right-click on "Databases" in the object browser
2. Select "Create" > "Database..."
3. Fill in the required fields in the dialog
4. Click "Save"

### Configuring Database Parameters

#### Default Settings

New databases inherit settings from the template database (usually `template1`):

```sql
SELECT name, setting FROM pg_settings WHERE name LIKE 'default_%';
```

#### Connection Parameters

Control database access:

```sql
ALTER DATABASE my_application_db CONNECTION LIMIT 50;
```

#### Locale and Encoding Settings

Set language and character encoding:

```sql
CREATE DATABASE international_db
    WITH ENCODING 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8';
```

### Managing Database Objects

#### Schemas

Organize database objects:

```sql
CREATE SCHEMA marketing;
CREATE SCHEMA accounting;

-- Creating objects in specific schemas
CREATE TABLE marketing.campaigns (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    start_date DATE
);
```

#### Roles and Permissions

Grant database access:

```sql
-- Create role
CREATE ROLE reporting_user LOGIN PASSWORD 'secure_password';

-- Grant permissions
GRANT CONNECT ON DATABASE analytics_db TO reporting_user;
GRANT USAGE ON SCHEMA public TO reporting_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reporting_user;
```

#### Default Privileges

Set permissions for future objects:

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO reporting_user;
```

### Database Maintenance

#### Vacuum

Regular maintenance to reclaim storage:

```sql
-- Basic vacuum
VACUUM my_application_db;

-- Full vacuum with analysis
VACUUM FULL ANALYZE my_application_db;

-- Automatic vacuum settings
ALTER DATABASE my_application_db SET autovacuum_vacuum_threshold = 100;
ALTER DATABASE my_application_db SET autovacuum_vacuum_scale_factor = 0.1;
```

#### Reindex

Rebuild indexes to improve performance:

```sql
REINDEX DATABASE my_application_db;
```

### Database Backup and Restore

#### pg_dump for Backup

Create logical backups:

```bash
# Full database backup
pg_dump -h localhost -U postgres -F c -b -v -f my_application_db.backup my_application_db

# Schema-only backup
pg_dump -h localhost -U postgres -s -f schema.sql my_application_db

# Data-only backup
pg_dump -h localhost -U postgres -a -f data.sql my_application_db
```

##### Dumping Data-Only vs. Schema-Only in PostgreSQL

- **Data-Only Dump**: Exports only the data (rows) from tables, excluding schema definitions (e.g., table structures, constraints, triggers). Useful for backing up or migrating data.
  - Command: `pg_dump --data-only -U postgres -d mydb > data.sql`
  - Example Output: `INSERT INTO employees (id, name) VALUES (1, 'Alice');`

- **Schema-Only Dump**: Exports only the schema (table definitions, constraints, triggers, functions, etc.), excluding data. Ideal for replicating database structure.
  - Command: `pg_dump --schema-only -U postgres -d mydb > schema.sql`
  - Example Output: `CREATE TABLE employees (id INTEGER PRIMARY KEY, name TEXT);`

**Key Points**:
- **OLTP**: Data-only for backups; schema-only for schema migrations.
- **OLAP**: Data-only for exporting query results; schema-only for setting up reporting databases.
- **Combine with `\d+`**: Check schema details before dumping.
- **Use Case**: Data-only for data migration; schema-only for development or testing environments.
- **Tool**: Use `pg_dump` (supports IPv6, e.g., `-h ::1`); ensure `LC_COLLATE`/`LC_CTYPE` match for consistent sorting.

**Example**:
```bash
# Data-only dump
pg_dump --data-only -h ::1 -U postgres -d postgres > employees_data.sql
# Schema-only dump (includes your trigger)
pg_dump --schema-only -h ::1 -U postgres -d postgres > employees_schema.sql
```

#### pg_restore for Restore

Restore from backup files:

```bash
# Restore to a new database
pg_restore -h localhost -U postgres -d new_application_db -v my_application_db.backup

# Restore with parallelism (faster)
pg_restore -h localhost -U postgres -d new_application_db -v -j 4 my_application_db.backup
```

### Copying and Cloning Databases

#### Template Databases

Use template databases for creating standardized databases:

```sql
-- Make a database a template
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'my_template_db';

-- Create from template
CREATE DATABASE new_app_db TEMPLATE my_template_db;
```

#### Database Cloning

Clone an entire database:

```bash
# Using pg_dump and pg_restore
pg_dump -h localhost -U postgres -Fc my_application_db > db_dump.custom
pg_restore -h localhost -U postgres -d my_application_db_clone db_dump.custom
```

### Database Statistics and Monitoring

#### System Catalogs

Query database metadata:

```sql
-- Database size
SELECT pg_size_pretty(pg_database_size('my_application_db'));

-- Table sizes
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

#### pg_stat Views

Monitor database activity:

```sql
-- Database statistics
SELECT * FROM pg_stat_database WHERE datname = 'my_application_db';

-- Connection information
SELECT * FROM pg_stat_activity WHERE datname = 'my_application_db';
```

### Database Migration and Upgrade

#### Major Version Upgrades

Upgrade to a new PostgreSQL version:

```bash
# Using pg_upgrade
pg_upgrade -b /usr/lib/postgresql/13/bin -B /usr/lib/postgresql/14/bin \
           -d /var/lib/postgresql/13/main -D /var/lib/postgresql/14/main \
           -o "-c config_file=/etc/postgresql/13/main/postgresql.conf" \
           -O "-c config_file=/etc/postgresql/14/main/postgresql.conf" \
           -j 4 -v
```

#### Testing Migrations

Verify compatibility before migration:

```bash
# Test database dump and restore
pg_dump -h old_server -U postgres my_application_db | psql -h new_server -U postgres my_application_db_test
```

### Advanced Database Configuration

#### Tablespaces

Manage physical storage locations:

```sql
-- Create tablespace
CREATE TABLESPACE fast_storage LOCATION '/ssd/postgresql/data';

-- Move database to tablespace
ALTER DATABASE my_application_db SET TABLESPACE fast_storage;
```

#### Parameter Management

Configure database settings:

```sql
-- Set parameters at database level
ALTER DATABASE my_application_db SET work_mem = '16MB';
ALTER DATABASE my_application_db SET maintenance_work_mem = '256MB';
```

### Real-world Example: E-Commerce Database Setup

```sql
-- Create database with appropriate settings
CREATE DATABASE ecommerce
    WITH 
    OWNER = ecomm_admin
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = 200;

-- Connect to the database
\c ecommerce

-- Create schemas for organization
CREATE SCHEMA products;
CREATE SCHEMA customers;
CREATE SCHEMA orders;
CREATE SCHEMA analytics;

-- Create application roles
CREATE ROLE app_reader WITH LOGIN PASSWORD 'secure_read_pwd';
CREATE ROLE app_writer WITH LOGIN PASSWORD 'secure_write_pwd';
CREATE ROLE analytics_user WITH LOGIN PASSWORD 'secure_analytics_pwd';

-- Set up permissions
GRANT CONNECT ON DATABASE ecommerce TO app_reader, app_writer, analytics_user;
GRANT USAGE ON SCHEMA products, customers, orders TO app_reader, app_writer;
GRANT USAGE ON SCHEMA analytics TO analytics_user;

-- Default privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA products, customers, orders 
    GRANT SELECT ON TABLES TO app_reader;
    
ALTER DEFAULT PRIVILEGES IN SCHEMA products, customers, orders 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_writer;

ALTER DEFAULT PRIVILEGES IN SCHEMA analytics 
    GRANT SELECT ON TABLES TO analytics_user;

-- Configure performance settings
ALTER DATABASE ecommerce SET work_mem = '8MB';
ALTER DATABASE ecommerce SET maintenance_work_mem = '128MB';
ALTER DATABASE ecommerce SET random_page_cost = 1.1;  -- For SSD storage
```

**Conclusion**

Creating and managing PostgreSQL databases involves multiple aspects from initial creation to ongoing maintenance and monitoring. Proper database design, configuration, and management practices ensure optimal performance, security, and reliability. By mastering these fundamental operations, database administrators can establish robust PostgreSQL environments that meet application requirements while maintaining operational efficiency.

---

