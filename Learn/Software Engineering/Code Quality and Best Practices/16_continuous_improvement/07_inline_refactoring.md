## Inline Refactoring


### Conceptual Overview

Inline Refactoring acts as the inverse operation to Extraction (Extract Method, Extract Class). It involves the collapsing of abstractions—replacing a method call, variable, or class usage directly with its content or implementation.

While software architecture typically emphasizes abstraction, excessive or premature abstraction leads to fragmentation, increased cognitive load, and "execution jumping" where a developer must traverse multiple files to understand simple logic. Inlining restores locality and linearity to code execution paths when the cost of indirection outweighs the benefit of encapsulation.

### Inline Method

This pattern is applied when a method's body is just as clear as its name, or when the method exists solely to delegate to another method without adding logic (Middle Man code smell).

Heuristic for Application:

If the function signature and the jump to definition distract the reader more than the raw code within the function, inline it.

**Implementation Strategy:**

1. **Verification:** Ensure the method is not polymorphic (overridden in subclasses), as inlining will bypass dynamic dispatch.
    
2. **Parameter Replacement:** Map formal parameters to actual arguments. Care must be taken if parameters are modified within the method body; this often requires introducing temporary variables in the caller to maintain pass-by-value semantics.
    
3. **Return Handling:** If the method has multiple exit points, the logic must be refactored to a single exit point or adapted to control flow structures (like `break` or `continue`) in the target context.
    

**Code Example:**

_Before (Unnecessary Indirection):_

Python

```
def get_rating(driver):
    return _calculate_internal_score(driver) > 5

def _calculate_internal_score(driver):
    return driver.late_deliveries * -1 + 10
```

_After (Inlined):_

Python

```
def get_rating(driver):
    return (driver.late_deliveries * -1 + 10) > 5
```

### Inline Temp (Variable)

Inline Temp involves replacing a temporary variable with the expression used to assign it. This is frequently a precursor step required to perform **Extract Method**. Temporary variables can lock code into a local scope, making it difficult to extract blocks of logic that depend on them.

**Constraints:**

- The variable must be assigned exactly once (immutable usage).
    
- The expression must be side-effect free. Inlining an expression that mutates state (e.g., `user.init()`) causes the mutation to occur at every usage point, altering program behavior.
    

**Code Example:**

_Before (Blocking Extraction):_

Python

```
base_price = order.base_price()
if base_price > 1000:
    return base_price * 0.95
else:
    return base_price * 0.98
```

_After (Facilitates Query Refactoring):_

Python

```
if order.base_price() > 1000:
    return order.base_price() * 0.95
else:
    return order.base_price() * 0.98
```

### Inline Class

This refactoring collapses a class that is no longer justified. This often occurs after moving features out of a class leaves it as a "Lazy Class" or a "Data Class" with no behavior. It is also used to merge two classes that are too intimately coupled.

**Execution Flow:**

1. **Identify Host:** Choose the class that will absorb the target class's responsibilities.
    
2. **Field Migration:** Move all fields and methods from the target to the host.
    
3. **Client Update:** Update all client code referencing the target class to reference the host class.
    
4. **Deprecation:** Remove the target class definition.
    

### Risks and Anti-Patterns

#### Variable Shadowing

When inlining code into a new scope, variable names in the inlined code may conflict with existing variables in the target scope. Advanced IDEs handle this automatically, but manual refactoring requires rigorous inspection of the lexical scope.

#### Control Flow Disruption

Inlining a method that contains `return`, `break`, or `throw` statements into a loop or a different control structure alters the flow of the host method.

- A `return` in the inlined code terminates the entire host function, not just the inlined block.
    
- Guard clauses in the inlined method must be converted to conditional blocks in the host.
    

#### Evaluation Order and Side Effects

Inlining assumes that the timing of execution does not matter. If the inlined expression relies on a global state or a specific sequence of events (e.g., a getter that lazy-loads a database connection), moving that execution point can introduce race conditions or initialization errors.

### Related Topics

- Code Smells: Middle Man, Lazy Class, Speculative Generality
    
- Extract Method / Extract Class (Inverse operations)
    
- Replace Temp with Query
    
- Law of Demeter (Inlining can sometimes fix violations by removing delegates)

---

