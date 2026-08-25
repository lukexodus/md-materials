## Dictionaries  


### **Overview**  
A dictionary is an unordered, mutable collection of key-value pairs. Keys must be unique and immutable (e.g., strings, numbers, or tuples), while values can be of any data type.  

### **Creating Dictionaries**  
```python
# Empty dictionary
empty_dict = {}

# Dictionary with key-value pairs
person = {"name": "Alice", "age": 25, "job": "Engineer"}

# Using dict() constructor
person2 = dict(name="Bob", age=30, job="Doctor")

# Dictionary with mixed keys
data = {1: "one", "two": 2, (3, 4): "tuple key"}
```

### **Accessing Values**  
```python
print(person["name"])  # Alice
print(person.get("age"))  # 25
print(person.get("salary", "Not available"))  # Default value if key is missing
```

### **Adding and Updating Values**  
```python
person["city"] = "New York"  # Add new key-value pair
person["age"] = 26  # Update existing value
```

### **Removing Key-Value Pairs**  
```python
del person["job"]  # Remove key-value pair
removed_value = person.pop("age")  # Remove and return value
person.clear()  # Remove all elements
```

### **Looping Through a Dictionary**  
```python
# Iterating through keys
for key in person:
    print(key, person[key])

# Iterating through key-value pairs
for key, value in person.items():
    print(key, value)
```

### **Dictionary Methods**  
```python
keys = person.keys()  # Get all keys
values = person.values()  # Get all values
items = person.items()  # Get all key-value pairs

person.update({"age": 27, "gender": "Female"})  # Update multiple keys
```

### **Dictionary Comprehensions**  
```python
squares = {x: x**2 for x in range(5)}  # {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}
```

**Key Points**  
- Dictionaries store key-value pairs and allow fast lookups.  
- Keys must be unique and immutable, while values can be any type.  
- Use `get()` for safe key access.  
- `update()` merges two dictionaries.  
- `items()`, `keys()`, and `values()` provide efficient access to dictionary contents.

---

