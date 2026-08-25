## Named Tuples


Named tuples are immutable sequence types where elements are accessible both by index and by named attributes. They combine the memory efficiency and performance of tuples with the readability and self-documentation of named fields, providing a lightweight alternative to full classes.

These structures work well for function return values with multiple components, small data records, and situations where you need both positional and named access patterns.

**Key Points:**

- Immutable by default—elements cannot be changed after creation
- Support both positional (`point[0]`) and named (`point.x`) access
- More memory-efficient than dictionaries
- Support tuple operations like unpacking and comparison
- Automatically generate useful methods like `_asdict()`, `_replace()`, and `_fields`

**Python example:**

```python
from collections import namedtuple

# Basic definition
Point = namedtuple('Point', ['x', 'y'])

p1 = Point(3, 4)
print(p1.x, p1.y)  # 3 4
print(p1[0], p1[1])  # 3 4

# Unpacking
x, y = p1

# Immutability
# p1.x = 5  # Raises AttributeError

# Creating updated copies
p2 = p1._replace(x=10)
print(p1)  # Point(x=3, y=4)
print(p2)  # Point(x=10, y=4)

# Converting to dictionary
print(p1._asdict())  # {'x': 3, 'y': 4}

# Default values
Point = namedtuple('Point', ['x', 'y'], defaults=[0, 0])
p3 = Point()  # Point(x=0, y=0)
```

**Function return values:**

```python
from collections import namedtuple
from typing import NamedTuple

# Old style
Result = namedtuple('Result', ['success', 'value', 'error'])

def divide(a, b):
    if b == 0:
        return Result(False, None, "Division by zero")
    return Result(True, a / b, None)

result = divide(10, 2)
if result.success:
    print(f"Result: {result.value}")
else:
    print(f"Error: {result.error}")

# Modern style with typing.NamedTuple (Python 3.6+)
class Result(NamedTuple):
    success: bool
    value: float | None
    error: str | None

def divide_typed(a: float, b: float) -> Result:
    if b == 0:
        return Result(False, None, "Division by zero")
    return Result(True, a / b, None)
```

**Complex data structures:**

```python
from typing import NamedTuple, List

class Address(NamedTuple):
    street: str
    city: str
    zip_code: str
    country: str = "USA"

class Person(NamedTuple):
    name: str
    age: int
    address: Address
    
    def with_address(self, address: Address) -> 'Person':
        return self._replace(address=address)
    
    def increment_age(self) -> 'Person':
        return self._replace(age=self.age + 1)

alice = Person(
    name="Alice",
    age=30,
    address=Address("123 Main St", "NYC", "10001")
)

# Update nested structure
new_address = alice.address._replace(city="Boston")
relocated = alice.with_address(new_address)

print(alice.address.city)      # NYC
print(relocated.address.city)  # Boston
```

**Pattern matching (Python 3.10+):**

```python
from typing import NamedTuple

class Point(NamedTuple):
    x: float
    y: float

class Circle(NamedTuple):
    center: Point
    radius: float

class Rectangle(NamedTuple):
    top_left: Point
    width: float
    height: float

def area(shape):
    match shape:
        case Circle(center, radius):
            return 3.14159 * radius ** 2
        case Rectangle(top_left, width, height):
            return width * height
        case _:
            return 0

circle = Circle(Point(0, 0), 5)
rect = Rectangle(Point(0, 0), 10, 20)

print(area(circle))  # 78.53975
print(area(rect))    # 200
```

**JavaScript/TypeScript approximation:**

```typescript
// TypeScript tuple with named elements
type Point = readonly [x: number, y: number];

const createPoint = (x: number, y: number): Point => [x, y] as const;

const p1: Point = createPoint(3, 4);
const [x, y] = p1;
console.log(x, y);  // 3 4

// More complex example
type Result<T, E> = readonly [success: boolean, value: T | null, error: E | null];

function divide(a: number, b: number): Result<number, string> {
    if (b === 0) {
        return [false, null, "Division by zero"] as const;
    }
    return [true, a / b, null] as const;
}

const [success, value, error] = divide(10, 2);
if (success) {
    console.log(`Result: ${value}`);
}
```

**Records and tuples (JavaScript proposal):**

```javascript
// Stage 2 proposal - not yet standard
const point = #{ x: 3, y: 4 };  // Record (immutable object)
const coords = #[3, 4];          // Tuple (immutable array)

// Deep immutability
const nested = #{
    user: #{
        name: "Alice",
        scores: #[95, 87, 92]
    }
};

// nested.user.name = "Bob";  // TypeError
```

**Considerations:**

- Named tuples are hashable and can be used as dictionary keys or set elements
- [Inference] Memory overhead is minimal compared to dictionaries (no per-instance dictionary)
- Positional access (`point[0]`) can reduce readability—use sparingly
- [Inference] Adding new fields breaks positional unpacking in existing code
- Work well for small, stable data structures with known fields

