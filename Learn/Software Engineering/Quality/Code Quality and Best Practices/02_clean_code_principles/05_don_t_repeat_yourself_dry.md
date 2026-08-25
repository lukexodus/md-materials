## Don't Repeat Yourself (DRY)


The Don't Repeat Yourself (DRY) principle states that "Every piece of knowledge must have a single, unambiguous, authoritative representation within a system." Often reduced to "don't copy-paste code," DRY is fundamentally about the duplication of _knowledge_ and _intent_, not just text. If you change a business rule, schema, or algorithm, you should only have to update it in one place.

**Types of Duplication**

- **Logic Duplication:** The same algorithm or validation rule appears in multiple places. If the rule changes (e.g., password length requirement), all instances must be hunted down and fixed.
    
- **Data Duplication:** The same data structure or schema definition is manually repeated across different layers (e.g., identical SQL, backend DTO, and frontend model definitions that are not synchronized).
    
- **Semantic Duplication:** Two blocks of code look different but perform the exact same business function. This is harder to detect than textual duplication.
    

The "WET" Counterpart

The opposite of DRY is WET (Write Everything Twice, or We Enjoy Typing). WET code creates technical debt because divergent changes are inevitable. If two identical blocks of code are modified independently over time, the system becomes inconsistent and buggy.

**Nuances and Risks**

- **Incidental Duplication:** Just because two blocks of code look the same doesn't mean they represent the same knowledge. If two different modules (e.g., Billing and Shipping) currently use the same validation logic but evolve independently, unifying them creates a rigid coupling. This is often called "premature DRY."
    
- **The Rule of Three:** A common heuristic is to wait until logic is duplicated three times before refactoring it into a shared abstraction. This prevents creating wrong abstractions too early.
    

**Example**

Violating DRY:

Here, the calculation for the total price with tax is repeated. If the tax rate changes, both functions break.

JavaScript

```
function createInvoice(items) {
  let total = 0;
  items.forEach(item => {
    total += item.price * 1.20; // Hardcoded tax logic
  });
  return total;
}

function generateQuote(items) {
  let estimated = 0;
  items.forEach(item => {
    estimated += item.price * 1.20; // Duplicated knowledge
  });
  return estimated;
}
```

Adhering to DRY:

The tax logic is encapsulated in a single source of truth.

JavaScript

```
const TAX_RATE = 1.20;

function applyTax(amount) {
  return amount * TAX_RATE;
}

function createInvoice(items) {
  return items.reduce((total, item) => total + applyTax(item.price), 0);
}

function generateQuote(items) {
  return items.reduce((est, item) => est + applyTax(item.price), 0);
}
```

