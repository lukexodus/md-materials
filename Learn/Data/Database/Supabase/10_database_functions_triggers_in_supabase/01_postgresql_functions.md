## PostgreSQL Functions


PostgreSQL functions are reusable code blocks that can be executed on the database server. They encapsulate logic, perform calculations, manipulate data, and return results.

### Function Structure

A basic PostgreSQL function consists of:

- Function name and parameters
- Return type specification
- Function body with logic
- Language declaration

```sql
CREATE OR REPLACE FUNCTION function_name(param1 type, param2 type)
RETURNS return_type
LANGUAGE plpgsql
AS $$
BEGIN
  -- function logic here
  RETURN result;
END;
$$;
```

### Function Languages

**PL/pgSQL (Procedural Language/PostgreSQL)**

PL/pgSQL is the most commonly used procedural language for PostgreSQL functions. It supports variables, control structures, exception handling, and complex logic.

```sql
CREATE OR REPLACE FUNCTION calculate_order_total(order_id uuid)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
  total numeric := 0;
  tax_rate numeric := 0.08;
BEGIN
  SELECT SUM(quantity * price)
  INTO total
  FROM order_items
  WHERE order_items.order_id = calculate_order_total.order_id;
  
  RETURN total * (1 + tax_rate);
END;
$$;
```

**Key features:**

- Variable declarations in DECLARE block
- Control structures (IF, CASE, LOOP, WHILE, FOR)
- Exception handling with BEGIN...EXCEPTION blocks
- Dynamic SQL with EXECUTE
- Record and row type support

**SQL Language**

SQL language functions contain only SQL statements without procedural logic. They are simpler and often more performant for straightforward queries.

```sql
CREATE OR REPLACE FUNCTION get_active_users()
RETURNS TABLE(id uuid, email text, created_at timestamptz)
LANGUAGE sql
AS $$
  SELECT id, email, created_at
  FROM users
  WHERE is_active = true
  ORDER BY created_at DESC;
$$;
```

**Characteristics:**

- No procedural constructs
- Direct SQL query execution
- Better optimization by query planner
- Immutable or stable function volatility classification possible

**Other Languages**

PostgreSQL supports additional languages through extensions:

- PL/Python (requires extension)
- PL/Perl (requires extension)
- PL/V8 (JavaScript, requires extension)

[Unverified] Supabase hosted instances may have limitations on which procedural languages are available beyond PL/pgSQL and SQL.

