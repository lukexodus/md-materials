## Triggers


Triggers automatically execute functions in response to specific database events (INSERT, UPDATE, DELETE, TRUNCATE). They enforce business rules, maintain data integrity, and automate workflows.

### Trigger Creation

```sql
CREATE TRIGGER trigger_name
{BEFORE | AFTER | INSTEAD OF} {INSERT | UPDATE | DELETE}
ON table_name
[FOR EACH {ROW | STATEMENT}]
[WHEN (condition)]
EXECUTE FUNCTION function_name();
```

**Example: Automatic timestamp update**

```sql
CREATE OR REPLACE FUNCTION update_modified_timestamp()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_modified_timestamp();
```

### Trigger Types and Timing

**BEFORE Triggers**

Execute before the triggering operation. They can:

- Modify NEW row values before insertion/update
- Prevent operations by returning NULL
- Validate data before changes occur
- Transform input data

```sql
CREATE OR REPLACE FUNCTION validate_email()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
    RAISE EXCEPTION 'Invalid email format: %', NEW.email;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER check_email_format
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION validate_email();
```

**AFTER Triggers**

Execute after the triggering operation completes. They are used for:

- Logging changes
- Cascading operations to related tables
- Sending notifications
- Maintaining audit trails

```sql
CREATE OR REPLACE FUNCTION log_user_changes()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO audit_log(table_name, operation, old_data, new_data, changed_at)
  VALUES (
    TG_TABLE_NAME,
    TG_OP,
    row_to_json(OLD),
    row_to_json(NEW),
    NOW()
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER audit_user_changes
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION log_user_changes();
```

**INSTEAD OF Triggers**

Only available on views. They replace the default operation with custom logic.

```sql
CREATE VIEW user_summary AS
SELECT id, email, profile_data->>'name' as name
FROM users;

CREATE OR REPLACE FUNCTION update_user_summary()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE users
  SET 
    email = NEW.email,
    profile_data = jsonb_set(profile_data, '{name}', to_jsonb(NEW.name))
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER instead_of_update_summary
INSTEAD OF UPDATE ON user_summary
FOR EACH ROW
EXECUTE FUNCTION update_user_summary();
```

### Row-Level vs Statement-Level Triggers

**FOR EACH ROW**

Executes once per affected row. Access to OLD and NEW row variables.

```sql
CREATE TRIGGER row_level_example
AFTER UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION track_price_changes();
```

**Use cases:**

- Individual row validation
- Per-row audit logging
- Row-specific calculations
- Maintaining row-level history

**FOR EACH STATEMENT**

Executes once per SQL statement, regardless of rows affected.

```sql
CREATE TRIGGER statement_level_example
AFTER INSERT ON orders
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_sales_summary();
```

**Use cases:**

- Aggregate operations
- Cache invalidation
- Batch notifications
- Performance optimization for bulk operations

**Key differences:**

- Row-level: OLD and NEW available, executes per row
- Statement-level: No row context, executes once per statement
- Row-level has higher overhead for bulk operations
- Statement-level more efficient for operations affecting many rows

### Trigger Special Variables

Within trigger functions, PostgreSQL provides special variables:

- `NEW`: New row data (INSERT/UPDATE)
- `OLD`: Old row data (UPDATE/DELETE)
- `TG_OP`: Operation type ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')
- `TG_TABLE_NAME`: Table name that triggered the function
- `TG_TABLE_SCHEMA`: Schema of the triggering table
- `TG_WHEN`: Timing ('BEFORE', 'AFTER', 'INSTEAD OF')
- `TG_LEVEL`: Level ('ROW', 'STATEMENT')

```sql
CREATE OR REPLACE FUNCTION flexible_audit()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO audit_log(operation, table_name, old_data)
    VALUES (TG_OP, TG_TABLE_NAME, row_to_json(OLD));
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_log(operation, table_name, old_data, new_data)
    VALUES (TG_OP, TG_TABLE_NAME, row_to_json(OLD), row_to_json(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO audit_log(operation, table_name, new_data)
    VALUES (TG_OP, TG_TABLE_NAME, row_to_json(NEW));
    RETURN NEW;
  END IF;
END;
$$;
```

