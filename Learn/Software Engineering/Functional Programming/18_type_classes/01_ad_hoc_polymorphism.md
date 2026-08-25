## Ad-hoc Polymorphism


Ad-hoc polymorphism enables functions to operate on multiple types with type-specific implementations, contrasting with parametric polymorphism where functions work uniformly across all types. This mechanism allows the same function name to behave differently depending on the argument types, with each behavior explicitly defined rather than derived from a single generic implementation.

The distinguishing characteristic of ad-hoc polymorphism is implementation multiplicity. Unlike parametric polymorphism where a single implementation handles all types abstractly, ad-hoc polymorphism provides distinct implementations per type. When invoking a polymorphic function, the runtime or compiler selects the appropriate implementation based on argument types.

Function overloading represents the simplest form of ad-hoc polymorphism. Multiple function definitions share a name but accept different type signatures. The compiler resolves which version to invoke based on argument types at the call site. However, traditional overloading lacks abstraction—each overload exists independently without shared interface contracts.

Type classes elevate ad-hoc polymorphism beyond simple overloading by introducing abstraction boundaries. Rather than scattered overloads, type classes define interfaces that types can implement. Functions constrained by type class requirements work with any type implementing that interface, maintaining both type-specific behavior and generic programming.

Ad-hoc polymorphism solves the expression problem's one dimension: adding new types to existing operations without modifying original code. Type classes enable retroactive implementation—applying interfaces to types after their definition, even types from external libraries. This extensibility distinguishes ad-hoc from subtype polymorphism, where types must declare interface conformance at definition time.

The mechanism provides operator overloading semantics in a principled manner. Equality, comparison, arithmetic operations, and string conversion can have type-specific definitions while maintaining consistent interfaces. A `==` operator behaves appropriately for integers, strings, custom types, and collections, with each type defining equality semantics relevant to its structure.

Dispatch resolution follows type-directed rules. In statically-typed languages, the compiler determines implementations at compile time through type inference and constraint resolution. In dynamically-typed languages, runtime type inspection selects implementations. Both approaches maintain type safety within their respective type systems.

