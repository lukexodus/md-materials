## Returns library


Returns brings typed monadic patterns with full type-checking support, designed specifically for modern Python with mypy integration. It emphasizes railway-oriented programming and explicit error handling.

**Result Container**

Result represents success (Success) or failure (Failure), similar to Either but with Python-specific ergonomics and comprehensive type hints.

```python
from returns.result import Result, Success, Failure

def divide(x: float, y: float) -> Result[float, str]:
    if y == 0:
        return Failure("Division by zero")
    return Success(x / y)

def sqrt(x: float) -> Result[float, str]:
    if x < 0:
        return Failure("Negative number")
    return Success(x ** 0.5)

# Railway-oriented programming
result: Result[float, str] = (
    divide(16, 4)
    .bind(sqrt)  # Success(2.0)
)

# Error propagation
error: Result[float, str] = (
    divide(16, 0)
    .bind(sqrt)  # Failure("Division by zero"), sqrt never called
)

# Unwrapping
match result:
    case Success(value):
        print(f"Result: {value}")
    case Failure(error):
        print(f"Error: {error}")
```

**Maybe Container**

Maybe handles optional values with proper type checking, providing safer alternatives to None checks.

```python
from returns.maybe import Maybe, Some, Nothing

def get_user(user_id: int) -> Maybe[dict]:
    users = {1: {'name': 'Alice'}, 2: {'name': 'Bob'}}
    return Some(users[user_id]) if user_id in users else Nothing

def get_user_name(user: dict) -> Maybe[str]:
    return Some(user['name']) if 'name' in user else Nothing

# Safe chaining
name: Maybe[str] = (
    get_user(1)
    .bind(get_user_name)  # Some('Alice')
)

not_found: Maybe[str] = (
    get_user(999)
    .bind(get_user_name)  # Nothing
)

# Unwrap with default
final_name = name.value_or('Unknown')  # 'Alice'
```

**IO Container**

IO marks functions with side effects, making them explicit in the type system and separating pure from impure code.

```python
from returns.io import IO, impure

@impure
def read_file(path: str) -> str:
    with open(path) as f:
        return f.read()

@impure
def write_file(path: str, content: str) -> None:
    with open(path, 'w') as f:
        f.write(content)

# Compose IO operations
def process_file(input_path: str, output_path: str) -> IO[None]:
    return (
        read_file(input_path)
        .map(str.upper)
        .bind(lambda content: write_file(output_path, content))
    )

# IO is lazy until unwrapped
io_operation = process_file('input.txt', 'output.txt')
io_operation._internal_value  # Actually executes
```

**IOResult Container**

IOResult combines IO and Result, handling both side effects and potential failures with full type safety.

```python
from returns.io import IOResult, IOSuccess, IOFailure
from returns.result import safe

@safe
def parse_int(s: str) -> int:
    return int(s)

def read_config(path: str) -> IOResult[dict, str]:
    try:
        with open(path) as f:
            return IOSuccess({'data': f.read()})
    except FileNotFoundError:
        return IOFailure("File not found")

def process_config(config: dict) -> IOResult[int, str]:
    data = config.get('data', '0')
    return parse_int(data).to_io()

# Chaining IO and validation
result: IOResult[int, str] = (
    read_config('config.txt')
    .bind(process_config)
)

# Pattern matching on result
result.alt(
    lambda error: print(f"Error: {error}")
).map(
    lambda value: print(f"Success: {value}")
)
```

**Pipeline and Flow**

The `flow` function enables readable left-to-right composition, while `pipeline` provides a more structured approach with explicit steps.

```python
from returns.pipeline import flow
from returns.pointfree import bind, map_

def validate_positive(x: int) -> Result[int, str]:
    return Success(x) if x > 0 else Failure("Not positive")

def double(x: int) -> int:
    return x * 2

def to_string(x: int) -> str:
    return f"Result: {x}"

# Flow composition
result = flow(
    10,
    validate_positive,
    bind(lambda x: Success(double(x))),
    map_(to_string)
)  # Success("Result: 20")

# Pipeline with multiple steps
from returns.pipeline import pipe

processed = pipe(
    [1, 2, 3, 4, 5],
    lambda xs: filter(lambda x: x > 2, xs),
    list,
    lambda xs: map(double, xs),
    list
)  # [6, 8, 10]
```

**Curry and Partial**

Returns provides typed currying and partial application with full mypy support, ensuring type safety throughout composition.

```python
from returns.curry import curry, partial

@curry
def add_three(x: int, y: int, z: int) -> int:
    return x + y + z

add_one = add_three(1)  # Type: Callable[[int, int], int]
add_one_two = add_three(1)(2)  # Type: Callable[[int], int]
result = add_three(1)(2)(3)  # 6

# Partial application
from operator import add, mul

increment = partial(add, 1)
double = partial(mul, 2)

result = flow(
    5,
    increment,  # 6
    double      # 12
)
```

**Do-notation**

Returns implements do-notation for imperative-style monadic composition, making complex chains more readable.

```python
from returns.result import Result, Success
from returns.context import Reader
from returns.do_notation import do

@do(Result[int, str])
def calculate(x: int, y: int) -> Result[int, str]:
    a = yield divide(x, y)
    b = yield sqrt(a)
    c = yield Success(b * 2)
    return c

result = calculate(16, 4)  # Success(4.0)

# With Reader for dependency injection
@do(Reader[dict, int])
def get_computed_value():
    config = yield Reader.ask()
    base = yield Reader(lambda cfg: cfg['base'])
    multiplier = yield Reader(lambda cfg: cfg['multiplier'])
    return base * multiplier

config = {'base': 10, 'multiplier': 5}
value = get_computed_value().run(config)  # 50
```

