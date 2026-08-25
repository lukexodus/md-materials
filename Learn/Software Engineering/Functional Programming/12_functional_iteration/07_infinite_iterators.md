## Infinite iterators


Infinite iterators produce unbounded sequences, embodying the concept of laziness. They generate values indefinitely until explicitly stopped or consumed by a limiting operation.

**`count(start=0, step=1)`** - Infinite arithmetic sequence:

```python
from itertools import count

# Basic counting
counter = count(10, 2)
# Output: 10, 12, 14, 16, 18, ... (infinitely)

# With islice to limit
from itertools import islice
result = list(islice(count(5), 10))
# Output: [5, 6, 7, 8, 9, 10, 11, 12, 13, 14]

# Floating point steps
floats = count(0.0, 0.5)
# Output: 0.0, 0.5, 1.0, 1.5, 2.0, ...

# Practical: enumerate replacement
data = ['a', 'b', 'c']
indexed = zip(count(), data)
# Output: (0, 'a'), (1, 'b'), (2, 'c')
```

**`cycle(iterable)`** - Infinite repetition of sequence:

```python
from itertools import cycle, islice

colors = ['red', 'green', 'blue']
color_cycle = cycle(colors)
# Output: 'red', 'green', 'blue', 'red', 'green', 'blue', ...

# Get first 10 from cycle
result = list(islice(color_cycle, 10))
# Output: ['red', 'green', 'blue', 'red', 'green', 'blue', 'red', 'green', 'blue', 'red']

# Round-robin assignment
tasks = ['task1', 'task2', 'task3', 'task4', 'task5']
workers = ['Alice', 'Bob', 'Charlie']
assignments = zip(tasks, cycle(workers))
# Output: ('task1', 'Alice'), ('task2', 'Bob'), ('task3', 'Charlie'), 
#         ('task4', 'Alice'), ('task5', 'Bob')
```

**`repeat(object, times=None)`** - Repeats object infinitely or n times:

```python
from itertools import repeat, islice

# Infinite repeat
threes = repeat(3)
# Output: 3, 3, 3, 3, 3, ...

# Limited repeat
result = list(repeat('X', 5))
# Output: ['X', 'X', 'X', 'X', 'X']

# With map for constant values
from itertools import starmap
data = [2, 3, 4]
powers_of_two = list(starmap(pow, zip(repeat(2), data)))
# Output: [4, 8, 16] (2^2, 2^3, 2^4)

# Functional constant application
def apply_n_times(func, value, n):
    return list(map(lambda _: func(value), repeat(None, n)))

result = apply_n_times(lambda x: x * 2, 5, 4)
# Output: [10, 10, 10, 10]
```

**Custom Infinite Iterators:**

```python
def infinite_fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

# Usage
fib = infinite_fibonacci()
first_ten = list(islice(fib, 10))
# Output: [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
```

**Infinite Sequence Generators:**

```python
def primes():
    """Infinite prime number generator"""
    def is_prime(n):
        if n < 2:
            return False
        for i in range(2, int(n ** 0.5) + 1):
            if n % i == 0:
                return False
        return True
    
    n = 2
    while True:
        if is_prime(n):
            yield n
        n += 1

# First 20 primes
prime_gen = primes()
result = list(islice(prime_gen, 20))
# Output: [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]
```

**Combining Infinite Iterators:**

```python
from itertools import count, cycle, islice, compress

# Alternating sequences
even_gen = (x for x in count(0, 2))
odd_gen = (x for x in count(1, 2))
selector = cycle([True, False])

alternating = compress(chain(even_gen, odd_gen), selector)
# [Inference] This creates an alternating pattern based on the selector cycle

# Infinite range with conditions
def conditional_infinite(start, condition):
    current = start
    while True:
        if condition(current):
            yield current
        current += 1

multiples_of_3 = conditional_infinite(0, lambda x: x % 3 == 0)
result = list(islice(multiples_of_3, 15))
# Output: [0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42]
```

**Practical Applications:**

```python
from itertools import count, takewhile

# Generate IDs
id_generator = count(1000)
next_id = lambda: next(id_generator)

# Polling with timeout
def poll_until(condition, max_attempts=None):
    attempts = count() if max_attempts is None else range(max_attempts)
    for attempt in attempts:
        if condition():
            return True
        # wait logic here
    return False

# Infinite stream processing
def process_stream(stream, processor):
    for item in stream:
        processed = processor(item)
        if processed is not None:
            yield processed

infinite_data = count(1)
processed = takewhile(lambda x: x < 1000, process_stream(infinite_data, lambda x: x ** 2))
# Output: 1, 4, 9, 16, 25, ... up to 961
```

