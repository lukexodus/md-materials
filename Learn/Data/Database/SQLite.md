# Syllabus

## Module 1: SQLite Fundamentals

- SQLite architecture and design principles
- Installation and setup across platforms
- SQLite command-line interface (sqlite3)
- Database files and storage format
- SQLite vs other database systems
- Use cases and limitations

## Module 2: Database Creation and Management

- Creating databases
- Database connection and disconnection
- Database metadata and information schema
- Database integrity checking
- Backup and restore operations
- Database encryption (SEE - SQLite Encryption Extension)

## Module 3: Data Definition Language (DDL)

- Table creation and modification
- Column data types and constraints
- Primary keys and foreign keys
- Unique constraints and check constraints
- Default values and auto-increment
- Dropping and renaming tables/columns

## Module 4: Basic SQL Operations (DML)

- INSERT statements and variations
- SELECT statements and basic queries
- UPDATE operations
- DELETE operations
- Data import and export
- Bulk operations

## Module 5: Advanced Querying

- WHERE clauses and filtering
- Sorting with ORDER BY
- LIMIT and OFFSET for pagination
- Aggregate functions (COUNT, SUM, AVG, MIN, MAX)
- GROUP BY and HAVING clauses
- Subqueries and nested queries
- Common Table Expressions (CTEs)

## Module 6: Joins and Relationships

- Inner joins
- Left and right outer joins
- Full outer joins (workarounds)
- Cross joins
- Self-joins
- Multi-table relationships
- Join optimization strategies

## Module 7: Indexes and Performance

- Index creation and types
- Clustered vs non-clustered indexes
- Composite indexes
- Partial indexes
- Index maintenance
- Query execution plans (EXPLAIN QUERY PLAN)
- Performance optimization techniques

## Module 8: SQLite Functions

- Built-in scalar functions
- String manipulation functions
- Date and time functions
- Mathematical functions
- Type conversion functions
- Custom user-defined functions
- Aggregate functions

## Module 9: Advanced Data Types and Features

- JSON support and JSON functions
- BLOB handling
- Full-text search (FTS3, FTS4, FTS5)
- Spatial data with SpatiaLite extension
- Generated columns
- Stored generated columns vs virtual columns

## Module 10: Transactions and Concurrency

- Transaction concepts (ACID properties)
- BEGIN, COMMIT, ROLLBACK
- Savepoints and nested transactions
- Isolation levels
- Locking mechanisms
- WAL mode (Write-Ahead Logging)
- Concurrent access patterns

## Module 11: Triggers and Automation

- Creating triggers (BEFORE, AFTER, INSTEAD OF)
- Trigger events (INSERT, UPDATE, DELETE)
- Trigger design patterns
- Recursive triggers
- Trigger debugging and troubleshooting
- Performance considerations

## Module 12: Views and Virtual Tables

- Creating and managing views
- Updatable views
- Virtual tables concept
- Creating virtual table modules
- Built-in virtual tables (sqlite_master, etc.)
- Performance implications

## Module 13: Security and Access Control

- Database file permissions
- SQL injection prevention
- Parameter binding and prepared statements
- Row-level security patterns
- Audit logging strategies
- Data privacy considerations

## Module 14: SQLite Extensions

- Loading and using extensions
- Popular extensions (SpatiaLite, SQLCipher)
- Creating custom extensions
- Extension distribution and deployment
- Version compatibility

## Module 15: Programming Language Integration

- Python sqlite3 module
- C/C++ SQLite API
- Java JDBC drivers
- JavaScript (Node.js) integration
- Other language bindings
- Connection pooling strategies

## Module 16: Advanced Administration

- Database analysis and statistics
- Vacuum and optimize operations
- Memory management and cache tuning
- Configuration options and pragmas
- Logging and monitoring
- Migration strategies

## Module 17: Testing and Quality Assurance

- Unit testing database operations
- Test data generation
- Schema validation
- Performance testing
- Regression testing
- Continuous integration with databases

## Module 18: Deployment and Production

- Production deployment strategies
- Replication and synchronization
- Backup automation
- Monitoring and alerting
- Capacity planning
- Disaster recovery

## Module 19: Advanced Topics

- Custom collation sequences
- Recursive queries and hierarchical data
- Graph data modeling
- Time series data handling
- Data warehousing patterns
- Migration from other databases

## Module 20: Troubleshooting and Optimization

- Common error diagnosis
- Performance bottleneck identification
- Query optimization techniques
- Schema design best practices
- Debugging tools and techniques
- Maintenance procedures

## Module 21: Real-World Projects

- Desktop application database design
- Mobile app data layer
- Web application backend
- Data analysis and reporting
- ETL processes with SQLite
- Embedded systems integration

---

# SQLite Fundamentals

SQLite is a self-contained, serverless, zero-configuration, transactional SQL database engine. Unlike traditional database systems that operate as separate server processes, SQLite reads and writes directly to ordinary disk files, making it one of the most widely deployed database engines in the world.

## SQLite Architecture and Design Principles

SQLite follows a unique architectural approach that distinguishes it from client-server database systems. The entire database engine is embedded within the application that uses it, eliminating the need for a separate database server process.

**Core architectural components:**

The SQLite architecture consists of several layers working together. The interface layer handles SQL command strings and database connections. The SQL compiler transforms SQL statements into bytecode through tokenization, parsing, and code generation. The virtual machine (VDBE - Virtual Database Engine) executes the bytecode instructions. The B-tree module manages the organization of database pages, handling both table B-trees and index B-trees. The pager module manages the reading and writing of database pages, implementing transaction control and crash recovery. The OS interface provides a portable abstraction layer for operating system calls.

**Design principles:**

SQLite prioritizes simplicity and reliability over raw performance. The library is designed to be completely self-contained with minimal external dependencies. It requires zero configuration - no setup procedures, no server processes to manage, and no configuration files. The entire database exists as a single cross-platform file that can be freely copied between 32-bit and 64-bit systems or between big-endian and little-endian architectures.

Atomicity, Consistency, Isolation, and Durability (ACID) properties are fully supported. Transactions are atomic even if interrupted by system crashes or power failures. SQLite implements serializable isolation by default, though it also supports read uncommitted and write-ahead logging modes.

The design emphasizes backward compatibility. Database files created by SQLite version 3.0.0 (released in 2004) can still be read and written by current versions. The library maintains a stable, well-documented file format that is guaranteed to be supported through at least the year 2050.

## Installation and Setup Across Platforms

SQLite requires minimal installation effort since it's a library rather than a standalone application. The database engine comes pre-installed on many systems and is embedded in numerous applications.

**Windows:**

SQLite is not pre-installed on Windows. To use the command-line tools, download the precompiled binaries from the official SQLite website. The sqlite-tools package contains sqlite3.exe, which is the command-line interface. Extract the zip file to a directory, optionally adding it to your system PATH for convenient access from any location. No installation wizard or registry modifications are required.

For development purposes, download the appropriate DLL (sqlite3.dll) and header files (sqlite3.h) from the amalgamation package. Many programming languages include SQLite bindings that handle the library automatically.

**macOS:**

SQLite comes pre-installed on macOS systems. The sqlite3 command-line tool is immediately available from the Terminal. To verify installation, run `sqlite3 --version`. The pre-installed version may not be the latest release. For the newest version, install through Homebrew using `brew install sqlite3`, or download binaries directly from the SQLite website.

**Linux:**

Most Linux distributions include SQLite by default. On Debian-based systems (Ubuntu, Mint), install or update using `sudo apt-get install sqlite3`. On Red Hat-based systems (Fedora, CentOS), use `sudo yum install sqlite` or `sudo dnf install sqlite`. On Arch Linux, use `sudo pacman -S sqlite`.

For development, install the development package that includes header files. On Debian-based systems, this is `libsqlite3-dev`. On Red Hat-based systems, use `sqlite-devel`.

**Mobile platforms:**

Both iOS and Android include SQLite as part of their core system libraries. On iOS, SQLite is available through the libsqlite3 library. On Android, SQLite is accessible through the android.database.sqlite package. Applications can use SQLite without additional installation or bundling.

**Verification:**

After installation, verify SQLite is working by opening a terminal or command prompt and typing `sqlite3 --version`. This displays the version number and compilation options. To test basic functionality, create a temporary in-memory database by typing `sqlite3 :memory:` followed by a simple SQL command like `SELECT sqlite_version();`.

## SQLite Command-Line Interface (sqlite3)

The sqlite3 command-line program is a powerful tool for interacting with SQLite databases. It provides an interactive shell for executing SQL statements, managing databases, and performing administrative tasks.

**Starting the shell:**

Launch the SQLite shell by typing `sqlite3` followed optionally by a database filename. If no filename is provided, SQLite creates a temporary in-memory database. If a filename is specified but doesn't exist, SQLite creates a new database file. To open an existing database, provide its path: `sqlite3 /path/to/database.db`.

**Basic SQL execution:**

Once in the shell, execute SQL statements by typing them and ending with a semicolon. Multi-line statements are supported - the shell continues accepting input until it encounters a semicolon. Statements can be interrupted using Ctrl+C. The shell displays query results in a default column mode with headers.

**Dot commands:**

The shell includes special meta-commands that begin with a period. These commands control shell behavior and perform administrative functions. Unlike SQL statements, dot commands don't require a semicolon.

`.help` displays a list of all available dot commands with brief descriptions. `.databases` shows all attached databases with their file paths. `.tables` lists all tables in the current database, optionally filtered by pattern. `.schema` displays the CREATE statements for tables and indexes, showing the database structure. `.schema tablename` shows the schema for a specific table.

`.mode` changes the output format. Available modes include csv, column, html, insert, json, line, list, quote, and tabs. The column mode displays results in aligned columns. The csv mode produces comma-separated values suitable for spreadsheet import. The json mode outputs results as JSON arrays.

`.headers on` or `.headers off` controls whether column names appear in query results. `.separator` changes the delimiter for list and csv modes. `.width` sets column widths for column mode output.

`.import FILE TABLE` reads data from a CSV file into a table. `.output FILE` redirects subsequent query output to a file instead of the screen. `.output stdout` returns output to the terminal. `.once FILE` redirects only the next query's output to a file.

`.dump` generates SQL statements that recreate the entire database. `.dump tablename` dumps only a specific table. This creates a backup in SQL format that can be restored by piping it back to sqlite3. `.backup FILE` creates a binary backup of the database to a file.

`.read FILE` executes SQL statements from a file. This is useful for running scripts or restoring database dumps. `.open FILE` closes the current database and opens a different one.

`.exit` or `.quit` terminates the shell session. Ctrl+D also exits on Unix-like systems.

**Configuration:**

The shell reads commands from a .sqliterc file in the user's home directory at startup. This file can contain dot commands to customize the shell environment. Common customizations include setting output mode, enabling headers, and adjusting column widths.

**Performance analysis:**

`.timer on` displays execution time for each SQL statement, useful for performance analysis. `.explain` changes the output mode to display VDBE bytecode instructions. `.eqp on` shows query execution plans before displaying results.

## Database Files and Storage Format

SQLite stores an entire database in a single ordinary disk file. This design choice provides numerous advantages including simplicity of backup, ease of transfer between systems, and straightforward database management.

**File structure:**

The SQLite database file is organized into fixed-size pages. The default page size is 4096 bytes, though values from 512 to 65536 bytes are supported (must be powers of 2). The page size is set when the database is created and cannot be changed afterward without recreating the database, though the VACUUM INTO command can create a copy with a different page size.

The first 100 bytes of the database file comprise the database header. This header contains critical information including a magic header string that identifies the file as an SQLite database, the database page size, file format version numbers, the database size in pages, and various flags controlling database behavior.

Following the header, the remainder of the file consists entirely of fixed-size pages. The first page contains both the database header and the root page of the schema table. Pages are typed according to their function: b-tree interior pages, b-tree leaf pages, freelist pages, overflow pages, and pointer map pages.

**B-tree organization:**

SQLite uses B-tree data structures to organize both tables and indexes. Each table has its own B-tree with integer row IDs (rowid) as keys. The actual data is stored in the leaf pages of this B-tree. Tables without an explicit INTEGER PRIMARY KEY receive an automatically generated rowid.

Indexes are also implemented as B-trees, with the indexed column values as keys and the corresponding rowid values as data. This allows SQLite to quickly locate rows based on indexed columns.

**Storage of data types:**

SQLite uses a dynamic type system. Rather than declaring column types strictly, SQLite uses storage classes: NULL, INTEGER (1, 2, 3, 4, 6, or 8 bytes depending on value), REAL (8-byte IEEE floating point), TEXT (UTF-8, UTF-16BE, or UTF-16LE), and BLOB (stored exactly as input).

Text and BLOB values are stored inline if they fit within the B-tree page. If a value is too large, SQLite chains it across multiple overflow pages. Large values are broken into chunks distributed across overflow pages linked together.

**Journal files and transactions:**

During transactions, SQLite creates temporary journal files. The rollback journal (database-journal) preserves the original content of modified pages, enabling recovery if a transaction is rolled back or interrupted. Write-ahead logging (WAL mode) creates a separate WAL file (database-wal) that records changes without modifying the original database file immediately.

The rollback journal provides atomicity and durability. Before modifying any page, SQLite writes the original page content to the journal. If the transaction commits, the journal is deleted. If the transaction rolls back or the system crashes, SQLite uses the journal to restore the database to its previous state.

WAL mode provides better concurrency. Writes append to the WAL file while reads access the original database file. Readers and writers don't block each other. Periodically, changes from the WAL file are transferred back to the main database file through a checkpoint operation.

**Locking and concurrency:**

SQLite implements file-level locking to manage concurrent access. Five lock states exist: UNLOCKED (no locks held), SHARED (reading allowed, writing blocked), RESERVED (intent to write, others can read), PENDING (waiting for readers to finish), and EXCLUSIVE (reading and writing blocked for others).

Multiple processes can hold SHARED locks simultaneously, allowing concurrent reads. Only one process can hold a RESERVED, PENDING, or EXCLUSIVE lock. This locking protocol ensures ACID properties but limits write concurrency - only one writer can modify the database at a time.

WAL mode improves concurrency by allowing one writer and multiple readers to operate simultaneously. Readers access database snapshots while the writer appends to the WAL file.

**File format stability:**

The SQLite file format is extraordinarily stable. The developers guarantee that database files created by SQLite 3.0.0 (2004) remain readable and writable by all future versions of SQLite 3. The file format is fully documented and intended to remain compatible through at least 2050. This stability makes SQLite suitable for long-term data storage and archival purposes.

## SQLite vs Other Database Systems

SQLite occupies a unique position in the database ecosystem. Understanding how it compares to other database systems helps identify when SQLite is the appropriate choice.

**SQLite vs client-server databases (PostgreSQL, MySQL, SQL Server):**

The fundamental architectural difference is that SQLite is serverless. Traditional databases operate as separate server processes that clients connect to over a network or local socket. SQLite is a library that applications link against, reading and writing database files directly.

This serverless architecture eliminates network latency and the overhead of inter-process communication. SQLite queries execute faster for simple operations since there's no client-server handshake. However, client-server databases excel at handling multiple concurrent writers across different machines.

SQLite implements a simpler concurrency model. Only one process can write to a SQLite database at a time (though WAL mode allows concurrent reads during writes). PostgreSQL and MySQL support multiple simultaneous writers through row-level locking and multi-version concurrency control (MVCC). For applications with many concurrent write operations, client-server databases provide better throughput.

Configuration requirements differ drastically. Client-server databases require installation, configuration, user management, backup strategies, and ongoing maintenance. SQLite requires none of this - the entire database is a single file with no configuration files, no server processes to monitor, and no user accounts to manage.

Resource usage varies significantly. Client-server databases consume substantial memory and CPU resources even when idle because they maintain persistent server processes. SQLite consumes no resources when not in use. The library loads only when the application needs it and uses minimal memory.

Data integrity guarantees are equally strong. Both SQLite and major client-server databases provide full ACID compliance. SQLite's transaction mechanism ensures atomicity and durability even during power failures or system crashes.

Query capabilities differ in sophistication. PostgreSQL and MySQL support advanced features like stored procedures, triggers with full procedural logic, complex user-defined functions, and sophisticated query optimization. SQLite provides basic trigger support and limited functions but lacks stored procedures and many advanced SQL features.

**SQLite vs embedded databases (Berkeley DB, LevelDB):**

Berkeley DB and LevelDB are key-value stores, not relational databases. They don't support SQL, tables, or relationships. Applications must handle data organization and querying logic themselves. SQLite provides full SQL support with tables, indexes, joins, and complex queries.

Berkeley DB offers higher write performance for key-value operations since it doesn't parse SQL or maintain relational structure. However, SQLite's SQL interface dramatically reduces development time for applications that need relational data organization.

LevelDB excels at sequential writes and range scans. It's optimized for write-heavy workloads. SQLite provides better read performance for complex queries involving multiple tables and indexes.

**SQLite vs NoSQL databases (MongoDB, Redis):**

MongoDB and Redis follow different data models. MongoDB uses document storage with JSON-like documents. Redis is an in-memory data structure store. SQLite adheres to the relational model with tables and rows.

For applications that need relational data with foreign keys and complex queries joining multiple tables, SQLite's SQL interface provides significant advantages. NoSQL databases require application code to maintain relationships and often denormalize data.

Redis operates entirely in memory, providing extremely fast operations but limited by available RAM. MongoDB can handle larger datasets but requires a running server process. SQLite balances these extremes with disk-based storage and zero server overhead.

**SQLite vs file formats (CSV, JSON, XML):**

Many applications use CSV, JSON, or XML files for data storage. SQLite offers substantial advantages for structured data. Querying JSON or CSV files requires loading the entire file into memory and parsing it. SQLite allows indexed queries that read only the necessary data.

Concurrent access to CSV or JSON files is problematic. Multiple processes modifying these files risk corruption. SQLite provides proper locking and transaction support.

SQLite files are often smaller than equivalent JSON representations since they use binary storage and don't repeat field names for each record. CSV files may be smaller for simple tabular data but lack type information and structure.

## Use Cases and Limitations

SQLite excels in specific scenarios while being unsuitable for others. Understanding these boundaries helps architects make informed decisions.

**Ideal use cases:**

Embedded applications represent SQLite's primary domain. Mobile apps on iOS and Android universally use SQLite for local data storage. Desktop applications use SQLite for preferences, caches, and application data. Web browsers use SQLite extensively - Firefox and Chrome store bookmarks, history, cookies, and cache metadata in SQLite databases.

IoT and edge devices benefit from SQLite's minimal resource footprint. Sensors, industrial equipment, and embedded systems use SQLite to collect and store data locally before transmission to central servers. The zero-configuration requirement is crucial when deploying thousands of devices.

Development and testing environments leverage SQLite's simplicity. Developers can create test databases instantly without setting up database servers. Test suites run faster since they don't wait for network communication. Each test can use a fresh in-memory database that disappears when the test completes.

Data analysis and scientific computing use SQLite as an application file format. Researchers distribute datasets as SQLite databases rather than CSV files. Recipients can immediately query the data using SQL without writing parsing code. The single-file format simplifies data sharing and archival.

Configuration and small data stores are perfect for SQLite. Applications that need structured storage for settings, logs, or cached data avoid the complexity of setting up a database server. The database file can reside in the application directory without special permissions or administrative setup.

Internal/temporary databases serve as intermediate storage during complex operations. Applications can create SQLite databases to sort large datasets, deduplicate records, or perform multi-step transformations that would be difficult with in-memory data structures.

**Appropriate scale:**

SQLite handles databases up to 281 terabytes in theory, though practical limits are lower. Databases in the hundreds of gigabytes work well if queries are indexed appropriately. The single-file design means the filesystem must support large files.

Read-heavy workloads scale excellently. Multiple processes can read simultaneously without interference. A single SQLite database can serve thousands of concurrent readers efficiently.

Write throughput becomes the limiting factor. Without WAL mode, writes are serialized and can create a bottleneck. With WAL mode, one writer can operate while readers continue, but applications needing multiple concurrent writers should consider client-server databases.

**Limitations and antipatterns:**

High-concurrency write workloads don't fit SQLite's design. Applications with many simultaneous writers across multiple machines should use PostgreSQL, MySQL, or other client-server databases. The file-level locking means writes serialize, creating contention.

Client-server applications generally shouldn't use SQLite. If the database and application run on separate machines, SQLite is inappropriate. Network filesystems (NFS, SMB) introduce locking problems and corruption risks. [Inference: SQLite's documentation explicitly warns against using it on network filesystems due to locking mechanism incompatibilities.]

Large enterprise applications with complex access control requirements exceed SQLite's capabilities. SQLite has minimal user management - all database access depends on file system permissions. PostgreSQL and MySQL provide sophisticated role-based access control, audit logging, and security features.

Applications requiring advanced SQL features may find SQLite limiting. Features not supported include RIGHT and FULL OUTER JOIN, stored procedures, user-defined aggregate functions in some contexts, and various PostgreSQL or MySQL-specific extensions.

Very high write throughput applications need different solutions. While SQLite handles typical application write loads easily, applications inserting millions of rows per second should consider specialized databases or streaming platforms.

**Key points:**

SQLite is a library, not a server. This architectural choice defines its strengths (simplicity, zero configuration, embedded use) and limitations (write concurrency, networked access). The entire database exists as a single cross-platform file that provides ACID transactions with minimal overhead. It's ideally suited for embedded systems, mobile apps, desktop software, development environments, and any application needing local structured storage without administrative burden. Applications requiring multiple concurrent writers, networked database access, or enterprise-scale user management should use client-server databases instead.

**Related topics to explore:**

WAL (Write-Ahead Logging) mode and its performance implications, SQLite's full-text search capabilities (FTS5), backup strategies and best practices, optimizing SQLite performance through proper indexing and query design, SQLite extensions and loadable modules, using SQLite with various programming languages (Python, Java, C/C++, JavaScript), migration strategies between SQLite and client-server databases.

---

# Database Creation and Management in SQLite

## Creating Databases

SQLite databases are created automatically when you attempt to connect to a database file that doesn't exist. Unlike traditional database management systems, SQLite doesn't require a separate server process or explicit CREATE DATABASE command.

**Key points:**

- A database is simply a single file on disk with a `.db`, `.sqlite`, `.sqlite3`, or any custom extension
- The file is created when you first connect to it using SQLite's API or command-line interface
- If you connect to an existing file, SQLite opens it; if the file doesn't exist, SQLite creates it
- An in-memory database can be created using the special filename `:memory:` which exists only in RAM and is destroyed when the connection closes
- Temporary databases can be created using an empty string `""` as the filename

**Example:**

```python
import sqlite3

# Creates a new database file or opens existing one
conn = sqlite3.connect('mydatabase.db')

# Creates an in-memory database
memory_conn = sqlite3.connect(':memory:')

# Creates a temporary database
temp_conn = sqlite3.connect('')
```

## Database Connection and Disconnection

Connection management is fundamental to working with SQLite databases. Proper connection handling ensures data integrity and resource cleanup.

**Key points:**

- Connections are established using language-specific APIs (sqlite3 module in Python, sqlite3 gem in Ruby, etc.)
- Multiple connections to the same database file are supported with appropriate locking mechanisms
- SQLite uses file-level locking to handle concurrent access
- Connections should always be properly closed to ensure pending transactions are committed and resources are released
- Connection pooling is less critical for SQLite than for client-server databases, but can still improve performance in multi-threaded applications
- Shared cache mode can be enabled to allow multiple connections to share the same page cache
- WAL (Write-Ahead Logging) mode improves concurrency by allowing readers to access the database while a writer is writing

**Example:**

```python
import sqlite3

# Opening a connection
conn = sqlite3.connect('example.db')

# Creating a cursor for executing SQL
cursor = conn.cursor()

# Executing queries
cursor.execute('CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)')

# Committing changes
conn.commit()

# Closing the connection
conn.close()

# Using context manager (automatically handles closing)
with sqlite3.connect('example.db') as conn:
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM users')
```

## Database Metadata and Information Schema

SQLite provides special tables and PRAGMA commands to query database metadata and schema information.

**Key points:**

- The `sqlite_master` table (or `sqlite_schema` in newer versions) contains schema information for all database objects
- Each database has its own `sqlite_master` table storing CREATE statements for tables, indexes, triggers, and views
- The `sqlite_temp_master` table contains schema information for temporary objects
- PRAGMA commands provide access to various database settings and metadata
- The `table_info` pragma returns column information for a specific table
- The `database_list` pragma shows all attached databases
- The `sqlite_stat1` and `sqlite_stat4` tables store index statistics used by the query optimizer

**Example:**

```sql
-- Query all tables in the database
SELECT name, type, sql FROM sqlite_master WHERE type='table';

-- Get column information for a specific table
PRAGMA table_info(users);

-- List all indexes
SELECT name, tbl_name FROM sqlite_master WHERE type='index';

-- Get database file information
PRAGMA database_list;

-- Get foreign key list for a table
PRAGMA foreign_key_list(orders);

-- Get index information
PRAGMA index_list(users);

-- Get table schema
SELECT sql FROM sqlite_master WHERE name='users';
```

## Database Integrity Checking

SQLite provides built-in mechanisms to verify database integrity and detect corruption.

**Key points:**

- The `PRAGMA integrity_check` command performs a comprehensive integrity check of the entire database
- The `PRAGMA quick_check` performs a faster but less thorough integrity check
- Integrity checks verify B-tree structures, check for orphaned pages, and validate internal consistency
- The `integrity_check` pragma can be limited to specific tables by providing table names as arguments
- Regular integrity checks are recommended, especially after system crashes or storage failures
- The `foreign_key_check` pragma verifies foreign key constraints without checking overall database integrity
- Integrity checks do not repair corruption; they only detect it

**Example:**

```sql
-- Full integrity check (returns 'ok' if no issues found)
PRAGMA integrity_check;

-- Quick integrity check (faster, less thorough)
PRAGMA quick_check;

-- Check integrity of specific tables
PRAGMA integrity_check(users, orders);

-- Check foreign key constraints
PRAGMA foreign_key_check;

-- Check foreign keys for specific table
PRAGMA foreign_key_check(orders);
```

**Output:**

For a healthy database, `integrity_check` returns a single row with the value "ok". If issues are found, it returns descriptive error messages indicating the nature and location of corruption.

## Backup and Restore Operations

SQLite offers multiple methods for backing up and restoring databases, ranging from simple file copying to online backup APIs.

**Key points:**

- The simplest backup method is copying the database file when no connections are active
- The `.backup` command in the SQLite CLI creates a consistent backup even while the database is in use
- The SQLite Backup API allows programmatic online backups without locking the database
- Online backups copy data page-by-page, allowing other connections to continue working
- The VACUUM command can create a compacted copy of the database in a new file
- For databases using WAL mode, both the database file and WAL file should be considered during backup
- The backup API handles transaction consistency automatically
- Incremental backups are not natively supported; each backup is a full copy

**Example:**

```bash
# Using SQLite CLI
sqlite3 original.db ".backup backup.db"

# Restore from backup
sqlite3 restored.db ".restore backup.db"
```

```python
import sqlite3

# Python backup example using backup API
source = sqlite3.connect('original.db')
backup = sqlite3.connect('backup.db')

# Perform the backup
source.backup(backup)

backup.close()
source.close()

# Backup with progress tracking
def progress(status, remaining, total):
    print(f'Copied {total-remaining} of {total} pages...')

source = sqlite3.connect('original.db')
backup = sqlite3.connect('backup.db')
source.backup(backup, pages=10, progress=progress)
```

**Alternative methods:**

```sql
-- Using VACUUM to create a compacted copy
VACUUM INTO 'backup.db';

-- Attach and copy method
ATTACH DATABASE 'backup.db' AS backup;
CREATE TABLE backup.users AS SELECT * FROM main.users;
DETACH DATABASE backup;
```

## Database Encryption (SEE - SQLite Encryption Extension)

[Unverified] SQLite Encryption Extension (SEE) is a commercial extension that provides transparent database encryption. The following information is based on publicly available documentation, but specific implementation details and behavior may vary.

**Key points:**

- SEE is a proprietary, paid extension to SQLite (not included in the free, open-source version)
- SEE provides 256-bit AES encryption for the entire database file
- Encryption and decryption occur transparently at the pager level
- The encryption key must be provided when opening the database connection
- Without the correct key, the database file appears as random data
- Third-party alternatives include SQLCipher (open-source), wxSQLite3, and others
- Encryption adds performance overhead due to encryption/decryption operations
- The database file size remains approximately the same after encryption
- Changing the encryption key requires re-encrypting the entire database

**Example (SEE):**

[Unverified] The exact API may vary by implementation:

```python
# Example pattern - actual implementation depends on the extension used
import sqlite3

# Opening an encrypted database with SEE
conn = sqlite3.connect('encrypted.db')
conn.execute("PRAGMA key='your-encryption-key'")

# Creating a new encrypted database
conn = sqlite3.connect('new_encrypted.db')
conn.execute("PRAGMA key='your-encryption-key'")
conn.execute('CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)')
```

**Example (SQLCipher - open-source alternative):**

```python
from pysqlcipher3 import dbapi2 as sqlite

# Opening encrypted database with SQLCipher
conn = sqlite.connect('encrypted.db')
conn.execute("PRAGMA key='your-passphrase'")

# Re-keying (changing the encryption key)
conn.execute("PRAGMA rekey='new-passphrase'")
```

**Important considerations:**

- Encryption is applied at rest (to the database file); data in memory is unencrypted
- Connection strings or key management must be handled securely in application code
- Performance impact varies based on workload characteristics and hardware
- Encrypted databases cannot be opened or examined without the correct key
- Key loss results in permanent data loss with no recovery option
- Some SQLite tools and utilities may not support encrypted databases

---

**Related topics you may want to explore:** Transaction management and ACID properties, SQLite journal modes (DELETE, WAL, MEMORY), Performance optimization and query planning, Concurrency control and locking mechanisms, Attached databases and cross-database queries

---

# Data Definition Language (DDL) in SQLite

Data Definition Language (DDL) consists of SQL commands used to define, modify, and remove database structures. In SQLite, DDL operations handle the schema of your database—creating tables, defining relationships, setting constraints, and managing the overall structure of your data storage.

## Table Creation and Modification

### Creating Tables

The `CREATE TABLE` statement defines a new table with specified columns and their properties.

**Basic syntax:**

```sql
CREATE TABLE table_name (
    column1 datatype constraints,
    column2 datatype constraints,
    ...
    table_constraints
);
```

**Example:**

```sql
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    hire_date TEXT,
    salary REAL
);
```

### IF NOT EXISTS Clause

Prevents errors when creating tables that might already exist:

```sql
CREATE TABLE IF NOT EXISTS departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL
);
```

### Temporary Tables

Tables that exist only for the duration of the database connection:

```sql
CREATE TEMP TABLE session_data (
    session_id TEXT,
    user_id INTEGER,
    login_time TEXT
);
```

### Modifying Tables with ALTER TABLE

SQLite supports limited `ALTER TABLE` operations compared to other database systems.

**Adding columns:**

```sql
ALTER TABLE employees ADD COLUMN department_id INTEGER;
```

**Renaming tables:**

```sql
ALTER TABLE employees RENAME TO staff;
```

**Renaming columns** (SQLite 3.25.0+):

```sql
ALTER TABLE employees RENAME COLUMN email TO email_address;
```

**Dropping columns** (SQLite 3.35.0+):

```sql
ALTER TABLE employees DROP COLUMN middle_name;
```

[Inference] For SQLite versions before 3.35.0, dropping columns requires recreating the table without the unwanted column, copying data, dropping the old table, and renaming the new table.

## Column Data Types and Constraints

### Storage Classes

SQLite uses dynamic typing with five storage classes:

- **NULL**: The value is a NULL value
- **INTEGER**: Signed integer (1, 2, 3, 4, 6, or 8 bytes)
- **REAL**: Floating point value (8-byte IEEE floating point)
- **TEXT**: Text string (UTF-8, UTF-16BE, or UTF-16LE)
- **BLOB**: Binary Large Object, stored exactly as input

### Type Affinity

SQLite uses type affinity rules to determine which storage class to use for a value. Common type affinities:

- **TEXT**: TEXT, CHAR, VARCHAR, CLOB
- **NUMERIC**: NUMERIC, DECIMAL, BOOLEAN, DATE, DATETIME
- **INTEGER**: INT, INTEGER, BIGINT, SMALLINT
- **REAL**: REAL, DOUBLE, FLOAT
- **BLOB**: BLOB (no affinity declared)

**Example:**

```sql
CREATE TABLE products (
    product_id INTEGER,
    product_name TEXT,
    price REAL,
    in_stock BOOLEAN,  -- stored as INTEGER (0 or 1)
    description TEXT,
    image BLOB
);
```

### Column Constraints

Constraints enforce rules on column data:

**NOT NULL**: Ensures column cannot contain NULL values

```sql
CREATE TABLE users (
    username TEXT NOT NULL,
    password TEXT NOT NULL
);
```

**UNIQUE**: Ensures all values in column are distinct

```sql
CREATE TABLE accounts (
    account_id INTEGER,
    email TEXT UNIQUE
);
```

**CHECK**: Validates values against a condition

```sql
CREATE TABLE products (
    product_id INTEGER,
    price REAL CHECK(price > 0),
    quantity INTEGER CHECK(quantity >= 0)
);
```

**DEFAULT**: Provides default value when none specified

```sql
CREATE TABLE orders (
    order_id INTEGER,
    order_date TEXT DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'pending'
);
```

**COLLATE**: Defines text comparison rules

```sql
CREATE TABLE names (
    name TEXT COLLATE NOCASE  -- case-insensitive comparisons
);
```

## Primary Keys and Foreign Keys

### Primary Keys

A primary key uniquely identifies each row in a table. In SQLite, primary keys create an implicit UNIQUE constraint and NOT NULL constraint.

**Single column primary key:**

```sql
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);
```

**Composite primary key:**

```sql
CREATE TABLE order_items (
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);
```

### INTEGER PRIMARY KEY and ROWID

When a column is declared as `INTEGER PRIMARY KEY`, it becomes an alias for SQLite's internal ROWID:

```sql
CREATE TABLE logs (
    log_id INTEGER PRIMARY KEY,  -- alias for ROWID
    message TEXT,
    timestamp TEXT
);
```

**Key characteristics:**

- Automatically assigned sequential values if not provided
- More efficient for lookups and joins
- Uses less storage than non-integer primary keys

### Foreign Keys

Foreign keys establish relationships between tables and enforce referential integrity.

**Enabling foreign key constraints** (required in SQLite):

```sql
PRAGMA foreign_keys = ON;
```

**Basic foreign key:**

```sql
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

**Foreign key with actions:**

```sql
CREATE TABLE order_details (
    detail_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT
);
```

**Referential actions:**

- **NO ACTION**: Prevents deletion/update if referenced (default)
- **RESTRICT**: Same as NO ACTION but cannot be deferred
- **CASCADE**: Propagates changes to child rows
- **SET NULL**: Sets foreign key to NULL
- **SET DEFAULT**: Sets foreign key to default value

## Unique Constraints and Check Constraints

### Unique Constraints

Ensures all values in a column or combination of columns are distinct.

**Column-level unique:**

```sql
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    username TEXT UNIQUE,
    email TEXT UNIQUE
);
```

**Table-level unique (composite):**

```sql
CREATE TABLE enrollments (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date TEXT,
    UNIQUE(student_id, course_id)
);
```

**Named unique constraint:**

```sql
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    sku TEXT,
    CONSTRAINT unique_sku UNIQUE(sku)
);
```

### Check Constraints

Validates data based on a boolean expression.

**Column-level check:**

```sql
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    age INTEGER CHECK(age >= 18 AND age <= 100),
    salary REAL CHECK(salary > 0)
);
```

**Table-level check:**

```sql
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    cost_price REAL,
    selling_price REAL,
    CHECK(selling_price >= cost_price)
);
```

**Named check constraint:**

```sql
CREATE TABLE accounts (
    account_id INTEGER PRIMARY KEY,
    balance REAL,
    CONSTRAINT positive_balance CHECK(balance >= 0)
);
```

**Complex check with multiple conditions:**

```sql
CREATE TABLE appointments (
    appointment_id INTEGER PRIMARY KEY,
    start_time TEXT,
    end_time TEXT,
    status TEXT,
    CHECK(status IN ('scheduled', 'completed', 'cancelled')),
    CHECK(end_time > start_time)
);
```

## Default Values and Auto-increment

### Default Values

Provides values when INSERT statement doesn't specify them.

**Literal defaults:**

```sql
CREATE TABLE articles (
    article_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    status TEXT DEFAULT 'draft',
    view_count INTEGER DEFAULT 0,
    is_published INTEGER DEFAULT 0
);
```

**Expression defaults:**

```sql
CREATE TABLE events (
    event_id INTEGER PRIMARY KEY,
    event_name TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

**Using functions as defaults:**

```sql
CREATE TABLE sessions (
    session_id TEXT DEFAULT (lower(hex(randomblob(16)))),
    user_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### Auto-increment

SQLite provides automatic incrementing for INTEGER PRIMARY KEY columns.

**Basic auto-increment:**

```sql
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,  -- auto-increments automatically
    customer_id INTEGER,
    order_date TEXT
);
```

**AUTOINCREMENT keyword:**

```sql
CREATE TABLE invoices (
    invoice_id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL,
    issue_date TEXT
);
```

**Difference between with and without AUTOINCREMENT:**

- Without AUTOINCREMENT: SQLite reuses deleted ROWID values
- With AUTOINCREMENT: SQLite never reuses deleted values (maintains monotonic increase)
- AUTOINCREMENT uses additional storage and is slightly slower

[Inference] AUTOINCREMENT is typically only needed when ROWID reuse would cause problems, such as when IDs are used as permanent references outside the database.

**Example with INSERT:**

```sql
-- Auto-increment in action
INSERT INTO orders (customer_id, order_date) 
VALUES (101, '2025-10-04');
-- order_id is automatically assigned
```

## Dropping and Renaming Tables/Columns

### Dropping Tables

Permanently removes a table and all its data.

**Basic DROP TABLE:**

```sql
DROP TABLE employees;
```

**With IF EXISTS:**

```sql
DROP TABLE IF EXISTS temporary_data;
```

**Considerations:**

- Cannot be undone
- Foreign key constraints may prevent dropping referenced tables
- Triggers and indexes associated with the table are also dropped

### Renaming Tables

Changes the name of an existing table.

**Basic RENAME:**

```sql
ALTER TABLE employees RENAME TO staff_members;
```

**Example workflow:**

```sql
-- Check if table exists first
SELECT name FROM sqlite_master WHERE type='table' AND name='old_name';

-- Rename the table
ALTER TABLE old_name RENAME TO new_name;
```

### Renaming Columns

Available in SQLite 3.25.0 and later.

**Basic column rename:**

```sql
ALTER TABLE employees RENAME COLUMN phone TO phone_number;
```

**Example:**

```sql
-- Rename multiple columns (requires multiple statements)
ALTER TABLE products RENAME COLUMN desc TO description;
ALTER TABLE products RENAME COLUMN qty TO quantity;
```

### Dropping Columns

Available in SQLite 3.35.0 and later.

**Basic column drop:**

```sql
ALTER TABLE employees DROP COLUMN middle_name;
```

**Restrictions:**

- Cannot drop primary key columns
- Cannot drop columns that are part of a foreign key constraint
- Cannot drop columns if the table has triggers or views that reference the column

### Recreating Tables (for older SQLite versions)

For versions before 3.35.0, modifying table structure requires recreation:

```sql
-- Step 1: Create new table with desired structure
CREATE TABLE employees_new (
    employee_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    -- 'middle_name' column removed
    email TEXT,
    hire_date TEXT
);

-- Step 2: Copy data from old table
INSERT INTO employees_new 
SELECT employee_id, first_name, last_name, email, hire_date 
FROM employees;

-- Step 3: Drop old table
DROP TABLE employees;

-- Step 4: Rename new table
ALTER TABLE employees_new RENAME TO employees;

-- Step 5: Recreate indexes, triggers, and views if any
```

## Schema Information Queries

SQLite stores schema information in the `sqlite_master` table.

**View all tables:**

```sql
SELECT name FROM sqlite_master WHERE type='table';
```

**View table structure:**

```sql
PRAGMA table_info(employees);
```

**View foreign keys:**

```sql
PRAGMA foreign_key_list(orders);
```

**View indexes:**

```sql
PRAGMA index_list(employees);
```

**Get CREATE TABLE statement:**

```sql
SELECT sql FROM sqlite_master WHERE type='table' AND name='employees';
```

## Transaction Control with DDL

DDL statements in SQLite are transactional and can be rolled back:

```sql
BEGIN TRANSACTION;

CREATE TABLE test_table (
    id INTEGER PRIMARY KEY,
    data TEXT
);

-- If something goes wrong
ROLLBACK;  -- Table creation is undone

-- Or if everything is fine
COMMIT;  -- Table creation is finalized
```

**Key points:**

- Multiple DDL operations can be grouped in a single transaction
- Improves performance for bulk schema changes
- Provides atomicity for related schema modifications

**Example:**

```sql
BEGIN TRANSACTION;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE INDEX idx_customer_orders ON orders(customer_id);

COMMIT;
```

---

**Important related topics:** Data Manipulation Language (DML) for working with data in these tables, Indexes for optimizing query performance, Views for creating virtual tables, Triggers for automating responses to data changes, and Database normalization principles for effective schema design.

---

