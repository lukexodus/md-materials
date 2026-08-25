## Maybe/Option Monad


The Maybe/Option monad encapsulates computations that may fail without throwing exceptions. It represents the presence or absence of a value through two constructors: `Just`/`Some` for success and `Nothing`/`None` for failure.

**Key Points:**

- Eliminates null pointer exceptions by making absence explicit
- Short-circuits on first `Nothing`, avoiding unnecessary computation
- Composes nullable operations without nested conditionals
- Forces explicit handling of the absent case at consumption

The monadic bind for Maybe implements automatic null-checking. When binding over `Nothing`, the function is never called, and `Nothing` propagates through the chain. This creates a safe pipeline where failure at any step stops execution gracefully.

**Example:**

```scala
case class User(name: String, email: Option[String])
case class EmailPreferences(frequency: String)

def findUser(id: Int): Option[User] = 
  if (id == 1) Some(User("Alice", Some("alice@example.com"))) else None

def getEmailPrefs(email: String): Option[EmailPreferences] =
  if (email.contains("@")) Some(EmailPreferences("daily")) else None

def notifyUser(id: Int): Option[String] = for {
  user <- findUser(id)
  email <- user.email
  prefs <- getEmailPrefs(email)
} yield s"Sending ${prefs.frequency} email to $email"
```

**Output:**

```scala
notifyUser(1)  // Some("Sending daily email to alice@example.com")
notifyUser(2)  // None (user not found)
notifyUser(1) where user.email = None  // None (email absent)
```

The power emerges when chaining multiple potentially-failing operations. Without Maybe, this would require nested if-statements checking for null at each step. The monadic structure handles all the plumbing automatically.

Common operations extend the basic monad:

- `getOrElse`: provides default values
- `orElse`: tries alternative computations
- `filter`: converts `Some` to `Nothing` based on predicates
- `fold`: unified handling of both cases

**Key Points:**

- `map` transforms present values, preserves absence
- `flatMap` chains dependent operations
- `fold` collapses to a single result handling both cases uniformly
- Pattern matching provides exhaustive case analysis

The Maybe monad also forms an Applicative, allowing independent operations to be combined. This is useful when multiple optional values need to be combined where none depends on another.

**Example:**

```haskell
liftA2 :: (a -> b -> c) -> Maybe a -> Maybe b -> Maybe c

createUser :: String -> String -> Int -> Maybe User
createUser name email age = 
  liftA2 (User name) (validateEmail email) (validateAge age)
```

