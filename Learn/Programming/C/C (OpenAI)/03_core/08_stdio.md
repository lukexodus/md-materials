## `stdio`


### `printf`

`printf` is a standard library function used for formatted output. It allows you to print data to the standard output (usually the console) with various formatting options. Format specifiers and flags are used within `printf` to control the output format. 

#### Format Specifiers:

Format specifiers are placeholders in the format string of `printf` that indicate the type of data to be printed and how it should be formatted.

- `%d`: Signed integer. Typical size is 4 bytes (32 bits).
- `%ld`: Long signed integer. Typical size is 8 bytes (64 bits).
- `%u`: Unsigned integer. Typical size is 4 bytes (32 bits).
- `%lu`: Long unsigned integer. Typical size is 8 bytes (64 bits).
- `%hd`: Short signed integer. Typical size is 2 bytes (16 bits).
- `%hu`: Short unsigned integer. Typical size is 2 bytes (16 bits).

- `%f`: Float. Typical size is 4 bytes (32 bits).
- `%lf`: Double. Typical size is 8 bytes (64 bits).
- `%e`, `%E`: Print a floating-point number in scientific notation (exponential format).
- `%g`, `%G`: Compact notation (float/double). Print a floating-point number in either decimal or exponential format, depending on the value.

- `%c`: Print a single character.
- `%s`: Print a string.

- `%x`, `%X`: Print an integer in hexadecimal format (lowercase or uppercase letters, respectively).
- `%a`, `%A`: Hexadecimal floating point (C99).
- `%o`: Print an integer in octal format.

- `%p`: Print a pointer address.

#### Format Flags:

Format flags modify the behavior of format specifiers and control how the data is formatted.

- `-`: Left-align the output within the field width.
- `+`: Print a plus sign (`+`) for positive numbers.
- `0`: Pad numbers with leading zeros instead of spaces.
- `.`: Specify precision for floating-point numbers.
- `*`: Get the width or precision from the argument list.
- `#`: Use an alternative format (e.g., print `0x` for `%#x`).

**Width and Precision:**

You can specify the minimum width and precision of the output by including numeric values between the `%` and the format specifier.

**Example:**

```c
#include <stdio.h>

int main() {
    int num = 42;
    float pi = 3.14159;

    printf("Integer: %d\n", num); // Prints an integer
    printf("Float: %.2f\n", pi); // Prints a float with 2 decimal places
    printf("Padded Integer: %05d\n", num); // Prints a padded integer with leading zeros
    printf("Hexadecimal: %x\n", num); // Prints the integer in hexadecimal format
    printf("Pointer Address: %p\n", &num); // Prints the memory address of the integer

    return 0;
}
```

**Output:**

```yaml
Integer: 42
Float: 3.14
Padded Integer: 00042
Hexadecimal: 2a
Pointer Address: 0x7ffd5826b0fc
```

**Notes:**

* Format specifiers and flags must match the data type being printed to avoid undefined behavior.
* Be careful when using format specifiers with `printf` to prevent security vulnerabilities like format string vulnerabilities.
* Always ensure that the number of arguments passed to `printf` matches the number of format specifiers to avoid runtime errors.

### `sprintf`

`sprintf` is a function in C used to format and store a series of characters in a string buffer. It works similar to `printf`, but instead of printing the formatted string to the standard output, `sprintf` writes the formatted string to a character array (string buffer).

```c
#include <stdio.h>

int sprintf(char *str, const char *format, ...);
```

* `str`: Pointer to the buffer where the formatted string will be stored.
* `format`: String that contains the text to be written to the buffer. It can also contain format specifiers, which are placeholders for the values to be inserted into the string.

The `sprintf` function formats the string according to the format string `format` and writes the resulting characters to the string buffer pointed to by `str`. It works similarly to `printf`, but the output is directed to the string buffer instead of the standard output.

The return value of `sprintf` is the number of characters written to the string buffer, excluding the null terminator ('\0').

Example usage:

```c
#include <stdio.h>

int main() {
    char buffer[100];
    int num = 123;
    float pi = 3.14159;

    sprintf(buffer, "Number: %d, Pi: %.2f", num, pi);
    printf("Formatted string: %s\n", buffer);

    return 0;
}
```

In this example, `sprintf` formats the string `"Number: %d, Pi: %.2f"` with the values of `num` and `pi` and stores it in the `buffer` array. The `printf` statement then prints the formatted string to the standard output.

It's important to note that `sprintf` does not perform bounds checking on the destination buffer. If the formatted string is too large to fit into the buffer, it can lead to buffer overflow, causing undefined behavior and potential security vulnerabilities. To prevent this, consider using safer alternatives like `snprintf`, which allows you to specify the size of the destination buffer to avoid overflow.

### `snprintf`

`snprintf` is a function in C used to format and store a series of characters in a buffer. Unlike `sprintf`, `snprintf` limits the number of characters written to the buffer to prevent buffer overflow, which can lead to undefined behavior.

```c
#include <stdio.h>

int snprintf(char *str, size_t size, const char *format, ...);
```

* `str`: Pointer to the buffer where the formatted string will be stored.
* `size`: Maximum number of characters to be written to the buffer, including the null terminator.
* `format`: String that contains the text to be written to the buffer. It can also contain format specifiers, which are placeholders for the values to be inserted into the string.

The `snprintf` function works similarly to `printf`, but it writes the formatted string to the specified buffer (`str`) instead of printing it to the standard output. The `size` parameter ensures that the function does not write more characters to the buffer than it can hold, preventing buffer overflow.

The return value of `snprintf` is the number of characters that would have been written to the buffer if it were large enough to hold the entire formatted string. If the return value is greater than or equal to the specified `size`, it indicates that truncation has occurred.

Example usage:

```c
#include <stdio.h>

int main() {
    char buffer[20];
    int num = 123;
    float pi = 3.14159;

    int len = snprintf(buffer, sizeof(buffer), "Number: %d, Pi: %.2f", num, pi);
    
    if (len >= sizeof(buffer)) {
        printf("Truncation occurred.\n");
    } else {
        printf("Formatted string: %s\n", buffer);
    }

    return 0;
}
```

In this example, `snprintf` formats the string `"Number: %d, Pi: %.2f"` with the values of `num` and `pi` and stores it in the `buffer` array. The `sizeof(buffer)` parameter ensures that the function does not write more than 20 characters to the buffer. The return value `len` indicates the length of the formatted string. If `len` is greater than or equal to `sizeof(buffer)`, it means that truncation has occurred.

### `scanf`

The `scanf()` function in C is used to read formatted input from the standard input stream (`stdin`). It is part of the Standard I/O Library (`stdio.h`). `scanf()` is a powerful function that allows you to parse input according to specified format specifiers.

**Syntax:**

```c
int scanf(const char *format, ...);
```

* `format`: A string that specifies the format of the input to be read.
* `...`: Additional arguments representing pointers to the variables where the read values should be stored.

**Example:**

```c
#include <stdio.h>

int main() {
    char name[50];
    int age;

    printf("Enter your name and age: ");
    scanf("%s %d", name, &age);

    printf("Name: %s, Age: %d\n", name, age);

    return 0;
}
```

In this example, `%s` in the format string indicates that `scanf()` should read a string (sequence of non-whitespace characters) and `%d` indicates that it should read an integer. The values read are stored in the variables `name` and `age`, respectively.

**Important Points to Note:**

* `scanf()` stops reading input when it encounters whitespace (space, tab, newline) unless specified otherwise in the format string.
* When reading a string, `scanf()` stops at the first whitespace character encountered.
* Ensure that the pointers provided to `scanf()` point to valid memory locations where the read values can be stored. Failure to do so can result in undefined behavior.
* Error handling is important when using `scanf()`. Always check the return value to ensure that the correct number of values were read and processed.

**Return Value:**

* `scanf()` returns the number of input items successfully matched and assigned, which can be fewer than the number of format specifiers provided.
* It returns `EOF` (end-of-file) if the input stream ends before the first matching failure or if an error occurs during reading.

**Example of Error Handling:**

```c
int num;
printf("Enter an integer: ");
if (scanf("%d", &num) != 1) {
    printf("Invalid input\n");
}
```

In this example, if `scanf()` fails to read an integer (returns a value other than 1), it prints an error message indicating invalid input.

`scanf()` is a versatile function for reading input in C, but it requires careful usage and error handling to ensure robustness and reliability in your programs.

#### Format String Parameter

The format string of the `scanf()` function in C specifies how the input should be interpreted and read from the standard input stream (`stdin`) or another input stream provided as an argument. It consists of format specifiers that match the data types of the variables to which the input values will be assigned.

**Basic Format Specifiers:**

* **`%d`**: Reads an integer value.
* **`%f`**: Reads a floating-point value (float).
* **`%lf`**: Reads a double-precision floating-point value (double).
* **`%c`**: Reads a single character.
* **`%s`**: Reads a string of characters until whitespace (space, tab, newline) is encountered.
* **`%u`**: Reads an unsigned integer.
* **`%x`, `%X`**: Reads an integer in hexadecimal format.
* **`%o`**: Reads an integer in octal format.
* **`%p`**: Reads a pointer value.

**Additional Format Specifiers:**

* **`%[^...]`**: Reads characters until any character in the specified set is encountered.
* **`%[^\n]`**: Reads characters until a newline character (`'\n'`) is encountered.
* **`%n`**: Returns the number of characters read so far.
* **`%%`**: Reads and discards a single '%' character.

**Example:**

```c
#include <stdio.h>

int main() {
    int num1, num2;
    char name[50];

    printf("Enter two numbers separated by a space: ");
    scanf("%d %d", &num1, &num2);

    printf("Enter your name: ");
    scanf(" %[^\n]", name); // Read until newline character is encountered

    printf("Numbers: %d, %d\n", num1, num2);
    printf("Name: %s\n", name);

    return 0;
}
```

In this example:

* `%d %d` in the first `scanf()` statement expects two integers separated by a space.
* `" %[^\n]"` in the second `scanf()` statement reads a string of characters until a newline character is encountered, allowing spaces in the input. 
	* The space before `"%[^\n]"` in the `scanf()` format string is used to consume any leading whitespace characters (spaces, tabs, etc.) in the input buffer before attempting to read the string of characters until a newline (`'\n'`) is encountered.

**Important Notes:**

* Whitespace characters (space, tab, newline) in the format string match zero or more whitespace characters in the input.
* Each conversion specifier in the format string corresponds to an argument in the `scanf()` function where the read value will be stored.
* Make sure to use the correct format specifiers to match the data types of the variables being read.
* Error handling is important when using `scanf()`. Check the return value to ensure that the correct number of values were read and processed.
### `fputs`

The `fputs()` function in C is used to write a string to the specified file stream. It appends the null-terminated string pointed to by `str` to the file associated with the given file stream `stream`. 

```c
int fputs(const char *str, FILE *stream);
```

* `str`: A pointer to the null-terminated string to be written to the file stream.
* `stream`: A pointer to the `FILE` object representing the file stream to write to.

The function returns a non-negative value on success and `EOF` (which is typically -1) on failure.

Example usage of `fputs()`:

```c
#include <stdio.h>

int main() {
    FILE *file = fopen("example.txt", "w"); // Open file for writing

    if (file != NULL) {
        const char *text = "Hello, world!\n";
        if (fputs(text, file) != EOF) {
            printf("String successfully written to file.\n");
        } else {
            perror("Error writing to file");
        }
        
        fclose(file); // Close the file stream
    } else {
        perror("Error opening file");
        return 1;
    }

    return 0;
}
```

In this example, the program opens a file named "example.txt" for writing. It then writes the string "Hello, world!\n" to the file using the `fputs()` function. Finally, it closes the file stream after writing.

### `fgets`

The `fgets()` function in C is used to read a line of text from a specified input stream, typically from the standard input (`stdin`) or from a file. It reads characters from the input stream up to and including the newline character (`'\n'`) or until the specified maximum number of characters is read.

**Syntax:**

```c
char *fgets(char *str, int n, FILE *stream);
```

* `str`: Pointer to a character array where the read characters will be stored.
* `n`: Maximum number of characters to read, including the null terminator.
* `stream`: Pointer to the `FILE` object representing the input stream from which to read.

**Example:**

```c
#include <stdio.h>

int main() {
    char buffer[100];

    printf("Enter a string: ");
    fgets(buffer, sizeof(buffer), stdin);

    printf("You entered: %s\n", buffer);

    return 0;
}
```

In this example, `fgets()` reads characters from the standard input (`stdin`) and stores them in the `buffer` array. It reads up to 99 characters from the input stream (leaving space for the null terminator) or until a newline character is encountered.

**Important Points to Note:**

* `fgets()` includes the newline character (`'\n'`) in the string it reads, if encountered before reaching the maximum number of characters or the end of the stream.
* The newline character (`'\n'`) is replaced by a null terminator (`'\0'`) at the end of the string.
* If `fgets()` encounters the end of the file (EOF) before reading any characters, or if an error occurs during reading, it returns `NULL`.
* `fgets()` is safer than `gets()` because it allows you to specify the maximum number of characters to read, which helps prevent buffer overflow vulnerabilities.

**Return Value:**

* On success, `fgets()` returns the same pointer passed as the `str` parameter, pointing to the first character of the string read.
* On failure, such as encountering the end of the file or an error during reading, it returns `NULL`.

**Example of Error Handling:**

```c
char buffer[100];
if (fgets(buffer, sizeof(buffer), stdin) == NULL) {
    printf("Error reading input\n");
    return 1;
}
```

In this example, if `fgets()` returns `NULL`, indicating an error during reading, it prints an error message and exits the program.

`fgets()` is a useful function for reading lines of text from input streams in C, and it provides a safer alternative to functions like `gets()` which do not limit the number of characters read, potentially leading to buffer overflow vulnerabilities.

### `puts`

The `puts()` function in C is used to write a string to the standard output (stdout). It appends a newline character (`'\n'`) to the end of the string and then writes the entire string to the output stream. Unlike `printf()`, `puts()` is specifically designed for writing strings and does not support format specifiers.

**Syntax:**

```c
int puts(const char *str);
```

* `str`: Pointer to the null-terminated string to be written to the output stream.

**Example:**

```c
#include <stdio.h>

int main() {
    char message[] = "Hello, world!";
    
    puts(message);
    
    return 0;
}
```

In this example, the `puts()` function writes the string "Hello, world!" to the standard output (`stdout`) followed by a newline character (`'\n'`).

**Return Value:**

* On success, `puts()` returns a non-negative integer.
* On failure or error, it returns `EOF` (end-of-file), indicating that an error occurred during the output operation.

**Important Points to Note:**

* `puts()` automatically appends a newline character (`'\n'`) to the end of the string it writes.
* It is simpler and more convenient than `printf()` when writing strings to the output stream, especially when no formatting is needed.
* `puts()` does not support format specifiers, so you cannot use it to write formatted output.
* Unlike `printf()`, `puts()` does not return the number of characters written. It only indicates success or failure with the return value.

**Example of Error Handling:**

```c
if (puts("Hello, world!") == EOF) {
    printf("Error writing to stdout\n");
    return 1;
}
```

In this example, if `puts()` returns `EOF`, indicating an error during writing, it prints an error message and exits the program.

`puts()` is commonly used for writing strings to the standard output stream, particularly when line breaks are desired at the end of each string. However, it does not provide the flexibility of `printf()` for formatting output.

### `gets`

The `gets()` function in C is used to read a line of text from the standard input stream (`stdin`) and stores it as a null-terminated string into the buffer pointed to by `str`. However, `gets()` is considered unsafe and should not be used in modern C programming due to its vulnerability to buffer overflow attacks. It does not perform any bounds checking, which can lead to overwriting memory beyond the boundaries of the buffer.

Here's the prototype of the `gets()` function:

```c
char *gets(char *str);
```

* `str`: Pointer to the character array (buffer) where the string read from `stdin` will be stored.

The function returns the same pointer `str` if successful, and `NULL` if an error occurs or if end-of-file is reached.

Example usage of `gets()` (though not recommended due to security risks):

```c
#include <stdio.h>

int main() {
    char buffer[100]; // Buffer to store input

    printf("Enter a string: ");
    if (gets(buffer) != NULL) {
        printf("You entered: %s\n", buffer);
    } else {
        printf("Error reading input.\n");
    }

    return 0;
}
```

In this example, the program prompts the user to enter a string. It then uses `gets()` to read a line of text from `stdin` and stores it in the `buffer` array. Finally, it prints the entered string back to the user.

It's important to note that using `gets()` is highly discouraged due to its lack of buffer overflow protection. Instead, you should use safer alternatives such as `fgets()` which allows you to specify the size of the buffer to avoid overflows.

### `fprintf`

The `fprintf()` function in C is used to write formatted data to a specified output stream. It is similar to `printf()` but allows you to specify the output stream where the formatted data will be written. You can use `fprintf()` to write to files, standard output (`stdout`), standard error (`stderr`), or any other output stream represented by a `FILE` pointer.

		**Syntax:**

```c
int fprintf(FILE *stream, const char *format, ...);
```

* `stream`: Pointer to the output stream where the formatted data will be written.
* `format`: A string that specifies the format of the output.
* `...`: Additional arguments representing the values to be formatted and written to the output stream.

**Example:**

```c
#include <stdio.h>

int main() {
    FILE *fp;
    char filename[] = "output.txt";

    // Open the file for writing
    fp = fopen(filename, "w");
    if (fp == NULL) {
        printf("Error opening the file.\n");
        return 1;
    }

    // Write formatted data to the file
    fprintf(fp, "Hello, %s! You are %d years old.\n", "John", 30);

    // Close the file
    fclose(fp);

    return 0;
}
```

In this example, `fprintf()` writes the formatted string "Hello, John! You are 30 years old." to the file named "output.txt". The `fopen()` function is used to open the file for writing, and `fclose()` is used to close the file after writing.

**Return Value:**

* `fprintf()` returns the number of characters written to the output stream if successful.
* If an error occurs during writing, it returns a negative value to indicate failure.

Important Points to Note:

* You can use `fprintf()` to write formatted data to any output stream represented by a `FILE` pointer, including files, standard output (`stdout`), and standard error (`stderr`).
* Like `printf()`, `fprintf()` supports format specifiers such as `%s`, `%d`, `%f`, etc., allowing you to format data before writing it to the output stream.
* Make sure to check the return value of `fprintf()` to handle errors during writing to the output stream.

**Example of Error Handling:**

```c
if (fprintf(fp, "Hello, world!\n") < 0) {
    printf("Error writing to the file.\n");
    return 1;
}
```

In this example, if `fprintf()` returns a negative value, indicating an error during writing, it prints an error message and exits the program.

`fprintf()` is a versatile function for writing formatted data to output streams, and it provides flexibility for directing output to different destinations based on the `FILE` pointer provided.

### `vfprintf`

`vfprintf` is a function in C that is used to write formatted output to a given output stream. It is similar to `fprintf`, but it takes a `va_list` argument instead of a variable number of arguments directly. This allows `vfprintf` to be used in situations where the number of arguments is not known at compile time.

Here's the syntax of `vfprintf`:

```c
int vfprintf(FILE *stream, const char *format, va_list arg);
```

- `stream`: Pointer to the output stream where the formatted output will be written.
- `format`: A format string that specifies how the output should be formatted, similar to the format string used in `printf`.
- `arg`: A `va_list` object containing the variable arguments to be formatted and written to the output stream.

The `vfprintf` function writes the formatted output to the specified output stream according to the format string and the variable arguments provided in the `va_list`.

Here's a simple example of how to use `vfprintf`:

```c
#include <stdio.h>
#include <stdarg.h>

int main() {
    FILE *file = fopen("output.txt", "w");
    if (file != NULL) {
        int value = 42;
        double pi = 3.14159;
        const char *message = "Hello, world!";
        
        // Format and write output to the file using vfprintf
        vfprintf(file, "Value: %d, Pi: %.2f, Message: %s\n", va_list(value, pi, message));
        
        fclose(file);
    } else {
        printf("Failed to open file.\n");
    }
    
    return 0;
}
```

In this example, `vfprintf` is used to write formatted output to a file named "output.txt". The format string specifies placeholders for an integer (`%d`), a double (`%.2f`), and a string (`%s`). The corresponding arguments (`value`, `pi`, and `message`) are provided in a `va_list`. Finally, the file is closed after writing the output.

### `fscanf`

The `fscanf()` function in C is used to read formatted input from a specified input stream, such as a file stream or the standard input stream (`stdin`).

* **Purpose**: `fscanf()` reads data from the input stream according to the specified format string and stores the results into the locations specified by the provided pointers.
    
* **Syntax**:
    
    ```c
    int fscanf(FILE *stream, const char *format, ...);
    ```
    
* **Parameters**:
    * `stream`: A pointer to the `FILE` object representing the input stream from which to read the formatted input.
    * `format`: A format string that specifies how the input data should be interpreted and parsed.
    * Additional arguments: Pointers to the memory locations where the read data will be stored. The number and types of these additional arguments depend on the format string.
* **Return Value**:
    * `fscanf()` returns the number of input items successfully matched and assigned. This can be less than the number of format specifiers in the format string if a matching failure occurs or if the end of the file is reached before all items are successfully matched and assigned. In case of an error, it returns `EOF`.
* **Example**:
    
    ```c
#include <stdio.h>

int main() {
	FILE *file;
	int num1, num2;

	// Open file for reading
	file = fopen("example.txt", "r");
	if (file == NULL) {
		perror("Error opening file");
		return 1;
	}

	// Read two integers from the file
	if (fscanf(file, "%d %d", &num1, &num2) == 2) {
		printf("Read integers: %d, %d\n", num1, num2);
	} else {
		printf("Error reading integers from file.\n");
	}

	// Close the file
	fclose(file);

	return 0;
}
    ```
    
* **Usage**:
    * `fscanf()` is useful when you need to read formatted input from files or other input streams.
    * The format string specifies the pattern that `fscanf()` should look for in the input stream. It can include format specifiers like `%d` for integers, `%f` for floats, `%s` for strings, and so on.
    * Error handling is important. Check the return value of `fscanf()` to ensure that the expected data has been successfully read.

Understanding how to use `fscanf()` allows you to efficiently read and parse input data from files or other input streams in C programs.

### `perror`

The `perror()` function in C is used to print an error message to the standard error (`stderr`) stream, accompanied by a string representation of the current value of the `errno` variable. It is particularly useful for providing meaningful error messages when system calls or library functions fail.

**Syntax:**

```c
void perror(const char *s);
```

* `s`: A string that will be prepended to the error message.

**Example:**

```c
#include <stdio.h>
#include <errno.h>

int main() {
    FILE *fp;
    
    fp = fopen("nonexistent_file.txt", "r");
    if (fp == NULL) {
        perror("Error opening file");
        return 1;
    }

    fclose(fp);

    return 0;
}
```

In this example, if the file "nonexistent_file.txt" does not exist, `fopen()` will fail and return `NULL`. The `perror()` function is then called to print an error message to `stderr`, indicating the reason for the failure, along with a string provided by the programmer ("Error opening file").

**Output:**

```yaml
Error opening file: No such file or directory
```

The error message generated by `perror()` provides valuable information about the error condition, making it easier to diagnose and fix problems in the program.

**Important Points to Note:**

* `perror()` prints the string specified by the `s` parameter, followed by a colon and a space, and then the error message corresponding to the current value of `errno`.
* The `errno` variable is set by various system calls and library functions to indicate the nature of the error that occurred.
* It is important to include meaningful context in the string provided to `perror()` so that the error message is informative and relevant to the specific operation that failed.
* Unlike some other error-handling functions, `perror()` does not terminate the program after printing the error message. It is the responsibility of the programmer to decide how to handle the error condition.

`perror()` is a simple yet effective tool for providing informative error messages in C programs, helping developers quickly identify and address issues that arise during program execution.

### `getchar`

The `getchar()` function in C is used to read a single character from the standard input stream (`stdin`). It is a part of the Standard I/O Library (`stdio.h`) in C.

**Syntax:**

```c
int getchar(void);
```

* The function takes no arguments.
* It returns an integer representing the character read as an unsigned char cast to an int or `EOF` if the end of the file or an error occurs.

**Example:**

```c
#include <stdio.h>

/* copy input to output; 2nd version */
int main()
{
    int c;

    while ((c = getchar()) != EOF)
        putchar(c);

    return 0;
}

```

The parentheses around the assignment, within the condition are necessary. The precedence of != is higher than that of =, which means that in the absence of parentheses the relational test != would be done before the assignment =.

What appears to be a character on the keyboard or screen is of course, like everything else, stored internally just as a bit pattern. The type char is specifically meant for storing such character data, but any integer type can be used. We used int for a subtle but important reason.

The problem is distinguishing the end of input from valid data. The solution is that getchar returns a distinctive value when there is no more input, a value that cannot be confused with any real character. This value is called EOF, for end of file. We must declare c to be a type big enough to hold any value that getchar returns. We can't use char since c must be big enough to hold EOF in addition to any possible char. Therefore we use int. 

EOF is an integer defined in <stdio.h>, but the specific numeric value doesn't matter as long as it is not the same as any char value. By using the symbolic constant, we are assured that nothing in the program depends on the specific numeric value.

**Important Points:**

* `getchar()` reads the next available character from the standard input stream (`stdin`) and advances the input pointer.
* It returns the ASCII value of the character read as an integer.
* If there are no characters available in the input stream, the program will wait until the user inputs a character.
* If an error occurs while reading the input, `getchar()` returns `EOF`.

**Usage Notes:**

* `getchar()` is often used in loops for reading characters until a specific condition is met, such as reaching the end of a line or the end of the file.
* To read characters from a file instead of standard input, you can use `fgetc()` with a file pointer obtained from `fopen()`.

Overall, `getchar()` is a simple and commonly used function for reading characters from the standard input stream in C programs. It provides basic functionality for character-based input processing.

### `putchar`

The `putchar()` function in C is used to write a single character to the standard output stream (`stdout`).

**Syntax:**

```c
int putchar(int c);
```

* `c`: The character to be written to the standard output stream.
* It returns the character written as an unsigned char cast to an int, or `EOF` if an error occurs.

**Example:**

```c
#include <stdio.h>

int main() {
    char ch = 'A';
    
    putchar(ch); // Writes 'A' to stdout

    return 0;
}
```

In this example, the `putchar()` function writes the character 'A' to the standard output stream (`stdout`). The character is displayed on the console.

**Important Points:**

* `putchar()` is commonly used to output characters to the console or terminal.
* It is especially useful when you need to output single characters or characters stored in variables.
* Like other I/O functions, `putchar()` returns a non-negative integer if successful, and `EOF` if an error occurs.

**Usage Notes:**

* `putchar()` is often used in loops for outputting characters from strings or arrays.
* It's a simple and efficient way to output characters without the need for formatting.
* Unlike `printf()`, `putchar()` does not support format specifiers. It only writes single characters to the standard output stream.

`putchar()` is a fundamental function for character output in C programs, allowing you to display characters on the console or write them to other output streams. It's particularly useful for simple output tasks and character-based I/O operations.

### `getline`

The `getline` function reads an entire line from the input stream, dynamically allocates memory to accommodate the line, and stores the line (including the newline character) into a buffer. It automatically adjusts the size of the buffer as needed to accommodate lines of varying lengths.

Here's the syntax and usage of the `getline` function:

```c
ssize_t getline(char **lineptr, size_t *n, FILE *stream);
```

* `lineptr`: A pointer to the buffer where the line will be stored. If `*lineptr` is `NULL` or if the allocated buffer is not large enough to hold the line, `getline` will allocate a new buffer using `malloc` and assign the address to `*lineptr`.
* `n`: A pointer to the size of the allocated buffer. Initially, `*n` should be set to `0` or the address of a variable containing `0`. Upon successful execution, `*n` will be updated with the size of the allocated buffer.
* `stream`: The input stream from which `getline` reads the line. Typically, this is a file stream (e.g., `stdin` for standard input).

The `getline` function returns the number of characters read, including the newline character (`'\n'`), or `-1` if an error occurs or if the end of the file is reached.

Here's an example of using `getline` to read lines from standard input:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    char *line = NULL; // Buffer for storing the line
    size_t len = 0;     // Initial size of the buffer
    ssize_t read;       // Number of characters read

    // Read lines from standard input until EOF is encountered
    while ((read = getline(&line, &len, stdin)) != -1) {
        printf("Line read (%zd bytes): %s", read, line);
    }

    // Free dynamically allocated memory
    free(line);
    
    return 0;
}
```

In this example:

* The program reads lines from standard input using `getline`.
* The `line` pointer is initially `NULL`, so `getline` dynamically allocates memory as needed.
* The size of the allocated buffer is initially `0`, but `getline` updates it dynamically based on the size of the line read.
* The loop continues reading lines until the end of the file is reached (`getline` returns `-1`).
* After reading all lines, the dynamically allocated memory is freed using `free(line)`.

### `fgetc`

The `fgetc()` function in C is used to read a single character from a specified input stream, such as a file stream or the standard input stream (`stdin`).

**Syntax:**

```c
int fgetc(FILE *stream);
```

* `stream`: A pointer to the `FILE` object representing the input stream from which to read the character.
* It returns the next character from the input stream as an unsigned char cast to an int, or `EOF` if the end of the file or an error occurs.

**Example:**

```c
#include <stdio.h>

int main() {
    FILE *file;
    int c;

    file = fopen("example.txt", "r"); // Open file for reading
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    // Read characters from the file until end of file (EOF) is reached
    while ((c = fgetc(file)) != EOF) {
        putchar(c); // Output character to stdout
    }

    fclose(file); // Close the file

    return 0;
}
```

In this example, the program opens a file named "example.txt" for reading. It reads characters from the file using `fgetc()` inside a loop, printing each character to the standard output (`stdout`). The loop continues until `fgetc()` returns `EOF`, indicating the end of the file or an error.

**Important Points:**

* `fgetc()` reads the next character from the specified input stream and advances the file position indicator.
* It returns the ASCII value of the character read as an integer.
* If the end of the file is reached, `fgetc()` returns `EOF` (End-of-File), which is typically defined as a negative integer constant.
* If an error occurs while reading the input stream, `fgetc()` also returns `EOF`.

**Usage Notes:**

* `fgetc()` is often used in conjunction with file handling functions (`fopen()`, `fclose()`) to read characters from files.
* It's common to use `fgetc()` in a loop to read characters from a file until the end of the file is reached.
* Error handling is important when using `fgetc()`. Check the return value to detect errors or the end of the file.

`fgetc()` provides a simple and effective way to read characters from files or other input streams in C programs, facilitating various file processing tasks.

### `fopen`

The `fopen()` function in C is used to open a file and associate it with a stream. It is part of the Standard I/O Library (`stdio.h`) in C.

**Syntax:**

```c
FILE *fopen(const char *filename, const char *mode);
```

* `filename`: A string containing the name of the file to be opened.
* `mode`: A string indicating the file access mode. It can be one of the following:
    * `"r"`: Open file for reading. The file must exist.
    * `"w"`: Create an empty file for writing. If the file already exists, its contents are truncated.
    * `"a"`: Append to a file. Writing operations append data to the end of the file. The file is created if it does not exist.
    * `"r+"`: Open file for both reading and writing. The file must exist.
    * `"w+"`: Create an empty file for both reading and writing. If the file already exists, its contents are truncated.
    * `"a+"`: Open file for reading and appending. The file is created if it does not exist.

**Return Value:**

* If successful, `fopen()` returns a pointer to the `FILE` object associated with the opened file.
* If an error occurs, it returns `NULL`, indicating failure to open the file.

**Example:**

```c
#include <stdio.h>

int main() {
    FILE *file;

    // Open a file named "example.txt" for writing
    file = fopen("example.txt", "w");
    if (file == NULL) {
        printf("Error opening file!\n");
        return 1;
    }

    // Write data to the file

    // Close the file
    fclose(file);

    return 0;
}
```

In this example, `fopen()` opens a file named "example.txt" for writing. If successful, it returns a pointer to a `FILE` object representing the opened file. The file can then be used for reading from or writing to.

**Important Points:**

* When opening a file, it's essential to handle potential errors by checking the return value of `fopen()`.
* Ensure proper file closing using `fclose()` after file operations are completed to release system resources associated with the file.
* File access modes determine how the file can be used (e.g., reading, writing, appending) and whether the file is created or truncated.
* The behavior of file opening operations may vary slightly across different operating systems and file systems, so it's crucial to understand the implications of different modes.

`fopen()` is a fundamental function for file handling in C programs, allowing you to open files for reading, writing, or appending data. Understanding its usage and file access modes is essential for effective file I/O operations in C.

### `fclose`

The `fclose()` function in C is used to close a file stream that was previously opened using `fopen()`, `freopen()`, or `fdopen()`.

**Syntax:**

```c
int fclose(FILE *stream);
```

* `stream`: A pointer to the `FILE` object representing the file stream to be closed.

**Return Value:**

* If the file stream is successfully closed, `fclose()` returns zero.
* If an error occurs while closing the file stream, it returns `EOF` (End-of-File).

**Example:**

```c
#include <stdio.h>

int main() {
    FILE *file = fopen("example.txt", "r");
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    // Perform file operations...

    if (fclose(file) == 0) {
        printf("File closed successfully.\n");
    } else {
        perror("Error closing file");
    }

    return 0;
}
```

In this example, `fclose()` is used to close the file stream represented by the `FILE` pointer `file`. It first checks if the file stream is successfully closed and prints a corresponding message. If an error occurs during the closing operation, it prints an error message using `perror()`.

**Important Points:**

* Always close file streams after performing file operations to release system resources associated with the file.
* Closing a file stream flushes any buffered data associated with the file, ensuring that all pending write operations are completed before the file is closed.
* Attempting to perform operations on a closed file stream results in undefined behavior.
* Errors during the closing operation may occur due to various reasons, such as file system errors or insufficient permissions.

Proper usage of `fclose()` ensures that files are closed safely and efficiently after file operations are completed, preventing resource leaks and potential file corruption. It is a critical aspect of file handling in C programming.

### `fread`

The `fread()` function in C is used to read data from a file stream.

* **Purpose**: `fread()` reads data from the file associated with the specified file pointer (`FILE *`) into the memory location pointed to by the provided buffer.
    
* **Syntax**:
    ```c
    size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);
    ```
    
* **Parameters**:
    * `ptr`: Pointer to the memory location where the read data will be stored.
    * `size`: Size in bytes of each element to be read.
	    * Specifies the size of each data element in bytes.
	    - It determines the number of bytes that `fread()` will attempt to read for each element from the file stream.
	    - The total number of bytes read from the file stream is calculated as `nmemb * size`
    * `nmemb`: Number of elements to be read.
	    - Specifies the number of data elements to be read from the file stream.
	    - Each "element" represents a distinct unit of data that will be read from the file. The actual interpretation of an "element" depends on the context of the data being read.
	    - For example, if you are reading integers from a file, each integer would typically be considered an "element."
    * `stream`: Pointer to the file stream from which data will be read.
* **Return Value**:
    * `fread()` returns the total number of elements successfully read. If an error occurs, or the end of the file is reached before reading the requested number of elements, it returns a value less than `nmemb`. The return value can be used to determine if the read operation was successful.
* **Example**:
    
    ```c
#include <stdio.h>

int main() {
	FILE *file;
	char buffer[100];

	// Open file for reading
	file = fopen("example.txt", "r");
	if (file == NULL) {
		perror("Error opening file");
		return 1;
	}

	// Read 10 elements of size 10 bytes each into buffer
	size_t elements_read = fread(buffer, 10, 10, file);
	if (elements_read != 10) {
		perror("Error reading from file");
		fclose(file);
		return 1;
	}

	// Close the file
	fclose(file);

	return 0;
}
    ```
    
* **Usage**:
    * `fread()` is commonly used to read binary data from files. It's useful for reading structured data where the size of each element is fixed.
    * Error handling is important. Always check the return value to ensure that the desired amount of data has been read.
    * Remember to open the file in the appropriate mode (`"r"`, `"rb"`, etc.) before using `fread()`.

`fread()` is a versatile function for reading binary data from files in C, and it's commonly used in file I/O operations, especially when dealing with structured binary data.

**File Handling Modes:**

When opening a file in C, you specify a mode that determines how the file will be accessed. The modes are represented by strings that contain one or more characters, each indicating a specific access mode. The most common modes include:

* **"r"**: Read mode. Opens a file for reading. The file must exist.
* **"w"**: Write mode. Opens a file for writing. If the file exists, its contents are overwritten. If the file does not exist, a new file is created.
* **"a"**: Append mode. Opens a file for writing. If the file exists, new data is appended to the end of the file. If the file does not exist, a new file is created.
* **"r+"**: Read and write mode. Opens a file for both reading and writing. The file must exist.
* **"w+"**: Read and write mode. Opens a file for both reading and writing. If the file exists, its contents are overwritten. If the file does not exist, a new file is created.
* **"a+"**: Read and append mode. Opens a file for both reading and appending. If the file exists, new data is appended to the end of the file. If the file does not exist, a new file is created.

### `freopen`

The `freopen()` function in C is used to change the file associated with a given stream. It allows you to reopen a file stream with a different file than the one it currently points to. This function is part of the Standard I/O Library (`stdio.h`) in C.

The syntax of the `freopen()` function is as follows:

```c
FILE *freopen(const char *filename, const char *mode, FILE *stream);
```

* `filename`: A string containing the name of the file to be associated with the stream.
* `mode`: A string indicating the file access mode, similar to the modes used in `fopen()`.
* `stream`: A pointer to the `FILE` object representing the stream to be reopened.

The function returns a pointer to the `FILE` object associated with the stream if successful. If an error occurs, it returns `NULL`.

Here's an example of how to use `freopen()`:

```c
#include <stdio.h>

int main() {
    FILE *file;

    // Open a file for writing
    file = freopen("output.txt", "w", stdout);
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    // Write data to the file
    printf("Hello, world!\n");

    // Close the file
    fclose(file);

    return 0;
}
```

In this example, `freopen()` is used to associate the file "output.txt" with the standard output stream `stdout`. As a result, any subsequent output operations to `stdout` will be directed to the file "output.txt". Finally, the file is closed using `fclose()`.

`freopen()` is useful when you need to redirect input or output streams to different files dynamically during program execution. It provides flexibility in managing file streams within C programs.

### `fdopen`

The `fdopen()` function in C is used to associate a file descriptor with a stream. It allows you to create a new stream from an existing file descriptor.

* **Purpose**: `fdopen()` creates a new stream that is associated with an existing file descriptor. This enables file I/O operations using standard I/O functions (`fprintf()`, `fscanf()`, etc.) on the specified file descriptor.
    
* **Syntax**:
    ```c
    FILE *fdopen(int fd, const char *mode);
    ```
    
* **Parameters**:
    * `fd`: An integer representing the file descriptor to be associated with the stream.
    * `mode`: A string indicating the file access mode, similar to the modes used in `fopen()`.
* **Return Value**:
    * If successful, `fdopen()` returns a pointer to the `FILE` object associated with the new stream. If an error occurs, it returns `NULL`.
* **Example**:
    
    ```c
#include <stdio.h>
#include <fcntl.h>

int main() {
	int fd;
	FILE *file;

	// Open a file for writing and get the file descriptor
	fd = open("output.txt", O_WRONLY | O_CREAT, 0644);
	if (fd == -1) {
		perror("Error opening file");
		return 1;
	}

	// Associate the file descriptor with a stream
	file = fdopen(fd, "w");
	if (file == NULL) {
		perror("Error associating file descriptor with stream");
		close(fd);
		return 1;
	}

	// Write data to the stream
	fprintf(file, "Hello, world!\n");

	// Close the stream (automatically closes the file descriptor)
	fclose(file);

	return 0;
}
    ```
    
* **Usage**:
    * `fdopen()` is useful when you need to work with file descriptors and streams interchangeably in C programs. It provides flexibility in managing file I/O operations.
    * After associating a file descriptor with a stream using `fdopen()`, standard I/O functions can be used to perform I/O operations on the file descriptor.

Understanding and using `fdopen()` is important for advanced file I/O operations and low-level programming in C. It enables interaction between file descriptors and streams, allowing developers to leverage the capabilities of both mechanisms.

### `fwrite`

The `fwrite()` function in C is used to write data to a file stream. It allows you to write a specified number of elements, each with a specified size, to the given file stream.

```c
size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);
```

* `ptr`: A pointer to the array of elements to be written to the file.
* `size`: The size in bytes of each element to be written.
* `nmemb`: The number of elements to write.
* `stream`: A pointer to the `FILE` object representing the file stream to write to.

The function returns the total number of elements successfully written, which may be less than `nmemb` if an error occurs or the end-of-file is reached.

Example usage of `fwrite()`:

```c
#include <stdio.h>

int main() {
    int data[] = {1, 2, 3, 4, 5};
    FILE *file = fopen("data.bin", "wb"); // Open file for binary writing

    if (file != NULL) {
        size_t elements_written = fwrite(data, sizeof(int), 5, file);
        printf("Elements written: %zu\n", elements_written);
        
        fclose(file); // Close the file stream
    } else {
        perror("Error opening file");
        return 1;
    }

    return 0;
}
```

In this example, the program writes the integer array `data` to a binary file named "data.bin". It writes 5 elements, each of size `sizeof(int)` bytes, to the file stream opened in binary writing mode ("wb"). Finally, it closes the file stream after writing.

### `fseek`

`fseek` is a C standard library function used to move the file position indicator associated with a given file pointer to a specified location within the file. It is typically used for file positioning operations in both reading and writing modes.

The function signature for `fseek` is as follows:

```c
int fseek(FILE *stream, long int offset, int whence);
```

* `stream`: A pointer to the FILE object that represents the file where the position indicator will be moved.
* `offset`: The number of bytes to offset from the origin specified by `whence`.
* `whence`: Specifies the reference point for the offset calculation. It can take one of the following values:
    * `SEEK_SET` (0): The offset is relative to the beginning of the file.
    * `SEEK_CUR` (1): The offset is relative to the current position indicator.
    * `SEEK_END` (2): The offset is relative to the end of the file.

The return value of `fseek` indicates success (zero) or failure (non-zero). If the function fails, the file position indicator may be left in an unspecified state.

**Example:**

```c
#include <stdio.h>

int main() {
    FILE *fp = fopen("example.txt", "r");
    if (fp == NULL) {
        perror("Error opening file");
        return 1;
    }

    // Move the file position indicator 10 bytes from the beginning of the file
    if (fseek(fp, 10, SEEK_SET) != 0) {
        perror("Error seeking file");
        fclose(fp);
        return 1;
    }

    // Perform operations after seeking

    fclose(fp);
    return 0;
}
```

In this example, `fseek` is used to move the file position indicator 10 bytes from the beginning of the file "example.txt". After seeking, you can perform read or write operations at the new file position.

### `ftell`

`ftell` is a C standard library function used to determine the current position of the file pointer associated with a given file stream. It returns the current position indicator within the file represented by the FILE pointer. The return value represents the byte offset from the beginning of the file.

The function signature for `ftell` is:

```c
long int ftell(FILE *stream);
```

* `stream`: A pointer to the FILE object representing the file stream for which you want to determine the current position.

The return value of `ftell` is the current position indicator within the file stream, represented as a long integer. If an error occurs, `ftell` returns -1L, and `errno` is set to indicate the error.

**Example:**

```c
#include <stdio.h>

int main() {
    FILE *fp = fopen("example.txt", "r");
    if (fp == NULL) {
        perror("Error opening file");
        return 1;
    }

    // Move the file position indicator to a different location
    fseek(fp, 10, SEEK_SET);

    // Get the current position of the file pointer
    long int position = ftell(fp);
    if (position == -1L) {
        perror("Error getting file position");
        fclose(fp);
        return 1;
    }

    printf("Current position: %ld\n", position);

    fclose(fp);
    return 0;
}
```

In this example, `ftell` is used to determine the current position of the file pointer after seeking 10 bytes from the beginning of the file "example.txt". The current position is then printed to the standard output.

### `rewind`

The `rewind()` function in C is used to reset the file position indicator associated with the specified file stream to the beginning of the file. It allows you to "rewind" or move the file pointer back to the start of the file, effectively resetting its position.

Here's the prototype of the `rewind()` function:

```c
void rewind(FILE *stream);
```

* `stream`: A pointer to the `FILE` object representing the file stream whose position indicator will be reset.

The `rewind()` function does not return a value.

Example usage of `rewind()`:

```c
#include <stdio.h>

int main() {
    FILE *file = fopen("example.txt", "r"); // Open file for reading

    if (file != NULL) {
        // Read data from the file
        // ...

        // After reading, rewind the file to the beginning
        rewind(file);

        // Now the file position indicator is at the start of the file again
        // You can read from the beginning of the file again if needed
        // ...
        
        fclose(file); // Close the file stream
    } else {
        perror("Error opening file");
        return 1;
    }

    return 0;
}
```

In this example, the program opens a file named "example.txt" for reading. After reading data from the file (not shown), it calls `rewind(file)` to reset the file position indicator to the beginning of the file. This allows subsequent read operations to start from the beginning of the file again. Finally, the program closes the file stream using `fclose()`.

### `feof`

The `feof()` function in C is used to check whether the end-of-file indicator associated with a given file stream has been set. It allows you to determine if the current position indicator in the file stream has reached the end of the file.

Here's the prototype of the `feof()` function:

```c
int feof(FILE *stream);
```

* `stream`: A pointer to the `FILE` object representing the file stream to be checked for the end-of-file condition.

The `feof()` function returns a non-zero value (true) if the end-of-file indicator is set for the specified file stream, indicating that the next input operation will encounter the end of the file. It returns 0 (false) otherwise.

Example usage of `feof()`:

```c
#include <stdio.h>

int main() {
    FILE *file = fopen("example.txt", "r"); // Open file for reading

    if (file != NULL) {
        int c;
        while ((c = fgetc(file)) != EOF) {
            putchar(c); // Output character to stdout
        }

        if (feof(file)) {
            printf("\nEnd of file reached.\n");
        } else {
            printf("\nEnd of file not reached.\n");
        }
        
        fclose(file); // Close the file stream
    } else {
        perror("Error opening file");
        return 1;
    }

    return 0;
}
```

In this example, the program opens a file named "example.txt" for reading. It then reads characters from the file stream using `fgetc()` in a loop until the end of the file is reached (EOF is encountered). After reading, it checks if the end-of-file indicator is set using `feof()` and prints a message accordingly. Finally, it closes the file stream using `fclose()`.

### `fgetc`

The `fgetc()` function in C is used to read a single character from a file pointed to by the specified file pointer. It reads the next character from the input stream associated with the file pointer and advances the file position indicator to the next character.

Here's the syntax of the `fgetc()` function:

```c
int fgetc(FILE *stream);
```

* `stream`: A pointer to the FILE object representing the input stream from which the character will be read.

The function returns the character read as an unsigned char cast to an int or `EOF` if an error occurs or if the end of the file is reached.

Here's a simple example demonstrating the usage of `fgetc()` to read characters from a file:

```c
#include <stdio.h>

int main() {
    FILE *fp;
    int ch;

    fp = fopen("test.txt", "r");

    if (fp == NULL) {
        perror("Error opening file");
        return 1;
    }

    // Read characters until end of file is reached
    while ((ch = fgetc(fp)) != EOF) {
        printf("%c", ch);
    }

    fclose(fp);
    return 0;
}
```

In this example, the program opens a file named "test.txt" for reading. It then reads characters from the file using `fgetc()` in a loop until the end of the file is reached (`EOF` is returned). Each character read is printed to the standard output. Finally, the file is closed using `fclose()`.

### `ungetc`

The `ungetc()` function in C is used to push a character back onto the input stream. It allows you to "unread" a character, making it available for the next input operation. The `ungetc()` function takes two arguments: the character to be pushed back onto the input stream and a file pointer indicating the stream from which the character was read.

Here's the syntax of the `ungetc()` function:

```c
int ungetc(int character, FILE *stream);
```

* `character`: The character to be pushed back onto the input stream.
* `stream`: A pointer to the FILE object representing the input stream from which the character was originally read.

The function returns the character pushed back on success, or `EOF` if an error occurs.

Here's a simple example demonstrating the usage of `ungetc()`:

```c
#include <stdio.h>

int main() {
    FILE *fp;
    int ch;

    fp = fopen("test.txt", "r");

    if (fp == NULL) {
        perror("Error opening file");
        return 1;
    }

    // Read a character from the file
    ch = fgetc(fp);
    printf("Read character: %c\n", ch);

    // Push the character back onto the input stream
    if (ungetc(ch, fp) == EOF) {
        perror("Error pushing character back onto stream");
        fclose(fp);
        return 1;
    }

    // Read the character again
    ch = fgetc(fp);
    printf("Read character again: %c\n", ch);

    fclose(fp);
    return 0;
}
```

In this example, the program opens a file named "test.txt" and reads a character from it using `fgetc()`. It then pushes the same character back onto the input stream using `ungetc()` and reads it again. The output demonstrates that the character is successfully pushed back onto the input stream and read again.

