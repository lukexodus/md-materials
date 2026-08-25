## String I/O


String I/O operations handle sequences of characters as complete units, providing convenience for text processing applications.

### Input Functions

`gets()` function (deprecated and unsafe):

```c
char *gets(char *str);  // Never use - buffer overflow risk
```

`fgets()` function (recommended replacement):

```c
char *fgets(char *str, int size, FILE *stream);
```

`fgets()` provides safer string input with several important characteristics:

- Reads at most `size-1` characters
- Includes newline character if encountered
- Null-terminates the string
- Returns NULL on error or end-of-file

**Example** of safe string input:

```c
char buffer[256];

printf("Enter a line of text: ");
if (fgets(buffer, sizeof(buffer), stdin) != NULL) {
    // Remove trailing newline if present
    size_t len = strlen(buffer);
    if (len > 0 && buffer[len-1] == '\n') {
        buffer[len-1] = '\0';
    }
    printf("You entered: %s\n", buffer);
}
```

### Output Functions

`puts()` function automatically appends newline:

```c
int puts(const char *str);
```

`fputs()` function writes to specified stream without automatic newline:

```c
int fputs(const char *str, FILE *stream);
```

**Example** comparing string output functions:

```c
char message[] = "Hello, World!";

puts(message);                    // Outputs: Hello, World!\n
fputs(message, stdout);           // Outputs: Hello, World!
printf("%s\n", message);         // Outputs: Hello, World!\n
```

### String Processing with I/O

Advanced string input techniques handle complex parsing requirements:

```c
#include <stdio.h>
#include <string.h>

// Reading multiple words from a line
char line[256];
char word1[50], word2[50], word3[50];

fgets(line, sizeof(line), stdin);
sscanf(line, "%49s %49s %49s", word1, word2, word3);

// Reading until specific delimiter
char *token;
token = strtok(line, " \t\n");
while (token != NULL) {
    printf("Token: %s\n", token);
    token = strtok(NULL, " \t\n");
}
```

