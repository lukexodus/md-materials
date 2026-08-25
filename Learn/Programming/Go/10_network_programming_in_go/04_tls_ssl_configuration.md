## TLS/SSL Configuration


Transport Layer Security provides encrypted communication and authentication for network connections.

**TLS Server Configuration:**

```go
func startTLSServer(certFile, keyFile, addr string) error {
    // Load TLS certificate
    cert, err := tls.LoadX509KeyPair(certFile, keyFile)
    if err != nil {
        return fmt.Errorf("failed to load certificate: %w", err)
    }
    
    // Configure TLS
    tlsConfig := &tls.Config{
        Certificates: []tls.Certificate{cert},
        MinVersion:   tls.VersionTLS12,
        CipherSuites: []uint16{
            tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
            tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,
            tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
        },
        PreferServerCipherSuites: true,
    }
    
    server := &http.Server{
        Addr:      addr,
        TLSConfig: tlsConfig,
        Handler:   http.DefaultServeMux,
    }
    
    log.Printf("Starting TLS server on %s", addr)
    return server.ListenAndServeTLS("", "")
}
```

**Mutual TLS (mTLS) Configuration:**

```go
func startMTLSServer(serverCert, serverKey, caCert, addr string) error {
    // Load server certificate
    cert, err := tls.LoadX509KeyPair(serverCert, serverKey)
    if err != nil {
        return fmt.Errorf("failed to load server certificate: %w", err)
    }
    
    // Load CA certificate for client verification
    caCertPEM, err := os.ReadFile(caCert)
    if err != nil {
        return fmt.Errorf("failed to read CA certificate: %w", err)
    }
    
    caCertPool := x509.NewCertPool()
    if !caCertPool.AppendCertsFromPEM(caCertPEM) {
        return fmt.Errorf("failed to parse CA certificate")
    }
    
    tlsConfig := &tls.Config{
        Certificates: []tls.Certificate{cert},
        ClientAuth:   tls.RequireAndVerifyClientCert,
        ClientCAs:    caCertPool,
        MinVersion:   tls.VersionTLS12,
    }
    
    server := &http.Server{
        Addr:      addr,
        TLSConfig: tlsConfig,
        Handler:   http.DefaultServeMux,
    }
    
    return server.ListenAndServeTLS("", "")
}
```

**TLS Client Configuration:**

```go
func createTLSClient(caCert, clientCert, clientKey string) (*http.Client, error) {
    // Load CA certificate
    caCertPEM, err := os.ReadFile(caCert)
    if err != nil {
        return nil, fmt.Errorf("failed to read CA certificate: %w", err)
    }
    
    caCertPool := x509.NewCertPool()
    caCertPool.AppendCertsFromPEM(caCertPEM)
    
    // Load client certificate
    clientCertPair, err := tls.LoadX509KeyPair(clientCert, clientKey)
    if err != nil {
        return nil, fmt.Errorf("failed to load client certificate: %w", err)
    }
    
    tlsConfig := &tls.Config{
        Certificates: []tls.Certificate{clientCertPair},
        RootCAs:      caCertPool,
        MinVersion:   tls.VersionTLS12,
    }
    
    transport := &http.Transport{
        TLSClientConfig: tlsConfig,
    }
    
    return &http.Client{
        Transport: transport,
        Timeout:   30 * time.Second,
    }, nil
}
```

