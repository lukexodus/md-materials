## Polymorphism and Encapsulation  


### **Polymorphism**  
Polymorphism is the ability of different classes to implement the same method or function in different ways. This allows objects of different types to be treated as instances of the same class through a shared interface.

- **Method Overloading**: Having multiple methods with the same name but different parameters.
- **Method Overriding**: Inheritance allows a subclass to override the method of a superclass, providing a different implementation.

#### **Method Overriding (Runtime Polymorphism)**  
Method overriding occurs when a subclass provides a specific implementation of a method that is already defined in the superclass.

```python
class Animal:
    def sound(self):
        return "Some generic sound"

class Dog(Animal):
    def sound(self):  # Overriding parent method
        return "Bark"

class Cat(Animal):
    def sound(self):  # Overriding parent method
        return "Meow"

# Polymorphic behavior
def make_sound(animal: Animal):
    print(animal.sound())

dog = Dog()
cat = Cat()

make_sound(dog)  # Bark
make_sound(cat)  # Meow
```

In the example above, the method `sound()` is overridden in both `Dog` and `Cat` classes, and the correct method is called based on the object type (`dog` or `cat`).

#### **Polymorphism with Inheritance**  
Polymorphism is commonly used with inheritance, where different subclasses can provide their own implementation of a common method from the base class.

```python
class Shape:
    def area(self):
        pass  # To be implemented by subclasses

class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return 3.14 * self.radius * self.radius

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height

    def area(self):
        return self.width * self.height

# Polymorphic behavior
shapes = [Circle(5), Rectangle(4, 6)]

for shape in shapes:
    print(f"Area: {shape.area()}")
```

In this case, the method `area()` is polymorphic, and different types of shapes (Circle and Rectangle) use their own implementation of the method.

### **Encapsulation**  
Encapsulation is the concept of bundling data (attributes) and methods (functions) that operate on the data into a single unit or class. It also restricts access to certain components of the object, meaning some internal details are hidden from the outside world. 

- **Public attributes/methods**: Accessible from outside the class.
- **Private attributes/methods**: Not directly accessible from outside the class (use of underscores or properties to hide implementation).

#### **Public and Private Members**  
In Python, by convention, a single underscore (`_`) before an attribute indicates that it is intended for internal use, but it is still accessible. A double underscore (`__`) makes the attribute private, which name-mangles it, making it harder to access directly.

```python
class Person:
    def __init__(self, name, age):
        self.name = name  # Public attribute
        self.__age = age  # Private attribute

    def get_age(self):  # Public method to access private data
        return self.__age

    def set_age(self, age):  # Public method to modify private data
        if age >= 0:
            self.__age = age
        else:
            print("Age cannot be negative.")

person = Person("Alice", 25)
print(person.name)  # Public attribute can be accessed
print(person.get_age())  # Accessing private attribute through public method

# person.__age  # This would raise an AttributeError due to name mangling
person.set_age(30)  # Setting a new valid age
print(person.get_age())  # 30
```

In the above example:
- `__age` is a private attribute, and it is not directly accessible from outside the class.  
- We use getter (`get_age()`) and setter (`set_age()`) methods to interact with it, ensuring that the age is valid.

#### **Encapsulation Using Properties**  
Instead of directly accessing attributes, we can use properties to control access to them. This allows us to define getter, setter, and deleter methods in a more Pythonic way.

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.__age = age

    @property
    def age(self):  # Getter
        return self.__age

    @age.setter
    def age(self, value):  # Setter
        if value >= 0:
            self.__age = value
        else:
            print("Age cannot be negative.")

    @age.deleter
    def age(self):  # Deleter
        print("Age deleted.")
        del self.__age

person = Person("Alice", 25)
print(person.age)  # 25 (getter)
person.age = 30  # Setting a new age (setter)
print(person.age)  # 30 (getter)

del person.age  # Age deleted. Attribute removed.
```

**Key Points**  
- **Polymorphism**: Allows methods with the same name to behave differently based on the object’s class. Achieved through method overriding.
- **Encapsulation**: Hides the internal state of an object and only exposes necessary functionality through public methods.  
- Use **getter/setter methods** or **properties** to manage access to private attributes.  
- **Polymorphism** and **encapsulation** work together to enhance flexibility and maintainability in object-oriented programming.

---

