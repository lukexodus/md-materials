## Refactoring mindset


The refactoring mindset is the discipline of treating code quality as a continuous process rather than a one-time phase. It involves the constant restructuring of existing code without changing its external behavior to improve non-functional attributes like readability, maintainability, and complexity.

**Key Points**

- **The Boy Scout Rule:** Leave the code cleaner than you found it. If you touch a file to fix a bug, make a small improvement to readability or structure in that same area.
    
- **Code Smells as Triggers:** Cultivate a sensitivity to "code smells" (e.g., Long Method, Large Class, Data Clumps, Shotgun Surgery). These are immediate triggers for refactoring.
    
- **Green-Red-Refactor:** In Test-Driven Development (TDD), refactoring is a mandatory step, not an optional one. It ensures that technical debt does not accumulate during feature development.
    
- **Safety Net:** Never refactor without a comprehensive suite of passing tests. Refactoring without tests is merely changing code blindly and risking regression.
    
- **Incrementalism:** Prefer small, atomic refactoring steps over "Big Bang" rewrites. Small changes are easier to verify, review, and roll back if necessary.
    

**Example**

_Scenario:_ A developer notices a 50-line function that handles user registration, email validation, and database insertion.

_Refactoring Action:_

1. **Identify:** The function violates the Single Responsibility Principle.
    
2. **Safety Check:** Ensure existing tests cover user registration.
    
3. **Extract:** Move email validation logic to a dedicated `EmailValidator` service.
    
4. **Extract:** Move database logic to a `UserRepository` class.
    
5. **Compose:** The original function now acts as a coordinator, calling `EmailValidator.validate()` and `UserRepository.save()`.
    
6. **Verify:** Run tests to confirm behavior is identical.

---

