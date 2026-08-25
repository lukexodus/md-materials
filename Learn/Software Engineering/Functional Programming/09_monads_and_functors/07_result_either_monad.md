## Result/Either Monad


The Result/Either monad extends Maybe by carrying error information. Where Maybe only indicates failure, Result/Either provides context about why the failure occurred. It has two cases: `Ok`/`Right` for success and `Err`/`Left` for failure.

**Key Points:**

- Preserves error information throughout the computation chain
- Enables typed error handling without exceptions
- First error short-circuits, subsequent operations are skipped
- Biased toward the success case (Right-biased in Either)

The monadic operations work identically to Maybe, but now failures carry diagnostic data. This makes debugging substantially easier while maintaining the compositional benefits. The error type can be anything: strings, enums, custom error types, or even accumulated errors.

**Example:**

```rust
enum AppError {
    NotFound(String),
    ValidationError(String),
    DatabaseError(String),
}

fn find_user(id: u32) -> Result<User, AppError> {
    if id > 0 { Ok(User { id, name: "Alice" }) }
    else { Err(AppError::NotFound(format!("User {} not found", id))) }
}

fn validate_age(user: &User) -> Result<&User, AppError> {
    if user.age >= 18 { Ok(user) }
    else { Err(AppError::ValidationError("User must be 18+".to_string())) }
}

fn save_to_db(user: &User) -> Result<(), AppError> {
    // Database operation simulation
    Ok(())
}

fn process_user(id: u32) -> Result<(), AppError> {
    find_user(id)
        .and_then(|u| validate_age(&u))
        .and_then(|u| save_to_db(u))
}
```

**Output:**

```rust
process_user(1)   // Ok(())
process_user(0)   // Err(NotFound("User 0 not found"))
process_user(1) where age = 15  // Err(ValidationError("User must be 18+"))
```

Railway-oriented programming visualizes Result/Either chains as trains on tracks. The success path runs on one track, failures switch to a parallel error track. Once on the error track, the train stays there, bypassing all subsequent operations.

**Key Points:**

- `map_err` transforms error values without affecting success
- `recover` catches specific errors and returns to success path
- `and_then`/`flatMap` chains operations that may fail
- Accumulating errors requires Applicative, not just Monad

Error accumulation is a distinct pattern where multiple validation errors are collected rather than short-circuiting on the first. This requires Validation applicative rather than monadic bind.

**Example:**

```haskell
data Validation e a = Failure e | Success a

instance Semigroup e => Applicative (Validation e) where
  pure = Success
  Success f <*> Success x = Success (f x)
  Failure e1 <*> Failure e2 = Failure (e1 <> e2)
  Failure e <*> _ = Failure e
  _ <*> Failure e = Failure e

validateUser :: String -> Int -> String -> Validation [String] User
validateUser name age email =
  User <$> validateName name
       <*> validateAge age
       <*> validateEmail email
```

This collects all validation errors simultaneously rather than stopping at the first failure. The Semigroup constraint on errors (`<>`) combines multiple failures.

