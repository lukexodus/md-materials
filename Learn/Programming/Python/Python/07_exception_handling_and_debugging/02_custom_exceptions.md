## Custom Exceptions  


### **What are Custom Exceptions?**  
Custom exceptions allow developers to define their own error types by extending Python's built-in `Exception` class. This helps in creating meaningful error messages and handling domain-specific errors.  

### **Defining a Custom Exception**  
To create a custom exception, define a class that inherits from `Exception`.  

```python
class CustomError(Exception):
    """A custom exception class."""
    pass

# Raising the custom exception
raise CustomError("This is a custom error")
```

### **Custom Exception with `__init__` for Custom Messages**  
A custom exception can accept additional parameters to provide more details.  

```python
class AgeError(Exception):
    """Exception raised for invalid age."""

    def __init__(self, age, message="Age must be 18 or above"):
        self.age = age
        self.message = message
        super().__init__(f"{message}. Provided age: {age}")

# Raising the custom exception
try:
    age = 16
    if age < 18:
        raise AgeError(age)
except AgeError as e:
    print(e)  # Output: Age must be 18 or above. Provided age: 16
```

### **Using Custom Exceptions in Functions**  
Custom exceptions can be used to validate inputs and enforce constraints.  

```python
class NegativeNumberError(Exception):
    """Exception raised when a negative number is encountered."""
    def __init__(self, number):
        super().__init__(f"Negative number not allowed: {number}")

def check_positive(number):
    if number < 0:
        raise NegativeNumberError(number)
    return f"Valid number: {number}"

try:
    print(check_positive(-5))
except NegativeNumberError as e:
    print(e)  # Negative number not allowed: -5
```

### **Creating a Hierarchy of Custom Exceptions**  
You can define multiple custom exceptions by inheriting from a base exception class.  

```python
class ApplicationError(Exception):
    """Base class for all application-related exceptions."""
    pass

class DatabaseError(ApplicationError):
    """Exception raised for database errors."""
    pass

class NetworkError(ApplicationError):
    """Exception raised for network issues."""
    pass

# Handling multiple custom exceptions
try:
    raise NetworkError("Network connection failed")
except ApplicationError as e:
    print(f"Application error occurred: {e}")  
```

**Key Points**  
- **Custom exceptions inherit from `Exception`** to create domain-specific errors.  
- **Use `__init__` to store additional information** for meaningful error messages.  
- **Custom exceptions improve code readability** by providing specific error handling.  
- **You can create an exception hierarchy** to categorize errors efficiently.  
- **Raising and handling custom exceptions** ensures proper error reporting and debugging.

---

