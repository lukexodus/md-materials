## Groupby Function


Groupby partitions a sorted iterator into consecutive groups based on a key function, yielding (key, group_iterator) pairs. This enables efficient aggregation and analysis of structured sequential data without materializing intermediate collections.

**Core Requirements and Behavior**

Groupby requires pre-sorted input with respect to the grouping key. It only groups consecutive elements with identical keys, not all elements globally:

```python
from itertools import groupby

# INCORRECT: unsorted data
data = [1, 2, 1, 3, 2]
for key, group in groupby(data):
    print(key, list(group))
# Output: 1 [1]
#         2 [2]
#         1 [1]  # New group! Not merged with first
#         3 [3]
#         2 [2]

# CORRECT: sorted first
sorted_data = sorted(data)  # [1, 1, 2, 2, 3]
for key, group in groupby(sorted_data):
    print(key, list(group))
# Output: 1 [1, 1]
#         2 [2, 2]
#         3 [3]
```

**Key Function Semantics**

The key function extracts the grouping criterion from each element. If omitted, groupby uses the identity function:

```python
# Grouping with key function
words = ['apple', 'apricot', 'banana', 'berry', 'cherry']
sorted_words = sorted(words, key=lambda w: w[0])

for letter, group in groupby(sorted_words, key=lambda w: w[0]):
    print(f"{letter}: {list(group)}")
# a: ['apple', 'apricot']
# b: ['banana', 'berry']
# c: ['cherry']
```

**Critical Iterator Consumption Pattern**

Group iterators share state with the parent groupby iterator. Advancing the parent invalidates previous groups:

```python
data = sorted([1, 1, 2, 2, 3, 3])
groups = groupby(data)

key1, group1 = next(groups)
key2, group2 = next(groups)  # Invalidates group1!

# group1 is now exhausted
list(group1)  # []
list(group2)  # [2, 2]
```

**Safe Materialization Strategy**

Always materialize groups immediately if you need to retain them:

```python
data = sorted([1, 1, 2, 2, 3, 3])
grouped = {key: list(group) for key, group in groupby(data)}
# {1: [1, 1], 2: [2, 2], 3: [3, 3]}
```

**Complex Aggregations**

Groupby excels at computing group-level statistics:

```python
from operator import itemgetter

# Student grades by subject
grades = [
    ('Math', 85), ('Math', 92), ('Math', 78),
    ('English', 88), ('English', 91),
    ('Science', 95), ('Science', 87), ('Science', 90)
]

sorted_grades = sorted(grades, key=itemgetter(0))

for subject, group in groupby(sorted_grades, key=itemgetter(0)):
    scores = [score for _, score in group]
    avg = sum(scores) / len(scores)
    print(f"{subject}: avg={avg:.1f}, count={len(scores)}")
# Math: avg=85.0, count=3
# English: avg=89.5, count=2
# Science: avg=90.7, count=3
```

**Multi-Level Grouping**

Compose key functions for hierarchical grouping:

```python
# Group by multiple criteria
records = [
    {'dept': 'Sales', 'year': 2023, 'amount': 100},
    {'dept': 'Sales', 'year': 2023, 'amount': 150},
    {'dept': 'Sales', 'year': 2024, 'amount': 200},
    {'dept': 'IT', 'year': 2023, 'amount': 120},
    {'dept': 'IT', 'year': 2024, 'amount': 180},
]

# Sort by dept then year
sorted_records = sorted(records, key=lambda r: (r['dept'], r['year']))

# Group by department
for dept, dept_group in groupby(sorted_records, key=lambda r: r['dept']):
    print(f"\n{dept}:")
    # Group by year within department
    dept_list = list(dept_group)
    for year, year_group in groupby(dept_list, key=lambda r: r['year']):
        total = sum(r['amount'] for r in year_group)
        print(f"  {year}: ${total}")
```

**Performance Characteristics**

Groupby operates in O(n) time with O(1) space overhead for the grouping mechanism itself (excluding materialized groups). The pre-sorting requirement adds O(n log n) time complexity to the overall operation.

**Pattern: Run-Length Encoding**

```python
def run_length_encode(iterable):
    return ((key, sum(1 for _ in group)) 
            for key, group in groupby(iterable))

encoded = list(run_length_encode('aaabbccccaa'))
# [('a', 3), ('b', 2), ('c', 4), ('a', 2)]
```

**Pattern: Deduplicate Consecutive**

```python
def deduplicate_consecutive(iterable):
    return (key for key, _ in groupby(iterable))

list(deduplicate_consecutive([1, 1, 2, 2, 3, 1, 1]))
# [1, 2, 3, 1]
```

**Working with Unsorted Data**

If maintaining original order is critical and sorting would disrupt it, consider alternative approaches:

```python
from collections import defaultdict

# Preserve order while grouping (not using groupby)
def group_preserve_order(iterable, key_func):
    groups = defaultdict(list)
    keys_seen = []
    
    for item in iterable:
        key = key_func(item)
        if key not in groups:
            keys_seen.append(key)
        groups[key].append(item)
    
    return [(key, groups[key]) for key in keys_seen]
```

[Inference] This last alternative pattern doesn't use `groupby` but solves the unsorted grouping problem that `groupby` cannot handle directly due to its consecutive-elements-only design.

---

