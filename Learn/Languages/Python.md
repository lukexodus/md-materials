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
