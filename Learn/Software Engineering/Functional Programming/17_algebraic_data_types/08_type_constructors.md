## Type Constructors


Type constructors are parameterized type definitions that produce concrete types when applied to type arguments. They operate at the type level, constructing new types from existing ones through systematic composition and transformation.

**Nullary Type Constructors**

Zero-parameter type constructors represent concrete, complete types:

```python
@dataclass
class Unit:
    pass

@dataclass
class Boolean:
    value: bool
```

**Unary Type Constructors**

Single-parameter constructors build container or wrapper types:

```python
# Option[_] is a unary type constructor
# Option[Int] is a concrete type
@dataclass
class Some(Generic[T]):
    value: T

@dataclass
class None_:
    pass

Option = Union[Some[T], None_]

# List[_] is a unary type constructor
@dataclass
class Cons(Generic[T]):
    head: T
    tail: 'List[T]'

@dataclass
class Nil:
    pass

List = Union[Cons[T], Nil]
```

**Binary Type Constructors**

Two-parameter constructors model relationships between types:

```python
# Either[_, _] is a binary type constructor
@dataclass
class Left(Generic[L]):
    value: L

@dataclass
class Right(Generic[R]):
    value: R

Either = Union[Left[L], Right[R]]

# Pair[_, _] is a binary type constructor
@dataclass
class Pair(Generic[A, B]):
    first: A
    second: B

# Result[_, _] models computation outcomes
@dataclass
class Ok(Generic[T]):
    value: T

@dataclass
class Error(Generic[E]):
    error: E

Result = Union[Ok[T], Error[E]]
```

**Partially Applied Type Constructors**

Fix some type parameters while leaving others open:

```python
# Fix error type, leave success type open
from typing import TypeAlias

StringError: TypeAlias = Result[T, str]

# Now StringError[Int] = Result[Int, str]
def parse_int(s: str) -> StringError[int]:
    try:
        return Ok(int(s))
    except ValueError:
        return Error("Invalid integer")
```

**Nested Type Constructors**

Compose type constructors to build complex structures:

```python
# Option[List[T]] - optional list
maybe_numbers: Option[List[int]] = Some(Cons(1, Cons(2, Nil())))

# List[Option[T]] - list of optional values
numbers_with_gaps: List[Option[int]] = Cons(
    Some(1),
    Cons(None_(), Cons(Some(3), Nil()))
)

# Either[Error, Option[T]] - result that might be empty
def safe_head(lst: List[T]) -> Either[str, Option[T]]:
    match lst:
        case Nil():
            return Right(None_())
        case Cons(head=x, tail=_):
            return Right(Some(x))
```

**Type Constructor Composition**

Combine constructors systematically:

```python
# Compose Option and List
def sequence_options(lst: List[Option[T]]) -> Option[List[T]]:
    """Convert List[Option[T]] to Option[List[T]]"""
    match lst:
        case Nil():
            return Some(Nil())
        case Cons(head=None_(), tail=_):
            return None_()
        case Cons(head=Some(x), tail=xs):
            match sequence_options(xs):
                case None_():
                    return None_()
                case Some(rest):
                    return Some(Cons(x, rest))

# Compose Result and List
def traverse_results(
    f: Callable[[T], Result[U, E]], 
    lst: List[T]
) -> Result[List[U], E]:
    """Apply effectful function, short-circuiting on error"""
    match lst:
        case Nil():
            return Ok(Nil())
        case Cons(head=x, tail=xs):
            match f(x):
                case Error(e):
                    return Error(e)
                case Ok(y):
                    match traverse_results(f, xs):
                        case Error(e):
                            return Error(e)
                        case Ok(ys):
                            return Ok(Cons(y, ys))
```

**Type Constructor Transformations**

Natural transformations between type constructors preserve structure:

```python
# Natural transformation: Option ~> List
def option_to_list(opt: Option[T]) -> List[T]:
    match opt:
        case None_():
            return Nil()
        case Some(value=x):
            return Cons(x, Nil())

# Natural transformation: List ~> Option (first element)
def list_to_option(lst: List[T]) -> Option[T]:
    match lst:
        case Nil():
            return None_()
        case Cons(head=x, tail=_):
            return Some(x)

# Natural transformation: Either[E, _] ~> Option
def either_to_option(either: Either[E, T]) -> Option[T]:
    match either:
        case Left(_):
            return None_()
        case Right(value=x):
            return Some(x)
```

**Kind Signatures**

[Inference] Type constructors have "kinds" that describe their arity and structure, though Python's type system doesn't formally express kinds:

```python
# Unit :: *                (concrete type)
# Option :: * -> *         (unary constructor)
# Either :: * -> * -> *    (binary constructor)
# Result :: * -> * -> *    (binary constructor)

# Higher-order constructor (takes constructor as parameter)
# Functor :: (* -> *) -> Constraint
```

**Functor Type Constructor Pattern**

Type constructors that support mapping preserve structure:

```python
from typing import Protocol, Callable

class Functor(Protocol[F]):
    def map(self, f: Callable[[A], B]) -> 'F[B]':
        ...

# Option is a functor
def map_option(f: Callable[[T], U], opt: Option[T]) -> Option[U]:
    match opt:
        case None_():
            return None_()
        case Some(value=x):
            return Some(f(x))

# List is a functor
def map_list(f: Callable[[T], U], lst: List[T]) -> List[U]:
    match lst:
        case Nil():
            return Nil()
        case Cons(head=x, tail=xs):
            return Cons(f(x), map_list(f, xs))

# Either[E, _] is a functor (fixes left type)
def map_either(f: Callable[[T], U], either: Either[E, T]) -> Either[E, U]:
    match either:
        case Left(value=e):
            return Left(e)
        case Right(value=x):
            return Right(f(x))
```

**Monad Type Constructor Pattern**

Type constructors supporting flatMap enable sequential composition:

```python
# Option monad
def flat_map_option(
    f: Callable[[T], Option[U]], 
    opt: Option[T]
) -> Option[U]:
    match opt:
        case None_():
            return None_()
        case Some(value=x):
            return f(x)

# List monad
def flat_map_list(
    f: Callable[[T], List[U]], 
    lst: List[T]
) -> List[U]:
    match lst:
        case Nil():
            return Nil()
        case Cons(head=x, tail=xs):
            return concat(f(x), flat_map_list(f, xs))

# Result monad
def flat_map_result(
    f: Callable[[T], Result[U, E]], 
    result: Result[T, E]
) -> Result[U, E]:
    match result:
        case Error(error=e):
            return Error(e)
        case Ok(value=x):
            return f(x)
```

**Type Constructor Algebra**

Type constructors form algebraic structures:

```python
# Product type constructor (pairs)
@dataclass
class Product(Generic[F, G, A]):
    """F[A] × G[A]"""
    first: F[A]
    second: G[A]

# Sum type constructor (coproduct)
@dataclass
class LeftF(Generic[F, A]):
    value: F[A]

@dataclass
class RightG(Generic[G, A]):
    value: G[A]

Sum = Union[LeftF[F, A], RightG[G, A]]  # F[A] + G[A]

# Composition type constructor
@dataclass
class Compose(Generic[F, G, A]):
    """F[G[A]]"""
    value: F[G[A]]
```

**Fixed-Point Type Constructor**

Enable recursive types through fixed-point operator:

```python
@dataclass
class Fix(Generic[F]):
    """μF - fixed point of F"""
    unfix: F['Fix[F]']

# Example: Natural numbers as fixed point
@dataclass
class NatF(Generic[T]):
    pass

@dataclass
class ZeroF(NatF[T]):
    pass

@dataclass
class SuccF(NatF[T]):
    pred: T

Nat = Fix[NatF]

zero: Nat = Fix(ZeroF())
one: Nat = Fix(SuccF(zero))
two: Nat = Fix(SuccF(one))
```

---

