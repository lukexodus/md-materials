## Type Hinting


### **Introduction to Type Hinting**

Type hinting in Python allows developers to specify the expected data types of function parameters and return values. While Python remains dynamically typed, type hints improve code readability, maintainability, and enable static type checking tools like `mypy`.

### **Basic Type Annotations**

Annotations are added using a colon (`:`) after a variable name and an arrow (`->`) for return types.

**Example:**

```python
def add(x: int, y: int) -> int:
    return x + y
```

### **Built-in Types in Type Hints**

- `int`, `float`, `str`, `bool`
- `list`, `tuple`, `set`, `dict`
- `None` for functions that do not return a value
    

**Example:**

```python
def greet(name: str) -> None:
    print(f"Hello, {name}!")
```

### **Using `typing` Module for Complex Types**

The `typing` module provides additional type hints for more complex structures.

#### Lists, Tuples, and Dictionaries

```python
from typing import List, Tuple, Dict

def process_numbers(numbers: List[int]) -> Tuple[int, int]:
    return min(numbers), max(numbers)

def get_student_scores() -> Dict[str, float]:
    return {"Alice": 90.5, "Bob": 85.0}
```

#### Optional and Union Types

`Optional[T]` is equivalent to `Union[T, None]`, meaning the value can be of type `T` or `None`.

```python
from typing import Optional, Union

def find_user(user_id: int) -> Optional[str]:
    return "User123" if user_id == 1 else None

def process_data(data: Union[int, float, str]) -> str:
    return str(data)
```

#### Any Type

`Any` can represent any data type, effectively disabling type checking.

```python
from typing import Any

def dynamic_function(value: Any) -> Any:
    return value
```

### **Callable and Function Type Hints**

Use `Callable` to specify that a parameter expects a function.

```python
from typing import Callable

def execute(func: Callable[[int, int], int], a: int, b: int) -> int:
    return func(a, b)

def multiply(x: int, y: int) -> int:
    return x * y

result = execute(multiply, 3, 4)  # Output: 12
```

### **Generics for Flexibility**

Generics allow defining functions that work with multiple types using `TypeVar`.

```python
from typing import TypeVar

T = TypeVar('T')

def get_first_element(elements: List[T]) -> T:
    return elements[0]

print(get_first_element([1, 2, 3]))  # Output: 1
print(get_first_element(["a", "b", "c"]))  # Output: "a"
```

### **Self-referencing and Class-based Type Hints**

Use forward declarations (`"ClassName"`) or `Type` for self-referencing types.

```python
from typing import Type

class Node:
    def __init__(self, value: int, next_node: "Node" = None) -> None:
        self.value = value
        self.next_node = next_node

def create_node(cls: Type[Node], value: int) -> Node:
    return cls(value)
```

**Key Points**
- Type hints improve readability but do not enforce types at runtime.
- Use `typing` for complex data structures (`List`, `Dict`, `Union`, etc.).
- `Optional[T]` represents `T` or `None`.
- `Callable` is used for function arguments.
- Generics (`TypeVar`) allow functions to work with multiple types.
- Forward declarations (`"ClassName"`) help reference a class within itself.

---

