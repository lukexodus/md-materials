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

