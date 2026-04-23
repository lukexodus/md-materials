# Comprehensive Guide to psql

`psql` is the official interactive terminal client for PostgreSQL. It lets you connect to a database, run SQL queries, execute scripts, inspect the schema, manage sessions, and automate workflows — all from the command line.

---

## Connecting to a Database

### Basic Syntax

```sh
psql [OPTIONS] [DBNAME [USERNAME]]
```

### Connection Options

|Flag|Long form|Meaning|
|---|---|---|
|`-h HOST`|`--host`|Server hostname or socket directory|
|`-p PORT`|`--port`|Port (default: 5432)|
|`-U USER`|`--username`|PostgreSQL role name|
|`-d DBNAME`|`--dbname`|Database to connect to|
|`-W`|`--password`|Force password prompt|
|`-w`|`--no-password`|Never prompt for password|

```sh
psql -h localhost -p 5432 -U alice -d mydb
```

### Connection String (URI)

```sh
psql "postgresql://alice:secret@localhost:5432/mydb"
psql "postgresql://alice@/mydb?host=/var/run/postgresql"
```

URI format: `postgresql://[user[:password]@][host][:port][/dbname][?param=val&...]`

### `PGPASSWORD` and `.pgpass`

```sh
PGPASSWORD=secret psql -U alice mydb
```

Or store credentials in `~/.pgpass` (chmod 600):

```
hostname:port:database:username:password
localhost:5432:mydb:alice:secret
*:*:*:alice:secret
```

### `PGSERVICE` and `pg_service.conf`

Define named connections in `~/.pg_service.conf`:

```ini
[myservice]
host=localhost
port=5432
dbname=mydb
user=alice
```

Then connect with:

```sh
psql service=myservice
```

### Environment Variables

|Variable|Meaning|
|---|---|
|`PGHOST`|Default host|
|`PGPORT`|Default port|
|`PGUSER`|Default user|
|`PGDATABASE`|Default database|
|`PGPASSWORD`|Password (avoid in scripts — use `.pgpass`)|
|`PGSSLMODE`|SSL mode (`disable`, `require`, `verify-ca`, `verify-full`)|
|`PGCONNECT_TIMEOUT`|Connection timeout in seconds|

---

## Non-interactive / Scripting Options

|Flag|Meaning|
|---|---|
|`-c COMMAND`|Run a single SQL command and exit|
|`-f FILE`|Execute SQL from a file and exit|
|`-o FILE`|Send output to a file|
|`-q` / `--quiet`|Suppress informational messages|
|`-t` / `--tuples-only`|Print only data rows, no headers/footers|
|`-A` / `--no-align`|Unaligned output (no column padding)|
|`-F SEP`|Field separator for unaligned output (default: `\|`)|
|`-R SEP`|Record separator for unaligned output (default: newline)|
|`-0`|Null-terminate rows (useful with `xargs -0`)|
|`--csv`|CSV output mode|
|`-v VAR=VAL`|Set a psql variable before starting|
|`-X`|Do not read `~/.psqlrc`|
|`--single-transaction`|Wrap `-f` script in a single transaction|

```sh
# Dump a query result to CSV
psql -U alice mydb -t -A -F',' -c "SELECT id, name FROM users" > users.csv

# Cleaner CSV
psql -U alice mydb --csv -c "SELECT id, name FROM users" > users.csv

# Run a script file
psql -U alice mydb -f schema.sql

# Run a script and stop on first error
psql -U alice mydb -v ON_ERROR_STOP=1 -f migration.sql
```

---

## The psql Prompt

By default, the prompt shows `dbname=#` for superusers or `dbname=>` for normal roles.

A multi-line (incomplete) query shows `dbname-#` or `dbname->`.

Terminate a command with `;` to execute it. Use `\g` as an alternative to `;`.

---

## Meta-commands (Backslash Commands)

Meta-commands are processed by `psql` itself — they are not sent to the server.

### General

|Command|Effect|
|---|---|
|`\q`|Quit psql|
|`\!`|Execute a shell command|
|`\! CMD`|Run CMD in the shell|
|`\cd DIR`|Change working directory|
|`\timing [on\|off]`|Toggle query execution time display|
|`\set VAR VAL`|Set a psql variable|
|`\unset VAR`|Unset a psql variable|
|`\echo TEXT`|Print text to stdout|
|`\warn TEXT`|Print text to stderr|
|`\i FILE`|Execute commands from a file|
|`\ir FILE`|Like `\i` but relative to current script's directory|
|`\o [FILE]`|Send output to file (or reset to stdout)|
|`\p`|Print current query buffer|
|`\r`|Reset (clear) query buffer|
|`\w FILE`|Write query buffer to file|
|`\e [FILE]`|Open buffer (or file) in `$EDITOR`|
|`\ef [FUNC]`|Edit a function definition|
|`\ev [VIEW]`|Edit a view definition|
|`\g [FILE]`|Execute query (like `;`), optionally to file|
|`\gx [FILE]`|Like `\g` but force expanded display|
|`\gset [PREFIX]`|Execute query, store results as psql variables|
|`\gexec`|Execute each cell of the result as SQL|
|`\watch [SEC]`|Re-run query every N seconds (default: 2)|
|`\s [FILE]`|Print or save command history|
|`\?`|Show meta-command help|
|`\h [CMD]`|Show SQL syntax help|

### Connection

|Command|Effect|
|---|---|
|`\c DBNAME [USER] [HOST] [PORT]`|Connect to a new database|
|`\c -`|Reconnect with current settings|
|`\conninfo`|Show current connection info|
|`\password [USER]`|Change a user's password securely|

### Output Format

|Command|Effect|
|---|---|
|`\x [on\|off\|auto]`|Toggle expanded (vertical) display|
|`\a`|Toggle between aligned and unaligned output|
|`\t [on\|off]`|Toggle tuples-only mode (hide headers/footers)|
|`\pset NAME [VALUE]`|Set a print option (see below)|
|`\f [SEP]`|Set field separator for unaligned mode|
|`\H`|Toggle HTML output mode|
|`\T STRING`|Set HTML `<table>` tag attributes|

#### `\pset` Options

|Option|Values / Effect|
|---|---|
|`format`|`unaligned`, `aligned`, `wrapped`, `html`, `asciidoc`, `latex`, `latex-longtable`, `troff-ms`, `csv`, `json`, `jsonlines`|
|`border`|`0`, `1`, `2`|
|`expanded`|`on`, `off`, `auto`|
|`null`|String to display for NULL values|
|`tuples_only`|`on`, `off`|
|`title STRING`|Set table title|
|`footer`|`on`, `off`|
|`fieldsep`|Field separator (unaligned)|
|`recordsep`|Record separator (unaligned)|
|`linestyle`|`ascii`, `old-ascii`, `unicode`|
|`unicode_border_linestyle`|`single`, `double`|
|`pager`|`on`, `off`, or pager command|
|`numericlocale`|`on`, `off`|

```sql
\pset null '(null)'
\pset format csv
\pset border 2
```

---

## Schema Inspection Commands (`\d`)

All `\d` commands accept an optional name pattern (supports `*` and `?` wildcards, or SQL `%` and `_`). Append `+` for more detail.

|Command|Shows|
|---|---|
|`\d`|All tables, views, sequences, foreign tables in search path|
|`\d NAME`|Columns, indexes, constraints, triggers for table/view/sequence|
|`\d+ NAME`|Like `\d` with storage, stats target, descriptions|
|`\dt [PATTERN]`|Tables|
|`\dv [PATTERN]`|Views|
|`\dm [PATTERN]`|Materialized views|
|`\di [PATTERN]`|Indexes|
|`\ds [PATTERN]`|Sequences|
|`\df [PATTERN]`|Functions|
|`\dfa [PATTERN]`|Aggregate functions|
|`\dfw [PATTERN]`|Window functions|
|`\dp [PATTERN]`|Privileges (access control)|
|`\da [PATTERN]`|Aggregate functions|
|`\dA [PATTERN]`|Access methods|
|`\db [PATTERN]`|Tablespaces|
|`\dc [PATTERN]`|Conversions|
|`\dC [PATTERN]`|Casts|
|`\dd [PATTERN]`|Object descriptions|
|`\dD [PATTERN]`|Domains|
|`\de [PATTERN]`|Foreign servers|
|`\dE [PATTERN]`|Foreign tables|
|`\dF [PATTERN]`|Text search configurations|
|`\dFd [PATTERN]`|Text search dictionaries|
|`\dFp [PATTERN]`|Text search parsers|
|`\dFt [PATTERN]`|Text search templates|
|`\dg [PATTERN]`|Roles/groups|
|`\du [PATTERN]`|Roles/users|
|`\dl`|Large objects|
|`\dn [PATTERN]`|Schemas|
|`\do [PATTERN]`|Operators|
|`\dO [PATTERN]`|Collations|
|`\dp [PATTERN]`|Table/column/sequence privileges|
|`\dP [PATTERN]`|Partitioned tables and indexes|
|`\drds`|Role-specific settings|
|`\dRp [PATTERN]`|Replication publications|
|`\dRs [PATTERN]`|Replication subscriptions|
|`\dT [PATTERN]`|Data types|
|`\dU [PATTERN]`|Unlogged tables|
|`\dx [PATTERN]`|Installed extensions|
|`\dX [PATTERN]`|Extended statistics|
|`\dy [PATTERN]`|Event triggers|
|`\l [PATTERN]`|List databases|
|`\l+`|List databases with sizes|
|`\z [PATTERN]`|Alias for `\dp` (privileges)|

```sql
\dt public.*
\d+ orders
\df pg_catalog.array*
```

---

## psql Variables

### Setting and Using Variables

```sql
\set myvar 'hello'
SELECT :'myvar';        -- as a string literal: 'hello'
SELECT :myvar;          -- as an identifier or unquoted value
SELECT :"myvar";        -- as a quoted identifier: "hello"
```

### Built-in Variables

|Variable|Effect|
|---|---|
|`ON_ERROR_STOP`|If `1`, stop on any error (critical for scripts)|
|`ON_ERROR_ROLLBACK`|`on` / `interactive` — roll back failed statements in a transaction|
|`AUTOCOMMIT`|`on` (default) / `off`|
|`VERBOSITY`|Error verbosity: `default`, `verbose`, `terse`, `sqlstate`|
|`SHOW_CONTEXT`|`never`, `errors`, `always`|
|`PROMPT1`|Primary prompt string|
|`PROMPT2`|Continuation prompt string|
|`PROMPT3`|Prompt for `COPY` data input|
|`HISTSIZE`|Number of history entries to keep|
|`HISTFILE`|Path to history file|
|`HISTCONTROL`|`ignorespace`, `ignoredups`, `ignoreboth`|
|`ECHO`|`queries`, `errors`, `all`, `none`|
|`ECHO_HIDDEN`|Show internal queries from meta-commands|
|`FETCH_COUNT`|Rows to fetch per cursor iteration (default: 0 = all)|
|`COMP_KEYWORD_CASE`|`upper`, `lower`, `preserve-upper`, `preserve-lower`|
|`DBNAME`|Current database name (read-only)|
|`USER`|Current user (read-only)|
|`HOST`|Current host (read-only)|
|`PORT`|Current port (read-only)|
|`SERVER_VERSION_NUM`|Server version as integer (read-only)|
|`LAST_ERROR_MESSAGE`|Last error message (read-only)|
|`LAST_ERROR_SQLSTATE`|Last SQL state code (read-only)|
|`ROW_COUNT`|Rows affected by last query (read-only)|
|`ERROR`|`true` if last query had an error (read-only)|

### Prompt Customisation

Prompt strings support substitution sequences:

|Sequence|Expands to|
|---|---|
|`%M`|Full hostname (or `[local]`)|
|`%m`|Hostname up to first dot|
|`%>`|Port number|
|`%n`|Database user|
|`%/`|Current database|
|`%~`|Database, shown as `~` if same as user|
|`%#`|`#` for superuser, `>` otherwise|
|`%R`|`=` normally, `^` in single-line mode, `-` in multi-line|
|`%x`|Transaction status (`*` in transaction, `!` in failed)|
|`%l`|Line number within current command|
|`%digits`|Character with octal code|
|`%:NAME:`|Value of psql variable NAME|
|`%``CMD``|Output of shell command CMD|
|`%[...]%]`|Begin/end terminal escape sequence|

```sql
\set PROMPT1 '%n@%m/%~%x%# '
```

---

## Transaction Control

```sql
BEGIN;
-- or:
START TRANSACTION;

SAVEPOINT sp1;
ROLLBACK TO SAVEPOINT sp1;
RELEASE SAVEPOINT sp1;

COMMIT;
ROLLBACK;
```

With `\set AUTOCOMMIT off`, every statement is implicitly inside a transaction until you `COMMIT` or `ROLLBACK`.

With `\set ON_ERROR_ROLLBACK on`, a failed statement in a transaction is automatically rolled back to a savepoint, allowing the transaction to continue.

---

## COPY

### Server-side COPY (requires file access on server)

```sql
COPY table_name TO '/tmp/out.csv' WITH (FORMAT csv, HEADER);
COPY table_name FROM '/tmp/in.csv' WITH (FORMAT csv, HEADER);
```

### Client-side `\copy` (reads/writes files on your machine)

```sql
\copy table_name TO 'out.csv' WITH (FORMAT csv, HEADER)
\copy table_name FROM 'in.csv' WITH (FORMAT csv, HEADER)
\copy (SELECT id, name FROM users WHERE active) TO 'active.csv' CSV HEADER
```

`\copy` supports the same options as `COPY` but the file path is resolved on the client.

---

## `\gset` and `\gexec`

### `\gset` — Store Query Results as Variables

```sql
SELECT current_database() AS dbname, current_user AS uname \gset
\echo :dbname :uname
```

With a prefix:

```sql
SELECT 42 AS val \gset my_
\echo :my_val
```

### `\gexec` — Execute Each Cell as SQL

```sql
SELECT 'CREATE TABLE t' || n || ' (id int)' FROM generate_series(1,3) n;
\gexec
-- Creates t1, t2, t3
```

---

## `\watch` — Repeated Execution

Re-runs the current query buffer every N seconds:

```sql
SELECT count(*) FROM pg_stat_activity;
\watch 5
```

Press Ctrl+C to stop.

---

## Conditional Execution

psql does not have an `if-else` in its meta-command language, but you can use variables and `\if`/`\elif`/`\else`/`\endif` (PostgreSQL 10+):

```sql
\if :some_var = 'yes'
  \echo 'doing the thing'
  CREATE TABLE foo (id int);
\elif :some_var = 'maybe'
  \echo 'skipping'
\else
  \echo 'nope'
\endif
```

The condition is a psql expression that evaluates to a boolean. Variables are substituted before evaluation.

---

## `\lo_` — Large Object Commands

|Command|Effect|
|---|---|
|`\lo_import FILE [COMMENT]`|Import a file as a large object|
|`\lo_export OID FILE`|Export a large object to a file|
|`\lo_list`|List large objects|
|`\lo_unlink OID`|Delete a large object|

---

## Query Buffer and History

- The query buffer accumulates lines until a `;` or `\g` is found.
- `\p` prints the current buffer.
- `\r` clears it.
- `\e` opens it in `$EDITOR`.
- `\s` shows command history.
- Use up/down arrows to navigate history in interactive mode.
- `\set HISTSIZE 2000` to keep more history entries.

---

## `~/.psqlrc`

Startup commands executed every time `psql` starts. Use to set defaults:

```sql
-- ~/.psqlrc
\set PROMPT1 '%n@%m/%~%x%# '
\set ON_ERROR_STOP 1
\set VERBOSITY verbose
\timing on
\x auto
\pset null '∅'
\set HISTSIZE 5000
\set HISTCONTROL ignoredups
\set COMP_KEYWORD_CASE upper
```

Skip `~/.psqlrc` with `psql -X`.

---

## Useful System Catalog Queries

### Table sizes

```sql
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total,
  pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_only
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog','information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Database sizes

```sql
SELECT datname, pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database
ORDER BY pg_database_size(datname) DESC;
```

### Active queries

```sql
SELECT pid, usename, state, wait_event_type, wait_event, query
FROM pg_stat_activity
WHERE state <> 'idle'
ORDER BY query_start;
```

### Long-running queries

```sql
SELECT pid, now() - query_start AS duration, query, state
FROM pg_stat_activity
WHERE state <> 'idle' AND query_start IS NOT NULL
ORDER BY duration DESC;
```

### Locks

```sql
SELECT
  l.pid, l.mode, l.granted,
  c.relname, a.query
FROM pg_locks l
JOIN pg_class c ON c.oid = l.relation
JOIN pg_stat_activity a ON a.pid = l.pid
WHERE NOT l.granted;
```

### Bloat estimate

```sql
SELECT
  schemaname, tablename,
  n_dead_tup, n_live_tup,
  round(n_dead_tup::numeric / nullif(n_live_tup + n_dead_tup, 0) * 100, 1) AS dead_pct
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;
```

### Index usage

```sql
SELECT
  schemaname, tablename, indexname,
  idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;
```

### Missing indexes (sequential scans on large tables)

```sql
SELECT
  schemaname, relname,
  seq_scan, seq_tup_read,
  idx_scan,
  n_live_tup
FROM pg_stat_user_tables
WHERE seq_scan > idx_scan AND n_live_tup > 10000
ORDER BY seq_scan DESC;
```

### Replication lag

```sql
SELECT
  client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn,
  (sent_lsn - replay_lsn) AS lag_bytes
FROM pg_stat_replication;
```

---

## `EXPLAIN` and `EXPLAIN ANALYZE`

```sql
EXPLAIN SELECT * FROM orders WHERE user_id = 42;
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT * FROM orders WHERE user_id = 42;
EXPLAIN (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON) SELECT ...;
```

### EXPLAIN Options

|Option|Effect|
|---|---|
|`ANALYZE`|Actually execute the query and show real timings|
|`VERBOSE`|Show output columns, schema-qualified names|
|`COSTS`|Show estimated cost (default: on)|
|`SETTINGS`|Show non-default planner settings|
|`BUFFERS`|Show buffer usage (requires `ANALYZE`)|
|`WAL`|Show WAL usage (requires `ANALYZE`)|
|`TIMING`|Per-node timing (default: on with `ANALYZE`)|
|`SUMMARY`|Show planning/execution time (default: on with `ANALYZE`)|
|`GENERIC_PLAN`|Show generic plan for parameterised query|
|`FORMAT`|`TEXT`, `XML`, `JSON`, `YAML`|

---

## Useful `\e` / Scripting Patterns

### Run a one-liner and get plain output

```sh
psql -Atc "SELECT id FROM users WHERE active" mydb
```

### Generate and run DDL

```sh
psql mydb <<'SQL'
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
    EXECUTE 'VACUUM ANALYZE ' || quote_ident(r.tablename);
  END LOOP;
END;
$$;
SQL
```

### Run a script, stop on error, wrap in transaction

```sh
psql -v ON_ERROR_STOP=1 --single-transaction -f migration.sql mydb
```

### Export a query to JSON

```sh
psql -Atc "SELECT json_agg(row_to_json(t)) FROM (SELECT id, name FROM users) t" mydb
```

---

## Tab Completion

psql supports context-aware tab completion for:

- SQL keywords
- Table, column, function, and schema names
- Meta-commands and their arguments
- Variable names after `:`

Completion behaviour can be tuned with `\set COMP_KEYWORD_CASE upper`.

---

## SSL and Security

```sh
psql "sslmode=require host=db.example.com dbname=mydb user=alice"
psql "sslmode=verify-full sslrootcert=/etc/ssl/certs/ca.crt host=db.example.com dbname=mydb user=alice"
```

SSL modes (weakest to strongest): `disable` → `allow` → `prefer` → `require` → `verify-ca` → `verify-full`.

---

## Version-specific Notes

|Feature|Min Version|
|---|---|
|`\if / \elif / \else / \endif`|PostgreSQL 10 / psql 10|
|`\gx`|psql 11|
|`\watch`|psql 9.3|
|`--csv` output flag|psql 12|
|`\pset format json` / `jsonlines`|psql 13|
|`EXPLAIN (SETTINGS)`|PostgreSQL 12|
|`EXPLAIN (WAL)`|PostgreSQL 13|
|`EXPLAIN (GENERIC_PLAN)`|PostgreSQL 16|
|`\dP` partitioned tables|psql 11|

Check your version:

```sh
psql --version
# or inside psql:
SELECT version();
```

---

## Quick Reference

```
psql -h HOST -p PORT -U USER -d DB   connect
\c DBNAME                             switch database
\q                                    quit
\l                                    list databases
\dn                                   list schemas
\dt [PATTERN]                         list tables
\d TABLE                              describe table
\di [PATTERN]                         list indexes
\df [PATTERN]                         list functions
\du                                   list roles
\dx                                   list extensions
\x [on|off|auto]                      expanded display
\t                                    tuples only
\a                                    toggle alignment
\pset null '(null)'                   show NULLs
\timing                               show query time
\i FILE                               run a file
\e                                    edit buffer
\p                                    print buffer
\r                                    clear buffer
\g                                    execute buffer
\watch N                              repeat every N sec
\gset                                 store results as vars
\gexec                                execute result cells
\set VAR VAL                          set variable
\if / \elif / \else / \endif          conditionals
\copy ... TO/FROM FILE                client-side COPY
\conninfo                             show connection
\h CMD                                SQL help
\? [commands]                         meta-command help
```