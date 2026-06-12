# Drizzle Kit — Comprehensive Guide

> Source: official Drizzle documentation at `orm.drizzle.team` (fetched June 2026).  
> Version context: Drizzle Kit `v1.0.0-beta.2` / stable `0.23.x`. Where behaviour differs between versions it is noted.

---

## What Is Drizzle Kit

Drizzle Kit is a CLI tool for managing SQL database migrations with Drizzle. It operates on your Drizzle schema files and provides six core commands and two utility commands:

| Command | Purpose |
|---|---|
| `generate` | Generate SQL migration files from schema diff |
| `migrate` | Apply generated SQL migration files to the database |
| `push` | Push schema directly to database (no migration files) |
| `pull` | Introspect database and emit a Drizzle schema file |
| `export` | Export SQL from current schema without applying |
| `check` | Detect migration file collisions |
| `up` | Upgrade snapshots from older generated migrations |
| `studio` | Spin up Drizzle Studio visual database browser |

---

## Installation

```bash
# npm
npm i -D drizzle-kit

# pnpm
pnpm add -D drizzle-kit

# yarn
yarn add -D drizzle-kit

# bun
bun add -D drizzle-kit
```

Drizzle Kit does not bundle database drivers. It picks up whatever driver is already installed in the project based on `dialect`. For special drivers (`aws-data-api`, `pglite`, `d1-http`) you must specify `driver` explicitly.

---

## Project Layout

```
📦 <project root>
 ├ 📂 drizzle/           ← migration output (default)
 ├ 📂 src/
 │  └ 📜 schema.ts
 ├ 📜 drizzle.config.ts  ← required config file
 ├ 📜 .env
 └ 📜 package.json
```

---

## drizzle.config.ts

All commands read configuration from `drizzle.config.ts` (or `.js`). You can override the config path via `--config=<path>` on any command, which is useful for multi-environment setups.

### Minimal config

```ts
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  dialect: "postgresql",
  schema: "./src/schema.ts",
});
```

### Full extended config

```ts
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  out: "./drizzle",
  dialect: "postgresql",        // required
  schema: "./src/schema.ts",    // required for generate/push

  driver: "pglite",             // only for special drivers
  dbCredentials: {
    url: "./database/",
  },

  extensionsFilters: ["postgis"],
  schemaFilter: ["public"],
  tablesFilter: "*",

  introspect: {
    casing: "camel",            // "camel" | "preserve"
  },

  migrations: {
    prefix: "timestamp",
    table: "__drizzle_migrations__",
    schema: "public",
  },

  entities: {
    roles: {
      provider: "supabase",     // "neon" | "supabase"
      exclude: ["some_role"],
      include: [],
    },
  },

  breakpoints: true,
  strict: true,
  verbose: true,
});
```

### Multiple config files

```
📦 <project root>
 ├ 📜 drizzle-dev.config.ts
 ├ 📜 drizzle-prod.config.ts
 └ ...

npx drizzle-kit generate --config=drizzle-dev.config.ts
npx drizzle-kit generate --config=drizzle-prod.config.ts
```

---

## Config Reference

### `dialect` *(required)*

| Values | `postgresql` `mysql` `sqlite` `turso` `singlestore` `mssql` `cockroachdb` |
|---|---|
| Used by | `generate` `migrate` `push` `pull` `check` `up` |

```ts
dialect: "postgresql"
```

### `schema`

Glob path(s) to Drizzle schema files.

| Type | `string \| string[]` |
|---|---|
| Used by | `generate` `push` |

```ts
// single file
schema: "./src/schema.ts"

// glob — all schema.ts files anywhere under src
schema: "./src/**/schema.ts"

// multiple explicit files
schema: ["./src/user/schema.ts", "./src/posts/schema.ts"]

// folder of schema files
schema: "./src/schema/*"

// Dax-style: only *.sql.ts files
schema: "./src/**/*.sql.ts"
```

### `out`

Output directory for migration SQL files, JSON snapshots, and pulled `schema.ts`.

| Type | `string` | Default | `"drizzle"` |
|---|---|---|---|
| Used by | `generate` `migrate` `push` `pull` `check` `up` | | |

```ts
out: "./migrations"
```

### `driver`

Only required for databases that cannot be auto-detected:

| Value | When |
|---|---|
| `aws-data-api` | AWS RDS Data API (PostgreSQL) |
| `pglite` | PGLite embedded PostgreSQL |
| `d1-http` | Cloudflare D1 via HTTP API |

```ts
// Cloudflare D1
driver: "d1-http"

// PGLite (in-memory or folder)
driver: "pglite"
```

### `dbCredentials`

Connection options vary by dialect:

```ts
// PostgreSQL — URL
dbCredentials: { url: "postgres://user:password@host:5432/db" }

// PostgreSQL — params
dbCredentials: {
  host: "localhost", port: 5432, user: "user",
  password: "pass", database: "mydb",
  ssl: true,  // boolean | "require" | "allow" | "prefer" | "verify-full"
}

// MySQL — URL
dbCredentials: { url: "mysql://user:password@host:3306/db" }

// SQLite
dbCredentials: { url: "sqlite.db" }            // file
dbCredentials: { url: ":memory:" }             // in-memory
dbCredentials: { url: "file:sqlite.db" }       // libsql prefix

// Turso
dbCredentials: {
  url: "libsql://acme.turso.io",
  authToken: "...",
}

// Cloudflare D1
dbCredentials: { accountId: "...", databaseId: "...", token: "..." }

// AWS Data API
dbCredentials: { database: "...", resourceArn: "...", secretArn: "..." }

// PGLite
dbCredentials: { url: "./database/" }
```

### `migrations`

Controls the name and schema of the migrations log table used by `drizzle-kit migrate`.

| Default | `{ table: "__drizzle_migrations", schema: "drizzle" }` |
|---|---|
| Used by | `migrate` |

```ts
migrations: {
  table: "my_migrations",
  schema: "public",   // PostgreSQL only
}
```

### `introspect`

Configuration for `drizzle-kit pull`.

```ts
introspect: {
  casing: "camel",      // JS property keys become camelCase (default)
  // casing: "preserve" // JS property keys match database column name exactly
}
```

With `casing: "camel"`, a column named `first_name` becomes `firstName` in the generated schema. With `"preserve"`, the key is `first_name`.

### `tablesFilter`

Glob filter for which tables `push` and `pull` should manage. Useful for multi-tenant schemas sharing one database.

```ts
tablesFilter: ["users", "posts", "project1_*"]

// CLI equivalent
--tablesFilter='user*'
```

### `schemaFilter`

Which PostgreSQL schemas to manage. Changed in `1.0.0-beta.1`.

```ts
// v0.x default: ["public"]
// v1 beta: all schemas unless filtered
schemaFilter: ["public", "auth"]
```

### `extensionsFilters`

Extensions like PostGIS create their own tables in public schema. List installed extensions so Drizzle Kit ignores their internal tables.

```ts
extensionsFilters: ["postgis"]
```

### `entities.roles`

Controls whether Drizzle Kit manages database roles.

By default role management is disabled. Enable it:

```ts
entities: { roles: true }
```

Exclude specific roles:

```ts
entities: {
  roles: { exclude: ["admin"] }
}
```

Use a cloud provider preset (excludes provider-managed roles automatically):

```ts
entities: {
  roles: { provider: "neon" }        // or "supabase"
}

// Provider + extra exclusions
entities: {
  roles: { provider: "supabase", exclude: ["new_supabase_role"] }
}
```

### `strict`

When `true`, `push` will prompt for confirmation before executing SQL statements.

| Default | `false` | Commands | `push` |
|---|---|---|---|

### `verbose`

Print all SQL statements during execution.

| Default | `true` | Commands | `generate` `pull` |
|---|---|---|---|

### `breakpoints`

Embeds `-- > statement-breakpoint` between statements in generated SQL files. Required for MySQL and SQLite, which do not support multiple DDL statements in a single transaction.

| Default | `true` | Commands | `generate` `pull` |
|---|---|---|---|

---

## Commands

### `drizzle-kit generate`

`drizzle-kit generate` lets you generate SQL migrations based on your Drizzle schema upon declaration or on subsequent schema changes.

**How it works:**

1. Reads Drizzle schema files → composes a JSON snapshot.
2. Reads previous migration folders → compares to most recent snapshot.
3. Diffs the snapshots → generates SQL.
4. Writes `migration.sql` and `snapshot.json` to a timestamped folder.

```bash
# with config
npx drizzle-kit generate

# CLI-only (no config file)
npx drizzle-kit generate --dialect=postgresql --schema=./src/schema.ts

# custom name
npx drizzle-kit generate --name=add_posts_table

# empty file for hand-written SQL
npx drizzle-kit generate --custom --name=seed_users

# skip commutativity checks (use only if directed by a bug report)
npx drizzle-kit generate --ignore-conflicts
```

**Output structure:**

```
📂 drizzle/
 └ 📂 20242409125510_add_posts_table/
   ├ 📜 migration.sql
   └ 📜 snapshot.json
```

**CLI-only flags for `generate`:**

| Flag | Purpose |
|---|---|
| `--name=<string>` | Custom migration folder name suffix |
| `--custom` | Generate empty SQL file for manual editing |
| `--ignore-conflicts` | Skip commutativity checks (available ≥ `1.0.0-beta.16`) |

---

### `drizzle-kit migrate`

Applies previously generated SQL migration files to the database in order.

**How it works:**

1. Reads the migrations folder.
2. Checks the `__drizzle_migrations` log table in the database to find unapplied migrations.
3. Applies unapplied migrations in chronological order.
4. Records each applied migration in the log table.

```bash
npx drizzle-kit migrate
```

**Applied migrations log** is stored in:
- Table: `__drizzle_migrations` (configurable via `migrations.table`)
- Schema: `drizzle` for PostgreSQL (configurable via `migrations.schema`)

**Skip commutativity check:**

```bash
npx drizzle-kit migrate --ignore-conflicts
```

**Minimal config required:**

```ts
export default defineConfig({
  dialect: "postgresql",
  out: "./drizzle",
  dbCredentials: { url: process.env.DATABASE_URL! },
  migrations: {
    table: "__drizzle_migrations",
    schema: "drizzle",
  },
});
```

---

### `drizzle-kit push`

`drizzle-kit push` lets you literally push your schema and subsequent schema changes directly to the database while omitting SQL files generation.

**How it works:**

1. Reads schema files → JSON snapshot.
2. Introspects current database schema.
3. Diffs → generates SQL in memory.
4. Applies SQL directly to the database.

No migration files are written. Good for local development, prototyping, and serverless database environments.

```bash
# with config
npx drizzle-kit push

# CLI-only
npx drizzle-kit push --dialect=postgresql --schema=./src/schema.ts \
  --url=postgresql://user:password@host:5432/db

# with safety flags
npx drizzle-kit push --strict --verbose

# skip data-loss confirmation prompts (destructive — use with care)
npx drizzle-kit push --force
```

**Push-specific CLI flags:**

| Flag | Purpose |
|---|---|
| `--verbose` | Print all SQL before executing |
| `--strict` | Prompt before every SQL statement |
| `--force` | Auto-accept all data-loss statements |

**Note:** `push` is not available for Expo SQLite or OP SQLite (on-device databases). Use embedded migrations for those.

---

### `drizzle-kit pull`

`drizzle-kit pull` lets you literally pull (introspect) your existing database schema and generate a `schema.ts` drizzle schema file. It is designed to cover the database first approach of Drizzle migrations.

**How it works:**

1. Connects to the database.
2. Reads the DDL (tables, columns, indexes, constraints).
3. Generates a `schema.ts` file in the `out` folder.

```bash
# with config
npx drizzle-kit pull

# CLI-only
npx drizzle-kit pull --dialect=postgresql \
  --url=postgresql://user:password@host:5432/db
```

**Casing control:**

```ts
// drizzle.config.ts
introspect: {
  casing: "camel",      // default — snake_case columns → camelCase keys
  // casing: "preserve" // keep column names as-is
}
```

**Scope filtering:**

```ts
schemaFilter: ["public", "auth"]
tablesFilter: ["users", "posts"]
extensionsFilters: ["postgis"]
```

---

### `drizzle-kit check`

`drizzle-kit check` will walk through all generated migrations and check for any race conditions (collisions) of generated migrations.

Useful in team environments where multiple developers may be generating migrations concurrently. Does not modify anything.

```bash
npx drizzle-kit check
```

---

### `drizzle-kit up`

`drizzle-kit up` is used to upgrade snapshots of previously generated migrations.

Run this after upgrading `drizzle-kit` to a version that changes the snapshot format. It rewrites existing snapshot JSON files to the current format without touching the SQL.

```bash
npx drizzle-kit up
```

---

### `drizzle-kit export`

Exports SQL representing the current schema state without applying it to any database. Useful for audit, review, or feeding into external migration tools.

```bash
npx drizzle-kit export
```

---

### `drizzle-kit studio`

`drizzle-kit studio` will connect to your database and spin up a proxy server for Drizzle Studio which you can use for convenient database browsing.

Drizzle Studio is a powerful visual database browser that comes bundled with Drizzle Kit.

```bash
npx drizzle-kit studio

# custom port
npx drizzle-kit studio --port=4983
```

Opens at `https://local.drizzle.studio` by default.

---

## Migration Workflows

### Code-first (generate + migrate)

The standard production workflow. Schema lives in TypeScript; SQL migrations are generated and version-controlled.

```bash
# 1. Schema changes → generate migration
npx drizzle-kit generate

# 2. Review the SQL in drizzle/<timestamp>/migration.sql

# 3. Apply to database
npx drizzle-kit migrate
```

Migrations can alternatively be applied at runtime using `drizzle-orm`'s `migrate()` helper:

```ts
import { drizzle } from "drizzle-orm/node-postgres";
import { migrate } from "drizzle-orm/node-postgres/migrator";

const db = drizzle(client);
await migrate(db, { migrationsFolder: "./drizzle" });
```

### Push (prototyping / dev-only)

No migration files generated. Changes are applied immediately.

```bash
npx drizzle-kit push
```

### Database-first (pull)

Start from an existing database and get a TypeScript schema.

```bash
npx drizzle-kit pull
# produces drizzle/schema.ts
```

Then use the generated schema as the basis for code-first development.

---

## Custom Migrations

Generate an empty migration file for hand-written SQL (data migrations, unsupported DDL, seed data):

```bash
npx drizzle-kit generate --custom --name=seed_users
```

This produces an empty `migration.sql` in the usual timestamped folder. Write your SQL there:

```sql
-- drizzle/20242409125510_seed_users/migration.sql

INSERT INTO "users" ("name") VALUES ('Alice'), ('Bob');
```

### Running JS/TS migrations

Drizzle also supports JS/TS migration files in the same migrations folder for cases where raw SQL is insufficient (e.g., calling external APIs, conditional logic). These are run by `drizzle-kit migrate` alongside `.sql` files.

---

## Team Workflows

When multiple developers generate migrations simultaneously, their local timestamp-based folder names can collide. Drizzle Kit detects these via `check`.

Recommended CI step:

```bash
npx drizzle-kit check   # fails if collisions exist
npx drizzle-kit migrate
```

For teams using blue/green deploys or serverless databases (PlanetScale, Neon, Turso), `push` combined with branching databases is common for feature development, with `generate`/`migrate` reserved for production promotion.

---

## Multi-Database / Multi-Environment

Use multiple config files and pass `--config` to each command:

```
📦 project root
 ├ drizzle-dev.config.ts
 ├ drizzle-staging.config.ts
 └ drizzle-prod.config.ts
```

```bash
npx drizzle-kit push   --config=drizzle-dev.config.ts
npx drizzle-kit migrate --config=drizzle-prod.config.ts
```

---

## Migration Prefix Formats

Configurable via `migrations.prefix` in `drizzle.config.ts`:

| Value | Example folder name |
|---|---|
| `"timestamp"` (default) | `20242409125510_init` |
| `"supabase"` | Supabase-compatible format |
| `"index"` | `0001_init` |
| `"unix"` | Unix epoch prefix |

```ts
migrations: {
  prefix: "timestamp",
}
```

---

## Web and Mobile (Embedded Migrations)

For on-device databases (Expo SQLite, OP SQLite, React Native SQLite) there is no server to push or pull from. Use `generate` to produce migration files, then bundle them with `drizzle-orm`'s embedded migrator:

```ts
import { drizzle } from "drizzle-orm/expo-sqlite";
import { migrate } from "drizzle-orm/expo-sqlite/migrator";
import migrations from "./drizzle/migrations"; // generated JS object

const db = drizzle(expoDb);
await migrate(db, migrations);
```

`push` and `pull` are not available for these platforms.

---

## Drizzle Studio

Studio is bundled with `drizzle-kit`. It connects to your database via the same credentials and serves a local web UI.

```bash
npx drizzle-kit studio
# open https://local.drizzle.studio
```

Features: browse tables, filter rows, edit cells, inspect relations, run raw SQL queries. Uses the `dbCredentials` from your `drizzle.config.ts`.

---

## Operational Notes

**Do not delete snapshot JSON files.** Drizzle Kit diffs the current schema against the most recent `snapshot.json`. Deleting them breaks diff computation and may cause redundant or incorrect SQL to be generated.

**Breakpoints matter for MySQL/SQLite.** The `-- > statement-breakpoint` comment in generated SQL files tells the executor to split statements. Do not remove them if you are on MySQL or SQLite.

**`push --force` is destructive.** It accepts all data-loss statements (DROP COLUMN, DROP TABLE) without confirmation. Do not use in production scripts.

**`generate --ignore-conflicts` bypasses safety checks.** Use only when directed to do so, e.g., when working around a confirmed Drizzle Kit bug.

**`check` before `migrate` in CI.** Running `check` as a pre-step catches collision problems before they reach the database.

**Environment variables in config.** Load `.env` manually or use a library like `dotenv` since `defineConfig` is plain TypeScript:

```ts
import { defineConfig } from "drizzle-kit";
import "dotenv/config";

export default defineConfig({
  dialect: "postgresql",
  schema: "./src/schema.ts",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

---

## Quick Reference

```bash
# First-time setup
npx drizzle-kit generate --name=init
npx drizzle-kit migrate

# Iterative schema change
npx drizzle-kit generate
npx drizzle-kit migrate

# Dev: schema-first fast iteration
npx drizzle-kit push

# Migrate existing database to Drizzle
npx drizzle-kit pull

# Visual browser
npx drizzle-kit studio

# CI checks
npx drizzle-kit check

# After drizzle-kit version upgrade
npx drizzle-kit up
```

---

*Official docs: https://orm.drizzle.team/docs/kit-overview*