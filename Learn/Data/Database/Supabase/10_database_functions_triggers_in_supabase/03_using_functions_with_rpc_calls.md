## Using Functions with RPC Calls


Supabase allows you to call PostgreSQL functions directly from your client code using RPC (Remote Procedure Call). This exposes server-side logic through your API.

### Creating RPC-Callable Functions

```sql
CREATE OR REPLACE FUNCTION get_user_stats(user_id uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result json;
BEGIN
  SELECT json_build_object(
    'total_orders', COUNT(DISTINCT o.id),
    'total_spent', COALESCE(SUM(o.total), 0),
    'last_order_date', MAX(o.created_at)
  )
  INTO result
  FROM orders o
  WHERE o.user_id = get_user_stats.user_id;
  
  RETURN result;
END;
$$;
```

### Calling Functions from Supabase Client

```javascript
// JavaScript/TypeScript
const { data, error } = await supabase
  .rpc('get_user_stats', { user_id: '123e4567-e89b-12d3-a456-426614174000' })

// With multiple parameters
const { data, error } = await supabase
  .rpc('search_products', { 
    search_term: 'laptop',
    min_price: 500,
    max_price: 2000
  })
```

### Function Security Modifiers

**SECURITY DEFINER vs SECURITY INVOKER**

```sql
-- SECURITY DEFINER: Runs with function creator's privileges
CREATE OR REPLACE FUNCTION admin_delete_user(user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM users WHERE id = user_id;
END;
$$;

-- SECURITY INVOKER: Runs with caller's privileges (default)
CREATE OR REPLACE FUNCTION get_my_profile()
RETURNS json
LANGUAGE sql
SECURITY INVOKER
AS $$
  SELECT row_to_json(users.*)
  FROM users
  WHERE id = auth.uid();
$$;
```

**SECURITY DEFINER considerations:**

- Use sparingly for administrative operations
- Always set `search_path` to prevent search path manipulation attacks
- Validate all inputs carefully
- Grant execute permissions explicitly

### Return Types for RPC

**Scalar values:**

```sql
CREATE FUNCTION get_total_users() RETURNS bigint
LANGUAGE sql AS $$
  SELECT COUNT(*) FROM users;
$$;
```

**Table returns:**

```sql
CREATE FUNCTION search_users(query text)
RETURNS TABLE(id uuid, email text, name text)
LANGUAGE sql AS $$
  SELECT id, email, profile->>'name' as name
  FROM users
  WHERE email ILIKE '%' || query || '%';
$$;
```

**JSON returns:**

```sql
CREATE FUNCTION get_dashboard_data()
RETURNS json
LANGUAGE sql AS $$
  SELECT json_build_object(
    'users', (SELECT COUNT(*) FROM users),
    'orders', (SELECT COUNT(*) FROM orders),
    'revenue', (SELECT SUM(total) FROM orders)
  );
$$;
```

