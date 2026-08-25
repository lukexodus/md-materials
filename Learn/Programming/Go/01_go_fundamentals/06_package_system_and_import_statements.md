## Package System and Import Statements


Go's package system organizes code into reusable units and manages namespace isolation.

**Package Declaration:** Every Go source file begins with a package declaration specifying the package name. Files in the same directory must declare the same package name.

**Package main:** The special `main` package creates executable programs. It must contain a `main()` function as the program entry point.

**Import Statements:** Import statements make other packages available in the current file. Go supports several import syntaxes:

**Standard Import:**

```go
import "fmt"
import "net/http"
```

**Grouped Import:**

```go
import (
    "fmt"
    "net/http"
    "os"
)
```

**Import Aliases:**

```go
import (
    f "fmt"
    . "math"  // dot import
    _ "image/png"  // blank import
)
```

**Import Path Resolution:** Go resolves import paths through several mechanisms:

- Standard library packages (built-in)
- Module dependencies (go.mod)
- Relative imports (deprecated in modules)

**Visibility Rules:** Go uses capitalization to determine visibility:

- Capitalized names are exported (public)
- Lowercase names are package-private
- This applies to functions, types, variables, constants, and struct fields

**Standard Library:** Go includes an extensive standard library covering:

- I/O operations (`io`, `ioutil`, `bufio`)
- Network programming (`net`, `net/http`)
- Text processing (`strings`, `strconv`, `regexp`)
- Data encoding (`encoding/json`, `encoding/xml`)
- Cryptography (`crypto`, `crypto/tls`)
- System interfaces (`os`, `syscall`)

**Package Documentation:** Package documentation uses special comment formats preceding package declarations. The `go doc` tool extracts and displays this documentation.

**Key Points:**

- Package names should be concise and descriptive
- Avoid stuttering in API design (e.g., `http.HttpServer` becomes `http.Server`)
- Circular dependencies are not allowed
- Unused imports cause compilation errors
- The `gofmt` tool standardizes import organization

---

