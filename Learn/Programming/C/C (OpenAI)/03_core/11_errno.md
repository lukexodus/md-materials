## `errno`


`errno` is a global integer variable defined in the `<errno.h>` header file. It is used to indicate errors that occur during the execution of library functions, system calls, and other operations.

**Purpose of `errno`:**

* `errno` serves as a standard mechanism for reporting errors in C programs.
* It provides a way for functions to communicate error information to the calling code.
* The value of `errno` is set to a specific error code whenever an error occurs, allowing the programmer to determine the cause of the error and take appropriate action.

**Usage of `errno`:**

* After a library function or system call fails, the value of `errno` is set to a specific error code indicating the nature of the error.
* The error code can be retrieved using `errno`, and its corresponding error message can be obtained using functions like `perror()` or `strerror()`.
* It's important to note that the value of `errno` is set only when an error occurs. If no error occurs, its value remains unchanged.

**Common Error Codes:**

* `EINVAL`: Invalid argument.
* `ENOMEM`: Insufficient memory.
* `EIO`: Input/output error.
* `ENOENT`: No such file or directory.
* `EBADF`: Bad file descriptor.

**Example:**

```c
#include <stdio.h>
#include <errno.h>
#include <string.h>

int main() {
    FILE *file = fopen("nonexistent_file.txt", "r");
    if (file == NULL) {
        printf("Error opening file: %s\n", strerror(errno));
        return 1;
    }

    fclose(file);
    return 0;
}
```

In this example, if `fopen()` fails to open the file "nonexistent_file.txt", it returns `NULL`, and `errno` is set to `ENOENT` (No such file or directory). The program then prints the corresponding error message using `strerror(errno)`.

**Important Points:**

* Always include `<errno.h>` to use `errno` in your C programs.
* After an error-checking operation, check the value of `errno` to determine the cause of the error.
* `errno` is thread-local, meaning each thread has its own copy of `errno`.

Understanding and properly handling errors using `errno` is crucial for writing robust and reliable C programs. It provides valuable information for diagnosing and troubleshooting errors during program execution.

