## fmt Package for Formatting


The `fmt` package serves as Go's primary interface for formatted I/O operations, similar to C's printf family but with Go-specific enhancements.

**Key Points**

- Implements formatted I/O with functions analogous to C's printf and scanf
- Provides type-safe printing with automatic type detection
- Supports custom formatting through the Stringer and GoStringer interfaces
- Handles both synchronous and asynchronous output operations

**Print Functions**

- `Print`, `Println`, `Printf` - output to standard output
- `Fprint`, `Fprintln`, `Fprintf` - output to specified io.Writer
- `Sprint`, `Sprintln`, `Sprintf` - return formatted string
- `Errorf` - creates formatted error values

**Scan Functions**

- `Scan`, `Scanln`, `Scanf` - read from standard input
- `Fscan`, `Fscanln`, `Fscanf` - read from specified io.Reader
- `Sscan`, `Sscanln`, `Sscanf` - read from string

**Formatting Verbs** The package uses format specifiers (verbs) that determine how values are formatted:

- `%v` - default format for any value
- `%+v` - adds field names for structs
- `%#v` - Go-syntax representation
- `%T` - type representation
- `%t` - boolean values
- `%d` - decimal integers
- `%b`, `%o`, `%x`, `%X` - binary, octal, hexadecimal
- `%f`, `%e`, `%g` - floating-point numbers
- `%s` - string values
- `%q` - quoted strings
- `%p` - pointer addresses

**Custom Formatting** Types can implement formatting interfaces:

```go
type Stringer interface {
    String() string
}

type GoStringer interface {
    GoString() string
}
```

