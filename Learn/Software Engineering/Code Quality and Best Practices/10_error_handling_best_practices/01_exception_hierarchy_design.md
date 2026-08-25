## Exception Hierarchy Design


### Structural Classification and Semantics

An effective exception hierarchy rigorously separates failure categories based on recovery potential and semantic meaning.

- **Fatal System Failures (Unchecked/Runtime):** These represent defects in the code (e.g., `NullPointerException`, `IndexOutOfBounds`) or unrecoverable environmental failures (e.g., `OutOfMemoryError`). These should generally extend the language's equivalent of `RuntimeException`. Applications should rarely catch these low-level exceptions explicitly except at the highest boundary (Global Error Handler) for logging and graceful termination.
    
- **Recoverable Conditions (Checked/Business):** These represent anticipated alternate flows in the business logic (e.g., `InsufficientFundsException`, `InventoryEmptyException`). While some modern languages (Kotlin, C#, Go) eschew checked exceptions to reduce boilerplate, strictly typed architectures often enforce handling of these scenarios via method signatures or Result/Either monads to ensure compiler-enforced reliability.
    
- **Interruption and Cancellation:** Thread interruption and task cancellation signals should form a distinct branch of the hierarchy. Mixing cancellation logic with error handling logic leads to "swallowed interrupts," preventing proper thread lifecycle management and resource cleanup.
    

### Abstraction Layers and Exception Translation

Exceptions must respect the abstraction boundaries of the architecture. A violation of this principle creates tight coupling and leaks implementation details.

- **The Translation Pattern:** A lower-level exception must be caught and wrapped in a higher-level exception relevant to the current context before propagating.
    
    - _Violation:_ A Service Layer throwing `java.sql.SQLException` or `psycopg2.OperationalError`.
        
    - _Correction:_ The Repository Layer catches persistence exceptions and rethrows a generic `DataAccessException` or a specific `EntityNotFoundException`.
        
- **Cause Chaining:** When wrapping exceptions, the original root cause must be preserved (passed to the constructor of the new exception) to maintain the full stack trace for debugging. Losing the `innerException` renders root cause analysis impossible in production environments.
    

### Granularity vs. Class Explosion

A common anti-pattern is creating a distinct exception class for every possible error message. This bloats the codebase and complicates `catch` blocks.

- **Differentiation Strategy:** Create a new exception subclass _only_ if the calling code is expected to handle that specific exception differently from its parent. If the recovery logic is identical (e.g., "log and fail"), a distinct class is unnecessary.
    
- **Payload-Driven Exceptions:** Instead of `InvalidEmailException`, `InvalidPhoneException`, and `InvalidZipCodeException`, implement a single `ValidationException` that carries a structured payload (e.g., an Enum `ErrorCode` or a list of `ValidationError` objects). This pushes the specificity into data rather than the type system.
    

### Inheritance and Polymorphism in Catch Blocks

Exception hierarchies must be designed to facilitate safe polymorphic catching while avoiding "Pokemon Exception Handling" (Gotta catch 'em all).

- **Base Class Catching:** Catching a high-level base class (e.g., `catch (Exception e)`) inadvertently swallows unrelated runtime errors, masking bugs. Catch blocks should be as specific as possible.
    
- **Leaf-First Evaluation:** Runtime environments evaluate catch blocks strictly in order. The hierarchy must be arranged such that specific leaf-node exceptions are caught before their generalized parent classes.
    
- **Marker Interfaces/Mixins:** In languages supporting multiple inheritance or interfaces, marker interfaces can group disparate exceptions that share a common trait (e.g., `RetryableException`) allowing a single catch block to handle network timeouts and database deadlocks uniformly without catching unrelated errors.
    

### Security and Boundary Marshalling

When exceptions traverse system boundaries (REST APIs, gRPC, IPC), the internal hierarchy cannot be exposed directly.

- **Sanitization:** Internal exception messages and stack traces must never be serialized directly to the client. This exposes internal topology, library versions, and potential injection vectors.
    
- **Mapping to Standard Protocols:**
    
    - _HTTP:_ Map hierarchy branches to HTTP Status Codes (e.g., `InputException` -> 400, `AuthException` -> 401/403, `SystemException` -> 500).
        
    - _gRPC:_ Map to standard gRPC error codes (`INVALID_ARGUMENT`, `NOT_FOUND`, `INTERNAL`).
        
- **DTO Conversion:** A Global Exception Filter/Interceptor should intercept the bubble-up process at the API edge and convert the exception object into a standardized, schema-compliant Error DTO (Data Transfer Object).

---

