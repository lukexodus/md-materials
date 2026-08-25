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

