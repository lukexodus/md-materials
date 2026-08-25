## Private Members Naming


Private members are internal details hidden from the public API. Naming conventions here serve as a warning to consumers that these elements are volatile and subject to change without notice.

**Key Points**

- **Underscore Prefix:** The most common convention (Python, JavaScript/TypeScript convention, C# fields) is to prefix private members with a single underscore `_`.
    
- **Language Specifics:**
    
    - **Python:** `_internal` is a weak internal indicator; `__private` (double underscore) invokes name mangling.
        
    - **C#:** Fields are often `_camelCase` (e.g., `_logger`) to distinguish them from local variables and properties.
        
    - **Java:** Standard `camelCase` is used, relying on the `private` access modifier rather than naming prefixes.
        
- **Encapsulation:** The name should imply that the variable is state maintained by the object, not to be touched directly.
    

**Example**

- **Poor:** `variable`, `privateVar`
    
- **Better:** `_dbConnection`, `_isInitialized`, `__internalCache`

---

