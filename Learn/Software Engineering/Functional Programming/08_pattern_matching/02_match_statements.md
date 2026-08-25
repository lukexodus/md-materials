## Match Statements


Match statements provide the syntactic foundation for pattern matching, offering a multi-way branch construct where each branch is associated with a pattern and an optional guard condition. The statement evaluates patterns sequentially until finding the first match, then executes the corresponding expression or block.

The syntax typically follows a match/case structure where the scrutinee (the value being matched) is specified once, and each case pattern is evaluated against it. This differs from if-elif chains by enabling the compiler to perform optimizations based on pattern structure and ensuring complete coverage through exhaustiveness analysis.

**Key Points:**

- Patterns are evaluated top-to-bottom; order matters
- First matching pattern wins (no fall-through like switch statements)
- Can include guard clauses for additional runtime conditions
- Variables bound in patterns are scoped to that branch
- Non-exhaustive matches may produce compiler warnings or errors

Guards extend pattern matching by adding boolean conditions that must be satisfied for a match to succeed. This allows you to combine structural matching with value-based predicates:

**Example:**

```python
def categorize(value):
    match value:
        case int(x) if x < 0:
            return "negative"
        case int(x) if x == 0:
            return "zero"
        case int(x) if x > 0:
            return "positive"
        case float(x) if x.is_integer():
            return "float integer"
        case _:
            return "other"
```

The underscore pattern (`_`) serves as a wildcard that matches anything, commonly used as the final catch-all case to ensure exhaustiveness. Unlike named variables, the wildcard doesn't bind a value, signaling that the matched data isn't used in that branch.

Match statements maintain expression semantics in functional languages, meaning the entire match construct evaluates to a value. Each branch must return a value of compatible type, allowing the match to be used in any expression context:

**Example:**

```haskell
factorial n = match n with
    | 0 -> 1
    | n -> n * factorial (n - 1)
```

Pattern matching integrates with type systems to provide compile-time guarantees. In languages with refinement types or dependent types, patterns can encode invariants that the type checker verifies, eliminating entire classes of runtime errors.

**Conclusion:** Match statements transform complex conditional logic into declarative pattern descriptions, improving readability while enabling powerful compiler optimizations and correctness guarantees.

