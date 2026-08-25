## Avoid magic numbers


Magic numbers are hard-coded numeric literals that appear directly in source code without explanation of their meaning. They obscure intent, making code difficult to read, understand, and maintain. Replacing them with named constants or enumerations provides semantic context and a single source of truth for updates.

**Key Points**

- **Semantic Clarity:** A number like `86400` requires the reader to calculate or guess its meaning. A constant named `SECONDS_IN_A_DAY` communicates intent immediately.
    
- **Maintainability:** If a value changes (e.g., a tax rate or buffer size), updating a magic number requires finding every occurrence, risking missed updates or accidental modification of unrelated matching numbers. A constant is updated in one place.
    
- **Refactoring Safety:** Named constants reduce the risk of "search and replace" errors where identical numbers with different meanings (e.g., `10` for max retries and `10` for a timeout) are inadvertently changed together.
    
- **Type Safety:** In strongly typed languages, replacing integers with Enums prevents invalid values from being passed to functions.
    

**Example**

_Bad Practice_

JavaScript

```
function calculateDiscount(price) {
  // What does 0.05 represent? What is the condition price > 100?
  if (price > 100) {
    return price * (1 - 0.05);
  }
  return price;
}

// Usage in loop
for (let i = 0; i < 52; i++) {
   // ...
}
```

_Good Practice_

JavaScript

```
const DISCOUNT_RATE = 0.05;
const MINIMUM_PRICE_FOR_DISCOUNT = 100;
const WEEKS_IN_YEAR = 52;

function calculateDiscount(price) {
  if (price > MINIMUM_PRICE_FOR_DISCOUNT) {
    return price * (1 - DISCOUNT_RATE);
  }
  return price;
}

for (let i = 0; i < WEEKS_IN_YEAR; i++) {
   // ...
}
```

