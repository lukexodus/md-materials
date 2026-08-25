## Developer-facing Errors


### The "Cause" Chain (Exception Wrapping)

One of the most destructive anti-patterns is "swallowing" exceptions or losing the stack trace.

- **Exception Chaining:** When catching a low-level exception (e.g., `SQLException`) and throwing a high-level exception (e.g., `OrderProcessingException`), the original exception must be passed as the `cause` parameter. This preserves the stack trace from the root cause up to the business logic failure.
    
    - _Implementation:_ `throw new BusinessException("Order failed", originalException);`
        
- **Suppressed Exceptions:** In `try-with-resources` or `finally` blocks, ensure that exceptions thrown during resource closure do not overwrite the primary exception thrown in the `try` block.
    

### Contextual State Dumps

A stack trace alone is often insufficient to reproduce complex state-dependent bugs.

- **Failure Atomicity:** Ensure that when an error occurs, the system state is rolled back to a consistent baseline (using database transactions or compensating transactions).
    
- **Environment Snapshots:** Developer logs for `ERROR` level events should include a snapshot of relevant environment variables, configuration flags, and the memory state of the critical variables at the moment of failure (sanitized).
    
- **Reproducibility Vectors:** Generate a cURL command or a serialized test case payload in the logs that can strictly reproduce the failure in a local development environment.

---

