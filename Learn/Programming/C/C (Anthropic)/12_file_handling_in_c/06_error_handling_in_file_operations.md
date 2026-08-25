## Error Handling in File Operations


Robust file operations require comprehensive error detection and handling to manage various failure conditions including permission issues, disk space limitations, and hardware failures.

### Error Detection Functions

#### Standard Error Indicators

```c
int feof(FILE *stream);      // Test for end-of-file
int ferror(FILE *stream);    // Test for error condition
void clearerr(FILE *stream); // Clear error indicators
```

#### System Error Reporting

```c
#include <errno.h>
#include <string.h>

void perror(const char *message);           // Print system error message
char *strerror(int errno);                  // Get error description string
```

**Example** of comprehensive error checking:

```c
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

typedef enum {
    FILE_OP_SUCCESS,
    FILE_OP_OPEN_ERROR,
    FILE_OP_READ_ERROR,
    FILE_OP_WRITE_ERROR,
    FILE_OP_SEEK_ERROR,
    FILE_OP_MEMORY_ERROR
} FileOpResult;

const char* file_op_error_message(FileOpResult result) {
    switch (result) {
        case FILE_OP_SUCCESS: return "Operation successful";
        case FILE_OP_OPEN_ERROR: return "Failed to open file";
        case FILE_OP_READ_ERROR: return "Failed to read from file";
        case FILE_OP_WRITE_ERROR: return "Failed to write to file";
        case FILE_OP_SEEK_ERROR: return "Failed to seek in file";
        case FILE_OP_MEMORY_ERROR: return "Memory allocation failed";
        default: return "Unknown error";
    }
}

FileOpResult safe_file_copy(const char *source, const char *dest) {
    FILE *src = NULL, *dst = NULL;
    unsigned char *buffer = NULL;
    FileOpResult result = FILE_OP_SUCCESS;
    
    // Open source file
    src = fopen(source, "rb");
    if (src == NULL) {
        fprintf(stderr, "Error opening source file '%s': %s\n",
                source, strerror(errno));
        return FILE_OP_OPEN_ERROR;
    }
    
    // Open destination file
    dst = fopen(dest, "wb");
    if (dst == NULL) {
        fprintf(stderr, "Error opening destination file '%s': %s\n",
                dest, strerror(errno));
        fclose(src);
        return FILE_OP_OPEN_ERROR;
    }
    
    // Allocate buffer
    const size_t buffer_size = 8192;
    buffer = (unsigned char*)malloc(buffer_size);
    if (buffer == NULL) {
        fprintf(stderr, "Memory allocation failed: %s\n", strerror(errno));
        result = FILE_OP_MEMORY_ERROR;
        goto cleanup;
    }
    
    // Copy data with error checking
    size_t bytes_read, bytes_written;
    while ((bytes_read = fread(buffer, 1, buffer_size, src)) > 0) {
        if (ferror(src)) {
            fprintf(stderr, "Error reading from source file: %s\n", 
                    strerror(errno));
            result = FILE_OP_READ_ERROR;
            goto cleanup;
        }
        
        bytes_written = fwrite(buffer, 1, bytes_read, dst);
        if (bytes_written != bytes_read) {
            fprintf(stderr, "Error writing to destination file: %s\n", 
                    strerror(errno));
            result = FILE_OP_WRITE_ERROR;
            goto cleanup;
        }
        
        if (ferror(dst)) {
            fprintf(stderr, "Write error detected: %s\n", strerror(errno));
            result = FILE_OP_WRITE_ERROR;
            goto cleanup;
        }
    }
    
    // Check for read errors after loop
    if (ferror(src)) {
        fprintf(stderr, "Final read error: %s\n", strerror(errno));
        result = FILE_OP_READ_ERROR;
    }
    
cleanup:
    if (buffer) free(buffer);
    if (src) {
        if (fclose(src) != 0 && result == FILE_OP_SUCCESS) {
            fprintf(stderr, "Error closing source file: %s\n", strerror(errno));
        }
    }
    if (dst) {
        if (fclose(dst) != 0 && result == FILE_OP_SUCCESS) {
            fprintf(stderr, "Error closing destination file: %s\n", strerror(errno));
        }
    }
    
    return result;
}
```

### Recovery and Retry Mechanisms

**Example** implementing retry logic for transient failures:
```c
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>    // For sleep() on Unix-like systems
#include <time.h>

int retry_file_operation(int (*operation)(const char*), const char *filename, 
                        int max_attempts, int delay_seconds) {
    int attempt = 0;
    int result;
    
    while (attempt < max_attempts) {
        result = operation(filename);
        if (result == 0) {
            return 0;  // Success
        }
        
        attempt++;
        
        // Check if error is worth retrying
        if (errno == ENOENT || errno == EACCES || errno == EPERM) {
            // File not found or permission errors - don't retry
            break;
        }
        
        if (attempt < max_attempts) {
            fprintf(stderr, "Attempt %d failed: %s. Retrying in %d seconds...\n",
                    attempt, strerror(errno), delay_seconds);
            sleep(delay_seconds);
        }
    }
    
    fprintf(stderr, "Operation failed after %d attempts: %s\n",
            attempt, strerror(errno));
    return -1;
}

int test_file_access(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        return -1;
    }
    fclose(file);
    return 0;
}

// Usage example
void demonstrate_retry_mechanism() {
    const char *filename = "test_file.txt";
    int result = retry_file_operation(test_file_access, filename, 3, 2);
    
    if (result == 0) {
        printf("File access successful\n");
    } else {
        printf("File access failed after retries\n");
    }
}
```

### Transactional File Operations

**Example** implementing atomic file updates:
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

int atomic_file_update(const char *filename, 
                      int (*write_function)(FILE*, void*), 
                      void *data) {
    char temp_filename[256];
    char backup_filename[256];
    
    // Create temporary and backup filenames
    snprintf(temp_filename, sizeof(temp_filename), "%s.tmp", filename);
    snprintf(backup_filename, sizeof(backup_filename), "%s.bak", filename);
    
    // Step 1: Write to temporary file
    FILE *temp_file = fopen(temp_filename, "wb");
    if (temp_file == NULL) {
        fprintf(stderr, "Cannot create temporary file: %s\n", strerror(errno));
        return 0;
    }
    
    if (write_function(temp_file, data) != 0) {
        fprintf(stderr, "Write operation failed\n");
        fclose(temp_file);
        remove(temp_filename);
        return 0;
    }
    
    if (fclose(temp_file) != 0) {
        fprintf(stderr, "Cannot close temporary file: %s\n", strerror(errno));
        remove(temp_filename);
        return 0;
    }
    
    // Step 2: Create backup of original file (if it exists)
    if (rename(filename, backup_filename) != 0 && errno != ENOENT) {
        fprintf(stderr, "Cannot create backup: %s\n", strerror(errno));
        remove(temp_filename);
        return 0;
    }
    
    // Step 3: Move temporary file to final location
    if (rename(temp_filename, filename) != 0) {
        fprintf(stderr, "Cannot move temporary file: %s\n", strerror(errno));
        // Attempt to restore backup
        rename(backup_filename, filename);
        remove(temp_filename);
        return 0;
    }
    
    // Step 4: Remove backup file (optional)
    remove(backup_filename);
    return 1;
}

// Example write function
int write_config_data(FILE *file, void *data) {
    const char *config_text = (const char*)data;
    if (fputs(config_text, file) == EOF) {
        return -1;
    }
    return 0;
}

void demonstrate_atomic_update() {
    const char *config_data = "# Configuration File\n"
                             "setting1=value1\n"
                             "setting2=value2\n";
    
    if (atomic_file_update("config.txt", write_config_data, (void*)config_data)) {
        printf("Configuration updated successfully\n");
    } else {
        printf("Configuration update failed\n");
    }
}
```

### File Locking and Concurrent Access

**Example** implementing file locking for concurrent access control [Unverified]:
```c
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

// [Unverified] - File locking implementation varies significantly between platforms
// This example shows conceptual approach

typedef struct {
    FILE *file;
    char *filename;
    int locked;
} LockedFile;

LockedFile* open_locked_file(const char *filename, const char *mode) {
    LockedFile *lf = (LockedFile*)malloc(sizeof(LockedFile));
    if (lf == NULL) return NULL;
    
    lf->filename = (char*)malloc(strlen(filename) + 1);
    if (lf->filename == NULL) {
        free(lf);
        return NULL;
    }
    strcpy(lf->filename, filename);
    
    lf->file = fopen(filename, mode);
    if (lf->file == NULL) {
        free(lf->filename);
        free(lf);
        return NULL;
    }
    
    // Platform-specific file locking would be implemented here
    // Example: flock() on Unix, LockFile() on Windows
    lf->locked = 1;  // [Inference] Assume lock successful for example
    
    return lf;
}

int close_locked_file(LockedFile *lf) {
    if (lf == NULL) return -1;
    
    int result = 0;
    
    if (lf->file) {
        if (fclose(lf->file) != 0) {
            result = -1;
        }
    }
    
    // Release lock (platform-specific implementation needed)
    
    free(lf->filename);
    free(lf);
    return result;
}
```

### Comprehensive Error Logging

**Example** implementing detailed error logging system:
```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>

typedef enum {
    LOG_DEBUG,
    LOG_INFO,
    LOG_WARNING,
    LOG_ERROR,
    LOG_CRITICAL
} LogLevel;

const char* log_level_string(LogLevel level) {
    switch (level) {
        case LOG_DEBUG: return "DEBUG";
        case LOG_INFO: return "INFO";
        case LOG_WARNING: return "WARNING";
        case LOG_ERROR: return "ERROR";
        case LOG_CRITICAL: return "CRITICAL";
        default: return "UNKNOWN";
    }
}

void log_message(LogLevel level, const char *format, ...) {
    FILE *log_file = fopen("file_operations.log", "a");
    if (log_file == NULL) {
        // Fallback to stderr if log file cannot be opened
        log_file = stderr;
    }
    
    // Get current timestamp
    time_t now = time(NULL);
    char timestamp[64];
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", localtime(&now));
    
    // Write log entry header
    fprintf(log_file, "[%s] %s: ", timestamp, log_level_string(level));
    
    // Write formatted message
    va_list args;
    va_start(args, format);
    vfprintf(log_file, format, args);
    va_end(args);
    
    fprintf(log_file, "\n");
    
    if (log_file != stderr) {
        fclose(log_file);
    }
}

FileOpResult safe_file_operation_with_logging(const char *source, const char *dest) {
    log_message(LOG_INFO, "Starting file copy operation: %s -> %s", source, dest);
    
    FILE *src = fopen(source, "rb");
    if (src == NULL) {
        log_message(LOG_ERROR, "Failed to open source file '%s': %s (errno=%d)", 
                    source, strerror(errno), errno);
        return FILE_OP_OPEN_ERROR;
    }
    
    log_message(LOG_DEBUG, "Source file opened successfully");
    
    FILE *dst = fopen(dest, "wb");
    if (dst == NULL) {
        log_message(LOG_ERROR, "Failed to open destination file '%s': %s (errno=%d)", 
                    dest, strerror(errno), errno);
        fclose(src);
        return FILE_OP_OPEN_ERROR;
    }
    
    log_message(LOG_DEBUG, "Destination file opened successfully");
    
    // Perform copy operation with detailed logging
    const size_t buffer_size = 8192;
    unsigned char buffer[buffer_size];
    size_t total_bytes = 0;
    size_t bytes_read;
    
    while ((bytes_read = fread(buffer, 1, buffer_size, src)) > 0) {
        if (fwrite(buffer, 1, bytes_read, dst) != bytes_read) {
            log_message(LOG_CRITICAL, "Write operation failed after %zu bytes: %s", 
                        total_bytes, strerror(errno));
            fclose(src);
            fclose(dst);
            return FILE_OP_WRITE_ERROR;
        }
        total_bytes += bytes_read;
        
        if (total_bytes % (1024 * 1024) == 0) {  // Log every MB
            log_message(LOG_DEBUG, "Copied %zu bytes", total_bytes);
        }
    }
    
    if (ferror(src)) {
        log_message(LOG_ERROR, "Read error after %zu bytes: %s", 
                    total_bytes, strerror(errno));
        fclose(src);
        fclose(dst);
        return FILE_OP_READ_ERROR;
    }
    
    fclose(src);
    fclose(dst);
    
    log_message(LOG_INFO, "File copy completed successfully: %zu bytes transferred", 
                total_bytes);
    return FILE_OP_SUCCESS;
}
```

### Error Recovery Strategies

**Example** implementing graceful degradation for file operations:
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

typedef struct {
    char **fallback_paths;
    int path_count;
    int current_path;
} FallbackConfig;

FallbackConfig* create_fallback_config(void) {
    FallbackConfig *config = (FallbackConfig*)malloc(sizeof(FallbackConfig));
    if (config == NULL) return NULL;
    
    config->fallback_paths = (char**)malloc(4 * sizeof(char*));
    if (config->fallback_paths == NULL) {
        free(config);
        return NULL;
    }
    
    // Set up fallback paths
    config->fallback_paths[0] = strdup("/tmp/");
    config->fallback_paths[1] = strdup("./temp/");
    config->fallback_paths[2] = strdup("./");
    config->fallback_paths[3] = strdup("/var/tmp/");
    config->path_count = 4;
    config->current_path = 0;
    
    return config;
}

FILE* open_with_fallback(const char *filename, const char *mode, 
                        FallbackConfig *config) {
    char full_path[512];
    FILE *file = NULL;
    
    for (int i = 0; i < config->path_count; i++) {
        snprintf(full_path, sizeof(full_path), "%s%s", 
                 config->fallback_paths[i], filename);
        
        file = fopen(full_path, mode);
        if (file != NULL) {
            config->current_path = i;
            log_message(LOG_INFO, "Successfully opened file at: %s", full_path);
            return file;
        }
        
        log_message(LOG_WARNING, "Failed to open file at %s: %s", 
                    full_path, strerror(errno));
    }
    
    log_message(LOG_ERROR, "Failed to open file '%s' at any fallback location", 
                filename);
    return NULL;
}

void destroy_fallback_config(FallbackConfig *config) {
    if (config != NULL) {
        if (config->fallback_paths != NULL) {
            for (int i = 0; i < config->path_count; i++) {
                free(config->fallback_paths[i]);
            }
            free(config->fallback_paths);
        }
        free(config);
    }
}
```

**Key points** about error handling in file operations:
- Always check return values from file operations
- Use `errno` and `strerror()` for detailed error information
- Implement proper resource cleanup in error conditions
- Consider transactional approaches for critical data updates
- Log errors comprehensively for debugging and monitoring
- Implement retry mechanisms for transient failures
- Use fallback strategies when primary operations fail

**Conclusion**

File handling in C provides comprehensive capabilities for data persistence and external system interaction. The layered approach from basic file operations through sequential processing, random access, binary operations, and robust error handling enables development of reliable file-based applications. Understanding file modes, buffer management, positioning functions, and error recovery strategies creates the foundation for implementing database systems, configuration management, data processing pipelines, and system administration tools. [Inference] Effective file handling combines technical proficiency with careful attention to error conditions and data integrity requirements, essential for production-quality software development.

---

