## `ctype`


The functions `isalpha`, `isupper`, `islower`, `isdigit`, `isalnum`, and `isspace` are used to perform character classification. These functions take a character as input and return a non-zero value if the character satisfies the specified condition, otherwise they return 0. Here's a brief description of each function:

- `isalpha(int c)`: Returns non-zero if the character `c` is an alphabet letter (either uppercase or lowercase), otherwise returns 0.
    
- `isupper(int c)`: Returns non-zero if the character `c` is an uppercase letter, otherwise returns 0.
    
- `islower(int c)`: Returns non-zero if the character `c` is a lowercase letter, otherwise returns 0.
    
- `isdigit(int c)`: Returns non-zero if the character `c` is a digit (0 to 9), otherwise returns 0.
    
- `isalnum(int c)`: Returns non-zero if the character `c` is an alphanumeric character (either a letter or a digit), otherwise returns 0.
    
- `isspace(int c)`: Returns non-zero if the character `c` is a whitespace character (space, tab, newline, carriage return, form feed, vertical tab), otherwise returns 0.

These functions are commonly used in C programming to check the type of characters encountered in strings, input streams, or other character data. They are especially useful for tasks like input validation, parsing, and text processing.

- `tolower(int c)`: Converts the character `c` to lowercase if it is an uppercase letter. If `c` is not an uppercase letter, it returns `c` unchanged.
    
- `toupper(int c)`: Converts the character `c` to uppercase if it is a lowercase letter. If `c` is not a lowercase letter, it returns `c` unchanged.

These functions are commonly used in C programming to perform case-insensitive comparisons, normalize input strings, and manipulate character data.

### `isprint`

The `isprint` function is used to determine if a character is a printable character.

Here's how it works:

* **Function Signature**:
    ```c
    int isprint(int c);
    ```
    
* **Parameters**:
    * `c`: An integer representing the character to be checked.
* **Return Value**:
    * If the character `c` is a printable character, `isprint` returns a non-zero value (true).
    * If the character `c` is not a printable character, `isprint` returns 0 (false).
* **Character Range**:
    * The function checks whether the ASCII value of the character `c` is in the range of printable characters, which typically includes characters with ASCII values from 32 to 126 (inclusive), along with some additional printable characters depending on the system.
* **Example**:
    ```c
    #include <stdio.h>
    #include <ctype.h>
    
    int main() {
        char ch = 'A';
        if (isprint(ch)) {
            printf("%c is a printable character\n", ch);
        } else {
            printf("%c is not a printable character\n", ch);
        }
        return 0;
    }
    ```
    
    In this example, if the character `ch` is a printable character, the program prints a message indicating that it's a printable character; otherwise, it prints a message stating that it's not.

The `isprint` function is particularly useful when you need to validate or process characters that are suitable for display in text-based interfaces or when working with textual data.

