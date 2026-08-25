## File Modes


File modes specify the intended operations and behavior when opening files. The mode string determines access permissions, file positioning, and text versus binary handling.

### Basic Mode Specifiers

#### Read Modes

- `"r"` - Read only. File must exist. Position at beginning.
- `"r+"` - Read and write. File must exist. Position at beginning.

#### Write Modes

- `"w"` - Write only. Creates new file or truncates existing file to zero length.
- `"w+"` - Read and write. Creates new file or truncates existing file.

#### Append Modes

- `"a"` - Write only. Creates file if it doesn't exist. Writes occur at end of file.
- `"a+"` - Read and write. Creates file if it doesn't exist. Writes occur at end of file.

### Binary Mode Modifier

Adding `'b'` to any mode string enables binary mode, which prevents newline character translation on systems that perform such conversions:

```c
FILE *binary_file = fopen("data.bin", "rb");    // Binary read
FILE *text_file = fopen("document.txt", "rt");  // Text read (explicit)
```

**Example** demonstrating different file modes:

```c
#include <stdio.h>
#include <string.h>

void demonstrate_file_modes() {
    const char *filename = "test_modes.txt";
    const char *data1 = "Initial content\n";
    const char *data2 = "Appended content\n";
    char buffer[100];
    
    // Write mode - creates new file
    FILE *file = fopen(filename, "w");
    if (file) {
        fputs(data1, file);
        fclose(file);
        printf("Write mode: Created file with initial content\n");
    }
    
    // Append mode - adds to existing file
    file = fopen(filename, "a");
    if (file) {
        fputs(data2, file);
        fclose(file);
        printf("Append mode: Added content to end of file\n");
    }
    
    // Read mode - read existing file
    file = fopen(filename, "r");
    if (file) {
        printf("Read mode contents:\n");
        while (fgets(buffer, sizeof(buffer), file)) {
            printf("  %s", buffer);
        }
        fclose(file);
    }
    
    // Read-write mode with positioning
    file = fopen(filename, "r+");
    if (file) {
        fseek(file, 0, SEEK_END);  // Move to end
        fputs("Modified content\n", file);
        fclose(file);
        printf("Read-write mode: Modified file\n");
    }
}
```

### Platform-Specific Considerations

Text mode behavior varies across platforms. Windows systems translate `\n` to `\r\n` in text mode, while Unix-like systems do not perform such translations. Binary mode ensures consistent behavior across platforms:

```c
#include <stdio.h>

void write_binary_vs_text() {
    // Binary mode preserves exact byte sequences
    FILE *bin_file = fopen("data.bin", "wb");
    if (bin_file) {
        const char data[] = {0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x0A};  // "Hello\n"
        fwrite(data, 1, sizeof(data), bin_file);
        fclose(bin_file);
    }
    
    // Text mode may perform newline translation
    FILE *txt_file = fopen("data.txt", "w");
    if (txt_file) {
        fputs("Hello\n", txt_file);
        fclose(txt_file);
    }
}
```

