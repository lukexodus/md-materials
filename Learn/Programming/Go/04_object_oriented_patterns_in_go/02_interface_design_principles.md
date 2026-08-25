## Interface Design Principles


Go interfaces are implicit contracts that define behavior without requiring explicit implementation declarations. This approach enables flexible, decoupled designs that emphasize what types can do rather than what they are.

```go
type Writer interface {
    Write([]byte) (int, error)
}

type Logger interface {
    Log(message string)
}

// Combining interfaces
type WriterLogger interface {
    Writer
    Logger
}
```

**Key Points:**

- Keep interfaces small and focused on single responsibilities
- Define interfaces where they're consumed, not where they're implemented
- Use interface embedding for composition
- Prefer many small interfaces over few large ones

The interface segregation principle applies strongly in Go - clients shouldn't depend on interfaces they don't use. This leads to highly testable and modular code where dependencies can be easily mocked or swapped.

