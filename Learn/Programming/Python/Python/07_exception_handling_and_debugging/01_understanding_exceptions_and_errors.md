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

