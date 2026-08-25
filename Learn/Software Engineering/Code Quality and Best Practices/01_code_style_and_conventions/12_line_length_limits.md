## Line length limits


Line length limits define the maximum number of characters allowed on a single horizontal line of code. This constraint forces developers to break complex logic into multi-line statements or refactor code for better readability.

**Key Points**

- **Historical vs. Modern:**
    
    - **80 Characters:** Originating from punched cards and standard terminal widths. Still widely used to support split-screen viewing (3-4 vertical panes) and reviewing code on smaller laptop screens.
        
    - **100-120 Characters:** A more modern relaxation of the rule, accommodating verbose languages (like Java) and high-resolution monitors while still preventing excessive horizontal scrolling.
        
- **Readability:** Long lines force the eye to scan back and forth excessively (saccades), increasing fatigue. Wrapping lines preserves the vertical flow of reading.
    
- **Hard vs. Soft Limits:**
    
    - **Soft Limit:** The preferred maximum length where formatters will attempt to wrap code.
        
    - **Hard Limit:** An absolute maximum where the linter will throw an error if exceeded.
        

**Strategies for Handling Long Lines**

1. **Variable Extraction:** Extract parts of a complex expression into descriptive variables.
    
2. **Line Continuation:** Use language-specific syntax (backslashes, parentheses) to break lines.
    
3. **Method Chaining:** Break chained method calls onto new lines with the dot operator at the start of the line.
    

**Example**

_Exceeding Limit (Hard to read side-by-side):_

Java

```
public void updateUserProfile(String userId, String newName, String newEmail, String newAddress, boolean isActive, Date lastLogin) { ... }
```

_Refactored (Wrapped):_

Java

```
public void updateUserProfile(
    String userId,
    String newName,
    String newEmail,
    String newAddress,
    boolean isActive,
    Date lastLogin
) { ... }
```

