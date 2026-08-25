## Either pattern


Either is a sum type representing a value that can be one of two types, conventionally called Left and Right. By convention, Left holds error values and Right holds success values, though Either itself is symmetric. This pattern generalizes Result to cases where both outcomes carry meaningful information.

**Structure and semantics:**

Either encodes a choice between two types:

```haskell
data Either e a = Left e | Right a
```

The type `Either String Int` means "either a String or an Int." When used for error handling, Left carries error information and Right carries success values. This convention comes from Right being associated with "correct" outcomes.

Functions returning Either explicitly declare both error and success types. A function `parseInteger :: String -> Either ParseError Int` clearly shows it produces either a ParseError or an Int, with no hidden failure modes.

**Functor and Monad instances:**

Either is right-biased in its Functor and Monad instances—map and bind operate on Right values while short-circuiting on Left. This enables automatic error propagation through chains of operations.

```haskell
processInput :: String -> Either Error Result
processInput input = do
    parsed <- parseInput input      -- Either Error ParsedData
    validated <- validate parsed    -- Either Error ValidData
    transformed <- transform validated  -- Either Error Result
    pure transformed
```

If any step produces a Left, the entire computation short-circuits and returns that Left. If all steps produce Right values, the final Right propagates through. This implements early return for errors without explicit checking.

**Bimap and bifunctor operations:**

Unlike Result types that typically only map over success values, Either supports bifunctor operations that transform both sides simultaneously:

```scala
val result: Either[ErrorCode, Int] = computeValue()
val mapped: Either[String, String] = result.bimap(
  errorCode => s"Error: ${errorCode.message}",
  value => s"Success: $value"
)
```

The `bimap` function applies different transformations to Left and Right values, enabling error transformation without unwrapping. This is useful for error context enrichment or normalizing error types across boundaries.

**Accumulating multiple errors:**

Standard Either short-circuits on the first error, but variations like `Validated` or using Either with Applicative semantics can accumulate multiple errors:

```haskell
-- Using Validation instead of Either
validateUser :: UserInput -> Validation [Error] User
validateUser input = User
    <$> validateName input.name
    <*> validateEmail input.email
    <*> validateAge input.age
```

This collects all validation errors rather than stopping at the first failure. The Applicative instance combines multiple Either-like values, aggregating errors when all inputs are Left.

**Converting between Either and other types:**

Either serves as a general error handling mechanism that converts to/from other representations:

```rust
fn either_to_option<E, T>(e: Either<E, T>) -> Option<T> {
    match e {
        Right(v) => Some(v),
        Left(_) => None
    }
}

fn either_to_result<E, T>(e: Either<E, T>) -> Result<T, E> {
    match e {
        Right(v) => Ok(v),
        Left(e) => Err(e)
    }
}
```

This flexibility lets Either interface with APIs expecting Option or Result while preserving error information where appropriate.

**Choosing between Left and Right:**

By convention, Right represents success because "right" suggests correctness. However, Either is fundamentally symmetric—nothing prevents using Left for success. Some APIs use Left for primary values in non-error contexts:

```haskell
-- Using Either for tagged union without error semantics
type Response = Either Text Binary
```

Here neither Left nor Right represents an error; they're alternative valid response types. The error-handling convention is just that—a convention enabling consistent Functor/Monad behavior across codebases.

**[Inference] Comparison with Result:**

Result types are Either specialized for error handling with fixed semantics (Ok/Err, Success/Failure). Either is more general, supporting any two-type choice. Languages with Result typically use it for errors and Either for other dichotomies. Languages with only Either use it for both purposes, relying on conventions.

