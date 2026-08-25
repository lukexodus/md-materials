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

