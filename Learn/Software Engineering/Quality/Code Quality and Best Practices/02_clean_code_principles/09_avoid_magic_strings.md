## Avoid magic strings


Magic strings are string literals specified directly within code, often used for comparisons, event names, or configuration keys. Like magic numbers, they are prone to typo-induced bugs that compilers often cannot detect and make refactoring tedious.

**Key Points**

- **Typo Susceptibility:** A misspelled string literal (e.g., "admin" vs "admn") usually results in silent logic failures rather than syntax errors. Constants catch these errors at compile time or initialization.
    
- **Duplication:** Repeating string literals violates the DRY (Don't Repeat Yourself) principle. If the underlying value needs to change, it must be changed everywhere.
    
- **"Stringly" Typed Code:** Relying on strings for control flow (e.g., `if (type === 'manager')`) weakens type safety. Enums or polymorphic classes are superior alternatives.
    
- **Localization/Internationalization:** Hard-coded strings make future translation efforts significantly harder. Strings intended for display should be separated into resource files; strings intended for logic should be constants.
    

**Example**

_Bad Practice_

Java

```
public void handleUser(User user) {
    if (user.getRole().equals("administrator")) {
        // grant access
    }
}

// Somewhere else in the codebase
public void promoteUser(User user) {
    user.setRole("admin"); // Inconsistent string usage ('administrator' vs 'admin')
}
```

_Good Practice_

Java

```
public class UserRole {
    public static final String ADMINISTRATOR = "administrator";
    public static final String GUEST = "guest";
}

// Or better, using Enum
public enum Role {
    ADMINISTRATOR,
    GUEST
}

public void handleUser(User user) {
    if (user.getRole() == Role.ADMINISTRATOR) {
        // grant access
    }
}
```

