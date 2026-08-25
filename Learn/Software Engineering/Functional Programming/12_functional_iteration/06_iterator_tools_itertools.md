## Iterator tools (itertools)


The `itertools` module provides a collection of building blocks for creating efficient iterator pipelines. These tools enable complex functional operations while maintaining lazy evaluation.

**Infinite Iterators (covered separately in next section):**

- `count()`, `cycle()`, `repeat()`

**Finite Iterators:**

**`chain(*iterables)`** - Concatenates multiple iterables:

```python
from itertools import chain

list1 = [1, 2, 3]
list2 = [4, 5, 6]
list3 = [7, 8, 9]

result = chain(list1, list2, list3)
# Output: 1, 2, 3, 4, 5, 6, 7, 8, 9

# chain.from_iterable for nested structures
nested = [[1, 2], [3, 4], [5]]
flat = chain.from_iterable(nested)
# Output: 1, 2, 3, 4, 5
```

**`compress(data, selectors)`** - Filters elements based on selector truthiness:

```python
from itertools import compress

data = ['A', 'B', 'C', 'D', 'E']
selectors = [1, 0, 1, 0, 1]

result = compress(data, selectors)
# Output: 'A', 'C', 'E'
```

**`dropwhile(predicate, iterable)`** - Drops elements until predicate becomes false:

```python
from itertools import dropwhile

data = [1, 3, 5, 8, 10, 12, 7, 9]
result = dropwhile(lambda x: x < 6, data)
# Output: 8, 10, 12, 7, 9 (includes all after condition fails)
```

**`takewhile(predicate, iterable)`** - Takes elements while predicate is true:

```python
from itertools import takewhile

data = [1, 3, 5, 8, 10, 12]
result = takewhile(lambda x: x < 10, data)
# Output: 1, 3, 5, 8
```

**`filterfalse(predicate, iterable)`** - Opposite of filter():

```python
from itertools import filterfalse

data = range(10)
result = filterfalse(lambda x: x % 2 == 0, data)
# Output: 1, 3, 5, 7, 9 (odd numbers)
```

**`islice(iterable, start, stop, step)`** - Slice iterator:

```python
from itertools import islice

data = range(100)
result = islice(data, 10, 20, 2)
# Output: 10, 12, 14, 16, 18

# Get first n elements
first_five = islice(range(1000), 5)
# Output: 0, 1, 2, 3, 4
```

**`accumulate(iterable, func=operator.add)`** - Running accumulation:

```python
from itertools import accumulate
import operator

data = [1, 2, 3, 4, 5]
result = accumulate(data)
# Output: 1, 3, 6, 10, 15 (running sum)

# Custom function
result = accumulate(data, operator.mul)
# Output: 1, 2, 6, 24, 120 (running product)

# Max accumulation
result = accumulate([5, 2, 9, 1, 7], max)
# Output: 5, 5, 9, 9, 9
```

**`starmap(func, iterable)`** - Applies function to unpacked tuples:

```python
from itertools import starmap

pairs = [(2, 3), (4, 5), (6, 7)]
result = starmap(pow, pairs)
# Output: 8, 1024, 279936 (2^3, 4^5, 6^7)
```

**`groupby(iterable, key=None)`** - Groups consecutive elements:

```python
from itertools import groupby

data = [('A', 1), ('A', 2), ('B', 3), ('B', 4), ('A', 5)]
grouped = groupby(data, key=lambda x: x[0])

for key, group in grouped:
    print(f"{key}: {list(group)}")
# Output:
# A: [('A', 1), ('A', 2)]
# B: [('B', 3), ('B', 4)]
# A: [('A', 5)]
```

**`tee(iterable, n=2)`** - Creates independent iterators from one:

```python
from itertools import tee

data = range(5)
iter1, iter2 = tee(data)

# Both can be consumed independently
list(iter1)  # [0, 1, 2, 3, 4]
list(iter2)  # [0, 1, 2, 3, 4]
```

**`zip_longest(*iterables, fillvalue=None)`** - Zips until longest exhausted:

```python
from itertools import zip_longest

list1 = [1, 2, 3]
list2 = ['a', 'b', 'c', 'd', 'e']

result = zip_longest(list1, list2, fillvalue=0)
# Output: (1, 'a'), (2, 'b'), (3, 'c'), (0, 'd'), (0, 'e')
```

**Pipeline Composition:**

Combining multiple itertools creates powerful functional pipelines:

```python
from itertools import chain, islice, accumulate, filterfalse

def process_data(datasets):
    # Chain multiple datasets
    combined = chain.from_iterable(datasets)
    
    # Filter out invalid values
    valid = filterfalse(lambda x: x < 0, combined)
    
    # Get running totals
    running_total = accumulate(valid)
    
    # Take first 100
    result = islice(running_total, 100)
    
    return list(result)
```

