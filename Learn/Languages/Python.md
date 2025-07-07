## **Comprehensive Python Syllabus**

### Introduction to Python

- History and evolution of Python
- Features and advantages of Python
- Installing Python and setting up the environment (IDLE, VS Code, PyCharm, Jupyter)
- Running Python scripts and interactive mode
- Understanding Python syntax and indentation

### Python Basics

- Variables and data types (int, float, string, bool, complex)
- Basic I/O operations (input and output)
- Operators (arithmetic, comparison, logical, bitwise, assignment, identity, membership)
- Type conversion and type casting

### Control Flow and Loops

- Conditional statements (if, elif, else)
- Looping structures (for, while, nested loops)
- Loop control statements (break, continue, pass)
- List comprehensions and generator expressions

### Data Structures in Python

- Lists (creation, indexing, slicing, methods)
- Tuples (immutability, operations, packing & unpacking)
- Sets (properties, methods, set operations)
- Dictionaries (keys, values, dictionary methods, comprehension)
- Strings (string methods, formatting, f-strings, regular expressions)

### Functions and Modules

- Defining and calling functions
- Arguments (positional, keyword, default, arbitrary)
- Return values and scope of variables
- Lambda functions
- Recursion
- Importing modules and creating custom modules
- The `sys`, `os`, `math`, `random`, and `datetime` modules

### File Handling

- Reading and writing files (text and binary)
- File methods (`open`, `read`, `write`, `close`)
- File modes (`r`, `w`, `a`, `rb`, `wb`, etc.)
- Using `with` statement for file handling
- Working with CSV and JSON files

### Object-Oriented Programming (OOP) in Python

- Classes and objects
- Instance variables and class variables
- Methods (instance, class, and static methods)
- Constructors and destructors (`__init__` and `__del__`)
- Inheritance and method overriding
- Polymorphism and encapsulation
- Magic methods (`__str__`, `__repr__`, `__len__`, `__getitem__`, etc.)
- Abstract classes and interfaces

### Exception Handling and Debugging

- Understanding exceptions and errors
- Using `try`, `except`, `finally`, and `else`
- Raising exceptions (`raise` statement)
- Custom exceptions
- Debugging techniques and tools (`pdb`, `logging`, `assert` statements)

### Python Standard Library and Third-Party Libraries

- `collections` module (Counter, defaultdict, deque, OrderedDict, etc.)
- `itertools` and `functools`
- `datetime` and `time` modules
- `re` module for regular expressions
- `json` and `csv` modules for data serialization
- Introduction to NumPy, Pandas, Matplotlib, and Scikit-learn
- Virtual environments and package management using `pip` and `venv`

### Functional Programming in Python

- Map, Filter, and Reduce
- List comprehensions and generators
- Closures and decorators
- Higher-order functions

### Multithreading, Multiprocessing, and Asynchronous Programming

- Threading in Python
- Synchronization and thread safety
- Multiprocessing module
- Asynchronous programming using `asyncio`
- Creating and handling coroutines
- Using `async` and `await`
- Asynchronous I/O with `aiohttp`
- Concurrency with `asyncio.gather` and `asyncio.run`

### Web Development with Python

- Introduction to Flask and Django
- Creating APIs with Flask/Django REST framework
- Handling HTTP requests and responses
- Templating engines (Jinja2 for Flask, Django templates)
- Connecting to databases using SQLAlchemy and Django ORM

### Database Handling with Python

- Connecting Python to SQLite, MySQL, and PostgreSQL
- CRUD operations with databases
- Using ORM for database interactions
- Working with NoSQL databases (MongoDB using PyMongo)

### Data Science and Machine Learning in Python

- NumPy for numerical computations
- Pandas for data manipulation
- Matplotlib and Seaborn for data visualization
- Scikit-learn for machine learning
- TensorFlow and PyTorch for deep learning
- Data preprocessing and feature engineering

### Cybersecurity and Ethical Hacking with Python

- Cryptography using `hashlib` and `pycryptodome`
- Web scraping with `BeautifulSoup` and `Scrapy`
- Network programming with `socket`
- Automating tasks with Python scripts

### Automation and Scripting

- Web automation with Selenium
- Automating Excel with `openpyxl`
- Automating emails and notifications
- Batch processing and scheduling scripts

### Advanced Topics

- Metaprogramming in Python
- Design patterns in Python
- Performance optimization and profiling (`cProfile`, `timeit`)
- Type hinting and static type checking (`mypy`)
- Building CLI applications with `argparse` and `click`

### Final Projects

- Building a web scraper
- Developing a CRUD web application
- Creating a machine learning model
- Implementing an automation script
- Building an API with Flask or Django
- Developing a multi-threaded or asynchronous application

This syllabus covers fundamental to advanced Python topics, ensuring comprehensive knowledge suitable for beginners to expert-level programmers.

# Syntax and Structure

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

## Type Hinting

### **Introduction to Type Hinting**

Type hinting in Python allows developers to specify the expected data types of function parameters and return values. While Python remains dynamically typed, type hints improve code readability, maintainability, and enable static type checking tools like `mypy`.

### **Basic Type Annotations**

Annotations are added using a colon (`:`) after a variable name and an arrow (`->`) for return types.

**Example:**

```python
def add(x: int, y: int) -> int:
    return x + y
```

### **Built-in Types in Type Hints**

- `int`, `float`, `str`, `bool`
- `list`, `tuple`, `set`, `dict`
- `None` for functions that do not return a value
    

**Example:**

```python
def greet(name: str) -> None:
    print(f"Hello, {name}!")
```

### **Using `typing` Module for Complex Types**

The `typing` module provides additional type hints for more complex structures.

#### Lists, Tuples, and Dictionaries

```python
from typing import List, Tuple, Dict

def process_numbers(numbers: List[int]) -> Tuple[int, int]:
    return min(numbers), max(numbers)

def get_student_scores() -> Dict[str, float]:
    return {"Alice": 90.5, "Bob": 85.0}
```

#### Optional and Union Types

`Optional[T]` is equivalent to `Union[T, None]`, meaning the value can be of type `T` or `None`.

```python
from typing import Optional, Union

def find_user(user_id: int) -> Optional[str]:
    return "User123" if user_id == 1 else None

def process_data(data: Union[int, float, str]) -> str:
    return str(data)
```

#### Any Type

`Any` can represent any data type, effectively disabling type checking.

```python
from typing import Any

def dynamic_function(value: Any) -> Any:
    return value
```

### **Callable and Function Type Hints**

Use `Callable` to specify that a parameter expects a function.

```python
from typing import Callable

def execute(func: Callable[[int, int], int], a: int, b: int) -> int:
    return func(a, b)

def multiply(x: int, y: int) -> int:
    return x * y

result = execute(multiply, 3, 4)  # Output: 12
```

### **Generics for Flexibility**

Generics allow defining functions that work with multiple types using `TypeVar`.

```python
from typing import TypeVar

T = TypeVar('T')

def get_first_element(elements: List[T]) -> T:
    return elements[0]

print(get_first_element([1, 2, 3]))  # Output: 1
print(get_first_element(["a", "b", "c"]))  # Output: "a"
```

### **Self-referencing and Class-based Type Hints**

Use forward declarations (`"ClassName"`) or `Type` for self-referencing types.

```python
from typing import Type

class Node:
    def __init__(self, value: int, next_node: "Node" = None) -> None:
        self.value = value
        self.next_node = next_node

def create_node(cls: Type[Node], value: int) -> Node:
    return cls(value)
```

**Key Points**
- Type hints improve readability but do not enforce types at runtime.
- Use `typing` for complex data structures (`List`, `Dict`, `Union`, etc.).
- `Optional[T]` represents `T` or `None`.
- `Callable` is used for function arguments.
- Generics (`TypeVar`) allow functions to work with multiple types.
- Forward declarations (`"ClassName"`) help reference a class within itself.

---

## I/O Operations

### **Input Operations**

Python uses the `input()` function to take user input. It returns a string by default.

**Example:**

```python
name = input("Enter your name: ")
print(f"Hello, {name}!")
```

#### Reading Numeric Input

Since `input()` returns a string, use type conversion to get numeric values.

```python
age = int(input("Enter your age: "))
height = float(input("Enter your height in meters: "))
```

#### Handling Input Errors

Use `try-except` to handle invalid inputs.

```python
try:
    num = int(input("Enter an integer: "))
except ValueError:
    print("Invalid input! Please enter a valid integer.")
```

### **Output Operations**

Python uses `print()` to display output.

**Example:**

```python
print("Hello, World!")
```

#### Printing Multiple Values

Use commas to separate multiple values.

```python
print("Name:", "Alice", "Age:", 25)
```

#### Formatting Output

Use `f-strings` for readable formatting.

```python
name = "Alice"
age = 25
print(f"My name is {name} and I am {age} years old.")
```

#### Controlling `print()` Behavior

- `sep` specifies a separator between values.
- `end` changes the default newline behavior.

```python
print("Python", "Java", "C++", sep=" | ")
print("Hello", end=" ")
print("World!")
```

### **File I/O**

Python provides built-in functions for reading and writing files.

#### Opening and Closing Files

Use `open()` to access a file and `close()` to release resources.

```python
file = open("example.txt", "r")  # Open file in read mode
file.close()
```

Using `with open()`, files are automatically closed.

```python
with open("example.txt", "r") as file:
    content = file.read()
```

#### Reading from Files

- `read()` reads the entire file.
- `readline()` reads one line at a time.
- `readlines()` returns all lines as a list.
    

```python
with open("example.txt", "r") as file:
    print(file.read())  # Read full file
```

```python
with open("example.txt", "r") as file:
    print(file.readline())  # Read first line
```

```python
with open("example.txt", "r") as file:
    print(file.readlines())  # Read all lines into a list
```

#### Writing to Files

- `w` (write mode) overwrites the file.
- `a` (append mode) adds content to the file.
    

```python
with open("example.txt", "w") as file:
    file.write("Hello, World!\n")
```

```python
with open("example.txt", "a") as file:
    file.write("Appending a new line.\n")
```

**Key Points**
- `input()` reads user input as a string; convert it for numeric values.
- Use `try-except` to handle input errors.
- `print()` can format output using `f-strings` and control separators.
- Use `open()` with `r`, `w`, or `a` modes for file operations.
- The `with` statement ensures files are properly closed.

---
## Input Error Handling

### **Handling Invalid Input**

User input can cause errors if not properly validated. The `try-except` block helps prevent crashes by handling exceptions.

**Example:**

```python
try:
    age = int(input("Enter your age: "))  # Might raise ValueError
    print(f"You are {age} years old.")
except ValueError:
    print("Invalid input! Please enter a valid number.")
```

### **Looping Until Valid Input**

To ensure valid input, use a loop that repeatedly asks the user until they enter correct data.

**Example:**

```python
while True:
    try:
        age = int(input("Enter your age: "))
        break  # Exit loop if input is valid
    except ValueError:
        print("Invalid input! Please enter a valid number.")

print(f"You entered: {age}")
```

### **Using `else` and `finally` in Error Handling**

- `else`: Executes if no exception occurs.
- `finally`: Executes regardless of whether an exception occurs.
    

**Example:**

```python
try:
    number = float(input("Enter a number: "))
except ValueError:
    print("Invalid input!")
else:
    print(f"Valid input: {number}")
finally:
    print("Execution completed.")
```

**Key Points**
- Use `try-except` to catch exceptions and prevent crashes.
- Use loops to repeatedly prompt the user until valid input is provided.
- `else` runs if no error occurs, and `finally` always executes.

---

## Operators

### **Arithmetic Operators**

Perform mathematical operations on numbers.

- `+` (Addition) → `5 + 3 = 8`
- `-` (Subtraction) → `5 - 3 = 2`
- `*` (Multiplication) → `5 * 3 = 15`
- `/` (Division) → `5 / 2 = 2.5`
- `//` (Floor Division) → `5 // 2 = 2`
- `%` (Modulus) → `5 % 2 = 1`
- `**` (Exponentiation) → `2 ** 3 = 8`
    

**Example:**

```python
a, b = 5, 2
print(a + b, a - b, a * b, a / b, a // b, a % b, a ** b)
```

### **Comparison Operators**

Compare two values and return `True` or `False`.

- `==` (Equal) → `5 == 5 → True`
- `!=` (Not Equal) → `5 != 3 → True`
- `>` (Greater Than) → `5 > 3 → True`
- `<` (Less Than) → `5 < 3 → False`
- `>=` (Greater Than or Equal) → `5 >= 5 → True`
- `<=` (Less Than or Equal) → `5 <= 3 → False`
    

**Example:**

```python
x, y = 10, 20
print(x == y, x != y, x > y, x < y, x >= y, x <= y)
```

### **Logical Operators**

Perform logical operations on boolean values.

- `and` (Logical AND) → `True and False → False`
- `or` (Logical OR) → `True or False → True`
- `not` (Logical NOT) → `not True → False`
    

**Example:**

```python
a, b = True, False
print(a and b, a or b, not a)
```

### **Bitwise Operators**

Operate on binary representations of numbers.

- `&` (AND) → `5 & 3 = 1` (0101 & 0011 = 0001)
- `|` (OR) → `5 | 3 = 7` (0101 | 0011 = 0111)
- `^` (XOR) → `5 ^ 3 = 6` (0101 ^ 0011 = 0110)
- `~` (NOT) → `~5 = -6` (inverts bits)
- `<<` (Left Shift) → `5 << 1 = 10` (0101 → 1010)
- `>>` (Right Shift) → `5 >> 1 = 2` (0101 → 0010)
    

**Example:**

```python
a, b = 5, 3
print(a & b, a | b, a ^ b, ~a, a << 1, a >> 1)
```

### **Assignment Operators**

Assign values and modify variables.

- `=` (Assign) → `x = 5`
- `+=` (Add and Assign) → `x += 3` (Same as `x = x + 3`)
- `-=` (Subtract and Assign) → `x -= 3`
- `*=` (Multiply and Assign) → `x *= 3`
- `/=` (Divide and Assign) → `x /= 3`
- `//=` (Floor Divide and Assign) → `x //= 3`
- `%=` (Modulus and Assign) → `x %= 3`
- `**=` (Exponentiate and Assign) → `x **= 3`
- `&=`, `|=`, `^=`, `<<=`, `>>=` (Bitwise Assignments)
    

**Example:**

```python
x = 5
x += 3
print(x)  # Output: 8
```

### **Identity Operators**

Check if two objects share the same memory location.

- `is` → `a is b` (True if they reference the same object)
- `is not` → `a is not b`
    

**Example:**

```python
a = [1, 2, 3]
b = a
c = [1, 2, 3]
print(a is b, a is not c)
```

### **Membership Operators**

Check if a value exists in a sequence.

- `in` → `3 in [1, 2, 3]` (True)
- `not in` → `4 not in [1, 2, 3]` (True)
    

**Example:**

```python
nums = [1, 2, 3, 4]
print(3 in nums, 5 not in nums)
```

### **Operator Precedence**

Defines the order in which operations are executed.  
**Precedence (Highest to Lowest):**

1. `()` (Parentheses)
2. `**` (Exponentiation)
3. `+x, -x, ~x` (Unary Operators)
4. `*, /, //, %` (Multiplication and Division)
5. `+, -` (Addition and Subtraction)
6. `<<, >>` (Bitwise Shift)
7. `&` (Bitwise AND)
8. `^` (Bitwise XOR)
9. `|` (Bitwise OR)
10. `==, !=, >, <, >=, <=` (Comparisons)
11. `is, is not, in, not in` (Identity and Membership)
12. `not` (Logical NOT)
13. `and` (Logical AND)
14. `or` (Logical OR)
15. `=, +=, -=, *=, /=, //=, %=, **=, &=, |=, ^=, <<=, >>=` (Assignments)
    

**Example:**

```python
result = 5 + 2 * 3  # Multiplication happens first: 5 + (2 * 3) = 11
```

**Key Points**
- Operators perform arithmetic, comparison, logical, bitwise, assignment, identity, and membership operations.
- Arithmetic operators include `+`, `-`, `*`, `/`, `//`, `%`, `**`.
- Comparison operators return boolean values based on conditions.
- Logical operators (`and`, `or`, `not`) operate on boolean values.
- Bitwise operators manipulate binary representations.
- Assignment operators modify variables in-place.
- Identity operators (`is`, `is not`) compare memory locations.
- Membership operators (`in`, `not in`) check sequence membership.
- Operator precedence determines execution order.

---

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

# Control Flow and Loops

## Conditional Statements  

### **Overview**  
Conditional statements control the flow of a program by executing different code blocks based on conditions. Python uses `if`, `elif`, and `else` for decision-making.  

### **Basic `if` Statement**  
Executes a block of code if the condition is `True`.  
```python
age = 18
if age >= 18:
    print("You are an adult.")
```

### **`if-else` Statement**  
Executes one block if the condition is `True` and another if it is `False`.  
```python
num = 10
if num % 2 == 0:
    print("Even number")
else:
    print("Odd number")
```

### **`if-elif-else` Statement**  
Checks multiple conditions in sequence.  
```python
score = 85
if score >= 90:
    print("Grade: A")
elif score >= 80:
    print("Grade: B")
elif score >= 70:
    print("Grade: C")
else:
    print("Grade: F")
```

### **Nested `if` Statements**  
An `if` statement inside another `if`.  
```python
num = 15
if num > 0:
    if num % 2 == 0:
        print("Positive even number")
    else:
        print("Positive odd number")
```

### **Ternary Operator (Conditional Expression)**  
A compact way to write `if-else`.  
```python
age = 20
status = "Adult" if age >= 18 else "Minor"
print(status)
```

### **Using `and`, `or`, `not` in Conditions**  
Logical operators combine multiple conditions.  
```python
x, y = 10, 5
if x > 5 and y < 10:
    print("Both conditions are true")

if x > 5 or y > 10:
    print("At least one condition is true")

if not (x < 5):
    print("Negation used")
```

### **Using `in` for Membership Testing**  
Check if a value exists in a sequence.  
```python
fruits = ["apple", "banana", "cherry"]
if "banana" in fruits:
    print("Banana is in the list")
```

### **Pass Statement in Conditional Blocks**  
Use `pass` as a placeholder to avoid errors.  
```python
x = 10
if x > 0:
    pass  # Placeholder for future code
```

**Key Points**  
- `if`, `elif`, and `else` control program flow based on conditions.  
- Use `if-elif-else` for multiple conditions.  
- Nested `if` statements check conditions within conditions.  
- The ternary operator provides a shorthand for `if-else`.  
- Logical operators (`and`, `or`, `not`) combine conditions.  
- The `in` keyword checks membership in sequences.  
- Use `pass` when a conditional block needs to be empty.

---

## Looping Structures  

### **Overview**  
Loops execute a block of code multiple times until a condition is met. Python provides `for` and `while` loops for iteration.  

### **`for` Loop**  
Iterates over sequences like lists, tuples, dictionaries, and ranges.  
```python
fruits = ["apple", "banana", "cherry"]
for fruit in fruits:
    print(fruit)
```

#### **Looping with `range()`**  
Generates a sequence of numbers.  
```python
for i in range(5):  # 0 to 4
    print(i)
```
```python
for i in range(1, 10, 2):  # Start, Stop, Step
    print(i)  # 1, 3, 5, 7, 9
```

#### **Looping Through a Dictionary**  
```python
person = {"name": "Alice", "age": 25}
for key, value in person.items():
    print(key, ":", value)
```

### **`while` Loop**  
Executes as long as the condition is `True`.  
```python
x = 0
while x < 5:
    print(x)
    x += 1
```

### **Loop Control Statements**  

#### **`break` Statement**  
Stops the loop immediately.  
```python
for i in range(10):
    if i == 5:
        break
    print(i)  # Stops at 4
```

#### **`continue` Statement**  
Skips the current iteration and continues with the next.  
```python
for i in range(5):
    if i == 2:
        continue
    print(i)  # Skips 2
```

#### **`else` Clause in Loops**  
Executes when the loop completes without `break`.  
```python
for i in range(3):
    print(i)
else:
    print("Loop completed")
```

#### **`pass` Statement**  
Placeholder for future code.  
```python
for i in range(5):
    pass  # Does nothing
```

### **Nested Loops**  
A loop inside another loop.  
```python
for i in range(3):
    for j in range(2):
        print(i, j)
```

### **List Comprehension for Loops**  
A concise way to create lists.  
```python
squares = [x**2 for x in range(5)]
print(squares)  # [0, 1, 4, 9, 16]
```

**Key Points**  
- `for` loops iterate over sequences like lists, tuples, and ranges.  
- `while` loops run while a condition is `True`.  
- Use `break` to exit a loop and `continue` to skip an iteration.  
- `else` in loops runs when the loop completes normally.  
- `pass` is a placeholder for incomplete loops.  
- Nested loops allow iterating over multiple dimensions.  
- List comprehensions provide a compact way to loop and create lists.

---

## List Comprehensions and Generator Expressions  

### **List Comprehensions**  
A list comprehension provides a concise way to create lists using a single line of code.  

#### **Basic Syntax**  
```python
[expression for item in iterable if condition]
```

#### **Example: Creating a List Using a Loop**  
```python
numbers = [1, 2, 3, 4, 5]
squares = [x**2 for x in numbers]
print(squares)  # [1, 4, 9, 16, 25]
```

#### **With Conditional Filtering**  
```python
even_numbers = [x for x in range(10) if x % 2 == 0]
print(even_numbers)  # [0, 2, 4, 6, 8]
```

#### **Using `if-else` in List Comprehension**  
```python
labels = ["Even" if x % 2 == 0 else "Odd" for x in range(5)]
print(labels)  # ['Even', 'Odd', 'Even', 'Odd', 'Even']
```

#### **Nested List Comprehensions**  
```python
matrix = [[j for j in range(3)] for i in range(3)]
print(matrix)  # [[0, 1, 2], [0, 1, 2], [0, 1, 2]]
```

### **Generator Expressions**  
Similar to list comprehensions, but they generate values lazily, improving memory efficiency.  

#### **Basic Syntax**  
```python
(expression for item in iterable if condition)
```

#### **Example: Creating a Generator**  
```python
gen = (x**2 for x in range(5))
print(next(gen))  # 0
print(next(gen))  # 1
```

#### **Using a Generator in a Loop**  
```python
for val in (x**2 for x in range(5)):
    print(val)  # 0, 1, 4, 9, 16
```

### **Difference Between List Comprehension and Generator Expression**  
| Feature       | List Comprehension                  | Generator Expression                |
| ------------- | ----------------------------------- | ----------------------------------- |
| Syntax        | `[expression for item in iterable]` | `(expression for item in iterable)` |
| Memory Usage  | Stores all values in memory         | Generates values one by one         |
| Performance   | Faster for small data sets          | More efficient for large data sets  |
| Modifiability | Creates a full list                 | Cannot modify once created          |
|               |                                     |                                     |

**Key Points**  
- List comprehensions create lists in a concise way.  
- Generators yield values lazily, improving memory efficiency.  
- Use list comprehensions when working with small to medium-sized data.  
- Use generator expressions for large datasets or when lazy evaluation is needed.

---

# Data Structures

## Lists  

### **Overview**  
A list is an ordered, mutable collection that allows storing multiple items in a single variable. Lists can hold elements of different data types.  

### **Creating Lists**  
```python
# Empty list
empty_list = []

# List with elements
fruits = ["apple", "banana", "cherry"]

# List with mixed data types
mixed = [1, "hello", 3.14, True]

# Using the list() constructor
numbers = list((1, 2, 3, 4))
```

### **Accessing Elements**  
```python
fruits = ["apple", "banana", "cherry"]
print(fruits[0])   # apple (first element)
print(fruits[-1])  # cherry (last element)
```

### **Slicing Lists**  
```python
numbers = [0, 1, 2, 3, 4, 5]
print(numbers[1:4])  # [1, 2, 3] (from index 1 to 3)
print(numbers[:3])   # [0, 1, 2] (from start to index 2)
print(numbers[::2])  # [0, 2, 4] (every second element)
```

### **Modifying Lists**  
```python
fruits[1] = "blueberry"  # Change an element
fruits.append("orange")  # Add an element at the end
fruits.insert(1, "grape")  # Insert at index 1
fruits.extend(["mango", "pineapple"])  # Add multiple elements
```

### **Removing Elements**  
```python
fruits.remove("banana")  # Remove by value
deleted_item = fruits.pop(2)  # Remove by index (returns removed item)
del fruits[0]  # Delete element at index 0
fruits.clear()  # Remove all elements
```

### **Looping Through Lists**  
```python
for fruit in fruits:
    print(fruit)

for i, fruit in enumerate(fruits):
    print(i, fruit)
```

### **Checking Membership**  
```python
print("apple" in fruits)  # True if "apple" exists in list
```

### **Sorting and Reversing**  
```python
numbers = [3, 1, 4, 1, 5]
numbers.sort()  # Sort in ascending order
numbers.sort(reverse=True)  # Sort in descending order
fruits.reverse()  # Reverse the list
```

### **List Comprehensions**  
```python
squares = [x**2 for x in range(5)]  # [0, 1, 4, 9, 16]
even_numbers = [x for x in range(10) if x % 2 == 0]  # [0, 2, 4, 6, 8]
```

### **Copying Lists**  
```python
copy1 = fruits.copy()  # Using copy()
copy2 = fruits[:]  # Using slicing
copy3 = list(fruits)  # Using list() constructor
```

### **List Methods**  
```python
fruits.count("apple")  # Count occurrences of "apple"
fruits.index("banana")  # Get index of "banana"
fruits.sort()  # Sort in place
fruits.reverse()  # Reverse in place
```

**Key Points**  
- Lists are mutable and can hold mixed data types.  
- Elements can be accessed via indexing and slicing.  
- Lists can be modified using `append()`, `insert()`, `extend()`, and element assignment.  
- Elements can be removed using `remove()`, `pop()`, `del`, and `clear()`.  
- Lists support iteration, sorting, reversing, and comprehensions.  
- Copying lists requires using `copy()`, slicing, or the `list()` constructor.

---

## Tuples  

### **Overview**  
A tuple is an ordered, immutable collection that can store multiple elements of different data types. Unlike lists, tuples cannot be modified after creation.  

### **Creating Tuples**  
```python
# Empty tuple
empty_tuple = ()

# Tuple with elements
fruits = ("apple", "banana", "cherry")

# Tuple with mixed data types
mixed = (1, "hello", 3.14, True)

# Single-element tuple (comma is required)
single_element = ("apple",)

# Using the tuple() constructor
numbers = tuple([1, 2, 3, 4])
```

### **Accessing Elements**  
```python
print(fruits[0])   # apple (first element)
print(fruits[-1])  # cherry (last element)
```

### **Slicing Tuples**  
```python
numbers = (0, 1, 2, 3, 4, 5)
print(numbers[1:4])  # (1, 2, 3)
print(numbers[:3])   # (0, 1, 2)
print(numbers[::2])  # (0, 2, 4)
```

### **Tuple Packing and Unpacking**  
```python
# Packing
person = ("Alice", 25, "Engineer")

# Unpacking
name, age, job = person
print(name)  # Alice
print(age)   # 25
print(job)   # Engineer
```

### **Looping Through Tuples**  
```python
for fruit in fruits:
    print(fruit)

for i, fruit in enumerate(fruits):
    print(i, fruit)
```

### **Checking Membership**  
```python
print("apple" in fruits)  # True if "apple" exists in tuple
```

### **Tuple Concatenation and Repetition**  
```python
new_tuple = fruits + ("mango", "pineapple")  # Concatenation
repeated = fruits * 2  # ('apple', 'banana', 'cherry', 'apple', 'banana', 'cherry')
```

### **Converting Between Tuples and Lists**  
```python
fruits_list = list(fruits)  # Convert tuple to list
fruits_tuple = tuple(fruits_list)  # Convert list back to tuple
```

### **Tuple Methods**  
```python
fruits.count("apple")  # Count occurrences of "apple"
fruits.index("banana")  # Get index of "banana"
```

**Key Points**  
- Tuples are immutable and ordered collections.  
- They support indexing, slicing, and unpacking.  
- Elements cannot be modified after creation.  
- Tuple concatenation and repetition create new tuples.  
- Membership checking and iteration are supported.  
- Tuples use less memory and are faster than lists for fixed data.

---

## Sets  

### **Overview**  
A set is an unordered, mutable collection of unique elements. Sets do not allow duplicate values and do not support indexing or slicing.  

### **Creating Sets**  
```python
# Empty set (must use set(), not {})
empty_set = set()

# Set with elements
fruits = {"apple", "banana", "cherry"}

# Using the set() constructor
numbers = set([1, 2, 3, 4, 4, 2])  # {1, 2, 3, 4}
```

### **Adding and Removing Elements**  
```python
fruits.add("orange")  # Add a single element
fruits.update(["mango", "grape"])  # Add multiple elements

fruits.remove("banana")  # Remove; raises error if not found
fruits.discard("banana")  # Remove; does not raise an error
deleted = fruits.pop()  # Removes a random element
fruits.clear()  # Remove all elements
```

### **Set Operations**  
```python
A = {1, 2, 3, 4}
B = {3, 4, 5, 6}

# Union (A ∪ B)
print(A | B)  # {1, 2, 3, 4, 5, 6}

# Intersection (A ∩ B)
print(A & B)  # {3, 4}

# Difference (A - B)
print(A - B)  # {1, 2}

# Symmetric Difference (A Δ B)
print(A ^ B)  # {1, 2, 5, 6}
```

### **Checking Membership and Set Relations**  
```python
print(2 in A)  # True
print(A.issubset(B))  # False
print(A.issuperset(B))  # False
print(A.isdisjoint(B))  # False
```

### **Looping Through a Set**  
```python
for item in fruits:
    print(item)
```

### **Frozen Sets**  
A `frozenset` is an immutable version of a set.  
```python
immutable_set = frozenset([1, 2, 3, 4])
# immutable_set.add(5)  # This would raise an error
```

**Key Points**  
- Sets store unique, unordered elements.  
- They support mathematical operations like union, intersection, and difference.  
- Sets do not support indexing or slicing.  
- Use `frozenset` for immutable sets.

---

## Dictionaries  

### **Overview**  
A dictionary is an unordered, mutable collection of key-value pairs. Keys must be unique and immutable (e.g., strings, numbers, or tuples), while values can be of any data type.  

### **Creating Dictionaries**  
```python
# Empty dictionary
empty_dict = {}

# Dictionary with key-value pairs
person = {"name": "Alice", "age": 25, "job": "Engineer"}

# Using dict() constructor
person2 = dict(name="Bob", age=30, job="Doctor")

# Dictionary with mixed keys
data = {1: "one", "two": 2, (3, 4): "tuple key"}
```

### **Accessing Values**  
```python
print(person["name"])  # Alice
print(person.get("age"))  # 25
print(person.get("salary", "Not available"))  # Default value if key is missing
```

### **Adding and Updating Values**  
```python
person["city"] = "New York"  # Add new key-value pair
person["age"] = 26  # Update existing value
```

### **Removing Key-Value Pairs**  
```python
del person["job"]  # Remove key-value pair
removed_value = person.pop("age")  # Remove and return value
person.clear()  # Remove all elements
```

### **Looping Through a Dictionary**  
```python
# Iterating through keys
for key in person:
    print(key, person[key])

# Iterating through key-value pairs
for key, value in person.items():
    print(key, value)
```

### **Dictionary Methods**  
```python
keys = person.keys()  # Get all keys
values = person.values()  # Get all values
items = person.items()  # Get all key-value pairs

person.update({"age": 27, "gender": "Female"})  # Update multiple keys
```

### **Dictionary Comprehensions**  
```python
squares = {x: x**2 for x in range(5)}  # {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}
```

**Key Points**  
- Dictionaries store key-value pairs and allow fast lookups.  
- Keys must be unique and immutable, while values can be any type.  
- Use `get()` for safe key access.  
- `update()` merges two dictionaries.  
- `items()`, `keys()`, and `values()` provide efficient access to dictionary contents.

---

## Strings  

### **Overview**  
A string is an immutable sequence of characters enclosed in single (`'`), double (`"`), or triple (`''' """`) quotes. Strings support indexing, slicing, and various built-in methods for manipulation.  

### **Creating Strings**  
```python
# Using single or double quotes
string1 = 'Hello'
string2 = "World"

# Using triple quotes for multiline strings
multiline = '''This is 
a multiline 
string'''

# Creating a string with the str() constructor
num_str = str(100)  # "100"
```

### **Accessing Characters**  
```python
text = "Python"
print(text[0])  # 'P' (first character)
print(text[-1])  # 'n' (last character)
```

### **Slicing Strings**  
```python
print(text[1:4])  # 'yth'
print(text[:3])  # 'Pyt'
print(text[::2])  # 'Pto' (every second character)
print(text[::-1])  # 'nohtyP' (reversed string)
```

### **String Concatenation and Repetition**  
```python
greeting = "Hello" + " " + "World"  # 'Hello World'
repeat = "Ha" * 3  # 'HaHaHa'
```

### **Checking Substrings**  
```python
print("Py" in text)  # True
print("Java" not in text)  # True
```

### **Modifying Strings**  
```python
text = "hello world"
print(text.upper())  # 'HELLO WORLD'
print(text.lower())  # 'hello world'
print(text.title())  # 'Hello World'
print(text.capitalize())  # 'Hello world'
print(text.swapcase())  # 'HELLO WORLD'
```

### **Trimming and Padding Strings**  
```python
text = "  Python  "
print(text.strip())  # 'Python' (removes spaces)
print(text.lstrip())  # 'Python  ' (removes left spaces)
print(text.rstrip())  # '  Python' (removes right spaces)

print(text.center(20, '-'))  # '-----  Python  -----'
print(text.ljust(20, '-'))  # '  Python  ---------'
print(text.rjust(20, '-'))  # '---------  Python  '
```

### **Replacing and Splitting Strings**  
```python
text = "Hello World"
print(text.replace("World", "Python"))  # 'Hello Python'

words = text.split()  # ['Hello', 'World']
csv_data = "apple,banana,grape"
print(csv_data.split(","))  # ['apple', 'banana', 'grape']
```

### **Joining Strings**  
```python
words = ["Hello", "World"]
print(" ".join(words))  # 'Hello World'

csv_list = ["apple", "banana", "grape"]
print(",".join(csv_list))  # 'apple,banana,grape'
```

### **Finding Substrings**  
```python
text = "Python programming"
print(text.find("pro"))  # 7 (first occurrence index)
print(text.rfind("o"))  # 9 (last occurrence index)
print(text.count("o"))  # 2 (number of occurrences)
```

### **Checking String Properties**  
```python
print("hello".isalpha())  # True (only letters)
print("123".isdigit())  # True (only digits)
print("hello123".isalnum())  # True (letters and digits)
print("   ".isspace())  # True (only spaces)
print("Hello World".istitle())  # True (each word capitalized)
```

### **Formatting Strings**  
```python
name = "Alice"
age = 25
print(f"My name is {name} and I am {age} years old.")  # f-string
print("My name is {} and I am {} years old.".format(name, age))  # format()
print("My name is %s and I am %d years old." % (name, age))  # Old-style formatting
```

### **Reversing a String**  
```python
text = "Python"
reversed_text = text[::-1]  # 'nohtyP'
print(''.join(reversed(text)))  # 'nohtyP'
```

**Key Points**  
- Strings are immutable and support indexing, slicing, and various built-in methods.  
- Use `+` for concatenation and `*` for repetition.  
- `strip()`, `lstrip()`, and `rstrip()` remove whitespace.  
- `find()`, `count()`, and `replace()` help in searching and modifying strings.  
- `join()` efficiently concatenates elements from an iterable.  
- `f-strings`, `format()`, and `%` formatting are used for dynamic string generation.

---

## Formatting Strings  

### **Using f-strings (Python 3.6+)**  
```python
name = "Alice"
age = 25
print(f"My name is {name} and I am {age} years old.")  # 'My name is Alice and I am 25 years old.'

# Expressions inside f-strings
print(f"Next year, I will be {age + 1} years old.")  # 'Next year, I will be 26 years old.'

# Formatting numbers
pi = 3.14159
print(f"Pi to two decimal places: {pi:.2f}")  # 'Pi to two decimal places: 3.14'
print(f"Binary of 10: {10:b}")  # 'Binary of 10: 1010'
```

### **Using `.format()` Method**  
```python
print("My name is {} and I am {} years old.".format(name, age))  
# 'My name is Alice and I am 25 years old.'

# Using positional and keyword arguments
print("{0} is {1} years old.".format(name, age))  # 'Alice is 25 years old.'
print("{name} is {age} years old.".format(name="Bob", age=30))  # 'Bob is 30 years old.'

# Formatting numbers
print("Pi to two decimal places: {:.2f}".format(pi))  # 'Pi to two decimal places: 3.14'
print("Binary of 10: {:b}".format(10))  # 'Binary of 10: 1010'
```

### **Using `%` Formatting (Old-Style, C-like)**  
```python
print("My name is %s and I am %d years old." % (name, age))  
# 'My name is Alice and I am 25 years old.'

# Formatting numbers
print("Pi to two decimal places: %.2f" % pi)  # 'Pi to two decimal places: 3.14'
print("Binary of 10: %s" % bin(10)[2:])  # 'Binary of 10: 1010'
```

### **Aligning and Padding Strings**  
```python
text = "Python"
print(f"|{text:<10}|")  # Left align:  '|Python    |'
print(f"|{text:>10}|")  # Right align: '|    Python|'
print(f"|{text:^10}|")  # Center align: '|  Python  |'

# Padding with specific characters
print(f"|{text:-^10}|")  # '|--Python--|'
```

**Key Points**  
- **f-strings** (Python 3.6+) provide the most readable and efficient formatting.  
- **`format()` method** is flexible and allows positional and keyword arguments. 
- **`%` formatting** is an older style similar to C-style formatting.  
- **Alignment options** (`<`, `>`, `^`) help structure text output.  
- **Precision control** (`.xf`) is useful for formatting numbers.

---

# Functions and Modules

## Defining and Calling Functions  

### **Defining a Function**  
A function in Python is defined using the `def` keyword, followed by the function name and parentheses containing optional parameters. The function body is indented and typically includes a `return` statement.  

```python
def greet():
    print("Hello, world!")

def add(a, b):
    return a + b
```

### **Calling a Function**  
```python
greet()  # Output: Hello, world!
result = add(5, 3)  # 8
```

### **Function Parameters and Arguments**  
#### **Positional Arguments**  
Arguments are matched based on position.  
```python
def describe_person(name, age):
    print(f"{name} is {age} years old.")

describe_person("Alice", 25)  # 'Alice is 25 years old.'
```

#### **Keyword Arguments**  
Arguments are passed using parameter names.  
```python
describe_person(age=30, name="Bob")  # 'Bob is 30 years old.'
```

#### **Default Parameters**  
```python
def greet(name="Guest"):
    print(f"Hello, {name}!")

greet()  # 'Hello, Guest!'
greet("Alice")  # 'Hello, Alice!'
```

#### **Arbitrary Arguments (`*args`)**  
Allows a function to accept any number of positional arguments as a tuple.  
```python
def sum_numbers(*args):
    return sum(args)

print(sum_numbers(1, 2, 3, 4))  # 10
```

#### **Arbitrary Keyword Arguments (`**kwargs`)**  
Allows passing multiple named arguments as a dictionary.  
```python
def display_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

display_info(name="Alice", age=25, job="Engineer")
# name: Alice
# age: 25
# job: Engineer
```

### **Returning Multiple Values**  
A function can return multiple values as a tuple.  
```python
def get_coordinates():
    return 10, 20

x, y = get_coordinates()
print(x, y)  # 10 20
```

### **Lambda (Anonymous) Functions**  
Lambda functions are one-line anonymous functions.  
```python
square = lambda x: x**2
print(square(5))  # 25

add = lambda a, b: a + b
print(add(3, 4))  # 7
```

### **Function Scope**  
#### **Local and Global Variables**  
```python
x = 10  # Global variable

def modify():
    global x
    x = 20  # Modifies global variable

modify()
print(x)  # 20
```

#### **Nested Functions and Closures**  
```python
def outer():
    msg = "Hello"

    def inner():
        print(msg)  # Accessing outer function's variable

    inner()

outer()  # 'Hello'
```

**Key Points**  
- Use `def` to define functions and `return` to send back values.  
- Positional, keyword, default, `*args`, and `**kwargs` allow flexible argument passing.  
- Lambda functions provide concise one-liners.  
- Scope determines variable accessibility (`global`, `local`).  
- Functions improve code reusability and organization.

---

## Arguments  

Arguments are values passed to a function during its call. Python supports multiple types of arguments, providing flexibility in function usage.  

### **Positional Arguments**  
Arguments are assigned based on their position in the function call.  
```python
def greet(name, age):
    print(f"{name} is {age} years old.")

greet("Alice", 25)  # Output: Alice is 25 years old.
```

### **Keyword Arguments**  
Arguments are passed using parameter names, allowing flexibility in order.  
```python
greet(age=30, name="Bob")  # Output: Bob is 30 years old.
```

### **Default Arguments**  
If a value is not provided, the default parameter is used.  
```python
def greet(name="Guest"):
    print(f"Hello, {name}!")

greet()  # Output: Hello, Guest!
greet("Alice")  # Output: Hello, Alice!
```

### **Arbitrary Positional Arguments (`*args`)**  
Allows passing multiple positional arguments, stored as a tuple.  
```python
def sum_numbers(*args):
    return sum(args)

print(sum_numbers(1, 2, 3, 4))  # Output: 10
```

### **Arbitrary Keyword Arguments (`**kwargs`)**  
Allows passing multiple named arguments, stored as a dictionary.  
```python
def display_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

display_info(name="Alice", age=25, job="Engineer")
# Output:
# name: Alice
# age: 25
# job: Engineer
```

### **Combining Argument Types**  
Python allows combining all argument types in a function definition. The order should be: **positional arguments → `*args` → keyword arguments → `**kwargs`**.  
```python
def complete_info(name, age, *args, city="Unknown", **kwargs):
    print(f"{name} is {age} years old from {city}.")
    print("Additional Info:", args)
    print("More Details:", kwargs)

complete_info("Alice", 25, "Engineer", city="New York", hobby="Reading", language="English")
# Output:
# Alice is 25 years old from New York.
# Additional Info: ('Engineer',)
# More Details: {'hobby': 'Reading', 'language': 'English'}
```

**Key Points**  
- **Positional arguments** assign values based on order.  
- **Keyword arguments** explicitly specify parameter names.  
- **Default arguments** provide fallback values if omitted.  
- **`*args`** collects extra positional arguments as a tuple.  
- **`**kwargs`** collects extra keyword arguments as a dictionary.  
- Argument types can be combined, following the correct order.

---

## Return Values and Scope of Variables  

### **Return Values**  
A function can return a value using the `return` statement.  

#### **Returning a Single Value**  
```python
def square(num):
    return num * num

result = square(5)
print(result)  # Output: 25
```

#### **Returning Multiple Values**  
Python allows returning multiple values as a tuple.  
```python
def get_coordinates():
    return 10, 20

x, y = get_coordinates()
print(x, y)  # Output: 10 20
```

#### **Returning `None`**  
If no `return` statement is present, the function returns `None` by default.  
```python
def greet():
    print("Hello!")

result = greet()  # Output: Hello!
print(result)  # Output: None
```

---

### **Scope of Variables**  
Scope determines where a variable can be accessed within a program.  

#### **Local Scope**  
A variable declared inside a function is local to that function.  
```python
def example():
    x = 10  # Local variable
    print(x)

example()  # Output: 10
# print(x)  # Error: x is not defined outside the function
```

#### **Global Scope**  
A variable declared outside functions is global and accessible throughout the script.  
```python
x = 10  # Global variable

def example():
    print(x)  # Accessing global variable

example()  # Output: 10
```

#### **Modifying Global Variables Inside Functions**  
Use the `global` keyword to modify a global variable inside a function.  
```python
x = 10

def modify():
    global x
    x = 20  # Modifying global variable

modify()
print(x)  # Output: 20
```

#### **Nested Functions and Enclosing Scope**  
A function inside another function can access variables from the outer function (enclosing scope).  
```python
def outer():
    msg = "Hello"

    def inner():
        print(msg)  # Accessing outer function's variable

    inner()

outer()  # Output: Hello
```

#### **Nonlocal Variables**  
Use `nonlocal` to modify an enclosing function's variable inside a nested function.  
```python
def outer():
    x = 10

    def inner():
        nonlocal x
        x = 20  # Modifying enclosing function's variable

    inner()
    print(x)

outer()  # Output: 20
```

**Key Points**  
- **Functions return values using `return`**, defaulting to `None` if omitted.  
- **Local variables** exist only inside their function.  
- **Global variables** are accessible throughout the script but must be modified using `global`.  
- **Enclosing function variables** can be accessed in nested functions and modified using `nonlocal`.

---

## Lambda Functions  

Lambda functions are anonymous, single-expression functions defined using the `lambda` keyword. They are often used for short, simple operations where defining a full function is unnecessary.  

### **Syntax**  
```python
lambda arguments: expression
```
- Can take multiple arguments but only one expression.  
- The expression is evaluated and returned automatically.  

### **Basic Example**  
```python
square = lambda x: x**2
print(square(5))  # Output: 25
```

### **Multiple Arguments**  
```python
add = lambda a, b: a + b
print(add(3, 4))  # Output: 7
```

### **Lambda with `map()`**  
`map()` applies a function to each item in an iterable.  
```python
numbers = [1, 2, 3, 4]
squared = list(map(lambda x: x**2, numbers))
print(squared)  # Output: [1, 4, 9, 16]
```

### **Lambda with `filter()`**  
`filter()` selects elements that satisfy a condition.  
```python
numbers = [1, 2, 3, 4, 5, 6]
evens = list(filter(lambda x: x % 2 == 0, numbers))
print(evens)  # Output: [2, 4, 6]
```

### **Lambda with `sorted()`**  
Used for custom sorting.  
```python
students = [("Alice", 25), ("Bob", 20), ("Charlie", 23)]
sorted_students = sorted(students, key=lambda x: x[1])
print(sorted_students)  # Output: [('Bob', 20), ('Charlie', 23), ('Alice', 25)]
```

### **Lambda in `reduce()`**  
`reduce()` from `functools` applies a function cumulatively.  
```python
from functools import reduce
numbers = [1, 2, 3, 4]
product = reduce(lambda x, y: x * y, numbers)
print(product)  # Output: 24
```

**Key Points**  
- **Lambda functions are anonymous and concise.**  
- **Used for short operations where defining a function is unnecessary.**  
- **Commonly used with `map()`, `filter()`, `sorted()`, and `reduce()`.**  
- **Cannot contain multiple expressions or statements.**

---

## Recursion  

Recursion is a programming technique where a function calls itself to solve smaller instances of a problem. It is useful for problems that can be broken down into simpler subproblems, such as factorial calculation, Fibonacci sequence, and tree traversal.  

### **Base Case and Recursive Case**  
Every recursive function must have:  
- **Base case** – Stops the recursion when a condition is met.  
- **Recursive case** – The function calls itself with a smaller problem.  

### **Factorial Example**  
```python
def factorial(n):
    if n == 0:  # Base case
        return 1
    return n * factorial(n - 1)  # Recursive case

print(factorial(5))  # Output: 120
```

### **Fibonacci Sequence**  
```python
def fibonacci(n):
    if n <= 1:  # Base case
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)  # Recursive case

print(fibonacci(6))  # Output: 8
```

### **Sum of a List**  
```python
def list_sum(lst):
    if not lst:  # Base case: empty list
        return 0
    return lst[0] + list_sum(lst[1:])  # Recursive case

print(list_sum([1, 2, 3, 4, 5]))  # Output: 15
```

### **Binary Search (Recursive)**  
```python
def binary_search(arr, target, low, high):
    if low > high:  # Base case: target not found
        return -1
    mid = (low + high) // 2
    if arr[mid] == target:
        return mid
    elif arr[mid] > target:
        return binary_search(arr, target, low, mid - 1)  # Search left half
    else:
        return binary_search(arr, target, mid + 1, high)  # Search right half

numbers = [1, 3, 5, 7, 9, 11]
print(binary_search(numbers, 7, 0, len(numbers) - 1))  # Output: 3
```

### **Tree Traversal (Recursive DFS)**  
```python
class Node:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None

def inorder_traversal(root):
    if root:
        inorder_traversal(root.left)
        print(root.value, end=" ")
        inorder_traversal(root.right)

# Example tree
root = Node(10)
root.left = Node(5)
root.right = Node(15)
inorder_traversal(root)  # Output: 5 10 15
```

### **Tail Recursion**  
Tail recursion optimizes recursive calls by eliminating the need for additional stack frames.  
```python
def tail_factorial(n, accumulator=1):
    if n == 0:
        return accumulator
    return tail_factorial(n - 1, n * accumulator)

print(tail_factorial(5))  # Output: 120
```

**Key Points**  
- **Recursion is useful for problems that can be divided into smaller subproblems.**  
- **Every recursive function must have a base case to avoid infinite recursion.**  
- **Can be memory-intensive due to function call stack growth.**  
- **Tail recursion reduces stack usage but is not optimized by Python.**  
- **Common use cases include factorials, Fibonacci, binary search, and tree traversal.**

---

## Importing Modules and Creating Custom Modules  

Modules in Python allow code reuse by organizing functions, classes, and variables into separate files. Python provides built-in modules, third-party modules, and user-defined custom modules.  

### **Importing Built-in Modules**  
Python includes many standard modules.  

#### **Importing the Entire Module**  
```python
import math
print(math.sqrt(16))  # Output: 4.0
```

#### **Importing Specific Functions**  
```python
from math import sqrt, pi
print(sqrt(25))  # Output: 5.0
print(pi)  # Output: 3.141592653589793
```

#### **Importing with an Alias**  
```python
import datetime as dt
print(dt.datetime.now())  # Output: Current date and time
```

#### **Importing All Functions (Not Recommended)**  
```python
from math import *  # Avoid using this; can cause conflicts
print(sin(0))  # Output: 0.0
```

---

### **Creating and Importing Custom Modules**  
A module is simply a `.py` file containing Python code.  

#### **Creating a Custom Module (`mymodule.py`)**  
```python
# mymodule.py
def greet(name):
    return f"Hello, {name}!"

PI = 3.14159
```

#### **Importing a Custom Module**  
```python
import mymodule
print(mymodule.greet("Alice"))  # Output: Hello, Alice!
print(mymodule.PI)  # Output: 3.14159
```

#### **Importing Specific Functions from a Module**  
```python
from mymodule import greet, PI
print(greet("Bob"))  # Output: Hello, Bob!
```

#### **Importing with an Alias**  
```python
import mymodule as mm
print(mm.greet("Charlie"))  # Output: Hello, Charlie!
```

---

### **Using `__name__ == "__main__"` in Modules**  
Modules can be used both as scripts and importable files.  
```python
# mymodule.py
def greet(name):
    return f"Hello, {name}!"

if __name__ == "__main__":
    print(greet("Tester"))  # Runs only when executed directly
```
```python
import mymodule  # This will not print anything from the `if __name__` block
```

---

### **Working with `sys.path` and Module Search Path**  
Python searches for modules in:  
1. The script's directory  
2. Installed packages (`site-packages`)  
3. Directories in `sys.path`  

#### **Checking Module Search Paths**  
```python
import sys
print(sys.path)
```

#### **Manually Adding a Custom Path**  
```python
import sys
sys.path.append("/path/to/directory")
import mymodule
```

---

## Packages  

A package in Python is a way of organizing multiple modules into a structured directory. It helps in managing large projects by grouping related modules together. A package is simply a directory containing multiple `.py` module files and an `__init__.py` file.  

### **Creating a Package**  
To create a package, follow this structure:  
```
mypackage/
│── __init__.py
│── module1.py
│── module2.py
│── subpackage/
│   │── __init__.py
│   │── submodule.py
```
- **`__init__.py`** – A special file that marks the directory as a package. It can be empty or contain initialization code.  
- **Modules (`.py` files)** – Contain reusable functions, classes, and variables.  

---

### **Creating a Basic Package**  
#### **Step 1: Create `mypackage/module1.py`**  
```python
# module1.py
def say_hello():
    return "Hello from module1!"
```

#### **Step 2: Create `mypackage/module2.py`**  
```python
# module2.py
def say_goodbye():
    return "Goodbye from module2!"
```

#### **Step 3: Create `mypackage/__init__.py`**  
```python
# __init__.py
from .module1 import say_hello
from .module2 import say_goodbye
```
This allows direct access to `say_hello` and `say_goodbye` when importing `mypackage`.  

---

### **Importing a Package**  
#### **Method 1: Import the Entire Package**  
```python
import mypackage
print(mypackage.say_hello())  # Output: Hello from module1!
print(mypackage.say_goodbye())  # Output: Goodbye from module2!
```

#### **Method 2: Import Specific Modules**  
```python
from mypackage import module1, module2
print(module1.say_hello())  # Output: Hello from module1!
print(module2.say_goodbye())  # Output: Goodbye from module2!
```

#### **Method 3: Import Functions Directly**  
```python
from mypackage.module1 import say_hello
print(say_hello())  # Output: Hello from module1!
```

---

### **Subpackages**  
A subpackage is a package inside another package.  

#### **Example Structure**  
```
mypackage/
│── __init__.py
│── module1.py
│── subpackage/
│   │── __init__.py
│   │── submodule.py
```

#### **Step 1: Create `mypackage/subpackage/submodule.py`**  
```python
# submodule.py
def sub_function():
    return "Hello from submodule!"
```

#### **Step 2: Import from the Subpackage**  
```python
import mypackage.subpackage.submodule
print(mypackage.subpackage.submodule.sub_function())  # Output: Hello from submodule!
```
OR  
```python
from mypackage.subpackage.submodule import sub_function
print(sub_function())  # Output: Hello from submodule!
```

---

### **Relative Imports in Packages**  
Relative imports use `.` notation to refer to modules within the same package.  

#### **Example: Using Relative Imports in `module1.py`**  
```python
# module1.py
from .module2 import say_goodbye  # Import from the same package

def greet_and_farewell():
    return say_goodbye()
```

#### **Using `..` to Import from a Parent Package in `subpackage/submodule.py`**  
```python
# submodule.py
from ..module1 import say_hello  # Import from parent package

def call_parent_function():
    return say_hello()
```

---

**Key Points**  
- **A package is a directory containing modules and an `__init__.py` file.**  
- **Modules inside a package can be imported using `import package.module`.**  
- **Subpackages allow further structuring of large projects.**  
- **Relative imports (`.` and `..`) help import within the same package.**  
- **Packages improve code organization, making large applications more maintainable.**

---

# File Handling

## Reading and Writing Files (Text and Binary)  

Python provides built-in functions to handle file operations, including reading and writing text and binary files.  

### **Opening Files**  
Use the `open()` function with different modes:  
- **`r`** – Read (default)  
- **`w`** – Write (overwrites existing content)  
- **`a`** – Append (adds to the end of the file)  
- **`x`** – Create (fails if the file exists)  
- **`b`** – Binary mode  
- **`t`** – Text mode (default)  
- **`+`** – Read and write  

```python
file = open("example.txt", "r")  # Open for reading (default mode)
file.close()
```

### **Reading Text Files**  
#### **Reading the Entire File**  
```python
with open("example.txt", "r") as file:
    content = file.read()
print(content)
```

#### **Reading Line by Line**  
```python
with open("example.txt", "r") as file:
    for line in file:
        print(line.strip())  # Strip removes newline characters
```

#### **Reading as a List of Lines**  
```python
with open("example.txt", "r") as file:
    lines = file.readlines()
print(lines)  # ['Line 1\n', 'Line 2\n']
```

### **Writing to Text Files**  
#### **Overwriting a File (`w` mode)**  
```python
with open("example.txt", "w") as file:
    file.write("Hello, World!\n")
```

#### **Appending to a File (`a` mode)**  
```python
with open("example.txt", "a") as file:
    file.write("Appending a new line.\n")
```

### **Working with Binary Files**  
#### **Writing Binary Data**  
```python
with open("binary.dat", "wb") as file:
    file.write(b'\x00\xFF\x10')  # Writing raw bytes
```

#### **Reading Binary Data**  
```python
with open("binary.dat", "rb") as file:
    data = file.read()
print(data)  # Output: b'\x00\xff\x10'
```

### **Handling File Exceptions**  
```python
try:
    with open("nonexistent.txt", "r") as file:
        content = file.read()
except FileNotFoundError:
    print("File not found.")
except IOError:
    print("Error reading file.")
```


**Key Points**  
- Use `with open()` to ensure files are properly closed.  
- `read()`, `readline()`, and `readlines()` provide different ways to read files.  
- `write()` and `writelines()` allow writing text or binary data.  
- Handle exceptions using `try-except` to avoid errors.

---

## File Methods  

Python provides various methods for working with files using the `file` object returned by `open()`.  

### **Opening a File**  
```python
file = open("example.txt", "r")  # Open a file in read mode
```

### **Reading Methods**  
#### **`read(size)`** – Reads the entire file or a specific number of bytes.  
```python
with open("example.txt", "r") as file:
    content = file.read(10)  # Reads first 10 characters
    print(content)
```

#### **`readline()`** – Reads a single line.  
```python
with open("example.txt", "r") as file:
    line = file.readline()
    print(line)  # Prints the first line
```

#### **`readlines()`** – Reads all lines into a list.  
```python
with open("example.txt", "r") as file:
    lines = file.readlines()
print(lines)  # ['Line 1\n', 'Line 2\n']
```

### **Writing Methods**  
#### **`write(string)`** – Writes a string to the file.  
```python
with open("example.txt", "w") as file:
    file.write("Hello, world!\n")
```

#### **`writelines(lines)`** – Writes a list of strings.  
```python
lines = ["Line 1\n", "Line 2\n"]
with open("example.txt", "w") as file:
    file.writelines(lines)
```

### **Cursor Positioning Methods**  
#### **`seek(offset, whence)`** – Moves the cursor.  
- `whence=0` (default) – Start of file  
- `whence=1` – Current position  
- `whence=2` – End of file  
```python
with open("example.txt", "r") as file:
    file.seek(5)  # Move to the 5th byte
    print(file.read(5))  # Read 5 bytes
```

#### **`tell()`** – Returns the current cursor position.  
```python
with open("example.txt", "r") as file:
    print(file.tell())  # 0 (start)
    file.read(5)
    print(file.tell())  # 5 (after reading 5 characters)
```

### **Flushing and Closing**  
#### **`flush()`** – Forces writing data to disk.  
```python
with open("example.txt", "w") as file:
    file.write("Data not yet saved.")
    file.flush()  # Ensures data is written immediately
```

#### **`close()`** – Closes the file.  
```python
file = open("example.txt", "r")
file.close()  # Release system resources
```

### **Checking File Properties**  
#### **`name`** – Returns the file name.  
```python
with open("example.txt", "r") as file:
    print(file.name)  # example.txt
```

#### **`mode`** – Returns the file mode.  
```python
with open("example.txt", "r") as file:
    print(file.mode)  # r
```

#### **`closed`** – Returns `True` if the file is closed.  
```python
file = open("example.txt", "r")
print(file.closed)  # False
file.close()
print(file.closed)  # True
```

**Key Points**  
- `read()`, `readline()`, and `readlines()` handle reading operations.  
- `write()` and `writelines()` allow writing strings and lists.  
- `seek()` and `tell()` manage file cursor positioning.  
- `flush()` ensures data is saved immediately.  
- `close()` releases file resources.  
- `name`, `mode`, and `closed` provide file metadata.

---

## File Modes  

Python’s `open()` function supports multiple file modes that determine how a file is accessed. The mode is specified as the second argument in `open(filename, mode)`.  

### **Text File Modes**  
- **`r`** – Read mode (default). The file must exist.  
- **`w`** – Write mode. Creates a new file or overwrites an existing file.  
- **`a`** – Append mode. Creates a file if it does not exist; otherwise, appends to it.  
- **`x`** – Exclusive creation mode. Fails if the file already exists.  

```python
# Reading a file
with open("example.txt", "r") as file:
    content = file.read()

# Writing to a file (overwrites existing content)
with open("example.txt", "w") as file:
    file.write("New content")

# Appending to a file
with open("example.txt", "a") as file:
    file.write("\nAdditional content")

# Creating a file (fails if it already exists)
with open("newfile.txt", "x") as file:
    file.write("This file was just created.")
```

### **Binary File Modes**  
Same as text modes but with **`b`** for binary data (e.g., images, videos).  
- **`rb`** – Read binary file.  
- **`wb`** – Write binary file.  
- **`ab`** – Append to a binary file.  
- **`xb`** – Create a new binary file.  

```python
# Writing binary data
with open("image.jpg", "wb") as file:
    file.write(b'\x89PNG\r\n')

# Reading binary data
with open("image.jpg", "rb") as file:
    data = file.read()
```

### **Read and Write Modes**  
- **`r+`** – Read and write. File must exist.  
- **`w+`** – Write and read. Overwrites existing content.  
- **`a+`** – Append and read. Creates file if it does not exist.  
- **`rb+`**, **`wb+`**, **`ab+`** – Binary versions of `r+`, `w+`, `a+`.  

```python
# Read and write (without truncating file)
with open("example.txt", "r+") as file:
    print(file.read())  # Read existing content
    file.write("\nNew line")  # Write additional content

# Write and read (overwrites file)
with open("example.txt", "w+") as file:
    file.write("Replaced content")
    file.seek(0)
    print(file.read())  # Read the new content
```

**Key Points**  
- Use **`r`** for reading (file must exist).  
- Use **`w`** for writing (erases existing content).  
- Use **`a`** to append (keeps existing content).  
- Use **`x`** to create a file (fails if it exists).  
- Append **`b`** for binary files.  
- Modes like **`r+`**, **`w+`**, and **`a+`** allow both reading and writing.

---

## Working with CSV and JSON Files  

Python provides built-in modules for handling CSV (`csv` module) and JSON (`json` module) files.  

### **Working with CSV Files**  

#### **Reading CSV Files**  
Use `csv.reader()` to read CSV files.  

```python
import csv

with open("data.csv", "r", newline="") as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)  # Each row is a list
```

#### **Reading CSV as Dictionary**  
Use `csv.DictReader()` to read CSV files into dictionaries.  

```python
with open("data.csv", "r", newline="") as file:
    reader = csv.DictReader(file)
    for row in reader:
        print(row["name"], row["age"])  # Access by column name
```

#### **Writing to CSV Files**  
Use `csv.writer()` to write lists to CSV files.  

```python
with open("data.csv", "w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(["Name", "Age"])
    writer.writerows([["Alice", 25], ["Bob", 30]])
```

#### **Writing Dictionary to CSV**  
Use `csv.DictWriter()` to write dictionaries.  

```python
data = [{"Name": "Alice", "Age": 25}, {"Name": "Bob", "Age": 30}]

with open("data.csv", "w", newline="") as file:
    writer = csv.DictWriter(file, fieldnames=["Name", "Age"])
    writer.writeheader()
    writer.writerows(data)
```

### **Working with JSON Files**  

#### **Reading JSON Files**  
Use `json.load()` to read JSON data from a file.  

```python
import json

with open("data.json", "r") as file:
    data = json.load(file)
print(data)  # Dictionary or list
```

#### **Writing JSON Files**  
Use `json.dump()` to write data to a JSON file.  

```python
data = {"name": "Alice", "age": 25}

with open("data.json", "w") as file:
    json.dump(data, file, indent=4)  # Pretty-print JSON
```

#### **Converting Between JSON and Python Objects**  
Use `json.dumps()` and `json.loads()` to convert between JSON strings and Python objects.  

```python
json_string = json.dumps(data)  # Convert dictionary to JSON string
print(json_string)

python_dict = json.loads(json_string)  # Convert JSON string to dictionary
print(python_dict)
```

**Key Points**  
- Use `csv.reader()` and `csv.DictReader()` for reading CSV files.  
- Use `csv.writer()` and `csv.DictWriter()` for writing CSV files.  
- Use `json.load()` to read JSON files and `json.dump()` to write JSON files.  
- Use `json.dumps()` and `json.loads()` to convert between JSON and Python objects.

---

# Object-Oriented Programming (OOP)

## Classes and Objects  

Python is an object-oriented programming (OOP) language, where everything is an object. Classes define blueprints for creating objects.  

### **Defining a Class**  
A class is created using the `class` keyword.  

```python
class Person:
    def __init__(self, name, age):  # Constructor
        self.name = name
        self.age = age

    def greet(self):  # Method
        return f"Hello, my name is {self.name} and I am {self.age} years old."

# Creating an object
person1 = Person("Alice", 25)
print(person1.greet())
```

### **Instance and Class Attributes**  
- **Instance attributes** are unique to each object.  
- **Class attributes** are shared among all instances.  

```python
class Car:
    wheels = 4  # Class attribute

    def __init__(self, brand):
        self.brand = brand  # Instance attribute

car1 = Car("Toyota")
car2 = Car("Honda")

print(car1.wheels, car1.brand)  # 4 Toyota
print(car2.wheels, car2.brand)  # 4 Honda
```

### **Instance and Class Methods**  
- **Instance methods** (`self`) operate on instance attributes.  
- **Class methods** (`cls`) operate on class attributes.  
- **Static methods** do not depend on class or instance attributes.  

```python
class Animal:
    species = "Mammal"

    def __init__(self, name):
        self.name = name

    def instance_method(self):
        return f"{self.name} is a {self.species}"

    @classmethod
    def class_method(cls):
        return f"All are {cls.species}"

    @staticmethod
    def static_method():
        return "Animals exist."

print(Animal.class_method())
print(Animal.static_method())

animal = Animal("Dog")
print(animal.instance_method())
```

### **Encapsulation (Access Modifiers)**  
Python uses naming conventions for access control:  
- `_protected` – Can be accessed but not recommended.  
- `__private` – Name-mangled to prevent accidental access.  

```python
class BankAccount:
    def __init__(self, balance):
        self._balance = balance  # Protected
        self.__pin = "1234"  # Private

    def get_balance(self):
        return self._balance

account = BankAccount(1000)
print(account.get_balance())  # 1000
# print(account.__pin)  # AttributeError: Cannot access private variable
```

### **Inheritance**  
A child class inherits from a parent class.  

```python
class Vehicle:
    def __init__(self, brand):
        self.brand = brand

    def info(self):
        return f"This is a {self.brand}."

class Car(Vehicle):
    def __init__(self, brand, model):
        super().__init__(brand)  # Call parent constructor
        self.model = model

    def info(self):
        return f"This is a {self.brand} {self.model}."

car = Car("Toyota", "Camry")
print(car.info())
```

### **Method Overriding**  
A subclass can override a parent class method.  

```python
class Parent:
    def show(self):
        return "Parent method"

class Child(Parent):
    def show(self):
        return "Child method"

child = Child()
print(child.show())  # Child method
```

### **Polymorphism**  
Different classes can share the same method name but behave differently.  

```python
class Cat:
    def sound(self):
        return "Meow"

class Dog:
    def sound(self):
        return "Bark"

animals = [Cat(), Dog()]
for animal in animals:
    print(animal.sound())
```

**Key Points**  
- Classes define blueprints for objects.  
- Use `self` to refer to instance attributes.  
- Use `@classmethod` for class-wide methods and `@staticmethod` for independent functions.  
- `_protected` and `__private` control access levels.  
- Use `super()` to call parent methods in inheritance.  
- Polymorphism allows different objects to share method names.

---

## Instance Variables and Class Variables  

### **Instance Variables**  
- Defined inside the constructor (`__init__`) using `self`.  
- Unique to each instance of the class.  
- Changing an instance variable affects only that specific object.  

```python
class Person:
    def __init__(self, name, age):
        self.name = name  # Instance variable
        self.age = age    # Instance variable

person1 = Person("Alice", 25)
person2 = Person("Bob", 30)

print(person1.name, person1.age)  # Alice 25
print(person2.name, person2.age)  # Bob 30

person1.age = 26  # Modifies only person1's age
print(person1.age)  # 26
print(person2.age)  # 30
```

### **Class Variables**  
- Defined outside `__init__`, at the class level.  
- Shared among all instances of the class.  
- Changing a class variable affects all instances (unless overridden by an instance).  

```python
class Car:
    wheels = 4  # Class variable (shared)

    def __init__(self, brand):
        self.brand = brand  # Instance variable

car1 = Car("Toyota")
car2 = Car("Honda")

print(car1.wheels, car1.brand)  # 4 Toyota
print(car2.wheels, car2.brand)  # 4 Honda

Car.wheels = 6  # Modifies the class variable
print(car1.wheels)  # 6
print(car2.wheels)  # 6
```

### **Overriding Class Variables with Instance Variables**  
If an instance assigns a new value to a class variable, it creates a separate instance variable instead of modifying the class variable.  

```python
car1.wheels = 5  # Creates an instance variable for car1 only
print(car1.wheels)  # 5
print(car2.wheels)  # 6 (still using the class variable)
```

### **Accessing Class Variables Using Class Methods**  
Class methods (`@classmethod`) can modify class variables.  

```python
class Employee:
    company = "TechCorp"  # Class variable

    def __init__(self, name):
        self.name = name  # Instance variable

    @classmethod
    def change_company(cls, new_company):
        cls.company = new_company  # Modify class variable

Employee.change_company("NewTech")  # Changes for all instances
emp1 = Employee("Alice")
emp2 = Employee("Bob")

print(emp1.company)  # NewTech
print(emp2.company)  # NewTech
```

**Key Points**  
- **Instance variables** are unique to each object (`self.var`).  
- **Class variables** are shared across all instances (`ClassName.var`).  
- Changing a class variable affects all instances unless overridden at the instance level.  
- **Class methods** (`@classmethod`) modify class variables for all instances.

---

## Instance Variables and Class Variables  

### **Instance Variables**  
- Defined inside the constructor (`__init__`) using `self`.  
- Unique to each instance of the class.  
- Changing an instance variable affects only that specific object.  

```python
class Person:
    def __init__(self, name, age):
        self.name = name  # Instance variable
        self.age = age    # Instance variable

person1 = Person("Alice", 25)
person2 = Person("Bob", 30)

print(person1.name, person1.age)  # Alice 25
print(person2.name, person2.age)  # Bob 30

person1.age = 26  # Modifies only person1's age
print(person1.age)  # 26
print(person2.age)  # 30
```

### **Class Variables**  
- Defined outside `__init__`, at the class level.  
- Shared among all instances of the class.  
- Changing a class variable affects all instances (unless overridden by an instance).  

```python
class Car:
    wheels = 4  # Class variable (shared)

    def __init__(self, brand):
        self.brand = brand  # Instance variable

car1 = Car("Toyota")
car2 = Car("Honda")

print(car1.wheels, car1.brand)  # 4 Toyota
print(car2.wheels, car2.brand)  # 4 Honda

Car.wheels = 6  # Modifies the class variable
print(car1.wheels)  # 6
print(car2.wheels)  # 6
```

### **Overriding Class Variables with Instance Variables**  
If an instance assigns a new value to a class variable, it creates a separate instance variable instead of modifying the class variable.  

```python
car1.wheels = 5  # Creates an instance variable for car1 only
print(car1.wheels)  # 5
print(car2.wheels)  # 6 (still using the class variable)
```

### **Accessing Class Variables Using Class Methods**  
Class methods (`@classmethod`) can modify class variables.  

```python
class Employee:
    company = "TechCorp"  # Class variable

    def __init__(self, name):
        self.name = name  # Instance variable

    @classmethod
    def change_company(cls, new_company):
        cls.company = new_company  # Modify class variable

Employee.change_company("NewTech")  # Changes for all instances
emp1 = Employee("Alice")
emp2 = Employee("Bob")

print(emp1.company)  # NewTech
print(emp2.company)  # NewTech
```

**Key Points**  
- **Instance variables** are unique to each object (`self.var`).  
- **Class variables** are shared across all instances (`ClassName.var`).  
- Changing a class variable affects all instances unless overridden at the instance level.  
- **Class methods** (`@classmethod`) modify class variables for all instances.

---

## Methods (Instance, Class, and Static Methods)  

### **Instance Methods**  
- These methods operate on the instance of the class (object).  
- They always take the instance as the first argument (`self`).  
- Instance methods can access and modify instance variables and class variables.

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def greet(self):  # Instance method
        return f"Hello, my name is {self.name} and I am {self.age} years old."

# Creating an instance
person = Person("Alice", 25)
print(person.greet())  # Hello, my name is Alice and I am 25 years old.
```

### **Class Methods**  
- These methods operate on the class itself, not on instances.  
- They take the class as the first argument (`cls`).  
- Class methods are often used to modify or interact with class-level variables and can be called on the class itself or an instance.

```python
class Person:
    species = "Human"  # Class variable

    def __init__(self, name, age):
        self.name = name
        self.age = age

    @classmethod
    def species_info(cls):  # Class method
        return f"All persons are {cls.species}."

# Using class method
print(Person.species_info())  # All persons are Human

person = Person("Alice", 25)
print(person.species_info())  # All persons are Human
```

### **Static Methods**  
- These methods do not operate on the instance or the class.  
- They do not take `self` or `cls` as the first argument.  
- Static methods are used for utility functions that don't modify or depend on the class or instance variables.

```python
class MathOperations:
    
    @staticmethod
    def add(x, y):  # Static method
        return x + y

    @staticmethod
    def multiply(x, y):  # Static method
        return x * y

# Using static methods
print(MathOperations.add(5, 3))  # 8
print(MathOperations.multiply(5, 3))  # 15
```

**Key Points**  
- **Instance methods**: Use `self` to access and modify instance attributes and call other methods in the instance.  
- **Class methods**: Use `cls` to access and modify class attributes, often for creating alternate constructors or modifying class state.  
- **Static methods**: Do not take `self` or `cls`; used for functions that do not require access to instance or class data.

---

## Constructors and Destructors (`__init__` and `__del__`)  

In Python, constructors and destructors are special methods used to initialize and clean up objects. These methods are invoked when an object is created or destroyed.  

### **Constructor (`__init__`)**  
- The `__init__()` method is called automatically when a new object of a class is created.  
- It is used to initialize the object's attributes or perform any setup needed when the object is created.  
- It takes `self` as the first argument, and any other arguments passed during object creation.

```python
class Person:
    def __init__(self, name, age):  # Constructor
        self.name = name
        self.age = age

    def greet(self):
        return f"Hello, my name is {self.name} and I am {self.age} years old."

# Creating an object
person = Person("Alice", 25)
print(person.greet())  # Hello, my name is Alice and I am 25 years old.
```

### **Destructor (`__del__`)**  
- The `__del__()` method is called when an object is about to be destroyed or garbage collected.  
- It is used to clean up any resources, such as closing files or network connections, that were opened during the object's life.  
- Python's garbage collector handles memory management, but `__del__()` can be useful for manual cleanup.

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age
        print(f"Person {self.name} created.")

    def __del__(self):  # Destructor
        print(f"Person {self.name} is being destroyed.")

# Creating and deleting an object
person = Person("Alice", 25)  # Person Alice created.
del person  # Person Alice is being destroyed.
```

### **Important Notes About Destructors**  
- The `__del__()` method is not guaranteed to be called immediately after `del` is used. Python's garbage collector handles object destruction, so it may not be called right away.
- If there are circular references or complex object graphs, `__del__()` may not be called as expected. In such cases, Python might not invoke `__del__()` until the program ends.  

### **Example with Destructor and Resource Cleanup**  
A destructor is particularly useful for cleaning up resources like files or network connections.

```python
class FileHandler:
    def __init__(self, filename):
        self.filename = filename
        self.file = open(self.filename, 'w')  # Open a file for writing
        print(f"File {self.filename} opened.")

    def write(self, content):
        self.file.write(content)

    def __del__(self):  # Destructor
        if self.file:
            self.file.close()  # Close the file
            print(f"File {self.filename} closed.")

# Creating an object and using it
file_handler = FileHandler("test.txt")
file_handler.write("Hello, World!")
del file_handler  # File test.txt closed.
```

**Key Points**  
- **`__init__()`**: The constructor initializes the object and is called when the object is created.  
- **`__del__()`**: The destructor is called when the object is about to be destroyed. It is used to perform cleanup tasks, like closing files or network connections.  
- Destructors are managed by Python's garbage collection, so their execution is not always immediate after `del`.

---

## Inheritance and Method Overriding  

### **Inheritance**  
Inheritance allows a class to inherit attributes and methods from another class. This promotes code reuse and a hierarchical relationship between classes. A subclass (child class) can inherit from a superclass (parent class) and extend or modify its behavior.

- A **child class** can inherit methods and attributes from a **parent class**.
- It can also override or add new methods to extend the functionality.

```python
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):  # Method in parent class
        return "Animal sound"

class Dog(Animal):  # Inheriting from Animal class
    def __init__(self, name, breed):
        super().__init__(name)  # Calling parent constructor
        self.breed = breed

    def speak(self):  # Method overriding
        return f"{self.name} says Woof!"

# Creating an instance of the child class
dog = Dog("Buddy", "Golden Retriever")
print(dog.speak())  # Buddy says Woof!
```

### **Using `super()` in Inheritance**  
The `super()` function is used to call a method from the parent class. It is commonly used in the constructor to initialize attributes from the parent class.

```python
class Person:
    def __init__(self, name):
        self.name = name

class Employee(Person):
    def __init__(self, name, job):
        super().__init__(name)  # Call parent constructor
        self.job = job

emp = Employee("John", "Software Developer")
print(emp.name)  # John
print(emp.job)  # Software Developer
```

### **Method Overriding**  
Method overriding occurs when a child class provides a specific implementation for a method that is already defined in the parent class. This allows the child class to alter or extend the behavior of the parent class.

```python
class Animal:
    def speak(self):
        return "Some sound"

class Cat(Animal):
    def speak(self):  # Overriding parent method
        return "Meow"

class Dog(Animal):
    def speak(self):  # Overriding parent method
        return "Woof"

# Creating instances
cat = Cat()
dog = Dog()

print(cat.speak())  # Meow
print(dog.speak())  # Woof
```

### **Overriding Methods with Arguments**  
You can override methods and change their implementation, including how they handle parameters. However, the method signature (name and arguments) should match the parent class method unless you are designing it differently.

```python
class Animal:
    def make_sound(self, sound="generic sound"):
        return f"Animal makes a {sound}"

class Dog(Animal):
    def make_sound(self, sound="bark"):
        return f"Dog barks: {sound}"

# Creating an instance
dog = Dog()
print(dog.make_sound())  # Dog barks: bark
print(dog.make_sound("growl"))  # Dog barks: growl
```

**Key Points**  
- **Inheritance**: Allows a child class to inherit attributes and methods from a parent class.
- **Method overriding**: The child class can override a method from the parent class to provide its own implementation.
- Use `super()` to call the parent class's methods or constructor from the child class.
- Method overriding enables a child class to customize the inherited behavior, making it more specific to the subclass's needs.

---

## Polymorphism and Encapsulation  

### **Polymorphism**  
Polymorphism is the ability of different classes to implement the same method or function in different ways. This allows objects of different types to be treated as instances of the same class through a shared interface.

- **Method Overloading**: Having multiple methods with the same name but different parameters.
- **Method Overriding**: Inheritance allows a subclass to override the method of a superclass, providing a different implementation.

#### **Method Overriding (Runtime Polymorphism)**  
Method overriding occurs when a subclass provides a specific implementation of a method that is already defined in the superclass.

```python
class Animal:
    def sound(self):
        return "Some generic sound"

class Dog(Animal):
    def sound(self):  # Overriding parent method
        return "Bark"

class Cat(Animal):
    def sound(self):  # Overriding parent method
        return "Meow"

# Polymorphic behavior
def make_sound(animal: Animal):
    print(animal.sound())

dog = Dog()
cat = Cat()

make_sound(dog)  # Bark
make_sound(cat)  # Meow
```

In the example above, the method `sound()` is overridden in both `Dog` and `Cat` classes, and the correct method is called based on the object type (`dog` or `cat`).

#### **Polymorphism with Inheritance**  
Polymorphism is commonly used with inheritance, where different subclasses can provide their own implementation of a common method from the base class.

```python
class Shape:
    def area(self):
        pass  # To be implemented by subclasses

class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return 3.14 * self.radius * self.radius

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height

    def area(self):
        return self.width * self.height

# Polymorphic behavior
shapes = [Circle(5), Rectangle(4, 6)]

for shape in shapes:
    print(f"Area: {shape.area()}")
```

In this case, the method `area()` is polymorphic, and different types of shapes (Circle and Rectangle) use their own implementation of the method.

### **Encapsulation**  
Encapsulation is the concept of bundling data (attributes) and methods (functions) that operate on the data into a single unit or class. It also restricts access to certain components of the object, meaning some internal details are hidden from the outside world. 

- **Public attributes/methods**: Accessible from outside the class.
- **Private attributes/methods**: Not directly accessible from outside the class (use of underscores or properties to hide implementation).

#### **Public and Private Members**  
In Python, by convention, a single underscore (`_`) before an attribute indicates that it is intended for internal use, but it is still accessible. A double underscore (`__`) makes the attribute private, which name-mangles it, making it harder to access directly.

```python
class Person:
    def __init__(self, name, age):
        self.name = name  # Public attribute
        self.__age = age  # Private attribute

    def get_age(self):  # Public method to access private data
        return self.__age

    def set_age(self, age):  # Public method to modify private data
        if age >= 0:
            self.__age = age
        else:
            print("Age cannot be negative.")

person = Person("Alice", 25)
print(person.name)  # Public attribute can be accessed
print(person.get_age())  # Accessing private attribute through public method

# person.__age  # This would raise an AttributeError due to name mangling
person.set_age(30)  # Setting a new valid age
print(person.get_age())  # 30
```

In the above example:
- `__age` is a private attribute, and it is not directly accessible from outside the class.  
- We use getter (`get_age()`) and setter (`set_age()`) methods to interact with it, ensuring that the age is valid.

#### **Encapsulation Using Properties**  
Instead of directly accessing attributes, we can use properties to control access to them. This allows us to define getter, setter, and deleter methods in a more Pythonic way.

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.__age = age

    @property
    def age(self):  # Getter
        return self.__age

    @age.setter
    def age(self, value):  # Setter
        if value >= 0:
            self.__age = value
        else:
            print("Age cannot be negative.")

    @age.deleter
    def age(self):  # Deleter
        print("Age deleted.")
        del self.__age

person = Person("Alice", 25)
print(person.age)  # 25 (getter)
person.age = 30  # Setting a new age (setter)
print(person.age)  # 30 (getter)

del person.age  # Age deleted. Attribute removed.
```

**Key Points**  
- **Polymorphism**: Allows methods with the same name to behave differently based on the object’s class. Achieved through method overriding.
- **Encapsulation**: Hides the internal state of an object and only exposes necessary functionality through public methods.  
- Use **getter/setter methods** or **properties** to manage access to private attributes.  
- **Polymorphism** and **encapsulation** work together to enhance flexibility and maintainability in object-oriented programming.

---

## Magic Methods  

Magic methods (also called dunder methods, due to their double underscores) are special methods in Python that allow you to define how objects of a class behave when they interact with built-in operators or functions. These methods are predefined in Python and provide a way to implement operator overloading, object comparison, object representation, and other custom behaviors.

### **`__init__(self)`**  
- The **constructor** method, automatically called when an object is instantiated.  
- Used to initialize the object's attributes.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

obj = MyClass(10)
print(obj.value)  # 10
```

### **`__str__(self)`**  
- The `__str__` method returns a string representation of the object.  
- Used by the `str()` function and when printing an object.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return f"MyClass with value {self.value}"

obj = MyClass(10)
print(str(obj))  # MyClass with value 10
```

### **`__repr__(self)`**  
- The `__repr__` method returns a string that represents the object in a way that could potentially be used to recreate the object (often more detailed than `__str__`).  
- Used by the `repr()` function and for object representation in interactive interpreters.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __repr__(self):
        return f"MyClass({self.value})"

obj = MyClass(10)
print(repr(obj))  # MyClass(10)
```

### **`__format__(self, format_spec)`**

- The `__format__` method allows you to define custom formatting behavior for the object when using the `format()` function or `f-string`.
- It is often used to control how an object is displayed or converted to a string.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __format__(self, format_spec):  # Custom formatting
        return f"Value: {self.value:{format_spec}}"

obj = MyClass(10)
print(format(obj, "04d"))  # Value: 0010
```

### **`__add__(self, other)`**  
- The `__add__` method allows you to define the behavior of the `+` operator for your objects.  
- It is called when you use the `+` operator between two objects of the class.

```python
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, other):  # Overloading '+' operator
        return Point(self.x + other.x, self.y + other.y)

    def __repr__(self):
        return f"Point({self.x}, {self.y})"

point1 = Point(1, 2)
point2 = Point(3, 4)
result = point1 + point2
print(result)  # Point(4, 6)
```

### **`__eq__(self, other)`**  
- The `__eq__` method allows you to define the behavior of the equality operator (`==`).  
- It is called when you use `==` to compare two objects of the class.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __eq__(self, other):  # Overloading '==' operator
        return self.value == other.value

obj1 = MyClass(10)
obj2 = MyClass(10)
print(obj1 == obj2)  # True
```

### **`__ne__(self, other)`**

- The `__ne__` method defines the behavior for the inequality operator `!=`.
- It is used to compare objects for inequality and should return `True` if they are considered unequal, otherwise `False`.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __ne__(self, other):  # Comparing inequality
        if isinstance(other, MyClass):
            return self.value != other.value
        return True

obj1 = MyClass(10)
obj2 = MyClass(20)

print(obj1 != obj2)  # True
```

### **`__lt__(self, other)`**  
- The `__lt__` method allows you to define the behavior of the less than operator (`<`).  
- It is called when you use `<` to compare two objects of the class.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __lt__(self, other):  # Overloading '<' operator
        return self.value < other.value

obj1 = MyClass(5)
obj2 = MyClass(10)
print(obj1 < obj2)  # True
```

### **`__le__(self, other)`**

- The `__le__` method defines the behavior for the less-than-or-equal-to operator `<=`.
- It is used to compare objects for "less than or equal to."

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __le__(self, other):  # Less-than-or-equal-to comparison
        if isinstance(other, MyClass):
            return self.value <= other.value
        return NotImplemented

obj1 = MyClass(10)
obj2 = MyClass(20)

print(obj1 <= obj2)  # True
```

### **`__gt__(self, other)`**

- The `__gt__` method defines the behavior for the greater-than operator `>`.
- It is used to compare two objects for "greater than."

### **`__ge__(self, other)`**

- The `__ge__` method defines the behavior for the greater-than-or-equal-to operator `>=`.
- It is used to compare objects for "greater than or equal to."

### **`__len__(self)`**  
- The `__len__` method defines the behavior of the `len()` function.  
- It returns the length of the object.

```python
class MyClass:
    def __init__(self, values):
        self.values = values

    def __len__(self):  # Overloading len() function
        return len(self.values)

obj = MyClass([1, 2, 3, 4])
print(len(obj))  # 4
```

### **`__getitem__(self, key)`**  
- The `__getitem__` method allows you to define how items are accessed using square brackets `[]`.  
- It is called when you use the indexing operator (`[]`) to get an item from the object.

```python
class MyClass:
    def __init__(self, values):
        self.values = values

    def __getitem__(self, key):  # Overloading '[]' operator
        return self.values[key]

obj = MyClass([10, 20, 30])
print(obj[1])  # 20
```

### **`__setitem__(self, key, value)`**  
- The `__setitem__` method allows you to define how items are set using square brackets `[]`.  
- It is called when you use the indexing operator (`[]`) to assign a value to an item in the object.

```python
class MyClass:
    def __init__(self, values):
        self.values = values

    def __setitem__(self, key, value):  # Overloading '[]' assignment
        self.values[key] = value

obj = MyClass([1, 2, 3])
obj[1] = 10
print(obj.values)  # [1, 10, 3]
```

### **`__delitem__(self, key)`**  
- The `__delitem__` method allows you to define the behavior of the `del` operator when trying to delete an item from an object using square brackets `[]`.  
- It is called when `del` is used to remove an item from an object.

```python
class MyClass:
    def __init__(self, values):
        self.values = values

    def __delitem__(self, key):  # Overloading 'del' operator
        del self.values[key]

obj = MyClass([1, 2, 3])
del obj[1]
print(obj.values)  # [1, 3]
```

### **`__del__(self)`**  
- The `__del__` method is called when an object is about to be destroyed.  
- It is used for cleanup actions like closing files or releasing resources.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __del__(self):  # Destructor
        print(f"MyClass object with value {self.value} is being deleted.")

obj = MyClass(10)
del obj  # MyClass object with value 10 is being deleted.
```

### **`__call__(self, *args, **kwargs)`**  
- The `__call__` method allows an object of a class to be called as if it were a function.  
- It enables an object to behave like a function, accepting arguments and returning a value.

```python
class MyClass:
    def __init__(self, multiplier):
        self.multiplier = multiplier

    def __call__(self, value):
        return self.multiplier * value

obj = MyClass(5)
print(obj(10))  # 50 (calling the object like a function)
```

### **`__contains__(self, item)`**  
- The `__contains__` method allows you to define the behavior of the `in` operator for checking membership.  
- It is called when you use `in` to check if an item exists in the object.

```python
class MyClass:
    def __init__(self, values):
        self.values = values

    def __contains__(self, item):  # Overloading 'in' operator
        return item in self.values

obj = MyClass([1, 2, 3, 4])
print(3 in obj)  # True
print(5 in obj)  # False
```

### **`__iter__(self)`**  
- The `__iter__` method is used to make an object iterable (i.e., able to be used in a for-loop).  
- It returns an iterator object that defines the `__next__` method.

```python
class MyClass:
    def __init__(self, values):
        self.values = values
        self.index = 0

    def __iter__(self):  # Making object iterable
        return self

    def __next__(self):
        if self.index < len(self.values):
            result = self.values[self.index]
            self.index += 1
            return result
        else:
            raise StopIteration

obj = MyClass([1, 2, 3])
for val in obj:
    print(val)  # 1, 2, 3
```

### **`__next__(self)`**  
- The `__next__` method works with `__iter__` to allow iteration.  
- It retrieves the next item from an iterable object and raises `StopIteration` when the iteration is complete.

```python
class MyClass:
    def __init__(self, values):
        self.values = values
        self.index = 0

    def __iter__(self):  # Making object iterable
        return self

    def __next__(self):
        if self.index < len(self.values):
            result = self.values[self.index]
            self.index += 1
            return result
        else:
            raise StopIteration

obj = MyClass([1, 2, 3])
iterator = iter(obj)
print(next(iterator))  # 1
print(next(iterator))  # 2
print(next(iterator))  # 3
# print(next(iterator))  # Raises StopIteration
```

### **`__setattr__(self, name, value)`**  
- The `__setattr__` method is called when an attribute is being set.  
- It allows you to customize the assignment of attributes in an object.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __setattr__(self, name, value):  # Overloading attribute assignment
        if name == 'value' and value < 0:
            print("Cannot set value to a negative number!")
        else:
            super().__setattr__(name, value)

obj = MyClass(10)
obj.value = -5  # Cannot set value to a negative number!
obj.value = 20  # Attribute set successfully
```

The `super()` function is used to call methods from a parent class. When overriding the `__setattr__` method, it's necessary to call `super().__setattr__(name, value)` to ensure that the base class's `__setattr__` method (usually the one from `object`) is still invoked and the attribute is properly set.

Without `super()`, the custom `__setattr__` method would handle attribute assignment but would not update the actual object’s attributes, which could lead to incomplete or incorrect behavior.

- **Attribute Assignment**: The `__setattr__` method in Python intercepts every attempt to set an attribute. If you don’t call the parent’s `__setattr__` method, the attribute won’t actually be set in the object.
- **Preventing Infinite Recursion**: If you manually set an attribute within `__setattr__`, and if you don’t call `super().__setattr__`, you’ll trigger `__setattr__` again, causing infinite recursion. By calling `super()`, you ensure that the base class's logic for setting attributes is correctly executed.
- **Customizing Behavior**: Using `super()` allows you to customize the behavior (like validating values) while ensuring the default behavior (actually assigning the attribute) is still executed.

### **`__getattr__(self, name)`**  
- The `__getattr__` method is called when an attribute is accessed that doesn't exist in the object.  
- It provides a way to define default values or dynamic attribute handling.

```python
class MyClass:
    def __getattr__(self, name):  # Handling missing attributes
        if name == 'name':
            return "Unknown"
        else:
            return f"{name} not found"

obj = MyClass()
print(obj.name)  # Unknown
print(obj.age)   # age not found
```

### **`__enter__(self)` and `__exit__(self)`**  
- The `__enter__` and `__exit__` methods are used for context management (with the `with` statement).  
- `__enter__` is called when entering the context, and `__exit__` is called when exiting the context.

```python
class MyClass:
    def __enter__(self):
        print("Entering the context")
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        print("Exiting the context")

with MyClass() as obj:
    print("Inside the context")
```

#### `__exit__` Parameters:
- **`exc_type`**: The type of exception that was raised inside the `with` block, or `None` if no exception occurred.
- **`exc_val`**: The actual exception instance, or `None` if no exception occurred.
- **`exc_tb`**: A traceback object for the exception, or `None` if no exception occurred.
#### `__exit__` Return Value:
- **`None`** (or any value other than `None` to suppress the exception):
    - If it returns `None`, any exception that occurred inside the `with` block is propagated outside.
    - If it returns a value (e.g., `True`), it suppresses the exception, preventing it from being propagated.

```python
class MyContext:
    def __enter__(self):
        print("Entering the context")
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        print("Exiting the context")
        if exc_type:
            print(f"An exception occurred: {exc_val}")
        else:
            print("No exception occurred")
        # Returning True suppresses the exception
        return True

# Using the context manager with an exception inside the block
with MyContext() as obj:
    print("Inside the context")
    raise ValueError("An error occurred")

# Output:
# Entering the context
# Inside the context
# Exiting the context
# An exception occurred: An error occurred
```

### **`__bool__(self)` and `__nonzero__(self)`**  
- The `__bool__` method is used to define the truth value of an object (whether it evaluates to `True` or `False`).  
- In Python 2, `__nonzero__` is used for the same purpose.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __bool__(self):  # Overloading boolean context
        return self.value != 0

obj1 = MyClass(10)
obj2 = MyClass(0)

print(bool(obj1))  # True
print(bool(obj2))  # False
```

### **`__copy__(self)` and `__deepcopy__(self)`**

- The `__copy__` method defines the behavior of copying an object using the `copy.copy()` function.
- The `__deepcopy__` method is used to handle deep copying of objects, allowing nested objects to be copied recursively.

```python
import copy

class MyClass:
    def __init__(self, values):
        self.values = values

    def __copy__(self):  # Shallow copy
        return MyClass(self.values)

    def __deepcopy__(self, memo):  # Deep copy
        values_copy = copy.deepcopy(self.values, memo)
        return MyClass(values_copy)

obj = MyClass([1, 2, 3])
shallow_copy = copy.copy(obj)
deep_copy = copy.deepcopy(obj)

print(shallow_copy.values)  # [1, 2, 3]
print(deep_copy.values)  # [1, 2, 3]
```

### **`__aenter__(self)` and `__aexit__(self, exc_type, exc_value, traceback)`**

- The `__aenter__` and `__aexit__` methods define the behavior for asynchronous context managers, similar to `__enter__` and `__exit__`.
- These are used for async operations inside a `with` block.

```python
class MyClass:
    async def __aenter__(self):  # Async setup for context
        print("Entering the async context")
        return self

    async def __aexit__(self, exc_type, exc_value, traceback):  # Async cleanup
        print("Exiting the async context")

# Usage within an asynchronous function
import asyncio

async def main():
    async with MyClass() as obj:
        print("Inside the async context")

asyncio.run(main())  # Entering the async context, Inside the async context, Exiting the async context
```

---

## Abstract Classes and Interfaces  

### **Abstract Classes**  
An **abstract class** is a class that **cannot be instantiated** and serves as a blueprint for other classes. It defines a common interface for its subclasses and may contain **abstract methods** (methods that must be implemented by derived classes).  

In Python, abstract classes are defined using the `ABC` (Abstract Base Class) module.  

#### **Defining an Abstract Class**  
- Use `ABC` from the `abc` module to define an abstract class.  
- Use `@abstractmethod` to declare abstract methods that subclasses **must** implement.  

```python
from abc import ABC, abstractmethod

class Animal(ABC):  # Abstract class
    @abstractmethod
    def make_sound(self):  # Abstract method
        pass
```

#### **Implementing an Abstract Class**  
A subclass **must implement all abstract methods** from the abstract class; otherwise, it cannot be instantiated.  

```python
class Dog(Animal):
    def make_sound(self):  # Implementing the abstract method
        return "Woof!"

class Cat(Animal):
    def make_sound(self):
        return "Meow!"

dog = Dog()
cat = Cat()
print(dog.make_sound())  # Woof!
print(cat.make_sound())  # Meow!
```

#### **Abstract Class with Concrete Methods**  
Abstract classes can also contain **concrete methods** (regular methods with implementations).  

```python
class Vehicle(ABC):
    def __init__(self, name):
        self.name = name

    @abstractmethod
    def start_engine(self):
        pass  # Abstract method

    def describe(self):  # Concrete method
        return f"This is a {self.name}."

class Car(Vehicle):
    def start_engine(self):
        return "Car engine started."

car = Car("Sedan")
print(car.start_engine())  # Car engine started.
print(car.describe())  # This is a Sedan.
```

### **Interfaces in Python**  
Python **does not** have built-in interfaces like Java or C++, but interfaces can be simulated using **abstract classes with only abstract methods**.  

#### **Defining an Interface**  
- An interface is an abstract class where **all methods are abstract** (no concrete methods).  

```python
from abc import ABC, abstractmethod

class Shape(ABC):  # Interface
    @abstractmethod
    def area(self):
        pass

    @abstractmethod
    def perimeter(self):
        pass
```

#### **Implementing an Interface**  
A class implementing the interface must define all abstract methods.  

```python
class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return 3.14 * self.radius ** 2

    def perimeter(self):
        return 2 * 3.14 * self.radius

circle = Circle(5)
print(circle.area())  # 78.5
print(circle.perimeter())  # 31.4
```

### **Multiple Interfaces**  
Python allows a class to implement multiple interfaces by inheriting from multiple abstract classes.  

```python
class Printable(ABC):
    @abstractmethod
    def print_details(self):
        pass

class Savable(ABC):
    @abstractmethod
    def save(self):
        pass

class Document(Printable, Savable):
    def print_details(self):
        return "Printing document."

    def save(self):
        return "Saving document."

doc = Document()
print(doc.print_details())  # Printing document.
print(doc.save())  # Saving document.
```

**Key Points**  
- **Abstract Classes**: Cannot be instantiated, may contain both abstract and concrete methods.  
- **Abstract Methods**: Declared with `@abstractmethod`, must be implemented by subclasses.  
- **Interfaces**: Can be simulated using abstract classes with only abstract methods.  
- **Multiple Inheritance**: A class can implement multiple interfaces in Python.

---

# Exception Handling and Debugging

## Understanding Exceptions and Errors

### **What are Exceptions and Errors?**  
- **Exceptions** are runtime errors that disrupt normal program execution. They can be handled using `try-except` blocks.  
- **Errors** are issues in the code that may prevent execution (e.g., syntax errors). Some errors can be caught as exceptions, while others terminate the program immediately.  

### **Types of Errors and Exceptions**  

#### **Syntax Errors**
- Occur when the Python parser detects invalid syntax.
- Cannot be handled using `try-except`.

```python
# Example of a syntax error
print("Hello"  # Missing closing parenthesis
```

#### **Runtime Errors (Exceptions)**
- Occur during program execution and can be handled.

```python
# Example: ZeroDivisionError
print(10 / 0)  # Division by zero causes an exception
```

#### **Common Built-in Exceptions**
- **ZeroDivisionError** – Division by zero (`10 / 0`).
- **TypeError** – Operation on incompatible types (`'2' + 2`).
- **ValueError** – Invalid value (`int("abc")`).
- **IndexError** – List index out of range (`lst[10]` when `lst` has 3 elements).
- **KeyError** – Nonexistent dictionary key (`dict['missing_key']`).
- **AttributeError** – Undefined object attribute (`obj.undefined_method()`).
- **ImportError** – Failed module import (`import nonexistent_module`).
- **FileNotFoundError** – Trying to open a non-existing file (`open('missing.txt')`).
- **NameError** – Using an undefined variable (`print(undefined_var)`).
- **IndentationError** – Incorrect indentation (`if True:\nprint("Indented wrong")`).
- **StopIteration** – Raised when an iterator has no more items.
- **EOFError** – Unexpected end of input in interactive mode.
- **RecursionError** – Exceeding maximum recursion depth (`def f(): f(); f()`).
- **ArithmeticError** – Base class for errors in numeric calculations.  
- **FloatingPointError** – Floating-point operation failure (rare in Python).  
- **OverflowError** – Number too large for representation (`10**1000` in fixed precision).  
- **MemoryError** – Operation exceeds memory capacity (e.g., creating an extremely large list).  
- **ReferenceError** – Weak reference to a garbage-collected object (`import weakref; weakref.ref(obj)`).  
- **AssertionError** – Raised when `assert` statement fails (`assert False, "This is an error"`).  
- **RuntimeError** – Generic error when no other category fits (`raise RuntimeError("Unexpected failure")`).  
- **NotImplementedError** – Raised in abstract methods that must be overridden (`raise NotImplementedError("Must implement this method")`).  
- **PermissionError** – Insufficient permission for a file operation (`open('/root/protected.txt', 'w')`).  
- **OSError** – General OS-related errors (file access, system calls, etc.).  
- **TimeoutError** – Operation timed out (e.g., network request timeout).  
- **UnicodeError** – Base class for Unicode-related encoding/decoding issues.  
- **UnicodeEncodeError** – Encoding failure when converting a string to bytes.  
- **UnicodeDecodeError** – Decoding failure when converting bytes to a string.  
- **UnicodeTranslateError** – Translation-related Unicode errors.  
- **BlockingIOError** – Non-blocking I/O operation attempted on a resource that would block.  
- **InterruptedError** – Interrupted system call (e.g., signal interrupts an I/O operation).  
- **BrokenPipeError** – Writing to a closed pipe/socket (`sys.stdout.write("message")` after `sys.stdout.close()`).  
- **ConnectionError** – Base class for network connection-related errors.  
- **ConnectionAbortedError** – Connection aborted by the peer.  
- **ConnectionRefusedError** – Connection attempt refused (e.g., connecting to a non-listening port).  
- **ConnectionResetError** – Connection reset by the peer.  
- **ModuleNotFoundError** – Importing a nonexistent module (`import nonexistent_module`).  
- **IsADirectoryError** – File operation attempted on a directory (`open('/home/user', 'r')`).  
- **NotADirectoryError** – Directory operation attempted on a file (`os.listdir('file.txt')`).  
- **FileExistsError** – Attempting to create a file that already exists (`os.mkdir('existing_folder')`).

### **Handling Exceptions with `try-except`**
```python
try:
    x = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero")
```

### **Handling Multiple Exceptions**
```python
try:
    num = int("abc")
except (ValueError, TypeError) as e:
    print(f"Error occurred: {e}")
```

### **Using `else` and `finally`**
- `else`: Runs if no exception occurs.  
- `finally`: Runs regardless of whether an exception occurred.

```python
try:
    x = 10 / 2
except ZeroDivisionError:
    print("Cannot divide by zero")
else:
    print("Division successful")
finally:
    print("This always runs")
```

### **Raising Exceptions (`raise`)**
```python
def check_age(age):
    if age < 18:
        raise ValueError("Age must be 18 or above")

check_age(16)  # Raises ValueError
```

### **Custom Exceptions**
```python
class CustomError(Exception):
    pass

try:
    raise CustomError("This is a custom exception")
except CustomError as e:
    print(e)
```

**Key Points**
- **Syntax errors** are detected before execution, while **exceptions** occur during runtime.  
- **Use `try-except` to catch and handle exceptions** to prevent program crashes.  
- **Multiple exceptions can be handled** using a tuple in `except`.  
- **`else` runs if no exception occurs**, while **`finally` always runs** (whether an exception occurs or not).  
- **Use `raise` to manually trigger exceptions** for invalid conditions.  
- **Custom exceptions can be created** by inheriting from `Exception`.

---

## Custom Exceptions  

### **What are Custom Exceptions?**  
Custom exceptions allow developers to define their own error types by extending Python's built-in `Exception` class. This helps in creating meaningful error messages and handling domain-specific errors.  

### **Defining a Custom Exception**  
To create a custom exception, define a class that inherits from `Exception`.  

```python
class CustomError(Exception):
    """A custom exception class."""
    pass

# Raising the custom exception
raise CustomError("This is a custom error")
```

### **Custom Exception with `__init__` for Custom Messages**  
A custom exception can accept additional parameters to provide more details.  

```python
class AgeError(Exception):
    """Exception raised for invalid age."""

    def __init__(self, age, message="Age must be 18 or above"):
        self.age = age
        self.message = message
        super().__init__(f"{message}. Provided age: {age}")

# Raising the custom exception
try:
    age = 16
    if age < 18:
        raise AgeError(age)
except AgeError as e:
    print(e)  # Output: Age must be 18 or above. Provided age: 16
```

### **Using Custom Exceptions in Functions**  
Custom exceptions can be used to validate inputs and enforce constraints.  

```python
class NegativeNumberError(Exception):
    """Exception raised when a negative number is encountered."""
    def __init__(self, number):
        super().__init__(f"Negative number not allowed: {number}")

def check_positive(number):
    if number < 0:
        raise NegativeNumberError(number)
    return f"Valid number: {number}"

try:
    print(check_positive(-5))
except NegativeNumberError as e:
    print(e)  # Negative number not allowed: -5
```

### **Creating a Hierarchy of Custom Exceptions**  
You can define multiple custom exceptions by inheriting from a base exception class.  

```python
class ApplicationError(Exception):
    """Base class for all application-related exceptions."""
    pass

class DatabaseError(ApplicationError):
    """Exception raised for database errors."""
    pass

class NetworkError(ApplicationError):
    """Exception raised for network issues."""
    pass

# Handling multiple custom exceptions
try:
    raise NetworkError("Network connection failed")
except ApplicationError as e:
    print(f"Application error occurred: {e}")  
```

**Key Points**  
- **Custom exceptions inherit from `Exception`** to create domain-specific errors.  
- **Use `__init__` to store additional information** for meaningful error messages.  
- **Custom exceptions improve code readability** by providing specific error handling.  
- **You can create an exception hierarchy** to categorize errors efficiently.  
- **Raising and handling custom exceptions** ensures proper error reporting and debugging.

---

## Debugging Techniques and Tools (`pdb`, `logging`, `assert` Statements)  

### **Debugging in Python**  
Debugging is the process of identifying and fixing errors in a program. Python provides several tools for debugging, including `pdb` (Python Debugger), `logging`, and `assert` statements.  

### **Using `pdb` (Python Debugger)**  
The `pdb` module allows interactive debugging, where you can pause execution, inspect variables, and step through code.  

#### **Basic Usage of `pdb`**  
```python
import pdb

def divide(a, b):
    pdb.set_trace()  # Start debugging here
    return a / b

print(divide(10, 2))  # Works fine
print(divide(10, 0))  # Causes ZeroDivisionError
```

#### **Common `pdb` Commands**  
- `n` (next) – Execute the next line.  
- `s` (step) – Step into a function.  
- `c` (continue) – Continue execution until the next breakpoint.  
- `p variable` – Print the value of a variable.  
- `q` (quit) – Exit the debugger.  

#### **Setting Breakpoints Manually**  
```python
def multiply(a, b):
    breakpoint()  # Equivalent to `pdb.set_trace()`
    return a * b

print(multiply(5, 3))
```

---

### **Using `logging` for Debugging**  
The `logging` module helps in tracking events, errors, and debug messages without cluttering code with print statements.  

#### **Basic Logging Example**  
```python
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG, format="%(levelname)s: %(message)s")

def add(a, b):
    logging.debug(f"Adding {a} and {b}")
    return a + b

print(add(4, 5))
```

#### **Logging Levels**  
- `DEBUG` – Detailed information, for debugging.  
- `INFO` – General information.  
- `WARNING` – Indication of potential issues.  
- `ERROR` – Serious errors that need attention.  
- `CRITICAL` – Severe errors causing application failure.  

#### **Logging to a File**  
```python
logging.basicConfig(filename="app.log", level=logging.DEBUG)
logging.info("This message is logged to a file.")
```

---

### **Using `assert` Statements for Debugging**  
An `assert` statement is used to check assumptions and raise an error if they are false.  

#### **Basic Assertion**  
```python
x = 10
assert x > 0, "x should be positive"
```

#### **Using `assert` in Functions**  
```python
def divide(a, b):
    assert b != 0, "Denominator must not be zero"
    return a / b

print(divide(10, 2))  # Works fine
print(divide(10, 0))  # AssertionError
```

#### **Disabling Assertions**  
Assertions can be disabled by running Python with the `-O` (optimize) flag:  
```sh
python -O script.py
```

---

**Key Points**  
- **Use `pdb` to step through code**, inspect variables, and debug interactively.  
- **Use `breakpoint()` instead of `pdb.set_trace()`** in Python 3.7+.  
- **Use `logging` for tracking errors** without using `print()`, with different logging levels.  
- **Logging can be configured to write to files**, making it useful for debugging applications.  
- **Use `assert` for quick checks** on program logic but avoid using it for error handling in production.

---

# Python Standard Library

## Python Standard Library  

The Python Standard Library is a collection of built-in modules that provide functionality for various tasks such as file handling, system operations, math calculations, networking, and more. These modules come pre-installed with Python, so they do not require separate installation.

### **Commonly Used Standard Library Modules**  

#### **1. `sys` – System-Specific Functions**  
Provides functions and variables for interacting with the Python runtime.  
```python
import sys
print(sys.version)  # Python version
print(sys.platform)  # OS platform
sys.exit(0)  # Exit the program
```

#### **2. `os` – Operating System Interface**  
Used for interacting with the operating system.  
```python
import os
print(os.name)  # OS name
print(os.getcwd())  # Current working directory
os.mkdir("new_folder")  # Create a new directory
os.remove("file.txt")  # Delete a file
```

#### **3. `math` – Mathematical Functions**  
Provides mathematical operations and constants.  
```python
import math
print(math.sqrt(25))  # Square root: 5.0
print(math.pi)  # Pi value: 3.141592653589793
print(math.factorial(5))  # Factorial: 120
```

#### **4. `random` – Generating Random Numbers**  
Used for random number generation and shuffling.  
```python
import random
print(random.randint(1, 10))  # Random integer between 1 and 10
print(random.choice(["apple", "banana", "cherry"]))  # Random selection
random.shuffle([1, 2, 3, 4, 5])  # Shuffle a list
```

#### **5. `datetime` – Date and Time Handling**  
Handles dates, times, and time-based operations.  
```python
import datetime
now = datetime.datetime.now()
print(now)  # Current date and time
print(now.strftime("%Y-%m-%d %H:%M:%S"))  # Format date and time
```

#### **6. `time` – Time-Related Functions**  
Provides functions for dealing with time.  
```python
import time
print(time.time())  # Current time in seconds since epoch
time.sleep(2)  # Pause execution for 2 seconds
```

#### **7. `re` – Regular Expressions**  
Used for pattern matching and text processing.  
```python
import re
pattern = r"\d+"
text = "There are 3 apples and 5 oranges."
matches = re.findall(pattern, text)
print(matches)  # Output: ['3', '5']
```

#### **8. `json` – Working with JSON Data**  
Used to parse and generate JSON data.  
```python
import json
data = {"name": "Alice", "age": 25}
json_data = json.dumps(data)  # Convert to JSON string
print(json_data)  # Output: '{"name": "Alice", "age": 25}'
parsed_data = json.loads(json_data)  # Convert back to dictionary
print(parsed_data["name"])  # Output: Alice
```

#### **9. `csv` – Handling CSV Files**  
Used for reading and writing CSV files.  
```python
import csv
with open("data.csv", mode="w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(["Name", "Age"])
    writer.writerow(["Alice", 25])

with open("data.csv", mode="r") as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)
```

#### **10. `urllib` – Handling URLs and HTTP Requests**  
Used to fetch data from the web.  
```python
import urllib.request
response = urllib.request.urlopen("https://www.example.com")
print(response.read().decode("utf-8"))
```

#### **11. `http` – HTTP Requests and Responses**  
Used to create HTTP servers and clients.  
```python
from http.server import SimpleHTTPRequestHandler, HTTPServer
server = HTTPServer(("localhost", 8000), SimpleHTTPRequestHandler)
print("Serving on port 8000...")
server.serve_forever()
```

#### **12. `socket` – Network Communication**  
Used for creating network connections.  
```python
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("example.com", 80))
print("Connected to example.com")
s.close()
```

#### **13. `hashlib` – Hashing Algorithms**  
Used for generating secure hash values.  
```python
import hashlib
hash_object = hashlib.sha256(b"hello world")
print(hash_object.hexdigest())  # Output: Hash value
```

#### **14. `threading` – Multithreading**  
Used for running multiple threads concurrently.  
```python
import threading
def print_hello():
    print("Hello from thread")

thread = threading.Thread(target=print_hello)
thread.start()
thread.join()
```

#### **15. `multiprocessing` – Parallel Processing**  
Used to execute tasks in parallel across multiple CPU cores.  
```python
import multiprocessing
def worker():
    print("Worker process running")

process = multiprocessing.Process(target=worker)
process.start()
process.join()
```

#### **16. `itertools` – Iterators and Combinatorics**  
Used for handling iteration-related tasks.  
```python
import itertools
numbers = [1, 2, 3]
combinations = itertools.combinations(numbers, 2)
print(list(combinations))  # Output: [(1, 2), (1, 3), (2, 3)]
```

#### **17. `functools` – Functional Programming Tools**  
Used for higher-order functions and optimization.  
```python
import functools
def multiply(a, b):
    return a * b

double = functools.partial(multiply, 2)
print(double(5))  # Output: 10
```

#### **18. `collections` – Specialized Data Structures**  
Provides additional container types beyond lists and dictionaries.  
```python
import collections
Counter = collections.Counter(["a", "b", "a", "c", "b", "a"])
print(Counter)  # Output: Counter({'a': 3, 'b': 2, 'c': 1})
```

#### **19. `logging` – Logging System**  
Used for debugging and application logging.  
```python
import logging
logging.basicConfig(level=logging.INFO)
logging.info("This is an info message")
```

#### **20. `configparser` – Handling Configuration Files**  
Used for reading and writing `.ini` configuration files.  
```python
import configparser
config = configparser.ConfigParser()
config["DEFAULT"] = {"username": "admin", "password": "secret"}
with open("config.ini", "w") as configfile:
    config.write(configfile)
```

---

**Key Points**  
- **The Python Standard Library provides built-in modules for various tasks.**  
- **Modules like `sys`, `os`, `math`, and `random` offer system, OS, and mathematical utilities.**  
- **Networking and web-related tasks can be handled with `urllib`, `socket`, and `http`.**  
- **Concurrency is supported with `threading` and `multiprocessing`.**  
- **Data processing modules like `json`, `csv`, and `collections` simplify structured data handling.**  
- **Security-related modules include `hashlib` for hashing and `logging` for tracking program execution.**

---



---


# Multithreading, Multiprocessing, and Asynchronous Programming

## **Asynchronous Programming Using `asyncio'**

The `asyncio` module in Python provides a framework for writing asynchronous, concurrent programs. It allows tasks to run concurrently without blocking execution, making it ideal for I/O-bound operations like network requests, database queries, and file handling.

---

## **1. Basics of `asyncio`**

`asyncio` enables asynchronous programming using coroutines. A coroutine is a special function that allows execution to be paused and resumed.

### **Key Concepts:**

- **Event Loop**: Manages the execution of asynchronous tasks.
- **Coroutines**: Special functions defined with `async def` that can be awaited.
- **Tasks**: Used to schedule coroutines for execution.

---

## **2. Creating and Running Coroutines**

A coroutine is defined using `async def` and is executed using `await`.

```python
import asyncio

async def greet():
    print("Hello,")
    await asyncio.sleep(2)  # Simulates an I/O operation
    print("World!")

asyncio.run(greet())  # Runs the coroutine
```

### **Explanation:**

- The `await asyncio.sleep(2)` suspends execution for 2 seconds.
- The event loop allows other tasks to run during the wait time.

---

## **3. Running Multiple Tasks Concurrently**

Instead of running coroutines sequentially, we can run multiple tasks concurrently using `asyncio.gather()`.

```python
import asyncio

async def task1():
    print("Task 1 started")
    await asyncio.sleep(2)
    print("Task 1 finished")

async def task2():
    print("Task 2 started")
    await asyncio.sleep(1)
    print("Task 2 finished")

async def main():
    await asyncio.gather(task1(), task2())  # Run both tasks concurrently

asyncio.run(main())
```

### **Explanation:**

- `asyncio.gather(task1(), task2())` executes both tasks at the same time.
- Task 2 finishes before Task 1 since it sleeps for 1 second instead of 2.

---

## **4. Creating and Managing Tasks**

`asyncio.create_task()` schedules coroutines as tasks, allowing them to run independently.

```python
import asyncio

async def task(name, duration):
    print(f"{name} started")
    await asyncio.sleep(duration)
    print(f"{name} finished")

async def main():
    task_a = asyncio.create_task(task("Task A", 2))
    task_b = asyncio.create_task(task("Task B", 1))

    await task_a  # Wait for Task A to finish
    await task_b  # Wait for Task B to finish

asyncio.run(main())
```

### **Explanation:**

- `asyncio.create_task()` schedules `task` execution in the background.
- Both tasks start immediately, but Task B finishes first since it has a shorter sleep time.

---

## **5. Using `asyncio.Queue` for Task Synchronization**

An `asyncio.Queue` can be used to manage tasks in a producer-consumer pattern.

```python
import asyncio

async def producer(queue):
    for i in range(5):
        await asyncio.sleep(1)
        await queue.put(i)
        print(f"Produced: {i}")

async def consumer(queue):
    while True:
        item = await queue.get()
        print(f"Consumed: {item}")
        queue.task_done()

async def main():
    queue = asyncio.Queue()
    producer_task = asyncio.create_task(producer(queue))
    consumer_task = asyncio.create_task(consumer(queue))

    await producer_task  # Wait for the producer to finish
    await queue.join()   # Ensure all items are processed
    consumer_task.cancel()  # Stop the consumer

asyncio.run(main())
```

### **Explanation:**

- The producer generates data and adds it to the queue.
- The consumer retrieves and processes data from the queue.
- `queue.join()` ensures all items are processed before stopping.

---

## **6. Handling Timeouts and Cancellation**

Asynchronous tasks can be **timed out** or **canceled** using `asyncio.wait_for()`.

```python
import asyncio

async def long_running_task():
    await asyncio.sleep(5)
    return "Task Completed"

async def main():
    try:
        result = await asyncio.wait_for(long_running_task(), timeout=2)
        print(result)
    except asyncio.TimeoutError:
        print("Task timed out!")

asyncio.run(main())
```

### **Explanation:**

- `asyncio.wait_for(long_running_task(), timeout=2)` ensures that the task is canceled if it takes longer than 2 seconds.

---

## **7. Running Async Code in a Synchronous Program**

In some cases, you may need to run async code inside a synchronous function using `asyncio.run_coroutine_threadsafe()`.

```python
import asyncio

async def background_task():
    while True:
        print("Running in the background...")
        await asyncio.sleep(2)

loop = asyncio.new_event_loop()
asyncio.set_event_loop(loop)
task = loop.create_task(background_task())

try:
    loop.run_forever()  # Keep running indefinitely
except KeyboardInterrupt:
    task.cancel()
    loop.close()
```

---

## **8. Asynchronous File Handling with `aiofiles`**

Standard file operations are blocking. To handle them asynchronously, use `aiofiles`.

```python
import asyncio
import aiofiles

async def read_file():
    async with aiofiles.open('example.txt', 'r') as file:
        content = await file.read()
        print(content)

asyncio.run(read_file())
```

### **Explanation:**

- `aiofiles.open()` allows non-blocking file access.
- `await file.read()` ensures the file read operation is handled asynchronously.

---

## **9. Web Requests with `aiohttp`**

To make non-blocking HTTP requests, use `aiohttp`.

```python
import aiohttp
import asyncio

async def fetch(url):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.text()

async def main():
    url = "https://www.example.com"
    content = await fetch(url)
    print(content[:200])  # Print first 200 characters

asyncio.run(main())
```

### **Explanation:**

- `aiohttp.ClientSession()` manages HTTP requests asynchronously.
- `await response.text()` ensures the response is retrieved asynchronously.

---

## **10. Real-World Applications of `asyncio`**

- **Web Servers**: `FastAPI`, `Sanic`, and `Quart` use `asyncio` for high-performance applications.
- **Web Scraping**: `aiohttp` + `BeautifulSoup` enables fast data collection.
- **Chat Applications**: `asyncio` + `websockets` for real-time messaging.
- **Database Queries**: `asyncpg` for high-performance PostgreSQL operations.

---

## **Conclusion**

The `asyncio` module enables efficient, concurrent execution of tasks in Python. By understanding `async def`, `await`, `asyncio.gather()`, and `asyncio.create_task()`, you can optimize performance for I/O-bound operations.

---

# Misc

## `pip`

`pip` is a package manager for Python that allows you to install and manage additional libraries and dependencies that are not included in the standard Python library. Here are some common `pip` commands for various library management tasks:

**Listing Installed Packages**

- **List All Installed Packages**: Lists all packages installed in the current environment.
  ```sh
  pip list
  ```

- **List Packages in a Specific Environment**: If you're using virtual environments, specify the environment to list packages.
  ```sh
  pip list -r requirements.txt
  ```
  This command lists packages installed in the current environment and writes them to `requirements.txt`.

**Installing Packages**

- **Install a Package**: Installs a package from the Python Package Index (PyPI) or from a local distribution file.
  ```sh
  pip install package_name
  ```
  Replace `package_name` with the name of the package you wish to install.

- **Install a Specific Version**: Specifies the version of the package to install.
  ```sh
  pip install package_name==version_number
  ```
  Replace `version_number` with the desired version.

- **Install Multiple Packages**: Installs multiple packages at once.
  ```sh
  pip install package_name1 package_name2
  ```

- **Install a Package from a URL**: Installs a package directly from a URL.
  ```sh
  pip install https://example.com/path/to/package.tar.gz
  ```

**Upgrading Packages**

- **Upgrade a Package**: Upgrades a package to the latest version.
  ```sh
  pip install --upgrade package_name
  ```

- **Upgrade All Packages**: Upgrades all installed packages to their latest versions.
  ```sh
  pip list --outdated | grep -v '^\-e' | cut -d ' ' -f1 | xargs -n1 pip install -U
  ```

**Uninstalling Packages**

- **Uninstall a Package**: Removes a package from the current environment.
  ```sh
  pip uninstall package_name
  ```

- **Uninstall Multiple Packages**: Removes multiple packages at once.
  ```sh
  pip uninstall package_name1 package_name2
  ```

**Other Useful Commands**

- **Check for Outdated Packages**: Lists all installed packages that have newer versions available.
  ```sh
  pip list --outdated
  ```

- **Freeze Current Environment**: Generates a `requirements.txt` file with the current environment's package versions.
  ```sh
  pip freeze > requirements.txt
  ```

- **Install Requirements from a File**: Installs packages listed in a `requirements.txt` file.
  ```sh
  pip install -r requirements.txt
  ```


## `pyenv`

### What is pyenv?

pyenv is a Python version management tool that lets you easily install, switch between, and manage multiple Python versions on your machine. It's especially useful when working on different projects that require different Python versions.

### Installation

**macOS (using Homebrew):**

```bash
brew install pyenv
```

**Linux/macOS (using the installer):**

```bash
curl https://pyenv.run | bash
```

**Manual installation:**

```bash
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
```

After installation, add these lines to your shell configuration file (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

Then restart your shell or run `source ~/.bashrc` (or your shell config file).

### Core Commands

#### Installing Python versions

```bash
# List available Python versions
pyenv install --list

# Install a specific version
pyenv install 3.11.5
pyenv install 3.12.0

# Install the latest version of a series
pyenv install 3.11:latest
```

#### Managing versions

```bash
# List installed versions
pyenv versions

# Set global Python version (system-wide default)
pyenv global 3.11.5

# Set local Python version (for current directory/project)
pyenv local 3.12.0

# Set shell Python version (for current shell session)
pyenv shell 3.10.8

# Check current Python version
pyenv version

# Show which pyenv provided the current python
pyenv which python
```

#### Removing versions

```bash
# Uninstall a Python version
pyenv uninstall 3.9.16
```

### Understanding pyenv's Priority System

pyenv determines which Python version to use in this order:

1. **Shell**: Set with `pyenv shell` (highest priority)
2. **Local**: Set with `pyenv local` (creates `.python-version` file)
3. **Global**: Set with `pyenv global`
4. **System**: Your system's default Python (lowest priority)

### Working with Projects

The most common workflow is setting local versions for projects:

```bash
# Navigate to your project
cd my-project

# Set Python version for this project
pyenv local 3.11.5

# This creates a .python-version file
cat .python-version  # Shows: 3.11.5
```

Now whenever you're in this directory, pyenv automatically uses Python 3.11.5.

### Integration with Virtual Environments

pyenv works great with virtual environments:

```bash
# Set project Python version
cd my-project
pyenv local 3.11.5

# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/macOS
# or
venv\Scripts\activate     # Windows
```

### Advanced Features

#### pyenv-virtualenv Plugin

Install pyenv-virtualenv for enhanced virtual environment management:

```bash
# Install via Homebrew (macOS)
brew install pyenv-virtualenv

# Or clone manually
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
```

Add to your shell config:

```bash
eval "$(pyenv virtualenv-init -)"
```

Then you can:

```bash
# Create a virtual environment
pyenv virtualenv 3.11.5 myproject-env

# Activate it
pyenv activate myproject-env

# Set it as local for a project
pyenv local myproject-env

# List virtual environments
pyenv virtualenvs

# Deactivate
pyenv deactivate

# Delete virtual environment
pyenv uninstall myproject-env
```

### Troubleshooting Common Issues

#### Build dependencies missing

On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev \
liblzma-dev python3-openssl git
```

On CentOS/RHEL:

```bash
sudo yum groupinstall "Development Tools"
sudo yum install openssl-devel bzip2-devel libffi-devel
```

#### Command not found

Make sure pyenv is in your PATH and the init command is in your shell config.

#### Python version not switching

Check your shell configuration and make sure you've restarted your terminal or sourced your config file.

### Best Practices

1. **Use local versions for projects**: Always set specific Python versions for your projects using `pyenv local`
    
2. **Keep .python-version in version control**: Commit the `.python-version` file so team members use the same Python version
    
3. **Update regularly**: Keep pyenv updated to access new Python releases:
    
    ```bash
    brew upgrade pyenv  # macOS
    # or
    cd $(pyenv root) && git pull  # Manual installation
    ```
    
4. **Use specific versions**: Instead of `pyenv install 3.11`, use `pyenv install 3.11.5` for reproducibility
    
5. **Combine with requirements.txt**: Document both Python version (via `.python-version`) and dependencies (via `requirements.txt`)
    

### Common Workflow Example

Here's a typical workflow for starting a new project:

```bash
# Create project directory
mkdir my-new-project
cd my-new-project

# Set Python version for this project
pyenv local 3.11.5

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install requests flask
pip freeze > requirements.txt

# Your .python-version file ensures everyone uses Python 3.11.5
# Your requirements.txt ensures everyone has the same packages
```

This setup ensures consistent Python environments across different machines and team members. The `.python-version` file will automatically activate the correct Python version whenever you enter the project directory.

---

## `pyenv` for Windows

pyenv-win is the Windows port of pyenv. It provides similar functionality but is implemented differently due to Windows architecture differences.

### Installation

#### Method 1: Using Git (Recommended)
```cmd
git clone https://github.com/pyenv-win/pyenv-win.git %USERPROFILE%\.pyenv
```

#### Method 2: Using PowerShell (Alternative)
```powershell
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

#### Method 3: Using Chocolatey
```cmd
choco install pyenv-win
```

#### Method 4: Using Scoop
```cmd
scoop bucket add main
scoop install pyenv
```

### Environment Setup

After installation, you need to add pyenv to your PATH. You have several options:

#### Option 1: Automatic Setup (Recommended)
The installer usually adds these automatically, but if not:

**For Command Prompt, add to your system PATH:**
- `%USERPROFILE%\.pyenv\pyenv-win\bin`
- `%USERPROFILE%\.pyenv\pyenv-win\shims`

**For PowerShell, add to your PowerShell profile:**
```powershell
## Edit your PowerShell profile
notepad $PROFILE

## Add these lines:
$env:PYENV = "$env:USERPROFILE\.pyenv\pyenv-win\"
$env:PYENV_ROOT = "$env:USERPROFILE\.pyenv\pyenv-win\"
$env:PYENV_HOME = "$env:USERPROFILE\.pyenv\pyenv-win\"
$env:PATH = "$env:PYENV_HOME\bin;$env:PYENV_HOME\shims;$env:PATH"
```

#### Option 2: Manual PATH Setup
1. Open System Properties → Advanced → Environment Variables
2. Add to User PATH:
   - `%USERPROFILE%\.pyenv\pyenv-win\bin`
   - `%USERPROFILE%\.pyenv\pyenv-win\shims`

**Restart your terminal** after setting up the PATH.

### Core Commands (Windows)

The commands are mostly the same as Unix pyenv:

#### Installing Python versions
```cmd
## List available Python versions
pyenv install --list

## Install a specific version
pyenv install 3.11.5
pyenv install 3.12.0

## On Windows, you might see more detailed version numbers
pyenv install 3.11.5-amd64
```

#### Managing versions
```cmd
## List installed versions
pyenv versions

## Set global Python version
pyenv global 3.11.5

## Set local Python version (creates .python-version file)
pyenv local 3.12.0

## Check current Python version
pyenv version

## Refresh shims (sometimes needed on Windows)
pyenv rehash
```

### Windows-Specific Considerations

#### 1. Architecture-Specific Versions
Windows pyenv often shows architecture-specific versions:
```cmd
## You might see versions like:
3.11.5-amd64    ## 64-bit version
3.11.5-win32    ## 32-bit version
```

Use the 64-bit versions unless you specifically need 32-bit.

#### 2. Path Issues
If Python isn't found after switching versions:
```cmd
## Refresh the shims
pyenv rehash

## Check what pyenv thinks is the current Python
pyenv which python
```

#### 3. PowerShell Execution Policy
If you get execution policy errors in PowerShell:
```powershell
## Check current policy
Get-ExecutionPolicy

## Set policy to allow local scripts (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Working with Projects on Windows

#### Using Command Prompt
```cmd
## Navigate to your project
cd C:\Projects\my-project

## Set Python version for this project
pyenv local 3.11.5

## Create virtual environment
python -m venv venv

## Activate virtual environment
venv\Scripts\activate.bat

## Install packages
pip install requests flask
pip freeze > requirements.txt
```

#### Using PowerShell
```powershell
## Navigate to your project
cd C:\Projects\my-project

## Set Python version
pyenv local 3.11.5

## Create virtual environment
python -m venv venv

## Activate virtual environment
.\venv\Scripts\Activate.ps1

## If you get execution policy error:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Windows Terminal Integration

If you're using Windows Terminal, add this to your PowerShell profile for better integration:

```powershell
## Add to $PROFILE
function pyenv { 
    $command = $args[0]
    $args = $args[1..($args.length-1)]
    
    switch ($command) {
        "shell" { 
            if ($args.length -gt 0) {
                $env:PYENV_VERSION = $args[0]
            } else {
                Remove-Item env:PYENV_VERSION -ErrorAction SilentlyContinue
            }
        }
        default { 
            & "$env:PYENV_HOME\bin\pyenv.bat" $command @args
        }
    }
}
```

### Troubleshooting Windows-Specific Issues

#### 1. "pyenv is not recognized"
- Check that pyenv-win\bin is in your PATH
- Restart your terminal
- Try opening a new Command Prompt as Administrator

#### 2. Python version not switching
```cmd
## Refresh shims
pyenv rehash

## Check pyenv status
pyenv version
pyenv versions

## Check what executable is being used
where python
```

#### 3. Permission issues
- Run Command Prompt or PowerShell as Administrator
- Check if antivirus is blocking the installation
- Ensure you have write permissions to %USERPROFILE%\.pyenv

#### 4. SSL/TLS errors during installation
```cmd
## Try installing with verbose output
pyenv install -v 3.11.5

## If SSL errors persist, you might need to update certificates
```

#### 5. Long path issues
Windows has path length limitations. If you encounter issues:
- Enable long paths in Windows 10/11:
  ```cmd
  ## Run as Administrator
  reg add HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1
  ```

### IDE Integration

#### Visual Studio Code
Add to your VS Code settings.json:
```json
{
    "python.defaultInterpreterPath": "python",
    "python.terminal.activateEnvironment": true
}
```

#### PyCharm
1. Go to File → Settings → Project → Python Interpreter
2. Click gear icon → Add
3. Select "System Interpreter"
4. Browse to: `%USERPROFILE%\.pyenv\pyenv-win\versions\3.11.5\python.exe`

### Best Practices for Windows

1. **Use Command Prompt or PowerShell consistently**: Don't mix different terminals in the same project

2. **Check architecture**: Always use 64-bit Python versions unless specifically needed
   ```cmd
   pyenv install 3.11.5-amd64
   ```

3. **Handle spaces in paths**: If your project path has spaces, use quotes:
   ```cmd
   cd "C:\My Projects\my-project"
   ```

4. **Virtual environment activation**: Remember Windows uses `Scripts\activate.bat` not `bin/activate`

5. **Antivirus considerations**: Add pyenv directory to antivirus exclusions if you experience slow installations

### Complete Windows Workflow Example

```cmd
## Create and navigate to project directory
mkdir C:\Projects\my-flask-app
cd C:\Projects\my-flask-app

## Set Python version for this project
pyenv local 3.11.5

## Verify Python version
python --version

## Create virtual environment
python -m venv venv

## Activate virtual environment
venv\Scripts\activate.bat

## Upgrade pip
python -m pip install --upgrade pip

## Install project dependencies
pip install flask requests python-dotenv

## Save dependencies
pip freeze > requirements.txt

## Create a simple app
echo from flask import Flask > app.py
echo app = Flask(__name__) >> app.py
echo @app.route('/') >> app.py
echo def hello(): return 'Hello World!' >> app.py

## Run the app
set FLASK_APP=app.py
flask run
```

This workflow ensures you have a consistent, isolated Python environment for your Windows projects using pyenv-win.

## Virtual Environments

A **Python virtual environment** is an isolated workspace where you can install and manage dependencies separately from the global Python installation. This helps avoid conflicts between different projects.

---

### **Creating a Virtual Environment**

1. **Navigate to your project directory**:
    
    ```sh
    cd path/to/your/project
    ```
    
2. **Create the virtual environment**:
    
    ```sh
    python -m venv myenv
    ```
    
    - `myenv` is the folder where the virtual environment will be created.
        

---

### **Activating the Virtual Environment**

- **Windows (Command Prompt)**:
    
    ```sh
    myenv\Scripts\activate
    ```
    
- **Windows (PowerShell)**:
    
    ```sh
    myenv\Scripts\Activate.ps1
    ```
    
- **Mac/Linux**:
    
    ```sh
    source myenv/bin/activate
    ```
    

---

### **Installing Packages Inside the Virtual Environment**

Once activated, install dependencies using `pip`:

```sh
pip install package_name
```

Example:

```sh
pip install requests
```

To install multiple packages from a `requirements.txt` file:

```sh
pip install -r requirements.txt
```

---

### **Deactivating the Virtual Environment**

To exit the virtual environment:

```sh
deactivate
```

---

### **Deleting a Virtual Environment**

Simply delete the `myenv` folder:

```sh
rm -rf myenv  # Mac/Linux
rd /s /q myenv  # Windows
```

---

### **Checking Installed Packages**

To see installed dependencies within the virtual environment:

```sh
pip list
```

To save installed packages for reuse:

```sh
pip freeze > requirements.txt
```

---

### **Why Use a Virtual Environment?**

✅ **Avoid conflicts** between different projects  
✅ **Keep dependencies isolated**  
✅ **Ensure reproducibility** (especially for deployment)  
✅ **Work on different Python versions easily**
