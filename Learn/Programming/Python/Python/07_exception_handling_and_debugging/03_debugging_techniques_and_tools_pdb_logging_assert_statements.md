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

