## Either Monad Concept


The Either monad represents computations that can result in one of two possible types: conventionally a Left value (typically representing failure or an alternative path) or a Right value (typically representing success). Unlike Maybe/Option which only signals presence or absence, Either carries information about why a computation didn't produce a Right value.

As a monad, Either provides flatMap/bind operations that enable composition while automatically handling the branching logic. When a Left value appears in a chain of operations, subsequent operations are skipped, and the Left value propagates through to the final result.

**Key Points:**

- Either<L, R> is a sum type with two variants: Left\<L> and Right\<R>
- By convention, Right represents the "right" (correct) path, Left represents alternatives
- The monad instance operates on the Right value, short-circuiting on Left
- Either is right-biased in its functor and monad instances
- It provides principled error handling without exceptions

The type signature:

```haskell
data Either a b = Left a | Right b

instance Functor (Either a) where
  fmap f (Right x) = Right (f x)
  fmap _ (Left x) = Left x

instance Monad (Either a) where
  return = Right
  Right x >>= f = f x
  Left x >>= _ = Left x
```

**Example:**

```scala
sealed trait Either[+L, +R]
case class Left[+L](value: L) extends Either[L, Nothing]
case class Right[+R](value: R) extends Either[Nothing, R]

def divide(a: Int, b: Int): Either[String, Int] =
  if (b == 0) Left("Division by zero")
  else Right(a / b)

def sqrt(n: Int): Either[String, Double] =
  if (n < 0) Left("Negative number")
  else Right(Math.sqrt(n.toDouble))

// Composing with for-comprehension (monadic bind)
def calculate(a: Int, b: Int): Either[String, Double] =
  for {
    divided <- divide(a, b)
    result <- sqrt(divided)
  } yield result
```

**Output:**

```scala
calculate(16, 4)  // Right(2.0)
calculate(10, 0)  // Left("Division by zero")
calculate(-4, 2)  // Left("Negative number")
```

The Either monad's power comes from its composition properties. When multiple Either-returning functions compose, the first Left value short-circuits the entire chain:

```typescript
type Either<L, R> = 
  | { tag: 'left'; value: L }
  | { tag: 'right'; value: R };

const left = <L, R>(value: L): Either<L, R> => 
  ({ tag: 'left', value });

const right = <L, R>(value: R): Either<L, R> => 
  ({ tag: 'right', value });

const flatMap = <L, R, S>(
  fn: (value: R) => Either<L, S>
) => (either: Either<L, R>): Either<L, S> => {
  return either.tag === 'right' 
    ? fn(either.value) 
    : either;
};

// Composition
const pipeline = (input: string) =>
  right(input)
    |> flatMap(parseJSON)
    |> flatMap(validateSchema)
    |> flatMap(transform)
    |> flatMap(save);
```

Either supports multiple error types through union types or parameterized error channels:

```haskell
-- Multiple error types
data ValidationError = EmptyField | InvalidFormat | TooLong
data DatabaseError = ConnectionFailed | QueryError String
data AppError = Validation ValidationError | Database DatabaseError

processRequest :: Request -> Either AppError Response
```

The bifunctor nature of Either allows mapping over both channels:

```haskell
bimap :: (a -> c) -> (b -> d) -> Either a b -> Either c d
bimap f _ (Left x) = Left (f x)
bimap _ g (Right x) = Right (g x)

-- Transform both error and success types
result = bimap 
  (formatError)     -- Handle Left
  (formatResponse)  -- Handle Right
  computation
```

Advanced patterns include converting between Either and other monadic types:

```haskell
-- Either to Maybe
eitherToMaybe :: Either a b -> Maybe b
eitherToMaybe (Right x) = Just x
eitherToMaybe (Left _) = Nothing

-- Maybe to Either
maybeToEither :: a -> Maybe b -> Either a b
maybeToEither err Nothing = Left err
maybeToEither _ (Just x) = Right x
```

**Example (Error accumulation):**

While standard Either short-circuits on the first Left, a variation called Validation uses an applicative functor to accumulate errors:

```haskell
-- Using Validation from Data.Validation
data Validation err a = Failure err | Success a

-- Applicative instance combines errors with Semigroup
instance Semigroup err => Applicative (Validation err) where
  pure = Success
  Failure e1 <*> Failure e2 = Failure (e1 <> e2)
  Failure e1 <*> Success _ = Failure e1
  Success _ <*> Failure e2 = Failure e2
  Success f <*> Success a = Success (f a)

-- Validation accumulates all errors
validateUser :: UserData -> Validation [Error] User
validateUser userData = 
  User <$> validateName (name userData)
       <*> validateEmail (email userData)
       <*> validateAge (age userData)
-- Returns all validation errors, not just first
```

The Either monad integrates with do-notation or similar syntactic sugar in most functional languages, making complex error-handling chains readable:

```haskell
processOrder :: OrderRequest -> Either OrderError Order
processOrder req = do
  customer <- lookupCustomer (customerId req)
  inventory <- checkInventory (items req)
  validated <- validatePayment (payment req)
  order <- createOrder customer inventory validated
  return order
-- Any Left value short-circuits and returns immediately
```

**Conclusion:** Either provides a type-safe, composable approach to error handling that makes failure cases explicit in function signatures. The monadic interface allows complex branching logic to be expressed as linear composition, while the type system ensures all error cases are handled. Combined with pattern matching, Either enables exhaustive handling of both success and failure paths.

---

