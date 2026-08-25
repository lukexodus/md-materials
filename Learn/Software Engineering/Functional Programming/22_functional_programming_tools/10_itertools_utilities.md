## Itertools Utilities


Itertools provides a collection of building blocks for creating efficient, memory-conscious iterator-based operations. These utilities enable complex iteration patterns while maintaining lazy evaluation and composability.

**Infinite Iterators:**

`count()` generates an infinite sequence of numbers with configurable start and step:

```python
from itertools import count

# Basic counting
counter = count(start=10, step=2)
# Generates: 10, 12, 14, 16, 18...

# Practical use with zip for enumeration
items = ['a', 'b', 'c']
indexed = list(zip(count(1), items))
# [(1, 'a'), (2, 'b'), (3, 'c')]

# Creating ID generators
id_generator = count(1000)
user_id_1 = next(id_generator)  # 1000
user_id_2 = next(id_generator)  # 1001
```

`cycle()` repeats elements from an iterable indefinitely:

```python
from itertools import cycle

# Rotating through options
colors = cycle(['red', 'green', 'blue'])
# Generates: red, green, blue, red, green, blue...

# Round-robin task assignment
workers = cycle(['worker_1', 'worker_2', 'worker_3'])
tasks = ['task_a', 'task_b', 'task_c', 'task_d', 'task_e']
assignments = list(zip(tasks, workers))
# [('task_a', 'worker_1'), ('task_b', 'worker_2'), ('task_c', 'worker_3'),
#  ('task_d', 'worker_1'), ('task_e', 'worker_2')]
```

`repeat()` produces the same value repeatedly, either indefinitely or for a specified count:

```python
from itertools import repeat

# Fixed repetitions
repeated = list(repeat('x', 5))  # ['x', 'x', 'x', 'x', 'x']

# Useful with map for multi-argument functions
from operator import pow
bases = [2, 3, 4]
powers = list(map(pow, bases, repeat(3)))  # [8, 27, 64]

# Creating constant-value generators
default_configs = repeat({'timeout': 30, 'retries': 3})
config1 = next(default_configs)
config2 = next(default_configs)
```

**Terminating Iterators:**

`accumulate()` returns running totals or cumulative results of a binary function:

```python
from itertools import accumulate
import operator

numbers = [1, 2, 3, 4, 5]

# Running sum (default)
cumsum = list(accumulate(numbers))  # [1, 3, 6, 10, 15]

# Running product
cumprod = list(accumulate(numbers, operator.mul))  # [1, 2, 6, 24, 120]

# Running maximum
data = [5, 2, 8, 1, 9, 3]
running_max = list(accumulate(data, max))  # [5, 5, 8, 8, 9, 9]

# Custom accumulation: compound interest
principal = [1000, 100, 50, 200]
interest_rate = 1.05  # 5% interest
balances = list(accumulate(principal, lambda acc, deposit: acc * interest_rate + deposit))
```

`chain()` concatenates multiple iterables into a single sequence:

```python
from itertools import chain

list1 = [1, 2, 3]
list2 = [4, 5, 6]
list3 = [7, 8, 9]

combined = list(chain(list1, list2, list3))  # [1, 2, 3, 4, 5, 6, 7, 8, 9]

# chain.from_iterable for nested structures
nested = [[1, 2], [3, 4], [5, 6]]
flattened = list(chain.from_iterable(nested))  # [1, 2, 3, 4, 5, 6]

# Combining different types
mixed = list(chain(range(3), 'abc', [10, 20]))  # [0, 1, 2, 'a', 'b', 'c', 10, 20]
```

`compress()` filters elements based on a boolean selector sequence:

```python
from itertools import compress

data = ['A', 'B', 'C', 'D', 'E']
selectors = [1, 0, 1, 0, 1]

selected = list(compress(data, selectors))  # ['A', 'C', 'E']

# Practical: filter by multiple conditions
users = [
    {'name': 'Alice', 'age': 30, 'active': True},
    {'name': 'Bob', 'age': 25, 'active': False},
    {'name': 'Charlie', 'age': 35, 'active': True}
]

active_flags = [u['active'] for u in users]
active_users = list(compress(users, active_flags))
```

`dropwhile()` and `takewhile()` provide conditional slicing:

```python
from itertools import dropwhile, takewhile

data = [1, 3, 5, 8, 10, 12, 7, 9]

# Drop elements while condition is true
after_even = list(dropwhile(lambda x: x % 2 != 0, data))  # [8, 10, 12, 7, 9]

# Take elements while condition is true
before_even = list(takewhile(lambda x: x % 2 != 0, data))  # [1, 3, 5]

# Processing log files until error
log_lines = ["INFO: Started", "INFO: Processing", "ERROR: Failed", "INFO: Retry"]
valid_logs = list(takewhile(lambda x: not x.startswith("ERROR"), log_lines))
```

`filterfalse()` inverts filter logic:

```python
from itertools import filterfalse

numbers = range(10)

# Get even numbers (filter for odd, then invert)
evens = list(filterfalse(lambda x: x % 2 == 1, numbers))  # [0, 2, 4, 6, 8]

# More readable than double negatives
def is_invalid(x):
    return x < 0 or x > 100

valid_scores = list(filterfalse(is_invalid, [-5, 50, 75, 120, 95]))  # [50, 75, 95]
```

**Combinatoric Iterators:**

`product()` generates Cartesian products:

```python
from itertools import product

# Basic Cartesian product
colors = ['red', 'blue']
sizes = ['S', 'M', 'L']
combinations = list(product(colors, sizes))
# [('red', 'S'), ('red', 'M'), ('red', 'L'), ('blue', 'S'), ('blue', 'M'), ('blue', 'L')]

# Repeat parameter for self-product
binary = list(product([0, 1], repeat=3))
# [(0,0,0), (0,0,1), (0,1,0), (0,1,1), (1,0,0), (1,0,1), (1,1,0), (1,1,1)]

# Grid coordinates
rows = range(3)
cols = range(3)
grid_points = list(product(rows, cols))
```

`permutations()` generates ordered arrangements:

```python
from itertools import permutations

elements = ['A', 'B', 'C']

# All permutations
all_perms = list(permutations(elements))
# [('A','B','C'), ('A','C','B'), ('B','A','C'), ('B','C','A'), ('C','A','B'), ('C','B','A')]

# Fixed-length permutations
two_perms = list(permutations(elements, 2))
# [('A','B'), ('A','C'), ('B','A'), ('B','C'), ('C','A'), ('C','B')]

# Password generation patterns
digits = '123'
patterns = [''.join(p) for p in permutations(digits)]
```

`combinations()` generates unordered selections without replacement:

```python
from itertools import combinations

team = ['Alice', 'Bob', 'Charlie', 'David']

# Choose 2 members
pairs = list(combinations(team, 2))
# [('Alice','Bob'), ('Alice','Charlie'), ('Alice','David'),
#  ('Bob','Charlie'), ('Bob','David'), ('Charlie','David')]

# All possible subsets of size k
items = [1, 2, 3, 4]
subsets_of_3 = list(combinations(items, 3))
# [(1,2,3), (1,2,4), (1,3,4), (2,3,4)]
```

`combinations_with_replacement()` allows repeated elements:

```python
from itertools import combinations_with_replacement

items = ['X', 'Y', 'Z']

# Combinations allowing repetition
combos = list(combinations_with_replacement(items, 2))
# [('X','X'), ('X','Y'), ('X','Z'), ('Y','Y'), ('Y','Z'), ('Z','Z')]

# Dice roll combinations
dice = range(1, 7)
two_dice = list(combinations_with_replacement(dice, 2))
```

**Grouping and Slicing:**

`groupby()` groups consecutive identical elements:

```python
from itertools import groupby

# Basic grouping
data = [1, 1, 2, 2, 2, 3, 1, 1]
grouped = [(key, list(group)) for key, group in groupby(data)]
# [(1, [1, 1]), (2, [2, 2, 2]), (3, [3]), (1, [1, 1])]

# Group by custom key
people = [
    {'name': 'Alice', 'dept': 'Engineering'},
    {'name': 'Bob', 'dept': 'Engineering'},
    {'name': 'Charlie', 'dept': 'Sales'},
    {'name': 'David', 'dept': 'Sales'}
]

# IMPORTANT: groupby requires sorted data
people.sort(key=lambda x: x['dept'])
by_dept = {dept: list(group) for dept, group in groupby(people, key=lambda x: x['dept'])}

# Counting consecutive occurrences
sequence = "aaabbbcccaaa"
counts = [(char, len(list(group))) for char, group in groupby(sequence)]
# [('a', 3), ('b', 3), ('c', 3), ('a', 3)]
```

`islice()` performs efficient slicing without creating intermediate lists:

```python
from itertools import islice, count

# Basic slicing
data = range(100)
subset = list(islice(data, 10, 20))  # Elements 10-19

# Skip pattern
every_third = list(islice(count(), 0, 20, 3))  # [0, 3, 6, 9, 12, 15, 18]

# First N elements of infinite iterator
first_ten = list(islice(count(1), 10))  # [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# Pagination
def paginate(iterable, page_size):
    iterator = iter(iterable)
    while True:
        page = list(islice(iterator, page_size))
        if not page:
            break
        yield page

pages = list(paginate(range(25), 10))
# [[0,1,2,3,4,5,6,7,8,9], [10,11,12,13,14,15,16,17,18,19], [20,21,22,23,24]]
```

**Specialized Iterators:**

`starmap()` applies a function to argument tuples:

```python
from itertools import starmap
import operator

# Apply function to tuple arguments
pairs = [(2, 3), (4, 5), (6, 7)]
products = list(starmap(operator.mul, pairs))  # [6, 20, 42]

# Multiple argument functions
def calculate_area(length, width):
    return length * width

dimensions = [(3, 4), (5, 6), (7, 8)]
areas = list(starmap(calculate_area, dimensions))  # [12, 30, 56]

# Processing coordinate pairs
points = [(1, 2), (3, 4), (5, 6)]
distances = list(starmap(lambda x, y: (x**2 + y**2)**0.5, points))
```

`tee()` creates independent iterators from a single source:

```python
from itertools import tee

original = iter(range(5))
iter1, iter2, iter3 = tee(original, 3)

# Each iterator can be consumed independently
list1 = list(iter1)  # [0, 1, 2, 3, 4]
list2 = list(iter2)  # [0, 1, 2, 3, 4]
list3 = list(iter3)  # [0, 1, 2, 3, 4]

# Useful for multiple passes without storing data
data = iter(range(1000000))
sum_iter, max_iter = tee(data, 2)
total = sum(sum_iter)
maximum = max(max_iter)
```

`zip_longest()` handles iterables of different lengths:

```python
from itertools import zip_longest

short = [1, 2, 3]
long = ['a', 'b', 'c', 'd', 'e']

# Default fill value (None)
paired = list(zip_longest(short, long))
# [(1,'a'), (2,'b'), (3,'c'), (None,'d'), (None,'e')]

# Custom fill value
paired_custom = list(zip_longest(short, long, fillvalue=0))
# [(1,'a'), (2,'b'), (3,'c'), (0,'d'), (0,'e')]

# Processing parallel data streams of different lengths
timestamps = [1, 2, 3, 4]
values = [10, 20, 30]
defaults = list(zip_longest(timestamps, values, fillvalue=-1))
```

**Performance Patterns:**

Combining itertools utilities creates memory-efficient pipelines:

```python
from itertools import islice, chain, groupby, accumulate

# Process large dataset in chunks with transformations
def process_large_file(filename):
    with open(filename) as f:
        # Chain multiple operations without intermediate lists
        lines = (line.strip() for line in f)
        non_empty = filter(None, lines)
        numeric = (int(line) for line in non_empty if line.isdigit())
        
        # Take first 1000, group by even/odd, accumulate sums
        first_thousand = islice(numeric, 1000)
        sorted_data = sorted(first_thousand, key=lambda x: x % 2)
        
        for parity, group in groupby(sorted_data, key=lambda x: x % 2):
            group_sum = sum(group)
            yield (parity, group_sum)

# Windowed iteration pattern
def windowed(iterable, n):
    """Generate sliding windows of size n"""
    iterators = tee(iterable, n)
    for i, it in enumerate(iterators):
        for _ in range(i):
            next(it, None)
    return zip(*iterators)

data = [1, 2, 3, 4, 5, 6]
windows = list(windowed(data, 3))
# [(1,2,3), (2,3,4), (3,4,5), (4,5,6)]
```

[Inference] Itertools utilities maintain O(1) memory complexity for most operations by leveraging lazy evaluation, making them suitable for processing large or infinite sequences. The actual memory usage depends on how the iterators are consumed and whether results are materialized into collections.

---

