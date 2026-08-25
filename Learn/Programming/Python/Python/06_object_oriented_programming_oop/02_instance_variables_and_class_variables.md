## Instance Variables and Class Variables  


### **Instance Variables**  
- Defined inside the constructor (`__init__`) using `self`.  
- Unique to each instance of the class.  
- Changing an instance variable affects only that specific object.  

```python
class Person:
    def __init__(self, name, age):
        self.name = name  # Instance variable
        self.age = age    # Instance variable

person1 = Person("Alice", 25)
person2 = Person("Bob", 30)

print(person1.name, person1.age)  # Alice 25
print(person2.name, person2.age)  # Bob 30

person1.age = 26  # Modifies only person1's age
print(person1.age)  # 26
print(person2.age)  # 30
```

### **Class Variables**  
- Defined outside `__init__`, at the class level.  
- Shared among all instances of the class.  
- Changing a class variable affects all instances (unless overridden by an instance).  

```python
class Car:
    wheels = 4  # Class variable (shared)

    def __init__(self, brand):
        self.brand = brand  # Instance variable

car1 = Car("Toyota")
car2 = Car("Honda")

print(car1.wheels, car1.brand)  # 4 Toyota
print(car2.wheels, car2.brand)  # 4 Honda

Car.wheels = 6  # Modifies the class variable
print(car1.wheels)  # 6
print(car2.wheels)  # 6
```

### **Overriding Class Variables with Instance Variables**  
If an instance assigns a new value to a class variable, it creates a separate instance variable instead of modifying the class variable.  

```python
car1.wheels = 5  # Creates an instance variable for car1 only
print(car1.wheels)  # 5
print(car2.wheels)  # 6 (still using the class variable)
```

### **Accessing Class Variables Using Class Methods**  
Class methods (`@classmethod`) can modify class variables.  

```python
class Employee:
    company = "TechCorp"  # Class variable

    def __init__(self, name):
        self.name = name  # Instance variable

    @classmethod
    def change_company(cls, new_company):
        cls.company = new_company  # Modify class variable

Employee.change_company("NewTech")  # Changes for all instances
emp1 = Employee("Alice")
emp2 = Employee("Bob")

print(emp1.company)  # NewTech
print(emp2.company)  # NewTech
```

**Key Points**  
- **Instance variables** are unique to each object (`self.var`).  
- **Class variables** are shared across all instances (`ClassName.var`).  
- Changing a class variable affects all instances unless overridden at the instance level.  
- **Class methods** (`@classmethod`) modify class variables for all instances.

---

