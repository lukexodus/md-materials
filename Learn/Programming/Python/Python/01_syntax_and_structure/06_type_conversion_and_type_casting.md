## Type Conversion and Type Casting


### **Type Conversion (Implicit and Explicit)**

Python automatically converts compatible types (implicit conversion), but explicit conversion (type casting) is required when dealing with incompatible types.

### **Implicit Type Conversion (Automatic)**

Python automatically promotes smaller data types to larger ones in expressions.

**Example:**

```python
a = 5   # int
b = 2.5 # float
c = a + b  # int + float → float
print(type(c))  # Output: <class 'float'>
```

Here, `a` (int) is automatically converted to `float` before addition.

### **Explicit Type Conversion (Type Casting)**

Manually convert data types using Python's built-in functions.

#### **Integer Conversion (`int()`)**

Converts values to integers, truncating decimals.

```python
x = int(3.9)  # 3
y = int("10")  # 10
z = int(True)  # 1
```

#### **Float Conversion (`float()`)**

Converts values to floating-point numbers.

```python
x = float(5)  # 5.0
y = float("3.14")  # 3.14
z = float(False)  # 0.0
```

#### **String Conversion (`str()`)**

Converts values to strings.

```python
x = str(100)  # "100"
y = str(3.14)  # "3.14"
z = str(True)  # "True"
```

#### **Boolean Conversion (`bool()`)**

Converts values to boolean (`True` or `False`).

```python
x = bool(0)  # False
y = bool(1)  # True
z = bool("Hello")  # True (Non-empty strings are True)
```

#### **List, Tuple, and Set Conversions**

Convert between list, tuple, and set types.

```python
x = list((1, 2, 3))  # (Tuple → List) → [1, 2, 3]
y = tuple([1, 2, 3])  # (List → Tuple) → (1, 2, 3)
z = set([1, 2, 3])  # (List → Set) → {1, 2, 3}
```

#### **Dictionary Conversion (`dict()`)**

Converts key-value pairs to a dictionary.

```python
x = dict([("name", "Alice"), ("age", 25)])  # {"name": "Alice", "age": 25}
```

### **Handling Errors in Type Conversion**

Errors occur when trying to convert incompatible types.

```python
try:
    x = int("Hello")  # Error: Cannot convert a non-numeric string to int
except ValueError:
    print("Invalid conversion!")
```

**Key Points**
- Python automatically converts compatible types (implicit conversion).
- Explicit conversion (type casting) is needed for incompatible types.
- Use `int()`, `float()`, `str()`, and `bool()` for common type conversions.
- Lists, tuples, and sets can be interconverted using `list()`, `tuple()`, and `set()`.
- `dict()` can be used to create dictionaries from key-value pairs.
- Handle errors using `try-except` to prevent crashes during invalid conversions.

---

