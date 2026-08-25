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

