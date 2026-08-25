## Iterator Chaining


Iterator chaining combines multiple iterators into a single sequential stream, processing elements from the first iterator until exhausted, then moving to the next. This technique enables compositional data processing without creating intermediate collections.

**Core Mechanism**

Chaining creates a lazy evaluation pipeline where each iterator is consumed only when needed. The chain maintains references to all source iterators and yields elements sequentially, preserving memory efficiency even with large or infinite sequences.

```python
from itertools import chain

# Chaining multiple iterables
numbers = chain([1, 2, 3], [4, 5], [6, 7, 8])
# Yields: 1, 2, 3, 4, 5, 6, 7, 8

# Chaining with chain.from_iterable for nested structures
nested = [[1, 2], [3, 4], [5]]
flat = chain.from_iterable(nested)
# Yields: 1, 2, 3, 4, 5
```

**Advanced Patterns**

Chaining enables heterogeneous data source composition without type constraints. You can chain generators, lists, ranges, and custom iterators transparently:

```python
def custom_generator():
    yield from range(10, 13)

combined = chain(
    range(5),
    custom_generator(),
    filter(lambda x: x % 2 == 0, [20, 21, 22, 23])
)
# Yields: 0, 1, 2, 3, 4, 10, 11, 12, 20, 22
```

**Performance Characteristics**

Chain operations execute in O(1) setup time with O(n) iteration cost, where n is the total number of elements across all iterators. Memory usage remains constant regardless of source iterator sizes, as chain never materializes the full sequence.

**Practical Applications**

Use iterator chaining for:

- Merging multiple data streams from different sources
- Appending headers/footers to data sequences
- Combining filtered subsets without intermediate storage
- Building complex pipelines from simple iterator components

```python
# Processing multiple log files sequentially
import gzip

def process_logs(file_paths):
    log_lines = chain.from_iterable(
        gzip.open(path, 'rt') for path in file_paths
    )
    return (line.strip() for line in log_lines if 'ERROR' in line)
```

