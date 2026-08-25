## `stdlib`


### `malloc`

The `malloc()` function in C is used to dynamically allocate memory during program execution. It stands for "memory allocation." `malloc()` allocates a block of memory of a specified size in bytes and returns a pointer to the beginning of that block.

Here's the prototype of the `malloc()` function:

```c
void *malloc(size_t size);
```

- **Return Type**: `void *`
    - `malloc` returns a pointer to memory of type `void *`. This indicates that `malloc` returns a generic pointer to memory, which can be used to point to any data type.
    - The use of `void *` allows `malloc` to allocate memory without assuming anything about the data type it will hold.
- **Parameters**:
    - `size`: This parameter specifies the size of the memory block to allocate in bytes. It is of type `size_t`, which is an unsigned integer type defined in `<stddef.h>`.

When using `malloc` to allocate memory, you typically cast the returned pointer to the appropriate type to match the data you intend to store in the allocated memory. Here's an example of how `malloc` is used:

The function returns a pointer to the allocated memory block if the allocation is successful. If the allocation fails (due to insufficient memory, for example), it returns `NULL`.

Example usage of `malloc()`:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *ptr;

    // Allocate memory for an array of 5 integers
    ptr = (int *)malloc(5 * sizeof(int));

    if (ptr != NULL) {
        // Memory allocation successful
        printf("Memory allocation successful.\n");

        // Use the allocated memory as needed
        for (int i = 0; i < 5; i++) {
            ptr[i] = i + 1;
            printf("ptr[%d] = %d\n", i, ptr[i]);
        }

        // Free the allocated memory when no longer needed
        free(ptr);
    } else {
        // Memory allocation failed
        printf("Memory allocation failed.\n");
    }

    return 0;
}
```

In this example, the program dynamically allocates memory for an array of 5 integers using `malloc()`. It then checks if the allocation was successful by testing if the returned pointer is not `NULL`. If the allocation was successful, it uses the allocated memory as needed. Finally, it frees the allocated memory using the `free()` function when it's no longer needed to prevent memory leaks.

### `calloc`

The `calloc()` function in C is used to dynamically allocate memory for an array of elements, initializing all the bytes in the allocated memory to zero. It stands for "contiguous allocation." `calloc()` takes two arguments: the number of elements to allocate and the size of each element in bytes.

Here's the prototype of the `calloc()` function:

```c
void *calloc(size_t num, size_t size);
```

* `num`: The number of elements to allocate.
* `size`: The size in bytes of each element.

The total amount of memory allocated is equal to `num * size`.

The function returns a pointer to the beginning of the allocated memory block if the allocation is successful. If the allocation fails (due to insufficient memory, for example), it returns `NULL`.

Example usage of `calloc()`:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *ptr;

    // Allocate memory for an array of 5 integers, initialized to zero
    ptr = (int *)calloc(5, sizeof(int));

    if (ptr != NULL) {
        // Memory allocation successful
        printf("Memory allocation successful.\n");

        // Use the allocated memory as needed
        for (int i = 0; i < 5; i++) {
            printf("ptr[%d] = %d\n", i, ptr[i]); // All elements are initialized to zero
        }

        // Free the allocated memory when no longer needed
        free(ptr);
    } else {
        // Memory allocation failed
        printf("Memory allocation failed.\n");
    }

    return 0;
}
```

In this example, the program dynamically allocates memory for an array of 5 integers using `calloc()`. All elements in the allocated memory block are initialized to zero. It then checks if the allocation was successful by testing if the returned pointer is not `NULL`. Finally, it frees the allocated memory using the `free()` function when it's no longer needed to prevent memory leaks.

### `realloc`

The `realloc()` function in C is used to dynamically resize or reallocate memory that was previously allocated using `malloc()`, `calloc()`, or `realloc()` itself. It allows you to adjust the size of the memory block, either by expanding it or shrinking it.

Here's the prototype of the `realloc()` function:

```c
void *realloc(void *ptr, size_t size);
```

* `ptr`: A pointer to the previously allocated memory block that you want to reallocate. If `ptr` is `NULL`, `realloc()` behaves like `malloc()` and allocates a new memory block of the specified size.
* `size`: The new size in bytes that you want the memory block to be resized to.

The function returns a pointer to the beginning of the reallocated memory block if the reallocation is successful. If the reallocation fails (due to insufficient memory, for example), it returns `NULL`. If `ptr` is `NULL`, `realloc()` behaves like `malloc()` and allocates a new memory block.

It's important to note the following points about `realloc()`:

* If the new size is larger than the original size of the memory block, `realloc()` may extend the existing memory block or allocate a new memory block at a different location and copy the contents of the original block to the new block.
* If the new size is smaller than the original size, `realloc()` may shrink the existing memory block, truncating its size. Data beyond the new size may be lost.
* If `realloc()` fails to allocate memory for the new block, the original block remains unchanged, and `realloc()` returns `NULL`. The original block is still valid and should not be accessed or modified.

Example usage of `realloc()`:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *ptr;

    // Allocate memory for an array of 5 integers
    ptr = (int *)malloc(5 * sizeof(int));

    if (ptr != NULL) {
        // Memory allocation successful
        printf("Memory allocation successful.\n");

        // Resize the memory block to hold 10 integers
        int *new_ptr = (int *)realloc(ptr, 10 * sizeof(int));

        if (new_ptr != NULL) {
            // Memory reallocation successful
            printf("Memory reallocation successful.\n");

            // Update pointer to point to the new memory block
            ptr = new_ptr;

            // Use the reallocated memory as needed
            // ...

            // Free the memory block when no longer needed
            free(ptr);
        } else {
            // Memory reallocation failed
            printf("Memory reallocation failed.\n");
            free(ptr); // Free the original memory block
        }
    } else {
        // Memory allocation failed
        printf("Memory allocation failed.\n");
    }

    return 0;
}
```

In this example, the program dynamically allocates memory for an array of 5 integers using `malloc()`. It then uses `realloc()` to resize the memory block to hold 10 integers. If the reallocation is successful, the program updates the pointer to point to the new memory block and performs further operations. Finally, it frees the memory block using `free()` when it's no longer needed to prevent memory leaks.

### `free`

The `free()` function in C is used to deallocate memory that was previously allocated dynamically using `malloc()`, `calloc()`, or `realloc()`. It releases the memory block back to the system, making it available for future allocations.

Here's the prototype of the `free()` function:

```c
void free(void *ptr);
```

* `ptr`: A pointer to the memory block that you want to deallocate. After calling `free()`, the pointer becomes invalid, and you should not attempt to access or modify the memory it previously pointed to.

It's important to note the following points about `free()`:

* The pointer `ptr` must point to a memory block that was previously allocated dynamically using `malloc()`, `calloc()`, or `realloc()`. Attempting to free memory that was not dynamically allocated or has already been freed results in undefined behavior.
* Once memory is freed, its contents are no longer guaranteed to be intact. Accessing or modifying the memory after it has been freed can lead to unpredictable behavior and program crashes.
* Using a pointer after freeing it is a common source of bugs in C programs, often referred to as "dangling pointers."

Example usage of `free()`:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *ptr;

    // Allocate memory for an array of 5 integers
    ptr = (int *)malloc(5 * sizeof(int));

    if (ptr != NULL) {
        // Memory allocation successful
        printf("Memory allocation successful.\n");

        // Use the allocated memory as needed
        // ...

        // Free the memory block when no longer needed
        free(ptr);
        printf("Memory deallocated.\n");
    } else {
        // Memory allocation failed
        printf("Memory allocation failed.\n");
    }

    return 0;
}
```

In this example, the program dynamically allocates memory for an array of 5 integers using `malloc()`. After using the allocated memory, it deallocates the memory block using `free()`. Once memory is deallocated, it should not be accessed or modified to avoid undefined behavior.

### `exit`

The `exit()` function in C is used to terminate the program immediately and return control to the operating system. It allows you to gracefully exit from your program and optionally return an exit status to the calling environment.

Here's the prototype of the `exit()` function:

```c
void exit(int status);
```

* `status`: An integer value representing the exit status of the program. A status of 0 typically indicates successful termination, while non-zero values often indicate errors or abnormal terminations.

The `exit()` function performs the following actions:

1. It flushes any buffered output streams, ensuring that all pending data is written to the output devices.
2. It closes any open streams (files) using `fclose()`.
3. It terminates the program and returns control to the operating system, passing the specified exit status.

The exit status can be retrieved by the parent process that called the terminated program. This status can be useful for determining the success or failure of the program's execution when invoked from a script or another program.

Example usage of `exit()`:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int result = 100;

    if (result == 100) {
        // Terminate the program with a successful exit status
        exit(EXIT_SUCCESS); // Alternatively, exit(0);
    } else {
        // Terminate the program with a failure exit status
        exit(EXIT_FAILURE); // Alternatively, exit(1);
    }

    // The code beyond this point will not be executed
    printf("This line will not be reached.\n");

    return 0;
}
```

In this example, depending on the value of `result`, the program terminates using `exit()` with either a successful exit status (`EXIT_SUCCESS`) or a failure exit status (`EXIT_FAILURE`). After calling `exit()`, the program immediately exits, and any code following the `exit()` call is not executed.

### `abort`

The `abort()` function in C is used to terminate the program abruptly by generating a SIGABRT signal. It is typically used to indicate critical errors or unexpected conditions that require the immediate termination of the program.

Here's the prototype of the `abort()` function:

```c
void abort(void);
```

The `abort()` function does not accept any arguments. When called, it performs the following actions:

1. It flushes any buffered output streams, ensuring that all pending data is written to the output devices.
2. It closes any open streams (files) using `fclose()`.
3. It generates a SIGABRT signal, which typically causes the program to terminate and may result in the creation of a core dump file for debugging purposes.

The `abort()` function is usually called when the program encounters unrecoverable errors or conditions that violate its assumptions about the environment. It provides a mechanism to gracefully terminate the program in such situations, allowing for diagnostic information to be collected and analyzed.

Example usage of `abort()`:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int result = 100;

    if (result != 100) {
        // Terminate the program abruptly
        abort();
    } else {
        printf("Program execution continues...\n");
    }

    return 0;
}
```

In this example, if the value of `result` is not equal to 100, the program calls `abort()`, which terminates the program abruptly. Otherwise, if the condition is not met, the program continues execution after the `abort()` call. It's important to use `abort()` judiciously and only in situations where the program cannot recover from the encountered error or condition.

### `atexit`

The `atexit()` function in C is used to register a function to be called automatically when the program terminates normally, either by reaching the end of the `main()` function or by calling the `exit()` function.

Here's a basic overview of how `atexit()` works:

* Prototype: `int atexit(void (*func)(void));`
* Parameter:
    * `func`: A pointer to the function to be registered. This function should not take any arguments and should not return any value.
* Returns:
    * `0` on success.
    * `non-zero` value if the function cannot be registered.

The functions registered with `atexit()` are called in the reverse order of their registration when the program exits. This means that the last function registered with `atexit()` is called first, followed by the second-to-last, and so on.

Here's a simple example demonstrating the usage of `atexit()`:

```c
#include <stdio.h>
#include <stdlib.h>

// Function to be called at program termination
void cleanup() {
    printf("Cleanup function called at program termination\n");
}

int main() {
    // Register the cleanup function
    if (atexit(cleanup) != 0) {
        perror("atexit() failed");
        return 1;
    }

    printf("Main function executing...\n");

    // Simulate program termination
    exit(0);
}
```

In this example, the `cleanup()` function is registered with `atexit()` to perform cleanup tasks when the program terminates. After registering the function, the `main()` function continues executing, and finally, the program exits using the `exit()` function. When the program terminates, the registered cleanup function `cleanup()` is automatically called.

`atexit()` is commonly used to perform cleanup tasks such as closing files, releasing memory, or performing other resource cleanup operations before the program exits.

### `system`

In C, the `system()` function is used to execute a command specified by a string. This function allows you to run shell commands or execute external programs from within your C program. It passes the command string to the command processor (shell) and waits for it to complete before returning control to the calling program.

Here's the syntax of the `system()` function:

```c
int system(const char *command);
```

* `command`: A null-terminated string containing the command to be executed.

The function returns an implementation-defined value, typically an integer status code returned by the command processor. A return value of `-1` typically indicates that the command processor couldn't be executed.

Here's a simple example demonstrating the usage of the `system()` function:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int status;

    // Execute the 'ls' command to list directory contents
    status = system("ls -l");

    if (status == -1) {
        printf("Error executing command\n");
        return 1;
    }

    printf("Command executed with status: %d\n", status);

    return 0;
}
```

In this example, the program calls the `system()` function with the command string `"ls -l"`, which lists the contents of the current directory in long format. The return value of `system()` is stored in the `status` variable and printed to the standard output.

It's important to note that the `system()` function may not be available or may behave differently across different operating systems and environments. Additionally, using the `system()` function with user-provided input may pose security risks due to command injection vulnerabilities, so it should be used with caution, especially when dealing with untrusted input.

### `atoi`, `atol`, `atoll`

The functions `atoi()`, `atol()`, and `atoll()` are used for converting strings to integers of different sizes. Here's a brief explanation of each:

1. **`atoi()`**:
    
    * Prototype: `int atoi(const char *str);`
    * Converts a string `str` to an integer (`int`).
    * It stops conversion at the first non-digit character encountered in the string.
    * If the string does not represent a valid integer, it returns 0.
    
    ```c
    int num = atoi("12345"); // num will be 12345
    ```
    
2. **`atol()`**:
    
    * Prototype: `long int atol(const char *str);`
    * Converts a string `str` to a long integer (`long int`).
    * Similar to `atoi()`, it stops conversion at the first non-digit character encountered in the string.
    * Returns 0 if the string does not represent a valid long integer.
    
    ```c
    long int num = atol("1234567890"); // num will be 1234567890
    ```
    
3. **`atoll()`**:
    
    * Prototype: `long long int atoll(const char *str);`
    * Converts a string `str` to a long long integer (`long long int`).
    * Like `atoi()` and `atol()`, it stops conversion at the first non-digit character.
    * Returns 0 if the string does not represent a valid long long integer.
    
    ```c
    long long int num = atoll("123456789012345"); // num will be 123456789012345
    ```
    

These functions are commonly used for string-to-integer conversions in C programming. It's important to note that they don't provide error checking for overflow or underflow, so you need to ensure that the input string represents a valid integer within the range of the target data type. Additionally, for better error handling, you might consider using `strtol()` or `strtoll()`, which provide more information about the conversion process.

### `strtol`, `strtoul`, `strtoll`, `strtoull`

The functions `strtol`, `strtoul`, `strtoll`, and `strtoull` are used for converting strings to long integers, unsigned long integers, long long integers, and unsigned long long integers, respectively. They provide more flexibility and error handling compared to the `atoi`, `atol`, and `atoll` functions. Here's a brief overview of each:

1. **`strtol`**:
    * Prototype: `long int strtol(const char *str, char **endptr, int base);`
    * Converts the initial portion of the string `str` to a `long int`.
    * Allows specification of the base for the conversion (e.g., 10 for decimal, 16 for hexadecimal).
    * Sets `endptr` to point to the first character after the converted number.
    * Returns the converted value as a `long int`.
    * If no conversion is performed, returns 0.
2. **`strtoul`**:
    * Prototype: `unsigned long int strtoul(const char *str, char **endptr, int base);`
    * Similar to `strtol` but returns an `unsigned long int`.
    * If no conversion is performed, returns 0.
3. **`strtoll`**:
    * Prototype: `long long int strtoll(const char *str, char **endptr, int base);`
    * Converts the initial portion of the string `str` to a `long long int`.
    * Allows specification of the base for the conversion.
    * Returns the converted value as a `long long int`.
    * If no conversion is performed, returns 0.
4. **`strtoull`**:
    * Prototype: `unsigned long long int strtoull(const char *str, char **endptr, int base);`
    * Similar to `strtoll` but returns an `unsigned long long int`.
    * If no conversion is performed, returns 0.

Here's a basic example demonstrating the usage of `strtol`:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    char str[] = "12345";
    char *endptr;
    long int num = strtol(str, &endptr, 10);

    if (str == endptr) {
        printf("No digits were found\n");
    } else {
        printf("Converted number: %ld\n", num);
        printf("Remaining string: %s\n", endptr);
    }

    return 0;
}
```

In this example, `strtol` converts the string "12345" to a `long int`, and `endptr` points to the first character after the converted number. If no conversion is performed, `str` will be equal to `endptr`.

### `rand`

The `rand()` function in C is used to generate pseudo-random integer numbers. It is part of the standard C library `stdlib.h`. However, it's important to note that `rand()` is not suitable for cryptography or security-related purposes due to its predictability.

Here's a basic overview of how `rand()` works:

* Prototype: `int rand(void);`
* Returns: A pseudo-random integer in the range of 0 to `RAND_MAX`.
* `RAND_MAX`: A constant defined in `stdlib.h` that represents the maximum value returned by `rand()`. The actual value of `RAND_MAX` can vary among different implementations, but it is guaranteed to be at least 32767.

To use `rand()`, you typically need to seed the random number generator using the `srand()` function. Seeding initializes the internal state of the random number generator, which ensures that subsequent calls to `rand()` produce different sequences of pseudo-random numbers.

Here's a simple example demonstrating the usage of `rand()` and `srand()`:

```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main() {
    int i;

    // Seed the random number generator with the current time
    srand(time(NULL));

    // Generate and print 5 random numbers
    printf("Random numbers:\n");
    for (i = 0; i < 5; i++) {
        printf("%d\n", rand());
    }

    return 0;
}
```

In this example, `srand(time(NULL))` seeds the random number generator with the current time, ensuring that each time the program runs, it starts with a different seed. As a result, the sequence of random numbers generated by `rand()` will be different each time the program is executed.

Keep in mind that the sequence of numbers generated by `rand()` is deterministic and will repeat if the same seed is used. Also, the quality of the pseudo-random numbers generated by `rand()` may not be sufficient for some applications, so consider using more advanced random number generation libraries if you require higher quality random numbers.

### `srand`

The `srand()` function in C is used to seed the random number generator (`rand()`) with a starting value. By providing a seed, you can initialize the state of the random number generator, which ensures that subsequent calls to `rand()` produce different sequences of pseudo-random numbers.

Here's a basic overview of how `srand()` works:

* Prototype: `void srand(unsigned int seed);`
* Parameters:
    * `seed`: An unsigned integer value used as the seed for the random number generator.
* Returns: None.

It's important to note that seeding the random number generator with the same seed value will produce the same sequence of pseudo-random numbers. Therefore, it's common to use a different seed value, such as the current time, to generate a different sequence each time the program runs.

Here's a simple example demonstrating the usage of `srand()`:

```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main() {
    int i;

    // Seed the random number generator with the current time
    srand(time(NULL));

    // Generate and print 5 random numbers
    printf("Random numbers:\n");
    for (i = 0; i < 5; i++) {
        printf("%d\n", rand());
    }

    return 0;
}
```

In this example, `srand(time(NULL))` seeds the random number generator with the current time. As a result, each time the program is executed, it starts with a different seed, producing a different sequence of random numbers from `rand()`. This helps ensure that the random numbers generated by the program are not predictable.

### `getenv`

The `getenv()` function in C is used to retrieve the value of an environment variable. Environment variables are global variables that are available to all processes running on the system and are commonly used to store configuration information and system settings.

Here's a basic overview of how `getenv()` works:

* Prototype: `char *getenv(const char *name);`
* Parameters:
    * `name`: A null-terminated string containing the name of the environment variable to retrieve.
* Returns:
    * If the environment variable is found, a pointer to a null-terminated string containing its value is returned.
    * If the environment variable is not found, `NULL` is returned.

Here's a simple example demonstrating the usage of `getenv()`:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    // Retrieve the value of the "PATH" environment variable
    char *path = getenv("PATH");

    if (path != NULL) {
        printf("Value of PATH: %s\n", path);
    } else {
        printf("PATH environment variable not found\n");
    }

    return 0;
}
```

In this example, `getenv("PATH")` is used to retrieve the value of the "PATH" environment variable, which typically contains a list of directories where executable files are located. If the variable is found, its value is printed to the standard output. Otherwise, a message indicating that the variable was not found is displayed.

It's important to note that environment variables are set outside of the program's code and are specific to the environment in which the program is executed. Therefore, the behavior of `getenv()` may vary depending on the system and the configuration of the environment variables.

### `putenv`

The `putenv()` function in C is used to set or update the value of an environment variable. It allows you to modify or add environment variables within the current process.

Here's a basic overview of how `putenv()` works:

* Prototype: `int putenv(char *string);`
* Parameter:
    * `string`: A pointer to a string in the format "name=value" representing the environment variable to be set or updated.
* Returns:
    * `0` on success.
    * `-1` if an error occurs.

If an environment variable with the same name already exists, `putenv()` updates its value. If it doesn't exist, `putenv()` creates a new environment variable.

Here's a simple example demonstrating the usage of `putenv()`:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    // Set the value of the "MY_VAR" environment variable
    char *var = "MY_VAR=hello";
    if (putenv(var) != 0) {
        perror("putenv() failed");
        return 1;
    }

    // Retrieve the value of the "MY_VAR" environment variable
    char *value = getenv("MY_VAR");
    if (value != NULL) {
        printf("Value of MY_VAR: %s\n", value);
    } else {
        printf("MY_VAR environment variable not found\n");
    }

    return 0;
}
```

In this example, `putenv()` is used to set the value of the "MY_VAR" environment variable to "hello". It then retrieves the value of "MY_VAR" using `getenv()` and prints it to the standard output.

It's important to note that `putenv()` may have different behavior across different platforms, and modifying the environment may have implications for other processes or the behavior of system utilities. Therefore, it should be used with caution. Additionally, some implementations provide safer alternatives such as `setenv()` and `unsetenv()`, which may be preferred in certain situations.

### `qsort`

The `qsort()` function in C is used for sorting arrays or other data structures using a user-defined comparison function. It is part of the standard C library `<stdlib.h>`.

Here's a basic overview of how `qsort()` works:

* Prototype: `void qsort(void *base, size_t nmemb, size_t size, int (*compar)(const void *, const void *));`
* Parameters:
    * `base`: Pointer to the array to be sorted.
    * `nmemb`: Number of elements in the array.
    * `size`: Size of each element in the array, in bytes.
    * `compar`: Pointer to the comparison function that determines the order of elements. This function should return an integer less than, equal to, or greater than zero if the first argument is considered to be respectively less than, equal to, or greater than the second.
* Returns: None.

The comparison function `compar` takes two `const void *` parameters, which point to the elements being compared. The function should return a negative value if the first element should precede the second, zero if they are equal, and a positive value if the first element should follow the second.

Here's a simple example demonstrating the usage of `qsort()` to sort an array of integers in ascending order:

```c
#include <stdio.h>
#include <stdlib.h>

// Comparison function for integers (ascending order)
int compare(const void *a, const void *b) {
    return (*(int *)a - *(int *)b);
}

int main() {
    int arr[] = {5, 2, 9, 1, 7};
    int n = sizeof(arr) / sizeof(arr[0]);

    // Sort the array using qsort
    qsort(arr, n, sizeof(int), compare);

    // Print the sorted array
    printf("Sorted array: ");
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");

    return 0;
}
```

In this example, the `compare()` function is defined to compare two integers. It subtracts the second integer from the first and returns the result, which determines the order of the elements. The array `arr` is then sorted using `qsort()` with `compare()` as the comparison function.

**Sample Implementation:**

```c
/* qsort:  sort v[left]...v[right] into increasing order */

void qsort(char *v[], int left, int right)  
{  
   int i, last;  
   void swap(char *v[], int i, int j);  

   if (left >= right)  /* do nothing if array contains */  
	   return;         /* fewer than two elements */  
   swap(v, left, (left + right)/2);  
   last = left;  
   for (i = left+1; i <= right; i++)  
	   if (strcmp(v[i], v[left]) < 0)  
		   swap(v, ++last, i);  
   swap(v, left, last);  
   qsort(v, left, last-1);  
   qsort(v, last+1, right);  
}

/* swap:  interchange v[i] and v[j] */  
void swap(char *v[], int i, int j)  
{  
   char *temp;  

   temp = v[i];  
   v[i] = v[j];  
   v[j] = temp;  
}
```

`qsort()` is a powerful and efficient sorting algorithm commonly used in C programming for sorting arrays and other data structures.

### `bsearch`

The `bsearch()` function in C is used to search for a key in a sorted array using a binary search algorithm. It is part of the standard C library `<stdlib.h>`.

Here's a basic overview of how `bsearch()` works:

* Prototype: `void *bsearch(const void *key, const void *base, size_t nmemb, size_t size, int (*compar)(const void *, const void *));`
* Parameters:
    * `key`: Pointer to the key to be searched for.
    * `base`: Pointer to the sorted array to be searched.
    * `nmemb`: Number of elements in the array.
    * `size`: Size of each element in the array, in bytes.
    * `compar`: Pointer to the comparison function that determines the order of elements. This function should return an integer less than, equal to, or greater than zero if the first argument is considered to be respectively less than, equal to, or greater than the second.
* Returns:
    * A pointer to the matching element if found, or `NULL` if the key is not found.

The comparison function `compar` is similar to the one used in `qsort()`. It takes two `const void *` parameters, which point to the elements being compared.

Here's a simple example demonstrating the usage of `bsearch()` to search for a key in a sorted array of integers:

```c
#include <stdio.h>
#include <stdlib.h>

// Comparison function for integers
int compare(const void *a, const void *b) {
    return (*(int *)a - *(int *)b);
}

int main() {
    int arr[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int key = 6;
    int n = sizeof(arr) / sizeof(arr[0]);

    // Search for the key in the sorted array
    int *result = (int *)bsearch(&key, arr, n, sizeof(int), compare);

    if (result != NULL) {
        printf("Key found: %d\n", *result);
    } else {
        printf("Key not found\n");
    }

    return 0;
}
```

In this example, the `compare()` function is defined to compare two integers. The `bsearch()` function is then used to search for the key `6` in the sorted array `arr`. If the key is found, a pointer to the matching element is returned, otherwise, `NULL` is returned.

