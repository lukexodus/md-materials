## Basic Syntax and Program Structure


Go syntax emphasizes simplicity and readability with minimal punctuation and consistent formatting rules.

**Program Structure:** Every Go program begins with a package declaration, followed by import statements, then package-level declarations (variables, constants, types, functions).

```go
package main

import (
    "fmt"
    "os"
)

func main() {
    fmt.Println("Hello, World!")
}
```

**Syntax Characteristics:**

- Semicolons are optional and typically omitted
- Curly braces define code blocks
- Case sensitivity determines visibility (capitalized names are exported)
- No parentheses required around control structure conditions
- Mandatory curly braces for all control structures

**Comments:**

- Line comments: `// comment text`
- Block comments: `/* comment text */`
- Documentation comments: Special comments preceding declarations

**Identifiers:** Names must begin with letters or underscores, followed by letters, digits, or underscores. Reserved keywords cannot be used as identifiers.

**Operators:** Go includes standard arithmetic, comparison, logical, and bitwise operators with predictable precedence and associativity rules.

