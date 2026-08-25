## Classes and Objects  


Python is an object-oriented programming (OOP) language, where everything is an object. Classes define blueprints for creating objects.  

### **Defining a Class**  
A class is created using the `class` keyword.  

```python
class Person:
    def __init__(self, name, age):  # Constructor
        self.name = name
        self.age = age

    def greet(self):  # Method
        return f"Hello, my name is {self.name} and I am {self.age} years old."

# Creating an object
person1 = Person("Alice", 25)
print(person1.greet())
```

### **Instance and Class Attributes**  
- **Instance attributes** are unique to each object.  
- **Class attributes** are shared among all instances.  

```python
class Car:
    wheels = 4  # Class attribute

    def __init__(self, brand):
        self.brand = brand  # Instance attribute

car1 = Car("Toyota")
car2 = Car("Honda")

print(car1.wheels, car1.brand)  # 4 Toyota
print(car2.wheels, car2.brand)  # 4 Honda
```

### **Instance and Class Methods**  
- **Instance methods** (`self`) operate on instance attributes.  
- **Class methods** (`cls`) operate on class attributes.  
- **Static methods** do not depend on class or instance attributes.  

```python
class Animal:
    species = "Mammal"

    def __init__(self, name):
        self.name = name

    def instance_method(self):
        return f"{self.name} is a {self.species}"

    @classmethod
    def class_method(cls):
        return f"All are {cls.species}"

    @staticmethod
    def static_method():
        return "Animals exist."

print(Animal.class_method())
print(Animal.static_method())

animal = Animal("Dog")
print(animal.instance_method())
```

### **Encapsulation (Access Modifiers)**  
Python uses naming conventions for access control:  
- `_protected` – Can be accessed but not recommended.  
- `__private` – Name-mangled to prevent accidental access.  

```python
class BankAccount:
    def __init__(self, balance):
        self._balance = balance  # Protected
        self.__pin = "1234"  # Private

    def get_balance(self):
        return self._balance

account = BankAccount(1000)
print(account.get_balance())  # 1000
# print(account.__pin)  # AttributeError: Cannot access private variable
```

### **Inheritance**  
A child class inherits from a parent class.  

```python
class Vehicle:
    def __init__(self, brand):
        self.brand = brand

    def info(self):
        return f"This is a {self.brand}."

class Car(Vehicle):
    def __init__(self, brand, model):
        super().__init__(brand)  # Call parent constructor
        self.model = model

    def info(self):
        return f"This is a {self.brand} {self.model}."

car = Car("Toyota", "Camry")
print(car.info())
```

### **Method Overriding**  
A subclass can override a parent class method.  

```python
class Parent:
    def show(self):
        return "Parent method"

class Child(Parent):
    def show(self):
        return "Child method"

child = Child()
print(child.show())  # Child method
```

### **Polymorphism**  
Different classes can share the same method name but behave differently.  

```python
class Cat:
    def sound(self):
        return "Meow"

class Dog:
    def sound(self):
        return "Bark"

animals = [Cat(), Dog()]
for animal in animals:
    print(animal.sound())
```

**Key Points**  
- Classes define blueprints for objects.  
- Use `self` to refer to instance attributes.  
- Use `@classmethod` for class-wide methods and `@staticmethod` for independent functions.  
- `_protected` and `__private` control access levels.  
- Use `super()` to call parent methods in inheritance.  
- Polymorphism allows different objects to share method names.

---

