## Using PL/pgSQL for Procedural Logic


### Introduction to PL/pgSQL

PL/pgSQL (Procedural Language/PostgreSQL) is PostgreSQL's native procedural programming language that extends standard SQL with control structures, complex calculations, and custom business logic. It combines the ease of SQL for data manipulation with the power of procedural programming, enabling developers to create stored functions, triggers, and complex database operations.

### PL/pgSQL Structure and Syntax

PL/pgSQL blocks follow a consistent structure with declarations and executable sections:

```sql
DO $$
DECLARE
    -- Variable declarations
    counter INTEGER := 0;
    user_name VARCHAR(50);
BEGIN
    -- Executable code
    counter := counter + 1;
    user_name := 'John Doe';
    
    -- Output (when used in DO blocks)
    RAISE NOTICE 'Counter: %, User: %', counter, user_name;
END $$;
```

**Key Points**

- Code blocks start with `DECLARE` (optional), `BEGIN`, and end with `END`
- Statements end with semicolons (`;`)
- Variables must be declared before use
- Assignment uses `:=` operator
- Dollar-quoted string literals (`$$`) can contain single quotes without escaping

### Declaring and Using Variables

PL/pgSQL supports various data types for variable declarations:

```sql
DO $$
DECLARE
    -- Simple variable declarations
    user_id INTEGER := 100;
    user_name VARCHAR(50) := 'Alice';
    is_active BOOLEAN DEFAULT TRUE;
    
    -- Using column type as reference
    user_record users%ROWTYPE;
    email_type users.email%TYPE;
    
    -- Record variables
    customer RECORD;
    
    -- Array variables
    ids INTEGER[] := ARRAY[1, 2, 3];
BEGIN
    -- Code using these variables
    RAISE NOTICE 'User: % (ID: %)', user_name, user_id;
END $$;
```

### Control Structures

#### Conditional Logic

PL/pgSQL supports standard conditional structures:

```sql
DO $$
DECLARE
    grade CHAR(1) := 'B';
    result TEXT;
BEGIN
    -- IF-THEN-ELSIF-ELSE structure
    IF grade = 'A' THEN
        result := 'Excellent';
    ELSIF grade = 'B' THEN
        result := 'Good';
    ELSIF grade = 'C' THEN
        result := 'Fair';
    ELSE
        result := 'Poor';
    END IF;
    
    RAISE NOTICE 'Result: %', result;
    
    -- CASE statement
    CASE grade
        WHEN 'A' THEN
            result := 'Excellent';
        WHEN 'B' THEN
            result := 'Good';
        WHEN 'C' THEN
            result := 'Fair';
        ELSE
            result := 'Poor';
    END CASE;
    
    RAISE NOTICE 'Result from CASE: %', result;
END $$;
```

#### Looping Constructs

PL/pgSQL provides several loop types for iteration:

```sql
DO $$
DECLARE
    i INTEGER := 0;
    fruits TEXT[] := ARRAY['Apple', 'Banana', 'Cherry'];
    fruit TEXT;
BEGIN
    -- Simple loop with EXIT
    LOOP
        i := i + 1;
        EXIT WHEN i > 3;
        RAISE NOTICE 'Simple loop iteration: %', i;
    END LOOP;
    
    -- FOR loop with range
    FOR i IN 1..3 LOOP
        RAISE NOTICE 'For loop iteration: %', i;
    END LOOP;
    
    -- FOR loop with REVERSE
    FOR i IN REVERSE 3..1 LOOP
        RAISE NOTICE 'Reverse for loop: %', i;
    END LOOP;
    
    -- FOREACH loop for arrays
    FOREACH fruit IN ARRAY fruits LOOP
        RAISE NOTICE 'Fruit: %', fruit;
    END LOOP;
    
    -- WHILE loop
    i := 0;
    WHILE i < 3 LOOP
        i := i + 1;
        RAISE NOTICE 'While loop: %', i;
    END LOOP;
END $$;
```

### Creating Functions

Functions are the most common PL/pgSQL objects, encapsulating reusable logic:

```sql
-- Basic function with parameters and return value
CREATE OR REPLACE FUNCTION calculate_bonus(
    employee_salary NUMERIC,
    performance_rating INTEGER
) RETURNS NUMERIC AS $$
DECLARE
    bonus_percentage NUMERIC;
BEGIN
    -- Determine bonus percentage based on rating
    CASE performance_rating
        WHEN 5 THEN bonus_percentage := 0.20;  -- 20% bonus
        WHEN 4 THEN bonus_percentage := 0.15;  -- 15% bonus
        WHEN 3 THEN bonus_percentage := 0.10;  -- 10% bonus
        WHEN 2 THEN bonus_percentage := 0.05;  -- 5% bonus
        ELSE bonus_percentage := 0.00;         -- No bonus
    END CASE;
    
    -- Calculate and return the bonus amount
    RETURN employee_salary * bonus_percentage;
END;
$$ LANGUAGE plpgsql;

-- Using the function
SELECT calculate_bonus(50000, 4);  -- Returns 7500
```

#### Function with OUT Parameters

```sql
CREATE OR REPLACE FUNCTION get_employee_details(
    IN emp_id INTEGER,
    OUT full_name TEXT,
    OUT department TEXT,
    OUT salary NUMERIC
) AS $$
BEGIN
    SELECT 
        first_name || ' ' || last_name,
        dept_name,
        monthly_salary
    INTO full_name, department, salary
    FROM employees
    JOIN departments ON employees.dept_id = departments.id
    WHERE employees.id = emp_id;
END;
$$ LANGUAGE plpgsql;

-- Call function and receive multiple outputs
SELECT * FROM get_employee_details(101);
```

### Handling Data with Cursors

Cursors allow row-by-row processing of query results:

```sql
CREATE OR REPLACE FUNCTION process_high_value_orders() RETURNS VOID AS $$
DECLARE
    order_cursor CURSOR FOR 
        SELECT id, customer_id, total_amount
        FROM orders
        WHERE total_amount > 1000
        ORDER BY total_amount DESC;
    
    order_rec RECORD;
    processed_count INTEGER := 0;
BEGIN
    -- Open the cursor
    OPEN order_cursor;
    
    -- Fetch rows one by one
    LOOP
        FETCH order_cursor INTO order_rec;
        EXIT WHEN NOT FOUND;
        
        -- Process each row
        processed_count := processed_count + 1;
        RAISE NOTICE 'Processing order #% for customer #% with amount $%',
            order_rec.id, order_rec.customer_id, order_rec.total_amount;
            
        -- Additional processing logic here
    END LOOP;
    
    -- Close the cursor
    CLOSE order_cursor;
    
    RAISE NOTICE 'Processed % high-value orders', processed_count;
END;
$$ LANGUAGE plpgsql;
```

### Exception Handling

PL/pgSQL provides robust exception handling capabilities:

```sql
CREATE OR REPLACE FUNCTION transfer_funds(
    sender_id INTEGER,
    recipient_id INTEGER,
    amount NUMERIC
) RETURNS BOOLEAN AS $$
DECLARE
    sender_balance NUMERIC;
BEGIN
    -- Start transaction explicitly
    BEGIN
        -- Check sender balance
        SELECT balance INTO sender_balance
        FROM accounts
        WHERE id = sender_id
        FOR UPDATE;  -- Lock the row
        
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Sender account % not found', sender_id;
        END IF;
        
        IF sender_balance < amount THEN
            RAISE EXCEPTION 'Insufficient balance (available: $%)', sender_balance;
        END IF;
        
        -- Update sender account
        UPDATE accounts
        SET balance = balance - amount
        WHERE id = sender_id;
        
        -- Update recipient account
        UPDATE accounts
        SET balance = balance + amount
        WHERE id = recipient_id;
        
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Recipient account % not found', recipient_id;
        END IF;
        
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error
            RAISE NOTICE 'Transfer failed: %', SQLERRM;
            RETURN FALSE;
    END;
END;
$$ LANGUAGE plpgsql;
```

**Key Points**

- Use `EXCEPTION` block to catch and handle errors
- `RAISE EXCEPTION` throws custom exceptions
- Built-in exception categories include `NO_DATA_FOUND`, `TOO_MANY_ROWS`, `UNIQUE_VIOLATION`
- `SQLERRM` provides the error message text
- `SQLSTATE` provides the error code

### Creating Triggers

Triggers execute PL/pgSQL functions in response to database events:

```sql
-- Create a trigger function
CREATE OR REPLACE FUNCTION audit_employee_changes() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO employee_audit(employee_id, action, changed_on)
        VALUES(NEW.id, 'INSERT', now());
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO employee_audit(employee_id, action, changed_on)
        VALUES(NEW.id, 'UPDATE', now());
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO employee_audit(employee_id, action, changed_on)
        VALUES(OLD.id, 'DELETE', now());
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Attach the trigger to a table
CREATE TRIGGER employee_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW EXECUTE FUNCTION audit_employee_changes();
```

#### Row-Level vs. Statement-Level Triggers

```sql
-- Row-level trigger (default, fires once per affected row)
CREATE TRIGGER employee_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW EXECUTE FUNCTION audit_employee_changes();

-- Statement-level trigger (fires once per SQL statement)
CREATE TRIGGER employee_audit_summary_trigger
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH STATEMENT EXECUTE FUNCTION audit_employee_changes_summary();
```

### Advanced PL/pgSQL Techniques

#### Dynamic SQL Execution

```sql
CREATE OR REPLACE FUNCTION exec_dynamic_query(
    table_name TEXT,
    column_name TEXT,
    filter_value TEXT
) RETURNS SETOF RECORD AS $$
DECLARE
    query_text TEXT;
    result RECORD;
BEGIN
    -- Build dynamic query
    query_text := 'SELECT * FROM ' || quote_ident(table_name) || 
                  ' WHERE ' || quote_ident(column_name) || ' = $1';
    
    -- Log the generated query (for debugging)
    RAISE NOTICE 'Executing: %', query_text;
    
    -- Execute and return results
    FOR result IN EXECUTE query_text USING filter_value LOOP
        RETURN NEXT result;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Usage requires column definition
SELECT * FROM exec_dynamic_query('employees', 'department', 'Sales') 
AS t(id INT, name TEXT, department TEXT, salary NUMERIC);
```

#### Working with JSON in PL/pgSQL

```sql
CREATE OR REPLACE FUNCTION process_json_data(data JSONB) RETURNS TABLE(
    name TEXT,
    processed_value NUMERIC
) AS $$
DECLARE
    item JSONB;
    item_name TEXT;
    item_value NUMERIC;
BEGIN
    -- Process each item in a JSON array
    FOR item IN SELECT * FROM jsonb_array_elements(data -> 'items') LOOP
        item_name := item ->> 'name';
        item_value := (item ->> 'value')::NUMERIC * 1.1;  -- Add 10%
        
        name := item_name;
        processed_value := item_value;
        RETURN NEXT;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT * FROM process_json_data('{"items": [
    {"name": "Product A", "value": 100},
    {"name": "Product B", "value": 200}
]}'::JSONB);
```

### Stored Procedures (PostgreSQL 11+)

Unlike functions, procedures can manage their own transactions:

```sql
CREATE OR REPLACE PROCEDURE batch_update_salaries(
    department_id INT,
    increase_percent NUMERIC
) AS $$
DECLARE
    affected_count INT;
BEGIN
    -- Start transaction
    UPDATE employees
    SET salary = salary * (1 + increase_percent / 100)
    WHERE dept_id = department_id;
    
    GET DIAGNOSTICS affected_count = ROW_COUNT;
    
    RAISE NOTICE 'Updated % employee salaries', affected_count;
    
    -- Transaction control is possible in procedures
    IF affected_count > 100 THEN
        RAISE NOTICE 'Too many employees affected, rolling back';
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Call the procedure
CALL batch_update_salaries(10, 5);  -- 5% increase for department 10
```

### Performance Considerations

**Key Points**

- PL/pgSQL functions are interpreted, not compiled
- Use `IMMUTABLE`, `STABLE`, or `VOLATILE` function attributes appropriately
- Minimize context switching between SQL and PL/pgSQL
- Use `RETURNS TABLE` for result sets instead of returning `SETOF RECORD`
- Consider query plan caching implications when using dynamic SQL
- For critical performance paths, consider implementing in C or using PostgreSQL extensions

### Security Best Practices

```sql
-- Define function with security constraints
CREATE OR REPLACE FUNCTION get_employee_salary(emp_id INTEGER) 
RETURNS NUMERIC
LANGUAGE plpgsql
SECURITY DEFINER  -- Function runs with privileges of creator
STABLE            -- Result depends only on input arguments
SET search_path = admin, public  -- Controlled search path
AS $$
DECLARE
    salary NUMERIC;
BEGIN
    SELECT e.salary INTO salary
    FROM admin.employees e
    WHERE e.id = emp_id;
    
    RETURN salary;
END;
$$;

-- Control execution privileges
REVOKE ALL ON FUNCTION get_employee_salary(INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_employee_salary(INTEGER) TO hr_staff;
```

**Key Points**

- Use `SECURITY DEFINER` carefully and only when necessary
- Always set a restricted `search_path` in `SECURITY DEFINER` functions
- Validate all input parameters to prevent SQL injection
- Use `quote_ident()` and `quote_literal()` for dynamic SQL
- Grant execution privileges only to appropriate roles

### Real-World Examples

#### Data Validation and Transformation

```sql
CREATE OR REPLACE FUNCTION validate_and_normalize_contact(
    IN p_first_name TEXT,
    IN p_last_name TEXT,
    IN p_email TEXT,
    IN p_phone TEXT,
    OUT normalized_first_name TEXT,
    OUT normalized_last_name TEXT,
    OUT normalized_email TEXT,
    OUT normalized_phone TEXT,
    OUT is_valid BOOLEAN
) AS $$
DECLARE
    email_pattern TEXT := '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$';
BEGIN
    -- Initialize validity
    is_valid := TRUE;
    
    -- Normalize and validate first name
    normalized_first_name := trim(initcap(p_first_name));
    IF normalized_first_name = '' THEN
        RAISE NOTICE 'First name cannot be empty';
        is_valid := FALSE;
    END IF;
    
    -- Normalize and validate last name
    normalized_last_name := trim(initcap(p_last_name));
    IF normalized_last_name = '' THEN
        RAISE NOTICE 'Last name cannot be empty';
        is_valid := FALSE;
    END IF;
    
    -- Normalize and validate email
    normalized_email := lower(trim(p_email));
    IF normalized_email = '' OR normalized_email !~ email_pattern THEN
        RAISE NOTICE 'Invalid email format';
        is_valid := FALSE;
    END IF;
    
    -- Normalize and validate phone (simplified)
    normalized_phone := regexp_replace(p_phone, '[^0-9]', '', 'g');
    IF length(normalized_phone) < 10 THEN
        RAISE NOTICE 'Phone number too short';
        is_valid := FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT * FROM validate_and_normalize_contact(
    ' john ', 'SMITH', 'John.Smith@Example.COM', '(555) 123-4567'
);
```

#### Batch Processing

```sql
CREATE OR REPLACE PROCEDURE process_pending_orders(batch_size INT DEFAULT 100) AS $$
DECLARE
    orders_cursor CURSOR FOR 
        SELECT id, customer_id, order_date, status
        FROM orders
        WHERE status = 'pending'
        ORDER BY order_date
        LIMIT batch_size
        FOR UPDATE;
    
    order_rec RECORD;
    processed INT := 0;
    failed INT := 0;
BEGIN
    OPEN orders_cursor;
    
    LOOP
        FETCH orders_cursor INTO order_rec;
        EXIT WHEN NOT FOUND;
        
        BEGIN
            -- Process the order
            UPDATE order_items
            SET status = 'processing'
            WHERE order_id = order_rec.id;
            
            UPDATE orders
            SET 
                status = 'processing',
                processed_at = now(),
                processed_by = current_user
            WHERE id = order_rec.id;
            
            -- Record success
            INSERT INTO order_processing_log(order_id, status, message)
            VALUES (order_rec.id, 'success', 'Order moved to processing');
            
            processed := processed + 1;
        EXCEPTION
            WHEN OTHERS THEN
                -- Log failure but continue with next order
                RAISE WARNING 'Failed to process order %: %', order_rec.id, SQLERRM;
                
                INSERT INTO order_processing_log(order_id, status, message)
                VALUES (order_rec.id, 'error', SQLERRM);
                
                failed := failed + 1;
                
                -- Continue with the next order (don't roll back everything)
                CONTINUE;
        END;
    END LOOP;
    
    CLOSE orders_cursor;
    
    RAISE NOTICE 'Batch processing complete: % processed, % failed', processed, failed;
END;
$$ LANGUAGE plpgsql;

-- Execute the procedure
CALL process_pending_orders(50);
```

**Conclusion**

PL/pgSQL provides a powerful framework for implementing complex business logic directly within the PostgreSQL database. By combining SQL's declarative power with procedural capabilities, developers can create robust, efficient, and secure database applications. The language's integration with PostgreSQL's type system, transaction management, and security model makes it an excellent choice for building reliable database applications.

When used effectively, PL/pgSQL can:

- Reduce application complexity by centralizing business rules
- Improve performance by minimizing client-server data transfer
- Enhance security through controlled execution contexts
- Enable complex data validation and transformation
- Support automated database maintenance and operations

Related topics: PostgreSQL event triggers, writing PostgreSQL extensions, optimizing PL/pgSQL performance, and integrating with external languages like PL/Python and PL/Perl.

---

