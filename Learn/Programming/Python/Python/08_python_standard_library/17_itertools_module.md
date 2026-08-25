## `itertools` Module


### Overview

The `itertools` module provides a collection of tools for creating iterators and working with iterable objects efficiently. It implements iterator building blocks inspired by functional programming languages and offers memory-efficient solutions for complex iteration patterns. All functions return iterators, making them suitable for processing large datasets without loading everything into memory.

### Infinite Iterators

#### count()

Creates an arithmetic progression starting from a given number with a specified step.

```python
import itertools

# Basic counting
counter = itertools.count(10, 2)  # Start at 10, step by 2
for i in counter:
    if i > 20:
        break
    print(i)  # Outputs: 10, 12, 14, 16, 18, 20

# With negative step
countdown = itertools.count(5, -1)
for i in countdown:
    if i < 0:
        break
    print(i)  # Outputs: 5, 4, 3, 2, 1, 0
```

#### cycle()

Infinitely repeats elements from an iterable in order.

```python
colors = itertools.cycle(['red', 'green', 'blue'])
for i, color in enumerate(colors):
    if i >= 10:
        break
    print(f"{i}: {color}")
# Outputs: 0: red, 1: green, 2: blue, 3: red, 4: green...

# Practical example: Round-robin assignment
tasks = ['task1', 'task2', 'task3', 'task4']
workers = itertools.cycle(['worker_a', 'worker_b', 'worker_c'])
assignments = list(zip(tasks, workers))
# [('task1', 'worker_a'), ('task2', 'worker_b'), ('task3', 'worker_c'), ('task4', 'worker_a')]
```

#### repeat()

Repeats a single value either infinitely or for a specified number of times.

```python
# Infinite repetition
ones = itertools.repeat(1)
limited_ones = list(itertools.islice(ones, 5))  # [1, 1, 1, 1, 1]

# Limited repetition
zeros = itertools.repeat(0, 3)
print(list(zeros))  # [0, 0, 0]

# Practical example: Initialize multiple lists
matrix = [list(itertools.repeat(0, 5)) for _ in range(3)]
# [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]
```

### Iterators Terminating on Shortest Input

#### accumulate()

Returns accumulated values using a binary function (default is addition).

```python
# Basic accumulation (cumulative sum)
numbers = [1, 2, 3, 4, 5]
cumsum = list(itertools.accumulate(numbers))
print(cumsum)  # [1, 3, 6, 10, 15]

# With custom function (cumulative product)
import operator
product = list(itertools.accumulate(numbers, operator.mul))
print(product)  # [1, 2, 6, 24, 120]

# With custom lambda (running maximum)
data = [3, 1, 4, 1, 5, 9, 2, 6]
running_max = list(itertools.accumulate(data, max))
print(running_max)  # [3, 3, 4, 4, 5, 9, 9, 9]

# Practical example: Running balance
transactions = [100, -20, 50, -30, 25]
balance = list(itertools.accumulate(transactions))
print(balance)  # [100, 80, 130, 100, 125]
```

#### chain()

Flattens multiple iterables into a single iterator.

```python
# Basic chaining
list1 = [1, 2, 3]
list2 = ['a', 'b', 'c']
list3 = [10, 20]
chained = list(itertools.chain(list1, list2, list3))
print(chained)  # [1, 2, 3, 'a', 'b', 'c', 10, 20]

# chain.from_iterable() for nested iterables
nested = [[1, 2], [3, 4], [5, 6]]
flattened = list(itertools.chain.from_iterable(nested))
print(flattened)  # [1, 2, 3, 4, 5, 6]

# Practical example: Combining multiple data sources
users_db1 = ['alice', 'bob']
users_db2 = ['charlie', 'diana']
users_cache = ['eve']
all_users = list(itertools.chain(users_db1, users_db2, users_cache))
```

#### compress()

Filters elements based on corresponding boolean selectors.

```python
data = ['a', 'b', 'c', 'd', 'e']
selectors = [1, 0, 1, 0, 1]
filtered = list(itertools.compress(data, selectors))
print(filtered)  # ['a', 'c', 'e']

# Practical example: Filter based on conditions
scores = [85, 92, 78, 96, 88]
passing = [score >= 80 for score in scores]
passing_scores = list(itertools.compress(scores, passing))
print(passing_scores)  # [85, 92, 96, 88]
```

#### dropwhile()

Drops elements from the beginning while a predicate is true, then returns the rest.

```python
numbers = [1, 3, 5, 24, 7, 11, 9, 2]
# Drop while numbers are odd
result = list(itertools.dropwhile(lambda x: x % 2 == 1, numbers))
print(result)  # [24, 7, 11, 9, 2] - stops dropping after first even number

# Practical example: Skip header comments in a file
lines = ['# Comment 1', '# Comment 2', 'data line 1', 'data line 2']
data_lines = list(itertools.dropwhile(lambda x: x.startswith('#'), lines))
print(data_lines)  # ['data line 1', 'data line 2']
```

#### takewhile()

Takes elements while a predicate is true, then stops.

```python
numbers = [1, 3, 5, 24, 7, 11]
# Take while numbers are odd
result = list(itertools.takewhile(lambda x: x % 2 == 1, numbers))
print(result)  # [1, 3, 5] - stops at first even number

# Practical example: Process items until a condition
temperatures = [20, 22, 25, 30, 35, 28, 24]
comfortable = list(itertools.takewhile(lambda x: x < 30, temperatures))
print(comfortable)  # [20, 22, 25]
```

#### filterfalse()

Returns elements where the predicate is false (opposite of filter()).

```python
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
odd_numbers = list(itertools.filterfalse(lambda x: x % 2 == 0, numbers))
print(odd_numbers)  # [1, 3, 5, 7, 9]

# Equivalent to filter with negated condition
even_numbers = list(filter(lambda x: x % 2 == 0, numbers))
not_even = list(itertools.filterfalse(lambda x: x % 2 == 0, numbers))
```

#### groupby()

Groups consecutive elements by a key function.

```python
# Basic grouping
data = ['a', 'a', 'b', 'b', 'b', 'c', 'a', 'a']
grouped = [(key, list(group)) for key, group in itertools.groupby(data)]
print(grouped)  # [('a', ['a', 'a']), ('b', ['b', 'b', 'b']), ('c', ['c']), ('a', ['a', 'a'])]

# With key function
students = [
    ('Alice', 'A'), ('Bob', 'B'), ('Charlie', 'A'), 
    ('David', 'A'), ('Eve', 'B'), ('Frank', 'C')
]
by_grade = [(grade, list(group)) for grade, group in 
           itertools.groupby(sorted(students, key=lambda x: x[1]), key=lambda x: x[1])]

# Practical example: Group transactions by date
transactions = [
    ('2023-01-01', 100), ('2023-01-01', 50), 
    ('2023-01-02', 75), ('2023-01-02', 25), ('2023-01-02', 200)
]
daily_totals = [(date, sum(amount for _, amount in group)) 
               for date, group in itertools.groupby(transactions, key=lambda x: x[0])]
```

#### islice()

Returns selected elements from an iterable using slice notation.

```python
numbers = range(20)

# islice(iterable, stop)
first_five = list(itertools.islice(numbers, 5))
print(first_five)  # [0, 1, 2, 3, 4]

# islice(iterable, start, stop)
middle = list(itertools.islice(numbers, 5, 10))
print(middle)  # [5, 6, 7, 8, 9]

# islice(iterable, start, stop, step)
every_third = list(itertools.islice(numbers, 0, 20, 3))
print(every_third)  # [0, 3, 6, 9, 12, 15, 18]

# Practical example: Pagination
def paginate(iterable, page_size):
    iterator = iter(iterable)
    while True:
        page = list(itertools.islice(iterator, page_size))
        if not page:
            break
        yield page

data = range(25)
for page_num, page in enumerate(paginate(data, 7), 1):
    print(f"Page {page_num}: {page}")
```

#### starmap()

Applies a function to arguments tuples from an iterable.

```python
import operator

# Basic usage with operator functions
pairs = [(2, 5), (3, 2), (10, 3)]
powers = list(itertools.starmap(pow, pairs))
print(powers)  # [32, 9, 1000] - 2^5, 3^2, 10^3

# With custom function
def multiply_add(a, b, c):
    return a * b + c

data = [(2, 3, 1), (4, 5, 2), (1, 6, 3)]
results = list(itertools.starmap(multiply_add, data))
print(results)  # [7, 22, 9] - (2*3+1), (4*5+2), (1*6+3)

# Practical example: Distance calculations
import math
points = [(0, 0, 3, 4), (1, 1, 4, 5)]  # (x1, y1, x2, y2)
distances = list(itertools.starmap(
    lambda x1, y1, x2, y2: math.sqrt((x2-x1)**2 + (y2-y1)**2), points))
```

#### tee()

Creates multiple independent iterators from a single iterable.

```python
data = [1, 2, 3, 4, 5]
iter1, iter2, iter3 = itertools.tee(data, 3)

# Each iterator is independent
print(list(iter1))  # [1, 2, 3, 4, 5]
print(list(iter2))  # [1, 2, 3, 4, 5]
print(list(iter3))  # [1, 2, 3, 4, 5]

# Practical example: Process data in multiple ways
def analyze_data(data):
    sum_iter, max_iter, min_iter = itertools.tee(data, 3)
    return sum(sum_iter), max(max_iter), min(min_iter)

numbers = [3, 1, 4, 1, 5, 9, 2, 6]
total, maximum, minimum = analyze_data(numbers)
```

#### zip_longest()

Zips iterables of different lengths, filling missing values with a fillvalue.

```python
# Basic usage
list1 = [1, 2, 3]
list2 = ['a', 'b', 'c', 'd', 'e']
zipped = list(itertools.zip_longest(list1, list2, fillvalue=0))
print(zipped)  # [(1, 'a'), (2, 'b'), (3, 'c'), (0, 'd'), (0, 'e')]

# Multiple iterables with different fillvalues
names = ['Alice', 'Bob']
ages = [25, 30, 35]
cities = ['NYC', 'LA', 'Chicago', 'Miami']
combined = list(itertools.zip_longest(names, ages, cities, fillvalue='N/A'))
# [('Alice', 25, 'NYC'), ('Bob', 30, 'LA'), ('N/A', 35, 'Chicago'), ('N/A', 'N/A', 'Miami')]
```

### Combinatorial Iterators

#### product()

Cartesian product of input iterables.

```python
# Basic product
colors = ['red', 'blue']
sizes = ['S', 'M', 'L']
combinations = list(itertools.product(colors, sizes))
print(combinations)  
# [('red', 'S'), ('red', 'M'), ('red', 'L'), ('blue', 'S'), ('blue', 'M'), ('blue', 'L')]

# With repeat parameter
dice_rolls = list(itertools.product(range(1, 7), repeat=2))
print(len(dice_rolls))  # 36 - all possible pairs of dice rolls

# Practical example: Generate test cases
test_params = {
    'browser': ['chrome', 'firefox'],
    'os': ['windows', 'mac'],
    'version': ['v1', 'v2']
}
test_cases = list(itertools.product(*test_params.values()))
```

#### permutations()

Returns all permutations of an iterable.

```python
# All permutations
letters = ['A', 'B', 'C']
perms = list(itertools.permutations(letters))
print(perms)  # [('A', 'B', 'C'), ('A', 'C', 'B'), ('B', 'A', 'C'), ('B', 'C', 'A'), ('C', 'A', 'B'), ('C', 'B', 'A')]

# Permutations of specific length
perms_2 = list(itertools.permutations(letters, 2))
print(perms_2)  # [('A', 'B'), ('A', 'C'), ('B', 'A'), ('B', 'C'), ('C', 'A'), ('C', 'B')]

# Practical example: Generate possible passwords
digits = '123'
possible_pins = [''.join(p) for p in itertools.permutations(digits, 3)]
print(possible_pins)  # ['123', '132', '213', '231', '312', '321']
```

#### combinations()

Returns combinations without repetition.

```python
# Basic combinations
items = ['A', 'B', 'C', 'D']
pairs = list(itertools.combinations(items, 2))
print(pairs)  # [('A', 'B'), ('A', 'C'), ('A', 'D'), ('B', 'C'), ('B', 'D'), ('C', 'D')]

# Combinations of different lengths
for r in range(1, len(items) + 1):
    combs = list(itertools.combinations(items, r))
    print(f"Combinations of {r}: {len(combs)} items")

# Practical example: Team selection
players = ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve']
teams_of_3 = list(itertools.combinations(players, 3))
print(f"Possible teams of 3: {len(teams_of_3)}")
```

#### combinations_with_replacement()

Returns combinations with repetition allowed.

```python
# Basic usage
items = ['A', 'B', 'C']
combs_with_rep = list(itertools.combinations_with_replacement(items, 2))
print(combs_with_rep)  # [('A', 'A'), ('A', 'B'), ('A', 'C'), ('B', 'B'), ('B', 'C'), ('C', 'C')]

# Practical example: Ice cream flavors with multiple scoops
flavors = ['vanilla', 'chocolate', 'strawberry']
double_scoops = list(itertools.combinations_with_replacement(flavors, 2))
print(f"Double scoop options: {len(double_scoops)}")
```

### Advanced Patterns and Use Cases

#### Pairwise Iteration

```python
def pairwise(iterable):
    """Return successive overlapping pairs from iterable."""
    a, b = itertools.tee(iterable)
    next(b, None)
    return zip(a, b)

# Example usage
numbers = [1, 2, 3, 4, 5]
pairs = list(pairwise(numbers))
print(pairs)  # [(1, 2), (2, 3), (3, 4), (4, 5)]

# Calculate differences between consecutive elements
differences = [b - a for a, b in pairwise(numbers)]
print(differences)  # [1, 1, 1, 1]
```

#### Sliding Window

```python
def sliding_window(iterable, n):
    """Create a sliding window of size n over iterable."""
    iterators = itertools.tee(iterable, n)
    for i, iterator in enumerate(iterators):
        for _ in range(i):
            next(iterator, None)
    return zip(*iterators)

# Example usage
data = [1, 2, 3, 4, 5, 6, 7]
windows = list(sliding_window(data, 3))
print(windows)  # [(1, 2, 3), (2, 3, 4), (3, 4, 5), (4, 5, 6), (5, 6, 7)]

# Moving average calculation
def moving_average(data, window_size):
    windows = sliding_window(data, window_size)
    return [sum(window) / len(window) for window in windows]

prices = [10, 12, 11, 14, 13, 15, 16]
ma_3 = moving_average(prices, 3)
print(ma_3)  # [11.0, 12.33..., 12.66..., 14.0, 14.66...]
```

#### Flatten Nested Structures

```python
def flatten(nested_list):
    """Recursively flatten nested lists."""
    for item in nested_list:
        if isinstance(item, (list, tuple)):
            yield from flatten(item)
        else:
            yield item

# Example usage
nested = [1, [2, 3], [4, [5, 6]], 7]
flat = list(flatten(nested))
print(flat)  # [1, 2, 3, 4, 5, 6, 7]

# Using itertools for simple flattening
simple_nested = [[1, 2], [3, 4], [5, 6]]
flat_simple = list(itertools.chain.from_iterable(simple_nested))
print(flat_simple)  # [1, 2, 3, 4, 5, 6]
```

#### Recipe: Batching

```python
def batched(iterable, n):
    """Batch data into tuples of length n."""
    if n < 1:
        raise ValueError('n must be at least one')
    iterator = iter(iterable)
    while True:
        batch = tuple(itertools.islice(iterator, n))
        if not batch:
            break
        yield batch

# Example usage
data = range(13)
batches = list(batched(data, 4))
print(batches)  # [(0, 1, 2, 3), (4, 5, 6, 7), (8, 9, 10, 11), (12,)]

# Process data in chunks
def process_in_batches(data, batch_size=100):
    for batch in batched(data, batch_size):
        # Process each batch
        result = sum(batch)  # Example processing
        yield result
```

#### Recipe: Unique Elements with Order Preservation

```python
def unique_everseen(iterable, key=None):
    """List unique elements, preserving order. Remember all elements ever seen."""
    seen = set()
    seen_add = seen.add
    if key is None:
        for element in itertools.filterfalse(seen.__contains__, iterable):
            seen_add(element)
            yield element
    else:
        for element in iterable:
            k = key(element)
            if k not in seen:
                seen_add(k)
                yield element

# Example usage
data = [1, 2, 3, 2, 4, 3, 5, 1]
unique = list(unique_everseen(data))
print(unique)  # [1, 2, 3, 4, 5]

# With key function
words = ['apple', 'BANANA', 'apple', 'Cherry', 'banana']
unique_words = list(unique_everseen(words, key=str.lower))
print(unique_words)  # ['apple', 'BANANA', 'Cherry']
```

### Performance Considerations

#### Memory Efficiency

All itertools functions return iterators, not lists, making them memory-efficient for large datasets.

```python
# Memory efficient - processes one item at a time
def process_large_dataset(filename):
    with open(filename) as f:
        # Chain multiple processing steps without creating intermediate lists
        lines = (line.strip() for line in f)
        non_empty = filter(None, lines)
        numbers = (int(line) for line in non_empty if line.isdigit())
        
        # Process in batches
        for batch in batched(numbers, 1000):
            yield sum(batch)

# Compare memory usage
import sys

# Memory intensive - creates full list
large_list = list(range(1000000))
print(f"List size: {sys.getsizeof(large_list)} bytes")

# Memory efficient - iterator
large_iter = itertools.count()
print(f"Iterator size: {sys.getsizeof(large_iter)} bytes")
```

#### Performance Tips

**Key points:**

- Use `itertools.chain.from_iterable()` instead of nested loops for flattening
- `itertools.accumulate()` is faster than manual accumulation loops
- `itertools.compress()` can be more efficient than list comprehensions with conditions
- `itertools.tee()` creates independent iterators but uses more memory as elements are consumed
- Combinatorial functions can generate very large result sets - use with caution

### Common Recipes and Patterns

#### Roundrobin

```python
def roundrobin(*iterables):
    """Visit input iterables in a round-robin fashion."""
    pending = len(iterables)
    nexts = itertools.cycle(iter(it).__next__ for it in iterables)
    while pending:
        try:
            for next in nexts:
                yield next()
        except StopIteration:
            pending -= 1
            nexts = itertools.cycle(itertools.islice(nexts, pending))

# Example usage
result = list(roundrobin('ABC', '12345', 'xyz'))
print(result)  # ['A', '1', 'x', 'B', '2', 'y', 'C', '3', 'z', '4', '5']
```

#### Partition

```python
def partition(predicate, iterable):
    """Partition entries into false entries and true entries."""
    t1, t2 = itertools.tee(iterable)
    return itertools.filterfalse(predicate, t1), filter(predicate, t2)

# Example usage
numbers = range(10)
evens, odds = partition(lambda x: x % 2, numbers)
print(f"Evens: {list(evens)}")  # [0, 2, 4, 6, 8]
print(f"Odds: {list(odds)}")    # [1, 3, 5, 7, 9]
```

#### Powerset

```python
def powerset(iterable):
    """Return the powerset of an iterable."""
    s = list(iterable)
    return itertools.chain.from_iterable(
        itertools.combinations(s, r) for r in range(len(s) + 1))

# Example usage
items = ['A', 'B', 'C']
ps = list(powerset(items))
print(ps)  # [(), ('A',), ('B',), ('C',), ('A', 'B'), ('A', 'C'), ('B', 'C'), ('A', 'B', 'C')]
```

### Integration with Other Python Features

#### Generator Expressions

```python
# Combining itertools with generator expressions
data = range(100)
processed = (x**2 for x in itertools.takewhile(lambda x: x < 10, data))
result = list(itertools.accumulate(processed))
print(result)  # [0, 1, 5, 14, 30, 55, 91, 140, 204, 285]
```

#### Functools Integration

```python
import functools
import operator

# Using with functools.reduce
numbers = [1, 2, 3, 4, 5]
cumulative_products = list(itertools.accumulate(numbers, operator.mul))
total_product = functools.reduce(operator.mul, numbers)

# Partial application with itertools
multiply_by_2 = functools.partial(operator.mul, 2)
doubled = list(map(multiply_by_2, range(5)))
```

#### Collections Integration

```python
from collections import Counter, defaultdict

# Frequency counting with groupby
data = 'aabbccddaab'
frequencies = {key: len(list(group)) for key, group in itertools.groupby(sorted(data))}
print(frequencies)  # {'a': 4, 'b': 3, 'c': 2, 'd': 2}

# Compare with Counter
counter_freq = Counter(data)
print(dict(counter_freq))  # {'a': 4, 'b': 3, 'c': 2, 'd': 2}
```

### Error Handling and Edge Cases

#### Empty Iterables

```python
# Handle empty iterables gracefully
empty_list = []
print(list(itertools.chain(empty_list, [1, 2, 3])))  # [1, 2, 3]
print(list(itertools.accumulate(empty_list)))  # []
print(list(itertools.combinations(empty_list, 2)))  # []

# Check for empty results
def safe_max(iterable):
    try:
        return max(iterable)
    except ValueError:
        return None

data = []
result = safe_max(itertools.chain(data, [0]))  # Provides default
```

#### Large Combinatorial Results

```python
# Be careful with combinatorial explosions
items = list(range(20))
# This would create 2^20 combinations - over 1 million!
# powerset_result = list(powerset(items))  # Don't do this!

# Instead, process in chunks or limit the size
limited_combinations = itertools.islice(
    itertools.combinations(items, 3), 100)  # Only first 100 combinations
safe_result = list(limited_combinations)
```

**Key points:**

- Itertools functions return memory-efficient iterators, not lists
- Combinatorial functions can generate extremely large result sets
- All itertools objects are consumed once - use `itertools.tee()` for multiple iterations
- Perfect for data processing pipelines and functional programming patterns
- Excellent for handling large datasets that don't fit in memory
- Can be combined with generator expressions and other functional programming tools
- [Inference] Performance is generally excellent due to C implementation of core functions
- Essential for writing efficient, readable code that processes sequences and combinations

The itertools module provides a comprehensive toolkit for iterator-based programming, enabling elegant solutions to complex iteration problems while maintaining excellent performance and memory efficiency.

---

