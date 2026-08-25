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

