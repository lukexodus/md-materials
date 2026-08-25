## Self-documenting code


Self-documenting code minimizes the need for auxiliary documentation by embedding understanding directly into the structure and identifiers of the source code. It relies on the principle that the clearest code reads like well-written prose in the domain language of the application.

**Key Points**

- **Extraction over Explanation:** Instead of writing a comment to explain a complex `if` condition, extract the condition into a boolean function or property with a descriptive name.
    
- **Magic Numbers and Strings:** Replace literal values with named constants or Enumerations. `if (status == 2)` is opaque; `if (status == Status.PUBLISHED)` is self-explanatory.
    
- **Guard Clauses:** Use early returns (guard clauses) to handle edge cases at the beginning of a function. This reduces indentation levels and clarifies the "happy path" logic at the end of the function.
    
- **Fluent Interfaces:** Where appropriate, design APIs that chain methods in a readable sentence structure (e.g., `Query.from('users').where('active', true).orderBy('name')`).
    

**Example**

_Before (Needs comments):_

Java

```
// Check if user is eligible for discount
// Must be a member, active, and spent over 100
if (user.type == 1 && user.status == 'A' && user.totalOrders > 100) {
    applyDiscount();
}
```

_After (Self-documenting):_

Java

```
if (user.isEligibleForGoldDiscount()) {
    applyDiscount();
}

// Inside User Class
public boolean isEligibleForGoldDiscount() {
    return this.isMember() 
        && this.isActive() 
        && this.hasSpentOver(100);
}
```

