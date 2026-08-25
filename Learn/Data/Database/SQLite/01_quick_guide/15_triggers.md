## Triggers


Triggers execute SQL automatically in response to `INSERT`, `UPDATE`, or `DELETE` events.

```sql
-- Log deletions
CREATE TABLE deleted_users_log (
    user_id  INTEGER,
    username TEXT,
    deleted_at TEXT DEFAULT (datetime('now'))
);

CREATE TRIGGER log_deleted_user
AFTER DELETE ON users
FOR EACH ROW
BEGIN
    INSERT INTO deleted_users_log (user_id, username)
    VALUES (OLD.id, OLD.username);
END;
```

### Trigger Timing

|Timing|Meaning|
|---|---|
|`BEFORE`|Fires before the operation|
|`AFTER`|Fires after the operation|
|`INSTEAD OF`|Fires in place of the operation (views only)|

### NEW and OLD References

- `NEW.column` — the incoming value (INSERT and UPDATE)
- `OLD.column` — the existing value (DELETE and UPDATE)

---

