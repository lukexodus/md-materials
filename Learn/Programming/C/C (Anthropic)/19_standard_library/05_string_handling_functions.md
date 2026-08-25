## String Handling Functions


String handling functions provide comprehensive string manipulation capabilities including copying, comparison, searching, and tokenization.

**Header File:** `string.h`

**String Length:**

- `strlen(const char *s)`: Calculate string length
- Does not count null terminator
- Undefined behavior if string not null-terminated
- Time complexity: O(n)

**String Copying:**

- `strcpy(char *dest, const char *src)`: Copy string
- `strncpy(char *dest, const char *src, size_t n)`: Copy up to n characters
- `strcpy_s()`: Bounds-checking version (C11 Annex K) [Unverified - optional extension]

**String Copying Behavior:**

- `strcpy()` copies until null terminator found
- `strncpy()` may not null-terminate if source length ≥ n
- Destination must have sufficient space
- Overlapping strings cause undefined behavior

**String Concatenation:**

- `strcat(char *dest, const char *src)`: Concatenate strings
- `strncat(char *dest, const char *src, size_t n)`: Concatenate up to n characters
- `strcat_s()`: Bounds-checking version (C11 Annex K) [Unverified - optional extension]

**String Comparison:**

- `strcmp(const char *s1, const char *s2)`: Compare strings lexicographically
- `strncmp(const char *s1, const char *s2, size_t n)`: Compare up to n characters
- `strcoll(const char *s1, const char *s2)`: Compare using locale-specific collation
- `strxfrm(char *dest, const char *src, size_t n)`: Transform string for strcoll

**Comparison Return Values:**

- Returns negative value if s1 < s2
- Returns 0 if s1 == s2
- Returns positive value if s1 > s2
- Comparison based on unsigned character values

**String Searching:**

- `strchr(const char *s, int c)`: Find first occurrence of character
- `strrchr(const char *s, int c)`: Find last occurrence of character
- `strstr(const char *haystack, const char *needle)`: Find first occurrence of substring
- `strpbrk(const char *s1, const char *s2)`: Find first character from set
- `strspn(const char *s1, const char *s2)`: Length of prefix containing only specified characters
- `strcspn(const char *s1, const char *s2)`: Length of prefix not containing specified characters

**String Tokenization:**

- `strtok(char *str, const char *delim)`: Extract tokens from string
- `strtok_r(char *str, const char *delim, char **saveptr)`: Reentrant version [Unverified - POSIX extension]

**strtok Behavior:**

- Modifies original string by inserting null terminators
- Maintains internal state between calls
- Not thread-safe due to static internal state
- Returns NULL when no more tokens found

**Memory Functions:**

- `memcpy(void *dest, const void *src, size_t n)`: Copy memory block
- `memmove(void *dest, const void *src, size_t n)`: Copy memory block (handles overlap)
- `memcmp(const void *s1, const void *s2, size_t n)`: Compare memory blocks
- `memchr(const void *s, int c, size_t n)`: Search for byte in memory
- `memset(void *s, int c, size_t n)`: Fill memory with constant byte

**Memory vs String Functions:**

- Memory functions work with arbitrary bytes
- String functions stop at null terminators
- Memory functions specify exact byte count
- `memmove()` safe for overlapping regions, `memcpy()` is not

**Error Information:**

- `strerror(int errnum)`: Get error message string for errno value
- Returns pointer to implementation-defined error message
- Useful for converting errno codes to readable messages

**Case Conversion (ctype.h):**

- `toupper(int c)`: Convert character to uppercase
- `tolower(int c)`: Convert character to lowercase
- Work on individual characters, not strings
- Return unchanged character if no conversion applicable

**Character Classification (ctype.h):**

- `isalpha(int c)`: Test for alphabetic character
- `isdigit(int c)`: Test for decimal digit
- `isalnum(int c)`: Test for alphanumeric character
- `isspace(int c)`: Test for whitespace character
- `ispunct(int c)`: Test for punctuation character
- `isprint(int c)`: Test for printable character

**Locale Considerations:**

- Many functions affected by current locale setting
- `strcoll()` and `strxfrm()` use locale-specific collation rules
- Character classification functions respect locale
- `setlocale()` function controls locale settings

**Security Considerations:**

- Buffer overflow risks with `strcpy()`, `strcat()`, `sprintf()`
- Bounds-checking variants available in C11 Annex K [Unverified - optional]
- Consider using `strncpy()`, `strncat()`, `snprintf()` for safer alternatives
- Always ensure destination buffers have adequate size

The Standard C Library provides essential functionality that enables portable, efficient C programming. Understanding these functions and their proper usage is crucial for writing robust, maintainable C code.

---

