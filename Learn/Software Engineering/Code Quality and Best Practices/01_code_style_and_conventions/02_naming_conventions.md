## Naming Conventions


Naming conventions form the semantic structure of a codebase, acting as the primary documentation for intent and logic. Effective naming reduces cognitive load, minimizes the need for comments, and facilitates maintainability by making code self-explanatory.

**Key Points**

- **Intent-Revealing Names:** identifiers must answer why they exist, what they do, and how they are used. If a name requires a comment to explain its purpose, the name is likely insufficient.
    
- ** consistency:** Adhere strictly to the chosen capitalization strategy (CamelCase, snake_case, PascalCase, kebab-case) across the entire project or within specific language idioms.
    
- **Pronounceability:** Names should be spoken easily to facilitate code reviews and team discussions. Avoid acronyms or distinct abbreviations unless they are ubiquitous domain terms.
    
- **Searchability:** distinct names are easier to grep or search in an IDE. Single-letter names (e.g., `e`, `t`) disappear in search results and should be avoided except for very short-lived loop iterators.
    
- **Avoid Disinformation:** Do not refer to a grouping of accounts as `accountList` unless it is actually a `List` data structure. If the container changes, the name becomes a lie. Use `accountGroup` or simply `accounts`.
    

**Example**

- **Poor:** `d` (elapsed time in days), `file1`, `temp`
    
- **Better:** `elapsedTimeInDays`, `daysSinceModification`, `auditLogFile`
    

---

