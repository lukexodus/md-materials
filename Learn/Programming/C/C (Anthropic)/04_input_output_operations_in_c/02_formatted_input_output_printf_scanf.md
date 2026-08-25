## Formatted Input/Output (printf, scanf)


### printf Function Family

The `printf()` function provides formatted output capabilities with extensive format specifier support. The general syntax is:

```c
int printf(const char *format, ...);
```

Format specifiers control how data appears in output:

- `%d` or `%i` - signed decimal integers
- `%u` - unsigned decimal integers
- `%o` - octal representation
- `%x` or `%X` - hexadecimal representation
- `%f` - floating-point numbers
- `%e` or `%E` - scientific notation
- `%g` or `%G` - shortest representation between %f and %e
- `%c` - single character
- `%s` - null-terminated strings
- `%p` - pointer addresses
- `%%` - literal percent sign

Width and precision modifiers enhance formatting control:

- `%10d` - right-aligned in 10-character field
- `%-10d` - left-aligned in 10-character field
- `%05d` - zero-padded to 5 digits
- `%.2f` - two decimal places
- `%10.2f` - 10-character field with 2 decimal places

**Example** of formatted output:

```c
int age = 25;
float height = 175.5;
char name[] = "John";

printf("Name: %-10s Age: %3d Height: %6.1f cm\n", name, age, height);
// Output: Name: John       Age:  25 Height:  175.5 cm
```

Related functions in the printf family:

- `fprintf()` - writes to specified file stream
- `sprintf()` - writes to character array
- `snprintf()` - writes to character array with size limit

### scanf Function Family

The `scanf()` function provides formatted input parsing with pattern matching capabilities:

```c
int scanf(const char *format, ...);
```

Input format specifiers mirror output specifiers but require address-of operators for variables:

- `%d` - reads decimal integers
- `%f` - reads floating-point numbers
- `%c` - reads single character (including whitespace)
- `%s` - reads strings (stops at whitespace)
- `%[...]` - reads character sets
- `%*` - suppresses assignment

**Key points** about scanf:

- Returns number of successfully parsed items
- Leaves unmatched input in the buffer
- Whitespace in format string matches any amount of whitespace in input
- String inputs without width specifiers create buffer overflow risks

**Example** of formatted input:

```c
int day, month, year;
char name[50];

printf("Enter date (dd/mm/yyyy): ");
scanf("%d/%d/%d", &day, &month, &year);

printf("Enter name: ");
scanf("%49s", name);  // Width limit prevents buffer overflow
```

Input buffer management often requires clearing residual characters:

```c
// Clear input buffer
while (getchar() != '\n');
```

