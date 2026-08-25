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

