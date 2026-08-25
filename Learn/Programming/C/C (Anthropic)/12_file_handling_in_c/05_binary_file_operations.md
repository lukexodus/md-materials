## Binary File Operations


Binary file operations handle raw byte data without character encoding or newline translation, enabling efficient storage of structured data, multimedia content, and serialized objects.

### Basic Binary I/O Functions

#### fread()

```c
size_t fread(void *ptr, size_t size, size_t count, FILE *stream);
```

Reads `count` items of `size` bytes each into the memory pointed to by `ptr`.

#### fwrite()

```c
size_t fwrite(const void *ptr, size_t size, size_t count, FILE *stream);
```

Writes `count` items of `size` bytes each from the memory pointed to by `ptr`.

**Example** of basic binary operations:

```c
#include <stdio.h>
#include <stdint.h>

void write_binary_data() {
    FILE *file = fopen("binary_data.bin", "wb");
    if (file == NULL) {
        perror("Error creating binary file");
        return;
    }
    
    // Write different data types
    uint32_t integer_value = 0x12345678;
    double double_value = 3.14159265359;
    char string_data[] = "Binary String";
    
    fwrite(&integer_value, sizeof(uint32_t), 1, file);
    fwrite(&double_value, sizeof(double), 1, file);
    fwrite(string_data, sizeof(char), sizeof(string_data), file);
    
    fclose(file);
    printf("Binary data written successfully\n");
}

void read_binary_data() {
    FILE *file = fopen("binary_data.bin", "rb");
    if (file == NULL) {
        perror("Error opening binary file");
        return;
    }
    
    uint32_t integer_value;
    double double_value;
    char string_data[20];
    
    if (fread(&integer_value, sizeof(uint32_t), 1, file) == 1 &&
        fread(&double_value, sizeof(double), 1, file) == 1 &&
        fread(string_data, sizeof(char), sizeof(string_data), file) > 0) {
        
        printf("Integer: 0x%08X (%u)\n", integer_value, integer_value);
        printf("Double: %.10f\n", double_value);
        printf("String: %s\n", string_data);
    }
    
    fclose(file);
}
```

### Structure Serialization

Binary files efficiently store structured data:

```c
#include <stdio.h>
#include <string.h>
#include <time.h>

typedef struct {
    uint32_t magic_number;    // File format identifier
    uint16_t version;         // Format version
    uint32_t record_count;    // Number of records
    time_t created_timestamp; // Creation time
} FileHeader;

typedef struct {
    uint32_t id;
    char name[64];
    float values[4];
    uint8_t flags;
} DataRecord;

#define MAGIC_NUMBER 0x44415441  // "DATA" in ASCII
#define FILE_VERSION 1

int write_structured_file(const char *filename, DataRecord *records, int count) {
    FILE *file = fopen(filename, "wb");
    if (file == NULL) return 0;
    
    // Write file header
    FileHeader header = {
        .magic_number = MAGIC_NUMBER,
        .version = FILE_VERSION,
        .record_count = count,
        .created_timestamp = time(NULL)
    };
    
    if (fwrite(&header, sizeof(FileHeader), 1, file) != 1) {
        fclose(file);
        return 0;
    }
    
    // Write data records
    size_t written = fwrite(records, sizeof(DataRecord), count, file);
    fclose(file);
    
    return written == (size_t)count;
}

int read_structured_file(const char *filename, DataRecord **records, int *count) {
    FILE *file = fopen(filename, "rb");
    if (file == NULL) return 0;
    
    FileHeader header;
    if (fread(&header, sizeof(FileHeader), 1, file) != 1) {
        fclose(file);
        return 0;
    }
    
    // Validate file format
    if (header.magic_number != MAGIC_NUMBER || header.version != FILE_VERSION) {
        fclose(file);
        return 0;
    }
    
    // Allocate memory for records
    *records = (DataRecord*)malloc(header.record_count * sizeof(DataRecord));
    if (*records == NULL) {
        fclose(file);
        return 0;
    }
    
    // Read data records
    size_t read_count = fread(*records, sizeof(DataRecord), header.record_count, file);
    fclose(file);
    
    if (read_count == header.record_count) {
        *count = header.record_count;
        return 1;
    } else {
        free(*records);
        *records = NULL;
        return 0;
    }
}
```

### Endianness Considerations

Binary files must handle byte order differences across platforms:

```c
#include <stdio.h>
#include <stdint.h>

// Check system endianness
int is_little_endian() {
    uint16_t test = 0x0001;
    return *(uint8_t*)&test == 1;
}

// Byte swapping functions
uint16_t swap16(uint16_t value) {
    return ((value & 0xFF) << 8) | ((value >> 8) & 0xFF);
}

uint32_t swap32(uint32_t value) {
    return ((value & 0xFF) << 24) |
           (((value >> 8) & 0xFF) << 16) |
           (((value >> 16) & 0xFF) << 8) |
           ((value >> 24) & 0xFF);
}

// Portable binary I/O with consistent byte order
void write_portable_uint32(FILE *file, uint32_t value) {
    // Always write in little-endian format
    if (!is_little_endian()) {
        value = swap32(value);
    }
    fwrite(&value, sizeof(uint32_t), 1, file);
}

uint32_t read_portable_uint32(FILE *file) {
    uint32_t value;
    fread(&value, sizeof(uint32_t), 1, file);
    
    // Convert from little-endian if necessary
    if (!is_little_endian()) {
        value = swap32(value);
    }
    
    return value;
}
```

### Memory-Mapped File Alternative

For large binary files, memory-mapped I/O provides efficient access [Unverified]:

```c
#include <stdio.h>
#include <stdlib.h>

// [Unverified] - Memory mapping implementation varies by platform
// This example shows conceptual usage
void process_large_binary_file(const char *filename) {
    FILE *file = fopen(filename, "rb");
    if (file == NULL) return;
    
    // Determine file size
    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    // For very large files, consider processing in chunks
    const size_t chunk_size = 1024 * 1024;  // 1MB chunks
    unsigned char *buffer = (unsigned char*)malloc(chunk_size);
    
    if (buffer != NULL) {
        size_t bytes_read;
        long total_processed = 0;
        
        while ((bytes_read = fread(buffer, 1, chunk_size, file)) > 0) {
            // Process chunk of data
            for (size_t i = 0; i < bytes_read; i++) {
                // Perform processing on buffer[i]
            }
            
            total_processed += bytes_read;
            printf("Processed: %ld/%ld bytes (%.1f%%)\n", 
                   total_processed, file_size, 
                   (100.0 * total_processed) / file_size);
        }
        
        free(buffer);
    }
    
    fclose(file);
}
```

