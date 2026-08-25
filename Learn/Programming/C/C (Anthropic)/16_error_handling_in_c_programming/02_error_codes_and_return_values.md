## Error Codes and Return Values


**Standard Return Value Conventions** Most C library functions follow established conventions for indicating success or failure. Functions typically return zero or a positive value for success, and negative values or special constants for errors. For example, `malloc()` returns `NULL` on failure, while many system calls return -1 to indicate errors.

**Custom Error Code Systems** Applications often implement custom error code schemes using enumerated types or integer constants. Well-designed error codes should be hierarchical, allowing categorization of errors by severity, subsystem, or error type. Error codes should be documented and consistent across the application.

**Error Information Preservation** Beyond simple success/failure indicators, robust error handling preserves additional error information. This includes error descriptions, error locations within the code, and contextual information about the conditions that led to the error. Some systems maintain error stacks or chains to track error propagation.

**Global Error State** The standard C library uses `errno` as a global variable to provide additional error information when functions fail. While convenient, global error state can create thread safety issues and requires careful management to avoid race conditions in multi-threaded applications.

