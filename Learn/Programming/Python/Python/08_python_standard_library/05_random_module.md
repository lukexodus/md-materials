## `random` Module


### Overview

The `random` module in Python provides functions for generating random numbers, selecting random elements, and performing various randomization operations. It implements pseudorandom number generators for different distributions and is essential for simulations, games, cryptography, testing, and statistical sampling.

### Importing the Module

```python
import random
from random import randint, choice, shuffle  # Import specific functions
```

### Basic Random Number Generation

#### random()

Generates a random float between 0.0 and 1.0 (exclusive of 1.0).

```python
import random
print(random.random())  # 0.37444887175646646
```

#### randint(a, b)

Returns a random integer between a and b (both inclusive).

```python
print(random.randint(1, 10))  # 7
print(random.randint(-5, 5))  # -2
```

#### randrange(start, stop, step)

Returns a random integer from the range, similar to range() function.

```python
print(random.randrange(10))      # 0 to 9
print(random.randrange(1, 11))   # 1 to 10
print(random.randrange(0, 101, 2))  # Even numbers 0 to 100
```

### Floating Point Random Numbers

#### uniform(a, b)

Returns a random float between a and b.

```python
print(random.uniform(1.5, 10.5))  # 6.234567891234567
```

#### triangular(low, high, mode)

Returns a random float with triangular distribution.

```python
print(random.triangular(0, 10, 5))  # Peaks at 5
```

### Sequence Operations

#### choice(seq)

Returns a random element from a non-empty sequence.

```python
colors = ['red', 'blue', 'green', 'yellow']
print(random.choice(colors))  # 'blue'

numbers = [1, 2, 3, 4, 5]
print(random.choice(numbers))  # 3
```

#### choices(population, weights, k)

Returns a list of k elements chosen from population with replacement.

```python
fruits = ['apple', 'banana', 'orange']
print(random.choices(fruits, k=3))  # ['banana', 'apple', 'banana']

# Weighted choices
print(random.choices(fruits, weights=[10, 1, 1], k=5))
# More likely to pick 'apple'
```

#### sample(population, k)

Returns a list of k unique elements from population without replacement.

```python
numbers = list(range(1, 11))
print(random.sample(numbers, 3))  # [7, 2, 9]

# For unique random integers
print(random.sample(range(100), 5))  # [23, 67, 89, 12, 45]
```

#### shuffle(x)

Shuffles the sequence x in place.

```python
deck = list(range(1, 53))
random.shuffle(deck)
print(deck[:5])  # [23, 7, 41, 2, 19]
```

### Statistical Distributions

#### Normal Distribution

```python
# Gaussian distribution
print(random.gauss(0, 1))      # Mean=0, Standard deviation=1
print(random.normalvariate(100, 15))  # Mean=100, SD=15
```

#### Exponential Distribution

```python
print(random.expovariate(1.5))  # Lambda=1.5
```

#### Gamma Distribution

```python
print(random.gammavariate(2, 3))  # Alpha=2, Beta=3
```

#### Beta Distribution

```python
print(random.betavariate(2, 5))  # Alpha=2, Beta=5
```

### Seeding and State Management

#### seed(x)

Initializes the random number generator with a seed value for reproducible results.

```python
random.seed(42)
print(random.random())  # 0.6394267984578837
print(random.random())  # 0.025010755222666936

# Reset with same seed
random.seed(42)
print(random.random())  # 0.6394267984578837 (same as before)
```

#### getstate() and setstate()

Save and restore the internal state of the random number generator.

```python
state = random.getstate()
print(random.random())  # 0.123456789

random.setstate(state)
print(random.random())  # 0.123456789 (same value)
```

### Advanced Usage Patterns

#### Creating Custom Random Generators

```python
# Create separate random instances
rng1 = random.Random(42)
rng2 = random.Random(123)

print(rng1.randint(1, 10))  # Independent from global random
print(rng2.randint(1, 10))  # Independent from both global and rng1
```

#### Weighted Random Selection

```python
def weighted_choice(choices, weights):
    total = sum(weights)
    r = random.uniform(0, total)
    upto = 0
    for choice, weight in zip(choices, weights):
        if upto + weight >= r:
            return choice
        upto += weight

items = ['A', 'B', 'C']
weights = [0.5, 0.3, 0.2]
print(weighted_choice(items, weights))
```

### Practical Applications

#### Password Generation

```python
import string

def generate_password(length=12):
    chars = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(random.choice(chars) for _ in range(length))

print(generate_password())  # "K3$mN9@pL4xZ"
```

#### Monte Carlo Simulation

```python
def estimate_pi(trials=1000000):
    inside_circle = 0
    for _ in range(trials):
        x, y = random.random(), random.random()
        if x*x + y*y <= 1:
            inside_circle += 1
    return 4 * inside_circle / trials

print(estimate_pi())  # Approximately 3.14159
```

#### Random Data Generation

```python
def generate_test_data(n=100):
    names = ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve']
    ages = list(range(18, 80))
    cities = ['New York', 'London', 'Tokyo', 'Paris', 'Sydney']
    
    data = []
    for _ in range(n):
        person = {
            'name': random.choice(names),
            'age': random.choice(ages),
            'city': random.choice(cities),
            'salary': random.uniform(30000, 150000)
        }
        data.append(person)
    return data
```

### Performance Considerations

#### Efficiency Tips

- Use `random.choices()` instead of multiple `random.choice()` calls
- For large samples without replacement, `random.sample()` is more efficient than manual selection
- Consider using `random.Random()` instances for thread safety
- Pre-generate random numbers for performance-critical applications

#### Memory Usage

```python
# Efficient for large ranges
random.randrange(1000000)  # Doesn't create the full range

# Less efficient
random.choice(range(1000000))  # Creates full range in memory
```

### Security Considerations

The `random` module is not cryptographically secure. For security-sensitive applications, use the `secrets` module instead:

```python
import secrets

# Cryptographically secure alternatives
secrets.randbelow(10)           # Instead of random.randrange(10)
secrets.choice(['a', 'b', 'c']) # Instead of random.choice()
secrets.token_hex(16)           # For secure tokens
```

### Common Pitfalls

#### Mutable Default Arguments

```python
# Wrong
def shuffle_list(lst=[]):
    random.shuffle(lst)
    return lst

# Correct
def shuffle_list(lst=None):
    if lst is None:
        lst = []
    random.shuffle(lst)
    return lst
```

#### Seeding in Loops

```python
# Wrong - reseeds every iteration
for i in range(10):
    random.seed(42)
    print(random.random())  # Always same value

# Correct - seed once
random.seed(42)
for i in range(10):
    print(random.random())  # Different values
```

### Testing with Random Data

#### Reproducible Tests

```python
import unittest

class TestRandomBehavior(unittest.TestCase):
    def setUp(self):
        random.seed(42)  # Ensure reproducible tests
    
    def test_random_choice(self):
        choices = [1, 2, 3, 4, 5]
        result = random.choice(choices)
        self.assertIn(result, choices)
```

#### Property-Based Testing

```python
def test_shuffle_preserves_elements():
    original = [1, 2, 3, 4, 5]
    shuffled = original.copy()
    random.shuffle(shuffled)
    assert sorted(shuffled) == sorted(original)
```

### Integration with Other Libraries

#### NumPy Integration

```python
import numpy as np

# NumPy has its own random module
np.random.seed(42)
arr = np.random.random(5)  # Array of random floats
```

#### Pandas Integration

```python
import pandas as pd

# Random sampling from DataFrames
df = pd.DataFrame({'A': range(100), 'B': range(100, 200)})
sample = df.sample(n=10)  # Random 10 rows
```

**Key points**: The random module is pseudorandom and deterministic when seeded, making it suitable for simulations and testing but not for cryptographic purposes. Understanding the difference between sampling with and without replacement is crucial for correct usage. The module provides both simple random selection and sophisticated statistical distributions for various applications.

---

