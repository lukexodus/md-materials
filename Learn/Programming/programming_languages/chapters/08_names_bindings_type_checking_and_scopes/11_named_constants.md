## Named Constants

### Definition

A named constant is an identifier bound to a value that cannot be changed after its initial binding. It combines the readability benefit of a named identifier with the safety guarantee that the associated value remains fixed for the constant's lifetime. Named constants are also called manifest constants in some language design literature, particularly when the value must be known at compile time.

### Purpose and Motivation

**Key Points**

- Replaces "magic numbers" or "magic strings" with self-documenting names, improving code readability and maintainability.
- Centralizes a value's definition so that changing it requires editing only one location rather than every point of use.
- Enables the compiler or interpreter to catch accidental reassignment as an error, preventing an entire class of bugs.
- Can allow compiler optimizations, since a known, unchanging value can sometimes be substituted directly at compile time rather than read from memory at runtime.

Consider a program that computes areas of circles. Writing `3.14159` repeatedly throughout the code is error-prone (a typo in one occurrence but not another) and unclear (why this number, and is it precise enough). Declaring it once as `PI` communicates intent and guarantees consistency.

### Binding Time for Named Constants

The value of a named constant can be bound at different points, and this timing affects what kinds of expressions are legal on the right-hand side.

- **Static binding (compile-time):** The value is fixed when the program is translated. This is common for constants whose value is a literal or an expression composed entirely of other compile-time constants.
- **Dynamic binding (execution-time, bound once):** The value is computed when the declaration is elaborated at runtime, but afterward remains fixed for the rest of the constant's scope. This allows a constant's value to depend on a parameter or another runtime-computed value while still forbidding subsequent change.

[Inference] The choice between allowing only static or also dynamic binding for named constants is a deliberate language design decision that trades off compiler optimization opportunity against expressive flexibility; languages that support dynamically bound named constants generally cannot fold their values into the compiled code the way statically bound ones can.

### Examples Across Languages

**Example**

In C, named constants are traditionally created via the preprocessor, which performs pure textual substitution before compilation:

```c
#define MAX_USERS 100
```

Modern C and C++ prefer `const` (a qualified variable, statically or dynamically bindable) or, in C++, `constexpr` (guaranteed compile-time evaluation):

```cpp
const int maxUsers = 100;        // may be statically or dynamically bound
constexpr double pi = 3.14159;   // must be a compile-time constant
```

In Ada, named constants are declared explicitly with the `constant` keyword, and the value may be any expression, including one evaluated at elaboration time:

```ada
Max_Users : constant Integer := 100;
Buffer_Size : constant Integer := Compute_Size(Config);
```

In Python, there is no language-enforced named constant; convention (all-uppercase identifiers) signals intent, but the interpreter does not prevent reassignment:

```python
MAX_USERS = 100  # convention only, not enforced
```

In Java, `final` fields serve this role:

```java
final int MAX_USERS = 100;
```

In JavaScript, `const` declarations bind a name to a value for the block scope, preventing reassignment of the binding itself:

```javascript
const MAX_USERS = 100;
```

### The Reassignment vs. Immutability Distinction

**Key Points**

- A named constant guarantees the *binding* cannot be reassigned to point at a different value.
- This is distinct from guaranteeing the referenced *object* is immutable.
- For primitive/scalar types, these two guarantees coincide, since there is nothing to mutate except the value itself.
- For reference or composite types (arrays, objects, structures), the binding can be fixed while the contents of the referenced object remain mutable.

This is a frequent source of confusion in languages like JavaScript:

```javascript
const list = [1, 2, 3];
list.push(4);       // legal: the array object is mutated, not the binding
list = [5, 6];       // illegal: reassigning the binding itself
```

Here, `list` as a name is permanently bound to one particular array object, but that array's internal state is still mutable. True deep immutability requires an additional mechanism (such as `Object.freeze()` in JavaScript, or an immutable collection type in other languages).

### Named Constants and Type Checking

Named constants participate in a language's static or dynamic type system like any other identifier. A statically typed language typically requires the constant's type either to be declared explicitly or inferred from its initializing expression, and that type then governs all subsequent uses of the name. Because the value cannot change, some languages use the constant's initializing expression to perform stricter compile-time checks than would be possible for an ordinary variable, such as verifying that an array size constant is a positive integer literal.

### Scope Rules for Named Constants

Named constants follow the same scoping rules as variables in most languages: a constant declared within a block, function, or module is visible according to the enclosing language's scope resolution rules (lexical/static scoping in most modern languages). A constant declared at the outermost/global level is typically visible throughout the program or throughout the module that declares it, subject to any export/visibility modifiers the language provides.

### Visual: Binding Time Spectrum

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 220">
<title>Named Constant Binding Time Spectrum (svg_diagram)</title>
<rect x="0" y="0" width="760" height="220" fill="#ffffff" />
<text x="380" y="28" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Named Constant Binding Time Spectrum (svg_diagram)</text>
<line x1="60" y1="120" x2="700" y2="120" stroke="#333333" stroke-width="2" />
<polygon points="700,120 690,114 690,126" fill="#333333" />
<circle cx="150" cy="120" r="8" fill="#2e6da4" />
<text x="150" y="90" font-size="13" text-anchor="middle" fill="#1a1a1a">Compile-Time</text>
<text x="150" y="106" font-size="11" text-anchor="middle" fill="#555555">(Literal Binding)</text>
<text x="150" y="150" font-size="11" text-anchor="middle" fill="#555555">e.g. #define,</text>
<text x="150" y="164" font-size="11" text-anchor="middle" fill="#555555">constexpr</text>
<circle cx="400" cy="120" r="8" fill="#5cb85c" />
<text x="400" y="90" font-size="13" text-anchor="middle" fill="#1a1a1a">Link/Load-Time</text>
<text x="400" y="106" font-size="11" text-anchor="middle" fill="#555555">(Resolved Constant)</text>
<text x="400" y="150" font-size="11" text-anchor="middle" fill="#555555">e.g. static const</text>
<text x="400" y="164" font-size="11" text-anchor="middle" fill="#555555">with external refs</text>
<circle cx="620" cy="120" r="8" fill="#d9534f" />
<text x="620" y="90" font-size="13" text-anchor="middle" fill="#1a1a1a">Elaboration-Time</text>
<text x="620" y="106" font-size="11" text-anchor="middle" fill="#555555">(Dynamic Binding)</text>
<text x="620" y="150" font-size="11" text-anchor="middle" fill="#555555">e.g. Ada constant</text>
<text x="620" y="164" font-size="11" text-anchor="middle" fill="#555555">from expression</text>

<text x="380" y="200" font-size="11" text-anchor="middle" fill="`#777777`">Bound earlier → more optimization potential | Bound later → more expressive flexibility</text>

</svg>

### Advantages and Trade-offs

**Key Points**

- **Advantage:** Errors from accidental modification are caught at compile time rather than surfacing as subtle runtime bugs.
- **Advantage:** Improves self-documentation; a well-named constant explains *why* a value is what it is.
- **Advantage:** Facilitates safer maintenance, since a value used in many places is updated in exactly one place.
- **Trade-off:** Overuse of dynamically bound named constants can reduce the compiler's ability to perform constant folding and other optimizations available to purely static constants.
- **Trade-off:** In languages without enforced immutability (such as Python's naming convention), named constants offer no actual protection, only a readability convention that disciplined programmers must uphold voluntarily. [Unverified: the degree to which this convention is actually followed varies by codebase and cannot be generalized.]

### Relationship to Enumerations

Named constants are conceptually related to enumeration types, which can be viewed as a mechanism for declaring a related group of named constants together, often with the compiler auto-assigning underlying ordinal values. The distinction is that an enumeration typically introduces a new distinct type, whereas a standalone named constant merely binds a name to a value of an already-existing type.

### Conclusion

Named constants formalize a simple but powerful idea: give a fixed value a meaningful name and let the language enforce that fixity. The design space varies primarily along two axes — how strictly reassignment is prevented (from strong compiler-enforced guarantees to mere naming convention) and when the value is bound (compile-time literal versus runtime-computed but still fixed). Understanding both axes clarifies why a construct like C's `#define`, C++'s `constexpr`, Ada's `constant`, and JavaScript's `const` all serve a similar conceptual purpose while offering meaningfully different guarantees.

**Related Topics**

- Variables and the concept of an l-value/r-value
- Type checking and type equivalence
- Static vs. dynamic scoping
- Enumeration types
- Aliasing and reference semantics
- Compile-time constant folding and optimization
- Immutability in data structures (deep vs. shallow)