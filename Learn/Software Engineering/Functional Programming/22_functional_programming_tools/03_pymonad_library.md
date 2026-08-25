## PyMonad library


PyMonad implements monadic patterns from Haskell, providing containers for managing effects, state, and computations. It enables railroad-oriented programming and explicit handling of failure cases.

**Maybe Monad**

The Maybe monad represents computations that might fail, eliminating null checks and providing safe chaining. `Just` contains a value, while `Nothing` represents absence.

```python
from pymonad.maybe import Just, Nothing

def safe_divide(x, y):
    return Just(x / y) if y != 0 else Nothing

def safe_sqrt(x):
    return Just(x ** 0.5) if x >= 0 else Nothing

# Chaining with bind (>>=)
result = (Just(16)
    .bind(safe_sqrt)      # Just(4.0)
    .bind(lambda x: safe_divide(x, 2)))  # Just(2.0)

error_case = (Just(-16)
    .bind(safe_sqrt)      # Nothing
    .bind(lambda x: safe_divide(x, 2)))  # Nothing (propagates)

# Map over Maybe
squared = Just(5).map(lambda x: x ** 2)  # Just(25)
nothing_squared = Nothing.map(lambda x: x ** 2)  # Nothing

# Extract with default
value = Just(42).value_or(0)     # 42
default = Nothing.value_or(0)    # 0
```

**Either Monad**

Either represents computations that can succeed (Right) or fail with an error message (Left). It provides more informative error handling than Maybe.

```python
from pymonad.either import Left, Right

def validate_age(age):
    if age < 0:
        return Left("Age cannot be negative")
    if age > 150:
        return Left("Invalid age")
    return Right(age)

def calculate_discount(age):
    if age < 18:
        return Right(0.1)
    if age >= 65:
        return Right(0.2)
    return Right(0.0)

# Chaining validations
result = (validate_age(70)
    .bind(calculate_discount))  # Right(0.2)

error = (validate_age(-5)
    .bind(calculate_discount))  # Left("Age cannot be negative")

# Either with error accumulation
def process_user(data):
    return (validate_age(data['age'])
        .bind(lambda age: Right({'age': age, 'discount': 0.1})))

# Pattern matching
result.either(
    lambda error: print(f"Error: {error}"),
    lambda value: print(f"Success: {value}")
)
```

**List Monad**

The List monad represents non-deterministic computations, naturally handling multiple possible outcomes. It enables elegant list comprehensions and Cartesian products.

```python
from pymonad.list import ListMonad

# Non-deterministic computation
numbers = ListMonad(1, 2, 3)
doubled = numbers.map(lambda x: x * 2)  # ListMonad(2, 4, 6)

# Bind for combinations
result = (ListMonad(1, 2, 3)
    .bind(lambda x: ListMonad(x, -x)))  # ListMonad(1, -1, 2, -2, 3, -3)

# Cartesian product
pairs = (ListMonad('a', 'b')
    .bind(lambda x: ListMonad(1, 2).map(lambda y: (x, y))))
# ListMonad(('a', 1), ('a', 2), ('b', 1), ('b', 2))

# Filter and chain
evens = (ListMonad(1, 2, 3, 4, 5, 6)
    .filter(lambda x: x % 2 == 0)
    .map(lambda x: x ** 2))  # ListMonad(4, 16, 36)
```

**Reader Monad**

Reader manages dependency injection and configuration propagation through computations, avoiding explicit parameter passing.

```python
from pymonad.reader import Reader

def get_base_price(config):
    return config['base_price']

def apply_tax(price):
    return Reader(lambda config: price * (1 + config['tax_rate']))

def apply_discount(price):
    return Reader(lambda config: price * (1 - config['discount']))

# Compose operations
calculate_final = (Reader(get_base_price)
    .bind(lambda price: apply_tax(price))
    .bind(lambda price: apply_discount(price)))

config = {'base_price': 100, 'tax_rate': 0.2, 'discount': 0.1}
final_price = calculate_final.run(config)  # 108.0

# Local configuration modification
def with_vip_discount(computation):
    return computation.local(lambda cfg: {**cfg, 'discount': 0.2})

vip_price = with_vip_discount(calculate_final).run(config)  # 96.0
```

**Writer Monad**

Writer carries auxiliary data (like logs) alongside computations, enabling pure logging without side effects.

```python
from pymonad.writer import Writer

def add_with_log(x, y):
    return Writer(x + y, [f"Added {x} and {y}"])

def multiply_with_log(x, y):
    return Writer(x * y, [f"Multiplied {x} and {y}"])

# Chain with logging
result = (add_with_log(3, 4)  # Writer(7, ["Added 3 and 4"])
    .bind(lambda x: multiply_with_log(x, 2)))
# Writer(14, ["Added 3 and 4", "Multiplied 7 and 2"])

value, log = result.value, result.log
# value: 14
# log: ["Added 3 and 4", "Multiplied 7 and 2"]
```

**State Monad**

State threads mutable state through pure computations, making state transformations explicit and composable.

```python
from pymonad.state import State

def push(value):
    return State(lambda stack: (None, [value] + stack))

def pop():
    return State(lambda stack: (stack[0] if stack else None, stack[1:] if stack else []))

def peek():
    return State(lambda stack: (stack[0] if stack else None, stack))

# Compose stateful operations
stack_ops = (push(1)
    .bind(lambda _: push(2))
    .bind(lambda _: push(3))
    .bind(lambda _: pop())
    .bind(lambda x: peek().map(lambda y: (x, y))))

result, final_state = stack_ops.run([])
# result: (3, 2)
# final_state: [2, 1]
```

