## Result types


Result types explicitly encode success or failure as data structures, making error handling a first-class concern in the type system. A Result type is typically a discriminated union with two variants: one representing successful outcomes containing a value, and another representing failures containing error information.

**Structure and representation**

The typical structure takes two type parameters: the success value type and the error type. For example, `Result<T, E>` means a computation that either succeeds with a value of type `T` or fails with an error of type `E`. Languages implement this as `Ok(value)` for success and `Err(error)` for failure variants.

**Type safety guarantees**

The type system enforces handling both cases. You cannot access the success value without acknowledging the possibility of failure. This eliminates entire classes of bugs where programmers forget to check for errors. Pattern matching or explicit case handling becomes mandatory, making error paths visible in the code.

**Transforming Results**

Map operations transform the success value while leaving errors untouched. If you have `Result<Int, Error>` and apply a function `Int -> String`, you get `Result<String, Error>`. The transformation only executes if the Result contains a success value; errors propagate automatically without transformation.

**Chaining dependent operations**

FlatMap (or bind) handles sequential operations where each step depends on the previous success. When you have a function that returns a Result, flatMap prevents nesting `Result<Result<T, E>, E>` by flattening the structure. This enables clean chaining of multiple fallible operations.

**Error transformation**

MapError allows transforming the error type without affecting success values. This is crucial when bridging different error domains or adding context to errors as they propagate up the call stack. You can convert specific errors into more general error types or enrich errors with additional diagnostic information.

**Combining multiple Results**

When multiple independent Results need combination, specialized functions handle various scenarios. You might want all Results to succeed (returning a Result of a tuple), or collect all errors if any fail. Applicative operations enable parallel validation where you accumulate all validation failures rather than stopping at the first error.

**Interoperation with exceptions**

Result types often need conversion to and from exception-based code. Constructors catch exceptions and convert them to Err variants. Conversely, methods extract values by throwing exceptions if the Result is an error, bridging functional and imperative error handling.

**Performance characteristics**

Results are value types with no heap allocation for the discriminated union itself. The performance cost is minimal—typically just a tag indicating which variant is present. Modern compilers optimize Result-heavy code effectively, often eliminating the overhead entirely through inlining.

**Error accumulation patterns**

Results enable sophisticated error collection strategies. In validation scenarios, you can implement traversals that collect all errors from a list of operations, providing comprehensive feedback rather than failing fast. This requires specialized traverse operations that sequence Results while accumulating errors.

