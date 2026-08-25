## Creating Tables and Constraints


### Introduction to Database Tables and Constraints

Tables form the fundamental structure of relational databases, organizing data into rows and columns. Constraints are rules enforced on data columns to maintain accuracy and reliability. Together, they ensure data integrity, which is crucial for building robust database applications.

### Database Table Basics

Tables are structured collections of related data organized in rows (records) and columns (fields). Each column has a specific data type that determines what values can be stored. The basic syntax for creating a table is:

```sql
CREATE TABLE table_name (
    column1 datatype [constraints],
    column2 datatype [constraints],
    column3 datatype [constraints],
    ...
);
```

Data types vary by database management system but commonly include:

```sql
-- Common data types
CREATE TABLE example_datatypes (
    int_column INT,                      -- Integer values
    varchar_column VARCHAR(50),          -- Variable-length string (max 50 chars)
    char_column CHAR(10),                -- Fixed-length string (always 10 chars)
    decimal_column DECIMAL(10,2),        -- Numeric with precision and scale
    date_column DATE,                    -- Date only
    timestamp_column TIMESTAMP,          -- Date and time
    boolean_column BOOLEAN,              -- True/false values
    text_column TEXT                     -- Unlimited length text
);
```

### Primary Keys

Primary keys uniquely identify each record in a table. They enforce entity integrity and provide a way to reference specific rows.

**Key Points:**

- **Must be unique** - No duplicate values allowed
- **Cannot be null** - Every row must have a value
- **Should be immutable** - Rarely or never changes
- **Optimized for lookups** - Automatically indexed
- **Relationship foundation** - Referenced by foreign keys
- **Can be simple or composite** - One column or multiple columns

#### Simple Primary Key

```sql
-- Using column constraint syntax
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2)
);

-- Using table constraint syntax
CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2),
    PRIMARY KEY (product_id)
);
```

#### Composite Primary Key

```sql
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);
```

#### Auto-incrementing Primary Keys

```sql
-- MySQL/MariaDB syntax
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- PostgreSQL syntax
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- SQL Server syntax
CREATE TABLE customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Oracle syntax
CREATE TABLE customers (
    customer_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE
);
```

#### UUID Primary Keys

```sql
-- PostgreSQL UUID example
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE documents (
    document_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Foreign Keys

Foreign keys establish and enforce relationships between tables. They ensure referential integrity by preventing orphaned records.

**Key Points:**

- **Relationship enforcement** - Ensures valid connections between tables
- **Prevents orphaned records** - Child records can't exist without parent records
- **Cascading actions** - Can automatically handle related records during deletions/updates
- **Performance consideration** - May impact write operations
- **Must reference unique values** - Typically references a primary key or unique constraint
- **Can be nullable** - Unless explicitly set as NOT NULL

#### Basic Foreign Key

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

#### Named Foreign Key with Options

```sql
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT fk_order 
        FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT
);
```

#### ON DELETE and ON UPDATE Actions

```sql
-- Available actions:
-- CASCADE - Automatically delete/update related records
-- RESTRICT - Prevent delete/update if related records exist
-- SET NULL - Set the foreign key to NULL
-- SET DEFAULT - Set the foreign key to its default value
-- NO ACTION - Similar to RESTRICT but checked at end of transaction

CREATE TABLE comments (
    comment_id INT PRIMARY KEY,
    post_id INT,
    user_id INT,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) 
        REFERENCES posts(post_id) 
        ON DELETE CASCADE,
    FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE SET NULL
);
```

#### Composite Foreign Keys

```sql
CREATE TABLE inventory_movements (
    movement_id INT PRIMARY KEY,
    warehouse_id INT,
    product_id INT,
    quantity INT NOT NULL,
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (warehouse_id, product_id) 
        REFERENCES warehouse_inventory(warehouse_id, product_id)
);
```

#### Self-Referencing Foreign Keys

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);
```

### Unique Constraints

Unique constraints ensure that values in specified columns are unique across the table, allowing NULL values unless NOT NULL is also specified.

**Key Points:**

- **Enforce uniqueness** - No duplicate values allowed in constrained columns
- **Allow NULL values** - Unlike primary keys (unless combined with NOT NULL)
- **Can span multiple columns** - Create composite unique constraints
- **Automatically indexed** - For performance
- **Used for alternate keys** - Data that's unique but not used as primary key
- **Business rule enforcement** - Ensuring business-specific uniqueness rules

#### Single Column Unique Constraint

```sql
-- Column constraint syntax
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(100) NOT NULL
);

-- Table constraint syntax
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_code VARCHAR(20),
    product_name VARCHAR(100) NOT NULL,
    UNIQUE (product_code)
);
```

#### Named Unique Constraint

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    tax_id VARCHAR(20),
    email VARCHAR(100) NOT NULL,
    CONSTRAINT uc_tax_id UNIQUE (tax_id)
);
```

#### Composite Unique Constraint

```sql
CREATE TABLE employee_projects (
    employee_id INT,
    project_id INT,
    role VARCHAR(50) NOT NULL,
    join_date DATE NOT NULL,
    PRIMARY KEY (employee_id, project_id),
    CONSTRAINT uc_employee_role UNIQUE (employee_id, role)
);
```

#### Conditional Unique Constraint (PostgreSQL)

```sql
-- PostgreSQL partial unique index (similar effect to conditional unique constraint)
CREATE TABLE reservations (
    reservation_id SERIAL PRIMARY KEY,
    room_id INT NOT NULL,
    customer_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL
);

-- Ensure each room has only one active reservation per date
CREATE UNIQUE INDEX ux_active_room_reservation 
ON reservations (room_id, reservation_date) 
WHERE status = 'active';
```

### Check Constraints

Check constraints enforce domain integrity by limiting the values that can be placed in a column based on a logical condition.

**Key Points:**

- **Data validation** - Ensures data meets specified conditions
- **Business rule enforcement** - Implements business logic at the database level
- **Works with expressions** - Can use various operators and functions
- **Prevents bad data** - Stops invalid data before it enters the database
- **Self-documenting** - Makes data rules explicit in schema
- **Database-independent** - Basic checks work across most database systems

#### Basic Check Constraint

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) CHECK (price > 0),
    stock_quantity INT CHECK (stock_quantity >= 0)
);
```

#### Named Check Constraint

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_salary_positive CHECK (salary > 0),
    CONSTRAINT chk_hire_date CHECK (hire_date <= CURRENT_DATE)
);
```

#### Complex Check Constraint

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE,
    status VARCHAR(20) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_date_validation CHECK (
        (ship_date IS NULL) OR (ship_date >= order_date)
    ),
    CONSTRAINT chk_status CHECK (
        status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')
    ),
    CONSTRAINT chk_amount CHECK (
        (status = 'Cancelled' AND total_amount = 0) OR
        (status != 'Cancelled' AND total_amount > 0)
    )
);
```

#### Multi-Column Check Constraint

```sql
CREATE TABLE rectangle_dimensions (
    rectangle_id INT PRIMARY KEY,
    width DECIMAL(10,2) NOT NULL,
    height DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_area CHECK (width * height <= 1000),
    CONSTRAINT chk_dimensions CHECK (width > 0 AND height > 0)
);
```

### NOT NULL Constraint

While not always categorized separately, the NOT NULL constraint is fundamental for data integrity.

```sql
CREATE TABLE contacts (
    contact_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    CONSTRAINT chk_contact_info CHECK (
        email IS NOT NULL OR phone IS NOT NULL
    )
);
```

### DEFAULT Constraint

DEFAULT constraints specify a default value for a column when no value is explicitly provided.

```sql
CREATE TABLE articles (
    article_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    is_published BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Complex Table Creation Example

**Example:**

Creating a comprehensive order management schema with various constraints:

```sql
-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    registration_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'Active' NOT NULL,
    CONSTRAINT uc_customer_email UNIQUE (email),
    CONSTRAINT chk_status CHECK (status IN ('Active', 'Inactive', 'Suspended')),
    CONSTRAINT chk_contact CHECK (email IS NOT NULL OR phone IS NOT NULL)
);

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_code VARCHAR(20) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 5,
    discontinued BOOLEAN DEFAULT FALSE,
    CONSTRAINT uc_product_code UNIQUE (product_code),
    CONSTRAINT chk_price CHECK (price > 0),
    CONSTRAINT chk_cost CHECK (cost > 0),
    CONSTRAINT chk_margin CHECK (price >= cost),
    CONSTRAINT chk_quantity CHECK (stock_quantity >= 0),
    CONSTRAINT chk_reorder CHECK (reorder_level >= 0)
);

-- Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    required_date DATE,
    shipped_date DATE,
    status VARCHAR(20) DEFAULT 'Pending' NOT NULL,
    shipping_fee DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    payment_type VARCHAR(20),
    paid_date DATE,
    notes TEXT,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) 
        ON DELETE RESTRICT,
    CONSTRAINT chk_dates CHECK (
        (shipped_date IS NULL OR shipped_date >= order_date) AND
        (required_date IS NULL OR required_date >= order_date) AND
        (paid_date IS NULL OR paid_date >= order_date)
    ),
    CONSTRAINT chk_order_status CHECK (
        status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')
    ),
    CONSTRAINT chk_payment CHECK (
        (payment_type IS NULL AND paid_date IS NULL) OR
        (payment_type IS NOT NULL AND status != 'Cancelled')
    )
);

-- Order Details table
CREATE TABLE order_details (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    discount DECIMAL(4,2) DEFAULT 0.00 NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_order FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_product FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT,
    CONSTRAINT chk_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_discount CHECK (discount >= 0 AND discount <= 0.50)
);

-- Order Status History table
CREATE TABLE order_status_history (
    history_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    status_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    comments TEXT,
    updated_by VARCHAR(50) NOT NULL,
    CONSTRAINT fk_order_history FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) 
        ON DELETE CASCADE,
    CONSTRAINT chk_status_history CHECK (
        status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')
    )
);
```

**Output:** When we query information about these tables, we see the constraints defined:

```
Table: customers
Columns:
  customer_id (INT, PK)
  first_name (VARCHAR(50), NOT NULL)
  last_name (VARCHAR(50), NOT NULL)
  email (VARCHAR(100), NOT NULL, UNIQUE)
  phone (VARCHAR(20))
  registration_date (DATE, DEFAULT CURRENT_DATE)
  status (VARCHAR(20), NOT NULL, DEFAULT 'Active')
Constraints:
  PRIMARY KEY (customer_id)
  UNIQUE (email)
  CHECK (status IN ('Active', 'Inactive', 'Suspended'))
  CHECK (email IS NOT NULL OR phone IS NOT NULL)

Table: products
[...details omitted for brevity...]

Table: orders
[...details omitted for brevity...]

Table: order_details
Columns:
  order_id (INT, NOT NULL, PK)
  product_id (INT, NOT NULL, PK)
  unit_price (DECIMAL(10,2), NOT NULL)
  quantity (INT, NOT NULL)
  discount (DECIMAL(4,2), NOT NULL, DEFAULT 0.00)
Constraints:
  PRIMARY KEY (order_id, product_id)
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
  CHECK (unit_price >= 0)
  CHECK (quantity > 0)
  CHECK (discount >= 0 AND discount <= 0.50)

[...remaining details omitted for brevity...]
```

### Altering Tables and Constraints

After creating tables, you can modify their structure or constraints using ALTER statements.

#### Adding Constraints to Existing Tables

```sql
-- Add a primary key
ALTER TABLE products 
ADD PRIMARY KEY (product_id);

-- Add a foreign key
ALTER TABLE orders
ADD CONSTRAINT fk_customer_order
FOREIGN KEY (customer_id) 
REFERENCES customers(customer_id);

-- Add a unique constraint
ALTER TABLE employees
ADD CONSTRAINT uc_email
UNIQUE (email);

-- Add a check constraint
ALTER TABLE products
ADD CONSTRAINT chk_price
CHECK (price > 0);
```

#### Modifying and Dropping Constraints

```sql
-- Drop a constraint
ALTER TABLE orders
DROP CONSTRAINT fk_customer_order;

-- Enable/disable constraint (Oracle, SQL Server syntax)
ALTER TABLE orders
DISABLE CONSTRAINT fk_customer_order;

ALTER TABLE orders
ENABLE CONSTRAINT fk_customer_order;
```

### Database-Specific Variations

Different database systems have variations in constraint syntax and capabilities:

#### PostgreSQL Specific

```sql
-- Deferrable constraints
CREATE TABLE transfers (
    transfer_id INT PRIMARY KEY,
    from_account INT NOT NULL,
    to_account INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_from_account 
        FOREIGN KEY (from_account) 
        REFERENCES accounts(account_id) 
        DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT fk_to_account 
        FOREIGN KEY (to_account) 
        REFERENCES accounts(account_id) 
        DEFERRABLE INITIALLY DEFERRED
);

-- Exclusion constraints
CREATE TABLE room_bookings (
    booking_id INT PRIMARY KEY,
    room_id INT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    CHECK (start_time < end_time),
    EXCLUDE USING gist (room_id WITH =, 
                       tsrange(start_time, end_time) WITH &&)
);
```

#### SQL Server Specific

```sql
-- With NOCHECK option
ALTER TABLE orders
WITH NOCHECK
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id) 
REFERENCES customers(customer_id);

-- Sparse columns
CREATE TABLE customer_details (
    customer_id INT PRIMARY KEY,
    standard_info VARCHAR(100) NOT NULL,
    corporate_id VARCHAR(20) SPARSE NULL,
    government_id VARCHAR(20) SPARSE NULL
);
```

#### Oracle Specific

```sql
-- Virtual columns with constraints
CREATE TABLE products (
    product_id NUMBER PRIMARY KEY,
    cost NUMBER(10,2) NOT NULL,
    markup_percent NUMBER(5,2) NOT NULL,
    price NUMBER GENERATED ALWAYS AS (cost * (1 + markup_percent/100)) VIRTUAL,
    CONSTRAINT chk_markup CHECK (markup_percent BETWEEN 0 AND 500)
);
```

### Best Practices for Table and Constraint Design

**Key Points:**

- **Be descriptive with naming** - Use clear, consistent naming conventions
- **Plan for growth** - Choose appropriate data types and constraints
- **Consider performance** - Balance constraint checking with performance needs
- **Document constraints** - Add comments to explain business rules
- **Use schemas** - Organize related tables into schemas
- **Test constraints** - Verify they enforce intended rules
- **Consider cascading effects** - Be careful with cascading actions in foreign keys
- **Validate data before migration** - Ensure existing data meets new constraints

**Conclusion**

**Conclusion:** Tables and constraints form the foundational structure of any relational database system. Well-designed tables with appropriate constraints ensure data integrity, enforce business rules, and prevent data anomalies. Primary keys provide unique identification for records, foreign keys maintain relationships between tables, unique constraints prevent duplicate values, and check constraints enforce domain validity. Together, these elements create a robust database structure that maintains data consistency and reliability across applications. By carefully considering the various constraint types and their implications during database design, developers can build systems that not only store data effectively but also enforce business rules at the database level.

### Related Topics

- Database indexing strategies
- Database normalization principles
- Performance optimization for constrained tables
- Inheritance and partitioning in tables
- Temporal database design
- Schema evolution and migration strategies

---

