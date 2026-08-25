## Magic Methods  


Magic methods (also called dunder methods, due to their double underscores) are special methods in Python that allow you to define how objects of a class behave when they interact with built-in operators or functions. These methods are predefined in Python and provide a way to implement operator overloading, object comparison, object representation, and other custom behaviors.

### **`__init__(self)`**  
- The **constructor** method, automatically called when an object is instantiated.  
- Used to initialize the object's attributes.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

obj = MyClass(10)
print(obj.value)  # 10
```

### **`__str__(self)`**  
- The `__str__` method returns a string representation of the object.  
- Used by the `str()` function and when printing an object.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return f"MyClass with value {self.value}"

obj = MyClass(10)
print(str(obj))  # MyClass with value 10
```

### **`__repr__(self)`**  
- The `__repr__` method returns a string that represents the object in a way that could potentially be used to recreate the object (often more detailed than `__str__`).  
- Used by the `repr()` function and for object representation in interactive interpreters.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __repr__(self):
        return f"MyClass({self.value})"

obj = MyClass(10)
print(repr(obj))  # MyClass(10)
```

### **`__format__(self, format_spec)`**

- The `__format__` method allows you to define custom formatting behavior for the object when using the `format()` function or `f-string`.
- It is often used to control how an object is displayed or converted to a string.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __format__(self, format_spec):  # Custom formatting
        return f"Value: {self.value:{format_spec}}"

obj = MyClass(10)
print(format(obj, "04d"))  # Value: 0010
```

### **`__add__(self, other)`**  
- The `__add__` method allows you to define the behavior of the `+` operator for your objects.  
- It is called when you use the `+` operator between two objects of the class.

```python
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, other):  # Overloading '+' operator
        return Point(self.x + other.x, self.y + other.y)

    def __repr__(self):
        return f"Point({self.x}, {self.y})"

point1 = Point(1, 2)
point2 = Point(3, 4)
result = point1 + point2
print(result)  # Point(4, 6)
```

### **`__eq__(self, other)`**  
- The `__eq__` method allows you to define the behavior of the equality operator (`==`).  
- It is called when you use `==` to compare two objects of the class.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __eq__(self, other):  # Overloading '==' operator
        return self.value == other.value

obj1 = MyClass(10)
obj2 = MyClass(10)
print(obj1 == obj2)  # True
```

### **`__ne__(self, other)`**

- The `__ne__` method defines the behavior for the inequality operator `!=`.
- It is used to compare objects for inequality and should return `True` if they are considered unequal, otherwise `False`.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __ne__(self, other):  # Comparing inequality
        if isinstance(other, MyClass):
            return self.value != other.value
        return True

obj1 = MyClass(10)
obj2 = MyClass(20)

print(obj1 != obj2)  # True
```

### **`__lt__(self, other)`**  
- The `__lt__` method allows you to define the behavior of the less than operator (`<`).  
- It is called when you use `<` to compare two objects of the class.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __lt__(self, other):  # Overloading '<' operator
        return self.value < other.value

obj1 = MyClass(5)
obj2 = MyClass(10)
print(obj1 < obj2)  # True
```

### **`__le__(self, other)`**

- The `__le__` method defines the behavior for the less-than-or-equal-to operator `<=`.
- It is used to compare objects for "less than or equal to."

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __le__(self, other):  # Less-than-or-equal-to comparison
        if isinstance(other, MyClass):
            return self.value <= other.value
        return NotImplemented

obj1 = MyClass(10)
obj2 = MyClass(20)

print(obj1 <= obj2)  # True
```

### **`__gt__(self, other)`**

- The `__gt__` method defines the behavior for the greater-than operator `>`.
- It is used to compare two objects for "greater than."

### **`__ge__(self, other)`**

- The `__ge__` method defines the behavior for the greater-than-or-equal-to operator `>=`.
- It is used to compare objects for "greater than or equal to."

### **`__len__(self)`**  
- The `__len__` method defines the behavior of the `len()` function.  
- It returns the length of the object.

```python
class MyClass:
    def __init__(self, values):
        self.values = values

    def __len__(self):  # Overloading len() function
        return len(self.values)

obj = MyClass([1, 2, 3, 4])
print(len(obj))  # 4
```

### **`__getitem__(self, key)`**  
- The `__getitem__` method allows you to define how items are accessed using square brackets `[]`.  
- It is called when you use the indexing operator (`[]`) to get an item from the object.

```python
class MyClass:
    def __init__(self, values):
        self.values = values

    def __getitem__(self, key):  # Overloading '[]' operator
        return self.values[key]

obj = MyClass([10, 20, 30])
print(obj[1])  # 20
```

### **`__setitem__(self, key, value)`**  
- The `__setitem__` method allows you to define how items are set using square brackets `[]`.  
- It is called when you use the indexing operator (`[]`) to assign a value to an item in the object.

```python
class MyClass:
    def __init__(self, values):
        self.values = values

    def __setitem__(self, key, value):  # Overloading '[]' assignment
        self.values[key] = value

obj = MyClass([1, 2, 3])
obj[1] = 10
print(obj.values)  # [1, 10, 3]
```

### **`__delitem__(self, key)`**  
- The `__delitem__` method allows you to define the behavior of the `del` operator when trying to delete an item from an object using square brackets `[]`.  
- It is called when `del` is used to remove an item from an object.

```python
class MyClass:
    def __init__(self, values):
        self.values = values

    def __delitem__(self, key):  # Overloading 'del' operator
        del self.values[key]

obj = MyClass([1, 2, 3])
del obj[1]
print(obj.values)  # [1, 3]
```

### **`__del__(self)`**  
- The `__del__` method is called when an object is about to be destroyed.  
- It is used for cleanup actions like closing files or releasing resources.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __del__(self):  # Destructor
        print(f"MyClass object with value {self.value} is being deleted.")

obj = MyClass(10)
del obj  # MyClass object with value 10 is being deleted.
```

### **`__call__(self, *args, **kwargs)`**  
- The `__call__` method allows an object of a class to be called as if it were a function.  
- It enables an object to behave like a function, accepting arguments and returning a value.

```python
class MyClass:
    def __init__(self, multiplier):
        self.multiplier = multiplier

    def __call__(self, value):
        return self.multiplier * value

obj = MyClass(5)
print(obj(10))  # 50 (calling the object like a function)
```

### **`__contains__(self, item)`**  
- The `__contains__` method allows you to define the behavior of the `in` operator for checking membership.  
- It is called when you use `in` to check if an item exists in the object.

```python
class MyClass:
    def __init__(self, values):
        self.values = values

    def __contains__(self, item):  # Overloading 'in' operator
        return item in self.values

obj = MyClass([1, 2, 3, 4])
print(3 in obj)  # True
print(5 in obj)  # False
```

### **`__iter__(self)`**  
- The `__iter__` method is used to make an object iterable (i.e., able to be used in a for-loop).  
- It returns an iterator object that defines the `__next__` method.

```python
class MyClass:
    def __init__(self, values):
        self.values = values
        self.index = 0

    def __iter__(self):  # Making object iterable
        return self

    def __next__(self):
        if self.index < len(self.values):
            result = self.values[self.index]
            self.index += 1
            return result
        else:
            raise StopIteration

obj = MyClass([1, 2, 3])
for val in obj:
    print(val)  # 1, 2, 3
```

### **`__next__(self)`**  
- The `__next__` method works with `__iter__` to allow iteration.  
- It retrieves the next item from an iterable object and raises `StopIteration` when the iteration is complete.

```python
class MyClass:
    def __init__(self, values):
        self.values = values
        self.index = 0

    def __iter__(self):  # Making object iterable
        return self

    def __next__(self):
        if self.index < len(self.values):
            result = self.values[self.index]
            self.index += 1
            return result
        else:
            raise StopIteration

obj = MyClass([1, 2, 3])
iterator = iter(obj)
print(next(iterator))  # 1
print(next(iterator))  # 2
print(next(iterator))  # 3
# print(next(iterator))  # Raises StopIteration
```

### **`__setattr__(self, name, value)`**  
- The `__setattr__` method is called when an attribute is being set.  
- It allows you to customize the assignment of attributes in an object.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __setattr__(self, name, value):  # Overloading attribute assignment
        if name == 'value' and value < 0:
            print("Cannot set value to a negative number!")
        else:
            super().__setattr__(name, value)

obj = MyClass(10)
obj.value = -5  # Cannot set value to a negative number!
obj.value = 20  # Attribute set successfully
```

The `super()` function is used to call methods from a parent class. When overriding the `__setattr__` method, it's necessary to call `super().__setattr__(name, value)` to ensure that the base class's `__setattr__` method (usually the one from `object`) is still invoked and the attribute is properly set.

Without `super()`, the custom `__setattr__` method would handle attribute assignment but would not update the actual object’s attributes, which could lead to incomplete or incorrect behavior.

- **Attribute Assignment**: The `__setattr__` method in Python intercepts every attempt to set an attribute. If you don’t call the parent’s `__setattr__` method, the attribute won’t actually be set in the object.
- **Preventing Infinite Recursion**: If you manually set an attribute within `__setattr__`, and if you don’t call `super().__setattr__`, you’ll trigger `__setattr__` again, causing infinite recursion. By calling `super()`, you ensure that the base class's logic for setting attributes is correctly executed.
- **Customizing Behavior**: Using `super()` allows you to customize the behavior (like validating values) while ensuring the default behavior (actually assigning the attribute) is still executed.

### **`__getattr__(self, name)`**  
- The `__getattr__` method is called when an attribute is accessed that doesn't exist in the object.  
- It provides a way to define default values or dynamic attribute handling.

```python
class MyClass:
    def __getattr__(self, name):  # Handling missing attributes
        if name == 'name':
            return "Unknown"
        else:
            return f"{name} not found"

obj = MyClass()
print(obj.name)  # Unknown
print(obj.age)   # age not found
```

### **`__enter__(self)` and `__exit__(self)`**  
- The `__enter__` and `__exit__` methods are used for context management (with the `with` statement).  
- `__enter__` is called when entering the context, and `__exit__` is called when exiting the context.

```python
class MyClass:
    def __enter__(self):
        print("Entering the context")
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        print("Exiting the context")

with MyClass() as obj:
    print("Inside the context")
```

#### `__exit__` Parameters:
- **`exc_type`**: The type of exception that was raised inside the `with` block, or `None` if no exception occurred.
- **`exc_val`**: The actual exception instance, or `None` if no exception occurred.
- **`exc_tb`**: A traceback object for the exception, or `None` if no exception occurred.
#### `__exit__` Return Value:
- **`None`** (or any value other than `None` to suppress the exception):
    - If it returns `None`, any exception that occurred inside the `with` block is propagated outside.
    - If it returns a value (e.g., `True`), it suppresses the exception, preventing it from being propagated.

```python
class MyContext:
    def __enter__(self):
        print("Entering the context")
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        print("Exiting the context")
        if exc_type:
            print(f"An exception occurred: {exc_val}")
        else:
            print("No exception occurred")
        # Returning True suppresses the exception
        return True

# Using the context manager with an exception inside the block
with MyContext() as obj:
    print("Inside the context")
    raise ValueError("An error occurred")

# Output:
# Entering the context
# Inside the context
# Exiting the context
# An exception occurred: An error occurred
```

### **`__bool__(self)` and `__nonzero__(self)`**  
- The `__bool__` method is used to define the truth value of an object (whether it evaluates to `True` or `False`).  
- In Python 2, `__nonzero__` is used for the same purpose.

```python
class MyClass:
    def __init__(self, value):
        self.value = value

    def __bool__(self):  # Overloading boolean context
        return self.value != 0

obj1 = MyClass(10)
obj2 = MyClass(0)

print(bool(obj1))  # True
print(bool(obj2))  # False
```

### **`__copy__(self)` and `__deepcopy__(self)`**

- The `__copy__` method defines the behavior of copying an object using the `copy.copy()` function.
- The `__deepcopy__` method is used to handle deep copying of objects, allowing nested objects to be copied recursively.

```python
import copy

class MyClass:
    def __init__(self, values):
        self.values = values

    def __copy__(self):  # Shallow copy
        return MyClass(self.values)

    def __deepcopy__(self, memo):  # Deep copy
        values_copy = copy.deepcopy(self.values, memo)
        return MyClass(values_copy)

obj = MyClass([1, 2, 3])
shallow_copy = copy.copy(obj)
deep_copy = copy.deepcopy(obj)

print(shallow_copy.values)  # [1, 2, 3]
print(deep_copy.values)  # [1, 2, 3]
```

### **`__aenter__(self)` and `__aexit__(self, exc_type, exc_value, traceback)`**

- The `__aenter__` and `__aexit__` methods define the behavior for asynchronous context managers, similar to `__enter__` and `__exit__`.
- These are used for async operations inside a `with` block.

```python
class MyClass:
    async def __aenter__(self):  # Async setup for context
        print("Entering the async context")
        return self

    async def __aexit__(self, exc_type, exc_value, traceback):  # Async cleanup
        print("Exiting the async context")

# Usage within an asynchronous function
import asyncio

async def main():
    async with MyClass() as obj:
        print("Inside the async context")

asyncio.run(main())  # Entering the async context, Inside the async context, Exiting the async context
```

---

