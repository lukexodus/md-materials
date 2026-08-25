## Keywords and Identifiers


C contains 32 reserved keywords that cannot be used as variable names or identifiers. These include data type keywords (`int`, `char`, `float`, `double`), storage class specifiers (`static`, `extern`, `auto`, `register`), control flow keywords (`if`, `else`, `while`, `for`, `switch`, `case`, `default`), and others (`sizeof`, `typedef`, `struct`, `union`, `enum`).

Identifiers are user-defined names for variables, functions, arrays, and other program elements. Valid identifiers must begin with a letter or underscore, followed by any combination of letters, digits, and underscores. Identifiers cannot start with digits and cannot contain special characters or spaces.

**Key points:**

- 32 reserved keywords cannot be used as identifiers
- Identifiers start with letter or underscore
- May contain letters, digits, underscores after first character
- Cannot start with digits
- Case-sensitive naming

**Example:**

```c
int count;          // Valid identifier
char _name[50];     // Valid identifier with underscore
float price2;       // Valid identifier with digit
// int 2count;      // Invalid - starts with digit
// float for;       // Invalid - reserved keyword
```

