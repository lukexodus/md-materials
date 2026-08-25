## Use Exceptions Properly


Exceptions should be reserved for truly exceptional conditions—events that the application cannot predict or handle in the normal flow of control. Misusing exceptions for control flow leads to poor performance and confusing code structures (GOTO-like behavior).

**Key Points**

- **Exceptions vs. Control Flow:** Do not use exceptions for expected logic (e.g., `try { list.get(i) } catch (IndexOutOfBoundsException)` to loop). This is computationally expensive and semantically incorrect.
    
- **Standard vs. Custom:** Prefer standard library exceptions (`IllegalArgumentException`, `IllegalStateException`) for common issues. Create custom exceptions only when you need to capture specific domain data or allow the caller to handle specific business error scenarios differently.
    
- **Exception Wrapping:** When catching a low-level exception (e.g., `SQLException`) to throw a higher-level one (e.g., `OrderProcessingException`), always pass the original exception as the "cause". This preserves the full stack trace for debugging.
    
- **Catch Specifics:** Avoid `catch (Exception e)`. This swallows unrelated runtime errors (like bugs or memory issues) and makes it impossible to handle recoverable errors specifically.
    
- **Resource Management:** Always use `try-with-resources` (or `using` blocks) to ensure resources like file streams or database connections are closed, even if an exception occurs.
    

**Example**

_Preserving Stack Trace (Wrapping):_

Java

```
public void saveConfig(Config c) {
    try {
        fileSystem.write(c.toJson());
    } catch (IOException e) {
        // Wrap and throw to preserve the cause
        throw new ConfigurationException("Failed to save configuration file", e);
    }
}
```

---

