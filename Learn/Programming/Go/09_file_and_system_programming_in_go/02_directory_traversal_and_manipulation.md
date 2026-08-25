## Directory Traversal and Manipulation


Go offers multiple approaches for working with directories, from simple operations to complex recursive traversals with filtering capabilities.

**Key Points:**

- `os.ReadDir` provides efficient directory listing
- `filepath.Walk` enables recursive directory traversal
- `filepath.WalkDir` is more efficient for large directory trees
- Directory operations respect platform-specific path separators
- Symbolic links can be followed or treated as regular files depending on the API used

**Example:**

```go
package main

import (
    "fmt"
    "io/fs"
    "os"
    "path/filepath"
    "strings"
)

func main() {
    // Create directory structure
    err := os.MkdirAll("testdir/subdir", 0755)
    if err != nil {
        panic(err)
    }
    defer os.RemoveAll("testdir")

    // Create some files
    os.WriteFile("testdir/file1.txt", []byte("content1"), 0644)
    os.WriteFile("testdir/subdir/file2.go", []byte("package main"), 0644)

    // Simple directory listing
    entries, err := os.ReadDir("testdir")
    if err != nil {
        panic(err)
    }

    fmt.Println("Directory contents:")
    for _, entry := range entries {
        fmt.Printf("  %s (dir: %t)\n", entry.Name(), entry.IsDir())
    }

    // Recursive traversal
    fmt.Println("\nRecursive traversal:")
    err = filepath.WalkDir("testdir", func(path string, d fs.DirEntry, err error) error {
        if err != nil {
            return err
        }
        
        indent := strings.Repeat("  ", strings.Count(path, string(os.PathSeparator)))
        fmt.Printf("%s%s\n", indent, d.Name())
        
        return nil
    })
    if err != nil {
        panic(err)
    }

    // Find specific files
    goFiles, err := findFilesByExtension("testdir", ".go")
    if err != nil {
        panic(err)
    }
    fmt.Printf("\nGo files found: %v\n", goFiles)
}

func findFilesByExtension(root, ext string) ([]string, error) {
    var files []string
    
    err := filepath.WalkDir(root, func(path string, d fs.DirEntry, err error) error {
        if err != nil {
            return err
        }
        
        if !d.IsDir() && filepath.Ext(path) == ext {
            files = append(files, path)
        }
        
        return nil
    })
    
    return files, err
}
```

The `filepath` package provides cross-platform path manipulation functions that handle differences between Windows and Unix-like systems automatically. Functions like `filepath.Join`, `filepath.Dir`, and `filepath.Base` ensure correct path handling across platforms.

