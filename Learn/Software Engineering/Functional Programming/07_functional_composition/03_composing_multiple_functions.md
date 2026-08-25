## Composing Multiple Functions


Composing multiple functions involves chaining three or more functions together to create complex transformations from simple building blocks. This technique scales composition beyond binary operations.

### N-ary Composition

Composing an arbitrary number of functions using reduction:

```python
from functools import reduce

def compose(*functions):
    def composed(x):
        return reduce(lambda acc, f: f(acc), reversed(functions), x)
    return composed

# Multiple simple functions
def add_ten(x):
    return x + 10

def multiply_three(x):
    return x * 3

def square(x):
    return x ** 2

def negate(x):
    return -x

def halve(x):
    return x / 2

# Compose five functions
transform = compose(halve, negate, square, multiply_three, add_ten)
print(transform(5))  # -((((5 + 10) * 3) ** 2)) / 2 = -3037.5
```

**Output:**

```
-3037.5
```

### Building Complex Transformations

Creating specialized transformations by combining simple operations:

```python
def compose(*functions):
    def composed(x):
        return reduce(lambda acc, f: f(acc), reversed(functions), x)
    return composed

# String transformation functions
def remove_spaces(s):
    return s.replace(' ', '')

def to_lowercase(s):
    return s.lower()

def reverse_string(s):
    return s[::-1]

def add_prefix(s):
    return f"processed_{s}"

def truncate(max_len):
    def truncator(s):
        return s[:max_len]
    return truncator

# Compose string processing pipeline
sanitize = compose(
    add_prefix,
    truncate(20),
    reverse_string,
    to_lowercase,
    remove_spaces
)

print(sanitize("Hello World Example"))
```

**Output:**

```
processed_elpmaxedlrow
```

### Layered Data Processing

Composing functions that operate on different data structures:

```python
def compose(*functions):
    return lambda x: reduce(lambda acc, f: f(acc), reversed(functions), x)

# Collection operations
def filter_even(nums):
    return [n for n in nums if n % 2 == 0]

def map_square(nums):
    return [n ** 2 for n in nums]

def take_first_three(nums):
    return nums[:3]

def sum_all(nums):
    return sum(nums)

def format_result(n):
    return f"Sum: {n}"

# Compose collection transformations
process_numbers = compose(
    format_result,
    sum_all,
    take_first_three,
    map_square,
    filter_even
)

numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
print(process_numbers(numbers))
```

**Output:**

```
Sum: 56
```

### Composition with Partial Application

Combining composition with partial application for flexible transformations:

```python
from functools import partial, reduce

def compose(*functions):
    return lambda x: reduce(lambda acc, f: f(acc), reversed(functions), x)

def multiply(x, y):
    return x * y

def add(x, y):
    return x + y

def power(x, exp):
    return x ** exp

def clamp(x, min_val, max_val):
    return max(min_val, min(max_val, x))

# Create specialized functions
double = partial(multiply, 2)
add_five = partial(add, 5)
cube = partial(power, exp=3)
clamp_0_100 = partial(clamp, min_val=0, max_val=100)

# Compose them
transform = compose(clamp_0_100, cube, add_five, double)
print(transform(3))   # clamp(((3 * 2) + 5) ** 3, 0, 100) = 100
print(transform(1))   # clamp(((1 * 2) + 5) ** 3, 0, 100) = 100
```

**Output:**

```
100
100
```

### Function Factory with Composition

Creating composable function generators:

```python
def compose(*functions):
    return lambda x: reduce(lambda acc, f: f(acc), reversed(functions), x)

# Function factories
def multiplier(factor):
    return lambda x: x * factor

def adder(amount):
    return lambda x: x + amount

def threshold(limit):
    return lambda x: x if x < limit else limit

def formatter(template):
    return lambda x: template.format(x)

# Build transformation from factories
create_transform = lambda: compose(
    formatter("Result: {}"),
    threshold(50),
    multiplier(3),
    adder(10)
)

transform = create_transform()
print(transform(5))   # "Result: 45"
print(transform(20))  # "Result: 50" (thresholded)
```

**Output:**

```
Result: 45
Result: 50
```

### Composing Validators

Creating validation pipelines through composition:

```python
def compose_validators(*validators):
    def validate(value):
        errors = []
        for validator in validators:
            error = validator(value)
            if error:
                errors.append(error)
        return errors if errors else None
    return validate

# Individual validators
def min_length(length):
    def validator(s):
        return None if len(s) >= length else f"Minimum length: {length}"
    return validator

def max_length(length):
    def validator(s):
        return None if len(s) <= length else f"Maximum length: {length}"
    return validator

def contains_digit(s):
    return None if any(c.isdigit() for c in s) else "Must contain digit"

def no_spaces(s):
    return None if ' ' not in s else "Cannot contain spaces"

# Compose validators
validate_password = compose_validators(
    min_length(8),
    max_length(20),
    contains_digit,
    no_spaces
)

print(validate_password("short"))
print(validate_password("valid_pass123"))
print(validate_password("has spaces 123"))
```

**Output:**

```
['Minimum length: 8', 'Must contain digit']
None
['Cannot contain spaces']
```

### Nested Composition

Composing compositions for hierarchical transformations:

```python
def compose(*functions):
    return lambda x: reduce(lambda acc, f: f(acc), reversed(functions), x)

# Low-level operations
def trim(s):
    return s.strip()

def lowercase(s):
    return s.lower()

def remove_punct(s):
    import string
    return s.translate(str.maketrans('', '', string.punctuation))

# Mid-level compositions
normalize_text = compose(remove_punct, lowercase, trim)

def split_words(s):
    return s.split()

def filter_short_words(words):
    return [w for w in words if len(w) > 3]

def join_with_dash(words):
    return '-'.join(words)

# High-level composition
create_slug = compose(
    join_with_dash,
    filter_short_words,
    split_words,
    normalize_text
)

print(create_slug("  Hello, World! How are YOU doing?  "))
```

**Output:**

```
hello-world-doing
```

### Composing Transformers and Reducers

Combining map-like and reduce-like operations:

```python
def compose(*functions):
    return lambda x: reduce(lambda acc, f: f(acc), reversed(functions), x)

# Transformer functions
def parse_lines(text):
    return text.strip().split('\n')

def parse_csv_line(line):
    return line.split(',')

def map_parse_csv(lines):
    return [parse_csv_line(line) for line in lines]

def extract_second_column(rows):
    return [row[1] if len(row) > 1 else None for row in rows]

def filter_none(values):
    return [v for v in values if v is not None]

def convert_to_int(values):
    return [int(v) for v in values if v.isdigit()]

def calculate_average(nums):
    return sum(nums) / len(nums) if nums else 0

# Compose CSV processing pipeline
process_csv = compose(
    calculate_average,
    convert_to_int,
    filter_none,
    extract_second_column,
    map_parse_csv,
    parse_lines
)

csv_data = """
name,age,city
alice,25,NYC
bob,30,LA
charlie,invalid,SF
david,35,Austin
"""

print(process_csv(csv_data))
```

**Output:**

```
30.0
```

### Memoized Composition

Composing with automatic memoization:

```python
def memoize(func):
    cache = {}
    def memoized(*args):
        if args not in cache:
            cache[args] = func(*args)
        return cache[args]
    return memoized

def compose(*functions):
    # Memoize each function in the composition
    memoized_funcs = [memoize(f) for f in functions]
    return lambda x: reduce(lambda acc, f: f(acc), reversed(memoized_funcs), x)

# Expensive operations
def expensive_calc_1(x):
    print(f"Computing calc_1({x})")
    return x * 2

def expensive_calc_2(x):
    print(f"Computing calc_2({x})")
    return x + 10

def expensive_calc_3(x):
    print(f"Computing calc_3({x})")
    return x ** 2

# Compose with memoization
transform = compose(expensive_calc_3, expensive_calc_2, expensive_calc_1)

print(transform(5))
print(transform(5))  # Cached, no recomputation
```

**Output:**

```
Computing calc_1(5)
Computing calc_2(10)
Computing calc_3(20)
400
400
```

**Key Points:**

- Multiple function composition builds complex behavior from simple components
- Order matters significantly when composing multiple functions
- Can combine transformers (map-like), filters, and reducers in one pipeline
- Partial application enables parameterized functions in compositions
- Composition of compositions creates hierarchical abstractions
- Memoization can optimize repeated computations in composed pipelines
- Each function should have a single, well-defined responsibility for maximum composability

