## TCP and UDP Socket Programming


Go's net package provides interfaces for network I/O, including TCP and UDP socket programming with both synchronous and asynchronous patterns.

**TCP Server Implementation:**

```go
func startTCPServer(address string) error {
    listener, err := net.Listen("tcp", address)
    if err != nil {
        return fmt.Errorf("failed to listen: %w", err)
    }
    defer listener.Close()
    
    log.Printf("TCP server listening on %s", address)
    
    for {
        conn, err := listener.Accept()
        if err != nil {
            log.Printf("Failed to accept connection: %v", err)
            continue
        }
        
        go handleTCPConnection(conn)
    }
}

func handleTCPConnection(conn net.Conn) {
    defer conn.Close()
    
    // Set read timeout
    conn.SetReadDeadline(time.Now().Add(30 * time.Second))
    
    scanner := bufio.NewScanner(conn)
    for scanner.Scan() {
        message := scanner.Text()
        log.Printf("Received: %s", message)
        
        // Echo back to client
        response := fmt.Sprintf("Echo: %s\n", message)
        conn.Write([]byte(response))
        
        // Reset deadline for next read
        conn.SetReadDeadline(time.Now().Add(30 * time.Second))
    }
    
    if err := scanner.Err(); err != nil {
        log.Printf("Connection error: %v", err)
    }
}
```

**TCP Client Implementation:**

```go
type TCPClient struct {
    conn    net.Conn
    timeout time.Duration
}

func NewTCPClient(address string, timeout time.Duration) (*TCPClient, error) {
    conn, err := net.DialTimeout("tcp", address, timeout)
    if err != nil {
        return nil, fmt.Errorf("failed to connect: %w", err)
    }
    
    return &TCPClient{
        conn:    conn,
        timeout: timeout,
    }, nil
}

func (c *TCPClient) SendMessage(message string) (string, error) {
    // Set write deadline
    c.conn.SetWriteDeadline(time.Now().Add(c.timeout))
    
    _, err := fmt.Fprintf(c.conn, "%s\n", message)
    if err != nil {
        return "", fmt.Errorf("failed to send: %w", err)
    }
    
    // Set read deadline
    c.conn.SetReadDeadline(time.Now().Add(c.timeout))
    
    response, err := bufio.NewReader(c.conn).ReadString('\n')
    if err != nil {
        return "", fmt.Errorf("failed to read response: %w", err)
    }
    
    return strings.TrimSpace(response), nil
}

func (c *TCPClient) Close() error {
    return c.conn.Close()
}
```

**UDP Server Implementation:**

```go
func startUDPServer(address string) error {
    addr, err := net.ResolveUDPAddr("udp", address)
    if err != nil {
        return fmt.Errorf("failed to resolve address: %w", err)
    }
    
    conn, err := net.ListenUDP("udp", addr)
    if err != nil {
        return fmt.Errorf("failed to listen: %w", err)
    }
    defer conn.Close()
    
    log.Printf("UDP server listening on %s", address)
    
    buffer := make([]byte, 1024)
    
    for {
        n, clientAddr, err := conn.ReadFromUDP(buffer)
        if err != nil {
            log.Printf("Failed to read UDP message: %v", err)
            continue
        }
        
        message := string(buffer[:n])
        log.Printf("Received from %s: %s", clientAddr, message)
        
        // Echo back to client
        response := fmt.Sprintf("Echo: %s", message)
        _, err = conn.WriteToUDP([]byte(response), clientAddr)
        if err != nil {
            log.Printf("Failed to send response: %v", err)
        }
    }
}
```

**UDP Client Implementation:**

```go
func sendUDPMessage(serverAddr, message string) (string, error) {
    addr, err := net.ResolveUDPAddr("udp", serverAddr)
    if err != nil {
        return "", fmt.Errorf("failed to resolve address: %w", err)
    }
    
    conn, err := net.DialUDP("udp", nil, addr)
    if err != nil {
        return "", fmt.Errorf("failed to connect: %w", err)
    }
    defer conn.Close()
    
    // Set timeout
    conn.SetDeadline(time.Now().Add(5 * time.Second))
    
    // Send message
    _, err = conn.Write([]byte(message))
    if err != nil {
        return "", fmt.Errorf("failed to send: %w", err)
    }
    
    // Read response
    buffer := make([]byte, 1024)
    n, err := conn.Read(buffer)
    if err != nil {
        return "", fmt.Errorf("failed to read response: %w", err)
    }
    
    return string(buffer[:n]), nil
}
```

