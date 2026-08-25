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

