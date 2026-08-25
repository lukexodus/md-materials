## Utility Functions


Utility functions provide general-purpose functionality including memory management, program control, searching, sorting, and random number generation.

**Header File:** `stdlib.h`

**Memory Management Functions:**

- `malloc(size_t size)`: Allocate memory block
- `calloc(size_t num, size_t size)`: Allocate and zero-initialize memory
- `realloc(void *ptr, size_t size)`: Resize memory block
- `free(void *ptr)`: Deallocate memory block
- `aligned_alloc(size_t alignment, size_t size)`: Aligned memory allocation (C11)

**Memory Management Characteristics:**

- `malloc()` returns uninitialized memory
- `calloc()` initializes all bytes to zero
- `realloc()` may move memory block to new location
- `free()` must be called for every successful allocation
- Double-free and use-after-free result in undefined behavior

**String to Number Conversion:**

- `atoi(const char *str)`: String to integer
- `atol(const char *str)`: String to long integer
- `atoll(const char *str)`: String to long long integer (C99)
- `atof(const char *str)`: String to double
- `strtol(const char *str, char **endptr, int base)`: Advanced string to long conversion
- `strtoul()`, `strtoll()`, `strtoull()`: Unsigned and long long variants
- `strtod()`, `strtof()`, `strtold()`: Advanced floating-point conversions

**Advanced Conversion Features:**

- `strtol()` family functions provide error detection
- Support for different number bases (2-36)
- `endptr` parameter indicates where parsing stopped
- Better error handling than `atoi()` family

**Searching and Sorting:**

- `qsort(void *base, size_t num, size_t size, int (*compare)(const void *, const void *))`: Quick sort algorithm
- `bsearch(const void *key, const void *base, size_t num, size_t size, int (*compare)(const void *, const void *))`: Binary search

**Random Number Generation:**

- `rand()`: Generate pseudo-random number (0 to RAND_MAX)
- `srand(unsigned int seed)`: Seed random number generator
- `RAND_MAX`: Maximum value returned by rand()

**Random Number Characteristics:**

- Linear congruential generator implementation [Inference - common implementation]
- Not cryptographically secure
- Same seed produces same sequence
- Quality varies by implementation

**Program Control:**

- `exit(int status)`: Terminate program normally
- `abort()`: Terminate program abnormally
- `atexit(void (*function)(void))`: Register exit handler function
- `system(const char *command)`: Execute system command

**Exit Status Codes:**

- `EXIT_SUCCESS`: Successful termination (typically 0)
- `EXIT_FAILURE`: Unsuccessful termination (typically non-zero)

**Environment Functions:**

- `getenv(const char *name)`: Get environment variable value
- `setenv()`, `unsetenv()`: Modify environment [Unverified - POSIX extensions]

**Absolute Value Functions:**

- `abs(int n)`: Integer absolute value
- `labs(long n)`: Long integer absolute value
- `llabs(long long n)`: Long long absolute value (C99)

**Division Functions:**

- `div(int numer, int denom)`: Integer division with quotient and remainder
- `ldiv()`, `lldiv()`: Long and long long variants
- Return `div_t`, `ldiv_t`, `lldiv_t` structures containing `quot` and `rem`

