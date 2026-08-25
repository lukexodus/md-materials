## Protocol Classes in Python


Python's protocol classes provide structural subtyping through special methods and the `typing.Protocol` mechanism, enabling ad-hoc polymorphism in a dynamically-typed language. Protocols define interfaces based on method signatures rather than explicit inheritance, allowing types to satisfy interfaces implicitly.

Structural typing in Python operates through duck typing at runtime—if an object implements the required methods with compatible signatures, it satisfies the protocol regardless of inheritance relationships. The `typing.Protocol` class formalizes this for static type checking, enabling type checkers to verify protocol conformance without runtime checks.

**Protocol Definition**

Protocols are defined by subclassing `typing.Protocol` and declaring method signatures without implementations (unless providing default implementations). These declarations specify the interface that conforming types must provide.

```python
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None: ...
    def area(self) -> float: ...
```

Any class implementing `draw()` and `area()` methods with compatible signatures satisfies `Drawable`, regardless of whether it explicitly inherits from the protocol. This enables retrofit compatibility—existing classes automatically conform to newly-defined protocols if they have the right methods.

**Special Method Protocols**

Python's data model includes numerous special methods (`__len__`, `__iter__`, `__getitem__`, etc.) that define protocols for built-in operations. These implicit protocols enable operator overloading and integration with Python's syntax.

The `Sized` protocol requires `__len__`, making objects compatible with `len()`. The `Iterable` protocol requires `__iter__`, enabling `for` loops. The `Sequence` protocol requires `__getitem__` and `__len__`, supporting indexing and slicing. Implementing these special methods grants access to Python's built-in operations.

**Runtime Protocol Checking**

The `typing.runtime_checkable` decorator enables `isinstance()` checks against protocols, bridging static and dynamic typing. Without this decorator, protocols only affect static type checking. With it, runtime type verification becomes possible, though checks only verify method presence, not signatures.

```python
@runtime_checkable
class Comparable(Protocol):
    def __lt__(self, other) -> bool: ...
```

This allows conditional logic based on protocol conformance, useful for handling multiple input types with different capabilities.

**Generic Protocols**

Protocols support type parameters, enabling generic interfaces parameterized by element types or other type variables. This combines structural subtyping with parametric polymorphism.

```python
from typing import Protocol, TypeVar

T = TypeVar('T')

class Container(Protocol[T]):
    def add(self, item: T) -> None: ...
    def get(self) -> T: ...
```

Types implementing `Container` with specific element types satisfy the protocol. Type checkers verify that operations on protocol types respect the type parameters.

**Protocol Composition**

Multiple protocols can be combined through intersection types or by defining protocols that inherit from multiple parent protocols. This enables fine-grained capability description where functions require only the operations they actually use.

Protocols provide gradual typing benefits—code can mix dynamically-typed and protocol-constrained sections. Functions accepting protocol types work with any compatible object while providing static type checking where declared.

