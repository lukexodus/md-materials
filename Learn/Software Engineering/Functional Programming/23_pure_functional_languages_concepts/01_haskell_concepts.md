## Haskell concepts


Haskell represents pure lazy functional programming taken to its logical extreme. The language enforces purity through its type system, making side effects explicit and trackable.

**Lazy evaluation by default**

Haskell evaluates expressions only when their results are needed. This enables infinite data structures and compositional programming patterns that would be impossible in strict languages. You can define `ones = 1 : ones` as an infinite list, and operations like `take 5 ones` work perfectly because only the needed elements are computed. Lazy evaluation also enables equational reasoning—you can substitute equals for equals throughout your program.

**Type classes and ad-hoc polymorphism**

Type classes provide constrained polymorphism, allowing functions to work across types that share common behavior. The `Eq`, `Ord`, `Show` type classes define interfaces that types can implement. Unlike inheritance, type classes separate data definition from behavior implementation—you can make existing types instances of new type classes retroactively. This enables powerful abstractions like `Functor`, `Applicative`, and `Monad`.

**Monads for effect management**

Monads encapsulate computational contexts and side effects in a pure language. The `IO` monad sequences input/output operations, `Maybe` handles optional values, `Either` manages errors, and `State` threads state through computations. Monads provide `return` (or `pure`) to lift values and `>>=` (bind) to sequence operations. Do-notation provides syntactic sugar making monadic code look imperative while remaining purely functional.

**Strong static typing with inference**

Haskell's Hindley-Milner type system infers most types automatically while catching errors at compile time. You rarely write type signatures for local definitions, yet the compiler ensures type safety. Algebraic data types combined with pattern matching provide exhaustiveness checking—the compiler warns if you haven't handled all cases. Parametric polymorphism ensures functions work uniformly across all types, providing strong reasoning guarantees.

**Algebraic data types and pattern matching**

ADTs combine sum types (alternatives) and product types (combinations). `data Maybe a = Nothing | Just a` defines a type that's either `Nothing` or `Just` wrapping a value. Pattern matching deconstructs these types safely. You can pattern match in function definitions, case expressions, and let bindings. Guards and as-patterns provide additional matching capabilities.

**Higher-kinded types**

Haskell's type system allows types that take other types as parameters. `Functor`, `Monad`, and similar abstractions are defined over type constructors, not concrete types. This enables writing functions polymorphic over any functor or monad, leading to highly reusable code. You can define `fmap` once and have it work for lists, trees, optionals, and any other functor.

**Purity and referential transparency**

Every Haskell function is referentially transparent—you can replace a function call with its result without changing program behavior. This makes reasoning about code mechanical: no hidden state, no action-at-a-distance. The type system enforces this by distinguishing pure computations from effectful ones through types like `IO a`.

**Immutability everywhere**

All data structures are immutable by default. "Modifying" a list or tree creates a new structure sharing most data with the original. The compiler and runtime optimize these patterns aggressively through techniques like deforestation and strictness analysis.

