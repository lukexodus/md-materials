## Setting Up Authentication and Access Control


### Understanding PostgreSQL Authentication

PostgreSQL provides a robust and flexible authentication and access control system that allows database administrators to secure their database instances against unauthorized access while providing appropriate permissions to legitimate users.

**Key Points**:

- Authentication determines who can connect to the database
- Access control determines what connected users can do
- PostgreSQL uses multiple layers of security from connection to object permissions
- Configuration is primarily done through pg_hba.conf and role management

### PostgreSQL Authentication Methods

#### Password Authentication

PostgreSQL supports several password authentication methods, each with different security characteristics:

```
# In pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    all             all             0.0.0.0/0               md5
host    all             all             0.0.0.0/0               scram-sha-256
```

- `md5`: Password is transmitted as an MD5 hash
- `scram-sha-256`: More secure challenge-response mechanism (recommended for PostgreSQL 10+)
- `password`: Plain text password (avoid except with SSL)

To enable SCRAM authentication:

```sql
-- Set password encryption method (in postgresql.conf)
-- or via ALTER SYSTEM
ALTER SYSTEM SET password_encryption = 'scram-sha-256';

-- Create user with encrypted password
CREATE ROLE appuser WITH LOGIN PASSWORD 'securepassword';
```

#### Certificate Authentication

Using SSL certificates for authentication offers enhanced security:

```
# In pg_hba.conf
hostssl all             all             0.0.0.0/0               cert clientcert=1
```

SSL certificate setup:

```sql
-- Generate certificates (shell commands)
-- openssl req -new -text -out server.req
-- openssl x509 -req -in server.req -text -days 365 -out server.crt

-- Configure postgresql.conf
ALTER SYSTEM SET ssl = on;
ALTER SYSTEM SET ssl_cert_file = 'server.crt';
ALTER SYSTEM SET ssl_key_file = 'server.key';
ALTER SYSTEM SET ssl_ca_file = 'root.crt';
```

#### LDAP Authentication

Integrating with enterprise directory services:

```
# In pg_hba.conf
host    all             all             0.0.0.0/0               ldap ldapserver=ldap.example.org ldapprefix="cn=" ldapsuffix=", dc=example, dc=org"
```

### HBA Configuration File Structure

The Host-Based Authentication (HBA) configuration file controls which hosts can connect to which databases using which authentication methods.

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                peer
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
host    production      app_user        10.0.0.0/24             scram-sha-256
host    replication     repl_user       10.0.0.5/32             scram-sha-256
```

To reload configuration after changes:

```sql
SELECT pg_reload_conf();
```

### Role-Based Access Control

PostgreSQL uses roles (users and groups) to manage authentication and authorization.

#### Creating Roles

```sql
-- Create a login role (user)
CREATE ROLE app_user WITH LOGIN PASSWORD 'secure_password';

-- Create a group role
CREATE ROLE developers;

-- Add users to group
GRANT developers TO app_user;
```

#### Attribute-Based Permissions

Roles can have special attributes that grant system-wide privileges:

```sql
-- Superuser role
CREATE ROLE admin WITH SUPERUSER LOGIN PASSWORD 'very_secure_password';

-- Role that can create databases
CREATE ROLE db_creator WITH CREATEDB LOGIN PASSWORD 'secure_password';

-- Role that can create roles
CREATE ROLE user_admin WITH CREATEROLE LOGIN PASSWORD 'secure_password';

-- Role that can initiate replication
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'secure_password';
```

### Database and Schema Level Permissions

#### Database Permissions

```sql
-- Create database owned by a specific role
CREATE DATABASE appdb OWNER app_owner;

-- Grant connect access to a database
GRANT CONNECT ON DATABASE appdb TO app_user;

-- Grant all privileges on a database
GRANT ALL PRIVILEGES ON DATABASE appdb TO admin_role;

-- Revoke privileges
REVOKE ALL PRIVILEGES ON DATABASE appdb FROM untrusted_role;
```

#### Schema Permissions

```sql
-- Create schema
CREATE SCHEMA app_schema AUTHORIZATION app_owner;

-- Grant usage permission on schema
GRANT USAGE ON SCHEMA app_schema TO app_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA app_schema
GRANT SELECT ON TABLES TO readonly_role;
```

### Object-Level Access Control

#### Table Permissions

```sql
-- Grant read access to a table
GRANT SELECT ON app_schema.customers TO readonly_role;

-- Grant read/write access
GRANT SELECT, INSERT, UPDATE, DELETE ON app_schema.customers TO readwrite_role;

-- Grant all privileges
GRANT ALL PRIVILEGES ON app_schema.customers TO admin_role;

-- Grant column-level permissions
GRANT SELECT (id, name, email) ON app_schema.customers TO limited_role;
GRANT UPDATE (email, phone) ON app_schema.customers TO support_role;
```

#### Function Permissions

```sql
-- Grant execute permission on a function
GRANT EXECUTE ON FUNCTION app_schema.calculate_totals(integer) TO analyst_role;
```

### Row-Level Security (RLS)

Row-Level Security allows fine-grained control over which rows a user can access.

```sql
-- Enable RLS on a table
ALTER TABLE app_schema.documents ENABLE ROW LEVEL SECURITY;

-- Create a policy that limits users to their own data
CREATE POLICY user_documents ON app_schema.documents
    USING (user_id = current_user_id());
    
-- Policy with different permissions for different operations
CREATE POLICY docs_view ON app_schema.documents
    FOR SELECT
    USING (status = 'public' OR user_id = current_user_id());
    
CREATE POLICY docs_modify ON app_schema.documents
    FOR UPDATE
    USING (user_id = current_user_id());
```

### Implementing Application-Level Security

#### Connection Pooling with Authentication

Using PgBouncer with authentication:

```ini
# pgbouncer.ini
[databases]
appdb = host=localhost port=5432 dbname=appdb

[pgbouncer]
listen_port = 6432
listen_addr = *
auth_type = md5
auth_file = userlist.txt
```

#### Connection String Security

Secure connection string handling in applications:

```python
# Using environment variables for credentials
import os
import psycopg2

db_conn = psycopg2.connect(
    host=os.environ.get('PG_HOST', 'localhost'),
    port=os.environ.get('PG_PORT', '5432'),
    dbname=os.environ.get('PG_DATABASE', 'appdb'),
    user=os.environ.get('PG_USER', 'app_user'),
    password=os.environ.get('PG_PASSWORD', '')
)
```

#### Implementing Connection Encryption

Enforcing SSL connections:

```python
# Python with SSL
db_conn = psycopg2.connect(
    host='db.example.com',
    dbname='appdb',
    user='app_user',
    password='secure_password',
    sslmode='require'  # Options: disable, allow, prefer, require, verify-ca, verify-full
)
```

### Security Best Practices

#### Regular Password Rotation

```sql
-- Update user password
ALTER ROLE app_user WITH PASSWORD 'new_secure_password';

-- Force password expiry
ALTER ROLE app_user WITH VALID UNTIL '2023-12-31';
```

#### Least Privilege Principle

```sql
-- Create read-only user
CREATE ROLE reporter WITH LOGIN PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE analytics TO reporter;
GRANT USAGE ON SCHEMA reports TO reporter;
GRANT SELECT ON ALL TABLES IN SCHEMA reports TO reporter;

-- Make sure future tables follow the same pattern
ALTER DEFAULT PRIVILEGES IN SCHEMA reports
GRANT SELECT ON TABLES TO reporter;
```

#### Connection Limits

Prevent resource exhaustion:

```sql
-- Limit connections per role
ALTER ROLE app_user CONNECTION LIMIT 10;

-- Set statement timeout
ALTER ROLE app_user SET statement_timeout = '30s';
```

### Monitoring and Auditing

#### Logging Authentication Attempts

Configure in postgresql.conf:

```
log_connections = on
log_disconnections = on
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_statement = 'ddl'  # Options: none, ddl, mod, all
```

#### Auditing Database Activity

```sql
-- Create audit table
CREATE TABLE audit.user_activity (
    id serial PRIMARY KEY,
    user_name text,
    action_timestamp timestamp with time zone NOT NULL DEFAULT current_timestamp,
    client_addr inet,
    action text,
    object_type text,
    object_name text
);

-- Create audit function
CREATE OR REPLACE FUNCTION audit_function()
RETURNS event_trigger AS $$
DECLARE
    obj record;
BEGIN
    SELECT * INTO obj FROM pg_event_trigger_ddl_commands() LIMIT 1;
    
    INSERT INTO audit.user_activity (
        user_name, action, object_type, object_name
    ) VALUES (
        session_user, 
        tg_tag, 
        obj.object_type, 
        obj.object_identity
    );
END;
$$ LANGUAGE plpgsql;

-- Create event trigger
CREATE EVENT TRIGGER audit_ddl ON ddl_command_end 
EXECUTE FUNCTION audit_function();
```

### Implementing Multi-Factor Authentication

While PostgreSQL doesn't natively support MFA, it can be implemented through external authentication systems.

#### PAM Integration

PostgreSQL can use Pluggable Authentication Modules (PAM) for MFA:

```
# In pg_hba.conf
local   all             all                                     pam pamservice=postgresql
```

PAM configuration (/etc/pam.d/postgresql):

```
auth    required    pam_unix.so
auth    required    pam_google_authenticator.so
```

### Automating User Management

#### Role Creation Script

```bash
#!/bin/bash
# create_user.sh

USERNAME=$1
PASSWORD=$2
DBNAME=$3
SCHEMA=$4

psql -v ON_ERROR_STOP=1 <<EOF
-- Create role
CREATE ROLE $USERNAME WITH LOGIN PASSWORD '$PASSWORD';

-- Grant connect to database
GRANT CONNECT ON DATABASE $DBNAME TO $USERNAME;

-- Grant schema usage
GRANT USAGE ON SCHEMA $SCHEMA TO $USERNAME;

-- Grant table access
GRANT SELECT ON ALL TABLES IN SCHEMA $SCHEMA TO $USERNAME;
ALTER DEFAULT PRIVILEGES IN SCHEMA $SCHEMA GRANT SELECT ON TABLES TO $USERNAME;

-- Set resource limits
ALTER ROLE $USERNAME SET statement_timeout = '30s';
ALTER ROLE $USERNAME CONNECTION LIMIT 5;
EOF
```

### Advanced Security Configurations

#### Network Level Security

In postgresql.conf:

```
listen_addresses = 'localhost,192.168.1.100'  # Control which IP addresses PostgreSQL listens on
port = 5432                                    # Default port; consider non-standard for security
```

#### Encryption At Rest

Using filesystem encryption or PostgreSQL's encryption extensions:

```sql
-- Using pgcrypto for column-level encryption
CREATE EXTENSION pgcrypto;

-- Store encrypted data
INSERT INTO sensitive_data (id, encrypted_data)
VALUES (1, pgp_sym_encrypt('secret information', 'encryption_key'));

-- Retrieve decrypted data
SELECT id, pgp_sym_decrypt(encrypted_data, 'encryption_key') AS decrypted
FROM sensitive_data;
```

**Conclusion**

Setting up authentication and access control in PostgreSQL requires careful planning and implementation across multiple layers. By properly configuring the HBA file, managing roles and permissions, implementing row-level security where needed, and following security best practices, you can create a secure PostgreSQL environment that protects your data while allowing appropriate access to legitimate users.

### Recommended Related Topics

- PostgreSQL Encryption Options and Data Security
- Implementing High Availability with Security Considerations
- PostgreSQL Audit Logging and Compliance
- Advanced Row-Level Security Patterns

---

