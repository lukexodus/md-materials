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

