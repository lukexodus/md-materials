## Code Formatting


Go's code formatting tools ensure consistent style across the Go ecosystem, eliminating style debates and improving code readability.

### gofmt

The canonical Go code formatter that defines Go's official style.

**Key Features**

- Applies Go's official formatting rules
- Handles indentation, spacing, and alignment
- Processes individual files or entire directories
- Can rewrite code in-place or output to stdout

**Usage Patterns**

```bash
gofmt file.go                    # Print formatted version
gofmt -w file.go                 # Write changes back to file
gofmt -d file.go                 # Show differences
gofmt -w -s .                    # Format all files, apply simplifications
```

**Simplification Rules** (`-s` flag)

- Removes unnecessary parentheses
- Simplifies slice expressions
- Converts array/slice/map literals to shorter forms
- Optimizes range expressions

**Integration Patterns** Most editors integrate gofmt automatically:

- Format on save functionality
- Pre-commit hooks for version control
- CI/CD pipeline formatting checks

### goimports

Enhanced formatter that manages import statements while applying gofmt formatting.

**Key Features**

- Automatically adds missing imports
- Removes unused imports
- Groups and sorts import statements
- Applies all gofmt formatting rules

**Import Grouping**

```go
import (
    // Standard library packages
    "context"
    "fmt"
    "net/http"

    // Third-party packages  
    "github.com/gin-gonic/gin"
    "github.com/lib/pq"

    // Local packages
    "example.com/myproject/internal/auth"
    "example.com/myproject/pkg/utils"
)
```

**Usage**

```bash
goimports -w file.go             # Format and fix imports
goimports -d .                   # Show import differences
goimports -local example.com .   # Specify local import prefix
```

**Editor Integration** Most Go-aware editors use goimports instead of gofmt for comprehensive formatting and import management.

