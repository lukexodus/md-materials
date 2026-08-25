## Sum types (unions)


Sum types represent a value that can be one of several different types, corresponding to logical OR. They enable type-safe handling of alternatives without runtime type checking overhead, where the total number of possible values is the sum of the cardinalities of the variant types.

**Union Types:**

```python
from typing import Union

# Basic union
IntOrStr = Union[int, str]

def process_value(value: IntOrStr) -> str:
    if isinstance(value, int):
        return f"Integer: {value}"
    else:
        return f"String: {value}"

result1 = process_value(42)        # "Integer: 42"
result2 = process_value("hello")   # "String: hello"

# Multiple alternatives
from typing import Union

NumberType = Union[int, float, complex]

def compute(x: NumberType) -> float:
    if isinstance(x, complex):
        return abs(x)
    return float(x)
```

**Modern Union Syntax (Python 3.10+):**

```python
# Using | operator
def handle_response(response: int | str | None) -> str:
    match response:
        case int(code):
            return f"Status code: {code}"
        case str(message):
            return f"Message: {message}"
        case None:
            return "No response"

# Type aliases with |
JsonValue = int | float | str | bool | None | list['JsonValue'] | dict[str, 'JsonValue']
```

**Optional as Sum Type:**

```python
from typing import Optional

# Optional[T] is Union[T, None]
def find_user(user_id: int) -> Optional[str]:
    users = {1: "Alice", 2: "Bob"}
    return users.get(user_id)

# Handling optional values
result = find_user(1)
if result is not None:
    print(f"Found: {result}")
else:
    print("Not found")

# With match statement
def process_optional(value: Optional[int]) -> str:
    match value:
        case None:
            return "No value"
        case int(n):
            return f"Value: {n}"
```

**Result Type Pattern:**

```python
from typing import NamedTuple, Union, TypeVar, Generic, Callable

T = TypeVar('T')
E = TypeVar('E')

class Ok(NamedTuple, Generic[T]):
    value: T

class Err(NamedTuple, Generic[E]):
    error: E

Result = Union[Ok[T], Err[E]]

def divide(a: float, b: float) -> Result[float, str]:
    if b == 0:
        return Err("Division by zero")
    return Ok(a / b)

# Using the result
result = divide(10, 2)
match result:
    case Ok(value):
        print(f"Success: {value}")
    case Err(error):
        print(f"Error: {error}")

# Chaining results
def safe_sqrt(x: float) -> Result[float, str]:
    if x < 0:
        return Err("Cannot take square root of negative number")
    return Ok(x ** 0.5)

def chain_operations(x: float) -> Result[float, str]:
    match divide(x, 2):
        case Ok(half):
            return safe_sqrt(half)
        case Err(e):
            return Err(e)
```

**Maybe/Option Pattern:**

```python
from typing import NamedTuple, Union, TypeVar, Generic, Callable

T = TypeVar('T')

class Just(NamedTuple, Generic[T]):
    value: T

class Nothing(NamedTuple):
    pass

Maybe = Union[Just[T], Nothing]

def safe_divide(a: float, b: float) -> Maybe[float]:
    if b == 0:
        return Nothing()
    return Just(a / b)

# Functor operations
def map_maybe(f: Callable[[T], U], maybe: Maybe[T]) -> Maybe[U]:
    match maybe:
        case Just(value):
            return Just(f(value))
        case Nothing():
            return Nothing()

result = safe_divide(10, 2)
doubled = map_maybe(lambda x: x * 2, result)
# Output: Just(value=10.0)

# Monadic bind
U = TypeVar('U')

def bind_maybe(maybe: Maybe[T], f: Callable[[T], Maybe[U]]) -> Maybe[U]:
    match maybe:
        case Just(value):
            return f(value)
        case Nothing():
            return Nothing()

def safe_sqrt(x: float) -> Maybe[float]:
    if x < 0:
        return Nothing()
    return Just(x ** 0.5)

result = bind_maybe(Just(16.0), safe_sqrt)
# Output: Just(value=4.0)
```

**Either Type:**

```python
from typing import NamedTuple, Union, TypeVar, Generic

L = TypeVar('L')
R = TypeVar('R')

class Left(NamedTuple, Generic[L]):
    value: L

class Right(NamedTuple, Generic[R]):
    value: R

Either = Union[Left[L], Right[R]]

# Convention: Left for error, Right for success
def parse_int(s: str) -> Either[str, int]:
    try:
        return Right(int(s))
    except ValueError:
        return Left(f"Cannot parse '{s}' as integer")

# Bimap
def bimap_either(
    left_f: Callable[[L], L2],
    right_f: Callable[[R], R2],
    either: Either[L, R]
) -> Either[L2, R2]:
    match either:
        case Left(value):
            return Left(left_f(value))
        case Right(value):
            return Right(right_f(value))

result = parse_int("42")
transformed = bimap_either(
    lambda e: f"Error: {e}",
    lambda n: n * 2,
    result
)
# Output: Right(value=84)
```

**Recursive Sum Types:**

```python
from typing import NamedTuple, Union

class Nil(NamedTuple):
    pass

class Cons(NamedTuple):
    head: int
    tail: 'List'

List = Union[Nil, Cons]

# Creating lists
empty: List = Nil()
single: List = Cons(1, Nil())
multiple: List = Cons(1, Cons(2, Cons(3, Nil())))

# Operations on recursive sum types
def list_length(lst: List) -> int:
    match lst:
        case Nil():
            return 0
        case Cons(_, tail):
            return 1 + list_length(tail)

def list_sum(lst: List) -> int:
    match lst:
        case Nil():
            return 0
        case Cons(head, tail):
            return head + list_sum(tail)

length = list_length(multiple)  # 3
total = list_sum(multiple)      # 6

# Map over list
def list_map(f: Callable[[int], int], lst: List) -> List:
    match lst:
        case Nil():
            return Nil()
        case Cons(head, tail):
            return Cons(f(head), list_map(f, tail))
```

**Expression Trees:**

```python
from typing import NamedTuple, Union

class Literal(NamedTuple):
    value: int

class Add(NamedTuple):
    left: 'Expr'
    right: 'Expr'

class Multiply(NamedTuple):
    left: 'Expr'
    right: 'Expr'

class Negate(NamedTuple):
    expr: 'Expr'

Expr = Union[Literal, Add, Multiply, Negate]

# Building expressions
expr = Add(
    Literal(5),
    Multiply(Literal(3), Literal(4))
)
# Represents: 5 + (3 * 4)

# Evaluating expressions
def eval_expr(expr: Expr) -> int:
    match expr:
        case Literal(value):
            return value
        case Add(left, right):
            return eval_expr(left) + eval_expr(right)
        case Multiply(left, right):
            return eval_expr(left) * eval_expr(right)
        case Negate(e):
            return -eval_expr(e)

result = eval_expr(expr)  # 17

# Pretty printing
def expr_to_string(expr: Expr) -> str:
    match expr:
        case Literal(value):
            return str(value)
        case Add(left, right):
            return f"({expr_to_string(left)} + {expr_to_string(right)})"
        case Multiply(left, right):
            return f"({expr_to_string(left)} * {expr_to_string(right)})"
        case Negate(e):
            return f"-{expr_to_string(e)}"
```

**Sum Type Exhaustiveness:**

```python
from typing import Union, Never

class Red(NamedTuple):
    pass

class Green(NamedTuple):
    pass

class Blue(NamedTuple):
    pass

Color = Union[Red, Green, Blue]

def process_color(color: Color) -> str:
    match color:
        case Red():
            return "Stop"
        case Green():
            return "Go"
        case Blue():
            return "Unknown"
        case _ as unreachable:
            # Type checker ensures this is never reached
            assert_never(unreachable)

def assert_never(x: Never) -> Never:
    raise AssertionError(f"Unhandled type: {type(x).__name__}")
```

