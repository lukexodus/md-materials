## Pattern Matching on ADTs


Pattern matching deconstructs algebraic data types by matching their structure and extracting components in a single expression. This provides exhaustive case analysis with compile-time guarantees about coverage, replacing cascading conditionals with declarative structure inspection.

**Structural Decomposition**

Pattern matching binds variables to ADT components based on constructor patterns. The match expression tests which variant is present and extracts its data simultaneously:

```python
from dataclasses import dataclass
from typing import Union

@dataclass
class Circle:
    radius: float

@dataclass
class Rectangle:
    width: float
    height: float

@dataclass
class Triangle:
    base: float
    height: float

Shape = Union[Circle, Rectangle, Triangle]

def area(shape: Shape) -> float:
    match shape:
        case Circle(radius=r):
            return 3.14159 * r * r
        case Rectangle(width=w, height=h):
            return w * h
        case Triangle(base=b, height=h):
            return 0.5 * b * h
```

**Nested Pattern Matching**

Patterns can nest arbitrarily deep, matching internal structure without intermediate variable assignments:

```python
@dataclass
class Point:
    x: float
    y: float

@dataclass
class Line:
    start: Point
    end: Point

@dataclass
class Polygon:
    points: list[Point]

def classify_line(line: Line) -> str:
    match line:
        case Line(Point(0, 0), Point(x, y)):
            return f"Line from origin to ({x}, {y})"
        case Line(Point(x1, y1), Point(x2, y2)) if x1 == x2:
            return "Vertical line"
        case Line(Point(x1, y1), Point(x2, y2)) if y1 == y2:
            return "Horizontal line"
        case Line(start=s, end=e) if s == e:
            return "Degenerate line (point)"
        case _:
            return "Diagonal line"
```

**Guards and Conditional Patterns**

Guards add boolean predicates to patterns, refining matches beyond structural criteria:

```python
@dataclass
class Some:
    value: int

@dataclass
class None_:
    pass

Option = Union[Some, None_]

def process(opt: Option) -> str:
    match opt:
        case Some(value=x) if x > 0:
            return f"Positive: {x}"
        case Some(value=x) if x < 0:
            return f"Negative: {x}"
        case Some(value=0):
            return "Zero"
        case None_():
            return "Empty"
```

**Wildcard and Capture Patterns**

Use `_` to ignore components and variable names to capture them:

```python
@dataclass
class Cons:
    head: int
    tail: 'List'

@dataclass
class Nil:
    pass

List = Union[Cons, Nil]

def second_element(lst: List) -> Option:
    match lst:
        case Cons(_, Cons(head=x, tail=_)):
            return Some(x)
        case _:
            return None_()
```

**Or-Patterns**

Multiple patterns can share a single handler using the `|` operator:

```python
@dataclass
class Red:
    pass

@dataclass
class Green:
    pass

@dataclass
class Blue:
    pass

Color = Union[Red, Green, Blue]

def is_primary(color: Color) -> bool:
    match color:
        case Red() | Green() | Blue():
            return True
        case _:
            return False
```

**Exhaustiveness Checking**

Modern type checkers can verify pattern match exhaustiveness, ensuring all ADT variants are handled:

```python
# Type checker warns if any Shape variant is unhandled
def perimeter(shape: Shape) -> float:
    match shape:
        case Circle(radius=r):
            return 2 * 3.14159 * r
        case Rectangle(width=w, height=h):
            return 2 * (w + h)
        # Missing Triangle case - type checker issues warning
```

[Inference] Exhaustiveness checking quality depends on the type checker implementation (e.g., mypy, pyright) and may not catch all missing cases in Python's structural pattern matching.

**Sequence Patterns**

Match against sequence structures like lists and tuples:

```python
def process_coords(coords: list[int]) -> str:
    match coords:
        case []:
            return "Empty"
        case [x]:
            return f"1D point at {x}"
        case [x, y]:
            return f"2D point at ({x}, {y})"
        case [x, y, z]:
            return f"3D point at ({x}, {y}, {z})"
        case [x, y, *rest]:
            return f"High-dimensional: starts at ({x}, {y})"
```

**Mapping Patterns**

Destructure dictionaries and mapping types:

```python
def process_config(config: dict) -> str:
    match config:
        case {"type": "database", "host": host, "port": port}:
            return f"DB connection: {host}:{port}"
        case {"type": "cache", "ttl": ttl}:
            return f"Cache with TTL: {ttl}"
        case {"type": t}:
            return f"Unknown type: {t}"
        case _:
            return "Invalid config"
```

