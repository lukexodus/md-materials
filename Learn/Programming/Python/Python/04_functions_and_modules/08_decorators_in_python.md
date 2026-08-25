## Decorators in Python


Decorators are a way to modify or enhance functions or classes without changing their source code. They use the `@decorator_name` syntax and are applied above the function or class definition.

### Basic Concept

A decorator is a function that takes another function as input and returns a modified version of it:

```python
def my_decorator(func):
    def wrapper():
        print("Before function call")
        func()
        print("After function call")
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")

say_hello()
# Output:
# Before function call
# Hello!
# After function call
```

The `@my_decorator` syntax is equivalent to `say_hello = my_decorator(say_hello)`.

### Decorators with Arguments

To handle functions that take arguments, use `*args` and `**kwargs`:

```python
def my_decorator(func):
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__}")
        result = func(*args, **kwargs)
        print(f"Finished {func.__name__}")
        return result
    return wrapper

@my_decorator
def add(a, b):
    return a + b

result = add(3, 5)  # prints decorating messages, returns 8
```

### Common Use Cases

**Timing execution:**
```python
import time

def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.4f} seconds")
        return result
    return wrapper
```

**Caching results:**
```python
def memoize(func):
    cache = {}
    def wrapper(*args):
        if args not in cache:
            cache[args] = func(*args)
        return cache[args]
    return wrapper
```

**Access control:**
```python
def require_auth(func):
    def wrapper(user, *args, **kwargs):
        if not user.is_authenticated:
            raise PermissionError("Authentication required")
        return func(user, *args, **kwargs)
    return wrapper
```

### Preserving Function Metadata

Use `functools.wraps` to preserve the original function's name and docstring:

```python
from functools import wraps

def my_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper
```

### Decorators with Parameters

To create decorators that accept arguments, add another layer of functions:

```python
def repeat(times):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for _ in range(times):
                result = func(*args, **kwargs)
            return result
        return wrapper
    return decorator

@repeat(times=3)
def greet(name):
    print(f"Hello {name}")

greet("Alice")  # prints "Hello Alice" three times
```

### Class Decorators

Decorators can also be applied to classes:

```python
def singleton(cls):
    instances = {}
    @wraps(cls)
    def get_instance(*args, **kwargs):
        if cls not in instances:
            instances[cls] = cls(*args, **kwargs)
        return instances[cls]
    return get_instance

@singleton
class Database:
    pass
```

### Built-in Decorators

Python provides several built-in decorators:

- `@staticmethod` - defines a method that doesn't access instance or class data
- `@classmethod` - defines a method that receives the class as first argument
- `@property` - makes a method accessible like an attribute
- `@abstractmethod` - marks methods that must be implemented in subclasses

---

