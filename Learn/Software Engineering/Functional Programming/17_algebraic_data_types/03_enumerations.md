## Enumerations


Enumerations define a fixed set of named constants, representing a closed sum type where all possible values are known at compile time. They provide type-safe alternatives to string or integer constants.

**Basic Enumerations:**

```python
from enum import Enum

class Status(Enum):
    PENDING = 1
    APPROVED = 2
    REJECTED = 3
    CANCELLED = 4

# Usage
current_status = Status.PENDING

# Comparison
if current_status == Status.PENDING:
    print("Waiting for approval")

# Access value
print(current_status.value)  # 1

# Access name
print(current_status.name)   # "PENDING"

# Iteration
for status in Status:
    print(f"{status.name}: {status.value}")
```

**Auto-valued Enumerations:**

```python
from enum import Enum, auto

class Direction(Enum):
    NORTH = auto()  # 1
    SOUTH = auto()  # 2
    EAST = auto()   # 3
    WEST = auto()   # 4

# Custom auto values
class Priority(Enum):
    def _generate_next_value_(name, start, count, last_values):
        return count * 10
    
    LOW = auto()      # 0
    MEDIUM = auto()   # 10
    HIGH = auto()     # 20
    CRITICAL = auto() # 30
```

**String Enumerations:**

```python
from enum import Enum

class HttpMethod(Enum):
    GET = "GET"
    POST = "POST"
    PUT = "PUT"
    DELETE = "DELETE"
    PATCH = "PATCH"

method = HttpMethod.GET
print(method.value)  # "GET"

# Direct comparison with strings in match
def handle_request(method: HttpMethod) -> str:
    match method:
        case HttpMethod.GET:
            return "Fetching resource"
        case HttpMethod.POST:
            return "Creating resource"
        case HttpMethod.PUT:
            return "Updating resource"
        case HttpMethod.DELETE:
            return "Deleting resource"
        case HttpMethod.PATCH:
            return "Patching resource"
```

**Enumerations with Methods:**

```python
from enum import Enum

class Color(Enum):
    RED = (255, 0, 0)
    GREEN = (0, 255, 0)
    BLUE = (0, 0, 255)
    YELLOW = (255, 255, 0)
    
    def __init__(self, r: int, g: int, b: int):
        self.r = r
        self.g = g
        self.b = b
    
    def to_hex(self) -> str:
        return f"#{self.r:02x}{self.g:02x}{self.b:02x}"
    
    def brightness(self) -> float:
        return (self.r + self.g + self.b) / (3 * 255)

color = Color.RED
print(color.to_hex())      # "#ff0000"
print(color.brightness())  # 0.333...
```

**Enum with Behavior:**

```python
from enum import Enum
from typing import Callable

class Operation(Enum):
    ADD = "+"
    SUBTRACT = "-"
    MULTIPLY = "*"
    DIVIDE = "/"
    
    def apply(self, a: float, b: float) -> float:
        match self:
            case Operation.ADD:
                return a + b
            case Operation.SUBTRACT:
                return a - b
            case Operation.MULTIPLY:
                return a * b
            case Operation.DIVIDE:
                if b == 0:
                    raise ValueError("Division by zero")
                return a / b

result = Operation.ADD.apply(5, 3)      # 8
result = Operation.MULTIPLY.apply(4, 7) # 28
```

**Flag Enumerations:**

```python
from enum import Flag, auto

class Permission(Flag):
    READ = auto()     # 1
    WRITE = auto()    # 2
    EXECUTE = auto()  # 4
    DELETE = auto()   # 8

# Combining flags
user_perms = Permission.READ | Permission.WRITE
print(Permission.READ in user_perms)   # True
print(Permission.DELETE in user_perms) # False

# Checking multiple flags
if user_perms & (Permission.READ | Permission.WRITE):
    print("Can read and write")

# All flags
admin_perms = Permission.READ | Permission.WRITE | Permission.EXECUTE | Permission.DELETE

# Removing flags
restricted = admin_perms & ~Permission.DELETE
```

**IntFlag for Bitwise Operations:**

```python
from enum import IntFlag, auto

class FileMode(IntFlag):
    OWNER_READ = auto()    # 1
    OWNER_WRITE = auto()   # 2
    OWNER_EXECUTE = auto() # 4
    GROUP_READ = auto()    # 8
    GROUP_WRITE = auto()   # 16
    GROUP_EXECUTE = auto() # 32
    
    @classmethod
    def rwx_owner(cls) -> 'FileMode':
        return cls.OWNER_READ | cls.OWNER_WRITE | cls.OWNER_EXECUTE
    
    @classmethod
    def rx_group(cls) -> 'FileMode':
        return cls.GROUP_READ | cls.GROUP_EXECUTE

mode = FileMode.rwx_owner() | FileMode.rx_group()
print(bin(mode.value))  # Binary representation
```

**Enum Membership and Lookup:**

```python
from enum import Enum

class Season(Enum):
    SPRING = 1
    SUMMER = 2
    FALL = 3
    WINTER = 4

# Lookup by value
season = Season(2)  # SUMMER

# Lookup by name
season = Season['WINTER']  # WINTER

# Membership testing
print(Season.SPRING in Season)  # True

# Get all members
all_seasons = list(Season)

# Dictionary mapping
season_names = {s: s.name.title() for s in Season}
# {Season.SPRING: 'Spring', ...}
```

**Unique Enumeration Values:**

```python
from enum import Enum, unique

@unique
class ErrorCode(Enum):
    SUCCESS = 0
    NOT_FOUND = 404
    UNAUTHORIZED = 401
    INTERNAL_ERROR = 500
    # DUPLICATE = 404  # Would raise ValueError: duplicate values found

# Aliases (without @unique)
class Status(Enum):
    PENDING = 1
    WAITING = 1  # Alias for PENDING
    APPROVED = 2

print(Status.PENDING is Status.WAITING)  # True
```

**Enum Comparison:**

```python
from enum import Enum, IntEnum

class Priority(IntEnum):
    LOW = 1
    MEDIUM = 2
    HIGH = 3

# IntEnum allows comparisons
if Priority.HIGH > Priority.LOW:
    print("High priority is greater")

# Regular Enum does not allow comparisons
class RegularPriority(Enum):
    LOW = 1
    MEDIUM = 2
    HIGH = 3

# RegularPriority.HIGH > RegularPriority.LOW  # TypeError

# Only equality works
if RegularPriority.HIGH == RegularPriority.HIGH:
    print("Equal")
```

**Pattern Matching with Enums:**

```python
from enum import Enum

class TrafficLight(Enum):
    RED = 1
    YELLOW = 2
    GREEN = 3

def next_light(current: TrafficLight) -> TrafficLight:
    match current:
        case TrafficLight.RED:
            return TrafficLight.GREEN
        case TrafficLight.YELLOW:
            return TrafficLight.RED
        case TrafficLight.GREEN:
            return TrafficLight.YELLOW

def action_for_light(light: TrafficLight) -> str:
    match light:
        case TrafficLight.RED | TrafficLight.YELLOW:
            return "Stop"
        case TrafficLight.GREEN:
            return "Go"
```

**Functional Operations on Enums:**

```python
from enum import Enum
from typing import Callable

class Grade(Enum):
    A = 90
    B = 80
    C = 70
    D = 60
    F = 0

def map_enum(f: Callable[[int], int], enum_class: type[Enum]) -> dict:
    return {member: f(member.value) for member in enum_class}

# Apply function to all enum values
weighted = map_enum(lambda x: x * 1.1, Grade)
# {Grade.A: 99.0, Grade.B: 88.0, ...}

def filter_enum(predicate: Callable[[Enum], bool], enum_class: type[Enum]) -> list:
    return [member for member in enum_class if predicate(member)]

# Filter passing grades
passing = filter_enum(lambda g: g.value >= 60, Grade)
# [Grade.A, Grade.B, Grade.C, Grade.D]
```

