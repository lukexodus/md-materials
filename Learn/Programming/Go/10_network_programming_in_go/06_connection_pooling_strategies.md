## Connection Pooling Strategies


Connection pooling reduces overhead by reusing network connections across multiple requests.

**HTTP Connection Pool Tuning:**

```go
func createOptimizedHTTPClient() *http.Client {
    transport := &http.Transport{
        // Connection pooling settings
        MaxIdleConns:        100,              // Total idle connections
        MaxIdleConnsPerHost: 20,               // Idle connections per host
        MaxConnsPerHost:     50,               // Max connections per host
        IdleConnTimeout:     90 * time.Second, // How long idle connections stay alive
        
        // Timeouts
        DialTimeout:           10 * time.Second,
        TLSHandshakeTimeout:   10 * time.Second,
        ResponseHeaderTimeout: 30 * time.Second,
        ExpectContinueTimeout: 1 * time.Second,
        
        // Keep-alive settings
        DisableKeepAlives: false,
        
        // Compression
        DisableCompression: false,
        
        // HTTP/2 support
        ForceAttemptHTTP2: true,
    }
    
    return &http.Client{
        Transport: transport,
        Timeout:   60 * time.Second,
    }
}
```

**Custom Connection Pool:**

```go
type ConnectionPool struct {
    mu          sync.RWMutex
    connections map[string]*pooledConnection
    maxConn     int
    timeout     time.Duration
}

type pooledConnection struct {
    conn      net.Conn
    lastUsed  time.Time
    inUse     bool
}

func NewConnectionPool(maxConn int, timeout time.Duration) *ConnectionPool {
    pool := &ConnectionPool{
        connections: make(map[string]*pooledConnection),
        maxConn:     maxConn,
        timeout:     timeout,
    }
    
    // Start cleanup goroutine
    go pool.cleanup()
    
    return pool
}

func (p *ConnectionPool) Get(address string) (net.Conn, error) {
    p.mu.Lock()
    defer p.mu.Unlock()
    
    // Try to reuse existing connection
    if pooled, exists := p.connections[address]; exists && !pooled.inUse {
        // Check if connection is still valid
        if time.Since(pooled.lastUsed) < p.timeout {
            pooled.inUse = true
            pooled.lastUsed = time.Now()
            return pooled.conn, nil
        }
        // Connection expired, remove it
        pooled.conn.Close()
        delete(p.connections, address)
    }
    
    // Check pool size limit
    if len(p.connections) >= p.maxConn {
        return nil, fmt.Errorf("connection pool full")
    }
    
    // Create new connection
    conn, err := net.DialTimeout("tcp", address, 10*time.Second)
    if err != nil {
        return nil, fmt.Errorf("failed to create connection: %w", err)
    }
    
    p.connections[address] = &pooledConnection{
        conn:     conn,
        lastUsed: time.Now(),
        inUse:    true,
    }
    
    return conn, nil
}

func (p *ConnectionPool) Put(address string, conn net.Conn) {
    p.mu.Lock()
    defer p.mu.Unlock()
    
    if pooled, exists := p.connections[address]; exists && pooled.conn == conn {
        pooled.inUse = false
        pooled.lastUsed = time.Now()
    }
}

func (p *ConnectionPool) cleanup() {
    ticker := time.NewTicker(30 * time.Second)
    defer ticker.Stop()
    
    for range ticker.C {
        p.mu.Lock()
        now := time.Now()
        for addr, pooled := range p.connections {
            if !pooled.inUse && now.Sub(pooled.lastUsed) > p.timeout {
                pooled.conn.Close()
                delete(p.connections, addr)
            }
        }
        p.mu.Unlock()
    }
}
```

**Database Connection Pool Pattern:**

```go
type DBPool struct {
    connections chan *sql.DB
    factory     func() (*sql.DB, error)
    maxOpen     int
    mu          sync.Mutex
    numOpen     int
}

func NewDBPool(maxOpen int, factory func() (*sql.DB, error)) *DBPool {
    return &DBPool{
        connections: make(chan *sql.DB, maxOpen),
        factory:     factory,
        maxOpen:     maxOpen,
    }
}

func (p *DBPool) Get() (*sql.DB, error) {
    select {
    case conn := <-p.connections:
        return conn, nil
    default:
        p.mu.Lock()
        if p.numOpen < p.maxOpen {
            p.numOpen++
            p.mu.Unlock()
            return p.factory()
        }
        p.mu.Unlock()
        
        // Wait for available connection
        return <-p.connections, nil
    }
}

func (p *DBPool) Put(conn *sql.DB) {
    select {
    case p.connections <- conn:
    default:
        // Pool is full, close connection
        conn.Close()
        p.mu.Lock()
        p.numOpen--
        p.mu.Unlock()
    }
}
```

**Key Points:**

- TCP provides reliable, ordered byte streams while UDP offers connectionless, unreliable datagram transmission
- Go's net/http package includes built-in connection pooling, HTTP/2 support, and comprehensive timeout controls
- WebSocket implementations require careful handling of connection lifecycle, heartbeat mechanisms, and message broadcasting
- TLS configuration supports various security levels from basic encryption to mutual authentication
- Context-aware network programming enables proper cancellation propagation and timeout handling
- Connection pooling strategies significantly impact application performance and resource utilization

**Best Practices:**

- Always set appropriate timeouts for network operations to prevent resource exhaustion
- Use context for cancellation and timeout propagation across network boundaries
- Configure TLS with strong cipher suites and appropriate certificate validation
- Implement proper connection pooling to balance performance and resource usage
- Handle network errors gracefully with appropriate retry mechanisms and circuit breakers
- Monitor connection pool metrics to optimize configuration parameters

Related advanced topics include load balancing strategies, circuit breaker patterns, and distributed networking protocols for microservices architectures.

---

