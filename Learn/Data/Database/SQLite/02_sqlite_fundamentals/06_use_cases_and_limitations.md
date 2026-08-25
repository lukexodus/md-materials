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

