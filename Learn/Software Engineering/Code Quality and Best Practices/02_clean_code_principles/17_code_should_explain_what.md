## Code should explain what


The code itself is the only source of truth regarding the behavior of the software. Therefore, the implementation details—the "what"—must be immediately transparent through the syntax, structure, and naming conventions used. If a developer needs to read a block of code three times to understand what data is being transformed, the code has failed to explain "what."

**Key Points**

- **Semantic Naming:** Variable, function, and class names must precisely describe the entity or action. `calculateTotalRevenue()` is infinitely superior to `calc()` or `doIt()`.
    
- **Explicit Control Flow:** Avoid complex, nested ternary operators or obscure one-liners that prioritize brevity over clarity. The flow of execution should be linear and predictable.
    
- **Single Responsibility Principle:** A function should do one thing. If a function name contains "And" (e.g., `validateAndSaveUser`), it is likely doing too much, obscuring the "what."
    
- **Type Hinting and Signatures:** In dynamically typed languages, explicit type hints provide immediate context about what data structures are flowing through the system.
    

**Example**

_Bad (Obscure):_

JavaScript

```
// What is 'd'? What is 86400000? What does the filter do?
const f = (d) => {
    return d.filter(x => (new Date() - x.t) < 86400000);
}
```

_Good (Explicit):_

JavaScript

```
const MILLISECONDS_IN_A_DAY = 86_400_000;

function filterRecentTransactions(transactions) {
    const now = new Date();
    return transactions.filter(transaction => {
        const timeElapsed = now - transaction.timestamp;
        return timeElapsed < MILLISECONDS_IN_A_DAY;
    });
}
```

