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

