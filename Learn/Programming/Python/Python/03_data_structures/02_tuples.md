## Tuples  


### **Overview**  
A tuple is an ordered, immutable collection that can store multiple elements of different data types. Unlike lists, tuples cannot be modified after creation.  

### **Creating Tuples**  
```python
# Empty tuple
empty_tuple = ()

# Tuple with elements
fruits = ("apple", "banana", "cherry")

# Tuple with mixed data types
mixed = (1, "hello", 3.14, True)

# Single-element tuple (comma is required)
single_element = ("apple",)

# Using the tuple() constructor
numbers = tuple([1, 2, 3, 4])
```

### **Accessing Elements**  
```python
print(fruits[0])   # apple (first element)
print(fruits[-1])  # cherry (last element)
```

### **Slicing Tuples**  
```python
numbers = (0, 1, 2, 3, 4, 5)
print(numbers[1:4])  # (1, 2, 3)
print(numbers[:3])   # (0, 1, 2)
print(numbers[::2])  # (0, 2, 4)
```

### **Tuple Packing and Unpacking**  
```python
# Packing
person = ("Alice", 25, "Engineer")

# Unpacking
name, age, job = person
print(name)  # Alice
print(age)   # 25
print(job)   # Engineer
```

### **Looping Through Tuples**  
```python
for fruit in fruits:
    print(fruit)

for i, fruit in enumerate(fruits):
    print(i, fruit)
```

### **Checking Membership**  
```python
print("apple" in fruits)  # True if "apple" exists in tuple
```

### **Tuple Concatenation and Repetition**  
```python
new_tuple = fruits + ("mango", "pineapple")  # Concatenation
repeated = fruits * 2  # ('apple', 'banana', 'cherry', 'apple', 'banana', 'cherry')
```

### **Converting Between Tuples and Lists**  
```python
fruits_list = list(fruits)  # Convert tuple to list
fruits_tuple = tuple(fruits_list)  # Convert list back to tuple
```

### **Tuple Methods**  
```python
fruits.count("apple")  # Count occurrences of "apple"
fruits.index("banana")  # Get index of "banana"
```

**Key Points**  
- Tuples are immutable and ordered collections.  
- They support indexing, slicing, and unpacking.  
- Elements cannot be modified after creation.  
- Tuple concatenation and repetition create new tuples.  
- Membership checking and iteration are supported.  
- Tuples use less memory and are faster than lists for fixed data.

---

