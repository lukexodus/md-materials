## Custom API Routes via Functions


PostgreSQL functions become RPC endpoints in Supabase, enabling custom API routes with complex business logic.

**Creating a custom endpoint:**

```sql
CREATE OR REPLACE FUNCTION calculate_order_total(order_id INT)
RETURNS NUMERIC AS $$
  SELECT SUM(quantity * price) 
  FROM order_items 
  WHERE order_items.order_id = $1;
$$ LANGUAGE SQL STABLE;
```

**Calling the function:**

```
POST /rest/v1/rpc/calculate_order_total
Content-Type: application/json

{
  "order_id": 123
}
```

**Function with multiple parameters:**

```sql
CREATE FUNCTION search_products(
  search_term TEXT,
  min_price NUMERIC DEFAULT 0,
  max_price NUMERIC DEFAULT 999999
)
RETURNS SETOF products AS $$
  SELECT * FROM products
  WHERE name ILIKE '%' || search_term || '%'
  AND price BETWEEN min_price AND max_price;
$$ LANGUAGE SQL STABLE;
```

Call with: `POST /rest/v1/rpc/search_products` with JSON body containing parameters.

**Function types:**

- **VOLATILE**: Default, can modify database state
- **STABLE**: Doesn't modify database, results consistent within single query
- **IMMUTABLE**: Deterministic, same input always produces same output

Use STABLE or IMMUTABLE when possible for better performance and caching.

**Return types:**

- Scalar values: `RETURNS TEXT`, `RETURNS INT`
- Single row: `RETURNS TABLE(col1 type, col2 type)`
- Multiple rows: `RETURNS SETOF table_name`
- JSON: `RETURNS JSON` or `RETURNS JSONB`
- Void: `RETURNS VOID` for operations without return value

**Security:** Functions inherit the privileges of the user calling them unless defined with `SECURITY DEFINER`, which executes with the privileges of the function creator.

```sql
CREATE FUNCTION admin_only_operation()
RETURNS VOID
SECURITY DEFINER
SET search_path = public
AS $$
  -- Runs with elevated privileges
  DELETE FROM sensitive_data WHERE expired = true;
$$ LANGUAGE SQL;
```

[Inference: `SECURITY DEFINER` should be used cautiously as it can bypass RLS policies]

**Use cases:**

- Complex calculations not expressible in single queries
- Multi-step transactions requiring atomicity
- Custom authentication or authorization logic
- Data aggregation and reporting
- Integration with external services (via extensions)
- Batch operations with custom validation

