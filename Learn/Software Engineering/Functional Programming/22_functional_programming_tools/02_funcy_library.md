## Funcy library


Funcy provides a collection of fancy functional tools with an emphasis on practical utility and Pythonic design. It combines ideas from Clojure, Haskell, and other functional languages while maintaining readability.

**Sequence Operations**

The library offers `take`, `drop`, `first`, `second`, `last`, and `nth` for precise element access. `repeatedly` and `iterate` generate infinite sequences, while `takewhile` and `dropwhile` provide predicate-based boundaries.

```python
from funcy import take, drop, first, last, repeatedly, iterate, takewhile

# Element access
numbers = range(10)
first_five = take(5, numbers)  # [0, 1, 2, 3, 4]
skip_five = drop(5, numbers)   # [5, 6, 7, 8, 9]
first_elem = first(numbers)    # 0
last_elem = last(numbers)      # 9

# Infinite sequences
import random
randoms = repeatedly(random.random)
first_three = take(3, randoms)  # [0.234..., 0.891..., 0.456...]

powers_of_two = iterate(lambda x: x * 2, 1)
# 1, 2, 4, 8, 16, 32, ...

# Conditional boundaries
positive = takewhile(lambda x: x < 5, range(10))  # [0, 1, 2, 3, 4]
```

**Collection Utilities**

`walk` and `walk_keys`/`walk_values` transform nested structures recursively. `project` extracts specific keys from dictionaries, similar to SQL SELECT. `where` filters collections based on multiple key-value conditions.

```python
from funcy import walk, walk_keys, walk_values, project, where

# Deep transformation
nested = {'a': [1, 2], 'b': {'c': [3, 4]}}
doubled = walk(lambda x: x * 2 if isinstance(x, int) else x, nested)
# {'a': [2, 4], 'b': {'c': [6, 8]}}

# Dictionary transformations
data = {'name': 'john', 'age': 30, 'city': 'NYC'}
upper_keys = walk_keys(str.upper, data)
# {'NAME': 'john', 'AGE': 30, 'CITY': 'NYC'}

# Projection
users = [
    {'name': 'Alice', 'age': 25, 'email': 'a@ex.com'},
    {'name': 'Bob', 'age': 30, 'email': 'b@ex.com'}
]
names_ages = project(users, ['name', 'age'])
# [{'name': 'Alice', 'age': 25}, {'name': 'Bob', 'age': 30}]

# Multi-condition filtering
adults = where(users, age=lambda x: x >= 18)
```

**Function Decorators**

Funcy provides decorators like `@decorator`, `@wraps`, and `@unwrap` for meta-programming. The `@once` and `@once_per` decorators ensure functions execute only once or once per argument combination.

```python
from funcy import decorator, once, once_per

@decorator
def log_calls(call):
    print(f"Calling {call._func.__name__}")
    return call()

@log_calls
def add(x, y):
    return x + y

# Singleton pattern
@once
def expensive_init():
    print("Initializing...")
    return {"config": "loaded"}

config1 = expensive_init()  # Prints "Initializing..."
config2 = expensive_init()  # Returns cached result

# Per-argument memoization
@once_per('user_id')
def load_user_data(user_id):
    print(f"Loading data for {user_id}")
    return {"id": user_id, "data": "..."}
```

**String and Regex Utilities**

`re_find`, `re_all`, and `re_test` simplify regex operations with cleaner syntax. String manipulation functions like `cut_prefix`, `cut_suffix`, and `str_join` handle common patterns.

```python
from funcy import re_find, re_all, re_test, cut_prefix, cut_suffix

# Regex operations
text = "Contact: john@example.com or jane@example.com"
email = re_find(r'\w+@\w+\.\w+', text)  # 'john@example.com'
all_emails = re_all(r'\w+@\w+\.\w+', text)  # ['john@...', 'jane@...']
has_email = re_test(r'\w+@\w+\.\w+', text)  # True

# String manipulation
url = "https://example.com/path"
path = cut_prefix(url, "https://")  # 'example.com/path'
filename = "document.txt"
name = cut_suffix(filename, ".txt")  # 'document'
```

**Data Flow Control**

`tap` allows side effects in pipelines without breaking the chain. `raiser` and `ignore` handle exceptions functionally. `post_processing` applies transformations to function results.

```python
from funcy import tap, raiser, ignore, post_processing

# Side effects in pipelines
result = (range(10)
    | tap(print)  # Prints values as they pass
    | filter(lambda x: x % 2 == 0)
    | list)

# Exception handling
safe_int = ignore(ValueError, default=0)(int)
safe_int("123")  # 123
safe_int("abc")  # 0

# Post-processing decorator
@post_processing(sorted)
def get_items():
    return [3, 1, 4, 1, 5]

items = get_items()  # [1, 1, 3, 4, 5]
```

