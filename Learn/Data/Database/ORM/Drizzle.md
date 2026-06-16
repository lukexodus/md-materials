# The Drizzle ORM Engineering Handbook

> A production-oriented reference for backend engineers building real systems with TypeScript, PostgreSQL, and Drizzle ORM.

---

## Table of Contents

| Part | Title | Topics |
|------|-------|--------|
| 1  | **Database Foundations** | Tables, keys, indexes, transactions, ACID, isolation, connections, migrations, joins, CTEs, window functions |
| 2  | **ORM Fundamentals** | What ORMs are, Active Record vs Data Mapper, Drizzle vs Prisma vs TypeORM vs Kysely |
| 3  | **Drizzle Architecture** | Core design principles, type inference, SQL compilation, schema-first development |
| 4  | **Project Setup** | Installation, configuration, PostgreSQL/MySQL/SQLite/Neon/Turso/PlanetScale/Supabase |
| 5  | **Schema Design** | Column types, constraints, indexes, PKs, FKs, enums, JSONB, arrays, generated columns |
| 6  | **Relations** | One-to-one, one-to-many, many-to-many, self-referencing, RBAC schema |
| 7  | **Querying Data** | Select, insert, update, delete, filtering, pagination, aggregations, JOINs, CTEs, window functions |
| 8  | **Transactions** | Atomicity, rollback, savepoints, isolation levels, real-world workflows |
| 9  | **Migrations** | Schema evolution, safe vs dangerous patterns, rollback strategies, drift detection |
| 10 | **Drizzle Kit Deep Dive** | generate, migrate, push, pull, check, studio — internals and workflows |
| 11 | **Performance Engineering** | N+1 queries, indexing strategy, EXPLAIN ANALYZE, pool sizing, generated SQL audit |
| 12 | **Framework Integration** | Fastify, tRPC, NestJS, Next.js, repository pattern, transaction boundaries |
| 13 | **Validation** | drizzle-zod, Zod schemas, validation layers, where validation belongs |
| 14 | **Authentication & Authorization** | Sessions, MFA schema, multi-tenant architecture, RBAC queries |
| 15 | **Production Architecture** | Clean architecture, modular monolith, service layer, repository pattern |
| 16 | **Testing** | Unit tests, integration tests, transaction-based isolation, Testcontainers, seed data |
| 17 | **Advanced PostgreSQL** | JSONB, arrays, full-text search, enums, partitioning, pgvector |
| 18 | **Real-World Case Study** | Complete DTS schema, document filing service, audit chain |
| 19 | **Common Pitfalls** | Beginner, intermediate, scaling, migration, type-safety mistakes |
| 20 | **Production Checklist** | Development, schema, migration, performance, security, deployment |
| 21 | **Mastery Roadmap** | Beginner → Intermediate → Advanced → Production Expert |

---

> **Accuracy labeling in this document:**
> - `[Inference]` — logically reasoned from known facts, not directly confirmed
> - `[Speculation]` — unconfirmed possibility
> - `[Unverified]` — no reliable source available
>
> LLM behavior claims include disclaimers where present. Library behavior described reflects drizzle-orm stable API as of the knowledge cutoff; always verify against the official docs at [orm.drizzle.team](https://orm.drizzle.team).

---

# The Drizzle ORM Engineering Handbook

> A production-oriented reference for backend engineers building real systems.

---

# Part 1: Database Foundations

Before touching a single line of Drizzle code, you need a working mental model of the database beneath it. Drizzle is a thin, transparent layer over SQL — which means your ability to use it well is directly proportional to your understanding of relational databases. This section teaches everything you need.

---

## 1.1 What Is a Relational Database?

A **relational database** is a system for storing structured data in a way that enforces relationships between pieces of data. The word *relational* comes from the mathematical concept of a **relation** — a set of tuples with named attributes — formalized by E.F. Codd in 1970.

The key insight of the relational model: data is organized into **tables** (relations), and relationships between data are expressed through **shared values** (keys), not through pointers or embedding.

```
┌─────────────────────────────────────────────────────────────┐
│ WHY THIS MATTERS                                            │
│                                                             │
│ Before relational databases, data was stored in:           │
│ • Hierarchical models (parent → child trees)               │
│ • Network models (explicit pointer graphs)                  │
│                                                             │
│ These were hard to query flexibly. Codd's insight:         │
│ "Store facts. Derive relationships at query time."          │
│ This is why SQL uses JOINs instead of pointers.             │
└─────────────────────────────────────────────────────────────┘
```

Modern relational databases include:

| Database      | Primary Use Case                       |
| ------------- | -------------------------------------- |
| PostgreSQL    | General-purpose, advanced features     |
| MySQL/MariaDB | Web applications, wide hosting support |
| SQLite        | Embedded, single-file, serverless      |
| SQL Server    | Enterprise, Windows ecosystems         |
| Oracle        | Enterprise, legacy systems             |

---

## 1.2 Tables, Rows, and Columns

### Tables

A **table** (formally: a *relation*) is the fundamental unit of storage. Think of it as a spreadsheet with strictly enforced rules.

Each table:
- Has a name unique within a database
- Has a fixed set of named **columns** (the schema)
- Contains zero or more **rows** (the data)

```
TABLE: users

┌──────┬──────────────────────┬─────────────────────────────┬────────────────┐
│  id  │        email         │            name             │   created_at   │
├──────┼──────────────────────┼─────────────────────────────┼────────────────┤
│  1   │ alice@example.com    │ Alice Liddell               │ 2024-01-15     │
│  2   │ bob@example.com      │ Bob Marley                  │ 2024-01-16     │
│  3   │ carol@example.com    │ Carol Danvers               │ 2024-01-17     │
└──────┴──────────────────────┴─────────────────────────────┴────────────────┘
  ↑                                                                ↑
  column                                                         column
  (4 columns total)
  
  Each horizontal line = 1 row
```

### Columns

A **column** defines a named attribute with a fixed data type. Every row must supply a value for every column (unless the column is nullable).

**Column properties you always define:**
- **Name** — must be unique within the table
- **Data type** — constrains what values are allowed (TEXT, INTEGER, BOOLEAN, TIMESTAMP, etc.)
- **Nullability** — whether `NULL` (absence of value) is permitted
- **Default** — value used when none is supplied

### Rows

A **row** (formally: a *tuple*) is a single record — one set of values, one per column. Rows have no inherent order in a relational database. The order you see results in depends on `ORDER BY` — not storage order.

> **Common misconception:** "The order I inserted rows is the order they come out." This is false. Without `ORDER BY`, result order is undefined.

---

## 1.3 Data Types

Data types are the database's mechanism for enforcing integrity at the storage level. Choosing the wrong type causes subtle bugs, performance issues, and wasted storage.

### Core types (common across databases)

| Category   | Types                                      | Notes                                           |
|------------|--------------------------------------------|-------------------------------------------------|
| Integer    | `SMALLINT`, `INTEGER`, `BIGINT`            | 2/4/8 bytes. Use `BIGINT` for IDs at scale.     |
| Decimal    | `NUMERIC(p,s)`, `DECIMAL`                  | Exact. Use for money. Never use FLOAT for money.|
| Float      | `REAL`, `DOUBLE PRECISION`                 | Approximate. Use for scientific data.           |
| Text       | `VARCHAR(n)`, `TEXT`, `CHAR(n)`            | `TEXT` is fine in PostgreSQL; no perf penalty.  |
| Boolean    | `BOOLEAN`                                  | TRUE/FALSE/NULL                                 |
| Date/Time  | `DATE`, `TIME`, `TIMESTAMP`, `INTERVAL`    | Always store timestamps in UTC.                 |
| UUID       | `UUID`                                     | 128-bit globally unique identifier.             |
| Binary     | `BYTEA` (PG), `BLOB` (SQLite/MySQL)        | Store files in object storage, not here.        |
| JSON       | `JSON`, `JSONB` (PG)                       | `JSONB` is indexable; prefer it over `JSON`.    |

### PostgreSQL-specific types (important for Drizzle users)

| Type        | Purpose                                           |
|-------------|---------------------------------------------------|
| `SERIAL`    | Auto-incrementing integer (old style)             |
| `BIGSERIAL` | Auto-incrementing bigint                          |
| `ENUM`      | A fixed set of string values                      |
| `ARRAY`     | Array of any base type                            |
| `JSONB`     | Binary JSON with indexing support                 |
| `TSVECTOR`  | Full-text search document                         |
| `INET`      | IP address                                        |
| `CIDR`      | IP network range                                  |

**Production rule:** Use the most specific type possible. `TEXT` for a field that should be an email lets garbage in. `VARCHAR(255)` is a cargo-cult from MySQL days — in PostgreSQL, `TEXT` with a `CHECK` constraint is cleaner.

---

## 1.4 Primary Keys

A **primary key** (PK) is a column (or combination of columns) that **uniquely identifies every row** in a table. It is the row's permanent address.

Rules enforced by the database:
1. **Uniqueness**: no two rows can share the same PK value
2. **Non-null**: PK columns cannot be NULL
3. **Immutability** (by convention): once assigned, PKs should not change

### Natural vs Surrogate Keys

**Natural key**: a key derived from real-world data (email address, social security number, ISBN).

**Surrogate key**: an artificial key with no business meaning (auto-increment integer, UUID).

```
┌──────────────────┬─────────────────────────────────────────────────┐
│   Key Type       │ Tradeoffs                                        │
├──────────────────┼─────────────────────────────────────────────────┤
│ Natural key      │ + Human-readable                                 │
│                  │ + No join needed to get meaning                  │
│                  │ - Real data changes (emails, usernames)          │
│                  │ - Couples schema to business rules               │
│                  │ - Often longer, slower to index                  │
├──────────────────┼─────────────────────────────────────────────────┤
│ Auto-increment   │ + Simple, compact (4 or 8 bytes)                 │
│ integer (SERIAL) │ + Sequential = good for B-tree index             │
│                  │ - Exposes row count/insertion order              │
│                  │ - Doesn't work well across distributed systems   │
├──────────────────┼─────────────────────────────────────────────────┤
│ UUID v4          │ + Globally unique, safe to generate client-side  │
│                  │ + Doesn't reveal business info                   │
│                  │ - 16 bytes vs 4/8 bytes                          │
│                  │ - Random = poor B-tree locality (index bloat)    │
├──────────────────┼─────────────────────────────────────────────────┤
│ UUIDv7 / ULID    │ + Globally unique + time-ordered                 │
│                  │ + Better index locality than UUIDv4              │
│                  │ - Relatively newer, less universal support       │
└──────────────────┴─────────────────────────────────────────────────┘
```

**Production recommendation**: Use `BIGSERIAL` (auto-increment bigint) as the PK for internal tables, and UUIDv7 or ULID when you need a globally unique, distributable, or publicly exposed identifier. Never expose sequential integer IDs in public APIs — they reveal your data volume and enable enumeration attacks.

### Composite Primary Keys

A **composite key** is a primary key made from two or more columns. Common in junction tables.

```sql
-- A user can belong to many organizations, 
-- an organization has many users.
-- The combination (user_id, org_id) uniquely identifies the relationship.
CREATE TABLE organization_members (
  user_id BIGINT NOT NULL,
  org_id  BIGINT NOT NULL,
  role    TEXT NOT NULL,
  PRIMARY KEY (user_id, org_id)
);
```

---

## 1.5 Foreign Keys

A **foreign key** (FK) is a column (or group of columns) in one table that references the primary key of another table. It enforces **referential integrity** — the database prevents you from creating orphaned records.

```
TABLE: users                    TABLE: posts
┌────┬──────────┐               ┌────┬──────────┬─────────┐
│ id │  email   │               │ id │  title   │ user_id │
├────┼──────────┤               ├────┼──────────┼─────────┤
│  1 │ alice@…  │ ◄─────────────│  1 │ Hello!   │    1    │
│  2 │ bob@…    │               │  2 │ World    │    1    │
└────┴──────────┘               └────┴──────────┴─────────┘
                                         FK on user_id → users.id
```

### Referential Actions

When a referenced row is deleted or updated, the database needs to know what to do with rows that reference it:

| Action        | Description                                                    |
|---------------|----------------------------------------------------------------|
| `RESTRICT`    | Block the delete/update if referenced rows exist (default)     |
| `CASCADE`     | Delete/update the referencing rows automatically               |
| `SET NULL`    | Set the FK column to NULL                                      |
| `SET DEFAULT` | Set the FK column to its default value                         |
| `NO ACTION`   | Like RESTRICT but checked at end of transaction                |

```sql
-- If a user is deleted, all their posts are deleted too.
CREATE TABLE posts (
  id      BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title   TEXT NOT NULL
);
```

**Common production mistake**: Using `CASCADE` without thinking through the implications. If a user deletes their account and their user_id cascades to orders, invoices, and audit logs — you may be deleting financial and compliance records. Think carefully. Often `SET NULL` or soft-deletion is safer.

---

## 1.6 Constraints

A **constraint** is a rule that the database enforces on data. Constraints are your last line of defense against bad data — they fire even if your application has a bug.

| Constraint        | Purpose                                               |
|-------------------|-------------------------------------------------------|
| `PRIMARY KEY`     | Uniqueness + not null for the key column(s)           |
| `UNIQUE`          | Uniqueness across a column or combination of columns  |
| `NOT NULL`        | Disallows NULL in the column                          |
| `FOREIGN KEY`     | Referential integrity                                 |
| `CHECK`           | Arbitrary boolean expression on column values         |
| `EXCLUSION`       | (PostgreSQL) Prevents overlapping ranges              |

### CHECK Constraints

```sql
CREATE TABLE products (
  id       BIGSERIAL PRIMARY KEY,
  name     TEXT NOT NULL,
  price    NUMERIC(10,2) NOT NULL,
  quantity INTEGER NOT NULL,
  CONSTRAINT price_positive    CHECK (price > 0),
  CONSTRAINT quantity_positive CHECK (quantity >= 0)
);
```

**Production rule**: Put CHECK constraints on anything that has a domain invariant. `status TEXT CHECK (status IN ('active','suspended','deleted'))` is better than just `TEXT`. Use ENUMs if the set is truly fixed; use CHECK if you want flexibility.

---

## 1.7 Indexes

An **index** is a separate data structure that the database maintains alongside your table to make certain queries faster. Think of it as the index at the back of a book — instead of reading every page to find "foreign key", you jump directly to the right page.

### Why Indexes Exist

Without an index, finding a row requires a **full table scan** (reading every row). For a table with 10 million rows, this means reading millions of rows to find one.

With an index on the searched column, the database jumps directly to the matching rows.

### How B-Tree Indexes Work (the default)

Most database indexes are **B-trees** (balanced trees). The tree maintains sorted order of the indexed values, allowing:
- Exact lookups: `WHERE id = 42` → O(log n)
- Range scans: `WHERE created_at > '2024-01-01'` → O(log n + k)
- Sorted retrieval: `ORDER BY email` may use index instead of sort

```
        [M]
       /   \
    [D-H]  [R-Z]
    / \      / \
  [D] [H] [R] [T-Z]
   ↑
   Leaf nodes contain row pointers
```

### Index Types in PostgreSQL

| Index Type | Use Case                                                    |
|------------|-------------------------------------------------------------|
| B-Tree     | Default. Equality, range, sort, prefix matches.             |
| Hash       | Equality only. Rarely used.                                 |
| GIN        | JSONB, arrays, full-text search.                           |
| GiST       | Geometric types, full-text, range overlap.                 |
| BRIN       | Very large tables with natural sort order (time-series).    |
| SP-GiST    | Non-balanced tree structures (IP addresses, geometry).      |

### The Index Tradeoff

Indexes are not free:

```
┌─────────────────────────────────────────────────────────────┐
│ READ performance  ████████████████████ +80%                 │
│ WRITE performance ████████            -20% to -40%          │
│ Storage           ████████            +10% to +30%          │
└─────────────────────────────────────────────────────────────┘
```

Every index you add speeds up SELECT but slows down INSERT, UPDATE, and DELETE. For write-heavy workloads, over-indexing is a real problem.

### What to Index

**Always index:**
- Primary key columns (automatic)
- Foreign key columns (not automatic! This is a common mistake)
- Columns used frequently in WHERE clauses
- Columns used in JOIN conditions
- Columns used in ORDER BY on large result sets

**Consider indexing:**
- Columns in `LIKE` queries with prefix matching (`WHERE name LIKE 'Al%'`)
- Partial indexes for filtered subsets (`WHERE deleted_at IS NULL`)
- Composite indexes for multi-column WHERE clauses

### Composite Indexes and Column Order

A composite index on `(a, b, c)` can answer queries on:
- `WHERE a = ?`
- `WHERE a = ? AND b = ?`
- `WHERE a = ? AND b = ? AND c = ?`

But **cannot** efficiently answer `WHERE b = ?` alone. The leftmost column must be used.

---

## 1.8 Unique Constraints

A **UNIQUE constraint** ensures no two rows share the same value in a column (or combination of columns).

```sql
-- Single column unique
CREATE TABLE users (
  id    BIGSERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL
);

-- Composite unique: a user can only have one active token type at a time
CREATE TABLE auth_tokens (
  id        BIGSERIAL PRIMARY KEY,
  user_id   BIGINT NOT NULL REFERENCES users(id),
  type      TEXT NOT NULL,
  token     TEXT NOT NULL,
  UNIQUE(user_id, type)
);
```

UNIQUE constraints automatically create an index. They differ from PRIMARY KEY in that:
- A table can have multiple UNIQUE constraints
- UNIQUE columns can contain NULL (and NULLs don't conflict with each other)

---

## 1.9 Transactions

A **transaction** is a sequence of database operations that the database treats as a single unit of work. Either all operations succeed together, or none of them do.

### The Banking Example (Why Transactions Exist)

```
Transfer $100 from Alice to Bob:
  1. Subtract $100 from Alice's balance
  2. Add $100 to Bob's balance

Without transactions:
  - Step 1 succeeds
  - Server crashes
  - Step 2 never runs
  - $100 vanishes
```

With a transaction, the crash causes both operations to be rolled back. The database is left in the state before the transfer started.

### Transaction Lifecycle

```
BEGIN
  ├─ Execute SQL statement 1
  ├─ Execute SQL statement 2  ← if any fails...
  ├─ Execute SQL statement 3
  └─ COMMIT  ←── all changes become permanent
  
  OR
  
  └─ ROLLBACK  ←── all changes are discarded
```

### ACID Properties

**ACID** is the set of guarantees that make transactions reliable:

| Property    | Meaning                                                                           |
|-------------|-----------------------------------------------------------------------------------|
| **Atomic**  | All operations succeed or all fail. No partial application.                       |
| **Consistent** | A transaction brings the database from one valid state to another. All constraints hold. |
| **Isolated** | Concurrent transactions don't see each other's intermediate states.             |
| **Durable** | Once committed, changes survive crashes (written to disk/WAL).                    |

---

## 1.10 Isolation Levels

**Isolation** is the I in ACID. Perfect isolation would mean concurrent transactions behave as if they ran one at a time — but this is expensive. Databases provide a spectrum of isolation levels.

### Read Anomalies (What Can Go Wrong)

| Anomaly               | Description                                                               |
|-----------------------|---------------------------------------------------------------------------|
| **Dirty Read**        | Transaction A reads data written by uncommitted Transaction B             |
| **Non-repeatable Read** | Transaction A reads the same row twice, gets different values (B committed between) |
| **Phantom Read**      | Transaction A reads a set of rows twice; B inserted/deleted rows between   |
| **Lost Update**       | Two transactions read-then-write the same row; one overwrites the other   |

### Isolation Levels (SQL Standard)

| Level              | Dirty Read | Non-repeatable | Phantom | Notes                          |
|--------------------|-----------|----------------|---------|--------------------------------|
| READ UNCOMMITTED   | Possible  | Possible       | Possible | Rarely used; risky             |
| READ COMMITTED     | Prevented | Possible       | Possible | PostgreSQL default             |
| REPEATABLE READ    | Prevented | Prevented      | Possible | MySQL InnoDB default           |
| SERIALIZABLE       | Prevented | Prevented      | Prevented | Safest; highest cost           |

```
┌─────────────────────────────────────────────────────────────┐
│ PostgreSQL note: Its READ COMMITTED uses MVCC (Multi-Version│
│ Concurrency Control) — readers don't block writers and vice  │
│ versa. This is better than the SQL standard's definition.    │
└─────────────────────────────────────────────────────────────┘
```

**Production rule**: Use READ COMMITTED (the default) for most operations. Use REPEATABLE READ or SERIALIZABLE only when your transaction logic truly requires it — for financial operations, inventory reservations, or anywhere a lost-update or phantom-read would cause incorrect results.

---

## 1.11 Locks and Concurrency

Databases use locks to coordinate concurrent access.

### Row-Level Locks

```sql
-- Optimistic: check after the fact
SELECT * FROM accounts WHERE id = 1;
UPDATE accounts SET balance = balance - 100 WHERE id = 1 AND balance >= 100;
-- Check rows affected. If 0, someone else changed it.

-- Pessimistic: lock during read
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;
-- Now we hold the lock. Other transactions wait.
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
COMMIT; -- lock released
```

**Optimistic concurrency** assumes conflicts are rare; check at update time.
**Pessimistic concurrency** assumes conflicts are likely; lock immediately.

The Batac City DTS (your project) uses pessimistic locking — a sound choice for document workflows where conflicts are expected and data integrity is critical.

---

## 1.12 Query Execution and the Query Planner

When you send a SQL query, the database goes through several phases before returning results:

```
Your SQL Query
     │
     ▼
┌─────────────┐
│   Parser    │  Validates syntax, builds parse tree
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Analyzer   │  Resolves names, checks semantics
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Planner   │  Chooses the optimal execution strategy
│  / Optimizer│  (which indexes to use, join order, etc.)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Executor   │  Actually runs the plan, returns rows
└─────────────┘
```

### The Query Planner Is Your Friend

The planner chooses between multiple strategies. Example for a simple query:

```sql
SELECT * FROM users WHERE email = 'alice@example.com';
```

Options the planner considers:
1. **Sequential scan**: read every row, filter in-memory
2. **Index scan**: use the index on `email` to jump to the row
3. **Index-only scan**: if all needed columns are in the index, skip the table entirely

The planner makes this decision based on **statistics** it maintains about your data (how many rows, how many distinct values, distribution of values). This is why `ANALYZE` (which updates statistics) matters after large data changes.

### EXPLAIN and EXPLAIN ANALYZE

```sql
-- See the plan (no execution)
EXPLAIN SELECT * FROM users WHERE email = 'alice@example.com';

-- See the plan AND run the query to get real timing
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'alice@example.com';
```

Key things to look for in EXPLAIN output:
- `Seq Scan` — full table scan; is this expected?
- `Index Scan` — using an index (good)
- `Bitmap Heap Scan` — using index for many rows (OK for range queries)
- `Hash Join`, `Nested Loop`, `Merge Join` — join strategies
- `cost=X..Y` — estimated cost (arbitrary units)
- `rows=N` — estimated rows
- `actual time=X..Y` — real time (ANALYZE only)
- `Rows Removed by Filter: N` — how much work was wasted by a poor filter

---

## 1.13 Database Connections and Connection Pools

### What Is a Database Connection?

A **connection** is a persistent, stateful channel between your application and the database server. Establishing one is expensive:
- TCP handshake
- Authentication
- Session initialization
- Memory allocation on the server side

A single connection is also synchronous — it processes one query at a time.

### Connection Pools

A **connection pool** is a cache of pre-established database connections managed for reuse. Instead of opening and closing a connection per query, you borrow one from the pool and return it when done.

```
Application
  │
  │  "I need to query the DB"
  ▼
┌───────────────────────────────────────┐
│          Connection Pool              │
│  ┌────┐  ┌────┐  ┌────┐  ┌────┐     │
│  │conn│  │conn│  │conn│  │conn│ ...  │
│  │ 1  │  │ 2  │  │ 3  │  │ 4  │     │
│  └────┘  └────┘  └────┘  └────┘     │
└───────────────────────────────────────┘
           │
           ▼
     PostgreSQL Server
```

### Pool Configuration Parameters

| Parameter       | Meaning                                         | Typical Value        |
|-----------------|-------------------------------------------------|----------------------|
| `min`           | Minimum connections to keep alive               | 2–5                  |
| `max`           | Maximum connections (caps server load)          | 10–50 (context-dependent) |
| `idleTimeoutMs` | How long idle connections are held before close | 10,000–30,000ms      |
| `connectionTimeoutMs` | How long to wait for an available connection | 5,000–30,000ms   |

**PostgreSQL limit**: PostgreSQL has a maximum connection limit (default 100). With multiple application servers, this adds up fast. Use `PgBouncer` or `pgpool-II` as a pooling proxy between your app and Postgres when scaling.

**Serverless rule**: In serverless environments (AWS Lambda, Vercel, etc.), each function invocation may create a new connection. Use connection pooling services like Neon's connection pooling, PlanetScale's proxy, or `@neondatabase/serverless` with HTTP-based connections.

---

## 1.14 Schema Evolution and Migrations

### What Is a Migration?

A **database migration** is a versioned, repeatable script that transforms a database schema from one state to another. Like version control for your database structure.

```
Version 1: users table with (id, email, name)
    │
    │  Migration 002: add created_at column
    ▼
Version 2: users table with (id, email, name, created_at)
    │
    │  Migration 003: add organizations table, add org_id to users
    ▼
Version 3: users, organizations tables; users has org_id FK
```

### Why Migrations Exist

Without migrations:
- How do you reproduce the schema on a new developer's machine?
- How do you apply schema changes to production without downtime?
- How do you roll back a bad schema change?
- How do you audit what changed and when?

Migrations answer all of these.

### Forward vs Rollback Migrations

A **forward migration** applies a change (the typical direction).
A **rollback migration** undoes the change.

Many teams write both. In practice, rolling back a migration that added data or changed data types is often destructive — plan accordingly.

### Migration Safety

Some migrations are safe; others are dangerous:

```
SAFE (non-destructive):
  + Adding a new nullable column
  + Adding a new table
  + Adding a new index (CONCURRENTLY in PostgreSQL)
  + Adding a new constraint with a default value

DANGEROUS (may block or destroy data):
  - Dropping a column
  - Renaming a column
  - Changing a column type
  - Adding a NOT NULL constraint to a column with existing NULLs
  - Adding a UNIQUE constraint without CONCURRENTLY
  - Dropping a table
```

For high-traffic production systems, even "safe" operations can be dangerous if they take out a lock. PostgreSQL's `CREATE INDEX CONCURRENTLY` exists precisely to add indexes without blocking writes.

---

## 1.15 Normalization and Denormalization

### Normalization

**Normalization** is the process of organizing data to reduce redundancy and improve integrity. It's defined through "normal forms" (1NF, 2NF, 3NF, BCNF, etc.).

In practice, most teams aim for **3NF** (third normal form):
- Every column depends on the key (1NF)
- Every column depends on the whole key (2NF)
- Every column depends on nothing but the key (3NF)

**Example of a poorly normalized table:**

```
order_items:
┌──────────┬──────────────┬────────────────┬──────────────┐
│ order_id │ product_id   │ product_name   │ category_name│
├──────────┼──────────────┼────────────────┼──────────────┤
│  100     │  5           │ Widget         │ Hardware     │
│  101     │  5           │ Widget         │ Hardware     │
└──────────┴──────────────┴────────────────┴──────────────┘
```

`product_name` and `category_name` are repeated. If the product name changes, you must update it in every `order_items` row.

**Normalized:**

```
products:           order_items:          categories:
┌────┬────────┬──────┐  ┌──────────┬──────────┐  ┌────┬──────────┐
│ id │  name  │cat_id│  │ order_id │product_id│  │ id │   name   │
├────┼────────┼──────┤  ├──────────┼──────────┤  ├────┼──────────┤
│  5 │ Widget │  3   │  │   100    │    5     │  │  3 │ Hardware │
└────┴────────┴──────┘  └──────────┴──────────┘  └────┴──────────┘
```

### Denormalization

**Denormalization** is the intentional introduction of redundancy for performance. Common in read-heavy systems and analytics.

Example: storing `user_display_name` on a `posts` table even though it exists on `users`. This avoids a JOIN on every post fetch, at the cost of needing to keep the data in sync.

**When to denormalize:**
- Read performance is critical and JOINs are provably slow
- The joined data is effectively immutable (user's join date)
- You have a CQRS/read-model architecture where read models are built separately

---

## 1.16 JOINs

**JOINs** combine rows from two or more tables based on a related column. They are how you reassemble normalized data at query time.

```
INNER JOIN  — only rows with matches in both tables
LEFT JOIN   — all rows from left, matched rows from right (nulls if no match)
RIGHT JOIN  — all rows from right, matched rows from left
FULL OUTER JOIN — all rows from both, nulls where no match
CROSS JOIN  — cartesian product (every combination)
```

```
users:          posts:              INNER JOIN result:
┌────┬──────┐  ┌────┬────────┬────┐  ┌────┬──────┬────────┐
│ id │ name │  │ id │ title  │uid │  │uid │ name │ title  │
├────┼──────┤  ├────┼────────┼────┤  ├────┼──────┼────────┤
│  1 │Alice │  │ 10 │Hello!  │ 1  │  │  1 │Alice │Hello!  │
│  2 │ Bob  │  │ 11 │World   │ 1  │  │  1 │Alice │World   │
│  3 │Carol │  └────┴────────┴────┘  └────┴──────┴────────┘
└────┴──────┘
               (Carol has no posts, so she's excluded from INNER JOIN)

LEFT JOIN result:
┌────┬──────┬────────┐
│uid │ name │ title  │
├────┼──────┼────────┤
│  1 │Alice │Hello!  │
│  1 │Alice │World   │
│  3 │Carol │  NULL  │  ← Carol included, title is NULL
└────┴──────┴────────┘
```

### JOIN Performance

JOINs have three strategies the planner can choose:

| Strategy       | When Used                                           |
|----------------|-----------------------------------------------------|
| Nested Loop    | One table is small; uses index on the other          |
| Hash Join      | Larger tables; builds hash table from smaller side   |
| Merge Join     | Both sides are pre-sorted on the join key            |

**N+1 problem**: The classic ORM performance bug. You fetch 100 users, then for each user you make a separate query for their posts. That's 101 queries instead of 1 JOIN. We'll address this extensively in Part 11.

---

## 1.17 Aggregations and GROUP BY

**Aggregation** computes a single value from a set of rows:

```sql
SELECT 
  status,
  COUNT(*)           AS total,
  SUM(amount)        AS revenue,
  AVG(amount)        AS avg_amount,
  MAX(created_at)    AS latest
FROM orders
GROUP BY status;
```

`HAVING` filters groups (like `WHERE` but for grouped results):

```sql
SELECT user_id, COUNT(*) AS order_count
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 10;  -- only users with >10 orders
```

---

## 1.18 CTEs (Common Table Expressions)

A **CTE** is a named, temporary result set used within a query. Makes complex queries readable.

```sql
WITH active_users AS (
  SELECT id, email FROM users WHERE status = 'active'
),
recent_orders AS (
  SELECT user_id, SUM(amount) AS total
  FROM orders
  WHERE created_at > NOW() - INTERVAL '30 days'
  GROUP BY user_id
)
SELECT 
  au.email,
  COALESCE(ro.total, 0) AS monthly_spend
FROM active_users au
LEFT JOIN recent_orders ro ON ro.user_id = au.id;
```

**Recursive CTEs** traverse tree structures (org charts, threaded comments, bill of materials):

```sql
WITH RECURSIVE subordinates AS (
  -- Base case: the manager
  SELECT id, name, manager_id FROM employees WHERE id = 1
  
  UNION ALL
  
  -- Recursive case: their direct reports
  SELECT e.id, e.name, e.manager_id
  FROM employees e
  JOIN subordinates s ON e.manager_id = s.id
)
SELECT * FROM subordinates;
```

---

## 1.19 Window Functions

**Window functions** compute values across a set of rows related to the current row, without collapsing them into a single row like `GROUP BY` does.

```sql
SELECT 
  user_id,
  amount,
  created_at,
  ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS order_seq,
  SUM(amount) OVER (PARTITION BY user_id) AS user_total,
  RANK() OVER (ORDER BY amount DESC) AS global_rank
FROM orders;
```

Common window functions: `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LAG()`, `LEAD()`, `SUM()`, `AVG()`, `FIRST_VALUE()`, `LAST_VALUE()`, `NTH_VALUE()`.

---

## 1.20 Views and Materialized Views

### Views

A **view** is a named, stored SQL query. Querying a view is like querying a virtual table.

```sql
CREATE VIEW active_users AS
  SELECT * FROM users WHERE deleted_at IS NULL;

-- Now query it like a table:
SELECT * FROM active_users WHERE email LIKE '%@example.com';
```

**Purpose**: Simplify complex queries; provide an abstraction layer over raw tables; restrict column access for security.

**Key limitation**: Regular views are recomputed on every query. They do not store data.

### Materialized Views

A **materialized view** stores the query result on disk. Dramatically faster to query, but must be explicitly refreshed.

```sql
CREATE MATERIALIZED VIEW monthly_revenue AS
  SELECT 
    DATE_TRUNC('month', created_at) AS month,
    SUM(amount) AS total
  FROM orders
  WHERE status = 'completed'
  GROUP BY DATE_TRUNC('month', created_at);

-- Refresh the materialized view (can be scheduled):
REFRESH MATERIALIZED VIEW monthly_revenue;

-- PostgreSQL 9.4+: refresh without blocking reads:
REFRESH MATERIALIZED VIEW CONCURRENTLY monthly_revenue;
```

---

## 1.21 Stored Procedures and Triggers

### Stored Procedures

A **stored procedure** is a named block of procedural SQL code stored in the database.

**When to use them:**
- Complex, multi-step operations that must be atomic
- Performance-critical operations that save round-trips
- Encapsulating logic that multiple apps must share

**When NOT to use them (for most backend teams):**
- They live in the database, not in version control
- Hard to test and debug
- Couples business logic to the database
- Difficult to evolve

Modern Drizzle-based architectures generally avoid stored procedures, preferring transactions at the application layer.

### Triggers

A **trigger** is code that runs automatically in response to a database event (INSERT, UPDATE, DELETE, TRUNCATE).

```sql
-- Automatically update updated_at on row change
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

Triggers are useful for audit logging, maintaining denormalized fields, and enforcing complex cross-table constraints. Use them sparingly — they add hidden behavior that's easy to forget.

---

## 1.22 How Modern Backend Applications Interact With Databases

A typical Node.js backend interacts with PostgreSQL through this stack:

```
HTTP Request
     │
     ▼
┌──────────────────────────┐
│   Route Handler          │
│   (Express/Fastify/etc.) │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│   Service / Use Case     │  ← Business logic lives here
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│   Repository / ORM       │  ← Drizzle lives here
│   (Drizzle ORM)          │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│   Database Driver        │  ← pg, mysql2, better-sqlite3
│   + Connection Pool      │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│   PostgreSQL Server      │
└──────────────────────────┘
```

**The round trip:**
1. Application executes a Drizzle query (which compiles to SQL)
2. Driver sends SQL over the connection (from the pool)
3. PostgreSQL parses, plans, and executes the query
4. Results are returned as rows
5. Driver deserializes rows into JavaScript objects
6. Drizzle applies TypeScript types
7. Your code receives typed data

Understanding every layer of this stack is what separates engineers who debug effectively from those who guess.

---

*End of Part 1 — Database Foundations*
# Part 2: ORM Fundamentals

---

## 2.1 What Is an ORM?

An **ORM (Object-Relational Mapper)** is a library that maps between the relational world (tables, rows, columns) and the object-oriented world (classes, instances, properties).

The fundamental tension it addresses:

```
Relational Database          Object-Oriented Code
─────────────────────        ─────────────────────
Tables (relations)    ←───→  Classes
Rows (tuples)         ←───→  Objects / Instances
Columns (attributes)  ←───→  Properties / Fields
Foreign keys          ←───→  References / Associations
JOINs                 ←───→  Navigation (user.posts)
NULL                  ←───→  null / undefined / Optional<T>
```

This mismatch — called the **object-relational impedance mismatch** — is why ORMs exist. Writing SQL by hand for every database operation is tedious, error-prone, and leads to SQL scattered throughout the codebase. ORMs are an attempt to manage that complexity.

---

## 2.2 Problems ORMs Solve

1. **Boilerplate reduction**: CRUD operations (Create, Read, Update, Delete) are repetitive SQL that ORMs abstract away.

2. **Type safety**: Raw SQL strings have no compile-time validation. ORMs (especially Drizzle) bring type safety to database operations.

3. **Schema co-location**: Instead of SQL DDL in migration files and data shapes in TypeScript interfaces separately, ORMs let you define both from one source of truth.

4. **Portability**: In theory, switching databases requires only a driver change, not rewriting queries. (In practice, this is rarely needed.)

5. **Query building**: Constructing dynamic SQL safely (with proper parameterization) is hard. ORMs provide composable query builders.

6. **Relation loading**: Fetching related data (user and their posts) is complex in raw SQL. ORMs provide ergonomic APIs.

---

## 2.3 Problems ORMs Create

No technology is free of tradeoffs. ORMs have well-documented failure modes:

### The "Magic" Problem

ORMs add layers of abstraction. When things go wrong, debugging requires understanding both the ORM and the SQL it generates. Developers who don't understand SQL are helpless when the generated SQL is inefficient.

### Leaky Abstractions

Every ORM abstraction eventually leaks. Complex queries, database-specific features (PostgreSQL's `JSONB`, `LATERAL` joins, `ON CONFLICT`), and performance tuning often require dropping down to raw SQL — defeating the purpose.

### N+1 Query Problem

```javascript
// Fetching 100 users and their posts
const users = await UserModel.findAll(); // 1 query
for (const user of users) {
  const posts = await user.getPosts(); // 100 queries!
}
// Total: 101 queries. Should be 1 JOIN or 2 queries.
```

Traditional ORMs with lazy loading make this painfully easy to introduce accidentally.

### Schema Drift

When the ORM model and the actual database schema diverge, subtle bugs emerge. Migrations must be carefully managed.

### Performance Ceiling

For high-performance operations, raw SQL is almost always faster than ORM-generated SQL. The ORM layer adds parsing, serialization, and abstraction overhead.

---

## 2.4 ORM vs Query Builder vs Raw SQL

| Approach        | Abstraction Level | Type Safety | Flexibility | Dev Speed |
|-----------------|------------------|-------------|-------------|-----------|
| ORM (Active Record) | High          | Medium      | Low         | Fast      |
| ORM (Data Mapper)   | Medium         | Medium-High | Medium      | Fast      |
| Query Builder   | Low-Medium       | High        | High        | Medium    |
| Raw SQL (typed) | None             | With effort | Maximum     | Slow      |

**Drizzle's position**: Drizzle is a **query builder with schema definition** — it sits at the "Low-Medium" abstraction level but achieves "Very High" type safety. This is its core value proposition: you write something that looks like SQL, but it's fully typed.

---

## 2.5 The Active Record Pattern

**Active Record** (popularized by Ruby on Rails) is an ORM pattern where each database table has a corresponding class, and instances of that class represent rows. The class also contains methods for querying and saving.

```javascript
// Active Record style (e.g., Sequelize, TypeORM with AR mode)
const user = await User.findOne({ where: { email: 'alice@example.com' } });
user.name = 'Alice B. Toklas';
await user.save(); // UPDATE users SET name = ? WHERE id = ?

const posts = await user.getPosts(); // Navigates relation
```

**Strengths:**
- Ergonomic for simple CRUD
- Intuitive for beginners

**Weaknesses:**
- Couples domain model to database schema
- Makes testing hard (objects carry database logic)
- Hidden queries from method calls
- Poor for complex queries

---

## 2.6 The Data Mapper Pattern

**Data Mapper** separates the domain object from the database mapping. Objects are plain data containers; a separate "mapper" or "repository" handles persistence.

```javascript
// Data Mapper style (TypeORM with EntityManager, or Drizzle)
// The domain object knows nothing about the database:
class User {
  id: number;
  email: string;
  name: string;
}

// The repository handles persistence:
class UserRepository {
  async findByEmail(email: string): Promise<User | null> {
    const rows = await db
      .select()
      .from(users)
      .where(eq(users.email, email))
      .limit(1);
    return rows[0] ?? null;
  }
}
```

**Strengths:**
- Domain model stays clean
- Easier to test (mock the repository)
- Explicit — no hidden queries

**Weaknesses:**
- More boilerplate
- Steeper initial learning curve

**Drizzle naturally supports the Data Mapper pattern.** Its lack of model classes and explicit query building encourages clean separation.

---

## 2.7 Comparing the Landscape

### Prisma

**Philosophy**: Schema-first, auto-generated client, migrations with a dedicated engine.

```typescript
// Prisma
const user = await prisma.user.findUnique({
  where: { email: 'alice@example.com' },
  include: { posts: true },
});
```

**Strengths:**
- Excellent DX (developer experience)
- Auto-generated types from schema
- Powerful migration system
- Prisma Studio GUI

**Weaknesses:**
- Generated client abstracts away SQL (harder to optimize)
- Binary engine dependency (bundling issues in edge/serverless)
- Limited raw power for complex PostgreSQL queries
- Schema language is separate from TypeScript

### TypeORM

**Philosophy**: Decorator-based, Active Record or Data Mapper, strong TypeScript focus.

```typescript
// TypeORM
@Entity()
class User {
  @PrimaryGeneratedColumn()
  id: number;
  
  @Column({ unique: true })
  email: string;
  
  @OneToMany(() => Post, post => post.user)
  posts: Post[];
}
```

**Strengths:**
- Familiar decorator syntax for OOP developers
- Both Active Record and Data Mapper patterns
- Good for enterprise-style architectures

**Weaknesses:**
- Frequent type issues in practice
- Heavy and complex
- Decorator metadata reflects typescript quirks
- Slow to adopt new features

### Sequelize

**Philosophy**: The original Node.js ORM. Active Record style, wide database support.

**Strengths:**
- Battle-tested, massive ecosystem
- Supports many databases

**Weaknesses:**
- Type safety is bolted on, not native
- Verbose and inconsistent API
- Migrations are manual
- Generally considered outdated for new TypeScript projects

### Kysely

**Philosophy**: A fully type-safe SQL query builder — no schema definition, no migrations, just typed query building.

```typescript
// Kysely
const user = await db
  .selectFrom('users')
  .where('email', '=', 'alice@example.com')
  .selectAll()
  .executeTakeFirst();
```

**Strengths:**
- Excellent type safety
- SQL-idiomatic — if you know SQL, you know Kysely
- Lightweight, no magic
- Works well with separate migration tools

**Weaknesses:**
- No schema definition (you define types manually or generate them)
- No migration system
- Relations require manual JOINs (no `include`-style loading)

### Raw SQL (with pg / mysql2)

```typescript
const { rows } = await pool.query<User>(
  'SELECT * FROM users WHERE email = $1',
  [email]
);
```

**Strengths:**
- Maximum control
- Zero abstraction overhead
- Use any SQL feature

**Weaknesses:**
- No type inference from queries
- Manual type casting
- SQL injection risk if parameterization is forgotten
- Maintenance burden as schema evolves

---

## 2.8 Where Drizzle Sits

```
High Abstraction (Prisma, Sequelize, TypeORM Active Record)
         │
         │  • Generated APIs
         │  • Hidden SQL
         │  • Magic relation loading
         │
         ▼
Medium Abstraction (TypeORM Data Mapper, MikroORM)
         │
         │  • Explicit entity classes
         │  • Unit of Work pattern
         │  • Still hides SQL
         │
         ▼
Low Abstraction / Query Builder (Drizzle, Kysely)
         │
         │  • Schema defined in TypeScript
         │  • Queries look like SQL
         │  • Full type inference
         │  • SQL is explicit, not hidden
         │
         ▼
Raw SQL (pg, mysql2, better-sqlite3)
```

**Drizzle's architectural philosophy, stated explicitly:**

> "Drizzle is SQL with types. It does not try to hide the database. It tries to make SQL type-safe and ergonomic."

Key consequences of this philosophy:

1. **No magic loading**: There's no `user.posts` auto-fetch. Relations are explicit queries.
2. **Generated SQL is readable**: The SQL Drizzle generates is the SQL you'd write by hand.
3. **Schema is TypeScript**: Your schema definition file is your source of truth for both runtime shape and TypeScript types.
4. **Zero runtime overhead from type system**: All type inference is compile-time. At runtime, Drizzle is just constructing strings and passing them to the driver.
5. **Escape hatches are first-class**: `sql` tagged template literal lets you drop to raw SQL within the type system.

---

## 2.9 The SQL-First Philosophy (Why It Matters)

Many ORMs try to let you forget SQL exists. Drizzle makes the opposite bet: developers who understand SQL can use Drizzle's abstractions more effectively, and developers who don't yet understand SQL will be guided toward it.

This creates a virtuous cycle:
- You see the SQL Drizzle generates → you understand what's happening
- You understand what's happening → you can optimize it
- You can optimize it → your application performs well under load

Contrast this with "magic" ORMs, where:
- You call a method and don't know what SQL runs
- Something is slow → you have to reverse-engineer what the ORM did
- You struggle to optimize because the abstraction is in the way

**For production systems**, Drizzle's transparency is a major advantage. When your DBA asks "why is this query doing a sequential scan on 5 million rows?", you can answer directly.

---

*End of Part 2 — ORM Fundamentals*
# Part 3: Drizzle Architecture

---

## 3.1 What Drizzle Is (Precisely)

Drizzle ORM is a **TypeScript-first, SQL-proximate query builder and schema definition toolkit** for relational databases. Despite the "ORM" in its name, it is more accurately described as a typed query builder with schema definition capabilities and an optional migration system.

The repository is split into two main packages:

| Package        | Purpose                                                         |
|----------------|-----------------------------------------------------------------|
| `drizzle-orm`  | The query builder, schema definition, and runtime library       |
| `drizzle-kit`  | CLI tool for migrations, introspection, and Drizzle Studio      |

These are distinct concerns. `drizzle-orm` runs in your application. `drizzle-kit` runs during development and deployment as a dev tool.

---

## 3.2 Core Design Principles

### Principle 1: TypeScript Types Are Derived From Schema, Not the Other Way Around

In most ORMs, you write a TypeScript class and the ORM generates SQL from it. In Drizzle, you define a schema using Drizzle's column builders, and TypeScript types are **inferred** from that schema automatically.

```typescript
// You write this (the schema):
export const users = pgTable('users', {
  id:    serial('id').primaryKey(),
  email: text('email').notNull().unique(),
  name:  text('name').notNull(),
});

// Drizzle infers this (you never write it manually):
type User = typeof users.$inferSelect;
// → { id: number; email: string; name: string }

type NewUser = typeof users.$inferInsert;
// → { id?: number; email: string; name: string }
```

This is fundamentally different from writing an interface separately. The types are structurally locked to the schema definition — if you add a column, the type updates automatically.

### Principle 2: SQL is Not Hidden

Drizzle queries are designed to translate to predictable, readable SQL. The library does not perform query optimization, batching, or other transformations behind your back.

```typescript
// Drizzle query:
db.select().from(users).where(eq(users.email, 'alice@example.com'))

// Generates exactly:
// SELECT * FROM "users" WHERE "users"."email" = 'alice@example.com'
```

### Principle 3: Zero Dependencies on the Driver

Drizzle is **driver-agnostic**. It constructs SQL strings and parameter arrays, then passes them to whatever driver you configure. This is why it works with:
- `pg` (node-postgres)
- `@neondatabase/serverless`
- `postgres` (postgres.js)
- `mysql2`
- `better-sqlite3`
- `@libsql/client` (Turso)
- `bun:sqlite`

### Principle 4: Explicit Over Implicit

There is no lazy loading, no session cache, no identity map, no change-tracking. When you want data, you write a query. When you want to save, you write an insert or update. Nothing happens unless you ask for it.

### Principle 5: Escape Hatches as First-Class Citizens

You're never trapped. The `sql` tagged template literal lets you write raw SQL fragments within any Drizzle query, while still participating in the type system.

---

## 3.3 Internal Architecture: How Drizzle Works

Understanding Drizzle's internals gives you a mental model for debugging and optimization.

### Layer 1: Schema Definitions (Compile-Time)

Schema files create **table objects** that are TypeScript values carrying metadata about columns, types, constraints, and relations.

```
pgTable('users', { ... })
         │
         ▼
  PgTableWithColumns<{
    id:    PgSerial<...>
    email: PgText<...>
    name:  PgText<...>
  }>
         │
         ▼ (TypeScript inference)
  
  $inferSelect: { id: number; email: string; name: string }
  $inferInsert: { id?: number; email: string; name: string }
```

### Layer 2: Query Builder (Fluent API)

Query builder methods return **builder objects** — not promises, not SQL strings. They accumulate configuration.

```
db.select()              → SelectBuilder
  .from(users)           → SelectBuilder (with from clause set)
  .where(eq(...))        → SelectBuilder (with where clause set)
  .limit(10)             → SelectBuilder (with limit set)
  .execute()             → Promise<Row[]>
```

The builder pattern allows composability. You can build queries incrementally:

```typescript
let query = db.select().from(users);

if (filters.email) {
  query = query.where(eq(users.email, filters.email));
}

if (filters.limit) {
  query = query.limit(filters.limit);
}

const results = await query;
```

### Layer 3: SQL Compilation (Runtime)

When you `await` a query builder, Drizzle calls its internal SQL compiler:

```
SelectBuilder
     │
     ▼ .toSQL()
┌────────────────────────────────────────┐
│ { sql: 'SELECT ... FROM "users" ...',  │
│   params: ['alice@example.com'] }      │
└────────────────────────────────────────┘
     │
     ▼ passes to driver
┌────────────────────────────────────────┐
│ pg driver → pool.query(sql, params)    │
└────────────────────────────────────────┘
     │
     ▼
┌────────────────────────────────────────┐
│ Raw rows from database                 │
└────────────────────────────────────────┘
     │
     ▼ Drizzle maps columns to object keys
┌────────────────────────────────────────┐
│ [{ id: 1, email: 'alice@...', ... }]   │
└────────────────────────────────────────┘
```

You can inspect the SQL at any point with `.toSQL()`:

```typescript
const query = db.select().from(users).where(eq(users.email, 'alice@example.com'));
console.log(query.toSQL());
// { sql: 'select "id", "email", "name" from "users" where "email" = $1',
//   params: ['alice@example.com'] }
```

### Layer 4: Type Inference Engine

This is what makes Drizzle special. TypeScript's type system is used to track:

- Which columns were selected (partial selects)
- Which joins were performed
- What the shape of the result will be

```typescript
// Full select — result is inferred as User[]
const users1 = await db.select().from(users);
// type: { id: number; email: string; name: string }[]

// Partial select — result is narrowed
const users2 = await db.select({ id: users.id, email: users.email }).from(users);
// type: { id: number; email: string }[]

// With join — result includes both tables
const users3 = await db
  .select({ user: users, post: posts })
  .from(users)
  .innerJoin(posts, eq(posts.userId, users.id));
// type: { user: User; post: Post }[]
```

No runtime reflection, no decorators, no code generation step. Pure TypeScript inference.

---

## 3.4 Type Safety Architecture in Depth

### How `$inferSelect` and `$inferInsert` Work

Every Drizzle table has two inferred type properties:

| Property          | What it represents                                       |
|-------------------|----------------------------------------------------------|
| `$inferSelect`    | The shape of a row returned by SELECT                    |
| `$inferInsert`    | The shape of data required/accepted by INSERT            |

The difference: `$inferInsert` makes columns with defaults (`.default(...)`, `.defaultNow()`, serial PKs) optional.

```typescript
const posts = pgTable('posts', {
  id:        serial('id').primaryKey(),         // auto-generated
  title:     text('title').notNull(),           // required
  content:   text('content'),                   // nullable → string | null
  createdAt: timestamp('created_at').defaultNow(), // has default
});

type Post    = typeof posts.$inferSelect;
// { id: number; title: string; content: string | null; createdAt: Date }

type NewPost = typeof posts.$inferInsert;
// { id?: number; title: string; content?: string | null; createdAt?: Date }
```

### Nullability in the Type System

Drizzle maps column nullability to TypeScript types:

```typescript
text('col').notNull()           // → string     (never null)
text('col')                     // → string | null
text('col').notNull().default('') // → string   (has default, not null)
```

This is accurate and safe — the TypeScript type reflects what the database will actually return.

### The `sql` Escape Hatch and Its Types

```typescript
import { sql } from 'drizzle-orm';

// Raw SQL with a known return type:
const result = await db.execute<{ count: number }>(
  sql`SELECT COUNT(*) as count FROM ${users}`
);

// Inline SQL expression in a query:
const rows = await db.select({
  id: users.id,
  upperEmail: sql<string>`UPPER(${users.email})`,
}).from(users);
// type: { id: number; upperEmail: string }[]
```

The `sql` tagged template handles parameterization safely — values are always passed as bind parameters, not interpolated into the string.

---

## 3.5 Runtime vs Compile-Time Validation

This is a critical concept that trips up many developers.

### Compile-Time (TypeScript)

TypeScript checks happen before your code runs. They catch:
- Wrong column names
- Wrong data types in inserts
- Accessing columns that don't exist in a partial select
- Incompatible join conditions (type-level)

```typescript
// TypeScript ERROR at compile time:
await db.insert(users).values({ email: 42 }); 
// Type 'number' is not assignable to type 'string'

await db.select().from(users).where(eq(users.nonExistentColumn, 'x'));
// Property 'nonExistentColumn' does not exist on type '...'
```

### Runtime (Database)

Runtime checks happen when the query actually executes:
- NOT NULL violations
- UNIQUE constraint violations
- FOREIGN KEY violations
- CHECK constraint violations
- Type coercion issues

```typescript
// TypeScript is happy — string is assignable to string
await db.insert(users).values({ email: 'not-an-email' });
// But your CHECK CONSTRAINT fires at runtime:
// ERROR: new row for relation "users" violates check constraint "valid_email"
```

**Mental model**: TypeScript catches shape errors. The database catches value errors. You need both.

### What Drizzle Does NOT Validate at Compile Time

- Whether a value satisfies a CHECK constraint
- Whether a foreign key value exists
- Whether a UNIQUE value already exists
- Whether the database is in a valid state for your operation

This is why Part 13 (Validation) matters — Zod/Valibot validation at the application layer fills this gap.

---

## 3.6 Schema-First Development

**Schema-first development** means your TypeScript schema definition is the single source of truth from which everything else is derived:

```
┌─────────────────────────────────────────┐
│         schema.ts (Drizzle schema)       │
└────────────────┬────────────────────────┘
                 │
        ┌────────┼─────────┐
        │        │         │
        ▼        ▼         ▼
  TypeScript  SQL DDL   Zod schemas
    types    (via kit)  (via drizzle-zod)
```

This contrasts with **database-first** (introspect existing DB schema, generate code) or **code-first** (write model classes, generate schema).

Drizzle supports all three workflows, but schema-first is the recommended approach for greenfield projects.

---

## 3.7 The Drizzle Instance (`db`)

The `db` object is your entry point to all queries. It is created by wrapping a driver with Drizzle:

```typescript
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
export const db = drizzle(pool);
```

The `db` object:
- Holds a reference to your driver/pool
- Provides `.select()`, `.insert()`, `.update()`, `.delete()`, `.transaction()`, `.execute()`, etc.
- Has no global state — multiple `db` instances are safe
- Is safe to share across your application (the pool handles concurrency)

**Important**: The `db` object is not a connection. It's a query dispatcher. The actual connection is managed by the pool.

---

## 3.8 Drizzle's Relation System (Conceptual Overview)

Drizzle has an optional **relations API** that is separate from foreign key definitions. This is a common confusion point.

```
Foreign Keys (SQL level)          Relations API (Query level)
─────────────────────────         ─────────────────────────
Enforced by the database          Drizzle-only abstraction
Defined in pgTable()              Defined in relations()
Affects schema/migrations         Does NOT affect schema
Ensures data integrity            Enables .with() queries
```

```typescript
// Foreign key: enforced by DB
export const posts = pgTable('posts', {
  userId: integer('user_id').notNull().references(() => users.id),
});

// Relation: used by Drizzle's query API
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  user: one(users, { fields: [posts.userId], references: [users.id] }),
}));

// Now you can use .with():
const usersWithPosts = await db.query.users.findMany({
  with: { posts: true },
});
```

The relations API generates efficient SQL (typically one query per relation, not N+1), but it runs multiple queries, not JOINs. For join-based queries, use the join API explicitly.

---

*End of Part 3 — Drizzle Architecture*
# Part 4: Project Setup

---

## 4.1 Installation Overview

Drizzle is split across packages. You always install `drizzle-orm` (the runtime library) and pair it with a database-specific driver. You install `drizzle-kit` as a dev dependency for migrations and tooling.

```bash
# Core library (always required)
pnpm add drizzle-orm

# Dev tooling (migrations, introspection, studio)
pnpm add -D drizzle-kit
```

Then install the appropriate driver for your database:

| Database           | Driver Package(s)                                            |
|--------------------|--------------------------------------------------------------|
| PostgreSQL         | `pg` + `@types/pg` OR `postgres` (postgres.js)              |
| MySQL              | `mysql2`                                                     |
| SQLite             | `better-sqlite3` + `@types/better-sqlite3`                  |
| SQLite (Bun)       | Built-in `bun:sqlite`                                        |
| Turso (libSQL)     | `@libsql/client`                                             |
| Neon (serverless)  | `@neondatabase/serverless`                                   |
| PlanetScale        | `@planetscale/database`                                      |

---

## 4.2 Recommended Project Structure

For a production backend using Drizzle, a clean structure separates concerns:

```
src/
├── db/
│   ├── index.ts           ← drizzle instance, exported as `db`
│   ├── schema/
│   │   ├── index.ts       ← re-exports all schema tables
│   │   ├── users.ts       ← users table + relations
│   │   ├── organizations.ts
│   │   ├── posts.ts
│   │   └── ...
│   └── migrations/        ← generated SQL migration files
│       ├── 0001_initial.sql
│       └── 0002_add_orgs.sql
├── modules/
│   ├── users/
│   │   ├── users.repository.ts
│   │   ├── users.service.ts
│   │   └── users.router.ts
│   └── ...
├── lib/
│   └── env.ts             ← validated environment variables
drizzle.config.ts          ← drizzle-kit configuration
```

### For a monorepo (like your DTS project)

```
packages/
├── db/                    ← shared database package
│   ├── package.json
│   ├── src/
│   │   ├── index.ts       ← exports db, schema
│   │   └── schema/
│   └── drizzle.config.ts
├── api/                   ← fastify backend
│   └── src/
│       └── modules/...
```

---

## 4.3 PostgreSQL Setup

### With `node-postgres` (`pg`)

```bash
pnpm add drizzle-orm pg
pnpm add -D drizzle-kit @types/pg
```

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from './schema';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,                    // max pool size
  idleTimeoutMillis: 30_000,  // close idle connections after 30s
  connectionTimeoutMillis: 5_000, // fail if no connection in 5s
});

export const db = drizzle(pool, { schema });
```

### With `postgres.js`

```bash
pnpm add drizzle-orm postgres
pnpm add -D drizzle-kit
```

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

const client = postgres(process.env.DATABASE_URL!, {
  max: 20,
  idle_timeout: 30,
});

export const db = drizzle(client, { schema });
```

**`pg` vs `postgres.js`**: Both work well. `postgres.js` is slightly more modern, has a cleaner API, and handles connection lifecycle more gracefully. `pg` is more widely used in the ecosystem and has better compatibility with older tooling. Either is fine for production.

---

## 4.4 MySQL Setup

```bash
pnpm add drizzle-orm mysql2
pnpm add -D drizzle-kit
```

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/mysql2';
import mysql from 'mysql2/promise';
import * as schema from './schema';

const pool = mysql.createPool({
  uri: process.env.DATABASE_URL,
  waitForConnections: true,
  connectionLimit: 20,
  queueLimit: 0,
});

export const db = drizzle(pool, { schema, mode: 'default' });
// Use mode: 'planetscale' for PlanetScale
```

---

## 4.5 SQLite Setup

### With `better-sqlite3` (synchronous, Node.js)

```bash
pnpm add drizzle-orm better-sqlite3
pnpm add -D drizzle-kit @types/better-sqlite3
```

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import * as schema from './schema';

const sqlite = new Database(process.env.DATABASE_PATH ?? './local.db');
export const db = drizzle(sqlite, { schema });
```

SQLite with `better-sqlite3` is **synchronous** — queries return values directly, not promises. Drizzle wraps them in promises to keep the API consistent, but internally there's no async I/O.

**When to use SQLite:**
- Local development (fast, no external service)
- Embedded applications
- Edge deployments with Turso (SQLite-compatible)
- Testing (fast, in-memory option)

---

## 4.6 Turso (libSQL) Setup

Turso is a distributed SQLite-compatible database. Good for edge-deployed applications.

```bash
pnpm add drizzle-orm @libsql/client
pnpm add -D drizzle-kit
```

```typescript
import { drizzle } from 'drizzle-orm/libsql';
import { createClient } from '@libsql/client';
import * as schema from './schema';

const client = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
});

export const db = drizzle(client, { schema });
```

---

## 4.7 Neon (Serverless PostgreSQL) Setup

Neon is a serverless PostgreSQL with branching. Ideal for serverless environments.

```bash
pnpm add drizzle-orm @neondatabase/serverless
pnpm add -D drizzle-kit
```

```typescript
// For serverless environments (Vercel, Cloudflare Workers, etc.)
import { drizzle } from 'drizzle-orm/neon-http';
import { neon } from '@neondatabase/serverless';
import * as schema from './schema';

const sql = neon(process.env.DATABASE_URL!);
export const db = drizzle(sql, { schema });
```

```typescript
// For Node.js with WebSocket pooling (better for persistent servers)
import { drizzle } from 'drizzle-orm/neon-serverless';
import { Pool, neonConfig } from '@neondatabase/serverless';
import ws from 'ws';
import * as schema from './schema';

neonConfig.webSocketConstructor = ws;

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
export const db = drizzle(pool, { schema });
```

---

## 4.8 PlanetScale Setup

PlanetScale is a MySQL-compatible serverless database with branching and no FK constraints (by default).

```bash
pnpm add drizzle-orm @planetscale/database
pnpm add -D drizzle-kit
```

```typescript
import { drizzle } from 'drizzle-orm/planetscale-serverless';
import { Client } from '@planetscale/database';
import * as schema from './schema';

const client = new Client({ url: process.env.DATABASE_URL });
export const db = drizzle(client, { schema });
```

**PlanetScale caveat**: FK constraints are disabled by default. You can define them in your Drizzle schema, but they won't be enforced at the DB level. You must enforce referential integrity at the application layer.

---

## 4.9 Supabase Setup

Supabase uses PostgreSQL. Connect with the standard `pg` or `postgres.js` driver directly to Supabase's connection pooler (Transaction mode for serverless, Session mode for persistent servers).

```typescript
// Direct connection (for migrations, scripts)
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from './schema';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL, // Direct connection string
  ssl: { rejectUnauthorized: false },
});

export const db = drizzle(pool, { schema });
```

**Supabase notes:**
- Use the **Supabase connection pooler** (Transaction mode) for serverless, not the direct connection
- The direct connection string and the pooler connection string are different — check your Supabase dashboard
- Supabase generates its own user/auth tables — avoid naming conflicts

---

## 4.10 Environment Variables

Never hardcode database credentials. Use environment variables validated at startup.

```typescript
// src/lib/env.ts
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  DATABASE_MAX_CONNECTIONS: z.coerce.number().int().positive().default(20),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Invalid environment variables:');
  console.error(JSON.stringify(parsed.error.format(), null, 2));
  process.exit(1);
}

export const env = parsed.data;
```

```typescript
// src/db/index.ts — uses validated env
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import { env } from '../lib/env';
import * as schema from './schema';

const pool = new Pool({
  connectionString: env.DATABASE_URL,
  max: env.DATABASE_MAX_CONNECTIONS,
});

export const db = drizzle(pool, { schema });
```

---

## 4.11 Drizzle Configuration File

`drizzle.config.ts` configures `drizzle-kit`. It sits in the project root.

```typescript
// drizzle.config.ts
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  // Where your schema files live
  schema: './src/db/schema/index.ts',
  
  // Where generated SQL migration files are stored
  out: './src/db/migrations',
  
  // Database dialect
  dialect: 'postgresql',
  
  // Connection for drizzle-kit operations (separate from runtime pool)
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  
  // Print SQL of every executed migration
  verbose: true,
  
  // Do not auto-apply breaking changes without confirmation
  strict: true,
});
```

### Config for Different Dialects

```typescript
// MySQL
export default defineConfig({
  schema: './src/db/schema/index.ts',
  out: './drizzle',
  dialect: 'mysql',
  dbCredentials: { url: process.env.DATABASE_URL! },
});

// SQLite
export default defineConfig({
  schema: './src/db/schema/index.ts',
  out: './drizzle',
  dialect: 'sqlite',
  dbCredentials: { url: './local.db' },
});

// Turso
export default defineConfig({
  schema: './src/db/schema/index.ts',
  out: './drizzle',
  dialect: 'turso',
  dbCredentials: {
    url: process.env.TURSO_DATABASE_URL!,
    authToken: process.env.TURSO_AUTH_TOKEN!,
  },
});
```

### Multiple Schemas (for monorepos)

```typescript
// drizzle.config.ts — glob pattern for multiple schema files
export default defineConfig({
  schema: './src/db/schema/*.ts',  // all .ts files in schema/
  out: './src/db/migrations',
  dialect: 'postgresql',
  dbCredentials: { url: process.env.DATABASE_URL! },
});
```

---

## 4.12 TypeScript Configuration

Drizzle requires TypeScript 5.0+ and a compatible `tsconfig.json`. Key settings:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,              // Required for full type safety
    "strictNullChecks": true,    // Required: null/undefined are typed
    "noUncheckedIndexedAccess": true, // Recommended: array access returns T | undefined
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
```

**`strict: true` is non-negotiable** if you want Drizzle's type safety to be meaningful. With strict mode off, TypeScript is too lenient and the type guarantees Drizzle provides are weaker.

---

## 4.13 Choosing the Right Database for Your Project

| Scenario                                                    | Recommendation             |
|-------------------------------------------------------------|----------------------------|
| Production web app, team-managed infrastructure             | PostgreSQL (`pg`)           |
| Serverless (Vercel/Netlify functions, edge)                 | Neon, PlanetScale, Turso    |
| Rapid prototyping, local dev                                | SQLite (`better-sqlite3`)   |
| MySQL-heavy team or existing MySQL infrastructure           | MySQL (`mysql2`)            |
| Edge-first with distributed reads                           | Turso (libSQL)              |
| Supabase ecosystem (auth, storage, realtime)                | Supabase (PostgreSQL)       |
| Need database branching for CI/CD                           | Neon or PlanetScale         |
| Philippine LGU government system (your DTS project)        | PostgreSQL — full ACID, compliance, no vendor lock-in |

---

*End of Part 4 — Project Setup*
# Part 5: Schema Design

---

## 5.1 Schema Files and Structure

Your Drizzle schema is TypeScript code — not a DSL, not a separate file format. Each table is a TypeScript value created by calling `pgTable` (or `mysqlTable`, `sqliteTable`).

The recommended pattern is one file per domain entity or group of related entities:

```
src/db/schema/
├── index.ts          ← re-exports everything
├── users.ts          ← users, sessions, auth tokens
├── organizations.ts  ← organizations, memberships
├── documents.ts      ← resolutions, ordinances (for DTS)
├── audit.ts          ← audit logs, activity
└── enums.ts          ← shared PostgreSQL enums
```

```typescript
// src/db/schema/index.ts
export * from './users';
export * from './organizations';
export * from './documents';
export * from './audit';
export * from './enums';
```

---

## 5.2 Defining Tables

### PostgreSQL

```typescript
import { pgTable, serial, text, timestamp, boolean, integer } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id:        serial('id').primaryKey(),
  email:     text('email').notNull().unique(),
  name:      text('name').notNull(),
  isActive:  boolean('is_active').notNull().default(true),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
});
```

### MySQL

```typescript
import { mysqlTable, int, varchar, boolean, timestamp } from 'drizzle-orm/mysql-core';

export const users = mysqlTable('users', {
  id:        int('id').autoincrement().primaryKey(),
  email:     varchar('email', { length: 255 }).notNull().unique(),
  name:      varchar('name', { length: 255 }).notNull(),
  isActive:  boolean('is_active').notNull().default(true),
  createdAt: timestamp('created_at').notNull().defaultNow(),
});
```

### SQLite

```typescript
import { sqliteTable, integer, text } from 'drizzle-orm/sqlite-core';

export const users = sqliteTable('users', {
  id:        integer('id').primaryKey({ autoIncrement: true }),
  email:     text('email').notNull().unique(),
  name:      text('name').notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
```

---

## 5.3 Column Types Reference (PostgreSQL)

### Numeric Types

```typescript
import {
  smallint, integer, bigint, serial, bigserial,
  numeric, real, doublePrecision
} from 'drizzle-orm/pg-core';

const numericColumns = pgTable('t', {
  smallInt:  smallint('small_int'),               // 2 bytes, -32768 to 32767
  intCol:    integer('int_col'),                  // 4 bytes
  bigInt:    bigint('big_int', { mode: 'number' }), // 8 bytes, JS number
  bigIntStr: bigint('big_int_str', { mode: 'bigint' }), // JS BigInt (safe for >53-bit)
  serial:    serial('id'),                        // auto-increment integer PK
  bigSerial: bigserial('id', { mode: 'number' }), // auto-increment bigint PK
  price:     numeric('price', { precision: 10, scale: 2 }), // EXACT decimal
  score:     real('score'),                       // 4-byte float (approximate)
  latitude:  doublePrecision('latitude'),          // 8-byte float (approximate)
});
```

**Critical**: Use `numeric` for money. Never use `real` or `doublePrecision` for financial values — floating-point approximation errors accumulate.

### Text Types

```typescript
import { text, varchar, char } from 'drizzle-orm/pg-core';

const textColumns = pgTable('t', {
  name:    text('name'),                    // unlimited length, preferred in PG
  code:    varchar('code', { length: 10 }), // max 10 chars
  isoCode: char('iso_code', { length: 2 }), // fixed 2 chars, padded
});
```

**In PostgreSQL, `text` is the idiomatic choice** for variable-length strings. `varchar(n)` adds a length check but has no storage or performance advantage over `text` with a `CHECK` constraint. Use `varchar(n)` when interoperability with other systems requires it.

### Boolean

```typescript
import { boolean } from 'drizzle-orm/pg-core';

const boolColumns = pgTable('t', {
  isActive:  boolean('is_active').notNull().default(true),
  isDeleted: boolean('is_deleted').notNull().default(false),
});
```

### Date and Time

```typescript
import { date, time, timestamp, interval } from 'drizzle-orm/pg-core';

const timeColumns = pgTable('t', {
  birthDate:   date('birth_date'),                               // DATE only
  startTime:   time('start_time'),                              // TIME only
  createdAt:   timestamp('created_at', { withTimezone: true })  // TIMESTAMPTZ
                 .notNull().defaultNow(),
  duration:    interval('duration'),                            // INTERVAL
});
```

**Always use `withTimezone: true`** (`TIMESTAMPTZ`) for timestamps. This stores timestamps in UTC and returns them in UTC regardless of database timezone settings. Plain `TIMESTAMP` is stored without timezone context — a landmine when your servers or users span timezones.

### UUID

```typescript
import { uuid } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

const uuidColumns = pgTable('t', {
  // Generate UUID in PostgreSQL (requires pgcrypto or pg 13+)
  id: uuid('id').primaryKey().defaultRandom(),
  
  // Or generate in application code (pass as string)
  token: uuid('token').notNull(),
});
```

### JSON and JSONB

```typescript
import { json, jsonb } from 'drizzle-orm/pg-core';

const jsonColumns = pgTable('t', {
  metadata:   json('metadata').$type<Record<string, unknown>>(),
  settings:   jsonb('settings').$type<UserSettings>(),
});

// With a proper type:
interface UserSettings {
  theme: 'light' | 'dark';
  notifications: boolean;
}

const withTypedJson = pgTable('t', {
  settings: jsonb('settings').$type<UserSettings>().notNull(),
});
```

**`jsonb` vs `json`**: Always prefer `jsonb` in PostgreSQL. It stores data in a decomposed binary format that:
- Supports GIN indexing
- Deduplicates keys
- Is faster to query
- Has operators like `@>`, `->`, `->>`

The only reason to use `json` is when you need to preserve key order or duplicate keys (very rare).

### Arrays

```typescript
import { text, integer } from 'drizzle-orm/pg-core';

const arrayColumns = pgTable('t', {
  tags:    text('tags').array(),                    // text[]
  scores:  integer('scores').array(),              // integer[]
  matrix:  integer('matrix').array().array(),      // integer[][] (2D)
});

// Querying arrays uses PostgreSQL array operators
```

### Enums

```typescript
import { pgEnum, pgTable, text } from 'drizzle-orm/pg-core';

// Define the enum type (creates a PostgreSQL TYPE)
export const documentStatusEnum = pgEnum('document_status', [
  'draft',
  'pending_review',
  'approved',
  'rejected',
  'archived',
]);

export const documents = pgTable('documents', {
  id:     serial('id').primaryKey(),
  title:  text('title').notNull(),
  status: documentStatusEnum('status').notNull().default('draft'),
});

// TypeScript type is inferred:
type DocumentStatus = typeof documentStatusEnum.enumValues[number];
// 'draft' | 'pending_review' | 'approved' | 'rejected' | 'archived'
```

---

## 5.4 Column Modifiers

Modifiers are chained after the column type:

```typescript
text('col')
  .notNull()           // NOT NULL constraint
  .unique()            // UNIQUE constraint
  .default('value')    // static default value
  .defaultRandom()     // random() for uuid, only with uuid type
  .$defaultFn(() => generateId())  // JS function called at insert time
  .$onUpdateFn(() => new Date())   // JS function called on update
  .references(() => otherTable.id) // foreign key (inline syntax)
  .generatedAlwaysAs(sql`...`)     // generated column
```

### Defaults: DB vs Application

| Method                      | Runs Where | Use When                              |
|-----------------------------|-----------|---------------------------------------|
| `.default('value')`         | Database  | Simple static values                  |
| `.defaultNow()`             | Database  | Timestamps (use this for created_at)  |
| `.defaultRandom()`          | Database  | UUIDs at the database level           |
| `.$defaultFn(() => ...)`    | Drizzle   | Complex IDs (ULID, custom logic)      |
| `.$onUpdateFn(() => ...)`   | Drizzle   | updated_at via application code       |

**Production note on `updated_at`**: There are two approaches:
1. `.$onUpdateFn(() => new Date())` — Drizzle sets it when you call `.update()`
2. A database trigger — the DB sets it on any UPDATE

Option 1 is simpler and more visible. Option 2 is foolproof (catches raw SQL updates too). For audit-critical systems, use the trigger approach.

---

## 5.5 Primary Keys

### Auto-increment Integer (most common)

```typescript
import { pgTable, serial, bigserial } from 'drizzle-orm/pg-core';

export const items = pgTable('items', {
  id: serial('id').primaryKey(),      // INTEGER, starts at 1
  // or
  id: bigserial('id', { mode: 'number' }).primaryKey(), // BIGINT, for large tables
});
```

### UUID Primary Key

```typescript
import { pgTable, uuid } from 'drizzle-orm/pg-core';

export const items = pgTable('items', {
  id: uuid('id').primaryKey().defaultRandom(),
});
```

### ULID / Custom ID (application-generated)

```typescript
import { pgTable, text } from 'drizzle-orm/pg-core';
import { ulid } from 'ulid'; // pnpm add ulid

export const items = pgTable('items', {
  id: text('id').primaryKey().$defaultFn(() => ulid()),
});
```

**ULID (Universally Unique Lexicographically Sortable Identifier)** is time-ordered, URL-safe, and 26 characters. It avoids UUID's random-insertion B-tree fragmentation while retaining global uniqueness. A strong choice for distributed systems.

---

## 5.6 Foreign Keys

### Inline Syntax

```typescript
export const posts = pgTable('posts', {
  id:     serial('id').primaryKey(),
  userId: integer('user_id').notNull().references(() => users.id),
});
```

### Explicit Syntax (more control over referential actions)

```typescript
import { pgTable, integer, serial, foreignKey } from 'drizzle-orm/pg-core';

export const posts = pgTable('posts', {
  id:     serial('id').primaryKey(),
  userId: integer('user_id').notNull(),
  parentId: integer('parent_id'),  // self-reference
}, (table) => ({
  userFk: foreignKey({
    columns: [table.userId],
    foreignColumns: [users.id],
    name: 'posts_user_id_fk',
  }).onDelete('cascade').onUpdate('restrict'),
  
  parentFk: foreignKey({
    columns: [table.parentId],
    foreignColumns: [table.id],  // self-reference
    name: 'posts_parent_id_fk',
  }).onDelete('set null'),
}));
```

---

## 5.7 Indexes

Indexes are defined in the table's third argument (the callback):

```typescript
import { pgTable, text, integer, serial, index, uniqueIndex } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id:        serial('id').primaryKey(),
  email:     text('email').notNull(),
  orgId:     integer('org_id').notNull(),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  deletedAt: timestamp('deleted_at'),
}, (table) => ({
  // Simple index
  emailIdx: index('users_email_idx').on(table.email),
  
  // Unique index (equivalent to UNIQUE constraint but more flexible)
  emailUniqueIdx: uniqueIndex('users_email_unique_idx').on(table.email),
  
  // Composite index
  orgCreatedIdx: index('users_org_created_idx').on(table.orgId, table.createdAt),
  
  // Partial index (only index active users)
  activeEmailIdx: index('users_active_email_idx')
    .on(table.email)
    .where(sql`${table.deletedAt} IS NULL`),
  
  // Descending order
  createdDescIdx: index('users_created_desc_idx')
    .on(table.createdAt.desc()),
}));
```

### Index Types (PostgreSQL-specific)

```typescript
import { index } from 'drizzle-orm/pg-core';

// GIN index for JSONB or full-text search
index('settings_gin_idx').using('gin', table.settings),

// GiST index for geometric/range types
index('location_gist_idx').using('gist', table.location),

// Concurrent index creation (avoids table lock in production)
index('email_idx').on(table.email).concurrently(),
```

---

## 5.8 Constraints (Table-Level)

```typescript
import { pgTable, text, integer, check, unique, primaryKey } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

export const products = pgTable('products', {
  id:       serial('id').primaryKey(),
  name:     text('name').notNull(),
  price:    numeric('price', { precision: 10, scale: 2 }).notNull(),
  minPrice: numeric('min_price', { precision: 10, scale: 2 }),
  category: text('category').notNull(),
  sku:      text('sku').notNull(),
}, (table) => ({
  // CHECK constraint
  pricePositive: check('price_positive', sql`${table.price} > 0`),
  
  // CHECK: price must be >= minPrice
  priceGteMinPrice: check(
    'price_gte_min_price',
    sql`${table.minPrice} IS NULL OR ${table.price} >= ${table.minPrice}`
  ),
  
  // Composite UNIQUE constraint
  categorySkuUnique: unique('category_sku_unique').on(table.category, table.sku),
}));
```

---

## 5.9 Generated Columns

**Generated columns** (PostgreSQL 12+) compute their value automatically from other columns. The database maintains them.

```typescript
import { pgTable, text, integer, generatedAlwaysAs } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

export const users = pgTable('users', {
  id:        serial('id').primaryKey(),
  firstName: text('first_name').notNull(),
  lastName:  text('last_name').notNull(),
  
  // Generated: cannot be inserted/updated directly
  fullName: text('full_name')
    .generatedAlwaysAs(sql`first_name || ' ' || last_name`)
    .notNull(),
    
  // Useful for full-text search:
  searchVector: tsvector('search_vector')
    .generatedAlwaysAs(
      sql`to_tsvector('english', coalesce(first_name,'') || ' ' || coalesce(last_name,''))`
    ),
});
```

---

## 5.10 Composite Primary Keys

```typescript
import { pgTable, integer, primaryKey } from 'drizzle-orm/pg-core';

// Many-to-many junction table
export const teamMembers = pgTable('team_members', {
  teamId:   integer('team_id').notNull().references(() => teams.id),
  userId:   integer('user_id').notNull().references(() => users.id),
  role:     text('role').notNull().default('member'),
  joinedAt: timestamp('joined_at').notNull().defaultNow(),
}, (table) => ({
  pk: primaryKey({ columns: [table.teamId, table.userId] }),
}));

// Inferred types respect composite PK
type TeamMember = typeof teamMembers.$inferSelect;
// { teamId: number; userId: number; role: string; joinedAt: Date }
```

---

## 5.11 A Complete Production Schema Example

Here is a realistic schema for the document tracking system context, showing all patterns together:

```typescript
// src/db/schema/documents.ts

import {
  pgTable, pgEnum, serial, bigserial, text, integer,
  boolean, timestamp, numeric, jsonb, uuid, index,
  uniqueIndex, foreignKey, check, primaryKey
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

// ─── Enums ────────────────────────────────────────────────────────────────────

export const documentTypeEnum = pgEnum('document_type', [
  'resolution', 'ordinance', 'motion', 'proclamation',
]);

export const documentStatusEnum = pgEnum('document_status', [
  'draft', 'filed', 'committee_review', 'floor_deliberation',
  'approved', 'vetoed', 'lapsed_into_law', 'archived',
]);

// ─── Users ───────────────────────────────────────────────────────────────────

export const users = pgTable('users', {
  id:           bigserial('id', { mode: 'number' }).primaryKey(),
  email:        text('email').notNull(),
  passwordHash: text('password_hash').notNull(),
  displayName:  text('display_name').notNull(),
  isActive:     boolean('is_active').notNull().default(true),
  createdAt:    timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt:    timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
  deletedAt:    timestamp('deleted_at', { withTimezone: true }),
}, (table) => ({
  emailUniqueIdx: uniqueIndex('users_email_unique').on(table.email),
  activeEmailIdx: index('users_active_email').on(table.email)
    .where(sql`${table.deletedAt} IS NULL`),
}));

// ─── Documents ────────────────────────────────────────────────────────────────

export const documents = pgTable('documents', {
  id:             bigserial('id', { mode: 'number' }).primaryKey(),
  
  // Gapless sequential numbering per type per year
  documentNumber: integer('document_number').notNull(),
  year:           integer('year').notNull(),
  type:           documentTypeEnum('type').notNull(),
  
  title:          text('title').notNull(),
  description:    text('description'),
  content:        text('content'),
  
  status:         documentStatusEnum('status').notNull().default('draft'),
  
  // Cryptographic integrity chain
  contentHash:    text('content_hash'),
  previousHash:   text('previous_hash'),
  
  // Who filed it
  filedById:      integer('filed_by_id').notNull(),
  
  // Metadata
  tags:           text('tags').array(),
  metadata:       jsonb('metadata').$type<Record<string, unknown>>(),
  
  filedAt:        timestamp('filed_at', { withTimezone: true }),
  approvedAt:     timestamp('approved_at', { withTimezone: true }),
  createdAt:      timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt:      timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
}, (table) => ({
  // Each document number is unique per type per year
  documentNumberUnique: uniqueIndex('doc_number_type_year_unique')
    .on(table.documentNumber, table.type, table.year),
    
  statusIdx:  index('documents_status_idx').on(table.status),
  typeIdx:    index('documents_type_idx').on(table.type),
  yearIdx:    index('documents_year_idx').on(table.year),
  filedByIdx: index('documents_filed_by_idx').on(table.filedById),
  
  filedByFk: foreignKey({
    columns: [table.filedById],
    foreignColumns: [users.id],
    name: 'documents_filed_by_fk',
  }),
  
  yearValid: check('year_valid', sql`${table.year} >= 1900 AND ${table.year} <= 2200`),
  docNumPositive: check('doc_num_positive', sql`${table.documentNumber} > 0`),
}));
```

This example demonstrates:
- Enums for constrained status values
- `BIGSERIAL` for large-table PKs
- Composite unique constraints for business rules
- Partial indexes for soft-delete patterns
- Explicit FK definitions with constraint names
- CHECK constraints for data integrity
- `JSONB` for flexible metadata
- Arrays for tags
- `withTimezone: true` on all timestamps

---

## 5.12 Type Helpers and Utilities

```typescript
// Get select type
type Document = typeof documents.$inferSelect;

// Get insert type
type NewDocument = typeof documents.$inferInsert;

// Partial update type (for PATCH endpoints)
type DocumentUpdate = Partial<typeof documents.$inferInsert>;

// Build a strict update type manually
type DocumentFields = typeof documents.$inferInsert;
type DocumentUpdatePayload = Pick<DocumentFields, 'title' | 'description' | 'status'>;
```

---

*End of Part 5 — Schema Design*
# Part 6: Relations

---

## 6.1 The Two Relation Systems in Drizzle

Drizzle has two separate systems for expressing relationships. Understanding which one to use and when is essential:

```
┌──────────────────────────┬──────────────────────────────────────────┐
│ Foreign Key References   │ Drizzle Relations API                    │
├──────────────────────────┼──────────────────────────────────────────┤
│ Defined in pgTable()     │ Defined with relations()                 │
│ Creates DB constraint    │ No DB constraint created                 │
│ Enforces integrity       │ Enables db.query.* with .with()          │
│ Used in JOIN queries     │ Issues multiple queries (not JOINs)      │
│ Always use for FKs       │ Use for convenience loading              │
└──────────────────────────┴──────────────────────────────────────────┘
```

**Both serve different purposes and can coexist.** In most schemas you'll have both.

---

## 6.2 One-to-Many

The most common relation: one user has many posts.

```typescript
// Schema
export const users = pgTable('users', {
  id:    bigserial('id', { mode: 'number' }).primaryKey(),
  email: text('email').notNull(),
  name:  text('name').notNull(),
});

export const posts = pgTable('posts', {
  id:      bigserial('id', { mode: 'number' }).primaryKey(),
  userId:  bigint('user_id', { mode: 'number' }).notNull()
             .references(() => users.id, { onDelete: 'cascade' }),
  title:   text('title').notNull(),
  content: text('content'),
});

// Relations API
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  user: one(users, {
    fields: [posts.userId],
    references: [users.id],
  }),
}));
```

### Querying One-to-Many

**Method 1: JOIN (explicit, single query)**

```typescript
// Returns flat rows; you manually reshape
const rows = await db
  .select({
    post: posts,
    userName: users.name,
    userEmail: users.email,
  })
  .from(posts)
  .innerJoin(users, eq(posts.userId, users.id));
// type: { post: Post; userName: string; userEmail: string }[]
```

**Method 2: Relations API (two queries, nested result)**

```typescript
// Requires relations to be defined and schema passed to drizzle()
const usersWithPosts = await db.query.users.findMany({
  with: {
    posts: true,
  },
});
// type: { id: number; email: string; name: string; posts: Post[] }[]
```

**Method 3: Separate queries (maximum control)**

```typescript
const user = await db.query.users.findFirst({
  where: eq(users.id, userId),
});

if (!user) throw new Error('User not found');

const userPosts = await db.select().from(posts)
  .where(eq(posts.userId, user.id));
```

**When to use each approach:**
- JOIN: When you need flat data, filtering across both tables, or a single round trip
- Relations API: When you need nested objects and don't need complex cross-table filtering
- Separate queries: When the logic between them depends on the first result

---

## 6.3 One-to-One

A user has exactly one profile.

```typescript
export const profiles = pgTable('profiles', {
  id:       bigserial('id', { mode: 'number' }).primaryKey(),
  userId:   bigint('user_id', { mode: 'number' }).notNull().unique()
              .references(() => users.id, { onDelete: 'cascade' }),
  bio:      text('bio'),
  avatarUrl: text('avatar_url'),
});

export const profilesRelations = relations(profiles, ({ one }) => ({
  user: one(users, {
    fields: [profiles.userId],
    references: [users.id],
  }),
}));

export const usersRelations = relations(users, ({ one, many }) => ({
  profile: one(profiles, {
    fields: [users.id],
    references: [profiles.userId],
  }),
  posts: many(posts),
}));

// Query
const userWithProfile = await db.query.users.findFirst({
  where: eq(users.id, userId),
  with: { profile: true },
});
// type: { ..., profile: Profile | null }
```

---

## 6.4 Many-to-Many

Users belong to many organizations; organizations have many users. Requires a **junction table**.

```typescript
export const organizations = pgTable('organizations', {
  id:   bigserial('id', { mode: 'number' }).primaryKey(),
  name: text('name').notNull(),
  slug: text('slug').notNull().unique(),
});

export const organizationMembers = pgTable('organization_members', {
  organizationId: bigint('organization_id', { mode: 'number' }).notNull()
    .references(() => organizations.id, { onDelete: 'cascade' }),
  userId: bigint('user_id', { mode: 'number' }).notNull()
    .references(() => users.id, { onDelete: 'cascade' }),
  role:     text('role').notNull().default('member'),
  joinedAt: timestamp('joined_at', { withTimezone: true }).notNull().defaultNow(),
}, (table) => ({
  pk: primaryKey({ columns: [table.organizationId, table.userId] }),
  userIdx: index('org_members_user_idx').on(table.userId),
}));

// Relations
export const organizationsRelations = relations(organizations, ({ many }) => ({
  memberships: many(organizationMembers),
}));

export const organizationMembersRelations = relations(organizationMembers, ({ one }) => ({
  organization: one(organizations, {
    fields: [organizationMembers.organizationId],
    references: [organizations.id],
  }),
  user: one(users, {
    fields: [organizationMembers.userId],
    references: [users.id],
  }),
}));

export const usersRelations = relations(users, ({ many }) => ({
  memberships: many(organizationMembers),
}));
```

### Querying Many-to-Many

```typescript
// Get all organizations a user belongs to (with role)
const userOrgs = await db
  .select({
    orgId:   organizations.id,
    orgName: organizations.name,
    role:    organizationMembers.role,
  })
  .from(organizationMembers)
  .innerJoin(organizations, eq(organizationMembers.organizationId, organizations.id))
  .where(eq(organizationMembers.userId, userId));

// Or via relations API (two queries):
const userWithOrgs = await db.query.users.findFirst({
  where: eq(users.id, userId),
  with: {
    memberships: {
      with: { organization: true },
    },
  },
});
// type: { ..., memberships: Array<{ role: string; organization: Organization }> }
```

---

## 6.5 Self-Referencing Relations

A classic example: an employee has a manager (who is also an employee).

```typescript
export const employees = pgTable('employees', {
  id:        bigserial('id', { mode: 'number' }).primaryKey(),
  name:      text('name').notNull(),
  managerId: bigint('manager_id', { mode: 'number' })
               .references((): AnyPgColumn => employees.id),
                // Note: () => employees.id uses a lambda to avoid circular reference
});

export const employeesRelations = relations(employees, ({ one, many }) => ({
  manager: one(employees, {
    fields: [employees.managerId],
    references: [employees.id],
    relationName: 'manager_subordinates', // disambiguate when same table is used twice
  }),
  subordinates: many(employees, {
    relationName: 'manager_subordinates',
  }),
}));
```

### Recursive CTE for Tree Traversal

The relations API doesn't handle recursive queries. Use a CTE directly:

```typescript
import { sql } from 'drizzle-orm';

const orgChart = await db.execute(sql`
  WITH RECURSIVE org_tree AS (
    SELECT id, name, manager_id, 0 AS depth
    FROM employees
    WHERE manager_id IS NULL  -- start at root
    
    UNION ALL
    
    SELECT e.id, e.name, e.manager_id, t.depth + 1
    FROM employees e
    JOIN org_tree t ON e.manager_id = t.id
    WHERE t.depth < 10  -- safety limit
  )
  SELECT * FROM org_tree ORDER BY depth, id
`);
```

---

## 6.6 Advanced Relation Querying

### Filtering, Ordering, Limiting Within Relations

```typescript
const usersWithRecentPosts = await db.query.users.findMany({
  with: {
    posts: {
      where: (posts, { gte }) => gte(posts.createdAt, thirtyDaysAgo),
      orderBy: (posts, { desc }) => [desc(posts.createdAt)],
      limit: 5,
    },
  },
  limit: 10,
});
```

### Column Selection Within Relations

```typescript
const usersWithPostTitles = await db.query.users.findMany({
  columns: {
    id: true,
    email: true,
    // name is excluded
  },
  with: {
    posts: {
      columns: {
        id: true,
        title: true,
        // content is excluded
      },
    },
  },
});
```

### Deep Nesting

```typescript
const deep = await db.query.organizations.findFirst({
  with: {
    memberships: {
      with: {
        user: {
          with: {
            posts: { limit: 3 },
          },
        },
      },
    },
  },
});
```

**Caution with deep nesting**: Each level of nesting adds another round-trip query. Deeply nested queries can become slow. Benchmark carefully and consider flattening with explicit JOINs for performance-critical paths.

---

## 6.7 RBAC Schema Pattern

A production-grade role-based access control schema:

```typescript
export const roleEnum = pgEnum('role', ['owner', 'admin', 'editor', 'viewer']);

export const permissions = pgTable('permissions', {
  id:       serial('id').primaryKey(),
  resource: text('resource').notNull(),  // 'document', 'report', etc.
  action:   text('action').notNull(),    // 'create', 'read', 'update', 'delete'
}, (table) => ({
  unique: uniqueIndex('permissions_resource_action').on(table.resource, table.action),
}));

export const rolePermissions = pgTable('role_permissions', {
  role:         roleEnum('role').notNull(),
  permissionId: integer('permission_id').notNull()
                  .references(() => permissions.id),
}, (table) => ({
  pk: primaryKey({ columns: [table.role, table.permissionId] }),
}));

// Query: does this user have permission?
const hasPermission = await db
  .select({ count: sql<number>`count(*)::int` })
  .from(organizationMembers)
  .innerJoin(rolePermissions, eq(organizationMembers.role, rolePermissions.role))
  .innerJoin(permissions, eq(rolePermissions.permissionId, permissions.id))
  .where(and(
    eq(organizationMembers.userId, userId),
    eq(organizationMembers.organizationId, orgId),
    eq(permissions.resource, resource),
    eq(permissions.action, action),
  ));

const allowed = hasPermission[0].count > 0;
```

---

# Part 7: Querying Data

---

## 7.1 Select

### Basic Select

```typescript
// Select all columns
const allUsers = await db.select().from(users);

// Select specific columns
const emails = await db.select({
  id:    users.id,
  email: users.email,
}).from(users);

// Select with aliasing
const aliased = await db.select({
  userId:    users.id,
  userEmail: users.email,
  userName:  users.name,
}).from(users);
```

### SQL Generated

```sql
SELECT "id", "email", "name" FROM "users"
SELECT "id", "email" FROM "users"
SELECT "id" AS "userId", "email" AS "userEmail", "name" AS "userName" FROM "users"
```

---

## 7.2 Insert

### Single Row

```typescript
const [newUser] = await db
  .insert(users)
  .values({
    email: 'alice@example.com',
    name: 'Alice',
  })
  .returning(); // Returns inserted row(s)

// type: User
```

### Multiple Rows

```typescript
const newUsers = await db
  .insert(users)
  .values([
    { email: 'alice@example.com', name: 'Alice' },
    { email: 'bob@example.com', name: 'Bob' },
  ])
  .returning();
```

### Insert Without Returning (MySQL/SQLite)

```typescript
const result = await db.insert(users).values({ email: 'x@x.com', name: 'X' });
// MySQL: result.insertId
// SQLite: result.lastInsertRowid
```

### On Conflict (Upsert)

```typescript
// Do nothing on conflict
await db
  .insert(users)
  .values({ email: 'alice@example.com', name: 'Alice' })
  .onConflictDoNothing();

// Update on conflict (upsert)
await db
  .insert(users)
  .values({ email: 'alice@example.com', name: 'Alice Updated' })
  .onConflictDoUpdate({
    target: users.email,         // conflict target column
    set: {
      name: sql`excluded.name`,  // use the incoming value
      updatedAt: new Date(),
    },
  });
```

**`excluded` table**: In PostgreSQL's `ON CONFLICT DO UPDATE`, `excluded` refers to the row that was rejected by the conflict. This is the standard SQL way to reference the incoming values.

---

## 7.3 Update

```typescript
// Update with returning
const [updated] = await db
  .update(users)
  .set({ name: 'Alice B.', updatedAt: new Date() })
  .where(eq(users.id, 1))
  .returning();

// Update multiple columns
await db
  .update(documents)
  .set({
    status:     'approved',
    approvedAt: new Date(),
    updatedAt:  new Date(),
  })
  .where(and(
    eq(documents.id, documentId),
    eq(documents.status, 'pending_review'),
  ));
```

**Always add a WHERE clause to UPDATE.** Omitting it updates every row. Drizzle will not warn you.

---

## 7.4 Delete

```typescript
// Delete with returning
const [deleted] = await db
  .delete(users)
  .where(eq(users.id, userId))
  .returning();

// Soft delete (preferred for audit trails)
await db
  .update(users)
  .set({ deletedAt: new Date() })
  .where(eq(users.id, userId));
```

---

## 7.5 Filtering (WHERE)

### Comparison Operators

```typescript
import { eq, ne, lt, lte, gt, gte, isNull, isNotNull } from 'drizzle-orm';

db.select().from(users).where(eq(users.id, 1));          // =
db.select().from(users).where(ne(users.status, 'deleted')); // !=
db.select().from(users).where(gt(users.age, 18));         // >
db.select().from(users).where(gte(users.age, 18));        // >=
db.select().from(users).where(lt(users.price, 100));      // <
db.select().from(users).where(lte(users.price, 100));     // <=
db.select().from(users).where(isNull(users.deletedAt));   // IS NULL
db.select().from(users).where(isNotNull(users.approvedAt)); // IS NOT NULL
```

### Logical Operators

```typescript
import { and, or, not } from 'drizzle-orm';

// AND
db.select().from(users).where(
  and(
    eq(users.isActive, true),
    isNull(users.deletedAt),
  )
);

// OR
db.select().from(users).where(
  or(
    eq(users.role, 'admin'),
    eq(users.role, 'owner'),
  )
);

// NOT
db.select().from(users).where(not(eq(users.status, 'banned')));
```

### String Operators

```typescript
import { like, ilike, notLike } from 'drizzle-orm';

db.select().from(users).where(like(users.email, '%@example.com'));   // LIKE (case sensitive)
db.select().from(users).where(ilike(users.name, 'alice%'));           // ILIKE (case insensitive)
db.select().from(users).where(notLike(users.email, '%@spam.com'));
```

### Array/Set Operators

```typescript
import { inArray, notInArray, between } from 'drizzle-orm';

db.select().from(users).where(inArray(users.id, [1, 2, 3]));
db.select().from(docs).where(inArray(docs.status, ['approved', 'filed']));
db.select().from(orders).where(between(orders.amount, 100, 500));
```

### Dynamic WHERE Conditions

A common real-world pattern — building filters from user input:

```typescript
interface DocumentFilters {
  status?:   string;
  type?:     string;
  year?:     number;
  search?:   string;
}

async function searchDocuments(filters: DocumentFilters) {
  const conditions = [];

  if (filters.status) {
    conditions.push(eq(documents.status, filters.status as DocumentStatus));
  }
  if (filters.type) {
    conditions.push(eq(documents.type, filters.type as DocumentType));
  }
  if (filters.year) {
    conditions.push(eq(documents.year, filters.year));
  }
  if (filters.search) {
    conditions.push(ilike(documents.title, `%${filters.search}%`));
  }

  const whereClause = conditions.length > 0 ? and(...conditions) : undefined;

  return db.select().from(documents).where(whereClause);
}
```

---

## 7.6 Sorting

```typescript
import { asc, desc } from 'drizzle-orm';

// Single column
db.select().from(posts).orderBy(desc(posts.createdAt));

// Multiple columns
db.select().from(docs).orderBy(
  desc(docs.year),
  asc(docs.documentNumber),
);

// Nulls first/last (PostgreSQL)
db.select().from(users).orderBy(
  asc(users.deletedAt).nullsLast(),
);
```

---

## 7.7 Pagination

### Offset Pagination (simple, less scalable)

```typescript
const PAGE_SIZE = 20;

async function getDocumentsPage(page: number) {
  return db.select()
    .from(documents)
    .orderBy(desc(documents.createdAt))
    .limit(PAGE_SIZE)
    .offset((page - 1) * PAGE_SIZE);
}
```

**Offset pagination problems:**
- Slow on large tables (DB must scan and skip N rows)
- Results shift if rows are inserted/deleted between page requests

### Cursor Pagination (scalable, stable)

```typescript
// Cursor is the last seen ID + timestamp
async function getDocumentsAfterCursor(
  cursor?: { id: number; createdAt: Date }
) {
  const PAGE_SIZE = 20;

  return db.select()
    .from(documents)
    .where(
      cursor
        ? or(
            lt(documents.createdAt, cursor.createdAt),
            and(
              eq(documents.createdAt, cursor.createdAt),
              lt(documents.id, cursor.id)
            )
          )
        : undefined
    )
    .orderBy(desc(documents.createdAt), desc(documents.id))
    .limit(PAGE_SIZE);
}

// Get next cursor from last row:
// const nextCursor = rows.length === PAGE_SIZE
//   ? { id: rows.at(-1)!.id, createdAt: rows.at(-1)!.createdAt }
//   : null;
```

---

## 7.8 Aggregations

```typescript
import { count, sum, avg, min, max, countDistinct } from 'drizzle-orm';

const stats = await db.select({
  total:    count(),
  distinct: countDistinct(documents.type),
  avgAge:   avg(users.age),
  minDate:  min(documents.createdAt),
  maxDate:  max(documents.createdAt),
}).from(documents);

// With GROUP BY
const byStatus = await db.select({
  status: documents.status,
  count:  count(),
}).from(documents)
  .groupBy(documents.status)
  .orderBy(desc(count()));

// With HAVING
const activeTypes = await db.select({
  type:  documents.type,
  total: count(),
}).from(documents)
  .groupBy(documents.type)
  .having(gt(count(), 10)); // only types with >10 documents
```

---

## 7.9 Joins

```typescript
import { eq, and } from 'drizzle-orm';

// INNER JOIN
const postsWithUsers = await db
  .select({
    postId:    posts.id,
    postTitle: posts.title,
    userName:  users.name,
    userEmail: users.email,
  })
  .from(posts)
  .innerJoin(users, eq(posts.userId, users.id));

// LEFT JOIN (includes posts even if user is deleted)
const allPosts = await db
  .select({
    post:     posts,
    userName: users.name,
  })
  .from(posts)
  .leftJoin(users, eq(posts.userId, users.id));

// Multiple JOINs
const richData = await db
  .select({
    doc:       documents,
    filedBy:   { name: users.name, email: users.email },
    orgName:   organizations.name,
  })
  .from(documents)
  .innerJoin(users, eq(documents.filedById, users.id))
  .leftJoin(organizations, eq(users.orgId, organizations.id))
  .where(eq(documents.status, 'approved'));
```

---

## 7.10 Subqueries

```typescript
import { eq, inArray } from 'drizzle-orm';

// Scalar subquery
const usersWithPostCount = await db.select({
  id:        users.id,
  email:     users.email,
  postCount: db.select({ count: count() })
               .from(posts)
               .where(eq(posts.userId, users.id))
               .as('post_count'),
}).from(users);

// Subquery in WHERE
const activeAuthorIds = db
  .select({ id: users.id })
  .from(users)
  .where(eq(users.isActive, true));

const authoredPosts = await db.select()
  .from(posts)
  .where(inArray(posts.userId, activeAuthorIds));
```

---

## 7.11 CTEs (Common Table Expressions)

```typescript
import { with as withCte } from 'drizzle-orm';

const activeUsersQuery = db
  .$with('active_users')
  .as(
    db.select().from(users).where(eq(users.isActive, true))
  );

const result = await db
  .with(activeUsersQuery)
  .select({
    userId:    activeUsersQuery.id,
    postCount: count(posts.id),
  })
  .from(activeUsersQuery)
  .leftJoin(posts, eq(posts.userId, activeUsersQuery.id))
  .groupBy(activeUsersQuery.id);
```

---

## 7.12 Window Functions

```typescript
import { sql } from 'drizzle-orm';

const ranked = await db.select({
  id:        orders.id,
  userId:    orders.userId,
  amount:    orders.amount,
  userRank:  sql<number>`RANK() OVER (PARTITION BY ${orders.userId} ORDER BY ${orders.amount} DESC)`,
  runningSum: sql<number>`SUM(${orders.amount}) OVER (PARTITION BY ${orders.userId} ORDER BY ${orders.createdAt})`,
}).from(orders);
```

---

## 7.13 Full-Text Search

```typescript
import { sql } from 'drizzle-orm';

// Basic full-text search (PostgreSQL)
const results = await db.select()
  .from(documents)
  .where(
    sql`to_tsvector('english', ${documents.title} || ' ' || coalesce(${documents.content}, '')) 
        @@ plainto_tsquery('english', ${searchTerm})`
  )
  .orderBy(
    sql`ts_rank(
      to_tsvector('english', ${documents.title} || ' ' || coalesce(${documents.content}, '')),
      plainto_tsquery('english', ${searchTerm})
    ) DESC`
  );
```

For heavy full-text search workloads, consider Meilisearch or Elasticsearch as a search index alongside PostgreSQL, with a sync worker keeping them in sync — exactly the pattern in your DTS project.

---

# Part 8: Transactions

---

## 8.1 Why Transactions Exist (Review + Drizzle Context)

From Part 1, you know transactions ensure atomicity. In Drizzle, you express transactions using `db.transaction()`:

```typescript
const result = await db.transaction(async (tx) => {
  // tx is a transaction-scoped db instance
  // All operations on tx use the same connection
  
  const [user] = await tx
    .insert(users)
    .values({ email: 'alice@example.com', name: 'Alice' })
    .returning();

  const [org] = await tx
    .insert(organizations)
    .values({ name: "Alice's Org", slug: 'alices-org' })
    .returning();

  await tx.insert(organizationMembers).values({
    userId: user.id,
    organizationId: org.id,
    role: 'owner',
  });

  return { user, org };
});
// If ANY step throws, ALL are rolled back.
```

**Critical**: Always use the `tx` parameter inside the transaction callback, not the outer `db` object. Queries on `db` use a different connection from the pool and are NOT part of the transaction.

---

## 8.2 Automatic Rollback

```typescript
try {
  await db.transaction(async (tx) => {
    await tx.update(accounts)
      .set({ balance: sql`balance - 100` })
      .where(eq(accounts.id, fromAccountId));

    // Simulate a failure
    throw new Error('Payment processor timed out');
    
    // This never runs:
    await tx.update(accounts)
      .set({ balance: sql`balance + 100` })
      .where(eq(accounts.id, toAccountId));
  });
} catch (err) {
  // The deduction was rolled back
  console.error('Transfer failed, nothing was changed:', err);
}
```

When any exception is thrown inside `db.transaction()`, Drizzle executes `ROLLBACK` automatically.

---

## 8.3 Nested Transactions and Savepoints

PostgreSQL supports **savepoints** — named points within a transaction to which you can partially roll back.

```typescript
await db.transaction(async (tx) => {
  await tx.insert(orders).values({ userId, total: 500 });

  // Nested transaction = SAVEPOINT
  try {
    await tx.transaction(async (nestedTx) => {
      await nestedTx.insert(notifications).values({
        userId,
        message: 'Your order was placed',
      });
      // If this fails, only the notification is rolled back
      // The outer order insert is NOT rolled back
    });
  } catch {
    console.warn('Notification failed, but order proceeds');
  }
});
```

**Savepoint behavior in Drizzle**: Each nested `tx.transaction()` call creates a `SAVEPOINT`. Throwing an error inside rolls back to the savepoint, not the entire transaction.

---

## 8.4 Transaction Isolation Level

```typescript
await db.transaction(
  async (tx) => {
    const [account] = await tx
      .select()
      .from(accounts)
      .where(eq(accounts.id, id))
      .for('update'); // SELECT ... FOR UPDATE (row lock)
    
    if (account.balance < amount) {
      throw new Error('Insufficient funds');
    }
    
    await tx.update(accounts)
      .set({ balance: sql`balance - ${amount}` })
      .where(eq(accounts.id, id));
  },
  {
    isolationLevel: 'serializable', // Highest isolation
  }
);
```

---

## 8.5 Real-World: Document Submission Workflow

This is a realistic example for the Batac City DTS — filing a council resolution:

```typescript
async function fileResolution(payload: {
  title: string;
  content: string;
  filedById: number;
  year: number;
}) {
  return db.transaction(async (tx) => {
    // 1. Lock the sequence row to ensure gapless numbering
    const [seq] = await tx
      .select()
      .from(documentSequences)
      .where(
        and(
          eq(documentSequences.type, 'resolution'),
          eq(documentSequences.year, payload.year),
        )
      )
      .for('update'); // Row-level lock

    if (!seq) throw new Error(`No sequence for year ${payload.year}`);

    const docNumber = seq.currentNumber + 1;

    // 2. Increment sequence
    await tx
      .update(documentSequences)
      .set({ currentNumber: docNumber })
      .where(eq(documentSequences.id, seq.id));

    // 3. Insert document
    const [doc] = await tx
      .insert(documents)
      .values({
        type:           'resolution',
        documentNumber: docNumber,
        year:           payload.year,
        title:          payload.title,
        content:        payload.content,
        status:         'filed',
        filedById:      payload.filedById,
        filedAt:        new Date(),
      })
      .returning();

    // 4. Insert audit log entry
    await tx.insert(auditLogs).values({
      entityType: 'document',
      entityId:   doc.id,
      action:     'filed',
      actorId:    payload.filedById,
      newState:   JSON.stringify(doc),
    });

    return doc;
  });
}
```

This demonstrates: row locking to prevent duplicate numbers, gapless sequencing, and atomic document + audit log creation.

---

# Part 9: Migrations

---

## 9.1 Migration Fundamentals

A migration is a versioned, reproducible transformation of your database schema. Drizzle Kit manages migrations as plain SQL files — not abstract "up/down" objects or binary formats.

```
drizzle/
├── meta/
│   ├── _journal.json     ← tracks which migrations have run
│   └── 0000_snapshot.json
├── 0000_initial.sql
├── 0001_add_organizations.sql
└── 0002_add_audit_logs.sql
```

The journal file tracks the state:

```json
{
  "version": "7",
  "entries": [
    {
      "idx": 0,
      "version": "7",
      "when": 1706300000000,
      "tag": "0000_initial",
      "breakpoints": true
    },
    {
      "idx": 1,
      "when": 1706300100000,
      "tag": "0001_add_organizations",
      "breakpoints": true
    }
  ]
}
```

---

## 9.2 Generating Migrations

After modifying your schema, generate a migration:

```bash
pnpm drizzle-kit generate
```

Drizzle Kit compares your current schema to the last known snapshot and generates the SQL diff.

**Example workflow:**

```typescript
// schema/users.ts — you add a new column
export const users = pgTable('users', {
  id:          serial('id').primaryKey(),
  email:       text('email').notNull().unique(),
  name:        text('name').notNull(),
  phoneNumber: text('phone_number'),  // ← NEW
});
```

```bash
$ pnpm drizzle-kit generate

  drizzle-kit: v0.20.0
  drizzle-orm: v0.29.0

  1 tables changed;
  No new tables created
  1 columns added

  Generated: drizzle/0001_add_phone_number.sql
```

Generated file:

```sql
-- drizzle/0001_add_phone_number.sql
ALTER TABLE "users" ADD COLUMN "phone_number" text;
```

---

## 9.3 Applying Migrations

### In Production (Recommended: Programmatic)

```typescript
// src/db/migrate.ts
import { drizzle } from 'drizzle-orm/node-postgres';
import { migrate } from 'drizzle-orm/node-postgres/migrator';
import { Pool } from 'pg';

async function runMigrations() {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const db = drizzle(pool);

  console.log('Running migrations...');
  await migrate(db, { migrationsFolder: './drizzle' });
  console.log('Migrations complete.');

  await pool.end();
}

runMigrations().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
```

Run before starting your server:

```json
// package.json
{
  "scripts": {
    "db:migrate": "tsx src/db/migrate.ts",
    "start": "pnpm db:migrate && node dist/server.js"
  }
}
```

### CLI (Development)

```bash
pnpm drizzle-kit migrate
```

---

## 9.4 Safe Migration Patterns

### Adding a Nullable Column

```sql
-- SAFE: doesn't require backfill, no lock issues
ALTER TABLE "users" ADD COLUMN "middle_name" text;
```

### Adding a NOT NULL Column With a Default

```sql
-- SAFE: DB fills existing rows with the default
ALTER TABLE "users" ADD COLUMN "country_code" text NOT NULL DEFAULT 'PH';
```

### Adding a NOT NULL Column Without a Default (DANGEROUS)

```sql
-- DANGEROUS on a table with existing rows:
-- ALTER TABLE "users" ADD COLUMN "required_field" text NOT NULL;
-- ERROR: column "required_field" contains null values

-- SAFE 3-step approach:
-- Step 1: Add nullable
ALTER TABLE "users" ADD COLUMN "required_field" text;

-- Step 2: Backfill (in a migration or script)
UPDATE "users" SET "required_field" = 'default_value' WHERE "required_field" IS NULL;

-- Step 3: Add constraint in next deployment
ALTER TABLE "users" ALTER COLUMN "required_field" SET NOT NULL;
```

### Renaming a Column (DANGEROUS - breaks running code)

```sql
-- NEVER do this in one step on a live system:
-- ALTER TABLE "users" RENAME COLUMN "name" TO "full_name";
-- All code referencing "name" breaks immediately.

-- SAFE expand-contract pattern:
-- Step 1: Add new column
ALTER TABLE "users" ADD COLUMN "full_name" text;

-- Step 2: Backfill
UPDATE "users" SET "full_name" = "name";

-- Step 3: Make new column NOT NULL (if needed), deploy new code using full_name

-- Step 4 (later): Drop old column (after old code is gone)
ALTER TABLE "users" DROP COLUMN "name";
```

### Adding an Index Without Blocking Writes

```sql
-- DANGEROUS (acquires SHARE LOCK for duration):
-- CREATE INDEX users_email_idx ON users(email);

-- SAFE (concurrent — no blocking):
CREATE INDEX CONCURRENTLY "users_email_idx" ON "users"("email");
```

**Note**: Drizzle Kit does NOT automatically generate `CONCURRENTLY` for index creation in migrations. You should manually edit generated migrations to add `CONCURRENTLY` for indexes on large production tables.

---

## 9.5 Rollback Strategies

SQL migrations are not automatically reversible. Dropping a column or table destroys data.

**Strategy 1: Soft rollback (recommended)**
Keep the migration, write a forward fix migration.

```sql
-- 0005_fix_constraint.sql
-- Instead of reverting 0004, fix forward:
ALTER TABLE "users" DROP CONSTRAINT "users_email_check";
ALTER TABLE "users" ADD CONSTRAINT "users_email_check" 
  CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
```

**Strategy 2: Blue-green deployment**
Keep the old version running while the new version migrates. Route traffic back to old if new fails. Requires the schema to be backward compatible.

**Strategy 3: Pre-migration backup**
Before any destructive migration, take a database snapshot. This is the only reliable rollback for data-destructive changes.

---

## 9.6 Detecting Schema Drift

Schema drift occurs when the actual database schema diverges from what your migration files describe. This happens when someone runs manual SQL against production.

```bash
# Check for drift:
pnpm drizzle-kit check
```

This compares the current schema snapshot against what's in the database. Any differences are reported as warnings.

---

# Part 10: Drizzle Kit Deep Dive

---

## 10.1 Overview of Commands

```
drizzle-kit generate  → Compare schema to snapshot, generate SQL migration
drizzle-kit migrate   → Apply pending migrations to the database
drizzle-kit push      → Sync schema directly to DB (no migration file) - DEV ONLY
drizzle-kit pull      → Introspect existing DB, generate Drizzle schema
drizzle-kit check     → Validate migration files are consistent
drizzle-kit studio    → Launch web-based DB GUI
```

---

## 10.2 `generate` — Create Migration Files

```bash
pnpm drizzle-kit generate
pnpm drizzle-kit generate --name="add_phone_to_users"
```

**What happens internally:**
1. Reads your current schema files (from `schema` config)
2. Loads the previous schema snapshot from `meta/XXXX_snapshot.json`
3. Computes the diff (new tables, dropped columns, changed types, etc.)
4. Writes the SQL to a new numbered migration file
5. Updates the snapshot to the current schema state

**When to use:** After every schema change, during development. Commit both the migration file and the updated snapshot.

---

## 10.3 `migrate` — Apply Migrations

```bash
pnpm drizzle-kit migrate
```

**What happens internally:**
1. Connects to the database using `dbCredentials` from config
2. Checks the `__drizzle_migrations` table (or creates it if not present)
3. Finds all migration files in the `out` directory not yet applied
4. Applies each pending migration in order, in a transaction
5. Records each applied migration in `__drizzle_migrations`

---

## 10.4 `push` — Direct Schema Sync (Development Only)

```bash
pnpm drizzle-kit push
```

**What it does**: Reads your schema and applies the necessary DDL directly to the database, bypassing migration files entirely.

**CRITICAL WARNING**: `push` is for local development only. It can drop columns, change types, and alter constraints without creating a migration file. Using it in production is dangerous — it bypasses your migration history and review process.

**When to use `push`:**
- Rapid prototyping during initial development
- When you're iterating on schema design and don't want to generate a migration for every experiment
- On a local dev database that you're willing to reset

**Never use `push`:**
- On staging databases
- On production databases
- On any database shared with teammates

---

## 10.5 `pull` — Introspect Existing Database

```bash
pnpm drizzle-kit pull
```

**What it does**: Connects to your database, reads the existing schema, and generates Drizzle schema TypeScript files from it.

**When to use:**
- Adopting Drizzle on an existing database
- Onboarding to a project where the DB was set up without Drizzle
- As a starting point when migrating from another ORM

**Generated output**: The introspected schema is a starting point — it may need manual adjustments (especially for complex types, custom functions, or triggers not representable in Drizzle's schema API).

---

## 10.6 `check` — Validate Migration Consistency

```bash
pnpm drizzle-kit check
```

Validates that:
- All migration files are accounted for
- No migrations have been modified after being applied
- The migration history is consistent

Useful in CI/CD to catch modified or missing migration files.

---

## 10.7 `studio` — Web-Based Database GUI

```bash
pnpm drizzle-kit studio
# Opens at https://local.drizzle.studio
```

Drizzle Studio provides a web interface to:
- Browse tables and rows
- Run queries
- Edit data directly
- Inspect schema

**Use cases**: Debugging data issues during development, quick data inspection, team demos. Not a replacement for a proper admin interface in production.

---

## 10.8 Production Migration Workflow

```
Developer writes code
      │
      ▼
Adds/modifies schema.ts
      │
      ▼
pnpm drizzle-kit generate
      │
      ▼
Reviews generated SQL manually
  (Is it safe? Does it need CONCURRENTLY?
   Does it need backfill steps?)
      │
      ▼
Commits schema + migration files together
      │
      ▼
CI validates with drizzle-kit check
      │
      ▼
Staging deployment runs:
  tsx src/db/migrate.ts
      │
      ▼
QA on staging
      │
      ▼
Production deployment runs:
  tsx src/db/migrate.ts
  (before new app version starts)
      │
      ▼
New app version starts
```

**Key rule**: Migration files are immutable once committed. Never edit a migration that has already been applied to any environment.

---

*End of Parts 6–10*
# Part 11: Performance Engineering

---

## 11.1 Query Optimization Fundamentals

Performance problems in database-backed applications almost always fall into one of these categories:

```
1. Missing index              → Full table scan on large table
2. N+1 queries               → O(n) queries instead of O(1)
3. Over-fetching              → SELECTing more data than needed
4. Poorly constructed JOINs  → Joining in wrong order, no index on join key
5. Unindexed ORDER BY        → Filesort on large result sets
6. Lock contention           → Transactions blocking each other
7. Connection pool exhaustion → Requests queuing waiting for connections
```

---

## 11.2 The N+1 Problem

The N+1 problem is the single most common performance issue in ORM-backed applications.

```typescript
// ❌ N+1: 1 query for users + 1 query per user for posts
const users = await db.select().from(users);  // 1 query
for (const user of users) {
  const posts = await db.select().from(posts)  // N queries
    .where(eq(posts.userId, user.id));
  // process user.posts...
}
// For 100 users: 101 queries
```

### Solution 1: JOIN

```typescript
// ✅ 1 query total
const usersWithPosts = await db
  .select({ user: users, post: posts })
  .from(users)
  .leftJoin(posts, eq(posts.userId, users.id));

// Result is flat; reshape it:
const grouped = usersWithPosts.reduce((acc, row) => {
  const user = acc.get(row.user.id) ?? { ...row.user, posts: [] };
  if (row.post) user.posts.push(row.post);
  acc.set(row.user.id, user);
  return acc;
}, new Map<number, UserWithPosts>());
```

### Solution 2: Drizzle Relations API (2 queries, nested)

```typescript
// ✅ 2 queries (1 for users, 1 for all their posts)
const usersWithPosts = await db.query.users.findMany({
  with: { posts: true },
});
// Result is already nested: { ...user, posts: Post[] }[]
```

The relations API issues a `WHERE user_id IN (...)` query for the related records — not one query per user. For small-to-medium datasets this is efficient and avoids the JOIN reshaping.

### Solution 3: `inArray` batch (maximum control)

```typescript
// ✅ 2 queries, full control
const users = await db.select().from(users);
const userIds = users.map(u => u.id);

const posts = await db.select()
  .from(posts)
  .where(inArray(posts.userId, userIds));

// Combine in memory:
const postsByUser = posts.reduce((acc, post) => {
  (acc[post.userId] ??= []).push(post);
  return acc;
}, {} as Record<number, Post[]>);
```

---

## 11.3 Indexing Strategy

### Always Index Foreign Keys

PostgreSQL does NOT automatically create indexes on foreign key columns. This is a well-known gotcha:

```typescript
// Schema definition creates the FK constraint but NOT an index:
export const posts = pgTable('posts', {
  userId: integer('user_id').notNull().references(() => users.id),
}, (table) => ({
  // ← Must add this manually:
  userIdIdx: index('posts_user_id_idx').on(table.userId),
}));
```

Without this index, every `JOIN posts ON posts.user_id = users.id` performs a sequential scan on `posts`.

### Composite Index Column Order

Place the **most selective column first** in a composite index (the one that eliminates the most rows):

```typescript
// Query: WHERE org_id = ? AND status = ? AND created_at > ?
// If org_id is most selective (few rows per org), put it first:
index('docs_org_status_created').on(
  table.orgId,      // most selective
  table.status,     // second
  table.createdAt,  // range scan last
)
```

### Partial Indexes for Filtered Queries

If you frequently query only active records:

```typescript
// Instead of: index on all documents
// Create: index only on non-archived documents
index('docs_active_idx')
  .on(table.createdAt.desc())
  .where(sql`${table.status} != 'archived'`)
```

This index is smaller, faster to update, and the planner will use it for the common case.

---

## 11.4 Analyzing Query Plans

```typescript
// Get the query plan before executing:
const query = db.select()
  .from(documents)
  .where(eq(documents.status, 'approved'))
  .orderBy(desc(documents.createdAt));

console.log(query.toSQL());
// { sql: 'SELECT ... FROM "documents" WHERE "status" = $1 ORDER BY ...', params: ['approved'] }

// Run EXPLAIN ANALYZE directly:
const plan = await db.execute(
  sql`EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) ${query}`
);
console.log(JSON.stringify(plan.rows[0], null, 2));
```

**Key warning signs in EXPLAIN output:**
- `Seq Scan` on a large table with a low row estimate — missing index
- `Rows Removed by Filter: N` where N is large — index exists but isn't selective enough
- `Hash Join` with a very large `Batches` count — memory pressure
- `actual time` much larger than `estimated time` — stale statistics (run `ANALYZE`)

---

## 11.5 Connection Pool Sizing

The optimal pool size is not "as large as possible." More connections mean:
- More memory on the PostgreSQL server
- More context switching overhead
- Potential lock contention

A good rule of thumb from the PgBouncer documentation:

```
optimal_pool_size = num_cpu_cores * 2 + effective_spindle_count
```

For a modern cloud database: `pool_size = CPU_cores * 2` is a reasonable starting point.

```typescript
const pool = new Pool({
  connectionString: env.DATABASE_URL,
  max:                    20,    // Tune this based on your DB server's resources
  min:                    2,     // Keep 2 connections warm
  idleTimeoutMillis:      30000, // Close idle connections after 30s
  connectionTimeoutMillis: 5000, // Timeout if no connection available in 5s
});
```

### Detecting Pool Exhaustion

```typescript
pool.on('connect', () => metrics.increment('db.connections.created'));
pool.on('acquire', () => metrics.increment('db.connections.acquired'));
pool.on('remove', () => metrics.increment('db.connections.removed'));

// Pool exhaustion manifests as connectionTimeout errors.
// Monitor: pool.totalCount, pool.idleCount, pool.waitingCount
```

---

## 11.6 Generated SQL Quality Check

Always audit Drizzle's generated SQL for your most critical queries:

```typescript
const q = db.select({
  id:     documents.id,
  title:  documents.title,
  status: documents.status,
})
.from(documents)
.where(
  and(
    eq(documents.orgId, orgId),
    inArray(documents.status, ['filed', 'approved']),
  )
)
.orderBy(desc(documents.createdAt))
.limit(20);

console.log(q.toSQL());
```

Compare to hand-written SQL. If they differ meaningfully, the hand-written version may be faster. Use `db.execute(sql`...`)` for those cases.

---

# Part 12: Backend Framework Integration

---

## 12.1 Fastify Integration (Production Setup)

A full production Fastify setup with Drizzle — relevant to your stack:

```typescript
// src/plugins/database.ts
import fp from 'fastify-plugin';
import type { FastifyPluginAsync } from 'fastify';
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from '../db/schema';

declare module 'fastify' {
  interface FastifyInstance {
    db: ReturnType<typeof drizzle<typeof schema>>;
  }
}

const databasePlugin: FastifyPluginAsync = async (fastify) => {
  const pool = new Pool({
    connectionString: fastify.config.DATABASE_URL,
    max: fastify.config.DB_MAX_CONNECTIONS,
  });

  const db = drizzle(pool, { schema });

  // Graceful shutdown
  fastify.addHook('onClose', async () => {
    await pool.end();
  });

  fastify.decorate('db', db);
};

export default fp(databasePlugin, { name: 'database' });
```

```typescript
// src/server.ts
import Fastify from 'fastify';
import databasePlugin from './plugins/database';
import { userRoutes } from './modules/users/users.router';

const fastify = Fastify({ logger: true });

await fastify.register(databasePlugin);
await fastify.register(userRoutes, { prefix: '/api/users' });
```

```typescript
// src/modules/users/users.router.ts
import type { FastifyPluginAsync } from 'fastify';
import { userSchema } from './users.schema';

export const userRoutes: FastifyPluginAsync = async (fastify) => {
  fastify.get('/', async (request, reply) => {
    const users = await fastify.db.select().from(users);
    return users;
  });
};
```

---

## 12.2 tRPC Integration

Full tRPC + Drizzle integration — directly relevant to your DTS stack:

```typescript
// src/trpc/context.ts
import type { CreateFastifyContextOptions } from '@trpc/server/adapters/fastify';
import type { db } from '../db';

export interface TRPCContext {
  db:      typeof db;
  session: Session | null;
}

export async function createContext(
  opts: CreateFastifyContextOptions
): Promise<TRPCContext> {
  const session = await getSession(opts.req);
  return {
    db,
    session,
  };
}
```

```typescript
// src/trpc/router.ts
import { router, protectedProcedure, publicProcedure } from './trpc';
import { z } from 'zod';
import { eq, desc } from 'drizzle-orm';
import { documents } from '../db/schema';

export const documentsRouter = router({
  list: protectedProcedure
    .input(z.object({
      status: z.string().optional(),
      page:   z.number().int().min(1).default(1),
    }))
    .query(async ({ ctx, input }) => {
      const PAGE_SIZE = 20;
      const conditions = [];

      if (input.status) {
        conditions.push(eq(documents.status, input.status));
      }

      const docs = await ctx.db
        .select()
        .from(documents)
        .where(conditions.length ? and(...conditions) : undefined)
        .orderBy(desc(documents.createdAt))
        .limit(PAGE_SIZE)
        .offset((input.page - 1) * PAGE_SIZE);

      return { items: docs, page: input.page };
    }),

  file: protectedProcedure
    .input(z.object({
      title:   z.string().min(1),
      content: z.string().optional(),
    }))
    .mutation(async ({ ctx, input }) => {
      return fileResolution({
        ...input,
        filedById: ctx.session.userId,
        year: new Date().getFullYear(),
      });
    }),
});
```

---

## 12.3 NestJS Integration

```typescript
// database.module.ts
import { Module, Global } from '@nestjs/common';
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from './schema';

export const DB_TOKEN = Symbol('DB');

@Global()
@Module({
  providers: [
    {
      provide: DB_TOKEN,
      useFactory: () => {
        const pool = new Pool({
          connectionString: process.env.DATABASE_URL,
        });
        return drizzle(pool, { schema });
      },
    },
  ],
  exports: [DB_TOKEN],
})
export class DatabaseModule {}
```

```typescript
// users.service.ts
import { Injectable, Inject } from '@nestjs/common';
import { DB_TOKEN } from '../database.module';
import type { db } from '../database.module';
import { users } from '../schema';
import { eq } from 'drizzle-orm';

@Injectable()
export class UsersService {
  constructor(@Inject(DB_TOKEN) private db: typeof db) {}

  async findByEmail(email: string) {
    return this.db.query.users.findFirst({
      where: eq(users.email, email),
    });
  }
}
```

---

## 12.4 Next.js Integration

```typescript
// lib/db.ts — singleton for Next.js (avoids creating multiple pools in dev)
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from './schema';

declare global {
  // Prevent multiple pool instances in Next.js hot reload
  var _pgPool: Pool | undefined;
}

const pool = global._pgPool ?? new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,
});

if (process.env.NODE_ENV !== 'production') {
  global._pgPool = pool;
}

export const db = drizzle(pool, { schema });
```

```typescript
// app/api/documents/route.ts (Next.js App Router)
import { db } from '@/lib/db';
import { documents } from '@/lib/schema';
import { desc } from 'drizzle-orm';

export async function GET() {
  const docs = await db.select().from(documents)
    .orderBy(desc(documents.createdAt))
    .limit(20);

  return Response.json(docs);
}
```

---

## 12.5 The Repository Pattern with Drizzle

A repository encapsulates all database access for a domain entity behind a clean interface:

```typescript
// src/modules/documents/documents.repository.ts
import type { db as DB } from '../../db';
import { documents, type NewDocument, type Document } from '../../db/schema';
import { eq, and, desc, inArray, type SQL } from 'drizzle-orm';

export class DocumentsRepository {
  constructor(private db: typeof DB) {}

  async findById(id: number): Promise<Document | null> {
    const [doc] = await this.db
      .select()
      .from(documents)
      .where(eq(documents.id, id));
    return doc ?? null;
  }

  async findByIdOrThrow(id: number): Promise<Document> {
    const doc = await this.findById(id);
    if (!doc) throw new Error(`Document ${id} not found`);
    return doc;
  }

  async findMany(filters: {
    status?: string;
    type?:   string;
    year?:   number;
  }): Promise<Document[]> {
    const conditions: SQL[] = [];

    if (filters.status) conditions.push(eq(documents.status, filters.status));
    if (filters.type)   conditions.push(eq(documents.type, filters.type));
    if (filters.year)   conditions.push(eq(documents.year, filters.year));

    return this.db
      .select()
      .from(documents)
      .where(conditions.length ? and(...conditions) : undefined)
      .orderBy(desc(documents.createdAt));
  }

  async create(data: NewDocument): Promise<Document> {
    const [doc] = await this.db
      .insert(documents)
      .values(data)
      .returning();
    return doc;
  }

  async update(id: number, data: Partial<NewDocument>): Promise<Document> {
    const [doc] = await this.db
      .update(documents)
      .set({ ...data, updatedAt: new Date() })
      .where(eq(documents.id, id))
      .returning();

    if (!doc) throw new Error(`Document ${id} not found`);
    return doc;
  }
}
```

**Why repositories:**
- Testable: swap `db` with a mock in tests
- Co-location: all document queries in one file
- Reusable: services call the repository, not raw Drizzle
- Transaction-compatible: pass `tx` instead of `db`

### Transactions Across Repositories

```typescript
// service layer coordinates across repos
class DocumentService {
  constructor(
    private db: typeof DB,
    private docRepo: DocumentsRepository,
    private auditRepo: AuditRepository,
  ) {}

  async approveDocument(docId: number, approvedById: number) {
    return this.db.transaction(async (tx) => {
      // Use tx-scoped repos for transaction participation
      const txDocRepo   = new DocumentsRepository(tx as any);
      const txAuditRepo = new AuditRepository(tx as any);

      const doc = await txDocRepo.update(docId, {
        status:     'approved',
        approvedAt: new Date(),
      });

      await txAuditRepo.log({
        entityType: 'document',
        entityId:   docId,
        action:     'approved',
        actorId:    approvedById,
      });

      return doc;
    });
  }
}
```

---

# Part 13: Validation

---

## 13.1 Why Database Validation Is Insufficient

The database enforces constraints at the storage level. This is important but not enough:

```
User Input → (Validation Layer) → (Service Layer) → Drizzle → DB
                    ↑
         This is where bad data should be caught.
         The DB is the last line of defense, not the first.
```

**Problems with relying solely on DB constraints:**
- Error messages from DB exceptions are technical and user-unfriendly
- Multiple violations cannot be reported at once (DB throws on first violation)
- Complex business rules (is this a valid PH municipality code?) can't be expressed as DB constraints
- Type coercion issues are caught late

---

## 13.2 drizzle-zod

`drizzle-zod` generates Zod schemas from your Drizzle table definitions:

```bash
pnpm add drizzle-zod zod
```

```typescript
import { createInsertSchema, createSelectSchema, createUpdateSchema } from 'drizzle-zod';
import { z } from 'zod';

// Base schemas from Drizzle table
const insertDocumentSchema = createInsertSchema(documents);
const selectDocumentSchema = createSelectSchema(documents);

// Extend with business rules
const createDocumentInput = createInsertSchema(documents, {
  title:   z.string().min(3).max(500).trim(),
  content: z.string().max(100_000).optional(),
  year:    z.number().int().min(2000).max(2099),
}).omit({
  id:        true,  // auto-generated
  createdAt: true,  // auto-generated
  updatedAt: true,  // auto-generated
  contentHash: true, // computed by service
});

type CreateDocumentInput = z.infer<typeof createDocumentInput>;

// Update schema: all fields optional
const updateDocumentInput = createInsertSchema(documents, {
  title: z.string().min(3).max(500).trim(),
}).pick({
  title:   true,
  content: true,
  status:  true,
}).partial();

type UpdateDocumentInput = z.infer<typeof updateDocumentInput>;
```

---

## 13.3 Validation in tRPC Procedures

```typescript
import { z } from 'zod';

const createDocument = protectedProcedure
  .input(createDocumentInput)  // Zod schema validates + types input
  .mutation(async ({ ctx, input }) => {
    // input is fully typed and validated here
    return documentService.create(input, ctx.session.userId);
  });
```

---

## 13.4 Validation in Fastify Routes

```typescript
import { createDocumentInput } from '../schemas';

fastify.post('/documents', {
  schema: {
    body: createDocumentInput, // Fastify + Zod via fastify-type-provider-zod
  },
}, async (request, reply) => {
  const input = request.body; // fully typed and validated
  const doc = await documentService.create(input);
  return reply.code(201).send(doc);
});
```

---

## 13.5 Where Validation Lives

```
┌──────────────────────────────────────────────────────────────┐
│ Layer             │ What It Validates                        │
├──────────────────────────────────────────────────────────────┤
│ HTTP/Transport    │ Content-Type, rate limits, auth headers  │
│ Input (Zod)       │ Shape, format, business rules of input   │
│ Service Layer     │ Business invariants, authorization       │
│ Drizzle (types)   │ Shape matches schema at compile time     │
│ Database          │ Constraints, FK integrity, CHECK rules   │
└──────────────────────────────────────────────────────────────┘
```

---

# Part 14: Authentication & Authorization

---

## 14.1 Authentication Schema

A complete authentication schema using sessions (cookie-based):

```typescript
// src/db/schema/auth.ts
export const users = pgTable('users', {
  id:           bigserial('id', { mode: 'number' }).primaryKey(),
  email:        text('email').notNull(),
  passwordHash: text('password_hash').notNull(),
  displayName:  text('display_name').notNull(),
  emailVerifiedAt: timestamp('email_verified_at', { withTimezone: true }),
  mfaEnabled:   boolean('mfa_enabled').notNull().default(false),
  mfaSecret:    text('mfa_secret'),
  createdAt:    timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt:    timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
}, (table) => ({
  emailIdx: uniqueIndex('users_email_unique').on(table.email),
}));

export const sessions = pgTable('sessions', {
  id:        text('id').primaryKey(),  // random token
  userId:    bigint('user_id', { mode: 'number' }).notNull()
               .references(() => users.id, { onDelete: 'cascade' }),
  expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  ipAddress: text('ip_address'),
  userAgent: text('user_agent'),
}, (table) => ({
  userIdx:   index('sessions_user_idx').on(table.userId),
  expiresIdx: index('sessions_expires_idx').on(table.expiresAt),
}));

export const emailVerifications = pgTable('email_verifications', {
  id:        bigserial('id', { mode: 'number' }).primaryKey(),
  userId:    bigint('user_id', { mode: 'number' }).notNull()
               .references(() => users.id, { onDelete: 'cascade' }),
  token:     text('token').notNull().unique(),
  expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
  usedAt:    timestamp('used_at', { withTimezone: true }),
});
```

### Auth Queries

```typescript
// Login
async function login(email: string, password: string) {
  const [user] = await db.select()
    .from(users)
    .where(eq(users.email, email.toLowerCase()))
    .limit(1);

  if (!user) throw new InvalidCredentialsError();

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) throw new InvalidCredentialsError();

  const sessionId = crypto.randomUUID();
  await db.insert(sessions).values({
    id:        sessionId,
    userId:    user.id,
    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
  });

  return sessionId;
}

// Session lookup (called on every authenticated request)
async function getSessionUser(sessionId: string) {
  const [row] = await db
    .select({ user: users })
    .from(sessions)
    .innerJoin(users, eq(sessions.userId, users.id))
    .where(
      and(
        eq(sessions.id, sessionId),
        gt(sessions.expiresAt, new Date()), // not expired
      )
    )
    .limit(1);

  return row?.user ?? null;
}
```

---

## 14.2 Multi-Tenant Architecture

For the DTS, Batac City is a single tenant. But the pattern scales to multiple LGUs:

```typescript
export const tenants = pgTable('tenants', {
  id:   bigserial('id', { mode: 'number' }).primaryKey(),
  slug: text('slug').notNull().unique(),  // 'batac-city', 'laoag-city'
  name: text('name').notNull(),
});

// All documents scoped to a tenant
export const documents = pgTable('documents', {
  id:       bigserial('id', { mode: 'number' }).primaryKey(),
  tenantId: bigint('tenant_id', { mode: 'number' }).notNull()
              .references(() => tenants.id),
  // ...
}, (table) => ({
  tenantIdx: index('documents_tenant_idx').on(table.tenantId),
}));

// Middleware adds tenantId to every query:
async function getTenantDocuments(tenantId: number, filters: DocumentFilters) {
  return db.select()
    .from(documents)
    .where(and(
      eq(documents.tenantId, tenantId),  // always scope to tenant
      filters.status ? eq(documents.status, filters.status) : undefined,
    ));
}
```

**Row-level security (PostgreSQL RLS)** is an alternative: the database enforces tenant isolation at the SQL level. This is more secure but adds complexity. Consider it for highly security-critical multi-tenant systems.

---

# Part 15: Production Architecture

---

## 15.1 Where Drizzle Belongs in Clean Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    HTTP Layer                              │
│          (Fastify routes, tRPC procedures)                 │
└──────────────────────────┬─────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────────┐
│                  Application Layer                         │
│            (Use cases, Service classes)                    │
│         Input validation (Zod), Authorization              │
└──────────────────────────┬─────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────────┐
│                  Domain Layer                              │
│         (Business rules, Domain objects)                   │
│          Pure TypeScript, NO database imports              │
└──────────────────────────┬─────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────────┐
│                Infrastructure Layer                        │
│    Repositories (Drizzle), Email service, File storage     │
│           Drizzle lives HERE                               │
└────────────────────────────────────────────────────────────┘
```

Drizzle belongs in the **infrastructure layer**, behind repository interfaces. Domain objects and use cases should not import from `drizzle-orm` directly.

---

## 15.2 Modular Monolith Structure

For the DTS project (and most mid-size applications), a modular monolith is the right architecture:

```
src/
├── modules/
│   ├── documents/
│   │   ├── documents.schema.ts      ← Zod input schemas
│   │   ├── documents.repository.ts  ← Drizzle queries
│   │   ├── documents.service.ts     ← Business logic
│   │   ├── documents.router.ts      ← HTTP routes / tRPC procedures
│   │   └── documents.test.ts
│   ├── auth/
│   │   ├── auth.repository.ts
│   │   ├── auth.service.ts
│   │   └── auth.router.ts
│   └── users/
│       └── ...
├── db/
│   ├── index.ts
│   └── schema/
├── lib/
│   ├── env.ts
│   ├── errors.ts
│   └── logger.ts
└── server.ts
```

Each module owns its routes, service logic, and repository. Cross-module dependencies go through service interfaces, not repository-to-repository.

---

## 15.3 Service Layer Pattern

```typescript
// src/modules/documents/documents.service.ts
import { db } from '../../db';
import { DocumentsRepository } from './documents.repository';
import { AuditRepository } from '../audit/audit.repository';
import type { CreateDocumentInput, UpdateDocumentInput } from './documents.schema';

export class DocumentsService {
  private docRepo:   DocumentsRepository;
  private auditRepo: AuditRepository;

  constructor(private database: typeof db) {
    this.docRepo   = new DocumentsRepository(database);
    this.auditRepo = new AuditRepository(database);
  }

  async createDocument(input: CreateDocumentInput, actorId: number) {
    // Authorization check (could also be in middleware)
    // ...

    return this.database.transaction(async (tx) => {
      const txDocRepo   = new DocumentsRepository(tx as any);
      const txAuditRepo = new AuditRepository(tx as any);

      const doc = await txDocRepo.create({
        ...input,
        filedById: actorId,
        year: new Date().getFullYear(),
      });

      await txAuditRepo.log({
        entityType: 'document',
        entityId:   doc.id,
        action:     'created',
        actorId,
        newState:   JSON.stringify(doc),
      });

      return doc;
    });
  }
}

// Singleton for the app
export const documentsService = new DocumentsService(db);
```

---

*End of Parts 11–15*
# Part 16: Testing

---

## 16.1 Testing Strategy Overview

Database testing requires a different approach than unit testing pure functions. The database is stateful and external — tests must manage that state carefully.

```
┌─────────────────────────────────────────────────────────────┐
│ Test Type        │ DB Involvement  │ Speed    │ Confidence  │
├─────────────────────────────────────────────────────────────┤
│ Unit tests       │ None (mocked)   │ Fast     │ Low (logic) │
│ Integration tests│ Real DB         │ Slow     │ High        │
│ E2E tests        │ Real DB         │ Slowest  │ Highest     │
└─────────────────────────────────────────────────────────────┘
```

---

## 16.2 Unit Testing Repositories (Mocked DB)

```typescript
// documents.repository.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { DocumentsRepository } from './documents.repository';

// Build a minimal db mock that matches the interface
function createMockDb(returnValue: any = []) {
  const queryBuilder = {
    select:    vi.fn().mockReturnThis(),
    insert:    vi.fn().mockReturnThis(),
    update:    vi.fn().mockReturnThis(),
    delete:    vi.fn().mockReturnThis(),
    from:      vi.fn().mockReturnThis(),
    where:     vi.fn().mockReturnThis(),
    values:    vi.fn().mockReturnThis(),
    set:       vi.fn().mockReturnThis(),
    returning: vi.fn().mockResolvedValue(returnValue),
    limit:     vi.fn().mockReturnThis(),
    orderBy:   vi.fn().mockReturnThis(),
  };
  return queryBuilder as any;
}

describe('DocumentsRepository', () => {
  it('findById returns null when not found', async () => {
    const mockDb = createMockDb([]);
    const repo = new DocumentsRepository(mockDb);
    const result = await repo.findById(999);
    expect(result).toBeNull();
  });
});
```

**Caveat**: Mocking Drizzle is verbose and brittle — the fluent API chain means you're mocking implementation details, not behavior. For most teams, integration tests against a real (test) database are more valuable.

---

## 16.3 Integration Tests with a Test Database

### Setup with Vitest + PostgreSQL

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals:     true,
    environment: 'node',
    setupFiles:  ['./src/test/setup.ts'],
    testTimeout: 30_000,
    // Run tests serially to avoid DB conflicts (or use isolation strategy)
    pool:        'forks',
    poolOptions: { forks: { singleFork: true } },
  },
});
```

```typescript
// src/test/setup.ts
import { drizzle } from 'drizzle-orm/node-postgres';
import { migrate } from 'drizzle-orm/node-postgres/migrator';
import { Pool } from 'pg';
import * as schema from '../db/schema';

const TEST_DB_URL = process.env.TEST_DATABASE_URL
  ?? 'postgresql://postgres:postgres@localhost:5432/dts_test';

export let testDb: ReturnType<typeof drizzle<typeof schema>>;
let pool: Pool;

beforeAll(async () => {
  pool = new Pool({ connectionString: TEST_DB_URL, max: 5 });
  testDb = drizzle(pool, { schema });

  // Run migrations on test DB
  await migrate(testDb, { migrationsFolder: './src/db/migrations' });
});

afterAll(async () => {
  await pool.end();
});
```

### Transaction-Based Test Isolation

The cleanest approach: wrap each test in a transaction that you roll back at the end. The database is always in a clean state.

```typescript
// src/test/helpers.ts
import type { PgTransaction } from 'drizzle-orm/pg-core';

type TransactionDb = PgTransaction<any, any, any>;

export async function withTestTransaction<T>(
  fn: (tx: TransactionDb) => Promise<T>
): Promise<T> {
  return new Promise((resolve, reject) => {
    testDb.transaction(async (tx) => {
      try {
        const result = await fn(tx);
        // Force rollback by throwing after the result is captured
        resolve(result);
        throw new Error('__rollback__');
      } catch (err) {
        if ((err as Error).message !== '__rollback__') {
          reject(err);
          throw err;
        }
      }
    }).catch((err) => {
      // Swallow the forced rollback error
      if (err.message !== '__rollback__') reject(err);
    });
  });
}
```

```typescript
// documents.repository.test.ts (integration)
import { describe, it, expect } from 'vitest';
import { withTestTransaction } from '../test/helpers';
import { DocumentsRepository } from './documents.repository';

describe('DocumentsRepository (integration)', () => {
  it('creates and retrieves a document', async () => {
    await withTestTransaction(async (tx) => {
      const repo = new DocumentsRepository(tx as any);

      const doc = await repo.create({
        type:           'resolution',
        documentNumber: 1,
        year:           2024,
        title:          'Test Resolution',
        filedById:      1,
        status:         'draft',
      });

      expect(doc.id).toBeDefined();
      expect(doc.title).toBe('Test Resolution');

      const found = await repo.findById(doc.id);
      expect(found?.title).toBe('Test Resolution');

      // tx rolls back after this — no data persists
    });
  });
});
```

---

## 16.4 Testcontainers (Isolated PostgreSQL per Test Run)

[Inference] Testcontainers starts a real PostgreSQL container for your tests and tears it down afterward. This ensures test isolation from your development database.

```bash
pnpm add -D testcontainers
```

```typescript
// src/test/setup.ts (with Testcontainers)
import { PostgreSqlContainer } from '@testcontainers/postgresql';

let container: StartedPostgreSqlContainer;

beforeAll(async () => {
  container = await new PostgreSqlContainer('postgres:16')
    .withDatabase('dts_test')
    .withUsername('test')
    .withPassword('test')
    .start();

  const connectionString = container.getConnectionUri();
  pool = new Pool({ connectionString });
  testDb = drizzle(pool, { schema });

  await migrate(testDb, { migrationsFolder: './src/db/migrations' });
}, 60_000); // Testcontainers can take time to start

afterAll(async () => {
  await pool.end();
  await container.stop();
});
```

---

## 16.5 Seed Data

```typescript
// src/test/seed.ts
export async function seedTestData(db: any) {
  const [user] = await db.insert(users).values({
    email: 'test@batac.gov.ph',
    passwordHash: await bcrypt.hash('password', 10),
    displayName: 'Test User',
  }).returning();

  const [doc] = await db.insert(documents).values({
    type:           'resolution',
    documentNumber: 1,
    year:           2024,
    title:          'SP Resolution No. 1-2024',
    status:         'draft',
    filedById:      user.id,
  }).returning();

  return { user, doc };
}
```

---

# Part 17: Advanced PostgreSQL with Drizzle

---

## 17.1 JSONB Operations

```typescript
import { sql } from 'drizzle-orm';

// Query JSONB field
const docsWithTag = await db.select()
  .from(documents)
  .where(sql`${documents.metadata} @> '{"category": "urgent"}'::jsonb`);

// Extract JSONB value
const withCategory = await db.select({
  id:       documents.id,
  category: sql<string>`${documents.metadata}->>'category'`,
}).from(documents);

// Update JSONB field (merge)
await db.update(documents)
  .set({
    metadata: sql`${documents.metadata} || '{"reviewed": true}'::jsonb`,
  })
  .where(eq(documents.id, docId));

// GIN index for JSONB (in schema)
const docs = pgTable('documents', {
  metadata: jsonb('metadata').$type<DocumentMetadata>(),
}, (table) => ({
  metadataGin: index('docs_metadata_gin').using('gin', table.metadata),
}));
```

---

## 17.2 Array Operations

```typescript
import { sql, arrayContains, arrayOverlaps } from 'drizzle-orm';

// Documents tagged with 'urgent'
const urgent = await db.select()
  .from(documents)
  .where(arrayContains(documents.tags, ['urgent']));

// Documents tagged with any of these tags
const filtered = await db.select()
  .from(documents)
  .where(arrayOverlaps(documents.tags, ['urgent', 'priority', 'review']));

// Append to array
await db.update(documents)
  .set({
    tags: sql`array_append(${documents.tags}, 'processed')`,
  })
  .where(eq(documents.id, docId));

// Array length
const withCount = await db.select({
  id:       documents.id,
  tagCount: sql<number>`array_length(${documents.tags}, 1)`,
}).from(documents);
```

---

## 17.3 Full-Text Search with Generated Columns

```typescript
// Schema with generated tsvector
export const documents = pgTable('documents', {
  id:      bigserial('id', { mode: 'number' }).primaryKey(),
  title:   text('title').notNull(),
  content: text('content'),
  
  // Generated column for FTS
  searchVector: tsvector('search_vector').generatedAlwaysAs(
    sql`to_tsvector('english', 
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(content, '')), 'B')
    )`
  ),
}, (table) => ({
  // GIN index on the generated tsvector column
  ftsIdx: index('documents_fts_idx').using('gin', table.searchVector),
}));

// FTS query
async function searchDocuments(query: string) {
  return db.select({
    id:    documents.id,
    title: documents.title,
    rank:  sql<number>`ts_rank(${documents.searchVector}, 
                         plainto_tsquery('english', ${query}))`,
    headline: sql<string>`ts_headline('english', ${documents.title}, 
                            plainto_tsquery('english', ${query}),
                            'MaxWords=20, MinWords=10')`,
  })
  .from(documents)
  .where(
    sql`${documents.searchVector} @@ plainto_tsquery('english', ${query})`
  )
  .orderBy(
    sql`ts_rank(${documents.searchVector}, plainto_tsquery('english', ${query})) DESC`
  )
  .limit(20);
}
```

---

## 17.4 Enums

```typescript
export const statusEnum = pgEnum('document_status', ['draft', 'filed', 'approved']);

// Introspect enum values at runtime:
const statuses = statusEnum.enumValues;
// ['draft', 'filed', 'approved']

// TypeScript type:
type Status = typeof statusEnum.enumValues[number];
// 'draft' | 'filed' | 'approved'
```

**Adding a value to a PostgreSQL enum is safe** (doesn't rewrite existing data). Removing or renaming values is destructive.

```sql
-- Safe: add a new value
ALTER TYPE document_status ADD VALUE 'under_review';

-- DANGEROUS: cannot remove a value from a PostgreSQL enum
-- Workaround: create new enum, migrate column, drop old enum
```

---

## 17.5 Partitioning

Table partitioning splits large tables into smaller physical pieces by a partition key. Drizzle's schema API doesn't have native partition support, but you can manage partitioned tables with raw SQL in migrations.

```sql
-- In a migration file (managed manually):
CREATE TABLE documents (
  id         BIGSERIAL,
  year       INTEGER NOT NULL,
  title      TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (year);

CREATE TABLE documents_2023 PARTITION OF documents
  FOR VALUES FROM (2023) TO (2024);

CREATE TABLE documents_2024 PARTITION OF documents
  FOR VALUES FROM (2024) TO (2025);
```

Drizzle queries work on the parent table — PostgreSQL routes to the correct partition automatically.

---

## 17.6 pgvector (Vector Embeddings)

```bash
pnpm add pgvector
```

```typescript
import { customType } from 'drizzle-orm/pg-core';

// Define the vector type
const vector = customType<{
  data: number[];
  driverData: string;
}>({
  dataType(config?: { dimensions?: number }) {
    return config?.dimensions
      ? `vector(${config.dimensions})`
      : 'vector';
  },
  toDriver(value: number[]): string {
    return `[${value.join(',')}]`;
  },
  fromDriver(value: string): number[] {
    return value.slice(1, -1).split(',').map(Number);
  },
});

export const documentEmbeddings = pgTable('document_embeddings', {
  id:         bigserial('id', { mode: 'number' }).primaryKey(),
  documentId: bigint('document_id', { mode: 'number' }).notNull()
                .references(() => documents.id),
  embedding:  vector('embedding', { dimensions: 1536 }),
}, (table) => ({
  // IVFFlat index for approximate nearest neighbor search
  embeddingIdx: sql`CREATE INDEX ON document_embeddings 
                    USING ivfflat (embedding vector_cosine_ops) 
                    WITH (lists = 100)`,
}));

// Similarity search:
const similar = await db.select({
  documentId: documentEmbeddings.documentId,
  similarity: sql<number>`1 - (embedding <=> ${JSON.stringify(queryVector)}::vector)`,
})
.from(documentEmbeddings)
.orderBy(sql`embedding <=> ${JSON.stringify(queryVector)}::vector`)
.limit(10);
```

---

# Part 18: Real-World Case Study

---

## 18.1 Overview: Document Tracking System (DTS)

This case study builds a production-grade backend for a Philippine LGU document tracking system — directly relevant to your project. We'll show the full architecture.

### Domain Objects

- `Users` — SP (Sangguniang Panlungsod) staff, council members, citizens
- `Documents` — resolutions, ordinances, motions
- `DocumentSequences` — gapless numbering per type per year
- `DocumentVersions` — immutable audit trail of changes
- `AuditLogs` — who did what and when
- `Sessions` — authentication sessions

---

## 18.2 Complete Schema

```typescript
// src/db/schema/auth.ts
export const users = pgTable('users', {
  id:              bigserial('id', { mode: 'number' }).primaryKey(),
  email:           text('email').notNull(),
  passwordHash:    text('password_hash').notNull(),
  displayName:     text('display_name').notNull(),
  role:            roleEnum('role').notNull().default('staff'),
  isActive:        boolean('is_active').notNull().default(true),
  mfaEnabled:      boolean('mfa_enabled').notNull().default(false),
  mfaSecret:       text('mfa_secret'),
  createdAt:       timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt:       timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
}, (t) => ({
  emailIdx: uniqueIndex('users_email_unique').on(t.email),
}));

export const sessions = pgTable('sessions', {
  id:        text('id').primaryKey(),
  userId:    bigint('user_id', { mode: 'number' }).notNull().references(() => users.id, { onDelete: 'cascade' }),
  expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  ipAddress: text('ip_address'),
  userAgent: text('user_agent'),
}, (t) => ({
  userIdx: index('sessions_user_idx').on(t.userId),
  expiresIdx: index('sessions_expires_idx').on(t.expiresAt),
}));

// src/db/schema/documents.ts
export const documentTypeEnum    = pgEnum('document_type', ['resolution', 'ordinance', 'motion', 'proclamation']);
export const documentStatusEnum  = pgEnum('document_status', ['draft', 'filed', 'committee_review', 'floor_deliberation', 'approved', 'vetoed', 'lapsed', 'archived']);
export const roleEnum            = pgEnum('user_role', ['admin', 'secretary', 'staff', 'council_member', 'viewer']);

// Gapless number sequences
export const documentSequences = pgTable('document_sequences', {
  id:            serial('id').primaryKey(),
  type:          documentTypeEnum('type').notNull(),
  year:          integer('year').notNull(),
  currentNumber: integer('current_number').notNull().default(0),
}, (t) => ({
  typeYearUnique: uniqueIndex('doc_seq_type_year').on(t.type, t.year),
}));

export const documents = pgTable('documents', {
  id:             bigserial('id', { mode: 'number' }).primaryKey(),
  type:           documentTypeEnum('type').notNull(),
  documentNumber: integer('document_number').notNull(),
  year:           integer('year').notNull(),
  title:          text('title').notNull(),
  description:    text('description'),
  content:        text('content'),
  status:         documentStatusEnum('status').notNull().default('draft'),
  contentHash:    text('content_hash'),      // SHA-256 of content
  previousHash:   text('previous_hash'),     // Hash chain
  filedById:      bigint('filed_by_id', { mode: 'number' }).notNull(),
  metadata:       jsonb('metadata').$type<DocumentMetadata>(),
  tags:           text('tags').array(),
  filedAt:        timestamp('filed_at', { withTimezone: true }),
  approvedAt:     timestamp('approved_at', { withTimezone: true }),
  createdAt:      timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt:      timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
}, (t) => ({
  docNumUnique: uniqueIndex('doc_number_type_year_unique').on(t.documentNumber, t.type, t.year),
  statusIdx:    index('documents_status_idx').on(t.status),
  typeYearIdx:  index('documents_type_year_idx').on(t.type, t.year),
  filedByIdx:   index('documents_filed_by_idx').on(t.filedById),
}));

// Immutable version history (append-only)
export const documentVersions = pgTable('document_versions', {
  id:          bigserial('id', { mode: 'number' }).primaryKey(),
  documentId:  bigint('document_id', { mode: 'number' }).notNull()
                 .references(() => documents.id),
  version:     integer('version').notNull(),
  title:       text('title').notNull(),
  content:     text('content'),
  status:      documentStatusEnum('status').notNull(),
  contentHash: text('content_hash').notNull(),
  editedById:  bigint('edited_by_id', { mode: 'number' }).notNull(),
  createdAt:   timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
}, (t) => ({
  docVersionUnique: uniqueIndex('doc_version_unique').on(t.documentId, t.version),
  docIdx:           index('doc_versions_doc_idx').on(t.documentId),
}));

// Comprehensive audit log
export const auditLogs = pgTable('audit_logs', {
  id:         bigserial('id', { mode: 'number' }).primaryKey(),
  entityType: text('entity_type').notNull(),
  entityId:   bigint('entity_id', { mode: 'number' }),
  action:     text('action').notNull(),
  actorId:    bigint('actor_id', { mode: 'number' }),
  oldState:   jsonb('old_state'),
  newState:   jsonb('new_state'),
  ipAddress:  text('ip_address'),
  createdAt:  timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
}, (t) => ({
  entityIdx: index('audit_entity_idx').on(t.entityType, t.entityId),
  actorIdx:  index('audit_actor_idx').on(t.actorId),
  dateIdx:   index('audit_date_idx').on(t.createdAt.desc()),
}));
```

---

## 18.3 Core Service: Filing a Resolution

```typescript
// src/modules/documents/documents.service.ts
import crypto from 'node:crypto';

export class DocumentsService {
  constructor(private db: typeof db) {}

  async fileDocument(input: {
    type:     DocumentType;
    title:    string;
    content?: string;
    year:     number;
    filedById: number;
    ipAddress?: string;
  }) {
    return this.db.transaction(async (tx) => {
      // 1. Lock sequence row (pessimistic locking)
      const [seq] = await tx
        .select()
        .from(documentSequences)
        .where(and(
          eq(documentSequences.type, input.type),
          eq(documentSequences.year, input.year),
        ))
        .for('update');

      if (!seq) {
        // Auto-create sequence for new year
        const [newSeq] = await tx.insert(documentSequences)
          .values({ type: input.type, year: input.year, currentNumber: 0 })
          .returning();
        Object.assign(seq ?? {}, newSeq);
      }

      const docNumber = (seq?.currentNumber ?? 0) + 1;

      // 2. Increment sequence atomically
      await tx.update(documentSequences)
        .set({ currentNumber: docNumber })
        .where(eq(documentSequences.id, seq!.id));

      // 3. Compute content hash
      const contentHash = input.content
        ? crypto.createHash('sha256').update(input.content).digest('hex')
        : null;

      // 4. Get previous document's hash (for chain)
      const [prevDoc] = await tx.select({ hash: documents.contentHash })
        .from(documents)
        .where(and(
          eq(documents.type, input.type),
          eq(documents.year, input.year),
        ))
        .orderBy(desc(documents.documentNumber))
        .limit(1);

      // 5. Insert document
      const [doc] = await tx.insert(documents).values({
        type:           input.type,
        documentNumber: docNumber,
        year:           input.year,
        title:          input.title,
        content:        input.content,
        status:         'filed',
        contentHash,
        previousHash:   prevDoc?.hash ?? null,
        filedById:      input.filedById,
        filedAt:        new Date(),
      }).returning();

      // 6. Create first version snapshot
      await tx.insert(documentVersions).values({
        documentId:  doc.id,
        version:     1,
        title:       doc.title,
        content:     doc.content,
        status:      doc.status,
        contentHash: contentHash ?? '',
        editedById:  input.filedById,
      });

      // 7. Audit log
      await tx.insert(auditLogs).values({
        entityType: 'document',
        entityId:   doc.id,
        action:     'filed',
        actorId:    input.filedById,
        newState:   doc,
        ipAddress:  input.ipAddress,
      });

      return doc;
    });
  }
}
```

---

# Part 19: Common Pitfalls

---

## 19.1 Beginner Mistakes

### Forgetting `await`

```typescript
// ❌ Wrong: query builder is not a Promise — it needs await
const users = db.select().from(users); // Returns builder, not data!

// ✅ Correct:
const users = await db.select().from(users);
```

### Using `push` in Production

```bash
# ❌ Never in production:
pnpm drizzle-kit push

# ✅ Always use migration files:
pnpm drizzle-kit migrate
```

### Not Using `tx` Inside Transactions

```typescript
// ❌ Wrong: uses outer db — NOT in the transaction
await db.transaction(async (tx) => {
  await db.insert(orders).values(order);  // ← db, not tx!
  await db.insert(orderItems).values(items); // Different connection!
});

// ✅ Correct:
await db.transaction(async (tx) => {
  await tx.insert(orders).values(order);
  await tx.insert(orderItems).values(items);
});
```

### Missing Index on Foreign Key

```typescript
// ❌ FK without index — slow JOINs
export const posts = pgTable('posts', {
  userId: integer('user_id').notNull().references(() => users.id),
  // No index on userId!
});

// ✅ Always add index:
export const posts = pgTable('posts', {
  userId: integer('user_id').notNull().references(() => users.id),
}, (t) => ({
  userIdx: index('posts_user_idx').on(t.userId),
}));
```

### Using FLOAT for Money

```typescript
// ❌ Floating-point imprecision for financial data
price: real('price')  // 0.1 + 0.2 = 0.30000000000000004

// ✅ Exact decimal
price: numeric('price', { precision: 10, scale: 2 })
```

---

## 19.2 Intermediate Mistakes

### Unguarded Dynamic WHERE

```typescript
// ❌ SQL injection risk if filters come from untrusted input
const status = request.query.status as string;
const results = await db.execute(
  sql`SELECT * FROM documents WHERE status = '${status}'` // INJECTION RISK
);

// ✅ Always use parameterized queries
const results = await db.select()
  .from(documents)
  .where(eq(documents.status, status)); // Drizzle parameterizes automatically
```

### Accidental Full Table UPDATE/DELETE

```typescript
// ❌ No WHERE clause — updates every row
await db.update(users).set({ isActive: false });

// ✅ Always specify WHERE
await db.update(users).set({ isActive: false }).where(eq(users.id, userId));
```

### Ignoring Nullability in Results

```typescript
// ❌ Assuming findFirst always returns a row
const user = await db.query.users.findFirst();
console.log(user.email); // TypeError if user is undefined!

// ✅ Check for null/undefined
const user = await db.query.users.findFirst({ where: eq(users.id, id) });
if (!user) throw new NotFoundError('User not found');
```

### Timestamp Timezone Issues

```typescript
// ❌ TIMESTAMP without timezone — ambiguous
createdAt: timestamp('created_at')

// ✅ Always use TIMESTAMPTZ
createdAt: timestamp('created_at', { withTimezone: true })
```

---

## 19.3 Scaling Mistakes

### Missing Pagination

```typescript
// ❌ Fetches all rows — catastrophic on large tables
const allDocs = await db.select().from(documents);

// ✅ Always paginate
const docs = await db.select().from(documents).limit(20).offset(0);
```

### SELECT * in Hot Paths

```typescript
// ❌ Fetching all columns when you only need 2
const docs = await db.select().from(documents); // fetches content (potentially large)

// ✅ Select only needed columns
const docs = await db.select({
  id:     documents.id,
  title:  documents.title,
  status: documents.status,
}).from(documents);
```

### Deep Relation Nesting

```typescript
// ❌ Each level = another round trip
const data = await db.query.orgs.findMany({
  with: {
    members: {
      with: {
        user: {
          with: {
            posts: {
              with: { comments: true } // 5 query round trips!
            }
          }
        }
      }
    }
  }
});

// ✅ Use explicit JOINs or flatten the query
```

---

## 19.4 Migration Disasters

### Editing a Committed Migration

```
# ❌ Never do this — causes corruption
vi drizzle/0003_add_column.sql  # Edit after commit

# The snapshot and migration file will be out of sync
# Future migrations will generate incorrect diffs
```

### Renaming a Column in One Step

```sql
-- ❌ Breaks all running code immediately
ALTER TABLE "users" RENAME COLUMN "name" TO "full_name";

-- ✅ Use expand-contract (see Part 9)
```

### Missing Backfill for NOT NULL Columns

```sql
-- ❌ Fails on non-empty tables
ALTER TABLE "users" ADD COLUMN "country" TEXT NOT NULL;

-- ✅ Add with default, then tighten later
ALTER TABLE "users" ADD COLUMN "country" TEXT NOT NULL DEFAULT 'PH';
-- Later: remove the default if desired
ALTER TABLE "users" ALTER COLUMN "country" DROP DEFAULT;
```

---

## 19.5 Type Safety Misconceptions

### "TypeScript guarantees correct data"

[Unverified] — TypeScript types are erased at runtime. Drizzle's type system tells you the _shape_ of data but not its _validity_. A `string` type doesn't prevent `"not-an-email"` from being stored. Add Zod validation.

### "drizzle-kit push is safe in dev"

It can drop columns and tables. Use it only on databases you're willing to reset entirely.

### "Drizzle infers return types perfectly"

When using raw `sql` template literals, you must manually specify the return type. Drizzle cannot infer types from arbitrary SQL strings.

```typescript
// Type is sql<unknown> if not specified
const result = await db.select({
  count: sql`count(*)`,       // unknown
}).from(users);

// ✅ Annotate manually
const result = await db.select({
  count: sql<number>`count(*)::int`,  // cast in SQL + type annotation
}).from(users);
```

---

# Part 20: Production Checklist

---

## 20.1 Development Checklist

- [ ] `strict: true` in `tsconfig.json`
- [ ] Environment variables validated at startup with Zod
- [ ] `db` instance exported as singleton
- [ ] Schema files co-locate `$inferSelect` and `$inferInsert` types
- [ ] All FK columns have corresponding indexes
- [ ] All timestamps use `withTimezone: true`
- [ ] Financial columns use `numeric`, not `real` or `doublePrecision`
- [ ] Enums defined in schema, not raw text columns with magic strings
- [ ] Relations defined for all FK relationships you'll query with `.with()`
- [ ] All queries use `.limit()` in list endpoints

## 20.2 Schema Checklist

- [ ] Every table has `created_at` and `updated_at`
- [ ] Soft-delete implemented with `deleted_at` (not hard delete for audit-critical data)
- [ ] No column named `data`, `info`, `misc` — be explicit
- [ ] All text columns that have value constraints use CHECK or enum
- [ ] Money columns are `NUMERIC(p,s)` with appropriate precision
- [ ] UUIDs use `uuid` type, not `text`
- [ ] All arrays are typed (`text('x').array()`, not `jsonb`)
- [ ] JSONB columns have `.$type<YourInterface>()` specified
- [ ] Composite unique constraints enforce business uniqueness rules
- [ ] Partial indexes on soft-deleted tables (`WHERE deleted_at IS NULL`)

## 20.3 Migration Checklist

- [ ] Migration reviewed by a second engineer before applying to staging
- [ ] No `DROP COLUMN` or `DROP TABLE` without a preceding code release that stops using it
- [ ] Large index additions use `CREATE INDEX CONCURRENTLY` (edit migration manually)
- [ ] `NOT NULL` columns with no default have a 3-step migration plan
- [ ] Column renames use expand-contract pattern
- [ ] Type changes have explicit `USING` cast clause
- [ ] Migration tested on a staging environment with production-sized data
- [ ] Pre-migration backup taken for production

## 20.4 Performance Checklist

- [ ] `EXPLAIN ANALYZE` run on all queries in hot paths
- [ ] No N+1 queries in list endpoints (use JOIN or relations API)
- [ ] No `SELECT *` in production list queries
- [ ] Connection pool size configured (not left at default)
- [ ] Idle connections timeout configured
- [ ] Slow query log enabled (`log_min_duration_statement = 1000`)
- [ ] Regular `VACUUM ANALYZE` scheduled or autovacuum tuned

## 20.5 Security Checklist

- [ ] No raw string interpolation in SQL queries
- [ ] All user input validated with Zod before reaching the DB
- [ ] Passwords stored with bcrypt (cost >= 12), not MD5 or SHA
- [ ] Session tokens are cryptographically random (`crypto.randomUUID()`)
- [ ] Session expiry enforced in the query (`expiresAt > NOW()`)
- [ ] Connection string not committed to version control
- [ ] DB user has only required permissions (not superuser for app)
- [ ] TLS enforced on database connection in production

## 20.6 Deployment Checklist

- [ ] Migrations run before new application version starts
- [ ] Migration runner handles already-applied migrations gracefully (idempotent)
- [ ] Zero-downtime migration compatibility verified (old code + new schema works)
- [ ] Rollback plan documented and tested for each migration
- [ ] DB connection pool drained on graceful shutdown (`pool.end()` in `onClose`)

---

# Part 21: Drizzle Mastery Roadmap

---

## Stage 1: Beginner

**Goal**: Ship CRUD without breaking things.

**Concepts to learn:**
- Install and configure Drizzle with PostgreSQL
- Define tables with basic column types
- Understand `$inferSelect` and `$inferInsert`
- Basic CRUD: select, insert, update, delete
- Basic WHERE conditions: `eq`, `and`, `or`
- Run `drizzle-kit generate` and `migrate`

**Projects to build:**
- Simple todo list API with Fastify
- Basic user authentication (register, login, sessions)

**Skills to demonstrate:**
- Can define a schema and generate a migration
- Can write all CRUD operations
- Understands the difference between `db.select()` and `db.query.*`

**Common mistakes at this stage:**
- Forgetting `await`
- Using `push` and thinking it's the same as `migrate`
- Not indexing FKs
- Not using `returning()`

---

## Stage 2: Intermediate

**Goal**: Build production-quality features with relations and transactions.

**Concepts to learn:**
- Relations API (`one`, `many`) and when to use `.with()` vs JOINs
- Transactions and the `tx` parameter
- Cursor-based pagination
- Dynamic WHERE conditions with optional filters
- drizzle-zod for input validation
- Repository pattern
- `inArray`, `ilike`, `between`, `isNull`
- Composite indexes and partial indexes

**Projects to build:**
- Multi-user app with organizations and memberships
- Document management system with status workflow
- Activity feed with efficient pagination

**Skills to demonstrate:**
- No N+1 queries in any list endpoint
- Uses transactions for multi-step operations
- All user input validated before reaching the DB
- Can write a repository with typed methods

**Common mistakes at this stage:**
- Deep relation nesting without considering round-trip cost
- Using `push` for schema exploration on a shared DB
- Not annotating `sql` raw expressions with return types
- Editing committed migration files

---

## Stage 3: Advanced

**Goal**: Handle complex queries, optimize performance, design for scale.

**Concepts to learn:**
- CTEs and recursive CTEs
- Window functions via `sql` template
- JSONB operators and GIN indexing
- Full-text search with `tsvector`/`tsquery`
- Partial updates and safe schema evolution patterns
- `EXPLAIN ANALYZE` and query plan reading
- Connection pool tuning
- Row-level locking (`FOR UPDATE`, `FOR SHARE`)
- Expand-contract migration patterns

**Projects to build:**
- Graph-traversal feature (org hierarchy, threaded comments)
- Full-text search across document content
- Analytics dashboard with window functions and materialized views
- Audit log system with hash chains

**Skills to demonstrate:**
- Can read and interpret EXPLAIN ANALYZE output
- Designs multi-step migrations safely
- Can replace N+1 with a single JOIN and reshape results
- Can implement pessimistic locking correctly

---

## Stage 4: Production Expert

**Goal**: Own the database layer end-to-end on a production system.

**Concepts to learn:**
- Zero-downtime migration strategies
- Table partitioning
- Connection pooling with PgBouncer
- Database replication (read replicas via multiple `db` instances)
- Testcontainers integration testing
- RLS (Row-Level Security) as an alternative to application-level tenant isolation
- Monitoring: slow query logs, pg_stat_statements, connection metrics
- pgvector for ML-powered features

**Projects to build:**
- Migrate a production schema with zero downtime
- Implement multi-tenancy with RLS or application-level scoping
- Build and benchmark a full-text search solution
- Set up CI with Testcontainers for migration correctness

**Skills to demonstrate:**
- Has shipped a non-trivial migration to production without downtime
- Can audit any codebase for N+1 queries and fix them
- Understands the generated SQL for every Drizzle query they write
- Can diagnose a slow query from EXPLAIN ANALYZE alone
- Implements the full security checklist on every project

---

## Summary: The Drizzle Mental Models to Internalize

1. **Drizzle is SQL with types.** Every query you write should map cleanly to SQL in your head.

2. **The schema is the single source of truth.** Types, validation schemas, and documentation should derive from it.

3. **The `tx` parameter is the transaction.** Never use the outer `db` inside a transaction.

4. **Foreign keys need indexes.** Always. Without exception.

5. **Migrations are immutable contracts.** Never edit a committed migration.

6. **Timestamps store UTC.** Always use `withTimezone: true`.

7. **Money uses `numeric`.** Never `real` or `doublePrecision`.

8. **Every list endpoint paginates.** No exceptions.

9. **TypeScript checks shape; Zod checks values; the DB checks constraints.** You need all three.

10. **EXPLAIN ANALYZE is your friend.** Run it on every critical query path before deploying.

---

*End of The Drizzle ORM Engineering Handbook*

---

> **Document metadata**
> - Covers: drizzle-orm, drizzle-kit, PostgreSQL, MySQL, SQLite, Turso, Neon, PlanetScale
> - Relevant stack: Node.js, TypeScript 5+, Fastify, tRPC, Zod, pnpm, Turborepo
> - Accuracy labels: [Inference] = logically reasoned, [Speculation] = unconfirmed possibility, [Unverified] = no reliable source
> - PostgreSQL-specific features labeled where not applicable to other dialects