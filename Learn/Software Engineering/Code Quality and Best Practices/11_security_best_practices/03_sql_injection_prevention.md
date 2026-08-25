## SQL Injection Prevention


### Architectural Theory of Prepared Statements

The fundamental flaw enabling SQL Injection (SQLi) is the commingling of control plane instructions (SQL keywords) and data plane inputs (user parameters) within a single serialized string. The parser cannot distinguish between intended commands and malicious payloads.

Prepared Statements (Parameterized Queries) mitigate this by decoupling the query structure from the data. The database driver sends the query template to the database engine first, where it is parsed, compiled, and optimized into an Abstract Syntax Tree (AST). User input is subsequently transmitted as raw data, strictly bound to the placeholders in the pre-compiled AST. This ensures input is treated strictly as literals, rendering payload execution impossible regardless of syntax characters present.

### Dynamic Identifier Handling (The "ORDER BY" Problem)

Standard parameterization does not support database identifiers (table names, column names, sort orders) because these elements alter the query plan and AST structure. A common anti-pattern is reverting to string concatenation for dynamic sorting or filtering.

Correct Implementation: Allow-listing (Whitelisting)

Map user inputs to internal, hardcoded constants. Never interpolate user input directly into the identifier slots.

Java

```
// Anti-Pattern: Vulnerable to SQLi
String query = "SELECT * FROM users ORDER BY " + userInput; 

// Architectural Standard: Allow-listing via Map
private static final Map<String, String> SORT_COLUMNS = Map.of(
    "name", "last_name",
    "date", "created_at",
    "score", "reputation"
);

String sortCol = SORT_COLUMNS.getOrDefault(userInput, "id"); // Default to safe fallback
String query = "SELECT * FROM users ORDER BY " + sortCol;
```

### Object-Relational Mapping (ORM) Vulnerabilities

While ORMs like Hibernate, Entity Framework, or Eloquent default to parameterization, they remain susceptible to injection when developers bypass abstraction layers for performance or complex logic.

- **HQL/JPQL Injection:** Concatenating strings into ORM query languages allows injection similar to standard SQL.
    
    - _Remediation:_ Use named parameters (`:paramName`) within the ORM query builder.
        
- **Raw SQL Fragments:** Methods exposing raw SQL interfaces (e.g., `EntityFramework.FromSqlRaw`, `ActiveRecord::Base.connection.execute`) require manual parameterization.
    
    - _Strict Rule:_ Audit all usages of raw SQL methods. Enforce wrappers that mandate parameter arrays.
        

### Second-Order SQL Injection

This vector occurs when malicious input is successfully stored in the database (sanitized or trusted) and subsequently retrieved and used in a new query without re-parameterization.

**Scenario:**

1. Attacker registers username `admin' --`.
    
2. Input is parameterized during `INSERT`, storing the literal string.
    
3. Admin script retrieves username and concatenates it: `UPDATE users SET password='new' WHERE username='` + retrievedUsername + `'`.
    
4. The query becomes `... WHERE username='admin' --'`.
    

**Mitigation:** Treat all data retrieved from the database as untrusted. Apply parameterization rigorously to read operations, internal data transfers, and ETL processes, not just HTTP ingress points.

### Advanced Edge Cases

#### Charset and Encoding Bypasses

If the application and database differ in character set handling (e.g., GBK vs. UTF-8), specific byte sequences can consume the backslash used in escaping, effectively un-escaping a quote character.

- **Defense:** Enforce consistent character encoding (UTF-8) across the full stack (Application Server, JDBC/ODBC Driver, Database Collation). Disable "gbk" or multi-byte encodings in database connections unless strictly necessary and handled by a driver aware of the encoding's escaping rules.
    

#### LIKE Clause Wildcard DoS

While not direct command execution, unchecked user input in `LIKE` clauses allows injection of wildcard characters (`%`, `_`).

- **Risk:** An attacker submits `%%%%%...`, causing a full table scan or high CPU usage (ReDoS equivalent in SQL).
    
- **Remediation:** Escape wildcard characters in the application layer _before_ binding the parameter.
    
    C#
    
    ```
    // C# Example
    string searchTerm = input.Replace("[", "[[]").Replace("%", "[%]").Replace("_", "[_]");
    cmd.Parameters.AddWithValue("@param", "%" + searchTerm + "%");
    ```
    

### Stored Procedures and Logical Encapsulation

Stored procedures are not an automatic silver bullet.

- **Vulnerable:** Procedures using `EXEC` or `sp_executesql` (SQL Server) or `EXECUTE IMMEDIATE` (Oracle/PostgreSQL) with concatenated strings are fully vulnerable.
    
- **Secure:** Procedures must utilize parameters defined in their signature.
    
- **Benefit:** They allow the removal of `SELECT/INSERT/UPDATE/DELETE` permissions from the application user, granting `EXECUTE` only. This enforces the Principle of Least Privilege, limiting the blast radius if the application server is compromised.
    

### Static Application Security Testing (SAST) Integration

Automated code quality gates must be configured to detect injection patterns.

- **Semgrep / CodeQL:** Configure rules to flag string concatenation used in variable assignment passed to `executeQuery`, `execute`, or ORM equivalents.
    
- **Taint Analysis:** Track variables from "Source" (HTTP Request) to "Sink" (Database Driver). Flaws are flagged if the path does not traverse a "Sanitizer" or parameterization function.
    

Related topics: Cross-Site Scripting (XSS) Prevention, Database Security Hardening, Query Performance Optimization, Input Validation Strategy.

---

