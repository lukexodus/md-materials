## Recursive Queries


Recursive CTEs allow querying hierarchical or graph-structured data by repeatedly executing a query until a condition is met.

### Organization Hierarchy

```sql
CREATE OR REPLACE FUNCTION get_employee_hierarchy(root_employee_id bigint)
RETURNS TABLE (
  id bigint,
  name text,
  manager_id bigint,
  level int
) AS $$
BEGIN
  RETURN QUERY
  WITH RECURSIVE employee_tree AS (
    -- Base case
    SELECT e.id, e.name, e.manager_id, 1 as level
    FROM employees e
    WHERE e.id = root_employee_id
    
    UNION ALL
    
    -- Recursive case
    SELECT e.id, e.name, e.manager_id, et.level + 1
    FROM employees e
    JOIN employee_tree et ON e.manager_id = et.id
  )
  SELECT * FROM employee_tree;
END;
$$ LANGUAGE plpgsql;
```

### Category Tree

```sql
WITH RECURSIVE category_path AS (
  SELECT 
    id, 
    name, 
    parent_id,
    name::text as path,
    1 as depth
  FROM categories
  WHERE parent_id IS NULL
  
  UNION ALL
  
  SELECT 
    c.id,
    c.name,
    c.parent_id,
    cp.path || ' > ' || c.name,
    cp.depth + 1
  FROM categories c
  JOIN category_path cp ON c.parent_id = cp.id
)
SELECT * FROM category_path;
```

### Graph Traversal

```sql
WITH RECURSIVE connections AS (
  SELECT user_id, friend_id, 1 as degree
  FROM friendships
  WHERE user_id = 123
  
  UNION
  
  SELECT f.user_id, f.friend_id, c.degree + 1
  FROM friendships f
  JOIN connections c ON f.user_id = c.friend_id
  WHERE c.degree < 3
)
SELECT DISTINCT friend_id, MIN(degree) as closest_degree
FROM connections
GROUP BY friend_id;
```

