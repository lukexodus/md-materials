## Generic ADTs


Generic algebraic data types parameterize over one or more type variables, enabling polymorphic data structures that work uniformly across different element types while maintaining type safety. This abstraction eliminates code duplication across type-specific implementations.

**Type Parameters**

Generic ADTs declare type variables that are instantiated at use sites:

```python
from dataclasses import dataclass
from typing import TypeVar, Union, Generic

T = TypeVar('T')

@dataclass
class Some(Generic[T]):
    value: T

@dataclass
class None_:
    pass

Option = Union[Some[T], None_]

# Instantiated types
int_option: Option[int] = Some(42)
str_option: Option[str] = Some("hello")
none_option: Option[int] = None_()
```

**Generic Recursive Structures**

Combine generics with recursion for polymorphic container types:

```python
@dataclass
class Cons(Generic[T]):
    head: T
    tail: 'List[T]'

@dataclass
class Nil:
    pass

List = Union[Cons[T], Nil]

# Type-safe list operations
def map_list(f: Callable[[T], U], lst: List[T]) -> List[U]:
    match lst:
        case Nil():
            return Nil()
        case Cons(head=x, tail=xs):
            return Cons(f(x), map_list(f, xs))

# Usage
numbers: List[int] = Cons(1, Cons(2, Cons(3, Nil())))
strings: List[str] = map_list(str, numbers)
```

**Multiple Type Parameters**

ADTs can abstract over multiple independent types:

```python
K = TypeVar('K')
V = TypeVar('V')

@dataclass
class Entry(Generic[K, V]):
    key: K
    value: V

@dataclass
class MapEmpty:
    pass

@dataclass
class MapNode(Generic[K, V]):
    entry: Entry[K, V]
    left: 'Map[K, V]'
    right: 'Map[K, V]'

Map = Union[MapEmpty, MapNode[K, V]]

def lookup(key: K, map: Map[K, V]) -> Option[V]:
    match map:
        case MapEmpty():
            return None_()
        case MapNode(entry=Entry(k, v), left=l, right=r):
            if key == k:
                return Some(v)
            elif key < k:
                return lookup(key, l)
            else:
                return lookup(key, r)
```

**Bounded Type Parameters**

Constrain type parameters to specific capabilities:

```python
from typing import Protocol

class Comparable(Protocol):
    def __lt__(self, other) -> bool: ...
    def __eq__(self, other) -> bool: ...

T_Comparable = TypeVar('T_Comparable', bound=Comparable)

@dataclass
class BSTEmpty:
    pass

@dataclass
class BSTNode(Generic[T_Comparable]):
    value: T_Comparable
    left: 'BST[T_Comparable]'
    right: 'BST[T_Comparable]'

BST = Union[BSTEmpty, BSTNode[T_Comparable]]

def insert(x: T_Comparable, tree: BST[T_Comparable]) -> BST[T_Comparable]:
    match tree:
        case BSTEmpty():
            return BSTNode(x, BSTEmpty(), BSTEmpty())
        case BSTNode(value=v, left=l, right=r):
            if x < v:
                return BSTNode(v, insert(x, l), r)
            elif x == v:
                return tree
            else:
                return BSTNode(v, l, insert(x, r))
```

**Covariance and Contravariance**

[Inference] Generic ADTs can specify variance to control subtyping relationships, though Python's type system has limited variance annotation support compared to languages like Scala or Haskell.

```python
from typing import TypeVar

# Covariant type parameter (read-only containers)
T_co = TypeVar('T_co', covariant=True)

@dataclass
class ReadOnlyBox(Generic[T_co]):
    value: T_co
    
    def get(self) -> T_co:
        return self.value

# Contravariant type parameter (write-only containers)
T_contra = TypeVar('T_contra', contravariant=True)

@dataclass
class WriteOnlyBox(Generic[T_contra]):
    def put(self, value: T_contra) -> None:
        pass
```

**Phantom Types**

Type parameters that don't appear in runtime representation, used purely for compile-time distinctions:

```python
from typing import Generic, TypeVar

Unit = TypeVar('Unit')

@dataclass
class Distance(Generic[Unit]):
    value: float
    
class Meters: pass
class Feet: pass

def meters_to_feet(d: Distance[Meters]) -> Distance[Feet]:
    return Distance(d.value * 3.28084)

# Type safety prevents mixing units
dist_m: Distance[Meters] = Distance(100.0)
dist_ft: Distance[Feet] = meters_to_feet(dist_m)
# dist_m + dist_ft  # Type error!
```

**Higher-Kinded Type Patterns**

Simulate higher-kinded types through protocol-based abstraction:

```python
from typing import Protocol, TypeVar

A = TypeVar('A')
B = TypeVar('B')
F = TypeVar('F')

class Functor(Protocol[F]):
    def map(self, f: Callable[[A], B]) -> 'Functor[B]':
        ...

@dataclass
class OptionFunctor(Generic[T]):
    option: Option[T]
    
    def map(self, f: Callable[[T], U]) -> 'OptionFunctor[U]':
        match self.option:
            case None_():
                return OptionFunctor(None_())
            case Some(value=x):
                return OptionFunctor(Some(f(x)))
```

**Generic Sum Types**

Multiple generic variants with different type parameters:

```python
@dataclass
class Left(Generic[T]):
    value: T

@dataclass
class Right(Generic[U]):
    value: U

Either = Union[Left[T], Right[U]]

def map_either(
    f: Callable[[T], A],
    g: Callable[[U], B],
    either: Either[T, U]
) -> Either[A, B]:
    match either:
        case Left(value=x):
            return Left(f(x))
        case Right(value=y):
            return Right(g(y))
```

**Existential Types**

Simulate existentially quantified types through wrapper abstraction:

```python
@dataclass
class Showable(Protocol):
    def show(self) -> str: ...

@dataclass
class ExistentialBox:
    """Hides the concrete type while exposing interface"""
    _value: Showable
    
    def show(self) -> str:
        return self._value.show()

# Can hold any type implementing Showable
boxes: list[ExistentialBox] = [
    ExistentialBox(SomeType()),
    ExistentialBox(AnotherType())
]
```

**Type-Level Computation**

Use generics for compile-time type transformations:

```python
from typing import Union

T = TypeVar('T')
U = TypeVar('U')

@dataclass
class Pair(Generic[T, U]):
    first: T
    second: U

# Type-level function: swap pair types
def swap(pair: Pair[T, U]) -> Pair[U, T]:
    return Pair(pair.second, pair.first)

original: Pair[int, str] = Pair(1, "hello")
swapped: Pair[str, int] = swap(original)  # Types transformed
```

