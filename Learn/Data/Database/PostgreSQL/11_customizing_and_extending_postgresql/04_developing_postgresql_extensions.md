## Developing PostgreSQL Extensions


### Understanding PostgreSQL Extensions

PostgreSQL extensions are packages that enhance the database with new functionality without modifying the core PostgreSQL codebase. Extensions provide a standardized way to add features, functions, data types, operators, and more while maintaining compatibility across PostgreSQL versions and simplifying deployment.

**Key Points:**

- Extensions separate optional functionality from core PostgreSQL
- They follow a standard framework for installation, upgrade, and removal
- Extensions can include SQL functions, C code, data types, operators, and more
- They enable seamless upgrades and migrations of additional functionality
- Well-designed extensions help solve specialized problems while maintaining compatibility

### Extension Architecture

### Extension Components

A complete PostgreSQL extension typically consists of:

1. **Control file** (`extension_name.control`): Contains metadata about the extension
2. **SQL scripts** (`extension_name--version.sql`): Define database objects
3. **Shared libraries** (`.so` or `.dll` files): Implement C functions (optional)
4. **Regression tests**: Verify extension functionality
5. **Documentation**: Explain usage and configuration

### Extension Control File

The control file specifies extension properties:

```
# myextension.control
comment = 'My custom PostgreSQL extension'
default_version = '1.0'
relocatable = true
module_pathname = '$libdir/myextension'
requires = 'another_extension'
```

Key parameters include:

- `comment`: Description of the extension
- `default_version`: Version installed by default
- `relocatable`: Whether the extension can be moved between schemas
- `module_pathname`: Path to the shared library (if any)
- `requires`: Dependencies on other extensions

### SQL-Only Extensions

Simpler extensions may use only SQL with no C code:

```sql
-- myextension--1.0.sql
-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION myextension" to load this file. \quit

-- Create supporting structures
CREATE SCHEMA IF NOT EXISTS myextension;

-- Create functions
CREATE FUNCTION myextension.hello_world()
RETURNS text AS $$
BEGIN
    RETURN 'Hello, World!';
END;
$$ LANGUAGE plpgsql;

-- Register functions with the extension
COMMENT ON FUNCTION myextension.hello_world() IS 'Provided by myextension';
```

### Extension Version Management

Extensions use versioned SQL scripts for upgrades:

```
myextension--1.0.sql      # Initial version
myextension--1.0--1.1.sql # Upgrade from 1.0 to 1.1
myextension--1.1--2.0.sql # Upgrade from 1.1 to 2.0
```

### Creating a Basic SQL Extension

### Project Structure

A minimal SQL-only extension project:

```
myextension/
├── Makefile
├── myextension.control
├── myextension--1.0.sql
├── README.md
└── test/
    └── sql/
        └── basic_test.sql
```

### Basic Makefile for SQL Extensions

```makefile
EXTENSION = myextension
DATA = myextension--1.0.sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
```

This Makefile uses PostgreSQL's extension building infrastructure (PGXS) to manage installation.

### Installation and Testing

```bash
# Build and install
make
make install

# Create extension in database
psql -d mydb -c "CREATE EXTENSION myextension;"

# Test the extension
psql -d mydb -c "SELECT myextension.hello_world();"
```

### Developing C-Based Extensions

### Project Structure for C Extensions

```
myextension/
├── Makefile
├── myextension.c
├── myextension.control
├── myextension--1.0.sql
├── README.md
└── test/
    └── sql/
        └── basic_test.sql
```

### C Extension Development Environment

Required tools and resources:

1. PostgreSQL server and client packages
2. PostgreSQL development packages (headers)
3. C compiler (gcc/clang)
4. Make utility
5. PostgreSQL source code (for reference)

```bash
# Ubuntu/Debian
sudo apt install postgresql-server-dev-14 build-essential

# RHEL/CentOS
sudo dnf install postgresql-devel gcc make
```

### Basic C Extension Structure

```c
// myextension.c
#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"

PG_MODULE_MAGIC;

// Function declaration
PG_FUNCTION_INFO_V1(hello_world);

// Implementation
Datum
hello_world(PG_FUNCTION_ARGS)
{
    return CStringGetTextDatum("Hello, World from C!");
}
```

### Makefile for C Extensions

```makefile
EXTENSION = myextension
EXTVERSION = 1.0

MODULE_big = myextension
OBJS = myextension.o

DATA = myextension--$(EXTVERSION).sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
```

### SQL Script for C Extension

```sql
-- myextension--1.0.sql
\echo Use "CREATE EXTENSION myextension" to load this file. \quit

-- Create function linked to C implementation
CREATE FUNCTION hello_world()
RETURNS text
AS '$libdir/myextension', 'hello_world'
LANGUAGE C STRICT;
```

### Building and Installing C Extensions

```bash
# Build the extension
make

# Install extension files
sudo make install

# Create extension in database
psql -d mydb -c "CREATE EXTENSION myextension;"
```

### Core Extension Development Concepts

### Creating Custom Data Types

```c
// In C file
PG_FUNCTION_INFO_V1(my_type_in);
PG_FUNCTION_INFO_V1(my_type_out);

Datum my_type_in(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    // Parse input and create internal representation
    MyType *result = parse_my_type(str);
    PG_RETURN_POINTER(result);
}

Datum my_type_out(PG_FUNCTION_ARGS)
{
    MyType *my_val = (MyType *) PG_GETARG_POINTER(0);
    char *result = convert_to_string(my_val);
    PG_RETURN_CSTRING(result);
}
```

```sql
-- In SQL file
CREATE TYPE my_custom_type (
    INTERNALLENGTH = 16,
    INPUT = my_type_in,
    OUTPUT = my_type_out,
    ALIGNMENT = double
);
```

### Implementing Custom Operators

```sql
-- Define operator function
CREATE FUNCTION my_custom_add(my_custom_type, my_custom_type)
RETURNS my_custom_type
AS '$libdir/myextension', 'my_custom_add_function'
LANGUAGE C IMMUTABLE STRICT;

-- Create operator
CREATE OPERATOR + (
    LEFTARG = my_custom_type,
    RIGHTARG = my_custom_type,
    PROCEDURE = my_custom_add
);
```

### Adding Index Support

```c
// Support function declarations
PG_FUNCTION_INFO_V1(my_type_cmp);
PG_FUNCTION_INFO_V1(my_type_hash);

// Implementation for comparison
Datum
my_type_cmp(PG_FUNCTION_ARGS)
{
    MyType *a = (MyType *) PG_GETARG_POINTER(0);
    MyType *b = (MyType *) PG_GETARG_POINTER(1);
    int result = compare_my_types(a, b);
    PG_RETURN_INT32(result);
}

// Implementation for hashing
Datum
my_type_hash(PG_FUNCTION_ARGS)
{
    MyType *a = (MyType *) PG_GETARG_POINTER(0);
    uint32 hash = compute_hash(a);
    PG_RETURN_UINT32(hash);
}
```

```sql
-- Create operator class for btree
CREATE OPERATOR CLASS my_type_ops
DEFAULT FOR TYPE my_custom_type USING btree AS
    OPERATOR 1 < ,
    OPERATOR 2 <= ,
    OPERATOR 3 = ,
    OPERATOR 4 >= ,
    OPERATOR 5 > ,
    FUNCTION 1 my_type_cmp(my_custom_type, my_custom_type);

-- Create operator class for hash
CREATE OPERATOR CLASS my_type_hash_ops
DEFAULT FOR TYPE my_custom_type USING hash AS
    OPERATOR 1 = ,
    FUNCTION 1 my_type_hash(my_custom_type);
```

### Memory Management in C Extensions

Proper memory management is crucial for stable extensions:

```c
// Allocate memory in the current memory context
void *ptr = palloc(size);

// Allocate zero-initialized memory
void *ptr = palloc0(size);

// Free memory (rarely needed explicitly)
pfree(ptr);

// Create a longer-lived memory context
MemoryContext old_context = MemoryContextSwitchTo(TopMemoryContext);
void *long_lived_ptr = palloc(size);
MemoryContextSwitchTo(old_context);
```

### Error Handling in C Extensions

```c
// Report an error
ereport(ERROR,
        (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
         errmsg("invalid parameter value: %s", input_value),
         errhint("Value must be between 1 and 100.")));

// Produce a warning
ereport(WARNING,
        (errmsg("deprecated function used"),
         errhint("Use new_function() instead.")));
```

### Advanced Extension Development

### Background Workers

Extensions can register background worker processes:

```c
// In _PG_init function
BackgroundWorker worker;

MemSet(&worker, 0, sizeof(BackgroundWorker));
worker.bgw_name = "My Extension Worker";
worker.bgw_flags = BGWORKER_SHMEM_ACCESS | BGWORKER_BACKEND_DATABASE_CONNECTION;
worker.bgw_start_time = BgWorkerStart_RecoveryFinished;
worker.bgw_restart_time = BGW_NEVER_RESTART;
worker.bgw_main_arg = 0;
worker.bgw_notify_pid = 0;
worker.bgw_main = my_background_main;

RegisterBackgroundWorker(&worker);
```

### Hook Functions

Extensions can intercept core PostgreSQL operations using hooks:

```c
// Store original hook
static check_password_hook_type prev_check_password_hook = NULL;

// Custom password check function
static bool
my_check_password_hook(const char *username, const char *password,
                       PasswordType password_type, Datum validuntil_time,
                       bool validuntil_null)
{
    // Custom password validation logic
    if (strlen(password) < 8)
        ereport(ERROR,
                (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
                 errmsg("password is too short")));

    // Call previous hook if any
    if (prev_check_password_hook &&
        !(*prev_check_password_hook)(username, password, password_type,
                                    validuntil_time, validuntil_null))
        return false;

    return true;
}

// Initialize hook in _PG_init
void
_PG_init(void)
{
    // Save previous hook and install our hook
    prev_check_password_hook = check_password_hook;
    check_password_hook = my_check_password_hook;
}
```

### Custom GUC Parameters

Extensions can add custom configuration parameters:

```c
// Global variable for the configuration
static int my_parameter = 100;

// Register parameter in _PG_init
void
_PG_init(void)
{
    DefineCustomIntVariable("myextension.parameter",
                          "Sets the behavior of myextension",
                          NULL,
                          &my_parameter,
                          100,
                          0,
                          1000,
                          PGC_USERSET,
                          0,
                          NULL,
                          NULL,
                          NULL);
}
```

### Extension Testing

### Regression Testing

Create comprehensive tests in the `test/sql` directory:

```sql
-- test/sql/basic_test.sql
\set ECHO none
\set QUIET 1

-- Load the extension
CREATE EXTENSION myextension;

-- Test functions
SELECT is(hello_world(), 'Hello, World!', 'hello_world() returns greeting');

-- Test with various inputs
SELECT hello_custom('PostgreSQL');
SELECT hello_custom(NULL);

-- Test edge cases
SELECT my_function(2147483647);  -- INT_MAX
SELECT my_function(-2147483648); -- INT_MIN

-- Clean up
DROP EXTENSION myextension;
```

### Using pgTAP for Testing

pgTAP provides a TAP-compliant testing framework:

```sql
-- Install pgTAP
CREATE EXTENSION pgtap;

-- Write test file
BEGIN;
SELECT plan(3);

-- Test extension creation
SELECT has_extension('myextension');

-- Test function existence
SELECT has_function('myextension.hello_world');

-- Test function result
SELECT is(
    myextension.hello_world(),
    'Hello, World!',
    'hello_world() should return greeting'
);

SELECT * FROM finish();
ROLLBACK;
```

Run tests with:

```bash
pg_prove -d mydb test/sql/
```

### Extension Distribution and Publication

### Packaging Extensions

Create distribution packages:

```bash
# Create tarball
make dist

# Create installable package (Debian example)
make deb
```

### Submitting to PGXN

The PostgreSQL Extension Network (PGXN) is a repository for distributing extensions:

1. Create a `META.json` file:

```json
{
    "name": "myextension",
    "abstract": "A simple PostgreSQL extension",
    "description": "This extension provides additional functionality for PostgreSQL.",
    "version": "1.0.0",
    "maintainer": "Your Name <your.email@example.com>",
    "license": "postgresql",
    "provides": {
        "myextension": {
            "abstract": "A simple PostgreSQL extension",
            "file": "sql/myextension--1.0.sql",
            "docfile": "README.md",
            "version": "1.0.0"
        }
    },
    "resources": {
        "repository": {
            "url": "https://github.com/yourusername/myextension.git",
            "web": "https://github.com/yourusername/myextension",
            "type": "git"
        }
    },
    "meta-spec": {
        "version": "1.0.0",
        "url": "https://pgxn.org/meta/spec.txt"
    },
    "tags": [
        "function",
        "utility"
    ]
}
```

2. Create a release on PGXN:

```bash
pgxn release myextension-1.0.0.zip
```

### Best Practices for Extension Development

1. Follow PostgreSQL coding standards
2. Include extensive documentation
3. Provide upgrade paths between versions
4. Handle errors gracefully
5. Use appropriate memory contexts
6. Implement thorough tests
7. Consider cross-version compatibility
8. Optimize for performance
9. Build with warning flags enabled
10. Include example usage scenarios

### Common Extension Development Patterns

### Extension with Public and Private Functions

```sql
-- Create schemas for public and private functions
CREATE SCHEMA myextension;
CREATE SCHEMA myextension_internal;

-- Create public function
CREATE FUNCTION myextension.public_function(text)
RETURNS text AS $$
    SELECT myextension_internal.helper_function($1);
$$ LANGUAGE sql;

-- Create private helper function
CREATE FUNCTION myextension_internal.helper_function(text)
RETURNS text AS $$
BEGIN
    RETURN 'Processed: ' || $1;
END;
$$ LANGUAGE plpgsql;

-- Restrict access to internal schema
REVOKE ALL ON SCHEMA myextension_internal FROM PUBLIC;
```

### Extension with Configuration Table

```sql
-- Create configuration table
CREATE TABLE myextension.configuration (
    key text PRIMARY KEY,
    value text NOT NULL,
    description text,
    last_modified timestamp with time zone DEFAULT now()
);

-- Add default configuration
INSERT INTO myextension.configuration (key, value, description)
VALUES
    ('max_items', '100', 'Maximum number of items to process'),
    ('log_level', 'info', 'Logging verbosity (debug, info, warning, error)');

-- Create configuration access function
CREATE FUNCTION myextension.get_config(config_key text)
RETURNS text AS $$
    SELECT value FROM myextension.configuration WHERE key = config_key;
$$ LANGUAGE sql;
```

### Extension Upgrade Example

```sql
-- myextension--1.0--1.1.sql
-- Add new function
CREATE FUNCTION myextension.new_function()
RETURNS text AS $$
BEGIN
    RETURN 'New function in version 1.1';
END;
$$ LANGUAGE plpgsql;

-- Modify existing function
CREATE OR REPLACE FUNCTION myextension.existing_function()
RETURNS text AS $$
BEGIN
    -- Updated implementation
    RETURN 'Updated in version 1.1';
END;
$$ LANGUAGE plpgsql;

-- Update version number in metadata
UPDATE pg_catalog.pg_extension
SET extversion = '1.1'
WHERE extname = 'myextension';
```

### Real-World Extension Development Examples

### Example: Custom Aggregation Function

```c
// myagg.c
#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "utils/array.h"

PG_MODULE_MAGIC;

// State for the aggregate
typedef struct {
    int count;
    double total;
} MyAggState;

// Transition function
PG_FUNCTION_INFO_V1(myagg_trans);
Datum
myagg_trans(PG_FUNCTION_ARGS)
{
    MyAggState *state;
    
    // Get or create state
    if (PG_ARGISNULL(0)) {
        state = (MyAggState *) palloc0(sizeof(MyAggState));
    } else {
        state = (MyAggState *) PG_GETARG_POINTER(0);
    }
    
    // Add value if not null
    if (!PG_ARGISNULL(1)) {
        double value = PG_GETARG_FLOAT8(1);
        state->count++;
        state->total += value;
    }
    
    PG_RETURN_POINTER(state);
}

// Final function
PG_FUNCTION_INFO_V1(myagg_final);
Datum
myagg_final(PG_FUNCTION_ARGS)
{
    MyAggState *state;
    
    // Handle null case (no rows)
    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();
        
    state = (MyAggState *) PG_GETARG_POINTER(0);
    
    // Handle empty case
    if (state->count == 0)
        PG_RETURN_NULL();
        
    // Return average
    PG_RETURN_FLOAT8(state->total / state->count);
}
```

SQL definition:

```sql
-- Create aggregate function
CREATE AGGREGATE myextension.myavg(double precision) (
    SFUNC = myagg_trans,
    STYPE = internal,
    FINALFUNC = myagg_final,
    FINALFUNC_EXTRA
);
```

### Example: Custom Index Access Method

Creating a custom index type requires several components:

1. Access method handlers
2. Index build, scan, and maintenance functions
3. Storage and memory management

```c
// Index handler function
PG_FUNCTION_INFO_V1(myindex_handler);
Datum
myindex_handler(PG_FUNCTION_ARGS)
{
    IndexAmRoutine *amroutine = makeNode(IndexAmRoutine);
    
    // Fill in handler function pointers
    amroutine->amstrategies = 5;     // Number of strategies (operators)
    amroutine->amsupport = 2;        // Number of support functions
    amroutine->amcanorder = false;   // Does AM support ordered scans?
    amroutine->amcanorderbyop = false; // Does AM support order by operator result?
    amroutine->amcanbackward = false; // Does AM support backward scanning?
    amroutine->amcanunique = false;  // Does AM support unique indexes?
    amroutine->amcanmulticol = true; // Does AM support multi-column indexes?
    amroutine->amoptionalkey = true; // Can scan without index qualification?
    amroutine->amsearcharray = false; // Does AM support ScalarArrayOpExpr quals?
    amroutine->amsearchnulls = true; // Does AM support IS NULL/NOT NULL quals?
    amroutine->amstorage = false;    // Does AM need custom storage?
    amroutine->amclusterable = false; // Can index be clustered on?
    amroutine->ampredlocks = false;  // Does AM handle predicate locks?
    amroutine->amcanparallel = false; // Does AM support parallel scan?
    amroutine->amcaninclude = false; // Does AM support INCLUDE columns?
    
    // Set handler functions
    amroutine->ambuild = myindex_build;
    amroutine->ambuildempty = myindex_buildempty;
    amroutine->aminsert = myindex_insert;
    amroutine->ambulkdelete = myindex_bulkdelete;
    amroutine->amvacuumcleanup = myindex_vacuumcleanup;
    amroutine->amcanreturn = NULL;
    amroutine->amcostestimate = myindex_costestimate;
    amroutine->amoptions = myindex_options;
    amroutine->ambeginscan = myindex_beginscan;
    amroutine->amrescan = myindex_rescan;
    amroutine->amgettuple = myindex_gettuple;
    amroutine->amgetbitmap = myindex_getbitmap;
    amroutine->amendscan = myindex_endscan;

    PG_RETURN_POINTER(amroutine);
}
```

SQL definition:

```sql
-- Create access method
CREATE ACCESS METHOD myindex TYPE INDEX HANDLER myindex_handler;

-- Create operator class
CREATE OPERATOR CLASS myindex_ops
DEFAULT FOR TYPE text USING myindex AS
    OPERATOR 1 <,
    OPERATOR 2 <=,
    OPERATOR 3 =,
    OPERATOR 4 >=,
    OPERATOR 5 >,
    FUNCTION 1 myindex_cmp(text, text),
    FUNCTION 2 myindex_hash(text);
```

### Troubleshooting Extension Development

### Common Issues and Solutions

**Problem**: "ERROR: could not access file $libdir/myextension: No such file or directory" **Solution**: Check that the shared library was installed correctly and the `module_pathname` is set correctly in the control file.

**Problem**: "ERROR: function X does not exist" **Solution**: Ensure the function is properly declared in both C and SQL files, and that the SQL file was installed correctly.

**Problem**: Memory leaks **Solution**: Use appropriate memory context management and valgrind for testing.

### Debugging Techniques

1. Add debug messages:

```c
elog(DEBUG1, "Processing value: %d", value);
```

2. Use assertions:

```c
Assert(value >= 0 && value <= 100);
```

3. Enable verbose logging:

```bash
# postgresql.conf
log_min_messages = debug1
```

4. Use GDB for debugging:

```bash
gdb --args postgres -D /path/to/data
```

5. Check extension loading:

```sql
SELECT * FROM pg_extension WHERE extname = 'myextension';
SELECT * FROM pg_proc WHERE proname LIKE 'myextension%';
```

### Advanced Extension Examples

### Example: Full-Text Search Dictionary

```c
// Dictionary handler function
PG_FUNCTION_INFO_V1(my_dict_init);
Datum
my_dict_init(PG_FUNCTION_ARGS)
{
    ListCell   *l;
    List       *options = (List *) PG_GETARG_POINTER(0);
    MyDictData *d = (MyDictData *) palloc0(sizeof(MyDictData));
    
    // Process options
    foreach(l, options)
    {
        DefElem    *defel = (DefElem *) lfirst(l);
        
        if (strcmp(defel->defname, "dictionary") == 0)
        {
            d->dict_name = defGetString(defel);
        }
    }
    
    // Initialize dictionary data
    // ...
    
    PG_RETURN_POINTER(d);
}

// Lexize function
PG_FUNCTION_INFO_V1(my_dict_lexize);
Datum
my_dict_lexize(PG_FUNCTION_ARGS)
{
    MyDictData *d = (MyDictData *) PG_GETARG_POINTER(0);
    char       *in = (char *) PG_GETARG_POINTER(1);
    int32       len = PG_GETARG_INT32(2);
    char       *txt = pnstrdup(in, len);
    
    // Process the word
    // ...
    
    // Return results as TSLexeme array
    if (result_tokens == 0)
        PG_RETURN_POINTER(NULL);
        
    TSLexeme   *res = palloc0((result_tokens + 1) * sizeof(TSLexeme));
    
    // Fill in lexemes
    // ...
    
    PG_RETURN_POINTER(res);
}
```

SQL definition:

```sql
-- Create text search template
CREATE TEXT SEARCH TEMPLATE my_template (
    INIT = my_dict_init,
    LEXIZE = my_dict_lexize
);

-- Create dictionary
CREATE TEXT SEARCH DICTIONARY my_dictionary (
    TEMPLATE = my_template,
    dictionary = 'english'
);

-- Create text search configuration
CREATE TEXT SEARCH CONFIGURATION my_config (
    PARSER = pg_catalog.default
);

-- Associate dictionary with configuration
ALTER TEXT SEARCH CONFIGURATION my_config
    ADD MAPPING FOR asciiword WITH my_dictionary;
```

### Resources for PostgreSQL Extension Development

1. PostgreSQL Documentation:
    - [Extending SQL](https://www.postgresql.org/docs/current/extend.html)
    - [C-Language Functions](https://www.postgresql.org/docs/current/xfunc-c.html)
    - [Procedural Languages](https://www.postgresql.org/docs/current/xplang.html)
2. Books:
    - "PostgreSQL Development Essentials"
    - "PostgreSQL 14 Administration Cookbook"
3. Online Resources:
    - [PostgreSQL Extension Network (PGXN)](https://pgxn.org/)
    - [PostgreSQL Wiki on Extensions](https://wiki.postgresql.org/wiki/Extension_Development)
    - [GitHub PostgreSQL Extension Template](https://github.com/omniti-labs/pg_extension_template)
4. Community Forums:
    - [PostgreSQL Mailing Lists](https://www.postgresql.org/list/)
    - [Stack Overflow PostgreSQL Tag](https://stackoverflow.com/questions/tagged/postgresql)
5. Example Extensions (Source Code Study):
    - [PostGIS](https://github.com/postgis/postgis)
    - [pgcrypto](https://github.com/postgres/postgres/tree/master/contrib/pgcrypto)
    - [hstore](https://github.com/postgres/postgres/tree/master/contrib/hstore)

---

