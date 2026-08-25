## Option types


Option types represent the presence or absence of a value without using null references. An Option is a discriminated union with two cases: Some containing a value, or None representing absence. This eliminates null pointer exceptions by making optionality explicit in the type system.

**Fundamental distinction from null**

Unlike null, which can appear anywhere a reference type is expected, Option types are explicit. A function returning `Option<User>` clearly signals that a user might not exist. A function returning `User` guarantees a user will always be present. This distinction moves the possibility of absence from runtime to compile time.

**Basic operations**

Map transforms the contained value if present, returning None if the Option is empty. This allows chaining transformations on potentially absent values without explicit null checking. The operation only executes when a value exists; otherwise, None propagates through the chain unchanged.

**Extracting values safely**

Unwrapping an Option requires handling both cases. Pattern matching is the canonical approach, forcing you to specify behavior for both Some and None. Alternative methods include providing default values (getOrElse), throwing exceptions for absent values (get), or using conditional extraction that returns another Option.

**Chaining optional operations**

FlatMap chains operations that themselves return Options. When you have `Option<A>` and a function `A -> Option<B>`, flatMap produces `Option<B>` without nesting Options. This is essential for sequences of lookups or computations where each step might fail to produce a value.

**Filtering and predicates**

Filter applies a predicate to an Option's value, converting Some to None if the predicate fails. This enables conditional preservation of values based on business logic. You can express "keep this value only if it satisfies certain conditions" without explicitly checking for presence first.

**Combining Options**

When multiple Options need interaction, combinators handle various scenarios. Zipping combines two Options into an Option of a tuple, succeeding only if both are Some. Applicative operations allow applying functions wrapped in Options to values wrapped in Options, useful for optional configurations or partial data assembly.

**Relationship with collections**

Options can be viewed as collections containing zero or one element. Many operations mirror collection operations: toList converts Some to a single-element list and None to an empty list. Flatten converts `Option<Option<T>>` to `Option<T>`, useful when nested Options arise from chained operations.

**OrElse and alternatives**

OrElse provides fallback behavior, attempting an alternative Option if the first is None. This chains optional computations where later attempts serve as fallbacks. It's particularly useful for cascading lookups through multiple sources or attempting increasingly expensive operations until one succeeds.

**Conversion and interoperation**

Options convert bidirectionally with nullable values. FromNullable constructs Options from nullable references, while toNullable extracts values as nullables. This enables gradual adoption in codebases and integration with libraries that use null. However, converting to nullable sacrifices the type safety benefits.

**Monadic laws and composition**

Options form a monad, ensuring predictable composition. The identity law guarantees that wrapping a value in Some and immediately flatMapping has no effect. The associativity law ensures that the order of nesting flatMap operations doesn't matter. These laws enable reliable refactoring and reasoning about optional computations.

**Performance and optimization**

Options typically compile to efficient representations. Some languages optimize `Option<T>` to have the same memory layout as a nullable reference for reference types. For value types, it's usually a boolean flag plus the value. Pattern matching on Options often compiles to simple branch instructions.

