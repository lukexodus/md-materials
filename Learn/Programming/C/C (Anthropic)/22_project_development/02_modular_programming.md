## Modular Programming


Modular programming promotes code reusability, maintainability, and team development efficiency through well-defined interfaces and separation of concerns.

**Module Structure and Organization**

```c
// File structure example:
/*
project_root/
├── src/
│   ├── core/
│   │   ├── book_manager.c
│   │   ├── user_manager.c
│   │   └── transaction_manager.c
│   ├── data/
│   │   ├── database.c
│   │   └── file_io.c
│   ├── ui/
│   │   ├── console_ui.c
│   │   └── menu_system.c
│   └── utils/
│       ├── string_utils.c
│       ├── date_utils.c
│       └── validation.c
├── include/
│   ├── core/
│   ├── data/
│   ├── ui/
│   └── utils/
├── tests/
├── docs/
└── build/
*/

// book_manager.h - Module interface definition
#ifndef BOOK_MANAGER_H
#define BOOK_MANAGER_H

#include "data_model.h"

// Public interface - what other modules can use
typedef struct BookManager BookManager;

// Module lifecycle
BookManager* book_manager_create(size_t initial_capacity);
void book_manager_destroy(BookManager* manager);

// Core operations
int book_manager_add(BookManager* manager, const Book* book);
int book_manager_remove(BookManager* manager, unsigned int book_id);
Book* book_manager_find_by_id(BookManager* manager, unsigned int book_id);
Book** book_manager_search(BookManager* manager, const char* query, 
                          size_t* result_count);

// Status operations
bool book_manager_is_available(BookManager* manager, unsigned int book_id);
int book_manager_checkout(BookManager* manager, unsigned int book_id, 
                         unsigned int user_id);
int book_manager_return(BookManager* manager, unsigned int book_id);

// Statistics
size_t book_manager_get_count(BookManager* manager);
size_t book_manager_get_available_count(BookManager* manager);

#endif
```

**Module Implementation with Encapsulation**

```c
// book_manager.c - Private implementation
#include "book_manager.h"
#include "string_utils.h"
#include "validation.h"
#include <stdlib.h>
#include <string.h>

// Private structure - hidden from other modules
struct BookManager {
    Book* books;
    size_t count;
    size_t capacity;
    bool is_sorted;  // Optimization flag
};

// Private helper functions
static int compare_books_by_title(const void* a, const void* b) {
    const Book* book_a = (const Book*)a;
    const Book* book_b = (const Book*)b;
    return strcmp(book_a->title, book_b->title);
}

static void ensure_sorted(BookManager* manager) {
    if (!manager->is_sorted && manager->count > 1) {
        qsort(manager->books, manager->count, sizeof(Book), compare_books_by_title);
        manager->is_sorted = true;
    }
}

static int resize_if_needed(BookManager* manager) {
    if (manager->count >= manager->capacity) {
        size_t new_capacity = manager->capacity * 2;
        Book* new_books = realloc(manager->books, new_capacity * sizeof(Book));
        if (!new_books) {
            return ERR_OUT_OF_MEMORY;
        }
        manager->books = new_books;
        manager->capacity = new_capacity;
    }
    return ERR_SUCCESS;
}

// Public interface implementation
BookManager* book_manager_create(size_t initial_capacity) {
    if (initial_capacity == 0) {
        initial_capacity = 100;  // Default capacity
    }
    
    BookManager* manager = malloc(sizeof(BookManager));
    if (!manager) {
        return NULL;
    }
    
    manager->books = malloc(initial_capacity * sizeof(Book));
    if (!manager->books) {
        free(manager);
        return NULL;
    }
    
    manager->count = 0;
    manager->capacity = initial_capacity;
    manager->is_sorted = true;
    
    return manager;
}

void book_manager_destroy(BookManager* manager) {
    if (manager) {
        free(manager->books);
        free(manager);
    }
}

int book_manager_add(BookManager* manager, const Book* book) {
    if (!manager || !book) {
        return ERR_INVALID_PARAM;
    }
    
    // Validate book data
    if (!validate_isbn(book->isbn) || strlen(book->title) == 0) {
        return ERR_INVALID_PARAM;
    }
    
    // Resize if necessary
    int result = resize_if_needed(manager);
    if (result != ERR_SUCCESS) {
        return result;
    }
    
    // Add book
    manager->books[manager->count] = *book;
    manager->books[manager->count].id = manager->count + 1;  // Auto-assign ID
    manager->count++;
    manager->is_sorted = false;  // Mark as unsorted
    
    return ERR_SUCCESS;
}

Book* book_manager_find_by_id(BookManager* manager, unsigned int book_id) {
    if (!manager || book_id == 0) {
        return NULL;
    }
    
    for (size_t i = 0; i < manager->count; i++) {
        if (manager->books[i].id == book_id) {
            return &manager->books[i];
        }
    }
    
    return NULL;
}

Book** book_manager_search(BookManager* manager, const char* query, 
                          size_t* result_count) {
    if (!manager || !query || !result_count) {
        if (result_count) *result_count = 0;
        return NULL;
    }
    
    // Count matching books
    size_t match_count = 0;
    for (size_t i = 0; i < manager->count; i++) {
        if (string_contains_ignore_case(manager->books[i].title, query) ||
            string_contains_ignore_case(manager->books[i].author, query)) {
            match_count++;
        }
    }
    
    if (match_count == 0) {
        *result_count = 0;
        return NULL;
    }
    
    // Allocate result array
    Book** results = malloc(match_count * sizeof(Book*));
    if (!results) {
        *result_count = 0;
        return NULL;
    }
    
    // Fill result array
    size_t result_index = 0;
    for (size_t i = 0; i < manager->count; i++) {
        if (string_contains_ignore_case(manager->books[i].title, query) ||
            string_contains_ignore_case(manager->books[i].author, query)) {
            results[result_index++] = &manager->books[i];
        }
    }
    
    *result_count = match_count;
    return results;
}

size_t book_manager_get_count(BookManager* manager) {
    return manager ? manager->count : 0;
}
```

**Inter-Module Communication**

```c
// system_facade.h - Coordinating module interactions
#ifndef SYSTEM_FACADE_H
#define SYSTEM_FACADE_H

#include "book_manager.h"
#include "user_manager.h"
#include "transaction_manager.h"

typedef struct {
    BookManager* book_mgr;
    UserManager* user_mgr;
    TransactionManager* transaction_mgr;
} LibrarySystem;

// High-level operations that coordinate multiple modules
LibrarySystem* library_system_create(void);
void library_system_destroy(LibrarySystem* system);

// Business operations
int library_borrow_book(LibrarySystem* system, unsigned int user_id, 
                       unsigned int book_id);
int library_return_book(LibrarySystem* system, unsigned int user_id, 
                       unsigned int book_id);
float library_calculate_fines(LibrarySystem* system, unsigned int user_id);

// Reports
void library_generate_overdue_report(LibrarySystem* system);
void library_generate_popular_books_report(LibrarySystem* system);

#endif
```

