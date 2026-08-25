## PHP Functions


### Creating and Calling Functions

Functions in PHP are reusable blocks of code designed to perform specific tasks. They help organize code, promote reusability, and reduce redundancy.

**Key Points:**

- Functions are defined using the `function` keyword
- Function names must start with a letter or underscore
- Function names are case-insensitive
- Functions can be called by writing the function name followed by parentheses

Basic function syntax:

```php
function functionName() {
    // Code to be executed
}

// Calling the function
functionName();
```

You can create functions anywhere in your PHP code, but typically they are defined before they are called. PHP also allows you to define functions inside conditional statements, though this practice is not recommended.

### Parameters and Return Values

Parameters allow functions to receive input values, making them more flexible and versatile.

**Key Points:**

- Parameters are specified within parentheses after the function name
- Multiple parameters are separated by commas
- Parameters act as variables within the function's scope
- Default parameter values can be specified for optional parameters
- Return values allow functions to output results

```php
// Function with parameters
function greet($name, $greeting = "Hello") {
    return "$greeting, $name!";
}

// Different ways to call the function
echo greet("John");                  // Output: Hello, John!
echo greet("Sarah", "Good morning"); // Output: Good morning, Sarah!
```

PHP supports several parameter passing methods:

```php
// Pass by value (default)
function increment($number) {
    $number++;
    return $number;
}
$a = 5;
echo increment($a); // Output: 6
echo $a;            // Output: 5 (original value unchanged)

// Pass by reference
function incrementRef(&$number) {
    $number++;
}
$b = 5;
incrementRef($b);
echo $b;  // Output: 6 (original value modified)
```

For complex functions that need to return multiple values, you can:

```php
// Return an array of values
function getCoordinates() {
    return [10, 20];
}
[$x, $y] = getCoordinates();
echo "X: $x, Y: $y";  // Output: X: 10, Y: 20

// Or use reference parameters
function calculateStats($numbers, &$sum, &$average) {
    $sum = array_sum($numbers);
    $average = $sum / count($numbers);
}
$numbers = [2, 4, 6, 8];
calculateStats($numbers, $sum, $avg);
echo "Sum: $sum, Average: $avg";  // Output: Sum: 20, Average: 5
```

### Variable Scope

Variable scope determines where a variable can be accessed within your code.

**Key Points:**

- Variables defined inside a function have local scope
- Variables defined outside functions have global scope
- Local variables are destroyed when the function completes
- The `global` keyword allows access to global variables inside functions
- The `static` keyword preserves variable values between function calls

```php
$globalVar = "I'm global";

function scopeTest() {
    $localVar = "I'm local";
    echo $localVar;          // Works fine
    // echo $globalVar;      // Error: undefined variable
    
    global $globalVar;       // Access global variable
    echo $globalVar;         // Now works
    
    static $counter = 0;     // Static variable
    $counter++;
    echo "Counter: $counter";
}

scopeTest();
// echo $localVar;           // Error: undefined variable
echo $globalVar;             // Works fine
scopeTest();                 // Counter will be 2, not reset to 1
```

PHP also provides the `$GLOBALS` array to access global variables:

```php
$x = 10;

function useGlobals() {
    echo $GLOBALS['x']; // Output: 10
    $GLOBALS['x'] = 20; // Modifies the global variable
}

useGlobals();
echo $x; // Output: 20
```

### Type Declarations and Return Types

Since PHP 7.0, you can specify parameter types and return types for functions, making your code more robust and self-documenting.

**Key Points:**

- Type declarations enforce specific data types for parameters
- Return type declarations specify the function's return value type
- Available types include: `int`, `float`, `string`, `bool`, `array`, `object`, `callable`, `iterable`, `self`, class/interface names
- `void` return type indicates the function returns nothing
- PHP 7.1+ supports nullable types with the `?` prefix

```php
// Type declarations for parameters
function add(int $a, int $b) {
    return $a + $b;
}
echo add(5, 3);       // Output: 8
// echo add("5", "3"); // Works but values are converted to integers
// echo add("five", 3); // Error: must be of type int, string given

// Return type declarations
function multiply(float $a, float $b): float {
    return $a * $b;
}
$result = multiply(2.5, 3);
echo $result;  // Output: 7.5

// Void return type
function logMessage(string $message): void {
    echo "LOG: $message";
    // return "value"; // Error: this would violate the void return type
}

// Nullable types (PHP 7.1+)
function findUser(int $id): ?array {
    // Database search logic here
    if ($id > 0) {
        return ['id' => $id, 'name' => 'User ' . $id];
    }
    return null; // Can return null with ?array type
}
```

PHP 7.4 introduced property type declarations and PHP 8.0 added union types, further enhancing type safety:

```php
// PHP 8.0 Union Types
function processInput(string|int $input): string|int {
    if (is_string($input)) {
        return strtoupper($input);
    }
    return $input * 2;
}
echo processInput("hello"); // Output: HELLO
echo processInput(5);       // Output: 10
```

### Advanced Function Concepts

PHP provides several advanced function concepts that make programming more flexible and powerful.

**Key Points:**

- Anonymous functions (closures) can be assigned to variables
- Arrow functions provide more concise syntax for simple functions
- Variadic functions accept a variable number of arguments
- Callable types allow for function callbacks and higher-order functions

```php
// Anonymous functions (closures)
$greet = function($name) {
    return "Hello, $name!";
};
echo $greet("Sarah");  // Output: Hello, Sarah!

// Closures with use keyword to access outside variables
$message = "Welcome to";
$welcomeUser = function($name) use ($message) {
    return "$message $name!";
};
echo $welcomeUser("PHP");  // Output: Welcome to PHP!

// Arrow functions (PHP 7.4+)
$multiply = fn($a, $b) => $a * $b;
echo $multiply(4, 5);  // Output: 20

// Variadic functions
function sum(...$numbers) {
    return array_sum($numbers);
}
echo sum(1, 2, 3, 4, 5);  // Output: 15

// Callable as parameter type
function processArray(array $array, callable $callback) {
    $result = [];
    foreach ($array as $item) {
        $result[] = $callback($item);
    }
    return $result;
}

$numbers = [1, 2, 3, 4];
$doubled = processArray($numbers, fn($n) => $n * 2);
print_r($doubled);  // Output: Array ( [0] => 2 [1] => 4 [2] => 6 [3] => 8 )
```

### Recursion

Recursion is when a function calls itself to solve a problem.

**Key Points:**

- Recursive functions need a base case to prevent infinite recursion
- Can be elegant for certain problems but may be inefficient for deep recursion
- PHP has a maximum recursion depth limit

```php
// Calculate factorial recursively
function factorial(int $n): int {
    // Base case
    if ($n <= 1) {
        return 1;
    }
    // Recursive case
    return $n * factorial($n - 1);
}

echo factorial(5);  // Output: 120 (5 * 4 * 3 * 2 * 1)
```

### Function Best Practices

**Key Points:**

- Write functions that do one thing well (Single Responsibility Principle)
- Keep functions reasonably short
- Use meaningful function and parameter names
- Document functions with PHPDoc comments
- Design functions to be testable
- Return early to avoid deeply nested conditionals

```php
/**
 * Calculates the net price after applying a discount percentage.
 * 
 * @param float $price The original price
 * @param float $discountPercent The discount percentage (0-100)
 * @return float The price after discount
 */
function calculateDiscountedPrice(float $price, float $discountPercent): float {
    // Input validation
    if ($price < 0) {
        throw new InvalidArgumentException("Price cannot be negative");
    }
    
    if ($discountPercent < 0 || $discountPercent > 100) {
        throw new InvalidArgumentException("Discount must be between 0 and 100");
    }
    
    $discount = $price * ($discountPercent / 100);
    return $price - $discount;
}

// Usage
try {
    echo calculateDiscountedPrice(100, 20);  // Output: 80
} catch (InvalidArgumentException $e) {
    echo "Error: " . $e->getMessage();
}
```

**Conclusion:** Functions are essential building blocks in PHP programming that allow you to create maintainable, reusable, and well-structured code. Understanding their creation, parameters, scope, and type systems will significantly improve your PHP programming skills. As your applications grow in complexity, properly designed functions become crucial for keeping your code organized and manageable.

---

