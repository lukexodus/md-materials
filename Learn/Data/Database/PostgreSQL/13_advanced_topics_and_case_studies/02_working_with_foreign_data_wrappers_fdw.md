## Working with Foreign Data Wrappers (FDW)


### Introduction to Foreign Data Wrappers

Foreign Data Wrappers (FDW) are a powerful feature in PostgreSQL that allows you to access and manipulate data stored in external data sources as if they were regular PostgreSQL tables. This capability, implemented according to the SQL/MED (Management of External Data) standard, enables PostgreSQL to function as a central data hub for heterogeneous data sources.

**Key Points:**

- FDWs allow seamless access to external data sources
- Based on SQL/MED standard (SQL-2003)
- External data appears as regular tables inside PostgreSQL
- Enables cross-database queries and operations

### Architecture of Foreign Data Wrappers

Foreign Data Wrappers follow a specific hierarchical structure within PostgreSQL:

### Foreign Data Wrapper

The core component that implements the communication protocol with the external data source. It contains all the code necessary to connect to and retrieve data from the external source.

### Foreign Server

Represents a specific instance of an external data source accessible through a Foreign Data Wrapper. A single FDW can have multiple server instances.

### User Mapping

Stores the credentials required to access the external data source. It maps PostgreSQL users to authentication information for the foreign server.

### Foreign Table

A virtual table within PostgreSQL that represents a table or view in the external data source. Queries against these tables are translated and forwarded to the external source.

### Popular Foreign Data Wrappers

### postgres_fdw

The built-in FDW for connecting to other PostgreSQL databases.

```sql
-- Install the extension
CREATE EXTENSION postgres_fdw;

-- Create the foreign server
CREATE SERVER foreign_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'remote_host', port '5432', dbname 'remote_db');

-- Create user mapping
CREATE USER MAPPING FOR local_user
SERVER foreign_server
OPTIONS (user 'remote_user', password 'remote_password');

-- Create foreign table
CREATE FOREIGN TABLE foreign_table (
    id integer,
    name text
)
SERVER foreign_server
OPTIONS (schema_name 'public', table_name 'remote_table');
```

### mysql_fdw

Connects to MySQL databases.

```sql
-- Install the extension
CREATE EXTENSION mysql_fdw;

-- Create the foreign server
CREATE SERVER mysql_server
FOREIGN DATA WRAPPER mysql_fdw
OPTIONS (host 'mysql_host', port '3306');

-- Create user mapping
CREATE USER MAPPING FOR postgres
SERVER mysql_server
OPTIONS (username 'mysql_user', password 'mysql_password');

-- Create foreign table
CREATE FOREIGN TABLE mysql_table (
    id integer,
    name text
)
SERVER mysql_server
OPTIONS (dbname 'mysql_db', table_name 'mysql_table');
```

### oracle_fdw

Connects to Oracle databases.

```sql
-- Install the extension
CREATE EXTENSION oracle_fdw;

-- Create the foreign server
CREATE SERVER oracle_server
FOREIGN DATA WRAPPER oracle_fdw
OPTIONS (dbserver '//oracle_host:1521/ORACLE_SID');

-- Create user mapping
CREATE USER MAPPING FOR postgres
SERVER oracle_server
OPTIONS (user 'oracle_user', password 'oracle_password');

-- Create foreign table
CREATE FOREIGN TABLE oracle_table (
    id integer,
    name text
)
SERVER oracle_server
OPTIONS (schema 'ORACLE_SCHEMA', table 'ORACLE_TABLE');
```

### file_fdw

Access data in flat files like CSV.

```sql
-- Install the extension
CREATE EXTENSION file_fdw;

-- Create the foreign server
CREATE SERVER file_server
FOREIGN DATA WRAPPER file_fdw;

-- Create foreign table
CREATE FOREIGN TABLE csv_table (
    id integer,
    name text,
    email text
)
SERVER file_server
OPTIONS (
    filename '/path/to/file.csv',
    format 'csv',
    header 'true',
    delimiter ','
);
```

### mongodb_fdw

Connect to MongoDB collections.

```sql
-- Install the extension
CREATE EXTENSION mongodb_fdw;

-- Create the foreign server
CREATE SERVER mongo_server
FOREIGN DATA WRAPPER mongodb_fdw
OPTIONS (address 'mongodb://mongo_host:27017');

-- Create user mapping
CREATE USER MAPPING FOR postgres
SERVER mongo_server
OPTIONS (username 'mongo_user', password 'mongo_password');

-- Create foreign table
CREATE FOREIGN TABLE mongo_collection (
    _id name,
    name text,
    age integer
)
SERVER mongo_server
OPTIONS (database 'mongo_db', collection 'mongo_collection');
```

### Advanced FDW Features

### Query Pushdown

Many FDWs support query pushdown, allowing filtering and other operations to be executed on the remote server rather than fetching all data and processing it locally.

```sql
-- This WHERE clause may be pushed down to the remote server
SELECT * FROM foreign_table WHERE id > 1000;
```

### Write Operations

Some FDWs support write operations (INSERT, UPDATE, DELETE) on foreign tables.

```sql
-- Inserting into a foreign table
INSERT INTO foreign_table (id, name) VALUES (1, 'Test');

-- Updating a foreign table
UPDATE foreign_table SET name = 'Updated' WHERE id = 1;

-- Deleting from a foreign table
DELETE FROM foreign_table WHERE id = 1;
```

### IMPORT FOREIGN SCHEMA

PostgreSQL 9.5+ allows importing table definitions from foreign data sources automatically.

```sql
-- Import all tables from a schema
IMPORT FOREIGN SCHEMA remote_schema
FROM SERVER foreign_server
INTO local_schema;

-- Import specific tables
IMPORT FOREIGN SCHEMA remote_schema LIMIT TO (table1, table2)
FROM SERVER foreign_server
INTO local_schema;

-- Exclude specific tables
IMPORT FOREIGN SCHEMA remote_schema EXCEPT (table3, table4)
FROM SERVER foreign_server
INTO local_schema;
```

### Performance Considerations

### Fetch Size

Controls how many rows are retrieved in each batch from the foreign server.

```sql
-- Set fetch size at the foreign table level
ALTER FOREIGN TABLE foreign_table
OPTIONS (ADD fetch_size '1000');

-- Or at the server level
ALTER SERVER foreign_server
OPTIONS (ADD fetch_size '1000');
```

### Caching

Some FDWs support caching of foreign data locally to improve performance.

```sql
-- Enable caching for a specific table
ALTER FOREIGN TABLE foreign_table
OPTIONS (ADD use_remote_estimate 'true', ADD cache_mode 'enabled');
```

### Statistics

Collecting statistics on foreign tables helps the query planner make better decisions.

```sql
-- Analyze a foreign table
ANALYZE foreign_table;
```

### Security Considerations

### Column-Level Permissions

You can restrict which columns users can access in foreign tables.

```sql
-- Grant access to specific columns only
GRANT SELECT (id, name) ON foreign_table TO user1;
```

### Row-Level Security

For FDWs that support it, row-level security policies can be defined.

```sql
-- Enable row-level security
ALTER TABLE foreign_table ENABLE ROW LEVEL SECURITY;

-- Create a policy
CREATE POLICY foreign_table_policy ON foreign_table
    USING (department = current_setting('app.current_department'));
```

### Encrypted Connections

Always use secure connections for FDWs connecting over networks.

```sql
-- Use SSL for postgres_fdw
CREATE SERVER secure_postgres_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'remote_host', port '5432', dbname 'remote_db', sslmode 'require');
```

### Creating Custom Foreign Data Wrappers

For specialized needs, you can develop custom FDWs using the PostgreSQL C API or multicorn (Python-based).

### C API Example Skeleton

```c
#include "postgres.h"
#include "foreign/fdwapi.h"
#include "optimizer/pathnode.h"
#include "optimizer/planmain.h"
#include "optimizer/restrictinfo.h"
#include "utils/rel.h"

PG_MODULE_MAGIC;

/* Function declarations */
void _PG_init(void);
void _PG_fini(void);

/* FDW handler function */
extern Datum my_fdw_handler(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(my_fdw_handler);

/* Handler implementation */
Datum
my_fdw_handler(PG_FUNCTION_ARGS)
{
    FdwRoutine *routine = makeNode(FdwRoutine);
    
    /* Assign callback functions */
    routine->GetForeignRelSize = myGetForeignRelSize;
    routine->GetForeignPaths = myGetForeignPaths;
    routine->GetForeignPlan = myGetForeignPlan;
    routine->BeginForeignScan = myBeginForeignScan;
    routine->IterateForeignScan = myIterateForeignScan;
    routine->ReScanForeignScan = myReScanForeignScan;
    routine->EndForeignScan = myEndForeignScan;
    
    PG_RETURN_POINTER(routine);
}
```

### Python-based FDW with Multicorn

```python
from multicorn import ForeignDataWrapper
import requests

class WebServiceFDW(ForeignDataWrapper):
    def __init__(self, options, columns):
        super(WebServiceFDW, self).__init__(options, columns)
        self.url = options.get('url')
        self.api_key = options.get('api_key')
        self.columns = columns
        
    def execute(self, quals, columns):
        response = requests.get(
            self.url,
            headers={'Authorization': f'Bearer {self.api_key}'}
        )
        data = response.json()
        
        for item in data:
            row = {}
            for column_name in self.columns:
                if column_name in item:
                    row[column_name] = item[column_name]
            yield row
```

### Common Troubleshooting

### Connection Issues

```sql
-- Check if the extension is properly installed
SELECT * FROM pg_extension WHERE extname = 'postgres_fdw';

-- Verify server definition
SELECT * FROM pg_foreign_server WHERE srvname = 'foreign_server';

-- Check user mappings
SELECT * FROM pg_user_mappings WHERE srvname = 'foreign_server';
```

### Performance Issues

```sql
-- View query plans to identify bottlenecks
EXPLAIN ANALYZE SELECT * FROM foreign_table WHERE id < 1000;

-- Check if statistics are collected
SELECT * FROM pg_stats WHERE tablename = 'foreign_table';
```

### Permission Problems

```sql
-- Check granted privileges
SELECT grantee, privilege_type 
FROM information_schema.table_privileges 
WHERE table_name = 'foreign_table';

-- Review user mapping details
SELECT * FROM pg_user_mappings;
```

### Best Practices

**Key Points:**

- Use connection pooling when possible
- Push down queries to the foreign server when feasible
- Limit the columns and rows retrieved to only what's needed
- Collect statistics regularly with ANALYZE
- Consider indexes on frequently queried columns in the foreign data source
- Test performance with EXPLAIN ANALYZE
- Use encrypted connections for sensitive data
- Implement proper error handling in custom FDWs
- Document server configurations and user mappings

### Conclusion

Foreign Data Wrappers represent one of PostgreSQL's most powerful features for data integration, allowing you to build a federated database system that can seamlessly query and manipulate data across diverse data sources. With proper configuration and understanding of performance considerations, FDWs can transform PostgreSQL into a central hub for all your data needs, regardless of where that data physically resides.

### Related Topics

- PostgreSQL Partitioning vs. Foreign Tables
- Logical Replication as an Alternative to FDWs
- Event Triggers with Foreign Tables
- Data Virtualization Strategies
- PostgreSQL as a Data Federation Layer

---

