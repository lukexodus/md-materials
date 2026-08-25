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
