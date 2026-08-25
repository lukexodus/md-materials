## Error propagation


Error propagation describes how errors flow through a program from their origin to handlers. In functional error handling, propagation happens automatically through the composition of Result or Option types, eliminating the need for explicit error checking at each step.

**Automatic propagation with bind**

The bind (flatMap) operation is the primary mechanism for error propagation. When you chain operations using bind, errors from earlier steps automatically bypass subsequent operations. If a function returns an error Result, all functions later in the chain receive that error without executing their success logic, effectively short-circuiting the computation.

**Early return semantics**

Functional error propagation provides early return behavior without explicit return statements. Once an error occurs, it tunnels through the remaining composition, emerging at the end of the chain. This mimics exception throwing but maintains explicit control flow and type safety.

**Context preservation during propagation**

As errors propagate, you often need to add contextual information. MapError operations at strategic points in the chain transform errors, enriching them with details about what operation failed or what data was being processed. This builds a stack of context without deeply nested try-catch blocks.

**Selective handling and recovery**

Not all errors need to propagate to the top. You can intercept specific errors at any point in the chain using recovery operations. These inspect the error, and if it matches certain criteria, convert it to a success value or alternative error. Unmatched errors continue propagating unchanged.

**Divergent error handling paths**

Some operations require different handling for different error types. Sum types for errors enable pattern matching at propagation boundaries, routing different error kinds to appropriate handlers. This creates branching recovery logic while maintaining a single flow for successful cases.

**Error boundaries and isolation**

Strategic placement of error handling boundaries prevents errors from propagating beyond certain modules or layers. A boundary catches all errors from a subsystem, logs them, and converts them to a standardized error format for the next layer. This isolates internal error representations from external contracts.

**Propagation through collection operations**

When processing collections of items where each can fail, propagation behavior depends on the strategy. Fail-fast propagation stops at the first error and returns it immediately. Error accumulation continues processing all items, collecting errors and returning them as a collection. Traverse operations implement these strategies generically.

**Short-circuiting vs accumulation**

Result types naturally short-circuit—the first error stops the chain. Validation types (a variation of Result) accumulate errors instead. When you need comprehensive feedback about multiple failures, validation types continue executing all steps, gathering errors in a collection. This is crucial for form validation or complex business rule checking where users benefit from seeing all problems at once.

**Effect on control flow**

Error propagation makes control flow explicit in the type signatures. A function returning `Result<T, E>` clearly communicates that it might fail. The propagation mechanism is visible in the code structure through map, flatMap, and other combinators, unlike exceptions which can emerge from any function call without type-level indication.

**Composition across abstraction boundaries**

Errors propagate cleanly across module and function boundaries without special ceremony. The type system ensures consistent handling. A chain of function calls, each returning Results, composes naturally. The outermost function receives either the final success value or the first error encountered, and the intermediate functions require no error handling code.

**Performance of propagation**

Error propagation through Result types is zero-cost in the success path and minimal-cost in the error path. The propagation is just passing data through function calls—no exception unwinding, no searching for handlers. Modern compilers inline these operations, making the overhead negligible compared to exception-based error handling.

