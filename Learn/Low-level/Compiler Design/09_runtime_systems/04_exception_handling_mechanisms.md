## Exception Handling Mechanisms


Exception handling provides structured mechanisms for responding to runtime errors and exceptional conditions. Implementation strategies must balance performance of normal execution paths against exception handling efficiency.

### Table-Based Exception Handling

Table-based exception handling uses metadata tables to describe exception handling regions and their associated handlers. These tables are consulted only when exceptions occur, avoiding runtime overhead during normal execution.

Exception tables typically contain:

- Protected regions with associated exception handlers
- Handler addresses and exception type filters
- Cleanup code locations for automatic object destruction
- Stack unwinding information for proper frame cleanup

The runtime system walks these tables during exception propagation, identifying appropriate handlers and performing necessary cleanup operations.

### Zero-Cost Exception Handling

Zero-cost exception handling aims to impose no runtime overhead on normal execution paths. All exception handling information is maintained in separate metadata tables rather than inline code checks.

This approach optimizes for the common case where exceptions don't occur but may impose higher costs when exceptions are actually thrown due to table lookup and stack unwinding requirements.

### Stack Unwinding

Stack unwinding restores program state during exception propagation by systematically destroying local objects and restoring saved registers as stack frames are removed.

Unwinding requires:

- Identifying which objects require destruction in each frame
- Calling appropriate destructors or cleanup code
- Restoring saved register values
- Updating stack and frame pointers
- Continuing unwinding until an appropriate handler is found

**Example** unwinding challenges:

```
void function() {
    Resource r1;  // Must be cleaned up during unwinding
    Resource r2;  // Must be cleaned up during unwinding
    
    riskyOperation();  // May throw exception
    
    // Normal cleanup happens here, but unwinding
    // must handle cleanup if exception occurs
}
```

### Exception Propagation

Exception propagation mechanisms transport exception objects from throw points to appropriate catch handlers. The system must maintain exception object lifetime and support re-throwing capabilities.

Exception propagation involves:

- Creating exception objects at throw points
- Searching for compatible exception handlers
- Unwinding stack frames until handlers are found
- Transferring control to handler code
- Managing exception object lifetime during propagation

