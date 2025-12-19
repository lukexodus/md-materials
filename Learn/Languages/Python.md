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

## Coroutine Functions

Coroutines are functions defined with `async def` that can be paused and resumed, allowing for asynchronous programming. They use `await` to suspend execution until an awaited operation completes.

```python
import asyncio

async def fetch_data():
    print("Start fetching")
    await asyncio.sleep(1)  # Simulates async operation
    print("Done fetching")
    return "data"

# Running the coroutine
asyncio.run(fetch_data())
```

Key characteristics:
- Defined with `async def`
- Use `await` for asynchronous operations
- Enable concurrent execution without threading
- Must be run in an event loop

Practical example with multiple coroutines:
```python
async def task(name, delay):
    print(f"{name} starting")
    await asyncio.sleep(delay)
    print(f"{name} completed")
    return f"Result from {name}"

async def main():
    # Run multiple coroutines concurrently
    results = await asyncio.gather(
        task("Task 1", 2),
        task("Task 2", 1),
        task("Task 3", 1.5)
    )
    print(results)

asyncio.run(main())
```

---

## Decorators in Python

Decorators are a way to modify or enhance functions or classes without changing their source code. They use the `@decorator_name` syntax and are applied above the function or class definition.

### Basic Concept

A decorator is a function that takes another function as input and returns a modified version of it:

```python
def my_decorator(func):
    def wrapper():
        print("Before function call")
        func()
        print("After function call")
    return wrapper

@my_decorator
def say_hello():
    print("Hello!")

say_hello()
# Output:
# Before function call
# Hello!
# After function call
```

The `@my_decorator` syntax is equivalent to `say_hello = my_decorator(say_hello)`.

### Decorators with Arguments

To handle functions that take arguments, use `*args` and `**kwargs`:

```python
def my_decorator(func):
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__}")
        result = func(*args, **kwargs)
        print(f"Finished {func.__name__}")
        return result
    return wrapper

@my_decorator
def add(a, b):
    return a + b

result = add(3, 5)  # prints decorating messages, returns 8
```

### Common Use Cases

**Timing execution:**
```python
import time

def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.4f} seconds")
        return result
    return wrapper
```

**Caching results:**
```python
def memoize(func):
    cache = {}
    def wrapper(*args):
        if args not in cache:
            cache[args] = func(*args)
        return cache[args]
    return wrapper
```

**Access control:**
```python
def require_auth(func):
    def wrapper(user, *args, **kwargs):
        if not user.is_authenticated:
            raise PermissionError("Authentication required")
        return func(user, *args, **kwargs)
    return wrapper
```

### Preserving Function Metadata

Use `functools.wraps` to preserve the original function's name and docstring:

```python
from functools import wraps

def my_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper
```

### Decorators with Parameters

To create decorators that accept arguments, add another layer of functions:

```python
def repeat(times):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for _ in range(times):
                result = func(*args, **kwargs)
            return result
        return wrapper
    return decorator

@repeat(times=3)
def greet(name):
    print(f"Hello {name}")

greet("Alice")  # prints "Hello Alice" three times
```

### Class Decorators

Decorators can also be applied to classes:

```python
def singleton(cls):
    instances = {}
    @wraps(cls)
    def get_instance(*args, **kwargs):
        if cls not in instances:
            instances[cls] = cls(*args, **kwargs)
        return instances[cls]
    return get_instance

@singleton
class Database:
    pass
```

### Built-in Decorators

Python provides several built-in decorators:

- `@staticmethod` - defines a method that doesn't access instance or class data
- `@classmethod` - defines a method that receives the class as first argument
- `@property` - makes a method accessible like an attribute
- `@abstractmethod` - marks methods that must be implemented in subclasses

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

## Dynamic Attribute Access in Python

Python provides several ways to access object attributes dynamically at runtime, rather than using hardcoded attribute names.

### The `getattr()` Function

The most common method is `getattr()`, which retrieves an attribute by name:

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

person = Person("Alice", 30)

# Static access
print(person.name)  # "Alice"

# Dynamic access
attr_name = "name"
print(getattr(person, attr_name))  # "Alice"

# With default value if attribute doesn't exist
print(getattr(person, "salary", 0))  # 0
```

### The `__dict__` Attribute

Every Python object has a `__dict__` attribute containing its attributes as a dictionary:

```python
person = Person("Bob", 25)
print(person.__dict__)  # {'name': 'Bob', 'age': 25}

# Access dynamically
attr_name = "age"
print(person.__dict__[attr_name])  # 25
```

### The `setattr()` Function

To set attributes dynamically:

```python
person = Person("Carol", 28)
setattr(person, "salary", 50000)
print(person.salary)  # 50000

# Dynamically set multiple attributes
attributes = {"city": "New York", "title": "Engineer"}
for key, value in attributes.items():
    setattr(person, key, value)
```

### The `hasattr()` Function

Check if an attribute exists before accessing it:

```python
if hasattr(person, "name"):
    print(getattr(person, "name"))
```

### The `delattr()` Function

Remove attributes dynamically:

```python
delattr(person, "city")
# or
del person.city
```

### Practical Use Cases

Dynamic attribute access is useful for:

- Processing configuration data where attribute names come from external sources
- Building flexible APIs that handle varying attribute sets
- Implementing attribute-based routing or dispatching
- Working with JSON or database records where field names are dynamic
- Creating generic utility functions that work with multiple object types

### Security Considerations

When using dynamic attribute access with user-provided input, validate the attribute names to prevent unauthorized access to internal attributes or methods.

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

## **Commonly Used Standard Library Modules**  

### **1. `sys` – System-Specific Functions**  
Provides functions and variables for interacting with the Python runtime.  
```python
import sys
print(sys.version)   Python version
print(sys.platform)   OS platform
sys.exit(0)   Exit the program
```

### **2. `os` – Operating System Interface**  
Used for interacting with the operating system.  
```python
import os
print(os.name)   OS name
print(os.getcwd())   Current working directory
os.mkdir("new_folder")   Create a new directory
os.remove("file.txt")   Delete a file
```

### **3. `math` – Mathematical Functions**  
Provides mathematical operations and constants.  
```python
import math
print(math.sqrt(25))   Square root: 5.0
print(math.pi)   Pi value: 3.141592653589793
print(math.factorial(5))   Factorial: 120
```

### **4. `random` – Generating Random Numbers**  
Used for random number generation and shuffling.  
```python
import random
print(random.randint(1, 10))   Random integer between 1 and 10
print(random.choice(["apple", "banana", "cherry"]))   Random selection
random.shuffle([1, 2, 3, 4, 5])   Shuffle a list
```

### **5. `datetime` – Date and Time Handling**  
Handles dates, times, and time-based operations.  
```python
import datetime
now = datetime.datetime.now()
print(now)   Current date and time
print(now.strftime("%Y-%m-%d %H:%M:%S"))   Format date and time
```

### **6. `time` – Time-Related Functions**  
Provides functions for dealing with time.  
```python
import time
print(time.time())   Current time in seconds since epoch
time.sleep(2)   Pause execution for 2 seconds
```

### **7. `re` – Regular Expressions**  
Used for pattern matching and text processing.  
```python
import re
pattern = r"\d+"
text = "There are 3 apples and 5 oranges."
matches = re.findall(pattern, text)
print(matches)   Output: ['3', '5']
```

### **8. `json` – Working with JSON Data**  
Used to parse and generate JSON data.  
```python
import json
data = {"name": "Alice", "age": 25}
json_data = json.dumps(data)   Convert to JSON string
print(json_data)   Output: '{"name": "Alice", "age": 25}'
parsed_data = json.loads(json_data)   Convert back to dictionary
print(parsed_data["name"])   Output: Alice
```

### **9. `csv` – Handling CSV Files**  
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

### **10. `urllib` – Handling URLs and HTTP Requests**  
Used to fetch data from the web.  
```python
import urllib.request
response = urllib.request.urlopen("https://www.example.com")
print(response.read().decode("utf-8"))
```

### **11. `http` – HTTP Requests and Responses**  
Used to create HTTP servers and clients.  
```python
from http.server import SimpleHTTPRequestHandler, HTTPServer
server = HTTPServer(("localhost", 8000), SimpleHTTPRequestHandler)
print("Serving on port 8000...")
server.serve_forever()
```

### **12. `socket` – Network Communication**  
Used for creating network connections.  
```python
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("example.com", 80))
print("Connected to example.com")
s.close()
```

### **13. `hashlib` – Hashing Algorithms**  
Used for generating secure hash values.  
```python
import hashlib
hash_object = hashlib.sha256(b"hello world")
print(hash_object.hexdigest())   Output: Hash value
```

### **14. `threading` – Multithreading**  
Used for running multiple threads concurrently.  
```python
import threading
def print_hello():
    print("Hello from thread")

thread = threading.Thread(target=print_hello)
thread.start()
thread.join()
```

### **15. `multiprocessing` – Parallel Processing**  
Used to execute tasks in parallel across multiple CPU cores.  
```python
import multiprocessing
def worker():
    print("Worker process running")

process = multiprocessing.Process(target=worker)
process.start()
process.join()
```

### **16. `itertools` – Iterators and Combinatorics**  
Used for handling iteration-related tasks.  
```python
import itertools
numbers = [1, 2, 3]
combinations = itertools.combinations(numbers, 2)
print(list(combinations))   Output: [(1, 2), (1, 3), (2, 3)]
```

### **17. `functools` – Functional Programming Tools**  
Used for higher-order functions and optimization.  
```python
import functools
def multiply(a, b):
    return a * b

double = functools.partial(multiply, 2)
print(double(5))   Output: 10
```

### **18. `collections` – Specialized Data Structures**  
Provides additional container types beyond lists and dictionaries.  
```python
import collections
Counter = collections.Counter(["a", "b", "a", "c", "b", "a"])
print(Counter)   Output: Counter({'a': 3, 'b': 2, 'c': 1})
```

### **19. `logging` – Logging System**  
Used for debugging and application logging.  
```python
import logging
logging.basicConfig(level=logging.INFO)
logging.info("This is an info message")
```

### **20. `configparser` – Handling Configuration Files**  
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

## `sys` Module

The `sys` module provides access to variables and functions that interact closely with the Python interpreter. It's one of the most fundamental built-in modules in Python, offering direct access to interpreter-specific parameters and functions that control the runtime environment.

### Module Overview and Purpose

The `sys` module serves as the primary interface between Python programs and the interpreter itself. It contains system-specific parameters and functions that allow programs to interact with the Python runtime environment, access command-line arguments, manipulate the Python path, and control various interpreter behaviors.

### Importing and Basic Usage

```python
import sys
# Access all sys functionality
print(sys.version)

# Import specific functions (less common)
from sys import argv, exit
```

### Command Line Arguments

#### sys.argv

The most commonly used feature of the `sys` module is `sys.argv`, which contains command-line arguments passed to the Python script.

```python
import sys

print("Script name:", sys.argv[0])
print("Arguments:", sys.argv[1:])
print("Total arguments:", len(sys.argv))

# Example usage in script.py
# python script.py arg1 arg2 arg3
# Output:
# Script name: script.py
# Arguments: ['arg1', 'arg2', 'arg3']
# Total arguments: 4
```

**Key points:**

- `sys.argv[0]` is always the script name
- Arguments are stored as strings
- Empty if no arguments provided (except script name)

### Python Path Manipulation

#### sys.path

Controls where Python looks for modules and packages.

```python
import sys

# View current Python path
print(sys.path)

# Add a directory to the path
sys.path.append('/path/to/custom/modules')

# Insert at beginning (higher priority)
sys.path.insert(0, '/priority/path')

# Remove a path
sys.path.remove('/some/path')
```

#### sys.modules

Dictionary containing all currently loaded modules.

```python
import sys

# Check if a module is loaded
if 'os' in sys.modules:
    print("os module is loaded")

# View all loaded modules
print(list(sys.modules.keys()))

# Remove a module (forces reload on next import)
if 'mymodule' in sys.modules:
    del sys.modules['mymodule']
```

### Input/Output Streams

#### Standard Streams

The `sys` module provides access to standard input, output, and error streams.

```python
import sys

# Standard output (default print destination)
sys.stdout.write("Hello, World!\n")

# Standard error
sys.stderr.write("Error message\n")

# Standard input
# line = sys.stdin.readline()

# Redirect output
original_stdout = sys.stdout
with open('output.txt', 'w') as f:
    sys.stdout = f
    print("This goes to file")
    sys.stdout = original_stdout
```

#### Stream Properties

```python
import sys

# Check if streams are TTY (terminal)
print("stdout is TTY:", sys.stdout.isatty())
print("stderr is TTY:", sys.stderr.isatty())

# Get encoding
print("stdout encoding:", sys.stdout.encoding)
```

### System Information

#### Python Version Information

```python
import sys

# Python version as string
print("Version:", sys.version)

# Version as tuple
print("Version info:", sys.version_info)
print("Major version:", sys.version_info.major)
print("Minor version:", sys.version_info.minor)

# API version
print("API version:", sys.api_version)

# Hexadecimal version
print("Hex version:", sys.hexversion)
```

#### Platform Information

```python
import sys

# Platform identifier
print("Platform:", sys.platform)

# Byte order
print("Byte order:", sys.byteorder)

# Size of objects
print("Size of int:", sys.getsizeof(42))
print("Size of string:", sys.getsizeof("hello"))
```

### Memory and Performance

#### Memory Management

```python
import sys

# Get object size
my_list = [1, 2, 3, 4, 5]
print("Size of list:", sys.getsizeof(my_list))

# Get reference count
print("Reference count:", sys.getrefcount(my_list))

# Garbage collection thresholds
print("GC thresholds:", sys.getthreshold())
```

#### Recursion Limits

```python
import sys

# Get current recursion limit
print("Recursion limit:", sys.getrecursionlimit())

# Set new recursion limit
sys.setrecursionlimit(1500)

# Check stack size
def check_stack_size():
    print("Current stack size:", len(sys._current_frames()))
```

### Program Execution Control

#### Exit Functions

```python
import sys

# Exit with status code
def main():
    if len(sys.argv) < 2:
        print("Usage: script.py <argument>")
        sys.exit(1)  # Exit with error code
    
    # Normal execution
    print("Processing:", sys.argv[1])
    sys.exit(0)  # Success exit

# Exit hooks
import atexit

def cleanup():
    print("Cleaning up...")

atexit.register(cleanup)
```

#### Exception Handling

```python
import sys

# Get current exception information
try:
    1 / 0
except:
    exc_type, exc_value, exc_traceback = sys.exc_info()
    print("Exception type:", exc_type)
    print("Exception value:", exc_value)

# Custom exception hook
def custom_exception_handler(exc_type, exc_value, exc_traceback):
    print(f"Custom handler: {exc_type.__name__}: {exc_value}")

sys.excepthook = custom_exception_handler
```

### Advanced Features

#### Execution Tracing

```python
import sys

def trace_calls(frame, event, arg):
    if event == 'call':
        print(f"Calling: {frame.f_code.co_name}")
    return trace_calls

# Enable tracing
sys.settrace(trace_calls)

def example_function():
    print("Inside function")

example_function()
sys.settrace(None)  # Disable tracing
```

#### Profile Hooks

```python
import sys

def profile_function(frame, event, arg):
    if event == 'call':
        print(f"Profile: {frame.f_code.co_name}")

sys.setprofile(profile_function)
```

#### Interpreter Settings

```python
import sys

# Check if running in interactive mode
print("Interactive:", hasattr(sys, 'ps1'))

# Get default encoding
print("Default encoding:", sys.getdefaultencoding())

# File system encoding
print("File system encoding:", sys.getfilesystemencoding())

# Check for frozen executable
print("Frozen:", getattr(sys, 'frozen', False))
```

### Float Information

```python
import sys

# Float precision information
print("Float info:", sys.float_info)
print("Float max:", sys.float_info.max)
print("Float min:", sys.float_info.min)
print("Float epsilon:", sys.float_info.epsilon)
```

### Practical Examples

#### Command Line Tool

```python
import sys

def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py <command> [args...]", file=sys.stderr)
        sys.exit(1)
    
    command = sys.argv[1]
    args = sys.argv[2:]
    
    if command == "process":
        for arg in args:
            print(f"Processing: {arg}")
    elif command == "version":
        print(f"Python {sys.version}")
    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
```

#### Dynamic Module Loading

```python
import sys
import importlib

def load_module_from_path(module_name, file_path):
    # Add path temporarily
    sys.path.insert(0, file_path)
    try:
        module = importlib.import_module(module_name)
        return module
    finally:
        sys.path.remove(file_path)
```

#### Memory Monitoring

```python
import sys
import gc

def monitor_memory():
    # Get sizes of different objects
    objects = gc.get_objects()
    
    type_counts = {}
    total_size = 0
    
    for obj in objects:
        obj_type = type(obj).__name__
        size = sys.getsizeof(obj)
        
        type_counts[obj_type] = type_counts.get(obj_type, 0) + 1
        total_size += size
    
    print(f"Total objects: {len(objects)}")
    print(f"Total size: {total_size} bytes")
    print("Top object types:")
    for obj_type, count in sorted(type_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"  {obj_type}: {count}")
```

### Error Handling and Debugging

#### Custom Error Reporting

```python
import sys
import traceback

def custom_error_handler():
    exc_type, exc_value, exc_traceback = sys.exc_info()
    
    if exc_type is not None:
        print("=== ERROR REPORT ===", file=sys.stderr)
        print(f"Type: {exc_type.__name__}", file=sys.stderr)
        print(f"Message: {exc_value}", file=sys.stderr)
        print("Traceback:", file=sys.stderr)
        traceback.print_tb(exc_traceback, file=sys.stderr)
        print("===================", file=sys.stderr)

# Use in except blocks
try:
    risky_operation()
except:
    custom_error_handler()
    sys.exit(1)
```

### Platform-Specific Behavior

#### Windows-Specific Features

```python
import sys

if sys.platform == "win32":
    # Windows-specific code
    print("Running on Windows")
    
    # Access Windows-specific attributes
    if hasattr(sys, 'getwindowsversion'):
        print("Windows version:", sys.getwindowsversion())

elif sys.platform.startswith("linux"):
    # Linux-specific code
    print("Running on Linux")

elif sys.platform == "darwin":
    # macOS-specific code
    print("Running on macOS")
```

### Performance Optimization

#### Bytecode Optimization

```python
import sys

# Check optimization level
print("Optimization level:", sys.flags.optimize)

# Check various flags
print("Debug flag:", sys.flags.debug)
print("Verbose flag:", sys.flags.verbose)
print("Interactive flag:", sys.flags.interactive)
```

### Thread and Async Support

#### Thread Switching

```python
import sys
import threading

# Get thread switch interval
print("Switch interval:", sys.getswitchinterval())

# Set thread switch interval
sys.setswitchinterval(0.01)  # 10ms
```

**Key points:**

- Lower values increase responsiveness but may reduce performance
- Default is typically 0.005 seconds (5ms)
- Only affects threads, not async/await

### Best Practices

**Example** of proper sys module usage:

```python
import sys
import os

def main():
    # Proper argument handling
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <input_file>", file=sys.stderr)
        return 1
    
    input_file = sys.argv[1]
    
    # Check if file exists before processing
    if not os.path.exists(input_file):
        print(f"Error: File '{input_file}' not found", file=sys.stderr)
        return 1
    
    try:
        # Process file
        with open(input_file, 'r') as f:
            content = f.read()
            print(f"Processed {len(content)} characters")
        return 0
    
    except Exception as e:
        print(f"Error processing file: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
```

### Security Considerations

When using the `sys` module, be aware of security implications:

- **Path manipulation**: Adding untrusted directories to `sys.path` can lead to code injection
- **Stream redirection**: Redirecting stdout/stderr can hide important error messages
- **Module manipulation**: Modifying `sys.modules` can affect program behavior unexpectedly
- **Trace functions**: Tracing can impact performance and expose sensitive information

### Common Pitfalls

- **Modifying sys.argv**: Changes affect the entire program
- **Circular imports**: Manipulating `sys.modules` can create circular dependencies
- **Memory leaks**: Holding references in trace functions can prevent garbage collection
- **Platform assumptions**: Code using platform-specific features may not be portable

**Conclusion:** The `sys` module is essential for system-level programming in Python, providing access to interpreter internals, command-line arguments, and runtime environment. While powerful, it should be used carefully, especially when modifying interpreter behavior or handling system resources. Understanding its capabilities is crucial for writing robust, system-aware Python applications.

---

## `os` Module

The `os` module provides a portable way to interact with the operating system, offering functions for file and directory operations, process management, environment variables, and system-level operations. It serves as the primary interface between Python programs and the underlying operating system.

### Module Overview and Purpose

The `os` module abstracts operating system functionality, allowing Python programs to perform system operations in a platform-independent manner. It handles file system operations, process management, environment variables, and provides access to various operating system services.

### Importing and Basic Usage

```python
import os
# Access all os functionality
print(os.getcwd())

# Import specific functions
from os import getcwd, listdir, environ
from os.path import join, exists, dirname
```

### File and Directory Operations

#### Current Working Directory

```python
import os

# Get current working directory
current_dir = os.getcwd()
print("Current directory:", current_dir)

# Change working directory
os.chdir('/path/to/new/directory')

# Change to parent directory
os.chdir('..')

# Change to home directory
os.chdir(os.path.expanduser('~'))
```

#### Directory Listing and Navigation

```python
import os

# List directory contents
files = os.listdir('.')
print("Files in current directory:", files)

# List with full paths
for item in os.listdir('.'):
    full_path = os.path.join('.', item)
    print(f"{'DIR' if os.path.isdir(full_path) else 'FILE'}: {item}")

# Walk directory tree
for root, dirs, files in os.walk('/path/to/directory'):
    print(f"Directory: {root}")
    for file in files:
        print(f"  File: {file}")
    for dir in dirs:
        print(f"  Subdirectory: {dir}")
```

#### Directory Creation and Removal

```python
import os

# Create single directory
os.mkdir('new_directory')

# Create nested directories
os.makedirs('path/to/nested/directory', exist_ok=True)

# Remove empty directory
os.rmdir('empty_directory')

# Remove directory and all contents
import shutil
shutil.rmtree('directory_with_contents')

# Remove nested empty directories
os.removedirs('path/to/empty/nested/dirs')
```

### File Operations

#### File Creation and Removal

```python
import os

# Create empty file
with open('new_file.txt', 'w') as f:
    pass

# Remove file
os.remove('file_to_delete.txt')
os.unlink('another_file.txt')  # Same as remove

# Safe file removal
def safe_remove(filename):
    try:
        os.remove(filename)
        print(f"Removed: {filename}")
    except FileNotFoundError:
        print(f"File not found: {filename}")
    except PermissionError:
        print(f"Permission denied: {filename}")
```

#### File and Directory Information

```python
import os
import time

# Check if path exists
print("File exists:", os.path.exists('file.txt'))
print("Directory exists:", os.path.exists('directory'))

# Check path type
print("Is file:", os.path.isfile('file.txt'))
print("Is directory:", os.path.isdir('directory'))
print("Is symlink:", os.path.islink('symlink'))

# Get file statistics
stat_info = os.stat('file.txt')
print("File size:", stat_info.st_size)
print("Modified time:", time.ctime(stat_info.st_mtime))
print("Created time:", time.ctime(stat_info.st_ctime))
print("Permissions:", oct(stat_info.st_mode))
```

#### File Permissions and Attributes

```python
import os

# Change file permissions
os.chmod('file.txt', 0o644)  # rw-r--r--
os.chmod('script.py', 0o755)  # rwxr-xr-x

# Change file ownership (Unix/Linux only)
if os.name == 'posix':
    os.chown('file.txt', 1000, 1000)  # uid, gid

# Access and modification times
os.utime('file.txt', (access_time, modification_time))
```

### Path Operations with os.path

#### Path Construction and Manipulation

```python
import os

# Join paths (platform-independent)
path = os.path.join('directory', 'subdirectory', 'file.txt')
print("Joined path:", path)

# Split path components
directory, filename = os.path.split(path)
print("Directory:", directory)
print("Filename:", filename)

# Get file extension
name, ext = os.path.splitext('file.txt')
print("Name:", name)
print("Extension:", ext)

# Get directory name
print("Directory name:", os.path.dirname('/path/to/file.txt'))

# Get base name
print("Base name:", os.path.basename('/path/to/file.txt'))
```

#### Path Analysis

```python
import os

# Absolute and relative paths
relative_path = 'file.txt'
absolute_path = os.path.abspath(relative_path)
print("Absolute path:", absolute_path)

# Normalize path
normalized = os.path.normpath('path//to/../file.txt')
print("Normalized:", normalized)

# Real path (resolve symlinks)
real_path = os.path.realpath('symlink_to_file')
print("Real path:", real_path)

# Check if path is absolute
print("Is absolute:", os.path.isabs('/absolute/path'))
```

#### Path Expansion

```python
import os

# Expand user home directory
home_path = os.path.expanduser('~/Documents')
print("Home path:", home_path)

# Expand environment variables
var_path = os.path.expandvars('$HOME/Documents')
print("Variable path:", var_path)

# Common path operations
print("Common prefix:", os.path.commonprefix(['/path/to/file1', '/path/to/file2']))
print("Common path:", os.path.commonpath(['/path/to/file1', '/path/to/file2']))
```

### Environment Variables

#### Reading Environment Variables

```python
import os

# Get all environment variables
print("All environment variables:")
for key, value in os.environ.items():
    print(f"{key}: {value}")

# Get specific environment variable
home_dir = os.environ.get('HOME')
path_var = os.environ.get('PATH')
print("Home directory:", home_dir)
print("PATH:", path_var)

# Get with default value
database_url = os.environ.get('DATABASE_URL', 'sqlite:///default.db')
print("Database URL:", database_url)
```

#### Setting Environment Variables

```python
import os

# Set environment variable
os.environ['MY_VARIABLE'] = 'my_value'

# Set multiple variables
os.environ.update({
    'API_KEY': 'secret_key',
    'DEBUG': 'true',
    'PORT': '8080'
})

# Remove environment variable
if 'TEMP_VAR' in os.environ:
    del os.environ['TEMP_VAR']

# Pop environment variable
old_value = os.environ.pop('OLD_VAR', 'default')
```

### Process Management

#### Running External Commands

```python
import os

# Execute system command
result = os.system('ls -l')
print("Exit code:", result)

# Execute and capture output (deprecated, use subprocess)
import subprocess

# Modern approach
result = subprocess.run(['ls', '-l'], capture_output=True, text=True)
print("Output:", result.stdout)
print("Error:", result.stderr)
print("Return code:", result.returncode)
```

#### Process Information

```python
import os

# Get process ID
print("Process ID:", os.getpid())

# Get parent process ID
print("Parent PID:", os.getppid())

# Get process group ID (Unix/Linux)
if os.name == 'posix':
    print("Process group ID:", os.getpgid(0))

# Get user and group IDs (Unix/Linux)
if os.name == 'posix':
    print("User ID:", os.getuid())
    print("Group ID:", os.getgid())
    print("Effective user ID:", os.geteuid())
    print("Effective group ID:", os.getegid())
```

#### Process Creation (Unix/Linux)

```python
import os

if os.name == 'posix':
    # Fork process
    pid = os.fork()
    
    if pid == 0:
        # Child process
        print("Child process")
        os._exit(0)
    else:
        # Parent process
        print(f"Parent process, child PID: {pid}")
        os.waitpid(pid, 0)  # Wait for child to complete
```

### System Information

#### Platform and OS Information

```python
import os

# Operating system name
print("OS name:", os.name)  # 'posix', 'nt', 'java'

# Detailed system information
if hasattr(os, 'uname'):
    uname_info = os.uname()
    print("System:", uname_info.sysname)
    print("Node:", uname_info.nodename)
    print("Release:", uname_info.release)
    print("Version:", uname_info.version)
    print("Machine:", uname_info.machine)

# CPU count
print("CPU count:", os.cpu_count())

# Load average (Unix/Linux)
if hasattr(os, 'getloadavg'):
    load1, load5, load15 = os.getloadavg()
    print(f"Load average: {load1:.2f}, {load5:.2f}, {load15:.2f}")
```

#### Memory and Resource Information

```python
import os

# Get terminal size
if hasattr(os, 'get_terminal_size'):
    size = os.get_terminal_size()
    print(f"Terminal size: {size.columns}x{size.lines}")

# Resource limits (Unix/Linux)
if hasattr(os, 'getrlimit'):
    import resource
    soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
    print(f"File descriptor limits: soft={soft}, hard={hard}")
```

### Advanced File Operations

#### File Descriptors

```python
import os

# Open file with file descriptor
fd = os.open('file.txt', os.O_RDONLY)

# Read from file descriptor
data = os.read(fd, 1024)
print("Data:", data.decode())

# Close file descriptor
os.close(fd)

# Write to file descriptor
fd = os.open('output.txt', os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o644)
os.write(fd, b'Hello, World!')
os.close(fd)
```

#### File Locking (Unix/Linux)

```python
import os
import fcntl

if os.name == 'posix':
    # Exclusive lock
    with open('lockfile.txt', 'w') as f:
        fcntl.flock(f.fileno(), fcntl.LOCK_EX)
        f.write('Locked content')
        # Lock released when file is closed
```

#### Pipes and Communication

```python
import os

# Create pipe
if os.name == 'posix':
    read_fd, write_fd = os.pipe()
    
    # Write to pipe
    os.write(write_fd, b'Hello from pipe')
    
    # Read from pipe
    data = os.read(read_fd, 1024)
    print("Pipe data:", data.decode())
    
    # Close file descriptors
    os.close(read_fd)
    os.close(write_fd)
```

### Symbolic Links and Hard Links

#### Creating and Managing Links

```python
import os

# Create symbolic link
os.symlink('target_file.txt', 'link_to_file.txt')

# Create hard link (Unix/Linux)
if os.name == 'posix':
    os.link('original_file.txt', 'hard_link.txt')

# Read symbolic link
if os.path.islink('link_to_file.txt'):
    target = os.readlink('link_to_file.txt')
    print("Link target:", target)

# Check if path is a link
print("Is symbolic link:", os.path.islink('link_to_file.txt'))
```

### Temporary Files and Directories

#### Working with Temporary Files

```python
import os
import tempfile

# Get temporary directory
temp_dir = tempfile.gettempdir()
print("Temp directory:", temp_dir)

# Create temporary file
with tempfile.NamedTemporaryFile(mode='w', delete=False) as temp_file:
    temp_file.write('Temporary content')
    temp_filename = temp_file.name

print("Temporary file:", temp_filename)

# Clean up
os.unlink(temp_filename)

# Create temporary directory
with tempfile.TemporaryDirectory() as temp_dir:
    print("Temporary directory:", temp_dir)
    # Directory is automatically cleaned up
```

### Error Handling

#### Common OS Exceptions

```python
import os

def safe_file_operation(filename):
    try:
        with open(filename, 'r') as f:
            content = f.read()
            return content
    except FileNotFoundError:
        print(f"File not found: {filename}")
    except PermissionError:
        print(f"Permission denied: {filename}")
    except IsADirectoryError:
        print(f"Is a directory: {filename}")
    except OSError as e:
        print(f"OS error: {e}")

def safe_directory_operation(dirname):
    try:
        os.makedirs(dirname, exist_ok=True)
        files = os.listdir(dirname)
        return files
    except PermissionError:
        print(f"Permission denied: {dirname}")
    except NotADirectoryError:
        print(f"Not a directory: {dirname}")
    except OSError as e:
        print(f"OS error: {e}")
```

### Practical Examples

#### File System Monitor

```python
import os
import time

def monitor_directory(path, interval=1):
    """Monitor directory for changes"""
    previous_files = set()
    
    while True:
        try:
            current_files = set(os.listdir(path))
            
            # New files
            new_files = current_files - previous_files
            for file in new_files:
                print(f"New file: {file}")
            
            # Removed files
            removed_files = previous_files - current_files
            for file in removed_files:
                print(f"Removed file: {file}")
            
            previous_files = current_files
            time.sleep(interval)
            
        except KeyboardInterrupt:
            print("Monitoring stopped")
            break
        except OSError as e:
            print(f"Error monitoring directory: {e}")
            break
```

#### Disk Usage Calculator

```python
import os

def calculate_directory_size(path):
    """Calculate total size of directory"""
    total_size = 0
    
    for root, dirs, files in os.walk(path):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                total_size += os.path.getsize(file_path)
            except OSError:
                pass  # Skip files that can't be accessed
    
    return total_size

def format_bytes(bytes):
    """Format bytes in human-readable format"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes < 1024.0:
            return f"{bytes:.2f} {unit}"
        bytes /= 1024.0
    return f"{bytes:.2f} PB"

# Usage
directory = '/path/to/directory'
size = calculate_directory_size(directory)
print(f"Directory size: {format_bytes(size)}")
```

#### Configuration File Manager

```python
import os
import json

class ConfigManager:
    def __init__(self, config_dir=None):
        if config_dir is None:
            config_dir = os.path.expanduser('~/.myapp')
        
        self.config_dir = config_dir
        self.config_file = os.path.join(config_dir, 'config.json')
        
        # Create config directory if it doesn't exist
        os.makedirs(config_dir, exist_ok=True)
    
    def load_config(self):
        """Load configuration from file"""
        if os.path.exists(self.config_file):
            with open(self.config_file, 'r') as f:
                return json.load(f)
        return {}
    
    def save_config(self, config):
        """Save configuration to file"""
        with open(self.config_file, 'w') as f:
            json.dump(config, f, indent=4)
    
    def get_setting(self, key, default=None):
        """Get specific setting"""
        config = self.load_config()
        return config.get(key, default)
    
    def set_setting(self, key, value):
        """Set specific setting"""
        config = self.load_config()
        config[key] = value
        self.save_config(config)

# Usage
config = ConfigManager()
config.set_setting('api_key', 'secret_key')
api_key = config.get_setting('api_key')
```

#### File Backup System

```python
import os
import shutil
import time
from datetime import datetime

class BackupManager:
    def __init__(self, backup_dir):
        self.backup_dir = backup_dir
        os.makedirs(backup_dir, exist_ok=True)
    
    def backup_file(self, source_file):
        """Backup a single file"""
        if not os.path.exists(source_file):
            raise FileNotFoundError(f"Source file not found: {source_file}")
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = os.path.basename(source_file)
        backup_name = f"{timestamp}_{filename}"
        backup_path = os.path.join(self.backup_dir, backup_name)
        
        shutil.copy2(source_file, backup_path)
        return backup_path
    
    def backup_directory(self, source_dir):
        """Backup entire directory"""
        if not os.path.exists(source_dir):
            raise FileNotFoundError(f"Source directory not found: {source_dir}")
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        dir_name = os.path.basename(source_dir)
        backup_name = f"{timestamp}_{dir_name}"
        backup_path = os.path.join(self.backup_dir, backup_name)
        
        shutil.copytree(source_dir, backup_path)
        return backup_path
    
    def list_backups(self):
        """List all backups"""
        backups = []
        for item in os.listdir(self.backup_dir):
            item_path = os.path.join(self.backup_dir, item)
            stat_info = os.stat(item_path)
            backups.append({
                'name': item,
                'path': item_path,
                'size': stat_info.st_size,
                'created': time.ctime(stat_info.st_ctime)
            })
        return sorted(backups, key=lambda x: x['created'], reverse=True)
```

### Platform-Specific Features

#### Windows-Specific Operations

```python
import os

if os.name == 'nt':
    # Windows-specific environment variables
    print("Windows directory:", os.environ.get('WINDIR'))
    print("User profile:", os.environ.get('USERPROFILE'))
    print("Program files:", os.environ.get('PROGRAMFILES'))
    
    # Windows path operations
    drive, path = os.path.splitdrive(r'C:\Windows\System32')
    print("Drive:", drive)
    print("Path:", path)
```

#### Unix/Linux-Specific Operations

```python
import os

if os.name == 'posix':
    # Unix/Linux-specific operations
    print("Home directory:", os.environ.get('HOME'))
    print("Shell:", os.environ.get('SHELL'))
    
    # File permissions
    def get_file_permissions(filename):
        stat_info = os.stat(filename)
        mode = stat_info.st_mode
        
        permissions = []
        permissions.append('r' if mode & 0o400 else '-')
        permissions.append('w' if mode & 0o200 else '-')
        permissions.append('x' if mode & 0o100 else '-')
        permissions.append('r' if mode & 0o040 else '-')
        permissions.append('w' if mode & 0o020 else '-')
        permissions.append('x' if mode & 0o010 else '-')
        permissions.append('r' if mode & 0o004 else '-')
        permissions.append('w' if mode & 0o002 else '-')
        permissions.append('x' if mode & 0o001 else '-')
        
        return ''.join(permissions)
```

### Performance Considerations

#### Efficient File Operations

```python
import os

def efficient_file_search(directory, pattern):
    """Efficiently search for files matching pattern"""
    matches = []
    
    # Use os.scandir for better performance than os.listdir
    with os.scandir(directory) as entries:
        for entry in entries:
            if entry.is_file() and pattern in entry.name:
                matches.append(entry.path)
    
    return matches

def batch_file_operations(file_list, operation):
    """Perform batch operations on multiple files"""
    results = []
    
    for file_path in file_list:
        try:
            result = operation(file_path)
            results.append((file_path, result, None))
        except OSError as e:
            results.append((file_path, None, str(e)))
    
    return results
```

### Security Considerations

#### Safe Path Operations

```python
import os

def safe_path_join(base_path, *paths):
    """Safely join paths to prevent directory traversal"""
    result = os.path.join(base_path, *paths)
    normalized = os.path.normpath(result)
    
    # Ensure the result is within the base path
    if not normalized.startswith(os.path.normpath(base_path)):
        raise ValueError("Path traversal detected")
    
    return normalized

def validate_filename(filename):
    """Validate filename for security"""
    # Check for dangerous characters
    dangerous_chars = ['..', '/', '\\', ':', '*', '?', '"', '<', '>', '|']
    
    for char in dangerous_chars:
        if char in filename:
            raise ValueError(f"Dangerous character in filename: {char}")
    
    # Check for reserved names (Windows)
    reserved_names = ['CON', 'PRN', 'AUX', 'NUL'] + [f'COM{i}' for i in range(1, 10)] + [f'LPT{i}' for i in range(1, 10)]
    
    if filename.upper() in reserved_names:
        raise ValueError(f"Reserved filename: {filename}")
    
    return filename
```

### Best Practices

**Example** of comprehensive file management:

```python
import os
import logging
import tempfile
from contextlib import contextmanager

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FileManager:
    def __init__(self, base_path):
        self.base_path = os.path.abspath(base_path)
        os.makedirs(base_path, exist_ok=True)
    
    @contextmanager
    def temporary_file(self, suffix='.tmp'):
        """Context manager for temporary files"""
        temp_fd, temp_path = tempfile.mkstemp(suffix=suffix, dir=self.base_path)
        try:
            yield temp_path
        finally:
            os.close(temp_fd)
            if os.path.exists(temp_path):
                os.unlink(temp_path)
    
    def safe_write(self, filename, content):
        """Safely write content to file"""
        full_path = os.path.join(self.base_path, filename)
        
        # Write to temporary file first
        with self.temporary_file() as temp_path:
            with open(temp_path, 'w') as f:
                f.write(content)
            
            # Atomically move to final location
            os.rename(temp_path, full_path)
            logger.info(f"Successfully wrote to {filename}")
    
    def safe_read(self, filename):
        """Safely read file content"""
        full_path = os.path.join(self.base_path, filename)
        
        if not os.path.exists(full_path):
            raise FileNotFoundError(f"File not found: {filename}")
        
        with open(full_path, 'r') as f:
            return f.read()
    
    def list_files(self, pattern=None):
        """List files with optional pattern matching"""
        files = []
        
        for item in os.listdir(self.base_path):
            item_path = os.path.join(self.base_path, item)
            if os.path.isfile(item_path):
                if pattern is None or pattern in item:
                    files.append(item)
        
        return sorted(files)
```

**Conclusion:** The `os` module is fundamental for system programming in Python, providing comprehensive access to operating system functionality. It enables file and directory operations, process management, environment variable manipulation, and system information retrieval. Understanding its capabilities is essential for writing robust, cross-platform applications that interact with the file system and operating system services. Always consider security implications when working with file paths and system operations, and use appropriate error handling for robust applications.

---

## `math` Module

### Overview

The math module is a built-in Python library that provides access to mathematical functions and constants defined by the C standard. It offers a comprehensive collection of mathematical operations including trigonometric functions, logarithms, exponentials, and various utility functions for numerical computations.

### Importing the Math Module

```python
import math
```

Once imported, all functions and constants are accessed using the `math.` prefix.

### Mathematical Constants

#### pi

The mathematical constant π (pi), approximately 3.14159.

```python
import math
print(math.pi)  # 3.141592653589793
```

#### e

The mathematical constant e (Euler's number), approximately 2.71828.

```python
print(math.e)  # 2.718281828459045
```

#### tau

The mathematical constant τ (tau), equal to 2π, approximately 6.28318.

```python
print(math.tau)  # 6.283185307179586
```

#### inf

Positive infinity as a floating-point value.

```python
print(math.inf)  # inf
```

#### nan

"Not a Number" (NaN) floating-point value.

```python
print(math.nan)  # nan
```

### Power and Logarithmic Functions

#### math.pow(x, y)

Returns x raised to the power y.

```python
result = math.pow(2, 3)  # 8.0
```

#### math.sqrt(x)

Returns the square root of x.

```python
result = math.sqrt(16)  # 4.0
```

#### math.log(x[, base])

Returns the natural logarithm of x, or logarithm to the given base.

```python
natural_log = math.log(math.e)  # 1.0
log_base_10 = math.log(100, 10)  # 2.0
```

#### math.log10(x)

Returns the base-10 logarithm of x.

```python
result = math.log10(1000)  # 3.0
```

#### math.log2(x)

Returns the base-2 logarithm of x.

```python
result = math.log2(8)  # 3.0
```

#### math.exp(x)

Returns e raised to the power x.

```python
result = math.exp(1)  # 2.718281828459045
```

#### math.exp2(x)

Returns 2 raised to the power x.

```python
result = math.exp2(3)  # 8.0
```

#### math.expm1(x)

Returns e^x - 1, providing better precision for small values of x.

```python
result = math.expm1(0.001)  # More accurate than math.exp(0.001) - 1
```

#### math.log1p(x)

Returns ln(1 + x), providing better precision for small values of x.

```python
result = math.log1p(0.001)  # More accurate than math.log(1 + 0.001)
```

### Trigonometric Functions

#### Basic Trigonometric Functions

```python
# Sine, cosine, and tangent
angle = math.pi / 4  # 45 degrees in radians
sin_val = math.sin(angle)    # 0.7071067811865476
cos_val = math.cos(angle)    # 0.7071067811865476
tan_val = math.tan(angle)    # 1.0
```

#### Inverse Trigonometric Functions

```python
# Arc sine, arc cosine, and arc tangent
value = 0.5
asin_val = math.asin(value)  # 0.5235987755982989
acos_val = math.acos(value)  # 1.0471975511965979
atan_val = math.atan(value)  # 0.4636476090008061
```

#### math.atan2(y, x)

Returns the arc tangent of y/x in radians, considering the signs of both arguments.

```python
result = math.atan2(1, 1)  # 0.7853981633974483 (45 degrees)
```

#### Hyperbolic Functions

```python
x = 1.0
sinh_val = math.sinh(x)  # 1.1752011936438014
cosh_val = math.cosh(x)  # 1.5430806348152437
tanh_val = math.tanh(x)  # 0.7615941559557649
```

#### Inverse Hyperbolic Functions

```python
x = 1.0
asinh_val = math.asinh(x)  # 0.8813735870195429
acosh_val = math.acosh(x)  # 0.0
atanh_val = math.atanh(0.5)  # 0.5493061443340549
```

### Rounding and Numeric Functions

#### math.ceil(x)

Returns the ceiling of x (smallest integer greater than or equal to x).

```python
result = math.ceil(4.2)   # 5
result = math.ceil(-4.2)  # -4
```

#### math.floor(x)

Returns the floor of x (largest integer less than or equal to x).

```python
result = math.floor(4.8)   # 4
result = math.floor(-4.8)  # -5
```

#### math.trunc(x)

Returns the truncated integer part of x.

```python
result = math.trunc(4.8)   # 4
result = math.trunc(-4.8)  # -4
```

#### math.fabs(x)

Returns the absolute value of x as a float.

```python
result = math.fabs(-5.5)  # 5.5
```

#### math.copysign(x, y)

Returns x with the sign of y.

```python
result = math.copysign(5, -1)  # -5.0
```

#### math.fmod(x, y)

Returns the floating-point remainder of x/y.

```python
result = math.fmod(10.5, 3)  # 1.5
```

#### math.remainder(x, y)

Returns the IEEE remainder of x with respect to y.

```python
result = math.remainder(10.5, 3)  # -1.5
```

#### math.modf(x)

Returns the fractional and integer parts of x as a tuple.

```python
fractional, integer = math.modf(4.75)  # (0.75, 4.0)
```

### Classification Functions

#### math.isfinite(x)

Returns True if x is finite (not infinite or NaN).

```python
result = math.isfinite(5.0)      # True
result = math.isfinite(math.inf) # False
```

#### math.isinf(x)

Returns True if x is positive or negative infinity.

```python
result = math.isinf(math.inf)  # True
result = math.isinf(5.0)       # False
```

#### math.isnan(x)

Returns True if x is NaN (Not a Number).

```python
result = math.isnan(math.nan)  # True
result = math.isnan(5.0)       # False
```

#### math.isclose(a, b, rel_tol=1e-09, abs_tol=0.0)

Returns True if values a and b are close to each other.

```python
result = math.isclose(0.1 + 0.2, 0.3)  # True
result = math.isclose(1.0, 1.01, rel_tol=0.1)  # True
```

### Distance and Norm Functions

#### math.dist(p, q)

Returns the Euclidean distance between points p and q.

```python
point1 = [1, 2, 3]
point2 = [4, 5, 6]
distance = math.dist(point1, point2)  # 5.196152422706632
```

#### math.hypot(*coordinates)

Returns the Euclidean norm (distance from origin).

```python
# 2D distance
distance = math.hypot(3, 4)  # 5.0

# 3D distance
distance = math.hypot(1, 2, 3)  # 3.7416573867739413
```

### Factorial and Combinatorial Functions

#### math.factorial(n)

Returns the factorial of n.

```python
result = math.factorial(5)  # 120
```

#### math.comb(n, k)

Returns the number of ways to choose k items from n items.

```python
result = math.comb(5, 2)  # 10
```

#### math.perm(n, k)

Returns the number of ways to arrange k items from n items.

```python
result = math.perm(5, 2)  # 20
```

### Angle Conversion Functions

#### math.degrees(x)

Converts angle x from radians to degrees.

```python
degrees = math.degrees(math.pi)  # 180.0
degrees = math.degrees(math.pi / 2)  # 90.0
```

#### math.radians(x)

Converts angle x from degrees to radians.

```python
radians = math.radians(180)  # 3.141592653589793
radians = math.radians(90)   # 1.5707963267948966
```

### Special Functions

#### math.gamma(x)

Returns the gamma function at x.

```python
result = math.gamma(5)  # 24.0 (equivalent to factorial(4))
```

#### math.lgamma(x)

Returns the natural logarithm of the gamma function at x.

```python
result = math.lgamma(5)  # 3.1780538303479458
```

#### math.erf(x)

Returns the error function at x.

```python
result = math.erf(1)  # 0.8427007929497149
```

#### math.erfc(x)

Returns the complementary error function at x.

```python
result = math.erfc(1)  # 0.15729920705028513
```

### Utility Functions

#### math.fsum(iterable)

Returns an accurate floating-point sum of values in the iterable.

```python
numbers = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
result = math.fsum(numbers)  # 1.0 (more accurate than sum())
```

#### math.prod(iterable, start=1)

Returns the product of all elements in the iterable.

```python
numbers = [1, 2, 3, 4, 5]
result = math.prod(numbers)  # 120
```

#### math.gcd(a, b)

Returns the greatest common divisor of a and b.

```python
result = math.gcd(48, 18)  # 6
```

#### math.lcm(*args)

Returns the least common multiple of the arguments.

```python
result = math.lcm(12, 18)  # 36
result = math.lcm(12, 18, 24)  # 72
```

#### math.frexp(x)

Returns the mantissa and exponent of x as a tuple.

```python
mantissa, exponent = math.frexp(8.0)  # (0.5, 4) because 8.0 = 0.5 * 2^4
```

#### math.ldexp(x, i)

Returns x * (2**i), the inverse of frexp().

```python
result = math.ldexp(0.5, 4)  # 8.0
```

#### math.nextafter(x, y)

Returns the next representable floating-point value after x in the direction of y.

```python
result = math.nextafter(1.0, 2.0)  # 1.0000000000000002
```

#### math.ulp(x)

Returns the value of the least significant bit of x.

```python
result = math.ulp(1.0)  # 2.220446049250313e-16
```

### Practical Examples

#### Distance Calculations

```python
import math

# Calculate distance between two points
def distance_2d(x1, y1, x2, y2):
    return math.sqrt((x2 - x1)**2 + (y2 - y1)**2)

# Using hypot for better precision
def distance_2d_hypot(x1, y1, x2, y2):
    return math.hypot(x2 - x1, y2 - y1)

# 3D distance
def distance_3d(p1, p2):
    return math.dist(p1, p2)
```

#### Angle Calculations

```python
import math

# Convert between degrees and radians
def deg_to_rad(degrees):
    return math.radians(degrees)

def rad_to_deg(radians):
    return math.degrees(radians)

# Calculate angle between two vectors
def angle_between_vectors(v1, v2):
    dot_product = sum(a * b for a, b in zip(v1, v2))
    magnitude_v1 = math.hypot(*v1)
    magnitude_v2 = math.hypot(*v2)
    return math.acos(dot_product / (magnitude_v1 * magnitude_v2))
```

#### Statistical Calculations

```python
import math

# Calculate standard deviation
def standard_deviation(data):
    n = len(data)
    mean = sum(data) / n
    variance = sum((x - mean) ** 2 for x in data) / n
    return math.sqrt(variance)

# Calculate geometric mean
def geometric_mean(data):
    product = math.prod(data)
    return product ** (1 / len(data))
```

### Error Handling

The math module raises specific exceptions for invalid operations:

```python
import math

try:
    result = math.sqrt(-1)  # Raises ValueError
except ValueError as e:
    print(f"Error: {e}")

try:
    result = math.log(0)  # Raises ValueError
except ValueError as e:
    print(f"Error: {e}")

try:
    result = math.factorial(-1)  # Raises ValueError
except ValueError as e:
    print(f"Error: {e}")
```

### Performance Considerations

The math module functions are implemented in C and are highly optimized. However, for array operations, consider using NumPy for better performance:

```python
import math
import time

# Using math module (slower for large datasets)
def process_with_math(data):
    return [math.sqrt(x) for x in data]

# For large arrays, NumPy is more efficient
import numpy as np
def process_with_numpy(data):
    return np.sqrt(data)
```

### Common Pitfalls

#### Floating-Point Precision

```python
import math

# Avoid direct equality comparisons
result = math.sqrt(2) ** 2
print(result == 2)  # False due to floating-point precision

# Use isclose() instead
print(math.isclose(result, 2))  # True
```

#### Domain Errors

```python
import math

# Check for valid domains
def safe_sqrt(x):
    if x < 0:
        raise ValueError("Cannot compute square root of negative number")
    return math.sqrt(x)

def safe_log(x):
    if x <= 0:
        raise ValueError("Logarithm undefined for non-positive numbers")
    return math.log(x)
```

**Key points:** The math module provides essential mathematical functions and constants for Python programming. It offers comprehensive coverage of basic arithmetic, trigonometry, logarithms, and special functions. All functions operate on and return floating-point numbers, making it ideal for scientific computing and mathematical applications.

**Next steps:** For more advanced mathematical operations, consider exploring NumPy for array operations, SciPy for scientific computing, or the decimal module for precise decimal arithmetic.

---

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

## `datetime` Module

### Overview

The datetime module is a built-in Python library that provides classes for manipulating dates and times. It offers comprehensive functionality for parsing, formatting, arithmetic operations, and timezone handling with date and time values. The module is designed to be more intuitive and feature-rich than the older time module.

### Importing the Datetime Module

```python
import datetime
from datetime import datetime, date, time, timedelta, timezone
```

### Core Classes

#### datetime.datetime

Represents a specific moment in time with date and time components.

```python
from datetime import datetime

# Create datetime objects
now = datetime.now()
specific_time = datetime(2023, 12, 25, 15, 30, 45)
print(specific_time)  # 2023-12-25 15:30:45
```

#### datetime.date

Represents a date (year, month, day) without time information.

```python
from datetime import date

# Create date objects
today = date.today()
specific_date = date(2023, 12, 25)
print(specific_date)  # 2023-12-25
```

#### datetime.time

Represents a time (hour, minute, second, microsecond) without date information.

```python
from datetime import time

# Create time objects
specific_time = time(15, 30, 45)
with_microseconds = time(15, 30, 45, 123456)
print(specific_time)  # 15:30:45
```

#### datetime.timedelta

Represents a duration, the difference between two dates or times.

```python
from datetime import timedelta

# Create timedelta objects
one_week = timedelta(weeks=1)
mixed_duration = timedelta(days=5, hours=3, minutes=30)
print(one_week)  # 7 days, 0:00:00
```

#### datetime.timezone

Represents timezone information.

```python
from datetime import timezone, timedelta

# Create timezone objects
utc = timezone.utc
eastern = timezone(timedelta(hours=-5))
```

### Creating Datetime Objects

#### Current Date and Time

```python
from datetime import datetime, date, time

# Current date and time
now = datetime.now()
today = date.today()
current_time = datetime.now().time()
```

#### Specific Date and Time

```python
# Various ways to create datetime objects
specific_datetime = datetime(2023, 12, 25, 15, 30, 45)
from_date_and_time = datetime.combine(date(2023, 12, 25), time(15, 30, 45))
```

#### From Timestamps

```python
import time
from datetime import datetime

# From Unix timestamp
timestamp = time.time()
from_timestamp = datetime.fromtimestamp(timestamp)
utc_from_timestamp = datetime.utcfromtimestamp(timestamp)
```

#### From ISO Format

```python
from datetime import datetime

# From ISO 8601 format
iso_string = "2023-12-25T15:30:45"
from_iso = datetime.fromisoformat(iso_string)
```

### Formatting and Parsing

#### strftime() - Format to String

```python
from datetime import datetime

dt = datetime(2023, 12, 25, 15, 30, 45)

# Common format codes
formatted = dt.strftime("%Y-%m-%d %H:%M:%S")  # 2023-12-25 15:30:45
date_only = dt.strftime("%Y-%m-%d")           # 2023-12-25
time_only = dt.strftime("%H:%M:%S")           # 15:30:45
readable = dt.strftime("%B %d, %Y at %I:%M %p")  # December 25, 2023 at 03:30 PM
```

#### Format Codes Reference

```python
# Common format codes
codes = {
    "%Y": "4-digit year",
    "%y": "2-digit year",
    "%m": "Month as number (01-12)",
    "%B": "Full month name",
    "%b": "Abbreviated month name",
    "%d": "Day of month (01-31)",
    "%H": "Hour (00-23)",
    "%I": "Hour (01-12)",
    "%M": "Minute (00-59)",
    "%S": "Second (00-59)",
    "%p": "AM/PM",
    "%A": "Full weekday name",
    "%a": "Abbreviated weekday name",
    "%w": "Weekday as number (0-6)",
    "%z": "UTC offset",
    "%Z": "Timezone name"
}
```

#### strptime() - Parse from String

```python
from datetime import datetime

# Parse various formats
date_string = "2023-12-25 15:30:45"
parsed = datetime.strptime(date_string, "%Y-%m-%d %H:%M:%S")

# Different format
date_string2 = "December 25, 2023"
parsed2 = datetime.strptime(date_string2, "%B %d, %Y")
```

### Date and Time Arithmetic

#### Using timedelta

```python
from datetime import datetime, timedelta

now = datetime.now()

# Add time
future = now + timedelta(days=7, hours=3, minutes=30)
past = now - timedelta(weeks=2)

# More complex operations
next_month = now + timedelta(days=30)
in_one_year = now + timedelta(days=365)
```

#### Duration Between Dates

```python
from datetime import datetime, date

# Calculate differences
start_date = datetime(2023, 1, 1)
end_date = datetime(2023, 12, 31)
difference = end_date - start_date
print(difference.days)  # 364
print(difference.total_seconds())  # 31,449,600
```

#### Timedelta Operations

```python
from datetime import timedelta

# Create timedelta objects
one_week = timedelta(weeks=1)
one_day = timedelta(days=1)
one_hour = timedelta(hours=1)

# Arithmetic operations
combined = one_week + one_day + one_hour
multiplied = one_day * 7
divided = one_week / 7
```

### Working with Dates

#### Date Attributes and Methods

```python
from datetime import date

today = date.today()
specific_date = date(2023, 12, 25)

# Attributes
print(today.year)     # 2023
print(today.month)    # Current month
print(today.day)      # Current day

# Methods
print(today.weekday())     # Monday is 0, Sunday is 6
print(today.isoweekday())  # Monday is 1, Sunday is 7
print(today.strftime("%A"))  # Full weekday name
```

#### Date Comparison

```python
from datetime import date

date1 = date(2023, 12, 25)
date2 = date(2023, 12, 31)

# Comparison operations
print(date1 < date2)   # True
print(date1 == date2)  # False
print(date1 > date2)   # False
```

#### Date Arithmetic

```python
from datetime import date, timedelta

today = date.today()
tomorrow = today + timedelta(days=1)
last_week = today - timedelta(weeks=1)

# Calculate age
birth_date = date(1990, 5, 15)
age = today - birth_date
print(f"Age in days: {age.days}")
```

### Working with Time

#### Time Attributes and Methods

```python
from datetime import time

specific_time = time(15, 30, 45, 123456)

# Attributes
print(specific_time.hour)        # 15
print(specific_time.minute)      # 30
print(specific_time.second)      # 45
print(specific_time.microsecond) # 123456
```

#### Time Comparison

```python
from datetime import time

time1 = time(9, 30)
time2 = time(17, 45)

print(time1 < time2)  # True
print(time1.strftime("%I:%M %p"))  # 09:30 AM
```

### Working with Datetime

#### Datetime Attributes and Methods

```python
from datetime import datetime

dt = datetime(2023, 12, 25, 15, 30, 45, 123456)

# Date components
print(dt.year, dt.month, dt.day)

# Time components
print(dt.hour, dt.minute, dt.second, dt.microsecond)

# Extract date and time
date_part = dt.date()
time_part = dt.time()
```

#### Datetime Arithmetic

```python
from datetime import datetime, timedelta

now = datetime.now()

# Add/subtract time
future = now + timedelta(days=30, hours=5)
past = now - timedelta(weeks=2, days=3)

# Calculate duration
event_time = datetime(2023, 12, 25, 18, 0)
time_until_event = event_time - now
```

### Timezone Handling

#### Creating Timezone-Aware Objects

```python
from datetime import datetime, timezone, timedelta

# UTC timezone
utc_time = datetime.now(timezone.utc)

# Custom timezone
est = timezone(timedelta(hours=-5))
est_time = datetime.now(est)

# From timestamp with timezone
import time
timestamp = time.time()
aware_dt = datetime.fromtimestamp(timestamp, tz=timezone.utc)
```

#### Converting Between Timezones

```python
from datetime import datetime, timezone, timedelta

# Create timezone-aware datetime
utc = timezone.utc
eastern = timezone(timedelta(hours=-5))
pacific = timezone(timedelta(hours=-8))

# UTC time
utc_time = datetime.now(utc)

# Convert to other timezones
eastern_time = utc_time.astimezone(eastern)
pacific_time = utc_time.astimezone(pacific)
```

#### Working with pytz (Third-party library)

```python
# Note: pytz is not built-in, requires installation
import pytz
from datetime import datetime

# Create timezone-aware datetime with pytz
utc = pytz.UTC
eastern = pytz.timezone('US/Eastern')
pacific = pytz.timezone('US/Pacific')

# Localize naive datetime
naive_dt = datetime(2023, 12, 25, 15, 30)
localized = eastern.localize(naive_dt)

# Convert between timezones
pacific_time = localized.astimezone(pacific)
```

### Advanced Operations

#### Working with Weekdays

```python
from datetime import datetime, timedelta

def get_next_weekday(date, weekday):
    """Get the next occurrence of a specific weekday"""
    days_ahead = weekday - date.weekday()
    if days_ahead <= 0:
        days_ahead += 7
    return date + timedelta(days_ahead)

# Get next Monday (0 = Monday)
today = datetime.now()
next_monday = get_next_weekday(today, 0)
```

#### Month and Year Operations

```python
from datetime import datetime, timedelta
import calendar

def add_months(date, months):
    """Add months to a date"""
    month = date.month - 1 + months
    year = date.year + month // 12
    month = month % 12 + 1
    day = min(date.day, calendar.monthrange(year, month)[1])
    return date.replace(year=year, month=month, day=day)

# Add 3 months to current date
current_date = datetime.now()
future_date = add_months(current_date, 3)
```

#### Business Day Calculations

```python
from datetime import datetime, timedelta

def add_business_days(date, business_days):
    """Add business days (excluding weekends)"""
    while business_days > 0:
        date += timedelta(days=1)
        if date.weekday() < 5:  # Monday to Friday
            business_days -= 1
    return date

# Add 5 business days
start_date = datetime(2023, 12, 20)
end_date = add_business_days(start_date, 5)
```

### Practical Examples

#### Age Calculator

```python
from datetime import date

def calculate_age(birth_date):
    """Calculate age in years"""
    today = date.today()
    age = today.year - birth_date.year
    
    # Check if birthday has occurred this year
    if (today.month, today.day) < (birth_date.month, birth_date.day):
        age -= 1
    
    return age

# Example usage
birth_date = date(1990, 5, 15)
age = calculate_age(birth_date)
print(f"Age: {age} years")
```

#### Date Range Generator

```python
from datetime import datetime, timedelta

def date_range(start_date, end_date, step=timedelta(days=1)):
    """Generate dates between start and end"""
    current = start_date
    while current < end_date:
        yield current
        current += step

# Generate all dates in a month
start = datetime(2023, 12, 1)
end = datetime(2023, 12, 31)
for date in date_range(start, end):
    print(date.strftime("%Y-%m-%d"))
```

#### Working Hours Calculator

```python
from datetime import datetime, timedelta

def calculate_working_hours(start_date, end_date, work_start=9, work_end=17):
    """Calculate working hours between two dates"""
    total_hours = 0
    current = start_date
    
    while current.date() <= end_date.date():
        # Skip weekends
        if current.weekday() < 5:
            if current.date() == start_date.date():
                # First day - use actual start time
                work_start_time = max(current.time(), datetime.min.time().replace(hour=work_start))
            else:
                work_start_time = datetime.min.time().replace(hour=work_start)
            
            if current.date() == end_date.date():
                # Last day - use actual end time
                work_end_time = min(end_date.time(), datetime.min.time().replace(hour=work_end))
            else:
                work_end_time = datetime.min.time().replace(hour=work_end)
            
            # Calculate hours for this day
            if work_end_time > work_start_time:
                day_hours = (datetime.combine(current.date(), work_end_time) - 
                           datetime.combine(current.date(), work_start_time)).total_seconds() / 3600
                total_hours += max(0, min(8, day_hours))
        
        current += timedelta(days=1)
    
    return total_hours
```

#### Recurring Event Generator

```python
from datetime import datetime, timedelta

def generate_recurring_events(start_date, recurrence_pattern, count=10):
    """Generate recurring events"""
    events = []
    current_date = start_date
    
    for i in range(count):
        events.append(current_date)
        
        if recurrence_pattern == 'daily':
            current_date += timedelta(days=1)
        elif recurrence_pattern == 'weekly':
            current_date += timedelta(weeks=1)
        elif recurrence_pattern == 'monthly':
            # Simple monthly (same day of month)
            if current_date.month == 12:
                current_date = current_date.replace(year=current_date.year + 1, month=1)
            else:
                current_date = current_date.replace(month=current_date.month + 1)
    
    return events
```

### Error Handling

#### Common Exceptions

```python
from datetime import datetime, date

# ValueError - Invalid date/time values
try:
    invalid_date = date(2023, 13, 1)  # Invalid month
except ValueError as e:
    print(f"Error: {e}")

# TypeError - Wrong type
try:
    result = datetime.now() + 5  # Can't add int to datetime
except TypeError as e:
    print(f"Error: {e}")

# AttributeError - Invalid attribute
try:
    d = date.today()
    print(d.hour)  # date objects don't have hour attribute
except AttributeError as e:
    print(f"Error: {e}")
```

#### Safe Date Operations

```python
from datetime import datetime, date
import calendar

def safe_date_create(year, month, day):
    """Safely create a date, handling invalid days"""
    try:
        return date(year, month, day)
    except ValueError:
        # Use last valid day of month
        last_day = calendar.monthrange(year, month)[1]
        return date(year, month, min(day, last_day))

def safe_parse_date(date_string, format_string):
    """Safely parse date string"""
    try:
        return datetime.strptime(date_string, format_string)
    except ValueError as e:
        print(f"Unable to parse date: {e}")
        return None
```

### Performance Considerations

#### Efficient Date Operations

```python
from datetime import datetime, date

# Use date objects for date-only operations
today = date.today()  # More efficient than datetime.now().date()

# Cache expensive operations
import functools

@functools.lru_cache(maxsize=128)
def get_first_day_of_month(year, month):
    return date(year, month, 1)

# Use comparison instead of conversion when possible
def is_weekend(date_obj):
    return date_obj.weekday() >= 5  # More efficient than string comparison
```

#### Memory-Efficient Date Iteration

```python
from datetime import date, timedelta

def efficient_date_range(start_date, end_date):
    """Memory-efficient date generator"""
    current = start_date
    while current <= end_date:
        yield current
        current += timedelta(days=1)

# Use generator instead of creating list
for date in efficient_date_range(date(2023, 1, 1), date(2023, 12, 31)):
    # Process date without storing all dates in memory
    pass
```

### Integration with Other Libraries

#### With JSON

```python
import json
from datetime import datetime

# Custom JSON encoder for datetime
class DateTimeEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        return super().default(obj)

# Usage
data = {'timestamp': datetime.now()}
json_string = json.dumps(data, cls=DateTimeEncoder)
```

#### With Pandas

```python
import pandas as pd
from datetime import datetime

# Create pandas Series with datetime
dates = pd.date_range(start='2023-01-01', end='2023-12-31', freq='D')
df = pd.DataFrame({'date': dates})

# Convert datetime objects to pandas
py_dates = [datetime(2023, 1, 1), datetime(2023, 1, 2)]
df_from_py = pd.DataFrame({'date': pd.to_datetime(py_dates)})
```

### Best Practices

#### Code Organization

```python
from datetime import datetime, timezone
import pytz

class DateTimeHelper:
    """Helper class for common datetime operations"""
    
    @staticmethod
    def now_utc():
        """Get current UTC time"""
        return datetime.now(timezone.utc)
    
    @staticmethod
    def format_for_display(dt):
        """Format datetime for user display"""
        return dt.strftime("%B %d, %Y at %I:%M %p")
    
    @staticmethod
    def parse_iso(iso_string):
        """Parse ISO format string safely"""
        try:
            return datetime.fromisoformat(iso_string)
        except ValueError:
            return None
```

#### Configuration Management

```python
from datetime import datetime, timezone

class Config:
    DEFAULT_TIMEZONE = timezone.utc
    DATE_FORMAT = "%Y-%m-%d"
    DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"
    DISPLAY_FORMAT = "%B %d, %Y at %I:%M %p"

def format_date(dt, format_type='default'):
    """Format date according to configuration"""
    formats = {
        'default': Config.DATE_FORMAT,
        'datetime': Config.DATETIME_FORMAT,
        'display': Config.DISPLAY_FORMAT
    }
    return dt.strftime(formats.get(format_type, Config.DATE_FORMAT))
```

**Key points:** The datetime module provides comprehensive date and time handling capabilities with separate classes for dates, times, and combined datetime objects. It offers robust parsing and formatting options, timezone support, and arithmetic operations. The module is essential for any application that needs to work with temporal data, from simple date calculations to complex timezone-aware applications.

**Next steps:** For more advanced timezone handling, consider using the zoneinfo module (Python 3.9+) or the pytz library. For high-performance date operations with large datasets, explore pandas' datetime functionality. For more complex date parsing, investigate the dateutil library.

---

## `time` Module

### Overview

The `time` module provides functions for working with time-related operations in Python. It handles time representations, formatting, parsing, and sleeping operations. The module works with both system time and provides utilities for measuring elapsed time, making it essential for scheduling, performance measurement, and time-based operations.

### Importing the Module

```python
import time
from time import sleep, time, strftime  # Import specific functions
```

### Time Representations

#### Epoch Time

Unix timestamp representing seconds since January 1, 1970, 00:00:00 UTC.

```python
import time

# Current time as timestamp
current_time = time.time()
print(current_time)  # 1720497234.567890

# Convert timestamp to readable format
print(time.ctime(current_time))  # Wed Jul 09 14:20:34 2025
```

#### Struct Time

A named tuple containing time components.

```python
# Current time as struct_time
current_struct = time.localtime()
print(current_struct)
# time.struct_time(tm_year=2025, tm_mon=7, tm_mday=9, tm_hour=14, tm_min=20, tm_sec=34, tm_wday=2, tm_yday=190, tm_isdst=0)

# Access individual components
print(current_struct.tm_year)   # 2025
print(current_struct.tm_mon)    # 7
print(current_struct.tm_mday)   # 9
print(current_struct.tm_hour)   # 14
```

### Core Time Functions

#### time()

Returns current time as a floating-point number of seconds since epoch.

```python
start = time.time()
# Some operation
end = time.time()
duration = end - start
print(f"Operation took {duration:.4f} seconds")
```

#### sleep(seconds)

Suspends execution for the specified number of seconds.

```python
print("Starting...")
time.sleep(2)      # Sleep for 2 seconds
print("2 seconds later")

time.sleep(0.5)    # Sleep for 500 milliseconds
print("0.5 seconds later")
```

#### localtime(seconds)

Converts timestamp to local time struct_time.

```python
# Current local time
local_time = time.localtime()
print(local_time)

# Convert specific timestamp
timestamp = 1720497234
local_time = time.localtime(timestamp)
print(local_time)
```

#### gmtime(seconds)

Converts timestamp to UTC time struct_time.

```python
# Current UTC time
utc_time = time.gmtime()
print(utc_time)

# Convert specific timestamp to UTC
utc_time = time.gmtime(1720497234)
print(utc_time)
```

#### mktime(time_tuple)

Converts struct_time to timestamp.

```python
# Create a specific time
time_tuple = (2025, 7, 9, 14, 30, 0, 0, 0, 0)
timestamp = time.mktime(time_tuple)
print(timestamp)  # 1720497000.0
```

### Time Formatting and Parsing

#### strftime(format, time_tuple)

Formats time according to format string.

```python
# Current time formatting
now = time.localtime()
print(time.strftime("%Y-%m-%d %H:%M:%S", now))  # 2025-07-09 14:30:00
print(time.strftime("%A, %B %d, %Y", now))     # Wednesday, July 09, 2025
print(time.strftime("%I:%M %p", now))           # 02:30 PM

# Common format codes
formats = {
    "%Y": "Year with century (2025)",
    "%y": "Year without century (25)",
    "%m": "Month as number (07)",
    "%B": "Full month name (July)",
    "%b": "Abbreviated month (Jul)",
    "%d": "Day of month (09)",
    "%A": "Full weekday name (Wednesday)",
    "%a": "Abbreviated weekday (Wed)",
    "%H": "Hour 24-hour format (14)",
    "%I": "Hour 12-hour format (02)",
    "%M": "Minute (30)",
    "%S": "Second (00)",
    "%p": "AM/PM indicator"
}
```

#### strptime(string, format)

Parses time string according to format.

```python
# Parse date string
date_string = "2025-07-09 14:30:00"
parsed_time = time.strptime(date_string, "%Y-%m-%d %H:%M:%S")
print(parsed_time)

# Parse different formats
time_str = "July 9, 2025 2:30 PM"
parsed = time.strptime(time_str, "%B %d, %Y %I:%M %p")
print(parsed)
```

#### ctime(seconds)

Converts timestamp to readable string.

```python
print(time.ctime())           # Current time
print(time.ctime(1720497234)) # Wed Jul  9 14:20:34 2025
```

#### asctime(time_tuple)

Converts struct_time to readable string.

```python
current_time = time.localtime()
print(time.asctime(current_time))  # Wed Jul  9 14:30:00 2025
```

### Performance Measurement

#### Timing Code Execution

```python
import time

def time_function(func, *args, **kwargs):
    start = time.time()
    result = func(*args, **kwargs)
    end = time.time()
    print(f"Function took {end - start:.4f} seconds")
    return result

def slow_operation():
    time.sleep(1)
    return "Done"

result = time_function(slow_operation)
```

#### High-Resolution Timing

```python
# More precise timing using perf_counter
start = time.perf_counter()
# Some operation
end = time.perf_counter()
duration = end - start
print(f"High precision duration: {duration:.9f} seconds")
```

#### Process and Thread Time

```python
# CPU time spent by current process
process_time = time.process_time()
print(f"Process time: {process_time}")

# Thread time
thread_time = time.thread_time()
print(f"Thread time: {thread_time}")
```

### Time Zones and UTC

#### Working with UTC

```python
# Current UTC timestamp
utc_timestamp = time.time()
print(f"UTC timestamp: {utc_timestamp}")

# Convert to UTC struct_time
utc_struct = time.gmtime(utc_timestamp)
print(f"UTC time: {time.asctime(utc_struct)}")

# Convert to local time
local_struct = time.localtime(utc_timestamp)
print(f"Local time: {time.asctime(local_struct)}")
```

#### Time Zone Information

```python
# Get timezone information
print(f"Timezone: {time.tzname}")      # ('UTC', 'UTC') or ('EST', 'EDT')
print(f"Daylight saving: {time.daylight}")  # 0 or 1
print(f"Timezone offset: {time.timezone}")  # Seconds west of UTC
```

### Advanced Time Operations

#### Creating Custom Time Objects

```python
def create_time(year, month, day, hour=0, minute=0, second=0):
    """Create a timestamp from individual components"""
    time_tuple = (year, month, day, hour, minute, second, 0, 0, 0)
    return time.mktime(time_tuple)

# Create specific time
birthday = create_time(2025, 12, 25, 9, 30, 0)
print(f"Birthday timestamp: {birthday}")
print(f"Birthday: {time.ctime(birthday)}")
```

#### Time Calculations

```python
# Calculate days between dates
def days_between(date1, date2):
    """Calculate days between two date strings"""
    format_str = "%Y-%m-%d"
    time1 = time.mktime(time.strptime(date1, format_str))
    time2 = time.mktime(time.strptime(date2, format_str))
    return abs(time2 - time1) / (24 * 60 * 60)

days = days_between("2025-01-01", "2025-07-09")
print(f"Days between: {days}")
```

#### Time Intervals

```python
def format_duration(seconds):
    """Format seconds into human-readable duration"""
    minutes, seconds = divmod(seconds, 60)
    hours, minutes = divmod(minutes, 60)
    days, hours = divmod(hours, 24)
    
    parts = []
    if days:
        parts.append(f"{int(days)} days")
    if hours:
        parts.append(f"{int(hours)} hours")
    if minutes:
        parts.append(f"{int(minutes)} minutes")
    if seconds:
        parts.append(f"{int(seconds)} seconds")
    
    return ", ".join(parts)

duration = 90061  # seconds
print(format_duration(duration))  # 1 days, 1 hours, 1 minutes, 1 seconds
```

### Practical Applications

#### Scheduling and Delays

```python
def schedule_task(task_func, delay_seconds):
    """Schedule a task to run after a delay"""
    print(f"Task scheduled for {delay_seconds} seconds from now")
    time.sleep(delay_seconds)
    task_func()

def my_task():
    print("Task executed!")

schedule_task(my_task, 3)  # Run after 3 seconds
```

#### Rate Limiting

```python
class RateLimiter:
    def __init__(self, max_calls, time_window):
        self.max_calls = max_calls
        self.time_window = time_window
        self.calls = []
    
    def can_make_call(self):
        now = time.time()
        # Remove old calls outside the time window
        self.calls = [call_time for call_time in self.calls 
                     if now - call_time <= self.time_window]
        
        if len(self.calls) < self.max_calls:
            self.calls.append(now)
            return True
        return False

# Allow 5 calls per 10 seconds
limiter = RateLimiter(5, 10)
print(limiter.can_make_call())  # True
```

#### Timeout Implementation

```python
def timeout_function(func, timeout_seconds, *args, **kwargs):
    """Execute function with timeout"""
    import signal
    
    def timeout_handler(signum, frame):
        raise TimeoutError("Function timed out")
    
    # Set up timeout
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(int(timeout_seconds))
    
    try:
        result = func(*args, **kwargs)
        signal.alarm(0)  # Cancel timeout
        return result
    except TimeoutError:
        print("Function timed out!")
        return None
```

#### Logging with Timestamps

```python
def log_message(message, level="INFO"):
    """Log message with timestamp"""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
    print(f"[{timestamp}] {level}: {message}")

log_message("Application started")
time.sleep(1)
log_message("Processing data", "DEBUG")
log_message("Error occurred", "ERROR")
```

### Performance Monitoring

#### Execution Time Decorator

```python
import functools

def time_it(func):
    """Decorator to measure function execution time"""
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()
        print(f"{func.__name__} took {end - start:.4f} seconds")
        return result
    return wrapper

@time_it
def slow_function():
    time.sleep(0.5)
    return "Result"

result = slow_function()
```

#### Profiling Code Sections

```python
class Timer:
    def __init__(self):
        self.start_time = None
    
    def start(self):
        self.start_time = time.perf_counter()
    
    def stop(self):
        if self.start_time is None:
            raise ValueError("Timer not started")
        elapsed = time.perf_counter() - self.start_time
        self.start_time = None
        return elapsed
    
    def __enter__(self):
        self.start()
        return self
    
    def __exit__(self, *args):
        elapsed = self.stop()
        print(f"Elapsed time: {elapsed:.4f} seconds")

# Usage as context manager
with Timer():
    time.sleep(1)
    # Code to time
```

### Common Patterns

#### Retry with Backoff

```python
def retry_with_backoff(func, max_retries=3, base_delay=1):
    """Retry function with exponential backoff"""
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            delay = base_delay * (2 ** attempt)
            print(f"Attempt {attempt + 1} failed, retrying in {delay}s")
            time.sleep(delay)
```

#### Periodic Task Execution

```python
def run_periodic_task(task_func, interval_seconds, duration_seconds=None):
    """Run task periodically"""
    start_time = time.time()
    
    while True:
        task_func()
        
        if duration_seconds and time.time() - start_time >= duration_seconds:
            break
        
        time.sleep(interval_seconds)

def heartbeat():
    print(f"Heartbeat at {time.strftime('%H:%M:%S')}")

# Run heartbeat every 5 seconds for 30 seconds
run_periodic_task(heartbeat, 5, 30)
```

### Cross-Platform Considerations

#### Sleep Precision

```python
# Sleep precision varies by platform
def precise_sleep(duration):
    """More precise sleep implementation"""
    start = time.perf_counter()
    while time.perf_counter() - start < duration:
        time.sleep(0.0001)  # Short sleep to avoid busy waiting
```

#### Platform-Specific Functions

```python
# Windows-specific high-resolution timer
try:
    # Windows
    time.clock()  # Deprecated in Python 3.8+
except AttributeError:
    # Use perf_counter instead
    pass

# Cross-platform monotonic time
monotonic_time = time.monotonic()  # Not affected by system clock adjustments
```

### Integration with Other Modules

#### DateTime Integration

```python
import datetime

# Convert between time and datetime
timestamp = time.time()
dt = datetime.datetime.fromtimestamp(timestamp)
back_to_timestamp = dt.timestamp()

# Time zone aware datetime
utc_dt = datetime.datetime.fromtimestamp(timestamp, tz=datetime.timezone.utc)
```

#### Threading with Time

```python
import threading
import time

def worker_with_timeout(work_func, timeout):
    """Run function in thread with timeout"""
    result = [None]
    exception = [None]
    
    def target():
        try:
            result[0] = work_func()
        except Exception as e:
            exception[0] = e
    
    thread = threading.Thread(target=target)
    thread.start()
    thread.join(timeout)
    
    if thread.is_alive():
        # Timeout occurred
        return None, "Timeout"
    
    return result[0], exception[0]
```

### Error Handling

#### Common Time-Related Errors

```python
try:
    # Invalid time string
    time.strptime("invalid", "%Y-%m-%d")
except ValueError as e:
    print(f"Parse error: {e}")

try:
    # Invalid timestamp
    time.localtime(-1)
except (ValueError, OSError) as e:
    print(f"Timestamp error: {e}")

try:
    # Timezone issues
    time.mktime((2025, 13, 32, 25, 61, 61, 0, 0, 0))  # Invalid values
except (ValueError, OverflowError) as e:
    print(f"Invalid time values: {e}")
```

**Key points**: The time module works with floating-point timestamps and struct_time objects, providing both low-level and high-level time operations. Understanding the difference between local time and UTC is crucial for global applications. The module's sleep function is essential for timing control, while formatting functions enable human-readable time representation. For more advanced time zone handling, consider using the datetime module or third-party libraries like pytz.

---

## `json` Module

The JSON (JavaScript Object Notation) module in Python provides functionality for parsing JSON from strings or files and converting Python objects into JSON format. JSON has become the standard for data exchange between web services and applications due to its lightweight, human-readable structure.

### Understanding JSON Structure

JSON supports several data types that map directly to Python equivalents. JSON objects correspond to Python dictionaries, JSON arrays to Python lists, JSON strings to Python strings, JSON numbers to Python integers or floats, JSON booleans to Python True/False, and JSON null to Python None.

### Importing and Basic Usage

```python
import json
```

The json module provides four main functions: `dumps()` for serializing Python objects to JSON strings, `dump()` for writing JSON directly to files, `loads()` for parsing JSON strings into Python objects, and `load()` for reading JSON from files.

### Serialization with dumps() and dump()

The `dumps()` function converts Python objects to JSON strings. It accepts various parameters to control output formatting and behavior.

**Example:**

```python
import json

data = {
    "name": "Alice",
    "age": 30,
    "city": "New York",
    "hobbies": ["reading", "swimming", "coding"]
}

json_string = json.dumps(data)
print(json_string)
```

**Output:**

```json
{"name": "Alice", "age": 30, "city": "New York", "hobbies": ["reading", "swimming", "coding"]}
```

### Pretty Printing JSON

For better readability, use the `indent` parameter to format JSON with proper indentation:

```python
pretty_json = json.dumps(data, indent=4)
print(pretty_json)
```

**Output:**

```json
{
    "name": "Alice",
    "age": 30,
    "city": "New York",
    "hobbies": [
        "reading",
        "swimming",
        "coding"
    ]
}
```

### Writing JSON to Files

The `dump()` function writes JSON directly to file objects:

```python
with open('data.json', 'w') as file:
    json.dump(data, file, indent=4)
```

### Deserialization with loads() and load()

The `loads()` function parses JSON strings into Python objects:

```python
json_string = '{"name": "Bob", "age": 25, "married": true}'
parsed_data = json.loads(json_string)
print(parsed_data)
print(type(parsed_data))
```

**Output:**

```python
{'name': 'Bob', 'age': 25, 'married': True}
<class 'dict'>
```

### Reading JSON from Files

The `load()` function reads JSON from file objects:

```python
with open('data.json', 'r') as file:
    loaded_data = json.load(file)
    print(loaded_data)
```

### Data Type Mapping

Understanding how Python types convert to JSON is crucial for proper serialization:

- Python `dict` → JSON object
- Python `list`, `tuple` → JSON array
- Python `str` → JSON string
- Python `int`, `float` → JSON number
- Python `True` → JSON true
- Python `False` → JSON false
- Python `None` → JSON null

### Common Parameters and Options

#### ensure_ascii Parameter

By default, `dumps()` escapes non-ASCII characters. Set `ensure_ascii=False` to preserve Unicode characters:

```python
data = {"message": "Hello, 世界"}
json_with_unicode = json.dumps(data, ensure_ascii=False)
print(json_with_unicode)
```

#### sort_keys Parameter

Sort dictionary keys in the output for consistent formatting:

```python
json_sorted = json.dumps(data, sort_keys=True, indent=2)
```

#### separators Parameter

Customize the separators used in JSON output:

```python
compact_json = json.dumps(data, separators=(',', ':'))
```

### Error Handling

JSON operations can raise several exceptions that should be handled appropriately:

#### JSONDecodeError

Occurs when parsing invalid JSON:

```python
try:
    invalid_json = '{"name": "Alice", "age":}'
    json.loads(invalid_json)
except json.JSONDecodeError as e:
    print(f"JSON decode error: {e}")
```

#### TypeError

Occurs when trying to serialize non-serializable objects:

```python
import datetime

try:
    data = {"timestamp": datetime.datetime.now()}
    json.dumps(data)
except TypeError as e:
    print(f"Serialization error: {e}")
```

### Custom JSON Encoders

For serializing custom objects, create a custom encoder by subclassing `JSONEncoder`:

```python
class DateTimeEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            return obj.isoformat()
        return super().default(obj)

data = {"timestamp": datetime.datetime.now()}
json_string = json.dumps(data, cls=DateTimeEncoder)
```

### Custom JSON Decoders

Create custom decoders for parsing JSON with specific transformations:

```python
def datetime_decoder(dct):
    for key, value in dct.items():
        if key == 'timestamp':
            try:
                dct[key] = datetime.datetime.fromisoformat(value)
            except ValueError:
                pass
    return dct

json_string = '{"timestamp": "2024-01-15T10:30:00"}'
parsed = json.loads(json_string, object_hook=datetime_decoder)
```

### Working with Complex Data Structures

JSON can handle nested structures effectively:

```python
complex_data = {
    "users": [
        {
            "id": 1,
            "profile": {
                "name": "Alice",
                "preferences": {
                    "theme": "dark",
                    "notifications": True
                }
            },
            "posts": [
                {"title": "First Post", "likes": 10},
                {"title": "Second Post", "likes": 25}
            ]
        }
    ]
}

json_output = json.dumps(complex_data, indent=2)
```

### Performance Considerations

#### Memory Usage

For large datasets, consider using `json.dump()` to write directly to files rather than creating large strings in memory with `json.dumps()`.

#### Speed Optimization

When working with large amounts of data, the `ujson` library (third-party) offers faster JSON processing:

```python
# Alternative: pip install ujson
# import ujson as json
```

### Streaming JSON Processing

For extremely large JSON files, consider using streaming parsers like `ijson` (third-party) that process JSON incrementally:

```python
# For very large files
# import ijson
# for item in ijson.items(file, 'item'):
#     process(item)
```

### Validation and Schema Checking

While the json module doesn't include schema validation, you can implement basic validation:

```python
def validate_user_data(data):
    required_fields = ['name', 'age', 'email']
    if not all(field in data for field in required_fields):
        raise ValueError("Missing required fields")
    
    if not isinstance(data['age'], int) or data['age'] < 0:
        raise ValueError("Invalid age")
    
    return True
```

### Best Practices

Always use context managers when working with files to ensure proper resource cleanup. Handle exceptions appropriately, especially `JSONDecodeError` when parsing external JSON data. Use `indent` parameter for human-readable output during development. Set `ensure_ascii=False` when working with international characters. Consider using `sort_keys=True` for consistent output in testing scenarios.

**Key points:**

- JSON module provides four main functions: dumps(), dump(), loads(), load()
- Always handle JSONDecodeError when parsing untrusted JSON data
- Use custom encoders/decoders for complex object serialization
- Consider memory usage with large datasets
- Validate JSON data structure when accepting external input

### Common Use Cases

#### API Response Processing

```python
import requests
import json

response = requests.get('https://api.example.com/data')
data = response.json()  # Equivalent to json.loads(response.text)
```

#### Configuration Files

```python
# Reading configuration
with open('config.json', 'r') as f:
    config = json.load(f)

# Writing configuration
config['new_setting'] = 'value'
with open('config.json', 'w') as f:
    json.dump(config, f, indent=4)
```

#### Data Persistence

```python
# Save application state
app_state = {
    'user_preferences': {...},
    'session_data': {...}
}

with open('app_state.json', 'w') as f:
    json.dump(app_state, f)
```

**Next steps:** Consider exploring third-party libraries like `jsonschema` for validation, `ujson` for performance, and `ijson` for streaming large datasets. Understanding these extensions will enhance your JSON processing capabilities for production applications.


---

## `re` Module

The re module is Python's built-in regular expression library that provides powerful pattern matching and text manipulation capabilities. It implements Perl-style regular expressions with additional Python-specific features.

### Module Import and Basic Usage

```python
import re

# Basic pattern matching
pattern = r'\d+'
text = "I have 42 apples and 13 oranges"
match = re.search(pattern, text)
```

### Core Functions

### search()

Searches for the first occurrence of a pattern in a string.

```python
import re

text = "The quick brown fox jumps over the lazy dog"
result = re.search(r'brown', text)
if result:
    print(f"Found: {result.group()}")
    print(f"Position: {result.start()}-{result.end()}")
```

### match()

Matches a pattern only at the beginning of a string.

```python
text = "Hello World"
result = re.match(r'Hello', text)  # Matches
result = re.match(r'World', text)  # None - doesn't match at start
```

### findall()

Returns all non-overlapping matches as a list.

```python
text = "Contact: john@email.com or jane@company.org"
emails = re.findall(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', text)
# Returns: ['john@email.com', 'jane@company.org']
```

### finditer()

Returns an iterator of match objects for all matches.

```python
text = "The temperatures are 25°C, 30°C, and 18°C"
for match in re.finditer(r'(\d+)°C', text):
    print(f"Temperature: {match.group(1)}°C at position {match.start()}")
```

### sub()

Replaces occurrences of a pattern with a replacement string.

```python
text = "The year is 2023"
result = re.sub(r'\d{4}', '2024', text)
# Returns: "The year is 2024"

# With function replacement
def increment_year(match):
    return str(int(match.group()) + 1)

result = re.sub(r'\d{4}', increment_year, text)
```

### subn()

Like sub() but returns a tuple with the new string and the number of substitutions.

```python
text = "apple apple banana apple"
result, count = re.subn(r'apple', 'orange', text)
# Returns: ('orange orange banana orange', 3)
```

### split()

Splits a string by occurrences of a pattern.

```python
text = "apple,banana;orange:grape"
fruits = re.split(r'[,;:]', text)
# Returns: ['apple', 'banana', 'orange', 'grape']
```

### Pattern Compilation

### compile()

Compiles a regular expression pattern into a Pattern object for reuse.

```python
pattern = re.compile(r'\b\w+@\w+\.\w+\b')
text1 = "Contact john@email.com"
text2 = "Or reach jane@company.org"

match1 = pattern.search(text1)
match2 = pattern.search(text2)
```

**Key points**: Compilation improves performance when using the same pattern multiple times.

### Regular Expression Syntax

### Character Classes

- `.` - Any character except newline
- `\d` - Any digit (0-9)
- `\D` - Any non-digit
- `\w` - Any word character (letters, digits, underscore)
- `\W` - Any non-word character
- `\s` - Any whitespace character
- `\S` - Any non-whitespace character

### Quantifiers

- `*` - Zero or more occurrences
- `+` - One or more occurrences
- `?` - Zero or one occurrence
- `{n}` - Exactly n occurrences
- `{n,}` - n or more occurrences
- `{n,m}` - Between n and m occurrences

### Anchors

- `^` - Start of string
- `$` - End of string
- `\b` - Word boundary
- `\B` - Non-word boundary

### Groups and Capturing

### Basic Groups

```python
text = "John Doe, age 30"
match = re.search(r'(\w+) (\w+), age (\d+)', text)
if match:
    first_name = match.group(1)
    last_name = match.group(2)
    age = match.group(3)
    full_match = match.group(0)  # or match.group()
```

### Named Groups

```python
pattern = r'(?P<first>\w+) (?P<last>\w+), age (?P<age>\d+)'
match = re.search(pattern, text)
if match:
    print(match.group('first'))
    print(match.groupdict())  # Returns dict of all named groups
```

### Non-capturing Groups

```python
# (?:...) creates a non-capturing group
text = "http://example.com and https://test.org"
urls = re.findall(r'https?://(?:\w+\.)+\w+', text)
```

### Flags and Modifiers

### Common Flags

```python
# Case insensitive
re.search(r'hello', 'HELLO WORLD', re.IGNORECASE)

# Multiline mode
re.search(r'^World', 'Hello\nWorld', re.MULTILINE)

# Dot matches newline
re.search(r'Hello.World', 'Hello\nWorld', re.DOTALL)

# Verbose mode for readable patterns
pattern = re.compile(r'''
    \b                # Word boundary
    \w+               # One or more word characters
    @                 # Literal @ symbol
    \w+               # One or more word characters
    \.                # Literal dot
    \w+               # One or more word characters
    \b                # Word boundary
''', re.VERBOSE)
```

### Combining Flags

```python
flags = re.IGNORECASE | re.MULTILINE
result = re.search(r'^hello', text, flags)
```

### Advanced Features

### Lookahead and Lookbehind

```python
# Positive lookahead (?=...)
text = "password123"
# Match word characters followed by digits
match = re.search(r'\w+(?=\d+)', text)  # Matches "password"

# Negative lookahead (?!...)
text = "test123 test456 testword"
# Match "test" not followed by "word"
matches = re.findall(r'test(?!word)', text)  # ['test', 'test']

# Positive lookbehind (?<=...)
text = "USD100 EUR200 GBP300"
# Match numbers preceded by "USD"
match = re.search(r'(?<=USD)\d+', text)  # Matches "100"

# Negative lookbehind (?<!...)
text = "pre-test post-test notest"
# Match "test" not preceded by "no"
matches = re.findall(r'(?<!no)test', text)  # ['test', 'test']
```

### Backreferences

```python
# Match repeated words
text = "This is is a test test"
duplicates = re.findall(r'\b(\w+)\s+\1\b', text)
# Returns: ['is', 'test']

# Replace repeated words
cleaned = re.sub(r'\b(\w+)\s+\1\b', r'\1', text)
# Returns: "This is a test"
```

### Conditional Patterns

```python
# Match different patterns based on a condition
text = "Mr. Smith or Ms. Johnson"
# Match title and name, handling different titles
pattern = r'(Mr\.|Ms\.)\s+(\w+)'
matches = re.findall(pattern, text)
```

### Match Objects

### Match Object Methods

```python
text = "The price is $25.99"
match = re.search(r'\$(\d+)\.(\d+)', text)

if match:
    print(match.group())      # Full match: "$25.99"
    print(match.group(1))     # First group: "25"
    print(match.group(2))     # Second group: "99"
    print(match.groups())     # All groups: ("25", "99")
    print(match.start())      # Start position
    print(match.end())        # End position
    print(match.span())       # (start, end) tuple
```

### Common Patterns

### Email Validation

```python
email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
text = "Contact us at support@company.com"
email = re.search(email_pattern, text)
```

### Phone Number Extraction

```python
phone_pattern = r'\b(?:\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})\b'
text = "Call me at (555) 123-4567 or +1-555-987-6543"
phones = re.findall(phone_pattern, text)
```

### URL Matching

```python
url_pattern = r'https?://(?:[-\w.])+(?:\:[0-9]+)?(?:/(?:[\w/_.])*(?:\?(?:[\w&=%.])*)?(?:\#(?:[\w.])*)?)?'
text = "Visit https://example.com/page?id=123#section"
urls = re.findall(url_pattern, text)
```

### Date Extraction

```python
date_pattern = r'\b(\d{1,2})/(\d{1,2})/(\d{4})\b'
text = "The event is on 12/25/2023"
dates = re.findall(date_pattern, text)
```

### Performance Considerations

### Compilation Benefits

```python
# Inefficient - compiles pattern each time
for text in large_text_list:
    re.search(r'pattern', text)

# Efficient - compile once, use many times
pattern = re.compile(r'pattern')
for text in large_text_list:
    pattern.search(text)
```

### Non-greedy Matching

```python
html = "<div>Content</div><div>More content</div>"
# Greedy (default)
greedy = re.findall(r'<div>.*</div>', html)  # Matches entire string
# Non-greedy
non_greedy = re.findall(r'<div>.*?</div>', html)  # Matches each div separately
```

### Error Handling

### Pattern Compilation Errors

```python
try:
    pattern = re.compile(r'[invalid pattern')
except re.error as e:
    print(f"Invalid regex pattern: {e}")
```

### Practical Examples

### Log File Processing

```python
log_pattern = re.compile(r'(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2})\s+(\w+)\s+(.+)')
log_line = "2023-12-01 10:30:45 ERROR Database connection failed"
match = log_pattern.search(log_line)
if match:
    date, time, level, message = match.groups()
```

### Text Cleaning

```python
def clean_text(text):
    # Remove extra whitespace
    text = re.sub(r'\s+', ' ', text)
    # Remove special characters except basic punctuation
    text = re.sub(r'[^\w\s.,!?-]', '', text)
    # Remove multiple punctuation
    text = re.sub(r'[.,!?]{2,}', '.', text)
    return text.strip()
```

### Data Validation

```python
def validate_credit_card(card_number):
    # Remove spaces and dashes
    card_number = re.sub(r'[-\s]', '', card_number)
    # Check if it's 13-19 digits
    if re.match(r'^\d{13,19}$', card_number):
        return True
    return False
```

**Key points**: The re module provides comprehensive pattern matching capabilities with functions for searching, matching, replacing, and splitting text. Compilation improves performance for repeated use, and various flags modify pattern behavior. Advanced features include lookahead/lookbehind assertions, backreferences, and named groups.

**Conclusion**: The re module is essential for text processing tasks in Python, offering powerful pattern matching through regular expressions. Understanding its functions, syntax, and performance considerations enables efficient text manipulation and data extraction from complex strings.

---

## `csv` Module

The csv module provides functionality for reading and writing CSV (Comma-Separated Values) files, handling various CSV dialects and formats. It offers both high-level reader/writer interfaces and low-level control over CSV parsing and generation.

### Module Import and Basic Usage

```python
import csv

# Basic reading
with open('data.csv', 'r') as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)
```

### Reading CSV Files

### csv.reader()

Creates a reader object that iterates over rows in a CSV file.

```python
import csv

with open('employees.csv', 'r') as file:
    csv_reader = csv.reader(file)
    
    # Read header
    header = next(csv_reader)
    print(f"Headers: {header}")
    
    # Read data rows
    for row in csv_reader:
        print(f"Row: {row}")
        # Access individual fields
        name = row[0]
        age = row[1]
        department = row[2]
```

### csv.DictReader()

Creates a reader object that maps CSV rows to dictionaries using the first row as field names.

```python
with open('employees.csv', 'r') as file:
    dict_reader = csv.DictReader(file)
    
    # Access field names
    print(f"Field names: {dict_reader.fieldnames}")
    
    # Iterate through rows as dictionaries
    for row in dict_reader:
        print(f"Name: {row['name']}, Age: {row['age']}, Department: {row['department']}")
```

### Custom Field Names with DictReader

```python
with open('data.csv', 'r') as file:
    dict_reader = csv.DictReader(file, fieldnames=['col1', 'col2', 'col3'])
    for row in dict_reader:
        print(row['col1'])
```

### Writing CSV Files

### csv.writer()

Creates a writer object for writing CSV data to a file.

```python
import csv

data = [
    ['Name', 'Age', 'Department'],
    ['John Doe', 30, 'Engineering'],
    ['Jane Smith', 25, 'Marketing'],
    ['Bob Johnson', 35, 'Sales']
]

with open('output.csv', 'w', newline='') as file:
    csv_writer = csv.writer(file)
    
    # Write single row
    csv_writer.writerow(['Name', 'Age', 'Department'])
    
    # Write multiple rows
    csv_writer.writerows([
        ['John Doe', 30, 'Engineering'],
        ['Jane Smith', 25, 'Marketing']
    ])
```

### csv.DictWriter()

Creates a writer object that writes dictionaries to CSV format.

```python
employees = [
    {'name': 'John Doe', 'age': 30, 'department': 'Engineering'},
    {'name': 'Jane Smith', 'age': 25, 'department': 'Marketing'},
    {'name': 'Bob Johnson', 'age': 35, 'department': 'Sales'}
]

with open('employees_output.csv', 'w', newline='') as file:
    fieldnames = ['name', 'age', 'department']
    dict_writer = csv.DictWriter(file, fieldnames=fieldnames)
    
    # Write header
    dict_writer.writeheader()
    
    # Write single row
    dict_writer.writerow({'name': 'Alice Brown', 'age': 28, 'department': 'HR'})
    
    # Write multiple rows
    dict_writer.writerows(employees)
```

### CSV Dialects and Formatting

### Built-in Dialects

```python
# List available dialects
print(csv.list_dialects())  # ['excel', 'excel-tab', 'unix']

# Use specific dialect
with open('data.csv', 'r') as file:
    reader = csv.reader(file, dialect='excel')
    for row in reader:
        print(row)
```

### Custom Dialect Definition

```python
# Register custom dialect
csv.register_dialect('custom', 
                     delimiter='|',
                     quotechar='"',
                     quoting=csv.QUOTE_MINIMAL,
                     lineterminator='\n')

# Use custom dialect
with open('pipe_delimited.csv', 'w', newline='') as file:
    writer = csv.writer(file, dialect='custom')
    writer.writerow(['Name', 'Age', 'City'])
    writer.writerow(['John Doe', 30, 'New York'])
```

### Manual Parameter Setting

```python
with open('data.csv', 'r') as file:
    reader = csv.reader(file, 
                       delimiter=';',
                       quotechar='"',
                       skipinitialspace=True)
    for row in reader:
        print(row)
```

### Reader and Writer Parameters

### Common Parameters

```python
# delimiter: character used to separate fields
reader = csv.reader(file, delimiter=',')

# quotechar: character used to quote fields
reader = csv.reader(file, quotechar='"')

# quoting: controls when quotes are used
reader = csv.reader(file, quoting=csv.QUOTE_MINIMAL)

# skipinitialspace: ignore whitespace after delimiter
reader = csv.reader(file, skipinitialspace=True)

# lineterminator: string used to terminate lines
writer = csv.writer(file, lineterminator='\n')
```

### Quoting Options

```python
# QUOTE_MINIMAL: Quote only when necessary
csv.QUOTE_MINIMAL

# QUOTE_ALL: Quote all fields
csv.QUOTE_ALL

# QUOTE_NONNUMERIC: Quote non-numeric fields
csv.QUOTE_NONNUMERIC

# QUOTE_NONE: Never quote fields
csv.QUOTE_NONE
```

### **Example** of different quoting styles:

```python
data = [['Name', 'Age', 'Comment'],
        ['John', 25, 'Says "Hello"'],
        ['Jane', 30, 'Normal text']]

# QUOTE_MINIMAL
with open('minimal.csv', 'w', newline='') as file:
    writer = csv.writer(file, quoting=csv.QUOTE_MINIMAL)
    writer.writerows(data)

# QUOTE_ALL
with open('all.csv', 'w', newline='') as file:
    writer = csv.writer(file, quoting=csv.QUOTE_ALL)
    writer.writerows(data)
```

### Error Handling and Validation

### Handling Malformed CSV

```python
import csv

def read_csv_safely(filename):
    try:
        with open(filename, 'r') as file:
            reader = csv.reader(file)
            rows = []
            for line_num, row in enumerate(reader, 1):
                try:
                    # Process row
                    rows.append(row)
                except csv.Error as e:
                    print(f"Error on line {line_num}: {e}")
                    continue
            return rows
    except FileNotFoundError:
        print(f"File {filename} not found")
        return []
    except PermissionError:
        print(f"Permission denied to read {filename}")
        return []
```

### Field Validation

```python
def validate_csv_row(row, expected_fields):
    if len(row) != expected_fields:
        raise ValueError(f"Expected {expected_fields} fields, got {len(row)}")
    
    # Additional validation
    if not row[0]:  # Name field
        raise ValueError("Name field cannot be empty")
    
    try:
        age = int(row[1])
        if age < 0 or age > 150:
            raise ValueError("Age must be between 0 and 150")
    except ValueError:
        raise ValueError("Age must be a valid integer")
```

### Advanced Usage

### Reading CSV with Different Encodings

```python
import csv

# UTF-8 encoding
with open('utf8_data.csv', 'r', encoding='utf-8') as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)

# Latin-1 encoding
with open('latin1_data.csv', 'r', encoding='latin-1') as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)
```

### Handling Large CSV Files

```python
def process_large_csv(filename, chunk_size=1000):
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        header = next(reader)
        
        chunk = []
        for row in reader:
            chunk.append(row)
            
            if len(chunk) >= chunk_size:
                # Process chunk
                process_chunk(chunk)
                chunk = []
        
        # Process remaining rows
        if chunk:
            process_chunk(chunk)

def process_chunk(chunk):
    # Process the chunk of rows
    for row in chunk:
        # Perform operations on each row
        pass
```

### CSV with Complex Data Types

```python
import csv
import json
from datetime import datetime

def write_complex_csv():
    data = [
        {
            'name': 'John Doe',
            'birth_date': datetime(1990, 5, 15),
            'skills': ['Python', 'Java', 'SQL'],
            'address': {'street': '123 Main St', 'city': 'New York'}
        }
    ]
    
    with open('complex_data.csv', 'w', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=['name', 'birth_date', 'skills', 'address'])
        writer.writeheader()
        
        for record in data:
            # Convert complex types to strings
            record['birth_date'] = record['birth_date'].isoformat()
            record['skills'] = json.dumps(record['skills'])
            record['address'] = json.dumps(record['address'])
            writer.writerow(record)

def read_complex_csv():
    with open('complex_data.csv', 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            # Convert strings back to complex types
            row['birth_date'] = datetime.fromisoformat(row['birth_date'])
            row['skills'] = json.loads(row['skills'])
            row['address'] = json.loads(row['address'])
            print(row)
```

### CSV Data Transformation

### Filtering and Transforming Data

```python
def filter_and_transform_csv(input_file, output_file, min_age=18):
    with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
        reader = csv.DictReader(infile)
        writer = csv.DictWriter(outfile, fieldnames=['name', 'age', 'department', 'status'])
        writer.writeheader()
        
        for row in reader:
            age = int(row['age'])
            if age >= min_age:
                # Transform data
                row['status'] = 'Adult' if age >= 18 else 'Minor'
                writer.writerow(row)
```

### Merging CSV Files

```python
def merge_csv_files(file_list, output_file):
    with open(output_file, 'w', newline='') as outfile:
        writer = None
        
        for filename in file_list:
            with open(filename, 'r') as infile:
                reader = csv.DictReader(infile)
                
                if writer is None:
                    # Initialize writer with fieldnames from first file
                    writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
                    writer.writeheader()
                
                for row in reader:
                    writer.writerow(row)
```

### CSV Statistics and Analysis

### Basic Statistics

```python
def csv_statistics(filename):
    with open(filename, 'r') as file:
        reader = csv.DictReader(file)
        
        ages = []
        departments = {}
        
        for row in reader:
            age = int(row['age'])
            ages.append(age)
            
            dept = row['department']
            departments[dept] = departments.get(dept, 0) + 1
        
        # Calculate statistics
        avg_age = sum(ages) / len(ages)
        min_age = min(ages)
        max_age = max(ages)
        
        print(f"Average age: {avg_age:.2f}")
        print(f"Age range: {min_age} - {max_age}")
        print(f"Department distribution: {departments}")
```

### Data Aggregation

```python
def aggregate_csv_data(filename):
    from collections import defaultdict
    
    department_data = defaultdict(lambda: {'count': 0, 'total_age': 0})
    
    with open(filename, 'r') as file:
        reader = csv.DictReader(file)
        
        for row in reader:
            dept = row['department']
            age = int(row['age'])
            
            department_data[dept]['count'] += 1
            department_data[dept]['total_age'] += age
    
    # Calculate averages
    for dept, data in department_data.items():
        avg_age = data['total_age'] / data['count']
        print(f"{dept}: {data['count']} employees, avg age: {avg_age:.2f}")
```

### Working with Different CSV Formats

### Tab-Separated Values

```python
# Reading TSV files
with open('data.tsv', 'r') as file:
    reader = csv.reader(file, delimiter='\t')
    for row in reader:
        print(row)

# Writing TSV files
with open('output.tsv', 'w', newline='') as file:
    writer = csv.writer(file, delimiter='\t')
    writer.writerow(['Name', 'Age', 'Department'])
    writer.writerow(['John Doe', 30, 'Engineering'])
```

### Semicolon-Separated Values

```python
# Common in European CSV files
with open('european.csv', 'r') as file:
    reader = csv.reader(file, delimiter=';')
    for row in reader:
        print(row)
```

### CSV with Different Line Endings

```python
# Handle different line endings
with open('data.csv', 'r', newline='') as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)
```

### Performance Optimization

### Memory-Efficient Processing

```python
def process_csv_memory_efficient(filename):
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        header = next(reader)
        
        # Process one row at a time
        for row in reader:
            # Process row immediately without storing
            process_row(row)
            # Row is garbage collected after processing

def process_row(row):
    # Perform operations on the row
    pass
```

### Bulk Operations

```python
def bulk_write_csv(filename, data_generator):
    with open(filename, 'w', newline='') as file:
        writer = csv.writer(file)
        
        # Write header
        writer.writerow(['Name', 'Age', 'Department'])
        
        # Write data in batches
        batch = []
        batch_size = 1000
        
        for record in data_generator:
            batch.append(record)
            
            if len(batch) >= batch_size:
                writer.writerows(batch)
                batch = []
        
        # Write remaining records
        if batch:
            writer.writerows(batch)
```

### Common Patterns and Best Practices

### Safe File Operations

```python
def safe_csv_operation(input_file, output_file):
    try:
        with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
            reader = csv.DictReader(infile)
            writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
            writer.writeheader()
            
            for row in reader:
                # Process and write row
                writer.writerow(row)
                
    except FileNotFoundError:
        print(f"Input file {input_file} not found")
    except PermissionError:
        print(f"Permission denied")
    except csv.Error as e:
        print(f"CSV error: {e}")
```

### Data Validation Pipeline

```python
def validate_and_clean_csv(input_file, output_file, error_file):
    with open(input_file, 'r') as infile, \
         open(output_file, 'w', newline='') as outfile, \
         open(error_file, 'w', newline='') as errfile:
        
        reader = csv.DictReader(infile)
        writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
        error_writer = csv.DictWriter(errfile, fieldnames=reader.fieldnames + ['error'])
        
        writer.writeheader()
        error_writer.writeheader()
        
        for row in reader:
            try:
                # Validate row
                validate_row(row)
                # Clean row
                cleaned_row = clean_row(row)
                writer.writerow(cleaned_row)
            except ValueError as e:
                row['error'] = str(e)
                error_writer.writerow(row)

def validate_row(row):
    if not row['name']:
        raise ValueError("Name cannot be empty")
    if not row['age'].isdigit():
        raise ValueError("Age must be numeric")

def clean_row(row):
    # Clean and normalize data
    row['name'] = row['name'].strip().title()
    row['age'] = int(row['age'])
    return row
```

**Key points**: The csv module provides robust CSV handling with reader/writer classes, dialect support, and error handling. DictReader and DictWriter offer dictionary-based access to CSV data, while various parameters control formatting and parsing behavior.

**Conclusion**: The csv module is essential for working with CSV files in Python, offering both simple and advanced features for reading, writing, and processing CSV data. Its flexibility in handling different CSV formats and dialects makes it suitable for various data processing tasks.

---

## `urllib` Module

The urllib module is Python's built-in library for handling URLs and making HTTP requests. It provides a comprehensive set of tools for opening URLs, parsing URLs, handling cookies, authentication, and various web-related tasks without requiring external dependencies.

### Module Structure

The urllib package consists of several submodules, each serving specific purposes. The `urllib.request` module opens URLs and handles HTTP requests. The `urllib.parse` module parses URLs and handles URL encoding/decoding. The `urllib.error` module defines exception classes for urllib operations. The `urllib.robotparser` module parses robots.txt files.

### Basic URL Opening with urllib.request

The simplest way to open a URL is using `urlopen()`:

```python
import urllib.request

response = urllib.request.urlopen('https://httpbin.org/get')
content = response.read()
print(content.decode('utf-8'))
```

### Response Objects

The `urlopen()` function returns a response object with various methods and attributes:

```python
import urllib.request

response = urllib.request.urlopen('https://httpbin.org/get')

# Read response content
content = response.read()

# Get response headers
headers = response.headers
print(f"Content-Type: {headers['Content-Type']}")

# Get status code
status = response.getcode()
print(f"Status: {status}")

# Get URL (useful for redirects)
url = response.geturl()
print(f"Final URL: {url}")
```

### Making Different HTTP Requests

#### GET Requests with Parameters

```python
import urllib.request
import urllib.parse

# Method 1: Build URL with parameters
base_url = 'https://httpbin.org/get'
params = {'key1': 'value1', 'key2': 'value2'}
query_string = urllib.parse.urlencode(params)
full_url = f"{base_url}?{query_string}"

response = urllib.request.urlopen(full_url)
data = response.read().decode('utf-8')
```

#### POST Requests

```python
import urllib.request
import urllib.parse
import json

# Prepare POST data
post_data = {
    'username': 'testuser',
    'password': 'testpass'
}

# Encode data
data = urllib.parse.urlencode(post_data).encode('utf-8')

# Create request
request = urllib.request.Request(
    'https://httpbin.org/post',
    data=data,
    headers={'Content-Type': 'application/x-www-form-urlencoded'}
)

# Send request
response = urllib.request.urlopen(request)
result = response.read().decode('utf-8')
```

#### JSON POST Requests

```python
import urllib.request
import json

# Prepare JSON data
post_data = {
    'name': 'John Doe',
    'email': 'john@example.com'
}

json_data = json.dumps(post_data).encode('utf-8')

# Create request
request = urllib.request.Request(
    'https://httpbin.org/post',
    data=json_data,
    headers={'Content-Type': 'application/json'}
)

response = urllib.request.urlopen(request)
```

### Custom Headers

Adding custom headers to requests:

```python
import urllib.request

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'application/json',
    'Authorization': 'Bearer your-token-here'
}

request = urllib.request.Request(
    'https://api.example.com/data',
    headers=headers
)

response = urllib.request.urlopen(request)
```

### URL Parsing with urllib.parse

The `urllib.parse` module provides powerful URL manipulation capabilities:

#### Parsing URLs

```python
import urllib.parse

url = 'https://example.com:8080/path/to/resource?param1=value1&param2=value2#fragment'

# Parse URL into components
parsed = urllib.parse.urlparse(url)
print(f"Scheme: {parsed.scheme}")
print(f"Hostname: {parsed.hostname}")
print(f"Port: {parsed.port}")
print(f"Path: {parsed.path}")
print(f"Query: {parsed.query}")
print(f"Fragment: {parsed.fragment}")
```

#### Building URLs

```python
import urllib.parse

# Build URL from components
components = urllib.parse.ParseResult(
    scheme='https',
    netloc='api.example.com',
    path='/v1/users',
    params='',
    query='limit=10&offset=0',
    fragment=''
)

url = urllib.parse.urlunparse(components)
print(url)
```

#### URL Encoding and Decoding

```python
import urllib.parse

# URL encoding
text = "Hello World & Special Characters!"
encoded = urllib.parse.quote(text)
print(f"Encoded: {encoded}")

# URL decoding
decoded = urllib.parse.unquote(encoded)
print(f"Decoded: {decoded}")

# Query parameter encoding
params = {'message': 'Hello World!', 'type': 'greeting'}
query_string = urllib.parse.urlencode(params)
print(f"Query string: {query_string}")
```

#### Parsing Query Strings

```python
import urllib.parse

query_string = 'name=John&age=30&city=New%20York'
parsed_params = urllib.parse.parse_qs(query_string)
print(parsed_params)
# Output: {'name': ['John'], 'age': ['30'], 'city': ['New York']}

# For single values, use parse_qs with keep_blank_values
single_values = {k: v[0] for k, v in parsed_params.items()}
print(single_values)
```

### Error Handling

Proper error handling is crucial when working with network requests:

```python
import urllib.request
import urllib.error

try:
    response = urllib.request.urlopen('https://httpbin.org/status/404')
    data = response.read()
except urllib.error.HTTPError as e:
    print(f"HTTP Error: {e.code} - {e.reason}")
    print(f"Response body: {e.read().decode('utf-8')}")
except urllib.error.URLError as e:
    print(f"URL Error: {e.reason}")
except Exception as e:
    print(f"Other error: {e}")
```

### Handling Redirects

```python
import urllib.request
import urllib.error

try:
    response = urllib.request.urlopen('https://httpbin.org/redirect/3')
    print(f"Final URL: {response.geturl()}")
    print(f"Status: {response.getcode()}")
except urllib.error.HTTPError as e:
    print(f"HTTP Error: {e.code}")
```

### Authentication

#### Basic Authentication

```python
import urllib.request
import base64

# Method 1: Using HTTPPasswordMgrWithDefaultRealm
password_mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()
password_mgr.add_password(None, 'https://httpbin.org', 'username', 'password')

handler = urllib.request.HTTPBasicAuthHandler(password_mgr)
opener = urllib.request.build_opener(handler)

response = opener.open('https://httpbin.org/basic-auth/username/password')
data = response.read().decode('utf-8')
```

#### Manual Basic Authentication

```python
import urllib.request
import base64

username = 'testuser'
password = 'testpass'

# Create base64 encoded credentials
credentials = f"{username}:{password}"
encoded_credentials = base64.b64encode(credentials.encode('utf-8')).decode('utf-8')

# Create request with Authorization header
request = urllib.request.Request('https://httpbin.org/basic-auth/testuser/testpass')
request.add_header('Authorization', f'Basic {encoded_credentials}')

response = urllib.request.urlopen(request)
```

### Handling Cookies

```python
import urllib.request
import urllib.parse
import http.cookiejar

# Create cookie jar
cookie_jar = http.cookiejar.CookieJar()

# Create opener with cookie support
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookie_jar))

# Make request (cookies will be automatically stored)
response = opener.open('https://httpbin.org/cookies/set/sessionid/abc123')

# Make another request (cookies will be automatically sent)
response = opener.open('https://httpbin.org/cookies')
data = response.read().decode('utf-8')
print(data)
```

### File Downloads

#### Simple File Download

```python
import urllib.request

url = 'https://httpbin.org/json'
filename = 'downloaded_data.json'

urllib.request.urlretrieve(url, filename)
print(f"File downloaded as {filename}")
```

#### Download with Progress Tracking

```python
import urllib.request
import sys

def download_progress(block_num, block_size, total_size):
    downloaded = block_num * block_size
    if total_size > 0:
        percent = min(downloaded * 100 / total_size, 100)
        sys.stdout.write(f"\rDownload progress: {percent:.1f}%")
        sys.stdout.flush()

url = 'https://httpbin.org/bytes/1000'
filename = 'large_file.bin'

urllib.request.urlretrieve(url, filename, reporthook=download_progress)
print(f"\nDownload complete: {filename}")
```

### Working with Proxies

```python
import urllib.request

# Set up proxy
proxy_handler = urllib.request.ProxyHandler({
    'http': 'http://proxy.example.com:8080',
    'https': 'https://proxy.example.com:8080'
})

opener = urllib.request.build_opener(proxy_handler)

# Use proxy for requests
response = opener.open('https://httpbin.org/ip')
data = response.read().decode('utf-8')
```

### SSL and HTTPS Handling

#### Custom SSL Context

```python
import urllib.request
import ssl

# Create custom SSL context
context = ssl.create_default_context()
context.check_hostname = False
context.verify_mode = ssl.CERT_NONE

# Use custom context
request = urllib.request.Request('https://self-signed.badssl.com/')
response = urllib.request.urlopen(request, context=context)
```

### Advanced Request Customization

#### Custom Opener

```python
import urllib.request

# Create custom opener with multiple handlers
cookie_jar = http.cookiejar.CookieJar()
cookie_processor = urllib.request.HTTPCookieProcessor(cookie_jar)
redirect_handler = urllib.request.HTTPRedirectHandler()

opener = urllib.request.build_opener(
    cookie_processor,
    redirect_handler
)

# Install as global default (optional)
urllib.request.install_opener(opener)

# Use opener
response = opener.open('https://httpbin.org/cookies')
```

### Timeouts and Connection Control

```python
import urllib.request
import socket

# Set global timeout
socket.setdefaulttimeout(10)

# Or set timeout for specific request
try:
    response = urllib.request.urlopen('https://httpbin.org/delay/5', timeout=3)
except socket.timeout:
    print("Request timed out")
```

### Working with FTP

```python
import urllib.request

# FTP download
ftp_url = 'ftp://ftp.example.com/path/to/file.txt'
try:
    response = urllib.request.urlopen(ftp_url)
    content = response.read()
    print(content.decode('utf-8'))
except Exception as e:
    print(f"FTP Error: {e}")
```

### Robots.txt Parsing

```python
import urllib.robotparser

# Parse robots.txt
rp = urllib.robotparser.RobotFileParser()
rp.set_url('https://example.com/robots.txt')
rp.read()

# Check if URL is allowed
can_fetch = rp.can_fetch('*', 'https://example.com/some-page')
print(f"Can fetch: {can_fetch}")
```

### Common Patterns and Best Practices

#### Session-like Behavior

```python
import urllib.request
import http.cookiejar

class URLSession:
    def __init__(self):
        self.cookie_jar = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(
            urllib.request.HTTPCookieProcessor(self.cookie_jar)
        )
    
    def get(self, url, headers=None):
        request = urllib.request.Request(url, headers=headers or {})
        return self.opener.open(request)
    
    def post(self, url, data=None, headers=None):
        if isinstance(data, dict):
            data = urllib.parse.urlencode(data).encode('utf-8')
        request = urllib.request.Request(url, data=data, headers=headers or {})
        return self.opener.open(request)

# Usage
session = URLSession()
response = session.get('https://httpbin.org/cookies/set/session/abc123')
response = session.get('https://httpbin.org/cookies')
```

#### Rate Limiting

```python
import urllib.request
import time

class RateLimitedOpener:
    def __init__(self, delay=1):
        self.delay = delay
        self.last_request_time = 0
    
    def open(self, url):
        current_time = time.time()
        time_since_last = current_time - self.last_request_time
        
        if time_since_last < self.delay:
            time.sleep(self.delay - time_since_last)
        
        self.last_request_time = time.time()
        return urllib.request.urlopen(url)

# Usage
opener = RateLimitedOpener(delay=2)  # 2 second delay between requests
response = opener.open('https://httpbin.org/get')
```

### Performance Considerations

For production applications, consider connection pooling and persistent connections. The urllib module creates new connections for each request, which can be inefficient for multiple requests to the same server. Consider using connection pooling libraries or implementing custom connection management for high-performance applications.

### Debugging and Logging

```python
import urllib.request
import http.client

# Enable debug logging
http.client.HTTPConnection.debuglevel = 1

# Make request with debug output
response = urllib.request.urlopen('https://httpbin.org/get')
```

**Key points:**

- urllib is part of Python's standard library, requiring no additional installations
- Always handle urllib.error.HTTPError and urllib.error.URLError exceptions
- Use Request objects for complex requests with custom headers and data
- urllib.parse provides comprehensive URL manipulation capabilities
- Consider using session-like patterns for multiple related requests
- Set appropriate timeouts to prevent hanging requests

**Next steps:** For more advanced HTTP client needs, consider exploring the `requests` library, which provides a more user-friendly API, or `aiohttp` for asynchronous HTTP operations. Understanding urllib provides a solid foundation for all HTTP-related work in Python.

---

## `socket` Module

The socket module provides access to the BSD socket interface, enabling network communication between applications across networks or on the same machine. It supports various socket types and protocols for building networked applications.

### Module Import and Basic Concepts

```python
import socket

# Basic socket creation
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
```

### Socket Families and Types

### Address Families

- `AF_INET` - IPv4 Internet protocols
- `AF_INET6` - IPv6 Internet protocols
- `AF_UNIX` - Unix domain sockets (local communication)
- `AF_BLUETOOTH` - Bluetooth protocols

### Socket Types

- `SOCK_STREAM` - TCP (reliable, connection-oriented)
- `SOCK_DGRAM` - UDP (unreliable, connectionless)
- `SOCK_RAW` - Raw sockets (requires privileges)

### Creating Sockets

### Basic Socket Creation

```python
import socket

# TCP socket (IPv4)
tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# UDP socket (IPv4)
udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# IPv6 TCP socket
ipv6_socket = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)

# Unix domain socket
unix_socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
```

### Socket Options

```python
# Set socket options
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Allow address reuse
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

# Set receive buffer size
sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4096)

# Set send buffer size
sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 4096)

# Get socket options
buffer_size = sock.getsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF)
```

### TCP Server Implementation

### Basic TCP Server

```python
import socket
import threading

def handle_client(client_socket, address):
    try:
        while True:
            # Receive data from client
            data = client_socket.recv(1024)
            if not data:
                break
            
            print(f"Received from {address}: {data.decode()}")
            
            # Echo back to client
            client_socket.send(data)
            
    except Exception as e:
        print(f"Error handling client {address}: {e}")
    finally:
        client_socket.close()

def tcp_server(host='localhost', port=12345):
    # Create socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # Allow address reuse
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        # Bind socket to address
        server_socket.bind((host, port))
        
        # Listen for connections
        server_socket.listen(5)
        print(f"Server listening on {host}:{port}")
        
        while True:
            # Accept client connection
            client_socket, address = server_socket.accept()
            print(f"Connection from {address}")
            
            # Handle client in separate thread
            client_thread = threading.Thread(
                target=handle_client,
                args=(client_socket, address)
            )
            client_thread.start()
            
    except Exception as e:
        print(f"Server error: {e}")
    finally:
        server_socket.close()

# Run server
if __name__ == "__main__":
    tcp_server()
```

### Advanced TCP Server with Context Manager

```python
import socket
import threading
from contextlib import contextmanager

@contextmanager
def tcp_server_socket(host, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        sock.bind((host, port))
        sock.listen(5)
        yield sock
    finally:
        sock.close()

def advanced_tcp_server():
    with tcp_server_socket('localhost', 12345) as server_socket:
        print("Server started on localhost:12345")
        
        while True:
            try:
                client_socket, address = server_socket.accept()
                threading.Thread(
                    target=handle_client,
                    args=(client_socket, address),
                    daemon=True
                ).start()
            except KeyboardInterrupt:
                print("Server shutting down...")
                break
```

### TCP Client Implementation

### Basic TCP Client

```python
import socket

def tcp_client(host='localhost', port=12345):
    # Create socket
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        # Connect to server
        client_socket.connect((host, port))
        print(f"Connected to {host}:{port}")
        
        # Send data
        message = "Hello, Server!"
        client_socket.send(message.encode())
        
        # Receive response
        response = client_socket.recv(1024)
        print(f"Server response: {response.decode()}")
        
    except Exception as e:
        print(f"Client error: {e}")
    finally:
        client_socket.close()

# Run client
tcp_client()
```

### Interactive TCP Client

```python
import socket
import threading

def receive_messages(sock):
    while True:
        try:
            message = sock.recv(1024).decode()
            if not message:
                break
            print(f"Received: {message}")
        except:
            break

def interactive_tcp_client():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        sock.connect(('localhost', 12345))
        
        # Start receiving thread
        receive_thread = threading.Thread(target=receive_messages, args=(sock,))
        receive_thread.daemon = True
        receive_thread.start()
        
        # Send messages
        while True:
            message = input()
            if message.lower() == 'quit':
                break
            sock.send(message.encode())
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        sock.close()
```

### UDP Socket Implementation

### UDP Server

```python
import socket

def udp_server(host='localhost', port=12345):
    # Create UDP socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    try:
        # Bind to address
        server_socket.bind((host, port))
        print(f"UDP Server listening on {host}:{port}")
        
        while True:
            # Receive data and client address
            data, client_address = server_socket.recvfrom(1024)
            print(f"Received from {client_address}: {data.decode()}")
            
            # Send response back to client
            response = f"Echo: {data.decode()}"
            server_socket.sendto(response.encode(), client_address)
            
    except Exception as e:
        print(f"UDP Server error: {e}")
    finally:
        server_socket.close()

# Run UDP server
udp_server()
```

### UDP Client

```python
import socket

def udp_client(host='localhost', port=12345):
    # Create UDP socket
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    try:
        # Send data to server
        message = "Hello, UDP Server!"
        client_socket.sendto(message.encode(), (host, port))
        
        # Receive response
        response, server_address = client_socket.recvfrom(1024)
        print(f"Server response: {response.decode()}")
        
    except Exception as e:
        print(f"UDP Client error: {e}")
    finally:
        client_socket.close()

# Run UDP client
udp_client()
```

### Socket Configuration and Options

### Timeout Settings

```python
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Set timeout for blocking operations
sock.settimeout(10.0)  # 10 seconds

# Set non-blocking mode
sock.setblocking(False)

# Get timeout setting
timeout = sock.gettimeout()
print(f"Socket timeout: {timeout}")
```

### Advanced Socket Options

```python
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Keep-alive options
sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)

# TCP-specific options (Linux)
try:
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_KEEPIDLE, 60)
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_KEEPINTVL, 10)
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_KEEPCNT, 6)
except AttributeError:
    # Not available on all platforms
    pass

# Disable Nagle's algorithm
sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
```

### Error Handling and Exceptions

### Common Socket Exceptions

```python
import socket

def robust_socket_operation():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        sock.connect(('localhost', 12345))
        sock.send(b"Hello")
        data = sock.recv(1024)
        
    except socket.error as e:
        print(f"Socket error: {e}")
    except socket.timeout:
        print("Socket operation timed out")
    except socket.gaierror as e:
        print(f"Address resolution error: {e}")
    except ConnectionRefusedError:
        print("Connection refused by remote host")
    except ConnectionResetError:
        print("Connection reset by remote host")
    except BrokenPipeError:
        print("Broken pipe - remote host closed connection")
    finally:
        sock.close()
```

### Graceful Error Handling

```python
import socket
import errno

def handle_socket_errors(sock):
    try:
        data = sock.recv(1024)
        return data
    except socket.error as e:
        if e.errno == errno.EAGAIN or e.errno == errno.EWOULDBLOCK:
            # No data available (non-blocking socket)
            return None
        elif e.errno == errno.ECONNRESET:
            # Connection reset by peer
            print("Connection reset by peer")
            return None
        else:
            # Other socket errors
            print(f"Socket error: {e}")
            raise
```

### Network Address Resolution

### Host and Service Resolution

```python
import socket

# Get host information
def get_host_info(hostname):
    try:
        # Get IP address
        ip_address = socket.gethostbyname(hostname)
        print(f"IP address of {hostname}: {ip_address}")
        
        # Get detailed host information
        host_info = socket.gethostbyaddr(ip_address)
        print(f"Host info: {host_info}")
        
    except socket.gaierror as e:
        print(f"Address resolution failed: {e}")

# Modern address resolution
def resolve_address(hostname, port):
    try:
        # Get address information
        addr_info = socket.getaddrinfo(hostname, port, socket.AF_UNSPEC, socket.SOCK_STREAM)
        
        for family, socktype, proto, canonname, sockaddr in addr_info:
            print(f"Family: {family}, Type: {socktype}, Address: {sockaddr}")
            
    except socket.gaierror as e:
        print(f"Address resolution failed: {e}")

# **Example** usage
get_host_info('google.com')
resolve_address('google.com', 80)
```

### Local Network Information

```python
import socket

# Get local hostname
hostname = socket.gethostname()
print(f"Local hostname: {hostname}")

# Get local IP address
local_ip = socket.gethostbyname(hostname)
print(f"Local IP: {local_ip}")

# Get fully qualified domain name
fqdn = socket.getfqdn()
print(f"FQDN: {fqdn}")
```

### Advanced Socket Programming

### Non-blocking Sockets

```python
import socket
import select

def non_blocking_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('localhost', 12345))
    server_socket.listen(5)
    
    # Set non-blocking
    server_socket.setblocking(False)
    
    sockets = [server_socket]
    
    while True:
        # Use select to check for ready sockets
        ready, _, _ = select.select(sockets, [], [], 1.0)
        
        for sock in ready:
            if sock == server_socket:
                # Accept new connection
                try:
                    client_socket, address = server_socket.accept()
                    client_socket.setblocking(False)
                    sockets.append(client_socket)
                    print(f"New connection from {address}")
                except socket.error:
                    continue
            else:
                # Handle client data
                try:
                    data = sock.recv(1024)
                    if data:
                        sock.send(data)  # Echo back
                    else:
                        # Client disconnected
                        sockets.remove(sock)
                        sock.close()
                except socket.error:
                    sockets.remove(sock)
                    sock.close()
```

### SSL/TLS Sockets

```python
import socket
import ssl

def ssl_client():
    # Create SSL context
    context = ssl.create_default_context()
    
    # Create socket and wrap with SSL
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ssl_sock = context.wrap_socket(sock, server_hostname='httpbin.org')
    
    try:
        ssl_sock.connect(('httpbin.org', 443))
        
        # Send HTTP request
        request = b"GET /get HTTP/1.1\r\nHost: httpbin.org\r\n\r\n"
        ssl_sock.send(request)
        
        # Receive response
        response = ssl_sock.recv(4096)
        print(response.decode())
        
    finally:
        ssl_sock.close()

def ssl_server():
    # Load certificate and key
    context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    context.load_cert_chain(certfile="server.crt", keyfile="server.key")
    
    # Create server socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('localhost', 12345))
    server_socket.listen(5)
    
    # Wrap with SSL
    ssl_server_socket = context.wrap_socket(server_socket, server_side=True)
    
    try:
        while True:
            client_socket, address = ssl_server_socket.accept()
            print(f"SSL connection from {address}")
            
            # Handle SSL client
            data = client_socket.recv(1024)
            client_socket.send(data)
            client_socket.close()
            
    finally:
        ssl_server_socket.close()
```

### Socket Server Classes

### Using socketserver Module

```python
import socketserver

class MyTCPHandler(socketserver.BaseRequestHandler):
    def handle(self):
        # Receive data
        data = self.request.recv(1024).strip()
        print(f"Received from {self.client_address}: {data.decode()}")
        
        # Send response
        self.request.sendall(data.upper())

# Create server
server = socketserver.TCPServer(('localhost', 12345), MyTCPHandler)

# Run server
try:
    server.serve_forever()
except KeyboardInterrupt:
    server.shutdown()
```

### Threaded Socket Server

```python
import socketserver
import threading

class ThreadedTCPHandler(socketserver.BaseRequestHandler):
    def handle(self):
        while True:
            try:
                data = self.request.recv(1024)
                if not data:
                    break
                
                print(f"Thread {threading.current_thread().name}: {data.decode()}")
                self.request.sendall(data.upper())
                
            except Exception as e:
                print(f"Error: {e}")
                break

class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    pass

# Create threaded server
server = ThreadedTCPServer(('localhost', 12345), ThreadedTCPHandler)
server.serve_forever()
```

### File Transfer Implementation

### File Transfer Server

```python
import socket
import os

def file_transfer_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('localhost', 12345))
    server_socket.listen(1)
    
    print("File transfer server listening...")
    
    while True:
        client_socket, address = server_socket.accept()
        print(f"Connection from {address}")
        
        try:
            # Receive filename
            filename = client_socket.recv(1024).decode()
            print(f"Requested file: {filename}")
            
            if os.path.exists(filename):
                # Send file size
                file_size = os.path.getsize(filename)
                client_socket.send(str(file_size).encode())
                
                # Send file content
                with open(filename, 'rb') as file:
                    while True:
                        chunk = file.read(4096)
                        if not chunk:
                            break
                        client_socket.send(chunk)
                
                print(f"File {filename} sent successfully")
            else:
                client_socket.send(b"0")  # File not found
                
        except Exception as e:
            print(f"Error: {e}")
        finally:
            client_socket.close()
```

### File Transfer Client

```python
import socket

def file_transfer_client(filename):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        client_socket.connect(('localhost', 12345))
        
        # Send filename
        client_socket.send(filename.encode())
        
        # Receive file size
        file_size = int(client_socket.recv(1024).decode())
        
        if file_size > 0:
            # Receive file content
            with open(f"received_{filename}", 'wb') as file:
                received = 0
                while received < file_size:
                    chunk = client_socket.recv(min(4096, file_size - received))
                    if not chunk:
                        break
                    file.write(chunk)
                    received += len(chunk)
            
            print(f"File received successfully: received_{filename}")
        else:
            print("File not found on server")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        client_socket.close()

# Transfer file
file_transfer_client("example.txt")
```

### Socket Performance Optimization

### Buffer Management

```python
import socket

def optimized_socket_communication():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # Optimize buffer sizes
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 65536)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 65536)
    
    # Disable Nagle's algorithm for low-latency
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    
    try:
        sock.connect(('localhost', 12345))
        
        # Send large data efficiently
        large_data = b'x' * 1000000  # 1MB of data
        
        # Send in chunks
        bytes_sent = 0
        chunk_size = 8192
        
        while bytes_sent < len(large_data):
            chunk = large_data[bytes_sent:bytes_sent + chunk_size]
            sent = sock.send(chunk)
            bytes_sent += sent
            
    finally:
        sock.close()
```

### Connection Pooling

```python
import socket
import threading
import queue

class ConnectionPool:
    def __init__(self, host, port, max_connections=10):
        self.host = host
        self.port = port
        self.max_connections = max_connections
        self.pool = queue.Queue(maxsize=max_connections)
        self.lock = threading.Lock()
        
        # Initialize connections
        for _ in range(max_connections):
            conn = self._create_connection()
            self.pool.put(conn)
    
    def _create_connection(self):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((self.host, self.port))
        return sock
    
    def get_connection(self):
        try:
            return self.pool.get(block=False)
        except queue.Empty:
            return self._create_connection()
    
    def return_connection(self, conn):
        try:
            self.pool.put(conn, block=False)
        except queue.Full:
            conn.close()
    
    def close_all(self):
        while not self.pool.empty():
            conn = self.pool.get()
            conn.close()
```

**Key points**: The socket module provides comprehensive network programming capabilities including TCP/UDP protocols, address resolution, SSL/TLS support, and various socket options. Proper error handling and resource management are essential for robust network applications.

**Conclusion**: The socket module is fundamental for network programming in Python, enabling the creation of servers, clients, and complex networked applications. Understanding socket types, error handling, and performance optimization is crucial for building efficient and reliable network communication systems.

---

## `http` Module

The http module is Python's built-in package for HTTP-related functionality, providing both client and server capabilities. It consists of several submodules that handle different aspects of HTTP communication, from basic HTTP status codes to full-featured web servers and cookie management.

### Module Structure

The http package contains four main submodules. The `http.client` module provides low-level HTTP client functionality for making HTTP requests. The `http.server` module contains classes for building HTTP servers. The `http.cookies` module handles HTTP cookie parsing and generation. The `http.cookiejar` module provides cookie storage and management for HTTP clients.

### HTTP Status Codes with http.HTTPStatus

The `http.HTTPStatus` enumeration provides a comprehensive collection of HTTP status codes:

```python
from http import HTTPStatus

# Access status codes
print(HTTPStatus.OK)  # 200
print(HTTPStatus.NOT_FOUND)  # 404
print(HTTPStatus.INTERNAL_SERVER_ERROR)  # 500

# Get status code properties
status = HTTPStatus.OK
print(f"Code: {status.value}")
print(f"Phrase: {status.phrase}")
print(f"Description: {status.description}")
```

### HTTP Client with http.client

The `http.client` module provides low-level HTTP client functionality:

#### Basic HTTP Requests

```python
import http.client
import json

# HTTP connection
conn = http.client.HTTPConnection('httpbin.org')

# Make GET request
conn.request('GET', '/get')
response = conn.getresponse()

print(f"Status: {response.status}")
print(f"Reason: {response.reason}")
print(f"Headers: {dict(response.getheaders())}")

data = response.read()
print(f"Response: {data.decode('utf-8')}")

conn.close()
```

#### HTTPS Connections

```python
import http.client
import ssl

# HTTPS connection
conn = http.client.HTTPSConnection('httpbin.org')

# Make GET request
conn.request('GET', '/get')
response = conn.getresponse()

print(f"Status: {response.status}")
data = response.read().decode('utf-8')
print(data)

conn.close()
```

#### POST Requests with Data

```python
import http.client
import json

conn = http.client.HTTPSConnection('httpbin.org')

# Prepare POST data
post_data = {
    'name': 'John Doe',
    'email': 'john@example.com'
}

json_data = json.dumps(post_data)
headers = {'Content-Type': 'application/json'}

# Make POST request
conn.request('POST', '/post', body=json_data, headers=headers)
response = conn.getresponse()

print(f"Status: {response.status}")
result = response.read().decode('utf-8')
print(result)

conn.close()
```

#### Custom Headers and Authentication

```python
import http.client
import base64

conn = http.client.HTTPSConnection('httpbin.org')

# Basic authentication
username = 'testuser'
password = 'testpass'
credentials = base64.b64encode(f"{username}:{password}".encode()).decode()

headers = {
    'Authorization': f'Basic {credentials}',
    'User-Agent': 'Python HTTP Client',
    'Accept': 'application/json'
}

conn.request('GET', '/basic-auth/testuser/testpass', headers=headers)
response = conn.getresponse()

print(f"Status: {response.status}")
data = response.read().decode('utf-8')
print(data)

conn.close()
```

### Connection Context Manager

Using connections as context managers for automatic cleanup:

```python
import http.client

with http.client.HTTPSConnection('httpbin.org') as conn:
    conn.request('GET', '/get')
    response = conn.getresponse()
    data = response.read().decode('utf-8')
    print(data)
```

### HTTP Server with http.server

The `http.server` module provides classes for building HTTP servers:

#### Simple HTTP Server

```python
import http.server
import socketserver

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b'<html><body><h1>Hello, World!</h1></body></html>')

PORT = 8000

with socketserver.TCPServer(("", PORT), MyHandler) as httpd:
    print(f"Server running on port {PORT}")
    httpd.serve_forever()
```

#### Custom HTTP Handler

```python
import http.server
import json
import urllib.parse

class APIHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/status':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            response = {'status': 'ok', 'message': 'Server is running'}
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_POST(self):
        if self.path == '/api/data':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                data = json.loads(post_data.decode('utf-8'))
                
                # Process data
                response = {'received': data, 'processed': True}
                
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(response).encode())
            except json.JSONDecodeError:
                self.send_response(400)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

# Run server
if __name__ == '__main__':
    import socketserver
    PORT = 8000
    
    with socketserver.TCPServer(("", PORT), APIHandler) as httpd:
        print(f"API Server running on port {PORT}")
        httpd.serve_forever()
```

#### File Server

```python
import http.server
import socketserver
import os

class FileHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory='/path/to/files', **kwargs)

PORT = 8000

with socketserver.TCPServer(("", PORT), FileHandler) as httpd:
    print(f"File server running on port {PORT}")
    httpd.serve_forever()
```

### Cookie Management with http.cookies

The `http.cookies` module handles HTTP cookie parsing and creation:

#### Creating Cookies

```python
import http.cookies

# Create cookie
cookie = http.cookies.SimpleCookie()
cookie['session_id'] = 'abc123'
cookie['session_id']['expires'] = 'Wed, 01 Jan 2025 00:00:00 GMT'
cookie['session_id']['path'] = '/'
cookie['session_id']['domain'] = '.example.com'
cookie['session_id']['secure'] = True
cookie['session_id']['httponly'] = True

print(cookie.output())
```

**Output:**

```
Set-Cookie: session_id=abc123; Domain=.example.com; expires=Wed, 01 Jan 2025 00:00:00 GMT; HttpOnly; Path=/; Secure
```

#### Parsing Cookies

```python
import http.cookies

# Parse cookie string
cookie_string = 'session_id=abc123; user_pref=dark_mode; lang=en'
cookie = http.cookies.SimpleCookie()
cookie.load(cookie_string)

for key, morsel in cookie.items():
    print(f"{key}: {morsel.value}")
```

#### Advanced Cookie Handling

```python
import http.cookies
from datetime import datetime, timedelta

cookie = http.cookies.SimpleCookie()

# Set cookie with expiration
cookie['auth_token'] = 'xyz789'
expire_date = datetime.utcnow() + timedelta(hours=24)
cookie['auth_token']['expires'] = expire_date.strftime('%a, %d %b %Y %H:%M:%S GMT')

# Set cookie attributes
cookie['preferences'] = 'theme=dark&lang=en'
cookie['preferences']['max-age'] = 3600  # 1 hour
cookie['preferences']['samesite'] = 'Strict'

print(cookie.output())
```

### Cookie Jar with http.cookiejar

The `http.cookiejar` module provides cookie storage for HTTP clients:

```python
import http.cookiejar
import urllib.request

# Create cookie jar
cookie_jar = http.cookiejar.CookieJar()

# Create opener with cookie support
opener = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(cookie_jar)
)

# Make request (cookies will be stored)
response = opener.open('https://httpbin.org/cookies/set/session/abc123')

# Print stored cookies
for cookie in cookie_jar:
    print(f"Cookie: {cookie.name}={cookie.value}")
    print(f"Domain: {cookie.domain}")
    print(f"Path: {cookie.path}")
```

### Persistent Cookie Storage

```python
import http.cookiejar
import urllib.request

# Create persistent cookie jar
cookie_jar = http.cookiejar.MozillaCookieJar('cookies.txt')

# Try to load existing cookies
try:
    cookie_jar.load()
except FileNotFoundError:
    pass

# Create opener
opener = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(cookie_jar)
)

# Make requests
response = opener.open('https://httpbin.org/cookies/set/persistent/true')

# Save cookies to file
cookie_jar.save()
```

### HTTP Client Error Handling

```python
import http.client
import socket

try:
    conn = http.client.HTTPSConnection('httpbin.org', timeout=5)
    conn.request('GET', '/status/404')
    response = conn.getresponse()
    
    if response.status == 404:
        print("Resource not found")
    elif response.status >= 400:
        print(f"Client error: {response.status}")
    elif response.status >= 500:
        print(f"Server error: {response.status}")
    else:
        print(f"Success: {response.status}")
        
except http.client.HTTPException as e:
    print(f"HTTP error: {e}")
except socket.timeout:
    print("Request timed out")
except socket.error as e:
    print(f"Socket error: {e}")
finally:
    conn.close()
```

### Connection Pooling

```python
import http.client
import threading

class ConnectionPool:
    def __init__(self, host, port=None, max_connections=10):
        self.host = host
        self.port = port
        self.max_connections = max_connections
        self.connections = []
        self.lock = threading.Lock()
    
    def get_connection(self):
        with self.lock:
            if self.connections:
                return self.connections.pop()
            else:
                if self.port:
                    return http.client.HTTPConnection(self.host, self.port)
                else:
                    return http.client.HTTPSConnection(self.host)
    
    def return_connection(self, conn):
        with self.lock:
            if len(self.connections) < self.max_connections:
                self.connections.append(conn)
            else:
                conn.close()
    
    def close_all(self):
        with self.lock:
            for conn in self.connections:
                conn.close()
            self.connections.clear()

# Usage
pool = ConnectionPool('httpbin.org')
conn = pool.get_connection()
conn.request('GET', '/get')
response = conn.getresponse()
data = response.read()
pool.return_connection(conn)
```

### Streaming Responses

```python
import http.client

conn = http.client.HTTPSConnection('httpbin.org')
conn.request('GET', '/stream/20')
response = conn.getresponse()

# Read response in chunks
while True:
    chunk = response.read(1024)
    if not chunk:
        break
    print(f"Received chunk: {len(chunk)} bytes")
    # Process chunk
    print(chunk.decode('utf-8'))

conn.close()
```

### Custom HTTP Methods

```python
import http.client

conn = http.client.HTTPSConnection('httpbin.org')

# Custom HTTP method
conn.request('PATCH', '/patch', body='{"op": "replace", "path": "/name", "value": "new_name"}')
response = conn.getresponse()

print(f"Status: {response.status}")
data = response.read().decode('utf-8')
print(data)

conn.close()
```

### Server-Side Cookie Handling

```python
import http.server
import http.cookies
import json

class CookieHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        # Parse cookies from request
        cookie_header = self.headers.get('Cookie')
        cookies = http.cookies.SimpleCookie()
        
        if cookie_header:
            cookies.load(cookie_header)
        
        if self.path == '/set-cookie':
            # Set a cookie
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            
            # Create new cookie
            new_cookie = http.cookies.SimpleCookie()
            new_cookie['user_id'] = '12345'
            new_cookie['user_id']['max-age'] = 3600
            
            self.send_header('Set-Cookie', new_cookie.output().split(': ')[1])
            self.end_headers()
            
            self.wfile.write(b'<html><body><h1>Cookie Set!</h1></body></html>')
        
        elif self.path == '/show-cookies':
            # Display cookies
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            cookie_dict = {key: morsel.value for key, morsel in cookies.items()}
            response = json.dumps(cookie_dict, indent=2)
            self.wfile.write(response.encode())
        
        else:
            self.send_response(404)
            self.end_headers()

# Run server
if __name__ == '__main__':
    import socketserver
    PORT = 8000
    
    with socketserver.TCPServer(("", PORT), CookieHandler) as httpd:
        print(f"Cookie server running on port {PORT}")
        httpd.serve_forever()
```

### HTTP/2 Support

While `http.client` primarily supports HTTP/1.1, you can check for HTTP/2 support:

```python
import http.client
import ssl

# Create connection with HTTP/2 support
context = ssl.create_default_context()
context.set_alpn_protocols(['h2', 'http/1.1'])

conn = http.client.HTTPSConnection('httpbin.org', context=context)
conn.request('GET', '/get')
response = conn.getresponse()

print(f"Protocol: {getattr(response, 'version', 'Unknown')}")
print(f"Status: {response.status}")

conn.close()
```

### Debugging HTTP Communications

```python
import http.client
import logging

# Enable debug logging
http.client.HTTPConnection.debuglevel = 1

# Set up logging
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

# Make request with debug output
conn = http.client.HTTPSConnection('httpbin.org')
conn.request('GET', '/get')
response = conn.getresponse()
data = response.read()

conn.close()
```

### Performance Considerations

The `http.client` module provides low-level control but requires manual connection management. For production applications, consider implementing connection pooling to reuse connections and reduce overhead. Always close connections properly to avoid resource leaks, and use context managers when possible for automatic cleanup.

### Thread Safety

The `http.client` connections are not thread-safe. When using multiple threads, either create separate connections for each thread or implement proper synchronization:

```python
import http.client
import threading

class ThreadSafeHTTPClient:
    def __init__(self, host):
        self.host = host
        self.local = threading.local()
    
    def get_connection(self):
        if not hasattr(self.local, 'connection'):
            self.local.connection = http.client.HTTPSConnection(self.host)
        return self.local.connection
    
    def request(self, method, url, **kwargs):
        conn = self.get_connection()
        conn.request(method, url, **kwargs)
        return conn.getresponse()

# Usage
client = ThreadSafeHTTPClient('httpbin.org')
response = client.request('GET', '/get')
```

**Key points:**

- http.client provides low-level HTTP client functionality with full control
- http.server enables building custom HTTP servers with minimal code
- http.cookies handles cookie parsing and generation for both clients and servers
- Always properly close connections to prevent resource leaks
- Use context managers for automatic connection cleanup
- Consider connection pooling for production applications with high request volumes

**Next steps:** For more advanced HTTP functionality, explore frameworks like Flask or Django for server-side development, or libraries like `requests` for simpler client-side HTTP operations. Understanding the http module provides the foundation for working with these higher-level tools.

---

## `hashlib` Module

### Overview

The hashlib module provides a common interface to many different secure hash and message digest algorithms. It implements hash algorithms including SHA1, SHA224, SHA256, SHA384, SHA512, MD5, and others through OpenSSL. Hash functions are mathematical algorithms that take input data of arbitrary size and produce a fixed-size string of bytes, typically used for data integrity verification, password storage, and cryptographic applications.

### Core Functionality

The hashlib module serves as Python's primary interface for cryptographic hash functions. It provides both FIPS-approved algorithms and additional algorithms available through OpenSSL. The module offers two main approaches: constructor functions for specific algorithms and a generic constructor that accepts algorithm names as strings.

### Available Hash Algorithms

#### Guaranteed Algorithms

These algorithms are guaranteed to be available on all platforms:

- **SHA-1** (sha1): 160-bit hash, cryptographically broken but still used for non-security purposes
- **SHA-224** (sha224): 224-bit variant of SHA-2
- **SHA-256** (sha256): 256-bit SHA-2, widely used and recommended
- **SHA-384** (sha384): 384-bit SHA-2
- **SHA-512** (sha512): 512-bit SHA-2
- **MD5** (md5): 128-bit hash, cryptographically broken, avoid for security

#### Additional Algorithms

Platform-dependent algorithms available through OpenSSL include SHA-3 variants, BLAKE2, and others. Use `hashlib.algorithms_available` to see all available algorithms on your system.

### Basic Usage Patterns

#### Direct Constructor Method

```python
import hashlib

# Create hash object
hasher = hashlib.sha256()
hasher.update(b'Hello, World!')
digest = hasher.hexdigest()
```

#### Generic Constructor Method

```python
import hashlib

# Using algorithm name
hasher = hashlib.new('sha256')
hasher.update(b'Hello, World!')
digest = hasher.hexdigest()
```

#### One-line Hashing

```python
import hashlib

# Direct hashing
digest = hashlib.sha256(b'Hello, World!').hexdigest()
```

### Hash Object Methods

#### update(data)

Feeds data to the hash object. Can be called multiple times to hash large amounts of data incrementally.

```python
hasher = hashlib.sha256()
hasher.update(b'First part')
hasher.update(b'Second part')
# Equivalent to hashing b'First partSecond part'
```

#### digest()

Returns the digest as bytes. This is the raw binary hash value.

```python
binary_hash = hasher.digest()
print(len(binary_hash))  # 32 bytes for SHA-256
```

#### hexdigest()

Returns the digest as a hexadecimal string, which is more readable and commonly used.

```python
hex_hash = hasher.hexdigest()
print(len(hex_hash))  # 64 characters for SHA-256
```

#### digest_size

Property that returns the size of the resulting hash in bytes.

```python
print(hashlib.sha256().digest_size)  # 32
print(hashlib.md5().digest_size)     # 16
```

#### block_size

Property that returns the internal block size of the hash algorithm.

```python
print(hashlib.sha256().block_size)  # 64
```

#### name

Property that returns the canonical name of the hash algorithm.

```python
print(hashlib.sha256().name)  # 'sha256'
```

#### copy()

Creates a copy of the hash object, useful for computing multiple hashes with shared prefixes.

```python
base_hasher = hashlib.sha256()
base_hasher.update(b'Common prefix')

hasher1 = base_hasher.copy()
hasher1.update(b'Suffix 1')

hasher2 = base_hasher.copy()
hasher2.update(b'Suffix 2')
```

### Advanced Features

#### Key Derivation Functions

The module provides PBKDF2 (Password-Based Key Derivation Function 2) for secure password hashing:

```python
import hashlib
import os

password = b'my_password'
salt = os.urandom(32)  # Random salt
key = hashlib.pbkdf2_hmac('sha256', password, salt, 100000)
```

#### SHAKE Algorithms

SHAKE128 and SHAKE256 are extendable-output functions that can produce hashes of arbitrary length:

```python
# SHAKE256 producing 32 bytes
shake = hashlib.shake_256()
shake.update(b'Hello, World!')
digest = shake.digest(32)  # Specify desired length
```

#### File Hashing

Efficient hashing of large files by reading in chunks:

```python
def hash_file(filename, algorithm='sha256'):
    hasher = hashlib.new(algorithm)
    with open(filename, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            hasher.update(chunk)
    return hasher.hexdigest()
```

### Security Considerations

#### Algorithm Selection

- **Use SHA-256 or higher** for new applications
- **Avoid MD5 and SHA-1** for cryptographic purposes due to known vulnerabilities
- **Consider SHA-3** for applications requiring resistance to length extension attacks

#### Salt Usage

Always use random salts when hashing passwords or sensitive data to prevent rainbow table attacks:

```python
import os
import hashlib

def hash_password(password):
    salt = os.urandom(32)
    key = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000)
    return salt + key  # Store salt with hash
```

#### Timing Attacks

Use `hmac.compare_digest()` for comparing hash values to prevent timing attacks:

```python
import hmac

def verify_hash(stored_hash, provided_data):
    calculated_hash = hashlib.sha256(provided_data).digest()
    return hmac.compare_digest(stored_hash, calculated_hash)
```

### Practical Applications

#### Data Integrity Verification

```python
def create_checksum(data):
    return hashlib.sha256(data).hexdigest()

def verify_integrity(data, expected_hash):
    return create_checksum(data) == expected_hash
```

#### Digital Signatures and Certificates

Hash functions are fundamental components in digital signature algorithms and certificate validation.

#### Blockchain Technology

Cryptocurrencies and blockchain systems heavily rely on hash functions for proof-of-work, merkle trees, and block linking.

#### Password Storage

```python
import hashlib
import secrets

def store_password(password):
    salt = secrets.token_hex(16)
    hash_obj = hashlib.pbkdf2_hmac('sha256', password.encode(), salt.encode(), 100000)
    return f"{salt}:{hash_obj.hex()}"

def verify_password(password, stored):
    salt, stored_hash = stored.split(':')
    hash_obj = hashlib.pbkdf2_hmac('sha256', password.encode(), salt.encode(), 100000)
    return hash_obj.hex() == stored_hash
```

### Performance Considerations

#### Algorithm Speed Comparison

Different algorithms have varying performance characteristics:

- **MD5**: Fastest but insecure
- **SHA-1**: Fast but deprecated for security
- **SHA-256**: Good balance of security and performance
- **SHA-512**: Slower but more secure
- **SHA-3**: Variable performance, good security properties

#### Memory Usage

Hash functions generally have low memory requirements, but incremental hashing with `update()` is more memory-efficient for large data sets than loading everything into memory at once.

#### Threading and Multiprocessing

Hash objects are not thread-safe. Create separate hash objects for each thread or use appropriate synchronization mechanisms.

### Error Handling

#### Common Exceptions

```python
try:
    hasher = hashlib.new('invalid_algorithm')
except ValueError as e:
    print(f"Algorithm not available: {e}")

try:
    hasher = hashlib.sha256()
    hasher.update("string data")  # Must be bytes
except TypeError as e:
    print(f"Data must be bytes: {e}")
```

#### Algorithm Availability Check

```python
def safe_hash(data, algorithm='sha256'):
    if algorithm not in hashlib.algorithms_available:
        raise ValueError(f"Algorithm {algorithm} not available")
    return hashlib.new(algorithm, data).hexdigest()
```

### Module Constants and Functions

#### algorithms_guaranteed

Set of algorithm names guaranteed to be available on all platforms.

#### algorithms_available

Set of all algorithm names available on the current platform.

#### new(name, [data])

Generic constructor that accepts algorithm name as string.

#### pbkdf2_hmac(hash_name, password, salt, iterations, dklen=None)

PBKDF2 key derivation function implementation.

### Integration with Other Modules

#### HMAC Module

```python
import hmac
import hashlib

# HMAC with SHA-256
mac = hmac.new(b'secret_key', b'message', hashlib.sha256)
print(mac.hexdigest())
```

#### Secrets Module

```python
import secrets
import hashlib

# Secure random salt generation
salt = secrets.token_bytes(32)
hash_value = hashlib.sha256(b'data' + salt).hexdigest()
```

### Best Practices

Use appropriate algorithms for your security requirements, always include salts for password hashing, implement proper error handling for algorithm availability, consider performance implications for large-scale applications, and keep up with current cryptographic recommendations as algorithms may become deprecated over time.

**Key points**: The hashlib module provides secure hash functions essential for data integrity, password storage, and cryptographic applications. Choose SHA-256 or higher for security-critical applications, always use salts with passwords, and be aware of algorithm deprecation over time.

---

## `threading` Module

### Overview

The `threading` module in Python provides a high-level interface for working with threads, allowing concurrent execution of code within a single process. It's built on top of the lower-level `_thread` module and offers object-oriented thread management with synchronization primitives.

### Core Components

#### Thread Class

The `Thread` class is the primary way to create and manage threads. It can be used in two main ways:

- Subclassing `Thread` and overriding the `run()` method
- Passing a callable function to the `Thread` constructor

```python
import threading
import time

# Method 1: Function-based
def worker_function(name):
    for i in range(3):
        print(f"Thread {name}: {i}")
        time.sleep(1)

thread1 = threading.Thread(target=worker_function, args=("Worker-1",))

# Method 2: Class-based
class WorkerThread(threading.Thread):
    def __init__(self, name):
        super().__init__()
        self.name = name
    
    def run(self):
        for i in range(3):
            print(f"Thread {self.name}: {i}")
            time.sleep(1)

thread2 = WorkerThread("Worker-2")
```

#### Thread Methods and Properties

**Key methods:**

- `start()`: Begin thread execution
- `join(timeout=None)`: Wait for thread to complete
- `is_alive()`: Check if thread is currently running
- `getName()` / `setName()`: Get/set thread name
- `ident`: Unique thread identifier (read-only)
- `daemon`: Boolean indicating if thread is a daemon thread

### Synchronization Primitives

#### Lock

The most basic synchronization primitive that ensures only one thread can execute a critical section at a time.

```python
import threading

lock = threading.Lock()
shared_resource = 0

def increment():
    global shared_resource
    for _ in range(100000):
        with lock:  # Context manager automatically acquires and releases
            shared_resource += 1

threads = []
for i in range(5):
    t = threading.Thread(target=increment)
    threads.append(t)
    t.start()

for t in threads:
    t.join()
```

#### RLock (Reentrant Lock)

Allows the same thread to acquire the lock multiple times without deadlocking itself.

```python
rlock = threading.RLock()

def recursive_function(n):
    with rlock:
        if n > 0:
            print(f"Level {n}")
            recursive_function(n - 1)
```

#### Semaphore

Controls access to a resource with a limited number of available slots.

```python
# Allow maximum 3 threads to access resource simultaneously
semaphore = threading.Semaphore(3)

def access_resource(thread_id):
    with semaphore:
        print(f"Thread {thread_id} accessing resource")
        time.sleep(2)
        print(f"Thread {thread_id} releasing resource")
```

#### Event

Provides a simple way for threads to communicate using a boolean flag.

```python
event = threading.Event()

def waiter():
    print("Waiting for event...")
    event.wait()
    print("Event received!")

def setter():
    time.sleep(3)
    print("Setting event")
    event.set()
```

#### Condition

Allows threads to wait for specific conditions and notify other threads when conditions change.

```python
condition = threading.Condition()
items = []

def consumer():
    with condition:
        while len(items) == 0:
            condition.wait()
        item = items.pop(0)
        print(f"Consumed {item}")

def producer():
    with condition:
        item = "data"
        items.append(item)
        print(f"Produced {item}")
        condition.notify()
```

### Thread-Safe Data Structures

#### Queue Module Integration

The `queue` module provides thread-safe FIFO, LIFO, and priority queue implementations that work seamlessly with threading.

```python
import queue
import threading

q = queue.Queue()

def producer():
    for i in range(5):
        q.put(f"item-{i}")
        print(f"Produced item-{i}")

def consumer():
    while True:
        item = q.get()
        if item is None:
            break
        print(f"Consumed {item}")
        q.task_done()
```

### Thread Local Storage

`threading.local()` creates thread-specific data storage where each thread has its own copy of variables.

```python
import threading

thread_local_data = threading.local()

def process_data():
    thread_local_data.value = threading.current_thread().name
    time.sleep(1)
    print(f"Thread {threading.current_thread().name}: {thread_local_data.value}")
```

### Advanced Features

#### Thread Pooling with ThreadPoolExecutor

While not part of the threading module directly, `concurrent.futures.ThreadPoolExecutor` provides efficient thread pool management.

```python
from concurrent.futures import ThreadPoolExecutor
import threading

def worker_task(n):
    return n * n

with ThreadPoolExecutor(max_workers=4) as executor:
    futures = [executor.submit(worker_task, i) for i in range(10)]
    results = [future.result() for future in futures]
```

#### Daemon Threads

Daemon threads automatically terminate when the main program exits, useful for background tasks.

```python
def background_task():
    while True:
        print("Background work...")
        time.sleep(2)

daemon_thread = threading.Thread(target=background_task)
daemon_thread.daemon = True
daemon_thread.start()
```

### Error Handling and Best Practices

#### Exception Handling in Threads

Exceptions in threads don't propagate to the main thread automatically.

```python
import sys
import traceback

def thread_with_exception():
    try:
        # Potentially problematic code
        raise ValueError("Something went wrong")
    except Exception:
        # Log the exception
        traceback.print_exc()
        # Or store it for later retrieval
        return sys.exc_info()

def safe_thread_wrapper(func, *args, **kwargs):
    try:
        return func(*args, **kwargs)
    except Exception as e:
        print(f"Thread exception: {e}")
        traceback.print_exc()
```

#### Resource Cleanup

Always ensure proper cleanup of resources in threaded environments.

```python
import atexit

def cleanup_threads():
    # Cleanup code for threads
    print("Cleaning up threads...")

atexit.register(cleanup_threads)
```

### Common Patterns and Use Cases

#### Producer-Consumer Pattern

```python
import threading
import queue
import time

class ProducerConsumer:
    def __init__(self):
        self.queue = queue.Queue(maxsize=10)
        self.shutdown = threading.Event()
    
    def producer(self, producer_id):
        count = 0
        while not self.shutdown.is_set():
            item = f"item-{producer_id}-{count}"
            self.queue.put(item)
            print(f"Producer {producer_id} produced {item}")
            count += 1
            time.sleep(0.5)
    
    def consumer(self, consumer_id):
        while not self.shutdown.is_set():
            try:
                item = self.queue.get(timeout=1)
                print(f"Consumer {consumer_id} consumed {item}")
                self.queue.task_done()
            except queue.Empty:
                continue
```

#### Worker Pool Pattern

```python
class WorkerPool:
    def __init__(self, num_workers=4):
        self.task_queue = queue.Queue()
        self.workers = []
        self.shutdown = threading.Event()
        
        for i in range(num_workers):
            worker = threading.Thread(target=self._worker, args=(i,))
            worker.start()
            self.workers.append(worker)
    
    def _worker(self, worker_id):
        while not self.shutdown.is_set():
            try:
                task = self.task_queue.get(timeout=1)
                task()
                self.task_queue.task_done()
            except queue.Empty:
                continue
    
    def submit_task(self, task):
        self.task_queue.put(task)
    
    def shutdown_pool(self):
        self.shutdown.set()
        for worker in self.workers:
            worker.join()
```

### Performance Considerations

#### Global Interpreter Lock (GIL)

Python's GIL prevents true parallel execution of Python bytecode, making threading most effective for I/O-bound tasks rather than CPU-bound tasks.

**Key points:**

- Threading is excellent for I/O-bound operations (file operations, network requests, database queries)
- For CPU-bound tasks, consider `multiprocessing` module instead
- C extensions can release the GIL for true parallelism

#### Thread Overhead

Each thread consumes memory (typically 8MB stack space on 64-bit systems) and has creation/context-switching overhead.

### Debugging and Monitoring

#### Thread Identification and Monitoring

```python
import threading

def monitor_threads():
    print(f"Active threads: {threading.active_count()}")
    for thread in threading.enumerate():
        print(f"Thread: {thread.name}, Alive: {thread.is_alive()}")

# Get current thread
current_thread = threading.current_thread()
print(f"Current thread: {current_thread.name}")

# Main thread reference
main_thread = threading.main_thread()
print(f"Main thread: {main_thread.name}")
```

#### Deadlock Detection

[Inference] Common deadlock patterns can be detected through careful code review and testing, though Python doesn't provide built-in deadlock detection.

```python
# Potential deadlock scenario
lock1 = threading.Lock()
lock2 = threading.Lock()

def thread1():
    with lock1:
        time.sleep(0.1)
        with lock2:  # Potential deadlock if thread2 holds lock2
            pass

def thread2():
    with lock2:
        time.sleep(0.1)
        with lock1:  # Potential deadlock if thread1 holds lock1
            pass
```

### Common Pitfalls and Solutions

#### Race Conditions

Occur when multiple threads access shared data without proper synchronization.

**Example of race condition:**

```python
# Problematic code
counter = 0

def increment():
    global counter
    temp = counter
    temp += 1
    counter = temp  # Race condition here
```

**Solution:**

```python
# Fixed with lock
counter = 0
counter_lock = threading.Lock()

def increment():
    global counter
    with counter_lock:
        counter += 1
```

#### Memory Leaks in Long-Running Threads

Ensure proper cleanup and avoid circular references in thread objects.

#### Signal Handling

[Unverified] Signal handling behavior with threads can be complex, as signals are typically delivered to the main thread only.

### Testing Threaded Code

#### Unit Testing Considerations

```python
import unittest
import threading
import time

class ThreadedTest(unittest.TestCase):
    def test_concurrent_access(self):
        results = []
        lock = threading.Lock()
        
        def worker():
            with lock:
                results.append(threading.current_thread().name)
        
        threads = [threading.Thread(target=worker) for _ in range(5)]
        for t in threads:
            t.start()
        for t in threads:
            t.join()
        
        self.assertEqual(len(results), 5)
```

### Integration with Other Modules

#### AsyncIO Integration

[Inference] While threading and asyncio serve different concurrency models, they can be integrated when needed.

```python
import asyncio
import threading

def run_in_thread(coro):
    def thread_target():
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        loop.run_until_complete(coro)
        loop.close()
    
    thread = threading.Thread(target=thread_target)
    thread.start()
    return thread
```

**Key points:**

- Use threading for I/O-bound tasks with blocking operations
- Consider asyncio for I/O-bound tasks that can benefit from async/await syntax
- Multiprocessing for CPU-bound tasks requiring true parallelism
- Thread-safe data structures from queue module for inter-thread communication
- Always use synchronization primitives to protect shared resources
- Be mindful of the GIL's impact on CPU-bound threading performance
- Proper exception handling and resource cleanup are crucial in threaded applications

The threading module provides a robust foundation for concurrent programming in Python, though understanding its limitations and appropriate use cases is essential for effective implementation.

---

## `multiprocessing` Module

### Overview

The multiprocessing module is Python's standard library solution for parallel processing that bypasses the Global Interpreter Lock (GIL) by using separate processes instead of threads. It provides a Process-like interface similar to threading but creates actual system processes, enabling true parallelism for CPU-intensive tasks. The module supports spawning processes, sharing data between processes, and synchronization primitives.

### Core Concepts

#### Process vs Thread Distinction

Unlike threading, multiprocessing creates separate Python interpreter processes, each with its own memory space and GIL. This enables genuine parallel execution of CPU-bound tasks but introduces overhead for process creation and inter-process communication. Each process runs independently and cannot directly access variables from other processes.

#### Memory Model

Processes have separate memory spaces, meaning variables are not shared by default. Data sharing requires explicit mechanisms like shared memory objects, pipes, or queues. This isolation provides safety but requires careful design for data exchange between processes.

#### Process Creation Methods

The module supports three process start methods:

- **spawn**: Creates a fresh Python interpreter (default on Windows/macOS)
- **fork**: Copies the parent process (default on Unix, faster but can cause issues)
- **forkserver**: Uses a server process to create new processes (Unix only, safer than fork)

### Basic Process Creation

#### Process Class

```python
import multiprocessing
import time

def worker_function(name, duration):
    print(f"Worker {name} starting")
    time.sleep(duration)
    print(f"Worker {name} finished")

# Create and start process
process = multiprocessing.Process(target=worker_function, args=('A', 2))
process.start()
process.join()  # Wait for completion
```

#### Process with Return Values

```python
import multiprocessing

def calculate_square(number, result_queue):
    result = number ** 2
    result_queue.put((number, result))

def main():
    queue = multiprocessing.Queue()
    processes = []
    
    for i in range(5):
        p = multiprocessing.Process(target=calculate_square, args=(i, queue))
        processes.append(p)
        p.start()
    
    # Collect results
    results = []
    for _ in range(5):
        results.append(queue.get())
    
    # Wait for all processes
    for p in processes:
        p.join()
    
    print(results)

if __name__ == '__main__':
    main()
```

### Process Pools

#### Pool Class

The Pool class provides a convenient way to parallelize function calls across multiple processes:

```python
import multiprocessing

def square_number(n):
    return n ** 2

def main():
    with multiprocessing.Pool(processes=4) as pool:
        numbers = [1, 2, 3, 4, 5]
        results = pool.map(square_number, numbers)
        print(results)  # [1, 4, 9, 16, 25]

if __name__ == '__main__':
    main()
```

#### Pool Methods

**map()**: Applies function to each element in iterable

```python
results = pool.map(function, iterable)
```

**imap()**: Lazy version of map, returns iterator

```python
for result in pool.imap(function, iterable):
    print(result)
```

**map_async()**: Asynchronous version of map

```python
async_result = pool.map_async(function, iterable)
results = async_result.get(timeout=10)
```

**apply()**: Applies function to single set of arguments

```python
result = pool.apply(function, args=(arg1, arg2))
```

**apply_async()**: Asynchronous version of apply

```python
async_result = pool.apply_async(function, args=(arg1, arg2))
result = async_result.get()
```

**starmap()**: Like map but unpacks arguments

```python
def add_numbers(a, b):
    return a + b

pairs = [(1, 2), (3, 4), (5, 6)]
results = pool.starmap(add_numbers, pairs)
```

### Inter-Process Communication

#### Queue

Thread-safe, process-safe queue for passing data between processes:

```python
import multiprocessing
import time

def producer(queue, items):
    for item in items:
        queue.put(item)
        time.sleep(0.1)
    queue.put(None)  # Sentinel value

def consumer(queue):
    while True:
        item = queue.get()
        if item is None:
            break
        print(f"Consumed: {item}")

def main():
    queue = multiprocessing.Queue()
    items = [1, 2, 3, 4, 5]
    
    p1 = multiprocessing.Process(target=producer, args=(queue, items))
    p2 = multiprocessing.Process(target=consumer, args=(queue,))
    
    p1.start()
    p2.start()
    
    p1.join()
    p2.join()

if __name__ == '__main__':
    main()
```

#### Pipe

Two-way communication channel between processes:

```python
import multiprocessing

def sender(conn):
    conn.send(['hello', 'world'])
    conn.close()

def receiver(conn):
    data = conn.recv()
    print(f"Received: {data}")
    conn.close()

def main():
    parent_conn, child_conn = multiprocessing.Pipe()
    
    p1 = multiprocessing.Process(target=sender, args=(child_conn,))
    p2 = multiprocessing.Process(target=receiver, args=(parent_conn,))
    
    p1.start()
    p2.start()
    
    p1.join()
    p2.join()

if __name__ == '__main__':
    main()
```

### Shared Memory Objects

#### Value and Array

Shared memory objects that can be accessed by multiple processes:

```python
import multiprocessing
import time

def worker(shared_value, shared_array, index):
    # Modify shared value
    with shared_value.get_lock():
        shared_value.value += 1
    
    # Modify shared array
    shared_array[index] = shared_array[index] * 2

def main():
    # Shared integer
    shared_value = multiprocessing.Value('i', 0)  # 'i' for integer
    
    # Shared array of integers
    shared_array = multiprocessing.Array('i', [1, 2, 3, 4, 5])
    
    processes = []
    for i in range(5):
        p = multiprocessing.Process(target=worker, args=(shared_value, shared_array, i))
        processes.append(p)
        p.start()
    
    for p in processes:
        p.join()
    
    print(f"Final shared value: {shared_value.value}")
    print(f"Final shared array: {list(shared_array)}")

if __name__ == '__main__':
    main()
```

#### Manager Objects

More flexible shared objects with higher overhead:

```python
import multiprocessing

def worker(shared_dict, shared_list, name):
    shared_dict[name] = multiprocessing.current_process().pid
    shared_list.append(name)

def main():
    with multiprocessing.Manager() as manager:
        shared_dict = manager.dict()
        shared_list = manager.list()
        
        processes = []
        for i in range(3):
            name = f"Process-{i}"
            p = multiprocessing.Process(target=worker, args=(shared_dict, shared_list, name))
            processes.append(p)
            p.start()
        
        for p in processes:
            p.join()
        
        print(f"Shared dict: {dict(shared_dict)}")
        print(f"Shared list: {list(shared_list)}")

if __name__ == '__main__':
    main()
```

### Synchronization Primitives

#### Lock

Prevents multiple processes from accessing shared resources simultaneously:

```python
import multiprocessing
import time

def worker_with_lock(lock, shared_resource, worker_id):
    for i in range(3):
        with lock:
            print(f"Worker {worker_id}: Accessing shared resource")
            shared_resource.value += 1
            time.sleep(0.1)
            print(f"Worker {worker_id}: Resource value is {shared_resource.value}")

def main():
    lock = multiprocessing.Lock()
    shared_resource = multiprocessing.Value('i', 0)
    
    processes = []
    for i in range(3):
        p = multiprocessing.Process(target=worker_with_lock, args=(lock, shared_resource, i))
        processes.append(p)
        p.start()
    
    for p in processes:
        p.join()

if __name__ == '__main__':
    main()
```

#### Semaphore

Controls access to a resource with limited capacity:

```python
import multiprocessing
import time

def worker(semaphore, worker_id):
    with semaphore:
        print(f"Worker {worker_id}: Acquired semaphore")
        time.sleep(2)
        print(f"Worker {worker_id}: Releasing semaphore")

def main():
    # Allow only 2 processes to access resource simultaneously
    semaphore = multiprocessing.Semaphore(2)
    
    processes = []
    for i in range(5):
        p = multiprocessing.Process(target=worker, args=(semaphore, i))
        processes.append(p)
        p.start()
    
    for p in processes:
        p.join()

if __name__ == '__main__':
    main()
```

#### Event

Simple signaling mechanism between processes:

```python
import multiprocessing
import time

def waiter(event, name):
    print(f"{name}: Waiting for event")
    event.wait()
    print(f"{name}: Event received!")

def setter(event):
    time.sleep(3)
    print("Setting event")
    event.set()

def main():
    event = multiprocessing.Event()
    
    processes = []
    for i in range(3):
        p = multiprocessing.Process(target=waiter, args=(event, f"Waiter-{i}"))
        processes.append(p)
        p.start()
    
    setter_process = multiprocessing.Process(target=setter, args=(event,))
    setter_process.start()
    
    for p in processes:
        p.join()
    setter_process.join()

if __name__ == '__main__':
    main()
```

#### Condition

More complex synchronization primitive combining lock and event functionality:

```python
import multiprocessing
import time
import random

def consumer(condition, items):
    with condition:
        condition.wait_for(lambda: len(items) > 0)
        item = items.pop(0)
        print(f"Consumed: {item}")

def producer(condition, items):
    for i in range(5):
        item = random.randint(1, 100)
        with condition:
            items.append(item)
            print(f"Produced: {item}")
            condition.notify_all()
        time.sleep(1)

def main():
    with multiprocessing.Manager() as manager:
        condition = multiprocessing.Condition()
        items = manager.list()
        
        consumers = [multiprocessing.Process(target=consumer, args=(condition, items)) for _ in range(2)]
        producer_process = multiprocessing.Process(target=producer, args=(condition, items))
        
        for c in consumers:
            c.start()
        producer_process.start()
        
        producer_process.join()
        for c in consumers:
            c.terminate()

if __name__ == '__main__':
    main()
```

### Process Management

#### Process Properties and Methods

**Process Attributes:**

```python
import multiprocessing

def worker():
    print(f"PID: {multiprocessing.current_process().pid}")
    print(f"Name: {multiprocessing.current_process().name}")

process = multiprocessing.Process(target=worker, name="MyWorker")
print(f"Process name: {process.name}")
print(f"Process PID: {process.pid}")  # None until started
print(f"Is alive: {process.is_alive()}")

process.start()
print(f"Process PID: {process.pid}")
print(f"Is alive: {process.is_alive()}")

process.join()
print(f"Exit code: {process.exitcode}")
```

**Process Control:**

```python
import multiprocessing
import time

def long_running_task():
    for i in range(10):
        print(f"Working... {i}")
        time.sleep(1)

process = multiprocessing.Process(target=long_running_task)
process.start()

# Terminate after 3 seconds
time.sleep(3)
process.terminate()
process.join()

print(f"Process terminated with exit code: {process.exitcode}")
```

#### Process Monitoring

```python
import multiprocessing
import psutil  # External library for system monitoring

def monitor_processes(processes):
    while any(p.is_alive() for p in processes):
        for i, process in enumerate(processes):
            if process.is_alive():
                try:
                    proc_info = psutil.Process(process.pid)
                    cpu_percent = proc_info.cpu_percent()
                    memory_info = proc_info.memory_info()
                    print(f"Process {i}: CPU {cpu_percent}%, Memory {memory_info.rss / 1024 / 1024:.1f}MB")
                except psutil.NoSuchProcess:
                    pass
        time.sleep(1)
```

### Advanced Features

#### Custom Process Classes

```python
import multiprocessing
import time

class CustomProcess(multiprocessing.Process):
    def __init__(self, name, duration):
        super().__init__()
        self.name = name
        self.duration = duration
        self.result = None
    
    def run(self):
        print(f"Custom process {self.name} starting")
        time.sleep(self.duration)
        self.result = f"Completed {self.name}"
        print(f"Custom process {self.name} finished")

def main():
    processes = []
    for i in range(3):
        p = CustomProcess(f"Process-{i}", i + 1)
        processes.append(p)
        p.start()
    
    for p in processes:
        p.join()
        print(f"Result: {p.result}")

if __name__ == '__main__':
    main()
```

#### Process Context and Start Methods

```python
import multiprocessing

def worker(name):
    print(f"Worker {name} in process {multiprocessing.current_process().pid}")

def main():
    # Set start method (must be called before creating processes)
    multiprocessing.set_start_method('spawn', force=True)
    
    # Or use context for specific start method
    ctx = multiprocessing.get_context('spawn')
    
    processes = []
    for i in range(3):
        p = ctx.Process(target=worker, args=(f"Worker-{i}",))
        processes.append(p)
        p.start()
    
    for p in processes:
        p.join()

if __name__ == '__main__':
    main()
```

#### Error Handling in Processes

```python
import multiprocessing
import traceback

def worker_with_error(should_error):
    try:
        if should_error:
            raise ValueError("Intentional error")
        return "Success"
    except Exception as e:
        return f"Error: {str(e)}"

def error_callback(error):
    print(f"Error callback: {error}")

def success_callback(result):
    print(f"Success callback: {result}")

def main():
    with multiprocessing.Pool(processes=2) as pool:
        # Using error callbacks
        results = []
        for i, should_error in enumerate([False, True, False]):
            result = pool.apply_async(
                worker_with_error, 
                args=(should_error,),
                callback=success_callback,
                error_callback=error_callback
            )
            results.append(result)
        
        # Get results with timeout
        for i, result in enumerate(results):
            try:
                value = result.get(timeout=5)
                print(f"Result {i}: {value}")
            except multiprocessing.TimeoutError:
                print(f"Result {i}: Timeout")
            except Exception as e:
                print(f"Result {i}: Exception {e}")

if __name__ == '__main__':
    main()
```

### Performance Optimization

#### Choosing Optimal Process Count

```python
import multiprocessing
import time
import math

def cpu_intensive_task(n):
    # Simulate CPU-intensive work
    result = 0
    for i in range(n):
        result += math.sqrt(i)
    return result

def benchmark_processes(task_count, max_processes=None):
    if max_processes is None:
        max_processes = multiprocessing.cpu_count()
    
    tasks = [100000] * task_count
    
    for process_count in range(1, max_processes + 1):
        start_time = time.time()
        
        with multiprocessing.Pool(processes=process_count) as pool:
            results = pool.map(cpu_intensive_task, tasks)
        
        end_time = time.time()
        print(f"Processes: {process_count}, Time: {end_time - start_time:.2f}s")

def main():
    print(f"CPU count: {multiprocessing.cpu_count()}")
    benchmark_processes(8)

if __name__ == '__main__':
    main()
```

#### Memory-Efficient Processing

```python
import multiprocessing
import sys

def process_chunk(chunk):
    # Process data in chunks to manage memory
    result = []
    for item in chunk:
        # Simulate processing
        result.append(item * 2)
    return result

def chunk_data(data, chunk_size):
    for i in range(0, len(data), chunk_size):
        yield data[i:i + chunk_size]

def main():
    # Large dataset
    large_data = list(range(1000000))
    chunk_size = 10000
    
    chunks = list(chunk_data(large_data, chunk_size))
    
    with multiprocessing.Pool() as pool:
        results = pool.map(process_chunk, chunks)
    
    # Flatten results
    final_result = []
    for chunk_result in results:
        final_result.extend(chunk_result)
    
    print(f"Processed {len(final_result)} items")

if __name__ == '__main__':
    main()
```

### Common Patterns and Best Practices

#### Producer-Consumer Pattern

```python
import multiprocessing
import time
import random

def producer(queue, num_items):
    for i in range(num_items):
        item = random.randint(1, 100)
        queue.put(item)
        print(f"Produced: {item}")
        time.sleep(0.1)
    
    # Send sentinel values to stop consumers
    queue.put(None)

def consumer(queue, consumer_id):
    while True:
        item = queue.get()
        if item is None:
            queue.put(None)  # Pass sentinel to other consumers
            break
        
        # Simulate processing time
        time.sleep(0.2)
        print(f"Consumer {consumer_id} processed: {item}")

def main():
    queue = multiprocessing.Queue(maxsize=10)
    
    # Start producer
    producer_process = multiprocessing.Process(target=producer, args=(queue, 20))
    producer_process.start()
    
    # Start consumers
    consumers = []
    for i in range(3):
        consumer_process = multiprocessing.Process(target=consumer, args=(queue, i))
        consumers.append(consumer_process)
        consumer_process.start()
    
    # Wait for completion
    producer_process.join()
    for consumer_process in consumers:
        consumer_process.join()

if __name__ == '__main__':
    main()
```

#### Map-Reduce Pattern

```python
import multiprocessing
from collections import defaultdict
import string

def mapper(text_chunk):
    """Map phase: count words in text chunk"""
    word_count = defaultdict(int)
    words = text_chunk.lower().translate(str.maketrans('', '', string.punctuation)).split()
    
    for word in words:
        word_count[word] += 1
    
    return dict(word_count)

def reducer(word_counts_list):
    """Reduce phase: combine word counts"""
    total_counts = defaultdict(int)
    
    for word_counts in word_counts_list:
        for word, count in word_counts.items():
            total_counts[word] += count
    
    return dict(total_counts)

def main():
    # Sample text data
    text_data = [
        "Hello world hello universe",
        "World of multiprocessing is great",
        "Hello great world of Python"
    ]
    
    # Map phase
    with multiprocessing.Pool() as pool:
        map_results = pool.map(mapper, text_data)
    
    # Reduce phase
    final_counts = reducer(map_results)
    
    print("Word counts:", final_counts)

if __name__ == '__main__':
    main()
```

### Debugging and Logging

#### Logging in Multiprocessing

```python
import multiprocessing
import logging
import sys

def setup_logging():
    # Configure logging for multiprocessing
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(processName)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler('multiprocessing.log')
        ]
    )

def worker(name, shared_queue):
    logger = logging.getLogger()
    logger.info(f"Worker {name} starting")
    
    try:
        # Simulate work
        result = sum(range(1000000))
        shared_queue.put((name, result))
        logger.info(f"Worker {name} completed with result {result}")
    except Exception as e:
        logger.error(f"Worker {name} failed: {e}")
        shared_queue.put((name, None))

def main():
    setup_logging()
    logger = logging.getLogger()
    
    queue = multiprocessing.Queue()
    processes = []
    
    for i in range(3):
        p = multiprocessing.Process(target=worker, args=(f"Worker-{i}", queue))
        processes.append(p)
        p.start()
        logger.info(f"Started process {p.name}")
    
    # Collect results
    results = []
    for _ in range(3):
        results.append(queue.get())
    
    for p in processes:
        p.join()
        logger.info(f"Process {p.name} joined")
    
    logger.info(f"All results: {results}")

if __name__ == '__main__':
    main()
```

#### Exception Handling and Debugging

```python
import multiprocessing
import traceback
import sys

def problematic_worker(x):
    if x == 3:
        raise ValueError(f"Problem with value {x}")
    return x * x

def safe_worker(x):
    try:
        return problematic_worker(x)
    except Exception as e:
        # Return error information instead of raising
        return {
            'error': str(e),
            'traceback': traceback.format_exc(),
            'input': x
        }

def main():
    data = [1, 2, 3, 4, 5]
    
    with multiprocessing.Pool() as pool:
        results = pool.map(safe_worker, data)
    
    for i, result in enumerate(results):
        if isinstance(result, dict) and 'error' in result:
            print(f"Error in item {i}: {result['error']}")
            print(f"Traceback: {result['traceback']}")
        else:
            print(f"Result {i}: {result}")

if __name__ == '__main__':
    main()
```

### Platform-Specific Considerations

#### Windows Considerations

On Windows, the entire script is re-imported when starting new processes, which can cause issues if not properly protected with `if __name__ == '__main__'`. The spawn start method is default and required.

#### Unix/Linux Considerations

Fork start method is default but can cause issues with threads or certain libraries. Consider using spawn or forkserver for better compatibility.

#### macOS Considerations

Recent versions default to spawn method. Fork method may cause crashes with certain GUI frameworks.

### Integration with Other Libraries

#### NumPy and Scientific Computing

```python
import multiprocessing
import numpy as np

def process_array_chunk(chunk):
    # Perform computation on numpy array chunk
    return np.sum(chunk ** 2)

def main():
    # Large numpy array
    large_array = np.random.rand(1000000)
    
    # Split into chunks
    num_processes = multiprocessing.cpu_count()
    chunks = np.array_split(large_array, num_processes)
    
    with multiprocessing.Pool() as pool:
        results = pool.map(process_array_chunk, chunks)
    
    total_result = sum(results)
    print(f"Total result: {total_result}")

if __name__ == '__main__':
    main()
```

#### Database Operations

```python
import multiprocessing
import sqlite3
import os

def init_worker():
    # Initialize database connection per process
    global db_conn
    db_conn = sqlite3.connect('worker.db')

def process_data_batch(batch):
    # Use the process-local database connection
    cursor = db_conn.cursor()
    results = []
    for item in batch:
        cursor.execute("SELECT * FROM table WHERE id = ?", (item,))
        results.append(cursor.fetchone())
    return results

def main():
    # Create database and table (simplified example)
    with sqlite3.connect('worker.db') as conn:
        conn.execute("CREATE TABLE IF NOT EXISTS table (id INTEGER, value TEXT)")
        conn.execute("INSERT INTO table VALUES (1, 'one'), (2, 'two'), (3, 'three')")
        conn.commit()
    
    data_batches = [[1, 2], [2, 3], [1, 3]]
    
    with multiprocessing.Pool(initializer=init_worker) as pool:
        results = pool.map(process_data_batch, data_batches)
    
    print("Results:", results)

if __name__ == '__main__':
    main()
```

### Memory Management and Resource Cleanup

#### Proper Resource Management

```python
import multiprocessing
import time
import resource

def memory_intensive_worker(size):
    # Allocate large amount of memory
    data = [0] * size
    
    # Get memory usage
    memory_usage = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    
    # Process data
    result = sum(data)
    
    # Explicitly delete large objects
    del data
    
    return result, memory_usage

def monitor_memory():
    """Monitor system memory usage"""
    import psutil
    process = psutil.Process()
    return process.memory_info().rss / 1024 / 1024  # MB

def main():
    print(f"Initial memory: {monitor_memory():.1f} MB")
    
    with multiprocessing.Pool(processes=2) as pool:
        sizes = [1000000, 2000000, 1500000]
        results = pool.map(memory_intensive_worker, sizes)
    
    print(f"Final memory: {monitor_memory():.1f} MB")
    print("Results:", results)

if __name__ == '__main__':
    main()
```

**Key points**: The multiprocessing module enables true parallelism by creating separate processes, bypassing Python's GIL. Use Process class for basic parallel execution, Pool for easy function mapping, and various IPC mechanisms (Queue, Pipe, shared memory) for data exchange. Always protect main code with `if __name__ == '__main__'` and choose appropriate start methods based on platform requirements.


---

##  `itertools` Module

### Overview

The `itertools` module provides a collection of tools for creating iterators and working with iterable objects efficiently. It implements iterator building blocks inspired by functional programming languages and offers memory-efficient solutions for complex iteration patterns. All functions return iterators, making them suitable for processing large datasets without loading everything into memory.

### Infinite Iterators

#### count()

Creates an arithmetic progression starting from a given number with a specified step.

```python
import itertools

# Basic counting
counter = itertools.count(10, 2)  # Start at 10, step by 2
for i in counter:
    if i > 20:
        break
    print(i)  # Outputs: 10, 12, 14, 16, 18, 20

# With negative step
countdown = itertools.count(5, -1)
for i in countdown:
    if i < 0:
        break
    print(i)  # Outputs: 5, 4, 3, 2, 1, 0
```

#### cycle()

Infinitely repeats elements from an iterable in order.

```python
colors = itertools.cycle(['red', 'green', 'blue'])
for i, color in enumerate(colors):
    if i >= 10:
        break
    print(f"{i}: {color}")
# Outputs: 0: red, 1: green, 2: blue, 3: red, 4: green...

# Practical example: Round-robin assignment
tasks = ['task1', 'task2', 'task3', 'task4']
workers = itertools.cycle(['worker_a', 'worker_b', 'worker_c'])
assignments = list(zip(tasks, workers))
# [('task1', 'worker_a'), ('task2', 'worker_b'), ('task3', 'worker_c'), ('task4', 'worker_a')]
```

#### repeat()

Repeats a single value either infinitely or for a specified number of times.

```python
# Infinite repetition
ones = itertools.repeat(1)
limited_ones = list(itertools.islice(ones, 5))  # [1, 1, 1, 1, 1]

# Limited repetition
zeros = itertools.repeat(0, 3)
print(list(zeros))  # [0, 0, 0]

# Practical example: Initialize multiple lists
matrix = [list(itertools.repeat(0, 5)) for _ in range(3)]
# [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]
```

### Iterators Terminating on Shortest Input

#### accumulate()

Returns accumulated values using a binary function (default is addition).

```python
# Basic accumulation (cumulative sum)
numbers = [1, 2, 3, 4, 5]
cumsum = list(itertools.accumulate(numbers))
print(cumsum)  # [1, 3, 6, 10, 15]

# With custom function (cumulative product)
import operator
product = list(itertools.accumulate(numbers, operator.mul))
print(product)  # [1, 2, 6, 24, 120]

# With custom lambda (running maximum)
data = [3, 1, 4, 1, 5, 9, 2, 6]
running_max = list(itertools.accumulate(data, max))
print(running_max)  # [3, 3, 4, 4, 5, 9, 9, 9]

# Practical example: Running balance
transactions = [100, -20, 50, -30, 25]
balance = list(itertools.accumulate(transactions))
print(balance)  # [100, 80, 130, 100, 125]
```

#### chain()

Flattens multiple iterables into a single iterator.

```python
# Basic chaining
list1 = [1, 2, 3]
list2 = ['a', 'b', 'c']
list3 = [10, 20]
chained = list(itertools.chain(list1, list2, list3))
print(chained)  # [1, 2, 3, 'a', 'b', 'c', 10, 20]

# chain.from_iterable() for nested iterables
nested = [[1, 2], [3, 4], [5, 6]]
flattened = list(itertools.chain.from_iterable(nested))
print(flattened)  # [1, 2, 3, 4, 5, 6]

# Practical example: Combining multiple data sources
users_db1 = ['alice', 'bob']
users_db2 = ['charlie', 'diana']
users_cache = ['eve']
all_users = list(itertools.chain(users_db1, users_db2, users_cache))
```

#### compress()

Filters elements based on corresponding boolean selectors.

```python
data = ['a', 'b', 'c', 'd', 'e']
selectors = [1, 0, 1, 0, 1]
filtered = list(itertools.compress(data, selectors))
print(filtered)  # ['a', 'c', 'e']

# Practical example: Filter based on conditions
scores = [85, 92, 78, 96, 88]
passing = [score >= 80 for score in scores]
passing_scores = list(itertools.compress(scores, passing))
print(passing_scores)  # [85, 92, 96, 88]
```

#### dropwhile()

Drops elements from the beginning while a predicate is true, then returns the rest.

```python
numbers = [1, 3, 5, 24, 7, 11, 9, 2]
# Drop while numbers are odd
result = list(itertools.dropwhile(lambda x: x % 2 == 1, numbers))
print(result)  # [24, 7, 11, 9, 2] - stops dropping after first even number

# Practical example: Skip header comments in a file
lines = ['# Comment 1', '# Comment 2', 'data line 1', 'data line 2']
data_lines = list(itertools.dropwhile(lambda x: x.startswith('#'), lines))
print(data_lines)  # ['data line 1', 'data line 2']
```

#### takewhile()

Takes elements while a predicate is true, then stops.

```python
numbers = [1, 3, 5, 24, 7, 11]
# Take while numbers are odd
result = list(itertools.takewhile(lambda x: x % 2 == 1, numbers))
print(result)  # [1, 3, 5] - stops at first even number

# Practical example: Process items until a condition
temperatures = [20, 22, 25, 30, 35, 28, 24]
comfortable = list(itertools.takewhile(lambda x: x < 30, temperatures))
print(comfortable)  # [20, 22, 25]
```

#### filterfalse()

Returns elements where the predicate is false (opposite of filter()).

```python
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
odd_numbers = list(itertools.filterfalse(lambda x: x % 2 == 0, numbers))
print(odd_numbers)  # [1, 3, 5, 7, 9]

# Equivalent to filter with negated condition
even_numbers = list(filter(lambda x: x % 2 == 0, numbers))
not_even = list(itertools.filterfalse(lambda x: x % 2 == 0, numbers))
```

#### groupby()

Groups consecutive elements by a key function.

```python
# Basic grouping
data = ['a', 'a', 'b', 'b', 'b', 'c', 'a', 'a']
grouped = [(key, list(group)) for key, group in itertools.groupby(data)]
print(grouped)  # [('a', ['a', 'a']), ('b', ['b', 'b', 'b']), ('c', ['c']), ('a', ['a', 'a'])]

# With key function
students = [
    ('Alice', 'A'), ('Bob', 'B'), ('Charlie', 'A'), 
    ('David', 'A'), ('Eve', 'B'), ('Frank', 'C')
]
by_grade = [(grade, list(group)) for grade, group in 
           itertools.groupby(sorted(students, key=lambda x: x[1]), key=lambda x: x[1])]

# Practical example: Group transactions by date
transactions = [
    ('2023-01-01', 100), ('2023-01-01', 50), 
    ('2023-01-02', 75), ('2023-01-02', 25), ('2023-01-02', 200)
]
daily_totals = [(date, sum(amount for _, amount in group)) 
               for date, group in itertools.groupby(transactions, key=lambda x: x[0])]
```

#### islice()

Returns selected elements from an iterable using slice notation.

```python
numbers = range(20)

# islice(iterable, stop)
first_five = list(itertools.islice(numbers, 5))
print(first_five)  # [0, 1, 2, 3, 4]

# islice(iterable, start, stop)
middle = list(itertools.islice(numbers, 5, 10))
print(middle)  # [5, 6, 7, 8, 9]

# islice(iterable, start, stop, step)
every_third = list(itertools.islice(numbers, 0, 20, 3))
print(every_third)  # [0, 3, 6, 9, 12, 15, 18]

# Practical example: Pagination
def paginate(iterable, page_size):
    iterator = iter(iterable)
    while True:
        page = list(itertools.islice(iterator, page_size))
        if not page:
            break
        yield page

data = range(25)
for page_num, page in enumerate(paginate(data, 7), 1):
    print(f"Page {page_num}: {page}")
```

#### starmap()

Applies a function to arguments tuples from an iterable.

```python
import operator

# Basic usage with operator functions
pairs = [(2, 5), (3, 2), (10, 3)]
powers = list(itertools.starmap(pow, pairs))
print(powers)  # [32, 9, 1000] - 2^5, 3^2, 10^3

# With custom function
def multiply_add(a, b, c):
    return a * b + c

data = [(2, 3, 1), (4, 5, 2), (1, 6, 3)]
results = list(itertools.starmap(multiply_add, data))
print(results)  # [7, 22, 9] - (2*3+1), (4*5+2), (1*6+3)

# Practical example: Distance calculations
import math
points = [(0, 0, 3, 4), (1, 1, 4, 5)]  # (x1, y1, x2, y2)
distances = list(itertools.starmap(
    lambda x1, y1, x2, y2: math.sqrt((x2-x1)**2 + (y2-y1)**2), points))
```

#### tee()

Creates multiple independent iterators from a single iterable.

```python
data = [1, 2, 3, 4, 5]
iter1, iter2, iter3 = itertools.tee(data, 3)

# Each iterator is independent
print(list(iter1))  # [1, 2, 3, 4, 5]
print(list(iter2))  # [1, 2, 3, 4, 5]
print(list(iter3))  # [1, 2, 3, 4, 5]

# Practical example: Process data in multiple ways
def analyze_data(data):
    sum_iter, max_iter, min_iter = itertools.tee(data, 3)
    return sum(sum_iter), max(max_iter), min(min_iter)

numbers = [3, 1, 4, 1, 5, 9, 2, 6]
total, maximum, minimum = analyze_data(numbers)
```

#### zip_longest()

Zips iterables of different lengths, filling missing values with a fillvalue.

```python
# Basic usage
list1 = [1, 2, 3]
list2 = ['a', 'b', 'c', 'd', 'e']
zipped = list(itertools.zip_longest(list1, list2, fillvalue=0))
print(zipped)  # [(1, 'a'), (2, 'b'), (3, 'c'), (0, 'd'), (0, 'e')]

# Multiple iterables with different fillvalues
names = ['Alice', 'Bob']
ages = [25, 30, 35]
cities = ['NYC', 'LA', 'Chicago', 'Miami']
combined = list(itertools.zip_longest(names, ages, cities, fillvalue='N/A'))
# [('Alice', 25, 'NYC'), ('Bob', 30, 'LA'), ('N/A', 35, 'Chicago'), ('N/A', 'N/A', 'Miami')]
```

### Combinatorial Iterators

#### product()

Cartesian product of input iterables.

```python
# Basic product
colors = ['red', 'blue']
sizes = ['S', 'M', 'L']
combinations = list(itertools.product(colors, sizes))
print(combinations)  
# [('red', 'S'), ('red', 'M'), ('red', 'L'), ('blue', 'S'), ('blue', 'M'), ('blue', 'L')]

# With repeat parameter
dice_rolls = list(itertools.product(range(1, 7), repeat=2))
print(len(dice_rolls))  # 36 - all possible pairs of dice rolls

# Practical example: Generate test cases
test_params = {
    'browser': ['chrome', 'firefox'],
    'os': ['windows', 'mac'],
    'version': ['v1', 'v2']
}
test_cases = list(itertools.product(*test_params.values()))
```

#### permutations()

Returns all permutations of an iterable.

```python
# All permutations
letters = ['A', 'B', 'C']
perms = list(itertools.permutations(letters))
print(perms)  # [('A', 'B', 'C'), ('A', 'C', 'B'), ('B', 'A', 'C'), ('B', 'C', 'A'), ('C', 'A', 'B'), ('C', 'B', 'A')]

# Permutations of specific length
perms_2 = list(itertools.permutations(letters, 2))
print(perms_2)  # [('A', 'B'), ('A', 'C'), ('B', 'A'), ('B', 'C'), ('C', 'A'), ('C', 'B')]

# Practical example: Generate possible passwords
digits = '123'
possible_pins = [''.join(p) for p in itertools.permutations(digits, 3)]
print(possible_pins)  # ['123', '132', '213', '231', '312', '321']
```

#### combinations()

Returns combinations without repetition.

```python
# Basic combinations
items = ['A', 'B', 'C', 'D']
pairs = list(itertools.combinations(items, 2))
print(pairs)  # [('A', 'B'), ('A', 'C'), ('A', 'D'), ('B', 'C'), ('B', 'D'), ('C', 'D')]

# Combinations of different lengths
for r in range(1, len(items) + 1):
    combs = list(itertools.combinations(items, r))
    print(f"Combinations of {r}: {len(combs)} items")

# Practical example: Team selection
players = ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve']
teams_of_3 = list(itertools.combinations(players, 3))
print(f"Possible teams of 3: {len(teams_of_3)}")
```

#### combinations_with_replacement()

Returns combinations with repetition allowed.

```python
# Basic usage
items = ['A', 'B', 'C']
combs_with_rep = list(itertools.combinations_with_replacement(items, 2))
print(combs_with_rep)  # [('A', 'A'), ('A', 'B'), ('A', 'C'), ('B', 'B'), ('B', 'C'), ('C', 'C')]

# Practical example: Ice cream flavors with multiple scoops
flavors = ['vanilla', 'chocolate', 'strawberry']
double_scoops = list(itertools.combinations_with_replacement(flavors, 2))
print(f"Double scoop options: {len(double_scoops)}")
```

### Advanced Patterns and Use Cases

#### Pairwise Iteration

```python
def pairwise(iterable):
    """Return successive overlapping pairs from iterable."""
    a, b = itertools.tee(iterable)
    next(b, None)
    return zip(a, b)

# Example usage
numbers = [1, 2, 3, 4, 5]
pairs = list(pairwise(numbers))
print(pairs)  # [(1, 2), (2, 3), (3, 4), (4, 5)]

# Calculate differences between consecutive elements
differences = [b - a for a, b in pairwise(numbers)]
print(differences)  # [1, 1, 1, 1]
```

#### Sliding Window

```python
def sliding_window(iterable, n):
    """Create a sliding window of size n over iterable."""
    iterators = itertools.tee(iterable, n)
    for i, iterator in enumerate(iterators):
        for _ in range(i):
            next(iterator, None)
    return zip(*iterators)

# Example usage
data = [1, 2, 3, 4, 5, 6, 7]
windows = list(sliding_window(data, 3))
print(windows)  # [(1, 2, 3), (2, 3, 4), (3, 4, 5), (4, 5, 6), (5, 6, 7)]

# Moving average calculation
def moving_average(data, window_size):
    windows = sliding_window(data, window_size)
    return [sum(window) / len(window) for window in windows]

prices = [10, 12, 11, 14, 13, 15, 16]
ma_3 = moving_average(prices, 3)
print(ma_3)  # [11.0, 12.33..., 12.66..., 14.0, 14.66...]
```

#### Flatten Nested Structures

```python
def flatten(nested_list):
    """Recursively flatten nested lists."""
    for item in nested_list:
        if isinstance(item, (list, tuple)):
            yield from flatten(item)
        else:
            yield item

# Example usage
nested = [1, [2, 3], [4, [5, 6]], 7]
flat = list(flatten(nested))
print(flat)  # [1, 2, 3, 4, 5, 6, 7]

# Using itertools for simple flattening
simple_nested = [[1, 2], [3, 4], [5, 6]]
flat_simple = list(itertools.chain.from_iterable(simple_nested))
print(flat_simple)  # [1, 2, 3, 4, 5, 6]
```

#### Recipe: Batching

```python
def batched(iterable, n):
    """Batch data into tuples of length n."""
    if n < 1:
        raise ValueError('n must be at least one')
    iterator = iter(iterable)
    while True:
        batch = tuple(itertools.islice(iterator, n))
        if not batch:
            break
        yield batch

# Example usage
data = range(13)
batches = list(batched(data, 4))
print(batches)  # [(0, 1, 2, 3), (4, 5, 6, 7), (8, 9, 10, 11), (12,)]

# Process data in chunks
def process_in_batches(data, batch_size=100):
    for batch in batched(data, batch_size):
        # Process each batch
        result = sum(batch)  # Example processing
        yield result
```

#### Recipe: Unique Elements with Order Preservation

```python
def unique_everseen(iterable, key=None):
    """List unique elements, preserving order. Remember all elements ever seen."""
    seen = set()
    seen_add = seen.add
    if key is None:
        for element in itertools.filterfalse(seen.__contains__, iterable):
            seen_add(element)
            yield element
    else:
        for element in iterable:
            k = key(element)
            if k not in seen:
                seen_add(k)
                yield element

# Example usage
data = [1, 2, 3, 2, 4, 3, 5, 1]
unique = list(unique_everseen(data))
print(unique)  # [1, 2, 3, 4, 5]

# With key function
words = ['apple', 'BANANA', 'apple', 'Cherry', 'banana']
unique_words = list(unique_everseen(words, key=str.lower))
print(unique_words)  # ['apple', 'BANANA', 'Cherry']
```

### Performance Considerations

#### Memory Efficiency

All itertools functions return iterators, not lists, making them memory-efficient for large datasets.

```python
# Memory efficient - processes one item at a time
def process_large_dataset(filename):
    with open(filename) as f:
        # Chain multiple processing steps without creating intermediate lists
        lines = (line.strip() for line in f)
        non_empty = filter(None, lines)
        numbers = (int(line) for line in non_empty if line.isdigit())
        
        # Process in batches
        for batch in batched(numbers, 1000):
            yield sum(batch)

# Compare memory usage
import sys

# Memory intensive - creates full list
large_list = list(range(1000000))
print(f"List size: {sys.getsizeof(large_list)} bytes")

# Memory efficient - iterator
large_iter = itertools.count()
print(f"Iterator size: {sys.getsizeof(large_iter)} bytes")
```

#### Performance Tips

**Key points:**

- Use `itertools.chain.from_iterable()` instead of nested loops for flattening
- `itertools.accumulate()` is faster than manual accumulation loops
- `itertools.compress()` can be more efficient than list comprehensions with conditions
- `itertools.tee()` creates independent iterators but uses more memory as elements are consumed
- Combinatorial functions can generate very large result sets - use with caution

### Common Recipes and Patterns

#### Roundrobin

```python
def roundrobin(*iterables):
    """Visit input iterables in a round-robin fashion."""
    pending = len(iterables)
    nexts = itertools.cycle(iter(it).__next__ for it in iterables)
    while pending:
        try:
            for next in nexts:
                yield next()
        except StopIteration:
            pending -= 1
            nexts = itertools.cycle(itertools.islice(nexts, pending))

# Example usage
result = list(roundrobin('ABC', '12345', 'xyz'))
print(result)  # ['A', '1', 'x', 'B', '2', 'y', 'C', '3', 'z', '4', '5']
```

#### Partition

```python
def partition(predicate, iterable):
    """Partition entries into false entries and true entries."""
    t1, t2 = itertools.tee(iterable)
    return itertools.filterfalse(predicate, t1), filter(predicate, t2)

# Example usage
numbers = range(10)
evens, odds = partition(lambda x: x % 2, numbers)
print(f"Evens: {list(evens)}")  # [0, 2, 4, 6, 8]
print(f"Odds: {list(odds)}")    # [1, 3, 5, 7, 9]
```

#### Powerset

```python
def powerset(iterable):
    """Return the powerset of an iterable."""
    s = list(iterable)
    return itertools.chain.from_iterable(
        itertools.combinations(s, r) for r in range(len(s) + 1))

# Example usage
items = ['A', 'B', 'C']
ps = list(powerset(items))
print(ps)  # [(), ('A',), ('B',), ('C',), ('A', 'B'), ('A', 'C'), ('B', 'C'), ('A', 'B', 'C')]
```

### Integration with Other Python Features

#### Generator Expressions

```python
# Combining itertools with generator expressions
data = range(100)
processed = (x**2 for x in itertools.takewhile(lambda x: x < 10, data))
result = list(itertools.accumulate(processed))
print(result)  # [0, 1, 5, 14, 30, 55, 91, 140, 204, 285]
```

#### Functools Integration

```python
import functools
import operator

# Using with functools.reduce
numbers = [1, 2, 3, 4, 5]
cumulative_products = list(itertools.accumulate(numbers, operator.mul))
total_product = functools.reduce(operator.mul, numbers)

# Partial application with itertools
multiply_by_2 = functools.partial(operator.mul, 2)
doubled = list(map(multiply_by_2, range(5)))
```

#### Collections Integration

```python
from collections import Counter, defaultdict

# Frequency counting with groupby
data = 'aabbccddaab'
frequencies = {key: len(list(group)) for key, group in itertools.groupby(sorted(data))}
print(frequencies)  # {'a': 4, 'b': 3, 'c': 2, 'd': 2}

# Compare with Counter
counter_freq = Counter(data)
print(dict(counter_freq))  # {'a': 4, 'b': 3, 'c': 2, 'd': 2}
```

### Error Handling and Edge Cases

#### Empty Iterables

```python
# Handle empty iterables gracefully
empty_list = []
print(list(itertools.chain(empty_list, [1, 2, 3])))  # [1, 2, 3]
print(list(itertools.accumulate(empty_list)))  # []
print(list(itertools.combinations(empty_list, 2)))  # []

# Check for empty results
def safe_max(iterable):
    try:
        return max(iterable)
    except ValueError:
        return None

data = []
result = safe_max(itertools.chain(data, [0]))  # Provides default
```

#### Large Combinatorial Results

```python
# Be careful with combinatorial explosions
items = list(range(20))
# This would create 2^20 combinations - over 1 million!
# powerset_result = list(powerset(items))  # Don't do this!

# Instead, process in chunks or limit the size
limited_combinations = itertools.islice(
    itertools.combinations(items, 3), 100)  # Only first 100 combinations
safe_result = list(limited_combinations)
```

**Key points:**

- Itertools functions return memory-efficient iterators, not lists
- Combinatorial functions can generate extremely large result sets
- All itertools objects are consumed once - use `itertools.tee()` for multiple iterations
- Perfect for data processing pipelines and functional programming patterns
- Excellent for handling large datasets that don't fit in memory
- Can be combined with generator expressions and other functional programming tools
- [Inference] Performance is generally excellent due to C implementation of core functions
- Essential for writing efficient, readable code that processes sequences and combinations

The itertools module provides a comprehensive toolkit for iterator-based programming, enabling elegant solutions to complex iteration problems while maintaining excellent performance and memory efficiency.

---

## `functools` Module

### Overview

The functools module provides utilities for working with higher-order functions and operations on callable objects. It includes tools for function composition, caching, partial application, method overloading, and functional programming patterns. The module is essential for creating decorators, optimizing function calls through memoization, and implementing advanced function manipulation techniques.

### Core Functionality

The functools module serves as Python's toolkit for functional programming concepts. It bridges object-oriented and functional programming paradigms by providing utilities that transform, combine, and optimize functions. The module includes both simple utilities like partial application and sophisticated features like least-recently-used caching and generic function dispatch.

### Caching and Memoization

#### lru_cache Decorator

The Least Recently Used (LRU) cache decorator automatically caches function results, significantly improving performance for expensive computations with repeated inputs:

```python
import functools
import time

@functools.lru_cache(maxsize=128)
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

@functools.lru_cache(maxsize=None)  # Unlimited cache size
def expensive_computation(x, y):
    time.sleep(1)  # Simulate expensive operation
    return x * y + x ** y

# Usage
print(fibonacci(50))  # Fast due to caching
print(expensive_computation(2, 3))  # Slow first time
print(expensive_computation(2, 3))  # Fast second time

# Cache statistics
print(fibonacci.cache_info())  # CacheInfo(hits=48, misses=51, maxsize=128, currsize=51)
fibonacci.cache_clear()  # Clear the cache
```

#### cache Decorator

Python 3.9+ introduced a simplified cache decorator with unlimited size:

```python
import functools

@functools.cache
def factorial(n):
    if n <= 1:
        return 1
    return n * factorial(n-1)

print(factorial(100))  # Computed once
print(factorial(100))  # Retrieved from cache
```

#### cached_property

Creates a cached property that computes the value once and stores it:

```python
import functools
import time

class DataProcessor:
    def __init__(self, data):
        self.data = data
    
    @functools.cached_property
    def processed_data(self):
        print("Processing data...")
        time.sleep(2)  # Simulate expensive processing
        return [x * 2 for x in self.data]
    
    @functools.cached_property
    def statistics(self):
        return {
            'mean': sum(self.processed_data) / len(self.processed_data),
            'max': max(self.processed_data),
            'min': min(self.processed_data)
        }

processor = DataProcessor([1, 2, 3, 4, 5])
print(processor.processed_data)  # Processes data
print(processor.processed_data)  # Returns cached result
print(processor.statistics)      # Uses cached processed_data
```

### Partial Application

#### partial Function

Creates a new partial object which behaves like a function with some arguments pre-filled:

```python
import functools

def multiply(x, y, z):
    return x * y * z

# Create partial functions
double = functools.partial(multiply, 2)      # Pre-fill x=2
triple_by_two = functools.partial(multiply, 2, 3)  # Pre-fill x=2, y=3

print(double(3, 4))      # multiply(2, 3, 4) = 24
print(triple_by_two(5))  # multiply(2, 3, 5) = 30

# Partial with keyword arguments
def greet(greeting, name, punctuation="!"):
    return f"{greeting}, {name}{punctuation}"

hello = functools.partial(greet, "Hello")
formal_hello = functools.partial(greet, "Hello", punctuation=".")

print(hello("Alice"))           # "Hello, Alice!"
print(formal_hello("Bob"))      # "Hello, Bob."
```

#### partialmethod

Similar to partial but designed for methods in class definitions:

```python
import functools

class Calculator:
    def operation(self, a, b, op):
        if op == 'add':
            return a + b
        elif op == 'multiply':
            return a * b
        elif op == 'power':
            return a ** b
    
    add = functools.partialmethod(operation, op='add')
    multiply = functools.partialmethod(operation, op='multiply')
    power = functools.partialmethod(operation, op='power')

calc = Calculator()
print(calc.add(5, 3))       # 8
print(calc.multiply(4, 6))  # 24
print(calc.power(2, 8))     # 256
```

### Function Composition and Transformation

#### reduce Function

Applies a function of two arguments cumulatively to items in an iterable:

```python
import functools

# Sum all numbers
numbers = [1, 2, 3, 4, 5]
total = functools.reduce(lambda x, y: x + y, numbers)
print(total)  # 15

# Find maximum
maximum = functools.reduce(lambda x, y: x if x > y else y, numbers)
print(maximum)  # 5

# Factorial using reduce
def factorial_reduce(n):
    return functools.reduce(lambda x, y: x * y, range(1, n + 1))

print(factorial_reduce(5))  # 120

# String concatenation
words = ['Hello', 'world', 'from', 'Python']
sentence = functools.reduce(lambda x, y: x + ' ' + y, words)
print(sentence)  # "Hello world from Python"

# Complex data processing
data = [{'value': 10}, {'value': 20}, {'value': 30}]
total_value = functools.reduce(lambda acc, item: acc + item['value'], data, 0)
print(total_value)  # 60
```

#### wraps Decorator

Essential for creating proper decorators that preserve function metadata:

```python
import functools
import time

def timing_decorator(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        print(f"{func.__name__} took {end_time - start_time:.4f} seconds")
        return result
    return wrapper

@timing_decorator
def slow_function():
    """This function is intentionally slow."""
    time.sleep(1)
    return "Done"

print(slow_function.__name__)  # "slow_function" (preserved)
print(slow_function.__doc__)   # "This function is intentionally slow." (preserved)
result = slow_function()
```

#### update_wrapper Function

Lower-level function used by wraps to copy metadata:

```python
import functools

def manual_decorator(func):
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    
    # Manually update wrapper metadata
    functools.update_wrapper(wrapper, func)
    return wrapper

@manual_decorator
def example_function():
    """Example function documentation."""
    return "Hello"

print(example_function.__name__)  # "example_function"
print(example_function.__doc__)   # "Example function documentation."
```

### Generic Functions and Single Dispatch

#### singledispatch Decorator

Creates a generic function that behaves differently based on the type of its first argument:

```python
import functools
from collections.abc import Sequence

@functools.singledispatch
def process_data(arg):
    """Default implementation for unknown types."""
    print(f"Processing unknown type: {type(arg)}")
    return str(arg)

@process_data.register
def _(arg: int):
    print("Processing integer")
    return arg * 2

@process_data.register
def _(arg: str):
    print("Processing string")
    return arg.upper()

@process_data.register
def _(arg: list):
    print("Processing list")
    return [x * 2 for x in arg]

@process_data.register(tuple)
def process_tuple(arg):
    print("Processing tuple")
    return tuple(x * 2 for x in arg)

# Usage
print(process_data(5))           # Processing integer -> 10
print(process_data("hello"))     # Processing string -> "HELLO"
print(process_data([1, 2, 3]))   # Processing list -> [2, 4, 6]
print(process_data((1, 2, 3)))   # Processing tuple -> (2, 4, 6)
print(process_data(3.14))        # Processing unknown type -> "3.14"
```

#### singledispatchmethod

Similar to singledispatch but for methods:

```python
import functools

class DataFormatter:
    @functools.singledispatchmethod
    def format(self, arg):
        return f"Unknown format for {type(arg)}"
    
    @format.register
    def _(self, arg: int):
        return f"Integer: {arg:,}"
    
    @format.register
    def _(self, arg: float):
        return f"Float: {arg:.2f}"
    
    @format.register
    def _(self, arg: str):
        return f"String: '{arg}'"
    
    @format.register
    def _(self, arg: list):
        return f"List with {len(arg)} items: {arg}"

formatter = DataFormatter()
print(formatter.format(1000))      # Integer: 1,000
print(formatter.format(3.14159))   # Float: 3.14
print(formatter.format("hello"))   # String: 'hello'
print(formatter.format([1, 2, 3])) # List with 3 items: [1, 2, 3]
```

### Advanced Decorators and Utilities

#### Custom Caching Decorators

Building custom caching mechanisms using functools principles:

```python
import functools
import time
import threading

def timed_cache(expiry_seconds):
    """Custom cache with time-based expiry."""
    def decorator(func):
        cache = {}
        lock = threading.Lock()
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            key = str(args) + str(sorted(kwargs.items()))
            current_time = time.time()
            
            with lock:
                if key in cache:
                    result, timestamp = cache[key]
                    if current_time - timestamp < expiry_seconds:
                        return result
                    else:
                        del cache[key]
                
                result = func(*args, **kwargs)
                cache[key] = (result, current_time)
                return result
        
        return wrapper
    return decorator

@timed_cache(expiry_seconds=5)
def get_current_time():
    return time.time()

print(get_current_time())  # Fresh call
time.sleep(2)
print(get_current_time())  # Cached result
time.sleep(4)
print(get_current_time())  # Fresh call (cache expired)
```

#### Retry Decorator

Using functools to create sophisticated retry mechanisms:

```python
import functools
import random
import time

def retry(max_attempts=3, delay=1, backoff=2):
    """Retry decorator with exponential backoff."""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            attempts = 0
            current_delay = delay
            
            while attempts < max_attempts:
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    attempts += 1
                    if attempts >= max_attempts:
                        raise e
                    
                    print(f"Attempt {attempts} failed: {e}. Retrying in {current_delay}s...")
                    time.sleep(current_delay)
                    current_delay *= backoff
            
        return wrapper
    return decorator

@retry(max_attempts=3, delay=0.5, backoff=2)
def unreliable_function():
    if random.random() < 0.7:  # 70% chance of failure
        raise Exception("Random failure")
    return "Success!"

try:
    result = unreliable_function()
    print(result)
except Exception as e:
    print(f"Final failure: {e}")
```

### Functional Programming Patterns

#### Composition and Chaining

Creating function composition utilities:

```python
import functools

def compose(*functions):
    """Compose multiple functions into one."""
    return functools.reduce(lambda f, g: lambda x: f(g(x)), functions, lambda x: x)

def pipe(value, *functions):
    """Apply functions in sequence to a value."""
    return functools.reduce(lambda acc, func: func(acc), functions, value)

# Example functions
def add_one(x):
    return x + 1

def multiply_by_two(x):
    return x * 2

def square(x):
    return x ** 2

# Function composition
composed = compose(square, multiply_by_two, add_one)
print(composed(3))  # square(multiply_by_two(add_one(3))) = square(8) = 64

# Pipeline approach
result = pipe(3, add_one, multiply_by_two, square)
print(result)  # Same result: 64

# More complex example
def format_number(x):
    return f"Result: {x}"

pipeline_result = pipe(
    5,
    lambda x: x * 2,
    lambda x: x + 10,
    lambda x: x ** 0.5,
    round,
    format_number
)
print(pipeline_result)  # "Result: 4"
```

#### Currying Implementation

Implementing currying using functools:

```python
import functools

def curry(func, arity=None):
    """Convert a function to its curried form."""
    if arity is None:
        arity = func.__code__.co_argcount
    
    def curried(*args, **kwargs):
        if len(args) + len(kwargs) >= arity:
            return func(*args, **kwargs)
        return lambda *more_args, **more_kwargs: curried(*(args + more_args), **{**kwargs, **more_kwargs})
    
    return curried

# Example usage
def add_three_numbers(a, b, c):
    return a + b + c

curried_add = curry(add_three_numbers)

# All these are equivalent:
print(add_three_numbers(1, 2, 3))  # 6
print(curried_add(1)(2)(3))        # 6
print(curried_add(1, 2)(3))        # 6
print(curried_add(1)(2, 3))        # 6

# Partial application through currying
add_five = curried_add(2)(3)  # Waiting for one more argument
print(add_five(4))  # 9
```

### Performance Optimization Techniques

#### Cache Optimization Strategies

Advanced caching techniques for different scenarios:

```python
import functools
import sys
import weakref
import threading

class AdvancedCache:
    """Custom cache with size limits and weak references."""
    
    def __init__(self, maxsize=128, typed=False):
        self.maxsize = maxsize
        self.typed = typed
        self.cache = {}
        self.access_order = []
        self.lock = threading.RLock()
        self.hits = 0
        self.misses = 0
    
    def __call__(self, func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            key = self._make_key(args, kwargs)
            
            with self.lock:
                if key in self.cache:
                    self.hits += 1
                    self._update_access(key)
                    return self.cache[key]
                
                self.misses += 1
                result = func(*args, **kwargs)
                
                if len(self.cache) >= self.maxsize:
                    self._evict_lru()
                
                self.cache[key] = result
                self.access_order.append(key)
                return result
        
        wrapper.cache_info = lambda: {
            'hits': self.hits,
            'misses': self.misses,
            'currsize': len(self.cache),
            'maxsize': self.maxsize
        }
        wrapper.cache_clear = self._clear
        return wrapper
    
    def _make_key(self, args, kwargs):
        key = args
        if kwargs:
            key += tuple(sorted(kwargs.items()))
        if self.typed:
            key += tuple(type(arg) for arg in args)
        return key
    
    def _update_access(self, key):
        self.access_order.remove(key)
        self.access_order.append(key)
    
    def _evict_lru(self):
        if self.access_order:
            lru_key = self.access_order.pop(0)
            del self.cache[lru_key]
    
    def _clear(self):
        with self.lock:
            self.cache.clear()
            self.access_order.clear()
            self.hits = 0
            self.misses = 0

@AdvancedCache(maxsize=50)
def expensive_function(n):
    return sum(i ** 2 for i in range(n))

# Usage
print(expensive_function(1000))
print(expensive_function.cache_info())
```

#### Memory-Efficient Caching

Implementing weak reference caching for memory-sensitive applications:

```python
import functools
import weakref
import gc

def weak_lru_cache(maxsize=128):
    """LRU cache that doesn't prevent garbage collection of results."""
    def decorator(func):
        cache = {}
        access_order = []
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            key = str(args) + str(sorted(kwargs.items()))
            
            # Clean up dead weak references
            dead_keys = [k for k, ref in cache.items() if ref() is None]
            for dead_key in dead_keys:
                del cache[dead_key]
                if dead_key in access_order:
                    access_order.remove(dead_key)
            
            if key in cache:
                result = cache[key]()
                if result is not None:
                    # Move to end (most recently used)
                    access_order.remove(key)
                    access_order.append(key)
                    return result
                else:
                    del cache[key]
            
            # Compute new result
            result = func(*args, **kwargs)
            
            # Evict LRU if at capacity
            while len(cache) >= maxsize and access_order:
                lru_key = access_order.pop(0)
                cache.pop(lru_key, None)
            
            # Store weak reference
            try:
                cache[key] = weakref.ref(result)
                access_order.append(key)
            except TypeError:
                # Can't create weak reference to this type
                pass
            
            return result
        
        return wrapper
    return decorator

class ExpensiveObject:
    def __init__(self, data):
        self.data = data
        self.processed = [x ** 2 for x in data]

@weak_lru_cache(maxsize=10)
def create_expensive_object(size):
    return ExpensiveObject(list(range(size)))

# Usage
obj1 = create_expensive_object(1000)
obj2 = create_expensive_object(1000)  # Same object from cache
print(obj1 is obj2)  # True

del obj1, obj2  # Objects can be garbage collected
gc.collect()
obj3 = create_expensive_object(1000)  # New object (old one was collected)
```

### Integration with Async Programming

#### Async Function Utilities

Extending functools concepts to asynchronous programming:

```python
import functools
import asyncio
import time

def async_lru_cache(maxsize=128):
    """LRU cache for async functions."""
    def decorator(func):
        cache = {}
        access_order = []
        
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            key = str(args) + str(sorted(kwargs.items()))
            
            if key in cache:
                # Move to end (most recently used)
                access_order.remove(key)
                access_order.append(key)
                return cache[key]
            
            # Evict LRU if at capacity
            if len(cache) >= maxsize and access_order:
                lru_key = access_order.pop(0)
                del cache[lru_key]
            
            # Compute new result
            result = await func(*args, **kwargs)
            cache[key] = result
            access_order.append(key)
            return result
        
        wrapper.cache_clear = lambda: cache.clear() or access_order.clear()
        return wrapper
    return decorator

@async_lru_cache(maxsize=50)
async def async_expensive_operation(n):
    await asyncio.sleep(0.1)  # Simulate async I/O
    return sum(i ** 2 for i in range(n))

async def main():
    start = time.time()
    
    # First calls (cache misses)
    results = await asyncio.gather(
        async_expensive_operation(100),
        async_expensive_operation(200),
        async_expensive_operation(100),  # Cache hit
    )
    
    end = time.time()
    print(f"Results: {results}")
    print(f"Time taken: {end - start:.2f}s")

# Run the async example
# asyncio.run(main())
```

#### Async Retry Decorator

```python
import functools
import asyncio
import random

def async_retry(max_attempts=3, delay=1, backoff=2):
    """Async retry decorator with exponential backoff."""
    def decorator(func):
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            attempts = 0
            current_delay = delay
            
            while attempts < max_attempts:
                try:
                    return await func(*args, **kwargs)
                except Exception as e:
                    attempts += 1
                    if attempts >= max_attempts:
                        raise e
                    
                    print(f"Attempt {attempts} failed: {e}. Retrying in {current_delay}s...")
                    await asyncio.sleep(current_delay)
                    current_delay *= backoff
            
        return wrapper
    return decorator

@async_retry(max_attempts=3, delay=0.5, backoff=2)
async def unreliable_async_function():
    await asyncio.sleep(0.1)
    if random.random() < 0.7:  # 70% chance of failure
        raise Exception("Random async failure")
    return "Async success!"
```

### Testing and Debugging Utilities

#### Function Introspection and Testing

Tools for analyzing and testing functions enhanced with functools:

```python
import functools
import inspect
import time

def debug_calls(func):
    """Decorator that logs function calls and performance."""
    call_count = 0
    total_time = 0
    
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        nonlocal call_count, total_time
        call_count += 1
        
        start_time = time.time()
        try:
            result = func(*args, **kwargs)
            success = True
            error = None
        except Exception as e:
            result = None
            success = False
            error = e
        finally:
            end_time = time.time()
            duration = end_time - start_time
            total_time += duration
        
        print(f"Call #{call_count} to {func.__name__}")
        print(f"  Args: {args}, Kwargs: {kwargs}")
        print(f"  Duration: {duration:.4f}s")
        print(f"  Success: {success}")
        if not success:
            print(f"  Error: {error}")
        print(f"  Average time: {total_time/call_count:.4f}s")
        print("-" * 40)
        
        if not success:
            raise error
        return result
    
    wrapper.call_count = lambda: call_count
    wrapper.total_time = lambda: total_time
    wrapper.average_time = lambda: total_time / call_count if call_count > 0 else 0
    
    return wrapper

@debug_calls
@functools.lru_cache(maxsize=32)
def fibonacci_debug(n):
    if n < 2:
        return n
    return fibonacci_debug(n-1) + fibonacci_debug(n-2)

# Usage
result = fibonacci_debug(10)
print(f"Final result: {result}")
print(f"Cache info: {fibonacci_debug.cache_info()}")
```

#### Mock and Test Utilities

Using functools for testing scenarios:

```python
import functools
from unittest.mock import MagicMock

def mock_with_cache(func):
    """Create a mock that respects caching behavior."""
    original_func = func
    mock = MagicMock()
    
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        # Check if original function is cached
        if hasattr(original_func, 'cache_info'):
            cache_info = original_func.cache_info()
            mock.cache_hits = cache_info.hits
            mock.cache_misses = cache_info.misses
            mock.cache_size = cache_info.currsize
        
        result = original_func(*args, **kwargs)
        mock(*args, **kwargs)  # Record the call
        return result
    
    wrapper.mock = mock
    return wrapper

@functools.lru_cache(maxsize=10)
def expensive_computation(x, y):
    return x ** y

# Wrap with mock
mocked_computation = mock_with_cache(expensive_computation)

# Use the function
result1 = mocked_computation(2, 10)
result2 = mocked_computation(2, 10)  # Cache hit

# Check mock statistics
print(f"Function called {mocked_computation.mock.call_count} times")
print(f"Cache hits: {mocked_computation.mock.cache_hits}")
print(f"Cache misses: {mocked_computation.mock.cache_misses}")
```

### Real-World Applications

#### Web Framework Utilities

Common patterns in web development using functools:

```python
import functools
import time
from typing import Dict, Any

def rate_limit(calls_per_minute=60):
    """Rate limiting decorator for API endpoints."""
    def decorator(func):
        call_times = {}
        
        @functools.wraps(func)
        def wrapper(user_id, *args, **kwargs):
            current_time = time.time()
            minute_ago = current_time - 60
            
            # Clean old entries
            if user_id in call_times:
                call_times[user_id] = [t for t in call_times[user_id] if t > minute_ago]
            else:
                call_times[user_id] = []
            
            # Check rate limit
            if len(call_times[user_id]) >= calls_per_minute:
                raise Exception(f"Rate limit exceeded for user {user_id}")
            
            # Record this call
            call_times[user_id].append(current_time)
            
            return func(user_id, *args, **kwargs)
        
        return wrapper
    return decorator

@rate_limit(calls_per_minute=10)
def api_endpoint(user_id: str, data: Dict[str, Any]):
    return f"Processing data for user {user_id}: {data}"

# Usage
try:
    for i in range(15):  # Exceed rate limit
        result = api_endpoint("user123", {"request": i})
        print(result)
except Exception as e:
    print(f"Rate limit error: {e}")
```

#### Data Processing Pipelines

Using functools for data transformation pipelines:

```python
import functools
from typing import List, Callable, Any

def pipeline(*transforms: Callable) -> Callable:
    """Create a data processing pipeline."""
    return functools.reduce(lambda f, g: lambda x: g(f(x)), transforms)

def batch_process(batch_size: int = 100):
    """Process data in batches."""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(data: List[Any]) -> List[Any]:
            results = []
            for i in range(0, len(data), batch_size):
                batch = data[i:i + batch_size]
                batch_results = func(batch)
                results.extend(batch_results)
            return results
        return wrapper
    return decorator

# Data transformation functions
def clean_data(items: List[str]) -> List[str]:
    return [item.strip().lower() for item in items if item.strip()]

def validate_data(items: List[str]) -> List[str]:
    return [item for item in items if len(item) > 2]

def enrich_data(items: List[str]) -> List[Dict[str, Any]]:
    return [{"value": item, "length": len(item), "processed_at": time.time()} for item in items]

@batch_process(batch_size=50)
def process_batch(batch: List[str]) -> List[Dict[str, Any]]:
    return pipeline(clean_data, validate_data, enrich_data)(batch)

# Usage
raw_data = ["  Hello  ", "Hi", "A", "World", "Python", "  ", "Code"]
processed_data = process_batch(raw_data)
print(processed_data)
```

### Best Practices and Common Pitfalls

#### Cache Key Design

Proper cache key generation for complex data types:

```python
import functools
import json
import hashlib

def smart_cache(maxsize=128):
    """Cache with intelligent key generation."""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # Create a stable key for complex objects
            key_data = {
                'args': [_serialize_arg(arg) for arg in args],
                'kwargs': {k: _serialize_arg(v) for k, v in kwargs.items()}
            }
            key = hashlib.md5(json.dumps(key_data, sort_keys=True).encode()).hexdigest()
            return key
        
        def _serialize_arg(arg):
            if hasattr(arg, '__dict__'):
                return {'__type__': type(arg).__name__, '__dict__': arg.__dict__}
            elif isinstance(arg, (list, tuple, set)):
                return [_serialize_arg(item) for item in arg]
            elif isinstance(arg, dict):
                return {k: _serialize_arg(v) for k, v in arg.items()}
            else:
                return arg
        
        # Apply lru_cache with the custom key function
        cached_func = functools.lru_cache(maxsize=maxsize)(func)
        
        @functools.wraps(func)
        def final_wrapper(*args, **kwargs):
            return cached_func(*args, **kwargs)
        
        return final_wrapper
    return decorator

class DataObject:
    def __init__(self, name, value):
        self.name = name
        self.value = value

@smart_cache(maxsize=50)
def process_complex_data(obj: DataObject, multiplier: int = 1):
    return obj.value * multiplier

# Usage
obj1 = DataObject("test", 10)
obj2 = DataObject("test", 10)  # Same content, different instance

result1 = process_complex_data(obj1, 2)
result2 = process_complex_data(obj2, 2)  # Should use cache
```

#### Thread Safety Considerations

Ensuring thread-safe operations with functools utilities:

```python
import functools
import threading
import time
import random

def thread_safe_cache(maxsize=128):
    """Thread-safe cache implementation."""
    def decorator(func):
        cache = {}
        access_order = []
        lock = threading.RLock()
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            key = str(args) + str(kwargs)
            
            with lock:
                if key in cache:
                    # Move to end (most recently used)
                    access_order.remove(key)
                    access_order.append(key)
                    return cache[key]
                
                # Evict LRU if at capacity
                if len(cache) >= maxsize and access_order:
                    lru_key = access_order.pop(0)
                    del cache[lru_key]
            
            # Compute result outside of lock to allow concurrent computation
            result = func(*args, **kwargs)
            
            with lock:
                cache[key] = result
                access_order.append(key)
                return result
        
        wrapper.cache_clear = lambda: _clear_cache(cache, access_order, lock)
        wrapper.cache_info = lambda: _get_cache_info(cache, lock)
        return wrapper
    
    def _clear_cache(cache, access_order, lock):
        with lock:
            cache.clear()
            access_order.clear()
    
    def _get_cache_info(cache, lock):
        with lock:
            return {'size': len(cache), 'maxsize': maxsize}
    
    return decorator

@thread_safe_cache(maxsize=20)
def thread_safe_computation(n):
    time.sleep(0.1)  # Simulate work
    return n ** 2

def worker_thread(thread_id):
    for i in range(10):
        value = random.randint(1, 5)
        result = thread_safe_computation(value)
        print(f"Thread {thread_id}: f({value}) = {result}")

# Test with multiple threads
threads = []
for i in range(3):
    thread = threading.Thread(target=worker_thread, args=(i,))
    threads.append(thread)
    thread.start()

for thread in threads:
    thread.join()

print(f"Cache info: {thread_safe_computation.cache_info()}")
```

### Error Handling and Robustness

#### Graceful Degradation

Implementing fallback mechanisms for cached functions:

```python
import functools
import logging
import pickle
import os

def persistent_cache(cache_file="function_cache.pkl", fallback_on_error=True):
    """Cache that persists to disk and gracefully handles errors."""
    def decorator(func):
        cache = {}
        
        # Load cache from disk
        if os.path.exists(cache_file):
            try:
                with open(cache_file, 'rb') as f:
                    cache = pickle.load(f)
                logging.info(f"Loaded {len(cache)} items from cache file")
            except Exception as e:
                logging.warning(f"Failed to load cache: {e}")
                cache = {}
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            key = str(args) + str(kwargs)
            
            # Try to get from cache
            if key in cache:
                try:
                    return cache[key]
                except Exception as e:
                    logging.warning(f"Cache retrieval error: {e}")
                    if not fallback_on_error:
                        raise
                    # Continue to compute fresh result
            
            # Compute result
            try:
                result = func(*args, **kwargs)
                cache[key] = result
                
                # Persist to disk
                try:
                    with open(cache_file, 'wb') as f:
                        pickle.dump(cache, f)
                except Exception as e:
                    logging.warning(f"Failed to persist cache: {e}")
                
                return result
            except Exception as e:
                logging.error(f"Function execution error: {e}")
                if not fallback_on_error:
                    raise
                
                # Return cached result if available, even if stale
                if key in cache:
                    logging.info("Returning stale cached result due to execution error")
                    return cache[key]
                raise
        
        wrapper.cache_clear = lambda: _clear_persistent_cache(cache, cache_file)
        return wrapper
    
    def _clear_persistent_cache(cache, cache_file):
        cache.clear()
        try:
            if os.path.exists(cache_file):
                os.remove(cache_file)
        except Exception as e:
            logging.warning(f"Failed to remove cache file: {e}")
    
    return decorator

@persistent_cache("computation_cache.pkl")
def expensive_computation_with_fallback(x, y):
    if x == 0:  # Simulate occasional errors
        raise ValueError("Cannot compute with x=0")
    return x ** y + y ** x

# Usage with error handling
for x in [1, 2, 0, 3, 0]:  # Include error cases
    try:
        result = expensive_computation_with_fallback(x, 2)
        print(f"f({x}, 2) = {result}")
    except Exception as e:
        print(f"Error computing f({x}, 2): {e}")
```

#### Input Validation and Sanitization

Combining functools with input validation:

```python
import functools
from typing import Union, List, Any
import inspect

def validate_types(**type_hints):
    """Decorator that validates function argument types."""
    def decorator(func):
        sig = inspect.signature(func)
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # Bind arguments to parameters
            bound_args = sig.bind(*args, **kwargs)
            bound_args.apply_defaults()
            
            # Validate types
            for param_name, value in bound_args.arguments.items():
                if param_name in type_hints:
                    expected_type = type_hints[param_name]
                    if not isinstance(value, expected_type):
                        raise TypeError(
                            f"Parameter '{param_name}' must be {expected_type.__name__}, "
                            f"got {type(value).__name__}"
                        )
            
            return func(*args, **kwargs)
        
        return wrapper
    return decorator

def sanitize_inputs(sanitizers: dict):
    """Decorator that sanitizes function inputs."""
    def decorator(func):
        sig = inspect.signature(func)
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            bound_args = sig.bind(*args, **kwargs)
            bound_args.apply_defaults()
            
            # Apply sanitizers
            for param_name, value in bound_args.arguments.items():
                if param_name in sanitizers:
                    sanitizer = sanitizers[param_name]
                    bound_args.arguments[param_name] = sanitizer(value)
            
            return func(*bound_args.args, **bound_args.kwargs)
        
        return wrapper
    return decorator

# Sanitizer functions
def sanitize_string(s):
    if not isinstance(s, str):
        s = str(s)
    return s.strip().lower()

def sanitize_positive_int(n):
    return max(1, int(abs(n)))

@validate_types(name=str, age=int, scores=list)
@sanitize_inputs({
    'name': sanitize_string,
    'age': sanitize_positive_int
})
@functools.lru_cache(maxsize=100)
def process_student_data(name: str, age: int, scores: List[float]):
    avg_score = sum(scores) / len(scores) if scores else 0
    return {
        'name': name,
        'age': age,
        'average_score': avg_score,
        'grade': 'A' if avg_score >= 90 else 'B' if avg_score >= 80 else 'C'
    }

# Usage
try:
    result1 = process_student_data("  ALICE  ", -25, [85.5, 92.0, 88.5])
    print(result1)  # name sanitized to "alice", age to 25
    
    result2 = process_student_data("  alice  ", 25, [85.5, 92.0, 88.5])
    print("Cache hit:", result1 == result2)  # Should be cache hit due to sanitization
    
    # This will raise TypeError
    process_student_data(123, "not_an_int", [85.5])
except TypeError as e:
    print(f"Validation error: {e}")
```

### Advanced Memory Management

#### Weak Reference Caching for Large Objects

Managing memory efficiently with large cached objects:

```python
import functools
import weakref
import gc
from typing import Optional, Dict, Any

class WeakValueCache:
    """Cache that holds weak references to values to prevent memory leaks."""
    
    def __init__(self, maxsize: int = 128):
        self.maxsize = maxsize
        self.cache: Dict[Any, weakref.ref] = {}
        self.access_order = []
        self.hits = 0
        self.misses = 0
    
    def get(self, key):
        if key in self.cache:
            ref = self.cache[key]
            value = ref()
            if value is not None:
                self.hits += 1
                # Update access order
                self.access_order.remove(key)
                self.access_order.append(key)
                return value
            else:
                # Dead reference, clean up
                del self.cache[key]
                if key in self.access_order:
                    self.access_order.remove(key)
        
        self.misses += 1
        return None
    
    def set(self, key, value):
        # Clean up dead references
        self._cleanup_dead_refs()
        
        # Evict LRU if at capacity
        while len(self.cache) >= self.maxsize and self.access_order:
            lru_key = self.access_order.pop(0)
            self.cache.pop(lru_key, None)
        
        try:
            def cleanup_callback(ref):
                # Remove from cache when object is garbage collected
                if key in self.cache and self.cache[key] is ref:
                    del self.cache[key]
                    if key in self.access_order:
                        self.access_order.remove(key)
            
            self.cache[key] = weakref.ref(value, cleanup_callback)
            self.access_order.append(key)
        except TypeError:
            # Cannot create weak reference to this type
            pass
    
    def _cleanup_dead_refs(self):
        dead_keys = []
        for key, ref in self.cache.items():
            if ref() is None:
                dead_keys.append(key)
        
        for key in dead_keys:
            del self.cache[key]
            if key in self.access_order:
                self.access_order.remove(key)
    
    def cache_info(self):
        self._cleanup_dead_refs()
        return {
            'hits': self.hits,
            'misses': self.misses,
            'currsize': len(self.cache),
            'maxsize': self.maxsize
        }
    
    def clear(self):
        self.cache.clear()
        self.access_order.clear()
        self.hits = 0
        self.misses = 0

def weak_cache(maxsize=128):
    """Decorator using weak reference cache."""
    def decorator(func):
        cache = WeakValueCache(maxsize)
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            key = str(args) + str(kwargs)
            
            # Try cache first
            result = cache.get(key)
            if result is not None:
                return result
            
            # Compute and cache
            result = func(*args, **kwargs)
            cache.set(key, result)
            return result
        
        wrapper.cache_info = cache.cache_info
        wrapper.cache_clear = cache.clear
        return wrapper
    
    return decorator

class LargeDataObject:
    """Simulate a large object that should be eligible for garbage collection."""
    def __init__(self, size):
        self.data = list(range(size))  # Large list
        self.size = size
    
    def __repr__(self):
        return f"LargeDataObject(size={self.size})"

@weak_cache(maxsize=5)
def create_large_object(size):
    print(f"Creating large object of size {size}")
    return LargeDataObject(size)

# Usage demonstration
obj1 = create_large_object(1000)
obj2 = create_large_object(1000)  # Cache hit
print(f"Same object: {obj1 is obj2}")

# Force garbage collection
del obj1, obj2
gc.collect()

# Next call should create new object (old one was collected)
obj3 = create_large_object(1000)
print(f"Cache info: {create_large_object.cache_info()}")
```

### Functional Programming Advanced Patterns

#### Monadic Error Handling

Implementing functional error handling patterns:

```python
import functools
from typing import Union, Callable, Any, TypeVar

T = TypeVar('T')
U = TypeVar('U')

class Result:
    """Monadic result type for error handling."""
    
    def __init__(self, value=None, error=None):
        self.value = value
        self.error = error
        self.is_success = error is None
    
    def bind(self, func: Callable[[T], 'Result[U]']) -> 'Result[U]':
        """Monadic bind operation."""
        if not self.is_success:
            return Result(error=self.error)
        try:
            return func(self.value)
        except Exception as e:
            return Result(error=str(e))
    
    def map(self, func: Callable[[T], U]) -> 'Result[U]':
        """Map operation for successful results."""
        if not self.is_success:
            return Result(error=self.error)
        try:
            return Result(value=func(self.value))
        except Exception as e:
            return Result(error=str(e))
    
    def get_or_else(self, default):
        """Get value or return default if error."""
        return self.value if self.is_success else default
    
    def __repr__(self):
        if self.is_success:
            return f"Success({self.value})"
        return f"Error({self.error})"

def safe_function(func):
    """Decorator that wraps function to return Result."""
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        try:
            result = func(*args, **kwargs)
            return Result(value=result)
        except Exception as e:
            return Result(error=str(e))
    return wrapper

@safe_function
def divide(a, b):
    if b == 0:
        raise ValueError("Division by zero")
    return a / b

@safe_function
def square_root(x):
    if x < 0:
        raise ValueError("Cannot take square root of negative number")
    return x ** 0.5

# Monadic composition
def safe_computation(a, b):
    return (divide(a, b)
            .bind(lambda x: Result(value=x * 2))
            .bind(lambda x: square_root(x)))

# Usage
result1 = safe_computation(8, 2)  # Success: sqrt((8/2)*2) = sqrt(8) ≈ 2.83
result2 = safe_computation(8, 0)  # Error: division by zero
result3 = safe_computation(-8, 2) # Error: negative square root

print(result1)  # Success(2.8284271247461903)
print(result2)  # Error(Division by zero)
print(result3)  # Error(Cannot take square root of negative number)

# Safe value extraction
safe_value = result1.get_or_else(0)
print(f"Safe value: {safe_value}")
```

#### Lazy Evaluation and Generators

Combining functools with lazy evaluation:

```python
import functools
from typing import Iterator, Callable, Any

class LazySequence:
    """Lazy sequence with functional operations."""
    
    def __init__(self, generator_func):
        self.generator_func = generator_func
    
    def map(self, func):
        def new_generator():
            for item in self.generator_func():
                yield func(item)
        return LazySequence(new_generator)
    
    def filter(self, predicate):
        def new_generator():
            for item in self.generator_func():
                if predicate(item):
                    yield item
        return LazySequence(new_generator)
    
    def take(self, n):
        def new_generator():
            count = 0
            for item in self.generator_func():
                if count >= n:
                    break
                yield item
                count += 1
        return LazySequence(new_generator)
    
    def reduce(self, func, initial=None):
        iterator = iter(self.generator_func())
        if initial is None:
            value = next(iterator)
        else:
            value = initial
        
        for item in iterator:
            value = func(value, item)
        return value
    
    def to_list(self):
        return list(self.generator_func())
    
    def __iter__(self):
        return iter(self.generator_func())

def lazy_range(start, stop=None, step=1):
    """Create a lazy range sequence."""
    if stop is None:
        stop = start
        start = 0
    
    def generator():
        current = start
        while current < stop:
            yield current
            current += step
    
    return LazySequence(generator)

def memoize_generator(func):
    """Memoize a generator function."""
    cache = {}
    
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        key = str(args) + str(kwargs)
        if key not in cache:
            cache[key] = list(func(*args, **kwargs))
        return iter(cache[key])
    
    return wrapper

@memoize_generator
def fibonacci_sequence(limit):
    """Generate Fibonacci sequence up to limit."""
    a, b = 0, 1
    while a < limit:
        yield a
        a, b = b, a + b

# Usage examples
# Lazy sequence operations
lazy_nums = lazy_range(1, 1000000)  # Million numbers, not computed yet
result = (lazy_nums
          .filter(lambda x: x % 2 == 0)    # Even numbers
          .map(lambda x: x ** 2)           # Square them
          .take(10)                        # First 10
          .to_list())                      # Materialize

print("First 10 squares of even numbers:", result)

# Memoized generator
fib1 = list(fibonacci_sequence(100))  # Computed and cached
fib2 = list(fibonacci_sequence(100))  # Retrieved from cache
print("Fibonacci numbers < 100:", fib1)
print("Same result:", fib1 == fib2)

# Functional composition with lazy evaluation
def compose_lazy(*functions):
    """Compose functions to work with lazy sequences."""
    def composed(lazy_seq):
        return functools.reduce(lambda seq, func: func(seq), functions, lazy_seq)
    return composed

# Create a processing pipeline
pipeline = compose_lazy(
    lambda seq: seq.filter(lambda x: x > 10),
    lambda seq: seq.map(lambda x: x * 3),
    lambda seq: seq.take(5)
)

processed = pipeline(lazy_range(1, 100))
print("Pipeline result:", processed.to_list())
```

### Integration with Modern Python Features

#### Type Hints and Generic Functions

Advanced type-safe functional programming:

```python
import functools
from typing import TypeVar, Generic, List, Dict, Callable, Optional, Union
from dataclasses import dataclass

T = TypeVar('T')
U = TypeVar('U')
V = TypeVar('V')

@dataclass
class Person:
    name: str
    age: int
    email: str

class TypedCache(Generic[T]):
    """Type-safe cache implementation."""
    
    def __init__(self, maxsize: int = 128):
        self.cache: Dict[str, T] = {}
        self.maxsize = maxsize
        self.access_order: List[str] = []
    
    def get(self, key: str) -> Optional[T]:
        if key in self.cache:
            self.access_order.remove(key)
            self.access_order.append(key)
            return self.cache[key]
        return None
    
    def set(self, key: str, value: T) -> None:
        if len(self.cache) >= self.maxsize and self.access_order:
            lru_key = self.access_order.pop(0)
            del self.cache[lru_key]
        
        self.cache[key] = value
        self.access_order.append(key)

def typed_lru_cache(maxsize: int = 128) -> Callable[[Callable[..., T]], Callable[..., T]]:
    """Type-safe LRU cache decorator."""
    def decorator(func: Callable[..., T]) -> Callable[..., T]:
        cache: TypedCache[T] = TypedCache(maxsize)
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs) -> T:
            key = str(args) + str(kwargs)
            
            result = cache.get(key)
            if result is not None:
                return result
            
            result = func(*args, **kwargs)
            cache.set(key, result)
            return result
        
        return wrapper
    return decorator

@typed_lru_cache(maxsize=50)
def get_person_info(person_id: int) -> Person:
    # Simulate database lookup
    return Person(
        name=f"Person_{person_id}",
        age=25 + (person_id % 50),
        email=f"person{person_id}@example.com"
    )

@typed_lru_cache(maxsize=100)
def compute_statistics(numbers: List[float]) -> Dict[str, float]:
    return {
        'mean': sum(numbers) / len(numbers),
        'max': max(numbers),
        'min': min(numbers),
        'std': (sum((x - sum(numbers)/len(numbers))**2 for x in numbers) / len(numbers))**0.5
    }

# Usage with full type safety
person: Person = get_person_info(123)
stats: Dict[str, float] = compute_statistics([1.0, 2.0, 3.0, 4.0, 5.0])

print(f"Person: {person}")
print(f"Statistics: {stats}")
```

**Key points**: The functools module provides essential tools for functional programming in Python, including caching with lru_cache, partial application, function composition with reduce, generic function dispatch with singledispatch, and proper decorator creation with wraps. It enables performance optimization through memoization, code reuse through partial functions, and elegant function transformation patterns. Master these utilities for writing more efficient, maintainable, and functionally-oriented Python code.

Important related topics include understanding decorator patterns, performance profiling for cache optimization, thread safety in concurrent applications, memory management with weak references, and integration with modern Python type hints for better code safety and documentation.

---

## `collections` Module

### Overview

The `collections` module provides specialized container datatypes that extend Python's built-in containers (dict, list, set, tuple). These containers offer additional functionality, better performance for specific use cases, and more convenient APIs for common patterns. The module includes both concrete implementations and abstract base classes for creating custom containers.

### Counter

A `Counter` is a dict subclass for counting hashable objects, essentially a multiset or bag implementation.

#### Basic Usage

```python
from collections import Counter

# Creating counters
c1 = Counter(['a', 'b', 'c', 'a', 'b', 'b'])
print(c1)  # Counter({'b': 3, 'a': 2, 'c': 1})

c2 = Counter({'red': 4, 'blue': 2})
print(c2)  # Counter({'red': 4, 'blue': 2})

c3 = Counter(cats=4, dogs=2)
print(c3)  # Counter({'cats': 4, 'dogs': 2})

# From string
c4 = Counter('hello world')
print(c4)  # Counter({'l': 3, 'o': 2, 'h': 1, 'e': 1, ' ': 1, 'w': 1, 'r': 1, 'd': 1})
```

#### Counter Methods

```python
c = Counter('abracadabra')

# Most common elements
print(c.most_common())     # [('a', 5), ('b', 2), ('r', 2), ('c', 1), ('d', 1)]
print(c.most_common(3))    # [('a', 5), ('b', 2), ('r', 2)]

# Elements (returns iterator over elements)
print(list(c.elements()))  # ['a', 'a', 'a', 'a', 'a', 'b', 'b', 'r', 'r', 'c', 'd']

# Update and subtract
c.update('aabbcc')
print(c)  # Counter({'a': 7, 'b': 4, 'c': 2, 'r': 2, 'd': 1})

c.subtract('abc')
print(c)  # Counter({'a': 6, 'b': 3, 'r': 2, 'c': 1, 'd': 1})

# Total count
print(c.total())  # 13 (sum of all counts)
```

#### Counter Arithmetic

```python
c1 = Counter(['a', 'b', 'c', 'a', 'b', 'b'])
c2 = Counter(['a', 'b', 'b', 'd'])

# Addition (combine counts)
print(c1 + c2)  # Counter({'b': 5, 'a': 3, 'c': 1, 'd': 1})

# Subtraction (subtract counts, keep positive)
print(c1 - c2)  # Counter({'b': 1, 'c': 1})

# Intersection (minimum counts)
print(c1 & c2)  # Counter({'a': 1, 'b': 2})

# Union (maximum counts)
print(c1 | c2)  # Counter({'b': 3, 'a': 2, 'c': 1, 'd': 1})
```

#### Practical Examples

```python
# Word frequency analysis
text = "the quick brown fox jumps over the lazy dog the fox"
word_freq = Counter(text.split())
print(word_freq.most_common(3))  # [('the', 2), ('fox', 2), ('quick', 1)]

# Character frequency in DNA sequence
dna = "ATCGATCGATCG"
nucleotide_count = Counter(dna)
gc_content = (nucleotide_count['G'] + nucleotide_count['C']) / len(dna)
print(f"GC Content: {gc_content:.2%}")

# Inventory management
inventory = Counter(apples=10, oranges=5, bananas=3)
sold = Counter(apples=3, oranges=2, bananas=1)
remaining = inventory - sold
print(f"Remaining inventory: {remaining}")
```

### defaultdict

A `defaultdict` is a dict subclass that calls a factory function to supply missing values.

#### Basic Usage

```python
from collections import defaultdict

# With list as default factory
dd_list = defaultdict(list)
dd_list['key1'].append('value1')
dd_list['key2'].append('value2')
print(dict(dd_list))  # {'key1': ['value1'], 'key2': ['value2']}

# With int as default factory (useful for counting)
dd_int = defaultdict(int)
for char in 'hello':
    dd_int[char] += 1
print(dict(dd_int))  # {'h': 1, 'e': 1, 'l': 2, 'o': 1}

# With set as default factory
dd_set = defaultdict(set)
dd_set['fruits'].add('apple')
dd_set['fruits'].add('banana')
print(dict(dd_set))  # {'fruits': {'apple', 'banana'}}
```

#### Custom Default Factories

```python
# Custom factory function
def default_value():
    return "N/A"

dd_custom = defaultdict(default_value)
print(dd_custom['missing_key'])  # "N/A"

# Lambda factory
dd_lambda = defaultdict(lambda: [0, 0])
dd_lambda['coordinates'][0] = 10
dd_lambda['coordinates'][1] = 20
print(dict(dd_lambda))  # {'coordinates': [10, 20]}

# Nested defaultdict
nested_dd = defaultdict(lambda: defaultdict(int))
nested_dd['user1']['score'] += 10
nested_dd['user1']['attempts'] += 1
nested_dd['user2']['score'] += 20
print(dict(nested_dd))  # {'user1': defaultdict(<class 'int'>, {'score': 10, 'attempts': 1}), 'user2': defaultdict(<class 'int'>, {'score': 20})}
```

#### Practical Examples

```python
# Group items by category
from collections import defaultdict

items = [
    ('apple', 'fruit'),
    ('carrot', 'vegetable'),
    ('banana', 'fruit'),
    ('broccoli', 'vegetable'),
    ('orange', 'fruit')
]

grouped = defaultdict(list)
for item, category in items:
    grouped[category].append(item)

print(dict(grouped))  # {'fruit': ['apple', 'banana', 'orange'], 'vegetable': ['carrot', 'broccoli']}

# Build adjacency list for graph
edges = [('A', 'B'), ('A', 'C'), ('B', 'D'), ('C', 'D')]
graph = defaultdict(set)
for src, dest in edges:
    graph[src].add(dest)
    graph[dest].add(src)  # Undirected graph

# Track student grades by subject
grades = [
    ('Alice', 'Math', 95),
    ('Bob', 'Math', 87),
    ('Alice', 'Science', 92),
    ('Bob', 'Science', 89)
]

student_grades = defaultdict(lambda: defaultdict(list))
for student, subject, grade in grades:
    student_grades[student][subject].append(grade)
```

### deque

A `deque` (double-ended queue) provides O(1) appends and pops from both ends, unlike lists which have O(n) operations for the beginning.

#### Basic Operations

```python
from collections import deque

# Creating deques
d1 = deque([1, 2, 3, 4, 5])
d2 = deque('hello')
d3 = deque(maxlen=3)  # Bounded deque

print(d1)  # deque([1, 2, 3, 4, 5])
print(d2)  # deque(['h', 'e', 'l', 'l', 'o'])
```

#### Deque Methods

```python
d = deque([1, 2, 3])

# Append operations
d.append(4)           # Add to right
d.appendleft(0)       # Add to left
print(d)              # deque([0, 1, 2, 3, 4])

# Pop operations
right = d.pop()       # Remove from right
left = d.popleft()    # Remove from left
print(f"Removed: {left}, {right}")  # Removed: 0, 4
print(d)              # deque([1, 2, 3])

# Extend operations
d.extend([4, 5])      # Extend right
d.extendleft([0, -1]) # Extend left (note: order reversed)
print(d)              # deque([-1, 0, 1, 2, 3, 4, 5])

# Rotation
d.rotate(2)           # Rotate right by 2
print(d)              # deque([4, 5, -1, 0, 1, 2, 3])

d.rotate(-3)          # Rotate left by 3
print(d)              # deque([0, 1, 2, 3, 4, 5, -1])
```

#### Bounded Deques

```python
# Fixed-size deque (LRU-like behavior)
recent_items = deque(maxlen=3)
for i in range(6):
    recent_items.append(i)
    print(f"Added {i}: {recent_items}")

# Output:
# Added 0: deque([0], maxlen=3)
# Added 1: deque([0, 1], maxlen=3)
# Added 2: deque([0, 1, 2], maxlen=3)
# Added 3: deque([1, 2, 3], maxlen=3)  # 0 was removed
# Added 4: deque([2, 3, 4], maxlen=3)  # 1 was removed
# Added 5: deque([3, 4, 5], maxlen=3)  # 2 was removed
```

#### Practical Examples

```python
# Sliding window maximum
def sliding_window_maximum(arr, k):
    from collections import deque
    dq = deque()
    result = []
    
    for i in range(len(arr)):
        # Remove elements outside window
        while dq and dq[0] <= i - k:
            dq.popleft()
        
        # Remove smaller elements from rear
        while dq and arr[dq[-1]] <= arr[i]:
            dq.pop()
        
        dq.append(i)
        
        # Add to result if window is complete
        if i >= k - 1:
            result.append(arr[dq[0]])
    
    return result

# Palindrome checker
def is_palindrome(s):
    d = deque(s.lower())
    while len(d) > 1:
        if d.popleft() != d.pop():
            return False
    return True

print(is_palindrome("racecar"))  # True
print(is_palindrome("hello"))    # False

# Breadth-first search
def bfs(graph, start):
    visited = set()
    queue = deque([start])
    result = []
    
    while queue:
        vertex = queue.popleft()
        if vertex not in visited:
            visited.add(vertex)
            result.append(vertex)
            queue.extend(neighbor for neighbor in graph[vertex] 
                        if neighbor not in visited)
    
    return result
```

### OrderedDict

An `OrderedDict` is a dict subclass that remembers insertion order. [Inference] While regular dicts in Python 3.7+ maintain insertion order, OrderedDict provides additional ordering-related methods and guarantees order preservation across all Python versions.

#### Basic Usage

```python
from collections import OrderedDict

# Regular dict vs OrderedDict
regular_dict = {'a': 1, 'b': 2, 'c': 3}
ordered_dict = OrderedDict([('a', 1), ('b', 2), ('c', 3)])

print(regular_dict)  # {'a': 1, 'b': 2, 'c': 3}
print(ordered_dict)  # OrderedDict([('a', 1), ('b', 2), ('c', 3)])
```

#### OrderedDict Methods

```python
od = OrderedDict([('a', 1), ('b', 2), ('c', 3)])

# Move to end
od.move_to_end('a')
print(od)  # OrderedDict([('b', 2), ('c', 3), ('a', 1)])

# Move to beginning
od.move_to_end('c', last=False)
print(od)  # OrderedDict([('c', 3), ('b', 2), ('a', 1)])

# Pop last item (LIFO)
last_item = od.popitem(last=True)
print(f"Popped: {last_item}")  # Popped: ('a', 1)

# Pop first item (FIFO)
first_item = od.popitem(last=False)
print(f"Popped: {first_item}")  # Popped: ('c', 3)
print(od)  # OrderedDict([('b', 2)])
```

#### Practical Examples

```python
# LRU Cache implementation
class LRUCache:
    def __init__(self, capacity):
        self.capacity = capacity
        self.cache = OrderedDict()
    
    def get(self, key):
        if key in self.cache:
            # Move to end (most recently used)
            self.cache.move_to_end(key)
            return self.cache[key]
        return None
    
    def put(self, key, value):
        if key in self.cache:
            # Update existing key
            self.cache.move_to_end(key)
        elif len(self.cache) >= self.capacity:
            # Remove least recently used
            self.cache.popitem(last=False)
        self.cache[key] = value

# Configuration with ordered sections
config = OrderedDict()
config['database'] = {'host': 'localhost', 'port': 5432}
config['cache'] = {'host': 'redis', 'port': 6379}
config['logging'] = {'level': 'INFO', 'file': 'app.log'}

# Maintain order when iterating
for section, settings in config.items():
    print(f"[{section}]")
    for key, value in settings.items():
        print(f"{key} = {value}")
```

### namedtuple

`namedtuple` creates tuple subclasses with named fields, providing a lightweight way to create classes for storing data.

#### Basic Usage

```python
from collections import namedtuple

# Define a named tuple
Point = namedtuple('Point', ['x', 'y'])
p1 = Point(10, 20)
print(p1)        # Point(x=10, y=20)
print(p1.x, p1.y)  # 10 20

# Alternative field specification
Person = namedtuple('Person', 'name age city')
person1 = Person('Alice', 30, 'New York')
print(person1.name)  # Alice

# With defaults (Python 3.7+)
Employee = namedtuple('Employee', ['name', 'id', 'department'], defaults=['IT'])
emp1 = Employee('Bob', 123)
print(emp1)  # Employee(name='Bob', id=123, department='IT')
```

#### namedtuple Methods

```python
Point = namedtuple('Point', ['x', 'y', 'z'])
p = Point(1, 2, 3)

# _asdict() - convert to dictionary
print(p._asdict())  # {'x': 1, 'y': 2, 'z': 3}

# _replace() - create new instance with some fields changed
p2 = p._replace(x=10)
print(p2)  # Point(x=10, y=2, z=3)

# _fields - tuple of field names
print(Point._fields)  # ('x', 'y', 'z')

# _make() - create instance from iterable
coords = [4, 5, 6]
p3 = Point._make(coords)
print(p3)  # Point(x=4, y=5, z=6)

# Tuple operations still work
print(p[0])     # 1 (indexing)
print(len(p))   # 3 (length)
x, y, z = p     # unpacking
```

#### Practical Examples

```python
# Database record representation
Record = namedtuple('Record', ['id', 'name', 'email', 'created_at'])

def fetch_users():
    # Simulate database fetch
    raw_data = [
        (1, 'Alice', 'alice@example.com', '2023-01-01'),
        (2, 'Bob', 'bob@example.com', '2023-01-02')
    ]
    return [Record._make(row) for row in raw_data]

users = fetch_users()
for user in users:
    print(f"User {user.name} ({user.email}) created on {user.created_at}")

# RGB color representation
Color = namedtuple('Color', ['red', 'green', 'blue'])

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return Color(*[int(hex_color[i:i+2], 16) for i in (0, 2, 4)])

red = hex_to_rgb('#FF0000')
print(red)  # Color(red=255, green=0, blue=0)

# Geometric calculations
Point = namedtuple('Point', ['x', 'y'])

def distance(p1, p2):
    return ((p1.x - p2.x)**2 + (p1.y - p2.y)**2)**0.5

p1 = Point(0, 0)
p2 = Point(3, 4)
print(f"Distance: {distance(p1, p2)}")  # Distance: 5.0

# Configuration objects
Config = namedtuple('Config', ['host', 'port', 'timeout', 'retries'], defaults=['localhost', 8080, 30, 3])
config = Config(host='production.com', port=443)
print(config)  # Config(host='production.com', port=443, timeout=30, retries=3)
```

### ChainMap

`ChainMap` groups multiple dicts or mappings together to create a single, updateable view.

#### Basic Usage

```python
from collections import ChainMap

dict1 = {'a': 1, 'b': 2}
dict2 = {'b': 3, 'c': 4}
dict3 = {'c': 5, 'd': 6}

# Create chain map
cm = ChainMap(dict1, dict2, dict3)
print(cm)  # ChainMap({'a': 1, 'b': 2}, {'b': 3, 'c': 4}, {'c': 5, 'd': 6})

# Lookup (searches in order)
print(cm['a'])  # 1 (from dict1)
print(cm['b'])  # 2 (from dict1, not dict2)
print(cm['c'])  # 4 (from dict2, not dict3)
print(cm['d'])  # 6 (from dict3)

# List all keys
print(list(cm.keys()))    # ['d', 'c', 'b', 'a']
print(list(cm.values()))  # [6, 4, 2, 1]
```

#### ChainMap Methods

```python
dict1 = {'a': 1, 'b': 2}
dict2 = {'c': 3, 'd': 4}
cm = ChainMap(dict1, dict2)

# new_child() - add new dict at front
child_cm = cm.new_child({'e': 5})
print(child_cm)  # ChainMap({'e': 5}, {'a': 1, 'b': 2}, {'c': 3, 'd': 4})

# parents - all maps except the first
print(cm.parents)  # ChainMap({'c': 3, 'd': 4})

# maps - list of all mappings
print(cm.maps)  # [{'a': 1, 'b': 2}, {'c': 3, 'd': 4}]

# Updates affect only the first mapping
cm['a'] = 10  # Updates dict1
cm['f'] = 6   # Adds to dict1
print(dict1)  # {'a': 10, 'b': 2, 'f': 6}
print(dict2)  # {'c': 3, 'd': 4} (unchanged)
```

#### Practical Examples

```python
# Configuration hierarchy (command line > config file > defaults)
defaults = {'host': 'localhost', 'port': 8080, 'debug': False}
config_file = {'host': 'production.com', 'port': 443}
command_line = {'debug': True}

config = ChainMap(command_line, config_file, defaults)
print(f"Host: {config['host']}")      # production.com (from config_file)
print(f"Port: {config['port']}")      # 443 (from config_file)
print(f"Debug: {config['debug']}")    # True (from command_line)

# Nested scope simulation
def outer_function():
    outer_vars = {'x': 1, 'y': 2}
    
    def inner_function():
        inner_vars = {'y': 3, 'z': 4}
        # Simulate variable lookup: local -> outer -> global
        scope = ChainMap(inner_vars, outer_vars, globals())
        print(f"x: {scope.get('x', 'Not found')}")  # 1 (from outer)
        print(f"y: {scope.get('y', 'Not found')}")  # 3 (from inner)
        print(f"z: {scope.get('z', 'Not found')}")  # 4 (from inner)
    
    inner_function()

# Environment variable override
import os
app_defaults = {'timeout': 30, 'retries': 3, 'verbose': False}
app_config = ChainMap(os.environ, app_defaults)

# Use environment variable if set, otherwise use default
timeout = int(app_config.get('TIMEOUT', app_config['timeout']))
```

### UserDict, UserList, UserString

These are wrapper classes that provide a base for creating custom container types.

#### UserDict

```python
from collections import UserDict

class CaseInsensitiveDict(UserDict):
    def __setitem__(self, key, value):
        super().__setitem__(key.lower(), value)
    
    def __getitem__(self, key):
        return super().__getitem__(key.lower())
    
    def __contains__(self, key):
        return super().__contains__(key.lower())
    
    def __delitem__(self, key):
        super().__delitem__(key.lower())

# Usage
ci_dict = CaseInsensitiveDict()
ci_dict['Name'] = 'Alice'
ci_dict['AGE'] = 30

print(ci_dict['name'])  # Alice
print(ci_dict['age'])   # 30
print('NAME' in ci_dict)  # True

# Validation dictionary
class ValidatedDict(UserDict):
    def __init__(self, validator_func, *args, **kwargs):
        self.validator = validator_func
        super().__init__(*args, **kwargs)
    
    def __setitem__(self, key, value):
        if not self.validator(key, value):
            raise ValueError(f"Invalid value: {value} for key: {key}")
        super().__setitem__(key, value)

def validate_age(key, value):
    return key == 'age' and isinstance(value, int) and 0 <= value <= 150

age_dict = ValidatedDict(validate_age)
age_dict['age'] = 25  # OK
# age_dict['age'] = -5  # Would raise ValueError
```

#### UserList

```python
from collections import UserList

class UniqueList(UserList):
    def append(self, item):
        if item not in self.data:
            super().append(item)
    
    def extend(self, items):
        for item in items:
            self.append(item)
    
    def insert(self, index, item):
        if item not in self.data:
            super().insert(index, item)

# Usage
ul = UniqueList([1, 2, 3])
ul.append(2)  # Won't add duplicate
ul.extend([3, 4, 5])  # Only 4 and 5 will be added
print(ul)  # [1, 2, 3, 4, 5]

# Statistics list
class StatsList(UserList):
    @property
    def mean(self):
        return sum(self.data) / len(self.data) if self.data else 0
    
    @property
    def median(self):
        sorted_data = sorted(self.data)
        n = len(sorted_data)
        if n % 2 == 0:
            return (sorted_data[n//2 - 1] + sorted_data[n//2]) / 2
        return sorted_data[n//2]

stats = StatsList([1, 3, 5, 7, 9])
print(f"Mean: {stats.mean}")    # Mean: 5.0
print(f"Median: {stats.median}")  # Median: 5
```

### Abstract Base Classes

The collections.abc module provides abstract base classes for containers.

#### Common ABCs

```python
from collections.abc import Mapping, MutableMapping, Sequence, MutableSequence

# Check if object implements interface
print(isinstance({}, Mapping))           # True
print(isinstance([], Sequence))          # True
print(isinstance([], MutableSequence))   # True

# Custom container that implements ABC
class ReadOnlyDict(Mapping):
    def __init__(self, data):
        self._data = data
    
    def __getitem__(self, key):
        return self._data[key]
    
    def __iter__(self):
        return iter(self._data)
    
    def __len__(self):
        return len(self._data)

# Usage
rod = ReadOnlyDict({'a': 1, 'b': 2})
print(rod['a'])     # 1
print(len(rod))     # 2
print(list(rod))    # ['a', 'b']
# rod['c'] = 3      # Would work but we haven't implemented __setitem__
```

### Performance Comparisons

#### List vs Deque Performance

```python
import time
from collections import deque

# Comparing append/pop performance
def time_operations(container_type, n=100000):
    container = container_type()
    
    # Time appends
    start = time.time()
    for i in range(n):
        container.append(i)
    append_time = time.time() - start
    
    # Time pops from left (if supported)
    if hasattr(container, 'popleft'):
        start = time.time()
        while container:
            container.popleft()
        pop_time = time.time() - start
    else:
        start = time.time()
        while container:
            container.pop(0)  # Inefficient for lists
        pop_time = time.time() - start
    
    return append_time, pop_time

# [Inference] Deques are significantly faster for operations at both ends
list_append, list_pop = time_operations(list, 10000)
deque_append, deque_pop = time_operations(deque, 10000)

print(f"List - Append: {list_append:.4f}s, Pop from start: {list_pop:.4f}s")
print(f"Deque - Append: {deque_append:.4f}s, Pop from start: {deque_pop:.4f}s")
```

#### Counter vs Manual Counting

```python
import time
from collections import Counter

data = ['apple', 'banana', 'apple', 'cherry', 'banana', 'apple'] * 10000

# Manual counting
start = time.time()
manual_count = {}
for item in data:
    manual_count[item] = manual_count.get(item, 0) + 1
manual_time = time.time() - start

# Counter
start = time.time()
counter_count = Counter(data)
counter_time = time.time() - start

print(f"Manual counting: {manual_time:.4f}s")
print(f"Counter: {counter_time:.4f}s")
# [Inference] Counter is typically faster due to C implementation
```

### Memory Usage Considerations

#### namedtuple vs Class vs dict

```python
import sys
from collections import namedtuple

# Regular class
class RegularPoint:
    def __init__(self, x, y):
        self.x = x
        self.y = y

# namedtuple
NamedPoint = namedtuple('Point', ['x', 'y'])

# Compare memory usage
regular = RegularPoint(1, 2)
named = NamedPoint(1, 2)
dict_point = {'x': 1, 'y': 2}

print(f"Regular class: {sys.getsizeof(regular)} bytes")
print(f"namedtuple: {sys.getsizeof(named)} bytes")
print(f"dict: {sys.getsizeof(dict_point)} bytes")
# [Inference] namedtuples are typically more memory-efficient than dicts and regular classes
```

### Best Practices and Common Patterns

#### When to Use Each Container

**Key points:**

- **Counter**: Frequency counting, multiset operations, statistical analysis
- **defaultdict**: Grouping data, avoiding KeyError, building nested structures
- **deque**: Queue/stack operations, sliding windows, bounded collections
- **OrderedDict**: When insertion order matters and you need ordering methods
- **namedtuple**: Lightweight data containers, replacing simple classes
- **ChainMap**: Configuration hierarchies, scope simulation, layered lookups

#### Common Patterns

```python
# Pattern 1: Grouping with defaultdict
from collections import defaultdict
def group_by(iterable, key_func):
    groups = defaultdict(list)
    for item in iterable:
        groups[key_func(item)].append(item)
    return dict(groups)

# Pattern 2: Frequency analysis with Counter
def analyze_text(text):
    words = text.lower().split()
    word_freq = Counter(words)
    char_freq = Counter(text.lower().replace(' ', ''))
    return {
        'word_count': len(words),
        'unique_words': len(word_freq),
        'most_common_word': word_freq.most_common(1)[0] if word_freq else None,
        'char_distribution': dict(char_freq.most_common(5))
    }

# Pattern 3: LRU-like behavior with deque
def recent_items_tracker(maxsize=10):
    items = deque(maxlen=maxsize)
    def add_item(item):
        if item in items:
            items.remove(item)  # Remove old occurrence
        items.append(item)  # Add to end
        return list(items)
    return add_item

# Pattern 4: Configuration management with ChainMap
def create_config(*config_sources):
    """Create configuration from multiple sources (later sources have higher priority)"""
    return ChainMap(*reversed(config_sources))
```

### Error Handling and Edge Cases

#### Handling Missing Keys

```python
from collections import defaultdict, Counter

# defaultdict with None factory
dd = defaultdict(lambda: None)
print(dd['missing'])  # None (instead of KeyError)

# Counter with missing keys
c = Counter(['a', 'b', 'c'])
print(c['missing'])  # 0 (not KeyError)

# ChainMap with missing keys
from collections import ChainMap

cm = ChainMap({'a': 1}, {'b': 2})
print(cm.get('missing', 'default'))  # 'default'
# print(cm['missing'])  # Would raise KeyError
```

#### Thread Safety Considerations

```python
import threading
from collections import defaultdict, deque, Counter

# [Unverified] Most collections types are not thread-safe for modifications
# Use locks for concurrent access
lock = threading.Lock()
shared_counter = Counter()

def thread_safe_count(items):
    with lock:
        shared_counter.update(items)

# For deque, some operations are atomic, but complex operations need locks
shared_deque = deque()

def safe_deque_operation():
    with lock:
        if shared_deque:  # Check and pop atomically
            return shared_deque.popleft()
    return None
```

#### Handling Large Data Sets

```python
# Memory-efficient processing with generators
def process_large_file(filename):
    word_count = Counter()
    
    def word_generator():
        with open(filename, 'r') as f:
            for line in f:
                for word in line.strip().split():
                    yield word.lower()
    
    # Process in chunks to avoid memory issues
    chunk_size = 10000
    words = word_generator()
    while True:
        chunk = []
        try:
            for _ in range(chunk_size):
                chunk.append(next(words))
        except StopIteration:
            if chunk:
                word_count.update(chunk)
            break
        word_count.update(chunk)
    
    return word_count

# Bounded collections for streaming data
class BoundedDefaultDict(defaultdict):
    def __init__(self, default_factory, max_size):
        super().__init__(default_factory)
        self.max_size = max_size
    
    def __setitem__(self, key, value):
        if len(self) >= self.max_size and key not in self:
            # Remove oldest item (simple LRU-like behavior)
            oldest_key = next(iter(self))
            del self[oldest_key]
        super().__setitem__(key, value)
```

### Advanced Use Cases

#### Custom Collection Combinations

```python
from collections import defaultdict, Counter, deque

class MultiLevelCounter:
    """Counter that tracks items at multiple hierarchy levels"""
    def __init__(self):
        self.counters = defaultdict(Counter)
    
    def add(self, category, item):
        self.counters[category][item] += 1
        self.counters['_total'][item] += 1
    
    def get_category_stats(self, category):
        return dict(self.counters[category])
    
    def get_global_stats(self):
        return dict(self.counters['_total'])
    
    def most_common_global(self, n=None):
        return self.counters['_total'].most_common(n)

# Usage
mlc = MultiLevelCounter()
mlc.add('fruits', 'apple')
mlc.add('fruits', 'banana')
mlc.add('vegetables', 'carrot')
mlc.add('fruits', 'apple')

print(mlc.get_category_stats('fruits'))  # {'apple': 2, 'banana': 1}
print(mlc.most_common_global())          # [('apple', 2), ('banana', 1), ('carrot', 1)]

class TimestampedDeque:
    """Deque with automatic timestamping"""
    def __init__(self, maxlen=None):
        self.items = deque(maxlen=maxlen)
        self.timestamps = deque(maxlen=maxlen)
    
    def append(self, item):
        import time
        self.items.append(item)
        self.timestamps.append(time.time())
    
    def get_recent(self, seconds):
        import time
        cutoff = time.time() - seconds
        recent_items = []
        for item, timestamp in zip(self.items, self.timestamps):
            if timestamp >= cutoff:
                recent_items.append((item, timestamp))
        return recent_items
    
    def __len__(self):
        return len(self.items)
    
    def __iter__(self):
        return zip(self.items, self.timestamps)

# Usage
td = TimestampedDeque(maxlen=100)
td.append('event1')
import time; time.sleep(1)
td.append('event2')
recent = td.get_recent(0.5)  # Get events from last 0.5 seconds
```

#### Data Processing Pipelines

```python
from collections import defaultdict, Counter, deque
from functools import reduce
import operator

class DataPipeline:
    """Process data through multiple collection-based stages"""
    def __init__(self):
        self.stages = []
    
    def add_grouping_stage(self, key_func):
        def group_stage(data):
            grouped = defaultdict(list)
            for item in data:
                grouped[key_func(item)].append(item)
            return dict(grouped)
        self.stages.append(group_stage)
        return self
    
    def add_counting_stage(self):
        def count_stage(data):
            if isinstance(data, dict):
                return {k: Counter(v) for k, v in data.items()}
            return Counter(data)
        self.stages.append(count_stage)
        return self
    
    def add_filtering_stage(self, predicate):
        def filter_stage(data):
            if isinstance(data, dict):
                return {k: [item for item in v if predicate(item)] 
                       for k, v in data.items()}
            return [item for item in data if predicate(item)]
        self.stages.append(filter_stage)
        return self
    
    def process(self, data):
        return reduce(lambda d, stage: stage(d), self.stages, data)

# Example usage
transactions = [
    {'type': 'purchase', 'amount': 100, 'category': 'food'},
    {'type': 'purchase', 'amount': 50, 'category': 'transport'},
    {'type': 'refund', 'amount': 25, 'category': 'food'},
    {'type': 'purchase', 'amount': 75, 'category': 'food'},
]

pipeline = (DataPipeline()
           .add_grouping_stage(lambda x: x['type'])
           .add_filtering_stage(lambda x: x['amount'] > 30)
           .add_counting_stage())

result = pipeline.process(transactions)
print(result)
```

#### Caching and Memoization Patterns

```python
from collections import OrderedDict
from functools import wraps

class TTLCache:
    """Time-to-live cache using OrderedDict"""
    def __init__(self, maxsize=128, ttl=300):
        self.maxsize = maxsize
        self.ttl = ttl
        self.cache = OrderedDict()
        self.timestamps = {}
    
    def _is_expired(self, key):
        import time
        return time.time() - self.timestamps.get(key, 0) > self.ttl
    
    def get(self, key):
        if key in self.cache and not self._is_expired(key):
            # Move to end (LRU behavior)
            self.cache.move_to_end(key)
            return self.cache[key]
        elif key in self.cache:
            # Remove expired item
            del self.cache[key]
            del self.timestamps[key]
        return None
    
    def set(self, key, value):
        import time
        if key in self.cache:
            self.cache.move_to_end(key)
        elif len(self.cache) >= self.maxsize:
            # Remove oldest
            oldest = next(iter(self.cache))
            del self.cache[oldest]
            del self.timestamps[oldest]
        
        self.cache[key] = value
        self.timestamps[key] = time.time()

def ttl_memoize(ttl=300, maxsize=128):
    """Decorator for TTL memoization"""
    def decorator(func):
        cache = TTLCache(maxsize, ttl)
        
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Create cache key
            key = str(args) + str(sorted(kwargs.items()))
            
            result = cache.get(key)
            if result is not None:
                return result
            
            result = func(*args, **kwargs)
            cache.set(key, result)
            return result
        
        wrapper.cache_info = lambda: {
            'size': len(cache.cache),
            'maxsize': cache.maxsize,
            'ttl': cache.ttl
        }
        wrapper.cache_clear = lambda: cache.cache.clear()
        
        return wrapper
    return decorator

# Usage
@ttl_memoize(ttl=60, maxsize=100)
def expensive_calculation(n):
    import time
    time.sleep(1)  # Simulate expensive operation
    return n ** 2

result = expensive_calculation(5)  # Takes 1 second
result = expensive_calculation(5)  # Returns immediately from cache
```

### Integration with Other Modules

#### JSON Serialization

```python
import json
from collections import OrderedDict, namedtuple, Counter

# OrderedDict with JSON
data = OrderedDict([('name', 'Alice'), ('age', 30), ('city', 'NYC')])
json_str = json.dumps(data)
loaded = json.loads(json_str, object_pairs_hook=OrderedDict)
print(type(loaded))  # <class 'collections.OrderedDict'>

# namedtuple with JSON
Person = namedtuple('Person', ['name', 'age', 'city'])
person = Person('Bob', 25, 'LA')

# Convert to dict for JSON serialization
person_dict = person._asdict()
json_str = json.dumps(person_dict)

# Load back as namedtuple
loaded_dict = json.loads(json_str)
loaded_person = Person(**loaded_dict)

# Counter with JSON
counter = Counter(['a', 'b', 'a', 'c', 'b', 'a'])
counter_json = json.dumps(dict(counter))
loaded_counter = Counter(json.loads(counter_json))
```

#### Pickle Support

```python
import pickle
from collections import defaultdict, deque, Counter

# Most collections types are pickle-able
dd = defaultdict(list)
dd['key'].append('value')

pickled = pickle.dumps(dd)
unpickled = pickle.loads(pickled)
print(type(unpickled))  # <class 'collections.defaultdict'>
print(unpickled.default_factory)  # <class 'list'>

# Custom collections need special handling
class CustomCounter(Counter):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.creation_time = __import__('time').time()
    
    def __reduce__(self):
        # Custom pickle support
        return (self.__class__, (dict(self),))

cc = CustomCounter(['a', 'b', 'a'])
pickled_cc = pickle.dumps(cc)
unpickled_cc = pickle.loads(pickled_cc)
```

#### Database Integration

```python
from collections import namedtuple, defaultdict
import sqlite3

# Using namedtuple for database records
def fetch_users_as_namedtuple():
    conn = sqlite3.connect(':memory:')
    conn.execute('CREATE TABLE users (id INTEGER, name TEXT, email TEXT)')
    conn.execute("INSERT INTO users VALUES (1, 'Alice', 'alice@example.com')")
    conn.execute("INSERT INTO users VALUES (2, 'Bob', 'bob@example.com')")
    
    User = namedtuple('User', ['id', 'name', 'email'])
    cursor = conn.execute('SELECT * FROM users')
    
    users = [User(*row) for row in cursor.fetchall()]
    conn.close()
    return users

# Grouping database results
def group_users_by_domain():
    users = fetch_users_as_namedtuple()
    by_domain = defaultdict(list)
    
    for user in users:
        domain = user.email.split('@')[1]
        by_domain[domain].append(user)
    
    return dict(by_domain)

users_by_domain = group_users_by_domain()
print(users_by_domain)
```

### Testing Collections-Based Code

```python
import unittest
from collections import Counter, defaultdict, deque

class TestCollections(unittest.TestCase):
    def test_counter_operations(self):
        c1 = Counter(['a', 'b', 'c', 'a'])
        c2 = Counter(['a', 'b', 'b'])
        
        # Test arithmetic operations
        result = c1 + c2
        expected = Counter({'a': 3, 'b': 3, 'c': 1})
        self.assertEqual(result, expected)
        
        # Test most_common
        self.assertEqual(c1.most_common(2), [('a', 2), ('b', 1)])
    
    def test_defaultdict_behavior(self):
        dd = defaultdict(list)
        dd['key'].append('value')
        
        # Test that missing keys create default values
        self.assertEqual(dd['missing'], [])
        self.assertIsInstance(dd['missing'], list)
    
    def test_deque_performance(self):
        d = deque(maxlen=3)
        
        # Test bounded behavior
        for i in range(5):
            d.append(i)
        
        self.assertEqual(len(d), 3)
        self.assertEqual(list(d), [2, 3, 4])
    
    def test_custom_collections(self):
        # Test custom collection behavior
        class ValidatedList(list):
            def append(self, item):
                if not isinstance(item, int):
                    raise TypeError("Only integers allowed")
                super().append(item)
        
        vl = ValidatedList([1, 2, 3])
        vl.append(4)
        self.assertEqual(vl, [1, 2, 3, 4])
        
        with self.assertRaises(TypeError):
            vl.append('string')

if __name__ == '__main__':
    unittest.main()
```

### Performance Optimization Tips

#### Choosing the Right Collection

```python
import timeit
from collections import deque, defaultdict, Counter

# Benchmark different approaches
def benchmark_counting():
    data = ['apple', 'banana', 'apple'] * 1000
    
    # Method 1: Manual dictionary
    def manual_count():
        counts = {}
        for item in data:
            counts[item] = counts.get(item, 0) + 1
        return counts
    
    # Method 2: defaultdict
    def defaultdict_count():
        counts = defaultdict(int)
        for item in data:
            counts[item] += 1
        return dict(counts)
    
    # Method 3: Counter
    def counter_count():
        return Counter(data)
    
    # [Inference] Counter is typically fastest for this use case
    manual_time = timeit.timeit(manual_count, number=1000)
    defaultdict_time = timeit.timeit(defaultdict_count, number=1000)
    counter_time = timeit.timeit(counter_count, number=1000)
    
    print(f"Manual: {manual_time:.4f}s")
    print(f"defaultdict: {defaultdict_time:.4f}s")
    print(f"Counter: {counter_time:.4f}s")

# Memory usage optimization
def memory_efficient_grouping(items, key_func):
    """Group items without storing all in memory at once"""
    # Instead of defaultdict(list) which stores all items
    # Use generator-based approach for large datasets
    sorted_items = sorted(items, key=key_func)
    
    from itertools import groupby
    for key, group in groupby(sorted_items, key=key_func):
        yield key, list(group)
```

### Common Antipatterns and Solutions

#### Avoiding Performance Pitfalls

```python
# ANTIPATTERN: Using list for frequent left operations
def bad_queue():
    queue = []
    for i in range(1000):
        queue.append(i)
    
    # This is O(n) for each operation!
    while queue:
        item = queue.pop(0)  # Bad!

# SOLUTION: Use deque
def good_queue():
    from collections import deque
    queue = deque()
    for i in range(1000):
        queue.append(i)
    
    # This is O(1) for each operation
    while queue:
        item = queue.popleft()  # Good!

# ANTIPATTERN: Manual grouping when defaultdict is available
def bad_grouping(items):
    groups = {}
    for item in items:
        key = item['category']
        if key not in groups:
            groups[key] = []  # Manual check
        groups[key].append(item)
    return groups

# SOLUTION: Use defaultdict
def good_grouping(items):
    from collections import defaultdict
    groups = defaultdict(list)
    for item in items:
        groups[item['category']].append(item)  # No manual check needed
    return dict(groups)
```

#### Avoiding Memory Leaks

```python
# ANTIPATTERN: Keeping references in collections
class DataProcessor:
    def __init__(self):
        self.cache = {}  # Can grow indefinitely
    
    def process(self, data):
        result = expensive_operation(data)
        self.cache[id(data)] = result  # Memory leak!
        return result

# SOLUTION: Use bounded collections
class BetterDataProcessor:
    def __init__(self, cache_size=1000):
        from collections import OrderedDict
        self.cache = OrderedDict()
        self.cache_size = cache_size
    
    def process(self, data):
        cache_key = hash(str(data))  # Better key
        
        if cache_key in self.cache:
            self.cache.move_to_end(cache_key)
            return self.cache[cache_key]
        
        result = expensive_operation(data)
        
        if len(self.cache) >= self.cache_size:
            self.cache.popitem(last=False)  # Remove oldest
        
        self.cache[cache_key] = result
        return result

def expensive_operation(data):
    # Placeholder for expensive operation
    return data * 2
```

**Key points:**

- Collections module provides specialized containers optimized for specific use cases
- Counter excels at frequency analysis and multiset operations
- defaultdict eliminates KeyError handling and simplifies grouping operations
- deque provides O(1) operations at both ends, perfect for queues and stacks
- OrderedDict maintains insertion order with additional ordering methods
- namedtuple creates lightweight, immutable record types
- ChainMap enables layered lookups across multiple mappings
- UserDict, UserList, UserString provide bases for custom container types
- [Inference] Most collections types are implemented in C for optimal performance
- Choose the right collection type based on your specific access patterns and requirements
- Be mindful of memory usage with unbounded collections
- Thread safety requires explicit synchronization for most collection operations
- Integration with JSON, pickle, and databases is straightforward for most types

The collections module is essential for writing efficient, readable Python code that handles complex data structures and access patterns elegantly.

---

## `logging` Module

### Overview

The Python logging module is a built-in library that provides a flexible framework for emitting log messages from Python programs. It's part of the standard library since Python 2.3 and offers a sophisticated system for capturing, filtering, formatting, and outputting diagnostic information.

### Core Components

#### Loggers

Loggers are the primary interface for application code. They expose methods that applications use directly and determine which log messages to process based on severity levels.

- **Root Logger**: The parent of all loggers, created automatically
- **Named Loggers**: Created using `logging.getLogger(name)`
- **Logger Hierarchy**: Uses dot notation (e.g., 'myapp.module1.submodule')

#### Handlers

Handlers determine where log messages go. Multiple handlers can be attached to a single logger.

- **StreamHandler**: Outputs to streams (stdout, stderr)
- **FileHandler**: Writes to files
- **RotatingFileHandler**: Rotates files based on size
- **TimedRotatingFileHandler**: Rotates files based on time intervals
- **HTTPHandler**: Sends logs via HTTP
- **SMTPHandler**: Emails log messages
- **SysLogHandler**: Sends to system logging daemon
- **NTEventLogHandler**: Windows Event Log (Windows only)

#### Formatters

Formatters specify the layout of log records in the final output.

**Key attributes:**

- `%(name)s`: Logger name
- `%(levelname)s`: Log level name
- `%(message)s`: The logged message
- `%(asctime)s`: Timestamp
- `%(filename)s`: Source filename
- `%(lineno)d`: Line number
- `%(funcName)s`: Function name

#### Filters

Filters provide fine-grained control over which log records are processed.

### Log Levels

Python logging defines five standard levels:

- **DEBUG (10)**: Detailed diagnostic information
- **INFO (20)**: General information about program execution
- **WARNING (30)**: Something unexpected happened or potential problems
- **ERROR (40)**: Serious problems that prevented a function from executing
- **CRITICAL (50)**: Very serious errors that may abort the program

### Basic Usage

#### Simple Logging

```python
import logging

# Basic configuration
logging.basicConfig(level=logging.INFO)

# Log messages
logging.debug('This is a debug message')
logging.info('This is an info message')
logging.warning('This is a warning message')
logging.error('This is an error message')
logging.critical('This is a critical message')
```

#### Creating Custom Loggers

```python
import logging

# Create logger
logger = logging.getLogger('my_app')
logger.setLevel(logging.DEBUG)

# Create handler
handler = logging.StreamHandler()
handler.setLevel(logging.DEBUG)

# Create formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)

# Add handler to logger
logger.addHandler(handler)

# Use logger
logger.info('Custom logger message')
```

### Configuration Methods

#### Basic Configuration

`logging.basicConfig()` provides quick setup for simple logging needs:

```python
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename='app.log',
    filemode='a'
)
```

#### Dictionary Configuration

```python
import logging.config

config = {
    'version': 1,
    'formatters': {
        'default': {
            'format': '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'default',
        },
    },
    'root': {
        'level': 'INFO',
        'handlers': ['console'],
    },
}

logging.config.dictConfig(config)
```

#### File-Based Configuration

Configuration can be loaded from INI or YAML files using `logging.config.fileConfig()`.

### Advanced Features

#### Log Rotation

```python
import logging
from logging.handlers import RotatingFileHandler

# Size-based rotation
handler = RotatingFileHandler('app.log', maxBytes=1024*1024, backupCount=5)

# Time-based rotation
from logging.handlers import TimedRotatingFileHandler
handler = TimedRotatingFileHandler('app.log', when='midnight', interval=1, backupCount=7)
```

#### Custom Filters

```python
class SpecificFilter(logging.Filter):
    def filter(self, record):
        return 'specific_keyword' in record.getMessage()

logger.addFilter(SpecificFilter())
```

#### Context Information

```python
# Using extra parameter
logger.info('User action', extra={'user_id': 123, 'action': 'login'})

# Using LoggerAdapter
adapter = logging.LoggerAdapter(logger, {'user_id': 123})
adapter.info('User performed action')
```

#### Exception Logging

```python
try:
    risky_operation()
except Exception:
    logger.exception('An error occurred')  # Includes traceback
    # or
    logger.error('An error occurred', exc_info=True)
```

### Performance Considerations

#### Lazy Evaluation

```python
# Inefficient - string formatting happens even if not logged
logger.debug('Value: ' + str(expensive_operation()))

# Efficient - formatting only happens if logged
logger.debug('Value: %s', expensive_operation())
```

#### Conditional Logging

```python
if logger.isEnabledFor(logging.DEBUG):
    logger.debug('Expensive debug info: %s', compute_expensive_info())
```

### Threading Considerations

The logging module is thread-safe by default. All handlers use locks to ensure thread safety, but this can impact performance in high-throughput applications.

**Key points:**

- Default handlers are thread-safe
- Custom handlers should implement proper locking
- QueueHandler can be used for better performance in multi-threaded applications

### Best Practices

#### Logger Naming

```python
# Use module's __name__ for automatic hierarchy
logger = logging.getLogger(__name__)

# Results in hierarchical names like:
# myproject.module1
# myproject.module1.submodule
```

#### Configuration Management

- Configure logging once at application startup
- Use configuration files for production environments
- Separate configuration from application code

#### Log Message Format

- Include relevant context (timestamp, level, module)
- Use structured logging for machine parsing
- Avoid logging sensitive information

#### Error Handling

```python
# Don't let logging errors crash your application
try:
    logger.info('Operation completed')
except Exception:
    pass  # Or use a fallback logging mechanism
```

### Integration with Other Libraries

#### With Web Frameworks

```python
# Flask example
from flask import Flask
import logging

app = Flask(__name__)
app.logger.setLevel(logging.INFO)

# Django uses Python logging by default
```

#### With Third-Party Libraries

Many libraries use Python logging:

- **Requests**: HTTP library logging
- **SQLAlchemy**: Database query logging
- **Celery**: Task queue logging

### Structured Logging

#### JSON Logging

```python
import json
import logging

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            'timestamp': self.formatTime(record),
            'level': record.levelname,
            'message': record.getMessage(),
            'module': record.module,
        }
        return json.dumps(log_entry)
```

### Common Patterns

#### Module-Level Logger

```python
import logging

logger = logging.getLogger(__name__)

def my_function():
    logger.info('Function called')
```

#### Contextual Logging

```python
import logging
from contextlib import contextmanager

@contextmanager
def log_context(logger, message):
    logger.info(f'Starting: {message}')
    try:
        yield
    finally:
        logger.info(f'Finished: {message}')

# Usage
with log_context(logger, 'database operation'):
    perform_database_operation()
```

### Troubleshooting

#### Common Issues

- **No output**: Check log levels and handler configuration
- **Duplicate messages**: Multiple handlers or propagation issues
- **Performance problems**: Excessive logging or inefficient formatters
- **Unicode errors**: Encoding issues with file handlers

#### Debugging Logging Configuration

```python
# Enable logging module's own debug output
logging.basicConfig(level=logging.DEBUG)
logging.getLogger().debug('Test message')

# Print current logger configuration
for name, logger in logging.Logger.manager.loggerDict.items():
    print(f'Logger: {name}, Level: {logger.level if hasattr(logger, "level") else "Not set"}')
```

### Testing Considerations

#### Capturing Logs in Tests

```python
import logging
import unittest
from unittest.mock import patch

class TestLogging(unittest.TestCase):
    def test_logging_output(self):
        with patch('logging.Logger.info') as mock_info:
            my_function_that_logs()
            mock_info.assert_called_with('Expected message')
```

### Security Considerations

- Avoid logging sensitive data (passwords, tokens, personal information)
- Sanitize user input before logging
- Consider log file permissions and storage security
- Be aware of log injection attacks

**Key points:**

- Log rotation prevents disk space issues
- Structured logging aids in log analysis
- Proper configuration separation improves maintainability
- Thread safety is handled automatically for standard handlers

---

## `configparser` Module

### Overview

The `configparser` module is a built-in Python library that provides a way to work with configuration files in a structured format similar to Windows INI files. It allows developers to store application settings, preferences, and configuration data in human-readable text files that can be easily modified without changing the source code.

### Configuration File Format

ConfigParser uses a section-based format where configuration data is organized into sections, with each section containing key-value pairs.

**Basic structure:**

```ini
[section1]
key1 = value1
key2 = value2

[section2]
key3 = value3
key4 = value4
```

### Key Classes

#### ConfigParser

The main class for reading and writing configuration files. It's case-insensitive for section and option names by default.

#### RawConfigParser

A more basic version that doesn't support string interpolation. Values are returned exactly as written in the file.

#### SafeConfigParser

Deprecated since Python 3.2. Use `ConfigParser` instead, which incorporates its safety features.

### Basic Operations

#### Creating a ConfigParser Object

```python
import configparser

config = configparser.ConfigParser()
```

#### Reading Configuration Files

```python
# Read from a file
config.read('config.ini')

# Read from multiple files
config.read(['config.ini', 'local_config.ini'])

# Read from string
config.read_string("""
[section1]
key1 = value1
""")

# Read from dictionary
config.read_dict({
    'section1': {'key1': 'value1'},
    'section2': {'key2': 'value2'}
})
```

#### Writing Configuration Files

```python
# Write to file
with open('config.ini', 'w') as configfile:
    config.write(configfile)

# Write to string
config_string = io.StringIO()
config.write(config_string)
```

### Working with Sections

#### Adding Sections

```python
config.add_section('database')
config.add_section('logging')
```

#### Checking Section Existence

```python
if config.has_section('database'):
    print("Database section exists")

# Get all sections
sections = config.sections()
```

#### Removing Sections

```python
config.remove_section('database')
```

### Working with Options

#### Setting Options

```python
config.set('database', 'host', 'localhost')
config.set('database', 'port', '5432')

# Alternative syntax
config['database']['host'] = 'localhost'
```

#### Getting Options

```python
# Basic get
host = config.get('database', 'host')

# With fallback value
port = config.get('database', 'port', fallback='3306')

# Type-specific getters
port = config.getint('database', 'port')
debug = config.getboolean('logging', 'debug')
timeout = config.getfloat('network', 'timeout')
```

#### Checking Option Existence

```python
if config.has_option('database', 'host'):
    print("Host option exists")

# Get all options in a section
options = config.options('database')
```

#### Removing Options

```python
config.remove_option('database', 'host')
```

### Data Types and Conversion

ConfigParser stores all values as strings, but provides methods for type conversion:

```python
# String (default)
name = config.get('user', 'name')

# Integer
age = config.getint('user', 'age')

# Float
height = config.getfloat('user', 'height')

# Boolean
active = config.getboolean('user', 'active')
```

**Boolean interpretation:**

- True: "1", "yes", "true", "on"
- False: "0", "no", "false", "off"

### String Interpolation

ConfigParser supports variable interpolation within configuration values.

#### Basic Interpolation

```ini
[paths]
home_dir = /Users
my_dir = %(home_dir)s/lumberjack
my_pictures = %(my_dir)s/Pictures
```

#### Extended Interpolation

```python
config = configparser.ConfigParser()
config.read_string("""
[paths]
home_dir = /Users
my_dir = ${paths:home_dir}/lumberjack
my_pictures = ${my_dir}/Pictures
""")
```

### Advanced Features

#### Default Values

```python
# Set defaults for all sections
config = configparser.ConfigParser({
    'debug': 'False',
    'timeout': '30'
})

# Section-specific defaults
config.read_dict({
    'DEFAULT': {
        'debug': 'False',
        'timeout': '30'
    }
})
```

#### Case Sensitivity

```python
# Case-sensitive parser
config = configparser.RawConfigParser()
config.optionxform = str  # Preserve case
```

#### Custom Delimiters

```python
config = configparser.ConfigParser(
    delimiters=('=', ':'),
    comment_prefixes=('#', ';')
)
```

#### Allow No Value Options

```python
config = configparser.ConfigParser(allow_no_value=True)
# Allows options without values: just_a_flag
```

### Error Handling

#### Common Exceptions

```python
try:
    value = config.get('section', 'option')
except configparser.NoSectionError:
    print("Section not found")
except configparser.NoOptionError:
    print("Option not found")
except configparser.ParsingError:
    print("Error parsing configuration file")
```

### Practical Examples

#### Database Configuration

```python
import configparser

# Create config
config = configparser.ConfigParser()

# Add database section
config.add_section('database')
config.set('database', 'host', 'localhost')
config.set('database', 'port', '5432')
config.set('database', 'username', 'admin')
config.set('database', 'password', 'secret')

# Save to file
with open('db_config.ini', 'w') as configfile:
    config.write(configfile)

# Read and use
config.read('db_config.ini')
db_host = config.get('database', 'host')
db_port = config.getint('database', 'port')
```

#### Application Settings

```python
# config.ini
[general]
app_name = MyApplication
version = 1.0.0
debug = true

[logging]
level = INFO
file = app.log
max_size = 10485760

[network]
timeout = 30.0
retries = 3
```

```python
# Using the config
config = configparser.ConfigParser()
config.read('config.ini')

app_name = config.get('general', 'app_name')
debug_mode = config.getboolean('general', 'debug')
log_level = config.get('logging', 'level')
timeout = config.getfloat('network', 'timeout')
```

### Best Practices

#### File Organization

- Use descriptive section names
- Group related options together
- Include comments for complex configurations
- Use consistent naming conventions

#### Security Considerations

- Never store sensitive data like passwords in plain text
- Use environment variables or secure vaults for secrets
- Set appropriate file permissions on configuration files

#### Validation

```python
def validate_config(config):
    required_sections = ['database', 'logging']
    for section in required_sections:
        if not config.has_section(section):
            raise ValueError(f"Missing required section: {section}")
    
    # Validate specific options
    if not config.has_option('database', 'host'):
        raise ValueError("Database host not specified")
```

#### Configuration Hierarchy

```python
# Load multiple config files with priority
config = configparser.ConfigParser()
config.read([
    'default.ini',      # Default settings
    'config.ini',       # Main config
    'local.ini'         # Local overrides
])
```

### Integration Patterns

#### Environment Variable Override

```python
import os
import configparser

config = configparser.ConfigParser()
config.read('config.ini')

# Override with environment variables
db_host = os.getenv('DB_HOST', config.get('database', 'host'))
```

#### Configuration Class Wrapper

```python
class AppConfig:
    def __init__(self, config_file):
        self.config = configparser.ConfigParser()
        self.config.read(config_file)
    
    @property
    def db_host(self):
        return self.config.get('database', 'host')
    
    @property
    def debug_mode(self):
        return self.config.getboolean('general', 'debug')
```

### Performance Considerations

#### Lazy Loading

```python
class ConfigManager:
    def __init__(self):
        self._config = None
    
    @property
    def config(self):
        if self._config is None:
            self._config = configparser.ConfigParser()
            self._config.read('config.ini')
        return self._config
```

#### Caching Values

```python
class CachedConfig:
    def __init__(self, config_file):
        self.config = configparser.ConfigParser()
        self.config.read(config_file)
        self._cache = {}
    
    def get_cached(self, section, option):
        key = f"{section}.{option}"
        if key not in self._cache:
            self._cache[key] = self.config.get(section, option)
        return self._cache[key]
```

### Limitations and Alternatives

#### ConfigParser Limitations

- No support for nested sections
- Limited data types (strings only, with conversion methods)
- No array/list support natively
- No JSON-like complex structures

#### Alternative Libraries

- **TOML**: `toml` or `tomllib` (Python 3.11+)
- **YAML**: `PyYAML` or `ruamel.yaml`
- **JSON**: Built-in `json` module
- **Environment variables**: `python-decouple` or `environs`

ConfigParser remains excellent for simple, flat configuration structures and maintains compatibility with legacy INI-style configuration files commonly used in system administration and desktop applications.

---

## `typing` Module

The `typing` module provides runtime support for type hints, introduced in Python 3.5 via PEP 484. It allows you to annotate function parameters, return values, and variables with expected types, improving code clarity and enabling static type checking with tools like mypy.

### Basic Type Annotations

You can annotate variables and function signatures with built-in types:

```python
from typing import List, Dict, Set, Tuple

def greet(name: str) -> str:
    return f"Hello, {name}"

age: int = 25
scores: List[int] = [95, 87, 92]
user_data: Dict[str, int] = {"age": 25, "score": 100}
```

### Common Generic Types

#### List, Dict, Set, Tuple

These generic types specify the types of elements they contain:

```python
from typing import List, Dict, Set, Tuple

# List of strings
names: List[str] = ["Alice", "Bob"]

# Dictionary with string keys and integer values
ages: Dict[str, int] = {"Alice": 30, "Bob": 25}

# Set of integers
unique_ids: Set[int] = {1, 2, 3}

# Tuple with specific types (fixed length)
coordinates: Tuple[float, float] = (10.5, 20.3)

# Tuple with variable length
numbers: Tuple[int, ...] = (1, 2, 3, 4, 5)
```

#### Optional and Union

`Optional[X]` is shorthand for `Union[X, None]`, indicating a value can be of type X or None:

```python
from typing import Optional, Union

def find_user(user_id: int) -> Optional[str]:
    # Returns username or None if not found
    return None

# Union allows multiple possible types
def process_id(id_value: Union[int, str]) -> str:
    return str(id_value)
```

#### Any

`Any` is a special type indicating a value can be of any type:

```python
from typing import Any

def log_value(value: Any) -> None:
    print(value)
```

### Callable

`Callable` describes functions and other callables:

```python
from typing import Callable

# Function that takes two ints and returns an int
def apply_operation(x: int, y: int, operation: Callable[[int, int], int]) -> int:
    return operation(x, y)

def add(a: int, b: int) -> int:
    return a + b

result = apply_operation(5, 3, add)  # Returns 8
```

### Type Aliases

You can create aliases for complex types:

```python
from typing import List, Tuple

# Define an alias
Coordinate = Tuple[float, float]
Path = List[Coordinate]

def calculate_distance(path: Path) -> float:
    # Implementation
    return 0.0
```

### NewType

`NewType` creates distinct types for type checking purposes:

```python
from typing import NewType

UserId = NewType('UserId', int)
OrderId = NewType('OrderId', int)

def get_user(user_id: UserId) -> str:
    return f"User {user_id}"

# Type checkers will catch mixing these up
user = UserId(42)
order = OrderId(100)

get_user(user)    # OK
# get_user(order)  # Type checker error
```

### Literal

`Literal` restricts values to specific literals:

```python
from typing import Literal

def set_mode(mode: Literal["read", "write", "execute"]) -> None:
    print(f"Mode set to {mode}")

set_mode("read")   # OK
# set_mode("delete")  # Type checker error
```

### TypedDict

`TypedDict` defines dictionaries with specific keys and value types:

```python
from typing import TypedDict

class Person(TypedDict):
    name: str
    age: int
    email: str

person: Person = {
    "name": "Alice",
    "age": 30,
    "email": "alice@example.com"
}
```

### Generic Classes

You can create generic classes using `TypeVar`:

```python
from typing import TypeVar, Generic, List

T = TypeVar('T')

class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: List[T] = []
    
    def push(self, item: T) -> None:
        self._items.append(item)
    
    def pop(self) -> T:
        return self._items.pop()

# Create type-specific stacks
int_stack: Stack[int] = Stack()
str_stack: Stack[str] = Stack()
```

### Protocol (Structural Subtyping)

`Protocol` defines structural types (duck typing with type checking):

```python
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None:
        ...

class Circle:
    def draw(self) -> None:
        print("Drawing circle")

class Square:
    def draw(self) -> None:
        print("Drawing square")

def render(shape: Drawable) -> None:
    shape.draw()

# Both work without explicit inheritance
render(Circle())
render(Square())
```

### TypeVar Constraints and Bounds

`TypeVar` can be constrained to specific types or bounded:

```python
from typing import TypeVar

# Constrained to specific types
AnyStr = TypeVar('AnyStr', str, bytes)

def concat(x: AnyStr, y: AnyStr) -> AnyStr:
    return x + y

# Bounded (must be subtype of Number)
from numbers import Number
NumericType = TypeVar('NumericType', bound=Number)

def add_numbers(x: NumericType, y: NumericType) -> NumericType:
    return x + y
```

### Type Guards

Type guards narrow types within conditional blocks:

```python
from typing import Union

def process_value(value: Union[int, str]) -> None:
    if isinstance(value, str):
        # Type checker knows value is str here
        print(value.upper())
    else:
        # Type checker knows value is int here
        print(value + 1)
```

### Overload

`@overload` decorator provides multiple type signatures for a function:

```python
from typing import overload, Union

@overload
def process(value: int) -> str: ...

@overload
def process(value: str) -> int: ...

def process(value: Union[int, str]) -> Union[str, int]:
    if isinstance(value, int):
        return str(value)
    return len(value)
```

### Modern Syntax (Python 3.9+)

Python 3.9+ allows using built-in collection types directly:

```python
# Python 3.9+
def process_items(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}

# Instead of:
from typing import List, Dict
def process_items(items: List[str]) -> Dict[str, int]:
    return {item: len(item) for item in items}
```

Python 3.10+ introduced the `|` operator for unions:

```python
# Python 3.10+
def get_value(key: str) -> int | None:
    return None

# Instead of:
from typing import Optional
def get_value(key: str) -> Optional[int]:
    return None
```

### Best Practices

Type hints are optional and don't affect runtime behavior. They serve as documentation and enable static type checking. Use them to clarify complex APIs, catch bugs early with type checkers, and improve IDE autocompletion and refactoring capabilities.

### ParamSpec and Concatenate

`ParamSpec` (Python 3.10+) captures the parameters of a callable, useful for decorators:

```python
from typing import ParamSpec, TypeVar, Callable

P = ParamSpec('P')
R = TypeVar('R')

def log_call(func: Callable[P, R]) -> Callable[P, R]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@log_call
def greet(name: str, age: int) -> str:
    return f"Hello {name}, you are {age}"
```

`Concatenate` allows adding parameters to a callable's signature:

```python
from typing import Concatenate, ParamSpec, TypeVar, Callable

P = ParamSpec('P')
R = TypeVar('R')

class Request:
    pass

def with_request(func: Callable[Concatenate[Request, P], R]) -> Callable[P, R]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        request = Request()
        return func(request, *args, **kwargs)
    return wrapper

@with_request
def handle(request: Request, user_id: int) -> str:
    return f"Handling request for user {user_id}"
```

### Self Type

`Self` (Python 3.11+) refers to the enclosing class, useful for methods that return instances:

```python
from typing import Self

class Builder:
    def __init__(self) -> None:
        self.value = 0
    
    def add(self, x: int) -> Self:
        self.value += x
        return self
    
    def multiply(self, x: int) -> Self:
        self.value *= x
        return self

# Enables method chaining with correct types
result = Builder().add(5).multiply(2)
```

### TypeGuard and TypeIs

`TypeGuard` (Python 3.10+) defines user-defined type guards:

```python
from typing import TypeGuard

def is_string_list(val: list[object]) -> TypeGuard[list[str]]:
    return all(isinstance(x, str) for x in val)

def process(items: list[object]) -> None:
    if is_string_list(items):
        # Type checker knows items is list[str] here
        print([s.upper() for s in items])
```

`TypeIs` (Python 3.13+) is a more precise version that narrows types in both branches:

```python
from typing import TypeIs

def is_str(val: str | int) -> TypeIs[str]:
    return isinstance(val, str)

def process(val: str | int) -> None:
    if is_str(val):
        # val is str
        print(val.upper())
    else:
        # val is int (TypeIs narrows the else branch too)
        print(val + 1)
```

### Never and NoReturn

`NoReturn` indicates a function never returns (always raises or loops forever):

```python
from typing import NoReturn

def raise_error(message: str) -> NoReturn:
    raise ValueError(message)

def infinite_loop() -> NoReturn:
    while True:
        pass
```

`Never` (Python 3.11+) represents the bottom type (no possible values):

```python
from typing import Never, assert_never

def handle_value(value: int | str) -> str:
    if isinstance(value, int):
        return str(value)
    elif isinstance(value, str):
        return value
    else:
        # Ensures all cases are handled
        assert_never(value)
```

### ClassVar

`ClassVar` indicates a class variable (not an instance variable):

```python
from typing import ClassVar

class Config:
    MAX_CONNECTIONS: ClassVar[int] = 100
    
    def __init__(self, name: str) -> None:
        self.name = name  # Instance variable
```

### Final

`Final` indicates a value that should not be reassigned:

```python
from typing import Final

MAX_SIZE: Final = 100
# MAX_SIZE = 200  # Type checker error

class Config:
    DEFAULT_TIMEOUT: Final[int] = 30
```

`@final` decorator prevents subclassing or overriding:

```python
from typing import final

@final
class FinalClass:
    pass

# class SubClass(FinalClass):  # Type checker error
#     pass

class BaseClass:
    @final
    def method(self) -> None:
        pass

class Derived(BaseClass):
    # def method(self) -> None:  # Type checker error
    #     pass
    pass
```

### Annotated

`Annotated` adds metadata to types:

```python
from typing import Annotated

# Add validation metadata
UserId = Annotated[int, "positive", "must be unique"]
Email = Annotated[str, "valid email format"]

def create_user(user_id: UserId, email: Email) -> None:
    pass
```

### Required and NotRequired

`Required` and `NotRequired` (Python 3.11+) mark TypedDict fields:

```python
from typing import TypedDict, Required, NotRequired

class User(TypedDict):
    name: Required[str]
    age: Required[int]
    email: NotRequired[str]  # Optional field

user1: User = {"name": "Alice", "age": 30}  # OK
user2: User = {"name": "Bob", "age": 25, "email": "bob@example.com"}  # OK
```

### Unpack

`Unpack` (Python 3.11+) unpacks TypedDict or tuple types:

```python
from typing import TypedDict, Unpack

class Person(TypedDict):
    name: str
    age: int

def create_person(**kwargs: Unpack[Person]) -> None:
    print(kwargs)

create_person(name="Alice", age=30)  # OK
# create_person(name="Bob")  # Type checker error - missing 'age'
```

### Mapping and Sequence Protocols

Abstract types for read-only collections:

```python
from typing import Mapping, Sequence

def print_items(items: Sequence[str]) -> None:
    # Works with lists, tuples, etc.
    for item in items:
        print(item)

def print_dict(data: Mapping[str, int]) -> None:
    # Works with dicts and other mappings
    for key, value in data.items():
        print(f"{key}: {value}")
```

### MutableMapping and MutableSequence

For collections that can be modified:

```python
from typing import MutableMapping, MutableSequence

def modify_list(items: MutableSequence[int]) -> None:
    items.append(42)
    items[0] = 100

def modify_dict(data: MutableMapping[str, int]) -> None:
    data["new_key"] = 123
    del data["old_key"]
```

### Iterable, Iterator, and Generator

Types for iteration protocols:

```python
from typing import Iterable, Iterator, Generator

def process_items(items: Iterable[int]) -> None:
    for item in items:
        print(item)

def count_up() -> Iterator[int]:
    n = 0
    while True:
        yield n
        n += 1

def fibonacci() -> Generator[int, None, None]:
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b
```

Generator type has three parameters: `Generator[YieldType, SendType, ReturnType]`

```python
from typing import Generator

def echo() -> Generator[int, str, bool]:
    value = yield 42  # Yields int
    print(f"Received: {value}")  # Receives str
    return True  # Returns bool
```

### ContextManager

Type for context manager protocol:

```python
from typing import ContextManager
from contextlib import contextmanager

@contextmanager
def get_resource() -> Generator[str, None, None]:
    resource = "acquired"
    try:
        yield resource
    finally:
        print("released")

def use_resource(cm: ContextManager[str]) -> None:
    with cm as resource:
        print(resource)
```

### Type Aliases with TypeAlias

`TypeAlias` (Python 3.10+) explicitly marks type aliases:

```python
from typing import TypeAlias

# Without TypeAlias (ambiguous)
Vector = list[float]  # Is this a type alias or a variable?

# With TypeAlias (explicit)
Vector: TypeAlias = list[float]
Matrix: TypeAlias = list[Vector]

def add_vectors(v1: Vector, v2: Vector) -> Vector:
    return [a + b for a, b in zip(v1, v2)]
```

### Generic Type Aliases

Create generic type aliases with TypeVar:

```python
from typing import TypeVar, TypeAlias

T = TypeVar('T')

# Generic type alias
Container: TypeAlias = list[T] | dict[str, T]

def process_container(c: Container[int]) -> None:
    pass
```

### Covariant and Contravariant TypeVars

TypeVars can be covariant or contravariant for proper subtyping:

```python
from typing import TypeVar, Generic

# Covariant (T_co)
T_co = TypeVar('T_co', covariant=True)

class Producer(Generic[T_co]):
    def produce(self) -> T_co:
        ...

# Animal -> Dog subtyping preserved
# Producer[Dog] is subtype of Producer[Animal]

# Contravariant (T_contra)
T_contra = TypeVar('T_contra', contravariant=True)

class Consumer(Generic[T_contra]):
    def consume(self, item: T_contra) -> None:
        ...

# Animal -> Dog subtyping reversed
# Consumer[Animal] is subtype of Consumer[Dog]
```

### Abstract Base Classes with typing

Combine ABC with typing for abstract generic classes:

```python
from typing import TypeVar, Generic
from abc import ABC, abstractmethod

T = TypeVar('T')

class Repository(ABC, Generic[T]):
    @abstractmethod
    def get(self, id: int) -> T:
        pass
    
    @abstractmethod
    def save(self, item: T) -> None:
        pass

class UserRepository(Repository[str]):
    def get(self, id: int) -> str:
        return f"User {id}"
    
    def save(self, item: str) -> None:
        print(f"Saving {item}")
```

### Runtime Type Checking Limitations

Type hints are not enforced at runtime by Python itself:

```python
def add(x: int, y: int) -> int:
    return x + y

# This runs without error at runtime
result = add("hello", "world")  # Returns "helloworld"
```

For runtime checking, use libraries like `typeguard` or `pydantic`:

```python
from pydantic import BaseModel, ValidationError

class User(BaseModel):
    name: str
    age: int

try:
    user = User(name="Alice", age="not a number")
except ValidationError as e:
    print(e)  # Validation error at runtime
```

### get_type_hints

`get_type_hints()` retrieves annotations at runtime:

```python
from typing import get_type_hints

def greet(name: str, age: int) -> str:
    return f"Hello {name}"

hints = get_type_hints(greet)
print(hints)  # {'name': <class 'str'>, 'age': <class 'int'>, 'return': <class 'str'>}
```

### TYPE_CHECKING Constant

`TYPE_CHECKING` is `False` at runtime, `True` during type checking (prevents circular imports):

```python
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    # Only imported during type checking, not at runtime
    from expensive_module import ExpensiveClass

def process(obj: 'ExpensiveClass') -> None:  # Forward reference as string
    pass
```

### Forward References

Use string literals for forward references:

```python
class Node:
    def __init__(self, value: int, next: 'Node | None' = None) -> None:
        self.value = value
        self.next = next
```

Python 3.7+ supports `from __future__ import annotations` to make all annotations strings by default:

```python
from __future__ import annotations

class Node:
    def __init__(self, value: int, next: Node | None = None) -> None:
        self.value = value
        self.next = next
```

This covers the comprehensive functionality of the `typing` module through Python 3.13.

---

## `inspect` Module

The `inspect` module provides functions for introspecting live Python objects, including modules, classes, methods, functions, tracebacks, frame objects, and code objects.

### Core Purpose

The module helps you examine the source code, signatures, and internal structure of Python objects at runtime. It's particularly useful for debugging, documentation generation, testing frameworks, and building developer tools.

### Getting Object Information

You can retrieve various types of information about Python objects:

**Type Checking**
- `inspect.ismodule()`, `inspect.isclass()`, `inspect.ismethod()`, `inspect.isfunction()` - Check object types
- `inspect.isbuiltin()`, `inspect.isroutine()` - Identify built-in and callable objects
- `inspect.isgeneratorfunction()`, `inspect.iscoroutinefunction()` - Check for special function types

**Source Code Access**
- `inspect.getsource(object)` - Returns the source code of an object as a string
- `inspect.getsourcelines(object)` - Returns a tuple of (source lines list, starting line number)
- `inspect.getfile(object)` - Returns the file path where an object is defined
- `inspect.getmodule(object)` - Returns the module an object belongs to

### Function Signatures

The module provides detailed signature inspection:

```python
import inspect

def example(a, b=10, *args, **kwargs):
    pass

sig = inspect.signature(example)
# sig contains parameter names, defaults, annotations, etc.

for param_name, param in sig.parameters.items():
    print(f"{param_name}: {param.kind}, default={param.default}")
```

The `Signature` object contains `Parameter` objects with attributes like `name`, `default`, `annotation`, and `kind` (POSITIONAL_OR_KEYWORD, VAR_POSITIONAL, KEYWORD_ONLY, etc.).

#### `inspect.signature` vs `get_type_hints`

##### Core Purpose

**`get_type_hints()`** (from `typing` module):
- Returns a dictionary mapping parameter names to their **resolved type annotations**
- Evaluates forward references and string annotations
- Processes `from __future__ import annotations`

**`inspect.signature()`** (from `inspect` module):
- Returns a `Signature` object with detailed metadata about function parameters
- Provides **raw annotations** without evaluation
- Includes parameter kinds (positional, keyword, etc.) and default values

##### Key Differences

###### 1. Return Type
```python
from typing import get_type_hints
import inspect

def example(x: int, y: str = "hello") -> bool:
    return True

# get_type_hints returns dict
hints = get_type_hints(example)
# {'x': <class 'int'>, 'y': <class 'str'>, 'return': <class 'bool'>}

# inspect.signature returns Signature object
sig = inspect.signature(example)
# <Signature (x: int, y: str = 'hello') -> bool>
```

###### 2. Forward Reference Handling
```python
def func(x: "MyClass") -> "MyClass":
    pass

# get_type_hints() evaluates string annotations
hints = get_type_hints(func)  # Attempts to resolve "MyClass"

# inspect.signature() keeps raw strings
sig = inspect.signature(func)
sig.parameters['x'].annotation  # Returns the string "MyClass"
```

###### 3. Information Provided

`get_type_hints()` only gives you:
- Type annotations
- Return type annotation

`inspect.signature()` gives you:
- Type annotations (raw)
- Default values
- Parameter kinds (`POSITIONAL_ONLY`, `POSITIONAL_OR_KEYWORD`, `VAR_POSITIONAL`, `KEYWORD_ONLY`, `VAR_KEYWORD`)
- Parameter order

###### 4. Usage Example
```python
def process(a: int, b: int = 5, *args: str, key: bool = True, **kwargs: float) -> None:
    pass

# With get_type_hints
hints = get_type_hints(process)
# {'a': int, 'b': int, 'args': str, 'key': bool, 'kwargs': float, 'return': None}

# With inspect.signature
sig = inspect.signature(process)
for name, param in sig.parameters.items():
    print(f"{name}: kind={param.kind}, default={param.default}, annotation={param.annotation}")
```

##### When to Use Each

**Use `get_type_hints()`** when:
- You need resolved type annotations for type checking
- Working with forward references
- Building type validation systems
- You only care about types, not parameter details

**Use `inspect.signature()`** when:
- You need parameter metadata (defaults, kinds)
- Building function wrappers or decorators
- Generating documentation
- You need the raw, unevaluated annotations
- Working with function introspection tools

##### Combined Usage
They're often used together:
```python
sig = inspect.signature(func)
hints = get_type_hints(func)

for name, param in sig.parameters.items():
    param_type = hints.get(name)
    default = param.default
    # Now you have both resolved type and default value
```

### Class Inspection

You can examine class hierarchies and members:

- `inspect.getmembers(object)` - Returns all members as (name, value) pairs
- `inspect.getmro(class)` - Returns the method resolution order tuple
- `inspect.getclasstree(classes)` - Arranges classes into a hierarchy

### Stack and Frame Inspection

The module allows you to examine the call stack:

- `inspect.currentframe()` - Returns the current stack frame
- `inspect.stack()` - Returns a list of frame records for the caller's stack
- `inspect.getframeinfo(frame)` - Extracts information from a frame object

Each frame record contains the frame object, filename, line number, function name, context lines, and context index.

### Practical Use Cases

The inspect module is commonly used in:

- **Testing frameworks** - To discover test methods and examine function signatures
- **Documentation tools** - To extract docstrings and signatures automatically
- **Decorators** - To preserve or examine wrapped function metadata
- **Debugging tools** - To examine the call stack and local variables
- **Serialization** - To understand object structure before pickling
- **API introspection** - To validate function calls or generate API documentation

### Important Limitations

[Inference] The module cannot retrieve source code for built-in functions written in C, objects defined in the interactive interpreter without saving to a file, or dynamically generated code that wasn't properly associated with source. [Inference] It also cannot access source for objects whose source files are no longer available or have been modified since the module was imported.

### Frame Objects

Frame objects represent execution frames in Python's call stack. Each time a function is called, Python creates a frame object that contains all the runtime information for that function's execution.

**What a Frame Contains**

A frame object holds:
- Local variables for the current function (`frame.f_locals`)
- Global variables accessible to the frame (`frame.f_globals`)
- Built-in namespace (`frame.f_builtins`)
- The code object being executed (`frame.f_code`)
- The previous frame in the stack (`frame.f_back`)
- Current line number being executed (`frame.f_lineno`)
- Last instruction executed (`frame.f_lasti`)

**Accessing Frames**

```python
import inspect
import sys

def inner():
    frame = inspect.currentframe()
    print(f"Function: {frame.f_code.co_name}")
    print(f"Local vars: {frame.f_locals}")
    print(f"Line number: {frame.f_lineno}")

def outer():
    x = 42
    inner()

outer()
```

You can also use `sys._getframe(n)` where n is the number of stack levels to go back (0 is current frame, 1 is caller, etc.).

**Frame Lifecycle**

Frames are created when functions are called and typically destroyed when functions return. However, if you keep a reference to a frame object, it can create reference cycles and prevent garbage collection of that frame's local variables.

### Code Objects

Code objects contain the compiled bytecode and metadata for executable Python code blocks (functions, methods, classes, modules, etc.). They're created by Python's compiler and are immutable.

**What a Code Object Contains**

Key attributes include:
- `co_name` - Name of the function/class/module
- `co_filename` - File where the code was defined
- `co_firstlineno` - First line number in the source
- `co_argcount` - Number of positional arguments
- `co_kwonlyargcount` - Number of keyword-only arguments
- `co_nlocals` - Number of local variables
- `co_varnames` - Tuple of local variable names
- `co_code` - The actual bytecode as bytes
- `co_consts` - Tuple of constants used in the bytecode
- `co_names` - Tuple of names used in the bytecode

**Accessing Code Objects**

```python
def example(a, b=10):
    x = a + b
    return x

code = example.__code__
print(f"Name: {code.co_name}")
print(f"Arg count: {code.co_argcount}")
print(f"Local vars: {code.co_varnames}")
print(f"Filename: {code.co_filename}")
```

**Bytecode Inspection**

You can examine the compiled bytecode using the `dis` module:

```python
import dis

def add(x, y):
    return x + y

dis.dis(add)
# Shows the bytecode instructions
```

### Relationship Between Frame and Code Objects

Every frame object has a code object (`frame.f_code`) that defines what code the frame is executing. Multiple frames can reference the same code object if the same function is called multiple times (recursively or from different places).

Think of it this way:
- **Code object** = The recipe (static, immutable, shared)
- **Frame object** = The kitchen workspace with ingredients (dynamic, per-execution, unique)

### Practical Applications

**Debugging and Profiling**

Debuggers like `pdb` use frame objects to inspect local variables and step through code. Profilers use frame information to track function calls and execution time.

**Stack Traces**

When exceptions occur, Python walks the frame stack to build traceback information. Each traceback entry corresponds to a frame.

**Dynamic Code Inspection**

```python
def get_caller_info():
    frame = inspect.currentframe().f_back
    return {
        'function': frame.f_code.co_name,
        'filename': frame.f_code.co_filename,
        'line': frame.f_lineno,
        'locals': frame.f_locals
    }
```

**Code Modification**

[Unverified] While code objects themselves are immutable, tools can create new code objects with modified bytecode for advanced metaprogramming, though this is fragile and version-dependent.

### Memory Considerations

Frame objects can create memory leaks if you're not careful. [Inference] When you store a reference to a frame object, it keeps all its local variables alive, and through `f_back`, it can keep the entire call stack alive. It's good practice to explicitly delete frame references when done:

```python
frame = inspect.currentframe()
try:
    # use frame
    pass
finally:
    del frame
```

## `abc` Module

The `abc` module in Python provides infrastructure for defining Abstract Base Classes (ABCs). It's part of the standard library and is used to create interfaces and enforce that derived classes implement particular methods.

### What Are Abstract Base Classes?

Abstract Base Classes are classes that contain one or more abstract methods. An abstract method is a method declared but contains no implementation. ABCs cannot be instantiated directly and must be subclassed with concrete implementations of their abstract methods.

### Key Components

**ABC Class**
The `ABC` class is a helper class that has `ABCMeta` as its metaclass. You can create an abstract base class by inheriting from `ABC`:

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self):
        pass
```

**ABCMeta Metaclass**
This is the metaclass used for defining Abstract Base Classes. You can use it explicitly:

```python
from abc import ABCMeta, abstractmethod

class Shape(metaclass=ABCMeta):
    @abstractmethod
    def area(self):
        pass
```

**@abstractmethod Decorator**
This decorator marks a method as abstract, requiring subclasses to provide an implementation:

```python
from abc import ABC, abstractmethod

class Animal(ABC):
    @abstractmethod
    def make_sound(self):
        pass

class Dog(Animal):
    def make_sound(self):
        return "Woof!"
```

### Common Decorators

**@abstractmethod**
The most basic decorator for defining abstract methods.

**@abstractproperty** (deprecated in Python 3.3+)
Previously used for abstract properties. Now you combine `@property` with `@abstractmethod`:

```python
from abc import ABC, abstractmethod

class MyClass(ABC):
    @property
    @abstractmethod
    def my_property(self):
        pass
```

**Combining with @staticmethod and @classmethod**
Abstract methods can also be static or class methods:

```python
from abc import ABC, abstractmethod

class MyClass(ABC):
    @classmethod
    @abstractmethod
    def my_classmethod(cls):
        pass
    
    @staticmethod
    @abstractmethod
    def my_staticmethod():
        pass
```

### Virtual Subclasses

The `abc` module allows you to register a class as a "virtual subclass" of an ABC without actually inheriting from it:

```python
from abc import ABC

class MyABC(ABC):
    pass

class MyClass:
    pass

MyABC.register(MyClass)

print(issubclass(MyClass, MyABC))  # True
print(isinstance(MyClass(), MyABC))  # True
```

### Practical Example

```python
from abc import ABC, abstractmethod

class Database(ABC):
    @abstractmethod
    def connect(self):
        pass
    
    @abstractmethod
    def disconnect(self):
        pass
    
    @abstractmethod
    def execute_query(self, query):
        pass

class PostgreSQL(Database):
    def connect(self):
        print("Connecting to PostgreSQL")
    
    def disconnect(self):
        print("Disconnecting from PostgreSQL")
    
    def execute_query(self, query):
        print(f"Executing: {query}")

# This would work
db = PostgreSQL()

# This would raise TypeError
# db = Database()  # Can't instantiate abstract class
```

### When to Use ABCs

ABCs are useful when you want to:
- Define a common interface for a group of subclasses
- Enforce that certain methods are implemented by subclasses
- Use duck typing with formal interfaces
- Create plugin systems or frameworks where third-party code needs to follow specific protocols

### Other Useful Functions

**get_cache_token()**
Returns the current ABC cache token.

**update_abstractmethods(cls, method_names)**
Recalculates the abstract methods of a class.

The `abc` module is a powerful tool for creating well-structured, maintainable object-oriented code in Python by enforcing interface contracts through abstract base classes.

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


---

## Weak References

### What is a Weak Reference in Python?

A **weak reference** lets you refer to an object **without increasing its reference count**. This means the object can still be garbage-collected even if weak references to it exist.

**Why use weak references?**

* Avoid **memory leaks** in large object graphs.
* Useful in caching and memoization.
* Prevent objects from being kept alive just because some “helper” object references them.

---

### How to Use `weakref`

The `weakref` module provides tools for weak references.

#### Example — Basic Weak Reference

```python
import weakref

class MyClass:
    pass

obj = MyClass()

# Create a weak reference
weak_obj = weakref.ref(obj)

# Call the weak reference to get the object back
print(weak_obj())      # <__main__.MyClass object at 0x...>

# Delete the original object
del obj

# Now the weak reference returns None
print(weak_obj())      # None
```

---

### `weakref` in Collections

If you want to keep a **collection** of weak references, use:

* `weakref.WeakSet` — for a set of weak references
* `weakref.WeakKeyDictionary` — keys are weak references
* `weakref.WeakValueDictionary` — values are weak references

---

#### Example — WeakValueDictionary

A cache that auto-clears items when values are garbage collected:

```python
import weakref

class Data:
    def __init__(self, name):
        self.name = name

cache = weakref.WeakValueDictionary()

d = Data("example")

cache["item"] = d

print(cache["item"].name)  # example

del d

# Now the object is gone
print(cache.get("item"))   # None
```

---

### Weak Reference Callbacks

Weak references can register a **callback** that runs when the object is about to be finalized:

```python
import weakref

class MyClass:
    pass

def on_finalize(wr):
    print("Object has been garbage-collected!")

obj = MyClass()
wr = weakref.ref(obj, on_finalize)

del obj
# prints: Object has been garbage-collected!
```

---

### Why Not Just Use Normal References?

Normal references keep objects alive. For instance:

```python
refs = []
obj = MyClass()
refs.append(obj)
# obj will never be freed as long as refs points to it
```

A weak reference avoids that problem.

---

**Summary:**

* Weak references don’t increase an object’s ref count.
* Object can still be garbage-collected.
* Useful for caches and memory-sensitive structures.
* Provided by Python’s `weakref` module.

---

I'll explain Python's five parameter kinds that `inspect.signature()` uses to classify function parameters.

## The Five Parameter Kinds

### 1. POSITIONAL_ONLY
Parameters that can **only** be passed by position, not by keyword.

```python
def func(a, b, /):  # "/" marks end of positional-only params
    return a + b

func(1, 2)        # ✓ Valid
func(a=1, b=2)    # ✗ TypeError: got some positional-only arguments passed as keyword
```

**Inspection:**
```python
import inspect

sig = inspect.signature(func)
for name, param in sig.parameters.items():
    print(f"{name}: {param.kind}")
# a: POSITIONAL_ONLY
# b: POSITIONAL_ONLY
```

### 2. POSITIONAL_OR_KEYWORD
Parameters that can be passed **either** by position or by keyword. This is the default.

```python
def func(a, b):
    return a + b

func(1, 2)        # ✓ Valid - positional
func(a=1, b=2)    # ✓ Valid - keyword
func(1, b=2)      # ✓ Valid - mixed
```

**Inspection:**
```python
sig = inspect.signature(func)
for name, param in sig.parameters.items():
    print(f"{name}: {param.kind}")
# a: POSITIONAL_OR_KEYWORD
# b: POSITIONAL_OR_KEYWORD
```

### 3. VAR_POSITIONAL
Captures excess positional arguments (the `*args` parameter).

```python
def func(*args):
    return args

func(1, 2, 3)     # Returns (1, 2, 3)
```

**Inspection:**
```python
sig = inspect.signature(func)
for name, param in sig.parameters.items():
    print(f"{name}: {param.kind}")
# args: VAR_POSITIONAL
```

### 4. KEYWORD_ONLY
Parameters that can **only** be passed by keyword, not by position.

```python
def func(*, a, b):  # "*" marks start of keyword-only params
    return a + b

func(a=1, b=2)    # ✓ Valid
func(1, 2)        # ✗ TypeError: takes 0 positional arguments but 2 were given
```

**Also applies after `*args`:**
```python
def func(*args, key):
    return args, key

func(1, 2, key=3)   # ✓ Valid: (1, 2), 3
func(1, 2, 3)       # ✗ TypeError: missing required keyword-only argument
```

**Inspection:**
```python
sig = inspect.signature(func)
for name, param in sig.parameters.items():
    print(f"{name}: {param.kind}")
# a: KEYWORD_ONLY
# b: KEYWORD_ONLY
```

### 5. VAR_KEYWORD
Captures excess keyword arguments (the `**kwargs` parameter).

```python
def func(**kwargs):
    return kwargs

func(a=1, b=2, c=3)  # Returns {'a': 1, 'b': 2, 'c': 3}
```

**Inspection:**
```python
sig = inspect.signature(func)
for name, param in sig.parameters.items():
    print(f"{name}: {param.kind}")
# kwargs: VAR_KEYWORD
```

### Complete Example: All Five Kinds

```python
def complete(pos_only, /,           # POSITIONAL_ONLY
             pos_or_kw,             # POSITIONAL_OR_KEYWORD
             *args,                 # VAR_POSITIONAL
             kw_only,               # KEYWORD_ONLY
             **kwargs):             # VAR_KEYWORD
    pass

# Valid call:
complete(1, 2, 3, 4, kw_only=5, extra=6)
```

**Inspection:**
```python
import inspect

sig = inspect.signature(complete)
for name, param in sig.parameters.items():
    print(f"{name:12} {param.kind}")

# Output:
# pos_only     Parameter.POSITIONAL_ONLY
# pos_or_kw    Parameter.POSITIONAL_OR_KEYWORD
# args         Parameter.VAR_POSITIONAL
# kw_only      Parameter.KEYWORD_ONLY
# kwargs       Parameter.VAR_KEYWORD
```

### Parameter Ordering Rules

Python enforces this strict order:
1. `POSITIONAL_ONLY` parameters
2. `POSITIONAL_OR_KEYWORD` parameters
3. `VAR_POSITIONAL` (`*args`)
4. `KEYWORD_ONLY` parameters
5. `VAR_KEYWORD` (`**kwargs`)

```python
# ✓ Valid ordering
def valid(a, /, b, *args, c, **kwargs):
    pass

# ✗ Invalid - keyword-only before positional
def invalid(*, a, b):  # SyntaxError if you try to add positional params after
    pass
```

### Practical Usage: Checking Parameter Kinds

```python
import inspect

def analyze_function(func):
    sig = inspect.signature(func)
    
    for name, param in sig.parameters.items():
        kind_name = str(param.kind).split('.')[-1]
        default = f"= {param.default}" if param.default != inspect.Parameter.empty else ""
        annotation = f": {param.annotation}" if param.annotation != inspect.Parameter.empty else ""
        
        print(f"{name}{annotation} {default} [{kind_name}]")

def example(a, /, b, *args, key=None, **kwargs):
    pass

analyze_function(example)
# Output:
# a [POSITIONAL_ONLY]
# b [POSITIONAL_OR_KEYWORD]
# args [VAR_POSITIONAL]
# key = None [KEYWORD_ONLY]
# kwargs [VAR_KEYWORD]
```

### Why This Matters

Understanding parameter kinds is essential for:
- **Building decorators** that preserve function signatures
- **Creating function wrappers** that forward arguments correctly
- **Generating documentation** that accurately describes how to call functions
- **Implementing dynamic dispatch** systems
- **Type checking and validation** tools

---

