## `typing` Module


The `typing` module provides runtime support for type hints, introduced in Python 3.5 via PEP 484. It allows you to annotate function parameters, return values, and variables with expected types, improving code clarity and enabling static type checking with tools like mypy.

### Basic Type Annotations

You can annotate variables and function signatures with built-in types:

```python
from typing import List, Dict, Set, Tuple

def greet(name: str) -> str:
    return f"Hello, {name}"

age: int = 25
scores: List[int] = [95, 87, 92]
user_data: Dict[str, int] = {"age": 25, "score": 100}
```

### Common Generic Types

#### List, Dict, Set, Tuple

These generic types specify the types of elements they contain:

```python
from typing import List, Dict, Set, Tuple

# List of strings
names: List[str] = ["Alice", "Bob"]

# Dictionary with string keys and integer values
ages: Dict[str, int] = {"Alice": 30, "Bob": 25}

# Set of integers
unique_ids: Set[int] = {1, 2, 3}

# Tuple with specific types (fixed length)
coordinates: Tuple[float, float] = (10.5, 20.3)

# Tuple with variable length
numbers: Tuple[int, ...] = (1, 2, 3, 4, 5)
```

#### Optional and Union

`Optional[X]` is shorthand for `Union[X, None]`, indicating a value can be of type X or None:

```python
from typing import Optional, Union

def find_user(user_id: int) -> Optional[str]:
    # Returns username or None if not found
    return None

# Union allows multiple possible types
def process_id(id_value: Union[int, str]) -> str:
    return str(id_value)
```

#### Any

`Any` is a special type indicating a value can be of any type:

```python
from typing import Any

def log_value(value: Any) -> None:
    print(value)
```

### Callable

`Callable` describes functions and other callables:

```python
from typing import Callable

# Function that takes two ints and returns an int
def apply_operation(x: int, y: int, operation: Callable[[int, int], int]) -> int:
    return operation(x, y)

def add(a: int, b: int) -> int:
    return a + b

result = apply_operation(5, 3, add)  # Returns 8
```

### Type Aliases

You can create aliases for complex types:

```python
from typing import List, Tuple

# Define an alias
Coordinate = Tuple[float, float]
Path = List[Coordinate]

def calculate_distance(path: Path) -> float:
    # Implementation
    return 0.0
```

### NewType

`NewType` creates distinct types for type checking purposes:

```python
from typing import NewType

UserId = NewType('UserId', int)
OrderId = NewType('OrderId', int)

def get_user(user_id: UserId) -> str:
    return f"User {user_id}"

# Type checkers will catch mixing these up
user = UserId(42)
order = OrderId(100)

get_user(user)    # OK
# get_user(order)  # Type checker error
```

### Literal

`Literal` restricts values to specific literals:

```python
from typing import Literal

def set_mode(mode: Literal["read", "write", "execute"]) -> None:
    print(f"Mode set to {mode}")

set_mode("read")   # OK
# set_mode("delete")  # Type checker error
```

### TypedDict

`TypedDict` defines dictionaries with specific keys and value types:

```python
from typing import TypedDict

class Person(TypedDict):
    name: str
    age: int
    email: str

person: Person = {
    "name": "Alice",
    "age": 30,
    "email": "alice@example.com"
}
```

### Generic Classes

You can create generic classes using `TypeVar`:

```python
from typing import TypeVar, Generic, List

T = TypeVar('T')

class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: List[T] = []
    
    def push(self, item: T) -> None:
        self._items.append(item)
    
    def pop(self) -> T:
        return self._items.pop()

# Create type-specific stacks
int_stack: Stack[int] = Stack()
str_stack: Stack[str] = Stack()
```

### Protocol (Structural Subtyping)

`Protocol` defines structural types (duck typing with type checking):

```python
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None:
        ...

class Circle:
    def draw(self) -> None:
        print("Drawing circle")

class Square:
    def draw(self) -> None:
        print("Drawing square")

def render(shape: Drawable) -> None:
    shape.draw()

# Both work without explicit inheritance
render(Circle())
render(Square())
```

### TypeVar Constraints and Bounds

`TypeVar` can be constrained to specific types or bounded:

```python
from typing import TypeVar

# Constrained to specific types
AnyStr = TypeVar('AnyStr', str, bytes)

def concat(x: AnyStr, y: AnyStr) -> AnyStr:
    return x + y

# Bounded (must be subtype of Number)
from numbers import Number
NumericType = TypeVar('NumericType', bound=Number)

def add_numbers(x: NumericType, y: NumericType) -> NumericType:
    return x + y
```

### Type Guards

Type guards narrow types within conditional blocks:

```python
from typing import Union

def process_value(value: Union[int, str]) -> None:
    if isinstance(value, str):
        # Type checker knows value is str here
        print(value.upper())
    else:
        # Type checker knows value is int here
        print(value + 1)
```

### Overload

`@overload` decorator provides multiple type signatures for a function:

```python
from typing import overload, Union

@overload
def process(value: int) -> str: ...

@overload
def process(value: str) -> int: ...

def process(value: Union[int, str]) -> Union[str, int]:
    if isinstance(value, int):
        return str(value)
    return len(value)
```

### Modern Syntax (Python 3.9+)

Python 3.9+ allows using built-in collection types directly:

```python
# Python 3.9+
def process_items(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}

# Instead of:
from typing import List, Dict
def process_items(items: List[str]) -> Dict[str, int]:
    return {item: len(item) for item in items}
```

Python 3.10+ introduced the `|` operator for unions:

```python
# Python 3.10+
def get_value(key: str) -> int | None:
    return None

# Instead of:
from typing import Optional
def get_value(key: str) -> Optional[int]:
    return None
```

### Best Practices

Type hints are optional and don't affect runtime behavior. They serve as documentation and enable static type checking. Use them to clarify complex APIs, catch bugs early with type checkers, and improve IDE autocompletion and refactoring capabilities.

### ParamSpec and Concatenate

`ParamSpec` (Python 3.10+) captures the parameters of a callable, useful for decorators:

```python
from typing import ParamSpec, TypeVar, Callable

P = ParamSpec('P')
R = TypeVar('R')

def log_call(func: Callable[P, R]) -> Callable[P, R]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@log_call
def greet(name: str, age: int) -> str:
    return f"Hello {name}, you are {age}"
```

`Concatenate` allows adding parameters to a callable's signature:

```python
from typing import Concatenate, ParamSpec, TypeVar, Callable

P = ParamSpec('P')
R = TypeVar('R')

class Request:
    pass

def with_request(func: Callable[Concatenate[Request, P], R]) -> Callable[P, R]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        request = Request()
        return func(request, *args, **kwargs)
    return wrapper

@with_request
def handle(request: Request, user_id: int) -> str:
    return f"Handling request for user {user_id}"
```

### Self Type

`Self` (Python 3.11+) refers to the enclosing class, useful for methods that return instances:

```python
from typing import Self

class Builder:
    def __init__(self) -> None:
        self.value = 0
    
    def add(self, x: int) -> Self:
        self.value += x
        return self
    
    def multiply(self, x: int) -> Self:
        self.value *= x
        return self

# Enables method chaining with correct types
result = Builder().add(5).multiply(2)
```

### TypeGuard and TypeIs

`TypeGuard` (Python 3.10+) defines user-defined type guards:

```python
from typing import TypeGuard

def is_string_list(val: list[object]) -> TypeGuard[list[str]]:
    return all(isinstance(x, str) for x in val)

def process(items: list[object]) -> None:
    if is_string_list(items):
        # Type checker knows items is list[str] here
        print([s.upper() for s in items])
```

`TypeIs` (Python 3.13+) is a more precise version that narrows types in both branches:

```python
from typing import TypeIs

def is_str(val: str | int) -> TypeIs[str]:
    return isinstance(val, str)

def process(val: str | int) -> None:
    if is_str(val):
        # val is str
        print(val.upper())
    else:
        # val is int (TypeIs narrows the else branch too)
        print(val + 1)
```

### Never and NoReturn

`NoReturn` indicates a function never returns (always raises or loops forever):

```python
from typing import NoReturn

def raise_error(message: str) -> NoReturn:
    raise ValueError(message)

def infinite_loop() -> NoReturn:
    while True:
        pass
```

`Never` (Python 3.11+) represents the bottom type (no possible values):

```python
from typing import Never, assert_never

def handle_value(value: int | str) -> str:
    if isinstance(value, int):
        return str(value)
    elif isinstance(value, str):
        return value
    else:
        # Ensures all cases are handled
        assert_never(value)
```

### ClassVar

`ClassVar` indicates a class variable (not an instance variable):

```python
from typing import ClassVar

class Config:
    MAX_CONNECTIONS: ClassVar[int] = 100
    
    def __init__(self, name: str) -> None:
        self.name = name  # Instance variable
```

### Final

`Final` indicates a value that should not be reassigned:

```python
from typing import Final

MAX_SIZE: Final = 100
# MAX_SIZE = 200  # Type checker error

class Config:
    DEFAULT_TIMEOUT: Final[int] = 30
```

`@final` decorator prevents subclassing or overriding:

```python
from typing import final

@final
class FinalClass:
    pass

# class SubClass(FinalClass):  # Type checker error
#     pass

class BaseClass:
    @final
    def method(self) -> None:
        pass

class Derived(BaseClass):
    # def method(self) -> None:  # Type checker error
    #     pass
    pass
```

### Annotated

`Annotated` adds metadata to types:

```python
from typing import Annotated

# Add validation metadata
UserId = Annotated[int, "positive", "must be unique"]
Email = Annotated[str, "valid email format"]

def create_user(user_id: UserId, email: Email) -> None:
    pass
```

### Required and NotRequired

`Required` and `NotRequired` (Python 3.11+) mark TypedDict fields:

```python
from typing import TypedDict, Required, NotRequired

class User(TypedDict):
    name: Required[str]
    age: Required[int]
    email: NotRequired[str]  # Optional field

user1: User = {"name": "Alice", "age": 30}  # OK
user2: User = {"name": "Bob", "age": 25, "email": "bob@example.com"}  # OK
```

### Unpack

`Unpack` (Python 3.11+) unpacks TypedDict or tuple types:

```python
from typing import TypedDict, Unpack

class Person(TypedDict):
    name: str
    age: int

def create_person(**kwargs: Unpack[Person]) -> None:
    print(kwargs)

create_person(name="Alice", age=30)  # OK
# create_person(name="Bob")  # Type checker error - missing 'age'
```

### Mapping and Sequence Protocols

Abstract types for read-only collections:

```python
from typing import Mapping, Sequence

def print_items(items: Sequence[str]) -> None:
    # Works with lists, tuples, etc.
    for item in items:
        print(item)

def print_dict(data: Mapping[str, int]) -> None:
    # Works with dicts and other mappings
    for key, value in data.items():
        print(f"{key}: {value}")
```

### MutableMapping and MutableSequence

For collections that can be modified:

```python
from typing import MutableMapping, MutableSequence

def modify_list(items: MutableSequence[int]) -> None:
    items.append(42)
    items[0] = 100

def modify_dict(data: MutableMapping[str, int]) -> None:
    data["new_key"] = 123
    del data["old_key"]
```

### Iterable, Iterator, and Generator

Types for iteration protocols:

```python
from typing import Iterable, Iterator, Generator

def process_items(items: Iterable[int]) -> None:
    for item in items:
        print(item)

def count_up() -> Iterator[int]:
    n = 0
    while True:
        yield n
        n += 1

def fibonacci() -> Generator[int, None, None]:
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b
```

Generator type has three parameters: `Generator[YieldType, SendType, ReturnType]`

```python
from typing import Generator

def echo() -> Generator[int, str, bool]:
    value = yield 42  # Yields int
    print(f"Received: {value}")  # Receives str
    return True  # Returns bool
```

### ContextManager

Type for context manager protocol:

```python
from typing import ContextManager
from contextlib import contextmanager

@contextmanager
def get_resource() -> Generator[str, None, None]:
    resource = "acquired"
    try:
        yield resource
    finally:
        print("released")

def use_resource(cm: ContextManager[str]) -> None:
    with cm as resource:
        print(resource)
```

### Type Aliases with TypeAlias

`TypeAlias` (Python 3.10+) explicitly marks type aliases:

```python
from typing import TypeAlias

# Without TypeAlias (ambiguous)
Vector = list[float]  # Is this a type alias or a variable?

# With TypeAlias (explicit)
Vector: TypeAlias = list[float]
Matrix: TypeAlias = list[Vector]

def add_vectors(v1: Vector, v2: Vector) -> Vector:
    return [a + b for a, b in zip(v1, v2)]
```

### Generic Type Aliases

Create generic type aliases with TypeVar:

```python
from typing import TypeVar, TypeAlias

T = TypeVar('T')

# Generic type alias
Container: TypeAlias = list[T] | dict[str, T]

def process_container(c: Container[int]) -> None:
    pass
```

### Covariant and Contravariant TypeVars

TypeVars can be covariant or contravariant for proper subtyping:

```python
from typing import TypeVar, Generic

# Covariant (T_co)
T_co = TypeVar('T_co', covariant=True)

class Producer(Generic[T_co]):
    def produce(self) -> T_co:
        ...

# Animal -> Dog subtyping preserved
# Producer[Dog] is subtype of Producer[Animal]

# Contravariant (T_contra)
T_contra = TypeVar('T_contra', contravariant=True)

class Consumer(Generic[T_contra]):
    def consume(self, item: T_contra) -> None:
        ...

# Animal -> Dog subtyping reversed
# Consumer[Animal] is subtype of Consumer[Dog]
```

### Abstract Base Classes with typing

Combine ABC with typing for abstract generic classes:

```python
from typing import TypeVar, Generic
from abc import ABC, abstractmethod

T = TypeVar('T')

class Repository(ABC, Generic[T]):
    @abstractmethod
    def get(self, id: int) -> T:
        pass
    
    @abstractmethod
    def save(self, item: T) -> None:
        pass

class UserRepository(Repository[str]):
    def get(self, id: int) -> str:
        return f"User {id}"
    
    def save(self, item: str) -> None:
        print(f"Saving {item}")
```

### Runtime Type Checking Limitations

Type hints are not enforced at runtime by Python itself:

```python
def add(x: int, y: int) -> int:
    return x + y

# This runs without error at runtime
result = add("hello", "world")  # Returns "helloworld"
```

For runtime checking, use libraries like `typeguard` or `pydantic`:

```python
from pydantic import BaseModel, ValidationError

class User(BaseModel):
    name: str
    age: int

try:
    user = User(name="Alice", age="not a number")
except ValidationError as e:
    print(e)  # Validation error at runtime
```

### get_type_hints

`get_type_hints()` retrieves annotations at runtime:

```python
from typing import get_type_hints

def greet(name: str, age: int) -> str:
    return f"Hello {name}"

hints = get_type_hints(greet)
print(hints)  # {'name': <class 'str'>, 'age': <class 'int'>, 'return': <class 'str'>}
```

### TYPE_CHECKING Constant

`TYPE_CHECKING` is `False` at runtime, `True` during type checking (prevents circular imports):

```python
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    # Only imported during type checking, not at runtime
    from expensive_module import ExpensiveClass

def process(obj: 'ExpensiveClass') -> None:  # Forward reference as string
    pass
```

### Forward References

Use string literals for forward references:

```python
class Node:
    def __init__(self, value: int, next: 'Node | None' = None) -> None:
        self.value = value
        self.next = next
```

Python 3.7+ supports `from __future__ import annotations` to make all annotations strings by default:

```python
from __future__ import annotations

class Node:
    def __init__(self, value: int, next: Node | None = None) -> None:
        self.value = value
        self.next = next
```

This covers the comprehensive functionality of the `typing` module through Python 3.13.

---

