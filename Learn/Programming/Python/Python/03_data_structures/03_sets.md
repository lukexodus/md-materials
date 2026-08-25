## Sets  


### **Overview**  
A set is an unordered, mutable collection of unique elements. Sets do not allow duplicate values and do not support indexing or slicing.  

### **Creating Sets**  
```python
# Empty set (must use set(), not {})
empty_set = set()

# Set with elements
fruits = {"apple", "banana", "cherry"}

# Using the set() constructor
numbers = set([1, 2, 3, 4, 4, 2])  # {1, 2, 3, 4}
```

### **Adding and Removing Elements**  
```python
fruits.add("orange")  # Add a single element
fruits.update(["mango", "grape"])  # Add multiple elements

fruits.remove("banana")  # Remove; raises error if not found
fruits.discard("banana")  # Remove; does not raise an error
deleted = fruits.pop()  # Removes a random element
fruits.clear()  # Remove all elements
```

### **Set Operations**  
```python
A = {1, 2, 3, 4}
B = {3, 4, 5, 6}

# Union (A ∪ B)
print(A | B)  # {1, 2, 3, 4, 5, 6}

# Intersection (A ∩ B)
print(A & B)  # {3, 4}

# Difference (A - B)
print(A - B)  # {1, 2}

# Symmetric Difference (A Δ B)
print(A ^ B)  # {1, 2, 5, 6}
```

### **Checking Membership and Set Relations**  
```python
print(2 in A)  # True
print(A.issubset(B))  # False
print(A.issuperset(B))  # False
print(A.isdisjoint(B))  # False
```

### **Looping Through a Set**  
```python
for item in fruits:
    print(item)
```

### **Frozen Sets**  
A `frozenset` is an immutable version of a set.  
```python
immutable_set = frozenset([1, 2, 3, 4])
# immutable_set.add(5)  # This would raise an error
```

**Key Points**  
- Sets store unique, unordered elements.  
- They support mathematical operations like union, intersection, and difference.  
- Sets do not support indexing or slicing.  
- Use `frozenset` for immutable sets.

---

