## Lists  


### **Overview**  
A list is an ordered, mutable collection that allows storing multiple items in a single variable. Lists can hold elements of different data types.  

### **Creating Lists**  
```python
# Empty list
empty_list = []

# List with elements
fruits = ["apple", "banana", "cherry"]

# List with mixed data types
mixed = [1, "hello", 3.14, True]

# Using the list() constructor
numbers = list((1, 2, 3, 4))
```

### **Accessing Elements**  
```python
fruits = ["apple", "banana", "cherry"]
print(fruits[0])   # apple (first element)
print(fruits[-1])  # cherry (last element)
```

### **Slicing Lists**  
```python
numbers = [0, 1, 2, 3, 4, 5]
print(numbers[1:4])  # [1, 2, 3] (from index 1 to 3)
print(numbers[:3])   # [0, 1, 2] (from start to index 2)
print(numbers[::2])  # [0, 2, 4] (every second element)
```

### **Modifying Lists**  
```python
fruits[1] = "blueberry"  # Change an element
fruits.append("orange")  # Add an element at the end
fruits.insert(1, "grape")  # Insert at index 1
fruits.extend(["mango", "pineapple"])  # Add multiple elements
```

### **Removing Elements**  
```python
fruits.remove("banana")  # Remove by value
deleted_item = fruits.pop(2)  # Remove by index (returns removed item)
del fruits[0]  # Delete element at index 0
fruits.clear()  # Remove all elements
```

### **Looping Through Lists**  
```python
for fruit in fruits:
    print(fruit)

for i, fruit in enumerate(fruits):
    print(i, fruit)
```

### **Checking Membership**  
```python
print("apple" in fruits)  # True if "apple" exists in list
```

### **Sorting and Reversing**  
```python
numbers = [3, 1, 4, 1, 5]
numbers.sort()  # Sort in ascending order
numbers.sort(reverse=True)  # Sort in descending order
fruits.reverse()  # Reverse the list
```

### **List Comprehensions**  
```python
squares = [x**2 for x in range(5)]  # [0, 1, 4, 9, 16]
even_numbers = [x for x in range(10) if x % 2 == 0]  # [0, 2, 4, 6, 8]
```

### **Copying Lists**  
```python
copy1 = fruits.copy()  # Using copy()
copy2 = fruits[:]  # Using slicing
copy3 = list(fruits)  # Using list() constructor
```

### **List Methods**  
```python
fruits.count("apple")  # Count occurrences of "apple"
fruits.index("banana")  # Get index of "banana"
fruits.sort()  # Sort in place
fruits.reverse()  # Reverse in place
```

**Key Points**  
- Lists are mutable and can hold mixed data types.  
- Elements can be accessed via indexing and slicing.  
- Lists can be modified using `append()`, `insert()`, `extend()`, and element assignment.  
- Elements can be removed using `remove()`, `pop()`, `del`, and `clear()`.  
- Lists support iteration, sorting, reversing, and comprehensions.  
- Copying lists requires using `copy()`, slicing, or the `list()` constructor.

---

