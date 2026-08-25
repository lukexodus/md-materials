## Null Object Pattern


The null object pattern replaces null references with objects that implement expected interfaces but provide neutral, do-nothing behavior. This eliminates null checks and prevents null pointer exceptions by ensuring all references point to valid objects.

Instead of returning null or undefined when an operation fails or a value is absent, you return a special null object that conforms to the same interface as a real object. This object responds to all the same methods but typically returns safe default values or performs no operations.

**Key Points:**

- Eliminates conditional null checks scattered throughout code
- Maintains type consistency—callers always receive the expected type
- Reduces cognitive overhead by allowing uniform object handling
- Particularly useful for optional dependencies, default behaviors, and missing data scenarios

**Example:**

```javascript
// Without null object pattern
class User {
  constructor(name, subscription) {
    this.name = name;
    this.subscription = subscription; // might be null
  }
  
  getDiscount() {
    if (this.subscription === null) {
      return 0;
    }
    return this.subscription.getDiscount();
  }
}

// With null object pattern
class NoSubscription {
  getDiscount() { return 0; }
  isActive() { return false; }
  getRenewalDate() { return null; }
}

class PremiumSubscription {
  getDiscount() { return 0.2; }
  isActive() { return true; }
  getRenewalDate() { return this.renewalDate; }
}

class User {
  constructor(name, subscription = new NoSubscription()) {
    this.name = name;
    this.subscription = subscription;
  }
  
  getDiscount() {
    return this.subscription.getDiscount(); // no null check needed
  }
}
```

The pattern works particularly well with algebraic data types and sum types, where the null object represents one variant of the type. In languages with rich type systems, you can encode the null object as a specific case in a discriminated union.

**Considerations:**

- The null object must implement all methods of the interface to maintain substitutability
- Multiple null objects may be needed for different contexts (e.g., NullUser vs NullSubscription)
- [Inference] The pattern can increase code complexity if the interface is large or frequently changing, as the null object must be kept in sync
- Works best when there's a sensible "do nothing" or default behavior for all operations

