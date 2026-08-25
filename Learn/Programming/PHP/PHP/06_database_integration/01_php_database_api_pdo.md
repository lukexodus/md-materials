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

