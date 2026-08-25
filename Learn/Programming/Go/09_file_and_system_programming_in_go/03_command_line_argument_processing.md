## Command-line Argument Processing


Go provides multiple levels of command-line argument processing, from basic access to sophisticated parsing with the `flag` package and third-party libraries.

**Key Points:**

- `os.Args` provides raw access to command-line arguments
- The `flag` package offers built-in parsing for common argument patterns
- Flags can be boolean, string, integer, or duration types
- Custom flag types can be implemented by satisfying the `flag.Value` interface
- The `flag` package supports both short and long-form arguments

**Example:**

```go
package main

import (
    "flag"
    "fmt"
    "os"
    "time"
)

func main() {
    // Define flags
    var (
        verbose = flag.Bool("verbose", false, "Enable verbose output")
        output  = flag.String("output", "output.txt", "Output file name")
        count   = flag.Int("count", 10, "Number of iterations")
        timeout = flag.Duration("timeout", 30*time.Second, "Timeout duration")
    )

    // Custom flag type
    var logLevel LogLevel
    flag.Var(&logLevel, "log-level", "Log level (debug, info, warn, error)")

    // Parse flags
    flag.Parse()

    // Access parsed values
    fmt.Printf("Verbose: %t\n", *verbose)
    fmt.Printf("Output: %s\n", *output)
    fmt.Printf("Count: %d\n", *count)
    fmt.Printf("Timeout: %v\n", *timeout)
    fmt.Printf("Log Level: %s\n", logLevel)

    // Remaining arguments (non-flag arguments)
    fmt.Printf("Remaining args: %v\n", flag.Args())

    // Raw arguments
    fmt.Printf("All args: %v\n", os.Args)
}

// Custom flag type
type LogLevel string

const (
    Debug LogLevel = "debug"
    Info  LogLevel = "info"
    Warn  LogLevel = "warn"
    Error LogLevel = "error"
)

func (l *LogLevel) String() string {
    return string(*l)
}

func (l *LogLevel) Set(value string) error {
    switch value {
    case "debug", "info", "warn", "error":
        *l = LogLevel(value)
        return nil
    default:
        return fmt.Errorf("invalid log level: %s", value)
    }
}
```

For more complex command-line interfaces, third-party libraries like Cobra or urfave/cli provide subcommands, advanced help generation, and shell completion features.

