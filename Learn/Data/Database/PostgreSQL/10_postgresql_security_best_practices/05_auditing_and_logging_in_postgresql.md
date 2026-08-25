## Auditing and Logging in PostgreSQL


### Understanding PostgreSQL Logging

PostgreSQL provides robust logging capabilities that enable database administrators to track activities, monitor performance, ensure compliance, and troubleshoot issues. Proper logging configuration is essential for security auditing, performance tuning, and regulatory compliance.

**Key Points:**

- PostgreSQL offers highly configurable logging mechanisms
- Logs can be directed to standard error, syslog, or dedicated log files
- Different verbosity levels can be set for various types of operations
- Logs can include timestamps, process IDs, session information, and other metadata
- Proper auditing enhances security and aids in forensic analysis

### Core Logging Configuration Parameters

### Log Destination Configuration

PostgreSQL supports multiple log destinations that can be configured in postgresql.conf:

```
# Log destination options: stderr, csvlog, syslog, or eventlog (Windows)
log_destination = 'stderr'

# Directory where log files are stored when logging to files
log_directory = 'pg_log'

# Log filename pattern
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'

# Log file rotation settings
log_rotation_age = 1d
log_rotation_size = 10MB

# Keep up to 7 days of logs
log_truncate_on_rotation = on
```

### Log Content Configuration

Control what information gets recorded in logs:

```
# Timestamp format
log_timezone = 'UTC'
log_line_prefix = '%m [%p] %q%u@%d '

# Log level (debug5, debug4, debug3, debug2, debug1, info, notice, warning, error, log, fatal, panic)
log_min_messages = warning

# Log statement types (none, ddl, mod, all)
log_statement = 'ddl'

# Duration logging
log_min_duration_statement = 1000  # Log statements taking more than 1 second
```

### Log Line Prefix Variables

The `log_line_prefix` parameter supports variables to include specific information in log entries:

|Variable|Description|
|---|---|
|%a|Application name|
|%u|User name|
|%d|Database name|
|%r|Remote host and port|
|%h|Remote host|
|%p|Process ID|
|%t|Timestamp without milliseconds|
|%m|Timestamp with milliseconds|
|%i|Command tag|
|%e|SQL state|
|%c|Session ID|
|%l|Session line number|
|%s|Session start timestamp|
|%v|Virtual transaction ID|
|%x|Transaction ID|
|%q|Produces no output unless in debug mode|

**Example:**

```
log_line_prefix = '%m [%p] %q%u@%d:%h '
```

This would produce logs like:

```
2025-05-09 14:32:27.351 UTC [5678] user@database:192.168.1.100 LOG: statement: SELECT * FROM users;
```

### Audit Logging Capabilities

### Statement Logging

Configure logging of SQL statements based on type:

```
# Log all DDL statements (CREATE, ALTER, DROP)
log_statement = 'ddl'

# Log all DDL and DML statements (INSERT, UPDATE, DELETE)
log_statement = 'mod'

# Log all statements
log_statement = 'all'
```

### Duration-Based Logging

Log statements that exceed a specified execution time:

```
# Log statements taking longer than 1 second
log_min_duration_statement = 1000

# Log all statements with duration (set to 0)
log_min_duration_statement = 0
```

### Error Verbosity and Rate Limiting

Control error reporting and prevent log flooding:

```
# Error verbosity (terse, default, verbose)
log_error_verbosity = default

# Suppress repeated messages
log_min_error_statement = error

# Rate limit for repeated messages
log_min_messages_statement = 5
```

### Dedicated Audit Logging with pgAudit

### Installing pgAudit Extension

pgAudit is a PostgreSQL extension that provides more detailed audit logging:

```sql
-- Install the extension
CREATE EXTENSION pgaudit;
```

Configuration in postgresql.conf:

```
# Load pgAudit library
shared_preload_libraries = 'pgaudit'

# Audit log settings
pgaudit.log = 'write, ddl'
pgaudit.log_catalog = on
pgaudit.log_relation = on
pgaudit.log_parameter = on
```

### pgAudit Log Types

pgAudit supports logging various operation types:

|Type|Description|
|---|---|
|read|SELECT, COPY FROM|
|write|INSERT, UPDATE, DELETE, TRUNCATE, COPY TO|
|function|Function calls and DO blocks|
|role|GRANT, REVOKE, CREATE/ALTER/DROP ROLE|
|ddl|All DDL not included in other categories|
|misc|DISCARD, FETCH, CHECKPOINT, VACUUM, etc.|
|all|All of the above|

**Example:**

```
# Log data modification and DDL statements
pgaudit.log = 'write, ddl'
```

### Object-Level Audit Logging

pgAudit enables auditing specific objects in the database:

```sql
-- Enable auditing on a table
ALTER TABLE sensitive_data ENABLE AUDIT;

-- Set specific audit levels for a schema
ALTER SCHEMA finance SET pgaudit.log TO 'read, write';
```

### Role-Based Audit Logging

Configure auditing based on database roles:

```sql
-- Create an audit role
CREATE ROLE auditor;

-- Configure audit settings for the role
ALTER ROLE auditor SET pgaudit.log TO 'all';
ALTER ROLE auditor SET pgaudit.log_relation TO on;
```

### Advanced Audit Logging Options

### Tracking Parameter Values

Capture the actual values passed to SQL queries:

```
# Log parameter values for audited statements
pgaudit.log_parameter = on
```

This produces logs like:

```
AUDIT: SESSION,1,1,WRITE,INSERT,TABLE,public.sensitive_data,,"INSERT INTO sensitive_data (id, data) VALUES ($1, $2)",parameters: $1 = '123', $2 = 'sensitive information'
```

### Row-Level Changes Tracking

Track changes at the row level:

```
# Enable capturing row-level changes
track_commit_timestamp = on
```

Combined with triggers and audit tables:

```sql
-- Create audit table
CREATE TABLE audit_trail (
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    action TEXT NOT NULL,
    row_data JSONB,
    changed_by TEXT NOT NULL,
    changed_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Create audit function
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_trail (table_name, action, row_data, changed_by, changed_at)
        VALUES (TG_TABLE_NAME, 'DELETE', row_to_json(OLD), session_user, now());
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_trail (table_name, action, row_data, changed_by, changed_at)
        VALUES (TG_TABLE_NAME, 'UPDATE', 
                jsonb_build_object('old', row_to_json(OLD), 'new', row_to_json(NEW)),
                session_user, now());
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_trail (table_name, action, row_data, changed_by, changed_at)
        VALUES (TG_TABLE_NAME, 'INSERT', row_to_json(NEW), session_user, now());
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply to table
CREATE TRIGGER audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON sensitive_data
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();
```

### Logging User Context

Track application context in logs:

```sql
-- Set application name
SET application_name = 'inventory_app';

-- Set custom variables for logging
SET log_min_duration_statement = 0;
SELECT set_config('app.user_id', '12345', false);
SELECT set_config('app.operation', 'monthly_report', false);
```

Configure postgresql.conf to include these:

```
log_line_prefix = '%m [%p] %a %x %q%u@%d '
```

### Log Management and Rotation

### Log File Management

Configure log rotation to prevent disk space issues:

```
# Logs will be rotated when they reach this size
log_rotation_size = 100MB

# Logs will be rotated after this time period
log_rotation_age = 1d

# Truncate existing file of same name during rotation
log_truncate_on_rotation = on

# Keep this many log files
log_file_mode = 0600
```

### Centralized Logging

Send PostgreSQL logs to a centralized logging system:

```
# Using syslog
log_destination = 'syslog'
syslog_facility = 'LOCAL0'
syslog_ident = 'postgres'

# Using csvlog for easier parsing
log_destination = 'csvlog'
```

### Log Analysis and Monitoring Tools

### pgBadger

pgBadger is a powerful log analyzer for PostgreSQL:

```bash
# Generate a report from PostgreSQL logs
pgbadger /var/log/postgresql/postgresql-14-main.log -o report.html
```

### Built-in Statistics Views

PostgreSQL provides system views for monitoring and auditing:

```sql
-- View recent logged events
SELECT * FROM pg_stat_activity;

-- Check for slow queries
SELECT * FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;

-- Examine logged statements (requires log_statement = 'all')
SELECT * FROM pg_stat_statements WHERE query LIKE 'UPDATE%';
```

### Real-time Log Monitoring

Tools for real-time monitoring:

```bash
# Using tail for real-time monitoring
tail -f /var/log/postgresql/postgresql-14-main.log

# Using grep to filter specific events
tail -f /var/log/postgresql/postgresql-14-main.log | grep 'ERROR'
```

### Compliance and Security Auditing

### Regulatory Compliance

Configure logging to meet compliance requirements:

```
# For SOX, PCI-DSS, HIPAA, GDPR compliance
log_statement = 'mod'
log_min_duration_statement = 0
pgaudit.log = 'write, ddl, role, misc'
pgaudit.log_parameter = on
pgaudit.log_relation = on
```

### Failed Authentication Attempts

Track failed login attempts:

```
# Log all authentication failures
log_min_messages = info
log_connections = on
log_disconnections = on
```

### Capturing Session Activity

Record detailed session information:

```
# Enable detailed session logging
log_connections = on
log_disconnections = on
log_duration = on
```

### Implementing a Complete Audit Strategy

### Layered Audit Approach

A comprehensive audit strategy combines multiple techniques:

1. **Server-level logging**: Configure postgresql.conf for baseline logging
2. **pgAudit extension**: Enable detailed statement-level auditing
3. **Trigger-based auditing**: Create audit tables for row-level tracking
4. **Application-level auditing**: Implement audit trails within applications
5. **Log aggregation**: Centralize logs for analysis and retention

### Sample Comprehensive Audit Configuration

postgresql.conf:

```
# Base logging configuration
log_destination = 'csvlog'
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_truncate_on_rotation = on
log_rotation_age = 1d
log_rotation_size = 100MB

# What to log
log_min_messages = warning
log_min_error_statement = error
log_min_duration_statement = 1000
log_connections = on
log_disconnections = on
log_line_prefix = '%m [%p] %q%u@%d:%h '
log_statement = 'ddl'

# pgAudit configuration
shared_preload_libraries = 'pgaudit'
pgaudit.log = 'write, ddl, role'
pgaudit.log_catalog = on
pgaudit.log_parameter = on
pgaudit.log_relation = on
pgaudit.log_statement_once = off
```

SQL configuration:

```sql
-- Create audit schema
CREATE SCHEMA audit;

-- Create comprehensive audit table
CREATE TABLE audit.activity_log (
    id BIGSERIAL PRIMARY KEY,
    event_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
    user_name TEXT NOT NULL,
    database_name TEXT NOT NULL,
    client_addr INET,
    application_name TEXT,
    session_id TEXT,
    object_type TEXT,
    object_name TEXT,
    action TEXT NOT NULL,
    statement TEXT,
    parameters JSONB,
    old_values JSONB,
    new_values JSONB
);

-- Create functions and triggers for row-level auditing
-- (Implementation details as shown in earlier examples)

-- Set appropriate permissions
REVOKE ALL ON SCHEMA audit FROM public;
GRANT USAGE ON SCHEMA audit TO auditor_role;
REVOKE ALL ON audit.activity_log FROM public;
GRANT SELECT ON audit.activity_log TO auditor_role;

-- Protect audit logs from tampering
REVOKE ALL ON SCHEMA audit FROM dba_role;
```

### Troubleshooting Audit Logging

### Common Issues and Solutions

**Problem**: Logs not being generated **Solution**: Check logging_collector is on and log directory is writable

**Problem**: Log files growing too quickly **Solution**: Adjust log_min_duration_statement and implement log rotation

**Problem**: Performance impact from extensive logging **Solution**: Use selective auditing with appropriate filters:

```
# Only log expensive queries
log_min_duration_statement = 5000  # 5 seconds

# Use pgAudit selectively
pgaudit.log = 'write, ddl'
pgaudit.log_relation = off
```

### Log Analysis and Reporting

### Creating Audit Reports

SQL queries for audit reporting:

```sql
-- Security audit report
SELECT event_time, user_name, client_addr, action, object_name
FROM audit.activity_log
WHERE action IN ('INSERT', 'UPDATE', 'DELETE')
  AND object_name = 'sensitive_data'
  AND event_time > (current_date - interval '30 days')
ORDER BY event_time DESC;

-- Activity summary by user
SELECT user_name, action, count(*) as action_count
FROM audit.activity_log
WHERE event_time > (current_date - interval '7 days')
GROUP BY user_name, action
ORDER BY user_name, action_count DESC;
```

### Data Retention for Audit Logs

Implement a retention policy:

```sql
-- Create a partitioned audit table for better performance with large logs
CREATE TABLE audit.activity_log (
    id BIGSERIAL,
    event_time TIMESTAMP WITH TIME ZONE NOT NULL,
    -- other columns as before
    PRIMARY KEY (id, event_time)
) PARTITION BY RANGE (event_time);

-- Create monthly partitions
CREATE TABLE audit.activity_log_202501 PARTITION OF audit.activity_log
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE audit.activity_log_202502 PARTITION OF audit.activity_log
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

-- Retention policy function
CREATE OR REPLACE FUNCTION audit.maintain_partitions()
RETURNS void AS $$
DECLARE
    retention_months INTEGER := 12;
    current_date DATE := CURRENT_DATE;
    partition_date DATE;
    partition_name TEXT;
    drop_date DATE;
BEGIN
    -- Create future partition if needed
    partition_date := DATE_TRUNC('month', current_date + interval '2 month');
    partition_name := 'audit.activity_log_' || TO_CHAR(partition_date, 'YYYYMM');
    
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %s PARTITION OF audit.activity_log
         FOR VALUES FROM (%L) TO (%L)',
        partition_name,
        partition_date,
        partition_date + interval '1 month'
    );
    
    -- Drop old partitions
    drop_date := DATE_TRUNC('month', current_date - (retention_months * interval '1 month'));
    partition_name := 'audit.activity_log_' || TO_CHAR(drop_date, 'YYYYMM');
    
    EXECUTE format('DROP TABLE IF EXISTS %s', partition_name);
END;
$$ LANGUAGE plpgsql;

-- Create a scheduled job to maintain partitions
-- (using pg_cron or external scheduler)
```

### Best Practices for PostgreSQL Auditing

1. Define your audit requirements based on business needs and compliance requirements
2. Use pgAudit for detailed statement-level auditing
3. Implement trigger-based auditing for sensitive tables
4. Configure appropriate log rotation and retention policies
5. Centralize logs for analysis and long-term storage
6. Protect audit logs from unauthorized access or modification
7. Regularly review audit logs for security issues
8. Consider performance impacts and balance with security needs
9. Document your audit configuration and procedures
10. Test audit capabilities during disaster recovery exercises

### Additional Audit-Related Extensions

1. **pg_stat_statements**: Track execution statistics for all SQL statements
2. **pg_stat_activity**: Show current session activity
3. **auto_explain**: Automatically log query execution plans
4. **pg_cron**: Schedule maintenance of audit tables
5. **pg_partman**: Advanced partition management for audit tables

---

