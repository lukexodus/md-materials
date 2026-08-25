## Views


A view is a saved SELECT query that acts like a read-only table.

```sql
CREATE VIEW active_users_view AS
SELECT id, username, email
FROM users
WHERE active = 1;

SELECT * FROM active_users_view WHERE username LIKE 'a%';

DROP VIEW active_users_view;
```

---

