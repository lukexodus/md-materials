## PHP Syntax and Basic Concepts


### PHP Tags and Embedding PHP in HTML

PHP is a server-side scripting language designed to be embedded within HTML. This unique feature allows developers to mix HTML and PHP code in the same file, making it especially powerful for web development.

#### Standard PHP Tags

The standard way to embed PHP code within HTML is by using the `<?php` opening tag and the `?>` closing tag.

**Key Points:**

- PHP code is executed on the server before the page is sent to the browser
- Any text outside the PHP tags is sent directly to the output
- The closing PHP tag is optional at the end of a file (and often omitted to prevent accidental whitespace output)

**Example:**

```php
<!DOCTYPE html>
<html>
<head>
    <title>My PHP Page</title>
</head>
<body>
    <h1>Welcome to my website</h1>
    
    <?php
    // This is PHP code
    $greeting = "Hello, World!";
    echo $greeting;
    ?>
    
    <p>This is regular HTML again.</p>
    
    <?php echo "The current time is: " . date("H:i:s"); ?>
</body>
</html>
```

**Output:**

```
Welcome to my website

Hello, World!

This is regular HTML again.

The current time is: 14:35:42
```

#### Short Echo Tags

PHP also supports a shorthand syntax for outputting content using `<?=` which is equivalent to `<?php echo`.

**Example:**

```php
<p>The sum of 5 + 7 is: <?= 5 + 7 ?></p>
```

**Output:**

```
The sum of 5 + 7 is: 12
```

#### Important Notes About PHP Tags

- Short tags (`<?` and `?>`) are discouraged as they may not be enabled in all PHP installations
- PHP files containing only PHP code (like classes or functions) should omit the closing `?>` tag to prevent unexpected output
- PHP code within tags is case-sensitive, while HTML tags are not

### Variables, Constants, and Data Types

#### PHP Variables

Variables in PHP start with a dollar sign ($) followed by the variable name. They are used to store and manipulate data.

**Key Points:**

- Variable names are case-sensitive (`$name` and `$Name` are different variables)
- Variable names must start with a letter or underscore, followed by any number of letters, numbers, or underscores
- Variables do not need to be declared before assignment
- PHP is loosely typed, so variables can change type during execution

**Example:**

```php
<?php
$name = "John";
$age = 30;
$isStudent = true;

echo $name;  // Outputs: John
$name = "Jane";
echo $name;  // Outputs: Jane

// Variable interpolation in strings
echo "My name is $name and I am $age years old.";
// Outputs: My name is Jane and I am 30 years old.

// Alternative way using concatenation
echo 'My name is ' . $name . ' and I am ' . $age . ' years old.';
?>
```

#### Variable Scope

PHP has several variable scopes:

**Key Points:**

- Local: Variables declared within a function
- Global: Variables declared outside functions
- Static: Local variables that retain their value between function calls
- Superglobals: Special variables accessible from anywhere (`$_GET`, `$_POST`, `$_SESSION`, etc.)

**Example:**

```php
<?php
$globalVar = "I'm global";  // Global scope

function testScope() {
    $localVar = "I'm local";  // Local scope
    global $globalVar;  // Access global variable
    echo $globalVar;  // Outputs: I'm global
    
    static $counter = 0;  // Static variable
    $counter++;
    echo "Function called $counter time(s)";
}

testScope();  // Outputs: I'm global Function called 1 time(s)
testScope();  // Outputs: I'm global Function called 2 time(s)

// Accessing superglobals
echo $_SERVER['PHP_SELF'];  // Outputs the current script path
?>
```

#### PHP Constants

Constants store values that don't change during script execution.

**Key Points:**

- Defined using the `define()` function or `const` keyword
- No dollar sign prefix
- Case-sensitive by default
- Available globally throughout the script
- Cannot be redefined once set

**Example:**

```php
<?php
// Using define()
define("PI", 3.14159);
define("SITE_NAME", "My PHP Website");

// Using const keyword (PHP 5.3+)
const DATABASE_HOST = "localhost";
const MAX_USERS = 100;

echo PI;  // Outputs: 3.14159
echo SITE_NAME;  // Outputs: My PHP Website

// PHP also has predefined constants
echo PHP_VERSION;  // Outputs the PHP version
echo __FILE__;  // Outputs the full path to the current file
?>
```

#### PHP Data Types

PHP supports several primitive data types and compound types.

**Key Points:**

- PHP automatically converts between types as needed (type juggling)
- The `gettype()` function returns the current type of a variable
- Type casting can be done with `(type)` syntax

##### Scalar Types:

1. **Integer** - Whole numbers without decimal points

```php
$intVar = 42;
$negativeInt = -7;
$octalInt = 0755;  // Octal (begins with 0)
$hexInt = 0xFF;    // Hexadecimal (begins with 0x)
$binaryInt = 0b101010;  // Binary (begins with 0b)
```

2. **Float (Double)** - Numbers with decimal points or in exponential form

```php
$floatVar = 3.14;
$scientificNotation = 2.5e3;  // 2500
```

3. **String** - Sequence of characters

```php
$singleQuoted = 'Hello';  // Variables not interpolated
$doubleQuoted = "Hello $name";  // Variables are interpolated
$heredoc = <<<EOD
Multi-line string
with variable interpolation: $name
EOD;

$nowdoc = <<<'EOD'
Multi-line string
without variable interpolation: $name
EOD;
```

4. **Boolean** - True or false values

```php
$isActive = true;
$isCompleted = false;
```

##### Compound Types:

1. **Array** - Ordered map that can hold multiple values

```php
// Indexed array
$fruits = ["apple", "banana", "cherry"];
echo $fruits[0];  // Outputs: apple

// Associative array
$person = [
    "name" => "John",
    "age" => 30,
    "city" => "New York"
];
echo $person["name"];  // Outputs: John

// Multidimensional array
$contacts = [
    ["name" => "John", "phone" => "1234567890"],
    ["name" => "Jane", "phone" => "0987654321"]
];
echo $contacts[1]["phone"];  // Outputs: 0987654321
```

2. **Object** - Instance of a class

```php
class Person {
    public $name;
    
    public function __construct($name) {
        $this->name = $name;
    }
    
    public function greet() {
        return "Hello, my name is " . $this->name;
    }
}

$john = new Person("John");
echo $john->greet();  // Outputs: Hello, my name is John
```

##### Special Types:

1. **NULL** - Represents a variable with no value

```php
$var = NULL;
$var = null;  // Case-insensitive
```

2. **Resource** - Reference to external resources (like database connections)

```php
$file = fopen("example.txt", "r");  // $file is a resource
```

#### Type Checking and Conversion

PHP provides several functions for checking and converting types:

**Key Points:**

- `is_*` functions check if a variable is of a specific type
- Type casting converts variables from one type to another
- PHP will automatically convert types in many contexts (type juggling)

**Example:**

```php
<?php
$var = "42";

// Type checking
var_dump(is_string($var));  // bool(true)
var_dump(is_int($var));     // bool(false)

// Type casting
$intVar = (int)$var;
var_dump($intVar);  // int(42)

$floatVar = (float)$var;
var_dump($floatVar);  // float(42)

$boolVar = (bool)$var;
var_dump($boolVar);  // bool(true)

// Automatic type conversion
echo "5" + 2;  // Outputs: 7 (string converted to int)
echo 5 . "2";  // Outputs: 52 (int converted to string)
?>
```

### Operators in PHP

PHP offers a rich set of operators for performing operations on variables and values.

#### Arithmetic Operators

Used for performing basic mathematical operations.

**Key Points:**

- Basic math operations: addition, subtraction, multiplication, division
- Modulus operator returns the remainder of a division
- Exponentiation operator raises one number to the power of another

**Example:**

```php
<?php
$a = 10;
$b = 3;

echo $a + $b;  // Addition: 13
echo $a - $b;  // Subtraction: 7
echo $a * $b;  // Multiplication: 30
echo $a / $b;  // Division: 3.3333...
echo $a % $b;  // Modulus: 1
echo $a ** $b; // Exponentiation: 1000

// Increment and decrement
$c = 5;
echo ++$c;     // Pre-increment: 6
echo $c++;     // Post-increment: 6 (but $c becomes 7)
echo --$c;     // Pre-decrement: 6
echo $c--;     // Post-decrement: 6 (but $c becomes 5)
?>
```

#### Assignment Operators

Used to assign values to variables, often combined with arithmetic operations.

**Key Points:**

- The basic assignment operator is `=`
- Combined operators perform an operation and assignment in one step
- Shorthand for common operations

**Example:**

```php
<?php
$a = 10;  // Basic assignment

// Combined assignment operators
$a += 5;   // Same as: $a = $a + 5;  (Now $a is 15)
$a -= 3;   // Same as: $a = $a - 3;  (Now $a is 12)
$a *= 2;   // Same as: $a = $a * 2;  (Now $a is 24)
$a /= 4;   // Same as: $a = $a / 4;  (Now $a is 6)
$a %= 4;   // Same as: $a = $a % 4;  (Now $a is 2)

$str = "Hello";
$str .= " World";  // String concatenation assignment: "Hello World"
?>
```

#### Comparison Operators

Used to compare two values and return a boolean result.

**Key Points:**

- Return `true` or `false` based on the comparison
- Value comparison vs. identical comparison (value and type)
- Spaceship operator (`<=>`) returns -1, 0, or 1 depending on comparison result

**Example:**

```php
<?php
$x = 10;
$y = "10";
$z = 5;

var_dump($x == $y);   // Equal: bool(true) - values are equal
var_dump($x === $y);  // Identical: bool(false) - different types
var_dump($x != $y);   // Not equal: bool(false)
var_dump($x !== $y);  // Not identical: bool(true)
var_dump($x < $z);    // Less than: bool(false)
var_dump($x > $z);    // Greater than: bool(true)
var_dump($x <= $z);   // Less than or equal to: bool(false)
var_dump($x >= $z);   // Greater than or equal to: bool(true)

// Spaceship operator (PHP 7+)
echo 1 <=> 1;  // Outputs: 0  (equal)
echo 1 <=> 2;  // Outputs: -1 (first is smaller)
echo 2 <=> 1;  // Outputs: 1  (first is greater)
?>
```

#### Logical Operators

Used to combine conditional statements and perform logical operations.

**Key Points:**

- Allow complex conditions by combining multiple boolean expressions
- Short-circuit evaluation: `&&` and `||` stop evaluating as soon as the result is determined
- `and` and `or` have lower precedence than `&&` and `||`

**Example:**

```php
<?php
$a = true;
$b = false;

var_dump($a && $b);  // Logical AND: bool(false)
var_dump($a || $b);  // Logical OR: bool(true)
var_dump(!$a);       // Logical NOT: bool(false)
var_dump($a and $b); // Alternative AND: bool(false)
var_dump($a or $b);  // Alternative OR: bool(true)
var_dump($a xor $b); // Logical XOR: bool(true) - true if one is true but not both

// Short-circuit example
$x = 10;
$result = ($x > 5 && functionThatMightNotRun());  // functionThatMightNotRun is executed
$result = ($x < 5 && functionThatWontRun());      // functionThatWontRun is not executed

// Precedence example (be careful)
$result = false || true && false;  // Evaluates to false because && has higher precedence
$result = (false || true) && false;  // Evaluates to false
?>
```

#### String Operators

PHP has two string operators:

**Key Points:**

- `.` for concatenation (joining strings)
- `.=` for concatenation assignment

**Example:**

```php
<?php
$firstName = "John";
$lastName = "Doe";

$fullName = $firstName . " " . $lastName;  // Concatenation: "John Doe"

$greeting = "Hello, ";
$greeting .= $fullName;  // Concatenation assignment: "Hello, John Doe"
?>
```

#### Array Operators

Operators for working with arrays.

**Key Points:**

- Union: combines arrays, with keys from the left array taking precedence
- Equality: arrays have the same key/value pairs
- Identity: arrays have same key/value pairs in same order and types
- Array spread operator (PHP 7.4+): unpacks arrays

**Example:**

```php
<?php
$arr1 = ["a" => "apple", "b" => "banana"];
$arr2 = ["b" => "berry", "c" => "cherry"];

// Union operator
$result = $arr1 + $arr2;  // ["a" => "apple", "b" => "banana", "c" => "cherry"]

// Comparison
var_dump($arr1 == $arr2);  // Equality: bool(false)
var_dump($arr1 === $arr2); // Identity: bool(false)
var_dump($arr1 != $arr2);  // Inequality: bool(true)
var_dump($arr1 <> $arr2);  // Inequality (alternative): bool(true)
var_dump($arr1 !== $arr2); // Non-identity: bool(true)

// Array spread operator (PHP 7.4+)
$fruits = ["apple", "banana"];
$morefruits = ["cherry", "date"];
$allfruits = [...$fruits, ...$morefruits];  // ["apple", "banana", "cherry", "date"]
?>
```

#### Conditional (Ternary) Operator

A shorthand way of writing if-else statements.

**Key Points:**

- Format: `condition ? value_if_true : value_if_false`
- Shorthand ternary (PHP 5.3+): `condition ?: value_if_false` (returns condition if true)
- Null coalescing (PHP 7+): `$var ?? 'default'` (returns default if $var is null)

**Example:**

```php
<?php
$age = 20;

// Full ternary
$status = ($age >= 18) ? "adult" : "minor";
echo $status;  // Outputs: adult

// Shorthand ternary (returns the tested expression if true)
$username = $_GET['user'] ?: 'guest';

// Null coalescing
$name = $username ?? 'Unknown';  // $name is 'Unknown' if $username is null
?>
```

#### Error Control Operator

The `@` operator suppresses error messages from an expression.

**Key Points:**

- Placed before an expression
- Suppresses error messages but the operation still fails
- Not recommended for general use (makes debugging difficult)

**Example:**

```php
<?php
// Without error control - would produce a warning
$content = file_get_contents("nonexistent-file.txt");

// With error control - suppresses the warning
$content = @file_get_contents("nonexistent-file.txt");

// Better approach - explicit error handling
if (file_exists("nonexistent-file.txt")) {
    $content = file_get_contents("nonexistent-file.txt");
} else {
    $content = "File not found";
}
?>
```

#### Execution Operator

The backtick operator (``) executes a command and returns the output.

**Key Points:**

- Equivalent to `shell_exec()`
- Security risk if used with unfiltered user input
- Availability depends on server configuration

**Example:**

```php
<?php
$output = `ls -la`;  // Executes 'ls -la' command on Unix-like systems
echo $output;

// Better alternative using escapeshellcmd for security
$command = escapeshellcmd('ls -la');
$output = shell_exec($command);
echo $output;
?>
```

#### Type Operators

Operators for checking and working with object types.

**Key Points:**

- `instanceof` checks if an object is an instance of a class
- Can check against class names, interfaces, and parent classes

**Example:**

```php
<?php
class MyClass {}
class ChildClass extends MyClass {}

$obj = new ChildClass();

var_dump($obj instanceof MyClass);     // bool(true)
var_dump($obj instanceof ChildClass);  // bool(true)
var_dump($obj instanceof stdClass);    // bool(false)
?>
```

### Related Topics

- Control structures (if, else, switch, loops)
- PHP functions and parameters
- Error handling with try/catch
- Including external PHP files with require and include
- Working with forms and user input

---

