## User and Role Management in PostgreSQL


### Understanding PostgreSQL Authentication and Authorization

PostgreSQL provides a robust security model centered around users, roles, and permissions that enables administrators to implement principle of least privilege access control. The system separates authentication (verifying identity) from authorization (determining permissions), offering fine-grained control over database resources.

### PostgreSQL Users vs Roles

Since PostgreSQL 8.1, "users" and "roles" are essentially the same concept with a minor distinction:

```sql
-- Creating a role (by default, cannot log in)
CREATE ROLE analytics;

-- Creating a user (role with login privilege)
CREATE USER data_scientist WITH PASSWORD 'secure_password';

-- Equivalent to:
CREATE ROLE data_scientist WITH LOGIN PASSWORD 'secure_password'; 
```

**Key Points**

- A "user" is simply a role with login privileges
- Users and roles exist in the same namespace
- The distinction is primarily semantic but helps clarify intended use
- Modern PostgreSQL practices favor the `ROLE` terminology with explicit privileges

### Creating and Managing Roles

#### Basic Role Creation

```sql
-- Create a basic role
CREATE ROLE read_only;

-- Create a role with specific attributes
CREATE ROLE reporting WITH 
    LOGIN 
    PASSWORD 'secure_password'
    CONNECTION LIMIT 5
    VALID UNTIL '2025-12-31';
    
-- Create a superuser role (only superusers can do this)
CREATE ROLE dba WITH SUPERUSER LOGIN PASSWORD 'very_secure_password';
```

#### Role Attributes

```sql
-- Set and modify role attributes
ALTER ROLE reporting CONNECTION LIMIT 10;
ALTER ROLE reporting VALID UNTIL '2026-12-31';
ALTER ROLE dba WITH NOSUPERUSER;
ALTER ROLE read_only WITH LOGIN PASSWORD 'new_password';

-- Rename a role
ALTER ROLE reporting RENAME TO bi_team;

-- Remove a role
DROP ROLE reporting;

-- Remove a role and reassign its objects
REASSIGN OWNED BY old_role TO new_role;
DROP ROLE old_role;
```

### Role Hierarchy and Inheritance

PostgreSQL enables role hierarchies through group roles and inheritance:

```sql
-- Create group roles
CREATE ROLE analytics;
CREATE ROLE developers;

-- Create user roles
CREATE USER analyst1 WITH PASSWORD 'password1';
CREATE USER analyst2 WITH PASSWORD 'password2';
CREATE USER dev1 WITH PASSWORD 'devpassword1';
CREATE USER dev2 WITH PASSWORD 'devpassword2';

-- Grant membership in group roles
GRANT analytics TO analyst1, analyst2;
GRANT developers TO dev1, dev2;

-- Grant permissions to group roles
GRANT USAGE ON SCHEMA analytics TO analytics;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO analytics;
```

#### Controlling Inheritance

```sql
-- Create role with NOINHERIT (permissions not automatically inherited)
CREATE ROLE financial_analyst LOGIN PASSWORD 'secure_password' NOINHERIT;

-- Grant membership but must explicitly set role to gain permissions
GRANT analytics TO financial_analyst;

-- Setting roles during a session
SET ROLE analytics;  -- Changes to the analytics role
RESET ROLE;          -- Returns to the original login role
```

### Managing Permissions

#### Object Ownership

```sql
-- Create object with specific ownership
CREATE TABLE sales (
    id serial PRIMARY KEY,
    amount numeric,
    sale_date date
) OWNER TO sales_admin;

-- Change ownership of an existing object
ALTER TABLE sales OWNER TO analytics;

-- Create an object as a different role
SET ROLE sales_admin;
CREATE TABLE customers (...);
RESET ROLE;
```

#### Basic Permission Management

```sql
-- Grant SELECT permission on a specific table
GRANT SELECT ON sales TO reporting;

-- Grant multiple permissions
GRANT SELECT, INSERT, UPDATE ON customers TO developers;

-- Revoke permissions
REVOKE INSERT, UPDATE ON customers FROM developers;

-- Grant permissions with grant option (can further grant to others)
GRANT SELECT ON sales TO bi_team WITH GRANT OPTION;
```

#### Schema-Level Permissions

```sql
-- Grant usage on schema
GRANT USAGE ON SCHEMA analytics TO reporting;

-- Grant SELECT on all tables in a schema
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO reporting;

-- Grant for future objects in schema
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT SELECT ON TABLES TO reporting;

-- Revoke schema-level privileges
REVOKE SELECT ON ALL TABLES IN SCHEMA analytics FROM guest;
```

### Default Roles and Privileges

PostgreSQL provides several predefined roles and default privileges:

```sql
-- Create objects with restrictive default privileges
CREATE SCHEMA secure_schema;
ALTER DEFAULT PRIVILEGES
    REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

-- Grant privileges to PUBLIC (all roles)
GRANT CONNECT ON DATABASE application_db TO PUBLIC;

-- Restrict public privileges
REVOKE ALL ON DATABASE sensitive_db FROM PUBLIC;
```

**Key Points**

- In PostgreSQL, `PUBLIC` represents all current and future roles
- By default, PUBLIC has EXECUTE privilege on functions
- Consider revoking default PUBLIC privileges for sensitive data
- Use default privileges to enforce security standards for new objects

### Role Management Best Practices

#### Least Privilege Model

```sql
-- App-specific roles with minimal privileges
CREATE ROLE app_readonly LOGIN PASSWORD 'app_password';
GRANT CONNECT ON DATABASE app_db TO app_readonly;
GRANT USAGE ON SCHEMA app TO app_readonly;
GRANT SELECT ON TABLE app.users TO app_readonly;

-- Create application user that can only execute specific functions
CREATE ROLE app_user LOGIN PASSWORD 'app_user_password';
REVOKE ALL ON ALL TABLES IN SCHEMA app FROM app_user;
GRANT EXECUTE ON FUNCTION app.authenticate_user(text, text) TO app_user;
GRANT EXECUTE ON FUNCTION app.get_user_profile(integer) TO app_user;
```

#### Role Naming Conventions

```sql
-- Consistent role naming examples
CREATE ROLE app_readonly;   -- Application-specific read-only role
CREATE ROLE app_readwrite;  -- Application-specific read-write role
CREATE ROLE app_admin;      -- Application-specific admin role
CREATE ROLE dba;            -- Database administrator
CREATE USER jsmith LOGIN;   -- Individual user account
```

### Role-Based Access Control (RBAC)

```sql
-- Create functional group roles
CREATE ROLE readonly;
CREATE ROLE readwrite;
CREATE ROLE admin;

-- Grant appropriate permissions to each role level
GRANT CONNECT ON DATABASE sales_db TO readonly;
GRANT USAGE ON SCHEMA sales TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA sales TO readonly;

GRANT readonly TO readwrite;  -- Inherit readonly permissions
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA sales TO readwrite;

GRANT readwrite TO admin;  -- Inherit readwrite permissions
GRANT CREATE, DROP ON SCHEMA sales TO admin;
GRANT TRUNCATE ON ALL TABLES IN SCHEMA sales TO admin;

-- Assign users to appropriate roles
CREATE USER alice LOGIN PASSWORD 'alice_password';
CREATE USER bob LOGIN PASSWORD 'bob_password';
CREATE USER charlie LOGIN PASSWORD 'charlie_password';

GRANT readonly TO alice;
GRANT readwrite TO bob;
GRANT admin TO charlie;
```

### Row-Level Security

PostgreSQL supports row-level security (RLS) for fine-grained access control:

```sql
-- Create table with sensitive data
CREATE TABLE customer_data (
    id serial PRIMARY KEY,
    customer_id int NOT NULL,
    name text,
    email text,
    account_balance numeric,
    notes text
);

-- Enable row-level security
ALTER TABLE customer_data ENABLE ROW LEVEL SECURITY;

-- Create policy for customer service representatives
CREATE POLICY customer_service_policy ON customer_data
    FOR SELECT
    TO customer_service
    USING (true);  -- Can see all rows
    
-- Create policy for customers to see only their own data
CREATE POLICY customer_view_own_data ON customer_data
    FOR SELECT
    TO customer_role
    USING (customer_id = current_setting('app.current_customer_id')::integer);

-- Create policy for financial analysts (can only see financial data)
CREATE POLICY finance_policy ON customer_data
    FOR SELECT
    TO finance
    USING (true)
    WITH CHECK (false);  -- Read-only access

-- Bypass RLS for specific roles
ALTER TABLE customer_data FORCE ROW LEVEL SECURITY;  -- Even for owners
ALTER ROLE admin BYPASSRLS;  -- Admin can bypass RLS
```

### Password Management and Authentication

#### Password Policies

```sql
-- Set password requirements
ALTER SYSTEM SET password_encryption = 'scram-sha-256';  -- Modern encryption
ALTER SYSTEM SET password_min_length = 12;               -- Minimum length

-- Set password expiration
ALTER USER analyst1 VALID UNTIL '2024-12-31';

-- Force password change on next login (emulated through expiration)
ALTER USER analyst1 VALID UNTIL 'yesterday';
```

#### Authentication Methods

PostgreSQL supports multiple authentication methods configured in `pg_hba.conf`:

```
# Example pg_hba.conf entries

# Local connections use peer authentication
local   all             all                                     peer

# Allow local network PostgreSQL MD5 password authentication
host    all             all             192.168.0.0/16          md5

# SCRAM authentication for specific database
host    financials      all             10.0.0.0/8              scram-sha-256

# Use LDAP authentication for domain users
host    all             all             0.0.0.0/0               ldap ldapserver=ldap.example.com ldapprefix="uid=" ldapsuffix=",ou=People,dc=example,dc=com"

# Allow replication connections with certificate
hostssl replication     replicator      10.10.0.0/24            cert
```

**Key Points**

- Multiple authentication methods can be configured based on connection type
- Authentication order follows the order in `pg_hba.conf`
- Modern PostgreSQL installations should use `scram-sha-256` instead of `md5`
- External authentication methods (LDAP, Kerberos, certificate) available for enterprise deployments

### Connection and Resource Control

```sql
-- Limit concurrent connections
ALTER ROLE reporting CONNECTION LIMIT 5;

-- Create role with resource limits using pgrowlocks
CREATE ROLE batch_processor WITH 
    LOGIN
    PASSWORD 'secure_password'
    CONNECTION LIMIT 2;

-- Set statement timeout for a role
ALTER ROLE batch_processor SET statement_timeout = '1h';

-- Set resource limits for a role
ALTER ROLE reporting SET work_mem = '64MB';
ALTER ROLE batch_processor SET maintenance_work_mem = '256MB';
```

### Auditing User Activity

```sql
-- Enable basic statement logging
ALTER SYSTEM SET log_statement = 'mod';  -- Log all DDL and modification statements
ALTER SYSTEM SET log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ';

-- Session-level auditing for specific roles
ALTER ROLE sensitive_data_user SET log_statement = 'all';
ALTER ROLE sensitive_data_user SET log_min_duration_statement = 0;

-- Extension-based auditing with pgaudit
CREATE EXTENSION pgaudit;
ALTER SYSTEM SET pgaudit.log = 'write, ddl';
ALTER SYSTEM SET pgaudit.log_relation = 'on';
ALTER SYSTEM SET pgaudit.log_statement_once = 'on';
```

### Integration with External Authentication Systems

#### LDAP Authentication

```
# pg_hba.conf entry for LDAP
host all all 0.0.0.0/0 ldap ldapserver=ldap.example.com ldapbasedn="ou=users,dc=example,dc=com" ldapsearchattribute=uid

# postgresql.conf settings
ldap_server = 'ldap.example.com'
ldap_port = 389
```

#### Certificate Authentication

```
# pg_hba.conf entry for certificate authentication
hostssl all all 0.0.0.0/0 cert clientcert=1 map=ssl-users

# Create mapping between certificate and database user
CREATE USER mapping FOR "CN=John Smith,OU=Development,O=Example Inc,C=US" WITH user=john;
```

### Advanced Use Cases

#### Database Application Users

```sql
-- Create application-specific user and schema
CREATE USER app_user WITH PASSWORD 'secure_app_password';
CREATE SCHEMA app_schema AUTHORIZATION app_user;

-- Restrict app_user to connect only from application server
-- In pg_hba.conf:
# host    app_db    app_user    192.168.1.100/32    scram-sha-256

-- Add essential permissions
GRANT CONNECT ON DATABASE app_db TO app_user;
GRANT USAGE ON SCHEMA app_schema TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app_schema TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA app_schema TO app_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES FOR ROLE app_admin IN SCHEMA app_schema
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES FOR ROLE app_admin IN SCHEMA app_schema
    GRANT USAGE, SELECT ON SEQUENCES TO app_user;
```

#### Multi-Tenant Database Design

```sql
-- Create base tenant role
CREATE ROLE tenant_template NOLOGIN;
GRANT CONNECT ON DATABASE multi_tenant_app TO tenant_template;
GRANT USAGE ON SCHEMA public TO tenant_template;
GRANT SELECT ON public.shared_lookup_tables TO tenant_template;

-- Create tenant-specific schema and role
CREATE SCHEMA tenant_abc;
CREATE ROLE tenant_abc LOGIN PASSWORD 'abc_password';
GRANT tenant_template TO tenant_abc;
GRANT USAGE ON SCHEMA tenant_abc TO tenant_abc;
GRANT ALL ON ALL TABLES IN SCHEMA tenant_abc TO tenant_abc;

-- Create tenant-specific tables
CREATE TABLE tenant_abc.customers (id serial PRIMARY KEY, name text);
CREATE TABLE tenant_abc.orders (id serial PRIMARY KEY, customer_id integer);

-- Set up row-level security for shared tables
CREATE TABLE public.all_tenant_data (
    id serial PRIMARY KEY,
    tenant_id text NOT NULL,
    data jsonb
);

ALTER TABLE public.all_tenant_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON public.all_tenant_data
    FOR ALL
    TO tenant_template
    USING (tenant_id = current_user::text)
    WITH CHECK (tenant_id = current_user::text);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.all_tenant_data TO tenant_template;
```

#### Dynamic Role Management

```sql
-- Function to create a new application user with standard permissions
CREATE OR REPLACE FUNCTION admin.create_app_user(
    username text,
    password text
) RETURNS void AS $$
BEGIN
    -- Create user
    EXECUTE format('CREATE USER %I WITH PASSWORD %L', username, password);
    
    -- Grant base permissions
    EXECUTE format('GRANT app_base_role TO %I', username);
    
    -- Create user-specific schema
    EXECUTE format('CREATE SCHEMA %I AUTHORIZATION %I', username, username);
    
    -- Log creation
    INSERT INTO admin.user_audit_log(action, username, created_by)
    VALUES ('CREATE_USER', username, session_user);
    
    RAISE NOTICE 'User % created successfully', username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to revoke user access
CREATE OR REPLACE FUNCTION admin.disable_user(username text) RETURNS void AS $$
BEGIN
    -- Revoke connection ability
    EXECUTE format('ALTER USER %I WITH NOLOGIN', username);
    
    -- Record action
    INSERT INTO admin.user_audit_log(action, username, created_by)
    VALUES ('DISABLE_USER', username, session_user);
    
    RAISE NOTICE 'User % disabled', username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Security Best Practices

**Key Points**

- Create separate roles for different functions (connection, read-only, read-write, admin)
- Avoid using superuser accounts for routine operations
- Set restrictive default privileges
- Implement connection encryption via SSL/TLS
- Use strong authentication methods (SCRAM-SHA-256, certificates)
- Implement regular privilege audits
- Consider row-level security for multi-user applications
- Apply the principle of least privilege consistently

#### Automated Security Audit

```sql
-- View to identify users with superuser privileges
CREATE OR REPLACE VIEW admin.superuser_audit AS
SELECT rolname, rolcreatedb, rolcreaterole, rolreplication
FROM pg_roles
WHERE rolsuper = true;

-- View to identify tables with public write access
CREATE OR REPLACE VIEW admin.public_write_access AS
SELECT table_schema, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'PUBLIC'
AND privilege_type IN ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE');

-- Function to audit permission grants
CREATE OR REPLACE FUNCTION admin.audit_permissions() RETURNS TABLE (
    issue text,
    object_type text,
    object_name text,
    details text
) AS $$
BEGIN
    -- Check for PUBLIC schema write permissions
    RETURN QUERY
    SELECT 'Public Schema Write'::text, 'schema'::text, 
           table_schema::text, privilege_type::text
    FROM information_schema.role_table_grants
    WHERE grantee = 'PUBLIC'
    AND table_schema NOT IN ('information_schema', 'pg_catalog')
    AND privilege_type IN ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE');
    
    -- Check for users with password authentication issues
    RETURN QUERY
    SELECT 'Weak Auth'::text, 'role'::text, rolname::text, 
           'Password authentication using md5'::text
    FROM pg_roles r
    JOIN pg_authid a ON r.oid = a.oid
    WHERE rolcanlogin AND rolname NOT IN ('postgres')
    AND NOT a.rolpassword LIKE 'SCRAM-SHA-256%';
    
    -- More checks can be added here
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Real-World Implementation Examples

#### Banking Application Role Structure

```sql
-- Core database roles
CREATE ROLE bank_app_base NOLOGIN;
CREATE ROLE bank_app_readonly LOGIN PASSWORD 'readonly_pwd';
CREATE ROLE bank_app_teller LOGIN PASSWORD 'teller_pwd';
CREATE ROLE bank_app_manager LOGIN PASSWORD 'manager_pwd';
CREATE ROLE bank_app_admin LOGIN PASSWORD 'admin_pwd';
CREATE ROLE bank_app_system LOGIN PASSWORD 'system_pwd';

-- Role hierarchy
GRANT bank_app_base TO bank_app_readonly;
GRANT bank_app_readonly TO bank_app_teller;
GRANT bank_app_teller TO bank_app_manager;
GRANT bank_app_manager TO bank_app_admin;

-- Base permissions
GRANT CONNECT ON DATABASE bank_db TO bank_app_base;
GRANT USAGE ON SCHEMA banking TO bank_app_base;
GRANT SELECT ON banking.branch_info TO bank_app_base;
GRANT SELECT ON banking.product_catalog TO bank_app_base;

-- Read-only role - can view most data
GRANT SELECT ON ALL TABLES IN SCHEMA banking TO bank_app_readonly;

-- Teller role - can perform transactions
GRANT INSERT ON banking.transactions TO bank_app_teller;
GRANT UPDATE ON banking.customer_accounts TO bank_app_teller;
GRANT EXECUTE ON FUNCTION banking.process_deposit(int, numeric) TO bank_app_teller;
GRANT EXECUTE ON FUNCTION banking.process_withdrawal(int, numeric) TO bank_app_teller;

-- Manager role - can manage customer accounts
GRANT INSERT, UPDATE ON banking.customers TO bank_app_manager;
GRANT UPDATE (credit_limit) ON banking.customer_accounts TO bank_app_manager;
GRANT EXECUTE ON FUNCTION banking.approve_loan(int, numeric) TO bank_app_manager;

-- Admin role - can perform schema changes
GRANT CREATE ON SCHEMA banking TO bank_app_admin;
GRANT ALL ON ALL TABLES IN SCHEMA banking TO bank_app_admin;

-- System role - for batch processes and automation
GRANT bank_app_readonly TO bank_app_system;
GRANT EXECUTE ON FUNCTION banking.run_eod_processing() TO bank_app_system;
GRANT EXECUTE ON FUNCTION banking.generate_statements() TO bank_app_system;

-- Row-level security for customer data
ALTER TABLE banking.customer_accounts ENABLE ROW LEVEL SECURITY;

-- Policy for tellers (can only see accounts from their branch)
CREATE POLICY teller_branch_accounts ON banking.customer_accounts
    FOR ALL
    TO bank_app_teller
    USING (branch_id = (SELECT branch_id FROM banking.employees 
                        WHERE employee_id = current_setting('app.employee_id')::int));

-- Managers can see all accounts
CREATE POLICY manager_all_accounts ON banking.customer_accounts
    FOR ALL
    TO bank_app_manager
    USING (true);
```

#### Software-as-a-Service Multi-Tenant Setup

```sql
-- Base tenant schema
CREATE SCHEMA tenant_template;
CREATE TABLE tenant_template.users (
    id serial PRIMARY KEY,
    username text UNIQUE,
    email text,
    created_at timestamp DEFAULT now()
);
CREATE TABLE tenant_template.projects (
    id serial PRIMARY KEY,
    name text,
    created_by integer REFERENCES tenant_template.users(id),
    created_at timestamp DEFAULT now()
);

-- Template role structure
CREATE ROLE tenant_role_template NOLOGIN;
CREATE ROLE tenant_user_template NOLOGIN;
CREATE ROLE tenant_admin_template NOLOGIN;

-- Function to provision a new tenant
CREATE OR REPLACE FUNCTION admin.provision_tenant(
    tenant_name text,
    admin_email text,
    admin_password text
) RETURNS void AS $$
DECLARE
    schema_name text;
    role_name text;
    admin_role_name text;
    user_role_name text;
BEGIN
    -- Sanitize tenant name for use in identifiers
    schema_name := 'tenant_' || regexp_replace(lower(tenant_name), '[^a-z0-9]', '_', 'g');
    role_name := schema_name || '_role';
    admin_role_name := schema_name || '_admin';
    user_role_name := schema_name || '_user';
    
    -- Create schema
    EXECUTE format('CREATE SCHEMA %I', schema_name);
    
    -- Create roles
    EXECUTE format('CREATE ROLE %I NOLOGIN', role_name);
    EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', admin_role_name, admin_password);
    EXECUTE format('CREATE ROLE %I NOLOGIN', user_role_name);
    
    -- Set up role hierarchy
    EXECUTE format('GRANT %I TO %I', role_name, admin_role_name);
    EXECUTE format('GRANT %I TO %I', role_name, user_role_name);
    
    -- Grant template permissions
    EXECUTE format('GRANT tenant_role_template TO %I', role_name);
    EXECUTE format('GRANT tenant_admin_template TO %I', admin_role_name);
    EXECUTE format('GRANT tenant_user_template TO %I', user_role_name);
    
    -- Clone template schema
    EXECUTE format('CREATE TABLE %I.users (LIKE tenant_template.users INCLUDING ALL)', schema_name);
    EXECUTE format('CREATE TABLE %I.projects (LIKE tenant_template.projects INCLUDING ALL)', schema_name);
    EXECUTE format('ALTER TABLE %I.projects
                    ADD CONSTRAINT projects_created_by_fkey
                    FOREIGN KEY (created_by) REFERENCES %I.users(id)',
                    schema_name, schema_name);
    
    -- Set ownership and permissions
    EXECUTE format('ALTER SCHEMA %I OWNER TO %I', schema_name, admin_role_name);
    EXECUTE format('GRANT USAGE ON SCHEMA %I TO %I', schema_name, role_name);
    EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO %I', schema_name, admin_role_name);
    EXECUTE format('GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA %I TO %I', 
                  schema_name, user_role_name);
    
    -- Create initial admin user in the tenant
    EXECUTE format('INSERT INTO %I.users (username, email) VALUES (%L, %L)', 
                  schema_name, 'admin', admin_email);
                  
    -- Log provisioning
    INSERT INTO admin.tenant_registry (tenant_name, schema_name, admin_email, created_at)
    VALUES (tenant_name, schema_name, admin_email, now());
    
    RAISE NOTICE 'Tenant % successfully provisioned with schema %', tenant_name, schema_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Conclusion**

PostgreSQL's user and role management system provides a flexible and powerful foundation for implementing complex security models. By properly leveraging roles, privileges, and advanced features like row-level security, organizations can enforce strong security policies while maintaining usability.

Effective role management practices include:

- Creating a well-defined role hierarchy
- Separating authentication from authorization
- Implementing the principle of least privilege
- Using group roles for permission management
- Leveraging schema-level security boundaries
- Employing row-level security for multi-tenant applications
- Regular auditing of role permissions

For complex systems, consider developing standardized procedures for role provisioning and a systematic approach to permission management. With proper design, PostgreSQL's security system can scale from simple applications to enterprise environments with sophisticated compliance requirements.

Related topics: PostgreSQL encryption options, audit logging strategies, integration with enterprise identity management, and implementing custom authentication methods.

---

