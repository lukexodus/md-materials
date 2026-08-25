## PostgreSQL CLI Tools: psql (PostgreSQL Shell)


### Introduction to psql

psql is the official interactive terminal-based front-end to PostgreSQL. It provides a command-line interface for typing SQL queries directly to a PostgreSQL server and viewing the query results. Beyond executing SQL, psql offers numerous meta-commands and features that make it a powerful tool for both administrative tasks and everyday database interaction.

### Installation and Connection

Installing psql typically comes bundled with PostgreSQL, but it can also be installed as a standalone client. The basic syntax to connect to a database is:

```bash
psql -h hostname -p port -U username -d dbname
```

Connection parameters can also be set with environment variables:

```bash
export PGHOST=hostname
export PGPORT=5432
export PGUSER=username
export PGPASSWORD=password  # Not recommended for security reasons
export PGDATABASE=dbname
```

Then simply run:

```bash
psql
```

### Basic Navigation and Information Commands

psql provides several meta-commands (commands that begin with a backslash):

```
\l          List all databases
\c dbname   Connect to a specific database
\dt         List tables in current database
\d tablename  Describe a table structure
\du         List all users and their roles
\dn         List all schemas
\df         List all functions
\dv         List all views
\dx         List all installed extensions
\timing     Toggle query execution time display
\q          Quit psql
```

### Query Buffer Operations

psql maintains a query buffer for composing multi-line queries:

```
\e          Edit the current query buffer with an external editor
\r          Reset (clear) the query buffer
\p          Show the contents of the query buffer
\g          Execute the query in the buffer (same as semicolon)
\s          Display command history
\w filename Save query buffer to file
```

### Output Formatting

Control how query results are displayed:

```
\x          Toggle expanded display mode
\a          Toggle between aligned and unaligned output
\H          Toggle HTML output format
\t          Toggle display of column names and row count footer
\o filename Send query results to a file
\copy       Perform a copy operation
```

### Advanced Features

#### Script Execution

Run SQL scripts directly from psql:

```bash
psql -f script.sql dbname
```

Or from within psql:

```
\i script.sql
```

#### Variables

Set and use variables:

```
\set name value    Set a variable
\unset name        Unset a variable
:name              Reference a variable
```

Use case:

```
\set threshold 100
SELECT * FROM transactions WHERE amount > :threshold;
```

#### Conditional Execution

```
\if expression
  # commands executed if expression is true
\elif expression
  # commands executed if previous \if or \elif is false but this expression is true
\else
  # commands executed if all previous conditions were false
\endif
```

### Performance Analysis

psql can help analyze query performance:

```
\timing on            Turn on timing of commands
EXPLAIN               Show query plan without executing
EXPLAIN ANALYZE       Show and execute query plan with actual timing
```

### Security and Role Management

```
\password [username]  Change password for a user
\conninfo            Display connection information
```

### Configuration

psql configuration can be set in `.psqlrc` file in your home directory:

```
\set QUIET on
\pset null '(null)'    Modifies output formatting options
\set COMP_KEYWORD_CASE upper
\timing on
\set HISTSIZE 2000
\set PROMPT1 '%n@%m:%>%x %/ %# '
```

### Useful Tips and Tricks

#### Custom Aliases

Create custom commands in `.psqlrc`:

```
\set activity 'SELECT pid, usename, application_name, client_addr, state, query FROM pg_stat_activity;'
```

Then use it:

```
:activity
```

#### Interactive Query Creation

For larger queries, use external editor integration:

```
\e
```

This will open your default editor (set by EDITOR environment variable).

### Common Troubleshooting

#### Connection Issues

If encountering connection problems:

```
psql "host=hostname port=5432 dbname=mydb user=username password=password sslmode=require"
```

Explicitly specifying all parameters can help identify connection issues.

#### Performance Issues

For slow queries:

```
\timing on
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM large_table WHERE condition;
```

### Real-world Examples

**Example: Examining a table structure**

```
\d+ users          Display detailed info about db objects
```

**Output:**

```
                                        Table "public.users"
   Column   |          Type          | Collation | Nullable |      Default      | Storage  | Stats target | Description
------------+------------------------+-----------+----------+-------------------+----------+--------------+-------------
 id         | integer                |           | not null | nextval('users_id_seq'::regclass) | plain    |              | 
 username   | character varying(50)  |           | not null |                   | extended |              | 
 email      | character varying(100) |           | not null |                   | extended |              | 
 created_at | timestamp with time zone |           | not null | now()            | plain    |              | 
Indexes:
    "users_pkey" PRIMARY KEY, btree (id)
    "users_email_key" UNIQUE CONSTRAINT, btree (email)
    "users_username_idx" btree (username)
```

**Example: Monitoring Database Activity**

```
SELECT pid, usename, datname, state, query
FROM pg_stat_activity
WHERE state <> 'idle';
```

**Example: Export Query Results to CSV**

```
\copy (SELECT * FROM users WHERE created_at > '2023-01-01') TO '~/users_export.csv' WITH CSV HEADER;
```

### Integration with Other Tools

psql can be effectively combined with other command-line tools:

```bash
# Use with grep to filter results
psql -c "SELECT * FROM pg_tables;" | grep public

# Use with awk for data processing
psql -c "SELECT count(*) FROM users;" -t | awk '{print "User count: " $1}'

# In bash scripts
USER_COUNT=$(psql -c "SELECT count(*) FROM users;" -t -A)
```

### Comparison with Other PostgreSQL Clients

While psql is the official CLI client, alternatives include:

- pgAdmin: GUI-based administration tool
- DBeaver: Universal database manager with PostgreSQL support
- pgcli: Command-line interface with auto-completion and syntax highlighting

psql remains preferred for server administration, automation, and scripting due to its lightweight nature and comprehensive feature set.

### Version-specific Features

PostgreSQL 14+ introduced new psql features:

- Enhanced tab completion
- Improved error reporting
- Better EXPLAIN visualization
- Additional meta-commands

**Conclusion**

psql is an indispensable tool for PostgreSQL database administrators and developers. Its combination of direct SQL execution, meta-commands for database exploration, and scripting capabilities make it suitable for everything from quick ad-hoc queries to complex administrative tasks. Mastering psql is a valuable skill for anyone working extensively with PostgreSQL databases.

---

