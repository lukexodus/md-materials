## Bypassing RLS


**Bypassing RLS** in PostgreSQL means allowing a user or role to access table data without being restricted by **Row-Level Security (RLS)** policies. RLS policies control which rows a user can see or modify based on conditions (e.g., `WHERE user_id = current_user`). Bypassing RLS is typically granted to superusers or roles with the `BYPASSRLS` attribute, enabling full access to all rows, ignoring policy restrictions.

**Example**:
```sql
ALTER ROLE app_user WITH BYPASSRLS;
```
- `app_user` can now access all rows in tables with RLS policies.

**Key Points**:
- Used in **OLTP** for administrative tasks or privileged operations (e.g., auditing via triggers like `audit_employee_changes`).
- Dangerous if misused; only grant to trusted roles.
- Check with `\du+` in `psql` to see roles with `BYPASSRLS`.

---


### Relationships Between Databases, Tables, Schemas, and Roles in PostgreSQL

In PostgreSQL, **databases**, **tables**, **schemas**, and **roles** are core components that interact to organize and secure data. Understanding their relationships is crucial for managing **Online Transaction Processing (OLTP)** and **Online Analytical Processing (OLAP)** systems, especially in your context (e.g., using PL/pgSQL triggers, `\d+`, and IPv6 connections). Below is a concise explanation of their relationships, tailored to your setup.

#### Key Components
1. **Database**:
   - A database is a self-contained collection of data, schemas, and objects (e.g., tables, functions).
   - Each database is isolated; you connect to one at a time (e.g., your `postgres` database on `::1`).
   - Created with `CREATE DATABASE` (e.g., `CREATE DATABASE mydb WITH LC_COLLATE 'en_US.UTF-8';`).

2. **Schema**:
   - A schema is a namespace within a database that organizes objects like tables, views, and functions.
   - Default schema: `public`. Others can be created (e.g., `CREATE SCHEMA sales;`).
   - Schemas allow logical separation of data (e.g., `sales.employees` vs. `hr.employees`).

3. **Table**:
   - Tables store data in rows and columns within a schema (e.g., `public.employees` with your `employee_audit_trigger`).
   - Created with `CREATE TABLE` and accessed via queries or PL/pgSQL (e.g., your `audit_employee_changes` trigger).

4. **Role**:
   - A role is a user or group defining access permissions (e.g., `postgres` role in your setup).
   - Roles own objects, execute functions, and have privileges (e.g., `SELECT`, `INSERT`, `BYPASSRLS`).
   - Created with `CREATE ROLE` (e.g., `CREATE ROLE app_user WITH LOGIN PASSWORD 'secret';`).

#### Relationships
1. **Database ↔ Schema**:
   - A database contains multiple schemas (e.g., `public`, `sales`).
   - Schemas are bound to one database and cannot span databases.
   - Example: Your `postgres` database may have a `public` schema with the `employees` table.
   - View with `\l+` in `psql` to see databases and their schemas’ `LC_COLLATE`/`LC_CTYPE`.

2. **Schema ↔ Table**:
   - Tables reside within a specific schema (e.g., `public.employees`, `sales.orders`).
   - Schemas organize tables to avoid naming conflicts and manage permissions.
   - Example: Your `employees` table in `public` has a trigger (`employee_audit_trigger`).
   - View with `\d+ employees` to see table details and schema.

3. **Database ↔ Table**:
   - Tables exist within a database, indirectly through schemas.
   - A table is uniquely identified by `database.schema.table` (e.g., `postgres.public.employees`).
   - No direct database-to-table link without a schema.

4. **Role ↔ Database**:
   - Roles are cluster-wide but granted access to specific databases via privileges (e.g., `CONNECT`).
   - Example: Your `postgres` role connects to the `postgres` database on `::1`.
   - Grant with: `GRANT CONNECT ON DATABASE postgres TO app_user;`.

5. **Role ↔ Schema**:
   - Roles can own schemas or have privileges (e.g., `USAGE`, `CREATE`) on them.
   - Example: `GRANT USAGE ON SCHEMA public TO app_user;` allows access to `public`.
   - View with `\dn+` in `psql`.

6. **Role ↔ Table**:
   - Roles have privileges on tables (e.g., `SELECT`, `INSERT`, `TRIGGER`) or own them.
   - Example: Your `employee_audit_trigger` on `employees` may require `TRIGGER` privilege for a role.
   - Grant with: `GRANT SELECT, INSERT ON employees TO app_user;`.
   - Roles with `BYPASSRLS` (as you mentioned) ignore row-level security policies on tables.

7. **Role ↔ Role**:
   - Roles can inherit privileges from other roles (e.g., `GRANT admin TO app_user;`).
   - Supports group-like permissions (e.g., `app_user` inherits `SELECT` from `read_only`).

#### Visual Representation
```
Cluster
└── Database (postgres)
    ├── Schema (public)
    │   ├── Table (employees)
    │   │   └── Trigger (employee_audit_trigger)
    │   └── Table (employee_audit)
    ├── Schema (sales)
    │   └── Table (orders)
    └── Roles (postgres, app_user)
        ├── Privileges: CONNECT on Database
        ├── Privileges: USAGE on Schema
        ├── Privileges: SELECT, INSERT on Tables
        └── Attributes: LOGIN, BYPASSRLS
```

#### Practical Example (Your Context)
```sql
-- Create a role
CREATE ROLE app_user WITH LOGIN PASSWORD 'secret';

-- Grant database access
GRANT CONNECT ON DATABASE postgres TO app_user;

-- Grant schema access
GRANT USAGE ON SCHEMA public TO app_user;

-- Grant table privileges
GRANT SELECT, INSERT, UPDATE ON employees TO app_user;
GRANT INSERT ON employee_audit TO app_user;

-- Allow trigger execution
GRANT TRIGGER ON employees TO app_user;

-- Check relationships
\l+ postgres          -- Database: LC_COLLATE, LC_CTYPE
\dn+ public          -- Schema: public, owned by postgres
\d+ employees        -- Table: employees, with trigger
\du+ app_user        -- Role: privileges, BYPASSRLS status
```

**Output** (simplified):
- Database: `postgres` with `en_US.UTF-8` collation.
- Schema: `public`, accessible by `app_user`.
- Table: `employees` with `employee_audit_trigger`, modifiable by `app_user`.
- Role: `app_user` with `CONNECT`, `USAGE`, and table privileges.

#### Key Points
- **Databases** isolate schemas; **schemas** organize tables; **tables** store data; **roles** control access.
- Your setup (`::1`, `postgres` role) uses roles to manage triggers and tables in the `public` schema.
- **OLTP**: Roles enforce fine-grained access (e.g., `app_user` updates `employees` with triggers).
- **OLAP**: Schemas separate data (e.g., `sales` for analytics), roles control reporting access.
- Use `LC_COLLATE`/`LC_CTYPE` (e.g., `en_US.UTF-8`) for consistent sorting in queries.
- **BYPASSRLS** roles override RLS policies on tables for privileged tasks.

#### Best Practices
- Use schemas to separate **OLTP** (e.g., `transaction`) and **OLAP** (e.g., `analytics`) data.
- Grant minimal privileges to roles (e.g., `SELECT` only for reporting users).
- Avoid `public` schema for sensitive data; create dedicated schemas.
- Use `BYPASSRLS` sparingly, only for trusted roles (check with `\du+`).
- Monitor relationships with `\l+`, `\dn+`, `\d+`, and `\du+` in `psql`.

---

