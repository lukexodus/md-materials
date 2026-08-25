## JSON Support


SQLite includes built-in JSON functions (available since 3.9.0, significantly extended since).

```sql
-- Extract a value
SELECT json_extract('{"name":"Alice","age":30}', '$.name');  -- 'Alice'

-- Store JSON in a column and query it
CREATE TABLE events (id INTEGER PRIMARY KEY, data TEXT);

INSERT INTO events (data) VALUES ('{"type":"login","user":"alice"}');

SELECT json_extract(data, '$.user')
FROM events
WHERE json_extract(data, '$.type') = 'login';

-- Build JSON
SELECT json_object('id', id, 'name', username) FROM users;

-- JSON array
SELECT json_array(1, 2, 3);  -- '[1,2,3]'
```

---

