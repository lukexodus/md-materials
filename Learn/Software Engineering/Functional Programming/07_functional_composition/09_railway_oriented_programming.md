## Railway-Oriented Programming


Railway-oriented programming is a design pattern that models computation as a railway track with two rails: a success path and a failure path. Functions act as switches that keep data on the success track or divert it to the failure track, where it stays until explicitly handled. This approach makes error handling explicit, composable, and type-safe.

The metaphor addresses a fundamental challenge: composing functions that can fail. Traditional exception-based approaches break composition because exceptions bypass the normal return flow. Railway-oriented programming treats errors as values, allowing them to flow through the system predictably.

**Key Points:**

- Operations are either two-track (can fail) or one-track (always succeed)
- Once on the failure track, subsequent operations are bypassed automatically
- Error information accumulates along the failure path
- Success and failure types are distinct, enabling type-driven correctness
- Composition remains simple because all functions follow the same protocol

The pattern typically uses Result or Either types to represent the two tracks:

```typescript
type Result<T, E> = 
  | { success: true; value: T }
  | { success: false; error: E };
```

**Example:**

```fsharp
// F# implementation
let validateInput input =
    if String.length input > 0 
    then Ok input
    else Error "Input cannot be empty"

let parseNumber str =
    match Int32.TryParse(str) with
    | true, num -> Ok num
    | false, _ -> Error "Not a valid number"

let doubleIfEven num =
    if num % 2 = 0 
    then Ok (num * 2)
    else Error "Number must be even"

// Composing with bind (>>=)
let processInput input =
    input
    |> validateInput
    |> Result.bind parseNumber
    |> Result.bind doubleIfEven
```

**Output:**

```
processInput "8"  // Ok 16
processInput "7"  // Error "Number must be even"
processInput "abc" // Error "Not a valid number"
processInput ""    // Error "Input cannot be empty"
```

Railway-oriented programming provides several composition operators:

- **Bind (>>=)**: Connects two-track functions, propagating failures automatically
- **Map**: Converts one-track functions into two-track functions
- **Tee**: Executes side effects on the success track without changing values
- **Try-catch**: Wraps exception-throwing code into the railway paradigm
- **Switch**: Provides recovery logic for specific failure cases

**Example (Advanced composition):**

```typescript
const bind = <T, U, E>(
  fn: (value: T) => Result<U, E>
) => (result: Result<T, E>): Result<U, E> => {
  if (result.success) {
    return fn(result.value);
  }
  return result;
};

const map = <T, U, E>(
  fn: (value: T) => U
) => (result: Result<T, E>): Result<U, E> => {
  if (result.success) {
    return { success: true, value: fn(result.value) };
  }
  return result;
};

// Building a pipeline
const processUser = (data: string) =>
  validateInput(data)
    .then(bind(parseJSON))
    .then(bind(validateUser))
    .then(map(normalizeUser))
    .then(bind(saveToDatabase));
```

The pattern extends to handling multiple failures through validation. Instead of stopping at the first error, validation can accumulate all errors using a different structure:

```haskell
data Validation e a = Failure [e] | Success a

-- Applicative instance allows combining validations
validateUser user = 
  User <$> validateName (name user)
       <*> validateEmail (email user)
       <*> validateAge (age user)
-- Collects all validation errors, not just the first
```

Railway-oriented programming integrates seamlessly with async operations. The two-track model extends naturally to promises or async/await patterns, where both success values and errors flow through the same compositional structure.

**Conclusion:** This pattern makes error handling a first-class concern in function composition. By encoding success and failure in types, it eliminates entire classes of bugs related to forgotten error handling, null references, or uncaught exceptions. The railway metaphor provides an intuitive mental model for reasoning about complex data flows.

