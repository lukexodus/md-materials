## Random Access Files


Random access enables direct positioning within files, allowing efficient reading and writing at arbitrary locations. This capability suits applications requiring database-like operations, indexed file structures, and selective data updates.

### File Positioning Functions

#### fseek()

```c
int fseek(FILE *stream, long offset, int whence);
```

The `whence` parameter specifies the reference point:

- `SEEK_SET` - Beginning of file
- `SEEK_CUR` - Current position
- `SEEK_END` - End of file

#### ftell()

```c
long ftell(FILE *stream);
```

Returns the current file position as a byte offset from the beginning.

#### rewind()

```c
void rewind(FILE *stream);
```

Resets the file position to the beginning, equivalent to `fseek(stream, 0, SEEK_SET)`.

**Example** of random access file operations:

```c
#include <stdio.h>
#include <string.h>

typedef struct {
    int id;
    char name[32];
    float balance;
    int active;
} Account;

#define RECORD_SIZE sizeof(Account)

void write_account_at_position(FILE *file, const Account *account, int position) {
    if (fseek(file, position * RECORD_SIZE, SEEK_SET) == 0) {
        fwrite(account, RECORD_SIZE, 1, file);
        fflush(file);  // Ensure data is written immediately
    }
}

int read_account_at_position(FILE *file, Account *account, int position) {
    if (fseek(file, position * RECORD_SIZE, SEEK_SET) == 0) {
        return fread(account, RECORD_SIZE, 1, file) == 1;
    }
    return 0;
}

void demonstrate_random_access() {
    const char *filename = "accounts.dat";
    FILE *file = fopen(filename, "w+b");  // Read-write binary mode
    
    if (file == NULL) {
        perror("Error creating file");
        return;
    }
    
    // Create sample accounts
    Account accounts[] = {
        {1001, "Alice Johnson", 1500.50, 1},
        {1002, "Bob Smith", 2300.75, 1},
        {1003, "Carol Davis", 850.25, 0},
        {1004, "David Wilson", 3200.00, 1}
    };
    
    // Write accounts at specific positions
    for (int i = 0; i < 4; i++) {
        write_account_at_position(file, &accounts[i], i);
    }
    
    // Read account at position 2
    Account retrieved;
    if (read_account_at_position(file, &retrieved, 2)) {
        printf("Account at position 2: ID=%d, Name=%s, Balance=%.2f, Active=%d\n",
               retrieved.id, retrieved.name, retrieved.balance, retrieved.active);
    }
    
    // Update account at position 1
    Account updated = {1002, "Bob Smith Jr.", 2500.00, 1};
    write_account_at_position(file, &updated, 1);
    
    // Verify update
    if (read_account_at_position(file, &retrieved, 1)) {
        printf("Updated account: ID=%d, Name=%s, Balance=%.2f\n",
               retrieved.id, retrieved.name, retrieved.balance);
    }
    
    fclose(file);
}
```

### Index-Based File Access

Random access files often benefit from index structures for efficient record lookup:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int key;
    long file_position;
} IndexEntry;

typedef struct {
    IndexEntry *entries;
    int count;
    int capacity;
} Index;

Index *create_index(int initial_capacity) {
    Index *idx = (Index*)malloc(sizeof(Index));
    if (idx == NULL) return NULL;
    
    idx->entries = (IndexEntry*)malloc(initial_capacity * sizeof(IndexEntry));
    if (idx->entries == NULL) {
        free(idx);
        return NULL;
    }
    
    idx->count = 0;
    idx->capacity = initial_capacity;
    return idx;
}

int add_index_entry(Index *idx, int key, long position) {
    if (idx->count >= idx->capacity) {
        int new_capacity = idx->capacity * 2;
        IndexEntry *new_entries = (IndexEntry*)realloc(
            idx->entries, new_capacity * sizeof(IndexEntry));
        if (new_entries == NULL) return 0;
        
        idx->entries = new_entries;
        idx->capacity = new_capacity;
    }
    
    idx->entries[idx->count].key = key;
    idx->entries[idx->count].file_position = position;
    idx->count++;
    return 1;
}

long find_record_position(Index *idx, int key) {
    for (int i = 0; i < idx->count; i++) {
        if (idx->entries[i].key == key) {
            return idx->entries[i].file_position;
        }
    }
    return -1;  // Not found
}

void destroy_index(Index *idx) {
    if (idx != NULL) {
        free(idx->entries);
        free(idx);
    }
}
```

### File Size and Capacity Management

Random access files require careful size management:

```c
#include <stdio.h>

long get_file_size(FILE *file) {
    long current_pos = ftell(file);
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    fseek(file, current_pos, SEEK_SET);  // Restore original position
    return size;
}

int extend_file_to_size(FILE *file, long target_size) {
    long current_size = get_file_size(file);
    if (current_size >= target_size) {
        return 1;  // Already large enough
    }
    
    fseek(file, 0, SEEK_END);
    long bytes_to_add = target_size - current_size;
    
    while (bytes_to_add > 0) {
        fputc(0, file);  // Write zero bytes
        bytes_to_add--;
    }
    
    return ferror(file) == 0;
}
```

