## Try-except vs Result


Try-except blocks represent imperative error handling where control flow jumps to exception handlers. Result types represent functional error handling where errors are explicit values in the type system. The fundamental difference lies in how errors are communicated and handled.

**Try-except characteristics:**

Try-except uses control flow for error handling. When an exception occurs, execution jumps to the nearest matching catch block, potentially skipping multiple stack frames. This creates action-at-a-distance where error handling logic lives far from error-producing code.

```python
def process_data():
    try:
        result = risky_operation()
        return transform(result)
    except ValueError as e:
        return default_value
    except NetworkError as e:
        log_error(e)
        raise
```

The function's type signature doesn't reveal which exceptions might occur. Callers must read documentation or source code to discover potential failures. There's no compiler support for ensuring all exception cases are handled—forgetting a catch block causes runtime crashes.

**Result type characteristics:**

Result types make errors explicit through sum types, typically `Result<T, E>` where `T` is the success type and `E` is the error type. Every function returning a Result declares its failure modes in the type signature.

```haskell
processData :: Input -> Result NetworkError Value
processData input = do
    rawData <- fetchData input  -- Result NetworkError RawData
    validated <- validate rawData  -- Result ValidationError RawData
    transform validated  -- Result NetworkError Value
```

The type signature immediately shows this function can fail with `NetworkError`. Callers must explicitly handle the error case through pattern matching, monadic binding, or combinators. The compiler enforces exhaustive handling.

**Composition differences:**

Try-except requires careful placement of try blocks and makes composition awkward. Combining multiple exception-throwing functions means nested try-except blocks or catch-all handlers that obscure specific error handling.

Result types compose naturally through monadic operations. The `bind` operation (`flatMap`, `>>=`, `andThen`) automatically propagates errors while allowing success values to flow through transformations. Early return on error happens automatically without explicit checks.

```rust
fn process_user_data(id: UserId) -> Result<Report, Error> {
    let user = fetch_user(id)?;  // Returns early if Error
    let data = get_user_data(user.id)?;  // Returns early if Error
    let processed = transform_data(data)?;  // Returns early if Error
    generate_report(processed)  // Final Result
}
```

The `?` operator provides early return on error while maintaining explicit error types. Compare this to try-except where early return requires explicit `return` statements and error types remain hidden.

**Type system integration:**

Result types integrate with type systems to provide compile-time guarantees. Generic functions can operate on Result values without knowing specific error types. Type inference tracks error propagation through the call graph.

Try-except lacks type system integration in most languages. Checked exceptions (Java) attempt this but create verbosity and are often worked around. The type system can't help compose or transform exceptions functionally.

**[Inference] Practical tradeoffs:**

Result types require more explicit error handling code but provide better safety guarantees and composition. Try-except allows ignoring errors (letting them propagate up) but risks unhandled exceptions at runtime. The functional approach frontloads error handling complexity in exchange for stronger correctness properties.

