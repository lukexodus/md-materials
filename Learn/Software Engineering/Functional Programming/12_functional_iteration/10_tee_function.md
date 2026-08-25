## Tee Function


The tee function creates independent iterators from a single input iterator, allowing multiple passes over the same data stream without re-computation or full materialization. This solves the fundamental problem that iterators are single-use by default.

**Operational Behavior**

Tee returns n independent iterators that share an internal cache. As iterators advance at different rates, tee stores values that have been consumed by some iterators but not others. This buffering mechanism enables divergent iteration speeds while maintaining consistency.

```python
from itertools import tee

data = iter([1, 2, 3, 4, 5])
iter1, iter2 = tee(data, 2)

# Independent consumption
list(iter1)  # [1, 2, 3, 4, 5]
list(iter2)  # [1, 2, 3, 4, 5]
```

**Memory Implications**

The memory footprint of tee depends on iterator divergence. If one iterator advances significantly ahead of others, tee must buffer all intermediate values. Maximum memory usage is O(k × d) where k is the number of teed iterators and d is the maximum divergence distance.

```python
it1, it2 = tee(range(1000000))

# Divergent consumption pattern - high memory usage
for _ in range(500000):
    next(it1)  # it1 far ahead

# Now it2 iteration requires buffering 500k elements
```

**Best Practices**

Tee works optimally when:

- Iterators progress at similar rates
- The number of teed copies is small (typically 2-3)
- You need to perform multiple passes with different operations

Avoid tee when:

- Large divergence between iterator positions is expected
- Original data can be materialized cheaply (use `list()` instead)
- Only one iterator will be fully consumed

**Pattern: Lookahead and Current**

A common pattern uses tee to examine current and next elements simultaneously:

```python
def pairwise(iterable):
    a, b = tee(iterable)
    next(b, None)  # Advance b by one
    return zip(a, b)

# Generate consecutive pairs
list(pairwise([1, 2, 3, 4, 5]))
# [(1, 2), (2, 3), (3, 4), (4, 5)]
```

**Pattern: Multiple Transformations**

Apply different operations to the same data stream without recomputation:

```python
numbers = iter(range(1, 100))
it1, it2, it3 = tee(numbers, 3)

squares = (x**2 for x in it1)
evens = (x for x in it2 if x % 2 == 0)
running_sum = accumulate(it3)
```

