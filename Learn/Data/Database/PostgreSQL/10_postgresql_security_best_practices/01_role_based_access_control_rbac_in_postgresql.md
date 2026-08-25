## Role-Based Access Control (RBAC) in PostgreSQL


### Understanding RBAC in PostgreSQL

Role-Based Access Control (RBAC) is PostgreSQL's security framework that manages database access permissions through roles. In PostgreSQL, roles are entities that can own database objects and have database privileges. Since PostgreSQL 8.1, roles have unified the concepts of users and groups into a single entity type.

**Key Points:**

- Roles can represent individual users or groups of users
- Roles can be members of other roles (role inheritance)
- PostgreSQL doesn't distinguish between users and groups at the system level
- RBAC allows for precise control of who can access what in your database
- Well-implemented RBAC enhances security while maintaining operational flexibility

### Core Concepts of PostgreSQL RBAC

### Roles vs Users

In PostgreSQL terminology:

- A role with LOGIN privilege is effectively a "user"
- A role without LOGIN privilege is effectively a "group"
- Any role can be a member of another role, creating a hierarchical structure

### Role Attributes

Roles can have various attributes that define their capabilities:

|Attribute|Description|
|---|---|
|SUPERUSER|Can bypass all permission checks (except LOGIN)|
|CREATEDB|Can create new databases|
|CREATEROLE|Can create, alter, and drop other roles|
|LOGIN|Can connect to the database (makes the role a "user")|
|REPLICATION|Can connect in replication mode|
|BYPASSRLS|Can bypass row-level security policies|
|PASSWORD|Sets authentication password for the role|
|CONNECTION LIMIT|Limits number of concurrent connections|

### Creating and Managing Roles

### Creating Roles

Basic syntax for creating roles:

```sql
CREATE ROLE role_name [WITH options];
```

**Example:**

```sql
-- Create an admin role with various privileges
CREATE ROLE admin_role WITH 
  CREATEDB 
  CREATEROLE 
  LOGIN 
  PASSWORD 'secure_password';

-- Create a read-only group role
CREATE ROLE readonly_users;
```

### Creating Users (Roles with LOGIN)

```sql
CREATE USER username [WITH options];
```

The CREATE USER command is equivalent to CREATE ROLE with LOGIN attribute.

**Example:**

```sql
-- Create a regular user
CREATE USER john WITH PASSWORD 'secret_password';
```

### Altering Roles

```sql
ALTER ROLE role_name WITH options;
```

**Example:**

```sql
-- Update a role's attributes
ALTER ROLE john WITH CREATEDB NOCREATEROLE;

-- Change password
ALTER ROLE john WITH PASSWORD 'new_secure_password';

-- Set connection limit
ALTER ROLE reporting_user WITH CONNECTION LIMIT 5;
```

### Removing Roles

```sql
DROP ROLE [IF EXISTS] role_name;
```

**Example:**

```sql
-- Remove a role safely
DROP ROLE IF EXISTS temp_user;
```

### Role Membership and Inheritance

### Adding Members to Roles

```sql
GRANT role_to_grant TO target_role;
```

**Example:**

```sql
-- Add john to the readonly_users role
GRANT readonly_users TO john;

-- Add multiple users to a role
GRANT analyst_role TO sarah, david, emma;
```

### Removing Members from Roles

```sql
REVOKE role_to_revoke FROM target_role;
```

**Example:**

```sql
-- Remove john from the readonly_users role
REVOKE readonly_users FROM john;
```

### Inheritance and NOINHERIT

By default, roles inherit the privileges of roles they are members of:

```sql
-- Create a role without inheritance
CREATE ROLE no_inherit_role NOINHERIT;

-- Change inheritance setting
ALTER ROLE some_role INHERIT;
```

### Managing Privileges with RBAC

### Basic Privilege Types

PostgreSQL provides granular privileges for different operations:

|Privilege|Description|
|---|---|
|SELECT|Retrieve data from tables/views|
|INSERT|Add new rows to tables|
|UPDATE|Modify existing rows|
|DELETE|Remove rows from tables|
|TRUNCATE|Empty a table or set of tables|
|REFERENCES|Create foreign key constraints|
|TRIGGER|Create triggers|
|CREATE|Create objects within schema|
|CONNECT|Connect to a database|
|TEMPORARY|Create temporary tables|
|EXECUTE|Execute functions/procedures|
|USAGE|Use sequences, types, domains, etc.|
|ALL PRIVILEGES|Grant all available privileges|

### Granting Privileges

```sql
GRANT privilege ON object TO role;
```

**Example:**

```sql
-- Grant SELECT on all tables in a schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_users;

-- Grant multiple privileges on a specific table
GRANT SELECT, INSERT, UPDATE, DELETE ON orders TO sales_staff;

-- Grant schema usage
GRANT USAGE ON SCHEMA analytics TO reporting_role;

-- Grant execute on functions
GRANT EXECUTE ON FUNCTION calculate_totals() TO analyst_role;
```

### Revoking Privileges

```sql
REVOKE privilege ON object FROM role;
```

**Example:**

```sql
-- Revoke DELETE privilege on a table
REVOKE DELETE ON customer_data FROM sales_staff;

-- Revoke all privileges
REVOKE ALL PRIVILEGES ON orders FROM temp_role;
```

### Using WITH GRANT OPTION

Allow a role to pass privileges to others:

```sql
GRANT privilege ON object TO role WITH GRANT OPTION;
```

**Example:**

```sql
-- Allow team_lead to grant SELECT privilege to others
GRANT SELECT ON sales_data TO team_lead WITH GRANT OPTION;
```

### Default Privileges

Set privileges for objects created in the future:

```sql
ALTER DEFAULT PRIVILEGES
  [FOR ROLE target_role]
  [IN SCHEMA schema_name]
  GRANT privileges ON object_type TO grantee_role;
```

**Example:**

```sql
-- Grant SELECT on future tables created by app_user in the app_schema
ALTER DEFAULT PRIVILEGES FOR ROLE app_user IN SCHEMA app_schema
  GRANT SELECT ON TABLES TO readonly_users;
```

### Implementing RBAC for Common Use Cases

### Application Database Access Pattern

```sql
-- Create database owner role (no login)
CREATE ROLE app_owner;

-- Create application service role (with login)
CREATE ROLE app_service WITH LOGIN PASSWORD 'secure_app_password';

-- Create readonly role for reporting
CREATE ROLE app_readonly;

-- Assign membership
GRANT app_owner TO app_service;
GRANT app_readonly TO reporting_user;

-- Set ownership and permissions
ALTER TABLE app_data OWNER TO app_owner;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;
```

### Multi-tenant Database Pattern

```sql
-- Create tenant admin roles
CREATE ROLE tenant_a_admin;
CREATE ROLE tenant_b_admin;

-- Create schemas for isolation
CREATE SCHEMA tenant_a AUTHORIZATION tenant_a_admin;
CREATE SCHEMA tenant_b AUTHORIZATION tenant_b_admin;

-- Create application roles
CREATE ROLE tenant_a_app WITH LOGIN PASSWORD 'tenant_a_password';
CREATE ROLE tenant_b_app WITH LOGIN PASSWORD 'tenant_b_password';

-- Assign permissions
GRANT tenant_a_admin TO tenant_a_app;
GRANT tenant_b_admin TO tenant_b_app;

-- Restrict schema access
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE USAGE ON SCHEMA tenant_a FROM tenant_b_app;
REVOKE USAGE ON SCHEMA tenant_b FROM tenant_a_app;
```

### Row-Level Security with RBAC

Combining RBAC with Row-Level Security (RLS):

```sql
-- Enable RLS on a table
ALTER TABLE customer_data ENABLE ROW LEVEL SECURITY;

-- Create policy based on role
CREATE POLICY customer_isolation ON customer_data
  FOR ALL
  TO PUBLIC
  USING (tenant_id = current_setting('app.tenant_id', TRUE));

-- Create roles with RLS bypass if needed
CREATE ROLE admin_role WITH BYPASSRLS;
```

### Best Practices for PostgreSQL RBAC

1. Follow the principle of least privilege
2. Create functional roles (groups) based on job functions
3. Assign users to roles rather than granting permissions directly
4. Use schema-based isolation for multi-tenant applications
5. Implement row-level security for data segregation within tables
6. Regularly audit role memberships and permissions
7. Avoid using superuser for routine operations
8. Establish naming conventions for roles
9. Document your RBAC structure
10. Use password policies and rotation for user roles

### Advanced RBAC Techniques

### Role Password Management

```sql
-- Set password with expiration
ALTER ROLE username WITH PASSWORD 'new_password' VALID UNTIL '2025-12-31';

-- Require password change
ALTER ROLE username WITH PASSWORD 'temporary_password' VALID UNTIL 'infinity';
```

### Connection Limiting for Roles

```sql
-- Limit concurrent connections
ALTER ROLE reporting_role CONNECTION LIMIT 10;
```

### Role Comments for Documentation

```sql
-- Add documentation to roles
COMMENT ON ROLE admin_role IS 'Database administrators with full access';
```

### Schema Isolation with Search Path

```sql
-- Set default schema search path for a role
ALTER ROLE tenant_a_app SET search_path TO tenant_a, public;
```

### Monitoring and Auditing RBAC

### Viewing Role Information

```sql
-- List all roles
SELECT rolname, rolsuper, rolinherit, rolcreaterole, 
       rolcreatedb, rolcanlogin, rolreplication, rolconnlimit, rolvaliduntil
FROM pg_roles;

-- Show role memberships
SELECT r.rolname, m.member, m.grantor, m.admin_option
FROM pg_auth_members m
JOIN pg_roles r ON m.roleid = r.oid
JOIN pg_roles m_role ON m.member = m_role.oid
ORDER BY r.rolname;
```

### Auditing Permissions

```sql
-- Check table privileges
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'target_table';

-- Check column-level privileges
SELECT grantee, column_name, privilege_type
FROM information_schema.column_privileges
WHERE table_name = 'customer_data';
```

### Setting Up Audit Logging

```sql
-- Enable command logging in postgresql.conf
# log_statement = 'ddl'  # Logs all data definition statements
# log_statement = 'mod'  # Logs all modification statements
# log_statement = 'all'  # Logs all statements

-- Or use an audit extension like pgAudit
CREATE EXTENSION pgaudit;
```

### Common RBAC Challenges and Solutions

### Managing Role Proliferation

As databases grow, roles can proliferate. Implement a hierarchical structure with functional groups:

```sql
-- Base role structure
CREATE ROLE app_users;
CREATE ROLE app_admins;
CREATE ROLE app_service_accounts;

-- Department-specific roles
CREATE ROLE sales_users;
CREATE ROLE marketing_users;

-- Inheritance structure
GRANT app_users TO sales_users, marketing_users;
```

### Handling Role Transitions

When employees change roles:

```sql
-- Remove old permissions
REVOKE sales_role FROM employee_user;

-- Add new permissions
GRANT marketing_role TO employee_user;

-- Check for orphaned objects
SELECT tablename FROM pg_tables WHERE tableowner = 'employee_user';
ALTER TABLE employee_owned_table OWNER TO department_role;
```

### Troubleshooting RBAC Issues

**Permission Denied Errors:**

```
ERROR:  permission denied for table customer_data
```

Diagnostic query:

```sql
-- Check actual permissions
SELECT grantee, privilege_type 
FROM information_schema.table_privileges 
WHERE table_name = 'customer_data';

-- Check role memberships
SELECT r.rolname AS role, u.rolname AS member
FROM pg_roles r
JOIN pg_auth_members m ON r.oid = m.roleid
JOIN pg_roles u ON m.member = u.oid
WHERE u.rolname = 'problem_user';
```

### Role Management Tools and Extensions

1. **pgAdmin**: GUI for PostgreSQL with robust role management features
2. **psql** meta-commands: `\du`, `\dp`, `\ddp` for viewing roles and permissions
3. **pgAudit**: Extension for detailed audit logging of database activities
4. **HypoPG**: Testing privilege changes without applying them
5. **pg_permissions**: Extension for simplified permission reporting

### Migrating to an RBAC Model

If transitioning from a legacy permission system:

1. Document current permissions and access patterns
2. Design your role hierarchy
3. Create new roles without affecting existing access
4. Gradually transfer users to new roles
5. Test thoroughly before cutting over
6. Keep your old roles during transition as a fallback

**Example Migration Script:**

```sql
-- Create new role structure
CREATE ROLE new_readonly_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO new_readonly_role;

-- Add existing user to new role temporarily
GRANT new_readonly_role TO legacy_user;

-- After testing, transfer completely
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM legacy_user;
-- Keep the legacy_user → new_readonly_role membership
```

### RBAC in Connection with External Authentication

When using external authentication like LDAP, Kerberos, or SAML:

```sql
-- Create role that will match SSO group
CREATE ROLE sso_admin_users NOLOGIN;
GRANT appropriate_permissions TO sso_admin_users;

-- Mapping happens in pg_hba.conf or identity provider
# Example pg_hba.conf entry
# hostssl all sso_user scram-sha-256 clientcert=1 map=ssl-map
```

---

