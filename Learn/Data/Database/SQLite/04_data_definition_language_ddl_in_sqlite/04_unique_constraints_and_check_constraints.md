## Unique Constraints and Check Constraints


### Unique Constraints

Ensures all values in a column or combination of columns are distinct.

**Column-level unique:**

```sql
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    username TEXT UNIQUE,
    email TEXT UNIQUE
);
```

**Table-level unique (composite):**

```sql
CREATE TABLE enrollments (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date TEXT,
    UNIQUE(student_id, course_id)
);
```

**Named unique constraint:**

```sql
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    sku TEXT,
    CONSTRAINT unique_sku UNIQUE(sku)
);
```

### Check Constraints

Validates data based on a boolean expression.

**Column-level check:**

```sql
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    age INTEGER CHECK(age >= 18 AND age <= 100),
    salary REAL CHECK(salary > 0)
);
```

**Table-level check:**

```sql
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    cost_price REAL,
    selling_price REAL,
    CHECK(selling_price >= cost_price)
);
```

**Named check constraint:**

```sql
CREATE TABLE accounts (
    account_id INTEGER PRIMARY KEY,
    balance REAL,
    CONSTRAINT positive_balance CHECK(balance >= 0)
);
```

**Complex check with multiple conditions:**

```sql
CREATE TABLE appointments (
    appointment_id INTEGER PRIMARY KEY,
    start_time TEXT,
    end_time TEXT,
    status TEXT,
    CHECK(status IN ('scheduled', 'completed', 'cancelled')),
    CHECK(end_time > start_time)
);
```

