## `string`


### `strlen`

The `strlen` function is used to determine the length of a null-terminated string. It calculates the number of characters in the string excluding the null terminator (`'\0'`).

Here's the prototype of the `strlen` function:

```c
size_t strlen(const char *str);
```

* `str`: A pointer to a null-terminated string whose length is to be calculated.
    
* Return value: The number of characters in the string pointed to by `str`, excluding the null terminator.


Here's how you can use the `strlen` function:

```c
#include <stdio.h>
#include <string.h>

int main() {
    char str[] = "Hello, World!"; // Null-terminated string

    size_t length = strlen(str); // Calculate the length of the string
    printf("Length of the string: %zu\n", length);

    return 0;
}
```

Output:

```c
Length of the string: 13
```

In this example, the `strlen` function calculates the length of the string `"Hello, World!"`, which is 13 characters long (including spaces and punctuation marks) but excluding the null terminator `'\0'`.

It's important to ensure that the string passed to `strlen` is properly null-terminated, meaning it ends with a `'\0'` character. Otherwise, `strlen` may continue scanning memory beyond the intended string, resulting in undefined behavior.

### `strcpy`

The `strcpy` function is used to copy a string from one location to another. It copies the characters of the source string, including the null terminator (`'\0'`), to the destination string.

`strcpy(s,t)` copies the string t to the string s. It would be nice just to say `s=t` but this copies the pointer, not the characters. To copy the characters, we need a loop. The array version first:

```c
/* strcpy:  copy t to s; array subscript version */  
void strcpy(char *s, char *t)  
{  
   int i;  

   i = 0;  
   while ((s[i] = t[i]) != '\0')  
	   i++;  
}
```

For contrast, here is a version of strcpy with pointers:

```c
/* strcpy:  copy t to s; pointer version */  
void strcpy(char *s, char *t)  
{  
   int i;  

   i = 0;  
   while ((*s = *t) != '\0') {  
	   s++;  
	   t++;  
   }  
}
```

or

```c
/* strcpy:  copy t to s; pointer version 2 */  
void strcpy(char *s, char *t)  
{  
   while ((*s++ = *t++) != '\0')  
	   ;  
}
```

or

```c
/* strcpy:  copy t to s; pointer version 3 */  
void strcpy(char *s, char *t)  
{  
   while (*s++ = *t++)  
	   ;  
}
```

Here's the prototype of the `strcpy` function:

```c
char *strcpy(char *dest, const char *src);
```

* `dest`: A pointer to the destination string where the copied string will be placed.
    
* `src`: A pointer to the null-terminated source string to be copied.
    
* Return value: The pointer to the destination string (`dest`).

It's essential to ensure that the destination string (`dest`) has enough space to accommodate the source string (`src`) and the null terminator. Failure to allocate sufficient space may result in buffer overflows, which can lead to undefined behavior and security vulnerabilities.

Here's an example of how you can use the `strcpy` function:

```c
#include <stdio.h>
#include <string.h>

int main() {
    char src[] = "Hello, World!"; // Source string
    char dest[20]; // Destination string with enough space

    // Copy the source string to the destination string
    strcpy(dest, src);

    // Print the copied string
    printf("Copied string: %s\n", dest);

    return 0;
}
```

Output:

```c
Copied string: Hello, World!
```

In this example, the `strcpy` function is used to copy the contents of the source string `"Hello, World!"` to the destination string `dest`. The destination string must have enough space to hold the entire source string, including the null terminator. After the copy operation, the destination string contains the same content as the source string.

### `strncpy`

The `strncpy` function is used to copy a specified number of characters from the source string to the destination string. It allows you to control the number of characters to copy, which helps prevent buffer overflows and ensures that the destination string is properly null-terminated if the source string is shorter than the specified length.

Here's the prototype of the `strncpy` function:

```c
char *strncpy(char *dest, const char *src, size_t n);
```

* `dest`: A pointer to the destination string where the copied characters will be placed.
    
* `src`: A pointer to the source string to be copied.
    
* `n`: The maximum number of characters to copy from the source string, including the null terminator.
    
* Return value: The pointer to the destination string (`dest`).

The `strncpy` function ensures that the destination string is null-terminated, even if the source string is longer than the specified length `n`.

Here's an example of how you can use the `strncpy` function:

```c
#include <stdio.h>
#include <string.h>

int main() {
    char src[] = "Hello, World!"; // Source string
    char dest[20]; // Destination string

    // Copy at most 10 characters from the source string to the destination string
    strncpy(dest, src, 10);

    // Ensure the destination string is null-terminated
    dest[10] = '\0';

    // Print the copied string
    printf("Copied string: %s\n", dest);

    return 0;
}
```

Output:

```c
Copied string: Hello, Wor
```

In this example, the `strncpy` function copies at most 10 characters from the source string `"Hello, World!"` to the destination string `dest`. Since the specified length is 10, only the first 10 characters are copied. The destination string is then manually null-terminated to ensure that it ends with a null character.

### `strcat`

The `strcat` function is used to concatenate (append) one string to the end of another string. It appends the characters of the source string to the end of the destination string, overwriting the null terminator (`'\0'`) of the destination string, and then adds a new null terminator at the end of the concatenated string. The `strcat` function is declared in the `<string.h>` header file.

Here's the prototype of the `strcat` function:

```c
char *strcat(char *dest, const char *src);
```

* `dest`: A pointer to the destination string where the characters of the source string will be appended.
    
* `src`: A pointer to the null-terminated source string to be appended.
    
* Return value: The pointer to the destination string (`dest`).

It's important to ensure that the destination string (`dest`) has enough space to accommodate the concatenated string. Failure to allocate sufficient space may result in buffer overflows, which can lead to undefined behavior and security vulnerabilities.

Here's an example of how you can use the `strcat` function:

```c
#include <stdio.h>
#include <string.h>

int main() {
    char dest[20] = "Hello, "; // Destination string
    char src[] = "World!"; // Source string

    // Concatenate the source string to the destination string
    strcat(dest, src);

    // Print the concatenated string
    printf("Concatenated string: %s\n", dest);

    return 0;
}
```

Output:

```c
Concatenated string: Hello, World!
```

In this example, the `strcat` function appends the characters of the source string `"World!"` to the end of the destination string `dest`, resulting in the concatenated string `"Hello, World!"`. The destination string must have enough space to accommodate both the original content and the concatenated content, including the null terminator. After the concatenation, the destination string contains the concatenated content.

### `strncat`

The `strncat` function is similar to `strcat`, but it allows you to concatenate a specified number of characters from the source string to the end of the destination string. This helps prevent buffer overflows and gives you more control over the concatenation process. The `strncat` function is declared in the `<string.h>` header file.

Here's the prototype of the `strncat` function:

```c
char *strncat(char *dest, const char *src, size_t n);
```

* `dest`: A pointer to the destination string where the characters of the source string will be appended.
    
* `src`: A pointer to the source string to be appended.
    
* `n`: The maximum number of characters to append from the source string.
    
* Return value: The pointer to the destination string (`dest`).

The `strncat` function appends at most `n` characters from the source string to the end of the destination string, and then adds a null terminator at the end of the concatenated string. It ensures that the destination string remains null-terminated even if fewer characters are appended than the specified `n`.

Here's an example of how you can use the `strncat` function:

```c
#include <stdio.h>
#include <string.h>

int main() {
    char dest[20] = "Hello, "; // Destination string
    char src[] = "World!"; // Source string

    // Concatenate at most 3 characters from the source string to the destination string
    strncat(dest, src, 3);

    // Print the concatenated string
    printf("Concatenated string: %s\n", dest);

    return 0;
}
```

Output:

```c
Concatenated string: Hello, Wor
```

In this example, the `strncat` function appends at most 3 characters from the source string `"World!"` to the end of the destination string `dest`, resulting in the concatenated string `"Hello, Wor"`. The destination string must have enough space to accommodate both the original content and the concatenated content, including the null terminator. After the concatenation, the destination string contains the concatenated content.

### `strcmp`

The `strcmp` function is used to compare two strings lexicographically. It compares each corresponding character in the two strings and determines their relationship based on their ASCII values.

```c
/* strcmp:  return <0 if s<t, 0 if s==t, >0 if s>t */
int strcmp(char *s, char *t)
{
   int i;

   for (i = 0; s[i] == t[i]; i++)
	   if (s[i] == '\0')
		   return 0;
   return s[i] - t[i];
}
```

The pointer version of strcmp:

```c
/* strcmp:  return <0 if s<t, 0 if s==t, >0 if s>t */
int strcmp(char *s, char *t)
{
   for ( ; *s == *t; s++, t++)
	   if (*s == '\0')
		   return 0;
   return *s - *t;
}
```

Here's the prototype of the `strcmp` function:

```c
int strcmp(const char *str1, const char *str2);
```

* `str1`: A pointer to the first null-terminated string to be compared.
    
* `str2`: A pointer to the second null-terminated string to be compared.
    
* Return value:
    * Returns an integer less than, equal to, or greater than zero if `str1` is found, respectively, to be less than, to match, or be greater than `str2`.

The `strcmp` function compares the strings character by character until it finds a mismatch or encounters the null terminator (`'\0'`) of one or both strings. It returns an integer value indicating the relationship between the strings based on their lexicographical order.

Here's an example of how you can use the `strcmp` function:

```c
#include <stdio.h>
#include <string.h>

int main() {
    char str1[] = "apple";
    char str2[] = "banana";

    int result = strcmp(str1, str2);

    if (result < 0) {
        printf("'%s' is less than '%s'\n", str1, str2);
    } else if (result > 0) {
        printf("'%s' is greater than '%s'\n", str1, str2);
    } else {
        printf("'%s' is equal to '%s'\n", str1, str2);
    }

    return 0;
}
```

Output:

```csharp
'apple' is less than 'banana'
```

In this example, the `strcmp` function compares the strings `"apple"` and `"banana"`. Since `'a'` comes before `'b'` in lexicographical order, `"apple"` is considered less than `"banana"`, and thus the output indicates that `'apple' is less than 'banana'`.

### `strncmp`

The `strncmp` function is similar to `strcmp`, but it allows you to compare a specified number of characters from two strings. This enables you to control the comparison and prevent buffer overflows. The `strncmp` function is declared in the `<string.h>` header file.

Here's the prototype of the `strncmp` function:

```c
int strncmp(const char *str1, const char *str2, size_t n);
```

* `str1`: A pointer to the first null-terminated string to be compared.
    
* `str2`: A pointer to the second null-terminated string to be compared.
    
* `n`: The maximum number of characters to compare.
    
* Return value:
    * Returns an integer less than, equal to, or greater than zero if the first `n` characters of `str1` are found, respectively, to be less than, to match, or be greater than the first `n` characters of `str2`.

The `strncmp` function compares the first `n` characters of the two strings `str1` and `str2`. It stops the comparison either when a mismatch is found or when `n` characters have been compared, whichever comes first.

Here's an example of how you can use the `strncmp` function:

```c
#include <stdio.h>
#include <string.h>

int main() {
    char str1[] = "apple";
    char str2[] = "application";

    int result = strncmp(str1, str2, 3); // Compare the first 3 characters

    if (result < 0) {
        printf("'%s' is less than '%s'\n", str1, str2);
    } else if (result > 0) {
        printf("'%s' is greater than '%s'\n", str1, str2);
    } else {
        printf("'%s' is equal to '%s'\n", str1, str2);
    }

    return 0;
}
```

Output:

```csharp
'apple' is less than 'application'
```

In this example, the `strncmp` function compares the first 3 characters of the strings `"apple"` and `"application"`. Since `'a'` comes before `'p'` in lexicographical order, `"apple"` is considered less than `"application"`, and thus the output indicates that `'apple' is less than 'application'`.

### `strchr`

The `strchr` function is used to find the first occurrence of a specified character in a string. It searches for the character `c` in the null-terminated string `str`.

Here's the prototype of the `strchr` function:

```c
char *strchr(const char *str, int c);
```

* `str`: A pointer to the null-terminated string to be searched.
    
* `c`: The character to be located in the string.
    
* Return value:
    * Returns a pointer to the first occurrence of the character `c` in the string `str`, or a null pointer if the character is not found.

The `strchr` function searches for the character `c` in the string `str` until it encounters the null terminator (`'\0'`) or finds the character `c`. If the character `c` is found, `strchr` returns a pointer to the location of the character within the string. If the character `c` is not found, `strchr` returns a null pointer.

Here's an example of how you can use the `strchr` function:

```c
#include <stdio.h>
#include <string.h>

int main() {
    char str[] = "Hello, World!";
    char *ptr;

    // Find the first occurrence of 'o' in the string
    ptr = strchr(str, 'o');

    if (ptr != NULL) {
        printf("Found 'o' at position: %ld\n", ptr - str);
    } else {
        printf("Character 'o' not found\n");
    }

    return 0;
}
```

Output:

```arduino
Found 'o' at position: 4
```

In this example, the `strchr` function searches for the character `'o'` in the string `"Hello, World!"`. It finds the first occurrence of `'o'` at position 4 (indexing starts from 0), and it returns a pointer to the location of the character within the string. The difference between the pointer returned by `strchr` and the beginning of the string (`str`) gives the position of the character within the string.

### `strrchr`

The `strrchr` function is similar to `strchr`, but it searches for the last occurrence of a specified character in a string. It returns a pointer to the location of the last occurrence of the character `c` in the null-terminated string `str`.

Here's the prototype of the `strrchr` function:

```c
char *strrchr(const char *str, int c);
```

* `str`: A pointer to the null-terminated string to be searched.
    
* `c`: The character to be located in the string.
    
* Return value:
    
    * Returns a pointer to the last occurrence of the character `c` in the string `str`, or a null pointer if the character is not found.

The `strrchr` function searches for the character `c` in the string `str`, starting from the end of the string and moving towards the beginning, until it encounters the null terminator (`'\0'`) or finds the character `c`. If the character `c` is found, `strrchr` returns a pointer to the location of the character within the string. If the character `c` is not found, `strrchr` returns a null pointer.

Here's an example of how you can use the `strrchr` function:

```c
#include <stdio.h>
#include <string.h>

int main() {
    char str[] = "Hello, World!";
    char *ptr;

    // Find the last occurrence of 'o' in the string
    ptr = strrchr(str, 'o');

    if (ptr != NULL) {
        printf("Found 'o' at position: %ld\n", ptr - str);
    } else {
        printf("Character 'o' not found\n");
    }

    return 0;
}
```

Output:

```arduino
Found 'o' at position: 8
```

In this example, the `strrchr` function searches for the last occurrence of the character `'o'` in the string `"Hello, World!"`. It finds the last occurrence of `'o'` at position 8 (indexing starts from 0), and it returns a pointer to the location of the character within the string. The difference between the pointer returned by `strrchr` and the beginning of the string (`str`) gives the position of the character within the string.

### `strstr`

The `strstr` function is used to find the first occurrence of a substring within a string. It searches for the first occurrence of the null-terminated substring `needle` within the null-terminated string `haystack`.

Here's the prototype of the `strstr` function:

```c
char *strstr(const char *haystack, const char *needle);
```

* `haystack`: A pointer to the null-terminated string to be searched.
    
* `needle`: A pointer to the null-terminated substring to be located within the string.
    
* Return value:
    * Returns a pointer to the first occurrence of the substring `needle` in the string `haystack`, or a null pointer if the substring is not found.

The `strstr` function searches for the substring `needle` in the string `haystack` until it encounters the null terminator (`'\0'`) or finds the substring. If the substring `needle` is found, `strstr` returns a pointer to the location of the substring within the string. If the substring `needle` is not found, `strstr` returns a null pointer.

Here's an example of how you can use the `strstr` function:

```c
#include <stdio.h>
#include <string.h>

int main() {
    char haystack[] = "Hello, World!";
    char needle[] = "World";

    // Find the first occurrence of 'World' in the string
    char *ptr = strstr(haystack, needle);

    if (ptr != NULL) {
        printf("Found '%s' at position: %ld\n", needle, ptr - haystack);
    } else {
        printf("Substring '%s' not found\n", needle);
    }

    return 0;
}
```

Output:

```arduino
Found 'World' at position: 7
```

In this example, the `strstr` function searches for the first occurrence of the substring `"World"` in the string `"Hello, World!"`. It finds the substring `"World"` at position 7 (indexing starts from 0), and it returns a pointer to the location of the substring within the string. The difference between the pointer returned by `strstr` and the beginning of the string (`haystack`) gives the position of the substring within the string.

### `strtok`

The `strtok` function is used to tokenize (split) a string into a series of tokens based on a specified set of delimiters. It is commonly used to extract words or elements from a string.

Here's the prototype of the `strtok` function:

```c
char *strtok(char *str, const char *delimiters);
```

* `str`: A pointer to the null-terminated string to be tokenized. For subsequent calls to `strtok`, this argument should be set to `NULL`.
    
* `delimiters`: A null-terminated string containing a set of characters that act as delimiters.
    
* Return value:
    * Returns a pointer to the next token in the string, or a null pointer if no more tokens are found.

The `strtok` function maintains internal state between calls, allowing it to continue tokenizing the same string across multiple calls. It modifies the original string by replacing delimiters with null characters (`'\0'`). The first call to `strtok` receives the string to be tokenized, and subsequent calls receive `NULL` as the first argument.

Here's an example of how you can use the `strtok` function:

```c
#include <stdio.h>
#include <string.h>

int main() {
    char str[] = "Hello, World! This is a sample sentence.";
    const char delimiters[] = " ,.!";

    // Tokenize the string
    char *token = strtok(str, delimiters);

    while (token != NULL) {
        printf("Token: %s\n", token);
        token = strtok(NULL, delimiters);
    }

    return 0;
}
```

Output:

```vbnet
Token: Hello
Token: World
Token: This
Token: is
Token: a
Token: sample
Token: sentence
```

In this example, the `strtok` function tokenizes the string `"Hello, World! This is a sample sentence."` using delimiters such as space, comma, period, and exclamation mark. The resulting tokens are printed one by one in the loop.

It's important to note that `strtok` modifies the original string during the tokenization process. If you need to preserve the original string, you may want to create a copy before using `strtok`.

### `strdup`

The `strdup` function is used to create a duplicate (copy) of a string. It allocates memory for the new string and copies the contents of the original string into the newly allocated memory. The `strdup` function is not part of the standard C library, but it is commonly available on many systems and is declared in the `<string.h>` header file.

Here's a typical implementation of the `strdup` function:

```c
#include <stdlib.h>
#include <string.h>

char *strdup(const char *str) {
    size_t len = strlen(str) + 1; // Include space for the null terminator
    char *dup_str = malloc(len); // Allocate memory for the duplicate string

    if (dup_str != NULL) {
        strcpy(dup_str, str); // Copy the contents of the original string
    }

    return dup_str; // Return a pointer to the duplicate string
}
```

* `str`: A pointer to the null-terminated string to be duplicated.
    
* Return value:
    * Returns a pointer to the newly allocated memory containing the duplicated string, or a null pointer if memory allocation fails.

Here's an example of how you can use the `strdup` function:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    const char *original = "Hello, World!";
    char *duplicate = strdup(original);

    if (duplicate != NULL) {
        printf("Original string: %s\n", original);
        printf("Duplicate string: %s\n", duplicate);
        
        // Free the memory allocated by strdup
        free(duplicate);
    } else {
        printf("Memory allocation failed.\n");
    }

    return 0;
}
```

Output:

```c
Original string: Hello, World!
Duplicate string: Hello, World!
```

In this example, the `strdup` function creates a duplicate of the string `"Hello, World!"`. The duplicate string is then printed alongside the original string. Finally, the memory allocated for the duplicate string is freed using the `free` function to prevent memory leaks. It's important to check if `strdup` returns a null pointer, which indicates that memory allocation failed.

### `strerror`

The `strerror()` function is used to obtain a human-readable string representation of an error number.

**Function Signature:**

```c
char *strerror(int errnum);
```

* `errnum`: An integer representing the error number for which you want to obtain the error message.

**Return Value:**

* The function returns a pointer to a null-terminated string containing the error message corresponding to the specified error number.

**Example:**

```c
#include <stdio.h>
#include <string.h>

int main() {
    int errorNumber = 2; // Example error number
    printf("Error message: %s\n", strerror(errorNumber));
    return 0;
}
```

In this example, `strerror(errorNumber)` returns a pointer to a string containing the error message corresponding to the error number `2`. The message is then printed using `printf()`.

**Important Notes:**

* `strerror()` is especially useful when you want to obtain human-readable error messages corresponding to error codes, such as those provided by `errno`.
* It provides a convenient way to display meaningful error messages to users or developers when errors occur in C programs.
* The error messages returned by `strerror()` are typically system-dependent and may vary between different operating systems and environments.

Overall, `strerror()` is a valuable tool for error handling in C programming, allowing you to easily obtain descriptive error messages corresponding to error codes encountered during program execution.

### `strcspn`

`strcspn` is a function in C that returns the length of the initial segment of a string that does not contain any characters from a specified set of characters. It calculates the length of the substring until the first occurrence of any character from the specified set.

Here's the function signature:

```c
size_t strcspn(const char *str1, const char *str2);
```

* `str1`: A pointer to the null-terminated string to be searched.
* `str2`: A pointer to the null-terminated string containing the characters to search for.

The function returns the length of the initial segment of `str1` that consists of characters not found in `str2`.

Here's an example of how `strcspn` can be used:

```c
#include <stdio.h>
#include <stddef.h> // Include for size_t

int main() {
    const char str[] = "Hello, world!";
    const char charset[] = "aeiou"; // Set of characters to search for

    size_t len = strcspn(str, charset);
    printf("Length until first vowel: %zu\n", len); // Output: Length until first vowel: 1

    return 0;
}
```

In this example:

* The `str` array contains the string "Hello, world!".
* The `charset` array contains the characters "aeiou", representing vowels.
* The `strcspn` function is used to find the length of the initial segment of `str` that does not contain any vowels.
* The length is then printed to the console. In this case, the output will be `1`, indicating that the first vowel in the string is 'e' at index 1.

