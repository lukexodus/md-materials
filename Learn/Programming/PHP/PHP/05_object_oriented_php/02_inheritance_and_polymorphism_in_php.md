## Inheritance and Polymorphism in PHP


### Understanding Inheritance in PHP

Inheritance is a fundamental concept in object-oriented programming that allows a class to inherit properties and methods from another class. In PHP, inheritance establishes an "is-a" relationship between classes, enabling code reuse and logical hierarchies.

**Key Points**:

- Inheritance creates parent-child relationships between classes
- Child classes inherit all non-private members from parent classes
- PHP supports single inheritance only (a class can extend only one parent class)
- The inherited code can be extended or modified in the child class

### Extending Classes

In PHP, the `extends` keyword is used to create a child class that inherits from a parent class.

**Example**:

```php
<?php
// Parent class
class Vehicle {
    protected string $make;
    protected string $model;
    protected int $year;
    
    public function __construct(string $make, string $model, int $year) {
        $this->make = $make;
        $this->model = $model;
        $this->year = $year;
    }
    
    public function getInfo(): string {
        return "Vehicle: {$this->year} {$this->make} {$this->model}";
    }
    
    public function startEngine(): string {
        return "Engine started!";
    }
}

// Child class extending Vehicle
class Car extends Vehicle {
    private int $doors;
    
    public function __construct(string $make, string $model, int $year, int $doors) {
        // Call parent constructor first
        parent::__construct($make, $model, $year);
        $this->doors = $doors;
    }
    
    public function getDoors(): int {
        return $this->doors;
    }
}

// Creating objects
$vehicle = new Vehicle("Generic", "Transport", 2023);
$car = new Car("Toyota", "Camry", 2023, 4);

// Car inherits methods from Vehicle
echo $car->getInfo(); // Output: Vehicle: 2023 Toyota Camry
echo $car->startEngine(); // Output: Engine started!
echo "Doors: " . $car->getDoors(); // Output: Doors: 4
?>
```

#### Access to Parent Class

The `parent::` keyword allows a child class to access methods and properties from its parent class:

```php
<?php
class ChildClass extends ParentClass {
    public function someMethod() {
        // Call the parent version of this method
        parent::someMethod();
        
        // Additional code specific to ChildClass
    }
}
?>
```

#### Protected vs Private Members

When extending classes, it's important to understand how visibility modifiers affect inheritance:

- `public` members are accessible from anywhere
- `protected` members are accessible within the class and all its subclasses
- `private` members are accessible only within the class that defines them

```php
<?php
class Base {
    public $publicVar = "Public - accessible everywhere";
    protected $protectedVar = "Protected - accessible in this class and children";
    private $privateVar = "Private - accessible only in this class";
    
    public function testAccess() {
        echo $this->publicVar;     // Works
        echo $this->protectedVar;  // Works
        echo $this->privateVar;    // Works
    }
}

class Derived extends Base {
    public function testAccess() {
        echo $this->publicVar;     // Works
        echo $this->protectedVar;  // Works
        echo $this->privateVar;    // Error! Not accessible in child class
    }
}
?>
```

### Method Overriding

Method overriding occurs when a child class provides a specific implementation for a method that is already defined in its parent class. This allows child classes to customize or extend the behavior of inherited methods.

**Key Points**:

- The overriding method must have the same name and signature
- The visibility of the overriding method cannot be more restrictive
- The `parent::` keyword can be used to call the parent's version

**Example**:

```php
<?php
class Animal {
    public function makeSound(): string {
        return "Some generic animal sound";
    }
    
    public function describe(): string {
        return "This is an animal that makes: " . $this->makeSound();
    }
}

class Dog extends Animal {
    // Override the makeSound method
    public function makeSound(): string {
        return "Woof!";
    }
    
    // Override with parent call
    public function describe(): string {
        return "This is a dog. " . parent::describe();
    }
}

class Cat extends Animal {
    // Override the makeSound method
    public function makeSound(): string {
        return "Meow!";
    }
}

$animal = new Animal();
$dog = new Dog();
$cat = new Cat();

echo $animal->makeSound(); // Output: Some generic animal sound
echo $dog->makeSound();    // Output: Woof!
echo $cat->makeSound();    // Output: Meow!

echo $dog->describe();     // Output: This is a dog. This is an animal that makes: Woof!
?>
```

#### Visibility Rules When Overriding

When overriding methods, the child method must have the same or less restrictive visibility:

```php
<?php
class ParentClass {
    protected function protectedMethod() {
        // Code
    }
}

class ChildClass extends ParentClass {
    // Valid - same visibility
    protected function protectedMethod() {
        // Overridden code
    }
}

class AnotherChild extends ParentClass {
    // Valid - less restrictive visibility
    public function protectedMethod() {
        // Overridden code
    }
}

class InvalidChild extends ParentClass {
    // Invalid - more restrictive visibility
    // This will cause a fatal error
    private function protectedMethod() {
        // Overridden code
    }
}
?>
```

#### Final Methods and Classes

PHP provides the `final` keyword to prevent method overriding or class inheritance:

```php
<?php
class BaseClass {
    // This method cannot be overridden in child classes
    final public function finalMethod() {
        return "This method is final and cannot be overridden";
    }
}

// This class cannot be inherited from
final class FinalClass {
    // Class content
}

// This would cause a fatal error
// class ChildClass extends FinalClass { }
?>
```

### Abstract Classes and Methods

Abstract classes serve as templates for other classes but cannot be instantiated themselves. They may contain abstract methods—methods declared without implementation—that must be implemented by any concrete (non-abstract) child class.

**Key Points**:

- Abstract classes are declared with the `abstract` keyword
- They can contain a mix of complete and abstract methods
- Abstract methods are declared with the `abstract` keyword and don't have a body
- A class with at least one abstract method must itself be abstract
- Child classes must implement all parent's abstract methods

**Example**:

```php
<?php
abstract class Shape {
    protected string $color;
    
    public function __construct(string $color) {
        $this->color = $color;
    }
    
    // Regular method with implementation
    public function getColor(): string {
        return $this->color;
    }
    
    // Abstract method without implementation
    abstract public function getArea(): float;
    
    // Another abstract method
    abstract public function getPerimeter(): float;
}

class Circle extends Shape {
    private float $radius;
    
    public function __construct(string $color, float $radius) {
        parent::__construct($color);
        $this->radius = $radius;
    }
    
    // Implementation of abstract method
    public function getArea(): float {
        return pi() * $this->radius * $this->radius;
    }
    
    // Implementation of abstract method
    public function getPerimeter(): float {
        return 2 * pi() * $this->radius;
    }
}

class Rectangle extends Shape {
    private float $width;
    private float $height;
    
    public function __construct(string $color, float $width, float $height) {
        parent::__construct($color);
        $this->width = $width;
        $this->height = $height;
    }
    
    // Implementation of abstract method
    public function getArea(): float {
        return $this->width * $this->height;
    }
    
    // Implementation of abstract method
    public function getPerimeter(): float {
        return 2 * ($this->width + $this->height);
    }
}

// This would cause an error - cannot instantiate abstract class
// $shape = new Shape("red"); 

$circle = new Circle("blue", 5);
echo "Circle area: " . $circle->getArea(); // Output: Circle area: 78.539816339745
echo "Circle color: " . $circle->getColor(); // Output: Circle color: blue

$rectangle = new Rectangle("green", 4, 6);
echo "Rectangle area: " . $rectangle->getArea(); // Output: Rectangle area: 24
?>
```

### Interfaces

Interfaces define a contract for classes without implementing any functionality. They specify what methods a class must implement but don't define how these methods work.

**Key Points**:

- Interfaces are declared with the `interface` keyword
- All methods in an interface are implicitly abstract and public
- Classes implement interfaces using the `implements` keyword
- A class can implement multiple interfaces
- Interfaces can extend other interfaces

**Example**:

```php
<?php
interface Drawable {
    // Method signatures without implementation
    public function draw(): void;
    public function resize(float $factor): void;
}

interface Printable {
    public function printOutput(): string;
}

// Class implementing multiple interfaces
class Square implements Drawable, Printable {
    private float $side;
    
    public function __construct(float $side) {
        $this->side = $side;
    }
    
    // Implementing the draw method from Drawable
    public function draw(): void {
        echo "Drawing a square with side length {$this->side}";
    }
    
    // Implementing the resize method from Drawable
    public function resize(float $factor): void {
        $this->side *= $factor;
    }
    
    // Implementing the printOutput method from Printable
    public function printOutput(): string {
        return "Square with side length: {$this->side}";
    }
    
    public function getArea(): float {
        return $this->side * $this->side;
    }
}

// Interface inheritance
interface AdvancedDrawable extends Drawable {
    public function fill(string $color): void;
}

class Circle implements AdvancedDrawable {
    private float $radius;
    private string $fillColor = "transparent";
    
    public function __construct(float $radius) {
        $this->radius = $radius;
    }
    
    public function draw(): void {
        echo "Drawing a circle with radius {$this->radius}";
    }
    
    public function resize(float $factor): void {
        $this->radius *= $factor;
    }
    
    public function fill(string $color): void {
        $this->fillColor = $color;
        echo "Filling circle with {$color} color";
    }
}

// Using interfaces for type hinting
function renderObject(Drawable $object): void {
    $object->draw();
}

$square = new Square(5);
$circle = new Circle(3);

renderObject($square); // Works because Square implements Drawable
renderObject($circle); // Works because Circle implements AdvancedDrawable which extends Drawable
?>
```

### Polymorphism in PHP

Polymorphism allows objects of different classes to be treated as objects of a common superclass or interface. It enables methods to do different things based on the object they're acting upon.

**Key Points**:

- Functions can accept parameters of base class/interface types
- Different implementations are called based on the actual object type
- Enables flexible and extensible code

**Example**:

```php
<?php
interface Vehicle {
    public function move(): string;
}

class Car implements Vehicle {
    public function move(): string {
        return "The car drives on the road";
    }
}

class Boat implements Vehicle {
    public function move(): string {
        return "The boat sails on the water";
    }
}

class Airplane implements Vehicle {
    public function move(): string {
        return "The airplane flies in the sky";
    }
}

// Polymorphic function
function transport(Vehicle $vehicle): void {
    echo $vehicle->move();
}

// Different implementations get called based on the object type
transport(new Car());      // Output: The car drives on the road
transport(new Boat());     // Output: The boat sails on the water
transport(new Airplane()); // Output: The airplane flies in the sky
?>
```

### Type Declarations with Classes and Interfaces

PHP allows you to specify class and interface types for function parameters and return values:

```php
<?php
interface Logger {
    public function log(string $message): void;
}

class FileLogger implements Logger {
    private string $filename;
    
    public function __construct(string $filename) {
        $this->filename = $filename;
    }
    
    public function log(string $message): void {
        // Code to log to file
    }
}

class DatabaseLogger implements Logger {
    public function log(string $message): void {
        // Code to log to database
    }
}

class App {
    private Logger $logger;
    
    public function __construct(Logger $logger) {
        $this->logger = $logger;
    }
    
    public function doSomething(): void {
        $this->logger->log("Action performed");
    }
    
    // Method that returns a specific type
    public function getNewLogger(): Logger {
        return new FileLogger("new_log.txt");
    }
}

// Different logger implementations can be used
$app1 = new App(new FileLogger("app.log"));
$app2 = new App(new DatabaseLogger());
?>
```

### Traits for Code Reuse

While PHP doesn't support multiple inheritance, traits provide a mechanism for code reuse in PHP:

```php
<?php
trait Loggable {
    public function log($message) {
        echo "Logging: $message\n";
    }
}

trait Serializable {
    public function serialize() {
        return serialize($this);
    }
    
    public function unserialize($data) {
        $obj = unserialize($data);
        foreach ($obj as $prop => $val) {
            $this->$prop = $val;
        }
    }
}

class User {
    use Loggable, Serializable;
    
    private $name;
    
    public function __construct($name) {
        $this->name = $name;
        $this->log("User created: $name");
    }
}

$user = new User("John");
$user->log("User logged in");  // Output: Logging: User logged in
?>
```

### Related Topics

- Method chaining with inheritance
- Static and late static binding
- Type variance in PHP 7.4+ (covariance and contravariance)
- Design patterns utilizing inheritance and polymorphism
- Anonymous classes
- Using reflection for dynamic class manipulation

---

