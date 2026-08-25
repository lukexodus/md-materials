## Inheritance and Method Overriding  


### **Inheritance**  
Inheritance allows a class to inherit attributes and methods from another class. This promotes code reuse and a hierarchical relationship between classes. A subclass (child class) can inherit from a superclass (parent class) and extend or modify its behavior.

- A **child class** can inherit methods and attributes from a **parent class**.
- It can also override or add new methods to extend the functionality.

```python
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):  # Method in parent class
        return "Animal sound"

class Dog(Animal):  # Inheriting from Animal class
    def __init__(self, name, breed):
        super().__init__(name)  # Calling parent constructor
        self.breed = breed

    def speak(self):  # Method overriding
        return f"{self.name} says Woof!"

# Creating an instance of the child class
dog = Dog("Buddy", "Golden Retriever")
print(dog.speak())  # Buddy says Woof!
```

### **Using `super()` in Inheritance**  
The `super()` function is used to call a method from the parent class. It is commonly used in the constructor to initialize attributes from the parent class.

```python
class Person:
    def __init__(self, name):
        self.name = name

class Employee(Person):
    def __init__(self, name, job):
        super().__init__(name)  # Call parent constructor
        self.job = job

emp = Employee("John", "Software Developer")
print(emp.name)  # John
print(emp.job)  # Software Developer
```

### **Method Overriding**  
Method overriding occurs when a child class provides a specific implementation for a method that is already defined in the parent class. This allows the child class to alter or extend the behavior of the parent class.

```python
class Animal:
    def speak(self):
        return "Some sound"

class Cat(Animal):
    def speak(self):  # Overriding parent method
        return "Meow"

class Dog(Animal):
    def speak(self):  # Overriding parent method
        return "Woof"

# Creating instances
cat = Cat()
dog = Dog()

print(cat.speak())  # Meow
print(dog.speak())  # Woof
```

### **Overriding Methods with Arguments**  
You can override methods and change their implementation, including how they handle parameters. However, the method signature (name and arguments) should match the parent class method unless you are designing it differently.

```python
class Animal:
    def make_sound(self, sound="generic sound"):
        return f"Animal makes a {sound}"

class Dog(Animal):
    def make_sound(self, sound="bark"):
        return f"Dog barks: {sound}"

# Creating an instance
dog = Dog()
print(dog.make_sound())  # Dog barks: bark
print(dog.make_sound("growl"))  # Dog barks: growl
```

**Key Points**  
- **Inheritance**: Allows a child class to inherit attributes and methods from a parent class.
- **Method overriding**: The child class can override a method from the parent class to provide its own implementation.
- Use `super()` to call the parent class's methods or constructor from the child class.
- Method overriding enables a child class to customize the inherited behavior, making it more specific to the subclass's needs.

---

