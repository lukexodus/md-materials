## Methods (Instance, Class, and Static Methods)  


### **Instance Methods**  
- These methods operate on the instance of the class (object).  
- They always take the instance as the first argument (`self`).  
- Instance methods can access and modify instance variables and class variables.

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def greet(self):  # Instance method
        return f"Hello, my name is {self.name} and I am {self.age} years old."

# Creating an instance
person = Person("Alice", 25)
print(person.greet())  # Hello, my name is Alice and I am 25 years old.
```

### **Class Methods**  
- These methods operate on the class itself, not on instances.  
- They take the class as the first argument (`cls`).  
- Class methods are often used to modify or interact with class-level variables and can be called on the class itself or an instance.

```python
class Person:
    species = "Human"  # Class variable

    def __init__(self, name, age):
        self.name = name
        self.age = age

    @classmethod
    def species_info(cls):  # Class method
        return f"All persons are {cls.species}."

# Using class method
print(Person.species_info())  # All persons are Human

person = Person("Alice", 25)
print(person.species_info())  # All persons are Human
```

### **Static Methods**  
- These methods do not operate on the instance or the class.  
- They do not take `self` or `cls` as the first argument.  
- Static methods are used for utility functions that don't modify or depend on the class or instance variables.

```python
class MathOperations:
    
    @staticmethod
    def add(x, y):  # Static method
        return x + y

    @staticmethod
    def multiply(x, y):  # Static method
        return x * y

# Using static methods
print(MathOperations.add(5, 3))  # 8
print(MathOperations.multiply(5, 3))  # 15
```

**Key Points**  
- **Instance methods**: Use `self` to access and modify instance attributes and call other methods in the instance.  
- **Class methods**: Use `cls` to access and modify class attributes, often for creating alternate constructors or modifying class state.  
- **Static methods**: Do not take `self` or `cls`; used for functions that do not require access to instance or class data.

---

