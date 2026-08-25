## Product types


Product types combine multiple values into a single compound value where all components must be present simultaneously. They represent the logical AND of types, creating structures where the total number of possible values is the product of the cardinalities of their component types.

**Tuples as Product Types:**

```python
# Simple product type
Point2D = tuple[int, int]
point: Point2D = (3, 4)

# Named tuples for clarity
from typing import NamedTuple

class Person(NamedTuple):
    name: str
    age: int
    email: str

person = Person("Alice", 30, "alice@example.com")
# Access: person.name, person.age, person.email

# Immutability enforced
# person.age = 31  # AttributeError
```

**Dataclasses as Product Types:**

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Rectangle:
    width: float
    height: float
    
    def area(self) -> float:
        return self.width * self.height

rect = Rectangle(10.0, 5.0)

@dataclass(frozen=True)
class User:
    id: int
    username: str
    email: str
    is_active: bool

user = User(1, "john_doe", "john@example.com", True)
```

**Nested Product Types:**

```python
from typing import NamedTuple

class Address(NamedTuple):
    street: str
    city: str
    zip_code: str

class Employee(NamedTuple):
    name: str
    employee_id: int
    address: Address
    salary: float

employee = Employee(
    "Jane Smith",
    12345,
    Address("123 Main St", "Springfield", "12345"),
    75000.0
)

# Access nested: employee.address.city
```

**Generic Product Types:**

```python
from typing import NamedTuple, TypeVar, Generic

T = TypeVar('T')
U = TypeVar('U')

class Pair(NamedTuple, Generic[T, U]):
    first: T
    second: U

int_str_pair: Pair[int, str] = Pair(42, "answer")
float_bool_pair: Pair[float, bool] = Pair(3.14, True)

# Homogeneous pairs
class Coordinate(NamedTuple):
    x: float
    y: float
    z: float

coord = Coordinate(1.0, 2.0, 3.0)
```

**Product Types with Type Aliases:**

```python
from typing import NamedTuple

# Representing complex structures
class RGB(NamedTuple):
    red: int
    green: int
    blue: int

class Color(NamedTuple):
    name: str
    rgb: RGB
    opacity: float

color = Color("SkyBlue", RGB(135, 206, 235), 1.0)

# Multiple fields of same type still distinct
class Dimensions(NamedTuple):
    length: float
    width: float
    height: float
    weight: float

box = Dimensions(10.0, 5.0, 3.0, 2.5)
```

**Transformation Functions on Product Types:**

```python
from typing import NamedTuple, Callable

class Point(NamedTuple):
    x: float
    y: float

def map_point(f: Callable[[float], float], point: Point) -> Point:
    """Apply function to both components"""
    return Point(f(point.x), f(point.y))

p = Point(3.0, 4.0)
doubled = map_point(lambda x: x * 2, p)
# Output: Point(x=6.0, y=8.0)

def zip_points(f: Callable[[float, float], float], p1: Point, p2: Point) -> Point:
    """Combine two points with binary function"""
    return Point(f(p1.x, p2.x), f(p1.y, p2.y))

result = zip_points(lambda a, b: a + b, Point(1, 2), Point(3, 4))
# Output: Point(x=4, y=6)
```

**Product Types with Constraints:**

```python
from dataclasses import dataclass
from typing import ClassVar

@dataclass(frozen=True)
class BoundedInt:
    value: int
    min_value: ClassVar[int] = 0
    max_value: ClassVar[int] = 100
    
    def __post_init__(self):
        if not (self.min_value <= self.value <= self.max_value):
            raise ValueError(f"Value must be between {self.min_value} and {self.max_value}")

@dataclass(frozen=True)
class ValidatedUser:
    username: str
    age: BoundedInt
    
    def __post_init__(self):
        if len(self.username) < 3:
            raise ValueError("Username must be at least 3 characters")

# Usage
user = ValidatedUser("alice", BoundedInt(25))
```

**Deconstructing Product Types:**

```python
from typing import NamedTuple

class Transaction(NamedTuple):
    id: str
    amount: float
    currency: str
    timestamp: int

def extract_amount(transaction: Transaction) -> float:
    """First projection"""
    return transaction.amount

def extract_currency(transaction: Transaction) -> str:
    """Second projection"""
    return transaction.currency

# Pattern matching (Python 3.10+)
def process_transaction(trans: Transaction) -> str:
    match trans:
        case Transaction(id=tid, amount=amt, currency="USD", timestamp=_):
            return f"USD transaction {tid}: ${amt}"
        case Transaction(id=tid, amount=amt, currency=curr, timestamp=_):
            return f"{curr} transaction {tid}: {amt}"

trans = Transaction("TXN001", 100.0, "USD", 1234567890)
```

**Algebraic Properties:**

```python
from typing import NamedTuple

# Unit type (single inhabitant)
class Unit(NamedTuple):
    pass

unit = Unit()

# Product with unit is isomorphic to original type
class PairWithUnit(NamedTuple):
    value: int
    unit: Unit

# This is essentially equivalent to just int

# Commutativity: (A, B) ≅ (B, A)
class AB(NamedTuple):
    a: str
    b: int

class BA(NamedTuple):
    b: int
    a: str

def swap(ab: AB) -> BA:
    return BA(ab.b, ab.a)

# Associativity: ((A, B), C) ≅ (A, (B, C))
class ABC_Left(NamedTuple):
    ab: tuple[str, int]
    c: bool

class ABC_Right(NamedTuple):
    a: str
    bc: tuple[int, bool]

def reassociate_left(left: ABC_Left) -> ABC_Right:
    a, b = left.ab
    return ABC_Right(a, (b, left.c))
```

