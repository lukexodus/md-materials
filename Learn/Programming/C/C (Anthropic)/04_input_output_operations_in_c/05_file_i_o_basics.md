## File I/O Basics


File I/O operations extend the standard I/O model to work with external files, enabling persistent data storage and retrieval.

### File Opening and Closing

Files must be opened before use and closed after operations complete:

```c
FILE *fopen(const char *filename, const char *mode);
int fclose(FILE *stream);
```

File access modes determine permitted operations:

- `"r"` - read only (file must exist)
- `"w"` - write only (creates new or truncates existing)
- `"a"` - append (writes at end of file)
- `"r+"` - read and write (file must exist)
- `"w+"` - read and write (creates new or truncates existing)
- `"a+"` - read and append

Binary file modes append 'b' to mode string (`"rb"`, `"wb"`, etc.).

**Example** of file operations:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    FILE *file;
    char filename[] = "data.txt";
    
    // Writing to file
    file = fopen(filename, "w");
    if (file == NULL) {
        fprintf(stderr, "Error opening file for writing\n");
        return 1;
    }
    
    fprintf(file, "Line 1: Sample data\n");
    fprintf(file, "Line 2: More data\n");
    fclose(file);
    
    // Reading from file
    file = fopen(filename, "r");
    if (file == NULL) {
        fprintf(stderr, "Error opening file for reading\n");
        return 1;
    }
    
    char buffer[256];
    while (fgets(buffer, sizeof(buffer), file) != NULL) {
        printf("Read: %s", buffer);
    }
    fclose(file);
    
    return 0;
}
```

### File I/O Functions

Most standard I/O functions have file-based equivalents:

**Formatted I/O:**

- `fprintf(FILE *, format, ...)` - formatted output to file
- `fscanf(FILE *, format, ...)` - formatted input from file

**Character I/O:**

- `fgetc(FILE *)` - read character from file
- `fputc(int, FILE *)` - write character to file

**String I/O:**

- `fgets(char *, int, FILE *)` - read string from file
- `fputs(const char *, FILE *)` - write string to file

**Binary I/O:**

- `fread(void *, size_t, size_t, FILE *)` - read binary data
- `fwrite(const void *, size_t, size_t, FILE *)` - write binary data

### File Position and Error Handling

File streams maintain position indicators that can be manipulated:

```c
long ftell(FILE *stream);           // Get current position
int fseek(FILE *stream, long offset, int whence);  // Set position
void rewind(FILE *stream);          // Reset to beginning
```

Position reference points for `fseek()`:

- `SEEK_SET` - beginning of file
- `SEEK_CUR` - current position
- `SEEK_END` - end of file

Error detection functions help identify problems:

```c
int feof(FILE *stream);    // Test for end-of-file
int ferror(FILE *stream);  // Test for error condition
void clearerr(FILE *stream);  // Clear error indicators
```

**Example** of file position manipulation:

```c
FILE *file = fopen("data.bin", "r+b");
if (file != NULL) {
    // Move to position 100 from beginning
    fseek(file, 100, SEEK_SET);
    
    // Read data at that position
    int value;
    fread(&value, sizeof(int), 1, file);
    
    // Move back 4 bytes and write new value
    fseek(file, -4, SEEK_CUR);
    value = 42;
    fwrite(&value, sizeof(int), 1, file);
    
    fclose(file);
}
```

### Binary File Operations

Binary I/O operations handle non-text data efficiently:

```c
#include <stdio.h>

struct Record {
    int id;
    float value;
    char name[20];
};

int main() {
    struct Record records[] = {
        {1, 3.14f, "Pi"},
        {2, 2.71f, "E"},
        {3, 1.41f, "Root2"}
    };
    
    // Write binary data
    FILE *file = fopen("records.dat", "wb");
    if (file != NULL) {
        fwrite(records, sizeof(struct Record), 3, file);
        fclose(file);
    }
    
    // Read binary data
    file = fopen("records.dat", "rb");
    if (file != NULL) {
        struct Record read_record;
        while (fread(&read_record, sizeof(struct Record), 1, file) == 1) {
            printf("ID: %d, Value: %.2f, Name: %s\n", 
                   read_record.id, read_record.value, read_record.name);
        }
        fclose(file);
    }
    
    return 0;
}
```

**Key points** for file I/O:

- Always check return values for error conditions
- Close files promptly to free system resources
- Use binary mode for non-text data
- Handle file permissions and path issues gracefully
- Consider buffering implications for performance-critical applications

**Conclusion**

C's I/O system provides a comprehensive framework for data input and output operations. The layered approach from character-level operations to formatted I/O and file handling offers flexibility for different programming requirements. Understanding buffer management, error handling, and the distinctions between text and binary modes enables robust program development. [Inference] Mastery of these I/O operations forms the foundation for more advanced topics including network programming, database connectivity, and system-level file manipulation.

---

