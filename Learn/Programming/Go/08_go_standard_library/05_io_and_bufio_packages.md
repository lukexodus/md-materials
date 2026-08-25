## io and bufio Packages


### io Package

Provides basic interfaces and functions for I/O primitives.

**Core Interfaces**

- `io.Reader` - reads data from source
- `io.Writer` - writes data to destination
- `io.Closer` - closes resources
- `io.Seeker` - seeks to position
- `io.ReaderWriter`, `io.ReadCloser`, etc. - composite interfaces

**Utility Functions**

- `Copy`, `CopyN` - copies data between Reader and Writer
- `ReadAll` - reads entire Reader contents
- `ReadFull` - reads exactly n bytes
- `WriteString` - writes string to Writer
- `MultiReader`, `MultiWriter` - combines multiple sources/destinations

**Special Readers/Writers**

- `io.Discard` - discards all written data
- `io.LimitReader` - limits reading to n bytes
- `io.TeeReader` - writes to Writer while reading
- `io.SectionReader` - reads from section of ReaderAt

### bufio Package

Implements buffered I/O, wrapping io.Reader and io.Writer to provide buffering and additional functionality.

**Buffered Reading** `bufio.Reader` provides:

- `Read`, `ReadByte`, `ReadRune` - basic reading
- `ReadLine`, `ReadBytes`, `ReadString` - line/delimiter-based reading
- `Peek` - looks ahead without consuming
- `Buffered` - returns buffered data count
- `UnreadByte`, `UnreadRune` - unreads last byte/rune

**Buffered Writing** `bufio.Writer` provides:

- `Write`, `WriteByte`, `WriteRune`, `WriteString` - basic writing
- `Flush` - forces write of buffered data
- `Available`, `Buffered` - buffer status
- Buffer size control

**Scanner** `bufio.Scanner` provides token-based reading:

- `Scan()` - advances to next token
- `Text()`, `Bytes()` - returns current token
- Split functions: `ScanLines`, `ScanWords`, `ScanRunes`, `ScanBytes`
- Custom split functions supported

