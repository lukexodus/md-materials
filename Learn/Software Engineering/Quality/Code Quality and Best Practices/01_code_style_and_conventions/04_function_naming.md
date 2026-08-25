## Function Naming


Functions perform actions; their names must be verbs or verb phrases that clearly indicate the side effect, transformation, or return value produced by the function.

**Key Points**

- **Verb-Noun Pairs:** The standard structure is [Verb][Noun], such as `calculateTax`, `deleteUser`, or `fetchConfig`.
    
- **Command-Query Separation:** A function should usually do something (command) or answer something (query), but not both. Names should reflect this. `getAccount()` should return an account, not create one if it is missing (unless named `getOrCreateAccount`).
    
- **Standardize Verbs:** Pick one verb per concept and stick to it. Do not mix `fetch`, `retrieve`, and `get` for the same type of operation across different controllers.
    
- **Avoid "And":** If a function name includes "And" (e.g., `validateAndSave`), it violates the Single Responsibility Principle. This suggests the function should be split into two.
    

**Example**

- **Poor:** `process()`, `handle()`, `userData()`
    
- **Better:** `sendEmailInvitation()`, `parseXmlConfiguration()`, `isValidPassword()`
    

---

