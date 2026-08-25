## Network Timeouts and Context


Proper timeout handling prevents network operations from hanging indefinitely and enables graceful cancellation.

**Context-Aware HTTP Server:**

```go
func contextAwareHandler(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()
    
    // Create timeout context for downstream operations
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()
    
    resultCh := make(chan string, 1)
    errCh := make(chan error, 1)
    
    go func() {
        result, err := performSlowOperation(ctx)
        if err != nil {
            errCh <- err
            return
        }
        resultCh <- result
    }()
    
    select {
    case result := <-resultCh:
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(map[string]string{"result": result})
        
    case err := <-errCh:
        if errors.Is(err, context.DeadlineExceeded) {
            http.Error(w, "Request timeout", http.StatusRequestTimeout)
        } else {
            http.Error(w, "Internal server error", http.StatusInternalServerError)
        }
        
    case <-ctx.Done():
        log.Printf("Request cancelled: %v", ctx.Err())
        return
    }
}

func performSlowOperation(ctx context.Context) (string, error) {
    select {
    case <-time.After(3 * time.Second):
        return "Operation completed", nil
    case <-ctx.Done():
        return "", ctx.Err()
    }
}
```

**Network Timeout Configuration:**

```go
type NetworkConfig struct {
    ConnectTimeout    time.Duration
    ReadTimeout       time.Duration
    WriteTimeout      time.Duration
    KeepAliveTimeout  time.Duration
    IdleTimeout       time.Duration
}

func createConfiguredClient(config NetworkConfig) *http.Client {
    dialer := &net.Dialer{
        Timeout:   config.ConnectTimeout,
        KeepAlive: config.KeepAliveTimeout,
    }
    
    transport := &http.Transport{
        Dial:                dialer.Dial,
        TLSHandshakeTimeout: 10 * time.Second,
        IdleConnTimeout:     config.IdleTimeout,
        ResponseHeaderTimeout: config.ReadTimeout,
        ExpectContinueTimeout: 1 * time.Second,
    }
    
    return &http.Client{
        Transport: transport,
        Timeout:   config.ReadTimeout + config.WriteTimeout,
    }
}
```

