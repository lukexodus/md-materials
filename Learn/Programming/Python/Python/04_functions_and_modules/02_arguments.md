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

