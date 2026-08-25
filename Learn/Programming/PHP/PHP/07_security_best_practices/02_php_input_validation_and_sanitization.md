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

