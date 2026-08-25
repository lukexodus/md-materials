## Mock Generation and Testing


Mocking enables isolated unit testing by replacing dependencies with controllable test doubles.

**Key Points:**

- Interface-based design facilitates mocking
- Manual mocks provide full control over behavior
- Generated mocks reduce boilerplate and maintenance overhead
- Mock libraries like GoMock provide sophisticated matching and verification
- Dependency injection patterns enable easy mock substitution

**Example:**

```go
// user_service.go
package service

import "context"

type User struct {
    ID    string
    Name  string
    Email string
}

// UserRepository defines the interface for user data access
type UserRepository interface {
    GetUser(ctx context.Context, id string) (User, error)
    SaveUser(ctx context.Context, user User) error
    DeleteUser(ctx context.Context, id string) error
}

// EmailService defines the interface for email operations
type EmailService interface {
    SendWelcomeEmail(ctx context.Context, user User) error
    SendNotification(ctx context.Context, userID, message string) error
}

// UserService handles business logic for users
type UserService struct {
    repo  UserRepository
    email EmailService
}

func NewUserService(repo UserRepository, email EmailService) *UserService {
    return &UserService{
        repo:  repo,
        email: email,
    }
}

func (s *UserService) CreateUser(ctx context.Context, name, email string) (User, error) {
    user := User{
        ID:    generateUserID(),
        Name:  name,
        Email: email,
    }
    
    if err := s.repo.SaveUser(ctx, user); err != nil {
        return User{}, err
    }
    
    if err := s.email.SendWelcomeEmail(ctx, user); err != nil {
        // Log error but don't fail user creation
        // In real application, might use error handling strategy
    }
    
    return user, nil
}

func (s *UserService) GetUser(ctx context.Context, id string) (User, error) {
    return s.repo.GetUser(ctx, id)
}

func (s *UserService) NotifyUser(ctx context.Context, id, message string) error {
    user, err := s.repo.GetUser(ctx, id)
    if err != nil {
        return err
    }
    
    return s.email.SendNotification(ctx, user.ID, message)
}

func generateUserID() string {
    return "user_" + randomString(10)
}

func randomString(length int) string {
    return "1234567890" // Simplified for example
}
```

**Manual Mocks:**

```go
// user_service_test.go
package service

import (
    "context"
    "errors"
    "testing"
)

// MockUserRepository implements UserRepository for testing
type MockUserRepository struct {
    users   map[string]User
    saveErr error
    getErr  error
}

func NewMockUserRepository() *MockUserRepository {
    return &MockUserRepository{
        users: make(map[string]User),
    }
}

func (m *MockUserRepository) GetUser(ctx context.Context, id string) (User, error) {
    if m.getErr != nil {
        return User{}, m.getErr
    }
    
    user, exists := m.users[id]
    if !exists {
        return User{}, errors.New("user not found")
    }
    
    return user, nil
}

func (m *MockUserRepository) SaveUser(ctx context.Context, user User) error {
    if m.saveErr != nil {
        return m.saveErr
    }
    
    m.users[user.ID] = user
    return nil
}

func (m *MockUserRepository) DeleteUser(ctx context.Context, id string) error {
    delete(m.users, id)
    return nil
}

// Set error conditions for testing
func (m *MockUserRepository) SetSaveError(err error) {
    m.saveErr = err
}

func (m *MockUserRepository) SetGetError(err error) {
    m.getErr = err
}

// MockEmailService implements EmailService for testing
type MockEmailService struct {
    welcomeEmails    []User
    notifications    []NotificationCall
    welcomeErr       error
    notificationErr  error
}

type NotificationCall struct {
    UserID  string
    Message string
}

func NewMockEmailService() *MockEmailService {
    return &MockEmailService{
        welcomeEmails: make([]User, 0),
        notifications: make([]NotificationCall, 0),
    }
}

func (m *MockEmailService) SendWelcomeEmail(ctx context.Context, user User) error {
    if m.welcomeErr != nil {
        return m.welcomeErr
    }
    
    m.welcomeEmails = append(m.welcomeEmails, user)
    return nil
}

func (m *MockEmailService) SendNotification(ctx context.Context, userID, message string) error {
    if m.notificationErr != nil {
        return m.notificationErr
    }
    
    m.notifications = append(m.notifications, NotificationCall{
        UserID:  userID,
        Message: message,
    })
    return nil
}

// Helper methods for test verification
func (m *MockEmailService) WelcomeEmailsSent() []User {
    return m.welcomeEmails
}

func (m *MockEmailService) NotificationsSent() []NotificationCall {
    return m.notifications
}

func (m *MockEmailService) SetWelcomeError(err error) {
    m.welcomeErr = err
}

func (m *MockEmailService) SetNotificationError(err error) {
    m.notificationErr = err
}

// Tests using manual mocks
func TestUserService_CreateUser(t *testing.T) {
    tests := []struct {
        name        string
        userName    string
        userEmail   string
        setupMocks  func(*MockUserRepository, *MockEmailService)
        wantErr     bool
        verifyMocks func(t *testing.T, repo *MockUserRepository, email *MockEmailService)
    }{
        {
            name:      "successful creation",
            userName:  "John Doe",
            userEmail: "john@example.com",
            setupMocks: func(repo *MockUserRepository, email *MockEmailService) {
                // No setup needed for success case
            },
            wantErr: false,
            verifyMocks: func(t *testing.T, repo *MockUserRepository, email *MockEmailService) {
                if len(email.WelcomeEmailsSent()) != 1 {
                    t.Errorf("Expected 1 welcome email, got %d", len(email.WelcomeEmailsSent()))
                }
                
                welcomeEmail := email.WelcomeEmailsSent()[0]
                if welcomeEmail.Name != "John Doe" {
                    t.Errorf("Welcome email user name = %v, want %v", welcomeEmail.Name, "John Doe")
                }
            },
        },
        {
            name:      "repository error",
            userName:  "John Doe",
            userEmail: "john@example.com",
            setupMocks: func(repo *MockUserRepository, email *MockEmailService) {
                repo.SetSaveError(errors.New("database error"))
            },
            wantErr: true,
            verifyMocks: func(t *testing.T, repo *MockUserRepository, email *MockEmailService) {
                if len(email.WelcomeEmailsSent()) != 0 {
                    t.Error("No welcome email should be sent on repository error")
                }
            },
        },
        {
            name:      "email error does not fail creation",
            userName:  "John Doe",
            userEmail: "john@example.com",
            setupMocks: func(repo *MockUserRepository, email *MockEmailService) {
                email.SetWelcomeError(errors.New("email service down"))
            },
            wantErr: false,
            verifyMocks: func(t *testing.T, repo *MockUserRepository, email *MockEmailService) {
                // User should still be created despite email failure
            },
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            repo := NewMockUserRepository()
            email := NewMockEmailService()
            tt.setupMocks(repo, email)
            
            service := NewUserService(repo, email)
            
            user, err := service.CreateUser(context.Background(), tt.userName, tt.userEmail)
            
            if tt.wantErr {
                if err == nil {
                    t.Error("CreateUser() should return an error")
                }
                return
            }
            
            if err != nil {
                t.Errorf("CreateUser() returned unexpected error: %v", err)
                return
            }
            
            if user.Name != tt.userName {
                t.Errorf("User name = %v, want %v", user.Name, tt.userName)
            }
            
            tt.verifyMocks(t, repo, email)
        })
    }
}
```

**Using GoMock (Generated Mocks):**

```go
//go:generate mockgen -source=user_service.go -destination=mocks/mock_user_service.go

// Generated mock usage
func TestWithGoMock(t *testing.T) {
    ctrl := gomock.NewController(t)
    defer ctrl.Finish()
    
    mockRepo := mocks.NewMockUserRepository(ctrl)
    mockEmail := mocks.NewMockEmailService(ctrl)
    
    service := NewUserService(mockRepo, mockEmail)
    
    // Set expectations
    mockRepo.EXPECT().
        SaveUser(gomock.Any(), gomock.Any()).
        Return(nil).
        Times(1)
    
    mockEmail.EXPECT().
        SendWelcomeEmail(gomock.Any(), gomock.Any()).
        Return(nil).
        Times(1)
    
    _, err := service.CreateUser(context.Background(), "Test User", "test@example.com")
    if err != nil {
        t.Errorf("Unexpected error: %v", err)
    }
}
```

