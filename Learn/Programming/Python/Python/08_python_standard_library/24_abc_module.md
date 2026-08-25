## `abc` Module


The `abc` module in Python provides infrastructure for defining Abstract Base Classes (ABCs). It's part of the standard library and is used to create interfaces and enforce that derived classes implement particular methods.

### What Are Abstract Base Classes?

Abstract Base Classes are classes that contain one or more abstract methods. An abstract method is a method declared but contains no implementation. ABCs cannot be instantiated directly and must be subclassed with concrete implementations of their abstract methods.

### Key Components

**ABC Class**
The `ABC` class is a helper class that has `ABCMeta` as its metaclass. You can create an abstract base class by inheriting from `ABC`:

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self):
        pass
```

**ABCMeta Metaclass**
This is the metaclass used for defining Abstract Base Classes. You can use it explicitly:

```python
from abc import ABCMeta, abstractmethod

class Shape(metaclass=ABCMeta):
    @abstractmethod
    def area(self):
        pass
```

**@abstractmethod Decorator**
This decorator marks a method as abstract, requiring subclasses to provide an implementation:

```python
from abc import ABC, abstractmethod

class Animal(ABC):
    @abstractmethod
    def make_sound(self):
        pass

class Dog(Animal):
    def make_sound(self):
        return "Woof!"
```

### Common Decorators

**@abstractmethod**
The most basic decorator for defining abstract methods.

**@abstractproperty** (deprecated in Python 3.3+)
Previously used for abstract properties. Now you combine `@property` with `@abstractmethod`:

```python
from abc import ABC, abstractmethod

class MyClass(ABC):
    @property
    @abstractmethod
    def my_property(self):
        pass
```

**Combining with @staticmethod and @classmethod**
Abstract methods can also be static or class methods:

```python
from abc import ABC, abstractmethod

class MyClass(ABC):
    @classmethod
    @abstractmethod
    def my_classmethod(cls):
        pass
    
    @staticmethod
    @abstractmethod
    def my_staticmethod():
        pass
```

### Virtual Subclasses

The `abc` module allows you to register a class as a "virtual subclass" of an ABC without actually inheriting from it:

```python
from abc import ABC

class MyABC(ABC):
    pass

class MyClass:
    pass

MyABC.register(MyClass)

print(issubclass(MyClass, MyABC))  # True
print(isinstance(MyClass(), MyABC))  # True
```

### Practical Example

```python
from abc import ABC, abstractmethod

class Database(ABC):
    @abstractmethod
    def connect(self):
        pass
    
    @abstractmethod
    def disconnect(self):
        pass
    
    @abstractmethod
    def execute_query(self, query):
        pass

class PostgreSQL(Database):
    def connect(self):
        print("Connecting to PostgreSQL")
    
    def disconnect(self):
        print("Disconnecting from PostgreSQL")
    
    def execute_query(self, query):
        print(f"Executing: {query}")

# This would work
db = PostgreSQL()

# This would raise TypeError
# db = Database()  # Can't instantiate abstract class
```

### When to Use ABCs

ABCs are useful when you want to:
- Define a common interface for a group of subclasses
- Enforce that certain methods are implemented by subclasses
- Use duck typing with formal interfaces
- Create plugin systems or frameworks where third-party code needs to follow specific protocols

### Other Useful Functions

**get_cache_token()**
Returns the current ABC cache token.

**update_abstractmethods(cls, method_names)**
Recalculates the abstract methods of a class.

The `abc` module is a powerful tool for creating well-structured, maintainable object-oriented code in Python by enforcing interface contracts through abstract base classes.

---

