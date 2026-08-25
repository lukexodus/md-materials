## `urllib` Module


The urllib module is Python's built-in library for handling URLs and making HTTP requests. It provides a comprehensive set of tools for opening URLs, parsing URLs, handling cookies, authentication, and various web-related tasks without requiring external dependencies.

### Module Structure

The urllib package consists of several submodules, each serving specific purposes. The `urllib.request` module opens URLs and handles HTTP requests. The `urllib.parse` module parses URLs and handles URL encoding/decoding. The `urllib.error` module defines exception classes for urllib operations. The `urllib.robotparser` module parses robots.txt files.

### Basic URL Opening with urllib.request

The simplest way to open a URL is using `urlopen()`:

```python
import urllib.request

response = urllib.request.urlopen('https://httpbin.org/get')
content = response.read()
print(content.decode('utf-8'))
```

### Response Objects

The `urlopen()` function returns a response object with various methods and attributes:

```python
import urllib.request

response = urllib.request.urlopen('https://httpbin.org/get')

# Read response content
content = response.read()

# Get response headers
headers = response.headers
print(f"Content-Type: {headers['Content-Type']}")

# Get status code
status = response.getcode()
print(f"Status: {status}")

# Get URL (useful for redirects)
url = response.geturl()
print(f"Final URL: {url}")
```

### Making Different HTTP Requests

#### GET Requests with Parameters

```python
import urllib.request
import urllib.parse

# Method 1: Build URL with parameters
base_url = 'https://httpbin.org/get'
params = {'key1': 'value1', 'key2': 'value2'}
query_string = urllib.parse.urlencode(params)
full_url = f"{base_url}?{query_string}"

response = urllib.request.urlopen(full_url)
data = response.read().decode('utf-8')
```

#### POST Requests

```python
import urllib.request
import urllib.parse
import json

# Prepare POST data
post_data = {
    'username': 'testuser',
    'password': 'testpass'
}

# Encode data
data = urllib.parse.urlencode(post_data).encode('utf-8')

# Create request
request = urllib.request.Request(
    'https://httpbin.org/post',
    data=data,
    headers={'Content-Type': 'application/x-www-form-urlencoded'}
)

# Send request
response = urllib.request.urlopen(request)
result = response.read().decode('utf-8')
```

#### JSON POST Requests

```python
import urllib.request
import json

# Prepare JSON data
post_data = {
    'name': 'John Doe',
    'email': 'john@example.com'
}

json_data = json.dumps(post_data).encode('utf-8')

# Create request
request = urllib.request.Request(
    'https://httpbin.org/post',
    data=json_data,
    headers={'Content-Type': 'application/json'}
)

response = urllib.request.urlopen(request)
```

### Custom Headers

Adding custom headers to requests:

```python
import urllib.request

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'application/json',
    'Authorization': 'Bearer your-token-here'
}

request = urllib.request.Request(
    'https://api.example.com/data',
    headers=headers
)

response = urllib.request.urlopen(request)
```

### URL Parsing with urllib.parse

The `urllib.parse` module provides powerful URL manipulation capabilities:

#### Parsing URLs

```python
import urllib.parse

url = 'https://example.com:8080/path/to/resource?param1=value1&param2=value2#fragment'

# Parse URL into components
parsed = urllib.parse.urlparse(url)
print(f"Scheme: {parsed.scheme}")
print(f"Hostname: {parsed.hostname}")
print(f"Port: {parsed.port}")
print(f"Path: {parsed.path}")
print(f"Query: {parsed.query}")
print(f"Fragment: {parsed.fragment}")
```

#### Building URLs

```python
import urllib.parse

# Build URL from components
components = urllib.parse.ParseResult(
    scheme='https',
    netloc='api.example.com',
    path='/v1/users',
    params='',
    query='limit=10&offset=0',
    fragment=''
)

url = urllib.parse.urlunparse(components)
print(url)
```

#### URL Encoding and Decoding

```python
import urllib.parse

# URL encoding
text = "Hello World & Special Characters!"
encoded = urllib.parse.quote(text)
print(f"Encoded: {encoded}")

# URL decoding
decoded = urllib.parse.unquote(encoded)
print(f"Decoded: {decoded}")

# Query parameter encoding
params = {'message': 'Hello World!', 'type': 'greeting'}
query_string = urllib.parse.urlencode(params)
print(f"Query string: {query_string}")
```

#### Parsing Query Strings

```python
import urllib.parse

query_string = 'name=John&age=30&city=New%20York'
parsed_params = urllib.parse.parse_qs(query_string)
print(parsed_params)
# Output: {'name': ['John'], 'age': ['30'], 'city': ['New York']}

# For single values, use parse_qs with keep_blank_values
single_values = {k: v[0] for k, v in parsed_params.items()}
print(single_values)
```

### Error Handling

Proper error handling is crucial when working with network requests:

```python
import urllib.request
import urllib.error

try:
    response = urllib.request.urlopen('https://httpbin.org/status/404')
    data = response.read()
except urllib.error.HTTPError as e:
    print(f"HTTP Error: {e.code} - {e.reason}")
    print(f"Response body: {e.read().decode('utf-8')}")
except urllib.error.URLError as e:
    print(f"URL Error: {e.reason}")
except Exception as e:
    print(f"Other error: {e}")
```

### Handling Redirects

```python
import urllib.request
import urllib.error

try:
    response = urllib.request.urlopen('https://httpbin.org/redirect/3')
    print(f"Final URL: {response.geturl()}")
    print(f"Status: {response.getcode()}")
except urllib.error.HTTPError as e:
    print(f"HTTP Error: {e.code}")
```

### Authentication

#### Basic Authentication

```python
import urllib.request
import base64

# Method 1: Using HTTPPasswordMgrWithDefaultRealm
password_mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()
password_mgr.add_password(None, 'https://httpbin.org', 'username', 'password')

handler = urllib.request.HTTPBasicAuthHandler(password_mgr)
opener = urllib.request.build_opener(handler)

response = opener.open('https://httpbin.org/basic-auth/username/password')
data = response.read().decode('utf-8')
```

#### Manual Basic Authentication

```python
import urllib.request
import base64

username = 'testuser'
password = 'testpass'

# Create base64 encoded credentials
credentials = f"{username}:{password}"
encoded_credentials = base64.b64encode(credentials.encode('utf-8')).decode('utf-8')

# Create request with Authorization header
request = urllib.request.Request('https://httpbin.org/basic-auth/testuser/testpass')
request.add_header('Authorization', f'Basic {encoded_credentials}')

response = urllib.request.urlopen(request)
```

### Handling Cookies

```python
import urllib.request
import urllib.parse
import http.cookiejar

# Create cookie jar
cookie_jar = http.cookiejar.CookieJar()

# Create opener with cookie support
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookie_jar))

# Make request (cookies will be automatically stored)
response = opener.open('https://httpbin.org/cookies/set/sessionid/abc123')

# Make another request (cookies will be automatically sent)
response = opener.open('https://httpbin.org/cookies')
data = response.read().decode('utf-8')
print(data)
```

### File Downloads

#### Simple File Download

```python
import urllib.request

url = 'https://httpbin.org/json'
filename = 'downloaded_data.json'

urllib.request.urlretrieve(url, filename)
print(f"File downloaded as {filename}")
```

#### Download with Progress Tracking

```python
import urllib.request
import sys

def download_progress(block_num, block_size, total_size):
    downloaded = block_num * block_size
    if total_size > 0:
        percent = min(downloaded * 100 / total_size, 100)
        sys.stdout.write(f"\rDownload progress: {percent:.1f}%")
        sys.stdout.flush()

url = 'https://httpbin.org/bytes/1000'
filename = 'large_file.bin'

urllib.request.urlretrieve(url, filename, reporthook=download_progress)
print(f"\nDownload complete: {filename}")
```

### Working with Proxies

```python
import urllib.request

# Set up proxy
proxy_handler = urllib.request.ProxyHandler({
    'http': 'http://proxy.example.com:8080',
    'https': 'https://proxy.example.com:8080'
})

opener = urllib.request.build_opener(proxy_handler)

# Use proxy for requests
response = opener.open('https://httpbin.org/ip')
data = response.read().decode('utf-8')
```

### SSL and HTTPS Handling

#### Custom SSL Context

```python
import urllib.request
import ssl

# Create custom SSL context
context = ssl.create_default_context()
context.check_hostname = False
context.verify_mode = ssl.CERT_NONE

# Use custom context
request = urllib.request.Request('https://self-signed.badssl.com/')
response = urllib.request.urlopen(request, context=context)
```

### Advanced Request Customization

#### Custom Opener

```python
import urllib.request

# Create custom opener with multiple handlers
cookie_jar = http.cookiejar.CookieJar()
cookie_processor = urllib.request.HTTPCookieProcessor(cookie_jar)
redirect_handler = urllib.request.HTTPRedirectHandler()

opener = urllib.request.build_opener(
    cookie_processor,
    redirect_handler
)

# Install as global default (optional)
urllib.request.install_opener(opener)

# Use opener
response = opener.open('https://httpbin.org/cookies')
```

### Timeouts and Connection Control

```python
import urllib.request
import socket

# Set global timeout
socket.setdefaulttimeout(10)

# Or set timeout for specific request
try:
    response = urllib.request.urlopen('https://httpbin.org/delay/5', timeout=3)
except socket.timeout:
    print("Request timed out")
```

### Working with FTP

```python
import urllib.request

# FTP download
ftp_url = 'ftp://ftp.example.com/path/to/file.txt'
try:
    response = urllib.request.urlopen(ftp_url)
    content = response.read()
    print(content.decode('utf-8'))
except Exception as e:
    print(f"FTP Error: {e}")
```

### Robots.txt Parsing

```python
import urllib.robotparser

# Parse robots.txt
rp = urllib.robotparser.RobotFileParser()
rp.set_url('https://example.com/robots.txt')
rp.read()

# Check if URL is allowed
can_fetch = rp.can_fetch('*', 'https://example.com/some-page')
print(f"Can fetch: {can_fetch}")
```

### Common Patterns and Best Practices

#### Session-like Behavior

```python
import urllib.request
import http.cookiejar

class URLSession:
    def __init__(self):
        self.cookie_jar = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(
            urllib.request.HTTPCookieProcessor(self.cookie_jar)
        )
    
    def get(self, url, headers=None):
        request = urllib.request.Request(url, headers=headers or {})
        return self.opener.open(request)
    
    def post(self, url, data=None, headers=None):
        if isinstance(data, dict):
            data = urllib.parse.urlencode(data).encode('utf-8')
        request = urllib.request.Request(url, data=data, headers=headers or {})
        return self.opener.open(request)

# Usage
session = URLSession()
response = session.get('https://httpbin.org/cookies/set/session/abc123')
response = session.get('https://httpbin.org/cookies')
```

#### Rate Limiting

```python
import urllib.request
import time

class RateLimitedOpener:
    def __init__(self, delay=1):
        self.delay = delay
        self.last_request_time = 0
    
    def open(self, url):
        current_time = time.time()
        time_since_last = current_time - self.last_request_time
        
        if time_since_last < self.delay:
            time.sleep(self.delay - time_since_last)
        
        self.last_request_time = time.time()
        return urllib.request.urlopen(url)

# Usage
opener = RateLimitedOpener(delay=2)  # 2 second delay between requests
response = opener.open('https://httpbin.org/get')
```

### Performance Considerations

For production applications, consider connection pooling and persistent connections. The urllib module creates new connections for each request, which can be inefficient for multiple requests to the same server. Consider using connection pooling libraries or implementing custom connection management for high-performance applications.

### Debugging and Logging

```python
import urllib.request
import http.client

# Enable debug logging
http.client.HTTPConnection.debuglevel = 1

# Make request with debug output
response = urllib.request.urlopen('https://httpbin.org/get')
```

**Key points:**

- urllib is part of Python's standard library, requiring no additional installations
- Always handle urllib.error.HTTPError and urllib.error.URLError exceptions
- Use Request objects for complex requests with custom headers and data
- urllib.parse provides comprehensive URL manipulation capabilities
- Consider using session-like patterns for multiple related requests
- Set appropriate timeouts to prevent hanging requests

**Next steps:** For more advanced HTTP client needs, consider exploring the `requests` library, which provides a more user-friendly API, or `aiohttp` for asynchronous HTTP operations. Understanding urllib provides a solid foundation for all HTTP-related work in Python.

---

