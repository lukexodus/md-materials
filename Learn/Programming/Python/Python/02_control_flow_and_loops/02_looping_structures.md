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

