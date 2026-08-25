## Test Coverage Analysis


Test coverage analysis helps identify untested code paths and measure the effectiveness of test suites.

**Key Points:**

- Built-in coverage tool generates coverage reports without external dependencies
- Line coverage, branch coverage, and function coverage are supported
- Coverage reports can be generated in multiple formats (text, HTML, JSON)
- Integration with continuous integration pipelines for coverage tracking
- Coverage thresholds can be enforced as part of quality gates

**Example:**

```go
// coverage_example.go
package coverage

import (
    "errors"
    "strings"
)

type UserService struct {
    users map[string]User
}

type User struct {
    ID       string
    Username string
    Email    string
    Active   bool
}

func NewUserService() *UserService {
    return &UserService{
        users: make(map[string]User),
    }
}

func (s *UserService) CreateUser(username, email string) (User, error) {
    if username == "" {
        return User{}, errors.New("username cannot be empty")
    }
    
    if email == "" {
        return User{}, errors.New("email cannot be empty")
    }
    
    if !strings.Contains(email, "@") {
        return User{}, errors.New("invalid email format")
    }
    
    if _, exists := s.users[username]; exists {
        return User{}, errors.New("user already exists")
    }
    
    user := User{
        ID:       generateID(),
        Username: username,
        Email:    email,
        Active:   true,
    }
    
    s.users[username] = user
    return user, nil
}

func (s *UserService) GetUser(username string) (User, error) {
    user, exists := s.users[username]
    if !exists {
        return User{}, errors.New("user not found")
    }
    
    if !user.Active {
        return User{}, errors.New("user is inactive")
    }
    
    return user, nil
}

func (s *UserService) DeactivateUser(username string) error {
    user, exists := s.users[username]
    if !exists {
        return errors.New("user not found")
    }
    
    user.Active = false
    s.users[username] = user
    return nil
}

func generateID() string {
    // Simplified ID generation
    return "user_123"
}
```

```go
// coverage_example_test.go
package coverage

import (
    "testing"
)

func TestUserService_CreateUser(t *testing.T) {
    service := NewUserService()
    
    tests := []struct {
        name      string
        username  string
        email     string
        wantErr   bool
        errMsg    string
    }{
        {"valid user", "john", "john@example.com", false, ""},
        {"empty username", "", "john@example.com", true, "username cannot be empty"},
        {"empty email", "john", "", true, "email cannot be empty"},
        {"invalid email", "john", "invalid-email", true, "invalid email format"},
        {"duplicate user", "john", "john@example.com", true, "user already exists"},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Create the first user for duplicate test
            if tt.name == "duplicate user" {
                service.CreateUser("john", "john@example.com")
            }
            
            user, err := service.CreateUser(tt.username, tt.email)
            
            if tt.wantErr {
                if err == nil {
                    t.Errorf("CreateUser() should return error")
                }
                if err != nil && err.Error() != tt.errMsg {
                    t.Errorf("CreateUser() error = %v, want %v", err.Error(), tt.errMsg)
                }
                return
            }
            
            if err != nil {
                t.Errorf("CreateUser() returned unexpected error: %v", err)
                return
            }
            
            if user.Username != tt.username {
                t.Errorf("Username = %v, want %v", user.Username, tt.username)
            }
            
            if user.Email != tt.email {
                t.Errorf("Email = %v, want %v", user.Email, tt.email)
            }
            
            if !user.Active {
                t.Error("New user should be active")
            }
        })
    }
}

func TestUserService_GetUser(t *testing.T) {
    service := NewUserService()
    
    // Create test user
    service.CreateUser("testuser", "test@example.com")
    
    tests := []struct {
        name     string
        username string
        setup    func()
        wantErr  bool
        errMsg   string
    }{
        {"existing active user", "testuser", func() {}, false, ""},
        {"non-existent user", "nonexistent", func() {}, true, "user not found"},
        {"inactive user", "testuser", func() {
            service.DeactivateUser("testuser")
        }, true, "user is inactive"},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Fresh service for each test
            service := NewUserService()
            service.CreateUser("testuser", "test@example.com")
            tt.setup()
            
            user, err := service.GetUser(tt.username)
            
            if tt.wantErr {
                if err == nil {
                    t.Errorf("GetUser() should return error")
                }
                if err != nil && err.Error() != tt.errMsg {
                    t.Errorf("GetUser() error = %v, want %v", err.Error(), tt.errMsg)
                }
                return
            }
            
            if err != nil {
                t.Errorf("GetUser() returned unexpected error: %v", err)
                return
            }
            
            if user.Username != tt.username {
                t.Errorf("Username = %v, want %v", user.Username, tt.username)
            }
        })
    }
}
```

**Running Coverage Analysis:**

```bash
# Generate coverage profile
go test -coverprofile=coverage.out

# View coverage percentage
go tool cover -func=coverage.out

# Generate HTML coverage report
go tool cover -html=coverage.out -o coverage.html

# Test specific packages with coverage
go test -cover ./...

# Set coverage mode (set, count, atomic)
go test -covermode=count -coverprofile=coverage.out
```

**Coverage Modes:**

- `set`: Track whether each statement was executed
- `count`: Track how many times each statement was executed
- `atomic`: Like count, but safe for concurrent programs

