## HTTP Client and Server Development


Go's net/http package provides comprehensive HTTP functionality with built-in support for HTTP/2, connection pooling, and middleware patterns.

**HTTP Server with Middleware:**

```go
type Server struct {
    router *http.ServeMux
    server *http.Server
}

func NewServer(addr string) *Server {
    router := http.NewServeMux()
    
    server := &http.Server{
        Addr:         addr,
        Handler:      router,
        ReadTimeout:  15 * time.Second,
        WriteTimeout: 15 * time.Second,
        IdleTimeout:  60 * time.Second,
    }
    
    return &Server{
        router: router,
        server: server,
    }
}

// Middleware for logging
func (s *Server) loggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        
        // Wrap the ResponseWriter to capture status code
        ww := &responseWriter{ResponseWriter: w, statusCode: 200}
        next.ServeHTTP(ww, r)
        
        log.Printf("%s %s %d %v", r.Method, r.URL.Path, ww.statusCode, time.Since(start))
    })
}

type responseWriter struct {
    http.ResponseWriter
    statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
    rw.statusCode = code
    rw.ResponseWriter.WriteHeader(code)
}

// Add routes with middleware
func (s *Server) setupRoutes() {
    s.router.Handle("/api/", s.loggingMiddleware(http.StripPrefix("/api", s.apiHandler())))
    s.router.HandleFunc("/health", s.healthHandler)
    s.router.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("./static/"))))
}

func (s *Server) apiHandler() http.Handler {
    mux := http.NewServeMux()
    mux.HandleFunc("/users", s.handleUsers)
    mux.HandleFunc("/users/", s.handleUserByID)
    return mux
}

func (s *Server) handleUsers(w http.ResponseWriter, r *http.Request) {
    switch r.Method {
    case http.MethodGet:
        s.getUsers(w, r)
    case http.MethodPost:
        s.createUser(w, r)
    default:
        http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
    }
}

func (s *Server) getUsers(w http.ResponseWriter, r *http.Request) {
    users := []User{
        {ID: 1, Name: "Alice", Email: "alice@example.com"},
        {ID: 2, Name: "Bob", Email: "bob@example.com"},
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(users)
}

type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
}
```

**Advanced HTTP Client:**

```go
type HTTPClient struct {
    client  *http.Client
    baseURL string
    headers map[string]string
}

func NewHTTPClient(baseURL string, timeout time.Duration) *HTTPClient {
    transport := &http.Transport{
        MaxIdleConns:        100,
        MaxIdleConnsPerHost: 10,
        IdleConnTimeout:     90 * time.Second,
        DisableCompression:  false,
    }
    
    client := &http.Client{
        Transport: transport,
        Timeout:   timeout,
    }
    
    return &HTTPClient{
        client:  client,
        baseURL: baseURL,
        headers: make(map[string]string),
    }
}

func (c *HTTPClient) SetHeader(key, value string) {
    c.headers[key] = value
}

func (c *HTTPClient) Get(ctx context.Context, endpoint string) (*http.Response, error) {
    url := c.baseURL + endpoint
    
    req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
    if err != nil {
        return nil, fmt.Errorf("failed to create request: %w", err)
    }
    
    c.addHeaders(req)
    
    return c.client.Do(req)
}

func (c *HTTPClient) Post(ctx context.Context, endpoint string, body interface{}) (*http.Response, error) {
    var bodyReader io.Reader
    
    if body != nil {
        jsonData, err := json.Marshal(body)
        if err != nil {
            return nil, fmt.Errorf("failed to marshal body: %w", err)
        }
        bodyReader = bytes.NewReader(jsonData)
    }
    
    url := c.baseURL + endpoint
    req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bodyReader)
    if err != nil {
        return nil, fmt.Errorf("failed to create request: %w", err)
    }
    
    req.Header.Set("Content-Type", "application/json")
    c.addHeaders(req)
    
    return c.client.Do(req)
}

func (c *HTTPClient) addHeaders(req *http.Request) {
    for key, value := range c.headers {
        req.Header.Set(key, value)
    }
}
```

