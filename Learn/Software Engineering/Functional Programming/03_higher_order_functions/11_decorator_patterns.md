## Decorator Patterns


Decorators are higher-order functions that take a function as input and return a new function with enhanced or modified behavior, without altering the original function's source code. They embody the principle of composition and separation of concerns.

### Core Mechanism

A decorator wraps a target function, intercepts its execution, and can add behavior before, after, or around the original function call. The decorator returns a new function that maintains the original's interface while extending its capabilities.

```python
def trace(func):
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__} with {args}, {kwargs}")
        result = func(*args, **kwargs)
        print(f"{func.__name__} returned {result}")
        return result
    return wrapper

def add(a, b):
    return a + b

decorated_add = trace(add)
result = decorated_add(3, 5)
```

**Output:**

```
Calling add with (3, 5), {}
add returned 8
```

### Preserving Function Metadata

Decorators can lose the original function's metadata (name, docstring, signature). Using `functools.wraps` preserves this information:

```python
from functools import wraps

def logging_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        print(f"Executing {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@logging_decorator
def calculate(x, y):
    """Calculates sum of two numbers"""
    return x + y

print(calculate.__name__)  # 'calculate', not 'wrapper'
print(calculate.__doc__)   # Original docstring preserved
```

### Syntactic Sugar

Python's `@` syntax provides a cleaner way to apply decorators:

```python
@trace
def multiply(a, b):
    return a * b

# Equivalent to: multiply = trace(multiply)
```

### Common Patterns

**Memoization** - Caching function results:

```python
def memoize(func):
    cache = {}
    @wraps(func)
    def wrapper(*args):
        if args not in cache:
            cache[args] = func(*args)
        return cache[args]
    return wrapper

@memoize
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
```

**Timing** - Measuring execution duration:

```python
import time

def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        duration = time.time() - start
        print(f"{func.__name__} took {duration:.4f}s")
        return result
    return wrapper
```

**Validation** - Enforcing preconditions:

```python
def validate_positive(func):
    @wraps(func)
    def wrapper(n):
        if n <= 0:
            raise ValueError("Input must be positive")
        return func(n)
    return wrapper

@validate_positive
def square_root(n):
    return n ** 0.5
```

### Decorator Classes

Decorators can be implemented as classes with `__call__` method:

```python
class CountCalls:
    def __init__(self, func):
        self.func = func
        self.count = 0
    
    def __call__(self, *args, **kwargs):
        self.count += 1
        print(f"Call {self.count} to {self.func.__name__}")
        return self.func(*args, **kwargs)

@CountCalls
def greet(name):
    return f"Hello, {name}"
```

**Key Points:**

- Decorators enable cross-cutting concerns (logging, timing, caching) without modifying core logic
- They promote DRY principle by extracting repetitive patterns
- Decorators compose behaviors in a declarative manner
- Use `functools.wraps` to maintain function introspection capabilities

