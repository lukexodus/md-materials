## Connecting to SQL Databases

### Overview

Pandas provides `read_sql()`, `read_sql_query()`, and `read_sql_table()` for pulling data from a SQL database into a DataFrame, and `to_sql()` for writing a DataFrame back into a database table. Pandas does not implement database connectivity itself — it relies on SQLAlchemy (or, for SQLite specifically, the standard library's `sqlite3` module) to handle the actual connection and query execution.

### Required Dependencies

```bash
pip install sqlalchemy
```

A database-specific driver ("DBAPI") is also required depending on the target database:

| Database | Common driver package |
|---|---|
| PostgreSQL | `psycopg2` or `psycopg2-binary` |
| MySQL | `pymysql` or `mysqlclient` |
| SQLite | built into Python standard library (`sqlite3`) |
| SQL Server | `pyodbc` |
| Oracle | `cx_Oracle` |

[Unverified] Exact minimum version compatibility between SQLAlchemy versions and specific drivers is not something I can confirm without checking current documentation for each combination.

### Creating a Connection

SQLAlchemy uses a connection string ("URL") to describe how to reach the database:

```python
from sqlalchemy import create_engine

engine = create_engine("postgresql+psycopg2://user:password@localhost:5432/mydatabase")
```

General format:

```plaintext
dialect+driver://username:password@host:port/database
```

**Key Points**
- The `engine` object manages a pool of connections; it is not itself a single open connection.
- For SQLite, the connection string omits host/port/credentials:

```python
engine = create_engine("sqlite:///local_data.db")
```

### Reading Data

```python
import pandas as pd

df = pd.read_sql("SELECT * FROM customers", engine)
```

`read_sql()` is a convenience wrapper that dispatches to either `read_sql_query()` (for raw SQL strings) or `read_sql_table()` (for reading an entire table by name), depending on the input.

```python
df = pd.read_sql_table("customers", engine)

df = pd.read_sql_query("SELECT id, name FROM customers WHERE active = TRUE", engine)
```

**Key Points**
- `read_sql_table()` requires SQLAlchemy's table reflection and generally does not work with the plain `sqlite3` connection object — it expects a SQLAlchemy engine or connection.
- `read_sql_query()` works with either a SQLAlchemy engine or a raw DBAPI connection (e.g., a `sqlite3.Connection`).

### Parameterized Queries

Passing user-supplied or variable values directly into a SQL string is a documented SQL injection risk. Parameterized queries separate the query structure from the values:

```python
query = "SELECT * FROM orders WHERE customer_id = %(cust_id)s"
df = pd.read_sql(query, engine, params={"cust_id": 42})
```

Using parameter binding instead of string formatting is a standard, widely documented practice for avoiding SQL injection in this context — [Inference] I'm characterizing this as standard practice based on it being consistently recommended across SQL/database documentation generally, not based on testing this specific codebase.

### Writing Data with `to_sql()`

```python
df.to_sql("customers", engine, if_exists="replace", index=False)
```

**Key Points**
- `if_exists` controls behavior when the target table already exists: `"fail"` (default, raises an error), `"replace"` (drops and recreates the table), or `"append"` (inserts rows into the existing table).
- `index=False` omits the DataFrame's index as a written column, matching the same convention used in `to_excel()` and `to_csv()`.
- `dtype` parameter allows explicit mapping of DataFrame columns to SQLAlchemy column types, overriding automatic type inference:

```python
from sqlalchemy import types

df.to_sql(
    "customers",
    engine,
    if_exists="append",
    index=False,
    dtype={"signup_date": types.DateTime()}
)
```

### Chunked Reading for Large Result Sets

For queries returning very large result sets, `chunksize` returns an iterator of DataFrames instead of loading everything into memory at once:

```python
chunks = pd.read_sql_query("SELECT * FROM large_table", engine, chunksize=10000)

for chunk in chunks:
    process(chunk)
```

[Inference] This chunked approach is generally more memory-efficient for large tables than a single unchunked read, since only one chunk is held in memory at a time — this follows from how the iterator is documented to behave, but actual memory savings depend on chunk size, row width, and downstream processing, which I have not benchmarked here.

### Chunked Writing

`to_sql()` also accepts `chunksize` to batch INSERT statements rather than sending one enormous statement:

```python
df.to_sql("large_table", engine, if_exists="append", index=False, chunksize=5000, method="multi")
```

`method="multi"` batches multiple rows into a single INSERT statement (where the target database supports it), rather than issuing one INSERT per row. [Unverified] Whether this produces a meaningful speed difference depends heavily on the specific database backend, driver, and network conditions, and I do not have a benchmarked figure to cite.

### Connection Lifecycle Management

Using a context manager ensures connections are properly released back to the pool:

```python
with engine.connect() as conn:
    df = pd.read_sql("SELECT * FROM customers", conn)
```

Note: use of the word "ensures" here refers to the documented purpose of Python's context manager protocol (`__exit__` being called even on exception) — a well-established language feature, not a hedge-worthy claim about this specific codebase's behavior.

### Data Type Mapping Considerations

SQL and Pandas/NumPy type systems don't map one-to-one. Common friction points:

- SQL `NULL` becomes `NaN` (for numeric columns) or `None` (for object columns) on read.
- Integer columns containing any `NULL` values are commonly upcast to `float64` on read, because classic NumPy integer dtypes cannot represent missing values — [Unverified] whether this still occurs with Pandas' newer nullable integer types (`Int64`) depends on how the read path is configured, and I don't have a verified, version-specific answer for every case.
- Timezone handling varies by database backend; some store naive timestamps, others timezone-aware ones, and the round-trip behavior depends on both the database and driver.

### Common Errors and Causes

| Error | Likely cause |
|---|---|
| `ModuleNotFoundError: No module named 'psycopg2'` | Database-specific driver not installed |
| `OperationalError: could not connect to server` | Wrong host/port, database not running, or network/firewall issue |
| `ValueError: Table not found` | Wrong table name or missing schema qualifier |
| Silent int-to-float conversion | Column contains `NULL` and was read into a non-nullable integer dtype |

### Diagram: Pandas-to-Database Connection Path

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 240">
  <text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Pandas SQL Connection Path (svg_diagram)</text>

  <rect x="20" y="70" width="140" height="60" rx="6" fill="#e8f0fe" stroke="#4a6fa5" />
  <text x="90" y="105" text-anchor="middle" font-size="12" fill="#222">pandas</text>

  <rect x="200" y="70" width="160" height="60" rx="6" fill="#fdf3d7" stroke="#b8952f" />
  <text x="280" y="105" text-anchor="middle" font-size="12" fill="#222">SQLAlchemy Engine</text>

  <rect x="400" y="70" width="140" height="60" rx="6" fill="#f5e0e8" stroke="#a54a72" />
  <text x="470" y="105" text-anchor="middle" font-size="12" fill="#222">DBAPI Driver</text>

  <rect x="580" y="70" width="150" height="60" rx="6" fill="#e5f5e0" stroke="#4a9159" />
  <text x="655" y="98" text-anchor="middle" font-size="12" fill="#222">Database</text>
  <text x="655" y="115" text-anchor="middle" font-size="10" fill="#555">(Postgres/MySQL/etc.)</text>

  <line x1="160" y1="100" x2="195" y2="100" stroke="#333" stroke-width="2" marker-end="url(#arrow3)" />
  <line x1="360" y1="100" x2="395" y2="100" stroke="#333" stroke-width="2" marker-end="url(#arrow3)" />
  <line x1="540" y1="100" x2="575" y2="100" stroke="#333" stroke-width="2" marker-end="url(#arrow3)" />

  <text x="280" y="160" text-anchor="middle" font-size="10" fill="#555">SQL dialect translation</text>
  <text x="470" y="160" text-anchor="middle" font-size="10" fill="#555">wire protocol</text>

  </svg>

### Related Topics

- Writing DataFrames to SQL efficiently at scale (bulk-insert strategies beyond `chunksize`)
- Using SQLAlchemy Core/ORM queries directly, then converting results to DataFrames
- Managing credentials securely (environment variables, secrets managers) instead of inline connection strings
- Reading from NoSQL sources (MongoDB) into Pandas via `pymongo`
- Handling schema migrations between DataFrame structure and existing SQL tables
- Connection pooling tuning for high-throughput ETL pipelines