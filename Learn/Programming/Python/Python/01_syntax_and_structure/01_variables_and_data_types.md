## Variables and Data Types


### **Variables in Python**

A variable is a named reference to a value stored in memory. Python is dynamically typed, meaning you do not need to declare the type explicitly; it is inferred based on the assigned value.

**Example:**

```python
x = 10        # Integer
y = 3.14      # Float
name = "John" # String
is_valid = True # Boolean
```

### **Variable Naming Rules**

- Must start with a letter (a-z, A-Z) or an underscore (`_`)
- Can contain letters, digits (0-9), and underscores (`_`)
- Cannot be a Python keyword (e.g., `class`, `def`, `return`)
- Case-sensitive (`name` and `Name` are different variables)
    
### **Variable Assignment**

Python allows multiple types of assignments:

#### Single Assignment

```python
a = 5
b = "Hello"
```

#### Multiple Assignment

```python
x, y, z = 10, 20, 30
```

#### Same Value Assignment

```python
a = b = c = 100
```

### **Data Types in Python**

Python provides several built-in data types, categorized as follows:

#### Numeric Types
- **int** – Whole numbers (e.g., `5`, `-10`, `100`)
- **float** – Decimal numbers (e.g., `3.14`, `-2.5`)
- **complex** – Numbers with a real and imaginary part (e.g., `2 + 3j`)
    

**Example:**

```python
num_int = 10
num_float = 3.14
num_complex = 2 + 3j
```

#### Sequence Types
- **str** – A sequence of characters (e.g., `"hello"`, `'world'`)
- **list** – Ordered, mutable collection (e.g., `[1, 2, 3]`)
- **tuple** – Ordered, immutable collection (e.g., `(1, 2, 3)`)
- **range** – Represents a sequence of numbers (e.g., `range(5) → 0,1,2,3,4`)
    

**Example:**

```python
text = "Python"
my_list = [1, 2, 3, "apple"]
my_tuple = (10, 20, 30)
my_range = range(1, 6)  # 1, 2, 3, 4, 5
```

#### Set Types
- **set** – Unordered collection of unique elements (e.g., `{1, 2, 3}`)
- **frozenset** – Immutable version of `set`
    

**Example:**

```python
my_set = {1, 2, 3, 4}
my_frozenset = frozenset({10, 20, 30})
```

#### Mapping Type
- **dict** – Key-value pair collection (e.g., `{"name": "Alice", "age": 30}`)
    

**Example:**

```python
person = {"name": "Alice", "age": 30, "city": "New York"}
```

#### Boolean Type
- **bool** – Represents `True` or `False`
    

**Example:**

```python
is_python_fun = True
is_sky_green = False
```

#### Binary Types
- **bytes** – Immutable sequence of bytes
- **bytearray** – Mutable sequence of bytes
- **memoryview** – Memory-efficient view of byte data
    

**Example:**

```python
byte_data = b"hello"
byte_array = bytearray([65, 66, 67])
memory_view = memoryview(byte_data)
```

### **Type Checking and Conversion**

Python provides functions to check and convert data types.

#### Checking Data Type

Use `type()` to determine the type of a variable.

```python
x = 42
print(type(x))  # Output: <class 'int'>
```

#### Explicit Type Conversion (Type Casting)

Convert between data types using built-in functions:

- `int()`, `float()`, `str()`, `list()`, `tuple()`, `set()`, `dict()`
    

**Example:**

```python
num_str = "100"
num_int = int(num_str)  # Converts string to integer
num_float = float(num_int)  # Converts integer to float
```

### **Mutable vs. Immutable Types**

- **Mutable** (modifiable): `list`, `set`, `dict`, `bytearray`
- **Immutable** (unchangeable): `int`, `float`, `str`, `tuple`, `frozenset`, `bytes`
    

**Example:**

```python
# Mutable
my_list = [1, 2, 3]
my_list[0] = 10  # Allowed

# Immutable
my_tuple = (1, 2, 3)
# my_tuple[0] = 10  # Error: Cannot modify a tuple
```

**Key Points**
- Python is dynamically typed; variable types are inferred at runtime.
- Variables are case-sensitive and must follow naming rules.
- Data types include numeric, sequence, set, mapping, boolean, and binary types.
- Use `type()` to check data types and built-in functions for conversions.
- Lists, sets, and dictionaries are mutable, while strings, tuples, and numbers are immutable.

---

