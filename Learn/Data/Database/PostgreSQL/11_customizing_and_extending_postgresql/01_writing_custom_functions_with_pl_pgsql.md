## Writing Custom Functions with PL/pgSQL


### Introduction to PL/pgSQL

PL/pgSQL (Procedural Language/PostgreSQL) is PostgreSQL's built-in procedural programming language that extends standard SQL with control structures, complex calculations, and custom business logic. PL/pgSQL combines the power of SQL with programming constructs like variables, conditionals, and loops, enabling developers to build sophisticated database functions, triggers, and stored procedures.

### Why Use PL/pgSQL Functions

PL/pgSQL offers several advantages over standard SQL and client-side application code:

- **Performance**: Executes close to the data, minimizing network overhead
- **Encapsulation**: Centralizes business logic at the database layer
- **Reusability**: Creates reusable code across applications and queries
- **Security**: Enables fine-grained access control through function execution privileges
- **Transactional Integrity**: Ensures atomic operations within database transactions
- **Reduced Network Traffic**: Processes multiple operations server-side with a single call

### PL/pgSQL Function Structure

A basic PL/pgSQL function follows this structure:

```sql
CREATE [OR REPLACE] FUNCTION function_name(parameter_list)
RETURNS return_type
[LANGUAGE plpgsql]
[SECURITY DEFINER | SECURITY INVOKER]
[COST execution_cost]
[ROWS result_rows]
AS $$
DECLARE
    -- Variable declarations
BEGIN
    -- Function body
    RETURN expression; -- For functions returning values
END;
$$ LANGUAGE plpgsql;
```

### Key Components of a PL/pgSQL Function

#### Function Parameters

Parameters define inputs to your function and can be specified in several ways:

```sql
-- Basic parameters
CREATE FUNCTION add_numbers(a integer, b integer) 
RETURNS integer AS $$
BEGIN
    RETURN a + b;
END;
$$ LANGUAGE plpgsql;

-- Named parameters with default values
CREATE FUNCTION user_details(
    p_user_id integer,
    p_include_inactive boolean DEFAULT false
) RETURNS TABLE (id integer, name text, status text) AS $$
BEGIN
    RETURN QUERY 
    SELECT u.id, u.name, u.status 
    FROM users u 
    WHERE u.id = p_user_id 
    AND (p_include_inactive OR u.status = 'active');
END;
$$ LANGUAGE plpgsql;
```

#### Variable Declaration

The DECLARE section defines local variables:

```sql
CREATE FUNCTION calculate_bonus(employee_id integer) 
RETURNS numeric AS $$
DECLARE
    base_salary numeric(10,2);
    years_of_service integer;
    performance_rating numeric(3,2);
    bonus_amount numeric(10,2);
BEGIN
    -- Function body using these variables
    -- ...
END;
$$ LANGUAGE plpgsql;
```

Common variable types include:
- Base types: `integer`, `numeric`, `text`, `boolean`, `date`, `timestamp`
- Arrays: `integer[]`, `text[]`
- Composite types: `record`, table row types
- System types: `oid`, `regclass`

#### Return Values

Functions can return single values, records, or sets of records:

```sql
-- Single value return
CREATE FUNCTION get_total_sales(month_id integer) 
RETURNS numeric AS $$
DECLARE
    total_amount numeric;
BEGIN
    SELECT SUM(amount) INTO total_amount
    FROM sales
    WHERE EXTRACT(MONTH FROM sale_date) = month_id;
    
    RETURN COALESCE(total_amount, 0);
END;
$$ LANGUAGE plpgsql;

-- Returning a record
CREATE FUNCTION get_employee(emp_id integer) 
RETURNS employees AS $$
DECLARE
    emp_record employees%ROWTYPE;
BEGIN
    SELECT * INTO emp_record
    FROM employees
    WHERE id = emp_id;
    
    RETURN emp_record;
END;
$$ LANGUAGE plpgsql;

-- Returning a table (set of records)
CREATE FUNCTION get_departments_by_location(loc_id integer) 
RETURNS TABLE (dept_id integer, dept_name text, emp_count bigint) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id, d.name, COUNT(e.id)
    FROM departments d
    LEFT JOIN employees e ON d.id = e.department_id
    WHERE d.location_id = loc_id
    GROUP BY d.id, d.name;
END;
$$ LANGUAGE plpgsql;
```

### Control Structures

#### Conditional Execution

IF-THEN-ELSE statements allow conditional logic execution:

```sql
CREATE FUNCTION classify_product(prod_id integer) 
RETURNS text AS $$
DECLARE
    product_price numeric;
BEGIN
    SELECT price INTO product_price
    FROM products
    WHERE id = prod_id;
    
    IF product_price IS NULL THEN
        RETURN 'Product not found';
    ELSIF product_price < 10 THEN
        RETURN 'Budget';
    ELSIF product_price < 50 THEN
        RETURN 'Regular';
    ELSIF product_price < 100 THEN
        RETURN 'Premium';
    ELSE
        RETURN 'Luxury';
    END IF;
END;
$$ LANGUAGE plpgsql;
```

CASE statements provide another way to handle multiple conditions:

```sql
CREATE FUNCTION get_shipping_cost(country text, weight numeric) 
RETURNS numeric AS $$
BEGIN
    RETURN CASE 
        WHEN country = 'USA' THEN
            CASE 
                WHEN weight <= 1 THEN 5.00
                WHEN weight <= 5 THEN 10.00
                ELSE 15.00
            END
        WHEN country IN ('Canada', 'Mexico') THEN weight * 3.50
        WHEN country IN ('UK', 'France', 'Germany') THEN weight * 8.00
        ELSE weight * 12.00
    END;
END;
$$ LANGUAGE plpgsql;
```

#### Looping Constructs

PL/pgSQL provides several looping structures:

```sql
-- Basic LOOP with EXIT
CREATE FUNCTION sum_to_n(n integer) 
RETURNS integer AS $$
DECLARE
    i integer := 0;
    total integer := 0;
BEGIN
    LOOP
        i := i + 1;
        total := total + i;
        
        EXIT WHEN i >= n;
    END LOOP;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- FOR loop with range
CREATE FUNCTION factorial(n integer) 
RETURNS integer AS $$
DECLARE
    result integer := 1;
BEGIN
    FOR i IN 1..n LOOP
        result := result * i;
    END LOOP;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- FOR loop with query results
CREATE FUNCTION update_employee_statuses() 
RETURNS void AS $$
DECLARE
    emp record;
BEGIN
    FOR emp IN 
        SELECT id, last_active_date 
        FROM employees 
        WHERE status = 'active'
    LOOP
        IF emp.last_active_date < CURRENT_DATE - interval '90 days' THEN
            UPDATE employees 
            SET status = 'inactive' 
            WHERE id = emp.id;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- WHILE loop
CREATE FUNCTION fibonacci(n integer) 
RETURNS integer AS $$
DECLARE
    i integer := 0;
    j integer := 1;
    temp integer;
    step integer := 0;
BEGIN
    WHILE step < n LOOP
        temp := i;
        i := j;
        j := temp + j;
        step := step + 1;
    END LOOP;
    
    RETURN i;
END;
$$ LANGUAGE plpgsql;
```

### Working with SQL in PL/pgSQL

#### Data Retrieval and Manipulation

PL/pgSQL functions can incorporate SQL statements:

```sql
-- SELECT INTO 
CREATE FUNCTION get_customer_credit_status(cust_id integer) 
RETURNS text AS $$
DECLARE
    total_purchases numeric;
    payment_ratio numeric;
BEGIN
    -- Get customer purchase total
    SELECT SUM(amount) INTO total_purchases
    FROM orders
    WHERE customer_id = cust_id;
    
    -- Get payment ratio
    SELECT COALESCE(SUM(payment_amount) / NULLIF(SUM(invoice_amount), 0), 0)
    INTO payment_ratio
    FROM invoices
    WHERE customer_id = cust_id;
    
    -- Determine credit status
    IF total_purchases > 10000 AND payment_ratio > 0.9 THEN
        RETURN 'Excellent';
    ELSIF total_purchases > 5000 AND payment_ratio > 0.75 THEN
        RETURN 'Good';
    ELSIF payment_ratio > 0.5 THEN
        RETURN 'Fair';
    ELSE
        RETURN 'Poor';
    END IF;
END;
$$ LANGUAGE plpgsql;
```

#### Dynamic SQL Execution

The EXECUTE statement runs dynamically constructed SQL:

```sql
CREATE FUNCTION query_by_department(dept_name text, order_field text) 
RETURNS SETOF employees AS $$
DECLARE
    query_text text;
BEGIN
    -- Sanitize input to prevent SQL injection
    IF order_field NOT IN ('id', 'name', 'hire_date', 'salary') THEN
        order_field := 'id';
    END IF;
    
    query_text := 'SELECT * FROM employees WHERE department = $1 ORDER BY ' || quote_ident(order_field);
    
    RETURN QUERY EXECUTE query_text USING dept_name;
END;
$$ LANGUAGE plpgsql;
```

**Key Points:**
- Use `quote_ident()` and `quote_literal()` to safely include identifiers and literals
- Parameter placeholders (`$1`, `$2`, etc.) handle values securely
- Dynamic SQL adds flexibility but requires careful security considerations

### Error Handling

#### Exception Handling

PL/pgSQL uses EXCEPTION blocks to catch and handle errors:

```sql
CREATE FUNCTION transfer_funds(
    from_account_id integer,
    to_account_id integer,
    amount numeric
) RETURNS boolean AS $$
DECLARE
    from_balance numeric;
    to_balance numeric;
BEGIN
    -- Check sufficient funds
    SELECT balance INTO from_balance
    FROM accounts
    WHERE id = from_account_id
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Source account % not found', from_account_id;
    END IF;
    
    IF from_balance < amount THEN
        RAISE EXCEPTION 'Insufficient funds (available: %)', from_balance;
    END IF;
    
    -- Update source account
    UPDATE accounts
    SET balance = balance - amount
    WHERE id = from_account_id;
    
    -- Update destination account
    UPDATE accounts
    SET balance = balance + amount
    WHERE id = to_account_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Destination account % not found', to_account_id;
    END IF;
    
    RETURN true;
    
EXCEPTION
    WHEN division_by_zero THEN
        RAISE LOG 'Division by zero detected in transfer_funds';
        RETURN false;
    WHEN OTHERS THEN
        -- Log error and rollback
        RAISE LOG 'Transfer funds error: %', SQLERRM;
        RETURN false;
END;
$$ LANGUAGE plpgsql;
```

#### Common PostgreSQL Error Codes

PL/pgSQL can catch specific errors by SQLSTATE code:

```sql
BEGIN
    -- Function logic
EXCEPTION
    WHEN unique_violation THEN      -- SQLSTATE '23505'
        -- Handle duplicate key
    WHEN foreign_key_violation THEN -- SQLSTATE '23503'
        -- Handle referential integrity violation
    WHEN check_violation THEN       -- SQLSTATE '23514'
        -- Handle check constraint violation
    WHEN insufficient_privilege THEN -- SQLSTATE '42501'
        -- Handle permission issues
END;
```

### Advanced PL/pgSQL Techniques

#### Cursors

Cursors process result sets row by row, ideal for large datasets:

```sql
CREATE FUNCTION process_large_result() 
RETURNS void AS $$
DECLARE
    curs CURSOR FOR 
        SELECT id, name 
        FROM large_table 
        WHERE processed = false;
    rec record;
BEGIN
    OPEN curs;
    
    LOOP
        FETCH curs INTO rec;
        EXIT WHEN NOT FOUND;
        
        -- Process each record
        PERFORM process_record(rec.id, rec.name);
        
        -- Update as processed
        UPDATE large_table 
        SET processed = true 
        WHERE id = rec.id;
        
        -- Commit every 100 records to avoid long transactions
        IF (rec.id % 100) = 0 THEN
            COMMIT;
        END IF;
    END LOOP;
    
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;
```

#### Function Polymorphism

Functions can work with different data types:

```sql
-- Polymorphic function using ANYELEMENT
CREATE FUNCTION max_value(a anyelement, b anyelement) 
RETURNS anyelement AS $$
BEGIN
    IF a > b THEN
        RETURN a;
    ELSE
        RETURN b;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Example usage
SELECT max_value(5, 10);       -- Returns 10
SELECT max_value(5.5, 2.3);    -- Returns 5.5
SELECT max_value('abc', 'def'); -- Returns 'def'
```

#### Composite Types and Records

Working with complex data structures:

```sql
CREATE FUNCTION get_employee_details(emp_id integer) 
RETURNS TABLE (
    id integer,
    full_name text,
    department text,
    manager text,
    years_of_service integer
) AS $$
DECLARE
    emp_record employees%ROWTYPE;
    manager_name text;
BEGIN
    -- Get employee record
    SELECT * INTO emp_record
    FROM employees
    WHERE id = emp_id;
    
    IF NOT FOUND THEN
        RETURN;
    END IF;
    
    -- Get manager name
    SELECT name INTO manager_name
    FROM employees
    WHERE id = emp_record.manager_id;
    
    -- Return employee details
    id := emp_record.id;
    full_name := emp_record.first_name || ' ' || emp_record.last_name;
    department := emp_record.department;
    manager := manager_name;
    years_of_service := EXTRACT(YEAR FROM AGE(CURRENT_DATE, emp_record.hire_date));
    
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;
```

### Triggers and Event Functions

#### Creating Triggers

Triggers execute functions automatically on table events:

```sql
-- Create trigger function
CREATE FUNCTION audit_employee_changes() 
RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO employee_audit_log (
            action, employee_id, changed_by, change_timestamp, new_data
        ) VALUES (
            'INSERT', NEW.id, current_user, current_timestamp, row_to_json(NEW)
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO employee_audit_log (
            action, employee_id, changed_by, change_timestamp, old_data, new_data
        ) VALUES (
            'UPDATE', NEW.id, current_user, current_timestamp, 
            row_to_json(OLD), row_to_json(NEW)
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO employee_audit_log (
            action, employee_id, changed_by, change_timestamp, old_data
        ) VALUES (
            'DELETE', OLD.id, current_user, current_timestamp, row_to_json(OLD)
        );
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to table
CREATE TRIGGER employee_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW EXECUTE FUNCTION audit_employee_changes();
```

#### Before vs. After Triggers

```sql
-- Before trigger for validation
CREATE FUNCTION validate_product() 
RETURNS trigger AS $$
BEGIN
    -- Ensure price is positive
    IF NEW.price <= 0 THEN
        RAISE EXCEPTION 'Product price must be positive';
    END IF;
    
    -- Convert product name to title case
    NEW.name := initcap(NEW.name);
    
    -- Set default category if none provided
    IF NEW.category IS NULL THEN
        NEW.category := 'Uncategorized';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER product_validation_trigger
BEFORE INSERT OR UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION validate_product();
```

### Performance Considerations

#### Function Volatility

PostgreSQL offers function volatility markings to optimize execution:

```sql
-- IMMUTABLE: Always returns same output for same input, no side effects
CREATE FUNCTION add_tax(price numeric) 
RETURNS numeric AS $$
BEGIN
    RETURN price * 1.08;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- STABLE: Returns same output for same input within transaction, no side effects
CREATE FUNCTION get_current_exchange_rate(currency text) 
RETURNS numeric AS $$
BEGIN
    RETURN (SELECT rate FROM exchange_rates WHERE code = currency);
END;
$$ LANGUAGE plpgsql STABLE;

-- VOLATILE: Default, can return different results on each call
CREATE FUNCTION generate_random_id() 
RETURNS text AS $$
BEGIN
    RETURN md5(random()::text || clock_timestamp()::text);
END;
$$ LANGUAGE plpgsql VOLATILE;
```

#### Optimizing PL/pgSQL Performance

- **Minimize database operations**: Reduce the number of SQL statements executed
- **Use set-based operations**: Favor set operations over row-by-row processing
- **Utilize proper indexing**: Ensure queries in functions use appropriate indexes
- **Consider function inlining**: Small functions may be inlined by the optimizer
- **Use appropriate volatility markings**: Help the optimizer make better decisions

### Security in PL/pgSQL Functions

#### Security Invoker vs. Security Definer

```sql
-- SECURITY INVOKER: Function runs with permissions of caller (default)
CREATE FUNCTION get_users_in_dept(dept_id integer) 
RETURNS TABLE (id integer, name text) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.name
    FROM users u
    WHERE u.department_id = dept_id;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

-- SECURITY DEFINER: Function runs with permissions of function creator
CREATE FUNCTION update_user_password(username text, new_password text) 
RETURNS boolean AS $$
BEGIN
    UPDATE users
    SET password_hash = crypt(new_password, gen_salt('bf'))
    WHERE user_name = username
    AND (current_user = username OR current_user = 'admin');
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Key Points:**
- Use SECURITY DEFINER sparingly and only when necessary
- Set a search_path explicitly in SECURITY DEFINER functions
- Grant minimum required privileges to function owners

### Debugging PL/pgSQL Functions

#### Techniques for Troubleshooting

- **RAISE Statements**: Output debug information at different levels

```sql
CREATE FUNCTION debug_example(value integer) 
RETURNS integer AS $$
DECLARE
    result integer;
BEGIN
    RAISE DEBUG 'debug_example called with value = %', value;
    
    result := value * 2;
    RAISE LOG 'Calculated result = %', result;
    
    IF result > 100 THEN
        RAISE INFO 'Large result detected: %', result;
    END IF;
    
    RETURN result;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Exception caught in debug_example: %', SQLERRM;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

- **ASSERT**: Verify conditions during development

```sql
CREATE FUNCTION calculate_discount(price numeric, discount_code text) 
RETURNS numeric AS $$
DECLARE
    discount_rate numeric;
    final_price numeric;
BEGIN
    SELECT rate INTO discount_rate
    FROM discount_codes
    WHERE code = discount_code;
    
    ASSERT discount_rate IS NOT NULL,
        'Invalid discount code or discount not found';
    
    ASSERT discount_rate BETWEEN 0 AND 1,
        'Invalid discount rate: %', discount_rate;
    
    final_price := price * (1 - discount_rate);
    
    ASSERT final_price >= 0,
        'Calculated price is negative: %', final_price;
    
    RETURN final_price;
END;
$$ LANGUAGE plpgsql;
```

### Testing PL/pgSQL Functions

#### Writing Test Cases

```sql
-- Create a testing framework
CREATE TABLE test_results (
    test_name text,
    passed boolean,
    execution_time timestamp,
    details text
);

-- Example test function
CREATE FUNCTION test_calculate_discount() 
RETURNS void AS $$
DECLARE
    expected_result numeric := 80.00;
    actual_result numeric;
    test_name text := 'calculate_discount_20_percent';
BEGIN
    -- Set up test data
    INSERT INTO discount_codes (code, rate) VALUES ('TEST20', 0.20);
    
    -- Execute function being tested
    actual_result := calculate_discount(100.00, 'TEST20');
    
    -- Verify result
    IF expected_result = actual_result THEN
        INSERT INTO test_results VALUES (test_name, true, now(), 'Test passed');
    ELSE
        INSERT INTO test_results VALUES (
            test_name, 
            false, 
            now(), 
            format('Expected %s, got %s', expected_result, actual_result)
        );
    END IF;
    
    -- Clean up test data
    DELETE FROM discount_codes WHERE code = 'TEST20';
EXCEPTION WHEN OTHERS THEN
    INSERT INTO test_results VALUES (
        test_name, 
        false, 
        now(), 
        format('Exception: %s', SQLERRM)
    );
    -- Ensure cleanup happens
    DELETE FROM discount_codes WHERE code = 'TEST20';
END;
$$ LANGUAGE plpgsql;
```

### Real-World Use Cases

#### Data Transformation and ETL

```sql
CREATE FUNCTION transform_and_load_customer_data() 
RETURNS integer AS $$
DECLARE
    records_inserted integer := 0;
BEGIN
    -- Insert transformed data
    INSERT INTO customer_warehouse (
        customer_id,
        full_name,
        contact_info,
        total_spent,
        customer_tier,
        last_purchase_date
    )
    SELECT 
        c.id,
        c.first_name || ' ' || c.last_name,
        jsonb_build_object(
            'email', c.email,
            'phone', c.phone,
            'address', c.address || ', ' || c.city || ', ' || c.state
        ),
        COALESCE(SUM(o.total_amount), 0),
        CASE 
            WHEN SUM(o.total_amount) > 10000 THEN 'Platinum'
            WHEN SUM(o.total_amount) > 5000 THEN 'Gold'
            WHEN SUM(o.total_amount) > 1000 THEN 'Silver'
            ELSE 'Bronze'
        END,
        MAX(o.order_date)
    FROM 
        customers c
    LEFT JOIN 
        orders o ON c.id = o.customer_id
    WHERE 
        c.updated_at > (SELECT last_etl_run FROM etl_control WHERE process = 'customer_transform')
    GROUP BY 
        c.id, c.first_name, c.last_name, c.email, c.phone, c.address, c.city, c.state;
        
    GET DIAGNOSTICS records_inserted = ROW_COUNT;
    
    -- Update control table with last run time
    UPDATE etl_control 
    SET last_etl_run = now() 
    WHERE process = 'customer_transform';
    
    RETURN records_inserted;
END;
$$ LANGUAGE plpgsql;
```

#### Business Logic Implementation

```sql
CREATE FUNCTION calculate_order_discount(
    customer_id integer,
    order_date date,
    order_amount numeric
) RETURNS numeric AS $$
DECLARE
    customer_discount numeric := 0;
    product_discount numeric := 0;
    seasonal_discount numeric := 0;
    loyalty_years integer;
    month_number integer;
    final_discount numeric;
BEGIN
    -- Get customer loyalty discount based on years as customer
    SELECT EXTRACT(YEAR FROM AGE(order_date, join_date)) INTO loyalty_years
    FROM customers
    WHERE id = customer_id;
    
    IF loyalty_years >= 5 THEN
        customer_discount := 0.10;
    ELSIF loyalty_years >= 2 THEN
        customer_discount := 0.05;
    END IF;
    
    -- Volume discount based on order size
    IF order_amount > 1000 THEN
        product_discount := 0.15;
    ELSIF order_amount > 500 THEN
        product_discount := 0.10;
    ELSIF order_amount > 200 THEN
        product_discount := 0.05;
    END IF;
    
    -- Seasonal discounts
    month_number := EXTRACT(MONTH FROM order_date);
    IF month_number IN (11, 12) THEN  -- Holiday season
        seasonal_discount := 0.05;
    ELSIF month_number IN (7, 8) THEN  -- Summer sale
        seasonal_discount := 0.03;
    END IF;
    
    -- Apply discount rules (taking the maximum single discount and adding 50% of others)
    final_discount := GREATEST(customer_discount, product_discount, seasonal_discount);
    
    -- Add half of other discounts (simplified combination)
    IF customer_discount > 0 AND customer_discount < final_discount THEN
        final_discount := final_discount + (customer_discount / 2);
    END IF;
    
    IF product_discount > 0 AND product_discount < final_discount THEN
        final_discount := final_discount + (product_discount / 2);
    END IF;
    
    IF seasonal_discount > 0 AND seasonal_discount < final_discount THEN
        final_discount := final_discount + (seasonal_discount / 2);
    END IF;
    
    -- Cap maximum discount at 25%
    final_discount := LEAST(final_discount, 0.25);
    
    RETURN final_discount;
END;
$$ LANGUAGE plpgsql;
```

#### Automated Database Maintenance

```sql
CREATE FUNCTION maintain_database() 
RETURNS void AS $$
DECLARE
    tbl record;
    dead_tuple_threshold integer := 10000;
    bloat_threshold numeric := 0.3;  -- 30% bloat
    analyze_threshold date := current_date - interval '7 days';
BEGIN
    -- Loop through all user tables
    FOR tbl IN 
        SELECT 
            schemaname,
            tablename,
            n_dead_tup,
            last_analyze,
            pg_total_relation_size(schemaname || '.' || tablename) as table_size,
            pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) as table_size_pretty
        FROM 
            pg_stat_user_tables
        ORDER BY 
            n_dead_tup DESC
    LOOP
        -- Log table being examined
        RAISE NOTICE 'Examining table: %.% (size: %)', 
            tbl.schemaname, tbl.tablename, tbl.table_size_pretty;
            
        -- VACUUM bloated tables
        IF tbl.n_dead_tup > dead_tuple_threshold THEN
            RAISE NOTICE 'VACUUMing table with % dead tuples: %.%', 
                tbl.n_dead_tup, tbl.schemaname, tbl.tablename;
                
            EXECUTE 'VACUUM (ANALYZE, VERBOSE) ' || 
                    quote_ident(tbl.schemaname) || '.' || 
                    quote_ident(tbl.tablename);
        -- ANALYZE stale statistics    
        ELSIF tbl.last_analyze IS NULL OR tbl.last_analyze < analyze_threshold THEN
            RAISE NOTICE 'ANALYZing table with stale statistics: %.%', 
                tbl.schemaname, tbl.tablename;
                
            EXECUTE 'ANALYZE VERBOSE ' || 
                    quote_ident(tbl.schemaname) || '.' || 
                    quote_ident(tbl.tablename);
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

### Function Documentation

#### Function Documentation Best Practices

```sql
/*
 * Function: calculate_shipping_cost
 * 
 * Calculates shipping costs based on package weight, destination country,
 * and shipping method.
 *
 * Parameters:
 *   p_weight - Package weight in kilograms
 *   p_country - Destination country code (ISO 2-letter code)
 *   p_shipping_method - Shipping method ('standard', 'express', or 'priority')
 *
 * Returns:
 *   Calculated shipping cost in USD
 *
 * Exceptions:
 *   If country code is invalid or unsupported
 *   If shipping method is invalid
 *   If weight is negative or above 100kg
 *
 * Notes:
 *   - Express shipping has a 50% premium over standard
 *   - Priority shipping has a 100% premium over standard
 *   - Maximum supported weight is 100kg
 *   - Based on shipping rates as of 2025-01-01
 *
 * Example:
 *   SELECT calculate_shipping_cost(5.2, 'US', 'express');
 *
 * Created by: Jane Developer
 * Created on: 2025-01-15
 * Version: 1.2
 */
CREATE OR REPLACE FUNCTION calculate_shipping_cost(
    p_weight numeric,
    p_country text,
    p_shipping_method text
) RETURNS numeric AS $$
DECLARE
    -- Function implementation...
END;
$$ LANGUAGE plpgsql;
```

### Conclusion

PL/pgSQL is a powerful procedural language that extends PostgreSQL's capabilities beyond standard SQL. By writing custom functions, you can encapsulate complex business logic, improve performance, ensure data consistency, and create reusable components for your applications.

Key takeaways for PL/pgSQL function development:

- Design functions with clear inputs, outputs, and error handling
- Leverage SQL's set-based operations rather than row-by-row processing when possible
- Consider performance implications through appropriate function volatility markings
- Implement proper security controls, especially for SECURITY DEFINER functions
- Document your functions thoroughly for future maintenance
- Use debugging tools to identify and fix issues during development
- Test your functions to ensure they behave as expected

With well-designed PL/pgSQL functions, you can build robust database applications that efficiently handle complex business requirements while maintaining data integrity and security.

---

