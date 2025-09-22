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