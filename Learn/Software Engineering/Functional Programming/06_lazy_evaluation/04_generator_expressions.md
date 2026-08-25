## Generator Expressions


Generator expressions create sequences lazily, producing values on-demand without materializing entire collections in memory.

### Core Concept

A generator expression is a compact syntax for creating iterators that compute elements one at a time, typically using comprehension-like notation.

**Python syntax:**

```python
# Generator expression
gen = (x**2 for x in range(1000000))

# List comprehension (eager)
lst = [x**2 for x in range(1000000)]
```

The generator expression creates an iterator; the list comprehension creates a complete list.

### Generator vs List Comprehension

**List comprehension (eager):**

```python
squares = [x**2 for x in range(1000000)]
# Allocates entire list immediately
# Memory: ~8MB (1M integers * 8 bytes)
```

**Generator expression (lazy):**

```python
squares = (x**2 for x in range(1000000))
# Creates iterator object
# Memory: ~100 bytes (iterator state)
# Values computed on demand
```

### Memory Efficiency

Generators maintain constant memory regardless of sequence length:

**Example:**

```python
# Sum of large sequence
total = sum(x**2 for x in range(1000000))

# Generator computes one value at a time
# Peak memory: single integer
# Compare to list: 8MB allocated
```

### Consumption Patterns

**Single-pass iteration:**

```python
gen = (x for x in range(5))

# First iteration
for val in gen:
    print(val)  # 0, 1, 2, 3, 4

# Second iteration
for val in gen:
    print(val)  # Nothing! Generator exhausted
```

Generators are single-use; once exhausted, they yield no more values.

**Conversion to collection:**

```python
gen = (x**2 for x in range(10))

# Convert to list (materializes all)
values = list(gen)  # [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# Generator now exhausted
```

### Pipeline Composition

Generators compose into processing pipelines:

**Example:**

```python
# Pipeline: generate, filter, transform
nums = (x for x in range(1000000))
evens = (x for x in nums if x % 2 == 0)
squares = (x**2 for x in evens)

# Nothing computed yet!

# Compute first 10
first_ten = list(itertools.islice(squares, 10))
# [0, 4, 16, 36, 64, 100, 144, 196, 256, 324]

# Only computed ~20 source values
```

Each stage remains lazy; values flow through pipeline on demand.

### Infinite Sequences

Generators naturally express infinite sequences:

**Example:**

```python
import itertools

# Infinite natural numbers
naturals = (x for x in itertools.count())

# Infinite Fibonacci
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

fibs = fibonacci()

# Take first 10
list(itertools.islice(fibs, 10))
# [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
```

### Conditional Generation

Generators support filtering and conditional logic:

**Example:**

```python
# Pythagorean triples
triples = ((a, b, c) 
           for a in range(1, 100)
           for b in range(a, 100)
           for c in range(b, 100)
           if a**2 + b**2 == c**2)

list(triples)
# [(3, 4, 5), (5, 12, 13), (6, 8, 10), ...]
```

### Nested Generators

Generators can be nested and flattened:

**Example:**

```python
# Nested structure
matrix = ((j for j in range(i, i+3)) for i in range(0, 9, 3))

# Iterate outer
for row in matrix:
    print(list(row))
# [0, 1, 2]
# [3, 4, 5]
# [6, 7, 8]

# Flatten with chain
import itertools
flat = (val for row in matrix for val in row)
# Equivalent to: itertools.chain.from_iterable(matrix)
```

### Generator Functions vs Expressions

**Generator expression:** Single expression, limited to simple patterns

**Generator function:** Full function body with `yield`, supports complex logic

**Example:**

```python
# Generator expression
squares = (x**2 for x in range(10))

# Equivalent generator function
def squares_gen():
    for x in range(10):
        yield x**2

squares = squares_gen()

# Complex generator function
def primes():
    n = 2
    while True:
        if is_prime(n):
            yield n
        n += 1
```

### Stateful Generators

Generators maintain internal state across yields:

**Example:**

```python
def running_average():
    total = 0
    count = 0
    while True:
        value = yield (total / count if count > 0 else 0)
        total += value
        count += 1

avg = running_average()
next(avg)  # Prime the generator
avg.send(10)  # 10.0
avg.send(20)  # 15.0
avg.send(30)  # 20.0
```

### Performance Characteristics

**Time complexity:** Same as equivalent eager code (per-element work identical)

**Space complexity:** O(1) vs O(n) for generator vs list

**Overhead:** Small per-element overhead from iterator protocol

**Example:**

```python
# Time comparison (per element: same)
# Space comparison:
import sys

lst = [x for x in range(1000000)]
sys.getsizeof(lst)  # ~8000000 bytes

gen = (x for x in range(1000000))
sys.getsizeof(gen)  # ~120 bytes
```

### Early Termination

Generators naturally support early termination:

**Example:**

```python
def process_until(data, condition):
    for item in data:
        result = expensive_transform(item)
        if condition(result):
            return result
        yield result

# Stops when condition met
# Doesn't process remaining data
```

### Limitations

**No random access:**

```python
gen = (x for x in range(10))
# gen[5]  # Error! No indexing

# Must consume to reach element
list(itertools.islice(gen, 5, 6))  # [5]
```

**No length:**

```python
gen = (x for x in range(10))
# len(gen)  # Error! No __len__
```

**Single-pass only:**

```python
gen = (x for x in range(5))
list(gen)  # [0, 1, 2, 3, 4]
list(gen)  # [] - exhausted
```

### Language-Specific Variants

**Python:** Generator expressions and functions with `yield`

**JavaScript:** Generator functions with `function*` and `yield`

```javascript
function* squares() {
    let i = 0;
    while (true) {
        yield i * i;
        i++;
    }
}
```

**Scala:** Lazy views and iterators

```scala
val squares = (1 to 1000000).view.map(x => x * x)
```

**C#:** LINQ with deferred execution

```csharp
var squares = Enumerable.Range(1, 1000000).Select(x => x * x);
```

### Chaining with Standard Functions

**Example:**

```python
import itertools

# Chaining operations
data = (x for x in range(100))
filtered = filter(lambda x: x % 2 == 0, data)
mapped = map(lambda x: x**2, filtered)
result = itertools.islice(mapped, 10)

list(result)
# [0, 4, 16, 36, 64, 100, 144, 196, 256, 324]

# All operations remain lazy until list() forces
```

### Resource Management

Generators can manage resources lazily:

**Example:**

```python
def read_large_file(path):
    with open(path) as f:
        for line in f:
            yield line.strip()

# File opened when iteration begins
# Reads one line at a time
# File closed when generator exhausted or GC'd
for line in read_large_file("huge.txt"):
    if "target" in line:
        break  # File closed early
```

**Key Points:**

- Generator expressions create lazy iterators with minimal memory
- Support infinite sequences naturally
- Single-pass only—exhausted after iteration
- Enable memory-efficient pipeline composition
- No random access or length operations
- Slight overhead vs eager evaluation for per-element work

