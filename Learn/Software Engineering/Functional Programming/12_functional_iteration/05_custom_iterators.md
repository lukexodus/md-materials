## Custom iterators


Custom iterators in functional programming allow you to create objects that produce sequences of values on demand, implementing lazy evaluation principles. In Python, this is achieved by implementing the iterator protocol: defining `__iter__()` and `__next__()` methods.

**Basic Structure:**

```python
class CustomIterator:
    def __init__(self, data):
        self.data = data
        self.index = 0
    
    def __iter__(self):
        return self
    
    def __next__(self):
        if self.index >= len(self.data):
            raise StopIteration
        result = self.data[self.index]
        self.index += 1
        return result
```

**Generator Functions as Iterators:**

Generator functions provide a more concise way to create iterators using `yield`:

```python
def fibonacci_gen(n):
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b

# Usage
for num in fibonacci_gen(10):
    print(num)
```

**Stateful Custom Iterators:**

Custom iterators can maintain complex internal state, enabling sophisticated iteration patterns:

```python
class RangeWithStep:
    def __init__(self, start, end, step_func):
        self.current = start
        self.end = end
        self.step_func = step_func
    
    def __iter__(self):
        return self
    
    def __next__(self):
        if self.current >= self.end:
            raise StopIteration
        result = self.current
        self.current = self.step_func(self.current)
        return result

# Exponential steps
exp_range = RangeWithStep(1, 1000, lambda x: x * 2)
# Output: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512
```

**Filtering Iterators:**

Custom iterators can implement filtering logic directly in the iteration process:

```python
class FilteredIterator:
    def __init__(self, iterable, predicate):
        self.iterator = iter(iterable)
        self.predicate = predicate
    
    def __iter__(self):
        return self
    
    def __next__(self):
        while True:
            value = next(self.iterator)
            if self.predicate(value):
                return value

# Usage
evens = FilteredIterator(range(20), lambda x: x % 2 == 0)
```

**Transform Iterators:**

Iterators that apply transformations lazily:

```python
class MappingIterator:
    def __init__(self, iterable, func):
        self.iterator = iter(iterable)
        self.func = func
    
    def __iter__(self):
        return self
    
    def __next__(self):
        return self.func(next(self.iterator))

# Chain transformations
squared = MappingIterator(range(5), lambda x: x ** 2)
doubled = MappingIterator(squared, lambda x: x * 2)
# Output: 0, 2, 8, 18, 32
```

**Sentinel-based Iterators:**

Using sentinels for conditional termination:

```python
def read_until_sentinel(data_source, sentinel):
    return iter(lambda: next(data_source), sentinel)

# Example
data = iter([1, 2, 3, -1, 4, 5])
values = read_until_sentinel(data, -1)
# Output: 1, 2, 3 (stops at sentinel -1)
```

