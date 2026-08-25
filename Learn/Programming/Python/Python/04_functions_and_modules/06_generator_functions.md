## Generator Functions


Generator functions are functions that use the `yield` keyword to produce a sequence of values lazily (one at a time, on demand) rather than computing and returning them all at once.

```python
def simple_generator():
    yield 1
    yield 2
    yield 3

# Using the generator
gen = simple_generator()
print(next(gen))  # 1
print(next(gen))  # 2
print(next(gen))  # 3
```

Key characteristics:
- They maintain their state between calls
- Memory efficient for large sequences
- Values are computed only when requested
- Use `yield` to produce values

Practical example:
```python
def fibonacci(n):
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b

for num in fibonacci(10):
    print(num)  # 0, 1, 1, 2, 3, 5, 8, 13, 21, 34
```

