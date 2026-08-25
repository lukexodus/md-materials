## **When to Raise Exceptions**


Raising (or throwing) an exception is an explicit signal that the code cannot proceed with its normal execution flow.

- **Invalid Input (Pre-condition Violation):** Raise exceptions immediately when arguments passed to a function do not match expected criteria (types, ranges, formats). This enforces the **Fail Fast** principle—detecting the error as close to the source as possible.
    
    - _Example:_ Raising `ValueError` if a function expects a positive integer but receives a negative one.
        
- **Unrecoverable State:** If a dependency is missing, a file is corrupt, or a network connection is mandatory but unavailable, raise an exception. The current scope cannot fix this; a higher level must decide what to do.
    
- **Abstraction Barriers:** When building a library or a specific module, catch low-level implementation details and raise a high-level, domain-specific exception.
    
    - _Example:_ In a Payment module, catch a low-level `socket.timeout` or `ConnectionError` and raise a `PaymentProcessingError`. This prevents the caller from needing to know about the networking library you are using.
        
- **Violation of Business Logic:** If an operation is technically valid in code but invalid in the business context (e.g., withdrawing more money than is in an account), raise a custom exception.
    

---

