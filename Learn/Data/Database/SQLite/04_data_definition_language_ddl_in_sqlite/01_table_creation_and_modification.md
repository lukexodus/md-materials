## Table Creation and Modification


### Creating Tables

The `CREATE TABLE` statement defines a new table with specified columns and their properties.

**Basic syntax:**

```sql
CREATE TABLE table_name (
    column1 datatype constraints,
    column2 datatype constraints,
    ...
    table_constraints
);
```

**Example:**

```sql
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    hire_date TEXT,
    salary REAL
);
```

### IF NOT EXISTS Clause

Prevents errors when creating tables that might already exist:

```sql
CREATE TABLE IF NOT EXISTS departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL
);
```

### Temporary Tables

Tables that exist only for the duration of the database connection:

```sql
CREATE TEMP TABLE session_data (
    session_id TEXT,
    user_id INTEGER,
    login_time TEXT
);
```

### Modifying Tables with ALTER TABLE

SQLite supports limited `ALTER TABLE` operations compared to other database systems.

**Adding columns:**

```sql
ALTER TABLE employees ADD COLUMN department_id INTEGER;
```

**Renaming tables:**

```sql
ALTER TABLE employees RENAME TO staff;
```

**Renaming columns** (SQLite 3.25.0+):

```sql
ALTER TABLE employees RENAME COLUMN email TO email_address;
```

**Dropping columns** (SQLite 3.35.0+):

```sql
ALTER TABLE employees DROP COLUMN middle_name;
```

[Inference] For SQLite versions before 3.35.0, dropping columns requires recreating the table without the unwanted column, copying data, dropping the old table, and renaming the new table.

