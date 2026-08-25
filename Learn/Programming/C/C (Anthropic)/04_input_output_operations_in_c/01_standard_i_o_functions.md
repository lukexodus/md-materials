## Standard I/O Functions


The C standard library implements I/O operations through a stream-based model where data flows between the program and external devices as sequences of characters. Three standard streams are automatically available to every C program:

- `stdin` (standard input) - typically the keyboard
- `stdout` (standard output) - typically the screen
- `stderr` (standard error) - typically the screen for error messages

The most fundamental I/O functions include `getchar()` and `putchar()` for single character operations, along with higher-level functions for formatted I/O.

**Key points** about standard I/O:

- All I/O operations are buffered by default for efficiency
- The newline character (`\n`) typically triggers output buffer flushing
- Error conditions can be checked using functions like `feof()` and `ferror()`
- Stream positioning can be controlled with functions like `fseek()` and `ftell()`

