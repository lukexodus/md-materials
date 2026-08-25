## `http` Module


The http module is Python's built-in package for HTTP-related functionality, providing both client and server capabilities. It consists of several submodules that handle different aspects of HTTP communication, from basic HTTP status codes to full-featured web servers and cookie management.

### Module Structure

The http package contains four main submodules. The `http.client` module provides low-level HTTP client functionality for making HTTP requests. The `http.server` module contains classes for building HTTP servers. The `http.cookies` module handles HTTP cookie parsing and generation. The `http.cookiejar` module provides cookie storage and management for HTTP clients.

### HTTP Status Codes with http.HTTPStatus

The `http.HTTPStatus` enumeration provides a comprehensive collection of HTTP status codes:

```python
from http import HTTPStatus

# Access status codes
print(HTTPStatus.OK)  # 200
print(HTTPStatus.NOT_FOUND)  # 404
print(HTTPStatus.INTERNAL_SERVER_ERROR)  # 500

# Get status code properties
status = HTTPStatus.OK
print(f"Code: {status.value}")
print(f"Phrase: {status.phrase}")
print(f"Description: {status.description}")
```

### HTTP Client with http.client

The `http.client` module provides low-level HTTP client functionality:

#### Basic HTTP Requests

```python
import http.client
import json

# HTTP connection
conn = http.client.HTTPConnection('httpbin.org')

# Make GET request
conn.request('GET', '/get')
response = conn.getresponse()

print(f"Status: {response.status}")
print(f"Reason: {response.reason}")
print(f"Headers: {dict(response.getheaders())}")

data = response.read()
print(f"Response: {data.decode('utf-8')}")

conn.close()
```

#### HTTPS Connections

```python
import http.client
import ssl

# HTTPS connection
conn = http.client.HTTPSConnection('httpbin.org')

# Make GET request
conn.request('GET', '/get')
response = conn.getresponse()

print(f"Status: {response.status}")
data = response.read().decode('utf-8')
print(data)

conn.close()
```

#### POST Requests with Data

```python
import http.client
import json

conn = http.client.HTTPSConnection('httpbin.org')

# Prepare POST data
post_data = {
    'name': 'John Doe',
    'email': 'john@example.com'
}

json_data = json.dumps(post_data)
headers = {'Content-Type': 'application/json'}

# Make POST request
conn.request('POST', '/post', body=json_data, headers=headers)
response = conn.getresponse()

print(f"Status: {response.status}")
result = response.read().decode('utf-8')
print(result)

conn.close()
```

#### Custom Headers and Authentication

```python
import http.client
import base64

conn = http.client.HTTPSConnection('httpbin.org')

# Basic authentication
username = 'testuser'
password = 'testpass'
credentials = base64.b64encode(f"{username}:{password}".encode()).decode()

headers = {
    'Authorization': f'Basic {credentials}',
    'User-Agent': 'Python HTTP Client',
    'Accept': 'application/json'
}

conn.request('GET', '/basic-auth/testuser/testpass', headers=headers)
response = conn.getresponse()

print(f"Status: {response.status}")
data = response.read().decode('utf-8')
print(data)

conn.close()
```

### Connection Context Manager

Using connections as context managers for automatic cleanup:

```python
import http.client

with http.client.HTTPSConnection('httpbin.org') as conn:
    conn.request('GET', '/get')
    response = conn.getresponse()
    data = response.read().decode('utf-8')
    print(data)
```

### HTTP Server with http.server

The `http.server` module provides classes for building HTTP servers:

#### Simple HTTP Server

```python
import http.server
import socketserver

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b'<html><body><h1>Hello, World!</h1></body></html>')

PORT = 8000

with socketserver.TCPServer(("", PORT), MyHandler) as httpd:
    print(f"Server running on port {PORT}")
    httpd.serve_forever()
```

#### Custom HTTP Handler

```python
import http.server
import json
import urllib.parse

class APIHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/status':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            response = {'status': 'ok', 'message': 'Server is running'}
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_POST(self):
        if self.path == '/api/data':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                data = json.loads(post_data.decode('utf-8'))
                
                # Process data
                response = {'received': data, 'processed': True}
                
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(response).encode())
            except json.JSONDecodeError:
                self.send_response(400)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

# Run server
if __name__ == '__main__':
    import socketserver
    PORT = 8000
    
    with socketserver.TCPServer(("", PORT), APIHandler) as httpd:
        print(f"API Server running on port {PORT}")
        httpd.serve_forever()
```

#### File Server

```python
import http.server
import socketserver
import os

class FileHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory='/path/to/files', **kwargs)

PORT = 8000

with socketserver.TCPServer(("", PORT), FileHandler) as httpd:
    print(f"File server running on port {PORT}")
    httpd.serve_forever()
```

### Cookie Management with http.cookies

The `http.cookies` module handles HTTP cookie parsing and creation:

#### Creating Cookies

```python
import http.cookies

# Create cookie
cookie = http.cookies.SimpleCookie()
cookie['session_id'] = 'abc123'
cookie['session_id']['expires'] = 'Wed, 01 Jan 2025 00:00:00 GMT'
cookie['session_id']['path'] = '/'
cookie['session_id']['domain'] = '.example.com'
cookie['session_id']['secure'] = True
cookie['session_id']['httponly'] = True

print(cookie.output())
```

**Output:**

```
Set-Cookie: session_id=abc123; Domain=.example.com; expires=Wed, 01 Jan 2025 00:00:00 GMT; HttpOnly; Path=/; Secure
```

#### Parsing Cookies

```python
import http.cookies

# Parse cookie string
cookie_string = 'session_id=abc123; user_pref=dark_mode; lang=en'
cookie = http.cookies.SimpleCookie()
cookie.load(cookie_string)

for key, morsel in cookie.items():
    print(f"{key}: {morsel.value}")
```

#### Advanced Cookie Handling

```python
import http.cookies
from datetime import datetime, timedelta

cookie = http.cookies.SimpleCookie()

# Set cookie with expiration
cookie['auth_token'] = 'xyz789'
expire_date = datetime.utcnow() + timedelta(hours=24)
cookie['auth_token']['expires'] = expire_date.strftime('%a, %d %b %Y %H:%M:%S GMT')

# Set cookie attributes
cookie['preferences'] = 'theme=dark&lang=en'
cookie['preferences']['max-age'] = 3600  # 1 hour
cookie['preferences']['samesite'] = 'Strict'

print(cookie.output())
```

### Cookie Jar with http.cookiejar

The `http.cookiejar` module provides cookie storage for HTTP clients:

```python
import http.cookiejar
import urllib.request

# Create cookie jar
cookie_jar = http.cookiejar.CookieJar()

# Create opener with cookie support
opener = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(cookie_jar)
)

# Make request (cookies will be stored)
response = opener.open('https://httpbin.org/cookies/set/session/abc123')

# Print stored cookies
for cookie in cookie_jar:
    print(f"Cookie: {cookie.name}={cookie.value}")
    print(f"Domain: {cookie.domain}")
    print(f"Path: {cookie.path}")
```

### Persistent Cookie Storage

```python
import http.cookiejar
import urllib.request

# Create persistent cookie jar
cookie_jar = http.cookiejar.MozillaCookieJar('cookies.txt')

# Try to load existing cookies
try:
    cookie_jar.load()
except FileNotFoundError:
    pass

# Create opener
opener = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(cookie_jar)
)

# Make requests
response = opener.open('https://httpbin.org/cookies/set/persistent/true')

# Save cookies to file
cookie_jar.save()
```

### HTTP Client Error Handling

```python
import http.client
import socket

try:
    conn = http.client.HTTPSConnection('httpbin.org', timeout=5)
    conn.request('GET', '/status/404')
    response = conn.getresponse()
    
    if response.status == 404:
        print("Resource not found")
    elif response.status >= 400:
        print(f"Client error: {response.status}")
    elif response.status >= 500:
        print(f"Server error: {response.status}")
    else:
        print(f"Success: {response.status}")
        
except http.client.HTTPException as e:
    print(f"HTTP error: {e}")
except socket.timeout:
    print("Request timed out")
except socket.error as e:
    print(f"Socket error: {e}")
finally:
    conn.close()
```

### Connection Pooling

```python
import http.client
import threading

class ConnectionPool:
    def __init__(self, host, port=None, max_connections=10):
        self.host = host
        self.port = port
        self.max_connections = max_connections
        self.connections = []
        self.lock = threading.Lock()
    
    def get_connection(self):
        with self.lock:
            if self.connections:
                return self.connections.pop()
            else:
                if self.port:
                    return http.client.HTTPConnection(self.host, self.port)
                else:
                    return http.client.HTTPSConnection(self.host)
    
    def return_connection(self, conn):
        with self.lock:
            if len(self.connections) < self.max_connections:
                self.connections.append(conn)
            else:
                conn.close()
    
    def close_all(self):
        with self.lock:
            for conn in self.connections:
                conn.close()
            self.connections.clear()

# Usage
pool = ConnectionPool('httpbin.org')
conn = pool.get_connection()
conn.request('GET', '/get')
response = conn.getresponse()
data = response.read()
pool.return_connection(conn)
```

### Streaming Responses

```python
import http.client

conn = http.client.HTTPSConnection('httpbin.org')
conn.request('GET', '/stream/20')
response = conn.getresponse()

# Read response in chunks
while True:
    chunk = response.read(1024)
    if not chunk:
        break
    print(f"Received chunk: {len(chunk)} bytes")
    # Process chunk
    print(chunk.decode('utf-8'))

conn.close()
```

### Custom HTTP Methods

```python
import http.client

conn = http.client.HTTPSConnection('httpbin.org')

# Custom HTTP method
conn.request('PATCH', '/patch', body='{"op": "replace", "path": "/name", "value": "new_name"}')
response = conn.getresponse()

print(f"Status: {response.status}")
data = response.read().decode('utf-8')
print(data)

conn.close()
```

### Server-Side Cookie Handling

```python
import http.server
import http.cookies
import json

class CookieHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        # Parse cookies from request
        cookie_header = self.headers.get('Cookie')
        cookies = http.cookies.SimpleCookie()
        
        if cookie_header:
            cookies.load(cookie_header)
        
        if self.path == '/set-cookie':
            # Set a cookie
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            
            # Create new cookie
            new_cookie = http.cookies.SimpleCookie()
            new_cookie['user_id'] = '12345'
            new_cookie['user_id']['max-age'] = 3600
            
            self.send_header('Set-Cookie', new_cookie.output().split(': ')[1])
            self.end_headers()
            
            self.wfile.write(b'<html><body><h1>Cookie Set!</h1></body></html>')
        
        elif self.path == '/show-cookies':
            # Display cookies
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            cookie_dict = {key: morsel.value for key, morsel in cookies.items()}
            response = json.dumps(cookie_dict, indent=2)
            self.wfile.write(response.encode())
        
        else:
            self.send_response(404)
            self.end_headers()

# Run server
if __name__ == '__main__':
    import socketserver
    PORT = 8000
    
    with socketserver.TCPServer(("", PORT), CookieHandler) as httpd:
        print(f"Cookie server running on port {PORT}")
        httpd.serve_forever()
```

### HTTP/2 Support

While `http.client` primarily supports HTTP/1.1, you can check for HTTP/2 support:

```python
import http.client
import ssl

# Create connection with HTTP/2 support
context = ssl.create_default_context()
context.set_alpn_protocols(['h2', 'http/1.1'])

conn = http.client.HTTPSConnection('httpbin.org', context=context)
conn.request('GET', '/get')
response = conn.getresponse()

print(f"Protocol: {getattr(response, 'version', 'Unknown')}")
print(f"Status: {response.status}")

conn.close()
```

### Debugging HTTP Communications

```python
import http.client
import logging

# Enable debug logging
http.client.HTTPConnection.debuglevel = 1

# Set up logging
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

# Make request with debug output
conn = http.client.HTTPSConnection('httpbin.org')
conn.request('GET', '/get')
response = conn.getresponse()
data = response.read()

conn.close()
```

### Performance Considerations

The `http.client` module provides low-level control but requires manual connection management. For production applications, consider implementing connection pooling to reuse connections and reduce overhead. Always close connections properly to avoid resource leaks, and use context managers when possible for automatic cleanup.

### Thread Safety

The `http.client` connections are not thread-safe. When using multiple threads, either create separate connections for each thread or implement proper synchronization:

```python
import http.client
import threading

class ThreadSafeHTTPClient:
    def __init__(self, host):
        self.host = host
        self.local = threading.local()
    
    def get_connection(self):
        if not hasattr(self.local, 'connection'):
            self.local.connection = http.client.HTTPSConnection(self.host)
        return self.local.connection
    
    def request(self, method, url, **kwargs):
        conn = self.get_connection()
        conn.request(method, url, **kwargs)
        return conn.getresponse()

# Usage
client = ThreadSafeHTTPClient('httpbin.org')
response = client.request('GET', '/get')
```

**Key points:**

- http.client provides low-level HTTP client functionality with full control
- http.server enables building custom HTTP servers with minimal code
- http.cookies handles cookie parsing and generation for both clients and servers
- Always properly close connections to prevent resource leaks
- Use context managers for automatic connection cleanup
- Consider connection pooling for production applications with high request volumes

**Next steps:** For more advanced HTTP functionality, explore frameworks like Flask or Django for server-side development, or libraries like `requests` for simpler client-side HTTP operations. Understanding the http module provides the foundation for working with these higher-level tools.

---

