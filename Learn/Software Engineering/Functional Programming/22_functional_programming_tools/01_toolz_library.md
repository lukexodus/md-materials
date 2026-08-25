## Toolz library


Toolz provides a set of utility functions for iterators, functions, and dictionaries, emphasizing lazy evaluation and composability. It extends Python's `itertools` and `functools` with additional tools for data processing pipelines.

**Core Iterator Functions**

The library offers `partition`, which splits iterables based on a predicate function, returning two iterables for true and false cases. The `partition_all` function chunks data into fixed-size groups, useful for batch processing. `sliding_window` creates overlapping windows of elements, enabling moving average calculations and pattern detection.

```python
from toolz import partition, partition_all, sliding_window

# Partition by predicate
is_even = lambda x: x % 2 == 0
evens, odds = partition(is_even, range(10))
# evens: [0, 2, 4, 6, 8], odds: [1, 3, 5, 7, 9]

# Fixed-size chunks
chunks = list(partition_all(3, range(10)))
# [(0, 1, 2), (3, 4, 5), (6, 7, 8), (9,)]

# Sliding windows
windows = list(sliding_window(3, range(5)))
# [(0, 1, 2), (1, 2, 3), (2, 3, 4)]
```

**Function Composition**

The `compose` function chains functions right-to-left, while `pipe` chains left-to-right for more readable data transformations. `thread_first` and `thread_last` provide threading macros similar to Clojure, inserting values at different positions in function calls.

```python
from toolz import compose, pipe, thread_first

# Right-to-left composition
process = compose(sum, list, filter(lambda x: x > 0))
result = process([-1, 2, -3, 4])  # 6

# Left-to-right pipeline
result = pipe(
    range(10),
    filter(lambda x: x % 2 == 0),
    map(lambda x: x ** 2),
    sum
)  # 120

# Threading with multiple arguments
result = thread_first(
    [1, 2, 3],
    (map, lambda x: x * 2),
    list,
    (sorted, None, True)  # reverse=True
)  # [6, 4, 2]
```

**Dictionary Operations**

`merge` and `merge_with` combine dictionaries, with the latter using a function to resolve conflicts. `assoc` and `dissoc` provide immutable dictionary updates, returning new dictionaries rather than modifying existing ones. `get_in` and `update_in` navigate and modify nested structures safely.

```python
from toolz import merge_with, assoc, dissoc, get_in, update_in

# Merge with conflict resolution
d1 = {'a': 1, 'b': 2}
d2 = {'b': 3, 'c': 4}
result = merge_with(sum, d1, d2)  # {'a': 1, 'b': 5, 'c': 4}

# Immutable updates
original = {'x': 1, 'y': 2}
updated = assoc(original, 'z', 3)  # {'x': 1, 'y': 2, 'z': 3}
removed = dissoc(original, 'x')    # {'y': 2}

# Nested access
nested = {'a': {'b': {'c': 42}}}
value = get_in(['a', 'b', 'c'], nested)  # 42
modified = update_in(nested, ['a', 'b', 'c'], lambda x: x * 2)
# {'a': {'b': {'c': 84}}}
```

**Currying and Partial Application**

The `curry` decorator automatically enables partial application for functions, creating more flexible and reusable components. It works with variable arity and keyword arguments.

```python
from toolz import curry

@curry
def multiply(x, y, z):
    return x * y * z

double = multiply(2)
double_triple = multiply(2, 3)
result = double_triple(4)  # 24

# Works with built-in functions
from toolz.curried import map, filter, reduce
process = compose(
    list,
    map(lambda x: x ** 2),
    filter(lambda x: x % 2 == 0)
)
```

**Memoization**

`memoize` caches function results based on arguments, trading memory for speed. It's particularly effective for recursive functions or expensive computations with repeated inputs.

```python
from toolz import memoize

@memoize
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

# First call computes, subsequent calls use cache
fib_10 = fibonacci(10)  # Computed once
fib_10_again = fibonacci(10)  # Retrieved from cache
```

