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

