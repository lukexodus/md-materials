## Custom Exceptions


### Architectural Role and Domain Mapping

Custom exceptions serve as a mechanism to map low-level technical failures to high-level domain semantics. In a layered architecture, exceptions must reflect the abstraction level of the layer from which they originate.

- **Semantic Precision:** Standard library exceptions (e.g., `IllegalArgumentException`, `ValueError`) are generic. A custom `InventoryAllocationFailedException` provides immediate clarity on the business rule violation, distinguishing it from a generic input error.
    
- **Taxonomy Design:** Define a base exception class for the application (e.g., `DomainException`) and subclass for specific modules (e.g., `PaymentException`, `OrderException`). This allows catch blocks to handle categories of errors (e.g., "retry all payment errors") rather than coupling to specific implementations.
    

### Exception Translation and Wrapping

To preserve architectural boundaries, exceptions crossing layer boundaries must be translated. Leaking implementation-specific exceptions (e.g., `SQLException` or `IOException`) to the presentation layer creates tight coupling and exposes security vulnerabilities.

- **Pattern Implementation:** Catch the low-level exception at the boundary and throw a custom, context-aware exception, passing the original exception as the `cause`.
    
    Java
    
    ```
    try {
        repository.save(order);
    } catch (ConstraintViolationException e) {
        // Translate infrastructure error to domain error
        throw new DuplicateOrderException(order.getId(), e);
    }
    ```
    
- **Cause Chaining:** Essential for debugging. The custom exception must expose the root cause to the logging framework while sanitizing the message displayed to the client.
    

### Context Enrichment and Immutability

String concatenation in exception messages is insufficient for structured logging and programmatic error handling.

- **Structured State:** Custom exceptions should define typed fields for relevant context (e.g., `resourceId`, `userId`, `errorCode`) rather than embedding them in a message string. This enables exception handlers to serialize errors into structured JSON responses automatically.
    
- **Immutability:** Exception state must be immutable. All context data should be injected via the constructor to ensure the exception represents a consistent snapshot of the failure state.
    

### Performance Considerations

Instantiating an exception is expensive primarily due to the capture of the stack trace.

- **Stack Trace Suppression:** For custom exceptions used strictly for flow control in high-throughput loops (a practice generally discouraged but sometimes necessary), override the stack trace generation method (e.g., `fillInStackTrace` in Java) to return `this`. This reduces the cost to that of a standard object allocation.
    
- **Cached Instances:** If an exception carries no state and is immutable, consider using a static singleton instance to eliminate allocation overhead entirely.
    

### Anti-Patterns

- **Swallowing Exceptions:** Catching a custom exception and logging it without rethrowing or handling the business logic effectively hides the failure state.
    
- **Exception-Driven Logic:** Using custom exceptions for expected control flow (e.g., `UserNotFoundException` during a login check) is an anti-pattern known as "Expection". It disrupts compiler optimizations and pollutes logs. Use `Option`/`Maybe` types or explicit return values for expected conditions.
    
- **Catch-All Inheritance:** Creating a single `AppException` and using it for every error prevents granular handling strategies. Distinct failure modes require distinct types.

---

