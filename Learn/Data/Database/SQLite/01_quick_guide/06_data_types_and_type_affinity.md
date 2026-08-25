## Data Types and Type Affinity


SQLite uses a flexible **type affinity** system rather than strict column types.

### Storage Classes

Every value stored belongs to one of five storage classes:

|Storage Class|Description|
|---|---|
|NULL|The null value|
|INTEGER|Signed integer, 1–8 bytes depending on magnitude|
|REAL|8-byte IEEE 754 floating-point number|
|TEXT|UTF-8, UTF-16BE, or UTF-16LE string|
|BLOB|Binary data, stored exactly as input|

### Type Affinity

Column type declarations are advisory. SQLite maps declared types to one of five affinities: `TEXT`, `NUMERIC`, `INTEGER`, `REAL`, `BLOB`. This means you can insert a string into an `INTEGER` column without an error — though this is generally a bad practice.

### Strict Tables (SQLite 3.37+)

If you want enforced types, use `STRICT`:

```sql
CREATE TABLE measurements (
    id    INTEGER PRIMARY KEY,
    value REAL NOT NULL
) STRICT;
```

In a `STRICT` table, only the declared type is accepted.

---

