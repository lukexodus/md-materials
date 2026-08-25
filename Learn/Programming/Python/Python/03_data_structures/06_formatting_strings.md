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

