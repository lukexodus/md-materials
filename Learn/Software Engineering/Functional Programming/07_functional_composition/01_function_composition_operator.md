## Function Composition Operator


Function composition is the process of combining two or more functions to produce a new function, where the output of one function becomes the input to the next. Mathematically, composing functions `f` and `g` creates a new function `h(x) = f(g(x))`.

### Mathematical Foundation

In mathematics, composition is denoted as `(f ∘ g)(x) = f(g(x))`. The composition reads right-to-left: apply `g` first, then apply `f` to the result.

```python
def compose(f, g):
    def composed(x):
        return f(g(x))
    return composed

# Simple functions
def add_three(x):
    return x + 3

def multiply_two(x):
    return x * 2

# Compose them
add_then_multiply = compose(multiply_two, add_three)
print(add_then_multiply(5))  # (5 + 3) * 2 = 16
```

**Output:**

```
16
```

### Generalized Composition

A more flexible composition function that handles arbitrary arguments:

```python
def compose(f, g):
    def composed(*args, **kwargs):
        return f(g(*args, **kwargs))
    return composed

def double(x):
    return x * 2

def square(x):
    return x ** 2

double_then_square = compose(square, double)
print(double_then_square(3))  # (3 * 2) ** 2 = 36
```

**Output:**

```
36
```

### Variadic Composition

Composing an arbitrary number of functions using `reduce`:

```python
from functools import reduce

def compose(*functions):
    def composed(x):
        return reduce(lambda acc, f: f(acc), reversed(functions), x)
    return composed

def add_one(x):
    return x + 1

def triple(x):
    return x * 3

def negate(x):
    return -x

# Compose multiple functions
transform = compose(negate, triple, add_one)
print(transform(4))  # -((4 + 1) * 3) = -15
```

**Output:**

```
-15
```

### Alternative Implementation with Reduce

Composing the functions themselves rather than just their application:

```python
from functools import reduce

def compose(*functions):
    return reduce(lambda f, g: lambda x: f(g(x)), functions, lambda x: x)

increment = lambda x: x + 1
double = lambda x: x * 2
square = lambda x: x ** 2

# Right-to-left composition
pipeline = compose(square, double, increment)
print(pipeline(3))  # ((3 + 1) * 2) ** 2 = 64
```

**Output:**

```
64
```

### Practical Example - Data Transformation

```python
def compose(*functions):
    def composed(data):
        return reduce(lambda acc, f: f(acc), reversed(functions), data)
    return composed

# String processing functions
def strip_whitespace(s):
    return s.strip()

def lowercase(s):
    return s.lower()

def remove_punctuation(s):
    import string
    return s.translate(str.maketrans('', '', string.punctuation))

def split_words(s):
    return s.split()

# Compose text processing pipeline
process_text = compose(split_words, remove_punctuation, lowercase, strip_whitespace)

text = "  Hello, World! How are YOU?  "
print(process_text(text))
```

**Output:**

```
['hello', 'world', 'how', 'are', 'you']
```

### Type-Preserving Composition

Using type hints for better clarity:

```python
from typing import Callable, TypeVar

A = TypeVar('A')
B = TypeVar('B')
C = TypeVar('C')

def compose(f: Callable[[B], C], g: Callable[[A], B]) -> Callable[[A], C]:
    def composed(x: A) -> C:
        return f(g(x))
    return composed

def length(s: str) -> int:
    return len(s)

def is_even(n: int) -> bool:
    return n % 2 == 0

# Compose: check if string length is even
check_even_length = compose(is_even, length)
print(check_even_length("hello"))  # False (5 is odd)
print(check_even_length("hi"))     # True (2 is even)
```

**Output:**

```
False
True
```

### Method Chaining vs Composition

Composition provides an alternative to method chaining:

```python
# Method chaining approach (object-oriented)
class Text:
    def __init__(self, value):
        self.value = value
    
    def upper(self):
        return Text(self.value.upper())
    
    def reverse(self):
        return Text(self.value[::-1])
    
    def __str__(self):
        return self.value

# result = Text("hello").upper().reverse()

# Composition approach (functional)
def to_upper(s):
    return s.upper()

def reverse_str(s):
    return s[::-1]

transform = compose(reverse_str, to_upper)
result = transform("hello")
print(result)
```

**Output:**

```
OLLEH
```

### Composing with Side Effects

Composition works best with pure functions, but can handle side effects:

```python
def compose(*functions):
    def composed(x):
        result = x
        for func in reversed(functions):
            result = func(result)
        return result
    return composed

def log_value(label):
    def logger(x):
        print(f"{label}: {x}")
        return x
    return logger

def add_ten(x):
    return x + 10

def square(x):
    return x ** 2

# Composition with logging side effects
pipeline = compose(
    log_value("Final"),
    square,
    log_value("After add"),
    add_ten,
    log_value("Initial")
)

result = pipeline(5)
```

**Output:**

```
Initial: 5
After add: 15
Final: 225
```

### Partial Composition

Composing functions with partial application:

```python
from functools import partial

def multiply(x, y):
    return x * y

def add(x, y):
    return x + y

def compose(f, g):
    return lambda x: f(g(x))

# Create specialized functions through partial application
multiply_by_three = partial(multiply, 3)
add_five = partial(add, 5)

# Compose them
transform = compose(multiply_by_three, add_five)
print(transform(10))  # (10 + 5) * 3 = 45
```

**Output:**

```
45
```

**Key Points:**

- Composition creates new functions by chaining existing ones right-to-left
- The output type of one function must match the input type of the next
- Composition promotes modularity by building complex operations from simple ones
- Works best with pure functions that avoid side effects
- Can be implemented for binary composition or variadic composition
- Enables declarative programming by describing transformations rather than imperative steps

