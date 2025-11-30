# Syllabus

## Phase 1: PHP Fundamentals (4 weeks)

### Week 1: Introduction to PHP

- **Day 1-2:** PHP installation and environment setup
    - Installing XAMPP/WAMP/MAMP
    - Configuring your development environment
    - PHP with built-in server
- **Day 3-4:** PHP syntax and basic concepts
    - PHP tags and embedding PHP in HTML
    - Variables, constants, and data types
    - Operators (arithmetic, comparison, logical)
- **Day 5-7:** Control structures
    - Conditional statements (if, else, elseif, switch)
    - Loops (for, while, do-while, foreach)
    - Break and continue statements

### Week 2: PHP Functions and Arrays

- **Day 1-2:** Functions
    - Creating and calling functions
    - Parameters and return values
    - Variable scope
    - Type declarations and return types
- **Day 3-5:** Arrays
    - Indexed arrays, associative arrays, multidimensional arrays
    - Array functions (count, sort, array_push, array_pop, array_merge)
    - Array iteration techniques
- **Day 6-7:** Form handling
    - $_GET and $_POST superglobals
    - Form validation basics
    - File uploads with $_FILES

### Week 3: Working with Data

- **Day 1-2:** String manipulation
    - String functions (strlen, strpos, str_replace, etc.)
    - Regular expressions with preg_match and preg_replace
- **Day 3-4:** Date and time handling
    - Working with DateTime objects
    - Formatting dates
    - Time zone handling
- **Day 5-7:** File system operations
    - Reading and writing files
    - Directory operations
    - File permissions and security considerations

### Week 4: State Management and Cookies

- **Day 1-3:** Sessions
    - Starting and configuring sessions
    - Session variables
    - Session security
- **Day 4-5:** Cookies
    - Creating and reading cookies
    - Cookie parameters and security
- **Day 6-7:** Project: Build a simple authentication system

## Phase 2: Intermediate PHP Development (6 weeks)

### Week 5: Object-Oriented PHP

- **Day 1-2:** Classes and objects
    - Creating classes and instantiating objects
    - Properties and methods
    - Constructors and destructors
- **Day 3-4:** Inheritance and polymorphism
    - Extending classes
    - Method overriding
    - Abstract classes and interfaces
- **Day 5-7:** Advanced OOP concepts
    - Namespaces
    - Traits
    - Static methods and properties
    - Magic methods

### Week 6: Database Integration

- **Day 1-2:** SQL fundamentals review
    - Basic queries (SELECT, INSERT, UPDATE, DELETE)
    - Joins and relationships
- **Day 3-4:** PHP Database API (PDO)
    - Database connections
    - Prepared statements
    - Error handling
- **Day 5-7:** Project: Build a CRUD application

### Week 7: Security Best Practices

- **Day 1-2:** Common vulnerabilities
    - SQL injection prevention
    - Cross-site scripting (XSS)
    - Cross-site request forgery (CSRF)
- **Day 3-4:** Input validation and sanitization
    - Filter functions
    - Escaping output
- **Day 5-7:** Authentication and authorization
    - Secure password hashing with password_hash()
    - Role-based access control

### Week 8: Error Handling and Debugging

- **Day 1-2:** Error types and handling
    - Error reporting configuration
    - try-catch blocks
    - Custom error handlers
- **Day 3-4:** Logging
    - Error logging
    - Application logging
- **Day 5-7:** Debugging techniques
    - Using var_dump() and print_r()
    - Xdebug installation and configuration
    - Debugging tools and IDEs

### Week 9: PHP and APIs

- **Day 1-3:** Consuming APIs
    - HTTP requests with cURL
    - Working with JSON and XML
    - API authentication methods
- **Day 4-7:** Creating RESTful APIs
    - REST principles
    - Designing API endpoints
    - Response formatting
    - Project: Build a simple REST API

### Week 10: Advanced PHP Techniques

- **Day 1-2:** Dependency management with Composer
    - Installing and using packages
    - Creating composer.json
    - Autoloading
- **Day 3-4:** PHP design patterns
    - Singleton, Factory, Observer
    - MVC architecture
- **Day 5-7:** Performance optimization
    - Caching strategies
    - Code optimization techniques
    - PHP opcode caching

## Phase 3: Modern PHP and Frameworks (8 weeks)

### Week 11: Introduction to Laravel

- **Day 1-2:** Laravel installation and configuration
    - Installing via Composer
    - Directory structure
    - Configuration files
- **Day 3-5:** Routing and controllers
    - Defining routes
    - Creating controllers
    - Request and response handling
- **Day 6-7:** Blade templating system
    - Template syntax
    - Layouts and sections
    - Components and slots

### Week 12: Laravel Database Interaction

- **Day 1-3:** Eloquent ORM
    - Models and relationships
    - Querying with Eloquent
    - Migrations and database seeding
- **Day 4-7:** Laravel authentication
    - Built-in authentication system
    - Custom authentication
    - Middleware

### Week 13-14: Laravel Advanced Topics

- **Day 1-3:** Laravel middleware
    - Built-in middleware
    - Creating custom middleware
- **Day 4-7:** Events and listeners
    - Creating and dispatching events
    - Registering listeners
- **Day 8-10:** Jobs and queues
    - Creating jobs
    - Queue configuration
    - Supervisors
- **Day 11-14:** Laravel project: Build a fully featured web application

### Week 15: Symfony Framework Introduction

- **Day 1-2:** Symfony installation and configuration
- **Day 3-5:** Symfony components
    - HttpFoundation, Routing, DependencyInjection
- **Day 6-7:** Twig templating

### Week 16: Modern PHP Development Practices

- **Day 1-3:** Testing in PHP
    - PHPUnit basics
    - Test-driven development
    - Feature and unit tests
- **Day 4-5:** CI/CD for PHP applications
    - GitHub Actions
    - Automated testing
    - Deployment pipelines
- **Day 6-7:** Docker for PHP development
    - Creating Docker containers for PHP
    - Docker Compose for multi-container setups

### Week 17: Web Services and Microservices

- **Day 1-3:** Building microservices with PHP
    - API design principles
    - Service communication
- **Day 4-7:** Message queues
    - RabbitMQ or Redis integration
    - Handling asynchronous tasks

### Week 18: Final Project

- Develop a complete, production-ready PHP application integrating all learned concepts
- Implement advanced features like:
    - OAuth authentication
    - WebSockets for real-time features
    - Payment gateway integration
    - Comprehensive testing

## Learning Resources

### Books

- "PHP & MySQL: Novice to Ninja" by Tom Butler and Kevin Yank
- "Modern PHP" by Josh Lockhart
- "PHP Objects, Patterns, and Practice" by Matt Zandstra
- "Laravel: Up & Running" by Matt Stauffer

### Online Courses

- PHP: The Right Way (phptherightway.com)
- Laracasts (laracasts.com)
- Symfony Cast (symfonycasts.com)
- PHP Academy on Udemy

### Documentation

- PHP Official Documentation (php.net/docs.php)
- Laravel Documentation (laravel.com/docs)
- Symfony Documentation (symfony.com/doc)

### Tools

- PHPStorm or Visual Studio Code with PHP extensions
- Xdebug for debugging
- Composer for dependency management
- Git for version control
- Docker for containerization

## Assessment Methods

### Weekly Coding Challenges

- Mini-projects solving real-world problems
- Code reviews with peers or mentors

### Phase Projects

- End-of-phase projects demonstrating cumulative knowledge
- Documentation requirements for all projects

### Final Certification Project

- Complete full-stack application with documentation
- Presentation and defense of architectural decisions

## Continuing Education

### Community Involvement

- Contribute to open-source PHP projects
- Participate in PHP user groups
- Attend PHP conferences (PHP[tek], Laracon)

### Specialized Paths After Completion

- PHP Security Specialist
- Laravel Framework Expert
- API Development Specialist
- Full-Stack PHP Developer

---

# Introduction to PHP

## PHP Installation and Environment Setup

### Understanding PHP Development Environments

PHP requires a server environment to run properly. While you can write PHP code in any text editor, you need a proper server environment to execute and test it. The most common approach for local development is using an all-in-one package that includes PHP, a web server (usually Apache), and a database (usually MySQL).

### XAMPP Installation

XAMPP is a free, open-source cross-platform web server solution that includes Apache, MySQL, PHP, and Perl. It's available for Windows, macOS, and Linux.

**Key Points:**

- XAMPP stands for Cross-Platform (X), Apache (A), MySQL (M), PHP (P), and Perl (P)
- It provides an easy-to-install package with all components preconfigured
- Ideal for beginners as it requires minimal setup

**Installation Steps:**

1. Download XAMPP from the official website: https://www.apachefriends.org/
2. Run the installer and follow the prompts
3. Select components to install (Apache and PHP are essential, MySQL recommended)
4. Choose installation directory (default is often C:\xampp on Windows)
5. Complete installation and launch XAMPP Control Panel
6. Start Apache service (and MySQL if needed)

**Example:**

```bash
# On Linux, you might install XAMPP with:
chmod 755 xampp-linux-x64-8.1.6-0-installer.run
sudo ./xampp-linux-x64-8.1.6-0-installer.run
```

**Testing Your Installation:** After installing XAMPP, navigate to http://localhost/ in your browser. If you see the XAMPP welcome page, your installation was successful.

### WAMP Installation (Windows)

WAMP (Windows, Apache, MySQL, PHP) is a Windows-specific development environment.

**Key Points:**

- Designed specifically for Windows systems
- Often easier to configure on Windows than other options
- Includes phpMyAdmin for database management

**Installation Steps:**

1. Download WampServer from https://www.wampserver.com/en/
2. Run the installer and follow the prompts
3. Select your default browser and PHP version
4. Complete installation and launch WampServer
5. The WAMP icon in the system tray should turn green when all services are running

**Testing Your Installation:** Navigate to http://localhost/ in your browser. You should see the WAMP server home page.

### MAMP Installation (macOS)

MAMP (macOS, Apache, MySQL, PHP) is designed specifically for macOS.

**Key Points:**

- Available in free and pro versions
- Pro version offers additional features like virtual hosts and mobile testing
- Simple, intuitive interface designed for macOS

**Installation Steps:**

1. Download MAMP from https://www.mamp.info/
2. Mount the disk image and drag MAMP to your Applications folder
3. Launch MAMP and click Start Servers
4. Configure ports if needed (default 8888 for web server)

**Testing Your Installation:** MAMP will automatically open http://localhost:8888/MAMP/ in your browser after starting the servers. If you see the MAMP start page, your installation is working.

### Configuring Your Development Environment

Once your package (XAMPP/WAMP/MAMP) is installed, you'll need to configure it for optimal development.

#### Document Root Configuration

The document root is where your web server looks for files to serve.

**Key Points:**

- Default document root in XAMPP: `xampp/htdocs/`
- Default document root in WAMP: `wamp/www/`
- Default document root in MAMP: `MAMP/htdocs/`

**Example - Creating a Project:**

```
1. Create a folder in your document root: htdocs/my_project/
2. Add an index.php file with sample PHP code
3. Access it via http://localhost/my_project/
```

#### PHP Configuration (php.ini)

The php.ini file controls PHP's behavior. Common settings to adjust include:

**Key Points:**

- Memory limits: `memory_limit = 256M`
- Upload file size: `upload_max_filesize = 20M` and `post_max_size = 20M`
- Error reporting: `display_errors = On` (for development)
- Timezone: `date.timezone = "America/New_York"`

**Example - Editing php.ini:**

```
# In XAMPP: Edit xampp/php/php.ini
# In WAMP: Click on WAMP icon → PHP → php.ini
# In MAMP: MAMP → File → Edit Template → PHP → php.ini
```

#### Virtual Hosts Configuration

Virtual hosts allow you to run multiple websites on a single server, each with its own domain name.

**Key Points:**

- Improves workflow by using domain names instead of paths
- More closely mimics production environments
- Requires editing two files: httpd-vhosts.conf and hosts file

**Example - Setting Up a Virtual Host in XAMPP:**

1. Edit `xampp/apache/conf/extra/httpd-vhosts.conf`:

```apache
<VirtualHost *:80>
    DocumentRoot "C:/xampp/htdocs"
    ServerName localhost
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot "C:/xampp/htdocs/my_project"
    ServerName myproject.local
    <Directory "C:/xampp/htdocs/my_project">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

2. Edit your hosts file (`C:\Windows\System32\drivers\etc\hosts` on Windows):

```
127.0.0.1 localhost
127.0.0.1 myproject.local
```

3. Restart Apache

### PHP with Built-in Server

Since PHP 5.4, PHP includes a built-in web server for development purposes. This is especially useful for quick testing or when you can't install a full server package.

**Key Points:**

- No installation required beyond PHP itself
- Limited to development use (not suitable for production)
- Simple to use with a single command
- Runs on a specified port (default 8000)

**Starting the Built-in Server:**

```bash
# Navigate to your project directory
cd /path/to/your/project

# Start PHP server on port 8000
php -S localhost:8000
```

**Example - Creating a Simple Test with Built-in Server:**

1. Create a directory for your project
2. Create an index.php file:

```php
<?php
phpinfo();
?>
```

3. Start the server and point to your project directory:

```bash
php -S localhost:8000 -t /path/to/your/project
```

4. Access http://localhost:8000 in your browser

**Limitations of the Built-in Server:**

- Single-threaded (handles one request at a time)
- No support for .htaccess files
- Limited MIME type support
- No built-in support for PHP opcode caching

### Verifying Your PHP Installation

Once your environment is set up, verify that PHP is working correctly.

**Key Points:**

- Check PHP version and configuration
- Ensure proper execution of PHP code
- Verify extension availability

**Example - Creating a Test File:**

Create a file named `info.php` in your document root with the following content:

```php
<?php
phpinfo();
?>
```

Access this file through your web server (e.g., http://localhost/info.php). You should see a detailed PHP information page showing your version, configuration settings, and enabled extensions.

**Security Note:** Remove or restrict access to this file in production environments, as it reveals sensitive information about your server configuration.

### Development Tools for PHP

To enhance your PHP development experience, consider these additional tools:

**Code Editors/IDEs:**

- Visual Studio Code with PHP extensions
- PhpStorm (paid, comprehensive PHP IDE)
- Sublime Text with PHP plugins
- Notepad++ (Windows) with PHP plugins

**Development Helpers:**

- Xdebug for debugging and profiling
- Composer for dependency management
- Git for version control
- Browser developer tools for frontend debugging

### Troubleshooting Common Setup Issues

**Port Conflicts:** If Apache won't start, another application may be using port 80. Check for IIS, Skype, or other web servers. You can change Apache's port in httpd.conf.

**Missing Extensions:** If your code requires extensions like mysqli or curl, ensure they're enabled in php.ini (remove the semicolon before the extension line).

**Permission Issues:** On Linux/macOS, ensure your web server has appropriate permissions to read/write to your project directories.

### Related Topics

- PHP version management tools (like PHPBrew or php-version)
- Docker for containerized PHP development environments
- Production server setup and differences from development environments
- Introduction to PHP frameworks and their specific environment requirements

---

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

## Control Structures

### Conditional Statements

Conditional statements allow you to execute different code blocks based on whether certain conditions are true or false. PHP provides several structures for conditional execution.

#### If Statement

The `if` statement is the most basic conditional statement, executing code only when a condition evaluates to true.

**Key Points:**

- The condition must evaluate to a boolean value
- Code within curly braces executes only if the condition is true
- Single-line statements can omit braces (not recommended for readability)
- Multiple conditions can be combined using logical operators

**Example:**

```php
<?php
$age = 25;

if ($age >= 18) {
    echo "You are an adult.";
}

// With multiple conditions
$username = "admin";
$password = "secure123";

if ($username === "admin" && $password === "secure123") {
    echo "Login successful.";
}

// Alternative syntax (useful in templates)
if ($age >= 18):
    echo "You are an adult.";
    echo "You can vote.";
endif;
?>
```

#### If-Else Statement

The `if-else` statement provides an alternative code block to execute when the condition is false.

**Key Points:**

- Only one block will execute—either the if block or the else block
- The else block is optional
- The else block executes only when the if condition is false

**Example:**

```php
<?php
$temperature = 15;

if ($temperature > 20) {
    echo "It's warm outside.";
} else {
    echo "It's cool outside.";
}

// Alternative syntax
if ($temperature > 20):
    echo "It's warm outside.";
else:
    echo "It's cool outside.";
endif;
?>
```

#### If-Elseif-Else Statement

For testing multiple conditions in sequence, the `elseif` statement allows you to check additional conditions when previous ones are false.

**Key Points:**

- You can have multiple elseif blocks
- Conditions are evaluated in order from top to bottom
- Only the first true condition's block will execute
- The else block executes only if all conditions are false
- You can use `elseif` or `else if` (they are identical)

**Example:**

```php
<?php
$score = 85;

if ($score >= 90) {
    echo "Grade: A";
} elseif ($score >= 80) {
    echo "Grade: B";
} elseif ($score >= 70) {
    echo "Grade: C";
} elseif ($score >= 60) {
    echo "Grade: D";
} else {
    echo "Grade: F";
}

// Alternative syntax
if ($score >= 90):
    echo "Grade: A";
elseif ($score >= 80):
    echo "Grade: B";
elseif ($score >= 70):
    echo "Grade: C";
elseif ($score >= 60):
    echo "Grade: D";
else:
    echo "Grade: F";
endif;
?>
```

#### Nested If Statements

Conditional statements can be nested inside other conditional statements to create more complex logic structures.

**Key Points:**

- Nesting can create complex conditions
- Excessive nesting reduces readability
- Consider refactoring deeply nested conditions

**Example:**

```php
<?php
$authenticated = true;
$isAdmin = true;
$hasPermission = false;

if ($authenticated) {
    if ($isAdmin) {
        echo "Welcome, Administrator!";
    } else {
        if ($hasPermission) {
            echo "Welcome, User with permissions!";
        } else {
            echo "Welcome, Regular user!";
        }
    }
} else {
    echo "Please log in.";
}

// Better approach with combined conditions
if (!$authenticated) {
    echo "Please log in.";
} elseif ($isAdmin) {
    echo "Welcome, Administrator!";
} elseif ($hasPermission) {
    echo "Welcome, User with permissions!";
} else {
    echo "Welcome, Regular user!";
}
?>
```

#### Switch Statement

The `switch` statement is an alternative to multiple if-elseif statements when comparing a single variable against multiple possible values.

**Key Points:**

- Compares an expression against multiple possible values
- Each case represents a possible value
- The `break` statement prevents fall-through to subsequent cases
- The `default` case executes when no case matches
- Cases are evaluated using loose comparison (==) by default

**Example:**

```php
<?php
$dayOfWeek = 3;

switch ($dayOfWeek) {
    case 1:
        echo "Monday";
        break;
    case 2:
        echo "Tuesday";
        break;
    case 3:
        echo "Wednesday";
        break;
    case 4:
        echo "Thursday";
        break;
    case 5:
        echo "Friday";
        break;
    case 6:
    case 7:
        echo "Weekend";
        break;
    default:
        echo "Invalid day";
        break;
}

// Alternative syntax
switch ($dayOfWeek):
    case 1:
        echo "Monday";
        break;
    case 2:
        echo "Tuesday";
        break;
    // ... other cases
    default:
        echo "Invalid day";
        break;
endswitch;
?>
```

#### Fall-through Behavior in Switch

Without a `break` statement, execution "falls through" to the next case, which can be useful in some scenarios.

**Example:**

```php
<?php
$permissions = 2;

switch ($permissions) {
    case 3: // Admin
        echo "Can delete content. ";
        // Fall through to next case
    case 2: // Editor
        echo "Can edit content. ";
        // Fall through to next case
    case 1: // Viewer
        echo "Can view content.";
        break;
    default:
        echo "No permissions.";
}

// For permission level 2, outputs: "Can edit content. Can view content."
?>
```

#### Match Expression (PHP 8.0+)

The `match` expression is a modern alternative to `switch` that returns values and uses strict comparison.

**Key Points:**

- Uses strict comparison (===)
- Returns a value (can be assigned to a variable)
- No break statements needed (no fall-through)
- Throws an exception if no case matches (unless default is provided)
- More concise syntax than switch

**Example:**

```php
<?php
$dayOfWeek = 3;

$day = match ($dayOfWeek) {
    1 => "Monday",
    2 => "Tuesday",
    3 => "Wednesday",
    4 => "Thursday",
    5 => "Friday",
    6, 7 => "Weekend",
    default => "Invalid day"
};

echo $day; // Outputs: Wednesday

// Match expressions can use complex conditions too
$result = match (true) {
    $age >= 65 => "Senior",
    $age >= 18 => "Adult",
    default => "Minor"
};
?>
```

#### Ternary Operator

The ternary operator provides a concise way to write simple if-else conditions.

**Key Points:**

- Format: `condition ? value_if_true : value_if_false`
- Good for simple conditional assignments
- Can be nested but becomes hard to read
- PHP has a shorthand form: `expr1 ?: expr3` (returns expr1 if true)

**Example:**

```php
<?php
$age = 20;

// Traditional if-else
if ($age >= 18) {
    $status = "Adult";
} else {
    $status = "Minor";
}

// Same logic with ternary operator
$status = ($age >= 18) ? "Adult" : "Minor";

// Shorthand ternary (returns the tested expression if true)
$username = $_GET['user'] ?: 'guest';

// Nested ternary (can be hard to read)
$category = ($age >= 65) ? "Senior" : (($age >= 18) ? "Adult" : "Minor");
?>
```

#### Null Coalescing Operator (PHP 7.0+)

The null coalescing operator `??` provides a concise way to handle null values.

**Key Points:**

- Returns the left operand if it exists and is not null
- Otherwise, returns the right operand
- Can be chained for multiple fallbacks
- Useful for providing default values

**Example:**

```php
<?php
// Traditional way
if (isset($_GET['user'])) {
    $username = $_GET['user'];
} else {
    $username = 'guest';
}

// With null coalescing operator
$username = $_GET['user'] ?? 'guest';

// Chained null coalescing
$username = $_GET['user'] ?? $_POST['user'] ?? $_SESSION['user'] ?? 'guest';

// Null coalescing assignment (PHP 7.4+)
$username ??= 'guest'; // Assigns 'guest' only if $username is null
?>
```

### Loops

Loops allow you to execute a block of code repeatedly until a condition is met. PHP provides several loop structures for different scenarios.

#### For Loop

The `for` loop is used when you know exactly how many times you want to execute a block of code.

**Key Points:**

- Consists of three expressions: initialization, condition, and increment/decrement
- All three expressions are optional
- Best used when the number of iterations is known beforehand
- Loop variables are typically named `$i`, `$j`, `$k`, etc.

**Example:**

```php
<?php
// Basic for loop
for ($i = 0; $i < 5; $i++) {
    echo "Iteration: $i<br>";
}

// Multiple counters
for ($i = 0, $j = 10; $i < 5; $i++, $j--) {
    echo "i = $i, j = $j<br>";
}

// Alternative syntax
for ($i = 0; $i < 5; $i++):
    echo "Iteration: $i<br>";
endfor;
?>
```

**Output:**

```
Iteration: 0
Iteration: 1
Iteration: 2
Iteration: 3
Iteration: 4
```

#### While Loop

The `while` loop executes a block of code as long as a condition is true.

**Key Points:**

- Condition is evaluated before each iteration
- If the condition is initially false, the loop never executes
- Best used when the number of iterations is not known beforehand
- Must ensure the condition eventually becomes false to avoid infinite loops

**Example:**

```php
<?php
// Simple while loop
$counter = 0;
while ($counter < 5) {
    echo "Counter: $counter<br>";
    $counter++;
}

// Reading from a file until EOF
$file = fopen("data.txt", "r");
while (!feof($file)) {
    $line = fgets($file);
    echo $line . "<br>";
}
fclose($file);

// Alternative syntax
$counter = 0;
while ($counter < 5):
    echo "Counter: $counter<br>";
    $counter++;
endwhile;
?>
```

**Output:**

```
Counter: 0
Counter: 1
Counter: 2
Counter: 3
Counter: 4
```

#### Do-While Loop

The `do-while` loop is similar to the while loop but guarantees that the code block executes at least once before checking the condition.

**Key Points:**

- Condition is evaluated after each iteration
- The loop always executes at least once
- Best used when you need to ensure the code runs at least once
- Semicolon required after the closing parenthesis

**Example:**

```php
<?php
// Simple do-while loop
$counter = 0;
do {
    echo "Counter: $counter<br>";
    $counter++;
} while ($counter < 5);

// Will execute once even though condition is initially false
$number = 10;
do {
    echo "This will execute once.";
} while ($number < 5);
?>
```

**Output:**

```
Counter: 0
Counter: 1
Counter: 2
Counter: 3
Counter: 4
This will execute once.
```

#### Foreach Loop

The `foreach` loop is specifically designed for iterating over arrays and objects.

**Key Points:**

- Automatically loops through each element in an array or object
- Can retrieve both keys and values
- No need to know the size of the array beforehand
- Very readable and reduces the chance of off-by-one errors

**Example:**

```php
<?php
// Simple foreach with values only
$colors = ["red", "green", "blue", "yellow"];
foreach ($colors as $color) {
    echo "Color: $color<br>";
}

// Foreach with keys and values
$person = [
    "name" => "John",
    "age" => 30,
    "city" => "New York"
];
foreach ($person as $key => $value) {
    echo "$key: $value<br>";
}

// Modifying values by reference
$numbers = [1, 2, 3, 4, 5];
foreach ($numbers as &$number) {
    $number *= 2;
}
unset($number); // Important to unset the reference after the loop
print_r($numbers); // Outputs: Array ( [0] => 2 [1] => 4 [2] => 6 [3] => 8 [4] => 10 )

// Alternative syntax
foreach ($colors as $color):
    echo "Color: $color<br>";
endforeach;
?>
```

**Output:**

```
Color: red
Color: green
Color: blue
Color: yellow

name: John
age: 30
city: New York
```

#### Nested Loops

Loops can be nested inside each other to handle multi-dimensional data structures or complex iterations.

**Key Points:**

- Each nested loop completes all its iterations for each iteration of the outer loop
- Helps process multi-dimensional arrays or complex patterns
- Be cautious of performance with deeply nested loops
- Use descriptive variable names to improve readability

**Example:**

```php
<?php
// Nested for loops - creating a multiplication table
echo "<table border='1'>";
for ($i = 1; $i <= 5; $i++) {
    echo "<tr>";
    for ($j = 1; $j <= 5; $j++) {
        $product = $i * $j;
        echo "<td>$i × $j = $product</td>";
    }
    echo "</tr>";
}
echo "</table>";

// Nested foreach for multi-dimensional arrays
$students = [
    "Class 1" => ["John", "Mary", "Bob"],
    "Class 2" => ["Alice", "David", "Emma"],
    "Class 3" => ["Sarah", "Tom", "Mike"]
];

foreach ($students as $class => $names) {
    echo "<h3>$class</h3>";
    echo "<ul>";
    foreach ($names as $name) {
        echo "<li>$name</li>";
    }
    echo "</ul>";
}
?>
```

### Break and Continue Statements

The `break` and `continue` statements provide additional control over loop execution.

#### Break Statement

The `break` statement terminates the execution of a loop or switch statement.

**Key Points:**

- Immediately exits the loop or switch statement
- Can be used with an optional numeric argument to specify how many levels to break out of
- Particularly useful for early termination when a condition is met
- Common in search algorithms to stop once a value is found

**Example:**

```php
<?php
// Breaking out of a for loop
for ($i = 1; $i <= 10; $i++) {
    if ($i == 5) {
        echo "Breaking at $i<br>";
        break;
    }
    echo "Iteration: $i<br>";
}
// Only outputs iterations 1-4, then the break message

// Breaking out of nested loops
for ($i = 1; $i <= 3; $i++) {
    for ($j = 1; $j <= 3; $j++) {
        echo "i = $i, j = $j<br>";
        if ($i == 2 && $j == 2) {
            echo "Breaking inner loop at i = $i, j = $j<br>";
            break;
        }
    }
}

// Breaking out of multiple levels with numeric argument (requires PHP 7.0+)
for ($i = 1; $i <= 3; $i++) {
    for ($j = 1; $j <= 3; $j++) {
        echo "i = $i, j = $j<br>";
        if ($i == 2 && $j == 2) {
            echo "Breaking both loops at i = $i, j = $j<br>";
            break 2; // Breaks out of both the inner and outer loops
        }
    }
}

// Breaking from a switch statement (already covered in switch section)
// Breaking from a while loop
$counter = 0;
while (true) { // Infinite loop
    $counter++;
    echo "Counter: $counter<br>";
    if ($counter >= 5) {
        break; // Exits the loop when counter reaches 5
    }
}
?>
```

**Output (from first example):**

```
Iteration: 1
Iteration: 2
Iteration: 3
Iteration: 4
Breaking at 5
```

#### Continue Statement

The `continue` statement skips the rest of the current iteration and proceeds to the next iteration of the loop.

**Key Points:**

- Skips remaining code in the current iteration
- Jumps to the next iteration of the loop
- Can be used with an optional numeric argument to specify which level to continue
- Useful for filtering or skipping specific iterations based on conditions

**Example:**

```php
<?php
// Skipping odd numbers
for ($i = 1; $i <= 10; $i++) {
    if ($i % 2 != 0) {
        continue; // Skip odd numbers
    }
    echo "Even number: $i<br>";
}

// Using continue in a nested loop
for ($i = 1; $i <= 3; $i++) {
    for ($j = 1; $j <= 3; $j++) {
        // Skip when both are 2
        if ($i == 2 && $j == 2) {
            echo "Skipping i = $i, j = $j<br>";
            continue;
        }
        echo "i = $i, j = $j<br>";
    }
}

// Using continue with a numeric argument (requires PHP 7.0+)
for ($i = 1; $i <= 3; $i++) {
    echo "Outer loop i = $i<br>";
    for ($j = 1; $j <= 3; $j++) {
        if ($j == 2) {
            echo "Skipping to next i when j = $j<br>";
            continue 2; // Skips to the next iteration of the outer loop
        }
        echo "Inner loop j = $j<br>";
    }
}

// Using continue in a while loop
$counter = 0;
while ($counter < 10) {
    $counter++;
    if ($counter % 3 == 0) {
        continue; // Skip multiples of 3
    }
    echo "Counter: $counter<br>";
}
?>
```

**Output (from first example):**

```
Even number: 2
Even number: 4
Even number: 6
Even number: 8
Even number: 10
```

#### Infinite Loops

An infinite loop is a loop that never terminates because its condition always evaluates to true.

**Key Points:**

- Often created accidentally due to logical errors
- Can be created intentionally with `while(true)` or similar constructs
- Must include a `break` statement to exit
- Can cause server timeouts or memory issues if not properly controlled

**Example:**

```php
<?php
// Intentional infinite loop with break
$counter = 0;
while (true) {
    $counter++;
    echo "Iteration: $counter<br>";
    
    // Exit condition
    if ($counter >= 5) {
        echo "Breaking out of infinite loop<br>";
        break;
    }
}

// Accidental infinite loop (commented out to prevent issues)
/*
$counter = 1;
while ($counter > 0) {
    echo "This will never end!";
    // Counter never decreases, so condition always true
}
*/

// Using an infinite loop for a user menu
/*
while (true) {
    $choice = getUserInput();
    
    switch ($choice) {
        case 1:
            processOption1();
            break;
        case 2:
            processOption2();
            break;
        case 3:
            echo "Exiting...";
            break 2; // Break out of the switch AND while loop
        default:
            echo "Invalid option";
    }
}
*/
?>
```

#### Alternative Syntax for Control Structures

PHP provides an alternative syntax for control structures, which is particularly useful in template files where PHP is mixed with HTML.

**Key Points:**

- Uses colons (:) after the opening statement and ends with an endif/endwhile/endfor/etc.
- More readable when mixed with HTML
- Available for all control structures (if, while, for, foreach, switch)
- The opening and closing tags must be paired correctly

**Example:**

```php
<?php if ($user_logged_in): ?>
    <h1>Welcome, <?= $username ?></h1>
    
    <?php if ($is_admin): ?>
        <div class="admin-panel">
            <h2>Admin Controls</h2>
            <!-- Admin options here -->
        </div>
    <?php else: ?>
        <div class="user-panel">
            <h2>User Options</h2>
            <!-- User options here -->
        </div>
    <?php endif; ?>
    
    <ul class="menu">
        <?php foreach ($menu_items as $item): ?>
            <li><a href="<?= $item['url'] ?>"><?= $item['title'] ?></a></li>
        <?php endforeach; ?>
    </ul>
    
<?php else: ?>
    <h1>Please log in</h1>
    <form method="post" action="login.php">
        <!-- Login form here -->
    </form>
<?php endif; ?>
```

### Related Topics

- Error handling with try/catch blocks
- Goto statement (available but rarely used)
- Function return statements to exit functions
- Array manipulation functions that replace common loop operations
- Pattern matching in PHP 8.0+ using the match expression
- Loop optimization techniques for better performance

---

# PHP Functions and Arrays

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

## PHP Arrays

### Indexed Arrays, Associative Arrays, Multidimensional Arrays

Arrays in PHP are ordered maps that associate values to keys. They're extremely versatile and represent one of PHP's most powerful and flexible data types.

**Key Points:**

- PHP arrays can contain any combination of data types
- Arrays can grow and shrink dynamically
- Array keys can be either integers or strings
- Array values can be any valid PHP data type, including other arrays

#### Indexed Arrays

Indexed arrays use numeric keys starting from 0 by default:

```php
// Creating indexed arrays
$fruits = ["Apple", "Banana", "Cherry"]; // Short syntax
$vegetables = array("Carrot", "Broccoli", "Spinach"); // Traditional syntax

// Accessing elements
echo $fruits[0]; // Output: Apple
echo $vegetables[1]; // Output: Broccoli

// Adding elements
$fruits[] = "Orange"; // Appends to the end
$fruits[4] = "Mango"; // Specifies index explicitly

// The array is now: ["Apple", "Banana", "Cherry", "Orange", "Mango"]
// Note that index 3 was automatically assigned to "Orange"
```

#### Associative Arrays

Associative arrays use string keys to create name-value pairs:

```php
// Creating associative arrays
$person = [
    "name" => "John Doe",
    "age" => 30,
    "email" => "john@example.com"
];

// Alternative syntax
$settings = array(
    "theme" => "dark",
    "notifications" => true,
    "language" => "en"
);

// Accessing elements
echo $person["name"]; // Output: John Doe
echo $settings["theme"]; // Output: dark

// Adding or modifying elements
$person["phone"] = "555-1234";
$person["age"] = 31; // Modifies existing value
```

#### Multidimensional Arrays

Multidimensional arrays contain other arrays as values, creating nested structures:

```php
// Two-dimensional indexed array
$matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
];

// Accessing elements
echo $matrix[0][1]; // Output: 2 (row 0, column 1)
echo $matrix[2][0]; // Output: 7 (row 2, column 0)

// Two-dimensional associative array
$users = [
    "user1" => [
        "name" => "Alice",
        "email" => "alice@example.com",
        "roles" => ["admin", "editor"]
    ],
    "user2" => [
        "name" => "Bob",
        "email" => "bob@example.com",
        "roles" => ["subscriber"]
    ]
];

// Accessing nested elements
echo $users["user1"]["name"]; // Output: Alice
echo $users["user2"]["roles"][0]; // Output: subscriber

// Complex multidimensional array
$organization = [
    "name" => "Acme Corp",
    "departments" => [
        "engineering" => [
            "manager" => "Jane Smith",
            "employees" => [
                ["name" => "Dev One", "position" => "Developer"],
                ["name" => "Dev Two", "position" => "Designer"]
            ]
        ],
        "marketing" => [
            "manager" => "John Brown",
            "employees" => [
                ["name" => "Mark One", "position" => "Copywriter"]
            ]
        ]
    ]
];

// Accessing deeply nested elements
echo $organization["departments"]["engineering"]["employees"][0]["name"]; // Output: Dev One
```

### Array Functions

PHP provides a rich set of built-in functions for working with arrays. Here are some of the most commonly used:

**Key Points:**

- Array functions can manipulate structure, order, and values
- Most array functions return a new array rather than modifying the original
- Some functions operate directly on the array (passing by reference)
- Function naming is often inconsistent (e.g., array_push vs. array_pop)

#### Basic Array Information

```php
// Get array length/count
$numbers = [10, 20, 30, 40, 50];
echo count($numbers); // Output: 5

// Check if a key exists
$user = ["name" => "John", "age" => 30];
var_dump(array_key_exists("email", $user)); // Output: bool(false)
var_dump(isset($user["name"])); // Output: bool(true)

// Check if a value exists
$fruits = ["Apple", "Banana", "Cherry"];
var_dump(in_array("Banana", $fruits)); // Output: bool(true)
var_dump(in_array("Orange", $fruits)); // Output: bool(false)

// Find key for a value
$index = array_search("Cherry", $fruits);
echo $index; // Output: 2
```

#### Adding and Removing Elements

```php
// Add elements to the end
$stack = [1, 2, 3];
array_push($stack, 4, 5); // $stack now contains [1, 2, 3, 4, 5]
// Equivalent to:
$stack[] = 6; // $stack now contains [1, 2, 3, 4, 5, 6]

// Remove and return the last element
$last = array_pop($stack); // $last = 6, $stack now contains [1, 2, 3, 4, 5]

// Add elements to the beginning
$queue = [1, 2, 3];
array_unshift($queue, 0); // $queue now contains [0, 1, 2, 3]

// Remove and return the first element
$first = array_shift($queue); // $first = 0, $queue now contains [1, 2, 3]

// Remove elements by key
$user = ["name" => "John", "age" => 30, "temp" => "value"];
unset($user["temp"]); // $user now contains ["name" => "John", "age" => 30]

// Remove elements by value
$colors = ["red", "green", "blue", "green", "yellow"];
$filtered = array_diff($colors, ["green", "yellow"]);
// $filtered now contains [0 => "red", 2 => "blue"] (original keys preserved)
```

#### Merging and Combining Arrays

```php
// Merge arrays (later values overwrite earlier ones for same string keys)
$array1 = ["color" => "red", 2, 4];
$array2 = ["a", "b", "color" => "green", "shape" => "circle", 10];
$result = array_merge($array1, $array2);
/*
$result now contains:
[
    "color" => "green",
    0 => 2,
    1 => 4,
    2 => "a",
    3 => "b",
    "shape" => "circle",
    4 => 10
]
*/

// Combine two arrays to create key-value pairs
$keys = ["name", "email", "phone"];
$values = ["John Doe", "john@example.com", "555-1234"];
$user = array_combine($keys, $values);
/*
$user now contains:
[
    "name" => "John Doe",
    "email" => "john@example.com",
    "phone" => "555-1234"
]
*/

// Append arrays (numeric re-indexing)
$array1 = [1, 2, 3];
$array2 = [4, 5, 6];
$result = [...$array1, ...$array2]; // PHP 7.4+ spread operator
// $result now contains [1, 2, 3, 4, 5, 6]
```

#### Sorting Arrays

```php
// Sort indexed array in ascending order
$numbers = [3, 1, 4, 1, 5, 9];
sort($numbers); // $numbers is now [1, 1, 3, 4, 5, 9]

// Sort indexed array in descending order
$scores = [85, 92, 78, 95];
rsort($scores); // $scores is now [95, 92, 85, 78]

// Sort associative array by values, maintaining key associations
$ages = ["John" => 35, "Mary" => 27, "Bob" => 42];
asort($ages); // $ages is now ["Mary" => 27, "John" => 35, "Bob" => 42]

// Sort associative array by values in descending order, maintaining key associations
arsort($ages); // $ages is now ["Bob" => 42, "John" => 35, "Mary" => 27]

// Sort associative array by keys
$data = ["z" => 1, "a" => 2, "k" => 3];
ksort($data); // $data is now ["a" => 2, "k" => 3, "z" => 1]

// Sort associative array by keys in descending order
krsort($data); // $data is now ["z" => 1, "k" => 3, "a" => 2]

// Custom sort using user-defined comparison function
$fruits = ["orange", "apple", "banana", "grape"];
usort($fruits, function($a, $b) {
    return strlen($a) - strlen($b); // Sort by string length
});
// $fruits is now ["apple", "grape", "orange", "banana"]
```

#### Array Transformation

```php
// Extract keys from an array
$user = ["name" => "John", "age" => 30, "city" => "New York"];
$keys = array_keys($user); // $keys = ["name", "age", "city"]

// Extract values from an array
$values = array_values($user); // $values = ["John", 30, "New York"]

// Map an array (apply a function to each element)
$numbers = [1, 2, 3, 4, 5];
$squared = array_map(function($n) { return $n * $n; }, $numbers);
// $squared = [1, 4, 9, 16, 25]

// Filter an array
$scores = [85, 92, 78, 95, 67];
$highScores = array_filter($scores, function($score) {
    return $score >= 80;
});
// $highScores = [0 => 85, 1 => 92, 3 => 95] (original keys preserved)

// Reduce an array to a single value
$sum = array_reduce($numbers, function($carry, $item) {
    return $carry + $item;
}, 0);
// $sum = 15 (1 + 2 + 3 + 4 + 5)

// Flip keys and values
$flipped = array_flip(["a" => 1, "b" => 2, "c" => 3]);
// $flipped = [1 => "a", 2 => "b", 3 => "c"]

// Get a slice of an array
$slice = array_slice($numbers, 1, 3); // $slice = [2, 3, 4]

// Chunk an array into groups
$chunks = array_chunk($numbers, 2);
// $chunks = [[1, 2], [3, 4], [5]]
```

### Array Iteration Techniques

PHP offers multiple ways to iterate through arrays, each with its advantages.

**Key Points:**

- Different loop types provide different capabilities (access to keys, values, etc.)
- Iterator objects provide advanced options for complex collections
- Modern PHP provides concise array iteration syntax

#### Using foreach Loop

The `foreach` loop is the most common way to iterate through PHP arrays:

```php
// Basic foreach loop for values only
$colors = ["red", "green", "blue"];
foreach ($colors as $color) {
    echo $color . " ";
}
// Output: red green blue

// Foreach with key and value
$person = ["name" => "John", "age" => 30, "city" => "New York"];
foreach ($person as $key => $value) {
    echo "$key: $value\n";
}
/*
Output:
name: John
age: 30
city: New York
*/

// Modifying values during iteration
$numbers = [1, 2, 3, 4, 5];
foreach ($numbers as &$number) {
    $number *= 2;
}
unset($number); // Important: unset the reference after the loop!
// $numbers now contains [2, 4, 6, 8, 10]
```

#### Using for Loop

For loops can be used with indexed arrays when you need precise control over the iteration:

```php
$fruits = ["Apple", "Banana", "Cherry", "Date"];
for ($i = 0; $i < count($fruits); $i++) {
    echo $fruits[$i] . " ";
}
// Output: Apple Banana Cherry Date

// More efficient version (caching the count)
$count = count($fruits);
for ($i = 0; $i < $count; $i++) {
    echo $fruits[$i] . " ";
}
```

#### Using while and do-while Loops

These loops provide additional flexibility:

```php
// While loop with array_keys and current/next functions
$person = ["name" => "John", "age" => 30, "city" => "New York"];
$keys = array_keys($person);
$i = 0;
while ($i < count($keys)) {
    $key = $keys[$i];
    echo "$key: {$person[$key]}\n";
    $i++;
}

// Using internal array pointer
reset($person); // Reset internal pointer to first element
while (list($key, $value) = each($person)) { // Warning: each() is deprecated in PHP 7.2+
    echo "$key: $value\n";
}

// Alternative using current() and next()
reset($person);
while (key($person) !== null) {
    $key = key($person);
    $value = current($person);
    echo "$key: $value\n";
    next($person);
}
```

#### Using Array Iterator Objects

Iterator objects provide more sophisticated iteration capabilities:

```php
// Using ArrayIterator
$fruits = ["Apple", "Banana", "Cherry"];
$iterator = new ArrayIterator($fruits);

while ($iterator->valid()) {
    echo $iterator->current() . " ";
    $iterator->next();
}
// Output: Apple Banana Cherry

// Iterator with foreach
$iterator->rewind(); // Reset to beginning
foreach ($iterator as $key => $value) {
    echo "$key: $value\n";
}

// RecursiveArrayIterator for multidimensional arrays
$nested = [
    "fruits" => ["Apple", "Banana"],
    "vegetables" => ["Carrot", "Broccoli"]
];

$iterator = new RecursiveArrayIterator($nested);
$recursive = new RecursiveIteratorIterator($iterator);

foreach ($recursive as $key => $value) {
    echo "$key: $value\n";
}
/*
Output:
0: Apple
1: Banana
0: Carrot
1: Broccoli
*/
```

#### Using array_walk and array_map

Function-based iteration provides powerful options for applying operations:

```php
// array_walk for in-place modification
$fruits = ["apple", "banana", "cherry"];
array_walk($fruits, function(&$value, $key) {
    $value = ucfirst($value); // Capitalize first letter
});
// $fruits now contains ["Apple", "Banana", "Cherry"]

// array_walk with additional data
$prices = [10, 20, 30];
$currency = "$";
array_walk($prices, function(&$price, $key, $symbol) {
    $price = $symbol . $price;
}, $currency);
// $prices now contains ["$10", "$20", "$30"]

// array_walk_recursive for nested arrays
$data = [
    "group1" => ["item1" => 100, "item2" => 200],
    "group2" => ["item1" => 300]
];
array_walk_recursive($data, function(&$value, $key) {
    if (is_numeric($value)) {
        $value *= 2;
    }
});
/*
$data now contains:
[
    "group1" => ["item1" => 200, "item2" => 400],
    "group2" => ["item1" => 600]
]
*/

// array_map for transformations returning a new array
$numbers = [1, 2, 3, 4, 5];
$doubled = array_map(function($value) {
    return $value * 2;
}, $numbers);
// $doubled now contains [2, 4, 6, 8, 10], $numbers is unchanged

// array_map with multiple arrays
$firstNames = ["John", "Jane"];
$lastNames = ["Doe", "Smith"];
$fullNames = array_map(function($first, $last) {
    return "$first $last";
}, $firstNames, $lastNames);
// $fullNames now contains ["John Doe", "Jane Smith"]
```

### Advanced Array Techniques

#### Array Destructuring (PHP 7.1+)

```php
// Basic list() assignment
$coordinates = [10, 20, 30];
[$x, $y, $z] = $coordinates;
echo "$x, $y, $z"; // Output: 10, 20, 30

// Skip elements
$data = [1, 2, 3, 4, 5];
[$first, , $third, , $fifth] = $data;
echo "$first, $third, $fifth"; // Output: 1, 3, 5

// Nested destructuring
$matrix = [[1, 2], [3, 4]];
[[$a, $b], [$c, $d]] = $matrix;
echo "$a, $b, $c, $d"; // Output: 1, 2, 3, 4

// Associative array destructuring
$person = ["name" => "John", "age" => 30];
["name" => $name, "age" => $age] = $person;
echo "$name is $age years old"; // Output: John is 30 years old
```

#### Array Unpacking (PHP 7.4+)

```php
// Unpacking arrays
$part1 = [1, 2, 3];
$part2 = [4, 5, 6];
$combined = [...$part1, ...$part2];
// $combined now contains [1, 2, 3, 4, 5, 6]

// Unpacking with keys
$defaults = ["host" => "localhost", "port" => 3306];
$custom = ["port" => 8000, "secure" => true];
$config = [...$defaults, ...$custom];
// $config now contains ["host" => "localhost", "port" => 8000, "secure" => true]

// Unpacking in function calls
function add($a, $b, $c) {
    return $a + $b + $c;
}
$numbers = [1, 2, 3];
echo add(...$numbers); // Output: 6
```

#### Array Intersections and Differences

```php
// Array intersection (elements present in all arrays)
$array1 = [1, 2, 3, 4, 5];
$array2 = [3, 4, 5, 6, 7];
$intersection = array_intersect($array1, $array2);
// $intersection now contains [2 => 3, 3 => 4, 4 => 5] (original keys preserved)

// Array difference (elements in first array not in others)
$difference = array_diff($array1, $array2);
// $difference now contains [0 => 1, 1 => 2]

// Associative array intersection (key-value pairs)
$a1 = ["a" => 1, "b" => 2, "c" => 3];
$a2 = ["a" => 1, "b" => 3, "d" => 4];
$intersect = array_intersect_assoc($a1, $a2);
// $intersect now contains ["a" => 1]

// Associative array difference (key-value pairs)
$diff = array_diff_assoc($a1, $a2);
// $diff now contains ["b" => 2, "c" => 3]
```

**Conclusion:** Arrays are one of PHP's most powerful features, providing flexible data structures for a wide variety of programming needs. Understanding how to effectively create, manipulate, and iterate through arrays is fundamental to PHP programming. By mastering array functions and iteration techniques, you'll be able to write more efficient and elegant code for handling collections of data in your PHP applications.

---

## PHP Form Handling

### $\_GET and $\_POST Superglobals

PHP provides special arrays called superglobals that store external data from various sources, including forms. The two most commonly used for form handling are `$_GET` and `$_POST`.

**Key Points:**

- Superglobals are automatically available in all scopes
- `$_GET` retrieves data sent through URL parameters
- `$_POST` retrieves data sent through HTTP POST method
- Form data is automatically parsed into these arrays
- Values are always strings unless transformed

#### Using $_GET

The `$_GET` superglobal contains data sent through URL query parameters, typically from forms with `method="get"` or direct URL access:

```php
// URL: example.php?name=John&age=30

// Accessing $_GET data
$name = $_GET['name'] ?? ''; // Using null coalescing operator (PHP 7+)
$age = $_GET['age'] ?? '';

echo "Name: $name, Age: $age"; // Output: Name: John, Age: 30

// Checking if a parameter exists
if (isset($_GET['name'])) {
    echo "Name parameter is set";
}

// Looping through all GET parameters
foreach ($_GET as $key => $value) {
    echo "$key: $value<br>";
}
```

GET method characteristics:

- Data is visible in the URL
- Limited to approximately 2000 characters
- Can be bookmarked
- Should never be used for sensitive data
- Ideal for search queries and non-sensitive filters

#### Using $\_POST

The `$_POST` superglobal contains data sent through HTTP POST method, typically from forms with `method="post"`:

```php
// HTML form (form.html)
/*
<form action="process.php" method="post">
    <input type="text" name="username">
    <input type="password" name="password">
    <button type="submit">Submit</button>
</form>
*/

// PHP processing script (process.php)
$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

echo "Username: $username"; // Output depends on form submission

// Checking if the form was submitted
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    echo "Form was submitted using POST method";
}

// Handling form fields with array notation
/*
<form method="post">
    <input type="checkbox" name="interests[]" value="sports"> Sports
    <input type="checkbox" name="interests[]" value="music"> Music
    <input type="checkbox" name="interests[]" value="movies"> Movies
</form>
*/

// Processing checkboxes as an array
if (isset($_POST['interests'])) {
    echo "Selected interests: ";
    foreach ($_POST['interests'] as $interest) {
        echo "$interest, ";
    }
}
```

POST method characteristics:

- Data is sent in the HTTP request body (not visible in URL)
- No practical size limit (server settings dependent)
- Cannot be bookmarked
- More secure for sensitive data (though still requires HTTPS)
- Ideal for submitting data that changes server state

#### Combining $\_GET and $\_POST

Sometimes you might need to use both methods together:

```php
// URL: form_handler.php?source=homepage

// HTML form
/*
<form action="form_handler.php?source=homepage" method="post">
    <input type="text" name="username">
    <button type="submit">Submit</button>
</form>
*/

// PHP processing
$source = $_GET['source'] ?? 'unknown';
$username = $_POST['username'] ?? '';

echo "Form submitted from $source by $username";
```

#### REQUEST Superglobal

The `$_REQUEST` array contains data from `$_GET`, `$_POST`, and `$_COOKIE`:

```php
// Accessing data without knowing the submission method
$username = $_REQUEST['username'] ?? '';

// Note: Using $_REQUEST is generally discouraged as it makes it harder to 
// determine the source of data and may lead to security issues
```

### Form Validation Basics

Form validation is crucial for ensuring that the data received from forms is valid, safe, and in the expected format.

**Key Points:**

- Never trust user input
- Validate on both client-side (JavaScript) and server-side (PHP)
- Server-side validation is mandatory for security
- Use different validation techniques based on the data type
- Always sanitize data before using it

#### Basic Validation Workflow

```php
<?php
// Initialize variables to store form data and error messages
$name = $email = $website = $comment = $gender = '';
$nameErr = $emailErr = $websiteErr = $genderErr = '';

// Check if the form was submitted
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    // Validate name
    if (empty($_POST['name'])) {
        $nameErr = "Name is required";
    } else {
        $name = test_input($_POST['name']);
        // Check if name contains only letters and whitespace
        if (!preg_match("/^[a-zA-Z-' ]*$/", $name)) {
            $nameErr = "Only letters and white space allowed";
        }
    }
    
    // Validate email
    if (empty($_POST['email'])) {
        $emailErr = "Email is required";
    } else {
        $email = test_input($_POST['email']);
        // Check if email is valid
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $emailErr = "Invalid email format";
        }
    }
    
    // Validate website (optional)
    if (!empty($_POST['website'])) {
        $website = test_input($_POST['website']);
        // Check if URL syntax is valid
        if (!filter_var($website, FILTER_VALIDATE_URL)) {
            $websiteErr = "Invalid URL format";
        }
    }
    
    // Validate comment (optional)
    if (!empty($_POST['comment'])) {
        $comment = test_input($_POST['comment']);
    }
    
    // Validate gender
    if (empty($_POST['gender'])) {
        $genderErr = "Gender is required";
    } else {
        $gender = test_input($_POST['gender']);
    }
    
    // If no errors, process the form data
    if (empty($nameErr) && empty($emailErr) && empty($websiteErr) && empty($genderErr)) {
        // Process valid data (e.g., save to database, send email)
        echo "Form submitted successfully!";
    }
}

// Function to sanitize and validate input data
function test_input($data) {
    $data = trim($data);           // Remove extra spaces, tabs, newlines
    $data = stripslashes($data);   // Remove backslashes
    $data = htmlspecialchars($data); // Convert special characters to HTML entities
    return $data;
}
?>

<!-- Display the form with validation messages -->
<form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
    Name: <input type="text" name="name" value="<?php echo $name; ?>">
    <span class="error"><?php echo $nameErr; ?></span><br>
    
    Email: <input type="text" name="email" value="<?php echo $email; ?>">
    <span class="error"><?php echo $emailErr; ?></span><br>
    
    Website: <input type="text" name="website" value="<?php echo $website; ?>">
    <span class="error"><?php echo $websiteErr; ?></span><br>
    
    Comment: <textarea name="comment"><?php echo $comment; ?></textarea><br>
    
    Gender:
    <input type="radio" name="gender" value="female" <?php if ($gender == "female") echo "checked"; ?>> Female
    <input type="radio" name="gender" value="male" <?php if ($gender == "male") echo "checked"; ?>> Male
    <span class="error"><?php echo $genderErr; ?></span><br>
    
    <input type="submit" name="submit" value="Submit">
</form>
```

#### Common Validation Techniques

```php
// Validating numeric input
if (!is_numeric($_POST['age'])) {
    $ageErr = "Age must be a number";
}

// Validating integers
if (!filter_var($_POST['zip'], FILTER_VALIDATE_INT)) {
    $zipErr = "ZIP code must be an integer";
}

// Validating range
$age = (int)$_POST['age'];
if ($age < 18 || $age > 120) {
    $ageErr = "Age must be between 18 and 120";
}

// Validating with regular expressions
if (!preg_match("/^[0-9]{5}(-[0-9]{4})?$/", $_POST['zip'])) {
    $zipErr = "Invalid ZIP code format";
}

// Validating dates
$date = $_POST['birthdate'];
$d = DateTime::createFromFormat('Y-m-d', $date);
if (!$d || $d->format('Y-m-d') != $date) {
    $dateErr = "Invalid date format (YYYY-MM-DD required)";
}

// Validating password strength
$password = $_POST['password'];
if (strlen($password) < 8) {
    $pwdErr = "Password must be at least 8 characters";
} elseif (!preg_match("#[0-9]+#", $password)) {
    $pwdErr = "Password must include at least one number";
} elseif (!preg_match("#[a-zA-Z]+#", $password)) {
    $pwdErr = "Password must include at least one letter";
}

// Validating file extensions
$allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
$filename = $_FILES['image']['name'];
$fileExtension = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
if (!in_array($fileExtension, $allowedExtensions)) {
    $fileErr = "Only JPG, JPEG, PNG & GIF files are allowed";
}
```

#### Using Filter Functions

PHP provides built-in functions for validating and sanitizing data:

```php
// Validating an email address
$email = $_POST['email'];
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $emailErr = "Invalid email format";
}

// Validating an IP address
$ip = $_POST['server_ip'];
if (!filter_var($ip, FILTER_VALIDATE_IP)) {
    $ipErr = "Invalid IP address";
}

// Sanitizing a string
$name = filter_var($_POST['name'], FILTER_SANITIZE_STRING); // Note: deprecated in PHP 8.1+
// Alternative in PHP 8.1+:
$name = htmlspecialchars($_POST['name']);

// Sanitizing an email
$email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);

// Sanitizing a URL
$url = filter_var($_POST['website'], FILTER_SANITIZE_URL);

// Combining validation and sanitization
$age = filter_var($_POST['age'], FILTER_VALIDATE_INT, [
    'options' => [
        'min_range' => 1, 
        'max_range' => 120
    ]
]);
if ($age === false) {
    $ageErr = "Age must be an integer between 1 and 120";
}
```

#### CSRF Protection

Cross-Site Request Forgery (CSRF) protection prevents unauthorized commands from being submitted:

```php
// Start session at the beginning of the script
session_start();

// Create a CSRF token
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}
$csrf_token = $_SESSION['csrf_token'];

// In the form
?>
<form method="post" action="process.php">
    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
    <!-- Other form fields -->
    <button type="submit">Submit</button>
</form>
<?php

// When processing the form
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Verify CSRF token
    if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
        die("CSRF token validation failed");
    }
    
    // Process form data
}
```

### File Uploads with $\_FILES

PHP makes it easy to handle file uploads through the `$_FILES` superglobal.

**Key Points:**

- Configure PHP settings in php.ini for file uploads
- Use `enctype="multipart/form-data"` in the form tag
- The `$_FILES` array contains file information
- Always validate file type, size, and extension
- Move uploaded files from temporary directory to permanent location

#### Basic File Upload Form

```html
<form action="upload.php" method="post" enctype="multipart/form-data">
    Select file to upload:
    <input type="file" name="fileToUpload" id="fileToUpload">
    <input type="submit" value="Upload File" name="submit">
</form>
```

#### Processing File Uploads

```php
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['fileToUpload'])) {
    $targetDir = "uploads/";
    $targetFile = $targetDir . basename($_FILES["fileToUpload"]["name"]);
    $uploadOk = 1;
    $fileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));
    
    // Check if file already exists
    if (file_exists($targetFile)) {
        echo "Sorry, file already exists.";
        $uploadOk = 0;
    }
    
    // Check file size (limit to 2MB)
    if ($_FILES["fileToUpload"]["size"] > 2000000) {
        echo "Sorry, your file is too large.";
        $uploadOk = 0;
    }
    
    // Allow only certain file formats
    $allowedTypes = ["jpg", "jpeg", "png", "gif", "pdf"];
    if (!in_array($fileType, $allowedTypes)) {
        echo "Sorry, only JPG, JPEG, PNG, GIF & PDF files are allowed.";
        $uploadOk = 0;
    }
    
    // Check if $uploadOk is set to 0 by an error
    if ($uploadOk == 0) {
        echo "Sorry, your file was not uploaded.";
    } else {
        // Try to upload file
        if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $targetFile)) {
            echo "The file " . htmlspecialchars(basename($_FILES["fileToUpload"]["name"])) . " has been uploaded.";
        } else {
            echo "Sorry, there was an error uploading your file.";
        }
    }
}
?>
```

#### Understanding the $\_FILES Array

The `$_FILES` superglobal contains an array with information about uploaded files:

```php
/*
$_FILES['fileToUpload'] structure:
[
    'name'      => 'example.jpg',    // Original filename
    'type'      => 'image/jpeg',     // MIME type
    'tmp_name'  => '/tmp/php7A1.tmp', // Temporary file path
    'error'     => 0,                // Error code (0 means no error)
    'size'      => 123456            // File size in bytes
]
*/

// Accessing file information
$fileName = $_FILES['fileToUpload']['name'];
$fileType = $_FILES['fileToUpload']['type'];
$fileTmpPath = $_FILES['fileToUpload']['tmp_name'];
$fileError = $_FILES['fileToUpload']['error'];
$fileSize = $_FILES['fileToUpload']['size'];

// Check for upload errors
if ($fileError !== UPLOAD_ERR_OK) {
    switch ($fileError) {
        case UPLOAD_ERR_INI_SIZE:
            echo "The uploaded file exceeds the upload_max_filesize directive in php.ini";
            break;
        case UPLOAD_ERR_FORM_SIZE:
            echo "The uploaded file exceeds the MAX_FILE_SIZE directive in the HTML form";
            break;
        case UPLOAD_ERR_PARTIAL:
            echo "The uploaded file was only partially uploaded";
            break;
        case UPLOAD_ERR_NO_FILE:
            echo "No file was uploaded";
            break;
        case UPLOAD_ERR_NO_TMP_DIR:
            echo "Missing a temporary folder";
            break;
        case UPLOAD_ERR_CANT_WRITE:
            echo "Failed to write file to disk";
            break;
        case UPLOAD_ERR_EXTENSION:
            echo "A PHP extension stopped the file upload";
            break;
        default:
            echo "Unknown upload error";
            break;
    }
    exit;
}
```

#### Handling Multiple File Uploads

```html
<form action="multiple_upload.php" method="post" enctype="multipart/form-data">
    Select files to upload:
    <input type="file" name="files[]" multiple>
    <input type="submit" value="Upload Files" name="submit">
</form>
```

```php
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['files'])) {
    $targetDir = "uploads/";
    $allowedTypes = ["jpg", "jpeg", "png", "gif"];
    $maxFileSize = 2000000; // 2MB
    $uploadedFiles = 0;
    $errors = [];
    
    // Count total files
    $totalFiles = count($_FILES['files']['name']);
    
    // Loop through each file
    for ($i = 0; $i < $totalFiles; $i++) {
        // Skip if there's an error or no file
        if ($_FILES['files']['error'][$i] !== UPLOAD_ERR_OK || $_FILES['files']['size'][$i] === 0) {
            $errors[] = "Error with file " . ($_FILES['files']['name'][$i] ?? "unknown");
            continue;
        }
        
        // Get file information
        $fileName = basename($_FILES['files']['name'][$i]);
        $targetFile = $targetDir . $fileName;
        $fileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));
        $fileSize = $_FILES['files']['size'][$i];
        
        // Validate file
        if (!in_array($fileType, $allowedTypes)) {
            $errors[] = "File type not allowed for $fileName";
            continue;
        }
        
        if ($fileSize > $maxFileSize) {
            $errors[] = "File size too large for $fileName";
            continue;
        }
        
        // Try to upload file
        if (move_uploaded_file($_FILES['files']['tmp_name'][$i], $targetFile)) {
            $uploadedFiles++;
        } else {
            $errors[] = "Failed to upload $fileName";
        }
    }
    
    echo "Successfully uploaded $uploadedFiles files.";
    
    if (!empty($errors)) {
        echo "<br>Errors:<br>";
        foreach ($errors as $error) {
            echo "- $error<br>";
        }
    }
}
?>
```

#### Secure File Upload Best Practices

```php
// Generate a unique filename to prevent overwriting
$newFileName = uniqid() . '.' . $fileType;
$targetFile = $targetDir . $newFileName;

// Store the original filename in the database
$originalFileName = $_FILES['fileToUpload']['name'];

// Check MIME type with finfo (more secure than relying on $_FILES['type'])
$finfo = new finfo(FILEINFO_MIME_TYPE);
$fileContents = file_get_contents($_FILES['fileToUpload']['tmp_name']);
$mimeType = $finfo->buffer($fileContents);

// List of allowed MIME types
$allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'application/pdf'
];

if (!in_array($mimeType, $allowedMimeTypes)) {
    echo "File type not allowed based on content analysis.";
    exit;
}

// Store uploaded files outside the web root
$targetDir = dirname(__DIR__) . '/secure_uploads/';

// Set proper permissions on uploaded files
if (move_uploaded_file($_FILES['fileToUpload']['tmp_name'], $targetFile)) {
    chmod($targetFile, 0644); // Set read-only for user and group
    echo "File uploaded successfully.";
} else {
    echo "Upload failed.";
}
```

#### Image Processing After Upload

You can use the GD or Imagick libraries to process images after upload:

```php
// Using GD to create a thumbnail
if ($fileType == "jpg" || $fileType == "jpeg") {
    // Create image from uploaded file
    $source = imagecreatefromjpeg($targetFile);
    
    // Get original image dimensions
    list($width, $height) = getimagesize($targetFile);
    
    // Set thumbnail dimensions
    $thumbWidth = 200;
    $thumbHeight = ($height / $width) * $thumbWidth;
    
    // Create thumbnail image
    $thumb = imagecreatetruecolor($thumbWidth, $thumbHeight);
    
    // Resize
    imagecopyresampled($thumb, $source, 0, 0, 0, 0, $thumbWidth, $thumbHeight, $width, $height);
    
    // Save thumbnail
    $thumbFile = $targetDir . "thumb_" . basename($targetFile);
    imagejpeg($thumb, $thumbFile, 80);
    
    // Free memory
    imagedestroy($source);
    imagedestroy($thumb);
    
    echo "Thumbnail created successfully.";
}
```

**Conclusion:** Proper form handling is essential for creating interactive and secure PHP applications. Understanding how to work with `$_GET` and `$_POST` superglobals allows you to capture user input, while validation ensures data integrity and security. File uploads add a powerful dimension to your applications but require careful handling to prevent security vulnerabilities. By following best practices for form processing, validation, and file handling, you can create robust PHP applications that safely and effectively handle user input.

Important subtopics related to PHP form handling include:

- AJAX form submissions
- Form handling with PHP frameworks
- Creating reusable form validation classes
- Server-side form generation
- Security considerations like XSS prevention

---

# Working with Data

## String Manipulation in PHP

### Introduction to String Manipulation

String manipulation is a fundamental aspect of PHP programming, allowing developers to process, modify, and extract information from text data. PHP offers a rich set of built-in functions for string operations, making it one of the most versatile languages for text processing.

**Key Points:**

- PHP strings are sequences of characters that can be manipulated using various functions
- String operations are essential for form validation, data cleaning, and content management
- PHP provides both procedural string functions and regular expression capabilities
- String functions in PHP are generally straightforward and efficient

### Basic String Functions

### String Length and Counting

The `strlen()` function returns the number of bytes in a string, making it essential for character counting and validation:

```php
$text = "Hello, World!";
echo strlen($text); // Outputs: 13
```

For Unicode strings, `mb_strlen()` from the Multibyte String extension provides accurate character counting:

```php
$unicode_text = "こんにちは"; // Japanese "Hello"
echo mb_strlen($unicode_text); // Outputs: 5 (not the byte count)
```

### Finding Substrings

PHP offers several functions to locate substrings within a larger string:

#### strpos() and stripos()

The `strpos()` function finds the position of the first occurrence of a substring:

```php
$haystack = "The quick brown fox jumps over the lazy dog";
$needle = "fox";
$position = strpos($haystack, $needle);
echo $position; // Outputs: 16
```

For case-insensitive searches, use `stripos()`:

```php
$haystack = "The quick brown FOX jumps over the lazy dog";
$needle = "fox";
$position = stripos($haystack, $needle);
echo $position; // Outputs: 16 (finds "FOX")
```

#### strrpos() and strripos()

These functions find the last occurrence of a substring:

```php
$text = "The quick brown fox jumps over the lazy fox";
echo strrpos($text, "fox"); // Outputs: 40
```

### Substring Extraction

#### substr()

The `substr()` function extracts a part of a string:

```php
$text = "Hello, World!";
echo substr($text, 0, 5); // Outputs: Hello
echo substr($text, 7); // Outputs: World!
echo substr($text, -6); // Outputs: World!
```

#### explode() and implode()

Split strings into arrays with `explode()`:

```php
$csv = "apple,banana,orange,grape";
$fruits = explode(",", $csv);
print_r($fruits);
// Outputs: Array ( [0] => apple [1] => banana [2] => orange [3] => grape )
```

Join array elements with `implode()`:

```php
$fruits = ["apple", "banana", "orange", "grape"];
$csv = implode(",", $fruits);
echo $csv; // Outputs: apple,banana,orange,grape
```

### String Replacement Functions

#### str_replace() and str_ireplace()

Replace all occurrences of a search string with a replacement:

```php
$text = "The quick brown fox jumps over the lazy dog";
$replaced = str_replace("fox", "cat", $text);
echo $replaced; // Outputs: The quick brown cat jumps over the lazy dog
```

For case-insensitive replacement:

```php
$text = "The quick brown FOX jumps over the lazy dog";
$replaced = str_ireplace("fox", "cat", $text);
echo $replaced; // Outputs: The quick brown cat jumps over the lazy dog
```

Multiple replacements in one call:

```php
$text = "The quick brown fox jumps over the lazy dog";
$search = ["quick", "brown", "fox", "lazy"];
$replace = ["slow", "black", "wolf", "energetic"];
$result = str_replace($search, $replace, $text);
echo $result; // Outputs: The slow black wolf jumps over the energetic dog
```

#### substr_replace()

Replace a portion of a string with another string:

```php
$text = "Hello, World!";
echo substr_replace($text, "PHP", 7, 5); // Outputs: Hello, PHP!
```

### Case Manipulation

PHP provides several functions to change the case of strings:

```php
$text = "Hello, World!";
echo strtoupper($text); // Outputs: HELLO, WORLD!
echo strtolower($text); // Outputs: hello, world!
echo ucfirst($text); // Outputs: Hello, world!
echo lcfirst($text); // Outputs: hello, World!
echo ucwords($text); // Outputs: Hello, World!
```

### String Trimming

Remove whitespace or specific characters from strings:

```php
$text = "  Hello, World!  ";
echo trim($text); // Outputs: "Hello, World!"
echo ltrim($text); // Outputs: "Hello, World!  "
echo rtrim($text); // Outputs: "  Hello, World!"

// Trim specific characters
$text = "###Hello, World!###";
echo trim($text, "#"); // Outputs: "Hello, World!"
```

### String Comparison

Compare strings with `strcmp()` and related functions:

```php
$str1 = "apple";
$str2 = "banana";
echo strcmp($str1, $str2); // Outputs: -1 (str1 is less than str2)

$str3 = "Apple";
echo strcasecmp($str1, $str3); // Outputs: 0 (equal when ignoring case)
```

### Regular Expressions in PHP

Regular expressions provide powerful pattern matching and manipulation capabilities:

### Pattern Matching with preg_match()

The `preg_match()` function searches a string for a pattern and returns whether a match was found:

```php
$text = "Contact us at info@example.com";
$pattern = '/[\w.]+@[\w.]+\.\w+/';
$hasEmail = preg_match($pattern, $text, $matches);

if ($hasEmail) {
    echo "Email found: " . $matches[0]; // Outputs: Email found: info@example.com
}
```

Multiple matches with `preg_match_all()`:

```php
$text = "Contact us at info@example.com or support@example.org";
$pattern = '/[\w.]+@[\w.]+\.\w+/';
$count = preg_match_all($pattern, $text, $matches);

echo "Found $count emails: " . implode(", ", $matches[0]);
// Outputs: Found 2 emails: info@example.com, support@example.org
```

### String Replacement with preg_replace()

Replace text using regular expression patterns:

```php
$text = "The date is 2023-05-15 and the time is 14:30:25";
$pattern = '/(\d{4})-(\d{2})-(\d{2})/';
$replacement = '$3/$2/$1'; // Day/Month/Year
$result = preg_replace($pattern, $replacement, $text);
echo $result; // Outputs: The date is 15/05/2023 and the time is 14:30:25
```

Complex replacements with callback functions:

```php
$text = "The price is $10.99";
$pattern = '/\$(\d+\.\d+)/';
$result = preg_replace_callback($pattern, function($matches) {
    // Convert USD to EUR (example conversion rate)
    $usd = floatval($matches[1]);
    $eur = $usd * 0.85;
    return '€' . number_format($eur, 2);
}, $text);
echo $result; // Outputs: The price is €9.34
```

### Splitting Strings with preg_split()

Split a string by a pattern:

```php
$text = "Hello,World;PHP|Programming";
$pattern = '/[,;|]/';
$parts = preg_split($pattern, $text);
print_r($parts);
// Outputs: Array ( [0] => Hello [1] => World [2] => PHP [3] => Programming )
```

### Advanced Regular Expression Features

#### Named Capture Groups

```php
$text = "John Smith <john.smith@example.com>";
$pattern = '/(?<name>[\w\s]+)\s*<(?<email>[\w.]+@[\w.]+\.\w+)>/';
preg_match($pattern, $text, $matches);

echo "Name: " . $matches['name'] . "\n";
echo "Email: " . $matches['email'];
// Outputs:
// Name: John Smith
// Email: john.smith@example.com
```

#### Modifiers

Regular expression modifiers alter pattern behavior:

```php
// Case-insensitive matching with 'i' modifier
$text = "Hello WORLD";
$pattern = '/hello/i';
preg_match($pattern, $text, $matches);
echo $matches[0]; // Outputs: Hello

// Multi-line matching with 'm' modifier
$text = "Line 1\nLine 2\nLine 3";
$pattern = '/^Line/m';
preg_match_all($pattern, $text, $matches);
print_r($matches[0]);
// Outputs: Array ( [0] => Line [1] => Line [2] => Line )

// PCRE_DOTALL with 's' modifier makes dot match newlines
$text = "Line 1\nLine 2";
$pattern = '/Line 1.*Line 2/s';
preg_match($pattern, $text, $matches);
echo $matches[0]; // Outputs: Line 1\nLine 2
```

### Practical Examples

#### Form Input Validation

```php
function validateEmail($email) {
    return preg_match('/^[\w.]+@[\w.]+\.\w{2,}$/', $email);
}

function validatePhone($phone) {
    // Accept formats like (123) 456-7890 or 123-456-7890
    return preg_match('/^\(?(\d{3})\)?[- ]?(\d{3})[- ]?(\d{4})$/', $phone);
}

// Usage
$email = "user@example.com";
$phone = "(123) 456-7890";

echo validateEmail($email) ? "Valid email" : "Invalid email";
echo validatePhone($phone) ? "Valid phone" : "Invalid phone";
```

#### URL Parsing

```php
$url = "https://www.example.com/products?id=123&category=electronics";
$pattern = '/^(https?):\/\/([^\/]+)(\/[^?]*)?\??(.*)$/';

preg_match($pattern, $url, $matches);
$protocol = $matches[1];
$domain = $matches[2];
$path = isset($matches[3]) ? $matches[3] : '';
$query = isset($matches[4]) ? $matches[4] : '';

echo "Protocol: $protocol\n";
echo "Domain: $domain\n";
echo "Path: $path\n";
echo "Query: $query\n";
```

#### HTML Tag Stripping

```php
$html = "<p>This is <strong>important</strong> text with a <a href='#'>link</a>.</p>";
$text = preg_replace('/<[^>]+>/', '', $html);
echo $text; // Outputs: This is important text with a link.
```

### Performance Considerations

#### Efficiency Tips

1. Use string functions when possible instead of regular expressions for simple operations
2. Cache compiled regular expressions with the `/e` modifier for repeated use
3. Be specific with patterns to avoid backtracking
4. Use atomic grouping `(?>...)` for complex patterns
5. Consider using `strtr()` for multiple simple replacements instead of multiple `str_replace()` calls

**Example of strtr() efficiency:**

```php
$replacements = [
    "apple" => "orange",
    "dog" => "cat",
    "red" => "blue"
];

$text = "The red apple is for the dog.";
echo strtr($text, $replacements);
// Outputs: The blue orange is for the cat.
```

### String Encoding and Multibyte Strings

#### mb_string Functions

When working with non-ASCII characters, use the multibyte string functions:

```php
$text = "こんにちは世界"; // Hello world in Japanese
echo mb_strlen($text); // Character count: 7

// Substring operations
echo mb_substr($text, 0, 5); // こんにちは

// Case conversion
$mixed = "HéLLö WöRLD";
echo mb_strtolower($mixed); // héllö wörld
```

#### Character Encoding Conversion

```php
$text = "こんにちは";
$utf8 = mb_convert_encoding($text, "UTF-8", "auto");
$iso = mb_convert_encoding($text, "ISO-8859-1", "UTF-8");
```

### Security Considerations

#### Escaping Output

Always escape strings before outputting to prevent XSS attacks:

```php
$userInput = "<script>alert('XSS');</script>";
echo htmlspecialchars($userInput);
// Outputs: &lt;script&gt;alert('XSS');&lt;/script&gt;
```

#### SQL Injection Prevention

Use prepared statements or properly escape strings for database queries:

```php
// Bad practice (vulnerable to SQL injection)
$username = "user' OR 1=1 --";
$query = "SELECT * FROM users WHERE username = '$username'";

// Good practice
$username = "user' OR 1=1 --";
$safeUsername = mysqli_real_escape_string($connection, $username);
$query = "SELECT * FROM users WHERE username = '$safeUsername'";

// Better practice: Use prepared statements
$stmt = $connection->prepare("SELECT * FROM users WHERE username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
```

### Common String Processing Tasks

#### CSV Parsing

```php
function parseCSV($csv) {
    $lines = explode("\n", trim($csv));
    $data = [];
    
    foreach ($lines as $line) {
        // Handle quoted values with commas inside
        $pattern = '/,(?=(?:[^"]*"[^"]*")*[^"]*$)/';
        $values = preg_split($pattern, $line);
        
        // Remove quotes from values
        $values = array_map(function($value) {
            return trim(str_replace('"', '', $value));
        }, $values);
        
        $data[] = $values;
    }
    
    return $data;
}

$csv = '"Name","Age","City"
"John Smith","25","New York"
"Jane Doe","30","Los Angeles"';

$parsed = parseCSV($csv);
print_r($parsed);
```

#### Word Counter

```php
function countWords($text) {
    // Remove punctuation and normalize whitespace
    $text = preg_replace('/[^\w\s]/', ' ', $text);
    $text = preg_replace('/\s+/', ' ', $text);
    $text = trim($text);
    
    // Split into words and count
    $words = explode(' ', $text);
    $wordCount = count($words);
    
    // Count frequency of each word
    $frequency = array_count_values(array_map('strtolower', $words));
    arsort($frequency);
    
    return [
        'total' => $wordCount,
        'frequency' => $frequency
    ];
}

$text = "The quick brown fox jumps over the lazy dog. The dog was not very lazy after all.";
$result = countWords($text);
echo "Total words: " . $result['total'] . "\n";
echo "Most frequent words: \n";
print_r(array_slice($result['frequency'], 0, 3));
```

### Conclusion

PHP offers an extensive collection of string manipulation functions and powerful regular expression capabilities. Mastering these tools enables developers to process text data efficiently, validate user input, and implement complex string transformations. Understanding when to use basic string functions versus regular expressions can significantly impact application performance and maintainability.

### Related Topics

- PHP Array Functions for data processing
- JSON and XML handling in PHP
- Character encoding and internationalization
- PHP's Filter extension for input validation
- PHP Template Engines like Twig and Smarty

---

## Date and Time Handling in PHP

### Introduction to PHP DateTime

PHP offers robust date and time manipulation capabilities through its DateTime extension. This object-oriented approach provides more flexibility and reliability than older procedural date/time functions like `date()` and `strtotime()`, though those still have their uses in simpler scenarios.

### Working with DateTime Objects

#### Creating DateTime Objects

There are several ways to instantiate DateTime objects in PHP:

```php
// Current date and time
$now = new DateTime();

// Specific date and time
$date = new DateTime('2025-05-05 14:30:00');

// From format
$date = DateTime::createFromFormat('Y-m-d H:i:s', '2025-05-05 14:30:00');

// From Unix timestamp
$date = new DateTime();
$date->setTimestamp(1714924200);
```

#### DateTime Modification

DateTime objects can be easily modified using various methods:

```php
$date = new DateTime('2025-05-05 14:30:00');

// Add interval
$date->add(new DateInterval('P1D')); // Add 1 day
$date->add(new DateInterval('PT2H')); // Add 2 hours

// Subtract interval
$date->sub(new DateInterval('P5D')); // Subtract 5 days

// Modify using relative strings
$date->modify('+1 month');
$date->modify('next Monday');
$date->modify('last day of this month');

// Set specific components
$date->setDate(2025, 12, 31); // Year, month, day
$date->setTime(23, 59, 59); // Hour, minute, second
```

#### Date Comparison

DateTime objects support direct comparison:

```php
$date1 = new DateTime('2025-01-01');
$date2 = new DateTime('2025-12-31');

if ($date1 < $date2) {
    echo 'Date1 is earlier than Date2';
}

// Calculate difference between dates
$interval = $date1->diff($date2);
echo $interval->format('%R%a days'); // +364 days
```

**Key Points**:

- Always use proper error handling with DateTime objects
- Chain methods for cleaner code (`$date->setDate()->setTime()`)
- Use DateTimeImmutable when you need to preserve original values
- DateTime objects are mutable by default; operations modify the original object

### Formatting Dates

#### Basic Formatting with format()

The `format()` method uses format characters to display date components:

```php
$date = new DateTime('2025-05-05 14:30:00');

// Common formats
echo $date->format('Y-m-d'); // 2025-05-05
echo $date->format('d/m/Y'); // 05/05/2025
echo $date->format('M j, Y'); // May 5, 2025
echo $date->format('l, F j, Y'); // Monday, May 5, 2025
echo $date->format('Y-m-d H:i:s'); // 2025-05-05 14:30:00
echo $date->format('h:i A'); // 02:30 PM
```

#### Common Format Characters

|Character|Description|Example|
|---|---|---|
|d|Day of month (01-31)|05|
|j|Day of month without leading zeros|5|
|m|Month number (01-12)|05|
|n|Month number without leading zeros|5|
|M|Short month name|May|
|F|Full month name|May|
|Y|Four-digit year|2025|
|y|Two-digit year|25|
|l|Full day of week|Monday|
|D|Short day of week|Mon|
|H|24-hour format (00-23)|14|
|h|12-hour format (01-12)|02|
|i|Minutes (00-59)|30|
|s|Seconds (00-59)|00|
|A|AM/PM|PM|

#### IntlDateFormatter (Internationalization)

For localized date formatting, use the IntlDateFormatter class:

```php
// Requires ext-intl
$formatter = new IntlDateFormatter(
    'fr_FR',
    IntlDateFormatter::LONG,
    IntlDateFormatter::SHORT
);

$date = new DateTime('2025-05-05 14:30:00');
echo $formatter->format($date); // 5 mai 2025 14:30
```

### Time Zone Handling

#### Setting Time Zones

PHP DateTime objects can work with different time zones:

```php
// Set time zone when creating
$date = new DateTime('2025-05-05 14:30:00', new DateTimeZone('Europe/Paris'));

// Change time zone after creation
$date = new DateTime('2025-05-05 14:30:00');
$date->setTimezone(new DateTimeZone('America/New_York'));

// Get current time zone
$timezone = $date->getTimezone();
echo $timezone->getName(); // America/New_York
```

#### Listing Available Time Zones

```php
$timezones = DateTimeZone::listIdentifiers();
// Or by region
$euTimezones = DateTimeZone::listIdentifiers(DateTimeZone::EUROPE);
```

#### Working with Different Time Zones

```php
// Convert time between zones
$paris = new DateTime('2025-05-05 14:30:00', new DateTimeZone('Europe/Paris'));
echo $paris->format('Y-m-d H:i:s'); // 2025-05-05 14:30:00

$paris->setTimezone(new DateTimeZone('America/New_York'));
echo $paris->format('Y-m-d H:i:s'); // 2025-05-05 08:30:00

// Time zone information
$tz = new DateTimeZone('Europe/Paris');
$info = $tz->getLocation();
echo "Latitude: {$info['latitude']}, Longitude: {$info['longitude']}";
```

#### Handling Daylight Saving Time

DateTime automatically handles daylight saving time transitions:

```php
$date = new DateTime('2025-03-30 01:30:00', new DateTimeZone('Europe/Paris'));
echo $date->format('Y-m-d H:i:s'); // 2025-03-30 01:30:00

// Add 1 hour (crosses DST boundary)
$date->add(new DateInterval('PT1H'));
echo $date->format('Y-m-d H:i:s'); // 2025-03-30 03:30:00 (skips 2:30)
```

**Key Points**:

- Always specify time zones explicitly in applications that work across regions
- Use standardized IANA time zone identifiers (e.g., 'Europe/Paris')
- Be careful around DST transitions to avoid logic errors

### Best Practices

#### Use DateTimeImmutable for Safer Operations

DateTimeImmutable works like DateTime but returns new objects instead of modifying the original:

```php
$date = new DateTimeImmutable('2025-05-05');
$tomorrow = $date->modify('+1 day');

echo $date->format('Y-m-d'); // Still 2025-05-05
echo $tomorrow->format('Y-m-d'); // 2025-05-06
```

#### DateTimeInterface for Type Hinting

For flexible function parameters that accept either DateTime or DateTimeImmutable:

```php
function formatDate(DateTimeInterface $date, string $format = 'Y-m-d'): string {
    return $date->format($format);
}
```

#### DatePeriod for Date Ranges

Generate sequences of dates:

```php
$start = new DateTime('2025-01-01');
$interval = new DateInterval('P1M'); // 1 month interval
$end = new DateTime('2026-01-01');

$period = new DatePeriod($start, $interval, $end);
foreach ($period as $date) {
    echo $date->format('Y-m-d') . PHP_EOL;
}
```

### Error Handling

Always use exception handling with DateTime operations:

```php
try {
    $date = new DateTime('invalid date format');
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
```

### Performance Considerations

For high-performance applications:

- Cache DateTime objects when possible
- Use DateTimeImmutable for thread safety
- For simple formatting of the current time, procedural functions like `date()` may be faster
- Consider using timestamps directly for simple calculations

**Conclusion**: PHP's DateTime classes provide powerful tools for handling dates and times. By using these object-oriented approaches, you can create more maintainable and reliable code compared to the older procedural date functions. Always remember to explicitly set time zones and handle DST transitions with care for applications that work across different regions.

---

## File System Operations in PHP

### Introduction to PHP File System Operations

PHP offers comprehensive capabilities for interacting with the file system, providing functions for file manipulation, directory management, and security control. These operations are essential for tasks such as configuration management, data storage, log handling, and content management systems.

### Reading and Writing Files

#### File Reading Functions

PHP provides several methods to read file content:

```php
// Read entire file into a string
$content = file_get_contents('example.txt');

// Read file line by line into an array
$lines = file('example.txt', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

// Read file using file handles
$handle = fopen('example.txt', 'r');
if ($handle) {
    while (($line = fgets($handle)) !== false) {
        echo $line;
    }
    fclose($handle);
}
```

#### Writing to Files

Similarly, PHP offers multiple approaches for writing to files:

```php
// Write string to file (overwrites existing content)
file_put_contents('output.txt', 'Hello, world!');

// Append content to existing file
file_put_contents('log.txt', "New log entry: " . date('Y-m-d H:i:s') . "\n", FILE_APPEND);

// Write using file handles
$handle = fopen('data.txt', 'w');
if ($handle) {
    fwrite($handle, "Line 1\n");
    fwrite($handle, "Line 2\n");
    fclose($handle);
}
```

#### File Reading/Writing Modes

When using `fopen()`, various modes control file access:

|Mode|Description|
|---|---|
|'r'|Read-only, starts at beginning|
|'r+'|Read/write, starts at beginning|
|'w'|Write-only, truncates file to zero length or creates new file|
|'w+'|Read/write, truncates file to zero length or creates new file|
|'a'|Write-only, append to end of file or creates new file|
|'a+'|Read/write, append to end of file or creates new file|
|'x'|Write-only, creates new file, fails if file exists|
|'x+'|Read/write, creates new file, fails if file exists|
|'c'|Write-only, creates new file or opens without truncation|
|'c+'|Read/write, creates new file or opens without truncation|

#### File Pointer Operations

Control the internal file pointer:

```php
$handle = fopen('example.txt', 'r+');

// Move pointer to specific position
fseek($handle, 10); // Move to 10th byte

// Get current position
$position = ftell($handle);

// Read specific number of bytes
$data = fread($handle, 50); // Read 50 bytes

// Rewind to beginning
rewind($handle);

fclose($handle);
```

#### Binary File Operations

PHP can also handle binary files:

```php
$handle = fopen('image.jpg', 'rb'); // 'b' for binary mode
$imageData = fread($handle, filesize('image.jpg'));
fclose($handle);

// Write binary data
$handle = fopen('output.jpg', 'wb');
fwrite($handle, $imageData);
fclose($handle);
```

#### CSV File Operations

PHP has special functions for CSV files:

```php
// Reading CSV
$handle = fopen('data.csv', 'r');
while (($data = fgetcsv($handle)) !== false) {
    // $data is an array with values from one row
    print_r($data);
}
fclose($handle);

// Writing CSV
$handle = fopen('output.csv', 'w');
$data = [
    ['Name', 'Email', 'Phone'],
    ['John Doe', 'john@example.com', '555-1234'],
    ['Jane Smith', 'jane@example.com', '555-5678']
];
foreach ($data as $row) {
    fputcsv($handle, $row);
}
fclose($handle);
```

**Key Points**:

- Use `file_get_contents()` and `file_put_contents()` for simple operations
- For more complex operations (line-by-line, chunked reading, etc.), use file handles
- Always close file handles with `fclose()` to free system resources
- Use binary modes ('b' suffix) when dealing with non-text files

### Directory Operations

#### Creating and Removing Directories

```php
// Create directory
if (!is_dir('uploads')) {
    mkdir('uploads', 0755);
}

// Create nested directories
mkdir('path/to/nested/directory', 0755, true);

// Remove directory (must be empty)
rmdir('old_directory');
```

#### Reading Directory Contents

```php
// List all files in directory
$files = scandir('documents');
print_r($files);

// Using directory handle
$dir = opendir('documents');
while (($file = readdir($dir)) !== false) {
    echo $file . "\n";
}
closedir($dir);

// Using DirectoryIterator (OOP approach)
$iterator = new DirectoryIterator('documents');
foreach ($iterator as $fileinfo) {
    if (!$fileinfo->isDot()) {
        echo $fileinfo->getFilename() . "\n";
    }
}
```

#### Recursive Directory Operations

For working with directory trees:

```php
// RecursiveDirectoryIterator example
$directory = new RecursiveDirectoryIterator('project');
$iterator = new RecursiveIteratorIterator($directory);

foreach ($iterator as $info) {
    if ($info->isFile()) {
        echo $info->getPathname() . "\n";
    }
}

// Find specific files recursively
$directory = new RecursiveDirectoryIterator('project');
$iterator = new RecursiveIteratorIterator($directory);
$phpFiles = new RegexIterator($iterator, '/\.php$/i');

foreach ($phpFiles as $phpFile) {
    echo $phpFile->getPathname() . "\n";
}
```

#### Copying and Moving Files/Directories

```php
// Copy file
copy('source.txt', 'destination.txt');

// Move/rename file
rename('oldname.txt', 'newname.txt');

// Move file to another directory
rename('file.txt', 'newdirectory/file.txt');
```

#### Getting File Information

```php
// Check if file/directory exists
if (file_exists('config.php')) {
    // File operations
}

// Check file type
if (is_file('document.txt')) {
    echo "Regular file";
} elseif (is_dir('documents')) {
    echo "Directory";
} elseif (is_link('shortcut')) {
    echo "Symbolic link";
}

// Get file size
$size = filesize('large_file.zip');
echo "Size: " . number_format($size / 1024, 2) . " KB";

// Get file modification time
$mtime = filemtime('document.txt');
echo "Last modified: " . date('Y-m-d H:i:s', $mtime);

// Get file owner and group
$owner = fileowner('document.txt');
$group = filegroup('document.txt');
echo "Owner ID: $owner, Group ID: $group";

// Get file information in one call
$info = stat('document.txt');
print_r($info);
```

**Key Points**:

- Always check return values of directory functions for error handling
- Use iterators for better memory usage with large directories
- Consider using SPL iterators for complex directory operations

### File Permissions and Security Considerations

#### Understanding File Permissions

PHP uses Unix-style permission system, even on Windows servers:

```php
// Change file permissions
chmod('script.php', 0755); // rwxr-xr-x
chmod('private.key', 0600); // rw-------

// Get current permissions
$perms = fileperms('script.php');
$perms_octal = substr(sprintf('%o', $perms), -4);
echo "Permissions: $perms_octal";

// Change file owner/group (requires appropriate system privileges)
chown('file.txt', 'www-data');
chgrp('file.txt', 'www-data');
```

#### Common Permission Values

|Octal|Permission|Meaning|
|---|---|---|
|0644|rw-r--r--|Owner can read/write, others can read|
|0755|rwxr-xr-x|Owner can read/write/execute, others can read/execute|
|0600|rw-------|Owner can read/write, no access for others|
|0777|rwxrwxrwx|Everyone can read/write/execute (avoid using)|

#### Security Best Practices

##### File Path Validation

Always validate and sanitize file paths:

```php
// Prevent directory traversal attacks
$filename = basename($_GET['file']); // Strip directory components
$safePath = '/var/www/uploads/' . $filename;

// Validate file is in allowed directory
$realPath = realpath($safePath);
$uploadsDir = realpath('/var/www/uploads');
if ($realPath === false || strpos($realPath, $uploadsDir) !== 0) {
    die('Invalid file access attempted');
}
```

##### File Upload Security

When handling file uploads:

```php
// Basic upload handling with validation
if ($_FILES['userfile']['error'] === UPLOAD_ERR_OK) {
    // Validate file type
    $finfo = new finfo(FILEINFO_MIME_TYPE);
    $type = $finfo->file($_FILES['userfile']['tmp_name']);
    
    $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    if (!in_array($type, $allowedTypes)) {
        die('Invalid file type');
    }
    
    // Use a safe filename
    $filename = bin2hex(random_bytes(16)) . '.jpg';
    $destination = '/var/www/uploads/' . $filename;
    
    // Move uploaded file to destination
    if (!move_uploaded_file($_FILES['userfile']['tmp_name'], $destination)) {
        die('Failed to move uploaded file');
    }
}
```

##### Configuration File Security

```php
// Store config files outside web root
// /var/www/config/database.php instead of /var/www/html/config/database.php

// Use restrictive permissions
chmod('/var/www/config/database.php', 0600);

// Prevent direct access with .htaccess (Apache)
// Place in config directory:
// <Files *>
//   Order deny,allow
//   Deny from all
// </Files>
```

##### Temporary Files

```php
// Create secure temporary file
$tempFile = tempnam(sys_get_temp_dir(), 'prefix_');
file_put_contents($tempFile, 'Sensitive data');

// Process data...

// Clean up
unlink($tempFile);
```

##### Open_basedir Restriction

In php.ini or virtual host configuration:

```
open_basedir = /var/www/:/tmp/
```

This restricts PHP file operations to specified directories.

#### Advanced File Operations

##### File Locking

Prevent race conditions with file locks:

```php
$handle = fopen('counter.txt', 'r+');
if (flock($handle, LOCK_EX)) { // Exclusive lock
    // Read current value
    $count = (int) fread($handle, 10);
    $count++;
    
    // Move back to start of file and write new value
    rewind($handle);
    fwrite($handle, $count);
    
    // Release lock
    flock($handle, LOCK_UN);
} else {
    echo "Couldn't lock the file!";
}
fclose($handle);
```

##### Stream Wrappers

PHP supports various stream wrappers:

```php
// HTTP stream
$content = file_get_contents('https://example.com/data.json');

// FTP operations
$handle = fopen('ftp://user:pass@ftp.example.com/file.txt', 'r');

// ZIP archives
$zip = new ZipArchive();
if ($zip->open('archive.zip') === true) {
    $content = $zip->getFromName('file.txt');
    $zip->close();
}

// Custom stream wrapper
stream_wrapper_register('custom', 'MyStreamWrapper');
file_put_contents('custom://identifier', 'data');
```

**Key Points**:

- Never trust user input for file operations
- Keep sensitive files outside web root
- Use minimal necessary permissions
- Implement proper error handling for all file operations
- Consider using dedicated libraries for complex file operations

### Error Handling for File Operations

```php
// Using exceptions for file operations (PHP 7+)
try {
    $content = @file_get_contents('missing.txt');
    if ($content === false) {
        throw new Exception('Failed to read file: ' . error_get_last()['message']);
    }
} catch (Exception $e) {
    error_log($e->getMessage());
    echo "An error occurred while reading the file.";
}

// Check for specific error conditions
if (!is_readable('config.php')) {
    die('Configuration file is not readable');
}

if (!is_writable('logs/app.log')) {
    error_log('Log directory is not writable');
    // Fallback behavior
}
```

**Conclusion**: PHP's file system functions provide powerful capabilities for handling files and directories in web applications. However, these operations also introduce security risks that must be carefully managed. Always validate user input, use proper permission settings, and follow security best practices to build robust and secure file handling routines. Remember that file operations can fail for various reasons (permissions, disk space, locks), so proper error handling is essential for production applications.


---
# State Management and Cookies

## Sessions in PHP

### Introduction to PHP Sessions

Sessions are a mechanism in PHP that allows data persistence across multiple page requests from the same visitor. Unlike cookies, which store data on the client side, session data is stored on the server, with only a session identifier stored in a cookie or URL. This makes sessions essential for maintaining state in web applications, storing user preferences, implementing authentication systems, and managing shopping carts.

### Starting and Configuring Sessions

#### Basic Session Initialization

Starting a session in PHP is straightforward:

```php
// Start a new session or resume an existing one
session_start();

// Now session variables can be accessed and modified
```

The `session_start()` function must be called before any output is sent to the browser (before any HTML, whitespace, or PHP output), or you'll encounter the "headers already sent" error.

#### Session Configuration Options

PHP offers various ways to configure session behavior:

```php
// Method 1: Using ini_set (runtime configuration)
ini_set('session.cookie_lifetime', 3600); // 1 hour
ini_set('session.gc_maxlifetime', 3600);  // 1 hour

// Method 2: Before session_start with options array (PHP 7.0+)
session_start([
    'cookie_lifetime' => 3600,
    'cookie_secure' => true,
    'cookie_httponly' => true,
    'cookie_samesite' => 'Lax',
    'use_strict_mode' => true
]);

// Method 3: Configure in php.ini or .htaccess
// session.cookie_lifetime = 3600
// session.gc_maxlifetime = 3600
// session.use_strict_mode = 1
```

#### Important Session Settings

|Setting|Description|Recommended Value|
|---|---|---|
|session.cookie_lifetime|Lifetime of session cookie in seconds (0 = until browser closes)|0 or time in seconds|
|session.gc_maxlifetime|Session data lifetime in seconds|1440 (24 minutes) or higher|
|session.use_strict_mode|Prevents session fixation attacks|1 (enabled)|
|session.cookie_secure|Only send cookie over HTTPS|1 (enabled) for HTTPS sites|
|session.cookie_httponly|Prevents JavaScript access to session cookie|1 (enabled)|
|session.cookie_samesite|Controls cross-origin behavior|'Lax' or 'Strict'|
|session.use_only_cookies|Don't allow session IDs in URLs|1 (enabled)|
|session.name|Name of the session cookie|Custom value (not PHPSESSID)|

#### Configuring Session Storage Location

PHP can store session data in different locations:

```php
// Custom session save path (directory must exist and be writable)
session_save_path('/path/to/session/storage');

// Check current path
echo session_save_path();
```

Common storage mechanisms include:

1. Files (default) - Sessions stored in files
2. Database - Custom storage in MySQL, PostgreSQL, etc.
3. Redis/Memcached - In-memory storage for better performance
4. Custom handlers - Implement your own storage mechanism

#### Custom Session Handlers

For advanced requirements, you can create custom session handlers:

```php
class DatabaseSessionHandler implements SessionHandlerInterface
{
    private $db;
    
    public function __construct($db) {
        $this->db = $db;
    }
    
    public function open($savePath, $sessionName) {
        return true;
    }
    
    public function close() {
        return true;
    }
    
    public function read($id) {
        $stmt = $this->db->prepare("SELECT data FROM sessions WHERE id = ?");
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ? $row['data'] : '';
    }
    
    public function write($id, $data) {
        $stmt = $this->db->prepare("REPLACE INTO sessions (id, data, last_accessed) 
                                   VALUES (?, ?, NOW())");
        return $stmt->execute([$id, $data]);
    }
    
    public function destroy($id) {
        $stmt = $this->db->prepare("DELETE FROM sessions WHERE id = ?");
        return $stmt->execute([$id]);
    }
    
    public function gc($maxlifetime) {
        $stmt = $this->db->prepare("DELETE FROM sessions WHERE 
                                   last_accessed < DATE_SUB(NOW(), INTERVAL ? SECOND)");
        return $stmt->execute([$maxlifetime]);
    }
}

// Register the handler
$handler = new DatabaseSessionHandler($pdo);
session_set_save_handler($handler, true);
session_start();
```

**Key Points**:

- Always configure sessions before calling `session_start()`
- Use appropriate cookie settings for security
- Consider custom session handlers for high-traffic applications

### Session Variables

#### Setting and Retrieving Session Variables

Session variables are stored in the `$_SESSION` superglobal array:

```php
// Start the session
session_start();

// Setting session variables
$_SESSION['user_id'] = 123;
$_SESSION['username'] = 'john_doe';
$_SESSION['is_admin'] = true;
$_SESSION['cart'] = ['product1', 'product2'];

// Reading session variables
if (isset($_SESSION['user_id'])) {
    echo "User ID: " . $_SESSION['user_id'];
}

// Checking if a session variable exists
if (isset($_SESSION['is_admin']) && $_SESSION['is_admin']) {
    // Show admin features
}

// Using default values
$username = $_SESSION['username'] ?? 'Guest';
```

#### Removing Session Variables

```php
// Remove a specific session variable
unset($_SESSION['temporary_data']);

// Clear all session variables but keep the session active
$_SESSION = [];

// Complete session destruction
session_unset();     // Remove all variables
session_destroy();   // Destroy the session
```

#### Complex Data in Sessions

Sessions can store complex data structures thanks to automatic serialization:

```php
// Store objects
$_SESSION['user'] = new User(123, 'john_doe');

// Store arrays
$_SESSION['preferences'] = [
    'theme' => 'dark',
    'language' => 'en',
    'notifications' => true
];

// Nested arrays
$_SESSION['cart'] = [
    'items' => [
        ['id' => 101, 'name' => 'Product 1', 'quantity' => 2],
        ['id' => 205, 'name' => 'Product 2', 'quantity' => 1]
    ],
    'total' => 59.98,
    'currency' => 'USD'
];
```

Be cautious when storing objects:

- Classes must be defined before `session_start()`
- Consider implementing the `Serializable` interface for complex objects
- Avoid storing resources (database connections, file handles)

#### Session Size Considerations

Session data is loaded into memory for every request, so keep it reasonably sized:

```php
// Check session size
$size = strlen(serialize($_SESSION));
echo "Session size: " . round($size / 1024, 2) . " KB";

// Consider moving large data elsewhere
if (isset($_SESSION['large_dataset']) && strlen(serialize($_SESSION['large_dataset'])) > 50000) {
    // Store in database/cache instead
    $cacheKey = md5(session_id() . '_large_data');
    $cache->set($cacheKey, $_SESSION['large_dataset']);
    $_SESSION['large_dataset_key'] = $cacheKey;
    unset($_SESSION['large_dataset']);
}
```

**Key Points**:

- Don't store sensitive data in sessions unless properly secured
- Keep session data small for performance
- Use appropriate data structures for organized storage
- Remember to unset temporary session data when no longer needed

### Session Security

#### Session Hijacking Prevention

Session hijacking occurs when an attacker steals a user's session ID:

```php
// Regenerate session ID periodically
if (!isset($_SESSION['last_regeneration']) || 
    time() - $_SESSION['last_regeneration'] > 1800) {
    
    // Regenerate session ID every 30 minutes
    session_regenerate_id(true);
    $_SESSION['last_regeneration'] = time();
}

// Regenerate on privilege level change
function login($user) {
    // Verify credentials...
    
    // Regenerate session ID when changing authentication state
    session_regenerate_id(true);
    
    $_SESSION['user_id'] = $user['id'];
    $_SESSION['username'] = $user['username'];
    $_SESSION['is_authenticated'] = true;
}
```

#### Session Fixation Prevention

Session fixation attacks occur when an attacker sets a session ID for a victim:

```php
// Enable strict mode in php.ini or .htaccess
// session.use_strict_mode = 1

// Or at runtime
ini_set('session.use_strict_mode', 1);

// Always regenerate session ID on login
session_start();
if (valid_login($username, $password)) {
    // Regenerate ID to prevent session fixation
    session_regenerate_id(true);
    $_SESSION['authenticated'] = true;
}
```

#### Session Data Validation

Always validate session data before using it:

```php
// Don't trust session data blindly
if (isset($_SESSION['user_id'])) {
    // Verify that this user still exists in the database
    $user = fetchUserById($_SESSION['user_id']);
    if (!$user) {
        // User may have been deleted, force logout
        session_unset();
        session_destroy();
        redirect('login.php');
    }
}

// Validate expected data types
$userId = isset($_SESSION['user_id']) ? (int)$_SESSION['user_id'] : 0;
if ($userId <= 0) {
    // Invalid user ID in session
    session_regenerate_id(true);
    $_SESSION = [];
    redirect('login.php');
}
```

#### Binding Sessions to Client Fingerprints

Add additional verification by binding sessions to client characteristics:

```php
session_start();

// On login - store fingerprint
function createSessionFingerprint() {
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
    // Optionally add more factors (be careful with IP as it can change)
    return hash('sha256', $userAgent . 'some-server-secret');
}

// Set fingerprint on login
$_SESSION['fingerprint'] = createSessionFingerprint();

// On subsequent requests - verify fingerprint
function verifySessionFingerprint() {
    if (!isset($_SESSION['fingerprint'])) {
        return false;
    }
    
    return hash_equals(
        $_SESSION['fingerprint'],
        createSessionFingerprint()
    );
}

// Check during request processing
if (!verifySessionFingerprint()) {
    // Potential session hijacking attempt
    session_unset();
    session_destroy();
    redirect('login.php?error=security');
}
```

#### Secure Cookie Configuration

Configure session cookies with security in mind:

```php
// PHP 7.3+ with samesite support
session_start([
    'cookie_secure' => true,         // HTTPS only
    'cookie_httponly' => true,       // No JavaScript access
    'cookie_samesite' => 'Lax',      // Restrict cross-site requests
    'use_only_cookies' => true,      // No session IDs in URLs
    'use_strict_mode' => true,       // Prevent session fixation
    'cookie_lifetime' => 0,          // Until browser closes
    'cookie_path' => '/',            // Valid for entire domain
    'name' => 'MYSECURESESSID'       // Custom session name
]);

// For PHP < 7.3 (without native samesite)
$cookieParams = session_get_cookie_params();
session_set_cookie_params(
    $cookieParams["lifetime"],
    $cookieParams["path"] . '; samesite=Lax', // Manually add samesite
    $cookieParams["domain"],
    true,  // secure
    true   // httponly
);
session_start();
```

#### Proper Session Cleanup

Always clean up sessions properly:

```php
function logout() {
    // Clear all session variables
    $_SESSION = [];
    
    // Delete the session cookie
    if (ini_get("session.use_cookies")) {
        $params = session_get_cookie_params();
        setcookie(
            session_name(),
            '',
            time() - 42000,
            $params["path"],
            $params["domain"],
            $params["secure"],
            $params["httponly"]
        );
    }
    
    // Destroy the session
    session_destroy();
    
    // Redirect to login page
    header("Location: login.php");
    exit;
}
```

#### Session Expiration Handling

```php
session_start();

// Check if session has expired
if (isset($_SESSION['last_activity']) && 
    (time() - $_SESSION['last_activity'] > 1800)) {
    // Session expired (30 minutes inactivity)
    session_unset();
    session_destroy();
    header("Location: login.php?expired=1");
    exit;
}

// Update last activity time
$_SESSION['last_activity'] = time();
```

#### Session Concurrency Control

Prevent multiple simultaneous logins:

```php
function login($userId, $token) {
    // Generate and store a unique token in DB
    $sessionToken = bin2hex(random_bytes(32));
    storeSessionTokenInDatabase($userId, $sessionToken);
    
    // Store in session
    $_SESSION['user_id'] = $userId;
    $_SESSION['session_token'] = $sessionToken;
}

// On each protected page
function verifySession() {
    if (!isset($_SESSION['user_id']) || !isset($_SESSION['session_token'])) {
        return false;
    }
    
    // Check if token in DB matches session
    $dbToken = getSessionTokenFromDatabase($_SESSION['user_id']);
    return hash_equals($_SESSION['session_token'], $dbToken);
}

// If verification fails, someone else logged in with this account
if (!verifySession()) {
    session_unset();
    session_destroy();
    header("Location: login.php?error=concurrent_login");
    exit;
}
```

**Key Points**:

- Always regenerate session IDs during authentication state changes
- Implement proper session timeouts
- Validate session data before using it
- Use secure cookie settings
- Bind sessions to client characteristics when appropriate
- Properly destroy sessions on logout

### Session Best Practices

#### Abstraction Layer for Session Management

Create a session management class for organized session handling:

```php
class SessionManager {
    public function __construct($options = []) {
        $defaults = [
            'cookie_lifetime' => 0,
            'cookie_secure' => true,
            'cookie_httponly' => true,
            'cookie_samesite' => 'Lax',
            'use_strict_mode' => true,
            'gc_maxlifetime' => 1800,
            'name' => 'MYAPPSESSION'
        ];
        
        $sessionOptions = array_merge($defaults, $options);
        session_start($sessionOptions);
        
        $this->initializeSession();
    }
    
    private function initializeSession() {
        // Security check - regenerate ID periodically
        if (!isset($_SESSION['last_regeneration']) || 
            time() - $_SESSION['last_regeneration'] > 900) {
            session_regenerate_id(true);
            $_SESSION['last_regeneration'] = time();
        }
        
        // Set/update last activity time
        $_SESSION['last_activity'] = time();
    }
    
    public function set($key, $value) {
        $_SESSION[$key] = $value;
    }
    
    public function get($key, $default = null) {
        return $_SESSION[$key] ?? $default;
    }
    
    public function remove($key) {
        if (isset($_SESSION[$key])) {
            unset($_SESSION[$key]);
            return true;
        }
        return false;
    }
    
    public function has($key) {
        return isset($_SESSION[$key]);
    }
    
    public function clear() {
        $_SESSION = [];
    }
    
    public function destroy() {
        $this->clear();
        
        // Delete the session cookie
        if (ini_get("session.use_cookies")) {
            $params = session_get_cookie_params();
            setcookie(
                session_name(),
                '',
                time() - 42000,
                $params["path"],
                $params["domain"],
                $params["secure"],
                $params["httponly"]
            );
        }
        
        // Destroy the session
        return session_destroy();
    }
    
    public function flash($key, $value = null) {
        if ($value !== null) {
            // Set flash data
            $_SESSION['_flash'][$key] = $value;
        } else {
            // Get and remove flash data
            if (isset($_SESSION['_flash'][$key])) {
                $value = $_SESSION['_flash'][$key];
                unset($_SESSION['_flash'][$key]);
                return $value;
            }
            return null;
        }
    }
    
    public function regenerateId() {
        return session_regenerate_id(true);
    }
}

// Usage example
$session = new SessionManager();
$session->set('user_id', 123);
$session->flash('message', 'Operation successful');

// On next page
echo $session->flash('message'); // Shows and clears message
```

#### Session Usage in Modern PHP Frameworks

Most modern PHP frameworks provide robust session handling:

- Laravel uses encrypted, signed session cookies by default
- Symfony provides session handling through its HttpFoundation component
- CodeIgniter includes a comprehensive Session class

When using frameworks, follow their recommended session practices:

```php
// Laravel example
Session::put('user_id', $user->id);
$userId = Session::get('user_id');

// Symfony example
$session = $request->getSession();
$session->set('user_id', $user->getId());
$userId = $session->get('user_id');
```

**Conclusion**: PHP sessions provide a powerful mechanism for state management in web applications. When properly configured and secured, they enable essential functionality like user authentication, shopping carts, and personalized experiences. Always prioritize security when working with sessions by implementing proper configuration, validation, and cleanup procedures. Using session abstractions or framework-provided session handling can significantly reduce security risks and improve code organization.

---

## Cookies in PHP

### Introduction to PHP Cookies

Cookies are small pieces of data stored by a web browser on the client's machine. They serve as a fundamental mechanism for maintaining state across HTTP requests in web applications. PHP offers built-in functions to create, read, modify, and delete cookies. Unlike sessions, which store data on the server, cookies store data directly on the user's device, making them suitable for non-sensitive information that needs to persist across sessions, such as user preferences, tracking information, and authentication tokens.

### Creating and Reading Cookies

#### Setting Cookies

PHP uses the `setcookie()` function to create cookies:

```php
// Basic cookie creation
setcookie('username', 'john_doe');

// Cookie with expiration time (1 hour from now)
setcookie('theme', 'dark', time() + 3600);

// Cookie with path, domain, secure, and httponly parameters
setcookie(
    'preference',   // name
    'layout_grid',  // value
    time() + 86400, // expiration (24 hours)
    '/',            // path (entire domain)
    'example.com',  // domain (optional)
    true,           // secure (HTTPS only)
    true            // httponly (not accessible via JavaScript)
);

// PHP 7.3+ with SameSite attribute
setcookie(
    'user_token', 
    'abc123', 
    [
        'expires' => time() + 3600,
        'path' => '/',
        'domain' => 'example.com',
        'secure' => true,
        'httponly' => true,
        'samesite' => 'Lax'  // 'None', 'Lax', or 'Strict'
    ]
);
```

Important notes about setting cookies:

- The `setcookie()` function must be called before any output is sent to the browser
- Cookie values should be URL-encoded if they contain special characters
- Expiration time is set as a Unix timestamp
- The default expiration is browser session (cookie deleted when browser closes)

#### Reading Cookies

Cookies are automatically added to the `$_COOKIE` superglobal array when the page loads:

```php
// Check if a cookie exists
if (isset($_COOKIE['username'])) {
    echo "Welcome back, " . htmlspecialchars($_COOKIE['username']);
}

// Access with default value
$theme = $_COOKIE['theme'] ?? 'light';

// Reading multiple cookies
$preferences = [
    'theme' => $_COOKIE['theme'] ?? 'light',
    'layout' => $_COOKIE['layout'] ?? 'default',
    'fontSize' => $_COOKIE['fontSize'] ?? 'medium'
];
```

#### Modifying Cookies

To modify a cookie, set it again with the same name:

```php
// Update cookie value
setcookie('theme', 'light', time() + 3600);

// Update expiration time (extend cookie lifetime)
setcookie('username', $_COOKIE['username'], time() + 86400 * 30); // 30 days
```

#### Deleting Cookies

To delete a cookie, set it with an expiration time in the past:

```php
// Delete a cookie
setcookie('username', '', time() - 3600);

// Delete with all original parameters
setcookie(
    'user_token', 
    '', 
    time() - 3600, 
    '/', 
    'example.com', 
    true, 
    true
);
```

When deleting cookies, it's important to specify the same path, domain, and other parameters that were used when creating the cookie.

#### Working with Arrays in Cookies

PHP doesn't directly support array storage in cookies, but you can use serialization:

```php
// Store array in cookie
$preferences = [
    'theme' => 'dark',
    'layout' => 'compact',
    'notifications' => true
];
setcookie('user_prefs', json_encode($preferences), time() + 86400);

// Read array from cookie
if (isset($_COOKIE['user_prefs'])) {
    $preferences = json_decode($_COOKIE['user_prefs'], true);
    $theme = $preferences['theme'] ?? 'light';
}
```

Alternatively, you can use square brackets in cookie names:

```php
// Set individual array elements
setcookie('preferences[theme]', 'dark', time() + 86400);
setcookie('preferences[layout]', 'compact', time() + 86400);

// Access array elements
$theme = $_COOKIE['preferences']['theme'] ?? 'light';
```

**Key Points**:

- Cookies must be set before any output is sent to the browser
- Cookie values are automatically URL-encoded and decoded
- Always validate and sanitize cookie data like any user input
- Consider size limitations (usually 4KB per cookie, with browser-specific limits)

### Cookie Parameters and Security

#### Understanding Cookie Parameters

Cookie behavior is controlled by several parameters:

|Parameter|Description|Default|Recommended|
|---|---|---|---|
|Name|Cookie identifier|Required|Descriptive, with prefix|
|Value|Data to store|Required|URL-encoded if needed|
|Expires/Max-Age|Lifetime of cookie|Session|Application-specific|
|Path|URL path where cookie is accessible|Current directory|'/' for site-wide|
|Domain|Domain where cookie is accessible|Current hostname|Specific subdomain if needed|
|Secure|Only sent over HTTPS|false|true|
|HttpOnly|Prevent JavaScript access|false|true|
|SameSite|Cross-origin request behavior|Browser default|'Lax' or 'Strict'|

#### Secure Cookie Configuration

```php
// Recommended secure cookie configuration
setcookie(
    'app_auth_token',
    $token,
    [
        'expires' => time() + 3600,
        'path' => '/',
        'domain' => 'example.com',
        'secure' => true,
        'httponly' => true,
        'samesite' => 'Lax'  // Balance between security and usability
    ]
);

// For APIs or services requiring cross-site cookies
setcookie(
    'api_token',
    $token,
    [
        'expires' => time() + 3600,
        'path' => '/api/',
        'domain' => 'api.example.com',
        'secure' => true,     // Must be true for SameSite=None
        'httponly' => true,
        'samesite' => 'None'  // Allow cross-site requests
    ]
);
```

#### Understanding SameSite Attribute

The SameSite attribute controls when cookies are sent in cross-site requests:

- `None`: Cookies sent on all requests (requires Secure flag)
- `Lax`: Cookies sent on same-site requests and top-level navigations from other sites
- `Strict`: Cookies only sent on same-site requests

```php
// SameSite examples for different scenarios

// For general authentication (default in modern browsers)
// Allows cookies on direct navigation but blocks in cross-site requests
setcookie('session_token', $token, ['samesite' => 'Lax', 'secure' => true, /* other params */]);

// For sensitive operations (banking, payment)
// Only allows cookies on same-site requests
setcookie('csrf_token', $csrfToken, ['samesite' => 'Strict', 'secure' => true, /* other params */]);

// For third-party integrations (payment providers, widgets)
// Allows cookies on all requests
setcookie('service_token', $serviceToken, ['samesite' => 'None', 'secure' => true, /* other params */]);
```

#### Cookie Security Best Practices

##### Use Secure Flag

The Secure flag ensures cookies are only transmitted over HTTPS:

```php
// Always use secure flag on production
$isProduction = true; // Determine this based on environment
setcookie('auth_token', $token, [
    'secure' => $isProduction,
    // other parameters
]);
```

##### Use HttpOnly Flag

The HttpOnly flag prevents JavaScript access to cookies, mitigating XSS attacks:

```php
// Authentication cookies should always use HttpOnly
setcookie('session_id', $sessionId, [
    'httponly' => true,
    // other parameters
]);
```

##### Implement Cookie Prefixes

Cookie prefixes add an extra layer of security:

```php
// __Secure- prefix requires Secure flag and HTTPS
setcookie('__Secure-Token', $value, [
    'secure' => true,
    'path' => '/',
    // other parameters
]);

// __Host- prefix requires Secure flag, no Domain, and Path=/
setcookie('__Host-UserID', $userId, [
    'secure' => true,
    'path' => '/',
    // No domain parameter
]);
```

##### Use Proper Expiration Times

Set cookie lifetimes appropriate to their purpose:

```php
// Session identification (short-lived)
setcookie('session_id', $sid, [
    'expires' => 0, // Browser session only
    // other parameters
]);

// Remember-me functionality (longer lived)
setcookie('remember_token', $token, [
    'expires' => time() + (86400 * 30), // 30 days
    // other parameters
]);

// User preferences (long-lived)
setcookie('theme_preference', $theme, [
    'expires' => time() + (86400 * 365), // 1 year
    // other parameters
]);
```

##### Encrypt Sensitive Cookie Data

For added security, encrypt cookie values:

```php
// Encrypt cookie data using sodium (PHP 7.2+)
$key = getEncryptionKeyFromSecureStorage();
$value = json_encode(['user_id' => 123, 'role' => 'admin']);

// Encrypt
$nonce = random_bytes(SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
$encrypted = sodium_crypto_secretbox($value, $nonce, $key);
$cookieValue = base64_encode($nonce . $encrypted);

setcookie('user_data', $cookieValue, [
    'expires' => time() + 3600,
    'secure' => true,
    'httponly' => true
]);

// Decrypt
if (isset($_COOKIE['user_data'])) {
    $decoded = base64_decode($_COOKIE['user_data']);
    $nonce = substr($decoded, 0, SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
    $ciphertext = substr($decoded, SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
    $decrypted = sodium_crypto_secretbox_open($ciphertext, $nonce, $key);
    if ($decrypted !== false) {
        $userData = json_decode($decrypted, true);
    }
}
```

##### Signing Cookies to Prevent Tampering

Sign cookies to detect modifications:

```php
// Sign cookie value
function createSignedCookie($name, $value, $secret, $options = []) {
    $signature = hash_hmac('sha256', $name . '=' . $value, $secret);
    $signedValue = $value . '.' . $signature;
    return setcookie($name, $signedValue, $options);
}

// Verify signature
function getVerifiedCookie($name, $secret) {
    if (!isset($_COOKIE[$name])) {
        return null;
    }
    
    $parts = explode('.', $_COOKIE[$name], 2);
    if (count($parts) !== 2) {
        return null;
    }
    
    list($value, $signature) = $parts;
    $expectedSignature = hash_hmac('sha256', $name . '=' . $value, $secret);
    
    if (hash_equals($expectedSignature, $signature)) {
        return $value;
    }
    
    return null;
}

// Usage
$secret = '...'; // From secure configuration
createSignedCookie('user_id', '123', $secret, [
    'expires' => time() + 3600,
    'secure' => true,
    'httponly' => true
]);

// Later, verify and use
$userId = getVerifiedCookie('user_id', $secret);
if ($userId !== null) {
    // Cookie is valid and not tampered
}
```

##### Cookie Size Optimization

Keep cookies small for performance:

```php
// Avoid storing large amounts of data
// Bad:
$largeObject = [...]; // Large array with many entries
setcookie('user_data', json_encode($largeObject)); // Could exceed size limits

// Better:
$identifier = generateUniqueId();
storeDataInDatabase($identifier, $largeObject);
setcookie('user_data_id', $identifier); // Just store the reference

// Later retrieve
if (isset($_COOKIE['user_data_id'])) {
    $largeObject = getDataFromDatabase($_COOKIE['user_data_id']);
}
```

#### GDPR and Cookie Compliance

For European users, consider GDPR requirements:

```php
// Only set cookies after consent
if (isset($_COOKIE['cookie_consent']) && $_COOKIE['cookie_consent'] === 'accepted') {
    // Set functional and analytics cookies
    setcookie('analytics_id', generateAnalyticsId(), [
        'expires' => time() + 86400 * 365,
        'path' => '/',
        'samesite' => 'Lax'
    ]);
}

// Set essential cookies that don't require consent
setcookie('csrf_token', generateCsrfToken(), [
    'expires' => 0, // Session only
    'path' => '/',
    'secure' => true,
    'httponly' => true
]);

// Set cookie consent cookie itself
if (isset($_POST['accept_cookies'])) {
    setcookie('cookie_consent', 'accepted', [
        'expires' => time() + 86400 * 365, // 1 year
        'path' => '/',
        'samesite' => 'Lax'
    ]);
}
```

#### Cross-Domain Cookies

For applications spanning multiple domains:

```php
// For subdomains
setcookie('shared_session', $token, [
    'domain' => '.example.com', // Note the leading dot
    'path' => '/',
    'secure' => true,
    'httponly' => true
]);

// For completely different domains, use alternatives:
// 1. URL parameters
// 2. Federated login
// 3. Cross-domain messaging (postMessage)
```

#### Testing Cookies

Verify cookie behavior during development:

```php
// Debug cookies
echo "<pre>";
print_r($_COOKIE);
echo "</pre>";

// Check if cookies are enabled
function areCookiesEnabled() {
    setcookie('test_cookie', '1', time() + 3600, '/');
    
    // Redirect to self to check if cookie was set
    header('Location: ' . $_SERVER['PHP_SELF'] . '?cookie_check=1');
    exit;
}

if (isset($_GET['cookie_check'])) {
    if (isset($_COOKIE['test_cookie'])) {
        echo "Cookies are enabled";
        setcookie('test_cookie', '', time() - 3600, '/'); // Clean up
    } else {
        echo "Cookies are disabled";
    }
}
```

**Key Points**:

- Always use Secure and HttpOnly flags for sensitive cookies
- Choose appropriate SameSite value for your use case
- Set reasonable expiration times based on data sensitivity
- Consider encrypting or signing cookies with sensitive data
- Be mindful of GDPR and other privacy regulations

### Cookies vs. Sessions: When to Use Each

|Feature|Cookies|Sessions|
|---|---|---|
|Storage Location|Client (browser)|Server|
|Size Limit|~4KB per cookie|Limited by server memory/configuration|
|Lifetime|Can persist indefinitely|Usually lost on browser close|
|Security|Less secure, can be accessed/modified by users|More secure, only ID stored on client|
|Accessibility|Available immediately|Requires session_start() function|
|Use Cases|Preferences, non-sensitive data, tracking|Authentication, cart data, sensitive information|

**Best Practices for Cookie Usage**:

1. Use cookies for:
    
    - User preferences (theme, language)
    - Non-sensitive tracking (analytics)
    - Remember-me functionality
    - Cross-site authentication tokens
2. Use sessions for:
    
    - User authentication
    - Shopping cart data
    - Form wizard state
    - Sensitive user data
3. Combine both:
    
    - Session ID stored in secure cookie
    - Long-term authentication with secure cookie + server verification

```php
// Example of combined approach for persistent login
if (!isset($_SESSION['user_id']) && isset($_COOKIE['remember_token'])) {
    // User not in session but has remember token
    $token = getVerifiedCookie('remember_token', $SECRET_KEY);
    if ($token) {
        $user = findUserByRememberToken($token);
        if ($user) {
            // Valid token, start session
            $_SESSION['user_id'] = $user['id'];
            // Regenerate token for security
            $newToken = generateSecureToken();
            updateUserRememberToken($user['id'], $newToken);
            createSignedCookie('remember_token', $newToken, $SECRET_KEY, [
                'expires' => time() + (86400 * 30),
                'path' => '/',
                'secure' => true,
                'httponly' => true,
                'samesite' => 'Lax'
            ]);
        }
    }
}
```

### Cookie Management Classes

Create abstraction layers for cleaner cookie handling:

```php
class Cookie {
    public static function set($name, $value, $options = []) {
        $defaults = [
            'expires' => 0,
            'path' => '/',
            'domain' => '',
            'secure' => true,
            'httponly' => true,
            'samesite' => 'Lax'
        ];
        
        $options = array_merge($defaults, $options);
        
        if (PHP_VERSION_ID >= 70300) {
            return setcookie($name, $value, $options);
        } else {
            // For PHP < 7.3
            return setcookie(
                $name,
                $value,
                $options['expires'],
                $options['path'] . '; samesite=' . $options['samesite'],
                $options['domain'],
                $options['secure'],
                $options['httponly']
            );
        }
    }
    
    public static function get($name, $default = null) {
        return $_COOKIE[$name] ?? $default;
    }
    
    public static function has($name) {
        return isset($_COOKIE[$name]);
    }
    
    public static function delete($name, $options = []) {
        $defaults = [
            'path' => '/',
            'domain' => '',
            'secure' => true,
            'httponly' => true,
            'samesite' => 'Lax'
        ];
        
        $options = array_merge($defaults, $options);
        $options['expires'] = time() - 3600;
        
        return self::set($name, '', $options);
    }
    
    public static function setEncrypted($name, $value, $key, $options = []) {
        if (!extension_loaded('sodium')) {
            throw new \RuntimeException('Sodium extension required for encrypted cookies');
        }
        
        $nonce = random_bytes(SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
        $encrypted = sodium_crypto_secretbox((string)$value, $nonce, $key);
        $cookieValue = base64_encode($nonce . $encrypted);
        
        return self::set($name, $cookieValue, $options);
    }
    
    public static function getEncrypted($name, $key, $default = null) {
        if (!self::has($name)) {
            return $default;
        }
        
        try {
            $decoded = base64_decode($_COOKIE[$name]);
            $nonce = substr($decoded, 0, SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
            $ciphertext = substr($decoded, SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
            $decrypted = sodium_crypto_secretbox_open($ciphertext, $nonce, $key);
            
            if ($decrypted === false) {
                return $default;
            }
            
            return $decrypted;
        } catch (\Exception $e) {
            // Decryption failed
            return $default;
        }
    }
}

// Usage
$encKey = sodium_crypto_secretbox_keygen(); // Store securely
Cookie::set('language', 'en');
Cookie::setEncrypted('user_data', json_encode(['id' => 123]), $encKey, ['expires' => time() + 3600]);
$userData = json_decode(Cookie::getEncrypted('user_data', $encKey), true);
Cookie::delete('old_cookie');
```

**Conclusion**: Cookies remain a fundamental tool for web development in PHP, allowing state persistence and user experience personalization. However, their proper implementation requires careful attention to security considerations and best practices. By using the right parameters, implementing encryption where necessary, and following modern security standards like SameSite attributes, you can leverage cookies safely in your PHP applications. Always remember that cookies are stored on the client side and can be viewed and modified, so never store sensitive information in unprotected cookies.

---

# Object-Oriented PHP

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

# Database Integration



---

## PHP Database API (PDO)

### Introduction to PDO

PHP Data Objects (PDO) is a database access layer providing a consistent interface for working with multiple databases in PHP. Introduced in PHP 5.1, PDO offers significant advantages over older APIs like `mysql_*` functions or MySQLi, primarily through its unified interface across different database systems and its strong security features.

**Key Points**:

- PDO is an abstraction layer for database access
- Supports multiple database systems through drivers
- Provides consistent methods across different databases
- Offers modern, secure approaches to database interaction
- Included in PHP by default since PHP 5.1

### Database Connections

#### Establishing a Connection

To connect to a database using PDO, you create a new instance of the `PDO` class. The constructor requires a Data Source Name (DSN), username, password, and optional configuration options.

```php
<?php
try {
    // Basic connection syntax
    $pdo = new PDO(
        'mysql:host=localhost;dbname=mydb;charset=utf8mb4',
        'username',
        'password',
        [
            // Optional configuration options
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    
    echo "Connected successfully";
} catch (PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}
?>
```

#### DSN (Data Source Name) Format

The DSN format varies depending on the database driver:

```php
// MySQL
$dsn = 'mysql:host=localhost;dbname=mydb;charset=utf8mb4';

// PostgreSQL
$dsn = 'pgsql:host=localhost;port=5432;dbname=mydb';

// SQLite
$dsn = 'sqlite:/path/to/database.sqlite';
$dsn = 'sqlite::memory:'; // In-memory database

// Microsoft SQL Server
$dsn = 'sqlsrv:Server=localhost;Database=mydb';

// Oracle
$dsn = 'oci:dbname=//localhost:1521/mydb';
```

#### Connection Options

PDO offers several attributes that can be set during connection:

```php
<?php
$options = [
    // Error reporting
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, // Throw exceptions on errors
    
    // Default fetch mode
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC, // Return results as associative arrays
    
    // Prepared statement behavior
    PDO::ATTR_EMULATE_PREPARES => false, // Use real prepared statements
    
    // Case conversion for column names
    PDO::ATTR_CASE => PDO::CASE_NATURAL, // Leave column names as returned by the database
    
    // Auto-commit mode
    PDO::ATTR_AUTOCOMMIT => true, // Auto-commit each query (default)
    
    // NULL and empty string handling
    PDO::ATTR_ORACLE_NULLS => PDO::NULL_NATURAL, // No conversion
    
    // Performance options
    PDO::ATTR_PERSISTENT => false // Use non-persistent connections (default)
];

$pdo = new PDO($dsn, $username, $password, $options);
?>
```

#### Connection Management Patterns

Here's a simple database connection class:

```php
<?php
class Database {
    private static ?PDO $instance = null;
    
    public static function getInstance(): PDO {
        if (self::$instance === null) {
            $config = require 'config.php';
            
            $dsn = "{$config['driver']}:host={$config['host']};dbname={$config['database']};charset={$config['charset']}";
            
            try {
                self::$instance = new PDO(
                    $dsn,
                    $config['username'],
                    $config['password'],
                    $config['options']
                );
            } catch (PDOException $e) {
                throw new Exception("Database connection failed: " . $e->getMessage());
            }
        }
        
        return self::$instance;
    }
    
    // Prevent direct instantiation
    private function __construct() {}
    
    // Prevent cloning
    private function __clone() {}
}

// Usage
try {
    $db = Database::getInstance();
    // Use $db for queries...
} catch (Exception $e) {
    die($e->getMessage());
}
?>
```

### Prepared Statements

Prepared statements are a feature that separates SQL logic from data, which helps prevent SQL injection attacks and can improve performance for repeated queries.

**Key Points**:

- Separate SQL code from parameters
- Parameters are sent separately from the SQL
- PDO automatically escapes parameters
- Statements can be reused with different parameters
- Improved security and potential performance benefits

#### Basic Prepared Statement

```php
<?php
try {
    // Prepare the statement
    $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
    
    // Execute with parameters
    $stmt->execute(['john_doe']);
    
    // Fetch the results
    $user = $stmt->fetch();
    
    if ($user) {
        echo "User found: " . $user['username'];
    } else {
        echo "User not found";
    }
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
```

#### Named Parameters

PDO supports named parameters, which can make code more readable than positional parameters:

```php
<?php
$stmt = $pdo->prepare("INSERT INTO users (username, email, created_at) VALUES (:username, :email, :created_at)");

$stmt->execute([
    ':username' => 'john_doe',
    ':email' => 'john@example.com',
    ':created_at' => date('Y-m-d H:i:s')
]);

// The colon prefix is optional in the parameter array
$stmt->execute([
    'username' => 'jane_doe',
    'email' => 'jane@example.com',
    'created_at' => date('Y-m-d H:i:s')
]);
?>
```

#### Binding Parameters

Parameters can also be bound individually:

```php
<?php
$stmt = $pdo->prepare("SELECT * FROM users WHERE status = :status AND role = :role");

// Bind parameters
$stmt->bindParam(':status', $status);
$stmt->bindParam(':role', $role);

// Set parameter values
$status = 'active';
$role = 'admin';

// Execute with bound values
$stmt->execute();

// Fetch results
$users = $stmt->fetchAll();
?>
```

#### Binding Parameters with Types

For stricter type control, you can specify parameter types:

```php
<?php
$stmt = $pdo->prepare("SELECT * FROM products WHERE id = :id AND price > :price");

// Bind with explicit types
$stmt->bindValue(':id', $id, PDO::PARAM_INT);
$stmt->bindValue(':price', $price, PDO::PARAM_STR);

// Execute
$stmt->execute();
?>
```

Available parameter types include:

- `PDO::PARAM_STR` (string, default)
- `PDO::PARAM_INT` (integer)
- `PDO::PARAM_BOOL` (boolean)
- `PDO::PARAM_NULL` (NULL value)
- `PDO::PARAM_LOB` (large object data)

#### Fetching Results

PDO offers multiple ways to fetch results:

```php
<?php
$stmt = $pdo->prepare("SELECT id, username, email FROM users WHERE status = ?");
$stmt->execute(['active']);

// 1. Fetch a single row
$user = $stmt->fetch();  // Returns false if no rows

// 2. Fetch all rows
$users = $stmt->fetchAll();

// 3. Fetch a single column from next row
$username = $stmt->fetchColumn(1);  // Second column (0-indexed)

// 4. Fetch into a class
class User {
    public $id;
    public $username;
    public $email;
    
    public function getDisplayName() {
        return $this->username;
    }
}

$stmt->setFetchMode(PDO::FETCH_CLASS, 'User');
$user = $stmt->fetch();
echo $user->getDisplayName();
?>
```

#### Fetch Modes

PDO offers several fetch modes to control how results are returned:

```php
<?php
// Different fetch modes
$stmt = $pdo->prepare("SELECT id, username, email FROM users LIMIT 10");
$stmt->execute();

// 1. Associative array (column name as key)
$stmt->setFetchMode(PDO::FETCH_ASSOC);
$row = $stmt->fetch();  // ['id' => 1, 'username' => 'john', 'email' => 'john@example.com']

// 2. Numeric array (column position as key)
$stmt->setFetchMode(PDO::FETCH_NUM);
$row = $stmt->fetch();  // [0 => 1, 1 => 'john', 2 => 'john@example.com']

// 3. Both associative and numeric (default)
$stmt->setFetchMode(PDO::FETCH_BOTH);
$row = $stmt->fetch();  // ['id' => 1, 0 => 1, 'username' => 'john', 1 => 'john', ...]

// 4. Object with column names as properties
$stmt->setFetchMode(PDO::FETCH_OBJ);
$row = $stmt->fetch();  // stdClass Object ( [id] => 1 [username] => john [email] => john@example.com )

// 5. Into specified class
$stmt->setFetchMode(PDO::FETCH_CLASS, 'User');
$user = $stmt->fetch();  // User Object with populated properties

// 6. Key-value pairs (first column as key, second as value)
$stmt->setFetchMode(PDO::FETCH_KEY_PAIR);
$pairs = $stmt->fetchAll();  // [1 => 'john', 2 => 'jane', ...]

// 7. Group rows by first column
$stmt->setFetchMode(PDO::FETCH_GROUP);
$grouped = $stmt->fetchAll();
?>
```

#### Working with Multiple Result Sets

For stored procedures that return multiple result sets:

```php
<?php
$stmt = $pdo->prepare("CALL get_user_with_orders(:user_id)");
$stmt->execute(['user_id' => 123]);

// First result set (user data)
$user = $stmt->fetch(PDO::FETCH_ASSOC);

// Move to the next result set (orders)
$stmt->nextRowset();

// Fetch orders
$orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
```

### Error Handling

PDO provides multiple ways to handle errors. Setting appropriate error handling is crucial for both development and production environments.

**Key Points**:

- Three error handling modes: silent, warning, or exception
- Exception mode is recommended for most applications
- Allows for clean try-catch blocks
- Provides detailed error information
- Enables unified error handling across database operations

#### Error Modes

PDO offers three error handling modes:

```php
<?php
// 1. Silent mode (default) - returns false on error
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_SILENT);

// 2. Warning mode - issues PHP warning on error
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_WARNING);

// 3. Exception mode - throws PDOException on error (recommended)
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
?>
```

#### Try-Catch Error Handling

Using exceptions is the recommended approach:

```php
<?php
try {
    // Set up connection
    $pdo = new PDO(
        'mysql:host=localhost;dbname=mydb;charset=utf8mb4',
        'username',
        'password',
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
    
    // Prepare and execute statement
    $stmt = $pdo->prepare("INSERT INTO users (username, email) VALUES (?, ?)");
    $stmt->execute(['john_doe', 'john@example.com']);
    
    echo "New user created with ID: " . $pdo->lastInsertId();
} catch (PDOException $e) {
    // Log error details
    error_log("Database error: " . $e->getMessage());
    
    // For development
    if (defined('DEBUG') && DEBUG) {
        echo "Error: " . $e->getMessage();
        echo "<pre>" . $e->getTraceAsString() . "</pre>";
    } else {
        // For production - generic message
        echo "A database error occurred. Please try again later.";
    }
} finally {
    // Clean up resources
    $pdo = null;
    $stmt = null;
}
?>
```

#### Checking for Specific Errors

You can check for specific database errors using the SQLSTATE code:

```php
<?php
try {
    $stmt = $pdo->prepare("INSERT INTO users (email) VALUES (?)");
    $stmt->execute(['john@example.com']);
} catch (PDOException $e) {
    if ($e->getCode() == '23000') {
        // Integrity constraint violation (e.g., duplicate key)
        echo "This email address is already registered.";
    } else {
        echo "Database error: " . $e->getMessage();
    }
}
?>
```

Common SQLSTATE codes:

- `23000`: Integrity constraint violation
- `42S02`: Base table or view not found
- `42000`: Syntax error or access violation
- `HY000`: General error

#### Transaction Error Handling

Error handling is particularly important with transactions:

```php
<?php
try {
    // Begin transaction
    $pdo->beginTransaction();
    
    // Multiple operations
    $stmt1 = $pdo->prepare("UPDATE accounts SET balance = balance - ? WHERE id = ?");
    $stmt1->execute([100, 1]);
    
    $stmt2 = $pdo->prepare("UPDATE accounts SET balance = balance + ? WHERE id = ?");
    $stmt2->execute([100, 2]);
    
    // Check balances
    $stmt3 = $pdo->prepare("SELECT balance FROM accounts WHERE id = ?");
    $stmt3->execute([1]);
    $balance = $stmt3->fetchColumn();
    
    if ($balance < 0) {
        // Manually throw exception for business rule
        throw new Exception("Insufficient funds");
    }
    
    // Commit transaction
    $pdo->commit();
    echo "Transfer successful";
} catch (Exception $e) {
    // Roll back transaction on any error
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    echo "Transfer failed: " . $e->getMessage();
}
?>
```

#### Custom Error Handler Class

For more sophisticated error handling, consider creating a custom error handler:

```php
<?php
class DatabaseErrorHandler {
    private static array $friendlyMessages = [
        '23000' => 'This record already exists or violates database constraints.',
        '42S02' => 'The requested data does not exist.',
        '42000' => 'Invalid database request.',
        'HY000' => 'A database error occurred.'
    ];
    
    public static function handle(PDOException $e, bool $debug = false): void {
        // Log the error
        self::logError($e);
        
        // Display appropriate message
        if ($debug) {
            self::displayDebugInfo($e);
        } else {
            self::displayFriendlyMessage($e);
        }
    }
    
    private static function logError(PDOException $e): void {
        $message = date('Y-m-d H:i:s') . " - SQLSTATE[{$e->getCode()}]: {$e->getMessage()}";
        error_log($message, 3, 'database_errors.log');
    }
    
    private static function displayFriendlyMessage(PDOException $e): void {
        $code = $e->getCode();
        $message = self::$friendlyMessages[$code] ?? 'A database error occurred.';
        
        echo "<div class='error'>$message</div>";
    }
    
    private static function displayDebugInfo(PDOException $e): void {
        echo "<div class='error-debug'>";
        echo "<h3>Database Error</h3>";
        echo "<p><strong>SQLSTATE:</strong> {$e->getCode()}</p>";
        echo "<p><strong>Message:</strong> {$e->getMessage()}</p>";
        echo "<pre>{$e->getTraceAsString()}</pre>";
        echo "</div>";
    }
}

// Usage
try {
    $pdo = new PDO($dsn, $username, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $stmt = $pdo->prepare("SELECT * FROM non_existent_table");
    $stmt->execute();
} catch (PDOException $e) {
    DatabaseErrorHandler::handle($e, true); // true for debug mode
}
?>
```

### Practical Examples

#### User Authentication System

```php
<?php
function authenticateUser(PDO $pdo, string $email, string $password): ?array {
    try {
        $stmt = $pdo->prepare("SELECT id, username, email, password_hash FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            return null; // User not found
        }
        
        // Verify password
        if (password_verify($password, $user['password_hash'])) {
            // Remove password hash from returned data
            unset($user['password_hash']);
            return $user;
        }
        
        return null; // Password incorrect
    } catch (PDOException $e) {
        error_log("Authentication error: " . $e->getMessage());
        throw new Exception("Authentication failed. Please try again later.");
    }
}

function registerUser(PDO $pdo, string $username, string $email, string $password): int {
    try {
        // Check if email already exists
        $checkStmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
        $checkStmt->execute([$email]);
        
        if ($checkStmt->fetch()) {
            throw new Exception("Email already registered");
        }
        
        // Insert new user
        $stmt = $pdo->prepare("
            INSERT INTO users (username, email, password_hash, created_at) 
            VALUES (?, ?, ?, ?)
        ");
        
        $passwordHash = password_hash($password, PASSWORD_DEFAULT);
        $createdAt = date('Y-m-d H:i:s');
        
        $stmt->execute([$username, $email, $passwordHash, $createdAt]);
        return (int) $pdo->lastInsertId();
    } catch (PDOException $e) {
        error_log("Registration error: " . $e->getMessage());
        
        if ($e->getCode() == '23000') {
            throw new Exception("This email is already registered");
        }
        
        throw new Exception("Registration failed. Please try again later.");
    }
}
?>
```

#### CRUD Operations with PDO

```php
<?php
class ProductRepository {
    private PDO $pdo;
    
    public function __construct(PDO $pdo) {
        $this->pdo = $pdo;
    }
    
    // Create
    public function create(array $data): int {
        $stmt = $this->pdo->prepare("
            INSERT INTO products (name, description, price, category_id, created_at)
            VALUES (:name, :description, :price, :category_id, :created_at)
        ");
        
        $stmt->execute([
            'name' => $data['name'],
            'description' => $data['description'],
            'price' => $data['price'],
            'category_id' => $data['category_id'],
            'created_at' => date('Y-m-d H:i:s')
        ]);
        
        return (int) $this->pdo->lastInsertId();
    }
    
    // Read
    public function findById(int $id): ?array {
        $stmt = $this->pdo->prepare("SELECT * FROM products WHERE id = ?");
        $stmt->execute([$id]);
        $product = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $product ?: null;
    }
    
    public function findAll(int $limit = 20, int $offset = 0): array {
        $stmt = $this->pdo->prepare("
            SELECT * FROM products 
            ORDER BY name 
            LIMIT ? OFFSET ?
        ");
        $stmt->execute([$limit, $offset]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    public function findByCategory(int $categoryId): array {
        $stmt = $this->pdo->prepare("
            SELECT * FROM products 
            WHERE category_id = ?
            ORDER BY name
        ");
        $stmt->execute([$categoryId]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    // Update
    public function update(int $id, array $data): bool {
        $query = "UPDATE products SET ";
        $fields = [];
        $values = [];
        
        // Build dynamic update fields
        foreach ($data as $field => $value) {
            if (in_array($field, ['name', 'description', 'price', 'category_id'])) {
                $fields[] = "$field = ?";
                $values[] = $value;
            }
        }
        
        // Add updated_at timestamp
        $fields[] = "updated_at = ?";
        $values[] = date('Y-m-d H:i:s');
        
        // Add product ID
        $values[] = $id;
        
        $query .= implode(", ", $fields);
        $query .= " WHERE id = ?";
        
        $stmt = $this->pdo->prepare($query);
        $stmt->execute($values);
        
        return $stmt->rowCount() > 0;
    }
    
    // Delete
    public function delete(int $id): bool {
        $stmt = $this->pdo->prepare("DELETE FROM products WHERE id = ?");
        $stmt->execute([$id]);
        
        return $stmt->rowCount() > 0;
    }
    
    // Search
    public function search(string $term): array {
        $term = "%$term%";
        $stmt = $this->pdo->prepare("
            SELECT * FROM products 
            WHERE name LIKE ? OR description LIKE ?
            ORDER BY name
        ");
        $stmt->execute([$term, $term]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}

// Usage
try {
    $pdo = new PDO($dsn, $username, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $productRepo = new ProductRepository($pdo);
    
    // Create
    $newProductId = $productRepo->create([
        'name' => 'New Product',
        'description' => 'Product description',
        'price' => 29.99,
        'category_id' => 2
    ]);
    
    // Read
    $product = $productRepo->findById($newProductId);
    
    // Update
    $productRepo->update($newProductId, ['price' => 34.99]);
    
    // Delete
    $productRepo->delete($newProductId);
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
```

#### Pagination with PDO

```php
<?php
function getPaginatedResults(
    PDO $pdo,
    string $table,
    int $page = 1,
    int $perPage = 10,
    string $orderBy = 'id',
    string $direction = 'ASC',
    array $conditions = []
): array {
    // Calculate offset
    $offset = ($page - 1) * $perPage;
    
    // Base query
    $query = "SELECT * FROM $table";
    $countQuery = "SELECT COUNT(*) FROM $table";
    $params = [];
    
    // Add WHERE conditions if provided
    if (!empty($conditions)) {
        $whereClause = [];
        foreach ($conditions as $field => $value) {
            $whereClause[] = "$field = ?";
            $params[] = $value;
        }
        $whereStr = implode(' AND ', $whereClause);
        $query .= " WHERE $whereStr";
        $countQuery .= " WHERE $whereStr";
    }
    
    // Add ORDER BY and LIMIT
    $query .= " ORDER BY $orderBy $direction LIMIT ? OFFSET ?";
    
    // Add pagination parameters
    $params[] = $perPage;
    $params[] = $offset;
    
    try {
        // Get total count
        $countStmt = $pdo->prepare($countQuery);
        $countStmt->execute(array_slice($params, 0, count($params) - 2));
        $totalItems = (int) $countStmt->fetchColumn();
        $totalPages = ceil($totalItems / $perPage);
        
        // Get data for current page
        $stmt = $pdo->prepare($query);
        $stmt->execute($params);
        $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return [
            'items' => $items,
            'pagination' => [
                'total_items' => $totalItems,
                'total_pages' => $totalPages,
                'current_page' => $page,
                'per_page' => $perPage,
                'has_next_page' => $page < $totalPages,
                'has_prev_page' => $page > 1
            ]
        ];
    } catch (PDOException $e) {
        error_log("Pagination error: " . $e->getMessage());
        throw new Exception("Failed to retrieve data");
    }
}

// Usage
try {
    $pdo = new PDO($dsn, $username, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    
    $result = getPaginatedResults(
        $pdo,
        'products',
        page: 2,
        perPage: 15,
        orderBy: 'price',
        direction: 'DESC',
        conditions: ['category_id' => 3]
    );
    
    $products = $result['items'];
    $pagination = $result['pagination'];
    
    // Display pagination info
    echo "Showing page {$pagination['current_page']} of {$pagination['total_pages']}";
    echo " ({$pagination['total_items']} total items)";
    
    // Display products
    foreach ($products as $product) {
        echo "<div>{$product['name']} - \${$product['price']}</div>";
    }
    
    // Display pagination links
    if ($pagination['has_prev_page']) {
        echo "<a href='?page=" . ($pagination['current_page'] - 1) . "'>Previous</a>";
    }
    
    if ($pagination['has_next_page']) {
        echo "<a href='?page=" . ($pagination['current_page'] + 1) . "'>Next</a>";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
```

### Best Practices for PDO

1. **Always use prepared statements**:
    
    - Even for queries without user input
    - Helps prevent SQL injection
2. **Set appropriate error mode**:
    
    - Use exceptions for comprehensive error handling
    - Log errors in production, display details in development
3. **Use transactions for multiple related operations**:
    
    - Ensures data integrity
    - Allows for atomic operations
4. **Close connections explicitly**:
    
    - Set PDO objects to null when finished
    - Especially important in long-running scripts
5. **Use appropriate fetch modes**:
    
    - Choose based on how you'll use the data
    - Set default fetch mode on connection
6. **Separate database logic**:
    
    - Use repository pattern or Data Access Objects
    - Keep SQL queries in one place
7. **Handle connection failures gracefully**:
    
    - Show user-friendly messages
    - Have fallback mechanisms
8. **Use parameter binding correctly**:
    
    - Prefer named parameters for readability
    - Use appropriate parameter types
9. **Set appropriate charset in DSN**:
    
    - Use UTF-8 (utf8mb4 for MySQL) for most applications
10. **Use connection pooling in high-load applications**:
    
    - Consider persistent connections
    - But be aware of their implications

### Related Topics

- Database migrations and schema management
- Query builders and ORMs
- Connection pooling and performance optimization
- Replication and load balancing
- Advanced transaction management
- Working with large datasets efficiently

---

# Security Best Practices

## PHP Security Guide

### Understanding PHP Security

PHP security involves protecting web applications from various attack vectors and vulnerabilities. As one of the most widely used server-side languages for web development, PHP applications are frequent targets for malicious actors seeking to exploit security weaknesses.

**Key Points:**

- Security must be considered at every stage of development
- PHP applications face numerous threats from SQL injection to session hijacking
- Regular updates and security patches are essential for maintaining secure PHP applications
- Following security best practices significantly reduces vulnerability risks

### SQL Injection Prevention

SQL injection occurs when malicious SQL statements are inserted into entry fields for execution. This can lead to unauthorized database access, data theft, or destruction.

#### Prepared Statements

Prepared statements separate SQL logic from data, preventing injection attacks.

```php
// Unsafe method
$query = "SELECT * FROM users WHERE username = '" . $_POST['username'] . "'";

// Safe method using prepared statements
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
$stmt->execute([$_POST['username']]);
$user = $stmt->fetch();
```

#### Parameter Binding

Binding parameters ensures data is properly escaped and treated as values, not code.

```php
// Using named parameters
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = :username AND status = :status");
$stmt->bindParam(':username', $username, PDO::PARAM_STR);
$stmt->bindParam(':status', $status, PDO::PARAM_INT);
$stmt->execute();
```

#### Input Validation

Always validate and sanitize user inputs before processing.

```php
// Validate input type
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    die("Invalid email format");
}

// Sanitize input
$username = htmlspecialchars(trim($_POST['username']));
```

#### Using ORM Libraries

ORM (Object-Relational Mapping) libraries like Doctrine provide built-in protection against SQL injection.

```php
// Example using Doctrine QueryBuilder
$qb = $entityManager->createQueryBuilder();
$query = $qb->select('u')
    ->from('User', 'u')
    ->where('u.username = :username')
    ->setParameter('username', $_POST['username'])
    ->getQuery();
$user = $query->getOneOrNullResult();
```

### Cross-Site Scripting (XSS)

XSS attacks occur when malicious scripts are injected into web pages viewed by users. These scripts can steal cookies, session tokens, or redirect users to malicious sites.

#### Output Escaping

Always escape output data displayed to users.

```php
// Unsafe output
echo "Welcome, " . $_GET['name'];

// Safe output with escaping
echo "Welcome, " . htmlspecialchars($_GET['name'], ENT_QUOTES, 'UTF-8');
```

#### Content Security Policy

Implement Content Security Policy headers to restrict which scripts can execute.

```php
// In PHP
header("Content-Security-Policy: default-src 'self'; script-src 'self' https://trusted-cdn.com;");
```

#### Use Template Engines with Auto-Escaping

Modern template engines like Twig automatically escape output.

```php
// Twig example with auto-escaping
$loader = new \Twig\Loader\FilesystemLoader('/path/to/templates');
$twig = new \Twig\Environment($loader, ['autoescape' => 'html']);
echo $twig->render('index.html', ['name' => $_GET['name']]);
```

#### XSS Protection Functions

PHP offers several functions for sanitizing output:

```php
// Escaping HTML
$safe_html = htmlspecialchars($user_input, ENT_QUOTES, 'UTF-8');

// Removing HTML tags
$stripped_content = strip_tags($user_input);

// URL encoding
$safe_url = urlencode($user_input);
```

### Cross-Site Request Forgery (CSRF)

CSRF attacks trick authenticated users into executing unwanted actions on websites where they're logged in by forging requests.

#### Token Validation

Generate and validate unique tokens for forms and requests.

```php
// Generate CSRF token
function generateCSRFToken() {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

// In form
echo '<input type="hidden" name="csrf_token" value="' . generateCSRFToken() . '">';

// Validate token
function validateCSRFToken($token) {
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

if (!validateCSRFToken($_POST['csrf_token'])) {
    die("CSRF token validation failed");
}
```

#### SameSite Cookies

Set SameSite attribute on cookies to prevent cross-site sending.

```php
// PHP 7.3+
session_set_cookie_params([
    'samesite' => 'Strict',
    'secure' => true,
    'httponly' => true
]);

// Older PHP versions
ini_set('session.cookie_samesite', "Strict");
```

#### Check Referrer and Origin Headers

Verify that requests come from your own domain.

```php
if (!isset($_SERVER['HTTP_REFERER']) || 
    parse_url($_SERVER['HTTP_REFERER'], PHP_URL_HOST) != $_SERVER['HTTP_HOST']) {
    die("Invalid request source");
}
```

### File Upload Security

File uploads present significant security risks if not handled properly.

#### Validate File Types

Check both file extensions and MIME types.

```php
$allowed_types = ['image/jpeg', 'image/png', 'image/gif'];
$allowed_extensions = ['jpg', 'jpeg', 'png', 'gif'];

$file_info = pathinfo($_FILES['upload']['name']);
$file_extension = strtolower($file_info['extension']);

// Check extension
if (!in_array($file_extension, $allowed_extensions)) {
    die("Invalid file extension");
}

// Check MIME type
$file_type = mime_content_type($_FILES['upload']['tmp_name']);
if (!in_array($file_type, $allowed_types)) {
    die("Invalid file type");
}
```

#### Store Files Outside Web Root

Place uploaded files in directories not directly accessible via URL.

```php
$upload_directory = '/var/secure_uploads/';
move_uploaded_file($_FILES['upload']['tmp_name'], $upload_directory . $safe_filename);
```

#### Randomize Filenames

Prevent overwriting and filename guessing.

```php
$new_filename = bin2hex(random_bytes(16)) . '.' . $file_extension;
```

### Session Security

Securing user sessions prevents session hijacking and fixation attacks.

#### Regenerate Session ID

Regenerate session IDs after login and privilege changes.

```php
// After successful authentication
session_regenerate_id(true);
$_SESSION['user_id'] = $user_id;
```

#### Session Timeout

Implement timeouts for inactive sessions.

```php
// Check if session has expired
if (isset($_SESSION['last_activity']) && 
    time() - $_SESSION['last_activity'] > 1800) { // 30 minutes
    session_unset();
    session_destroy();
    header("Location: login.php");
    exit;
}
$_SESSION['last_activity'] = time();
```

#### Secure Session Configuration

Configure PHP for secure session handling.

```php
ini_set('session.use_only_cookies', 1);
ini_set('session.use_strict_mode', 1);
ini_set('session.cookie_httponly', 1);
ini_set('session.cookie_secure', 1);
ini_set('session.cookie_samesite', 'Lax');
```

### Password Hashing and Management

Proper password management is crucial for PHP application security.

#### Using Password Hash API

Never store plain text passwords; use PHP's password_hash function.

```php
// Hashing a password
$password_hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);

// Verifying a password
if (password_verify($input_password, $stored_hash)) {
    // Password is correct
}
```

#### Password Policy Enforcement

Implement and enforce strong password policies.

```php
function validatePassword($password) {
    // At least 8 characters
    if (strlen($password) < 8) {
        return false;
    }
    
    // Check for complexity requirements
    if (!preg_match('/[A-Z]/', $password) || // Uppercase
        !preg_match('/[a-z]/', $password) || // Lowercase
        !preg_match('/[0-9]/', $password) || // Number
        !preg_match('/[^A-Za-z0-9]/', $password)) { // Special char
        return false;
    }
    
    return true;
}
```

### Error Handling and Logging

Proper error handling prevents information leakage while maintaining debugging capabilities.

#### Production vs Development Environment

Different error configurations for different environments.

```php
// Development environment
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Production environment
ini_set('display_errors', 0);
error_reporting(E_ALL);
ini_set('log_errors', 1);
ini_set('error_log', '/path/to/error.log');
```

#### Custom Error Handlers

Implement custom error handlers for controlled error display.

```php
function customErrorHandler($errno, $errstr, $errfile, $errline) {
    // Log the error
    error_log("Error [$errno]: $errstr in $errfile on line $errline");
    
    // Display user-friendly message
    if (!(error_reporting() & $errno)) {
        return false;
    }
    
    if (ENVIRONMENT === 'production') {
        echo "An error occurred. Please try again later.";
    } else {
        echo "<b>Error:</b> [$errno] $errstr<br>";
        echo "Line $errline in $errfile<br>";
    }
    
    return true;
}
set_error_handler("customErrorHandler");
```

### Using Security Libraries and Frameworks

Leverage established PHP security libraries for robust protection.

#### PHP Security Libraries

- **Symfony Security Component**: Provides authentication, authorization, and CSRF protection
- **OWASP CSRF Protector**: Dedicated CSRF protection library
- **Zend Escaper**: Specialized output escaping library
- **DOMPurify**: HTML sanitization library to prevent XSS

```php
// Example using Symfony CSRF protection
use Symfony\Component\Security\Csrf\CsrfTokenManager;
use Symfony\Component\Security\Csrf\TokenGenerator\UriSafeTokenGenerator;

$tokenGenerator = new UriSafeTokenGenerator();
$tokenManager = new CsrfTokenManager($tokenGenerator);

$token = $tokenManager->getToken('form_id');
// Add token to form

// Validating token
if (!$tokenManager->isTokenValid($token)) {
    die("CSRF attack detected");
}
```

### Regular Security Maintenance

Security is not a one-time setup but requires ongoing maintenance.

#### Keep PHP and Dependencies Updated

Regularly update PHP and all dependencies to patch known vulnerabilities.

```php
// Check PHP version
if (version_compare(PHP_VERSION, '7.4.0', '<')) {
    die("Unsupported PHP version. Please upgrade to PHP 7.4 or higher.");
}

// Using Composer to update dependencies
// Command line: composer update
```

#### Security Auditing

Conduct regular code reviews and security audits.

```php
// Example of a simple security check
function auditDatabaseConfig() {
    global $db_config;
    
    $issues = [];
    
    if ($db_config['user'] === 'root') {
        $issues[] = "Using root database user in application";
    }
    
    if (empty($db_config['password']) || $db_config['password'] === 'password') {
        $issues[] = "Weak or empty database password";
    }
    
    return $issues;
}
```

### Advanced Security Measures

For high-security applications, consider implementing additional protective measures.

#### Two-Factor Authentication

Implement 2FA for additional account security.

```php
// Example using PHP-based TOTP (Time-based One-Time Password)
require_once 'vendor/autoload.php';
use OTPHP\TOTP;

// Generate a secret key for the user
$totp = TOTP::create();
$secret = $totp->getSecret();

// Verify provided code
$totp = TOTP::create($stored_secret);
if ($totp->verify($input_code)) {
    // Code is valid
}
```

#### Rate Limiting

Implement rate limiting to prevent brute force attacks.

```php
function checkRateLimit($user_id, $action, $max_attempts, $time_window) {
    global $db;
    
    // Clean old attempts
    $stmt = $db->prepare("DELETE FROM rate_limits WHERE user_id = ? AND action = ? AND attempt_time < ?");
    $stmt->execute([$user_id, $action, time() - $time_window]);
    
    // Count recent attempts
    $stmt = $db->prepare("SELECT COUNT(*) FROM rate_limits WHERE user_id = ? AND action = ?");
    $stmt->execute([$user_id, $action]);
    $attempts = $stmt->fetchColumn();
    
    if ($attempts >= $max_attempts) {
        return false; // Rate limit exceeded
    }
    
    // Record this attempt
    $stmt = $db->prepare("INSERT INTO rate_limits (user_id, action, attempt_time) VALUES (?, ?, ?)");
    $stmt->execute([$user_id, $action, time()]);
    
    return true; // Within rate limit
}

// Usage
if (!checkRateLimit($user_id, 'login', 5, 300)) { // 5 attempts in 5 minutes
    die("Too many login attempts. Please try again later.");
}
```

#### HTTP Security Headers

Implement security headers to enhance protection.

```php
// Set security headers
header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
header("X-Content-Type-Options: nosniff");
header("X-Frame-Options: DENY");
header("X-XSS-Protection: 1; mode=block");
header("Referrer-Policy: strict-origin-when-cross-origin");
header("Permissions-Policy: geolocation=(), microphone=()");
```

### Security for PHP Frameworks

Popular PHP frameworks offer built-in security features that should be understood and properly implemented.

#### Laravel Security

Laravel includes several security features that should be properly utilized.

```php
// CSRF protection in Laravel
<form method="POST" action="/profile">
    @csrf
    <!-- Form fields -->
</form>

// XSS protection with {{ }} syntax (auto-escapes)
<div>{{ $userInput }}</div>

// Raw output (use sparingly)
<div>{!! $trustedHtml !!}</div>
```

#### Symfony Security

Leverage Symfony's security components for authentication and authorization.

```php
// Example security.yaml configuration
security:
    encoders:
        App\Entity\User:
            algorithm: auto
    
    providers:
        app_user_provider:
            entity:
                class: App\Entity\User
                property: email
    
    firewalls:
        main:
            anonymous: true
            guard:
                authenticators:
                    - App\Security\LoginFormAuthenticator
            logout:
                path: app_logout
```

#### CodeIgniter Security

CodeIgniter offers various security helpers and libraries.

```php
// CSRF protection in CodeIgniter 4
<form method="post" action="/form">
    <?= csrf_field() ?>
    <!-- Form fields -->
</form>

// Using the Security class
$security = \Config\Services::security();
$sanitized = $security->sanitizeFilename($filename);
```

**Conclusion:** PHP security requires implementing multiple layers of protection against various attack vectors. By following the practices outlined in this guide—from preventing SQL injection to securing file uploads and properly handling sessions—developers can significantly reduce the risk of security breaches. Remember that security is an ongoing process that requires regular updates, audits, and awareness of emerging threats. Implementing these security measures should be considered a fundamental part of PHP development, not an optional add-on.

Related topics you might want to explore:

- PHP Security Scanners and Static Analysis Tools
- Server Hardening for PHP Applications
- OAuth and JWT Implementation in PHP
- API Security Best Practices for PHP

---

## PHP Input Validation and Sanitization

### Understanding Input Validation vs. Sanitization

Input validation and sanitization are two distinct but complementary security practices in PHP development. Together, they form a critical defense against various attack vectors.

**Key Points:**

- Validation determines if data meets expected format and constraints
- Sanitization modifies input to make it safe for intended use
- Always validate first, then sanitize as needed
- Different contexts require different sanitization approaches
- Defense in depth requires both practices working together

### The Importance of Input Handling

Proper input handling prevents numerous vulnerabilities including SQL injection, XSS attacks, command injection, and path traversal attacks.

```php
// Vulnerable code without validation or sanitization
$username = $_POST['username'];
$query = "SELECT * FROM users WHERE username = '$username'";
// Potential SQL injection!

// Displaying unvalidated input
echo "Welcome, " . $_GET['name'];
// Potential XSS vulnerability!
```

### Types of Validation

#### Type Validation

Ensures data is of the expected type (string, integer, etc.).

```php
// Validate integer
if (!filter_var($_POST['age'], FILTER_VALIDATE_INT)) {
    die("Age must be an integer");
}

// Validate boolean
$newsletter = filter_var($_POST['subscribe'], FILTER_VALIDATE_BOOLEAN);

// Validate float
if (!filter_var($_POST['price'], FILTER_VALIDATE_FLOAT)) {
    die("Price must be a number");
}
```

#### Format Validation

Confirms data adheres to specific formats like email, URL, or IP address.

```php
// Validate email
if (!filter_var($_POST['email'], FILTER_VALIDATE_EMAIL)) {
    die("Invalid email format");
}

// Validate URL
if (!filter_var($_POST['website'], FILTER_VALIDATE_URL)) {
    die("Invalid URL format");
}

// Validate IP address
if (!filter_var($_POST['ip_address'], FILTER_VALIDATE_IP)) {
    die("Invalid IP address");
}

// Validate MAC address
if (!filter_var($_POST['mac'], FILTER_VALIDATE_MAC)) {
    die("Invalid MAC address");
}
```

#### Range Validation

Verifies data falls within acceptable numerical or length ranges.

```php
// Validate integer in range
$options = [
    'options' => [
        'min_range' => 18,
        'max_range' => 120
    ]
];
if (!filter_var($_POST['age'], FILTER_VALIDATE_INT, $options)) {
    die("Age must be between 18 and 120");
}

// Validate string length
$name = $_POST['name'];
if (strlen($name) < 2 || strlen($name) > 50) {
    die("Name must be between 2 and 50 characters");
}
```

#### Pattern Validation

Uses regular expressions to validate against complex patterns.

```php
// Validate using regex
if (!preg_match('/^[a-zA-Z0-9_]{5,20}$/', $_POST['username'])) {
    die("Username must be 5-20 characters and contain only letters, numbers, and underscores");
}

// Validate password strength
$password = $_POST['password'];
if (!preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/', $password)) {
    die("Password must be at least 8 characters and include uppercase, lowercase, number and special character");
}

// Validate phone number
if (!preg_match('/^\+?[1-9]\d{1,14}$/', $_POST['phone'])) {
    die("Invalid phone number format");
}
```

### PHP Filter Functions

PHP provides a powerful set of filter functions for validation and sanitization.

#### Filter_var Function

The most versatile filter function that validates and sanitizes various data types.

```php
// Basic usage
$email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
if ($email === false) {
    die("Invalid email address");
}

// With options
$age = filter_var($_POST['age'], FILTER_VALIDATE_INT, [
    'options' => [
        'min_range' => 18,
        'max_range' => 120,
        'default' => 18
    ]
]);

// Combining flags
$url = filter_var($_POST['url'], FILTER_VALIDATE_URL, FILTER_FLAG_PATH_REQUIRED | FILTER_FLAG_QUERY_REQUIRED);
```

#### Filter_input Function

Specifically designed for validating input from superglobals like GET, POST, and COOKIE.

```php
// Validate GET parameter
$page = filter_input(INPUT_GET, 'page', FILTER_VALIDATE_INT, [
    'options' => ['min_range' => 1],
    'flags' => FILTER_NULL_ON_FAILURE
]);

// Validate POST parameter
$email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);

// Validate COOKIE parameter
$user_id = filter_input(INPUT_COOKIE, 'user_id', FILTER_VALIDATE_INT);
```

#### Filter_input_array Function

Process multiple inputs simultaneously with different filters.

```php
// Define filters for multiple inputs
$filters = [
    'name' => [
        'filter' => FILTER_SANITIZE_STRING,
        'flags' => FILTER_FLAG_NO_ENCODE_QUOTES
    ],
    'email' => FILTER_VALIDATE_EMAIL,
    'age' => [
        'filter' => FILTER_VALIDATE_INT,
        'options' => ['min_range' => 1, 'max_range' => 120]
    ],
    'website' => FILTER_VALIDATE_URL
];

// Apply all filters at once
$inputs = filter_input_array(INPUT_POST, $filters);

// Check results
if ($inputs['email'] === false || $inputs['age'] === false) {
    die("Validation failed");
}
```

#### Filter_var_array Function

Similar to filter_input_array but works with arrays of values instead of superglobals.

```php
// Raw data array
$data = [
    'name' => $_POST['name'] ?? '',
    'email' => $_POST['email'] ?? '',
    'comments' => $_POST['comments'] ?? ''
];

// Define filters
$filters = [
    'name' => FILTER_SANITIZE_STRING,
    'email' => FILTER_VALIDATE_EMAIL,
    'comments' => [
        'filter' => FILTER_SANITIZE_STRING,
        'flags' => FILTER_FLAG_NO_ENCODE_QUOTES
    ]
];

// Apply filters
$filtered = filter_var_array($data, $filters);
```

### PHP Validation Filter Types

PHP provides numerous predefined validation filters.

#### Common Validation Filters

```php
// Email validation
$valid_email = filter_var($email, FILTER_VALIDATE_EMAIL);

// URL validation
$valid_url = filter_var($url, FILTER_VALIDATE_URL);

// IP address validation
$valid_ip = filter_var($ip, FILTER_VALIDATE_IP);
$valid_ipv4 = filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4);
$valid_ipv6 = filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV6);

// Integer validation
$valid_int = filter_var($int, FILTER_VALIDATE_INT);

// Float validation
$valid_float = filter_var($float, FILTER_VALIDATE_FLOAT);

// Boolean validation
$valid_bool = filter_var($bool, FILTER_VALIDATE_BOOLEAN);

// Domain validation
$valid_domain = filter_var($domain, FILTER_VALIDATE_DOMAIN);

// MAC address validation
$valid_mac = filter_var($mac, FILTER_VALIDATE_MAC);
```

#### Validation Filter Flags

Flags modify validation filter behavior.

```php
// URL validation with required path and query
$valid_url = filter_var($url, FILTER_VALIDATE_URL, 
    FILTER_FLAG_PATH_REQUIRED | FILTER_FLAG_QUERY_REQUIRED);

// IP validation excluding private ranges
$valid_public_ip = filter_var($ip, FILTER_VALIDATE_IP, 
    FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE);

// Email validation with host check
$valid_email = filter_var($email, FILTER_VALIDATE_EMAIL, 
    FILTER_FLAG_EMAIL_UNICODE);
```

### Input Sanitization

After validation confirms data format is correct, sanitization makes it safe for use in different contexts.

#### PHP Sanitization Filter Types

PHP provides several sanitization filters for different data types.

```php
// String sanitization (deprecated in PHP 8.1, see alternatives below)
$clean_string = filter_var($string, FILTER_SANITIZE_STRING);

// Alternative string sanitization approach for PHP 8.1+
$clean_string = htmlspecialchars(strip_tags($string));

// Email sanitization
$clean_email = filter_var($email, FILTER_SANITIZE_EMAIL);

// URL sanitization
$clean_url = filter_var($url, FILTER_SANITIZE_URL);

// Number sanitization
$clean_number = filter_var($number, FILTER_SANITIZE_NUMBER_INT);
$clean_float = filter_var($float, FILTER_SANITIZE_NUMBER_FLOAT, 
    FILTER_FLAG_ALLOW_FRACTION | FILTER_FLAG_ALLOW_THOUSAND);

// Encode URL components
$encoded_url = filter_var($url, FILTER_SANITIZE_ENCODED);

// Remove all HTML tags
$clean_text = filter_var($text, FILTER_SANITIZE_FULL_SPECIAL_CHARS);
```

#### Context-Specific Sanitization

Different contexts require different sanitization approaches.

```php
// Database context (using PDO prepared statements)
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
$stmt->execute([$username]);

// HTML context
$safe_html_output = htmlspecialchars($user_input, ENT_QUOTES, 'UTF-8');

// URL context
$safe_url_param = urlencode($param);

// Shell command context
$safe_command = escapeshellarg($user_input);

// JavaScript context
$safe_js = json_encode($user_input);

// CSS context
$safe_css = preg_replace('/[^a-zA-Z0-9#]/', '', $color);
```

### Escaping Output

Escaping converts special characters to their HTML entity equivalents, preventing them from being interpreted as code.

#### HTML Context Escaping

```php
// Basic HTML escaping
echo htmlspecialchars($user_input, ENT_QUOTES, 'UTF-8');

// With more control
echo htmlentities($user_input, ENT_QUOTES | ENT_HTML5, 'UTF-8');

// Escaping attributes
$attr_value = htmlspecialchars($user_input, ENT_QUOTES, 'UTF-8');
echo "<div title=\"$attr_value\">Content</div>";
```

#### JavaScript Context Escaping

```php
// Escaping data for use in JavaScript
$js_safe = json_encode($user_input);
echo "<script>var userInput = $js_safe;</script>";

// Alternative approach
echo "<script>var userInput = '" . 
     preg_replace('/[\/\'"()]/', '\\\\$0', $user_input) . 
     "';</script>";
```

#### URL Context Escaping

```php
// Encoding URL parameters
$encoded_param = urlencode($user_input);
echo "<a href=\"profile.php?name=$encoded_param\">Profile</a>";

// Encoding path segments
$encoded_path = rawurlencode($user_input);
echo "<a href=\"files/$encoded_path\">Download</a>";
```

#### CSS Context Escaping

```php
// Escaping values for CSS
$css_safe = preg_replace('/[^a-zA-Z0-9#]/', '', $color);
echo "<div style=\"color: $css_safe;\">Text</div>";
```

#### XML Context Escaping

```php
// Escaping for XML
$xml_safe = htmlspecialchars($user_input, ENT_QUOTES | ENT_XML1, 'UTF-8');
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root>$xml_safe</root>";
```

### Implementing Validation with PHP Libraries

#### Respect\Validation

A versatile validation library with numerous validators.

```php
// Using Respect\Validation
use Respect\Validation\Validator as v;

// Simple validation
if (v::email()->validate($email)) {
    // Valid email
}

// Complex validation
$usernameValidator = v::alnum('_')
    ->noWhitespace()
    ->length(5, 20);

if (!$usernameValidator->validate($username)) {
    $errors[] = 'Invalid username format';
}

// Chaining validation rules
$passwordValidator = v::stringType()
    ->length(8, null)
    ->containsLetter()
    ->containsDigit()
    ->containsSpecialChar();

if (!$passwordValidator->validate($password)) {
    $errors[] = 'Password does not meet security requirements';
}
```

#### Symfony Validator Component

Powerful validation framework with annotations and constraints.

```php
// Using Symfony Validator
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\Validator\Validation;

// Define validation constraints
$constraints = new Assert\Collection([
    'name' => [
        new Assert\NotBlank(),
        new Assert\Length(['min' => 2, 'max' => 50])
    ],
    'email' => [
        new Assert\NotBlank(),
        new Assert\Email()
    ],
    'age' => [
        new Assert\Type('integer'),
        new Assert\Range(['min' => 18, 'max' => 120])
    ]
]);

// Validate data
$validator = Validation::createValidator();
$violations = $validator->validate($_POST, $constraints);

if (count($violations) > 0) {
    foreach ($violations as $violation) {
        $errors[] = $violation->getMessage();
    }
}
```

#### Laravel Validation

Laravel's elegant validation system.

```php
// Using Laravel validation
$validator = Validator::make($request->all(), [
    'name' => 'required|string|max:255',
    'email' => 'required|email|unique:users',
    'password' => 'required|string|min:8|confirmed',
    'age' => 'required|integer|between:18,120',
    'website' => 'nullable|url',
    'avatar' => 'nullable|image|max:2048',
]);

if ($validator->fails()) {
    return redirect()->back()
        ->withErrors($validator)
        ->withInput();
}
```

### Advanced Validation Techniques

#### Custom Validation Rules

Creating your own validation rules for specific needs.

```php
// Custom validation function
function validateUsername($username) {
    // Check length
    if (strlen($username) < 5 || strlen($username) > 20) {
        return false;
    }
    
    // Check characters
    if (!preg_match('/^[a-zA-Z0-9_]+$/', $username)) {
        return false;
    }
    
    // Check reserved names
    $reserved = ['admin', 'root', 'system'];
    if (in_array(strtolower($username), $reserved)) {
        return false;
    }
    
    return true;
}

// Usage
if (!validateUsername($_POST['username'])) {
    die("Invalid username");
}
```

#### Server-Side and Client-Side Validation

Implementing both for better user experience and security.

```php
// Server-side validation (PHP)
if (!filter_var($_POST['email'], FILTER_VALIDATE_EMAIL)) {
    $errors[] = "Invalid email format";
}

// Client-side validation (HTML5)
echo '<input type="email" name="email" required pattern="[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$">';

// Client-side validation (JavaScript)
echo '<script>
function validateForm() {
    const email = document.forms["myForm"]["email"].value;
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    
    if (!emailRegex.test(email)) {
        alert("Please enter a valid email address");
        return false;
    }
    return true;
}
</script>';
```

#### Cross-Field Validation

Validating data based on multiple fields.

```php
// Password and confirmation validation
if ($_POST['password'] !== $_POST['password_confirm']) {
    die("Passwords do not match");
}

// Date range validation
$start_date = strtotime($_POST['start_date']);
$end_date = strtotime($_POST['end_date']);

if ($start_date > $end_date) {
    die("End date must be after start date");
}
```

### Common Output Escaping Functions

PHP provides several built-in functions for escaping output in different contexts.

#### htmlspecialchars

The most commonly used function for escaping HTML output.

```php
// Basic usage
echo htmlspecialchars($user_input);

// With all options
echo htmlspecialchars(
    $user_input,
    ENT_QUOTES | ENT_HTML5, // Convert both single and double quotes
    'UTF-8',                // Character encoding
    false                   // Don't double-encode existing entities
);

// Commonly used constants
// ENT_COMPAT: Converts double quotes, leaves single quotes alone
// ENT_QUOTES: Converts both double and single quotes
// ENT_NOQUOTES: Leaves both double and single quotes unconverted
// ENT_HTML5: Handle code as HTML 5
```

#### htmlentities

Converts all applicable characters to HTML entities.

```php
// Basic usage
echo htmlentities($user_input);

// With options
echo htmlentities(
    $user_input,
    ENT_QUOTES | ENT_HTML5,
    'UTF-8',
    false
);
```

#### strip_tags

Removes HTML and PHP tags from a string.

```php
// Remove all tags
$clean_text = strip_tags($user_input);

// Allow specific tags
$allowed_html = strip_tags($user_input, '<p><br><strong><em><ul><li>');
```

#### URL Functions

Functions for encoding URL components.

```php
// Encode URL parameters
$safe_param = urlencode($user_input);
echo "search.php?q=$safe_param";

// Encode URL path segments
$safe_path = rawurlencode($user_input);
echo "files/$safe_path";

// Decode URL
$decoded = urldecode($encoded_input);
```

#### JSON Encoding

Safe way to embed data in JavaScript.

```php
// Basic usage
$js_safe = json_encode($user_input);
echo "<script>var data = $js_safe;</script>";

// With options
$js_safe = json_encode(
    $user_input,
    JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT
);
```

### Best Practices for Validation and Sanitization

#### Whitelist vs. Blacklist Approach

Always prefer whitelist (allowlist) over blacklist (blocklist) validation.

```php
// Bad approach (blacklist)
$input = str_replace(['<script>', '</script>'], '', $_POST['input']);

// Good approach (whitelist)
if (!preg_match('/^[a-zA-Z0-9\s]+$/', $_POST['input'])) {
    die("Invalid input");
}
```

#### Validation at Every Layer

Implement validation at multiple layers of your application.

```php
// Form layer validation
if (empty($_POST['email']) || !filter_var($_POST['email'], FILTER_VALIDATE_EMAIL)) {
    $errors[] = "Invalid email";
}

// Business logic layer validation
function registerUser($email) {
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new InvalidArgumentException("Invalid email format");
    }
    // Continue registration process
}

// Database layer validation (MySQL example)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    CONSTRAINT valid_email CHECK (email REGEXP '^[^@]+@[^@]+\.[^@]+$')
);
```

#### Always Validate Before Processing

Never trust input data before validation.

```php
// Bad approach
$user = getUserByEmail($_POST['email']);
sendPasswordReset($user->id);

// Good approach
if (filter_var($_POST['email'], FILTER_VALIDATE_EMAIL)) {
    $user = getUserByEmail($_POST['email']);
    if ($user) {
        sendPasswordReset($user->id);
    }
} else {
    die("Invalid email format");
}
```

#### Context-Aware Escaping

Always escape output based on its specific context.

```php
// HTML context
echo htmlspecialchars($data, ENT_QUOTES, 'UTF-8');

// JavaScript context
echo json_encode($data);

// CSS context
echo preg_replace('/[^a-zA-Z0-9#]/', '', $color);

// URL context
echo urlencode($param);

// SQL context
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
$stmt->execute([$username]);

// Shell context
$command = "ls " . escapeshellarg($directory);
```

**Conclusion:** Proper input validation and output escaping are fundamental to PHP security. By implementing comprehensive validation to ensure data meets expected formats and constraints, and then applying context-appropriate sanitization and escaping techniques, developers can protect applications from a wide range of injection attacks. Always validate first, then sanitize as needed, and finally escape output based on the specific context in which it will be used. Remember that security is best implemented in layers, and input handling is a critical component of that defense strategy.

Related topics you might want to explore:

- Content Security Policy (CSP) Implementation
- Advanced Regular Expressions for Validation
- Data Type Validation in ORM Systems
- Custom Validation Libraries Development
- Output Encoding vs. Output Escaping

---

## Authentication and Authorization in PHP

### Understanding Authentication vs Authorization

Authentication and authorization are critical security concepts in web applications. Authentication verifies user identity ("who you are"), while authorization determines access rights ("what you're allowed to do").

**Key Points**

- Authentication occurs before authorization
- Both components are essential for a secure application
- PHP offers native functions and libraries for both processes
- Implementation requires careful planning to avoid security vulnerabilities

### Secure Password Hashing with password_hash()

PHP's `password_hash()` function provides a secure way to hash passwords, replacing older insecure methods like MD5 or SHA-1.

#### Basic Implementation

```php
// Creating a password hash
$password = "user_password";
$hash = password_hash($password, PASSWORD_DEFAULT);

// Verifying a password against hash
if (password_verify($password, $hash)) {
    // Password is correct
} else {
    // Password is incorrect
}
```

#### Available Hashing Algorithms

```php
// Bcrypt - the default algorithm
$bcrypt_hash = password_hash($password, PASSWORD_BCRYPT);

// Argon2i - better for server environments with sufficient memory
$argon2i_hash = password_hash($password, PASSWORD_ARGON2I);

// Argon2id - combines Argon2i and Argon2d (recommended when available)
$argon2id_hash = password_hash($password, PASSWORD_ARGON2ID);
```

#### Customizing Hash Options

```php
// Bcrypt with custom cost
$bcrypt_options = ['cost' => 12]; // Default is 10
$custom_bcrypt = password_hash($password, PASSWORD_BCRYPT, $bcrypt_options);

// Argon2id with custom parameters
$argon_options = [
    'memory_cost' => 2048,    // Memory cost in KiB (default: 65536)
    'time_cost'   => 4,       // Number of iterations (default: 4)
    'threads'     => 3        // Degree of parallelism (default: 1)
];
$custom_argon = password_hash($password, PASSWORD_ARGON2ID, $argon_options);
```

**Key Points**

- Always use `password_hash()` rather than creating custom hashing mechanisms
- The `PASSWORD_DEFAULT` algorithm automatically uses the strongest available algorithm
- The hashing algorithm and parameters are stored within the hash itself
- Never truncate hash fields in your database (use VARCHAR(255) at minimum)

### Password Storage Best Practices

#### Database Schema Example

```php
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
);
```

#### Registration Process

```php
function registerUser($username, $email, $password) {
    global $pdo;
    
    // Check if username/email already exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE username = ? OR email = ?");
    $stmt->execute([$username, $email]);
    if ($stmt->rowCount() > 0) {
        return false; // User already exists
    }
    
    // Hash password and create account
    $password_hash = password_hash($password, PASSWORD_DEFAULT);
    
    $stmt = $pdo->prepare("INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)");
    return $stmt->execute([$username, $email, $password_hash]);
}
```

#### Login Process

```php
function authenticateUser($username, $password) {
    global $pdo;
    
    $stmt = $pdo->prepare("SELECT id, password_hash FROM users WHERE username = ?");
    $stmt->execute([$username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user && password_verify($password, $user['password_hash'])) {
        // Check if rehash is needed (algorithm updated)
        if (password_needs_rehash($user['password_hash'], PASSWORD_DEFAULT)) {
            $new_hash = password_hash($password, PASSWORD_DEFAULT);
            $update = $pdo->prepare("UPDATE users SET password_hash = ? WHERE id = ?");
            $update->execute([$new_hash, $user['id']]);
        }
        
        return $user['id']; // Authentication successful
    }
    
    return false; // Authentication failed
}
```

### Role-Based Access Control (RBAC)

RBAC is an approach to restricting system access where permissions are assigned to roles, and users are assigned to roles.

#### Database Structure for RBAC

```php
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE role_permissions (
    role_id INT,
    permission_id INT,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);

CREATE TABLE user_roles (
    user_id INT,
    role_id INT,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);
```

#### Implementing RBAC Functions

```php
// Check if user has specific permission
function userHasPermission($userId, $permissionName) {
    global $pdo;
    
    $query = "
    SELECT COUNT(*) FROM permissions p
    JOIN role_permissions rp ON p.id = rp.permission_id
    JOIN user_roles ur ON rp.role_id = ur.role_id
    WHERE ur.user_id = ? AND p.name = ?
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute([$userId, $permissionName]);
    
    return $stmt->fetchColumn() > 0;
}

// Check if user has specific role
function userHasRole($userId, $roleName) {
    global $pdo;
    
    $query = "
    SELECT COUNT(*) FROM roles r
    JOIN user_roles ur ON r.id = ur.role_id
    WHERE ur.user_id = ? AND r.name = ?
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute([$userId, $roleName]);
    
    return $stmt->fetchColumn() > 0;
}

// Assign role to user
function assignRoleToUser($userId, $roleId) {
    global $pdo;
    
    $stmt = $pdo->prepare("INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)");
    return $stmt->execute([$userId, $roleId]);
}
```

#### Implementing a Simple Authorization Middleware

```php
function requirePermission($permissionName) {
    session_start();
    
    if (!isset($_SESSION['user_id'])) {
        // User not logged in
        header('Location: /login.php');
        exit;
    }
    
    if (!userHasPermission($_SESSION['user_id'], $permissionName)) {
        // User doesn't have required permission
        header('HTTP/1.1 403 Forbidden');
        include('403.php');
        exit;
    }
}

// Example usage in a script
// At the top of admin_panel.php
requirePermission('access_admin_panel');
// Rest of the script follows...
```

### Session Management and Security

#### Secure Session Configuration

```php
// Place this at the beginning of your application
function secureSessionStart() {
    ini_set('session.cookie_httponly', 1);
    ini_set('session.cookie_secure', 1); // Only on HTTPS
    ini_set('session.use_only_cookies', 1);
    ini_set('session.cookie_samesite', 'Lax');
    
    // Regenerate session ID to prevent fixation attacks
    session_start();
    if (!isset($_SESSION['created'])) {
        session_regenerate_id(true);
        $_SESSION['created'] = time();
    } else if (time() - $_SESSION['created'] > 1800) {
        // Regenerate session ID every 30 minutes
        session_regenerate_id(true);
        $_SESSION['created'] = time();
    }
}
```

#### Implementing Remember Me Functionality

```php
function createRememberMeToken($userId) {
    global $pdo;
    
    $selector = bin2hex(random_bytes(16));
    $validator = bin2hex(random_bytes(32));
    $token = $selector . ':' . $validator;
    
    $hashedValidator = password_hash($validator, PASSWORD_DEFAULT);
    $expiry = date('Y-m-d H:i:s', time() + 2592000); // 30 days
    
    $stmt = $pdo->prepare("INSERT INTO auth_tokens (user_id, selector, hashed_validator, expiry) VALUES (?, ?, ?, ?)");
    $stmt->execute([$userId, $selector, $hashedValidator, $expiry]);
    
    setcookie('remember_me', $token, time() + 2592000, '/', '', true, true);
    
    return true;
}

function validateRememberMeToken() {
    global $pdo;
    
    if (!isset($_COOKIE['remember_me'])) {
        return false;
    }
    
    list($selector, $validator) = explode(':', $_COOKIE['remember_me'], 2);
    
    $stmt = $pdo->prepare("SELECT user_id, hashed_validator, expiry FROM auth_tokens WHERE selector = ?");
    $stmt->execute([$selector]);
    $token = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$token || strtotime($token['expiry']) < time()) {
        return false;
    }
    
    if (password_verify($validator, $token['hashed_validator'])) {
        // Log user in
        $_SESSION['user_id'] = $token['user_id'];
        
        // Regenerate remember me token for security
        createRememberMeToken($token['user_id']);
        
        return true;
    }
    
    return false;
}
```

### Two-Factor Authentication (2FA)

#### Implementing TOTP (Time-Based One-Time Password)

```php
// Using the paragonie/constant_time_encoding and spomky-labs/otphp packages
// composer require paragonie/constant_time_encoding spomky-labs/otphp

use OTPHP\TOTP;

// Generate a new secret key for a user
function generateTotpSecret($userId) {
    global $pdo;
    
    $totp = TOTP::create();
    $secret = $totp->getSecret();
    
    $stmt = $pdo->prepare("UPDATE users SET totp_secret = ? WHERE id = ?");
    $stmt->execute([$secret, $userId]);
    
    return $secret;
}

// Verify a TOTP code
function verifyTotpCode($userId, $code) {
    global $pdo;
    
    $stmt = $pdo->prepare("SELECT totp_secret FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$result || empty($result['totp_secret'])) {
        return false;
    }
    
    $totp = TOTP::create($result['totp_secret']);
    return $totp->verify($code);
}
```

### OAuth and Social Login Integration

#### Facebook Login Implementation Example

```php
// Using the league/oauth2-facebook package
// composer require league/oauth2-facebook

use League\OAuth2\Client\Provider\Facebook;

function initFacebookOAuth() {
    return new Facebook([
        'clientId'          => 'your-app-id',
        'clientSecret'      => 'your-app-secret',
        'redirectUri'       => 'https://your-domain.com/facebook-callback.php',
        'graphApiVersion'   => 'v12.0',
    ]);
}

// Step 1: Redirect to Facebook
function redirectToFacebookLogin() {
    $provider = initFacebookOAuth();
    
    $authUrl = $provider->getAuthorizationUrl([
        'scope' => ['email'],
    ]);
    
    // Store state for CSRF protection
    $_SESSION['oauth2state'] = $provider->getState();
    
    header('Location: ' . $authUrl);
    exit;
}

// Step 2: Handle the callback
function handleFacebookCallback() {
    global $pdo;
    $provider = initFacebookOAuth();
    
    if (!isset($_GET['state']) || $_GET['state'] !== $_SESSION['oauth2state']) {
        unset($_SESSION['oauth2state']);
        throw new Exception('Invalid state parameter');
    }
    
    $token = $provider->getAccessToken('authorization_code', [
        'code' => $_GET['code']
    ]);
    
    try {
        // Get user details
        $user = $provider->getResourceOwner($token);
        
        $fbUserId = $user->getId();
        $email = $user->getEmail();
        $name = $user->getName();
        
        // Check if user exists
        $stmt = $pdo->prepare("SELECT id FROM users WHERE facebook_id = ? OR email = ?");
        $stmt->execute([$fbUserId, $email]);
        $existingUser = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($existingUser) {
            // Update existing user
            $stmt = $pdo->prepare("UPDATE users SET facebook_id = ? WHERE id = ?");
            $stmt->execute([$fbUserId, $existingUser['id']]);
            $userId = $existingUser['id'];
        } else {
            // Create new user
            $stmt = $pdo->prepare("INSERT INTO users (username, email, facebook_id) VALUES (?, ?, ?)");
            $stmt->execute([$name, $email, $fbUserId]);
            $userId = $pdo->lastInsertId();
        }
        
        // Log the user in
        $_SESSION['user_id'] = $userId;
        
        return true;
    } catch (\Exception $e) {
        return false;
    }
}
```

### JWT (JSON Web Tokens) for API Authentication

```php
// Using firebase/php-jwt package
// composer require firebase/php-jwt

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JWTAuth {
    private $secretKey;
    private $algorithm;
    private $issuer;
    private $tokenLifetime;
    
    public function __construct() {
        $this->secretKey = getenv('JWT_SECRET_KEY');
        $this->algorithm = 'HS256';
        $this->issuer = 'your-application-name';
        $this->tokenLifetime = 3600; // 1 hour
    }
    
    public function createToken($userId, $additionalData = []) {
        $issuedAt = time();
        $expiration = $issuedAt + $this->tokenLifetime;
        
        $payload = [
            'iss' => $this->issuer,
            'iat' => $issuedAt,
            'exp' => $expiration,
            'sub' => $userId,
            'data' => $additionalData
        ];
        
        return JWT::encode($payload, $this->secretKey, $this->algorithm);
    }
    
    public function validateToken($token) {
        try {
            $decoded = JWT::decode($token, new Key($this->secretKey, $this->algorithm));
            return $decoded;
        } catch (\Exception $e) {
            return false;
        }
    }
    
    public function getBearerToken() {
        $headers = apache_request_headers();
        if (!isset($headers['Authorization'])) {
            return null;
        }
        
        if (preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $matches)) {
            return $matches[1];
        }
        
        return null;
    }
}

// Example usage in API endpoint
function apiAuthMiddleware() {
    $jwtAuth = new JWTAuth();
    $token = $jwtAuth->getBearerToken();
    
    if (!$token) {
        header('HTTP/1.0 401 Unauthorized');
        echo json_encode(['error' => 'Authentication required']);
        exit;
    }
    
    $decoded = $jwtAuth->validateToken($token);
    if (!$decoded) {
        header('HTTP/1.0 401 Unauthorized');
        echo json_encode(['error' => 'Invalid token']);
        exit;
    }
    
    return $decoded->sub; // User ID
}
```

### Complete Authentication System Example

```php
class Auth {
    private $pdo;
    
    public function __construct(PDO $pdo) {
        $this->pdo = $pdo;
    }
    
    public function register($username, $email, $password) {
        // Validate input
        if (empty($username) || empty($email) || empty($password)) {
            return ['success' => false, 'message' => 'All fields are required'];
        }
        
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return ['success' => false, 'message' => 'Invalid email format'];
        }
        
        if (strlen($password) < 8) {
            return ['success' => false, 'message' => 'Password must be at least 8 characters'];
        }
        
        // Check if username or email already exists
        $stmt = $this->pdo->prepare("SELECT id FROM users WHERE username = ? OR email = ?");
        $stmt->execute([$username, $email]);
        if ($stmt->rowCount() > 0) {
            return ['success' => false, 'message' => 'Username or email already exists'];
        }
        
        // Hash password and create account
        $password_hash = password_hash($password, PASSWORD_DEFAULT);
        
        try {
            $stmt = $this->pdo->prepare("INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)");
            $stmt->execute([$username, $email, $password_hash]);
            
            // Assign default role
            $this->assignRole($this->pdo->lastInsertId(), 'user');
            
            return ['success' => true, 'message' => 'Registration successful'];
        } catch (PDOException $e) {
            return ['success' => false, 'message' => 'Database error: ' . $e->getMessage()];
        }
    }
    
    public function login($username, $password, $remember = false) {
        if (empty($username) || empty($password)) {
            return ['success' => false, 'message' => 'Username and password are required'];
        }
        
        try {
            $stmt = $this->pdo->prepare("SELECT id, username, password_hash FROM users WHERE username = ? OR email = ?");
            $stmt->execute([$username, $username]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user || !password_verify($password, $user['password_hash'])) {
                return ['success' => false, 'message' => 'Invalid username or password'];
            }
            
            // Start session
            session_start();
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['username'] = $user['username'];
            
            // Update last login timestamp
            $updateStmt = $this->pdo->prepare("UPDATE users SET last_login = NOW() WHERE id = ?");
            $updateStmt->execute([$user['id']]);
            
            // Check if rehash is needed
            if (password_needs_rehash($user['password_hash'], PASSWORD_DEFAULT)) {
                $new_hash = password_hash($password, PASSWORD_DEFAULT);
                $updateHashStmt = $this->pdo->prepare("UPDATE users SET password_hash = ? WHERE id = ?");
                $updateHashStmt->execute([$new_hash, $user['id']]);
            }
            
            // Remember me functionality
            if ($remember) {
                $this->createRememberMeToken($user['id']);
            }
            
            return ['success' => true, 'user_id' => $user['id'], 'message' => 'Login successful'];
        } catch (PDOException $e) {
            return ['success' => false, 'message' => 'Database error: ' . $e->getMessage()];
        }
    }
    
    public function logout() {
        session_start();
        
        // Clear session
        $_SESSION = [];
        session_destroy();
        
        // Clear remember me cookie
        if (isset($_COOKIE['remember_me'])) {
            list($selector) = explode(':', $_COOKIE['remember_me'], 2);
            
            // Delete token from database
            $stmt = $this->pdo->prepare("DELETE FROM auth_tokens WHERE selector = ?");
            $stmt->execute([$selector]);
            
            // Expire cookie
            setcookie('remember_me', '', time() - 3600, '/', '', true, true);
        }
        
        return ['success' => true, 'message' => 'Logout successful'];
    }
    
    public function isLoggedIn() {
        session_start();
        
        if (isset($_SESSION['user_id'])) {
            return true;
        }
        
        // Check remember me cookie
        if (isset($_COOKIE['remember_me'])) {
            return $this->validateRememberMeToken();
        }
        
        return false;
    }
    
    public function getCurrentUserId() {
        session_start();
        return $_SESSION['user_id'] ?? null;
    }
    
    public function assignRole($userId, $roleName) {
        // Get role ID
        $stmt = $this->pdo->prepare("SELECT id FROM roles WHERE name = ?");
        $stmt->execute([$roleName]);
        $role = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$role) {
            return false; // Role doesn't exist
        }
        
        try {
            $stmt = $this->pdo->prepare("INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)");
            return $stmt->execute([$userId, $role['id']]);
        } catch (PDOException $e) {
            // Role might already be assigned
            return false;
        }
    }
    
    public function hasPermission($userId, $permissionName) {
        $query = "
        SELECT COUNT(*) FROM permissions p
        JOIN role_permissions rp ON p.id = rp.permission_id
        JOIN user_roles ur ON rp.role_id = ur.role_id
        WHERE ur.user_id = ? AND p.name = ?
        ";
        
        $stmt = $this->pdo->prepare($query);
        $stmt->execute([$userId, $permissionName]);
        
        return $stmt->fetchColumn() > 0;
    }
    
    public function hasRole($userId, $roleName) {
        $query = "
        SELECT COUNT(*) FROM roles r
        JOIN user_roles ur ON r.id = ur.role_id
        WHERE ur.user_id = ? AND r.name = ?
        ";
        
        $stmt = $this->pdo->prepare($query);
        $stmt->execute([$userId, $roleName]);
        
        return $stmt->fetchColumn() > 0;
    }
    
    private function createRememberMeToken($userId) {
        $selector = bin2hex(random_bytes(16));
        $validator = bin2hex(random_bytes(32));
        $token = $selector . ':' . $validator;
        
        $hashedValidator = password_hash($validator, PASSWORD_DEFAULT);
        $expiry = date('Y-m-d H:i:s', time() + 2592000); // 30 days
        
        // Remove any existing tokens for this user
        $stmt = $this->pdo->prepare("DELETE FROM auth_tokens WHERE user_id = ?");
        $stmt->execute([$userId]);
        
        // Create new token
        $stmt = $this->pdo->prepare("INSERT INTO auth_tokens (user_id, selector, hashed_validator, expiry) VALUES (?, ?, ?, ?)");
        $stmt->execute([$userId, $selector, $hashedValidator, $expiry]);
        
        setcookie('remember_me', $token, time() + 2592000, '/', '', true, true);
        
        return true;
    }
    
    private function validateRememberMeToken() {
        list($selector, $validator) = explode(':', $_COOKIE['remember_me'], 2);
        
        $stmt = $this->pdo->prepare("SELECT user_id, hashed_validator, expiry FROM auth_tokens WHERE selector = ?");
        $stmt->execute([$selector]);
        $token = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$token || strtotime($token['expiry']) < time()) {
            return false;
        }
        
        if (password_verify($validator, $token['hashed_validator'])) {
            // Log user in
            $_SESSION['user_id'] = $token['user_id'];
            
            // Get username
            $stmt = $this->pdo->prepare("SELECT username FROM users WHERE id = ?");
            $stmt->execute([$token['user_id']]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($user) {
                $_SESSION['username'] = $user['username'];
            }
            
            // Regenerate remember me token for security
            $this->createRememberMeToken($token['user_id']);
            
            return true;
        }
        
        return false;
    }
}
```

### Security Best Practices

#### Protection Against Common Attacks

##### CSRF Protection

```php
function generateCsrfToken() {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function validateCsrfToken($token) {
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

// Example usage in a form
echo '<input type="hidden" name="csrf_token" value="' . generateCsrfToken() . '">';

// Example validation
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!validateCsrfToken($_POST['csrf_token'])) {
        die('CSRF token validation failed');
    }
    // Process form...
}
```

##### Preventing SQL Injection

```php
// Always use prepared statements with PDO
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
$stmt->execute([$username]);

// Or with named parameters
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = :username");
$stmt->execute(['username' => $username]);
```

##### Preventing XSS Attacks

```php
// Output escaping
echo htmlspecialchars($userInput, ENT_QUOTES, 'UTF-8');

// Input validation
function sanitizeInput($input) {
    return filter_var($input, FILTER_SANITIZE_STRING);
}
```

### Rate Limiting for Login Attempts

```php
function checkLoginAttempts($ip, $username) {
    global $pdo;
    
    // Get attempts in the last 15 minutes
    $stmt = $pdo->prepare("
        SELECT COUNT(*) FROM login_attempts 
        WHERE (ip_address = ? OR username = ?) 
        AND attempt_time > DATE_SUB(NOW(), INTERVAL 15 MINUTE)
    ");
    $stmt->execute([$ip, $username]);
    $attempts = $stmt->fetchColumn();
    
    if ($attempts >= 5) {
        // Too many attempts
        return false;
    }
    
    return true;
}

function recordLoginAttempt($ip, $username, $success) {
    global $pdo;
    
    $stmt = $pdo->prepare("
        INSERT INTO login_attempts (ip_address, username, success) 
        VALUES (?, ?, ?)
    ");
    $stmt->execute([$ip, $username, $success]);
}

// Usage in login function
if (!checkLoginAttempts($_SERVER['REMOTE_ADDR'], $username)) {
    return ['success' => false, 'message' => 'Too many login attempts. Please try again later.'];
}

// After login attempt
recordLoginAttempt($_SERVER['REMOTE_ADDR'], $username, $success);
```

### Implementing Audit Logging

```php
function logUserAction($userId, $action, $details = null) {
    global $pdo;
    
    $stmt = $pdo->prepare("
        INSERT INTO audit_logs (user_id, action, details, ip_address, user_agent) 
        VALUES (?, ?, ?, ?, ?)
    ");
    
    $stmt->execute([
        $userId,
        $action,
        $details ? json_encode($details) : null,
        $_SERVER['REMOTE_ADDR'],
        $_SERVER['HTTP_USER_AGENT'] ?? null
    ]);
}

// Example usage
logUserAction($userId, 'login', ['method' => 'password']);
logUserAction($userId, 'permission_change', ['added' => 'delete_users', 'by' => $adminId]);
```

**Key Points**

- Implement comprehensive logging for security events
- Store IP addresses and user agents for better forensic capabilities
- Consider using a separate database or storage for logs to prevent tampering
- Regularly review logs for suspicious activities

### Important Security Considerations

- Use HTTPS for all authentication and authorization processes
- Implement proper password policies (minimum length, complexity requirements)
- Consider account lockout policies and password expiration
- Use secure headers (Content-Security-Policy, X-XSS-Protection, etc.)
- Regularly update PHP and all dependencies
- Follow the principle of least privilege when assigning permissions
- Consider implementing multi-factor authentication for sensitive operations
- Perform regular security audits and code reviews

---

# Error Handling and Debugging

## Error Types and Handling in PHP

### Understanding PHP Error Types

PHP defines several error types that help categorize issues that occur during script execution.

#### Core Error Types

```php
// Common PHP Error Constants
E_ERROR             // Fatal run-time errors that halt script execution
E_WARNING           // Run-time warnings (non-fatal errors)
E_PARSE             // Compile-time parse errors
E_NOTICE            // Run-time notices (potential issues)
E_CORE_ERROR        // Fatal errors during PHP initial startup
E_CORE_WARNING      // Warnings during PHP initial startup
E_COMPILE_ERROR     // Fatal compile-time errors
E_COMPILE_WARNING   // Compile-time warnings
E_USER_ERROR        // User-generated error message
E_USER_WARNING      // User-generated warning message
E_USER_NOTICE       // User-generated notice message
E_STRICT            // Runtime notices for future compatibility
E_RECOVERABLE_ERROR // Catchable fatal error
E_DEPRECATED        // Warnings about code that will not work in future versions
E_USER_DEPRECATED   // User-generated deprecation warnings
E_ALL               // All errors and warnings (except E_STRICT in < PHP 5.4.0)
```

#### Error vs Exception vs Throwable

```php
// Error - Cannot be caught with try-catch prior to PHP 7
// Traditional PHP errors (E_WARNING, E_NOTICE, etc.)

// Exception - Can be caught with try-catch
// Custom exceptions should extend this base class
class MyCustomException extends Exception {}

// Throwable - Interface implemented by both Error and Exception in PHP 7+
// Can catch both errors and exceptions in PHP 7+:
try {
    // Code that might throw errors or exceptions
} catch (Throwable $t) {
    // Catches both Error and Exception instances
}
```

**Key Points**

- Before PHP 7, only Exceptions could be caught with try-catch
- PHP 7+ introduced the Error class which implements Throwable (as does Exception)
- E_ERROR types generally terminate script execution if not caught
- E_WARNING and E_NOTICE allow scripts to continue execution

### Error Reporting Configuration

PHP error reporting can be configured at multiple levels: in php.ini, at runtime with ini_set(), or for specific code blocks.

#### PHP.ini Configuration

```ini
; Common error reporting settings in php.ini

; Development environment - show all errors
error_reporting = E_ALL
display_errors = On
display_startup_errors = On
log_errors = On
error_log = /path/to/php_error.log

; Production environment - hide errors, log them instead
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
error_log = /path/to/php_error.log
```

#### Runtime Configuration

```php
// For development environments
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// For production environments
ini_set('display_errors', 0);
error_reporting(E_ALL & ~E_NOTICE & ~E_DEPRECATED);
ini_set('log_errors', 1);
ini_set('error_log', '/path/to/php_error.log');
```

#### Controlling Error Reporting for Specific Functions

```php
// Suppress errors for a specific function call
$result = @file_get_contents('non_existent_file.txt');
if ($result === false) {
    // Handle error gracefully
}

// Alternative to @ operator (better practice)
$errorReporting = error_reporting(0); // Turn off error reporting
$result = file_get_contents('non_existent_file.txt');
error_reporting($errorReporting); // Restore previous error reporting level
```

**Key Points**

- Development environments should show all errors for easier debugging
- Production environments should hide errors from users but log them for administrators
- The @ operator suppresses errors but affects performance and can hide serious issues
- It's better to use try-catch blocks instead of the @ operator when possible

### Try-Catch Blocks

Try-catch blocks allow you to handle exceptions gracefully without terminating script execution.

#### Basic Try-Catch

```php
try {
    // Code that might throw an exception
    $file = new SplFileObject('non_existent_file.txt');
} catch (Exception $e) {
    // Handle the exception
    echo "An exception occurred: " . $e->getMessage();
}
```

#### Multiple Catch Blocks

```php
try {
    // Code that might throw different types of exceptions
    $db = new PDO('mysql:host=localhost;dbname=test', 'username', 'password');
    $stmt = $db->prepare('SELECT * FROM non_existent_table');
    $stmt->execute();
} catch (PDOException $e) {
    // Handle database-specific exceptions
    echo "Database error: " . $e->getMessage();
} catch (Exception $e) {
    // Handle other exceptions
    echo "General exception: " . $e->getMessage();
}
```

#### Catch Order Matters

```php
try {
    // Some code
} catch (SpecificException $e) {
    // This will catch SpecificException
} catch (Exception $e) {
    // This will catch any other Exception types that aren't SpecificException
} finally {
    // This code always runs, regardless of whether an exception was thrown
}
```

#### Finally Block

```php
try {
    $file = fopen('data.txt', 'r');
    $content = fread($file, filesize('data.txt'));
    // Process content
} catch (Exception $e) {
    echo "Error reading file: " . $e->getMessage();
} finally {
    // This will run whether an exception occurred or not
    if (isset($file) && $file) {
        fclose($file);
    }
}
```

#### Throwing Exceptions

```php
function divide($a, $b) {
    if ($b == 0) {
        throw new InvalidArgumentException("Division by zero");
    }
    return $a / $b;
}

try {
    echo divide(10, 0);
} catch (InvalidArgumentException $e) {
    echo "Invalid argument: " . $e->getMessage();
}
```

#### Rethrowing Exceptions

```php
try {
    // Some code that might throw an exception
    processData();
} catch (Exception $e) {
    // Log the exception
    error_log("Exception caught: " . $e->getMessage());
    
    // Rethrow it for higher-level handling
    throw $e;
}
```

#### Nested Try-Catch Blocks

```php
try {
    try {
        // Some code that might throw an exception
        throw new Exception("Inner exception");
    } catch (Exception $e) {
        // Handle or transform the exception
        throw new RuntimeException("Outer exception: " . $e->getMessage(), 0, $e);
    }
} catch (RuntimeException $e) {
    echo "Caught: " . $e->getMessage();
    // Access the previous exception
    $previous = $e->getPrevious();
    if ($previous) {
        echo "Previous: " . $previous->getMessage();
    }
}
```

#### Custom Exception Classes

```php
// Define custom exception classes
class DatabaseException extends Exception {
    private $query;
    
    public function __construct($message, $query = null, $code = 0, Exception $previous = null) {
        parent::__construct($message, $code, $previous);
        $this->query = $query;
    }
    
    public function getQuery() {
        return $this->query;
    }
}

class ValidationException extends Exception {
    private $invalidFields = [];
    
    public function __construct($message, array $invalidFields = [], $code = 0, Exception $previous = null) {
        parent::__construct($message, $code, $previous);
        $this->invalidFields = $invalidFields;
    }
    
    public function getInvalidFields() {
        return $this->invalidFields;
    }
}

// Usage
try {
    $email = 'invalid-email';
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new ValidationException("Invalid input data", ['email' => 'Invalid email format']);
    }
    
    // Database operation
    $query = "SELECT * FROM users WHERE email = '$email'";
    // If database error occurs
    throw new DatabaseException("Database query failed", $query);
} catch (ValidationException $e) {
    echo "Validation error: " . $e->getMessage();
    print_r($e->getInvalidFields());
} catch (DatabaseException $e) {
    echo "Database error: " . $e->getMessage();
    echo "Failed query: " . $e->getQuery();
    // Log the error
    error_log($e->getMessage() . " - Query: " . $e->getQuery());
}
```

**Key Points**

- Try-catch blocks help handle errors gracefully without terminating script execution
- Catch blocks should be ordered from most specific to least specific exception types
- The finally block always executes, making it ideal for cleanup operations
- Custom exception classes can provide more context-specific information
- Proper exception handling improves application robustness and user experience

### Custom Error Handlers

PHP allows you to define custom error handlers to process errors in a way specific to your application.

#### Setting Up a Custom Error Handler

```php
// Define custom error handler function
function customErrorHandler($errno, $errstr, $errfile, $errline) {
    $errorType = match($errno) {
        E_ERROR, E_USER_ERROR => 'FATAL ERROR',
        E_WARNING, E_USER_WARNING => 'WARNING',
        E_NOTICE, E_USER_NOTICE => 'NOTICE',
        E_DEPRECATED, E_USER_DEPRECATED => 'DEPRECATED',
        default => 'UNKNOWN ERROR'
    };
    
    // Format error message
    $errorMessage = "$errorType: $errstr in $errfile on line $errline";
    
    // Different actions based on error type
    if ($errno == E_ERROR || $errno == E_USER_ERROR) {
        // Log fatal errors and display a user-friendly message
        error_log($errorMessage);
        echo "<div style='color:red;'>A critical error occurred. Please try again later.</div>";
        exit(1);
    } else {
        // Log non-fatal errors
        error_log($errorMessage);
        
        // If in development environment, display the error
        if (getenv('APP_ENV') === 'development') {
            echo "<div style='color:orange;'>$errorMessage</div>";
        }
    }

    // Return true to prevent PHP's built-in error handler from running
    return true;
}

// Register the custom error handler
set_error_handler('customErrorHandler');
```

#### Handling Fatal Errors with Register Shutdown Function

```php
// Register shutdown function to catch fatal errors
function fatalErrorHandler() {
    $error = error_get_last();
    
    // Check if the last error was fatal
    if ($error && ($error['type'] === E_ERROR || $error['type'] === E_PARSE || $error['type'] === E_COMPILE_ERROR)) {
        // Clear any output that might have been generated
        ob_clean();
        
        // Log the error
        $errorMessage = "FATAL ERROR: {$error['message']} in {$error['file']} on line {$error['line']}";
        error_log($errorMessage);
        
        // Display a friendly error page
        include 'templates/fatal-error.php';
    }
}

// Register the shutdown function
register_shutdown_function('fatalErrorHandler');
```

#### Custom Exception Handler

```php
// Define custom exception handler
function customExceptionHandler($exception) {
    // Log the exception
    $message = "Uncaught Exception: " . $exception->getMessage() . 
               " in file " . $exception->getFile() . 
               " on line " . $exception->getLine();
    error_log($message);
    
    // If in development
    if (getenv('APP_ENV') === 'development') {
        echo "<h1>Exception Occurred</h1>";
        echo "<p><strong>Message:</strong> " . $exception->getMessage() . "</p>";
        echo "<p><strong>File:</strong> " . $exception->getFile() . "</p>";
        echo "<p><strong>Line:</strong> " . $exception->getLine() . "</p>";
        echo "<h2>Stack Trace:</h2>";
        echo "<pre>" . $exception->getTraceAsString() . "</pre>";
    } else {
        // In production, show a generic error message
        include 'templates/error.php';
    }
    
    exit(1);
}

// Register the exception handler
set_exception_handler('customExceptionHandler');
```

#### Restoring Default Error Handlers

```php
// Save the custom error handler
$oldErrorHandler = set_error_handler('customErrorHandler');

// Code that needs custom error handling
// ...

// Restore the previous error handler
restore_error_handler();

// Same for exception handler
$oldExceptionHandler = set_exception_handler('customExceptionHandler');
// ...
restore_exception_handler();
```

#### Complete Error Handling System Example

```php
class ErrorHandler {
    private $logFile;
    private $developmentMode;
    
    public function __construct($logFile = null, $developmentMode = false) {
        $this->logFile = $logFile ?: ini_get('error_log');
        $this->developmentMode = $developmentMode;
        
        // Register handlers
        set_error_handler([$this, 'handleError']);
        set_exception_handler([$this, 'handleException']);
        register_shutdown_function([$this, 'handleShutdown']);
        
        // Start output buffering for clean error pages
        ob_start();
    }
    
    public function handleError($errno, $errstr, $errfile, $errline) {
        // Don't handle errors that are excluded by error_reporting setting
        if (!(error_reporting() & $errno)) {
            return false;
        }
        
        $errorType = $this->getErrorTypeName($errno);
        $message = "$errorType: $errstr in $errfile on line $errline";
        
        // Log the error
        $this->logError($message);
        
        // Display error in development mode
        if ($this->developmentMode) {
            echo "<div class='error-box error-type-$errno'>";
            echo "<h3>$errorType</h3>";
            echo "<p>$errstr</p>";
            echo "<p><strong>File:</strong> $errfile</p>";
            echo "<p><strong>Line:</strong> $errline</p>";
            echo "</div>";
        }
        
        // If it's a fatal error, stop execution
        if ($errno == E_ERROR || $errno == E_USER_ERROR) {
            exit(1);
        }
        
        // Return true to prevent PHP's built-in error handler
        return true;
    }
    
    public function handleException($exception) {
        $message = "Uncaught Exception: " . $exception->getMessage() . 
                   " in file " . $exception->getFile() . 
                   " on line " . $exception->getLine();
        
        // Log the exception
        $this->logError($message);
        $this->logError($exception->getTraceAsString());
        
        // Clean output buffer
        ob_clean();
        
        // Display error page
        if ($this->developmentMode) {
            echo "<div class='exception-box'>";
            echo "<h2>Uncaught Exception: " . get_class($exception) . "</h2>";
            echo "<p><strong>Message:</strong> " . $exception->getMessage() . "</p>";
            echo "<p><strong>File:</strong> " . $exception->getFile() . "</p>";
            echo "<p><strong>Line:</strong> " . $exception->getLine() . "</p>";
            
            // Display previous exception if available
            $previous = $exception->getPrevious();
            if ($previous) {
                echo "<h3>Previous Exception:</h3>";
                echo "<p><strong>Message:</strong> " . $previous->getMessage() . "</p>";
                echo "<p><strong>File:</strong> " . $previous->getFile() . "</p>";
                echo "<p><strong>Line:</strong> " . $previous->getLine() . "</p>";
            }
            
            echo "<h3>Stack Trace:</h3>";
            echo "<pre>" . $exception->getTraceAsString() . "</pre>";
            echo "</div>";
        } else {
            // In production, show a generic error page
            include 'templates/exception.php';
        }
        
        exit(1);
    }
    
    public function handleShutdown() {
        $error = error_get_last();
        
        if ($error && (
            $error['type'] === E_ERROR || 
            $error['type'] === E_PARSE || 
            $error['type'] === E_COMPILE_ERROR || 
            $error['type'] === E_CORE_ERROR
        )) {
            // Clear output buffer
            ob_clean();
            
            $errorType = $this->getErrorTypeName($error['type']);
            $message = "$errorType: {$error['message']} in {$error['file']} on line {$error['line']}";
            
            // Log the error
            $this->logError($message);
            
            // Display error page
            if ($this->developmentMode) {
                echo "<div class='fatal-error-box'>";
                echo "<h2>Fatal Error</h2>";
                echo "<p><strong>Message:</strong> {$error['message']}</p>";
                echo "<p><strong>File:</strong> {$error['file']}</p>";
                echo "<p><strong>Line:</strong> {$error['line']}</p>";
                echo "</div>";
            } else {
                // In production, show a generic error page
                include 'templates/fatal-error.php';
            }
        }
    }
    
    private function logError($message) {
        $timestamp = date('Y-m-d H:i:s');
        $logMessage = "[$timestamp] $message" . PHP_EOL;
        
        // Add request info to log
        if (isset($_SERVER['REQUEST_URI'])) {
            $logMessage .= "    URL: {$_SERVER['REQUEST_METHOD']} {$_SERVER['REQUEST_URI']}" . PHP_EOL;
        }
        
        if (isset($_SERVER['HTTP_REFERER'])) {
            $logMessage .= "    Referer: {$_SERVER['HTTP_REFERER']}" . PHP_EOL;
        }
        
        // Add IP address if available
        if (isset($_SERVER['REMOTE_ADDR'])) {
            $logMessage .= "    IP: {$_SERVER['REMOTE_ADDR']}" . PHP_EOL;
        }
        
        // Write to log file
        error_log($logMessage, 3, $this->logFile);
    }
    
    private function getErrorTypeName($errorCode) {
        return match($errorCode) {
            E_ERROR => 'E_ERROR',
            E_WARNING => 'E_WARNING',
            E_PARSE => 'E_PARSE',
            E_NOTICE => 'E_NOTICE',
            E_CORE_ERROR => 'E_CORE_ERROR',
            E_CORE_WARNING => 'E_CORE_WARNING',
            E_COMPILE_ERROR => 'E_COMPILE_ERROR',
            E_COMPILE_WARNING => 'E_COMPILE_WARNING',
            E_USER_ERROR => 'E_USER_ERROR',
            E_USER_WARNING => 'E_USER_WARNING',
            E_USER_NOTICE => 'E_USER_NOTICE',
            E_STRICT => 'E_STRICT',
            E_RECOVERABLE_ERROR => 'E_RECOVERABLE_ERROR',
            E_DEPRECATED => 'E_DEPRECATED',
            E_USER_DEPRECATED => 'E_USER_DEPRECATED',
            default => 'UNKNOWN ERROR'
        };
    }
}

// Usage
$errorHandler = new ErrorHandler('/path/to/error.log', true); // true for development mode
```

**Key Points**

- Custom error handlers allow unified error processing across your application
- Different handling strategies can be applied based on error type and environment
- Fatal errors need to be caught with register_shutdown_function
- Including context data like request information makes debugging easier
- Output buffering helps ensure clean error pages

### Advanced Error Handling Techniques

#### Creating a Debug Logger

```php
class DebugLogger {
    private static $instance;
    private $logs = [];
    private $startTime;
    private $logFile;
    
    private function __construct($logFile = null) {
        $this->startTime = microtime(true);
        $this->logFile = $logFile;
    }
    
    public static function getInstance($logFile = null) {
        if (self::$instance === null) {
            self::$instance = new self($logFile);
        }
        return self::$instance;
    }
    
    public function log($message, $context = []) {
        $time = microtime(true);
        $elapsed = $time - $this->startTime;
        
        $logEntry = [
            'time' => date('Y-m-d H:i:s'),
            'elapsed' => round($elapsed, 4),
            'memory' => $this->formatBytes(memory_get_usage()),
            'message' => $message,
            'context' => $context
        ];
        
        $this->logs[] = $logEntry;
        
        // Write to log file if specified
        if ($this->logFile) {
            $logMessage = "[{$logEntry['time']}] [{$logEntry['elapsed']}s] [{$logEntry['memory']}] $message";
            if (!empty($context)) {
                $logMessage .= " " . json_encode($context);
            }
            file_put_contents($this->logFile, $logMessage . PHP_EOL, FILE_APPEND);
        }
        
        return $this;
    }
    
    public function getLogs() {
        return $this->logs;
    }
    
    public function display() {
        echo "<div class='debug-log'>";
        echo "<h2>Debug Log</h2>";
        echo "<table border='1'>";
        echo "<tr><th>Time</th><th>Elapsed</th><th>Memory</th><th>Message</th><th>Context</th></tr>";
        
        foreach ($this->logs as $log) {
            echo "<tr>";
            echo "<td>{$log['time']}</td>";
            echo "<td>{$log['elapsed']}s</td>";
            echo "<td>{$log['memory']}</td>";
            echo "<td>{$log['message']}</td>";
            echo "<td>" . (empty($log['context']) ? '' : json_encode($log['context'])) . "</td>";
            echo "</tr>";
        }
        
        echo "</table>";
        echo "</div>";
    }
    
    private function formatBytes($bytes) {
        $units = ['B', 'KB', 'MB', 'GB', 'TB'];
        
        $bytes = max($bytes, 0);
        $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
        $pow = min($pow, count($units) - 1);
        
        $bytes /= pow(1024, $pow);
        
        return round($bytes, 2) . ' ' . $units[$pow];
    }
}

// Usage
$logger = DebugLogger::getInstance('debug.log');
$logger->log('Starting application');

try {
    $logger->log('Processing data', ['user_id' => 123]);
    // Some code
    throw new Exception('Test exception');
} catch (Exception $e) {
    $logger->log('Exception caught', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
}

$logger->log('Finished processing');

// Display debug info in development environment
if (getenv('APP_ENV') === 'development') {
    $logger->display();
}
```

#### Error Monitoring with Context

```php
class ContextualErrorHandler {
    private static $instance;
    private $errors = [];
    private $context = [];
    
    private function __construct() {
        // Register handlers
        set_error_handler([$this, 'handleError']);
        set_exception_handler([$this, 'handleException']);
    }
    
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    public function addContext($key, $value) {
        $this->context[$key] = $value;
        return $this;
    }
    
    public function handleError($errno, $errstr, $errfile, $errline) {
        // Don't handle errors that are excluded by error_reporting setting
        if (!(error_reporting() & $errno)) {
            return false;
        }
        
        $errorData = [
            'type' => $this->getErrorTypeName($errno),
            'message' => $errstr,
            'file' => $errfile,
            'line' => $errline,
            'context' => $this->context,
            'trace' => debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS)
        ];
        
        $this->errors[] = $errorData;
        
        // Log the error
        $this->logError($errorData);
        
        // Return true to prevent PHP's built-in error handler
        return true;
    }
    
    public function handleException($exception) {
        $errorData = [
            'type' => get_class($exception),
            'message' => $exception->getMessage(),
            'file' => $exception->getFile(),
            'line' => $exception->getLine(),
            'context' => $this->context,
            'trace' => $exception->getTrace()
        ];
        
        $this->errors[] = $errorData;
        
        // Log the error
        $this->logError($errorData);
        
        // Show error page based on environment
        if (getenv('APP_ENV') === 'development') {
            $this->showDetailedErrorPage($errorData);
        } else {
            $this->showGenericErrorPage();
        }
    }
    
    private function logError($errorData) {
        $message = "[{$errorData['type']}] {$errorData['message']} in {$errorData['file']} on line {$errorData['line']}";
        
        // Add context information
        if (!empty($errorData['context'])) {
            $message .= " | Context: " . json_encode($errorData['context']);
        }
        
        error_log($message);
    }
    
    private function showDetailedErrorPage($errorData) {
        echo "<div class='error-page'>";
        echo "<h1>Application Error</h1>";
        echo "<p><strong>Type:</strong> {$errorData['type']}</p>";
        echo "<p><strong>Message:</strong> {$errorData['message']}</p>";
        echo "<p><strong>File:</strong> {$errorData['file']}</p>";
        echo "<p><strong>Line:</strong> {$errorData['line']}</p>";
        
        echo "<h2>Context:</h2>";
        echo "<pre>" . json_encode($errorData['context'], JSON_PRETTY_PRINT) . "</pre>";
        
        echo "<h2>Stack Trace:</h2>";
        echo "<table border='1'>";
        echo "<tr><th>#</th><th>File</th><th>Line</th><th>Function</th></tr>";
        
        foreach ($errorData['trace'] as $i => $trace) {
            echo "<tr>";
            echo "<td>$i</td>";
            echo "<td>" . ($trace['file'] ?? 'Unknown') . "</td>";
            echo "<td>" . ($trace['line'] ?? 'Unknown') . "</td>";
            echo "<td>" . ($trace['function'] ?? 'Unknown') . "</td>";
            echo "</tr>";
        }
        
        echo "</table>";
        echo "</div>";
        exit(1);
    }
    
    private function showGenericErrorPage() {
        header("HTTP/1.1 500 Internal Server Error");
        include 'templates/500.php';
        exit(1);
    }
    
    private function getErrorTypeName($errorCode) {
        return match($errorCode) {
            E_ERROR => 'E_ERROR',
            E_WARNING => 'E_WARNING',
            E_PARSE => 'E_PARSE',
            E_NOTICE => 'E_NOTICE',
            E_CORE_ERROR => 'E_CORE_ERROR',
            E_CORE_WARNING => 'E_CORE_WARNING',
            E_COMPILE_ERROR => 'E_COMPILE_ERROR',
            E_COMPILE_WARNING => 'E_COMPILE_WARNING',
            E_USER_ERROR => 'E_USER_ERROR',
            E_USER_WARNING => 'E_USER_WARNING',
            E_USER_NOTICE => 'E_USER_NOTICE',
            E_STRICT => 'E_STRICT',
            E_RECOVERABLE_ERROR => 'E_RECOVERABLE_ERROR',
            E_DEPRECATED => 'E_DEPRECATED',
            E_USER_DEPRECATED => 'E_USER_DEPRECATED',
            default => 'UNKNOWN ERROR'
        };
    }
}

// Usage
$errorHandler = ContextualErrorHandler::getInstance();

// Add request context
$errorHandler->addContext('url', $_SERVER['REQUEST_URI'] ?? null)
             ->addContext('method', $_SERVER['REQUEST_METHOD'] ?? null)
             ->addContext('ip', $_SERVER['REMOTE_ADDR'] ?? null);

// Add user context if authenticated
if (isset($_SESSION['user_id'])) {
    $errorHandler->addContext('user_id', $_SESSION['user_id']);
}

// Now any errors will include this context
try {
    // Transaction start
    $errorHandler->addContext('transaction_id', uniqid('tx_'));
    
    // Some code that might throw an exception
    processOrder($orderId);
} catch (Exception $e) {
    // Additional context for this specific catch block
    $errorHandler->addContext('order_id', $orderId);
    throw $e; // Re-throw to be handled by the exception handler
}
```

#### Integration with External Logging Services

```php
class ExternalErrorHandler {
    private $serviceName;
    private $apiKey;
    private $errorCount = 0;
    private $maxErrors = 10; // Limit the number of external reports
    private $developmentMode;
    
    public function __construct($serviceName, $apiKey, $developmentMode = false) {
        $this->serviceName = $serviceName;
        $this->apiKey = $apiKey;
        $this->developmentMode = $developmentMode;
        
        // Register handlers
        set_error_handler([$this, 'handleError']);
        set_exception_handler([$this, 'handleException']);
        register_shutdown_function([$this, 'handleShutdown']);
    }
    
    public function handleError($errno, $errstr, $errfile, $errline) {
        // Skip if error reporting is disabled for this error
        if (!(error_reporting() & $errno)) {
            return false;
        }
        
        // Log locally
        $errorType = $this->getErrorTypeName($errno);
        $message = "$errorType: $errstr in $errfile on line $errline";
        error_log($message);
        
        // Report to external service (only for significant errors)
        if (in_array($errno, [E_ERROR, E_RECOVERABLE_ERROR, E_USER_ERROR]) && $this->errorCount < $this->maxErrors) {
            $this->reportToExternalService($errorType, $errstr, $errfile, $errline);
            $this->errorCount++;
        }
        
        return true;
    }
    
    public function handleException($exception) {
        // Log locally
        $message = "Uncaught Exception: " . get_class($exception) . " - " . $exception->getMessage() . 
                   " in file " . $exception->getFile() . " on line " . $exception->getLine();
        error_log($message);
        error_log($exception->getTraceAsString());
        
        // Report to external service if we haven't hit the limit
        if ($this->errorCount < $this->maxErrors) {
            $this->reportToExternalService(
                get_class($exception),
                $exception->getMessage(),
                $exception->getFile(),
                $exception->getLine(),
                $exception->getTraceAsString()
            );
            $this->errorCount++;
        }
        
        // Display user-friendly error in production
        if (!$this->developmentMode) {
            header('HTTP/1.1 500 Internal Server Error');
            echo '<h1>Something went wrong</h1>';
            echo '<p>Our team has been notified and is working on the issue.</p>';
        } else {
            // Show detailed error in development
            echo '<h1>Uncaught Exception: ' . get_class($exception) . '</h1>';
            echo '<p>' . $exception->getMessage() . '</p>';
            echo '<p>in <strong>' . $exception->getFile() . '</strong> on line <strong>' . $exception->getLine() . '</strong></p>';
            echo '<pre>' . $exception->getTraceAsString() . '</pre>';
        }
        
        exit(1);
    }
    
    public function handleShutdown() {
        $error = error_get_last();
        
        // Only handle fatal errors that haven't been caught
        if ($error && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
            // Log locally
            $message = "FATAL ERROR: {$error['message']} in {$error['file']} on line {$error['line']}";
            error_log($message);
            
            // Report to external service
            if ($this->errorCount < $this->maxErrors) {
                $this->reportToExternalService(
                    $this->getErrorTypeName($error['type']),
                    $error['message'],
                    $error['file'],
                    $error['line']
                );
            }
            
            // Display user-friendly error in production
            if (!$this->developmentMode) {
                if (!headers_sent()) {
                    header('HTTP/1.1 500 Internal Server Error');
                    echo '<h1>Something went wrong</h1>';
                    echo '<p>Our team has been notified and is working on the issue.</p>';
                }
            } else {
                // Show detailed error in development
                echo '<div style="border: 2px solid red; padding: 10px; margin: 10px;">';
                echo '<h1>Fatal Error</h1>';
                echo '<p>' . $error['message'] . '</p>';
                echo '<p>in <strong>' . $error['file'] . '</strong> on line <strong>' . $error['line'] . '</strong></p>';
                echo '</div>';
            }
        }
    }
    
    private function reportToExternalService($type, $message, $file, $line, $trace = '') {
        // Sanitize and prepare data
        $data = [
            'api_key' => $this->apiKey,
            'service' => $this->serviceName,
            'error_type' => $type,
            'message' => $message,
            'file' => $file,
            'line' => $line,
            'trace' => $trace,
            'url' => $_SERVER['REQUEST_URI'] ?? '',
            'method' => $_SERVER['REQUEST_METHOD'] ?? '',
            'timestamp' => date('Y-m-d H:i:s'),
            'server' => $_SERVER['SERVER_NAME'] ?? '',
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            'php_version' => PHP_VERSION
        ];
        
        // Determine which service to use based on serviceName
        switch ($this->serviceName) {
            case 'sentry':
                $url = 'https://sentry.io/api/errors/';
                break;
            case 'bugsnag':
                $url = 'https://notify.bugsnag.com/';
                break;
            case 'rollbar':
                $url = 'https://api.rollbar.com/api/1/item/';
                break;
            default:
                $url = 'https://logs.yourservice.com/api/errors';
        }
        
        // Send asynchronously to avoid impacting performance
        $this->sendAsyncRequest($url, $data);
    }
    
    private function sendAsyncRequest($url, $data) {
        // Create a non-blocking request
        $options = [
            'http' => [
                'header'  => "Content-type: application/json\r\n",
                'method'  => 'POST',
                'content' => json_encode($data),
                'timeout' => 1,  // Short timeout to avoid blocking
            ]
        ];
        
        $context = stream_context_create($options);
        $result = @file_get_contents($url, false, $context);
        
        // We don't care about the result as this is async
        return;
    }
    
    private function getErrorTypeName($type) {
        // Convert error constant to string name
        $errorTypes = [
            E_ERROR => 'E_ERROR',
            E_WARNING => 'E_WARNING',
            E_PARSE => 'E_PARSE',
            E_NOTICE => 'E_NOTICE',
            E_CORE_ERROR => 'E_CORE_ERROR',
            E_CORE_WARNING => 'E_CORE_WARNING',
            E_COMPILE_ERROR => 'E_COMPILE_ERROR',
            E_COMPILE_WARNING => 'E_COMPILE_WARNING',
            E_USER_ERROR => 'E_USER_ERROR',
            E_USER_WARNING => 'E_USER_WARNING',
            E_USER_NOTICE => 'E_USER_NOTICE',
            E_STRICT => 'E_STRICT',
            E_RECOVERABLE_ERROR => 'E_RECOVERABLE_ERROR',
            E_DEPRECATED => 'E_DEPRECATED',
            E_USER_DEPRECATED => 'E_USER_DEPRECATED',
        ];
        
        return $errorTypes[$type] ?? 'UNKNOWN_ERROR';
    }
}
```

#### Handling AJAX and API Errors

When building modern PHP applications, especially those with JavaScript frontends or providing API endpoints, special consideration is required for error handling. Here's how to handle errors in these contexts:

```php
class ApiErrorHandler {
    private $format; // 'json' or 'xml'
    
    public function __construct($format = 'json') {
        $this->format = $format;
        set_exception_handler([$this, 'handleException']);
        set_error_handler([$this, 'handleError']);
    }
    
    public function handleException($exception) {
        $statusCode = ($exception instanceof HttpException) ? $exception->getCode() : 500;
        
        // Ensure we have a valid HTTP status code
        if ($statusCode < 100 || $statusCode > 599) {
            $statusCode = 500;
        }
        
        $data = [
            'status' => 'error',
            'code' => $statusCode,
            'message' => $exception->getMessage(),
        ];
        
        // Add stack trace in development mode
        if (defined('ENVIRONMENT') && ENVIRONMENT === 'development') {
            $data['file'] = $exception->getFile();
            $data['line'] = $exception->getLine();
            $data['trace'] = $exception->getTraceAsString();
        }
        
        $this->outputError($statusCode, $data);
    }
    
    public function handleError($errno, $errstr, $errfile, $errline) {
        // Skip if error reporting is disabled for this error
        if (!(error_reporting() & $errno)) {
            return false;
        }
        
        $data = [
            'status' => 'error',
            'code' => 500,
            'message' => $errstr,
        ];
        
        // Add details in development mode
        if (defined('ENVIRONMENT') && ENVIRONMENT === 'development') {
            $data['file'] = $errfile;
            $data['line'] = $errline;
            $data['type'] = $this->getErrorTypeName($errno);
        }
        
        $this->outputError(500, $data);
        return true;
    }
    
    private function outputError($statusCode, $data) {
        http_response_code($statusCode);
        
        if ($this->format === 'json') {
            header('Content-Type: application/json');
            echo json_encode($data);
        } else if ($this->format === 'xml') {
            header('Content-Type: application/xml');
            echo $this->arrayToXml($data);
        }
        
        exit;
    }
    
    private function arrayToXml($data) {
        $xml = new SimpleXMLElement('<response></response>');
        $this->arrayToXmlHelper($data, $xml);
        return $xml->asXML();
    }
    
    private function arrayToXmlHelper($data, &$xml) {
        foreach ($data as $key => $value) {
            if (is_array($value)) {
                $subnode = $xml->addChild($key);
                $this->arrayToXmlHelper($value, $subnode);
            } else {
                $xml->addChild($key, htmlspecialchars($value));
            }
        }
    }
    
    private function getErrorTypeName($type) {
        // Same implementation as in ExternalErrorHandler class
        $errorTypes = [
            E_ERROR => 'E_ERROR',
            E_WARNING => 'E_WARNING',
            E_PARSE => 'E_PARSE',
            E_NOTICE => 'E_NOTICE',
            E_CORE_ERROR => 'E_CORE_ERROR',
            E_CORE_WARNING => 'E_CORE_WARNING',
            E_COMPILE_ERROR => 'E_COMPILE_ERROR',
            E_COMPILE_WARNING => 'E_COMPILE_WARNING',
            E_USER_ERROR => 'E_USER_ERROR',
            E_USER_WARNING => 'E_USER_WARNING',
            E_USER_NOTICE => 'E_USER_NOTICE',
            E_STRICT => 'E_STRICT',
            E_RECOVERABLE_ERROR => 'E_RECOVERABLE_ERROR',
            E_DEPRECATED => 'E_DEPRECATED',
            E_USER_DEPRECATED => 'E_USER_DEPRECATED',
        ];
        
        return $errorTypes[$type] ?? 'UNKNOWN_ERROR';
    }
}

// Custom HTTP exception class for API errors
class HttpException extends Exception {
    public function __construct($message, $code = 500) {
        parent::__construct($message, $code);
    }
}

// Usage example
$apiHandler = new ApiErrorHandler('json');

// Now you can throw HTTP exceptions with appropriate status codes
try {
    $user = authenticateUser();
    if (!$user) {
        throw new HttpException('Unauthorized access', 401);
    }
    
    $resource = fetchResource($_GET['id']);
    if (!$resource) {
        throw new HttpException('Resource not found', 404);
    }
    
    // Process the request...
} catch (HttpException $e) {
    // This will be caught by our custom exception handler
    throw $e;
}
```

#### Error Handling in Production vs Development

Error handling strategies should differ between development and production environments:

```php
class ErrorHandlingConfig {
    public static function initialize() {
        // Determine environment
        $environment = getenv('APP_ENV') ?: 'production';
        
        // Define constant for use in other parts of the application
        define('ENVIRONMENT', $environment);
        
        switch ($environment) {
            case 'development':
                // Show all errors in development
                ini_set('display_errors', 1);
                ini_set('display_startup_errors', 1);
                error_reporting(E_ALL);
                break;
                
            case 'testing':
                // Show errors but log them as well
                ini_set('display_errors', 1);
                error_reporting(E_ALL & ~E_DEPRECATED & ~E_STRICT);
                break;
                
            case 'production':
            default:
                // Hide errors in production but log them
                ini_set('display_errors', 0);
                error_reporting(E_ALL & ~E_DEPRECATED & ~E_NOTICE);
                
                // Ensure logs are written
                ini_set('log_errors', 1);
                ini_set('error_log', '/path/to/secure/logs/php_errors.log');
                break;
        }
        
        // Register appropriate error handlers based on environment
        if ($environment === 'production') {
            // Use production-safe error handlers
            $handler = new ProductionErrorHandler();
        } else {
            // Use detailed error handlers for development
            $handler = new DevelopmentErrorHandler();
        }
        
        // Register the handler
        $handler->register();
    }
}

class ProductionErrorHandler {
    public function register() {
        set_error_handler([$this, 'handleError']);
        set_exception_handler([$this, 'handleException']);
        register_shutdown_function([$this, 'handleShutdown']);
    }
    
    public function handleError($errno, $errstr, $errfile, $errline) {
        if (!(error_reporting() & $errno)) {
            return false;
        }
        
        // Log the error with context
        $this->logError($errno, $errstr, $errfile, $errline);
        
        // For fatal errors, display generic error page
        if (in_array($errno, [E_ERROR, E_USER_ERROR, E_RECOVERABLE_ERROR])) {
            $this->displayErrorPage();
            exit(1);
        }
        
        return true;
    }
    
    public function handleException($exception) {
        // Log the exception
        $message = get_class($exception) . ': ' . $exception->getMessage() . 
                   ' in ' . $exception->getFile() . ' on line ' . $exception->getLine();
        error_log($message);
        error_log($exception->getTraceAsString());
        
        // Display generic error page
        $this->displayErrorPage();
        exit(1);
    }
    
    public function handleShutdown() {
        $error = error_get_last();
        
        if ($error && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
            // Log fatal error
            $this->logError($error['type'], $error['message'], $error['file'], $error['line']);
            
            // Display generic error page if headers not sent
            if (!headers_sent()) {
                $this->displayErrorPage();
            }
        }
    }
    
    private function logError($type, $message, $file, $line) {
        $errorTypes = [
            E_ERROR => 'Fatal Error',
            E_WARNING => 'Warning',
            E_PARSE => 'Parse Error',
            E_NOTICE => 'Notice',
            E_CORE_ERROR => 'Core Error',
            E_CORE_WARNING => 'Core Warning',
            E_COMPILE_ERROR => 'Compile Error',
            E_COMPILE_WARNING => 'Compile Warning',
            E_USER_ERROR => 'User Error',
            E_USER_WARNING => 'User Warning',
            E_USER_NOTICE => 'User Notice',
            E_STRICT => 'Strict Standards',
            E_RECOVERABLE_ERROR => 'Recoverable Error',
            E_DEPRECATED => 'Deprecated',
            E_USER_DEPRECATED => 'User Deprecated',
        ];
        
        $errorType = $errorTypes[$type] ?? 'Unknown Error';
        $logMessage = "[$errorType] $message in $file on line $line";
        
        // Add context information
        $context = [
            'URL' => $_SERVER['REQUEST_URI'] ?? 'CLI',
            'IP' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
            'Time' => date('Y-m-d H:i:s'),
            'User-Agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown'
        ];
        
        $contextString = json_encode($context);
        error_log("$logMessage | Context: $contextString");
    }
    
    private function displayErrorPage() {
        if (php_sapi_name() === 'cli') {
            echo "An error occurred. Please check the error logs for more information.\n";
            return;
        }
        
        // Clear any output buffers
        while (ob_get_level()) {
            ob_end_clean();
        }
        
        // Send appropriate header
        if (!headers_sent()) {
            header('HTTP/1.1 500 Internal Server Error');
            header('Content-Type: text/html; charset=UTF-8');
        }
        
        // Display generic error page
        include '/path/to/error_pages/500.php';
    }
}

class DevelopmentErrorHandler {
    public function register() {
        set_error_handler([$this, 'handleError']);
        set_exception_handler([$this, 'handleException']);
        register_shutdown_function([$this, 'handleShutdown']);
    }
    
    public function handleError($errno, $errstr, $errfile, $errline) {
        if (!(error_reporting() & $errno)) {
            return false;
        }
        
        // Get error context
        $context = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS);
        
        // Display detailed error information
        $this->displayDetailedError(
            'PHP Error',
            $errstr,
            $errfile,
            $errline,
            $this->getErrorTypeName($errno),
            $context
        );
        
        // Don't execute PHP's internal error handler
        return true;
    }
    
    public function handleException($exception) {
        $this->displayDetailedError(
            'Uncaught Exception: ' . get_class($exception),
            $exception->getMessage(),
            $exception->getFile(),
            $exception->getLine(),
            'Exception',
            $exception->getTrace()
        );
        exit(1);
    }
    
    public function handleShutdown() {
        $error = error_get_last();
        
        if ($error && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
            $this->displayDetailedError(
                'Fatal Error',
                $error['message'],
                $error['file'],
                $error['line'],
                $this->getErrorTypeName($error['type']),
                []
            );
        }
    }
    
    private function displayDetailedError($title, $message, $file, $line, $type, $trace) {
        if (php_sapi_name() === 'cli') {
            echo "\n===== $title =====\n";
            echo "Type: $type\n";
            echo "Message: $message\n";
            echo "File: $file\n";
            echo "Line: $line\n";
            echo "Stack Trace:\n";
            print_r($trace);
            echo "\n==================\n";
            return;
        }
        
        // Clear any output buffers
        while (ob_get_level()) {
            ob_end_clean();
        }
        
        // Send appropriate header
        if (!headers_sent()) {
            header('HTTP/1.1 500 Internal Server Error');
            header('Content-Type: text/html; charset=UTF-8');
        }
        
        // Display styled error page
        echo '<!DOCTYPE html>';
        echo '<html lang="en">';
        echo '<head>';
        echo '<meta charset="UTF-8">';
        echo '<meta name="viewport" content="width=device-width, initial-scale=1.0">';
        echo '<title>' . htmlspecialchars($title) . '</title>';
        echo '<style>
            body { font-family: sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; }
            .error-container { max-width: 1200px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
            .error-title { background: #f44336; color: white; padding: 10px 15px; margin: -20px -20px 20px; border-radius: 5px 5px 0 0; }
            .error-details { background: #f5f5f5; padding: 15px; border-radius: 5px; overflow: auto; }
            .error-context { margin-top: 20px; }
            .trace-item { padding: 10px; border-bottom: 1px solid #ddd; }
            .trace-item:nth-child(odd) { background: #f9f9f9; }
            .file-excerpt { background: #f8f8f8; padding: 10px; border-left: 3px solid #f44336; font-family: monospace; overflow-x: auto; }
            .highlight-line { background: #ffe0e0; }
            .code-context { font-family: monospace; white-space: pre; overflow-x: auto; }
        </style>';
        echo '</head>';
        echo '<body>';
        echo '<div class="error-container">';
        echo '<div class="error-title"><h1>' . htmlspecialchars($title) . '</h1></div>';
        
        echo '<div class="error-details">';
        echo '<p><strong>Type:</strong> ' . htmlspecialchars($type) . '</p>';
        echo '<p><strong>Message:</strong> ' . htmlspecialchars($message) . '</p>';
        echo '<p><strong>File:</strong> ' . htmlspecialchars($file) . '</p>';
        echo '<p><strong>Line:</strong> ' . htmlspecialchars($line) . '</p>';
        
        // Display file excerpt with line numbers if file exists
        if (file_exists($file)) {
            $codeLines = file($file);
            echo '<div class="file-excerpt">';
            echo '<strong>Code Context:</strong><br>';
            echo '<div class="code-context">';
            
            // Show a few lines before and after the error line
            $startLine = max(0, $line - 5);
            $endLine = min(count($codeLines), $line + 5);
            
            for ($i = $startLine; $i < $endLine; $i++) {
                $currentLine = $i + 1;
                $lineClass = ($currentLine == $line) ? 'highlight-line' : '';
                echo '<div class="' . $lineClass . '">';
                echo sprintf("%4d | %s", $currentLine, htmlspecialchars($codeLines[$i]));
                echo '</div>';
            }
            
            echo '</div></div>';
        }
        
        // Display stack trace
        if (!empty($trace)) {
            echo '<div class="error-context">';
            echo '<h2>Stack Trace</h2>';
            
            foreach ($trace as $i => $item) {
                echo '<div class="trace-item">';
                echo '<strong>#' . $i . '</strong> ';
                
                if (isset($item['class'])) {
                    echo htmlspecialchars($item['class'] . $item['type'] . $item['function']) . '()';
                } else if (isset($item['function'])) {
                    echo htmlspecialchars($item['function']) . '()';
                } else {
                    echo '{main}';
                }
                
                if (isset($item['file']) && isset($item['line'])) {
                    echo ' in ' . htmlspecialchars($item['file']) . ' on line ' . htmlspecialchars($item['line']);
                }
                
                echo '</div>';
            }
            
            echo '</div>';
        }
        
        // Show request data
        echo '<div class="error-context">';
        echo '<h2>Request Data</h2>';
        
        echo '<h3>GET</h3>';
        echo '<pre>' . htmlspecialchars(print_r($_GET, true)) . '</pre>';
        
        echo '<h3>POST</h3>';
        echo '<pre>' . htmlspecialchars(print_r($_POST, true)) . '</pre>';
        
        echo '<h3>SERVER</h3>';
        echo '<pre>' . htmlspecialchars(print_r($_SERVER, true)) . '</pre>';
        
        echo '</div>';
        
        echo '</div></div>';
        echo '</body></html>';
    }
    
    private function getErrorTypeName($type) {
        // Same implementation as in previous classes
        $errorTypes = [
            E_ERROR => 'E_ERROR',
            E_WARNING => 'E_WARNING',
            E_PARSE => 'E_PARSE',
            E_NOTICE => 'E_NOTICE',
            E_CORE_ERROR => 'E_CORE_ERROR',
            E_CORE_WARNING => 'E_CORE_WARNING',
            E_COMPILE_ERROR => 'E_COMPILE_ERROR',
            E_COMPILE_WARNING => 'E_COMPILE_WARNING',
            E_USER_ERROR => 'E_USER_ERROR',
            E_USER_WARNING => 'E_USER_WARNING',
            E_USER_NOTICE => 'E_USER_NOTICE',
            E_STRICT => 'E_STRICT',
            E_RECOVERABLE_ERROR => 'E_RECOVERABLE_ERROR',
            E_DEPRECATED => 'E_DEPRECATED',
            E_USER_DEPRECATED => 'E_USER_DEPRECATED',
        ];
        
        return $errorTypes[$type] ?? 'UNKNOWN_ERROR';
    }
}

// Initialize error handling based on environment
ErrorHandlingConfig::initialize();
```

### Error Handling Best Practices

Here are some best practices for error handling in PHP applications:

#### Hierarchical Error Structure

Create a structured error hierarchy for better error management:

```php
// Base exception class
class AppException extends Exception {
    protected $userMessage;
    protected $context;
    
    public function __construct($message, $code = 0, $previous = null, $userMessage = null, array $context = []) {
        parent::__construct($message, $code, $previous);
        $this->userMessage = $userMessage ?: 'An application error occurred';
        $this->context = $context;
    }
    
    public function getUserMessage() {
        return $this->userMessage;
    }
    
    public function getContext() {
        return $this->context;
    }
}

// Database exceptions
class DatabaseException extends AppException {
    public function __construct($message, $code = 0, $previous = null, $userMessage = null, array $context = []) {
        parent::__construct(
            $message,
            $code,
            $previous,
            $userMessage ?: 'A database error occurred',
            $context
        );
    }
}

// Validation exceptions
class ValidationException extends AppException {
    protected $errors = [];
    
    public function __construct($message, array $errors = [], $code = 0, $previous = null) {
        parent::__construct(
            $message,
            $code,
            $previous,
            'The submitted data contains errors',
            ['errors' => $errors]
        );
        $this->errors = $errors;
    }
    
    public function getErrors() {
        return $this->errors;
    }
}

// Authentication exceptions
class AuthException extends AppException {
    public function __construct($message, $code = 401, $previous = null) {
        parent::__construct(
            $message,
            $code,
            $previous,
            'Authentication failed',
            []
        );
    }
}

// Authorization exceptions
class ForbiddenException extends AppException {
    public function __construct($message = 'Access denied', $code = 403, $previous = null) {
        parent::__construct(
            $message,
            $code,
            $previous,
            'You do not have permission to access this resource',
            []
        );
    }
}

// Not found exceptions
class NotFoundException extends AppException {
    public function __construct($message = 'Resource not found', $code = 404, $previous = null) {
        parent::__construct(
            $message,
            $code,
            $previous,
            'The requested resource could not be found',
            []
        );
    }
}
```

#### Contextual Error Messages

Provide different error messages for developers and end users:

```php
class ErrorMessageHelper {
    private $isDevelopment;
    
    public function __construct($isDevelopment = false) {
        $this->isDevelopment = $isDevelopment;
    }
    
    public function formatException($exception) {
        // Base data available in all environments
        $data = [
            'status' => 'error',
            'message' => $this->getSafeMessage($exception)
        ];
        
        // Add developer-specific information in development mode
        if ($this->isDevelopment) {
            $data['dev_message'] = $exception->getMessage();
            $data['file'] = $exception->getFile();
            $data['line'] = $exception->getLine();
            $data['trace'] = $exception->getTraceAsString();
            
            // Add context if available (for our custom exceptions)
            if ($exception instanceof AppException) {
                $data['context'] = $exception->getContext();
            }
            
            // Add validation errors if available
            if ($exception instanceof ValidationException) {
                $data['validation_errors'] = $exception->getErrors();
            }
        }
        
        return $data;
    }
    
    private function getSafeMessage($exception) {
        // Use user-friendly message from our custom exceptions if available
        if ($exception instanceof AppException && $exception->getUserMessage()) {
            return $exception->getUserMessage();
        }

        // Fallback to generic message
        return 'An unexpected error occurred. Please try again later.';
    }
}
```

### Custom Exception Classes

Use custom exceptions to represent different application concerns. This allows better categorization, easier error management, and improved context reporting.

```php
class AppException extends Exception {
    protected $userMessage;
    protected $context;

    public function __construct($message, $userMessage = null, $context = [], $code = 0, Throwable $previous = null) {
        parent::__construct($message, $code, $previous);
        $this->userMessage = $userMessage;
        $this->context = $context;
    }

    public function getUserMessage() {
        return $this->userMessage;
    }

    public function getContext() {
        return $this->context;
    }
}

class ValidationException extends AppException {
    protected $errors = [];

    public function __construct($errors, $message = 'Validation failed', $userMessage = 'There were validation errors.', $context = [], $code = 422) {
        parent::__construct($message, $userMessage, $context, $code);
        $this->errors = $errors;
    }

    public function getErrors() {
        return $this->errors;
    }
}
```

### Centralized Error Handling

Register a global exception handler to manage uncaught exceptions and standardize responses:

```php
set_exception_handler(function ($exception) {
    $isDevelopment = getenv('APP_ENV') === 'development';
    $errorFormatter = new ErrorMessageHelper($isDevelopment);
    $response = $errorFormatter->formatException($exception);

    header('Content-Type: application/json', true, 500);
    echo json_encode($response);
    exit;
});
```

**Key Points**

- Use custom exception classes for clearer error domain separation.
- Separate user-friendly and developer-focused messages.
- Provide context and validation data in errors where applicable.
- Use centralized handling to simplify and standardize error reporting.
- Never expose sensitive data in production environments.

---

## Logging in PHP

### Understanding PHP Logging Fundamentals

PHP provides several built-in mechanisms for logging errors and application events. Effective logging is crucial for debugging, monitoring application health, security auditing, and understanding user behavior patterns.

**Key Points**:

- PHP has native error logging capabilities through the error_log() function
- Configuration options in php.ini control logging behavior
- Both error logging and application logging serve different but complementary purposes
- Properly structured logs improve debugging efficiency and application maintenance

### Error Logging

PHP's error logging system captures various types of runtime issues including syntax errors, warnings, notices, and fatal errors.

#### Error Reporting Configuration

The error reporting level can be configured in php.ini or dynamically within scripts:

```php
// Set error reporting level
error_reporting(E_ALL);

// Enable display of errors (development only)
ini_set('display_errors', 1);

// Enable error logging
ini_set('log_errors', 1);

// Set error log file
ini_set('error_log', '/path/to/error.log');
```

#### Error Types in PHP

PHP categorizes errors into different levels:

```php
E_ERROR             // Fatal run-time errors
E_WARNING           // Run-time warnings (non-fatal errors)
E_PARSE             // Compile-time parse errors
E_NOTICE            // Run-time notices (potentially incorrect code)
E_CORE_ERROR        // Fatal errors during PHP's initial startup
E_CORE_WARNING      // Warnings during PHP's initial startup
E_COMPILE_ERROR     // Fatal compile-time errors
E_COMPILE_WARNING   // Compile-time warnings
E_USER_ERROR        // User-generated error message
E_USER_WARNING      // User-generated warning message
E_USER_NOTICE       // User-generated notice message
E_STRICT            // PHP suggestions for code improvements
E_RECOVERABLE_ERROR // Catchable fatal error
E_DEPRECATED        // Functions that will be removed in future
E_USER_DEPRECATED   // User-generated deprecation warnings
E_ALL               // All errors and warnings
```

#### Using error_log() Function

The error_log() function sends error messages to various destinations:

```php
// Log to the server's error log or to a file
error_log("Database connection failed", 0);

// Send error by email
error_log("Critical error occurred", 1, "admin@example.com");

// Write to specific file
error_log("Payment processing failed", 3, "/path/to/payment-errors.log");
```

#### Exception Handling with Logging

Combining exception handling with logging creates robust error management:

```php
try {
    // Code that might throw an exception
    $result = divide(10, 0);
} catch (Exception $e) {
    error_log("Exception: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
    // Handle the exception
}
```

### Application Logging

While error logging focuses on issues and exceptions, application logging captures broader events, user actions, system states, and performance metrics.

#### PSR-3 Logger Interface

The PHP-FIG PSR-3 standard defines a common interface for logging libraries:

```php
use Psr\Log\LoggerInterface;

class UserService {
    protected $logger;
    
    public function __construct(LoggerInterface $logger) {
        $this->logger = $logger;
    }
    
    public function registerUser($userData) {
        try {
            // Registration logic
            $this->logger->info('User registered successfully', ['email' => $userData['email']]);
        } catch (Exception $e) {
            $this->logger->error('User registration failed', [
                'error' => $e->getMessage(),
                'email' => $userData['email']
            ]);
            throw $e;
        }
    }
}
```

#### Using Monolog

Monolog is the most popular logging library in PHP that implements PSR-3:

```php
use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use Monolog\Handler\RotatingFileHandler;
use Monolog\Formatter\LineFormatter;

// Create a logger instance
$logger = new Logger('app');

// Add handlers
$logger->pushHandler(new StreamHandler('/path/to/app.log', Logger::DEBUG));
$logger->pushHandler(new RotatingFileHandler('/path/to/app.log', 10, Logger::ERROR)); // Rotate after 10 days

// Log with context data
$logger->info('Page requested', [
    'url' => $_SERVER['REQUEST_URI'],
    'method' => $_SERVER['REQUEST_METHOD'],
    'ip' => $_SERVER['REMOTE_ADDR'],
    'user_id' => $userId ?? null
]);
```

#### Log Levels

PSR-3 defines eight log levels in descending order of severity:

```php
// Emergency: system is unusable
$logger->emergency('System down');

// Alert: action must be taken immediately
$logger->alert('Database unavailable');

// Critical: critical conditions
$logger->critical('Application component unavailable');

// Error: error conditions
$logger->error('Failed to connect to payment gateway');

// Warning: warning conditions
$logger->warning('User quota almost reached');

// Notice: normal but significant condition
$logger->notice('User has logged in');

// Info: informational messages
$logger->info('Page requested');

// Debug: detailed debug information
$logger->debug('Query execution time: 0.005s');
```

#### Structured Logging with JSON

JSON-formatted logs are easily parsable by log analysis tools:

```php
$formatter = new JsonFormatter();
$handler = new StreamHandler('/path/to/app.log');
$handler->setFormatter($formatter);

$logger = new Logger('app');
$logger->pushHandler($handler);

$logger->info('API request received', [
    'endpoint' => '/api/users',
    'parameters' => $_GET,
    'execution_time' => $executionTime
]);
```

### Implementing Centralized Logging

For larger applications, centralized logging aggregates logs from multiple sources.

#### ELK Stack Integration

Connect PHP applications to Elasticsearch, Logstash, and Kibana:

```php
use Monolog\Logger;
use Monolog\Handler\ElasticsearchHandler;
use Elasticsearch\ClientBuilder;

$client = ClientBuilder::create()
    ->setHosts(['elasticsearch:9200'])
    ->build();

$logger = new Logger('app');
$handler = new ElasticsearchHandler($client, [
    'index' => 'app-logs',
    'type' => 'log'
]);

$logger->pushHandler($handler);
```

#### Graylog Integration

Send logs to Graylog via GELF protocol:

```php
use Monolog\Logger;
use Monolog\Handler\GelfHandler;
use Gelf\Publisher;
use Gelf\Transport\UdpTransport;

$transport = new UdpTransport('graylog-server', 12201);
$publisher = new Publisher($transport);
$handler = new GelfHandler($publisher);

$logger = new Logger('app');
$logger->pushHandler($handler);
```

### Best Practices for PHP Logging

#### Log File Management

Implement log rotation to prevent disk space issues:

```php
use Monolog\Logger;
use Monolog\Handler\RotatingFileHandler;

$logger = new Logger('app');
$handler = new RotatingFileHandler(
    '/path/to/app.log',    // Base filename
    14,                    // Keep 14 days of logs
    Logger::INFO,          // Minimum level
    true,                  // Create new log file if it doesn't exist
    0664                   // File permissions
);
$logger->pushHandler($handler);
```

#### Security Considerations

Avoid logging sensitive information:

```php
// WRONG: Logging sensitive data
$logger->info('User login', ['username' => $username, 'password' => $password]);

// CORRECT: Log without sensitive data
$logger->info('User login attempt', ['username' => $username, 'success' => $loginSuccess]);
```

#### Contextual Logging

Add context to make logs more useful:

```php
$logger->info('Order processed', [
    'order_id' => $orderId,
    'amount' => $amount,
    'customer_id' => $customerId,
    'processing_time' => $processingTime
]);
```

#### Performance Considerations

Minimize logging impact on performance:

```php
// Check log level before constructing expensive log messages
if ($logger->isHandling(Logger::DEBUG)) {
    $expensiveData = generateExpensiveDebugData();
    $logger->debug('Performance metrics', $expensiveData);
}
```

### Custom Logging Solutions

#### Creating a Logger Wrapper

Implement a custom wrapper for standardized logging:

```php
class AppLogger {
    private $logger;
    private $defaultContext;
    
    public function __construct(LoggerInterface $logger, array $defaultContext = []) {
        $this->logger = $logger;
        $this->defaultContext = $defaultContext;
    }
    
    public function log($level, $message, array $context = []) {
        $context = array_merge($this->defaultContext, $context);
        $context['timestamp'] = date('Y-m-d H:i:s');
        $context['memory_usage'] = memory_get_usage(true);
        
        $this->logger->log($level, $message, $context);
    }
    
    // Convenience methods for different log levels
    public function info($message, array $context = []) {
        $this->log(Logger::INFO, $message, $context);
    }
    
    public function error($message, array $context = []) {
        $this->log(Logger::ERROR, $message, $context);
    }
    
    // Add more methods for other log levels
}
```

#### Database Logging

Store logs in a database for easy querying:

```php
use Monolog\Logger;
use Monolog\Handler\PdoHandler;

$pdo = new PDO('mysql:host=localhost;dbname=app', 'username', 'password');
$logger = new Logger('app');
$logger->pushHandler(new PdoHandler(
    $pdo,
    'INSERT INTO logs (level, message, context, created_at) VALUES (?, ?, ?, ?)'
));
```

### Advanced Error Handling

#### Custom Error Handler

Register custom error handlers for comprehensive logging:

```php
function customErrorHandler($errno, $errstr, $errfile, $errline) {
    global $logger;
    
    $errorTypes = [
        E_ERROR => 'Error',
        E_WARNING => 'Warning',
        E_PARSE => 'Parse Error',
        E_NOTICE => 'Notice',
        // Add other error types
    ];
    
    $type = $errorTypes[$errno] ?? 'Unknown Error';
    
    $logger->error("$type: $errstr", [
        'file' => $errfile,
        'line' => $errline,
        'trace' => debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS)
    ]);
    
    // Return false to allow PHP's internal error handler to run
    return false;
}

// Register the custom error handler
set_error_handler('customErrorHandler', E_ALL);
```

#### Exception Handler

Catch unhandled exceptions:

```php
function exceptionHandler($exception) {
    global $logger;
    
    $logger->critical('Unhandled Exception: ' . $exception->getMessage(), [
        'exception' => get_class($exception),
        'file' => $exception->getFile(),
        'line' => $exception->getLine(),
        'trace' => $exception->getTraceAsString()
    ]);
    
    // Display a user-friendly message in production
    if (ENVIRONMENT === 'production') {
        echo "An error occurred. Please try again later.";
    } else {
        // Show detailed error in development
        echo "<h1>Exception: " . get_class($exception) . "</h1>";
        echo "<p>" . $exception->getMessage() . "</p>";
        echo "<pre>" . $exception->getTraceAsString() . "</pre>";
    }
    
    exit(1);
}

// Register exception handler
set_exception_handler('exceptionHandler');
```

### Logging in Frameworks

#### Laravel Logging

Laravel provides a robust logging system built on Monolog:

```php
// In Laravel controller or service
Log::info('User action performed', ['user_id' => Auth::id(), 'action' => 'create_post']);

// Configure multiple channels in config/logging.php
'channels' => [
    'stack' => [
        'driver' => 'stack',
        'channels' => ['daily', 'slack'],
    ],
    'daily' => [
        'driver' => 'daily',
        'path' => storage_path('logs/laravel.log'),
        'level' => 'debug',
        'days' => 14,
    ],
    'slack' => [
        'driver' => 'slack',
        'url' => env('LOG_SLACK_WEBHOOK_URL'),
        'username' => 'Laravel Log',
        'emoji' => ':boom:',
        'level' => 'critical',
    ],
]
```

#### Symfony Logging

Symfony uses Monolog with its own configuration:

```php
// In Symfony controller
$this->logger->info('Order created', ['order_id' => $order->getId()]);

// Configure in config/packages/monolog.yaml
monolog:
    channels: ['app', 'payment', 'api']
    handlers:
        main:
            type: rotating_file
            path: "%kernel.logs_dir%/%kernel.environment%.log"
            level: debug
            channels: ["!event"]
            max_files: 10
        payment:
            type: stream
            path: "%kernel.logs_dir%/payment.log"
            level: info
            channels: ["payment"]
```

### Log Analysis and Monitoring

#### Simple Log Analysis with Command Line

Basic analysis with Unix commands:

```bash
# Count occurrences of "error"
grep -c "error" /path/to/app.log

# Find all errors from a specific user
grep "user_id: 123" /path/to/app.log | grep "error"

# Analyze error frequency by hour
grep "ERROR" /path/to/app.log | cut -d' ' -f1,2 | cut -d':' -f1,2 | sort | uniq -c
```

#### Real-time Log Monitoring

Using tools like LogWatch for real-time monitoring:

```php
// Set up hook to send critical errors to monitoring service
$logger->pushProcessor(function ($record) {
    if ($record['level'] >= Logger::CRITICAL) {
        // Send to monitoring service via webhook
        $client = new \GuzzleHttp\Client();
        $client->post('https://monitoring.example.com/webhook', [
            'json' => [
                'message' => $record['message'],
                'context' => $record['context'],
                'level' => $record['level_name'],
            ]
        ]);
    }
    return $record;
});
```

### Auditing and Compliance Logging

For applications requiring regulatory compliance, implement specialized logging:

```php
class AuditLogger {
    private $logger;
    
    public function __construct(LoggerInterface $logger) {
        $this->logger = $logger;
    }
    
    public function logDataAccess($userId, $dataType, $recordId, $action) {
        $this->logger->notice('Data access', [
            'user_id' => $userId,
            'data_type' => $dataType,
            'record_id' => $recordId,
            'action' => $action,
            'ip_address' => $_SERVER['REMOTE_ADDR'],
            'user_agent' => $_SERVER['HTTP_USER_AGENT'],
            'timestamp' => time(),
            'request_id' => $this->getRequestId()
        ]);
    }
    
    private function getRequestId() {
        if (!isset($_SERVER['X_REQUEST_ID'])) {
            $_SERVER['X_REQUEST_ID'] = bin2hex(random_bytes(16));
        }
        return $_SERVER['X_REQUEST_ID'];
    }
}

// Usage
$auditLogger = new AuditLogger($logger);
$auditLogger->logDataAccess(
    $user->getId(),
    'patient_record',
    $patientId,
    'view_medical_history'
);
```

### Integrating Logging with Development Workflow

#### Debug Logging

Development-specific logging for debugging:

```php
class DebugBar {
    private static $logs = [];
    private static $queries = [];
    private static $timing = [];
    
    public static function log($message, $context = []) {
        self::$logs[] = ['message' => $message, 'context' => $context, 'time' => microtime(true)];
    }
    
    public static function logQuery($sql, $params = [], $executionTime = null) {
        self::$queries[] = [
            'sql' => $sql,
            'params' => $params,
            'time' => $executionTime,
        ];
    }
    
    public static function startTiming($name) {
        self::$timing[$name] = ['start' => microtime(true)];
    }
    
    public static function endTiming($name) {
        if (isset(self::$timing[$name])) {
            self::$timing[$name]['end'] = microtime(true);
            self::$timing[$name]['duration'] = self::$timing[$name]['end'] - self::$timing[$name]['start'];
        }
    }
    
    public static function render() {
        if (!DEVELOPMENT_MODE) return '';
        
        // Render debug information as HTML
        $output = '<div class="debug-bar">';
        // Render logs, queries, timing info
        $output .= '</div>';
        
        return $output;
    }
}
```

**Conclusion**:

Proper logging is essential in PHP applications for debugging, monitoring, security, and compliance purposes. By implementing a comprehensive logging strategy that includes both error and application logging, developers can gain valuable insights into their application's behavior, quickly identify and resolve issues, and maintain a secure and reliable system. Using standardized logging interfaces like PSR-3 and powerful libraries like Monolog enables developers to create flexible and maintainable logging solutions that can grow with their application's needs.

Related topics you might find useful:

- PHP Application Performance Monitoring
- Log Aggregation and Analysis Tools
- Security Logging Best Practices
- Implementing Request Tracing in PHP Applications

---

## Debugging Techniques in PHP

### Understanding PHP Debugging Fundamentals

Debugging is an essential skill for PHP developers that helps identify and fix issues in code. Effective debugging techniques can significantly reduce development time and improve code quality by systematically isolating and resolving problems.

**Key Points**:

- PHP offers built-in functions like var_dump() and print_r() for basic debugging
- Xdebug extends PHP with advanced debugging capabilities
- Modern IDEs provide integrated debugging tools that streamline the process
- Selecting the right debugging approach depends on project complexity and environment

### Using var_dump() and print_r()

These native PHP functions provide simple but effective ways to inspect variables during runtime.

#### var_dump() Function

The var_dump() function displays structured information about variables including type and value:

```php
// Simple variable
$username = "john_doe";
var_dump($username);
// Output: string(8) "john_doe"

// Array
$user = [
    'id' => 1,
    'name' => 'John Doe',
    'email' => 'john@example.com',
    'active' => true
];
var_dump($user);
/* Output:
array(4) {
  ["id"]=>
  int(1)
  ["name"]=>
  string(8) "John Doe"
  ["email"]=>
  string(16) "john@example.com"
  ["active"]=>
  bool(true)
}
*/

// Object
$dateTime = new DateTime('2023-01-15');
var_dump($dateTime);
// Shows detailed object structure with properties and values
```

#### print_r() Function

The print_r() function offers a more readable output format but provides less type information:

```php
// Array
$user = [
    'id' => 1,
    'name' => 'John Doe',
    'email' => 'john@example.com'
];
print_r($user);
/* Output:
Array
(
    [id] => 1
    [name] => John Doe
    [email] => john@example.com
)
*/

// Capturing output as string
$output = print_r($user, true);
file_put_contents('debug.log', $output);
```

#### Enhanced Output Formatting

Improving readability of debug output:

```php
// Adding context to debug output
echo '<pre>';
var_dump($complexVariable);
echo '</pre>';

// Adding labels
echo '<h3>User Data:</h3><pre>';
print_r($userData);
echo '</pre>';

// Formatting for CLI
echo "DEBUG INFO:\n";
print_r($data);
echo "\n---------------------\n";
```

#### Conditional Debugging

Implementing controlled debugging output:

```php
// Debug flag
define('DEBUG_MODE', true);

function debug($var, $label = null) {
    if (!DEBUG_MODE) return;
    
    echo '<div style="background:#f1f1f1; padding:10px; margin:10px 0; border:1px solid #ccc;">';
    if ($label) {
        echo "<strong>$label:</strong> ";
    }
    echo '<pre>';
    var_dump($var);
    echo '</pre></div>';
}

// Usage
debug($user, 'User Object');
```

#### Helper Functions

Creating custom debugging functions:

```php
function dd($var) {
    echo '<pre>';
    var_dump($var);
    echo '</pre>';
    die(); // Stop execution
}

function debug_to_console($data) {
    $output = json_encode($data);
    echo "<script>console.log($output);</script>";
}

function log_debug($message, $data = null) {
    $log = date('Y-m-d H:i:s') . ' - ' . $message;
    if ($data !== null) {
        $log .= ' - ' . print_r($data, true);
    }
    file_put_contents('debug.log', $log . PHP_EOL, FILE_APPEND);
}
```

### Xdebug Installation and Configuration

Xdebug is a powerful PHP extension that provides advanced debugging features beyond basic variable inspection.

#### Installing Xdebug

Installation varies by platform:

**For Linux/Ubuntu:**

```bash
# Install PHP development package
sudo apt-get install php-dev

# Install Xdebug extension
sudo pecl install xdebug

# Find php.ini location
php --ini

# Add Xdebug configuration to php.ini
sudo echo "zend_extension=xdebug.so" >> /path/to/php.ini
```

**For Windows:**

1. Find your PHP version and thread safety setting:

```
php -i | findstr "PHP Version"
php -i | findstr "Thread Safety"
```

2. Download the appropriate DLL from https://xdebug.org/download
3. Add to php.ini:

```
zend_extension = "C:\path\to\php\ext\php_xdebug.dll"
```

**For macOS with Homebrew:**

```bash
brew install php@8.1
pecl install xdebug
```

#### Basic Xdebug Configuration

Essential Xdebug settings in php.ini:

```ini
[xdebug]
zend_extension=xdebug.so
xdebug.mode=develop,debug
xdebug.start_with_request=yes
xdebug.client_host=127.0.0.1
xdebug.client_port=9003
xdebug.idekey=PHPSTORM
xdebug.log="/path/to/xdebug.log"
```

#### Xdebug Modes

Xdebug 3.x introduced different operation modes:

```ini
; Step debugging
xdebug.mode=debug

; Profiling
xdebug.mode=profile
xdebug.output_dir="/tmp/xdebug"

; Code coverage
xdebug.mode=coverage

; Enhanced error reporting
xdebug.mode=develop

; Multiple modes
xdebug.mode=debug,develop,trace
```

#### Remote Debugging Setup

Configure Xdebug for remote debugging:

```ini
; For on-demand debugging (trigger with XDEBUG_SESSION cookie/param)
xdebug.start_with_request=trigger

; Start debugging for every request
xdebug.start_with_request=yes

; Configure remote host (usually localhost)
xdebug.client_host=127.0.0.1
xdebug.client_port=9003

; For Docker/VM environments, adjust client_host
xdebug.client_host=host.docker.internal
```

#### Browser Extensions for Xdebug

Browser extensions help trigger debugging sessions:

1. **Xdebug Helper for Chrome/Firefox**:
    
    - Easily toggle debug sessions
    - Configure IDE key to match your environment
    - Supports profiling and tracing modes
2. **Browser Bookmarklets**: Create bookmarklets with this JavaScript:
    
    ```javascript
    javascript:(function(){document.cookie='XDEBUG_SESSION=PHPSTORM;path=/;';})()
    ```
    

#### Command Line Debugging

Enable Xdebug for CLI scripts:

```bash
# Linux/macOS
XDEBUG_MODE=debug XDEBUG_SESSION=1 php script.php

# Windows
set XDEBUG_MODE=debug
set XDEBUG_SESSION=1
php script.php
```

#### Xdebug Functions

Useful Xdebug functions for manual debugging control:

```php
// Start debugger
xdebug_break();

// Get function stack
$stack = xdebug_get_function_stack();
print_r($stack);

// Start/stop profiling
xdebug_start_profiling();
// Code to profile
xdebug_stop_profiling();

// Measure code performance
$startTime = xdebug_time_index();
// Code to measure
$endTime = xdebug_time_index();
echo "Execution time: " . ($endTime - $startTime) . " seconds";
```

### Debugging Tools and IDEs

Modern IDEs provide integrated debugging tools that make PHP debugging more efficient and intuitive.

#### PhpStorm Debugging

PhpStorm offers comprehensive debugging features:

1. **Configuration Setup**:
    
    - Go to Settings → PHP → Debug
    - Configure Debug port (default: 9003)
    - Set Xdebug settings in PHP interpreter
2. **Start Debugging**:
    
    - Set breakpoints by clicking in the gutter
    - Click the "Start Listening for PHP Debug Connections" button
    - Run your application with Xdebug enabled
3. **Debugging Features**:
    
    - Step Into (F7): Move into function calls
    - Step Over (F8): Execute current line without diving into functions
    - Step Out (Shift+F8): Complete current function and return to caller
    - Run to Cursor (Alt+F9): Run until reaching current cursor position
    - Evaluate Expression (Alt+F8): Evaluate custom expressions during debugging
4. **Watches and Variables**:
    
    ```php
    $user = getUserData();     // Set breakpoint here
    $processed = process($user); // Inspect $user in variables panel
    ```
    

#### Visual Studio Code with PHP Debug Extension

VS Code with PHP Debug extension provides a lightweight alternative:

1. **Installation**:
    
    - Install PHP Debug extension by Felix Becker
    - Create launch.json configuration:
    
    ```json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Listen for Xdebug",
                "type": "php",
                "request": "launch",
                "port": 9003,
                "pathMappings": {
                    "/var/www/html": "${workspaceFolder}"
                }
            }
        ]
    }
    ```
    
2. **Debugging Features**:
    
    - Set breakpoints by clicking in the gutter
    - Use Debug panel to control execution flow
    - Inspect variables in the Variables panel
    - Add watch expressions for specific variables

#### Browser Developer Tools

Browser dev tools provide JavaScript debugging and network inspection:

```php
// Send data to browser console
echo '<script>console.log(' . json_encode($data) . ')</script>';

// More structured logging
echo '<script>
console.group("User Data");
console.log("Name:", ' . json_encode($user->name) . ');
console.log("Email:", ' . json_encode($user->email) . ');
console.groupEnd();
</script>';
```

#### Debugging in Laravel

Laravel includes powerful debugging tools:

1. **Dump and Die Functions**:
    
    ```php
    // Output and continue
    dump($variable);
    
    // Output and die
    dd($variable);
    
    // Output as table and die
    $users = User::all();
    dd($users->toArray());
    ```
    
2. **Laravel Telescope**: An elegant debug assistant:
    
    ```php
    // Install via Composer
    composer require laravel/telescope --dev
    
    // Publish assets
    php artisan telescope:install
    php artisan migrate
    
    // Access at /telescope to see:
    // - Requests, exceptions, logs, database queries
    // - Cache operations, queue jobs, scheduled tasks
    // - Model events and notifications
    ```
    
3. **Laravel Debugbar**: A development toolbar:
    
    ```php
    // Install via Composer
    composer require barryvdh/laravel-debugbar --dev
    
    // Publish assets (optional)
    php artisan vendor:publish --provider="Barryvdh\Debugbar\ServiceProvider"
    
    // Configure in .env
    DEBUGBAR_ENABLED=true
    
    // Manually log data
    Debugbar::info('Info message');
    Debugbar::error('Error message');
    Debugbar::warning('Warning message');
    Debugbar::addMeasure('Timing operation', $startTime, $endTime);
    ```
    

#### Symfony Debugging Tools

Symfony provides its own debugging ecosystem:

1. **VarDumper Component**:
    
    ```php
    // Install
    composer require symfony/var-dumper
    
    // Usage
    dump($variable);
    dd($variable); // Dump and die
    ```
    
2. **Symfony Profiler**:
    
    ```php
    // Install WebProfilerBundle
    composer require symfony/web-profiler-bundle --dev
    
    // Configure in config/packages/dev/web_profiler.yaml
    web_profiler:
        toolbar: true
        intercept_redirects: false
    
    // Access the profiler toolbar at the bottom of your page
    ```
    
3. **Symfony Debug Bundle**:
    
    ```php
    // Install
    composer require symfony/debug-bundle --dev
    
    // Automatically integrated - see dumps in profiler
    ```
    

### Advanced Debugging Techniques

#### Error Handling for Debugging

Customizing PHP error handling for debugging:

```php
// Set custom error handler
set_error_handler(function($errno, $errstr, $errfile, $errline) {
    echo "<div style='background-color:#ffcccc; padding:10px; margin:10px;'>";
    echo "<strong>Error [$errno]:</strong> $errstr<br>";
    echo "File: $errfile, Line: $errline";
    
    // Show backtrace for better context
    echo "<pre>";
    debug_print_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS);
    echo "</pre>";
    echo "</div>";
    
    // Don't execute PHP's internal error handler
    return true;
});

// Set exception handler
set_exception_handler(function($exception) {
    echo "<div style='background-color:#ffddcc; padding:10px; margin:10px;'>";
    echo "<strong>Uncaught Exception:</strong> " . $exception->getMessage() . "<br>";
    echo "File: " . $exception->getFile() . ", Line: " . $exception->getLine();
    echo "<pre>" . $exception->getTraceAsString() . "</pre>";
    echo "</div>";
});
```

#### Remote Debugging in Docker Environments

Configure Xdebug in containerized applications:

```dockerfile
# Dockerfile
FROM php:8.1-apache

# Install Xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Configure Xdebug
RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
```

```yaml
# docker-compose.yml
version: '3'
services:
  php:
    build: .
    ports:
      - "80:80"
    volumes:
      - ./src:/var/www/html
    environment:
      PHP_IDE_CONFIG: "serverName=DockerApp"
```

IDE configuration (PhpStorm):

1. Settings → PHP → Servers
2. Add server named "DockerApp"
3. Configure path mappings: local path → /var/www/html

#### Interactive Debugging with PsySH

PsySH is an interactive debugger and REPL for PHP:

```bash
# Install globally
composer global require psy/psysh

# Use in a project
composer require psy/psysh --dev
```

```php
// Use in code
$user = User::find(1);
eval(\Psy\sh());  // Opens interactive shell with current scope
```

#### Debugging API Requests

Tools for debugging API interactions:

```php
// Log API request and response
function callApi($url, $method, $data = []) {
    $startTime = microtime(true);
    
    $curl = curl_init();
    // curl configuration...
    
    // Execute and get response
    $response = curl_exec($curl);
    $info = curl_getinfo($curl);
    
    // Log request details
    $log = [
        'timestamp' => date('Y-m-d H:i:s'),
        'url' => $url,
        'method' => $method,
        'request_data' => $data,
        'response_code' => $info['http_code'],
        'response_time' => microtime(true) - $startTime,
        'response' => json_decode($response, true)
    ];
    
    file_put_contents('api_log.json', json_encode($log) . "\n", FILE_APPEND);
    
    return $response;
}
```

Using Guzzle with middleware for logging:

```php
use GuzzleHttp\Client;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Middleware;
use GuzzleHttp\MessageFormatter;

$stack = HandlerStack::create();

// Add middleware that logs requests and responses
$stack->push(
    Middleware::log(
        new \Monolog\Logger('api'),
        new MessageFormatter('{method} {uri} HTTP/{version} {req_body} => {code} {res_body}')
    )
);

$client = new Client([
    'handler' => $stack,
    'base_uri' => 'https://api.example.com',
]);

// Now all requests will be logged
$response = $client->request('GET', '/users');
```

#### Memory Debugging

Identifying and troubleshooting memory issues:

```php
// Track memory usage
$startMemory = memory_get_usage();

// Code to analyze
for ($i = 0; $i < 1000; $i++) {
    $arr[] = str_repeat('*', 1000);
}

$endMemory = memory_get_usage();
echo "Memory used: " . ($endMemory - $startMemory) . " bytes\n";

// Peak memory usage
echo "Peak memory usage: " . memory_get_peak_usage(true) . " bytes\n";

// Memory leak detection
function findMemoryLeaks($iterations = 10, $callback) {
    $baseline = memory_get_usage();
    $lastUsage = $baseline;
    
    echo "Starting memory: $baseline bytes\n";
    
    for ($i = 1; $i <= $iterations; $i++) {
        $callback();
        
        $currentUsage = memory_get_usage();
        $diff = $currentUsage - $lastUsage;
        
        echo "Iteration $i: $currentUsage bytes (";
        echo ($diff >= 0) ? "+" : "";
        echo "$diff bytes)\n";
        
        $lastUsage = $currentUsage;
    }
    
    echo "Total change: " . (memory_get_usage() - $baseline) . " bytes\n";
}

// Usage example
findMemoryLeaks(5, function() {
    // Function to test for memory leaks
    $data = generateLargeDataset();
    processData($data);
});
```

#### Xdebug Profiling

Using Xdebug for performance profiling:

```ini
; php.ini configuration
xdebug.mode=profile
xdebug.output_dir=/tmp/xdebug
xdebug.profiler_output_name=cachegrind.out.%p
```

Triggering profiles:

```bash
# Via URL
http://localhost/script.php?XDEBUG_PROFILE=1

# Via environment
XDEBUG_MODE=profile php script.php
```

Analyzing profiles:

1. Install KCachegrind (Linux/MacOS) or WinCachegrind (Windows)
2. Open the generated cachegrind.out.* file
3. Analyze function calls, execution time, and memory usage

#### Database Query Debugging

Tools for debugging database interactions:

```php
// Simple query logging
function logQuery($query, $params = []) {
    static $queryCount = 0;
    $queryCount++;
    
    $logEntry = [
        'query_num' => $queryCount,
        'time' => date('H:i:s'),
        'query' => $query,
        'params' => $params
    ];
    
    file_put_contents('queries.log', json_encode($logEntry) . "\n", FILE_APPEND);
}

// MySQL query profiling
$pdo->query("SET profiling = 1");
$pdo->query("YOUR QUERY HERE");
$result = $pdo->query("SHOW PROFILE");
print_r($result->fetchAll(PDO::FETCH_ASSOC));

// Database query debugging in Laravel
DB::enableQueryLog();
// Run some queries
$users = User::where('active', true)->get();
dd(DB::getQueryLog());
```

### Debugging Workflows and Best Practices

#### Systematic Debugging Process

Following a structured debugging approach:

1. **Reproduce the Issue**:
    
    - Create a minimal, reliable test case
    - Document exact steps to reproduce
    - Note environmental factors (PHP version, browser, etc.)
2. **Gather Information**:
    
    - Check error logs
    - Examine variable states at key points
    - Review recent code changes
3. **Form Hypotheses**:
    
    - Based on observed behavior, propose possible causes
    - Prioritize by likelihood and impact
4. **Test and Narrow Down**:
    
    - Add strategic debug statements
    - Use binary search approach (isolate half the code at a time)
    - Verify assumptions about variable values and flow
5. **Fix and Verify**:
    
    - Implement the fix
    - Test to confirm the issue is resolved
    - Add regression tests to prevent recurrence

#### Logging vs. Interactive Debugging

Choosing the right approach for different scenarios:

```php
// When to use logging:
// - Production environments
// - Intermittent issues
// - Performance problems
// - Long-running processes

// When to use interactive debugging:
// - Complex logic debugging
// - During active development
// - When variable states need inspection
// - For stepping through execution flow
```

#### Debug-Friendly Code Structure

Writing code that's easier to debug:

```php
// HARD TO DEBUG:
function process($data) {
    return doSomething(filterValues(transformInput($data)));
}

// MORE DEBUG-FRIENDLY:
function process($data) {
    $transformed = transformInput($data);
    $filtered = filterValues($transformed);
    $result = doSomething($filtered);
    return $result;
}
```

#### Debugging in Production

Safe techniques for production environments:

```php
// Toggle debug mode safely
$debugEnabled = $_SERVER['REMOTE_ADDR'] === '123.456.789.0'; // Developer's IP

// Conditional debug output to log file
if ($debugEnabled && $somethingFailed) {
    error_log('Debug info: ' . print_r($importantData, true));
}

// Log errors without exposing details to users
try {
    // Risky operation
} catch (Exception $e) {
    // For users
    echo "Sorry, an error occurred.";
    
    // For logs
    error_log('Error: ' . $e->getMessage() . ' in ' . $e->getFile() . ' on line ' . $e->getLine());
    error_log('Stack trace: ' . $e->getTraceAsString());
}
```

#### Debugging Third-Party Libraries

Strategies for debugging vendor code:

```php
// Temporarily modify vendor autoload to enable debugging
// In vendor/composer/autoload_real.php
public static function getLoader() {
    // Add at the beginning of the function:
    ini_set('xdebug.max_nesting_level', 500);
    
    // Rest of original function...
}

// Monkey patching for debugging
// Save original method
$originalMethod = [SomeVendorClass::class, 'methodName'];

// Replace with instrumented version
runkit_method_redefine(
    SomeVendorClass::class,
    'methodName',
    function($arg1, $arg2) use ($originalMethod) {
        echo "Method called with: ";
        var_dump($arg1, $arg2);
        
        $result = $originalMethod($arg1, $arg2);
        
        echo "Result: ";
        var_dump($result);
        
        return $result;
    }
);
```

**Conclusion**:

Effective PHP debugging requires a combination of techniques and tools tailored to specific scenarios. From simple var_dump() statements to advanced Xdebug configurations and IDE integrations, each approach has its place in a developer's toolkit. By implementing systematic debugging processes and utilizing the appropriate tools, developers can efficiently identify and resolve issues, resulting in more robust and reliable PHP applications. The key is to select the right debugging technique for each situation, balancing comprehensive analysis with development efficiency.

Related topics you might find useful:

- PHP Performance Optimization Techniques
- Automated Testing Strategies in PHP
- Error Logging and Monitoring Solutions
- Continuous Integration for PHP Projects

---

# PHP and APIs

## Consuming APIs in PHP

### Understanding APIs in PHP Context

PHP offers robust capabilities for interacting with external APIs, enabling developers to extend application functionality by leveraging third-party services. APIs (Application Programming Interfaces) provide standardized methods for different software applications to communicate with each other through well-defined requests and responses.

**Key Points**

- PHP can consume both REST and SOAP APIs
- Most modern APIs communicate using JSON, though XML is still common
- PHP provides multiple methods for making HTTP requests
- Proper error handling is essential when working with external services

### HTTP Requests with cURL

cURL (Client URL) is a library that allows making HTTP requests to other servers, making it the foundation for API consumption in PHP.

#### Basic cURL Implementation

```php
<?php
// Initialize a cURL session
$curl = curl_init();

// Set cURL options
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint",
    CURLOPT_RETURNTRANSFER => true,  // Return response instead of outputting
    CURLOPT_FOLLOWLOCATION => true,  // Follow redirects
    CURLOPT_TIMEOUT => 30,           // Timeout in seconds
    CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
    CURLOPT_CUSTOMREQUEST => "GET",  // HTTP method
]);

// Execute the request
$response = curl_exec($curl);
$err = curl_error($curl);

// Close cURL resource
curl_close($curl);

if ($err) {
    echo "cURL Error: " . $err;
} else {
    echo $response;
}
?>
```

#### Making Different HTTP Requests

cURL supports all common HTTP methods used in API interactions:

```php
<?php
// POST request
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_CUSTOMREQUEST => "POST",
    CURLOPT_POSTFIELDS => json_encode([
        "name" => "John Doe",
        "email" => "john@example.com"
    ]),
    CURLOPT_HTTPHEADER => [
        "Content-Type: application/json",
    ],
]);

// PUT request
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint/1",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_CUSTOMREQUEST => "PUT",
    CURLOPT_POSTFIELDS => json_encode([
        "name" => "Updated Name"
    ]),
    CURLOPT_HTTPHEADER => [
        "Content-Type: application/json",
    ],
]);

// DELETE request
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint/1",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_CUSTOMREQUEST => "DELETE",
]);
?>
```

#### Setting Request Headers

Headers are crucial for API communication, providing metadata about the request:

```php
<?php
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Content-Type: application/json",
        "Accept: application/json",
        "User-Agent: PHP/cURL",
        "Authorization: Bearer YOUR_ACCESS_TOKEN"
    ],
]);
?>
```

#### Error Handling and Debugging

Proper error handling is essential when working with external APIs:

```php
<?php
$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_VERBOSE => true,        // Enable verbose output for debugging
]);

$response = curl_exec($curl);
$err = curl_error($curl);
$info = curl_getinfo($curl);        // Get request info including HTTP status code
curl_close($curl);

if ($err) {
    echo "cURL Error: " . $err;
} elseif ($info['http_code'] >= 400) {
    echo "API Error: HTTP Code " . $info['http_code'];
} else {
    // Process successful response
    echo $response;
}
?>
```

### Working with JSON

JSON (JavaScript Object Notation) has become the standard data format for most modern APIs due to its lightweight nature and compatibility with JavaScript.

#### Decoding JSON Responses

```php
<?php
$curl = curl_init("https://api.example.com/users");
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($curl);
curl_close($curl);

// Convert JSON string to PHP array/object
$data = json_decode($response, true);  // true returns associative array, false returns object

if (json_last_error() !== JSON_ERROR_NONE) {
    echo "JSON Error: " . json_last_error_msg();
} else {
    // Access the data
    foreach ($data['users'] as $user) {
        echo $user['name'] . ": " . $user['email'] . "<br>";
    }
}
?>
```

#### Encoding PHP Arrays/Objects to JSON

```php
<?php
$userData = [
    'name' => 'John Doe',
    'email' => 'john@example.com',
    'roles' => ['admin', 'editor']
];

$jsonData = json_encode($userData, JSON_PRETTY_PRINT);

if (json_last_error() !== JSON_ERROR_NONE) {
    echo "JSON Encoding Error: " . json_last_error_msg();
} else {
    echo $jsonData;
    
    // Use in a POST request
    curl_setopt_array($curl, [
        CURLOPT_URL => "https://api.example.com/users",
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CUSTOMREQUEST => "POST",
        CURLOPT_POSTFIELDS => $jsonData,
        CURLOPT_HTTPHEADER => [
            "Content-Type: application/json",
            "Content-Length: " . strlen($jsonData)
        ],
    ]);
}
?>
```

#### JSON Error Handling

```php
<?php
function checkJsonError() {
    $error = json_last_error();
    if ($error !== JSON_ERROR_NONE) {
        $errorMessages = [
            JSON_ERROR_DEPTH => 'Maximum stack depth exceeded',
            JSON_ERROR_STATE_MISMATCH => 'Underflow or the modes mismatch',
            JSON_ERROR_CTRL_CHAR => 'Unexpected control character found',
            JSON_ERROR_SYNTAX => 'Syntax error, malformed JSON',
            JSON_ERROR_UTF8 => 'Malformed UTF-8 characters'
        ];
        
        return isset($errorMessages[$error]) 
            ? $errorMessages[$error] 
            : 'Unknown JSON error: ' . $error;
    }
    return null;
}

$data = json_decode($response, true);
if ($errorMsg = checkJsonError()) {
    throw new Exception("JSON Error: " . $errorMsg);
}
?>
```

### Working with XML

While JSON is more common, some APIs still use XML, especially legacy or enterprise systems. PHP offers multiple ways to work with XML.

#### SimpleXML for Reading XML

```php
<?php
$curl = curl_init("https://api.example.com/data.xml");
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($curl);
curl_close($curl);

// Parse XML string
try {
    $xml = new SimpleXMLElement($response);
    
    // Access XML data
    echo $xml->user->name . "<br>";
    echo $xml->user->email . "<br>";
    
    // Loop through elements
    foreach ($xml->users->user as $user) {
        echo $user->name . ": " . $user->email . "<br>";
    }
    
    // Access attributes
    echo $xml->product['id'] . ": " . $xml->product->name . "<br>";
    
} catch (Exception $e) {
    echo "XML Error: " . $e->getMessage();
}
?>
```

#### Creating XML with SimpleXML

```php
<?php
// Create a new XML document
$xml = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><request></request>');

// Add elements and attributes
$xml->addChild('action', 'create');
$user = $xml->addChild('user');
$user->addChild('name', 'John Doe');
$user->addChild('email', 'john@example.com');
$user->addAttribute('id', '123');

// Convert to string
$xmlString = $xml->asXML();

// Send XML in a request
$curl = curl_init("https://api.example.com/xmlapi");
curl_setopt_array($curl, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => $xmlString,
    CURLOPT_HTTPHEADER => [
        "Content-Type: application/xml",
        "Content-Length: " . strlen($xmlString)
    ],
]);
$response = curl_exec($curl);
curl_close($curl);
?>
```

#### DOMDocument for Complex XML Operations

```php
<?php
// Create an XML document
$dom = new DOMDocument('1.0', 'UTF-8');
$dom->formatOutput = true;

// Create elements
$root = $dom->createElement('request');
$dom->appendChild($root);

$action = $dom->createElement('action', 'update');
$root->appendChild($action);

$user = $dom->createElement('user');
$user->setAttribute('id', '123');
$root->appendChild($user);

$name = $dom->createElement('name', 'John Doe');
$user->appendChild($name);

$email = $dom->createElement('email', 'john@example.com');
$user->appendChild($email);

// Convert to string
$xmlString = $dom->saveXML();

// Use in API request
curl_setopt($curl, CURLOPT_POSTFIELDS, $xmlString);
?>
```

#### XML to Array Conversion

```php
<?php
function xml_to_array($xml) {
    $parser = xml_parser_create();
    xml_parser_set_option($parser, XML_OPTION_CASE_FOLDING, 0);
    xml_parser_set_option($parser, XML_OPTION_SKIP_WHITE, 1);
    xml_parse_into_struct($parser, $xml, $tags);
    xml_parser_free($parser);
    
    $elements = [];
    $stack = [];
    
    foreach ($tags as $tag) {
        $index = count($elements);
        
        if ($tag['type'] == "complete" || $tag['type'] == "open") {
            $elements[$index] = [
                'name' => $tag['tag'],
                'attributes' => isset($tag['attributes']) ? $tag['attributes'] : '',
                'content' => isset($tag['value']) ? $tag['value'] : '',
                'children' => []
            ];
            
            if ($tag['type'] == "open") {
                $stack[] = $index;
            }
        }
        
        if ($tag['type'] == "close") {
            $current = array_pop($stack);
            
            if (count($stack) > 0) {
                $parent = $stack[count($stack) - 1];
                $elements[$parent]['children'][] = $elements[$current];
                unset($elements[$current]);
            }
        }
    }
    
    return $elements[0];
}

$xmlString = '<response><user id="123"><name>John Doe</name><email>john@example.com</email></user></response>';
$arrayData = xml_to_array($xmlString);
?>
```

### API Authentication Methods

Most APIs require authentication to protect resources and identify users. PHP supports all common authentication methods.

#### API Key Authentication

The simplest form of authentication, typically passed in a header or query parameter:

```php
<?php
// API key in query string
$url = "https://api.example.com/data?api_key=YOUR_API_KEY";
$curl = curl_init($url);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($curl);
curl_close($curl);

// API key in header
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "X-API-Key: YOUR_API_KEY",
    ],
]);
?>
```

#### Basic Authentication

Uses HTTP's basic auth mechanism with username and password:

```php
<?php
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_USERPWD => "username:password", // Basic Auth credentials
]);

// Alternative method
$credentials = base64_encode("username:password");
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Authorization: Basic " . $credentials,
    ],
]);
?>
```

#### OAuth 1.0 Authentication

Used by some legacy APIs, requires signature generation:

```php
<?php
function generateOAuthSignature($method, $url, $params, $consumerSecret, $tokenSecret = '') {
    // Sort parameters alphabetically
    ksort($params);
    
    // Create parameter string
    $paramString = '';
    foreach ($params as $key => $value) {
        $paramString .= urlencode($key) . '=' . urlencode($value) . '&';
    }
    $paramString = rtrim($paramString, '&');
    
    // Create signature base string
    $baseString = strtoupper($method) . '&' . urlencode($url) . '&' . urlencode($paramString);
    
    // Create signing key
    $signingKey = urlencode($consumerSecret) . '&' . urlencode($tokenSecret);
    
    // Generate signature
    $signature = base64_encode(hash_hmac('sha1', $baseString, $signingKey, true));
    
    return $signature;
}

// OAuth 1.0 parameters
$oauthParams = [
    'oauth_consumer_key' => 'YOUR_CONSUMER_KEY',
    'oauth_nonce' => md5(uniqid(rand(), true)),
    'oauth_signature_method' => 'HMAC-SHA1',
    'oauth_timestamp' => time(),
    'oauth_token' => 'YOUR_ACCESS_TOKEN',
    'oauth_version' => '1.0'
];

// Generate signature
$signature = generateOAuthSignature(
    'GET', 
    'https://api.example.com/data', 
    $oauthParams, 
    'YOUR_CONSUMER_SECRET', 
    'YOUR_TOKEN_SECRET'
);

// Add signature to parameters
$oauthParams['oauth_signature'] = $signature;

// Create Authorization header
$authHeader = 'OAuth ';
foreach ($oauthParams as $key => $value) {
    $authHeader .= $key . '="' . urlencode($value) . '", ';
}
$authHeader = rtrim($authHeader, ', ');

// Make the request
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Authorization: " . $authHeader
    ],
]);
?>
```

#### OAuth 2.0 Authentication

The most common modern authentication flow, typically exchanging credentials for a token:

```php
<?php
// Step 1: Get authorization code (typically happens in browser with redirect)
$authUrl = "https://oauth.example.com/authorize?client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI&response_type=code&scope=read,write";
// User gets redirected to this URL, authenticates, and is returned to redirect_uri with code parameter

// Step 2: Exchange authorization code for access token
$code = $_GET['code'];  // Authorization code from redirect
$tokenUrl = "https://oauth.example.com/token";

$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => $tokenUrl,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => http_build_query([
        'grant_type' => 'authorization_code',
        'code' => $code,
        'client_id' => 'YOUR_CLIENT_ID',
        'client_secret' => 'YOUR_CLIENT_SECRET',
        'redirect_uri' => 'YOUR_REDIRECT_URI'
    ])
]);

$tokenResponse = curl_exec($curl);
curl_close($curl);
$tokenData = json_decode($tokenResponse, true);
$accessToken = $tokenData['access_token'];

// Step 3: Use access token in API requests
$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Authorization: Bearer " . $accessToken
    ],
]);
$response = curl_exec($curl);
curl_close($curl);
?>
```

#### Client Credential Flow (for Service-to-Service APIs)

```php
<?php
$tokenUrl = "https://oauth.example.com/token";

$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => $tokenUrl,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => http_build_query([
        'grant_type' => 'client_credentials',
        'client_id' => 'YOUR_CLIENT_ID',
        'client_secret' => 'YOUR_CLIENT_SECRET',
        'scope' => 'read write'
    ])
]);

$tokenResponse = curl_exec($curl);
curl_close($curl);
$tokenData = json_decode($tokenResponse, true);
$accessToken = $tokenData['access_token'];

// Use access token in API requests
?>
```

#### JWT (JSON Web Token) Authentication

```php
<?php
// Requires a JWT library like firebase/php-jwt
require 'vendor/autoload.php';
use Firebase\JWT\JWT;

// Create a JWT token
$key = "your_secret_key";
$payload = [
    "iss" => "your_app_name",
    "aud" => "api.example.com",
    "iat" => time(),
    "exp" => time() + 3600, // Expires in 1 hour
    "sub" => "user_id"
];

$jwt = JWT::encode($payload, $key, 'HS256');

// Use token in API request
$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Authorization: Bearer " . $jwt
    ],
]);
$response = curl_exec($curl);
curl_close($curl);
?>
```

### Creating an API Wrapper Class

For cleaner code and reusability, it's best to create a wrapper class for API interactions:

```php
<?php
class ApiClient {
    private $baseUrl;
    private $apiKey;
    private $accessToken;
    
    public function __construct($baseUrl, $apiKey = null, $accessToken = null) {
        $this->baseUrl = rtrim($baseUrl, '/');
        $this->apiKey = $apiKey;
        $this->accessToken = $accessToken;
    }
    
    public function setAccessToken($token) {
        $this->accessToken = $token;
    }
    
    private function getHeaders() {
        $headers = ["Accept: application/json"];
        
        if ($this->apiKey) {
            $headers[] = "X-API-Key: {$this->apiKey}";
        }
        
        if ($this->accessToken) {
            $headers[] = "Authorization: Bearer {$this->accessToken}";
        }
        
        return $headers;
    }
    
    private function request($method, $endpoint, $data = null) {
        $url = $this->baseUrl . "/" . ltrim($endpoint, '/');
        $curl = curl_init();
        
        $options = [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTPHEADER => $this->getHeaders(),
            CURLOPT_CUSTOMREQUEST => strtoupper($method)
        ];
        
        if ($data && in_array(strtoupper($method), ['POST', 'PUT', 'PATCH'])) {
            $jsonData = json_encode($data);
            $options[CURLOPT_POSTFIELDS] = $jsonData;
            $options[CURLOPT_HTTPHEADER][] = "Content-Type: application/json";
            $options[CURLOPT_HTTPHEADER][] = "Content-Length: " . strlen($jsonData);
        }
        
        curl_setopt_array($curl, $options);
        
        $response = curl_exec($curl);
        $httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
        $error = curl_error($curl);
        curl_close($curl);
        
        if ($error) {
            throw new Exception("cURL Error: " . $error);
        }
        
        $decodedResponse = json_decode($response, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            // Not JSON or invalid JSON
            return [
                'code' => $httpCode,
                'data' => $response
            ];
        }
        
        return [
            'code' => $httpCode,
            'data' => $decodedResponse
        ];
    }
    
    public function get($endpoint, $queryParams = []) {
        if (!empty($queryParams)) {
            $endpoint .= '?' . http_build_query($queryParams);
        }
        return $this->request('GET', $endpoint);
    }
    
    public function post($endpoint, $data) {
        return $this->request('POST', $endpoint, $data);
    }
    
    public function put($endpoint, $data) {
        return $this->request('PUT', $endpoint, $data);
    }
    
    public function patch($endpoint, $data) {
        return $this->request('PATCH', $endpoint, $data);
    }
    
    public function delete($endpoint) {
        return $this->request('DELETE', $endpoint);
    }
}

// Usage example
$api = new ApiClient('https://api.example.com/v1', 'your-api-key');

// Get users
$response = $api->get('users', ['limit' => 10]);
if ($response['code'] === 200) {
    $users = $response['data'];
    foreach ($users as $user) {
        echo $user['name'] . "<br>";
    }
}

// Create user
$newUser = [
    'name' => 'John Doe',
    'email' => 'john@example.com'
];
$response = $api->post('users', $newUser);

// Update user
$updatedData = ['name' => 'John Smith'];
$response = $api->put('users/123', $updatedData);

// Delete user
$response = $api->delete('users/123');
```

### Alternative HTTP Clients

While cURL is the most common method for API requests, PHP offers alternatives:

#### Using file_get_contents() with Stream Context

```php
<?php
// Simple GET request
$response = file_get_contents('https://api.example.com/data');

// More complex request with headers and method
$options = [
    'http' => [
        'method' => 'POST',
        'header' => [
            'Content-Type: application/json',
            'Authorization: Bearer YOUR_TOKEN'
        ],
        'content' => json_encode(['name' => 'John Doe']),
        'timeout' => 30
    ]
];

$context = stream_context_create($options);
$response = file_get_contents('https://api.example.com/users', false, $context);
$data = json_decode($response, true);
?>
```

#### Using Guzzle HTTP Client

Guzzle is a popular third-party HTTP client library that simplifies API requests:

```php
<?php
// Requires: composer require guzzlehttp/guzzle
require 'vendor/autoload.php';
use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;

// Create client
$client = new Client([
    'base_uri' => 'https://api.example.com/',
    'timeout' => 30,
    'headers' => [
        'Accept' => 'application/json',
        'Authorization' => 'Bearer YOUR_TOKEN'
    ]
]);

// GET request
try {
    $response = $client->get('users', [
        'query' => ['limit' => 10]
    ]);
    $data = json_decode($response->getBody(), true);
    
    foreach ($data['users'] as $user) {
        echo $user['name'] . "<br>";
    }
} catch (RequestException $e) {
    echo "Error: " . $e->getMessage();
}

// POST request
try {
    $response = $client->post('users', [
        'json' => [
            'name' => 'John Doe',
            'email' => 'john@example.com'
        ]
    ]);
    
    $statusCode = $response->getStatusCode();
    $data = json_decode($response->getBody(), true);
} catch (RequestException $e) {
    if ($e->hasResponse()) {
        $statusCode = $e->getResponse()->getStatusCode();
        echo "API Error: " . $statusCode;
    } else {
        echo "Connection Error: " . $e->getMessage();
    }
}
```

### Rate Limiting and Throttling

When working with APIs, it's important to respect rate limits:

```php
<?php
class RateLimitedApiClient {
    private $baseUrl;
    private $requestsPerMinute;
    private $requestTimes = [];
    
    public function __construct($baseUrl, $requestsPerMinute = 60) {
        $this->baseUrl = $baseUrl;
        $this->requestsPerMinute = $requestsPerMinute;
    }
    
    private function waitForRateLimit() {
        // Remove request times older than 1 minute
        $now = microtime(true);
        $this->requestTimes = array_filter(
            $this->requestTimes,
            function($time) use ($now) {
                return $now - $time < 60;
            }
        );
        
        // If we've reached the limit, wait
        if (count($this->requestTimes) >= $this->requestsPerMinute) {
            $oldestTime = min($this->requestTimes);
            $timeToWait = 60 - ($now - $oldestTime) + 0.1; // Add 0.1s buffer
            
            if ($timeToWait > 0) {
                usleep($timeToWait * 1000000); // Convert to microseconds
            }
        }
        
        // Add current request time
        $this->requestTimes[] = microtime(true);
    }
    
    public function get($endpoint) {
        $this->waitForRateLimit();
        
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL => $this->baseUrl . '/' . $endpoint,
            CURLOPT_RETURNTRANSFER => true
        ]);
        
        $response = curl_exec($curl);
        curl_close($curl);
        
        return json_decode($response, true);
    }
    
    // Additional methods for POST, PUT, etc.
}

$api = new RateLimitedApiClient('https://api.example.com', 30); // 30 requests per minute
?>
```

### Handling Pagination

Many APIs return paginated results, requiring multiple requests to fetch all data:

```php
<?php
function fetchAllPages($baseUrl, $endpoint, $headers = []) {
    $allResults = [];
    $page = 1;
    $hasMorePages = true;
    
    while ($hasMorePages) {
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL => $baseUrl . '/' . $endpoint . '?page=' . $page,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => $headers
        ]);
        
        $response = curl_exec($curl);
        curl_close($curl);
        
        $data = json_decode($response, true);
        
        if (!empty($data['results'])) {
            $allResults = array_merge($allResults, $data['results']);
            
            // Check if there are more pages
            if (isset($data['next_page']) && $data['next_page']) {
                $page++;
            } else {
                $hasMorePages = false;
            }
        } else {
            $hasMorePages = false;
        }
        
        // Avoid rate limiting
        sleep(1);
    }
    
    return $allResults;
}

$headers = [
    'Authorization: Bearer YOUR_TOKEN',
    'Accept: application/json'
];

$allUsers = fetchAllPages('https://api.example.com', 'users', $headers);
echo "Total users: " . count($allUsers);
?>
```

### Caching API Responses

To reduce API calls and improve performance, implement response caching:

```php
<?php
class CachedApiClient {
    private $baseUrl;
    private $token;
    private $cacheDir;
    private $cacheTTL;
    
    public function __construct($baseUrl, $token, $cacheDir = 'cache', $cacheTTL = 3600) {
        $this->baseUrl = $baseUrl;
        $this->token = $token;
        $this->cacheDir = $cacheDir;
        $this->cacheTTL = $cacheTTL;
        
        // Create cache directory if it doesn't exist
        if (!file_exists($this->cacheDir)) {
            mkdir($this->cacheDir, 0755, true);
        }
    }
    
    private function getCacheFilename($endpoint) {
        return $this->cacheDir . '/' . md5($endpoint) . '.json';
    }
    
    private function getFromCache($endpoint) {
        $cacheFile = $this->getCacheFilename($endpoint);
        
        if (file_exists($cacheFile)) {
            $fileTime = filemtime($cacheFile);
            
            // Check if cache is still valid
            if (time() - $fileTime < $this->cacheTTL) {
                return json_decode(file_get_contents($cacheFile), true);
            }
        }
        
        return null;
    }
    
    private function saveToCache($endpoint, $data) {
        $cacheFile = $this->getCacheFilename($endpoint);
        file_put_contents($cacheFile, json_encode($data));
    }
    
    public function get($endpoint, $params = [], $forceRefresh = false) {
        $url = $this->baseUrl . $endpoint;
        if (!empty($params)) {
            $url .= '?' . http_build_query($params);
        }
        
        // Try to get from cache if not forcing refresh
        if (!$forceRefresh) {
            $cachedData = $this->getFromCache($url);
            if ($cachedData !== null) {
                return $cachedData;
            }
        }
        
        // Make the API request
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $this->token,
            'Accept: application/json'
        ]);
        
        $response = curl_exec($ch);
        $statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($statusCode === 200) {
            $data = json_decode($response, true);
            $this->saveToCache($url, $data);
            return $data;
        }
        
        return null;
    }
}

// Usage example
$client = new CachedApiClient(
    'https://api.example.com/v1', 
    'your_api_token', 
    'api_cache', 
    1800 // 30 minutes TTL
);

// First call - will hit the API
$userData = $client->get('/users/123');

// Second call - will retrieve from cache
$sameUserData = $client->get('/users/123');

// Force refresh - will hit the API again
$refreshedUserData = $client->get('/users/123', [], true);
```

**Key Points:**

- File-based caching is simple but effective for many applications
- Each endpoint's response is cached with an MD5 hash as the filename
- The Time-To-Live (TTL) determines how long cached data remains valid
- Force refresh option allows bypassing the cache when needed

### Using PSR-6/PSR-16 Cache Libraries

For more robust caching, leverage standardized caching libraries:

```php
<?php
require 'vendor/autoload.php';

use Symfony\Component\Cache\Adapter\FilesystemAdapter;
use Symfony\Contracts\Cache\ItemInterface;

class PSR6ApiClient {
    private $baseUrl;
    private $token;
    private $cache;
    private $cacheTTL;
    
    public function __construct($baseUrl, $token, $cacheTTL = 3600) {
        $this->baseUrl = $baseUrl;
        $this->token = $token;
        $this->cacheTTL = $cacheTTL;
        $this->cache = new FilesystemAdapter('api_cache', $cacheTTL);
    }
    
    public function get($endpoint, $params = [], $forceRefresh = false) {
        $url = $this->baseUrl . $endpoint;
        if (!empty($params)) {
            $url .= '?' . http_build_query($params);
        }
        
        $cacheKey = 'api_' . md5($url);
        
        // Delete cache item if force refresh
        if ($forceRefresh) {
            $this->cache->delete($cacheKey);
        }
        
        return $this->cache->get($cacheKey, function (ItemInterface $item) use ($url) {
            $item->expiresAfter($this->cacheTTL);
            
            // Make the API request
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Authorization: Bearer ' . $this->token,
                'Accept: application/json'
            ]);
            
            $response = curl_exec($ch);
            $statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            if ($statusCode === 200) {
                return json_decode($response, true);
            }
            
            throw new \Exception("API request failed with status code: $statusCode");
        });
    }
}
```

### Error Handling and Retry Logic

Implement robust error handling and retry mechanisms for reliable API interactions:

```php
<?php
class ResilientApiClient {
    private $baseUrl;
    private $token;
    private $maxRetries;
    private $retryDelay;
    
    public function __construct($baseUrl, $token, $maxRetries = 3, $retryDelay = 1000) {
        $this->baseUrl = $baseUrl;
        $this->token = $token;
        $this->maxRetries = $maxRetries;
        $this->retryDelay = $retryDelay; // milliseconds
    }
    
    public function get($endpoint, $params = []) {
        $url = $this->baseUrl . $endpoint;
        if (!empty($params)) {
            $url .= '?' . http_build_query($params);
        }
        
        $retries = 0;
        $lastException = null;
        
        while ($retries <= $this->maxRetries) {
            try {
                return $this->executeRequest($url);
            } catch (\Exception $e) {
                $lastException = $e;
                
                // Only retry on certain status codes (server errors)
                $statusCode = $e->getCode();
                if ($statusCode < 500 && $statusCode !== 429) {
                    throw $e; // Don't retry client errors except rate limiting
                }
                
                $retries++;
                
                if ($retries <= $this->maxRetries) {
                    // Exponential backoff with jitter
                    $delay = $this->retryDelay * pow(2, $retries - 1);
                    $jitter = $delay * 0.2 * (mt_rand(0, 10) / 10);
                    usleep(($delay + $jitter) * 1000);
                }
            }
        }
        
        throw $lastException ?: new \Exception("Maximum retries exceeded");
    }
    
    private function executeRequest($url) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $this->token,
            'Accept: application/json'
        ]);
        
        $response = curl_exec($ch);
        $statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        
        if ($error) {
            throw new \Exception("cURL Error: $error");
        }
        
        if ($statusCode >= 400) {
            $errorData = json_decode($response, true);
            $message = isset($errorData['message']) ? $errorData['message'] : 'Unknown error';
            throw new \Exception($message, $statusCode);
        }
        
        return json_decode($response, true);
    }
}
```

**Key Points:**

- Implements exponential backoff with jitter for retries
- Differentiates between retryable errors (5xx, rate limit) and client errors (4xx)
- Preserves and rethrows the original exception when retries are exhausted

### Webhooks and Event Handling

Receive and process API events through webhooks:

```php
<?php
class WebhookHandler {
    private $secretKey;
    private $validSources;
    
    public function __construct($secretKey, array $validSources = []) {
        $this->secretKey = $secretKey;
        $this->validSources = $validSources;
    }
    
    public function handleRequest() {
        // Verify request source if IPs are specified
        if (!empty($this->validSources)) {
            $clientIP = $_SERVER['REMOTE_ADDR'];
            if (!in_array($clientIP, $this->validSources)) {
                $this->sendResponse(403, 'Forbidden');
                return;
            }
        }
        
        // Get and validate the payload
        $payload = file_get_contents('php://input');
        if (empty($payload)) {
            $this->sendResponse(400, 'Empty payload');
            return;
        }
        
        // Verify signature if provided
        if (isset($_SERVER['HTTP_X_WEBHOOK_SIGNATURE'])) {
            $providedSignature = $_SERVER['HTTP_X_WEBHOOK_SIGNATURE'];
            $calculatedSignature = hash_hmac('sha256', $payload, $this->secretKey);
            
            if (!hash_equals($calculatedSignature, $providedSignature)) {
                $this->sendResponse(401, 'Invalid signature');
                return;
            }
        }
        
        // Process the webhook data
        $data = json_decode($payload, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            $this->sendResponse(400, 'Invalid JSON payload');
            return;
        }
        
        // Process based on event type
        $eventType = isset($data['event']) ? $data['event'] : 'unknown';
        $result = $this->processEvent($eventType, $data);
        
        // Return response
        $this->sendResponse(200, 'Webhook processed', $result);
    }
    
    private function processEvent($eventType, $data) {
        switch ($eventType) {
            case 'payment.success':
                return $this->handlePaymentSuccess($data);
            
            case 'user.created':
                return $this->handleUserCreated($data);
            
            case 'subscription.updated':
                return $this->handleSubscriptionUpdated($data);
            
            default:
                return ['status' => 'ignored', 'reason' => 'Unknown event type'];
        }
    }
    
    private function handlePaymentSuccess($data) {
        // Process payment success
        $paymentId = $data['payment_id'] ?? null;
        
        // Update database, send confirmation emails, etc.
        // ...
        
        return [
            'status' => 'processed',
            'payment_id' => $paymentId
        ];
    }
    
    private function handleUserCreated($data) {
        // Process user creation event
        // ...
        
        return ['status' => 'processed'];
    }
    
    private function handleSubscriptionUpdated($data) {
        // Process subscription update
        // ...
        
        return ['status' => 'processed'];
    }
    
    private function sendResponse($statusCode, $message, $data = null) {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        
        $response = [
            'status' => $statusCode < 300 ? 'success' : 'error',
            'message' => $message
        ];
        
        if ($data !== null) {
            $response['data'] = $data;
        }
        
        echo json_encode($response);
        exit;
    }
}

// Usage
$webhook = new WebhookHandler(
    'your_webhook_secret_key',
    ['192.168.1.100', '203.0.113.0/24'] // Optional allowed IPs/ranges
);
$webhook->handleRequest();
```

### Asynchronous API Processing

For handling multiple API requests efficiently:

```php
<?php
require 'vendor/autoload.php';

use GuzzleHttp\Client;
use GuzzleHttp\Promise;

class AsyncApiClient {
    private $client;
    private $baseUrl;
    private $token;
    
    public function __construct($baseUrl, $token) {
        $this->baseUrl = $baseUrl;
        $this->token = $token;
        
        $this->client = new Client([
            'base_uri' => $baseUrl,
            'headers' => [
                'Authorization' => 'Bearer ' . $token,
                'Accept' => 'application/json'
            ]
        ]);
    }
    
    public function fetchMultiple(array $endpoints) {
        $promises = [];
        
        foreach ($endpoints as $key => $endpoint) {
            $promises[$key] = $this->client->getAsync($endpoint);
        }
        
        // Wait for all requests to complete
        $responses = Promise\Utils::settle($promises)->wait();
        $results = [];
        
        foreach ($responses as $key => $response) {
            if ($response['state'] === 'fulfilled') {
                $results[$key] = json_decode($response['value']->getBody(), true);
            } else {
                $results[$key] = [
                    'error' => true,
                    'message' => $response['reason']->getMessage()
                ];
            }
        }
        
        return $results;
    }
    
    public function batchProcess(array $items, $endpoint, $batchSize = 10) {
        $chunks = array_chunk($items, $batchSize);
        $results = [];
        
        foreach ($chunks as $chunk) {
            $promises = [];
            
            foreach ($chunk as $index => $item) {
                $promises[$index] = $this->client->postAsync($endpoint, [
                    'json' => $item
                ]);
            }
            
            // Process batch and collect results
            $responses = Promise\Utils::settle($promises)->wait();
            
            foreach ($responses as $index => $response) {
                if ($response['state'] === 'fulfilled') {
                    $results[] = json_decode($response['value']->getBody(), true);
                } else {
                    $results[] = [
                        'error' => true,
                        'item' => $items[$index],
                        'message' => $response['reason']->getMessage()
                    ];
                }
            }
        }
        
        return $results;
    }
}

// Usage examples
$client = new AsyncApiClient('https://api.example.com/v1/', 'your_api_token');

// Fetch multiple endpoints in parallel
$userIds = [123, 456, 789];
$endpoints = array_map(function($id) { 
    return "/users/$id"; 
}, $userIds);

$userData = $client->fetchMultiple($endpoints);

// Process batch of items
$products = [
    ['id' => 1, 'name' => 'Product 1', 'price' => 19.99],
    ['id' => 2, 'name' => 'Product 2', 'price' => 29.99],
    // ... more products
];

$results = $client->batchProcess($products, '/products/update');
```

### API Testing and Documentation

Create test cases for your API integrations:

```php
<?php
use PHPUnit\Framework\TestCase;

class WeatherApiTest extends TestCase {
    private $apiClient;
    private $mockHandler;
    
    protected function setUp(): void {
        // Create mock handler for testing
        $this->mockHandler = new \GuzzleHttp\Handler\MockHandler();
        $handlerStack = \GuzzleHttp\HandlerStack::create($this->mockHandler);
        
        $client = new \GuzzleHttp\Client(['handler' => $handlerStack]);
        
        // Inject mocked client into API client
        $this->apiClient = new WeatherApiClient('fake_api_key');
        $this->apiClient->setHttpClient($client);
    }
    
    public function testGetCurrentWeatherSuccess() {
        // Mock successful response
        $mockResponse = new \GuzzleHttp\Psr7\Response(200, [], json_encode([
            'location' => [
                'name' => 'New York',
                'country' => 'USA'
            ],
            'current' => [
                'temp_c' => 22.5,
                'condition' => [
                    'text' => 'Sunny',
                    'icon' => '//cdn.example.com/sunny.png'
                ]
            ]
        ]));
        
        $this->mockHandler->append($mockResponse);
        
        $result = $this->apiClient->getCurrentWeather('New York');
        
        $this->assertEquals('New York', $result['location']['name']);
        $this->assertEquals(22.5, $result['current']['temp_c']);
        $this->assertEquals('Sunny', $result['current']['condition']['text']);
    }
    
    public function testGetCurrentWeatherError() {
        // Mock error response
        $mockResponse = new \GuzzleHttp\Psr7\Response(401, [], json_encode([
            'error' => [
                'code' => 1002,
                'message' => 'API key invalid'
            ]
        ]));
        
        $this->mockHandler->append($mockResponse);
        
        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('API key invalid');
        
        $this->apiClient->getCurrentWeather('New York');
    }
    
    public function testRateLimitHandling() {
        // Mock rate limit response
        $mockResponse = new \GuzzleHttp\Psr7\Response(429, [
            'Retry-After' => '30'
        ], json_encode([
            'error' => 'Rate limit exceeded'
        ]));
        
        $this->mockHandler->append($mockResponse);
        
        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('Rate limit exceeded. Try again in 30 seconds');
        
        $this->apiClient->getCurrentWeather('New York');
    }
}
```

### GraphQL API Consumption

Working with GraphQL APIs:

```php
<?php
class GraphQLClient {
    private $endpoint;
    private $headers;
    
    public function __construct($endpoint, $token = null) {
        $this->endpoint = $endpoint;
        $this->headers = [
            'Content-Type: application/json',
            'Accept: application/json'
        ];
        
        if ($token) {
            $this->headers[] = 'Authorization: Bearer ' . $token;
        }
    }
    
    public function query($query, $variables = []) {
        $data = [
            'query' => $query,
            'variables' => $variables
        ];
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $this->endpoint);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        curl_setopt($ch, CURLOPT_HTTPHEADER, $this->headers);
        
        $response = curl_exec($ch);
        $statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($statusCode !== 200) {
            throw new \Exception("GraphQL request failed with status code: $statusCode");
        }
        
        $result = json_decode($response, true);
        
        if (isset($result['errors'])) {
            $errorMessage = $result['errors'][0]['message'] ?? 'Unknown GraphQL error';
            throw new \Exception("GraphQL error: $errorMessage");
        }
        
        return $result['data'];
    }
}

// Usage example
$client = new GraphQLClient(
    'https://api.github.com/graphql',
    'your_github_token'
);

// Query repositories
$query = <<<'GRAPHQL'
query ($username: String!, $count: Int!) {
  user(login: $username) {
    repositories(first: $count, orderBy: {field: STARGAZERS, direction: DESC}) {
      nodes {
        name
        description
        stargazers {
          totalCount
        }
        primaryLanguage {
          name
        }
      }
    }
  }
}
GRAPHQL;

$variables = [
    'username' => 'octocat',
    'count' => 5
];

try {
    $result = $client->query($query, $variables);
    
    $repositories = $result['user']['repositories']['nodes'];
    foreach ($repositories as $repo) {
        echo "Repository: {$repo['name']}\n";
        echo "Description: {$repo['description']}\n";
        echo "Stars: {$repo['stargazers']['totalCount']}\n";
        echo "Language: {$repo['primaryLanguage']['name'] ?? 'N/A'}\n";
        echo "-----------------------------------\n";
    }
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage();
}
```

### Real-World API Integration Example

A complete integration with a payment gateway API:

```php
<?php
class StripePaymentGateway {
    private $client;
    private $apiKey;
    
    public function __construct($apiKey, $isTest = false) {
        $this->apiKey = $apiKey;
        $this->baseUrl = $isTest ? 
            'https://api.stripe.com/v1/test/' : 
            'https://api.stripe.com/v1/';
        
        $this->client = new \GuzzleHttp\Client([
            'base_uri' => $this->baseUrl,
            'headers' => [
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/x-www-form-urlencoded',
                'Stripe-Version' => '2020-08-27'
            ]
        ]);
    }
    
    public function createCustomer($email, $name, $metadata = []) {
        try {
            $response = $this->client->post('customers', [
                'form_params' => [
                    'email' => $email,
                    'name' => $name,
                    'metadata' => $metadata
                ]
            ]);
            
            return json_decode($response->getBody(), true);
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            $this->handleApiError($e);
        }
    }
    
    public function createPaymentIntent($amount, $currency, $customerId, $paymentMethodId = null) {
        try {
            $params = [
                'amount' => $amount, // Amount in cents
                'currency' => $currency,
                'customer' => $customerId,
                'confirmation_method' => 'automatic',
                'confirm' => $paymentMethodId ? true : false,
            ];
            
            if ($paymentMethodId) {
                $params['payment_method'] = $paymentMethodId;
            }
            
            $response = $this->client->post('payment_intents', [
                'form_params' => $params
            ]);
            
            return json_decode($response->getBody(), true);
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            $this->handleApiError($e);
        }
    }
    
    public function confirmPaymentIntent($paymentIntentId, $paymentMethodId) {
        try {
            $response = $this->client->post("payment_intents/{$paymentIntentId}/confirm", [
                'form_params' => [
                    'payment_method' => $paymentMethodId
                ]
            ]);
            
            return json_decode($response->getBody(), true);
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            $this->handleApiError($e);
        }
    }
    
    public function retrievePaymentIntent($paymentIntentId) {
        try {
            $response = $this->client->get("payment_intents/{$paymentIntentId}");
            return json_decode($response->getBody(), true);
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            $this->handleApiError($e);
        }
    }
    
    public function createSubscription($customerId, $priceId) {
        try {
            $response = $this->client->post('subscriptions', [
                'form_params' => [
                    'customer' => $customerId,
                    'items' => [
                        ['price' => $priceId]
                    ]
                ]
            ]);
            
            return json_decode($response->getBody(), true);
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            $this->handleApiError($e);
        }
    }
    
    private function handleApiError($exception) {
        if ($exception instanceof \GuzzleHttp\Exception\ClientException) {
            $response = $exception->getResponse();
            $error = json_decode($response->getBody(), true);
            
            throw new \Exception(
                $error['error']['message'] ?? 'Unknown Stripe error',
                $response->getStatusCode()
            );
        }
        
        throw new \Exception('Payment gateway communication error: ' . $exception->getMessage());
    }
}

// Usage example:
$gateway = new StripePaymentGateway('sk_test_your_test_key', true);

try {
    // Create a customer
    $customer = $gateway->createCustomer(
        'customer@example.com',
        'John Doe',
        ['user_id' => '123456']
    );
    
    // Create a payment intent
    $paymentIntent = $gateway->createPaymentIntent(
        2500, // $25.00
        'usd',
        $customer['id']
    );
    
    // The client would use the payment intent's client_secret to collect payment method details
    $clientSecret = $paymentIntent['client_secret'];
    
    // After collecting payment details on the client:
    $confirmedPayment = $gateway->confirmPaymentIntent(
        $paymentIntent['id'],
        'pm_card_visa' // In production, this would be a real payment method ID
    );
    
    if ($confirmedPayment['status'] === 'succeeded') {
        echo "Payment completed successfully!";
    } else if ($confirmedPayment['status'] === 'requires_action') {
        // Handle 3D Secure or other authentication
        echo "Additional authentication required";
    }
    
} catch (\Exception $e) {
    echo "Payment error: " . $e->getMessage();
}
```

**Conclusion**

Effectively consuming APIs in PHP requires mastering HTTP requests, data format handling, authentication methods, and implementing best practices for caching, error handling, and testing. Structured API integration enables reliable communication with external services, enhancing your applications with third-party capabilities while maintaining performance and security. As APIs evolve, keeping your implementation patterns modular and testable allows for easier maintenance and adaptation to changing requirements.

**Related Topics**

- RESTful API design principles
- API versioning strategies
- OAuth 2.0 and OpenID Connect implementation
- API documentation tools like Swagger/OpenAPI
- API gateway patterns and implementation
- Microservices architecture and communication
- Event-driven architecture with webhooks

---

## Creating RESTful APIs in PHP

### Understanding REST Principles

REST (Representational State Transfer) is an architectural style for designing networked applications. RESTful APIs use HTTP requests to perform CRUD (Create, Read, Update, Delete) operations on resources, making them intuitive and widely compatible.

**Key Points**

- REST is stateless - each request must contain all information needed to process it
- Resources are identified by URIs (Uniform Resource Identifiers)
- HTTP methods (GET, POST, PUT, DELETE) map to CRUD operations
- Responses typically use standard formats like JSON or XML
- REST emphasizes scalability, simplicity, and separation of concerns

#### Core REST Principles

1. **Client-Server Architecture**: Separates client concerns from server concerns
2. **Statelessness**: No client context stored on the server between requests
3. **Cacheability**: Responses must define themselves as cacheable or non-cacheable
4. **Layered System**: Client cannot tell if connected directly to end server
5. **Uniform Interface**: Resources are identified in requests and manipulated through representations
6. **Code on Demand** (optional): Servers can temporarily extend client functionality

#### HTTP Methods in REST

- **GET**: Retrieve a resource (read-only)
- **POST**: Create a new resource
- **PUT**: Update an existing resource (complete replacement)
- **PATCH**: Partially update a resource
- **DELETE**: Remove a resource
- **OPTIONS**: Discover supported operations on a resource
- **HEAD**: Retrieve metadata about a resource without the body

### Designing API Endpoints

Well-designed API endpoints are crucial for usability, maintainability, and performance. They should be intuitive, consistent, and follow REST conventions.

- Use nouns, not verbs for resources (e.g., `/users` not `/getUsers`)
- Use plural nouns for collections (e.g., `/users` not `/user`)
- Use nested resources for relationships (e.g., `/users/123/orders`)
- Include API versioning (e.g., `/v1/users`)
- Keep URLs consistent and intuitive
- Use query parameters for filtering, sorting, and pagination

#### Endpoint Naming Conventions

```
# Resource collections (plural nouns)
GET /api/users       # Get all users
POST /api/users      # Create a new user

# Specific resources (with identifier)
GET /api/users/123   # Get user with ID 123
PUT /api/users/123   # Update user with ID 123
DELETE /api/users/123 # Delete user with ID 123

# Nested resources
GET /api/users/123/orders      # Get orders for user 123
POST /api/users/123/orders     # Create order for user 123
GET /api/users/123/orders/456  # Get specific order 456 for user 123
```

#### Resource Hierarchy

Structure resources hierarchically when there are parent-child relationships:

```
/api/companies
/api/companies/{companyId}
/api/companies/{companyId}/departments
/api/companies/{companyId}/departments/{departmentId}
/api/companies/{companyId}/departments/{departmentId}/employees
```

#### Query Parameters for Filtering, Sorting, and Pagination

```
# Filtering
/api/products?category=electronics&price_min=100&price_max=500

# Sorting
/api/products?sort=price_asc
/api/products?sort=name_desc

# Pagination
/api/products?page=2&limit=20
/api/products?offset=40&limit=20
```

#### Versioning Strategies

```
# URL path versioning
/api/v1/users
/api/v2/users

# Query parameter versioning
/api/users?version=1

# Header versioning
# Custom header: API-Version: 1
# Accept header: Accept: application/vnd.company.v1+json
```

### Building a Basic RESTful API in PHP

#### Directory Structure

```
/api
  /v1
    index.php       # Main router
    config.php      # Configuration
    /controllers
      UserController.php
      ProductController.php
    /models
      User.php
      Product.php
    /helpers
      Response.php
      Database.php
    /middleware
      Authentication.php
      RateLimit.php
```

#### The Router (index.php)

```php
<?php
// Enable error reporting during development
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Allow CORS for API
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Include configuration and helper files
require_once 'config.php';
require_once 'helpers/Response.php';
require_once 'helpers/Database.php';

// Include controllers
require_once 'controllers/UserController.php';
require_once 'controllers/ProductController.php';

// Parse request
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = explode('/', $uri);

// Extract API version and resource from URI
$apiVersion = isset($uri[2]) ? $uri[2] : null;  // e.g., "v1"
$resource = isset($uri[3]) ? $uri[3] : null;    // e.g., "users"
$id = isset($uri[4]) ? $uri[4] : null;          // e.g., "123"
$subresource = isset($uri[5]) ? $uri[5] : null; // e.g., "orders"

// Ensure we're using the correct API version
if ($apiVersion !== 'v1') {
    Response::json(['error' => 'API version not supported'], 400);
    exit;
}

// Get request method
$method = $_SERVER['REQUEST_METHOD'];

// Get request body for POST, PUT, PATCH requests
$data = null;
if (in_array($method, ['POST', 'PUT', 'PATCH'])) {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    // Check for valid JSON
    if ($input && !$data) {
        Response::json(['error' => 'Invalid JSON provided'], 400);
        exit;
    }
}

// Route request to appropriate controller
try {
    // Connect to database
    $db = new Database();
    $conn = $db->getConnection();
    
    // Handle user resource
    if ($resource === 'users') {
        $controller = new UserController($conn);
        
        switch ($method) {
            case 'GET':
                if ($id) {
                    if ($subresource === 'orders') {
                        $controller->getUserOrders($id);
                    } else {
                        $controller->getUser($id);
                    }
                } else {
                    $controller->getAllUsers();
                }
                break;
            case 'POST':
                if ($id && $subresource === 'orders') {
                    $controller->createUserOrder($id, $data);
                } else {
                    $controller->createUser($data);
                }
                break;
            case 'PUT':
                if ($id) {
                    $controller->updateUser($id, $data);
                } else {
                    Response::json(['error' => 'User ID required'], 400);
                }
                break;
            case 'DELETE':
                if ($id) {
                    $controller->deleteUser($id);
                } else {
                    Response::json(['error' => 'User ID required'], 400);
                }
                break;
            default:
                Response::json(['error' => 'Method not allowed'], 405);
        }
    }
    // Handle product resource
    else if ($resource === 'products') {
        $controller = new ProductController($conn);
        
        switch ($method) {
            case 'GET':
                if ($id) {
                    $controller->getProduct($id);
                } else {
                    $controller->getAllProducts();
                }
                break;
            case 'POST':
                $controller->createProduct($data);
                break;
            case 'PUT':
                if ($id) {
                    $controller->updateProduct($id, $data);
                } else {
                    Response::json(['error' => 'Product ID required'], 400);
                }
                break;
            case 'DELETE':
                if ($id) {
                    $controller->deleteProduct($id);
                } else {
                    Response::json(['error' => 'Product ID required'], 400);
                }
                break;
            default:
                Response::json(['error' => 'Method not allowed'], 405);
        }
    }
    // Resource not found
    else {
        Response::json(['error' => 'Resource not found'], 404);
    }
} catch (Exception $e) {
    Response::json(['error' => $e->getMessage()], 500);
}
?>
```

#### Helper Classes

Response Helper:

```php
<?php
class Response {
    /**
     * Send JSON response with appropriate headers
     * 
     * @param mixed $data The data to be encoded as JSON
     * @param int $statusCode HTTP status code
     * @return void
     */
    public static function json($data, $statusCode = 200) {
        header('Content-Type: application/json');
        http_response_code($statusCode);
        echo json_encode($data, JSON_PRETTY_PRINT);
        exit;
    }
    
    /**
     * Send error response
     * 
     * @param string $message Error message
     * @param int $statusCode HTTP status code
     * @return void
     */
    public static function error($message, $statusCode = 400) {
        self::json(['error' => $message], $statusCode);
    }
    
    /**
     * Send success response
     * 
     * @param mixed $data The data to be included in response
     * @param string $message Success message
     * @return void
     */
    public static function success($data, $message = 'Success') {
        self::json([
            'status' => 'success',
            'message' => $message,
            'data' => $data
        ]);
    }
    
    /**
     * Send paginated response
     * 
     * @param array $items Items for current page
     * @param int $total Total number of items
     * @param int $page Current page number
     * @param int $limit Items per page
     * @return void
     */
    public static function paginate($items, $total, $page, $limit) {
        $totalPages = ceil($total / $limit);
        
        self::json([
            'data' => $items,
            'meta' => [
                'total' => $total,
                'page' => $page,
                'limit' => $limit,
                'total_pages' => $totalPages,
                'has_next_page' => $page < $totalPages,
                'has_prev_page' => $page > 1
            ]
        ]);
    }
}
?>
```

Database Helper:

```php
<?php
class Database {
    private $host = 'localhost';
    private $db_name = 'api_database';
    private $username = 'username';
    private $password = 'password';
    private $conn;
    
    /**
     * Connect to database
     * 
     * @return PDO
     */
    public function getConnection() {
        $this->conn = null;
        
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name,
                $this->username,
                $this->password
            );
            $this->conn->exec("SET NAMES utf8");
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch(PDOException $e) {
            throw new Exception("Database connection error: " . $e->getMessage());
        }
        
        return $this->conn;
    }
}
?>
```

#### Controller Example

```php
<?php
class UserController {
    private $conn;
    private $table = 'users';
    
    public function __construct($db) {
        $this->conn = $db;
    }
    
    /**
     * Get all users with pagination
     * 
     * @return void
     */
    public function getAllUsers() {
        try {
            // Parse pagination parameters
            $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
            $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
            $offset = ($page - 1) * $limit;
            
            // Get total count
            $countQuery = "SELECT COUNT(*) as total FROM " . $this->table;
            $countStmt = $this->conn->prepare($countQuery);
            $countStmt->execute();
            $total = $countStmt->fetchColumn();
            
            // Get users for current page
            $query = "SELECT id, name, email, created_at FROM " . $this->table . 
                     " ORDER BY id DESC LIMIT :limit OFFSET :offset";
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();
            
            $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Return paginated response
            Response::paginate($users, $total, $page, $limit);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
    
    /**
     * Get single user by ID
     * 
     * @param int $id User ID
     * @return void
     */
    public function getUser($id) {
        try {
            $query = "SELECT id, name, email, created_at FROM " . $this->table . 
                     " WHERE id = :id";
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':id', $id);
            $stmt->execute();
            
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($user) {
                Response::json($user);
            } else {
                Response::error("User not found", 404);
            }
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
    
    /**
     * Create new user
     * 
     * @param array $data User data
     * @return void
     */
    public function createUser($data) {
        try {
            // Validate required fields
            if (!isset($data['name']) || !isset($data['email']) || !isset($data['password'])) {
                Response::error("Missing required fields: name, email, password", 400);
                return;
            }
            
            // Validate email
            if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
                Response::error("Invalid email format", 400);
                return;
            }
            
            // Check if email already exists
            $checkQuery = "SELECT id FROM " . $this->table . " WHERE email = :email";
            $checkStmt = $this->conn->prepare($checkQuery);
            $checkStmt->bindParam(':email', $data['email']);
            $checkStmt->execute();
            
            if ($checkStmt->rowCount() > 0) {
                Response::error("Email already exists", 409);
                return;
            }
            
            // Insert new user
            $query = "INSERT INTO " . $this->table . 
                     " (name, email, password, created_at) VALUES " .
                     " (:name, :email, :password, NOW())";
            
            $stmt = $this->conn->prepare($query);
            
            // Hash the password
            $password_hash = password_hash($data['password'], PASSWORD_BCRYPT);
            
            // Bind parameters
            $stmt->bindParam(':name', $data['name']);
            $stmt->bindParam(':email', $data['email']);
            $stmt->bindParam(':password', $password_hash);
            
            if ($stmt->execute()) {
                $id = $this->conn->lastInsertId();
                
                // Return the created user (without password)
                Response::json([
                    'id' => $id,
                    'name' => $data['name'],
                    'email' => $data['email'],
                    'created_at' => date('Y-m-d H:i:s')
                ], 201);
            } else {
                Response::error("Failed to create user", 500);
            }
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
    
    /**
     * Update existing user
     * 
     * @param int $id User ID
     * @param array $data User data
     * @return void
     */
    public function updateUser($id, $data) {
        try {
            // Check if user exists
            $checkQuery = "SELECT id FROM " . $this->table . " WHERE id = :id";
            $checkStmt = $this->conn->prepare($checkQuery);
            $checkStmt->bindParam(':id', $id);
            $checkStmt->execute();
            
            if ($checkStmt->rowCount() === 0) {
                Response::error("User not found", 404);
                return;
            }
            
            // Build update query based on provided fields
            $updateFields = [];
            $queryParams = [':id' => $id];
            
            if (isset($data['name'])) {
                $updateFields[] = "name = :name";
                $queryParams[':name'] = $data['name'];
            }
            
            if (isset($data['email'])) {
                // Validate email
                if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
                    Response::error("Invalid email format", 400);
                    return;
                }
                
                // Check if email already exists for another user
                $emailCheckQuery = "SELECT id FROM " . $this->table . 
                                  " WHERE email = :email AND id != :user_id";
                $emailCheckStmt = $this->conn->prepare($emailCheckQuery);
                $emailCheckStmt->bindParam(':email', $data['email']);
                $emailCheckStmt->bindParam(':user_id', $id);
                $emailCheckStmt->execute();
                
                if ($emailCheckStmt->rowCount() > 0) {
                    Response::error("Email already exists", 409);
                    return;
                }
                
                $updateFields[] = "email = :email";
                $queryParams[':email'] = $data['email'];
            }
            
            if (isset($data['password'])) {
                $updateFields[] = "password = :password";
                $queryParams[':password'] = password_hash($data['password'], PASSWORD_BCRYPT);
            }
            
            // If no fields to update
            if (empty($updateFields)) {
                Response::error("No fields to update", 400);
                return;
            }
            
            // Execute update query
            $query = "UPDATE " . $this->table . " SET " . implode(", ", $updateFields) . 
                     " WHERE id = :id";
            
            $stmt = $this->conn->prepare($query);
            $stmt->execute($queryParams);
            
            // Get updated user
            $this->getUser($id);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
    
    /**
     * Delete user
     * 
     * @param int $id User ID
     * @return void
     */
    public function deleteUser($id) {
        try {
            // Check if user exists
            $checkQuery = "SELECT id FROM " . $this->table . " WHERE id = :id";
            $checkStmt = $this->conn->prepare($checkQuery);
            $checkStmt->bindParam(':id', $id);
            $checkStmt->execute();
            
            if ($checkStmt->rowCount() === 0) {
                Response::error("User not found", 404);
                return;
            }
            
            // Delete user
            $query = "DELETE FROM " . $this->table . " WHERE id = :id";
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':id', $id);
            
            if ($stmt->execute()) {
                Response::json(['message' => 'User deleted successfully'], 200);
            } else {
                Response::error("Failed to delete user", 500);
            }
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
    
    /**
     * Get user's orders
     * 
     * @param int $userId User ID
     * @return void
     */
    public function getUserOrders($userId) {
        try {
            // Check if user exists
            $checkQuery = "SELECT id FROM " . $this->table . " WHERE id = :id";
            $checkStmt = $this->conn->prepare($checkQuery);
            $checkStmt->bindParam(':id', $userId);
            $checkStmt->execute();
            
            if ($checkStmt->rowCount() === 0) {
                Response::error("User not found", 404);
                return;
            }
            
            // Get orders
            $query = "SELECT id, user_id, total_amount, status, created_at " . 
                     "FROM orders WHERE user_id = :user_id ORDER BY created_at DESC";
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':user_id', $userId);
            $stmt->execute();
            
            $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            Response::json($orders);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
}
?>
```

### Response Formatting

Proper response formatting ensures your API is consistent, predictable, and easy to use. Standard formats help clients easily process and understand responses.

#### JSON Response Structure

```php
<?php
// Basic response structure
$response = [
    'status' => 'success', // or 'error'
    'message' => 'Operation completed successfully',
    'data' => [
        // Resource data here
    ]
];

// Error response
$errorResponse = [
    'status' => 'error',
    'message' => 'Invalid input parameters',
    'errors' => [
        'email' => 'Email is required',
        'password' => 'Password must be at least 8 characters'
    ]
];

// Collection response with pagination
$paginatedResponse = [
    'data' => [
        // Array of resources
    ],
    'meta' => [
        'total' => 150,
        'count' => 20,
        'per_page' => 20,
        'current_page' => 2,
        'total_pages' => 8,
        'links' => [
            'first' => '/api/products?page=1',
            'last' => '/api/products?page=8',
            'prev' => '/api/products?page=1',
            'next' => '/api/products?page=3'
        ]
    ]
];
```

#### HATEOAS Links

HATEOAS (Hypermedia as the Engine of Application State) enhances REST APIs by including related links:

```php
<?php
$userResponse = [
    'id' => 123,
    'name' => 'John Doe',
    'email' => 'john@example.com',
    '_links' => [
        'self' => [
            'href' => '/api/users/123'
        ],
        'orders' => [
            'href' => '/api/users/123/orders'
        ],
        'update' => [
            'href' => '/api/users/123',
            'method' => 'PUT'
        ],
        'delete' => [
            'href' => '/api/users/123',
            'method' => 'DELETE'
        ]
    ]
];
```

#### HTTP Status Codes

Choose appropriate HTTP status codes for different scenarios:

```php
<?php
// Success responses
http_response_code(200); // OK (standard success)
http_response_code(201); // Created (resource creation)
http_response_code(204); // No Content (successful deletion)

// Client error responses
http_response_code(400); // Bad Request (invalid input)
http_response_code(401); // Unauthorized (authentication required)
http_response_code(403); // Forbidden (insufficient permissions)
http_response_code(404); // Not Found (resource doesn't exist)
http_response_code(405); // Method Not Allowed
http_response_code(409); // Conflict (e.g., email already exists)
http_response_code(422); // Unprocessable Entity (validation errors)
http_response_code(429); // Too Many Requests: Rate limit exceeded

// Server error responses
http_response_code(500); // Internal Server Error
http_response_code(503); // Service Unavailable (maintenance)
```

#### Content Negotiation

Support different response formats based on Accept header:

```php
<?php
$data = [
    'id' => 123,
    'name' => 'John Doe',
    'email' => 'john@example.com'
];

$acceptHeader = $_SERVER['HTTP_ACCEPT'] ?? 'application/json';

if (strpos($acceptHeader, 'application/xml') !== false) {
    // Return XML response
    header('Content-Type: application/xml');
    
    $xml = new SimpleXMLElement('<response/>');
    
    // Helper function to convert array to XML
    function arrayToXml($data, &$xml) {
        foreach ($data as $key => $value) {
            if (is_array($value)) {
                if (is_numeric($key)) {
                    $key = 'item' . $key;
                }
                $subnode = $xml->addChild($key);
                arrayToXml($value, $subnode);
            } else {
                $xml->addChild($key, htmlspecialchars($value));
            }
        }
    }
    
    arrayToXml($data, $xml);
    echo $xml->asXML();
} else {
    // Return JSON response (default)
    header('Content-Type: application/json');
    echo json_encode($data);
}
```

### Advanced API Features

#### Authentication with JWT

- JSON Web Tokens provide a secure way to authenticate API requests
- Stateless authentication that works well with REST principles
- Consists of header, payload, and signature

```php
<?php
class JWTAuth {
    private $secretKey;
    
    public function __construct($secretKey = null) {
        $this->secretKey = $secretKey ?: 'your-secret-key';
    }
    
    /**
     * Generate JWT token
     * 
     * @param array $payload Data to be encoded in token
     * @param int $expiration Expiration time in seconds
     * @return string
     */
    public function generateToken($payload, $expiration = 3600) {
        $issuedAt = time();
        $expire = $issuedAt + $expiration;
        
        $header = base64_encode(json_encode([
            'alg' => 'HS256',
            'typ' => 'JWT'
        ]));
        
        $payload = array_merge($payload, [
            'iat' => $issuedAt,
            'exp' => $expire
        ]);
        
        $payload = base64_encode(json_encode($payload));
        
        $signature = hash_hmac('sha256', "$header.$payload", $this->secretKey, true);
        $signature = base64_encode($signature);
        
        return "$header.$payload.$signature";
    }
    
    /**
     * Validate JWT token
     * 
     * @param string $token JWT token
     * @return array|bool Decoded payload or false if invalid
     */
    public function validateToken($token) {
        $parts = explode('.', $token);
        
        if (count($parts) !== 3) {
            return false;
        }
        
        list($header, $payload, $signature) = $parts;
        
        $verifySignature = hash_hmac('sha256', "$header.$payload", $this->secretKey, true);
        $verifySignature = base64_encode($verifySignature);
        
        if ($signature !== $verifySignature) {
            return false;
        }
        
        $decodedPayload = json_decode(base64_decode($payload), true);
        
        // Check if token is expired
        if (isset($decodedPayload['exp']) && $decodedPayload['exp'] < time()) {
            return false;
        }
        
        return $decodedPayload;
    }
}

// Usage example in AuthController
class AuthController {
    private $conn;
    private $jwt;
    
    public function __construct($db) {
        $this->conn = $db;
        $this->jwt = new JWTAuth();
    }
    
    /**
     * Login user and generate token
     * 
     * @param array $data Login credentials
     * @return void
     */
    public function login($data) {
        try {
            // Validate required fields
            if (!isset($data['email']) || !isset($data['password'])) {
                Response::error("Email and password are required", 400);
                return;
            }
            
            // Find user by email
            $query = "SELECT id, name, email, password FROM users WHERE email = :email";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':email', $data['email']);
            $stmt->execute();
            
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user || !password_verify($data['password'], $user['password'])) {
                Response::error("Invalid credentials", 401);
                return;
            }
            
            // Generate token
            $token = $this->jwt->generateToken([
                'user_id' => $user['id'],
                'email' => $user['email']
            ]);
            
            Response::json([
                'user' => [
                    'id' => $user['id'],
                    'name' => $user['name'],
                    'email' => $user['email']
                ],
                'token' => $token
            ]);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
}

// Authentication middleware
class AuthMiddleware {
    private $jwt;
    
    public function __construct() {
        $this->jwt = new JWTAuth();
    }
    
    /**
     * Authenticate request
     * 
     * @return array User payload if authenticated
     */
    public function authenticate() {
        // Get token from Authorization header
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? '';
        
        if (!preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            Response::error("Bearer token required", 401);
            exit;
        }
        
        $token = $matches[1];
        $payload = $this->jwt->validateToken($token);
        
        if (!$payload) {
            Response::error("Invalid or expired token", 401);
            exit;
        }
        
        return $payload;
    }
}
```

### Rate Limiting

```php
<?php
class RateLimiter {
    private $conn;
    private $limitPerMinute;
    
    public function __construct($db, $limitPerMinute = 60) {
        $this->conn = $db;
        $this->limitPerMinute = $limitPerMinute;
    }
    
    /**
     * Check if request exceeds rate limit
     * 
     * @param string $identifier Client identifier (IP, API key, user ID)
     * @return bool True if limit exceeded
     */
    public function isLimited($identifier) {
        try {
            // Clean up old requests
            $this->cleanupOldRequests();
            
            // Count requests in last minute
            $query = "SELECT COUNT(*) FROM api_requests 
                     WHERE identifier = :identifier 
                     AND request_time > DATE_SUB(NOW(), INTERVAL 1 MINUTE)";
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':identifier', $identifier);
            $stmt->execute();
            
            $count = $stmt->fetchColumn();
            
            if ($count >= $this->limitPerMinute) {
                return true;
            }
            
            // Log this request
            $this->logRequest($identifier);
            
            return false;
        } catch (\PDOException $e) {
            // Log error
            error_log('Rate limiting error: ' . $e->getMessage());
            return false; // Default to allowing the request if DB fails
        }
    }
    
    /**
     * Log a new API request
     * 
     * @param string $identifier Client identifier
     * @return bool Success status
     */
    private function logRequest($identifier) {
        $query = "INSERT INTO api_requests (identifier, request_time) 
                 VALUES (:identifier, NOW())";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':identifier', $identifier);
        
        return $stmt->execute();
    }
    
    /**
     * Remove old request logs (older than 1 hour)
     */
    private function cleanupOldRequests() {
        $query = "DELETE FROM api_requests 
                 WHERE request_time < DATE_SUB(NOW(), INTERVAL 1 HOUR)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
    }
    
    /**
     * Get current rate limit information
     * 
     * @param string $identifier Client identifier
     * @return array Rate limit data
     */
    public function getRateLimitInfo($identifier) {
        $query = "SELECT COUNT(*) FROM api_requests 
                 WHERE identifier = :identifier 
                 AND request_time > DATE_SUB(NOW(), INTERVAL 1 MINUTE)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':identifier', $identifier);
        $stmt->execute();
        
        $count = $stmt->fetchColumn();
        
        return [
            'limit' => $this->limitPerMinute,
            'remaining' => max(0, $this->limitPerMinute - $count),
            'reset' => time() + 60 // Reset in 60 seconds
        ];
    }
}
```

### Implementing Rate Limiting in API Endpoints

```php
<?php
// API endpoint handler
require_once 'RateLimiter.php';
require_once 'DatabaseConnection.php';

// Get database connection
$db = new DatabaseConnection();
$conn = $db->getConnection();

// Create rate limiter
$rateLimiter = new RateLimiter($conn, 100); // 100 requests per minute

// Get client identifier (IP address or API key)
$identifier = $_SERVER['REMOTE_ADDR']; // Simple IP-based limiting
// Or for API key-based limiting:
// $identifier = $_SERVER['HTTP_X_API_KEY'] ?? $_SERVER['REMOTE_ADDR'];

// Check if client is rate limited
if ($rateLimiter->isLimited($identifier)) {
    // Send rate limit headers
    $rateLimitInfo = $rateLimiter->getRateLimitInfo($identifier);
    header('X-RateLimit-Limit: ' . $rateLimitInfo['limit']);
    header('X-RateLimit-Remaining: ' . $rateLimitInfo['remaining']);
    header('X-RateLimit-Reset: ' . $rateLimitInfo['reset']);
    header('Retry-After: ' . $rateLimitInfo['reset'] - time());
    
    // Send 429 response
    header('HTTP/1.1 429 Too Many Requests');
    header('Content-Type: application/json');
    
    echo json_encode([
        'status' => 'error',
        'message' => 'Rate limit exceeded. Please try again later.',
        'rate_limit' => $rateLimitInfo
    ]);
    
    exit;
}

// Add rate limit headers to successful responses
$rateLimitInfo = $rateLimiter->getRateLimitInfo($identifier);
header('X-RateLimit-Limit: ' . $rateLimitInfo['limit']);
header('X-RateLimit-Remaining: ' . $rateLimitInfo['remaining']);
header('X-RateLimit-Reset: ' . $rateLimitInfo['reset']);

// Continue processing the API request...
// Your API logic here
```

### Versioning Strategies

- **URI Versioning**: Include version in URL path (`/api/v1/users`)
- **Header Versioning**: Use custom headers (`Accept-version: v1`)
- **Accept Header Versioning**: Use media type versioning (`Accept: application/vnd.example.v1+json`)
- **Query Parameter Versioning**: Add version as query parameter (`/api/users?version=1`)

```php
<?php
// URI versioning example
$requestUri = $_SERVER['REQUEST_URI'];

// Extract version from URI
if (preg_match('/\/v(\d+)\//', $requestUri, $matches)) {
    $version = (int)$matches[1];
    
    switch ($version) {
        case 1:
            require_once 'api/v1/Router.php';
            $router = new V1\Router();
            break;
        case 2:
            require_once 'api/v2/Router.php';
            $router = new V2\Router();
            break;
        default:
            // Use latest version or send error
            header('HTTP/1.1 400 Bad Request');
            echo json_encode(['error' => 'Unsupported API version']);
            exit;
    }
    
    $router->route();
} else {
    // No version specified
    header('HTTP/1.1 400 Bad Request');
    echo json_encode(['error' => 'API version required']);
    exit;
}
```

### Documentation

- Use tools like Swagger/OpenAPI for automatic documentation
- Document all endpoints, parameters, and responses
- Include example requests and responses
- Provide authentication details
- Document rate limiting policies

### Error Handling

**Best Practices**

- Return appropriate HTTP status codes
- Include detailed error messages
- Use consistent error response format
- Include error codes for programmatic handling

```php
<?php
class ApiError {
    /**
     * Send error response
     * 
     * @param int $statusCode HTTP status code
     * @param string $message Human-readable error message
     * @param string $errorCode Internal error code
     * @param array $details Additional error details
     */
    public static function respond($statusCode, $message, $errorCode = null, $details = []) {
        $httpCodes = [
            400 => 'Bad Request',
            401 => 'Unauthorized',
            403 => 'Forbidden',
            404 => 'Not Found',
            405 => 'Method Not Allowed',
            422 => 'Unprocessable Entity',
            429 => 'Too Many Requests',
            500 => 'Internal Server Error',
            503 => 'Service Unavailable'
        ];
        
        $statusText = $httpCodes[$statusCode] ?? 'Unknown Error';
        
        header("HTTP/1.1 $statusCode $statusText");
        header('Content-Type: application/json');
        
        $response = [
            'status' => 'error',
            'message' => $message
        ];
        
        if ($errorCode) {
            $response['error_code'] = $errorCode;
        }
        
        if (!empty($details)) {
            $response['details'] = $details;
        }
        
        echo json_encode($response);
        exit;
    }
}

// Example usage
if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
    ApiError::respond(
        400, 
        'Invalid user ID provided', 
        'ERR_INVALID_ID', 
        ['parameter' => 'id', 'expected' => 'numeric value']
    );
}
```

### Caching Strategies

- Implement HTTP caching with ETag and If-None-Match headers
- Use Cache-Control headers to define caching policies
- Consider Redis or Memcached for server-side caching
- Implement conditional GET requests

```php
<?php
class ApiCache {
    /**
     * Generate ETag for response data
     * 
     * @param mixed $data Response data
     * @return string ETag hash
     */
    public static function generateETag($data) {
        return md5(json_encode($data));
    }
    
    /**
     * Check if client has fresh cache based on ETag
     * 
     * @param string $etag Current ETag
     * @return bool True if client has fresh cache
     */
    public static function clientHasFreshCache($etag) {
        $ifNoneMatch = isset($_SERVER['HTTP_IF_NONE_MATCH']) ? 
                      trim($_SERVER['HTTP_IF_NONE_MATCH']) : '';
        
        return $ifNoneMatch === $etag;
    }
    
    /**
     * Send cached response headers
     * 
     * @param string $etag ETag for the resource
     * @param int $maxAge Cache max age in seconds
     */
    public static function sendCacheHeaders($etag, $maxAge = 3600) {
        header("ETag: $etag");
        header("Cache-Control: max-age=$maxAge, public");
    }
    
    /**
     * Send not modified response
     */
    public static function sendNotModified() {
        header('HTTP/1.1 304 Not Modified');
        exit;
    }
}

// Example usage in an API endpoint
$userId = (int)$_GET['id'];
$userModel = new UserModel();
$userData = $userModel->getUserById($userId);

// Generate ETag
$etag = ApiCache::generateETag($userData);

// Check if client has fresh cache
if (ApiCache::clientHasFreshCache($etag)) {
    ApiCache::sendNotModified();
}

// Send cache headers
ApiCache::sendCacheHeaders($etag, 3600);

// Send response data
header('Content-Type: application/json');
echo json_encode([
    'status' => 'success',
    'data' => $userData
]);
```

### Cross-Origin Resource Sharing (CORS)

- Allow controlled access from different domains
- Define which origins can access the API
- Set appropriate headers for preflight requests
- Handle OPTIONS requests properly

```php
<?php
class CorsHandler {
    private $allowedOrigins;
    private $allowedMethods;
    private $allowedHeaders;
    private $allowCredentials;
    private $maxAge;
    
    public function __construct(
        $allowedOrigins = ['*'],
        $allowedMethods = ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        $allowedHeaders = ['Content-Type', 'Authorization', 'X-Requested-With'],
        $allowCredentials = true,
        $maxAge = 86400
    ) {
        $this->allowedOrigins = $allowedOrigins;
        $this->allowedMethods = $allowedMethods;
        $this->allowedHeaders = $allowedHeaders;
        $this->allowCredentials = $allowCredentials;
        $this->maxAge = $maxAge;
    }
    
    /**
     * Handle CORS headers for all requests
     */
    public function handleCors() {
        // Get request origin
        $origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '';
        
        // Check if origin is allowed
        if (in_array('*', $this->allowedOrigins) || in_array($origin, $this->allowedOrigins)) {
            header("Access-Control-Allow-Origin: $origin");
        }
        
        // Allow credentials if needed
        if ($this->allowCredentials) {
            header("Access-Control-Allow-Credentials: true");
        }
        
        // Handle preflight OPTIONS request
        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            header("Access-Control-Allow-Methods: " . implode(', ', $this->allowedMethods));
            header("Access-Control-Allow-Headers: " . implode(', ', $this->allowedHeaders));
            header("Access-Control-Max-Age: {$this->maxAge}");
            header("Content-Length: 0");
            header("Content-Type: text/plain");
            exit;
        }
    }
}

// Usage at the beginning of your API entry point
$corsHandler = new CorsHandler(
    ['https://example.com', 'https://app.example.com'], // Allowed origins
    ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],        // Allowed methods
    ['Content-Type', 'Authorization', 'X-API-Key']      // Allowed headers
);

$corsHandler->handleCors();

// Continue processing API request...
```

### Security Best Practices

- Implement proper input validation
- Use prepared statements for database queries
- Implement rate limiting (as shown above)
- Use HTTPS for all API traffic
- Implement proper authentication and authorization
- Sanitize all output data
- Follow the principle of least privilege
- Regularly audit API access logs

```php
<?php
class InputValidator {
    /**
     * Validate request parameters
     * 
     * @param array $rules Validation rules
     * @param array $data Input data
     * @return array Errors or empty if valid
     */
    public static function validate($rules, $data) {
        $errors = [];
        
        foreach ($rules as $field => $rule) {
            // Check required fields
            if (isset($rule['required']) && $rule['required'] && 
                (!isset($data[$field]) || empty($data[$field]))) {
                $errors[$field][] = "Field '$field' is required";
                continue;
            }
            
            // Skip validation if field is not present and not required
            if (!isset($data[$field]) || $data[$field] === '') {
                continue;
            }
            
            // Validate type
            if (isset($rule['type'])) {
                switch ($rule['type']) {
                    case 'int':
                        if (!is_numeric($data[$field]) || (int)$data[$field] != $data[$field]) {
                            $errors[$field][] = "Field '$field' must be an integer";
                        }
                        break;
                    case 'float':
                        if (!is_numeric($data[$field])) {
                            $errors[$field][] = "Field '$field' must be a number";
                        }
                        break;
                    case 'email':
                        if (!filter_var($data[$field], FILTER_VALIDATE_EMAIL)) {
                            $errors[$field][] = "Field '$field' must be a valid email";
                        }
                        break;
                    case 'url':
                        if (!filter_var($data[$field], FILTER_VALIDATE_URL)) {
                            $errors[$field][] = "Field '$field' must be a valid URL";
                        }
                        break;
                    case 'date':
                        $d = \DateTime::createFromFormat('Y-m-d', $data[$field]);
                        if (!$d || $d->format('Y-m-d') != $data[$field]) {
                            $errors[$field][] = "Field '$field' must be a valid date (YYYY-MM-DD)";
                        }
                        break;
                }
            }
            
            // Validate min/max for numbers
            if (is_numeric($data[$field])) {
                if (isset($rule['min']) && $data[$field] < $rule['min']) {
                    $errors[$field][] = "Field '$field' must be at least {$rule['min']}";
                }
                if (isset($rule['max']) && $data[$field] > $rule['max']) {
                    $errors[$field][] = "Field '$field' must be at most {$rule['max']}";
                }
            }
            
            // Validate string length
            if (is_string($data[$field])) {
                $length = mb_strlen($data[$field]);
                if (isset($rule['minLength']) && $length < $rule['minLength']) {
                    $errors[$field][] = "Field '$field' must be at least {$rule['minLength']} characters";
                }
                if (isset($rule['maxLength']) && $length > $rule['maxLength']) {
                    $errors[$field][] = "Field '$field' must be at most {$rule['maxLength']} characters";
                }
            }
            
            // Validate pattern
            if (isset($rule['pattern']) && !preg_match($rule['pattern'], $data[$field])) {
                $errors[$field][] = "Field '$field' has an invalid format";
            }
            
            // Validate enum values
            if (isset($rule['enum']) && !in_array($data[$field], $rule['enum'])) {
                $errors[$field][] = "Field '$field' must be one of: " . implode(', ', $rule['enum']);
            }
        }
        
        return $errors;
    }
}

// Example usage
$rules = [
    'name' => [
        'required' => true,
        'type' => 'string',
        'minLength' => 2,
        'maxLength' => 50
    ],
    'email' => [
        'required' => true,
        'type' => 'email'
    ],
    'age' => [
        'required' => false,
        'type' => 'int',
        'min' => 18,
        'max' => 120
    ],
    'status' => [
        'required' => true,
        'enum' => ['active', 'inactive', 'pending']
    ]
];

$inputData = [
    'name' => 'John Doe',
    'email' => 'invalid-email',
    'age' => 15
    // Missing 'status' field
];

$errors = InputValidator::validate($rules, $inputData);

if (!empty($errors)) {
    ApiError::respond(
        422, 
        'Validation failed', 
        'ERR_VALIDATION', 
        $errors
    );
}
```

### Testing RESTful APIs

- Unit testing individual components
- Integration testing API endpoints
- Load testing for performance
- Security testing for vulnerabilities
- Automated testing with tools like PHPUnit

### Performance Optimization

- Implement database query optimization
- Use connection pooling
- Implement caching strategies
- Use pagination for large datasets
- Consider asynchronous processing for heavy operations
- Implement HTTP/2 for multiplexing requests
- Use compression for responses (gzip)

### API Gateway Integration

- Route API requests through a central gateway
- Implement cross-cutting concerns (authentication, rate limiting)
- Handle request/response transformation
- Provide analytics and monitoring
- Implement service discovery for microservices

### Conclusion

Building RESTful APIs in PHP requires careful planning and implementation of core REST principles. By following best practices for endpoint design, authentication, response formatting, and error handling, you can create robust and scalable APIs. Advanced features like rate limiting, caching, and comprehensive documentation further enhance the usability and security of your API. With proper testing and performance optimization, your PHP-based API can efficiently serve both internal and external consumers.