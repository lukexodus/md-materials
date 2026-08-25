## Struct Embedding Patterns


Struct embedding in Go provides a powerful composition mechanism that promotes fields and methods from embedded types, creating is-a relationships without traditional inheritance complexity.

```go
type User struct {
    ID       int
    Username string
    Email    string
}

func (u User) DisplayName() string {
    return u.Username
}

type Admin struct {
    User        // Embedded struct
    Permissions []string
}

func (a Admin) HasPermission(perm string) bool {
    for _, p := range a.Permissions {
        if p == perm {
            return true
        }
    }
    return false
}

// Admin can access User fields and methods directly
admin := Admin{
    User: User{ID: 1, Username: "admin", Email: "admin@example.com"},
    Permissions: []string{"read", "write", "delete"},
}

fmt.Println(admin.DisplayName()) // Promoted method from User
fmt.Println(admin.Username)      // Promoted field from User
```

Advanced embedding patterns include:

- **Multiple embedding**: Combining multiple types into a single struct
- **Interface embedding**: Composing interfaces from other interfaces
- **Anonymous embedding**: Using types directly without field names
- **Method forwarding**: Controlling which methods are promoted

**Example** of interface embedding:

```go
type Reader interface {
    Read([]byte) (int, error)
}

type Writer interface {
    Write([]byte) (int, error)
}

type ReadWriter interface {
    Reader  // Embeds Reader interface
    Writer  // Embeds Writer interface
}

type Closer interface {
    Close() error
}

type ReadWriteCloser interface {
    ReadWriter  // Embeds combined interface
    Closer      // Adds closing behavior
}
```

Embedding promotes loose coupling by allowing types to acquire behavior from multiple sources while maintaining clear ownership and avoiding the diamond problem inherent in multiple inheritance systems.

**Key Points:**

- Embedding promotes fields and methods from embedded types
- Name conflicts are resolved by outer type precedence
- Embedded interfaces create interface composition
- Method sets are combined from all embedded types
- Provides delegation patterns without explicit forwarding code

These patterns collectively enable Go to achieve object-oriented design goals through composition and interfaces rather than inheritance, resulting in more flexible and maintainable code architectures.

---

