## Safe Navigation


Safe navigation provides operators and constructs that short-circuit when encountering null or undefined values, propagating the absence through a chain of operations without throwing exceptions. This allows deeply nested property access and method calls without explicit null checks at each level.

The most common implementation is the optional chaining operator, which stops evaluation and returns undefined when it encounters a null or undefined value. Functional languages often provide this through Maybe/Option monads or similar abstractions.

**Key Points:**

- Eliminates deeply nested null checks in property access chains
- Returns a consistent sentinel value (null, undefined, or None) when any step fails
- Composes naturally with other functional patterns like default values and mapping
- Reduces visual noise and improves readability for optional data traversal

**Example:**

```javascript
// Without safe navigation
function getUserCity(user) {
  if (user !== null && user !== undefined) {
    if (user.address !== null && user.address !== undefined) {
      if (user.address.city !== null && user.address.city !== undefined) {
        return user.address.city;
      }
    }
  }
  return 'Unknown';
}

// With safe navigation (optional chaining)
function getUserCity(user) {
  return user?.address?.city ?? 'Unknown';
}

// Array safe navigation
const firstActiveUserCity = users?.[0]?.address?.city;

// Method call safe navigation
const discount = user?.subscription?.calculateDiscount?.();
```

In functional languages with Maybe/Option types:

```haskell
-- Haskell example
getUserCity :: Maybe User -> String
getUserCity user = 
  fromMaybe "Unknown" $ user >>= address >>= city
  
-- Or with do-notation
getUserCity user = fromMaybe "Unknown" $ do
  u <- user
  addr <- address u
  city addr
```

```scala
// Scala example
def getUserCity(user: Option[User]): String =
  user
    .flatMap(_.address)
    .flatMap(_.city)
    .getOrElse("Unknown")
```

**Combining with other operations:**

```javascript
// Safe navigation with mapping
const cityNames = users
  .map(u => u?.address?.city)
  .filter(city => city !== undefined);

// Safe navigation with default values
const config = {
  timeout: settings?.network?.timeout ?? 5000,
  retries: settings?.network?.retries ?? 3
};

// Safe navigation with transformation
const upperCityName = user?.address?.city?.toUpperCase() ?? 'UNKNOWN';
```

**Considerations:**

- [Inference] Overuse can hide underlying data quality issues—sometimes null should be treated as an error
- Different languages handle intermediate nulls differently (return null vs undefined vs None)
- Performance impact is typically negligible but can matter in tight loops with many checks
- Works best for truly optional data; required data should fail fast rather than propagate absence

