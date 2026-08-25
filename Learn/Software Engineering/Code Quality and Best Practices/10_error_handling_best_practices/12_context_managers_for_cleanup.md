## Context managers for cleanup


### Deterministic Resource Management and RAII

In languages with Garbage Collection (GC) like Python or Java, memory management is automatic, but resource management (file descriptors, sockets, database transactions, mutex locks) is not. Relying on finalizers (`__del__` in Python or `finalize()` in Java) is non-deterministic and an anti-pattern. Context managers implement the Resource Acquisition Is Initialization (RAII) pattern, decoupling resource lifecycle from object scope. They guarantee that teardown logic executes regardless of control flow exits, including exceptions, `return` statements, or `sys.exit()`.

### The Protocol: `__enter__` and `__exit__` mechanics

Robust implementation requires strict adherence to the protocol contracts, particularly regarding exception propagation.

- **`__enter__`:** Establishes the runtime context. If this method raises an exception, the runtime guarantees that `__exit__` is **never** called. Therefore, `__enter__` must be atomic; partial acquisition failures inside `__enter__` must be self-cleaned before propagating the error.
    
- **`__exit__`:** Handles teardown. It receives three arguments representing the exception (`exc_type`, `exc_value`, `traceback`) if one occurred.
    
    - **Exception Suppression:** Returning `True` acts as a "catch" block, suppressing the exception. This should be used sparingly (e.g., essentially only for expected operational errors like `FileExistsError` in a customized atomic writer).
        
    - **Exception Translation:** To wrap low-level exceptions (e.g., `socket.error`) in domain-specific exceptions, `__exit__` must raise the new exception explicitly. The original exception context (`__context__`) is preserved automatically in modern Python.
        

### Dynamic Composition with `ExitStack`

A common limitation of the `with` statement is the inability to handle a dynamic number of resources (e.g., opening a list of files provided at runtime). Nesting `with` blocks is syntactically impossible for unknown counts.

- **`contextlib.ExitStack`:** This provides a stack-based context manager that allows pushing callbacks and other context managers dynamically. It ensures proper LIFO (Last-In, First-Out) cleanup. If an exception occurs during the initialization of the $N$th resource, `ExitStack` guarantees the cleanup of the preceding $N-1$ resources, preventing leaks during partial initialization sequences.
    

### Asynchronous Context Managers

In event-driven architectures (e.g., `asyncio`, `Twisted`), blocking I/O inside standard cleanup methods halts the event loop, degrading system throughput.

- **`__aenter__` and `__aexit__`:** Use `async with` to handle resources requiring asynchronous teardown, such as closing database connection pools or flushing network buffers.
    
- **Deadlock Risks:** Unlike synchronous managers, `__aexit__` is a coroutine. Ensure that the cleanup logic does not await primitives that might currently be held by the cancelled task, which leads to deadlocks.
    

### Generator-Based Managers (`@contextmanager`)

The `contextlib.contextmanager` decorator transforms a generator into a context manager.

- **Mandatory `try-finally`:** The code before the `yield` statement executes as `__enter__`. The code after `yield` executes as `__exit__`. Crucially, the `yield` must be wrapped in a `try...finally` block. Without this, an exception raised inside the `with` block will cause the generator to terminate immediately at the yield point, skipping the cleanup code entirely.
    
- **Single-Use Limitation:** Unlike class-based managers, generator-based managers are typically single-use. Attempting to reuse them raises a `RuntimeError`.
    

### Anti-Patterns

- **Universal Suppression:** writing `__exit__` methods that strictly return `True` without checking `exc_type`. This swallows `SystemExit` and `KeyboardInterrupt`, making the process unkillable and impossible to debug.
    
- **Fat Contexts:** overloading a context manager to handle unrelated concerns (e.g., a timer that also handles database commits). Adhere to the Single Responsibility Principle; use `ExitStack` to compose small, focused managers.

---

