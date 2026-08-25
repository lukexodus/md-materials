## Exception Naming and Taxonomy


### Semantic Precision and Intent

Exception naming is a critical component of API design and the self-documenting code principle. The class name itself must convey the specific error condition without requiring the consumer to inspect the stack trace or message string. A properly named exception dictates the consumer's recovery strategy.

- **Problem-Centric vs. Symptom-Centric:** Names should describe the root cause found in the business logic, not the low-level symptom.
    
    - _Poor:_ `DatabaseWriteException` (Implementation detail, symptom).
        
    - _Optimal:_ `DuplicateUsernameException` (Domain constraint violation, root cause).
        
- **Actionability:** The name should imply the recoverability of the state.
    
    - `ServiceUnavailableException` implies a temporary state where a retry (with backoff) is a valid strategy.
        
    - `InvalidRequestFormatException` implies a permanent error where retrying without modification is futile.
        

### Grammatical Structure and Conventions

Consistency in grammatical construction reduces cognitive load during API discovery.

1. **Standard Pattern:** `<Object><State><Exception>` or `<Adjective><Object><Exception>`.
    
    - _Examples:_ `PaymentAuthorizationExpiredException`, `MissingConfigurationValueException`.
        
2. **The Suffix Rule:**
    
    - **Java/.NET:** Rigid adherence to the `Exception` suffix is mandatory (e.g., `UserNotFoundException`). This distinguishes the type from the entity (a `UserNotFound` object vs. an Event vs. an Exception).
        
    - **Python:** The convention fluctuates between `Error` (standard library style, e.g., `ValueError`) and `Exception`. For custom business logic, `Exception` is often preferred to distinguish from low-level syntax or runtime errors.
        
3. **Forbidden Redundancies:**
    
    - Avoid generic prefixes that mirror the namespace. In `com.app.billing`, `BillingException` is redundant if it is the base class, but `BillingServiceConnectionException` is valid.
        
    - Avoid vague verbs. `ProcessException`, `CalculationException`, or `ManageException` provide zero context.
        

### Scope and Domain-Driven Design (DDD)

Exception names must align with the **Bounded Context** in which they exist. The same underlying failure (e.g., a connection timeout) requires different naming conventions depending on the architectural layer.

- **Infrastructure Layer:** Names reflect technical failures.
    
    - _Example:_ `SocketTimeoutException`, `SqlConstraintViolationException`.
        
- **Domain Layer:** Names reflect business rules. Technical exceptions must be caught and wrapped (translated) into domain exceptions to prevent leaky abstractions.
    
    - _Transformation:_ A `SqlConstraintViolationException` (unique key violation on email column) becomes a `UserAlreadyRegisteredException`.
        
- **Application/Service Layer:** Names reflect use-case failures.
    
    - _Example:_ `CheckoutProcessFailedException`.
        

### Hierarchy Naming Strategies

The taxonomy of exception inheritance is as important as the leaf-node names. Base classes should group exceptions by **recovery strategy** or **component boundary**, not just categorical similarity.

- **Categorical Bases:**
    
    - `TransientException`: Base class for all retriable errors (Network blips, lock contention).
        
    - `FatalException`: Base class for unrecoverable errors requiring administrative intervention (Config corruption, missing assets).
        
- **Marker Interfaces/Mixins:**
    
    - Instead of deep inheritance trees, using marker interfaces like `ISecurityAlert` allows global handlers to identify and log security-relevant exceptions (like `InsufficientPrivilegesException` or `TokenTamperedException`) differently from standard logic errors.
        

### Anti-Patterns in Naming

- **The "General" Trap:** Names like `GeneralException`, `CommonException`, or `BaseException` (if used as a concrete throw) defeat the purpose of `try-catch` blocks. Callers cannot granularly catch specific failures without resorting to fragile string matching on the exception message.
    
- **Leaky Implementation Details:** Naming an exception `JmsQueueFullException` in a generic `NotificationService` interface couples the client to the JMS implementation. If the backend switches to Kafka or HTTP Webhooks, the name becomes a lie. Use `NotificationBacklogExceededException` instead.
    
- **HTTP Status Code Mimicry:** Avoid naming internal exceptions `NotFoundException` or `BadRequestException` unless strictly within the REST Controller layer. Domain logic should be agnostic to the transport layer protocol. Use `EntityMissingException` or `InputValidationException`.
    

### Related Topics

- Exception Translation and Chaining
    
- Global Error Handling Strategies
    
- Domain-Driven Design (DDD)
    
- Checked vs. Unchecked Exceptions Standards

---

