## Pipe Operator Concept


The pipe operator inverts the order of function composition, applying functions left-to-right in the order they appear. This matches the natural reading direction and makes data transformation pipelines more intuitive.

### Left-to-Right Flow

While traditional composition reads `f(g(x))` right-to-left, piping reads `x |> g |> f` left-to-right:

```python
def pipe(*functions):
    def piped(x):
        result = x
        for func in functions:
            result = func(result)
        return result
    return piped

def add_one(x):
    return x + 1

def double(x):
    return x * 2

def square(x):
    return x ** 2

# Pipe left-to-right
transform = pipe(add_one, double, square)
print(transform(3))  # ((3 + 1) * 2) ** 2 = 64
```

**Output:**

```
64
```

### Comparison with Composition

```python
from functools import reduce

def compose(*functions):
    def composed(x):
        return reduce(lambda acc, f: f(acc), reversed(functions), x)
    return composed

def pipe(*functions):
    def piped(x):
        return reduce(lambda acc, f: f(acc), functions, x)
    return piped

# Same functions, different order
increment = lambda x: x + 1
triple = lambda x: x * 3

# Composition: right-to-left
comp = compose(triple, increment)
print(f"Compose: {comp(5)}")  # (5 + 1) * 3 = 18

# Pipe: left-to-right
piped = pipe(increment, triple)
print(f"Pipe: {piped(5)}")    # (5 + 1) * 3 = 18
```

**Output:**

```
Compose: 18
Pipe: 18
```

### Functional Piping with reduce

Direct implementation using reduce without wrapper:

```python
from functools import reduce

def pipe(data, *functions):
    return reduce(lambda acc, f: f(acc), functions, data)

numbers = [1, 2, 3, 4, 5]

result = pipe(
    numbers,
    lambda xs: [x * 2 for x in xs],      # Double each
    lambda xs: [x for x in xs if x > 4],  # Filter > 4
    sum                                    # Sum remaining
)

print(result)
```

**Output:**

```
24
```

### Practical Data Pipeline

```python
def pipe(*functions):
    def piped(data):
        return reduce(lambda acc, f: f(acc), functions, data)
    return piped

# Text processing pipeline
def split_lines(text):
    return text.split('\n')

def remove_empty(lines):
    return [line for line in lines if line.strip()]

def strip_lines(lines):
    return [line.strip() for line in lines]

def to_uppercase(lines):
    return [line.upper() for line in lines]

def join_lines(lines):
    return ' | '.join(lines)

# Create pipeline
process_text = pipe(
    split_lines,
    remove_empty,
    strip_lines,
    to_uppercase,
    join_lines
)

text = """
hello world
  
how are you
  
goodbye
"""

print(process_text(text))
```

**Output:**

```
HELLO WORLD | HOW ARE YOU | GOODBYE
```

### Method-Style Piping

Creating a chainable pipe object:

```python
class Pipe:
    def __init__(self, value):
        self.value = value
    
    def pipe(self, func):
        return Pipe(func(self.value))
    
    def get(self):
        return self.value

# Usage
result = (Pipe(5)
    .pipe(lambda x: x + 1)
    .pipe(lambda x: x * 2)
    .pipe(lambda x: x ** 2)
    .get())

print(result)
```

**Output:**

```
144
```

### Pipeline with Error Handling

```python
def pipe_safe(*functions):
    def piped(data):
        result = data
        for i, func in enumerate(functions):
            try:
                result = func(result)
            except Exception as e:
                raise ValueError(f"Error in pipeline stage {i} ({func.__name__}): {e}")
        return result
    return piped

def parse_int(s):
    return int(s)

def double(x):
    return x * 2

def format_result(x):
    return f"Result: {x}"

safe_pipeline = pipe_safe(parse_int, double, format_result)

print(safe_pipeline("42"))
# safe_pipeline("not a number")  # Would raise: Error in pipeline stage 0
```

**Output:**

```
Result: 84
```

### Async Pipeline

Handling asynchronous functions in a pipe:

```python
import asyncio

async def async_pipe(data, *functions):
    result = data
    for func in functions:
        if asyncio.iscoroutinefunction(func):
            result = await func(result)
        else:
            result = func(result)
    return result

async def fetch_data(url):
    await asyncio.sleep(0.1)  # Simulate network call
    return f"Data from {url}"

async def process_data(data):
    await asyncio.sleep(0.1)  # Simulate processing
    return data.upper()

def add_timestamp(data):
    import time
    return f"{data} at {time.time():.0f}"

# Run async pipeline
async def main():
    result = await async_pipe(
        "https://api.example.com",
        fetch_data,
        process_data,
        add_timestamp
    )
    print(result)

# asyncio.run(main())
```

### Debugging Pipelines

Adding inspection between stages:

```python
def pipe_debug(*functions):
    def piped(data):
        result = data
        print(f"Initial: {result}")
        for i, func in enumerate(functions):
            result = func(result)
            print(f"After {func.__name__} (stage {i+1}): {result}")
        return result
    return piped

process = pipe_debug(
    lambda x: x + 5,
    lambda x: x * 2,
    lambda x: x - 3
)

result = process(10)
```

**Output:**

```
Initial: 10
After <lambda> (stage 1): 15
After <lambda> (stage 2): 30
After <lambda> (stage 3): 27
```

### Conditional Piping

Applying functions conditionally within a pipeline:

```python
def pipe(*functions):
    def piped(data):
        return reduce(lambda acc, f: f(acc), functions, data)
    return piped

def when(condition, func):
    def conditional(x):
        return func(x) if condition(x) else x
    return conditional

pipeline = pipe(
    lambda x: x + 1,
    when(lambda x: x > 10, lambda x: x * 2),  # Only double if > 10
    lambda x: x ** 2
)

print(pipeline(5))   # (5 + 1) ** 2 = 36
print(pipeline(12))  # ((12 + 1) * 2) ** 2 = 676
```

**Output:**

```
36
676
```

### Parallel Pipeline Branching

Creating multiple pipelines from the same input:

```python
def branch(*pipelines):
    def branched(data):
        return [pipe(data) for pipe in pipelines]
    return branched

def pipe(*functions):
    def piped(data):
        return reduce(lambda acc, f: f(acc), functions, data)
    return piped

# Define different processing paths
path_a = pipe(lambda x: x * 2, lambda x: x + 10)
path_b = pipe(lambda x: x ** 2, lambda x: x - 5)
path_c = pipe(lambda x: x + 1, lambda x: x * 3)

# Branch into multiple paths
process = branch(path_a, path_b, path_c)
results = process(5)
print(results)
```

**Output:**

```
[20, 20, 18]
```

**Key Points:**

- Pipe operators apply functions left-to-right, matching natural reading order
- More intuitive for data transformation workflows than right-to-left composition
- Can be implemented as higher-order functions or chainable objects
- Particularly effective for ETL (Extract, Transform, Load) operations
- Works well with debugging and inspection since stages are sequential
- Can be extended with error handling, async support, and conditional logic
- Improves code readability by making data flow explicit

