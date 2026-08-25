## Input Validation and Sanitization


**String Validation** Validate input strings against expected patterns:

```go
import (
    "regexp"
    "unicode/utf8"
)

func validateEmail(email string) bool {
    emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
    return emailRegex.MatchString(email) && utf8.ValidString(email)
}

func sanitizeInput(input string) string {
    // Remove control characters
    clean := strings.Map(func(r rune) rune {
        if r < 32 && r != '\t' && r != '\n' && r != '\r' {
            return -1
        }
        return r
    }, input)
    
    return strings.TrimSpace(clean)
}
```

**Numeric Validation** Validate numeric inputs with proper bounds checking:

```go
import "strconv"

func validatePort(portStr string) (int, error) {
    port, err := strconv.Atoi(portStr)
    if err != nil {
        return 0, fmt.Errorf("invalid port format: %w", err)
    }
    
    if port < 1 || port > 65535 {
        return 0, fmt.Errorf("port out of valid range: %d", port)
    }
    
    return port, nil
}
```

**Path Validation** Prevent directory traversal attacks:

```go
import (
    "path/filepath"
    "strings"
)

func validateFilePath(basePath, userPath string) (string, error) {
    cleanPath := filepath.Clean(userPath)
    
    if strings.Contains(cleanPath, "..") {
        return "", fmt.Errorf("invalid path: contains directory traversal")
    }
    
    fullPath := filepath.Join(basePath, cleanPath)
    if !strings.HasPrefix(fullPath, basePath) {
        return "", fmt.Errorf("path outside allowed directory")
    }
    
    return fullPath, nil
}
```

**SQL Injection Prevention** Use prepared statements for database queries:

```go
func getUserByID(db *sql.DB, userID int) (*User, error) {
    query := "SELECT id, name, email FROM users WHERE id = ?"
    row := db.QueryRow(query, userID)
    
    var user User
    err := row.Scan(&user.ID, &user.Name, &user.Email)
    if err != nil {
        return nil, err
    }
    
    return &user, nil
}
```

