# sqlc: A Comprehensive Guide

sqlc is a code generator for Go (and increasingly other languages) that turns SQL queries into type-safe, idiomatic code. Instead of writing database boilerplate by hand or reaching for a full ORM, you write plain SQL and let sqlc generate the Go structs and functions that match exactly what your queries do. The result is code that behaves predictably, is easy to test, and stays in sync with your schema.

---

## How sqlc Works

The workflow is schema-first:

1. Write your SQL schema (DDL: `CREATE TABLE`, etc.)
2. Write annotated SQL queries with special comments
3. Run `sqlc generate`
4. Use the generated Go types and functions in your application

sqlc parses your SQL, understands what columns each query returns, and emits a Go package with one function per query. If the SQL is invalid, `sqlc generate` fails — catching errors at compile time rather than at runtime.

---

## Installation

### Via Go

```bash
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
```

### Via Homebrew (macOS/Linux)

```bash
brew install sqlc
```

### Via Docker

```bash
docker run --rm -v $(pwd):/src -w /src sqlc/sqlc generate
```

### Verify

```bash
sqlc version
```

---

## Project Structure

A typical sqlc project looks like this:

```
myapp/
├── sqlc.yaml          # sqlc configuration
├── db/
│   ├── migrations/    # schema files (DDL)
│   │   └── 001_init.sql
│   └── query/         # annotated query files
│       └── users.sql
└── internal/
    └── db/            # generated output directory
        ├── db.go
        ├── models.go
        └── query.sql.go
```

You can arrange this however you like — sqlc only cares about what you point it to in `sqlc.yaml`.

---

## Configuration: sqlc.yaml

The `sqlc.yaml` (or `sqlc.yml`) file controls everything. A minimal example:

```yaml
version: "2"
sql:
  - engine: "postgresql"
    queries: "db/query/"
    schema: "db/migrations/"
    gen:
      go:
        package: "db"
        out: "internal/db"
```

### Full Configuration Reference

```yaml
version: "2"
sql:
  - engine: "postgresql"           # postgresql, mysql, or sqlite
    queries: "db/query/"           # path(s) to query files
    schema: "db/migrations/"       # path(s) to schema files
    gen:
      go:
        package: "db"              # Go package name
        out: "internal/db"         # output directory
        sql_package: "pgx/v5"      # database/sql, pgx/v4, pgx/v5
        emit_json_tags: true       # add json tags to structs
        emit_db_tags: false        # add db tags (for sqlx)
        emit_prepared_queries: false
        emit_interface: true       # emit a Querier interface
        emit_exact_table_names: false  # pluralize struct names by default
        emit_empty_slices: true    # return [] instead of nil for list queries
        emit_exported_queries: false
        emit_result_struct_pointers: false
        emit_params_struct_pointers: false
        emit_methods_with_db_argument: false
        overrides:                 # type overrides (see below)
          - db_type: "uuid"
            go_type: "github.com/google/uuid.UUID"
        rename:                    # rename generated struct fields
          created_at: "CreatedAt"
```

### engine values

`postgresql` parses full PostgreSQL syntax including CTEs, window functions, and `ON CONFLICT`. `mysql` supports MySQL/MariaDB. `sqlite` supports SQLite 3. Each engine has different supported features.

### sql_package values

`database/sql` uses the standard library. `pgx/v4` and `pgx/v5` use the jackc/pgx driver directly and support PostgreSQL-native types like `pgtype.UUID`, `pgtype.Timestamptz`, and arrays without conversion overhead.

---

## Schema Files

Schema files are plain DDL SQL. sqlc reads them to understand the shape of your tables — it does not run them. You can point `schema` at a directory of migration files, a single file, or a glob.

```sql
-- db/migrations/001_init.sql

CREATE TABLE users (
    id         BIGSERIAL PRIMARY KEY,
    email      TEXT      NOT NULL UNIQUE,
    name       TEXT      NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE posts (
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT    NOT NULL REFERENCES users(id),
    title      TEXT      NOT NULL,
    body       TEXT      NOT NULL DEFAULT '',
    published  BOOLEAN   NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

sqlc supports most DDL including `CREATE TABLE`, `ALTER TABLE`, `CREATE INDEX`, `CREATE TYPE` (enums), and `DROP TABLE`.

---

## Query Files and Annotations

Every query must have a sqlc annotation comment immediately before it:

```sql
-- name: <FunctionName> :<command>
```

The command tells sqlc what kind of function to generate:

|Command|Description|Returns|
|---|---|---|
|`:one`|Fetch a single row|`(Row, error)`|
|`:many`|Fetch multiple rows|`([]Row, error)`|
|`:exec`|Execute with no return|`error`|
|`:execrows`|Execute, return rows affected|`(int64, error)`|
|`:execresult`|Execute, return `sql.Result`|`(sql.Result, error)`|
|`:copyfrom`|PostgreSQL COPY bulk insert|`(int64, error)`|
|`:batchexec`|pgx batch execute|`error`|
|`:batchmany`|pgx batch with rows|`([]Row, error)`|
|`:batchone`|pgx batch single row|`(Row, error)`|

### Example Query File

```sql
-- db/query/users.sql

-- name: GetUser :one
SELECT * FROM users
WHERE id = $1 AND deleted_at IS NULL
LIMIT 1;

-- name: GetUserByEmail :one
SELECT * FROM users
WHERE email = $1 AND deleted_at IS NULL
LIMIT 1;

-- name: ListUsers :many
SELECT * FROM users
WHERE deleted_at IS NULL
ORDER BY created_at DESC;

-- name: CreateUser :one
INSERT INTO users (email, name)
VALUES ($1, $2)
RETURNING *;

-- name: UpdateUser :one
UPDATE users
SET name = $2
WHERE id = $1
RETURNING *;

-- name: DeleteUser :exec
UPDATE users
SET deleted_at = NOW()
WHERE id = $1;

-- name: HardDeleteUser :exec
DELETE FROM users
WHERE id = $1;
```

---

## Generated Code

Running `sqlc generate` produces three files:

### models.go

One struct per table, with fields matching column names and types:

```go
// internal/db/models.go

package db

import (
    "time"
    "database/sql"
)

type User struct {
    ID        int64
    Email     string
    Name      string
    CreatedAt time.Time
    DeletedAt sql.NullTime
}

type Post struct {
    ID        int64
    UserID    int64
    Title     string
    Body      string
    Published bool
    CreatedAt time.Time
}
```

### db.go

The `DBTX` interface and `Queries` struct:

```go
// internal/db/db.go

package db

import (
    "context"
    "database/sql"
)

type DBTX interface {
    ExecContext(context.Context, string, ...interface{}) (sql.Result, error)
    PrepareContext(context.Context, string) (*sql.Stmt, error)
    QueryContext(context.Context, string, ...interface{}) (*sql.Rows, error)
    QueryRowContext(context.Context, string, ...interface{}) *sql.Row
}

func New(db DBTX) *Queries {
    return &Queries{db: db}
}

type Queries struct {
    db DBTX
}

func (q *Queries) WithTx(tx *sql.Tx) *Queries {
    return &Queries{db: tx}
}
```

The `DBTX` interface means `*sql.DB` and `*sql.Tx` both satisfy it — the same `Queries` works inside and outside transactions.

### query.sql.go

One method per annotated query:

```go
// internal/db/query.sql.go (excerpt)

const getUser = `-- name: GetUser :one
SELECT id, email, name, created_at, deleted_at FROM users
WHERE id = $1 AND deleted_at IS NULL
LIMIT 1
`

func (q *Queries) GetUser(ctx context.Context, id int64) (User, error) {
    row := q.db.QueryRowContext(ctx, getUser, id)
    var i User
    err := row.Scan(
        &i.ID,
        &i.Email,
        &i.Name,
        &i.CreatedAt,
        &i.DeletedAt,
    )
    return i, err
}

type CreateUserParams struct {
    Email string
    Name  string
}

const createUser = `-- name: CreateUser :one
INSERT INTO users (email, name)
VALUES ($1, $2)
RETURNING id, email, name, created_at, deleted_at
`

func (q *Queries) CreateUser(ctx context.Context, arg CreateUserParams) (User, error) {
    row := q.db.QueryRowContext(ctx, createUser, arg.Email, arg.Name)
    var i User
    err := row.Scan(
        &i.ID,
        &i.Email,
        &i.Name,
        &i.CreatedAt,
        &i.DeletedAt,
    )
    return i, err
}
```

Notice that the original SQL is preserved as a constant — it's exactly what gets sent to the database.

---

## Using the Generated Code

### Basic Setup

```go
package main

import (
    "context"
    "database/sql"
    "log"

    _ "github.com/lib/pq"
    "myapp/internal/db"
)

func main() {
    conn, err := sql.Open("postgres", "postgres://localhost/myapp?sslmode=disable")
    if err != nil {
        log.Fatal(err)
    }
    defer conn.Close()

    queries := db.New(conn)

    user, err := queries.CreateUser(context.Background(), db.CreateUserParams{
        Email: "alice@example.com",
        Name:  "Alice",
    })
    if err != nil {
        log.Fatal(err)
    }
    log.Printf("created user %d: %s", user.ID, user.Email)
}
```

### Transactions

Because `Queries` accepts any `DBTX`, wrapping operations in a transaction is straightforward:

```go
func transferPost(ctx context.Context, conn *sql.DB, postID, newOwnerID int64) error {
    tx, err := conn.BeginTx(ctx, nil)
    if err != nil {
        return err
    }
    defer tx.Rollback()

    q := db.New(tx)

    // Both calls run inside the same transaction
    if err := q.UpdatePostOwner(ctx, db.UpdatePostOwnerParams{
        ID:     postID,
        UserID: newOwnerID,
    }); err != nil {
        return err
    }

    if err := q.LogTransfer(ctx, db.LogTransferParams{
        PostID:     postID,
        NewOwnerID: newOwnerID,
    }); err != nil {
        return err
    }

    return tx.Commit()
}
```

### Using the Querier Interface

When `emit_interface: true` is set, sqlc generates a `Querier` interface. Use it in your service layer for easier testing:

```go
type UserService struct {
    db db.Querier
}

func NewUserService(q db.Querier) *UserService {
    return &UserService{db: q}
}

func (s *UserService) GetByEmail(ctx context.Context, email string) (db.User, error) {
    return s.db.GetUserByEmail(ctx, email)
}
```

In tests, implement the interface with a mock or use a test database.

---

## Type Overrides

sqlc maps SQL types to Go types automatically, but you can override them. This is commonly used for UUIDs, custom types, and `pgtype` values.

```yaml
# sqlc.yaml
gen:
  go:
    overrides:
      # Use google/uuid instead of [16]byte
      - db_type: "uuid"
        go_type:
          import: "github.com/google/uuid"
          type: "UUID"

      # Use pgtype.Numeric for NUMERIC columns
      - db_type: "pg_catalog.numeric"
        go_type:
          import: "github.com/jackc/pgx/v5/pgtype"
          type: "Numeric"

      # Override a specific column only
      - column: "users.metadata"
        go_type:
          import: "encoding/json"
          type: "RawMessage"

      # Use a nullable wrapper for a specific type
      - db_type: "text"
        nullable: true
        go_type:
          import: "database/sql"
          type: "NullString"
```

The `column` key targets one specific table column (`table.column`) rather than all columns of that type. `nullable: true` applies the override only when the column is nullable.

---

## Nullable Columns

By default, sqlc maps nullable columns to `sql.NullString`, `sql.NullInt64`, `sql.NullTime`, etc. With pgx/v5, it maps them to `pgtype` variants. You can also override them to use pointer types:

```yaml
overrides:
  - db_type: "text"
    nullable: true
    go_type: "*string"
```

This produces `*string` instead of `sql.NullString` for nullable text columns, which some teams prefer for cleaner struct literals.

---

## Enums

PostgreSQL `CREATE TYPE ... AS ENUM` becomes a Go string type with constants:

```sql
CREATE TYPE user_role AS ENUM ('admin', 'member', 'viewer');

CREATE TABLE users (
    id   BIGSERIAL PRIMARY KEY,
    role user_role NOT NULL DEFAULT 'member'
);
```

sqlc generates:

```go
type UserRole string

const (
    UserRoleAdmin  UserRole = "admin"
    UserRoleMember UserRole = "member"
    UserRoleViewer UserRole = "viewer"
)
```

---

## JSON Tags

With `emit_json_tags: true`, generated structs include JSON field tags:

```go
type User struct {
    ID        int64          `json:"id"`
    Email     string         `json:"email"`
    Name      string         `json:"name"`
    CreatedAt time.Time      `json:"created_at"`
    DeletedAt sql.NullTime   `json:"deleted_at"`
}
```

Column names are used as-is (snake_case) by default.

---

## Advanced Query Patterns

### Joins

sqlc understands join results and generates a flat struct for them:

```sql
-- name: GetPostWithAuthor :one
SELECT
    p.id,
    p.title,
    p.body,
    p.created_at,
    u.id   AS user_id,
    u.name AS user_name,
    u.email AS user_email
FROM posts p
JOIN users u ON u.id = p.user_id
WHERE p.id = $1;
```

This generates a `GetPostWithAuthorRow` struct with exactly those columns — not the full `Post` and `User` structs merged, because sqlc models what the query actually returns.

### Optional / Dynamic Filters

SQL doesn't have optional parameters natively, but a common pattern is using `CASE` or `IS NULL` checks to make a parameter optional:

```sql
-- name: ListUsers :many
SELECT * FROM users
WHERE
    deleted_at IS NULL
    AND ($1::bigint IS NULL OR id > $1)
ORDER BY id
LIMIT $2;
```

When `$1` is `NULL`, the `id > $1` condition is skipped (because `NULL` comparisons yield `NULL`, which is falsy). This creates a cursor-based pagination primitive.

### IN Clauses and Arrays (PostgreSQL)

PostgreSQL supports `= ANY($1)` for array membership, which sqlc handles cleanly:

```sql
-- name: GetUsersByIDs :many
SELECT * FROM users
WHERE id = ANY($1::bigint[]);
```

Generated code:

```go
func (q *Queries) GetUsersByIDs(ctx context.Context, ids []int64) ([]User, error) { ... }
```

For MySQL and SQLite, `IN` with variable length is not directly supported — a common workaround is to use a subquery or generate the query dynamically outside sqlc.

### RETURNING

`RETURNING *` (PostgreSQL) and `RETURNING id` give you the inserted/updated row back without a second query. sqlc maps the returned columns into the struct automatically.

### CTEs

```sql
-- name: GetActiveUserStats :one
WITH active AS (
    SELECT id FROM users WHERE deleted_at IS NULL
)
SELECT COUNT(*) AS count FROM active;
```

sqlc handles CTEs and generates the correct return type.

### Batch Operations (pgx)

For bulk inserts or updates with pgx, use `:copyfrom` (PostgreSQL COPY protocol, fastest) or `:batchexec`/`:batchmany`:

```sql
-- name: BulkCreateUsers :copyfrom
INSERT INTO users (email, name)
VALUES ($1, $2);
```

`COPY FROM` is significantly faster than individual `INSERT` statements for large datasets.

---

## Working with pgx/v5

When `sql_package: "pgx/v5"` is set, the generated code uses pgx types directly. The `New` function accepts `*pgxpool.Pool` or `pgx.Conn`:

```go
import (
    "github.com/jackc/pgx/v5/pgxpool"
    "myapp/internal/db"
)

pool, err := pgxpool.New(ctx, "postgres://localhost/myapp")
if err != nil {
    log.Fatal(err)
}

queries := db.New(pool)
```

pgx/v5 also enables richer types like `pgtype.UUID`, `pgtype.Inet`, and PostgreSQL arrays without manual conversion.

### pgx Transactions

```go
tx, err := pool.Begin(ctx)
if err != nil {
    return err
}
defer tx.Rollback(ctx)

q := db.New(tx)
// ... queries using q ...

return tx.Commit(ctx)
```

---

## Testing Strategies

### Real Database Tests

The most reliable approach is testing against a real database. Use `testcontainers-go` to spin up a PostgreSQL container per test run:

```go
func TestCreateUser(t *testing.T) {
    ctx := context.Background()

    // conn set up with testcontainers or a local test DB
    conn := setupTestDB(t)
    q := db.New(conn)

    user, err := q.CreateUser(ctx, db.CreateUserParams{
        Email: "test@example.com",
        Name:  "Test User",
    })
    require.NoError(t, err)
    assert.Equal(t, "test@example.com", user.Email)
}
```

### Mock via Interface

With `emit_interface: true`, sqlc generates a `Querier` interface. Implement it with a mock in unit tests:

```go
type mockQuerier struct {
    users map[int64]db.User
}

func (m *mockQuerier) GetUser(ctx context.Context, id int64) (db.User, error) {
    u, ok := m.users[id]
    if !ok {
        return db.User{}, sql.ErrNoRows
    }
    return u, nil
}

// implement remaining methods...
```

Tools like `mockery` can auto-generate the mock from the `Querier` interface.

### pgxmock and sqlmock

`github.com/DATA-DOG/go-sqlmock` mocks `database/sql` connections. `github.com/pashagolub/pgxmock` does the same for pgx. These are useful for testing error paths without a real database.

---

## Migrations and Schema Management

sqlc reads schema files but does not run or manage migrations. Pair it with a migration tool:

### golang-migrate

```bash
migrate -path db/migrations -database "postgres://localhost/myapp?sslmode=disable" up
```

Point sqlc at the same migration directory — it reads all `.sql` files in order and builds up the schema definition.

### goose

```bash
goose -dir db/migrations postgres "postgres://localhost/myapp" up
```

goose uses `-- +goose Up` / `-- +goose Down` markers. sqlc can handle these by ignoring unknown comments.

### Atlas

Atlas has first-class sqlc integration and can generate migrations from schema diffs, run them, and feed the resulting schema back to sqlc.

---

## Handling Migrations with sqlc

When using a migration tool, each migration file may contain both `UP` and `DOWN` sections. sqlc only cares about the final state of the schema, so if your migration tool uses marker comments (like goose), sqlc will see the SQL but may choke on `DOWN` statements that drop tables the `UP` section created.

Solutions:

- Split `UP` and `DOWN` into separate files
- Use sqlc's `schema` pointing to a separate canonical schema file that you keep in sync
- Use Atlas, which manages this automatically

---

## Plugins and Extensions

sqlc supports a plugin system via WASM (WebAssembly) modules. Plugins can:

- Generate code for languages other than Go (Kotlin, Python, TypeScript generators exist)
- Apply custom transformations to the generated output
- Add additional files alongside the standard output

```yaml
version: "2"
plugins:
  - name: ts
    wasm:
      url: "https://downloads.sqlc.dev/plugin/sqlc-gen-typescript_0.1.3.wasm"
      sha256: "..."
sql:
  - engine: "postgresql"
    queries: "db/query/"
    schema: "db/migrations/"
    gen:
      plugins:
        - name: ts
          out: "src/db"
          options:
            runtime: node
            driver: pg
```

Official and community plugins exist for TypeScript, Python, Kotlin, and more.

---

## sqlc Cloud and sqlc vet

### sqlc vet

`sqlc vet` runs lint rules against your queries. Rules are defined in the config:

```yaml
version: "2"
sql:
  - engine: "postgresql"
    queries: "db/query/"
    schema: "db/migrations/"
    rules:
      - sqlc/db-prepare     # prepare all queries against a live DB
    gen:
      go:
        package: "db"
        out: "internal/db"
rules:
  - name: no-pg-sleep
    message: "pg_sleep is not allowed in production queries"
    rule: |
      query.sql.contains("pg_sleep")
```

The built-in `sqlc/db-prepare` rule connects to a real database and runs `PREPARE` for every query, catching type mismatches and SQL errors that static analysis can't catch.

Custom rules are written in CEL (Common Expression Language) and can inspect `query`, `schema`, and `config` objects.

### Configuration for db-prepare

```yaml
rules:
  - sqlc/db-prepare
database:
  uri: "postgres://localhost/myapp_test?sslmode=disable"
```

---

## Common Patterns and Recipes

### Repository Pattern

Wrap the generated `Queries` in a repository struct for your domain layer:

```go
type UserRepository struct {
    q *db.Queries
}

func NewUserRepository(conn db.DBTX) *UserRepository {
    return &UserRepository{q: db.New(conn)}
}

func (r *UserRepository) FindByEmail(ctx context.Context, email string) (*db.User, error) {
    u, err := r.q.GetUserByEmail(ctx, email)
    if errors.Is(err, sql.ErrNoRows) {
        return nil, nil
    }
    if err != nil {
        return nil, fmt.Errorf("find user by email: %w", err)
    }
    return &u, nil
}
```

### Pagination

Cursor-based pagination using the `id`:

```sql
-- name: ListUsersPaginated :many
SELECT * FROM users
WHERE
    deleted_at IS NULL
    AND ($1::bigint = 0 OR id > $1)
ORDER BY id ASC
LIMIT $2;
```

Offset-based:

```sql
-- name: ListUsersOffset :many
SELECT * FROM users
WHERE deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;
```

### Soft Deletes

Include `deleted_at IS NULL` in every relevant query. sqlc has no magic for this — it's explicit, which keeps things clear:

```sql
-- name: ListActiveUsers :many
SELECT * FROM users
WHERE deleted_at IS NULL
ORDER BY name;
```

### Upsert

```sql
-- name: UpsertUser :one
INSERT INTO users (email, name)
VALUES ($1, $2)
ON CONFLICT (email) DO UPDATE
SET name = EXCLUDED.name
RETURNING *;
```

### Counting

```sql
-- name: CountUsers :one
SELECT COUNT(*) FROM users
WHERE deleted_at IS NULL;
```

Returns `int64` since `COUNT(*)` always returns a single value that sqlc maps to the appropriate integer type.

---

## Embed Queries from Go Files

If you prefer keeping SQL closer to your Go code, you can embed `.sql` files using Go's `embed` package alongside the generated code. sqlc itself reads files from disk at generation time — the embed approach is for the running binary if you ever need the raw SQL at runtime (e.g., for logging or documentation).

```go
import _ "embed"

//go:embed query/users.sql
var usersSQL string
```

This is optional and unrelated to sqlc's generation step.

---

## Error Handling

sqlc-generated functions return standard Go errors. `sql.ErrNoRows` is returned for `:one` queries that find nothing:

```go
user, err := q.GetUser(ctx, id)
if err != nil {
    if errors.Is(err, sql.ErrNoRows) {
        return nil, ErrNotFound
    }
    return nil, fmt.Errorf("get user: %w", err)
}
```

For pgx, the equivalent is `pgx.ErrNoRows`:

```go
if errors.Is(err, pgx.ErrNoRows) {
    return nil, ErrNotFound
}
```

PostgreSQL-specific error codes (constraint violations, deadlocks, etc.) come through as `*pgconn.PgError`:

```go
var pgErr *pgconn.PgError
if errors.As(err, &pgErr) {
    if pgErr.Code == "23505" { // unique_violation
        return nil, ErrDuplicateEmail
    }
}
```

---

## Regenerating After Schema Changes

The workflow for schema changes is:

1. Write a new migration file
2. Update any affected queries
3. Run `sqlc generate`
4. Compile — the Go compiler catches anything that no longer type-checks

This tight loop is the main value proposition: the compiler tells you everywhere the code needs to change when the database schema changes.

---

## Performance Considerations

sqlc itself has no runtime overhead. The generated code is just Go functions calling `database/sql` or pgx directly. A few notes:

- **Prepared statements**: Disabled by default (`emit_prepared_queries: false`). Enable with caution — they consume server-side resources and can cause issues with connection poolers like PgBouncer in transaction pooling mode.
- **SELECT ***: sqlc rewrites `SELECT *` to explicit column lists in the generated SQL constant (when it can resolve the columns), which avoids sending unneeded data. Write explicit column lists in queries where performance matters or where you want to be deliberate about what you fetch.
- **Connection pooling**: Use `pgxpool` for production PostgreSQL workloads. For `database/sql`, configure `SetMaxOpenConns`, `SetMaxIdleConns`, and `SetConnMaxLifetime`.
- **Batch operations**: For bulk writes, `:copyfrom` is dramatically faster than looping over individual inserts.

---

## Comparison with Alternatives

### sqlc vs database/sql by hand

Writing `database/sql` by hand is tedious, repetitive, and error-prone — mismatched `Scan` arguments only fail at runtime. sqlc generates correct `Scan` calls and catches mistakes at generation time.

### sqlc vs GORM / Ent

ORMs abstract SQL behind Go method chains. This is convenient for simple queries but produces unpredictable SQL for complex ones, and the abstraction leaks when you need database-specific features. sqlc requires you to write SQL, which is an explicit trade-off: more control, more visibility, no surprises, but also more verbosity.

### sqlc vs sqlx

`sqlx` extends `database/sql` with struct scanning via reflection and named queries. It reduces boilerplate but doesn't generate code — you still write the queries and the struct definitions separately and keep them in sync manually. sqlc does that for you.

### sqlc vs squirrel / goqu

Query builders construct SQL programmatically. They're useful for dynamic queries (where the shape of the SQL isn't known until runtime), but they don't provide type safety on the result and don't generate code. sqlc and a query builder can coexist — use sqlc for the 90% of queries that are static, and a builder for the dynamic ones.

---

## Gotchas and Known Limitations

**`SELECT *` in joins**: When you `SELECT *` across a join, sqlc may not be able to resolve which table each column comes from, leading to confusing generated types. Write explicit column lists with aliases in join queries.

**MySQL lacks `RETURNING`**: MySQL does not support `RETURNING`. For inserts, use `:execresult` and `sql.Result.LastInsertId()` to get the new ID, then fetch the row if needed.

**Dynamic queries**: sqlc cannot generate code for queries where the SQL itself changes at runtime (dynamic `WHERE` clauses, variable `ORDER BY`, etc.). Accept this limitation and handle dynamic queries separately (with a query builder or raw SQL).

**Schema drift**: If your migration files contain `DOWN` migrations that undo `UP` changes, sqlc may see conflicting DDL. Use a single canonical schema file or split up/down migrations.

**`NOT NULL` columns with defaults**: A column with a `DEFAULT` that is `NOT NULL` will appear as a non-pointer, non-Null type in generated structs. If your insert query doesn't include that column, it won't appear in the params struct either — the database handles it. This is correct behavior.

**WASM plugin performance**: WASM plugins are slower to load than native code. For large projects with many plugins, generation time can increase noticeably.

---

## CI Integration

Add sqlc generation to your CI pipeline to catch drift between schema, queries, and generated code:

```yaml
# .github/workflows/ci.yml
- name: Check sqlc is up to date
  run: |
    sqlc generate
    git diff --exit-code internal/db/
```

If any generated file differs from what's in the repo, the diff step fails — ensuring the generated code is always in sync with the SQL.

---

## Quick Reference

### Annotation Commands

```sql
-- name: FuncName :one       -- single row
-- name: FuncName :many      -- slice of rows
-- name: FuncName :exec      -- no return value
-- name: FuncName :execrows  -- rows affected
-- name: FuncName :copyfrom  -- PostgreSQL COPY (bulk insert)
```

### Parameter Placeholders

PostgreSQL uses `$1`, `$2`, … — MySQL and SQLite use `?`.

### Minimal sqlc.yaml

```yaml
version: "2"
sql:
  - engine: "postgresql"
    queries: "query/"
    schema: "schema.sql"
    gen:
      go:
        package: "db"
        out: "db"
```

### Generation

```bash
sqlc generate    # generate code
sqlc vet         # lint queries
sqlc compile     # check SQL without generating
sqlc diff        # show what would change
```