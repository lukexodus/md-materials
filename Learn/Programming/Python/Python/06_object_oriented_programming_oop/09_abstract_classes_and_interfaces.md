## Abstract Classes and Interfaces  


### **Abstract Classes**  
An **abstract class** is a class that **cannot be instantiated** and serves as a blueprint for other classes. It defines a common interface for its subclasses and may contain **abstract methods** (methods that must be implemented by derived classes).  

In Python, abstract classes are defined using the `ABC` (Abstract Base Class) module.  

#### **Defining an Abstract Class**  
- Use `ABC` from the `abc` module to define an abstract class.  
- Use `@abstractmethod` to declare abstract methods that subclasses **must** implement.  

```python
from abc import ABC, abstractmethod

class Animal(ABC):  # Abstract class
    @abstractmethod
    def make_sound(self):  # Abstract method
        pass
```

#### **Implementing an Abstract Class**  
A subclass **must implement all abstract methods** from the abstract class; otherwise, it cannot be instantiated.  

```python
class Dog(Animal):
    def make_sound(self):  # Implementing the abstract method
        return "Woof!"

class Cat(Animal):
    def make_sound(self):
        return "Meow!"

dog = Dog()
cat = Cat()
print(dog.make_sound())  # Woof!
print(cat.make_sound())  # Meow!
```

#### **Abstract Class with Concrete Methods**  
Abstract classes can also contain **concrete methods** (regular methods with implementations).  

```python
class Vehicle(ABC):
    def __init__(self, name):
        self.name = name

    @abstractmethod
    def start_engine(self):
        pass  # Abstract method

    def describe(self):  # Concrete method
        return f"This is a {self.name}."

class Car(Vehicle):
    def start_engine(self):
        return "Car engine started."

car = Car("Sedan")
print(car.start_engine())  # Car engine started.
print(car.describe())  # This is a Sedan.
```

### **Interfaces in Python**  
Python **does not** have built-in interfaces like Java or C++, but interfaces can be simulated using **abstract classes with only abstract methods**.  

#### **Defining an Interface**  
- An interface is an abstract class where **all methods are abstract** (no concrete methods).  

```python
from abc import ABC, abstractmethod

class Shape(ABC):  # Interface
    @abstractmethod
    def area(self):
        pass

    @abstractmethod
    def perimeter(self):
        pass
```

#### **Implementing an Interface**  
A class implementing the interface must define all abstract methods.  

```python
class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return 3.14 * self.radius ** 2

    def perimeter(self):
        return 2 * 3.14 * self.radius

circle = Circle(5)
print(circle.area())  # 78.5
print(circle.perimeter())  # 31.4
```

### **Multiple Interfaces**  
Python allows a class to implement multiple interfaces by inheriting from multiple abstract classes.  

```python
class Printable(ABC):
    @abstractmethod
    def print_details(self):
        pass

class Savable(ABC):
    @abstractmethod
    def save(self):
        pass

class Document(Printable, Savable):
    def print_details(self):
        return "Printing document."

    def save(self):
        return "Saving document."

doc = Document()
print(doc.print_details())  # Printing document.
print(doc.save())  # Saving document.
```

**Key Points**  
- **Abstract Classes**: Cannot be instantiated, may contain both abstract and concrete methods.  
- **Abstract Methods**: Declared with `@abstractmethod`, must be implemented by subclasses.  
- **Interfaces**: Can be simulated using abstract classes with only abstract methods.  
- **Multiple Inheritance**: A class can implement multiple interfaces in Python.

---

