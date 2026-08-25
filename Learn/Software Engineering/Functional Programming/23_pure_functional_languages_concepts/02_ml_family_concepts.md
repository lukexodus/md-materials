## ML family concepts


The ML family (Standard ML, OCaml, F#) balances functional purity with pragmatic features for systems programming and real-world applications.

**Eager evaluation by default**

Unlike Haskell, ML languages use strict evaluation—expressions are evaluated when bound, not when needed. This makes performance more predictable and reasoning about execution order straightforward. Side effects happen in the order written, which simplifies interaction with the outside world.

**Module system and functors**

ML's module system separates interface (signatures) from implementation (structures). Signatures specify types and value declarations without implementation. Functors are functions from modules to modules, enabling parametric modules. You can write a functor that takes an ordered type and produces a balanced tree implementation. This provides large-scale code organization beyond what simple type classes offer.

**Row polymorphism (OCaml)**

OCaml extends ML with polymorphic variants and object types using row polymorphism. You can define variants without declaring them upfront: `` `Some x `` creates a polymorphic variant that works with any superset of tags. Objects use structural typing—any object with the required methods matches, regardless of nominal type. This provides flexibility without sacrificing type safety.

**Value restriction and mutability**

ML languages allow mutable references and imperative features. The value restriction prevents unsound type generalization in the presence of mutation—only syntactic values (not function applications) can be polymorphically generalized. This prevents type system unsoundness while allowing both pure and impure code in the same language.

**Imperative features integration**

ML languages provide mutable references, arrays, and imperative control flow (loops, exceptions) alongside functional constructs. Functions can have side effects freely—there's no `IO` monad. This makes ML suitable for systems programming and applications requiring performance or integration with imperative libraries.

**Pattern matching exhaustiveness**

ML compilers perform exhaustive pattern matching analysis, warning about non-exhaustive matches or unreachable patterns. This catches bugs at compile time. Pattern matching works on algebraic data types, records, literals, and includes guards for conditional matching.

**Type inference with explicit annotations**

Like Haskell, ML infers types but allows explicit annotations for documentation and constraint. The inference engine typically requires less annotation than Haskell due to stricter evaluation and the value restriction. Polymorphic recursion requires explicit annotations.

**Algebraic data types without higher-kinded types**

ML's ADTs work similarly to Haskell but the type system stops at first-order kinds. You cannot abstract over type constructors in Standard ML. OCaml has added some support for GADTs and first-class modules, partially bridging this gap. F# integrates with .NET's type system, providing different tradeoffs.

**Practical standard library**

ML implementations provide comprehensive standard libraries optimized for real-world use. OCaml includes efficient data structures, Unix system calls, and excellent FFI. F# integrates seamlessly with .NET libraries and provides computation expressions (similar to monads) for asynchronous programming, queries, and custom DSLs.

