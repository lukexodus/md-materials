## SQL Injection Prevention Patterns

SQL injection remains one of the most consistently exploited vulnerability classes in web applications. In a Fastify context, the framework itself provides no database layer — prevention is entirely the responsibility of the application code that constructs and executes queries. This document covers the complete set of patterns applicable across query styles, ORMs, and database drivers commonly used with Fastify.

---

### Why SQL Injection Occurs

SQL injection happens when user-supplied input is concatenated into a query string before being sent to the database. The database engine cannot distinguish between the query structure and the injected data — it parses the combined string as a single SQL statement.

```typescript
// Vulnerable — input becomes part of the query structure
const username = request.body.username // attacker sends: ' OR '1'='1
const query = `SELECT * FROM users WHERE username = '${username}'`
// Executed: SELECT * FROM users WHERE username = '' OR '1'='1'
// Returns all rows
```

The database receives the injected logical condition as valid SQL syntax and evaluates it. No amount of input validation at the Fastify layer reliably prevents this — the fix must occur at the query construction site.

---

### The Fundamental Fix — Parameterized Queries

Parameterized queries (also called prepared statements) separate the query structure from the data. The database driver sends the SQL template and the parameter values independently. The database parses the template first, then binds the values — values can never alter the query structure.

```typescript
// Safe — username is a bound parameter, not part of the query string
const result = await pool.query(
  'SELECT id, username, email FROM users WHERE username = $1',
  [username]
)
```

The database receives two distinct artifacts: the query template with a placeholder, and the parameter array. The value `' OR '1'='1` is treated as a literal string to match against the `username` column — it cannot alter the query's logical structure.

**Key Points:**
- Parameterized queries are the primary and most reliable prevention mechanism.
- All subsequent patterns in this document are complementary — none replace parameterization.
- [Inference] The exact placeholder syntax (`$1`, `?`, `:name`) varies by database driver — the principle is identical across all of them.

---

### Driver-Level Parameterization

#### `pg` (node-postgres)

```typescript
import { Pool } from 'pg'

const pool = new Pool({ connectionString: process.env.DATABASE_URL })

// Positional parameters: $1, $2, ...
async function getUserById(id: string) {
  const result = await pool.query(
    'SELECT id, username, email FROM users WHERE id = $1',
    [id]
  )
  return result.rows[0] ?? null
}

async function searchUsers(search: string, limit: number) {
  const result = await pool.query(
    'SELECT id, username FROM users WHERE username ILIKE $1 ORDER BY username LIMIT $2',
    [`%${search}%`, limit]
  )
  return result.rows
}
```

**Key Points:**
- `%${search}%` — the `%` wildcards are interpolated in the application before the parameter is bound. This is safe because the wildcard characters are part of the parameter value, not part of the query structure. The entire value including `%` characters is treated as a literal LIKE pattern.
- `LIMIT $2` with a bound integer is safe — `pg` will reject non-numeric values for integer-typed parameters.

---

#### `mysql2`

```typescript
import mysql from 'mysql2/promise'

const pool = mysql.createPool({ uri: process.env.DATABASE_URL })

// Positional placeholder: ?
async function getUserByEmail(email: string) {
  const [rows] = await pool.execute(
    'SELECT id, username FROM users WHERE email = ?',
    [email]
  )
  return (rows as any[])[0] ?? null
}
```

**Key Points:**
- Use `pool.execute()` rather than `pool.query()` — `execute()` uses true prepared statements on the MySQL server side. `pool.query()` uses client-side escaping, which is less robust. [Unverified: behavior difference may vary by `mysql2` version — verify in the library changelog.]
- Placeholder is `?` (positional, no numbering).

---

#### `better-sqlite3`

```typescript
import Database from 'better-sqlite3'

const db = new Database(process.env.DB_PATH!)

// Named parameters
const getUserStmt = db.prepare('SELECT id, username FROM users WHERE id = @id')

function getUserById(id: string) {
  return getUserStmt.get({ id }) ?? null
}

// Positional parameters
const insertUserStmt = db.prepare(
  'INSERT INTO users (username, email) VALUES (?, ?)'
)

function createUser(username: string, email: string) {
  return insertUserStmt.run(username, email)
}
```

**Key Points:**
- `better-sqlite3` supports both `?` positional and `@name` / `$name` / `:name` named parameter styles.
- Prepared statements created once and reused (as above) are more efficient than preparing on every call.
- `better-sqlite3` is synchronous — all calls block the event loop. [Inference] Suitable for low-concurrency or CLI contexts; evaluate carefully for high-throughput Fastify APIs.

---

### ORM-Level Prevention

ORMs construct parameterized queries internally for standard operations. The risk with ORMs is their raw query escape hatches — these bypass the ORM's safe query builder and require the same care as writing raw SQL.

#### Prisma

```typescript
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

// Safe — Prisma generates parameterized SQL
async function getUser(id: string) {
  return prisma.user.findUnique({ where: { id } })
}

// Safe — Prisma parameterizes the search value
async function searchUsers(search: string) {
  return prisma.user.findMany({
    where: {
      username: { contains: search, mode: 'insensitive' }
    }
  })
}

// Raw query — requires explicit parameterization
async function getRawUser(id: string) {
  // Safe: $1 is a bound parameter
  return prisma.$queryRaw`SELECT id, username FROM users WHERE id = ${id}::uuid`
}

// UNSAFE raw query — never do this
async function unsafeRaw(id: string) {
  return prisma.$queryRawUnsafe(
    `SELECT id, username FROM users WHERE id = '${id}'`
  )
}
```

**Key Points:**
- Prisma's tagged template literal `` prisma.$queryRaw`...` `` automatically parameterizes interpolated values — this is safe.
- `prisma.$queryRawUnsafe()` accepts a plain string — concatenation into that string is a direct injection vector. Use only for static query strings with no user input; bind parameters via the second argument array if dynamic values are needed.
- [Inference] `$queryRawUnsafe` exists for cases where the query itself must be dynamic (e.g., dynamic table names) — even then, restrict dynamic segments to an allowlist rather than passing user input directly.

---

#### TypeORM

```typescript
import { DataSource } from 'typeorm'

const dataSource = new DataSource({ /* config */ })

// Safe — QueryBuilder uses parameterization
async function getActiveUsers(minAge: number) {
  return dataSource
    .getRepository(User)
    .createQueryBuilder('user')
    .where('user.age >= :minAge', { minAge })
    .andWhere('user.active = :active', { active: true })
    .getMany()
}

// Raw query — parameterized safely
async function getRawUsers(role: string) {
  return dataSource.query(
    'SELECT id, username FROM users WHERE role = $1',
    [role]
  )
}

// UNSAFE — never do this
async function unsafeQuery(role: string) {
  return dataSource.query(
    `SELECT id, username FROM users WHERE role = '${role}'`
  )
}
```

**Key Points:**
- Named parameters in QueryBuilder (`:minAge`, `:active`) are bound — not interpolated into the SQL string.
- `dataSource.query()` with a parameter array is safe; `dataSource.query()` with string concatenation is not.

---

#### Drizzle ORM

```typescript
import { drizzle } from 'drizzle-orm/node-postgres'
import { eq, ilike } from 'drizzle-orm'
import { users } from './schema'

const db = drizzle(pool)

// Safe — Drizzle generates parameterized SQL
async function getUserByEmail(email: string) {
  return db.select().from(users).where(eq(users.email, email))
}

// Safe — ilike operator parameterizes the value
async function searchByUsername(term: string) {
  return db.select().from(users).where(ilike(users.username, `%${term}%`))
}

// Raw SQL in Drizzle — use sql template tag
import { sql } from 'drizzle-orm'

async function customQuery(status: string) {
  return db.execute(sql`SELECT id FROM users WHERE status = ${status}`)
}
```

**Key Points:**
- Drizzle's `sql` tagged template literal parameterizes interpolated values automatically — the same safe pattern as Prisma's `$queryRaw`.
- Drizzle's query builder operators (`eq`, `ilike`, `gt`, etc.) all produce parameterized SQL internally.

---

### Dynamic Query Construction

Some queries must be partially dynamic — variable `WHERE` clauses, sorting columns, or pagination. Each dynamic element requires a different strategy depending on whether it is a value or a structural element.

#### Dynamic WHERE Clauses (values — parameterizable)

```typescript
async function filterUsers(
  filters: { role?: string; active?: boolean; minAge?: number },
  pool: Pool
) {
  const conditions: string[] = []
  const params: unknown[] = []
  let paramIndex = 1

  if (filters.role !== undefined) {
    conditions.push(`role = $${paramIndex++}`)
    params.push(filters.role)
  }

  if (filters.active !== undefined) {
    conditions.push(`active = $${paramIndex++}`)
    params.push(filters.active)
  }

  if (filters.minAge !== undefined) {
    conditions.push(`age >= $${paramIndex++}`)
    params.push(filters.minAge)
  }

  const whereClause = conditions.length > 0
    ? `WHERE ${conditions.join(' AND ')}`
    : ''

  const query = `SELECT id, username, email FROM users ${whereClause} ORDER BY username`

  const result = await pool.query(query, params)
  return result.rows
}
```

**Key Points:**
- The query *structure* is assembled from static string fragments only — no user input enters the query template.
- User-supplied values go into the `params` array exclusively and are bound as parameters.
- `paramIndex` tracks the positional placeholder number — this pattern generalizes to any number of optional filters.

---

#### Dynamic Column Names and Sort Orders (structural — not parameterizable)

Column names and sort directions cannot be parameterized — the database driver treats all parameters as values, not identifiers. Use an explicit allowlist:

```typescript
type SortColumn = 'username' | 'email' | 'created_at' | 'age'
type SortDirection = 'ASC' | 'DESC'

const ALLOWED_SORT_COLUMNS: readonly SortColumn[] = [
  'username', 'email', 'created_at', 'age'
]
const ALLOWED_SORT_DIRECTIONS: readonly SortDirection[] = ['ASC', 'DESC']

function validateSortColumn(col: string): SortColumn {
  if (!(ALLOWED_SORT_COLUMNS as readonly string[]).includes(col)) {
    throw new Error(`Invalid sort column: ${col}`)
  }
  return col as SortColumn
}

function validateSortDirection(dir: string): SortDirection {
  const upper = dir.toUpperCase()
  if (!(ALLOWED_SORT_DIRECTIONS as readonly string[]).includes(upper)) {
    throw new Error(`Invalid sort direction: ${dir}`)
  }
  return upper as SortDirection
}

async function listUsersSorted(
  sortBy: string,
  sortDir: string,
  pool: Pool
) {
  const column = validateSortColumn(sortBy)
  const direction = validateSortDirection(sortDir)

  // column and direction are now guaranteed to be safe structural fragments
  const result = await pool.query(
    `SELECT id, username, email FROM users ORDER BY ${column} ${direction}`
  )
  return result.rows
}
```

**Key Points:**
- Allowlist validation converts an arbitrary user string into a type-safe structural fragment before interpolation.
- The allowlist is defined as a `readonly` constant in the application — it cannot be influenced by user input.
- [Inference] This is the correct pattern for dynamic table names as well — though dynamic table names are a design smell that may indicate a schema design issue worth revisiting.

---

### Fastify Route Integration

Combining schema validation with parameterized queries in a complete route:

```typescript
import { FastifyInstance } from 'fastify'
import { Type, Static } from '@sinclair/typebox'
import { Pool } from 'pg'

const GetUsersQuery = Type.Object({
  search:    Type.Optional(Type.String({ maxLength: 100 })),
  role:      Type.Optional(Type.Union([
               Type.Literal('admin'),
               Type.Literal('user'),
               Type.Literal('moderator')
             ])),
  sortBy:    Type.Optional(Type.Union([
               Type.Literal('username'),
               Type.Literal('created_at')
             ])),
  sortDir:   Type.Optional(Type.Union([
               Type.Literal('asc'),
               Type.Literal('desc')
             ])),
  page:      Type.Optional(Type.Integer({ minimum: 1, maximum: 10000 })),
  pageSize:  Type.Optional(Type.Integer({ minimum: 1, maximum: 100 }))
})

type GetUsersQueryType = Static<typeof GetUsersQuery>

export async function userRoutes(fastify: FastifyInstance) {
  const pool: Pool = fastify.pg // assumes @fastify/postgres decorator

  fastify.get<{ Querystring: GetUsersQueryType }>(
    '/users',
    { schema: { querystring: GetUsersQuery } },
    async (request, reply) => {
      const {
        search,
        role,
        sortBy = 'username',
        sortDir = 'asc',
        page = 1,
        pageSize = 20
      } = request.query

      const conditions: string[] = []
      const params: unknown[] = []
      let i = 1

      if (search) {
        conditions.push(`username ILIKE $${i++}`)
        params.push(`%${search}%`)
      }

      if (role) {
        conditions.push(`role = $${i++}`)
        params.push(role)
      }

      // sortBy and sortDir already constrained to literals by schema —
      // but validate defensively before structural interpolation
      const safeSort = (['username', 'created_at'] as const).includes(sortBy as any)
        ? sortBy : 'username'
      const safeDir = sortDir.toUpperCase() === 'DESC' ? 'DESC' : 'ASC'

      const offset = (page - 1) * pageSize
      params.push(pageSize, offset)

      const where = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : ''
      const query = `
        SELECT id, username, email, role, created_at
        FROM users
        ${where}
        ORDER BY ${safeSort} ${safeDir}
        LIMIT $${i++} OFFSET $${i++}
      `

      const result = await pool.query(query, params)
      return result.rows
    }
  )
}
```

---

### Second-Order Injection

Second-order injection occurs when sanitized data is stored in the database and later retrieved and used unsafely in a subsequent query.

```typescript
// First request — stores a payload safely (parameterized)
await pool.query(
  'INSERT INTO users (username) VALUES ($1)',
  ["admin'--"]  // stored safely as a string
)

// Later — retrieved value used unsafely in another query (vulnerable)
const user = await pool.query('SELECT username FROM users WHERE id = $1', [id])
const username = user.rows[0].username // "admin'--"

// UNSAFE — treats retrieved DB value as trusted, interpolates into new query
await pool.query(`SELECT * FROM audit_logs WHERE actor = '${username}'`)
```

**Key Points:**
- Data retrieved from the database is not inherently safe for use in subsequent queries.
- Parameterize all queries regardless of whether the values originate from user input or from a previous database read.
- [Inference] Second-order injection is commonly overlooked because developers conflate "came from the database" with "safe to use in SQL" — these are independent properties.

---

### What Schema Validation Does and Does Not Prevent

| Threat | Schema validation alone sufficient? | Notes |
|---|---|---|
| Type mismatch (string where int expected) | Yes | Ajv rejects at validation phase |
| Overly long strings | Yes (with `maxLength`) | Limits payload size |
| SQL metacharacters in a string field | No | Valid string type; still injectable if concatenated |
| `' OR '1'='1` in a string field | No | Valid string; only parameterization prevents exploitation |
| Dynamic column name injection | Partially | `Type.Literal` union constrains to allowlist |
| Second-order injection | No | Schema validates input; does not govern internal query construction |

---

### Common Mistakes

**Mistake 1 — Escaping instead of parameterizing:**

```typescript
// Fragile — escape functions can be bypassed via encoding or edge cases
const safe = username.replace(/'/g, "''")
const query = `SELECT * FROM users WHERE username = '${safe}'`
```

Use parameterization instead. Escaping is not a reliable substitute.

**Mistake 2 — Trusting ORM-generated queries for raw extensions:**

```typescript
// The ORM query is safe; the raw extension is not
const user = await prisma.user.findFirst({ where: { id } })
const logs = await prisma.$queryRawUnsafe(
  `SELECT * FROM logs WHERE user_id = '${user!.id}'`
)
```

Even if `user.id` came from a safe ORM query, `$queryRawUnsafe` with string interpolation is still vulnerable to second-order injection.

**Mistake 3 — Parameterizing the value but structurally interpolating the column:**

```typescript
// The value ($1) is safe; the column name is not
const col = request.query.sortBy // attacker sends: username; DROP TABLE users;--
const result = await pool.query(
  `SELECT id FROM users ORDER BY ${col} LIMIT $1`,
  [limit]
)
```

Structural elements (columns, table names, sort direction, keywords) must be validated against an allowlist before interpolation — they cannot be parameterized.

---

**Related Topics:**
- `@fastify/postgres` — decorating Fastify with a pg pool
- Prisma integration with Fastify — setup and lifecycle management
- Drizzle ORM with Fastify — schema definition and query patterns
- Input sanitization — complementary content-level controls
- Schema validation with TypeBox — constraining input to safe value sets
- Rate limiting with `@fastify/rate-limit` — reducing brute-force query attack surface
- Audit logging for sensitive queries — detecting injection attempts post-hoc