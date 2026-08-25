## Environment Variable Handling


Environment variables provide a standard way to configure applications and pass runtime information. Go's `os` package provides comprehensive environment variable support.

**Key Points:**

- `os.Getenv` retrieves environment variable values
- `os.LookupEnv` distinguishes between empty and unset variables
- `os.Setenv` and `os.Unsetenv` modify the environment
- `os.Environ` returns all environment variables
- Environment changes only affect the current process and its children

**Example:**

```go
package main

import (
    "fmt"
    "os"
    "strconv"
    "strings"
    "time"
)

type Config struct {
    DatabaseURL string
    Port        int
    Debug       bool
    Timeout     time.Duration
}

func main() {
    config := loadConfig()
    fmt.Printf("Config: %+v\n", config)

    // List all environment variables
    fmt.Println("\nEnvironment variables:")
    for _, env := range os.Environ() {
        pair := strings.SplitN(env, "=", 2)
        if len(pair) == 2 {
            fmt.Printf("  %s = %s\n", pair[0], pair[1])
        }
    }

    // Modify environment
    os.Setenv("CUSTOM_VAR", "custom_value")
    fmt.Printf("CUSTOM_VAR: %s\n", os.Getenv("CUSTOM_VAR"))
}

func loadConfig() Config {
    config := Config{
        DatabaseURL: getEnvWithDefault("DATABASE_URL", "localhost:5432"),
        Port:        getEnvAsInt("PORT", 8080),
        Debug:       getEnvAsBool("DEBUG", false),
        Timeout:     getEnvAsDuration("TIMEOUT", 30*time.Second),
    }
    return config
}

func getEnvWithDefault(key, defaultValue string) string {
    if value, exists := os.LookupEnv(key); exists {
        return value
    }
    return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
    if value, exists := os.LookupEnv(key); exists {
        if intValue, err := strconv.Atoi(value); err == nil {
            return intValue
        }
    }
    return defaultValue
}

func getEnvAsBool(key string, defaultValue bool) bool {
    if value, exists := os.LookupEnv(key); exists {
        if boolValue, err := strconv.ParseBool(value); err == nil {
            return boolValue
        }
    }
    return defaultValue
}

func getEnvAsDuration(key string, defaultValue time.Duration) time.Duration {
    if value, exists := os.LookupEnv(key); exists {
        if duration, err := time.ParseDuration(value); err == nil {
            return duration
        }
    }
    return defaultValue
}
```

Environment variables are commonly used for configuration in containerized environments and follow the twelve-factor app methodology for configuration management.

