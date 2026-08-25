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

