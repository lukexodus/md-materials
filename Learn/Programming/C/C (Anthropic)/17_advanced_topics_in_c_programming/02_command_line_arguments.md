## Command Line Arguments


Command line arguments allow programs to receive input parameters when executed. The main() function can accept arguments representing the command line tokens.

**Standard main() Signatures**

```c
int main(int argc, char *argv[]);
int main(int argc, char **argv);
int main(void);  // No command line access
```

**Parameter Meanings**

- `argc` (argument count) - number of command line arguments including program name
- `argv` (argument vector) - array of strings containing the arguments
- `argv[0]` - program name (implementation-dependent)
- `argv[1]` through `argv[argc-1]` - command line arguments
- `argv[argc]` - guaranteed to be NULL

**Basic Argument Processing**

```c
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    printf("Program name: %s\n", argv[0]);
    printf("Number of arguments: %d\n", argc);
    
    for (int i = 1; i < argc; i++) {
        printf("Argument %d: %s\n", i, argv[i]);
    }
    
    return 0;
}
```

**Examples**

**Option Processing**

```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    int verbose = 0;
    char *output_file = NULL;
    char *input_file = NULL;
    
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "--verbose") == 0) {
            verbose = 1;
        }
        else if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) {
            output_file = argv[++i];  // Get next argument
        }
        else if (argv[i][0] != '-') {  // Not an option
            input_file = argv[i];
        }
        else {
            fprintf(stderr, "Unknown option: %s\n", argv[i]);
            return 1;
        }
    }
    
    if (verbose) {
        printf("Verbose mode enabled\n");
        printf("Input file: %s\n", input_file ? input_file : "stdin");
        printf("Output file: %s\n", output_file ? output_file : "stdout");
    }
    
    return 0;
}
```

**Using getopt() for Complex Options**

```c
#include <unistd.h>  // POSIX systems
#include <stdio.h>

int main(int argc, char *argv[]) {
    int opt;
    int verbose = 0;
    char *output_file = NULL;
    
    while ((opt = getopt(argc, argv, "vo:h")) != -1) {
        switch (opt) {
            case 'v':
                verbose = 1;
                break;
            case 'o':
                output_file = optarg;
                break;
            case 'h':
                printf("Usage: %s [-v] [-o output] [input_file]\n", argv[0]);
                return 0;
            case '?':
                fprintf(stderr, "Unknown option\n");
                return 1;
        }
    }
    
    // Process remaining arguments
    for (int i = optind; i < argc; i++) {
        printf("Non-option argument: %s\n", argv[i]);
    }
    
    return 0;
}
```

**Environment Variable Access**

```c
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[], char *envp[]) {
    // Method 1: Using envp parameter
    printf("Environment variables:\n");
    for (int i = 0; envp[i] != NULL; i++) {
        printf("%s\n", envp[i]);
    }
    
    // Method 2: Using getenv()
    char *path = getenv("PATH");
    if (path) {
        printf("PATH: %s\n", path);
    }
    
    return 0;
}
```

**Key Points**

- argv[0] contains program name (may be full path or just filename)
- Arguments are separated by whitespace in shell
- Shell performs quote processing and expansion
- Arguments are always strings, requiring conversion for numbers
- argc includes program name in count

