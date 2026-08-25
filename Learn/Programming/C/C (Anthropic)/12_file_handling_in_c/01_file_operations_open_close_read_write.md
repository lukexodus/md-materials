## File Operations (Open, Close, Read, Write)


### Opening Files

The `fopen()` function establishes a connection between a program and a file, returning a FILE pointer that serves as a handle for subsequent operations:

```c
FILE *fopen(const char *filename, const char *mode);
```

The function returns NULL if the file cannot be opened due to permission issues, non-existent paths, or insufficient system resources.

**Example** of basic file opening:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    FILE *file = fopen("example.txt", "w");
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }
    
    printf("File opened successfully\n");
    fclose(file);
    return 0;
}
```

### Closing Files

The `fclose()` function terminates the connection to a file, flushing any buffered data and releasing system resources:

```c
int fclose(FILE *stream);
```

The function returns 0 on success or EOF if an error occurs. Failing to close files can lead to resource leaks and data corruption.

```c
FILE *file = fopen("data.txt", "r");
if (file != NULL) {
    // Perform file operations
    if (fclose(file) != 0) {
        perror("Error closing file");
    }
    file = NULL;  // Prevent accidental reuse
}
```

### Reading Operations

C provides multiple functions for reading data from files, each suited for different data types and reading patterns.

#### Character Reading

```c
int fgetc(FILE *stream);    // Read single character
int getc(FILE *stream);     // Macro version, potentially faster
```

**Example** of character-by-character file reading:

```c
#include <stdio.h>

void read_file_char_by_char(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("Error opening file");
        return;
    }
    
    int ch;
    int char_count = 0, line_count = 1;
    
    while ((ch = fgetc(file)) != EOF) {
        putchar(ch);
        char_count++;
        if (ch == '\n') {
            line_count++;
        }
    }
    
    printf("\nFile statistics: %d characters, %d lines\n", char_count, line_count);
    fclose(file);
}
```

#### String Reading

```c
char *fgets(char *str, int size, FILE *stream);
```

`fgets()` reads up to `size-1` characters or until a newline is encountered, automatically null-terminating the string:

```c
#include <stdio.h>
#include <string.h>

void read_file_line_by_line(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("Error opening file");
        return;
    }
    
    char buffer[256];
    int line_number = 1;
    
    while (fgets(buffer, sizeof(buffer), file) != NULL) {
        // Remove trailing newline if present
        size_t len = strlen(buffer);
        if (len > 0 && buffer[len-1] == '\n') {
            buffer[len-1] = '\0';
        }
        
        printf("Line %d: %s\n", line_number++, buffer);
    }
    
    fclose(file);
}
```

#### Formatted Reading

```c
int fscanf(FILE *stream, const char *format, ...);
```

`fscanf()` parses formatted input from files using the same format specifiers as `scanf()`:

```c
#include <stdio.h>

typedef struct {
    int id;
    char name[50];
    float salary;
} Employee;

void read_employee_data(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("Error opening file");
        return;
    }
    
    Employee emp;
    while (fscanf(file, "%d %49s %f", &emp.id, emp.name, &emp.salary) == 3) {
        printf("Employee: ID=%d, Name=%s, Salary=%.2f\n", 
               emp.id, emp.name, emp.salary);
    }
    
    fclose(file);
}
```

### Writing Operations

File writing functions complement reading operations, enabling data output to files.

#### Character Writing

```c
int fputc(int c, FILE *stream);
int putc(int c, FILE *stream);    // Macro version
```

#### String Writing

```c
int fputs(const char *str, FILE *stream);
```

`fputs()` writes a string to a file without automatically adding a newline character:

```c
#include <stdio.h>

void write_strings_to_file(const char *filename) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        perror("Error opening file");
        return;
    }
    
    const char *lines[] = {
        "First line of text",
        "Second line of text",
        "Third line of text"
    };
    
    for (int i = 0; i < 3; i++) {
        fputs(lines[i], file);
        fputc('\n', file);  // Add newline manually
    }
    
    fclose(file);
    printf("Data written to %s successfully\n", filename);
}
```

#### Formatted Writing

```c
int fprintf(FILE *stream, const char *format, ...);
```

**Example** combining reading and writing operations:

```c
#include <stdio.h>
#include <ctype.h>

void convert_to_uppercase(const char *input_file, const char *output_file) {
    FILE *input = fopen(input_file, "r");
    FILE *output = fopen(output_file, "w");
    
    if (input == NULL || output == NULL) {
        perror("Error opening files");
        if (input) fclose(input);
        if (output) fclose(output);
        return;
    }
    
    int ch;
    while ((ch = fgetc(input)) != EOF) {
        fputc(toupper(ch), output);
    }
    
    fclose(input);
    fclose(output);
    printf("File conversion completed\n");
}
```

