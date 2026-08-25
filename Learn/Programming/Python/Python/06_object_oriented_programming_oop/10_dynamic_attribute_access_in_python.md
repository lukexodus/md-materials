## Dynamic Attribute Access in Python


Python provides several ways to access object attributes dynamically at runtime, rather than using hardcoded attribute names.

### The `getattr()` Function

The most common method is `getattr()`, which retrieves an attribute by name:

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

person = Person("Alice", 30)

# Static access
print(person.name)  # "Alice"

# Dynamic access
attr_name = "name"
print(getattr(person, attr_name))  # "Alice"

# With default value if attribute doesn't exist
print(getattr(person, "salary", 0))  # 0
```

### The `__dict__` Attribute

Every Python object has a `__dict__` attribute containing its attributes as a dictionary:

```python
person = Person("Bob", 25)
print(person.__dict__)  # {'name': 'Bob', 'age': 25}

# Access dynamically
attr_name = "age"
print(person.__dict__[attr_name])  # 25
```

### The `setattr()` Function

To set attributes dynamically:

```python
person = Person("Carol", 28)
setattr(person, "salary", 50000)
print(person.salary)  # 50000

# Dynamically set multiple attributes
attributes = {"city": "New York", "title": "Engineer"}
for key, value in attributes.items():
    setattr(person, key, value)
```

### The `hasattr()` Function

Check if an attribute exists before accessing it:

```python
if hasattr(person, "name"):
    print(getattr(person, "name"))
```

### The `delattr()` Function

Remove attributes dynamically:

```python
delattr(person, "city")
# or
del person.city
```

### Practical Use Cases

Dynamic attribute access is useful for:

- Processing configuration data where attribute names come from external sources
- Building flexible APIs that handle varying attribute sets
- Implementing attribute-based routing or dispatching
- Working with JSON or database records where field names are dynamic
- Creating generic utility functions that work with multiple object types

### Security Considerations

When using dynamic attribute access with user-provided input, validate the attribute names to prevent unauthorized access to internal attributes or methods.

---

