## Operator Module


The `operator` module provides function equivalents for Python's built-in operators, enabling operators to be used as first-class functions. This eliminates the need for lambda expressions in many common scenarios and improves code readability.

**Arithmetic Operators**: Functions like `add()`, `sub()`, `mul()`, `truediv()`, `floordiv()`, `mod()`, and `pow()` replace arithmetic operators. These are particularly useful with `reduce()` and `map()`.

**Comparison Operators**: Functions including `eq()`, `ne()`, `lt()`, `le()`, `gt()`, and `ge()` enable comparisons as function arguments. These integrate seamlessly with sorting and filtering operations.

**Logical Operators**: `and_()`, `or_()`, `not_()`, and `xor()` provide boolean operations as functions. Note that unlike their operator counterparts, these do not short-circuit.

**Item Access Operators**: `getitem()` and `setitem()` enable bracket notation as functions. `getitem()` is especially powerful when combined with `itemgetter()` for extracting multiple elements.

**Attribute Access**: `attrgetter()` creates functions that extract attributes from objects. It supports nested attributes, multiple attributes, and dot notation, making it invaluable for sorting and grouping operations.

**Method Calling**: `methodcaller()` creates functions that call specific methods on objects. It supports both method names and arguments, enabling dynamic method invocation in functional pipelines.

**Item Getter Factory**: `itemgetter()` creates functions that retrieve items by index or key. It can extract multiple items simultaneously, returning tuples when given multiple arguments.

**In-Place Operators**: Functions like `iadd()`, `imul()`, etc., correspond to augmented assignment operators. These modify objects in-place when possible, though their use contradicts immutability principles.

**Key Points**

- Operator functions are faster than equivalent lambdas due to implementation in C
- `attrgetter()` and `itemgetter()` support multiple arguments for extracting multiple values
- Operator functions have meaningful names, improving code documentation
- These functions work seamlessly with `functools` and `itertools`

**Example**

```python
from operator import add, mul, itemgetter, attrgetter, methodcaller
from functools import reduce

# Arithmetic operations
numbers = [1, 2, 3, 4, 5]
total = reduce(add, numbers)  # 15
product = reduce(mul, numbers)  # 120

# Item extraction
data = [('Alice', 30, 5000), ('Bob', 25, 6000), ('Charlie', 35, 5500)]
get_name_and_salary = itemgetter(0, 2)
names_salaries = list(map(get_name_and_salary, data))
# [('Alice', 5000), ('Bob', 6000), ('Charlie', 5500)]

# Sorting by multiple fields
sorted_data = sorted(data, key=itemgetter(2, 1))  # Sort by salary, then age

# Attribute access
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age
        self.address = type('Address', (), {'city': 'NYC'})()

people = [Person('Alice', 30), Person('Bob', 25)]
get_age = attrgetter('age')
ages = list(map(get_age, people))  # [30, 25]

# Nested attribute access
get_city = attrgetter('address.city')
cities = list(map(get_city, people))  # ['NYC', 'NYC']

# Method calling
strings = ['hello', 'world', 'python']
uppercase = methodcaller('upper')
result = list(map(uppercase, strings))  # ['HELLO', 'WORLD', 'PYTHON']

# Method with arguments
replace_o = methodcaller('replace', 'o', '0')
modified = list(map(replace_o, strings))  # ['hell0', 'w0rld', 'pyth0n']
```

