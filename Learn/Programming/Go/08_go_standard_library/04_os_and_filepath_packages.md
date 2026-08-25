## os and filepath Packages


### os Package

Provides platform-independent interface to operating system functionality.

**File Operations**

- `Open`, `OpenFile` - opens files with various modes
- `Create` - creates/truncates files
- `Remove`, `RemoveAll` - deletes files/directories
- `Rename` - renames files/directories
- `Mkdir`, `MkdirAll` - creates directories
- `Chmod` - changes file permissions
- `Stat`, `Lstat` - retrieves file information

**Process Management**

- `Getpid`, `Getppid` - process IDs
- `Exit` - terminates program
- `Signal` handling through os.Signal interface
- Environment variables: `Getenv`, `Setenv`, `Environ`

**Standard Streams**

- `os.Stdin`, `os.Stdout`, `os.Stderr` - standard I/O streams
- `os.Args` - command-line arguments

**File Type** `os.File` implements multiple interfaces:

- `io.Reader`, `io.Writer` - basic I/O
- `io.Seeker` - position seeking
- `io.Closer` - resource cleanup

### filepath Package

Provides utilities for manipulating filename paths in a way compatible with the target operating system.

**Path Manipulation**

- `Join` - joins path elements with OS-specific separator
- `Split` - splits path into directory and file
- `Dir`, `Base` - extracts directory/filename
- `Ext` - returns file extension
- `Abs` - returns absolute path
- `Rel` - returns relative path
- `Clean` - returns shortest equivalent path

**Pattern Matching**

- `Match` - shell-style pattern matching
- `Glob` - returns names matching pattern

**Path Walking**

- `Walk` - recursively walks directory tree
- `WalkDir` - more efficient directory walking (Go 1.16+)

