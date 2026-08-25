## Documentation Practices


Comprehensive documentation ensures code maintainability, team collaboration, and knowledge transfer.

**API Documentation with Doxygen**

```c
/**
 * @file book_manager.h
 * @brief Book management module for library system
 * @author Development Team
 * @date 2024-01-15
 * @version 1.0
 * 
 * This module provides comprehensive book management functionality including
 * inventory management, search capabilities, and availability tracking.
 * 
 * @section usage Usage Example
 * @code
 * BookManager* manager = book_manager_create(100);
 * Book new_book = {0, "Title", "Author", "ISBN", 2024, true, 0, 0};
 * book_manager_add(manager, &new_book);
 * 
 * size_t count;
 * Book** results = book_manager_search(manager, "Title", &count);
 * // Use results...
 * free(results);
 * book_manager_destroy(manager);
 * @endcode
 * 
 * @section thread_safety Thread Safety
 * This module is NOT thread-safe. External synchronization required for
 * concurrent access.
 * 
 * @section memory_management Memory Management
 * - BookManager objects must be created with book_manager_create()
 * - BookManager objects must be destroyed with book_manager_destroy()
 * - Search results must be freed by caller using free()
 */

#ifndef BOOK_MANAGER_H
#define BOOK_MANAGER_H

#include "data_model.h"

/**
 * @brief Opaque book manager structure
 * 
 * Contains internal book storage and management state. Implementation
 * details are hidden to ensure encapsulation and allow internal changes
 * without affecting client code.
 */
typedef struct BookManager BookManager;

/**
 * @brief Creates a new book manager instance
 * 
 * Allocates and initializes a new BookManager with specified initial capacity.
 * The capacity will grow automatically as needed.
 * 
 * @param initial_capacity Initial number of books to allocate space for.
 *                        If 0, uses default capacity of 100 books.
 * 
 * @return Pointer to new BookManager instance, or NULL if allocation fails
 * 
 * @post If successful, returned BookManager has zero books and is ready for use
 * @post Caller is responsible for calling book_manager_destroy() to free memory
 * 
 * @see book_manager_destroy()
 * 
 * @warning Memory allocation may fail - always check return value
 * 
 * @par Time Complexity
 * O(1) - Constant time allocation
 * 
 * @par Memory Usage
 * Allocates sizeof(BookManager) + initial_capacity * sizeof(Book) bytes
 */
BookManager* book_manager_create(size_t initial_capacity);

/**
 * @brief Destroys a book manager instance
 * 
 * Frees all memory associated with the BookManager, including the internal
 * book storage. After calling this function, the BookManager pointer becomes
 * invalid and must not be used.
 * 
 * @param manager BookManager instance to destroy. Can be NULL (no-op).
 * 
 * @pre manager was created by book_manager_create() or is NULL
 * @post manager pointer becomes invalid
 * @post All memory is freed
 * 
 * @see book_manager_create()
 * 
 * @par Time Complexity
 * O(1) - Constant time deallocation
 */
void book_manager_destroy(BookManager* manager);

/**
 * @brief Adds a new book to the manager
 * 
 * Inserts a copy of the provided book into the manager's collection.
 * The book ID will be automatically assigned and should be ignored in
 * the input book structure.
 * 
 * @param manager Valid BookManager instance
 * @param book Book structure to add. ID field will be overwritten.
 * 
 * @return ERR_SUCCESS on success, error code on failure:
 *         - ERR_INVALID_PARAM: manager or book is NULL, or book data invalid
 *         - ERR_OUT_OF_MEMORY: insufficient memory to expand collection
 * 
 * @pre manager != NULL
 * @pre book != NULL
 * @pre book->title is not empty
 * @pre book->isbn is valid ISBN format
 * 
 * @post On success, book count increases by 1
 * @post Added book gets unique ID assigned
 * @post Collection may be resized if at capacity
 * 
 * @see book_manager_remove(), validate_isbn()
 * 
 * @par Time Complexity
 * - Average case: O(1) amortized
 * - Worst case: O(n) when resizing is needed
 */
int book_manager_add(BookManager* manager, const Book* book);

/**
 * @brief Searches for books matching a query string
 * 
 * Performs case-insensitive substring search on book titles and authors.
 * Returns an array of pointers to matching books. The caller is responsible
 * for freeing the returned array (but not the individual Book pointers).
 * 
 * @param manager Valid BookManager instance
 * @param query Search string to match against titles and authors
 * @param result_count [out] Pointer to store number of matches found
 * 
 * @return Array of Book pointers matching query, or NULL if no matches.
 *         Caller must free() the returned array.
 * 
 * @pre manager != NULL
 * @pre query != NULL
 * @pre result_count != NULL
 * 
 * @post *result_count contains number of matches (0 if no matches)
 * @post Returned pointers reference books owned by manager
 * @post Caller must free() returned array but NOT the Book objects
 * 
 * @warning Book pointers become invalid after book_manager_destroy()
 * @warning Returned array must be freed to prevent memory leak
 * 
 * @par Time Complexity
 * O(n) where n is number of books in collection
 * 
 * @par Example
 * @code
 * size_t count;
 * Book** results = book_manager_search(mgr, "programming", &count);
 * if (results) {
 *     for (size_t i = 0; i < count; i++) {
 *         printf("Found: %s\n", results[i]->title);
 *     }
 *     free(results);  // Free array, not individual books
 * }
 * @endcode
 */
Book** book_manager_search(BookManager* manager, const char* query, 
                          size_t* result_count);

#endif
```

**README Documentation**

````markdown
# Library Management System

A comprehensive C-based library management system designed for educational institutions and public libraries.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Features

### Core Functionality
- **Book Management**: Add, remove, search, and update book records
- **User Management**: Registration, authentication, and profile management
- **Borrowing System**: Check-out, return, renewal, and reservation system
- **Fine Management**: Automatic calculation and payment tracking
- **Reporting**: Overdue books, popular titles, and usage statistics

### Technical Features
- **Memory Efficient**: Optimized data structures and algorithms
- **Cross-Platform**: Supports Linux, Windows, and macOS
- **Modular Design**: Clean separation of concerns for maintainability
- **Comprehensive Testing**: Unit, integration, and memory leak testing
- **Documentation**: Full API documentation with examples

## Requirements

### System Requirements
- C compiler (GCC 7.0+ or Clang 6.0+)
- Make build system
- Minimum 50MB RAM
- 100MB disk space for data files

### Development Requirements
- Git for version control
- Doxygen for documentation generation
- Valgrind for memory testing (Linux/macOS)
- CppCheck for static analysis

## Installation

### From Source
```bash
