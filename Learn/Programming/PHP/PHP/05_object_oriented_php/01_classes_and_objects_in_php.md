## Classes and Objects in PHP


### Introduction to OOP in PHP

PHP has supported Object-Oriented Programming (OOP) since PHP 4, but it was significantly enhanced in PHP 5 and later versions. OOP in PHP allows developers to create reusable code modules that encapsulate data and behavior through classes and objects. This paradigm helps organize code, improve maintainability, and model real-world entities more effectively.

### Creating Classes and Instantiating Objects

In PHP, a class is defined using the `class` keyword followed by the name of the class. Class names are case-sensitive and typically follow PascalCase convention.

**Key Points**:

- Classes are templates or blueprints for objects
- Objects are instances of classes
- Use the `new` keyword to create objects
- Each object has its own state but shares the class definition

**Example**:

```php
<?php
// Defining a class
class Person {
    // Class content goes here
}

// Instantiating an object
$person = new Person();
?>
```

The class above is empty, but it demonstrates the basic syntax for creating a class and instantiating an object from it. You can create multiple objects from the same class, each with its own independent state:

```php
<?php
$person1 = new Person();
$person2 = new Person();
// $person1 and $person2 are different objects of the same class
?>
```

### Properties and Methods

#### Properties

Properties (also called attributes or fields) are variables defined within a class that store data for each object. They can be defined with visibility modifiers.

**Key Points**:

- Properties represent the state or data of an object
- Visibility modifiers: `public`, `protected`, `private`
- Type declarations can be used since PHP 7.4
- Properties can have default values

**Example**:

```php
<?php
class Person {
    // Properties with visibility modifiers
    public string $name;
    private int $age;
    protected string $address;
    
    // Property with default value
    public bool $isActive = true;
}
?>
```

#### Methods

Methods are functions defined within a class that determine the behavior of objects instantiated from that class.

**Key Points**:

- Methods represent the behavior or actions of an object
- Visibility modifiers also apply to methods
- The `$this` keyword refers to the current object
- Type declarations can be used for parameters and return values

**Example**:

```php
<?php
class Person {
    public string $name;
    private int $age;
    
    // A method to set the age
    public function setAge(int $newAge): void {
        if ($newAge >= 0 && $newAge <= 120) {
            $this->age = $newAge;
        } else {
            throw new Exception("Invalid age value");
        }
    }
    
    // A method to get the age
    public function getAge(): int {
        return $this->age;
    }
    
    // A method that uses other properties
    public function greet(): string {
        return "Hello, my name is " . $this->name . " and I am " . $this->age . " years old.";
    }
}

// Using the class
$person = new Person();
$person->name = "John"; // Directly accessible because it's public
$person->setAge(30);    // Using a method to set private property
echo $person->greet();  // Output: Hello, my name is John and I am 30 years old.
?>
```

### Constructors and Destructors

#### Constructors

Constructors are special methods that are automatically called when an object is created. In PHP, the constructor method is named `__construct()`.

**Key Points**:

- Constructors initialize object state
- Parameters can be passed to constructors
- Constructor promotion (PHP 8+) allows defining properties directly in constructor parameters
- Constructors cannot return values

**Example**:

```php
<?php
class Person {
    public string $name;
    private int $age;
    
    // Constructor
    public function __construct(string $name, int $age) {
        $this->name = $name;
        $this->setAge($age);
    }
    
    public function setAge(int $age): void {
        if ($age >= 0 && $age <= 120) {
            $this->age = $age;
        } else {
            throw new Exception("Invalid age value");
        }
    }
    
    public function getAge(): int {
        return $this->age;
    }
}

// Creating an object with constructor parameters
$person = new Person("Alice", 25);
echo $person->name;     // Output: Alice
echo $person->getAge(); // Output: 25
?>
```

Constructor property promotion (PHP 8+):

```php
<?php
class Person {
    // Properties are automatically created from constructor parameters
    public function __construct(
        public string $name,
        private int $age,
        protected string $address = ""
    ) {
        // Additional initialization if needed
    }
    
    public function getAge(): int {
        return $this->age;
    }
}

$person = new Person("Bob", 30);
echo $person->name;     // Output: Bob
echo $person->getAge(); // Output: 30
?>
```

#### Destructors

Destructors are called when an object is destroyed, either explicitly or when the script ends. In PHP, the destructor method is named `__destruct()`.

**Key Points**:

- Destructors perform cleanup tasks
- They take no parameters
- They cannot return values
- Useful for closing files, database connections, etc.
- Called automatically when object is no longer referenced

**Example**:

```php
<?php
class FileHandler {
    private $fileHandle;
    
    public function __construct(string $filename) {
        $this->fileHandle = fopen($filename, 'w');
        echo "File opened.\n";
    }
    
    public function write(string $data): void {
        fwrite($this->fileHandle, $data);
    }
    
    public function __destruct() {
        if ($this->fileHandle) {
            fclose($this->fileHandle);
            echo "File closed.\n";
        }
    }
}

// Using the class
function processFile() {
    $file = new FileHandler("example.txt");
    $file->write("Hello, World!");
    // $file will be destroyed when this function ends
    // The destructor will be called automatically
}

processFile();
// Output:
// File opened.
// File closed.
?>
```

### Advanced Class Features

#### Static Properties and Methods

Static members belong to the class itself rather than to any specific instance.

```php
<?php
class Counter {
    private static int $count = 0;
    
    public function __construct() {
        self::$count++;
    }
    
    public static function getCount(): int {
        return self::$count;
    }
}

$a = new Counter();
$b = new Counter();
echo Counter::getCount(); // Output: 2
?>
```

#### Constants

Class constants provide fixed values that don't change across instances.

```php
<?php
class MathOperations {
    const PI = 3.14159;
    
    public function calculateCircleArea(float $radius): float {
        return self::PI * $radius * $radius;
    }
}

echo MathOperations::PI; // Output: 3.14159
?>
```

### Best Practices for PHP Classes

1. Follow naming conventions:
    
    - Classes: PascalCase (e.g., `PersonManager`)
    - Methods and properties: camelCase (e.g., `getUserData()`)
2. Encapsulate internal data:
    
    - Use private/protected for properties
    - Provide accessor methods (getters/setters) when needed
3. Keep classes focused (Single Responsibility Principle)
    
4. Use type declarations for better code reliability
    
5. Document your classes with PHPDoc comments
    

```php
<?php
/**
 * Represents a user in the system
 */
class User {
    private int $id;
    
    /**
     * Get the user's ID
     *
     * @return int The user's unique identifier
     */
    public function getId(): int {
        return $this->id;
    }
}
?>
```

### Related Topics

- Inheritance and the `extends` keyword
- Interfaces and the `implements` keyword
- Traits for code reuse
- Namespaces for organizing classes
- Abstract classes and methods
- Final classes and methods
- Magic methods beyond `__construct` and `__destruct`
- Object serialization
- Type hinting with classes

---

