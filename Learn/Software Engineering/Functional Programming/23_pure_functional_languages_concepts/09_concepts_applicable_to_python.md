## Concepts applicable to Python


Python isn't a pure functional language, but functional programming concepts enhance Python codebases significantly, particularly for data processing pipelines and concurrent systems.

**Immutability with Tuples and NamedTuples**

Use tuples and `collections.namedtuple` or `typing.NamedTuple` for immutable data structures. Frozen dataclasses (`@dataclass(frozen=True)`) provide immutable classes with pattern matching support in Python 3.10+. Immutability eliminates defensive copying and makes concurrent code safer. The `tuple` unpacking syntax enables destructuring similar to pattern matching.

**Higher-Order Functions**

`map`, `filter`, and `functools.reduce` transform collections functionally. `functools.partial` creates specialized functions by pre-filling arguments. Decorators are higher-order functions that transform other functions, enabling cross-cutting concerns like memoization, logging, or access control. Function composition through `functools.reduce` or libraries like `toolz` chains transformations.

**Iterators and Generators**

Generators provide lazy evaluation through `yield`, producing values on-demand without materializing entire sequences. Generator expressions offer concise syntax for simple transformations. `itertools` provides functional primitives like `chain`, `cycle`, `accumulate`, and `starmap`. This lazy evaluation mirrors Elixir's streams, enabling efficient processing of large or infinite sequences.

**Comprehensions**

List, dict, and set comprehensions provide declarative syntax for transformations and filtering. Generator comprehensions create lazy iterators. Nested comprehensions flatten nested loops into readable expressions. These combine mapping and filtering into single expressions without explicit loops.

**Pattern Matching (3.10+)**

Structural pattern matching through `match`/`case` enables Erlang-like pattern matching on data structures. Guards use `if` clauses. Patterns can destructure sequences, mappings, and objects. Or-patterns combine multiple alternatives. This brings functional elegance to branching logic previously handled by if-elif chains.

**Type Hints and mypy**

Type hints enable static type checking while maintaining Python's dynamic nature. Generic types parameterize containers and functions. Protocol types define structural interfaces. Union types represent sum types similar to Erlang's tagged tuples. `mypy` catches type errors at development time, bringing stronger guarantees to functional codebases.

**Operator and itemgetter**

`operator.itemgetter` and `operator.attrgetter` create accessor functions for sorting and mapping. `operator.methodcaller` creates functions that call methods. These replace lambdas with more efficient C implementations and provide clearer intent.

**toolz and cytoolz**

The `toolz` library provides functional utilities like `pipe` for threading values through transformations, `curry` for partial application, `compose` for function composition, and `partition` for splitting sequences. `cytoolz` is the Cython-optimized version offering significant performance improvements. These fill gaps in Python's standard library for functional programming.

**Multiprocessing and ProcessPoolExecutor**

Process-based parallelism provides isolation similar to Erlang processes, though with higher overhead. `concurrent.futures.ProcessPoolExecutor` manages worker processes. `multiprocessing.Queue` and `multiprocessing.Pipe` enable message passing. While not as lightweight as Erlang processes, this architecture scales across CPU cores for CPU-bound work.

**Immutable Collections Libraries**

`pyrsistent` provides persistent data structures (vectors, maps, sets) with structural sharing. Operations return new versions efficiently without copying entire structures. `frozendict` and `frozenset` provide immutable alternatives to built-in mutable collections. These enable truly functional data manipulation with guaranteed immutability.

**Ray and Distributed Computing**

Ray brings actor-model programming to Python with distributed state and remote functions. Tasks and actors scale across clusters transparently. While not pure functional programming, Ray's design borrows heavily from Erlang's process model for building distributed systems.

**Exception Handling with Result Types**

Libraries like `returns` provide `Result` and `Maybe` types for explicit error handling without exceptions. The railway-oriented programming pattern chains operations that might fail, short-circuiting on the first error. This makes error paths explicit in type signatures and enables composition without try-except blocks.

---
