## Error Propagation Patterns


### Service Layer Pattern

```go
type UserService struct {
    repo   UserRepository
    cache  Cache
    logger Logger
}

func (s *UserService) GetUser(ctx context.Context, userID string) (*User, error) {
    // Try cache first
    if user, err := s.cache.Get(ctx, userID); err == nil {
        return user, nil
    }
    
    // Fallback to repository
    user, err := s.repo.GetUser(ctx, userID)
    if err != nil {
        if errors.Is(err, ErrUserNotFound) {
            return nil, err // Don't wrap sentinel errors
        }
        return nil, fmt.Errorf("repository error: %w", err)
    }
    
    // Cache the result
    if err := s.cache.Set(ctx, userID, user); err != nil {
        s.logger.Warn("failed to cache user", "user_id", userID, "error", err)
        // Don't return cache errors for read operations
    }
    
    return user, nil
}
```

### HTTP Handler Error Pattern

```go
type APIError struct {
    Code    int    `json:"code"`
    Message string `json:"message"`
    Details string `json:"details,omitempty"`
}

func (e APIError) Error() string {
    return e.Message
}

func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
    userID := r.URL.Query().Get("id")
    
    user, err := h.service.GetUser(r.Context(), userID)
    if err != nil {
        h.handleError(w, err)
        return
    }
    
    json.NewEncoder(w).Encode(user)
}

func (h *UserHandler) handleError(w http.ResponseWriter, err error) {
    var apiErr APIError
    
    switch {
    case errors.Is(err, ErrUserNotFound):
        apiErr = APIError{
            Code:    404,
            Message: "User not found",
        }
    case errors.Is(err, ErrInvalidInput):
        apiErr = APIError{
            Code:    400,
            Message: "Invalid input",
            Details: err.Error(),
        }
    default:
        h.logger.Error("internal server error", "error", err)
        apiErr = APIError{
            Code:    500,
            Message: "Internal server error",
        }
    }
    
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(apiErr.Code)
    json.NewEncoder(w).Encode(apiErr)
}
```

### Concurrent Error Handling

```go
func processConcurrently(items []Item) error {
    var wg sync.WaitGroup
    errChan := make(chan error, len(items))
    
    for _, item := range items {
        wg.Add(1)
        go func(item Item) {
            defer wg.Done()
            if err := processItem(item); err != nil {
                errChan <- fmt.Errorf("failed to process item %d: %w", item.ID, err)
            }
        }(item)
    }
    
    // Close error channel when all goroutines complete
    go func() {
        wg.Wait()
        close(errChan)
    }()
    
    // Collect all errors
    var errors []error
    for err := range errChan {
        errors = append(errors, err)
    }
    
    if len(errors) > 0 {
        return fmt.Errorf("processing failed with %d errors: %v", len(errors), errors[0])
    }
    
    return nil
}
```

**Key Points:**

- Different layers handle errors differently
- Service layers often wrap errors with context
- HTTP handlers convert errors to appropriate responses
- Concurrent operations need careful error collection
- Preserve error chains for debugging while converting for user consumption

**Examples** of comprehensive error handling demonstrate Go's explicit approach to error management, emphasizing clarity and predictable error flow throughout application layers.

---

