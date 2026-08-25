## Useful Built-In Functions


### String Functions

```sql
LENGTH(str)
UPPER(str) / LOWER(str)
SUBSTR(str, start, length)
TRIM(str) / LTRIM(str) / RTRIM(str)
REPLACE(str, old, new)
INSTR(str, substr)
PRINTF(format, ...)   -- or FORMAT() in 3.38+
```

### Numeric Functions

```sql
ABS(x)
ROUND(x, digits)
MAX(x, y) / MIN(x, y)   -- scalar versions, not aggregate
RANDOM()                  -- random integer in [-9223372036854775808, 9223372036854775807]
```

### Date and Time Functions

```sql
date('now')                      -- '2026-06-01'
time('now')                      -- current UTC time
datetime('now')                  -- '2026-06-01 HH:MM:SS'
datetime('now', 'localtime')     -- adjusted to local time
strftime('%Y-%m', 'now')         -- custom format
julianday('now')                 -- Julian day number
```

Modifiers can be chained:

```sql
datetime('now', '+7 days', 'start of month')
```

### Aggregate Functions

```sql
COUNT(*) / COUNT(col)
SUM(col)
AVG(col)
MAX(col) / MIN(col)
GROUP_CONCAT(col, separator)
```

---

