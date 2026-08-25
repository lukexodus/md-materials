## Accumulate Function


Accumulate produces running totals or cumulative results by applying a binary function across an iterator, yielding intermediate values at each step. This generalizes prefix sum computation to arbitrary associative operations.

**Function Signature and Behavior**

```python
from itertools import accumulate
import operator

# Default: cumulative sum
list(accumulate([1, 2, 3, 4, 5]))
# [1, 3, 6, 10, 15]

# Custom binary function
list(accumulate([1, 2, 3, 4, 5], operator.mul))
# [1, 2, 6, 24, 120]  # Factorial-like sequence
```

The function signature is `accumulate(iterable, func=operator.add, *, initial=None)`. The func parameter must accept two arguments and return a single value that can be used as the left operand in subsequent calls.

**Initial Value Semantics**

The optional `initial` parameter provides a starting accumulator value, emitted before processing any input elements:

```python
list(accumulate([1, 2, 3], initial=100))
# [100, 101, 103, 106]

# Useful for operations requiring identity elements
list(accumulate([2, 3, 4], operator.mul, initial=1))
# [1, 2, 6, 24]
```

**Advanced Operations**

Accumulate enables sophisticated sequential computations:

```python
# Running maximum
data = [3, 1, 4, 1, 5, 9, 2, 6]
list(accumulate(data, max))
# [3, 3, 4, 4, 5, 9, 9, 9]

# Running minimum
list(accumulate(data, min))
# [3, 1, 1, 1, 1, 1, 1, 1]

# Custom accumulator: track count and sum simultaneously
def track_stats(acc, x):
    count, total = acc
    return (count + 1, total + x)

list(accumulate([10, 20, 30], track_stats, initial=(0, 0)))
# [(0, 0), (1, 10), (2, 30), (3, 60)]
```

**Stateful Accumulation**

Use accumulate for computations requiring memory of previous states:

```python
# Fibonacci sequence using accumulate
def fib_step(state, _):
    a, b = state
    return (b, a + b)

fib_states = accumulate(range(10), fib_step, initial=(0, 1))
fibs = (a for a, b in fib_states)
list(fibs)
# [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55]
```

**Performance Considerations**

Accumulate operates in O(n) time with O(1) additional space for the accumulator state. It's lazy and yields values incrementally, making it suitable for infinite sequences:

```python
# Infinite accumulation
from itertools import count, islice

powers_of_2 = accumulate(count(), lambda x, _: x * 2, initial=1)
list(islice(powers_of_2, 10))
# [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]
```

**Practical Applications**

- **Financial computations**: Running balances, compound interest
- **Data analysis**: Cumulative distributions, moving windows
- **State machines**: Sequential state transitions
- **Signal processing**: Integration, running statistics

```python
# Calculate running average
def running_avg_step(state, x):
    count, total = state
    new_count = count + 1
    new_total = total + x
    return (new_count, new_total)

data = [10, 20, 30, 40]
states = accumulate(data, running_avg_step, initial=(0, 0))
averages = (total / count for count, total in states if count > 0)
list(averages)
# [10.0, 15.0, 20.0, 25.0]
```

