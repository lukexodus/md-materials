## Computed Columns


Computed columns are database views or generated columns that appear as regular columns in API responses but derive their values from calculations or transformations.

**Database views as computed fields:**

```sql
CREATE VIEW user_profiles AS
SELECT 
  users.id,
  users.name,
  users.email,
  COUNT(posts.id) as post_count,
  MAX(posts.created_at) as last_post_date
FROM users
LEFT JOIN posts ON posts.user_id = users.id
GROUP BY users.id;
```

The view becomes queryable: `GET /rest/v1/user_profiles`

**Generated columns:**

```sql
ALTER TABLE products
ADD COLUMN total_price NUMERIC GENERATED ALWAYS AS (price * quantity) STORED;
```

The `total_price` automatically appears in API responses and updates when dependencies change.

**Functions as computed columns:**

```sql
CREATE FUNCTION full_name(users)
RETURNS text AS $$
  SELECT $1.first_name || ' ' || $1.last_name;
$$ LANGUAGE SQL STABLE;
```

Access via: `?select=*,full_name`

**Use cases:**

- Aggregating related data (counts, sums, averages)
- Concatenating fields (full names, addresses)
- Formatting dates or numbers
- Security-filtered views (showing only permitted data)
- Complex calculations without client-side processing

