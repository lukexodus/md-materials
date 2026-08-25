## Frozen Dataclasses


Frozen dataclasses are structured data containers with named fields that are immutable after instantiation. They combine the convenience of automatic constructor generation, field access, and comparison methods with immutability guarantees. Many languages provide built-in support through decorators, attributes, or language constructs.

These structures serve as domain objects, value objects, and data transfer objects where immutability prevents accidental modification and makes the data contract explicit.

**Key Points:**

- Automatically generate constructors, equality methods, and string representations
- Enforce immutability at the language or framework level
- Provide clear schema definition for data structures
- Enable hash-based operations when immutable (useful for sets and dictionary keys)
- Reduce boilerplate compared to manual immutable class implementation

**Python example:**

```python
from dataclasses import dataclass, replace
from typing import List

@dataclass(frozen=True)
class Point:
    x: float
    y: float
    
    def move(self, dx: float, dy: float) -> 'Point':
        return Point(self.x + dx, self.y + dy)
    
    def distance_to(self, other: 'Point') -> float:
        import math
        return math.sqrt((self.x - other.x)**2 + (self.y - other.y)**2)

p1 = Point(0, 0)
p2 = p1.move(3, 4)
print(p1)  # Point(x=0, y=0)
print(p2)  # Point(x=3, y=4)

# p1.x = 5  # Raises FrozenInstanceError

# Using replace for updates
@dataclass(frozen=True)
class User:
    id: int
    name: str
    email: str
    active: bool = True

user = User(1, "Alice", "alice@example.com")
updated = replace(user, email="newemail@example.com")
print(user.email)    # alice@example.com
print(updated.email) # newemail@example.com
```

**Nested frozen dataclasses:**

```python
from dataclasses import dataclass
from typing import Optional

@dataclass(frozen=True)
class Address:
    street: str
    city: str
    zip_code: str

@dataclass(frozen=True)
class ContactInfo:
    email: str
    phone: Optional[str] = None

@dataclass(frozen=True)
class Person:
    name: str
    address: Address
    contact: ContactInfo
    
    def with_address(self, address: Address) -> 'Person':
        return replace(self, address=address)
    
    def with_email(self, email: str) -> 'Person':
        new_contact = replace(self.contact, email=email)
        return replace(self, contact=new_contact)

person = Person(
    name="Bob",
    address=Address("123 Main St", "NYC", "10001"),
    contact=ContactInfo("bob@example.com", "555-0100")
)

updated = person.with_email("robert@example.com")
```

**TypeScript/JavaScript approximation with readonly:**

```typescript
interface FrozenPoint {
  readonly x: number;
  readonly y: number;
}

class Point {
  readonly x: number;
  readonly y: number;
  
  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
    Object.freeze(this);
  }
  
  move(dx: number, dy: number): Point {
    return new Point(this.x + dx, this.y + dy);
  }
}

// Using type-level immutability
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};

interface User {
  id: number;
  profile: {
    name: string;
    settings: {
      theme: string;
    };
  };
}

type FrozenUser = DeepReadonly<User>;

const user: FrozenUser = {
  id: 1,
  profile: {
    name: "Alice",
    settings: { theme: "dark" }
  }
};

// user.profile.name = "Bob"; // Type error
```

**Scala case classes (frozen by default):**

```scala
case class Point(x: Double, y: Double) {
  def move(dx: Double, dy: Double): Point = 
    Point(x + dx, y + dy)
  
  def distanceTo(other: Point): Double = {
    val dx = x - other.x
    val dy = y - other.y
    math.sqrt(dx * dx + dy * dy)
  }
}

val p1 = Point(0, 0)
val p2 = p1.move(3, 4)

// Using copy for updates
case class User(id: Int, name: String, email: String, active: Boolean = true)

val user = User(1, "Alice", "alice@example.com")
val updated = user.copy(email = "newemail@example.com")
```

**Validation in frozen dataclasses:**

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Email:
    value: str
    
    def __post_init__(self):
        if '@' not in self.value:
            raise ValueError(f"Invalid email: {self.value}")

@dataclass(frozen=True)
class PositiveInt:
    value: int
    
    def __post_init__(self):
        if self.value <= 0:
            raise ValueError(f"Value must be positive: {self.value}")

@dataclass(frozen=True)
class Order:
    id: int
    quantity: PositiveInt
    customer_email: Email
    
order = Order(
    id=1,
    quantity=PositiveInt(5),
    customer_email=Email("customer@example.com")
)
```

**Considerations:**

- Language support varies—Python dataclasses, Scala case classes, Kotlin data classes all provide different features
- Frozen dataclasses can be used as dictionary keys or set elements (if hashable)
- [Inference] Type checking catches attempts to modify fields at compile time in statically typed languages
- Nested mutable objects require explicit freezing or immutable types
- [Inference] Performance is generally excellent—modern runtimes optimize dataclass operations

