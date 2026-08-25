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

