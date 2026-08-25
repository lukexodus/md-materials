## Creating Custom Data Types and Operators in PostgreSQL


### Introduction to PostgreSQL Type System

PostgreSQL's type system is remarkably extensible, allowing developers to create custom data types that behave like built-in types. This capability enables domain-specific data modeling, type safety, and specialized operations. Custom data types can represent complex structures ranging from geometric shapes to financial instruments, chemical compounds to time ranges. Combined with custom operators, they enable intuitive syntax and powerful operations tailored to your application domain.

### Motivation for Custom Types

Custom data types provide several benefits:

- **Domain-specific modeling**: Represent real-world concepts directly in the database
- **Type safety**: Prevent mixing incompatible values and catch errors earlier
- **Encapsulation**: Bundle related data with validation rules
- **Performance**: Store complex data efficiently and optimize operations
- **Maintainability**: Implement business logic at the database level consistently

### Basic Type Creation Methods

PostgreSQL offers multiple approaches for creating custom types:

#### Composite Types

Composite types are similar to structs or records and contain multiple fields:

```sql
-- Create a composite type for a 2D point
CREATE TYPE point2d AS (
    x DOUBLE PRECISION,
    y DOUBLE PRECISION
);

-- Use the type in a table
CREATE TABLE shapes (
    id SERIAL PRIMARY KEY,
    center point2d,
    name TEXT
);

-- Insert values
INSERT INTO shapes (center, name)
VALUES (
    (1.5, 2.5), -- x=1.5, y=2.5
    'My Shape'
);

-- Query fields
SELECT (center).x, (center).y FROM shapes;
```

#### Enumerated Types

Enums define a static set of values:

```sql
-- Create an enum for traffic light states
CREATE TYPE traffic_light_state AS ENUM (
    'red',
    'yellow',
    'green'
);

-- Use in a table
CREATE TABLE intersections (
    id SERIAL PRIMARY KEY,
    location TEXT,
    current_state traffic_light_state,
    last_updated TIMESTAMPTZ
);

-- Insert value
INSERT INTO intersections (location, current_state, last_updated)
VALUES ('Main & Broadway', 'green', NOW());

-- Invalid value would fail
-- INSERT INTO intersections (location, current_state, last_updated)
-- VALUES ('Oak & Pine', 'blue', NOW());
```

#### Domain Types

Domains are types with constraints:

```sql
-- Create a domain for positive prices with 2 decimal places
CREATE DOMAIN positive_price AS DECIMAL(10,2)
    CHECK (VALUE > 0);
    
-- Use in a table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT,
    price positive_price -- Will enforce the constraint
);

-- Valid insert
INSERT INTO products (name, price) VALUES ('Widget', 19.99);

-- Invalid insert would fail
-- INSERT INTO products (name, price) VALUES ('Free item', 0);
```

### Creating Full Custom Types

For more complex types, PostgreSQL supports complete custom type implementation:

#### Shell Type Creation

Start by defining a shell type:

```sql
-- Create a shell type
CREATE TYPE complex;
```

#### Input/Output Functions

Define functions to convert between external text representation and internal format:

```sql
-- Input function (text -> internal)
CREATE FUNCTION complex_in(cstring)
RETURNS complex
AS '$libdir/complex'
LANGUAGE C IMMUTABLE STRICT;

-- Output function (internal -> text)
CREATE FUNCTION complex_out(complex)
RETURNS cstring
AS '$libdir/complex'
LANGUAGE C IMMUTABLE STRICT;
```

#### Complete Type Definition

Finalize the type with input/output functions:

```sql
-- Complete type definition
CREATE TYPE complex (
    INTERNALLENGTH = 16,
    INPUT = complex_in,
    OUTPUT = complex_out,
    ALIGNMENT = double
);
```

#### SQL-Based Custom Types

For simpler cases, you can implement custom types in SQL:

```sql
-- Create a type for ISBN numbers
CREATE TYPE isbn;

-- Input function
CREATE FUNCTION isbn_in(text)
RETURNS isbn AS $$
DECLARE
    clean_isbn TEXT;
BEGIN
    -- Basic validation (simplified)
    clean_isbn := REGEXP_REPLACE($1, '[^0-9X]', '', 'g');
    IF LENGTH(clean_isbn) NOT IN (10, 13) THEN
        RAISE EXCEPTION 'Invalid ISBN format';
    END IF;
    RETURN clean_isbn;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Output function
CREATE FUNCTION isbn_out(isbn)
RETURNS text AS $$
BEGIN
    RETURN $1::text;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Complete the type
CREATE TYPE isbn (
    INPUT = isbn_in,
    OUTPUT = isbn_out,
    LIKE = text
);
```

### Creating Custom Operators

Custom operators make working with your types more intuitive:

#### Basic Operator Definition

```sql
-- Define a function for adding two complex numbers
CREATE FUNCTION complex_add(complex, complex)
RETURNS complex AS $$
    -- Implementation here
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- Create an operator based on the function
CREATE OPERATOR + (
    LEFTARG = complex,
    RIGHTARG = complex,
    PROCEDURE = complex_add,
    COMMUTATOR = +
);
```

#### Comparison Operators

For ordering and indexing, define comparison operators:

```sql
-- Less than function for complex numbers (by magnitude)
CREATE FUNCTION complex_lt(complex, complex)
RETURNS boolean AS $$
BEGIN
    -- Compare magnitudes (simplified)
    RETURN (complex_magnitude($1) < complex_magnitude($2));
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Define operator
CREATE OPERATOR < (
    LEFTARG = complex,
    RIGHTARG = complex,
    PROCEDURE = complex_lt,
    COMMUTATOR = >,
    NEGATOR = >=
);
```

#### Operator Classes for Indexing

Enable efficient indexing with operator classes:

```sql
-- Create operator class for B-tree
CREATE OPERATOR CLASS complex_ops
DEFAULT FOR TYPE complex USING btree AS
    OPERATOR 1 <,
    OPERATOR 2 <=,
    OPERATOR 3 =,
    OPERATOR 4 >=,
    OPERATOR 5 >,
    FUNCTION 1 complex_cmp(complex, complex);
```

### Practical Example: Currency Type

Let's create a complete example for a currency type:

```sql
-- Currency type to handle amounts with explicit currency code
CREATE TYPE currency;

-- Internal representation
CREATE FUNCTION currency_in(cstring)
RETURNS currency AS $$
DECLARE
    parts TEXT[];
    amount NUMERIC;
    code TEXT;
BEGIN
    -- Parse format like "USD 100.00" or "100.00 USD"
    parts := regexp_matches($1, '([A-Z]{3})\s+(\d+(\.\d+)?)|(\d+(\.\d+)?)\s+([A-Z]{3})');
    
    IF parts[1] IS NOT NULL THEN
        code := parts[1];
        amount := parts[2]::numeric;
    ELSE
        code := parts[6];
        amount := parts[4]::numeric;
    END IF;
    
    -- Validation
    IF code NOT IN ('USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF') THEN
        RAISE EXCEPTION 'Unsupported currency code: %', code;
    END IF;
    
    -- Return internal representation
    RETURN (code || ',' || amount)::currency;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- External representation
CREATE FUNCTION currency_out(currency)
RETURNS cstring AS $$
DECLARE
    parts TEXT[];
BEGIN
    parts := string_to_array($1::text, ',');
    RETURN parts[1] || ' ' || parts[2];
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Complete the type
CREATE TYPE currency (
    INPUT = currency_in,
    OUTPUT = currency_out,
    LIKE = text
);

-- Accessor functions
CREATE FUNCTION currency_code(currency)
RETURNS text AS $$
    SELECT split_part($1::text, ',', 1);
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE FUNCTION currency_amount(currency)
RETURNS numeric AS $$
    SELECT split_part($1::text, ',', 2)::numeric;
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- Addition operator
CREATE FUNCTION currency_add(currency, currency)
RETURNS currency AS $$
DECLARE
    code1 TEXT := currency_code($1);
    code2 TEXT := currency_code($2);
    amount1 NUMERIC := currency_amount($1);
    amount2 NUMERIC := currency_amount($2);
BEGIN
    IF code1 <> code2 THEN
        RAISE EXCEPTION 'Cannot add different currencies: % and %', code1, code2;
    END IF;
    RETURN (code1 || ',' || (amount1 + amount2))::currency;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Create addition operator
CREATE OPERATOR + (
    LEFTARG = currency,
    RIGHTARG = currency,
    PROCEDURE = currency_add,
    COMMUTATOR = +
);

-- Usage example
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    amount currency,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert with explicit casting
INSERT INTO orders (customer_id, amount)
VALUES 
    (1, 'USD 99.95'::currency),
    (2, 'EUR 75.00'::currency);

-- Query with operators and accessors
SELECT 
    id,
    currency_code(amount) AS currency,
    currency_amount(amount) AS value
FROM orders;

-- Addition (would error if currencies don't match)
SELECT 'USD 100.00'::currency + 'USD 50.00'::currency;
```

### Advanced Type Features

#### Array Support

Enable arrays of your custom type:

```sql
-- Use arrays of your custom type
CREATE TABLE sensor_readings (
    id SERIAL PRIMARY KEY,
    location TEXT,
    coordinates point2d[],  -- Array of points
    timestamp TIMESTAMPTZ
);

-- Insert array values
INSERT INTO sensor_readings (location, coordinates, timestamp)
VALUES (
    'Building A',
    ARRAY['(1.0,2.0)'::point2d, '(1.5,2.5)'::point2d, '(2.0,3.0)'::point2d],
    NOW()
);
```

#### Range Types

Create range types for your custom types:

```sql
-- First ensure operators exist for your type
CREATE FUNCTION time_lt(time with time zone, time with time zone)
RETURNS boolean AS $$
    SELECT $1 < $2;
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- Create a range type
CREATE TYPE timerange AS RANGE (
    subtype = time with time zone,
    subtype_opclass = time_ops
);

-- Use in a table
CREATE TABLE shift_schedule (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER,
    work_hours timerange,
    day DATE
);

-- Insert range values
INSERT INTO shift_schedule (employee_id, work_hours, day)
VALUES (
    1, 
    '[09:00:00+00, 17:00:00+00)', 
    CURRENT_DATE
);
```

### Implementing Type Casts

Define casts between your types and existing types:

```sql
-- Cast from text to currency
CREATE FUNCTION text_to_currency(text)
RETURNS currency AS $$
BEGIN
    RETURN $1::currency;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Invalid currency format: %', $1;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Create cast
CREATE CAST (text AS currency)
WITH FUNCTION text_to_currency(text)
AS IMPLICIT;

-- Cast from currency to numeric (gets amount only)
CREATE CAST (currency AS numeric)
WITH FUNCTION currency_amount(currency)
AS IMPLICIT;
```

### Object-Oriented Type Hierarchies

PostgreSQL supports inheritance between types:

```sql
-- Base type for shapes
CREATE TABLE geometric_shape (
    id SERIAL PRIMARY KEY,
    name TEXT,
    color TEXT
);

-- Create a circle table inheriting from shape
CREATE TABLE circle (
    radius DOUBLE PRECISION,
    CHECK (radius > 0)
) INHERITS (geometric_shape);

-- Create a rectangle table inheriting from shape
CREATE TABLE rectangle (
    width DOUBLE PRECISION,
    height DOUBLE PRECISION,
    CHECK (width > 0 AND height > 0)
) INHERITS (geometric_shape);

-- Insert data
INSERT INTO circle (name, color, radius)
VALUES ('Small circle', 'red', 5.0);

INSERT INTO rectangle (name, color, width, height)
VALUES ('Large rectangle', 'blue', 10.0, 20.0);

-- Query all shapes
SELECT * FROM geometric_shape;
```

### Implementing Aggregate Functions

Create aggregates for your custom types:

```sql
-- Function to combine two currencies
CREATE FUNCTION currency_state_function(state currency, next currency)
RETURNS currency AS $$
BEGIN
    IF state IS NULL THEN
        RETURN next;
    END IF;
    
    IF currency_code(state) <> currency_code(next) THEN
        RAISE EXCEPTION 'Cannot aggregate different currencies';
    END IF;
    
    RETURN state + next;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create aggregate
CREATE AGGREGATE sum(currency) (
    SFUNC = currency_state_function,
    STYPE = currency,
    INITCOND = NULL
);

-- Use the aggregate
SELECT currency_code(sum(amount)) AS currency, 
       currency_amount(sum(amount)) AS total
FROM orders
GROUP BY currency_code(amount);
```

### Performance Considerations

#### Storage Efficiency

Consider internal representation carefully:

```sql
-- Using fixed-length or variable-length storage
CREATE TYPE efficient_point (
    INTERNALLENGTH = 16,  -- Fixed length, 8 bytes per coordinate
    INPUT = point_in,
    OUTPUT = point_out
);

-- Vs variable length for arbitrary precision
CREATE TYPE variable_point (
    INTERNALLENGTH = VARIABLE,
    INPUT = vpoint_in,
    OUTPUT = vpoint_out
);
```

#### Function Cost Estimates

Provide execution cost hints:

```sql
-- Function with cost estimate
CREATE FUNCTION complex_magnitude(complex)
RETURNS double precision
AS '$libdir/complex', 'complex_magnitude'
LANGUAGE C IMMUTABLE STRICT
COST 10;  -- Relative cost hint
```

### Extending PostgreSQL in C

For maximum performance and flexibility, extend PostgreSQL in C:

```c
// In a C file (complex.c)
#include "postgres.h"
#include "fmgr.h"

PG_MODULE_MAGIC;

// Structure for internal representation
typedef struct ComplexNumber {
    double re;
    double im;
} ComplexNumber;

// Input function
PG_FUNCTION_INFO_V1(complex_in);
Datum
complex_in(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    ComplexNumber *result;
    
    // Parse input string (format: '1.0+2.0i')
    // Allocation and parsing logic...
    
    PG_RETURN_POINTER(result);
}

// Output function
PG_FUNCTION_INFO_V1(complex_out);
Datum
complex_out(PG_FUNCTION_ARGS)
{
    ComplexNumber *complex = (ComplexNumber *) PG_GETARG_POINTER(0);
    char *result;
    
    // Format as string
    // Allocation and formatting logic...
    
    PG_RETURN_CSTRING(result);
}
```

### Real-World Application Examples

#### Geographic Information System (GIS)

```sql
-- Simplified PostGIS-like type for a point
CREATE TYPE geo_point;

-- Input function
CREATE FUNCTION geo_point_in(cstring)
RETURNS geo_point AS $$
DECLARE
    parts DOUBLE PRECISION[];
BEGIN
    -- Format: 'POINT(lon lat)'
    parts := regexp_matches($1, 'POINT\(([0-9.-]+) ([0-9.-]+)\)')::DOUBLE PRECISION[];
    
    -- Validate longitude and latitude
    IF parts[1] < -180 OR parts[1] > 180 THEN
        RAISE EXCEPTION 'Invalid longitude: %', parts[1];
    END IF;
    
    IF parts[2] < -90 OR parts[2] > 90 THEN
        RAISE EXCEPTION 'Invalid latitude: %', parts[2];
    END IF;
    
    -- Return as internal representation
    RETURN (parts[1] || ',' || parts[2])::geo_point;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Output function
CREATE FUNCTION geo_point_out(geo_point)
RETURNS cstring AS $$
DECLARE
    parts TEXT[];
    lon DOUBLE PRECISION;
    lat DOUBLE PRECISION;
BEGIN
    parts := string_to_array($1::text, ',');
    lon := parts[1]::DOUBLE PRECISION;
    lat := parts[2]::DOUBLE PRECISION;
    RETURN 'POINT(' || lon || ' ' || lat || ')';
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Complete the type
CREATE TYPE geo_point (
    INPUT = geo_point_in,
    OUTPUT = geo_point_out,
    LIKE = text
);

-- Calculate distance between points
CREATE FUNCTION geo_distance(geo_point, geo_point)
RETURNS DOUBLE PRECISION AS $$
DECLARE
    lon1 DOUBLE PRECISION := split_part($1::text, ',', 1)::DOUBLE PRECISION;
    lat1 DOUBLE PRECISION := split_part($1::text, ',', 2)::DOUBLE PRECISION;
    lon2 DOUBLE PRECISION := split_part($2::text, ',', 1)::DOUBLE PRECISION;
    lat2 DOUBLE PRECISION := split_part($2::text, ',', 2)::DOUBLE PRECISION;
    x DOUBLE PRECISION;
    y DOUBLE PRECISION;
    R DOUBLE PRECISION := 6371000; -- Earth radius in meters
BEGIN
    -- Haversine formula
    x := (lon2-lon1) * cos((lat1+lat2)/2);
    y := (lat2-lat1);
    RETURN sqrt(x*x + y*y) * R * PI() / 180;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Create operator for distance
CREATE OPERATOR <-> (
    LEFTARG = geo_point,
    RIGHTARG = geo_point,
    PROCEDURE = geo_distance,
    COMMUTATOR = <->
);
```

#### Time Interval with Business Days

```sql
-- Business time interval that excludes weekends and holidays
CREATE TYPE business_interval;

-- Function to add business days to a date
CREATE FUNCTION add_business_days(start_date DATE, days INTEGER)
RETURNS DATE AS $$
DECLARE
    current_date DATE := start_date;
    days_added INTEGER := 0;
    is_holiday BOOLEAN;
BEGIN
    WHILE days_added < days LOOP
        current_date := current_date + INTERVAL '1 day';
        
        -- Skip weekends
        IF EXTRACT(DOW FROM current_date) NOT IN (0, 6) THEN
            -- Check if it's a holiday
            SELECT EXISTS(
                SELECT 1 FROM holidays WHERE holiday_date = current_date
            ) INTO is_holiday;
            
            IF NOT is_holiday THEN
                days_added := days_added + 1;
            END IF;
        END IF;
    END LOOP;
    
    RETURN current_date;
END;
$$ LANGUAGE plpgsql STABLE;

-- Time interval input function
CREATE FUNCTION business_interval_in(cstring)
RETURNS business_interval AS $$
DECLARE
    num_days INTEGER;
BEGIN
    -- Format: '10 business days'
    num_days := substring($1 from '^(\d+)')::INTEGER;
    RETURN num_days::text::business_interval;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Output function
CREATE FUNCTION business_interval_out(business_interval)
RETURNS cstring AS $$
BEGIN
    RETURN $1::text || ' business days';
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Complete the type
CREATE TYPE business_interval (
    INPUT = business_interval_in,
    OUTPUT = business_interval_out,
    LIKE = text
);

-- Operator for adding business days to a date
CREATE FUNCTION date_add_business(date, business_interval)
RETURNS date AS $$
    SELECT add_business_days($1, $2::text::integer);
$$ LANGUAGE SQL STABLE STRICT;

-- Create operator
CREATE OPERATOR + (
    LEFTARG = date,
    RIGHTARG = business_interval,
    PROCEDURE = date_add_business
);

-- Usage
CREATE TABLE project_deadlines (
    id SERIAL PRIMARY KEY,
    task_name TEXT,
    start_date DATE,
    duration business_interval,
    deadline DATE GENERATED ALWAYS AS (start_date + duration) STORED
);

-- Insert with custom type
INSERT INTO project_deadlines (task_name, start_date, duration)
VALUES ('Complete documentation', '2023-05-01', '10 business days'::business_interval);
```

**Key Points**:

- PostgreSQL supports creating various custom data types including composite, enumerated, domain and complete custom types
- Custom operators allow for intuitive syntax when working with custom types
- Input/output functions define how data converts between text and internal representations
- Custom types can participate in advanced features like arrays, ranges, and inheritance
- Performance optimization requires careful consideration of storage formats and access patterns
- Real-world applications include specialized domains like GIS, finance, and business logic

---

