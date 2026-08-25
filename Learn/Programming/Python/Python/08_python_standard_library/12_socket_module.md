## `socket` Module


The socket module provides access to the BSD socket interface, enabling network communication between applications across networks or on the same machine. It supports various socket types and protocols for building networked applications.

### Module Import and Basic Concepts

```python
import socket

# Basic socket creation
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
```

### Socket Families and Types

### Address Families

- `AF_INET` - IPv4 Internet protocols
- `AF_INET6` - IPv6 Internet protocols
- `AF_UNIX` - Unix domain sockets (local communication)
- `AF_BLUETOOTH` - Bluetooth protocols

### Socket Types

- `SOCK_STREAM` - TCP (reliable, connection-oriented)
- `SOCK_DGRAM` - UDP (unreliable, connectionless)
- `SOCK_RAW` - Raw sockets (requires privileges)

### Creating Sockets

### Basic Socket Creation

```python
import socket

# TCP socket (IPv4)
tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# UDP socket (IPv4)
udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# IPv6 TCP socket
ipv6_socket = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)

# Unix domain socket
unix_socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
```

### Socket Options

```python
# Set socket options
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Allow address reuse
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

# Set receive buffer size
sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 4096)

# Set send buffer size
sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 4096)

# Get socket options
buffer_size = sock.getsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF)
```

### TCP Server Implementation

### Basic TCP Server

```python
import socket
import threading

def handle_client(client_socket, address):
    try:
        while True:
            # Receive data from client
            data = client_socket.recv(1024)
            if not data:
                break
            
            print(f"Received from {address}: {data.decode()}")
            
            # Echo back to client
            client_socket.send(data)
            
    except Exception as e:
        print(f"Error handling client {address}: {e}")
    finally:
        client_socket.close()

def tcp_server(host='localhost', port=12345):
    # Create socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # Allow address reuse
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        # Bind socket to address
        server_socket.bind((host, port))
        
        # Listen for connections
        server_socket.listen(5)
        print(f"Server listening on {host}:{port}")
        
        while True:
            # Accept client connection
            client_socket, address = server_socket.accept()
            print(f"Connection from {address}")
            
            # Handle client in separate thread
            client_thread = threading.Thread(
                target=handle_client,
                args=(client_socket, address)
            )
            client_thread.start()
            
    except Exception as e:
        print(f"Server error: {e}")
    finally:
        server_socket.close()

# Run server
if __name__ == "__main__":
    tcp_server()
```

### Advanced TCP Server with Context Manager

```python
import socket
import threading
from contextlib import contextmanager

@contextmanager
def tcp_server_socket(host, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        sock.bind((host, port))
        sock.listen(5)
        yield sock
    finally:
        sock.close()

def advanced_tcp_server():
    with tcp_server_socket('localhost', 12345) as server_socket:
        print("Server started on localhost:12345")
        
        while True:
            try:
                client_socket, address = server_socket.accept()
                threading.Thread(
                    target=handle_client,
                    args=(client_socket, address),
                    daemon=True
                ).start()
            except KeyboardInterrupt:
                print("Server shutting down...")
                break
```

### TCP Client Implementation

### Basic TCP Client

```python
import socket

def tcp_client(host='localhost', port=12345):
    # Create socket
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        # Connect to server
        client_socket.connect((host, port))
        print(f"Connected to {host}:{port}")
        
        # Send data
        message = "Hello, Server!"
        client_socket.send(message.encode())
        
        # Receive response
        response = client_socket.recv(1024)
        print(f"Server response: {response.decode()}")
        
    except Exception as e:
        print(f"Client error: {e}")
    finally:
        client_socket.close()

# Run client
tcp_client()
```

### Interactive TCP Client

```python
import socket
import threading

def receive_messages(sock):
    while True:
        try:
            message = sock.recv(1024).decode()
            if not message:
                break
            print(f"Received: {message}")
        except:
            break

def interactive_tcp_client():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        sock.connect(('localhost', 12345))
        
        # Start receiving thread
        receive_thread = threading.Thread(target=receive_messages, args=(sock,))
        receive_thread.daemon = True
        receive_thread.start()
        
        # Send messages
        while True:
            message = input()
            if message.lower() == 'quit':
                break
            sock.send(message.encode())
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        sock.close()
```

### UDP Socket Implementation

### UDP Server

```python
import socket

def udp_server(host='localhost', port=12345):
    # Create UDP socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    try:
        # Bind to address
        server_socket.bind((host, port))
        print(f"UDP Server listening on {host}:{port}")
        
        while True:
            # Receive data and client address
            data, client_address = server_socket.recvfrom(1024)
            print(f"Received from {client_address}: {data.decode()}")
            
            # Send response back to client
            response = f"Echo: {data.decode()}"
            server_socket.sendto(response.encode(), client_address)
            
    except Exception as e:
        print(f"UDP Server error: {e}")
    finally:
        server_socket.close()

# Run UDP server
udp_server()
```

### UDP Client

```python
import socket

def udp_client(host='localhost', port=12345):
    # Create UDP socket
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    try:
        # Send data to server
        message = "Hello, UDP Server!"
        client_socket.sendto(message.encode(), (host, port))
        
        # Receive response
        response, server_address = client_socket.recvfrom(1024)
        print(f"Server response: {response.decode()}")
        
    except Exception as e:
        print(f"UDP Client error: {e}")
    finally:
        client_socket.close()

# Run UDP client
udp_client()
```

### Socket Configuration and Options

### Timeout Settings

```python
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Set timeout for blocking operations
sock.settimeout(10.0)  # 10 seconds

# Set non-blocking mode
sock.setblocking(False)

# Get timeout setting
timeout = sock.gettimeout()
print(f"Socket timeout: {timeout}")
```

### Advanced Socket Options

```python
import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Keep-alive options
sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)

# TCP-specific options (Linux)
try:
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_KEEPIDLE, 60)
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_KEEPINTVL, 10)
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_KEEPCNT, 6)
except AttributeError:
    # Not available on all platforms
    pass

# Disable Nagle's algorithm
sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
```

### Error Handling and Exceptions

### Common Socket Exceptions

```python
import socket

def robust_socket_operation():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        sock.connect(('localhost', 12345))
        sock.send(b"Hello")
        data = sock.recv(1024)
        
    except socket.error as e:
        print(f"Socket error: {e}")
    except socket.timeout:
        print("Socket operation timed out")
    except socket.gaierror as e:
        print(f"Address resolution error: {e}")
    except ConnectionRefusedError:
        print("Connection refused by remote host")
    except ConnectionResetError:
        print("Connection reset by remote host")
    except BrokenPipeError:
        print("Broken pipe - remote host closed connection")
    finally:
        sock.close()
```

### Graceful Error Handling

```python
import socket
import errno

def handle_socket_errors(sock):
    try:
        data = sock.recv(1024)
        return data
    except socket.error as e:
        if e.errno == errno.EAGAIN or e.errno == errno.EWOULDBLOCK:
            # No data available (non-blocking socket)
            return None
        elif e.errno == errno.ECONNRESET:
            # Connection reset by peer
            print("Connection reset by peer")
            return None
        else:
            # Other socket errors
            print(f"Socket error: {e}")
            raise
```

### Network Address Resolution

### Host and Service Resolution

```python
import socket

# Get host information
def get_host_info(hostname):
    try:
        # Get IP address
        ip_address = socket.gethostbyname(hostname)
        print(f"IP address of {hostname}: {ip_address}")
        
        # Get detailed host information
        host_info = socket.gethostbyaddr(ip_address)
        print(f"Host info: {host_info}")
        
    except socket.gaierror as e:
        print(f"Address resolution failed: {e}")

# Modern address resolution
def resolve_address(hostname, port):
    try:
        # Get address information
        addr_info = socket.getaddrinfo(hostname, port, socket.AF_UNSPEC, socket.SOCK_STREAM)
        
        for family, socktype, proto, canonname, sockaddr in addr_info:
            print(f"Family: {family}, Type: {socktype}, Address: {sockaddr}")
            
    except socket.gaierror as e:
        print(f"Address resolution failed: {e}")

# **Example** usage
get_host_info('google.com')
resolve_address('google.com', 80)
```

### Local Network Information

```python
import socket

# Get local hostname
hostname = socket.gethostname()
print(f"Local hostname: {hostname}")

# Get local IP address
local_ip = socket.gethostbyname(hostname)
print(f"Local IP: {local_ip}")

# Get fully qualified domain name
fqdn = socket.getfqdn()
print(f"FQDN: {fqdn}")
```

### Advanced Socket Programming

### Non-blocking Sockets

```python
import socket
import select

def non_blocking_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('localhost', 12345))
    server_socket.listen(5)
    
    # Set non-blocking
    server_socket.setblocking(False)
    
    sockets = [server_socket]
    
    while True:
        # Use select to check for ready sockets
        ready, _, _ = select.select(sockets, [], [], 1.0)
        
        for sock in ready:
            if sock == server_socket:
                # Accept new connection
                try:
                    client_socket, address = server_socket.accept()
                    client_socket.setblocking(False)
                    sockets.append(client_socket)
                    print(f"New connection from {address}")
                except socket.error:
                    continue
            else:
                # Handle client data
                try:
                    data = sock.recv(1024)
                    if data:
                        sock.send(data)  # Echo back
                    else:
                        # Client disconnected
                        sockets.remove(sock)
                        sock.close()
                except socket.error:
                    sockets.remove(sock)
                    sock.close()
```

### SSL/TLS Sockets

```python
import socket
import ssl

def ssl_client():
    # Create SSL context
    context = ssl.create_default_context()
    
    # Create socket and wrap with SSL
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ssl_sock = context.wrap_socket(sock, server_hostname='httpbin.org')
    
    try:
        ssl_sock.connect(('httpbin.org', 443))
        
        # Send HTTP request
        request = b"GET /get HTTP/1.1\r\nHost: httpbin.org\r\n\r\n"
        ssl_sock.send(request)
        
        # Receive response
        response = ssl_sock.recv(4096)
        print(response.decode())
        
    finally:
        ssl_sock.close()

def ssl_server():
    # Load certificate and key
    context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    context.load_cert_chain(certfile="server.crt", keyfile="server.key")
    
    # Create server socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('localhost', 12345))
    server_socket.listen(5)
    
    # Wrap with SSL
    ssl_server_socket = context.wrap_socket(server_socket, server_side=True)
    
    try:
        while True:
            client_socket, address = ssl_server_socket.accept()
            print(f"SSL connection from {address}")
            
            # Handle SSL client
            data = client_socket.recv(1024)
            client_socket.send(data)
            client_socket.close()
            
    finally:
        ssl_server_socket.close()
```

### Socket Server Classes

### Using socketserver Module

```python
import socketserver

class MyTCPHandler(socketserver.BaseRequestHandler):
    def handle(self):
        # Receive data
        data = self.request.recv(1024).strip()
        print(f"Received from {self.client_address}: {data.decode()}")
        
        # Send response
        self.request.sendall(data.upper())

# Create server
server = socketserver.TCPServer(('localhost', 12345), MyTCPHandler)

# Run server
try:
    server.serve_forever()
except KeyboardInterrupt:
    server.shutdown()
```

### Threaded Socket Server

```python
import socketserver
import threading

class ThreadedTCPHandler(socketserver.BaseRequestHandler):
    def handle(self):
        while True:
            try:
                data = self.request.recv(1024)
                if not data:
                    break
                
                print(f"Thread {threading.current_thread().name}: {data.decode()}")
                self.request.sendall(data.upper())
                
            except Exception as e:
                print(f"Error: {e}")
                break

class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    pass

# Create threaded server
server = ThreadedTCPServer(('localhost', 12345), ThreadedTCPHandler)
server.serve_forever()
```

### File Transfer Implementation

### File Transfer Server

```python
import socket
import os

def file_transfer_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('localhost', 12345))
    server_socket.listen(1)
    
    print("File transfer server listening...")
    
    while True:
        client_socket, address = server_socket.accept()
        print(f"Connection from {address}")
        
        try:
            # Receive filename
            filename = client_socket.recv(1024).decode()
            print(f"Requested file: {filename}")
            
            if os.path.exists(filename):
                # Send file size
                file_size = os.path.getsize(filename)
                client_socket.send(str(file_size).encode())
                
                # Send file content
                with open(filename, 'rb') as file:
                    while True:
                        chunk = file.read(4096)
                        if not chunk:
                            break
                        client_socket.send(chunk)
                
                print(f"File {filename} sent successfully")
            else:
                client_socket.send(b"0")  # File not found
                
        except Exception as e:
            print(f"Error: {e}")
        finally:
            client_socket.close()
```

### File Transfer Client

```python
import socket

def file_transfer_client(filename):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        client_socket.connect(('localhost', 12345))
        
        # Send filename
        client_socket.send(filename.encode())
        
        # Receive file size
        file_size = int(client_socket.recv(1024).decode())
        
        if file_size > 0:
            # Receive file content
            with open(f"received_{filename}", 'wb') as file:
                received = 0
                while received < file_size:
                    chunk = client_socket.recv(min(4096, file_size - received))
                    if not chunk:
                        break
                    file.write(chunk)
                    received += len(chunk)
            
            print(f"File received successfully: received_{filename}")
        else:
            print("File not found on server")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        client_socket.close()

# Transfer file
file_transfer_client("example.txt")
```

### Socket Performance Optimization

### Buffer Management

```python
import socket

def optimized_socket_communication():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # Optimize buffer sizes
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 65536)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 65536)
    
    # Disable Nagle's algorithm for low-latency
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    
    try:
        sock.connect(('localhost', 12345))
        
        # Send large data efficiently
        large_data = b'x' * 1000000  # 1MB of data
        
        # Send in chunks
        bytes_sent = 0
        chunk_size = 8192
        
        while bytes_sent < len(large_data):
            chunk = large_data[bytes_sent:bytes_sent + chunk_size]
            sent = sock.send(chunk)
            bytes_sent += sent
            
    finally:
        sock.close()
```

### Connection Pooling

```python
import socket
import threading
import queue

class ConnectionPool:
    def __init__(self, host, port, max_connections=10):
        self.host = host
        self.port = port
        self.max_connections = max_connections
        self.pool = queue.Queue(maxsize=max_connections)
        self.lock = threading.Lock()
        
        # Initialize connections
        for _ in range(max_connections):
            conn = self._create_connection()
            self.pool.put(conn)
    
    def _create_connection(self):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((self.host, self.port))
        return sock
    
    def get_connection(self):
        try:
            return self.pool.get(block=False)
        except queue.Empty:
            return self._create_connection()
    
    def return_connection(self, conn):
        try:
            self.pool.put(conn, block=False)
        except queue.Full:
            conn.close()
    
    def close_all(self):
        while not self.pool.empty():
            conn = self.pool.get()
            conn.close()
```

**Key points**: The socket module provides comprehensive network programming capabilities including TCP/UDP protocols, address resolution, SSL/TLS support, and various socket options. Proper error handling and resource management are essential for robust network applications.

**Conclusion**: The socket module is fundamental for network programming in Python, enabling the creation of servers, clients, and complex networked applications. Understanding socket types, error handling, and performance optimization is crucial for building efficient and reliable network communication systems.

---

