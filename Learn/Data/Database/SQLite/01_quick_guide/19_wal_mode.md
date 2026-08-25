## WAL Mode


Write-Ahead Logging (WAL) is an alternative journaling mode that improves concurrency.

```sql
PRAGMA journal_mode = WAL;
```

In WAL mode:

- Readers do not block writers, and writers do not block readers.
- Multiple readers can coexist with one writer.
- Performance for write-heavy workloads is generally better.
- The database consists of the main file plus `-wal` and `-shm` sidecar files while WAL mode is active.

WAL mode persists across connections and survives restarts. To return to the default:

```sql
PRAGMA journal_mode = DELETE;
```

---

