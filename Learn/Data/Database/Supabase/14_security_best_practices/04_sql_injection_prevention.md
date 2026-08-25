## SQL Injection Prevention


SQL injection occurs when untrusted input is concatenated into SQL queries, allowing attackers to manipulate query logic. Supabase's architecture provides strong protection against SQL injection when used correctly.

**How Supabase prevents SQL injection:**

PostgREST and Supabase client libraries use parameterized queries exclusively. User input is never directly concatenated into SQL statements. All filters, values, and parameters are passed as bound parameters, which PostgreSQL treats as data, not executable code.

**Safe query examples:**

Using Supabase client library (JavaScript):

```javascript
// Safe - parameters are bound, not concatenated
const { data, error } = await supabase
  .from('users')
  .select('*')
  .eq('email', userInput); // userInput is safely parameterized

// Safe - insertion with bound values
const { data, error } = await supabase
  .from('posts')
  .insert({ 
    title: userTitle,  // Safely parameterized
    content: userContent 
  });
```

**Unsafe patterns to avoid:**

When writing custom database functions or using direct SQL:

```sql
-- UNSAFE - vulnerable to SQL injection
CREATE FUNCTION search_users(search_term TEXT)
RETURNS SETOF users AS $$
BEGIN
  RETURN QUERY EXECUTE 
    'SELECT * FROM users WHERE name LIKE ''%' || search_term || '%''';
  -- If search_term contains SQL, it will execute
END;
$$ LANGUAGE plpgsql;
```

**Safe function implementation:**

```sql
-- SAFE - uses parameterized query
CREATE FUNCTION search_users(search_term TEXT)
RETURNS SETOF users AS $$
BEGIN
  RETURN QUERY 
    SELECT * FROM users 
    WHERE name ILIKE '%' || search_term || '%';
  -- Concatenation here is safe; search_term is treated as data
END;
$$ LANGUAGE plpgsql;
```

For dynamic SQL when necessary, use `EXECUTE` with `USING`:

```sql
CREATE FUNCTION dynamic_query(table_name TEXT, search_value TEXT)
RETURNS TABLE(result JSONB) AS $$
BEGIN
  -- Validate table_name against whitelist first
  IF table_name NOT IN ('users', 'posts', 'comments') THEN
    RAISE EXCEPTION 'Invalid table name';
  END IF;
  
  RETURN QUERY EXECUTE 
    format('SELECT row_to_json(t) FROM %I AS t WHERE name = $1', table_name)
  USING search_value;  -- Safely bound parameter
END;
$$ LANGUAGE plpgsql;
```

**Protection layers:**

- **Client libraries**: Automatically parameterize all queries
- **PostgREST**: Converts REST API calls to parameterized PostgreSQL queries
- **Row Level Security**: Even if injection were possible, RLS limits accessible data
- **Database functions**: Write secure functions using parameterized queries
- **Input validation**: Validate and constrain input before it reaches the database

**Direct database access:**

If connecting directly to PostgreSQL (not through Supabase APIs), always use parameterized queries:

```javascript
// Node.js with pg library - Safe
const result = await pool.query(
  'SELECT * FROM users WHERE email = $1',
  [userEmail]  // Parameterized
);

// UNSAFE - never do this
const result = await pool.query(
  `SELECT * FROM users WHERE email = '${userEmail}'`
);
```

**Best practices:**

- Always use Supabase client libraries or PostgREST API for queries
- Never construct SQL strings by concatenating user input
- If writing custom database functions, use parameters or `EXECUTE ... USING`
- Validate and whitelist dynamic identifiers (table names, column names) when absolutely necessary
- Apply principle of least privilege through RLS and database roles
- Regularly audit custom SQL code for injection vulnerabilities

[Inference: While Supabase's architecture makes SQL injection extremely difficult through normal usage, custom database functions and direct database connections require careful implementation]

