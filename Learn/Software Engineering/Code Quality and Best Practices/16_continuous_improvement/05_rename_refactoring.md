## Rename Refactoring


### Semantic Alignment and Intent

Rename Refactoring is the process of altering symbol identifiers (variables, functions, classes, modules) to accurately reflect their current runtime behavior, scope, and domain context. In high-quality codebases, identifiers must adhere to the **Principle of Least Astonishment**. As business logic evolves, variable names often drift from their original intent, creating "semantic distance" that increases cognitive load and defect rates.

Renaming is not a cosmetic change; it is a structural modification of the code's semantic contract. A discrepancy between a symbol's name and its function (e.g., `getUser()` actually returning a `UserPermission` object) is a critical technical debt vector known as **Linguistic Antipatterns**.

### Abstract Syntax Tree (AST) vs. Textual Replacement

Enterprise-grade renaming operations must rely on AST analysis rather than lexical (text-based) search and replace.

- **Scope Awareness:** Textual replacement fails to respect lexical scoping rules. Renaming a global variable `i` to `index` via text search will incorrectly mutate local loop iterators named `i` in unrelated namespaces.
    
- **Shadowing Detection:** AST-based refactoring tools (powered by Language Server Protocols like LSP) detect variable shadowing. If a rename operation creates a collision where a local variable hides a variable in the outer scope, the refactoring tool must abort or warn.
    
- **Reference Integrity:** Renaming must propagate to all references, including:
    
    - Docstrings and comments (heuristic-based).
        
    - String literals (if reflecting reflection-based usage).
        
    - Type hints and dependency injection containers.
        

### Strategy for Public API Refactoring

Renaming symbols exposed in a public API constitutes a **Breaking Change**. To maintain backward compatibility and service availability, the **Parallel Change (Expand-Contract)** pattern must be employed.

Phase 1: Expand (Aliasing)

Introduce the new name while retaining the old name as a proxy wrapper. This ensures zero downtime and allows consumers to upgrade asynchronously.

Python

```
# Old implementation
def fetch_client_data(id):
    # ... logic ...
    pass

# Refactored implementation
def retrieve_customer_profile(id):
    # ... logic ...
    pass

# Backward compatibility shim
@deprecated("Use retrieve_customer_profile instead")
def fetch_client_data(id):
    return retrieve_customer_profile(id)
```

Phase 2: Migrate

Update all internal calls within the owning codebase to use the new signature.

Phase 3: Contract (Cleanup)

After a defined deprecation window (e.g., one major version cycle), remove the alias.

### Database Schema Renaming

Renaming columns or tables in a production database is a high-risk operation that requires decoupling the schema change from the application deployment.

**The Migration Triad:**

1. **Additive Change:** Add the new column `new_name`.
    
2. **Dual Write:** Update application logic to write to _both_ `old_name` and `new_name`, while reading from `old_name`. Backfill `new_name` with historical data.
    
3. **Switch Read:** Update application logic to read from `new_name`.
    
4. **Destructive Change:** Remove `old_name` once usage metrics hit zero.
    

Directly renaming a column via `ALTER TABLE RENAME COLUMN` causes immediate downtime for any active application instances still issuing queries against the old schema.

### Version Control Implications

Git tracks file history based on content heuristics. Renaming a file (class/module) can sever the history graph if the similarity index drops below the threshold (default 50%).

- **Atomic Renames:** When renaming a file, avoid modifying significant logic in the same commit. This assists `git log --follow` in tracking the file's lineage.
    
- **Blame integrity:** Extensive renaming of variables within a file can pollute `git blame` data, attributing lines to the refactorer rather than the original author. This trade-off is acceptable for clarity but should be noted in commit messages (`Refactor: Rename variable X to Y for clarity`).
    

### Anti-Patterns in Naming

- **Type Encoding (Hungarian Notation):** Avoid prefixes like `strName` or `iCount` in modern strongly-typed or type-hinted languages. It adds noise and creates maintenance overhead if types change.
    
- **Noise Words:** Suffixes like `Info`, `Data`, or `Manager` often indicate ill-defined responsibilities (God Classes). Renaming `UserManager` to `UserAuthenticator` or `UserRepository` clarifies intent.
    
- **Inconsistent Vocabulary:** Do not mix synonyms across the architecture (e.g., `fetch`, `retrieve`, `get`, `load`). Enforce a "Ubiquitous Language" derived from Domain-Driven Design (DDD).

---

