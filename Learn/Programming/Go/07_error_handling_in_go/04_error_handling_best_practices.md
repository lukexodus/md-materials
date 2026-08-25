## Error Handling Best Practices


### Early Return Pattern

```go
func processUser(userID int) (*User, error) {
    user, err := getUserFromDB(userID)
    if err != nil {
        return nil, fmt.Errorf("failed to get user: %w", err)
    }
    
    if err := validateUser(user); err != nil {
        return nil, fmt.Errorf("user validation failed: %w", err)
    }
    
    if err := enrichUserData(user); err != nil {
        return nil, fmt.Errorf("failed to enrich user data: %w", err)
    }
    
    return user, nil
}
```

### Error Context and Logging

```go
func (s *UserService) UpdateUser(ctx context.Context, userID int, updates UserUpdates) error {
    logger := s.logger.With("user_id", userID, "operation", "update")
    
    user, err := s.repo.GetUser(ctx, userID)
    if err != nil {
        logger.Error("failed to fetch user", "error", err)
        return fmt.Errorf("user lookup failed: %w", err)
    }
    
    if err := s.validateUpdates(updates); err != nil {
        logger.Warn("invalid updates provided", "error", err)
        return fmt.Errorf("validation error: %w", err)
    }
    
    if err := s.repo.UpdateUser(ctx, userID, updates); err != nil {
        logger.Error("database update failed", "error", err)
        return fmt.Errorf("update operation failed: %w", err)
    }
    
    logger.Info("user updated successfully")
    return nil
}
```

**Key Points:**

- Return errors early to avoid deep nesting
- Add contextual information when wrapping errors
- Log errors at appropriate levels with sufficient context
- Maintain error chains for debugging

