## N+1 Query Problems


N+1 queries occur when an application executes one query to fetch a list, then N additional queries to fetch related data for each item. This pattern severely impacts performance.

### Identifying N+1 Problems

**Anti-pattern example:**

```javascript
// BAD: N+1 query problem
const { data: users } = await supabase
  .from('users')
  .select('id, email')
  .limit(10)

// This executes 10 additional queries!
for (const user of users) {
  const { data: orders } = await supabase
    .from('orders')
    .select('*')
    .eq('user_id', user.id)
  
  user.orders = orders
}
```

This results in 11 queries total (1 + 10).

### Solutions

**Use JOIN or nested select:**

```javascript
// GOOD: Single query with join
const { data: users } = await supabase
  .from('users')
  .select(`
    id,
    email,
    orders (
      id,
      total,
      created_at
    )
  `)
  .limit(10)
```

**Use IN clause with batching:**

```javascript
// GOOD: Two queries total
const { data: users } = await supabase
  .from('users')
  .select('id, email')
  .limit(10)

const userIds = users.map(u => u.id)

const { data: orders } = await supabase
  .from('orders')
  .select('*')
  .in('user_id', userIds)

// Group orders by user in application
const ordersByUser = orders.reduce((acc, order) => {
  if (!acc[order.user_id]) acc[order.user_id] = []
  acc[order.user_id].push(order)
  return acc
}, {})

users.forEach(user => {
  user.orders = ordersByUser[user.id] || []
})
```

### PostgreSQL-Level Detection

```sql
-- Monitor for patterns indicating N+1
SELECT 
  LEFT(query, 100) as query_pattern,
  calls,
  mean_exec_time,
  total_exec_time
FROM pg_stat_statements
WHERE calls > 1000
  AND query LIKE '%WHERE%=%'
ORDER BY calls DESC;
```

### Complex N+1 Example

```javascript
// BAD: Multiple levels of N+1
async function getBadUserData() {
  const users = await db.query('SELECT * FROM users LIMIT 10')
  
  for (const user of users) {
    user.orders = await db.query('SELECT * FROM orders WHERE user_id = ?', [user.id])
    
    for (const order of user.orders) {
      order.items = await db.query('SELECT * FROM order_items WHERE order_id = ?', [order.id])
      // 10 users * 5 orders * query = 50 additional queries
    }
  }
  
  return users
}

// GOOD: Single optimized query
async function getGoodUserData() {
  const { data } = await supabase
    .from('users')
    .select(`
      *,
      orders (
        *,
        order_items (
          *,
          product:products (
            id,
            name,
            price
          )
        )
      )
    `)
    .limit(10)
  
  return data
}
```

### Using Database Functions for Complex Queries

```sql
-- Create function to return nested data
CREATE OR REPLACE FUNCTION get_user_with_orders(p_user_id uuid)
RETURNS json AS $$
BEGIN
  RETURN (
    SELECT json_build_object(
      'user', row_to_json(u.*),
      'orders', COALESCE(
        (
          SELECT json_agg(
            json_build_object(
              'order', row_to_json(o.*),
              'items', (
                SELECT json_agg(row_to_json(oi.*))
                FROM order_items oi
                WHERE oi.order_id = o.id
              )
            )
          )
          FROM orders o
          WHERE o.user_id = u.id
        ),
        '[]'::json
      )
    )
    FROM users u
    WHERE u.id = p_user_id
  );
END;
$$ LANGUAGE plpgsql;

-- Call from application
const { data } = await supabase.rpc('get_user_with_orders', {
  p_user_id: userId
})
```

