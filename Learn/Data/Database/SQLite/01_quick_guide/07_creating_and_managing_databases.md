## Creating and Managing Databases


### Creating a Database

A database is created implicitly when you open a file that does not exist:

```sql
-- Nothing special needed; the file is created on first write
```

### Attaching Additional Databases

```sql
ATTACH DATABASE 'archive.db' AS archive;

-- Query across both
SELECT * FROM main.orders
UNION ALL
SELECT * FROM archive.orders;

DETACH DATABASE archive;
```

---

