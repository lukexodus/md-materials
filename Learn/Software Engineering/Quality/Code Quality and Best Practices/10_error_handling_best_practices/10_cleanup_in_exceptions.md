## Cleanup in Exceptions


### Deterministic Resource Management (RAII)

The gold standard for exception cleanup is removing the need for explicit manual cleanup. Resource Acquisition Is Initialization (RAII) ties the lifecycle of a resource (file handle, mutex, network socket) to the scope of a variable. When the scope is exited via stack unwinding during an exception, the destructor/finalizer automatically releases the resource.

- **Implementation:**
    
    - **C++/Rust:** Relies on stack-allocated objects with destructors (`~ClassName` or `Drop` trait). This provides deterministic cleanup without garbage collection overhead.
        
    - **Java/C#:** Simulates RAII via `try-with-resources` (Java) or `using` statements (C#). These constructs compile down to implicit try-finally blocks that guarantee the `AutoCloseable` or `IDisposable` interface methods are invoked.
        
    - **Python:** Utilizes Context Managers (`with` statement) invoking `__enter__` and `__exit__`.
        

### Exception Safety Levels

Cleanup logic must strictly adhere to Exception Safety guarantees to prevent state corruption:

- **No-Throw Guarantee:** Cleanup code (destructors, `finally` blocks) must **never** throw an exception. If an exception escapes a destructor during stack unwinding (while another exception is already active), it typically results in immediate process termination (e.g., `std::terminate` in C++).
    
- **Strong Guarantee:** Operations are transactional. If an exception occurs, the system state remains unchanged (rollback semantics). This requires careful ordering of resource acquisition and side effects.
    
- **Basic Guarantee:** Invariants are preserved, and no resources are leaked, but the exact state of the data may be unpredictable (though valid).
    

### Exception Suppression

A critical edge case in cleanup involves "exception masking." If an exception is thrown during the cleanup phase (e.g., closing a file fails) while an original exception is propagating:

1. **The Masking Problem:** The secondary exception (cleanup failure) overwrites the primary exception (logic failure), hiding the root cause of the bug.
    
2. **Resolution Patterns:**
    
    - **Suppressed Exceptions (Java):** The `try-with-resources` construct automatically attaches the cleanup exception to the primary exception using `Throwable.addSuppressed()`.
        
    - **Manual Handling:** In manual cleanup blocks, check if an exception is currently active. If so, log the cleanup error rather than throwing it, preserving the original stack trace.
        

