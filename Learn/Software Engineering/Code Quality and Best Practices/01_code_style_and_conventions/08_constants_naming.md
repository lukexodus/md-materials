## Constants Naming


Constants are values that do not change during execution. They replace magic numbers and string literals, providing semantic meaning to raw data.

**Key Points**

- **SCREAMING_SNAKE_CASE:** The universal convention for constants is uppercase letters with underscores separating words.
    
- **Location:** Constants should be defined at the top of the file or in a dedicated configuration file/class.
    
- **Context:** If a constant is specific to a class, prefix it to indicate the association if the language doesn't support static class constants natively.
    
- **Semantics:** The name must reflect what the value _means_, not what the value _is_.
    

**Example**

- **Poor:** `FIVE = 5`, `MAX = 100`, `TIME = 3600`
    
- **Better:** `MAX_RETRY_ATTEMPTS = 5`, `DEFAULT_PAGE_SIZE = 100`, `CACHE_TTL_SECONDS = 3600`
    

---

