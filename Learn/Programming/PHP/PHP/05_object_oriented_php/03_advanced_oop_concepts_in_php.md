## Advanced OOP Concepts in PHP


### Namespaces

Namespaces provide a way to encapsulate items such as classes, interfaces, functions, and constants to avoid name collisions. Introduced in PHP 5.3, namespaces effectively address the problem of organizing large codebases and using third-party libraries.

**Key Points**:

- Namespaces help prevent naming conflicts
- They organize code into logical groups
- Namespace declarations must be the first statement in a file
- Sub-namespaces are created using backslashes
- Namespaces enable better code organization and reuse

**Example**:

```php
<?php
// File: User.php
namespace App\Models;

class User {
    private string $name;
    
    public function __construct(string $name) {
        $this->name = $name;
    }
    
    public function getName(): string {
        return $this->name;
    }
}
?>
```

```php
<?php
// File: UserController.php
namespace App\Controllers;

use App\Models\User;

class UserController {
    public function createUser(string $name): User {
        return new User($name);
    }
}
?>
```

#### Namespace Resolution and Aliases

PHP offers several ways to reference classes within namespaces:

```php
<?php
namespace App\Admin;

// 1. Fully qualified name (absolute)
$user = new \App\Models\User("John");

// 2. Import with "use" statement
use App\Models\User;
$user = new User("John");

// 3. Import with alias
use App\Models\User as UserModel;
$user = new UserModel("John");

// 4. Import multiple classes
use App\Models\{User, Product, Order};

// 5. Relative namespace (relative to current namespace)
namespace App\Models\Admin;
$user = new \App\Models\User("John"); // Absolute
$order = new ..\Order("123");         // Relative
?>
```

#### Global Namespace

Code without a namespace declaration belongs to the global namespace:

```php
<?php
// Global namespace
class GlobalClass {
    // Code
}

namespace App;

// Referencing global class
$obj = new \GlobalClass();
?>
```

### Traits

Traits are a mechanism for code reuse in single inheritance languages like PHP. They allow developers to reuse methods across several classes without requiring inheritance.

**Key Points**:

- Traits help avoid code duplication and limitations of single inheritance
- A trait cannot be instantiated on its own
- Multiple traits can be used in a single class
- Traits can include properties, methods, and abstract methods
- Conflict resolution mechanisms are available when using multiple traits

**Example**:

```php
<?php
// Define a trait
trait Logger {
    protected function log(string $message): void {
        echo "[" . date("Y-m-d H:i:s") . "] $message\n";
    }
}

trait Timestampable {
    private $createdAt;
    private $updatedAt;
    
    public function setCreatedAt(): void {
        $this->createdAt = new \DateTime();
    }
    
    public function setUpdatedAt(): void {
        $this->updatedAt = new \DateTime();
    }
    
    public function getCreatedAt(): ?\DateTime {
        return $this->createdAt;
    }
    
    public function getUpdatedAt(): ?\DateTime {
        return $this->updatedAt;
    }
}

// Use traits in a class
class Article {
    use Logger, Timestampable;
    
    private string $title;
    private string $content;
    
    public function __construct(string $title, string $content) {
        $this->title = $title;
        $this->content = $content;
        $this->setCreatedAt();
        $this->log("Article created: $title");
    }
    
    public function update(string $content): void {
        $this->content = $content;
        $this->setUpdatedAt();
        $this->log("Article updated: $this->title");
    }
}

$article = new Article("PHP Traits", "Content about traits...");
$article->update("Updated content about traits!");
echo "Created at: " . $article->getCreatedAt()->format('Y-m-d H:i:s');
?>
```

#### Conflict Resolution in Traits

When multiple traits provide methods with the same name, conflicts must be resolved:

```php
<?php
trait A {
    public function hello() {
        return "Hello from A";
    }
}

trait B {
    public function hello() {
        return "Hello from B";
    }
}

class MyClass {
    // Using both traits with the same method name
    use A, B {
        // Resolve conflict by preferring B's implementation
        B::hello insteadof A;
        
        // But keep A's implementation accessible with an alias
        A::hello as helloA;
    }
}

$obj = new MyClass();
echo $obj->hello();  // Output: Hello from B
echo $obj->helloA(); // Output: Hello from A
?>
```

#### Trait Composition and Abstract Methods

Traits can also include abstract methods and use other traits:

```php
<?php
trait Notifiable {
    abstract public function getEmail(): string;
    
    public function sendNotification(string $message): void {
        $email = $this->getEmail();
        echo "Sending notification to $email: $message\n";
    }
}

trait LoggableTrait {
    use Logger; // Traits can use other traits
    
    public function logAction(string $action): void {
        $this->log("Action performed: $action");
    }
}

class User {
    use Notifiable, LoggableTrait;
    
    private string $email;
    
    public function __construct(string $email) {
        $this->email = $email;
    }
    
    // Implement abstract method from trait
    public function getEmail(): string {
        return $this->email;
    }
}

$user = new User("user@example.com");
$user->sendNotification("Your account has been created");
$user->logAction("Account creation");
?>
```

### Static Methods and Properties

Static members belong to the class itself rather than to any specific instance of the class. They are accessed using the class name rather than an object instance.

**Key Points**:

- Static properties are shared across all instances of a class
- Static methods can be called without creating an object
- The `self::` keyword is used to access static members within the class
- Static methods cannot access non-static properties
- Static members are useful for utility functions and shared data

**Example**:

```php
<?php
class MathUtils {
    // Static property
    public static float $pi = 3.14159;
    
    // Static method
    public static function square(float $number): float {
        return $number * $number;
    }
    
    public static function circleArea(float $radius): float {
        // Accessing static property with self::
        return self::$pi * self::square($radius);
    }
}

// Using static members without creating an instance
echo MathUtils::$pi;  // Output: 3.14159
echo MathUtils::square(4);  // Output: 16
echo MathUtils::circleArea(5);  // Output: 78.53975
?>
```

#### Static Counter Example

A common use case for static properties is counting instances:

```php
<?php
class User {
    private static int $count = 0;
    private string $name;
    
    public function __construct(string $name) {
        $this->name = $name;
        self::$count++;
    }
    
    public static function getCount(): int {
        return self::$count;
    }
}

$user1 = new User("Alice");
$user2 = new User("Bob");
$user3 = new User("Charlie");

echo "Total users created: " . User::getCount();  // Output: 3
?>
```

#### Static Methods as Factory Methods

Static methods are often used as factory methods to create instances:

```php
<?php
class Database {
    private static ?Database $instance = null;
    private string $connection;
    
    // Private constructor to prevent direct instantiation
    private function __construct(string $host, string $username, string $password) {
        $this->connection = "Connected to $host as $username";
    }
    
    // Static factory method implementing Singleton pattern
    public static function getInstance(
        string $host = 'localhost',
        string $username = 'root',
        string $password = ''
    ): Database {
        if (self::$instance === null) {
            self::$instance = new Database($host, $username, $password);
        }
        return self::$instance;
    }
    
    public function query(string $sql): string {
        return "Executing query: $sql on " . $this->connection;
    }
}

// Using the static factory method
$db = Database::getInstance();
echo $db->query("SELECT * FROM users");

// Always returns the same instance
$db2 = Database::getInstance();
var_dump($db === $db2);  // Output: bool(true)
?>
```

#### Late Static Binding

Late static binding resolves static method calls at runtime rather than compile time:

```php
<?php
class BaseClass {
    protected static string $name = "Base";
    
    public static function getName(): string {
        return self::$name;  // Always refers to BaseClass::$name
    }
    
    public static function getNameLSB(): string {
        return static::$name;  // Uses late static binding
    }
}

class ChildClass extends BaseClass {
    protected static string $name = "Child";
}

echo BaseClass::getName();    // Output: Base
echo ChildClass::getName();   // Output: Base (using parent's implementation with self::)
echo BaseClass::getNameLSB(); // Output: Base
echo ChildClass::getNameLSB(); // Output: Child (using LSB with static::)
?>
```

### Magic Methods

Magic methods are special methods that start with a double underscore (`__`). They are triggered automatically by PHP in response to specific actions and allow classes to implement special behaviors.

**Key Points**:

- Magic methods are called automatically by PHP
- They provide hooks into language features
- Should be used carefully due to potential performance implications
- Enable powerful object behaviors like property overloading
- Make classes more dynamic and flexible

#### Constructor and Destructor

Already covered in previous sections, but included for completeness:

```php
<?php
class FileHandler {
    private $handle;
    
    // Called when object is created
    public function __construct(string $filename) {
        $this->handle = fopen($filename, 'w');
    }
    
    // Called when object is destroyed
    public function __destruct() {
        if ($this->handle) {
            fclose($this->handle);
        }
    }
}
?>
```

#### Property Overloading Magic Methods

These methods allow classes to respond to operations on non-existent properties:

```php
<?php
class DynamicProperties {
    private array $data = [];
    
    // Called when reading non-existent property
    public function __get(string $name) {
        if (array_key_exists($name, $this->data)) {
            return $this->data[$name];
        }
        return null;
    }
    
    // Called when writing to non-existent property
    public function __set(string $name, $value) {
        $this->data[$name] = $value;
    }
    
    // Called when checking if non-existent property exists
    public function __isset(string $name): bool {
        return isset($this->data[$name]);
    }
    
    // Called when unsetting non-existent property
    public function __unset(string $name) {
        unset($this->data[$name]);
    }
}

$obj = new DynamicProperties();
$obj->name = "John";  // Calls __set()
echo $obj->name;      // Calls __get(), Output: John
var_dump(isset($obj->name));  // Calls __isset(), Output: bool(true)
unset($obj->name);    // Calls __unset()
var_dump(isset($obj->name));  // Output: bool(false)
?>
```

#### Method Overloading Magic Methods

These methods handle calls to non-existent methods:

```php
<?php
class MethodCaller {
    // Called when invoking non-existent instance method
    public function __call(string $name, array $arguments) {
        echo "Called instance method '$name' with arguments: " . 
             implode(', ', $arguments);
    }
    
    // Called when invoking non-existent static method
    public static function __callStatic(string $name, array $arguments) {
        echo "Called static method '$name' with arguments: " . 
             implode(', ', $arguments);
    }
}

$obj = new MethodCaller();
$obj->nonExistentMethod(1, "test");  // Calls __call()
MethodCaller::staticMethod(42);      // Calls __callStatic()
?>
```

#### Serialization Magic Methods

These methods control object serialization and unserialization:

```php
<?php
class User {
    private string $username;
    private string $password;  // Sensitive data
    private array $preferences;
    
    public function __construct(string $username, string $password) {
        $this->username = $username;
        $this->password = $password;
        $this->preferences = [];
    }
    
    // Called during serialization
    public function __sleep(): array {
        // Only serialize these properties
        return ['username', 'preferences'];
    }
    
    // Called after unserialization
    public function __wakeup() {
        // Reconnect to database or restore resources
        $this->password = "";  // Security: don't keep password in memory
    }
}

$user = new User("john_doe", "secret123");
$serialized = serialize($user);  // __sleep() is called
$newUser = unserialize($serialized);  // __wakeup() is called
?>
```

#### String Conversion Magic Methods

These methods allow objects to be converted to strings:

```php
<?php
class Product {
    private string $name;
    private float $price;
    
    public function __construct(string $name, float $price) {
        $this->name = $name;
        $this->price = $price;
    }
    
    // Called when object is converted to string
    public function __toString(): string {
        return "$this->name: $" . number_format($this->price, 2);
    }
}

$product = new Product("Smartphone", 499.99);
echo $product;  // Output: Smartphone: $499.99
?>
```

#### Debugging Magic Methods

These methods help with debugging and developer experience:

```php
<?php
class ComplexObject {
    private $data;
    private $resource;
    
    public function __construct() {
        $this->data = ["key" => "value"];
        $this->resource = fopen("php://memory", "r");
    }
    
    // Controls object representation when var_dump() is called
    public function __debugInfo(): array {
        return [
            'data' => $this->data,
            'resource_type' => get_resource_type($this->resource)
        ];
    }
}

$complex = new ComplexObject();
var_dump($complex);  // Shows custom debug information
?>
```

#### Object Cloning Magic Method

This method customizes object cloning behavior:

```php
<?php
class Connection {
    private $resource;
    private string $connectionId;
    
    public function __construct() {
        $this->connectionId = uniqid('conn_');
        $this->resource = fopen("php://memory", "r+");
    }
    
    // Called when object is cloned
    public function __clone() {
        // Create a new connection resource
        $this->resource = fopen("php://memory", "r+");
        // Assign new ID
        $this->connectionId = uniqid('conn_');
    }
    
    public function getId(): string {
        return $this->connectionId;
    }
}

$conn1 = new Connection();
echo $conn1->getId() . "\n";

$conn2 = clone $conn1;  // __clone() is called
echo $conn2->getId() . "\n";  // Different ID
?>
```

#### Invoke Magic Method

This method allows objects to be called as functions:

```php
<?php
class Multiplier {
    private int $factor;
    
    public function __construct(int $factor) {
        $this->factor = $factor;
    }
    
    // Called when object is used as a function
    public function __invoke(int $number): int {
        return $number * $this->factor;
    }
}

$doubler = new Multiplier(2);
$tripler = new Multiplier(3);

echo $doubler(5);  // Output: 10
echo $tripler(5);  // Output: 15

// Check if object is callable
var_dump(is_callable($doubler));  // Output: bool(true)
?>
```

#### Set State Magic Method

This method is used for `var_export()` and handling object creation from exported arrays:

```php
<?php
class Point {
    public float $x;
    public float $y;
    
    public function __construct(float $x, float $y) {
        $this->x = $x;
        $this->y = $y;
    }
    
    // Called by var_export() to recreate object
    public static function __set_state(array $properties): object {
        return new Point(
            $properties['x'] ?? 0,
            $properties['y'] ?? 0
        );
    }
}

$point = new Point(10.5, 20.7);
$exported = var_export($point, true);
eval('$newPoint = ' . $exported . ';');
echo "New point: ({$newPoint->x}, {$newPoint->y})";
?>
```

### Combining Advanced OOP Concepts

Here's an example that combines namespaces, traits, static methods, and magic methods:

```php
<?php
namespace App\Services;

trait Loggable {
    protected static array $logs = [];
    
    public function log(string $message): void {
        self::$logs[] = "[" . date("Y-m-d H:i:s") . "] $message";
    }
    
    public static function getLogs(): array {
        return self::$logs;
    }
}

trait Configurable {
    private array $config = [];
    
    public function __get(string $name) {
        return $this->config[$name] ?? null;
    }
    
    public function __set(string $name, $value): void {
        $this->config[$name] = $value;
    }
    
    public function __isset(string $name): bool {
        return isset($this->config[$name]);
    }
}

class ApiClient {
    use Loggable, Configurable;
    
    private static ?self $instance = null;
    private string $apiKey;
    
    private function __construct(string $apiKey) {
        $this->apiKey = $apiKey;
        $this->log("API client initialized");
    }
    
    public static function getInstance(string $apiKey = ""): self {
        if (self::$instance === null) {
            self::$instance = new self($apiKey);
        }
        return self::$instance;
    }
    
    public function __call(string $method, array $args) {
        $this->log("Called API method: $method");
        
        $endpoint = strtolower($method);
        return $this->request($endpoint, $args[0] ?? []);
    }
    
    private function request(string $endpoint, array $data): array {
        $this->log("Making request to $endpoint with data: " . json_encode($data));
        
        // Simulate API request
        return [
            'success' => true,
            'endpoint' => $endpoint,
            'data' => $data
        ];
    }
    
    public function __debugInfo(): array {
        return [
            'config' => $this->config,
            'api_key' => str_repeat('*', strlen($this->apiKey)),
            'logs_count' => count(self::$logs)
        ];
    }
}

// Usage
$api = ApiClient::getInstance("secret_key_123");
$api->baseUrl = "https://api.example.com/v1";
$api->timeout = 30;

$result = $api->getUserData(['id' => 123]);
$result = $api->updateProfile(['name' => 'John']);

var_dump($api);
var_dump(ApiClient::getLogs());
?>
```

### Best Practices for Advanced OOP in PHP

1. **Use Namespaces Effectively**:
    
    - Align namespace structure with directory structure
    - Use PSR-4 autoloading standard
    - Keep namespace depth manageable
2. **Traits Usage**:
    
    - Use traits for horizontal code reuse
    - Keep traits focused and composable
    - Document trait dependencies clearly
3. **Static Members**:
    
    - Use static methods for utility functions
    - Be careful with mutable static properties
    - Consider using dependency injection over singletons
4. **Magic Methods**:
    
    - Use magic methods deliberately and document them
    - Be aware of potential performance implications
    - Don't make behavior too magical or unpredictable
5. **General Best Practices**:
    
    - Follow SOLID principles
    - Use design patterns appropriately
    - Document your code thoroughly
    - Write unit tests for complex behaviors

### Related Topics

- Dependency injection
- Design patterns in PHP
- Reflection API
- Anonymous classes
- Type variance (covariant returns, contravariant parameters)
- Attribute-based programming (PHP 8+)

---

