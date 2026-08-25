## Backup and Restore


### File Copy (Offline)

When no connection is writing, simply copy the `.db` file.

```bash
cp mydata.db mydata.backup.db
```

### SQLite Online Backup API

The Online Backup API (accessible via the CLI or language bindings) safely copies a live database without stopping writes.

```bash
sqlite3 mydata.db ".backup mydata.backup.db"
```

### Dump to SQL

```bash
sqlite3 mydata.db .dump > mydata.sql
```

### Restore from SQL Dump

```bash
sqlite3 newdata.db < mydata.sql
```

---

