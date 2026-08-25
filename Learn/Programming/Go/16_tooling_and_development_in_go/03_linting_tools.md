## Linting Tools


Go's linting ecosystem provides static analysis tools that identify potential issues, enforce coding standards, and improve code quality.

### go vet

Built-in static analysis tool that identifies suspicious constructs and potential bugs.

**Analysis Categories**

- Printf format string mismatches
- Unreachable code detection
- Incorrect struct tags
- Missing return statements
- Mutex copying issues
- Shadow variable detection
- Assembly code validation

**Usage**

```bash
go vet ./...                     # Analyze all packages
go vet package                   # Analyze specific package
go vet -shadow ./...             # Include shadow variable analysis
```

**Common Issues Detected**

```go
// Printf format mismatch
fmt.Printf("%d", "string")       // vet: wrong type for format

// Unreachable code
return
fmt.Println("never reached")     // vet: unreachable code

// Struct tag issues
type User struct {
    Name string `json:"name,omitempty,"`  // vet: trailing comma
}

// Copying mutex
var mu sync.Mutex
mu2 := mu                        // vet: assignment copies mutex
```

### golint (Deprecated)

[Unverified] The original Go linter, now deprecated in favor of more comprehensive tools. Previously identified style violations and naming convention issues.

### staticcheck

Comprehensive static analysis tool that has become the de facto standard for Go linting.

**Key Features**

- Extensive set of checks for bugs, performance, and style
- High-quality analysis with low false positive rate
- Incremental analysis for large codebases
- Configurable check selection

**Usage**

```bash
go install honnef.co/go/tools/cmd/staticcheck@latest
staticcheck ./...                # Analyze all packages
staticcheck -checks=all ./...    # Run all available checks
```

**Check Categories**

- `SA` - Static analysis checks (bugs, correctness)
- `S` - Simple style checks
- `ST` - Stylistic checks
- `QF` - Quick fixes
- `U` - Unused code detection

### golangci-lint

Meta-linter that runs multiple linters simultaneously with unified configuration.

**Included Linters**

- staticcheck, gosec, govet, errcheck
- ineffassign, misspell, gocyclo
- deadcode, unused, gosimple
- Many others configurable via `.golangci.yml`

**Configuration Example**

```yaml
linters-settings:
  golint:
    min-confidence: 0.8
  gocyclo:
    min-complexity: 15
  maligned:
    suggest-new: true

linters:
  enable:
    - staticcheck
    - gosec
    - errcheck
    - ineffassign
  disable:
    - typecheck

run:
  timeout: 5m
  tests: false
```

**Usage**

```bash
golangci-lint run                # Run with default configuration
golangci-lint run --config .golangci.yml
golangci-lint linters            # List available linters
```

### Specialized Linters

- `gosec` - Security-focused static analysis
- `errcheck` - Ensures error return values are checked
- `ineffassign` - Detects ineffectual assignments
- `misspell` - Finds commonly misspelled English words
- `gocyclo` - Computes cyclomatic complexity

