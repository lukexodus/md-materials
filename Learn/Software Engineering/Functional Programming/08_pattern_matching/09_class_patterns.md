## Class Patterns


Class patterns enable matching against the type and structure of objects, extracting their components in a single expression. This pattern allows deconstruction of objects based on their class type and the values of their properties or constructor parameters.

**Key Points:**

- Matches objects by their type and internal structure
- Extracts values directly from object properties or constructor arguments
- Combines type checking and value extraction in one operation
- Reduces boilerplate code compared to traditional instanceof checks and casting
- Supports nested patterns for complex object hierarchies

The syntax typically involves specifying the class name followed by a pattern that destructures the object's components. The pattern can match against constructor parameters, public fields, or accessor methods depending on the language implementation.

**Example:**

```scala
sealed trait Shape
case class Circle(radius: Double) extends Shape
case class Rectangle(width: Double, height: Double) extends Shape
case class Triangle(base: Double, height: Double) extends Shape

def calculateArea(shape: Shape): Double = shape match {
  case Circle(r) => Math.PI * r * r
  case Rectangle(w, h) => w * h
  case Triangle(b, h) => 0.5 * b * h
}

def describeShape(shape: Shape): String = shape match {
  case Circle(r) if r > 10 => s"Large circle with radius $r"
  case Circle(r) => s"Small circle with radius $r"
  case Rectangle(w, h) if w == h => s"Square with side $w"
  case Rectangle(w, h) => s"Rectangle ${w}x${h}"
  case Triangle(b, h) => s"Triangle with base $b and height $h"
}
```

**Output:**

```
calculateArea(Circle(5.0))           // 78.53981633974483
calculateArea(Rectangle(4.0, 6.0))   // 24.0
describeShape(Circle(15.0))          // "Large circle with radius 15.0"
describeShape(Rectangle(5.0, 5.0))   // "Square with side 5.0"
```

Class patterns shine when working with algebraic data types, enabling exhaustive matching that the compiler can verify. This eliminates entire categories of runtime errors related to unhandled cases. The pattern matching compiler can warn when cases are missing or when cases are unreachable.

When dealing with nested structures, class patterns allow deep destructuring in a single expression. This eliminates the need for multiple levels of conditional logic and temporary variables.

**Example:**

```scala
case class Point(x: Double, y: Double)
case class Line(start: Point, end: Point)
case class Polygon(vertices: List[Point])

def analyzeGeometry(geo: Any): String = geo match {
  case Point(0, 0) => "Origin point"
  case Point(x, 0) => s"Point on x-axis at $x"
  case Point(0, y) => s"Point on y-axis at $y"
  case Point(x, y) => s"Point at ($x, $y)"
  
  case Line(Point(x1, y1), Point(x2, y2)) if x1 == x2 => 
    "Vertical line"
  case Line(Point(x1, y1), Point(x2, y2)) if y1 == y2 => 
    "Horizontal line"
  case Line(start, end) => 
    s"Line from $start to $end"
  
  case Polygon(vertices) if vertices.length < 3 => 
    "Invalid polygon"
  case Polygon(vertices) => 
    s"Polygon with ${vertices.length} vertices"
}
```

The type system ensures that extracted values have the correct types without explicit casting. This type safety extends through the entire pattern, including nested components. Refactoring becomes safer because changes to class structures are caught at compile time.

