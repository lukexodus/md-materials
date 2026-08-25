## Testing Strategies


Comprehensive testing ensures code reliability, catches regressions, and facilitates refactoring.

**Unit Testing Framework**

```c
// test_framework.h - Simple unit testing framework
#ifndef TEST_FRAMEWORK_H
#define TEST_FRAMEWORK_H

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

// Test result tracking
typedef struct {
    int total_tests;
    int passed_tests;
    int failed_tests;
    const char* current_suite;
} TestResults;

extern TestResults test_results;

// Test macros
#define TEST_SUITE(name) \
    do { \
        printf("\n=== Test Suite: %s ===\n", name); \
        test_results.current_suite = name; \
    } while(0)

#define TEST_CASE(name) \
    printf("Running test: %s... ", name)

#define ASSERT_TRUE(condition) \
    do { \
        test_results.total_tests++; \
        if (condition) { \
            printf("PASS\n"); \
            test_results.passed_tests++; \
        } else { \
            printf("FAIL - %s:%d\n", __FILE__, __LINE__); \
            test_results.failed_tests++; \
        } \
    } while(0)

#define ASSERT_FALSE(condition) ASSERT_TRUE(!(condition))

#define ASSERT_EQUAL_INT(expected, actual) \
    ASSERT_TRUE((expected) == (actual))

#define ASSERT_EQUAL_STRING(expected, actual) \
    ASSERT_TRUE(strcmp(expected, actual) == 0)

#define ASSERT_NOT_NULL(ptr) ASSERT_TRUE((ptr) != NULL)

#define ASSERT_NULL(ptr) ASSERT_TRUE((ptr) == NULL)

// Test reporting
void print_test_summary(void);
void reset_test_results(void);

#endif
```

**Unit Test Implementation**

```c
// test_book_manager.c - Unit tests for book manager module
#include "test_framework.h"
#include "book_manager.h"
#include <stdlib.h>

TestResults test_results = {0, 0, 0, NULL};

void test_book_manager_creation(void) {
    TEST_CASE("book_manager_create");
    
    BookManager* manager = book_manager_create(10);
    ASSERT_NOT_NULL(manager);
    ASSERT_EQUAL_INT(0, book_manager_get_count(manager));
    
    book_manager_destroy(manager);
}

void test_book_manager_add(void) {
    TEST_CASE("book_manager_add");
    
    BookManager* manager = book_manager_create(10);
    Book test_book = {
        .id = 0,  // Will be auto-assigned
        .title = "Test Book",
        .author = "Test Author",
        .isbn = "9781234567890",
        .publication_year = 2024,
        .is_available = true,
        .borrower_id = 0
    };
    
    int result = book_manager_add(manager, &test_book);
    ASSERT_EQUAL_INT(ERR_SUCCESS, result);
    ASSERT_EQUAL_INT(1, book_manager_get_count(manager));
    
    book_manager_destroy(manager);
}

void test_book_manager_search(void) {
    TEST_CASE("book_manager_search");
    
    BookManager* manager = book_manager_create(10);
    
    // Add test books
    Book book1 = {0, "C Programming", "Dennis Ritchie", "9781111111111", 
                  1978, true, 0, 0};
    Book book2 = {0, "Advanced C", "Peter van der Linden", "9782222222222", 
                  1994, true, 0, 0};
    Book book3 = {0, "Python Programming", "Mark Lutz", "9783333333333", 
                  2013, true, 0, 0};
    
    book_manager_add(manager, &book1);
    book_manager_add(manager, &book2);
    book_manager_add(manager, &book3);
    
    // Search for C books
    size_t result_count;
    Book** results = book_manager_search(manager, "C", &result_count);
    
    ASSERT_NOT_NULL(results);
    ASSERT_EQUAL_INT(2, result_count);  // Should find 2 C books
    
    free(results);
    book_manager_destroy(manager);
}

void test_book_manager_invalid_params(void) {
    TEST_CASE("book_manager_invalid_params");
    
    // Test null parameters
    ASSERT_NULL(book_manager_create(0));  // Should use default capacity
    ASSERT_EQUAL_INT(ERR_INVALID_PARAM, book_manager_add(NULL, NULL));
    ASSERT_NULL(book_manager_find_by_id(NULL, 1));
    
    BookManager* manager = book_manager_create(10);
    
    // Test invalid book data
    Book invalid_book = {0, "", "", "invalid-isbn", 0, true, 0, 0};
    ASSERT_EQUAL_INT(ERR_INVALID_PARAM, book_manager_add(manager, &invalid_book));
    
    book_manager_destroy(manager);
}

int main(void) {
    reset_test_results();
    
    TEST_SUITE("BookManager Tests");
    test_book_manager_creation();
    test_book_manager_add();
    test_book_manager_search();
    test_book_manager_invalid_params();
    
    print_test_summary();
    
    return (test_results.failed_tests == 0) ? 0 : 1;
}

void print_test_summary(void) {
    printf("\n=== Test Summary ===\n");
    printf("Total tests: %d\n", test_results.total_tests);
    printf("Passed: %d\n", test_results.passed_tests);
    printf("Failed: %d\n", test_results.failed_tests);
    printf("Success rate: %.1f%%\n", 
           (float)test_results.passed_tests / test_results.total_tests * 100);
}

void reset_test_results(void) {
    test_results.total_tests = 0;
    test_results.passed_tests = 0;
    test_results.failed_tests = 0;
    test_results.current_suite = NULL;
}
```

**Integration Testing**

```c
// test_integration.c - Integration tests
#include "test_framework.h"
#include "system_facade.h"

void test_borrow_return_workflow(void) {
    TEST_CASE("borrow_return_workflow");
    
    LibrarySystem* system = library_system_create();
    ASSERT_NOT_NULL(system);
    
    // Add test user
    User test_user = {1, "testuser", "test@example.com", 
                      "hashedpassword", time(NULL), true, 0.0};
    // user_manager_add(system->user_mgr, &test_user);
    
    // Add test book
    Book test_book = {1, "Test Book", "Test Author", "9781111111111", 
                      2024, true, 0, 0};
    // book_manager_add(system->book_mgr, &test_book);
    
    // Test borrow operation
    int result = library_borrow_book(system, 1, 1);
    ASSERT_EQUAL_INT(ERR_SUCCESS, result);
    
    // Verify book is no longer available
    // Book* book = book_manager_find_by_id(system->book_mgr, 1);
    // ASSERT_FALSE(book->is_available);
    
    // Test return operation
    result = library_return_book(system, 1, 1);
    ASSERT_EQUAL_INT(ERR_SUCCESS, result);
    
    library_system_destroy(system);
}

void test_fine_calculation(void) {
    TEST_CASE("fine_calculation");
    
    LibrarySystem* system = library_system_create();
    
    // Set up overdue scenario
    // This would involve mocking time or using test data
    // [Inference] Fine calculation depends on overdue days and rate
    
    float fines = library_calculate_fines(system, 1);
    ASSERT_TRUE(fines >= 0.0);  // Fines should be non-negative
    
    library_system_destroy(system);
}

int main(void) {
    reset_test_results();
    
    TEST_SUITE("Integration Tests");
    test_borrow_return_workflow();
    test_fine_calculation();
    
    print_test_summary();
    
    return (test_results.failed_tests == 0) ? 0 : 1;
}
```

**Memory Testing with Valgrind Integration**

```bash
#!/bin/bash
# run_memory_tests.sh

echo "Running memory leak detection..."

# Compile with debug symbols
gcc -g -O0 -o test_program test_main.c src/*.c -I include/

# Run with Valgrind
valgrind --tool=memcheck \
         --leak-check=full \
         --show-leak-kinds=all \
         --track-origins=yes \
         --verbose \
         --log-file=valgrind_report.txt \
         ./test_program

# Check results
if [ $? -eq 0 ]; then
    echo "Memory tests completed successfully"
    grep -q "ERROR SUMMARY: 0 errors" valgrind_report.txt
    if [ $? -eq 0 ]; then
        echo "No memory errors detected"
    else
        echo "Memory errors found - check valgrind_report.txt"
        exit 1
    fi
else
    echo "Memory tests failed"
    exit 1
fi
```

