## Avoiding exceptions


Exceptions break referential transparency and introduce hidden control flow that violates functional programming principles. When a function throws an exception, it has an effect beyond returning a value—it can jump execution to any catch block up the call stack. This makes functions impure because the same inputs don't guarantee the same observable behavior; the function might return normally or throw an exception depending on runtime conditions.

**Problems with exceptions in functional code:**

Exception-based error handling forces callers to remember which exceptions might be thrown, creating implicit contracts not captured in type signatures. A function `divide: (Int, Int) -> Int` appears to always return an integer, but actually throws on division by zero. This hidden behavior makes composition dangerous—chaining functions means accumulating potential exceptions that aren't visible in types.

Exceptions also complicate reasoning about code flow. When any function call might jump elsewhere, local reasoning becomes impossible. You must consider the entire call stack to understand what might happen. This contradicts functional programming's goal of understanding code by examining small, isolated pieces.

**Functional alternatives:**

Instead of throwing exceptions, functions should encode error possibilities in their return types. A division function returns `Option<Int>` or `Result<Int, DivisionError>`, making failure explicit. Callers see immediately that they must handle the error case—the type system enforces it.

This approach treats errors as data rather than control flow. Errors become values that can be transformed, composed, and passed around like any other data. Functions remain total (defined for all inputs in their domain) and pure (same input always produces same output value, even if that value represents failure).

**Practical benefits:**

Type-driven error handling enables the compiler to verify exhaustive error handling. If you don't handle a `None` case or `Error` variant, compilation fails. This catches bugs at compile time rather than runtime. It also makes refactoring safer—changing error types automatically highlights all call sites that need updating.

