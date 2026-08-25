## Parameterized Queries


### Architectural Mechanism and Execution Flow

Parameterized queries, also known as prepared statements, fundamentally alter the interaction model between the application layer and the database engine. Unlike dynamic SQL generation, which relies on string interpolation, parameterization enforces a strict separation of code (SQL logic) and data (user input).

1. **Prepare Phase:** The application sends the query template with placeholders (e.g., `?`, `:id`, `@name`) to the database management system (DBMS). The DBMS parses, compiles, and performs query optimization on this template. The resulting execution plan is cached.
    
2. **Bind Phase:** The application transmits the parameter values to the DBMS. These values are mapped directly to the placeholders in the pre-compiled statement.
    
3. **Execute Phase:** The DBMS executes the previously prepared statement using the bound values.
    

This separation ensures that the database treats bound parameters strictly as literal values, never as executable SQL commands. This renders the interpreter immune to SQL Injection (SQLi) payloads that attempt to alter the query structure (e.g., `' OR '1'='1`).

### Performance Implications

From a performance optimization perspective, parameterized queries provide significant advantages over ad-hoc SQL strings:

- **Query Plan Caching:** Most modern RDBMS (PostgreSQL, SQL Server, Oracle) use the query hash to look up cached execution plans. String interpolation generates unique hashes for every unique input (e.g., `SELECT * FROM users WHERE id = 1` vs. `SELECT * FROM users WHERE id = 2`), forcing the database to perform a hard parse for each request. Parameterized queries (`SELECT * FROM users WHERE id = ?`) generate a single hash, allowing the reuse of the execution plan (soft parse).
    
- **Reduced Bandwidth:** For batched operations, only the parameter data needs to be transmitted over the network for subsequent executions, rather than the full SQL string.
    
- **Latency:** While there is a slight overhead in the initial "prepare" round-trip, the amortization of parsing and optimization costs yields lower latency in high-throughput transactional systems.
    

### Type Safety and Data Integrity

Manual string escaping is error-prone and often fails to handle edge cases regarding data types. Parameterization leverages the underlying driver's protocol to ensure type fidelity:

- **Binary Data (BLOBs):** Parameterization handles the complexities of encoding binary streams without requiring Base64 conversion or hex escaping within the SQL string.
    
- **Temporal Types:** Date and timestamp formats are handled natively by the driver, abstracting away database-specific literal formats (e.g., `YYYY-MM-DD` vs `MM/DD/YYYY`).
    
- **Null Handling:** Explicit parameter binding allows for unambiguous `NULL` value insertion, preventing logic errors common in string concatenation where a null variable might become the string literal `"null"` or an empty string.
    

### Handling Dynamic Identifiers (The Limitation)

A critical architectural constraint is that bind parameters can only represent **literals** (values). They cannot substitute SQL identifiers such as:

- Table names
    
- Column names
    
- SQL keywords (e.g., `ASC`, `DESC`)
    

Attempting to parameterize identifiers results in syntax errors because the database compiler requires these identifiers to generate the query plan during the Prepare Phase.

Solution Pattern: Allow-listing

To handle dynamic table or column selection safely, implement an Allow-list (White-list) validation strategy in the application logic before query construction.

Java

```
// Anti-Pattern: String concatenation for table name
String sql = "SELECT * FROM " + userInputTable; // VULNERABLE

// Best Practice: Map verification
Map<String, String> allowedTables = Map.of(
    "users", "users_table",
    "orders", "orders_table"
);

String tableName = allowedTables.get(userInput);
if (tableName == null) throw new SecurityException("Invalid table");

String sql = "SELECT * FROM " + tableName + " WHERE id = ?";
```

### Advanced Edge Case: The `IN` Clause

Standard prepared statements often struggle with variable-length lists in `IN` clauses (e.g., `WHERE id IN (?, ?, ?)`), as the number of placeholders must match the array length, and changing the number of placeholders changes the query hash, potentially negating plan caching benefits.

**Optimized Approaches:**

1. **Array Binding:** Use database-specific array types (e.g., PostgreSQL `ANY(?)` syntax) to pass a single array parameter.
    
2. **Temporary Tables:** Insert values into a temporary table and use a `JOIN` or subquery.
    
3. **Static Padding:** Pad the parameter list to fixed sizes (e.g., 10, 20, 50) and fill unused slots with `NULL` or impossible values to minimize the number of unique query plans.
    

### Anti-Patterns and Pitfalls

1. **Second-Order Injection:** While parameterization prevents injection during the _immediate_ query, it does not sanitize the data stored in the database. If this data is later retrieved and used in a dynamic context (e.g., `eval()` in JavaScript, or concatenated into a new SQL query inside a stored procedure), injection is still possible.
    
2. **ORM Leaks:** using Object-Relational Mappers (ORMs) does not guarantee parameterization. Using "Raw SQL" features within ORMs (e.g., Hibernate `createNativeQuery`, Entity Framework `FromSqlRaw`) incorrectly can reintroduce vulnerabilities.
    
    - _Bad:_ `context.Database.ExecuteSqlRaw("UPDATE Users SET Name = '" + name + "'")`
        
    - _Good:_ `context.Database.ExecuteSqlRaw("UPDATE Users SET Name = {0}", name)`
        
3. **Truncation Errors:** In some legacy drivers, if a bound string exceeds the column definition, the driver might silently truncate it, potentially altering the logic of `WHERE` clauses (e.g., authentication checks). Explicit length validation should occur at the service layer.
    

### Implementation Standards (Polyglot)

Java (JDBC)

Use PreparedStatement over Statement. Ensure resources are closed via try-with-resources.

Java

```
String query = "UPDATE accounts SET balance = balance - ? WHERE id = ?";
try (Connection con = dataSource.getConnection();
     PreparedStatement pst = con.prepareStatement(query)) {
    pst.setBigDecimal(1, amount);
    pst.setInt(2, accountId);
    pst.executeUpdate();
}
```

C# (ADO.NET / Dapper)

Use SqlParameter to specify types explicitly, preventing implicit conversion penalties.

C#

```
using (SqlCommand command = new SqlCommand("SELECT * FROM Orders WHERE OrderDate > @Date", connection))
{
    command.Parameters.Add("@Date", SqlDbType.DateTime).Value = startDate;
    // ...
}
```

Node.js (pg)

PostgreSQL driver for Node uses ordinal placeholders ($1, $2).

JavaScript

```
const text = 'INSERT INTO users(name, email) VALUES($1, $2) RETURNING *';
const values = ['brianc', 'brian.m.carlson@gmail.com'];
const res = await client.query(text, values);
```

---

