## Lambda Functions  


Lambda functions are anonymous, single-expression functions defined using the `lambda` keyword. They are often used for short, simple operations where defining a full function is unnecessary.  

### **Syntax**  
```python
lambda arguments: expression
```
- Can take multiple arguments but only one expression.  
- The expression is evaluated and returned automatically.  

### **Basic Example**  
```python
square = lambda x: x**2
print(square(5))  # Output: 25
```

### **Multiple Arguments**  
```python
add = lambda a, b: a + b
print(add(3, 4))  # Output: 7
```

### **Lambda with `map()`**  
`map()` applies a function to each item in an iterable.  
```python
numbers = [1, 2, 3, 4]
squared = list(map(lambda x: x**2, numbers))
print(squared)  # Output: [1, 4, 9, 16]
```

### **Lambda with `filter()`**  
`filter()` selects elements that satisfy a condition.  
```python
numbers = [1, 2, 3, 4, 5, 6]
evens = list(filter(lambda x: x % 2 == 0, numbers))
print(evens)  # Output: [2, 4, 6]
```

### **Lambda with `sorted()`**  
Used for custom sorting.  
```python
students = [("Alice", 25), ("Bob", 20), ("Charlie", 23)]
sorted_students = sorted(students, key=lambda x: x[1])
print(sorted_students)  # Output: [('Bob', 20), ('Charlie', 23), ('Alice', 25)]
```

### **Lambda in `reduce()`**  
`reduce()` from `functools` applies a function cumulatively.  
```python
from functools import reduce
numbers = [1, 2, 3, 4]
product = reduce(lambda x, y: x * y, numbers)
print(product)  # Output: 24
```

**Key Points**  
- **Lambda functions are anonymous and concise.**  
- **Used for short operations where defining a function is unnecessary.**  
- **Commonly used with `map()`, `filter()`, `sorted()`, and `reduce()`.**  
- **Cannot contain multiple expressions or statements.**

---

