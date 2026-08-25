## Functools Module


The `functools` module provides essential higher-order functions and operations for functional programming. It includes tools for function transformation, caching, method enhancement, and functional composition.

**`partial()` - Partial Application**: Creates new functions by freezing portions of a function's arguments. The resulting partial object is callable and can accept additional arguments. This enables function specialization and configuration reuse.

```python
from functools import partial

def power(base, exponent):
    return base ** exponent

square = partial(power, exponent=2)
cube = partial(power, exponent=3)

square(5)  # 25
cube(5)   # 125

# Useful with map/filter
from operator import mul
double = partial(mul, 2)
list(map(double, [1, 2, 3]))  # [2, 4, 6]
```

**`reduce()` - Fold Operation**: Applies a binary function cumulatively to sequence items, reducing the sequence to a single value. It processes left-to-right and optionally accepts an initializer.

```python
from functools import reduce
from operator import add, mul

numbers = [1, 2, 3, 4, 5]
reduce(add, numbers)  # 15
reduce(mul, numbers)  # 120

# With initializer
reduce(add, numbers, 100)  # 115

# Complex reductions
data = [{'value': 10}, {'value': 20}, {'value': 30}]
total = reduce(lambda acc, d: acc + d['value'], data, 0)  # 60
```

**`lru_cache()` - Memoization**: Decorator that caches function results using a Least Recently Used eviction policy. It dramatically improves performance for expensive, deterministic functions with repeated calls.

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

fibonacci(100)  # Computed efficiently

# Check cache statistics
fibonacci.cache_info()  # CacheInfo(hits=98, misses=101, maxsize=128, currsize=101)

# Clear cache when needed
fibonacci.cache_clear()

# Unbounded cache
@lru_cache(maxsize=None)
def expensive_computation(x):
    return x ** x
```

**`cache()` - Simple Memoization**: Simplified decorator equivalent to `lru_cache(maxsize=None)`. Introduced in Python 3.9, it provides unbounded caching with less overhead than `lru_cache()`.

```python
from functools import cache

@cache
def factorial(n):
    return n * factorial(n-1) if n else 1

factorial(50)  # Cached indefinitely
```

**`wraps()` - Decorator Preservation**: Decorator that copies metadata from wrapped functions to wrapper functions. Essential for preserving `__name__`, `__doc__`, `__module__`, and other attributes when creating decorators.

```python
from functools import wraps

def my_decorator(func):
    @wraps(func)  # Preserves original function metadata
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@my_decorator
def greet(name):
    """Greet someone by name"""
    return f"Hello, {name}"

greet.__name__  # 'greet' (not 'wrapper')
greet.__doc__   # 'Greet someone by name'
```

**`total_ordering()` - Comparison Methods**: Class decorator that fills in missing comparison methods based on `__eq__` and one ordering method (`__lt__`, `__le__`, `__gt__`, or `__ge__`).

```python
from functools import total_ordering

@total_ordering
class Student:
    def __init__(self, name, grade):
        self.name = name
        self.grade = grade
    
    def __eq__(self, other):
        return self.grade == other.grade
    
    def __lt__(self, other):
        return self.grade < other.grade
    # __le__, __gt__, __ge__ automatically generated

alice = Student('Alice', 90)
bob = Student('Bob', 85)
alice > bob  # True (generated from __lt__ and __eq__)
```

**`singledispatch()` - Generic Functions**: Decorator for creating generic functions with type-based dispatch. Enables function overloading based on the type of the first argument.

```python
from functools import singledispatch

@singledispatch
def process(data):
    raise NotImplementedError(f"Cannot process {type(data)}")

@process.register(int)
def _(data):
    return data * 2

@process.register(str)
def _(data):
    return data.upper()

@process.register(list)
def _(data):
    return [x * 2 for x in data]

process(5)        # 10
process('hello')  # 'HELLO'
process([1, 2])   # [2, 4]

# Check registered implementations
process.registry.keys()  # Shows registered types
```

**`cached_property()` - Lazy Property Evaluation**: Decorator that transforms a method into a cached property. The method is called once, and subsequent accesses return the cached value.

```python
from functools import cached_property

class DataProcessor:
    def __init__(self, data):
        self.data = data
    
    @cached_property
    def expensive_computation(self):
        print("Computing...")
        return sum(x ** 2 for x in self.data)

processor = DataProcessor([1, 2, 3, 4, 5])
processor.expensive_computation  # Prints "Computing...", returns 55
processor.expensive_computation  # Returns 55 immediately (cached)
```

**`partialmethod()` - Partial Methods**: Similar to `partial()` but designed for methods. It creates new methods with pre-filled arguments, useful for class definitions.

```python
from functools import partialmethod

class Calculator:
    def power(self, base, exponent):
        return base ** exponent
    
    square = partialmethod(power, exponent=2)
    cube = partialmethod(power, exponent=3)

calc = Calculator()
calc.square(5)  # 25
calc.cube(5)    # 125
```

**`update_wrapper()` - Manual Wrapper Updates**: Lower-level function that `wraps()` uses internally. It manually updates wrapper functions with attributes from wrapped functions.

```python
from functools import update_wrapper

def decorator(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    update_wrapper(wrapper, func)
    return wrapper
```

**`cmp_to_key()` - Comparison Conversion**: Converts old-style comparison functions (returning -1, 0, 1) to key functions suitable for sorting. Useful when working with legacy code or certain sorting algorithms.

```python
from functools import cmp_to_key

def compare(x, y):
    return (x > y) - (x < y)

data = [5, 2, 8, 1, 9]
sorted(data, key=cmp_to_key(compare))  # [1, 2, 5, 8, 9]

# Custom comparison logic
def compare_length_then_alpha(x, y):
    if len(x) != len(y):
        return len(x) - len(y)
    return (x > y) - (x < y)

words = ['python', 'is', 'amazing', 'for', 'functional']
sorted(words, key=cmp_to_key(compare_length_then_alpha))
# ['is', 'for', 'python', 'amazing', 'functional']
```

**Key Points**

- `functools` integrates seamlessly with `operator` and `itertools`
- Caching decorators require hashable arguments
- `partial()` objects are picklable, enabling distributed computing
- Most `functools` features support keyword arguments
- Performance gains from caching can be dramatic for recursive or expensive functions

**Output Performance Considerations**

[Inference] Based on typical Python implementation characteristics, `lru_cache()` and `cache()` provide O(1) lookup time but add memory overhead. The tradeoff between computation time and memory usage should guide cache size selection. For recursive functions, caching transforms exponential complexity to linear in many cases.

