## Using Python, Perl, and C for Custom Functions


### Introduction to PostgreSQL Procedural Languages

PostgreSQL supports multiple procedural languages for writing custom functions and stored procedures. Beyond the built-in PL/pgSQL, PostgreSQL allows developers to extend database functionality using languages like Python, Perl, and C. These languages provide different trade-offs between performance, ecosystem integration, and development speed.

### Language Extensions Overview

**Key Points**:

- PostgreSQL supports external languages via procedural language extensions
- Each language extension must be installed separately
- Different languages offer unique capabilities and performance characteristics
- Security considerations vary by language implementation

### Setting Up Language Extensions

#### Python (PL/Python)

PL/Python comes in two variants: PL/Python for untrusted code (plpythonu) and PL/Python for trusted code (plpython3u):

```sql
-- Install PL/Python extension (requires Python and PostgreSQL dev packages)
CREATE EXTENSION plpython3u;

-- Verify installation
SELECT * FROM pg_language WHERE lanname = 'plpython3u';
```

Installation requirements:

- PostgreSQL development libraries
- Python development libraries
- On Ubuntu/Debian: `apt-get install postgresql-plpython3-<pg_version>`
- On RHEL/CentOS: `yum install postgresql<version>-plpython3`

#### Perl (PL/Perl)

```sql
-- Install PL/Perl extension
CREATE EXTENSION plperl;

-- For untrusted Perl (more capabilities but higher risk)
CREATE EXTENSION plperlu;
```

Installation requirements:

- Perl development libraries
- On Ubuntu/Debian: `apt-get install postgresql-plperl-<pg_version>`
- On RHEL/CentOS: `yum install postgresql<version>-plperl`

#### C (Writing C Functions)

Unlike interpreted languages, C functions require:

1. Compilation into shared objects (.so files)
2. Loading via CREATE FUNCTION with language 'C'

Installation requirements:

- PostgreSQL server development package
- C compiler (gcc/clang)
- On Ubuntu/Debian: `apt-get install postgresql-server-dev-<pg_version>`
- On RHEL/CentOS: `yum install postgresql<version>-devel`

### Creating Functions in Python (PL/Python)

#### Basic Function Structure

```sql
CREATE OR REPLACE FUNCTION python_hello(name text)
RETURNS text
AS $$
    return "Hello, " + name + "! This is PL/Python speaking."
$$ LANGUAGE plpython3u;

-- Usage
SELECT python_hello('World');
```

#### Data Processing Example

```sql
CREATE OR REPLACE FUNCTION calculate_statistics(data_array float[])
RETURNS json
AS $$
    import numpy as np
    import json
    
    if not data_array:
        return json.dumps({"error": "Empty array"})
    
    arr = np.array(data_array)
    stats = {
        "mean": float(np.mean(arr)),
        "median": float(np.median(arr)),
        "std_dev": float(np.std(arr)),
        "min": float(np.min(arr)),
        "max": float(np.max(arr)),
        "q1": float(np.percentile(arr, 25)),
        "q3": float(np.percentile(arr, 75))
    }
    
    return json.dumps(stats)
$$ LANGUAGE plpython3u;

-- Usage
SELECT calculate_statistics(ARRAY[1.5, 2.5, 3.5, 4.5, 5.5, 10.0, 15.0]);
```

#### Accessing Database Data

PL/Python can execute SQL queries using the `plpy` module:

```sql
CREATE OR REPLACE FUNCTION get_user_orders(user_id integer)
RETURNS TABLE(order_id integer, amount numeric, order_date timestamp)
AS $$
    # Execute query through plpy
    orders = plpy.execute("""
        SELECT order_id, amount, order_date 
        FROM orders 
        WHERE user_id = $1
        ORDER BY order_date DESC
    """, [user_id])
    
    # Return results as records
    return orders
$$ LANGUAGE plpython3u;

-- Usage 
SELECT * FROM get_user_orders(42);
```

#### Using External Python Libraries

```sql
CREATE OR REPLACE FUNCTION analyze_text_sentiment(text_content text)
RETURNS json
AS $$
    import json
    
    try:
        # Using TextBlob for sentiment analysis
        from textblob import TextBlob
        
        blob = TextBlob(text_content)
        sentiment = blob.sentiment
        
        return json.dumps({
            "polarity": sentiment.polarity,
            "subjectivity": sentiment.subjectivity,
            "assessment": "positive" if sentiment.polarity > 0 else 
                          "negative" if sentiment.polarity < 0 else "neutral"
        })
    except ImportError:
        plpy.error("Required Python library not installed: TextBlob")
$$ LANGUAGE plpython3u;
```

**Key Points**:

- External libraries must be installed in the PostgreSQL server's Python environment
- Library management requires server access (not feasible in managed services)
- `plpy.error()` raises PostgreSQL exceptions

### Creating Functions in Perl (PL/Perl)

#### Basic Function Structure

```sql
CREATE OR REPLACE FUNCTION perl_hello(name text)
RETURNS text
AS $$
    my $name = shift;
    return "Hello, $name! This is PL/Perl speaking.";
$$ LANGUAGE plperl;

-- Usage
SELECT perl_hello('World');
```

#### Text Processing Example

Perl excels at text manipulation with regular expressions:

```sql
CREATE OR REPLACE FUNCTION extract_emails(text_content text)
RETURNS SETOF text
AS $$
    my $text = shift;
    my @emails = ();
    
    # Extract email addresses using regex
    while ($text =~ /([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/g) {
        push @emails, $1;
    }
    
    # Return unique emails
    my %seen = ();
    return [grep { !$seen{$_}++ } @emails];
$$ LANGUAGE plperl;

-- Usage
SELECT * FROM extract_emails('Contact us at support@example.com or sales@example.org');
```

#### Database Interaction

Using `spi_exec_query` for database operations:

```sql
CREATE OR REPLACE FUNCTION get_department_stats()
RETURNS TABLE(department text, employee_count bigint, avg_salary numeric)
AS $$
    # Query departments
    my $departments = spi_exec_query("SELECT id, name FROM departments");
    
    my @results = ();
    
    # For each department, get employee stats
    foreach my $dept (@{$departments->{rows}}) {
        my $stats = spi_exec_query("
            SELECT 
                COUNT(*) AS employee_count,
                ROUND(AVG(salary), 2) AS avg_salary
            FROM employees
            WHERE department_id = " . $dept->{id}
        );
        
        push @results, {
            department => $dept->{name},
            employee_count => $stats->{rows}[0]{employee_count},
            avg_salary => $stats->{rows}[0]{avg_salary}
        };
    }
    
    return \@results;
$$ LANGUAGE plperl;

-- Usage
SELECT * FROM get_department_stats();
```

#### Using External Perl Modules

```sql
CREATE OR REPLACE FUNCTION generate_random_uuid()
RETURNS text
AS $$
    use Data::UUID;
    
    my $ug = Data::UUID->new();
    my $uuid = $ug->create_str();
    
    return $uuid;
$$ LANGUAGE plperlu;

-- Usage
SELECT generate_random_uuid();
```

**Key Points**:

- External modules must be installed in the PostgreSQL server's Perl environment
- `plperlu` (untrusted) is required for many module operations
- Security considerations are more significant with untrusted language variants

### Creating Functions in C

C functions offer the highest performance but require more development effort and carry additional risks.

#### Basic C Function Structure

```c
/* File: hello.c */
#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(c_hello);

Datum
c_hello(PG_FUNCTION_ARGS)
{
    text *name_text = PG_GETARG_TEXT_PP(0);
    int name_len = VARSIZE_ANY_EXHDR(name_text);
    char *name = palloc(name_len + 1);
    
    memcpy(name, VARDATA_ANY(name_text), name_len);
    name[name_len] = '\0';
    
    char *result = psprintf("Hello, %s! This is C speaking.", name);
    
    pfree(name);
    
    PG_RETURN_TEXT_P(cstring_to_text(result));
}
```

Compilation and installation:

```bash
# Compile the C code into a shared object
gcc -fPIC -I$(pg_config --includedir-server) -c hello.c
gcc -shared -o hello.so hello.o

# Move to PostgreSQL extension directory
sudo cp hello.so $(pg_config --pkglibdir)
```

Create the function in PostgreSQL:

```sql
CREATE OR REPLACE FUNCTION c_hello(text)
RETURNS text
AS 'hello', 'c_hello'
LANGUAGE C STRICT;

-- Usage
SELECT c_hello('World');
```

#### High-Performance Aggregate Function

```c
/* File: vector_norm.c */
#include "postgres.h"
#include "fmgr.h"
#include "catalog/pg_type.h"
#include "utils/array.h"
#include <math.h>

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(vector_norm);

Datum
vector_norm(PG_FUNCTION_ARGS)
{
    ArrayType *array = PG_GETARG_ARRAYTYPE_P(0);
    float8 *values;
    int ndims, *dims, *lbs;
    float8 sum = 0.0;
    
    /* Check array dimensions */
    ndims = ARR_NDIM(array);
    if (ndims != 1)
        ereport(ERROR, (errmsg("input must be a 1-dimensional array")));
    
    dims = ARR_DIMS(array);
    lbs = ARR_LBOUND(array);
    
    values = (float8 *) ARR_DATA_PTR(array);
    int array_size = dims[0];
    
    /* Calculate the L2 norm (Euclidean norm) */
    for (int i = 0; i < array_size; i++) {
        sum += values[i] * values[i];
    }
    
    float8 result = sqrt(sum);
    
    PG_RETURN_FLOAT8(result);
}
```

```sql
CREATE OR REPLACE FUNCTION vector_norm(float8[])
RETURNS float8
AS 'vector_norm', 'vector_norm'
LANGUAGE C STRICT;

-- Usage
SELECT vector_norm(ARRAY[3.0, 4.0]); -- Returns 5.0 (Pythagorean triple)
```

#### Complex Data Processing in C

```c
/* File: image_process.c */
#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "libpq/pqformat.h"
#include <stdio.h>

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(grayscale_image);

Datum
grayscale_image(PG_FUNCTION_ARGS)
{
    bytea *input_image = PG_GETARG_BYTEA_PP(0);
    int size = VARSIZE_ANY_EXHDR(input_image);
    
    /* Validate minimum size for a basic RGB image */
    if (size < 3) {
        ereport(ERROR, (errmsg("Invalid image data: too small")));
    }
    
    /* Create output bytea with same size */
    bytea *output_image = (bytea *) palloc(VARHDRSZ + size);
    SET_VARSIZE(output_image, VARHDRSZ + size);
    
    unsigned char *in_bytes = (unsigned char *) VARDATA_ANY(input_image);
    unsigned char *out_bytes = (unsigned char *) VARDATA(output_image);
    
    /* Process RGB pixels (every 3 bytes) */
    for (int i = 0; i < size; i += 3) {
        if (i + 2 >= size) break; // Avoid buffer overrun
        
        unsigned char r = in_bytes[i];
        unsigned char g = in_bytes[i+1];
        unsigned char b = in_bytes[i+2];
        
        /* Standard grayscale conversion formula */
        unsigned char gray = (unsigned char)(0.299 * r + 0.587 * g + 0.114 * b);
        
        /* Set all RGB channels to the same gray value */
        out_bytes[i] = gray;
        out_bytes[i+1] = gray;
        out_bytes[i+2] = gray;
    }
    
    PG_RETURN_BYTEA_P(output_image);
}
```

```sql
CREATE OR REPLACE FUNCTION grayscale_image(bytea)
RETURNS bytea
AS 'image_process', 'grayscale_image'
LANGUAGE C STRICT;

-- Usage would require image data stored in bytea column
SELECT grayscale_image(image_data) FROM images WHERE id = 1;
```

### Performance Comparisons

**Key Points**:

- C functions offer the highest performance (typically 10-100x faster than interpreted languages)
- Python provides good balance between development speed and performance
- Perl excels at text processing tasks

Benchmark example:

```sql
-- Create test data
CREATE TABLE test_data AS
SELECT generate_series(1, 100000) AS id, 
       random() * 100 AS value;

-- Time different implementations
\timing on

-- PL/pgSQL version
CREATE OR REPLACE FUNCTION sum_sqrt_plpgsql()
RETURNS float8 AS $$
DECLARE
    total float8 := 0;
    r record;
BEGIN
    FOR r IN SELECT value FROM test_data LOOP
        total := total + sqrt(r.value);
    END LOOP;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- PL/Python version
CREATE OR REPLACE FUNCTION sum_sqrt_python()
RETURNS float8 AS $$
    import math
    total = 0
    results = plpy.execute("SELECT value FROM test_data")
    for row in results:
        total += math.sqrt(row["value"])
    return total
$$ LANGUAGE plpython3u;

-- PL/Perl version
CREATE OR REPLACE FUNCTION sum_sqrt_perl()
RETURNS float8 AS $$
    my $total = 0;
    my $results = spi_exec_query("SELECT value FROM test_data");
    foreach my $row (@{$results->{rows}}) {
        $total += sqrt($row->{value});
    }
    return $total;
$$ LANGUAGE plperl;

-- C version would be much faster but is more complex to implement

SELECT sum_sqrt_plpgsql();
SELECT sum_sqrt_python();
SELECT sum_sqrt_perl();
```

Typical relative performance (from fastest to slowest):

1. C functions
2. SQL functions (when optimized)
3. PL/pgSQL
4. PL/Python
5. PL/Perl

### Security Considerations

#### Python Security

```sql
-- Create a sandboxed environment
CREATE OR REPLACE FUNCTION secure_python_function(text)
RETURNS text AS $$
    # Can't access filesystem or network directly
    import os
    
    try:
        os.system("rm -rf /") # This will fail in plpython3u
        return "This shouldn't happen"
    except:
        return "Security restrictions prevented file system access"
$$ LANGUAGE plpython3u;
```

#### Perl Security

```sql
-- Trusted Perl can't access system
CREATE OR REPLACE FUNCTION trusted_perl_function()
RETURNS text AS $$
    eval {
        system("ls -la"); # This will fail in plperl
    };
    if ($@) {
        return "Security prevented system access: $@";
    }
    return "This shouldn't happen";
$$ LANGUAGE plperl;

-- Untrusted Perl has fewer restrictions
CREATE OR REPLACE FUNCTION untrusted_perl_function()
RETURNS text AS $$
    # This can access system resources - DANGEROUS!
    use File::Temp qw(tempfile);
    my ($fh, $filename) = tempfile();
    print $fh "Test content\n";
    close $fh;
    my $content = `cat $filename`;
    unlink $filename;
    return "File content: $content";
$$ LANGUAGE plperlu;
```

#### C Security

C functions have no security sandbox and run with database server privileges:

```c
/* DANGEROUS - DO NOT USE IN PRODUCTION */
PG_FUNCTION_INFO_V1(unsafe_c_function);

Datum
unsafe_c_function(PG_FUNCTION_ARGS)
{
    /* This has full system access - extremely dangerous */
    system("touch /tmp/security_breach");
    
    PG_RETURN_TEXT_P(cstring_to_text("File created"));
}
```

**Key Points**:

- PL/Python and PL/Perl (trusted) provide security sandboxing
- PL/Perl untrusted (plperlu) and C functions have extensive system access
- Always review code before installation, especially for untrusted languages
- Use appropriate permissions to restrict who can create functions

### Practical Use Cases

#### Python: Machine Learning Integration

```sql
CREATE OR REPLACE FUNCTION predict_customer_churn(
    customer_age int,
    subscription_length int,
    monthly_charges numeric,
    total_charges numeric
) RETURNS json AS $$
    import pickle
    import json
    import os
    
    # Load pre-trained model (path must be accessible to PostgreSQL)
    model_path = '/var/lib/postgresql/models/churn_model.pkl'
    
    try:
        with open(model_path, 'rb') as f:
            model = pickle.load(f)
            
        # Make prediction
        features = [[customer_age, subscription_length, 
                     float(monthly_charges), float(total_charges)]]
        prediction = model.predict_proba(features)[0]
        
        return json.dumps({
            'churn_probability': float(prediction[1]),
            'retain_probability': float(prediction[0]),
            'recommendation': 'At risk' if prediction[1] > 0.5 else 'Stable'
        })
    except Exception as e:
        return json.dumps({'error': str(e)})
$$ LANGUAGE plpython3u;
```

#### Perl: Complex Text Analysis

```sql
CREATE OR REPLACE FUNCTION analyze_log_entries(log_text text)
RETURNS TABLE(log_level text, timestamp text, component text, message text) AS $$
    my $logs = shift;
    my @parsed_logs = ();
    
    # Complex regex to parse log entries
    while ($logs =~ /\[(ERROR|WARNING|INFO|DEBUG)\]\s+\[([0-9]{4}-[0-9]{2}-[0-9]{2}\s+[0-9]{2}:[0-9]{2}:[0-9]{2})\]\s+\[([^\]]+)\]\s+(.+?)(?=\n\[|$)/gs) {
        push @parsed_logs, {
            log_level => $1,
            timestamp => $2,
            component => $3,
            message => $4
        };
    }
    
    return \@parsed_logs;
$$ LANGUAGE plperl;

-- Usage
SELECT * FROM analyze_log_entries('[ERROR] [2023-05-01 14:23:45] [AuthService] Failed login attempt
[INFO] [2023-05-01 14:25:12] [UserService] User profile updated');
```

#### C: High-Performance Geospatial Calculations

```c
/* File: haversine.c */
#include "postgres.h"
#include "fmgr.h"
#include <math.h>

PG_MODULE_MAGIC;

#define EARTH_RADIUS_KM 6371.0

PG_FUNCTION_INFO_V1(haversine_distance);

Datum
haversine_distance(PG_FUNCTION_ARGS)
{
    float8 lat1 = PG_GETARG_FLOAT8(0);
    float8 lon1 = PG_GETARG_FLOAT8(1);
    float8 lat2 = PG_GETARG_FLOAT8(2);
    float8 lon2 = PG_GETARG_FLOAT8(3);
    
    /* Convert to radians */
    lat1 = lat1 * M_PI / 180.0;
    lon1 = lon1 * M_PI / 180.0;
    lat2 = lat2 * M_PI / 180.0;
    lon2 = lon2 * M_PI / 180.0;
    
    /* Haversine formula */
    float8 dlon = lon2 - lon1;
    float8 dlat = lat2 - lat1;
    float8 a = sin(dlat/2) * sin(dlat/2) + cos(lat1) * cos(lat2) * sin(dlon/2) * sin(dlon/2);
    float8 c = 2 * atan2(sqrt(a), sqrt(1-a));
    float8 distance = EARTH_RADIUS_KM * c;
    
    PG_RETURN_FLOAT8(distance);
}
```

```sql
CREATE OR REPLACE FUNCTION haversine_distance(
    lat1 float8, lon1 float8, 
    lat2 float8, lon2 float8
) RETURNS float8
AS 'haversine', 'haversine_distance'
LANGUAGE C STRICT;

-- Usage: Calculate distance between New York and London
SELECT haversine_distance(40.7128, -74.0060, 51.5074, -0.1278) AS distance_km;
```

### Debugging and Troubleshooting

#### Debugging PL/Python

```sql
CREATE OR REPLACE FUNCTION debug_python_function(n integer)
RETURNS text AS $$
    import sys
    import traceback
    
    debug_output = []
    
    try:
        # Intentional error for demonstration
        result = 100 / n
        debug_output.append(f"Result: {result}")
    except Exception as e:
        debug_output.append(f"Error: {str(e)}")
        debug_output.append(f"Python version: {sys.version}")
        debug_output.append(f"Traceback: {traceback.format_exc()}")
    
    return "\n".join(debug_output)
$$ LANGUAGE plpython3u;

-- Test with valid input
SELECT debug_python_function(5);

-- Test with error-causing input
SELECT debug_python_function(0);
```

#### Debugging PL/Perl

```sql
CREATE OR REPLACE FUNCTION debug_perl_function(n integer)
RETURNS text AS $$
    my $n = shift;
    my @debug = ();
    
    push @debug, "Perl version: $]";
    
    eval {
        # Intentional error for demonstration
        my $result = 100 / $n;
        push @debug, "Result: $result";
    };
    
    if ($@) {
        push @debug, "Error: $@";
    }
    
    return join("\n", @debug);
$$ LANGUAGE plperl;

-- Test with valid input
SELECT debug_perl_function(5);

-- Test with error-causing input
SELECT debug_perl_function(0);
```

#### Debugging C Functions

C functions require more sophisticated debugging:

1. Add debug logging in the C code:

```c
elog(NOTICE, "Debug: variable value is %d", some_variable);
```

2. Compile with debug symbols:

```bash
gcc -g -fPIC -I$(pg_config --includedir-server) -c function.c
```

3. Use gdb for core dumps:

```bash
gdb $(which postgres) /path/to/core
```

### Best Practices

#### Language Selection Guidelines

**Key Points**:

- Use PL/pgSQL for basic database logic (triggers, simple functions)
- Choose Python for data science, machine learning, or complex algorithms
- Select Perl for text processing and log analysis
- Use C for performance-critical operations and low-level system integration

#### Code Organization and Maintainability

```sql
-- Create schema for functions
CREATE SCHEMA IF NOT EXISTS custom_functions;

-- Group related functions
CREATE OR REPLACE FUNCTION custom_functions.array_stats(data float[])
RETURNS json
AS $$
    import numpy as np
    import json
    # Function implementation
$$ LANGUAGE plpython3u;

-- Documentation comments
COMMENT ON FUNCTION custom_functions.array_stats(float[]) IS 
'Calculates statistical metrics on an array of floating-point values.
Returns a JSON object with keys: mean, median, std_dev, min, max, q1, q3.
Example: SELECT custom_functions.array_stats(ARRAY[1.0, 2.0, 3.0, 4.0, 5.0]);';
```

#### Error Handling Patterns

```sql
-- Python error handling
CREATE OR REPLACE FUNCTION robust_python_function(input_text text)
RETURNS json
AS $$
    import json
    import traceback
    
    try:
        # Main function logic
        result = process_data(input_text)
        return json.dumps({"status": "success", "data": result})
    except ValueError as e:
        # Handle specific error types
        plpy.notice(f"Value error: {str(e)}")
        return json.dumps({"status": "error", "error": str(e), "type": "value_error"})
    except Exception as e:
        # Log unexpected errors
        plpy.error(f"Unexpected error: {str(e)}\n{traceback.format_exc()}")
$$ LANGUAGE plpython3u;

-- Perl error handling
CREATE OR REPLACE FUNCTION robust_perl_function(input_text text)
RETURNS json
AS $$
    use JSON;
    
    my $input = shift;
    my $result;
    
    eval {
        # Main function logic
        $result = process_data($input);
    };
    
    if ($@) {
        return encode_json({
            status => "error",
            error => "$@"
        });
    }
    
    return encode_json({
        status => "success",
        data => $result
    });
$$ LANGUAGE plperl;
```

### Advanced Techniques

#### Combining Multiple Languages

```sql
-- Python wrapper around C function for pre/post processing
CREATE OR REPLACE FUNCTION enhanced_vector_operation(vectors float[][])
RETURNS json
AS $$
    import json
    
    # Preprocess data
    processed_vectors = []
    for vector in vectors:
        # Normalize vector
        if any(vector):  # Avoid division by zero
            norm = plpy.execute(f"SELECT vector_norm(ARRAY{vector}::float8[])")[0]["vector_norm"]
            processed_vectors.append([v/norm for v in vector])
        else:
            processed_vectors.append(vector)
    
    # Process results
    results = []
    for vector in processed_vectors:
        results.append({
            "original": vector,
            "magnitude": plpy.execute(f"SELECT vector_norm(ARRAY{vector}::float8[])")[0]["vector_norm"],
            "dimension": len(vector)
        })
    
    return json.dumps(results)
$$ LANGUAGE plpython3u;
```

#### Creating Dynamic SQL

```sql
CREATE OR REPLACE FUNCTION query_builder(
    table_name text,
    columns text[],
    conditions json
) RETURNS SETOF record
AS $$
    import json
    
    # Validate table name (prevent SQL injection)
    valid_tables = plpy.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
    valid_table_names = [t["table_name"] for t in valid_tables]
    
    if table_name not in valid_table_names:
        plpy.error(f"Invalid table name: {table_name}")
    
    # Validate columns
    valid_columns = plpy.execute(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table_name}'")
    valid_column_names = [c["column_name"] for c in valid_columns]
    
    for col in columns:
        if col not in valid_column_names:
            plpy.error(f"Invalid column name: {col}")
    
    # Build query
    column_list = ", ".join(columns)
    
    query = f"SELECT {column_list} FROM {table_name}"
    
    # Add conditions
    where_clauses = []
    params = []
    
    cond_data = json.loads(conditions)
    for i, (col, value) in enumerate(cond_data.items()):
        if col not in valid_column_names:
            plpy.error(f"Invalid column in condition: {col}")
        
        where_clauses.append(f"{col} = ${i+1}")
        params.append(value)
    
    if where_clauses:
        query += " WHERE " + " AND ".join(where_clauses)
    
    # Execute and return
    plan = plpy.prepare(query, [plpy.describe_cursor(params)[0]["type"] for param in params])
    return plpy.execute(plan, params)
$$ LANGUAGE plpython3u;

-- Usage
SELECT * FROM query_builder(
    'products', 
    ARRAY['product_id', 'name', 'price'], 
    '{"category_id": 5, "is_active": true}'
) AS (product_id int, name text, price numeric);
```

#### Using Trigger Functions

```sql
-- Create audit log table
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    table_name text NOT NULL,
    record_id integer,
    operation text NOT NULL,
    old_data jsonb,
    new_data jsonb,
    changed_by text,
    changed_at timestamp DEFAULT NOW()
);

-- Python-based trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS trigger
LANGUAGE plpythonu
AS $$
    import json

    # Get current user
    user_result = plpy.execute("SELECT current_user AS user")
    current_user = user_result[0]["user"]

    # Determine operation and prepare data
    if TD["event"] == "DELETE":
        operation = "DELETE"
        old_data = TD["old"]
        new_data = None
        record_id = TD["old"]["id"] if "id" in TD["old"] else None
    elif TD["event"] == "INSERT":
        operation = "INSERT"
        old_data = None
        new_data = TD["new"]
        record_id = TD["new"]["id"] if "id" in TD["new"] else None
    elif TD["event"] == "UPDATE":
        operation = "UPDATE"
        old_data = TD["old"]
        new_data = TD["new"]
        record_id = TD["new"]["id"] if "id" in TD["new"] else None

    # Insert audit record
    plpy.execute(
        """
        INSERT INTO audit_log 
            (table_name, record_id, operation, old_data, new_data, changed_by)
        VALUES
            (%s, %s, %s, %s, %s, %s)
        """ % (
            plpy.quote_literal(TG_TABLE_NAME),
            record_id if record_id is not None else 'NULL',
            plpy.quote_literal(operation),
            plpy.quote_literal(json.dumps(old_data) if old_data else None),
            plpy.quote_literal(json.dumps(new_data) if new_data else None),
            plpy.quote_literal(current_user)
        )
    )

    return None
$$;
```

- **`TG_TABLE_NAME`** is used to dynamically get the name of the table where the trigger is attached.
- **`TD["event"]`** tells whether it was an `INSERT`, `UPDATE`, or `DELETE`.
- **`TD["old"]`** and **`TD["new"]`** give you access to the row data before and after the change.
- **`plpy.quote_literal()`** is essential for safely embedding values in SQL strings to prevent SQL injection in PL/Python.
- The function uses `json.dumps()` to serialize row data into JSON for storage.

##### **Trigger Setup Example**

Attach it to any table like this:

```sql
CREATE TRIGGER users_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION audit_trigger_function();
```
    
---

##### **Updated Considerations (as of PostgreSQL 15+)**

- PL/Python is still supported but **PL/pgSQL** is often preferred due to security, ease of deployment, and performance.
- Instead of `plpy.quote_literal`, modern alternatives suggest using **parameterized queries** if available (which unfortunately PL/Python doesn’t fully support like PL/pgSQL or server-side languages).
- PostgreSQL 15 introduced **JSON_TABLE** for querying JSON more easily, which can help in reporting over the `audit_log`.

---

