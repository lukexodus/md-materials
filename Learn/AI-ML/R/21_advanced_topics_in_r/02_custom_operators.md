## Custom Operators


R's flexible syntax allows creation of custom binary and unary operators, enabling domain-specific notations that improve code readability and create specialized computational interfaces.

**Key points:**

- Binary operators are defined as functions with names enclosed in percent signs
- Operator precedence follows R's built-in precedence rules and cannot be modified
- Custom operators should follow consistent naming conventions and documentation practices
- Overloading existing operators requires careful consideration of expected behavior

Binary operator definition follows the pattern `%name%` where `name` represents the operator function. The function must accept exactly two arguments and can perform any computation or side effect. For example, a string concatenation operator might be defined as `%+% <- function(x, y) paste0(x, y)`.

Operator precedence in R follows fixed rules that cannot be modified for custom operators. User-defined operators have the same precedence as built-in operators like `%in%` and `%*%`, falling between arithmetic and comparison operators. This precedence affects expression evaluation order and may require parentheses for clarity.

Common custom operator patterns include mathematical operations specific to domains (like `%cross%` for vector cross products), string manipulation (`%like%` for pattern matching), and data pipeline operations extending the `%>%` pipe operator concept.

Functional programming operators can implement concepts like function composition (`%o%`), partial application, or specialized mapping operations. These operators often accept functions as arguments and return modified or combined functions.

Assignment operators can be created using the `%<-%` pattern, though these require more complex implementation involving `substitute()` and assignment functions. The `zeallot` package demonstrates sophisticated multiple assignment operators.

S3 method dispatch works with custom operators, allowing different behavior based on argument classes. This enables polymorphic operators that adapt their behavior to different data types while maintaining consistent syntax.

Documentation and testing of custom operators requires special attention to operator precedence interactions, edge cases with different argument types, and clear examples of intended usage patterns. [Inference] Custom operators are most successful when they represent well-understood mathematical or domain concepts.

