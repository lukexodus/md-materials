## Combinatoric iterators


Combinatoric iterators generate mathematical combinations, permutations, and Cartesian products efficiently without materializing all possibilities in memory.

**`product(*iterables, repeat=1)`** - Cartesian product:

```python
from itertools import product

# Basic product
colors = ['red', 'blue']
sizes = ['S', 'M', 'L']
result = product(colors, sizes)
# Output: ('red', 'S'), ('red', 'M'), ('red', 'L'), 
#         ('blue', 'S'), ('blue', 'M'), ('blue', 'L')

# With repeat parameter
dice_rolls = list(product(range(1, 7), repeat=2))
# Output: All 36 combinations of two dice rolls
# (1,1), (1,2), ..., (6,6)

# Multiple iterables
letters = ['A', 'B']
numbers = [1, 2]
symbols = ['!', '?']
result = list(product(letters, numbers, symbols))
# Output: 8 combinations total
# ('A', 1, '!'), ('A', 1, '?'), ('A', 2, '!'), ('A', 2, '?'),
# ('B', 1, '!'), ('B', 1, '?'), ('B', 2, '!'), ('B', 2, '?')

# Practical: generate all coordinates
grid = list(product(range(3), range(3)))
# Output: (0,0), (0,1), (0,2), (1,0), (1,1), (1,2), (2,0), (2,1), (2,2)
```

**`permutations(iterable, r=None)`** - All r-length permutations:

```python
from itertools import permutations

# Full permutations
items = ['A', 'B', 'C']
result = list(permutations(items))
# Output: ('A', 'B', 'C'), ('A', 'C', 'B'), ('B', 'A', 'C'),
#         ('B', 'C', 'A'), ('C', 'A', 'B'), ('C', 'B', 'A')

# Partial permutations
result = list(permutations(items, 2))
# Output: ('A', 'B'), ('A', 'C'), ('B', 'A'), ('B', 'C'), ('C', 'A'), ('C', 'B')

# Order matters (unlike combinations)
numbers = [1, 2, 3]
two_number_perms = list(permutations(numbers, 2))
# Output: (1, 2), (1, 3), (2, 1), (2, 3), (3, 1), (3, 2)

# Practical: password generation patterns
chars = 'ABC'
patterns = [''.join(p) for p in permutations(chars, 2)]
# Output: ['AB', 'AC', 'BA', 'BC', 'CA', 'CB']
```

**`combinations(iterable, r)`** - r-length combinations without replacement:

```python
from itertools import combinations

# Basic combinations
items = ['A', 'B', 'C', 'D']
result = list(combinations(items, 2))
# Output: ('A', 'B'), ('A', 'C'), ('A', 'D'), ('B', 'C'), ('B', 'D'), ('C', 'D')

# Three-element combinations
numbers = [1, 2, 3, 4]
result = list(combinations(numbers, 3))
# Output: (1, 2, 3), (1, 2, 4), (1, 3, 4), (2, 3, 4)

# All possible subsets (using chain)
from itertools import chain
def all_subsets(items):
    return chain.from_iterable(
        combinations(items, r) for r in range(len(items) + 1)
    )

subsets = list(all_subsets([1, 2, 3]))
# Output: (), (1,), (2,), (3,), (1, 2), (1, 3), (2, 3), (1, 2, 3)

# Practical: team selection
players = ['Alice', 'Bob', 'Charlie', 'David', 'Eve']
teams = list(combinations(players, 3))
# Output: All possible 3-player teams (10 combinations)
```

**`combinations_with_replacement(iterable, r)`** - Combinations with repetition:

```python
from itertools import combinations_with_replacement

# Allow repeated elements
items = ['A', 'B', 'C']
result = list(combinations_with_replacement(items, 2))
# Output: ('A', 'A'), ('A', 'B'), ('A', 'C'), ('B', 'B'), ('B', 'C'), ('C', 'C')

# Dice combinations allowing duplicates
dice = [1, 2, 3, 4, 5, 6]
two_dice = list(combinations_with_replacement(dice, 2))
# Output: 21 combinations including (1,1), (2,2), etc.

# Practical: coin change problems
coins = [1, 5, 10, 25]
ways_to_make_change = list(combinations_with_replacement(coins, 3))
# All ways to select 3 coins (with replacement)
```

**Memory-Efficient Combinatoric Processing:**

```python
from itertools import combinations, islice

def find_first_matching_combination(items, r, condition):
    """Find first combination matching condition without generating all"""
    for combo in combinations(items, r):
        if condition(combo):
            return combo
    return None

# Example: find first triple that sums to target
numbers = range(1, 100)
result = find_first_matching_combination(
    numbers, 3, lambda combo: sum(combo) == 50
)
# Stops as soon as first match found

# Process large combinations in batches
def batch_combinations(items, r, batch_size=1000):
    combo_iter = combinations(items, r)
    while True:
        batch = list(islice(combo_iter, batch_size))
        if not batch:
            break
        yield batch

# Process in manageable chunks
for batch in batch_combinations(range(50), 5, batch_size=10000):
    # Process batch
    pass
```

**Combinatoric Filtering:**

```python
from itertools import combinations, permutations

# Filter combinations by constraint
def valid_combinations(items, r, predicate):
    return filter(predicate, combinations(items, r))

numbers = [1, 2, 3, 4, 5, 6]
sum_to_ten = list(valid_combinations(
    numbers, 3, lambda combo: sum(combo) == 10
))
# Output: (1, 3, 6), (1, 4, 5), (2, 3, 5)

# Permutations with constraints
def no_adjacent_same(perm):
    return all(perm[i] != perm[i+1] for i in range(len(perm)-1))

items = ['A', 'A', 'B', 'B']
valid_perms = list(filter(no_adjacent_same, permutations(items)))
```

**Complex Combinatoric Patterns:**

```python
from itertools import product, combinations, chain

# All possible poker hands (example structure)
def poker_hands(deck):
    return combinations(deck, 5)

# Nested combinations
def all_team_matchups(players, team_size):
    """Generate all possible team vs team matchups"""
    all_teams = combinations(players, team_size)
    return combinations(all_teams, 2)

# Multi-level product
def configuration_space(*dimensions):
    """Generate all possible configurations across dimensions"""
    return product(*dimensions)

config_space = configuration_space(
    ['small', 'medium', 'large'],           # size
    ['red', 'blue', 'green'],               # color
    ['cotton', 'polyester'],                # material
    ['round', 'v-neck']                     # neck type
)
# Output: 36 total configurations
```

**Performance Considerations:**

```python
from itertools import combinations
import math

def count_combinations(n, r):
    """Calculate count without generating"""
    return math.comb(n, r)

# Check size before generating
n, r = 100, 50
count = count_combinations(n, r)
print(f"Would generate {count} combinations")
# Output: Would generate 100891344545564193334812497256 combinations
# (too large to materialize!)

# Use generator expressions for large spaces
large_space = (combo for combo in combinations(range(1000), 10))
# Only generates combinations as needed
```

