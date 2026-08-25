## Exception analysis


Concept and Rationale

Exception analysis is the systematic evaluation of how an application handles runtime anomalies. It moves beyond simply "fixing the crash" to understanding the semantic meaning of errors, ensuring system resilience, and preserving diagnostic fidelity. Effective analysis categorizes exceptions into three distinct buckets: recoverable errors (network glitches, file locks), programming errors (null references, invalid arguments), and fatal system errors (out of memory, configuration corruption). The goal is to ensure that the application fails gracefully, leaks no sensitive information, and provides actionable telemetry for debugging.

The "Throw Early, Catch Late" Principle

This is the foundational rule of robust exception management.

- **Throw Early:** Detect invalid states immediately at the point of entry (e.g., inside a constructor or method start). This prevents "zombie" objects from corrupting the system state further down the line.
    
- **Catch Late:** Do not catch an exception unless you can meaningfully handle it (e.g., retry, fallback, or friendly user message). If a method cannot resolve the issue, it should let the exception bubble up to a higher-level handler (like a global middleware or controller). Catching exceptions too early without resolution often leads to "swallowing" errors, where the failure is hidden, and the system continues in an undefined state.
    

Preserving the Stack Trace

A common defect in exception analysis is "destructive rethrowing." When an exception is caught and re-thrown explicitly, the original stack trace—the roadmap to the crash—can be lost depending on the syntax used.

Bad Practice (Destructive Rethrow)

In C# and many other languages, explicitly specifying the variable in the throw statement resets the stack trace to the current line, obscuring the original source of the error.

C#

```
try {
    // Code that causes a NullReferenceException
} catch (Exception ex) {
    // Bad: The stack trace is reset here. 
    // You lose the info about where the null reference actually happened.
    throw ex; 
}
```

Good Practice (Preserving Context)

Use the throw keyword without the variable to preserve the original stack trace. Alternatively, wrap the exception in a custom domain exception, passing the original as the InnerException.

C#

```
try {
    // Code that fails
} catch (SqlException ex) {
    // Good: Wraps the low-level DB error in a domain-relevant error.
    // Preserves the original stack trace via the 'innerException' parameter.
    throw new OrderProcessingException("Failed to process order", ex);
}
```

Exception Wrapping and Abstraction Leaks

Exception analysis must ensure that implementation details do not leak across architectural boundaries. A UI layer or a REST API consumer should never see a SqlException or NullReferenceException. These are implementation details that expose the underlying technology stack (security risk) and offer no value to the client.

- **Strategy:** Catch low-level technical exceptions at the service boundary and wrap them in semantic, domain-specific exceptions (e.g., `UserNotFoundException`, `PaymentDeclinedException`).
    
- **Benefit:** This allows the calling code to handle errors based on _business logic_ (e.g., "if payment declined, ask for new card") rather than _technical implementation_ (e.g., "if SQL error 504, do X").
    

Anti-Pattern: Control Flow via Exceptions

Exceptions are computationally expensive; they require stack unwinding and memory allocation for the stack trace. Using them for logic flow (e.g., validating user input) degrades performance and readability.

- **Violation:** `try { int.Parse(input); } catch { return false; }`
    
- **Correction:** Use the "Tester-Doer" pattern or safe parsing methods: `int.TryParse(input, out var result);`
    

Global Exception Handling

A comprehensive analysis strategy requires a safety net. This is typically a global middleware (in Web APIs) or a top-level AppDomain handler (in Desktop apps).

1. **Catch All:** Intercepts any exception not handled by specific code.
    
2. **Log:** Writes the full stack trace and request context to a secure log store.
    
3. **Sanitize:** Returns a generic "Internal Server Error" (HTTP 500) to the user with a correlation ID (e.g., "Error Reference: #8329A"), hiding the actual stack trace from the public response.
    

Next Steps

Review your codebase for catch (Exception ex) blocks that define empty bodies (swallowed exceptions) or perform throw ex (stack trace destruction). Replace generic exception handlers with specific ones (e.g., catch (FileNotFoundException)) and implement a global exception handler for unpredicted errors.

---

