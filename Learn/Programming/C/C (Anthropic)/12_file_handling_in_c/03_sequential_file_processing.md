## Sequential File Processing


Sequential file processing involves reading or writing files from beginning to end in order. This approach suits applications that process entire files or handle data streams where random access is unnecessary.

### Forward Sequential Reading

**Example** of processing a log file sequentially:

```c
#include <stdio.h>
#include <string.h>
#include <time.h>

typedef struct {
    char timestamp[20];
    char level[10];
    char message[256];
} LogEntry;

int parse_log_entry(const char *line, LogEntry *entry) {
    return sscanf(line, "%19s %9s %255[^\n]", 
                  entry->timestamp, entry->level, entry->message) == 3;
}

void process_log_file(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("Error opening log file");
        return;
    }
    
    char line[512];
    LogEntry entry;
    int total_entries = 0;
    int error_count = 0;
    int warning_count = 0;
    
    printf("Processing log file: %s\n", filename);
    printf("----------------------------------------\n");
    
    while (fgets(line, sizeof(line), file) != NULL) {
        if (parse_log_entry(line, &entry)) {
            total_entries++;
            
            if (strcmp(entry.level, "ERROR") == 0) {
                error_count++;
                printf("ERROR: %s - %s\n", entry.timestamp, entry.message);
            } else if (strcmp(entry.level, "WARNING") == 0) {
                warning_count++;
            }
        }
    }
    
    fclose(file);
    
    printf("----------------------------------------\n");
    printf("Summary: %d total entries, %d errors, %d warnings\n", 
           total_entries, error_count, warning_count);
}
```

### Sequential File Copying

**Example** of copying files with buffer optimization:

```c
#include <stdio.h>
#include <time.h>

int copy_file_sequential(const char *source, const char *destination) {
    FILE *src = fopen(source, "rb");
    FILE *dst = fopen(destination, "wb");
    
    if (src == NULL || dst == NULL) {
        perror("Error opening files");
        if (src) fclose(src);
        if (dst) fclose(dst);
        return 0;
    }
    
    const size_t buffer_size = 8192;  // 8KB buffer for efficiency
    unsigned char buffer[buffer_size];
    size_t bytes_read, total_bytes = 0;
    clock_t start_time = clock();
    
    while ((bytes_read = fread(buffer, 1, buffer_size, src)) > 0) {
        if (fwrite(buffer, 1, bytes_read, src) != bytes_read) {
            perror("Error writing to destination file");
            fclose(src);
            fclose(dst);
            return 0;
        }
        total_bytes += bytes_read;
    }
    
    clock_t end_time = clock();
    double elapsed = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;
    
    fclose(src);
    fclose(dst);
    
    printf("Copied %zu bytes in %.3f seconds (%.2f KB/s)\n", 
           total_bytes, elapsed, (total_bytes / 1024.0) / elapsed);
    
    return 1;
}
```

### Stream Processing with Filters

Sequential processing enables efficient data transformation through streaming:

```c
#include <stdio.h>
#include <ctype.h>
#include <string.h>

void process_text_stream(FILE *input, FILE *output, 
                        void (*filter)(char *, char *)) {
    char input_line[1024];
    char output_line[1024];
    
    while (fgets(input_line, sizeof(input_line), input) != NULL) {
        filter(input_line, output_line);
        fputs(output_line, output);
    }
}

void uppercase_filter(char *input, char *output) {
    int i = 0;
    while (input[i] != '\0') {
        output[i] = toupper(input[i]);
        i++;
    }
    output[i] = '\0';
}

void word_count_filter(char *input, char *output) {
    int word_count = 0;
    int in_word = 0;
    
    for (int i = 0; input[i] != '\0'; i++) {
        if (isspace(input[i])) {
            in_word = 0;
        } else if (!in_word) {
            in_word = 1;
            word_count++;
        }
    }
    
    snprintf(output, 1024, "Words in line: %d\n", word_count);
}
```

