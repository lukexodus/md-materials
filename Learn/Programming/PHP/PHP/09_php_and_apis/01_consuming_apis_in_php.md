## Consuming APIs in PHP


### Understanding APIs in PHP Context

PHP offers robust capabilities for interacting with external APIs, enabling developers to extend application functionality by leveraging third-party services. APIs (Application Programming Interfaces) provide standardized methods for different software applications to communicate with each other through well-defined requests and responses.

**Key Points**

- PHP can consume both REST and SOAP APIs
- Most modern APIs communicate using JSON, though XML is still common
- PHP provides multiple methods for making HTTP requests
- Proper error handling is essential when working with external services

### HTTP Requests with cURL

cURL (Client URL) is a library that allows making HTTP requests to other servers, making it the foundation for API consumption in PHP.

#### Basic cURL Implementation

```php
<?php
// Initialize a cURL session
$curl = curl_init();

// Set cURL options
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint",
    CURLOPT_RETURNTRANSFER => true,  // Return response instead of outputting
    CURLOPT_FOLLOWLOCATION => true,  // Follow redirects
    CURLOPT_TIMEOUT => 30,           // Timeout in seconds
    CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
    CURLOPT_CUSTOMREQUEST => "GET",  // HTTP method
]);

// Execute the request
$response = curl_exec($curl);
$err = curl_error($curl);

// Close cURL resource
curl_close($curl);

if ($err) {
    echo "cURL Error: " . $err;
} else {
    echo $response;
}
?>
```

#### Making Different HTTP Requests

cURL supports all common HTTP methods used in API interactions:

```php
<?php
// POST request
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_CUSTOMREQUEST => "POST",
    CURLOPT_POSTFIELDS => json_encode([
        "name" => "John Doe",
        "email" => "john@example.com"
    ]),
    CURLOPT_HTTPHEADER => [
        "Content-Type: application/json",
    ],
]);

// PUT request
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint/1",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_CUSTOMREQUEST => "PUT",
    CURLOPT_POSTFIELDS => json_encode([
        "name" => "Updated Name"
    ]),
    CURLOPT_HTTPHEADER => [
        "Content-Type: application/json",
    ],
]);

// DELETE request
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint/1",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_CUSTOMREQUEST => "DELETE",
]);
?>
```

#### Setting Request Headers

Headers are crucial for API communication, providing metadata about the request:

```php
<?php
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Content-Type: application/json",
        "Accept: application/json",
        "User-Agent: PHP/cURL",
        "Authorization: Bearer YOUR_ACCESS_TOKEN"
    ],
]);
?>
```

#### Error Handling and Debugging

Proper error handling is essential when working with external APIs:

```php
<?php
$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/endpoint",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_VERBOSE => true,        // Enable verbose output for debugging
]);

$response = curl_exec($curl);
$err = curl_error($curl);
$info = curl_getinfo($curl);        // Get request info including HTTP status code
curl_close($curl);

if ($err) {
    echo "cURL Error: " . $err;
} elseif ($info['http_code'] >= 400) {
    echo "API Error: HTTP Code " . $info['http_code'];
} else {
    // Process successful response
    echo $response;
}
?>
```

### Working with JSON

JSON (JavaScript Object Notation) has become the standard data format for most modern APIs due to its lightweight nature and compatibility with JavaScript.

#### Decoding JSON Responses

```php
<?php
$curl = curl_init("https://api.example.com/users");
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($curl);
curl_close($curl);

// Convert JSON string to PHP array/object
$data = json_decode($response, true);  // true returns associative array, false returns object

if (json_last_error() !== JSON_ERROR_NONE) {
    echo "JSON Error: " . json_last_error_msg();
} else {
    // Access the data
    foreach ($data['users'] as $user) {
        echo $user['name'] . ": " . $user['email'] . "<br>";
    }
}
?>
```

#### Encoding PHP Arrays/Objects to JSON

```php
<?php
$userData = [
    'name' => 'John Doe',
    'email' => 'john@example.com',
    'roles' => ['admin', 'editor']
];

$jsonData = json_encode($userData, JSON_PRETTY_PRINT);

if (json_last_error() !== JSON_ERROR_NONE) {
    echo "JSON Encoding Error: " . json_last_error_msg();
} else {
    echo $jsonData;
    
    // Use in a POST request
    curl_setopt_array($curl, [
        CURLOPT_URL => "https://api.example.com/users",
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CUSTOMREQUEST => "POST",
        CURLOPT_POSTFIELDS => $jsonData,
        CURLOPT_HTTPHEADER => [
            "Content-Type: application/json",
            "Content-Length: " . strlen($jsonData)
        ],
    ]);
}
?>
```

#### JSON Error Handling

```php
<?php
function checkJsonError() {
    $error = json_last_error();
    if ($error !== JSON_ERROR_NONE) {
        $errorMessages = [
            JSON_ERROR_DEPTH => 'Maximum stack depth exceeded',
            JSON_ERROR_STATE_MISMATCH => 'Underflow or the modes mismatch',
            JSON_ERROR_CTRL_CHAR => 'Unexpected control character found',
            JSON_ERROR_SYNTAX => 'Syntax error, malformed JSON',
            JSON_ERROR_UTF8 => 'Malformed UTF-8 characters'
        ];
        
        return isset($errorMessages[$error]) 
            ? $errorMessages[$error] 
            : 'Unknown JSON error: ' . $error;
    }
    return null;
}

$data = json_decode($response, true);
if ($errorMsg = checkJsonError()) {
    throw new Exception("JSON Error: " . $errorMsg);
}
?>
```

### Working with XML

While JSON is more common, some APIs still use XML, especially legacy or enterprise systems. PHP offers multiple ways to work with XML.

#### SimpleXML for Reading XML

```php
<?php
$curl = curl_init("https://api.example.com/data.xml");
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($curl);
curl_close($curl);

// Parse XML string
try {
    $xml = new SimpleXMLElement($response);
    
    // Access XML data
    echo $xml->user->name . "<br>";
    echo $xml->user->email . "<br>";
    
    // Loop through elements
    foreach ($xml->users->user as $user) {
        echo $user->name . ": " . $user->email . "<br>";
    }
    
    // Access attributes
    echo $xml->product['id'] . ": " . $xml->product->name . "<br>";
    
} catch (Exception $e) {
    echo "XML Error: " . $e->getMessage();
}
?>
```

#### Creating XML with SimpleXML

```php
<?php
// Create a new XML document
$xml = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><request></request>');

// Add elements and attributes
$xml->addChild('action', 'create');
$user = $xml->addChild('user');
$user->addChild('name', 'John Doe');
$user->addChild('email', 'john@example.com');
$user->addAttribute('id', '123');

// Convert to string
$xmlString = $xml->asXML();

// Send XML in a request
$curl = curl_init("https://api.example.com/xmlapi");
curl_setopt_array($curl, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => $xmlString,
    CURLOPT_HTTPHEADER => [
        "Content-Type: application/xml",
        "Content-Length: " . strlen($xmlString)
    ],
]);
$response = curl_exec($curl);
curl_close($curl);
?>
```

#### DOMDocument for Complex XML Operations

```php
<?php
// Create an XML document
$dom = new DOMDocument('1.0', 'UTF-8');
$dom->formatOutput = true;

// Create elements
$root = $dom->createElement('request');
$dom->appendChild($root);

$action = $dom->createElement('action', 'update');
$root->appendChild($action);

$user = $dom->createElement('user');
$user->setAttribute('id', '123');
$root->appendChild($user);

$name = $dom->createElement('name', 'John Doe');
$user->appendChild($name);

$email = $dom->createElement('email', 'john@example.com');
$user->appendChild($email);

// Convert to string
$xmlString = $dom->saveXML();

// Use in API request
curl_setopt($curl, CURLOPT_POSTFIELDS, $xmlString);
?>
```

#### XML to Array Conversion

```php
<?php
function xml_to_array($xml) {
    $parser = xml_parser_create();
    xml_parser_set_option($parser, XML_OPTION_CASE_FOLDING, 0);
    xml_parser_set_option($parser, XML_OPTION_SKIP_WHITE, 1);
    xml_parse_into_struct($parser, $xml, $tags);
    xml_parser_free($parser);
    
    $elements = [];
    $stack = [];
    
    foreach ($tags as $tag) {
        $index = count($elements);
        
        if ($tag['type'] == "complete" || $tag['type'] == "open") {
            $elements[$index] = [
                'name' => $tag['tag'],
                'attributes' => isset($tag['attributes']) ? $tag['attributes'] : '',
                'content' => isset($tag['value']) ? $tag['value'] : '',
                'children' => []
            ];
            
            if ($tag['type'] == "open") {
                $stack[] = $index;
            }
        }
        
        if ($tag['type'] == "close") {
            $current = array_pop($stack);
            
            if (count($stack) > 0) {
                $parent = $stack[count($stack) - 1];
                $elements[$parent]['children'][] = $elements[$current];
                unset($elements[$current]);
            }
        }
    }
    
    return $elements[0];
}

$xmlString = '<response><user id="123"><name>John Doe</name><email>john@example.com</email></user></response>';
$arrayData = xml_to_array($xmlString);
?>
```

### API Authentication Methods

Most APIs require authentication to protect resources and identify users. PHP supports all common authentication methods.

#### API Key Authentication

The simplest form of authentication, typically passed in a header or query parameter:

```php
<?php
// API key in query string
$url = "https://api.example.com/data?api_key=YOUR_API_KEY";
$curl = curl_init($url);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($curl);
curl_close($curl);

// API key in header
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "X-API-Key: YOUR_API_KEY",
    ],
]);
?>
```

#### Basic Authentication

Uses HTTP's basic auth mechanism with username and password:

```php
<?php
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_USERPWD => "username:password", // Basic Auth credentials
]);

// Alternative method
$credentials = base64_encode("username:password");
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Authorization: Basic " . $credentials,
    ],
]);
?>
```

#### OAuth 1.0 Authentication

Used by some legacy APIs, requires signature generation:

```php
<?php
function generateOAuthSignature($method, $url, $params, $consumerSecret, $tokenSecret = '') {
    // Sort parameters alphabetically
    ksort($params);
    
    // Create parameter string
    $paramString = '';
    foreach ($params as $key => $value) {
        $paramString .= urlencode($key) . '=' . urlencode($value) . '&';
    }
    $paramString = rtrim($paramString, '&');
    
    // Create signature base string
    $baseString = strtoupper($method) . '&' . urlencode($url) . '&' . urlencode($paramString);
    
    // Create signing key
    $signingKey = urlencode($consumerSecret) . '&' . urlencode($tokenSecret);
    
    // Generate signature
    $signature = base64_encode(hash_hmac('sha1', $baseString, $signingKey, true));
    
    return $signature;
}

// OAuth 1.0 parameters
$oauthParams = [
    'oauth_consumer_key' => 'YOUR_CONSUMER_KEY',
    'oauth_nonce' => md5(uniqid(rand(), true)),
    'oauth_signature_method' => 'HMAC-SHA1',
    'oauth_timestamp' => time(),
    'oauth_token' => 'YOUR_ACCESS_TOKEN',
    'oauth_version' => '1.0'
];

// Generate signature
$signature = generateOAuthSignature(
    'GET', 
    'https://api.example.com/data', 
    $oauthParams, 
    'YOUR_CONSUMER_SECRET', 
    'YOUR_TOKEN_SECRET'
);

// Add signature to parameters
$oauthParams['oauth_signature'] = $signature;

// Create Authorization header
$authHeader = 'OAuth ';
foreach ($oauthParams as $key => $value) {
    $authHeader .= $key . '="' . urlencode($value) . '", ';
}
$authHeader = rtrim($authHeader, ', ');

// Make the request
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Authorization: " . $authHeader
    ],
]);
?>
```

#### OAuth 2.0 Authentication

The most common modern authentication flow, typically exchanging credentials for a token:

```php
<?php
// Step 1: Get authorization code (typically happens in browser with redirect)
$authUrl = "https://oauth.example.com/authorize?client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI&response_type=code&scope=read,write";
// User gets redirected to this URL, authenticates, and is returned to redirect_uri with code parameter

// Step 2: Exchange authorization code for access token
$code = $_GET['code'];  // Authorization code from redirect
$tokenUrl = "https://oauth.example.com/token";

$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => $tokenUrl,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => http_build_query([
        'grant_type' => 'authorization_code',
        'code' => $code,
        'client_id' => 'YOUR_CLIENT_ID',
        'client_secret' => 'YOUR_CLIENT_SECRET',
        'redirect_uri' => 'YOUR_REDIRECT_URI'
    ])
]);

$tokenResponse = curl_exec($curl);
curl_close($curl);
$tokenData = json_decode($tokenResponse, true);
$accessToken = $tokenData['access_token'];

// Step 3: Use access token in API requests
$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Authorization: Bearer " . $accessToken
    ],
]);
$response = curl_exec($curl);
curl_close($curl);
?>
```

#### Client Credential Flow (for Service-to-Service APIs)

```php
<?php
$tokenUrl = "https://oauth.example.com/token";

$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => $tokenUrl,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => http_build_query([
        'grant_type' => 'client_credentials',
        'client_id' => 'YOUR_CLIENT_ID',
        'client_secret' => 'YOUR_CLIENT_SECRET',
        'scope' => 'read write'
    ])
]);

$tokenResponse = curl_exec($curl);
curl_close($curl);
$tokenData = json_decode($tokenResponse, true);
$accessToken = $tokenData['access_token'];

// Use access token in API requests
?>
```

#### JWT (JSON Web Token) Authentication

```php
<?php
// Requires a JWT library like firebase/php-jwt
require 'vendor/autoload.php';
use Firebase\JWT\JWT;

// Create a JWT token
$key = "your_secret_key";
$payload = [
    "iss" => "your_app_name",
    "aud" => "api.example.com",
    "iat" => time(),
    "exp" => time() + 3600, // Expires in 1 hour
    "sub" => "user_id"
];

$jwt = JWT::encode($payload, $key, 'HS256');

// Use token in API request
$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => "https://api.example.com/data",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        "Authorization: Bearer " . $jwt
    ],
]);
$response = curl_exec($curl);
curl_close($curl);
?>
```

### Creating an API Wrapper Class

For cleaner code and reusability, it's best to create a wrapper class for API interactions:

```php
<?php
class ApiClient {
    private $baseUrl;
    private $apiKey;
    private $accessToken;
    
    public function __construct($baseUrl, $apiKey = null, $accessToken = null) {
        $this->baseUrl = rtrim($baseUrl, '/');
        $this->apiKey = $apiKey;
        $this->accessToken = $accessToken;
    }
    
    public function setAccessToken($token) {
        $this->accessToken = $token;
    }
    
    private function getHeaders() {
        $headers = ["Accept: application/json"];
        
        if ($this->apiKey) {
            $headers[] = "X-API-Key: {$this->apiKey}";
        }
        
        if ($this->accessToken) {
            $headers[] = "Authorization: Bearer {$this->accessToken}";
        }
        
        return $headers;
    }
    
    private function request($method, $endpoint, $data = null) {
        $url = $this->baseUrl . "/" . ltrim($endpoint, '/');
        $curl = curl_init();
        
        $options = [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTPHEADER => $this->getHeaders(),
            CURLOPT_CUSTOMREQUEST => strtoupper($method)
        ];
        
        if ($data && in_array(strtoupper($method), ['POST', 'PUT', 'PATCH'])) {
            $jsonData = json_encode($data);
            $options[CURLOPT_POSTFIELDS] = $jsonData;
            $options[CURLOPT_HTTPHEADER][] = "Content-Type: application/json";
            $options[CURLOPT_HTTPHEADER][] = "Content-Length: " . strlen($jsonData);
        }
        
        curl_setopt_array($curl, $options);
        
        $response = curl_exec($curl);
        $httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
        $error = curl_error($curl);
        curl_close($curl);
        
        if ($error) {
            throw new Exception("cURL Error: " . $error);
        }
        
        $decodedResponse = json_decode($response, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            // Not JSON or invalid JSON
            return [
                'code' => $httpCode,
                'data' => $response
            ];
        }
        
        return [
            'code' => $httpCode,
            'data' => $decodedResponse
        ];
    }
    
    public function get($endpoint, $queryParams = []) {
        if (!empty($queryParams)) {
            $endpoint .= '?' . http_build_query($queryParams);
        }
        return $this->request('GET', $endpoint);
    }
    
    public function post($endpoint, $data) {
        return $this->request('POST', $endpoint, $data);
    }
    
    public function put($endpoint, $data) {
        return $this->request('PUT', $endpoint, $data);
    }
    
    public function patch($endpoint, $data) {
        return $this->request('PATCH', $endpoint, $data);
    }
    
    public function delete($endpoint) {
        return $this->request('DELETE', $endpoint);
    }
}

// Usage example
$api = new ApiClient('https://api.example.com/v1', 'your-api-key');

// Get users
$response = $api->get('users', ['limit' => 10]);
if ($response['code'] === 200) {
    $users = $response['data'];
    foreach ($users as $user) {
        echo $user['name'] . "<br>";
    }
}

// Create user
$newUser = [
    'name' => 'John Doe',
    'email' => 'john@example.com'
];
$response = $api->post('users', $newUser);

// Update user
$updatedData = ['name' => 'John Smith'];
$response = $api->put('users/123', $updatedData);

// Delete user
$response = $api->delete('users/123');
```

### Alternative HTTP Clients

While cURL is the most common method for API requests, PHP offers alternatives:

#### Using file_get_contents() with Stream Context

```php
<?php
// Simple GET request
$response = file_get_contents('https://api.example.com/data');

// More complex request with headers and method
$options = [
    'http' => [
        'method' => 'POST',
        'header' => [
            'Content-Type: application/json',
            'Authorization: Bearer YOUR_TOKEN'
        ],
        'content' => json_encode(['name' => 'John Doe']),
        'timeout' => 30
    ]
];

$context = stream_context_create($options);
$response = file_get_contents('https://api.example.com/users', false, $context);
$data = json_decode($response, true);
?>
```

#### Using Guzzle HTTP Client

Guzzle is a popular third-party HTTP client library that simplifies API requests:

```php
<?php
// Requires: composer require guzzlehttp/guzzle
require 'vendor/autoload.php';
use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;

// Create client
$client = new Client([
    'base_uri' => 'https://api.example.com/',
    'timeout' => 30,
    'headers' => [
        'Accept' => 'application/json',
        'Authorization' => 'Bearer YOUR_TOKEN'
    ]
]);

// GET request
try {
    $response = $client->get('users', [
        'query' => ['limit' => 10]
    ]);
    $data = json_decode($response->getBody(), true);
    
    foreach ($data['users'] as $user) {
        echo $user['name'] . "<br>";
    }
} catch (RequestException $e) {
    echo "Error: " . $e->getMessage();
}

// POST request
try {
    $response = $client->post('users', [
        'json' => [
            'name' => 'John Doe',
            'email' => 'john@example.com'
        ]
    ]);
    
    $statusCode = $response->getStatusCode();
    $data = json_decode($response->getBody(), true);
} catch (RequestException $e) {
    if ($e->hasResponse()) {
        $statusCode = $e->getResponse()->getStatusCode();
        echo "API Error: " . $statusCode;
    } else {
        echo "Connection Error: " . $e->getMessage();
    }
}
```

### Rate Limiting and Throttling

When working with APIs, it's important to respect rate limits:

```php
<?php
class RateLimitedApiClient {
    private $baseUrl;
    private $requestsPerMinute;
    private $requestTimes = [];
    
    public function __construct($baseUrl, $requestsPerMinute = 60) {
        $this->baseUrl = $baseUrl;
        $this->requestsPerMinute = $requestsPerMinute;
    }
    
    private function waitForRateLimit() {
        // Remove request times older than 1 minute
        $now = microtime(true);
        $this->requestTimes = array_filter(
            $this->requestTimes,
            function($time) use ($now) {
                return $now - $time < 60;
            }
        );
        
        // If we've reached the limit, wait
        if (count($this->requestTimes) >= $this->requestsPerMinute) {
            $oldestTime = min($this->requestTimes);
            $timeToWait = 60 - ($now - $oldestTime) + 0.1; // Add 0.1s buffer
            
            if ($timeToWait > 0) {
                usleep($timeToWait * 1000000); // Convert to microseconds
            }
        }
        
        // Add current request time
        $this->requestTimes[] = microtime(true);
    }
    
    public function get($endpoint) {
        $this->waitForRateLimit();
        
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL => $this->baseUrl . '/' . $endpoint,
            CURLOPT_RETURNTRANSFER => true
        ]);
        
        $response = curl_exec($curl);
        curl_close($curl);
        
        return json_decode($response, true);
    }
    
    // Additional methods for POST, PUT, etc.
}

$api = new RateLimitedApiClient('https://api.example.com', 30); // 30 requests per minute
?>
```

### Handling Pagination

Many APIs return paginated results, requiring multiple requests to fetch all data:

```php
<?php
function fetchAllPages($baseUrl, $endpoint, $headers = []) {
    $allResults = [];
    $page = 1;
    $hasMorePages = true;
    
    while ($hasMorePages) {
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL => $baseUrl . '/' . $endpoint . '?page=' . $page,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => $headers
        ]);
        
        $response = curl_exec($curl);
        curl_close($curl);
        
        $data = json_decode($response, true);
        
        if (!empty($data['results'])) {
            $allResults = array_merge($allResults, $data['results']);
            
            // Check if there are more pages
            if (isset($data['next_page']) && $data['next_page']) {
                $page++;
            } else {
                $hasMorePages = false;
            }
        } else {
            $hasMorePages = false;
        }
        
        // Avoid rate limiting
        sleep(1);
    }
    
    return $allResults;
}

$headers = [
    'Authorization: Bearer YOUR_TOKEN',
    'Accept: application/json'
];

$allUsers = fetchAllPages('https://api.example.com', 'users', $headers);
echo "Total users: " . count($allUsers);
?>
```

### Caching API Responses

To reduce API calls and improve performance, implement response caching:

```php
<?php
class CachedApiClient {
    private $baseUrl;
    private $token;
    private $cacheDir;
    private $cacheTTL;
    
    public function __construct($baseUrl, $token, $cacheDir = 'cache', $cacheTTL = 3600) {
        $this->baseUrl = $baseUrl;
        $this->token = $token;
        $this->cacheDir = $cacheDir;
        $this->cacheTTL = $cacheTTL;
        
        // Create cache directory if it doesn't exist
        if (!file_exists($this->cacheDir)) {
            mkdir($this->cacheDir, 0755, true);
        }
    }
    
    private function getCacheFilename($endpoint) {
        return $this->cacheDir . '/' . md5($endpoint) . '.json';
    }
    
    private function getFromCache($endpoint) {
        $cacheFile = $this->getCacheFilename($endpoint);
        
        if (file_exists($cacheFile)) {
            $fileTime = filemtime($cacheFile);
            
            // Check if cache is still valid
            if (time() - $fileTime < $this->cacheTTL) {
                return json_decode(file_get_contents($cacheFile), true);
            }
        }
        
        return null;
    }
    
    private function saveToCache($endpoint, $data) {
        $cacheFile = $this->getCacheFilename($endpoint);
        file_put_contents($cacheFile, json_encode($data));
    }
    
    public function get($endpoint, $params = [], $forceRefresh = false) {
        $url = $this->baseUrl . $endpoint;
        if (!empty($params)) {
            $url .= '?' . http_build_query($params);
        }
        
        // Try to get from cache if not forcing refresh
        if (!$forceRefresh) {
            $cachedData = $this->getFromCache($url);
            if ($cachedData !== null) {
                return $cachedData;
            }
        }
        
        // Make the API request
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $this->token,
            'Accept: application/json'
        ]);
        
        $response = curl_exec($ch);
        $statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($statusCode === 200) {
            $data = json_decode($response, true);
            $this->saveToCache($url, $data);
            return $data;
        }
        
        return null;
    }
}

// Usage example
$client = new CachedApiClient(
    'https://api.example.com/v1', 
    'your_api_token', 
    'api_cache', 
    1800 // 30 minutes TTL
);

// First call - will hit the API
$userData = $client->get('/users/123');

// Second call - will retrieve from cache
$sameUserData = $client->get('/users/123');

// Force refresh - will hit the API again
$refreshedUserData = $client->get('/users/123', [], true);
```

**Key Points:**

- File-based caching is simple but effective for many applications
- Each endpoint's response is cached with an MD5 hash as the filename
- The Time-To-Live (TTL) determines how long cached data remains valid
- Force refresh option allows bypassing the cache when needed

### Using PSR-6/PSR-16 Cache Libraries

For more robust caching, leverage standardized caching libraries:

```php
<?php
require 'vendor/autoload.php';

use Symfony\Component\Cache\Adapter\FilesystemAdapter;
use Symfony\Contracts\Cache\ItemInterface;

class PSR6ApiClient {
    private $baseUrl;
    private $token;
    private $cache;
    private $cacheTTL;
    
    public function __construct($baseUrl, $token, $cacheTTL = 3600) {
        $this->baseUrl = $baseUrl;
        $this->token = $token;
        $this->cacheTTL = $cacheTTL;
        $this->cache = new FilesystemAdapter('api_cache', $cacheTTL);
    }
    
    public function get($endpoint, $params = [], $forceRefresh = false) {
        $url = $this->baseUrl . $endpoint;
        if (!empty($params)) {
            $url .= '?' . http_build_query($params);
        }
        
        $cacheKey = 'api_' . md5($url);
        
        // Delete cache item if force refresh
        if ($forceRefresh) {
            $this->cache->delete($cacheKey);
        }
        
        return $this->cache->get($cacheKey, function (ItemInterface $item) use ($url) {
            $item->expiresAfter($this->cacheTTL);
            
            // Make the API request
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Authorization: Bearer ' . $this->token,
                'Accept: application/json'
            ]);
            
            $response = curl_exec($ch);
            $statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            if ($statusCode === 200) {
                return json_decode($response, true);
            }
            
            throw new \Exception("API request failed with status code: $statusCode");
        });
    }
}
```

### Error Handling and Retry Logic

Implement robust error handling and retry mechanisms for reliable API interactions:

```php
<?php
class ResilientApiClient {
    private $baseUrl;
    private $token;
    private $maxRetries;
    private $retryDelay;
    
    public function __construct($baseUrl, $token, $maxRetries = 3, $retryDelay = 1000) {
        $this->baseUrl = $baseUrl;
        $this->token = $token;
        $this->maxRetries = $maxRetries;
        $this->retryDelay = $retryDelay; // milliseconds
    }
    
    public function get($endpoint, $params = []) {
        $url = $this->baseUrl . $endpoint;
        if (!empty($params)) {
            $url .= '?' . http_build_query($params);
        }
        
        $retries = 0;
        $lastException = null;
        
        while ($retries <= $this->maxRetries) {
            try {
                return $this->executeRequest($url);
            } catch (\Exception $e) {
                $lastException = $e;
                
                // Only retry on certain status codes (server errors)
                $statusCode = $e->getCode();
                if ($statusCode < 500 && $statusCode !== 429) {
                    throw $e; // Don't retry client errors except rate limiting
                }
                
                $retries++;
                
                if ($retries <= $this->maxRetries) {
                    // Exponential backoff with jitter
                    $delay = $this->retryDelay * pow(2, $retries - 1);
                    $jitter = $delay * 0.2 * (mt_rand(0, 10) / 10);
                    usleep(($delay + $jitter) * 1000);
                }
            }
        }
        
        throw $lastException ?: new \Exception("Maximum retries exceeded");
    }
    
    private function executeRequest($url) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $this->token,
            'Accept: application/json'
        ]);
        
        $response = curl_exec($ch);
        $statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        
        if ($error) {
            throw new \Exception("cURL Error: $error");
        }
        
        if ($statusCode >= 400) {
            $errorData = json_decode($response, true);
            $message = isset($errorData['message']) ? $errorData['message'] : 'Unknown error';
            throw new \Exception($message, $statusCode);
        }
        
        return json_decode($response, true);
    }
}
```

**Key Points:**

- Implements exponential backoff with jitter for retries
- Differentiates between retryable errors (5xx, rate limit) and client errors (4xx)
- Preserves and rethrows the original exception when retries are exhausted

### Webhooks and Event Handling

Receive and process API events through webhooks:

```php
<?php
class WebhookHandler {
    private $secretKey;
    private $validSources;
    
    public function __construct($secretKey, array $validSources = []) {
        $this->secretKey = $secretKey;
        $this->validSources = $validSources;
    }
    
    public function handleRequest() {
        // Verify request source if IPs are specified
        if (!empty($this->validSources)) {
            $clientIP = $_SERVER['REMOTE_ADDR'];
            if (!in_array($clientIP, $this->validSources)) {
                $this->sendResponse(403, 'Forbidden');
                return;
            }
        }
        
        // Get and validate the payload
        $payload = file_get_contents('php://input');
        if (empty($payload)) {
            $this->sendResponse(400, 'Empty payload');
            return;
        }
        
        // Verify signature if provided
        if (isset($_SERVER['HTTP_X_WEBHOOK_SIGNATURE'])) {
            $providedSignature = $_SERVER['HTTP_X_WEBHOOK_SIGNATURE'];
            $calculatedSignature = hash_hmac('sha256', $payload, $this->secretKey);
            
            if (!hash_equals($calculatedSignature, $providedSignature)) {
                $this->sendResponse(401, 'Invalid signature');
                return;
            }
        }
        
        // Process the webhook data
        $data = json_decode($payload, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            $this->sendResponse(400, 'Invalid JSON payload');
            return;
        }
        
        // Process based on event type
        $eventType = isset($data['event']) ? $data['event'] : 'unknown';
        $result = $this->processEvent($eventType, $data);
        
        // Return response
        $this->sendResponse(200, 'Webhook processed', $result);
    }
    
    private function processEvent($eventType, $data) {
        switch ($eventType) {
            case 'payment.success':
                return $this->handlePaymentSuccess($data);
            
            case 'user.created':
                return $this->handleUserCreated($data);
            
            case 'subscription.updated':
                return $this->handleSubscriptionUpdated($data);
            
            default:
                return ['status' => 'ignored', 'reason' => 'Unknown event type'];
        }
    }
    
    private function handlePaymentSuccess($data) {
        // Process payment success
        $paymentId = $data['payment_id'] ?? null;
        
        // Update database, send confirmation emails, etc.
        // ...
        
        return [
            'status' => 'processed',
            'payment_id' => $paymentId
        ];
    }
    
    private function handleUserCreated($data) {
        // Process user creation event
        // ...
        
        return ['status' => 'processed'];
    }
    
    private function handleSubscriptionUpdated($data) {
        // Process subscription update
        // ...
        
        return ['status' => 'processed'];
    }
    
    private function sendResponse($statusCode, $message, $data = null) {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        
        $response = [
            'status' => $statusCode < 300 ? 'success' : 'error',
            'message' => $message
        ];
        
        if ($data !== null) {
            $response['data'] = $data;
        }
        
        echo json_encode($response);
        exit;
    }
}

// Usage
$webhook = new WebhookHandler(
    'your_webhook_secret_key',
    ['192.168.1.100', '203.0.113.0/24'] // Optional allowed IPs/ranges
);
$webhook->handleRequest();
```

### Asynchronous API Processing

For handling multiple API requests efficiently:

```php
<?php
require 'vendor/autoload.php';

use GuzzleHttp\Client;
use GuzzleHttp\Promise;

class AsyncApiClient {
    private $client;
    private $baseUrl;
    private $token;
    
    public function __construct($baseUrl, $token) {
        $this->baseUrl = $baseUrl;
        $this->token = $token;
        
        $this->client = new Client([
            'base_uri' => $baseUrl,
            'headers' => [
                'Authorization' => 'Bearer ' . $token,
                'Accept' => 'application/json'
            ]
        ]);
    }
    
    public function fetchMultiple(array $endpoints) {
        $promises = [];
        
        foreach ($endpoints as $key => $endpoint) {
            $promises[$key] = $this->client->getAsync($endpoint);
        }
        
        // Wait for all requests to complete
        $responses = Promise\Utils::settle($promises)->wait();
        $results = [];
        
        foreach ($responses as $key => $response) {
            if ($response['state'] === 'fulfilled') {
                $results[$key] = json_decode($response['value']->getBody(), true);
            } else {
                $results[$key] = [
                    'error' => true,
                    'message' => $response['reason']->getMessage()
                ];
            }
        }
        
        return $results;
    }
    
    public function batchProcess(array $items, $endpoint, $batchSize = 10) {
        $chunks = array_chunk($items, $batchSize);
        $results = [];
        
        foreach ($chunks as $chunk) {
            $promises = [];
            
            foreach ($chunk as $index => $item) {
                $promises[$index] = $this->client->postAsync($endpoint, [
                    'json' => $item
                ]);
            }
            
            // Process batch and collect results
            $responses = Promise\Utils::settle($promises)->wait();
            
            foreach ($responses as $index => $response) {
                if ($response['state'] === 'fulfilled') {
                    $results[] = json_decode($response['value']->getBody(), true);
                } else {
                    $results[] = [
                        'error' => true,
                        'item' => $items[$index],
                        'message' => $response['reason']->getMessage()
                    ];
                }
            }
        }
        
        return $results;
    }
}

// Usage examples
$client = new AsyncApiClient('https://api.example.com/v1/', 'your_api_token');

// Fetch multiple endpoints in parallel
$userIds = [123, 456, 789];
$endpoints = array_map(function($id) { 
    return "/users/$id"; 
}, $userIds);

$userData = $client->fetchMultiple($endpoints);

// Process batch of items
$products = [
    ['id' => 1, 'name' => 'Product 1', 'price' => 19.99],
    ['id' => 2, 'name' => 'Product 2', 'price' => 29.99],
    // ... more products
];

$results = $client->batchProcess($products, '/products/update');
```

### API Testing and Documentation

Create test cases for your API integrations:

```php
<?php
use PHPUnit\Framework\TestCase;

class WeatherApiTest extends TestCase {
    private $apiClient;
    private $mockHandler;
    
    protected function setUp(): void {
        // Create mock handler for testing
        $this->mockHandler = new \GuzzleHttp\Handler\MockHandler();
        $handlerStack = \GuzzleHttp\HandlerStack::create($this->mockHandler);
        
        $client = new \GuzzleHttp\Client(['handler' => $handlerStack]);
        
        // Inject mocked client into API client
        $this->apiClient = new WeatherApiClient('fake_api_key');
        $this->apiClient->setHttpClient($client);
    }
    
    public function testGetCurrentWeatherSuccess() {
        // Mock successful response
        $mockResponse = new \GuzzleHttp\Psr7\Response(200, [], json_encode([
            'location' => [
                'name' => 'New York',
                'country' => 'USA'
            ],
            'current' => [
                'temp_c' => 22.5,
                'condition' => [
                    'text' => 'Sunny',
                    'icon' => '//cdn.example.com/sunny.png'
                ]
            ]
        ]));
        
        $this->mockHandler->append($mockResponse);
        
        $result = $this->apiClient->getCurrentWeather('New York');
        
        $this->assertEquals('New York', $result['location']['name']);
        $this->assertEquals(22.5, $result['current']['temp_c']);
        $this->assertEquals('Sunny', $result['current']['condition']['text']);
    }
    
    public function testGetCurrentWeatherError() {
        // Mock error response
        $mockResponse = new \GuzzleHttp\Psr7\Response(401, [], json_encode([
            'error' => [
                'code' => 1002,
                'message' => 'API key invalid'
            ]
        ]));
        
        $this->mockHandler->append($mockResponse);
        
        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('API key invalid');
        
        $this->apiClient->getCurrentWeather('New York');
    }
    
    public function testRateLimitHandling() {
        // Mock rate limit response
        $mockResponse = new \GuzzleHttp\Psr7\Response(429, [
            'Retry-After' => '30'
        ], json_encode([
            'error' => 'Rate limit exceeded'
        ]));
        
        $this->mockHandler->append($mockResponse);
        
        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('Rate limit exceeded. Try again in 30 seconds');
        
        $this->apiClient->getCurrentWeather('New York');
    }
}
```

### GraphQL API Consumption

Working with GraphQL APIs:

```php
<?php
class GraphQLClient {
    private $endpoint;
    private $headers;
    
    public function __construct($endpoint, $token = null) {
        $this->endpoint = $endpoint;
        $this->headers = [
            'Content-Type: application/json',
            'Accept: application/json'
        ];
        
        if ($token) {
            $this->headers[] = 'Authorization: Bearer ' . $token;
        }
    }
    
    public function query($query, $variables = []) {
        $data = [
            'query' => $query,
            'variables' => $variables
        ];
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $this->endpoint);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        curl_setopt($ch, CURLOPT_HTTPHEADER, $this->headers);
        
        $response = curl_exec($ch);
        $statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($statusCode !== 200) {
            throw new \Exception("GraphQL request failed with status code: $statusCode");
        }
        
        $result = json_decode($response, true);
        
        if (isset($result['errors'])) {
            $errorMessage = $result['errors'][0]['message'] ?? 'Unknown GraphQL error';
            throw new \Exception("GraphQL error: $errorMessage");
        }
        
        return $result['data'];
    }
}

// Usage example
$client = new GraphQLClient(
    'https://api.github.com/graphql',
    'your_github_token'
);

// Query repositories
$query = <<<'GRAPHQL'
query ($username: String!, $count: Int!) {
  user(login: $username) {
    repositories(first: $count, orderBy: {field: STARGAZERS, direction: DESC}) {
      nodes {
        name
        description
        stargazers {
          totalCount
        }
        primaryLanguage {
          name
        }
      }
    }
  }
}
GRAPHQL;

$variables = [
    'username' => 'octocat',
    'count' => 5
];

try {
    $result = $client->query($query, $variables);
    
    $repositories = $result['user']['repositories']['nodes'];
    foreach ($repositories as $repo) {
        echo "Repository: {$repo['name']}\n";
        echo "Description: {$repo['description']}\n";
        echo "Stars: {$repo['stargazers']['totalCount']}\n";
        echo "Language: {$repo['primaryLanguage']['name'] ?? 'N/A'}\n";
        echo "-----------------------------------\n";
    }
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage();
}
```

### Real-World API Integration Example

A complete integration with a payment gateway API:

```php
<?php
class StripePaymentGateway {
    private $client;
    private $apiKey;
    
    public function __construct($apiKey, $isTest = false) {
        $this->apiKey = $apiKey;
        $this->baseUrl = $isTest ? 
            'https://api.stripe.com/v1/test/' : 
            'https://api.stripe.com/v1/';
        
        $this->client = new \GuzzleHttp\Client([
            'base_uri' => $this->baseUrl,
            'headers' => [
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/x-www-form-urlencoded',
                'Stripe-Version' => '2020-08-27'
            ]
        ]);
    }
    
    public function createCustomer($email, $name, $metadata = []) {
        try {
            $response = $this->client->post('customers', [
                'form_params' => [
                    'email' => $email,
                    'name' => $name,
                    'metadata' => $metadata
                ]
            ]);
            
            return json_decode($response->getBody(), true);
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            $this->handleApiError($e);
        }
    }
    
    public function createPaymentIntent($amount, $currency, $customerId, $paymentMethodId = null) {
        try {
            $params = [
                'amount' => $amount, // Amount in cents
                'currency' => $currency,
                'customer' => $customerId,
                'confirmation_method' => 'automatic',
                'confirm' => $paymentMethodId ? true : false,
            ];
            
            if ($paymentMethodId) {
                $params['payment_method'] = $paymentMethodId;
            }
            
            $response = $this->client->post('payment_intents', [
                'form_params' => $params
            ]);
            
            return json_decode($response->getBody(), true);
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            $this->handleApiError($e);
        }
    }
    
    public function confirmPaymentIntent($paymentIntentId, $paymentMethodId) {
        try {
            $response = $this->client->post("payment_intents/{$paymentIntentId}/confirm", [
                'form_params' => [
                    'payment_method' => $paymentMethodId
                ]
            ]);
            
            return json_decode($response->getBody(), true);
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            $this->handleApiError($e);
        }
    }
    
    public function retrievePaymentIntent($paymentIntentId) {
        try {
            $response = $this->client->get("payment_intents/{$paymentIntentId}");
            return json_decode($response->getBody(), true);
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            $this->handleApiError($e);
        }
    }
    
    public function createSubscription($customerId, $priceId) {
        try {
            $response = $this->client->post('subscriptions', [
                'form_params' => [
                    'customer' => $customerId,
                    'items' => [
                        ['price' => $priceId]
                    ]
                ]
            ]);
            
            return json_decode($response->getBody(), true);
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            $this->handleApiError($e);
        }
    }
    
    private function handleApiError($exception) {
        if ($exception instanceof \GuzzleHttp\Exception\ClientException) {
            $response = $exception->getResponse();
            $error = json_decode($response->getBody(), true);
            
            throw new \Exception(
                $error['error']['message'] ?? 'Unknown Stripe error',
                $response->getStatusCode()
            );
        }
        
        throw new \Exception('Payment gateway communication error: ' . $exception->getMessage());
    }
}

// Usage example:
$gateway = new StripePaymentGateway('sk_test_your_test_key', true);

try {
    // Create a customer
    $customer = $gateway->createCustomer(
        'customer@example.com',
        'John Doe',
        ['user_id' => '123456']
    );
    
    // Create a payment intent
    $paymentIntent = $gateway->createPaymentIntent(
        2500, // $25.00
        'usd',
        $customer['id']
    );
    
    // The client would use the payment intent's client_secret to collect payment method details
    $clientSecret = $paymentIntent['client_secret'];
    
    // After collecting payment details on the client:
    $confirmedPayment = $gateway->confirmPaymentIntent(
        $paymentIntent['id'],
        'pm_card_visa' // In production, this would be a real payment method ID
    );
    
    if ($confirmedPayment['status'] === 'succeeded') {
        echo "Payment completed successfully!";
    } else if ($confirmedPayment['status'] === 'requires_action') {
        // Handle 3D Secure or other authentication
        echo "Additional authentication required";
    }
    
} catch (\Exception $e) {
    echo "Payment error: " . $e->getMessage();
}
```

**Conclusion**

Effectively consuming APIs in PHP requires mastering HTTP requests, data format handling, authentication methods, and implementing best practices for caching, error handling, and testing. Structured API integration enables reliable communication with external services, enhancing your applications with third-party capabilities while maintaining performance and security. As APIs evolve, keeping your implementation patterns modular and testable allows for easier maintenance and adaptation to changing requirements.

**Related Topics**

- RESTful API design principles
- API versioning strategies
- OAuth 2.0 and OpenID Connect implementation
- API documentation tools like Swagger/OpenAPI
- API gateway patterns and implementation
- Microservices architecture and communication
- Event-driven architecture with webhooks

---

