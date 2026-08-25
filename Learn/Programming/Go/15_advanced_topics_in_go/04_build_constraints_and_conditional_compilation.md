## Build Constraints and Conditional Compilation


Build constraints enable platform-specific and feature-specific code compilation.

### Platform-Specific Code

```go
// file: network_unix.go
//go:build unix && !windows

package network

import (
    "net"
    "syscall"
    "unsafe"
)

// Unix-specific network operations
func SetSocketOptions(conn net.Conn) error {
    tcpConn, ok := conn.(*net.TCPConn)
    if !ok {
        return fmt.Errorf("not a TCP connection")
    }
    
    rawConn, err := tcpConn.SyscallConn()
    if err != nil {
        return err
    }
    
    return rawConn.Control(func(fd uintptr) {
        // Set TCP_NODELAY
        syscall.SetsockoptInt(int(fd), syscall.IPPROTO_TCP, syscall.TCP_NODELAY, 1)
        // Set SO_REUSEADDR
        syscall.SetsockoptInt(int(fd), syscall.SOL_SOCKET, syscall.SO_REUSEADDR, 1)
    })
}

func GetSystemLoad() (float64, error) {
    // Unix-specific load average
    var info syscall.Sysinfo_t
    if err := syscall.Sysinfo(&info); err != nil {
        return 0, err
    }
    return float64(info.Loads[0]) / 65536.0, nil
}
```

```go
// file: network_windows.go  
//go:build windows

package network

import (
    "net"
    "syscall"
    "unsafe"
)

// Windows-specific network operations
func SetSocketOptions(conn net.Conn) error {
    tcpConn, ok := conn.(*net.TCPConn)
    if !ok {
        return fmt.Errorf("not a TCP connection")
    }
    
    rawConn, err := tcpConn.SyscallConn()
    if err != nil {
        return err
    }
    
    return rawConn.Control(func(fd uintptr) {
        // Windows-specific socket options
        val := int32(1)
        syscall.SetsockoptInt(syscall.Handle(fd), syscall.IPPROTO_TCP, syscall.TCP_NODELAY, int(val))
    })
}

func GetSystemLoad() (float64, error) {
    // Windows doesn't have direct load average equivalent
    // Return CPU usage approximation
    return getCPUUsage()
}

func getCPUUsage() (float64, error) {
    // [Unverified] Windows-specific CPU usage calculation
    // Would typically use Windows performance counters
    return 0.0, nil
}
```

### Feature Flags and Custom Build Tags

```go
// file: debug.go
//go:build debug

package main

import (
    "fmt"
    "runtime"
    "time"
)

const DebugMode = true

func init() {
    fmt.Println("Debug mode enabled")
}

func DebugLog(format string, args ...interface{}) {
    pc, file, line, _ := runtime.Caller(1)
    fn := runtime.FuncForPC(pc)
    timestamp := time.Now().Format("15:04:05.000")
    
    fmt.Printf("[DEBUG %s %s:%d %s] ", timestamp, file, line, fn.Name())
    fmt.Printf(format+"\n", args...)
}

func ProfileMemory() {
    var m runtime.MemStats
    runtime.ReadMemStats(&m)
    
    fmt.Printf("Memory: Alloc=%d KB, TotalAlloc=%d KB, Sys=%d KB, NumGC=%d\n",
        m.Alloc/1024, m.TotalAlloc/1024, m.Sys/1024, m.NumGC)
}
```

```go
// file: release.go  
//go:build !debug

package main

const DebugMode = false

func DebugLog(format string, args ...interface{}) {
    // No-op in release builds
}

func ProfileMemory() {
    // No-op in release builds
}
```

### Complex Build Configurations

```go
// file: storage_embedded.go
//go:build embedded && !cloud

package storage

import (
    "encoding/json"
    "os"
    "path/filepath"
)

type EmbeddedStorage struct {
    dataDir string
    cache   map[string][]byte
}

func NewStorage(config Config) (Storage, error) {
    storage := &EmbeddedStorage{
        dataDir: config.DataDir,
        cache:   make(map[string][]byte),
    }
    
    if err := os.MkdirAll(storage.dataDir, 0755); err != nil {
        return nil, err
    }
    
    return storage, nil
}

func (s *EmbeddedStorage) Store(key string, data []byte) error {
    s.cache[key] = data
    
    filePath := filepath.Join(s.dataDir, key+".json")
    return os.WriteFile(filePath, data, 0644)
}

func (s *EmbeddedStorage) Retrieve(key string) ([]byte, error) {
    if data, exists := s.cache[key]; exists {
        return data, nil
    }
    
    filePath := filepath.Join(s.dataDir, key+".json")
    data, err := os.ReadFile(filePath)
    if err == nil {
        s.cache[key] = data
    }
    return data, err
}
```

```go
// file: storage_cloud.go
//go:build cloud && !embedded

package storage

import (
    "bytes"
    "context"
    "fmt"
    
    "github.com/aws/aws-sdk-go/aws"
    "github.com/aws/aws-sdk-go/service/s3"
)

type CloudStorage struct {
    s3Client   *s3.S3
    bucketName string
}

func NewStorage(config Config) (Storage, error) {
    return &CloudStorage{
        s3Client:   s3.New(config.AWSSession),
        bucketName: config.S3Bucket,
    }, nil
}

func (s *CloudStorage) Store(key string, data []byte) error {
    _, err := s.s3Client.PutObject(&s3.PutObjectInput{
        Bucket: aws.String(s.bucketName),
        Key:    aws.String(key),
        Body:   bytes.NewReader(data),
    })
    return err
}

func (s *CloudStorage) Retrieve(key string) ([]byte, error) {
    result, err := s.s3Client.GetObject(&s3.GetObjectInput{
        Bucket: aws.String(s.bucketName),
        Key:    aws.String(key),
    })
    if err != nil {
        return nil, err
    }
    defer result.Body.Close()
    
    var buffer bytes.Buffer
    _, err = buffer.ReadFrom(result.Body)
    return buffer.Bytes(), err
}
```

**Key Points:**

- Build constraints enable platform-specific and feature-specific code
- Multiple constraints can be combined using boolean logic
- Custom build tags support feature flags and configuration variants
- Interface-based design enables seamless switching between implementations

