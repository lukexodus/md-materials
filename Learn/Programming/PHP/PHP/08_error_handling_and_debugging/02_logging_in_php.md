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

