## Variable Naming


Variables hold state and data; their names should reflect the _content_ rather than the implementation details. The length of a variable name should often be proportional to the size of its scope.

**Key Points**

- **Nouns and Noun Phrases:** Variables represent things or attributes. Use nouns like `user`, `account`, or `width`.
    
- **Scope Correlation:** For variables with a large scope (global or class-level), use highly descriptive, distinct names. For variables with very small scopes (e.g., a 3-line loop), shorter names like `i` or `x` are acceptable if the context is immediately obvious.
    
- **Boolean Conventions:** Prefix boolean variables with `is`, `has`, `can`, or `should` to imply a true/false nature. e.g., `isValid`, `hasMembership`. Avoid negative booleans like `isNotValid` as they create double negatives in logic (`!isNotValid`).
    
- **Count vs. Index:** Distinguish between a count of items and a 0-based index. Use `userCount` for the total and `userIndex` for the iterator position.
    

**Example**

- **Poor:** `flag`, `status`, `str`
    
- **Better:** `isArchived`, `orderStatus`, `customerName`
    

---

