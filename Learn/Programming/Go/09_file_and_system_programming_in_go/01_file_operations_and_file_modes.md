## File Operations and File Modes


Go's file operations are primarily handled through the `os` and `io` packages, providing both low-level and high-level interfaces for file manipulation.

**Key Points:**

- Files are represented by the `*os.File` type, which implements `io.Reader`, `io.Writer`, and `io.Closer`
- File modes control permissions and access patterns using Unix-style permission bits
- Go provides both synchronous and memory-mapped file operations
- All file operations return errors that should be handled explicitly
- File operations are platform-abstracted but respect underlying OS semantics

**Example:**

```go
package main

import (
    "fmt"
    "io"
    "os"
)

func main() {
    // Create a new file with specific permissions
    file, err := os.OpenFile("example.txt", os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
    if err != nil {
        panic(err)
    }
    defer file.Close()

    // Write data to file
    _, err = file.WriteString("Hello, World!\n")
    if err != nil {
        panic(err)
    }

    // Read file content
    content, err := os.ReadFile("example.txt")
    if err != nil {
        panic(err)
    }
    fmt.Print(string(content))

    // Get file information
    info, err := os.Stat("example.txt")
    if err != nil {
        panic(err)
    }
    fmt.Printf("File size: %d bytes\n", info.Size())
    fmt.Printf("Permissions: %s\n", info.Mode())
}
```

**File Mode Constants:**

- `os.O_RDONLY`: Read-only access
- `os.O_WRONLY`: Write-only access
- `os.O_RDWR`: Read-write access
- `os.O_APPEND`: Append to file
- `os.O_CREATE`: Create file if it doesn't exist
- `os.O_EXCL`: Exclusive creation (fails if file exists)
- `os.O_SYNC`: Synchronous I/O
- `os.O_TRUNC`: Truncate file to zero length

Permission bits follow Unix conventions (owner/group/other with read/write/execute flags). The `os.FileMode` type provides methods for checking specific permissions and file types.

