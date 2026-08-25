## Recursion  


Recursion is a programming technique where a function calls itself to solve smaller instances of a problem. It is useful for problems that can be broken down into simpler subproblems, such as factorial calculation, Fibonacci sequence, and tree traversal.  

### **Base Case and Recursive Case**  
Every recursive function must have:  
- **Base case** – Stops the recursion when a condition is met.  
- **Recursive case** – The function calls itself with a smaller problem.  

### **Factorial Example**  
```python
def factorial(n):
    if n == 0:  # Base case
        return 1
    return n * factorial(n - 1)  # Recursive case

print(factorial(5))  # Output: 120
```

### **Fibonacci Sequence**  
```python
def fibonacci(n):
    if n <= 1:  # Base case
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)  # Recursive case

print(fibonacci(6))  # Output: 8
```

### **Sum of a List**  
```python
def list_sum(lst):
    if not lst:  # Base case: empty list
        return 0
    return lst[0] + list_sum(lst[1:])  # Recursive case

print(list_sum([1, 2, 3, 4, 5]))  # Output: 15
```

### **Binary Search (Recursive)**  
```python
def binary_search(arr, target, low, high):
    if low > high:  # Base case: target not found
        return -1
    mid = (low + high) // 2
    if arr[mid] == target:
        return mid
    elif arr[mid] > target:
        return binary_search(arr, target, low, mid - 1)  # Search left half
    else:
        return binary_search(arr, target, mid + 1, high)  # Search right half

numbers = [1, 3, 5, 7, 9, 11]
print(binary_search(numbers, 7, 0, len(numbers) - 1))  # Output: 3
```

### **Tree Traversal (Recursive DFS)**  
```python
class Node:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None

def inorder_traversal(root):
    if root:
        inorder_traversal(root.left)
        print(root.value, end=" ")
        inorder_traversal(root.right)

# Example tree
root = Node(10)
root.left = Node(5)
root.right = Node(15)
inorder_traversal(root)  # Output: 5 10 15
```

### **Tail Recursion**  
Tail recursion optimizes recursive calls by eliminating the need for additional stack frames.  
```python
def tail_factorial(n, accumulator=1):
    if n == 0:
        return accumulator
    return tail_factorial(n - 1, n * accumulator)

print(tail_factorial(5))  # Output: 120
```

**Key Points**  
- **Recursion is useful for problems that can be divided into smaller subproblems.**  
- **Every recursive function must have a base case to avoid infinite recursion.**  
- **Can be memory-intensive due to function call stack growth.**  
- **Tail recursion reduces stack usage but is not optimized by Python.**  
- **Common use cases include factorials, Fibonacci, binary search, and tree traversal.**

---

